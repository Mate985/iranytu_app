import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database/database_helper.dart';
import '../data/models/reward_model.dart';

class RewardProvider with ChangeNotifier {
  static const String _pointsKey = 'user_current_stars';
  static const String _countsKey = 'reward_redeem_counts';

  int _totalStars = 0;
  List<RewardModel> _rewards = [];
  Map<int, int> _rewardCounts = {};
  bool _isLoading = false;

  int get totalStars => _totalStars;
  List<RewardModel> get rewards => _rewards;
  bool get isLoading => _isLoading;

  // Beváltott trófeák lekérése a Kuckóhoz
  List<RewardModel> get redeemedRewards =>
      _rewards.where((r) => r.isRedeemed).toList();

  // Adott jutalom aktuális kiváltott darabszáma (pl. x1, x2, x3)
  int getRedeemCount(int? rewardId) {
    if (rewardId == null) return 0;
    final count = _rewardCounts[rewardId] ?? 0;
    if (count == 0) {
      final isRedeemedInDb = _rewards.any(
        (r) => r.id == rewardId && r.isRedeemed,
      );
      return isRedeemedInDb ? 1 : 0;
    }
    return count;
  }

  RewardProvider() {
    loadRewardsAndStars();
  }

  // Csillagok, jutalmak és darabszámok betöltése
  Future<void> loadRewardsAndStars() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _totalStars = prefs.getInt(_pointsKey) ?? 0;

    final rawCounts = prefs.getString(_countsKey);
    _rewardCounts = {};
    if (rawCounts != null && rawCounts.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawCounts) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          final id = int.tryParse(key);
          if (id != null && value is int) {
            _rewardCounts[id] = value;
          }
        });
      } catch (_) {}
    }

    _rewards = await DatabaseHelper.instance.getAllRewards();

    // Szinkronizáció a korábban már kiváltott jutalmakkal
    bool countsChanged = false;
    for (final r in _rewards) {
      if (r.id != null) {
        if (r.isRedeemed && (_rewardCounts[r.id!] ?? 0) <= 0) {
          _rewardCounts[r.id!] = 1;
          countsChanged = true;
        } else if (!r.isRedeemed && (_rewardCounts[r.id!] ?? 0) > 0) {
          _rewardCounts.remove(r.id!);
          countsChanged = true;
        }
      }
    }
    if (countsChanged) {
      await _saveCounts(prefs);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveCounts([SharedPreferences? prefsInstance]) async {
    final prefs = prefsInstance ?? await SharedPreferences.getInstance();
    final stringKeyMap = _rewardCounts.map(
      (key, val) => MapEntry(key.toString(), val),
    );
    await prefs.setString(_countsKey, jsonEncode(stringKeyMap));
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
    _rewardCounts.remove(id);
    await _saveCounts();
    await DatabaseHelper.instance.deleteReward(id);
    await loadRewardsAndStars();
  }

  // Jutalom beváltása (többször is kiváltható, növeli a darabszámot)
  Future<bool> redeemReward(RewardModel reward) async {
    if (_totalStars < reward.pointsCost) {
      return false; // Nincs elég csillag
    }

    // Csillagok levonása
    _totalStars -= reward.pointsCost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _totalStars);

    // Beváltott státusz és számláló növelése (+1)
    if (reward.id != null) {
      final currentCount = getRedeemCount(reward.id);
      _rewardCounts[reward.id!] = currentCount + 1;
      await _saveCounts(prefs);
      await DatabaseHelper.instance.updateRewardRedeemed(reward.id!, true);
    }

    await loadRewardsAndStars();
    return true;
  }

  // Szülői jóváhagyás: 1 db jutalom teljesítve (-1 a számlálóból)
  Future<void> fulfillReward(RewardModel reward) async {
    if (reward.id == null) return;
    final id = reward.id!;
    final currentCount = getRedeemCount(id);

    if (currentCount > 1) {
      _rewardCounts[id] = currentCount - 1;
      await _saveCounts();
    } else {
      _rewardCounts.remove(id);
      await _saveCounts();
      await DatabaseHelper.instance.updateRewardRedeemed(id, false);
      await DatabaseHelper.instance.updateRewardRoomPlacement(
        id,
        false,
        0.5,
        0.5,
      );
    }

    await loadRewardsAndStars();
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
