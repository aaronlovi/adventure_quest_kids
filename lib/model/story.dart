import 'package:adventure_quest_kids/model/story_meta_data.dart';

import 'story_page.dart';

class Story {
  final StoryMetaData storyMetaData;
  final Map<String, StoryPage> pages;

  Story(this.storyMetaData, this.pages);

  String getTitle(String localeName) => storyMetaData.getTitle(localeName);
  String getSubTitle(String localeName) =>
      storyMetaData.getSubTitle(localeName);
  String getFullTitle(String localeName) =>
      storyMetaData.getFullTitle(localeName);

  String get firstPageId => storyMetaData.firstPageId;

  String get imagesFolder => storyMetaData.imagesFolder;
  String get soundsFolder => storyMetaData.soundsFolder;
  String get speechFolder => storyMetaData.speechFolder;
}
