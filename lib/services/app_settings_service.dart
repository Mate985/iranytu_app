import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
  static const String _keyScreenTimeLimit = 'screen_time_limit_minutes';
  static const String _keyRoutineReminderMinutes = 'routine_reminder_minutes';
  static const String _keyTtsVoiceStyle = 'tts_voice_style';

  // Új kulcsok az értesítésekhez és felugró ablakokhoz
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyTaskPopupAlertEnabled = 'task_popup_alert_enabled';
  static const String _keyAlertSoundEnabled = 'alert_sound_enabled';

  // Képernyőidő lekérdezése (alapértelmezett: 60 perc)
  static Future<int> getScreenTimeLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyScreenTimeLimit) ?? 60;
  }

  static Future<void> setScreenTimeLimit(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScreenTimeLimit, minutes);
  }

  // Rutin előjelzési idő lekérdezése (alapértelmezett: 30 perc)
  static Future<int> getRoutineReminderMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyRoutineReminderMinutes) ?? 30;
  }

  static Future<void> setRoutineReminderMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRoutineReminderMinutes, minutes);
  }

  // TTS Hangstílus lekérdezése (alapértelmezett: 'fairy' - lágy mesehang)
  // Lehetséges értékek: 'fairy' (mesehang), 'female' (kedves női), 'calm' (nyugodt felnőtt)
  static Future<String> getTtsVoiceStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTtsVoiceStyle) ?? 'fairy';
  }

  static Future<void> setTtsVoiceStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTtsVoiceStyle, style);
  }

  // --- Értesítési beállítások ---

  // 1. Rendszerszintű értesítések engedélyezése (alapértelmezett: true)
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  // 2. Alkalmazáson belüli felugró ablak engedélyezése (alapértelmezett: true)
  static Future<bool> isTaskPopupAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTaskPopupAlertEnabled) ?? true;
  }

  static Future<void> setTaskPopupAlertEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTaskPopupAlertEnabled, enabled);
  }

  // 3. Hangjelzés / automatikus felolvasás engedélyezése (alapértelmezett: true)
  static Future<bool> isAlertSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAlertSoundEnabled) ?? true;
  }

  static Future<void> setAlertSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlertSoundEnabled, enabled);
  }
}
