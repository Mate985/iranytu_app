import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models/custom_task_model.dart';
import '../../providers/custom_task_provider.dart';
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
  bool _hasVoiceRecording = false;

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

  void _toggleVoiceRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        _hasVoiceRecording = true;
      }
    });
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kérlek, add meg a feladat nevét!')),
      );
      return;
    }

    final newTask = CustomTaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: _selectedCategory,
      imagePath: _imagePath,
      audioPath: _hasVoiceRecording
          ? 'custom_voice_${DateTime.now().millisecondsSinceEpoch}'
          : null,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            color: Color(0xFF2563EB),
            size: 28,
          ),
          SizedBox(width: 10),
          Text(
            'Egyedi Feladat Készítése',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adj hozzá saját tárgyat, fotót és szülői hangot a fejlesztőjátékokhoz.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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

              // 2. Kategória választó (csak a két támogatott modul)
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
                    child: Text('Szókirakó Kaland (Betűrendező)'),
                  ),
                  DropdownMenuItem(
                    value: 'Kép és Szó',
                    child: Text('Kép és Szó Kaland (Kép-Szó párosító)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),

              // 3. Kép kiválasztása (Kamera / Galéria)
              const Text(
                'Vizuális kártya (Fotó):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
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
                          label: const Text('Galéria megnyitása'),
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
                          label: const Text('Fotózás kamerával'),
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Hangrögzítés
              const Text(
                'Saját hangfelvétel (Opcionális):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isRecording
                            ? 'Felvétel folyamatban... Beszélj bele!'
                            : (_hasVoiceRecording
                                  ? 'Hangfelvétel rögzítve! ✅'
                                  : 'Kattints a mikrofonra a rögzítéshez'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isRecording
                              ? Colors.red
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
