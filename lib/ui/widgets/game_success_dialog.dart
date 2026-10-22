import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

enum CharacterGender { boy, girl }

class GameSuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final bool earnedStar;
  final VoidCallback onNext;
  final CharacterGender? gender;
  final String? audioPath;

  const GameSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    required this.earnedStar,
    required this.onNext,
    this.gender,
    this.audioPath,
  });

  static Future<void> show(
    BuildContext context, {
    String title = 'Hurrá! Megcsináltad! 🎉',
    required String message,
    required bool earnedStar,
    required VoidCallback onNext,
    CharacterGender? gender,
    String? audioPath = 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameSuccessDialog(
        title: title,
        message: message,
        earnedStar: earnedStar,
        onNext: onNext,
        gender: gender,
        audioPath: audioPath,
      ),
    );
  }

  @override
  State<GameSuccessDialog> createState() => _GameSuccessDialogState();
}

class _GameSuccessDialogState extends State<GameSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late CharacterGender _activeGender;

  @override
  void initState() {
    super.initState();
    _activeGender =
        widget.gender ??
        (DateTime.now().second % 2 == 0
            ? CharacterGender.boy
            : CharacterGender.girl);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.speakOrPlay(
        text: 'Hurrá! Nagyon ügyes vagy, megcsináltad!',
        audioPath:
            widget.audioPath ??
            'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBoy = _activeGender == CharacterGender.boy;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ANIMÁLT KARAKTER FIGURA
            ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Háttér fényudvar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isBoy
                          ? (isDark
                                ? const Color(
                                    0xFF0369A1,
                                  ).withValues(alpha: 0.35)
                                : const Color(0xFFE0F2FE))
                          : (isDark
                                ? const Color(
                                    0xFFBE185D,
                                  ).withValues(alpha: 0.35)
                                : const Color(0xFFFCE7F3)),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isBoy
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFFF472B6))
                                  .withValues(alpha: 0.3),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  // Karakter fej & lájk kéz
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isBoy ? '👦' : '👧',
                        style: const TextStyle(fontSize: 58),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('👍', style: TextStyle(fontSize: 28)),
                          if (widget.earnedStar) ...[
                            const SizedBox(width: 4),
                            const Text('⭐', style: TextStyle(fontSize: 26)),
                          ],
                        ],
                      ),
                    ],
                  ),

                  // Környező csillagok
                  Positioned(
                    top: -6,
                    left: 2,
                    child: Text(
                      '✨',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.amber.shade400,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 10,
                    right: -4,
                    child: Text('🎉', style: TextStyle(fontSize: 22)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // CÍM
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isBoy
                    ? (isDark
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF0284C7))
                    : (isDark
                          ? const Color(0xFFF472B6)
                          : const Color(0xFFDB2777)),
              ),
            ),

            const SizedBox(height: 8),

            // ÜZENET & CSILLAG VISSZAJELZÉS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF334155),
                      height: 1.3,
                    ),
                  ),
                  if (widget.earnedStar) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF78350F).withValues(alpha: 0.4)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFFD97706)
                              : const Color(0xFFFCD34D),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Color(0xFFFBBF24),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+1 Csillag jutalom! ⭐',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TOVÁBB GOMB
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'Tovább a következőhöz ➔',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onNext();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
