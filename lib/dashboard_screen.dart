import 'package:flutter/material.dart';
import 'profile_drawer.dart';
import 'voice_screen.dart';
import 'image_screen.dart';
import 'doc_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SpeakGlobeAI")),
      drawer: ProfileDrawer(), // FIXED: Removed 'const'
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _card(
              context,
              "Voice Assistant",
              Icons.mic,
              Colors.purple,
              const VoiceScreen(),
            ),
            _card(
              context,
              "Image Analyzer",
              Icons.camera,
              Colors.blue,
              const ImageScreen(),
            ),
            _card(
              context,
              "Doc Converter",
              Icons.file_copy,
              Colors.orange,
              const DocScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget page,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
