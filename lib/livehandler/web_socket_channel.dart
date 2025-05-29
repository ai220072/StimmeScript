/*import 'package:openai_realtime_dart/openai_realtime_dart.dart';
import 'package:codelens_v2/module/constant.dart';

final client = RealtimeClient(apiKey: apiSecretKey);

Future<void> startTranscriptionSession() async {
  await client.connect();
  await client.updateSession(
    inputAudioFormat: InputAudioFormat.pcm16,
    inputAudioTranscription: InputAudioTranscriptionConfig(
      model: 'gpt-4o-transcribe',
      language: 'en',
    ),
    turnDetection: TurnDetection(
      type: TurnDetectionType.serverVad,
      threshold: 0.5,
      prefixPaddingMs: 300,
      silenceDurationMs: 500,
    ),
    inputAudioNoiseReduction: InputAudioNoiseReductionConfig(
      type: InputAudioNoiseReductionType.nearField,
    ),
  );
}*/
