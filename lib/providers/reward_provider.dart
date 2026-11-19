import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database/database_helper.dart';
import '../data/models/reward_model.dart';

class RewardProvider with ChangeNotifier {
  static const String _pointsKey = 'user_current_stars';
  static const String _countsKey = 'reward_redeem_counts';
  static const String _stackModeKey = 'my_room_stack_rewards_mode';
  static const String _instancePositionsKey = 'my_room_instance_positions_v1';

  int _totalStars = 0;
  List<RewardModel> _rewards = [];
  Map<int, int> _rewardCounts = {};
  bool _stackRewardsInRoom = true;
  // Kulcs: "${rewardId}_$copyIndex", érték: {'placed': bool, 'x': double, 'y': double}
  Map<String, Map<String, dynamic>> _instancePositions = {};
  bool _isLoading = false;

  int get totalStars => _totalStars;
  List<RewardModel> get rewards => _rewards;
  bool get isLoading => _isLoading;
  bool get stackRewardsInRoom => _stackRewardsInRoom;

  List<RewardModel> get redeemedRewards =>
      _rewards.where((r) => r.isRedeemed).toList();

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

  Future<void> toggleStackRewardsInRoom([bool? value]) async {
    _stackRewardsInRoom = value ?? !_stackRewardsInRoom;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_stackModeKey, _stackRewardsInRoom);
    notifyListeners();
  }

  bool isInstancePlaced(int rewardId, int copyIndex, RewardModel fallback) {
    final key = '${rewardId}_$copyIndex';
    if (_instancePositions.containsKey(key)) {
      return (_instancePositions[key]!['placed'] as bool?) ?? false;
    }
    if (copyIndex == 0) return fallback.isPlaced;
    return false;
  }

  Offset getInstancePosition(
    int rewardId,
    int copyIndex,
    RewardModel fallback,
  ) {
    final key = '${rewardId}_$copyIndex';
    if (_instancePositions.containsKey(key)) {
      final x = (_instancePositions[key]!['x'] as num?)?.toDouble() ?? 0.45;
      final y = (_instancePositions[key]!['y'] as num?)?.toDouble() ?? 0.18;
      return Offset(x, y);
    }
    if (copyIndex == 0) {
      return Offset(fallback.roomX, fallback.roomY);
    }
    return Offset((0.25 + (copyIndex * 0.14)) % 0.85, 0.18);
  }

  Future<void> updateInstancePosition(
    int rewardId,
    int copyIndex,
    bool isPlaced,
    double x,
    double y,
  ) async {
    final key = '${rewardId}_$copyIndex';
    _instancePositions[key] = {'placed': isPlaced, 'x': x, 'y': y};
    await _saveInstancePositions();

    if (copyIndex == 0) {
      await DatabaseHelper.instance.updateRewardRoomPlacement(
        rewardId,
        isPlaced,
        x,
        y,
      );
    }
    await loadRewardsAndStars();
  }

  Future<void> _saveInstancePositions([
    SharedPreferences? prefsInstance,
  ]) async {
    final prefs = prefsInstance ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _instancePositionsKey,
      jsonEncode(_instancePositions),
    );
  }

  Future<void> loadRewardsAndStars() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _totalStars = prefs.getInt(_pointsKey) ?? 0;
    _stackRewardsInRoom = prefs.getBool(_stackModeKey) ?? true;

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

    final rawPositions = prefs.getString(_instancePositionsKey);
    _instancePositions = {};
    if (rawPositions != null && rawPositions.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPositions) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            _instancePositions[key] = value;
          }
        });
      } catch (_) {}
    }

    _rewards = await DatabaseHelper.instance.getAllRewards();

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

  Future<void> addStars(int count) async {
    _totalStars += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _totalStars);
    notifyListeners();
  }

  Future<void> removeStars(int count) async {
    _totalStars = (_totalStars - count).clamp(0, 99999);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _totalStars);
    notifyListeners();
  }

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

  Future<void> deleteReward(int id) async {
    _rewardCounts.remove(id);
    _instancePositions.removeWhere((k, _) => k.startsWith('${id}_'));
    await _saveCounts();
    await _saveInstancePositions();
    await DatabaseHelper.instance.deleteReward(id);
    await loadRewardsAndStars();
  }

  Future<bool> redeemReward(RewardModel reward) async {
    if (_totalStars < reward.pointsCost) {
      return false;
    }

    _totalStars -= reward.pointsCost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _totalStars);

    if (reward.id != null) {
      final currentCount = getRedeemCount(reward.id);
      _rewardCounts[reward.id!] = currentCount + 1;
      await _saveCounts(prefs);
      await DatabaseHelper.instance.updateRewardRedeemed(reward.id!, true);
    }

    await loadRewardsAndStars();
    return true;
  }

  Future<void> fulfillReward(RewardModel reward) async {
    if (reward.id == null) return;
    final id = reward.id!;
    final currentCount = getRedeemCount(id);

    if (currentCount > 1) {
      final newCount = currentCount - 1;
      _rewardCounts[id] = newCount;
      _instancePositions.remove('${id}_$newCount');
      await _saveCounts();
      await _saveInstancePositions();
    } else {
      _rewardCounts.remove(id);
      _instancePositions.removeWhere((k, _) => k.startsWith('${id}_'));
      await _saveCounts();
      await _saveInstancePositions();
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

  Future<void> updateRewardPosition(
    int id,
    bool isPlaced,
    double x,
    double y,
  ) async {
    await updateInstancePosition(id, 0, isPlaced, x, y);
  }
}
