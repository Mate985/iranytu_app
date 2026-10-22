import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/custom_task_provider.dart';
import '../../services/audio_service.dart';
import '../widgets/app_picto.dart';
import '../widgets/game_success_dialog.dart';
import 'calm_room_screen.dart';
import 'number_trace_screen.dart';

enum GameTabMode { explore, quiz }

enum QuizTaskType { countItems, listenAndFind, neighbors }

class _CountableItem {
  final String name;
  final String emoji;
  final String audioFile;

  const _CountableItem({
    required this.name,
    required this.emoji,
    required this.audioFile,
  });
}

class NumberExplorerGameScreen extends StatefulWidget {
  const NumberExplorerGameScreen({super.key});

  @override
  State<NumberExplorerGameScreen> createState() =>
      _NumberExplorerGameScreenState();
}

class _NumberExplorerGameScreenState extends State<NumberExplorerGameScreen> {
  GameTabMode _tabMode = GameTabMode.explore;
  QuizTaskType _quizType = QuizTaskType.countItems;

  int _maxRange = 20;
  int _pageOffset = 0;

  int _exploredNumber = 1;

  int _targetNumber = 5;
  int _baseNeighborNumber = 4;
  bool _isNextNeighbor = true;
  int _successStreak = 0;
  bool _isTransitioning = false;

  List<int> _shuffledPageNumbers = [];

  final Random _random = Random();

  final List<_CountableItem> _items = const [
    _CountableItem(
      name: 'sárgarépát',
      emoji: '🥕',
      audioFile: 'szamold_meg_hany_sargarepa.mp3',
    ),
    _CountableItem(
      name: 'almát',
      emoji: '🍎',
      audioFile: 'szamold_meg_hany_alma.mp3',
    ),
    _CountableItem(
      name: 'citromot',
      emoji: '🍋',
      audioFile: 'szamold_meg_hany_citrom.mp3',
    ),
    _CountableItem(
      name: 'eperkét',
      emoji: '🍓',
      audioFile: 'szamold_meg_hany_eper.mp3',
    ),
    _CountableItem(
      name: 'banánt',
      emoji: '🍌',
      audioFile: 'szamold_meg_hany_banan.mp3',
    ),
  ];
  late _CountableItem _currentFruit;

  @override
  void initState() {
    super.initState();
    _currentFruit = _items[0];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabMode == GameTabMode.explore) {
        _speakText(
          'Fedezd fel a számokat! Érints meg egy számot a táblán!',
          audioPath: 'assets/audio/words/fedezd_fel_a_szamokat.mp3',
        );
      } else {
        _generateQuizTask();
      }
    });
  }

  int get _pageSize => 10;

  void _updateShuffledNumbers() {
    final count = _calculateCurrentItemsCount();
    final list = List.generate(count, (i) => _pageOffset + i + 1);
    list.shuffle(_random);
    _shuffledPageNumbers = list;
  }

  void _onRangeChanged(int newRange) {
    setState(() {
      _maxRange = newRange;
      _pageOffset = 0;
      if (_maxRange > 20 && _quizType == QuizTaskType.countItems) {
        _quizType = QuizTaskType.listenAndFind;
      }
      if (_tabMode == GameTabMode.quiz) {
        _generateQuizTask();
      }
    });
  }

  void _generateQuizTask() {
    setState(() {
      _isTransitioning = false;
      _currentFruit = _items[_random.nextInt(_items.length)];

      if (_quizType == QuizTaskType.countItems) {
        _targetNumber = _random.nextInt(10) + 1;
        _pageOffset = 0;
        _speakText(
          'Számold meg, hány ${_currentFruit.name} látsz a képen!',
          audioPath: 'assets/audio/words/${_currentFruit.audioFile}',
        );
      } else if (_quizType == QuizTaskType.listenAndFind) {
        _targetNumber = _random.nextInt(_maxRange) + 1;
        _pageOffset = ((_targetNumber - 1) ~/ _pageSize) * _pageSize;
        // A kérdés hangja mindig lefut a te hangodon
        _speakText(
          'Keresd meg a(z) $_targetNumber számot a táblán!',
          audioPath: 'assets/audio/words/keresd_meg_ezt_a_szamot.mp3',
        );
      } else {
        _isNextNeighbor = _random.nextBool();
        if (_isNextNeighbor) {
          _baseNeighborNumber = _random.nextInt(_maxRange - 2) + 1;
          _targetNumber = _baseNeighborNumber + 1;
          _speakText(
            'Melyik szám jön a(z) $_baseNeighborNumber után?',
            audioPath: 'assets/audio/words/melyik_szam_jon_ezutan.mp3',
          );
        } else {
          _baseNeighborNumber = _random.nextInt(_maxRange - 2) + 2;
          _targetNumber = _baseNeighborNumber - 1;
          _speakText(
            'Melyik szám áll a(z) $_baseNeighborNumber előtt?',
            audioPath: 'assets/audio/words/melyik_szam_all_ezelott.mp3',
          );
        }
        _pageOffset = ((_targetNumber - 1) ~/ _pageSize) * _pageSize;
      }

      _updateShuffledNumbers();
    });
  }

  void _speakText(String text, {String? audioPath}) {
    // Ha van audioPath, azt játssza le, ha nincs, a Google TTS mondja be
    AudioService.instance.speakOrPlay(text: text, audioPath: audioPath);
  }

  void _onNumberTapped(int number) {
    if (_isTransitioning) return;

    // 1-10 között a saját felvételed, 10 felett Google TTS
    final audioPath = (number >= 1 && number <= 10)
        ? 'assets/audio/words/$number.mp3'
        : null;

    _speakText('$number', audioPath: audioPath);

    if (_tabMode == GameTabMode.explore) {
      setState(() {
        _exploredNumber = number;
      });
      return;
    }

    if (number == _targetNumber) {
      setState(() {
        _isTransitioning = true;
      });

      _successStreak++;
      final earnedStar = (_successStreak % 3 == 0);
      if (earnedStar) {
        context.read<RewardProvider>().addStars(1);
      }

      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        GameSuccessDialog.show(
          context,
          title: 'Eltaláltad a számot! 🎯',
          message: 'A helyes szám: $number volt!\nNagyon ügyesen számoltál!',
          earnedStar: earnedStar,
          audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
          onNext: _generateQuizTask,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Próbáld meg újra! Számold át vagy keresd még egyszer!',
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF64748B),
        ),
      );
    }
  }

  void _openNumberTrace(int numVal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NumberTraceScreen(number: numVal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customTasks = context.watch<CustomTaskProvider>().getTasksByCategory(
      'Beszélő Számtábla',
    );

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
          'Beszélő Számtábla',
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModeTab(
                        mode: GameTabMode.explore,
                        title: '🔍 Felfedező',
                        icon: Icons.explore_rounded,
                      ),
                    ),
                    Expanded(
                      child: _buildModeTab(
                        mode: GameTabMode.quiz,
                        title: '🎯 Kvíz',
                        icon: Icons.psychology_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRangeChip(20, '1–20 (Kezdő)'),
                  const SizedBox(width: 10),
                  _buildRangeChip(100, '1–100 (Haladó)'),
                ],
              ),
              const SizedBox(height: 10),
              if (_tabMode == GameTabMode.explore)
                _buildExploreHeader()
              else
                _buildQuizHeader(),
              const SizedBox(height: 10),
              if (_maxRange > 20) _buildPaginationControls(),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _calculateCurrentItemsCount(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                    itemBuilder: (context, index) {
                      final int numVal;
                      if (_tabMode == GameTabMode.quiz &&
                          _shuffledPageNumbers.length > index) {
                        numVal = _shuffledPageNumbers[index];
                      } else {
                        numVal = _pageOffset + index + 1;
                      }

                      if (numVal > _maxRange) return const SizedBox.shrink();

                      final isExplored =
                          _tabMode == GameTabMode.explore &&
                          _exploredNumber == numVal;

                      return _buildNumberTile(numVal, isExplored);
                    },
                  ),
                ),
              ),
              if (customTasks.isNotEmpty) ...[
                const SizedBox(height: 8),
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
                      const Icon(
                        Icons.star_outline_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Saját kártyák:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: customTasks.map((t) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  backgroundColor: isDark
                                      ? const Color(0xFF334155)
                                      : null,
                                  avatar: t.imagePath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(t.imagePath!),
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.touch_app_rounded,
                                          size: 16,
                                        ),
                                  label: Text(
                                    t.title,
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFF8FAFC)
                                          : null,
                                    ),
                                  ),
                                  onPressed: () => _speakText(
                                    t.title,
                                    audioPath: t.audioPath,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberTile(int numVal, bool isExplored) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isExplored
        ? const Color(0xFF38BDF8)
        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC));

    final borderColor = isExplored
        ? const Color(0xFF0284C7)
        : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1));

    final textColor = isExplored
        ? Colors.white
        : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B));

    return AnimatedScale(
      scale: isExplored ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Material(
        color: bgColor,
        elevation: isExplored ? 6 : 1,
        shadowColor: isExplored
            ? const Color(0xFF0284C7).withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onNumberTapped(numVal),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isExplored ? 2.5 : 1.2,
              ),
            ),
            child: Text(
              '$numVal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tens = _exploredNumber ~/ 10;
    final ones = _exploredNumber % 10;
    final canTrace = _exploredNumber <= 10;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0369A1).withValues(alpha: 0.35)
                  : const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF7DD3FC),
                width: 1.5,
              ),
            ),
            child: Text(
              '$_exploredNumber',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF0284C7),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kiválasztott szám',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    if (tens > 0)
                      _buildValueChip(
                        '${tens}x Tízes',
                        isDark
                            ? const Color(0xFF065F46)
                            : const Color(0xFFDCFCE7),
                        isDark
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFF15803D),
                      ),
                    _buildValueChip(
                      '${ones}x Egyes',
                      isDark
                          ? const Color(0xFF78350F)
                          : const Color(0xFFFEF3C7),
                      isDark
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFFB45309),
                    ),
                  ],
                ),
                if (canTrace) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _openNumberTrace(_exploredNumber),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          color: isDark
                              ? const Color(0xFFC084FC)
                              : const Color(0xFF9333EA),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Gyakorold az írását! ✍️',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFC084FC)
                                : const Color(0xFF9333EA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.volume_up_rounded,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
              size: 28,
            ),
            onPressed: () {
              final audioPath = (_exploredNumber >= 1 && _exploredNumber <= 10)
                  ? 'assets/audio/words/$_exploredNumber.mp3'
                  : null;
              _speakText('$_exploredNumber', audioPath: audioPath);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuizHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              if (_maxRange == 20)
                _buildQuizTypeChip(QuizTaskType.countItems, '🍎 Mennyiség'),
              _buildQuizTypeChip(QuizTaskType.listenAndFind, '👂 Keresd meg'),
              _buildQuizTypeChip(QuizTaskType.neighbors, '↔️ Szomszédok'),
            ],
          ),
          const SizedBox(height: 12),

          if (_quizType == QuizTaskType.countItems) ...[
            Text(
              'Hány ${_currentFruit.name} látsz?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(
                _targetNumber,
                (index) => AppPicto(emoji: _currentFruit.emoji, size: 36),
              ),
            ),
          ] else if (_quizType == QuizTaskType.listenAndFind) ...[
            Text(
              'Keresd meg a táblán ezt a számot: $_targetNumber',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF1E293B),
              ),
            ),
          ] else ...[
            Text(
              _isNextNeighbor
                  ? 'Melyik szám jön a(z) $_baseNeighborNumber után?'
                  : 'Melyik szám áll a(z) $_baseNeighborNumber előtt?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF1E293B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final start = _pageOffset + 1;
    final end = min(_pageOffset + _pageSize, _maxRange);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Előző 10'),
            onPressed: _pageOffset > 0
                ? () => setState(() {
                    _pageOffset -= _pageSize;
                    if (_tabMode == GameTabMode.quiz) {
                      _updateShuffledNumbers();
                    }
                  })
                : null,
          ),
          Text(
            '$start – $end / $_maxRange',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
          ),
          TextButton.icon(
            label: const Text('Következő 10'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            onPressed: (_pageOffset + _pageSize) < _maxRange
                ? () => setState(() {
                    _pageOffset += _pageSize;
                    if (_tabMode == GameTabMode.quiz) {
                      _updateShuffledNumbers();
                    }
                  })
                : null,
          ),
        ],
      ),
    );
  }

  int _calculateCurrentItemsCount() {
    final remaining = _maxRange - _pageOffset;
    return min(_pageSize, remaining > 0 ? remaining : 0);
  }

  Widget _buildModeTab({
    required GameTabMode mode,
    required String title,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _tabMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tabMode = mode;
          if (mode == GameTabMode.quiz) {
            _generateQuizTask();
          } else {
            final audioPath = (_exploredNumber >= 1 && _exploredNumber <= 10)
                ? 'assets/audio/words/$_exploredNumber.mp3'
                : null;
            _speakText('$_exploredNumber', audioPath: audioPath);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF334155) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF38BDF8)
                  : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected
                    ? (isDark
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFF0F172A))
                    : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizTypeChip(QuizTaskType type, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _quizType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _quizType = type;
          _generateQuizTask();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? const Color(0xFF0369A1).withValues(alpha: 0.4)
                    : const Color(0xFFE0F2FE))
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0284C7) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1))
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeChip(int range, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _maxRange == range;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) _onRangeChanged(range);
      },
      selectedColor: const Color(0xFF0284C7),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: isSelected
            ? Colors.white
            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  Widget _buildValueChip(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textCol,
        ),
      ),
    );
  }
}
