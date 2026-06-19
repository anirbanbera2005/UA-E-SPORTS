import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/components.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _tab = 0;
  final _tabs = ['All', 'Matches', 'Wallet', 'Offers', 'System'];
  final _notifs = [
    {'title': 'Match Starting Soon!', 'body': 'BGMI Squad starts in 30 minutes. Get ready!', 'cat': 'Matches', 'time': '5m', 'icon': Icons.sports_esports, 'color': EsportsColors.electricBlue, 'priority': 'high'},
    {'title': '₹2,500 Credited', 'body': 'Won BGMI Squad Match. Prize added to wallet.', 'cat': 'Wallet', 'time': '2h', 'icon': Icons.account_balance_wallet, 'color': EsportsColors.success, 'priority': 'normal'},
    {'title': 'Weekend Mega Contest!', 'body': '₹50,000 prize pool. Join now!', 'cat': 'Offers', 'time': '4h', 'icon': Icons.local_offer, 'color': EsportsColors.gold, 'priority': 'high'},
    {'title': 'New Game Added', 'body': 'Apex Legends matches now available.', 'cat': 'System', 'time': '1d', 'icon': Icons.new_releases, 'color': EsportsColors.neonPurple, 'priority': 'normal'},
    {'title': 'Match Result', 'body': 'Free Fire BR - You ranked #18.', 'cat': 'Matches', 'time': '1d', 'icon': Icons.leaderboard, 'color': EsportsColors.live, 'priority': 'normal'},
    {'title': 'Withdrawal Processed', 'body': '₹1,000 sent to your bank account.', 'cat': 'Wallet', 'time': '2d', 'icon': Icons.check_circle, 'color': EsportsColors.success, 'priority': 'normal'},
    {'title': 'App Update', 'body': 'Version 2.1 with new features.', 'cat': 'System', 'time': '3d', 'icon': Icons.system_update, 'color': EsportsColors.cyan, 'priority': 'low'},
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_tab == 0) return _notifs;
    return _notifs.where((n) => n['cat'] == _tabs[_tab]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
        SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            appBackButton(context), const SizedBox(width: 12),
            const Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const Spacer(),
            GestureDetector(onTap: () {}, child: const Text('Clear All', style: TextStyle(fontSize: 12, color: EsportsColors.cyan))),
          ])),
          SizedBox(height: 36, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _tabs.length,
            itemBuilder: (_, i) {
              final sel = _tab == i;
              return GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: sel ? EsportsColors.primaryGradient : null,
                    color: sel ? null : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: sel ? null : Border.all(color: EsportsColors.border),
                  ),
                  child: Center(child: Text(_tabs[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : EsportsColors.textMuted))),
                ),
              );
            },
          )),
          const SizedBox(height: 8),
          Expanded(child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final n = _filtered[i];
              final color = n['color'] as Color;
              final isHigh = n['priority'] == 'high';
              return Dismissible(
                key: ValueKey(n['title']),
                direction: DismissDirection.endToStart,
                background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: EsportsColors.live.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.delete, color: EsportsColors.live)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isHigh ? color.withOpacity(0.08) : EsportsColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isHigh ? color.withOpacity(0.25) : EsportsColors.border),
                  ),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: Icon(n['icon'] as IconData, color: color, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(n['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
                        Text(n['time'] as String, style: const TextStyle(fontSize: 10, color: EsportsColors.textDim)),
                      ]),
                      const SizedBox(height: 3),
                      Text(n['body'] as String, style: const TextStyle(fontSize: 11, color: EsportsColors.textMuted)),
                    ])),
                  ]),
                ),
              );
            },
          )),
        ])),
      ]),
    );
  }
}