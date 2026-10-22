import 'dart:math';
import 'package:flutter/material.dart';

class CalmRoomScreen extends StatefulWidget {
  const CalmRoomScreen({super.key});

  @override
  State<CalmRoomScreen> createState() => _CalmRoomScreenState();
}

class _CalmRoomScreenState extends State<CalmRoomScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  // Választható nyugtató színvilágok
  int _colorThemeIndex = 0;
  final List<List<Color>> _themes = [
    [const Color(0xFF0F172A), const Color(0xFF1E293B)], // Éjszakai égbolt
    [const Color(0xFF1E1B4B), const Color(0xFF312E81)], // Mélylila nyugalom
    [const Color(0xFF064E3B), const Color(0xFF065F46)], // Erdei csend
    [const Color(0xFF0C4A6E), const Color(0xFF075985)], // Óceán mélye
  ];

  // Interaktív buborékok pozíciói
  final List<Offset> _bubbles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    // 8 másodperces lassú, ritmikus légzési ciklus (4 mp be, 4 mp ki)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOutSine,
    );

    // Kezdeti buborékok generálása
    for (int i = 0; i < 8; i++) {
      _bubbles.add(
        Offset(0.2 + _rnd.nextDouble() * 0.6, 0.2 + _rnd.nextDouble() * 0.6),
      );
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  void _popBubble(int index) {
    setState(() {
      _bubbles.removeAt(index);
      // Pár másodperc múlva újra felbukkanhat máshol
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _bubbles.add(
              Offset(
                0.15 + _rnd.nextDouble() * 0.7,
                0.15 + _rnd.nextDouble() * 0.7,
              ),
            );
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _themes[_colorThemeIndex];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: currentTheme,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                children: [
                  // 1. KÖZÉPSŐ LÉGZÉSSEGÍTŐ PULZÁLÓ KÖR ÉS SZÖVEG
                  // IgnorePointer: Nem blokkolja az érintéseket, így a buborékok bárhol pukkaszthatóak!
                  Center(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _breathingAnimation,
                        builder: (context, child) {
                          final scale =
                              0.85 + (_breathingAnimation.value * 0.35);
                          final isBreathingIn =
                              _breathingController.status ==
                              AnimationStatus.forward;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.25),
                                        Colors.white.withValues(alpha: 0.05),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.spa_rounded,
                                      size: 48,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                child: Text(
                                  isBreathingIn
                                      ? 'Beszívjuk a levegőt... 🌸'
                                      : 'Lassan kifújjuk... 🍃',
                                  key: ValueKey(isBreathingIn),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Itt minden rendben van. Pihenj egy picit.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // 2. SZENZOROS LEBEGŐ BUBORÉKOK (A kör felett/mögött is azonnal elpukkannak)
                  ..._bubbles.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final pos = entry.value;
                    return Positioned(
                      left: pos.dx * w - 30,
                      top: pos.dy * h - 30,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _popBubble(idx),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // 3. BEZÁRÁS ÉS TÉMAVÁLTÓ GOMBOK (FELÜL - megmarad a kattinthatóságuk)
                  Positioned(
                    top: 10,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white70,
                        size: 28,
                      ),
                      tooltip: 'Vissza',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 16,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.palette_outlined,
                            color: Colors.white70,
                            size: 28,
                          ),
                          tooltip: 'Másik színvilág',
                          onPressed: () {
                            setState(() {
                              _colorThemeIndex =
                                  (_colorThemeIndex + 1) % _themes.length;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
