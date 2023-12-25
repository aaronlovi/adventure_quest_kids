import 'dart:math';

import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final AnimationController animationController;

  ParticlePainter(this.particles, this.animationController);

  @override
  void paint(Canvas canvas, Size size) {
    if (!animationController.isAnimating) return;

    for (var particle in particles) {
      final position =
          particle.position + particle.velocity * animationController.value;
      final paint = Paint()..color = particle.color;
      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticleField extends StatefulWidget {
  final List<Particle> particles;
  final AnimationController controller;

  const ParticleField({
    super.key,
    required this.particles,
    required this.controller,
  });

  @override
  ParticleFieldState createState() => ParticleFieldState();
}

class ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() => setState(() {}));

    particles = widget.particles;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(particles, widget.controller),
    );
  }
}

List<Particle> generateParticles({
  required Rect rectangle,
  required int count,
  required double minSize,
  required double maxSize,
  required Color color,
  required Duration animationDuration,
}) {
  final random = Random();
  return List.generate(count, (_) {
    final dx = rectangle.left + random.nextDouble() * rectangle.width;
    final dy = rectangle.top + random.nextDouble() * rectangle.height;
    final size = minSize + random.nextDouble() * (maxSize - minSize);

    // Determine a random point on the edge of the rectangle
    final edgePoint = _randomPointOnEdge(rectangle, random);

    // Calculate the velocity needed to reach the edge point in the given duration
    final velocity = Offset(
      (edgePoint.dx - dx) / animationDuration.inSeconds,
      (edgePoint.dy - dy) / animationDuration.inSeconds,
    );

    return Particle(
      position: Offset(dx, dy),
      velocity: velocity,
      size: size,
      color: color,
    );
  });
}

Offset _randomPointOnEdge(Rect rectangle, Random random) {
  final side = random.nextInt(4);
  switch (side) {
    case 0: // top
      return Offset(rectangle.left + random.nextDouble() * rectangle.width,
          rectangle.top);
    case 1: // right
      return Offset(rectangle.right,
          rectangle.top + random.nextDouble() * rectangle.height);
    case 2: // bottom
      return Offset(rectangle.left + random.nextDouble() * rectangle.width,
          rectangle.bottom);
    default: // left
      return Offset(rectangle.left,
          rectangle.top + random.nextDouble() * rectangle.height);
  }
}
