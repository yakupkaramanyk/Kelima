import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    try {
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _initialized = true;
    } catch (e) {
      debugPrint('TTS Init error: $e');
    }
  }

  Future<void> speak(String text, String languageCode) async {
    if (text.isEmpty) return;
    try {
      await _init();
      await _tts.setLanguage(languageCode);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS Speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS Stop error: $e');
    }
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) => TtsService());

