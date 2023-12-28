import 'package:flutter/material.dart';

class StoryText extends StatelessWidget {
  final String word;
  final int index;
  final ValueNotifier<int> currentWordIndex;
  final Color highlightedWordGlowColor;
  final Color textColor;

  const StoryText({
    super.key,
    required this.word,
    required this.index,
    required this.currentWordIndex,
    required this.highlightedWordGlowColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final normalTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textColor,
    );

    final highlightedTextStyle =
        normalTextStyle.copyWith(decoration: TextDecoration.underline);

    var opacity =
        index == currentWordIndex.value && currentWordIndex.value != -1
            ? 1.0
            : 0.0;

    return Stack(
      children: [
        Text(word, style: normalTextStyle),
        AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 500),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: highlightedWordGlowColor.withOpacity(0.6),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Text(word, style: highlightedTextStyle),
          ),
        ),
      ],
    );
  }
}
