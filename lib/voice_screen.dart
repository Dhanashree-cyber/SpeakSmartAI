import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'profile_drawer.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});
  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();

  String _wordsSpoken = "Waiting for speech...";
  String _translatedText = "Translation will appear here...";
  bool _isListening = false;
  String _targetLang = "hi";

  final List<Map<String, String>> _langs = [
    {'name': 'Hindi', 'code': 'hi'},
    {'name': 'Spanish', 'code': 'es'},
    {'name': 'French', 'code': 'fr'},
    {'name': 'German', 'code': 'de'},
    {'name': 'Marathi', 'code': 'mr'},
    {'name': 'Japanese', 'code': 'ja'},
  ];

  // This function is now separate so it can be called anytime the language changes
  void _runTranslation() async {
    if (_wordsSpoken.isEmpty || _wordsSpoken == "Waiting for speech...") return;

    var translation = await _translator.translate(
      _wordsSpoken,
      to: _targetLang,
    );
    setState(() {
      _translatedText = translation.text;
    });

    await _tts.setLanguage(_targetLang);
    await _tts.speak(_translatedText);
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _wordsSpoken = result.recognizedWords;
            if (result.finalResult) {
              _isListening = false;
              _runTranslation(); // Initial translation
            }
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice AI Assistant")),
      drawer: ProfileDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YOU SPOKE SECTION
            const Text(
              "You Spoke:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              constraints: const BoxConstraints(minHeight: 80),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(_wordsSpoken, style: const TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 25),

            // LANGUAGE SELECTOR (REACTIVE)
            const Text(
              "Translate to:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _targetLang,
                  isExpanded: true,
                  items: _langs
                      .map(
                        (l) => DropdownMenuItem(
                          value: l['code'],
                          child: Text(l['name']!),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _targetLang = val!;
                    });
                    // BRO: This is the magic part - it re-translates immediately!
                    _runTranslation();
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            // TRANSLATED OUTPUT SECTION
            const Text(
              "AI Translation:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              constraints: const BoxConstraints(minHeight: 80),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
              ),
              child: Text(
                _translatedText,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),

            const Spacer(),

            // MIC BUTTON
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isListening ? null : _startListening,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: _isListening
                          ? Colors.red
                          : Colors.deepPurple,
                      child: Icon(
                        _isListening ? Icons.graphic_eq : Icons.mic,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isListening ? "Listening..." : "Tap to Speak",
                    style: TextStyle(
                      color: _isListening ? Colors.red : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
