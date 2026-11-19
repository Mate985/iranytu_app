import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/reward_provider.dart';
import '../../services/audio_service.dart';
import '../widgets/parental_pin_dialog.dart';

class _MemoryPairItem {
  final String id;
  final String title;
  final String? ttsText;
  final String emoji;
  final String? imagePath;
  final String? audioPath;
  final bool isCustom;

  const _MemoryPairItem({
    required this.id,
    required this.title,
    this.ttsText,
    required this.emoji,
    this.imagePath,
    this.audioPath,
    this.isCustom = false,
  });

  String get spokenText => ttsText ?? title;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'ttsText': ttsText,
    'emoji': emoji,
    'imagePath': imagePath,
    'audioPath': audioPath,
    'isCustom': isCustom,
  };

  factory _MemoryPairItem.fromJson(Map<String, dynamic> json) {
    return _MemoryPairItem(
      id: json['id'] as String,
      title: json['title'] as String,
      ttsText: json['ttsText'] as String?,
      emoji: (json['emoji'] as String?) ?? '⭐',
      imagePath: json['imagePath'] as String?,
      audioPath: json['audioPath'] as String?,
      isCustom: (json['isCustom'] as bool?) ?? true,
    );
  }
}

class _MemoryBoardCard {
  final int instanceId;
  final _MemoryPairItem item;
  bool isFlipped = false;
  bool isMatched = false;

  _MemoryBoardCard({required this.instanceId, required this.item});
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  static const String _customPairsKey = 'custom_memory_pairs_v1';

  static const List<_MemoryPairItem> _defaultPool = [
    _MemoryPairItem(id: 'dog', title: 'Kutya', emoji: '🐶'),
    _MemoryPairItem(id: 'cat', title: 'Cica', emoji: '🐱'),
    _MemoryPairItem(id: 'apple', title: 'Alma', emoji: '🍎'),
    _MemoryPairItem(id: 'banana', title: 'Banán', emoji: '🍌'),
    _MemoryPairItem(id: 'car', title: 'Autó', emoji: '🚗'),
    _MemoryPairItem(id: 'ball', title: 'Labda', emoji: '⚽'),
    _MemoryPairItem(id: 'sun', title: 'Napocska', emoji: '☀️'),
    _MemoryPairItem(id: 'moon', title: 'Hold', emoji: '🌙'),
    _MemoryPairItem(id: 'star', title: 'Csillag', emoji: '⭐'),
    _MemoryPairItem(id: 'house', title: 'Házikó', emoji: '🏠'),
    _MemoryPairItem(id: 'tree', title: 'Fa', emoji: '🌳'),
    _MemoryPairItem(id: 'flower', title: 'Virág', emoji: '🌻'),
    _MemoryPairItem(id: 'fish', title: 'Halacska', emoji: '🐟'),
    _MemoryPairItem(id: 'bird', title: 'Madár', emoji: '🐦'),
    _MemoryPairItem(id: 'rabbit', title: 'Nyuszi', emoji: '🐰'),
    _MemoryPairItem(id: 'bear', title: 'Maci', emoji: '🐻'),
    _MemoryPairItem(id: 'lion', title: 'Oroszlán', emoji: '🦁'),
    _MemoryPairItem(id: 'elephant', title: 'Elefánt', emoji: '🐘'),
    _MemoryPairItem(id: 'frog', title: 'Béka', emoji: '🐸'),
    _MemoryPairItem(id: 'butterfly', title: 'Pillangó', emoji: '🦋'),
    _MemoryPairItem(id: 'strawberry', title: 'Eper', emoji: '🍓'),
    _MemoryPairItem(id: 'pear', title: 'Körte', emoji: '🍐'),
    _MemoryPairItem(id: 'carrot', title: 'Répa', emoji: '🥕'),
    _MemoryPairItem(id: 'icecream', title: 'Fagyi', emoji: '🍦'),
    _MemoryPairItem(id: 'train', title: 'Vonat', emoji: '🚂'),
    _MemoryPairItem(id: 'airplane', title: 'Repülő', emoji: '✈️'),
    _MemoryPairItem(id: 'boat', title: 'Hajó', emoji: '⛵'),
    _MemoryPairItem(id: 'bicycle', title: 'Bicikli', emoji: '🚲'),
    _MemoryPairItem(id: 'book', title: 'Könyv', emoji: '📖'),
    _MemoryPairItem(
      id: 'teddy',
      title: 'Plüssmaci',
      ttsText: 'plüss maci',
      emoji: '🧸',
    ),
  ];

  List<_MemoryPairItem> _customPairs = [];
  List<_MemoryBoardCard> _boardCards = [];
  int _pairCount = 2; // 2 -> 2x2, 4 -> 3x3, 6 -> 3x4
  int _moves = 0;
  int _matchedPairs = 0;
  bool _isChecking = false;
  bool _isMuted = false;
  _MemoryBoardCard? _firstSelected;

  @override
  void initState() {
    super.initState();
    _loadCustomPairsAndStart();
  }

  @override
  void dispose() {
    AudioService.instance.stopAll();
    super.dispose();
  }

  Future<void> _loadCustomPairsAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_customPairsKey) ?? [];
    final loaded = <_MemoryPairItem>[];
    for (final raw in rawList) {
      try {
        loaded.add(_MemoryPairItem.fromJson(jsonDecode(raw)));
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _customPairs = loaded;
    });
    _startNewRound();
  }

  Future<void> _saveCustomPairs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _customPairsKey,
      _customPairs.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  void _startNewRound() {
    final random = Random();
    final selectedItems = <_MemoryPairItem>[];

    final shuffledCustom = List<_MemoryPairItem>.from(_customPairs)
      ..shuffle(random);
    for (final custom in shuffledCustom) {
      if (selectedItems.length < (_pairCount ~/ 2).clamp(1, _pairCount)) {
        selectedItems.add(custom);
      }
    }

    final shuffledDefault = List<_MemoryPairItem>.from(_defaultPool)
      ..shuffle(random);
    for (final item in shuffledDefault) {
      if (selectedItems.length >= _pairCount) break;
      if (!selectedItems.any((e) => e.id == item.id)) {
        selectedItems.add(item);
      }
    }

    final deck = <_MemoryBoardCard>[];
    int idCounter = 0;
    for (final item in selectedItems) {
      deck.add(_MemoryBoardCard(instanceId: idCounter++, item: item));
      deck.add(_MemoryBoardCard(instanceId: idCounter++, item: item));
    }

    final cols = _pairCount == 2 ? 2 : 3;
    _shuffleWithoutAdjacentPairs(deck, cols, random);

    setState(() {
      _boardCards = deck;
      _moves = 0;
      _matchedPairs = 0;
      _firstSelected = null;
      _isChecking = false;
    });
  }

  void _shuffleWithoutAdjacentPairs(
    List<_MemoryBoardCard> deck,
    int cols,
    Random random,
  ) {
    for (int attempt = 0; attempt < 200; attempt++) {
      deck.shuffle(random);
      final strictCheck = attempt < 120;
      if (!_hasAdjacentIdenticalCards(
        deck,
        cols,
        checkDiagonals: strictCheck,
      )) {
        return;
      }
    }

    for (int i = 0; i < deck.length; i++) {
      if (_isCardAdjacentToMatch(deck, i, cols)) {
        for (int j = 0; j < deck.length; j++) {
          if (i == j || deck[i].item.id == deck[j].item.id) continue;
          final temp = deck[i];
          deck[i] = deck[j];
          deck[j] = temp;
          if (!_isCardAdjacentToMatch(deck, i, cols) &&
              !_isCardAdjacentToMatch(deck, j, cols)) {
            break;
          }
          deck[j] = deck[i];
          deck[i] = temp;
        }
      }
    }
  }

  bool _hasAdjacentIdenticalCards(
    List<_MemoryBoardCard> deck,
    int cols, {
    required bool checkDiagonals,
  }) {
    for (int i = 0; i < deck.length; i++) {
      if (_isCardAdjacentToMatch(
        deck,
        i,
        cols,
        checkDiagonals: checkDiagonals,
      )) {
        return true;
      }
    }
    return false;
  }

  bool _isCardAdjacentToMatch(
    List<_MemoryBoardCard> deck,
    int index,
    int cols, {
    bool checkDiagonals = false,
  }) {
    final row = index ~/ cols;
    final col = index % cols;
    final id = deck[index].item.id;

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        if (!checkDiagonals && dr != 0 && dc != 0) continue;

        final nr = row + dr;
        final nc = col + dc;
        if (nc < 0 || nc >= cols) continue;

        final neighborIndex = nr * cols + nc;
        if (neighborIndex >= 0 && neighborIndex < deck.length) {
          if (deck[neighborIndex].item.id == id) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<void> _onCardTap(_MemoryBoardCard card) async {
    if (_isChecking || card.isFlipped || card.isMatched) return;

    setState(() {
      card.isFlipped = true;
    });

    if (!_isMuted) {
      AudioService.instance.speakOrPlay(
        text: card.item.spokenText,
        audioPath: card.item.isCustom ? card.item.audioPath : null,
      );
    }

    if (_firstSelected == null) {
      _firstSelected = card;
      return;
    }

    final first = _firstSelected!;
    _firstSelected = null;
    _moves++;

    if (first.item.id == card.item.id) {
      setState(() {
        first.isMatched = true;
        card.isMatched = true;
        _matchedPairs++;
      });

      if (_matchedPairs >= _pairCount) {
        await Future.delayed(const Duration(milliseconds: 1400));
        if (mounted) {
          await _onGameWon();
        }
      }
    } else {
      setState(() {
        _isChecking = true;
      });
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        first.isFlipped = false;
        card.isFlipped = false;
        _isChecking = false;
      });
    }
  }

  Future<void> _onGameWon() async {
    await context.read<RewardProvider>().addStars(2);
    if (!_isMuted) {
      AudioService.instance.speakOrPlay(
        text: 'Ügyes vagy!',
        audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
      );
    }

    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉🏆🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Ügyes vagy!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minden pár megvan! ($_moves lépés)\n+2 csillag ⭐',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD97706),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Menü'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _startNewRound();
            },
            icon: const Icon(Icons.replay_rounded),
            label: const Text(
              'Új játék',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openParentCustomManager() async {
    final authorized = await ParentalPinDialog.show(context);
    if (!authorized || !mounted) return;

    final titleController = TextEditingController();
    String selectedEmoji = '🐶';
    String? pickedImagePath;
    String? recordedAudioPath;
    bool isRecording = false;

    const emojiChoices = [
      '🐶',
      '🐱',
      '🐰',
      '🦊',
      '🐻',
      '🐼',
      '🦁',
      '🐸',
      '🍎',
      '🍓',
      '🍕',
      '🍦',
      '🚗',
      '🚂',
      '🚀',
      '⚽',
      '🎸',
      '🧸',
      '👑',
      '🌈',
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
          final navBarPadding = MediaQuery.of(ctx).viewPadding.bottom;

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: bottomInset + navBarPadding + 28,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.extension_rounded,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Szülői saját memóriapárok (${_customPairs.length} db)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (isRecording) {
                              await AudioService.instance.stopRecording();
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Kártya neve (pl. Nagyi kutyusa)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final img = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 800,
                              maxHeight: 800,
                              imageQuality: 85,
                            );
                            if (img != null) {
                              setSheetState(() {
                                pickedImagePath = img.path;
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.photo_library_rounded,
                            size: 18,
                          ),
                          label: Text(
                            pickedImagePath == null
                                ? 'Saját fotó'
                                : 'Fotó kész ✅',
                          ),
                        ),
                        if (pickedImagePath != null)
                          IconButton(
                            tooltip: 'Fotó törlése',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                setSheetState(() => pickedImagePath = null),
                          ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRecording
                                ? const Color(0xFFEF4444)
                                : (recordedAudioPath != null
                                      ? const Color(0xFF0D9488)
                                      : const Color(0xFF6366F1)),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            if (isRecording) {
                              final path = await AudioService.instance
                                  .stopRecording();
                              setSheetState(() {
                                isRecording = false;
                                recordedAudioPath = path;
                              });
                            } else {
                              final started = await AudioService.instance
                                  .startRecording();
                              if (started) {
                                setSheetState(() {
                                  isRecording = true;
                                });
                              }
                            }
                          },
                          icon: Icon(
                            isRecording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isRecording
                                ? 'Leállítás...'
                                : (recordedAudioPath != null
                                      ? 'Hang kész 🎤'
                                      : 'Saját hang'),
                          ),
                        ),
                        if (recordedAudioPath != null && !isRecording) ...[
                          IconButton(
                            tooltip: 'Felvétel meghallgatása',
                            icon: const Icon(
                              Icons.play_circle_fill_rounded,
                              color: Color(0xFF16A34A),
                            ),
                            onPressed: () => AudioService.instance.playAudio(
                              recordedAudioPath!,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hang törlése',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                setSheetState(() => recordedAudioPath = null),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Vagy válassz ikont fotó helyett:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: emojiChoices.map((em) {
                        final isSelected =
                            selectedEmoji == em && pickedImagePath == null;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedEmoji = em;
                              pickedImagePath = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFDBEAFE)
                                  : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              em,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (isRecording) {
                            recordedAudioPath = await AudioService.instance
                                .stopRecording();
                            isRecording = false;
                          }
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          final newItem = _MemoryPairItem(
                            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                            title: title,
                            emoji: selectedEmoji,
                            imagePath: pickedImagePath,
                            audioPath: recordedAudioPath,
                            isCustom: true,
                          );
                          setState(() {
                            _customPairs.insert(0, newItem);
                          });
                          await _saveCustomPairs();
                          titleController.clear();
                          setSheetState(() {
                            pickedImagePath = null;
                            recordedAudioPath = null;
                          });
                          _startNewRound();
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text(
                          'Hozzáadás a memóriajátékhoz',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (_customPairs.isNotEmpty) ...[
                      const Divider(height: 24),
                      const Text(
                        'Felvett saját párok:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ..._customPairs.map((cp) {
                        final hasVoice =
                            cp.audioPath != null && cp.audioPath!.isNotEmpty;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading:
                              cp.imagePath != null &&
                                  File(cp.imagePath!).existsSync()
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(cp.imagePath!),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Text(
                                  cp.emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                          title: Text(
                            cp.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            hasVoice
                                ? '🎤 Saját hangfelvétellel'
                                : '🔊 Google TTS hanggal',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              setState(() {
                                _customPairs.removeWhere((e) => e.id == cp.id);
                              });
                              await _saveCustomPairs();
                              setSheetState(() {});
                              _startNewRound();
                            },
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFace(_MemoryBoardCard card, bool isDark) {
    final item = card.item;
    final hasCustomPhoto =
        item.imagePath != null && File(item.imagePath!).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: card.isMatched
            ? (isDark
                  ? const Color(0xFF065F46).withValues(alpha: 0.5)
                  : const Color(0xFFDCFCE7))
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: card.isMatched
              ? const Color(0xFF16A34A)
              : const Color(0xFF38BDF8),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Center(
                child: hasCustomPhoto
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(item.imagePath!),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 38),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A8A), const Color(0xFF1D4ED8)]
              : [const Color(0xFF38BDF8), const Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.question_mark_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildCenterSpacerTile(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.4)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Icon(
        Icons.star_rounded,
        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTwoByTwo = _pairCount == 2;
    final isThreeByThree = _pairCount == 4;
    final crossAxisCount = isTwoByTwo ? 2 : 3;
    final rowCount = isTwoByTwo ? 2 : (isThreeByThree ? 3 : 4);
    final gridItemCount = isThreeByThree ? 9 : _boardCards.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Memória Párkereső',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: _isMuted ? 'Hang be' : 'Némítás',
            icon: Icon(
              _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isMuted
                  ? const Color(0xFF64748B)
                  : const Color(0xFF16A34A),
            ),
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
              });
              if (_isMuted) {
                AudioService.instance.stopAll();
              }
            },
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Saját kártyapárok (Szülői)',
            icon: const Icon(
              Icons.add_photo_alternate_rounded,
              color: Color(0xFF0284C7),
            ),
            onPressed: _openParentCustomManager,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Új leosztás',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _startNewRound,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<int>(
                      showSelectedIcon: false,
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      segments: const [
                        ButtonSegment(
                          value: 2,
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '2×2',
                              style: TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ),
                        ButtonSegment(
                          value: 4,
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '3×3',
                              style: TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ),
                        ButtonSegment(
                          value: 6,
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '3×4',
                              style: TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ),
                      ],
                      selected: {_pairCount},
                      onSelectionChanged: (val) {
                        setState(() {
                          _pairCount = val.first;
                        });
                        _startNewRound();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_matchedPairs / $_pairCount pár',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0369A1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 10.0;
                    final availableWidth =
                        constraints.maxWidth - (crossAxisCount - 1) * spacing;
                    final availableHeight =
                        constraints.maxHeight - (rowCount - 1) * spacing;

                    final cellWidth = availableWidth / crossAxisCount;
                    final cellHeight = availableHeight / rowCount;
                    final aspectRatio = (cellWidth / cellHeight).clamp(
                      0.65,
                      2.2,
                    );

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gridItemCount,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: aspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        if (isThreeByThree && index == 4) {
                          return _buildCenterSpacerTile(isDark);
                        }

                        final cardIndex = (isThreeByThree && index > 4)
                            ? index - 1
                            : index;
                        final card = _boardCards[cardIndex];
                        final showFace = card.isFlipped || card.isMatched;

                        return GestureDetector(
                          onTap: () => _onCardTap(card),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: showFace
                                ? KeyedSubtree(
                                    key: ValueKey('face_${card.instanceId}'),
                                    child: _buildCardFace(card, isDark),
                                  )
                                : KeyedSubtree(
                                    key: ValueKey('back_${card.instanceId}'),
                                    child: _buildCardBack(isDark),
                                  ),
                          ),
                        );
                      },
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
