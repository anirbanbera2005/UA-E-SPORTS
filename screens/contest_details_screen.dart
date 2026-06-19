import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/components.dart';
import 'join_contest_screen.dart';

class ContestDetailsScreen extends StatelessWidget {
  final ExtendedMatchData match;
  final UserProfile currentUser;

  const ContestDetailsScreen({super.key, required this.match, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('contests').doc(match.id).snapshots(),
      builder: (context, matchSnap) {
        if (matchSnap.connectionState == ConnectionState.waiting && !matchSnap.hasData) {
          return const Scaffold(backgroundColor: EsportsColors.bg1, body: Center(child: CircularProgressIndicator(color: EsportsColors.cyan)));
        }
        if (!matchSnap.hasData || !matchSnap.data!.exists) {
          return const Scaffold(backgroundColor: EsportsColors.bg1, body: Center(child: Text('Contest no longer exists.', style: TextStyle(color: Colors.white))));
        }

        final liveMatch = ExtendedMatchData.fromFirestore(
          matchSnap.data!.data() as Map<String, dynamic>,
          match.id,
          match.gameIconCode,
          match.gradientColors,
        );

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('contests')
              .doc(liveMatch.id)
              .collection('participants')
              .doc(currentUser.uid)
              .snapshots(),
          builder: (context, participantSnap) {
            
            final bool isJoined = participantSnap.hasData && participantSnap.data!.exists;
            final Map<String, dynamic>? participantData =
                isJoined ? participantSnap.data!.data() as Map<String, dynamic> : null;
            
            final String paymentStatus = participantData?['paymentStatus'] ?? 'Pending';

            return Scaffold(
              backgroundColor: EsportsColors.bg1,
              body: Stack(
                children: [
                  Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
                  _buildContent(context, liveMatch, isJoined, paymentStatus),
                ],
              ),
              bottomNavigationBar: _buildBottomBar(context, liveMatch, isJoined),
            );
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ExtendedMatchData liveMatch, bool isJoined, String paymentStatus) {
    // FIX: Hardened against empty gradientColors array
    final c = liveMatch.gradientColors.isNotEmpty 
        ? Color(liveMatch.gradientColors[0]) 
        : EsportsColors.cyan;
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: EsportsColors.bg1,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.withOpacity(0.4), EsportsColors.bg1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Icon(IconData(liveMatch.gameIconCode, fontFamily: 'MaterialIcons'), size: 80, color: c.withOpacity(0.5)),
              ),
            ),
            title: Text('${liveMatch.gameName} - ${liveMatch.matchType}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoGrid(liveMatch),
                const SizedBox(height: 24),

                if (isJoined) 
                  _buildJoinedStatusCard(context, liveMatch, paymentStatus)
                else 
                  _buildRulesAndDetails(liveMatch),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(ExtendedMatchData liveMatch) {
    return Row(
      children: [
        Expanded(child: _infoBox('Entry Fee', liveMatch.isFree ? 'FREE' : '₹${liveMatch.entryFee}', Icons.confirmation_num, EsportsColors.cyan)),
        const SizedBox(width: 12),
        Expanded(child: _infoBox('Prize Pool', '₹${liveMatch.prizePool}', Icons.emoji_events, EsportsColors.gold)),
        const SizedBox(width: 12),
        Expanded(child: _infoBox('Filled', '${liveMatch.filledSlots}/${liveMatch.totalSlots}', Icons.people, EsportsColors.neonPurple)),
      ],
    );
  }

  Widget _infoBox(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: glassDecoration(opacity: 0.1, borderRadius: 12, borderColor: color.withOpacity(0.3)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: EsportsColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildRulesAndDetails(ExtendedMatchData liveMatch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Match Rules', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (liveMatch.rules.isEmpty)
          const Text('No special rules specified.', style: TextStyle(color: EsportsColors.textSecondary))
        else
          ...liveMatch.rules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 8, color: EsportsColors.cyan),
                    const SizedBox(width: 12),
                    Expanded(child: Text(rule, style: const TextStyle(color: EsportsColors.textSecondary, height: 1.4))),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildJoinedStatusCard(BuildContext context, ExtendedMatchData liveMatch, String paymentStatus) {
    if (paymentStatus == 'Pending') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: EsportsColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: EsportsColors.warning)),
        child: const Column(
          children: [
            Icon(Icons.hourglass_top, color: EsportsColors.warning, size: 40),
            SizedBox(height: 12),
            Text('Payment Under Review', style: TextStyle(color: EsportsColors.warning, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Admin is verifying your payment screenshot. Room details will unlock upon approval.', textAlign: TextAlign.center, style: TextStyle(color: EsportsColors.textSecondary)),
          ],
        ),
      );
    }

    if (paymentStatus == 'Approved') {
      if (!liveMatch.isRoomRevealed) {
        final hr = liveMatch.roomRevealTime.toLocal().hour;
        final min = liveMatch.roomRevealTime.toLocal().minute.toString().padLeft(2, '0');
        final ampm = hr >= 12 ? 'PM' : 'AM';
        final hr12 = hr > 12 ? hr - 12 : (hr == 0 ? 12 : hr);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: EsportsColors.electricBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: EsportsColors.electricBlue)),
          child: Column(
            children: [
              const Icon(Icons.lock_clock, color: EsportsColors.electricBlue, size: 40),
              const SizedBox(height: 12),
              const Text('Registration Confirmed', style: TextStyle(color: EsportsColors.electricBlue, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Room ID and Password will be revealed here at $hr12:$min $ampm.', textAlign: TextAlign.center, style: const TextStyle(color: EsportsColors.textSecondary)),
            ],
          ),
        );
      } else {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: EsportsColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: EsportsColors.success)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.meeting_room, color: EsportsColors.success),
                  SizedBox(width: 8),
                  Text('Room Details Revealed!', style: TextStyle(color: EsportsColors.success, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              
              const Text('ROOM ID', style: TextStyle(color: EsportsColors.textMuted, fontSize: 12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(liveMatch.roomId.isEmpty ? 'Waiting for admin...' : liveMatch.roomId, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  if (liveMatch.roomId.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.copy, color: EsportsColors.success),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: liveMatch.roomId));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room ID Copied!')));
                      },
                    ),
                ],
              ),
              const Divider(color: EsportsColors.border, height: 32),
              
              const Text('PASSWORD', style: TextStyle(color: EsportsColors.textMuted, fontSize: 12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(liveMatch.roomPassword.isEmpty ? 'Waiting for admin...' : liveMatch.roomPassword, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  if (liveMatch.roomPassword.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.copy, color: EsportsColors.success),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: liveMatch.roomPassword));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Copied!')));
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget? _buildBottomBar(BuildContext context, ExtendedMatchData liveMatch, bool isJoined) {
    if (isJoined) return null; 

    if (liveMatch.slotsLeft <= 0) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        color: EsportsColors.bg2,
        child: const Text('MATCH FULL', style: TextStyle(color: EsportsColors.live, fontSize: 20, fontWeight: FontWeight.bold)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EsportsColors.bg2,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: EsportsColors.electricBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => JoinContestScreen(match: liveMatch, currentUser: currentUser)),
              );
            },
            child: Text(
              liveMatch.isFree ? 'JOIN FOR FREE' : 'PAY ₹${liveMatch.entryFee} TO JOIN',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }
}