import 'Global.dart';

class AppStrings {
  static String _currentLanguage = 'en'; // Default language

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'NO RETURN',
      'click_to_start': 'CLICK TO START',
      'click_to_continue': 'CLICK TO CONTINUE',
      'menu': 'MENU',
      'reset': 'RESET GAME',
      'reset_message': 'Are You sure You want to delete ALL of Your progress?',
      'no': 'NO',
      'yes': 'YES',
      'music': 'MUSIC',
      'sfx': 'SFX',
      'notifications': 'NOTIFICATIONS',
      'on': 'ON',
      'off': 'OFF',
      'notification_content': 'The waiting time is over! Click to return to the game.',
      'ship_starting': 'THE SHIP IS STARTING...',
      'ship_exploded': 'YOUR SHIP HAS EXPLODED',
      'please_wait': 'PLEASE WAIT'
    },
    'pl': {
      'app_title': 'BEZ POWROTU',
      'click_to_start': 'KLIKNIJ EKRAN ABY ROZPOCZĄĆ',
      'click_to_continue': 'KLIKNIJ ABY KONTYNUOWAĆ',
      'menu': 'MENU',
      'reset': 'RESET GRY',
      'reset_message': 'Czy jesteś pewny, że chcesz usunąć cały postęp gry?',
      'no': 'NIE',
      'yes': 'TAK',
      'music': 'MUZYKA',
      'sfx': 'SFX',
      'notifications': 'POWIADOMIENIA',
      'on': 'WŁ',
      'off': 'WYŁ',
      'notification_content': 'Czas oczekiwania minął! Kliknij, aby wrócić do gry.',
      'ship_starting': 'START STATKU...',
      'ship_exploded': 'TWÓJ STATEK WYBUCHŁ',
      'please_wait': 'PROSZĘ CZEKAĆ'
    }
  };

  // Initialize the language synchronously
  static Future<void> initialize() async {
    _currentLanguage = await languageSetting();
  }

  // Synchronous getter for strings
  static String get(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? key;
  }
}
