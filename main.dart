import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/theme.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/contest_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/my_matches_screen.dart';
import 'screens/ai_support_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseAvailable = true;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stack) {
    firebaseAvailable = false;
    debugPrint('Firebase initialization failed: $error\n$stack');
  }

  // Local Emulator is DISABLED so the User App connects to the Live Database
  /*
  if (kDebugMode && firebaseAvailable) {
    try {
      String host = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : 'localhost';
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      FirebaseAuth.instance.useAuthEmulator(host, 9099);
      debugPrint('--- [Emulator] Connected to Firebase Local Emulators on $host ---');
    } catch (e) {
      debugPrint('--- [Emulator] Connection failed: $e ---');
    }
  }
  */

  runApp(EsportsApp(firebaseAvailable: firebaseAvailable));
}

class EsportsApp extends StatelessWidget {
  final bool firebaseAvailable;
  const EsportsApp({super.key, required this.firebaseAvailable});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UA Esports',
      debugShowCheckedModeBanner: false,
      theme: EsportsTheme.dark,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            boldText: false,
            textScaler: const TextScaler.linear(1),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(decoration: TextDecoration.none),
            child: child!,
          ),
        );
      },
      home: !firebaseAvailable 
          ? const Scaffold(body: Center(child: Text('Failed to connect to servers.', style: TextStyle(color: Colors.white))))
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator(color: EsportsColors.cyan)),
                  );
                }
                if (snapshot.hasData) {
                  return MainShell(firebaseAvailable: firebaseAvailable);
                }
                return const MobileAuthScreen();
              },
            ),
    );
  }
}

class MainShell extends StatefulWidget {
  final bool firebaseAvailable;
  const MainShell({super.key, required this.firebaseAvailable});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  late AnimationController _fabCtrl;

  List<Widget> get _screens => [
    const HomeScreen(),
    ContestScreen(firebaseAvailable: widget.firebaseAvailable),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() { 
    _fabCtrl.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: _navIndex,
            children: _screens,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            left: 16,
            child: Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: EsportsColors.card.withOpacity(.85),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: EsportsColors.border),
                    ),
                    child: const Icon(Icons.menu_rounded, color: EsportsColors.cyan, size: 26),
                  ),
                );
              },
            ),
          ),
          if (_navIndex == 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              right: 16,
              child: _floatingQuickJoin(),
            ),
          Positioned(
            bottom: 90,
            right: 16,
            child: AnimatedBuilder(
              animation: _fabCtrl,
              builder: (_, __) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AiSupportScreen()));
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: EsportsColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: EsportsColors.electricBlue.withOpacity(0.3 + 0.1 * _fabCtrl.value),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.support_agent, color: Colors.white, size: 24),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: EsportsColors.bg2.withOpacity(0.95),
        border: const Border(top: BorderSide(color: EsportsColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _navItem(0, Icons.home_filled, 'Home'),
                _navItem(1, Icons.emoji_events, 'Contest'),
                _navItem(2, Icons.person, 'Profile'),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final sel = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: sel ? 20 : 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: sel ? LinearGradient(colors: [EsportsColors.electricBlue.withOpacity(0.15), EsportsColors.neonPurple.withOpacity(0.1)]) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: sel ? EsportsColors.cyan : EsportsColors.textDim, size: 22),
          if (sel) ...[
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: EsportsColors.cyan)),
          ],
        ]),
      ),
    );
  }

  Widget _buildDrawer() {
    final items = [
      {'icon': Icons.home_filled, 'label': 'Home', 'screen': null},
      {'icon': Icons.person, 'label': 'Profile', 'screen': const ProfileScreen()},
      {'icon': Icons.settings, 'label': 'Settings', 'screen': const SettingsScreen()},
      {'icon': Icons.notifications, 'label': 'Notifications', 'screen': const NotificationsScreen()},
      {'icon': Icons.sports_esports, 'label': 'My Matches', 'screen': const MyMatchesScreen()},
      {'icon': Icons.support_agent, 'label': 'AI Support', 'screen': const AiSupportScreen()},
      {'icon': Icons.account_balance_wallet, 'label': 'Wallet', 'screen': const WalletScreen()},
    ];

    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [EsportsColors.bg2.withOpacity(0.95), EsportsColors.bg3.withOpacity(0.9)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              border: const Border(right: BorderSide(color: EsportsColors.border)),
            ),
            child: SafeArea(child: Column(children: [
              const SizedBox(height: 20),
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: EsportsColors.primaryGradient,
                  boxShadow: [BoxShadow(color: EsportsColors.electricBlue.withOpacity(0.3), blurRadius: 16)],
                ),
                child: const Center(child: Text('U', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white))),
              ),
              const SizedBox(height: 10),
              const Text('Player', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 30),
              Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 20), color: EsportsColors.border),
              const SizedBox(height: 10),
              ...items.map((item) => ListTile(
                leading: Icon(item['icon'] as IconData, color: EsportsColors.cyan, size: 22),
                title: Text(item['label'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context); 
                  if (item['screen'] == null) {
                    setState(() => _navIndex = 0);
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'] as Widget));
                  }
                },
              )),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout, color: EsportsColors.live, size: 22),
                title: const Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: EsportsColors.live)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => _showLogoutDialog(),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('v2.1.0', style: TextStyle(fontSize: 11, color: EsportsColors.textDim)),
              ),
            ])),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Navigator.pop(context); 
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: EsportsColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      content: const Text('Are you sure you want to logout?', style: TextStyle(color: EsportsColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: EsportsColors.textMuted))),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await FirebaseAuth.instance.signOut();
          },
          style: ElevatedButton.styleFrom(backgroundColor: EsportsColors.live, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ],
    ));
  }

  Widget _floatingQuickJoin() {
    return GestureDetector(
      onTap: () => setState(() => _navIndex = 1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: EsportsColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: EsportsColors.electricBlue.withOpacity(0.3), blurRadius: 12)],
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.flash_on, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text('Quick Join', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
    );
  }
}