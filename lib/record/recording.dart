import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class AudioRecorder {
  final Record _audioRecorder = Record();
  String? _filePath;

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      _filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(path: _filePath);

      // Automatically stop the recording after 10 seconds
      Timer(Duration(seconds: 10), () async {
        await stopRecording();
      });
      print("Recording started: $_filePath");
    } else {
      print("Permission not granted");
    }
  }

  Future<void> stopRecording() async {
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
      print("Recording stopped: $_filePath");
    }
  }

  String? get filePath => _filePath;
}
