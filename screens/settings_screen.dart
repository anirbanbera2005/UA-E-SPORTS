import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true, _animations = true, _dataSaver = false, _biometric = false;
  bool _matchNotif = true, _walletNotif = true, _offerNotif = true;
  bool _perfMode = false, _streamMode = false, _lowData = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
        SafeArea(child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [appBackButton(context), const SizedBox(width: 12), const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white))]),
            const SizedBox(height: 20),
            _section('Appearance', Icons.palette, [
              _toggle('Dark Mode', 'Premium dark theme', _darkMode, (v) => setState(() => _darkMode = v)),
              _toggle('Animations', 'Enable smooth transitions', _animations, (v) => setState(() => _animations = v)),
              _dropdownTile('Language', _language, ['English', 'Hindi', 'Tamil', 'Telugu'], (v) => setState(() => _language = v!)),
            ]),
            _section('Notifications', Icons.notifications, [
              _toggle('Match Alerts', 'Upcoming match reminders', _matchNotif, (v) => setState(() => _matchNotif = v)),
              _toggle('Wallet Updates', 'Transaction notifications', _walletNotif, (v) => setState(() => _walletNotif = v)),
              _toggle('Offers', 'Deals and promotions', _offerNotif, (v) => setState(() => _offerNotif = v)),
            ]),
            _section('Security', Icons.security, [
              _toggle('Biometric Lock', 'Fingerprint / Face ID', _biometric, (v) => setState(() => _biometric = v)),
              _toggle('Data Saver', 'Reduce data usage', _dataSaver, (v) => setState(() => _dataSaver = v)),
              _actionTile('Change Password', Icons.lock, () {}),
              _actionTile('Two-Factor Auth', Icons.verified_user, () {}),
            ]),
            _section('Gaming', Icons.sports_esports, [
              _toggle('Performance Mode', 'Optimize for speed', _perfMode, (v) => setState(() => _perfMode = v)),
              _toggle('Stream Mode', 'Hide sensitive info', _streamMode, (v) => setState(() => _streamMode = v)),
              _toggle('Low Data Mode', 'Minimal data usage', _lowData, (v) => setState(() => _lowData = v)),
            ]),
            _section('About', Icons.info, [
              _infoTile('Version', '2.1.0'),
              _infoTile('Build', '2025.05.23'),
              _actionTile('Privacy Policy', Icons.privacy_tip, () {}),
              _actionTile('Terms of Service', Icons.description, () {}),
            ]),
            const SizedBox(height: 80),
          ]),
        )),
      ]),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Row(children: [Icon(icon, color: EsportsColors.cyan, size: 18), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))]),
      const SizedBox(height: 10),
      GlassCard(opacity: 0.06, padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), child: Column(children: children)),
      const SizedBox(height: 8),
    ]);
  }

  Widget _toggle(String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          Text(sub, style: const TextStyle(fontSize: 11, color: EsportsColors.textMuted)),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: EsportsColors.electricBlue, inactiveTrackColor: EsportsColors.border),
      ]),
    );
  }

  Widget _dropdownTile(String title, String current, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
        DropdownButton<String>(
          value: current, dropdownColor: EsportsColors.card,
          style: const TextStyle(fontSize: 13, color: EsportsColors.cyan),
          underline: const SizedBox(),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChanged,
        ),
      ]),
    );
  }

  Widget _actionTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: EsportsColors.textDim, size: 20),
        ]),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, color: EsportsColors.textMuted)),
      ]),
    );
  }
}