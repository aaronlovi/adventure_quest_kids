import 'package:yaml/yaml.dart';

import 'story_choice.dart';

class StoryPage {
  final String imageFileName;
  final String text;
  final Map<String, StoryChoice> choices;
  final bool isTerminal;

  const StoryPage({
    required this.imageFileName,
    required this.text,
    required this.choices,
    this.isTerminal = false,
  });

  factory StoryPage.fromYaml(YamlMap yamlMap) {
    String imageFileName = yamlMap['imageFileName'];
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
      text: text,
      choices: choices,
      isTerminal: isTerminal,
    );
  }
}
