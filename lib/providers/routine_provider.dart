import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';
import '../data/models/task_model.dart';
import '../data/models/daily_schedule_model.dart';
import '../data/models/subtask_model.dart';
import '../services/notification_service.dart';
import '../services/app_settings_service.dart';

class ScheduledTaskItem {
  final DailyScheduleModel schedule;
  final TaskModel task;

  ScheduledTaskItem({required this.schedule, required this.task});
}

class RoutineProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<ScheduledTaskItem> _todayTasks = [];
  bool _isLoading = false;
  int _selectedDay = DateTime.now().weekday; // 1: Hétfő ... 7: Vasárnap

  List<ScheduledTaskItem> get todayTasks => _todayTasks;
  bool get isLoading => _isLoading;
  int get selectedDay => _selectedDay;

  void selectDay(int day) {
    _selectedDay = day;
    loadScheduleForSelectedDay(showLoading: true);
  }

  Future<void> loadScheduleForSelectedDay({bool showLoading = false}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    final schedules = await _dbHelper.getSchedulesForDay(_selectedDay);
    final allTasks = await _dbHelper.getAllTasks();

    final List<ScheduledTaskItem> items = [];
    for (final schedule in schedules) {
      final task = allTasks.firstWhere(
        (t) => t.id == schedule.taskId,
        orElse: () => TaskModel(
          id: schedule.taskId,
          title: 'Ismeretlen feladat',
          ttsText: '',
          defaultDuration: 5,
        ),
      );
      items.add(ScheduledTaskItem(schedule: schedule, task: task));
    }

    _todayTasks = items;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTodaySchedule() async {
    await loadScheduleForSelectedDay(showLoading: true);
  }

  Future<void> toggleTaskCompletion(
    int scheduleId,
    bool isCurrentlyCompleted,
  ) async {
    final newStatus = !isCurrentlyCompleted;
    await _dbHelper.updateScheduleCompletion(scheduleId, newStatus);

    if (newStatus) {
      await NotificationService.instance.cancelReminder(scheduleId);
    } else {
      final scheduleItem = _todayTasks.firstWhere(
        (item) => item.schedule.id == scheduleId,
      );
      await _scheduleNotificationForItem(scheduleItem);
    }

    await loadScheduleForSelectedDay(showLoading: false);
  }

  Future<void> removeTaskFromSchedule(int scheduleId) async {
    await NotificationService.instance.cancelReminder(scheduleId);
    await _dbHelper.deleteSchedule(scheduleId);
    await loadScheduleForSelectedDay(showLoading: false);
  }

  Future<void> updateTaskTime(int scheduleId, String newTime) async {
    await _dbHelper.updateScheduleTime(scheduleId, newTime);

    final index = _todayTasks.indexWhere(
      (item) => item.schedule.id == scheduleId,
    );
    if (index != -1) {
      final currentItem = _todayTasks[index];
      final updatedSchedule = currentItem.schedule.copyWith(
        scheduledTime: newTime,
      );
      final updatedItem = ScheduledTaskItem(
        schedule: updatedSchedule,
        task: currentItem.task,
      );
      await _scheduleNotificationForItem(updatedItem);
    }

    await loadScheduleForSelectedDay(showLoading: false);
  }

  Future<void> addNewTaskWithSchedule({
    required String title,
    required String ttsText,
    String? audioPath,
    required int duration,
    required String scheduledTime,
    required String colorCode,
    required List<String> stepDescriptions,
    List<String?>? stepAudioPaths,
    String iconPath = 'brush',
    int? targetDay,
  }) async {
    final dayToAssign = targetDay ?? _selectedDay;

    // 1. Feladat mentése
    final taskId = await _dbHelper.insertTask(
      TaskModel(
        title: title,
        ttsText: ttsText.isEmpty ? title : ttsText,
        audioPath: audioPath,
        defaultDuration: duration,
        colorCode: colorCode,
        iconPath: iconPath,
        isCustom: true,
      ),
    );

    // 2. Mikrolépések mentése (saját hangfelvételekkel együtt)
    int savedOrder = 1;
    for (int i = 0; i < stepDescriptions.length; i++) {
      final desc = stepDescriptions[i].trim();
      if (desc.isNotEmpty) {
        final stepAudio = (stepAudioPaths != null && i < stepAudioPaths.length)
            ? stepAudioPaths[i]
            : null;
        await _dbHelper.insertSubtask(
          SubtaskModel(
            taskId: taskId,
            stepOrder: savedOrder,
            description: desc,
            iconPath: iconPath,
            audioPath: stepAudio,
          ),
        );
        savedOrder++;
      }
    }

    // 3. Beosztás hozzárendelése a kiválasztott naphoz
    final nextOrder = _todayTasks.length + 1;
    final scheduleModel = DailyScheduleModel(
      taskId: taskId,
      dayOfWeek: dayToAssign,
      orderIndex: nextOrder,
      status: TaskStatus.pending,
      scheduledTime: scheduledTime,
    );
    final scheduleId = await _dbHelper.insertSchedule(scheduleModel);

    // 4. Értesítés beütemezése
    final taskModel = TaskModel(
      id: taskId,
      title: title,
      ttsText: ttsText.isEmpty ? title : ttsText,
      audioPath: audioPath,
      defaultDuration: duration,
      colorCode: colorCode,
      iconPath: iconPath,
      isCustom: true,
    );

    final item = ScheduledTaskItem(
      schedule: scheduleModel.copyWith(id: scheduleId),
      task: taskModel,
    );
    await _scheduleNotificationForItem(item);

    // 5. Lista újratöltése
    await loadScheduleForSelectedDay(showLoading: false);
  }

  Future<void> _scheduleNotificationForItem(ScheduledTaskItem item) async {
    final scheduleId = item.schedule.id;
    final timeStr = item.schedule.scheduledTime;

    if (scheduleId == null || timeStr == null || !timeStr.contains(':')) {
      return;
    }

    final notificationsEnabled =
        await AppSettingsService.areNotificationsEnabled();
    if (!notificationsEnabled) {
      await NotificationService.instance.cancelReminder(scheduleId);
      return;
    }

    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return;

    final bodyText = item.task.ttsText.trim().isNotEmpty
        ? item.task.ttsText
        : 'Itt az ideje a következő feladatnak!';

    await NotificationService.instance.scheduleTaskReminder(
      id: scheduleId,
      title: 'Feladat: ${item.task.title}',
      body: bodyText,
      hour: hour,
      minute: minute,
      dayOfWeek: item.schedule.dayOfWeek,
    );

    final advanceMinutes = await AppSettingsService.getRoutineReminderMinutes();
    if (advanceMinutes > 0) {
      await NotificationService.instance.scheduleAdvanceReminder(
        scheduleId: scheduleId,
        title: item.task.title,
        hour: hour,
        minute: minute,
        dayOfWeek: item.schedule.dayOfWeek,
        advanceMinutes: advanceMinutes,
      );
    } else {
      await NotificationService.instance.cancelReminder(scheduleId + 500000);
    }
  }

  Future<void> rescheduleAllNotifications() async {
    final notificationsEnabled =
        await AppSettingsService.areNotificationsEnabled();

    if (!notificationsEnabled) {
      await NotificationService.instance.cancelAll();
      return;
    }

    final allTasks = await _dbHelper.getAllTasks();
    for (int day = 1; day <= 7; day++) {
      final schedules = await _dbHelper.getSchedulesForDay(day);
      for (final schedule in schedules) {
        if (schedule.status != TaskStatus.completed) {
          final task = allTasks.firstWhere(
            (t) => t.id == schedule.taskId,
            orElse: () => TaskModel(
              id: schedule.taskId,
              title: 'Feladat',
              ttsText: '',
              defaultDuration: 5,
            ),
          );
          await _scheduleNotificationForItem(
            ScheduledTaskItem(schedule: schedule, task: task),
          );
        }
      }
    }
  }
}
