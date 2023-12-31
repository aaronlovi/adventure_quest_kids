import 'package:flutter/material.dart';

class StoryChoice {
  final String text;
  final Map<String, String> textByLanguage;
  final String nextPageId;
  final Rect? rectangle;
  final Color? borderColor;
  final IconData? icon;

  const StoryChoice({
    required this.text,
    required this.nextPageId,
    this.textByLanguage = const <String, String>{},
    this.rectangle,
    this.borderColor,
    this.icon,
  });
}
