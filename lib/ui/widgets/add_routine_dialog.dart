import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final List<String?> _stepAudioPaths = [null];
  final List<String?> _stepImagePaths = [null];
  String? _routineImagePath;

  int _recordingIndex = -1;
  final ImagePicker _picker = ImagePicker();

  Color _selectedColor = const Color(0xFF60A5FA);

  final List<Color> _availableColors = [
    const Color(0xFF60A5FA),
    const Color(0xFF34D399),
    const Color(0xFFFBBF24),
    const Color(0xFFFB923C),
    const Color(0xFFC084FC),
    const Color(0xFFF472B6),
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
      _stepImagePaths.add(null);
    });
  }

  void _removeStepField(int index) {
    if (_stepControllers.length > 1) {
      if (_recordingIndex == index) {
        AudioService.instance.stopRecording();
        _recordingIndex = -1;
      } else if (_recordingIndex > index) {
        _recordingIndex--;
      }
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
        _stepAudioPaths.removeAt(index);
        _stepImagePaths.removeAt(index);
      });
    }
  }

  Future<void> _pickStepImage(int index, ImageSource source) async {
    try {
      final XFile? img = await _picker.pickImage(
        source: source,
        maxWidth: 700,
        imageQuality: 80,
      );
      if (img != null) {
        setState(() {
          _stepImagePaths[index] = img.path;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickRoutineImage(ImageSource source) async {
    try {
      final XFile? img = await _picker.pickImage(
        source: source,
        maxWidth: 700,
        imageQuality: 80,
      );
      if (img != null) {
        setState(() {
          _routineImagePath = img.path;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleRecording(int index) async {
    if (_recordingIndex == index) {
      final path = await AudioService.instance.stopRecording();
      setState(() {
        _recordingIndex = -1;
        if (path != null) {
          _stepAudioPaths[index] = path;
        }
      });
    } else {
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
            const SnackBar(content: Text('Mikrofon engedély szükséges!')),
          );
        }
      }
    }
  }

  Future<void> _playRecordedAudio(int index) async {
    final path = _stepAudioPaths[index];
    if (path != null && File(path).existsSync()) {
      await AudioService.instance.playAudio(path);
    }
  }

  void _deleteAudio(int index) {
    setState(() {
      _stepAudioPaths[index] = null;
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;

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
            imagePath: _stepImagePaths[i],
            audioPath: _stepAudioPaths[i],
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
      imagePath: _routineImagePath,
      themeColor: _selectedColor,
      steps: steps,
    );

    await DatabaseService.instance.addRoutine(newRoutine);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final hasRoutineImg =
        _routineImagePath != null && File(_routineImagePath!).existsSync();

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
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
                    labelText: 'Rutin neve (pl. Uzsonna)',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Kötelező kitölteni' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Rövid leírás'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (hasRoutineImg)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_routineImagePath!),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_rounded, size: 17),
                      label: const Text('Borítókép'),
                      onPressed: () => _pickRoutineImage(ImageSource.gallery),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_rounded, size: 17),
                      label: const Text('Kamera'),
                      onPressed: () => _pickRoutineImage(ImageSource.camera),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Szín:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
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
                  'Lépések (kép + saját hang):',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ..._stepControllers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ctrl = entry.value;
                  final isThisRecording = _recordingIndex == idx;
                  final hasAudio = _stepAudioPaths[idx] != null;
                  final stepImg = _stepImagePaths[idx];
                  final hasImg = stepImg != null && File(stepImg).existsSync();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. sor: sorszám/kép + szövegmező + lépés törlése
                        Row(
                          children: [
                            if (hasImg)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(stepImg),
                                  width: 34,
                                  height: 34,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
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
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: '${idx + 1}. lépés',
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (_stepControllers.length > 1)
                              IconButton(
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                tooltip: 'Lépés törlése',
                                onPressed: () => _removeStepField(idx),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 2. sor: kép- és hangvezérlők tördelhetően (nincs overflow)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            IconButton(
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.image_rounded,
                                color: hasImg
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF0284C7),
                                size: 22,
                              ),
                              tooltip: 'Kép galériából',
                              onPressed: () =>
                                  _pickStepImage(idx, ImageSource.gallery),
                            ),
                            IconButton(
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                color: Color(0xFF64748B),
                                size: 22,
                              ),
                              tooltip: 'Fotó kamerával',
                              onPressed: () =>
                                  _pickStepImage(idx, ImageSource.camera),
                            ),
                            IconButton(
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
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
                                size: 22,
                              ),
                              tooltip: isThisRecording
                                  ? 'Felvétel leállítása'
                                  : 'Hang felvétele',
                              onPressed: () => _toggleRecording(idx),
                            ),
                            if (hasAudio && !isThisRecording) ...[
                              IconButton(
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 22,
                                ),
                                tooltip: 'Hang visszahallgatása',
                                onPressed: () => _playRecordedAudio(idx),
                              ),
                              IconButton(
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                tooltip: 'Hang törlése',
                                onPressed: () => _deleteAudio(idx),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: _addStepField,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Újabb lépés'),
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
