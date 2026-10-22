import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../services/audio_service.dart';
import '../screens/task_detail_screen.dart';
import '../helpers/icon_helper.dart';
import 'parental_pin_dialog.dart';

class TaskCard extends StatelessWidget {
  final ScheduledTaskItem item;
  final VoidCallback onToggle;

  const TaskCard({super.key, required this.item, required this.onToggle});

  Future<void> _selectTime(BuildContext context) async {
    final isUnlocked = await ParentalPinDialog.show(context);
    if (!isUnlocked || !context.mounted) return;

    TimeOfDay initialTime = const TimeOfDay(hour: 8, minute: 0);
    if (item.schedule.scheduledTime != null &&
        item.schedule.scheduledTime!.contains(':')) {
      final parts = item.schedule.scheduledTime!.split(':');
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;
      initialTime = TimeOfDay(hour: hour, minute: minute);
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      await context.read<RoutineProvider>().updateTaskTime(
        item.schedule.id!,
        formattedTime,
      );
    }
  }

  Future<void> _deleteTask(BuildContext context) async {
    final isUnlocked = await ParentalPinDialog.show(context);
    if (!isUnlocked || !context.mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Feladat törlése'),
        content: Text(
          'Biztosan törölni szeretnéd a(z) "${item.task.title}" feladatot a mai napirendből?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Mégse'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Törlés', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<RoutineProvider>().removeTaskFromSchedule(
        item.schedule.id!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = item.schedule.status == 'COMPLETED';

    final cardBgColor = isCompleted
        ? (isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.5)
              : const Color(0xFFF1F5F9))
        : (isDark ? const Color(0xFF1E293B) : Colors.white);

    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    final titleColor = isCompleted
        ? const Color(0xFF94A3B8)
        : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B));

    final timeColor = isCompleted
        ? const Color(0xFF94A3B8)
        : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isCompleted
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(item: item),
              ),
            );
          },
          onLongPress: () => _deleteTask(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isCompleted
                      ? const Color(0xFF81C784)
                      : const Color(
                          0xFF81C784,
                        ).withValues(alpha: isDark ? 0.25 : 0.15),
                  child: Icon(
                    isCompleted
                        ? Icons.check_rounded
                        : AppIcons.getIcon(item.task.iconPath),
                    color: isCompleted
                        ? Colors.white
                        : (isDark
                              ? const Color(0xFF81C784)
                              : const Color(0xFF2E7D32)),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          color: titleColor,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectTime(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: timeColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.schedule.scheduledTime ??
                                  'Időpont beállítása',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: timeColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit_rounded,
                              size: 12,
                              color: timeColor.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.volume_up_rounded,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF2563EB),
                        size: 24,
                      ),
                      tooltip: 'Felolvasás / Hang lejátszása',
                      onPressed: () {
                        final textToSpeak = item.task.ttsText.trim().isNotEmpty
                            ? item.task.ttsText
                            : item.task.title;

                        AudioService.instance.speakOrPlay(
                          text: textToSpeak,
                          audioPath: item.task.audioPath,
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isCompleted
                            ? const Color(0xFF16A34A)
                            : (isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8)),
                        size: 28,
                      ),
                      onPressed: onToggle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
