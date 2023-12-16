import 'package:flutter/material.dart';

abstract class Constants {
  static const VisualDensity mostDense = VisualDensity(
    horizontal: VisualDensity.minimumDensity,
    vertical: VisualDensity.minimumDensity,
  );

  static const oneSecond = Duration(milliseconds: 1000);
  static const halfSecond = Duration(milliseconds: 500);
  static const twoHundredMilliseconds = Duration(milliseconds: 200);
  static const hundredMilliseconds = Duration(milliseconds: 100);

  static const String storyListRoute = '/story-list';
  static const String frontPageRoute = '/front-page';
  static const String settingsPageRoute = '/settings';

  static final iconColors = <Color>[
    Colors.red,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];
}

extension BuildContextExtensions on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
}
