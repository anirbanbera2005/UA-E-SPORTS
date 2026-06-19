import 'package:flutter/material.dart';
import 'dart:math';

class Particle {
  double x, y, speed, size;
  Particle(this.x, this.y, this.speed, this.size);
}

class ParticleBackground extends StatefulWidget {
  @override
  _ParticleBackgroundState createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {

  late AnimationController ctrl;
  List<Particle> particles = [];
  Random r = Random();

  @override
  void initState() {
    super.initState();

    ctrl = AnimationController(vsync: this, duration: Duration(seconds: 10))
      ..addListener(update)
      ..repeat();

    for (int i = 0; i < 80; i++) {
      particles.add(Particle(
          r.nextDouble(), r.nextDouble(),
          r.nextDouble() * 0.003,
          r.nextDouble() * 3));
    }
  }

  void update() {
    for (var p in particles) {
      p.y -= p.speed;
      if (p.y < 0) {
        p.y = 1;
        p.x = r.nextDouble();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(particles),
      size: Size.infinite,
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var p in particles) {
      paint.color = Colors.cyanAccent.withOpacity(0.7);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}