import 'dart:convert';
import 'package:codelens_v2/module/AES/aes_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constant.dart';
import 'grammarly.dart';

const fixedKey = 'ThisIsA32ByteFixedKeyForAES1234';

final storage = FlutterSecureStorage();

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({super.key, required this.title});
  final String title;

  @override
  State<SpeechToTextPage> createState() => SpeechToTextPageState();
}

class SpeechToTextPageState extends State<SpeechToTextPage> {
  String text = "No transcription yet";
  bool isTranscribing = false;
  final List<String> allowedExtensions = ['mp3', 'wav', 'm4a', 'flac', 'aac'];

  Future<String> convertSpeechToTextWithRetry(String filePath) async {
    const apiKey = apiSecretKey;
    var url = Uri.https("api.openai.com", "v1/audio/transcriptions");

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({"Authorization": "Bearer $apiKey"});
      request.fields["model"] = 'whisper-1';
      request.fields["language"] = "en";
      request.fields["response_format"] = "verbose_json";
      request.fields["timestamp_granularities"] = "word";
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        var newResponse = await http.Response.fromStream(response);
        final responseData = json.decode(newResponse.body);
        return responseData['text'] ?? 'No transcription available';
      } else if (response.statusCode == 429) {
        String retryAfter = response.headers['retry-after'] ?? '1';
        int retrySeconds = int.parse(retryAfter);
        await Future.delayed(Duration(seconds: retrySeconds));
        return convertSpeechToTextWithRetry(filePath);
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> pickFile() async {
    try {
      setState(() => isTranscribing = true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        String rawTranscription = await convertSpeechToTextWithRetry(result.files.single.path!);

        String correctedText = await correctGrammar(rawTranscription);
        await saveTranscriptionToFirebase(correctedText);

        if (mounted) {
          setState(() {
            text = correctedText;
            isTranscribing = false;
          });
        }
      } else {
        setState(() {
          text = 'No file selected';
          isTranscribing = false;
        });
      }
    } catch (e) {
      setState(() {
        text = 'Error picking file: $e';
        isTranscribing = false;
      });
    }
  }  

  Future<void> saveTranscriptionToFirebase(String correctedText) async {
    try {
      
      final encryptedText = AESUtil.encryptText(correctedText, fixedKey);

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transcriptions')
          .add({
        'transcription': encryptedText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Encrypted transcription saved to Firestore')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving transcription to Firestore: $e')),
        );
      }
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Speech to Text'),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.mic, size: 80, color: Colors.redAccent),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFB22222)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: pickFile,
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
                const SizedBox(height: 20),
                isTranscribing
                    ? const CircularProgressIndicator()
                    : Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFB22222)],
                    ),
                    borderRadius: BorderRadius.circular(8),
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