import 'dart:io';
import 'package:flutter/material.dart';
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

  // Saját hangfelvétel változói
  String? _recordedAudioPath;
  bool _isRecording = false;

  final List<TextEditingController> _stepControllers = [];

  final List<String> _availableColors = [
    '#81C784', // Zöld
    '#64B5F6', // Kék
    '#FFB74D', // Narancs
    '#BA68C8', // Lila
    '#E57373', // Piros
  ];

  @override
  void initState() {
    super.initState();
    _addStepField();
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStepField(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
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

  Future<void> _toggleRecording() async {
    final audio = AudioService.instance;
    if (_isRecording) {
      final path = await audio.stopRecording();
      setState(() {
        _isRecording = false;
        if (path != null) {
          _recordedAudioPath = path;
        }
      });
    } else {
      final success = await audio.startRecording();
      if (success) {
        setState(() {
          _isRecording = true;
        });
      }
    }
  }

  Future<void> _playRecording() async {
    if (_recordedAudioPath != null && File(_recordedAudioPath!).existsSync()) {
      await AudioService.instance.playAudio(_recordedAudioPath!);
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

    final steps = _stepControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    await context.read<RoutineProvider>().addNewTaskWithSchedule(
      title: _titleController.text.trim(),
      ttsText: _ttsTextController.text.trim(),
      audioPath: _recordedAudioPath,
      duration: int.tryParse(_durationController.text.trim()) ?? 10,
      scheduledTime: _formatTimeOfDay(_selectedTime),
      colorCode: _selectedColor,
      iconPath: _selectedIcon,
      stepDescriptions: steps,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAudio =
        _recordedAudioPath != null &&
        _recordedAudioPath!.isNotEmpty &&
        File(_recordedAudioPath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Új feladat rögzítése'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Feladat megnevezése
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

            // Instrukciós szöveg + MIKROFON & VISSZAHALLGATÁS
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ttsTextController,
                    decoration: InputDecoration(
                      labelText: 'Instrukció a gyermeknek',
                      hintText: 'Pl. Egyél meg egy finom almát!',
                      helperText: hasAudio
                          ? 'Saját hangfelvétel rögzítve! ✅'
                          : 'Opcionálisan felveheted saját hangoddal.',
                      helperStyle: TextStyle(
                        color: hasAudio
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF64748B),
                        fontWeight: hasAudio
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
                if (hasAudio && !_isRecording)
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
                    tooltip: 'Felvétel meghallgatása',
                    onPressed: _playRecording,
                  ),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: _isRecording
                        ? const Color(0xFFFEE2E2)
                        : (hasAudio
                              ? const Color(0xFFDBEAFE)
                              : const Color(0xFFF1F5F9)),
                    padding: const EdgeInsets.all(14),
                  ),
                  icon: Icon(
                    _isRecording
                        ? Icons.stop_circle_rounded
                        : (hasAudio
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded),
                    color: _isRecording
                        ? const Color(0xFFEF4444)
                        : (hasAudio
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF64748B)),
                    size: 26,
                  ),
                  tooltip: _isRecording
                      ? 'Felvétel leállítása'
                      : (hasAudio ? 'Újrafelvétel' : 'Saját hang felvétele'),
                  onPressed: _toggleRecording,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Időtartam és Tervezett időpont egy sorban
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

            // Piktogram választó
            const Text(
              'Piktogram kiválasztása:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
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
                            ? const Color(0xFF81C784).withValues(alpha: 0.15)
                            : const Color(0xFFF1F5F9),
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

            // Kártya színe
            const Text(
              'Kártya színe:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
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
                          ? Border.all(color: const Color(0xFF1E293B), width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Mikrolépések
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mikrolépések (opcionális):',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addStepField,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Lépés hozzáadása'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._stepControllers.asMap().entries.map((entry) {
              final idx = entry.key;
              final controller = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFFE2E8F0),
                      foregroundColor: const Color(0xFF475569),
                      child: Text(
                        '${idx + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: '${idx + 1}. lépés leírása',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (_stepControllers.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _removeStepField(idx),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 30),

            // Mentés gomb
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
                'Feladat mentése a mai napirendbe',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
