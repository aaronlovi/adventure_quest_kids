import 'package:flutter/material.dart';

import 'story_text.dart';

class AnimatedStoryText extends StatelessWidget {
  final List<String> words;
  final ValueNotifier<int> currentWordIndex;
  final Color highlightedWordGlowColor;
  final Color textColor;

  const AnimatedStoryText({
    super.key,
    required this.words,
    required this.currentWordIndex,
    required this.highlightedWordGlowColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: currentWordIndex,
      builder: (context, _) {
        const textStyle = TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        );

        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: textStyle,
            children: words.asMap().entries.expand((entry) {
              int index = entry.key;
              String word = entry.value;
              return [
                WidgetSpan(
                  child: StoryText(
                    word: word,
                    index: index,
                    currentWordIndex: currentWordIndex,
                    highlightedWordGlowColor: highlightedWordGlowColor,
                    textColor: textColor,
                  ),
                ),
                const TextSpan(text: ' '),
              ];
            }).toList(),
          ),
        );
      },
    );
  }
}
