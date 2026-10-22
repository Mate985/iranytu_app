import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'app_settings_service.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  final FlutterTts _flutterTts = FlutterTts();

  TtsService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('hu-HU');
    await configureVoice();
  }

  /// Hangszín és tempó beállítása a szülői preferenciák alapján
  Future<void> configureVoice() async {
    final style = await AppSettingsService.getTtsVoiceStyle();

    // Hangkeresés a készüléken
    try {
      final List<dynamic>? voices = await _flutterTts.getVoices;
      if (voices != null) {
        for (var v in voices) {
          final name = v['name'].toString().toLowerCase();
          final locale = v['locale'].toString();

          if (locale.contains('hu')) {
            if (style == 'female' &&
                (name.contains('female') || name.contains('huf'))) {
              await _flutterTts.setVoice({"name": v["name"], "locale": locale});
              break;
            } else if (style == 'calm' &&
                (name.contains('male') || name.contains('hum'))) {
              await _flutterTts.setVoice({"name": v["name"], "locale": locale});
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("TTS hangprofil betöltési hiba: $e");
    }

    // Paraméterek finomhangolása
    if (style == 'fairy') {
      // Barátságos mesehang: enyhén magasabb pitch, nyugodt tempó
      await _flutterTts.setSpeechRate(0.42);
      await _flutterTts.setPitch(1.22);
    } else if (style == 'calm') {
      await _flutterTts.setSpeechRate(0.40);
      await _flutterTts.setPitch(0.95);
    } else {
      await _flutterTts.setSpeechRate(0.44);
      await _flutterTts.setPitch(1.05);
    }

    await _flutterTts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    await _flutterTts.stop();
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
