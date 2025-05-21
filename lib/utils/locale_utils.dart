import 'package:adventure_quest_kids/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const List<String> supportedLocales = ['en', 'fr'];
const List<String> supportedNonDefaultLocales = ['fr'];

Map<String, String> getLanguageMap(BuildContext context) {
  Map<String, String> languageMap = {
    'en': AppLocalizations.of(context)!.english,
    'fr': AppLocalizations.of(context)!.french,
  };
  return languageMap;
}

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (locale != _locale) {
      _locale = locale;
      notifyListeners();
    }
  }
}
