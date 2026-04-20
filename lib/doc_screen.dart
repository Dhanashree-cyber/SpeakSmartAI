import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'profile_drawer.dart';

class DocScreen extends StatefulWidget {
  const DocScreen({super.key});
  @override
  State<DocScreen> createState() => _DocScreenState();
}

class _DocScreenState extends State<DocScreen> {
  String _fileName = "No file selected";

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'txt'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document Converter")),
      drawer: ProfileDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              "Selected File: $_fileName",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("Choose Document"),
            ),
          ],
        ),
      ),
    );
  }
}
