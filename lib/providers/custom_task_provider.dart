import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/custom_task_model.dart';

class CustomTaskProvider extends ChangeNotifier {
  static const String _storageKey = 'custom_user_tasks';
  List<CustomTaskModel> _tasks = [];
  bool _isLoading = true;

  List<CustomTaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<CustomTaskModel> getTasksByCategory(String category) {
    return _tasks.where((t) => t.category == category).toList();
  }

  CustomTaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final List<String>? rawList = prefs.getStringList(_storageKey);

    if (rawList != null) {
      _tasks = rawList.map((item) => CustomTaskModel.fromJson(item)).toList();
    } else {
      _tasks = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(CustomTaskModel task) async {
    _tasks.add(task);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = _tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(_storageKey, rawList);
  }
}
