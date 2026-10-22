import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_timer_provider.dart';
import '../widgets/app_picto.dart';

class SessionTimeoutScreen extends StatelessWidget {
  const SessionTimeoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const AppPicto(emoji: '🌙', size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Mára elfáradtak a játékok!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF166534),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nagyon ügyesen játszottál ma! Ideje pihentetni a szemedet, mozogni egy kicsit vagy inni egy finom vizet.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Szülői feloldó gomb (pl. PIN vagy hosszú nyomás védi)
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                ),
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: const Text('Szülői feloldás / Idő módosítása'),
                onPressed: () {
                  _showParentUnlockDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showParentUnlockDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Szülői feloldás',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A folytatáshoz írd be a megoldást: 3 + 4 = ?'),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Válasz',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mégse'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
            ),
            onPressed: () {
              if (controller.text.trim() == '7') {
                Navigator.pop(ctx);
                context.read<SessionTimerProvider>().resetSession();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Helytelen válasz!')),
                );
              }
            },
            child: const Text(
              'Feloldás',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
