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
        print('Story: ${storyMetaData.title} (${storyMetaData.assetName})');
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

        // Check that if there is both speech and speech timestamps for this page, then the number of timestamps matches the number of words
        if (currentPage.speechFileName.isNotEmpty &&
            currentPage.speechTimestampsFileName.isNotEmpty) {
          String speechTimestampsString = File(
                  '${storyMetaData.speechFolder}/${currentPage.speechTimestampsFileName}')
              .readAsStringSync();
          List<String> speechTimestampsList =
              speechTimestampsString.split('\n');
          List<String> speechWordsList = currentPage.text.split(' ');

          if (kDebugMode) {
            print(
                '\tSpeech: ${currentPage.speechFileName} (${speechWordsList.length} words) - ${currentPage.speechTimestampsFileName} (${speechTimestampsList.length} timestamps)');
          }

          expect(speechTimestampsList.length, speechWordsList.length);
        }

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
