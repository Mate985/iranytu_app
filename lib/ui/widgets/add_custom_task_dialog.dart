import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models/custom_task_model.dart';
import '../../providers/custom_task_provider.dart';
import '../../services/audio_service.dart';
import 'app_picto.dart';

class AddCustomTaskDialog extends StatefulWidget {
  const AddCustomTaskDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AddCustomTaskDialog(),
    );
  }

  @override
  State<AddCustomTaskDialog> createState() => _AddCustomTaskDialogState();
}

class _AddCustomTaskDialogState extends State<AddCustomTaskDialog> {
  final _titleController = TextEditingController();
  String _selectedCategory = 'Szókirakó';
  String? _imagePath;
  bool _isRecording = false;
  String? _recordedAudioPath;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 600,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _toggleVoiceRecording() async {
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
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mikrofon hozzáférés szükséges a felvételhez!'),
          ),
        );
      }
    }
  }

  Future<void> _playRecordedAudio() async {
    if (_recordedAudioPath != null && File(_recordedAudioPath!).existsSync()) {
      await AudioService.instance.playAudio(_recordedAudioPath!);
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kérlek, add meg a feladat nevét!')),
      );
      return;
    }

    if (_isRecording) {
      final path = await AudioService.instance.stopRecording();
      _isRecording = false;
      if (path != null) {
        _recordedAudioPath = path;
      }
    }

    final newTask = CustomTaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: _selectedCategory,
      imagePath: _imagePath,
      audioPath: _selectedCategory == 'Szókirakó' ? _recordedAudioPath : null,
    );

    final provider = context.read<CustomTaskProvider>();
    await provider.addTask(newTask);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sikeresen elmentve: "$title"! 🎉'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    AudioService.instance.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasVoiceRecording =
        _recordedAudioPath != null &&
        _recordedAudioPath!.isNotEmpty &&
        File(_recordedAudioPath!).existsSync();

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          const Icon(
            Icons.add_photo_alternate_rounded,
            color: Color(0xFF2563EB),
            size: 26,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Egyedi Feladat Készítése',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adj hozzá saját tárgyat, fotót és szülői hangot a fejlesztőjátékokhoz.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),

              // 1. Név mező
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Feladat / Tárgy neve (pl. Fésű)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Kategória választó
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Cél modul',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Szókirakó',
                    child: Text(
                      'Szókirakó Kaland (Betűrendező)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Kép és Szó',
                    child: Text(
                      'Kép és Szó Kaland (Kép-Szó párosító)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (val) async {
                  if (val != null) {
                    if (_isRecording) {
                      await AudioService.instance.stopRecording();
                      _isRecording = false;
                    }
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // 3. Kép kiválasztása (Kamera / Galéria)
              Text(
                'Vizuális kártya (Fotó):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.file(
                              File(_imagePath!),
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const AppPicto(emoji: '🖼️', size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.photo_library_rounded,
                            size: 18,
                          ),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Galéria megnyitása'),
                          ),
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                        const SizedBox(height: 4),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.camera_alt_rounded, size: 18),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Fotózás kamerával'),
                          ),
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 4. Hangrögzítés – KIZÁRÓLAG Szókirakó Kaland módban látszik!
              if (_selectedCategory == 'Szókirakó') ...[
                const SizedBox(height: 16),
                Text(
                  'Saját hangfelvétel (Opcionális):',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: _isRecording
                              ? Colors.red
                              : const Color(0xFF2563EB),
                          size: 28,
                        ),
                        onPressed: _toggleVoiceRecording,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _isRecording
                              ? 'Felvétel folyamatban... Beszélj bele!'
                              : (hasVoiceRecording
                                    ? 'Hangfelvétel rögzítve! ✅'
                                    : 'Kattints a mikrofonra a rögzítéshez'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isRecording
                                ? Colors.red
                                : (hasVoiceRecording
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                      if (hasVoiceRecording && !_isRecording)
                        IconButton(
                          icon: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: Color(0xFF16A34A),
                            size: 28,
                          ),
                          tooltip: 'Visszahallgatás',
                          onPressed: _playRecordedAudio,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Mégse',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _saveTask,
          child: const Text(
            'Mentés',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
