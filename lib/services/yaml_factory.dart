import 'dart:io';

import 'package:adventure_quest_kids/model/story_choice.dart';
import 'package:adventure_quest_kids/model/story_page.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import '../model/story.dart';
import '../model/story_meta_data.dart';

class YamlFactory {
  static StoryPage toStoryPage(YamlMap yamlMap) {
    String imageFileName = yamlMap['imageFileName'];
    String soundFileName = yamlMap['soundFileName'] ?? '';
    String speechFileName = yamlMap['speechFileName'] ?? '';
    String text = yamlMap['text'];
    Map<String, StoryChoice> choices = {};

    if (yamlMap['choices'] != null) {
      for (var choice in yamlMap['choices'].keys) {
        choices[choice] = StoryChoice.fromYaml(yamlMap['choices'][choice]);
      }
    }

    bool isTerminal;
    if (yamlMap['isTerminal'] != null) {
      isTerminal = yamlMap['isTerminal'];
    } else {
      isTerminal = false;
    }

    return StoryPage(
      imageFileName: imageFileName,
      soundFileName: soundFileName,
      speechFileName: speechFileName,
      text: text,
      choices: choices,
      isTerminal: isTerminal,
    );
  }

  static Story toStory(StoryMetaData storyMetadata, YamlMap yamlMap) {
    Map<String, StoryPage> pages = {};

    if (yamlMap['pages'] != null) {
      for (var page in yamlMap['pages'].keys) {
        pages[page] = YamlFactory.toStoryPage(yamlMap['pages'][page]);
      }
    }

    return Story(storyMetadata, pages);
  }

  static Future<Story> getStory(
    StoryMetaData storyMetaData, {
    bool isUnitTest = false,
  }) async {
    String yamlString = isUnitTest
        ? await File('${storyMetaData.storyDataFolder}/story_data.yaml')
            .readAsString()
        : await rootBundle
            .loadString('${storyMetaData.storyDataFolder}/story_data.yaml');
    YamlMap yamlMap = loadYaml(yamlString);
    return YamlFactory.toStory(storyMetaData, yamlMap);
  }
}
