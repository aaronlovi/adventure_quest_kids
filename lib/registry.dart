import 'package:audioplayers/audioplayers.dart';

import 'model/story_meta_data.dart';

class Registry {
  Map<String, StoryMetaData> storyList;
  AudioPlayer backgroundAudioPlayer;
  StoryMetaData? currentStoryMetaData;

  Registry(this.backgroundAudioPlayer) : storyList = {};

  void dispose() {
    backgroundAudioPlayer.dispose();
  }
}
