import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isTimeZoneInitialized = false;

  NotificationService._init();

  void _ensureTimeZoneInitialized() {
    if (_isTimeZoneInitialized) return;
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Budapest'));
      _isTimeZoneInitialized = true;
    } catch (_) {
      // Ha már inicializálva volt
      _isTimeZoneInitialized = true;
    }
  }

  Future<void> init() async {
    _ensureTimeZoneInitialized();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // Értesítési engedély (Android 13+)
      await androidImplementation.requestNotificationsPermission();
      // Pontos ébresztés/riasztás engedély (Android 12+)
      await androidImplementation.requestExactAlarmsPermission();

      // Értesítési csatorna létrehozása
      const androidChannel = AndroidNotificationChannel(
        'schedule_reminders',
        'Napirendi Értesítések',
        description: 'Emlékeztetők a napi feladatok elvégzésére',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      await androidImplementation.createNotificationChannel(androidChannel);
    }
  }

  // Azonnali tesztértesítés
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'schedule_reminders',
      'Napirendi Értesítések',
      channelDescription: 'Emlékeztetők a napi feladatok elvégzésére',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(sound: 'default'),
    );

    await _notificationsPlugin.show(
      id: 99999,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  // Időzített feladat-emlékeztető a pontos időpontra
  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int dayOfWeek, // 1: Hétfő ... 7: Vasárnap
  }) async {
    _ensureTimeZoneInitialized();
    final scheduledDate = _nextInstanceOfDayAndTime(dayOfWeek, hour, minute);

    const androidDetails = AndroidNotificationDetails(
      'schedule_reminders',
      'Napirendi Értesítések',
      channelDescription: 'Emlékeztetők a napi feladatok elvégzésére',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(sound: 'default'),
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Közelgő feladat előrejelzése (pl. 5, 15 vagy 30 perccel előtte)
  Future<void> scheduleAdvanceReminder({
    required int scheduleId,
    required String title,
    required int hour,
    required int minute,
    required int dayOfWeek,
    required int advanceMinutes,
  }) async {
    if (advanceMinutes <= 0) return;

    var targetHour = hour;
    var targetMinute = minute - advanceMinutes;
    var targetDay = dayOfWeek;

    if (targetMinute < 0) {
      targetMinute += 60;
      targetHour -= 1;
      if (targetHour < 0) {
        targetHour += 24;
        targetDay = targetDay == 1 ? 7 : targetDay - 1;
      }
    }

    final advanceId = scheduleId + 500000;
    await scheduleTaskReminder(
      id: advanceId,
      title: 'Hamarosan: $title',
      body: 'A feladat $advanceMinutes perc múlva kezdődik!',
      hour: targetHour,
      minute: targetMinute,
      dayOfWeek: targetDay,
    );
  }

  // Értesítés visszavonása
  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id: id);
    await _notificationsPlugin.cancel(id: id + 500000);
  }

  // Összes időzített értesítés törlése
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  // Következő esedékes időpont meghatározása (biztonságos inicializálással)
  tz.TZDateTime _nextInstanceOfDayAndTime(int dayOfWeek, int hour, int minute) {
    _ensureTimeZoneInitialized();

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
