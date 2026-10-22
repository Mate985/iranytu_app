import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reward_provider.dart';
import '../../data/models/reward_model.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  Widget _buildRewardImage(RewardModel reward, {bool isDark = false}) {
    if (reward.imageType == 'CUSTOM_IMAGE' &&
        File(reward.imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(reward.imagePath),
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    }

    IconData iconData = Icons.stars_rounded;
    switch (reward.imagePath) {
      case 'icecream':
        iconData = Icons.icecream_rounded;
        break;
      case 'tv':
        iconData = Icons.tv_rounded;
        break;
      case 'park':
        iconData = Icons.park_rounded;
        break;
      case 'toys':
        iconData = Icons.toys_rounded;
        break;
      case 'book':
        iconData = Icons.menu_book_rounded;
        break;
      case 'sports':
        iconData = Icons.sports_esports_rounded;
        break;
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF854D0E).withValues(alpha: 0.35)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        iconData,
        size: 40,
        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      ),
    );
  }

  void _claimReward(BuildContext context, RewardModel reward) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration_rounded, color: Color(0xFFD97706), size: 28),
            SizedBox(width: 8),
            Text(
              'Jutalom beváltása',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRewardImage(reward, isDark: isDark),
            const SizedBox(height: 16),
            Text(
              'Szeretnéd beváltani a(z) "${reward.title}" jutalmat?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ez ${reward.pointsCost} csillagodba fog kerülni.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFB45309),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await context.read<RewardProvider>().redeemReward(
                reward,
              );
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Gratulálunk! Megkaptad: ${reward.title}! 🎉',
                    ),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Igen, beváltom!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<RewardProvider>(
      builder: (context, rewardProv, child) {
        final currentStars = rewardProv.totalStars;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'Jutalmaim',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            foregroundColor: isDark
                ? const Color(0xFFF8FAFC)
                : const Color(0xFF1E293B),
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF854D0E).withValues(alpha: 0.6),
                            const Color(0xFFA16207).withValues(alpha: 0.5),
                          ]
                        : [const Color(0xFFFEF08A), const Color(0xFFFDE047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: isDark
                      ? Border.all(
                          color: const Color(0xFFCA8A04).withValues(alpha: 0.5),
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : const Color(0xFFEAB308).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Összegyűjtött csillagaid',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFFEF9C3)
                                : const Color(0xFF854D0E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Válassz egy jutalmat!',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFFFDE047)
                                : const Color(0xFF713F12),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFBBF24),
                          size: 36,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$currentStars',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFFEF9C3)
                                : const Color(0xFF713F12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rewardProv.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : rewardProv.rewards.isEmpty
                    ? Center(
                        child: Text(
                          'Még nincsenek jutalmak felvéve.',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: rewardProv.rewards.length,
                        itemBuilder: (context, index) {
                          final reward = rewardProv.rewards[index];
                          final canAfford = currentStars >= reward.pointsCost;
                          final missingStars = reward.pointsCost - currentStars;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: canAfford
                                    ? (isDark
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFF86EFAC))
                                    : (isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0)),
                                width: canAfford ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.25 : 0.04,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildRewardImage(reward, isDark: isDark),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      reward.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                        color: isDark
                                            ? const Color(0xFFF8FAFC)
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (canAfford)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 38,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _claimReward(context, reward),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF22C55E,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Kérem! (${reward.pointsCost} ⭐)',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    height: 38,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.lock_outline_rounded,
                                          size: 14,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 4),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Még $missingStars ⭐',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
