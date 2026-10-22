import 'dart:io';
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

class WordMatchGameScreen extends StatefulWidget {
  const WordMatchGameScreen({super.key});

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  final List<WordQuestion> _baseQuestions = const [
    WordQuestion(
      word: 'Cipő',
      pictoEmoji: '👟',
      options: ['Kabát', 'Cipő', 'Zokni'],
    ),
    WordQuestion(
      word: 'Alma',
      pictoEmoji: '🍎',
      audioPath: 'assets/audio/words/alma.mp3',
      options: ['Kenyér', 'Alma', 'Labda'],
    ),
    WordQuestion(
      word: 'Fogkefe',
      pictoEmoji: '🪥',
      options: ['Fogkefe', 'Szappan', 'Fésű'],
    ),
    WordQuestion(
      word: 'Kabát',
      pictoEmoji: '🧥',
      options: ['Póló', 'Nadrág', 'Kabát'],
    ),
    WordQuestion(
      word: 'Autó',
      pictoEmoji: '🚗',
      audioPath: 'assets/audio/words/auto.mp3',
      options: ['Autó', 'Vonat', 'Bicikli'],
    ),
    WordQuestion(
      word: 'Könyv',
      pictoEmoji: '📖',
      options: ['Füzet', 'Könyv', 'Levél'],
    ),
    WordQuestion(
      word: 'Víz',
      pictoEmoji: '💧',
      options: ['Tej', 'Víz', 'Gyümölcslé'],
    ),
    WordQuestion(
      word: 'Ágy',
      pictoEmoji: '🛏️',
      options: ['Asztal', 'Szék', 'Ágy'],
    ),
    WordQuestion(
      word: 'Tányér',
      pictoEmoji: '🍽️',
      options: ['Tányér', 'Pohár', 'Bögre'],
    ),
    WordQuestion(
      word: 'Hátizsák',
      pictoEmoji: '🎒',
      options: ['Kabát', 'Hátizsák', 'Tolltartó'],
    ),
    WordQuestion(
      word: 'Napocska',
      pictoEmoji: '☀️',
      options: ['Felhő', 'Hold', 'Napocska'],
    ),
    WordQuestion(
      word: 'Ceruza',
      pictoEmoji: '✏️',
      options: ['Olló', 'Vonalzó', 'Ceruza'],
    ),
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

  void _buildActiveQuestions() {
    final customTasks = context.read<CustomTaskProvider>().getTasksByCategory(
      'Kép és Szó',
    );

    final List<WordQuestion> merged = List.from(_baseQuestions);

    final List<String> allBaseWords = _baseQuestions
        .map((q) => q.word)
        .toList();

    for (final task in customTasks) {
      final fakeOptions = List<String>.from(allBaseWords)
        ..removeWhere((w) => w.toLowerCase() == task.title.toLowerCase());
      fakeOptions.shuffle();

      final opts = [
        task.title,
        fakeOptions.isNotEmpty ? fakeOptions[0] : 'Labda',
        fakeOptions.length > 1 ? fakeOptions[1] : 'Cipő',
      ]..shuffle();

      merged.add(
        WordQuestion(
          word: task.title,
          imagePath: task.imagePath,
          audioPath: task.audioPath,
          options: opts,
        ),
      );
    }

    merged.shuffle();

    setState(() {
      _activeQuestions = merged;
      _currentIndex = 0;
      _selectedOption = null;
      _isAnswered = false;
    });
  }

  WordQuestion get _currentQuestion => _activeQuestions.isNotEmpty
      ? _activeQuestions[_currentIndex]
      : _baseQuestions[0];

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
    setState(() {
      _currentIndex = (_currentIndex + 1) % _activeQuestions.length;
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
        centerTitle: true,
        title: Text(
          'Kép és Szó Kaland 🧩',
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
