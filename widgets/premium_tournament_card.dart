import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumTournamentCard extends StatefulWidget {
  final String image, game, mode, prize, entry, timer;
  final VoidCallback onTap;

  const PremiumTournamentCard({
    super.key, required this.image, required this.game, required this.mode,
    required this.prize, required this.entry, required this.timer, required this.onTap,
  });

  @override
  State<PremiumTournamentCard> createState() => _PremiumTournamentCardState();
}

class _PremiumTournamentCardState extends State<PremiumTournamentCard> with SingleTickerProviderStateMixin {
  late AnimationController glow;

  @override
  void initState() {
    super.initState();
    glow = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() { glow.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: glow,
        builder: (_, __) {
          return Transform.scale(
            scale: 0.98 + glow.value * .02,
            child: Container(
              height: 340,
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(.30 * glow.value), blurRadius: 35),
                  BoxShadow(color: Colors.purple.withOpacity(.20 * glow.value), blurRadius: 50),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(widget.image, fit: BoxFit.cover, width: double.infinity),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(.3), Colors.black]),
                    ),
                  ),
                  Positioned(
                    top: 16, left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: Colors.orange),
                      child: const Text("FEATURED", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  Positioned(bottom: 120, left: 20, child: Text(widget.game, style: const TextStyle(fontSize: 34, color: Colors.white, fontWeight: FontWeight.w900))),
                  Positioned(bottom: 88, left: 20, child: Text(widget.mode, style: TextStyle(color: Colors.white.withOpacity(.8)))),
                  Positioned(
                    bottom: 24, left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.prize, style: const TextStyle(fontSize: 36, color: Colors.amber, fontWeight: FontWeight.w900)),
                        Text("Entry ${widget.entry}", style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 18, bottom: 24,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                          child: Text(widget.timer, style: const TextStyle(color: Colors.cyan)),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 120, height: 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Colors.blue, Colors.purple])),
                          child: const Center(child: Text("JOIN NOW", style: TextStyle(fontWeight: FontWeight.w900))),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: glow.value * 0.8, sigmaY: glow.value * 0.8),
                        child: Container(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}