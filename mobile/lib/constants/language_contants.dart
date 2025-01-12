import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String LANGUAGE_CODE = 'languageCode';

//languages code
const String english = 'en';
const String french = 'fr';
const String portuguese = 'pt';
const String swahili = 'sw';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(LANGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString(LANGUAGE_CODE) ?? english;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case english:
      return const Locale(english, '');
    case french:
      return const Locale(french, "");
    case portuguese:
      return const Locale(portuguese, "");
    case swahili:
      return const Locale(swahili, "");

    default:
      return const Locale(english, '');
  }
}

class Language {
  final int id;
  final Widget flag;

  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(
          1, Image.asset('assets/images/english_flag.png'), "English", "en"),
      Language(2, Image.asset('assets/images/france_flag.png'), "French", "fr"),
      Language(3, Image.asset('assets/images/portugal_flag.png'), "Portuguese",
          "pt"),
      Language(
          4, Image.asset('assets/images/swahili_flag.png'), "Swahili", "sw"),
    ];
  }
}
