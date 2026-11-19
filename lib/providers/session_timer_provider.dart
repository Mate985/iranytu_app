import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_settings_service.dart';

class SessionTimerProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const String _prefKeyTimeLimitSeconds = 'session_time_limit_seconds';
  static const String _legacyPrefKeyTimeLimitMinutes =
      'session_time_limit_minutes';
  static const String _prefKeyEndTimeMs = 'session_timer_end_time_ms';

  final FlutterLocalNotificationsPlugin _notifPlugin =
      FlutterLocalNotificationsPlugin();

  int _timeLimitSeconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isTimeUp = false;

  DateTime? _endTime;
  Timer? _timer;
  Timer? _backgroundNotifTimer;

  int get timeLimitSeconds => _timeLimitSeconds;
  int get timeLimitMinutes => _timeLimitSeconds ~/ 60;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isTimeUp => _isTimeUp;
  bool get hasLimit => _timeLimitSeconds > 0;

  String get formattedLimitLabel {
    if (_timeLimitSeconds <= 0) return 'Kikapcsolva';
    return '${_timeLimitSeconds ~/ 60} perc';
  }

  String get formattedRemainingTime {
    if (!hasLimit) return 'Korlátlan';
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  SessionTimerProvider() {
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!hasLimit || !_isRunning || _endTime == null) return;

    if (state == AppLifecycleState.resumed) {
      final diff = _endTime!.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        _onTimeFinished(sendNotification: false);
      } else {
        _remainingSeconds = diff;
        notifyListeners();
      }
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_prefKeyTimeLimitSeconds)) {
      _timeLimitSeconds = prefs.getInt(_prefKeyTimeLimitSeconds) ?? 0;
    } else {
      final legacyMinutes = prefs.getInt(_legacyPrefKeyTimeLimitMinutes) ?? 0;
      _timeLimitSeconds = legacyMinutes * 60;
    }

    if (_timeLimitSeconds > 0 && _timeLimitSeconds < 60) {
      _timeLimitSeconds = 900;
      await prefs.setInt(_prefKeyTimeLimitSeconds, 900);
      await prefs.setInt(_legacyPrefKeyTimeLimitMinutes, 15);
    }

    if (hasLimit) {
      final savedEndMs = prefs.getInt(_prefKeyEndTimeMs);
      if (savedEndMs != null) {
        final savedEnd = DateTime.fromMillisecondsSinceEpoch(savedEndMs);
        final diff = savedEnd.difference(DateTime.now()).inSeconds;
        if (diff > 0 && diff <= _timeLimitSeconds) {
          _remainingSeconds = diff;
          _endTime = savedEnd;
        } else {
          _remainingSeconds = _timeLimitSeconds;
          _endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
        }
      } else {
        _remainingSeconds = _timeLimitSeconds;
        _endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
      }
      startTimer();
    }
    notifyListeners();
  }

  Future<void> setTimeLimitSeconds(int seconds) async {
    final validSeconds = (seconds > 0 && seconds < 60) ? 900 : seconds;
    _timeLimitSeconds = validSeconds;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyTimeLimitSeconds, validSeconds);
    await prefs.setInt(_legacyPrefKeyTimeLimitMinutes, validSeconds ~/ 60);

    stopTimer();
    _isTimeUp = false;

    if (validSeconds > 0) {
      _remainingSeconds = validSeconds;
      _endTime = DateTime.now().add(Duration(seconds: validSeconds));
      await prefs.setInt(_prefKeyEndTimeMs, _endTime!.millisecondsSinceEpoch);
      startTimer();
    } else {
      _remainingSeconds = 0;
      _endTime = null;
      await prefs.remove(_prefKeyEndTimeMs);
    }
    notifyListeners();
  }

  Future<void> setTimeLimit(int minutes) async {
    await setTimeLimitSeconds(minutes * 60);
  }

  void startTimer() {
    if (!hasLimit || _isRunning) return;

    _isRunning = true;
    _isTimeUp = false;
    _endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
    _saveEndTime();

    _timer?.cancel();
    _backgroundNotifTimer?.cancel();

    _backgroundNotifTimer = Timer(Duration(seconds: _remainingSeconds), () {
      _showScreenTimeUpNotification();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_endTime != null) {
        final diff = _endTime!.difference(DateTime.now()).inSeconds;
        if (diff > 0) {
          _remainingSeconds = diff;
          notifyListeners();
        } else {
          _onTimeFinished(sendNotification: true);
        }
      } else if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimeFinished(sendNotification: true);
      }
    });
  }

  Future<void> _saveEndTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (_endTime != null) {
      await prefs.setInt(_prefKeyEndTimeMs, _endTime!.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_prefKeyEndTimeMs);
    }
  }

  Future<void> _showScreenTimeUpNotification() async {
    try {
      final enabled = await AppSettingsService.areNotificationsEnabled();
      if (!enabled) return;

      const androidDetails = AndroidNotificationDetails(
        'screen_time_limit_channel',
        'Képernyőidő figyelmeztetés',
        channelDescription:
            'Értesítés, ha lejárt a beállított játék- és képernyőidő',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      const details = NotificationDetails(android: androidDetails);

      await _notifPlugin.show(
        id: 9901,
        title: 'Lejárt a játékidő! ⏳',
        body: 'Pihentesd a szemed! Szólj a szülőnek.',
        notificationDetails: details,
      );
    } catch (_) {}
  }

  void pauseTimer() {
    _timer?.cancel();
    _backgroundNotifTimer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resumeTimer() {
    if (hasLimit && !_isTimeUp && !_isRunning) {
      startTimer();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _backgroundNotifTimer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetSession() {
    _isTimeUp = false;
    if (hasLimit) {
      _remainingSeconds = _timeLimitSeconds;
      _endTime = DateTime.now().add(Duration(seconds: _timeLimitSeconds));
      _saveEndTime();
      startTimer();
    } else {
      _remainingSeconds = 0;
      _endTime = null;
      _saveEndTime();
      stopTimer();
    }
    notifyListeners();
  }

  void _onTimeFinished({bool sendNotification = true}) {
    _timer?.cancel();
    _backgroundNotifTimer?.cancel();
    _remainingSeconds = 0;
    _isRunning = false;
    _isTimeUp = true;
    if (sendNotification) {
      _showScreenTimeUpNotification();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _backgroundNotifTimer?.cancel();
    super.dispose();
  }
}
