class TaskModel {
  final int? id;
  final String title;
  final String? iconPath;
  final String ttsText;
  final String? audioPath; // Szülői felvett hang útvonala
  final int defaultDuration;
  final int rewardPoints;
  final String colorCode;
  final bool isCustom;

  TaskModel({
    this.id,
    required this.title,
    this.iconPath = 'brush',
    required this.ttsText,
    this.audioPath,
    this.defaultDuration = 0,
    this.rewardPoints = 1,
    this.colorCode = '#E2E8F0',
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'icon_path': iconPath,
      'tts_text': ttsText,
      'audio_path': audioPath,
      'default_duration': defaultDuration,
      'reward_points': rewardPoints,
      'color_code': colorCode,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      iconPath: map['icon_path'] as String?,
      ttsText: map['tts_text'] as String,
      audioPath: map['audio_path'] as String?,
      defaultDuration: map['default_duration'] as int? ?? 0,
      rewardPoints: map['reward_points'] as int? ?? 1,
      colorCode: map['color_code'] as String? ?? '#E2E8F0',
      isCustom: (map['is_custom'] as int? ?? 0) == 1,
    );
  }
}
