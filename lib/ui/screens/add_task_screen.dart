import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../services/audio_service.dart';
import '../helpers/icon_helper.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _ttsTextController = TextEditingController();
  final _durationController = TextEditingController(text: '10');

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  String _selectedColor = '#81C784';
  String _selectedIcon = 'brush';
  String? _pickedImagePath;

  String? _recordedAudioPath;
  bool _isRecordingMain = false;

  final List<TextEditingController> _stepControllers = [];
  final List<String?> _stepAudioPaths = [];
  int? _recordingStepIndex;

  final ImagePicker _picker = ImagePicker();

  final List<String> _availableColors = [
    '#81C784',
    '#64B5F6',
    '#FFB74D',
    '#BA68C8',
    '#E57373',
  ];

  @override
  void initState() {
    super.initState();
    _addStepField();
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
      _stepAudioPaths.add(null);
    });
  }

  void _removeStepField(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        if (_recordingStepIndex == index) {
          AudioService.instance.stopRecording();
          _recordingStepIndex = null;
        } else if (_recordingStepIndex != null &&
            _recordingStepIndex! > index) {
          _recordingStepIndex = _recordingStepIndex! - 1;
        }
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
        _stepAudioPaths.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ttsTextController.dispose();
    _durationController.dispose();
    for (var c in _stepControllers) {
      c.dispose();
    }
    AudioService.instance.stopAll();
    super.dispose();
  }

  Future<void> _pickTaskImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleMainRecording() async {
    final audio = AudioService.instance;
    if (_isRecordingMain) {
      final path = await audio.stopRecording();
      setState(() {
        _isRecordingMain = false;
        if (path != null) {
          _recordedAudioPath = path;
        }
      });
    } else {
      if (_recordingStepIndex != null) {
        final stepPath = await audio.stopRecording();
        if (stepPath != null) {
          _stepAudioPaths[_recordingStepIndex!] = stepPath;
        }
        _recordingStepIndex = null;
      }
      final success = await audio.startRecording();
      if (success) {
        setState(() {
          _isRecordingMain = true;
        });
      }
    }
  }

  Future<void> _toggleStepRecording(int index) async {
    final audio = AudioService.instance;
    if (_recordingStepIndex == index) {
      final path = await audio.stopRecording();
      setState(() {
        _recordingStepIndex = null;
        if (path != null) {
          _stepAudioPaths[index] = path;
        }
      });
    } else {
      if (_isRecordingMain) {
        final mainPath = await audio.stopRecording();
        if (mainPath != null) {
          _recordedAudioPath = mainPath;
        }
        _isRecordingMain = false;
      }
      if (_recordingStepIndex != null) {
        final prevPath = await audio.stopRecording();
        if (prevPath != null) {
          _stepAudioPaths[_recordingStepIndex!] = prevPath;
        }
      }
      final success = await audio.startRecording();
      if (success) {
        setState(() {
          _recordingStepIndex = index;
        });
      }
    }
  }

  Future<void> _playAudioFile(String? path) async {
    if (path != null && File(path).existsSync()) {
      await AudioService.instance.playAudio(path);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final audio = AudioService.instance;
    if (_isRecordingMain) {
      final mainPath = await audio.stopRecording();
      if (mainPath != null) _recordedAudioPath = mainPath;
      _isRecordingMain = false;
    }
    if (_recordingStepIndex != null) {
      final stepPath = await audio.stopRecording();
      if (stepPath != null) _stepAudioPaths[_recordingStepIndex!] = stepPath;
      _recordingStepIndex = null;
    }

    final descriptions = _stepControllers.map((c) => c.text.trim()).toList();
    final visualPath =
        (_pickedImagePath != null && _pickedImagePath!.isNotEmpty)
        ? _pickedImagePath!
        : _selectedIcon;

    await context.read<RoutineProvider>().addNewTaskWithSchedule(
      title: _titleController.text.trim(),
      ttsText: _ttsTextController.text.trim(),
      audioPath: _recordedAudioPath,
      duration: int.tryParse(_durationController.text.trim()) ?? 10,
      scheduledTime: _formatTimeOfDay(_selectedTime),
      colorCode: _selectedColor,
      iconPath: visualPath,
      stepDescriptions: descriptions,
      stepAudioPaths: _stepAudioPaths,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasMainAudio =
        _recordedAudioPath != null &&
        _recordedAudioPath!.isNotEmpty &&
        File(_recordedAudioPath!).existsSync();
    final hasPickedPhoto =
        _pickedImagePath != null && File(_pickedImagePath!).existsSync();
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Új feladat rögzítése'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 88),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Feladat címe *',
                  hintText: 'Pl. Uzsonnázás',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Add meg a feladat címét!'
                    : null,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ttsTextController,
                      decoration: InputDecoration(
                        labelText: 'Instrukció (rövid)',
                        hintText: 'Pl. Egyél egy almát!',
                        helperText: hasMainAudio
                            ? 'Saját hangfelvétel rögzítve! ✅'
                            : 'Opcionális saját hang.',
                        helperStyle: TextStyle(
                          color: hasMainAudio
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF64748B),
                          fontWeight: hasMainAudio
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hasMainAudio && !_isRecordingMain)
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFDCFCE7),
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Color(0xFF16A34A),
                        size: 26,
                      ),
                      tooltip: 'Meghallgatás',
                      onPressed: () => _playAudioFile(_recordedAudioPath),
                    ),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: _isRecordingMain
                          ? const Color(0xFFFEE2E2)
                          : (hasMainAudio
                                ? const Color(0xFFDBEAFE)
                                : const Color(0xFFF1F5F9)),
                      padding: const EdgeInsets.all(14),
                    ),
                    icon: Icon(
                      _isRecordingMain
                          ? Icons.stop_circle_rounded
                          : (hasMainAudio
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded),
                      color: _isRecordingMain
                          ? const Color(0xFFEF4444)
                          : (hasMainAudio
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B)),
                      size: 26,
                    ),
                    tooltip: _isRecordingMain ? 'Leállítás' : 'Hang felvétele',
                    onPressed: _toggleMainRecording,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Időtartam (perc)',
                        suffixText: 'perc',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || int.tryParse(val) == null) {
                          return 'Érvényes számot adj meg!';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time_rounded),
                      label: Text(_formatTimeOfDay(_selectedTime)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Saját fotó / Kép feltöltése a feladathoz
              Text(
                'Saját kép / fotó (opcionális):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (hasPickedPhoto) ...[
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_pickedImagePath!),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _pickedImagePath = null),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(
                            Icons.photo_library_rounded,
                            size: 18,
                          ),
                          label: const Text('Galéria'),
                          onPressed: () => _pickTaskImage(ImageSource.gallery),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.camera_alt_rounded, size: 18),
                          label: const Text('Kamera'),
                          onPressed: () => _pickTaskImage(ImageSource.camera),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!hasPickedPhoto) ...[
                Text(
                  'Vagy válassz piktogramot:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppIcons.availableIcons.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = AppIcons.availableIcons[index];
                      final isSelected = item.key == _selectedIcon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = item.key),
                        child: Container(
                          width: 64,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(
                                    0xFF81C784,
                                  ).withValues(alpha: 0.15)
                                : (isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF81C784)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFF64748B),
                                size: 26,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                'Kártya színe:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _availableColors.map((hex) {
                  final isSelected = _selectedColor == hex;
                  final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                width: 3,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mikrolépések (opcionális):',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _addStepField,
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Lépés hozzáadása',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ..._stepControllers.asMap().entries.map((entry) {
                final idx = entry.key;
                final controller = entry.value;
                final stepAudio = _stepAudioPaths[idx];
                final hasStepAudio =
                    stepAudio != null &&
                    stepAudio.isNotEmpty &&
                    File(stepAudio).existsSync();
                final isStepRec = _recordingStepIndex == idx;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: const Color(0xFFE2E8F0),
                        foregroundColor: const Color(0xFF475569),
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: '${idx + 1}. lépés',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      if (hasStepAudio && !isStepRec) ...[
                        const SizedBox(width: 2),
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Color(0xFF16A34A),
                            size: 22,
                          ),
                          tooltip: 'Meghallgatás',
                          onPressed: () => _playAudioFile(stepAudio),
                        ),
                      ],
                      const SizedBox(width: 2),
                      IconButton(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isStepRec
                              ? Icons.stop_circle_rounded
                              : (hasStepAudio
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded),
                          color: isStepRec
                              ? const Color(0xFFEF4444)
                              : (hasStepAudio
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF64748B)),
                          size: 22,
                        ),
                        tooltip: isStepRec ? 'Leállítás' : 'Hang felvétele',
                        onPressed: () => _toggleStepRecording(idx),
                      ),
                      if (_stepControllers.length > 1) ...[
                        const SizedBox(width: 2),
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () => _removeStepField(idx),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveTask,
                child: const Text(
                  'Feladat mentése',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
