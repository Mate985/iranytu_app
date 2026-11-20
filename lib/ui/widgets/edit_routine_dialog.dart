import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  late List<String?> _stepImagePaths;
  String? _routineImagePath;
  late Color _selectedColor;

  int? _recordingStepIndex;
  final ImagePicker _picker = ImagePicker();

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
    _routineImagePath = widget.routine.imagePath;

    _stepControllers = widget.routine.steps
        .map((s) => TextEditingController(text: s.title))
        .toList();

    _stepAudioPaths = widget.routine.steps.map((s) => s.audioPath).toList();
    _stepImagePaths = widget.routine.steps.map((s) => s.imagePath).toList();

    if (_stepControllers.isEmpty) {
      _stepControllers.add(TextEditingController());
      _stepAudioPaths.add(null);
      _stepImagePaths.add(null);
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
      _stepImagePaths.add(null);
    });
  }

  void _removeStep(int index) {
    if (_stepControllers.length > 1) {
      if (_recordingStepIndex == index) {
        AudioService.instance.stopRecording();
        _recordingStepIndex = null;
      } else if (_recordingStepIndex != null && _recordingStepIndex! > index) {
        _recordingStepIndex = _recordingStepIndex! - 1;
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

  Future<void> _toggleRecord(int index) async {
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
      if (_recordingStepIndex != null) {
        await audio.stopRecording();
      }
      final success = await audio.startRecording();
      if (success) {
        setState(() => _recordingStepIndex = index);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mikrofon engedély szükséges!')),
        );
      }
    }
  }

  Future<void> _playRecording(String path) async {
    if (File(path).existsSync()) {
      await AudioService.instance.playAudio(path);
    }
  }

  void _deleteAudio(int index) {
    setState(() {
      _stepAudioPaths[index] = null;
    });
  }

  Widget? _buildPreviewImage(
    String? rawPath, {
    required double size,
    required double radius,
    required bool isDark,
  }) {
    final path = rawPath?.trim() ?? '';
    if (path.isEmpty) return null;

    Widget? img;
    if (path.startsWith('assets/')) {
      img = Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    } else if (File(path).existsSync()) {
      img = Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }

    if (img == null) return null;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
        child: img,
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (_recordingStepIndex != null) {
      final path = await AudioService.instance.stopRecording();
      if (path != null) {
        _stepAudioPaths[_recordingStepIndex!] = path;
      }
      _recordingStepIndex = null;
    }

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

        final existingIcon = (i < widget.routine.steps.length)
            ? widget.routine.steps[i].icon
            : Icons.check_circle_outline_rounded;

        updatedSteps.add(
          RoutineStep(
            id: existingId,
            title: text,
            icon: existingIcon,
            imagePath: _stepImagePaths[i],
            isCompleted: existingCompleted,
            audioPath: _stepAudioPaths[i],
          ),
        );
      }
    }

    if (updatedSteps.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Legalább 1 lépés kell!')));
      return;
    }

    final updated = Routine(
      id: widget.routine.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      icon: widget.routine.icon,
      imagePath: _routineImagePath,
      themeColor: _selectedColor,
      steps: updatedSteps,
    );

    await DatabaseService.instance.updateRoutine(updated);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Rutin törlése',
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Törlöd a(z) "${widget.routine.title}" rutint?',
          style: TextStyle(
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryText = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF1E293B);
    final secondaryText = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final stepCardBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final stepCardBorder = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    final routinePreview = _buildPreviewImage(
      _routineImagePath,
      size: 52,
      radius: 10,
      isDark: isDark,
    );

    return AlertDialog(
      backgroundColor: dialogBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      title: Row(
        children: [
          Expanded(
            child: Text(
              'Rutin szerkesztése',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primaryText,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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
                  style: TextStyle(color: primaryText),
                  decoration: InputDecoration(
                    labelText: 'Rutin neve',
                    labelStyle: TextStyle(color: secondaryText),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Kötelező kitölteni' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  style: TextStyle(color: primaryText),
                  decoration: InputDecoration(
                    labelText: 'Rövid leírás',
                    labelStyle: TextStyle(color: secondaryText),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (routinePreview != null) routinePreview,
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
                Text(
                  'Szín:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
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
                Text(
                  'Lépések (kép + saját hang):',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                ..._stepControllers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ctrl = entry.value;
                  final stepAudio = _stepAudioPaths[idx];
                  final hasLocalAudio =
                      stepAudio != null &&
                      stepAudio.isNotEmpty &&
                      !stepAudio.startsWith('assets/') &&
                      File(stepAudio).existsSync();
                  final stepImg = _stepImagePaths[idx];
                  final stepPreview = _buildPreviewImage(
                    stepImg,
                    size: 40,
                    radius: 8,
                    isDark: isDark,
                  );
                  final hasAnyImg = stepPreview != null;
                  final isRec = _recordingStepIndex == idx;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isRec
                          ? (isDark
                                ? const Color(
                                    0xFF7F1D1D,
                                  ).withValues(alpha: 0.45)
                                : const Color(0xFFFEE2E2))
                          : stepCardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRec ? const Color(0xFFEF4444) : stepCardBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (stepPreview != null)
                              stepPreview
                            else
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: isRec
                                    ? const Color(0xFFEF4444)
                                    : (isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0)),
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isRec
                                        ? Colors.white
                                        : (isDark
                                              ? const Color(0xFFE2E8F0)
                                              : Colors.black87),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: ctrl,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: primaryText,
                                ),
                                decoration: InputDecoration(
                                  hintText: '${idx + 1}. lépés',
                                  hintStyle: TextStyle(color: secondaryText),
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
                                onPressed: () => _removeStep(idx),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
                                color: hasAnyImg
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
                              icon: Icon(
                                Icons.camera_alt_rounded,
                                color: secondaryText,
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
                                isRec
                                    ? Icons.stop_circle_rounded
                                    : (hasLocalAudio
                                          ? Icons.mic_rounded
                                          : Icons.mic_none_rounded),
                                color: isRec
                                    ? const Color(0xFFEF4444)
                                    : (hasLocalAudio
                                          ? const Color(0xFF2563EB)
                                          : secondaryText),
                                size: 22,
                              ),
                              tooltip: isRec
                                  ? 'Felvétel leállítása'
                                  : (hasLocalAudio
                                        ? 'Újrafelvétel'
                                        : 'Hang felvétele'),
                              onPressed: () => _toggleRecord(idx),
                            ),
                            if (hasLocalAudio && !isRec) ...[
                              IconButton(
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Color(0xFF10B981),
                                  size: 22,
                                ),
                                tooltip: 'Felvétel meghallgatása',
                                onPressed: () => _playRecording(stepAudio),
                              ),
                              IconButton(
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: secondaryText,
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
                  onPressed: _addStep,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Új lépés'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_recordingStepIndex != null) {
              AudioService.instance.stopRecording();
            }
            Navigator.pop(context, false);
          },
          child: const Text('Mégse'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
          ),
          child: const Text('Mentés', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
