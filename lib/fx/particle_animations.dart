import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract class Particle {
  void draw(Canvas canvas, Animation<double> animation) {
    // Do nothing by default
  }
}

class CircularParticle extends Particle {
  Offset initialOffset;
  Offset finalOffset;
  double minSize;
  double maxSize;
  Color color;
  double initialOpacity;
  double finalOpacity;

  CircularParticle({
    required this.initialOffset,
    required this.finalOffset,
    required this.minSize,
    double? maxSize,
    required this.color,
    required this.initialOpacity,
    double? finalOpacity,
  })  : maxSize = maxSize ?? minSize,
        finalOpacity = finalOpacity ?? initialOpacity;

  Offset currentPosition(Animation<double> animation) {
    return Offset.lerp(initialOffset, finalOffset, animation.value)!;
  }

  double currentSize(Animation<double> animation) {
    return ui.lerpDouble(minSize, maxSize, animation.value)!;
  }

  double currentOpacity(Animation<double> animation) {
    return ui.lerpDouble(initialOpacity, finalOpacity, animation.value)!;
  }

  @override
  void draw(Canvas canvas, Animation<double> animation) {
    final position = currentPosition(animation);
    final size = currentSize(animation);
    final opacity = currentOpacity(animation);
    final paint = Paint()..color = color.withOpacity(opacity);
    canvas.drawCircle(position, size, paint);
  }
}

class IconParticle extends Particle {
  Offset initialOffset;
  Offset finalOffset;
  double minSize;
  double maxSize;
  IconData icon;
  Color color;
  double initialOpacity;
  double finalOpacity;

  IconParticle({
    required this.initialOffset,
    required this.finalOffset,
    required this.icon,
    required this.color,
    required this.initialOpacity,
    double? finalOpacity,
    required this.minSize,
    double? maxSize,
  })  : finalOpacity = finalOpacity ?? initialOpacity,
        maxSize = maxSize ?? minSize;

  Offset currentPosition(Animation<double> animation) {
    return Offset.lerp(initialOffset, finalOffset, animation.value)!;
  }

  double currentSize(Animation<double> animation) {
    return ui.lerpDouble(minSize, maxSize, animation.value)!;
  }

  double currentOpacity(Animation<double> animation) {
    return ui.lerpDouble(initialOpacity, finalOpacity, animation.value)!;
  }

  @override
  void draw(Canvas canvas, Animation<double> animation) {
    final offset = currentPosition(animation);
    final color_ = color.withOpacity(currentOpacity(animation));
    final size = currentSize(animation);

    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontFamily: 'MaterialIcons'),
    )
      ..pushStyle(ui.TextStyle(color: color_, fontSize: size))
      ..addText(String.fromCharCode(icon.codePoint));

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: size));

    canvas.drawParagraph(paragraph, offset);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;

  ParticlePainter(this.particles, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.isCompleted) return;
    if (animation.isDismissed) return;

    for (var particle in particles) {
      particle.draw(canvas, animation);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticleField extends StatefulWidget {
  final List<Particle> particles;
  final AnimationController controller;
  final Curve curve;

  const ParticleField({
    super.key,
    required this.particles,
    required this.controller,
    this.curve = Curves.easeOutQuart,
  });

  @override
  ParticleFieldState createState() => ParticleFieldState();
}

class ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final Animation<double> curve;

  @override
  void initState() {
    super.initState();

    if (!mounted) return;

    curve = CurvedAnimation(
      parent: widget.controller,
      curve: widget.curve,
    );
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(widget.particles, curve),
    );
  }
}

List<CircularParticle> generateBurstParticles({
  required Rect rectangle,
  required int count,
  required double minSize,
  required double maxSize,
  required Color color,
  double initialOpacity = 1.0,
  double finalOpacity = 0.0,
  double jitterFactor = 0.1,
}) {
  final random = Random();
  return List.generate(count, (_) {
    final initialX = rectangle.left +
        rectangle.width / 2 +
        (random.nextDouble() * 2 - 1) * jitterFactor * rectangle.width;
    final initialY = rectangle.top +
        rectangle.height / 2 +
        (random.nextDouble() * 2 - 1) * jitterFactor * rectangle.height;
    final finalX = rectangle.left + random.nextDouble() * rectangle.width;
    final finalY = rectangle.top + random.nextDouble() * rectangle.height;
    final particleSize = minSize + random.nextDouble() * (maxSize - minSize);

    return CircularParticle(
      initialOffset: Offset(initialX, initialY),
      finalOffset: Offset(finalX, finalY),
      minSize: particleSize,
      color: color,
      initialOpacity: initialOpacity,
      finalOpacity: finalOpacity,
    );
  });
}

List<IconParticle> generateIconParticles({
  required IconData icon,
  required int count,
  required Rect rectangle,
  required double minSize,
  required double maxSize,
  required Color color,
  double initialOpacity = 1.0,
  double finalOpacity = 0.0,
  double jitterFactor = 0.2,
}) {
  final random = Random();
  return List.generate(count, (_) {
    final particleSize = minSize + random.nextDouble() * (maxSize - minSize);
    final initialX = rectangle.left +
        rectangle.width / 2 +
        (random.nextDouble() * 2 - 1) * jitterFactor * rectangle.width -
        particleSize / 2;
    final initialY = rectangle.top +
        rectangle.height / 2 +
        (random.nextDouble() * 2 - 1) * jitterFactor * rectangle.height -
        particleSize / 2;
    final finalX = rectangle.left +
        random.nextDouble() * rectangle.width -
        particleSize / 2;
    final finalY = rectangle.top +
        random.nextDouble() * rectangle.height -
        particleSize / 2;

    return IconParticle(
      initialOffset: Offset(initialX, initialY),
      finalOffset: Offset(finalX, finalY),
      icon: icon,
      color: color,
      minSize: particleSize,
      initialOpacity: initialOpacity,
      finalOpacity: finalOpacity,
    );
  });
}
