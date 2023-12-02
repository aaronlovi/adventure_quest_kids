import 'package:flutter/material.dart';

abstract class Constants {
  static const VisualDensity mostDense = VisualDensity(
    horizontal: VisualDensity.minimumDensity,
    vertical: VisualDensity.minimumDensity,
  );

  static const oneSecond = Duration(milliseconds: 1000);
}

extension BuildContextExtensions on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
}
