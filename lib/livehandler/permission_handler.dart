import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

Future<void> initRecorder() async {
  await Permission.microphone.request();
  await _recorder.openRecorder();
}
