import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../widgets/components.dart';
import '../models/models.dart';
import '../data/contest_service.dart';
import 'contest_details_screen.dart';

class MyMatchesScreen extends StatefulWidget {
  const MyMatchesScreen({super.key});

  @override
  State<MyMatchesScreen> createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends State<MyMatchesScreen> {
  int _tab = 0;
  final _tabs = ['Upcoming', 'Live', 'Completed', 'Cancelled'];
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  String _formatTime(DateTime time) {
    final diff = time.difference(DateTime.now());
    if (diff.isNegative) return 'Started';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    return '${diff.inMinutes}m left';
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
            const Text('My Matches', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          ])),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(3),
            decoration: glassDecoration(opacity: 0.06, borderRadius: 14),
            child: Row(children: List.generate(_tabs.length, (i) {
              final sel = _tab == i;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(gradient: sel ? EsportsColors.primaryGradient : null, borderRadius: BorderRadius.circular(11)),
                  child: Center(child: Text(_tabs[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? Colors.white : EsportsColors.textMuted))),
                ),
              ));
            })),
          ),
          
          Expanded(
            child: _currentUid.isEmpty 
              ? const Center(child: Text('Not Logged In', style: TextStyle(color: EsportsColors.textMuted)))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(_currentUid).collection('joined_contests').snapshots(),
                  builder: (context, joinedSnap) {
                    if (joinedSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: EsportsColors.cyan));
                    }
                    if (!joinedSnap.hasData || joinedSnap.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Get a set of Contest IDs the user has joined
                    final joinedIds = joinedSnap.data!.docs.map((doc) => doc.id).toSet();

                    return StreamBuilder<List<ExtendedMatchData>>(
                      stream: ContestService().getContests(),
                      builder: (context, contestsSnap) {
                        if (contestsSnap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: EsportsColors.cyan));
                        }

                        final allMatches = contestsSnap.data ?? [];
                        
                        // Filter matches the user is in, and match the selected Tab status
                        final myMatches = allMatches.where((m) {
                          if (!joinedIds.contains(m.id)) return false;
                          
                          // Handle custom "Cancelled" state if applicable, otherwise use dynamicStatus
                          final currentStatus = m.status == 'Cancelled' ? 'Cancelled' : m.dynamicStatus;
                          return currentStatus == _tabs[_tab];
                        }).toList();

                        if (myMatches.isEmpty) return _buildEmptyState();

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: myMatches.length,
                          itemBuilder: (_, i) {
                            final m = myMatches[i];
                            final color = m.gradientColors.isNotEmpty ? Color(m.gradientColors.first) : EsportsColors.cyan;
                            
                            return GestureDetector(
                              onTap: () {
                                final currentUser = FirebaseAuth.instance.currentUser;
                                if (currentUser != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ContestDetailsScreen(
                                        match: m,
                                        // Pass a basic UserProfile since we just need the UID for the Details Screen query
                                        currentUser: UserProfile(uid: currentUser.uid, name: '', email: '', avatarLetter: 'U'), 
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
                                child: Row(children: [
                                  Container(
                                    padding: const EdgeInsets.all(10), 
                                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                                    child: Icon(IconData(m.gameIconCode, fontFamily: 'MaterialIcons'), color: color, size: 22)
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(children: [
                                      Flexible(child: Text(m.gameName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis)), 
                                      const SizedBox(width: 6), 
                                      TagBadge(text: m.matchTag, color: color, fontSize: 8)
                                    ]),
                                    const SizedBox(height: 4),
                                    Text('Entry: ${m.isFree ? "FREE" : "₹${m.entryFee}"} • Prize: ₹${m.prizePool}', style: const TextStyle(fontSize: 11, color: EsportsColors.textMuted)),
                                  ])),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text(_formatTime(m.matchTime), style: const TextStyle(fontSize: 11, color: EsportsColors.textDim)),
                                    if (_tab == 2) ...[
                                      const SizedBox(height: 4),
                                      const TagBadge(text: 'VIEW RESULTS', color: EsportsColors.gold, fontSize: 9),
                                    ]
                                  ]),
                                ]),
                              ),
                            );
                          },
                        );
                      }
                    );
                  }
                ),
          ),
        ])),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          const Icon(Icons.inbox, color: EsportsColors.textDim, size: 48), 
          const SizedBox(height: 8), 
          Text('No ${_tabs[_tab].toLowerCase()} matches', style: const TextStyle(color: EsportsColors.textMuted))
        ]
      )
    );
  }
}