// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

// =============================================================================
// GREEN PROFESSIONAL THEME
// =============================================================================

class GreenTheme {
  static const Color primary = Color(0xFF0D3B2E);
  static const Color primaryDark = Color(0xFF082619);
  static const Color primaryLight = Color(0xFF145C43);
  static const Color accent = Color(0xFF00C853);
  static const Color accentLight = Color(0xFF69F0AE);
  static const Color accentDark = Color(0xFF00953D);
  static const Color teal = Color(0xFF00897B);
  static const Color tealLight = Color(0xFF4DB6AC);

  static const Color background = Color(0xFFF1F8F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF0FAF4);
  static const Color border = Color(0xFFD0E8D8);
  static const Color borderDark = Color(0xFFADD4BA);

  static const Color statusCalled = Color(0xFF00C853);
  static const Color statusPending = Color(0xFFFFB300);
  static const Color statusUnreachable = Color(0xFFE53935);
  static const Color statusFollowUp = Color(0xFF7B1FA2);
  static const Color statusBusy = Color(0xFF0288D1);
  static const Color statusSwitchedOff = Color(0xFF757575);
  static const Color statusParentContacted = Color(0xFF00897B);
  static const Color statusCallBack = Color(0xFFF57C00);
  static const Color statusInterested = Color(0xFF2E7D32);
  static const Color statusNotInterested = Color(0xFFC62828);

  static const Color textPrimary = Color(0xFF1A2E1E);
  static const Color textSecondary = Color(0xFF3D6B4F);
  static const Color textMuted = Color(0xFF7A9E84);
  static const Color textOnGreen = Color(0xFFFFFFFF);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00953D)],
  );

  static BoxDecoration cardDecoration({
    double radius = 16,
    bool elevated = false,
  }) {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: const Color(0xFF00C853).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  static TextStyle displayFont({
    double size = 16,
    FontWeight weight = FontWeight.w600,
    Color color = textPrimary,
  }) => GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: weight,
    color: color,
  );

  static TextStyle bodyFont({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = textSecondary,
  }) => GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
}

// =============================================================================
// ENUMS
// =============================================================================

enum CallStatus {
  pending,
  called,
  notReachable,
  switchedOff,
  busy,
  parentContacted,
  followUpRequired,
  interested,
  notInterested,
  callBackLater,
}

enum FeeStatus { paid, partial, pending, overdue }

enum BatchStatus { active, completed, upcoming }

enum FirebaseConnectionStatus { connected, syncing, disconnected, error }

// =============================================================================
// SAFE PARSE HELPERS
// =============================================================================

class _Safe {
  static String str(Map<String, dynamic> d, String k, [String def = '']) {
    try {
      return (d[k] ?? def).toString();
    } catch (_) {
      return def;
    }
  }

  static int intVal(Map<String, dynamic> d, String k, [int def = 0]) {
    try {
      return (d[k] as num?)?.toInt() ?? def;
    } catch (_) {
      return def;
    }
  }

  static double dblVal(Map<String, dynamic> d, String k, [double def = 0]) {
    try {
      return (d[k] as num?)?.toDouble() ?? def;
    } catch (_) {
      return def;
    }
  }

  static bool boolVal(Map<String, dynamic> d, String k, [bool def = false]) {
    try {
      return (d[k] as bool?) ?? def;
    } catch (_) {
      return def;
    }
  }

  static DateTime dateTime(Map<String, dynamic> d, String k) {
    try {
      final v = d[k];
      if (v is Timestamp) return v.toDate();
      return DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  static DateTime? dateTimeNullable(Map<String, dynamic> d, String k) {
    try {
      final v = d[k];
      if (v is Timestamp) return v.toDate();
      return null;
    } catch (_) {
      return null;
    }
  }

  static List<String> strList(Map<String, dynamic> d, String k) {
    try {
      return List<String>.from(d[k] ?? []);
    } catch (_) {
      return [];
    }
  }

  static T enumVal<T extends Enum>(
    List<T> values,
    Map<String, dynamic> d,
    String k,
    T def,
  ) {
    try {
      final name = d[k]?.toString() ?? '';
      return values.firstWhere((e) => e.name == name, orElse: () => def);
    } catch (_) {
      return def;
    }
  }

  static Map<String, dynamic> safeMap(DocumentSnapshot doc) {
    try {
      final data = doc.data();
      if (data == null) return {};
      return data as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

// =============================================================================
// MODELS
// =============================================================================

class FacultyModel {
  final String id;
  final String name;
  final String facultyId;
  final String mobile;
  final String email;
  final String department;
  final String designation;
  final String? profileImageUrl;
  final List<String> assignedBatches;
  final int totalCalls;
  final int totalStudentsManaged;
  final DateTime createdAt;

  const FacultyModel({
    required this.id,
    required this.name,
    required this.facultyId,
    required this.mobile,
    required this.email,
    required this.department,
    this.designation = 'Faculty',
    this.profileImageUrl,
    this.assignedBatches = const [],
    this.totalCalls = 0,
    this.totalStudentsManaged = 0,
    required this.createdAt,
  });

  factory FacultyModel.fromFirestore(DocumentSnapshot doc) {
    final d = _Safe.safeMap(doc);
    return FacultyModel(
      id: doc.id,
      name: _Safe.str(d, 'name'),
      facultyId: _Safe.str(d, 'facultyId'),
      mobile: _Safe.str(d, 'mobile'),
      email: _Safe.str(d, 'email'),
      department: _Safe.str(d, 'department'),
      designation: _Safe.str(d, 'designation', 'Faculty'),
      profileImageUrl: d['profileImageUrl'] as String?,
      assignedBatches: _Safe.strList(d, 'assignedBatches'),
      totalCalls: _Safe.intVal(d, 'totalCalls'),
      totalStudentsManaged: _Safe.intVal(d, 'totalStudentsManaged'),
      createdAt: _Safe.dateTime(d, 'createdAt'),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'facultyId': facultyId,
    'mobile': mobile,
    'email': email,
    'department': department,
    'designation': designation,
    'profileImageUrl': profileImageUrl,
    'assignedBatches': assignedBatches,
    'totalCalls': totalCalls,
    'totalStudentsManaged': totalStudentsManaged,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  FacultyModel copyWith({
    String? name,
    String? facultyId,
    String? mobile,
    String? email,
    String? department,
    String? designation,
    List<String>? assignedBatches,
    int? totalCalls,
    int? totalStudentsManaged,
  }) => FacultyModel(
    id: id,
    name: name ?? this.name,
    facultyId: facultyId ?? this.facultyId,
    mobile: mobile ?? this.mobile,
    email: email ?? this.email,
    department: department ?? this.department,
    designation: designation ?? this.designation,
    profileImageUrl: profileImageUrl,
    assignedBatches: assignedBatches ?? this.assignedBatches,
    totalCalls: totalCalls ?? this.totalCalls,
    totalStudentsManaged: totalStudentsManaged ?? this.totalStudentsManaged,
    createdAt: createdAt,
  );
}

class BatchModel {
  final String id;
  final String batchName;
  final String courseName;
  final String batchCode;
  final String facultyName;
  final String facultyId;
  final String batchTiming;
  final String startTime;
  final String endTime;
  final DateTime createdAt;
  final int studentCount;
  final BatchStatus status;
  final String? notes;

  const BatchModel({
    required this.id,
    required this.batchName,
    required this.courseName,
    required this.batchCode,
    required this.facultyName,
    required this.facultyId,
    required this.batchTiming,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.studentCount = 0,
    this.status = BatchStatus.active,
    this.notes,
  });

  String get timing => startTime.isNotEmpty && endTime.isNotEmpty
      ? '$startTime - $endTime'
      : batchTiming;

  factory BatchModel.fromFirestore(DocumentSnapshot doc) {
    final d = _Safe.safeMap(doc);
    return BatchModel(
      id: doc.id,
      batchName: _Safe.str(
        d,
        'batchName',
        _Safe.str(d, 'name', 'Unnamed Batch'),
      ),
      courseName: _Safe.str(d, 'courseName'),
      batchCode: _Safe.str(d, 'batchCode'),
      facultyName: _Safe.str(d, 'facultyName'),
      facultyId: _Safe.str(d, 'facultyId'),
      batchTiming: _Safe.str(d, 'batchTiming'),
      startTime: _Safe.str(d, 'startTime'),
      endTime: _Safe.str(d, 'endTime'),
      createdAt: _Safe.dateTime(d, 'createdAt'),
      studentCount: _Safe.intVal(d, 'studentCount'),
      status: _Safe.enumVal(
        BatchStatus.values,
        d,
        'status',
        BatchStatus.active,
      ),
      notes: d['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'batchName': batchName,
    'courseName': courseName,
    'batchCode': batchCode,
    'facultyName': facultyName,
    'facultyId': facultyId,
    'batchTiming': batchTiming,
    'startTime': startTime,
    'endTime': endTime,
    'createdAt': Timestamp.fromDate(createdAt),
    'studentCount': studentCount,
    'status': status.name,
    'notes': notes,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  BatchModel copyWith({
    String? batchName,
    String? courseName,
    String? batchCode,
    String? facultyName,
    String? facultyId,
    String? batchTiming,
    String? startTime,
    String? endTime,
    int? studentCount,
    BatchStatus? status,
    String? notes,
  }) => BatchModel(
    id: id,
    batchName: batchName ?? this.batchName,
    courseName: courseName ?? this.courseName,
    batchCode: batchCode ?? this.batchCode,
    facultyName: facultyName ?? this.facultyName,
    facultyId: facultyId ?? this.facultyId,
    batchTiming: batchTiming ?? this.batchTiming,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    createdAt: createdAt,
    studentCount: studentCount ?? this.studentCount,
    status: status ?? this.status,
    notes: notes ?? this.notes,
  );
}

class StudentModel {
  final String id;
  final String studentName;
  final String studentId;
  final String mobileNumber;
  final String parentNumber;
  final String email;
  final String address;
  final String gender;
  final double attendance;
  final FeeStatus feeStatus;
  final CallStatus callingStatus;
  final String course;
  final String batchId;
  final String batchName;
  final String? notes;
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final String? lastCalledBy;
  final DateTime? lastCalledAt;
  final int callAttempts;

  const StudentModel({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.mobileNumber,
    required this.parentNumber,
    this.email = '',
    this.address = '',
    this.gender = '',
    this.attendance = 0,
    this.feeStatus = FeeStatus.pending,
    this.callingStatus = CallStatus.pending,
    this.course = '',
    required this.batchId,
    required this.batchName,
    this.notes,
    this.profilePhotoUrl,
    required this.createdAt,
    this.lastCalledBy,
    this.lastCalledAt,
    this.callAttempts = 0,
  });

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final d = _Safe.safeMap(doc);
    return StudentModel(
      id: doc.id,
      studentName: _Safe.str(d, 'studentName', _Safe.str(d, 'name', 'Unknown')),
      studentId: _Safe.str(d, 'studentId'),
      mobileNumber: _Safe.str(d, 'mobileNumber', _Safe.str(d, 'mobile')),
      parentNumber: _Safe.str(d, 'parentNumber', _Safe.str(d, 'parentMobile')),
      email: _Safe.str(d, 'email'),
      address: _Safe.str(d, 'address'),
      gender: _Safe.str(d, 'gender'),
      attendance: _Safe.dblVal(d, 'attendance'),
      feeStatus: _Safe.enumVal(
        FeeStatus.values,
        d,
        'feeStatus',
        FeeStatus.pending,
      ),
      callingStatus: _Safe.enumVal(
        CallStatus.values,
        d,
        'callingStatus',
        CallStatus.pending,
      ),
      course: _Safe.str(d, 'course'),
      batchId: _Safe.str(d, 'batchId'),
      batchName: _Safe.str(d, 'batchName'),
      notes: d['notes'] as String?,
      profilePhotoUrl: d['profilePhotoUrl'] as String?,
      createdAt: _Safe.dateTime(d, 'createdAt'),
      lastCalledBy: d['lastCalledBy'] as String?,
      lastCalledAt: _Safe.dateTimeNullable(d, 'lastCalledAt'),
      callAttempts: _Safe.intVal(d, 'callAttempts'),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'studentName': studentName,
    'studentId': studentId,
    'mobileNumber': mobileNumber,
    'parentNumber': parentNumber,
    'email': email,
    'address': address,
    'gender': gender,
    'attendance': attendance,
    'feeStatus': feeStatus.name,
    'callingStatus': callingStatus.name,
    'course': course,
    'batchId': batchId,
    'batchName': batchName,
    'notes': notes,
    'profilePhotoUrl': profilePhotoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastCalledBy': lastCalledBy,
    'lastCalledAt': lastCalledAt != null
        ? Timestamp.fromDate(lastCalledAt!)
        : null,
    'callAttempts': callAttempts,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class CallLog {
  final String id;
  final DateTime calledAt;
  final CallStatus status;
  final String calledBy;
  final int duration;
  final String? notes;
  final DateTime? followUpDate;

  const CallLog({
    required this.id,
    required this.calledAt,
    required this.status,
    required this.calledBy,
    this.duration = 0,
    this.notes,
    this.followUpDate,
  });

  factory CallLog.fromMap(String id, Map<String, dynamic> d) {
    return CallLog(
      id: id,
      calledAt: _Safe.dateTime(d, 'callDate'),
      status: _Safe.enumVal(CallStatus.values, d, 'status', CallStatus.pending),
      calledBy: _Safe.str(d, 'facultyName'),
      duration: _Safe.intVal(d, 'duration'),
      notes: d['notes'] as String?,
      followUpDate: _Safe.dateTimeNullable(d, 'followUpDate'),
    );
  }
}

class CallReport {
  final String id;
  final String studentId;
  final String studentName;
  final String batchId;
  final String batchName;
  final String facultyId;
  final String facultyName;
  final CallStatus status;
  final DateTime callDate;
  final int duration;
  final String? notes;
  final DateTime? followUpDate;
  final bool interested;
  final bool parentContacted;

  const CallReport({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.batchId,
    required this.batchName,
    required this.facultyId,
    required this.facultyName,
    required this.status,
    required this.callDate,
    this.duration = 0,
    this.notes,
    this.followUpDate,
    this.interested = false,
    this.parentContacted = false,
  });

  factory CallReport.fromFirestore(DocumentSnapshot doc) {
    final d = _Safe.safeMap(doc);
    return CallReport(
      id: doc.id,
      studentId: _Safe.str(d, 'studentId'),
      studentName: _Safe.str(d, 'studentName'),
      batchId: _Safe.str(d, 'batchId'),
      batchName: _Safe.str(d, 'batchName'),
      facultyId: _Safe.str(d, 'facultyId'),
      facultyName: _Safe.str(d, 'facultyName'),
      status: _Safe.enumVal(CallStatus.values, d, 'status', CallStatus.pending),
      callDate: _Safe.dateTime(d, 'callDate'),
      duration: _Safe.intVal(d, 'duration'),
      notes: d['notes'] as String?,
      followUpDate: _Safe.dateTimeNullable(d, 'followUpDate'),
      interested: _Safe.boolVal(d, 'interested'),
      parentContacted: _Safe.boolVal(d, 'parentContacted'),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'studentId': studentId,
    'studentName': studentName,
    'batchId': batchId,
    'batchName': batchName,
    'facultyId': facultyId,
    'facultyName': facultyName,
    'status': status.name,
    'callDate': Timestamp.fromDate(callDate),
    'duration': duration,
    'notes': notes,
    'followUpDate': followUpDate != null
        ? Timestamp.fromDate(followUpDate!)
        : null,
    'interested': interested,
    'parentContacted': parentContacted,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class FeedbackModel {
  final String id;
  final String studentId;
  final String studentName;
  final String facultyId;
  final String facultyName;
  final String feedbackType;
  final String? notes;
  final DateTime createdAt;

  const FeedbackModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.facultyId,
    required this.facultyName,
    required this.feedbackType,
    this.notes,
    required this.createdAt,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final d = _Safe.safeMap(doc);
    return FeedbackModel(
      id: doc.id,
      studentId: _Safe.str(d, 'studentId'),
      studentName: _Safe.str(d, 'studentName'),
      facultyId: _Safe.str(d, 'facultyId'),
      facultyName: _Safe.str(d, 'facultyName'),
      feedbackType: _Safe.str(d, 'feedbackType'),
      notes: d['notes'] as String?,
      createdAt: _Safe.dateTime(d, 'createdAt'),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'studentId': studentId,
    'studentName': studentName,
    'facultyId': facultyId,
    'facultyName': facultyName,
    'feedbackType': feedbackType,
    'notes': notes,
    'createdAt': Timestamp.fromDate(createdAt),
    'serverTimestamp': FieldValue.serverTimestamp(),
  };
}

class ActivityLog {
  final String id;
  final String activityType;
  final String? studentId;
  final String? studentName;
  final String? batchId;
  final String? batchName;
  final String facultyId;
  final String facultyName;
  final DateTime timestamp;
  final String actionDetails;

  const ActivityLog({
    required this.id,
    required this.activityType,
    this.studentId,
    this.studentName,
    this.batchId,
    this.batchName,
    required this.facultyId,
    required this.facultyName,
    required this.timestamp,
    required this.actionDetails,
  });

  factory ActivityLog.fromFirestore(DocumentSnapshot doc) {
    final d = _Safe.safeMap(doc);
    return ActivityLog(
      id: doc.id,
      activityType: _Safe.str(d, 'activityType'),
      studentId: d['studentId'] as String?,
      studentName: d['studentName'] as String?,
      batchId: d['batchId'] as String?,
      batchName: d['batchName'] as String?,
      facultyId: _Safe.str(d, 'facultyId'),
      facultyName: _Safe.str(d, 'facultyName'),
      timestamp: _Safe.dateTime(d, 'timestamp'),
      actionDetails: _Safe.str(d, 'actionDetails'),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'activityType': activityType,
    'studentId': studentId,
    'studentName': studentName,
    'batchId': batchId,
    'batchName': batchName,
    'facultyId': facultyId,
    'facultyName': facultyName,
    'timestamp': Timestamp.fromDate(timestamp),
    'actionDetails': actionDetails,
  };
}

class DashboardStats {
  final int totalStudents;
  final int totalBatches;
  final int totalFaculty;
  final int calledToday;
  final int pendingCalls;
  final int unreachable;
  final int followUps;
  final int interestedStudents;
  final int admissionConfirmed;
  final double completionPercentage;

  const DashboardStats({
    this.totalStudents = 0,
    this.totalBatches = 0,
    this.totalFaculty = 0,
    this.calledToday = 0,
    this.pendingCalls = 0,
    this.unreachable = 0,
    this.followUps = 0,
    this.interestedStudents = 0,
    this.admissionConfirmed = 0,
    this.completionPercentage = 0,
  });
}

// =============================================================================
// CONNECTION MONITOR
// =============================================================================

class FirebaseConnectionMonitor extends ChangeNotifier {
  FirebaseConnectionStatus _status = FirebaseConnectionStatus.connected;
  DateTime? _lastSyncTime;
  String? _errorMessage;
  bool _isSyncing = false;
  StreamSubscription? _connectivitySub;

  FirebaseConnectionStatus get status => _status;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;
  bool get isSyncing => _isSyncing;

  FirebaseConnectionMonitor() {
    _startMonitoring();
  }

  void _startMonitoring() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        _updateStatus(FirebaseConnectionStatus.disconnected);
      } else {
        _updateStatus(FirebaseConnectionStatus.connected);
        _lastSyncTime = DateTime.now();
        notifyListeners();
      }
    }, onError: (_) {});
  }






  void _updateStatus(FirebaseConnectionStatus s) {
    if (_status != s) {
      _status = s;
      if (s == FirebaseConnectionStatus.connected) _errorMessage = null;
      notifyListeners();
    }
  }

  void setSyncing(bool syncing) {
    _isSyncing = syncing;
    if (syncing && _status == FirebaseConnectionStatus.connected) {
      _status = FirebaseConnectionStatus.syncing;
    } else if (!syncing && _status == FirebaseConnectionStatus.syncing) {
      _status = FirebaseConnectionStatus.connected;
      _lastSyncTime = DateTime.now();
    }
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    _updateStatus(FirebaseConnectionStatus.error);
  }

  void retryConnection() {
    _errorMessage = null;
    _updateStatus(FirebaseConnectionStatus.connected);
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}

// =============================================================================
// FIREBASE SERVICE
// =============================================================================

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseConnectionMonitor _monitor = FirebaseConnectionMonitor();
  static bool _offlineEnabled = false;

  static FirebaseConnectionMonitor get connectionMonitor => _monitor;

  static CollectionReference get _students => _db.collection('students');
  static CollectionReference get _batches => _db.collection('batches');
  static CollectionReference get _faculties => _db.collection('faculties');
  static CollectionReference get _callReports => _db.collection('call_reports');
  static CollectionReference get _feedbacks => _db.collection('feedbacks');
  static CollectionReference get _activityLogs =>
      _db.collection('activity_logs');

  static Future<void> enableOfflineCache() async {
    if (_offlineEnabled) return;
    try {
      _db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _offlineEnabled = true;
    } catch (_) {}
  }

  static Future<T> _safe<T>(Future<T> Function() fn, String op) async {
    try {
      _monitor.setSyncing(true);
      final r = await fn().timeout(const Duration(seconds: 30));
      _monitor.setSyncing(false);
      return r;
    } on FirebaseException catch (e) {
      _monitor.setSyncing(false);
      _monitor.setError(e.message ?? 'Firebase error');
      throw Exception('Database error. Please try again.');
    } on TimeoutException {
      _monitor.setSyncing(false);
      throw Exception('Request timed out. Check your connection.');
    } catch (e) {
      _monitor.setSyncing(false);
      throw Exception('Operation failed. Please try again.');
    }
  }

  static Future<void> logActivity({
    required String activityType,
    String? studentId,
    String? studentName,
    String? batchId,
    String? batchName,
    required String facultyId,
    required String facultyName,
    required String actionDetails,
  }) async {
    try {
      final ref = _activityLogs.doc();
      await ref.set(
        ActivityLog(
          id: ref.id,
          activityType: activityType,
          studentId: studentId,
          studentName: studentName,
          batchId: batchId,
          batchName: batchName,
          facultyId: facultyId,
          facultyName: facultyName,
          timestamp: DateTime.now(),
          actionDetails: actionDetails,
        ).toFirestore(),
      );
    } catch (_) {}
  }

  // ─── Students ───────────────────────────────────────────────────────────────
// ─── Students ───────────────────────────────────────────────────────────────
static Stream<List<StudentModel>> watchStudents({String? batchId}) {
  try {
    Query q = _students;
    if (batchId != null && batchId.isNotEmpty) {
      q = q.where('batchId', isEqualTo: batchId);
    }
    // Remove orderBy to avoid composite index requirement
    // Sort in memory instead
    
    return q
        .snapshots(includeMetadataChanges: false)
        .map(
          (s) {
            final students = s.docs
                .map((d) {
                  try {
                    return StudentModel.fromFirestore(d);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<StudentModel>()
                .toList();
            
            // Sort by studentName in memory
            students.sort((a, b) => a.studentName.compareTo(b.studentName));
            return students;
          },
        );
  } catch (_) {
    return const Stream.empty();
  }
}

  static Future<String> addStudent(
    StudentModel s,
    String facultyId,
    String facultyName,
  ) async {
    return _safe(() async {
      final studentData = s.toFirestore();
      studentData['createdAt'] = Timestamp.fromDate(s.createdAt);
      studentData['updatedAt'] = FieldValue.serverTimestamp();

      await _students.doc(s.id).set(studentData);
      await _updateBatchCount(s.batchId, 1);

      unawaited(
        logActivity(
          activityType: 'STUDENT_ADDED',
          studentId: s.id,
          studentName: s.studentName,
          batchId: s.batchId,
          batchName: s.batchName,
          facultyId: facultyId,
          facultyName: facultyName,
          actionDetails: 'Added ${s.studentName} to ${s.batchName}',
        ),
      );
      return s.id;
    }, 'addStudent');
  }

  static Future<void> updateStudent(
    StudentModel s,
    String facultyId,
    String facultyName,
  ) async {
    return _safe(() async {
      await _students.doc(s.id).update(s.toFirestore());
      unawaited(
        logActivity(
          activityType: 'STUDENT_UPDATED',
          studentId: s.id,
          studentName: s.studentName,
          batchId: s.batchId,
          batchName: s.batchName,
          facultyId: facultyId,
          facultyName: facultyName,
          actionDetails: 'Updated ${s.studentName}',
        ),
      );
    }, 'updateStudent');
  }

  static Future<void> deleteStudent(
    String id,
    String batchId,
    String studentName,
    String facultyId,
    String facultyName,
  ) async {
    return _safe(() async {
      await _students.doc(id).delete();
      await _updateBatchCount(batchId, -1);
      unawaited(
        logActivity(
          activityType: 'STUDENT_DELETED',
          studentId: id,
          studentName: studentName,
          batchId: batchId,
          facultyId: facultyId,
          facultyName: facultyName,
          actionDetails: 'Deleted $studentName',
        ),
      );
    }, 'deleteStudent');
  }

  static Future<void> updateCallStatus(
    String studentId,
    CallStatus status,
    String facultyId,
    String facultyName, {
    int duration = 0,
    String? notes,
    DateTime? followUpDate,
    bool interested = false,
    bool parentContacted = false,
  }) async {
    return _safe(() async {
      final studentDoc = await _students.doc(studentId).get();
      if (!studentDoc.exists) throw Exception('Student not found');

      final d = _Safe.safeMap(studentDoc);
      final studentName = _Safe.str(d, 'studentName', _Safe.str(d, 'name', ''));
      final batchId = _Safe.str(d, 'batchId');
      final batchName = _Safe.str(d, 'batchName');
      final now = DateTime.now();

      await _students.doc(studentId).update({
        'callingStatus': status.name,
        'lastCalledAt': Timestamp.fromDate(now),
        'lastCalledBy': facultyName,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'callAttempts': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final reportRef = _callReports.doc();
      await reportRef.set(
        CallReport(
          id: reportRef.id,
          studentId: studentId,
          studentName: studentName,
          batchId: batchId,
          batchName: batchName,
          facultyId: facultyId,
          facultyName: facultyName,
          status: status,
          callDate: now,
          duration: duration,
          notes: notes,
          followUpDate: followUpDate,
          interested: interested,
          parentContacted: parentContacted,
        ).toFirestore(),
      );

      try {
        await _faculties.doc(facultyId).update({
          'totalCalls': FieldValue.increment(1),
        });
      } catch (_) {}

      unawaited(
        logActivity(
          activityType: 'CALL_COMPLETED',
          studentId: studentId,
          studentName: studentName,
          batchId: batchId,
          batchName: batchName,
          facultyId: facultyId,
          facultyName: facultyName,
          actionDetails:
              'Called $studentName – Status: ${status.name}${notes != null ? ', Notes: $notes' : ''}',
        ),
      );
    }, 'updateCallStatus');
  }

  static Future<void> addFeedback(
    String studentId,
    String studentName,
    String feedbackType,
    String facultyId,
    String facultyName, {
    String? notes,
  }) async {
    return _safe(() async {
      final ref = _feedbacks.doc();
      await ref.set(
        FeedbackModel(
          id: ref.id,
          studentId: studentId,
          studentName: studentName,
          facultyId: facultyId,
          facultyName: facultyName,
          feedbackType: feedbackType,
          notes: notes,
          createdAt: DateTime.now(),
        ).toFirestore(),
      );
      unawaited(
        logActivity(
          activityType: 'FEEDBACK_ADDED',
          studentId: studentId,
          studentName: studentName,
          facultyId: facultyId,
          facultyName: facultyName,
          actionDetails: 'Feedback "$feedbackType" for $studentName',
        ),
      );
    }, 'addFeedback');
  }

  // ─── Batches ────────────────────────────────────────────────────────────────
  static Stream<List<BatchModel>> watchBatches({String? facultyId}) {
    try {
      Query q = _batches;
      if (facultyId != null && facultyId.isNotEmpty) {
        q = q.where('facultyId', isEqualTo: facultyId);
      }
      // Remove orderBy to avoid index requirement
      // Just sort in memory if needed

      return q
          .snapshots(includeMetadataChanges: false)
          .map(
            (s) => s.docs
                .map((d) {
                  try {
                    return BatchModel.fromFirestore(d);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<BatchModel>()
                .toList(),
          );
    } catch (_) {
      return const Stream.empty();
    }
  }

  static Future<String> addBatch(
    BatchModel b,
    String facultyId,
    String facultyName,
  ) async {
    return _safe(() async {
      // Create a proper map with all required fields
      final batchData = {
        'batchName': b.batchName,
        'courseName': b.courseName,
        'batchCode': b.batchCode,
        'facultyName': b.facultyName,
        'facultyId': b.facultyId,
        'batchTiming': b.batchTiming,
        'startTime': b.startTime,
        'endTime': b.endTime,
        'createdAt': Timestamp.fromDate(b.createdAt),
        'studentCount': b.studentCount,
        'status': b.status.name,
        'notes': b.notes,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Use the batch ID from the model
      await _batches.doc(b.id).set(batchData);

      // Update faculty's assigned batches
      try {
        await _faculties.doc(facultyId).update({
          'assignedBatches': FieldValue.arrayUnion([b.id]),
        });
      } catch (_) {}

      // Log the activity
      unawaited(
        logActivity(
          activityType: 'BATCH_CREATED',
          batchId: b.id,
          batchName: b.batchName,
          facultyId: facultyId,
          facultyName: facultyName,
          actionDetails: 'Batch created: ${b.batchName} (${b.courseName})',
        ),
      );

      return b.id;
    }, 'addBatch');
  }

  static Future<void> updateBatch(
    BatchModel b,
    String facultyId,
    String facultyName,
  ) async {
    return _safe(() async {
      await _batches.doc(b.id).update(b.toFirestore());
      unawaited(
        logActivity(
          activityType: 'BATCH_UPDATED',
          batchId: b.id,
          batchName: b.batchName,
          facultyId: facultyId,
          facultyName: facultyName,
          actionDetails: 'Batch updated: ${b.batchName}',
        ),
      );
    }, 'updateBatch');
  }

  static Future<void> deleteBatch(
    String id,
    String batchName,
    String facultyId,
    String facultyName,
  ) async {
    return _safe(() async {
      // First, get all students in this batch
      final studentsSnap = await _students
          .where('batchId', isEqualTo: id)
          .get();

      // Use a batch write for atomic operation
      final batch = _db.batch();

      // Delete all students in this batch
      for (final doc in studentsSnap.docs) {
        batch.delete(_students.doc(doc.id));
      }

      // Delete the batch itself
      batch.delete(_batches.doc(id));

      // Commit the batch operation
      await batch.commit();

      // Update faculty's assigned batches (remove this batch)
      try {
        final facultyDoc = await _faculties.doc(facultyId).get();
        if (facultyDoc.exists) {
          final Map<String, dynamic>? data =
              facultyDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('assignedBatches')) {
            final dynamic assignedBatchesData = data['assignedBatches'];
            if (assignedBatchesData is List) {
              // Safely convert to List<String>
              final List<String> currentBatches = assignedBatchesData
                  .whereType<String>()
                  .toList();

              if (currentBatches.contains(id)) {
                await _faculties.doc(facultyId).update({
                  'assignedBatches': FieldValue.arrayRemove([id]),
                });
              }
            }
          }
        }
      } catch (e) {
        // Log error but don't fail the batch deletion
        print('Error updating faculty assigned batches: $e');
      }

      // Log the activity
      unawaited(
        logActivity(
          activityType: 'BATCH_DELETED',
          batchId: id,
          batchName: batchName,
          facultyId: facultyId,
          facultyName: facultyName,
          actionDetails:
              'Batch deleted: $batchName (${studentsSnap.docs.length} students removed)',
        ),
      );
    }, 'deleteBatch');
  }

  // ─── Faculty ────────────────────────────────────────────────────────────────
  static Stream<List<FacultyModel>> watchFaculties() {
    try {
      return _faculties
          .orderBy('name')
          .snapshots(includeMetadataChanges: false)
          .map(
            (s) => s.docs
                .map((d) {
                  try {
                    return FacultyModel.fromFirestore(d);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<FacultyModel>()
                .toList(),
          );
    } catch (_) {
      return const Stream.empty();
    }
  }

  static Future<String> addFaculty(FacultyModel f) async {
    return _safe(() async {
      final facultyData = f.toFirestore();
      facultyData['createdAt'] = Timestamp.fromDate(f.createdAt);
      facultyData['updatedAt'] = FieldValue.serverTimestamp();

      await _faculties.doc(f.id).set(facultyData);

      unawaited(
        logActivity(
          activityType: 'FACULTY_ADDED',
          facultyId: f.id,
          facultyName: f.name,
          actionDetails: 'Faculty added: ${f.name} (${f.department})',
        ),
      );
      return f.id;
    }, 'addFaculty');
  }

  static Future<void> updateFaculty(FacultyModel f) async {
    return _safe(() async {
      await _faculties.doc(f.id).update(f.toFirestore());
      unawaited(
        logActivity(
          activityType: 'FACULTY_UPDATED',
          facultyId: f.id,
          facultyName: f.name,
          actionDetails: 'Faculty updated: ${f.name}',
        ),
      );
    }, 'updateFaculty');
  }

  static Future<void> deleteFaculty(String id, String name) async {
    return _safe(() async {
      final doc = await _faculties.doc(id).get();
      final d = _Safe.safeMap(doc);
      final assigned = _Safe.strList(d, 'assignedBatches');
      if (assigned.isNotEmpty) {
        throw Exception(
          'Faculty has ${assigned.length} assigned batch(es). Please reassign first.',
        );
      }
      await _faculties.doc(id).delete();
      unawaited(
        logActivity(
          activityType: 'FACULTY_DELETED',
          facultyId: id,
          facultyName: name,
          actionDetails: 'Faculty deleted: $name',
        ),
      );
    }, 'deleteFaculty');
  }

  // ─── Streams ────────────────────────────────────────────────────────────────
static Stream<List<CallReport>> watchCallReports({
  String? facultyId,
  String? studentId,
}) {
  try {
    Query q = _callReports;
    
    if (studentId != null && studentId.isNotEmpty) {
      q = q.where('studentId', isEqualTo: studentId);
    } else if (facultyId != null && facultyId.isNotEmpty) {
      q = q.where('facultyId', isEqualTo: facultyId);
    }
    
    // Remove orderBy to avoid index requirements, sort in memory
    return q
        .snapshots(includeMetadataChanges: false)
        .map(
          (s) {
            final reports = s.docs
                .map((d) {
                  try {
                    return CallReport.fromFirestore(d);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<CallReport>()
                .toList();
            
            // Sort by callDate descending in memory
            reports.sort((a, b) => b.callDate.compareTo(a.callDate));
            
            // Limit to 50 reports
            if (reports.length > 50) {
              return reports.sublist(0, 50);
            }
            return reports;
          },
        );
  } catch (_) {
    return const Stream.empty();
  }
}

  static Stream<List<CallLog>> watchCallHistory(String studentId) {
    try {
      return _callReports
          .where('studentId', isEqualTo: studentId)
          .orderBy('callDate', descending: true)
          .snapshots(includeMetadataChanges: false)
          .map(
            (s) => s.docs
                .map((doc) {
                  try {
                    final d = _Safe.safeMap(doc);
                    return CallLog.fromMap(doc.id, d);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<CallLog>()
                .toList(),
          );
    } catch (_) {
      return const Stream.empty();
    }
  }

  static Stream<List<FeedbackModel>> watchFeedbacks(String studentId) {
    try {
      return _feedbacks
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .snapshots(includeMetadataChanges: false)
          .map(
            (s) => s.docs
                .map((d) {
                  try {
                    return FeedbackModel.fromFirestore(d);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<FeedbackModel>()
                .toList(),
          );
    } catch (_) {
      return const Stream.empty();
    }
  }

  static Stream<List<ActivityLog>> watchActivityLogs({String? facultyId}) {
    try {
      Query q = _activityLogs.orderBy('timestamp', descending: true).limit(30);
      if (facultyId != null && facultyId.isNotEmpty) {
        q = _activityLogs
            .where('facultyId', isEqualTo: facultyId)
            .orderBy('timestamp', descending: true)
            .limit(30);
      }
      return q
          .snapshots(includeMetadataChanges: false)
          .map(
            (s) => s.docs
                .map((d) {
                  try {
                    return ActivityLog.fromFirestore(d);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<ActivityLog>()
                .toList(),
          );
    } catch (_) {
      return const Stream.empty();
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  static Future<void> _updateBatchCount(String batchId, int delta) async {
    if (batchId.isEmpty) return;
    try {
      await _batches.doc(batchId).update({
        'studentCount': FieldValue.increment(delta),
      });
    } catch (_) {}
  }
}

// ignore: unused_element
void unawaited(Future<void> future) {}

// =============================================================================
// STABLE STREAM CACHE
// Helper that caches stream instances so they are not recreated on every build.
// =============================================================================

class _StreamCache {
  static final Map<String, Stream<dynamic>> _cache = {};

  static Stream<List<StudentModel>> students({String? batchId}) {
    final key = 'students_${batchId ?? 'all'}';
    if (!_cache.containsKey(key)) {
      _cache[key] = FirebaseService.watchStudents(
        batchId: batchId,
      ).asBroadcastStream();
    }
    return _cache[key]! as Stream<List<StudentModel>>;
  }

  static Stream<List<BatchModel>> batches({String? facultyId}) {
    final key = 'batches_${facultyId ?? 'all'}';
    if (!_cache.containsKey(key)) {
      _cache[key] = FirebaseService.watchBatches(
        facultyId: facultyId,
      ).asBroadcastStream();
    }
    return _cache[key]! as Stream<List<BatchModel>>;
  }

  static Stream<List<FacultyModel>> faculties() {
    const key = 'faculties';
    if (!_cache.containsKey(key)) {
      _cache[key] = FirebaseService.watchFaculties().asBroadcastStream();
    }
    return _cache[key]! as Stream<List<FacultyModel>>;
  }

  static Stream<List<ActivityLog>> activityLogs({String? facultyId}) {
    final key = 'activity_${facultyId ?? 'all'}';
    if (!_cache.containsKey(key)) {
      _cache[key] = FirebaseService.watchActivityLogs(
        facultyId: facultyId,
      ).asBroadcastStream();
    }
    return _cache[key]! as Stream<List<ActivityLog>>;
  }

  static Stream<List<CallReport>> callReports({String? facultyId}) {
    final key = 'reports_${facultyId ?? 'all'}';
    if (!_cache.containsKey(key)) {
      _cache[key] = FirebaseService.watchCallReports(
        facultyId: facultyId,
      ).asBroadcastStream();
    }
    return _cache[key]! as Stream<List<CallReport>>;
  }

  // Force refresh methods
  static void refreshBatches({String? facultyId}) {
    final key = 'batches_${facultyId ?? 'all'}';
    _cache.remove(key);
  }

  static void refreshStudents({String? batchId}) {
    final key = 'students_${batchId ?? 'all'}';
    _cache.remove(key);
  }

  static void refreshFaculties() {
    _cache.remove('faculties');
  }

  static void refreshActivityLogs({String? facultyId}) {
    final key = 'activity_${facultyId ?? 'all'}';
    _cache.remove(key);
  }

  static void refreshCallReports({String? facultyId}) {
    final key = 'reports_${facultyId ?? 'all'}';
    _cache.remove(key);
  }

  static void refreshAll() {
    _cache.clear();
  }
}

// =============================================================================
// STABLE STREAM BUILDER
// as previous data while waiting for new snapshot – no blank flash.
// =============================================================================

class StableStreamBuilder<T> extends StatefulWidget {
  final Stream<T> stream;
  final T? initialData;
  final Widget Function(BuildContext, T) builder;
  final Widget Function(BuildContext)? loadingBuilder;
  final Widget Function(BuildContext, Object)? errorBuilder;

  const StableStreamBuilder({
    super.key,
    required this.stream,
    this.initialData,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  State<StableStreamBuilder<T>> createState() => _StableStreamBuilderState<T>();
}

class _StableStreamBuilderState<T> extends State<StableStreamBuilder<T>> {
  T? _lastData;
  Object? _lastError;
  bool _hasData = false;
  StreamSubscription<T>? _sub;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _lastData = widget.initialData;
      _hasData = true;
    }
    _subscribe();
  }

  @override
  void didUpdateWidget(StableStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _sub?.cancel();
      _subscribe();
    }
  }

  void _subscribe() {
    _sub = widget.stream.listen(
      (data) {
        if (mounted) {
          setState(() {
            _lastData = data;
            _hasData = true;
            _lastError = null;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() => _lastError = e);
        }
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lastError != null && !_hasData) {
      return widget.errorBuilder?.call(context, _lastError!) ??
          const SizedBox.shrink();
    }
    if (!_hasData) {
      return widget.loadingBuilder?.call(context) ?? const SizedBox.shrink();
    }
    return widget.builder(context, _lastData as T);
  }
}

// =============================================================================
// MAIN SCREEN
// =============================================================================

class BeediSmartCallingScreen extends StatefulWidget {
  const BeediSmartCallingScreen({super.key});

  @override
  State<BeediSmartCallingScreen> createState() =>
      _BeediSmartCallingScreenState();
}

class _BeediSmartCallingScreenState extends State<BeediSmartCallingScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _fabAnimCtrl;
  final SwiperController _swiperCtrl = SwiperController();
  final TextEditingController _searchCtrl = TextEditingController();

  // ─── STABLE STREAM INSTANCES ─────────────────────────────────────────────
  // Created once in initState, never recreated inside build().
  late Stream<List<StudentModel>> _studentsStream;
  late Stream<List<BatchModel>> _batchesStream;
  late Stream<List<FacultyModel>> _facultiesStream;
  late Stream<List<ActivityLog>> _activityStream;
  late Stream<List<CallReport>> _callReportsStream;

  // State
  int _currentTab = 0;
  int _currentCardIdx = 0;
  bool _fabExpanded = false;
  bool _isFirstLoad = true; // Only true until first data arrives
  bool _isBusy = false;
  String _selectedBatchId = '';
  String _selectedBatchName = '';
  String _searchQuery = '';
  CallStatus? _filterStatus;
  String _selectedPeriod = 'Today';
  bool _showSearchBar = false;
  bool _showStudentDetail = false;
  StudentModel? _selectedStudent;

  // Swiper key: only changes when batch/filter changes intentionally,
  // NOT on every Firebase update.
  String _swiperKey = 'swiper_initial';

  final String _currentFacultyId = 'fac_001';
  final String _currentFacultyName = 'Rahul Mehta';

  @override
  void initState() {
    super.initState();
    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchCtrl.addListener(_onSearch);
    FirebaseService.connectionMonitor.addListener(_onConnectionChanged);
    _initStreams();
    _init();
  }


  void _handleFirestoreError(Object error) {
  final errorStr = error.toString();
  print('Firestore Error: $errorStr');
  
  if (errorStr.contains('failed-precondition') && 
      errorStr.contains('index')) {
    // Extract the index creation link
    final RegExp regex = RegExp(r'https://[^\s]+');
    final match = regex.firstMatch(errorStr);
    final link = match?.group(0);
    
    if (link != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: GreenTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Index Required',
            style: GreenTheme.displayFont(size: 18, weight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Firestore requires an index for this query to work efficiently.',
                style: GreenTheme.bodyFont(),
              ),
              const SizedBox(height: 12),
              Text(
                'Click the button below to create it automatically.',
                style: GreenTheme.bodyFont(size: 12, color: GreenTheme.textMuted),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GreenTheme.cardAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Note: After creating the index, please restart the app.',
                  style: GreenTheme.bodyFont(
                    size: 11,
                    color: GreenTheme.statusFollowUp,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GreenTheme.bodyFont(color: GreenTheme.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final uri = Uri.parse(link);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                } catch (e) {
                  _snack('Could not open link. Please create index manually.', err: true);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GreenTheme.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Create Index',
                style: GreenTheme.bodyFont(color: Colors.white, weight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
  }
}

  void _refreshBatches() {
    print('Refreshing batches...');
    setState(() {
      // Force recreate the batches stream
      _batchesStream = FirebaseService.watchBatches(
        facultyId: _currentFacultyId,
      ).asBroadcastStream();

      // Also clear the cache
      _StreamCache.refreshBatches(facultyId: _currentFacultyId);
    });
  }

// Add this method to force refresh all streams
void _refreshAllData() {
  print('Refreshing all data...');
  
  // Clear all stream caches
  _StreamCache.refreshAll();
  
  // Recreate all streams with current filters
  _studentsStream = FirebaseService.watchStudents(
    batchId: _selectedBatchId.isEmpty ? null : _selectedBatchId,
  ).asBroadcastStream();
  
  _batchesStream = FirebaseService.watchBatches(
    facultyId: _currentFacultyId,
  ).asBroadcastStream();
  
  _facultiesStream = FirebaseService.watchFaculties().asBroadcastStream();
  
  _activityStream = FirebaseService.watchActivityLogs(
    facultyId: _currentFacultyId,
  ).asBroadcastStream();
  
  _callReportsStream = FirebaseService.watchCallReports(
    facultyId: _currentFacultyId,
  ).asBroadcastStream();
  
  // Force a rebuild of the swiper
  setState(() {
    _swiperKey = 'swiper_${_selectedBatchId}_${DateTime.now().millisecondsSinceEpoch}';
  });
}



  /// Create all streams once here. Never recreate them inside build().
  void _initStreams() {
    _studentsStream = FirebaseService.watchStudents(
      batchId: _selectedBatchId.isEmpty ? null : _selectedBatchId,
    ).asBroadcastStream();

    _batchesStream = FirebaseService.watchBatches(
      facultyId: _currentFacultyId,
    ).asBroadcastStream();

    _facultiesStream = FirebaseService.watchFaculties().asBroadcastStream();

    _activityStream = FirebaseService.watchActivityLogs(
      facultyId: _currentFacultyId,
    ).asBroadcastStream();

    _callReportsStream = FirebaseService.watchCallReports(
      facultyId: _currentFacultyId,
    ).asBroadcastStream();
  }

  /// Only called when the batch filter changes – recreates only the
  /// students stream (which depends on batchId).
  void _rebuildStudentsStream() {
    _studentsStream = FirebaseService.watchStudents(
      batchId: _selectedBatchId.isEmpty ? null : _selectedBatchId,
    ).asBroadcastStream();
    _swiperKey =
        'swiper_${_selectedBatchId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _fabAnimCtrl.dispose();
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    FirebaseService.connectionMonitor.removeListener(_onConnectionChanged);
    super.dispose();
  }

  void _onSearch() {
    if (mounted)
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase().trim());
  }

  void _onConnectionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _init() async {
    await FirebaseService.enableOfflineCache();
    if (mounted) setState(() => _isFirstLoad = false);
  }

  // ─── Actions ────────────────────────────────────────────────────────────────
  Future<void> _makeCall(String number, String label) async {
    if (number.trim().isEmpty) {
      _snack('No number available for $label', err: true);
      return;
    }
    try {
      final uri = Uri.parse('tel:${number.trim()}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _snack('Cannot open dialer', err: true);
      }
    } catch (_) {
      _snack('Cannot open dialer', err: true);
    }
  }

  Future<void> _openWhatsApp(String number, String name) async {
    if (number.trim().isEmpty) {
      _snack('No number available', err: true);
      return;
    }
    try {
      final cleaned = number.trim().replaceAll(RegExp(r'\D'), '');
      final msg = Uri.encodeComponent('Hello $name, this is BEEDI College.');
      final uri = Uri.parse('https://wa.me/91$cleaned?text=$msg');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _snack('Cannot open WhatsApp', err: true);
      }
    } catch (_) {
      _snack('Cannot open WhatsApp', err: true);
    }
  }

  Future<void> _updateCallStatus(
    StudentModel student,
    CallStatus status, {
    int duration = 0,
    String? notes,
    DateTime? followUpDate,
    bool interested = false,
    bool parentContacted = false,
  }) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await FirebaseService.updateCallStatus(
        student.id,
        status,
        _currentFacultyId,
        _currentFacultyName,
        duration: duration,
        notes: notes,
        followUpDate: followUpDate,
        interested: interested,
        parentContacted: parentContacted,
      );

      if (interested) {
        await FirebaseService.addFeedback(
          student.id,
          student.studentName,
          'Interested',
          _currentFacultyId,
          _currentFacultyName,
          notes: notes,
        );
      } else if (status == CallStatus.called) {
        await FirebaseService.addFeedback(
          student.id,
          student.studentName,
          'Admission Confirmed',
          _currentFacultyId,
          _currentFacultyName,
          notes: notes,
        );
      } else if (status == CallStatus.notInterested) {
        await FirebaseService.addFeedback(
          student.id,
          student.studentName,
          'Not Interested',
          _currentFacultyId,
          _currentFacultyName,
          notes: notes,
        );
      }

      if (mounted) _snack('Status updated: ${_statusLabel(status)}');
    } catch (e) {
      if (mounted)
        _snack(e.toString().replaceAll('Exception: ', ''), err: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _deleteStudent(StudentModel student) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await FirebaseService.deleteStudent(
        student.id,
        student.batchId,
        student.studentName,
        _currentFacultyId,
        _currentFacultyName,
      );
      if (mounted) {
        setState(() {
          if (_selectedStudent?.id == student.id) {
            _showStudentDetail = false;
            _selectedStudent = null;
          }
        });
        _snack('${student.studentName} deleted');
      }
    } catch (e) {
      if (mounted)
        _snack(e.toString().replaceAll('Exception: ', ''), err: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

Future<void> _exportToExcel() async {
  _snack('Preparing Excel export...');
  
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GreenTheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Exporting student data...',
                style: GreenTheme.bodyFont(),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Fetch all students
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .get();
    
    // Close loading dialog
    if (mounted) Navigator.pop(context);
    
    if (snapshot.docs.isEmpty) {
      _snack('No student data found to export', err: true);
      return;
    }
    
    print('Found ${snapshot.docs.length} students to export');
    
    // Create Excel file
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Students'];
    
    // Define headers
    final List<String> headers = [
      'Student ID',
      'Student Name',
      'Batch Name',
      'Batch ID',
      'Mobile Number',
      'Parent Number',
      'Email',
      'Address',
      'Course',
      'Attendance (%)',
      'Fee Status',
      'Call Status',
      'Call Attempts',
      'Last Called By',
      'Last Called At',
      'Notes',
      'Created Date',
    ];
    
    // Add headers with styling
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#1B5E20'),
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
      );
    }
    
    // Add data rows
    int rowIndex = 1;
    for (var doc in snapshot.docs) {
      try {
        final student = StudentModel.fromFirestore(doc);
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = 
            TextCellValue(student.studentId);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = 
            TextCellValue(student.studentName);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = 
            TextCellValue(student.batchName);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = 
            TextCellValue(student.batchId);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = 
            TextCellValue(student.mobileNumber);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = 
            TextCellValue(student.parentNumber);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = 
            TextCellValue(student.email);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).value = 
            TextCellValue(student.address);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex)).value = 
            TextCellValue(student.course);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex)).value = 
            TextCellValue(student.attendance.toStringAsFixed(1));
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex)).value = 
            TextCellValue(student.feeStatus.name);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex)).value = 
            TextCellValue(student.callingStatus.name);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: rowIndex)).value = 
            TextCellValue(student.callAttempts.toString());
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: rowIndex)).value = 
            TextCellValue(student.lastCalledBy ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: rowIndex)).value = 
            TextCellValue(student.lastCalledAt != null 
                ? DateFormat('dd/MM/yyyy HH:mm:ss').format(student.lastCalledAt!) 
                : '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: rowIndex)).value = 
            TextCellValue(student.notes ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: rowIndex)).value = 
            TextCellValue(DateFormat('dd/MM/yyyy HH:mm:ss').format(student.createdAt));
        
        rowIndex++;
      } catch (e) {
        print('Error processing student: $e');
      }
    }
    
    // Save the file
    final List<int>? bytes = excel.save();
    if (bytes == null) {
      _snack('Failed to generate Excel file', err: true);
      return;
    }
    
    // Get documents directory
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'BEEDI_Students_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    // Save file
    final File file = File(filePath);
    await file.writeAsBytes(bytes);
    
    _snack('✅ Exported ${rowIndex - 1} students to $fileName');
    
    // Show success dialog with option to share
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: GreenTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Export Complete',
            style: GreenTheme.displayFont(size: 18, weight: FontWeight.w700),
          ),
          content: Text(
            '${rowIndex - 1} students exported successfully!\n\nFile saved to:\n$fileName',
            style: GreenTheme.bodyFont(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GreenTheme.bodyFont()),
            ),
          ],
        ),
      );
    }
    
  } catch (e) {
    // Close loading dialog if still open
    if (mounted) {
      try {
        Navigator.pop(context);
      } catch (_) {}
    }
    
    print('Export error details: $e');
    _snack('Export failed: ${e.toString().replaceAll('Exception: ', '')}', err: true);
  }
}

  // ─── Status helpers ─────────────────────────────────────────────────────────
  Color _statusColor(CallStatus s) {
    switch (s) {
      case CallStatus.called:
        return GreenTheme.statusCalled;
      case CallStatus.pending:
        return GreenTheme.statusPending;
      case CallStatus.notReachable:
        return GreenTheme.statusUnreachable;
      case CallStatus.switchedOff:
        return GreenTheme.statusSwitchedOff;
      case CallStatus.busy:
        return GreenTheme.statusBusy;
      case CallStatus.parentContacted:
        return GreenTheme.statusParentContacted;
      case CallStatus.followUpRequired:
        return GreenTheme.statusFollowUp;
      case CallStatus.interested:
        return GreenTheme.statusInterested;
      case CallStatus.notInterested:
        return GreenTheme.statusNotInterested;
      case CallStatus.callBackLater:
        return GreenTheme.statusCallBack;
    }
  }

  String _statusLabel(CallStatus s) {
    switch (s) {
      case CallStatus.called:
        return 'Called';
      case CallStatus.pending:
        return 'Pending';
      case CallStatus.notReachable:
        return 'Not Reachable';
      case CallStatus.switchedOff:
        return 'Switched Off';
      case CallStatus.busy:
        return 'Busy';
      case CallStatus.parentContacted:
        return 'Parent Contacted';
      case CallStatus.followUpRequired:
        return 'Follow Up';
      case CallStatus.interested:
        return 'Interested';
      case CallStatus.notInterested:
        return 'Not Interested';
      case CallStatus.callBackLater:
        return 'Call Back Later';
    }
  }

  IconData _statusIcon(CallStatus s) {
    switch (s) {
      case CallStatus.called:
        return Icons.check_circle_rounded;
      case CallStatus.pending:
        return Icons.hourglass_empty_rounded;
      case CallStatus.notReachable:
        return Icons.phone_missed_rounded;
      case CallStatus.switchedOff:
        return Icons.mobile_off_rounded;
      case CallStatus.busy:
        return Icons.phone_in_talk_rounded;
      case CallStatus.parentContacted:
        return Icons.family_restroom_rounded;
      case CallStatus.followUpRequired:
        return Icons.refresh_rounded;
      case CallStatus.interested:
        return Icons.thumb_up_rounded;
      case CallStatus.notInterested:
        return Icons.thumb_down_rounded;
      case CallStatus.callBackLater:
        return Icons.alarm_rounded;
    }
  }

  Color _feeColor(FeeStatus s) {
    switch (s) {
      case FeeStatus.paid:
        return GreenTheme.statusCalled;
      case FeeStatus.partial:
        return GreenTheme.statusCallBack;
      case FeeStatus.pending:
        return GreenTheme.statusPending;
      case FeeStatus.overdue:
        return GreenTheme.statusUnreachable;
    }
  }

  IconData _activityIcon(String t) {
    switch (t) {
      case 'CALL_COMPLETED':
        return Icons.phone_in_talk_rounded;
      case 'STUDENT_ADDED':
        return Icons.person_add_rounded;
      case 'STUDENT_DELETED':
        return Icons.person_remove_rounded;
      case 'STUDENT_UPDATED':
        return Icons.person_rounded;
      case 'BATCH_CREATED':
        return Icons.create_new_folder_rounded;
      case 'BATCH_UPDATED':
        return Icons.edit_rounded;
      case 'BATCH_DELETED':
        return Icons.delete_rounded;
      case 'FACULTY_ADDED':
        return Icons.school_rounded;
      case 'FACULTY_UPDATED':
        return Icons.edit_rounded;
      case 'FACULTY_DELETED':
        return Icons.delete_rounded;
      case 'FEEDBACK_ADDED':
        return Icons.feedback_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  // Simple snackbar helper
  void _snack(String msg, {bool err = false}) {
    if (!mounted) return;
    final sb = SnackBar(
      content: Text(msg),
      backgroundColor: err ? GreenTheme.statusNotInterested : GreenTheme.accent,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(sb);
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: GreenTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // These are const-like widgets that don't depend on stream data
              _buildTopBar(),
              _buildConnectionBanner(),
              if (_showSearchBar) _buildSearchBar(),
              if (_currentTab == 0 && !_showStudentDetail)
                _buildBatchSelector(),
              if (_currentTab == 0 && !_showStudentDetail) _buildFilterChips(),
              Expanded(child: _buildTabBody()),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: _buildFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // ─── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: GreenTheme.surface,
        border: Border(bottom: BorderSide(color: GreenTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: GreenTheme.accentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BEEDI College',
                  style: GreenTheme.displayFont(
                    size: 16,
                    weight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Smart Calling System',
                  style: GreenTheme.bodyFont(
                    size: 11,
                    color: GreenTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (_showStudentDetail)
            _topBtn(
              Icons.arrow_back_rounded,
              () => setState(() {
                _showStudentDetail = false;
                _selectedStudent = null;
              }),
            ),
          const SizedBox(width: 4),
          _topBtn(
            Icons.search_rounded,
            () => setState(() => _showSearchBar = !_showSearchBar),
          ),
          const SizedBox(width: 4),
          _topBtn(Icons.ios_share_rounded, _exportToExcel),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: GreenTheme.accentGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _currentFacultyName.isNotEmpty
                    ? _currentFacultyName[0].toUpperCase()
                    : 'U',
                style: GreenTheme.displayFont(
                  size: 14,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: GreenTheme.cardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GreenTheme.border),
      ),
      child: Icon(icon, color: GreenTheme.textSecondary, size: 18),
    ),
  );

  // ─── Connection Banner ──────────────────────────────────────────────────────
  Widget _buildConnectionBanner() {
    final mon = FirebaseService.connectionMonitor;
    final status = mon.status;
    if (status == FirebaseConnectionStatus.connected && !mon.isSyncing)
      return const SizedBox.shrink();

    final (text, icon, color) = switch (status) {
      FirebaseConnectionStatus.connected => (
        'Connected',
        Icons.wifi,
        GreenTheme.statusCalled,
      ),
      FirebaseConnectionStatus.syncing => (
        'Syncing…',
        Icons.sync,
        GreenTheme.statusFollowUp,
      ),
      FirebaseConnectionStatus.disconnected => (
        'Working Offline – changes will sync when back online',
        Icons.wifi_off,
        GreenTheme.statusUnreachable,
      ),
      FirebaseConnectionStatus.error => (
        'Sync Error – tap Retry',
        Icons.error_outline,
        GreenTheme.statusNotInterested,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withOpacity(0.12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GreenTheme.bodyFont(
                size: 11,
                color: color,
                weight: FontWeight.w600,
              ),
            ),
          ),
          if (status == FirebaseConnectionStatus.disconnected ||
              status == FirebaseConnectionStatus.error)
            GestureDetector(
              onTap: mon.retryConnection,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Retry',
                  style: GreenTheme.bodyFont(
                    size: 11,
                    color: Colors.white,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: GreenTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GreenTheme.border),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: GreenTheme.bodyFont(color: GreenTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search by name, mobile, ID…',
            hintStyle: GreenTheme.bodyFont(color: GreenTheme.textMuted),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: GreenTheme.textMuted,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      size: 18,
                      color: GreenTheme.textMuted,
                    ),
                    onPressed: () => _searchCtrl.clear(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Batch Selector ─────────────────────────────────────────────────────────
  // FIX: uses the stable _batchesStream created in initState, never rebuilds
  // the stream reference.
  Widget _buildBatchSelector() {
    // Use FirebaseService directly instead of cached stream to ensure updates
    return StreamBuilder<List<BatchModel>>(
      stream: FirebaseService.watchBatches(facultyId: _currentFacultyId),
      initialData: const [],
      builder: (context, snapshot) {
        final batches = snapshot.data ?? [];
        return SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: batches.length + 1,
            itemBuilder: (_, i) {
              if (i == 0)
                return _batchChip(
                  'All Batches',
                  _selectedBatchId.isEmpty,
                  batchId: '',
                  batchName: '',
                );
              final b = batches[i - 1];
              return _batchChip(
                b.batchName.isNotEmpty ? b.batchName : 'Batch',
                _selectedBatchId == b.id,
                batchId: b.id,
                batchName: b.batchName,
              );
            },
          ),
        );
      },
    );
  }

  Widget _batchChip(
    String label,
    bool selected, {
    required String batchId,
    required String batchName,
  }) {
    return GestureDetector(
      onTap: () {
        final newId = selected ? '' : batchId;
        final newName = selected ? '' : batchName;
        if (_selectedBatchId == newId) return;
        setState(() {
          _selectedBatchId = newId;
          _selectedBatchName = newName;
          _showStudentDetail = false;
          _currentCardIdx = 0;
          // Force a rebuild of the swiper
          _swiperKey =
              'swiper_${newId}_${DateTime.now().millisecondsSinceEpoch}';
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? GreenTheme.accentGradient : null,
          color: selected ? null : GreenTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? GreenTheme.accentDark : GreenTheme.border,
          ),
        ),
        child: Text(
          label,
          style: GreenTheme.bodyFont(
            size: 12,
            weight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : GreenTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  // ─── Filter Chips ───────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    final filters = <(String, CallStatus?)>[
      ('All', null),
      ('Pending', CallStatus.pending),
      ('Called', CallStatus.called),
      ('Follow Up', CallStatus.followUpRequired),
      ('Unreachable', CallStatus.notReachable),
      ('Interested', CallStatus.interested),
      ('Not Interested', CallStatus.notInterested),
    ];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final (label, status) = filters[i];
          final selected = _filterStatus == status;
          final color = status != null
              ? _statusColor(status)
              : GreenTheme.accent;
          return GestureDetector(
            onTap: () =>
                setState(() => _filterStatus = selected ? null : status),
            child: Container(
              margin: const EdgeInsets.only(right: 6, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? color.withOpacity(0.15) : GreenTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selected ? color : GreenTheme.border),
              ),
              child: Text(
                label,
                style: GreenTheme.bodyFont(
                  size: 11,
                  weight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? color : GreenTheme.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Tab Router ─────────────────────────────────────────────────────────────
  Widget _buildTabBody() {
    if (_showStudentDetail && _selectedStudent != null)
      return _buildStudentDetail(_selectedStudent!);
    switch (_currentTab) {
      case 0:
        return _buildCallingTab();
      case 1:
        return _buildDashboardTab();
      case 2:
        return _buildReportsTab();
      case 3:
        return _buildFacultyTab();
      case 4:
        return _buildBatchesTab();
      default:
        return _buildCallingTab();
    }
  }

  // ==========================================================================
  // TAB 0 – CALLING
  // FIX: Uses StableStreamBuilder so previous data stays visible during
  // Firebase updates. Loading shimmer only shown on very first load.
  // ==========================================================================
Widget _buildCallingTab() {
  if (_isFirstLoad) return _shimmer();

  return RefreshIndicator(
    onRefresh: () async {
      _refreshAllData();
      await Future.delayed(const Duration(milliseconds: 500));
    },
    child: StreamBuilder<List<StudentModel>>(
      stream: FirebaseService.watchStudents(
        batchId: _selectedBatchId.isEmpty ? null : _selectedBatchId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Show the actual error for debugging
          print('Stream error: ${snapshot.error}');
          return _errorWidget(
            'Error: ${snapshot.error}\nPlease check Firebase configuration.',
          );
        }

        final allStudents = snapshot.data ?? [];
        var all = List<StudentModel>.from(allStudents);

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          all = all
              .where(
                (s) =>
                    s.studentName.toLowerCase().contains(_searchQuery) ||
                    s.mobileNumber.contains(_searchQuery) ||
                    s.studentId.toLowerCase().contains(_searchQuery) ||
                    s.batchName.toLowerCase().contains(_searchQuery),
              )
              .toList();
        }
        // Apply status filter
        if (_filterStatus != null) {
          all = all.where((s) => s.callingStatus == _filterStatus).toList();
        }

        if (all.isEmpty) {
          return _emptyState(
            'No students found',
            'Pull down to refresh or add new students.',
          );
        }

        // Clamp the card index so the swiper never goes out of bounds
        final safeIdx = _currentCardIdx.clamp(0, all.length - 1);

        return Column(
          children: [
            _buildCallingHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${all.length} student${all.length != 1 ? 's' : ''}',
                    style: GreenTheme.bodyFont(
                      size: 12,
                      color: GreenTheme.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${safeIdx + 1} / ${all.length}',
                    style: GreenTheme.bodyFont(
                      size: 12,
                      color: GreenTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            _buildQuickStats(all),
            const SizedBox(height: 8),
            Expanded(
              child: Swiper(
                key: ValueKey(_swiperKey),
                controller: _swiperCtrl,
                itemCount: all.length,
                itemBuilder: (ctx, i) {
                  if (i < 0 || i >= all.length) return const SizedBox.shrink();
                  final student = all[i];
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedStudent = student;
                      _showStudentDetail = true;
                    }),
                    child: _buildStudentCard(student),
                  );
                },
                layout: SwiperLayout.TINDER,
                itemWidth: MediaQuery.of(context).size.width - 32,
                itemHeight: MediaQuery.of(context).size.height * 0.60,
                onIndexChanged: (i) {
                  _currentCardIdx = i;
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}

  Widget _buildQuickStats(List<StudentModel> students) {
    final today = DateTime.now();
    final calledToday = students.where((s) {
      final lca = s.lastCalledAt;
      if (lca == null) return false;
      return lca.year == today.year &&
          lca.month == today.month &&
          lca.day == today.day;
    }).length;

    final pendingCalls = students
        .where((s) => s.callingStatus == CallStatus.pending)
        .length;
    final followUps = students
        .where((s) => s.callingStatus == CallStatus.followUpRequired)
        .length;
    final unreachable = students
        .where((s) => s.callingStatus == CallStatus.notReachable)
        .length;
    final interested = students
        .where((s) => s.callingStatus == CallStatus.interested)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _qStat('Today', calledToday.toString(), GreenTheme.statusCalled),
          const SizedBox(width: 6),
          _qStat('Pending', pendingCalls.toString(), GreenTheme.statusPending),
          const SizedBox(width: 6),
          _qStat('Follow Up', followUps.toString(), GreenTheme.statusFollowUp),
          const SizedBox(width: 6),
          _qStat(
            'N/Reach',
            unreachable.toString(),
            GreenTheme.statusUnreachable,
          ),
          const SizedBox(width: 6),
          _qStat(
            'Interest',
            interested.toString(),
            GreenTheme.statusInterested,
          ),
        ],
      ),
    );
  }

  Widget _qStat(String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GreenTheme.displayFont(
              size: 15,
              weight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GreenTheme.bodyFont(size: 8, color: GreenTheme.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

// Add this method to show a refresh button in the calling tab
Widget _buildCallingHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Students',
            style: GreenTheme.displayFont(size: 18, weight: FontWeight.w700),
          ),
        ),
        GestureDetector(
          onTap: () {
            _refreshAllData();
            _snack('Refreshing data...');
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GreenTheme.cardAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GreenTheme.border),
            ),
            child: const Icon(Icons.refresh_rounded, size: 20),
          ),
        ),
      ],
    ),
  );
}






  // ─── Student Card ───────────────────────────────────────────────────────────
  Widget _buildStudentCard(StudentModel s) {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: GreenTheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: GreenTheme.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: GreenTheme.accent.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _avatar(s.studentName),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.studentName,
                                  style: GreenTheme.displayFont(
                                    size: 16,
                                    weight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: s.callingStatus == CallStatus.called
                                      ? GreenTheme.statusCalled
                                      : GreenTheme.statusPending,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.studentId,
                            style: GreenTheme.bodyFont(
                              size: 10,
                              color: GreenTheme.textMuted,
                            ),
                          ),
                          Text(
                            s.batchName.isNotEmpty ? s.batchName : 'No batch',
                            style: GreenTheme.bodyFont(
                              size: 11,
                              color: GreenTheme.accent,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: GreenTheme.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _infoTile(
                      Icons.phone_rounded,
                      'Mobile',
                      s.mobileNumber.isNotEmpty ? s.mobileNumber : '—',
                    ),
                    const SizedBox(width: 12),
                    _infoTile(
                      Icons.supervisor_account_rounded,
                      'Parent',
                      s.parentNumber.isNotEmpty ? s.parentNumber : '—',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _infoTile(
                      Icons.bar_chart_rounded,
                      'Attend',
                      '${s.attendance.toStringAsFixed(0)}%',
                      vc: s.attendance < 60
                          ? GreenTheme.statusUnreachable
                          : GreenTheme.statusCalled,
                    ),
                    const SizedBox(width: 12),
                    _infoTile(
                      Icons.account_balance_wallet_rounded,
                      'Fee',
                      s.feeStatus.name.toUpperCase(),
                      vc: _feeColor(s.feeStatus),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(s.callingStatus).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _statusColor(s.callingStatus).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _statusIcon(s.callingStatus),
                            color: _statusColor(s.callingStatus),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _statusLabel(s.callingStatus),
                            style: GreenTheme.bodyFont(
                              size: 10,
                              weight: FontWeight.w600,
                              color: _statusColor(s.callingStatus),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${s.callAttempts} attempt${s.callAttempts != 1 ? 's' : ''}',
                      style: GreenTheme.bodyFont(
                        size: 10,
                        color: GreenTheme.textMuted,
                      ),
                    ),
                    if (s.lastCalledAt != null)
                      Text(
                        '· ${_timeAgo(s.lastCalledAt!)}',
                        style: GreenTheme.bodyFont(
                          size: 10,
                          color: GreenTheme.textMuted,
                        ),
                      ),
                  ],
                ),
                if ((s.notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GreenTheme.cardAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GreenTheme.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notes_rounded,
                          color: GreenTheme.textMuted,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            s.notes!,
                            style: GreenTheme.bodyFont(size: 10),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _gradBtn(
                        Icons.call_rounded,
                        'Call Student',
                        GreenTheme.accentGradient,
                        () {
                          _makeCall(s.mobileNumber, s.studentName);
                          _showCallSheet(s, isParent: false);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _gradBtn(
                        Icons.people_rounded,
                        'Parent',
                        const LinearGradient(
                          colors: [Color(0xFF00897B), Color(0xFF00695C)],
                        ),
                        () {
                          _makeCall(s.parentNumber, '${s.studentName} Parent');
                          _showCallSheet(s, isParent: true);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _iconCircleBtn(
                      Icons.chat_rounded,
                      const Color(0xFF25D366),
                      () => _openWhatsApp(s.mobileNumber, s.studentName),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _secBtn(
                        Icons.check_rounded,
                        'Complete',
                        GreenTheme.statusCalled,
                        () => _showCallSheet(
                          s,
                          isParent: false,
                          preset: CallStatus.called,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _secBtn(
                        Icons.refresh_rounded,
                        'Follow Up',
                        GreenTheme.statusFollowUp,
                        () => _showCallSheet(
                          s,
                          isParent: false,
                          preset: CallStatus.followUpRequired,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _secBtn(
                        Icons.thumb_up_rounded,
                        'Interested',
                        GreenTheme.statusInterested,
                        () => _showCallSheet(
                          s,
                          isParent: false,
                          preset: CallStatus.interested,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _secBtn(
                        Icons.delete_rounded,
                        'Delete',
                        GreenTheme.statusNotInterested,
                        () => _confirmDeleteStudent(s),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fade(duration: 200.ms)
        .scale(begin: const Offset(0.96, 0.96), duration: 250.ms);
  }

  // ─── Call Report Sheet ──────────────────────────────────────────────────────
  void _showCallSheet(
    StudentModel student, {
    required bool isParent,
    CallStatus? preset,
  }) {
    if (_isBusy) return;
    final notesCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '0');
    DateTime? followUpDate;
    bool interested = preset == CallStatus.interested;
    bool parentContacted = isParent;
    CallStatus? chosenStatus = preset;

    final allStatuses = CallStatus.values
        .where((s) => s != CallStatus.pending)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GreenTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: GreenTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Call Report',
                    style: GreenTheme.displayFont(
                      size: 18,
                      weight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${student.studentName} – ${isParent ? "Parent Call" : "Student Call"}',
                    style: GreenTheme.bodyFont(color: GreenTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Call Status *',
                    style: GreenTheme.bodyFont(
                      size: 12,
                      weight: FontWeight.w600,
                      color: GreenTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allStatuses.map((cs) {
                      final sel = chosenStatus == cs;
                      return GestureDetector(
                        onTap: () => setS(() {
                          chosenStatus = cs;
                          if (cs == CallStatus.interested) interested = true;
                          if (cs == CallStatus.parentContacted)
                            parentContacted = true;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? _statusColor(cs).withOpacity(0.15)
                                : GreenTheme.cardAlt,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? _statusColor(cs) : GreenTheme.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _statusIcon(cs),
                                color: sel
                                    ? _statusColor(cs)
                                    : GreenTheme.textMuted,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _statusLabel(cs),
                                style: GreenTheme.bodyFont(
                                  size: 11,
                                  color: sel
                                      ? _statusColor(cs)
                                      : GreenTheme.textMuted,
                                  weight: sel
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  _inputField('Notes', notesCtrl, Icons.notes_rounded),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now().add(
                                const Duration(days: 1),
                              ),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null)
                              setS(() => followUpDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: GreenTheme.cardAlt,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: GreenTheme.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  color: GreenTheme.textMuted,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  followUpDate != null
                                      ? DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(followUpDate!)
                                      : 'Follow-up Date',
                                  style: GreenTheme.bodyFont(
                                    size: 12,
                                    color: followUpDate != null
                                        ? GreenTheme.textPrimary
                                        : GreenTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _inputField(
                          'Duration (sec)',
                          durationCtrl,
                          Icons.timer_rounded,
                          kt: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _toggleChip(
                          'Interested',
                          Icons.thumb_up_rounded,
                          GreenTheme.statusInterested,
                          interested,
                          () => setS(() => interested = !interested),
                        ),
                      ),
                      if (!isParent) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _toggleChip(
                            'Parent Contacted',
                            Icons.family_restroom_rounded,
                            GreenTheme.statusParentContacted,
                            parentContacted,
                            () =>
                                setS(() => parentContacted = !parentContacted),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _isBusy
                          ? null
                          : () async {
                              if (chosenStatus == null) {
                                _snack(
                                  'Please select a call status',
                                  err: true,
                                );
                                return;
                              }
                              Navigator.pop(ctx);
                              final dur =
                                  int.tryParse(durationCtrl.text.trim()) ?? 0;
                              await _updateCallStatus(
                                student,
                                chosenStatus!,
                                duration: dur,
                                notes: notesCtrl.text.trim().isNotEmpty
                                    ? notesCtrl.text.trim()
                                    : null,
                                followUpDate: followUpDate,
                                interested: interested,
                                parentContacted: parentContacted || isParent,
                              );
                            },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: GreenTheme.accentGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'Save Report',
                            style: GreenTheme.displayFont(
                              size: 15,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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

  // ==========================================================================
  // STUDENT DETAIL
  // FIX: sub-streams for call history and feedback are stable because they
  // are created fresh only when _buildStudentDetail is called with a new
  // student – and they're scoped inside their own StableStreamBuilders.
  // ==========================================================================

  Widget _buildStudentDetail(StudentModel s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: GreenTheme.cardDecoration(elevated: true),
            child: Row(
              children: [
                _avatar(s.studentName, size: 70),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.studentName,
                        style: GreenTheme.displayFont(
                          size: 20,
                          weight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        s.studentId,
                        style: GreenTheme.bodyFont(
                          size: 11,
                          color: GreenTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            s.callingStatus,
                          ).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusLabel(s.callingStatus),
                          style: GreenTheme.bodyFont(
                            size: 11,
                            color: _statusColor(s.callingStatus),
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Student Information',
            style: GreenTheme.displayFont(size: 15, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: GreenTheme.cardDecoration(),
            child: Column(
              children: [
                _detRow(
                  Icons.phone_rounded,
                  'Mobile',
                  s.mobileNumber.isNotEmpty ? s.mobileNumber : '—',
                ),
                _detRow(
                  Icons.supervisor_account_rounded,
                  'Parent',
                  s.parentNumber.isNotEmpty ? s.parentNumber : '—',
                ),
                _detRow(
                  Icons.email_rounded,
                  'Email',
                  s.email.isNotEmpty ? s.email : 'Not provided',
                ),
                _detRow(
                  Icons.home_rounded,
                  'Address',
                  s.address.isNotEmpty ? s.address : 'Not provided',
                ),
                _detRow(
                  Icons.school_rounded,
                  'Course',
                  s.course.isNotEmpty ? s.course : 'Not specified',
                ),
                _detRow(
                  Icons.view_module_rounded,
                  'Batch',
                  s.batchName.isNotEmpty ? s.batchName : '—',
                ),
                _detRow(
                  Icons.bar_chart_rounded,
                  'Attendance',
                  '${s.attendance.toStringAsFixed(1)}%',
                ),
                _detRow(
                  Icons.account_balance_wallet_rounded,
                  'Fee Status',
                  s.feeStatus.name.toUpperCase(),
                  color: _feeColor(s.feeStatus),
                ),
                _detRow(
                  Icons.phone_callback_rounded,
                  'Call Attempts',
                  s.callAttempts.toString(),
                ),
                if (s.lastCalledAt != null)
                  _detRow(
                    Icons.access_time_rounded,
                    'Last Called',
                    DateFormat('dd/MM/yy HH:mm').format(s.lastCalledAt!),
                  ),
                if ((s.notes ?? '').isNotEmpty)
                  _detRow(Icons.notes_rounded, 'Notes', s.notes!),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actBtn(
                  Icons.call_rounded,
                  'Call',
                  GreenTheme.accentGradient,
                  () => _makeCall(s.mobileNumber, s.studentName),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actBtn(
                  Icons.people_rounded,
                  'Parent',
                  const LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF00695C)],
                  ),
                  () => _makeCall(s.parentNumber, '${s.studentName} Parent'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actBtn(
                  Icons.chat_rounded,
                  'WhatsApp',
                  const LinearGradient(
                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                  ),
                  () => _openWhatsApp(s.mobileNumber, s.studentName),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _actBtn(
                  Icons.assignment_rounded,
                  'Call Report',
                  const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)],
                  ),
                  () => _showCallSheet(s, isParent: false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actBtn(
                  Icons.edit_rounded,
                  'Edit Student',
                  const LinearGradient(
                    colors: [Color(0xFF0288D1), Color(0xFF0277BD)],
                  ),
                  () => _showEditStudentSheet(s),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actBtn(
                  Icons.delete_rounded,
                  'Delete',
                  const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFC62828)],
                  ),
                  () => _confirmDeleteStudent(s),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Call History',
            style: GreenTheme.displayFont(size: 15, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          // FIX: stable sub-stream for call history, no flash on updates
          StableStreamBuilder<List<CallLog>>(
            key: ValueKey('callhistory_${s.id}'),
            stream: FirebaseService.watchCallHistory(s.id),
            initialData: const [],
            loadingBuilder: (_) => _cardLoader(),
            errorBuilder: (_, __) => _cardMsg('Could not load call history.'),
            builder: (_, logs) {
              if (logs.isEmpty) return _cardMsg('No call history yet.');
              return Column(
                children: logs
                    .map(
                      (log) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: GreenTheme.cardDecoration(),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  log.status,
                                ).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _statusIcon(log.status),
                                color: _statusColor(log.status),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _statusLabel(log.status),
                                    style: GreenTheme.bodyFont(
                                      size: 12,
                                      weight: FontWeight.w600,
                                      color: _statusColor(log.status),
                                    ),
                                  ),
                                  if ((log.notes ?? '').isNotEmpty)
                                    Text(
                                      log.notes!,
                                      style: GreenTheme.bodyFont(
                                        size: 10,
                                        color: GreenTheme.textMuted,
                                      ),
                                    ),
                                  Text(
                                    '${log.calledBy.isNotEmpty ? log.calledBy : "Unknown"} · ${DateFormat('dd/MM/yy HH:mm').format(log.calledAt)}',
                                    style: GreenTheme.bodyFont(
                                      size: 10,
                                      color: GreenTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (log.duration > 0)
                              Text(
                                '${log.duration}s',
                                style: GreenTheme.bodyFont(
                                  size: 11,
                                  color: GreenTheme.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Feedback History',
            style: GreenTheme.displayFont(size: 15, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          StableStreamBuilder<List<FeedbackModel>>(
            key: ValueKey('feedback_${s.id}'),
            stream: FirebaseService.watchFeedbacks(s.id),
            initialData: const [],
            loadingBuilder: (_) => _cardLoader(),
            errorBuilder: (_, __) => _cardMsg('Could not load feedback.'),
            builder: (_, fbs) {
              if (fbs.isEmpty) return _cardMsg('No feedback yet.');
              return Column(
                children: fbs
                    .map(
                      (fb) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: GreenTheme.cardDecoration(),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: GreenTheme.accent.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.feedback_rounded,
                                color: GreenTheme.accent,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fb.feedbackType,
                                    style: GreenTheme.bodyFont(
                                      size: 12,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  if ((fb.notes ?? '').isNotEmpty)
                                    Text(
                                      fb.notes!,
                                      style: GreenTheme.bodyFont(
                                        size: 10,
                                        color: GreenTheme.textMuted,
                                      ),
                                    ),
                                  Text(
                                    'By ${fb.facultyName} · ${DateFormat('dd/MM/yy HH:mm').format(fb.createdAt)}',
                                    style: GreenTheme.bodyFont(
                                      size: 10,
                                      color: GreenTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showEditStudentSheet(StudentModel s) {
    final nameCtrl = TextEditingController(text: s.studentName);
    final mobileCtrl = TextEditingController(text: s.mobileNumber);
    final parentCtrl = TextEditingController(text: s.parentNumber);
    final emailCtrl = TextEditingController(text: s.email);
    final addrCtrl = TextEditingController(text: s.address);
    final courseCtrl = TextEditingController(text: s.course);
    final notesCtrl = TextEditingController(text: s.notes ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GreenTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GreenTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Edit Student',
                  style: GreenTheme.displayFont(
                    size: 18,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _inputField('Student Name *', nameCtrl, Icons.person_rounded),
                const SizedBox(height: 10),
                _inputField(
                  'Mobile Number *',
                  mobileCtrl,
                  Icons.phone_rounded,
                  kt: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                _inputField(
                  'Parent Number',
                  parentCtrl,
                  Icons.family_restroom_rounded,
                  kt: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                _inputField(
                  'Email',
                  emailCtrl,
                  Icons.email_rounded,
                  kt: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                _inputField('Address', addrCtrl, Icons.home_rounded),
                const SizedBox(height: 10),
                _inputField('Course', courseCtrl, Icons.school_rounded),
                const SizedBox(height: 10),
                _inputField('Notes', notesCtrl, Icons.notes_rounded),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: isSaving
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty ||
                                mobileCtrl.text.trim().isEmpty) {
                              _snack('Name and mobile are required', err: true);
                              return;
                            }
                            if (!RegExp(
                              r'^\d{10}$',
                            ).hasMatch(mobileCtrl.text.trim())) {
                              _snack(
                                'Enter a valid 10-digit mobile number',
                                err: true,
                              );
                              return;
                            }
                            setS(() => isSaving = true);
                            try {
                              final updated = StudentModel(
                                id: s.id,
                                studentName: nameCtrl.text.trim(),
                                studentId: s.studentId,
                                mobileNumber: mobileCtrl.text.trim(),
                                parentNumber: parentCtrl.text.trim().isNotEmpty
                                    ? parentCtrl.text.trim()
                                    : s.parentNumber,
                                email: emailCtrl.text.trim(),
                                address: addrCtrl.text.trim(),
                                gender: s.gender,
                                attendance: s.attendance,
                                feeStatus: s.feeStatus,
                                callingStatus: s.callingStatus,
                                course: courseCtrl.text.trim(),
                                batchId: s.batchId,
                                batchName: s.batchName,
                                notes: notesCtrl.text.trim().isNotEmpty
                                    ? notesCtrl.text.trim()
                                    : null,
                                createdAt: s.createdAt,
                                lastCalledBy: s.lastCalledBy,
                                lastCalledAt: s.lastCalledAt,
                                callAttempts: s.callAttempts,
                              );
                              await FirebaseService.updateStudent(
                                updated,
                                _currentFacultyId,
                                _currentFacultyName,
                              );
                              if (mounted) {
                                Navigator.pop(ctx);
                                setState(() => _selectedStudent = updated);
                                _snack('Student updated');
                              }
                            } catch (e) {
                              if (mounted)
                                _snack(
                                  e.toString().replaceAll('Exception: ', ''),
                                  err: true,
                                );
                            } finally {
                              setS(() => isSaving = false);
                            }
                          },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: isSaving
                            ? const LinearGradient(
                                colors: [Colors.grey, Colors.grey],
                              )
                            : GreenTheme.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GreenTheme.displayFont(
                                  size: 15,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
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
    );
  }

  // ==========================================================================
  // TAB 1 – DASHBOARD
  // FIX: Removed nested StreamBuilders that caused cascading rebuilds.
  // Uses a single combined StableStreamBuilder approach with cached streams.
  // Stats are computed inline – no setState called from stream callbacks.
  // ==========================================================================

Widget _buildDashboardTab() {
  return RefreshIndicator(
    onRefresh: () async {
      _refreshAllData();
      await Future.delayed(const Duration(milliseconds: 500));
    },
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: GreenTheme.displayFont(size: 22, weight: FontWeight.w700),
          ),
          Text(
            DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
            style: GreenTheme.bodyFont(size: 12, color: GreenTheme.textMuted),
          ),
          const SizedBox(height: 20),
          // Students stream for stats
          StableStreamBuilder<List<StudentModel>>(
            stream: _studentsStream,
            initialData: const [],
            builder: (_, students) {
              return StableStreamBuilder<List<BatchModel>>(
                stream: _batchesStream,
                initialData: const [],
                builder: (_, batches) {
                  return StableStreamBuilder<List<FacultyModel>>(
                    stream: _facultiesStream,
                    initialData: const [],
                    builder: (_, faculties) {
                      final today = DateTime.now();
                      final calledToday = students.where((s) {
                        final lca = s.lastCalledAt;
                        if (lca == null) return false;
                        return lca.year == today.year &&
                            lca.month == today.month &&
                            lca.day == today.day;
                      }).length;

                      final stats = DashboardStats(
                        totalStudents: students.length,
                        totalBatches: batches.length,
                        totalFaculty: faculties.length,
                        calledToday: calledToday,
                        pendingCalls: students
                            .where((s) => s.callingStatus == CallStatus.pending)
                            .length,
                        unreachable: students
                            .where(
                              (s) => s.callingStatus == CallStatus.notReachable,
                            )
                            .length,
                        followUps: students
                            .where(
                              (s) =>
                                  s.callingStatus ==
                                  CallStatus.followUpRequired,
                            )
                            .length,
                        interestedStudents: students
                            .where(
                              (s) => s.callingStatus == CallStatus.interested,
                            )
                            .length,
                        admissionConfirmed: students
                            .where((s) => s.callingStatus == CallStatus.called)
                            .length,
                        completionPercentage: students.isEmpty
                            ? 0
                            : calledToday / students.length,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTargetCardWithStats(stats),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _dashCard(
                                'Batches',
                                batches.length.toString(),
                                Icons.view_module_rounded,
                                GreenTheme.teal,
                              ),
                              const SizedBox(width: 10),
                              _dashCard(
                                'Faculty',
                                faculties.length.toString(),
                                Icons.school_rounded,
                                GreenTheme.statusFollowUp,
                              ),
                              const SizedBox(width: 10),
                              _dashCard(
                                'Students',
                                students.length.toString(),
                                Icons.people_alt_rounded,
                                GreenTheme.accent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.7,
                            children: [
                              _statCard(
                                'Called Today',
                                stats.calledToday.toString(),
                                Icons.check_circle_rounded,
                                GreenTheme.statusCalled,
                              ),
                              _statCard(
                                'Pending',
                                stats.pendingCalls.toString(),
                                Icons.hourglass_empty_rounded,
                                GreenTheme.statusPending,
                              ),
                              _statCard(
                                'Follow Up',
                                stats.followUps.toString(),
                                Icons.refresh_rounded,
                                GreenTheme.statusFollowUp,
                              ),
                              _statCard(
                                'Unreachable',
                                stats.unreachable.toString(),
                                Icons.phone_missed_rounded,
                                GreenTheme.statusUnreachable,
                              ),
                              _statCard(
                                'Interested',
                                stats.interestedStudents.toString(),
                                Icons.thumb_up_rounded,
                                GreenTheme.statusInterested,
                              ),
                              _statCard(
                                'Admission Conf',
                                stats.admissionConfirmed.toString(),
                                Icons.verified_rounded,
                                GreenTheme.statusCalled,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Recent Activity',
            style: GreenTheme.displayFont(size: 15, weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _buildActivityFeed(),
        ],),
      ),
    );
  }

  Widget _buildTargetCardWithStats(DashboardStats stats) {
    final pct = stats.completionPercentage.clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF145C43), Color(0xFF0D3B2E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    GreenTheme.accentLight,
                  ),
                  strokeWidth: 6,
                ),
                Text(
                  '${(pct * 100).toInt()}%',
                  style: GreenTheme.displayFont(
                    size: 13,
                    weight: FontWeight.w700,
                    color: GreenTheme.accentLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Progress',
                  style: GreenTheme.displayFont(
                    size: 15,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.calledToday} of ${stats.totalStudents} students called today',
                  style: GreenTheme.bodyFont(size: 12, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      GreenTheme.accentLight,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashCard(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: GreenTheme.cardDecoration(elevated: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                value,
                style: GreenTheme.displayFont(
                  size: 22,
                  weight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GreenTheme.bodyFont(
                  size: 10,
                  color: GreenTheme.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );

  Widget _statCard(String label, String value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: GreenTheme.cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: GreenTheme.displayFont(
                      size: 20,
                      weight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: GreenTheme.bodyFont(
                      size: 10,
                      color: GreenTheme.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildActivityFeed() {
    return StableStreamBuilder<List<ActivityLog>>(
      stream: _activityStream,
      initialData: const [],
      loadingBuilder: (_) => _cardLoader(),
      errorBuilder: (_, __) => _cardMsg('Unable to load activity.'),
      builder: (_, logs) {
        if (logs.isEmpty) return _cardMsg('No recent activity.');
        return Column(
          children: logs
              .map(
                (log) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: GreenTheme.cardDecoration(),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: GreenTheme.accent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _activityIcon(log.activityType),
                          color: GreenTheme.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.activityType.replaceAll('_', ' '),
                              style: GreenTheme.bodyFont(
                                size: 12,
                                weight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              log.actionDetails,
                              style: GreenTheme.bodyFont(
                                size: 11,
                                color: GreenTheme.textMuted,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeAgo(log.timestamp),
                        style: GreenTheme.bodyFont(
                          size: 10,
                          color: GreenTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  // ==========================================================================
  // TAB 2 – REPORTS
  // ==========================================================================

Widget _buildReportsTab() {
  return RefreshIndicator(
    onRefresh: () async {
      _refreshAllData();
      await Future.delayed(const Duration(milliseconds: 500));
    },
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports',
                  style: GreenTheme.displayFont(
                    size: 22,
                    weight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Calling history & analytics',
                  style: GreenTheme.bodyFont(
                    size: 12,
                    color: GreenTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: ['Today', 'This Week', 'This Month'].map((p) {
                    final sel = _selectedPeriod == p;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = p),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: sel ? GreenTheme.accentGradient : null,
                          color: sel ? null : GreenTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel
                                ? GreenTheme.accentDark
                                : GreenTheme.border,
                          ),
                        ),
                        child: Text(
                          p,
                          style: GreenTheme.bodyFont(
                            size: 12,
                            weight:
                                sel ? FontWeight.w600 : FontWeight.w400,
                            color: sel
                                ? Colors.white
                                : GreenTheme.textMuted,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: StableStreamBuilder<List<CallReport>>(
              stream: _callReportsStream,
              initialData: const [],
              loadingBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, __) =>
                  _errorWidget('Unable to load reports.'),
              builder: (_, allReports) {
                final now = DateTime.now();

                final reports = allReports.where((r) {
                  if (_selectedPeriod == 'Today') {
                    return r.callDate.year == now.year &&
                        r.callDate.month == now.month &&
                        r.callDate.day == now.day;
                  } else if (_selectedPeriod == 'This Week') {
                    return r.callDate.isAfter(
                      now.subtract(const Duration(days: 7)),
                    );
                  } else {
                    return r.callDate.isAfter(
                      DateTime(now.year, now.month, 1),
                    );
                  }
                }).toList();

                if (reports.isEmpty) {
                  return _emptyState(
                    'No reports for $_selectedPeriod',
                    'Make some calls to see data here.',
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reports.length,
                  itemBuilder: (_, i) {
                    final r = reports[i];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: GreenTheme.cardDecoration(),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _statusColor(r.status)
                                  .withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _statusIcon(r.status),
                              color: _statusColor(r.status),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.studentName.isNotEmpty
                                      ? r.studentName
                                      : 'Unknown',
                                  style: GreenTheme.bodyFont(
                                    size: 13,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  r.batchName.isNotEmpty
                                      ? r.batchName
                                      : '—',
                                  style: GreenTheme.bodyFont(
                                    size: 11,
                                    color: GreenTheme.textMuted,
                                  ),
                                ),
                                if ((r.notes ?? '').isNotEmpty)
                                  Text(
                                    r.notes!,
                                    style: GreenTheme.bodyFont(
                                      size: 10,
                                      color:
                                          GreenTheme.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Text(
                                _statusLabel(r.status),
                                style: GreenTheme.bodyFont(
                                  size: 11,
                                  weight: FontWeight.w600,
                                  color:
                                      _statusColor(r.status),
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yy HH:mm')
                                    .format(r.callDate),
                                style: GreenTheme.bodyFont(
                                  size: 10,
                                  color:
                                      GreenTheme.textMuted,
                                ),
                              ),
                              if (r.duration > 0)
                                Text(
                                  '${r.duration}s',
                                  style: GreenTheme.bodyFont(
                                    size: 9,
                                    color:
                                        GreenTheme.textMuted,
                                  ),
                                ),
                              if (r.interested)
                                const Icon(
                                  Icons.thumb_up,
                                  color: GreenTheme
                                      .statusInterested,
                                  size: 12,
                                ),
                            ],
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
      ),
    ),
  );
}

  // ==========================================================================
  // TAB 3 – FACULTY
  // ==========================================================================

Widget _buildFacultyTab() {
  return RefreshIndicator(
    onRefresh: () async {
      _refreshAllData();
      await Future.delayed(const Duration(milliseconds: 500));
    },
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Faculty Management',
                    style: GreenTheme.displayFont(
                      size: 20,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                _addBtn('Add Faculty', _showAddFacultySheet),
              ],
            ),
          ),
          StableStreamBuilder<List<FacultyModel>>(
            stream: _facultiesStream,
            initialData: const [],
            loadingBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, __) => _errorWidget('Unable to load faculty.'),
            builder: (_, list) {
              if (list.isEmpty) {
                return _emptyState(
                  'No Faculty Added',
                  'Tap + to add faculty members.',
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) => _facultyCard(list[i]),
              );
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _facultyCard(FacultyModel f) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: GreenTheme.cardDecoration(elevated: true),
    child: ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          gradient: GreenTheme.accentGradient,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            f.name.isNotEmpty ? f.name[0].toUpperCase() : '?',
            style: GreenTheme.displayFont(
              size: 20,
              weight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
      title: Text(
        f.name,
        style: GreenTheme.displayFont(size: 14, weight: FontWeight.w700),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${f.facultyId}  ·  ${f.department}',
            style: GreenTheme.bodyFont(size: 11),
          ),
          Text(
            f.mobile,
            style: GreenTheme.bodyFont(size: 11, color: GreenTheme.textMuted),
          ),
          Text(
            '${f.assignedBatches.length} batches  ·  ${f.totalCalls} calls',
            style: GreenTheme.bodyFont(size: 10, color: GreenTheme.accent),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              size: 18,
              color: GreenTheme.textSecondary,
            ),
            onPressed: () => _showEditFacultySheet(f),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              size: 18,
              color: GreenTheme.statusNotInterested,
            ),
            onPressed: () => _confirmDeleteFaculty(f),
          ),
        ],
      ),
    ),
  );

  void _showAddFacultySheet() {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final desigCtrl = TextEditingController();
    _facultyFormSheet(
      'Add Faculty',
      nameCtrl,
      idCtrl,
      mobileCtrl,
      emailCtrl,
      deptCtrl,
      desigCtrl,
      null,
      () async {
        if (nameCtrl.text.trim().isEmpty || mobileCtrl.text.trim().isEmpty) {
          _snack('Name and mobile are required', err: true);
          return;
        }
        try {
          final f = FacultyModel(
            id: 'fac_${DateTime.now().millisecondsSinceEpoch}',
            name: nameCtrl.text.trim(),
            facultyId: idCtrl.text.trim().isEmpty
                ? 'FAC${DateTime.now().millisecondsSinceEpoch}'
                : idCtrl.text.trim(),
            mobile: mobileCtrl.text.trim(),
            email: emailCtrl.text.trim(),
            department: deptCtrl.text.trim().isEmpty
                ? 'General'
                : deptCtrl.text.trim(),
            designation: desigCtrl.text.trim().isEmpty
                ? 'Faculty'
                : desigCtrl.text.trim(),
            createdAt: DateTime.now(),
          );
          await FirebaseService.addFaculty(f);
          if (mounted) {
            Navigator.pop(context);
            _snack('Faculty added: ${f.name}');
          }
        } catch (e) {
          if (mounted)
            _snack(e.toString().replaceAll('Exception: ', ''), err: true);
        }
      },
    );
  }

  void _showEditFacultySheet(FacultyModel f) {
    final nameCtrl = TextEditingController(text: f.name);
    final idCtrl = TextEditingController(text: f.facultyId);
    final mobileCtrl = TextEditingController(text: f.mobile);
    final emailCtrl = TextEditingController(text: f.email);
    final deptCtrl = TextEditingController(text: f.department);
    final desigCtrl = TextEditingController(text: f.designation);
    _facultyFormSheet(
      'Edit Faculty',
      nameCtrl,
      idCtrl,
      mobileCtrl,
      emailCtrl,
      deptCtrl,
      desigCtrl,
      f,
      () async {
        try {
          await FirebaseService.updateFaculty(
            f.copyWith(
              name: nameCtrl.text.trim(),
              facultyId: idCtrl.text.trim(),
              mobile: mobileCtrl.text.trim(),
              email: emailCtrl.text.trim(),
              department: deptCtrl.text.trim(),
              designation: desigCtrl.text.trim(),
            ),
          );
          if (mounted) {
            Navigator.pop(context);
            _snack('Faculty updated');
          }
        } catch (e) {
          if (mounted)
            _snack(e.toString().replaceAll('Exception: ', ''), err: true);
        }
      },
    );
  }

  void _facultyFormSheet(
    String title,
    TextEditingController nameCtrl,
    TextEditingController idCtrl,
    TextEditingController mobileCtrl,
    TextEditingController emailCtrl,
    TextEditingController deptCtrl,
    TextEditingController desigCtrl,
    FacultyModel? existing,
    VoidCallback onSave,
  ) {
    bool isSaving = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GreenTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GreenTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GreenTheme.displayFont(
                    size: 18,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _inputField('Full Name *', nameCtrl, Icons.person_rounded),
                const SizedBox(height: 10),
                _inputField('Faculty ID', idCtrl, Icons.badge_rounded),
                const SizedBox(height: 10),
                _inputField(
                  'Mobile *',
                  mobileCtrl,
                  Icons.phone_rounded,
                  kt: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                _inputField(
                  'Email',
                  emailCtrl,
                  Icons.email_rounded,
                  kt: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                _inputField('Department', deptCtrl, Icons.business_rounded),
                const SizedBox(height: 10),
                _inputField('Designation', desigCtrl, Icons.work_rounded),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: isSaving
                        ? null
                        : () {
                            setS(() => isSaving = true);
                            onSave();
                          },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: GreenTheme.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                existing == null
                                    ? 'Add Faculty'
                                    : 'Save Changes',
                                style: GreenTheme.displayFont(
                                  size: 15,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
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
    );
  }

  void _confirmDeleteFaculty(FacultyModel f) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: GreenTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Faculty',
          style: GreenTheme.displayFont(size: 17, weight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete "${f.name}"?', style: GreenTheme.bodyFont()),
            if (f.assignedBatches.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ This faculty has ${f.assignedBatches.length} assigned batch(es). Please reassign them first.',
                style: GreenTheme.bodyFont(
                  size: 12,
                  color: GreenTheme.statusNotInterested,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GreenTheme.bodyFont(color: GreenTheme.textMuted),
            ),
          ),
          if (f.assignedBatches.isEmpty)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FirebaseService.deleteFaculty(f.id, f.name);
                  if (mounted) _snack('Faculty deleted');
                } catch (e) {
                  if (mounted)
                    _snack(
                      e.toString().replaceAll('Exception: ', ''),
                      err: true,
                    );
                }
              },
              child: Text(
                'Delete',
                style: GreenTheme.bodyFont(
                  color: GreenTheme.statusNotInterested,
                  weight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 4 – BATCHES
  // ==========================================================================

Widget _buildBatchesTab() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Batch Management',
                style: GreenTheme.displayFont(
                  size: 20,
                  weight: FontWeight.w700,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () {
                    _refreshAllData();
                    _snack('Refreshing batches...');
                  },
                  tooltip: 'Refresh',
                ),
                _addBtn('New Batch', _showAddBatchSheet),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: StreamBuilder<List<BatchModel>>(
          stream: FirebaseService.watchBatches(
            facultyId: _currentFacultyId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading batches...'),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return _errorWidget('Error: ${snapshot.error}');
            }

            final list = snapshot.data ?? [];

            if (list.isEmpty) {
              return _emptyState(
                'No Batches Created',
                'Tap + to create your first batch.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _refreshAllData();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) => _batchCard(list[i]),
              ),
            );
          },
        ),
      ),
    ],
  );
}

  Widget _batchCard(BatchModel b) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: GreenTheme.cardDecoration(elevated: true),
    child: ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: GreenTheme.accentGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            b.batchName.isNotEmpty ? b.batchName[0].toUpperCase() : 'B',
            style: GreenTheme.displayFont(
              size: 18,
              weight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
      title: Text(
        b.batchName,
        style: GreenTheme.displayFont(size: 14, weight: FontWeight.w700),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${b.courseName}  ·  ${b.timing}',
            style: GreenTheme.bodyFont(size: 11),
          ),
          Text(
            '${b.studentCount} students  ·  Code: ${b.batchCode}',
            style: GreenTheme.bodyFont(size: 10, color: GreenTheme.textMuted),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: GreenTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              b.status.name.toUpperCase(),
              style: GreenTheme.bodyFont(
                size: 9,
                color: GreenTheme.accent,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.person_add,
              size: 18,
              color: GreenTheme.textSecondary,
            ),
            onPressed: () => _showAddStudentSheet(b),
            tooltip: 'Add Student',
          ),
          IconButton(
            icon: const Icon(
              Icons.edit,
              size: 18,
              color: GreenTheme.textSecondary,
            ),
            onPressed: () => _showEditBatchSheet(b),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              size: 18,
              color: GreenTheme.statusNotInterested,
            ),
            onPressed: () => _confirmDeleteBatch(b),
          ),
        ],
      ),
    ),
  );

  void _showAddBatchSheet() {
    final nameCtrl = TextEditingController();
    final courseCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: '10:00 AM');
    final endCtrl = TextEditingController(text: '12:00 PM');
    final notesCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GreenTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GreenTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create Batch',
                  style: GreenTheme.displayFont(
                    size: 18,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _inputField('Batch Name *', nameCtrl, Icons.group_rounded),
                const SizedBox(height: 10),
                _inputField('Course Name *', courseCtrl, Icons.school_rounded),
                const SizedBox(height: 10),
                _inputField('Batch Code', codeCtrl, Icons.qr_code_rounded),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _inputField(
                        'Start Time',
                        startCtrl,
                        Icons.access_time_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _inputField(
                        'End Time',
                        endCtrl,
                        Icons.access_time_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _inputField('Notes', notesCtrl, Icons.notes_rounded),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: isSaving
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty ||
                                courseCtrl.text.trim().isEmpty) {
                              _snack(
                                'Batch name and course are required',
                                err: true,
                              );
                              return;
                            }
                            setS(() => isSaving = true);
                            try {
                              final now = DateTime.now();
                              final batchId =
                                  'batch_${now.millisecondsSinceEpoch}';

                              final b = BatchModel(
                                id: batchId,
                                batchName: nameCtrl.text.trim(),
                                courseName: courseCtrl.text.trim(),
                                batchCode: codeCtrl.text.trim().isEmpty
                                    ? 'BATCH${now.millisecondsSinceEpoch}'
                                    : codeCtrl.text.trim(),
                                facultyName: _currentFacultyName,
                                facultyId: _currentFacultyId,
                                batchTiming:
                                    '${startCtrl.text.trim()} - ${endCtrl.text.trim()}',
                                startTime: startCtrl.text.trim(),
                                endTime: endCtrl.text.trim(),
                                createdAt: now,
                                notes: notesCtrl.text.trim().isNotEmpty
                                    ? notesCtrl.text.trim()
                                    : null,
                              );

// Inside _showAddBatchSheet, replace the success callback
await FirebaseService.addBatch(
  b,
  _currentFacultyId,
  _currentFacultyName,
);

if (mounted) {
  // Clear all caches first
  _StreamCache.refreshAll();
  
  // Force refresh all streams
  setState(() {
    _batchesStream = FirebaseService.watchBatches(
      facultyId: _currentFacultyId,
    ).asBroadcastStream();
    
    _studentsStream = FirebaseService.watchStudents(
      batchId: _selectedBatchId.isEmpty ? null : _selectedBatchId,
    ).asBroadcastStream();
    
    // Update swiper key to force rebuild
    _swiperKey = 'swiper_${_selectedBatchId}_${DateTime.now().millisecondsSinceEpoch}';
  });
  
  Navigator.pop(ctx);
  _snack('Batch "${b.batchName}" created successfully!');
}
                            } catch (e) {
                              print('Error saving batch: $e');
                              if (mounted)
                                _snack(
                                  'Error: ${e.toString().replaceAll('Exception: ', '')}',
                                  err: true,
                                );
                            } finally {
                              if (mounted) {
                                setS(() => isSaving = false);
                              }
                            }
                          },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: isSaving
                            ? const LinearGradient(
                                colors: [Colors.grey, Colors.grey],
                              )
                            : GreenTheme.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Create Batch',
                                style: GreenTheme.displayFont(
                                  size: 15,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
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
    );
  }

  void _showEditBatchSheet(BatchModel b) {
    final nameCtrl = TextEditingController(text: b.batchName);
    final courseCtrl = TextEditingController(text: b.courseName);
    final codeCtrl = TextEditingController(text: b.batchCode);
    final startCtrl = TextEditingController(text: b.startTime);
    final endCtrl = TextEditingController(text: b.endTime);
    final notesCtrl = TextEditingController(text: b.notes ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GreenTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GreenTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Edit Batch',
                  style: GreenTheme.displayFont(
                    size: 18,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _inputField('Batch Name *', nameCtrl, Icons.group_rounded),
                const SizedBox(height: 10),
                _inputField('Course', courseCtrl, Icons.school_rounded),
                const SizedBox(height: 10),
                _inputField('Batch Code', codeCtrl, Icons.qr_code_rounded),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _inputField(
                        'Start Time',
                        startCtrl,
                        Icons.access_time_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _inputField(
                        'End Time',
                        endCtrl,
                        Icons.access_time_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _inputField('Notes', notesCtrl, Icons.notes_rounded),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: isSaving
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty) {
                              _snack('Batch name is required', err: true);
                              return;
                            }
                            setS(() => isSaving = true);
                            try {
                              await FirebaseService.updateBatch(
                                b.copyWith(
                                  batchName: nameCtrl.text.trim(),
                                  courseName: courseCtrl.text.trim(),
                                  batchCode: codeCtrl.text.trim(),
                                  startTime: startCtrl.text.trim(),
                                  endTime: endCtrl.text.trim(),
                                  batchTiming:
                                      '${startCtrl.text.trim()} - ${endCtrl.text.trim()}',
                                  notes: notesCtrl.text.trim().isNotEmpty
                                      ? notesCtrl.text.trim()
                                      : null,
                                ),
                                _currentFacultyId,
                                _currentFacultyName,
                              );
                              if (mounted) {
                                Navigator.pop(ctx);
                                _snack('Batch updated');
                              }
                            } catch (e) {
                              if (mounted)
                                _snack(
                                  e.toString().replaceAll('Exception: ', ''),
                                  err: true,
                                );
                            } finally {
                              setS(() => isSaving = false);
                            }
                          },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: GreenTheme.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GreenTheme.displayFont(
                                  size: 15,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
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
    );
  }

  void _showAddStudentSheet(BatchModel batch) {
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final parentCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final courseCtrl = TextEditingController(text: batch.courseName);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GreenTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GreenTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add Student',
                  style: GreenTheme.displayFont(
                    size: 18,
                    weight: FontWeight.w700,
                  ),
                ),
                Text(
                  'to ${batch.batchName}',
                  style: GreenTheme.bodyFont(color: GreenTheme.textMuted),
                ),
                const SizedBox(height: 16),
                _inputField('Student Name *', nameCtrl, Icons.person_rounded),
                const SizedBox(height: 10),
                _inputField(
                  'Mobile Number *',
                  mobileCtrl,
                  Icons.phone_rounded,
                  kt: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                _inputField(
                  'Parent Number',
                  parentCtrl,
                  Icons.family_restroom_rounded,
                  kt: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                _inputField(
                  'Email',
                  emailCtrl,
                  Icons.email_rounded,
                  kt: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                _inputField('Address', addrCtrl, Icons.home_rounded),
                const SizedBox(height: 10),
                _inputField('Course', courseCtrl, Icons.school_rounded),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: isSaving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            final mobile = mobileCtrl.text.trim();
                            if (name.isEmpty || mobile.isEmpty) {
                              _snack('Name and mobile are required', err: true);
                              return;
                            }
                            if (!RegExp(r'^\d{7,15}$').hasMatch(mobile)) {
                              _snack('Enter a valid mobile number', err: true);
                              return;
                            }
                            setS(() => isSaving = true);
                            try {
                              final now = DateTime.now();
                              final s = StudentModel(
                                id: 'student_${now.millisecondsSinceEpoch}',
                                studentName: name,
                                studentId: 'BEEDI${now.millisecondsSinceEpoch}',
                                mobileNumber: mobile,
                                parentNumber: parentCtrl.text.trim().isEmpty
                                    ? mobile
                                    : parentCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                address: addrCtrl.text.trim(),
                                course: courseCtrl.text.trim(),
                                batchId: batch.id,
                                batchName: batch.batchName,
                                createdAt: now,
                              );
// Inside _showAddStudentSheet, replace the success part
// Inside _showAddStudentSheet, after await FirebaseService.addStudent
await FirebaseService.addStudent(
  s,
  _currentFacultyId,
  _currentFacultyName,
);

if (mounted) {
  Navigator.pop(ctx);
  _snack('Student "$name" added to ${batch.batchName}');
  
  // Clear cache and refresh all data
  _StreamCache.refreshAll();
  _StreamCache.refreshStudents(batchId: _selectedBatchId);
  
  // Force refresh the students list
  setState(() {
    _studentsStream = FirebaseService.watchStudents(
      batchId: _selectedBatchId.isEmpty ? null : _selectedBatchId,
    ).asBroadcastStream();
    
    // Force swiper to rebuild
    _swiperKey = 'swiper_${_selectedBatchId}_${DateTime.now().millisecondsSinceEpoch}';
  });
}
                            } catch (e) {
                              if (mounted)
                                _snack(
                                  e.toString().replaceAll('Exception: ', ''),
                                  err: true,
                                );
                            } finally {
                              setS(() => isSaving = false);
                            }
                          },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: GreenTheme.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Add Student',
                                style: GreenTheme.displayFont(
                                  size: 15,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
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
    );
  }

  void _confirmDeleteBatch(BatchModel b) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: GreenTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Batch',
          style: GreenTheme.displayFont(size: 17, weight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete "${b.batchName}"?', style: GreenTheme.bodyFont()),
            if (b.studentCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ This will also permanently delete ${b.studentCount} student record(s). This action cannot be undone.',
                style: GreenTheme.bodyFont(
                  size: 12,
                  color: GreenTheme.statusNotInterested,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to proceed?',
              style: GreenTheme.bodyFont(size: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GreenTheme.bodyFont(color: GreenTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog immediately
              Navigator.pop(context);

              // Show a loading indicator
              _snack('Deleting batch "${b.batchName}"...');

              try {
                // Perform deletion
                await FirebaseService.deleteBatch(
                  b.id,
                  b.batchName,
                  _currentFacultyId,
                  _currentFacultyName,
                );

                // Clear cache and refresh streams
                _StreamCache.refreshBatches(facultyId: _currentFacultyId);
                _StreamCache.refreshStudents();

                if (mounted) {
                  // Force refresh the batches stream
                  setState(() {
                    _batchesStream = FirebaseService.watchBatches(
                      facultyId: _currentFacultyId,
                    ).asBroadcastStream();

                    // If the deleted batch was selected, reset batch selection
                    if (_selectedBatchId == b.id) {
                      _selectedBatchId = '';
                      _selectedBatchName = '';
                      _rebuildStudentsStream();
                    }
                  });

                  _snack('Batch "${b.batchName}" deleted successfully');
                }
              } catch (e) {
                if (mounted) {
                  _snack(
                    'Error deleting batch: ${e.toString().replaceAll('Exception: ', '')}',
                    err: true,
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: GreenTheme.bodyFont(
                color: GreenTheme.statusNotInterested,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStudent(StudentModel s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: GreenTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Student',
          style: GreenTheme.displayFont(size: 17, weight: FontWeight.w700),
        ),
        content: Text(
          'Delete "${s.studentName}"? This cannot be undone.',
          style: GreenTheme.bodyFont(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GreenTheme.bodyFont(color: GreenTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStudent(s);
            },
            child: Text(
              'Delete',
              style: GreenTheme.bodyFont(
                color: GreenTheme.statusNotInterested,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BOTTOM NAV + FAB
  // ==========================================================================

  Widget _buildBottomNav() {
    const items = [
      (Icons.phone_in_talk_rounded, 'Calling'),
      (Icons.dashboard_rounded, 'Dashboard'),
      (Icons.bar_chart_rounded, 'Reports'),
      (Icons.school_rounded, 'Faculty'),
      (Icons.view_module_rounded, 'Batches'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: GreenTheme.surface,
        border: Border(top: BorderSide(color: GreenTheme.border)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = _currentTab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _currentTab = i;
                    _showStudentDetail = false;
                    _selectedStudent = null;
                  }),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i].$1,
                        color: active
                            ? GreenTheme.accent
                            : GreenTheme.textMuted,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].$2,
                        style: GreenTheme.bodyFont(
                          size: 9,
                          color: active
                              ? GreenTheme.accent
                              : GreenTheme.textMuted,
                          weight: active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    if (_showStudentDetail) return const SizedBox.shrink();

    final opts = <(IconData, String, Color, VoidCallback)>[
      (
        Icons.person_add_rounded,
        'Add Student',
        GreenTheme.statusBusy,
        () {
          if (_selectedBatchId.isEmpty) {
            _snack(
              'Select a batch first (use the batch filter above)',
              err: true,
            );
          } else {
            final dummy = BatchModel(
              id: _selectedBatchId,
              batchName: _selectedBatchName,
              courseName: '',
              batchCode: '',
              facultyName: _currentFacultyName,
              facultyId: _currentFacultyId,
              batchTiming: '',
              startTime: '',
              endTime: '',
              createdAt: DateTime.now(),
            );
            _showAddStudentSheet(dummy);
          }
        },
      ),
      (
        Icons.create_new_folder_rounded,
        'Create Batch',
        GreenTheme.teal,
        _showAddBatchSheet,
      ),
      (
        Icons.school_rounded,
        'Add Faculty',
        GreenTheme.statusFollowUp,
        _showAddFacultySheet,
      ),
      (
        Icons.ios_share_rounded,
        'Export Excel',
        GreenTheme.statusCalled,
        _exportToExcel,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_fabExpanded)
          ...opts.map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() => _fabExpanded = false);
                  _fabAnimCtrl.reverse();
                  o.$4();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: GreenTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GreenTheme.border),
                      ),
                      child: Text(
                        o.$2,
                        style: GreenTheme.bodyFont(
                          size: 12,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: o.$3,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(o.$1, color: Colors.white, size: 19),
                    ),
                  ],
                ),
              ),
            ),
          ),
        FloatingActionButton(
          onPressed: () {
            setState(() => _fabExpanded = !_fabExpanded);
            _fabExpanded ? _fabAnimCtrl.forward() : _fabAnimCtrl.reverse();
          },
          backgroundColor: GreenTheme.accent,
          elevation: 8,
          child: AnimatedRotation(
            turns: _fabExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SHARED WIDGETS
  // ==========================================================================

  Widget _avatar(String name, {double size = 52}) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: GreenTheme.accentGradient,
        shape: BoxShape.circle,
        border: Border.all(color: GreenTheme.border, width: 2),
        boxShadow: [
          BoxShadow(color: GreenTheme.accent.withOpacity(0.25), blurRadius: 8),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: GreenTheme.displayFont(
            size: size * 0.38,
            weight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, {Color? vc}) =>
      Expanded(
        child: Row(
          children: [
            Icon(icon, size: 13, color: GreenTheme.textMuted),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GreenTheme.bodyFont(
                      size: 9,
                      color: GreenTheme.textMuted,
                    ),
                  ),
                  Text(
                    value,
                    style: GreenTheme.bodyFont(
                      size: 11,
                      weight: FontWeight.w600,
                      color: vc ?? GreenTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _detRow(IconData icon, String label, String value, {Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: GreenTheme.textMuted),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: GreenTheme.bodyFont(
                  size: 12,
                  color: GreenTheme.textMuted,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GreenTheme.bodyFont(
                  size: 12,
                  color: color ?? GreenTheme.textPrimary,
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _gradBtn(
    IconData icon,
    String label,
    Gradient grad,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: grad,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: GreenTheme.displayFont(
                size: 11,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _iconCircleBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
      );

  Widget _secBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(height: 2),
          Text(
            label,
            style: GreenTheme.bodyFont(
              size: 8,
              color: color,
              weight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );

  Widget _actBtn(
    IconData icon,
    String label,
    Gradient grad,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        gradient: grad,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 3),
          Text(
            label,
            style: GreenTheme.displayFont(
              size: 10,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _addBtn(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: GreenTheme.accentGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: GreenTheme.displayFont(
              size: 12,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _inputField(
    String hint,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType kt = TextInputType.text,
    Function(String)? onChanged,
  }) => Container(
    decoration: BoxDecoration(
      color: GreenTheme.cardAlt,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: GreenTheme.border),
    ),
    child: TextField(
      controller: ctrl,
      keyboardType: kt,
      style: GreenTheme.bodyFont(color: GreenTheme.textPrimary),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GreenTheme.bodyFont(color: GreenTheme.textMuted),
        prefixIcon: Icon(icon, color: GreenTheme.textMuted, size: 18),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
    ),
  );

  Widget _toggleChip(
    String label,
    IconData icon,
    Color color,
    bool active,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.12) : GreenTheme.cardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? color : GreenTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? color : GreenTheme.textMuted, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GreenTheme.bodyFont(
                size: 11,
                color: active ? color : GreenTheme.textMuted,
                weight: active ? FontWeight.w600 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: GreenTheme.border,
    highlightColor: GreenTheme.cardAlt,
    child: Column(
      children: List.generate(
        2,
        (_) => Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          height: 360,
          decoration: BoxDecoration(
            color: GreenTheme.surface,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    ),
  );

  Widget _emptyState(String title, String subtitle) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: GreenTheme.accent.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.inbox_rounded,
            color: GreenTheme.accent,
            size: 38,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: GreenTheme.displayFont(size: 17, weight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GreenTheme.bodyFont(color: GreenTheme.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _errorWidget(String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: GreenTheme.statusUnreachable,
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          msg,
          style: GreenTheme.bodyFont(color: GreenTheme.statusUnreachable),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _cardMsg(String msg) => Container(
    padding: const EdgeInsets.all(20),
    decoration: GreenTheme.cardDecoration(),
    child: Center(
      child: Text(msg, style: GreenTheme.bodyFont(color: GreenTheme.textMuted)),
    ),
  );

  Widget _cardLoader() => Container(
    padding: const EdgeInsets.all(20),
    decoration: GreenTheme.cardDecoration(),
    child: const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );
}
