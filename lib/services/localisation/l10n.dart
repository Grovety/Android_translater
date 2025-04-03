import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/services.dart';

class L10n {
  static String curSourceLanguage = 'en';

  static String curTargetLanguage =
      PlatformDispatcher.instance.locale.languageCode;

  Map<String, dynamic> _translations = {};

  void updateSourceLanguage(String language) => curSourceLanguage = language;

  String getTranslation(String key) {
    if (!_translations.containsKey(key) || _translations[key] == false) {
      log("Warning! Translation key not found: $key");
      return key;
    }
    final result = _translations[key] as String;
    return result;
  }

  Future<String> loadTranslations() async {
    String translations = '';
    try {
      translations = await rootBundle.loadString(
        'assets/l10n/${L10n.curTargetLanguage}.json',
      );
    } catch (error) {
      translations = await rootBundle.loadString('assets/l10n/en.json');
      log('Download translations. Language is not available: $error');
    }
    setTranslations(translations);
    return translations;
  }

  void setTranslations(String? data) {
    if (data != null && data != '') {
      _translations = jsonDecode(data) as Map<String, dynamic>;
    }
  }

  Map<String, dynamic> get translations => _translations;
}
