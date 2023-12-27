import 'dart:io';

import 'package:adventure_quest_kids/model/story_choice.dart';
import 'package:adventure_quest_kids/model/story_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import '../model/story.dart';
import '../model/story_meta_data.dart';
import '../utils/icons_utils.dart';
import '../utils/locale_utils.dart';

class YamlFactory {
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

  static Story toStory(StoryMetaData storyMetadata, YamlMap yamlMap) {
    Map<String, StoryPage> pages = {};

    if (yamlMap['pages'] != null) {
      for (var page in yamlMap['pages'].keys) {
        pages[page] = YamlFactory._toStoryPage(yamlMap['pages'][page]);
      }
    }

    return Story(storyMetadata, pages);
  }

  static StoryPage _toStoryPage(YamlMap yamlMap) {
    String imageFileName = yamlMap['imageFileName'];
    String soundFileName = yamlMap['soundFileName'] ?? '';
    String speechFileName = yamlMap['speechFileName'] ?? '';
    String speechTimestampsFileName = yamlMap['speechTimestampsFileName'] ?? '';
    String text = yamlMap['text'];
    Map<String, StoryChoice> choices = {};

    Map<String, String> textByLanguage = {};
    for (var locale in supportedNonDefaultLocales) {
      if (yamlMap['text-$locale'] != null) {
        textByLanguage[locale] = yamlMap['text-$locale'];
      }
    }

    if (yamlMap['choices'] != null) {
      for (var choice in yamlMap['choices'].keys) {
        choices[choice] = _toStoryChoice(yamlMap['choices'][choice]);
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
      speechTimestampsFileName: speechTimestampsFileName,
      text: text,
      textByLanguage: textByLanguage,
      choices: choices,
      isTerminal: isTerminal,
      // rectangles: rectangles,
    );
  }

  static StoryChoice _toStoryChoice(YamlMap yamlMap) {
    Rect? rectangle;
    Color? borderColor;

    Map<String, String> textByLanguage = {};
    for (var locale in supportedNonDefaultLocales) {
      if (yamlMap['text-$locale'] != null) {
        textByLanguage[locale] = yamlMap['text-$locale'];
      }
    }

    if (yamlMap['rectangle'] != null) {
      var rectMap = yamlMap['rectangle'];
      rectangle = Rect.fromLTRB(
        rectMap['left'],
        rectMap['top'],
        rectMap['right'],
        rectMap['bottom'],
      );
    }

    if (yamlMap['borderColor'] != null) {
      String colorString = yamlMap['borderColor'];
      borderColor = Color(int.parse(colorString));
    }

    if (yamlMap['icon'] != null) {
      String iconString = yamlMap['icon'];
      IconData icon = getIconFromString(iconString);

      return StoryChoice(
        text: yamlMap['text'],
        nextPageId: yamlMap['nextPageId'],
        textByLanguage: textByLanguage,
        rectangle: rectangle,
        borderColor: borderColor,
        icon: icon,
      );
    }

    return StoryChoice(
      text: yamlMap['text'],
      nextPageId: yamlMap['nextPageId'],
      textByLanguage: textByLanguage,
      rectangle: rectangle,
      borderColor: borderColor,
    );
  }
}
