import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../services/audio_service.dart';
import '../../services/app_settings_service.dart';

class TaskAlertDialog extends StatefulWidget {
  final TaskModel task;
  final String scheduledTime;

  const TaskAlertDialog({
    super.key,
    required this.task,
    required this.scheduledTime,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskModel task,
    required String scheduledTime,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TaskAlertDialog(task: task, scheduledTime: scheduledTime),
    );
  }

  @override
  State<TaskAlertDialog> createState() => _TaskAlertDialogState();
}

class _TaskAlertDialogState extends State<TaskAlertDialog> {
  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFF38BDF8);
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF38BDF8);
    }
  }

  IconData _getIconData(String? iconPath) {
    switch (iconPath) {
      case 'brush':
        return Icons.brush_rounded;
      case 'wash':
      case 'shower':
        return Icons.shower_rounded;
      case 'bed':
        return Icons.bed_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'sports_esports':
        return Icons.sports_esports_rounded;
      case 'check_circle':
        return Icons.check_circle_rounded;
      case 'directions_walk':
        return Icons.directions_walk_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'timer':
        return Icons.timer_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    // Csak akkor játszik le hangot automatikusan, ha a szülő nem tiltotta le
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isSoundEnabled = await AppSettingsService.isAlertSoundEnabled();
      if (!isSoundEnabled || !mounted) return;

      AudioService.instance.speakOrPlay(
        text: widget.task.ttsText.isNotEmpty
            ? widget.task.ttsText
            : widget.task.title,
        audioPath: widget.task.audioPath,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseColor(widget.task.colorCode);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Időpont jelvény
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    size: 18,
                    color: themeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.scheduledTime,
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nagy kerek ikon a feladathoz
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: themeColor, width: 3),
              ),
              child: Icon(
                _getIconData(widget.task.iconPath),
                size: 52,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 18),

            // Főcím
            const Text(
              'Itt az ideje!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.task.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),

            if (widget.task.ttsText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                widget.task.ttsText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Újrahallgatás gomb
            IconButton.filledTonal(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
              ),
              onPressed: () {
                AudioService.instance.speakOrPlay(
                  text: widget.task.ttsText.isNotEmpty
                      ? widget.task.ttsText
                      : widget.task.title,
                  audioPath: widget.task.audioPath,
                );
              },
              icon: const Icon(
                Icons.volume_up_rounded,
                color: Color(0xFF0284C7),
              ),
              tooltip: 'Újrahallgatás',
            ),

            const SizedBox(height: 24),

            // Nagy zöld gomb: "Megcsinálom!"
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  AudioService.instance.stopAll();
                  Navigator.of(context).pop();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Megcsinálom!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
