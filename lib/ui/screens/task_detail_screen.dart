import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/subtask_model.dart';
import '../../providers/routine_provider.dart';
import '../../services/audio_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final ScheduledTaskItem item;

  const TaskDetailScreen({super.key, required this.item});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<SubtaskModel> _subtasks = [];
  bool _isLoading = true;
  final Set<int> _completedStepIds = {};

  // Időzítő állapotváltozók
  Timer? _timer;
  late int _totalSeconds;
  late int _remainingSeconds;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _loadSubtasks();

    final durationMinutes = widget.item.task.defaultDuration;
    _totalSeconds = durationMinutes * 60;
    _remainingSeconds = _totalSeconds;
  }

  Future<void> _playTaskAudio() async {
    final task = widget.item.task;
    await AudioService.instance.speakOrPlay(
      text: task.ttsText.isNotEmpty ? task.ttsText : task.title,
      audioPath: task.audioPath,
    );
  }

  Future<void> _playStepAudio(SubtaskModel subtask) async {
    await AudioService.instance.speakOrPlay(
      text: subtask.description,
      audioPath: subtask.audioPath,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioService.instance.stopAll();
    super.dispose();
  }

  Future<void> _loadSubtasks() async {
    final subtasks = await _dbHelper.getSubtasksForTask(widget.item.task.id!);
    setState(() {
      _subtasks = subtasks;
      _isLoading = false;
    });
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) {
      _remainingSeconds = _totalSeconds;
    }
    _timer?.cancel();
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        _showCompletedDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ügyes vagy! 🎉'),
        content: const Text('Lejárt a feladatra szánt idő!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Rendben',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSecs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.item.task;
    final progress = _totalSeconds > 0
        ? (_remainingSeconds / _totalSeconds)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Instrukciós szöveg kártya felolvasó / lejátszó gombbal
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.ttsText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          iconSize: 32,
                          tooltip: 'Hang lejátszása',
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            color: Color(0xFF2563EB),
                          ),
                          onPressed: _playTaskAudio,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Vizuális kör alakú időzítő
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress > 0.25
                                ? const Color(0xFF81C784)
                                : const Color(0xFFE57373),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_remainingSeconds),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'hátralévő idő',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Időzítő kezelőgombok
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRunning
                              ? const Color(0xFFFFB74D)
                              : const Color(0xFF81C784),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isRunning ? _pauseTimer : _startTimer,
                        icon: Icon(
                          _isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          _isRunning ? 'Szünet' : 'Indítás',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Újra'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Lépések:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _subtasks.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Nincsenek részletes lépések ehhez a feladathoz.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _subtasks.length,
                          itemBuilder: (context, index) {
                            final subtask = _subtasks[index];
                            final isDone = _completedStepIds.contains(
                              subtask.id,
                            );

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isDone
                                      ? const Color(0xFF81C784)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              color: isDone
                                  ? const Color(0xFFF1F8E9)
                                  : Colors.white,
                              child: ListTile(
                                onTap: () => _playStepAudio(subtask),
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: isDone
                                      ? const Color(0xFF81C784)
                                      : const Color(0xFFE2E8F0),
                                  foregroundColor: isDone
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                  child: Text('${subtask.stepOrder}'),
                                ),
                                title: Text(
                                  subtask.description,
                                  style: TextStyle(
                                    fontSize: 15,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isDone
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.volume_up_rounded,
                                        color: Color(0xFF3B82F6),
                                        size: 22,
                                      ),
                                      tooltip: 'Lépés felmondása',
                                      onPressed: () => _playStepAudio(subtask),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isDone
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                  .radio_button_unchecked_rounded,
                                        color: isDone
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFF94A3B8),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (isDone) {
                                            _completedStepIds.remove(
                                              subtask.id,
                                            );
                                          } else {
                                            _completedStepIds.add(subtask.id!);
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
