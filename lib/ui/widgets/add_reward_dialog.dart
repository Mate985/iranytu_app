import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/reward_provider.dart';

class AddRewardDialog extends StatefulWidget {
  const AddRewardDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AddRewardDialog(),
    );
  }

  @override
  State<AddRewardDialog> createState() => _AddRewardDialogState();
}

class _AddRewardDialogState extends State<AddRewardDialog> {
  final _titleController = TextEditingController();
  final _pointsController = TextEditingController(text: '3');
  final _picker = ImagePicker();

  String? _pickedImagePath;
  String _selectedPresetIcon = 'stars';
  bool _useCustomImage = false;

  final Map<String, IconData> _presetIcons = {
    'stars': Icons.stars_rounded,
    'icecream': Icons.icecream_rounded,
    'tv': Icons.tv_rounded,
    'park': Icons.park_rounded,
    'toys': Icons.toys_rounded,
    'book': Icons.menu_book_rounded,
    'sports': Icons.sports_esports_rounded,
  };

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
        _useCustomImage = true;
      });
    }
  }

  Future<void> _saveReward() async {
    final title = _titleController.text.trim();
    final points = int.tryParse(_pointsController.text.trim()) ?? 0;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kérlek, add meg a jutalom nevét!')),
      );
      return;
    }

    if (points <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A csillagok száma legalább 1 legyen!')),
      );
      return;
    }

    if (_useCustomImage && _pickedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kérlek, válassz ki egy képet a galériából!'),
        ),
      );
      return;
    }

    final imageType = _useCustomImage ? 'CUSTOM_IMAGE' : 'DEFAULT_ICON';
    final imagePath = _useCustomImage ? _pickedImagePath! : _selectedPresetIcon;

    await context.read<RewardProvider>().addReward(
      title: title,
      pointsCost: points,
      imageType: imageType,
      imagePath: imagePath,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jutalom sikeresen elmentve!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 28),
                SizedBox(width: 8),
                Text(
                  'Új jutalom felvétele',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Jutalom megnevezése',
                hintText: 'Pl. Kedvenc plüssmaci, fagyi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Szükséges csillagok száma (⭐)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Jutalom képe:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Beépített ikon'),
                    selected: !_useCustomImage,
                    onSelected: (selected) {
                      if (selected) setState(() => _useCustomImage = false);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Saját fotó'),
                    selected: _useCustomImage,
                    onSelected: (selected) {
                      if (selected) setState(() => _useCustomImage = true);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_useCustomImage)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presetIcons.entries.map((entry) {
                  final isSelected = _selectedPresetIcon == entry.key;
                  return InkWell(
                    onTap: () =>
                        setState(() => _selectedPresetIcon = entry.key),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFEF08A)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFD97706)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        entry.value,
                        color: const Color(0xFF1E293B),
                        size: 28,
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Column(
                children: [
                  if (_pickedImagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_pickedImagePath!),
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: Text(
                      _pickedImagePath == null
                          ? 'Fotó kiválasztása galériából'
                          : 'Másik fotó választása',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Mégse'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Mentés'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
