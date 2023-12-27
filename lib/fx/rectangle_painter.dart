import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedRectangle {
  final Rect rectangle;
  final Color initialBorderColor;
  final Color finalBorderColor;
  final double initialBorderWidth;
  final double finalBorderWidth;
  final double initialOpacity;
  final double finalOpacity;

  AnimatedRectangle({
    required this.rectangle,
    required this.initialBorderColor,
    required this.finalBorderColor,
    required this.initialBorderWidth,
    double? finalBorderWidth,
    required this.initialOpacity,
    double? finalOpacity,
  })  : finalBorderWidth = finalBorderWidth ?? initialBorderWidth,
        finalOpacity = finalOpacity ?? initialOpacity;

  Color currentBorderColor(Animation<double> animation) {
    return Color.lerp(initialBorderColor, finalBorderColor, animation.value)!;
  }

  double currentBorderWidth(Animation<double> animation) {
    return lerpDouble(initialBorderWidth, finalBorderWidth, animation.value)!;
  }

  double currentOpacity(Animation<double> animation) {
    return lerpDouble(initialOpacity, finalOpacity, animation.value)!;
  }

  void draw(Canvas canvas, Animation<double> animation) {
    final paint = Paint()
      ..color =
          currentBorderColor(animation).withOpacity(currentOpacity(animation))
      ..style = PaintingStyle.stroke
      ..strokeWidth = currentBorderWidth(animation);

    canvas.drawRect(rectangle, paint);
  }
}

class AnimatedRectanglePainter extends CustomPainter {
  final List<AnimatedRectangle> rectangles;
  final Animation<double> animation;

  AnimatedRectanglePainter(this.rectangles, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.isCompleted) return;
    if (animation.isDismissed) return;

    for (final rectangle in rectangles) {
      rectangle.draw(canvas, animation);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedRectangleWidget extends StatefulWidget {
  final List<AnimatedRectangle> rectangles;
  final AnimationController controller;
  final Curve curve;

  const AnimatedRectangleWidget({
    super.key,
    required this.rectangles,
    required this.controller,
    this.curve = Curves.easeOutCubic,
  });

  @override
  AnimatedRectangleWidgetState createState() => AnimatedRectangleWidgetState();
}

class AnimatedRectangleWidgetState extends State<AnimatedRectangleWidget>
    with SingleTickerProviderStateMixin {
  late final Animation<double> curve;

  @override
  void initState() {
    super.initState();

    curve = CurvedAnimation(
      parent: widget.controller,
      curve: widget.curve,
    );
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AnimatedRectanglePainter(widget.rectangles, curve),
    );
  }
}
