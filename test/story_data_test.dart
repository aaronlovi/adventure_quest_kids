import 'dart:io';

import 'package:adventure_quest_kids/main.dart';
import 'package:adventure_quest_kids/model/story.dart';
import 'package:adventure_quest_kids/model/story_choice.dart';
import 'package:adventure_quest_kids/model/story_meta_data.dart';
import 'package:adventure_quest_kids/model/story_page.dart';
import 'package:adventure_quest_kids/services/yaml_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';
import 'package:yaml/yaml.dart';

/// Tests that check that the story data, and localized versions are valid
void main() {
  test('Load story data', () {
    List<StoryMetaData> storyMetaDataList = _loadStoryMetaDataList();

    for (var storyMetaData in storyMetaDataList) {
      String storyYamlString =
          File('${storyMetaData.storyDataFolder}/story_data.yaml')
              .readAsStringSync();
      YamlMap storyYamlMap = loadYaml(storyYamlString);
      Story story = YamlFactory.toStory(storyMetaData, storyYamlMap);

      if (kDebugMode) {
        print(
            'Story: ${storyMetaData.getTitle('')} (${storyMetaData.assetName})');
      }

      // Basic checks
      expect(storyYamlMap, isNotEmpty);
      expect(story.pages, isNotEmpty);
      expect(story.pages.containsKey(story.firstPageId), true);

      Set<String> pageIds = story.pages.keys.toSet();
      const int maxLevel = 25;

      StoryPage firstPage = story.pages[story.firstPageId]!;
      pageIds.remove(story.firstPageId);

      var pageStack = <Tuple2<StoryPage, int>>[];
      pageStack.add(Tuple2<StoryPage, int>(firstPage, 1));

      // Generally, does a DFS of the story graph, checking that all pages are reachable
      while (pageStack.isNotEmpty) {
        Tuple2<StoryPage, int> currentPageInfo = pageStack.removeLast();
        StoryPage currentPage = currentPageInfo.item1;
        int currentLevel = currentPageInfo.item2;

        // Check that the current page is not too deep
        expect(currentLevel <= maxLevel, true);

        // Process the current page

        if (currentPage.choices.isEmpty) expect(currentPage.isTerminal, true);

        // Checks that the current page's number of words matches the number
        // of per-word speech timestamps for default and all localized versions
        // of the page
        _ensureNumTimestampsMatchesNumWords(storyMetaData, currentPage);

        for (MapEntry<String, StoryChoice> choice
            in currentPage.choices.entries) {
          StoryPage? nextPage = story.pages[choice.value.nextPageId];

          expect(nextPage, isNotNull);

          if (nextPage != null) {
            pageStack.add(Tuple2<StoryPage, int>(nextPage, currentLevel + 1));
            pageIds.remove(choice.value.nextPageId);
          }
        }
      }

      // Check that all pages were visited
      expect(pageIds, isEmpty);
    }
  });

  test('Story metadata contains a valid set of terminal pages', () {
    List<StoryMetaData> storyMetaDataList = _loadStoryMetaDataList();

    for (var storyMetaData in storyMetaDataList) {
      String storyYamlString =
          File('${storyMetaData.storyDataFolder}/story_data.yaml')
              .readAsStringSync();
      YamlMap storyYamlMap = loadYaml(storyYamlString);
      Story story = YamlFactory.toStory(storyMetaData, storyYamlMap);

      Set<String> terminalPageIds = story.pages.entries
          .where((e) => e.value.isTerminal)
          .map((e) => e.key)
          .toSet();

      expect(setEquals(storyMetaData.terminalPageIds, terminalPageIds), true);
    }
  });
}

/// Checks that if there is both speech and speech timestamps for this page,
/// then the number of timestamps matches the number of words
void _ensureNumTimestampsMatchesNumWords(
  StoryMetaData storyMetaData,
  StoryPage currentPage,
) {
  _validatedLocalizedSpeechAndTimestamps(storyMetaData, currentPage);
  _validateDefaultLanguageSpeechAndTimestamps(storyMetaData, currentPage);
}

/// Checks that if there is both speech and speech timestamps for this page,
/// then the number of timestamps matches the number of words for each
/// localized version of the page
void _validatedLocalizedSpeechAndTimestamps(
  StoryMetaData storyMetaData,
  StoryPage currentPage,
) {
  for (var languageKey in currentPage.speechByLanguage.keys) {
    _checkSpeechTimestampsMatchWordCount(
        storyMetaData, currentPage, languageKey);
  }
}

/// Checks that if there is both speech and speech timestamps for this page,
/// then the number of timestamps matches the number of words for the default
/// language version of the page
void _validateDefaultLanguageSpeechAndTimestamps(
  StoryMetaData storyMetaData,
  StoryPage currentPage,
) {
  if (currentPage.speechFileName.isNotEmpty &&
      currentPage.speechTimestampsFileName.isNotEmpty) {
    _checkSpeechTimestampsMatchWordCount(storyMetaData, currentPage);
  }
}

/// Checks that the number of timestamps matches the number of words
/// for the given page and language
void _checkSpeechTimestampsMatchWordCount(
  StoryMetaData storyMetaData,
  StoryPage currentPage, [
  String? languageKey,
]) {
  if (languageKey != null) {
    // Check that the localized version exists
    expect(
      currentPage.speechTimestampsByLanguage.containsKey(languageKey),
      true,
    );
    expect(
      currentPage.textByLanguage.containsKey(languageKey),
      true,
    );
  }

  final String speechTimestampsFileName = languageKey != null
      ? currentPage.speechTimestampsByLanguage[languageKey]!
      : currentPage.speechTimestampsFileName;
  final String speechTimestampsString =
      File('${storyMetaData.speechFolder}/$speechTimestampsFileName')
          .readAsStringSync();

  final List<String> speechTimestampsList = speechTimestampsString.split('\n');
  final List<String> speechWordsList = languageKey != null
      ? currentPage.textByLanguage[languageKey]!.split(' ')
      : currentPage.text.split(' ');

  if (kDebugMode) {
    var speechFileName = languageKey != null
        ? currentPage.speechByLanguage[languageKey]
        : currentPage.speechFileName;
    print('\tSpeech: $speechFileName (${speechWordsList.length} words)'
        ' - $speechTimestampsFileName (${speechTimestampsList.length} timestamps)');
  }

  expect(speechTimestampsList.length, speechWordsList.length);
}

List<StoryMetaData> _loadStoryMetaDataList() {
  String metaDataYamlString = File('assets/story_list.yaml').readAsStringSync();
  YamlMap metaDataYamlMap = loadYaml(metaDataYamlString);
  var storyMetaDataList = <StoryMetaData>[];
  for (var storyItem in metaDataYamlMap['story_list'].keys) {
    StoryMetaData storyMetaData =
        getStoryMetadataFromYaml(metaDataYamlMap, storyItem);
    storyMetaDataList.add(storyMetaData);
  }
  return storyMetaDataList;
}
