// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

// ════════════════════════════════════════════════════════════════════════════════
// BEEDI College - AdmissionScreen.dart
// Online Admission Management System
// 68 Features Implemented | Firebase: Auth + Firestore + Storage
// ════════════════════════════════════════════════════════════════════════════════

// Required pubspec.yaml dependencies:
// dependencies:
//   flutter:
//     sdk: flutter
//   firebase_core: ^2.24.2
//   firebase_auth: ^4.16.0
//   cloud_firestore: ^4.14.0
//   firebase_storage: ^11.6.0
//   google_sign_in: ^6.2.1
//   image_picker: ^1.0.5
//   file_picker: ^6.1.1
//   intl: ^0.18.1
//   shared_preferences: ^2.2.2
//   flutter_local_notifications: ^16.3.0
//   url_launcher: ^6.2.5
//
// Firebase Security Rules (Firestore):
// rules_version = '2';
// service cloud.firestore {
//   match /databases/{database}/documents {
//     match /applications/{document} {
//       allow read, write: if request.auth != null &&
//         (request.auth.uid == resource.data.userId ||
//          request.auth.token.isAdmin == true);
//     }
//     match /programs/{document} {
//       allow read: if true;
//       allow write: if request.auth.token.isAdmin == true;
//     }
//   }
// }
//
// Firestore Collection: applications/{userId}_{timestamp}
// {
//   applicationId: "BDC2026001",
//   userId: "uid_from_auth",
//   personalInfo: { fullName, dob, gender, nationality, aadharNumber, emergencyContact },
//   contactInfo: { email, phone, alternatePhone, address, city, state, pincode },
//   academicInfo: { previousQualification, percentage, passingYear, board, schoolName,
//                   backlog, entranceScore, gapYear },
//   programInfo: { selectedProgram, programId, branchPreferences, semester, shift, hostel },
//   documents: { photo, signature, marksheet10th, marksheet12th, casteCertificate, income },
//   paymentInfo: { applicationFee, transactionId, paymentStatus, paymentDate },
//   status: "draft/submitted/under_review/approved/rejected",
//   submissionDate: Timestamp, lastUpdated: Timestamp
// }

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ════════════════════════════════════════════════════════════════════════════════
// FIREBASE SERVICE LAYER (Abstracted for easy real Firebase swap-in)
// ════════════════════════════════════════════════════════════════════════════════

/// Simulates Firebase Auth user
class _MockUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  _MockUser({required this.uid, required this.email, this.displayName, this.photoURL});
}

/// Simulates Firestore DocumentSnapshot
class _FirebaseService {
  static _MockUser? _currentUser;
  static final Map<String, Map<String, dynamic>> _firestoreDb = {};
  static final Map<String, Uint8List> _storageDb = {};

  // ── Auth ───────────────────────────────────────────────────────────────────
  static _MockUser? get currentUser => _currentUser;

  static Future<_MockUser> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (password.length < 6) throw Exception('Invalid credentials. Please try again.');
    _currentUser = _MockUser(uid: 'uid_${email.hashCode}', email: email, displayName: email.split('@').first);
    return _currentUser!;
  }

  static Future<_MockUser> registerWithEmail(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (password.length < 8) throw Exception('Password must be at least 8 characters.');
    _currentUser = _MockUser(uid: 'uid_${email.hashCode}', email: email, displayName: name);
    return _currentUser!;
  }

  static Future<_MockUser> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    _currentUser = _MockUser(uid: 'google_uid_12345', email: 'student@gmail.com', displayName: 'Google User');
    return _currentUser!;
  }

  static Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 900));
    // Simulates Firebase send email
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  // ── Firestore ──────────────────────────────────────────────────────────────
  static Future<void> saveDocument(String collection, String docId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _firestoreDb['$collection/$docId'] = {...data, 'lastUpdated': DateTime.now().toIso8601String()};
  }

  static Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _firestoreDb['$collection/$docId'];
  }

  static Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _firestoreDb.entries
        .where((e) => e.key.startsWith('$collection/'))
        .map((e) => e.value)
        .toList();
  }

  static Future<bool> checkDuplicate(String field, String value) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _firestoreDb.values.any((doc) =>
        doc['personalInfo'] != null && doc['personalInfo'][field] == value);
  }

  // ── Storage ────────────────────────────────────────────────────────────────
  static Future<String> uploadFile(String path, Uint8List bytes,
      {void Function(double)? onProgress}) async {
    // Simulate upload with progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      onProgress?.call(i / 10);
    }
    _storageDb[path] = bytes;
    return 'https://storage.firebase.com/beedi-college/$path?token=${math.Random().nextInt(99999)}';
  }

  // ── Programs ───────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> fetchPrograms() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      {'id': 'PGM001', 'name': 'B.Tech Computer Science', 'fee': 850000, 'seats': 60, 'filled': 42, 'appFee': 1200, 'category': 'Engineering'},
      {'id': 'PGM002', 'name': 'MBA Business Analytics', 'fee': 1200000, 'seats': 40, 'filled': 35, 'appFee': 1500, 'category': 'Business'},
      {'id': 'PGM003', 'name': 'MBBS', 'fee': 1500000, 'seats': 100, 'filled': 98, 'appFee': 2000, 'category': 'Medical'},
      {'id': 'PGM004', 'name': 'LLB Integrated', 'fee': 750000, 'seats': 60, 'filled': 30, 'appFee': 800, 'category': 'Law'},
      {'id': 'PGM005', 'name': 'B.Des Industrial Design', 'fee': 650000, 'seats': 30, 'filled': 18, 'appFee': 1000, 'category': 'Design'},
      {'id': 'PGM006', 'name': 'M.Tech AI & Robotics', 'fee': 600000, 'seats': 30, 'filled': 22, 'appFee': 1000, 'category': 'Engineering'},
      {'id': 'PGM007', 'name': 'BBA International Business', 'fee': 450000, 'seats': 60, 'filled': 40, 'appFee': 700, 'category': 'Business'},
      {'id': 'PGM008', 'name': 'Diploma Data Science', 'fee': 180000, 'seats': 50, 'filled': 28, 'appFee': 500, 'category': 'Engineering'},
    ];
  }

  // ── Application Number ─────────────────────────────────────────────────────
  static String generateApplicationNumber() {
    final n = math.Random().nextInt(9000) + 1000;
    return 'BDC2026$n';
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// COLORS & THEME
// ════════════════════════════════════════════════════════════════════════════════

class _AC {
  static const primary    = Color(0xFF1A5F7A);
  static const secondary  = Color(0xFFF9D371);
  static const accent     = Color(0xFFF24C4C);
  static const success    = Color(0xFF2E8B57);
  static const warning    = Color(0xFFFFA500);
  static const info       = Color(0xFF00B4D8);
  static const bgLight    = Color(0xFFF5F7FA);
  static const bgDark     = Color(0xFF121212);
  static const cardDark   = Color(0xFF1E1E2E);
  static const cardLight  = Colors.white;
}

// ════════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ════════════════════════════════════════════════════════════════════════════════

class _PersonalInfo {
  String fullName = '';
  String dob = '';
  String gender = '';
  String nationality = 'Indian';
  String aadhar = '';
  String motherName = '';
  String fatherName = '';
  String emergencyContact = '';
  String emergencyName = '';
}

class _ContactInfo {
  String email = '';
  String phone = '';
  String altPhone = '';
  String address = '';
  String city = '';
  String state = '';
  String pincode = '';
}

class _AcademicInfo {
  String qualification = '12th';
  double percentage = 0;
  String passingYear = '';
  String board = '';
  String schoolName = '';
  bool hasBacklog = false;
  String backlogDetails = '';
  String entranceExam = '';
  double entranceScore = 0;
  bool hasGapYear = false;
  String gapYearReason = '';
  double cgpa = 0;
}

class _ProgramInfo {
  String programId = '';
  String programName = '';
  List<String> branchPrefs = ['', '', ''];
  int semester = 1;
  String shift = 'Morning';
  bool needsHostel = false;
  String hostelType = 'Non-AC';
  String referralCode = '';
}

class _DocumentStatus {
  String? photo;
  String? signature;
  String? mark10th;
  String? mark12th;
  String? caste;
  String? income;

  bool get photoUploaded => photo != null;
  bool get signatureUploaded => signature != null;
  bool get mark10thUploaded => mark10th != null;
  bool get mark12thUploaded => mark12th != null;
}

class _PaymentInfo {
  int fee = 1200;
  String transactionId = '';
  String status = 'pending'; // pending/success/failed
  DateTime? paymentDate;
  int discount = 0;
}

// ════════════════════════════════════════════════════════════════════════════════
// SHIMMER WIDGET
// ════════════════════════════════════════════════════════════════════════════════

class _Shimmer extends StatefulWidget {
  final double width, height;
  final double radius;
  final bool isDark;
  const _Shimmer({required this.width, required this.height, this.radius = 8, this.isDark = false});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: widget.isDark
                ? [const Color(0xFF2A2A3E), const Color(0xFF3A3A5E), const Color(0xFF2A2A3E)]
                : [const Color(0xFFE0E0E0), const Color(0xFFF5F5F5), const Color(0xFFE0E0E0)],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// CONFETTI PAINTER
// ════════════════════════════════════════════════════════════════════════════════

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors = [_AC.primary, _AC.secondary, _AC.accent, _AC.success, _AC.info];
  final List<Offset> _particles;

  _ConfettiPainter(this.progress)
      : _particles = List.generate(
            40,
            (i) => Offset(
              (math.sin(i * 2.3) * 0.5 + 0.5),
              (math.cos(i * 1.7) * 0.5 + 0.5),
            ));

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final paint = Paint()..color = colors[i % colors.length].withOpacity(1 - progress);
      final x = p.dx * size.width + math.sin(i + progress * 10) * 30;
      final y = p.dy * size.height * progress * 2;
      canvas.drawCircle(Offset(x, y), 5, paint);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 2 + i);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 8, height: 4), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ════════════════════════════════════════════════════════════════════════════════
// SIGNATURE PAD PAINTER
// ════════════════════════════════════════════════════════════════════════════════

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _AC.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => old.strokes != strokes;
}

// ════════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN WIDGET
// ════════════════════════════════════════════════════════════════════════════════

class AdmissionScreen extends StatefulWidget {
  const AdmissionScreen({super.key});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen>
    with TickerProviderStateMixin {

  // ── Firebase / Auth State ─────────────────────────────────────────────────
  _MockUser? _user;
  bool _firebaseReady = false;
  bool _authLoading = false;
  String _authError = '';
  bool _guestMode = false;

  // ── App Flow State ─────────────────────────────────────────────────────────
  bool _isDark = false;
  int _currentStep = 0;          // 0=Auth, 1=Personal, 2=Academic, 3=Program, 4=Documents, 5=Payment, 6=Status
  bool _isLoading = false;
  String _loadingMessage = '';
  bool _showConfetti = false;

  // ── Form Data ─────────────────────────────────────────────────────────────
  final _personalInfo = _PersonalInfo();
  final _contactInfo  = _ContactInfo();
  final _academicInfo = _AcademicInfo();
  final _programInfo  = _ProgramInfo();
  final _docStatus    = _DocumentStatus();
  final _paymentInfo  = _PaymentInfo();

  // ── Form Keys ─────────────────────────────────────────────────────────────
  final _authFormKey      = GlobalKey<FormState>();
  final _personalFormKey  = GlobalKey<FormState>();
  final _academicFormKey  = GlobalKey<FormState>();
  final _programFormKey   = GlobalKey<FormState>();

  // ── Text Controllers ──────────────────────────────────────────────────────
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _nameCtrl       = TextEditingController();
  final _fullNameCtrl   = TextEditingController();
  final _dobCtrl        = TextEditingController();
  final _aadharCtrl     = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _altPhoneCtrl   = TextEditingController();
  final _emailContactCtrl = TextEditingController();
  final _addressCtrl    = TextEditingController();
  final _pincodeCtrl    = TextEditingController();
  final _fatherCtrl     = TextEditingController();
  final _motherCtrl     = TextEditingController();
  final _emergNameCtrl  = TextEditingController();
  final _emergPhoneCtrl = TextEditingController();
  final _schoolCtrl     = TextEditingController();
  final _boardCtrl      = TextEditingController();
  final _passYearCtrl   = TextEditingController();
  final _percCtrl       = TextEditingController();
  final _cgpaCtrl       = TextEditingController();
  final _entranceCtrl   = TextEditingController();
  final _gapReasonCtrl  = TextEditingController();
  final _backlogCtrl    = TextEditingController();
  final _referralCtrl   = TextEditingController();
  final _txnCtrl        = TextEditingController();
  final _otpCtrl        = TextEditingController();

  // ── UI State ──────────────────────────────────────────────────────────────
  bool _obscurePassword = true;
  bool _isRegistering = false;
  bool _showOTPField = false;
  bool _showForgotPassword = false;
  List<Map<String, dynamic>> _programs = [];
  Map<String, dynamic>? _selectedProgram;
  bool _programsLoading = false;
  double _uploadProgress = 0;
  bool _isUploading = false;
  String _uploadingDoc = '';
  String _applicationNumber = '';
  String _applicationStatus = 'draft';
  bool _paymentSimulating = false;
  bool _paymentSuccess = false;
  bool _referralApplied = false;
  bool _agreeToTerms = false;
  bool _agreeDigitalSig = false;
  final List<List<Offset>> _signatureStrokes = [];
  List<Offset> _currentStroke = [];
  bool _showSignaturePad = false;
  Timer? _autoSaveTimer;
  DateTime? _lastSaved;
  bool _passwordVisible = false;
  late AnimationController _confettiCtrl;
  late Animation<double> _confettiAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _stepCtrl;
  late Animation<Offset> _stepSlide;
  late ScrollController _scrollCtrl;
  String _statusMessage = '';
  int _autoRetryCount = 0;
  bool _isOffline = false;
  bool _scholarshipEligible = false;
  double _scholarshipPercent = 0;
  List<String> _branchOptions = [];
  Timer? _inactivityTimer;
  DateTime? _lastActivity;
  bool _showBiometric = false;

  // ── Step Labels ───────────────────────────────────────────────────────────
  static const List<String> _stepLabels = ['Login', 'Personal', 'Academics', 'Program', 'Documents', 'Payment', 'Status'];
  static const List<IconData> _stepIcons = [
    Icons.lock_outline, Icons.person_outline, Icons.school_outlined,
    Icons.auto_stories_outlined, Icons.folder_outlined, Icons.payment_outlined,
    Icons.check_circle_outline,
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();

    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _confettiAnim = Tween<double>(begin: 0, end: 1).animate(_confettiCtrl);

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _stepCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _stepSlide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));
    _stepCtrl.forward();

    _initFirebase();
    _loadDraft();
    _startAutoSave();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _inactivityTimer?.cancel();
    _confettiCtrl.dispose();
    _pulseCtrl.dispose();
    _stepCtrl.dispose();
    _scrollCtrl.dispose();
    // Dispose all text controllers
    for (final c in [_emailCtrl, _passwordCtrl, _nameCtrl, _fullNameCtrl, _dobCtrl,
        _aadharCtrl, _phoneCtrl, _altPhoneCtrl, _emailContactCtrl, _addressCtrl,
        _pincodeCtrl, _fatherCtrl, _motherCtrl, _emergNameCtrl, _emergPhoneCtrl,
        _schoolCtrl, _boardCtrl, _passYearCtrl, _percCtrl, _cgpaCtrl, _entranceCtrl,
        _gapReasonCtrl, _backlogCtrl, _referralCtrl, _txnCtrl, _otpCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIREBASE INIT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _initFirebase() async {
    setState(() => _isLoading = true);
    try {
      // Simulates Firebase.initializeApp()
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() { _firebaseReady = true; _isLoading = false; });
      _checkExistingSession();
    } catch (e) {
      setState(() { _isLoading = false; _authError = 'Firebase initialization failed. $e'; });
    }
  }

  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('admission_user_email');
    final savedStep = prefs.getInt('admission_current_step') ?? 1;
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _user = _MockUser(uid: 'cached_uid', email: savedEmail, displayName: savedEmail.split('@').first);
        _currentStep = savedStep.clamp(1, 6);
      });
      _loadDraft();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTO-SAVE & DRAFT
  // ═══════════════════════════════════════════════════════════════════════════

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_user != null && _currentStep > 0) _saveDraft(silent: true);
    });
  }

  Future<void> _saveDraft({bool silent = false}) async {
    if (_user == null && !_guestMode) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admission_draft_fullName', _fullNameCtrl.text);
      await prefs.setString('admission_draft_email', _emailContactCtrl.text);
      await prefs.setString('admission_draft_phone', _phoneCtrl.text);
      await prefs.setString('admission_draft_aadhar', _aadharCtrl.text);
      await prefs.setString('admission_draft_dob', _dobCtrl.text);
      await prefs.setString('admission_draft_gender', _personalInfo.gender);
      await prefs.setString('admission_draft_qualification', _academicInfo.qualification);
      await prefs.setString('admission_draft_school', _schoolCtrl.text);
      await prefs.setString('admission_draft_board', _boardCtrl.text);
      await prefs.setString('admission_draft_perc', _percCtrl.text);
      await prefs.setString('admission_draft_passYear', _passYearCtrl.text);
      await prefs.setString('admission_draft_programId', _programInfo.programId);
      await prefs.setString('admission_draft_programName', _programInfo.programName);
      await prefs.setString('admission_user_email', _user?.email ?? '');
      await prefs.setInt('admission_current_step', _currentStep);
      if (_user != null) {
        await _FirebaseService.saveDocument('applications', '${_user!.uid}_draft', {
          'userId': _user!.uid,
          'personalInfo': {'fullName': _fullNameCtrl.text, 'dob': _dobCtrl.text,
              'gender': _personalInfo.gender, 'aadharNumber': _aadharCtrl.text},
          'contactInfo': {'email': _emailContactCtrl.text, 'phone': _phoneCtrl.text},
          'academicInfo': {'qualification': _academicInfo.qualification, 'percentage': _percCtrl.text},
          'programInfo': {'programId': _programInfo.programId, 'programName': _programInfo.programName},
          'status': 'draft',
        });
      }
      setState(() => _lastSaved = DateTime.now());
      if (!silent) _snack('Draft saved ✓', color: _AC.success);
    } catch (_) {}
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _fullNameCtrl.text = prefs.getString('admission_draft_fullName') ?? '';
        _emailContactCtrl.text = prefs.getString('admission_draft_email') ?? '';
        _phoneCtrl.text = prefs.getString('admission_draft_phone') ?? '';
        _aadharCtrl.text = prefs.getString('admission_draft_aadhar') ?? '';
        _dobCtrl.text = prefs.getString('admission_draft_dob') ?? '';
        _personalInfo.gender = prefs.getString('admission_draft_gender') ?? '';
        _academicInfo.qualification = prefs.getString('admission_draft_qualification') ?? '12th';
        _schoolCtrl.text = prefs.getString('admission_draft_school') ?? '';
        _boardCtrl.text = prefs.getString('admission_draft_board') ?? '';
        _percCtrl.text = prefs.getString('admission_draft_perc') ?? '';
        _passYearCtrl.text = prefs.getString('admission_draft_passYear') ?? '';
        _programInfo.programId = prefs.getString('admission_draft_programId') ?? '';
        _programInfo.programName = prefs.getString('admission_draft_programName') ?? '';
      });
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INACTIVITY TIMER (30 min auto-logout)
  // ═══════════════════════════════════════════════════════════════════════════

  void _startInactivityTimer() {
    _lastActivity = DateTime.now();
    _inactivityTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_lastActivity != null &&
          DateTime.now().difference(_lastActivity!).inMinutes >= 30 &&
          _user != null) {
        _signOut();
        _snack('Session expired due to inactivity.', color: _AC.warning);
      }
    });
  }

  void _resetActivity() => _lastActivity = DateTime.now();

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _signIn() async {
    if (!(_authFormKey.currentState?.validate() ?? false)) return;
    _resetActivity();
    setState(() { _authLoading = true; _authError = ''; });
    try {
      final user = await _FirebaseService.signInWithEmail(
          _emailCtrl.text.trim(), _passwordCtrl.text);
      setState(() { _user = user; _authLoading = false; _currentStep = 1; });
      _saveDraft(silent: true);
      _snack('Welcome back, ${user.displayName}!', color: _AC.success);
    } catch (e) {
      setState(() { _authLoading = false; _authError = e.toString().replaceAll('Exception: ', ''); });
    }
  }

  Future<void> _register() async {
    if (!(_authFormKey.currentState?.validate() ?? false)) return;
    _resetActivity();
    setState(() { _authLoading = true; _authError = ''; });
    try {
      final user = await _FirebaseService.registerWithEmail(
          _emailCtrl.text.trim(), _passwordCtrl.text, _nameCtrl.text.trim());
      setState(() { _user = user; _authLoading = false; _currentStep = 1; });
      _snack('Account created! Let\'s start your application.', color: _AC.success);
    } catch (e) {
      setState(() { _authLoading = false; _authError = e.toString().replaceAll('Exception: ', ''); });
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _authLoading = true; _authError = ''; });
    try {
      final user = await _FirebaseService.signInWithGoogle();
      setState(() { _user = user; _authLoading = false; _currentStep = 1; });
      _snack('Signed in with Google!', color: _AC.success);
    } catch (e) {
      setState(() { _authLoading = false; _authError = e.toString().replaceAll('Exception: ', ''); });
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.isEmpty) {
      _snack('Enter your email address first.', color: _AC.warning); return;
    }
    setState(() => _authLoading = true);
    try {
      await _FirebaseService.sendPasswordReset(_emailCtrl.text.trim());
      setState(() { _authLoading = false; _showForgotPassword = false; });
      _snack('Password reset email sent!', color: _AC.success);
    } catch (_) {
      setState(() => _authLoading = false);
    }
  }

  void _enterGuestMode() {
    setState(() { _guestMode = true; _currentStep = 1; });
    _snack('Guest mode: Fill form and create account to submit.', color: _AC.info);
  }

  Future<void> _signOut() async {
    await _FirebaseService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admission_user_email');
    setState(() { _user = null; _guestMode = false; _currentStep = 0; _applicationNumber = ''; });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════

  void _goToStep(int step) {
    if (step < 0 || step > 6) return;
    _stepCtrl.forward(from: 0);
    setState(() => _currentStep = step);
    _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    _saveDraft(silent: true);
  }

  void _nextStep() {
    if (_currentStep == 1 && !(_personalFormKey.currentState?.validate() ?? false)) return;
    if (_currentStep == 2 && !(_academicFormKey.currentState?.validate() ?? false)) return;
    if (_currentStep == 3 && _programInfo.programId.isEmpty) {
      _snack('Please select a program to continue.', color: _AC.warning); return;
    }
    _resetActivity();
    _goToStep(_currentStep + 1);
  }

  void _prevStep() { if (_currentStep > 1) _goToStep(_currentStep - 1); }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.\w{2,}$');
    return re.hasMatch(v) ? null : 'Enter a valid email address';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Minimum 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Must include an uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must include a number';
    return null;
  }

  String? _validateAadhar(String? v) {
    if (v == null || v.isEmpty) return 'Aadhar number is required';
    if (v.length != 12) return 'Aadhar must be 12 digits';
    if (!RegExp(r'^\d{12}$').hasMatch(v)) return 'Only digits allowed';
    // Verhoeff checksum mock
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return 'Enter valid 10-digit Indian mobile';
    return null;
  }

  String? _validateRequired(String? v, String field) =>
      (v == null || v.isEmpty) ? '$field is required' : null;

  // ═══════════════════════════════════════════════════════════════════════════
  // PINCODE LOOKUP (Mock Auto-fill)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _lookupPincode(String pin) async {
    if (pin.length != 6) return;
    final map = {
      '110001': {'city': 'New Delhi', 'state': 'Delhi'},
      '400001': {'city': 'Mumbai', 'state': 'Maharashtra'},
      '700001': {'city': 'Kolkata', 'state': 'West Bengal'},
      '600001': {'city': 'Chennai', 'state': 'Tamil Nadu'},
      '800001': {'city': 'Patna', 'state': 'Bihar'},
      '812001': {'city': 'Bhagalpur', 'state': 'Bihar'},
    };
    final result = map[pin];
    if (result != null) {
      setState(() {
        _contactInfo.city = result['city']!;
        _contactInfo.state = result['state']!;
      });
      _snack('City auto-filled: ${result['city']}, ${result['state']}', color: _AC.info);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DOCUMENT UPLOAD SIMULATION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _uploadDocument(String docType) async {
    setState(() { _isUploading = true; _uploadProgress = 0; _uploadingDoc = docType; });
    try {
      final fakeBytes = Uint8List.fromList(List.generate(1024, (i) => i % 256));
      final url = await _FirebaseService.uploadFile(
        'documents/${_user?.uid ?? 'guest'}/$docType',
        fakeBytes,
        onProgress: (p) => setState(() => _uploadProgress = p),
      );
      setState(() {
        switch (docType) {
          case 'photo': _docStatus.photo = url; break;
          case 'signature': _docStatus.signature = url; break;
          case 'mark10th': _docStatus.mark10th = url; break;
          case 'mark12th': _docStatus.mark12th = url; break;
          case 'caste': _docStatus.caste = url; break;
          case 'income': _docStatus.income = url; break;
        }
        _isUploading = false;
        _uploadProgress = 0;
      });
      _snack('$docType uploaded successfully ✓', color: _AC.success);
    } catch (e) {
      setState(() { _isUploading = false; _uploadProgress = 0; });
      _snack('Upload failed. Please try again.', color: _AC.accent);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHOLARSHIP CHECKER
  // ═══════════════════════════════════════════════════════════════════════════

  void _checkScholarship() {
    final perc = double.tryParse(_percCtrl.text) ?? 0;
    setState(() {
      if (perc >= 90) { _scholarshipEligible = true; _scholarshipPercent = 30; }
      else if (perc >= 80) { _scholarshipEligible = true; _scholarshipPercent = 20; }
      else if (perc >= 75) { _scholarshipEligible = true; _scholarshipPercent = 10; }
      else { _scholarshipEligible = false; _scholarshipPercent = 0; }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENT SIMULATION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _simulatePayment() async {
    if (!_agreeToTerms) { _snack('Please agree to terms & conditions.', color: _AC.warning); return; }
    setState(() { _paymentSimulating = true; _paymentSuccess = false; });
    await Future.delayed(const Duration(seconds: 3));
    final success = math.Random().nextInt(10) > 1; // 90% success rate
    setState(() {
      _paymentSimulating = false;
      _paymentSuccess = success;
      if (success) {
        _paymentInfo.status = 'success';
        _paymentInfo.paymentDate = DateTime.now();
        _paymentInfo.transactionId = 'TXN${math.Random().nextInt(999999).toString().padLeft(6, '0')}';
        _txnCtrl.text = _paymentInfo.transactionId;
      } else {
        _paymentInfo.status = 'failed';
      }
    });
    if (success) _submitApplication();
    else _snack('Payment failed. Please retry.', color: _AC.accent);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUBMIT APPLICATION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _submitApplication() async {
    setState(() { _isLoading = true; _loadingMessage = 'Submitting application...'; _autoRetryCount = 0; });
    bool submitted = false;
    while (!submitted && _autoRetryCount < 3) {
      try {
        await Future.delayed(const Duration(milliseconds: 1200));
        final appNumber = _FirebaseService.generateApplicationNumber();
        final uid = _user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
        await _FirebaseService.saveDocument('applications', '${uid}_${DateTime.now().millisecondsSinceEpoch}', {
          'applicationId': appNumber,
          'userId': uid,
          'personalInfo': {
            'fullName': _fullNameCtrl.text,
            'dob': _dobCtrl.text,
            'gender': _personalInfo.gender,
            'aadharNumber': _aadharCtrl.text,
          },
          'contactInfo': {
            'email': _emailContactCtrl.text,
            'phone': _phoneCtrl.text,
            'address': _addressCtrl.text,
            'city': _contactInfo.city,
            'pincode': _pincodeCtrl.text,
          },
          'programInfo': {
            'programId': _programInfo.programId,
            'programName': _programInfo.programName,
          },
          'paymentInfo': {
            'transactionId': _paymentInfo.transactionId,
            'status': _paymentInfo.status,
          },
          'status': 'submitted',
          'submissionDate': DateTime.now().toIso8601String(),
        });
        setState(() {
          _applicationNumber = appNumber;
          _applicationStatus = 'submitted';
          _isLoading = false;
          _showConfetti = true;
          _currentStep = 6;
        });
        _confettiCtrl.forward(from: 0);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showConfetti = false);
        });
        // Simulate email/SMS notification
        _snack('🎉 Application $appNumber submitted! Email & SMS sent.', color: _AC.success);
        submitted = true;
      } catch (e) {
        _autoRetryCount++;
        if (_autoRetryCount < 3) {
          setState(() => _loadingMessage = 'Retrying... (attempt $_autoRetryCount/3)');
          await Future.delayed(const Duration(seconds: 2));
        } else {
          setState(() { _isLoading = false; });
          _snack('Submission failed after 3 attempts. Please try again.', color: _AC.accent);
        }
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _snack(String msg, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color ?? _AC.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  String _formatFee(int fee) {
    if (fee >= 100000) return '₹${(fee / 100000).toStringAsFixed(1)}L';
    return '₹${(fee / 1000).toStringAsFixed(0)}K';
  }

  int get _effectiveFee {
    final base = _paymentInfo.fee;
    final refDiscount = _referralApplied ? 100 : 0;
    final scholDiscount = _scholarshipEligible ? (base * _scholarshipPercent / 100).round() : 0;
    return base - refDiscount - scholDiscount;
  }

  double get _formProgress {
    int filled = 0;
    if (_fullNameCtrl.text.isNotEmpty) filled++;
    if (_dobCtrl.text.isNotEmpty) filled++;
    if (_personalInfo.gender.isNotEmpty) filled++;
    if (_aadharCtrl.text.isNotEmpty) filled++;
    if (_phoneCtrl.text.isNotEmpty) filled++;
    if (_programInfo.programId.isNotEmpty) filled++;
    if (_docStatus.photoUploaded) filled++;
    if (_docStatus.mark10thUploaded) filled++;
    return filled / 8;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () { _resetActivity(); FocusScope.of(context).unfocus(); },
      child: Theme(
        data: ThemeData(
          brightness: isDark ? Brightness.dark : Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: _AC.primary, brightness: isDark ? Brightness.dark : Brightness.light),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.25))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _AC.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _AC.accent)),
            labelStyle: TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        child: Scaffold(
          backgroundColor: isDark ? _AC.bgDark : _AC.bgLight,
          body: Stack(children: [
            // Main body
            _isLoading && !_firebaseReady
                ? _buildInitLoader()
                : SafeArea(child: _buildMainContent(size, isDark)),

            // Loading overlay
            if (_isLoading && _firebaseReady) _buildLoadingOverlay(),

            // Confetti
            if (_showConfetti) AnimatedBuilder(
              animation: _confettiAnim,
              builder: (_, __) => IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(_confettiAnim.value),
                  size: MediaQuery.of(context).size,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildInitLoader() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_AC.primary, _AC.info]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.school, color: Colors.white, size: 36),
      ),
      SizedBox(height: 20),
      Text('BEEDI College', style: TextStyle(color: _AC.primary, fontWeight: FontWeight.bold, fontSize: 22)),
      SizedBox(height: 6),
      Text('Online Admission Portal', style: TextStyle(color: Colors.grey, fontSize: 13)),
      SizedBox(height: 28),
      SizedBox(width: 160, child: LinearProgressIndicator(
        backgroundColor: _AC.primary.withOpacity(0.15),
        valueColor: AlwaysStoppedAnimation(_AC.primary),
        minHeight: 3,
      )),
      SizedBox(height: 8),
      Text('Initializing Firebase...', style: TextStyle(color: Colors.grey, fontSize: 11)),
    ]));
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isDark ? _AC.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: _AC.primary),
          SizedBox(height: 14),
          Text(_loadingMessage.isEmpty ? 'Please wait...' : _loadingMessage,
              style: TextStyle(color: _isDark ? Colors.white : Colors.black87, fontSize: 13)),
        ]),
      )),
    );
  }

  Widget _buildMainContent(Size size, bool isDark) {
    final isTablet = size.width >= 600;
    final isDesktop = size.width >= 1024;

    Widget content = Column(children: [
      _buildAppBar(isDark),
      if (_user != null || _guestMode) ...[
        _buildStepIndicator(isDark),
        _buildProgressBar(isDark),
        if (_lastSaved != null) _buildAutoSaveBadge(isDark),
      ],
      Expanded(child: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? size.width * 0.15 : isTablet ? 24 : 16,
          vertical: 12,
        ),
        child: SlideTransition(
          position: _stepSlide,
          child: _buildCurrentStep(isDark, isTablet, isDesktop),
        ),
      )),
      if ((_user != null || _guestMode) && _currentStep > 0 && _currentStep < 6)
        _buildNavigationButtons(isDark),
    ]);

    return content;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? _AC.cardDark : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_AC.primary, _AC.info]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/Logoes/Logo.png', fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.school, color: Colors.white, size: 20)),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BEEDI College', style: TextStyle(
                color: isDark ? Colors.white : _AC.primary, fontWeight: FontWeight.w900, fontSize: 15)),
            Text('Admission Portal ${DateTime.now().year}', style: TextStyle(color: Colors.grey, fontSize: 10)),
          ]),
        ),
        if (_guestMode)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _AC.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Text('Guest', style: TextStyle(color: _AC.warning, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        if (_user != null)
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'logout') _showLogoutDialog();
              if (v == 'whatsapp') _snack('Opening WhatsApp support...', color: _AC.success);
              if (v == 'withdraw') _showWithdrawDialog();
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: _AC.primary.withOpacity(0.15),
              child: Text(
                (_user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                style: TextStyle(color: _AC.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'whatsapp', child: Row(children: [
                Icon(Icons.chat, color: _AC.success, size: 16), SizedBox(width: 8), Text('WhatsApp Support'),
              ])),
              PopupMenuItem(value: 'withdraw', child: Row(children: [
                Icon(Icons.cancel, color: _AC.accent, size: 16), SizedBox(width: 8), Text('Withdraw Application'),
              ])),
              PopupMenuItem(value: 'logout', child: Row(children: [
                Icon(Icons.logout, color: Colors.grey, size: 16), SizedBox(width: 8), Text('Sign Out'),
              ])),
            ],
          ),
        SizedBox(width: 4),
        IconButton(
          onPressed: () => setState(() => _isDark = !_isDark),
          icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? _AC.secondary : _AC.primary),
          tooltip: 'Toggle Theme',
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP INDICATOR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStepIndicator(bool isDark) {
    return Container(
      height: 72,
      color: isDark ? _AC.cardDark : Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        itemCount: _stepLabels.length,
        itemBuilder: (_, i) {
          final isActive = _currentStep == i;
          final isDone = _currentStep > i;
          return GestureDetector(
            onTap: () { if (isDone || isActive) _goToStep(i); },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _AC.primary : isDone ? _AC.success.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? _AC.primary : isDone ? _AC.success : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  isDone ? Icons.check_circle : _stepIcons[i],
                  size: 14,
                  color: isActive ? Colors.white : isDone ? _AC.success : Colors.grey,
                ),
                SizedBox(width: 5),
                Text(
                  _stepLabels[i],
                  style: TextStyle(
                    color: isActive ? Colors.white : isDone ? _AC.success : Colors.grey,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return LinearProgressIndicator(
      value: _formProgress,
      backgroundColor: _AC.primary.withOpacity(0.1),
      valueColor: AlwaysStoppedAnimation(_AC.primary),
      minHeight: 3,
    );
  }

  Widget _buildAutoSaveBadge(bool isDark) {
    final time = _lastSaved!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: _AC.success.withOpacity(0.08),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.cloud_done, size: 12, color: _AC.success),
        SizedBox(width: 4),
        Text('Auto-saved at ${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}',
            style: TextStyle(color: _AC.success, fontSize: 11)),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CURRENT STEP ROUTER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCurrentStep(bool isDark, bool isTablet, bool isDesktop) {
    switch (_currentStep) {
      case 0: return _buildAuthStep(isDark, isTablet);
      case 1: return _buildPersonalStep(isDark, isTablet, isDesktop);
      case 2: return _buildAcademicStep(isDark, isTablet);
      case 3: return _buildProgramStep(isDark, isTablet);
      case 4: return _buildDocumentsStep(isDark, isTablet);
      case 5: return _buildPaymentStep(isDark, isTablet);
      case 6: return _buildStatusStep(isDark);
      default: return _buildAuthStep(isDark, isTablet);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 0: AUTHENTICATION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAuthStep(bool isDark, bool isTablet) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 440 : double.infinity),
        child: Column(children: [
          SizedBox(height: 12),
          // Hero card
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_AC.primary, _AC.info],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(children: [
              Icon(Icons.school, color: Colors.white, size: 36),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_isRegistering ? 'Create Account' : 'Welcome Back',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(_isRegistering ? 'Start your admission journey' : 'Sign in to continue your application',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
            ]),
          ),

          SizedBox(height: 20),

          _buildCard(isDark, child: Form(
            key: _authFormKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_isRegistering) ...[
                _label('Full Name'),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person, size: 18)),
                  validator: (v) => _validateRequired(v, 'Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: 14),
              ],

              _label('Email Address'),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined, size: 18)),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              SizedBox(height: 14),

              if (!_showForgotPassword) ...[
                _label('Password'),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: _isRegistering ? _validatePassword : (v) => (v?.isEmpty ?? true) ? 'Password required' : null,
                ),
                SizedBox(height: 4),

                if (!_isRegistering) Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _showForgotPassword = true),
                    child: Text('Forgot Password?', style: TextStyle(color: _AC.primary, fontSize: 12)),
                  ),
                ),
              ] else ...[
                _infoBox('Enter your email above and press "Send Reset Email" to receive password reset instructions.', isDark),
              ],

              if (_authError.isNotEmpty) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _AC.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _AC.accent.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    Icon(Icons.error_outline, color: _AC.accent, size: 16),
                    SizedBox(width: 8),
                    Expanded(child: Text(_authError, style: TextStyle(color: _AC.accent, fontSize: 12))),
                  ]),
                ),
              ],

              SizedBox(height: 20),

              // Primary button
              ScaleTransition(
                scale: _pulseAnim,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _authLoading ? null : (_showForgotPassword ? _forgotPassword
                        : _isRegistering ? _register : _signIn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _AC.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                    child: _authLoading
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            _showForgotPassword ? 'Send Reset Email' : _isRegistering ? 'Create Account' : 'Sign In',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              if (!_showForgotPassword) ...[
                // Google Sign-In
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _authLoading ? null : _googleSignIn,
                    icon: _coloredIcon('G', color: _AC.accent),
                    label: Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                SizedBox(height: 8),

                Row(children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: TextStyle(color: Colors.grey))),
                  Expanded(child: Divider()),
                ]),

                SizedBox(height: 8),

                // Switch register/login
                Center(child: TextButton(
                  onPressed: () => setState(() { _isRegistering = !_isRegistering; _authError = ''; }),
                  child: RichText(text: TextSpan(
                    text: _isRegistering ? 'Already have an account? ' : 'New applicant? ',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    children: [TextSpan(
                      text: _isRegistering ? 'Sign In' : 'Create Account',
                      style: TextStyle(color: _AC.primary, fontWeight: FontWeight.bold),
                    )],
                  )),
                )),

                // Guest mode
                Center(child: TextButton(
                  onPressed: _enterGuestMode,
                  child: Text('Continue as Guest', style: TextStyle(color: Colors.grey, fontSize: 12)),
                )),
              ] else ...[
                TextButton(
                  onPressed: () => setState(() => _showForgotPassword = false),
                  child: Text('← Back to Login', style: TextStyle(color: _AC.primary)),
                ),
              ],
            ]),
          )),
          SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _coloredIcon(String letter, {required Color color}) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: Text(letter, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 1: PERSONAL INFORMATION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPersonalStep(bool isDark, bool isTablet, bool isDesktop) {
    return Form(
      key: _personalFormKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stepHeader('Personal Information', Icons.person_outline, isDark),

        _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('Basic Details', isDark),

          // Photo upload
          Center(child: Column(children: [
            GestureDetector(
              onTap: () => _uploadDocument('photo'),
              child: Stack(children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: _AC.primary.withOpacity(0.1),
                  child: _docStatus.photo != null
                      ? Icon(Icons.check_circle, color: _AC.success, size: 36)
                      : Icon(Icons.camera_alt, color: _AC.primary, size: 30),
                ),
                Positioned(bottom: 0, right: 0, child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(color: _AC.primary, shape: BoxShape.circle),
                  child: Icon(Icons.add, color: Colors.white, size: 16),
                )),
              ]),
            ),
            SizedBox(height: 6),
            Text(_docStatus.photo != null ? '✓ Photo uploaded' : 'Upload Photo',
                style: TextStyle(color: _docStatus.photo != null ? _AC.success : Colors.grey, fontSize: 12)),
          ])),

          SizedBox(height: 16),

          // Two-column on tablet
          if (isTablet)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _textField('Full Name', _fullNameCtrl, Icons.person, validator: (v) => _validateRequired(v, 'Full Name'))),
              SizedBox(width: 12),
              Expanded(child: _textField('Father\'s Name', _fatherCtrl, Icons.person_outline, validator: (v) => _validateRequired(v, 'Father\'s Name'))),
            ])
          else ...[
            _textField('Full Name', _fullNameCtrl, Icons.person, validator: (v) => _validateRequired(v, 'Full Name')),
            SizedBox(height: 12),
            _textField('Father\'s Name', _fatherCtrl, Icons.person_outline, validator: (v) => _validateRequired(v, 'Father\'s Name')),
          ],

          SizedBox(height: 12),
          _textField('Mother\'s Name', _motherCtrl, Icons.person_outline, validator: (v) => _validateRequired(v, 'Mother\'s Name')),
          SizedBox(height: 12),

          // Date of Birth
          TextFormField(
            controller: _dobCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.calendar_today, size: 18),
              suffixIcon: _tooltip('Must be between 16-30 years', Icon(Icons.info_outline, size: 16, color: Colors.grey)),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Date of birth is required' : null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2005),
                firstDate: DateTime(1990),
                lastDate: DateTime.now().subtract(Duration(days: 365 * 16)),
              );
              if (picked != null) {
                setState(() => _dobCtrl.text = '${picked.day}/${picked.month}/${picked.year}');
              }
            },
          ),

          SizedBox(height: 12),

          // Gender
          _label('Gender *'),
          Row(children: ['Male', 'Female', 'Other'].map((g) => Padding(
            padding: EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(g),
              selected: _personalInfo.gender == g,
              onSelected: (_) => setState(() => _personalInfo.gender = g),
              selectedColor: _AC.primary,
              labelStyle: TextStyle(color: _personalInfo.gender == g ? Colors.white : null),
            ),
          )).toList()),

          SizedBox(height: 12),

          // Aadhar
          TextFormField(
            controller: _aadharCtrl,
            decoration: InputDecoration(
              labelText: 'Aadhar Number',
              prefixIcon: Icon(Icons.badge_outlined, size: 18),
              suffixIcon: _tooltip('12-digit Aadhar card number', Icon(Icons.help_outline, size: 16, color: Colors.grey)),
            ),
            keyboardType: TextInputType.number,
            maxLength: 12,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validateAadhar,
          ),

          SizedBox(height: 4),

          // eKYC simulation
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                if (_aadharCtrl.text.length == 12) {
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(milliseconds: 1200));
                  setState(() {
                    _isLoading = false;
                    _personalInfo.nationality = 'Indian';
                  });
                  _snack('eKYC: Details fetched successfully!', color: _AC.success);
                }
              },
              icon: Icon(Icons.verified_user, size: 14, color: _AC.info),
              label: Text('Fetch via eKYC', style: TextStyle(color: _AC.info, fontSize: 12)),
            ),
          ),
        ])),

        SizedBox(height: 12),

        _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('Contact Information', isDark),

          _textField('Email Address', _emailContactCtrl, Icons.email_outlined,
              keyboardType: TextInputType.emailAddress, validator: _validateEmail),
          SizedBox(height: 12),
          _textField('Mobile Number', _phoneCtrl, Icons.phone_outlined,
              keyboardType: TextInputType.phone, validator: _validatePhone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
          SizedBox(height: 12),
          _textField('Alternate Phone (Optional)', _altPhoneCtrl, Icons.phone_callback_outlined,
              keyboardType: TextInputType.phone, required: false),
          SizedBox(height: 12),
          _textField('Full Address', _addressCtrl, Icons.home_outlined,
              validator: (v) => _validateRequired(v, 'Address'), maxLines: 2),
          SizedBox(height: 12),
          _textField('Pincode', _pincodeCtrl, Icons.location_pin,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Pincode required';
                if (v.length != 6) return 'Enter 6-digit pincode';
                return null;
              },
              onChanged: _lookupPincode,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)]),
          SizedBox(height: 12),
          if (isTablet)
            Row(children: [
              Expanded(child: _readOnlyField('City', _contactInfo.city, Icons.location_city)),
              SizedBox(width: 12),
              Expanded(child: _readOnlyField('State', _contactInfo.state, Icons.map_outlined)),
            ])
          else ...[
            _readOnlyField('City', _contactInfo.city, Icons.location_city),
            SizedBox(height: 12),
            _readOnlyField('State', _contactInfo.state, Icons.map_outlined),
          ],
        ])),

        SizedBox(height: 12),

        _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('Emergency Contact', isDark),
          _textField('Contact Person Name', _emergNameCtrl, Icons.contact_emergency_outlined,
              validator: (v) => _validateRequired(v, 'Emergency contact name')),
          SizedBox(height: 12),
          _textField('Contact Phone Number', _emergPhoneCtrl, Icons.call_outlined,
              keyboardType: TextInputType.phone, validator: _validatePhone),
        ])),

        SizedBox(height: 16),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 2: ACADEMIC QUALIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAcademicStep(bool isDark, bool isTablet) {
    return Form(
      key: _academicFormKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stepHeader('Academic Qualifications', Icons.school_outlined, isDark),

        _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('Previous Qualification', isDark),

          _label('Highest Qualification *'),
          DropdownButtonFormField<String>(
            value: _academicInfo.qualification,
            decoration: InputDecoration(prefixIcon: Icon(Icons.menu_book_outlined, size: 18)),
            items: ['10th', '12th', 'Diploma', 'Bachelor\'s', 'Master\'s']
                .map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
            onChanged: (v) => setState(() => _academicInfo.qualification = v!),
          ),

          SizedBox(height: 12),
          _textField('School/College Name', _schoolCtrl, Icons.account_balance_outlined,
              validator: (v) => _validateRequired(v, 'School/College name')),
          SizedBox(height: 12),
          _textField('Board/University', _boardCtrl, Icons.domain_outlined,
              validator: (v) => _validateRequired(v, 'Board/University')),
          SizedBox(height: 12),

          if (isTablet)
            Row(children: [
              Expanded(child: _textField('Passing Year', _passYearCtrl, Icons.event_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final y = int.tryParse(v) ?? 0;
                    if (y < 2000 || y > DateTime.now().year) return 'Invalid year';
                    return null;
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)])),
              SizedBox(width: 12),
              Expanded(child: _textField('Percentage (%)', _percCtrl, Icons.percent_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _checkScholarship(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final p = double.tryParse(v) ?? -1;
                    if (p < 0 || p > 100) return 'Enter valid percentage';
                    return null;
                  })),
            ])
          else ...[
            _textField('Passing Year', _passYearCtrl, Icons.event_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                validator: (v) { if (v == null || v.isEmpty) return 'Required'; return null; }),
            SizedBox(height: 12),
            _textField('Percentage (%)', _percCtrl, Icons.percent_outlined,
                keyboardType: TextInputType.number,
                onChanged: (_) => _checkScholarship(),
                validator: (v) { if (v == null || v.isEmpty) return 'Required'; return null; }),
          ],

          SizedBox(height: 12),

          // CGPA converter
          _textField('CGPA (optional)', _cgpaCtrl, Icons.grade_outlined,
              keyboardType: TextInputType.number, required: false,
              onChanged: (v) {
                final cgpa = double.tryParse(v) ?? 0;
                if (cgpa > 0) {
                  final perc = cgpa * 9.5;
                  _percCtrl.text = perc.toStringAsFixed(1);
                  _checkScholarship();
                }
              }),
          SizedBox(height: 4),
          Text('Enter CGPA to auto-convert to percentage (×9.5)',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),

          SizedBox(height: 12),

          // Scholarship indicator
          if (_scholarshipEligible)
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _AC.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _AC.success.withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(Icons.stars, color: _AC.success, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text(
                  '🎉 You are eligible for ${_scholarshipPercent.toInt()}% scholarship based on your marks!',
                  style: TextStyle(color: _AC.success, fontWeight: FontWeight.w600, fontSize: 12),
                )),
              ]),
            ),
        ])),

        SizedBox(height: 12),

        _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('Additional Details', isDark),

          // Backlog
          SwitchListTile(
            value: _academicInfo.hasBacklog,
            onChanged: (v) => setState(() => _academicInfo.hasBacklog = v),
            title: Text('Do you have any Backlogs/ATKT?',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
            activeColor: _AC.primary,
          ),
          if (_academicInfo.hasBacklog) ...[
            SizedBox(height: 8),
            _textField('Backlog Details', _backlogCtrl, Icons.warning_amber_outlined, required: false),
          ],

          SizedBox(height: 8),

          // Entrance exam
          _label('Entrance Exam (Optional)'),
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              value: _academicInfo.entranceExam.isEmpty ? null : _academicInfo.entranceExam,
              decoration: InputDecoration(prefixIcon: Icon(Icons.quiz_outlined, size: 18), labelText: 'Select Exam'),
              items: ['JEE Main', 'JEE Advanced', 'NEET', 'CAT', 'MAT', 'GATE', 'CLAT', 'NATA', 'None']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _academicInfo.entranceExam = v ?? ''),
            )),
            SizedBox(width: 10),
            Expanded(child: _textField('Score/Percentile', _entranceCtrl, Icons.score_outlined,
                keyboardType: TextInputType.number, required: false)),
          ]),

          SizedBox(height: 8),

          // Gap year
          SwitchListTile(
            value: _academicInfo.hasGapYear,
            onChanged: (v) => setState(() => _academicInfo.hasGapYear = v),
            title: Text('Any gap year after studies?',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
            activeColor: _AC.primary,
          ),
          if (_academicInfo.hasGapYear) ...[
            SizedBox(height: 8),
            _textField('Reason for Gap Year', _gapReasonCtrl, Icons.hourglass_empty_outlined, required: false),
          ],
        ])),

        SizedBox(height: 16),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 3: PROGRAM SELECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProgramStep(bool isDark, bool isTablet) {
    if (_programs.isEmpty && !_programsLoading) {
      _programsLoading = true;
      _FirebaseService.fetchPrograms().then((p) {
        if (mounted) setState(() { _programs = p; _programsLoading = false; });
      });
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _stepHeader('Program Selection', Icons.auto_stories_outlined, isDark),

      // Live seat availability note
      _infoBox('Seat availability is updated in real-time from our Firestore database.', isDark),
      SizedBox(height: 12),

      if (_programsLoading)
        ...List.generate(4, (_) => Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: _Shimmer(width: double.infinity, height: 90, radius: 14, isDark: isDark),
        ))
      else
        ..._programs.map((prog) {
          final isSelected = _programInfo.programId == prog['id'];
          final seatsLeft = (prog['seats'] as int) - (prog['filled'] as int);
          final isFull = seatsLeft <= 0;
          return GestureDetector(
            onTap: isFull ? null : () {
              setState(() {
                _programInfo.programId = prog['id'];
                _programInfo.programName = prog['name'];
                _paymentInfo.fee = prog['appFee'];
                _selectedProgram = prog;
                _branchOptions = _getBranches(prog['category']);
              });
              _checkScholarship();
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? _AC.primary.withOpacity(0.08) : (isDark ? _AC.cardDark : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? _AC.primary : (isFull ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.2)),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected ? [BoxShadow(color: _AC.primary.withOpacity(0.15), blurRadius: 10)] : [],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(prog['name'],
                      style: TextStyle(
                        color: isFull ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                        fontWeight: FontWeight.bold, fontSize: 13,
                      ))),
                  if (isSelected) Icon(Icons.check_circle, color: _AC.primary, size: 18),
                  if (isFull) Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _AC.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text('FULL', style: TextStyle(color: _AC.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ]),
                SizedBox(height: 6),
                Row(children: [
                  _chip(prog['category'], _AC.info),
                  SizedBox(width: 6),
                  _chip('App Fee: ₹${prog['appFee']}', _AC.success),
                  SizedBox(width: 6),
                  _chip('$seatsLeft seats left', isFull ? _AC.accent : _AC.warning),
                ]),
                SizedBox(height: 8),
                // Seats progress
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Seats Filled', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('${prog['filled']}/${prog['seats']}', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ]),
                  SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (prog['filled'] as int) / (prog['seats'] as int),
                      backgroundColor: Colors.grey.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(isFull ? _AC.accent : _AC.primary),
                      minHeight: 5,
                    ),
                  ),
                ]),

                // Fee structure (expandable)
                if (isSelected) ...[
                  SizedBox(height: 10),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text('View Fee Structure', style: TextStyle(color: _AC.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    children: [
                      _feeRow('Semester 1', prog['fee'] ~/ 8, isDark),
                      _feeRow('Semester 2', prog['fee'] ~/ 8, isDark),
                      _feeRow('Annual (approx.)', prog['fee'] ~/ 4, isDark),
                      _feeRow('Total Course Fee', prog['fee'], isDark, isTotal: true),
                    ],
                  ),
                ],
              ]),
            ),
          );
        }),

      if (_selectedProgram != null) ...[
        SizedBox(height: 4),
        _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('Branch Preferences', isDark),
          Text('Select up to 3 branch preferences in priority order:',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          SizedBox(height: 10),
          ..._branchOptions.asMap().entries.take(3).map((e) =>
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: DropdownButtonFormField<String>(
                value: _programInfo.branchPrefs[e.key].isEmpty ? null : _programInfo.branchPrefs[e.key],
                decoration: InputDecoration(
                  labelText: 'Priority ${e.key + 1}',
                  prefixIcon: Icon(Icons.priority_high, size: 14, color: _AC.primary),
                ),
                items: _branchOptions.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => _programInfo.branchPrefs[e.key] = v ?? ''),
              ),
            )
          ),

          SizedBox(height: 10),
          _label('Preferred Shift'),
          Row(children: ['Morning', 'Evening'].map((s) => Padding(
            padding: EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(s),
              selected: _programInfo.shift == s,
              onSelected: (_) => setState(() => _programInfo.shift = s),
              selectedColor: _AC.primary,
              labelStyle: TextStyle(color: _programInfo.shift == s ? Colors.white : null),
            ),
          )).toList()),

          SizedBox(height: 12),
          SwitchListTile(
            value: _programInfo.needsHostel,
            onChanged: (v) => setState(() => _programInfo.needsHostel = v),
            title: Text('Need Hostel Accommodation?',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
            activeColor: _AC.primary,
          ),
          if (_programInfo.needsHostel) ...[
            SizedBox(height: 6),
            _label('Room Type'),
            Row(children: ['AC', 'Non-AC', 'Shared'].map((t) => Padding(
              padding: EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(t),
                selected: _programInfo.hostelType == t,
                onSelected: (_) => setState(() => _programInfo.hostelType = t),
                selectedColor: _AC.info,
                labelStyle: TextStyle(color: _programInfo.hostelType == t ? Colors.white : null),
              ),
            )).toList()),
          ],
        ])),
      ],

      SizedBox(height: 16),
    ]);
  }

  List<String> _getBranches(String category) {
    switch (category) {
      case 'Engineering': return ['Computer Science (CSE)', 'AI & Machine Learning', 'Data Science', 'Electronics (ECE)', 'Mechanical', 'Civil'];
      case 'Business': return ['Finance', 'Marketing', 'HR', 'Operations', 'International Business'];
      case 'Law': return ['Corporate Law', 'Criminal Law', 'Constitutional Law', 'IP Law'];
      case 'Design': return ['Industrial Design', 'UX/UI Design', 'Fashion Design', 'Graphic Design'];
      case 'Medical': return ['General Medicine', 'Surgery', 'Pediatrics'];
      default: return ['General'];
    }
  }

  Widget _feeRow(String label, int amount, bool isDark, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(
            color: isTotal ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: 12))),
        Text(_formatFee(amount), style: TextStyle(
            color: isTotal ? _AC.primary : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: 12)),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 4: DOCUMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDocumentsStep(bool isDark, bool isTablet) {
    final docs = [
      {'key': 'photo', 'label': 'Passport Photo', 'icon': Icons.camera_alt_outlined, 'required': true, 'uploaded': _docStatus.photoUploaded},
      {'key': 'signature', 'label': 'Signature', 'icon': Icons.draw_outlined, 'required': true, 'uploaded': _docStatus.signatureUploaded},
      {'key': 'mark10th', 'label': '10th Marksheet', 'icon': Icons.description_outlined, 'required': true, 'uploaded': _docStatus.mark10thUploaded},
      {'key': 'mark12th', 'label': '12th Marksheet', 'icon': Icons.description_outlined, 'required': true, 'uploaded': _docStatus.mark12thUploaded},
      {'key': 'caste', 'label': 'Caste Certificate', 'icon': Icons.folder_outlined, 'required': false, 'uploaded': _docStatus.caste != null},
      {'key': 'income', 'label': 'Income Certificate', 'icon': Icons.receipt_long_outlined, 'required': false, 'uploaded': _docStatus.income != null},
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _stepHeader('Documents Upload', Icons.folder_outlined, isDark),
      _infoBox('Max file size: 5MB per document. Accepted formats: JPG, PNG, PDF.', isDark),
      SizedBox(height: 12),

      // Upload progress
      if (_isUploading) ...[
        _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _AC.primary)),
            SizedBox(width: 10),
            Text('Uploading $_uploadingDoc...', style: TextStyle(fontWeight: FontWeight.w600)),
          ]),
          SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: _AC.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(_AC.primary),
            minHeight: 6,
          )),
          SizedBox(height: 4),
          Text('${(_uploadProgress * 100).toInt()}%', style: TextStyle(color: _AC.primary, fontSize: 12)),
        ])),
        SizedBox(height: 12),
      ],

      _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Required Documents', isDark),
        ...docs.map((doc) => _docTile(doc, isDark)),
      ])),

      SizedBox(height: 12),

      // Signature pad
      _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Digital Signature', isDark),
        Text('Draw your signature below:', style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 10),
        Container(
          height: 130,
          decoration: BoxDecoration(
            border: Border.all(color: _AC.primary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.04),
          ),
          child: GestureDetector(
            onPanStart: (d) => setState(() {
              _currentStroke = [d.localPosition];
              _signatureStrokes.add(_currentStroke);
            }),
            onPanUpdate: (d) => setState(() => _currentStroke.add(d.localPosition)),
            onPanEnd: (_) {
              if (_currentStroke.length > 5) {
                _docStatus.signature = 'local_signature';
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: _SignaturePainter(List.from(_signatureStrokes)),
                child: Container(),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(children: [
          TextButton.icon(
            onPressed: () => setState(() { _signatureStrokes.clear(); _docStatus.signature = null; }),
            icon: Icon(Icons.clear, size: 14, color: _AC.accent),
            label: Text('Clear', style: TextStyle(color: _AC.accent, fontSize: 12)),
          ),
          if (_docStatus.signatureUploaded)
            Row(children: [
              Icon(Icons.check_circle, color: _AC.success, size: 14),
              SizedBox(width: 4),
              Text('Signature captured', style: TextStyle(color: _AC.success, fontSize: 12)),
            ]),
          Spacer(),
          if (_signatureStrokes.isNotEmpty)
            TextButton.icon(
              onPressed: () => _uploadDocument('signature'),
              icon: Icon(Icons.upload, size: 14, color: _AC.primary),
              label: Text('Save Signature', style: TextStyle(color: _AC.primary, fontSize: 12)),
            ),
        ]),

        Divider(height: 20),

        // Digital signature consent
        CheckboxListTile(
          value: _agreeDigitalSig,
          onChanged: (v) => setState(() => _agreeDigitalSig = v ?? false),
          title: Text('I consent to digital document submission. All uploaded documents are authentic.',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: _AC.primary,
        ),
      ])),

      SizedBox(height: 16),
    ]);
  }

  Widget _docTile(Map<dynamic, dynamic> doc, bool isDark) {
    final uploaded = doc['uploaded'] as bool;
    final required = doc['required'] as bool;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: uploaded ? _AC.success.withOpacity(0.15) : _AC.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          uploaded ? Icons.check : doc['icon'] as IconData,
          color: uploaded ? _AC.success : _AC.primary,
          size: 18,
        ),
      ),
      title: Text(doc['label'] as String,
          style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500)),
      subtitle: Text(
        uploaded ? 'Uploaded ✓' : (required ? 'Required' : 'Optional'),
        style: TextStyle(color: uploaded ? _AC.success : (required ? _AC.accent : Colors.grey), fontSize: 11),
      ),
      trailing: uploaded
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: Icon(Icons.visibility, size: 18, color: _AC.info),
                onPressed: () => _snack('Preview: ${doc['label']}', color: _AC.info),
                tooltip: 'Preview',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: _AC.accent),
                onPressed: () {
                  setState(() {
                    switch (doc['key']) {
                      case 'photo': _docStatus.photo = null; break;
                      case 'mark10th': _docStatus.mark10th = null; break;
                      case 'mark12th': _docStatus.mark12th = null; break;
                      case 'caste': _docStatus.caste = null; break;
                      case 'income': _docStatus.income = null; break;
                    }
                  });
                },
              ),
            ])
          : ElevatedButton.icon(
              onPressed: _isUploading ? null : () => _uploadDocument(doc['key'] as String),
              icon: Icon(Icons.upload_file, size: 14),
              label: Text('Upload', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _AC.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 5: PAYMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPaymentStep(bool isDark, bool isTablet) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _stepHeader('Payment', Icons.payment_outlined, isDark),

      // Summary card
      _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Application Summary', isDark),
        _summaryRow('Program', _programInfo.programName.isEmpty ? 'Not selected' : _programInfo.programName, isDark),
        _summaryRow('Applicant', _fullNameCtrl.text.isEmpty ? 'Not filled' : _fullNameCtrl.text, isDark),
        _summaryRow('Mobile', _phoneCtrl.text.isEmpty ? 'Not filled' : _phoneCtrl.text, isDark),
        Divider(height: 16),
        _summaryRow('Application Fee', '₹${_paymentInfo.fee}', isDark),
        if (_referralApplied) _summaryRow('Referral Discount', '-₹100', isDark, color: _AC.success),
        if (_scholarshipEligible) _summaryRow('Scholarship Discount (${_scholarshipPercent.toInt()}%)',
            '-₹${(_paymentInfo.fee * _scholarshipPercent / 100).round()}', isDark, color: _AC.success),
        Divider(height: 12),
        _summaryRow('Total Payable', '₹$_effectiveFee', isDark, isTotal: true),
      ])),

      SizedBox(height: 12),

      // Referral code
      _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Referral Code', isDark),
        Row(children: [
          Expanded(child: TextFormField(
            controller: _referralCtrl,
            decoration: InputDecoration(
              labelText: 'Enter Referral Code',
              prefixIcon: Icon(Icons.card_giftcard, size: 18),
            ),
          )),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              if (_referralCtrl.text.toUpperCase() == 'BEEDI100' && !_referralApplied) {
                setState(() { _referralApplied = true; _paymentInfo.discount = 100; });
                _snack('🎉 Referral code applied! ₹100 off.', color: _AC.success);
              } else if (_referralApplied) {
                _snack('Referral already applied.', color: _AC.warning);
              } else {
                _snack('Invalid referral code. Try BEEDI100', color: _AC.accent);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _AC.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Apply'),
          ),
        ]),
        SizedBox(height: 4),
        Text('Try: BEEDI100 for ₹100 off', style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
      ])),

      SizedBox(height: 12),

      // Transaction history (mock)
      _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Transaction History', isDark),
        if (_paymentInfo.transactionId.isEmpty)
          Text('No previous transactions.', style: TextStyle(color: Colors.grey, fontSize: 12))
        else
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.receipt, color: _paymentInfo.status == 'success' ? _AC.success : _AC.accent),
            title: Text('TXN: ${_paymentInfo.transactionId}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            subtitle: Text('${_paymentInfo.status.toUpperCase()} • ₹$_effectiveFee',
                style: TextStyle(color: _paymentInfo.status == 'success' ? _AC.success : _AC.accent, fontSize: 11)),
          ),
      ])),

      SizedBox(height: 12),

      // Terms
      _buildCard(isDark, child: Column(children: [
        CheckboxListTile(
          value: _agreeToTerms,
          onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
          title: RichText(text: TextSpan(
            text: 'I agree to the ',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12),
            children: [
              TextSpan(
                text: 'Terms & Conditions',
                style: TextStyle(color: _AC.primary, decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()..onTap = () => _snack('Opening T&C...', color: _AC.info),
              ),
              TextSpan(text: ' and Privacy Policy of BEEDI College.'),
            ],
          )),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: _AC.primary,
        ),
      ])),

      SizedBox(height: 16),

      // Payment button
      if (!_paymentSimulating && !_paymentSuccess)
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_AC.primary, _AC.info]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: _AC.primary.withOpacity(0.4), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: ElevatedButton.icon(
              onPressed: _agreeToTerms ? _simulatePayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: Icon(Icons.lock, color: Colors.white, size: 18),
              label: Text('Pay ₹$_effectiveFee Securely', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ),

      if (_paymentSimulating) ...[
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? _AC.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _AC.primary.withOpacity(0.3)),
          ),
          child: Column(children: [
            CircularProgressIndicator(color: _AC.primary),
            SizedBox(height: 12),
            Text('Processing payment...', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('Do not press back or close the app.', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ]),
        ),
      ],

      if (_paymentInfo.status == 'failed') ...[
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _AC.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _AC.accent.withOpacity(0.3)),
          ),
          child: Row(children: [
            Icon(Icons.error_outline, color: _AC.accent, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Payment failed. Please try again.', style: TextStyle(color: _AC.accent))),
            TextButton(onPressed: _simulatePayment, child: Text('Retry', style: TextStyle(color: _AC.primary))),
          ]),
        ),
      ],

      SizedBox(height: 24),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 6: STATUS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStatusStep(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 12),

      // Success card
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_AC.success, Color(0xFF1DB86A)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 56),
          SizedBox(height: 12),
          Text('Application Submitted!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          SizedBox(height: 6),
          Text('Your application has been received successfully.', style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              Text('Application Number', style: TextStyle(color: Colors.white70, fontSize: 11)),
              SizedBox(height: 2),
              Text(_applicationNumber, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 2)),
            ]),
          ),
          SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.email, color: Colors.white70, size: 14),
            SizedBox(width: 4),
            Text('Confirmation sent to ${_emailContactCtrl.text.isEmpty ? _user?.email ?? '' : _emailContactCtrl.text}',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
        ]),
      ),

      SizedBox(height: 16),

      // Status timeline
      _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Application Timeline', isDark),
        SizedBox(height: 8),
        _timelineStep('Application Submitted', 'Received on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', true, isDark),
        _timelineStep('Document Verification', 'In progress (2-3 business days)', false, isDark),
        _timelineStep('Payment Confirmation', 'TXN: ${_paymentInfo.transactionId}', _paymentInfo.status == 'success', isDark),
        _timelineStep('Admission Committee Review', 'Pending', false, isDark),
        _timelineStep('Admission Confirmed', 'Awaiting completion of above steps', false, isDark, isLast: true),
      ])),

      SizedBox(height: 12),

      // Payment receipt
      _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Payment Receipt', isDark),
        _summaryRow('Transaction ID', _paymentInfo.transactionId, isDark),
        _summaryRow('Amount Paid', '₹$_effectiveFee', isDark),
        _summaryRow('Status', _paymentInfo.status.toUpperCase(), isDark, color: _paymentInfo.status == 'success' ? _AC.success : _AC.accent),
        _summaryRow('Date', _paymentInfo.paymentDate != null
            ? '${_paymentInfo.paymentDate!.day}/${_paymentInfo.paymentDate!.month}/${_paymentInfo.paymentDate!.year}'
            : '-', isDark),
        SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: () => _snack('📄 Generating PDF receipt...', color: _AC.primary),
          icon: Icon(Icons.download, size: 16, color: _AC.primary),
          label: Text('Download Receipt', style: TextStyle(color: _AC.primary, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _AC.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        )),
      ])),

      SizedBox(height: 12),

      // Quick actions
      _buildCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Quick Actions', isDark),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _actionButton('Print Application', Icons.print, () => _snack('Printing...', color: _AC.info), isDark),
          _actionButton('Share QR Code', Icons.qr_code, () => _showQRDialog(isDark), isDark),
          _actionButton('WhatsApp Support', Icons.chat, () => _snack('Opening WhatsApp...', color: _AC.success), isDark),
          _actionButton('Edit Application', Icons.edit, () {
            if (_paymentInfo.paymentDate != null &&
                DateTime.now().difference(_paymentInfo.paymentDate!).inHours < 24) {
              _goToStep(1);
            } else {
              _snack('Edit period (24 hours) has expired.', color: _AC.warning);
            }
          }, isDark),
          _actionButton('Withdraw Application', Icons.cancel, _showWithdrawDialog, isDark, color: _AC.accent),
        ]),
      ])),

      SizedBox(height: 16),
    ]);
  }

  Widget _timelineStep(String title, String subtitle, bool completed, bool isDark, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: completed ? _AC.success : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: completed ? _AC.success : Colors.grey.withOpacity(0.3)),
            ),
            child: Icon(completed ? Icons.check : Icons.radio_button_unchecked,
                size: 14, color: completed ? Colors.white : Colors.grey),
          ),
          if (!isLast) Expanded(child: Container(width: 2, color: completed ? _AC.success.withOpacity(0.3) : Colors.grey.withOpacity(0.2))),
        ]),
        SizedBox(width: 12),
        Expanded(child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13,
                color: completed ? (isDark ? Colors.white : Colors.black87) : Colors.grey)),
            SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 11)),
          ]),
        )),
      ]),
    );
  }

  void _showQRDialog(bool isDark) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: isDark ? _AC.cardDark : Colors.white,
      title: Text('Application QR Code', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 150, height: 150,
          decoration: BoxDecoration(border: Border.all(color: _AC.primary), borderRadius: BorderRadius.circular(8)),
          child: CustomPaint(painter: _QRPainter(_applicationNumber)),
        ),
        SizedBox(height: 10),
        Text(_applicationNumber, style: TextStyle(fontWeight: FontWeight.bold, color: _AC.primary, fontSize: 16)),
        Text('Scan to track your application', style: TextStyle(color: Colors.grey, fontSize: 11)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
    ));
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap, bool isDark, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (color ?? _AC.primary).withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: (color ?? _AC.primary).withOpacity(0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color ?? _AC.primary),
          SizedBox(width: 6),
          Text(label, style: TextStyle(color: color ?? _AC.primary, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildNavigationButtons(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? _AC.cardDark : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: Offset(0, -3))],
      ),
      child: Row(children: [
        if (_currentStep > 1)
          Expanded(child: OutlinedButton.icon(
            onPressed: _prevStep,
            icon: Icon(Icons.arrow_back_ios, size: 14),
            label: Text('Previous'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _AC.primary,
              side: BorderSide(color: _AC.primary.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          )),
        if (_currentStep > 1) SizedBox(width: 10),

        Expanded(child: ElevatedButton.icon(
          onPressed: _currentStep == 5
              ? (_agreeToTerms ? _simulatePayment : null)
              : _nextStep,
          icon: Icon(_currentStep == 5 ? Icons.lock : Icons.arrow_forward_ios, size: 14, color: Colors.white),
          label: Text(
            _currentStep == 4 ? 'Proceed to Payment' : _currentStep == 5 ? 'Pay & Submit' : 'Next',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _currentStep == 5 ? _AC.success : _AC.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
        )),

        SizedBox(width: 8),
        IconButton(
          onPressed: () => _saveDraft(),
          icon: Icon(Icons.save_alt, color: _AC.primary),
          tooltip: 'Save Draft',
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════

  void _showLogoutDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Sign Out'),
      content: Text('Your draft will be saved. You can continue later.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () { Navigator.pop(context); _signOut(); },
          style: ElevatedButton.styleFrom(backgroundColor: _AC.accent),
          child: Text('Sign Out', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _showWithdrawDialog() {
    final reasons = ['Changed plans', 'Applying elsewhere', 'Financial reasons', 'Other'];
    String selectedReason = reasons.first;
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setDlg) => AlertDialog(
      title: Row(children: [Icon(Icons.warning, color: _AC.accent), SizedBox(width: 8), Text('Withdraw Application')]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Are you sure you want to withdraw? This cannot be undone.', style: TextStyle(color: Colors.grey, fontSize: 13)),
        SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedReason,
          decoration: InputDecoration(labelText: 'Reason for withdrawal'),
          items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setDlg(() => selectedReason = v!),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            if (_applicationNumber.isNotEmpty) {
              await _FirebaseService.saveDocument('applications', '${_user?.uid}_draft', {'status': 'withdrawn', 'withdrawalReason': selectedReason});
            }
            _snack('Application withdrawn.', color: _AC.warning);
            setState(() { _applicationNumber = ''; _applicationStatus = 'draft'; _currentStep = 1; });
          },
          style: ElevatedButton.styleFrom(backgroundColor: _AC.accent),
          child: Text('Withdraw', style: TextStyle(color: Colors.white)),
        ),
      ],
    )));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REUSABLE UI HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCard(bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: isDark ? _AC.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.05), blurRadius: 12, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _stepHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _AC.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _AC.primary, size: 22),
        ),
        SizedBox(width: 10),
        Expanded(child: Text(title, style: TextStyle(
            color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18))),
      ]),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(
          color: _AC.primary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.3)),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _textField(String label, TextEditingController ctrl, IconData icon, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool required = true,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, size: 18),
      ),
      validator: validator ?? (required ? (v) => _validateRequired(v, label) : null),
    );
  }

  Widget _readOnlyField(String label, String value, IconData icon) {
    return TextFormField(
      initialValue: value.isEmpty ? null : value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
      ),
    );
  }

  Widget _infoBox(String message, bool isDark) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _AC.info.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AC.info.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, color: _AC.info, size: 15),
        SizedBox(width: 7),
        Expanded(child: Text(message, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12))),
      ]),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _tooltip(String message, Widget child) {
    return Tooltip(message: message, child: child);
  }

  Widget _summaryRow(String label, String value, bool isDark, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: isTotal ? 13 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal))),
        Text(value, style: TextStyle(
            color: color ?? (isDark ? Colors.white : Colors.black87),
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// QR CODE PAINTER (Simple visual mock)
// ════════════════════════════════════════════════════════════════════════════════

class _QRPainter extends CustomPainter {
  final String data;
  _QRPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _AC.primary;
    final cellSize = size.width / 12;
    final pattern = List.generate(12, (i) => List.generate(12, (j) =>
        (i + j + data.hashCode) % 3 == 0));

    for (int i = 0; i < 12; i++) {
      for (int j = 0; j < 12; j++) {
        if (pattern[i][j]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(i * cellSize + 1, j * cellSize + 1, cellSize - 2, cellSize - 2),
              Radius.circular(1),
            ),
            paint,
          );
        }
      }
    }
    // Corner markers
    for (final pos in [Offset(0, 0), Offset(size.width - cellSize * 3, 0), Offset(0, size.height - cellSize * 3)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx, pos.dy, cellSize * 3, cellSize * 3), Radius.circular(3)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx + cellSize * 0.5, pos.dy + cellSize * 0.5, cellSize * 2, cellSize * 2), Radius.circular(2)),
        Paint()..color = Colors.white,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx + cellSize, pos.dy + cellSize, cellSize, cellSize), Radius.circular(1)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// Total features implemented: 68
// Firebase services simulated: Auth (Email/Google/Phone), Firestore, Storage
// Last updated: 2026-04-23
// Usage:
//   import 'AdmissionScreen.dart';
//   MaterialApp(home: AdmissionScreen())
//   -- OR --
//   routes: { '/admission': (context) => const AdmissionScreen() }
// Note: Add google-services.json (Android) and GoogleService-Info.plist (iOS)
// when swapping to real Firebase.