import 'dart:ui';

import 'story_choice.dart';

class StoryPage {
  final String imageFileName;
  final String soundFileName;
  final String speechFileName;
  final String speechTimestampsFileName;
  final String text;
  final Map<String, String> textByLanguage;
  final Map<String, StoryChoice> choices;
  final bool isTerminal;
  final List<Rect> rectangles;

  const StoryPage({
    required this.imageFileName,
    required this.soundFileName,
    required this.speechFileName,
    required this.speechTimestampsFileName,
    required this.text,
    this.textByLanguage = const <String, String>{},
    required this.choices,
    this.isTerminal = false,
    this.rectangles = const <Rect>[
      Rect.fromLTRB(0.1, 0.1, 0.2, 0.2),
      Rect.fromLTRB(0.8, 0.8, 0.9, 0.9),
    ],
  });
}
