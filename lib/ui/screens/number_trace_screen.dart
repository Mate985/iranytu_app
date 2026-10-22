import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reward_provider.dart';
import '../../services/audio_service.dart';

class NumberTraceScreen extends StatefulWidget {
  final int number;

  const NumberTraceScreen({super.key, required this.number});

  @override
  State<NumberTraceScreen> createState() => _NumberTraceScreenState();
}

class _NumberTraceScreenState extends State<NumberTraceScreen> {
  final List<Offset?> _points = [];
  Size _canvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.speakOrPlay(
        text: 'Rajzold át a(z) ${widget.number} számot a szürke vonalon!',
        audioPath: 'assets/audio/words/rajzold_at_a_szamot.mp3',
      );
    });
  }

  Path _getNumberPath(int num, Size size) {
    final path = Path();
    if (size == Size.zero) return path;

    final w = size.width;
    final h = size.height;

    switch (num) {
      case 0:
        path.addOval(Rect.fromLTWH(w * 0.25, h * 0.15, w * 0.5, h * 0.7));
        break;
      case 1:
        path.moveTo(w * 0.35, h * 0.3);
        path.lineTo(w * 0.5, h * 0.15);
        path.lineTo(w * 0.5, h * 0.85);
        break;
      case 2:
        path.moveTo(w * 0.25, h * 0.3);
        path.quadraticBezierTo(w * 0.5, h * 0.1, w * 0.75, h * 0.3);
        path.lineTo(w * 0.25, h * 0.85);
        path.lineTo(w * 0.75, h * 0.85);
        break;
      case 3:
        path.moveTo(w * 0.25, h * 0.2);
        path.lineTo(w * 0.7, h * 0.2);
        path.lineTo(w * 0.45, h * 0.45);
        path.arcToPoint(
          Offset(w * 0.25, h * 0.75),
          radius: Radius.circular(w * 0.3),
          clockwise: true,
        );
        break;
      case 4:
        path.moveTo(w * 0.65, h * 0.15);
        path.lineTo(w * 0.2, h * 0.6);
        path.lineTo(w * 0.8, h * 0.6);
        path.moveTo(w * 0.65, h * 0.35);
        path.lineTo(w * 0.65, h * 0.85);
        break;
      case 5:
        path.moveTo(w * 0.7, h * 0.18);
        path.lineTo(w * 0.3, h * 0.18);
        path.lineTo(w * 0.3, h * 0.45);
        path.quadraticBezierTo(w * 0.75, h * 0.4, w * 0.7, h * 0.7);
        path.quadraticBezierTo(w * 0.55, h * 0.9, w * 0.25, h * 0.8);
        break;
      case 6:
        path.moveTo(w * 0.65, h * 0.18);
        path.quadraticBezierTo(w * 0.25, h * 0.35, w * 0.25, h * 0.65);
        path.addOval(Rect.fromLTWH(w * 0.25, h * 0.5, w * 0.5, h * 0.35));
        break;
      case 7:
        path.moveTo(w * 0.25, h * 0.18);
        path.lineTo(w * 0.75, h * 0.18);
        path.lineTo(w * 0.4, h * 0.85);
        break;
      case 8:
        path.addOval(Rect.fromLTWH(w * 0.3, h * 0.15, w * 0.4, h * 0.32));
        path.addOval(Rect.fromLTWH(w * 0.25, h * 0.47, w * 0.5, h * 0.38));
        break;
      case 9:
        path.addOval(Rect.fromLTWH(w * 0.25, h * 0.15, w * 0.5, h * 0.35));
        path.moveTo(w * 0.75, h * 0.4);
        path.lineTo(w * 0.75, h * 0.65);
        path.quadraticBezierTo(w * 0.75, h * 0.85, w * 0.35, h * 0.85);
        break;
      case 10:
        path.moveTo(w * 0.2, h * 0.3);
        path.lineTo(w * 0.35, h * 0.15);
        path.lineTo(w * 0.35, h * 0.85);
        path.addOval(Rect.fromLTWH(w * 0.5, h * 0.15, w * 0.35, h * 0.7));
        break;
      default:
        path.moveTo(w * 0.2, h * 0.5);
        path.lineTo(w * 0.8, h * 0.5);
    }

    return path;
  }

  void _finishTrace() {
    final validPoints = _points.where((p) => p != null).cast<Offset>().toList();

    if (validPoints.length < 20) {
      AudioService.instance.speakOrPlay(
        text: 'Próbáld meg követni a vonalat!',
        audioPath: 'assets/audio/words/probald_meg_kovetni_a_vonalat.mp3',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Próbáld meg követni a vonalat! 🌟'),
          backgroundColor: Color(0xFF64748B),
        ),
      );
      return;
    }

    // Pontosság ellenőrzése: a rajzolt pontok legfeljebb 35 pixelre lehetnek a sablon vonalától
    final targetPath = _getNumberPath(widget.number, _canvasSize);
    final metrics = targetPath.computeMetrics().toList();

    int accuratePoints = 0;
    for (final pt in validPoints) {
      bool isClose = false;
      for (final metric in metrics) {
        // Megkeressük a vonalhoz legközelebbi pontot
        for (double d = 0; d < metric.length; d += 10) {
          final pos = metric.getTangentForOffset(d)?.position;
          if (pos != null && (pos - pt).distance < 35) {
            isClose = true;
            break;
          }
        }
        if (isClose) break;
      }
      if (isClose) accuratePoints++;
    }

    final accuracyRatio = accuratePoints / validPoints.length;

    if (accuracyRatio < 0.45) {
      AudioService.instance.speakOrPlay(
        text: 'Próbáld meg követni a vonalat!',
        audioPath: 'assets/audio/words/probald_meg_kovetni_a_vonalat.mp3',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Próbáld meg pontosabban követni a szürke vonalat! ✍️'),
          backgroundColor: Color(0xFF64748B),
        ),
      );
      return;
    }

    context.read<RewardProvider>().addStars(1);
    AudioService.instance.speakOrPlay(
      text: 'Hurrá! Nagyon ügyes vagy, megcsináltad!',
      audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF0FDF4),
        title: const Row(
          children: [
            Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 30),
            SizedBox(width: 8),
            Text(
              'Szuper írás! ⭐',
              style: TextStyle(
                color: Color(0xFF15803D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Hibátlanul átrajzoltad a(z) ${widget.number}-es számot!\nKaptál +1 csillagot érte!',
          style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Vissza a Számtáblához ➔',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${widget.number}-es szám írása'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Újrarajzolás',
            onPressed: () => setState(() => _points.clear()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: GestureDetector(
                          onPanStart: (details) {
                            setState(() {
                              _points.add(details.localPosition);
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              _points.add(details.localPosition);
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              _points.add(null);
                            });
                          },
                          child: CustomPaint(
                            painter: _NumberPainter(
                              points: _points,
                              numberPath: _getNumberPath(
                                widget.number,
                                _canvasSize,
                              ),
                            ),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text(
                    'Kész a szám! Ellenőrzés',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: _finishTrace,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberPainter extends CustomPainter {
  final List<Offset?> points;
  final Path numberPath;

  _NumberPainter({required this.points, required this.numberPath});

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerGuidePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(numberPath, guidePaint);
    canvas.drawPath(numberPath, centerGuidePaint);

    final drawPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, drawPaint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawCircle(points[i]!, 6, drawPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NumberPainter oldDelegate) => true;
}
