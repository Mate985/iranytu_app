import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeTutorialScreen extends StatefulWidget {
  const WelcomeTutorialScreen({super.key});

  @override
  State<WelcomeTutorialScreen> createState() => _WelcomeTutorialScreenState();
}

class _WelcomeTutorialScreenState extends State<WelcomeTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _tutorialPages = [
    {
      'title': 'Üdvözlünk az Iránytűben! 👋',
      'icon': '🌟',
      'color': const Color(0xFF38BDF8),
      'description':
          'Ez a játékos fejlesztőalkalmazás azért készült, hogy segítse a mindennapi tanulást, a szókincs bővítését, a számolást és az önállóságot.',
      'items': [
        {
          'title': 'Személyre szabott segítség',
          'desc':
              'Strukturált napirend, vizuális megerősítés és barátságos hangok.',
        },
        {
          'title': 'Egyszerű használat',
          'desc':
              'Gyermekek és szülők számára egyaránt áttekinthető kezelőfelület.',
        },
      ],
    },
    {
      'title': 'Napi Tevékenységek 📅',
      'icon': '📋',
      'color': const Color(0xFF60A5FA),
      'description': 'A mindennapi rutinok és feladatok szervezése:',
      'items': [
        {
          'title': 'Napirendem',
          'desc':
              'Napi teendők időpontokkal, hangos felolvasással és csillaggyűjtő pipálással.',
        },
        {
          'title': 'Lépésről lépésre',
          'desc':
              'Összetett feladatok (kézmosás, öltözködés) könnyen követhető részfolyamatokra bontva.',
        },
      ],
    },
    {
      'title': 'Kommunikáció és Fejlődés 💬',
      'icon': '🧩',
      'color': const Color(0xFF34D399),
      'description': 'Beszédfejlesztés és interaktív feladatok:',
      'items': [
        {
          'title': 'Beszélő Kártyák',
          'desc':
              'Hangos képes kártyák a mindennapi igények, érzések és kérések kifejezésére.',
        },
        {
          'title': 'Játékos gyakorlás',
          'desc':
              'Beszélő Számtábla, Szókirakó, Kép és Szó kaland, ABC betűíró és Nyugis Vonalvezető.',
        },
      ],
    },
    {
      'title': 'Jutalmak és Kuckó 🏆',
      'icon': '⭐',
      'color': const Color(0xFFFBBF24),
      'description': 'Pozitív megerősítés és saját szoba:',
      'items': [
        {
          'title': 'Jutalmaim',
          'desc':
              'A feladatokért gyűjtött csillagok beváltása megbeszélt családi jutalmakra.',
        },
        {
          'title': 'Saját Kuckóm',
          'desc':
              'A gyermek saját virtuális szobája a beváltott trófeákkal és családi fotóval.',
        },
        {
          'title': 'Szülői beállítások',
          'desc':
              'PIN kóddal védett felület az időkorlát, új feladatok és hangok kezelésére.',
        },
      ],
    },
    {
      'title': 'Tudnivaló a Hangokról 🎙️',
      'icon': '🔊',
      'color': const Color(0xFFA78BFA),
      'description': 'Hogyan szólnak a feladatok az alkalmazásban?',
      'items': [
        {
          'title': 'Alapértelmezett hangok',
          'desc':
              'A beépített feladatok túlnyomó része a készítő rögzített hangján szólal meg.',
        },
        {
          'title': 'Beszélő Számtábla',
          'desc': '10 felett a számokat beépített Google hang olvassa fel.',
        },
        {
          'title': 'Egyedi feladatok',
          'desc':
              'Az újonnan hozzáadott saját kártyák a szülő által rögzített hangon vagy Google hangon szólnak.',
        },
      ],
    },
  ];

  Future<void> _closeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_seen', true);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Alkalmazás útmutató',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark
            ? const Color(0xFFF8FAFC)
            : const Color(0xFF1E293B),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentPage + 1} / ${_tutorialPages.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  TextButton(
                    onPressed: _closeTutorial,
                    child: Text(
                      'Bezárás',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _tutorialPages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _tutorialPages[index];
                    final List<Map<String, String>> items =
                        List<Map<String, String>>.from(page['items'] as List);

                    return AnimatedScale(
                      scale: _currentPage == index ? 1.0 : 0.96,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.3 : 0.04,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              page['icon'] as String,
                              style: const TextStyle(fontSize: 44),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              page['title'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFF8FAFC)
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              page['description'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                            const Divider(height: 22),
                            Expanded(
                              child: ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final item = items[i];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? const Color(0xFF60A5FA)
                                                : const Color(0xFF2563EB),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item['desc']!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.35,
                                            color: isDark
                                                ? const Color(0xFFCBD5E1)
                                                : const Color(0xFF475569),
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _tutorialPages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF2563EB)
                          : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (_currentPage < _tutorialPages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _closeTutorial();
                    }
                  },
                  child: Text(
                    _currentPage == _tutorialPages.length - 1
                        ? 'Értem, köszönöm! 👍'
                        : 'Következő ➔',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
