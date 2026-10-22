import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../data/models/routine_step_model.dart';
import '../../services/database_service.dart';
import '../../services/audio_service.dart';
import '../widgets/add_routine_dialog.dart';
import '../widgets/edit_routine_dialog.dart';
import '../widgets/parental_pin_dialog.dart';

class RoutineStepsScreen extends StatefulWidget {
  const RoutineStepsScreen({super.key});

  @override
  State<RoutineStepsScreen> createState() => _RoutineStepsScreenState();
}

class _RoutineStepsScreenState extends State<RoutineStepsScreen> {
  final DatabaseService _dbService = DatabaseService.instance;
  final FlutterTts _flutterTts = FlutterTts();
  List<Routine> _routines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadRoutines();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('hu-HU');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    AudioService.instance.stopAll();
    super.dispose();
  }

  Future<void> _loadRoutines() async {
    final routines = await _dbService.getRoutines();
    setState(() {
      _routines = routines;
      _isLoading = false;
    });
  }

  Future<void> _toggleStep(RoutineStep step) async {
    final newStatus = !step.isCompleted;
    setState(() {
      step.isCompleted = newStatus;
    });
    await _dbService.updateStepStatus(step.id, newStatus);
  }

  Future<void> _resetRoutine(Routine routine) async {
    setState(() {
      for (var step in routine.steps) {
        step.isCompleted = false;
      }
    });
    await _dbService.resetRoutineSteps(routine.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Lépésről lépésre',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
              itemCount: _routines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final routine = _routines[index];
                final progress = routine.progress;
                final isAllDone = progress == 1.0;

                return Card(
                  elevation: 2,
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isDark
                          ? routine.themeColor.withValues(alpha: 0.4)
                          : routine.themeColor.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: index == 0,
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: routine.themeColor.withValues(
                          alpha: isDark ? 0.25 : 0.15,
                        ),
                        child: Icon(
                          routine.icon,
                          color: routine.themeColor,
                          size: 26,
                        ),
                      ),
                      title: Text(
                        routine.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            routine.description,
                            softWrap: true,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 7,
                              backgroundColor: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isAllDone
                                    ? const Color(0xFF10B981)
                                    : routine.themeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                        ),
                        ...routine.steps.asMap().entries.map((entry) {
                          final stepIndex = entry.key;
                          final step = entry.value;

                          final stepBgColor = step.isCompleted
                              ? (isDark
                                    ? const Color(
                                        0xFF064E3B,
                                      ).withValues(alpha: 0.35)
                                    : const Color(0xFFF0FDF4))
                              : (isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.white);

                          final stepBorderColor = step.isCompleted
                              ? (isDark
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFBBF7D0))
                              : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0));

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: stepBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: stepBorderColor),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: step.isCompleted
                                      ? const Color(0xFF22C55E)
                                      : (isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0)),
                                  child: step.isCompleted
                                      ? const Icon(
                                          Icons.check,
                                          size: 15,
                                          color: Colors.white,
                                        )
                                      : Text(
                                          '${stepIndex + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 10),
                                // Itt töröltük a maxLines-t és az ellipsis-t, így teljes egészében kiírja a szöveget
                                Expanded(
                                  child: Text(
                                    step.title,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                      decoration: step.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: step.isCompleted
                                          ? (isDark
                                                ? const Color(0xFF4ADE80)
                                                : const Color(0xFF15803D))
                                          : (isDark
                                                ? const Color(0xFFF8FAFC)
                                                : const Color(0xFF1E293B)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        Icons.volume_up_rounded,
                                        color: isDark
                                            ? const Color(0xFF60A5FA)
                                            : const Color(0xFF2563EB),
                                        size: 22,
                                      ),
                                      tooltip: 'Lépés felolvasása',
                                      onPressed: () =>
                                          AudioService.instance.speakOrPlay(
                                            text: step.title,
                                            audioPath: step.audioPath,
                                          ),
                                    ),
                                    Checkbox(
                                      value: step.isCompleted,
                                      activeColor: const Color(0xFF22C55E),
                                      checkColor: Colors.white,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      side: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFF94A3B8),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      onChanged: (_) => _toggleStep(step),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: Color(0xFF64748B),
                                    ),
                                    tooltip: 'Rutin szerkesztése (Szülői)',
                                    onPressed: () async {
                                      final isAuthorized =
                                          await ParentalPinDialog.show(context);
                                      if (!isAuthorized || !context.mounted)
                                        return;

                                      final updated =
                                          await EditRoutineDialog.show(
                                            context,
                                            routine,
                                          );
                                      if (updated == true) {
                                        _loadRoutines();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 20,
                                      color: Color(0xFFEF4444),
                                    ),
                                    tooltip: 'Rutin törlése (Szülői)',
                                    onPressed: () async {
                                      final isAuthorized =
                                          await ParentalPinDialog.show(context);
                                      if (!isAuthorized || !context.mounted)
                                        return;

                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: isDark
                                              ? const Color(0xFF1E293B)
                                              : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          title: Text(
                                            'Rutin törlése',
                                            style: TextStyle(
                                              color: isDark
                                                  ? const Color(0xFFF8FAFC)
                                                  : const Color(0xFF0F172A),
                                            ),
                                          ),
                                          content: Text(
                                            'Biztosan törölni szeretnéd a(z) "${routine.title}" rutint a lépéseivel együtt?',
                                            style: TextStyle(
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF334155),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: Text(
                                                'Mégse',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? const Color(0xFF94A3B8)
                                                      : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFEF4444,
                                                ),
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text(
                                                'Törlés',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await _dbService.deleteRoutine(
                                          routine.id,
                                        );
                                        _loadRoutines();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () => _resetRoutine(routine),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                                label: const Text(
                                  'Újrakezdés',
                                  style: TextStyle(color: Color(0xFF64748B)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Új rutin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final isAuthorized = await ParentalPinDialog.show(context);
          if (!isAuthorized || !context.mounted) return;

          final added = await AddRoutineDialog.show(context);
          if (added == true) {
            _loadRoutines();
          }
        },
      ),
    );
  }
}
