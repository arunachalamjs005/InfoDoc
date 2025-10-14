import 'package:flutter/services.dart';

class AudioTranscriptionService {
  static const MethodChannel _channel = MethodChannel('com.example.infodoc_app/transcription');

  /// Transcribe an audio file using native Android Speech Recognition
  static Future<String?> transcribeAudioFile(String audioFilePath) async {
    try {
      final String? result = await _channel.invokeMethod('transcribeAudio', {
        'audioPath': audioFilePath,
      });
      return result;
    } on PlatformException catch (e) {
      print('Failed to transcribe audio: ${e.message}');
      return null;
    }
  }
}
