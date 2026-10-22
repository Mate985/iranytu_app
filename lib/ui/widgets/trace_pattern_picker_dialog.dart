import 'package:flutter/material.dart';
import '../../data/trace_patterns_data.dart';

class TracePatternPickerDialog extends StatelessWidget {
  final int selectedPatternId;
  final ValueChanged<TracePattern> onPatternSelected;

  const TracePatternPickerDialog({
    super.key,
    required this.selectedPatternId,
    required this.onPatternSelected,
  });

  static Future<TracePattern?> show(BuildContext context, int currentId) {
    return showDialog<TracePattern>(
      context: context,
      builder: (ctx) => TracePatternPickerDialog(
        selectedPatternId: currentId,
        onPatternSelected: (p) => Navigator.pop(ctx, p),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patterns = TracePatternsData.getAllPatterns();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.92,
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF2563EB),
                  size: 26,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '30 Vonalvezetési Minta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Válassz ki egy sablont a gyakorláshoz!',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
            Divider(
              height: 20,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: patterns.length,
                itemBuilder: (context, index) {
                  final p = patterns[index];
                  final isSelected = p.id == selectedPatternId;

                  final cardBg = isSelected
                      ? (isDark
                            ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                            : const Color(0xFFEFF6FF))
                      : (isDark ? const Color(0xFF0F172A) : Colors.white);

                  final borderColor = isSelected
                      ? const Color(0xFF2563EB)
                      : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0));

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onPatternSelected(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            p.iconEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${p.id} ${p.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: isSelected
                                        ? const Color(0xFF38BDF8)
                                        : (isDark
                                              ? const Color(0xFFF8FAFC)
                                              : const Color(0xFF1E293B)),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
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
            ),
          ],
        ),
      ),
    );
  }
}
