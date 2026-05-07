// ============================================================
// CenterLoginScreen.dart — Production-Level Login Screen
// Fixes: duplicate nav, infinite loader, context-after-await,
//        Firebase hang, fallback local auth, mounted guards
// ============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ⚠️ Update import path to match your project structure
import 'dashboard_screen.dart';

class CenterLoginScreen extends StatefulWidget {
  const CenterLoginScreen({super.key});

  @override
  State<CenterLoginScreen> createState() => _CenterLoginScreenState();
}

class _CenterLoginScreenState extends State<CenterLoginScreen> {
  // ─── Controllers ────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _centerCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  // ─── State ──────────────────────────────────────────────────
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // ─── Credentials (move to backend/env in production) ────────
  static const Map<String, String> _credentials = {
    'KYP09060019': 'center@123',
    'KYP09060044': 'center@456',
    'KYP09060060': 'center@789',
    'KYP09060002': 'center@101',
  };

  static const Map<String, String> _roles = {
    'KYP09060019': 'Center Admin',
    'KYP09060044': 'Center Admin',
    'KYP09060060': 'Center Admin',
    'KYP09060002': 'Center Admin',
  };

  @override
  void dispose() {
    _centerCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────
  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _errorMessage = msg;
      _isLoading = false;
    });
  }

  void _setLoading(bool val) {
    if (!mounted) return;
    setState(() => _isLoading = val);
  }

  // ─── Main Login Flow ─────────────────────────────────────────
  Future<void> _login() async {
    // 1. Validate form
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);
    setState(() => _errorMessage = null);

    final centerCode = _centerCodeController.text.trim().toUpperCase();
    final password = _passwordController.text.trim();

    // ── STAGE 1: Local credential check ─────────────────────────
    debugPrint('[LOGIN] Stage 1: Checking local credentials');
    if (!_credentials.containsKey(centerCode)) {
      return _setError('Invalid Center Code. Please check and try again.');
    }
    if (_credentials[centerCode] != password) {
      return _setError('Incorrect password. Please try again.');
    }
    debugPrint('[LOGIN] Stage 1: ✅ Credentials valid');

    final role = _roles[centerCode] ?? 'Center Admin';

    // ── STAGE 2: Firebase Auth (with timeout + fallback) ─────────
    debugPrint('[LOGIN] Stage 2: Firebase Auth');
    try {
      await _firebaseAuth(centerCode, password)
          .timeout(const Duration(seconds: 8));
      debugPrint('[LOGIN] Stage 2: ✅ Firebase auth done');
    } catch (e) {
      // Non-blocking: log and continue
      debugPrint('[LOGIN] Stage 2: ⚠️ Firebase auth skipped — $e');
    }

    // Check mounted after every await
    if (!mounted) return;

    // ── STAGE 3: Firestore session write (with timeout + fallback) ─
    debugPrint('[LOGIN] Stage 3: Firestore write');
    try {
      await _firestoreWrite(centerCode, role)
          .timeout(const Duration(seconds: 8));
      debugPrint('[LOGIN] Stage 3: ✅ Firestore write done');
    } catch (e) {
      debugPrint('[LOGIN] Stage 3: ⚠️ Firestore write skipped — $e');
    }

    if (!mounted) return;

    // ── STAGE 4: SharedPreferences session ───────────────────────
    debugPrint('[LOGIN] Stage 4: Saving session');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('centerCode', centerCode);
      await prefs.setString('userRole', role);
      debugPrint('[LOGIN] Stage 4: ✅ Session saved');
    } catch (e) {
      debugPrint('[LOGIN] Stage 4: ⚠️ Session save failed — $e');
      // Non-blocking: continue
    }

    if (!mounted) return;

    // ── STAGE 5: Navigate to Dashboard ───────────────────────────
    debugPrint('[LOGIN] Stage 5: Navigating to Dashboard');
    _setLoading(false); // Stop spinner BEFORE navigation

    // Single, safe navigation — pushAndRemoveUntil clears back stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(centerCode: centerCode),
      ),
      (route) => false,
    );
    debugPrint('[LOGIN] Stage 5: ✅ Navigation triggered');
  }

  // ── Firebase Auth helper ─────────────────────────────────────
  Future<void> _firebaseAuth(String centerCode, String password) async {
    final auth = FirebaseAuth.instance;
    final email = '$centerCode@kypcenter.com';
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await auth.createUserWithEmailAndPassword(
            email: email, password: password);
      } else {
        rethrow;
      }
    }
  }

  // ── Firestore write helper ───────────────────────────────────
  Future<void> _firestoreWrite(String centerCode, String role) async {
    await FirebaseFirestore.instance
        .collection('centers')
        .doc(centerCode)
        .set({
      'centerCode': centerCode,
      'role': role,
      'lastLogin': FieldValue.serverTimestamp(),
      'status': 'active',
    }, SetOptions(merge: true));
  }

  // ─── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 12,
                shadowColor: const Color(0xFF1E3A8A).withOpacity(0.18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(36),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Logo ──────────────────────────────────
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'KYP Center Portal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Multi-Center Management System',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // ── Center Code ───────────────────────────
                        TextFormField(
                          controller: _centerCodeController,
                          enabled: !_isLoading,
                          textCapitalization: TextCapitalization.characters,
                          decoration: _inputDecoration(
                            label: 'Center Code',
                            hint: 'e.g. KYP09060019',
                            icon: Icons.business_center_rounded,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your center code';
                            }
                            final code = v.trim().toUpperCase();
                            if (!code.startsWith('KYP')) {
                              return 'Code must start with KYP';
                            }
                            if (code.length < 10) {
                              return 'Invalid center code format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Password ──────────────────────────────
                        TextFormField(
                          controller: _passwordController,
                          enabled: !_isLoading,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: Colors.grey.shade500,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter password';
                            if (v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        // ── Error Banner ──────────────────────────
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _ErrorBanner(message: _errorMessage!),
                        ],

                        const SizedBox(height: 28),

                        // ── Login Button ──────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF1E3A8A).withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const _LoadingRow()
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Demo Credentials ──────────────────────
                        _DemoCredentialsPanel(credentials: _credentials),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Color(0xFF1E3A8A), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        SizedBox(width: 12),
        Text('Signing in...', style: TextStyle(fontSize: 15)),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Colors.red.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCredentialsPanel extends StatelessWidget {
  final Map<String, String> credentials;
  const _DemoCredentialsPanel({required this.credentials});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Demo Credentials',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...credentials.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: Colors.blue.shade400),
                    const SizedBox(width: 8),
                    Text(
                      '${e.key}  /  ${e.value}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.blue.shade800,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}