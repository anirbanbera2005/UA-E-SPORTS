import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/components.dart';
import '../data/contest_service.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String contestId;

  const WaitingRoomScreen({
    super.key,
    required this.contestId,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  void _shareMatch(ExtendedMatchData match) {
    final String shareText = 
        "🔥 Join me in the ${match.gameName} Tournament! 🔥\n\n"
        "Mode: ${match.matchType} (${match.matchTag})\n"
        "Map: ${match.mapName}\n"
        "Prize Pool: ₹${match.prizePool}\n"
        "Entry: ${match.isFree ? 'FREE' : '₹${match.entryFee}'}\n\n"
        "Download the UA ESPORTS app to register!";
    Share.share(shareText);
  }

  void _scheduleReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder set! We will notify you 10 minutes before the room reveals.'),
        backgroundColor: EsportsColors.cyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
          const ParticleBackground(count: 20, color: EsportsColors.neonPurple),
          
          SafeArea(
            child: StreamBuilder<ExtendedMatchData>(
              stream: ContestService().getContestStream(widget.contestId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: EsportsColors.cyan));
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Text('Error loading room data.', style: Theme.of(context).textTheme.bodyLarge),
                  );
                }

                final match = snapshot.data!;
                
                // FIX: Hardened against empty gradientColors array
                final Color matchColor = match.gradientColors.isNotEmpty 
                    ? Color(match.gradientColors.first) 
                    : EsportsColors.cyan;
                
                final timeLeft = match.roomRevealTime.difference(DateTime.now());
                final isRevealed = timeLeft.isNegative;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          appBackButton(context),
                          const SizedBox(width: 12),
                          const Text('Waiting Room', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            
                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, __) {
                                final scale = 0.95 + 0.05 * _pulseCtrl.value;
                                return Transform.scale(
                                  scale: scale,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 120, height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(colors: [matchColor.withOpacity(0.3), matchColor.withOpacity(0.1)]),
                                          boxShadow: [BoxShadow(color: matchColor.withOpacity(0.2 + 0.1 * _pulseCtrl.value), blurRadius: 30)],
                                        ),
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.asset(gameLogoAssetFor(match.gameName), width: 70, height: 70, fit: BoxFit.cover),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(match.gameName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                                    ],
                                  ),
                                );
                              }
                            ),
                            const SizedBox(height: 30),

                            GlassCard(
                              opacity: 0.1,
                              borderColor: isRevealed ? EsportsColors.success : EsportsColors.border,
                              child: Column(
                                children: [
                                  if (!isRevealed) ...[
                                    const Text('Room ID & Password will show in:', style: TextStyle(color: EsportsColors.textMuted, fontSize: 14)),
                                    const SizedBox(height: 12),
                                    Text(
                                      _formatDuration(timeLeft),
                                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: matchColor, shadows: [Shadow(color: matchColor.withOpacity(0.5), blurRadius: 20)]),
                                    ),
                                  ] else ...[
                                    const Text('MATCH IS READY!', style: TextStyle(color: EsportsColors.success, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                                    const SizedBox(height: 20),
                                    
                                    const Text('ROOM ID', style: TextStyle(color: EsportsColors.textMuted, fontSize: 12)),
                                    SelectableText(
                                      match.roomId.isEmpty ? "Waiting for Admin..." : match.roomId,
                                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    const Text('PASSWORD', style: TextStyle(color: EsportsColors.textMuted, fontSize: 12)),
                                    SelectableText(
                                      match.roomPassword.isEmpty ? "Waiting for Admin..." : match.roomPassword,
                                      style: const TextStyle(fontSize: 28, color: EsportsColors.live, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            GlassCard(
                              opacity: 0.06,
                              child: Column(
                                children: [
                                  _detailRow('Mode', '${match.matchType} (${match.matchTag})'),
                                  _detailRow('Map', match.mapName),
                                  _detailRow('Entry Fee', match.isFree ? 'FREE' : '₹${match.entryFee}'),
                                  _detailRow('Prize Pool', '₹${match.prizePool}'),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(color: EsportsColors.border),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Participants', style: TextStyle(fontSize: 14, color: EsportsColors.textMuted)),
                                      Text('${match.filledSlots}/${match.totalSlots}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: EsportsColors.cyan)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  NeonProgressBar(value: match.fillRate, color: matchColor),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),

                            Row(
                              children: [
                                Expanded(
                                  child: NeonButton(
                                    label: 'INVITE',
                                    icon: Icons.share,
                                    color: EsportsColors.neonPurple,
                                    onPressed: () => _shareMatch(match),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: NeonButton(
                                    label: 'REMINDER',
                                    icon: Icons.alarm,
                                    color: EsportsColors.cyan,
                                    onPressed: _scheduleReminder,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: EsportsColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}