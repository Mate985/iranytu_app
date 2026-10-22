import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/custom_task_provider.dart';
import '../../services/audio_service.dart';
import '../widgets/app_picto.dart';
import 'calm_room_screen.dart';
import '../widgets/game_success_dialog.dart';

class RoutineStepItem {
  final int id;
  final String title;
  final String emoji;
  final String? imagePath;
  final String? audioPath;

  const RoutineStepItem({
    required this.id,
    required this.title,
    this.emoji = '📌',
    this.imagePath,
    this.audioPath,
  });
}

class RoutineScenario {
  final String title;
  final List<RoutineStepItem> correctSteps;

  const RoutineScenario({required this.title, required this.correctSteps});
}

class RoutineSequenceGameScreen extends StatefulWidget {
  const RoutineSequenceGameScreen({super.key});

  @override
  State<RoutineSequenceGameScreen> createState() =>
      _RoutineSequenceGameScreenState();
}

class _RoutineSequenceGameScreenState extends State<RoutineSequenceGameScreen> {
  final List<RoutineScenario> _baseScenarios = const [
    RoutineScenario(
      title: 'Kézmosás',
      correctSteps: [
        RoutineStepItem(
          id: 1,
          title: 'Vizezd be a kezed',
          emoji: '💧',
          audioPath: 'assets/audio/words/vizezd_be_a_kezed.mp3',
        ),
        RoutineStepItem(
          id: 2,
          title: 'Használj szappant és habosíts',
          emoji: '🧼',
          audioPath: 'assets/audio/words/hasznalj_szappant.mp3',
        ),
        RoutineStepItem(
          id: 3,
          title: 'Öblítsd le a habot vízzel',
          emoji: '🚿',
          audioPath: 'assets/audio/words/oblitsd_le_a_habot.mp3',
        ),
        RoutineStepItem(
          id: 4,
          title: 'Töröld szárazra törölközővel',
          emoji: '🧻',
          audioPath: 'assets/audio/words/torold_szarazra_a_torolkozovel.mp3',
        ),
      ],
    ),
    RoutineScenario(
      title: 'Fogmosás',
      correctSteps: [
        RoutineStepItem(
          id: 1,
          title: 'Tegyél fogkrémet a kefére',
          emoji: '🪥',
          audioPath: 'assets/audio/words/tegyel_fogkremet_a_kefere.mp3',
        ),
        RoutineStepItem(
          id: 2,
          title: 'Moss fogat alaposan körkörösen',
          emoji: '😁',
          audioPath: 'assets/audio/words/moss_fogat_alaposan.mp3',
        ),
        RoutineStepItem(
          id: 3,
          title: 'Öblítsd ki a szád vízzel',
          emoji: '🚰',
          audioPath: 'assets/audio/words/oblitsd_ki_a_szad.mp3',
        ),
        RoutineStepItem(
          id: 4,
          title: 'Mosd el a fogkefét és tedd el',
          emoji: '✨',
          audioPath: 'assets/audio/words/mosd_el_a_fogkefet.mp3',
        ),
      ],
    ),
    RoutineScenario(
      title: 'Iskolatáska bepakolása',
      correctSteps: [
        RoutineStepItem(
          id: 1,
          title: 'Nézd meg a holnapi órarendet',
          emoji: '📅',
          audioPath: 'assets/audio/words/nezd_meg_a_holnapi.mp3',
        ),
        RoutineStepItem(
          id: 2,
          title: 'Tedd be a tankönyveket',
          emoji: '📚',
          audioPath: 'assets/audio/words/tedd_be_a_tankonyveket.mp3',
        ),
        RoutineStepItem(
          id: 3,
          title: 'Rakd be a tolltartót és vizes palackot',
          emoji: '✏️',
          audioPath: 'assets/audio/words/rakd_be_a_tolltartot.mp3',
        ),
        RoutineStepItem(
          id: 4,
          title: 'Húzd be a táska cipzárját',
          emoji: '🎒',
          audioPath: 'assets/audio/words/huzd_be_a_taska_zipzarjat.mp3',
        ),
      ],
    ),
    RoutineScenario(
      title: 'Reggeli öltözködés',
      correctSteps: [
        RoutineStepItem(
          id: 1,
          title: 'Vedd le a pizsamát',
          emoji: '🛌',
          audioPath: 'assets/audio/words/vedd_le_a_pizsamat.mp3',
        ),
        RoutineStepItem(
          id: 2,
          title: 'Vedd fel az alsóneműt és zoknit',
          emoji: '🧦',
          audioPath: 'assets/audio/words/vedd_fel_az_alsonemut.mp3',
        ),
        RoutineStepItem(
          id: 3,
          title: 'Bújj bele a nadrágba és pólóba',
          emoji: '👕',
          audioPath: 'assets/audio/words/bujj_bele_a_nadragba.mp3',
        ),
        RoutineStepItem(
          id: 4,
          title: 'Vedd fel a pulóvert',
          emoji: '🧥',
          audioPath: 'assets/audio/words/vedd_fel_a_pulovert.mp3',
        ),
      ],
    ),
    RoutineScenario(
      title: 'Ebédelés / Asztalterítés',
      correctSteps: [
        RoutineStepItem(
          id: 1,
          title: 'Moss kezet alaposan',
          emoji: '🧼',
          audioPath: 'assets/audio/words/moss_kezet_alaposan.mp3',
        ),
        RoutineStepItem(
          id: 2,
          title: 'Tedd az asztalra a tányért és evőeszközt',
          emoji: '🍽️',
          audioPath: 'assets/audio/words/tedd_az_asztalra_a_tanyert.mp3',
        ),
        RoutineStepItem(
          id: 3,
          title: 'Ülj le és egyél nyugodtan',
          emoji: '🍲',
          audioPath: 'assets/audio/words/ulj_le_es_egyel.mp3',
        ),
        RoutineStepItem(
          id: 4,
          title: 'Vidd a mosogatóba az üres tányért',
          emoji: '🥣',
          audioPath: 'assets/audio/words/vidd_a_mosogatoba_az_ures.mp3',
        ),
      ],
    ),
    RoutineScenario(
      title: 'Indulás elinduláskor',
      correctSteps: [
        RoutineStepItem(
          id: 1,
          title: 'Vedd fel a cipődet',
          emoji: '👟',
          audioPath: 'assets/audio/words/vedd_fel_a_cipodet.mp3',
        ),
        RoutineStepItem(
          id: 2,
          title: 'Kösd be vagy tépőzárazd be a cipőt',
          emoji: '👟',
          audioPath: 'assets/audio/words/kosd_be_a_cipot.mp3',
        ),
        RoutineStepItem(
          id: 3,
          title: 'Vedd fel a kabátodat',
          emoji: '🧥',
          audioPath: 'assets/audio/words/vedd_fel_a_kabatodat.mp3',
        ),
        RoutineStepItem(
          id: 4,
          title: 'Húzd fel a kabát cipzárját',
          emoji: '🔒',
          audioPath: 'assets/audio/words/huzd_fel_a_kabat_zipzarjat.mp3',
        ),
      ],
    ),
    RoutineScenario(
      title: 'Esti lefekvés',
      correctSteps: [
        RoutineStepItem(
          id: 1,
          title: 'Moss fogat a fürdőszobában',
          emoji: '🪥',
          audioPath: 'assets/audio/words/moss_fogat_a_furdoben.mp3',
        ),
        RoutineStepItem(
          id: 2,
          title: 'Vedd fel a kényelmes pizsamát',
          emoji: '🥱',
          audioPath: 'assets/audio/words/vedd_fel_a_pizsamat.mp3',
        ),
        RoutineStepItem(
          id: 3,
          title: 'Bújj be az ágyba a takaró alá',
          emoji: '🛏️',
          audioPath: 'assets/audio/words/bujj_be_az_agyba.mp3',
        ),
        RoutineStepItem(
          id: 4,
          title: 'Kapcsold le a lámpát és pihenj',
          emoji: '🌙',
          audioPath: 'assets/audio/words/kapcsold_le_a_lampat.mp3',
        ),
      ],
    ),
    RoutineScenario(
      title: 'Játékok elpakolása',
      correctSteps: [
        RoutineStepItem(
          id: 1,
          title: 'Hagyd abba a játékot időben',
          emoji: '⏰',
          audioPath: 'assets/audio/words/hagyd_abba_a_jatekot.mp3',
        ),
        RoutineStepItem(
          id: 2,
          title: 'Szedd össze a kockákat a földről',
          emoji: '🧩',
          audioPath: 'assets/audio/words/szedd_ossze_a_kockakat.mp3',
        ),
        RoutineStepItem(
          id: 3,
          title: 'Tedd be őket a játéktároló dobozba',
          emoji: '📦',
          audioPath: 'assets/audio/words/tedd_be_oket_a_dobozba.mp3',
        ),
        RoutineStepItem(
          id: 4,
          title: 'Told a dobozt a helyére a polcra',
          emoji: '🧸',
          audioPath: 'assets/audio/words/told_a_dobozt_a_helyere.mp3',
        ),
      ],
    ),
    RoutineScenario(
      title: 'Esti fürdés / Zuhanyzás',
      correctSteps: [
        RoutineStepItem(
          id: 1,
          title: 'Készítsd elő a tiszta törölközőt',
          emoji: '🧻',
          audioPath: 'assets/audio/words/keszits_elo_tiszta_torolkozot.mp3',
        ),
        RoutineStepItem(
          id: 2,
          title: 'Lépj be a kádba vagy zuhanyzóba',
          emoji: '🛁',
          audioPath: 'assets/audio/words/lepj_be_a_kadba.mp3',
        ),
        RoutineStepItem(
          id: 3,
          title: 'Mosd meg a tested tusfürdővel',
          emoji: '🧼',
          audioPath: 'assets/audio/words/mosd_meg_a_testedet.mp3',
        ),
        RoutineStepItem(
          id: 4,
          title: 'Törölközz meg alaposan szárazra',
          emoji: '✨',
          audioPath: 'assets/audio/words/torolkozz_meg_alaposan.mp3',
        ),
      ],
    ),
    RoutineScenario(
      title: 'Hazaérkezés iskola után',
      correctSteps: [
        RoutineStepItem(
          id: 1,
          title: 'Vedd le a cipőd az előszobában',
          emoji: '👟',
          audioPath: 'assets/audio/words/vedd_le_a_cipod.mp3',
        ),
        RoutineStepItem(
          id: 2,
          title: 'Akaszd fel a kabátodat a fogasra',
          emoji: '🧥',
          audioPath: 'assets/audio/words/akaszd_fel_a_kabatot.mp3',
        ),
        RoutineStepItem(
          id: 3,
          title: 'Moss alaposan kezet meleg vízzel',
          emoji: '🧼',
          audioPath: 'assets/audio/words/moss_alaposan_kezet.mp3',
        ),
        RoutineStepItem(
          id: 4,
          title: 'Vedd ki az uzsonnás dobozt a táskából',
          emoji: '🍎',
          audioPath:
              'assets/audio/words/vedd_ki_az_uzsonnasdobozt_a_taskadbol.mp3',
        ),
      ],
    ),
  ];

  List<RoutineScenario> _activeScenarios = [];
  int _currentScenarioIndex = 0;
  int _completedScenariosCount = 0;
  late List<RoutineStepItem> _shuffledSteps;
  bool _isInitialized = false;

  RoutineScenario get _currentScenario => _activeScenarios.isNotEmpty
      ? _activeScenarios[_currentScenarioIndex]
      : _baseScenarios[0];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadAndMergeScenarios();
      _isInitialized = true;
    }
  }

  void _loadAndMergeScenarios() {
    final customTaskProv = context.watch<CustomTaskProvider>();
    final customTasks = customTaskProv.tasks.where((t) {
      return t.category.trim().toLowerCase() == 'rutin sorrend' ||
          t.category.trim().toLowerCase().contains('rutin');
    }).toList();

    final List<RoutineScenario> merged = [];

    if (customTasks.length >= 2) {
      final List<RoutineStepItem> customSteps = [];
      for (int i = 0; i < customTasks.length; i++) {
        final t = customTasks[i];
        customSteps.add(
          RoutineStepItem(
            id: i + 1,
            title: t.title,
            imagePath: t.imagePath,
            audioPath: t.audioPath,
          ),
        );
      }
      merged.add(
        RoutineScenario(
          title: 'Saját otthoni rutin ⭐',
          correctSteps: customSteps,
        ),
      );
    }

    merged.addAll(_baseScenarios);

    setState(() {
      _activeScenarios = merged;
      if (_currentScenarioIndex >= _activeScenarios.length) {
        _currentScenarioIndex = 0;
      }
      _loadScenario();
    });
  }

  void _loadScenario() {
    _shuffledSteps = List.from(_currentScenario.correctSteps);
    _shuffledSteps.shuffle();
    if (_isAlreadyCorrect() && _shuffledSteps.length > 1) {
      _shuffledSteps = _shuffledSteps.reversed.toList();
    }
  }

  bool _isAlreadyCorrect() {
    for (int i = 0; i < _shuffledSteps.length; i++) {
      if (_shuffledSteps[i].id != _currentScenario.correctSteps[i].id) {
        return false;
      }
    }
    return true;
  }

  void _speakText(String text, {String? audioPath}) {
    // Csak akkor játszunk le bármit, ha van kifejezett audioPath (nincs Google TTS robothang fallback)
    if (audioPath != null) {
      AudioService.instance.speakOrPlay(text: text, audioPath: audioPath);
    }
  }

  void _checkOrder() {
    bool isCorrect = true;
    for (int i = 0; i < _shuffledSteps.length; i++) {
      if (_shuffledSteps[i].id != _currentScenario.correctSteps[i].id) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      _completedScenariosCount++;
      final earnedStar = (_completedScenariosCount % 2 == 0);
      if (earnedStar) {
        context.read<RewardProvider>().addStars(1);
      }

      AudioService.instance.speakOrPlay(
        text: 'Hurrá, nagyon ügyes vagy!',
        audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
      );

      GameSuccessDialog.show(
        context,
        title: 'Sikerült a rutin! 🌟',
        message:
            'Hibátlanul összeraktad a(z) "${_currentScenario.title}" lépéseit!',
        earnedStar: earnedStar,
        audioPath: 'assets/audio/words/hurra_nagyon_ugyes_vagy.mp3',
        onNext: () {
          setState(() {
            _currentScenarioIndex =
                (_currentScenarioIndex + 1) % _activeScenarios.length;
            _loadScenario();
          });
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Még nincs teljesen jó helyen. Próbáld meg áthúzni a kártyákat!',
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF64748B),
        ),
      );
    }
  }

  Widget _buildStepVisual(RoutineStepItem step) {
    if (step.imagePath != null && File(step.imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(step.imagePath!),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      );
    }
    return AppPicto(emoji: step.emoji, size: 26);
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
          'Rutin Sorrendrakó',
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF14532D).withValues(alpha: 0.5)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.low_priority_rounded,
                        color: Color(0xFF22C55E),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _currentScenario.title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFF8FAFC)
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              Text(
                                '${_currentScenarioIndex + 1} / ${_activeScenarios.length}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Húzd ujjaddal a kártyákat a jó sorrendbe!',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: _shuffledSteps.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _shuffledSteps.removeAt(oldIndex);
                      _shuffledSteps.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final step = _shuffledSteps[index];
                    return Container(
                      key: ValueKey('${step.id}_${step.title}'),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.02,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildStepVisual(step),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFF8FAFC)
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (step.audioPath != null)
                            IconButton(
                              icon: Icon(
                                Icons.volume_up_rounded,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                size: 24,
                              ),
                              tooltip: 'Lépés felolvasása',
                              onPressed: () => _speakText(
                                step.title,
                                audioPath: step.audioPath,
                              ),
                            ),
                          Icon(
                            Icons.drag_handle_rounded,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                            size: 26,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Kész vagyok! Ellenőrzés',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: _checkOrder,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
