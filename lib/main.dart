import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔥 Firebase Save Function (WITH DEBUG)
Future<void> saveTranslation(String input, String output) async {
  try {
    print("🔥 Saving: $input -> $output");

    await FirebaseFirestore.instance.collection('translations').add({
      'input': input,
      'output': output,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("✅ Saved successfully!");
  } catch (e) {
    print("❌ Firebase Error: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SpeakSmartApp());
}

class SpeakSmartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpeakGlobeAI',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: VoiceScreen(),
    );
  }
}

class VoiceScreen extends StatefulWidget {
  @override
  _VoiceScreenState createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = "Press the button and start speaking";

  final translator = GoogleTranslator();
  String _translatedText = "";

  FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTTS();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("STATUS: $status"),
      onError: (error) => print("ERROR: $error"),
    );
    print("🎤 Speech available: $available");
  }

  void _initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.35);
  }

  Future speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.stop();
      await Future.delayed(Duration(milliseconds: 200));
      await _flutterTts.speak(text);
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult: (result) async {

            if (result.recognizedWords.isNotEmpty) {
              setState(() {
                _text = result.recognizedWords;
              });
            }

            if (result.finalResult) {
              print("🎯 Final speech: $_text");

              await _speech.stop();
              setState(() => _isListening = false);

              try {
                var translation =
                    await translator.translate(_text, to: 'en');

                setState(() {
                  _translatedText = translation.text;
                });

                print("🌍 Translated: $_translatedText");

                // ✅ DIRECT CALL (NO DELAY — more reliable)
                await saveTranslation(_text, _translatedText);

                // 🔊 Speak
                await speak(_translatedText);

              } catch (e) {
                print("❌ Translation error: $e");

                setState(() {
                  _translatedText = "⚠️ Network issue. Try again.";
                });
              }
            }
          },
        );
      } else {
        print("❌ Speech not available");
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SpeakGlobeAI"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_text, style: TextStyle(fontSize: 18)),
              ),

              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _translatedText.isEmpty
                      ? "Translation will appear here"
                      : _translatedText,
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              ),

              SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _listen,
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                label: Text(_isListening ? "Stop" : "Record Voice"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}