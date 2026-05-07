// ============================================================
// BEEDI COLLEGE ANONYMOUS CHAT SYSTEM — UPGRADED v2.0
// Single-file Flutter App | Firebase Firestore + Auth
// Theme: White + Green + Blue | Glassmorphism | Premium UI
// PIN Security System | Admin Panel | Advanced Features
// ============================================================
// SETUP INSTRUCTIONS:
// 1. Add to pubspec.yaml:
//    dependencies:
//      flutter: sdk: flutter
//      firebase_core: ^3.6.0
//      firebase_auth: ^5.3.1
//      cloud_firestore: ^5.4.4
//      provider: ^6.1.2
//      flutter_animate: ^4.5.0
//      google_fonts: ^6.2.1
//      intl: ^0.19.0
//      cached_network_image: ^3.4.1
//      shared_preferences: ^2.3.2
//      uuid: ^4.4.2
//      crypto: ^3.0.3
// 2. Run: flutter pub get
// 3. Configure Firebase project and add google-services.json (Android)
//    and GoogleService-Info.plist (iOS)
// 4. Enable Email/Password Auth in Firebase Console
// 5. Create Firestore database in Firebase Console
// 6. Place your logo at: assets/Logoes/Logo.png
// ============================================================

import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

// ============================================================
// CONSTANTS & SECURITY CONFIG
// ============================================================

class _SecurityConfig {
  // Admin secret passcode (hidden — never expose to students)
  static const String _adminPinHash =
      'a3b6c9d2e5f8a1b4c7d0e3f6a9b2c5d8e1f4a7b0c3d6e9f2a5b8c1d4e7f0a3b6';
  static const String adminPin = 'ADMIN2026';
  static const String adminEmail = 'admin@beedicollege.edu';
  static const String adminPassword = 'BeediAdmin@2026#Secure';
  static const String studentEmailSuffix = '@beedicollege.edu';
  static const String studentPasswordPrefix = 'BeediStudent@Secure#';
  static const int maxMessageLength = 1000;
  static const int minMessageLength = 1;
  static const int rateLimitSeconds = 2;
  static const int maxMessagesPerMinute = 20;
  static const int pinLength = 5;
  static const int maxPinGenerationRetries = 10;
  static const String pinnedMessageCollection = 'pinned_messages';
  static const String adminAnnouncementField = 'admin_announcement';

  static bool isValidAdminPin(String pin) => pin.trim().toUpperCase() == adminPin;

  static String hashPin(String pin) {
    final bytes = utf8.encode(pin + '_beedi_salt_2026');
    return sha256.convert(bytes).toString();
  }

  static String sanitizeMessage(String msg) {
    return msg
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'[^\x09\x0A\x0D\x20-\x7E\u00A0-\uFFFF]'), '')
        .substring(0, msg.trim().length.clamp(0, maxMessageLength));
  }

  static bool isValidMessage(String msg) {
    final s = msg.trim();
    return s.length >= minMessageLength && s.length <= maxMessageLength;
  }
}

// ============================================================
// THEME & COLORS
// ============================================================

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF2E7D32);
  static const Color secondaryLight = Color(0xFF66BB6A);
  static const Color accent = Color(0xFF00ACC1);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FFFE);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF0F7FF);
  static const Color textDark = Color(0xFF1A237E);
  static const Color textMed = Color(0xFF546E7A);
  static const Color textLight = Color(0xFF90A4AE);
  static const Color bubbleMe = Color(0xFFE3F2FD);
  static const Color bubbleOther = Color(0xFFF1F8E9);
  static const Color adminBubble = Color(0xFF1565C0);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color adminGlow = Color(0x401565C0);

  static const List<Color> avatarColors = [
    Color(0xFF7C4DFF),
    Color(0xFFFF5252),
    Color(0xFF00BCD4),
    Color(0xFFFF6D00),
    Color(0xFF4CAF50),
    Color(0xFFE91E63),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00897B),
    Color(0xFFD84315),
    Color(0xFF00695C),
  ];

  static LinearGradient get adminBubbleGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF1A237E)],
      );

  static LinearGradient get appBarGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D47A1), Color(0xFF1B5E20), Color(0xFF006064)],
      );

  static LinearGradient get splashGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D47A1), Color(0xFF1B5E20), Color(0xFF006064)],
      );
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
}

// ============================================================
// MODELS
// ============================================================

class StudentModel {
  final String uid;
  final String realName;
  final String pin;
  final String batch;
  final bool isAdmin;
  final bool isBanned;
  final bool isMuted;
  final DateTime createdAt;
  final DateTime? pinExpiry;
  final bool pinActive;

  StudentModel({
    required this.uid,
    required this.realName,
    required this.pin,
    required this.batch,
    required this.isAdmin,
    this.isBanned = false,
    this.isMuted = false,
    required this.createdAt,
    this.pinExpiry,
    this.pinActive = true,
  });

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      uid: doc.id,
      realName: data['realName'] ?? '',
      pin: data['pin'] ?? '',
      batch: data['batch'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      isBanned: data['isBanned'] ?? false,
      isMuted: data['isMuted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pinExpiry: (data['pinExpiry'] as Timestamp?)?.toDate(),
      pinActive: data['pinActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'realName': realName,
        'pin': pin,
        'batch': batch,
        'isAdmin': isAdmin,
        'isBanned': isBanned,
        'isMuted': isMuted,
        'createdAt': Timestamp.fromDate(createdAt),
        'pinExpiry': pinExpiry != null ? Timestamp.fromDate(pinExpiry!) : null,
        'pinActive': pinActive,
      };

  bool get isPinExpired =>
      pinExpiry != null && DateTime.now().isAfter(pinExpiry!);
}

class PinModel {
  final String pin;
  final String batch;
  final bool isActive;
  final bool isUsed;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String createdBy;

  PinModel({
    required this.pin,
    required this.batch,
    required this.isActive,
    required this.isUsed,
    required this.createdAt,
    this.expiresAt,
    required this.createdBy,
  });

  factory PinModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PinModel(
      pin: data['pin'] ?? doc.id,
      batch: data['batch'] ?? '',
      isActive: data['isActive'] ?? true,
      isUsed: data['isUsed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] ?? 'ADMIN',
    );
  }

  Map<String, dynamic> toMap() => {
        'pin': pin,
        'batch': batch,
        'isActive': isActive,
        'isUsed': isUsed,
        'createdAt': Timestamp.fromDate(createdAt),
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
        'createdBy': createdBy,
      };
}

class ChatMessage {
  final String messageId;
  final String senderPin;
  final String senderType;
  final String message;
  final DateTime timestamp;
  final String? replyMessage;
  final String? replySenderPin;
  final String? replyMessageId;
  final Map<String, List<String>> reactions;
  final bool isDeleted;
  final List<String> seenBy;
  final bool isPinned;

  ChatMessage({
    required this.messageId,
    required this.senderPin,
    required this.senderType,
    required this.message,
    required this.timestamp,
    this.replyMessage,
    this.replySenderPin,
    this.replyMessageId,
    this.reactions = const {},
    this.isDeleted = false,
    this.seenBy = const [],
    this.isPinned = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      messageId: doc.id,
      senderPin: data['senderPin'] ?? '',
      senderType: data['senderType'] ?? 'student',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      replyMessage: data['replyMessage'],
      replySenderPin: data['replySenderPin'],
      replyMessageId: data['replyMessageId'],
      reactions: Map<String, List<String>>.from(
        (data['reactions'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, List<String>.from(v ?? [])),
        ),
      ),
      isDeleted: data['isDeleted'] ?? false,
      seenBy: List<String>.from(data['seenBy'] ?? []),
      isPinned: data['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'senderPin': senderPin,
        'senderType': senderType,
        'message': message,
        'timestamp': Timestamp.fromDate(timestamp),
        'replyMessage': replyMessage,
        'replySenderPin': replySenderPin,
        'replyMessageId': replyMessageId,
        'reactions': reactions,
        'isDeleted': isDeleted,
        'seenBy': seenBy,
        'isPinned': isPinned,
      };
}

// ============================================================
// PROVIDERS
// ============================================================

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class AuthProvider extends ChangeNotifier {
  StudentModel? _currentStudent;
  bool _isLoading = false;
  String? _error;
  bool _isAdminVerified = false;

  StudentModel? get currentStudent => _currentStudent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _currentStudent?.isAdmin ?? false;
  bool get isAdminVerified => _isAdminVerified;
  bool get isLoggedIn => _currentStudent != null;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Rate limiting
  final Map<String, List<DateTime>> _loginAttempts = {};

  bool _isRateLimited(String identifier) {
    final now = DateTime.now();
    _loginAttempts[identifier] ??= [];
    _loginAttempts[identifier]!
        .removeWhere((t) => now.difference(t).inMinutes > 5);
    if (_loginAttempts[identifier]!.length >= 5) return true;
    _loginAttempts[identifier]!.add(now);
    return false;
  }

  Future<bool> loginWithPin(String pin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cleanPin = pin.trim().toUpperCase();

      if (_isRateLimited(cleanPin)) {
        _error = 'Too many attempts. Please wait a few minutes.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final isAdminPin = _SecurityConfig.isValidAdminPin(cleanPin);

      if (isAdminPin) {
        try {
          await _auth.signInWithEmailAndPassword(
            email: _SecurityConfig.adminEmail,
            password: _SecurityConfig.adminPassword,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
            await _auth.createUserWithEmailAndPassword(
              email: _SecurityConfig.adminEmail,
              password: _SecurityConfig.adminPassword,
            );
          }
        }

        final uid = _auth.currentUser!.uid;
        final doc = await _db.collection('students').doc(uid).get();
        if (!doc.exists) {
          await _db.collection('students').doc(uid).set({
            'uid': uid,
            'realName': 'BEEDI Admin',
            'pin': _SecurityConfig.adminPin,
            'batch': 'ADMIN',
            'isAdmin': true,
            'isBanned': false,
            'isMuted': false,
            'pinActive': true,
            'createdAt': Timestamp.now(),
          });
        }

        // Verify admin doc in Firestore
        final adminDoc = await _db.collection('admin_config').doc('admin_meta').get();
        if (!adminDoc.exists) {
          await _db.collection('admin_config').doc('admin_meta').set({
            'adminUid': uid,
            'adminPin': _SecurityConfig.hashPin(_SecurityConfig.adminPin),
            'createdAt': Timestamp.now(),
          });
        }

        _currentStudent = StudentModel(
          uid: uid,
          realName: 'BEEDI Admin',
          pin: _SecurityConfig.adminPin,
          batch: 'ADMIN',
          isAdmin: true,
          createdAt: DateTime.now(),
        );
        _isAdminVerified = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Student PIN login — validate against admin_pins collection first
      final pinDoc = await _db.collection('admin_pins').doc(cleanPin).get();
      bool pinIsValid = false;

      if (pinDoc.exists) {
        final pinData = pinDoc.data() as Map<String, dynamic>;
        final isActive = pinData['isActive'] ?? true;
        final expiresAt = (pinData['expiresAt'] as Timestamp?)?.toDate();
        final isExpired = expiresAt != null && DateTime.now().isAfter(expiresAt);
        pinIsValid = isActive && !isExpired;
      }

      // Also check students collection for backward compatibility
      final query = await _db
          .collection('students')
          .where('pin', isEqualTo: cleanPin)
          .where('isAdmin', isEqualTo: false)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _error = 'Invalid PIN. Please check and try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final studentData = query.docs.first;
      final data = studentData.data();

      if (data['isBanned'] == true) {
        _error = 'Your account has been banned. Contact admin.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (data['isMuted'] == true) {
        // Allow login but note muted status
      }

      if (data['pinActive'] == false) {
        _error = 'Your PIN has been deactivated. Contact admin.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check PIN expiry
      final pinExpiry = (data['pinExpiry'] as Timestamp?)?.toDate();
      if (pinExpiry != null && DateTime.now().isAfter(pinExpiry)) {
        _error = 'Your PIN has expired. Contact admin for a new PIN.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      try {
        final email =
            '${cleanPin.toLowerCase()}${_SecurityConfig.studentEmailSuffix}';
        final password = '${_SecurityConfig.studentPasswordPrefix}${cleanPin}';
        try {
          await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
            await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
          }
        }
      } catch (_) {
        await _auth.signInAnonymously();
      }

      _currentStudent = StudentModel.fromFirestore(studentData);

      // Mark PIN as used in admin_pins
      if (pinDoc.exists) {
        await _db.collection('admin_pins').doc(cleanPin).update({'isUsed': true});
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_pin', cleanPin);
      await prefs.setString('saved_pin_hash', _SecurityConfig.hashPin(cleanPin));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> registerStudent({
    required String realName,
    required String batch,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Students cannot self-generate PINs anymore in upgraded system
      // This path only works if an admin-generated PIN is available
      // For backward compatibility, this still works
      final pin = _generateSecurePin();
      await _ensurePinUnique(pin);

      final email =
          '${pin.toLowerCase()}${_SecurityConfig.studentEmailSuffix}';
      final password = '${_SecurityConfig.studentPasswordPrefix}${pin}';

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = _auth.currentUser!.uid;
      final studentData = {
        'uid': uid,
        'realName': realName,
        'pin': pin,
        'batch': batch,
        'isAdmin': false,
        'isBanned': false,
        'isMuted': false,
        'pinActive': true,
        'createdAt': Timestamp.now(),
      };

      await _db.collection('students').doc(uid).set(studentData);

      _currentStudent = StudentModel(
        uid: uid,
        realName: realName,
        pin: pin,
        batch: batch,
        isAdmin: false,
        createdAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_pin', pin);
      await prefs.setString('saved_pin_hash', _SecurityConfig.hashPin(pin));
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  String _generateSecurePin() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const digits = '0123456789';
    final rand = Random.secure();
    final letter = letters[rand.nextInt(letters.length)];
    final number =
        List.generate(4, (_) => digits[rand.nextInt(digits.length)]).join();
    return '$letter$number';
  }

  Future<void> _ensurePinUnique(String pin) async {
    final existing = await FirebaseFirestore.instance
        .collection('students')
        .where('pin', isEqualTo: pin)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) throw Exception('PIN collision, retry');

    final pinDoc = await FirebaseFirestore.instance
        .collection('admin_pins')
        .doc(pin)
        .get();
    if (pinDoc.exists) throw Exception('PIN already exists');
  }

  Future<String?> getSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('saved_pin');
    final hash = prefs.getString('saved_pin_hash');
    if (pin == null || hash == null) return null;
    // Verify hash integrity
    if (_SecurityConfig.hashPin(pin) != hash) {
      await prefs.remove('saved_pin');
      await prefs.remove('saved_pin_hash');
      return null;
    }
    return pin;
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentStudent = null;
    _isAdminVerified = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_pin');
    await prefs.remove('saved_pin_hash');
    notifyListeners();
  }
}

// ============================================================
// ADMIN PIN MANAGER PROVIDER
// ============================================================

class AdminPinProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _error;
  List<PinModel> _generatedPins = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PinModel> get generatedPins => _generatedPins;

  static const String _pinCollection = 'admin_pins';

  String _generateSecurePin() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const digits = '0123456789';
    final rand = Random.secure();
    final letter = letters[rand.nextInt(letters.length)];
    final number =
        List.generate(4, (_) => digits[rand.nextInt(digits.length)]).join();
    return '$letter$number';
  }

  Future<bool> _isPinDuplicate(String pin) async {
    final pinDoc = await _db.collection(_pinCollection).doc(pin).get();
    if (pinDoc.exists) return true;
    final studentQuery = await _db
        .collection('students')
        .where('pin', isEqualTo: pin)
        .limit(1)
        .get();
    return studentQuery.docs.isNotEmpty;
  }

  Future<String?> generateUniquePin() async {
    for (int i = 0; i < _SecurityConfig.maxPinGenerationRetries; i++) {
      final pin = _generateSecurePin();
      final isDup = await _isPinDuplicate(pin);
      if (!isDup) return pin;
    }
    return null;
  }

  Future<List<String>> generateBatchPins({
    required int count,
    required String batch,
    required String adminPin,
    DateTime? expiresAt,
  }) async {
    if (!_SecurityConfig.isValidAdminPin(adminPin)) {
      _error = 'Unauthorized: Admin PIN required.';
      notifyListeners();
      return [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final generatedList = <String>[];
    final batch_ = _db.batch();

    try {
      for (int i = 0; i < count; i++) {
        final pin = await generateUniquePin();
        if (pin == null) {
          _error = 'Could not generate unique PIN after retries.';
          break;
        }
        final pinRef = _db.collection(_pinCollection).doc(pin);
        batch_.set(pinRef, {
          'pin': pin,
          'batch': batch,
          'isActive': true,
          'isUsed': false,
          'createdAt': Timestamp.now(),
          'expiresAt':
              expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
          'createdBy': 'ADMIN',
          'pinHash': _SecurityConfig.hashPin(pin),
        });
        generatedList.add(pin);
      }

      await batch_.commit();
      await loadPins();
    } catch (e) {
      _error = 'Failed to generate PINs: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return generatedList;
  }

  Future<void> togglePinActive(String pin, bool active) async {
    await _db.collection(_pinCollection).doc(pin).update({'isActive': active});
    await loadPins();
  }

  Future<void> deletePin(String pin) async {
    await _db.collection(_pinCollection).doc(pin).delete();
    await loadPins();
  }

  Future<void> loadPins() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _db
          .collection(_pinCollection)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      _generatedPins = snap.docs.map((d) => PinModel.fromFirestore(d)).toList();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Stream<QuerySnapshot> pinsStream() => _db
      .collection(_pinCollection)
      .orderBy('createdAt', descending: true)
      .snapshots();
}

// ============================================================
// CHAT PROVIDER
// ============================================================

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  ChatMessage? _replyingTo;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  String _currentRoom = 'general';
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;
  Map<String, bool> _typingUsers = {};
  String _searchQuery = '';
  List<ChatMessage> _searchResults = [];
  bool _isSearching = false;
  ChatMessage? _pinnedMessage;
  String? _adminAnnouncement;

  // Rate limiting
  final Map<String, List<DateTime>> _messageTimes = {};

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  ChatMessage? get replyingTo => _replyingTo;
  bool get hasMore => _hasMore;
  String get currentRoom => _currentRoom;
  Map<String, bool> get typingUsers => _typingUsers;
  List<ChatMessage> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  ChatMessage? get pinnedMessage => _pinnedMessage;
  String? get adminAnnouncement => _adminAnnouncement;

  static const int pageSize = 30;

  bool _isRateLimited(String senderPin) {
    final now = DateTime.now();
    _messageTimes[senderPin] ??= [];
    _messageTimes[senderPin]!
        .removeWhere((t) => now.difference(t).inSeconds > 60);
    if (_messageTimes[senderPin]!.length >= _SecurityConfig.maxMessagesPerMinute) {
      return true;
    }
    // Enforce minimum gap
    if (_messageTimes[senderPin]!.isNotEmpty) {
      final last = _messageTimes[senderPin]!.last;
      if (now.difference(last).inSeconds < _SecurityConfig.rateLimitSeconds) {
        return true;
      }
    }
    _messageTimes[senderPin]!.add(now);
    return false;
  }

  void setRoom(String room) {
    _currentRoom = room;
    _messages = [];
    _lastDocument = null;
    _hasMore = true;
    _replyingTo = null;
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _startListening();
    _startTypingListener();
    _loadPinnedMessage();
    _loadAdminAnnouncement();
    notifyListeners();
  }

  void _startListening() {
    _messageSubscription?.cancel();
    _messageSubscription = _db
        .collection('anonymous_chats')
        .doc(_currentRoom)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(pageSize)
        .snapshots()
        .listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }
      notifyListeners();
    });
  }

  void _startTypingListener() {
    _typingSubscription?.cancel();
    _typingSubscription = _db
        .collection('anonymous_chats')
        .doc(_currentRoom)
        .snapshots()
        .listen((snap) {
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>?;
      final typing = data?['typing'] as Map<String, dynamic>? ?? {};
      _typingUsers = typing.map((k, v) => MapEntry(k, v == true));
      notifyListeners();
    });
  }

  Future<void> _loadPinnedMessage() async {
    try {
      final snap = await _db
          .collection('anonymous_chats')
          .doc(_currentRoom)
          .collection('messages')
          .where('isPinned', isEqualTo: true)
          .limit(1)
          .get();
      _pinnedMessage =
          snap.docs.isNotEmpty ? ChatMessage.fromFirestore(snap.docs.first) : null;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadAdminAnnouncement() async {
    try {
      final doc = await _db
          .collection('anonymous_chats')
          .doc(_currentRoom)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        _adminAnnouncement =
            data?[_SecurityConfig.adminAnnouncementField] as String?;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> loadMoreMessages() async {
    if (!_hasMore || _isLoading || _lastDocument == null) return;
    _isLoading = true;
    notifyListeners();

    final query = await _db
        .collection('anonymous_chats')
        .doc(_currentRoom)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(pageSize)
        .get();

    if (query.docs.length < pageSize) _hasMore = false;
    if (query.docs.isNotEmpty) {
      _lastDocument = query.docs.last;
      _messages
          .addAll(query.docs.map((doc) => ChatMessage.fromFirestore(doc)));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> sendMessage({
    required String message,
    required String senderPin,
    required String senderType,
    bool isAdminSender = false,
  }) async {
    final sanitized = _SecurityConfig.sanitizeMessage(message);

    if (!_SecurityConfig.isValidMessage(sanitized)) {
      return 'Message is empty or too long.';
    }

    // Rate limit — admins bypass rate limiting
    if (!isAdminSender && _isRateLimited(senderPin)) {
      return 'You are sending messages too fast. Please slow down.';
    }

    // Security: prevent fake admin messages from students
    if (!isAdminSender && senderType == 'admin') {
      return 'Unauthorized message type.';
    }

    final data = {
      'senderPin': senderPin,
      'senderType': isAdminSender ? 'admin' : 'student',
      'message': sanitized,
      'timestamp': FieldValue.serverTimestamp(),
      'replyMessage': _replyingTo?.message,
      'replySenderPin': _replyingTo?.senderPin,
      'replyMessageId': _replyingTo?.messageId,
      'reactions': {},
      'isDeleted': false,
      'seenBy': [senderPin],
      'isPinned': false,
    };

    await _db
        .collection('anonymous_chats')
        .doc(_currentRoom)
        .collection('messages')
        .add(data);

    await _db.collection('anonymous_chats').doc(_currentRoom).set({
      'lastMessage': sanitized,
      'lastSenderPin': senderPin,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'roomId': _currentRoom,
    }, SetOptions(merge: true));

    clearReply();
    cancelTyping(senderPin);
    return null;
  }

  Future<void> deleteMessage(String messageId) async {
    await _db
        .collection('anonymous_chats')
        .doc(_currentRoom)
        .collection('messages')
        .doc(messageId)
        .update({'isDeleted': true, 'message': 'This message was deleted.'});
  }

  Future<void> pinMessage(String messageId, bool pin) async {
    // Unpin existing if pinning new
    if (pin) {
      final existing = await _db
          .collection('anonymous_chats')
          .doc(_currentRoom)
          .collection('messages')
          .where('isPinned', isEqualTo: true)
          .get();
      for (final doc in existing.docs) {
        await doc.reference.update({'isPinned': false});
      }
    }
    await _db
        .collection('anonymous_chats')
        .doc(_currentRoom)
        .collection('messages')
        .doc(messageId)
        .update({'isPinned': pin});
    await _loadPinnedMessage();
  }

  Future<void> markSeen(String messageId, String userPin) async {
    final ref = _db
        .collection('anonymous_chats')
        .doc(_currentRoom)
        .collection('messages')
        .doc(messageId);
    await ref.update({
      'seenBy': FieldValue.arrayUnion([userPin]),
    });
  }

  Future<void> addReaction(
      String messageId, String emoji, String userPin) async {
    final ref = _db
        .collection('anonymous_chats')
        .doc(_currentRoom)
        .collection('messages')
        .doc(messageId);

    await _db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final reactions = Map<String, List<String>>.from(
        (doc.data()?['reactions'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, List<String>.from(v ?? [])),
        ),
      );

      if (reactions[emoji] == null) {
        reactions[emoji] = [userPin];
      } else if (reactions[emoji]!.contains(userPin)) {
        reactions[emoji]!.remove(userPin);
        if (reactions[emoji]!.isEmpty) reactions.remove(emoji);
      } else {
        reactions[emoji]!.add(userPin);
      }

      tx.update(ref, {'reactions': reactions});
    });
  }

  void setReply(ChatMessage message) {
    _replyingTo = message;
    notifyListeners();
  }

  void clearReply() {
    _replyingTo = null;
    notifyListeners();
  }

  void updateTyping(String senderPin) {
    _typingTimer?.cancel();
    _db.collection('anonymous_chats').doc(_currentRoom).set({
      'typing': {senderPin: true},
    }, SetOptions(merge: true)).catchError((_) {});
    _typingTimer =
        Timer(const Duration(seconds: 3), () => cancelTyping(senderPin));
  }

  void cancelTyping(String senderPin) {
    _typingTimer?.cancel();
    _db.collection('anonymous_chats').doc(_currentRoom).set({
      'typing': {senderPin: false},
    }, SetOptions(merge: true)).catchError((_) {});
  }

  Future<void> searchMessages(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();

    // Search in local messages first
    _searchResults = _messages
        .where((m) =>
            !m.isDeleted &&
            m.message.toLowerCase().contains(_searchQuery))
        .toList();
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> setAdminAnnouncement(String text, String room) async {
    await _db.collection('anonymous_chats').doc(room).set({
      _SecurityConfig.adminAnnouncementField: text,
    }, SetOptions(merge: true));
    _adminAnnouncement = text;
    notifyListeners();
  }

  Future<void> banPin(String pin) async {
    final query = await _db
        .collection('students')
        .where('pin', isEqualTo: pin)
        .get();
    for (final doc in query.docs) {
      await doc.reference.update({'isBanned': true});
    }
    // Also deactivate in admin_pins
    final pinDoc = await _db.collection('admin_pins').doc(pin).get();
    if (pinDoc.exists) {
      await _db
          .collection('admin_pins')
          .doc(pin)
          .update({'isActive': false});
    }
  }

  Future<void> mutePin(String pin, bool mute) async {
    final query = await _db
        .collection('students')
        .where('pin', isEqualTo: pin)
        .get();
    for (final doc in query.docs) {
      await doc.reference.update({'isMuted': mute});
    }
  }

  Future<StudentModel?> getStudentByPin(String pin) async {
    final query = await _db
        .collection('students')
        .where('pin', isEqualTo: pin)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return StudentModel.fromFirestore(query.docs.first);
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }
}

// ============================================================
// UTILITIES
// ============================================================

class AvatarHelper {
  static Color getAvatarColor(String pin) {
    int hash = 0;
    for (final char in pin.codeUnits) {
      hash = char + ((hash << 5) - hash);
    }
    return AppColors.avatarColors[hash.abs() % AppColors.avatarColors.length];
  }

  static IconData getAvatarIcon(String pin) {
    const icons = [
      Icons.person,
      Icons.face,
      Icons.emoji_emotions,
      Icons.school,
      Icons.auto_awesome,
      Icons.psychology,
      Icons.rocket_launch,
      Icons.science,
      Icons.star,
      Icons.lightbulb,
      Icons.bolt,
      Icons.local_fire_department,
    ];
    int hash = 0;
    for (final char in pin.codeUnits) {
      hash = char + ((hash << 5) - hash);
    }
    return icons[hash.abs() % icons.length];
  }

  static String getInitial(String pin) => pin.isNotEmpty ? pin[0] : '?';
}

class TimeHelper {
  static String format(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return DateFormat.jm().format(dt);
    if (diff.inDays == 1) return 'Yesterday ${DateFormat.jm().format(dt)}';
    return DateFormat('MMM d, h:mm a').format(dt);
  }

  static String formatDate(DateTime dt) {
    final now = DateTime.now();
    if (DateFormat.yMd().format(now) == DateFormat.yMd().format(dt)) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (DateFormat.yMd().format(yesterday) == DateFormat.yMd().format(dt)) {
      return 'Yesterday';
    }
    return DateFormat('MMMM d, y').format(dt);
  }
}

// ============================================================
// APP START SCREEN
// ============================================================

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ChatProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AdminPinProvider()),
          ],
          child: const BeeediApp(),
        ),
      ),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Initializing App...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}

// ============================================================
// MAIN APP WIDGET
// ============================================================

class BeeediApp extends StatelessWidget {
  const BeeediApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, theme, __) => MaterialApp(
        title: 'BEEDI Chat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)),
    );
    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final savedPin = await authProvider.getSavedPin();
    if (savedPin != null && mounted) {
      final success = await authProvider.loginWithPin(savedPin);
      if (success && mounted) {
        _navigate();
        return;
      }
    }
    if (mounted) Navigator.pushReplacement(context, _fadeRoute(const LoginScreen()));
  }

  void _navigate() {
    final auth = context.read<AuthProvider>();
    if (auth.isAdmin) {
      Navigator.pushReplacement(context, _fadeRoute(const AdminDashboard()));
    } else {
      context.read<ChatProvider>().setRoom('general');
      Navigator.pushReplacement(context, _fadeRoute(const ChatScreen()));
    }
  }

  Route _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            // Animated background orbs
            Positioned(
              top: -80,
              right: -80,
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Colors.white.withOpacity(0.04 * _glowAnim.value),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Colors.white.withOpacity(0.03 * _glowAnim.value),
                  ),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (_, child) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white
                                    .withOpacity(0.3 * _glowAnim.value),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: child,
                        ),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/Logoes/Logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.school,
                                size: 60,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'BEEDI College',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Anonymous Student Chat',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 56),
                      _PulsatingLoader(),
                    ],
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

class _PulsatingLoader extends StatefulWidget {
  @override
  State<_PulsatingLoader> createState() => _PulsatingLoaderState();
}

class _PulsatingLoaderState extends State<_PulsatingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Opacity(
        opacity: _pulse.value,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePin = true;
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithPin(_pinController.text.trim());
    if (success && mounted) {
      if (auth.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else {
        context.read<ChatProvider>().setRoom('general');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFE8F5E9), Color(0xFFE0F7FA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: isTablet ? 480 : double.infinity),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 0 : 24,
                    vertical: 32,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _showRegister
                              ? _RegisterCard(
                                  onBack: () =>
                                      setState(() => _showRegister = false))
                              : _buildLoginCard(),
                        ],
                      ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'logo',
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/Logoes/Logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.school,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'BEEDI College',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        Text(
          'Anonymous Student Chat',
          style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textMed),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Your PIN',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Use your student PIN to access the anonymous chat.',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textMed),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _pinController,
                obscureText: _obscurePin,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. A4821',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    letterSpacing: 2,
                    color: AppColors.textLight,
                    fontSize: 16,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: Colors.white, size: 20),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePin
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textMed,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePin = !_obscurePin),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your PIN';
                  }
                  if (val.trim().toUpperCase() != 'ADMIN2026' &&
                      val.trim().length < 5) {
                    return 'Invalid PIN format';
                  }
                  return null;
                },
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(message: auth.error!),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: auth.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      )
                    : _GradientButton(
                        label: 'Enter Chat',
                        icon: Icons.login,
                        onTap: _login,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF1976D2)],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _showRegister = true),
                  child: Text(
                    "Don't have a PIN? Register",
                    style: GoogleFonts.poppins(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildPinHint(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryLight.withOpacity(0.15),
            AppColors.primaryLight.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.secondaryLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your identity stays anonymous. PIN is your only identifier in chat.',
              style:
                  GoogleFonts.poppins(fontSize: 12, color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED WIDGETS
// ============================================================

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final LinearGradient gradient;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REGISTER CARD
// ============================================================

class _RegisterCard extends StatefulWidget {
  final VoidCallback onBack;
  const _RegisterCard({required this.onBack});

  @override
  State<_RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<_RegisterCard> {
  final _nameCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _generatedPin;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _batchCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.registerStudent(
      realName: _nameCtrl.text.trim(),
      batch: _batchCtrl.text.trim(),
    );
    if (auth.currentStudent != null && mounted) {
      setState(() => _generatedPin = auth.currentStudent!.pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.1),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: _generatedPin != null
            ? _buildSuccessView()
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: widget.onBack,
                          color: AppColors.textDark,
                        ),
                        Text(
                          'Register Student',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline,
                            color: AppColors.primary),
                        labelStyle: GoogleFonts.poppins(
                            color: AppColors.textMed),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _batchCtrl,
                      decoration: InputDecoration(
                        labelText: 'Batch (e.g. 2024-25)',
                        prefixIcon: const Icon(Icons.group_outlined,
                            color: AppColors.secondary),
                        labelStyle: GoogleFonts.poppins(
                            color: AppColors.textMed),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    if (auth.error != null) ...[
                      _ErrorBanner(message: auth.error!),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: auth.isLoading
                          ? const Center(
                              child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Generate My PIN',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle,
              color: AppColors.success, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          'Registration Successful!',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Text('Your anonymous PIN is:',
            style: GoogleFonts.poppins(color: AppColors.textMed)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _generatedPin!,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Text(
            '⚠️ Save this PIN carefully. You will need it to login. We cannot recover it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.warning),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: _GradientButton(
            label: 'Enter Chat →',
            icon: Icons.arrow_forward,
            onTap: () {
              context.read<ChatProvider>().setRoom('general');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary]),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CHAT SCREEN
// ============================================================

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _showScrollButton = false;
  bool _showSearch = false;
  String _currentRoom = 'general';
  String? _sendError;
  late AnimationController _searchAnimCtrl;
  late Animation<double> _searchFade;

  final List<Map<String, String>> _rooms = [
    {'id': 'general', 'name': 'General', 'icon': '💬'},
    {'id': 'academic', 'name': 'Academic', 'icon': '📚'},
    {'id': 'sports', 'name': 'Sports', 'icon': '⚽'},
    {'id': 'events', 'name': 'Events', 'icon': '🎉'},
    {'id': 'help', 'name': 'Help Desk', 'icon': '🆘'},
  ];

  @override
  void initState() {
    super.initState();
    _searchAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchFade =
        CurvedAnimation(parent: _searchAnimCtrl, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().setRoom(_currentRoom);
    });
    _scrollCtrl.addListener(() {
      final show = _scrollCtrl.offset > 300;
      if (show != _showScrollButton) {
        setState(() => _showScrollButton = show);
      }
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    _searchCtrl.dispose();
    _searchAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();

    if (auth.currentStudent?.isMuted == true) {
      setState(() => _sendError = 'You are muted by admin.');
      return;
    }

    if (_messageCtrl.text.trim().isEmpty) return;

    final error = await chat.sendMessage(
      message: _messageCtrl.text,
      senderPin: auth.currentStudent!.pin,
      senderType: auth.isAdmin ? 'admin' : 'student',
      isAdminSender: auth.isAdmin,
    );

    if (error != null) {
      setState(() => _sendError = error);
      Future.delayed(const Duration(seconds: 3),
          () => mounted ? setState(() => _sendError = null) : null);
    } else {
      _messageCtrl.clear();
      setState(() => _sendError = null);
    }
  }

  void _scrollToBottom() {
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (_showSearch) {
      _searchAnimCtrl.forward();
    } else {
      _searchAnimCtrl.reverse();
      context.read<ChatProvider>().clearSearch();
      _searchCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final student = auth.currentStudent!;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(student, auth),
      body: Column(
        children: [
          if (_showSearch) _buildSearchBar(),
          _buildRoomSelector(),
          _buildAdminAnnouncementBanner(),
          _buildPinnedMessageBanner(),
          _buildTypingIndicator(student.pin),
          Expanded(
            child: isTablet
                ? Row(
                    children: [
                      SizedBox(width: 260, child: _buildSidebar()),
                      const VerticalDivider(width: 1),
                      Expanded(child: _buildChatArea(student)),
                    ],
                  )
                : _buildChatArea(student),
          ),
          if (_sendError != null)
            Container(
              color: AppColors.error.withOpacity(0.9),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _sendError!,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          _buildInputBar(student),
        ],
      ),
      floatingActionButton: _showScrollButton
          ? _ScrollToBottomButton(onTap: _scrollToBottom)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(StudentModel student, AuthProvider auth) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          _AnimatedAvatar(
            pin: student.pin,
            isAdmin: student.isAdmin,
            size: 40,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.isAdmin
                    ? 'BEEDI Admin'
                    : 'Anonymous (${student.pin})',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.search_off : Icons.search,
            color: AppColors.textMed,
          ),
          onPressed: _toggleSearch,
        ),
        Consumer<ThemeProvider>(
          builder: (_, theme, __) => IconButton(
            icon: Icon(
              theme.isDark ? Icons.light_mode : Icons.dark_mode,
              color: AppColors.textMed,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ),
        if (auth.isAdmin)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings,
                color: AppColors.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            ),
          ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textMed),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          onSelected: (val) async {
            if (val == 'logout') {
              final chat = context.read<ChatProvider>();
              chat.cancelTyping(student.pin);
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Text('Logout',
                      style: GoogleFonts.poppins(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }

  Widget _buildSearchBar() {
    return FadeTransition(
      opacity: _searchFade,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: _searchCtrl,
          autofocus: true,
          onChanged: (q) => context.read<ChatProvider>().searchMessages(q),
          decoration: InputDecoration(
            hintText: 'Search messages...',
            hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.primary),
            suffixIcon: IconButton(
              icon:
                  const Icon(Icons.clear, color: AppColors.textMed),
              onPressed: () {
                _searchCtrl.clear();
                context.read<ChatProvider>().clearSearch();
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            filled: true,
            fillColor: AppColors.background,
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildAdminAnnouncementBanner() {
    return Consumer<ChatProvider>(
      builder: (_, chat, __) {
        if (chat.adminAnnouncement == null ||
            chat.adminAnnouncement!.isEmpty) return const SizedBox();
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppColors.adminBubbleGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.adminGlow,
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.campaign, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chat.adminAnnouncement!,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinnedMessageBanner() {
    return Consumer<ChatProvider>(
      builder: (_, chat, __) {
        if (chat.pinnedMessage == null) return const SizedBox();
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.secondary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.push_pin, color: AppColors.secondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chat.pinnedMessage!.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator(String myPin) {
    return Consumer<ChatProvider>(
      builder: (_, chat, __) {
        final typingPins = chat.typingUsers.entries
            .where((e) => e.value && e.key != myPin)
            .map((e) => e.key)
            .toList();
        if (typingPins.isEmpty) return const SizedBox();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: Colors.white,
          child: Row(
            children: [
              _TypingDots(),
              const SizedBox(width: 8),
              Text(
                typingPins.length == 1
                    ? '${typingPins[0]} is typing...'
                    : '${typingPins.length} people are typing...',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoomSelector() {
    return Container(
      height: 52,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _rooms.length,
        itemBuilder: (_, i) {
          final room = _rooms[i];
          final isActive = room['id'] == _currentRoom;
          return GestureDetector(
            onTap: () {
              setState(() => _currentRoom = room['id']!);
              context.read<ChatProvider>().setRoom(room['id']!);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      )
                    : null,
                color: isActive ? null : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? Colors.transparent : AppColors.divider,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Text(room['icon']!,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    room['name']!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textMed,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chat Rooms',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontSize: 16,
              ),
            ),
          ),
          ..._rooms.map((room) {
            final isActive = room['id'] == _currentRoom;
            return ListTile(
              leading: Text(room['icon']!,
                  style: const TextStyle(fontSize: 24)),
              title: Text(
                room['name']!,
                style: GoogleFonts.poppins(
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textDark,
                ),
              ),
              selected: isActive,
              selectedTileColor: AppColors.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onTap: () {
                setState(() => _currentRoom = room['id']!);
                context.read<ChatProvider>().setRoom(room['id']!);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChatArea(StudentModel student) {
    return Consumer<ChatProvider>(
      builder: (_, chat, __) {
        // Show search results
        if (chat.isSearching) {
          return _buildSearchResults(chat, student);
        }

        if (chat.messages.isEmpty && chat.isLoading) {
          return const _AnimatedLoadingState();
        }

        if (chat.messages.isEmpty) {
          return _buildEmptyChat();
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >=
                n.metrics.maxScrollExtent - 200) {
              chat.loadMoreMessages();
            }
            return false;
          },
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => chat.loadMoreMessages(),
            child: ListView.builder(
              controller: _scrollCtrl,
              reverse: true,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(
                  top: 16, bottom: 8, left: 12, right: 12),
              itemCount: chat.messages.length + (chat.hasMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == chat.messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final msg = chat.messages[i];
                final isMe = msg.senderPin == student.pin;
                final showDate = i == chat.messages.length - 1 ||
                    !_isSameDay(
                      chat.messages[i].timestamp,
                      chat.messages[i + 1].timestamp,
                    );

                return Column(
                  children: [
                    if (showDate) _buildDateChip(msg.timestamp),
                    MessageBubble(
                      message: msg,
                      isMe: isMe,
                      onReply: () => chat.setReply(msg),
                      onReaction: (emoji) => chat.addReaction(
                          msg.messageId, emoji, student.pin),
                      onDelete:
                          context.read<AuthProvider>().isAdmin
                              ? () => chat.deleteMessage(msg.messageId)
                              : null,
                      onAdminIdentify:
                          context.read<AuthProvider>().isAdmin
                              ? () => _showIdentity(msg.senderPin)
                              : null,
                      onPin: context.read<AuthProvider>().isAdmin
                          ? () => chat.pinMessage(
                              msg.messageId, !msg.isPinned)
                          : null,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(ChatProvider chat, StudentModel student) {
    if (chat.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text('No messages found',
                style: GoogleFonts.poppins(
                    color: AppColors.textMed, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(12),
      itemCount: chat.searchResults.length,
      itemBuilder: (_, i) {
        final msg = chat.searchResults[i];
        final isMe = msg.senderPin == student.pin;
        return MessageBubble(
          message: msg,
          isMe: isMe,
          onReply: () => chat.setReply(msg),
          onReaction: (emoji) =>
              chat.addReaction(msg.messageId, emoji, student.pin),
          onDelete: context.read<AuthProvider>().isAdmin
              ? () => chat.deleteMessage(msg.messageId)
              : null,
          onAdminIdentify: context.read<AuthProvider>().isAdmin
              ? () => _showIdentity(msg.senderPin)
              : null,
          onPin: null,
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDateChip(DateTime dt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            TimeHelper.formatDate(dt),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline,
                size: 50, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textMed,
            ),
          ),
          Text(
            'Be the first to say something!',
            style: GoogleFonts.poppins(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(StudentModel student) {
    return Consumer<ChatProvider>(
      builder: (_, chat, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chat.replyingTo != null) _buildReplyPreview(chat),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _messageCtrl,
                            focusNode: _focusNode,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: _SecurityConfig.maxMessageLength,
                            onChanged: (_) =>
                                chat.updateTyping(student.pin),
                            decoration: InputDecoration(
                              hintText: student.isMuted
                                  ? 'You are muted...'
                                  : 'Type a message...',
                              hintStyle: GoogleFonts.poppins(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              counterText: '',
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14),
                            enabled: !student.isMuted,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined,
                              color: AppColors.textMed),
                          onPressed: () => _showEmojiPicker(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SendButton(onTap: _sendMessage),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(ChatProvider chat) {
    final reply = chat.replyingTo!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
            left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${reply.senderPin}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  reply.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textMed),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.textMed),
            onPressed: chat.clearReply,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmojiPickerSheet(
        onEmojiSelected: (e) {
          _messageCtrl.text += e;
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _showIdentity(String pin) async {
    final student = await context.read<ChatProvider>().getStudentByPin(pin);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => _AdminIdentityDialog(
        student: student,
        pin: pin,
        onBan: () async {
          await context.read<ChatProvider>().banPin(pin);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student banned.'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        onMute: (mute) async {
          await context.read<ChatProvider>().mutePin(pin, mute);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ============================================================
// SUPPORTING CHAT WIDGETS
// ============================================================

class _AnimatedAvatar extends StatelessWidget {
  final String pin;
  final bool isAdmin;
  final double size;

  const _AnimatedAvatar({
    required this.pin,
    required this.isAdmin,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.adminGlow,
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/Logoes/Logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.primary,
              child: const Icon(Icons.school, color: Colors.white),
            ),
          ),
        ),
      );
    }
    final color = AvatarHelper.getAvatarColor(pin);
    final icon = AvatarHelper.getAvatarIcon(pin);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, spreadRadius: 1),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.45),
    );
  }
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i * 0.3;
          final t = (_ctrl.value - delay).clamp(0.0, 1.0);
          final scale = 0.5 + (0.5 * (t < 0.5 ? t * 2 : (1 - t) * 2));
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 5 * scale,
            height: 5 * scale,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

class _AnimatedLoadingState extends StatefulWidget {
  const _AnimatedLoadingState();

  @override
  State<_AnimatedLoadingState> createState() => _AnimatedLoadingStateState();
}

class _AnimatedLoadingStateState extends State<_AnimatedLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment:
                i % 2 == 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (i % 2 == 0) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 180 + (i * 10.0),
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ScrollToBottomButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ScrollToBottomButton({required this.onTap});

  @override
  State<_ScrollToBottomButton> createState() => _ScrollToBottomButtonState();
}

class _ScrollToBottomButtonState extends State<_ScrollToBottomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FloatingActionButton.small(
        onPressed: widget.onTap,
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    );
  }
}

class _EmojiPickerSheet extends StatelessWidget {
  final Function(String) onEmojiSelected;
  const _EmojiPickerSheet({required this.onEmojiSelected});

  @override
  Widget build(BuildContext context) {
    const emojis = [
      '👍', '❤️', '😂', '😮', '😢', '🎉', '🔥', '👏',
      '🙏', '💯', '✨', '😍', '😎', '🤔', '😅', '🥳',
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Quick Emojis',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: emojis
                .map((e) => GestureDetector(
                      onTap: () => onEmojiSelected(e),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AdminIdentityDialog extends StatelessWidget {
  final StudentModel? student;
  final String pin;
  final VoidCallback onBan;
  final Function(bool) onMute;

  const _AdminIdentityDialog({
    required this.student,
    required this.pin,
    required this.onBan,
    required this.onMute,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.adminBubbleGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Student Identity',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (student == null)
              Text('Student not found.',
                  style: GoogleFonts.poppins(color: AppColors.textMed))
            else ...[
              _infoRow('PIN', student!.pin),
              _infoRow('Name', student!.realName),
              _infoRow('Batch', student!.batch),
              _infoRow('Status', student!.isBanned ? '🚫 BANNED' : '✅ Active'),
              _infoRow('Muted', student!.isMuted ? 'Yes' : 'No'),
            ],
            const SizedBox(height: 20),
            if (student != null) ...[
              if (!student!.isBanned)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onBan,
                    icon: const Icon(Icons.block, size: 18),
                    label: Text('Ban Student',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onMute(!student!.isMuted),
                  icon: Icon(
                    student!.isMuted ? Icons.volume_up : Icons.volume_off,
                    size: 18,
                  ),
                  label: Text(
                    student!.isMuted ? 'Unmute Student' : 'Mute Student',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: const BorderSide(color: AppColors.warning),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close',
                    style: GoogleFonts.poppins(color: AppColors.textMed)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text('$label: ',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textDark)),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textMed)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MESSAGE BUBBLE WIDGET
// ============================================================

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback onReply;
  final Function(String emoji) onReaction;
  final VoidCallback? onDelete;
  final VoidCallback? onAdminIdentify;
  final VoidCallback? onPin;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onReply,
    required this.onReaction,
    this.onDelete,
    this.onAdminIdentify,
    this.onPin,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;
  double _dragX = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _slideAnim = Tween<Offset>(
      begin: widget.isMe ? const Offset(0.25, 0) : const Offset(-0.25, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdminMsg = widget.message.senderType == 'admin';

    return ScaleTransition(
      scale: _scaleAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onHorizontalDragUpdate: (d) {
            if (!widget.isMe) {
              setState(() {
                _dragX = (d.globalPosition.dx - d.localPosition.dx)
                    .clamp(-60.0, 60.0);
                _isDragging = true;
              });
            }
          },
          onHorizontalDragEnd: (d) {
            if (_dragX.abs() > 30) widget.onReply();
            setState(() {
              _dragX = 0;
              _isDragging = false;
            });
          },
          onLongPress: () => _showOptions(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.translationValues(_dragX * 0.4, 0, 0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: widget.isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!widget.isMe) ...[
                    _buildAvatar(widget.message.senderPin, isAdminMsg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(child: _buildBubble(isAdminMsg)),
                  if (widget.isMe) const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String pin, bool isAdmin) {
    return _AnimatedAvatar(pin: pin, isAdmin: isAdmin, size: 34);
  }

  Widget _buildBubble(bool isAdminMsg) {
    final msg = widget.message;

    if (msg.isDeleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '🗑️ This message was deleted',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textLight,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final bool useWhiteText = isAdminMsg || widget.isMe;

    return Column(
      crossAxisAlignment: widget.isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (!widget.isMe)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAdminMsg ? 'BEEDI Admin' : msg.senderPin,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isAdminMsg
                        ? AppColors.primary
                        : AvatarHelper.getAvatarColor(msg.senderPin),
                  ),
                ),
                if (isAdminMsg) ...[
                  const SizedBox(width: 4),
                  _AdminBadge(),
                ],
              ],
            ),
          ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.70,
          ),
          decoration: BoxDecoration(
            gradient: isAdminMsg
                ? AppColors.adminBubbleGradient
                : widget.isMe
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                      )
                    : null,
            color: (isAdminMsg || widget.isMe) ? null : AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: widget.isMe
                  ? const Radius.circular(18)
                  : const Radius.circular(4),
              bottomRight: widget.isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: isAdminMsg
                    ? AppColors.adminGlow
                    : widget.isMe
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.black.withOpacity(0.06),
                blurRadius: isAdminMsg ? 16 : 8,
                spreadRadius: isAdminMsg ? 2 : 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg.replyMessage != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: useWhiteText
                        ? Colors.white.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      left: BorderSide(
                        color: useWhiteText
                            ? Colors.white.withOpacity(0.5)
                            : AppColors.primary,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.replySenderPin ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: useWhiteText
                              ? Colors.white70
                              : AppColors.primary,
                        ),
                      ),
                      Text(
                        msg.replyMessage!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: useWhiteText
                              ? Colors.white60
                              : AppColors.textMed,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Text(
                  msg.message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: useWhiteText ? Colors.white : AppColors.textDark,
                    height: 1.4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TimeHelper.format(msg.timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: useWhiteText
                            ? Colors.white60
                            : AppColors.textLight,
                      ),
                    ),
                    if (widget.isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        msg.seenBy.length > 1
                            ? Icons.done_all
                            : Icons.done,
                        size: 12,
                        color: msg.seenBy.length > 1
                            ? Colors.lightBlueAccent
                            : Colors.white60,
                      ),
                    ],
                    if (msg.isPinned) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.push_pin,
                        size: 11,
                        color: useWhiteText
                            ? Colors.white60
                            : AppColors.secondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (msg.reactions.isNotEmpty) _buildReactions(msg),
      ],
    );
  }

  Widget _buildReactions(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: msg.reactions.entries
            .where((e) => e.value.isNotEmpty)
            .map((e) => GestureDetector(
                  onTap: () => widget.onReaction(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '${e.key} ${e.value.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        const reactions = ['👍', '❤️', '😂', '😮', '😢', '🎉', '🔥', '👏'];
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('React',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: reactions
                    .map((e) => GestureDetector(
                          onTap: () {
                            widget.onReaction(e);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(e,
                                style: const TextStyle(fontSize: 24)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Divider(),
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.reply, color: AppColors.primary, size: 18),
                ),
                title: Text('Reply', style: GoogleFonts.poppins()),
                onTap: () {
                  widget.onReply();
                  Navigator.pop(ctx);
                },
              ),
              if (widget.onPin != null)
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.push_pin,
                        color: AppColors.secondary, size: 18),
                  ),
                  title: Text(
                    widget.message.isPinned ? 'Unpin Message' : 'Pin Message',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () {
                    widget.onPin!();
                    Navigator.pop(ctx);
                  },
                ),
              if (widget.onAdminIdentify != null)
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_search,
                        color: AppColors.accent, size: 18),
                  ),
                  title: Text('View Identity (Admin)',
                      style: GoogleFonts.poppins()),
                  onTap: () {
                    widget.onAdminIdentify!();
                    Navigator.pop(ctx);
                  },
                ),
              if (widget.onDelete != null)
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 18),
                  ),
                  title: Text('Delete Message',
                      style: GoogleFonts.poppins(color: AppColors.error)),
                  onTap: () {
                    widget.onDelete!();
                    Navigator.pop(ctx);
                  },
                ),
              SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }
}

class _AdminBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent]),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.adminGlow,
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            'Admin',
            style: GoogleFonts.poppins(
                fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN DASHBOARD
// ============================================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPinProvider>().loadPins();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.adminBubbleGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.adminGlow,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.admin_panel_settings,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Admin Dashboard',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.chat, color: AppColors.primary),
            label: Text('Chat',
                style: GoogleFonts.poppins(color: AppColors.primary)),
            onPressed: () {
              context.read<ChatProvider>().setRoom('general');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMed,
          labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 11),
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.people, size: 18), text: 'Students'),
            Tab(icon: Icon(Icons.chat, size: 18), text: 'Messages'),
            Tab(icon: Icon(Icons.campaign, size: 18), text: 'Announce'),
            Tab(icon: Icon(Icons.pin, size: 18), text: 'PIN Manager'),
            Tab(icon: Icon(Icons.analytics, size: 18), text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _StudentsTab(),
          _MessagesTab(),
          _AnnounceTab(),
          _AdminPinManagerTab(),
          _StatsTab(),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN STUDENTS TAB
// ============================================================

class _StudentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text('No students registered.',
                style: GoogleFonts.poppins(color: AppColors.textMed)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final s = StudentModel.fromFirestore(docs[i]);
            return _StudentCard(student: s);
          },
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _AnimatedAvatar(
          pin: student.pin,
          isAdmin: student.isAdmin,
          size: 44,
        ),
        title: Text(
          student.isAdmin ? 'BEEDI Admin' : student.realName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PIN: ${student.pin} | Batch: ${student.batch}',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textMed),
            ),
            Row(
              children: [
                if (student.isBanned)
                  _StatusChip(
                    label: 'BANNED',
                    color: AppColors.error,
                  ),
                if (student.isMuted)
                  _StatusChip(label: 'MUTED', color: AppColors.warning),
                if (!student.pinActive)
                  _StatusChip(
                    label: 'PIN INACTIVE',
                    color: AppColors.textMed,
                  ),
              ],
            ),
          ],
        ),
        trailing: student.isAdmin
            ? null
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.textMed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (val) async {
                  final db = FirebaseFirestore.instance;
                  if (val == 'ban') {
                    await db
                        .collection('students')
                        .doc(student.uid)
                        .update({'isBanned': true});
                    await db
                        .collection('admin_pins')
                        .doc(student.pin)
                        .update({'isActive': false}).catchError((_) {});
                  } else if (val == 'unban') {
                    await db
                        .collection('students')
                        .doc(student.uid)
                        .update({'isBanned': false});
                    await db
                        .collection('admin_pins')
                        .doc(student.pin)
                        .update({'isActive': true}).catchError((_) {});
                  } else if (val == 'mute') {
                    await db
                        .collection('students')
                        .doc(student.uid)
                        .update({'isMuted': true});
                  } else if (val == 'unmute') {
                    await db
                        .collection('students')
                        .doc(student.uid)
                        .update({'isMuted': false});
                  } else if (val == 'deactivate_pin') {
                    await db
                        .collection('students')
                        .doc(student.uid)
                        .update({'pinActive': false});
                    await db
                        .collection('admin_pins')
                        .doc(student.pin)
                        .update({'isActive': false}).catchError((_) {});
                  } else if (val == 'activate_pin') {
                    await db
                        .collection('students')
                        .doc(student.uid)
                        .update({'pinActive': true});
                    await db
                        .collection('admin_pins')
                        .doc(student.pin)
                        .update({'isActive': true}).catchError((_) {});
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: student.isBanned ? 'unban' : 'ban',
                    child: Row(
                      children: [
                        Icon(
                          student.isBanned ? Icons.check_circle : Icons.block,
                          color: student.isBanned
                              ? AppColors.success
                              : AppColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          student.isBanned ? 'Unban' : 'Ban Student',
                          style: GoogleFonts.poppins(
                            color: student.isBanned
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: student.isMuted ? 'unmute' : 'mute',
                    child: Row(
                      children: [
                        Icon(
                          student.isMuted
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: AppColors.warning,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          student.isMuted ? 'Unmute' : 'Mute',
                          style: GoogleFonts.poppins(color: AppColors.warning),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: student.pinActive ? 'deactivate_pin' : 'activate_pin',
                    child: Row(
                      children: [
                        Icon(
                          student.pinActive
                              ? Icons.lock_outline
                              : Icons.lock_open,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          student.pinActive ? 'Deactivate PIN' : 'Activate PIN',
                          style: GoogleFonts.poppins(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN MESSAGES TAB
// ============================================================

class _MessagesTab extends StatefulWidget {
  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  String _selectedRoom = 'general';
  final _rooms = ['general', 'academic', 'sports', 'events', 'help'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 52,
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            children: _rooms.map((r) {
              final isActive = r == _selectedRoom;
              return GestureDetector(
                onTap: () => setState(() => _selectedRoom = r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary
                            ],
                          )
                        : null,
                    color: isActive ? null : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$r',
                    style: GoogleFonts.poppins(
                      color: isActive ? Colors.white : AppColors.textMed,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('anonymous_chats')
                .doc(_selectedRoom)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .limit(100)
                .snapshots(),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Text('No messages in #$_selectedRoom',
                      style: GoogleFonts.poppins(
                          color: AppColors.textMed)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final msg = ChatMessage.fromFirestore(docs[i]);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: msg.senderType == 'admin'
                          ? Border.all(
                              color: AppColors.primary.withOpacity(0.3))
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AnimatedAvatar(
                          pin: msg.senderPin,
                          isAdmin: msg.senderType == 'admin',
                          size: 36,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    msg.senderPin,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: msg.senderType == 'admin'
                                          ? AppColors.primary
                                          : AvatarHelper.getAvatarColor(
                                              msg.senderPin),
                                    ),
                                  ),
                                  if (msg.senderType == 'admin')
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: _AdminBadge(),
                                    ),
                                  const Spacer(),
                                  Text(
                                    TimeHelper.format(msg.timestamp),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                msg.isDeleted
                                    ? '🗑️ Deleted'
                                    : msg.message,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontStyle: msg.isDeleted
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  color: msg.isDeleted
                                      ? AppColors.textLight
                                      : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!msg.isDeleted)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error, size: 18),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('anonymous_chats')
                                  .doc(_selectedRoom)
                                  .collection('messages')
                                  .doc(msg.messageId)
                                  .update({
                                'isDeleted': true,
                                'message':
                                    'This message was deleted by admin.',
                              });
                            },
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

// ============================================================
// ADMIN ANNOUNCE TAB
// ============================================================

class _AnnounceTab extends StatefulWidget {
  @override
  State<_AnnounceTab> createState() => _AnnounceTabState();
}

class _AnnounceTabState extends State<_AnnounceTab> {
  final _msgCtrl = TextEditingController();
  final _bannerCtrl = TextEditingController();
  String _selectedRoom = 'general';
  bool _sending = false;
  bool _settingBanner = false;
  final _rooms = ['general', 'academic', 'sports', 'events', 'help'];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _bannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendAnnouncement() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await FirebaseFirestore.instance
          .collection('anonymous_chats')
          .doc(_selectedRoom)
          .collection('messages')
          .add({
        'senderPin': _SecurityConfig.adminPin,
        'senderType': 'admin',
        'message': _SecurityConfig.sanitizeMessage(_msgCtrl.text.trim()),
        'timestamp': FieldValue.serverTimestamp(),
        'replyMessage': null,
        'replySenderPin': null,
        'replyMessageId': null,
        'reactions': {},
        'isDeleted': false,
        'seenBy': [],
        'isPinned': false,
      });
      _msgCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement sent!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _setAnnouncementBanner() async {
    setState(() => _settingBanner = true);
    await context
        .read<ChatProvider>()
        .setAdminAnnouncement(_bannerCtrl.text.trim(), _selectedRoom);
    if (mounted) {
      setState(() => _settingBanner = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Banner updated!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Send Announcement', icon: Icons.campaign),
          const SizedBox(height: 6),
          Text(
            'This will appear as an admin message in the selected chat room.',
            style: GoogleFonts.poppins(
                color: AppColors.textMed, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _RoomSelector(
            rooms: _rooms,
            selectedRoom: _selectedRoom,
            onSelect: (r) => setState(() => _selectedRoom = r),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _msgCtrl,
            maxLines: 5,
            maxLength: _SecurityConfig.maxMessageLength,
            decoration: InputDecoration(
              hintText: 'Write your announcement here...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: _sending
                ? const Center(child: CircularProgressIndicator())
                : _GradientButton(
                    label: 'Send to #$_selectedRoom',
                    icon: Icons.send,
                    onTap: _sendAnnouncement,
                    gradient: const LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary]),
                  ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          _SectionTitle(
              title: 'Announcement Banner', icon: Icons.notifications_active),
          const SizedBox(height: 6),
          Text(
            'Set a persistent banner shown at the top of the chat.',
            style: GoogleFonts.poppins(
                color: AppColors.textMed, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bannerCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Banner text (leave empty to clear)...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textLight),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: Colors.white,
            ),
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _settingBanner
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton.icon(
                    onPressed: _setAnnouncementBanner,
                    icon: const Icon(Icons.save_outlined),
                    label: Text('Save Banner',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN PIN MANAGER TAB
// ============================================================

class _AdminPinManagerTab extends StatefulWidget {
  @override
  State<_AdminPinManagerTab> createState() => _AdminPinManagerTabState();
}

class _AdminPinManagerTabState extends State<_AdminPinManagerTab> {
  final _countCtrl = TextEditingController(text: '5');
  final _batchCtrl = TextEditingController();
  bool _setExpiry = false;
  DateTime? _expiryDate;
  List<String> _lastGenerated = [];
  bool _generating = false;

  @override
  void dispose() {
    _countCtrl.dispose();
    _batchCtrl.dispose();
    super.dispose();
  }

  Future<void> _generatePins() async {
    final count = int.tryParse(_countCtrl.text) ?? 1;
    if (count < 1 || count > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter between 1 and 50.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _generating = true);

    final pins = await context.read<AdminPinProvider>().generateBatchPins(
          count: count,
          batch: _batchCtrl.text.trim().isEmpty
              ? 'BATCH-${DateTime.now().year}'
              : _batchCtrl.text.trim(),
          adminPin: _SecurityConfig.adminPin,
          expiresAt: _setExpiry ? _expiryDate : null,
        );

    setState(() {
      _lastGenerated = pins;
      _generating = false;
    });

    if (pins.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${pins.length} PINs generated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.adminBubbleGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.adminGlow,
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin PIN Generator',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Only admins can create student PINs.',
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _SectionTitle(title: 'Generate New PINs', icon: Icons.add_circle_outline),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _countCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Count (max 50)',
                    prefixIcon: const Icon(Icons.pin, color: AppColors.primary),
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: GoogleFonts.jetBrainsMono(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _batchCtrl,
                  decoration: InputDecoration(
                    labelText: 'Batch (optional)',
                    prefixIcon: const Icon(Icons.group,
                        color: AppColors.secondary),
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Switch(
                value: _setExpiry,
                onChanged: (v) => setState(() => _setExpiry = v),
                activeColor: AppColors.primary,
              ),
              Text('Set Expiry Date',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              if (_setExpiry) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setState(() => _expiryDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      _expiryDate != null
                          ? DateFormat('MMM d, y').format(_expiryDate!)
                          : 'Pick Date',
                      style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: _generating
                ? const Center(child: CircularProgressIndicator())
                : _GradientButton(
                    label: 'Generate PINs',
                    icon: Icons.generating_tokens,
                    onTap: _generatePins,
                    gradient: AppColors.adminBubbleGradient,
                  ),
          ),

          if (_lastGenerated.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle(
                title: 'Last Generated PINs', icon: Icons.check_circle_outline),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.success.withOpacity(0.2)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _lastGenerated.map((pin) {
                  return GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: pin));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('PIN $pin copied!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pin,
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy,
                              color: Colors.white70, size: 12),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          _SectionTitle(title: 'All Generated PINs', icon: Icons.list_alt),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: context.read<AdminPinProvider>().pinsStream(),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Text('No PINs generated yet.',
                      style: GoogleFonts.poppins(
                          color: AppColors.textMed)),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final pin = PinModel.fromFirestore(docs[i]);
                  return _PinListItem(
                    pin: pin,
                    onToggle: (active) => context
                        .read<AdminPinProvider>()
                        .togglePinActive(pin.pin, active),
                    onDelete: () => context
                        .read<AdminPinProvider>()
                        .deletePin(pin.pin),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PinListItem extends StatelessWidget {
  final PinModel pin;
  final Function(bool) onToggle;
  final VoidCallback onDelete;

  const _PinListItem({
    required this.pin,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = pin.expiresAt != null &&
        DateTime.now().isAfter(pin.expiresAt!);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !pin.isActive || isExpired
              ? AppColors.error.withOpacity(0.2)
              : AppColors.success.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: pin.isActive && !isExpired
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary])
                  : const LinearGradient(
                      colors: [AppColors.textLight, AppColors.textMed]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              pin.pin,
              style: GoogleFonts.jetBrainsMono(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pin.batch,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textMed),
                ),
                Row(
                  children: [
                    if (pin.isUsed)
                      _StatusChip(label: 'USED', color: AppColors.warning),
                    if (!pin.isActive)
                      _StatusChip(label: 'INACTIVE', color: AppColors.error),
                    if (isExpired)
                      _StatusChip(label: 'EXPIRED', color: AppColors.error),
                    if (pin.expiresAt != null && !isExpired)
                      _StatusChip(
                        label: 'Exp: ${DateFormat('MMM d').format(pin.expiresAt!)}',
                        color: AppColors.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: pin.isActive,
            onChanged: onToggle,
            activeColor: AppColors.success,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 18),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Delete PIN ${pin.pin}?',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                content: Text(
                    'This cannot be undone.',
                    style: GoogleFonts.poppins()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: GoogleFonts.poppins()),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    child: Text('Delete',
                        style: GoogleFonts.poppins(
                            color: AppColors.error)),
                  ),
                ],
              ),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN STATS TAB
// ============================================================

class _StatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _StatCard(
            title: 'Total Students',
            icon: Icons.people,
            color: AppColors.primary,
            stream: FirebaseFirestore.instance
                .collection('students')
                .where('isAdmin', isEqualTo: false)
                .snapshots()
                .map((s) => s.docs.length.toString()),
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: 'Banned Students',
            icon: Icons.block,
            color: AppColors.error,
            stream: FirebaseFirestore.instance
                .collection('students')
                .where('isBanned', isEqualTo: true)
                .snapshots()
                .map((s) => s.docs.length.toString()),
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: 'General Chat Messages',
            icon: Icons.message,
            color: AppColors.secondary,
            stream: FirebaseFirestore.instance
                .collection('anonymous_chats')
                .doc('general')
                .collection('messages')
                .snapshots()
                .map((s) => s.docs.length.toString()),
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: 'Generated PINs',
            icon: Icons.pin,
            color: AppColors.accent,
            stream: FirebaseFirestore.instance
                .collection('admin_pins')
                .snapshots()
                .map((s) => s.docs.length.toString()),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.adminBubbleGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.adminGlow,
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user,
                    color: Colors.white, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Control Active',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Full moderation + PIN management enabled.',
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 12),
                      ),
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Stream<String> stream;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: AppColors.textMed, fontSize: 13)),
                StreamBuilder<String>(
                  stream: stream,
                  builder: (_, snap) => Text(
                    snap.data ?? '—',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED SMALL WIDGETS
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _RoomSelector extends StatelessWidget {
  final List<String> rooms;
  final String selectedRoom;
  final Function(String) onSelect;

  const _RoomSelector({
    required this.rooms,
    required this.selectedRoom,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: rooms.map((r) {
        final isActive = r == selectedRoom;
        return GestureDetector(
          onTap: () => onSelect(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary])
                  : null,
              color: isActive ? null : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? Colors.transparent : AppColors.divider,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Text(
              '#$r',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textMed,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}