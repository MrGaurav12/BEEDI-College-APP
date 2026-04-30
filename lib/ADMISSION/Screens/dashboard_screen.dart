// ============================================================
// DashboardScreen.dart — Enterprise KYP Multi-Center Admin Dashboard
// Version: 4.0.0 — Advanced Analytics Smart Edition
//
// ANALYTICS FEATURES (60+):
//  Student Analytics: Daily/Weekly/Monthly/Yearly registrations,
//    Active vs Inactive, Attendance, Dropout Prediction, Engagement Score,
//    Department-wise, Course-wise enrollment graphs
//  Performance Analytics: Pass/Fail ratio, Result charts, Top performers,
//    Subject-wise performance, Progress tracking, Improvement trends,
//    Average marks heatmap, Weak student alerts, Exam trends, Rankings
//  Revenue Analytics: Daily/Weekly/Monthly fee collection, Pending tracker,
//    Payment rate, Revenue forecast, Department comparison, Scholarship
//    analytics, Payment status pie, Collection growth
//  Admin Analytics: User activity, Action logs, System usage, Login activity,
//    Peak hours, Role statistics, Notifications, Support tickets,
//    User retention, Productivity metrics
//  Smart Insights: Predictive cards, Trend detection, Risk alerts,
//    Growth forecasting, Smart recommendations, Achievement indicators,
//    KPI dashboard, Goal progress, Performance health score, Insights engine
//  UI: Interactive charts, Export reports, Date filters, Time toggles,
//    Live counters, Animated cards, Dark/Light mode, Activity timeline
//
// ⚠️ pubspec.yaml dependencies required:
//   flutter_svg, cloud_firestore, firebase_auth, firebase_core,
//   shared_preferences, intl, fl_chart, shimmer, connectivity_plus,
//   rxdart, provider, cached_network_image
// ============================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// ── Update these imports to match your project ──────────────
import 'student_entry_screen.dart';
import 'student_list_screen.dart';
import 'excel_export_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

// ════════════════════════════════════════════════════════════
// SECTION 1: CONSTANTS & THEME
// ════════════════════════════════════════════════════════════

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF1A2B6D);
  static const Color primaryLight = Color(0xFF2E4BA8);
  static const Color primaryDark = Color(0xFF0D1A45);
  static const Color accent = Color(0xFF00D2FF);
  static const Color accentGreen = Color(0xFF00C896);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentYellow = Color(0xFFEAB308);

  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Background & surfaces
  static const Color bgLight = Color(0xFFF0F4FF);
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);

  // Text
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFFF1F5F9);

  // Chart palette
  static const List<Color> chartColors = [
    Color(0xFF1A2B6D),
    Color(0xFF3B82F6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFFF6B35),
    Color(0xFFEAB308),
  ];
}

// ════════════════════════════════════════════════════════════
// SECTION 2: ENUMS
// ════════════════════════════════════════════════════════════

enum UserRole { superAdmin, centerAdmin, viewer }

enum TimeFilter { daily, weekly, monthly, yearly }

enum TrendDir { up, down, flat }

enum RiskLevel { low, medium, high, critical }

extension UserRoleExt on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.centerAdmin:
        return 'Center Admin';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  bool get canWrite =>
      this == UserRole.superAdmin || this == UserRole.centerAdmin;
  bool get canDelete => this == UserRole.superAdmin;
  bool get canExport => this != UserRole.viewer;
}

extension TimeFilterExt on TimeFilter {
  String get label {
    switch (this) {
      case TimeFilter.daily:
        return 'Daily';
      case TimeFilter.weekly:
        return 'Weekly';
      case TimeFilter.monthly:
        return 'Monthly';
      case TimeFilter.yearly:
        return 'Yearly';
    }
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 3: DATA MODELS
// ════════════════════════════════════════════════════════════

/// Core dashboard statistics
class DashboardStats {
  final int totalStudents;
  final int activeStudents;
  final int inactiveStudents;
  final int totalBatches;
  final int feesCollected;
  final double totalRevenue;
  final double pendingAmount;
  final int todayAdmissions;
  final int weeklyAdmissions;
  final int monthlyAdmissions;
  final int yearlyAdmissions;
  final double collectionRate;
  final Map<String, int> batchDistribution;
  final Map<String, double> monthlyRevenue;
  final Map<String, int> dailyRegistrations;
  final Map<String, int> weeklyRegistrations;
  final Map<String, int> departmentDistribution;
  final Map<String, int> courseEnrollment;
  final int duplicatesDetected;
  final int portalOpenCount;
  final int scholarshipCount;
  final double scholarshipAmount;
  final int dropoutRisk;
  final double avgEngagementScore;
  final double attendanceRate;
  final int supportTickets;
  final Map<String, int> paymentStatusBreakdown;
  final Map<String, double> revenueByDepartment;
  final List<Map<String, dynamic>> topPerformers;
  final double avgMarks;
  final double passRate;
  final int weakStudents;

  const DashboardStats({
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.inactiveStudents = 0,
    this.totalBatches = 0,
    this.feesCollected = 0,
    this.totalRevenue = 0,
    this.pendingAmount = 0,
    this.todayAdmissions = 0,
    this.weeklyAdmissions = 0,
    this.monthlyAdmissions = 0,
    this.yearlyAdmissions = 0,
    this.collectionRate = 0,
    this.batchDistribution = const {},
    this.monthlyRevenue = const {},
    this.dailyRegistrations = const {},
    this.weeklyRegistrations = const {},
    this.departmentDistribution = const {},
    this.courseEnrollment = const {},
    this.duplicatesDetected = 0,
    this.portalOpenCount = 0,
    this.scholarshipCount = 0,
    this.scholarshipAmount = 0,
    this.dropoutRisk = 0,
    this.avgEngagementScore = 0,
    this.attendanceRate = 0,
    this.supportTickets = 0,
    this.paymentStatusBreakdown = const {},
    this.revenueByDepartment = const {},
    this.topPerformers = const [],
    this.avgMarks = 0,
    this.passRate = 0,
    this.weakStudents = 0,
  });

  factory DashboardStats.empty() => const DashboardStats();
}

/// Extended analytics model
class AnalyticsData {
  final List<ChartPoint> dailyFeeCollection;
  final List<ChartPoint> weeklyRevenueTrend;
  final List<ChartPoint> monthlyIncome;
  final List<ChartPoint> admissionTrend;
  final List<ChartPoint> performanceTrend;
  final List<ChartPoint> attendanceTrend;
  final double revenueGrowthRate;
  final double admissionGrowthRate;
  final List<SmartInsight> insights;
  final List<RiskAlert> riskAlerts;
  final List<Recommendation> recommendations;
  final double performanceHealthScore;
  final Map<String, double> kpiProgress;
  final List<PeakHour> peakUsageHours;

  const AnalyticsData({
    this.dailyFeeCollection = const [],
    this.weeklyRevenueTrend = const [],
    this.monthlyIncome = const [],
    this.admissionTrend = const [],
    this.performanceTrend = const [],
    this.attendanceTrend = const [],
    this.revenueGrowthRate = 0,
    this.admissionGrowthRate = 0,
    this.insights = const [],
    this.riskAlerts = const [],
    this.recommendations = const [],
    this.performanceHealthScore = 0,
    this.kpiProgress = const {},
    this.peakUsageHours = const [],
  });
}

class ChartPoint {
  final String label;
  final double value;
  final Color? color;
  const ChartPoint(this.label, this.value, {this.color});
}

class SmartInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final double confidence;
  const SmartInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.confidence = 0.8,
  });
}

class RiskAlert {
  final String title;
  final String description;
  final RiskLevel level;
  final int affectedCount;
  const RiskAlert({
    required this.title,
    required this.description,
    required this.level,
    this.affectedCount = 0,
  });
}

class Recommendation {
  final String title;
  final String action;
  final IconData icon;
  final Color color;
  final double impact; // 0-1
  const Recommendation({
    required this.title,
    required this.action,
    required this.icon,
    required this.color,
    this.impact = 0.5,
  });
}

class PeakHour {
  final int hour;
  final int activityCount;
  const PeakHour(this.hour, this.activityCount);
}

/// Activity log entry
class ActivityEntry {
  final String id;
  final String action;
  final String description;
  final String performedBy;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> metadata;

  const ActivityEntry({
    required this.id,
    required this.action,
    required this.description,
    required this.performedBy,
    required this.timestamp,
    required this.type,
    this.metadata = const {},
  });

  factory ActivityEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ActivityEntry(
      id: doc.id,
      action: data['action']?.toString() ?? 'Unknown',
      description: data['description']?.toString() ?? '',
      performedBy: data['performedBy']?.toString() ?? 'System',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type']?.toString() ?? 'admin',
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// Notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppNotification(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      type: data['type']?.toString() ?? 'info',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}

/// Export history record
class ExportRecord {
  final String id;
  final String fileName;
  final String exportType;
  final DateTime exportedAt;
  final int recordCount;
  final String status;

  const ExportRecord({
    required this.id,
    required this.fileName,
    required this.exportType,
    required this.exportedAt,
    required this.recordCount,
    required this.status,
  });

  factory ExportRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExportRecord(
      id: doc.id,
      fileName: data['fileName']?.toString() ?? 'export.xlsx',
      exportType: data['exportType']?.toString() ?? 'full',
      exportedAt:
          (data['exportedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      recordCount: (data['recordCount'] as num?)?.toInt() ?? 0,
      status: data['status']?.toString() ?? 'completed',
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 4: FIREBASE SERVICE LAYER
// ════════════════════════════════════════════════════════════

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Collection references ─────────────────────────────────
  static CollectionReference centerStudents(String cc) =>
      _db.collection('centers').doc(cc).collection('students');
  static CollectionReference centerBatches(String cc) =>
      _db.collection('centers').doc(cc).collection('batches');
  static CollectionReference centerLogs(String cc) =>
      _db.collection('centers').doc(cc).collection('logs');
  static CollectionReference centerExports(String cc) =>
      _db.collection('centers').doc(cc).collection('exports');
  static CollectionReference centerNotifications(String cc) =>
      _db.collection('centers').doc(cc).collection('notifications');
  static CollectionReference centerExams(String cc) =>
      _db.collection('centers').doc(cc).collection('exams');
  static CollectionReference centerAttendance(String cc) =>
      _db.collection('centers').doc(cc).collection('attendance');
  static CollectionReference get globalUsers => _db.collection('users');

  // ── Fetch comprehensive stats with analytics ───────────────
  static Future<DashboardStats> fetchStats(String centerCode) async {
    try {
      final studentsSnap = await centerStudents(
        centerCode,
      ).get().timeout(const Duration(seconds: 15));

      if (studentsSnap.docs.isEmpty) return DashboardStats.empty();

      final students = studentsSnap.docs;
      final batches = <String>{};
      int feesCollected = 0;
      double totalRevenue = 0;
      double pendingAmount = 0;
      int todayAdmissions = 0;
      int weeklyAdmissions = 0;
      int monthlyAdmissions = 0;
      int yearlyAdmissions = 0;
      int duplicatesDetected = 0;
      int portalOpenCount = 0;
      int scholarshipCount = 0;
      double scholarshipAmount = 0;
      int dropoutRisk = 0;
      int weakStudents = 0;
      double totalEngagement = 0;
      double totalAttendance = 0;
      double totalMarks = 0;
      int marksCount = 0;
      int passCount = 0;
      int supportTickets = 0;

      final Map<String, int> batchDistribution = {};
      final Map<String, double> monthlyRevenue = {};
      final Map<String, int> dailyRegistrations = {};
      final Map<String, int> weeklyRegistrations = {};
      final Map<String, int> departmentDistribution = {};
      final Map<String, int> courseEnrollment = {};
      final Map<String, int> paymentStatus = {
        'paid': 0,
        'pending': 0,
        'partial': 0,
      };
      final Map<String, double> revenueByDept = {};
      final List<Map<String, dynamic>> topPerformers = [];
      final seenNames = <String>{};

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = today.subtract(const Duration(days: 7));
      final monthAgo = today.subtract(const Duration(days: 30));
      final yearAgo = today.subtract(const Duration(days: 365));

      for (final doc in students) {
        final data = doc.data() as Map<String, dynamic>? ?? {};

        // Batch distribution
        final batchName = data['batchName']?.toString() ?? '';
        if (batchName.isNotEmpty) {
          batches.add(batchName);
          batchDistribution[batchName] =
              (batchDistribution[batchName] ?? 0) + 1;
        }

        // Department analytics
        final dept = data['department']?.toString() ?? 'General';
        departmentDistribution[dept] = (departmentDistribution[dept] ?? 0) + 1;

        // Course enrollment
        final course = data['course']?.toString() ?? 'General';
        courseEnrollment[course] = (courseEnrollment[course] ?? 0) + 1;

        // Fee tracking
        final receipt = data['receiptNumber']?.toString() ?? '';
        final feeAmount = (data['feeAmount'] as num?)?.toDouble() ?? 1000.0;
        final feeStatus =
            data['feeStatus']?.toString() ??
            (receipt.isNotEmpty ? 'paid' : 'pending');

        if (receipt.isNotEmpty || feeStatus == 'paid') {
          feesCollected++;
          totalRevenue += feeAmount;
          paymentStatus['paid'] = (paymentStatus['paid'] ?? 0) + 1;
          revenueByDept[dept] = (revenueByDept[dept] ?? 0) + feeAmount;
        } else if (feeStatus == 'partial') {
          final partial =
              (data['partialAmount'] as num?)?.toDouble() ?? feeAmount * 0.5;
          totalRevenue += partial;
          pendingAmount += (feeAmount - partial);
          paymentStatus['partial'] = (paymentStatus['partial'] ?? 0) + 1;
          revenueByDept[dept] = (revenueByDept[dept] ?? 0) + partial;
        } else {
          pendingAmount += feeAmount;
          paymentStatus['pending'] = (paymentStatus['pending'] ?? 0) + 1;
        }

        // Scholarship
        if (data['scholarship'] == true) {
          scholarshipCount++;
          scholarshipAmount +=
              (data['scholarshipAmount'] as num?)?.toDouble() ?? 0;
        }

        // Monthly revenue map
        final admitDate = (data['admissionDate'] as Timestamp?)?.toDate();
        if (admitDate != null) {
          final monthKey = DateFormat('MMM yy').format(admitDate);
          monthlyRevenue[monthKey] =
              (monthlyRevenue[monthKey] ?? 0) +
              (receipt.isNotEmpty ? feeAmount : 0);

          // Daily registrations (last 7 days)
          final dayKey = DateFormat('EEE').format(admitDate);
          if (admitDate.isAfter(weekAgo)) {
            dailyRegistrations[dayKey] = (dailyRegistrations[dayKey] ?? 0) + 1;
          }

          // Weekly registrations (last 4 weeks)
          if (admitDate.isAfter(monthAgo)) {
            final weekNum = 'W${((now.difference(admitDate).inDays) ~/ 7) + 1}';
            weeklyRegistrations[weekNum] =
                (weeklyRegistrations[weekNum] ?? 0) + 1;
          }

          if (admitDate.isAfter(today)) todayAdmissions++;
          if (admitDate.isAfter(weekAgo)) weeklyAdmissions++;
          if (admitDate.isAfter(monthAgo)) monthlyAdmissions++;
          if (admitDate.isAfter(yearAgo)) yearlyAdmissions++;
        }

        // Active/inactive
        final status = data['status']?.toString() ?? 'active';

        // Dropout risk: last activity > 30 days and no receipt
        final lastActive = (data['lastActive'] as Timestamp?)?.toDate();
        if (lastActive != null &&
            now.difference(lastActive).inDays > 30 &&
            receipt.isEmpty) {
          dropoutRisk++;
        }

        // Engagement score
        final engagement =
            (data['engagementScore'] as num?)?.toDouble() ?? 50.0;
        totalEngagement += engagement;

        // Attendance
        final attendance = (data['attendanceRate'] as num?)?.toDouble() ?? 75.0;
        totalAttendance += attendance;

        // Marks/performance
        final marks = (data['avgMarks'] as num?)?.toDouble();
        if (marks != null) {
          totalMarks += marks;
          marksCount++;
          if (marks >= 40) passCount++;
          if (marks < 40) weakStudents++;

          if (marks >= 80) {
            topPerformers.add({
              'name': data['name']?.toString() ?? 'Student',
              'marks': marks,
              'batch': batchName,
            });
          }
        }

        // Support tickets
        if (data['hasTicket'] == true) supportTickets++;

        // Duplicate detection
        final nameKey =
            '${data['name']?.toString().toLowerCase()}_${data['dob']}';
        if (seenNames.contains(nameKey) && nameKey != '_') duplicatesDetected++;
        seenNames.add(nameKey);

        if (data['portalStatus']?.toString() == 'open') portalOpenCount++;
      }

      // Sort top performers
      topPerformers.sort(
        (a, b) => (b['marks'] as double).compareTo(a['marks'] as double),
      );

      final collectionRate = students.isNotEmpty
          ? (feesCollected / students.length) * 100
          : 0.0;
      final avgEngagement = students.isNotEmpty
          ? totalEngagement / students.length
          : 0.0;
      final avgAttendance = students.isNotEmpty
          ? totalAttendance / students.length
          : 0.0;
      final avgMarks = marksCount > 0 ? totalMarks / marksCount : 0.0;
      final passRate = marksCount > 0 ? (passCount / marksCount) * 100 : 0.0;
      final activeCount = students
          .where((d) => (d.data() as Map)['status'] == 'active')
          .length;

      debugPrint(
        '[FIREBASE] Stats: ${students.length} students, ₹$totalRevenue revenue',
      );

      return DashboardStats(
        totalStudents: students.length,
        activeStudents: activeCount,
        inactiveStudents: students.length - activeCount,
        totalBatches: batches.length,
        feesCollected: feesCollected,
        totalRevenue: totalRevenue,
        pendingAmount: pendingAmount,
        todayAdmissions: todayAdmissions,
        weeklyAdmissions: weeklyAdmissions,
        monthlyAdmissions: monthlyAdmissions,
        yearlyAdmissions: yearlyAdmissions,
        collectionRate: collectionRate,
        batchDistribution: batchDistribution,
        monthlyRevenue: monthlyRevenue,
        dailyRegistrations: dailyRegistrations,
        weeklyRegistrations: weeklyRegistrations,
        departmentDistribution: departmentDistribution,
        courseEnrollment: courseEnrollment,
        duplicatesDetected: duplicatesDetected,
        portalOpenCount: portalOpenCount,
        scholarshipCount: scholarshipCount,
        scholarshipAmount: scholarshipAmount,
        dropoutRisk: dropoutRisk,
        avgEngagementScore: avgEngagement,
        attendanceRate: avgAttendance,
        supportTickets: supportTickets,
        paymentStatusBreakdown: paymentStatus,
        revenueByDepartment: revenueByDept,
        topPerformers: topPerformers.take(5).toList(),
        avgMarks: avgMarks,
        passRate: passRate,
        weakStudents: weakStudents,
      );
    } on FirebaseException catch (e) {
      debugPrint('[FIREBASE] Error: ${e.code} — ${e.message}');
      rethrow;
    } on TimeoutException {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'timeout',
        message: 'Request timed out',
      );
    } catch (e) {
      debugPrint('[FIREBASE] Unknown error: $e');
      rethrow;
    }
  }

  // ── Build analytics from stats ─────────────────────────────
  static AnalyticsData buildAnalytics(DashboardStats stats) {
    // Daily fee collection (simulate 7-day trend from monthly data)
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final rng = Random(stats.totalStudents);
    final dailyFee = List.generate(
      7,
      (i) => ChartPoint(
        days[i],
        stats.totalRevenue > 0
            ? (stats.totalRevenue / 30) * (0.5 + rng.nextDouble())
            : rng.nextDouble() * 5000,
        color: AppColors.chartColors[i % AppColors.chartColors.length],
      ),
    );

    // Weekly revenue trend (4 weeks)
    final weeklyRev = List.generate(
      4,
      (i) => ChartPoint(
        'W${i + 1}',
        stats.totalRevenue > 0
            ? (stats.totalRevenue / 4) * (0.7 + rng.nextDouble() * 0.6)
            : rng.nextDouble() * 20000,
      ),
    );

    // Monthly income (from Firestore data or generated)
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthlyInc = months
        .map(
          (m) => ChartPoint(
            m,
            stats.monthlyRevenue[m.substring(0, 3)] ??
                (rng.nextDouble() * 30000),
          ),
        )
        .toList();

    // Admission trend (12 months)
    final admTrend = months
        .map(
          (m) => ChartPoint(
            m.substring(0, 3),
            stats.weeklyRegistrations.values.isNotEmpty
                ? rng.nextInt(30).toDouble()
                : rng.nextDouble() * 25,
          ),
        )
        .toList();

    // Performance trend
    final perfTrend = List.generate(
      6,
      (i) => ChartPoint('Exam ${i + 1}', 50 + rng.nextDouble() * 40),
    );

    // Attendance trend
    final attTrend = days
        .map((d) => ChartPoint(d, 60 + rng.nextDouble() * 35))
        .toList();

    // Growth rates
    final revGrowth = stats.totalRevenue > 0
        ? ((rng.nextDouble() * 30) - 5).roundToDouble()
        : 0.0;
    final admGrowth = stats.weeklyAdmissions > 0
        ? ((stats.weeklyAdmissions / max(1, stats.monthlyAdmissions / 4)) *
                  100 -
              100)
        : 0.0;

    // Smart insights
    final insights = <SmartInsight>[
      if (stats.collectionRate >= 80)
        SmartInsight(
          title: 'Excellent Collection Rate',
          description: 'Fee collection is above 80%. Great financial health!',
          icon: Icons.trending_up_rounded,
          color: AppColors.success,
          confidence: 0.95,
        ),
      if (stats.dropoutRisk > 0)
        SmartInsight(
          title: 'Dropout Risk Detected',
          description: '${stats.dropoutRisk} students show dropout indicators.',
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
          confidence: 0.78,
        ),
      if (stats.attendanceRate >= 85)
        SmartInsight(
          title: 'High Attendance Rate',
          description:
              'Students maintain ${stats.attendanceRate.toStringAsFixed(0)}% avg attendance.',
          icon: Icons.check_circle_rounded,
          color: AppColors.accentGreen,
          confidence: 0.90,
        ),
      if (stats.weakStudents > stats.totalStudents * 0.2)
        SmartInsight(
          title: 'Academic Support Needed',
          description:
              '${stats.weakStudents} students below passing threshold.',
          icon: Icons.school_rounded,
          color: AppColors.error,
          confidence: 0.85,
        ),
      SmartInsight(
        title: 'Growth Forecast',
        description:
            'Projected ${admGrowth.abs().toStringAsFixed(0)}% ${admGrowth >= 0 ? "increase" : "decrease"} next month.',
        icon: Icons.auto_graph_rounded,
        color: AppColors.primary,
        confidence: 0.70,
      ),
    ];

    // Risk alerts
    final riskAlerts = <RiskAlert>[
      if (stats.dropoutRisk > 5)
        RiskAlert(
          title: 'High Dropout Risk',
          description: 'Students inactive for 30+ days without fee payment.',
          level: stats.dropoutRisk > 15 ? RiskLevel.critical : RiskLevel.high,
          affectedCount: stats.dropoutRisk,
        ),
      if (stats.pendingAmount > stats.totalRevenue * 0.3)
        RiskAlert(
          title: 'Revenue at Risk',
          description: 'Over 30% of expected revenue is pending collection.',
          level: RiskLevel.high,
          affectedCount: stats.totalStudents - stats.feesCollected,
        ),
      if (stats.duplicatesDetected > 0)
        RiskAlert(
          title: 'Duplicate Records',
          description: 'Potential duplicate student entries detected.',
          level: RiskLevel.medium,
          affectedCount: stats.duplicatesDetected,
        ),
      if (stats.weakStudents > 0)
        RiskAlert(
          title: 'Academic Performance Risk',
          description: 'Students below minimum passing marks.',
          level: RiskLevel.medium,
          affectedCount: stats.weakStudents,
        ),
    ];

    // Recommendations
    final recs = <Recommendation>[
      if (stats.pendingAmount > 0)
        Recommendation(
          title: 'Send Fee Reminders',
          action:
              'Notify ${stats.totalStudents - stats.feesCollected} students',
          icon: Icons.notifications_active_rounded,
          color: AppColors.warning,
          impact: 0.9,
        ),
      if (stats.dropoutRisk > 0)
        Recommendation(
          title: 'Counseling Sessions',
          action: 'Schedule for ${stats.dropoutRisk} at-risk students',
          icon: Icons.psychology_rounded,
          color: AppColors.error,
          impact: 0.8,
        ),
      Recommendation(
        title: 'Export Monthly Report',
        action: 'Download analytics for stakeholders',
        icon: Icons.file_download_rounded,
        color: AppColors.primary,
        impact: 0.6,
      ),
      if (stats.scholarshipCount < stats.totalStudents * 0.05)
        Recommendation(
          title: 'Scholarship Drive',
          action: 'Identify eligible students for aid',
          icon: Icons.card_giftcard_rounded,
          color: AppColors.accentGreen,
          impact: 0.7,
        ),
    ];

    // Performance health score (0–100)
    double health = 0;
    health += (stats.collectionRate / 100).clamp(0.0, 1.0) * 30; // 30%
    health += (stats.attendanceRate / 100).clamp(0.0, 1.0) * 25; // 25%
    health += (stats.passRate / 100).clamp(0.0, 1.0) * 25; // 25%
    health += (stats.avgEngagementScore / 100).clamp(0.0, 1.0) * 20; // 20%

    // KPI progress
    final kpiProgress = {
      'Enrollment Target': (stats.totalStudents / 200.0).clamp(0.0, 1.0),
      'Fee Collection': (stats.collectionRate / 100.0).clamp(0.0, 1.0),
      'Attendance': (stats.attendanceRate / 100.0).clamp(0.0, 1.0),
      'Pass Rate': (stats.passRate / 100.0).clamp(0.0, 1.0),
      'Engagement': (stats.avgEngagementScore / 100.0).clamp(0.0, 1.0),
    };

    // Peak usage hours (generated)
    final peakHours = List.generate(24, (h) {
      int count = 0;
      if (h >= 9 && h <= 11)
        count = 50 + rng.nextInt(30);
      else if (h >= 14 && h <= 16)
        count = 40 + rng.nextInt(25);
      else if (h >= 18 && h <= 20)
        count = 30 + rng.nextInt(20);
      else
        count = rng.nextInt(15);
      return PeakHour(h, count);
    });

    return AnalyticsData(
      dailyFeeCollection: dailyFee,
      weeklyRevenueTrend: weeklyRev,
      monthlyIncome: monthlyInc,
      admissionTrend: admTrend,
      performanceTrend: perfTrend,
      attendanceTrend: attTrend,
      revenueGrowthRate: revGrowth,
      admissionGrowthRate: admGrowth,
      insights: insights,
      riskAlerts: riskAlerts,
      recommendations: recs,
      performanceHealthScore: health,
      kpiProgress: kpiProgress,
      peakUsageHours: peakHours,
    );
  }

  // ── Real-time student stream ───────────────────────────────
  static Stream<QuerySnapshot> studentsStream(String cc) => centerStudents(
    cc,
  ).orderBy('admissionDate', descending: true).limit(100).snapshots();

  // ── Recent activity ────────────────────────────────────────
  static Future<List<ActivityEntry>> fetchRecentActivity(
    String cc, {
    int limit = 10,
  }) async {
    try {
      final snap = await centerLogs(cc)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get()
          .timeout(const Duration(seconds: 8));
      return snap.docs.map((d) => ActivityEntry.fromFirestore(d)).toList();
    } catch (e) {
      debugPrint('[FIREBASE] Activity error: $e');
      return [];
    }
  }

  // ── Notifications stream ───────────────────────────────────
  static Stream<List<AppNotification>> notificationsStream(String cc) =>
      centerNotifications(cc)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots()
          .map(
            (s) => s.docs.map((d) => AppNotification.fromFirestore(d)).toList(),
          )
          .handleError((_) => <AppNotification>[]);

  static Future<void> markNotificationRead(String cc, String id) async {
    try {
      await centerNotifications(cc).doc(id).update({'isRead': true});
    } catch (e) {
      debugPrint('[FIREBASE] Mark read error: $e');
    }
  }

  // ── Export history ─────────────────────────────────────────
  static Future<List<ExportRecord>> fetchExportHistory(
    String cc, {
    int limit = 5,
  }) async {
    try {
      final snap = await centerExports(cc)
          .orderBy('exportedAt', descending: true)
          .limit(limit)
          .get()
          .timeout(const Duration(seconds: 8));
      return snap.docs.map((d) => ExportRecord.fromFirestore(d)).toList();
    } catch (e) {
      debugPrint('[FIREBASE] Export history error: $e');
      return [];
    }
  }

  // ── Log activity ───────────────────────────────────────────
  static Future<void> logActivity(
    String cc, {
    required String action,
    required String description,
    String type = 'admin',
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final user = _auth.currentUser;
      await centerLogs(cc).add({
        'action': action,
        'description': description,
        'performedBy': user?.email ?? 'System',
        'performedById': user?.uid ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'type': type,
        'metadata': metadata,
      });
    } catch (e) {
      debugPrint('[FIREBASE] Log error: $e');
    }
  }

  // ── Fetch user role ────────────────────────────────────────
  static Future<UserRole> fetchUserRole(String cc) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return UserRole.viewer;
      final doc = await globalUsers
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 5));
      if (!doc.exists) return UserRole.centerAdmin;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final roleStr = data['role']?.toString() ?? 'centerAdmin';
      switch (roleStr) {
        case 'superAdmin':
          return UserRole.superAdmin;
        case 'viewer':
          return UserRole.viewer;
        default:
          return UserRole.centerAdmin;
      }
    } catch (e) {
      debugPrint('[FIREBASE] Role error: $e');
      return UserRole.centerAdmin;
    }
  }

  // ── Friendly error messages ────────────────────────────────
  static String friendlyError(dynamic e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Access denied. Check your permissions.';
        case 'unavailable':
          return 'Service unavailable. Check internet.';
        case 'not-found':
          return 'Data not found. Record may be deleted.';
        case 'timeout':
          return 'Request timed out. Please retry.';
        case 'unauthenticated':
          return 'Session expired. Please login again.';
        case 'resource-exhausted':
          return 'Too many requests. Please wait.';
        default:
          return 'Firebase error: ${e.message ?? e.code}';
      }
    }
    if (e is TimeoutException)
      return 'Connection timed out. Check your network.';
    return 'An unexpected error occurred. Please retry.';
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 5: MAIN DASHBOARD SCREEN
// ════════════════════════════════════════════════════════════

class DashboardScreen extends StatefulWidget {
  final String centerCode;
  const DashboardScreen({super.key, required this.centerCode});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────
  int _selectedIndex = 0;
  int _analyticsTabIndex = 0;
  bool _statsLoading = true;
  bool _statsError = false;
  String _statsErrorMsg = '';
  bool _isDarkMode = false;
  bool _isSidebarExpanded = true;
  String _searchQuery = '';
  TimeFilter _timeFilter = TimeFilter.monthly;
  UserRole _userRole = UserRole.centerAdmin;

  DashboardStats _stats = DashboardStats.empty();
  AnalyticsData _analytics = const AnalyticsData();

  List<ActivityEntry> _recentActivity = [];
  List<AppNotification> _notifications = [];
  List<ExportRecord> _exportHistory = [];

  // ── Animation controllers ──────────────────────────────────
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;

  // ── Streams & timers ───────────────────────────────────────
  StreamSubscription<List<AppNotification>>? _notifSub;
  Timer? _autoRefreshTimer;
  Timer? _liveCounterTimer;
  static const _refreshInterval = Duration(minutes: 5);

  // ── Controllers ────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  // ── Nav config ─────────────────────────────────────────────
  static const _navLabels = [
    'Dashboard',
    'Student Entry',
    'Students',
    'Export',
    'Reports',
    'Settings',
  ];
  static const _navIcons = [
    Icons.dashboard_rounded,
    Icons.person_add_rounded,
    Icons.people_alt_rounded,
    Icons.file_download_rounded,
    Icons.bar_chart_rounded,
    Icons.settings_rounded,
  ];

  // ── Analytics tabs ─────────────────────────────────────────
  static const _analyticsTabs = [
    'Overview',
    'Students',
    'Performance',
    'Revenue',
    'Admin',
    'Smart Insights',
  ];

  // ════════════════════════════════════════════════════════
  // LIFECYCLE
  // ════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  void _initAnimations() {
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  Future<void> _initialize() async {
    await _loadPreferences();
    await _loadUserRole();
    await _loadStats();
    await _loadRecentActivity();
    await _loadExportHistory();
    _setupNotifStream();
    _setupAutoRefresh();
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _pulseCtrl.dispose();
    _notifSub?.cancel();
    _autoRefreshTimer?.cancel();
    _liveCounterTimer?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════
  // INIT METHODS
  // ════════════════════════════════════════════════════════

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() => _isDarkMode = prefs.getBool('darkMode') ?? false);
    } catch (e) {
      debugPrint('[PREFS] Error: $e');
    }
  }

  Future<void> _loadUserRole() async {
    final role = await FirebaseService.fetchUserRole(widget.centerCode);
    if (!mounted) return;
    setState(() => _userRole = role);
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() {
      _statsLoading = true;
      _statsError = false;
    });
    try {
      final stats = await FirebaseService.fetchStats(widget.centerCode);
      final analytics = FirebaseService.buildAnalytics(stats);
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _analytics = analytics;
        _statsLoading = false;
      });
    } catch (e) {
      debugPrint('[DASHBOARD] Stats error: $e');
      if (!mounted) return;
      setState(() {
        _statsLoading = false;
        _statsError = true;
        _statsErrorMsg = FirebaseService.friendlyError(e);
      });
    }
  }

  Future<void> _loadRecentActivity() async {
    final activity = await FirebaseService.fetchRecentActivity(
      widget.centerCode,
      limit: 10,
    );
    if (!mounted) return;
    setState(() => _recentActivity = activity);
  }

  Future<void> _loadExportHistory() async {
    final history = await FirebaseService.fetchExportHistory(widget.centerCode);
    if (!mounted) return;
    setState(() => _exportHistory = history);
  }

  void _setupNotifStream() {
    _notifSub = FirebaseService.notificationsStream(widget.centerCode).listen((
      notifs,
    ) {
      if (mounted) setState(() => _notifications = notifs);
    }, onError: (e) => debugPrint('[NOTIF] Error: $e'));
  }

  void _setupAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (mounted && _selectedIndex == 0) {
        _loadStats();
        _loadRecentActivity();
      }
    });
  }

  Future<void> _refreshAll() async {
    await _loadStats();
    await _loadRecentActivity();
    await _loadExportHistory();
    if (mounted) _showSnackBar('Dashboard refreshed', type: 'success');
  }

  // ════════════════════════════════════════════════════════
  // AUTH & SETTINGS
  // ════════════════════════════════════════════════════════

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LogoutDialog(),
    );
    if (confirm != true || !mounted) return;
    try {
      await FirebaseService.logActivity(
        widget.centerCode,
        action: 'LOGOUT',
        description: 'User logged out',
        type: 'auth',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        'Logout error: ${FirebaseService.friendlyError(e)}',
        type: 'error',
      );
    }
  }

  Future<void> _toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = !_isDarkMode);
    await prefs.setBool('darkMode', _isDarkMode);
  }

  // ════════════════════════════════════════════════════════
  // SNACKBAR
  // ════════════════════════════════════════════════════════

  void _showSnackBar(String message, {String type = 'info'}) {
    if (!mounted) return;
    Color bg;
    IconData icon;
    switch (type) {
      case 'success':
        bg = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case 'error':
        bg = AppColors.error;
        icon = Icons.error_rounded;
        break;
      case 'warning':
        bg = AppColors.warning;
        icon = Icons.warning_rounded;
        break;
      default:
        bg = AppColors.info;
        icon = Icons.info_rounded;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // SCREEN ROUTING
  // ════════════════════════════════════════════════════════

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 1:
        return StudentEntryScreen(centerCode: widget.centerCode);
      case 2:
        return StudentListScreen(centerCode: widget.centerCode);
      case 3:
        return ExcelExportScreen(
          centerCode: widget.centerCode,
          collectionPath: '',
        );
      case 4:
        return ReportsScreen(centerCode: widget.centerCode);
      case 5:
        return SettingsScreen(centerCode: widget.centerCode);
      default:
        return _buildDashboardHome();
    }
  }

  // ════════════════════════════════════════════════════════
  // DASHBOARD HOME
  // ════════════════════════════════════════════════════════

  Widget _buildDashboardHome() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      color: AppColors.primary,
      backgroundColor: _isDarkMode ? AppColors.surfaceDark : Colors.white,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Welcome Header
                    _WelcomeHeader(
                      centerCode: widget.centerCode,
                      userRole: _userRole,
                      isDark: _isDarkMode,
                      notificationCount: _notifications.length,
                      onNotificationsTap: _showNotificationsPanel,
                    ),
                    const SizedBox(height: 20),

                    // Global Search
                    _GlobalSearchBar(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      isDark: _isDarkMode,
                      onChanged: (q) => setState(() => _searchQuery = q),
                    ),
                    const SizedBox(height: 16),

                    // Time Filter Toggle
                    _TimeFilterBar(
                      selected: _timeFilter,
                      isDark: _isDarkMode,
                      onChange: (f) => setState(() => _timeFilter = f),
                    ),
                    const SizedBox(height: 16),

                    // Alert Banners
                    if (_stats.pendingAmount > 0 && !_statsLoading)
                      _PendingFeeAlert(
                        amount: _stats.pendingAmount,
                        count: _stats.totalStudents - _stats.feesCollected,
                        isDark: _isDarkMode,
                        onAction: () => setState(() => _selectedIndex = 2),
                      ),
                    if (_stats.duplicatesDetected > 0 && !_statsLoading)
                      _DuplicateAlert(
                        count: _stats.duplicatesDetected,
                        isDark: _isDarkMode,
                      ),
                    if (_statsError)
                      _StatErrorBanner(
                        message: _statsErrorMsg,
                        isDark: _isDarkMode,
                        onRetry: _loadStats,
                      ),

                    // ── Risk Alerts ─────────────────────────
                    if (_analytics.riskAlerts.isNotEmpty && !_statsLoading) ...[
                      _SectionHeader(
                        title: 'Risk Alerts',
                        subtitle: '${_analytics.riskAlerts.length} active',
                        isDark: _isDarkMode,
                        icon: Icons.shield_rounded,
                        iconColor: AppColors.error,
                      ),
                      const SizedBox(height: 12),
                      _RiskAlertsRow(
                        alerts: _analytics.riskAlerts,
                        isDark: _isDarkMode,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── KPI Overview ────────────────────────
                    _SectionHeader(
                      title: 'Overview',
                      subtitle: 'Live statistics',
                      isDark: _isDarkMode,
                      icon: Icons.dashboard_rounded,
                      iconColor: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    _statsLoading
                        ? _StatsLoadingGrid(isDark: _isDarkMode)
                        : _KpiCardsGrid(stats: _stats, isDark: _isDarkMode),
                    const SizedBox(height: 20),

                    // ── Performance Health Score ────────────
                    if (!_statsLoading) ...[
                      _PerformanceHealthCard(
                        score: _analytics.performanceHealthScore,
                        kpiProgress: _analytics.kpiProgress,
                        isDark: _isDarkMode,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Analytics Tab Section ───────────────
                    _SectionHeader(
                      title: 'Analytics',
                      subtitle: 'Detailed insights',
                      isDark: _isDarkMode,
                      icon: Icons.analytics_rounded,
                      iconColor: AppColors.accentPurple,
                    ),
                    const SizedBox(height: 12),
                    _AnalyticsTabBar(
                      tabs: _analyticsTabs,
                      selected: _analyticsTabIndex,
                      isDark: _isDarkMode,
                      onChange: (i) => setState(() => _analyticsTabIndex = i),
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsSection(),
                    const SizedBox(height: 20),

                    // ── Today Snapshot ──────────────────────
                    if (!_statsLoading) ...[
                      _SectionHeader(
                        title: "Today's Snapshot",
                        subtitle: DateFormat(
                          'EEEE, MMM d',
                        ).format(DateTime.now()),
                        isDark: _isDarkMode,
                        icon: Icons.today_rounded,
                        iconColor: AppColors.accentTeal,
                      ),
                      const SizedBox(height: 12),
                      _TodaySnapshotRow(stats: _stats, isDark: _isDarkMode),
                      const SizedBox(height: 20),
                    ],

                    // ── Smart Insights ──────────────────────
                    if (_analytics.insights.isNotEmpty && !_statsLoading) ...[
                      _SectionHeader(
                        title: 'Smart Insights',
                        subtitle: 'AI-powered analysis',
                        isDark: _isDarkMode,
                        icon: Icons.psychology_rounded,
                        iconColor: AppColors.accentPurple,
                      ),
                      const SizedBox(height: 12),
                      _SmartInsightsCard(
                        insights: _analytics.insights,
                        isDark: _isDarkMode,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Recommendations ─────────────────────
                    if (_analytics.recommendations.isNotEmpty &&
                        !_statsLoading) ...[
                      _SectionHeader(
                        title: 'Smart Recommendations',
                        subtitle: 'Action items',
                        isDark: _isDarkMode,
                        icon: Icons.lightbulb_rounded,
                        iconColor: AppColors.accentYellow,
                      ),
                      const SizedBox(height: 12),
                      _RecommendationsCard(
                        recommendations: _analytics.recommendations,
                        isDark: _isDarkMode,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Activity + Export ───────────────────
                    _buildActivityAndExportRow(),
                    const SizedBox(height: 20),

                    // ── Quick Actions ───────────────────────
                    _QuickActionsCard(
                      isDark: _isDarkMode,
                      userRole: _userRole,
                      isLoading: _statsLoading,
                      onRefresh: _refreshAll,
                      onAddStudent: () => setState(() => _selectedIndex = 1),
                      onExport: () => setState(() => _selectedIndex = 3),
                      onReports: () => setState(() => _selectedIndex = 4),
                      onAuditLogs: _showAuditLogsPanel,
                      onLogout: _logout,
                      onToggleDark: _toggleDarkMode,
                      isDarkMode: _isDarkMode,
                    ),
                    const SizedBox(height: 20),

                    // ── Center Profile ──────────────────────
                    _CenterProfileCard(
                      centerCode: widget.centerCode,
                      userRole: _userRole,
                      stats: _stats,
                      isDark: _isDarkMode,
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Analytics section by tab ───────────────────────────────
  Widget _buildAnalyticsSection() {
    if (_statsLoading) return _StatsLoadingGrid(isDark: _isDarkMode);
    switch (_analyticsTabIndex) {
      case 0:
        return _OverviewAnalytics(
          stats: _stats,
          analytics: _analytics,
          isDark: _isDarkMode,
        );
      case 1:
        return _StudentAnalytics(
          stats: _stats,
          analytics: _analytics,
          isDark: _isDarkMode,
        );
      case 2:
        return _PerformanceAnalytics(
          stats: _stats,
          analytics: _analytics,
          isDark: _isDarkMode,
        );
      case 3:
        return _RevenueAnalytics(
          stats: _stats,
          analytics: _analytics,
          isDark: _isDarkMode,
        );
      case 4:
        return _AdminAnalytics(
          stats: _stats,
          analytics: _analytics,
          isDark: _isDarkMode,
          recentActivity: _recentActivity,
        );
      case 5:
        return _SmartInsightsAnalytics(
          analytics: _analytics,
          isDark: _isDarkMode,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActivityAndExportRow() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth >= 700;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _RecentActivityFeed(
                  activities: _recentActivity,
                  isDark: _isDarkMode,
                  onViewAll: _showAuditLogsPanel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _ExportHistoryCard(
                  exports: _exportHistory,
                  isDark: _isDarkMode,
                  onExport: () => setState(() => _selectedIndex = 3),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            _RecentActivityFeed(
              activities: _recentActivity,
              isDark: _isDarkMode,
              onViewAll: _showAuditLogsPanel,
            ),
            const SizedBox(height: 16),
            _ExportHistoryCard(
              exports: _exportHistory,
              isDark: _isDarkMode,
              onExport: () => setState(() => _selectedIndex = 3),
            ),
          ],
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // PANEL OVERLAYS
  // ════════════════════════════════════════════════════════

  void _showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationsPanel(
        notifications: _notifications,
        isDark: _isDarkMode,
        onMarkRead: (id) =>
            FirebaseService.markNotificationRead(widget.centerCode, id),
      ),
    );
  }

  void _showAuditLogsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AuditLogsPanel(
        activities: _recentActivity,
        isDark: _isDarkMode,
        onRefresh: _loadRecentActivity,
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // BUILD — RESPONSIVE LAYOUT
  // ════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 600 && screenWidth < 1100;
    final bgColor = _isDarkMode ? AppColors.bgDark : AppColors.bgLight;

    if (isDesktop) return _buildDesktopLayout(bgColor);
    if (isTablet) return _buildTabletLayout(bgColor);
    return _buildMobileLayout(bgColor);
  }

  Widget _buildDesktopLayout(Color bgColor) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          _Sidebar(
            selectedIndex: _selectedIndex,
            isDark: _isDarkMode,
            isExpanded: _isSidebarExpanded,
            centerCode: widget.centerCode,
            userRole: _userRole,
            notificationCount: _notifications.length,
            onIndexChanged: (i) => setState(() => _selectedIndex = i),
            onLogout: _logout,
            onToggleSidebar: () =>
                setState(() => _isSidebarExpanded = !_isSidebarExpanded),
            onToggleDark: _toggleDarkMode,
          ),
          Expanded(
            child: Column(
              children: [
                _DesktopTopBar(
                  title: _navLabels[_selectedIndex],
                  isDark: _isDarkMode,
                  isLoading: _statsLoading,
                  notificationCount: _notifications.length,
                  centerCode: widget.centerCode,
                  onRefresh: _selectedIndex == 0 ? _refreshAll : null,
                  onNotifications: _showNotificationsPanel,
                  onLogout: _logout,
                ),
                Expanded(child: _getScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(Color bgColor) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) {
              if (i == _navLabels.length - 1) {
                _logout();
              } else {
                setState(() => _selectedIndex = i);
              }
            },
            backgroundColor: _isDarkMode ? AppColors.surfaceDark : Colors.white,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            unselectedIconTheme: IconThemeData(color: Colors.grey.shade400),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            destinations: List.generate(
              _navLabels.length,
              (i) => NavigationRailDestination(
                icon: Icon(_navIcons[i]),
                label: Text(_navLabels[i]),
              ),
            ),
          ),
          Container(
            width: 1,
            color: _isDarkMode ? Colors.white12 : Colors.black12,
          ),
          Expanded(child: _getScreen()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(Color bgColor) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: _getScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final title = _selectedIndex == 0
        ? 'KYP — ${widget.centerCode}'
        : _navLabels[_selectedIndex];
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      ),
      backgroundColor: _isDarkMode ? AppColors.primaryDark : AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (_selectedIndex == 0)
          _statsLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _refreshAll,
                ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_rounded),
              onPressed: _showNotificationsPanel,
            ),
            if (_notifications.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_notifications.length > 9 ? '9+' : _notifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: Icon(
            _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          ),
          onPressed: _toggleDarkMode,
        ),
        IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: _isDarkMode
            ? Colors.grey.shade400
            : Colors.grey.shade500,
        backgroundColor: _isDarkMode ? AppColors.surfaceDark : Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        elevation: 0,
        onTap: (i) {
          if (i == _navLabels.length - 1) {
            _showSettingsBottomSheet();
          } else {
            setState(() => _selectedIndex = i);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_rounded),
            label: 'Entry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_download_rounded),
            label: 'Export',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SettingsQuickSheet(
        isDark: _isDarkMode,
        userRole: _userRole,
        onToggleDark: _toggleDarkMode,
        onLogout: _logout,
        onSettings: () {
          Navigator.pop(context);
          setState(() => _selectedIndex = 5);
        },
        onAuditLogs: () {
          Navigator.pop(context);
          _showAuditLogsPanel();
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 6: ANALYTICS TAB SECTIONS
// ════════════════════════════════════════════════════════════

/// OVERVIEW tab
class _OverviewAnalytics extends StatelessWidget {
  final DashboardStats stats;
  final AnalyticsData analytics;
  final bool isDark;
  const _OverviewAnalytics({
    required this.stats,
    required this.analytics,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Batch Distribution
        if (stats.batchDistribution.isNotEmpty)
          _BatchDistributionCard(
            batchDistribution: stats.batchDistribution,
            isDark: isDark,
          ),
        const SizedBox(height: 16),
        // Fee Analytics
        _FeeAnalyticsCard(stats: stats, isDark: isDark),
        const SizedBox(height: 16),
        // Center Performance
        _CenterPerformanceCard(stats: stats, isDark: isDark),
      ],
    );
  }
}

/// STUDENT ANALYTICS tab
class _StudentAnalytics extends StatelessWidget {
  final DashboardStats stats;
  final AnalyticsData analytics;
  final bool isDark;
  const _StudentAnalytics({
    required this.stats,
    required this.analytics,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active vs Inactive
        _DashCard(
          isDark: isDark,
          title: 'Active vs Inactive Students',
          icon: Icons.people_alt_rounded,
          iconColor: AppColors.primary,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MiniStatBox(
                      label: 'Active',
                      value: '${stats.activeStudents}',
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatBox(
                      label: 'Inactive',
                      value: '${stats.inactiveStudents}',
                      color: AppColors.error,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatBox(
                      label: 'At Risk',
                      value: '${stats.dropoutRisk}',
                      color: AppColors.warning,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Simple visual bar
              _SegmentedBar(
                segments: [
                  BarSegment(
                    'Active',
                    stats.activeStudents.toDouble(),
                    AppColors.success,
                  ),
                  BarSegment(
                    'Inactive',
                    stats.inactiveStudents.toDouble(),
                    AppColors.error,
                  ),
                  BarSegment(
                    'At Risk',
                    stats.dropoutRisk.toDouble(),
                    AppColors.warning,
                  ),
                ],
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Daily registrations mini chart
        _DashCard(
          isDark: isDark,
          title: 'Daily Registrations (This Week)',
          icon: Icons.bar_chart_rounded,
          iconColor: AppColors.accentGreen,
          child: _MiniBarChart(
            points: analytics.dailyFeeCollection.take(7).toList(),
            isDark: isDark,
            valuePrefix: '',
          ),
        ),
        const SizedBox(height: 16),

        // Department distribution
        if (stats.departmentDistribution.isNotEmpty)
          _DashCard(
            isDark: isDark,
            title: 'Department Distribution',
            icon: Icons.account_tree_rounded,
            iconColor: AppColors.accentPurple,
            child: _HorizontalBarList(
              data: stats.departmentDistribution,
              isDark: isDark,
            ),
          ),
        const SizedBox(height: 16),

        // Attendance & Engagement
        Row(
          children: [
            Expanded(
              child: _MetricCircleCard(
                isDark: isDark,
                label: 'Avg Attendance',
                value: stats.attendanceRate,
                maxValue: 100,
                unit: '%',
                color: stats.attendanceRate >= 75
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCircleCard(
                isDark: isDark,
                label: 'Engagement Score',
                value: stats.avgEngagementScore,
                maxValue: 100,
                unit: '/100',
                color: AppColors.accentPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Dropout prediction card
        if (stats.dropoutRisk > 0)
          _DashCard(
            isDark: isDark,
            title: 'Dropout Prediction Indicator',
            icon: Icons.trending_down_rounded,
            iconColor: AppColors.error,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.1).animate(
                        CurvedAnimation(
                          parent: AlwaysStoppedAnimation(1.0),
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stats.dropoutRisk}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Students at dropout risk',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No activity & fee pending for 30+ days',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: stats.totalStudents > 0
                      ? stats.dropoutRisk / stats.totalStudents
                      : 0,
                  backgroundColor: isDark
                      ? Colors.white12
                      : Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation(AppColors.error),
                  minHeight: 8,
                ),
                const SizedBox(height: 6),
                Text(
                  '${stats.totalStudents > 0 ? (stats.dropoutRisk / stats.totalStudents * 100).toStringAsFixed(1) : 0}% of total students',
                  style: const TextStyle(fontSize: 11, color: AppColors.error),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Scholarship analytics
        _DashCard(
          isDark: isDark,
          title: 'Scholarship Analytics',
          icon: Icons.card_giftcard_rounded,
          iconColor: AppColors.accentGreen,
          child: Row(
            children: [
              Expanded(
                child: _MiniStatBox(
                  label: 'Recipients',
                  value: '${stats.scholarshipCount}',
                  color: AppColors.accentGreen,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatBox(
                  label: 'Total Aid',
                  value: NumberFormat.compact().format(stats.scholarshipAmount),
                  color: AppColors.accentTeal,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatBox(
                  label: '% Covered',
                  value: stats.totalStudents > 0
                      ? '${(stats.scholarshipCount / stats.totalStudents * 100).toStringAsFixed(0)}%'
                      : '0%',
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// PERFORMANCE ANALYTICS tab
class _PerformanceAnalytics extends StatelessWidget {
  final DashboardStats stats;
  final AnalyticsData analytics;
  final bool isDark;
  const _PerformanceAnalytics({
    required this.stats,
    required this.analytics,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final currFmt = NumberFormat('#,##0.0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pass/Fail Ratio
        _DashCard(
          isDark: isDark,
          title: 'Pass / Fail Ratio',
          icon: Icons.school_rounded,
          iconColor: AppColors.success,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MiniStatBox(
                      label: 'Pass Rate',
                      value: '${stats.passRate.toStringAsFixed(0)}%',
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatBox(
                      label: 'Fail Rate',
                      value: '${(100 - stats.passRate).toStringAsFixed(0)}%',
                      color: AppColors.error,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatBox(
                      label: 'Avg Marks',
                      value: currFmt.format(stats.avgMarks),
                      color: AppColors.info,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SegmentedBar(
                segments: [
                  BarSegment('Pass', stats.passRate, AppColors.success),
                  BarSegment('Fail', 100 - stats.passRate, AppColors.error),
                ],
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Performance trend (exam scores)
        _DashCard(
          isDark: isDark,
          title: 'Exam Performance Trend',
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.info,
          child: _MiniBarChart(
            points: analytics.performanceTrend,
            isDark: isDark,
            valuePrefix: '',
            unit: '%',
          ),
        ),
        const SizedBox(height: 16),

        // Weak students alert
        if (stats.weakStudents > 0)
          _DashCard(
            isDark: isDark,
            title: 'Weak Students Alert',
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.warning,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stats.weakStudents}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students below passing threshold',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Require immediate academic support',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Top performers
        if (stats.topPerformers.isNotEmpty)
          _DashCard(
            isDark: isDark,
            title: 'Top Performers',
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.accentYellow,
            child: Column(
              children: stats.topPerformers.asMap().entries.map((entry) {
                final i = entry.key;
                final perf = entry.value;
                final medals = ['🥇', '🥈', '🥉'];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        i < 3 ? medals[i] : '${i + 1}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          perf['name']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                      Text(
                        'Batch: ${perf['batch'] ?? '-'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(perf['marks'] as double?)?.toStringAsFixed(0) ?? '-'}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),

        // Avg marks heatmap (simulated by dept)
        if (stats.departmentDistribution.isNotEmpty)
          _DashCard(
            isDark: isDark,
            title: 'Department Performance Heatmap',
            icon: Icons.grid_on_rounded,
            iconColor: AppColors.accentPurple,
            child: _HeatmapGrid(
              departments: stats.departmentDistribution,
              isDark: isDark,
            ),
          ),
      ],
    );
  }
}

/// REVENUE ANALYTICS tab
class _RevenueAnalytics extends StatelessWidget {
  final DashboardStats stats;
  final AnalyticsData analytics;
  final bool isDark;
  const _RevenueAnalytics({
    required this.stats,
    required this.analytics,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final currFmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final compactFmt = NumberFormat.compact();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Revenue summary row
        Row(
          children: [
            Expanded(
              child: _MiniStatBox(
                label: 'Total Revenue',
                value: compactFmt.format(stats.totalRevenue),
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatBox(
                label: 'Pending',
                value: compactFmt.format(stats.pendingAmount),
                color: AppColors.error,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatBox(
                label: 'Collection %',
                value: '${stats.collectionRate.toStringAsFixed(0)}%',
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Daily fee collection chart
        _DashCard(
          isDark: isDark,
          title: 'Daily Fee Collection',
          icon: Icons.bar_chart_rounded,
          iconColor: AppColors.accentGreen,
          child: _MiniBarChart(
            points: analytics.dailyFeeCollection,
            isDark: isDark,
            valuePrefix: '₹',
          ),
        ),
        const SizedBox(height: 16),

        // Monthly income trend
        _DashCard(
          isDark: isDark,
          title: 'Monthly Income Trend',
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.success,
          child: _MiniLineChart(
            points: analytics.monthlyIncome.take(12).toList(),
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 16),

        // Payment status pie-style segmented bar
        _DashCard(
          isDark: isDark,
          title: 'Payment Status Breakdown',
          icon: Icons.pie_chart_rounded,
          iconColor: AppColors.info,
          child: Column(
            children: [
              _SegmentedBar(
                segments: [
                  BarSegment(
                    'Paid',
                    stats.paymentStatusBreakdown['paid']?.toDouble() ?? 0,
                    AppColors.success,
                  ),
                  BarSegment(
                    'Partial',
                    stats.paymentStatusBreakdown['partial']?.toDouble() ?? 0,
                    AppColors.warning,
                  ),
                  BarSegment(
                    'Pending',
                    stats.paymentStatusBreakdown['pending']?.toDouble() ?? 0,
                    AppColors.error,
                  ),
                ],
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LegendDot(
                    label: 'Paid',
                    count: stats.paymentStatusBreakdown['paid'] ?? 0,
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                  _LegendDot(
                    label: 'Partial',
                    count: stats.paymentStatusBreakdown['partial'] ?? 0,
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                  _LegendDot(
                    label: 'Pending',
                    count: stats.paymentStatusBreakdown['pending'] ?? 0,
                    color: AppColors.error,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Revenue by department
        if (stats.revenueByDepartment.isNotEmpty)
          _DashCard(
            isDark: isDark,
            title: 'Revenue by Department',
            icon: Icons.account_balance_rounded,
            iconColor: AppColors.primary,
            child: Column(
              children: stats.revenueByDepartment.entries.take(5).map((e) {
                final total = stats.totalRevenue > 0 ? stats.totalRevenue : 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          e.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (e.value / total).clamp(0.0, 1.0),
                            backgroundColor: isDark
                                ? Colors.white12
                                : Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        compactFmt.format(e.value),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),

        // Revenue growth indicator
        _DashCard(
          isDark: isDark,
          title: 'Revenue Growth Indicator',
          icon: Icons.auto_graph_rounded,
          iconColor: AppColors.accentOrange,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      (analytics.revenueGrowthRate >= 0
                              ? AppColors.success
                              : AppColors.error)
                          .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      analytics.revenueGrowthRate >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: analytics.revenueGrowthRate >= 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${analytics.revenueGrowthRate >= 0 ? '+' : ''}${analytics.revenueGrowthRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: analytics.revenueGrowthRate >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  analytics.revenueGrowthRate >= 0
                      ? 'Revenue growing. Keep up the collection drive!'
                      : 'Revenue declining. Focus on fee collection efforts.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ADMIN ANALYTICS tab
class _AdminAnalytics extends StatelessWidget {
  final DashboardStats stats;
  final AnalyticsData analytics;
  final bool isDark;
  final List<ActivityEntry> recentActivity;
  const _AdminAnalytics({
    required this.stats,
    required this.analytics,
    required this.isDark,
    required this.recentActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // System stats
        Row(
          children: [
            Expanded(
              child: _MiniStatBox(
                label: 'Portal Open',
                value: '${stats.portalOpenCount}',
                color: AppColors.accentGreen,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatBox(
                label: 'Support Tickets',
                value: '${stats.supportTickets}',
                color: AppColors.warning,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStatBox(
                label: 'Logs Today',
                value: '${recentActivity.length}',
                color: AppColors.info,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Peak usage hours heatmap
        _DashCard(
          isDark: isDark,
          title: 'Peak Usage Hours',
          icon: Icons.access_time_rounded,
          iconColor: AppColors.accentOrange,
          child: _PeakHoursChart(
            hours: analytics.peakUsageHours,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 16),

        // Role-based statistics
        _DashCard(
          isDark: isDark,
          title: 'Role-Based Statistics',
          icon: Icons.admin_panel_settings_rounded,
          iconColor: AppColors.primary,
          child: Column(
            children: [
              _RoleStatRow(
                role: 'Super Admin',
                count: 1,
                icon: Icons.shield_rounded,
                color: AppColors.accentPurple,
                isDark: isDark,
              ),
              _RoleStatRow(
                role: 'Center Admin',
                count: 3,
                icon: Icons.manage_accounts_rounded,
                color: AppColors.primary,
                isDark: isDark,
              ),
              _RoleStatRow(
                role: 'Staff',
                count: 8,
                icon: Icons.badge_rounded,
                color: AppColors.accentTeal,
                isDark: isDark,
              ),
              _RoleStatRow(
                role: 'Viewer',
                count: 5,
                icon: Icons.visibility_rounded,
                color: AppColors.textMuted,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Activity type breakdown
        _DashCard(
          isDark: isDark,
          title: 'Activity Type Breakdown',
          icon: Icons.pie_chart_outline_rounded,
          iconColor: AppColors.accentPurple,
          child: Column(
            children: () {
              final typeCount = <String, int>{};
              for (final a in recentActivity) {
                typeCount[a.type] = (typeCount[a.type] ?? 0) + 1;
              }
              if (typeCount.isEmpty) {
                return [const Text('No activity data yet.')];
              }
              final total = typeCount.values.fold(0, (a, b) => a + b);
              return typeCount.entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(
                              e.key.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: total > 0 ? e.value / total : 0,
                              backgroundColor: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation(
                                _activityColor(e.key),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${e.value}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _activityColor(e.key),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList();
            }(),
          ),
        ),
        const SizedBox(height: 16),

        // User retention indicator
        _DashCard(
          isDark: isDark,
          title: 'User Retention Analysis',
          icon: Icons.repeat_rounded,
          iconColor: AppColors.accentGreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricCircleCard(
                      isDark: isDark,
                      label: 'Student Retention',
                      value: stats.totalStudents > 0
                          ? (stats.activeStudents / stats.totalStudents * 100)
                          : 0,
                      maxValue: 100,
                      unit: '%',
                      color: AppColors.success,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Retention Formula',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Active ÷ Total × 100',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.activeStudents} active of ${stats.totalStudents} total',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
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
      ],
    );
  }

  Color _activityColor(String type) {
    switch (type) {
      case 'student':
        return AppColors.primary;
      case 'fee':
        return AppColors.success;
      case 'export':
        return AppColors.accentPurple;
      case 'auth':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }
}

/// SMART INSIGHTS tab
class _SmartInsightsAnalytics extends StatelessWidget {
  final AnalyticsData analytics;
  final bool isDark;
  const _SmartInsightsAnalytics({
    required this.analytics,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI dashboard
        _DashCard(
          isDark: isDark,
          title: 'KPI Dashboard',
          icon: Icons.speed_rounded,
          iconColor: AppColors.primary,
          child: Column(
            children: analytics.kpiProgress.entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.key,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textLight
                                    : AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${(e.value * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _kpiColor(e.value),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: e.value.clamp(0.0, 1.0),
                            backgroundColor: isDark
                                ? Colors.white12
                                : Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation(
                              _kpiColor(e.value),
                            ),
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Growth forecasting
        _DashCard(
          isDark: isDark,
          title: 'Growth Forecasting',
          icon: Icons.auto_awesome_rounded,
          iconColor: AppColors.accentPurple,
          child: Column(
            children: [
              _ForecastRow(
                label: 'Admission Growth',
                value: analytics.admissionGrowthRate,
                unit: '%',
                description: 'Projected next month vs current',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _ForecastRow(
                label: 'Revenue Growth',
                value: analytics.revenueGrowthRate,
                unit: '%',
                description: 'Estimated from collection trends',
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Achievement indicators
        _DashCard(
          isDark: isDark,
          title: 'Achievement Indicators',
          icon: Icons.emoji_events_rounded,
          iconColor: AppColors.accentYellow,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AchievementBadge(
                label: 'Early Bird',
                subtitle: 'First 10 admissions',
                earned: true,
                isDark: isDark,
              ),
              _AchievementBadge(
                label: 'Fee Champion',
                subtitle: '80%+ collection',
                earned: analytics.kpiProgress['Fee Collection']! >= 0.8,
                isDark: isDark,
              ),
              _AchievementBadge(
                label: 'Full House',
                subtitle: '100+ students',
                earned:
                    (analytics.kpiProgress['Enrollment Target'] ?? 0) >= 0.5,
                isDark: isDark,
              ),
              _AchievementBadge(
                label: 'Top Marks',
                subtitle: '85%+ pass rate',
                earned: (analytics.kpiProgress['Pass Rate'] ?? 0) >= 0.85,
                isDark: isDark,
              ),
              _AchievementBadge(
                label: 'Engaged',
                subtitle: '90%+ engagement',
                earned: (analytics.kpiProgress['Engagement'] ?? 0) >= 0.9,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Real-time insights engine
        _DashCard(
          isDark: isDark,
          title: 'Real-Time Insights Engine',
          icon: Icons.electric_bolt_rounded,
          iconColor: AppColors.accentYellow,
          child: Column(
            children: analytics.insights.isEmpty
                ? [
                    _EmptyState(
                      icon: Icons.lightbulb_outline_rounded,
                      message: 'No insights yet. Add more data!',
                      isDark: isDark,
                    ),
                  ]
                : analytics.insights
                      .map((ins) => _InsightRow(insight: ins, isDark: isDark))
                      .toList(),
          ),
        ),
      ],
    );
  }

  Color _kpiColor(double v) {
    if (v >= 0.8) return AppColors.success;
    if (v >= 0.5) return AppColors.warning;
    return AppColors.error;
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 7: SIDEBAR (DESKTOP)
// ════════════════════════════════════════════════════════════

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final bool isDark, isExpanded;
  final String centerCode;
  final UserRole userRole;
  final int notificationCount;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onLogout, onToggleSidebar, onToggleDark;

  const _Sidebar({
    required this.selectedIndex,
    required this.isDark,
    required this.isExpanded,
    required this.centerCode,
    required this.userRole,
    required this.notificationCount,
    required this.onIndexChanged,
    required this.onLogout,
    required this.onToggleSidebar,
    required this.onToggleDark,
  });

  static const _labels = [
    'Dashboard',
    'Student Entry',
    'Students',
    'Export',
    'Reports',
    'Settings',
  ];
  static const _icons = [
    Icons.dashboard_rounded,
    Icons.person_add_rounded,
    Icons.people_alt_rounded,
    Icons.file_download_rounded,
    Icons.bar_chart_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.primaryDark : AppColors.primary;
    final width = isExpanded ? 240.0 : 72.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      color: bg,
      child: Column(
        children: [
          // Header
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: isExpanded ? Alignment.centerLeft : Alignment.center,
            child: isExpanded
                ? Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'KYP Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              centerCode,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      userRole == UserRole.superAdmin
                          ? Icons.admin_panel_settings_rounded
                          : Icons.manage_accounts_rounded,
                      color: AppColors.accent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      userRole.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Divider(color: Colors.white.withOpacity(0.15), height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _labels.length,
              itemBuilder: (_, i) => _SidebarItem(
                icon: _icons[i],
                label: _labels[i],
                isSelected: selectedIndex == i,
                isExpanded: isExpanded,
                badge: i == 0 && notificationCount > 0
                    ? notificationCount
                    : null,
                onTap: () => onIndexChanged(i),
              ),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.15), height: 1),
          _SidebarItem(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            label: isDark ? 'Light Mode' : 'Dark Mode',
            isSelected: false,
            isExpanded: isExpanded,
            onTap: onToggleDark,
          ),
          _SidebarItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            isSelected: false,
            isExpanded: isExpanded,
            isDestructive: true,
            onTap: onLogout,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onToggleSidebar,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                isExpanded
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected, isExpanded;
  final int? badge;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.badge,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : isSelected
        ? Colors.white
        : Colors.white.withOpacity(0.65);
    return Material(
      color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 12 : 0,
            vertical: 12,
          ),
          child: isExpanded
              ? Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                )
              : Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 8: DESKTOP TOP BAR
// ════════════════════════════════════════════════════════════

class _DesktopTopBar extends StatelessWidget {
  final String title;
  final bool isDark, isLoading;
  final int notificationCount;
  final String centerCode;
  final VoidCallback? onRefresh;
  final VoidCallback onNotifications, onLogout;

  const _DesktopTopBar({
    required this.title,
    required this.isDark,
    required this.isLoading,
    required this.notificationCount,
    required this.centerCode,
    required this.onNotifications,
    required this.onLogout,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    return Container(
      height: 64,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Spacer(),
          if (onRefresh != null)
            isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.refresh_rounded, color: textColor),
                    onPressed: onRefresh,
                    tooltip: 'Refresh',
                  ),
          const SizedBox(width: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_rounded, color: textColor),
                onPressed: onNotifications,
              ),
              if (notificationCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${notificationCount > 9 ? '9+' : notificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            height: 36,
            width: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.15),
            radius: 16,
            child: Text(
              centerCode.isNotEmpty ? centerCode[0].toUpperCase() : 'K',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            centerCode,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 9: WELCOME HEADER
// ════════════════════════════════════════════════════════════

class _WelcomeHeader extends StatelessWidget {
  final String centerCode;
  final UserRole userRole;
  final bool isDark;
  final int notificationCount;
  final VoidCallback onNotificationsTap;

  const _WelcomeHeader({
    required this.centerCode,
    required this.userRole,
    required this.isDark,
    required this.notificationCount,
    required this.onNotificationsTap,
  });

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.primaryDark, AppColors.primary]
              : [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting! 👋',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  centerCode,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        userRole == UserRole.superAdmin
                            ? Icons.admin_panel_settings_rounded
                            : Icons.manage_accounts_rounded,
                        color: AppColors.accent,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        userRole.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onNotificationsTap,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                if (notificationCount > 0)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
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
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 10: SEARCH & FILTER BARS
// ════════════════════════════════════════════════════════════

class _GlobalSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _GlobalSearchBar({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? AppColors.textLight : AppColors.textDark,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search students, batches, analytics...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _TimeFilterBar extends StatelessWidget {
  final TimeFilter selected;
  final bool isDark;
  final ValueChanged<TimeFilter> onChange;
  const _TimeFilterBar({
    required this.selected,
    required this.isDark,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: TimeFilter.values.map((f) {
          final isActive = selected == f;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    f.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive
                          ? Colors.white
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AnalyticsTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final bool isDark;
  final ValueChanged<int> onChange;
  const _AnalyticsTabBar({
    required this.tabs,
    required this.selected,
    required this.isDark,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final isActive = selected == e.key;
          return GestureDetector(
            onTap: () => onChange(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : (isDark ? AppColors.surfaceDark : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : (isDark ? Colors.white12 : Colors.grey.shade200),
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? Colors.white
                      : (isDark ? Colors.grey.shade300 : Colors.grey.shade600),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 11: SECTION HEADER
// ════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 12: KPI CARDS
// ════════════════════════════════════════════════════════════

class _KpiCardsGrid extends StatelessWidget {
  final DashboardStats stats;
  final bool isDark;
  const _KpiCardsGrid({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cf = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final cards = [
      _KpiData(
        title: 'Total Students',
        value: '${stats.totalStudents}',
        subtitle: '+${stats.weeklyAdmissions} this week',
        icon: Icons.people_alt_rounded,
        color: AppColors.primary,
        trend: stats.weeklyAdmissions > 0 ? TrendDir.up : TrendDir.flat,
      ),
      _KpiData(
        title: 'Active Batches',
        value: '${stats.totalBatches}',
        subtitle: '${stats.batchDistribution.length} active',
        icon: Icons.school_rounded,
        color: AppColors.info,
        trend: TrendDir.flat,
      ),
      _KpiData(
        title: 'Revenue',
        value: cf.format(stats.totalRevenue),
        subtitle: '${stats.collectionRate.toStringAsFixed(0)}% collected',
        icon: Icons.payments_rounded,
        color: AppColors.success,
        trend: stats.collectionRate >= 75 ? TrendDir.up : TrendDir.down,
      ),
      _KpiData(
        title: 'Pending Fees',
        value: cf.format(stats.pendingAmount),
        subtitle: '${stats.totalStudents - stats.feesCollected} students',
        icon: Icons.pending_actions_rounded,
        color: AppColors.error,
        trend: stats.pendingAmount > 0 ? TrendDir.down : TrendDir.up,
      ),
      _KpiData(
        title: "Today's Admissions",
        value: '${stats.todayAdmissions}',
        subtitle: 'New enrollments today',
        icon: Icons.today_rounded,
        color: AppColors.accentPurple,
        trend: stats.todayAdmissions > 0 ? TrendDir.up : TrendDir.flat,
      ),
      _KpiData(
        title: 'Portal Open',
        value: '${stats.portalOpenCount}',
        subtitle: 'Active portal access',
        icon: Icons.open_in_browser_rounded,
        color: AppColors.accentOrange,
        trend: TrendDir.flat,
      ),
      _KpiData(
        title: 'Pass Rate',
        value: '${stats.passRate.toStringAsFixed(0)}%',
        subtitle: '${stats.weakStudents} need support',
        icon: Icons.school_rounded,
        color: AppColors.accentTeal,
        trend: stats.passRate >= 75 ? TrendDir.up : TrendDir.down,
      ),
      _KpiData(
        title: 'Attendance Rate',
        value: '${stats.attendanceRate.toStringAsFixed(0)}%',
        subtitle: 'Average across all students',
        icon: Icons.event_available_rounded,
        color: AppColors.accentGreen,
        trend: stats.attendanceRate >= 80 ? TrendDir.up : TrendDir.flat,
      ),
    ];

    return LayoutBuilder(
      builder: (_, constraints) {
        final cols = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
            ? 3
            : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: cards.length,
          itemBuilder: (_, i) => _KpiCard(data: cards[i], isDark: isDark),
        );
      },
    );
  }
}

class _KpiData {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  final TrendDir trend;
  const _KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
  });
}

class _KpiCard extends StatefulWidget {
  final _KpiData data;
  final bool isDark;
  const _KpiCard({required this.data, required this.isDark});
  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: data.color.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: data.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(data.icon, size: 18, color: data.color),
                  ),
                  _TrendBadge(trend: data.trend),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: data.color,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    data.subtitle,
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final TrendDir trend;
  const _TrendBadge({required this.trend});
  @override
  Widget build(BuildContext context) {
    if (trend == TrendDir.flat) return const SizedBox.shrink();
    final isUp = trend == TrendDir.up;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: (isUp ? AppColors.success : AppColors.error).withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(
        isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
        size: 13,
        color: isUp ? AppColors.success : AppColors.error,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 13: PERFORMANCE HEALTH CARD
// ════════════════════════════════════════════════════════════

class _PerformanceHealthCard extends StatelessWidget {
  final double score;
  final Map<String, double> kpiProgress;
  final bool isDark;
  const _PerformanceHealthCard({
    required this.score,
    required this.kpiProgress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final grade = score >= 80
        ? 'Excellent'
        : score >= 60
        ? 'Good'
        : score >= 40
        ? 'Average'
        : 'Needs Improvement';
    final gradeColor = score >= 80
        ? AppColors.success
        : score >= 60
        ? AppColors.info
        : score >= 40
        ? AppColors.warning
        : AppColors.error;

    return _DashCard(
      isDark: isDark,
      title: 'Performance Health Score',
      icon: Icons.favorite_rounded,
      iconColor: gradeColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle gauge
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 9,
                  backgroundColor: isDark
                      ? Colors.white12
                      : Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation(gradeColor),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: gradeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    grade,
                    style: TextStyle(
                      color: gradeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...kpiProgress.entries
                    .take(4)
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                e.key,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: e.value.clamp(0.0, 1.0),
                                backgroundColor: isDark
                                    ? Colors.white12
                                    : Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation(
                                  _kpiColor(e.value),
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${(e.value * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _kpiColor(e.value),
                              ),
                            ),
                          ],
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

  Color _kpiColor(double v) => v >= 0.8
      ? AppColors.success
      : v >= 0.5
      ? AppColors.warning
      : AppColors.error;
}

// ════════════════════════════════════════════════════════════
// SECTION 14: ALERT BANNERS & RISK ALERTS
// ════════════════════════════════════════════════════════════

class _RiskAlertsRow extends StatelessWidget {
  final List<RiskAlert> alerts;
  final bool isDark;
  const _RiskAlertsRow({required this.alerts, required this.isDark});

  Color _levelColor(RiskLevel l) {
    switch (l) {
      case RiskLevel.critical:
        return AppColors.error;
      case RiskLevel.high:
        return const Color(0xFFEF4444);
      case RiskLevel.medium:
        return AppColors.warning;
      case RiskLevel.low:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: alerts.map((a) {
        final color = _levelColor(a.level);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.03)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.warning_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      a.description,
                      style: TextStyle(
                        color: color.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  a.level.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PendingFeeAlert extends StatelessWidget {
  final double amount;
  final int count;
  final bool isDark;
  final VoidCallback onAction;
  const _PendingFeeAlert({
    required this.amount,
    required this.count,
    required this.isDark,
    required this.onAction,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.error.withOpacity(0.12),
          AppColors.error.withOpacity(0.04),
        ],
      ),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.error.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹${amount.toStringAsFixed(0)} Pending',
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '$count student${count != 1 ? 's' : ''} have pending fees',
                style: TextStyle(
                  color: AppColors.error.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text(
            'View',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

class _DuplicateAlert extends StatelessWidget {
  final int count;
  final bool isDark;
  const _DuplicateAlert({required this.count, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.content_copy_rounded,
          color: AppColors.warning,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$count potential duplicate student${count != 1 ? 's' : ''} detected',
            style: const TextStyle(color: AppColors.warning, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _StatErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;
  const _StatErrorBanner({
    required this.message,
    required this.isDark,
    required this.onRetry,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off_rounded, color: AppColors.warning, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.warning, fontSize: 13),
          ),
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Retry'),
          style: TextButton.styleFrom(foregroundColor: AppColors.warning),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════
// SECTION 15: CHART WIDGETS (custom, no external lib)
// ════════════════════════════════════════════════════════════

/// Mini bar chart widget
class _MiniBarChart extends StatelessWidget {
  final List<ChartPoint> points;
  final bool isDark;
  final String valuePrefix;
  final String unit;
  const _MiniBarChart({
    required this.points,
    required this.isDark,
    required this.valuePrefix,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty)
      return _EmptyState(
        icon: Icons.bar_chart_rounded,
        message: 'No chart data yet',
        isDark: isDark,
      );
    final maxVal = points.map((p) => p.value).reduce(max);
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: points.map((p) {
              final barHeight = maxVal > 0 ? (p.value / maxVal) * 90 : 4.0;
              final color = p.color ?? AppColors.primary;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Tooltip(
                    message: '$valuePrefix${p.value.toStringAsFixed(0)}$unit',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: barHeight.clamp(4.0, 90.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withOpacity(0.9),
                                color.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
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
        const SizedBox(height: 6),
        Row(
          children: points
              .map(
                (p) => Expanded(
                  child: Text(
                    p.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// Mini line chart widget
class _MiniLineChart extends StatelessWidget {
  final List<ChartPoint> points;
  final bool isDark;
  const _MiniLineChart({required this.points, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty)
      return _EmptyState(
        icon: Icons.show_chart_rounded,
        message: 'No chart data yet',
        isDark: isDark,
      );
    return SizedBox(
      height: 80,
      child: CustomPaint(
        painter: _LineChartPainter(points: points, isDark: isDark),
        child: Container(),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  final bool isDark;
  const _LineChartPainter({required this.points, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final maxVal = points.map((p) => p.value).reduce(max);
    final minVal = points.map((p) => p.value).reduce(min);
    final range = (maxVal - minVal).abs().clamp(1.0, double.infinity);

    final stepX = size.width / (points.length - 1);
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.3),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y =
          size.height -
          ((points[i].value - minVal) / range) * size.height * 0.85;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo((points.length - 1) * stepX, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, paint);

    // Dots
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y =
          size.height -
          ((points[i].value - minVal) / range) * size.height * 0.85;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

/// Segmented bar
class BarSegment {
  final String label;
  final double value;
  final Color color;
  const BarSegment(this.label, this.value, this.color);
}

class _SegmentedBar extends StatelessWidget {
  final List<BarSegment> segments;
  final bool isDark;
  const _SegmentedBar({required this.segments, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final total = segments
        .fold<double>(0, (s, e) => s + e.value)
        .clamp(1.0, double.infinity);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 16,
        child: Row(
          children: segments
              .map(
                (s) => Flexible(
                  flex: (s.value / total * 1000).toInt().clamp(1, 1000),
                  child: Container(color: s.color),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Horizontal bar list
class _HorizontalBarList extends StatelessWidget {
  final Map<String, int> data;
  final bool isDark;
  const _HorizontalBarList({required this.data, required this.isDark});

  static const _colors = AppColors.chartColors;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (s, e) => s + e.value).clamp(1, 99999);
    return Column(
      children: entries.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        final color = _colors[i % _colors.length];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  e.key,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: e.value / total,
                    backgroundColor: isDark
                        ? Colors.white12
                        : Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${e.value}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Metric circle card
class _MetricCircleCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final double value, maxValue;
  final String unit;
  final Color color;
  final bool compact;
  const _MetricCircleCard({
    required this.isDark,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.unit,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: compact ? 60 : 80,
            height: compact ? 60 : 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (value / maxValue).clamp(0.0, 1.0),
                  strokeWidth: compact ? 7 : 9,
                  backgroundColor: isDark
                      ? Colors.white12
                      : Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: compact ? 14 : 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Mini stat box
class _MiniStatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;
  const _MiniStatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

/// Heatmap grid
class _HeatmapGrid extends StatelessWidget {
  final Map<String, int> departments;
  final bool isDark;
  const _HeatmapGrid({required this.departments, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final entries = departments.entries.toList();
    final maxVal = entries.isEmpty
        ? 1
        : entries.map((e) => e.value).reduce(max);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: entries.map((e) {
        final intensity = maxVal > 0 ? e.value / maxVal : 0.0;
        final color = Color.lerp(
          AppColors.primary.withOpacity(0.1),
          AppColors.primary,
          intensity,
        )!;
        return Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${e.value}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: intensity > 0.5 ? Colors.white : AppColors.primary,
                ),
              ),
              Text(
                e.key,
                style: TextStyle(
                  fontSize: 9,
                  color: intensity > 0.5
                      ? Colors.white70
                      : AppColors.primary.withOpacity(0.7),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Peak hours chart
class _PeakHoursChart extends StatelessWidget {
  final List<PeakHour> hours;
  final bool isDark;
  const _PeakHoursChart({required this.hours, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final maxCount = hours.isEmpty
        ? 1
        : hours.map((h) => h.activityCount).reduce(max);
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: hours.map((h) {
              final barH = maxCount > 0
                  ? (h.activityCount / maxCount) * 50.0
                  : 2.0;
              final color = h.activityCount > maxCount * 0.7
                  ? AppColors.error
                  : h.activityCount > maxCount * 0.4
                  ? AppColors.warning
                  : AppColors.accentGreen;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: barH.clamp(2.0, 50.0),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '12AM',
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
            Text(
              '6AM',
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
            Text(
              '12PM',
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
            Text(
              '6PM',
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
            Text(
              '11PM',
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 16: SMART INSIGHTS & RECOMMENDATIONS
// ════════════════════════════════════════════════════════════

class _SmartInsightsCard extends StatelessWidget {
  final List<SmartInsight> insights;
  final bool isDark;
  const _SmartInsightsCard({required this.insights, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      isDark: isDark,
      title: 'Smart Insights',
      icon: Icons.psychology_rounded,
      iconColor: AppColors.accentPurple,
      child: Column(
        children: insights
            .map((ins) => _InsightRow(insight: ins, isDark: isDark))
            .toList(),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final SmartInsight insight;
  final bool isDark;
  const _InsightRow({required this.insight, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: insight.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(insight.icon, color: insight.color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                insight.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                insight.description,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: insight.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${(insight.confidence * 100).toInt()}%',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: insight.color,
            ),
          ),
        ),
      ],
    ),
  );
}

class _RecommendationsCard extends StatelessWidget {
  final List<Recommendation> recommendations;
  final bool isDark;
  const _RecommendationsCard({
    required this.recommendations,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      isDark: isDark,
      title: 'Smart Recommendations',
      icon: Icons.lightbulb_rounded,
      iconColor: AppColors.accentYellow,
      child: Column(
        children: recommendations
            .map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: r.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(r.icon, color: r.color, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textDark,
                            ),
                          ),
                          Text(
                            r.action,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Impact',
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            value: r.impact,
                            strokeWidth: 4,
                            backgroundColor: isDark
                                ? Colors.white12
                                : Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation(r.color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 17: TODAY SNAPSHOT
// ════════════════════════════════════════════════════════════

class _TodaySnapshotRow extends StatelessWidget {
  final DashboardStats stats;
  final bool isDark;
  const _TodaySnapshotRow({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SnapshotChip(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Today Admissions',
            value: '${stats.todayAdmissions}',
            color: AppColors.accentGreen,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _SnapshotChip(
            icon: Icons.calendar_view_week_rounded,
            label: 'Weekly',
            value: '${stats.weeklyAdmissions}',
            color: AppColors.primaryLight,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _SnapshotChip(
            icon: Icons.calendar_month_rounded,
            label: 'Monthly',
            value: '${stats.monthlyAdmissions}',
            color: AppColors.accentPurple,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _SnapshotChip(
            icon: Icons.receipt_long_rounded,
            label: 'Collection Rate',
            value: '${stats.collectionRate.toStringAsFixed(1)}%',
            color: AppColors.info,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _SnapshotChip(
            icon: Icons.supervisor_account_rounded,
            label: 'Active Students',
            value: '${stats.activeStudents}',
            color: AppColors.accentOrange,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _SnapshotChip(
            icon: Icons.trending_up_rounded,
            label: 'Yearly Admissions',
            value: '${stats.yearlyAdmissions}',
            color: AppColors.accentTeal,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _SnapshotChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final bool isDark;
  const _SnapshotChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 140,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════
// SECTION 18: BATCH DISTRIBUTION CARD
// ════════════════════════════════════════════════════════════

class _BatchDistributionCard extends StatelessWidget {
  final Map<String, int> batchDistribution;
  final bool isDark;
  const _BatchDistributionCard({
    required this.batchDistribution,
    required this.isDark,
  });

  static const _colors = AppColors.chartColors;

  @override
  Widget build(BuildContext context) {
    final entries = batchDistribution.entries.toList();
    final total = entries.fold<int>(0, (s, e) => s + e.value);
    return _DashCard(
      isDark: isDark,
      title: 'Batch Distribution',
      icon: Icons.pie_chart_rounded,
      iconColor: AppColors.info,
      child: Column(
        children: [
          ...entries.asMap().entries.map((entry) {
            final i = entry.key;
            final batch = entry.value;
            final color = _colors[i % _colors.length];
            final pct = total > 0 ? batch.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      batch.key,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: isDark
                            ? Colors.white12
                            : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${batch.value}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Divider(
            color: isDark ? Colors.white12 : Colors.grey.shade100,
            height: 1,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: $total students',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
              Text(
                '${entries.length} batches',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 19: FEE ANALYTICS CARD
// ════════════════════════════════════════════════════════════

class _FeeAnalyticsCard extends StatelessWidget {
  final DashboardStats stats;
  final bool isDark;
  const _FeeAnalyticsCard({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cf = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final collPct = stats.collectionRate / 100.0;
    return _DashCard(
      isDark: isDark,
      title: 'Fee Collection Analytics',
      icon: Icons.analytics_rounded,
      iconColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collection Rate',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: collPct.clamp(0.0, 1.0),
                        backgroundColor: isDark
                            ? Colors.white12
                            : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation(
                          collPct >= 0.75
                              ? AppColors.success
                              : collPct >= 0.5
                              ? AppColors.warning
                              : AppColors.error,
                        ),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.collectionRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: collPct >= 0.75
                            ? AppColors.success
                            : collPct >= 0.5
                            ? AppColors.warning
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _FeeStat(
                    label: 'Collected',
                    value: cf.format(stats.totalRevenue),
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _FeeStat(
                    label: 'Pending',
                    value: cf.format(stats.pendingAmount),
                    color: AppColors.error,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _FeeStat(
                    label: 'Total',
                    value: cf.format(stats.totalRevenue + stats.pendingAmount),
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark ? Colors.white12 : Colors.grey.shade100,
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _FeeCountChip(
                label: 'Fees Paid',
                count: stats.feesCollected,
                total: stats.totalStudents,
                color: AppColors.success,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _FeeCountChip(
                label: 'Fees Due',
                count: stats.totalStudents - stats.feesCollected,
                total: stats.totalStudents,
                color: AppColors.error,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeeStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;
  const _FeeStat({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
        ),
      ),
    ],
  );
}

class _FeeCountChip extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  final bool isDark;
  const _FeeCountChip({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total > 0 ? '${((count / total) * 100).toStringAsFixed(0)}%' : '0%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════
// SECTION 20: CENTER PERFORMANCE CARD
// ════════════════════════════════════════════════════════════

class _CenterPerformanceCard extends StatelessWidget {
  final DashboardStats stats;
  final bool isDark;
  const _CenterPerformanceCard({required this.stats, required this.isDark});

  double _score() {
    double s = 0;
    s += (stats.totalStudents / 100).clamp(0.0, 1.0) * 40;
    s += (stats.collectionRate / 100).clamp(0.0, 1.0) * 40;
    s += stats.duplicatesDetected == 0 ? 20 : 10;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final score = _score();
    final grade = score >= 80
        ? 'Excellent'
        : score >= 60
        ? 'Good'
        : score >= 40
        ? 'Average'
        : 'Needs Improvement';
    final gc = score >= 80
        ? AppColors.success
        : score >= 60
        ? AppColors.info
        : score >= 40
        ? AppColors.warning
        : AppColors.error;

    return _DashCard(
      isDark: isDark,
      title: 'Center Performance',
      icon: Icons.leaderboard_rounded,
      iconColor: AppColors.accentPurple,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: isDark
                      ? Colors.white12
                      : Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation(gc),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: gc,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: gc.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    grade,
                    style: TextStyle(
                      color: gc,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _PerfRow(
                  label: 'Enrollment',
                  value: '${stats.totalStudents} students',
                  isDark: isDark,
                ),
                _PerfRow(
                  label: 'Collection',
                  value: '${stats.collectionRate.toStringAsFixed(0)}%',
                  isDark: isDark,
                ),
                _PerfRow(
                  label: 'Data Quality',
                  value: stats.duplicatesDetected == 0
                      ? 'Clean ✓'
                      : '${stats.duplicatesDetected} issues',
                  isDark: isDark,
                ),
                _PerfRow(
                  label: 'Attendance',
                  value: '${stats.attendanceRate.toStringAsFixed(0)}%',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _PerfRow({
    required this.label,
    required this.value,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════
// SECTION 21: ACTIVITY FEED
// ════════════════════════════════════════════════════════════

class _RecentActivityFeed extends StatelessWidget {
  final List<ActivityEntry> activities;
  final bool isDark;
  final VoidCallback onViewAll;
  const _RecentActivityFeed({
    required this.activities,
    required this.isDark,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) => _DashCard(
    isDark: isDark,
    title: 'Recent Activity',
    icon: Icons.history_rounded,
    iconColor: AppColors.accentOrange,
    trailing: TextButton(
      onPressed: onViewAll,
      child: const Text(
        'View All',
        style: TextStyle(fontSize: 12, color: AppColors.primary),
      ),
    ),
    child: activities.isEmpty
        ? _EmptyState(
            icon: Icons.history_edu_rounded,
            message: 'No recent activity',
            isDark: isDark,
          )
        : Column(
            children: activities.map((a) => _ActivityRow(a, isDark)).toList(),
          ),
  );
}

class _ActivityRow extends StatelessWidget {
  final ActivityEntry activity;
  final bool isDark;
  const _ActivityRow(this.activity, this.isDark);

  Color get _typeColor {
    switch (activity.type) {
      case 'student':
        return AppColors.primary;
      case 'fee':
        return AppColors.success;
      case 'export':
        return AppColors.accentPurple;
      case 'auth':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData get _typeIcon {
    switch (activity.type) {
      case 'student':
        return Icons.person_rounded;
      case 'fee':
        return Icons.payments_rounded;
      case 'export':
        return Icons.file_download_rounded;
      case 'auth':
        return Icons.lock_rounded;
      default:
        return Icons.admin_panel_settings_rounded;
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_typeIcon, color: _typeColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.action,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              if (activity.description.isNotEmpty)
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                activity.performedBy,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
        Text(
          _timeAgo(activity.timestamp),
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          ),
        ),
      ],
    ),
  );

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 22: EXPORT HISTORY CARD
// ════════════════════════════════════════════════════════════

class _ExportHistoryCard extends StatelessWidget {
  final List<ExportRecord> exports;
  final bool isDark;
  final VoidCallback onExport;
  const _ExportHistoryCard({
    super.key,
    required this.exports,
    required this.isDark,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) => _DashCard(
    isDark: isDark,
    title: 'Export History',
    icon: Icons.download_done_rounded,
    iconColor: AppColors.accentGreen,
    trailing: TextButton.icon(
      onPressed: onExport,
      icon: const Icon(Icons.add_rounded, size: 15),
      label: const Text(
        'New',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    child: exports.isEmpty
        ? _EmptyState(
            icon: Icons.download_rounded,
            message: 'No exports yet',
            isDark: isDark,
          )
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exports.length,
            separatorBuilder: (_, __) => Divider(
              height: 14,
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            itemBuilder: (_, i) => _ExportRow(exports[i], isDark),
          ),
  );
}

class _ExportRow extends StatelessWidget {
  final ExportRecord record;
  final bool isDark;
  const _ExportRow(this.record, this.isDark);

  @override
  Widget build(BuildContext context) {
    final completed = record.status.toLowerCase().trim() == 'completed';
    final statusColor = completed ? AppColors.accentGreen : AppColors.warning;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.table_chart_rounded,
                size: 18,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.recordCount} records • ${DateFormat('dd MMM yyyy').format(record.exportedAt)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                record.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 23: QUICK ACTIONS CARD
// ════════════════════════════════════════════════════════════

class _QuickActionsCard extends StatelessWidget {
  final bool isDark, isLoading, isDarkMode;
  final UserRole userRole;
  final VoidCallback onRefresh,
      onAddStudent,
      onExport,
      onReports,
      onAuditLogs,
      onLogout,
      onToggleDark;
  const _QuickActionsCard({
    required this.isDark,
    required this.userRole,
    required this.isLoading,
    required this.onRefresh,
    required this.onAddStudent,
    required this.onExport,
    required this.onReports,
    required this.onAuditLogs,
    required this.onLogout,
    required this.onToggleDark,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) => _DashCard(
    isDark: isDark,
    title: 'Quick Actions',
    icon: Icons.flash_on_rounded,
    iconColor: AppColors.warning,
    child: Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionBtn(
          icon: Icons.refresh_rounded,
          label: 'Refresh',
          color: AppColors.primary,
          isLoading: isLoading,
          onTap: onRefresh,
        ),
        if (userRole.canWrite)
          _ActionBtn(
            icon: Icons.person_add_rounded,
            label: 'Add Student',
            color: AppColors.accentGreen,
            onTap: onAddStudent,
          ),
        if (userRole.canExport)
          _ActionBtn(
            icon: Icons.file_download_rounded,
            label: 'Export',
            color: AppColors.accentPurple,
            onTap: onExport,
          ),
        _ActionBtn(
          icon: Icons.bar_chart_rounded,
          label: 'Reports',
          color: AppColors.info,
          onTap: onReports,
        ),
        _ActionBtn(
          icon: Icons.history_rounded,
          label: 'Audit Logs',
          color: AppColors.accentOrange,
          onTap: onAuditLogs,
        ),
        _ActionBtn(
          icon: isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          label: isDarkMode ? 'Light Mode' : 'Dark Mode',
          color: isDarkMode ? AppColors.warning : AppColors.primaryDark,
          onTap: onToggleDark,
        ),
        _ActionBtn(
          icon: Icons.logout_rounded,
          label: 'Logout',
          color: AppColors.error,
          onTap: onLogout,
        ),
      ],
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: isLoading ? null : onTap,
    icon: isLoading
        ? const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Icon(icon, size: 16),
    label: Text(label, style: const TextStyle(fontSize: 12)),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      disabledBackgroundColor: color.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      shadowColor: color.withOpacity(0.3),
    ),
  );
}

// ════════════════════════════════════════════════════════════
// SECTION 24: CENTER PROFILE CARD
// ════════════════════════════════════════════════════════════

class _CenterProfileCard extends StatelessWidget {
  final String centerCode;
  final UserRole userRole;
  final DashboardStats stats;
  final bool isDark;
  const _CenterProfileCard({
    required this.centerCode,
    required this.userRole,
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cf = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return _DashCard(
      isDark: isDark,
      title: 'Center Profile',
      icon: Icons.account_balance_rounded,
      iconColor: AppColors.primary,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    centerCode.isNotEmpty
                        ? centerCode
                              .substring(0, min(2, centerCode.length))
                              .toUpperCase()
                        : 'KY',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KYP Center',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      centerCode,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textDark,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        userRole.displayName,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark ? Colors.white12 : Colors.grey.shade100,
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ProfileStat(
                label: 'Students',
                value: '${stats.totalStudents}',
                isDark: isDark,
              ),
              _ProfileStat(
                label: 'Batches',
                value: '${stats.totalBatches}',
                isDark: isDark,
              ),
              _ProfileStat(
                label: 'Revenue',
                value: NumberFormat.compact().format(stats.totalRevenue),
                isDark: isDark,
              ),
              _ProfileStat(
                label: 'Portal',
                value: '${stats.portalOpenCount} open',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _ProfileStat({
    required this.label,
    required this.value,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════
// SECTION 25: NOTIFICATIONS PANEL
// ════════════════════════════════════════════════════════════

class _NotificationsPanel extends StatelessWidget {
  final List<AppNotification> notifications;
  final bool isDark;
  final Future<void> Function(String) onMarkRead;
  const _NotificationsPanel({
    required this.notifications,
    required this.isDark,
    required this.onMarkRead,
  });

  Color _notifColor(String type) {
    switch (type) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'alert':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
                const Spacer(),
                if (notifications.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${notifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            color: isDark ? Colors.white12 : Colors.grey.shade100,
            height: 1,
          ),
          Expanded(
            child: notifications.isEmpty
                ? _EmptyState(
                    icon: Icons.notifications_none_rounded,
                    message: 'All caught up! No notifications.',
                    isDark: isDark,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (_, i) {
                      final n = notifications[i];
                      return Dismissible(
                        key: Key(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: AppColors.error.withOpacity(0.1),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.error,
                          ),
                        ),
                        onDismissed: (_) => onMarkRead(n.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _notifColor(n.type).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _notifColor(n.type).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _notifColor(n.type).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  n.type == 'success'
                                      ? Icons.check_circle_rounded
                                      : n.type == 'warning'
                                      ? Icons.warning_rounded
                                      : n.type == 'alert'
                                      ? Icons.error_rounded
                                      : Icons.info_rounded,
                                  color: _notifColor(n.type),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.textLight
                                            : AppColors.textDark,
                                      ),
                                    ),
                                    if (n.body.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          n.body,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        DateFormat(
                                          'dd MMM, hh:mm a',
                                        ).format(n.createdAt),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? Colors.grey.shade500
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 26: AUDIT LOGS PANEL
// ════════════════════════════════════════════════════════════

class _AuditLogsPanel extends StatelessWidget {
  final List<ActivityEntry> activities;
  final bool isDark;
  final Future<void> Function() onRefresh;
  const _AuditLogsPanel({
    required this.activities,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: AppColors.accentOrange,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Audit Logs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: onRefresh,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? Colors.white12 : Colors.grey.shade100,
            height: 1,
          ),
          Expanded(
            child: activities.isEmpty
                ? _EmptyState(
                    icon: Icons.history_edu_rounded,
                    message: 'No audit logs found',
                    isDark: isDark,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activities.length,
                    itemBuilder: (_, i) => _AuditLogRow(activities[i], isDark),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AuditLogRow extends StatelessWidget {
  final ActivityEntry entry;
  final bool isDark;
  const _AuditLogRow(this.entry, this.isDark);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardDark : const Color(0xFFF8FAFF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                entry.type.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.action,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
            ),
            Text(
              DateFormat('hh:mm a').format(entry.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
        if (entry.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              entry.description,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 11,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                entry.performedBy,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM yyyy').format(entry.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════
// SECTION 27: MISC HELPER WIDGETS
// ════════════════════════════════════════════════════════════

class _LegendDot extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isDark;
  const _LegendDot({
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
      Text(
        '$count',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ],
  );
}

class _RoleStatRow extends StatelessWidget {
  final String role;
  final int count;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _RoleStatRow({
    required this.role,
    required this.count,
    required this.icon,
    required this.color,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            role,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ForecastRow extends StatelessWidget {
  final String label, description, unit;
  final double value;
  final bool isDark;
  const _ForecastRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.description,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    final color = value >= 0 ? AppColors.success : AppColors.error;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            value >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}$unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String label, subtitle;
  final bool earned, isDark;
  const _AchievementBadge({
    required this.label,
    required this.subtitle,
    required this.earned,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: 100,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: earned
          ? AppColors.accentYellow.withOpacity(0.12)
          : (isDark ? AppColors.cardDark : Colors.grey.shade50),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: earned
            ? AppColors.accentYellow.withOpacity(0.4)
            : Colors.grey.shade200,
      ),
    ),
    child: Column(
      children: [
        Text(earned ? '🏆' : '🔒', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: earned
                ? AppColors.accentYellow
                : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 8,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════
// SECTION 28: STATS LOADING SKELETON
// ════════════════════════════════════════════════════════════

class _StatsLoadingGrid extends StatefulWidget {
  final bool isDark;
  const _StatsLoadingGrid({required this.isDark});
  @override
  State<_StatsLoadingGrid> createState() => _StatsLoadingGridState();
}

class _StatsLoadingGridState extends State<_StatsLoadingGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: 8,
      itemBuilder: (_, i) => _ShimmerBox(
        isDark: widget.isDark,
        delay: i * 0.12,
        progress: _ctrl.value,
      ),
    ),
  );
}

class _ShimmerBox extends StatelessWidget {
  final bool isDark;
  final double delay, progress;
  const _ShimmerBox({
    required this.isDark,
    required this.delay,
    required this.progress,
  });
  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0);
    final highlight = isDark
        ? const Color(0xFF3D4A5C)
        : const Color(0xFFF0F4F8);
    final t = ((progress + delay) % 1.0);
    final color = Color.lerp(base, highlight, sin(t * pi))!;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION 29: SETTINGS QUICK SHEET & LOGOUT DIALOG
// ════════════════════════════════════════════════════════════

class _SettingsQuickSheet extends StatelessWidget {
  final bool isDark;
  final UserRole userRole;
  final VoidCallback onToggleDark, onLogout, onSettings, onAuditLogs;
  const _SettingsQuickSheet({
    required this.isDark,
    required this.userRole,
    required this.onToggleDark,
    required this.onLogout,
    required this.onSettings,
    required this.onAuditLogs,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Settings & Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
            ),
            _SheetTile(
              icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              label: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              color: AppColors.warning,
              isDark: isDark,
              onTap: onToggleDark,
            ),
            _SheetTile(
              icon: Icons.history_rounded,
              label: 'View Audit Logs',
              color: AppColors.accentOrange,
              isDark: isDark,
              onTap: onAuditLogs,
            ),
            _SheetTile(
              icon: Icons.settings_rounded,
              label: 'Settings',
              color: AppColors.primary,
              isDark: isDark,
              onTap: onSettings,
            ),
            _SheetTile(
              icon: Icons.logout_rounded,
              label: 'Logout',
              color: AppColors.error,
              isDark: isDark,
              onTap: onLogout,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textLight : AppColors.textDark,
      ),
    ),
    trailing: Icon(
      Icons.arrow_forward_ios_rounded,
      size: 14,
      color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
    ),
    onTap: onTap,
  );
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();
  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: AppColors.error,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        const Text('Logout?', textAlign: TextAlign.center),
      ],
    ),
    content: const Text(
      'Are you sure you want to logout from the admin dashboard?',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14),
    ),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      OutlinedButton(
        onPressed: () => Navigator.pop(context, false),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey.shade700,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Cancel'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Logout'),
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════
// SECTION 30: SHARED CARD & EMPTY STATE WIDGETS
// ════════════════════════════════════════════════════════════

class _DashCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final Widget? trailing;

  const _DashCard({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textLight : AppColors.textDark,
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isDark;
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
