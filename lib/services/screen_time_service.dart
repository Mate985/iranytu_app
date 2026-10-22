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

  // A 3 váltakozó, kedves üzenet
  final List<ScreenBreakMessage> _breakMessages = const [
    ScreenBreakMessage(
      title: 'Irány a szabad levegő! 🌳⚽',
      description:
          'Már sokat ügyeskedtél ma a képernyő előtt. Ideje szaladgálni vagy labdázni egy jót a friss levegőn!',
      speechText:
          'Ideje egy kis szünetnek! Menj ki a szabadba szaladgálni vagy játszani egyet!',
    ),
    ScreenBreakMessage(
      title: 'Pihentesd a szemedet! ☀️🍃',
      description:
          'A szemeidnek is kell egy kis pihenő! Szívj egy kis friss levegőt az udvaron, a teraszon vagy az ablaknál!',
      speechText:
          'A szemeidnek is kell egy kis pihenő! Szívj egy kis friss levegőt az udvaron vagy a teraszon!',
    ),
    ScreenBreakMessage(
      title: 'Frissítő szünet a szabadban! 🦋🌼',
      description:
          'Igyál egy finom pohár vizet vagy gyümölcslevet, és nézd meg, mi újság kint a természetben!',
      speechText:
          'Készíts magadnak egy finom innivalót, és nézd meg, mi újság kint a szabadban!',
    ),
  ];

  /// Számláló elindítása
  void startMonitoring() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _dialogShown = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final limitMinutes = await AppSettingsService.getScreenTimeLimit();

      // Ha a szülő kikapcsolta (0), leállítjuk a számlálást
      if (limitMinutes <= 0) {
        _elapsedSeconds = 0;
        return;
      }

      _elapsedSeconds++;
      final limitSeconds = limitMinutes * 60;

      // Amikor eléri a limitet és még nem mutattuk a figyelmeztetést
      if (_elapsedSeconds >= limitSeconds && !_dialogShown) {
        _dialogShown = true;
        _showBreakDialog();
      }
    });
  }

  /// Pihenő felugró ablak és rendszerértesítés megjelenítése
  void _showBreakDialog() {
    final currentMessage =
        _breakMessages[_messageIndex % _breakMessages.length];
    _messageIndex++;

    // 1. Rendszerértesítés küldése az értesítési sávba
    NotificationService.instance.showInstantNotification(
      title: currentMessage.title,
      body: currentMessage.speechText,
    );

    // 2. Felugró ablak megjelenítése az appban
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
                  // Kedves illusztráció ikon
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
                  const SizedBox(height: 12),
                  Text(
                    currentMessage.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mesehang felolvasó gomb
                  ElevatedButton.icon(
                    onPressed: () {
                      TtsService.instance.speak(currentMessage.speechText);
                    },
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Felolvasás mesés hangon ✨',
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
                  const SizedBox(height: 12),

                  // Bezárás és időzítő újraindítása
                  TextButton(
                    onPressed: () {
                      TtsService.instance.stop();
                      Navigator.of(ctx).pop();
                      // Újraindítjuk a ciklust a következő figyelmeztetésig
                      _elapsedSeconds = 0;
                      _dialogShown = false;
                    },
                    child: const Text(
                      'Rendben, leteszem! 🌸',
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
