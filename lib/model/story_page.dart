import 'story_choice.dart';

class StoryPage {
  final String imageFileName;
  final String soundFileName;
  final String speechFileName;
  final String speechTimestampsFileName;
  final String text;
  final Map<String, String> textByLanguage;
  final Map<String, String> speechByLanguage;
  final Map<String, String> speechTimestampsByLanguage;
  final Map<String, StoryChoice> choices;
  final bool isTerminal;

  const StoryPage({
    required this.imageFileName,
    required this.soundFileName,
    required this.speechFileName,
    required this.speechTimestampsFileName,
    required this.text,
    this.textByLanguage = const <String, String>{},
    this.speechByLanguage = const <String, String>{},
    this.speechTimestampsByLanguage = const <String, String>{},
    required this.choices,
    this.isTerminal = false,
  });
}
