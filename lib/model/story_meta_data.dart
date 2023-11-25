import 'dart:io';
import 'package:adventure_quest_kids/model/story.dart';
import 'package:yaml/yaml.dart';

class StoryMetaData {
  final String assetName;
  final String title;
  final String firstPageId;

  StoryMetaData(
      {required this.assetName,
      required this.title,
      required this.firstPageId});

  Future<Story> getStory() async {
    String yamlString =
        await File('$storyDataFolder/story_data.yaml').readAsString();
    YamlMap yamlMap = loadYaml(yamlString);
    return Story.fromYaml(this, yamlMap);
  }

  String get assetsFolder => 'assets/$assetName';

  String get imagesFolder => '$assetsFolder/images';

  String get storyDataFolder => '$assetsFolder/story_data';
}
