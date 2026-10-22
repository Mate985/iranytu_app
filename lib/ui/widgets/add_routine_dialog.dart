import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/routine_step_model.dart';
import '../../services/database_service.dart';
import '../../services/audio_service.dart';

class AddRoutineDialog extends StatefulWidget {
  const AddRoutineDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const AddRoutineDialog(),
    );
  }

  @override
  State<AddRoutineDialog> createState() => _AddRoutineDialogState();
}

class _AddRoutineDialogState extends State<AddRoutineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
  ];

  // Minden lépéshez tartozó rögzített hangfájl elérési útja
  final List<String?> _stepAudioPaths = [null];

  // Éppen melyik lépésnél zajlik rögzítés (-1 ha semelyiknél)
  int _recordingIndex = -1;

  Color _selectedColor = const Color(0xFF60A5FA);

  final List<Color> _availableColors = [
    const Color(0xFF60A5FA), // Kék
    const Color(0xFF34D399), // Zöld
    const Color(0xFFFBBF24), // Sárga
    const Color(0xFFFB923C), // Narancs
    const Color(0xFFC084FC), // Lila
    const Color(0xFFF472B6), // Rózsaszín
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
      _stepAudioPaths.add(null);
    });
  }

  void _removeStepField(int index) {
    if (_stepControllers.length > 1) {
      // Ha éppen ezt a lépést vettük fel, leállítjuk
      if (_recordingIndex == index) {
        AudioService.instance.stopRecording();
        _recordingIndex = -1;
      }
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
        _stepAudioPaths.removeAt(index);
      });
    }
  }

  // Hangfelvétel indítása vagy leállítása
  Future<void> _toggleRecording(int index) async {
    if (_recordingIndex == index) {
      // Leállítás
      final path = await AudioService.instance.stopRecording();
      setState(() {
        _recordingIndex = -1;
        if (path != null) {
          _stepAudioPaths[index] = path;
        }
      });
    } else {
      // Ha máshol ment a felvétel, azt leállítjuk először
      if (_recordingIndex != -1) {
        await AudioService.instance.stopRecording();
      }

      final success = await AudioService.instance.startRecording();
      if (success) {
        setState(() {
          _recordingIndex = index;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mikrofon hozzáférés szükséges a felvételhez!'),
            ),
          );
        }
      }
    }
  }

  // Rögzített hang visszahallgatása
  Future<void> _playRecordedAudio(int index) async {
    final path = _stepAudioPaths[index];
    if (path != null && File(path).existsSync()) {
      await AudioService.instance.playAudio(path);
    }
  }

  // Rögzített hang törlése az adott lépésről
  void _deleteAudio(int index) {
    setState(() {
      _stepAudioPaths[index] = null;
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    // Ha maradt futó felvétel, leállítjuk
    if (_recordingIndex != -1) {
      await AudioService.instance.stopRecording();
      _recordingIndex = -1;
    }

    final routineId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final List<RoutineStep> steps = [];

    for (int i = 0; i < _stepControllers.length; i++) {
      final text = _stepControllers[i].text.trim();
      if (text.isNotEmpty) {
        steps.add(
          RoutineStep(
            id: '${routineId}_step_$i',
            title: text,
            icon: Icons.check_circle_outline_rounded,
            audioPath: _stepAudioPaths[i], // <-- Mentjük a rögzített hangot!
          ),
        );
      }
    }

    if (steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Legalább 1 lépést adj hozzá!')),
      );
      return;
    }

    final newRoutine = Routine(
      id: routineId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      icon: Icons.task_alt_rounded,
      themeColor: _selectedColor,
      steps: steps,
    );

    await DatabaseService.instance.addRoutine(newRoutine);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Új rutin hozzáadása',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Rutin neve (pl. Uzsonna készítés)',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Kötelező kitölteni' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Rövid leírás'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Szín kiválasztása:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _availableColors.map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 16,
                        child: _selectedColor == color
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lépések és saját hangfelvétel:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'A mikrofonra bökve felmondhatod a lépést a saját hangodon.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                ..._stepControllers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ctrl = entry.value;
                  final isThisRecording = _recordingIndex == idx;
                  final hasAudio = _stepAudioPaths[idx] != null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isThisRecording
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isThisRecording
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: isThisRecording
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFE2E8F0),
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isThisRecording
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            decoration: InputDecoration(
                              hintText: '${idx + 1}. lépés leírása',
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        // Hangfelvétel / Stop gomb
                        IconButton(
                          icon: Icon(
                            isThisRecording
                                ? Icons.stop_circle_rounded
                                : (hasAudio
                                      ? Icons.check_circle_rounded
                                      : Icons.mic_rounded),
                            color: isThisRecording
                                ? const Color(0xFFEF4444)
                                : (hasAudio
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF64748B)),
                            size: 24,
                          ),
                          tooltip: isThisRecording
                              ? 'Felvétel leállítása'
                              : (hasAudio
                                    ? 'Saját hang rögzítve (újravételhez kattints)'
                                    : 'Saját hang felvétele'),
                          onPressed: () => _toggleRecording(idx),
                        ),

                        // Ha van rögzített hang, megjelenik a visszahallgató és törlő gomb
                        if (hasAudio && !isThisRecording) ...[
                          IconButton(
                            icon: const Icon(
                              Icons.play_circle_fill_rounded,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                            tooltip: 'Hang visszahallgatása',
                            onPressed: () => _playRecordedAudio(idx),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFF94A3B8),
                              size: 20,
                            ),
                            tooltip: 'Hang törlése',
                            onPressed: () => _deleteAudio(idx),
                          ),
                        ],

                        if (_stepControllers.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => _removeStepField(idx),
                          ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: _addStepField,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Újabb lépés hozzáadása'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_recordingIndex != -1) {
              AudioService.instance.stopRecording();
            }
            Navigator.pop(context, false);
          },
          child: const Text('Mégse'),
        ),
        ElevatedButton(
          onPressed: _saveRoutine,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
          ),
          child: const Text('Mentés', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
