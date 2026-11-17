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

class _OddOption {
  final String label;
  final String? ttsText;
  final String emoji;
  final bool isOdd;
  final String? imagePath;
  final String? audioPath;

  const _OddOption({
    required this.label,
    this.ttsText,
    required this.emoji,
    required this.isOdd,
    this.imagePath,
    this.audioPath,
  });

  String get spokenText => ttsText ?? label;

  Map<String, dynamic> toJson() => {
    'label': label,
    'ttsText': ttsText,
    'emoji': emoji,
    'isOdd': isOdd,
    'imagePath': imagePath,
    'audioPath': audioPath,
  };

  factory _OddOption.fromJson(Map<String, dynamic> json) => _OddOption(
    label: json['label'] as String,
    ttsText: json['ttsText'] as String?,
    emoji: (json['emoji'] as String?) ?? '⭐',
    isOdd: json['isOdd'] as bool,
    imagePath: json['imagePath'] as String?,
    audioPath: json['audioPath'] as String?,
  );
}

class _OddPuzzle {
  final String id;
  final String prompt;
  final String explanation;
  final String? promptAudioPath;
  final List<_OddOption> options;
  final bool isCustom;

  const _OddPuzzle({
    required this.id,
    required this.prompt,
    required this.explanation,
    required this.options,
    this.promptAudioPath,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'prompt': prompt,
    'explanation': explanation,
    'promptAudioPath': promptAudioPath,
    'options': options.map((e) => e.toJson()).toList(),
    'isCustom': isCustom,
  };

  factory _OddPuzzle.fromJson(Map<String, dynamic> json) => _OddPuzzle(
    id: json['id'] as String,
    prompt: json['prompt'] as String,
    explanation: json['explanation'] as String,
    promptAudioPath: json['promptAudioPath'] as String?,
    options: (json['options'] as List)
        .map((e) => _OddOption.fromJson(e as Map<String, dynamic>))
        .toList(),
    isCustom: (json['isCustom'] as bool?) ?? true,
  );
}

class _EditableOptionDraft {
  final TextEditingController labelCtrl;
  String emoji;
  String? imagePath;
  String? audioPath;
  final bool isOdd;

  _EditableOptionDraft({
    required String initialLabel,
    required this.emoji,
    required this.isOdd,
  }) : labelCtrl = TextEditingController(text: initialLabel);
}

class OddOneOutGameScreen extends StatefulWidget {
  const OddOneOutGameScreen({super.key});

  @override
  State<OddOneOutGameScreen> createState() => _OddOneOutGameScreenState();
}

class _OddOneOutGameScreenState extends State<OddOneOutGameScreen> {
  static const String _customPuzzlesKey = 'custom_odd_one_out_puzzles_v2';
  static const int _questionsPerRound = 5;

  // Egységesen Google TTS-t használ az összes beépített feladvány,
  // a Plüssmaci pedig itt is fonetikus 'plüss maci' kiejtést kapott.
  static const List<_OddPuzzle> _defaultPuzzles = [
    _OddPuzzle(
      id: 'fruits_car',
      prompt: 'Melyik nem gyümölcs?',
      explanation: 'Az autó jármű, a többi pedig finom gyümölcs!',
      options: [
        _OddOption(label: 'Alma', emoji: '🍎', isOdd: false),
        _OddOption(label: 'Banán', emoji: '🍌', isOdd: false),
        _OddOption(label: 'Eper', emoji: '🍓', isOdd: false),
        _OddOption(label: 'Körte', emoji: '🍐', isOdd: false),
        _OddOption(label: 'Szőlő', emoji: '🍇', isOdd: false),
        _OddOption(label: 'Autó', emoji: '🚗', isOdd: true),
      ],
    ),
    _OddPuzzle(
      id: 'animals_ball',
      prompt: 'Melyik nem állat?',
      explanation: 'A labda játék, a többiek pedig állatok!',
      options: [
        _OddOption(label: 'Kutya', emoji: '🐶', isOdd: false),
        _OddOption(label: 'Cica', emoji: '🐱', isOdd: false),
        _OddOption(label: 'Nyuszi', emoji: '🐰', isOdd: false),
        _OddOption(label: 'Maci', emoji: '🐻', isOdd: false),
        _OddOption(label: 'Malac', emoji: '🐷', isOdd: false),
        _OddOption(label: 'Labda', emoji: '⚽', isOdd: true),
      ],
    ),
    _OddPuzzle(
      id: 'vehicles_pear',
      prompt: 'Melyik nem jármű?',
      explanation: 'A körte gyümölcs, a többivel pedig utazni lehet!',
      options: [
        _OddOption(label: 'Vonat', emoji: '🚂', isOdd: false),
        _OddOption(label: 'Repülő', emoji: '✈️', isOdd: false),
        _OddOption(label: 'Hajó', emoji: '⛵', isOdd: false),
        _OddOption(label: 'Autóbusz', emoji: '🚌', isOdd: false),
        _OddOption(label: 'Bicikli', emoji: '🚲', isOdd: false),
        _OddOption(label: 'Körte', emoji: '🍐', isOdd: true),
      ],
    ),
    _OddPuzzle(
      id: 'sky_fish',
      prompt: 'Mi nem az égen található?',
      explanation: 'A halacska a vízben úszik, nem az égen!',
      options: [
        _OddOption(label: 'Napocska', emoji: '☀️', isOdd: false),
        _OddOption(label: 'Hold', emoji: '🌙', isOdd: false),
        _OddOption(label: 'Csillag', emoji: '⭐', isOdd: false),
        _OddOption(label: 'Felhő', emoji: '☁️', isOdd: false),
        _OddOption(label: 'Szivárvány', emoji: '🌈', isOdd: false),
        _OddOption(label: 'Halacska', emoji: '🐟', isOdd: true),
      ],
    ),
    _OddPuzzle(
      id: 'clothes_carrot',
      prompt: 'Melyiket nem tudod felvenni?',
      explanation: 'A répa zöldség, a többi pedig ruhadarab!',
      options: [
        _OddOption(label: 'Póló', emoji: '👕', isOdd: false),
        _OddOption(label: 'Cipő', emoji: '👟', isOdd: false),
        _OddOption(label: 'Sapka', emoji: '🧢', isOdd: false),
        _OddOption(label: 'Zokni', emoji: '🧦', isOdd: false),
        _OddOption(label: 'Kesztyű', emoji: '🧤', isOdd: false),
        _OddOption(label: 'Répa', emoji: '🥕', isOdd: true),
      ],
    ),
    _OddPuzzle(
      id: 'plants_bus',
      prompt: 'Melyik nem növény?',
      explanation: 'A kisbusz jármű, a többi pedig növény!',
      options: [
        _OddOption(label: 'Fa', emoji: '🌳', isOdd: false),
        _OddOption(label: 'Napraforgó', emoji: '🌻', isOdd: false),
        _OddOption(label: 'Fenyőfa', emoji: '🌲', isOdd: false),
        _OddOption(label: 'Tulipán', emoji: '🌷', isOdd: false),
        _OddOption(label: 'Rózsa', emoji: '🌹', isOdd: false),
        _OddOption(label: 'Kisbusz', emoji: '🚌', isOdd: true),
      ],
    ),
    _OddPuzzle(
      id: 'music_cheese',
      prompt: 'Melyik nem hangszer?',
      explanation: 'A sajt ennivaló, a többivel zenélni lehet!',
      options: [
        _OddOption(label: 'Gitár', emoji: '🎸', isOdd: false),
        _OddOption(label: 'Dob', emoji: '🥁', isOdd: false),
        _OddOption(label: 'Zongora', emoji: '🎹', isOdd: false),
        _OddOption(label: 'Trombita', emoji: '🎺', isOdd: false),
        _OddOption(label: 'Hegedű', emoji: '🎻', isOdd: false),
        _OddOption(label: 'Sajt', emoji: '🧀', isOdd: true),
      ],
    ),
    _OddPuzzle(
      id: 'water_lion',
      prompt: 'Melyik nem vízben él?',
      explanation: 'Az oroszlán a szárazföldön él!',
      options: [
        _OddOption(label: 'Delfin', emoji: '🐬', isOdd: false),
        _OddOption(label: 'Hal', emoji: '🐠', isOdd: false),
        _OddOption(label: 'Polip', emoji: '🐙', isOdd: false),
        _OddOption(label: 'Bálna', emoji: '🐳', isOdd: false),
        _OddOption(label: 'Rák', emoji: '🦀', isOdd: false),
        _OddOption(label: 'Oroszlán', emoji: '🦁', isOdd: true),
      ],
    ),
    _OddPuzzle(
      id: 'flying_turtle',
      prompt: 'Melyik nem tud repülni?',
      explanation: 'A teknős lassan sétál, nem repül!',
      options: [
        _OddOption(label: 'Madár', emoji: '🐦', isOdd: false),
        _OddOption(label: 'Pillangó', emoji: '🦋', isOdd: false),
        _OddOption(label: 'Méhecske', emoji: '🐝', isOdd: false),
        _OddOption(label: 'Katica', emoji: '🐞', isOdd: false),
        _OddOption(label: 'Sas', emoji: '🦅', isOdd: false),
        _OddOption(label: 'Teknős', emoji: '🐢', isOdd: true),
      ],
    ),
    _OddPuzzle(
      id: 'vegetables_teddy',
      prompt: 'Melyik nem zöldség?',
      explanation: 'A plüss maci játék, nem zöldség!',
      options: [
        _OddOption(label: 'Brokkoli', emoji: '🥦', isOdd: false),
        _OddOption(label: 'Kukorica', emoji: '🌽', isOdd: false),
        _OddOption(label: 'Paradicsom', emoji: '🍅', isOdd: false),
        _OddOption(label: 'Répa', emoji: '🥕', isOdd: false),
        _OddOption(label: 'Uborka', emoji: '🥒', isOdd: false),
        _OddOption(
          label: 'Plüssmaci',
          ttsText: 'plüss maci',
          emoji: '🧸',
          isOdd: true,
        ),
      ],
    ),
    _OddPuzzle(
      id: 'winter_watermelon',
      prompt: 'Melyik nem a télhez tartozik?',
      explanation: 'A görögdinnye nyári gyümölcs!',
      options: [
        _OddOption(label: 'Hóember', emoji: '⛄', isOdd: false),
        _OddOption(label: 'Hópehely', emoji: '❄️', isOdd: false),
        _OddOption(label: 'Kesztyű', emoji: '🧤', isOdd: false),
        _OddOption(label: 'Sál', emoji: '🧣', isOdd: false),
        _OddOption(label: 'Szánkó', emoji: '🛷', isOdd: false),
        _OddOption(label: 'Dinnye', emoji: '🍉', isOdd: true),
      ],
    ),
    _OddPuzzle(
      id: 'sweets_dog',
      prompt: 'Melyik nem édesség?',
      explanation: 'A kutya egy hűséges háziállat, nem édesség!',
      options: [
        _OddOption(label: 'Fagyi', emoji: '🍦', isOdd: false),
        _OddOption(label: 'Torta', emoji: '🎂', isOdd: false),
        _OddOption(label: 'Süti', emoji: '🧁', isOdd: false),
        _OddOption(label: 'Csoki', emoji: '🍫', isOdd: false),
        _OddOption(label: 'Fánk', emoji: '🍩', isOdd: false),
        _OddOption(label: 'Kutya', emoji: '🐶', isOdd: true),
      ],
    ),
  ];

  List<_OddPuzzle> _customPuzzles = [];
  List<_OddPuzzle> _roundPuzzles = [];
  List<_OddOption> _currentOptions = [];
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _answeredCorrectly = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _loadCustomPuzzlesAndStart();
  }

  @override
  void dispose() {
    AudioService.instance.stopAll();
    super.dispose();
  }

  Future<void> _loadCustomPuzzlesAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_customPuzzlesKey) ?? [];
    final loaded = <_OddPuzzle>[];
    for (final item in raw) {
      try {
        loaded.add(_OddPuzzle.fromJson(jsonDecode(item)));
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _customPuzzles = loaded;
    });
    _startNewRound();
  }

  Future<void> _saveCustomPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _customPuzzlesKey,
      _customPuzzles.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  void _startNewRound() {
    final random = Random();
    final combined = <_OddPuzzle>[..._customPuzzles, ..._defaultPuzzles]
      ..shuffle(random);

    _roundPuzzles = combined.take(_questionsPerRound).toList();
    _currentIndex = 0;
    _loadCurrentQuestion();
  }

  void _loadCurrentQuestion() {
    final puzzle = _roundPuzzles[_currentIndex];
    final shuffledOptions = List<_OddOption>.from(puzzle.options)
      ..shuffle(Random());

    setState(() {
      _currentOptions = shuffledOptions;
      _selectedOptionIndex = null;
      _answeredCorrectly = false;
    });

    if (!_isMuted) {
      AudioService.instance.speakOrPlay(
        text: puzzle.prompt,
        audioPath: puzzle.isCustom ? puzzle.promptAudioPath : null,
      );
    }
  }

  Future<void> _onOptionTap(int index) async {
    if (_answeredCorrectly) return;

    final option = _currentOptions[index];
    final puzzle = _roundPuzzles[_currentIndex];

    setState(() {
      _selectedOptionIndex = index;
    });

    if (option.isOdd) {
      setState(() {
        _answeredCorrectly = true;
      });
      if (!_isMuted) {
        if (puzzle.isCustom &&
            option.audioPath != null &&
            option.audioPath!.isNotEmpty) {
          await AudioService.instance.speakOrPlay(
            text: option.spokenText,
            audioPath: option.audioPath,
          );
        } else {
          await AudioService.instance.speakOrPlay(
            text: 'Ügyes! ${puzzle.explanation}',
          );
        }
      }
    } else {
      if (!_isMuted) {
        if (puzzle.isCustom &&
            option.audioPath != null &&
            option.audioPath!.isNotEmpty) {
          await AudioService.instance.speakOrPlay(
            text: option.spokenText,
            audioPath: option.audioPath,
          );
        } else {
          await AudioService.instance.speakOrPlay(
            text: '${option.spokenText}. Nézzük meg a többit is!',
          );
        }
      }
    }
  }

  Future<void> _nextOrFinish() async {
    if (_currentIndex + 1 < _roundPuzzles.length) {
      setState(() {
        _currentIndex++;
      });
      _loadCurrentQuestion();
    } else {
      await context.read<RewardProvider>().addStars(2);
      if (!_isMuted) {
        // A játék végi dicséret itt is a saját felvett mp3 hangfájlodat használja!
        AudioService.instance.speakOrPlay(
          text: 'Hurrá, nagyon ügyes vagy!',
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐣🌟🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Hurrá, nagyon ügyes vagy!',
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
              const Text(
                'Minden kakukktojást megtaláltál!\nJutalmad: +2 csillag ⭐',
                textAlign: TextAlign.center,
                style: TextStyle(
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
              child: const Text('Vissza a menübe'),
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
                'Új kör!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openParentCustomPuzzleDialog() async {
    final authorized = await ParentalPinDialog.show(context);
    if (!authorized || !mounted) return;

    final promptCtrl = TextEditingController(text: 'Melyik a kakukktojás?');
    String? promptAudioPath;
    int? activeRecordingIndex;

    final drafts = <_EditableOptionDraft>[
      _EditableOptionDraft(initialLabel: '', emoji: '🍎', isOdd: false),
      _EditableOptionDraft(initialLabel: '', emoji: '🍌', isOdd: false),
      _EditableOptionDraft(initialLabel: '', emoji: '🍓', isOdd: false),
      _EditableOptionDraft(initialLabel: '', emoji: '🍐', isOdd: false),
      _EditableOptionDraft(initialLabel: '', emoji: '🍇', isOdd: false),
      _EditableOptionDraft(initialLabel: '', emoji: '🚗', isOdd: true),
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
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
          final navBarPadding = MediaQuery.of(ctx).viewPadding.bottom;

          Future<void> toggleMicFor(int targetIndex) async {
            if (activeRecordingIndex != null) {
              final recorded = await AudioService.instance.stopRecording();
              final finishedIdx = activeRecordingIndex!;
              setSheetState(() {
                activeRecordingIndex = null;
                if (finishedIdx == -1) {
                  promptAudioPath = recorded;
                } else {
                  drafts[finishedIdx].audioPath = recorded;
                }
              });
              if (finishedIdx == targetIndex) return;
            }

            final ok = await AudioService.instance.startRecording();
            if (ok) {
              setSheetState(() {
                activeRecordingIndex = targetIndex;
              });
            }
          }

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
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
                          Icons.quiz_rounded,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Szülői saját Kakukktojás (${_customPuzzles.length} db)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (activeRecordingIndex != null) {
                              await AudioService.instance.stopRecording();
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: promptCtrl,
                            decoration: InputDecoration(
                              labelText: 'Kérdés (pl. Melyik nem gyümölcs?)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Kérdés felmondása mikrofonnal',
                          icon: Icon(
                            activeRecordingIndex == -1
                                ? Icons.stop_circle_rounded
                                : Icons.mic_rounded,
                            color: activeRecordingIndex == -1
                                ? const Color(0xFFD97706)
                                : (promptAudioPath != null
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF6366F1)),
                          ),
                          onPressed: () => toggleMicFor(-1),
                        ),
                        if (promptAudioPath != null &&
                            activeRecordingIndex != -1)
                          IconButton(
                            tooltip: 'Kérdés meghallgatása',
                            icon: const Icon(
                              Icons.play_circle_fill_rounded,
                              color: Color(0xFF16A34A),
                            ),
                            onPressed: () => AudioService.instance.playAudio(
                              promptAudioPath!,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '5 összetartozó elem (Emoji/Fotó + Név + Hang):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (int i = 0; i < 5; i++) ...[
                      _buildEditableOptionRow(
                        index: i,
                        draft: drafts[i],
                        hint: '${i + 1}. összetartozó elem',
                        isRecording: activeRecordingIndex == i,
                        onPickPhoto: () async {
                          final picker = ImagePicker();
                          final img = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 800,
                            maxHeight: 800,
                            imageQuality: 85,
                          );
                          if (img != null) {
                            setSheetState(() {
                              drafts[i].imagePath = img.path;
                            });
                          }
                        },
                        onToggleMic: () => toggleMicFor(i),
                        onStateChanged: () => setSheetState(() {}),
                      ),
                      const SizedBox(height: 6),
                    ],
                    const SizedBox(height: 6),
                    const Text(
                      '6. elem: A KAKUKKTOJÁS (ami kilóg a sorból):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildEditableOptionRow(
                      index: 5,
                      draft: drafts[5],
                      hint: 'Kakukktojás neve (pl. Autó)',
                      isRecording: activeRecordingIndex == 5,
                      onPickPhoto: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 800,
                          maxHeight: 800,
                          imageQuality: 85,
                        );
                        if (img != null) {
                          setSheetState(() {
                            drafts[5].imagePath = img.path;
                          });
                        }
                      },
                      onToggleMic: () => toggleMicFor(5),
                      onStateChanged: () => setSheetState(() {}),
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
                          if (activeRecordingIndex != null) {
                            final rec = await AudioService.instance
                                .stopRecording();
                            if (activeRecordingIndex == -1) {
                              promptAudioPath = rec;
                            } else {
                              drafts[activeRecordingIndex!].audioPath = rec;
                            }
                            activeRecordingIndex = null;
                          }

                          if (drafts.any(
                            (d) => d.labelCtrl.text.trim().isEmpty,
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Kérlek, mind a 6 elemnek adj nevet!',
                                ),
                              ),
                            );
                            return;
                          }

                          final newPuzzle = _OddPuzzle(
                            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                            prompt: promptCtrl.text.trim().isEmpty
                                ? 'Melyik a kakukktojás?'
                                : promptCtrl.text.trim(),
                            explanation:
                                'A(z) ${drafts[5].labelCtrl.text.trim()} a kakukktojás!',
                            promptAudioPath: promptAudioPath,
                            options: drafts
                                .map(
                                  (d) => _OddOption(
                                    label: d.labelCtrl.text.trim(),
                                    emoji: d.emoji,
                                    isOdd: d.isOdd,
                                    imagePath: d.imagePath,
                                    audioPath: d.audioPath,
                                  ),
                                )
                                .toList(),
                            isCustom: true,
                          );

                          setState(() {
                            _customPuzzles.insert(0, newPuzzle);
                          });
                          await _saveCustomPuzzles();

                          for (final d in drafts) {
                            d.labelCtrl.clear();
                            d.imagePath = null;
                            d.audioPath = null;
                          }
                          promptAudioPath = null;
                          setSheetState(() {});
                          _startNewRound();
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text(
                          'Feladvány mentése',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (_customPuzzles.isNotEmpty) ...[
                      const Divider(height: 24),
                      const Text(
                        'Mentett saját feladványok:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      ..._customPuzzles.map(
                        (cp) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            cp.prompt,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(cp.explanation),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              setState(() {
                                _customPuzzles.removeWhere(
                                  (e) => e.id == cp.id,
                                );
                              });
                              await _saveCustomPuzzles();
                              setSheetState(() {});
                              _startNewRound();
                            },
                          ),
                        ),
                      ),
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

  Widget _buildEditableOptionRow({
    required int index,
    required _EditableOptionDraft draft,
    required String hint,
    required bool isRecording,
    required VoidCallback onPickPhoto,
    required VoidCallback onToggleMic,
    required VoidCallback onStateChanged,
  }) {
    final hasPhoto =
        draft.imagePath != null && File(draft.imagePath!).existsSync();
    final hasAudio = draft.audioPath != null && draft.audioPath!.isNotEmpty;

    return Row(
      children: [
        if (hasPhoto)
          GestureDetector(
            onTap: onPickPhoto,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(draft.imagePath!),
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
            ),
          )
        else
          SizedBox(
            width: 46,
            child: TextFormField(
              initialValue: draft.emoji,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (v) {
                if (v.trim().isNotEmpty) draft.emoji = v.trim();
              },
            ),
          ),
        const SizedBox(width: 6),
        Expanded(
          child: TextField(
            controller: draft.labelCtrl,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Saját fotó választása',
          icon: Icon(
            Icons.photo_camera_back_rounded,
            color: hasPhoto ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
            size: 22,
          ),
          onPressed: onPickPhoto,
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: isRecording
              ? 'Felvétel megállítása'
              : 'Saját hang rögzítése',
          icon: Icon(
            isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
            color: isRecording
                ? const Color(0xFFD97706)
                : (hasAudio
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF6366F1)),
            size: 22,
          ),
          onPressed: onToggleMic,
        ),
        if (hasAudio && !isRecording)
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Hang visszahallgatása',
            icon: const Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFF16A34A),
              size: 22,
            ),
            onPressed: () => AudioService.instance.playAudio(draft.audioPath!),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_roundPuzzles.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final puzzle = _roundPuzzles[_currentIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Kakukktojás Kereső',
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
            tooltip: _isMuted ? 'Hang bekapcsolása' : 'Hang némítása',
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
            tooltip: 'Saját feladványok (Szülői)',
            icon: const Icon(Icons.add_task_rounded, color: Color(0xFFD97706)),
            onPressed: _openParentCustomPuzzleDialog,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFD97706)
                        : const Color(0xFFFDE68A),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Feladvány: ${_currentIndex + 1} / ${_roundPuzzles.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            puzzle.prompt,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFF8FAFC)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            color: Color(0xFFD97706),
                          ),
                          onPressed: () {
                            if (!_isMuted) {
                              AudioService.instance.speakOrPlay(
                                text: puzzle.prompt,
                                audioPath: puzzle.isCustom
                                    ? puzzle.promptAudioPath
                                    : null,
                              );
                            }
                          },
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
                    const crossAxisCount = 2;
                    final rowCount = (_currentOptions.length / crossAxisCount)
                        .ceil()
                        .clamp(1, 3);
                    const spacing = 10.0;

                    final cellWidth =
                        (constraints.maxWidth -
                            (crossAxisCount - 1) * spacing) /
                        crossAxisCount;
                    final cellHeight =
                        (constraints.maxHeight - (rowCount - 1) * spacing) /
                        rowCount;
                    final aspectRatio = (cellWidth / cellHeight).clamp(
                      0.75,
                      2.2,
                    );

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _currentOptions.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: aspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final option = _currentOptions[index];
                        final isSelected = _selectedOptionIndex == index;
                        final hasPhoto =
                            option.imagePath != null &&
                            File(option.imagePath!).existsSync();

                        Color borderColor = isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0);
                        Color bgColor = isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white;

                        if (isSelected) {
                          if (option.isOdd) {
                            borderColor = const Color(0xFF16A34A);
                            bgColor = isDark
                                ? const Color(
                                    0xFF065F46,
                                  ).withValues(alpha: 0.45)
                                : const Color(0xFFDCFCE7);
                          } else {
                            borderColor = isDark
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF93C5FD);
                            bgColor = isDark
                                ? const Color(
                                    0xFF1E3A8A,
                                  ).withValues(alpha: 0.35)
                                : const Color(0xFFEFF6FF);
                          }
                        }

                        return InkWell(
                          onTap: () => _onOptionTap(index),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: borderColor,
                                width: isSelected ? 3.0 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.3 : 0.04,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Center(
                                      child: hasPhoto
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                File(option.imagePath!),
                                                fit: BoxFit.contain,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                            )
                                          : FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                option.emoji,
                                                style: const TextStyle(
                                                  fontSize: 44,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFF8FAFC)
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              if (_answeredCorrectly) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _nextOrFinish,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _currentIndex + 1 < _roundPuzzles.length
                          ? 'Következő feladvány!'
                          : 'Jutalom átvétele (+2 ⭐)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
