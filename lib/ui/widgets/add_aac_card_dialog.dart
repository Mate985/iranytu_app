import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/aac_card_model.dart';
import '../../services/audio_service.dart';

class AddAacCardDialog extends StatefulWidget {
  final String initialCategory;

  const AddAacCardDialog({super.key, this.initialCategory = 'NEEDS'});

  @override
  State<AddAacCardDialog> createState() => _AddAacCardDialogState();
}

class _AddAacCardDialogState extends State<AddAacCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _speechController = TextEditingController();

  late String _selectedCategory;
  String _imageType = 'DEFAULT_ICON';
  String _selectedIconPath = 'water_drop';
  String? _customImagePath;

  // Hangfelvétel állapota
  String? _recordedAudioPath;
  bool _isRecording = false;

  final List<Map<String, dynamic>> _availableIcons = [
    {
      'path': 'water_drop',
      'icon': Icons.water_drop_rounded,
      'label': 'Víz / Ital',
    },
    {'path': 'restaurant', 'icon': Icons.restaurant_rounded, 'label': 'Étel'},
    {'path': 'wc', 'icon': Icons.wc_rounded, 'label': 'WC'},
    {
      'path': 'front_hand',
      'icon': Icons.front_hand_rounded,
      'label': 'Segítség',
    },
    {'path': 'bed', 'icon': Icons.bed_rounded, 'label': 'Pihenés'},
    {
      'path': 'sentiment_satisfied',
      'icon': Icons.sentiment_satisfied_alt_rounded,
      'label': 'Boldog',
    },
    {'path': 'healing', 'icon': Icons.healing_rounded, 'label': 'Fájdalom'},
    {'path': 'volume_off', 'icon': Icons.volume_off_rounded, 'label': 'Hangos'},
    {
      'path': 'sentiment_dissatisfied',
      'icon': Icons.sentiment_dissatisfied_rounded,
      'label': 'Szomorú',
    },
    {
      'path': 'sports_esports',
      'icon': Icons.sports_esports_rounded,
      'label': 'Játék',
    },
    {'path': 'tv', 'icon': Icons.tv_rounded, 'label': 'Mese'},
    {
      'path': 'directions_walk',
      'icon': Icons.directions_walk_rounded,
      'label': 'Séta',
    },
    {'path': 'menu_book', 'icon': Icons.menu_book_rounded, 'label': 'Könyv'},
    {'path': 'music_note', 'icon': Icons.music_note_rounded, 'label': 'Zene'},
    {'path': 'favorite', 'icon': Icons.favorite_rounded, 'label': 'Ölelés'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _speechController.dispose();
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

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageType = 'CUSTOM_IMAGE';
          _customImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nem sikerült megnyitni a képet')),
        );
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_imageType == 'CUSTOM_IMAGE' &&
        (_customImagePath == null || !File(_customImagePath!).existsSync())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kérlek válassz ki egy képet a galériából!'),
        ),
      );
      return;
    }

    final speech = _speechController.text.trim().isEmpty
        ? _titleController.text.trim()
        : _speechController.text.trim();

    final newCard = AacCardModel(
      title: _titleController.text.trim(),
      speechText: speech,
      category: _selectedCategory,
      imageType: _imageType,
      imagePath: _imageType == 'CUSTOM_IMAGE'
          ? _customImagePath!
          : _selectedIconPath,
      audioPath: _recordedAudioPath,
    );

    Navigator.of(context).pop(newCard);
  }

  @override
  Widget build(BuildContext context) {
    final hasAudio =
        _recordedAudioPath != null &&
        _recordedAudioPath!.isNotEmpty &&
        File(_recordedAudioPath!).existsSync();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Új kártya létrehozása',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Kategória választó
                const Text(
                  'Kategória:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'NEEDS',
                      child: Text('Kérések / Szükségletek'),
                    ),
                    DropdownMenuItem(
                      value: 'FEELINGS',
                      child: Text('Érzések / Hangulat'),
                    ),
                    DropdownMenuItem(
                      value: 'ACTIVITIES',
                      child: Text('Tevékenységek'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 14),

                // Kártya címe
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Kártya felirata *',
                    hintText: 'Pl. Alma / Almalevet kérek',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kérlek add meg a kártya feliratát!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Felolvasandó mondat + MIKROFON & LEJÁTSZÁS GOMBOK
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _speechController,
                        decoration: InputDecoration(
                          labelText: 'Mit mondjon a telefon?',
                          hintText: 'Pl. Kérek egy kis finom almalevet!',
                          helperText: hasAudio
                              ? 'Saját hang rögzítve! ✅'
                              : 'Üresen hagyva a címet olvassa fel.',
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
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: Color(0xFF16A34A),
                          size: 24,
                        ),
                        tooltip: 'Hang meghallgatása',
                        onPressed: _playRecording,
                      ),
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: _isRecording
                            ? const Color(0xFFFEE2E2)
                            : (hasAudio
                                  ? const Color(0xFFE0F2FE)
                                  : const Color(0xFFF1F5F9)),
                        padding: const EdgeInsets.all(12),
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
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF64748B)),
                        size: 24,
                      ),
                      tooltip: _isRecording
                          ? 'Felvétel leállítása'
                          : (hasAudio
                                ? 'Újrafelvétel'
                                : 'Saját hang rögzítése'),
                      onPressed: _toggleRecording,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kép vagy Ikon választó
                const Text(
                  'Kártya képe:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.palette_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Gyári ikon'),
                          ],
                        ),
                        selected: _imageType == 'DEFAULT_ICON',
                        onSelected: (val) {
                          if (val) setState(() => _imageType = 'DEFAULT_ICON');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Saját fotó'),
                          ],
                        ),
                        selected: _imageType == 'CUSTOM_IMAGE',
                        onSelected: (val) {
                          if (val) {
                            setState(() => _imageType = 'CUSTOM_IMAGE');
                            if (_customImagePath == null) _pickImage();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ha saját fotó van kiválasztva
                if (_imageType == 'CUSTOM_IMAGE')
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                          ),
                          child:
                              _customImagePath != null &&
                                  File(_customImagePath!).existsSync()
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    File(_customImagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 40,
                                  color: Color(0xFF94A3B8),
                                ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(
                            Icons.image_search_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _customImagePath == null
                                ? 'Kép kiválasztása galériából'
                                : 'Kép módosítása',
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Gyári ikonok listája
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: GridView.builder(
                      itemCount: _availableIcons.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        final item = _availableIcons[index];
                        final isSelected = _selectedIconPath == item['path'];

                        return InkWell(
                          onTap: () {
                            setState(
                              () => _selectedIconPath = item['path'] as String,
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFBAE6FD)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: isSelected
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF64748B),
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                // Mentés gomb
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kártya mentése',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
