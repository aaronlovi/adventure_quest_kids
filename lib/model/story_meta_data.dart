import 'dart:io';
import 'package:adventure_quest_kids/model/story.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class StoryMetaData {
  final String assetName;
  final String title;
  final String subTitle;
  final String firstPageId;

  StoryMetaData(
      {required this.assetName,
      required this.title,
      required this.firstPageId,
      required this.subTitle});

  Future<Story> getStory({bool isUnitTest = false}) async {
    String yamlString = isUnitTest
        ? await File('$storyDataFolder/story_data.yaml').readAsString()
        : await rootBundle.loadString('$storyDataFolder/story_data.yaml');
    YamlMap yamlMap = loadYaml(yamlString);
    return Story.fromYaml(this, yamlMap);
  }

  String get assetsFolder => 'assets/$assetName';

  String get imagesFolder => '$assetsFolder/images';

  String get soundsFolder => '$assetsFolder/sounds';

  String get storyDataFolder => '$assetsFolder/story_data';

  String get fullTitle => subTitle.isEmpty ? title : '$title: $subTitle';
}
