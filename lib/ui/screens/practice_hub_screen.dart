import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/session_timer_provider.dart';
import 'calm_room_screen.dart';
import 'word_match_game_screen.dart';
import 'routine_sequence_game_screen.dart';
import 'trace_shape_game_screen.dart';
import 'number_explorer_game_screen.dart';
import 'letter_trace_screen.dart';
import 'word_builder_game_screen.dart';
import 'memory_game_screen.dart';
import 'odd_one_out_game_screen.dart';
import 'session_timeout_screen.dart';

class PracticeHubScreen extends StatelessWidget {
  const PracticeHubScreen({super.key});

  void _openGame(BuildContext context, Widget gameScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _GameSessionGuard(child: gameScreen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timerProv = context.watch<SessionTimerProvider>();

    if (timerProv.isTimeUp) {
      return const SessionTimeoutScreen();
    }

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
          if (timerProv.hasLimit)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF93C5FD),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: isDark
                        ? const Color(0xFF93C5FD)
                        : const Color(0xFF1D4ED8),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timerProv.formattedRemainingTime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
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
                        'Mit játszunk?',
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
                        'Gyűjts csillagokat!',
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
            title: 'Memória Párkereső 🧠',
            subtitle: 'Találd meg a párokat!',
            icon: Icons.grid_view_rounded,
            cardColor: isDark
                ? const Color(0xFF0F766E).withValues(alpha: 0.35)
                : const Color(0xFFCCFBF1),
            borderColor: isDark
                ? const Color(0xFF14B8A6).withValues(alpha: 0.5)
                : const Color(0xFF99F6E4),
            accentColor: isDark
                ? const Color(0xFF2DD4BF)
                : const Color(0xFF0D9488),
            rewardStars: 2,
            onTap: () => _openGame(context, const MemoryGameScreen()),
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'Kakukktojás Kereső 🐣',
            subtitle: 'Melyik nem illik ide?',
            icon: Icons.rule_rounded,
            cardColor: isDark
                ? const Color(0xFFB45309).withValues(alpha: 0.3)
                : const Color(0xFFFEF3C7),
            borderColor: isDark
                ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                : const Color(0xFFFDE68A),
            accentColor: isDark
                ? const Color(0xFFFBBF24)
                : const Color(0xFFD97706),
            rewardStars: 2,
            onTap: () => _openGame(context, const OddOneOutGameScreen()),
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'Beszélő Számtábla',
            subtitle: 'Számolj és hallgasd!',
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
            onTap: () => _openGame(context, const NumberExplorerGameScreen()),
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'Kép és Szó Kaland',
            subtitle: 'Párosítsd a képet és a szót!',
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
            onTap: () => _openGame(context, const WordMatchGameScreen()),
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'Rutin Sorrendrakó',
            subtitle: 'Rakd sorrendbe a lépéseket!',
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
            onTap: () => _openGame(context, const RoutineSequenceGameScreen()),
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'Nyugis Vonalvezető',
            subtitle: 'Kövesd a vonalat az ujjaddal!',
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
            onTap: () => _openGame(context, const TraceShapeGameScreen()),
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'ABC Betűíró ✍️',
            subtitle: 'Rajzold át a betűt!',
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
            onTap: () => _openGame(context, const LetterTraceScreen()),
          ),
          const SizedBox(height: 14),

          _buildGameCard(
            context: context,
            title: 'Szókirakó Kaland 🔤',
            subtitle: 'Rakd ki a szót!',
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
            onTap: () => _openGame(context, const WordBuilderGameScreen()),
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

class _GameSessionGuard extends StatelessWidget {
  final Widget child;

  const _GameSessionGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isTimeUp = context.select<SessionTimerProvider, bool>(
      (prov) => prov.isTimeUp,
    );

    if (isTimeUp) {
      return const SessionTimeoutScreen();
    }

    return child;
  }
}
