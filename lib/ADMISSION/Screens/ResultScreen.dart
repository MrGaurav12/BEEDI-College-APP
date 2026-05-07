import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════
// THEME CONSTANTS — GREEN • WHITE • BLUE
// ═══════════════════════════════════════════════════════════

class AppColors {
  // Primary palette: Green-White-Blue
  static const Color green = Color(0xFF00A86B); // emerald green
  static const Color greenLight = Color(0xFF4DD9A0);
  static const Color greenDark = Color(0xFF007A4D);
  static const Color blue = Color(0xFF1A73E8);
  static const Color blueLight = Color(0xFF4A9EFF);
  static const Color blueDark = Color(0xFF0D47A1);
  static const Color white = Colors.white;
  static const Color surface = Color(0xFFF0FBF6);
  static const Color surfaceBlue = Color(0xFFEFF5FF);
  static const Color card = Colors.white;

  // Semantics
  static const Color success = Color(0xFF00A86B);
  static const Color successLight = Color(0xFF4DD9A0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color warning = Color(0xFFF57C00);
  static const Color gold = Color(0xFFFFB300);
  static const Color silver = Color(0xFF78909C);
  static const Color bronze = Color(0xFFAD6F3B);

  // Text
  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color divider = Color(0xFFDCEFE7);

  // Batch colours
  static Color batchColor(String b) {
    switch (b) {
      case 'FEB 2026':
        return const Color(0xFF1A73E8);
      case 'MARCH 2026':
        return const Color(0xFF00A86B);
      case 'APRIL 2026':
        return const Color(0xFF0097A7);
      case 'MAY 2026':
        return const Color(0xFF388E3C);
      default:
        return blue;
    }
  }

  static List<Color> batchGradient(String b) {
    switch (b) {
      case 'FEB 2026':
        return [const Color(0xFF1A73E8), const Color(0xFF4A9EFF)];
      case 'MARCH 2026':
        return [const Color(0xFF00A86B), const Color(0xFF4DD9A0)];
      case 'APRIL 2026':
        return [const Color(0xFF0097A7), const Color(0xFF26C6DA)];
      case 'MAY 2026':
        return [const Color(0xFF388E3C), const Color(0xFF66BB6A)];
      default:
        return [blue, blueLight];
    }
  }

  static Color gradeColor(String g) {
    switch (g) {
      case 'A+':
        return green;
      case 'A':
        return greenDark;
      case 'B+':
        return blue;
      case 'B':
        return blueLight;
      case 'C':
        return warning;
      case 'D':
        return const Color(0xFFE65100);
      default:
        return error;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════

const int kPassMark = 40;
const int kMaxPerSubject = 100;
const int kTotalSubjects = 3;
const int kMaxTotal = 500;

// ═══════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════

enum SortMode { rank, name, percentage, grade }

enum FilterMode { all, pass, fail }

enum ThemeMode2 { light, dark }

// ═══════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════

class Student {
  final String name;
  final String fatherName;
  final String motherName;
  final String dob;
  final String pin;
  final String rollNo;
  final String mobile;
  final String email;
  final String address;
  final String photoInitials;
  final Color avatarColor;
  final int cit;
  final int cls;
  final int css;
  final int coa;
  final int cpe;
  final String attendance;
  final String admissionDate;
  final String category;

  const Student({
    required this.name,
    required this.fatherName,
    required this.motherName,
    required this.dob,
    required this.pin,
    required this.rollNo,
    required this.mobile,
    this.email = '',
    this.address = '',
    this.photoInitials = '',
    this.avatarColor = AppColors.blue,
    required this.cit,
    required this.cls,
    required this.css,
    required this.coa,
    required this.cpe,
    this.attendance = '90%',
    this.admissionDate = 'Jan 2026',
    this.category = 'General',
  });

  int get total => cit + cls + css + coa + cpe;
  double get percentage => (total / kMaxTotal) * 100;
  bool get citPass => cit >= kPassMark;
  bool get clsPass => cls >= kPassMark;
  bool get cssPass => css >= kPassMark;
  bool get coaPass => coa >= kPassMark;
  bool get cpePass => cpe >= kPassMark;
  bool get overallPass => citPass && clsPass && cssPass && coaPass && cpePass;
  int get passCount =>
      [citPass, clsPass, cssPass, coaPass, cpePass].where((x) => x).length;
  int get failCount => kTotalSubjects - passCount;
  int get highest => [cit, cls, css, coa, cpe].reduce(max);
  int get lowest => [cit, cls, css, coa, cpe].reduce(min);
  double get average => total / kTotalSubjects;

  String get grade {
    final p = percentage;
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B+';
    if (p >= 60) return 'B';
    if (p >= 50) return 'C';
    if (p >= 40) return 'D';
    return 'F';
  }

  String get gradeDescription {
    switch (grade) {
      case 'A+':
        return 'Outstanding';
      case 'A':
        return 'Excellent';
      case 'B+':
        return 'Very Good';
      case 'B':
        return 'Good';
      case 'C':
        return 'Average';
      case 'D':
        return 'Below Average';
      default:
        return 'Fail';
    }
  }

  String get performanceBadge {
    if (percentage >= 90) return '🏆 Topper';
    if (percentage >= 75) return '⭐ Merit';
    if (percentage >= 60) return '✅ Pass';
    if (overallPass) return '✔ Cleared';
    return '⚠ Needs Improvement';
  }

  Color get gradeColor => AppColors.gradeColor(grade);
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : '?';
  }
}

// ═══════════════════════════════════════════════════════════
// BATCH DATA
// ═══════════════════════════════════════════════════════════

const Map<String, List<Student>> batchStudents = {
  'FEB 2026': [
  Student(
    name: 'KUMARI TANUJA BHARTI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '01-01-2005',
    pin: '481092',
    rollNo: 'FEB26/001',
    mobile: '9100000001',
    email: 'tanuja@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF00A86B),
    cit: 78,
    cls: 74,
    css: 76,
    coa: 72,
    cpe: 80,
    attendance: '90%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),
  Student(
    name: 'SIRITI KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '02-02-2005',
    pin: '579234',
    rollNo: 'FEB26/002',
    mobile: '9100000002',
    email: 'siriti@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF1A73E8),
    cit: 70,
    cls: 66,
    css: 68,
    coa: 64,
    cpe: 72,
    attendance: '88%',
    admissionDate: 'Feb 2026',
    category: 'OBC',
  ),
  Student(
    name: 'NANDANI KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '03-03-2006',
    pin: '835671',
    rollNo: 'FEB26/003',
    mobile: '9100000003',
    email: 'nandani@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFE53935),
    cit: 82,
    cls: 78,
    css: 80,
    coa: 76,
    cpe: 84,
    attendance: '92%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),
  Student(
    name: 'ANNU BHARTI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '04-04-2005',
    pin: '742908',
    rollNo: 'FEB26/004',
    mobile: '9100000004',
    email: 'annu@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF8E24AA),
    cit: 65,
    cls: 60,
    css: 62,
    coa: 58,
    cpe: 67,
    attendance: '85%',
    admissionDate: 'Feb 2026',
    category: 'SC',
  ),
  Student(
    name: 'MADHU KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '05-05-2006',
    pin: '316457',
    rollNo: 'FEB26/005',
    mobile: '9100000005',
    email: 'madhu@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFFB8C00),
    cit: 75,
    cls: 70,
    css: 72,
    coa: 68,
    cpe: 77,
    attendance: '89%',
    admissionDate: 'Feb 2026',
    category: 'OBC',
  ),
  Student(
    name: 'KUMARI SNEHA BHARTI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '06-06-2005',
    pin: '204583',
    rollNo: 'FEB26/006',
    mobile: '9100000006',
    email: 'sneha@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF43A047),
    cit: 88,
    cls: 84,
    css: 86,
    coa: 82,
    cpe: 90,
    attendance: '95%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),
  Student(
    name: 'PAYAL KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '07-07-2006',
    pin: '698321',
    rollNo: 'FEB26/007',
    mobile: '9100000007',
    email: 'payal@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF3949AB),
    cit: 72,
    cls: 68,
    css: 70,
    coa: 66,
    cpe: 74,
    attendance: '87%',
    admissionDate: 'Feb 2026',
    category: 'EWS',
  ),
  Student(
    name: 'RANGILA KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '08-08-2005',
    pin: '957160',
    rollNo: 'FEB26/008',
    mobile: '9100000008',
    email: 'rangila@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFD81B60),
    cit: 60,
    cls: 55,
    css: 58,
    coa: 52,
    cpe: 63,
    attendance: '83%',
    admissionDate: 'Feb 2026',
    category: 'SC',
  ),
  Student(
    name: 'AARATI KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '09-09-2006',
    pin: '173846',
    rollNo: 'FEB26/009',
    mobile: '9100000009',
    email: 'aarati@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF00897B),
    cit: 80,
    cls: 76,
    css: 78,
    coa: 74,
    cpe: 82,
    attendance: '91%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),
  Student(
    name: 'SONALI NANDINI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '10-10-2005',
    pin: '428579',
    rollNo: 'FEB26/010',
    mobile: '9100000010',
    email: 'sonali@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF5E35B1),
    cit: 85,
    cls: 82,
    css: 84,
    coa: 80,
    cpe: 88,
    attendance: '94%',
    admissionDate: 'Feb 2026',
    category: 'OBC',
  ),
  Student(
    name: 'NIKKI KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '11-11-2006',
    pin: '365012',
    rollNo: 'FEB26/011',
    mobile: '9100000011',
    email: 'nikki@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF6D4C41),
    cit: 73,
    cls: 70,
    css: 71,
    coa: 69,
    cpe: 75,
    attendance: '88%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),
  Student(
    name: 'ANJALI KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '12-12-2005',
    pin: '791548',
    rollNo: 'FEB26/012',
    mobile: '9100000012',
    email: 'anjali@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF7CB342),
    cit: 77,
    cls: 73,
    css: 75,
    coa: 71,
    cpe: 79,
    attendance: '90%',
    admissionDate: 'Feb 2026',
    category: 'OBC',
  ),
  Student(
    name: 'PRIYANKA KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '13-01-2006',
    pin: '604237',
    rollNo: 'FEB26/013',
    mobile: '9100000013',
    email: 'priyanka@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFEF5350),
    cit: 69,
    cls: 65,
    css: 67,
    coa: 63,
    cpe: 71,
    attendance: '86%',
    admissionDate: 'Feb 2026',
    category: 'EWS',
  ),
  Student(
    name: 'ANKITA KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '14-02-2005',
    pin: '829165',
    rollNo: 'FEB26/014',
    mobile: '9100000014',
    email: 'ankita@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF26A69A),
    cit: 81,
    cls: 77,
    css: 79,
    coa: 75,
    cpe: 83,
    attendance: '92%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),
],
  'MARCH 2026': [
  Student(
    name: 'JYOTI RAJ',
    fatherName: 'Mithlesh Kumar',
    motherName: 'N/A',
    dob: '22-07-2008',
    pin: '903246',
    rollNo: 'MAR26/001',
    mobile: '9000000001',
    email: 'jyoti1@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF1A73E8),
    cit: 310, cls: 214, css: 127,
    coa: 0, cpe: 0,
    attendance: '80%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'RAJNANDANI',
    fatherName: 'Mithlesh Kumar',
    motherName: 'N/A',
    dob: '17-08-2008',
    pin: '457891',
    rollNo: 'MAR26/002',
    mobile: '9000000002',
    email: 'rajnandani2@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF00A86B),
    cit: 281, cls: 205, css: 120,
    coa: 0, cpe: 0,
    attendance: '78%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'NAFISHA KHATUN',
    fatherName: 'MD Tasalim Ansari',
    motherName: 'N/A',
    dob: '12-05-2008',
    pin: '321765',
    rollNo: 'MAR26/003',
    mobile: '9000000003',
    email: 'nafisha3@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF0097A7),
    cit: 265, cls: 279, css: 129,
    coa: 0, cpe: 0,
    attendance: '82%',
    admissionDate: 'Feb 2026',
    category: 'OBC',
  ),

  Student(
    name: 'DOLLY KUMARI',
    fatherName: 'Mithlesh Ray',
    motherName: 'N/A',
    dob: '20-06-2008',
    pin: '678940',
    rollNo: 'MAR26/004',
    mobile: '9000000004',
    email: 'dolly4@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFE91E63),
    cit: 296, cls: 224, css: 199,
    coa: 0, cpe: 0,
    attendance: '88%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'SRISTI KUMARI',
    fatherName: 'Santosh Kumar',
    motherName: 'N/A',
    dob: '16-02-2007',
    pin: '273401',
    rollNo: 'MAR26/005',
    mobile: '9000000005',
    email: 'sristi5@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF673AB7),
    cit: 308, cls: 209, css: 127,
    coa: 0, cpe: 0,
    attendance: '84%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'SANDHYA KUMARI',
    fatherName: 'Akhilesh Paswan',
    motherName: 'N/A',
    dob: '24-11-2009',
    pin: '387206',
    rollNo: 'MAR26/006',
    mobile: '9000000006',
    email: 'sandhya6@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFFF9800),
    cit: 289, cls: 204, css: 122,
    coa: 0, cpe: 0,
    attendance: '79%',
    admissionDate: 'Feb 2026',
    category: 'SC',
  ),

  Student(
    name: 'RAJNANDANI KUMARI',
    fatherName: 'Rajesh Paswan',
    motherName: 'N/A',
    dob: '06-05-2009',
    pin: '692745',
    rollNo: 'MAR26/007',
    mobile: '9000000007',
    email: 'rajnandani7@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF3F51B5),
    cit: 294, cls: 227, css: 122,
    coa: 0, cpe: 0,
    attendance: '81%',
    admissionDate: 'Feb 2026',
    category: 'SC',
  ),

  Student(
    name: 'KUNAL KUMAR',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '01-01-2005',
    pin: '287419',
    rollNo: 'MAR26/008',
    mobile: '9000000008',
    email: 'kunal8@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF4CAF50),
    cit: 295, cls: 211, css: 120,
    coa: 0, cpe: 0,
    attendance: '75%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'HIMANSHU RAJ',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '01-01-2005',
    pin: '819064',
    rollNo: 'MAR26/009',
    mobile: '9000000009',
    email: 'himanshu9@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF9C27B0),
    cit: 0, cls: 0, css: 0,
    coa: 0, cpe: 0,
    attendance: '70%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'SAHIL RAJ',
    fatherName: 'Gautam Sah',
    motherName: 'N/A',
    dob: '27-02-2010',
    pin: '465278',
    rollNo: 'MAR26/010',
    mobile: '9000000010',
    email: 'sahil10@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF795548),
    cit: 0, cls: 0, css: 0,
    coa: 0, cpe: 0,
    attendance: '77%',
    admissionDate: 'Feb 2026',
    category: 'OBC',
  ),

  Student(
    name: 'RANJEET KUMAR',
    fatherName: 'Madan Ray',
    motherName: 'N/A',
    dob: '01-01-2007',
    pin: '902317',
    rollNo: 'MAR26/011',
    mobile: '9000000011',
    email: 'ranjeet11@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF607D8B),
    cit: 293, cls: 201, css: 120,
    coa: 0, cpe: 0,
    attendance: '78%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'PRINCE KUMAR',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '01-01-2005',
    pin: '734621',
    rollNo: 'MAR26/012',
    mobile: '9000000012',
    email: 'prince12@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF2196F3),
    cit: 311, cls: 228, css: 117,
    coa: 0, cpe: 0,
    attendance: '83%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  // Newly added (no marks data)
  Student(
    name: 'ANSHU KUMAR',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '01-01-2005',
    pin: '946573',
    rollNo: 'MAR26/013',
    mobile: '9000000013',
    email: 'anshu13@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF8BC34A),
    cit: 0, cls: 0, css: 0,
    coa: 0, cpe: 0,
    attendance: '70%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'KANCHAN KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '01-01-2005',
    pin: '150398',
    rollNo: 'MAR26/014',
    mobile: '9000000014',
    email: 'kanchan14@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFFF5722),
    cit: 0, cls: 0, css: 0,
    coa: 0, cpe: 0,
    attendance: '70%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'RUPA KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '01-01-2005',
    pin: '146583',
    rollNo: 'MAR26/015',
    mobile: '9000000015',
    email: 'rupa15@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFCDDC39),
    cit: 0, cls: 0, css: 0,
    coa: 0, cpe: 0,
    attendance: '70%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'AJIT KUMAR',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '01-01-2005',
    pin: '614573',
    rollNo: 'MAR26/016',
    mobile: '9000000016',
    email: 'ajit16@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF03A9F4),
    cit: 0, cls: 0, css: 0,
    coa: 0, cpe: 0,
    attendance: '70%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),

  Student(
    name: 'MD SARFUDDIN',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '01-01-2005',
    pin: '758901',
    rollNo: 'MAR26/017',
    mobile: '9000000017',
    email: 'md17@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF9E9E9E),
    cit: 0, cls: 0, css: 0,
    coa: 0, cpe: 0,
    attendance: '70%',
    admissionDate: 'Feb 2026',
    category: 'General',
  ),
],
  'APRIL 2026': [
  Student(
    name: 'SIMRAN KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '01-01-2005',
    pin: '362185',
    rollNo: 'APR26/001',
    mobile: '9000000001',
    email: 'simran@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF00A86B),
    cit: 80,
    cls: 75,
    css: 78,
    coa: 74,
    cpe: 82,
    attendance: '90%',
    admissionDate: 'Mar 2026',
    category: 'General',
  ),
  Student(
    name: 'ANIRUDH KUMAR',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '02-02-2005',
    pin: '721409',
    rollNo: 'APR26/002',
    mobile: '9000000002',
    email: 'anirudh@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF1A73E8),
    cit: 70,
    cls: 68,
    css: 72,
    coa: 65,
    cpe: 75,
    attendance: '88%',
    admissionDate: 'Mar 2026',
    category: 'OBC',
  ),
  Student(
    name: 'MANISH KUMAR',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '03-03-2005',
    pin: '854367',
    rollNo: 'APR26/003',
    mobile: '9000000003',
    email: 'manish@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFE53935),
    cit: 60,
    cls: 55,
    css: 58,
    coa: 52,
    cpe: 61,
    attendance: '85%',
    admissionDate: 'Mar 2026',
    category: 'SC',
  ),
  Student(
    name: 'HIMANSHU KUMAR SINGH',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '04-04-2005',
    pin: '590674',
    rollNo: 'APR26/004',
    mobile: '9000000004',
    email: 'himanshu@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF8E24AA),
    cit: 88,
    cls: 84,
    css: 86,
    coa: 82,
    cpe: 90,
    attendance: '95%',
    admissionDate: 'Mar 2026',
    category: 'General',
  ),
  Student(
    name: 'ANKITA KUMARI 2',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '05-05-2006',
    pin: '418023',
    rollNo: 'APR26/005',
    mobile: '9000000005',
    email: 'ankita@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFFB8C00),
    cit: 76,
    cls: 72,
    css: 74,
    coa: 70,
    cpe: 78,
    attendance: '89%',
    admissionDate: 'Mar 2026',
    category: 'OBC',
  ),
  Student(
    name: 'RAUSHANI KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '06-06-2006',
    pin: '763149',
    rollNo: 'APR26/006',
    mobile: '9000000006',
    email: 'raushani@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF43A047),
    cit: 82,
    cls: 78,
    css: 80,
    coa: 76,
    cpe: 85,
    attendance: '92%',
    admissionDate: 'Mar 2026',
    category: 'General',
  ),
  Student(
    name: 'SONAM KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '07-07-2005',
    pin: '238761',
    rollNo: 'APR26/007',
    mobile: '9000000007',
    email: 'sonam@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF3949AB),
    cit: 68,
    cls: 65,
    css: 66,
    coa: 63,
    cpe: 70,
    attendance: '87%',
    admissionDate: 'Mar 2026',
    category: 'EWS',
  ),
  Student(
    name: 'NISHA KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '08-08-2006',
    pin: '632598',
    rollNo: 'APR26/008',
    mobile: '9000000008',
    email: 'nisha@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFFD81B60),
    cit: 74,
    cls: 70,
    css: 72,
    coa: 68,
    cpe: 76,
    attendance: '90%',
    admissionDate: 'Mar 2026',
    category: 'OBC',
  ),
  Student(
    name: 'SWETA KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '09-09-2005',
    pin: '417830',
    rollNo: 'APR26/009',
    mobile: '9000000009',
    email: 'sweta@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF00897B),
    cit: 79,
    cls: 75,
    css: 77,
    coa: 73,
    cpe: 81,
    attendance: '91%',
    admissionDate: 'Mar 2026',
    category: 'General',
  ),
  Student(
    name: 'MONIKA KUMARI',
    fatherName: 'N/A',
    motherName: 'N/A',
    dob: '10-10-2006',
    pin: '975241',
    rollNo: 'APR26/010',
    mobile: '9000000010',
    email: 'monika@example.com',
    address: 'Bihar',
    avatarColor: Color(0xFF5E35B1),
    cit: 83,
    cls: 80,
    css: 82,
    coa: 78,
    cpe: 86,
    attendance: '93%',
    admissionDate: 'Mar 2026',
    category: 'SC',
  ),
],
  'MAY 2026': [
    Student(
      name: 'DEEPAK MISHRA',
      fatherName: 'Neeraj Mishra',
      motherName: 'Savita Mishra',
      dob: '19-06-2005',
      pin: '334455',
      rollNo: 'MAY26/001',
      mobile: '9876543240',
      email: 'deepak@example.com',
      address: 'Patna, Bihar',
      avatarColor: Color(0xFF388E3C),
      cit: 88,
      cls: 84,
      css: 90,
      coa: 82,
      cpe: 86,
      attendance: '96%',
      admissionDate: 'Apr 2026',
      category: 'General',
    ),
    Student(
      name: 'SHREYA GUPTA',
      fatherName: 'Ravi Gupta',
      motherName: 'Neelam Gupta',
      dob: '07-02-2004',
      pin: '667788',
      rollNo: 'MAY26/002',
      mobile: '9876543241',
      email: 'shreya@example.com',
      address: 'Muzaffarpur, Bihar',
      avatarColor: Color(0xFF00A86B),
      cit: 93,
      cls: 91,
      css: 87,
      coa: 89,
      cpe: 95,
      attendance: '98%',
      admissionDate: 'Apr 2026',
      category: 'General',
    ),
    Student(
      name: 'ROHIT KUMAR',
      fatherName: 'Ashok Kumar',
      motherName: 'Manju Devi',
      dob: '14-10-2006',
      pin: '123456',
      rollNo: 'MAY26/003',
      mobile: '9876543242',
      email: 'rohit2@example.com',
      address: 'Hajipur, Bihar',
      avatarColor: Color(0xFF1A73E8),
      cit: 60,
      cls: 55,
      css: 62,
      coa: 58,
      cpe: 64,
      attendance: '82%',
      admissionDate: 'Apr 2026',
      category: 'OBC',
    ),
  ],
};

// ═══════════════════════════════════════════════════════════
// FEATURE 1: APP STATE (Global state management)
// ═══════════════════════════════════════════════════════════

class AppState extends ChangeNotifier {
  bool isDarkMode = false;
  String? lastLoggedBatch;
  String? lastLoggedName;
  int loginAttempts = 0;
  bool isLocked = false;
  List<String> recentSearches = [];
  List<String> bookmarkedStudents = [];
  Map<String, int> batchViewCount = {};

  void toggleDark() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void recordLogin(String batch, String name) {
    lastLoggedBatch = batch;
    lastLoggedName = name;
    loginAttempts = 0;
    isLocked = false;
    batchViewCount[batch] = (batchViewCount[batch] ?? 0) + 1;
    notifyListeners();
  }

  void failedAttempt() {
    loginAttempts++;
    if (loginAttempts >= 5) isLocked = true;
    notifyListeners();
  }

  void unlock() {
    loginAttempts = 0;
    isLocked = false;
    notifyListeners();
  }

  void addSearch(String q) {
    recentSearches.remove(q);
    recentSearches.insert(0, q);
    if (recentSearches.length > 5) recentSearches.removeLast();
    notifyListeners();
  }

  void toggleBookmark(String name) {
    if (bookmarkedStudents.contains(name)) {
      bookmarkedStudents.remove(name);
    } else {
      bookmarkedStudents.add(name);
    }
    notifyListeners();
  }

  bool isBookmarked(String name) => bookmarkedStudents.contains(name);
}

final AppState appState = AppState();

// ═══════════════════════════════════════════════════════════
// FEATURE 2: SUBJECT META
// ═══════════════════════════════════════════════════════════

class SubjectMeta {
  final String code;
  final String fullName;
  final IconData icon;
  final Color color;

  const SubjectMeta(this.code, this.fullName, this.icon, this.color);
}

const List<SubjectMeta> subjectMetas = [
  SubjectMeta(
    'CIT',
    'Computer Information Technology',
    Icons.computer_rounded,
    AppColors.blue,
  ),
  SubjectMeta(
    'CLS',
    'Computer Literacy Skills',
    Icons.menu_book_rounded,
    AppColors.green,
  ),
  SubjectMeta(
    'CSS',
    'Computer Software Skills',
    Icons.code_rounded,
    Color(0xFF0097A7),
  ),
  SubjectMeta(
    'COA',
    'Computer Org. & Architecture',
    Icons.memory_rounded,
    Color(0xFF7B1FA2),
  ),
  SubjectMeta(
    'CPE',
    'Computer Programming Essentials',
    Icons.terminal_rounded,
    AppColors.greenDark,
  ),
];

// ═══════════════════════════════════════════════════════════
// UTILITIES
// ═══════════════════════════════════════════════════════════

PageRouteBuilder<T> fadeSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 380),
    transitionsBuilder: (_, animation, __, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

String formatPercent(double p) => '${p.toStringAsFixed(1)}%';

// ═══════════════════════════════════════════════════════════
// FEATURE 3: REUSABLE PRESSABLE CARD
// ═══════════════════════════════════════════════════════════

class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;
  const PressableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.96,
  });
  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _ctrl.forward(),
    onTapUp: (_) async {
      await _ctrl.reverse();
      widget.onTap();
    },
    onTapCancel: () => _ctrl.reverse(),
    child: AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: widget.child,
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// FEATURE 4: SHAKE WIDGET
// ═══════════════════════════════════════════════════════════

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;
  const ShakeWidget({super.key, required this.child, this.shake = false});
  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _anim = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ShakeWidget old) {
    super.didUpdateWidget(old);
    if (widget.shake && !old.shake)
      _ctrl.forward(from: 0).then((_) => _ctrl.reverse());
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, child) => Transform.translate(
      offset: Offset(sin(_anim.value * pi * 5) * 8, 0),
      child: child,
    ),
    child: widget.child,
  );
}

// ═══════════════════════════════════════════════════════════
// FEATURE 5: GRADIENT TEXT
// ═══════════════════════════════════════════════════════════

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  const GradientText(this.text, {super.key, this.style, required this.colors});
  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (b) => LinearGradient(
      colors: colors,
    ).createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
    child: Text(text, style: style),
  );
}

// ═══════════════════════════════════════════════════════════
// FEATURE 6: CIRCULAR PERCENT INDICATOR (animated)
// ═══════════════════════════════════════════════════════════

class CircularPercentIndicator extends StatefulWidget {
  final double percent;
  final Color color;
  final double radius;
  final String label;
  const CircularPercentIndicator({
    super.key,
    required this.percent,
    required this.color,
    this.radius = 60,
    this.label = 'Score',
  });
  @override
  State<CircularPercentIndicator> createState() => _CpiState();
}

class _CpiState extends State<CircularPercentIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) {
      final ap = widget.percent * _anim.value;
      return SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: CustomPaint(
          painter: _CircularPainter(percent: ap / 100, color: widget.color),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatPercent(ap),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: widget.radius * 0.27,
                    color: widget.color,
                  ),
                ),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: widget.radius * 0.17,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _CircularPainter extends CustomPainter {
  final double percent;
  final Color color;
  _CircularPainter({required this.percent, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = min(size.width, size.height) / 2 - 8;
    const sw = 9.0;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2,
      2 * pi * percent,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircularPainter old) => old.percent != percent;
}

// ═══════════════════════════════════════════════════════════
// FEATURE 7: ANIMATED SUBJECT BAR
// ═══════════════════════════════════════════════════════════

class SubjectBar extends StatefulWidget {
  final String subject;
  final int marks;
  final bool isPass;
  final int maxMarks;
  final Duration delay;
  final Color color;
  const SubjectBar({
    super.key,
    required this.subject,
    required this.marks,
    required this.isPass,
    this.maxMarks = 100,
    this.delay = Duration.zero,
    this.color = AppColors.blue,
  });
  @override
  State<SubjectBar> createState() => _SubjectBarState();
}

class _SubjectBarState extends State<SubjectBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isPass ? AppColors.green : AppColors.errorLight;
    final ratio = widget.marks / widget.maxMarks;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.isPass ? Icons.check_rounded : Icons.close_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${widget.marks}/${widget.maxMarks}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.isPass ? 'PASS' : 'FAIL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 6,
              color: color.withOpacity(0.12),
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ratio * _anim.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.6), color],
                      ),
                      borderRadius: BorderRadius.circular(6),
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
}

// ═══════════════════════════════════════════════════════════
// FEATURE 8: INFO ROW
// ═══════════════════════════════════════════════════════════

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon!, size: 16, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 8),
        ],
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// FEATURE 9: STAT CHIP
// ═══════════════════════════════════════════════════════════

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.18)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// FEATURE 10: SECTION CARD WRAPPER
// ═══════════════════════════════════════════════════════════

class SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final Color? borderColor;
  const SectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.borderColor,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: borderColor != null
          ? Border.all(color: borderColor!.withOpacity(0.25), width: 1.5)
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.045),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// FEATURE 11: BADGE WIDGET
// ═══════════════════════════════════════════════════════════

class Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const Badge({
    super.key,
    required this.text,
    required this.bg,
    required this.fg,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: fg,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// FEATURE 12: AVATAR WIDGET
// ═══════════════════════════════════════════════════════════

class AvatarWidget extends StatelessWidget {
  final Student student;
  final double size;
  const AvatarWidget({super.key, required this.student, this.size = 72});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: student.avatarColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(size * 0.3),
      border: Border.all(
        color: student.avatarColor.withOpacity(0.5),
        width: 2.5,
      ),
    ),
    child: Center(
      child: Text(
        student.initials,
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w900,
          color: student.avatarColor,
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// FEATURE 13: RANK BADGE
// ═══════════════════════════════════════════════════════════

class RankBadge extends StatelessWidget {
  final int rank;
  const RankBadge({super.key, required this.rank});
  Color get color {
    if (rank == 1) return AppColors.gold;
    if (rank == 2) return AppColors.silver;
    if (rank == 3) return AppColors.bronze;
    return AppColors.textSecondary;
  }

  IconData get icon {
    if (rank == 1) return Icons.looks_one_rounded;
    if (rank == 2) return Icons.looks_two_rounded;
    if (rank == 3) return Icons.looks_3_rounded;
    return Icons.tag;
  }

  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 52,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(0.12),
      border: Border.all(
        color: color.withOpacity(0.35),
        width: rank <= 3 ? 2 : 1,
      ),
    ),
    child: rank <= 3
        ? Icon(icon, color: color, size: 28)
        : Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
  );
}

// ═══════════════════════════════════════════════════════════
// FEATURE 14: SHIMMER LOADER
// ═══════════════════════════════════════════════════════════

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12,
  });
  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        gradient: LinearGradient(
          colors: [
            Color.lerp(
              const Color(0xFFE8F5E9),
              const Color(0xFFC8E6C9),
              _anim.value,
            )!,
            Color.lerp(
              const Color(0xFFE3F2FD),
              const Color(0xFFBBDEFB),
              _anim.value,
            )!,
          ],
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// FEATURE 15: TOASTER / SNACKBAR HELPER
// ═══════════════════════════════════════════════════════════

void showToast(
  BuildContext context,
  String msg, {
  Color? color,
  IconData? icon,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon ?? Icons.info_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: color ?? AppColors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// ════════════════ SCREEN 1: SPLASH ═════════════════════════
// ═══════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade, _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );
    _ring = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _ctrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted)
          Navigator.pushReplacement(
            context,
            fadeSlideRoute(const BatchSelectionScreen()),
          );
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00A86B), Color(0xFF1A73E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _fade,
                  child: const Text(
                    'SMART RESULT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FadeTransition(
                  opacity: _fade,
                  child: Text(
                    'Management System',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _ring,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white.withOpacity(0.7),
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
}

// ═══════════════════════════════════════════════════════════
// ════════════════ SCREEN 2: BATCH SELECTION ═════════════════
// ═══════════════════════════════════════════════════════════

class BatchSelectionScreen extends StatefulWidget {
  const BatchSelectionScreen({super.key});
  @override
  State<BatchSelectionScreen> createState() => _BatchSelectionScreenState();
}

class _BatchSelectionScreenState extends State<BatchSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  final List<AnimationController> _cardCtrs = [];
  final List<Animation<double>> _cardFades = [];
  final List<Animation<Offset>> _cardSlides = [];

  // FEATURE 16: batch stats computed
  Map<String, Map<String, dynamic>> get _batchStats {
    final res = <String, Map<String, dynamic>>{};
    batchStudents.forEach((batch, students) {
      final passed = students.where((s) => s.overallPass).length;
      final avg = students.isEmpty
          ? 0.0
          : students.map((s) => s.percentage).reduce((a, b) => a + b) /
                students.length;
      res[batch] = {'total': students.length, 'passed': passed, 'avg': avg};
    });
    return res;
  }

  final List<Map<String, dynamic>> _batches = [
    {'name': 'FEB 2026', 'icon': Icons.ac_unit_rounded, 'emoji': '❄️'},
    {'name': 'MARCH 2026', 'icon': Icons.local_florist_rounded, 'emoji': '🌸'},
    {'name': 'APRIL 2026', 'icon': Icons.wb_sunny_rounded, 'emoji': '☀️'},
    {'name': 'MAY 2026', 'icon': Icons.celebration_rounded, 'emoji': '🎓'},
  ];

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    for (int i = 0; i < _batches.length; i++) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 520),
      );
      _cardCtrs.add(c);
      _cardFades.add(CurvedAnimation(parent: c, curve: Curves.easeOut));
      _cardSlides.add(
        Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
      );
      Future.delayed(Duration(milliseconds: 180 + i * 90), () {
        if (mounted) c.forward();
      });
    }
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    for (final c in _cardCtrs) c.dispose();
    super.dispose();
  }

  void _onBatchTap(int i) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      fadeSlideRoute(LoginScreen(batchName: _batches[i]['name'])),
    );
  }

  // FEATURE 17: About dialog
  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.info_rounded, color: AppColors.blue),
            SizedBox(width: 10),
            Text('About', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text(
          'Smart Result Management System\nVersion 3.0.0\n\nBuilt for educational institutions to manage and display student results efficiently.\n\n© 2026 SRMS',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _batchStats;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── FEATURE 18: Top app bar with notification+about ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                child: FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.green, AppColors.blue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.green.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GradientText(
                                'SMART RESULT',
                                colors: const [AppColors.green, AppColors.blue],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Text(
                                'Management System',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // FEATURE 19: Analytics button
                        IconButton(
                          icon: const Icon(
                            Icons.bar_chart_rounded,
                            color: AppColors.blue,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              fadeSlideRoute(const GlobalAnalyticsScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: _showAbout,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ── Heading ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select\nYour Batch',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap a batch to view your result',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── FEATURE 20: Batch ListView ──
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _batches.length,
                  itemBuilder: (context, i) {
                    final b = _batches[i];
                    final bname = b['name'] as String;
                    final color = AppColors.batchColor(bname);
                    final st = stats[bname]!;
                    final passRatio =
                        (st['passed'] as int) / (st['total'] as int);

                    return FadeTransition(
                      opacity: _cardFades[i],
                      child: SlideTransition(
                        position: _cardSlides[i],
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: PressableCard(
                            onTap: () => _onBatchTap(i),
                            child: Container(
                              height: 112,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.18),
                                    blurRadius: 22,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: color.withOpacity(0.15),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(23),
                                child: Stack(
                                  children: [
                                    // ── Glassmorphism background tint ──
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              color.withOpacity(0.04),
                                              Colors.white,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ── Decorative circle top-right ──
                                    Positioned(
                                      top: -24,
                                      right: -24,
                                      child: Container(
                                        width: 88,
                                        height: 88,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color.withOpacity(0.06),
                                        ),
                                      ),
                                    ),

                                    // ── Gradient strip on left ──
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 5,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: AppColors.batchGradient(
                                              bname,
                                            ),
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(23),
                                            bottomLeft: Radius.circular(23),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ── Main row content ──
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        16,
                                        0,
                                      ),
                                      child: Row(
                                        children: [
                                          // Icon box
                                          Container(
                                            width: 58,
                                            height: 58,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: AppColors.batchGradient(
                                                  bname,
                                                ),
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: color.withOpacity(
                                                    0.42,
                                                  ),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              b['icon'] as IconData,
                                              color: Colors.white,
                                              size: 26,
                                            ),
                                          ),
                                          const SizedBox(width: 16),

                                          // Center: text + stats + bar
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Emoji + batch name
                                                Row(
                                                  children: [
                                                    Text(
                                                      b['emoji'] as String,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      bname,
                                                      style: TextStyle(
                                                        fontSize: 15.5,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: color,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),

                                                // FEATURE 21: Live batch stats
                                                Row(
                                                  children: [
                                                    _statPill(
                                                      '${st['total']}',
                                                      'Students',
                                                      color,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _statPill(
                                                      '${st['passed']}',
                                                      'Passed',
                                                      AppColors.green,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 9),

                                                // FEATURE 22: Improved progress bar
                                                Stack(
                                                  children: [
                                                    Container(
                                                      height: 7,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            color.withOpacity(
                                                              0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                    ),
                                                    FractionallySizedBox(
                                                      widthFactor: passRatio,
                                                      child: Container(
                                                        height: 7,
                                                        decoration:
                                                            BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                    colors: AppColors
                                                                        .batchGradient(
                                                                          bname,
                                                                        ),
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                        20,
                                                                      ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: color
                                                                      .withOpacity(
                                                                        0.4,
                                                                      ),
                                                                  blurRadius: 4,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        1,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Right: arrow
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 15,
                                              color: color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
              // FEATURE 23: Footer with total institution stats
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _footerStat(
                      '${batchStudents.values.fold(0, (a, b) => a + b.length)}',
                      'Students',
                    ),
                    _divider(),
                    _footerStat(
                      '${batchStudents.values.fold(0, (a, l) => a + l.where((s) => s.overallPass).length)}',
                      'Passed',
                    ),
                    _divider(),
                    _footerStat('4', 'Batches'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '© 2026 Smart Result Management System',
                style: TextStyle(color: Colors.grey[400], fontSize: 10.5),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Mini stat pill widget
  Widget _statPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerStat(String val, String lbl) => Column(
    children: [
      Text(
        val,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
      ),
      Text(
        lbl,
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      ),
    ],
  );

  Widget _divider() => Container(
    height: 30,
    width: 1.5,
    margin: const EdgeInsets.symmetric(horizontal: 20),
    color: AppColors.divider,
  );
}

// ═══════════════════════════════════════════════════════════
// ════════════════ SCREEN 3: LOGIN ══════════════════════════
// ═══════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  final String batchName;
  const LoginScreen({super.key, required this.batchName});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false, _obscure = true, _shake = false;
  String? _error;
  late AnimationController _formCtrl, _pulseCtrl;
  late Animation<double> _formFade, _pulse;
  late Animation<Offset> _formSlide;
  Color get _bc => AppColors.batchColor(widget.batchName);

  @override
  void initState() {
    super.initState();
    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _formFade = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween(
      begin: 0.97,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _formCtrl.forward();
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    _pulseCtrl.dispose();
    _nameCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _error = null;
      _shake = false;
    });
    if (!_formKey.currentState!.validate()) return;
    if (appState.isLocked) {
      setState(() {
        _error = 'Too many attempts. Please wait.';
        _shake = true;
      });
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 1100));
    final name = _nameCtrl.text.trim().toUpperCase();
    final pin = _pinCtrl.text.trim();
    final students = batchStudents[widget.batchName] ?? [];
    Student? found;
    for (final s in students) {
      if (s.name == name && s.pin == pin) {
        found = s;
        break;
      }
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    if (found != null) {
      HapticFeedback.heavyImpact();
      appState.recordLogin(widget.batchName, found.name);
      Navigator.pushReplacement(
        context,
        fadeSlideRoute(
          ResultScreen(student: found, batchName: widget.batchName),
        ),
      );
    } else {
      HapticFeedback.vibrate();
      appState.failedAttempt();
      setState(() {
        final rem = 5 - appState.loginAttempts;
        _error = rem > 0
            ? 'Invalid name or PIN. $rem attempt${rem == 1 ? "" : "s"} remaining.'
            : 'Account locked due to too many failed attempts.';
        _shake = true;
      });
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted)
        setState(() {
          _shake = false;
        });
    }
  }

  // FEATURE 24: Quick fill from hint
  void _quickFill(Student s) {
    _nameCtrl.text = s.name;
    _pinCtrl.text = s.pin;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final students = batchStudents[widget.batchName] ?? [];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFE3F2FD), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppColors.textPrimary,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    // FEATURE 25: Pulsing batch chip
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, child) =>
                          Transform.scale(scale: _pulse.value, child: child),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.batchGradient(widget.batchName),
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: _bc.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.batchName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _formFade,
                    child: SlideTransition(
                      position: _formSlide,
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          // Lock icon
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.batchGradient(
                                  widget.batchName,
                                ),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: _bc.withOpacity(0.4),
                                  blurRadius: 22,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_open_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Student Login',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Enter your credentials to view result',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Form card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: _bc.withOpacity(0.08),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _field(
                                    _nameCtrl,
                                    'Student Name',
                                    'Enter full name in CAPS',
                                    Icons.person_outline_rounded,
                                    caps: TextCapitalization.characters,
                                    validator: (v) =>
                                        v == null || v.trim().length < 3
                                        ? 'Name too short'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _field(
                                    _pinCtrl,
                                    '6-Digit PIN',
                                    '● ● ● ● ● ●',
                                    Icons.lock_outline_rounded,
                                    obscure: _obscure,
                                    kb: TextInputType.number,
                                    maxLen: 6,
                                    formatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    spacing: 6,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() {
                                        _obscure = !_obscure;
                                      }),
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Enter PIN'
                                        : v.length != 6
                                        ? 'PIN must be 6 digits'
                                        : null,
                                  ),
                                  // FEATURE 26: Login attempts warning
                                  if (appState.loginAttempts > 0 &&
                                      !appState.isLocked) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: AppColors.warning,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${appState.loginAttempts}/5 failed attempts',
                                          style: const TextStyle(
                                            color: AppColors.warning,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (_error != null) ...[
                                    const SizedBox(height: 14),
                                    ShakeWidget(
                                      shake: _shake,
                                      child: Container(
                                        padding: const EdgeInsets.all(13),
                                        decoration: BoxDecoration(
                                          color: AppColors.errorLight
                                              .withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: AppColors.errorLight
                                                .withOpacity(0.35),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              color: AppColors.errorLight,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _error!,
                                                style: const TextStyle(
                                                  color: AppColors.error,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.45,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  // FEATURE 27: Unlock button if locked
                                  if (appState.isLocked) ...[
                                    const SizedBox(height: 14),
                                    TextButton.icon(
                                      onPressed: () {
                                        appState.unlock();
                                        setState(() {
                                          _error = null;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.lock_open_rounded,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Unlock Account (Demo)',
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.blue,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 22),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _loading || appState.isLocked
                                          ? null
                                          : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _bc,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: _bc
                                            .withOpacity(0.55),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 280,
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.search_rounded,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'View My Result',
                                                    style: TextStyle(
                                                      fontSize: 15.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // FEATURE 28: Quick-fill credential hints (tappable)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _bc.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _bc.withOpacity(0.15)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.tips_and_updates_rounded,
                                      color: _bc,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tap to quick-fill credentials:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _bc,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...students
                                    .take(3)
                                    .map(
                                      (s) => GestureDetector(
                                        onTap: () => _quickFill(s),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: _bc.withOpacity(0.2),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.person_rounded,
                                                size: 14,
                                                color: _bc,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${s.name.split(' ').first} • PIN: ${s.pin}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.touch_app_rounded,
                                                size: 14,
                                                color: _bc.withOpacity(0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '© 2026 Smart Result Management System',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
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
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType? kb,
    int? maxLen,
    List<TextInputFormatter>? formatters,
    double spacing = 0,
    Widget? suffix,
    TextCapitalization caps = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: kb,
      maxLength: maxLen,
      inputFormatters: formatters,
      textCapitalization: caps,
      style: TextStyle(fontSize: 14.5, letterSpacing: spacing),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        prefixIcon: Icon(icon, color: _bc, size: 20),
        suffixIcon: suffix,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13.5,
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withOpacity(0.45),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF0FBF6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _bc, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
      validator: validator,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ════════════════ SCREEN 4: RESULT ═════════════════════════
// ═══════════════════════════════════════════════════════════

class ResultScreen extends StatefulWidget {
  final Student student;
  final String batchName;
  const ResultScreen({
    super.key,
    required this.student,
    required this.batchName,
  });
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  // FEATURE 29: Tab controller for result sections
  late TabController _tabCtrl;
  bool _isBookmarked = false;

  Color get _bc => AppColors.batchColor(widget.batchName);
  Student get s => widget.student;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _tabCtrl = TabController(length: 3, vsync: this);
    _fadeCtrl.forward();
    _isBookmarked = appState.isBookmarked(s.name);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    appState.toggleBookmark(s.name);
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    showToast(
      context,
      _isBookmarked ? 'Bookmarked!' : 'Bookmark removed',
      color: _isBookmarked ? AppColors.green : AppColors.textSecondary,
      icon: _isBookmarked
          ? Icons.bookmark_rounded
          : Icons.bookmark_border_rounded,
    );
  }

  // FEATURE 30: Share result text
  void _shareResult() {
    final text =
        '''
📋 SMART RESULT – ${widget.batchName}
━━━━━━━━━━━━━━━━━━━
👤 Name     : ${s.name}
🎓 Roll No  : ${s.rollNo}
━━━━━━━━━━━━━━━━━━━
📚 CIT : ${s.cit}/400
📚 CLS : ${s.cls}/350
📚 CSS : ${s.css}/150
📚 COA : ${s.coa}/100
📚 CPE : ${s.cpe}/100
━━━━━━━━━━━━━━━━━━━
📊 Total    : ${s.total}/900
📈 %age     : ${formatPercent(s.percentage)}
🏷️  Grade    : ${s.grade} (${s.gradeDescription})
✅ Result   : ${s.overallPass ? "PASS" : "FAIL"}
━━━━━━━━━━━━━━━━━━━
''';
    Clipboard.setData(ClipboardData(text: text));
    showToast(
      context,
      'Result copied to clipboard!',
      color: AppColors.blue,
      icon: Icons.copy_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPass = s.overallPass;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FadeTransition(
        opacity: _fade,
        child: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              expandedHeight: 240,
              floating: false,
              pinned: true,
              backgroundColor: isPass ? AppColors.green : AppColors.error,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              ),
              actions: [
                // FEATURE 31: Bookmark toggle
                IconButton(
                  icon: Icon(
                    _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: Colors.white,
                  ),
                  onPressed: _toggleBookmark,
                ),
                // FEATURE 32: Share
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  onPressed: _shareResult,
                ),
                // FEATURE 33: Leaderboard nav
                IconButton(
                  icon: const Icon(
                    Icons.leaderboard_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    fadeSlideRoute(
                      LeaderboardScreen(
                        loggedInName: s.name,
                        batchName: widget.batchName,
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPass
                          ? [
                              AppColors.greenDark,
                              AppColors.green,
                              AppColors.greenLight,
                            ]
                          : [AppColors.error, AppColors.errorLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 54, 18, 16),
                      child: Row(
                        children: [
                          // FEATURE 34: Avatar
                          AvatarWidget(student: s, size: 82),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  s.rollNo,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s.performanceBadge,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Badge(
                                      text: isPass ? '✓ PASS' : '✗ FAIL',
                                      bg: Colors.white,
                                      fg: isPass
                                          ? AppColors.green
                                          : AppColors.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Badge(
                                      text: 'Grade: ${s.grade}',
                                      bg: Colors.white.withOpacity(0.25),
                                      fg: Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // FEATURE 35: Tabs on app bar
              bottom: TabBar(
                controller: _tabCtrl,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.person_rounded, size: 18),
                    text: 'Details',
                  ),
                  Tab(
                    icon: Icon(Icons.menu_book_rounded, size: 18),
                    text: 'Marks',
                  ),
                  Tab(
                    icon: Icon(Icons.analytics_rounded, size: 18),
                    text: 'Summary',
                  ),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildDetailsTab(),
              _buildMarksTab(),
              _buildSummaryTab(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 1: Details ──────────────────────────────────────

  Widget _buildDetailsTab() => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const SizedBox(height: 4),
        // Batch + score row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.batchGradient(widget.batchName),
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _bc.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.batchName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            CircularPercentIndicator(
              percent: s.percentage,
              color: s.overallPass ? AppColors.green : AppColors.error,
              radius: 46,
            ),
          ],
        ),
        const SizedBox(height: 14),
        SectionCard(
          icon: Icons.person_rounded,
          iconColor: _bc,
          title: 'Personal Information',
          child: Column(
            children: [
              InfoRow(
                label: 'Full Name',
                value: s.name,
                icon: Icons.badge_rounded,
                iconColor: _bc,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Roll No',
                value: s.rollNo,
                icon: Icons.numbers_rounded,
                iconColor: _bc,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Date of Birth',
                value: s.dob,
                icon: Icons.cake_rounded,
                iconColor: _bc,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Father',
                value: s.fatherName,
                icon: Icons.man_rounded,
                iconColor: _bc,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Mother',
                value: s.motherName,
                icon: Icons.woman_rounded,
                iconColor: _bc,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Mobile',
                value: s.mobile,
                icon: Icons.phone_rounded,
                iconColor: _bc,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Email',
                value: s.email.isEmpty ? '—' : s.email,
                icon: Icons.email_rounded,
                iconColor: _bc,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Address',
                value: s.address.isEmpty ? '—' : s.address,
                icon: Icons.location_on_rounded,
                iconColor: _bc,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // FEATURE 36: Academic details card
        SectionCard(
          icon: Icons.school_rounded,
          iconColor: AppColors.blue,
          title: 'Academic Info',
          child: Column(
            children: [
              InfoRow(
                label: 'Batch',
                value: widget.batchName,
                icon: Icons.group_rounded,
                iconColor: AppColors.blue,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Category',
                value: s.category,
                icon: Icons.category_rounded,
                iconColor: AppColors.blue,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Admission',
                value: s.admissionDate,
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.blue,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Attendance',
                value: s.attendance,
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.green,
              ),
              const Divider(height: 1),
              InfoRow(
                label: 'Subjects',
                value:
                    '$kTotalSubjects (${s.passCount} Pass, ${s.failCount} Fail)',
                icon: Icons.book_rounded,
                iconColor: AppColors.blue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: PressableCard(
                onTap: _shareResult,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.batchGradient(widget.batchName),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _bc.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Copy Result',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PressableCard(
                onTap: () => Navigator.push(
                  context,
                  fadeSlideRoute(
                    LeaderboardScreen(
                      loggedInName: s.name,
                      batchName: widget.batchName,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _bc.withOpacity(0.3), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.leaderboard_rounded, color: _bc, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Leaderboard',
                        style: TextStyle(
                          color: _bc,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ),
  );

  // ── Tab 2: Marks ─────────────────────────────────────────

  Widget _buildMarksTab() => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const SizedBox(height: 4),
        SectionCard(
          icon: Icons.menu_book_rounded,
          iconColor: AppColors.blue,
          title: 'Subject-wise Marks',
          child: Column(
            children: [
              SubjectBar(
                subject: 'BS-CIT – Computer Information Technology',
                marks: s.cit,
                isPass: s.citPass,
                delay: const Duration(milliseconds: 80),
              ),
              SubjectBar(
                subject: 'BS-CLS – Computer Literacy Skills',
                marks: s.cls,
                isPass: s.clsPass,
                delay: const Duration(milliseconds: 160),
              ),
              SubjectBar(
                subject: 'BS-CSS – Computer Software Skills',
                marks: s.css,
                isPass: s.cssPass,
                delay: const Duration(milliseconds: 240),
              ),
              SubjectBar(
                subject: 'COA – Org. & Architecture',
                marks: s.coa,
                isPass: s.coaPass,
                delay: const Duration(milliseconds: 320),
              ),
              SubjectBar(
                subject: 'CPE – Programming Essentials',
                marks: s.cpe,
                isPass: s.cpePass,
                delay: const Duration(milliseconds: 400),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Passing marks: 40 per subject (out of 100)',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // FEATURE 37: Subject comparison radar chart (text-based visual)
        SectionCard(
          icon: Icons.compare_rounded,
          iconColor: AppColors.green,
          title: 'Subject Comparison',
          child: Column(
            children: [
              ...[
                    'CIT:${s.cit}',
                    'CLS:${s.cls}',
                    'CSS:${s.css}',
                    'COA:${s.coa}',
                    'CPE:${s.cpe}',
                  ]
                  .asMap()
                  .map((i, pair) {
                    final parts = pair.split(':');
                    final marks = int.parse(parts[1]);
                    final meta = subjectMetas[i];
                    return MapEntry(
                      i,
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 44,
                              child: Text(
                                parts[0],
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: meta.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: meta.color.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: marks / 100,
                                    child: Container(
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            meta.color.withOpacity(0.5),
                                            meta.color,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            meta.icon,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            meta.fullName,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$marks',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: meta.color,
                                //width: 30,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                  .values
                  .toList(),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );

  // ── Tab 3: Summary ───────────────────────────────────────

  Widget _buildSummaryTab() {
    final isPass = s.overallPass;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 4),
          SectionCard(
            icon: Icons.analytics_rounded,
            iconColor: AppColors.warning,
            title: 'Result Summary',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatChip(
                        label: 'Total Marks',
                        value: '${s.total}',
                        color: AppColors.blue,
                        icon: Icons.calculate_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatChip(
                        label: 'Percentage',
                        value: formatPercent(s.percentage),
                        color: AppColors.green,
                        icon: Icons.percent_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatChip(
                        label: 'Grade',
                        value: s.grade,
                        color: s.gradeColor,
                        icon: Icons.star_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // FEATURE 38: Extra stats row
                Row(
                  children: [
                    Expanded(
                      child: StatChip(
                        label: 'Highest',
                        value: '${s.highest}',
                        color: AppColors.green,
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatChip(
                        label: 'Lowest',
                        value: '${s.lowest}',
                        color: s.lowest < 40
                            ? AppColors.error
                            : AppColors.warning,
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatChip(
                        label: 'Average',
                        value: s.average.toStringAsFixed(1),
                        color: AppColors.blue,
                        icon: Icons.equalizer_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // FEATURE 39: Detailed pass/fail breakdown
                Row(
                  children: [
                    Expanded(
                      child: _passFailTile(
                        s.passCount,
                        'Passed',
                        AppColors.green,
                        Icons.check_circle_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _passFailTile(
                        s.failCount,
                        'Failed',
                        AppColors.error,
                        Icons.cancel_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPass
                          ? [AppColors.greenDark, AppColors.green]
                          : [AppColors.error, AppColors.errorLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPass
                            ? Icons.emoji_events_rounded
                            : Icons.warning_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPass
                            ? 'OVERALL RESULT: PASS'
                            : 'OVERALL RESULT: FAIL',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // FEATURE 40: Grade explanation card
          SectionCard(
            icon: Icons.grade_rounded,
            iconColor: s.gradeColor,
            title: 'Grade Analysis',
            borderColor: s.gradeColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: s.gradeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: s.gradeColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          s.grade,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: s.gradeColor,
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
                            s.gradeDescription,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: s.gradeColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatPercent(s.percentage),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.performanceBadge,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Grade scale
                ...[
                  ['A+', '90–100', 'Outstanding', AppColors.green],
                  ['A', '80–89', 'Excellent', AppColors.greenDark],
                  ['B+', '70–79', 'Very Good', AppColors.blue],
                  ['B', '60–69', 'Good', AppColors.blueLight],
                  ['C', '50–59', 'Average', AppColors.warning],
                  ['D', '40–49', 'Pass', AppColors.bronze],
                  ['F', '<40', 'Fail', AppColors.error],
                ].map((row) {
                  final isCurrentGrade = s.grade == row[0];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentGrade
                          ? (row[3] as Color).withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isCurrentGrade
                          ? Border.all(
                              color: (row[3] as Color).withOpacity(0.4),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            row[0] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: row[3] as Color,
                            ),
                          ),
                        ),
                        Text(
                          row[1] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            row[2] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: isCurrentGrade
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isCurrentGrade)
                          const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.green,
                            size: 18,
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // FEATURE 41: Attendance + Topper card
          SectionCard(
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.blue,
            title: 'Additional Stats',
            child: Column(
              children: [
                _statRow(
                  Icons.check_circle_rounded,
                  'Attendance',
                  s.attendance,
                  AppColors.green,
                ),
                const Divider(height: 18),
                _statRow(
                  Icons.category_rounded,
                  'Category',
                  s.category,
                  AppColors.blue,
                ),
                const Divider(height: 18),
                _statRow(
                  Icons.calendar_today_rounded,
                  'Admission',
                  s.admissionDate,
                  AppColors.warning,
                ),
                const Divider(height: 18),
                _statRow(
                  Icons.workspace_premium_rounded,
                  'Performance',
                  s.performanceBadge,
                  s.gradeColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            '© 2026 Smart Result Management System',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _passFailTile(int count, String label, Color color, IconData icon) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );

  Widget _statRow(IconData icon, String label, String value, Color color) =>
      Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════
// ════════════════ SCREEN 5: LEADERBOARD ════════════════════
// ═══════════════════════════════════════════════════════════

class _RankedStudent {
  final int rank;
  final Student student;
  _RankedStudent({required this.rank, required this.student});
}

class LeaderboardScreen extends StatefulWidget {
  final String loggedInName;
  final String batchName;
  const LeaderboardScreen({
    super.key,
    required this.loggedInName,
    required this.batchName,
  });
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late List<_RankedStudent> _ranked;
  late List<_RankedStudent> _filtered;
  SortMode _sort = SortMode.rank;
  FilterMode _filter = FilterMode.all;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  late List<AnimationController> _itemCtrs;
  late List<Animation<double>> _itemFades;
  Color get _bc => AppColors.batchColor(widget.batchName);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _buildRanked();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    for (final c in _itemCtrs) c.dispose();
    super.dispose();
  }

  void _buildRanked({SortMode? sort}) {
    _sort = sort ?? _sort;
    final students = List<Student>.from(batchStudents[widget.batchName] ?? []);
    students.sort((a, b) {
      switch (_sort) {
        case SortMode.name:
          return a.name.compareTo(b.name);
        case SortMode.percentage:
          return b.percentage.compareTo(a.percentage);
        case SortMode.grade:
          return a.grade.compareTo(b.grade);
        case SortMode.rank:
        default:
          return b.total.compareTo(a.total);
      }
    });
    _ranked = List.generate(
      students.length,
      (i) => _RankedStudent(rank: i + 1, student: students[i]),
    );
    _itemCtrs = List.generate(students.length, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 380),
      );
      Future.delayed(Duration(milliseconds: 100 + i * 60), () {
        if (mounted) c.forward();
      });
      return c;
    });
    _itemFades = _itemCtrs
        .map(
          (c) =>
              CurvedAnimation(parent: c, curve: Curves.easeOut)
                  as Animation<double>,
        )
        .toList();
    _applyFilter();
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase().trim();
    List<_RankedStudent> list = List.from(_ranked);
    if (_filter == FilterMode.pass)
      list = list.where((r) => r.student.overallPass).toList();
    if (_filter == FilterMode.fail)
      list = list.where((r) => !r.student.overallPass).toList();
    if (q.isNotEmpty)
      list = list
          .where((r) => r.student.name.toLowerCase().contains(q))
          .toList();
    if (mounted)
      setState(() {
        _filtered = list;
      });
  }

  void _changeSort(SortMode m) {
    for (final c in _itemCtrs) {
      c.reset();
    }
    _buildRanked(sort: m);
    if (mounted) setState(() {});
  }

  void _changeFilter(FilterMode m) {
    _filter = m;
    _applyFilter();
  }

  // FEATURE 42: Batch stats banner
  Widget _buildStatsBanner() {
    final students = batchStudents[widget.batchName] ?? [];
    final passed = students.where((s) => s.overallPass).length;
    final top = students.isEmpty
        ? null
        : students.reduce((a, b) => a.total > b.total ? a : b);
    final avg = students.isEmpty
        ? 0.0
        : students.map((s) => s.percentage).reduce((a, b) => a + b) /
              students.length;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.batchGradient(widget.batchName),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _bc.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _bannerStat('${students.length}', 'Total', Icons.people_rounded),
          _bannerDivider(),
          _bannerStat('$passed', 'Passed', Icons.check_circle_rounded),
          _bannerDivider(),
          _bannerStat(
            '${students.length - passed}',
            'Failed',
            Icons.cancel_rounded,
          ),
          _bannerDivider(),
          _bannerStat(
            '${avg.toStringAsFixed(0)}%',
            'Avg',
            Icons.percent_rounded,
          ),
        ],
      ),
    );
  }

  Widget _bannerStat(String v, String l, IconData ic) => Expanded(
    child: Column(
      children: [
        Icon(ic, color: Colors.white.withOpacity(0.8), size: 16),
        const SizedBox(height: 2),
        Text(
          v,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          l,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 10.5,
          ),
        ),
      ],
    ),
  );
  Widget _bannerDivider() =>
      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.25));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leaderboard',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.batchName,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // FEATURE 43: Sort picker
          PopupMenuButton<SortMode>(
            icon: const Icon(Icons.sort_rounded, color: AppColors.textPrimary),
            onSelected: _changeSort,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: SortMode.rank,
                child: Text('Sort by Rank'),
              ),
              const PopupMenuItem(
                value: SortMode.name,
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: SortMode.percentage,
                child: Text('Sort by %'),
              ),
              const PopupMenuItem(
                value: SortMode.grade,
                child: Text('Sort by Grade'),
              ),
            ],
          ),
          // FEATURE 44: Filter picker
          PopupMenuButton<FilterMode>(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.textPrimary,
            ),
            onSelected: _changeFilter,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterMode.all,
                child: Text('Show All'),
              ),
              const PopupMenuItem(
                value: FilterMode.pass,
                child: Text('Pass Only'),
              ),
              const PopupMenuItem(
                value: FilterMode.fail,
                child: Text('Fail Only'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search student…',
                hintStyle: const TextStyle(fontSize: 13.5),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          appState.addSearch(_searchCtrl.text);
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: Column(
          children: [
            _buildStatsBanner(),
            // Filter chips row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _filterChip('All', FilterMode.all),
                  const SizedBox(width: 8),
                  _filterChip('Pass Only', FilterMode.pass),
                  const SizedBox(width: 8),
                  _filterChip('Fail Only', FilterMode.fail),
                ],
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 60,
                            color: AppColors.textSecondary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No students found',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.6),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final r = _filtered[i];
                        final isMe = r.student.name == widget.loggedInName;
                        final origI = _ranked.indexWhere(
                          (x) => x.student.name == r.student.name,
                        );
                        final fade = (origI >= 0 && origI < _itemFades.length)
                            ? _itemFades[origI]
                            : const AlwaysStoppedAnimation(1.0);
                        return FadeTransition(
                          opacity: fade,
                          child: _buildLeaderRow(r, isMe),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, FilterMode mode) {
    final active = _filter == mode;
    return GestureDetector(
      onTap: () => _changeFilter(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _bc : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _bc : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderRow(_RankedStudent r, bool isMe) {
    final s = r.student;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isMe ? _bc.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMe ? _bc.withOpacity(0.35) : AppColors.divider,
          width: isMe ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: r.rank <= 3
                ? AppColors.gold.withOpacity(0.1)
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            RankBadge(rank: r.rank),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          s.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: isMe ? _bc : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _bc,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.rollNo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // FEATURE 45: Mini subject scores
                  Row(
                    children: ['CIT:${s.cit}', 'CLS:${s.cls}', 'CSS:${s.css}']
                        .map((p) {
                          final parts = p.split(':');
                          final m = int.parse(parts[1]);
                          final pass = m >= 40;
                          return Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (pass
                                          ? AppColors.green
                                          : AppColors.errorLight)
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$p',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: pass
                                    ? AppColors.green
                                    : AppColors.errorLight,
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${s.total}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isMe ? _bc : AppColors.textPrimary,
                  ),
                ),
                const Text(
                  '/ 500',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPercent(s.percentage),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: s.overallPass
                          ? [AppColors.greenDark, AppColors.green]
                          : [AppColors.error, AppColors.errorLight],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.overallPass ? 'PASS' : 'FAIL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ════════════ SCREEN 6: GLOBAL ANALYTICS ════════════════════
// ═══════════════════════════════════════════════════════════

class GlobalAnalyticsScreen extends StatefulWidget {
  const GlobalAnalyticsScreen({super.key});
  @override
  State<GlobalAnalyticsScreen> createState() => _GlobalAnalyticsScreenState();
}

class _GlobalAnalyticsScreenState extends State<GlobalAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Student> get _allStudents =>
      batchStudents.values.expand((l) => l).toList();

  @override
  Widget build(BuildContext context) {
    final all = _allStudents;
    final passed = all.where((s) => s.overallPass).length;
    final failed = all.length - passed;
    final avg = all.isEmpty
        ? 0.0
        : all.map((s) => s.percentage).reduce((a, b) => a + b) / all.length;
    final toppers = all.where((s) => s.percentage >= 90).length;
    final topStudent = all.isEmpty
        ? null
        : all.reduce((a, b) => a.total > b.total ? a : b);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Global Analytics',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'All Batches',
              style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // FEATURE 46: Global stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _analyticsCard(
                    'Total Students',
                    '${all.length}',
                    Icons.people_rounded,
                    AppColors.blue,
                  ),
                  _analyticsCard(
                    'Pass',
                    '$passed',
                    Icons.check_circle_rounded,
                    AppColors.green,
                  ),
                  _analyticsCard(
                    'Fail',
                    '$failed',
                    Icons.cancel_rounded,
                    AppColors.error,
                  ),
                  _analyticsCard(
                    'Avg Score',
                    '${avg.toStringAsFixed(1)}%',
                    Icons.percent_rounded,
                    AppColors.warning,
                  ),
                  _analyticsCard(
                    'Toppers (A+)',
                    '$toppers',
                    Icons.emoji_events_rounded,
                    AppColors.gold,
                  ),
                  _analyticsCard(
                    'Batches',
                    '${batchStudents.length}',
                    Icons.calendar_today_rounded,
                    AppColors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // FEATURE 47: Per-batch table
              SectionCard(
                icon: Icons.table_chart_rounded,
                iconColor: AppColors.blue,
                title: 'Batch-wise Performance',
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Batch',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Pass',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppColors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Avg%',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppColors.blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...batchStudents.entries.map((e) {
                      final students = e.value;
                      final pass = students.where((s) => s.overallPass).length;
                      final bavg = students.isEmpty
                          ? 0.0
                          : students
                                    .map((s) => s.percentage)
                                    .reduce((a, b) => a + b) /
                                students.length;
                      final color = AppColors.batchColor(e.key);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      e.key,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: color,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${students.length}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '$pass',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.green,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${bavg.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // FEATURE 48: Top performer spotlight
              if (topStudent != null)
                SectionCard(
                  icon: Icons.emoji_events_rounded,
                  iconColor: AppColors.gold,
                  title: '🏆 Top Performer',
                  borderColor: AppColors.gold,
                  child: Row(
                    children: [
                      AvatarWidget(student: topStudent, size: 60),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topStudent.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              topStudent.rollNo,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${topStudent.total}/500 • ${formatPercent(topStudent.percentage)} • Grade: ${topStudent.grade}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              // FEATURE 49: Grade distribution
              SectionCard(
                icon: Icons.pie_chart_rounded,
                iconColor: AppColors.green,
                title: 'Grade Distribution',
                child: Column(
                  children: ['A+', 'A', 'B+', 'B', 'C', 'D', 'F'].map((g) {
                    final count = all.where((s) => s.grade == g).length;
                    final frac = all.isEmpty ? 0.0 : count / all.length;
                    final color = AppColors.gradeColor(g);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              g,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                height: 22,
                                color: color.withOpacity(0.1),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: frac,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [color.withOpacity(0.7), color],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 28,
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                '© 2026 Smart Result Management System',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _analyticsCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withOpacity(0.18)),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const Spacer(),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
