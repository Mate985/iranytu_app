import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/trace_patterns_data.dart';
import '../../providers/reward_provider.dart';
import '../../services/audio_service.dart';
import '../widgets/trace_pattern_picker_dialog.dart';
import '../widgets/game_success_dialog.dart';
import 'calm_room_screen.dart';

class TraceShapeGameScreen extends StatefulWidget {
  const TraceShapeGameScreen({super.key});

  @override
  State<TraceShapeGameScreen> createState() => _TraceShapeGameScreenState();
}

class _TraceShapeGameScreenState extends State<TraceShapeGameScreen> {
  final List<List<Offset>> _userStrokes = [];
  List<Offset> _currentStroke = [];
  final List<TracePattern> _patterns = TracePatternsData.getAllPatterns();
  int _currentPatternIndex = 0;
  int _completedShapesCount = 0;
  Size _canvasSize = Size.zero;

  TracePattern get _currentPattern => _patterns[_currentPatternIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakInstruction();
    });
  }

  void _speakInstruction() {
    AudioService.instance.speakOrPlay(
      text: 'Rajzold át a vonalat a szürke sávot követve!',
      audioPath: 'assets/audio/words/rajzold_at_a_vonalat.mp3',
    );
  }

  Path _getPatternPath(TracePattern pattern, Size size) {
    final path = Path();
    if (pattern.points.isEmpty || size == Size.zero) return path;

    final first = Offset(
      pattern.points.first.dx * size.width,
      pattern.points.first.dy * size.height,
    );
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < pattern.points.length; i++) {
      final pt = Offset(
        pattern.points[i].dx * size.width,
        pattern.points[i].dy * size.height,
      );
      path.lineTo(pt.dx, pt.dy);
    }
    return path;
  }

  bool _validateTracing() {
    final allPoints = [
      ..._userStrokes.expand((stroke) => stroke),
      ..._currentStroke,
    ];

    if (allPoints.length < 15 || _canvasSize == Size.zero) return false;

    final targetPath = _getPatternPath(_currentPattern, _canvasSize);
    final pathMetrics = targetPath.computeMetrics().toList();
    if (pathMetrics.isEmpty) return false;

    final metric = pathMetrics.first;
    final totalLength = metric.length;

    const maxAllowedDistance = 48.0;
    int offTrackPoints = 0;

    for (final p in allPoints) {
      double minDistance = double.infinity;
      for (double d = 0; d < totalLength; d += 15) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent != null) {
          final dist = (p - tangent.position).distance;
          if (dist < minDistance) {
            minDistance = dist;
          }
        }
      }
      if (minDistance > maxAllowedDistance) {
        offTrackPoints++;
      }
    }

    if (offTrackPoints / allPoints.length > 0.30) {
      return false;
    }

    return true;
  }

  void _finishShape() {
    final isValid = _validateTracing();

    if (!isValid) {
      AudioService.instance.speakOrPlay(
        text: 'Próbáld meg pontosabban követni a szürke vonalat!',
        audioPath: 'assets/audio/words/probald_meg_pontosabban_kovetni.mp3',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Maradj a szürke vonal mentén, és húzd végig az ujjad!',
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF64748B),
        ),
      );
      return;
    }

    _completedShapesCount++;
    final earnedStar = (_completedShapesCount % 3 == 0);
    if (earnedStar) {
      context.read<RewardProvider>().addStars(1);
    }

    AudioService.instance.speakOrPlay(
      text: 'Hurrá, nagyon ügyes vagy!',
      audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
    );

    GameSuccessDialog.show(
      context,
      title: 'Szép vonalvezetés! 🎨',
      message: 'Sikeresen átrajzoltad a(z) ${_currentPattern.title} mintát!',
      earnedStar: earnedStar,
      audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
      onNext: () {
        setState(() {
          _userStrokes.clear();
          _currentStroke.clear();
          _currentPatternIndex = (_currentPatternIndex + 1) % _patterns.length;
        });
        _speakInstruction();
      },
    );
  }

  Future<void> _openPatternPicker() async {
    final picked = await TracePatternPickerDialog.show(
      context,
      _currentPattern.id,
    );
    if (picked != null) {
      setState(() {
        _userStrokes.clear();
        _currentStroke.clear();
        _currentPatternIndex = _patterns.indexWhere((p) => p.id == picked.id);
      });
      _speakInstruction();
    }
  }

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
        centerTitle: true,
        title: Text(
          'Nyugis Vonalvezető',
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Consumer<RewardProvider>(
            builder: (context, rewardProv, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rewardProv.totalStars}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _currentPattern.iconEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPattern.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFF8FAFC)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_currentPattern.category} • ${_currentPatternIndex + 1}/${_patterns.length}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.grid_view_rounded,
                            color: Color(0xFF3B82F6),
                            size: 22,
                          ),
                          tooltip: 'Minta választása',
                          onPressed: _openPatternPicker,
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            size: 22,
                          ),
                          tooltip: 'Újrarajzolás',
                          onPressed: () {
                            setState(() {
                              _userStrokes.clear();
                              _currentStroke.clear();
                            });
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            color: Color(0xFF9333EA),
                            size: 22,
                          ),
                          tooltip: 'Utasítás meghallgatása',
                          onPressed: _speakInstruction,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _canvasSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: GestureDetector(
                          onPanStart: (details) {
                            setState(() {
                              _currentStroke = [details.localPosition];
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              _currentStroke.add(details.localPosition);
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              if (_currentStroke.isNotEmpty) {
                                _userStrokes.add(List.from(_currentStroke));
                                _currentStroke.clear();
                              }
                            });
                          },
                          child: CustomPaint(
                            painter: _ShapePainter(
                              userStrokes: _userStrokes,
                              currentStroke: _currentStroke,
                              shapePath: _getPatternPath(
                                _currentPattern,
                                _canvasSize,
                              ),
                              isDark: isDark,
                            ),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9333EA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text(
                    'Kész vagyok a vonallal!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: _finishShape,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final List<List<Offset>> userStrokes;
  final List<Offset> currentStroke;
  final Path shapePath;
  final bool isDark;

  _ShapePainter({
    required this.userStrokes,
    required this.currentStroke,
    required this.shapePath,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..strokeWidth = 28
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerGuidePaint = Paint()
      ..color = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(shapePath, guidePaint);
    canvas.drawPath(shapePath, centerGuidePaint);

    final drawPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in userStrokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], drawPaint);
      }
    }

    for (int i = 0; i < currentStroke.length - 1; i++) {
      canvas.drawLine(currentStroke[i], currentStroke[i + 1], drawPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) => true;
}
