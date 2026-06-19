import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import '../core/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding, margin;
  final double borderRadius, opacity;
  final Color? borderColor;
  final List<BoxShadow>? shadows;

  const GlassCard({super.key, required this.child, this.padding, this.margin, this.borderRadius = 16, this.opacity = 0.08, this.borderColor, this.shadows});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: glassDecoration(opacity: opacity, borderRadius: borderRadius, borderColor: borderColor, shadows: shadows),
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  final bool breathing, isLoading;
  final double height;

  const NeonButton({super.key, required this.label, this.onPressed, this.color = EsportsColors.electricBlue, this.icon, this.breathing = false, this.isLoading = false, this.height = 50});

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    if (widget.breathing) _ctrl.repeat(reverse: true);
    _glow = Tween<double>(begin: 0.2, end: 0.6).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) {
        final glowVal = widget.breathing ? _glow.value : 0.3;
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: widget.color.withOpacity(glowVal), blurRadius: 20, spreadRadius: -2)],
          ),
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: widget.isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    if (widget.icon != null) ...[Icon(widget.icon, size: 20), const SizedBox(width: 8)],
                    Text(widget.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ]),
          ),
        );
      },
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  final double value;
  final String prefix, suffix;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({super.key, required this.value, this.prefix = '', this.suffix = '', this.style, this.duration = const Duration(milliseconds: 800)});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) {
        String text;
        if (v == v.roundToDouble()) {
          text = '$prefix${v.toInt()}$suffix';
        } else {
          text = '$prefix${v.toStringAsFixed(1)}$suffix';
        }
        return Text(text, style: style ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white));
      },
    );
  }
}

class TagBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const TagBadge({super.key, required this.text, required this.color, this.fontSize = 9});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
    );
  }
}

class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const StatBox({super.key, required this.label, required this.value, this.color = EsportsColors.cyan, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (icon != null) Icon(icon, color: color, size: 18),
      if (icon != null) const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, color: EsportsColors.textMuted)),
    ]);
  }
}

Widget appBackButton(BuildContext context) {
  return GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: glassDecoration(opacity: 0.1, borderRadius: 12),
      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
    ),
  );
}

String fmtCountdown(Duration d) {
  if (d.isNegative) return 'LIVE';
  final h = d.inHours, m = d.inMinutes.remainder(60), s = d.inSeconds.remainder(60);
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

class ParticleBackground extends StatefulWidget {
  final int count;
  final Color color;
  const ParticleBackground({super.key, this.count = 30, this.color = EsportsColors.electricBlue});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final r = Random();
    _particles = List.generate(widget.count, (_) => _Particle(
      x: r.nextDouble(), y: r.nextDouble(),
      size: 1 + r.nextDouble() * 3,
      speed: 0.1 + r.nextDouble() * 0.4,
      opacity: 0.1 + r.nextDouble() * 0.3,
    ));
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _ctrl, builder: (_, __) {
      return CustomPaint(
        painter: _ParticlePainter(_particles, widget.color, _ctrl.value),
        size: Size.infinite,
      );
    });
  }
}

class _Particle {
  double x, y, size, speed, opacity;
  _Particle({required this.x, required this.y, required this.size, required this.speed, required this.opacity});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final double progress;

  _ParticlePainter(this.particles, this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y + progress * p.speed) % 1.0;
      final paint = Paint()..color = color.withOpacity(p.opacity * (1 - y));
      canvas.drawCircle(Offset(p.x * size.width, y * size.height), p.size, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NeonProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const NeonProgressBar({super.key, required this.value, this.color = EsportsColors.electricBlue, this.height = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(height / 2)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
          ),
        ),
      ),
    );
  }
}