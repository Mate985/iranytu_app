import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/routine_step_model.dart';
import '../../services/database_service.dart';
import '../../services/audio_service.dart';

class EditRoutineDialog extends StatefulWidget {
  final Routine routine;

  const EditRoutineDialog({super.key, required this.routine});

  static Future<bool?> show(BuildContext context, Routine routine) {
    return showDialog<bool>(
      context: context,
      builder: (context) => EditRoutineDialog(routine: routine),
    );
  }

  @override
  State<EditRoutineDialog> createState() => _EditRoutineDialogState();
}

class _EditRoutineDialogState extends State<EditRoutineDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late List<TextEditingController> _stepControllers;
  late List<String?> _stepAudioPaths;
  late Color _selectedColor;

  int? _recordingStepIndex;

  final List<Color> _availableColors = [
    const Color(0xFF38BDF8),
    const Color(0xFF2DD4BF),
    const Color(0xFFFB923C),
    const Color(0xFFFBBF24),
    const Color(0xFF34D399),
    const Color(0xFF60A5FA),
    const Color(0xFFA3E635),
    const Color(0xFFC084FC),
    const Color(0xFFF472B6),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine.title);
    _descController = TextEditingController(text: widget.routine.description);
    _selectedColor = widget.routine.themeColor;

    _stepControllers = widget.routine.steps
        .map((s) => TextEditingController(text: s.title))
        .toList();

    _stepAudioPaths = widget.routine.steps.map((s) => s.audioPath).toList();

    if (_stepControllers.isEmpty) {
      _stepControllers.add(TextEditingController());
      _stepAudioPaths.add(null);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
      _stepAudioPaths.add(null);
    });
  }

  void _removeStep(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers.removeAt(index);
        _stepAudioPaths.removeAt(index);
      });
    }
  }

  Future<void> _toggleRecord(int index) async {
    final audio = AudioService.instance;
    if (_recordingStepIndex == index) {
      // Felvétel leállítása
      final path = await audio.stopRecording();
      setState(() {
        _recordingStepIndex = null;
        if (path != null) {
          _stepAudioPaths[index] = path;
        }
      });
    } else {
      // Ha máshol futna felvétel, állítsuk le
      if (_recordingStepIndex != null) {
        await audio.stopRecording();
      }
      final success = await audio.startRecording();
      if (success) {
        setState(() => _recordingStepIndex = index);
      }
    }
  }

  Future<void> _playRecording(String path) async {
    await AudioService.instance.playAudio(path);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final List<RoutineStep> updatedSteps = [];
    for (int i = 0; i < _stepControllers.length; i++) {
      final text = _stepControllers[i].text.trim();
      if (text.isNotEmpty) {
        final existingId = (i < widget.routine.steps.length)
            ? widget.routine.steps[i].id
            : '${widget.routine.id}_step_${DateTime.now().millisecondsSinceEpoch}_$i';

        final existingCompleted = (i < widget.routine.steps.length)
            ? widget.routine.steps[i].isCompleted
            : false;

        updatedSteps.add(
          RoutineStep(
            id: existingId,
            title: text.endsWith('.') ? text : '$text.',
            icon: Icons.check_circle_outline_rounded,
            isCompleted: existingCompleted,
            audioPath:
                _stepAudioPaths[i], // <-- MEGŐRIZZÜK ÉS MENTJÜK A HANGOT!
          ),
        );
      }
    }

    if (updatedSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Legalább 1 lépést meg kell adni!')),
      );
      return;
    }

    final updated = Routine(
      id: widget.routine.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      icon: widget.routine.icon,
      themeColor: _selectedColor,
      steps: updatedSteps,
    );

    await DatabaseService.instance.updateRoutine(updated);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rutin törlése'),
        content: Text(
          'Biztosan törölni szeretnéd a(z) "${widget.routine.title}" rutint?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Mégse'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Törlés', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.deleteRoutine(widget.routine.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Rutin szerkesztése',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFEF4444),
            ),
            tooltip: 'Rutin törlése',
            onPressed: _confirmDelete,
          ),
        ],
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
                  decoration: const InputDecoration(labelText: 'Rutin neve'),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                  'Lépések és saját hangok szerkesztése:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ..._stepControllers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ctrl = entry.value;
                  final hasAudio =
                      _stepAudioPaths[idx] != null &&
                      _stepAudioPaths[idx]!.isNotEmpty &&
                      File(_stepAudioPaths[idx]!).existsSync();
                  final isRec = _recordingStepIndex == idx;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFFE2E8F0),
                          child: Text(
                            '${idx + 1}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            decoration: InputDecoration(
                              hintText: '${idx + 1}. lépés',
                              isDense: true,
                            ),
                          ),
                        ),
                        // Lejátszás gomb, ha már van hang
                        if (hasAudio && !isRec)
                          IconButton(
                            icon: const Icon(
                              Icons.play_circle_fill_rounded,
                              color: Color(0xFF10B981),
                              size: 22,
                            ),
                            tooltip: 'Felvétel meghallgatása',
                            onPressed: () =>
                                _playRecording(_stepAudioPaths[idx]!),
                          ),
                        // Mikrofon felvétel gomb
                        IconButton(
                          icon: Icon(
                            isRec
                                ? Icons.stop_circle_rounded
                                : (hasAudio
                                      ? Icons.mic_rounded
                                      : Icons.mic_none_rounded),
                            color: isRec
                                ? const Color(0xFFEF4444)
                                : (hasAudio
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF94A3B8)),
                            size: 22,
                          ),
                          tooltip: isRec
                              ? 'Felvétel leállítása'
                              : (hasAudio ? 'Újrafelvétel' : 'Hang felvétele'),
                          onPressed: () => _toggleRecord(idx),
                        ),
                        // Törlés gomb
                        if (_stepControllers.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => _removeStep(idx),
                          ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: _addStep,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Új lépés hozzáadása'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Mégse'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
          ),
          child: const Text(
            'Módosítások mentése',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
