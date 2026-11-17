import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'app_settings_service.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TtsService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('hu-HU');
      await _flutterTts.awaitSpeakCompletion(false);
      await configureVoice();
      _isInitialized = true;
    } catch (e) {
      debugPrint("TTS init hiba: $e");
    }
  }

  Future<void> configureVoice() async {
    final style = await AppSettingsService.getTtsVoiceStyle();

    try {
      await _flutterTts.setLanguage('hu-HU');
      if (style == 'fairy') {
        await _flutterTts.setSpeechRate(0.45);
        await _flutterTts.setPitch(1.18);
      } else if (style == 'calm') {
        await _flutterTts.setSpeechRate(0.42);
        await _flutterTts.setPitch(0.95);
      } else {
        await _flutterTts.setSpeechRate(0.48);
        await _flutterTts.setPitch(1.0);
      }
      await _flutterTts.setVolume(1.0);
    } catch (e) {
      debugPrint("TTS hangprofil beállítási hiba: $e");
    }
  }

  Future<void> speak(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    try {
      if (!_isInitialized) {
        await _initTts();
      }
      await _flutterTts.stop();
      await _flutterTts.setLanguage('hu-HU');
      await _flutterTts.setVolume(1.0);
      debugPrint("🔊 Google TTS felolvasás indul: '$cleanText'");
      await _flutterTts.speak(cleanText);
    } catch (e) {
      debugPrint("TTS speak hiba: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint("TTS stop hiba: $e");
    }
  }
}
