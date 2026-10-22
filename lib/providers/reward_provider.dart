import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database/database_helper.dart';
import '../data/models/reward_model.dart';

class RewardProvider with ChangeNotifier {
  static const String _pointsKey = 'user_current_stars';

  int _totalStars = 0;
  List<RewardModel> _rewards = [];
  bool _isLoading = false;

  int get totalStars => _totalStars;
  List<RewardModel> get rewards => _rewards;
  bool get isLoading => _isLoading;

  // Beváltott trófeák lekérése a Kuckóhoz
  List<RewardModel> get redeemedRewards =>
      _rewards.where((r) => r.isRedeemed).toList();

  RewardProvider() {
    loadRewardsAndStars();
  }

  // Csillagok és jutalmak betöltése
  Future<void> loadRewardsAndStars() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _totalStars = prefs.getInt(_pointsKey) ?? 0;

    _rewards = await DatabaseHelper.instance.getAllRewards();
    _isLoading = false;
    notifyListeners();
  }

  // Csillagok hozzáadása (pl. feladat bepipálásakor)
  Future<void> addStars(int count) async {
    _totalStars += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _totalStars);
    notifyListeners();
  }

  // Csillagok levonása (ha mégis visszavonják a feladat pipát)
  Future<void> removeStars(int count) async {
    _totalStars = (_totalStars - count).clamp(0, 99999);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _totalStars);
    notifyListeners();
  }

  // Új jutalom mentése (alapértelmezett ikon vagy galériás saját fotó)
  Future<void> addReward({
    required String title,
    required int pointsCost,
    required String imageType,
    required String imagePath,
  }) async {
    final reward = RewardModel(
      title: title,
      pointsCost: pointsCost,
      imageType: imageType,
      imagePath: imagePath,
    );
    await DatabaseHelper.instance.insertReward(reward);
    await loadRewardsAndStars();
  }

  // Jutalom törlése
  Future<void> deleteReward(int id) async {
    await DatabaseHelper.instance.deleteReward(id);
    await loadRewardsAndStars();
  }

  // Jutalom beváltása (ha van elég csillag)
  Future<bool> redeemReward(RewardModel reward) async {
    if (_totalStars < reward.pointsCost) {
      return false; // Nincs elég csillag
    }

    // Csillagok levonása
    _totalStars -= reward.pointsCost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _totalStars);

    // Beváltott státusz frissítése
    if (reward.id != null) {
      await DatabaseHelper.instance.updateRewardRedeemed(reward.id!, true);
    }

    await loadRewardsAndStars();
    return true;
  }

  // Trófea helyzetének mentése a Kuckóban
  Future<void> updateRewardPosition(
    int id,
    bool isPlaced,
    double x,
    double y,
  ) async {
    await DatabaseHelper.instance.updateRewardRoomPlacement(id, isPlaced, x, y);
    await loadRewardsAndStars();
  }
}
