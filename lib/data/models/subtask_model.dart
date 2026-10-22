class SubtaskModel {
  final int? id;
  final int taskId;
  final int stepOrder;
  final String description;
  final String? iconPath;
  final String? audioPath;

  const SubtaskModel({
    this.id,
    required this.taskId,
    required this.stepOrder,
    required this.description,
    this.iconPath,
    this.audioPath,
  });

  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      stepOrder: map['step_order'] as int,
      description: map['description'] as String,
      iconPath: map['icon_path'] as String?,
      audioPath: map['audio_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'step_order': stepOrder,
      'description': description,
      'icon_path': iconPath,
      'audio_path': audioPath,
    };
  }
}
