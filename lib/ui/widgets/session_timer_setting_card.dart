import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_timer_provider.dart';

class SessionTimerSettingCard extends StatelessWidget {
  const SessionTimerSettingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF1E293B);
    final secondaryTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    // Kizárólag valós perces opciók (a 30 mp teszt eltávolítva)
    const options = [
      {'seconds': 0, 'label': 'Kikapcsolva'},
      {'seconds': 900, 'label': '15 perc'},
      {'seconds': 1800, 'label': '30 perc'},
      {'seconds': 2700, 'label': '45 perc'},
      {'seconds': 3600, 'label': '60 perc'},
    ];

    return Consumer<SessionTimerProvider>(
      builder: (context, timerProv, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Color(0xFF2563EB),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Játékidő korlát (Képernyőidő)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  if (timerProv.hasLimit)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E3A8A).withValues(alpha: 0.5)
                            : const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        timerProv.formattedRemainingTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                ],
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF1F5F9),
              ),
              Text(
                'Állítsd be, mennyi ideig használhatja a gyermek az alkalmazást. A háttérben is figyel, és értesítést küld, ha lejárt az idő.',
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((opt) {
                  final sec = opt['seconds'] as int;
                  final label = opt['label'] as String;
                  final isSelected = timerProv.timeLimitSeconds == sec;

                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : primaryTextColor,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                    onSelected: (_) {
                      timerProv.setTimeLimitSeconds(sec);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
