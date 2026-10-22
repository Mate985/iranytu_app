import 'package:flutter/material.dart';

class RewardCelebrationDialog extends StatelessWidget {
  final int earnedStars;
  final String taskTitle;

  const RewardCelebrationDialog({
    super.key,
    required this.earnedStars,
    required this.taskTitle,
  });

  static Future<void> show(
    BuildContext context, {
    required int earnedStars,
    required String taskTitle,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => RewardCelebrationDialog(
        earnedStars: earnedStars,
        taskTitle: taskTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arany csillag ikon háttér karikával
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFEF08A),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 60,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Szuper vagy!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Befejezted ezt a feladatot:\n"$taskTitle"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Megszerzett pontok jelzése
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: Color(0xFFD97706),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+$earnedStars Csillag!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Köszönöm!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
