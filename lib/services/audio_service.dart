import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'tts_service.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal();

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;

  /// Futásidejű mikrofon engedély ellenőrzése és kérése
  Future<bool> checkAndRequestPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  /// Hangfelvétel indítása (Szülői egyedi felvételhez)
  Future<bool> startRecording() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        debugPrint("A felhasználó megtagadta a mikrofon engedélyt!");
        return false;
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = '${dir.path}/$fileName';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      return true;
    } catch (e) {
      debugPrint("Hiba a felvétel indításakor: $e");
      _isRecording = false;
      return false;
    }
  }

  /// Hangfelvétel leállítása
  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      return path ?? _currentRecordingPath;
    } catch (e) {
      debugPrint("Hiba a felvétel leállításakor: $e");
      _isRecording = false;
      return null;
    }
  }

  /// Telefonon tárolt egyedi szülői hangfájl lejátszása
  Future<bool> playAudio(String filePath) async {
    try {
      await stopAll();
      final file = File(filePath);
      if (file.existsSync()) {
        await _audioPlayer.play(DeviceFileSource(filePath));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Hiba a helyi hang lejátszásakor: $e");
      return false;
    }
  }

  /// Beépített Asset hang ellenőrzése és lejátszása
  Future<bool> playAsset(String assetPath) async {
    try {
      await stopAll();

      var fullAssetPath = assetPath.trim();
      while (fullAssetPath.startsWith('/')) {
        fullAssetPath = fullAssetPath.substring(1);
      }
      if (!fullAssetPath.startsWith('assets/')) {
        fullAssetPath = 'assets/$fullAssetPath';
      }

      // Valóban benne van-e a csomagolt assetek között?
      try {
        await rootBundle.load(fullAssetPath);
      } catch (notFound) {
        debugPrint("⚠️ Nem található az Asset fájl: $fullAssetPath");
        return false;
      }

      // Az audioplayers AssetSource alapértelmezetten 'assets/' elé fűz, ezért levágjuk
      final cleanPath = fullAssetPath.replaceFirst('assets/', '');

      debugPrint("Asset lejátszása -> '$cleanPath'");
      await _audioPlayer.play(AssetSource(cleanPath));
      return true;
    } catch (e, stack) {
      debugPrint("Hiba az asset hang lejátszásakor ($assetPath): $e");
      debugPrint("Hiba részletei: $stack");
      return false;
    }
  }

  /// Intelligens hanglejátszás:
  /// Azonnal leállítja a futó TTS-t és audio-t.
  /// Ha van érvényes felvett hang, NEM engedi megszólalni a Google TTS robotot!
  Future<void> speakOrPlay({required String text, String? audioPath}) async {
    debugPrint(
      "speakOrPlay hívás -> szöveg: '$text' | audioPath: '$audioPath'",
    );

    // 1. Azonnal csendesítünk minden korábbi hangot és felolvasást
    await stopAll();

    // 2. Ha meg van adva audioPath, megpróbáljuk lejátszani
    if (audioPath != null && audioPath.trim().isNotEmpty) {
      if (audioPath.contains('assets/')) {
        final success = await playAsset(audioPath);
        if (success) return;
      } else if (File(audioPath).existsSync()) {
        final success = await playAudio(audioPath);
        if (success) return;
      }
    }

    // 3. Csak akkor nyúl a robot TTS-hez, ha egyáltalán nem volt megadva audioPath
    if (audioPath == null || audioPath.trim().isEmpty) {
      debugPrint("Nincs egyedi hang megadva, tartalék TTS szólal meg: '$text'");
      await TtsService.instance.speak(text);
    } else {
      debugPrint(
        "⚠️ Az audioPath meg volt adva ($audioPath), de nem sikerült lejátszani. A TTS némítva maradt a kettős beszéd elkerülése érdekében.",
      );
    }
  }

  /// Minden hang azonnali leállítása
  Future<void> stopAll() async {
    try {
      await _audioPlayer.stop();
      await TtsService.instance.stop();
    } catch (e) {
      debugPrint("Hiba a hang leállításakor: $e");
    }
  }

  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
  }
}
