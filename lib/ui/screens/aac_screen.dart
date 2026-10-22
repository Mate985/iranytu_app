import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/aac_provider.dart';
import '../../data/models/aac_card_model.dart';
import '../../services/audio_service.dart';
import '../../services/parental_service.dart';
import '../widgets/parental_pin_dialog.dart';
import '../widgets/add_aac_card_dialog.dart';

class AacScreen extends StatefulWidget {
  const AacScreen({super.key});

  @override
  State<AacScreen> createState() => _AacScreenState();
}

class _AacScreenState extends State<AacScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isManageMode = false;

  final List<String> _categoryKeys = ['NEEDS', 'FEELINGS', 'ACTIVITIES'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Szülői PIN ellenőrzés
  Future<bool> _authenticateParent() async {
    final hasPin = await ParentalService.hasPinConfigured();
    if (!hasPin) return true;

    if (!mounted) return false;
    final isAuthorized = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ParentalPinDialog(),
    );

    return isAuthorized ?? false;
  }

  // Új kártya hozzáadása
  Future<void> _addNewCard(AacProvider aacProv) async {
    final authorized = await _authenticateParent();
    if (!authorized) return;

    final currentCategory = _categoryKeys[_tabController.index];

    if (!mounted) return;
    final newCard = await showDialog<AacCardModel>(
      context: context,
      builder: (_) => AddAacCardDialog(initialCategory: currentCategory),
    );

    if (newCard != null) {
      await aacProv.addCard(newCard);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('„${newCard.title}” sikeresen hozzáadva!')),
        );
      }
    }
  }

  // Kártya törlése megerősítéssel
  Future<void> _confirmDeleteCard(
    AacProvider aacProv,
    AacCardModel card,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kártya törlése'),
        content: Text(
          'Biztosan törölni szeretnéd a(z) „${card.title}” kártyát?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Mégse'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Törlés', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && card.id != null) {
      await aacProv.deleteCard(card.id!);
    }
  }

  IconData _getIconData(String iconPath) {
    switch (iconPath) {
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'wc':
        return Icons.wc_rounded;
      case 'front_hand':
        return Icons.front_hand_rounded;
      case 'bed':
        return Icons.bed_rounded;
      case 'sentiment_satisfied':
        return Icons.sentiment_satisfied_alt_rounded;
      case 'healing':
        return Icons.healing_rounded;
      case 'volume_off':
        return Icons.volume_off_rounded;
      case 'sentiment_dissatisfied':
        return Icons.sentiment_dissatisfied_rounded;
      case 'sports_esports':
        return Icons.sports_esports_rounded;
      case 'tv':
        return Icons.tv_rounded;
      case 'directions_walk':
        return Icons.directions_walk_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'music_note':
        return Icons.music_note_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      default:
        return Icons.chat_bubble_rounded;
    }
  }

  Widget _buildCardImage(AacCardModel card, {double size = 48}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (card.imageType == 'CUSTOM_IMAGE' && File(card.imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(card.imagePath),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    return Icon(
      _getIconData(card.imagePath),
      size: size,
      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
    );
  }

  Widget _buildCardGrid(List<AacCardModel> cards, AacProvider aacProv) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(
              'Nincs még saját kártya ebben a kategóriában.',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _addNewCard(aacProv),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Kártya hozzáadása'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        final isSelected = aacProv.selectedCard?.id == card.id;

        // Témakövető kártyaszínek
        final cardBgColor = isSelected
            ? (isDark
                  ? const Color(0xFF0369A1).withValues(alpha: 0.35)
                  : const Color(0xFFE0F2FE))
            : (isDark ? const Color(0xFF1E293B) : Colors.white);

        final borderColor = isSelected
            ? const Color(0xFF0284C7)
            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

        final titleColor = isSelected
            ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1))
            : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B));

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: () {
                  if (!_isManageMode) {
                    aacProv.selectAndSpeakCard(card);
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: borderColor,
                      width: isSelected ? 3 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(
                                0xFF0284C7,
                              ).withValues(alpha: isDark ? 0.4 : 0.2)
                            : Colors.black.withValues(
                                alpha: isDark ? 0.25 : 0.05,
                              ),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCardImage(card, size: 52),
                      const SizedBox(height: 10),
                      Text(
                        card.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Törlés gomb kezelő módban
            if (_isManageMode)
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => _confirmDeleteCard(aacProv, card),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AacProvider>(
      builder: (context, aacProv, child) {
        final selectedCard = aacProv.selectedCard;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'Beszélő Kártyák',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFBAE6FD),
            foregroundColor: isDark
                ? const Color(0xFFF8FAFC)
                : const Color(0xFF0369A1),
            elevation: 0,
            actions: [
              IconButton(
                tooltip: _isManageMode ? 'Kész' : 'Kártyák kezelése',
                icon: Icon(
                  _isManageMode
                      ? Icons.check_circle_rounded
                      : Icons.tune_rounded,
                  color: _isManageMode
                      ? const Color(0xFF16A34A)
                      : (isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0369A1)),
                  size: 26,
                ),
                onPressed: () async {
                  if (!_isManageMode) {
                    final ok = await _authenticateParent();
                    if (!ok) return;
                  }
                  setState(() => _isManageMode = !_isManageMode);
                },
              ),
              IconButton(
                tooltip: 'Új kártya felvétele',
                icon: Icon(
                  Icons.add_circle_rounded,
                  size: 28,
                  color: isDark
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF0369A1),
                ),
                onPressed: () => _addNewCard(aacProv),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: isDark
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFF0369A1),
              unselectedLabelColor: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
              indicatorColor: isDark
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFF0284C7),
              indicatorWeight: 3.5,
              tabs: const [
                Tab(icon: Icon(Icons.favorite_rounded), text: 'Kérések'),
                Tab(icon: Icon(Icons.mood_rounded), text: 'Érzések'),
                Tab(icon: Icon(Icons.attractions_rounded), text: 'Tevékenység'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Mondatszalag
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.06,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: selectedCard == null
                    ? Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.touch_app_rounded,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF94A3B8),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Válassz ki egy kártyát, és elmondom helyetted!',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          _buildCardImage(selectedCard, size: 42),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedCard.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFF8FAFC)
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  selectedCard.speechText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF0284C7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.volume_up_rounded,
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF0284C7),
                              size: 30,
                            ),
                            onPressed: () => AudioService.instance.speakOrPlay(
                              text: selectedCard.speechText,
                              audioPath: selectedCard.audioPath,
                            ),
                            tooltip: 'Felolvasás újra',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF94A3B8),
                              size: 24,
                            ),
                            onPressed: () => aacProv.clearSelection(),
                            tooltip: 'Törlés',
                          ),
                        ],
                      ),
              ),

              // Kártyák fülek szerint
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCardGrid(
                      aacProv.getCardsByCategory('NEEDS'),
                      aacProv,
                    ),
                    _buildCardGrid(
                      aacProv.getCardsByCategory('FEELINGS'),
                      aacProv,
                    ),
                    _buildCardGrid(
                      aacProv.getCardsByCategory('ACTIVITIES'),
                      aacProv,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
