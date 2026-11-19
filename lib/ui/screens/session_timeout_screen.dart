import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_timer_provider.dart';
import '../../services/parental_service.dart';
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
                'Lejárt a játékidő.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF166534),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Pihentesd a szemed! Igyál egy kis vizet.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                ),
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: const Text('Szülői feloldás'),
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
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Color(0xFF16A34A)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Szülői feloldás',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add meg a 4 jegyű PIN-kódot:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'PIN-kód',
                  counterText: '',
                  errorText: errorText,
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
              onPressed: () async {
                final pin = controller.text.trim();
                final isValid = await ParentalService.verifyPin(pin);
                if (isValid) {
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    context.read<SessionTimerProvider>().resetSession();
                  }
                } else {
                  setDialogState(() {
                    errorText = 'Hibás PIN-kód!';
                  });
                }
              },
              child: const Text(
                'Feloldás',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
