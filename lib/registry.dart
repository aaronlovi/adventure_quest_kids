import 'package:adventure_quest_kids/model/user_settings.dart';
import 'package:adventure_quest_kids/services/user_settings_service.dart';
import 'package:audioplayers/audioplayers.dart';

import 'model/story_meta_data.dart';

class Registry {
  Map<String, StoryMetaData> storyList;
  AudioPlayer backgroundAudioPlayer;
  StoryMetaData? currentStoryMetaData;
  UserSettings settings;
  final IUserSettingsService _userSettingsService;

  Registry(this.backgroundAudioPlayer, this.settings,
      IUserSettingsService userSettingsService)
      : _userSettingsService = userSettingsService,
        storyList = {};

  double get backgroundVolume => settings.backgroundVolume;
  set backgroundVolume(double volume) {
    settings.backgroundVolume = volume;
  }

  double get foregroundVolume => settings.foregroundVolume;
  set foregroundVolume(double volume) {
    settings.foregroundVolume = volume;
  }

  Future<void> saveSettings() async {
    await _userSettingsService.saveSettings(settings);
  }

  void dispose() {
    backgroundAudioPlayer.dispose();
  }
}
