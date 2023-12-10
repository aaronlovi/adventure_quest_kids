import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<List<Duration>> readTimestamps(
    String assetPath, double scaleFactor) async {
  try {
    final content = await rootBundle.loadString(assetPath);
    final timestamps =
        content.split('\n').where((line) => line.isNotEmpty).map((line) {
      final seconds = double.parse(line);
      final milliseconds = (seconds * 1000 / scaleFactor).round();
      return Duration(milliseconds: milliseconds);
    }).toList();
    return timestamps;
  } catch (e) {
    if (kDebugMode) {
      print('Error reading timestamps: $e');
    }
    return [];
  }
}
