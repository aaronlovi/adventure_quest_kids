import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_settings.dart';

abstract class IUserSettingsService {
  Future<UserSettings> loadSettings();
  Future<void> saveSettings(UserSettings settings);
}

class UserSettingsService implements IUserSettingsService {
  static const _backgroundVolumeKey = 'backgroundVolume';
  static const _foregroundVolumeKey = 'foregroundVolume';
  static const _speechVolumeKey = 'speechVolume';
  static const _speechRateKey = 'speechRate';

  @override
  Future<UserSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSettings(
      backgroundVolume: prefs.getDouble(_backgroundVolumeKey) ??
          UserSettings.defaultBackgroundVolume,
      foregroundVolume: prefs.getDouble(_foregroundVolumeKey) ??
          UserSettings.defaultForegroundVolume,
      speechVolume:
          prefs.getDouble(_speechVolumeKey) ?? UserSettings.defaultSpeechVolume,
      speechRate:
          prefs.getDouble(_speechRateKey) ?? UserSettings.defaultSpeechRate,
    );
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_backgroundVolumeKey, settings.backgroundVolume);
    prefs.setDouble(_foregroundVolumeKey, settings.foregroundVolume);
    prefs.setDouble(_speechVolumeKey, settings.speechVolume);
    prefs.setDouble(_speechRateKey, settings.speechRate);
  }
}
