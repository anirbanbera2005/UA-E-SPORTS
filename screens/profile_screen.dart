import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/components.dart';
import '../data/user_service.dart';
import 'wallet_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _avatarCtrl;
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? ''; 

  @override
  void initState() {
    super.initState();
    _avatarCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() { _avatarCtrl.dispose(); super.dispose(); }

  Widget _buildTopBar() {
    return Row(
      children: [
        if (Navigator.of(context).canPop()) ...[appBackButton(context), const SizedBox(width: 12)],
        const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.account_balance_wallet, color: EsportsColors.gold, size: 28),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid.isEmpty) return const Center(child: Text("Not Logged In", style: TextStyle(color: Colors.white)));

    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
          const ParticleBackground(count: 15, color: EsportsColors.neonPurple),
          SafeArea(
            child: StreamBuilder<UserProfile>(
              stream: UserService().getUserProfile(currentUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: EsportsColors.cyan));
                final user = snapshot.data ?? UserProfile(uid: currentUid, name: 'Player', email: '', avatarLetter: 'P');
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 16),
                      _buildHero(user),
                      const SizedBox(height: 16),
                      _buildDynamicStats(user),
                      const SizedBox(height: 16),
                      _buildGameIds(user),
                      const SizedBox(height: 16),
                      _buildAchievements(),
                      const SizedBox(height: 100),
                    ]
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(UserProfile user) {
    return GlassCard(
      opacity: 0.08,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _avatarCtrl, 
            builder: (_, __) {
              return Transform.translate(
                offset: Offset(0, -3 * sin(_avatarCtrl.value * 3.14)), 
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: EsportsColors.primaryGradient,
                    boxShadow: [BoxShadow(color: EsportsColors.electricBlue.withOpacity(0.3 + 0.1 * _avatarCtrl.value), blurRadius: 20)],
                  ),
                  child: Center(child: Text(user.avatarLetter, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white))),
                )
              );
            }
          ),
          const SizedBox(height: 12),
          Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(fontSize: 13, color: EsportsColors.textMuted)),
        ]
      ),
    );
  }

  Widget _buildDynamicStats(UserProfile user) {
    return GlassCard(
      opacity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const Row(children: [Icon(Icons.analytics, color: EsportsColors.cyan, size: 18), SizedBox(width: 8), Text('Statistics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))]),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _statTile('Total Matches', '${user.totalMatches}', EsportsColors.electricBlue)),
              Expanded(child: _statTile('Wins (Top 3)', '${user.wins}', EsportsColors.success)),
              Expanded(child: _statTile('Earnings', '₹ ${user.totalEarnings.toInt()}', EsportsColors.gold)),
            ]
          ),
        ]
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.15))),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: EsportsColors.textMuted), textAlign: TextAlign.center),
        ]
      ),
    );
  }

  Widget _buildGameIds(UserProfile user) {
    return GlassCard(
      opacity: 0.06, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const Row(children: [Icon(Icons.games, color: EsportsColors.cyan, size: 18), SizedBox(width: 8), Text('Game IDs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))]),
          const SizedBox(height: 12),
          if (user.gameIds.isEmpty) const Text('No Game IDs saved yet. Join a match to save one!', style: TextStyle(color: EsportsColors.textMuted, fontSize: 12)),
          ...user.gameIds.entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: glassDecoration(opacity: 0.05, borderRadius: 10),
            child: Row(
              children: [
                Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                const Spacer(),
                Text(e.value, style: const TextStyle(fontSize: 12, color: EsportsColors.textMuted, fontFamily: 'monospace')),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 14, color: EsportsColors.textDim),
              ]
            ),
          )),
        ]
      )
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {'title': '1st Place Free Fire Squad', 'time': '2 days ago', 'color': EsportsColors.gold},
      {'title': '2nd Place BGMI Solo', 'time': '1 week ago', 'color': const Color(0xFFBDBDBD)},
      {'title': '3rd Place Valorant', 'time': '2 weeks ago', 'color': const Color(0xFFFF8A65)},
    ];
    return GlassCard(
      opacity: 0.06, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const Row(children: [Icon(Icons.workspace_premium, color: EsportsColors.gold, size: 18), SizedBox(width: 8), Text('Recent Achievements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))]),
          const SizedBox(height: 12),
          ...achievements.map((a) {
            final color = a['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.25))),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: color, size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(a['time'] as String, style: const TextStyle(fontSize: 11, color: EsportsColors.textMuted)),
                  ])),
                ]
              ),
            );
          }),
        ]
      )
    );
  }
}