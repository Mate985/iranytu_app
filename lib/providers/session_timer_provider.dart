import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionTimerProvider extends ChangeNotifier {
  static const String _prefKeyTimeLimit = 'session_time_limit_minutes';

  // 0 = nincs korlát, egyébként percekben (pl. 5, 10, 15, 20, 30)
  int _timeLimitMinutes = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isTimeUp = false;

  Timer? _timer;

  int get timeLimitMinutes => _timeLimitMinutes;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isTimeUp => _isTimeUp;
  bool get hasLimit => _timeLimitMinutes > 0;

  // Formázott perc:másodperc (pl. "09:45")
  String get formattedRemainingTime {
    if (!hasLimit) return 'Korlátlan';
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  SessionTimerProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _timeLimitMinutes = prefs.getInt(_prefKeyTimeLimit) ?? 0;
    if (hasLimit) {
      _remainingSeconds = _timeLimitMinutes * 60;
      startTimer();
    }
    notifyListeners();
  }

  Future<void> setTimeLimit(int minutes) async {
    _timeLimitMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyTimeLimit, minutes);

    stopTimer();
    _isTimeUp = false;

    if (minutes > 0) {
      _remainingSeconds = minutes * 60;
      startTimer();
    } else {
      _remainingSeconds = 0;
    }
    notifyListeners();
  }

  void startTimer() {
    if (!hasLimit || _isRunning) return;

    _isRunning = true;
    _isTimeUp = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimeFinished();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
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
    _isRunning = false;
    notifyListeners();
  }

  void resetSession() {
    _isTimeUp = false;
    if (hasLimit) {
      _remainingSeconds = _timeLimitMinutes * 60;
      startTimer();
    } else {
      _remainingSeconds = 0;
      stopTimer();
    }
    notifyListeners();
  }

  void _onTimeFinished() {
    _timer?.cancel();
    _isRunning = false;
    _isTimeUp = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
