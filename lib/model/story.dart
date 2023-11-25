import 'package:adventure_quest_kids/model/story_meta_data.dart';
import 'package:yaml/yaml.dart';

import 'story_page.dart';

class Story {
  final StoryMetaData storyMetaData;
  final Map<String, StoryPage> pages;

  Story(this.storyMetaData, this.pages);

  factory Story.fromYaml(StoryMetaData storyMetadata, YamlMap yamlMap) {
    Map<String, StoryPage> pages = {};

    if (yamlMap['pages'] != null) {
      for (var page in yamlMap['pages'].keys) {
        pages[page] = StoryPage.fromYaml(yamlMap['pages'][page]);
      }
    }

    return Story(storyMetadata, pages);
  }

  String get title => storyMetaData.title;

  String get firstPageId => storyMetaData.firstPageId;

  String get imagesFolder => storyMetaData.imagesFolder;
}
