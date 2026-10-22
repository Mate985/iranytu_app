import 'dart:convert';

class CustomTaskModel {
  final String id;
  final String title;
  final String category; // 'Kép és Szó', 'Rutin Sorrend', 'Beszélő Számtábla'
  final String? imagePath;
  final String? audioPath;

  CustomTaskModel({
    required this.id,
    required this.title,
    required this.category,
    this.imagePath,
    this.audioPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'imagePath': imagePath,
      'audioPath': audioPath,
    };
  }

  factory CustomTaskModel.fromMap(Map<String, dynamic> map) {
    return CustomTaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'Kép és Szó',
      imagePath: map['imagePath'],
      audioPath: map['audioPath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomTaskModel.fromJson(String source) =>
      CustomTaskModel.fromMap(json.decode(source));
}
