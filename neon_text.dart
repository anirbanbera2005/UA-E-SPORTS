import 'package:flutter/material.dart';

class NeonText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "UA ESPORTS",
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.cyanAccent,
        shadows: [
          Shadow(blurRadius: 20, color: Colors.cyanAccent),
          Shadow(blurRadius: 40, color: Colors.blueAccent),
          Shadow(blurRadius: 60, color: Colors.purpleAccent),
        ],
      ),
    );
  }
}