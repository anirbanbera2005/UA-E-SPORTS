import 'package:flutter/material.dart';
import 'dart:math';

class LightningPainter extends CustomPainter {
  final double progress;
  LightningPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;

    final glow = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.7)
      ..strokeWidth = 6;

    Path path = Path();
    double x = size.width / 2;
    double y = 0;

    path.moveTo(x, y);

    Random r = Random();

    while (y < size.height * 0.4 * progress) {
      x += r.nextDouble() * 20 - 10;
      y += r.nextDouble() * 25 + 10;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, glow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}