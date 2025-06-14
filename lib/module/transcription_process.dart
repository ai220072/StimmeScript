import 'dart:convert';
import 'package:codelens_v2/module/AES/aes_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'grammarly.dart';
import 'constant.dart';

const fixedKey = 'ThisIsA32ByteFixedKeyForAES1234';

Future<void> processAndSaveTranscription({
  required BuildContext context,
  required String filePath,
  required void Function(String message) onProgress,
  required void Function(String result) onComplete,
  required void Function(String error) onError,
  required void Function(double progress) onProgressUpdate, // NEW
}) async {
  try {
    onProgress("Uploading file...");
    onProgressUpdate(0.2);

    // simulate upload delay
    await Future.delayed(Duration(seconds: 1));

    onProgress("Processing file...");
    onProgressUpdate(0.5);

    await Future.delayed(Duration(seconds: 1));

    onProgress("Finalizing...");
    onProgressUpdate(0.8);

    await Future.delayed(Duration(seconds: 1));

    onComplete("Transcription complete!");
    onProgressUpdate(1.0);
  } catch (e) {
    onError("An error occurred: $e");
    onProgressUpdate(0.0);
  }
}



Future<String> _convertSpeechToTextWithRetry(String filePath) async {
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
      return _convertSpeechToTextWithRetry(filePath);
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Transcription failed: $e');
  }
}

Future<void> _saveTranscriptionToFirebase(BuildContext context, String correctedText) async {
  try {
    final encryptedText = AESUtil.encryptText(correctedText, fixedKey);
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transcriptions')
        .add({
      'transcription': encryptedText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Encrypted transcription saved to Firestore')),
    );
  } catch (e) {
    throw Exception('Firestore error: $e');
  }
}
