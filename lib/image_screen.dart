import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'profile_drawer.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});
  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final FlutterTts _tts = FlutterTts();

  // Replace with your actual API Key from Google AI Studio
  final String _apiKey = 'AIzaSyAJRoFVEKWk1Q_6jYe8bRLv80Dmucrssos';

  String _extractedText = "Select an image to extract text...";
  String _aiResponse = "AI Analysis and Translation will appear here...";
  bool _isProcessing = false;
  String _targetLang = "Hindi";

  final List<String> _langs = [
    "Hindi",
    "Spanish",
    "French",
    "German",
    "Marathi",
  ];

  Future<void> _processWithGemini() async {
    if (_extractedText.isEmpty || _extractedText.contains("Select an image"))
      return;

    setState(() => _isProcessing = true);

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      // We ask Gemini to handle both Translation and Summary in one go for better grammar
      final prompt =
          """
      Analyze this text extracted from an image: "$_extractedText".
      1. Translate it accurately into $_targetLang with perfect grammar.
      2. Provide a 2-sentence summary in $_targetLang.
      Format the output clearly.
      """;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _aiResponse = response.text ?? "No response from AI.";
        _isProcessing = false;
      });

      // AI speaks the response back
      await _tts.setLanguage(_targetLang == "Hindi" ? "hi" : "en");
      await _tts.speak(_aiResponse);
    } catch (e) {
      setState(() {
        _aiResponse =
            "Error: Please check your API key or Internet connection.";
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isProcessing = true);

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      setState(() {
        _extractedText = recognizedText.text;
      });

      textRecognizer.close();
      _processWithGemini();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vision AI Analyzer"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: ProfileDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Extracted Raw Text:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            _buildDisplayBox(_extractedText, Colors.grey[100]!),

            const SizedBox(height: 20),
            const Text(
              "Target Language:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _targetLang,
                  isExpanded: true,
                  items: _langs
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _targetLang = val!);
                    _processWithGemini();
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Gemini AI Analysis (Summary & Translation):",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            _buildDisplayBox(
              _aiResponse,
              Colors.deepPurple.withOpacity(0.05),
              isAi: true,
            ),

            const SizedBox(height: 30),
            Center(
              child: FloatingActionButton.extended(
                onPressed: _isProcessing ? null : _pickImage,
                label: Text(_isProcessing ? "AI is Thinking..." : "Scan Image"),
                icon: const Icon(Icons.add_a_photo),
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayBox(String text, Color color, {bool isAi = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 300),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: isAi
            ? Border.all(color: Colors.deepPurple.withOpacity(0.2))
            : null,
      ),
      child: SingleChildScrollView(
        child: _isProcessing && isAi
            ? const Center(child: CircularProgressIndicator())
            : Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
