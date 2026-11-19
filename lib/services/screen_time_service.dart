import 'dart:async';
import 'package:flutter/material.dart';
import 'app_settings_service.dart';
import 'notification_service.dart';
import 'tts_service.dart';

class ScreenBreakMessage {
  final String title;
  final String description;
  final String speechText;

  const ScreenBreakMessage({
    required this.title,
    required this.description,
    required this.speechText,
  });
}

class ScreenTimeService {
  static final ScreenTimeService instance = ScreenTimeService._internal();
  ScreenTimeService._internal();

  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _dialogShown = false;
  int _messageIndex = 0;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final List<ScreenBreakMessage> _breakMessages = const [
    ScreenBreakMessage(
      title: 'Szünet idő! 🌳',
      description: 'Menj ki a friss levegőre!',
      speechText: 'Szünet idő! Menj ki a friss levegőre!',
    ),
    ScreenBreakMessage(
      title: 'Szempihentető! ☀️',
      description: 'Pihentesd a szemed egy kicsit!',
      speechText: 'Pihentesd a szemed!',
    ),
    ScreenBreakMessage(
      title: 'Frissítő szünet! 💧',
      description: 'Igyál egy kis vizet!',
      speechText: 'Igyál egy kis vizet!',
    ),
  ];

  void startMonitoring() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _dialogShown = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final limitMinutes = await AppSettingsService.getScreenTimeLimit();

      if (limitMinutes <= 0) {
        _elapsedSeconds = 0;
        return;
      }

      _elapsedSeconds++;
      final limitSeconds = limitMinutes * 60;

      if (_elapsedSeconds >= limitSeconds && !_dialogShown) {
        _dialogShown = true;
        _showBreakDialog();
      }
    });
  }

  void _showBreakDialog() {
    final currentMessage =
        _breakMessages[_messageIndex % _breakMessages.length];
    _messageIndex++;

    NotificationService.instance.showInstantNotification(
      title: currentMessage.title,
      body: currentMessage.speechText,
    );

    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.forest_rounded,
                      color: Color(0xFF16A34A),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentMessage.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentMessage.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      TtsService.instance.speak(currentMessage.speechText);
                    },
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Felolvasás',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      TtsService.instance.stop();
                      Navigator.of(ctx).pop();
                      _elapsedSeconds = 0;
                      _dialogShown = false;
                    },
                    child: const Text(
                      'Rendben',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _elapsedSeconds = 0;
    _dialogShown = false;
  }
}
