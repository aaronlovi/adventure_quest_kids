import 'package:flutter/material.dart';

import 'story_text.dart';

class AnimatedStoryText extends StatelessWidget {
  final List<String> words;
  final ValueNotifier<int> currentWordIndex;

  const AnimatedStoryText(
      {super.key, required this.words, required this.currentWordIndex});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: currentWordIndex,
      builder: (context, _) {
        const textStyle = TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
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
                      currentWordIndex: currentWordIndex),
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
