class DailyScheduleModel {
  final int? id;
  final int taskId;
  final int dayOfWeek; // 1: Hétfő ... 7: Vasárnap
  final int orderIndex;
  final String status; // 'PENDING', 'COMPLETED'
  final String? scheduledTime; // pl. "08:00"

  DailyScheduleModel({
    this.id,
    required this.taskId,
    required this.dayOfWeek,
    required this.orderIndex,
    this.status = 'PENDING',
    this.scheduledTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'day_of_week': dayOfWeek,
      'order_index': orderIndex,
      'status': status,
      'scheduled_time': scheduledTime,
    };
  }

  factory DailyScheduleModel.fromMap(Map<String, dynamic> map) {
    return DailyScheduleModel(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      dayOfWeek: map['day_of_week'] as int,
      orderIndex: map['order_index'] as int,
      status: (map['status'] as String?) ?? 'PENDING',
      scheduledTime: map['scheduled_time'] as String?,
    );
  }

  DailyScheduleModel copyWith({
    int? id,
    int? taskId,
    int? dayOfWeek,
    int? orderIndex,
    String? status,
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
