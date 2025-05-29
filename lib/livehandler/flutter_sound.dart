// lib/utils/flutter_sound.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';

class AudioRecorder {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      await _recorder.openRecorder();
      _isInitialized = true;
    }
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
    _isInitialized = false;
  }

  Future<void> start({
    required void Function(Uint8List buffer) onData,
    int sampleRate = 16000,
    int channels = 1,
  }) async {
    final StreamController<Uint8List> controller = StreamController<Uint8List>();
    controller.stream.listen(onData);

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      numChannels: channels,
      sampleRate: sampleRate,
      toStream: controller.sink,
    );
  }

  Future<void> stop() async {
    await _recorder.stopRecorder();
  }
}
