enum TaskStatus {
  pending,
  completed;

  /// Biztonságos parser: kisbetűsíti és levágja a szóközöket,
  /// így kezeli a korábbi 'PENDING', 'pending' vagy akár null értékeket is.
  static TaskStatus fromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'completed':
        return TaskStatus.completed;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }

  /// Adatbázisba íráshoz szöveges reprezentáció (kisbetűs konzisztencia)
  String toDbValue() => name;
}

class DailyScheduleModel {
  final int? id;
  final int taskId;
  final int dayOfWeek; // 1: Hétfő ... 7: Vasárnap
  final int orderIndex;
  final TaskStatus status; // String helyett TaskStatus típus!
  final String? scheduledTime; // pl. "08:00"

  DailyScheduleModel({
    this.id,
    required this.taskId,
    required this.dayOfWeek,
    required this.orderIndex,
    this.status = TaskStatus.pending,
    this.scheduledTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'day_of_week': dayOfWeek,
      'order_index': orderIndex,
      'status': status.toDbValue(), // 'pending' vagy 'completed' kerül a DB-be
      'scheduled_time': scheduledTime,
    };
  }

  factory DailyScheduleModel.fromMap(Map<String, dynamic> map) {
    return DailyScheduleModel(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      dayOfWeek: map['day_of_week'] as int,
      orderIndex: map['order_index'] as int,
      status: TaskStatus.fromString(map['status'] as String?),
      scheduledTime: map['scheduled_time'] as String?,
    );
  }

  DailyScheduleModel copyWith({
    int? id,
    int? taskId,
    int? dayOfWeek,
    int? orderIndex,
    TaskStatus? status,
    String? scheduledTime,
  }) {
    return DailyScheduleModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      orderIndex: orderIndex ?? this.orderIndex,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }
}
