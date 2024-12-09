import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

late Box nodeBox;
late Box userProgressBox;
bool handleActions = false;

Future<bool> isTimerCompleted(String timerKey) async {
  final prefs = await SharedPreferences.getInstance();
  final endTimeKey = '${timerKey}_endTime';
  final endTimeMillis = prefs.getInt(endTimeKey);

  if (endTimeMillis == null) {
    return false; // Timer doesn't exist, consider it completed
  }

  final endTime = DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
  final now = DateTime.now();

  return now.isAfter(endTime);
}

void resetTimer(String timerKey) async{
  final prefs = await SharedPreferences.getInstance();

  prefs.setBool('${timerKey}_endTime', false);
}


Future<String> languageSetting() async {
  final prefs = await SharedPreferences.getInstance();
  String language;

  // Get device locale
  final deviceLocale = ui.window.locale.languageCode;
  // Set language based on device locale (pl for Polish, en for others)
  if(nodeBox.isEmpty) {
    if (deviceLocale == 'pl') {
      language = 'pl';
      await prefs.setString('language', language);
      return language;
    }
    else {
      language = 'en';
      await prefs.setString('language', language);
      return language;
    }
  }
  else{
    if(deviceLocale != prefs.getString('language')){
      language = deviceLocale;
      await prefs.setString('language', language);
      nodeBox.clear();
      return language;
    }
    else{
      language = deviceLocale;
      return language;
    }
  }

  // Save the detected language

}