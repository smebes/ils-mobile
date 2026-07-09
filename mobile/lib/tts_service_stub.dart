import 'package:flutter_tts/flutter_tts.dart';

/// Android/iOS — flutter_tts ile Almanca kelime okuma.
class TtsService {
  static final FlutterTts _tts = FlutterTts()
    ..setLanguage('de-DE')
    ..setSpeechRate(0.4)
    ..setVolume(1.0);

  static void speak(String text) {
    _tts.speak(text);
  }
}
