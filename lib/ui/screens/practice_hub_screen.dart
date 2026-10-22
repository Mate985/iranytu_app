import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reward_provider.dart';
import 'calm_room_screen.dart';
import 'word_match_game_screen.dart';
import 'routine_sequence_game_screen.dart';
import 'trace_shape_game_screen.dart';
import 'number_explorer_game_screen.dart';
import 'letter_trace_screen.dart';
import 'word_builder_game_screen.dart';

class PracticeHubScreen extends StatelessWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF1E293B),
        centerTitle: false,
        titleSpacing: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Játékos gyakorlás',
            style: TextStyle(
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          Consumer<RewardProvider>(
            builder: (context, rewardProv, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF854D0E).withValues(alpha: 0.35)
                      : const Color(0xFFFEF08A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFCA8A04)
                        : const Color(0xFFFDE047),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFBBF24),
                      size: 18,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${rewardProv.totalStars}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFFFEF08A)
                            : const Color(0xFF854D0E),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.spa_rounded,
              color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
              size: 26,
            ),
            tooltip: 'Nyugizóna',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalmRoomScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1B4332).withValues(alpha: 0.4)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2D6A4F)
                    : const Color(0xFFC8E6C9),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.3 : 0.05,
                        ),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.sports_esports_rounded,
                    color: isDark
                        ? const Color(0xFF81C784)
                        : const Color(0xFF2E7D32),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mit szeretnél játszani?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gyakorolj bátran, gyűjts csillagokat!',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFF388E3C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildGameCard(
            context: context,
            title: 'Beszélő Számtábla',
            subtitle: 'Ismerd meg a számokat játékosan hanggal és képpel!',
            icon: Icons.pin_rounded,
            cardColor: isDark
                ? const Color(0xFF0369A1).withValues(alpha: 0.3)
                : const Color(0xFFE0F2FE),
            borderColor: isDark
                ? const Color(0xFF0284C7).withValues(alpha: 0.5)
                : const Color(0xFFBAE6FD),
            accentColor: isDark
                ? const Color(0xFF38BDF8)
                : const Color(0xFF0284C7),
            rewardStars: 2,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NumberExplorerGameScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'Kép és Szó Kaland',
            subtitle: 'Kösd össze a szavakat a megfelelő képekkel!',
            icon: Icons.menu_book_rounded,
            cardColor: isDark
                ? const Color(0xFF92400E).withValues(alpha: 0.3)
                : const Color(0xFFFEF3C7),
            borderColor: isDark
                ? const Color(0xFFD97706).withValues(alpha: 0.5)
                : const Color(0xFFFDE68A),
            accentColor: isDark
                ? const Color(0xFFFBBF24)
                : const Color(0xFFD97706),
            rewardStars: 2,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WordMatchGameScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'Rutin Sorrendrakó',
            subtitle: 'Rakd helyes sorrendbe a napirendi lépéseket!',
            icon: Icons.format_list_numbered_rounded,
            cardColor: isDark
                ? const Color(0xFF166534).withValues(alpha: 0.3)
                : const Color(0xFFDCFCE7),
            borderColor: isDark
                ? const Color(0xFF16A34A).withValues(alpha: 0.5)
                : const Color(0xFFBBF7D0),
            accentColor: isDark
                ? const Color(0xFF4ADE80)
                : const Color(0xFF16A34A),
            rewardStars: 2,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoutineSequenceGameScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'Nyugis Vonalvezető',
            subtitle: 'Kövess lassú, szép formákat az ujjaddal!',
            icon: Icons.gesture_rounded,
            cardColor: isDark
                ? const Color(0xFF6B21A8).withValues(alpha: 0.3)
                : const Color(0xFFF3E8FF),
            borderColor: isDark
                ? const Color(0xFF9333EA).withValues(alpha: 0.5)
                : const Color(0xFFE9D5FF),
            accentColor: isDark
                ? const Color(0xFFC084FC)
                : const Color(0xFF9333EA),
            rewardStars: 1,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TraceShapeGameScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'ABC Betűíró ✍️',
            subtitle: 'Gyakorold a betűk rajzolását, kiejtését és a szavakat!',
            icon: Icons.edit_note_rounded,
            cardColor: isDark
                ? const Color(0xFF1E40AF).withValues(alpha: 0.3)
                : const Color(0xFFEFF6FF),
            borderColor: isDark
                ? const Color(0xFF2563EB).withValues(alpha: 0.5)
                : const Color(0xFFBFDBFE),
            accentColor: isDark
                ? const Color(0xFF60A5FA)
                : const Color(0xFF2563EB),
            rewardStars: 1,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LetterTraceScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'Szókirakó Kaland 🔤',
            subtitle: 'Rakd ki a szavakat a megfelelő betűk érintésével!',
            icon: Icons.spellcheck_rounded,
            cardColor: isDark
                ? const Color(0xFF991B1B).withValues(alpha: 0.3)
                : const Color(0xFFFEE2E2),
            borderColor: isDark
                ? const Color(0xFFDC2626).withValues(alpha: 0.5)
                : const Color(0xFFFECACA),
            accentColor: isDark
                ? const Color(0xFFF87171)
                : const Color(0xFFDC2626),
            rewardStars: 2,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WordBuilderGameScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardColor,
    required Color borderColor,
    required Color accentColor,
    required int rewardStars,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF854D0E).withValues(alpha: 0.35)
                              : const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFFCA8A04)
                                : const Color(0xFFFDE047),
                          ),
                        ),
                        child: Text(
                          '+$rewardStars ⭐',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFFEF08A)
                                : const Color(0xFF854D0E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
