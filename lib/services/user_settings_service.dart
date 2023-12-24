import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_settings.dart';

abstract class IUserSettingsService {
  Future<UserSettings> loadSettings();
  Future<void> saveSettings(UserSettings settings);
}

class UserSettingsService implements IUserSettingsService {
  static const _versionKey = 'version';
  static const _backgroundVolumeKey = 'backgroundVolume';
  static const _foregroundVolumeKey = 'foregroundVolume';
  static const _speechVolumeKey = 'speechVolume';
  static const _speechRateKey = 'speechRate';
  static const _localeKey = 'locale';

  @override
  Future<UserSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, Set<String>> terminalPagesVisited = {};
    for (var key in prefs.getKeys()) {
      if (key.startsWith('terminal.')) {
        terminalPagesVisited[key.substring(9)] =
            prefs.getStringList(key)?.toSet() ?? {};
      }
    }

    return UserSettings(
      version: prefs.getInt(_versionKey) ?? UserSettings.version1,
      backgroundVolume: prefs.getDouble(_backgroundVolumeKey) ??
          UserSettings.defaultBackgroundVolume,
      foregroundVolume: prefs.getDouble(_foregroundVolumeKey) ??
          UserSettings.defaultForegroundVolume,
      speechVolume:
          prefs.getDouble(_speechVolumeKey) ?? UserSettings.defaultSpeechVolume,
      speechRate:
          prefs.getDouble(_speechRateKey) ?? UserSettings.defaultSpeechRate,
      terminalPagesVisited: terminalPagesVisited,
      localeName: prefs.getString(_localeKey),
    );
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_versionKey, settings.version);
    await prefs.setDouble(_backgroundVolumeKey, settings.backgroundVolume);
    await prefs.setDouble(_foregroundVolumeKey, settings.foregroundVolume);
    await prefs.setDouble(_speechVolumeKey, settings.speechVolume);
    await prefs.setDouble(_speechRateKey, settings.speechRate);

    for (var entry in settings.terminalPagesVisited.entries) {
      await prefs.setStringList('terminal.${entry.key}', entry.value.toList());
    }

    await prefs.setString(_localeKey, settings.localeName ?? '');
  }
}
