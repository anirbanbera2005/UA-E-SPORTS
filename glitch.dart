import 'package:flutter/material.dart';

class GlitchWidget extends StatelessWidget {
  final Widget child;

  const GlitchWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(offset: Offset(-2, 0), child: child),
        Transform.translate(offset: Offset(2, 0), child: child),
        child,
      ],
    );
  }
}