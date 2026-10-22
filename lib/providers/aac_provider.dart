import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';
import '../data/models/aac_card_model.dart';
import '../services/audio_service.dart';

class AacProvider with ChangeNotifier {
  List<AacCardModel> _cards = [];
  bool _isLoading = false;
  AacCardModel? _selectedCard;

  List<AacCardModel> get cards => _cards;
  bool get isLoading => _isLoading;
  AacCardModel? get selectedCard => _selectedCard;

  // Kategóriánkénti szűrés
  List<AacCardModel> getCardsByCategory(String category) {
    return _cards.where((c) => c.category == category).toList();
  }

  AacProvider() {
    loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    _cards = await DatabaseHelper.instance.getAllAacCards();
    _isLoading = false;
    notifyListeners();
  }

  // Kártya kiválasztása és lejátszása (saját hangfelvétel vagy TTS)
  Future<void> selectAndSpeakCard(AacCardModel card) async {
    _selectedCard = card;
    notifyListeners();

    await AudioService.instance.speakOrPlay(
      text: card.speechText,
      audioPath: card.audioPath,
    );
  }

  void clearSelection() {
    _selectedCard = null;
    notifyListeners();
  }

  Future<void> addCard(AacCardModel card) async {
    await DatabaseHelper.instance.insertAacCard(card);
    await loadCards();
  }

  Future<void> deleteCard(int id) async {
    await DatabaseHelper.instance.deleteAacCard(id);
    if (_selectedCard?.id == id) {
      _selectedCard = null;
    }
    await loadCards();
  }
}
