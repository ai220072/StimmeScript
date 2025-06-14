import 'dart:io';
import 'package:codelens_v2/module/recorder/record_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class RecorderPage extends StatefulWidget {
  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _initialized = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    var micPermission = await Permission.microphone.request();
    if (micPermission.isGranted) {
      await _recorder.openRecorder();
      setState(() => _initialized = true);
    } else {
      setState(() => _initialized = false);
    }
  }

  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  Future<void> _start() async {
    if (await Permission.microphone.isGranted) {
      _filePath = await _getFilePath();
      await _recorder.startRecorder(
        toFile: _filePath,
        codec: Codec.aacMP4,
      );
      setState(() => _isRecording = true);
    } else {
      await Permission.microphone.request();
    }
  }

  Future<void> _stop() async {
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);

    if (_filePath != null) {
      final fileName = await showFileNameDialog(context);

      if (fileName != null && fileName.isNotEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        final newPath = '${dir.path}/$fileName.m4a';

        final recordedFile = File(_filePath!);

        try {
          await recordedFile.rename(newPath);
          _filePath = newPath;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved recording as "$fileName.m4a"')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving file: $e')),
          );
        }
      }
    }
  }

  Future<String?> showFileNameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Recording'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Enter file name',
              hintText: 'e.g. My recording',
            ),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.of(context).pop(text);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a file name')),
                  );
                  return;
                }
                Navigator.of(context).pop(text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: Text("Microphone permission denied."));
    }

    return Scaffold(
      body: Center(
        child: RecordButton(
          isRecording: _isRecording,
          onStart: _start,
          onStop: _stop,
        ),
      ),
    );
  }
}
