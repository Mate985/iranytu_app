import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reward_provider.dart';
import '../../services/audio_service.dart';
import '../widgets/game_success_dialog.dart';
import 'calm_room_screen.dart';

class AlphabetLetter {
  final String letter;
  final String word;
  final String emoji;
  final List<List<Offset>> strokes;

  const AlphabetLetter({
    required this.letter,
    required this.word,
    required this.emoji,
    required this.strokes,
  });

  String get audioFileName => '${letter.toLowerCase()}.mp3';
}

class LetterTraceScreen extends StatefulWidget {
  final int initialIndex;

  const LetterTraceScreen({super.key, this.initialIndex = 0});

  @override
  State<LetterTraceScreen> createState() => _LetterTraceScreenState();
}

class _LetterTraceScreenState extends State<LetterTraceScreen> {
  final List<List<Offset>> _userStrokes = [];
  List<Offset> _currentStroke = [];
  int _currentIndex = 0;
  int _completedLettersCount = 0;
  Size _canvasSize = Size.zero;

  final List<AlphabetLetter> _alphabet = const [
    AlphabetLetter(
      letter: 'A',
      word: 'Alma',
      emoji: '🍎',
      strokes: [
        [Offset(0.5, 0.15), Offset(0.2, 0.85)],
        [Offset(0.5, 0.15), Offset(0.8, 0.85)],
        [Offset(0.32, 0.6), Offset(0.68, 0.6)],
      ],
    ),
    AlphabetLetter(
      letter: 'Á',
      word: 'Ásó',
      emoji: '⛏️',
      strokes: [
        [Offset(0.5, 0.22), Offset(0.2, 0.85)],
        [Offset(0.5, 0.22), Offset(0.8, 0.85)],
        [Offset(0.32, 0.62), Offset(0.68, 0.62)],
        [Offset(0.4, 0.12), Offset(0.6, 0.05)],
      ],
    ),
    AlphabetLetter(
      letter: 'B',
      word: 'Baba',
      emoji: '👶',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.25, 0.85)],
        [
          Offset(0.25, 0.15),
          Offset(0.65, 0.15),
          Offset(0.75, 0.32),
          Offset(0.65, 0.5),
          Offset(0.25, 0.5),
        ],
        [
          Offset(0.25, 0.5),
          Offset(0.7, 0.5),
          Offset(0.8, 0.67),
          Offset(0.7, 0.85),
          Offset(0.25, 0.85),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'C',
      word: 'Cica',
      emoji: '🐱',
      strokes: [
        [
          Offset(0.75, 0.25),
          Offset(0.5, 0.15),
          Offset(0.25, 0.35),
          Offset(0.25, 0.65),
          Offset(0.5, 0.85),
          Offset(0.75, 0.75),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'Cs',
      word: 'Csiga',
      emoji: '🐌',
      strokes: [
        [
          Offset(0.5, 0.25),
          Offset(0.35, 0.15),
          Offset(0.18, 0.35),
          Offset(0.18, 0.65),
          Offset(0.35, 0.85),
          Offset(0.5, 0.75),
        ],
        [
          Offset(0.82, 0.25),
          Offset(0.68, 0.18),
          Offset(0.58, 0.3),
          Offset(0.65, 0.5),
          Offset(0.8, 0.6),
          Offset(0.82, 0.75),
          Offset(0.68, 0.85),
          Offset(0.55, 0.78),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'D',
      word: 'Doboz',
      emoji: '📦',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.25, 0.85)],
        [
          Offset(0.25, 0.15),
          Offset(0.55, 0.15),
          Offset(0.8, 0.35),
          Offset(0.8, 0.65),
          Offset(0.55, 0.85),
          Offset(0.25, 0.85),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'Dz',
      word: 'Edző',
      emoji: '🏋️',
      strokes: [
        [Offset(0.2, 0.15), Offset(0.2, 0.85)],
        [
          Offset(0.2, 0.15),
          Offset(0.45, 0.15),
          Offset(0.55, 0.4),
          Offset(0.55, 0.6),
          Offset(0.45, 0.85),
          Offset(0.2, 0.85),
        ],
        [
          Offset(0.65, 0.25),
          Offset(0.85, 0.25),
          Offset(0.65, 0.85),
          Offset(0.85, 0.85),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'Dzs',
      word: 'Dzseki',
      emoji: '🧥',
      strokes: [
        [Offset(0.15, 0.15), Offset(0.15, 0.85)],
        [
          Offset(0.15, 0.15),
          Offset(0.35, 0.15),
          Offset(0.45, 0.5),
          Offset(0.35, 0.85),
          Offset(0.15, 0.85),
        ],
        [
          Offset(0.5, 0.3),
          Offset(0.65, 0.3),
          Offset(0.5, 0.85),
          Offset(0.65, 0.85),
        ],
        [
          Offset(0.85, 0.3),
          Offset(0.72, 0.45),
          Offset(0.85, 0.6),
          Offset(0.72, 0.85),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'E',
      word: 'Eper',
      emoji: '🍓',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.25, 0.85)],
        [Offset(0.25, 0.15), Offset(0.75, 0.15)],
        [Offset(0.25, 0.5), Offset(0.65, 0.5)],
        [Offset(0.25, 0.85), Offset(0.75, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'É',
      word: 'Érem',
      emoji: '🥇',
      strokes: [
        [Offset(0.25, 0.22), Offset(0.25, 0.85)],
        [Offset(0.25, 0.22), Offset(0.75, 0.22)],
        [Offset(0.25, 0.53), Offset(0.65, 0.53)],
        [Offset(0.25, 0.85), Offset(0.75, 0.85)],
        [Offset(0.42, 0.12), Offset(0.62, 0.05)],
      ],
    ),
    AlphabetLetter(
      letter: 'F',
      word: 'Fa',
      emoji: '🌳',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.25, 0.85)],
        [Offset(0.25, 0.15), Offset(0.75, 0.15)],
        [Offset(0.25, 0.5), Offset(0.65, 0.5)],
      ],
    ),
    AlphabetLetter(
      letter: 'G',
      word: 'Gomba',
      emoji: '🍄',
      strokes: [
        [
          Offset(0.75, 0.25),
          Offset(0.5, 0.15),
          Offset(0.25, 0.35),
          Offset(0.25, 0.65),
          Offset(0.5, 0.85),
          Offset(0.75, 0.85),
          Offset(0.75, 0.5),
          Offset(0.55, 0.5),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'Gy',
      word: 'Gyűrű',
      emoji: '💍',
      strokes: [
        [
          Offset(0.5, 0.25),
          Offset(0.35, 0.15),
          Offset(0.18, 0.35),
          Offset(0.18, 0.65),
          Offset(0.35, 0.85),
          Offset(0.5, 0.85),
          Offset(0.5, 0.55),
          Offset(0.35, 0.55),
        ],
        [Offset(0.65, 0.25), Offset(0.75, 0.55)],
        [Offset(0.85, 0.25), Offset(0.65, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'H',
      word: 'Ház',
      emoji: '🏠',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.25, 0.85)],
        [Offset(0.75, 0.15), Offset(0.75, 0.85)],
        [Offset(0.25, 0.5), Offset(0.75, 0.5)],
      ],
    ),
    AlphabetLetter(
      letter: 'I',
      word: 'Iskola',
      emoji: '🏫',
      strokes: [
        [Offset(0.5, 0.15), Offset(0.5, 0.85)],
        [Offset(0.3, 0.15), Offset(0.7, 0.15)],
        [Offset(0.3, 0.85), Offset(0.7, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'Í',
      word: 'Íj',
      emoji: '🏹',
      strokes: [
        [Offset(0.5, 0.22), Offset(0.5, 0.85)],
        [Offset(0.3, 0.22), Offset(0.7, 0.22)],
        [Offset(0.3, 0.85), Offset(0.7, 0.85)],
        [Offset(0.42, 0.12), Offset(0.58, 0.05)],
      ],
    ),
    AlphabetLetter(
      letter: 'J',
      word: 'Játék',
      emoji: '🧸',
      strokes: [
        [Offset(0.3, 0.15), Offset(0.7, 0.15)],
        [
          Offset(0.6, 0.15),
          Offset(0.6, 0.7),
          Offset(0.5, 0.85),
          Offset(0.3, 0.8),
          Offset(0.25, 0.65),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'K',
      word: 'Kutya',
      emoji: '🐶',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.25, 0.85)],
        [Offset(0.75, 0.15), Offset(0.25, 0.5)],
        [Offset(0.35, 0.42), Offset(0.75, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'L',
      word: 'Labda',
      emoji: '⚽',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.25, 0.85)],
        [Offset(0.25, 0.85), Offset(0.75, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'Ly',
      word: 'Lyuk',
      emoji: '🕳️',
      strokes: [
        [Offset(0.2, 0.15), Offset(0.2, 0.85)],
        [Offset(0.2, 0.85), Offset(0.5, 0.85)],
        [Offset(0.6, 0.25), Offset(0.72, 0.55)],
        [Offset(0.85, 0.25), Offset(0.65, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'M',
      word: 'Maci',
      emoji: '🐻',
      strokes: [
        [Offset(0.2, 0.85), Offset(0.2, 0.15)],
        [Offset(0.2, 0.15), Offset(0.5, 0.55)],
        [Offset(0.5, 0.55), Offset(0.8, 0.15)],
        [Offset(0.8, 0.15), Offset(0.8, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'N',
      word: 'Nap',
      emoji: '☀️',
      strokes: [
        [Offset(0.25, 0.85), Offset(0.25, 0.15)],
        [Offset(0.25, 0.15), Offset(0.75, 0.85)],
        [Offset(0.75, 0.85), Offset(0.75, 0.15)],
      ],
    ),
    AlphabetLetter(
      letter: 'Ny',
      word: 'Nyúl',
      emoji: '🐰',
      strokes: [
        [Offset(0.18, 0.85), Offset(0.18, 0.2)],
        [Offset(0.18, 0.2), Offset(0.5, 0.85)],
        [Offset(0.5, 0.85), Offset(0.5, 0.2)],
        [Offset(0.62, 0.25), Offset(0.72, 0.55)],
        [Offset(0.85, 0.25), Offset(0.65, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'O',
      word: 'Orvos',
      emoji: '🩺',
      strokes: [
        [
          Offset(0.5, 0.15),
          Offset(0.78, 0.25),
          Offset(0.85, 0.5),
          Offset(0.78, 0.75),
          Offset(0.5, 0.85),
          Offset(0.22, 0.75),
          Offset(0.15, 0.5),
          Offset(0.22, 0.25),
          Offset(0.5, 0.15),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'Ó',
      word: 'Óceán',
      emoji: '🌊',
      strokes: [
        [
          Offset(0.5, 0.22),
          Offset(0.78, 0.32),
          Offset(0.85, 0.55),
          Offset(0.78, 0.78),
          Offset(0.5, 0.88),
          Offset(0.22, 0.78),
          Offset(0.15, 0.55),
          Offset(0.22, 0.32),
          Offset(0.5, 0.22),
        ],
        [Offset(0.42, 0.12), Offset(0.58, 0.05)],
      ],
    ),
    AlphabetLetter(
      letter: 'Ö',
      word: 'Öv',
      emoji: '🥋',
      strokes: [
        [
          Offset(0.5, 0.25),
          Offset(0.78, 0.35),
          Offset(0.85, 0.58),
          Offset(0.78, 0.8),
          Offset(0.5, 0.88),
          Offset(0.22, 0.8),
          Offset(0.15, 0.58),
          Offset(0.22, 0.35),
          Offset(0.5, 0.25),
        ],
        [Offset(0.38, 0.12), Offset(0.42, 0.12)],
        [Offset(0.58, 0.12), Offset(0.62, 0.12)],
      ],
    ),
    AlphabetLetter(
      letter: 'Ő',
      word: 'Őzike',
      emoji: '🦌',
      strokes: [
        [
          Offset(0.5, 0.25),
          Offset(0.78, 0.35),
          Offset(0.85, 0.58),
          Offset(0.78, 0.8),
          Offset(0.5, 0.88),
          Offset(0.22, 0.8),
          Offset(0.15, 0.58),
          Offset(0.22, 0.35),
          Offset(0.5, 0.25),
        ],
        [Offset(0.35, 0.15), Offset(0.45, 0.05)],
        [Offset(0.55, 0.15), Offset(0.65, 0.05)],
      ],
    ),
    AlphabetLetter(
      letter: 'P',
      word: 'Pillangó',
      emoji: '🦋',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.25, 0.85)],
        [
          Offset(0.25, 0.15),
          Offset(0.65, 0.15),
          Offset(0.78, 0.32),
          Offset(0.65, 0.5),
          Offset(0.25, 0.5),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'Q',
      word: 'Quad',
      emoji: '🏍️',
      strokes: [
        [
          Offset(0.5, 0.15),
          Offset(0.78, 0.25),
          Offset(0.85, 0.5),
          Offset(0.78, 0.75),
          Offset(0.5, 0.85),
          Offset(0.22, 0.75),
          Offset(0.15, 0.5),
          Offset(0.22, 0.25),
          Offset(0.5, 0.15),
        ],
        [Offset(0.55, 0.65), Offset(0.8, 0.9)],
      ],
    ),
    AlphabetLetter(
      letter: 'R',
      word: 'Róka',
      emoji: '🦊',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.25, 0.85)],
        [
          Offset(0.25, 0.15),
          Offset(0.65, 0.15),
          Offset(0.75, 0.32),
          Offset(0.65, 0.5),
          Offset(0.25, 0.5),
        ],
        [Offset(0.55, 0.5), Offset(0.75, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'S',
      word: 'Sün',
      emoji: '🦔',
      strokes: [
        [
          Offset(0.75, 0.25),
          Offset(0.55, 0.15),
          Offset(0.35, 0.25),
          Offset(0.45, 0.45),
          Offset(0.65, 0.55),
          Offset(0.7, 0.75),
          Offset(0.5, 0.85),
          Offset(0.25, 0.75),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'Sz',
      word: 'Szilva',
      emoji: '🫐',
      strokes: [
        [
          Offset(0.48, 0.25),
          Offset(0.35, 0.15),
          Offset(0.2, 0.25),
          Offset(0.3, 0.45),
          Offset(0.42, 0.55),
          Offset(0.45, 0.75),
          Offset(0.32, 0.85),
          Offset(0.18, 0.75),
        ],
        [
          Offset(0.58, 0.25),
          Offset(0.82, 0.25),
          Offset(0.58, 0.85),
          Offset(0.82, 0.85),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'T',
      word: 'Teknős',
      emoji: '🐢',
      strokes: [
        [Offset(0.2, 0.15), Offset(0.8, 0.15)],
        [Offset(0.5, 0.15), Offset(0.5, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'Ty',
      word: 'Tyúk',
      emoji: '🐔',
      strokes: [
        [Offset(0.15, 0.15), Offset(0.55, 0.15)],
        [Offset(0.35, 0.15), Offset(0.35, 0.85)],
        [Offset(0.62, 0.25), Offset(0.72, 0.55)],
        [Offset(0.85, 0.25), Offset(0.65, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'U',
      word: 'Utazás',
      emoji: '🚗',
      strokes: [
        [
          Offset(0.25, 0.15),
          Offset(0.25, 0.65),
          Offset(0.5, 0.85),
          Offset(0.75, 0.65),
          Offset(0.75, 0.15),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'Ú',
      word: 'Újság',
      emoji: '📰',
      strokes: [
        [
          Offset(0.25, 0.22),
          Offset(0.25, 0.68),
          Offset(0.5, 0.88),
          Offset(0.75, 0.68),
          Offset(0.75, 0.22),
        ],
        [Offset(0.42, 0.12), Offset(0.58, 0.05)],
      ],
    ),
    AlphabetLetter(
      letter: 'Ü',
      word: 'Üveg',
      emoji: '🥛',
      strokes: [
        [
          Offset(0.25, 0.25),
          Offset(0.25, 0.68),
          Offset(0.5, 0.88),
          Offset(0.75, 0.68),
          Offset(0.75, 0.25),
        ],
        [Offset(0.38, 0.12), Offset(0.42, 0.12)],
        [Offset(0.58, 0.12), Offset(0.62, 0.12)],
      ],
    ),
    AlphabetLetter(
      letter: 'Ű',
      word: 'Űrhajó',
      emoji: '🚀',
      strokes: [
        [
          Offset(0.25, 0.25),
          Offset(0.25, 0.68),
          Offset(0.5, 0.88),
          Offset(0.75, 0.68),
          Offset(0.75, 0.25),
        ],
        [Offset(0.35, 0.15), Offset(0.45, 0.05)],
        [Offset(0.55, 0.15), Offset(0.65, 0.05)],
      ],
    ),
    AlphabetLetter(
      letter: 'V',
      word: 'Virág',
      emoji: '🌸',
      strokes: [
        [Offset(0.2, 0.15), Offset(0.5, 0.85)],
        [Offset(0.5, 0.85), Offset(0.8, 0.15)],
      ],
    ),
    AlphabetLetter(
      letter: 'W',
      word: 'Wagon',
      emoji: '🚃',
      strokes: [
        [Offset(0.15, 0.15), Offset(0.32, 0.85)],
        [Offset(0.32, 0.85), Offset(0.5, 0.35)],
        [Offset(0.5, 0.35), Offset(0.68, 0.85)],
        [Offset(0.68, 0.85), Offset(0.85, 0.15)],
      ],
    ),
    AlphabetLetter(
      letter: 'X',
      word: 'Xilofon',
      emoji: '🎼',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.75, 0.85)],
        [Offset(0.75, 0.15), Offset(0.25, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'Y',
      word: 'Yacht',
      emoji: '🛥️',
      strokes: [
        [Offset(0.25, 0.15), Offset(0.5, 0.5)],
        [Offset(0.75, 0.15), Offset(0.5, 0.5)],
        [Offset(0.5, 0.5), Offset(0.5, 0.85)],
      ],
    ),
    AlphabetLetter(
      letter: 'Z',
      word: 'Zebra',
      emoji: '🦓',
      strokes: [
        [
          Offset(0.25, 0.15),
          Offset(0.75, 0.15),
          Offset(0.25, 0.85),
          Offset(0.75, 0.85),
        ],
      ],
    ),
    AlphabetLetter(
      letter: 'Zs',
      word: 'Zsiráf',
      emoji: '🦒',
      strokes: [
        [
          Offset(0.18, 0.25),
          Offset(0.48, 0.25),
          Offset(0.18, 0.85),
          Offset(0.48, 0.85),
        ],
        [
          Offset(0.82, 0.25),
          Offset(0.68, 0.18),
          Offset(0.58, 0.3),
          Offset(0.65, 0.5),
          Offset(0.8, 0.6),
          Offset(0.82, 0.75),
          Offset(0.68, 0.85),
          Offset(0.55, 0.78),
        ],
      ],
    ),
  ];

  AlphabetLetter get _current => _alphabet[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _alphabet.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentLetter();
    });
  }

  void _speakCurrentLetter() {
    final spokenLetter = (_current.letter == 'A') ? 'a' : _current.letter;
    AudioService.instance.speakOrPlay(
      text: '$spokenLetter... mint ${_current.word}!',
      audioPath: 'assets/audio/words/${_current.audioFileName}',
    );
  }

  bool _validateStrokes() {
    final allPoints = <Offset>[];
    for (final stroke in _userStrokes) {
      allPoints.addAll(stroke);
    }
    allPoints.addAll(_currentStroke);

    if (allPoints.length < 20) return false;

    int accuratePoints = 0;
    for (final pt in allPoints) {
      bool isClose = false;
      for (final stroke in _current.strokes) {
        if (stroke.isEmpty) continue;
        for (int i = 0; i < stroke.length - 1; i++) {
          final p1 = Offset(
            stroke[i].dx * _canvasSize.width,
            stroke[i].dy * _canvasSize.height,
          );
          final p2 = Offset(
            stroke[i + 1].dx * _canvasSize.width,
            stroke[i + 1].dy * _canvasSize.height,
          );
          final dist = _pointToSegmentDistance(pt, p1, p2);
          if (dist < 40) {
            isClose = true;
            break;
          }
        }
        if (isClose) break;
      }
      if (isClose) accuratePoints++;
    }

    final accuracyRatio = accuratePoints / allPoints.length;
    return accuracyRatio >= 0.40;
  }

  double _pointToSegmentDistance(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    double t =
        (ap.dx * ab.dx + ap.dy * ab.dy) / (ab.dx * ab.dx + ab.dy * ab.dy);
    t = t.clamp(0.0, 1.0);
    final closest = a + ab * t;
    return (p - closest).distance;
  }

  void _finishLetter() {
    if (!_validateStrokes()) {
      // Saját felvett hibahang lejátszása
      AudioService.instance.speakOrPlay(
        text: 'Próbáld meg követni a vonalat!',
        audioPath: 'assets/audio/words/probald_meg_kovetni_a_vonalat.mp3',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Próbáld meg pontosabban követni a szürke vonalat! ✍️'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF64748B),
        ),
      );
      return;
    }

    _completedLettersCount++;
    final earnedStar = (_completedLettersCount % 3 == 0);
    if (earnedStar) {
      context.read<RewardProvider>().addStars(1);
    }

    // Saját felvett sikerhang lejátszása
    AudioService.instance.speakOrPlay(
      text: 'Hurrá! Nagyon ügyes vagy!',
      audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
    );

    GameSuccessDialog.show(
      context,
      title: 'Szép betűírás! ✍️',
      message:
          'Sikeresen átrajzoltad a(z) "${_current.letter}" betűt (${_current.word})!',
      earnedStar: earnedStar,
      audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
      onNext: () {
        setState(() {
          _userStrokes.clear();
          _currentStroke.clear();
          _currentIndex = (_currentIndex + 1) % _alphabet.length;
        });
        _speakCurrentLetter();
      },
    );
  }

  void _showLetterPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Válassz egy betűt a gyakorláshoz (44 betű):',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFF8FAFC)
                      : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: _alphabet.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, idx) {
                    final item = _alphabet[idx];
                    final isSelected = idx == _currentIndex;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _userStrokes.clear();
                          _currentStroke.clear();
                          _currentIndex = idx;
                        });
                        _speakCurrentLetter();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : (isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1D4ED8)
                                : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1)),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.letter,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                          ? const Color(0xFFF8FAFC)
                                          : const Color(0xFF1E293B)),
                              ),
                            ),
                            Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 11),
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
        );
      },
    );
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
          'Betűíró Vonalvezető ✍️',
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
          padding: const EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
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
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E3A8A).withValues(alpha: 0.5)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF93C5FD),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _current.letter,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_current.emoji} ${_current.word}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFF8FAFC)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'ABC Betű: ${_currentIndex + 1} / ${_alphabet.length}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.grid_view_rounded,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                      tooltip: 'Betűválasztó',
                      onPressed: _showLetterPicker,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        size: 20,
                      ),
                      tooltip: 'Újrarajzolás',
                      onPressed: () {
                        setState(() {
                          _userStrokes.clear();
                          _currentStroke.clear();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: Color(0xFF16A34A),
                        size: 20,
                      ),
                      onPressed: _speakCurrentLetter,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _canvasSize = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
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
                            painter: _LetterPainter(
                              strokes: _current.strokes,
                              userStrokes: _userStrokes,
                              currentStroke: _currentStroke,
                              isDark: isDark,
                            ),
                            size: Size.infinite,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Kész vagyok a betűvel!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: _finishLetter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LetterPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<List<Offset>> userStrokes;
  final List<Offset> currentStroke;
  final bool isDark;

  _LetterPainter({
    required this.strokes,
    required this.userStrokes,
    required this.currentStroke,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerGuidePaint = Paint()
      ..color = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path();
      path.moveTo(stroke.first.dx * size.width, stroke.first.dy * size.height);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx * size.width, stroke[i].dy * size.height);
      }
      canvas.drawPath(path, guidePaint);
      canvas.drawPath(path, centerGuidePaint);
    }

    final userPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in userStrokes) {
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 6, userPaint);
      } else {
        for (int i = 0; i < stroke.length - 1; i++) {
          canvas.drawLine(stroke[i], stroke[i + 1], userPaint);
        }
      }
    }

    if (currentStroke.length == 1) {
      canvas.drawCircle(currentStroke.first, 6, userPaint);
    } else {
      for (int i = 0; i < currentStroke.length - 1; i++) {
        canvas.drawLine(currentStroke[i], currentStroke[i + 1], userPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LetterPainter oldDelegate) => true;
}
