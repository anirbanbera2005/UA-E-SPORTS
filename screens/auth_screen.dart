import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme.dart';
import '../widgets/components.dart';

class MobileAuthScreen extends StatefulWidget {
  const MobileAuthScreen({super.key});

  @override
  State<MobileAuthScreen> createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<MobileAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );

        final String uid = credential.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'role': 'user', 
          'gameIds': {},
          'wallet': {
            'balance': 0.0,
            'bonus': 0.0,
            'withdrawable': 0.0,
            'transactions': [],
          },
          'stats': {
            'totalCompletedMatches': 0,
            'top3Wins': 0,
            'losses': 0,
            'totalEarnings': 0.0,
            'totalEntryFees': 0.0,
          }
        });
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Authentication failed.';
      if (e.code == 'user-not-found') message = 'No user found for that email.';
      else if (e.code == 'wrong-password') message = 'Incorrect password.';
      else if (e.code == 'email-already-in-use') message = 'The account already exists for that email.';
      else if (e.code == 'weak-password') message = 'The password provided is too weak.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: EsportsColors.live));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: EsportsColors.live));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsportsColors.bg1,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: EsportsColors.meshBg)),
          const ParticleBackground(count: 20, color: EsportsColors.electricBlue),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: GlassCard(
                  opacity: 0.1,
                  borderColor: EsportsColors.border,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, color: EsportsColors.cyan, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _isSignUp ? 'CREATE ACCOUNT' : 'PLAYER LOGIN',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                      ),
                      const SizedBox(height: 24),
                      if (_isSignUp) ...[
                        TextFormField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: Colors.white),
                          validator: (v) => v!.trim().isEmpty ? 'Enter your name' : null,
                          decoration: const InputDecoration(labelText: 'Gamer Tag / Name', filled: true, fillColor: EsportsColors.bg1),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => v!.trim().isEmpty ? 'Enter an email' : null,
                        decoration: const InputDecoration(labelText: 'Email Address', filled: true, fillColor: EsportsColors.bg1),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => v!.isEmpty ? 'Enter a password' : null,
                        decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: EsportsColors.bg1),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: NeonButton(
                          label: _isSignUp ? 'SIGN UP' : 'SIGN IN',
                          color: EsportsColors.electricBlue,
                          isLoading: _isLoading,
                          onPressed: _authenticate,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => setState(() => _isSignUp = !_isSignUp),
                        child: Text(
                          _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up",
                          style: const TextStyle(color: EsportsColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}