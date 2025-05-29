import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:codelens_v2/module/constant.dart';

Future<String> correctGrammar(String transcription) async {
  const apiKey = apiSecretKey;
  var url = Uri.https("api.openai.com", "/v1/chat/completions");

  try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": [
          {
            "role": "system",
            "content":
                "You will be provided with transcribed text. Convert it to standard English."
          },
          {"role": "user", "content": transcription}
        ],
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['choices'][0]['message']['content'] ?? transcription;
    } else {
      return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
    }
  } catch (e) {
    return 'Error correcting grammar: $e';
  }
}

List<String> chunkText(String text, int chunkSize) {
  List<String> chunks = [];
  int start = 0;
  while (start < text.length) {
    int end = (start + chunkSize < text.length) ? start + chunkSize : text.length;
    chunks.add(text.substring(start, end));
    start = end;
  }
  return chunks;
}

Future<String> correctFullTranscription(String fullText) async {
  const int chunkSize = 1000; // Adjust size if needed
  List<String> chunks = chunkText(fullText, chunkSize);

  StringBuffer correctedFullText = StringBuffer();

  for (var chunk in chunks) {
    String correctedChunk = await correctGrammar(chunk);
    correctedFullText.writeln(correctedChunk);
  }

  return correctedFullText.toString();
}
