import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/components.dart';
import '../data/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late AnimationController _coinCtrl;
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? ''; 

  @override
  void initState() {
    super.initState();
    _coinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() { _coinCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (currentUid.isEmpty) return const Scaffold(backgroundColor: EsportsColors.bg1, body: Center(child: Text("Not Logged In", style: TextStyle(color: Colors.white))));

    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
          const ParticleBackground(count: 15, color: EsportsColors.gold),
          SafeArea(
            child: StreamBuilder<WalletData>(
              stream: UserService().getUserWallet(currentUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: EsportsColors.gold));
                final wallet = snapshot.data ?? WalletData();
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Row(children: [appBackButton(context), const SizedBox(width: 12), const Text('Wallet & History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white))]),
                      const SizedBox(height: 20),
                      _buildBalanceCard(wallet),
                      const SizedBox(height: 16),
                      _buildActions(),
                      const SizedBox(height: 20),
                      _buildTransactions(wallet),
                      const SizedBox(height: 80),
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

  Widget _buildBalanceCard(WalletData wallet) {
    return AnimatedBuilder(
      animation: _coinCtrl, 
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + _coinCtrl.value * 2, -1), end: Alignment(1 - _coinCtrl.value * 2, 1),
              colors: [EsportsColors.gold.withOpacity(0.2), EsportsColors.card, EsportsColors.goldDark.withOpacity(0.15)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: EsportsColors.gold.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: EsportsColors.gold.withOpacity(0.1), blurRadius: 20)],
          ),
          child: Column(
            children: [
              const Text('Total Balance', style: TextStyle(fontSize: 13, color: EsportsColors.textMuted)),
              const SizedBox(height: 4),
              AnimatedCounter(value: wallet.balance, prefix: '₹ ', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: EsportsColors.gold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _balanceBox('Bonus', '₹ ${wallet.bonus.toInt()}', EsportsColors.neonPurple)),
                  const SizedBox(width: 12),
                  Expanded(child: _balanceBox('Withdrawable', '₹ ${wallet.withdrawable.toInt()}', EsportsColors.success)),
                ]
              ),
            ]
          ),
        );
      }
    );
  }

  Widget _balanceBox(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        children: [
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: EsportsColors.textMuted)),
        ]
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(child: NeonButton(label: 'ADD FUNDS', icon: Icons.add_circle, color: EsportsColors.success, onPressed: () {})),
        const SizedBox(width: 12),
        Expanded(child: NeonButton(label: 'WITHDRAW', icon: Icons.account_balance, color: EsportsColors.electricBlue, onPressed: () {})),
      ]
    );
  }

  Widget _buildTransactions(WalletData wallet) {
    return GlassCard(
      opacity: 0.06, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const Row(children: [Icon(Icons.receipt_long, color: EsportsColors.cyan, size: 18), SizedBox(width: 8), Text('Recent Match Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))]),
          const SizedBox(height: 12),
          if (wallet.transactions.isEmpty) const Text('No recent activities.', style: TextStyle(color: EsportsColors.textMuted)),
          ...wallet.transactions.map((t) {
            final isCredit = t.type == 'credit';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: glassDecoration(opacity: 0.05, borderRadius: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: (isCredit ? EsportsColors.success : EsportsColors.live).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? EsportsColors.success : EsportsColors.live, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text(t.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text(_timeAgo(t.time), style: const TextStyle(fontSize: 10, color: EsportsColors.textDim)),
                      ]
                    )
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end, 
                    children: [
                      Text('${isCredit ? "+" : "-"} ₹ ${t.amount.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isCredit ? EsportsColors.success : EsportsColors.live)),
                      if (t.status == 'pending') const TagBadge(text: 'PENDING', color: EsportsColors.warning, fontSize: 8),
                    ]
                  ),
                ]
              ),
            );
          }),
        ]
      )
    );
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}