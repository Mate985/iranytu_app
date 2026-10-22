import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_schedule_screen.dart';
import 'parent_settings_screen.dart';
import '../widgets/parental_pin_dialog.dart';
import 'rewards_screen.dart';
import 'my_room_screen.dart';
import 'aac_screen.dart';
import 'calm_room_screen.dart';
import 'routine_steps_screen.dart';
import 'practice_hub_screen.dart';
import 'welcome_tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstRun();
    });
  }

  Future<void> _checkFirstRun() async {
    // Vár 1.2 másodpercet a kezdőlap betöltődése után, hogy a gyermek/szülő lássa a logót és a főmenüt
    await Future.delayed(const Duration(milliseconds: 1200));

    final prefs = await SharedPreferences.getInstance();
    final bool seen = prefs.getBool('tutorial_seen') ?? false;

    if (!seen && mounted) {
      _openTutorial();
    }
  }

  void _openTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeTutorialScreen()),
    );
  }

  Future<void> _openParentalSettings(BuildContext context) async {
    final isUnlocked = await ParentalPinDialog.show(context);
    if (isUnlocked && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ParentSettingsScreen()),
      );
    }
  }

  void _openSafeSpace(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalmRoomScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Napirendem',
        'icon': Icons.calendar_today_rounded,
        'color': isDark ? const Color(0xFF1E3A8A) : const Color(0xFFBFDBFE),
        'textColor': isDark ? const Color(0xFFDBEAFE) : Colors.black87,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DailyScheduleScreen()),
        ),
      },
      {
        'title': 'Lépésről lépésre',
        'icon': Icons.format_list_numbered_rounded,
        'color': isDark ? const Color(0xFF7C2D12) : const Color(0xFFFED7AA),
        'textColor': isDark ? const Color(0xFFFFEDD5) : Colors.black87,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RoutineStepsScreen()),
        ),
      },
      {
        'title': 'Beszélő Kártyák',
        'icon': Icons.chat_bubble_rounded,
        'color': isDark ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD),
        'textColor': isDark ? const Color(0xFFE0F2FE) : Colors.black87,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AacScreen()),
        ),
      },
      {
        'title': 'Játékos gyakorlás',
        'icon': Icons.extension_rounded,
        'color': isDark ? const Color(0xFF14532D) : const Color(0xFFBBF7D0),
        'textColor': isDark ? const Color(0xFFDCFCE7) : Colors.black87,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PracticeHubScreen()),
          );
        },
      },
      {
        'title': 'Jutalmaim',
        'icon': Icons.stars_rounded,
        'color': isDark ? const Color(0xFF78350F) : const Color(0xFFFEF08A),
        'textColor': isDark ? const Color(0xFFFEF3C7) : Colors.black87,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RewardsScreen()),
        ),
      },
      {
        'title': 'Saját Kuckóm',
        'icon': Icons.cottage_rounded,
        'color': isDark ? const Color(0xFF831843) : const Color(0xFFFBCFE8),
        'textColor': isDark ? const Color(0xFFFCE7F3) : Colors.black87,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyRoomScreen()),
        ),
      },
      {
        'title': 'Szülői beállítások',
        'icon': Icons.admin_panel_settings_rounded,
        'color': isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        'textColor': isDark ? const Color(0xFFF1F5F9) : Colors.black87,
        'onTap': () => _openParentalSettings(context),
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.lock_rounded,
            color: isDark ? const Color(0xFF94A3B8) : Colors.blueGrey,
            size: 26,
          ),
          tooltip: 'Szülői beállítások',
          onPressed: () => _openParentalSettings(context),
        ),
        title: Text(
          'Iránytű',
          style: TextStyle(
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF0284C7),
              size: 26,
            ),
            tooltip: 'Alkalmazás útmutató',
            onPressed: _openTutorial,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.spa_rounded,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
              tooltip: 'Nyugiszoba vészgomb',
              onPressed: () => _openSafeSpace(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final textColor = item['textColor'] as Color;

              return InkWell(
                onTap: item['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.04,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 48,
                        color: textColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['title'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
