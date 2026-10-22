import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_timer_provider.dart';

class SessionTimerSettingCard extends StatelessWidget {
  const SessionTimerSettingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProv = context.watch<SessionTimerProvider>();
    final options = [0, 5, 10, 15, 20, 30];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.timer_rounded,
                  color: Color(0xFFD97706),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Játékidő korlát',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      timerProv.hasLimit
                          ? 'Aktív: ${timerProv.timeLimitMinutes} perc (Hátralévő: ${timerProv.formattedRemainingTime})'
                          : 'Jelenleg korlátlan játékidő van beállítva',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Válassz maximális játékidőt:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((minutes) {
              final isSelected = timerProv.timeLimitMinutes == minutes;
              return ChoiceChip(
                label: Text(minutes == 0 ? 'Kikapcsolva' : '$minutes perc'),
                selected: isSelected,
                selectedColor: const Color(0xFFD97706),
                backgroundColor: const Color(0xFFF1F5F9),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (selected) {
                  if (selected) {
                    context.read<SessionTimerProvider>().setTimeLimit(minutes);
                  }
                },
              );
            }).toList(),
          ),
          if (timerProv.hasLimit) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Időzítő újraindítása mára'),
              onPressed: () {
                context.read<SessionTimerProvider>().resetSession();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'A játékidő újraindítva a beállított limitre.',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
