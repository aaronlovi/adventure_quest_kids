import 'story_choice.dart';

class StoryPage {
  final String imageFileName;
  final String soundFileName;
  final String speechFileName;
  final String text;
  final Map<String, StoryChoice> choices;
  final bool isTerminal;

  const StoryPage({
    required this.imageFileName,
    required this.soundFileName,
    required this.speechFileName,
    required this.text,
    required this.choices,
    this.isTerminal = false,
  });
}
