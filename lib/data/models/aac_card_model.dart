class AacCardModel {
  final int? id;
  final String title; // Megjelenő címke (pl. "Inni kérek")
  final String
  speechText; // Felolvasandó mondat (pl. "Szomjas vagyok, inni szeretnék")
  final String
  category; // 'NEEDS' (szükséglet), 'FEELINGS' (érzés), 'ACTIVITIES' (tevékenység)
  final String imageType; // 'DEFAULT_ICON' vagy 'CUSTOM_IMAGE'
  final String imagePath; // Ikon azonosítója vagy galériás kép elérési útja
  final String? audioPath; // Saját szülői hangfelvétel elérési útja

  AacCardModel({
    this.id,
    required this.title,
    required this.speechText,
    required this.category,
    required this.imageType,
    required this.imagePath,
    this.audioPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'speech_text': speechText,
      'category': category,
      'image_type': imageType,
      'image_path': imagePath,
      'audio_path': audioPath,
    };
  }

  factory AacCardModel.fromMap(Map<String, dynamic> map) {
    return AacCardModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      speechText: map['speech_text'] as String,
      category: map['category'] as String,
      imageType: map['image_type'] as String,
      imagePath: map['image_path'] as String,
      audioPath: map['audio_path'] as String?,
    );
  }
}
