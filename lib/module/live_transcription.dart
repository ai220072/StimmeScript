/*import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'constant.dart';

class LiveTranscriptionPage extends StatefulWidget {
  const LiveTranscriptionPage({super.key});

  @override
  State<LiveTranscriptionPage> createState() => _LiveTranscriptionPageState();
}

class _LiveTranscriptionPageState extends State<LiveTranscriptionPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  WebSocketChannel? _channel;
  String _transcription = '';
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 200));
  }

  void _startStreaming() async {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://api.openai.com/v1/realtime?intent=transcription'),
    );

    _channel!.sink.add(jsonEncode({
      "type": "transcription_session.update",
      "input_audio_format": "pcm16",
      "input_audio_transcription": {
        "model": "gpt-4o-transcribe",
        "prompt": "",
        "language": "en"
      },
      "turn_detection": {
        "type": "server_vad",
        "threshold": 0.5,
        "prefix_padding_ms": 300,
        "silence_duration_ms": 500
      },
      "input_audio_noise_reduction": {"type": "near_field"},
      "include": ["item.input_audio_transcription.logprobs"]
    }));

    _channel!.stream.listen((event) {
      final data = json.decode(event);
      if (data['type'] == 'transcription') {
        setState(() {
          _transcription = data['text'] ?? _transcription;
        });
      }
    });

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      sampleRate: 16000,
      numChannels: 1,
      audioStream: (buffer) {
        final base64Audio = base64Encode(buffer);
        _channel!.sink.add(jsonEncode({
          "type": "input_audio_buffer.append",
          "audio": base64Audio,
        }));
      },
    );

    setState(() => _isRecording = true);
  }

  Future<void> _stopStreaming() async {
    await _recorder.stopRecorder();
    _channel?.sink.close();
    setState(() => _isRecording = false);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Transcription'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.mic, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(
              _transcription,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stop' : 'Start'),
              onPressed: _isRecording ? _stopStreaming : _startStreaming,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
