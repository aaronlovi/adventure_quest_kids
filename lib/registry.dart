import 'dart:io';

import 'package:adventure_quest_kids/model/user_settings.dart';
import 'package:adventure_quest_kids/services/user_settings_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'model/story_meta_data.dart';

class Registry {
  Map<String, StoryMetaData> storyList;
  AudioPlayer backgroundAudioPlayer;
  AudioPlayer speechAudioPlayer;
  StoryMetaData? currentStoryMetaData;
  UserSettings settings;
  final IUserSettingsService _userSettingsService;

  Registry(
    this.backgroundAudioPlayer,
    this.speechAudioPlayer,
    this.settings,
    IUserSettingsService userSettingsService,
  )   : _userSettingsService = userSettingsService,
        storyList = {};

  double get backgroundVolume => settings.backgroundVolume;
  set backgroundVolume(double volume) {
    settings.backgroundVolume = volume;
  }

  double get foregroundVolume => settings.foregroundVolume;
  set foregroundVolume(double volume) {
    settings.foregroundVolume = volume;
  }

  double get speechVolume => settings.speechVolume;
  set speechVolume(double volume) {
    settings.speechVolume = volume;
  }

  double get speechRate => settings.speechRate;
  set speechRate(double rate) {
    settings.speechRate = rate;
  }

  String get localeName =>
      (settings.localeName?.isEmpty ?? true) ? 'en' : settings.localeName!;
  set localeName(String localeName) {
    settings.localeName = localeName;
  }

  Set<String> getTerminalPagesVisited(String storyId) =>
      settings.terminalPagesVisited[storyId] ?? {};

  Future<void> setTerminalPageVisited(
      String storyId, String terminalPageId) async {
    settings.terminalPagesVisited
        .putIfAbsent(storyId, () => {terminalPageId})
        .add(terminalPageId);
    await saveSettings();
  }

  Future<void> saveSettings() async {
    await _userSettingsService.saveSettings(settings);
  }

  String get bannerAdUnitId => Platform.isAndroid
      ? dotenv.env['ANDROID_BANNER_AD_UNIT_ID']!
      : dotenv.env['IOS_BANNER_AD_UNIT_ID']!;

  void dispose() {
    backgroundAudioPlayer.dispose();
  }
}
