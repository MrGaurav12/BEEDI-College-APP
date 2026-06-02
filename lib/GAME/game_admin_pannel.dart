// =============================================================================
// BEEDI GAME ADMIN PANEL - PRODUCTION GRADE v2.0
// File: lib/game/admin/game_admin_panel.dart
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:beedi_college/GAME/beedi_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// =============================================================================
// CONFIGURATION
// =============================================================================
class AdminConfig {
  static const String adminRole = 'super_admin';
  static const String adminCollection = 'admin_users';
  static const Duration sessionTimeout = Duration(hours: 2);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const int pageSize = 25;
}

// =============================================================================
// COLOR SYSTEM
// =============================================================================
class AppColors {
  static const Color bg1 = Color(0xFF050A14);
  static const Color bg2 = Color(0xFF0A1628);
  static const Color bg3 = Color(0xFF0F2040);
  static const Color sidebar = Color(0xFF071120);

  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPurple = Color(0xFFB44FFF);
  static const Color neonGold = Color(0xFFFFD700);
  static const Color neonRed = Color(0xFFFF0044);
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonPink = Color(0xFFFF0080);

  static const Color txtPrimary = Color(0xFFE8F4FF);
  static const Color txtSecondary = Color(0xFF8AACCC);
  static const Color error = Color(0xFFFF4444);
  static const Color success = Color(0xFF44FF44);
  static const Color warning = Color(0xFFFFAA44);
}

// =============================================================================
// TYPOGRAPHY SYSTEM
// =============================================================================
class AppTypography {
  static TextStyle orbitron({
    double size = 14,
    Color color = AppColors.txtPrimary,
    FontWeight weight = FontWeight.bold,
  }) => GoogleFonts.orbitron(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: 0.5,
  );

  static TextStyle rajdhani({
    double size = 14,
    Color color = AppColors.txtPrimary,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.rajdhani(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: 0.3,
  );

  static TextStyle mono({
    double size = 13,
    Color color = AppColors.neonGreen,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.shareTechMono(
    fontSize: size,
    color: color,
    fontWeight: weight,
  );
}

// =============================================================================
// ADMIN AUTH SERVICE
// =============================================================================
class AdminAuthService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final _prefs = SharedPreferences.getInstance();
  static String? _currentAdminId;
  static DateTime? _sessionStart;

  static Future<bool> authenticate(String adminId, String pin) async {
    try {
      final doc = await _db
          .collection(AdminConfig.adminCollection)
          .doc(adminId)
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final hashedPin = data['pinHash'];
      final isValid = _verifyPin(pin, hashedPin);

      if (isValid && data['role'] == AdminConfig.adminRole) {
        _currentAdminId = adminId;
        _sessionStart = DateTime.now();
        await _saveSession(adminId);
        await _logAdminAction('login', 'Admin logged in');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Auth error: $e');
      return false;
    }
  }

  static Future<bool> checkSession() async {
    if (_currentAdminId != null && _sessionStart != null) {
      if (DateTime.now().difference(_sessionStart!) <
          AdminConfig.sessionTimeout) {
        return true;
      }
    }

    final prefs = await _prefs;
    final savedAdminId = prefs.getString('admin_id');
    final savedSessionTime = prefs.getInt('admin_session_time');

    if (savedAdminId != null && savedSessionTime != null) {
      final sessionTime = DateTime.fromMillisecondsSinceEpoch(savedSessionTime);
      if (DateTime.now().difference(sessionTime) < AdminConfig.sessionTimeout) {
        _currentAdminId = savedAdminId;
        _sessionStart = sessionTime;
        return true;
      }
    }

    return false;
  }

  static Future<void> logout() async {
    await _logAdminAction('logout', 'Admin logged out');
    _currentAdminId = null;
    _sessionStart = null;
    final prefs = await _prefs;
    await prefs.remove('admin_id');
    await prefs.remove('admin_session_time');
  }

  static Future<void> _saveSession(String adminId) async {
    final prefs = await _prefs;
    await prefs.setString('admin_id', adminId);
    await prefs.setInt(
      'admin_session_time',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static bool _verifyPin(String input, String hash) {
    // In production, use proper hashing (bcrypt, PBKDF2)
    return input ==
        'admin2026'; // Placeholder - implement proper hash verification
  }

  static Future<void> _logAdminAction(String action, String detail) async {
    try {
      await _db.collection('adminLogs').add({
        'adminId': _currentAdminId,
        'action': action,
        'detail': detail,
        'timestamp': FieldValue.serverTimestamp(),
        'ip': null, // Would be set by backend
      });
    } catch (_) {}
  }
}

// =============================================================================
// FIREBASE SERVICE WITH ERROR HANDLING
// =============================================================================
class AdminFirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final Map<String, Timer?> _refreshTimers = {};
  static int _retryCount = 0;

  // ──────────────────────────────────────────────────────────────────────────
  // USER MANAGEMENT
  // ──────────────────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getUsersStream({
    String? filter,
    String? searchQuery,
  }) {
    Query query = _db.collection('players');

    if (filter == 'online') {
      query = query.where('onlineStatus', isEqualTo: true);
    } else if (filter == 'banned') {
      query = query.where('banned', isEqualTo: true);
    }

    query = query
        .orderBy('createdAt', descending: true)
        .limit(AdminConfig.pageSize);

    return query.snapshots().handleError((error) {
      debugPrint('Stream error: $error');
      return const Stream.empty();
    });
  }

  static Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      final doc = await _db.collection('players').doc(userId).get();
      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching user: $e');
      throw Exception('Failed to fetch user details');
    }
  }

  static Future<void> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection('players').doc(userId).update(data);
      await _logAdminAction(
        userId,
        'update_user',
        'Updated fields: ${data.keys.join(', ')}',
      );
    } catch (e) {
      debugPrint('Update error: $e');
      throw Exception('Failed to update user');
    }
  }

  static Future<void> banUser(String userId, String reason) async {
    final batch = _db.batch();
    final userRef = _db.collection('players').doc(userId);

    batch.update(userRef, {
      'banned': true,
      'bannedReason': reason,
      'bannedAt': FieldValue.serverTimestamp(),
      'onlineStatus': false,
    });

    await batch.commit();
    await _logAdminAction(userId, 'ban_user', 'Reason: $reason');
  }

  static Future<void> unbanUser(String userId) async {
    await _db.collection('players').doc(userId).update({
      'banned': false,
      'bannedReason': null,
      'unbannedAt': FieldValue.serverTimestamp(),
    });
    await _logAdminAction(userId, 'unban_user', 'User unbanned');
  }

  static Future<void> modifyCoins(
    String userId,
    int amount,
    String reason,
  ) async {
    final docRef = _db.collection('players').doc(userId);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) throw Exception('User not found');

      final currentCoins = (doc.data()?['coins'] ?? 0) as int;
      final newCoins = currentCoins + amount;

      if (newCoins < 0) throw Exception('Insufficient coins');

      transaction.update(docRef, {'coins': newCoins});
    });

    await _logAdminAction(
      userId,
      'modify_coins',
      '$reason: ${amount > 0 ? "+$amount" : amount}',
    );
  }

  static Future<void> deleteUserAccount(String userId) async {
    final batch = _db.batch();

    // Delete user data from all collections
    batch.delete(_db.collection('players').doc(userId));
    batch.delete(_db.collection('leaderboard').doc(userId));
    batch.delete(_db.collection('inventory').doc(userId));

    // Delete all scores
    final scores = await _db
        .collection('scores')
        .where('playerId', isEqualTo: userId)
        .get();
    for (final doc in scores.docs) {
      batch.delete(doc.reference);
    }

    // Delete all transactions
    final transactions = await _db
        .collection('transactions')
        .where('playerId', isEqualTo: userId)
        .get();
    for (final doc in transactions.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    await _logAdminAction(
      userId,
      'delete_account',
      'Account permanently deleted',
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DASHBOARD STATS
  // ──────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final results = await Future.wait([
        _db.collection('players').count().get(),
        _db
            .collection('players')
            .where('onlineStatus', isEqualTo: true)
            .count()
            .get(),
        _db
            .collection('players')
            .where('banned', isEqualTo: true)
            .count()
            .get(),
        _db.collection('scores').count().get(),
        _db.collection('transactions').count().get(),
        _db
            .collection('players')
            .where(
              'createdAt',
              isGreaterThan: DateTime.now().subtract(const Duration(days: 7)),
            )
            .count()
            .get(),
      ]);

      return {
        'totalPlayers': results[0].count ?? 0,
        'onlinePlayers': results[1].count ?? 0,
        'bannedPlayers': results[2].count ?? 0,
        'totalGames': results[3].count ?? 0,
        'totalTransactions': results[4].count ?? 0,
        'newPlayersWeek': results[5].count ?? 0,
      };
    } catch (e) {
      debugPrint('Stats error: $e');
      return {
        'totalPlayers': 0,
        'onlinePlayers': 0,
        'bannedPlayers': 0,
        'totalGames': 0,
        'totalTransactions': 0,
        'newPlayersWeek': 0,
      };
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LEADERBOARD MANAGEMENT
  // ──────────────────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getLeaderboardStream() {
    return _db
        .collection('leaderboard')
        .orderBy('xp', descending: true)
        .limit(100)
        .snapshots()
        .handleError((error) {
          debugPrint('Leaderboard error: $error');
          return const Stream.empty();
        });
  }

  static Future<void> resetLeaderboard() async {
    final batch = _db.batch();
    final snapshot = await _db.collection('leaderboard').limit(500).get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'xp': 0,
        'level': 1,
        'wins': 0,
        'streak': 0,
      });
    }

    await batch.commit();
    await _logAdminAction('system', 'reset_leaderboard', 'Leaderboard reset');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // GAME SCORES
  // ──────────────────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getScoresStream() {
    return _db
        .collection('scores')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .handleError((error) {
          debugPrint('Scores error: $error');
          return const Stream.empty();
        });
  }

  static Future<void> deleteScore(String scoreId) async {
    await _db.collection('scores').doc(scoreId).delete();
    await _logAdminAction('system', 'delete_score', 'Deleted score entry');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // MARKETPLACE
  // ──────────────────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getMarketplaceItemsStream() {
    return _db
        .collection('marketplace')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          debugPrint('Marketplace error: $error');
          return const Stream.empty();
        });
  }

  static Future<void> addMarketplaceItem(Map<String, dynamic> item) async {
    await _db.collection('marketplace').add({
      ...item,
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
      'salesCount': 0,
    });
    await _logAdminAction(
      'system',
      'add_marketplace_item',
      'Item: ${item['name']}',
    );
  }

  static Future<void> updateMarketplaceItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    await _db.collection('marketplace').doc(itemId).update(updates);
    await _logAdminAction(
      'system',
      'update_marketplace_item',
      'Updated item: $itemId',
    );
  }

  static Future<void> deleteMarketplaceItem(String itemId) async {
    await _db.collection('marketplace').doc(itemId).delete();
    await _logAdminAction(
      'system',
      'delete_marketplace_item',
      'Deleted item: $itemId',
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ANNOUNCEMENTS
  // ──────────────────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getAnnouncementsStream() {
    return _db
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .handleError((error) {
          debugPrint('Announcements error: $error');
          return const Stream.empty();
        });
  }

  static Future<void> createAnnouncement({
    required String title,
    required String message,
    required String type,
    String? priority,
  }) async {
    await _db.collection('announcements').add({
      'title': title,
      'message': message,
      'type': type,
      'priority': priority ?? 'normal',
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': await _getCurrentAdminId(),
    });
    await _logAdminAction('system', 'create_announcement', 'Title: $title');
  }

  static Future<void> deleteAnnouncement(String announcementId) async {
    await _db.collection('announcements').doc(announcementId).delete();
    await _logAdminAction(
      'system',
      'delete_announcement',
      'Deleted announcement',
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TRANSACTIONS
  // ──────────────────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getTransactionsStream() {
    return _db
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(200)
        .snapshots()
        .handleError((error) {
          debugPrint('Transactions error: $error');
          return const Stream.empty();
        });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ACTIVITY LOGS
  // ──────────────────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getActivityLogsStream() {
    return _db
        .collection('activityLogs')
        .orderBy('timestamp', descending: true)
        .limit(200)
        .snapshots()
        .handleError((error) {
          debugPrint('Activity logs error: $error');
          return const Stream.empty();
        });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // APP SETTINGS
  // ──────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final doc = await _db.collection('appSettings').doc('config').get();
      if (doc.exists) {
        return doc.data() ?? {};
      }
      return _getDefaultSettings();
    } catch (e) {
      debugPrint('Settings error: $e');
      return _getDefaultSettings();
    }
  }

  static Future<void> updateAppSettings(Map<String, dynamic> settings) async {
    await _db.collection('appSettings').doc('config').set({
      ...settings,
      'lastUpdated': FieldValue.serverTimestamp(),
      'updatedBy': await _getCurrentAdminId(),
    }, SetOptions(merge: true));
    await _logAdminAction('system', 'update_settings', 'Settings updated');
  }

  static Map<String, dynamic> _getDefaultSettings() {
    return {
      'maintenanceMode': false,
      'registrationEnabled': true,
      'dailyRewardEnabled': true,
      'pvpEnabled': true,
      'marketplaceEnabled': true,
      'leaderboardEnabled': true,
      'appVersion': '2.0.0',
      'minAppVersion': '1.0.0',
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // UTILITIES
  // ──────────────────────────────────────────────────────────────────────────

  static Future<String> _getCurrentAdminId() async {
    // Implementation to get current admin ID
    return 'admin';
  }

  static Future<void> _logAdminAction(
    String target,
    String action,
    String detail,
  ) async {
    try {
      await _db.collection('adminActions').add({
        'adminId': await _getCurrentAdminId(),
        'target': target,
        'action': action,
        'detail': detail,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}

// =============================================================================
// SPLASH SCREEN
// =============================================================================
class AdminSplashScreen extends StatefulWidget {
  const AdminSplashScreen({super.key});

  @override
  State<AdminSplashScreen> createState() => _AdminSplashScreenState();
}

class _AdminSplashScreenState extends State<AdminSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    // Navigate after splash
    Future.delayed(const Duration(milliseconds: 2000), () {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final isLoggedIn = await AdminAuthService.checkSession();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isLoggedIn ? const GameAdminPanel() : const AdminLoginScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.neonBlue, AppColors.neonPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonBlue.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('⚡', style: TextStyle(fontSize: 50)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'BEEDI ADMIN',
                      style: AppTypography.orbitron(
                        size: 24,
                        color: AppColors.neonBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Command Center v2.0',
                      style: AppTypography.rajdhani(
                        size: 14,
                        color: AppColors.txtSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.neonBlue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// ADMIN LOGIN SCREEN
// =============================================================================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final _adminIdController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _matrixController;

  @override
  void initState() {
    super.initState();
    _matrixController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _adminIdController.dispose();
    _pinController.dispose();
    _matrixController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AdminAuthService.authenticate(
        _adminIdController.text.trim(),
        _pinController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GameAdminPanel()),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid credentials. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication error. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: Stack(
        children: [
          // Animated matrix background
          AnimatedBuilder(
            animation: _matrixController,
            builder: (context, child) {
              return CustomPaint(
                painter: MatrixBackgroundPainter(_matrixController.value),
                size: Size.infinite,
              );
            },
          ),

          // Login form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.neonBlue,
                                AppColors.neonPurple,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonBlue.withOpacity(0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('⚡', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'ADMIN ACCESS',
                          style: AppTypography.orbitron(
                            size: 20,
                            color: AppColors.neonBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your credentials to continue',
                          style: AppTypography.rajdhani(
                            size: 14,
                            color: AppColors.txtSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Error message
                        if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTypography.rajdhani(
                                      size: 12,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Admin ID field
                        _buildTextField(
                          controller: _adminIdController,
                          label: 'ADMIN ID',
                          icon: Icons.badge_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Admin ID is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // PIN field
                        _buildTextField(
                          controller: _pinController,
                          label: 'ACCESS PIN',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'PIN is required';
                            }
                            if (value.length < 6) {
                              return 'PIN must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login button
                        GestureDetector(
                          onTap: _isLoading ? null : _handleLogin,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.neonBlue,
                                  AppColors.neonPurple,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonBlue.withOpacity(0.3),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'AUTHENTICATE',
                                      style: AppTypography.orbitron(
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: AppTypography.rajdhani(size: 14, color: AppColors.txtPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.mono(size: 12, color: AppColors.neonBlue),
        prefixIcon: Icon(icon, color: AppColors.neonBlue, size: 20),
        filled: true,
        fillColor: AppColors.bg2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.neonBlue.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neonBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: validator,
    );
  }
}

// =============================================================================
// MATRIX BACKGROUND PAINTER
// =============================================================================
class MatrixBackgroundPainter extends CustomPainter {
  final double progress;
  final Random _random = Random(42);
  final List<String> _chars = [
    '0',
    '1',
    '⚡',
    'B',
    'E',
    'D',
    'I',
    'K',
    'Y',
    'P',
  ];

  MatrixBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 50; i++) {
      final x = _random.nextDouble() * size.width;
      final y = ((progress * size.height + i * 30) % size.height);
      final char = _chars[_random.nextInt(_chars.length)];

      final textPainter = TextPainter(
        text: TextSpan(
          text: char,
          style: GoogleFonts.shareTechMono(
            fontSize: 12,
            color: AppColors.neonGreen.withOpacity(0.08),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(MatrixBackgroundPainter oldDelegate) => true;
}

// =============================================================================
// MAIN ADMIN PANEL
// =============================================================================
class GameAdminPanel extends StatefulWidget {
  const GameAdminPanel({super.key});

  @override
  State<GameAdminPanel> createState() => _GameAdminPanelState();
}

class _GameAdminPanelState extends State<GameAdminPanel>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final List<NavigationItem> _navItems = [
    NavigationItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    NavigationItem(icon: Icons.people_outline, label: 'Users'),
    NavigationItem(icon: Icons.videogame_asset_outlined, label: 'Games'),
    NavigationItem(icon: Icons.leaderboard_outlined, label: 'Leaderboard'),
    NavigationItem(icon: Icons.store_outlined, label: 'Marketplace'),
    NavigationItem(icon: Icons.swap_horiz, label: 'Transactions'),
    NavigationItem(icon: Icons.campaign_outlined, label: 'Announcements'),
    NavigationItem(icon: Icons.history, label: 'Activity Logs'),
    NavigationItem(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg1,
      drawer: isDesktop ? null : _buildDrawer(),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(isDesktop),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: const [
                      DashboardSection(),
                      UsersSection(),
                      GamesSection(),
                      LeaderboardSection(),
                      MarketplaceSection(),
                      TransactionsSection(),
                      AnnouncementsSection(),
                      ActivityLogsSection(),
                      SettingsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isSidebarExpanded ? 260 : 80,
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        border: Border(
          right: BorderSide(color: AppColors.neonBlue.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          // Logo section
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: _isSidebarExpanded ? 20 : 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.neonBlue, AppColors.neonPurple],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonBlue.withOpacity(
                              _glowAnimation.value,
                            ),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('⚡', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    if (_isSidebarExpanded) ...[
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BEEDI',
                            style: AppTypography.orbitron(
                              size: 14,
                              color: AppColors.neonBlue,
                            ),
                          ),
                          Text(
                            'ADMIN PANEL',
                            style: AppTypography.rajdhani(
                              size: 10,
                              color: AppColors.txtSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          const Divider(color: AppColors.bg3, height: 1),
          const SizedBox(height: 16),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                final item = _navItems[index];

                return _buildNavItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  isExpanded: _isSidebarExpanded,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),

          // Expand/collapse button
          const Divider(color: AppColors.bg3, height: 1),
          _buildNavItem(
            icon: _isSidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
            label: _isSidebarExpanded ? 'Collapse' : 'Expand',
            isSelected: false,
            isExpanded: _isSidebarExpanded,
            onTap: () =>
                setState(() => _isSidebarExpanded = !_isSidebarExpanded),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: isExpanded ? 12 : 14,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.neonBlue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: AppColors.neonBlue.withOpacity(0.3))
                  : null,
            ),
            child: isExpanded
                ? Row(
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? AppColors.neonBlue
                            : AppColors.txtSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTypography.rajdhani(
                            size: 13,
                            color: isSelected
                                ? AppColors.neonBlue
                                : AppColors.txtSecondary,
                            weight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    icon,
                    color: isSelected
                        ? AppColors.neonBlue
                        : AppColors.txtSecondary,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.sidebar,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BEEDI ADMIN',
                      style: AppTypography.orbitron(
                        size: 14,
                        color: AppColors.neonBlue,
                      ),
                    ),
                    Text(
                      'Command Center',
                      style: AppTypography.rajdhani(
                        size: 10,
                        color: AppColors.txtSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.bg3, height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                final item = _navItems[index];

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected
                        ? AppColors.neonBlue
                        : AppColors.txtSecondary,
                  ),
                  title: Text(
                    item.label,
                    style: AppTypography.rajdhani(
                      size: 13,
                      color: isSelected
                          ? AppColors.neonBlue
                          : AppColors.txtSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppColors.neonBlue.withOpacity(0.1),
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const Divider(color: AppColors.bg3, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.neonRed),
            title: Text(
              'Logout',
              style: AppTypography.rajdhani(size: 13, color: AppColors.neonRed),
            ),
            onTap: _handleLogout,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDesktop) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border(
          bottom: BorderSide(color: AppColors.neonBlue.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.txtSecondary),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          Text(
            _navItems[_selectedIndex].label,
            style: AppTypography.orbitron(size: 14, color: AppColors.neonBlue),
          ),
          const Spacer(),
          // Time display
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              final now = DateTime.now();
              return Text(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
                style: AppTypography.mono(size: 12, color: AppColors.neonGreen),
              );
            },
          ),
          const SizedBox(width: 16),
          // Admin badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neonGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neonGold.withOpacity(0.3)),
            ),
            child: Text(
              'ADMIN',
              style: AppTypography.orbitron(size: 9, color: AppColors.neonGold),
            ),
          ),
          const SizedBox(width: 12),
          // Logout button
          GestureDetector(
            onTap: _handleLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neonRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neonRed.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.logout, color: AppColors.neonRed, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'LOGOUT',
                    style: AppTypography.orbitron(
                      size: 9,
                      color: AppColors.neonRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Logout',
          style: AppTypography.orbitron(color: AppColors.neonRed),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTypography.rajdhani(color: AppColors.txtPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.rajdhani(color: AppColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: AppTypography.orbitron(color: AppColors.neonRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AdminAuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminSplashScreen()),
          (route) => false,
        );
      }
    }
  }
}

// =============================================================================
// NAVIGATION ITEM MODEL
// =============================================================================
class NavigationItem {
  final IconData icon;
  final String label;

  const NavigationItem({required this.icon, required this.label});
}

// =============================================================================
// DASHBOARD SECTION
// =============================================================================
class DashboardSection extends StatefulWidget {
  const DashboardSection({super.key});

  @override
  State<DashboardSection> createState() => _DashboardSectionState();
}

class _DashboardSectionState extends State<DashboardSection> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  final List<double> _weeklyStats = [120, 145, 132, 168, 189, 210, 245];
  final List<double> _gameStats = [45, 52, 48, 61, 73, 68, 89];
  final List<double> _coinStats = [1250, 1890, 2100, 2450, 2780, 3100, 3450];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await AdminFirestoreService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200
        ? 4
        : screenWidth > 800
        ? 3
        : 2;

    return RefreshIndicator(
      onRefresh: _loadStats,
      color: AppColors.neonBlue,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats grid
            if (_isLoading)
              _buildSkeletonGrid(crossAxisCount)
            else
              GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _StatCard(
                    title: 'Total Players',
                    value: '${_stats['totalPlayers'] ?? 0}',
                    icon: Icons.people,
                    color: AppColors.neonBlue,
                    subtitle: '+${_stats['newPlayersWeek'] ?? 0} this week',
                  ),
                  _StatCard(
                    title: 'Online Now',
                    value: '${_stats['onlinePlayers'] ?? 0}',
                    icon: Icons.wifi,
                    color: AppColors.neonGreen,
                    subtitle: 'Active sessions',
                  ),
                  _StatCard(
                    title: 'Banned Users',
                    value: '${_stats['bannedPlayers'] ?? 0}',
                    icon: Icons.block,
                    color: AppColors.neonRed,
                    subtitle: 'Suspended accounts',
                  ),
                  _StatCard(
                    title: 'Total Games',
                    value: '${_stats['totalGames'] ?? 0}',
                    icon: Icons.videogame_asset,
                    color: AppColors.neonPurple,
                    subtitle: 'Game plays',
                  ),
                  _StatCard(
                    title: 'Transactions',
                    value: '${_stats['totalTransactions'] ?? 0}',
                    icon: Icons.swap_horiz,
                    color: AppColors.neonGold,
                    subtitle: 'Total transactions',
                  ),
                  _StatCard(
                    title: 'Conversion Rate',
                    value:
                        '${_stats['totalPlayers'] != null && _stats['totalPlayers'] > 0 ? ((_stats['onlinePlayers'] ?? 0) * 100 / (_stats['totalPlayers'] ?? 1)).toStringAsFixed(1) : '0'}%',
                    icon: Icons.trending_up,
                    color: AppColors.neonCyan,
                    subtitle: 'Active ratio',
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Charts
            if (screenWidth > 800)
              Row(
                children: [
                  Expanded(
                    child: _ChartCard(
                      title: 'User Growth',
                      data: _weeklyStats,
                      color: AppColors.neonBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ChartCard(
                      title: 'Game Activity',
                      data: _gameStats,
                      color: AppColors.neonPurple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ChartCard(
                      title: 'Coin Flow',
                      data: _coinStats,
                      color: AppColors.neonGold,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _ChartCard(
                    title: 'User Growth',
                    data: _weeklyStats,
                    color: AppColors.neonBlue,
                  ),
                  const SizedBox(height: 16),
                  _ChartCard(
                    title: 'Game Activity',
                    data: _gameStats,
                    color: AppColors.neonPurple,
                  ),
                  const SizedBox(height: 16),
                  _ChartCard(
                    title: 'Coin Flow',
                    data: _coinStats,
                    color: AppColors.neonGold,
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Recent activity
            _SectionHeader(title: 'RECENT ACTIVITY', color: AppColors.neonCyan),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: AdminFirestoreService.getActivityLogsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _SkeletonLoader(height: 200);
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return _EmptyState(
                    icon: Icons.history,
                    message: 'No recent activity',
                  );
                }

                return _GlassCard(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.take(10).length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.bg3, height: 1),
                    itemBuilder: (_, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final timestamp = (data['timestamp'] as Timestamp?)
                          ?.toDate();

                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getActionColor(
                              data['action'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getActionIcon(data['action']),
                            size: 16,
                            color: _getActionColor(data['action']),
                          ),
                        ),
                        title: Text(
                          data['detail'] ?? 'Unknown action',
                          style: AppTypography.rajdhani(
                            size: 12,
                            color: AppColors.txtPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          data['target'] ?? '',
                          style: AppTypography.mono(
                            size: 10,
                            color: AppColors.txtSecondary,
                          ),
                        ),
                        trailing: Text(
                          timestamp != null
                              ? '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
                              : '--:--',
                          style: AppTypography.mono(
                            size: 10,
                            color: AppColors.txtSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid(int crossAxisCount) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: List.generate(6, (_) => const _SkeletonLoader(height: 120)),
    );
  }

  Color _getActionColor(String? action) {
    switch (action) {
      case 'ban_user':
        return AppColors.neonRed;
      case 'unban_user':
        return AppColors.neonGreen;
      case 'modify_coins':
        return AppColors.neonGold;
      case 'delete_account':
        return AppColors.error;
      default:
        return AppColors.neonBlue;
    }
  }

  IconData _getActionIcon(String? action) {
    switch (action) {
      case 'ban_user':
        return Icons.block;
      case 'unban_user':
        return Icons.lock_open;
      case 'modify_coins':
        return Icons.monetization_on;
      case 'delete_account':
        return Icons.delete;
      default:
        return Icons.notifications;
    }
  }
}

// =============================================================================
// STAT CARD WIDGET
// =============================================================================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.6), blurRadius: 6),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTypography.orbitron(size: 28, color: color)),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.rajdhani(
              size: 12,
              color: AppColors.txtSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.mono(size: 9, color: color.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CHART CARD
// =============================================================================
class _ChartCard extends StatelessWidget {
  final String title;
  final List<double> data;
  final Color color;

  const _ChartCard({
    required this.title,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.orbitron(size: 12, color: color)),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: _LineChartPainter(data: data, color: color),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${data.reduce((a, b) => a < b ? a : b).toInt()}',
                style: AppTypography.mono(
                  size: 9,
                  color: AppColors.txtSecondary,
                ),
              ),
              Text(
                'Max: ${data.reduce((a, b) => a > b ? a : b).toInt()}',
                style: AppTypography.mono(size: 9, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// LINE CHART PAINTER
// =============================================================================
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return;

    final points = <Offset>[];
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue) * size.height;
      points.add(Offset(x, y));
    }

    // Draw line
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =============================================================================
// USERS SECTION
// =============================================================================
class UsersSection extends StatefulWidget {
  const UsersSection({super.key});

  @override
  State<UsersSection> createState() => _UsersSectionState();
}

class _UsersSectionState extends State<UsersSection> {
  String _searchQuery = '';
  String _filter = 'all';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _users = [];
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _lastDocument == null) return;

    setState(() => _isLoadingMore = true);

    try {
      // Pagination implementation
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _isLoadingMore = false);
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.bg2,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: AppTypography.rajdhani(
                    size: 13,
                    color: AppColors.txtPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, or email...',
                    hintStyle: AppTypography.rajdhani(
                      size: 12,
                      color: AppColors.txtSecondary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.neonBlue,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.bg3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _FilterChip(
                label: 'All',
                isSelected: _filter == 'all',
                onTap: () => setState(() => _filter = 'all'),
              ),
              _FilterChip(
                label: 'Online',
                isSelected: _filter == 'online',
                onTap: () => setState(() => _filter = 'online'),
              ),
              _FilterChip(
                label: 'Banned',
                isSelected: _filter == 'banned',
                onTap: () => setState(() => _filter = 'banned'),
              ),
            ],
          ),
        ),

        // Users list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: AdminFirestoreService.getUsersStream(
              filter: _filter != 'all' ? _filter : null,
              searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.neonBlue),
                );
              }

              if (snapshot.hasError) {
                return _ErrorState(
                  message: 'Failed to load users',
                  onRetry: () => setState(() {}),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              final filteredDocs = _searchQuery.isEmpty
                  ? docs
                  : docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nickname = (data['nickname'] ?? '')
                          .toString()
                          .toLowerCase();
                      final playerId = (data['playerId'] ?? '')
                          .toString()
                          .toLowerCase();
                      return nickname.contains(_searchQuery) ||
                          playerId.contains(_searchQuery);
                    }).toList();

              if (filteredDocs.isEmpty) {
                return _EmptyState(
                  icon: Icons.people_outline,
                  message: 'No users found',
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: filteredDocs.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == filteredDocs.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final doc = filteredDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _UserCard(
                    userId: doc.id,
                    data: data,
                    onUpdate: () => setState(() {}),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// FILTER CHIP
// =============================================================================
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonBlue.withOpacity(0.2)
              : AppColors.bg3,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.neonBlue
                : AppColors.neonBlue.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.rajdhani(
            size: 12,
            color: isSelected ? AppColors.neonBlue : AppColors.txtSecondary,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// USER CARD
// =============================================================================
class _UserCard extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> data;
  final VoidCallback onUpdate;

  const _UserCard({
    required this.userId,
    required this.data,
    required this.onUpdate,
  });

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isBanned = widget.data['banned'] == true;
    final isOnline = widget.data['onlineStatus'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _GlassCard(
        borderColor: isBanned
            ? AppColors.neonRed
            : (isOnline ? AppColors.neonGreen : AppColors.neonBlue),
        child: Column(
          children: [
            // Main row
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.neonBlue, AppColors.neonPurple],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.data['avatar'] ?? '👤',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data['nickname'] ?? 'Unknown',
                            style: AppTypography.orbitron(
                              size: 14,
                              color: AppColors.txtPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.data['playerId'] ?? '',
                            style: AppTypography.mono(
                              size: 10,
                              color: AppColors.txtSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _UserBadge(
                                text: 'LVL ${widget.data['level'] ?? 1}',
                                color: AppColors.neonPurple,
                              ),
                              _UserBadge(
                                text: '💰 ${widget.data['coins'] ?? 0}',
                                color: AppColors.neonGold,
                              ),
                              _UserBadge(
                                text: '🏆 ${widget.data['totalWins'] ?? 0}',
                                color: AppColors.neonGreen,
                              ),
                              if (isOnline)
                                _UserBadge(
                                  text: 'ONLINE',
                                  color: AppColors.neonGreen,
                                  filled: true,
                                ),
                              if (isBanned)
                                _UserBadge(
                                  text: 'BANNED',
                                  color: AppColors.neonRed,
                                  filled: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    Column(
                      children: [
                        _ActionIconButton(
                          icon: Icons.edit,
                          color: AppColors.neonBlue,
                          onTap: () => _showUserDetails(),
                        ),
                        const SizedBox(height: 8),
                        _ActionIconButton(
                          icon: isBanned ? Icons.lock_open : Icons.block,
                          color: isBanned
                              ? AppColors.neonGreen
                              : AppColors.neonRed,
                          onTap: () => _toggleBan(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Divider(color: AppColors.bg3),
                    const SizedBox(height: 12),

                    // User details
                    _InfoRow(
                      label: 'Real Name',
                      value: widget.data['realName'] ?? 'Not set',
                    ),
                    _InfoRow(
                      label: 'Email',
                      value: widget.data['email'] ?? 'Not set',
                    ),
                    _InfoRow(
                      label: 'Mobile',
                      value: widget.data['mobileNumber'] ?? 'Not set',
                    ),
                    _InfoRow(label: 'XP', value: '${widget.data['xp'] ?? 0}'),
                    _InfoRow(
                      label: 'Streak',
                      value: '${widget.data['streak'] ?? 0}',
                    ),
                    _InfoRow(
                      label: 'Rank',
                      value: widget.data['rank'] ?? 'Novice',
                    ),

                    const SizedBox(height: 12),

                    // Action buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _AdminActionChip(
                          label: 'Give 100 Coins',
                          icon: Icons.add_circle,
                          color: AppColors.neonGold,
                          onTap: () => _modifyCoins(100),
                        ),
                        _AdminActionChip(
                          label: 'Give 500 Coins',
                          icon: Icons.monetization_on,
                          color: AppColors.neonGold,
                          onTap: () => _modifyCoins(500),
                        ),
                        _AdminActionChip(
                          label: 'Reset Coins',
                          icon: Icons.refresh,
                          color: AppColors.neonOrange,
                          onTap: () => _modifyCoins(-widget.data['coins'] ?? 0),
                        ),
                        _AdminActionChip(
                          label: 'Reset XP',
                          icon: Icons.star_border,
                          color: AppColors.neonPurple,
                          onTap: () => _resetXP(),
                        ),
                        _AdminActionChip(
                          label: 'Delete Account',
                          icon: Icons.delete_forever,
                          color: AppColors.error,
                          onTap: _deleteAccount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserDetailSheet(
        userId: widget.userId,
        data: widget.data,
        onUpdate: widget.onUpdate,
      ),
    );
  }

  Future<void> _toggleBan() async {
    final isBanned = widget.data['banned'] == true;

    if (isBanned) {
      await AdminFirestoreService.unbanUser(widget.userId);
    } else {
      final reason = await _showBanDialog();
      if (reason != null) {
        await AdminFirestoreService.banUser(widget.userId, reason);
      } else {
        return;
      }
    }

    widget.onUpdate();
  }

  Future<String?> _showBanDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Ban User',
          style: AppTypography.orbitron(color: AppColors.neonRed),
        ),
        content: TextField(
          controller: controller,
          style: AppTypography.rajdhani(color: AppColors.txtPrimary),
          decoration: InputDecoration(
            hintText: 'Reason for ban',
            hintStyle: AppTypography.rajdhani(color: AppColors.txtSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.neonBlue.withOpacity(0.3),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.rajdhani(color: AppColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(
              'Ban',
              style: AppTypography.orbitron(color: AppColors.neonRed),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _modifyCoins(int amount) async {
    final reason = amount > 0 ? 'Admin gift' : 'Admin adjustment';
    await AdminFirestoreService.modifyCoins(widget.userId, amount, reason);
    widget.onUpdate();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${amount > 0 ? 'Added' : 'Removed'} ${amount.abs()} coins',
          ),
          backgroundColor: amount > 0 ? AppColors.success : AppColors.warning,
        ),
      );
    }
  }

  Future<void> _resetXP() async {
    await AdminFirestoreService.updateUser(widget.userId, {
      'xp': 0,
      'level': 1,
    });
    widget.onUpdate();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Delete Account',
          style: AppTypography.orbitron(color: AppColors.error),
        ),
        content: Text(
          'Are you sure you want to permanently delete this account? This action cannot be undone.',
          style: AppTypography.rajdhani(color: AppColors.txtPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.rajdhani(color: AppColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTypography.orbitron(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AdminFirestoreService.deleteUserAccount(widget.userId);
      widget.onUpdate();
    }
  }
}

// =============================================================================
// REUSABLE WIDGETS
// =============================================================================

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _GlassCard({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg2.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (borderColor ?? AppColors.neonBlue).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: (borderColor ?? AppColors.neonBlue).withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
    );
  }
}

class _SkeletonLoader extends StatelessWidget {
  final double height;
  final double? width;

  const _SkeletonLoader({required this.height, this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [Colors.transparent, Colors.white24, Colors.transparent],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.txtSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.rajdhani(
              size: 14,
              color: AppColors.txtSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.rajdhani(size: 14, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          _ActionButton(
            label: 'Retry',
            color: AppColors.neonBlue,
            onTap: onRetry,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.orbitron(size: 14, color: color)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _UserBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;

  const _UserBadge({
    required this.text,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: AppTypography.mono(
          size: 9,
          color: filled ? Colors.white : color,
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
            ],
            Text(label, style: AppTypography.rajdhani(size: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

class _AdminActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.rajdhani(size: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.rajdhani(
                size: 12,
                color: AppColors.txtSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.mono(size: 12, color: AppColors.neonGreen),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PLACEHOLDER SECTIONS (Other sections - implement similarly)
// =============================================================================

class GamesSection extends StatefulWidget {
  const GamesSection({super.key});

  @override
  State<GamesSection> createState() => _GamesSectionState();
}

class _GamesSectionState extends State<GamesSection> {
  String _selectedCategory = 'all';
  String _selectedDifficulty = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'all',
    'Puzzle',
    'Arcade',
    'Shooter',
    'Strategy',
    'Trivia',
    'Sports',
    'Action',
    'Casual',
  ];
  final List<String> _difficulties = ['all', 'Easy', 'Medium', 'Hard'];

  // Game statistics
  int _totalGamesPlayed = 0;
  int _totalWins = 0;
  int _totalLosses = 0;
  int _totalCoinsEarned = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _loadGameStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGameStats() async {
    try {
      final scoresSnapshot = await FirebaseFirestore.instance
          .collection('scores')
          .limit(1000)
          .get();

      int totalPlayed = 0;
      int totalWins = 0;
      int totalCoins = 0;

      for (final doc in scoresSnapshot.docs) {
        final data = doc.data();
        totalPlayed++;
        if (data['won'] == true) totalWins++;
        totalCoins += (data['coins'] as int? ?? 0);
      }

      setState(() {
        _totalGamesPlayed = totalPlayed;
        _totalWins = totalWins;
        _totalLosses = totalPlayed - totalWins;
        _totalCoinsEarned = totalCoins;
      });
    } catch (e) {
      debugPrint('Error loading game stats: $e');
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppColors.neonGreen;
      case 'Medium':
        return AppColors.neonOrange;
      case 'Hard':
        return AppColors.neonRed;
      default:
        return AppColors.txtSecondary;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Puzzle':
        return AppColors.neonBlue;
      case 'Arcade':
        return AppColors.neonGold;
      case 'Shooter':
        return AppColors.neonRed;
      case 'Strategy':
        return AppColors.neonPurple;
      case 'Trivia':
        return AppColors.neonCyan;
      case 'Sports':
        return AppColors.neonGreen;
      case 'Action':
        return AppColors.neonOrange;
      case 'Casual':
        return AppColors.neonPink;
      default:
        return AppColors.txtSecondary;
    }
  }

  Future<void> _resetGameStats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Reset Game Stats',
          style: AppTypography.orbitron(color: AppColors.warning),
        ),
        content: Text(
          'Are you sure you want to reset all game statistics? This will clear all scores and game history. This action cannot be undone.',
          style: AppTypography.rajdhani(color: AppColors.txtPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.rajdhani(color: AppColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Reset',
              style: AppTypography.orbitron(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final scoresSnapshot = await FirebaseFirestore.instance
            .collection('scores')
            .limit(500)
            .get();

        for (final doc in scoresSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        _loadGameStats();
        _showSnackBar('Game statistics reset successfully', AppColors.success);
      } catch (e) {
        _showSnackBar('Error: $e', AppColors.error);
      }
    }
  }

  Future<void> _viewGameDetails(Map<String, dynamic> game) async {
    final scoresSnapshot = await FirebaseFirestore.instance
        .collection('scores')
        .where('gameName', isEqualTo: game['name'])
        .limit(100)
        .get();

    int totalPlays = scoresSnapshot.docs.length;
    int wins = 0;
    int totalCoins = 0;
    int totalXp = 0;

    for (final doc in scoresSnapshot.docs) {
      final data = doc.data();
      if (data['won'] == true) wins++;
      totalCoins += (data['coins'] as int? ?? 0);
      totalXp += (data['xp'] as int? ?? 0);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          final categoryColor = _getCategoryColor(game['cat'] as String);

          return Container(
            decoration: const BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.txtSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              categoryColor,
                              categoryColor.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            game['icon'] as String,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game['name'] as String,
                              style: AppTypography.orbitron(
                                size: 18,
                                color: AppColors.txtPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: categoryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    game['cat'] as String,
                                    style: AppTypography.orbitron(
                                      size: 9,
                                      color: categoryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(
                                      game['diff'] as String,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _getDifficultyColor(
                                        game['diff'] as String,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    game['diff'] as String,
                                    style: AppTypography.orbitron(
                                      size: 9,
                                      color: _getDifficultyColor(
                                        game['diff'] as String,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.bg3),

                // Stats
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _StatGrid(
                        stats: [
                          {
                            'label': 'Total Plays',
                            'value': '$totalPlays',
                            'icon': Icons.play_arrow,
                            'color': AppColors.neonBlue,
                          },
                          {
                            'label': 'Win Rate',
                            'value': totalPlays > 0
                                ? '${((wins * 100) / totalPlays).toStringAsFixed(1)}%'
                                : '0%',
                            'icon': Icons.emoji_events,
                            'color': AppColors.neonGold,
                          },
                          {
                            'label': 'Wins',
                            'value': '$wins',
                            'icon': Icons.check_circle,
                            'color': AppColors.neonGreen,
                          },
                          {
                            'label': 'Losses',
                            'value': '${totalPlays - wins}',
                            'icon': Icons.cancel,
                            'color': AppColors.neonRed,
                          },
                          {
                            'label': 'Total Coins',
                            'value': '$totalCoins',
                            'icon': Icons.monetization_on,
                            'color': AppColors.neonGold,
                          },
                          {
                            'label': 'Total XP',
                            'value': '$totalXp',
                            'icon': Icons.star,
                            'color': AppColors.neonPurple,
                          },
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        label: 'Base Coins Reward',
                        value: '+${game['coins']}💰',
                        icon: Icons.monetization_on,
                      ),
                      _DetailRow(
                        label: 'Base XP Reward',
                        value: '+${game['xp']} XP',
                        icon: Icons.star,
                      ),
                      _DetailRow(
                        label: 'Difficulty Level',
                        value: game['diff'] as String,
                        icon: Icons.signal_cellular_alt,
                      ),
                      _DetailRow(
                        label: 'Category',
                        value: game['cat'] as String,
                        icon: Icons.category,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.rajdhani(color: Colors.white),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGames = GameCatalog.games;

    // Filter games
    var filteredGames = allGames.where((game) {
      if (_selectedCategory != 'all' && game['cat'] != _selectedCategory)
        return false;
      if (_selectedDifficulty != 'all' && game['diff'] != _selectedDifficulty)
        return false;
      if (_searchQuery.isNotEmpty) {
        final name = (game['name'] as String).toLowerCase();
        if (!name.contains(_searchQuery)) return false;
      }
      return true;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200
        ? 4
        : screenWidth > 800
        ? 3
        : 2;

    return Column(
      children: [
        // Stats Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.bg2,
          child: Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  title: 'Total Plays',
                  value: '$_totalGamesPlayed',
                  icon: Icons.play_arrow,
                  color: AppColors.neonBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStatCard(
                  title: 'Win Rate',
                  value: _totalGamesPlayed > 0
                      ? '${((_totalWins * 100) / _totalGamesPlayed).toStringAsFixed(1)}%'
                      : '0%',
                  icon: Icons.emoji_events,
                  color: AppColors.neonGold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStatCard(
                  title: 'Coins Earned',
                  value: '$_totalCoinsEarned',
                  icon: Icons.monetization_on,
                  color: AppColors.neonGreen,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _resetGameStats,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search and Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.bg2,
          child: Column(
            children: [
              // Search
              TextField(
                controller: _searchController,
                style: AppTypography.rajdhani(
                  size: 13,
                  color: AppColors.txtPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search games by name...',
                  hintStyle: AppTypography.rajdhani(
                    size: 12,
                    color: AppColors.txtSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.neonBlue,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.bg3,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    final color = category == 'all'
                        ? AppColors.neonBlue
                        : _getCategoryColor(category);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.2)
                                : AppColors.bg3,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : AppColors.neonBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            category == 'all' ? 'ALL' : category,
                            style: AppTypography.rajdhani(
                              size: 10,
                              color: isSelected
                                  ? color
                                  : AppColors.txtSecondary,
                              weight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Difficulty filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _difficulties.map((difficulty) {
                    final isSelected = _selectedDifficulty == difficulty;
                    final color = _getDifficultyColor(difficulty);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDifficulty = difficulty),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.2)
                                : AppColors.bg3,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : AppColors.neonBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            difficulty == 'all' ? 'ALL' : difficulty,
                            style: AppTypography.rajdhani(
                              size: 10,
                              color: isSelected
                                  ? color
                                  : AppColors.txtSecondary,
                              weight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Games Grid
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadGameStats,
            color: AppColors.neonBlue,
            child: filteredGames.isEmpty
                ? _EmptyState(
                    icon: Icons.games,
                    message: _searchQuery.isNotEmpty
                        ? 'No games match your search'
                        : 'No games found',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = filteredGames[index];
                      final categoryColor = _getCategoryColor(
                        game['cat'] as String,
                      );
                      final difficultyColor = _getDifficultyColor(
                        game['diff'] as String,
                      );

                      return GestureDetector(
                        onTap: () => _viewGameDetails(game),
                        child: _GlassCard(
                          borderColor: categoryColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: categoryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: categoryColor.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          game['icon'] as String,
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            game['name'] as String,
                                            style: AppTypography.orbitron(
                                              size: 11,
                                              color: AppColors.txtPrimary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: categoryColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  game['cat'] as String,
                                                  style: AppTypography.orbitron(
                                                    size: 7,
                                                    color: categoryColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: difficultyColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  game['diff'] as String,
                                                  style: AppTypography.orbitron(
                                                    size: 7,
                                                    color: difficultyColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(color: AppColors.bg3, height: 1),

                              // Rewards
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.monetization_on,
                                            color: AppColors.neonGold,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '+${game['coins']}',
                                            style: AppTypography.orbitron(
                                              size: 11,
                                              color: AppColors.neonGold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: AppColors.neonPurple,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '+${game['xp']}',
                                            style: AppTypography.orbitron(
                                              size: 11,
                                              color: AppColors.neonPurple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              // View Stats button
                              Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: categoryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.bar_chart,
                                        color: categoryColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'VIEW STATS',
                                        style: AppTypography.orbitron(
                                          size: 9,
                                          color: categoryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

// Mini Stat Card Widget
class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.mono(
                  size: 8,
                  color: AppColors.txtSecondary,
                ),
              ),
              Text(
                value,
                style: AppTypography.orbitron(size: 12, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Stat Grid Widget
class _StatGrid extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const _StatGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: stats.map((stat) {
        return Container(
          decoration: BoxDecoration(
            color: (stat['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (stat['color'] as Color).withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stat['icon'], color: stat['color'], size: 24),
              const SizedBox(height: 8),
              Text(
                stat['value'].toString(),
                style: AppTypography.orbitron(size: 18, color: stat['color']),
              ),
              const SizedBox(height: 4),
              Text(
                stat['label'],
                style: AppTypography.mono(
                  size: 10,
                  color: AppColors.txtSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Detail Row Widget
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.neonBlue, size: 16),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.rajdhani(
                size: 12,
                color: AppColors.txtSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.mono(
                size: 12,
                color: valueColor ?? AppColors.neonGreen,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// Empty State Widget

// Glass Card Widget (if not already defined)

// Error State Widget (if needed)

class LeaderboardSection extends StatefulWidget {
  const LeaderboardSection({super.key});

  @override
  State<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<LeaderboardSection> {
  String _timeFilter = 'all'; // all, weekly, monthly
  String _sortBy = 'xp'; // xp, wins, level, coins
  bool _isRefreshing = false;

  final List<String> _timeFilters = ['all', 'weekly', 'monthly'];
  final Map<String, String> _timeLabels = {
    'all': 'ALL TIME',
    'weekly': 'THIS WEEK',
    'monthly': 'THIS MONTH',
  };

  final List<String> _sortOptions = ['xp', 'wins', 'level', 'coins'];
  final Map<String, String> _sortLabels = {
    'xp': '🏆 XP',
    'wins': '🎯 WINS',
    'level': '⭐ LEVEL',
    'coins': '💰 COINS',
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isRefreshing = false);
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return AppColors.neonGold;
    if (rank == 2) return AppColors.neonBlue;
    if (rank == 3) return AppColors.neonGreen;
    return AppColors.txtSecondary;
  }

  String _getRankIcon(int rank) {
    if (rank == 1) return '👑';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '$rank';
  }

  Future<void> _resetLeaderboard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Reset Leaderboard',
          style: AppTypography.orbitron(color: AppColors.warning),
        ),
        content: Text(
          'Are you sure you want to reset all leaderboard data? This will reset XP, wins, and streaks for all players. This action cannot be undone.',
          style: AppTypography.rajdhani(color: AppColors.txtPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.rajdhani(color: AppColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Reset',
              style: AppTypography.orbitron(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminFirestoreService.resetLeaderboard();
        _showSnackBar('Leaderboard reset successfully', AppColors.success);
        _loadStats();
      } catch (e) {
        _showSnackBar('Error: $e', AppColors.error);
      }
    }
  }

  Future<void> _exportLeaderboard(List<QueryDocumentSnapshot> docs) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: _GlassCard(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.neonGold),
                SizedBox(height: 12),
                Text('Exporting leaderboard...'),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
      _showSnackBar('Export feature coming soon!', AppColors.neonBlue);
    }
  }

  void _showPlayerDetails(Map<String, dynamic> data) {
    final rank = data['rank'] ?? 0;
    final rankColor = _getRankColor(rank);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.txtSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header with rank
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [rankColor, rankColor.withOpacity(0.5)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: rankColor.withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getRankIcon(rank),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['nickname'] ?? 'Unknown',
                              style: AppTypography.orbitron(
                                size: 18,
                                color: AppColors.txtPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['playerId'] ?? 'N/A',
                              style: AppTypography.mono(
                                size: 11,
                                color: AppColors.neonGreen,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: rankColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: rankColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Rank #$rank',
                                style: AppTypography.orbitron(
                                  size: 11,
                                  color: rankColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.bg3),

                // Stats
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _StatGrid(
                        stats: [
                          {
                            'label': 'XP',
                            'value': '${data['xp'] ?? 0}',
                            'icon': Icons.star,
                            'color': AppColors.neonPurple,
                          },
                          {
                            'label': 'Level',
                            'value': '${data['level'] ?? 1}',
                            'icon': Icons.trending_up,
                            'color': AppColors.neonBlue,
                          },
                          {
                            'label': 'Coins',
                            'value': '${data['coins'] ?? 0}',
                            'icon': Icons.monetization_on,
                            'color': AppColors.neonGold,
                          },
                          {
                            'label': 'Wins',
                            'value': '${data['wins'] ?? 0}',
                            'icon': Icons.emoji_events,
                            'color': AppColors.neonGreen,
                          },
                          {
                            'label': 'Streak',
                            'value': '${data['streak'] ?? 0}',
                            'icon': Icons.local_fire_department,
                            'color': AppColors.neonOrange,
                          },
                          {
                            'label': 'Games Played',
                            'value':
                                '${(data['wins'] ?? 0) + (data['losses'] ?? 0)}',
                            'icon': Icons.videogame_asset,
                            'color': AppColors.neonCyan,
                          },
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        label: 'Win Rate',
                        value:
                            '${data['wins'] != null && (data['wins'] + (data['losses'] ?? 0)) > 0 ? ((data['wins'] * 100) / ((data['wins'] + (data['losses'] ?? 0)))).toStringAsFixed(1) : '0'}%',
                        icon: Icons.percent,
                      ),
                      _DetailRow(
                        label: 'Total XP Earned',
                        value: '${data['xp'] ?? 0}',
                        icon: Icons.auto_awesome,
                      ),
                      _DetailRow(
                        label: 'Last Updated',
                        value: _formatDate(data['updatedAt'] as Timestamp?),
                        icon: Icons.update,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Never';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.rajdhani(color: Colors.white),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with filters
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.bg2,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'GLOBAL RANKINGS',
                      style: AppTypography.orbitron(
                        size: 14,
                        color: AppColors.neonGold,
                      ),
                    ),
                  ),
                  // Reset button
                  GestureDetector(
                    onTap: _resetLeaderboard,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'RESET',
                            style: AppTypography.orbitron(
                              size: 10,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Export button
                  GestureDetector(
                    onTap: () async {
                      final snapshot = await FirebaseFirestore.instance
                          .collection('leaderboard')
                          .orderBy(_sortBy, descending: true)
                          .limit(500)
                          .get();
                      _exportLeaderboard(snapshot.docs);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.neonGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.download,
                            color: AppColors.neonGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'EXPORT',
                            style: AppTypography.orbitron(
                              size: 10,
                              color: AppColors.neonGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Time filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _timeFilters.map((filter) {
                    final isSelected = _timeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _timeFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.neonGold.withOpacity(0.2)
                                : AppColors.bg3,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.neonGold
                                  : AppColors.neonBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            _timeLabels[filter] ?? filter.toUpperCase(),
                            style: AppTypography.rajdhani(
                              size: 11,
                              color: isSelected
                                  ? AppColors.neonGold
                                  : AppColors.txtSecondary,
                              weight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Sort by chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _sortOptions.map((sort) {
                    final isSelected = _sortBy == sort;
                    final color = isSelected
                        ? _getSortColor(sort)
                        : AppColors.txtSecondary;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _sortBy = sort),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.2)
                                : AppColors.bg3,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : AppColors.neonBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            _sortLabels[sort] ?? sort.toUpperCase(),
                            style: AppTypography.rajdhani(
                              size: 10,
                              color: isSelected
                                  ? color
                                  : AppColors.txtSecondary,
                              weight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Leaderboard List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadStats,
            color: AppColors.neonGold,
            child: StreamBuilder<QuerySnapshot>(
              stream: AdminFirestoreService.getLeaderboardStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_isRefreshing) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.neonGold),
                  );
                }

                if (snapshot.hasError) {
                  return _ErrorState(
                    message: 'Failed to load leaderboard',
                    onRetry: () => _loadStats(),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                // Sort based on selected option
                var sortedDocs = List<QueryDocumentSnapshot>.from(docs);
                sortedDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aValue = aData[_sortBy] ?? 0;
                  final bValue = bData[_sortBy] ?? 0;
                  return (bValue as int).compareTo(aValue as int);
                });

                // Add rank to each document
                final rankedDocs = sortedDocs.asMap().entries.map((entry) {
                  final data = entry.value.data() as Map<String, dynamic>;
                  data['rank'] = entry.key + 1;
                  return entry.value;
                }).toList();

                if (rankedDocs.isEmpty) {
                  return _EmptyState(
                    icon: Icons.leaderboard,
                    message: 'No players found on leaderboard',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rankedDocs.length,
                  itemBuilder: (context, index) {
                    final doc = rankedDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final rank = index + 1;
                    final rankColor = _getRankColor(rank);
                    final isTop3 = rank <= 3;

                    return GestureDetector(
                      onTap: () => _showPlayerDetails({...data, 'rank': rank}),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: isTop3
                              ? (Matrix4.identity()..translate(0.0, -2.0))
                              : Matrix4.identity(),
                          child: _GlassCard(
                            borderColor: rankColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Rank
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: isTop3
                                          ? LinearGradient(
                                              colors: [
                                                rankColor,
                                                rankColor.withOpacity(0.5),
                                              ],
                                            )
                                          : null,
                                      color: isTop3 ? null : AppColors.bg3,
                                      border: Border.all(
                                        color: rankColor,
                                        width: isTop3 ? 2 : 1,
                                      ),
                                      boxShadow: isTop3
                                          ? [
                                              BoxShadow(
                                                color: rankColor.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 10,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getRankIcon(rank),
                                        style: TextStyle(
                                          fontSize: isTop3 ? 24 : 16,
                                          fontWeight: isTop3
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: rankColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Avatar and Info
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.bg3,
                                    ),
                                    child: Center(
                                      child: Text(
                                        data['avatar'] ?? '👤',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['nickname'] ?? 'Unknown',
                                          style: AppTypography.orbitron(
                                            size: 14,
                                            color: isTop3
                                                ? rankColor
                                                : AppColors.txtPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          data['playerId'] ?? '',
                                          style: AppTypography.mono(
                                            size: 10,
                                            color: AppColors.txtSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            _LeaderboardBadge(
                                              text: 'Lv.${data['level'] ?? 1}',
                                              color: AppColors.neonPurple,
                                            ),
                                            _LeaderboardBadge(
                                              text: '🏆 ${data['wins'] ?? 0}',
                                              color: AppColors.neonGreen,
                                            ),
                                            _LeaderboardBadge(
                                              text: '🔥 ${data['streak'] ?? 0}',
                                              color: AppColors.neonOrange,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Stats
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${data['xp'] ?? 0}',
                                        style: AppTypography.orbitron(
                                          size: 16,
                                          color: rankColor,
                                        ),
                                      ),
                                      Text(
                                        'XP',
                                        style: AppTypography.mono(
                                          size: 9,
                                          color: AppColors.txtSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '💰 ${data['coins'] ?? 0}',
                                        style: AppTypography.orbitron(
                                          size: 12,
                                          color: AppColors.neonGold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right,
                                    color: rankColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getSortColor(String sort) {
    switch (sort) {
      case 'xp':
        return AppColors.neonPurple;
      case 'wins':
        return AppColors.neonGreen;
      case 'level':
        return AppColors.neonBlue;
      case 'coins':
        return AppColors.neonGold;
      default:
        return AppColors.txtSecondary;
    }
  }
}

// Helper Widgets
class _LeaderboardBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _LeaderboardBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: AppTypography.mono(size: 9, color: color)),
    );
  }
}

class MarketplaceSection extends StatefulWidget {
  const MarketplaceSection({super.key});

  @override
  State<MarketplaceSection> createState() => _MarketplaceSectionState();
}

class _MarketplaceSectionState extends State<MarketplaceSection> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemIdController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Premium Avatars';
  String _selectedRarity = 'rare';
  bool _isAddingItem = false;
  bool _isEditing = false;
  String? _editingItemId;
  String _searchQuery = '';

  final List<String> _categories = [
    'Premium Avatars',
    'Animated Frames',
    'Power Boosters',
    'XP Multipliers',
    'Special Themes',
    'Rare Badges',
    'Daily Reward Packs',
    'Profile Decorations',
    'Mystery Boxes',
    'Legendary Items',
    'Limited Event Items',
    'Energy Packs',
    'Streak Protectors',
    'Quiz Hint Packs',
    'Premium Name Colors',
    'Clan Upgrade Packs',
    'Skill Cards',
    'Emoji Packs',
    'Background Skins',
    'Achievement Effects',
  ];

  final List<String> _rarities = [
    'common',
    'rare',
    'epic',
    'legendary',
    'mythic',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemIdController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _emojiController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _itemNameController.clear();
    _itemIdController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _emojiController.clear();
    _selectedCategory = 'Premium Avatars';
    _selectedRarity = 'rare';
    _isEditing = false;
    _editingItemId = null;
  }

  Future<void> _addOrUpdateItem() async {
    if (_itemNameController.text.trim().isEmpty) {
      _showSnackBar('Item name is required', AppColors.error);
      return;
    }

    if (_itemIdController.text.trim().isEmpty) {
      _showSnackBar('Item ID is required', AppColors.error);
      return;
    }

    setState(() => _isAddingItem = true);

    try {
      final itemData = {
        'name': _itemNameController.text.trim(),
        'itemId': _itemIdController.text.trim(),
        'category': _selectedCategory,
        'rarity': _selectedRarity,
        'price': int.tryParse(_priceController.text.trim()) ?? 100,
        'description': _descriptionController.text.trim().isEmpty
            ? 'Amazing item for your collection!'
            : _descriptionController.text.trim(),
        'emoji': _emojiController.text.trim().isEmpty
            ? '🎮'
            : _emojiController.text.trim(),
        'active': true,
        'salesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing && _editingItemId != null) {
        await AdminFirestoreService.updateMarketplaceItem(
          _editingItemId!,
          itemData,
        );
        _showSnackBar('Item updated successfully!', AppColors.success);
      } else {
        await AdminFirestoreService.addMarketplaceItem(itemData);
        _showSnackBar('Item added successfully!', AppColors.success);
      }

      _resetForm();
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _isAddingItem = false);
    }
  }

  Future<void> _toggleItemActive(String itemId, bool currentActive) async {
    try {
      await AdminFirestoreService.updateMarketplaceItem(itemId, {
        'active': !currentActive,
      });
      _showSnackBar(
        'Item ${!currentActive ? 'activated' : 'deactivated'}',
        AppColors.success,
      );
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    }
  }

  Future<void> _deleteItem(String itemId, String itemName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Delete Item',
          style: AppTypography.orbitron(color: AppColors.error),
        ),
        content: Text(
          'Are you sure you want to delete "$itemName"? This action cannot be undone.',
          style: AppTypography.rajdhani(color: AppColors.txtPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.rajdhani(color: AppColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTypography.orbitron(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminFirestoreService.deleteMarketplaceItem(itemId);
        _showSnackBar('Item deleted successfully', AppColors.success);
      } catch (e) {
        _showSnackBar('Error: $e', AppColors.error);
      }
    }
  }

  void _editItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    _itemNameController.text = data['name'] ?? '';
    _itemIdController.text = data['itemId'] ?? '';
    _priceController.text = (data['price'] ?? 100).toString();
    _descriptionController.text = data['description'] ?? '';
    _emojiController.text = data['emoji'] ?? '🎮';
    _selectedCategory = data['category'] ?? 'Premium Avatars';
    _selectedRarity = data['rarity'] ?? 'rare';
    _isEditing = true;
    _editingItemId = doc.id;

    _showAddEditDialog();
  }

  void _showAddEditDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.bg2,
            title: Row(
              children: [
                Icon(
                  _isEditing ? Icons.edit : Icons.add,
                  color: AppColors.neonGold,
                ),
                const SizedBox(width: 8),
                Text(
                  _isEditing ? 'Edit Item' : 'Add New Item',
                  style: AppTypography.orbitron(
                    size: 16,
                    color: AppColors.neonGold,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: _itemNameController,
                      label: 'Item Name *',
                      icon: Icons.shopping_bag,
                      hint: 'e.g., Dragon Lord Avatar',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _itemIdController,
                      label: 'Item ID *',
                      icon: Icons.tag,
                      hint: 'e.g., avatar_dragon_001',
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      value: _selectedCategory,
                      items: _categories,
                      label: 'Category',
                      icon: Icons.category,
                      onChanged: (value) =>
                          setDialogState(() => _selectedCategory = value!),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      value: _selectedRarity,
                      items: _rarities,
                      label: 'Rarity',
                      icon: Icons.star,
                      onChanged: (value) =>
                          setDialogState(() => _selectedRarity = value!),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _priceController,
                      label: 'Price (Coins)',
                      icon: Icons.monetization_on,
                      hint: 'e.g., 500',
                      isNumber: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _emojiController,
                      label: 'Emoji/Icon',
                      icon: Icons.emoji_emotions,
                      hint: 'e.g., 🐉',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      hint: 'Describe the item...',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _resetForm();
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: AppTypography.rajdhani(color: AppColors.txtSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: _isAddingItem ? null : _addOrUpdateItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGold,
                  foregroundColor: Colors.black,
                ),
                child: _isAddingItem
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'UPDATE' : 'ADD',
                        style: AppTypography.orbitron(size: 12),
                      ),
              ),
            ],
          );
        },
      ),
    ).then((_) => _resetForm());
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: AppTypography.rajdhani(size: 13, color: AppColors.txtPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.mono(size: 11, color: AppColors.neonBlue),
        hintText: hint,
        hintStyle: AppTypography.rajdhani(
          size: 12,
          color: AppColors.txtSecondary,
        ),
        prefixIcon: Icon(icon, color: AppColors.neonBlue, size: 18),
        filled: true,
        fillColor: AppColors.bg3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.bg2,
          style: AppTypography.rajdhani(size: 13, color: AppColors.txtPrimary),
          icon: Icon(icon, color: AppColors.neonBlue, size: 18),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  _getRarityIcon(item),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _getRarityIcon(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Icon(
          Icons.circle,
          color: AppColors.txtSecondary,
          size: 12,
        );
      case 'rare':
        return const Icon(Icons.star, color: AppColors.neonBlue, size: 12);
      case 'epic':
        return const Icon(
          Icons.star_half,
          color: AppColors.neonPurple,
          size: 12,
        );
      case 'legendary':
        return const Icon(Icons.star, color: AppColors.neonGold, size: 12);
      case 'mythic':
        return const Icon(
          Icons.star_border,
          color: AppColors.neonPink,
          size: 12,
        );
      default:
        return const Icon(Icons.circle, size: 12);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.rajdhani(color: Colors.white),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return AppColors.txtSecondary;
      case 'rare':
        return AppColors.neonBlue;
      case 'epic':
        return AppColors.neonPurple;
      case 'legendary':
        return AppColors.neonGold;
      case 'mythic':
        return AppColors.neonPink;
      default:
        return AppColors.txtSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.bg2,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: AppTypography.rajdhani(
                    size: 13,
                    color: AppColors.txtPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search items by name or ID...',
                    hintStyle: AppTypography.rajdhani(
                      size: 12,
                      color: AppColors.txtSecondary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.neonBlue,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.bg3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _showAddEditDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.neonGold, AppColors.neonOrange],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.black, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'ADD ITEM',
                        style: AppTypography.orbitron(
                          size: 11,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Items Grid
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: AdminFirestoreService.getMarketplaceItemsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.neonBlue),
                );
              }

              if (snapshot.hasError) {
                return _ErrorState(
                  message: 'Failed to load items',
                  onRetry: () => setState(() {}),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              var filteredDocs = docs;

              if (_searchQuery.isNotEmpty) {
                filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final itemId = (data['itemId'] ?? '')
                      .toString()
                      .toLowerCase();
                  return name.contains(_searchQuery) ||
                      itemId.contains(_searchQuery);
                }).toList();
              }

              if (filteredDocs.isEmpty) {
                return _EmptyState(
                  icon: Icons.store_outlined,
                  message: _searchQuery.isNotEmpty
                      ? 'No items match your search'
                      : 'No marketplace items yet.\nTap "ADD ITEM" to create one.',
                );
              }

              final screenWidth = MediaQuery.of(context).size.width;
              final crossAxisCount = screenWidth > 1200
                  ? 4
                  : screenWidth > 800
                  ? 3
                  : 2;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final rarity = data['rarity'] ?? 'common';
                  final color = _getRarityColor(rarity);
                  final isActive = data['active'] == true;

                  return _GlassCard(
                    borderColor: color,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with status and actions
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Status indicator
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? AppColors.success
                                      : AppColors.error,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (isActive
                                                  ? AppColors.success
                                                  : AppColors.error)
                                              .withOpacity(0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: color.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  rarity.toUpperCase(),
                                  style: AppTypography.orbitron(
                                    size: 8,
                                    color: color,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Edit button
                              GestureDetector(
                                onTap: () => _editItem(doc),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.neonBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: AppColors.neonBlue,
                                    size: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Delete button
                              GestureDetector(
                                onTap: () =>
                                    _deleteItem(doc.id, data['name'] ?? ''),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: AppColors.error,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Emoji/Icon
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Center(
                              child: Text(
                                data['emoji'] ?? '🎮',
                                style: const TextStyle(fontSize: 42),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            data['name'] ?? 'Unknown',
                            style: AppTypography.orbitron(
                              size: 12,
                              color: AppColors.txtPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Category
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            data['category'] ?? '',
                            style: AppTypography.rajdhani(
                              size: 10,
                              color: AppColors.txtSecondary,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Price and toggle
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Text(
                                '💰 ${data['price'] ?? 0}',
                                style: AppTypography.orbitron(
                                  size: 14,
                                  color: AppColors.neonGold,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () =>
                                    _toggleItemActive(doc.id, isActive),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.success.withOpacity(0.1)
                                        : AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isActive
                                          ? AppColors.success
                                          : AppColors.error,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isActive ? 'ACTIVE' : 'INACTIVE',
                                    style: AppTypography.orbitron(
                                      size: 8,
                                      color: isActive
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class TransactionsSection extends StatefulWidget {
  const TransactionsSection({super.key});

  @override
  State<TransactionsSection> createState() => _TransactionsSectionState();
}

class _TransactionsSectionState extends State<TransactionsSection> {
  String _filterType = 'all'; // all, transfer, purchase, reward
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['all', 'transfer', 'purchase', 'reward'];
  final Map<String, String> _filterLabels = {
    'all': 'ALL',
    'transfer': 'TRANSFERS',
    'purchase': 'PURCHASES',
    'reward': 'REWARDS',
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '--:--';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'transfer':
        return AppColors.neonBlue;
      case 'purchase':
        return AppColors.neonPurple;
      case 'reward':
        return AppColors.neonGold;
      default:
        return AppColors.txtSecondary;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'transfer':
        return Icons.swap_horiz;
      case 'purchase':
        return Icons.shopping_cart;
      case 'reward':
        return Icons.card_giftcard;
      default:
        return Icons.receipt;
    }
  }

  Future<void> _exportTransactions(List<QueryDocumentSnapshot> docs) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: _GlassCard(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.neonBlue),
                SizedBox(height: 12),
                Text('Exporting transactions...'),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
      _showSnackBar('Export feature coming soon!', AppColors.neonBlue);
    }
  }

  void _showTransactionDetails(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.txtSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getTransactionColor(
                            data['type'] ?? '',
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getTransactionColor(
                              data['type'] ?? '',
                            ).withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          _getTransactionIcon(data['type'] ?? ''),
                          color: _getTransactionColor(data['type'] ?? ''),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (data['type'] ?? 'TRANSACTION')
                                  .toString()
                                  .toUpperCase(),
                              style: AppTypography.orbitron(
                                size: 14,
                                color: _getTransactionColor(data['type'] ?? ''),
                              ),
                            ),
                            Text(
                              data['txnId'] ?? 'N/A',
                              style: AppTypography.mono(
                                size: 10,
                                color: AppColors.txtSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${data['amount'] ?? 0}',
                        style: AppTypography.orbitron(
                          size: 20,
                          color: _getTransactionColor(data['type'] ?? ''),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.bg3),

                // Details
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _DetailRow(
                        label: 'Transaction ID',
                        value: data['txnId'] ?? 'N/A',
                        icon: Icons.receipt,
                      ),
                      _DetailRow(
                        label: 'Status',
                        value: data['status'] ?? 'success',
                        icon: Icons.check_circle,
                        valueColor: (data['status'] ?? 'success') == 'success'
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Sender',
                        value: data['senderId'] ?? 'System',
                        icon: Icons.person_outline,
                      ),
                      _DetailRow(
                        label: 'Sender UPI',
                        value: data['senderUpiId'] ?? 'N/A',
                        icon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Receiver',
                        value: data['receiverId'] ?? 'System',
                        icon: Icons.person_outline,
                      ),
                      _DetailRow(
                        label: 'Receiver UPI',
                        value: data['receiverUpiId'] ?? 'N/A',
                        icon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Description',
                        value: data['description'] ?? 'No description',
                        icon: Icons.description,
                      ),
                      _DetailRow(
                        label: 'Timestamp',
                        value: _formatDate(data['timestamp'] as Timestamp?),
                        icon: Icons.access_time,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.rajdhani(color: Colors.white),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter and Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.bg2,
          child: Column(
            children: [
              // Search
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.rajdhani(
                        size: 13,
                        color: AppColors.txtPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by ID, sender, receiver...',
                        hintStyle: AppTypography.rajdhani(
                          size: 12,
                          color: AppColors.txtSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.neonBlue,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AppColors.bg3,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Export button
                  GestureDetector(
                    onTap: () async {
                      final snapshot = await FirebaseFirestore.instance
                          .collection('transactions')
                          .orderBy('timestamp', descending: true)
                          .limit(1000)
                          .get();
                      _exportTransactions(snapshot.docs);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.neonGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.download,
                            color: AppColors.neonGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'EXPORT',
                            style: AppTypography.orbitron(
                              size: 10,
                              color: AppColors.neonGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterOptions.map((filter) {
                    final isSelected = _filterType == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filterType = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _getTransactionColor(filter).withOpacity(0.2)
                                : AppColors.bg3,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? _getTransactionColor(filter)
                                  : AppColors.neonBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            _filterLabels[filter] ?? filter.toUpperCase(),
                            style: AppTypography.rajdhani(
                              size: 11,
                              color: isSelected
                                  ? _getTransactionColor(filter)
                                  : AppColors.txtSecondary,
                              weight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Stats Summary
        StreamBuilder<QuerySnapshot>(
          stream: AdminFirestoreService.getTransactionsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            final docs = snapshot.data!.docs;
            final totalVolume = docs.fold<int>(0, (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              return sum + (data['amount'] as int? ?? 0);
            });

            final transferVolume = docs
                .where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['type'] == 'transfer';
                })
                .fold<int>(0, (sum, doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return sum + (data['amount'] as int? ?? 0);
                });

            final purchaseVolume = docs
                .where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['type'] == 'purchase';
                })
                .fold<int>(0, (sum, doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return sum + (data['amount'] as int? ?? 0);
                });

            return Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Volume',
                      value: '$totalVolume',
                      icon: Icons.attach_money,
                      color: AppColors.neonGold,
                      subtitle: 'Total transactions',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Transfers',
                      value: '$transferVolume',
                      icon: Icons.swap_horiz,
                      color: AppColors.neonBlue,
                      subtitle: 'P2P transfers',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Purchases',
                      value: '$purchaseVolume',
                      icon: Icons.shopping_cart,
                      color: AppColors.neonPurple,
                      subtitle: 'Marketplace buys',
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Transactions List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: AdminFirestoreService.getTransactionsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.neonBlue),
                );
              }

              if (snapshot.hasError) {
                return _ErrorState(
                  message: 'Failed to load transactions',
                  onRetry: () => setState(() {}),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // Apply filters
              var filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                if (_filterType != 'all' && data['type'] != _filterType) {
                  return false;
                }
                if (_searchQuery.isNotEmpty) {
                  final txnId = (data['txnId'] ?? '').toString().toLowerCase();
                  final sender = (data['senderId'] ?? '')
                      .toString()
                      .toLowerCase();
                  final receiver = (data['receiverId'] ?? '')
                      .toString()
                      .toLowerCase();
                  return txnId.contains(_searchQuery) ||
                      sender.contains(_searchQuery) ||
                      receiver.contains(_searchQuery);
                }
                return true;
              }).toList();

              if (filteredDocs.isEmpty) {
                return _EmptyState(
                  icon: Icons.swap_horiz,
                  message: _searchQuery.isNotEmpty
                      ? 'No transactions match your search'
                      : 'No transactions found',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final type = data['type'] ?? 'unknown';
                  final amount = data['amount'] ?? 0;
                  final status = data['status'] ?? 'success';
                  final color = _getTransactionColor(type);
                  final icon = _getTransactionIcon(type);

                  return GestureDetector(
                    onTap: () => _showTransactionDetails(data),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _GlassCard(
                        borderColor: color,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Type icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: color.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(icon, color: color, size: 24),
                              ),
                              const SizedBox(width: 12),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['description'] ?? 'Transaction',
                                      style: AppTypography.orbitron(
                                        size: 12,
                                        color: AppColors.txtPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${data['senderId'] ?? 'System'} → ${data['receiverId'] ?? 'System'}',
                                      style: AppTypography.mono(
                                        size: 10,
                                        color: AppColors.txtSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            type.toUpperCase(),
                                            style: AppTypography.orbitron(
                                              size: 8,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        if (status != 'success')
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.error
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              status.toUpperCase(),
                                              style: AppTypography.orbitron(
                                                size: 8,
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Amount and time
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$amount',
                                    style: AppTypography.orbitron(
                                      size: 16,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(
                                      data['timestamp'] as Timestamp?,
                                    ),
                                    style: AppTypography.mono(
                                      size: 10,
                                      color: AppColors.txtSecondary,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.txtSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Helper widget for detail rows

class AnnouncementsSection extends StatefulWidget {
  const AnnouncementsSection({super.key});

  @override
  State<AnnouncementsSection> createState() => _AnnouncementsSectionState();
}

class _AnnouncementsSectionState extends State<AnnouncementsSection> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedType = 'info';
  String _selectedPriority = 'normal';
  bool _isAdding = false;
  bool _isEditing = false;
  String? _editingId;

  final List<String> _announcementTypes = [
    'info',
    'success',
    'warning',
    'error',
    'event',
  ];
  final List<String> _priorities = ['low', 'normal', 'high', 'urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    _messageController.clear();
    _selectedType = 'info';
    _selectedPriority = 'normal';
    _isEditing = false;
    _editingId = null;
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'info':
        return AppColors.neonBlue;
      case 'success':
        return AppColors.neonGreen;
      case 'warning':
        return AppColors.neonOrange;
      case 'error':
        return AppColors.neonRed;
      case 'event':
        return AppColors.neonPurple;
      default:
        return AppColors.neonBlue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'info':
        return Icons.info_outline;
      case 'success':
        return Icons.check_circle_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      case 'event':
        return Icons.event_available;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return AppColors.txtSecondary;
      case 'normal':
        return AppColors.neonBlue;
      case 'high':
        return AppColors.neonOrange;
      case 'urgent':
        return AppColors.neonRed;
      default:
        return AppColors.txtSecondary;
    }
  }

  Future<void> _createAnnouncement() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Title is required', AppColors.error);
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      _showSnackBar('Message is required', AppColors.error);
      return;
    }

    setState(() => _isAdding = true);

    try {
      await AdminFirestoreService.createAnnouncement(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _selectedType,
        priority: _selectedPriority,
      );

      _showSnackBar('Announcement created successfully!', AppColors.success);
      _resetForm();
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _updateAnnouncement(String id) async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Title is required', AppColors.error);
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      _showSnackBar('Message is required', AppColors.error);
      return;
    }

    setState(() => _isAdding = true);

    try {
      await AdminFirestoreService.updateMarketplaceItem(id, {
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'type': _selectedType,
        'priority': _selectedPriority,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Announcement updated successfully!', AppColors.success);
      _resetForm();
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _deleteAnnouncement(String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Delete Announcement',
          style: AppTypography.orbitron(color: AppColors.error),
        ),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
          style: AppTypography.rajdhani(color: AppColors.txtPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.rajdhani(color: AppColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTypography.orbitron(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminFirestoreService.deleteAnnouncement(id);
        _showSnackBar('Announcement deleted successfully', AppColors.success);
      } catch (e) {
        _showSnackBar('Error: $e', AppColors.error);
      }
    }
  }

  Future<void> _toggleAnnouncementActive(String id, bool currentActive) async {
    try {
      await AdminFirestoreService.updateMarketplaceItem(id, {
        'active': !currentActive,
      });
      _showSnackBar(
        'Announcement ${!currentActive ? 'activated' : 'deactivated'}',
        AppColors.success,
      );
    } catch (e) {
      _showSnackBar('Error: $e', AppColors.error);
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? data]) {
    if (data != null) {
      _titleController.text = data['title'] ?? '';
      _messageController.text = data['message'] ?? '';
      _selectedType = data['type'] ?? 'info';
      _selectedPriority = data['priority'] ?? 'normal';
      _isEditing = true;
      _editingId = data['id'];
    } else {
      _resetForm();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.bg2,
            title: Row(
              children: [
                Icon(
                  _isEditing ? Icons.edit : Icons.add_alert,
                  color: AppColors.neonGold,
                ),
                const SizedBox(width: 8),
                Text(
                  _isEditing ? 'Edit Announcement' : 'New Announcement',
                  style: AppTypography.orbitron(
                    size: 16,
                    color: AppColors.neonGold,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Title',
                      icon: Icons.title,
                      hint: 'Enter announcement title...',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _messageController,
                      label: 'Message',
                      icon: Icons.message,
                      hint: 'Enter announcement message...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    _buildTypeDropdown(setDialogState),
                    const SizedBox(height: 12),
                    _buildPriorityDropdown(setDialogState),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _resetForm();
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: AppTypography.rajdhani(color: AppColors.txtSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: _isAdding
                    ? null
                    : (_isEditing
                          ? () => _updateAnnouncement(_editingId!)
                          : _createAnnouncement),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGold,
                  foregroundColor: Colors.black,
                ),
                child: _isAdding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'UPDATE' : 'CREATE',
                        style: AppTypography.orbitron(size: 12),
                      ),
              ),
            ],
          );
        },
      ),
    ).then((_) => _resetForm());
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTypography.rajdhani(size: 13, color: AppColors.txtPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.mono(size: 11, color: AppColors.neonBlue),
        hintText: hint,
        hintStyle: AppTypography.rajdhani(
          size: 12,
          color: AppColors.txtSecondary,
        ),
        prefixIcon: Icon(icon, color: AppColors.neonBlue, size: 18),
        filled: true,
        fillColor: AppColors.bg3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildTypeDropdown(StateSetter setDialogState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          dropdownColor: AppColors.bg2,
          style: AppTypography.rajdhani(size: 13, color: AppColors.txtPrimary),
          icon: const Icon(Icons.category, color: AppColors.neonBlue, size: 18),
          items: _announcementTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Icon(
                    _getTypeIcon(type),
                    color: _getTypeColor(type),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(type.toUpperCase()),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setDialogState(() => _selectedType = value!),
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown(StateSetter setDialogState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPriority,
          isExpanded: true,
          dropdownColor: AppColors.bg2,
          style: AppTypography.rajdhani(size: 13, color: AppColors.txtPrimary),
          icon: const Icon(Icons.flag, color: AppColors.neonBlue, size: 18),
          items: _priorities.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: Row(
                children: [
                  Icon(
                    Icons.flag,
                    color: _getPriorityColor(priority),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(priority.toUpperCase()),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) =>
              setDialogState(() => _selectedPriority = value!),
        ),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.rajdhani(color: Colors.white),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Create Button
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.bg2,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'MANAGE ANNOUNCEMENTS',
                  style: AppTypography.orbitron(
                    size: 14,
                    color: AppColors.neonGold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showAddEditDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.neonGold, AppColors.neonOrange],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_alert,
                        color: Colors.black,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'NEW ANNOUNCEMENT',
                        style: AppTypography.orbitron(
                          size: 10,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Announcements List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: AdminFirestoreService.getAnnouncementsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.neonGold),
                );
              }

              if (snapshot.hasError) {
                return _ErrorState(
                  message: 'Failed to load announcements',
                  onRetry: () => setState(() {}),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return _EmptyState(
                  icon: Icons.campaign_outlined,
                  message:
                      'No announcements yet.\nTap "NEW ANNOUNCEMENT" to create one.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final type = data['type'] ?? 'info';
                  final priority = data['priority'] ?? 'normal';
                  final isActive = data['active'] != false;
                  final typeColor = _getTypeColor(type);
                  final priorityColor = _getPriorityColor(priority);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _GlassCard(
                      borderColor: typeColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: typeColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    _getTypeIcon(type),
                                    color: typeColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['title'] ?? 'Untitled',
                                        style: AppTypography.orbitron(
                                          size: 14,
                                          color: AppColors.txtPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: typeColor.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              type.toUpperCase(),
                                              style: AppTypography.orbitron(
                                                size: 8,
                                                color: typeColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: priorityColor.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.flag,
                                                  color: priorityColor,
                                                  size: 10,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  priority.toUpperCase(),
                                                  style: AppTypography.orbitron(
                                                    size: 8,
                                                    color: priorityColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!isActive) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.error
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'INACTIVE',
                                                style: AppTypography.orbitron(
                                                  size: 8,
                                                  color: AppColors.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Action buttons
                                Row(
                                  children: [
                                    // Edit
                                    GestureDetector(
                                      onTap: () => _showAddEditDialog({
                                        'id': doc.id,
                                        'title': data['title'],
                                        'message': data['message'],
                                        'type': data['type'],
                                        'priority': data['priority'],
                                      }),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.neonBlue.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: AppColors.neonBlue,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Delete
                                    GestureDetector(
                                      onTap: () => _deleteAnnouncement(
                                        doc.id,
                                        data['title'] ?? '',
                                      ),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: AppColors.error,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Toggle Active
                                    GestureDetector(
                                      onTap: () => _toggleAnnouncementActive(
                                        doc.id,
                                        isActive,
                                      ),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color:
                                              (isActive
                                                      ? AppColors.success
                                                      : AppColors.error)
                                                  .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Icon(
                                          isActive
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: isActive
                                              ? AppColors.success
                                              : AppColors.error,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Message body
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Text(
                              data['message'] ?? 'No message',
                              style: AppTypography.rajdhani(
                                size: 13,
                                color: AppColors.txtSecondary,
                              ),
                            ),
                          ),

                          // Footer with timestamp
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: AppColors.txtSecondary,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(data['createdAt'] as Timestamp?),
                                  style: AppTypography.mono(
                                    size: 10,
                                    color: AppColors.txtSecondary,
                                  ),
                                ),
                                if (data['createdBy'] != null) ...[
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.person,
                                    color: AppColors.txtSecondary,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['createdBy'] ?? 'Admin',
                                    style: AppTypography.mono(
                                      size: 10,
                                      color: AppColors.txtSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
    );
  }
}

// Helper widget for preview card (optional - for user-facing announcements)
class AnnouncementPreviewCard extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final VoidCallback? onDismiss;

  const AnnouncementPreviewCard({
    super.key,
    required this.announcement,
    this.onDismiss,
  });

  Color _getTypeColor(String type) {
    switch (type) {
      case 'info':
        return AppColors.neonBlue;
      case 'success':
        return AppColors.neonGreen;
      case 'warning':
        return AppColors.neonOrange;
      case 'error':
        return AppColors.neonRed;
      case 'event':
        return AppColors.neonPurple;
      default:
        return AppColors.neonBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = announcement['type'] ?? 'info';
    final color = _getTypeColor(type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _GlassCard(
        borderColor: color,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement['title'] ?? 'Announcement',
                              style: AppTypography.orbitron(
                                size: 14,
                                color: AppColors.txtPrimary,
                              ),
                            ),
                            Text(
                              announcement['message'] ?? '',
                              style: AppTypography.rajdhani(
                                size: 12,
                                color: AppColors.txtSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.txtSecondary,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ActivityLogsSection extends StatefulWidget {
  const ActivityLogsSection({super.key});

  @override
  State<ActivityLogsSection> createState() => _ActivityLogsSectionState();
}

class _ActivityLogsSectionState extends State<ActivityLogsSection> {
  String _filterAction = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _actionFilters = [
    'all',
    'login',
    'logout',
    'win',
    'loss',
    'purchase',
    'transfer',
    'daily_reward',
    'account_created',
    'ban_user',
    'unban_user',
    'modify_coins',
    'delete_account',
  ];

  final Map<String, String> _filterLabels = {
    'all': 'ALL',
    'login': 'LOGIN',
    'logout': 'LOGOUT',
    'win': 'WINS',
    'loss': 'LOSSES',
    'purchase': 'PURCHASES',
    'transfer': 'TRANSFERS',
    'daily_reward': 'REWARDS',
    'account_created': 'NEW USERS',
    'ban_user': 'BANS',
    'unban_user': 'UNBANS',
    'modify_coins': 'COIN ADJUST',
    'delete_account': 'DELETIONS',
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'login':
        return AppColors.neonGreen;
      case 'logout':
        return AppColors.neonOrange;
      case 'win':
        return AppColors.neonGold;
      case 'loss':
        return AppColors.neonRed;
      case 'purchase':
        return AppColors.neonPurple;
      case 'transfer':
        return AppColors.neonBlue;
      case 'daily_reward':
        return AppColors.neonGold;
      case 'account_created':
        return AppColors.neonCyan;
      case 'ban_user':
        return AppColors.error;
      case 'unban_user':
        return AppColors.success;
      case 'modify_coins':
        return AppColors.neonGold;
      case 'delete_account':
        return AppColors.error;
      default:
        return AppColors.txtSecondary;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'win':
        return Icons.emoji_events;
      case 'loss':
        return Icons.sentiment_dissatisfied;
      case 'purchase':
        return Icons.shopping_cart;
      case 'transfer':
        return Icons.swap_horiz;
      case 'daily_reward':
        return Icons.card_giftcard;
      case 'account_created':
        return Icons.person_add;
      case 'ban_user':
        return Icons.block;
      case 'unban_user':
        return Icons.lock_open;
      case 'modify_coins':
        return Icons.monetization_on;
      case 'delete_account':
        return Icons.delete_forever;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '--:--';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getRelativeDateGroup(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    const weekAgo = Duration(days: 7);

    if (date.isAfter(today)) {
      return 'Today';
    } else if (date.isAfter(yesterday)) {
      return 'Yesterday';
    } else if (date.isAfter(now.subtract(weekAgo))) {
      return 'This Week';
    } else {
      return '${date.month}/${date.year}';
    }
  }

  Future<void> _clearOldLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Clear Old Logs',
          style: AppTypography.orbitron(color: AppColors.warning),
        ),
        content: Text(
          'Are you sure you want to clear all logs older than 30 days? This action cannot be undone.',
          style: AppTypography.rajdhani(color: AppColors.txtPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.rajdhani(color: AppColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: AppTypography.orbitron(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final thirtyDaysAgo = Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 30)),
        );
        final snapshot = await FirebaseFirestore.instance
            .collection('activityLogs')
            .where('timestamp', isLessThan: thirtyDaysAgo)
            .limit(500)
            .get();

        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        _showSnackBar(
          'Cleared ${snapshot.docs.length} old logs',
          AppColors.success,
        );
      } catch (e) {
        _showSnackBar('Error: $e', AppColors.error);
      }
    }
  }

  Future<void> _exportLogs(List<QueryDocumentSnapshot> docs) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: _GlassCard(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.neonBlue),
                SizedBox(height: 12),
                Text('Exporting logs...'),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
      _showSnackBar('Export feature coming soon!', AppColors.neonBlue);
    }
  }

  void _showLogDetails(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          final action = data['action'] ?? 'unknown';
          final actionColor = _getActionColor(action);

          return Container(
            decoration: const BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.txtSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: actionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: actionColor.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          _getActionIcon(action),
                          color: actionColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.toUpperCase(),
                              style: AppTypography.orbitron(
                                size: 14,
                                color: actionColor,
                              ),
                            ),
                            Text(
                              data['playerId'] ?? 'Unknown',
                              style: AppTypography.mono(
                                size: 10,
                                color: AppColors.txtSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if ((data['coins'] ?? 0) != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (data['coins'] as int) > 0
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(data['coins'] as int) > 0 ? '+' : ''}${data['coins']}💰',
                            style: AppTypography.orbitron(
                              size: 12,
                              color: (data['coins'] as int) > 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.bg3),

                // Details
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _DetailRow(
                        label: 'Player ID',
                        value: data['playerId'] ?? 'N/A',
                        icon: Icons.badge,
                      ),
                      _DetailRow(
                        label: 'Nickname',
                        value: data['nickname'] ?? 'Unknown',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Action',
                        value: data['action'] ?? 'unknown',
                        icon: Icons.polymer,
                        valueColor: _getActionColor(
                          data['action'] ?? 'unknown',
                        ),
                      ),
                      _DetailRow(
                        label: 'Detail',
                        value: data['detail'] ?? 'No details',
                        icon: Icons.description,
                      ),
                      const SizedBox(height: 12),
                      if ((data['coins'] ?? 0) != 0)
                        _DetailRow(
                          label: 'Coins Change',
                          value:
                              '${(data['coins'] as int) > 0 ? '+' : ''}${data['coins']}',
                          icon: Icons.monetization_on,
                          valueColor: (data['coins'] as int) > 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      if ((data['xp'] ?? 0) != 0)
                        _DetailRow(
                          label: 'XP Change',
                          value:
                              '${(data['xp'] as int) > 0 ? '+' : ''}${data['xp']}',
                          icon: Icons.star,
                          valueColor: (data['xp'] as int) > 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Timestamp',
                        value: _formatDate(data['timestamp'] as Timestamp?),
                        icon: Icons.access_time,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.rajdhani(color: Colors.white),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter and Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.bg2,
          child: Column(
            children: [
              // Search and Actions
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.rajdhani(
                        size: 13,
                        color: AppColors.txtPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by player ID, nickname, or detail...',
                        hintStyle: AppTypography.rajdhani(
                          size: 12,
                          color: AppColors.txtSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.neonBlue,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AppColors.bg3,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Clear old logs button
                  GestureDetector(
                    onTap: _clearOldLogs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_sweep,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'CLEAR OLD',
                            style: AppTypography.orbitron(
                              size: 9,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Export button
                  GestureDetector(
                    onTap: () async {
                      final snapshot = await FirebaseFirestore.instance
                          .collection('activityLogs')
                          .orderBy('timestamp', descending: true)
                          .limit(1000)
                          .get();
                      _exportLogs(snapshot.docs);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.neonGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.download,
                            color: AppColors.neonGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'EXPORT',
                            style: AppTypography.orbitron(
                              size: 9,
                              color: AppColors.neonGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _actionFilters.map((action) {
                    final isSelected = _filterAction == action;
                    final color = _getActionColor(action);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filterAction = action),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.2)
                                : AppColors.bg3,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : AppColors.neonBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getActionIcon(action),
                                color: isSelected
                                    ? color
                                    : AppColors.txtSecondary,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _filterLabels[action] ?? action.toUpperCase(),
                                style: AppTypography.rajdhani(
                                  size: 10,
                                  color: isSelected
                                      ? color
                                      : AppColors.txtSecondary,
                                  weight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Stats Summary
        StreamBuilder<QuerySnapshot>(
          stream: AdminFirestoreService.getActivityLogsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            final docs = snapshot.data!.docs;
            final totalLogs = docs.length;
            final wins = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['action'] == 'win';
            }).length;
            final purchases = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['action'] == 'purchase';
            }).length;
            final totalCoins = docs.fold<int>(0, (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              return sum + ((data['coins'] as int?)?.abs() ?? 0);
            });

            return Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Logs',
                      value: '$totalLogs',
                      icon: Icons.history,
                      color: AppColors.neonBlue,
                      subtitle: 'Last 200 entries',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Wins',
                      value: '$wins',
                      icon: Icons.emoji_events,
                      color: AppColors.neonGold,
                      subtitle: 'Game victories',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Purchases',
                      value: '$purchases',
                      icon: Icons.shopping_cart,
                      color: AppColors.neonPurple,
                      subtitle: 'Marketplace buys',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Coin Flow',
                      value: '$totalCoins',
                      icon: Icons.monetization_on,
                      color: AppColors.neonGreen,
                      subtitle: 'Total coins moved',
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Activity Logs List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: AdminFirestoreService.getActivityLogsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.neonBlue),
                );
              }

              if (snapshot.hasError) {
                return _ErrorState(
                  message: 'Failed to load activity logs',
                  onRetry: () => setState(() {}),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // Apply filters
              var filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                if (_filterAction != 'all' && data['action'] != _filterAction) {
                  return false;
                }
                if (_searchQuery.isNotEmpty) {
                  final playerId = (data['playerId'] ?? '')
                      .toString()
                      .toLowerCase();
                  final nickname = (data['nickname'] ?? '')
                      .toString()
                      .toLowerCase();
                  final detail = (data['detail'] ?? '')
                      .toString()
                      .toLowerCase();
                  return playerId.contains(_searchQuery) ||
                      nickname.contains(_searchQuery) ||
                      detail.contains(_searchQuery);
                }
                return true;
              }).toList();

              if (filteredDocs.isEmpty) {
                return _EmptyState(
                  icon: Icons.history,
                  message: _searchQuery.isNotEmpty
                      ? 'No logs match your search'
                      : 'No activity logs found',
                );
              }

              // Group by date
              final Map<String, List<QueryDocumentSnapshot>> groupedLogs = {};
              for (final doc in filteredDocs) {
                final data = doc.data() as Map<String, dynamic>;
                final dateGroup = _getRelativeDateGroup(
                  data['timestamp'] as Timestamp?,
                );
                if (!groupedLogs.containsKey(dateGroup)) {
                  groupedLogs[dateGroup] = [];
                }
                groupedLogs[dateGroup]!.add(doc);
              }

              final sortedDates = groupedLogs.keys.toList()
                ..sort((a, b) {
                  const order = ['Today', 'Yesterday', 'This Week'];
                  final indexA = order.indexOf(a);
                  final indexB = order.indexOf(b);
                  if (indexA != -1 && indexB != -1)
                    return indexA.compareTo(indexB);
                  if (indexA != -1) return -1;
                  if (indexB != -1) return 1;
                  return b.compareTo(a);
                });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final dateGroup = sortedDates[index];
                  final logs = groupedLogs[dateGroup]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          dateGroup,
                          style: AppTypography.orbitron(
                            size: 12,
                            color: AppColors.neonGold,
                          ),
                        ),
                      ),
                      // Logs for this date
                      ...logs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final action = data['action'] ?? 'unknown';
                        final color = _getActionColor(action);
                        final icon = _getActionIcon(action);
                        final coinChange = data['coins'] as int? ?? 0;

                        return GestureDetector(
                          onTap: () => _showLogDetails(data),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: _GlassCard(
                              borderColor: color,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Action icon
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: color.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Icon(icon, color: color, size: 20),
                                    ),
                                    const SizedBox(width: 12),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['nickname'] ?? 'Unknown',
                                            style: AppTypography.orbitron(
                                              size: 12,
                                              color: AppColors.txtPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            data['detail'] ?? 'No details',
                                            style: AppTypography.rajdhani(
                                              size: 11,
                                              color: AppColors.txtSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  action.toUpperCase(),
                                                  style: AppTypography.orbitron(
                                                    size: 8,
                                                    color: color,
                                                  ),
                                                ),
                                              ),
                                              if (coinChange != 0) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: coinChange > 0
                                                        ? AppColors.success
                                                              .withOpacity(0.1)
                                                        : AppColors.error
                                                              .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${coinChange > 0 ? '+' : ''}$coinChange💰',
                                                    style:
                                                        AppTypography.orbitron(
                                                          size: 8,
                                                          color: coinChange > 0
                                                              ? AppColors
                                                                    .success
                                                              : AppColors.error,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Time
                                    Text(
                                      _formatDate(
                                        data['timestamp'] as Timestamp?,
                                      ),
                                      style: AppTypography.mono(
                                        size: 10,
                                        color: AppColors.txtSecondary,
                                      ),
                                    ),

                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.txtSecondary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      if (index != sortedDates.length - 1)
                        const Divider(color: AppColors.bg3, height: 24),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsSection extends StatefulWidget {
  const SettingsSection({super.key});

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  bool _isLoading = true;
  bool _isSaving = false;

  // App Settings
  bool _maintenanceMode = false;
  bool _registrationEnabled = true;
  bool _dailyRewardEnabled = true;
  bool _pvpEnabled = true;
  bool _marketplaceEnabled = true;
  bool _leaderboardEnabled = true;
  bool _chatEnabled = true;
  bool _notificationsEnabled = true;

  // Game Settings
  int _defaultCoins = 100;
  int _dailyRewardBase = 50;
  int _referralBonus = 100;
  int _maxLoginAttempts = 5;
  int _sessionTimeout = 30;

  // Security Settings
  bool _twoFactorRequired = false;
  bool _emailVerificationRequired = false;
  bool _adminApprovalRequired = false;
  int _pinExpiryDays = 90;

  // Economy Settings
  double _coinToXpRate = 1.0;
  int _maxDailyEarnings = 5000;
  int _gameWinBaseCoins = 30;
  int _gameWinBaseXp = 50;

  // Text Controllers
  final TextEditingController _defaultCoinsController = TextEditingController();
  final TextEditingController _dailyRewardBaseController =
      TextEditingController();
  final TextEditingController _referralBonusController =
      TextEditingController();
  final TextEditingController _maxLoginAttemptsController =
      TextEditingController();
  final TextEditingController _sessionTimeoutController =
      TextEditingController();
  final TextEditingController _pinExpiryDaysController =
      TextEditingController();
  final TextEditingController _coinToXpRateController = TextEditingController();
  final TextEditingController _maxDailyEarningsController =
      TextEditingController();
  final TextEditingController _gameWinBaseCoinsController =
      TextEditingController();
  final TextEditingController _gameWinBaseXpController =
      TextEditingController();
  final TextEditingController _appVersionController = TextEditingController();
  final TextEditingController _minAppVersionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _defaultCoinsController.dispose();
    _dailyRewardBaseController.dispose();
    _referralBonusController.dispose();
    _maxLoginAttemptsController.dispose();
    _sessionTimeoutController.dispose();
    _pinExpiryDaysController.dispose();
    _coinToXpRateController.dispose();
    _maxDailyEarningsController.dispose();
    _gameWinBaseCoinsController.dispose();
    _gameWinBaseXpController.dispose();
    _appVersionController.dispose();
    _minAppVersionController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await AdminFirestoreService.getAppSettings();

      _maintenanceMode = settings['maintenanceMode'] ?? false;
      _registrationEnabled = settings['registrationEnabled'] ?? true;
      _dailyRewardEnabled = settings['dailyRewardEnabled'] ?? true;
      _pvpEnabled = settings['pvpEnabled'] ?? true;
      _marketplaceEnabled = settings['marketplaceEnabled'] ?? true;
      _leaderboardEnabled = settings['leaderboardEnabled'] ?? true;
      _chatEnabled = settings['chatEnabled'] ?? true;
      _notificationsEnabled = settings['notificationsEnabled'] ?? true;

      _defaultCoins = settings['defaultCoins'] ?? 100;
      _dailyRewardBase = settings['dailyRewardBase'] ?? 50;
      _referralBonus = settings['referralBonus'] ?? 100;
      _maxLoginAttempts = settings['maxLoginAttempts'] ?? 5;
      _sessionTimeout = settings['sessionTimeout'] ?? 30;

      _twoFactorRequired = settings['twoFactorRequired'] ?? false;
      _emailVerificationRequired =
          settings['emailVerificationRequired'] ?? false;
      _adminApprovalRequired = settings['adminApprovalRequired'] ?? false;
      _pinExpiryDays = settings['pinExpiryDays'] ?? 90;

      _coinToXpRate = (settings['coinToXpRate'] ?? 1.0).toDouble();
      _maxDailyEarnings = settings['maxDailyEarnings'] ?? 5000;
      _gameWinBaseCoins = settings['gameWinBaseCoins'] ?? 30;
      _gameWinBaseXp = settings['gameWinBaseXp'] ?? 50;

      // Set controller values
      _defaultCoinsController.text = _defaultCoins.toString();
      _dailyRewardBaseController.text = _dailyRewardBase.toString();
      _referralBonusController.text = _referralBonus.toString();
      _maxLoginAttemptsController.text = _maxLoginAttempts.toString();
      _sessionTimeoutController.text = _sessionTimeout.toString();
      _pinExpiryDaysController.text = _pinExpiryDays.toString();
      _coinToXpRateController.text = _coinToXpRate.toString();
      _maxDailyEarningsController.text = _maxDailyEarnings.toString();
      _gameWinBaseCoinsController.text = _gameWinBaseCoins.toString();
      _gameWinBaseXpController.text = _gameWinBaseXp.toString();
      _appVersionController.text = settings['appVersion'] ?? '2.0.0';
      _minAppVersionController.text = settings['minAppVersion'] ?? '1.0.0';
    } catch (e) {
      _showSnackBar('Error loading settings: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    final settings = {
      'maintenanceMode': _maintenanceMode,
      'registrationEnabled': _registrationEnabled,
      'dailyRewardEnabled': _dailyRewardEnabled,
      'pvpEnabled': _pvpEnabled,
      'marketplaceEnabled': _marketplaceEnabled,
      'leaderboardEnabled': _leaderboardEnabled,
      'chatEnabled': _chatEnabled,
      'notificationsEnabled': _notificationsEnabled,
      'defaultCoins': int.tryParse(_defaultCoinsController.text) ?? 100,
      'dailyRewardBase': int.tryParse(_dailyRewardBaseController.text) ?? 50,
      'referralBonus': int.tryParse(_referralBonusController.text) ?? 100,
      'maxLoginAttempts': int.tryParse(_maxLoginAttemptsController.text) ?? 5,
      'sessionTimeout': int.tryParse(_sessionTimeoutController.text) ?? 30,
      'twoFactorRequired': _twoFactorRequired,
      'emailVerificationRequired': _emailVerificationRequired,
      'adminApprovalRequired': _adminApprovalRequired,
      'pinExpiryDays': int.tryParse(_pinExpiryDaysController.text) ?? 90,
      'coinToXpRate': double.tryParse(_coinToXpRateController.text) ?? 1.0,
      'maxDailyEarnings':
          int.tryParse(_maxDailyEarningsController.text) ?? 5000,
      'gameWinBaseCoins': int.tryParse(_gameWinBaseCoinsController.text) ?? 30,
      'gameWinBaseXp': int.tryParse(_gameWinBaseXpController.text) ?? 50,
      'appVersion': _appVersionController.text.trim(),
      'minAppVersion': _minAppVersionController.text.trim(),
    };

    try {
      await AdminFirestoreService.updateAppSettings(settings);
      _showSnackBar('Settings saved successfully!', AppColors.success);
      await _loadSettings(); // Reload to refresh
    } catch (e) {
      _showSnackBar('Error saving settings: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          'Reset Settings',
          style: AppTypography.orbitron(color: AppColors.warning),
        ),
        content: Text(
          'Are you sure you want to reset all settings to default values?',
          style: AppTypography.rajdhani(color: AppColors.txtPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.rajdhani(color: AppColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Reset',
              style: AppTypography.orbitron(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _maintenanceMode = false;
      _registrationEnabled = true;
      _dailyRewardEnabled = true;
      _pvpEnabled = true;
      _marketplaceEnabled = true;
      _leaderboardEnabled = true;
      _chatEnabled = true;
      _notificationsEnabled = true;
      _defaultCoins = 100;
      _dailyRewardBase = 50;
      _referralBonus = 100;
      _maxLoginAttempts = 5;
      _sessionTimeout = 30;
      _twoFactorRequired = false;
      _emailVerificationRequired = false;
      _adminApprovalRequired = false;
      _pinExpiryDays = 90;
      _coinToXpRate = 1.0;
      _maxDailyEarnings = 5000;
      _gameWinBaseCoins = 30;
      _gameWinBaseXp = 50;

      _defaultCoinsController.text = '100';
      _dailyRewardBaseController.text = '50';
      _referralBonusController.text = '100';
      _maxLoginAttemptsController.text = '5';
      _sessionTimeoutController.text = '30';
      _pinExpiryDaysController.text = '90';
      _coinToXpRateController.text = '1.0';
      _maxDailyEarningsController.text = '5000';
      _gameWinBaseCoinsController.text = '30';
      _gameWinBaseXpController.text = '50';

      setState(() {});
      _showSnackBar('Settings reset to default', AppColors.success);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.rajdhani(color: Colors.white),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.neonBlue),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header with Save Button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'SYSTEM CONFIGURATION',
                      style: AppTypography.orbitron(
                        size: 16,
                        color: AppColors.neonGold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _resetToDefault,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'RESET',
                            style: AppTypography.orbitron(
                              size: 10,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _saveSettings,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.neonGold, AppColors.neonOrange],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.save, color: Colors.black, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'SAVE ALL',
                            style: AppTypography.orbitron(
                              size: 10,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // App Settings
              _SettingsCard(
                title: 'APP SETTINGS',
                icon: Icons.app_settings_alt,
                color: AppColors.neonBlue,
                children: [
                  _ToggleRow(
                    label: 'Maintenance Mode',
                    value: _maintenanceMode,
                    onChanged: (val) => setState(() => _maintenanceMode = val),
                    subtitle: 'When enabled, users cannot access the app',
                    color: _maintenanceMode
                        ? AppColors.warning
                        : AppColors.txtSecondary,
                  ),
                  _ToggleRow(
                    label: 'Registration Enabled',
                    value: _registrationEnabled,
                    onChanged: (val) =>
                        setState(() => _registrationEnabled = val),
                    subtitle: 'Allow new users to create accounts',
                    color: AppColors.neonGreen,
                  ),
                  _ToggleRow(
                    label: 'Daily Rewards',
                    value: _dailyRewardEnabled,
                    onChanged: (val) =>
                        setState(() => _dailyRewardEnabled = val),
                    subtitle: 'Enable daily login rewards',
                    color: AppColors.neonGold,
                  ),
                  _ToggleRow(
                    label: 'PVP Mode',
                    value: _pvpEnabled,
                    onChanged: (val) => setState(() => _pvpEnabled = val),
                    subtitle: 'Enable player vs player battles',
                    color: AppColors.neonPurple,
                  ),
                  _ToggleRow(
                    label: 'Marketplace',
                    value: _marketplaceEnabled,
                    onChanged: (val) =>
                        setState(() => _marketplaceEnabled = val),
                    subtitle: 'Enable item shop and trading',
                    color: AppColors.neonOrange,
                  ),
                  _ToggleRow(
                    label: 'Leaderboard',
                    value: _leaderboardEnabled,
                    onChanged: (val) =>
                        setState(() => _leaderboardEnabled = val),
                    subtitle: 'Show global rankings',
                    color: AppColors.neonGold,
                  ),
                  _ToggleRow(
                    label: 'Chat System',
                    value: _chatEnabled,
                    onChanged: (val) => setState(() => _chatEnabled = val),
                    subtitle: 'Enable in-game chat',
                    color: AppColors.neonCyan,
                  ),
                  _ToggleRow(
                    label: 'Notifications',
                    value: _notificationsEnabled,
                    onChanged: (val) =>
                        setState(() => _notificationsEnabled = val),
                    subtitle: 'Push notifications to users',
                    color: AppColors.neonPink,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Game Settings
              _SettingsCard(
                title: 'GAME ECONOMY',
                icon: Icons.games,
                color: AppColors.neonPurple,
                children: [
                  _NumberFieldRow(
                    label: 'Default Coins',
                    controller: _defaultCoinsController,
                    icon: Icons.monetization_on,
                    suffix: 'coins',
                  ),
                  _NumberFieldRow(
                    label: 'Daily Reward Base',
                    controller: _dailyRewardBaseController,
                    icon: Icons.card_giftcard,
                    suffix: 'coins',
                  ),
                  _NumberFieldRow(
                    label: 'Referral Bonus',
                    controller: _referralBonusController,
                    icon: Icons.group_add,
                    suffix: 'coins',
                  ),
                  _NumberFieldRow(
                    label: 'Game Win - Base Coins',
                    controller: _gameWinBaseCoinsController,
                    icon: Icons.emoji_events,
                    suffix: 'coins',
                  ),
                  _NumberFieldRow(
                    label: 'Game Win - Base XP',
                    controller: _gameWinBaseXpController,
                    icon: Icons.star,
                    suffix: 'XP',
                  ),
                  _NumberFieldRow(
                    label: 'Coin to XP Rate',
                    controller: _coinToXpRateController,
                    icon: Icons.auto_awesome,
                    suffix: 'X',
                    isDouble: true,
                  ),
                  _NumberFieldRow(
                    label: 'Max Daily Earnings',
                    controller: _maxDailyEarningsController,
                    icon: Icons.trending_up,
                    suffix: 'coins',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Security Settings
              _SettingsCard(
                title: 'SECURITY',
                icon: Icons.security,
                color: AppColors.neonRed,
                children: [
                  _ToggleRow(
                    label: 'Two-Factor Authentication',
                    value: _twoFactorRequired,
                    onChanged: (val) =>
                        setState(() => _twoFactorRequired = val),
                    subtitle: 'Require 2FA for login',
                    color: AppColors.neonRed,
                  ),
                  _ToggleRow(
                    label: 'Email Verification',
                    value: _emailVerificationRequired,
                    onChanged: (val) =>
                        setState(() => _emailVerificationRequired = val),
                    subtitle: 'Verify email before login',
                    color: AppColors.neonOrange,
                  ),
                  _ToggleRow(
                    label: 'Admin Approval',
                    value: _adminApprovalRequired,
                    onChanged: (val) =>
                        setState(() => _adminApprovalRequired = val),
                    subtitle: 'New accounts require admin approval',
                    color: AppColors.neonPurple,
                  ),
                  _NumberFieldRow(
                    label: 'Max Login Attempts',
                    controller: _maxLoginAttemptsController,
                    icon: Icons.login,
                    suffix: 'attempts',
                  ),
                  _NumberFieldRow(
                    label: 'Session Timeout',
                    controller: _sessionTimeoutController,
                    icon: Icons.timer,
                    suffix: 'minutes',
                  ),
                  _NumberFieldRow(
                    label: 'PIN Expiry Days',
                    controller: _pinExpiryDaysController,
                    icon: Icons.lock_clock,
                    suffix: 'days',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Version Settings
              _SettingsCard(
                title: 'VERSION CONTROL',
                icon: Icons.update,
                color: AppColors.neonCyan,
                children: [
                  _TextFieldRow(
                    label: 'App Version',
                    controller: _appVersionController,
                    icon: Icons.tag,
                    hint: 'e.g., 2.0.0',
                  ),
                  _TextFieldRow(
                    label: 'Minimum App Version',
                    controller: _minAppVersionController,
                    icon: Icons.download,
                    hint: 'e.g., 1.0.0',
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Danger Zone
              _SettingsCard(
                title: 'DANGER ZONE',
                icon: Icons.warning_amber,
                color: AppColors.error,
                children: [
                  _DangerButton(
                    label: 'Clear All User Data',
                    icon: Icons.delete_sweep,
                    color: AppColors.error,
                    onTap: () => _showDangerConfirmation('clear_all_data'),
                  ),
                  const SizedBox(height: 8),
                  _DangerButton(
                    label: 'Reset All Leaderboards',
                    icon: Icons.leaderboard,
                    color: AppColors.warning,
                    onTap: () => _showDangerConfirmation('reset_leaderboards'),
                  ),
                  const SizedBox(height: 8),
                  _DangerButton(
                    label: 'Delete All Test Accounts',
                    icon: Icons.person_remove,
                    color: AppColors.error,
                    onTap: () =>
                        _showDangerConfirmation('delete_test_accounts'),
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),

        // Loading overlay
        if (_isSaving)
          Container(
            color: Colors.black54,
            child: const Center(
              child: _GlassCard(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.neonGold),
                      SizedBox(height: 12),
                      Text('Saving settings...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDangerConfirmation(String action) {
    String title = '';
    String message = '';

    switch (action) {
      case 'clear_all_data':
        title = 'Clear All User Data';
        message =
            'This will permanently delete ALL user data including accounts, scores, and transactions. This action CANNOT be undone!';
        break;
      case 'reset_leaderboards':
        title = 'Reset Leaderboards';
        message =
            'This will reset all leaderboard rankings and stats. Are you sure?';
        break;
      case 'delete_test_accounts':
        title = 'Delete Test Accounts';
        message =
            'This will delete all accounts marked as "test". This action cannot be undone.';
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.error),
            const SizedBox(width: 8),
            Text(title, style: AppTypography.orbitron(color: AppColors.error)),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.rajdhani(color: AppColors.txtPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.rajdhani(color: AppColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _showSnackBar(
                'Action requires additional confirmation',
                AppColors.warning,
              );
            },
            child: Text(
              'Confirm',
              style: AppTypography.orbitron(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets
class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTypography.orbitron(size: 13, color: color),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.bg3, height: 1),
          // Content
          ...children,
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.rajdhani(
                    size: 13,
                    color: AppColors.txtPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.mono(
                    size: 10,
                    color: AppColors.txtSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}

class _NumberFieldRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String suffix;
  final bool isDouble;

  const _NumberFieldRow({
    required this.label,
    required this.controller,
    required this.icon,
    required this.suffix,
    this.isDouble = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Row(
              children: [
                Icon(icon, color: AppColors.neonBlue, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.rajdhani(
                    size: 12,
                    color: AppColors.txtPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: isDouble
                  ? TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              style: AppTypography.mono(size: 13, color: AppColors.neonGreen),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                suffixText: suffix,
                suffixStyle: AppTypography.mono(
                  size: 11,
                  color: AppColors.txtSecondary,
                ),
                filled: true,
                fillColor: AppColors.bg3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextFieldRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;

  const _TextFieldRow({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Row(
              children: [
                Icon(icon, color: AppColors.neonBlue, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.rajdhani(
                    size: 12,
                    color: AppColors.txtPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.mono(size: 13, color: AppColors.neonGreen),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.mono(
                  size: 11,
                  color: AppColors.txtSecondary,
                ),
                filled: true,
                fillColor: AppColors.bg3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DangerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text(label, style: AppTypography.rajdhani(size: 12, color: color)),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: AppColors.txtSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// USER DETAIL SHEET
// =============================================================================
class _UserDetailSheet extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> data;
  final VoidCallback onUpdate;

  const _UserDetailSheet({
    required this.userId,
    required this.data,
    required this.onUpdate,
  });

  @override
  State<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends State<_UserDetailSheet> {
  final _nicknameController = TextEditingController();
  final _coinsController = TextEditingController();
  final _levelController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.data['nickname'] ?? '';
    _coinsController.text = (widget.data['coins'] ?? 0).toString();
    _levelController.text = (widget.data['level'] ?? 1).toString();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _coinsController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Future<void> _saveField(String field, String value) async {
    setState(() => _isSaving = true);
    try {
      await AdminFirestoreService.updateUser(widget.userId, {field: value});
      widget.onUpdate();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Updated successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.txtSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.neonBlue, AppColors.neonPurple],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.data['avatar'] ?? '👤',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data['nickname'] ?? 'Unknown',
                            style: AppTypography.orbitron(
                              size: 18,
                              color: AppColors.txtPrimary,
                            ),
                          ),
                          Text(
                            widget.data['playerId'] ?? '',
                            style: AppTypography.mono(
                              size: 11,
                              color: AppColors.neonGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isSaving)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Editable fields
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _EditableField(
                      label: 'Nickname',
                      controller: _nicknameController,
                      onSave: () =>
                          _saveField('nickname', _nicknameController.text),
                    ),
                    const SizedBox(height: 12),
                    _EditableField(
                      label: 'Coins',
                      controller: _coinsController,
                      isNumeric: true,
                      onSave: () => _saveField(
                        'coins',
                        (int.tryParse(_coinsController.text) ?? 0) as String,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EditableField(
                      label: 'Level',
                      controller: _levelController,
                      isNumeric: true,
                      onSave: () => _saveField(
                        'level',
                        (int.tryParse(_levelController.text) ?? 1) as String,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isNumeric;
  final VoidCallback onSave;

  const _EditableField({
    required this.label,
    required this.controller,
    required this.onSave,
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: AppTypography.rajdhani(
              size: 13,
              color: AppColors.txtPrimary,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: AppTypography.mono(
                size: 11,
                color: AppColors.neonBlue,
              ),
              filled: true,
              fillColor: AppColors.bg3,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSave,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
            ),
            child: const Icon(Icons.save, color: AppColors.neonGreen, size: 18),
          ),
        ),
      ],
    );
  }
}
