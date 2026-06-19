// Location: lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../data/admin_service.dart';
import 'create_contest_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: EsportsColors.card,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
            unselectedIconTheme: const IconThemeData(color: EsportsColors.textMuted),
            selectedIconTheme: const IconThemeData(color: EsportsColors.cyan),
            unselectedLabelTextStyle: const TextStyle(color: EsportsColors.textMuted),
            selectedLabelTextStyle: const TextStyle(color: EsportsColors.cyan, fontWeight: FontWeight.bold),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.sports_esports), label: Text('Contests')),
              NavigationRailDestination(icon: Icon(Icons.payment), label: Text('Payments')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: EsportsColors.border),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(gradient: EsportsColors.meshBg),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return _buildMetricsDashboard();
      case 1: return _buildContestManagement(); 
      case 2: return _buildPaymentApprovals();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildMetricsDashboard() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin Dashboard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildMetricCard('Total Users', 'Active', Icons.people, EsportsColors.cyan),
              _buildMetricCard('Live Contests', 'System Normal', Icons.sensors, EsportsColors.live),
              _buildMetricCard('Pending Payments', 'Check Tab', Icons.pending_actions, EsportsColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: EsportsColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title, style: const TextStyle(fontSize: 14, color: EsportsColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildContestManagement() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Contest Management', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: EsportsColors.electricBlue, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('CREATE NEW CONTEST', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateContestScreen())),
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('contests').orderBy('matchTime', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Text('No contests found.', style: TextStyle(color: EsportsColors.textMuted));

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return Card(
                      color: EsportsColors.card,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: EsportsColors.border, child: Text(data['gameName'][0], style: const TextStyle(color: Colors.white))),
                        title: Text(data['title'] ?? 'Match', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: ${doc.id} | Status: ${data['status']}', style: const TextStyle(color: EsportsColors.textMuted)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: EsportsColors.neonPurple),
                              onPressed: () => _showRoomIdDialog(doc.id, data['roomId'] ?? '', data['roomPassword'] ?? ''),
                              child: const Text('ROOM ID', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: EsportsColors.gold),
                              onPressed: data['status'] == 'Results Declared' ? null : () => _showResultsDialog(doc.id),
                              child: Text(data['status'] == 'Results Declared' ? 'PAID' : 'PAY WINNERS', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRoomIdDialog(String contestId, String currentId, String currentPass) {
    final idCtrl = TextEditingController(text: currentId);
    final passCtrl = TextEditingController(text: currentPass);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: EsportsColors.bg2,
        title: const Text('Set Room ID & Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Room ID', filled: true, fillColor: EsportsColors.card)),
            const SizedBox(height: 12),
            TextField(controller: passCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Room Password', filled: true, fillColor: EsportsColors.card)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(color: EsportsColors.textMuted))),
          ElevatedButton(
            onPressed: () {
              // Capture messenger using main context before closing dialog
              final messenger = ScaffoldMessenger.of(context);
              
              _adminService.updateRoomDetails(contestId, idCtrl.text, passCtrl.text);
              Navigator.pop(dialogContext);
              
              messenger.showSnackBar(const SnackBar(content: Text('Room Details Live!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: EsportsColors.success),
            child: const Text('PUBLISH TO APP', style: TextStyle(color: Colors.white)),
          )
        ],
      )
    ).then((_) {
      idCtrl.dispose();
      passCtrl.dispose();
    });
  }

  void _showResultsDialog(String contestId) async {
    final snapshot = await FirebaseFirestore.instance.collection('contests').doc(contestId).collection('participants').get();
    
    if (snapshot.docs.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No participants in this match!')));
      return;
    }

    Map<String, TextEditingController> prizeControllers = {};
    for (var doc in snapshot.docs) {
      prizeControllers[doc.id] = TextEditingController(text: '0');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: EsportsColors.bg2,
        title: const Text('Distribute Prizes', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 400,
          height: MediaQuery.of(context).size.height * 0.6, 
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final player = snapshot.docs[index].data();
              final uid = snapshot.docs[index].id;
              return ListTile(
                title: Text(player['username'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                subtitle: Text('Game ID: ${player['gameIdUsed']}', style: const TextStyle(color: EsportsColors.textMuted)),
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: prizeControllers[uid],
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: EsportsColors.gold, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(prefixText: '₹ ', filled: true, fillColor: EsportsColors.card),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(color: EsportsColors.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: EsportsColors.gold),
            onPressed: () async {
              List<Map<String, dynamic>> winners = [];
              for (var doc in snapshot.docs) {
                final uid = doc.id;
                final prizeAmount = double.tryParse(prizeControllers[uid]!.text) ?? 0;
                if (prizeAmount > 0) {
                  winners.add({'uid': uid, 'prize': prizeAmount});
                }
              }

              // Capture ScaffoldMessenger before popping the dialog or awaiting
              final messenger = ScaffoldMessenger.of(context);
              
              Navigator.pop(dialogContext);
              
              messenger.showSnackBar(const SnackBar(content: Text('Distributing Prizes...')));
              
              await _adminService.publishLeaderboard(contestId, winners);
              
              if (mounted) {
                messenger.showSnackBar(const SnackBar(content: Text('Prizes Distributed Successfully!'), backgroundColor: EsportsColors.success));
              }
            },
            child: const Text('CONFIRM PAYMENTS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      )
    ).then((_) {
      for (var ctrl in prizeControllers.values) {
        ctrl.dispose();
      }
    });
  }

  Widget _buildPaymentApprovals() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pending Payment Approvals', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collectionGroup('participants').where('paymentStatus', isEqualTo: 'Pending').snapshots(),
              builder: (context, snapshot) {
                // FIXED: Added error checking to catch Firebase missing index or permission exceptions
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SelectableText(
                        'Firebase Error: ${snapshot.error}\n\n'
                        'IMPORTANT: If this says "Permission Denied", you need to update your Firestore Rules. '
                        'If it says "Index Required", check your terminal/console for the creation link.', 
                        style: const TextStyle(color: EsportsColors.live, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  );
                }

                // FIXED: Only show loading spinner if waiting AND no data exists
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                   return const Center(child: CircularProgressIndicator(color: EsportsColors.cyan));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No pending payments.', style: TextStyle(color: EsportsColors.textMuted)));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return Card(
                      color: EsportsColors.card,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.receipt, color: EsportsColors.warning),
                        title: Text('${data['username']} (UID: ${data['uid']})', style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Game ID: ${data['gameIdUsed']}', style: const TextStyle(color: EsportsColors.textMuted)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.image, color: EsportsColors.cyan),
                              label: const Text('View Receipt'),
                              onPressed: () => _showReceiptDialog(data['paymentScreenshotUrl'] ?? ''),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: EsportsColors.success),
                              onPressed: () => _adminService.updatePaymentStatus(doc.reference.parent.parent!.id, doc.id, 'Approved'),
                              child: const Text('APPROVE', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiptDialog(String url) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: EsportsColors.bg2,
        content: url.isNotEmpty 
            ? Image.network(
                url, 
                height: 400,
                errorBuilder: (context, error, stackTrace) => const Text('Image load failed', style: TextStyle(color: Colors.white)),
              ) 
            : const Text('No image provided', style: TextStyle(color: Colors.white)),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close', style: TextStyle(color: Colors.white)))],
      )
    );
  }
}