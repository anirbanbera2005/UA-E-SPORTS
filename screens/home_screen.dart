import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/components.dart';
import '../data/contest_service.dart';
import 'contest_screen.dart';
import 'wallet_screen.dart';
import 'notifications_screen.dart';
import 'contest_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerCtrl, _bannerCtrl;
  late Animation<double> _headerSlide, _headerFade;
  late ScrollController _bannerScroll;
  Timer? _bannerTimer;
  int _bannerIndex = 0;
  final ContestService _contestService = ContestService();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  late Stream<DocumentSnapshot> _userStream;
  late Stream<List<ExtendedMatchData>> _contestsStream;

  final _games = const <Map<String, dynamic>>[
    {'name': 'Free Fire', 'asset': 'assets/logos/freefire.png', 'colors': [0xFFFF6B00, 0xFFFF8F00], 'code': 'FF'},
    {'name': 'BGMI', 'asset': 'assets/logos/bgmi.png', 'colors': [0xFF4CAF50, 0xFF00E676], 'code': 'BGMI'},
    {'name': 'EA FC', 'asset': 'assets/logos/eafc.png', 'colors': [0xFF2979FF, 0xFF448AFF], 'code': 'EAFC'},
    {'name': 'Cricket 26', 'asset': 'assets/logos/cricket26.png', 'colors': [0xFFFFAB00, 0xFFFFD740], 'code': 'RC26'},
    {'name': 'Clash Royale', 'asset': 'assets/logos/clash.png', 'colors': [0xFF7C4DFF, 0xFFB388FF], 'code': 'CR'},
    {'name': 'Valorant', 'asset': 'assets/logos/valorant.png', 'colors': [0xFFFF4081, 0xFFFF80AB], 'code': 'VAL'},
    {'name': 'Apex', 'asset': 'assets/logos/apex.png', 'colors': [0xFFFF3D00, 0xFFFF6E40], 'code': 'APX'},
  ];

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseFirestore.instance.collection('users').doc(_currentUid).snapshots();
    _contestsStream = _contestService.getContests();

    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _headerSlide = Tween<double>(begin: -30, end: 0).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeIn));
    _headerCtrl.forward();
    _bannerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _bannerScroll = ScrollController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!_bannerScroll.hasClients) return;
        final mxScroll = _bannerScroll.position.maxScrollExtent;
        _bannerIndex = (_bannerIndex + 1) % 3;
        final target = _bannerIndex * (MediaQuery.of(context).size.width - 32);
        _bannerScroll.animateTo(target > mxScroll ? 0 : target, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      });
    });
  }

  @override
  void dispose() { 
    _headerCtrl.dispose(); 
    _bannerCtrl.dispose(); 
    _bannerScroll.dispose(); 
    _bannerTimer?.cancel(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
      const ParticleBackground(count: 20, color: EsportsColors.neonPurple),
      
      StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: EsportsColors.cyan));
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('User Profile Not Found', style: TextStyle(color: Colors.white)));
          }
          
          final currentUser = UserProfile.fromFirestore(userSnapshot.data!.data() as Map<String, dynamic>, _currentUid);

          return StreamBuilder<List<ExtendedMatchData>>(
            stream: _contestsStream,
            builder: (context, matchSnapshot) {
              final allMatches = matchSnapshot.data ?? [];
              
              final upcoming = allMatches.where((m) => m.dynamicStatus == 'Upcoming').toList();
              final live = allMatches.where((m) => m.dynamicStatus == 'Live').toList();
              final completed = allMatches.where((m) => m.dynamicStatus == 'Completed').toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: SafeArea(child: _buildHeader(currentUser))),
                  SliverToBoxAdapter(child: _buildGameSelector()),
                  SliverToBoxAdapter(child: _buildFeaturedBanner()),
                  SliverToBoxAdapter(child: _sectionTitle('Upcoming Matches', Icons.schedule)),
                  SliverToBoxAdapter(child: _buildMatchCards(upcoming, 0, currentUser)),
                  SliverToBoxAdapter(child: _sectionTitle('Live Now', Icons.sensors, color: EsportsColors.live)),
                  SliverToBoxAdapter(child: _buildMatchCards(live, 1, currentUser)),
                  SliverToBoxAdapter(child: _sectionTitle('Recent Results', Icons.fact_check)),
                  SliverToBoxAdapter(child: _buildMatchCards(completed, 2, currentUser)),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          );
        },
      ),
    ]);
  }

  Widget _buildHeader(UserProfile user) {
    return AnimatedBuilder(animation: _headerFade, builder: (_, __) {
      return Transform.translate(
        offset: Offset(0, _headerSlide.value),
        child: Opacity(opacity: _headerFade.value, child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: EsportsColors.primaryGradient,
                boxShadow: [BoxShadow(color: EsportsColors.electricBlue.withOpacity(0.3), blurRadius: 12)],
              ),
              child: Center(child: Text(user.avatarLetter, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ])),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: glassDecoration(opacity: 0.1, borderRadius: 12),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.account_balance_wallet, size: 16, color: EsportsColors.gold),
                  const SizedBox(width: 6),
                  AnimatedCounter(value: user.balance, prefix: '₹ ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: EsportsColors.gold)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: glassDecoration(opacity: 0.1, borderRadius: 12),
                child: Stack(children: [
                  const Icon(Icons.notifications_none, size: 20, color: Colors.white),
                  Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: EsportsColors.live, shape: BoxShape.circle))),
                ]),
              ),
            ),
          ]),
        )),
      );
    });
  }

  Widget _buildGameSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _games.length,
        itemBuilder: (_, i) {
          final g = _games[i];
          final c1 = Color(g['colors'][0] as int);
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContestScreen(initialFilterGame: g['name'] as String))),
            child: Container(
              width: 72,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [c1.withOpacity(0.25), c1.withOpacity(0.05)]),
                    border: Border.all(color: c1.withOpacity(0.4)),
                    boxShadow: [BoxShadow(color: c1.withOpacity(0.15), blurRadius: 10)],
                  ),
                  child: Padding(padding: const EdgeInsets.all(10), child: Image.asset(g['asset'] as String, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.games))),
                ),
                const SizedBox(height: 6),
                Text(g['name'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: EsportsColors.textSecondary), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    final banners = [
      {'title': 'MEGA TOURNAMENT', 'sub': '₹ 50,000 Prize Pool', 'color': EsportsColors.electricBlue, 'icon': Icons.emoji_events},
      {'title': 'WEEKEND WARS', 'sub': 'Free Entry • Squad BR', 'color': EsportsColors.neonPurple, 'icon': Icons.local_fire_department},
      {'title': 'PRO LEAGUE S2', 'sub': 'Registration Open', 'color': EsportsColors.gold, 'icon': Icons.military_tech},
    ];
    return SizedBox(
      height: 150,
      child: ListView.builder(
        controller: _bannerScroll,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: banners.length,
        itemBuilder: (_, i) {
          final b = banners[i];
          final c = b['color'] as Color;
          return Container(
            width: MediaQuery.of(context).size.width - 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.withOpacity(0.3), c.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: c.withOpacity(0.15), blurRadius: 20)],
            ),
            child: Stack(children: [
              Positioned(right: -20, bottom: -20, child: Icon(b['icon'] as IconData, size: 120, color: c.withOpacity(0.1))),
              Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                TagBadge(text: 'FEATURED', color: c, fontSize: 8),
                const SizedBox(height: 8),
                Text(b['title'] as String, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(b['sub'] as String, style: TextStyle(fontSize: 13, color: c)),
              ])),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildMatchCards(List<ExtendedMatchData> matches, int tab, UserProfile currentUser) {
    if (matches.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No matches available', style: TextStyle(color: EsportsColors.textMuted))));
    return SizedBox(
      height: 175,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: matches.length,
        itemBuilder: (_, i) => _MiniMatchCard(match: matches[i], tabType: tab, currentUser: currentUser),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, {Color color = EsportsColors.cyan}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const Spacer(),
        Text('See All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

class SelfUpdatingCountdown extends StatefulWidget {
  final DateTime targetTime;
  final TextStyle style;

  const SelfUpdatingCountdown({super.key, required this.targetTime, required this.style});

  @override
  State<SelfUpdatingCountdown> createState() => _SelfUpdatingCountdownState();
}

class _SelfUpdatingCountdownState extends State<SelfUpdatingCountdown> {
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDiff(Duration diff) {
    if (diff.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(diff.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(diff.inSeconds.remainder(60));
    if (diff.inDays > 0) return "${diff.inDays}d ${twoDigits(diff.inHours.remainder(24))}h";
    return "${twoDigits(diff.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final diff = widget.targetTime.difference(DateTime.now());
    return Text(_formatDiff(diff), style: widget.style);
  }
}

class _MiniMatchCard extends StatefulWidget {
  final ExtendedMatchData match;
  final int tabType;
  final UserProfile currentUser;
  const _MiniMatchCard({required this.match, required this.tabType, required this.currentUser});
  @override
  State<_MiniMatchCard> createState() => _MiniMatchCardState();
}

class _MiniMatchCardState extends State<_MiniMatchCard> with SingleTickerProviderStateMixin {
  late AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() { _glow.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final c = Color(m.gradientColors[0]);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContestDetailsScreen(match: m, currentUser: widget.currentUser))),
      child: AnimatedBuilder(animation: _glow, builder: (_, __) {
        return Container(
          width: 220,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(begin: Alignment(-1 + _glow.value * 2, -1), end: Alignment(1 - _glow.value * 2, 1), colors: [c.withOpacity(0.18), EsportsColors.card, c.withOpacity(0.1)]),
            border: Border.all(color: c.withOpacity(0.25)),
            boxShadow: [BoxShadow(color: c.withOpacity(0.08), blurRadius: 16)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(IconData(m.gameIconCode, fontFamily: 'MaterialIcons'), color: c, size: 20),
              const SizedBox(width: 6),
              Expanded(child: Text(m.gameName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis)),
              TagBadge(text: m.matchTag, color: c),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.monetization_on, size: 14, color: EsportsColors.gold),
              const SizedBox(width: 4),
              Text('₹ ${m.prizePool}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: EsportsColors.gold)),
            ]),
            const SizedBox(height: 4),
            Text('Entry: ${m.isFree ? "FREE" : "₹ ${m.entryFee}"} • ${m.matchType}', style: const TextStyle(fontSize: 10, color: EsportsColors.textMuted)),
            const Spacer(),
            Row(children: [
              Expanded(child: NeonProgressBar(value: m.fillRate, color: m.fillRate > 0.8 ? EsportsColors.live : c)),
              const SizedBox(width: 8),
              Text('${m.slotsLeft} left', style: TextStyle(fontSize: 10, color: m.slotsLeft <= 10 ? EsportsColors.live : EsportsColors.textMuted)),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: widget.tabType == 1 ? EsportsColors.live.withOpacity(0.15) : EsportsColors.cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: widget.tabType == 2 
                  ? const Text('ENDED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: EsportsColors.cyan))
                  : widget.tabType == 1 
                      ? const Text('• LIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: EsportsColors.live))
                      : SelfUpdatingCountdown(
                          targetTime: m.matchTime, 
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: EsportsColors.cyan)
                        ),
            ),
          ]),
        );
      }),
    );
  }
}