import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/custom_task_provider.dart';
import '../../services/audio_service.dart';
import '../widgets/app_picto.dart';
import 'calm_room_screen.dart';
import '../widgets/game_success_dialog.dart';

class WordQuestion {
  final String word;
  final String pictoEmoji;
  final String? imagePath;
  final String? audioPath;
  final List<String> options;

  const WordQuestion({
    required this.word,
    this.pictoEmoji = '📌',
    this.imagePath,
    this.audioPath,
    required this.options,
  });
}

class _BaseWordItem {
  final String word;
  final String pictoEmoji;
  final String? audioPath;

  const _BaseWordItem({
    required this.word,
    required this.pictoEmoji,
    this.audioPath,
  });
}

class WordMatchGameScreen extends StatefulWidget {
  const WordMatchGameScreen({super.key});

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  final Random _random = Random();

  final List<_BaseWordItem> _baseWordPool = const [
    _BaseWordItem(word: 'Cipő', pictoEmoji: '👟'),
    _BaseWordItem(
      word: 'Alma',
      pictoEmoji: '🍎',
      audioPath: 'assets/audio/words/alma.mp3',
    ),
    _BaseWordItem(word: 'Fogkefe', pictoEmoji: '🪥'),
    _BaseWordItem(word: 'Kabát', pictoEmoji: '🧥'),
    _BaseWordItem(
      word: 'Autó',
      pictoEmoji: '🚗',
      audioPath: 'assets/audio/words/auto.mp3',
    ),
    _BaseWordItem(word: 'Könyv', pictoEmoji: '📖'),
    _BaseWordItem(word: 'Víz', pictoEmoji: '💧'),
    _BaseWordItem(word: 'Ágy', pictoEmoji: '🛏️'),
    _BaseWordItem(word: 'Tányér', pictoEmoji: '🍽️'),
    _BaseWordItem(word: 'Hátizsák', pictoEmoji: '🎒'),
    _BaseWordItem(word: 'Napocska', pictoEmoji: '☀️'),
    _BaseWordItem(word: 'Ceruza', pictoEmoji: '✏️'),
    _BaseWordItem(
      word: 'Labda',
      pictoEmoji: '⚽',
      audioPath: 'assets/audio/words/labda.mp3',
    ),
    _BaseWordItem(
      word: 'Cica',
      pictoEmoji: '🐱',
      audioPath: 'assets/audio/words/cica.mp3',
    ),
    _BaseWordItem(word: 'Kutya', pictoEmoji: '🐶'),
    _BaseWordItem(
      word: 'Maci',
      pictoEmoji: '🐻',
      audioPath: 'assets/audio/words/maci.mp3',
    ),
    _BaseWordItem(
      word: 'Virág',
      pictoEmoji: '🌸',
      audioPath: 'assets/audio/words/virag.mp3',
    ),
    _BaseWordItem(
      word: 'Hal',
      pictoEmoji: '🐟',
      audioPath: 'assets/audio/words/hal.mp3',
    ),
    _BaseWordItem(
      word: 'Ház',
      pictoEmoji: '🏠',
      audioPath: 'assets/audio/words/haz.mp3',
    ),
    _BaseWordItem(
      word: 'Fa',
      pictoEmoji: '🌳',
      audioPath: 'assets/audio/words/fa.mp3',
    ),
    _BaseWordItem(word: 'Banán', pictoEmoji: '🍌'),
    _BaseWordItem(word: 'Eper', pictoEmoji: '🍓'),
    _BaseWordItem(word: 'Vonat', pictoEmoji: '🚂'),
    _BaseWordItem(word: 'Bicikli', pictoEmoji: '🚲'),
    _BaseWordItem(word: 'Zokni', pictoEmoji: '🧦'),
    _BaseWordItem(word: 'Póló', pictoEmoji: '👕'),
    _BaseWordItem(word: 'Pohár', pictoEmoji: '🥛'),
    _BaseWordItem(word: 'Kenyér', pictoEmoji: '🍞'),
    _BaseWordItem(word: 'Szappan', pictoEmoji: '🧼'),
    _BaseWordItem(word: 'Hold', pictoEmoji: '🌙'),
  ];

  List<WordQuestion> _activeQuestions = [];
  int _currentIndex = 0;
  String? _selectedOption;
  bool _isAnswered = false;
  int _streakCount = 0;

  @override
  void initState() {
    super.initState();
    _buildActiveQuestions();
  }

  List<String> _generateRandomOptions(
    String correctWord,
    List<String> fullWordPool,
  ) {
    final distractors = List<String>.from(fullWordPool)
      ..removeWhere(
        (w) => w.trim().toLowerCase() == correctWord.trim().toLowerCase(),
      );
    distractors.shuffle(_random);

    final options = <String>[
      correctWord,
      if (distractors.isNotEmpty) distractors[0] else 'Labda',
      if (distractors.length > 1) distractors[1] else 'Cipő',
    ];
    options.shuffle(_random);
    return options;
  }

  void _buildActiveQuestions() {
    final customTasks = context.read<CustomTaskProvider>().getTasksByCategory(
      'Kép és Szó',
    );

    final allWords = <String>[
      ..._baseWordPool.map((e) => e.word),
      ...customTasks.map((t) => t.title.trim()),
    ];

    final List<WordQuestion> merged = [];

    for (final base in _baseWordPool) {
      merged.add(
        WordQuestion(
          word: base.word,
          pictoEmoji: base.pictoEmoji,
          audioPath: base.audioPath,
          options: _generateRandomOptions(base.word, allWords),
        ),
      );
    }

    for (final task in customTasks) {
      merged.add(
        WordQuestion(
          word: task.title.trim(),
          imagePath: task.imagePath,
          audioPath: task.audioPath,
          options: _generateRandomOptions(task.title.trim(), allWords),
        ),
      );
    }

    merged.shuffle(_random);

    setState(() {
      _activeQuestions = merged;
      _currentIndex = 0;
      _selectedOption = null;
      _isAnswered = false;
    });
  }

  WordQuestion get _currentQuestion => _activeQuestions.isNotEmpty
      ? _activeQuestions[_currentIndex]
      : WordQuestion(
          word: 'Cipő',
          pictoEmoji: '👟',
          options: _generateRandomOptions(
            'Cipő',
            _baseWordPool.map((e) => e.word).toList(),
          ),
        );

  void _onOptionSelected(String option) {
    if (_isAnswered) return;

    final isCorrect = option == _currentQuestion.word;

    setState(() {
      _selectedOption = option;
      _isAnswered = true;
    });

    if (isCorrect) {
      _streakCount++;
      final earnedStar = (_streakCount % 3 == 0);
      if (earnedStar) {
        context.read<RewardProvider>().addStars(1);
      }

      AudioService.instance.speakOrPlay(
        text: 'Hurrá, nagyon ügyes vagy!',
        audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
      );

      GameSuccessDialog.show(
        context,
        title: 'Eltaláltad! Szuper munka! 🎉',
        message:
            'Pontosan ez a(z) "${_currentQuestion.word}"!\nNagyon ügyesen választottál!',
        earnedStar: earnedStar,
        audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
        onNext: _nextQuestion,
      );
    } else {
      AudioService.instance.speakOrPlay(
        text: 'Nem baj, próbáljuk meg újra!',
        audioPath: 'assets/audio/words/nembaj_probaljuk_meg_ujra.mp3',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semmi baj, nézd meg jól a többi szót is! 🌟'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF64748B),
        ),
      );
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            _selectedOption = null;
            _isAnswered = false;
          });
        }
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _activeQuestions.length) {
      _buildActiveQuestions();
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _isAnswered = false;
    });
  }

  Widget _buildQuestionVisual(WordQuestion q) {
    if (q.imagePath != null && File(q.imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(q.imagePath!),
          width: 140,
          height: 140,
          fit: BoxFit.cover,
        ),
      );
    }
    return AppPicto(emoji: q.pictoEmoji, size: 96);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = _currentQuestion;

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
            'Kép és Szó Kaland 🧩',
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              size: 25,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuestionVisual(q),
                      const SizedBox(height: 10),
                      Text(
                        '${_currentIndex + 1} / ${_activeQuestions.length}',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mi látható a fenti képen? Érintsd meg a nevét!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFF8FAFC)
                      : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                flex: 5,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: q.options.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = q.options[index];
                    final isSelected = _selectedOption == option;
                    final isCorrect = isSelected && option == q.word;

                    Color btnBg;
                    if (isSelected) {
                      btnBg = isCorrect
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444);
                    } else {
                      btnBg = isDark ? const Color(0xFF1E293B) : Colors.white;
                    }

                    return SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnBg,
                          foregroundColor: isSelected
                              ? Colors.white
                              : (isDark
                                    ? const Color(0xFFF8FAFC)
                                    : const Color(0xFF1E293B)),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1)),
                              width: 1.5,
                            ),
                          ),
                        ),
                        onPressed: () => _onOptionSelected(option),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
