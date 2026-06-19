import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../core/theme.dart';
import '../data/contest_service.dart';
import '../models/models.dart';
import '../widgets/components.dart';

Widget buildGameLogo(String gameName, Color c, double size) {
  final normalizedName = gameName.trim();
  final assetPath = kGameLogoAsset[normalizedName] ?? 'assets/logos/${normalizedName.replaceAll(' ', '').toLowerCase()}.png';
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: c.withOpacity(0.15),
          border: Border.all(color: c.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.sports_esports, color: c, size: size * 0.6),
      ),
    ),
  );
}

class ContestScreen extends StatefulWidget {
  final String initialFilterGame;
  final bool firebaseAvailable;
  const ContestScreen({super.key, this.initialFilterGame = 'Default', this.firebaseAvailable = true});
  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> with TickerProviderStateMixin {
  late AnimationController _titleCtrl;
  late Animation<double> _titleGlow;
  int _tab = 0;
  String _searchQuery = '';
  Timer? _tickTimer;

  Map<String, String> _filters = {
    'Game': 'Default', 'Status': 'Default', 'Prize': 'Default', 'Entry': 'Default',
    'Mode': 'Default', 'SubMode': 'Default', 'Map': 'Default', 'PlayerSize': 'Default',
    'Stadium': 'Default', 'Arena': 'Default', 'Perspective': 'Default',
  };

  late final ContestService _contestService;

  @override
  void initState() {
    _contestService = ContestService();
    super.initState();
    _titleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _titleGlow = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeInOut));
    
    if (widget.initialFilterGame != 'All' && widget.initialFilterGame != 'Default') {
      _filters['Game'] = widget.initialFilterGame;
    }

    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { _titleCtrl.dispose(); _tickTimer?.cancel(); super.dispose(); }

  void _syncTabWithStatus() {
    if (_filters['Status'] == 'Upcoming') _tab = 0;
    else if (_filters['Status'] == 'Live') _tab = 1;
    else if (_filters['Status'] == 'Completed') _tab = 2;
  }

  void _syncStatusWithTab(int tabIndex) {
    _tab = tabIndex;
    if (_tab == 0) _filters['Status'] = 'Upcoming';
    else if (_tab == 1) _filters['Status'] = 'Live';
    else if (_tab == 2) _filters['Status'] = 'Completed';
  }

  int get _activeFilterCount => _filters.values.where((v) => v != 'Default').length;

  List<MatchData> _filteredMatches(List<MatchData> allMatches) {
    final now = DateTime.now();
    var list = allMatches.where((m) => _matchesTab(m, now)).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((m) => m.gameName.toLowerCase().contains(query)).toList();
    }

    if (_filters['Game'] != 'Default') list = list.where((m) => m.gameName == _filters['Game']).toList();
    if (_filters['Status'] != 'Default') list = list.where((m) => _matchesStatusFilter(m, _filters['Status']!)).toList();

    if (_filters['Prize'] != 'Default') {
      list = list.where((m) {
        if (_filters['Prize'] == 'Under ₹500') return m.prizePool < 500;
        if (_filters['Prize'] == '₹500–₹5000') return m.prizePool >= 500 && m.prizePool <= 5000;
        if (_filters['Prize'] == '₹5000+') return m.prizePool > 5000;
        return true;
      }).toList();
    }

    if (_filters['Entry'] != 'Default') {
      list = list.where((m) {
        if (_filters['Entry'] == 'Free') return m.entryFee == 0;
        if (_filters['Entry'] == '₹10–50') return m.entryFee >= 10 && m.entryFee <= 50;
        if (_filters['Entry'] == '₹50–100') return m.entryFee > 50 && m.entryFee <= 100;
        if (_filters['Entry'] == '₹100+') return m.entryFee > 100;
        return true;
      }).toList();
    }

    if (_filters['Map'] != 'Default') list = list.where((m) => m.mapName.contains(_filters['Map']!)).toList();
    if (_filters['Arena'] != 'Default') list = list.where((m) => m.mapName.contains(_filters['Arena']!)).toList();
    if (_filters['Stadium'] != 'Default') list = list.where((m) => m.mapName.contains(_filters['Stadium']!)).toList();
    if (_filters['Mode'] != 'Default') list = list.where((m) => m.matchType.contains(_filters['Mode']!) || m.matchTag.contains(_filters['Mode']!)).toList();
    if (_filters['SubMode'] != 'Default') list = list.where((m) => m.matchType.contains(_filters['SubMode']!) || m.matchTag.contains(_filters['SubMode']!)).toList();

    return list;
  }

  bool _matchesTab(MatchData m, DateTime now) {
    final status = m.status.toLowerCase();
    if (_tab == 0) return status == 'upcoming' || (m.matchTime.isAfter(now) && status != 'completed');
    if (_tab == 1) return status == 'live' || status == 'ongoing';
    return status == 'completed';
  }

  bool _matchesStatusFilter(MatchData m, String statusFilter) {
    final filter = statusFilter.toLowerCase();
    final status = m.status.toLowerCase();
    if (filter == 'upcoming') return status == 'upcoming' || m.matchTime.isAfter(DateTime.now());
    if (filter == 'live') return status == 'live' || status == 'ongoing';
    if (filter == 'completed') return status == 'completed';
    return true;
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        initialFilters: Map.from(_filters),
        onApply: (newFilters) {
          setState(() {
            _filters = newFilters;
            if (_filters['Status'] != 'Default') _syncTabWithStatus();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
        const ParticleBackground(count: 15, color: EsportsColors.electricBlue),
        SafeArea(child: Column(children: [
          _buildTopBar(),
          _buildTitle(),
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(child: _buildMatchList()),
        ])),
      ]),
    );
  }

  Widget _buildTopBar() {
    final canGoBack = Navigator.of(context).canPop();
    if (!canGoBack) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: EsportsColors.card.withOpacity(0.75), borderRadius: BorderRadius.circular(14), border: Border.all(color: EsportsColors.border)),
            child: const Icon(Icons.arrow_back_ios_new, color: EsportsColors.cyan, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        const Text('Home • Contest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ]),
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(animation: _titleGlow, builder: (_, __) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [EsportsColors.electricBlue, Color.lerp(EsportsColors.cyan, EsportsColors.neonPurple, _titleGlow.value)!, EsportsColors.electricBlue],
            stops: [0, _titleGlow.value, 1],
          ).createShader(b),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1), duration: const Duration(seconds: 1), curve: Curves.elasticOut,
              builder: (_, v, c) => Transform.scale(scale: 0.8 + 0.2 * v, child: c),
              child: const Icon(Icons.bolt, color: Colors.white, size: 26)),
            const SizedBox(width: 6),
            const Text('UA ESPORTS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.white)),
            const SizedBox(width: 6),
            TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1), duration: const Duration(seconds: 1), curve: Curves.elasticOut,
              builder: (_, v, c) => Transform.scale(scale: 0.8 + 0.2 * v, child: c),
              child: const Icon(Icons.bolt, color: Colors.white, size: 26)),
          ]),
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: glassDecoration(opacity: 0.08, borderRadius: 14),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search matches, games...',
                  hintStyle: TextStyle(color: EsportsColors.textMuted, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: EsportsColors.textMuted, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _openFilterSheet,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _activeFilterCount > 0 ? EsportsColors.cyan.withOpacity(0.2) : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _activeFilterCount > 0 ? EsportsColors.cyan : EsportsColors.border),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.tune, color: _activeFilterCount > 0 ? EsportsColors.cyan : Colors.white70, size: 20),
                  if (_activeFilterCount > 0)
                    Positioned(
                      top: -6, right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: EsportsColors.live, shape: BoxShape.circle),
                        child: Text('$_activeFilterCount', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = ['Upcoming', 'Ongoing', 'Completed'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: glassDecoration(opacity: 0.06, borderRadius: 14),
      child: Row(children: List.generate(3, (i) {
        final sel = _tab == i;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _syncStatusWithTab(i)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: sel ? EsportsColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(11),
              boxShadow: sel ? [BoxShadow(color: EsportsColors.electricBlue.withOpacity(0.3), blurRadius: 10)] : [],
            ),
            child: Center(child: Text(tabs[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: sel ? Colors.white : EsportsColors.textMuted))),
          ),
        ));
      })),
    );
  }

  Widget _buildMatchList() {
    return StreamBuilder<List<MatchData>>(
      stream: _contestService.getContests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
        if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.error_outline, size: 48, color: EsportsColors.live), const SizedBox(height: 8), const Text('Unable to load contests', style: TextStyle(color: EsportsColors.textMuted))]));
        
        final matches = _filteredMatches(snapshot.data ?? []);
        if (matches.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.inbox_outlined, size: 48, color: EsportsColors.textDim), const SizedBox(height: 8), const Text('No matches found', style: TextStyle(color: EsportsColors.textMuted))]));

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          itemCount: matches.length,
          itemBuilder: (_, i) => _ContestMatchCard(
            match: matches[i],
            tabType: _tab,
            onTap: () => _openMatch(matches[i]),
          ),
        );
      },
    );
  }

  void _openMatch(MatchData m) {
    Widget screen;
    if (_tab == 0) screen = UpcomingMatchDetail(match: m);
    else if (_tab == 1) screen = OngoingMatchDetail(match: m);
    else screen = CompletedMatchDetail(match: m);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _FilterSheet extends StatefulWidget {
  final Map<String, String> initialFilters;
  final Function(Map<String, String>) onApply;
  const _FilterSheet({required this.initialFilters, required this.onApply});
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Map<String, String> f;
  @override
  void initState() { super.initState(); f = Map.from(widget.initialFilters); }
  void _reset() { setState(() { f.updateAll((key, value) => 'Default'); }); }
  void _set(String key, String val) {
    setState(() {
      f[key] = (f[key] == val) ? 'Default' : val;
      if (key == 'Game') {
        f['Mode'] = 'Default'; f['SubMode'] = 'Default'; f['Map'] = 'Default';
        f['PlayerSize'] = 'Default'; f['Stadium'] = 'Default'; f['Arena'] = 'Default'; f['Perspective'] = 'Default';
      }
      if (key == 'Mode') { f['SubMode'] = 'Default'; f['Map'] = 'Default'; f['PlayerSize'] = 'Default'; }
    });
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap, {bool isAccent = false}) {
    Color baseCol = isAccent ? EsportsColors.gold : EsportsColors.cyan;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? baseCol.withOpacity(0.2) : Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? baseCol : EsportsColors.border)),
        child: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? baseCol : EsportsColors.textMuted, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500)),
      ),
    );
  }

  Widget _buildSection(String title, String key, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 10, children: options.map((opt) => _chip(opt, f[key] == opt, () => _set(key, opt))).toList()),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildExpandableMode(String mainMode, List<String> subModes) {
    bool isExpanded = f['Mode'] == mainMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chip(mainMode, isExpanded, () => _set('Mode', mainMode), isAccent: true),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: isExpanded && subModes.isNotEmpty ? Padding(
            padding: const EdgeInsets.only(top: 10, left: 12),
            child: Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(border: Border(left: BorderSide(color: EsportsColors.border, width: 2))),
              child: Wrap(spacing: 8, runSpacing: 10, children: subModes.map((sm) => _chip(sm, f['SubMode'] == sm, () => _set('SubMode', sm))).toList()),
            ),
          ) : const SizedBox.shrink(),
        )
      ],
    );
  }

  Widget _buildGameSpecificFilters() {
    switch (f['Game']) {
      case 'Free Fire':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MODE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(height: 10),
          _chip('Default', f['Mode'] == 'Default', () => _set('Mode', 'Default')), const SizedBox(height: 10),
          Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.start, children: [_buildExpandableMode('BR', ['Solo', 'Duo', 'Squad']), _buildExpandableMode('Clash Squad', ['1v1', '2v2', '3v3', '4v4', '5v5', '6v6']), _buildExpandableMode('Lone Wolf', ['1v1', '2v2'])]),
          const SizedBox(height: 24), _buildSection('MAP', 'Map', ['Default', 'Bermuda', 'Kalahari', 'Purgatory', 'Alpine', 'Solara', 'Nexterra']),
        ]);
      case 'BGMI':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MODE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(height: 10),
          _chip('Default', f['Mode'] == 'Default', () => _set('Mode', 'Default')), const SizedBox(height: 10),
          Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.start, children: [_buildExpandableMode('Battle Royale', ['Default', 'Solo', 'Duo', 'Squad']), _buildExpandableMode('Team Deathmatch', ['Default', 'TDM', 'Domination', 'Gun Game', 'Assault'])]),
          const SizedBox(height: 24),
          if (f['Mode'] == 'Battle Royale') _buildSection('MAP (BATTLE ROYALE)', 'Map', ['Default', 'Erangel', 'Miramar', 'Livik', 'Sanhok', 'Vikendi', 'Nusa'])
          else if (f['Mode'] == 'Team Deathmatch') _buildSection('MAP (TDM)', 'Map', ['Default', 'Warehouse', 'Ruins', 'Town'])
          else _buildSection('MAP', 'Map', ['Default', 'Erangel', 'Miramar', 'Livik', 'Sanhok', 'Warehouse', 'Ruins']),
        ]);
      case 'Valorant':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSection('MODE', 'Mode', ['Default', 'Competitive', 'Team Deathmatch', 'Deathmatch', 'Custom']),
          if (f['Mode'] == 'Competitive' || f['Mode'] == 'Team Deathmatch') _buildSection('PLAYER SIZE', 'PlayerSize', ['Default', '5v5']),
          if (f['Mode'] == 'Deathmatch') _buildSection('PLAYER SIZE', 'PlayerSize', ['Default', 'FFA']),
          if (f['Mode'] == 'Custom') _buildSection('PLAYER SIZE', 'PlayerSize', ['Default', '1v1', '2v2', '3v3', '5v5']),
          _buildSection('MAP', 'Map', ['Default', 'Ascent', 'Bind', 'Haven', 'Split', 'Icebox', 'Breeze', 'Sunset', 'Lotus', 'Pearl', 'Fracture', 'Abyss', 'District', 'Kasbah', 'Piazza', 'Drift']),
        ]);
      case 'EA FC':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSection('MODE', 'Mode', ['Default', 'Kick Off', 'Online Friendly', 'Online Seasons', 'Co-op Seasons', 'Ultimate Team Friendly', 'Clubs', 'Rush', 'Custom']),
          _buildSection('PLAYER SIZE', 'PlayerSize', ['Default', '1v1', '2v2', '3v3', '4v4', '5v5']),
          _buildSection('STADIUM', 'Stadium', ['Default', 'Santiago Bernabéu', 'Old Trafford', 'Anfield', 'Etihad Stadium', 'Parc des Princes', 'Allianz Arena', 'VOLTA Arena', 'Rush Arena']),
        ]);
      case 'Real Cricket 26':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSection('MODE', 'Mode', ['Default', 'T20', 'ODI', 'Test', 'Super Over', 'Custom']),
          _buildSection('PLAYER SIZE', 'PlayerSize', ['Default', '1v1']),
          _buildSection('STADIUM', 'Stadium', ['Default', 'Wankhede Stadium', 'Eden Gardens', 'Narendra Modi Stadium', 'M. A. Chidambaram Stadium', 'Melbourne Cricket Ground', "Lord's Cricket Ground", 'The Oval']),
        ]);
      case 'Apex Legends':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSection('MODE', 'Mode', ['Default', 'Battle Royale', 'Ranked Battle Royale', 'Team Deathmatch', 'Control', 'Gun Run', 'Mixtape', 'Custom']),
          _buildSection('PLAYER SIZE', 'PlayerSize', ['Default', 'Solo', 'Duo', 'Trio', '4 Squads', '6v6', '9v9']),
          _buildSection('PERSPECTIVE', 'Perspective', ['Default', 'FPP']),
          _buildSection('MAP', 'Map', ['Default', 'Kings Canyon', "World's Edge", 'Olympus', 'Storm Point', 'Broken Moon', 'E-District', 'Party Crasher', 'Habitat 4', 'Overflow', 'Skull Town', 'Lava Siphon', 'Barometer', 'Production Yard', 'Fragment', 'Estates']),
        ]);
      case 'Clash Royale':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSection('MODE', 'Mode', ['Default', '1v1', 'Ranked', 'Path of Legends', '2v2', 'Friendly Battle', 'Custom']),
          _buildSection('PLAYER SIZE', 'PlayerSize', ['Default', 'Solo', 'Duo']),
          _buildSection('ARENA', 'Arena', ['Default', 'Goblin Stadium', 'Bone Pit', 'Barbarian Bowl', 'P.E.K.K.A’s Playhouse', 'Spell Valley', 'Builder’s Workshop', 'Royal Arena', 'Legendary Arena']),
        ]);
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(color: EsportsColors.bg2, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: EsportsColors.cyan.withOpacity(0.3)))),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: EsportsColors.border))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Row(children: [Icon(Icons.tune, color: EsportsColors.cyan, size: 20), SizedBox(width: 8), Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white))]),
            TextButton(onPressed: _reset, child: const Text('Clear All', style: TextStyle(color: EsportsColors.textMuted, fontWeight: FontWeight.w600)))
          ]),
        ),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              _buildSection('GAME', 'Game', ['Default', 'Free Fire', 'BGMI', 'Valorant', 'EA FC', 'Real Cricket 26', 'Apex Legends', 'Clash Royale']),
              _buildSection('STATUS', 'Status', ['Default', 'Upcoming', 'Live', 'Completed']),
              _buildSection('ENTRY FEE', 'Entry', ['Default', 'Free', '₹10–50', '₹50–100', '₹100+']),
              _buildSection('PRIZE POOL', 'Prize', ['Default', 'Under ₹500', '₹500–₹5000', '₹5000+']),
              AnimatedSize(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutBack, child: Container(key: ValueKey(f['Game']), child: _buildGameSpecificFilters())),
              const SizedBox(height: 40),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: EsportsColors.bg1, border: Border(top: BorderSide(color: EsportsColors.border))),
            child: SizedBox(
              width: double.infinity,
              child: NeonButton(label: 'APPLY FILTERS', icon: Icons.check_circle, color: EsportsColors.cyan, onPressed: () { widget.onApply(f); Navigator.pop(context); }),
            ),
          ),
        )
      ]),
    );
  }
}

class _ContestMatchCard extends StatefulWidget {
  final MatchData match;
  final int tabType;
  final VoidCallback onTap;
  const _ContestMatchCard({required this.match, required this.tabType, required this.onTap});
  @override
  State<_ContestMatchCard> createState() => _ContestMatchCardState();
}

class _ContestMatchCardState extends State<_ContestMatchCard> with SingleTickerProviderStateMixin {
  static const double _cardHeight = 175;
  late AnimationController _bg;
  late Animation<double> _bgA, _scaleA;

  @override
  void initState() {
    super.initState();
    _bg = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _bgA = Tween<double>(begin: -0.5, end: 1.5).animate(CurvedAnimation(parent: _bg, curve: Curves.easeInOut));
    _scaleA = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _bg, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _bg.dispose(); super.dispose(); }

  Widget _statCol(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildCardContent(MatchData m, Color c, Duration rem) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildGameLogo(m.gameName, c, 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(m.gameName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 6),
                        TagBadge(text: m.matchTag, color: c),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${m.matchType} • ${m.mapName}', style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: widget.tabType == 2 ? Colors.black45 : (rem.isNegative ? EsportsColors.live.withOpacity(0.8) : c.withOpacity(0.8)), borderRadius: BorderRadius.circular(8)),
                child: Text(widget.tabType == 2 ? 'Ended' : fmtCountdown(rem), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: Colors.white)),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${m.filledSlots}/${m.totalSlots} slots', style: const TextStyle(fontSize: 10, color: Colors.white70)),
              Text('(${m.slotsLeft} left)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: m.slotsLeft <= 10 ? EsportsColors.live : EsportsColors.success)),
            ],
          ),
          const SizedBox(height: 4),
          NeonProgressBar(value: m.fillRate, color: m.fillRate > 0.8 ? EsportsColors.live : c),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statCol('PRIZE', '₹${m.prizePool}', EsportsColors.gold),
              const SizedBox(width: 16),
              _statCol('ENTRY', m.isFree ? 'FREE' : '₹${m.entryFee}', EsportsColors.success),
              const SizedBox(width: 16),
              _statCol('MODE', m.matchType, EsportsColors.cyan),
              const Spacer(),
              NeonButton(label: widget.tabType == 0 ? 'JOIN' : widget.tabType == 1 ? 'WATCH' : 'VIEW', color: widget.tabType == 2 ? EsportsColors.textDim : c, height: 38, onPressed: widget.onTap),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final c = Color(m.gradientColors[0]);
    final rem = m.matchTime.difference(DateTime.now());

    if (m.gameName == 'Free Fire') return _buildFreeFireCard(m, c, rem);
    return _buildStandardCard(m, c, rem);
  }

  Widget _buildFreeFireCard(MatchData m, Color c, Duration rem) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bg,
        builder: (_, __) {
          return SizedBox(
            height: _cardHeight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.5), width: 1.5), boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Positioned.fill(child: Transform.scale(scale: _scaleA.value, child: Image.asset('assets/image/play2.png', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: EsportsColors.card)))),
                    Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.85)])))),
                    _buildCardContent(m, c, rem),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStandardCard(MatchData m, Color c, Duration rem) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bgA,
        builder: (_, __) {
          return SizedBox(
            height: _cardHeight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(begin: Alignment(_bgA.value, -1), end: Alignment(-_bgA.value, 1), colors: [c.withOpacity(0.25), EsportsColors.card, c.withOpacity(0.15)]),
                border: Border.all(color: c.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: c.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Stack(
                children: [
                  Positioned(right: -20, top: -10, child: Opacity(opacity: 0.05, child: buildGameLogo(m.gameName, c, 120))),
                  Positioned.fill(child: Container(color: Colors.black.withOpacity(0.4))),
                  _buildCardContent(m, c, rem),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class UpcomingMatchDetail extends StatefulWidget {
  final MatchData match;
  const UpcomingMatchDetail({super.key, required this.match});
  @override
  State<UpcomingMatchDetail> createState() => _UpcomingMatchDetailState();
}

class _UpcomingMatchDetailState extends State<UpcomingMatchDetail> {
  final PageController _pageCtrl = PageController();
  int _col = 0;
  late final List<Map<String, String>> _players;

  @override
  void initState() {
    super.initState();
    _players = List.generate(widget.match.filledSlots, (i) => {'name': randomName(i), 'uid': randomUid(i)});
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final c = Color(m.gradientColors[0]);
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
        SafeArea(child: Column(children: [
          _header(m, c),
          _tabSelector(c),
          Expanded(child: PageView(controller: _pageCtrl, onPageChanged: (i) => setState(() => _col = i), children: [_playersPage(), _prizePage(m)])),
          _joinButton(m, c),
        ])),
      ]),
    );
  }

  Widget _header(MatchData m, Color c) {
    final rem = m.matchTime.difference(DateTime.now());
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        opacity: 0.08,
        child: Column(children: [
          Row(children: [
            appBackButton(context),
            const SizedBox(width: 12),
            buildGameLogo(m.gameName, c, 44),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(m.gameName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(width: 6), TagBadge(text: m.matchTag, color: c)]),
              Text('${m.matchType} • ${m.mapName}', style: const TextStyle(fontSize: 12, color: EsportsColors.textMuted)),
            ])),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            StatBox(label: 'Prize Pool', value: '₹${m.prizePool}', color: EsportsColors.gold),
            StatBox(label: 'Entry', value: m.isFree ? 'FREE' : '₹${m.entryFee}', color: EsportsColors.success),
            StatBox(label: 'Slots Left', value: '${m.slotsLeft}', color: m.slotsLeft <= 10 ? EsportsColors.live : EsportsColors.cyan),
            StatBox(label: 'Starts In', value: fmtCountdown(rem), color: EsportsColors.cyan),
          ]),
        ]),
      ),
    );
  }

  Widget _tabSelector(Color c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(3),
      decoration: glassDecoration(opacity: 0.06, borderRadius: 12),
      child: Row(children: [_colTab('Participants', 0, c), _colTab('Prize Distribution', 1, c)]),
    );
  }

  Widget _colTab(String lbl, int idx, Color c) {
    final sel = _col == idx;
    return Expanded(child: GestureDetector(
      onTap: () { setState(() => _col = idx); _pageCtrl.animateToPage(idx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(gradient: sel ? EsportsColors.primaryGradient : null, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(lbl, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? Colors.white : EsportsColors.textMuted))),
      ),
    ));
  }

  Widget _playersPage() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _players.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
          const Icon(Icons.people, color: EsportsColors.cyan, size: 18), const SizedBox(width: 8),
          Text('${_players.length} Registered', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ]));
        final p = _players[i - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: glassDecoration(opacity: 0.06, borderRadius: 12),
          child: Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: EsportsColors.electricBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('$i', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EsportsColors.electricBlue)))),
            const SizedBox(width: 10),
            CircleAvatar(radius: 16, backgroundColor: Colors.primaries[(i - 1) % Colors.primaries.length].withOpacity(0.2),
              child: Text(p['name']![0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
            const SizedBox(width: 10),
            Expanded(child: Text(p['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
            Text('${p['uid']!.substring(0, 4)}****', style: const TextStyle(fontSize: 10, color: EsportsColors.textDim, fontFamily: 'monospace')),
          ]),
        );
      },
    );
  }

  Widget _prizePage(MatchData m) {
    final pool = m.prizePool;
    final dist = [
      {'rank': '🥇 1st', 'pct': 0.40, 'color': EsportsColors.gold},
      {'rank': '🥈 2nd', 'pct': 0.25, 'color': const Color(0xFFBDBDBD)},
      {'rank': '🥉 3rd', 'pct': 0.15, 'color': const Color(0xFFFF8A65)},
      {'rank': '4th - 5th', 'pct': 0.075, 'color': EsportsColors.cyan},
      {'rank': '6th - 10th', 'pct': 0.01, 'color': EsportsColors.textMuted},
    ];
    return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 16), children: [
      GlassCard(opacity: 0.06, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.emoji_events, color: EsportsColors.gold, size: 20), const SizedBox(width: 8), const Text('Prize Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)), const Spacer(), Text('₹$pool', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: EsportsColors.gold))]),
        const SizedBox(height: 14),
        ...dist.map((d) {
          final amt = (pool * (d['pct'] as double)).round();
          final clr = d['color'] as Color;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: clr.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: clr.withOpacity(0.2))),
            child: Row(children: [Text(d['rank'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: clr)), const Spacer(), Text('₹$amt', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))]),
          );
        }),
      ])),
    ]);
  }

  Widget _joinButton(MatchData m, Color c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: NeonButton(
        label: 'JOIN MATCH',
        icon: Icons.gamepad,
        color: c,
        breathing: true,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JoinFlowScreen(match: m))),
      ),
    );
  }
}

class JoinFlowScreen extends StatefulWidget {
  final MatchData match;
  const JoinFlowScreen({super.key, required this.match});
  @override
  State<JoinFlowScreen> createState() => _JoinFlowScreenState();
}

class _JoinFlowScreenState extends State<JoinFlowScreen> {
  final _uidCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  void _proceed() {
    if (_uidCtrl.text.length < 6) { _showError('Enter a valid Game UID (min 6 chars)'); return; }
    if (_nameCtrl.text.length < 3) { _showError('Enter your in-game name (min 3 chars)'); return; }
    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentRulesScreen(match: widget.match, uid: _uidCtrl.text, name: _nameCtrl.text)));
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: EsportsColors.live, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  void dispose() { _uidCtrl.dispose(); _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final c = Color(m.gradientColors[0]);
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
        SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [appBackButton(context), const SizedBox(width: 12), const Text('Join Match', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))]),
          const SizedBox(height: 20),
          GlassCard(opacity: 0.06, child: Row(children: [
            buildGameLogo(m.gameName, c, 38),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.gameName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('${m.matchType} • ${m.mapName} • ${m.matchTag}', style: const TextStyle(fontSize: 11, color: EsportsColors.textMuted)),
            ])),
            Column(children: [
              Text(m.isFree ? 'FREE' : '₹${m.entryFee}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: m.isFree ? EsportsColors.success : EsportsColors.gold)),
              const Text('Entry', style: TextStyle(fontSize: 10, color: EsportsColors.textMuted)),
            ]),
          ])),
          const SizedBox(height: 24),
          const Text('Game UID *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: EsportsColors.textSecondary)),
          const SizedBox(height: 8),
          _field(_uidCtrl, 'Enter your game UID', Icons.badge, c),
          const SizedBox(height: 16),
          const Text('In-Game Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: EsportsColors.textSecondary)),
          const SizedBox(height: 8),
          _field(_nameCtrl, 'Enter your in-game name', Icons.person, c, isNumber: false),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, child: NeonButton(
            label: m.isFree ? 'JOIN FREE' : 'PAY ₹${m.entryFee}',
            icon: m.isFree ? Icons.check_circle : Icons.payment,
            color: m.isFree ? EsportsColors.success : c,
            breathing: true,
            onPressed: _proceed,
          )),
        ]))),
      ]),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon, Color c, {bool isNumber = true}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 0.5),
      keyboardType: isNumber ? TextInputType.text : TextInputType.name,
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: EsportsColors.textDim),
        prefixIcon: Icon(icon, color: c),
        filled: true, fillColor: EsportsColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: EsportsColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: EsportsColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: 2)),
      ),
    );
  }
}

class PaymentRulesScreen extends StatefulWidget {
  final MatchData match;
  final String uid, name;
  const PaymentRulesScreen({super.key, required this.match, required this.uid, required this.name});
  @override
  State<PaymentRulesScreen> createState() => _PaymentRulesScreenState();
}

class _PaymentRulesScreenState extends State<PaymentRulesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _successCtrl;
  bool _confirmed = false;

  final _rules = [
    'Join match room 10 mins before start time.',
    'Hacks, emulators, or third-party tools are strictly banned.',
    'Submit correct in-game UID during registration.',
    'Entry fee is non-refundable after confirmation.',
    'Results based on screenshots + admin verification.',
    'Teaming with opponents = instant disqualification.',
    'Prizes distributed within 24h of completion.',
    'Admin decision is final for all disputes.',
  ];

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() { _successCtrl.dispose(); super.dispose(); }

  void _confirm() {
    setState(() => _confirmed = true);
    _successCtrl.forward();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.match.isFree ? 'Registration successful!' : 'Payment confirmed!'), backgroundColor: EsportsColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LegacyWaitingRoomScreen(match: widget.match, name: widget.name)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final c = Color(m.gradientColors[0]);
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
        SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [appBackButton(context), const SizedBox(width: 12), const Text('Confirm & Pay', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))]),
          const SizedBox(height: 20),
          GlassCard(opacity: 0.06, child: Column(children: [
            _row('Player', widget.name), _row('UID', widget.uid), _row('Game', m.gameName), _row('Mode', '${m.matchType} (${m.matchTag})'), _row('Map', m.mapName), _row('Entry', m.isFree ? 'FREE' : '₹${m.entryFee}'),
          ])),
          const SizedBox(height: 16),
          GlassCard(opacity: 0.06, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.rule, color: Color(0xFFFF8A65), size: 20), SizedBox(width: 8), Text('Match Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))]),
            const SizedBox(height: 12),
            ...List.generate(_rules.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 22, height: 22, decoration: BoxDecoration(color: EsportsColors.electricBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: EsportsColors.electricBlue)))),
              const SizedBox(width: 10),
              Expanded(child: Text(_rules[i], style: const TextStyle(fontSize: 13, color: EsportsColors.textSecondary, height: 1.4))),
            ]))),
          ])),
          const SizedBox(height: 16),
          if (!m.isFree) GlassCard(opacity: 0.06, child: Column(children: [
            const Row(children: [Icon(Icons.payment, color: EsportsColors.cyan, size: 20), SizedBox(width: 8), Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))]),
            const SizedBox(height: 16),
            Container(width: 160, height: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.qr_code_2, size: 100, color: Colors.black87), const SizedBox(height: 4), Text('₹${m.entryFee}', style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w700))])),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF5F259F).withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF5F259F).withOpacity(0.25))),
              child: const Row(children: [Icon(Icons.phone_android, color: Color(0xFF5F259F), size: 20), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PhonePe / UPI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)), Text('uaesports@ybl', style: TextStyle(fontSize: 12, color: EsportsColors.textMuted, fontFamily: 'monospace'))])), Icon(Icons.copy, color: EsportsColors.textDim, size: 18)]),
            ),
          ])),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _confirmed ? Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut)) : const AlwaysStoppedAnimation(1.0),
            child: SizedBox(width: double.infinity, child: NeonButton(
              label: _confirmed ? 'CONFIRMED ✓' : (m.isFree ? 'CONFIRM (FREE)' : 'CONFIRM ₹${m.entryFee}'),
              color: _confirmed ? EsportsColors.textDim : (m.isFree ? EsportsColors.success : c),
              breathing: !_confirmed,
              onPressed: _confirmed ? null : _confirm,
            )),
          ),
          const SizedBox(height: 16),
        ]))),
      ]),
    );
  }

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: const TextStyle(fontSize: 13, color: EsportsColors.textMuted)),
        Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    ),
  );
}

class LegacyWaitingRoomScreen extends StatefulWidget {
  final MatchData match;
  final String name;
  const LegacyWaitingRoomScreen({super.key, required this.match, required this.name});
  @override
  State<LegacyWaitingRoomScreen> createState() => _LegacyWaitingRoomScreenState();
}

class _LegacyWaitingRoomScreenState extends State<LegacyWaitingRoomScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { _pulseCtrl.dispose(); _tick?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final c = Color(m.gradientColors[0]);
    final rem = m.matchTime.difference(DateTime.now());

    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
        const ParticleBackground(count: 25, color: EsportsColors.neonPurple),
        SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [appBackButton(context), const SizedBox(width: 12), const Text('Waiting Room', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))])),
          const Spacer(),
          AnimatedBuilder(animation: _pulseCtrl, builder: (_, __) {
            final scale = 0.95 + 0.05 * _pulseCtrl.value;
            return Transform.scale(scale: scale, child: Column(children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [c.withOpacity(0.3), c.withOpacity(0.1)]),
                  boxShadow: [BoxShadow(color: c.withOpacity(0.2 + 0.1 * _pulseCtrl.value), blurRadius: 30)]),
                child: Center(child: buildGameLogo(m.gameName, c, 70)),
              ),
              const SizedBox(height: 20),
              Text(m.gameName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Match starts in', style: TextStyle(fontSize: 14, color: EsportsColors.textMuted)),
              const SizedBox(height: 8),
              Text(fmtCountdown(rem), style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: c, shadows: [Shadow(color: c.withOpacity(0.5), blurRadius: 20)])),
            ]));
          }),
          const SizedBox(height: 30),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: GlassCard(opacity: 0.06, child: Column(children: [
            _row('Your Entry', widget.name),
            _row('Mode', '${m.matchType} (${m.matchTag})'),
            _row('Map', m.mapName),
            _row('Participants', '${m.filledSlots + 1}/${m.totalSlots}'),
            _row('Prize Pool', '₹${m.prizePool}'),
          ]))),
          const Spacer(),
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            Expanded(child: NeonButton(label: 'INVITE FRIENDS', icon: Icons.share, color: EsportsColors.neonPurple, onPressed: () {})),
            const SizedBox(width: 12),
            Expanded(child: NeonButton(label: 'SET REMINDER', icon: Icons.alarm, color: EsportsColors.cyan, onPressed: () {})),
          ])),
          const SizedBox(height: 16),
        ])),
      ]),
    );
  }

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 12, color: EsportsColors.textMuted)), Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))]));
}

class OngoingMatchDetail extends StatefulWidget {
  final MatchData match;
  const OngoingMatchDetail({super.key, required this.match});
  @override
  State<OngoingMatchDetail> createState() => _OngoingMatchDetailState();
}

class _OngoingMatchDetailState extends State<OngoingMatchDetail> with TickerProviderStateMixin {
  late AnimationController _liveCtrl, _radarCtrl;
  final PageController _pageCtrl = PageController();
  int _col = 0;
  Timer? _tick;
  late final List<Map<String, String>> _players;
  int _myRank = 4;
  int _projectedWin = 0;

  @override
  void initState() {
    super.initState();
    _liveCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _radarCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _players = List.generate(widget.match.filledSlots, (i) => {'name': randomName(i + 100), 'uid': randomUid(i + 100)});
    _projectedWin = (widget.match.prizePool * 0.075).round();
    _tick = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() { _myRank = max(1, _myRank + (Random().nextBool() ? -1 : 1)); });
    });
  }

  @override
  void dispose() { _liveCtrl.dispose(); _radarCtrl.dispose(); _pageCtrl.dispose(); _tick?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final c = Color(m.gradientColors[0]);
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
        SafeArea(child: Column(children: [
          Container(margin: const EdgeInsets.all(16), child: GlassCard(opacity: 0.08, child: Column(children: [
            Row(children: [
              appBackButton(context), const SizedBox(width: 12),
              buildGameLogo(m.gameName, c, 38), const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text(m.gameName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(width: 6), TagBadge(text: m.matchTag, color: c)]),
                Text('${m.matchType} • ${m.mapName}', style: const TextStyle(fontSize: 12, color: EsportsColors.textMuted)),
              ])),
              AnimatedBuilder(animation: _liveCtrl, builder: (_, __) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: EsportsColors.live.withOpacity(0.1 + 0.05 * _liveCtrl.value), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: EsportsColors.live.withOpacity(0.2 * _liveCtrl.value), blurRadius: 10)]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: const BoxDecoration(color: EsportsColors.live, shape: BoxShape.circle)), const SizedBox(width: 6), const Text('LIVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: EsportsColors.live))]),
                );
              }),
            ]),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              StatBox(label: 'Your Rank', value: '#$_myRank', color: _myRank <= 3 ? EsportsColors.gold : EsportsColors.cyan),
              StatBox(label: 'Projected', value: '₹$_projectedWin', color: EsportsColors.success),
              StatBox(label: 'Prize Pool', value: '₹${m.prizePool}', color: EsportsColors.gold),
            ]),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: NeonButton(
              label: 'WATCH ON YOUTUBE',
              icon: Icons.play_circle_fill,
              color: const Color(0xFFFF0000),
              onPressed: () {
                showDialog(context: context, builder: (_) => AlertDialog(
                  backgroundColor: EsportsColors.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(children: [Icon(Icons.play_circle_fill, color: const Color(0xFFFF0000), size: 28), SizedBox(width: 8), Text('Watch Live', style: TextStyle(color: Colors.white))]),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFF0000).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Column(children: [Icon(Icons.ondemand_video, size: 48, color: Color(0xFFFF0000)), SizedBox(height: 8), Text('UA Legend 2005', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)), SizedBox(height: 4), Text('youtube.com/@ualegend2005', style: TextStyle(fontSize: 11, color: EsportsColors.textMuted, fontFamily: 'monospace'))])),
                  ]),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE', style: TextStyle(color: EsportsColors.cyan)))],
                ));
              },
            )),
          ]))),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(3),
            decoration: glassDecoration(opacity: 0.06, borderRadius: 12),
            child: Row(children: [_colTab('Live Scores', 0, c), _colTab('Players', 1, c), _colTab('Prize', 2, c)]),
          ),
          Expanded(child: PageView(controller: _pageCtrl, onPageChanged: (i) => setState(() => _col = i), children: [
            _liveScoresPage(m, c),
            _playersListPage(),
            _prizeListPage(m),
          ])),
        ])),
      ]),
    );
  }

  Widget _colTab(String lbl, int idx, Color c) {
    final sel = _col == idx;
    return Expanded(child: GestureDetector(
      onTap: () { setState(() => _col = idx); _pageCtrl.animateToPage(idx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(gradient: sel ? EsportsColors.primaryGradient : null, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(lbl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? Colors.white : EsportsColors.textMuted))),
      ),
    ));
  }

  Widget _liveScoresPage(MatchData m, Color c) {
    final r = Random(m.id.hashCode);
    final entries = List.generate(min(10, m.filledSlots), (i) => LeaderEntry(
      rank: i + 1, username: i == _myRank - 1 ? 'ShadowStrike' : randomName(i + 50),
      uid: i == _myRank - 1 ? '9876543210' : randomUid(i + 50),
      kills: max(0, 12 - i + r.nextInt(4)), points: max(0, 100 - i * 8 + r.nextInt(12)),
      prize: i < 5 ? (m.prizePool * [0.4, 0.25, 0.15, 0.075, 0.075][i]).round() : 0,
    ));

    return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(16), children: [
      Center(child: AnimatedBuilder(animation: _radarCtrl, builder: (_, __) {
        return Container(
          width: 60, height: 60,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: c.withOpacity(0.1 + 0.1 * _radarCtrl.value), blurRadius: 20 + 10 * _radarCtrl.value)]),
          child: Icon(Icons.radar, color: c, size: 30),
        );
      })),
      const SizedBox(height: 12),
      ...entries.map((e) {
        final isMe = e.username == 'ShadowStrike';
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? EsportsColors.electricBlue.withOpacity(0.12) : EsportsColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isMe ? EsportsColors.electricBlue.withOpacity(0.3) : EsportsColors.border),
          ),
          child: Row(children: [
            SizedBox(width: 30, child: Text('#${e.rank}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: e.rank <= 3 ? EsportsColors.gold : EsportsColors.textMuted))),
            CircleAvatar(radius: 14, backgroundColor: isMe ? EsportsColors.electricBlue.withOpacity(0.3) : Colors.white.withOpacity(0.05),
              child: Text(e.username[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
            const SizedBox(width: 8),
            Expanded(child: Text(e.username, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isMe ? EsportsColors.cyan : Colors.white))),
            if (isMe) const TagBadge(text: 'YOU', color: EsportsColors.cyan, fontSize: 8),
            const SizedBox(width: 8),
            Text('${e.kills}K', style: const TextStyle(fontSize: 12, color: EsportsColors.live, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('${e.points}', style: const TextStyle(fontSize: 12, color: EsportsColors.cyan, fontWeight: FontWeight.w600)),
          ]),
        );
      }),
    ]);
  }

  Widget _playersListPage() {
    return ListView.builder(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _players.length, itemBuilder: (_, i) {
      final p = _players[i];
      return Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: glassDecoration(opacity: 0.05, borderRadius: 10),
        child: Row(children: [
          SizedBox(width: 28, child: Text('${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: EsportsColors.textMuted))),
          CircleAvatar(radius: 14, backgroundColor: Colors.primaries[i % Colors.primaries.length].withOpacity(0.2), child: Text(p['name']![0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
          const SizedBox(width: 8),
          Expanded(child: Text(p['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
          Text('${p['uid']!.substring(0, 4)}****', style: const TextStyle(fontSize: 10, color: EsportsColors.textDim, fontFamily: 'monospace')),
        ]),
      );
    });
  }

  Widget _prizeListPage(MatchData m) {
    final pool = m.prizePool;
    final dist = [{'r': '🥇 1st', 'p': 0.40, 'c': EsportsColors.gold}, {'r': '🥈 2nd', 'p': 0.25, 'c': const Color(0xFFBDBDBD)}, {'r': '🥉 3rd', 'p': 0.15, 'c': const Color(0xFFFF8A65)}, {'r': '4-5th', 'p': 0.075, 'c': EsportsColors.cyan}, {'r': '6-10th', 'p': 0.01, 'c': EsportsColors.textMuted}];
    return ListView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(16), children: [
      ...dist.map((d) {
        final clr = d['c'] as Color;
        return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: clr.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: clr.withOpacity(0.2))),
          child: Row(children: [Text(d['r'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: clr)), const Spacer(), Text('₹${(pool * (d['p'] as double)).round()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))]));
      }),
    ]);
  }
}

class CompletedMatchDetail extends StatefulWidget {
  final MatchData match;
  const CompletedMatchDetail({super.key, required this.match});
  @override
  State<CompletedMatchDetail> createState() => _CompletedMatchDetailState();
}

class _CompletedMatchDetailState extends State<CompletedMatchDetail> with TickerProviderStateMixin {
  late AnimationController _congratsCtrl, _shineCtrl, _confettiCtrl;
  late Animation<double> _congratsScale, _congratsOpacity, _shineAnim;
  late final List<LeaderEntry> _lb;
  int? _userRank;
  int _userPrize = 0;

  @override
  void initState() {
    super.initState();
    _congratsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _congratsScale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _congratsCtrl, curve: Curves.elasticOut));
    _congratsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _congratsCtrl, curve: const Interval(0, 0.4)));
    _shineCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _shineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_shineCtrl);
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

    final r = Random(widget.match.id.hashCode);
    final pool = widget.match.prizePool;
    final prizes = [(pool * 0.40).round(), (pool * 0.25).round(), (pool * 0.15).round(), (pool * 0.075).round(), (pool * 0.075).round(), (pool * 0.01).round(), (pool * 0.01).round(), (pool * 0.01).round(), (pool * 0.01).round(), (pool * 0.01).round()];
    _userRank = r.nextInt(8) + 1;
    _lb = List.generate(20, (i) {
      final rank = i + 1;
      final isUser = rank == _userRank;
      return LeaderEntry(rank: rank, username: isUser ? 'ShadowStrike' : randomName(i + 200 + widget.match.id.hashCode), uid: isUser ? '9876543210' : randomUid(i + 200 + widget.match.id.hashCode), kills: max(0, 14 - i + r.nextInt(4)), points: max(0, 120 - i * 6 + r.nextInt(12)), prize: rank <= prizes.length ? prizes[rank - 1] : 0);
    });
    if (_userRank != null && _userRank! <= prizes.length) {
      _userPrize = prizes[_userRank! - 1];
      WidgetsBinding.instance.addPostFrameCallback((_) => _congratsCtrl.forward());
    }
  }

  @override
  void dispose() { _congratsCtrl.dispose(); _shineCtrl.dispose(); _confettiCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final c = Color(m.gradientColors[0]);
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
        if (_userPrize > 0) AnimatedBuilder(animation: _confettiCtrl, builder: (_, __) => CustomPaint(painter: _ConfettiPainter(_confettiCtrl.value), size: Size.infinite)),
        SafeArea(child: Column(children: [
          Container(margin: const EdgeInsets.all(16), child: GlassCard(opacity: 0.08, child: Row(children: [
            appBackButton(context), const SizedBox(width: 12),
            buildGameLogo(m.gameName, c, 38), const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(m.gameName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(width: 6), TagBadge(text: m.matchTag, color: c)]),
              Text('${m.matchType} • ${m.mapName}', style: const TextStyle(fontSize: 12, color: EsportsColors.textMuted)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: const Text('COMPLETED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: EsportsColors.textMuted, letterSpacing: 1))),
          ]))),
          if (_userPrize > 0) FadeTransition(opacity: _congratsOpacity, child: ScaleTransition(scale: _congratsScale,
            child: AnimatedBuilder(animation: _shineAnim, builder: (_, __) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment(-1 + 2 * _shineAnim.value, -1), end: Alignment(1 - 2 * _shineAnim.value, 1), colors: [EsportsColors.gold.withOpacity(0.2), EsportsColors.goldDark.withOpacity(0.1), EsportsColors.gold.withOpacity(0.25)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: EsportsColors.gold.withOpacity(0.4)),
                  boxShadow: [BoxShadow(color: EsportsColors.gold.withOpacity(0.15), blurRadius: 20)],
                ),
                child: Column(children: [
                  const Icon(Icons.celebration, color: EsportsColors.gold, size: 32),
                  const SizedBox(height: 8),
                  ShaderMask(shaderCallback: (b) => LinearGradient(colors: [EsportsColors.gold, Color.lerp(EsportsColors.goldDark, EsportsColors.gold, _shineAnim.value)!, EsportsColors.gold]).createShader(b),
                    child: const Text('Congratulations ShadowStrike!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white))),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.emoji_events, color: EsportsColors.gold, size: 18), const SizedBox(width: 6),
                    Text('You won ₹$_userPrize (Rank #$_userRank)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: EsportsColors.gold)),
                  ]),
                  const SizedBox(height: 8),
                  const Text('Amount credited to wallet', style: TextStyle(fontSize: 11, color: EsportsColors.textMuted)),
                ]),
              );
            }),
          )),
          _buildPodium(c),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: EsportsColors.bg3, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: const Row(children: [SizedBox(width: 36, child: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EsportsColors.textMuted))), Expanded(child: Text('Player', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EsportsColors.textMuted))), SizedBox(width: 45, child: Text('Kills', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EsportsColors.textMuted))), SizedBox(width: 45, child: Text('Pts', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EsportsColors.textMuted))), SizedBox(width: 60, child: Text('Prize', textAlign: TextAlign.end, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: EsportsColors.textMuted)))]),
          ),
          Expanded(child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(color: EsportsColors.card, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)), border: Border.all(color: EsportsColors.border)),
            child: ListView.builder(physics: const BouncingScrollPhysics(), itemCount: _lb.length, itemBuilder: (_, i) => _leaderRow(_lb[i])),
          )),
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: NeonButton(label: 'PLAY AGAIN', icon: Icons.replay, color: c, breathing: true, onPressed: () => Navigator.pop(context))),
        ])),
      ]),
    );
  }

  Widget _buildPodium(Color c) {
    if (_lb.length < 3) return const SizedBox();
    final order = [_lb[1], _lb[0], _lb[2]];
    final heights = [80.0, 105.0, 60.0];
    final colors = [const Color(0xFFBDBDBD), EsportsColors.gold, const Color(0xFFFF8A65)];
    final labels = ['2nd', '1st', '3rd'];

    return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(3, (i) {
      final e = order[i];
      final isUser = e.username == 'ShadowStrike';
      return Expanded(child: TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1), duration: Duration(milliseconds: 600 + i * 200), curve: Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: 0.5 + 0.5 * v, child: Opacity(opacity: v.clamp(0, 1), child: child)),
        child: Column(children: [
          Container(
            decoration: isUser ? BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: colors[i].withOpacity(0.6), blurRadius: 16)]) : null,
            child: CircleAvatar(radius: i == 1 ? 26 : 20, backgroundColor: colors[i].withOpacity(0.2), child: Text(e.username[0], style: TextStyle(fontSize: i == 1 ? 18 : 14, fontWeight: FontWeight.w900, color: colors[i]))),
          ),
          const SizedBox(height: 3),
          Text(e.username, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isUser ? colors[i] : Colors.white), overflow: TextOverflow.ellipsis),
          Text('UID: ${e.uid.substring(0, 4)}', style: const TextStyle(fontSize: 8, color: EsportsColors.textDim, fontFamily: 'monospace')),
          Text('₹${e.prize}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors[i])),
          const SizedBox(height: 3),
          Container(width: 60, height: heights[i], decoration: BoxDecoration(
            gradient: LinearGradient(colors: [colors[i].withOpacity(0.35), colors[i].withOpacity(0.08)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: colors[i].withOpacity(0.25)),
          ), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.emoji_events, color: colors[i], size: i == 1 ? 24 : 18), Text(labels[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors[i]))])),
        ]),
      ));
    })));
  }

  Widget _leaderRow(LeaderEntry e) {
    final isUser = e.username == 'ShadowStrike';
    Color rc = e.rank == 1 ? EsportsColors.gold : e.rank == 2 ? const Color(0xFFBDBDBD) : e.rank == 3 ? const Color(0xFFFF8A65) : EsportsColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: EsportsColors.border.withOpacity(0.5))), color: isUser ? EsportsColors.electricBlue.withOpacity(0.12) : (e.rank <= 3 ? rc.withOpacity(0.04) : Colors.transparent)),
      child: Row(children: [
        SizedBox(width: 36, child: e.rank <= 3 ? Icon(Icons.emoji_events, size: 16, color: rc) : Text('#${e.rank}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: rc))),
        Expanded(child: Row(children: [
          CircleAvatar(radius: 13, backgroundColor: isUser ? EsportsColors.electricBlue.withOpacity(0.3) : rc.withOpacity(0.15), child: Text(e.username[0], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isUser ? Colors.white : rc))),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Flexible(child: Text(e.username, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isUser ? EsportsColors.cyan : Colors.white))), if (isUser) ...[const SizedBox(width: 4), const TagBadge(text: 'YOU', color: EsportsColors.cyan, fontSize: 7)]]),
            Text('${e.uid.substring(0, 4)}****', style: const TextStyle(fontSize: 9, color: EsportsColors.textDim, fontFamily: 'monospace')),
          ])),
        ])),
        SizedBox(width: 45, child: Text('${e.kills}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: EsportsColors.live, fontWeight: FontWeight.w600))),
        SizedBox(width: 45, child: Text('${e.points}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: EsportsColors.cyan, fontWeight: FontWeight.w600))),
        SizedBox(width: 60, child: Text(e.prize > 0 ? '₹${e.prize}' : '-', textAlign: TextAlign.end, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: e.prize > 0 ? EsportsColors.success : EsportsColors.textDim))),
      ]),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Random(42);
    final colors = [EsportsColors.gold, EsportsColors.cyan, EsportsColors.neonPurple, EsportsColors.electricBlue, EsportsColors.success];
    for (int i = 0; i < 40; i++) {
      final x = r.nextDouble() * size.width;
      final baseY = r.nextDouble() * size.height;
      final y = (baseY + progress * size.height * (0.3 + r.nextDouble() * 0.5)) % size.height;
      final paint = Paint()..color = colors[i % colors.length].withOpacity(0.4 * (1 - y / size.height));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: 4 + r.nextDouble() * 4, height: 3 + r.nextDouble() * 6), const Radius.circular(1)), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}