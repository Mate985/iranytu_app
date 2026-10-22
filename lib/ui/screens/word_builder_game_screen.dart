import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/custom_task_provider.dart';
import '../../services/audio_service.dart';
import '../widgets/game_success_dialog.dart';
import 'calm_room_screen.dart';

class _WordPuzzleItem {
  final String word;
  final String emoji;
  final String? imagePath;
  final String? audioPath;

  const _WordPuzzleItem({
    required this.word,
    required this.emoji,
    this.imagePath,
    this.audioPath,
  });
}

class WordBuilderGameScreen extends StatefulWidget {
  const WordBuilderGameScreen({super.key});

  @override
  State<WordBuilderGameScreen> createState() => _WordBuilderGameScreenState();
}

class _WordBuilderGameScreenState extends State<WordBuilderGameScreen> {
  final List<_WordPuzzleItem> _defaultWords = const [
    _WordPuzzleItem(
      word: 'NAP',
      emoji: '☀️',
      audioPath: 'assets/audio/words/nap.mp3',
    ),
    _WordPuzzleItem(
      word: 'HÁZ',
      emoji: '🏠',
      audioPath: 'assets/audio/words/haz.mp3',
    ),
    _WordPuzzleItem(
      word: 'HAL',
      emoji: '🐟',
      audioPath: 'assets/audio/words/hal.mp3',
    ),
    _WordPuzzleItem(
      word: 'FA',
      emoji: '🌳',
      audioPath: 'assets/audio/words/fa.mp3',
    ),
    _WordPuzzleItem(
      word: 'ALMA',
      emoji: '🍎',
      audioPath: 'assets/audio/words/alma.mp3',
    ),
    _WordPuzzleItem(
      word: 'CICA',
      emoji: '🐱',
      audioPath: 'assets/audio/words/cica.mp3',
    ),
    _WordPuzzleItem(
      word: 'AUTÓ',
      emoji: '🚗',
      audioPath: 'assets/audio/words/auto.mp3',
    ),
    _WordPuzzleItem(
      word: 'MACI',
      emoji: '🐻',
      audioPath: 'assets/audio/words/maci.mp3',
    ),
    _WordPuzzleItem(
      word: 'LABDA',
      emoji: '⚽',
      audioPath: 'assets/audio/words/labda.mp3',
    ),
    _WordPuzzleItem(
      word: 'VIRÁG',
      emoji: '🌸',
      audioPath: 'assets/audio/words/virag.mp3',
    ),
  ];

  int _currentIndex = 0;
  int _completedWordsCount = 0;

  String _targetWord = '';
  String? _customImagePath;
  String? _currentAudioPath;
  String _emoji = '';

  List<String> _shuffledLetters = [];
  List<bool> _letterUsed = [];
  List<int> _placedLetterIndices = [];

  List<_WordPuzzleItem> _cachedTasks = [];
  final Random _random = Random();
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTasksAndLoad();
    });
  }

  void _initTasksAndLoad() {
    final customTasks = context.read<CustomTaskProvider>().getTasksByCategory(
      'Szókirakó',
    );

    final mappedCustom = customTasks.map((t) {
      return _WordPuzzleItem(
        word: t.title.toUpperCase().trim(),
        emoji: '⭐',
        imagePath: t.imagePath,
        audioPath: t.audioPath,
      );
    }).toList();

    final all = [..._defaultWords, ...mappedCustom]..shuffle(_random);
    _cachedTasks = all;
    _currentIndex = 0;

    _loadCurrentTask();
  }

  List<_WordPuzzleItem> _getAllTasks() {
    if (_cachedTasks.isNotEmpty) return _cachedTasks;
    return _defaultWords;
  }

  void _loadCurrentTask() {
    final allTasks = _getAllTasks();
    if (allTasks.isEmpty) return;

    if (_currentIndex >= allTasks.length) {
      _currentIndex = 0;
    }

    final currentTask = allTasks[_currentIndex];

    setState(() {
      _isTransitioning = false;
      _targetWord = currentTask.word.toUpperCase().trim();
      _emoji = currentTask.emoji;
      _customImagePath = currentTask.imagePath;
      _currentAudioPath = currentTask.audioPath;

      final letters = _targetWord.split('');

      const distractorPool = [
        'A',
        'Á',
        'B',
        'C',
        'D',
        'E',
        'É',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'Ó',
        'Ö',
        'P',
        'R',
        'S',
        'T',
        'U',
        'V',
        'Z',
      ];

      final extraLetters = <String>[];
      while (extraLetters.length < 2) {
        final candidate =
            distractorPool[_random.nextInt(distractorPool.length)];
        if (!letters.contains(candidate) && !extraLetters.contains(candidate)) {
          extraLetters.add(candidate);
        } else if (letters.length <= 3) {
          extraLetters.add(candidate);
        }
      }

      final allLetters = [...letters, ...extraLetters]..shuffle(_random);

      _shuffledLetters = allLetters;
      _letterUsed = List.filled(allLetters.length, false);
      _placedLetterIndices.clear();
    });

    _speakWord();
  }

  void _speakWord() {
    AudioService.instance.speakOrPlay(
      text: _targetWord,
      audioPath: _currentAudioPath,
    );
  }

  void _onLetterTap(int index) {
    if (_letterUsed[index] || _isTransitioning) return;

    final tappedLetter = _shuffledLetters[index];
    final nextTargetIndex = _placedLetterIndices.length;

    if (nextTargetIndex < _targetWord.length &&
        _targetWord[nextTargetIndex] == tappedLetter) {
      final letterAudio =
          'assets/audio/words/${tappedLetter.toLowerCase()}.mp3';
      AudioService.instance.speakOrPlay(
        text: tappedLetter,
        audioPath: letterAudio,
      );

      setState(() {
        _letterUsed[index] = true;
        _placedLetterIndices.add(index);
      });

      if (_placedLetterIndices.length == _targetWord.length) {
        setState(() {
          _isTransitioning = true;
        });

        Future.delayed(const Duration(milliseconds: 2200), () {
          if (!mounted) return;
          _speakWord();

          Future.delayed(const Duration(milliseconds: 2200), () {
            if (mounted) {
              _onWordCompleted();
            }
          });
        });
      }
    } else {
      AudioService.instance.speakOrPlay(
        text: 'Majdnem! Keresd a következő betűt!',
        audioPath: 'assets/audio/words/majdnem_keresd_a_kovetkezo_betut.mp3',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Majdnem! Keresd a következő betűt! 🌟'),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xFF64748B),
        ),
      );
    }
  }

  void _removeLastLetter() {
    if (_isTransitioning) return;
    if (_placedLetterIndices.isNotEmpty) {
      setState(() {
        final lastIdx = _placedLetterIndices.removeLast();
        _letterUsed[lastIdx] = false;
      });
    }
  }

  void _resetCurrentWord() {
    if (_isTransitioning) return;
    setState(() {
      _placedLetterIndices.clear();
      _letterUsed = List.filled(_shuffledLetters.length, false);
    });
    _speakWord();
  }

  void _onWordCompleted() {
    _completedWordsCount++;
    final earnedStar = (_completedWordsCount % 3 == 0);
    if (earnedStar) {
      context.read<RewardProvider>().addStars(1);
    }

    GameSuccessDialog.show(
      context,
      title: 'Nagyon szuper vagy! 🔤',
      message: 'Sikeresen kiraktad a szót: $_targetWord!',
      earnedStar: earnedStar,
      audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
      onNext: () {
        final allTasks = _getAllTasks();
        setState(() {
          _currentIndex = (_currentIndex + 1) % allTasks.length;
        });
        _loadCurrentTask();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTasks = _getAllTasks();

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
          'Szókirakó Kaland 🔤',
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
          padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 12.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.03,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Szó: ${_currentIndex + 1} / ${allTasks.length}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.refresh_rounded,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                              tooltip: 'Újrakezdés',
                              onPressed: _resetCurrentWord,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.volume_up_rounded,
                                color: Color(0xFF16A34A),
                                size: 28,
                              ),
                              tooltip: 'Szó meghallgatása',
                              onPressed: _speakWord,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _speakWord,
                      child: Container(
                        width: 130,
                        height: 130,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: _customImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  File(_customImagePath!),
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                _emoji,
                                style: const TextStyle(fontSize: 64),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_targetWord.length, (idx) {
                      final hasLetter = idx < _placedLetterIndices.length;
                      final letterChar = hasLetter
                          ? _shuffledLetters[_placedLetterIndices[idx]]
                          : '';

                      return GestureDetector(
                        onTap:
                            (hasLetter &&
                                idx == _placedLetterIndices.length - 1)
                            ? _removeLastLetter
                            : null,
                        child: Container(
                          width: 46,
                          height: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: hasLetter
                                ? (isDark
                                      ? const Color(
                                          0xFF1E3A8A,
                                        ).withValues(alpha: 0.5)
                                      : const Color(0xFFEFF6FF))
                                : (isDark
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: hasLetter
                                  ? const Color(0xFF3B82F6)
                                  : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1)),
                              width: hasLetter ? 2 : 1.5,
                            ),
                          ),
                          child: Text(
                            letterChar,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : const Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Rakd ki a szót! Érintsd meg a betűket sorban:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(_shuffledLetters.length, (index) {
                        final isUsed = _letterUsed[index];

                        return Opacity(
                          opacity: isUsed ? 0.25 : 1.0,
                          child: Material(
                            color: isUsed
                                ? (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0))
                                : const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(14),
                            elevation: isUsed ? 0 : 3,
                            child: InkWell(
                              onTap: isUsed ? null : () => _onLetterTap(index),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                child: Text(
                                  _shuffledLetters[index],
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isUsed
                                        ? (isDark
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFF94A3B8))
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
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
