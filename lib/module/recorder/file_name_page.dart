import 'package:flutter/material.dart';

class FileNamePage extends StatefulWidget {
  const FileNamePage({super.key});

  @override
  State<FileNamePage> createState() => _FileNamePageState();
}

class _FileNamePageState extends State<FileNamePage> {
  final TextEditingController _controller = TextEditingController();

  void _submitFileName() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a file name')),
      );
      return;
    }
    Navigator.of(context).pop(text); // Return filename
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Name Your Recording'),
        backgroundColor: Colors.red,
        titleTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter file name',
                border: OutlineInputBorder(),
                hintText: 'e.g. My recording',
              ),
              autofocus: true,
              onSubmitted: (_) => _submitFileName(),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _submitFileName,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF0000), Color(0xFFB22222)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
