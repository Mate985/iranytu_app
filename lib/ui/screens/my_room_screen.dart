import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/reward_provider.dart';
import '../../data/models/reward_model.dart';

class MyRoomScreen extends StatefulWidget {
  const MyRoomScreen({super.key});

  @override
  State<MyRoomScreen> createState() => _MyRoomScreenState();
}

class _MyRoomScreenState extends State<MyRoomScreen> {
  static const String _roomPhotoKey = 'my_room_custom_photo_path';

  bool _isEditMode = false;
  String? _customPhotoPath;

  final Map<int, Offset> _dragPositions = {};

  @override
  void initState() {
    super.initState();
    _loadCustomPhoto();
  }

  Future<void> _loadCustomPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customPhotoPath = prefs.getString(_roomPhotoKey);
    });
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_roomPhotoKey, pickedFile.path);
        setState(() {
          _customPhotoPath = pickedFile.path;
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

  Future<void> _removePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roomPhotoKey);
    setState(() {
      _customPhotoPath = null;
    });
  }

  Widget _buildRewardWidget(RewardModel reward, {double size = 54}) {
    if (reward.imageType == 'CUSTOM_IMAGE' &&
        File(reward.imagePath).existsSync()) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(reward.imagePath), fit: BoxFit.cover),
        ),
      );
    }

    IconData iconData = Icons.stars_rounded;
    switch (reward.imagePath) {
      case 'icecream':
        iconData = Icons.icecream_rounded;
        break;
      case 'tv':
        iconData = Icons.tv_rounded;
        break;
      case 'park':
        iconData = Icons.park_rounded;
        break;
      case 'toys':
        iconData = Icons.toys_rounded;
        break;
      case 'book':
        iconData = Icons.menu_book_rounded;
        break;
      case 'sports':
        iconData = Icons.sports_esports_rounded;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF08A),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(iconData, size: size * 0.58, color: const Color(0xFFB45309)),
    );
  }

  void _showTrophyCelebration(RewardModel reward) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _buildRewardWidget(reward, size: 76),
            const SizedBox(height: 16),
            Text(
              reward.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Büszke lehetsz magadra, ezt a trófeát az ügyességedért kaptad! 🏆⭐',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Szuper vagyok!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShelf(double yPos, double width) {
    return Positioned(
      top: yPos,
      left: width * 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.84,
            height: 14,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB45309), Color(0xFF92400E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.04),
            width: width * 0.76,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 10,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF78350F),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(4),
                    ),
                  ),
                ),
                Container(
                  width: 10,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF78350F),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallPhotoFrame() {
    final hasPhoto =
        _customPhotoPath != null && File(_customPhotoPath!).existsSync();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _isEditMode ? _pickPhoto : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 78,
            height: 90,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? const Color(0xFFD97706)
                    : const Color(0xFFB45309),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: hasPhoto
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(_customPhotoPath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        color: _isEditMode
                            ? (isDark
                                  ? const Color(0xFFFDE047)
                                  : const Color(0xFFB45309))
                            : const Color(0xFFD97706),
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isEditMode ? 'Fotó' : 'Képkeret',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
          ),
          if (_isEditMode && hasPhoto)
            Positioned(
              right: -6,
              top: -6,
              child: GestureDetector(
                onTap: _removePhoto,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<RewardProvider>(
      builder: (context, rewardProv, child) {
        final redeemed = rewardProv.redeemedRewards;
        final placedRewards = redeemed.where((r) => r.isPlaced).toList();
        final unplacedRewards = redeemed.where((r) => !r.isPlaced).toList();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'Saját Kuckóm',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFFDE68A),
            foregroundColor: isDark
                ? const Color(0xFFFDE68A)
                : const Color(0xFF78350F),
            elevation: 0,
            actions: [
              IconButton(
                tooltip: _isEditMode
                    ? 'Elrendezés kész'
                    : 'Trófeák és fotó elrendezése',
                icon: Icon(
                  _isEditMode
                      ? Icons.check_circle_rounded
                      : Icons.palette_rounded,
                  color: _isEditMode
                      ? const Color(0xFF16A34A)
                      : (isDark
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFF78350F)),
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _isEditMode = !_isEditMode;
                  });
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final roomWidth = constraints.maxWidth;
              final roomHeight =
                  constraints.maxHeight - (_isEditMode ? 160 : 0);

              final shelf1Y = roomHeight * 0.18;
              final shelf2Y = roomHeight * 0.31;
              final shelf3Y = roomHeight * 0.44;
              final shelf4Y = roomHeight * 0.57;

              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Column(
                            children: [
                              Expanded(
                                flex: 70,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [
                                              const Color(0xFF1E293B),
                                              const Color(0xFF0F172A),
                                            ]
                                          : [
                                              const Color(0xFFFEF9C3),
                                              const Color(0xFFFEF08A),
                                            ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 30,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF0B1120)
                                        : const Color(0xFFE2E8F0),
                                    border: Border(
                                      top: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFCBD5E1),
                                        width: 6,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      width: roomWidth * 0.78,
                                      height: 54,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(
                                                0xFF312E81,
                                              ).withValues(alpha: 0.6)
                                            : const Color(0xFFDDD6FE),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF4338CA)
                                              : const Color(0xFFC4B5FD),
                                          width: 3,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.emoji_events_rounded,
                                            size: 20,
                                            color: isDark
                                                ? const Color(0xFFFDE047)
                                                : const Color(0xFF6D28D9),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              'Itt találod a trófeáid!',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? const Color(0xFFE0E7FF)
                                                    : const Color(0xFF5B21B6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          top: 14,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFB45309),
                                    Color(0xFF78350F),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFFDE68A),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFDE047),
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'SIKEREIM',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFDE047),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 10,
                          left: 16,
                          child: _buildWallPhotoFrame(),
                        ),

                        _buildShelf(shelf1Y, roomWidth),
                        _buildShelf(shelf2Y, roomWidth),
                        _buildShelf(shelf3Y, roomWidth),
                        _buildShelf(shelf4Y, roomWidth),

                        if (redeemed.isEmpty)
                          Positioned(
                            bottom: 150,
                            left: 20,
                            right: 20,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(
                                          0xFF1E293B,
                                        ).withValues(alpha: 0.9)
                                      : Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.35 : 0.08,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.cottage_rounded,
                                      size: 24,
                                      color: Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'A Kuckód még üres!',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? const Color(0xFFF8FAFC)
                                                  : const Color(0xFF1E293B),
                                            ),
                                          ),
                                          Text(
                                            'Válts be jutalmakat, és tedd ki őket a polcokra!',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        ...placedRewards.map((reward) {
                          if (reward.id == null) return const SizedBox.shrink();
                          final rewardId = reward.id!;

                          final currentOffset =
                              _dragPositions[rewardId] ??
                              Offset(
                                (reward.roomX * (roomWidth - 60)).clamp(
                                  10.0,
                                  roomWidth - 70,
                                ),
                                (reward.roomY * (roomHeight - 60)).clamp(
                                  10.0,
                                  roomHeight - 70,
                                ),
                              );

                          return Positioned(
                            left: currentOffset.dx,
                            top: currentOffset.dy,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (!_isEditMode) {
                                  _showTrophyCelebration(reward);
                                }
                              },
                              onPanStart: _isEditMode
                                  ? (_) {
                                      setState(() {
                                        _dragPositions[rewardId] =
                                            currentOffset;
                                      });
                                    }
                                  : null,
                              onPanUpdate: _isEditMode
                                  ? (details) {
                                      setState(() {
                                        final prev =
                                            _dragPositions[rewardId] ??
                                            currentOffset;
                                        final nextX =
                                            (prev.dx + details.delta.dx).clamp(
                                              10.0,
                                              roomWidth - 70,
                                            );
                                        final nextY =
                                            (prev.dy + details.delta.dy).clamp(
                                              10.0,
                                              roomHeight - 70,
                                            );
                                        _dragPositions[rewardId] = Offset(
                                          nextX,
                                          nextY,
                                        );
                                      });
                                    }
                                  : null,
                              onPanEnd: _isEditMode
                                  ? (_) async {
                                      final finalOffset =
                                          _dragPositions[rewardId] ??
                                          currentOffset;
                                      final normX =
                                          (finalOffset.dx / (roomWidth - 60))
                                              .clamp(0.0, 1.0);
                                      final normY =
                                          (finalOffset.dy / (roomHeight - 60))
                                              .clamp(0.0, 1.0);

                                      await rewardProv.updateRewardPosition(
                                        rewardId,
                                        true,
                                        normX,
                                        normY,
                                      );
                                      if (mounted) {
                                        setState(() {
                                          _dragPositions.remove(rewardId);
                                        });
                                      }
                                    }
                                  : null,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _buildRewardWidget(reward, size: 54),
                                  if (_isEditMode)
                                    Positioned(
                                      right: -6,
                                      top: -6,
                                      child: GestureDetector(
                                        onTap: () async {
                                          _dragPositions.remove(rewardId);
                                          await rewardProv.updateRewardPosition(
                                            rewardId,
                                            false,
                                            0.5,
                                            0.5,
                                          );
                                        },
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
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  if (_isEditMode)
                    Container(
                      height: 180,
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.35 : 0.12,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kattints rá, hogy kitehesd a szobába:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFF8FAFC)
                                  : const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: unplacedRewards.isEmpty
                                ? Center(
                                    child: Text(
                                      'Minden beváltott trófeád a polcokon van!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: unplacedRewards.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 14),
                                    itemBuilder: (context, index) {
                                      final reward = unplacedRewards[index];
                                      return InkWell(
                                        onTap: () {
                                          if (reward.id != null) {
                                            rewardProv.updateRewardPosition(
                                              reward.id!,
                                              true,
                                              0.45,
                                              0.18,
                                            );
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Column(
                                          children: [
                                            _buildRewardWidget(
                                              reward,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 4),
                                            SizedBox(
                                              width: 66,
                                              child: Text(
                                                reward.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? const Color(0xFFF8FAFC)
                                                      : const Color(0xFF1E293B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
