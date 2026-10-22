import 'package:shared_preferences/shared_preferences.dart';

class ParentalService {
  static const String _pinKey = 'parental_pin_code';
  static const String _securityQuestionKey = 'parental_security_question';
  static const String _securityAnswerKey = 'parental_security_answer';

  static const String _defaultQuestion = 'Mi az édesanyád leánykori neve?';
  static const String _defaultAnswer = 'admin';

  // Ellenőrzi, hogy a szülő állított-e már be egyedi PIN kódot
  static Future<bool> hasPinConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  // Aktuális PIN lekérése (ha még nincs semmi, null-t ad vissza)
  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  // Megadott PIN ellenőrzése
  static Future<bool> verifyPin(String enteredPin) async {
    final currentPin = await getPin();
    if (currentPin == null) return false;
    return currentPin == enteredPin;
  }

  // Új PIN beállítása / mentése
  static Future<bool> setPin(String newPin) async {
    if (newPin.length != 4) return false;
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_pinKey, newPin);
  }

  // Biztonsági kérdés és válasz lekérése
  static Future<Map<String, String>> getSecurityQuestionAndAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    final question = prefs.getString(_securityQuestionKey) ?? _defaultQuestion;
    final answer = prefs.getString(_securityAnswerKey) ?? _defaultAnswer;
    return {'question': question, 'answer': answer};
  }

  // Biztonsági kérdés és válasz mentése
  static Future<void> setSecurityQuestionAndAnswer(
    String question,
    String answer,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_securityQuestionKey, question);
    await prefs.setString(_securityAnswerKey, answer.trim().toLowerCase());
  }

  // PIN visszaállítása elfelejtés esetén az új kódra a helyes válasz megadásával
  static Future<bool> resetPinWithSecurityAnswer(
    String enteredAnswer,
    String newPin,
  ) async {
    if (newPin.length != 4) return false;
    final qa = await getSecurityQuestionAndAnswer();
    if (enteredAnswer.trim().toLowerCase() == qa['answer']!.toLowerCase()) {
      return await setPin(newPin);
    }
    return false;
  }
}
