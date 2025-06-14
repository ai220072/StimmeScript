import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'transcription_process.dart';

class DeterminateLinearIndicator extends StatelessWidget {
  final String label;
  final double progress;

  const DeterminateLinearIndicator({
    super.key,
    required this.label,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[300],
              color: Colors.red[700],
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }
}

class AudioTranscriptionPage extends StatefulWidget {
  final String title;
  const AudioTranscriptionPage({super.key, required this.title});

  @override
  State<AudioTranscriptionPage> createState() => _AudioTranscriptionPageState();
}

class _AudioTranscriptionPageState extends State<AudioTranscriptionPage> {
  String text = "No transcription yet";
  bool isTranscribing = false;
  double progressValue = 0.0;
  String progressLabel = "Loading...";

  final List<String> allowedExtensions = ['mp3', 'wav', 'm4a', 'flac', 'aac'];

  Future<void> pickFileAndProcess() async {
    setState(() => isTranscribing = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;

        if (file.size > 25 * 1024 * 1024) {
          setState(() {
            text = 'File too large. Maximum allowed size is 25MB.';
            isTranscribing = false;
          });
          return;
        }

        if (file.size == 0) {
          setState(() {
            text = 'Selected file is empty.';
            isTranscribing = false;
          });
          return;
        }

        final ext = file.extension?.toLowerCase();
        if (ext == null || !allowedExtensions.contains(ext)) {
          setState(() {
            text = 'Invalid audio format selected.';
            isTranscribing = false;
          });
          return;
        }

        await processAndSaveTranscription(
          filePath: file.path!,
          context: context,
          onProgress: (progressMsg) {
            setState(() {
              progressLabel = progressMsg;
              // Optional label mapping if desired
              if (progressMsg == "Transcribing...") {
                progressValue = 0.33;
              } else if (progressMsg == "Fixing grammar...") {
                progressValue = 0.66;
              } else {
                progressValue = 0.9;
              }
              text = progressMsg;
            });
          },
          onComplete: (transcription) async {
            setState(() {
              text = transcription.isEmpty
                  ? 'No speech detected in the audio.'
                  : transcription;
              progressValue = 1.0;
              progressLabel = "Done!";
            });
            await Future.delayed(const Duration(milliseconds: 500));
            setState(() {
              isTranscribing = false;
              progressValue = 0.0;
              progressLabel = "";
            });
          },
          onError: (error) {
            setState(() {
              text = 'Error: $error';
              isTranscribing = false;
              progressValue = 0.0;
              progressLabel = "Error occurred";
            });
          },
          onProgressUpdate: (double p) {
            setState(() => progressValue = p.clamp(0.0, 1.0));
          },
        );
      } else {
        setState(() {
          text = 'No file selected';
          isTranscribing = false;
        });
      }
    } catch (e) {
      setState(() {
        text = 'Error processing file: $e';
        isTranscribing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF0000), Color(0xFFB22222)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF0000), Color(0xFFB22222)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: pickFileAndProcess,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Pick Audio File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (isTranscribing)
                    Column(
                      children: [
                        Image.asset(
                          'assets/animations/Pen.gif',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 16),
                        DeterminateLinearIndicator(
                          label: progressLabel,
                          progress: progressValue,
                        ),
                      ],
                    )
                  else
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
