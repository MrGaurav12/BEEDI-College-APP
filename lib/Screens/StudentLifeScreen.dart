// ============================================================
//  StudentLifeScreen.dart
//  BEEDI College – KYP (Kushal Yuva Program) Student Life
//  43+ Features | Firebase Ready | Responsive | Production Grade
// ============================================================
//
// pubspec.yaml dependencies (add these):
// dependencies:
//   firebase_core: ^2.24.2
//   firebase_auth: ^4.16.0
//   cloud_firestore: ^4.14.0
//   firebase_storage: ^11.6.0
//   shared_preferences: ^2.2.2
//   intl: ^0.18.1
//   image_picker: ^1.0.5
//   file_picker: ^6.1.1
//   fl_chart: ^0.66.0
//   pdf: ^3.10.7
//   printing: ^5.11.1
//   flutter_local_notifications: ^16.0.0
//   shimmer: ^3.0.0
//   cached_network_image: ^3.3.0
//   connectivity_plus: ^5.0.2
//   marquee: ^2.2.3
//   table_calendar: ^3.0.9
//   lottie: ^2.7.0
//
// Firebase Security Rules (add in Firebase Console):
// rules_version = '2';
// service cloud.firestore {
//   match /databases/{database}/documents {
//     match /kyp_applications/{userId} {
//       allow read, write: if request.auth != null && request.auth.uid == userId;
//     }
//     match /student_life_activities/{activity} {
//       allow read: if true;
//       allow write: if request.auth != null;
//     }
//     match /kyp_attendance/{userId} { allow read, write: if request.auth.uid == userId; }
//     match /kyp_achievements/{doc}   { allow read: if true; allow write: if request.auth != null; }
//     match /notifications/{doc}      { allow read, write: if request.auth != null; }
//   }
// }
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ── Conditional Firebase imports (comment out if not yet configured) ──────────
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fl_chart/fl_chart.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 0 – CONSTANTS & THEME
// ══════════════════════════════════════════════════════════════════════════════

const kPrimary = Color(0xFF1565C0); // Deep Blue
const kAccent = Color(0xFFFF6F00); // Amber/Orange
const kSuccess = Color(0xFF2E7D32);
const kWarning = Color(0xFFF57F17);
const kError = Color(0xFFC62828);
const kSurface = Color(0xFFF5F7FA);
const kCard = Colors.white;
const kTextDark = Color(0xFF1A237E);
const kTextMed = Color(0xFF455A64);
const kTextLight = Color(0xFF90A4AE);
const kGradStart = Color(0xFF1565C0);
const kGradEnd = Color(0xFF0D47A1);

const List<String> kKypTrades = [
  'IT & ITES',
  'Retail Management',
  'Banking & Finance',
  'Tourism & Hospitality',
  'Healthcare',
  'Electronics',
  'Automobile',
  'Logistics',
];

const Map<String, String> kBatchTimings = {
  'Morning': '7:00 AM – 12:00 PM',
  'Afternoon': '12:00 PM – 5:00 PM',
  'Evening': '5:00 PM – 9:00 PM',
};

const List<String> kQualifications = [
  'Matriculation (10th)',
  'Intermediate (12th)',
  'Diploma',
  'Graduation',
  'Post Graduation',
];

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1 – DATA MODELS
// ══════════════════════════════════════════════════════════════════════════════

class KypApplication {
  String applicationId;
  String name, email, phone, dob, aadhar, gender;
  String qualification, percentage, passingYear, board;
  String trade, trainingMode, batchPreference;
  String status; // pending | approved | rejected | enrolled
  DateTime appliedDate;
  int currentStep;

  KypApplication({
    this.applicationId = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.dob = '',
    this.aadhar = '',
    this.gender = 'Male',
    this.qualification = '',
    this.percentage = '',
    this.passingYear = '',
    this.board = '',
    this.trade = '',
    this.trainingMode = 'Offline',
    this.batchPreference = 'Morning',
    this.status = 'pending',
    DateTime? appliedDate,
    this.currentStep = 0,
  }) : appliedDate = appliedDate ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'applicationId': applicationId,
    'name': name,
    'email': email,
    'phone': phone,
    'dob': dob,
    'aadhar': aadhar,
    'gender': gender,
    'qualification': qualification,
    'percentage': percentage,
    'passingYear': passingYear,
    'board': board,
    'trade': trade,
    'trainingMode': trainingMode,
    'batchPreference': batchPreference,
    'status': status,
    'appliedDate': appliedDate.toIso8601String(),
    'currentStep': currentStep,
  };

  factory KypApplication.fromMap(Map<String, dynamic> m) => KypApplication(
    applicationId: m['applicationId'] ?? '',
    name: m['name'] ?? '',
    email: m['email'] ?? '',
    phone: m['phone'] ?? '',
    dob: m['dob'] ?? '',
    aadhar: m['aadhar'] ?? '',
    gender: m['gender'] ?? 'Male',
    qualification: m['qualification'] ?? '',
    percentage: m['percentage'] ?? '',
    passingYear: m['passingYear'] ?? '',
    board: m['board'] ?? '',
    trade: m['trade'] ?? '',
    trainingMode: m['trainingMode'] ?? 'Offline',
    batchPreference: m['batchPreference'] ?? 'Morning',
    status: m['status'] ?? 'pending',
    appliedDate: DateTime.tryParse(m['appliedDate'] ?? '') ?? DateTime.now(),
    currentStep: m['currentStep'] ?? 0,
  );
}

class CollegeEvent {
  final String id, title, description, venue, category;
  final DateTime date;
  final int maxSeats, registeredCount;
  bool isRegistered;

  CollegeEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.category,
    required this.date,
    this.maxSeats = 100,
    this.registeredCount = 0,
    this.isRegistered = false,
  });
}

class Achievement {
  final String id, title, description, category;
  final DateTime earnedDate;
  int likes;
  bool likedByMe;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.earnedDate,
    this.likes = 0,
    this.likedByMe = false,
  });
}

class AppNotification {
  final String id, title, message;
  final DateTime timestamp;
  bool isRead;
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class AttendanceDay {
  final DateTime date;
  final bool isPresent;
  AttendanceDay({required this.date, required this.isPresent});
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2 – MOCK DATA SERVICE (replace with Firebase calls)
// ══════════════════════════════════════════════════════════════════════════════

class MockDataService {
  static List<CollegeEvent> sampleEvents() {
    final now = DateTime.now();
    return [
      CollegeEvent(
        id: 'e1',
        title: 'KYP Orientation Day',
        description: 'Welcome ceremony for new KYP batch 2024',
        venue: 'Main Auditorium',
        category: 'Orientation',
        date: now.add(const Duration(days: 3)),
        maxSeats: 200,
        registeredCount: 145,
      ),
      CollegeEvent(
        id: 'e2',
        title: 'Resume Building Workshop',
        description: 'Learn to craft a winning resume with HR experts',
        venue: 'Seminar Hall B',
        category: 'Workshop',
        date: now.add(const Duration(days: 7)),
        maxSeats: 60,
        registeredCount: 48,
      ),
      CollegeEvent(
        id: 'e3',
        title: 'Campus Placement Drive – TCS',
        description: 'TCS off-campus drive for IT & ITES batch',
        venue: 'Conference Room',
        category: 'Placement',
        date: now.add(const Duration(days: 12)),
        maxSeats: 80,
        registeredCount: 72,
      ),
      CollegeEvent(
        id: 'e4',
        title: 'Entrepreneurship Summit',
        description: 'Startup ideas & funding opportunities panel',
        venue: 'Open Air Stage',
        category: 'Summit',
        date: now.add(const Duration(days: 18)),
        maxSeats: 500,
        registeredCount: 230,
      ),
      CollegeEvent(
        id: 'e5',
        title: 'Digital Literacy Hackathon',
        description: '24-hour hackathon for KYP students',
        venue: 'Computer Lab Complex',
        category: 'Hackathon',
        date: now.add(const Duration(days: 22)),
        maxSeats: 100,
        registeredCount: 88,
      ),
    ];
  }

  static List<Achievement> sampleAchievements() => [
    Achievement(
      id: 'a1',
      title: 'Best Project – IT Batch',
      description:
          'Awarded best project in IT & ITES trade for inventory management app',
      category: 'Academic',
      earnedDate: DateTime(2024, 3, 10),
      likes: 24,
    ),
    Achievement(
      id: 'a2',
      title: 'District-Level Debate Champion',
      description: 'First prize at Bihar State Yuva Debate Competition',
      category: 'Cultural',
      earnedDate: DateTime(2024, 2, 15),
      likes: 37,
    ),
    Achievement(
      id: 'a3',
      title: 'KYP Topper – Banking Batch',
      description: 'Scored 98/100 in Banking & Finance final assessment',
      category: 'Academic',
      earnedDate: DateTime(2024, 1, 28),
      likes: 19,
    ),
    Achievement(
      id: 'a4',
      title: 'Volunteer of the Month',
      description: 'Led community digital literacy drive in Bhagalpur district',
      category: 'Social',
      earnedDate: DateTime(2024, 3, 1),
      likes: 42,
    ),
  ];

  static List<AppNotification> sampleNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n1',
        title: 'Application Approved!',
        message:
            'Your KYP application KYP-2024-00123 has been approved. Report to college on Monday.',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'n2',
        title: 'Attendance Alert',
        message:
            'Your attendance has dropped below 75%. Please attend classes regularly.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'n3',
        title: 'New Event: Placement Drive',
        message:
            'TCS Campus Placement Drive scheduled on ${DateFormat('d MMM').format(now.add(const Duration(days: 12)))}. Register now!',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        id: 'n4',
        title: 'Fee Payment Reminder',
        message:
            'KYP course fee payment due in 5 days. Pay online to avoid late charges.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }

  static List<AttendanceDay> sampleAttendance() {
    final now = DateTime.now();
    final days = <AttendanceDay>[];
    final rand = Random(42);
    for (int i = 25; i >= 1; i--) {
      final d = now.subtract(Duration(days: i));
      if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
        days.add(
          AttendanceDay(date: d, isPresent: rand.nextBool() || rand.nextBool()),
        );
      }
    }
    return days;
  }

  static List<Map<String, dynamic>> sampleNotices() => [
    {
      'title': 'Mid-term exam schedule released',
      'date': '15 Apr 2024',
      'priority': 'high',
    },
    {
      'title': 'Holiday on 14 April – Dr. Ambedkar Jayanti',
      'date': '12 Apr 2024',
      'priority': 'medium',
    },
    {
      'title': 'Library books submission deadline: 30 April',
      'date': '10 Apr 2024',
      'priority': 'low',
    },
    {
      'title': 'Sports Day registrations open till 20 April',
      'date': '8 Apr 2024',
      'priority': 'medium',
    },
  ];

  static List<Map<String, dynamic>> sampleGrades() => [
    {
      'subject': 'Communication Skills',
      'internal': 38,
      'practical': 45,
      'theory': 72,
      'max': 150,
    },
    {
      'subject': 'IT Fundamentals',
      'internal': 42,
      'practical': 48,
      'theory': 85,
      'max': 175,
    },
    {
      'subject': 'Banking Basics',
      'internal': 35,
      'practical': 40,
      'theory': 68,
      'max': 143,
    },
    {
      'subject': 'Soft Skills',
      'internal': 44,
      'practical': 50,
      'theory': 78,
      'max': 172,
    },
    {
      'subject': 'Project Work',
      'internal': 48,
      'practical': 50,
      'theory': 0,
      'max': 98,
    },
  ];

  static const List<String> motivationalQuotes = [
    '"Education is the most powerful weapon which you can use to change the world." – Nelson Mandela',
    '"The beautiful thing about learning is nobody can take it away from you." – B.B. King',
    '"Success is not final; failure is not fatal: it is the courage to continue that counts." – Churchill',
    '"The secret of getting ahead is getting started." – Mark Twain',
    '"Believe you can and you\'re halfway there." – Theodore Roosevelt',
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3 – MAIN WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class StudentLifeScreen extends StatefulWidget {
  const StudentLifeScreen({super.key});

  @override
  State<StudentLifeScreen> createState() => _StudentLifeScreenState();
}

class _StudentLifeScreenState extends State<StudentLifeScreen>
    with SingleTickerProviderStateMixin {
  // ── Navigation ─────────────────────────────────────────────────────────────
  int _currentTab = 0;
  late PageController _pageController;

  // ── Theme ──────────────────────────────────────────────────────────────────
  bool _isDark = false;

  // ── Data ───────────────────────────────────────────────────────────────────
  List<CollegeEvent> _events = [];
  List<Achievement> _achievements = [];
  List<AppNotification> _notifications = [];
  List<AttendanceDay> _attendance = [];
  List<Map<String, dynamic>> _notices = [];
  List<Map<String, dynamic>> _grades = [];
  KypApplication? _application;
  bool _isLoading = true;
  bool _isOnline = true;

  // ── Profile ─────────────────────────────────────────────────────────────────
  String _studentName = 'Rahul Kumar';
  String _studentEmail = 'rahul.kumar@beedicollege.ac.in';
  String _studentPhone = '9876543210';
  String _studentBatch = 'IT & ITES – Morning Batch';
  String _rollNumber = 'KYP-2024-00123';
  double _attendancePct = 78.5;
  bool _profilePublic = true;
  bool _largeText = false;

  // ── Announcement marquee ───────────────────────────────────────────────────
  final List<String> _announcements = [
    '📢 Mid-term examinations scheduled from 15 May 2024',
    '🏆 KYP Batch 2024 Topper List published – Check Notice Board',
    '📝 Last date for document submission: 25 April 2024',
    '🎉 Congratulations to all KYP students selected in TCS Campus Drive!',
  ];
  int _announcementIndex = 0;
  Timer? _announcementTimer;

  // ── Auto-save draft timer ──────────────────────────────────────────────────
  Timer? _autoSaveTimer;
  String _autoSaveStatus = '';

  // ── Notification badge ─────────────────────────────────────────────────────
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
    _startAnnouncementTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _announcementTimer?.cancel();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  // ── FEATURE 41 & 42: Load data (Firestore / offline cache) ─────────────────
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simulate network fetch (replace with Firestore calls)
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _events = MockDataService.sampleEvents();
      _achievements = MockDataService.sampleAchievements();
      _notifications = MockDataService.sampleNotifications();
      _attendance = MockDataService.sampleAttendance();
      _notices = MockDataService.sampleNotices();
      _grades = MockDataService.sampleGrades();
      _isLoading = false;
    });
  }

  // ── FEATURE 43: Announcement marquee timer ─────────────────────────────────
  void _startAnnouncementTimer() {
    _announcementTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        _announcementIndex = (_announcementIndex + 1) % _announcements.length;
      });
    });
  }

  // ── FEATURE: Auto-save draft to Firestore ──────────────────────────────────
  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_application == null) return;
      // TODO: await FirebaseFirestore.instance.collection('kyp_applications').doc(uid).set(_application!.toMap(), SetOptions(merge: true));
      if (!mounted) return;
      setState(
        () => _autoSaveStatus =
            'Draft saved at ${DateFormat('hh:mm a').format(DateTime.now())}',
      );
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _autoSaveStatus = '');
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = _isDark ? _darkTheme() : _lightTheme();
    return Theme(
      data: theme,
      child: Builder(
        builder: (ctx) {
          final width = MediaQuery.of(ctx).size.width;
          final isTablet = width >= 600 && width < 1200;
          final isDesktop = width >= 1200;

          return Scaffold(
            backgroundColor: _isDark ? const Color(0xFF0D1117) : kSurface,
            // FEATURE 29: Announcement Banner
            appBar: _buildAppBar(ctx),
            // FEATURE 36: Responsive layout
            body: isDesktop
                ? _desktopLayout(ctx)
                : Column(
                    children: [
                      _announcementBanner(),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: _buildPages(ctx, isTablet),
                        ),
                      ),
                    ],
                  ),
            // FEATURE 37: Bottom Navigation Bar (5 items)
            bottomNavigationBar: isDesktop ? null : _buildBottomNav(ctx),
          );
        },
      ),
    );
  }

  // ── AppBar (FEATURE 1 – custom appbar with logo + notif bell) ────────────
  PreferredSizeWidget _buildAppBar(BuildContext ctx) {
    return AppBar(
      backgroundColor: kGradStart,
      elevation: 0,
      titleSpacing: 8,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          'assets/Logoes/Logo.png',
          errorBuilder: (_, __, ___) => const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Text(
              'BC',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KYP Student Life',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            _studentBatch,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
      actions: [
        // FEATURE 38: Dark/Light toggle
        IconButton(
          icon: Icon(
            _isDark ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: () => setState(() => _isDark = !_isDark),
          tooltip: 'Toggle Theme',
        ),
        // FEATURE 26: Notification bell with badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () => _showNotificationsSheet(ctx),
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$_unreadCount',
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
        // Online indicator
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(
            _isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: _isOnline ? Colors.greenAccent : Colors.red,
            size: 18,
          ),
        ),
      ],
    );
  }

  // ── FEATURE 29: Marquee Announcement Banner ───────────────────────────────
  Widget _announcementBanner() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Container(
        key: ValueKey(_announcementIndex),
        width: double.infinity,
        color: kAccent.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Text(
          _announcements[_announcementIndex],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext ctx) {
    const items = [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Apply'),
      BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Activities'),
      BottomNavigationBarItem(
        icon: Icon(Icons.emoji_events),
        label: 'Achievements',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
    return BottomNavigationBar(
      currentIndex: _currentTab,
      onTap: (i) {
        setState(() => _currentTab = i);
        _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      selectedItemColor: kPrimary,
      unselectedItemColor: kTextLight,
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }

  // ── Desktop layout with side drawer ──────────────────────────────────────
  Widget _desktopLayout(BuildContext ctx) {
    return Row(
      children: [
        _desktopSideNav(ctx),
        Expanded(
          child: Column(
            children: [
              _announcementBanner(),
              Expanded(child: _buildPageContent(ctx, _currentTab, true)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _desktopSideNav(BuildContext ctx) {
    final items = [
      ('Dashboard', Icons.dashboard),
      ('Apply KYP', Icons.assignment),
      ('Activities', Icons.event),
      ('Achievements', Icons.emoji_events),
      ('Profile', Icons.person),
    ];
    return Container(
      width: 220,
      color: kGradStart,
      child: Column(
        children: [
          const SizedBox(height: 24),
          ...items.asMap().entries.map((e) {
            final selected = _currentTab == e.key;
            return ListTile(
              leading: Icon(
                e.value.$2,
                color: selected ? Colors.white : Colors.white60,
              ),
              title: Text(
                e.value.$1,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white60,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              tileColor: selected ? Colors.white12 : null,
              onTap: () => setState(() => _currentTab = e.key),
            );
          }),
        ],
      ),
    );
  }

  // ── Pages ─────────────────────────────────────────────────────────────────
  List<Widget> _buildPages(BuildContext ctx, bool isTablet) => [
    _buildPageContent(ctx, 0, isTablet),
    _buildPageContent(ctx, 1, isTablet),
    _buildPageContent(ctx, 2, isTablet),
    _buildPageContent(ctx, 3, isTablet),
    _buildPageContent(ctx, 4, isTablet),
  ];

  Widget _buildPageContent(BuildContext ctx, int tab, bool wide) {
    switch (tab) {
      case 0:
        return _DashboardPage(
          student: _studentName,
          roll: _rollNumber,
          attendance: _attendancePct,
          events: _events,
          notices: _notices,
          notifications: _notifications,
          isLoading: _isLoading,
          wide: wide,
          isDark: _isDark,
          onRefresh: _loadData,
          quote:
              MockDataService.motivationalQuotes[DateTime.now().day %
                  MockDataService.motivationalQuotes.length],
        );
      case 1:
        return _ApplicationPage(
          application: _application,
          onApplicationChanged: (a) {
            setState(() => _application = a);
            _startAutoSave();
          },
          autoSaveStatus: _autoSaveStatus,
          onOtpSuccess: () {},
          isDark: _isDark,
        );
      case 2:
        return _ActivitiesPage(
          events: _events,
          attendance: _attendance,
          grades: _grades,
          isLoading: _isLoading,
          wide: wide,
          isDark: _isDark,
          onEventRegister: (e) {
            setState(() {
              e.isRegistered = !e.isRegistered;
            });
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(
                  e.isRegistered
                      ? '✅ Registered for ${e.title}'
                      : 'Registration cancelled',
                ),
                backgroundColor: e.isRegistered ? kSuccess : kError,
              ),
            );
          },
        );
      case 3:
        return _AchievementsPage(
          achievements: _achievements,
          isDark: _isDark,
          onLike: (a) => setState(() {
            a.likedByMe = !a.likedByMe;
            a.likes += a.likedByMe ? 1 : -1;
          }),
          onAdd: () => _showAddAchievementDialog(ctx),
        );
      case 4:
        return _ProfilePage(
          name: _studentName,
          email: _studentEmail,
          phone: _studentPhone,
          batch: _studentBatch,
          roll: _rollNumber,
          isDark: _isDark,
          profilePublic: _profilePublic,
          largeText: _largeText,
          onPublicToggle: (v) => setState(() => _profilePublic = v),
          onLargeTextToggle: (v) => setState(() => _largeText = v),
          onEdit: () => _showEditProfileDialog(ctx),
          onExport: () => _exportData(),
          attendance: _attendance,
        );
      default:
        return const SizedBox();
    }
  }

  // ── FEATURE 26: Notifications Sheet ──────────────────────────────────────
  void _showNotificationsSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: _isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _isDark ? Colors.white : kTextDark,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var n in _notifications) n.isRead = true;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Mark all read'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (_, i) {
                final n = _notifications[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: n.isRead
                        ? Colors.grey.shade200
                        : kPrimary.withOpacity(0.15),
                    child: Icon(
                      Icons.notifications,
                      color: n.isRead ? Colors.grey : kPrimary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: _isDark ? Colors.white : kTextDark,
                    ),
                  ),
                  subtitle: Text(
                    n.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _isDark ? Colors.white60 : kTextMed,
                    ),
                  ),
                  trailing: Text(
                    DateFormat('d MMM').format(n.timestamp),
                    style: const TextStyle(fontSize: 11, color: kTextLight),
                  ),
                  onTap: () => setState(() => n.isRead = true),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── FEATURE 16/37: Add Achievement ────────────────────────────────────────
  void _showAddAchievementDialog(BuildContext ctx) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Academic';
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Add Achievement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: category,
              items: [
                'Academic',
                'Cultural',
                'Sports',
                'Social',
                'Technical',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => category = v!,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              setState(() {
                _achievements.insert(
                  0,
                  Achievement(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    category: category,
                    earnedDate: DateTime.now(),
                  ),
                );
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('✅ Achievement added!'),
                  backgroundColor: kSuccess,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ── FEATURE 31: Edit Profile ──────────────────────────────────────────────
  void _showEditProfileDialog(BuildContext ctx) {
    final nameCtrl = TextEditingController(text: _studentName);
    final phoneCtrl = TextEditingController(text: _studentPhone);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _studentName = nameCtrl.text.trim();
                _studentPhone = phoneCtrl.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('✅ Profile updated!'),
                  backgroundColor: kSuccess,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── FEATURE 35: Export Data ────────────────────────────────────────────────
  void _exportData() {
    final data = {
      'student': {
        'name': _studentName,
        'email': _studentEmail,
        'roll': _rollNumber,
      },
      'attendance': _attendance
          .map(
            (a) => {
              'date': DateFormat('yyyy-MM-dd').format(a.date),
              'present': a.isPresent,
            },
          )
          .toList(),
      'achievements': _achievements
          .map((a) => {'title': a.title, 'category': a.category})
          .toList(),
    };
    final json = const JsonEncoder.withIndent('  ').convert(data);
    // In production: use path_provider to save file or share_plus to share
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Data exported (JSON ready for download)'),
        backgroundColor: kSuccess,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Exported Data'),
                content: SingleChildScrollView(
                  child: Text(
                    json,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Themes ─────────────────────────────────────────────────────────────────
  ThemeData _lightTheme() => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
    useMaterial3: true,
cardTheme: const CardThemeData(
  color: Color(0xFF1E293B),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
  ),
),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey.shade50,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
  );

  ThemeData _darkTheme() => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0D1117),
cardTheme: const CardThemeData(
  color: Color(0xFF1E293B),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
  ),
),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4 – DASHBOARD PAGE
// ══════════════════════════════════════════════════════════════════════════════

class _DashboardPage extends StatelessWidget {
  final String student, roll, quote;
  final double attendance;
  final List<CollegeEvent> events;
  final List<Map<String, dynamic>> notices;
  final List<AppNotification> notifications;
  final bool isLoading, wide, isDark;
  final Future<void> Function() onRefresh;

  const _DashboardPage({
    required this.student,
    required this.roll,
    required this.attendance,
    required this.events,
    required this.notices,
    required this.notifications,
    required this.isLoading,
    required this.wide,
    required this.isDark,
    required this.onRefresh,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    // FEATURE 42: Pull to Refresh
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: isLoading
          ? _ShimmerLoader(isDark: isDark)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _greetingCard(),
                const SizedBox(height: 16),
                // FEATURE 18: Daily Motivation
                _motivationCard(),
                const SizedBox(height: 16),
                // FEATURE 1 (dashboard cards)
                _dashboardStatsRow(),
                const SizedBox(height: 20),
                _sectionHeader('📅 Upcoming Events'),
                const SizedBox(height: 8),
                ...events.take(3).map(_eventCard),
                const SizedBox(height: 20),
                _sectionHeader('📋 Notice Board'),
                const SizedBox(height: 8),
                ...notices.map(_noticeItem),
                const SizedBox(height: 20),
                // FEATURE 19: KYP Batch Overview
                _batchOverviewCard(),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _greetingCard() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kGradStart, kGradEnd]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, ${student.split(' ').first}! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Roll: $roll',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                const Text(
                  'KYP Batch 2024 · Active',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _motivationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                quote,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : kTextMed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardStatsRow() {
    final stats = [
      ('Application', 'Approved', Icons.check_circle, kSuccess),
      (
        'Attendance',
        '${attendance.toStringAsFixed(1)}%',
        Icons.calendar_today,
        attendance >= 75 ? kSuccess : kError,
      ),
      ('Pending Tasks', '3', Icons.pending_actions, kWarning),
      ('Certificates', '2', Icons.card_membership, kPrimary),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: stats
          .map(
            (s) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: s.$4.withOpacity(0.15),
                      child: Icon(s.$3, color: s.$4, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.$1,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white54 : kTextLight,
                            ),
                          ),
                          Text(
                            s.$2,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : kTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _eventCard(CollegeEvent e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimary.withOpacity(0.1),
          child: Text(
            e.category[0],
            style: const TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          e.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
        subtitle: Text(
          '${e.venue} · ${DateFormat('d MMM, hh:mm a').format(e.date)}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Text(
          '${e.maxSeats - e.registeredCount} seats',
          style: TextStyle(
            fontSize: 11,
            color: (e.maxSeats - e.registeredCount) < 10 ? kError : kSuccess,
          ),
        ),
      ),
    );
  }

  Widget _noticeItem(Map<String, dynamic> n) {
    final colors = {'high': kError, 'medium': kWarning, 'low': kSuccess};
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.circle,
          size: 10,
          color: colors[n['priority']] ?? kTextLight,
        ),
        title: Text(
          n['title'],
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
        trailing: Text(
          n['date'],
          style: const TextStyle(fontSize: 11, color: kTextLight),
        ),
      ),
    );
  }

  Widget _batchOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎓 KYP Batch Overview',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const Divider(height: 20),
            _batchRow('Trade', 'IT & ITES'),
            _batchRow('Batch', 'Morning (7AM–12PM)'),
            _batchRow('Trainer', 'Prof. Anjali Singh'),
            _batchRow('Duration', '6 months (Jan–Jun 2024)'),
            _batchRow('Mode', 'Offline + Practical'),
            const SizedBox(height: 12),
            Text(
              'Syllabus Progress',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : kTextMed,
              ),
            ),
            const SizedBox(height: 8),
            _progressRow('Communication Skills', 0.85),
            _progressRow('IT Fundamentals', 0.70),
            _progressRow('Soft Skills', 0.60),
            _progressRow('Project Work', 0.40),
          ],
        ),
      ),
    );
  }

  Widget _batchRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            k,
            style: const TextStyle(color: kTextLight, fontSize: 12),
          ),
        ),
        Text(
          v,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
      ],
    ),
  );

  Widget _progressRow(String label, double val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              '${(val * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              val >= 0.75 ? kSuccess : kPrimary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _sectionHeader(String t) => Text(
    t,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: isDark ? Colors.white : kTextDark,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5 – APPLICATION PAGE (10 features)
// ══════════════════════════════════════════════════════════════════════════════

class _ApplicationPage extends StatefulWidget {
  final KypApplication? application;
  final ValueChanged<KypApplication> onApplicationChanged;
  final String autoSaveStatus;
  final VoidCallback onOtpSuccess;
  final bool isDark;

  const _ApplicationPage({
    required this.application,
    required this.onApplicationChanged,
    required this.autoSaveStatus,
    required this.onOtpSuccess,
    required this.isDark,
  });

  @override
  State<_ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<_ApplicationPage> {
  late KypApplication _app;
  int _step = 0;
  bool _submitted = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _isSubmitting = false;
  bool _eligibilityOk = true;
  final _otpController = TextEditingController();
  final _mockOtp = '123456';
  final _formKey = GlobalKey<FormState>();

  // Step controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _aadharCtrl = TextEditingController();
  final _pctCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _boardCtrl = TextEditingController();

  String _gender = 'Male';
  String _qual = kQualifications.first;
  String _trade = kKypTrades.first;
  String _mode = 'Offline';
  String _batch = 'Morning';

  final List<String> _statusStages = [
    'Applied',
    'Documents Verified',
    'Interview Scheduled',
    'Selected',
    'Enrolled',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.application != null) {
      final a = widget.application!;
      _app = a;
      _step = a.currentStep;
      _nameCtrl.text = a.name;
      _emailCtrl.text = a.email;
      _phoneCtrl.text = a.phone;
      _dobCtrl.text = a.dob;
      _aadharCtrl.text = a.aadhar;
      _gender = a.gender;
      _qual = a.qualification.isEmpty ? kQualifications.first : a.qualification;
      _pctCtrl.text = a.percentage;
      _yearCtrl.text = a.passingYear;
      _boardCtrl.text = a.board;
      _trade = a.trade.isEmpty ? kKypTrades.first : a.trade;
      _mode = a.trainingMode;
      _batch = a.batchPreference;
      _submitted = a.status != 'pending' || a.applicationId.isNotEmpty;
    } else {
      _app = KypApplication();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _aadharCtrl.dispose();
    _pctCtrl.dispose();
    _yearCtrl.dispose();
    _boardCtrl.dispose();
    super.dispose();
  }

  void _saveStep() {
    _app
      ..name = _nameCtrl.text.trim()
      ..email = _emailCtrl.text.trim()
      ..phone = _phoneCtrl.text.trim()
      ..dob = _dobCtrl.text.trim()
      ..aadhar = _aadharCtrl.text.trim()
      ..gender = _gender
      ..qualification = _qual
      ..percentage = _pctCtrl.text.trim()
      ..passingYear = _yearCtrl.text.trim()
      ..board = _boardCtrl.text.trim()
      ..trade = _trade
      ..trainingMode = _mode
      ..batchPreference = _batch
      ..currentStep = _step;
    widget.onApplicationChanged(_app);
  }

  // FEATURE 5: Eligibility Check
  void _checkEligibility() {
    final pct = double.tryParse(_pctCtrl.text) ?? 0;
    setState(() => _eligibilityOk = pct >= 50);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted && _app.applicationId.isNotEmpty) {
      return _buildStatusTracker();
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.autoSaveStatus.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kSuccess.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '💾 ${widget.autoSaveStatus}',
              style: const TextStyle(color: kSuccess, fontSize: 12),
            ),
          ),
        _stepIndicator(),
        const SizedBox(height: 20),
        Form(key: _formKey, child: _buildStep()),
        const SizedBox(height: 20),
        _stepButtons(),
      ],
    );
  }

  // FEATURE 6: Visual Application Status Timeline
  Widget _buildStatusTracker() {
    final statusMap = {
      'pending': 0,
      'documents_verified': 1,
      'interview_scheduled': 2,
      'selected': 3,
      'enrolled': 4,
      'approved': 4,
    };
    final currentStageIndex = statusMap[_app.status] ?? 0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application Submitted ✅',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: widget.isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Application ID: ${_app.applicationId}',
                  style: const TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Applied on: ${DateFormat('d MMM yyyy').format(_app.appliedDate)}',
                  style: const TextStyle(color: kTextLight, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Application Progress',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 16),
                ..._statusStages.asMap().entries.map((e) {
                  final done = e.key <= currentStageIndex;
                  final active = e.key == currentStageIndex;
                  return Row(
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: done
                                ? kSuccess
                                : Colors.grey.shade300,
                            child: Icon(
                              done ? Icons.check : Icons.circle,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          if (e.key < _statusStages.length - 1)
                            Container(
                              width: 2,
                              height: 30,
                              color: done ? kSuccess : Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        e.value,
                        style: TextStyle(
                          fontWeight: active
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: active
                              ? kSuccess
                              : (widget.isDark ? Colors.white60 : kTextMed),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // FEATURE 8: Download PDF (simulated)
        ElevatedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📄 Application PDF downloaded!'),
              backgroundColor: kSuccess,
            ),
          ),
          icon: const Icon(Icons.download),
          label: const Text('Download Application PDF'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _submitted = false;
            _app.applicationId = '';
            _app.status = 'pending';
          }),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Application'),
        ),
      ],
    );
  }

  // FEATURE 1: Step indicator
  Widget _stepIndicator() {
    const steps = ['Personal', 'Academic', 'KYP Program', 'Documents'];
    return Row(
      children: steps.asMap().entries.map((e) {
        final active = e.key == _step;
        final done = e.key < _step;
        return Expanded(
          child: Row(
            children: [
              if (e.key > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: done ? kSuccess : Colors.grey.shade300,
                  ),
                ),
              CircleAvatar(
                radius: 14,
                backgroundColor: done
                    ? kSuccess
                    : active
                    ? kPrimary
                    : Colors.grey.shade300,
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${e.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
              ),
              if (e.key < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: done ? kSuccess : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _step1Personal();
      case 1:
        return _step2Academic();
      case 2:
        return _step3Kyp();
      case 3:
        return _step4Documents();
      default:
        return const SizedBox();
    }
  }

  // FEATURE 1 Step 1: Personal Details
  Widget _step1Personal() {
    return Column(
      children: [
        _field(
          'Full Name',
          _nameCtrl,
          validator: (v) =>
              (v == null || v.trim().length < 3) ? 'Enter valid name' : null,
        ),
        _field(
          'Email',
          _emailCtrl,
          type: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || !v.contains('@')) return 'Enter valid email';
            return null;
          },
        ),
        // FEATURE 4: Aadhar + OTP Verification
        _field(
          'Aadhar Number',
          _aadharCtrl,
          type: TextInputType.number,
          maxLen: 12,
          validator: (v) {
            if (v == null || v.length != 12) return 'Aadhar must be 12 digits';
            if (v[0] == '0' || v[0] == '1') return 'Invalid Aadhar';
            return null;
          },
        ),
        if (!_otpVerified)
          Column(
            children: [
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  if (_phoneCtrl.text.length < 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter phone first')),
                    );
                    return;
                  }
                  setState(() => _otpSent = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP sent! Use 123456 for demo'),
                      backgroundColor: kPrimary,
                    ),
                  );
                },
                icon: const Icon(Icons.sms),
                label: const Text('Send OTP to verify Aadhar'),
                style: ElevatedButton.styleFrom(backgroundColor: kAccent),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 8),
                _field(
                  'Enter OTP',
                  _otpController,
                  maxLen: 6,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_otpController.text == _mockOtp) {
                      setState(() => _otpVerified = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Aadhar verified!'),
                          backgroundColor: kSuccess,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Wrong OTP'),
                          backgroundColor: kError,
                        ),
                      );
                    }
                  },
                  child: const Text('Verify OTP'),
                ),
              ],
            ],
          )
        else
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.verified, color: kSuccess, size: 16),
                SizedBox(width: 4),
                Text(
                  'Aadhar Verified',
                  style: TextStyle(color: kSuccess, fontSize: 12),
                ),
              ],
            ),
          ),
        // FEATURE: Phone
        _field(
          'Phone Number',
          _phoneCtrl,
          type: TextInputType.phone,
          maxLen: 10,
          validator: (v) {
            if (v == null || v.length != 10) return 'Phone must be 10 digits';
            if (!RegExp(r'^[6-9]').hasMatch(v)) return 'Must start with 6-9';
            return null;
          },
        ),
        _field('Date of Birth (DD/MM/YYYY)', _dobCtrl),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _gender,
          items: [
            'Male',
            'Female',
            'Other',
          ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _gender = v!),
          decoration: const InputDecoration(labelText: 'Gender'),
        ),
      ],
    );
  }

  // FEATURE 1 Step 2: Academic Details
  Widget _step2Academic() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _qual,
          items: kQualifications
              .map((q) => DropdownMenuItem(value: q, child: Text(q)))
              .toList(),
          onChanged: (v) => setState(() => _qual = v!),
          decoration: const InputDecoration(labelText: 'Highest Qualification'),
        ),
        const SizedBox(height: 12),
        _field(
          'Percentage / CGPA',
          _pctCtrl,
          type: TextInputType.number,
          onChanged: (_) => _checkEligibility(),
          validator: (v) {
            final pct = double.tryParse(v ?? '');
            if (pct == null) return 'Enter valid percentage';
            if (pct < 0 || pct > 100) return 'Must be 0–100';
            return null;
          },
        ),
        // FEATURE 5: Eligibility indicator
        if (_pctCtrl.text.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _eligibilityOk
                  ? kSuccess.withOpacity(0.1)
                  : kError.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _eligibilityOk ? Icons.check_circle : Icons.cancel,
                  color: _eligibilityOk ? kSuccess : kError,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _eligibilityOk
                      ? 'Eligible for KYP (≥50%)'
                      : 'Not eligible – Minimum 50% required',
                  style: TextStyle(
                    color: _eligibilityOk ? kSuccess : kError,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        _field(
          'Passing Year',
          _yearCtrl,
          type: TextInputType.number,
          maxLen: 4,
        ),
        _field('Board / University', _boardCtrl),
      ],
    );
  }

  // FEATURE 1 Step 3: KYP Program Details
  Widget _step3Kyp() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _trade,
          items: kKypTrades
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _trade = v!),
          decoration: const InputDecoration(labelText: 'Select Trade'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _mode,
          items: [
            'Offline',
            'Online',
            'Hybrid',
          ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (v) => setState(() => _mode = v!),
          decoration: const InputDecoration(labelText: 'Training Mode'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _batch,
          items: kBatchTimings.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text('${e.key}: ${e.value}'),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _batch = v!),
          decoration: const InputDecoration(labelText: 'Batch Preference'),
        ),
        const SizedBox(height: 12),
        Card(
          color: kPrimary.withOpacity(0.07),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Trade Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Trade: $_trade', style: const TextStyle(fontSize: 13)),
                Text('Mode: $_mode', style: const TextStyle(fontSize: 13)),
                Text(
                  'Batch: $_batch (${kBatchTimings[_batch]})',
                  style: const TextStyle(fontSize: 13),
                ),
                const Text(
                  'Duration: 6 Months',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // FEATURE 1 Step 4: Document Upload
  Widget _step4Documents() {
    final docs = [
      ('Passport Photo', Icons.photo_camera, '< 5MB, JPG/PNG'),
      ('Signature', Icons.draw, '< 2MB, JPG/PNG'),
      ('10th Marksheet', Icons.description, '< 5MB, PDF/JPG'),
      ('12th Marksheet', Icons.description, '< 5MB, PDF/JPG'),
      ('Aadhar Card', Icons.badge, '< 2MB, PDF/JPG'),
    ];
    return Column(
      children: [
        ...docs.map(
          (d) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(d.$2, color: kPrimary),
              title: Text(d.$1),
              subtitle: Text(
                d.$3,
                style: const TextStyle(fontSize: 11, color: kTextLight),
              ),
              trailing: ElevatedButton.icon(
                onPressed: () {
                  // TODO: await ImagePicker().pickImage(source: ImageSource.gallery);
                  // Then upload to Firebase Storage
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '📎 ${d.$1} upload simulated (Firebase Storage)',
                      ),
                      backgroundColor: kSuccess,
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file, size: 14),
                label: const Text('Upload', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ),
          ),
        ),
        // FEATURE 9: Fee payment
        const SizedBox(height: 8),
        Card(
          color: kAccent.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.payment, color: kAccent),
                    SizedBox(width: 8),
                    Text(
                      'Application Fee: ₹500',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '🔒 Redirecting to Razorpay gateway...',
                                ),
                                backgroundColor: kPrimary,
                              ),
                            ),
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text('Pay Online'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepButtons() {
    return Row(
      children: [
        if (_step > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() {
                _saveStep();
                _step--;
              }),
              child: const Text('← Back'),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    if (_formKey.currentState?.validate() == false) return;
                    _saveStep();
                    if (_step < 3) {
                      setState(() => _step++);
                    } else {
                      _submitApplication();
                    }
                  },
            child: _isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(_step < 3 ? 'Next →' : '📤 Submit Application'),
          ),
        ),
      ],
    );
  }

  // FEATURE 10: Application Number Generation + Submission
  Future<void> _submitApplication() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    // TODO: FirebaseFirestore.instance.collection('kyp_applications').doc(uid).set(_app.toMap());
    final appId =
        'KYP-${DateTime.now().year}-${(10000 + Random().nextInt(89999)).toString()}';
    setState(() {
      _app.applicationId = appId;
      _app.status = 'pending';
      _submitted = true;
      _isSubmitting = false;
    });
    widget.onApplicationChanged(_app);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Application submitted! ID: $appId'),
        backgroundColor: kSuccess,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType? type,
    int? maxLen,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLength: maxLen,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(labelText: label, counterText: ''),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 6 – ACTIVITIES PAGE (8 features)
// ══════════════════════════════════════════════════════════════════════════════

class _ActivitiesPage extends StatefulWidget {
  final List<CollegeEvent> events;
  final List<AttendanceDay> attendance;
  final List<Map<String, dynamic>> grades;
  final bool isLoading, wide, isDark;
  final void Function(CollegeEvent) onEventRegister;

  const _ActivitiesPage({
    required this.events,
    required this.attendance,
    required this.grades,
    required this.isLoading,
    required this.wide,
    required this.isDark,
    required this.onEventRegister,
  });

  @override
  State<_ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<_ActivitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tab,
          labelColor: kPrimary,
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Attendance'),
            Tab(text: 'Grades'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [_eventsTab(), _attendanceTab(), _gradesTab()],
          ),
        ),
      ],
    );
  }

  // FEATURE 11 & 12: Events + Registration
  Widget _eventsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.events.length,
      itemBuilder: (_, i) {
        final e = widget.events[i];
        final seatsLeft = e.maxSeats - e.registeredCount;
        const catColors = {
          'Placement': kSuccess,
          'Workshop': kPrimary,
          'Hackathon': kAccent,
          'Orientation': kWarning,
          'Summit': Colors.purple,
        };
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: catColors[e.category] ?? kPrimary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: widget.isDark ? Colors.white : kTextDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (catColors[e.category] ?? kPrimary)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            e.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: catColors[e.category] ?? kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      e.description,
                      style: const TextStyle(fontSize: 12, color: kTextMed),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: kTextLight,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          e.venue,
                          style: const TextStyle(fontSize: 12, color: kTextMed),
                        ),
                        const Spacer(),
                        const Icon(Icons.event, size: 13, color: kTextLight),
                        const SizedBox(width: 3),
                        Text(
                          DateFormat('d MMM, hh:mm a').format(e.date),
                          style: const TextStyle(fontSize: 12, color: kTextMed),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$seatsLeft seats left',
                          style: TextStyle(
                            fontSize: 12,
                            color: seatsLeft < 15 ? kError : kSuccess,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: seatsLeft == 0 && !e.isRegistered
                              ? null
                              : () {
                                  setState(() => widget.onEventRegister(e));
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: e.isRegistered
                                ? kSuccess
                                : kPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            e.isRegistered ? '✅ Registered' : 'Register',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
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

  // FEATURE 13 & 14: Attendance Tracker + Analytics
  Widget _attendanceTab() {
    final present = widget.attendance.where((a) => a.isPresent).length;
    final total = widget.attendance.length;
    final pct = total == 0 ? 0.0 : (present / total * 100);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Monthly Attendance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _attendanceStat('Present', '$present', kSuccess),
                    _attendanceStat('Absent', '${total - present}', kError),
                    _attendanceStat(
                      'Percentage',
                      '${pct.toStringAsFixed(1)}%',
                      pct >= 75 ? kSuccess : kError,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct >= 75 ? kSuccess : kError,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pct >= 75
                      ? '✅ Attendance is satisfactory'
                      : '⚠️ Attendance below 75% – Risk of de-registration',
                  style: TextStyle(
                    fontSize: 11,
                    color: pct >= 75 ? kSuccess : kError,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Calendar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: widget.attendance
                      .map(
                        (a) => Tooltip(
                          message:
                              '${DateFormat('d MMM').format(a.date)}: ${a.isPresent ? 'Present' : 'Absent'}',
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: a.isPresent
                                  ? kSuccess.withOpacity(0.8)
                                  : kError.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '${a.date.day}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _legendDot(kSuccess, 'Present'),
                    const SizedBox(width: 12),
                    _legendDot(kError.withOpacity(0.4), 'Absent'),
                  ],
                ),
              ],
            ),
          ),
        ),
        // FEATURE 14: Simple analytics chart (bar visualization)
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Attendance Trend',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 12),
                _simpleBarChart(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // FEATURE 22: Grades / Marks
  Widget _gradesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assessment Marks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2.5),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                  },
                  children: [
                    _tableHeader(['Subject', 'Int.', 'Prac.', 'Theory']),
                    ...widget.grades.map((g) {
                      final total =
                          g['internal'] + g['practical'] + g['theory'];
                      final maxT = g['max'];
                      final grade = total / maxT >= 0.85
                          ? 'A+'
                          : total / maxT >= 0.75
                          ? 'A'
                          : total / maxT >= 0.60
                          ? 'B'
                          : 'C';
                      return TableRow(
                        decoration: BoxDecoration(
                          color: grade == 'A+'
                              ? kSuccess.withOpacity(0.05)
                              : null,
                        ),
                        children: [
                          _tableCell('${g['subject']} [$grade]', bold: true),
                          _tableCell('${g['internal']}'),
                          _tableCell('${g['practical']}'),
                          _tableCell('${g['theory']}'),
                        ],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${widget.grades.fold<int>(0, (s, g) => s + (g['internal'] as int) + (g['practical'] as int) + (g['theory'] as int))} / '
                  '${widget.grades.fold<int>(0, (s, g) => s + (g['max'] as int))}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // FEATURE 24: Feedback / rating
        const SizedBox(height: 16),
        _feedbackCard(),
      ],
    );
  }

  Widget _feedbackCard() {
    int _rating = 4;
    return StatefulBuilder(
      builder: (ctx, set) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📝 Rate Your Trainer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () => set(() => _rating = i + 1),
                      child: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        color: kAccent,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Save to Firestore
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Feedback submitted!'),
                        backgroundColor: kSuccess,
                      ),
                    );
                  },
                  child: const Text('Submit Feedback'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _simpleBarChart() {
    // Group attendance by week
    final weeks = <String, List<bool>>{};
    for (final a in widget.attendance) {
      final wk = 'Wk ${((a.date.day - 1) ~/ 7) + 1}';
      weeks.putIfAbsent(wk, () => []).add(a.isPresent);
    }
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeks.entries.map((e) {
          final pct = e.value.isEmpty
              ? 0.0
              : e.value.where((b) => b).length / e.value.length;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${(pct * 100).toInt()}%',
                  style: const TextStyle(fontSize: 9, color: kTextLight),
                ),
                const SizedBox(height: 2),
                Container(
                  height: 60 * pct,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: pct >= 0.75 ? kSuccess : kError,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  e.key,
                  style: const TextStyle(fontSize: 9, color: kTextLight),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _attendanceStat(String label, String val, Color color) => Column(
    children: [
      Text(
        val,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: color,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 11, color: kTextLight)),
    ],
  );

  Widget _legendDot(Color c, String label) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );

  TableRow _tableHeader(List<String> cells) => TableRow(
    decoration: BoxDecoration(color: kPrimary.withOpacity(0.1)),
    children: cells
        .map(
          (c) => Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              c,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: kPrimary,
              ),
            ),
          ),
        )
        .toList(),
  );

  Widget _tableCell(String t, {bool bold = false}) => Padding(
    padding: const EdgeInsets.all(6),
    child: Text(
      t,
      style: TextStyle(
        fontSize: 11,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 7 – ACHIEVEMENTS PAGE
// ══════════════════════════════════════════════════════════════════════════════

class _AchievementsPage extends StatelessWidget {
  final List<Achievement> achievements;
  final bool isDark;
  final void Function(Achievement) onLike;
  final VoidCallback onAdd;

  const _AchievementsPage({
    required this.achievements,
    required this.isDark,
    required this.onLike,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    const catColors = {
      'Academic': kPrimary,
      'Cultural': Colors.purple,
      'Sports': kAccent,
      'Social': kSuccess,
      'Technical': Colors.teal,
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAdd,
        backgroundColor: kPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Achievement',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, i) {
          final a = achievements[i];
          final color = catColors[a.category] ?? kPrimary;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withOpacity(0.15),
                        child: Icon(Icons.emoji_events, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : kTextDark,
                              ),
                            ),
                            Text(
                              a.category,
                              style: TextStyle(fontSize: 11, color: color),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateFormat('d MMM yy').format(a.earnedDate),
                          style: TextStyle(fontSize: 10, color: color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    a.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : kTextMed,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // FEATURE 17: Like / peer recognition
                      InkWell(
                        onTap: () => onLike(a),
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          children: [
                            Icon(
                              a.likedByMe
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              color: a.likedByMe ? kPrimary : kTextLight,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${a.likes}',
                              style: TextStyle(
                                color: a.likedByMe ? kPrimary : kTextLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // FEATURE 23: Certificate share
                      InkWell(
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎓 Sharing certificate...'),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.share, color: kTextLight, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Share',
                              style: TextStyle(color: kTextLight, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📥 Certificate downloaded!'),
                              ),
                            ),
                        icon: const Icon(Icons.download, size: 14),
                        label: const Text(
                          'Certificate',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 8 – PROFILE PAGE (5 features)
// ══════════════════════════════════════════════════════════════════════════════

class _ProfilePage extends StatelessWidget {
  final String name, email, phone, batch, roll;
  final bool isDark, profilePublic, largeText;
  final ValueChanged<bool> onPublicToggle, onLargeTextToggle;
  final VoidCallback onEdit, onExport;
  final List<AttendanceDay> attendance;

  const _ProfilePage({
    required this.name,
    required this.email,
    required this.phone,
    required this.batch,
    required this.roll,
    required this.isDark,
    required this.profilePublic,
    required this.largeText,
    required this.onPublicToggle,
    required this.onLargeTextToggle,
    required this.onEdit,
    required this.onExport,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    final present = attendance.where((a) => a.isPresent).length;
    final total = attendance.length;
    final pct = total == 0 ? 0.0 : present / total * 100;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // FEATURE 31: Profile Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: kPrimary.withOpacity(0.15),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: kPrimary,
                      ),
                    ),
                    InkWell(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📷 Photo upload (Firebase Storage)'),
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: kAccent,
                        child: Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  roll,
                  style: const TextStyle(color: kPrimary, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  batch,
                  style: const TextStyle(color: kTextLight, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat(
                      'Attendance',
                      '${pct.toStringAsFixed(0)}%',
                      pct >= 75 ? kSuccess : kError,
                    ),
                    _stat('Events', '3', kPrimary),
                    _stat('Achievements', '4', kAccent),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        // Contact details
        Card(
          child: Column(
            children: [
              _infoTile(Icons.email, 'Email', email),
              _infoTile(Icons.phone, 'Phone', phone),
              _infoTile(Icons.school, 'Batch', batch),
              _infoTile(Icons.badge, 'Roll Number', roll),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // FEATURE 34: Privacy Controls
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔒 Privacy Controls',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Public Profile'),
                  subtitle: const Text(
                    'Visible to other students',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: profilePublic,
                  onChanged: onPublicToggle,
                  activeColor: kPrimary,
                ),
                SwitchListTile(
                  title: const Text('Large Text Mode'),
                  subtitle: const Text(
                    'Accessibility – larger font',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: largeText,
                  onChanged: onLargeTextToggle,
                  activeColor: kPrimary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        // FEATURE 32: Document Locker
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📁 Document Locker',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...[
                  ('10th Marksheet', Icons.description, 'Uploaded'),
                  ('Aadhar Card', Icons.badge, 'Uploaded'),
                  ('Passport Photo', Icons.photo, 'Uploaded'),
                  ('12th Marksheet', Icons.description, 'Pending'),
                ].map(
                  (d) => ListTile(
                    dense: true,
                    leading: Icon(d.$2, color: kPrimary, size: 20),
                    title: Text(d.$1, style: const TextStyle(fontSize: 13)),
                    trailing: Text(
                      d.$3,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: d.$3 == 'Uploaded' ? kSuccess : kWarning,
                      ),
                    ),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '📄 Opening ${d.$1} from Firebase Storage...',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        // FEATURE 33: Password Reset
        Card(
          child: ListTile(
            leading: const Icon(Icons.lock_reset, color: kPrimary),
            title: const Text('Change Password'),
            subtitle: const Text(
              'Reset via Firebase Auth',
              style: TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📧 Password reset email sent!'),
                  backgroundColor: kSuccess,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),
        // FEATURE 35: Export Data
        Card(
          child: ListTile(
            leading: const Icon(Icons.download, color: kPrimary),
            title: const Text('Export My Data'),
            subtitle: const Text(
              'Download all data as JSON',
              style: TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onExport,
          ),
        ),

        const SizedBox(height: 8),
        // FEATURE 28: Chat Support (basic UI)
        Card(
          child: ListTile(
            leading: const Icon(Icons.chat, color: kAccent),
            title: const Text('Chat Support'),
            subtitle: const Text(
              'Contact college helpdesk',
              style: TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChatSheet(context),
          ),
        ),

        const SizedBox(height: 60),
      ],
    );
  }

  // FEATURE 28: Chat support bottom sheet
  void _showChatSheet(BuildContext ctx) {
    final msgs = <Map<String, String>>[
      {'sender': 'support', 'text': 'Hello! How can we help you today?'},
    ];
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx2, set) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx2).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 420,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    '💬 Chat Support',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: msgs.length,
                    itemBuilder: (_, i) {
                      final m = msgs[i];
                      final isMe = m['sender'] == 'me';
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? kPrimary : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            m['text']!,
                            style: TextStyle(
                              color: isMe ? Colors.white : kTextDark,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: kPrimary,
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            if (ctrl.text.trim().isEmpty) return;
                            set(() {
                              msgs.add({
                                'sender': 'me',
                                'text': ctrl.text.trim(),
                              });
                              ctrl.clear();
                              Future.delayed(const Duration(seconds: 1), () {
                                set(
                                  () => msgs.add({
                                    'sender': 'support',
                                    'text':
                                        'Thank you! A support agent will respond shortly.',
                                  }),
                                );
                              });
                            });
                          },
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
    );
  }

  Widget _stat(String label, String val, Color color) => Column(
    children: [
      Text(
        val,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: color,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 11, color: kTextLight)),
    ],
  );

  Widget _infoTile(IconData icon, String label, String val) => ListTile(
    dense: true,
    leading: Icon(icon, size: 18, color: kPrimary),
    title: Text(label, style: const TextStyle(fontSize: 11, color: kTextLight)),
    subtitle: Text(
      val,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 9 – SHIMMER LOADER (FEATURE 40)
// ══════════════════════════════════════════════════════════════════════════════

class _ShimmerLoader extends StatefulWidget {
  final bool isDark;
  const _ShimmerLoader({required this.isDark});

  @override
  State<_ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<_ShimmerLoader>
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
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark ? const Color(0xFF1E293B) : Colors.grey.shade200;
    final high = widget.isDark ? const Color(0xFF334155) : Colors.grey.shade300;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [base, high, base],
                stops: [0, _anim.value, 1],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// END OF FILE
// ══════════════════════════════════════════════════════════════════════════════
//
// Firebase Integration Checklist (replace mock calls):
// ─────────────────────────────────────────────────────
// 1. Replace MockDataService calls with Firestore StreamBuilder/FutureBuilder
// 2. Use FirebaseAuth.instance.signInAnonymously() on app launch
// 3. Use Firebase.initializeApp() in main.dart before runApp()
// 4. Add google-services.json (Android) and GoogleService-Info.plist (iOS)
// 5. Enable Firestore offline persistence:
//    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
// 6. Upload documents via:
//    FirebaseStorage.instance.ref('users/{uid}/docs/{filename}').putFile(file);
// 7. Real-time status listener:
//    FirebaseFirestore.instance.collection('kyp_applications').doc(uid).snapshots()
// 8. Local notifications via flutter_local_notifications for FEATURE 27
// 9. Export CSV with csv package; Export PDF with pdf + printing packages
// ═════════════════════════════════════════════════════════════════════════════
