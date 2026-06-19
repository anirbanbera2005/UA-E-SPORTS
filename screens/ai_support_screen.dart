import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/components.dart';

class AiSupportScreen extends StatefulWidget {
  const AiSupportScreen({super.key});
  @override
  State<AiSupportScreen> createState() => _AiSupportScreenState();
}

class _AiSupportScreenState extends State<AiSupportScreen> with TickerProviderStateMixin {
  late AnimationController _orbCtrl;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;

  final _quickActions = [
    {'label': 'Wallet Issue', 'icon': Icons.account_balance_wallet, 'color': EsportsColors.gold},
    {'label': 'Refund', 'icon': Icons.replay, 'color': EsportsColors.live},
    {'label': 'Match Help', 'icon': Icons.sports_esports, 'color': EsportsColors.electricBlue},
    {'label': 'Report Bug', 'icon': Icons.bug_report, 'color': EsportsColors.neonPurple},
    {'label': 'Account', 'icon': Icons.person, 'color': EsportsColors.cyan},
  ];

  final List<ChatMessage> _messages = [
    ChatMessage(text: 'Hello! I\'m your AI Support assistant. How can I help you today?', isUser: false, time: DateTime.now()),
  ];

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() { _orbCtrl.dispose(); _msgCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: _getAiResponse(text),
          isUser: false,
          time: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  String _getAiResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('wallet') || lower.contains('balance')) return 'Your current wallet balance is ₹2,500. Bonus: ₹350, Withdrawable: ₹1,800. Would you like to add money or withdraw?';
    if (lower.contains('refund')) return 'I can help with refunds. Please provide the match ID and reason. Refunds are processed within 24-48 hours after verification.';
    if (lower.contains('withdraw')) return 'To withdraw, go to Wallet → Withdraw. Minimum withdrawal is ₹100. Processing takes 24-48 hours to your linked bank account.';
    if (lower.contains('match') || lower.contains('join')) return 'To join a match: go to Contest → select a match → tap JOIN → enter your Game UID → confirm payment. Make sure to join the room 10 minutes before start!';
    if (lower.contains('report') || lower.contains('bug')) return 'I\'ve created a support ticket for your report. Ticket ID: #UA2025-${Random().nextInt(9999).toString().padLeft(4, '0')}. Our team will investigate within 24 hours.';
    return 'Thanks for reaching out! I\'m here to help with wallet issues, match queries, refunds, bug reports, and account management. What do you need assistance with?';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
        SafeArea(child: Column(children: [
          _buildHeader(),
          Expanded(child: _buildChat()),
          if (_messages.length <= 1) _buildQuickActions(),
          _buildInput(),
        ])),
      ]),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        appBackButton(context),
        const SizedBox(width: 12),
        AnimatedBuilder(animation: _orbCtrl, builder: (_, __) {
          return Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [EsportsColors.electricBlue.withOpacity(0.6 + 0.2 * _orbCtrl.value), EsportsColors.neonPurple.withOpacity(0.6 + 0.2 * _orbCtrl.value)]),
              boxShadow: [BoxShadow(color: EsportsColors.electricBlue.withOpacity(0.2 + 0.1 * _orbCtrl.value), blurRadius: 12 + 4 * _orbCtrl.value)],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          );
        }),
        const SizedBox(width: 10),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          Row(children: [Icon(Icons.circle, size: 8, color: EsportsColors.success), SizedBox(width: 4), Text('Online', style: TextStyle(fontSize: 11, color: EsportsColors.success))]),
        ])),
        GestureDetector(
          onTap: () {},
          child: Container(padding: const EdgeInsets.all(8), decoration: glassDecoration(opacity: 0.08, borderRadius: 10),
            child: const Icon(Icons.support_agent, color: EsportsColors.cyan, size: 20)),
        ),
      ]),
    );
  }

  Widget _buildChat() {
    return ListView.builder(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _messages.length) return _typingIndicator();
        final msg = _messages[i];
        return _chatBubble(msg);
      },
    );
  }

  Widget _chatBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? EsportsColors.electricBlue.withOpacity(0.2) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          border: Border.all(color: msg.isUser ? EsportsColors.electricBlue.withOpacity(0.3) : EsportsColors.glassBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(msg.text, style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4)),
          const SizedBox(height: 4),
          Text('${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 9, color: EsportsColors.textDim)),
        ]),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16), bottomLeft: Radius.circular(4)),
          border: Border.all(color: EsportsColors.glassBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _dot(0), const SizedBox(width: 4), _dot(1), const SizedBox(width: 4), _dot(2),
        ]),
      ),
    );
  }

  Widget _dot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + index * 200),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Container(
        width: 8, height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: EsportsColors.electricBlue.withOpacity(0.3 + 0.4 * v)),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _quickActions.map((a) {
          final color = a['color'] as Color;
          return GestureDetector(
            onTap: () => _sendMessage(a['label'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.25))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(a['icon'] as IconData, color: color, size: 16), const SizedBox(width: 6),
                Text(a['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(children: [
        Expanded(child: Container(
          decoration: glassDecoration(opacity: 0.08, borderRadius: 24),
          child: TextField(
            controller: _msgCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            onSubmitted: _sendMessage,
            decoration: InputDecoration(
              hintText: 'Type a message...', hintStyle: const TextStyle(color: EsportsColors.textDim),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton(icon: const Icon(Icons.mic, color: EsportsColors.textMuted, size: 20), onPressed: () {}),
            ),
          ),
        )),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _sendMessage(_msgCtrl.text),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(gradient: EsportsColors.primaryGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: EsportsColors.electricBlue.withOpacity(0.3), blurRadius: 10)]),
            child: const Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}