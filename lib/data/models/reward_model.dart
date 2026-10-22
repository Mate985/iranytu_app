class RewardModel {
  final int? id;
  final String title;
  final int pointsCost;
  final String imageType; // 'DEFAULT_ICON' vagy 'CUSTOM_IMAGE'
  final String imagePath;
  final bool isRedeemed;
  final bool isPlaced; // Ki van-e helyezve a szobába
  final double roomX; // Vízszintes pozíció (0.0 - 1.0)
  final double roomY; // Függőleges pozíció (0.0 - 1.0)

  RewardModel({
    this.id,
    required this.title,
    required this.pointsCost,
    required this.imageType,
    required this.imagePath,
    this.isRedeemed = false,
    this.isPlaced = false,
    this.roomX = 0.5,
    this.roomY = 0.5,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'points_cost': pointsCost,
      'image_type': imageType,
      'image_path': imagePath,
      'is_redeemed': isRedeemed ? 1 : 0,
      'is_placed': isPlaced ? 1 : 0,
      'room_x': roomX,
      'room_y': roomY,
    };
  }

  factory RewardModel.fromMap(Map<String, dynamic> map) {
    return RewardModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      pointsCost: map['points_cost'] as int,
      imageType: map['image_type'] as String,
      imagePath: map['image_path'] as String,
      isRedeemed: (map['is_redeemed'] as int? ?? 0) == 1,
      isPlaced: (map['is_placed'] as int? ?? 0) == 1,
      roomX: (map['room_x'] as num?)?.toDouble() ?? 0.5,
      roomY: (map['room_y'] as num?)?.toDouble() ?? 0.5,
    );
  }

  RewardModel copyWith({
    int? id,
    String? title,
    int? pointsCost,
    String? imageType,
    String? imagePath,
    bool? isRedeemed,
    bool? isPlaced,
    double? roomX,
    double? roomY,
  }) {
    return RewardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      pointsCost: pointsCost ?? this.pointsCost,
      imageType: imageType ?? this.imageType,
      imagePath: imagePath ?? this.imagePath,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      isPlaced: isPlaced ?? this.isPlaced,
      roomX: roomX ?? this.roomX,
      roomY: roomY ?? this.roomY,
    );
  }
}
