import 'package:flutter/material.dart';
import 'dart:math';

import '../widgets/particle.dart';
import '../widgets/lightning.dart';
import '../widgets/glitch.dart';
import '../widgets/neon_text.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController logoCtrl;
  late AnimationController textCtrl;
  late AnimationController rotateCtrl;
  late AnimationController lightningCtrl;
  late AnimationController flashCtrl;

  @override
  void initState() {
    super.initState();

    logoCtrl = AnimationController(vsync: this, duration: Duration(seconds: 2))..forward();
    textCtrl = AnimationController(vsync: this, duration: Duration(seconds: 2));
    rotateCtrl = AnimationController(vsync: this, duration: Duration(seconds: 6))..repeat();

    lightningCtrl = AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    flashCtrl = AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    Future.delayed(Duration(milliseconds: 900), () {
      lightningCtrl.forward().then((_) {
        flashCtrl.forward(from: 0);
      });
    });

    Future.delayed(Duration(seconds: 2), () {
      textCtrl.forward();
    });

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    logoCtrl.dispose();
    textCtrl.dispose();
    rotateCtrl.dispose();
    lightningCtrl.dispose();
    flashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ParticleBackground(),

          AnimatedBuilder(
            animation: lightningCtrl,
            builder: (_, __) => CustomPaint(
              painter: LightningPainter(lightningCtrl.value),
              size: Size.infinite,
            ),
          ),

          AnimatedBuilder(
            animation: flashCtrl,
            builder: (_, __) => Opacity(
              opacity: (1 - flashCtrl.value) * 0.8,
              child: Container(color: Colors.white),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: logoCtrl,
                  builder: (_, __) {
                    double scale = Curves.elasticOut.transform(logoCtrl.value);

                    return Transform.scale(
                      scale: scale,
                      child: GlitchWidget(
                        child: Image.asset("assets/logo.png", height: 120),
                      ),
                    );
                  },
                ),

                SizedBox(height: 30),

                AnimatedBuilder(
                  animation: textCtrl,
                  builder: (_, __) => Opacity(
                    opacity: textCtrl.value,
                    child: AnimatedBuilder(
                      animation: rotateCtrl,
                      builder: (_, __) => Transform.rotate(
                        angle: rotateCtrl.value * 2 * pi,
                        child: NeonText(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}