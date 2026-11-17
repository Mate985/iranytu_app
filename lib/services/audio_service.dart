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

  Future<bool> checkAndRequestPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    return result.isGranted;
  }

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

  Future<bool> playAudio(String filePath) async {
    try {
      await stopAll();
      final cleanPath = filePath.replaceFirst('file://', '').trim();
      final file = File(cleanPath);
      if (file.existsSync()) {
        await _audioPlayer.play(DeviceFileSource(cleanPath));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Hiba a helyi hang lejátszásakor: $e");
      return false;
    }
  }

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

      try {
        await rootBundle.load(fullAssetPath);
      } catch (notFound) {
        return false;
      }

      final cleanPath = fullAssetPath.replaceFirst('assets/', '');
      await _audioPlayer.play(AssetSource(cleanPath));
      return true;
    } catch (e) {
      debugPrint("Hiba az asset hang lejátszásakor ($assetPath): $e");
      return false;
    }
  }

  /// Ha van érvényes saját felvett hang vagy létező asset, CSAK azt játssza le.
  /// A Google TTS robothang kizárólag akkor szólal meg, ha nincs saját felvétel!
  Future<void> speakOrPlay({required String text, String? audioPath}) async {
    await stopAll();

    final rawPath = audioPath?.trim() ?? '';

    if (rawPath.isNotEmpty) {
      if (rawPath.contains('assets/')) {
        // Beépített útvonal: ha létezik a fájl, lejátsszuk; ha nem létezik, jöhet a TTS
        final success = await playAsset(rawPath);
        if (success) return;
      } else {
        // Szülő által rögzített saját hangfájl: lejátsszuk, és SOHA nem engedjük rá a TTS-t
        final cleanPath = rawPath.replaceFirst('file://', '');
        if (File(cleanPath).existsSync()) {
          await playAudio(cleanPath);
          return;
        }
      }
    }

    // Ha nem volt saját hangfájl (vagy a beépített asset nem létezett), a Google TTS szólal meg
    if (text.trim().isNotEmpty) {
      await TtsService.instance.speak(text);
    }
  }

  Future<void> stopAll() async {
    try {
      await TtsService.instance.stop();
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Hiba a hang leállításakor: $e");
    }
  }

  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
  }
}
