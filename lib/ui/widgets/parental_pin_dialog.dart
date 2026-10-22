import 'package:flutter/material.dart';
import '../../services/parental_service.dart';

class ParentalPinDialog extends StatefulWidget {
  const ParentalPinDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ParentalPinDialog(),
    );
    return result ?? false;
  }

  @override
  State<ParentalPinDialog> createState() => _ParentalPinDialogState();
}

class _ParentalPinDialogState extends State<ParentalPinDialog> {
  // Beviteli vezérlők
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _recoveryAnswerController = TextEditingController();
  final _recoveryNewPinController = TextEditingController();

  bool _isLoading = true;
  bool _isFirstRun = false;
  bool _isRecoveryMode = false;

  String? _errorMessage;
  String _securityQuestion = '';

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final isConfigured = await ParentalService.hasPinConfigured();
    final qa = await ParentalService.getSecurityQuestionAndAnswer();

    if (mounted) {
      setState(() {
        _isFirstRun = !isConfigured;
        _securityQuestion = qa['question']!;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _recoveryAnswerController.dispose();
    _recoveryNewPinController.dispose();
    super.dispose();
  }

  // 1. Meglévő PIN ellenőrzése
  Future<void> _verifyExistingPin() async {
    final enteredPin = _pinController.text.trim();
    if (enteredPin.length != 4) {
      setState(() => _errorMessage = 'Kérlek, 4 számjegyet adj meg!');
      return;
    }

    final isValid = await ParentalService.verifyPin(enteredPin);
    if (!mounted) return;

    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = 'Helytelen PIN kód!';
        _pinController.clear();
      });
    }
  }

  // 2. Első indításkori PIN regisztráció
  Future<void> _setupFirstTimePin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.length != 4 || confirmPin.length != 4) {
      setState(() => _errorMessage = 'A kódnak 4 számjegyből kell állnia!');
      return;
    }

    if (pin != confirmPin) {
      setState(() => _errorMessage = 'A megadott kódok nem egyeznek!');
      return;
    }

    await ParentalService.setPin(pin);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Szülői PIN kód sikeresen beállítva!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  // 3. Elfelejtett kód visszaállítása a biztonsági kérdéssel
  Future<void> _resetForgottenPin() async {
    final answer = _recoveryAnswerController.text.trim();
    final newPin = _recoveryNewPinController.text.trim();

    if (answer.isEmpty) {
      setState(() => _errorMessage = 'Kérlek, add meg a biztonsági választ!');
      return;
    }

    if (newPin.length != 4) {
      setState(
        () => _errorMessage = 'Az új PIN-nek 4 számjegyűnek kell lennie!',
      );
      return;
    }

    final success = await ParentalService.resetPinWithSecurityAnswer(
      answer,
      newPin,
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN kód sikeresen visszaállítva és beállítva!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() => _errorMessage = 'Hibás biztonsági válasz!');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            _isFirstRun
                ? Icons.admin_panel_settings_rounded
                : (_isRecoveryMode
                      ? Icons.help_outline_rounded
                      : Icons.lock_outline_rounded),
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isFirstRun
                  ? 'PIN kód létrehozása'
                  : (_isRecoveryMode
                        ? 'Kód visszaállítása'
                        : 'Szülői hozzáférés'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isFirstRun) ...[
              // ELSŐ INDÍTÁS NÉZET
              const Text(
                'A gyermek védelme érdekében hozz létre egy saját 4 számjegyű szülői PIN kódot:',
                style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 16),
              _buildPinInput(_pinController, 'Új PIN kód'),
              const SizedBox(height: 12),
              _buildPinInput(_confirmPinController, 'Új PIN megerősítése'),
            ] else if (_isRecoveryMode) ...[
              // ELFELEJTETT KÓD NÉZET
              Text(
                'Biztonsági kérdés:\n$_securityQuestion',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _recoveryAnswerController,
                decoration: InputDecoration(
                  labelText: 'Válasz (pl. édesanyád neve)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildPinInput(
                _recoveryNewPinController,
                'Új PIN kód (4 számjegy)',
              ),
            ] else ...[
              // MEGSZOKOTT BELÉPŐ NÉZET
              const Text(
                'Add meg a 4 számjegyű szülői PIN kódot:',
                style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 16),
              _buildPinInput(_pinController, '••••', isLarge: true),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isRecoveryMode = true;
                      _errorMessage = null;
                    });
                  },
                  child: const Text(
                    'Elfelejtetted a kódot?',
                    style: TextStyle(fontSize: 12, color: Color(0xFF2563EB)),
                  ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      actions: [
        TextButton(
          onPressed: () {
            if (_isRecoveryMode) {
              setState(() {
                _isRecoveryMode = false;
                _errorMessage = null;
              });
            } else {
              Navigator.of(context).pop(false);
            }
          },
          child: Text(
            _isRecoveryMode ? 'Vissza' : 'Mégse',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_isFirstRun) {
              _setupFirstTimePin();
            } else if (_isRecoveryMode) {
              _resetForgottenPin();
            } else {
              _verifyExistingPin();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            _isFirstRun
                ? 'Mentés és belépés'
                : (_isRecoveryMode ? 'Visszaállítás' : 'Belépés'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinInput(
    TextEditingController controller,
    String hint, {
    bool isLarge = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 4,
      textAlign: TextAlign.center,
      autofocus: true,
      style: TextStyle(
        fontSize: isLarge ? 24 : 18,
        letterSpacing: isLarge ? 12 : 8,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }
}
