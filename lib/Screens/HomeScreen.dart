// ============================================================
//  home_screen.dart  –  BEEDI College  [Ultra Professional Redesign v2.0]
//  Blue-White-Green-Yellow Palette | 40+ Features | Full Animations
//  Responsive | Hover | Only 4 Registered Students
//  NEW FEATURES: Weather, Progress Tracker, Chatbot, Dark Mode,
//  Notification Center, Study Timer, Attendance, Timetable,
//  Campus Map, Fee Calculator, Alumni Spotlight, Job Board,
//  Grade Calculator, Event RSVP, Scholarship Finder, Chat Rooms,
//  AI Study Assistant, College Radio, Leaderboard, AR Campus Tour
// ============================================================

import 'dart:async';
import 'dart:math';

import 'package:beedi_college/ADMISSION/Screens/login_screen.dart';
import 'package:beedi_college/QuzeScreens/BS_CITScreen.dart' hide LoginScreen;
import 'package:beedi_college/Screens/AIChatScreen.dart';
import 'package:beedi_college/Screens/AcedemicScreen.dart';
import 'package:beedi_college/Screens/AdmissionScreen.dart';
import 'package:beedi_college/Screens/AlumniSpotlightScreen.dart';
import 'package:beedi_college/Screens/AttendanceScreen.dart';
import 'package:beedi_college/Screens/CampusMapScreen.dart';
import 'package:beedi_college/Screens/ContactsScreen.dart';
import 'package:beedi_college/Screens/ELibraryScreen.dart';
import 'package:beedi_college/Screens/FacultyPortalScreen.dart';
import 'package:beedi_college/Screens/GradeCalculatorScreen.dart';
import 'package:beedi_college/Screens/HajipurVaishaliScreen.dart';
import 'package:beedi_college/Screens/JobBoardScreen.dart';
import 'package:beedi_college/Screens/KYPAdmissionScreen.dart';
import 'package:beedi_college/Screens/KYPQuizeScreen.dart';
import 'package:beedi_college/Screens/OpportunitiesScreen.dart';
import 'package:beedi_college/Screens/ResearchScreen.dart';
import 'package:beedi_college/Screens/ScholarshipScreen.dart';
import 'package:beedi_college/Screens/SportsScreen.dart';
import 'package:beedi_college/Screens/StudentLifeScreen.dart';
import 'package:beedi_college/Screens/StudentQuizScreen.dart' hide LoginScreen;
import 'package:beedi_college/Screens/StudyTimerScreen.dart';
import 'package:beedi_college/Screens/SubjectChooseScrren.dart';
import 'package:beedi_college/Screens/TimetableScreen.dart';
import 'package:beedi_college/Screens/TodatTestScreen.dart';
import 'package:beedi_college/Screens/VirtualTourScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ════════════════════════════════════════════════════════════
//  THEME CONSTANTS  (Blue · White · Green · Yellow)
// ════════════════════════════════════════════════════════════
class AC {
  static const bg = Color(0xFFF0F8FF);
  static const bg2 = Color(0xFFE6F2FF);
  static const surface = Color(0xFFF5F9FF);
  static const cardBg = Color(0xFFFFFFFF);
  static const darkBg = Color(0xFF0A1628);
  static const darkSurface = Color(0xFF0F1F3D);
  static const darkCard = Color(0xFF152545);

  static const primaryBlue = Color(0xFF1E88E5);
  static const darkBlue = Color(0xFF0D47A1);
  static const lightBlue = Color(0xFF42A5F5);
  static const accentBlue = Color(0xFF1565C0);
  static const neonBlue = Color(0xFF00B4FF);

  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF8FAFF);
  static const iceBlue = Color(0xFFE3F2FD);

  static const green = Color(0xFF4CAF50);
  static const greenLight = Color(0xFF81C784);
  static const teal = Color(0xFF00BCD4);
  static const yellow = Color(0xFFFFC107);
  static const gold = Color(0xFFFFD700);
  static const orange = Color(0xFFFF9800);
  static const red = Color(0xFFF44336);
  static const purple = Color(0xFF9C27B0);

  static const textPri = Color(0xFF1A237E);
  static const textSec = Color(0xFF455A64);
  static const textMuted = Color(0xFF78909C);
  static const darkTextPri = Color(0xFFE3F2FD);
  static const darkTextSec = Color(0xFF90CAF9);

  static const Color blue = Color(0xFF1E88E5);
  static const Color darkGreen = Color(0xFF059669);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFF1F5F9);
  static const Color borderGrey = Color(0xFFE2E8F0);

  

  static const appBarGrad = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const heroGrad = LinearGradient(
    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const darkAppBarGrad = LinearGradient(
    colors: [Color(0xFF0A1628), Color(0xFF0D47A1), Color(0xFF1565C0)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// ════════════════════════════════════════════════════════════
//  DARK MODE PROVIDER
// ════════════════════════════════════════════════════════════
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

final themeProvider = ThemeProvider();

// ════════════════════════════════════════════════════════════
//  AUTHENTICATION SYSTEM
// ════════════════════════════════════════════════════════════
class StudentAuth {
  static const Map<String, String> _registeredStudents = {
    'Randhir Kumar': '123456',
    'Gaurav Kumar': '234567',
    'Priti Kumari': '345678',
    'Mantu Kumar': '456789',
  };

  static bool authenticate(String name, String pin) {
    final normalizedName = name.trim();
    final normalizedPin = pin.trim();
    return _registeredStudents.containsKey(normalizedName) &&
        _registeredStudents[normalizedName] == normalizedPin;
  }

  static List<String> getRegisteredStudents() =>
      _registeredStudents.keys.toList();
  static bool isStudentRegistered(String name) =>
      _registeredStudents.containsKey(name.trim());
}

// ════════════════════════════════════════════════════════════
//  DATA
// ════════════════════════════════════════════════════════════
const List<Map<String, String>> kStats = [
  {'value': '15,000+', 'label': 'Students', 'icon': '🎓'},
  {'value': '550+', 'label': 'Faculty', 'icon': '👨‍🏫'},
  {'value': '42', 'label': 'Departments', 'icon': '🏛️'},
  {'value': '97%', 'label': 'Placement', 'icon': '💼'},
  {'value': '₹45L', 'label': 'Highest CTC', 'icon': '💰'},
  {'value': '60K+', 'label': 'Alumni', 'icon': '🌐'},
];

const List<String> kTicker = [
  '🎓  Admission Open 2026-27 – Apply before Dec 31',
  '🏆  BEEDI College wins Best College Award 2024 by Bihar Govt',
  '📚  KYP Enrollment now live – Register today for FREE',
  '🌐  International Exchange Programme accepting applications',
  '⚡  New AI Research Lab inaugurated on Campus B',
  '🎉  Annual Sports Meet on Dec 10 – Register Now',
  '💡  Startup Incubator – Pitch your idea, win ₹5 Lakhs',
  '📍  Hajipur-Vaishali Campus Expansion – New facilities coming soon!',
  '🎵  College Radio BEEDI FM 90.5 now LIVE – Tune in!',
  '🏅  BEEDI College Leaderboard – Top 10 students announced!',
];

const List<Map<String, dynamic>> kAchievements = [
  {
    'emoji': '🏆',
    'title': 'Best College Award 2024',
    'sub': 'Bihar Government Excellence in Education',
    'color': Color(0xFF1E88E5),
  },
  {
    'emoji': '🔬',
    'title': 'AI Research Lab',
    'sub': 'First AI lab in Eastern Bihar',
    'color': Color(0xFF0D47A1),
  },
  {
    'emoji': '🌍',
    'title': 'Global Tie-ups',
    'sub': 'MoUs with 12 International Universities',
    'color': Color(0xFF42A5F5),
  },
  {
    'emoji': '💰',
    'title': '₹45L Highest Package',
    'sub': 'Google placement – CSE 2024 batch',
    'color': Color(0xFF1565C0),
  },
  {
    'emoji': '⭐',
    'title': 'Opp.. HDFC Bank',
    'sub': 'Top 5% colleges in Bihar & Jharkhand',
    'color': Color(0xFF1E88E5),
  },
];

final List<Map<String, String>> kTestimonials = [
  {
    'name': 'Priya Sharma',
    'batch': 'B.Tech CSE 2022 · Google, Bangalore',
    'text':
        'BEEDI College gave me the foundation to crack Google interviews. The faculty pushes you beyond limits. My placement package was ₹45 LPA — a dream come true!',
    'img': 'https://randomuser.me/api/portraits/women/68.jpg',
    'rating': '5',
  },
  {
    'name': 'Arjun Mehta',
    'batch': 'MBA Finance 2023 · HDFC Bank',
    'text':
        'The campus culture and industry networking here are unmatched in Bihar. BEEDI\'s placement cell connected me to HDFC Bank in my final semester itself.',
    'img': 'https://randomuser.me/api/portraits/men/32.jpg',
    'rating': '5',
  },
  {
    'name': 'Sneha Roy',
    'batch': 'B.Sc Physics 2021 · IIT-JRF',
    'text':
        'Research facilities at BEEDI are at par with top NITs. I got IIT-JRF fellowship after doing project work in their Quantum Physics lab. Proud alumna!',
    'img': 'https://randomuser.me/api/portraits/women/45.jpg',
    'rating': '5',
  },
  {
    'name': 'Rohit Kumar',
    'batch': 'B.Tech ECE 2023 · Samsung R&D',
    'text':
        'From zero industry exposure to Samsung R&D in Seoul — BEEDI\'s international exchange program changed my life. The college investments in students are real.',
    'img': 'https://randomuser.me/api/portraits/men/52.jpg',
    'rating': '5',
  },
  {
    'name': 'Anjali Gupta',
    'batch': 'BBA 2022 · Startup Founder',
    'text':
        'BEEDI\'s startup incubator funded my agri-tech startup with ₹3 Lakhs. Today we serve 5000+ farmers. Thank you BEEDI for believing in us!',
    'img': 'https://randomuser.me/api/portraits/women/23.jpg',
    'rating': '5',
  },
];

const List<Map<String, dynamic>> kCarousel = [
  {
    'title': 'Excellence in Education',
    'sub': 'World-class academic programs for tomorrow\'s leaders of Bihar',
    'img': 'https://picsum.photos/id/20/800/350',
    'badge': '🎓 Academic',
    'color': Color(0xFF1565C0),
    'cta': 'Explore Courses',
  },
  {
    'title': 'Research & Innovation Hub',
    'sub': 'Pioneering AI & biotech discoveries shaping India\'s future',
    'img': 'https://picsum.photos/id/119/800/350',
    'badge': '🔬 Research',
    'color': Color(0xFF0D47A1),
    'cta': 'See Projects',
  },
  {
    'title': 'Vibrant Campus Life',
    'sub': '60+ clubs, annual fests & a community that lifts you higher',
    'img': 'https://picsum.photos/id/64/800/350',
    'badge': '🌟 Student Life',
    'color': Color(0xFF1E88E5),
    'cta': 'Explore Life',
  },
  {
    'title': 'Global Opportunities',
    'sub': 'Exchange programs & international collaborations await',
    'img': 'https://picsum.photos/id/180/800/350',
    'badge': '🌐 Global',
    'color': Color(0xFF42A5F5),
    'cta': 'Go Global',
  },
];

const List<Map<String, dynamic>> kUniqueFeatures = [
  {
    'icon': '🤖',
    'title': 'AI Research Lab',
    'desc': 'First dedicated AI & ML lab in Eastern Bihar with GPU clusters',
    'color': Color(0xFF1E88E5),
    'tag': 'Innovation',
  },
  {
    'icon': '🚀',
    'title': 'Startup Incubator',
    'desc': '₹5L seed funding + mentorship for student startups',
    'color': Color(0xFF1565C0),
    'tag': 'Entrepreneurship',
  },
  {
    'icon': '🌍',
    'title': 'Global Exchange',
    'desc': 'Semester abroad at 12 partner universities worldwide',
    'color': Color(0xFF42A5F5),
    'tag': 'International',
  },
  {
    'icon': '☀️',
    'title': 'Solar Campus',
    'desc': '100% solar-powered campus — India\'s greenest college',
    'color': Color(0xFF0D47A1),
    'tag': 'Sustainability',
  },
  {
    'icon': '🏥',
    'title': 'Health & Wellness',
    'desc': '24/7 clinic, counsellors & mental health support on campus',
    'color': Color(0xFF1E88E5),
    'tag': 'Wellbeing',
  },
  {
    'icon': '📡',
    'title': 'Smart Classrooms',
    'desc': 'IoT-enabled smart rooms with live lecture streaming',
    'color': Color(0xFF42A5F5),
    'tag': 'EdTech',
  },
  {
    'icon': '🎭',
    'title': 'Cultural Hub',
    'desc': '2000-seat auditorium hosting Bihar\'s biggest college fest',
    'color': Color(0xFF1565C0),
    'tag': 'Culture',
  },
  {
    'icon': '🏊',
    'title': 'Olympic Pool',
    'desc': 'Olympic-size pool + 15 sports disciplines & floodlit grounds',
    'color': Color(0xFF1E88E5),
    'tag': 'Sports',
  },
  {
    'icon': '📚',
    'title': 'Digital Library',
    'desc': '5L+ e-books, 200+ journals & 24/7 open study zones',
    'color': Color(0xFF0D47A1),
    'tag': 'Knowledge',
  },
  {
    'icon': '🤝',
    'title': 'Alumni Network',
    'desc': '60K+ alumni across 40 countries with live mentorship portal',
    'color': Color(0xFF42A5F5),
    'tag': 'Community',
  },
];

const List<Map<String, String>> kNews = [
  {
    'title': 'New AI Lab Opens on Campus B — First in Eastern Bihar',
    'date': 'Nov 28, 2024',
    'tag': 'Innovation',
    'img': 'https://picsum.photos/id/48/300/150',
    'read': '3 min read',
  },
  {
    'title': 'BEEDI Wins Best College Award — Bihar Govt Honours Excellence',
    'date': 'Nov 20, 2024',
    'tag': 'Achievement',
    'img': 'https://picsum.photos/id/20/300/150',
    'read': '2 min read',
  },
  {
    'title': 'Annual Sports Meet 2024 — 1200 Athletes, Record Wins',
    'date': 'Nov 15, 2024',
    'tag': 'Sports',
    'img': 'https://picsum.photos/id/165/300/150',
    'read': '4 min read',
  },
  {
    'title': 'Student Startup Gets ₹40L Funding After BEEDI Incubator',
    'date': 'Nov 10, 2024',
    'tag': 'Startup',
    'img': 'https://picsum.photos/id/119/300/150',
    'read': '5 min read',
  },
];

const List<Map<String, dynamic>> kEvents = [
  {
    'title': 'Annual Sports Meet',
    'date': 'Dec 10',
    'time': '9:00 AM',
    'venue': 'Sports Ground A',
    'color': Color(0xFF1E88E5),
    'icon': '🏅',
    'seats': '1200',
  },
  {
    'title': 'Tech Symposium 2024',
    'date': 'Dec 18',
    'time': '10:00 AM',
    'venue': 'Seminar Hall B1',
    'color': Color(0xFF42A5F5),
    'icon': '💡',
    'seats': '500',
  },
  {
    'title': 'Freshers Welcome Night',
    'date': 'Jan 5',
    'time': '6:00 PM',
    'venue': 'Main Auditorium',
    'color': Color(0xFF1565C0),
    'icon': '🎉',
    'seats': '2000',
  },
  {
    'title': 'KYP Quiz Finals',
    'date': 'Jan 12',
    'time': '11:00 AM',
    'venue': 'Exam Hall C',
    'color': Color(0xFF0D47A1),
    'icon': '🧠',
    'seats': '300',
  },
  {
    'title': 'Startup Pitch Day',
    'date': 'Jan 20',
    'time': '2:00 PM',
    'venue': 'Innovation Hub',
    'color': Color(0xFF1E88E5),
    'icon': '🚀',
    'seats': '200',
  },
];

const List<Map<String, String>> kGallery = [
  {'img': 'https://picsum.photos/id/20/300/200', 'label': 'Campus Main Gate'},
  {'img': 'https://picsum.photos/id/48/300/200', 'label': 'AI Research Lab'},
  {'img': 'https://picsum.photos/id/64/300/200', 'label': 'Student Fest'},
  {'img': 'https://picsum.photos/id/119/300/200', 'label': 'Science Block'},
  {'img': 'https://picsum.photos/id/165/300/200', 'label': 'Sports Ground'},
  {'img': 'https://picsum.photos/id/180/300/200', 'label': 'Library'},
];

const List<Map<String, String>> kHajipurFeatures = [
  {
    'title': 'Hajipur Satellite Campus',
    'desc': 'New 50-acre campus coming up in Hajipur-Vaishali region',
    'icon': '🏗️',
    'color': '#1E88E5',
  },
  {
    'title': 'Vaishali Heritage Center',
    'desc': 'Dedicated center for Buddhist and historical studies',
    'icon': '🕉️',
    'color': '#42A5F5',
  },
  {
    'title': 'Community Outreach',
    'desc': 'Rural development programs in 50+ villages',
    'icon': '🤝',
    'color': '#1565C0',
  },
  {
    'title': 'Skill Development Hub',
    'desc': 'Vocational training for local youth',
    'icon': '💪',
    'color': '#0D47A1',
  },
];

// ════════════════════════════════════════════════════════════
//  NEW FEATURE DATA
// ════════════════════════════════════════════════════════════

const List<Map<String, dynamic>> kAlumniSpotlight = [
  {
    'name': 'Dr. Amit Verma',
    'role': 'CTO, Zomato',
    'batch': 'B.Tech CSE 2010',
    'img': 'https://randomuser.me/api/portraits/men/44.jpg',
    'quote': 'BEEDI shaped my problem-solving mindset.',
    'color': Color(0xFF1E88E5),
  },
  {
    'name': 'Kavya Singh',
    'role': 'IAS Officer',
    'batch': 'BA Hons 2014',
    'img': 'https://randomuser.me/api/portraits/women/33.jpg',
    'quote': 'The discipline here prepared me for UPSC.',
    'color': Color(0xFF0D47A1),
  },
  {
    'name': 'Rahul Jha',
    'role': 'NASA Researcher',
    'batch': 'M.Sc Physics 2012',
    'img': 'https://randomuser.me/api/portraits/men/22.jpg',
    'quote': 'BEEDI\'s research culture launched my career.',
    'color': Color(0xFF42A5F5),
  },
];

const List<Map<String, dynamic>> kJobBoard = [
  {
    'company': 'Google India',
    'role': 'Software Engineer L3',
    'location': 'Bangalore',
    'package': '₹32-45 LPA',
    'deadline': 'Dec 15',
    'type': 'Full-time',
    'color': Color(0xFF1E88E5),
    'logo': '🔵',
  },
  {
    'company': 'Amazon AWS',
    'role': 'Cloud Architect',
    'location': 'Hyderabad',
    'package': '₹28-38 LPA',
    'deadline': 'Dec 20',
    'type': 'Full-time',
    'color': Color(0xFF0D47A1),
    'logo': '🟠',
  },
  {
    'company': 'Microsoft',
    'role': 'Data Scientist',
    'location': 'Noida',
    'package': '₹25-35 LPA',
    'deadline': 'Jan 5',
    'type': 'Full-time',
    'color': Color(0xFF42A5F5),
    'logo': '🟦',
  },
  {
    'company': 'Paytm Internship',
    'role': 'ML Engineer Intern',
    'location': 'Remote',
    'package': '₹50K/month',
    'deadline': 'Jan 10',
    'type': 'Internship',
    'color': Color(0xFF1565C0),
    'logo': '💙',
  },
];

const List<Map<String, dynamic>> kLeaderboard = [
  {
    'rank': 1,
    'name': 'Priya Sharma',
    'dept': 'CSE',
    'score': 9850,
    'badge': '🥇',
    'avatar': 'https://randomuser.me/api/portraits/women/68.jpg',
  },
  {
    'rank': 2,
    'name': 'Arjun Mehta',
    'dept': 'MBA',
    'score': 9720,
    'badge': '🥈',
    'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
  },
  {
    'rank': 3,
    'name': 'Sneha Roy',
    'dept': 'Physics',
    'score': 9650,
    'badge': '🥉',
    'avatar': 'https://randomuser.me/api/portraits/women/45.jpg',
  },
  {
    'rank': 4,
    'name': 'Rohit Kumar',
    'dept': 'ECE',
    'score': 9520,
    'badge': '⭐',
    'avatar': 'https://randomuser.me/api/portraits/men/52.jpg',
  },
  {
    'rank': 5,
    'name': 'Anjali Gupta',
    'dept': 'BBA',
    'score': 9410,
    'badge': '⭐',
    'avatar': 'https://randomuser.me/api/portraits/women/23.jpg',
  },
];

const List<Map<String, String>> kScholarships = [
  {
    'name': 'Merit Scholarship',
    'amount': '₹75,000/year',
    'criteria': 'Top 10% students',
    'deadline': 'Jan 31',
    'icon': '🏆',
  },
  {
    'name': 'SC/ST Fellowship',
    'amount': '₹50,000/year',
    'criteria': 'SC/ST students',
    'deadline': 'Feb 15',
    'icon': '🤝',
  },
  {
    'name': 'Sports Excellence',
    'amount': '₹40,000/year',
    'criteria': 'National-level athletes',
    'deadline': 'Dec 31',
    'icon': '🏅',
  },
  {
    'name': 'Research Grant',
    'amount': '₹2,00,000',
    'criteria': 'PhD & PG students',
    'deadline': 'Mar 1',
    'icon': '🔬',
  },
];

const List<Map<String, dynamic>> kCampusMap = [
  {'name': 'Main Gate', 'icon': '🚪', 'x': 0.1, 'y': 0.9},
  {'name': 'Admin Block', 'icon': '🏛️', 'x': 0.3, 'y': 0.7},
  {'name': 'Library', 'icon': '📚', 'x': 0.5, 'y': 0.5},
  {'name': 'Science Labs', 'icon': '🔬', 'x': 0.7, 'y': 0.6},
  {'name': 'Canteen', 'icon': '🍽️', 'x': 0.4, 'y': 0.3},
  {'name': 'Hostel A', 'icon': '🏠', 'x': 0.8, 'y': 0.2},
  {'name': 'Sports Ground', 'icon': '⚽', 'x': 0.2, 'y': 0.2},
  {'name': 'AI Lab', 'icon': '🤖', 'x': 0.6, 'y': 0.85},
];

// ════════════════════════════════════════════════════════════
//  CARD DATA MODEL
// ════════════════════════════════════════════════════════════
class CardData {
  final String title, subtitle, networkImg;
  final IconData icon;
  final Color accent, accent2;
  final Widget screen;
  final String tag;

  const CardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.networkImg,
    required this.accent,
    required this.accent2,
    required this.screen,
    this.tag = '',
  });
}

List<CardData> get kCards => [
  CardData(
    title: 'Academic Programs',
    subtitle: 'Degrees, diplomas & certifications',
    icon: Icons.menu_book_rounded,
    networkImg: 'https://miro.medium.com/1*sxTXB1rgfsEhUjxEhz-jzQ.png',
    accent: const Color(0xFF1E88E5),
    accent2: const Color(0xFF42A5F5),
    screen: const AcademicScreen(),
    tag: '42 Programs',
  ),
  CardData(
    title: 'Research',
    subtitle: 'Innovation & cutting-edge studies',
    icon: Icons.science_rounded,
    networkImg: 'https://miro.medium.com/v2/resize:fit:1400/1*ibByiZpcXhuXPzbFtoSqFg.png',
    accent: const Color(0xFF1565C0),
    accent2: const Color(0xFF42A5F5),
    screen: const ResearchScreen(),
    tag: '50+ Projects',
  ),
  CardData(
    title: 'Student Life',
    subtitle: 'Culture, clubs & community',
    icon: Icons.people_alt_rounded,
    networkImg: 'https://hotmart.s3.amazonaws.com/product_pictures/68165baa-7048-4f85-ae25-6c540576664b/TeacherwithAI.png',
    accent: const Color(0xFF1E88E5),
    accent2: const Color(0xFF42A5F5),
    screen: const StudentLifeScreen(),
    tag: '70+ Clubs',
  ),
  CardData(
    title: 'Sports',
    subtitle: 'Champions on and off field',
    icon: Icons.sports_soccer_rounded,
    networkImg: 'https://cdn.prod.website-files.com/671653eb164bd7404a75a117/671926acacddbca59e0f2352_ia.png',
    accent: const Color(0xFF0D47A1),
    accent2: const Color(0xFF1E88E5),
    screen: const SportsScreen(),
    tag: '18 Disciplines',
  ),
  CardData(
    title: 'Admission',
    subtitle: 'Join the BEEDI family today',
    icon: Icons.how_to_reg_rounded,
    networkImg: 'https://www.esparklearning.com/app/uploads/2024/04/AI-for-Image-Generation-featured-image-e1712251769334.webp',
    accent: const Color(0xFF1565C0),
    accent2: const Color(0xFF42A5F5),
    screen: const AdmissionScreen(),
    tag: 'Apply Now',
  ),
  CardData(
    title: 'KYP Quiz',
    subtitle: 'Test your knowledge & skills',
    icon: Icons.quiz_rounded,
    networkImg: 'https://miro.medium.com/v2/resize:fit:1400/1*HyZJyzKp6fWwSITjxfd2iQ.jpeg',
    accent: const Color(0xFF1E88E5),
    accent2: const Color(0xFF42A5F5),
    screen: const KYPQuizScreen(),
    tag: 'Free Cert',
  ),
  CardData(
    title: 'Student Test',
    subtitle: 'Only for registered students',
    icon: Icons.assignment_rounded,
    networkImg:
        'https://cdnai.iconscout.com/ai-image/premium/thumb/ai-school-boy-in-uniform-answering-a-quiz-sheet-3d-icon-png-download-jpg-14509115.png',
    accent: const Color(0xFF1E88E5),
    accent2: const Color(0xFF42A5F5),
    screen: const StudentEntryScreen(),
    tag: 'Take Test',
  ),
  CardData(
    title: 'Smart Study',
    subtitle: 'Only for registered students',
    icon: Icons.assignment_rounded,
    networkImg:
        'https://www.uttyler.edu/offices/academic-affairs/resource-hub/images/aiimage1.jpeg',
    accent: const Color(0xFF1E88E5),
    accent2: const Color(0xFF42A5F5),
    screen: const SubjectChooseScreen(),
    tag: 'Take Test',
  ),
  CardData(
    title: 'Today Test',
    subtitle: 'Only for registered students',
    icon: Icons.assignment_rounded,
    networkImg:
        'https://cdn.pixabay.com/photo/2024/03/15/19/21/ai-8635633_1280.jpg',
    accent: const Color(0xFF1E88E5),
    accent2: const Color(0xFF42A5F5),
    screen: const LoginScreen(),
    tag: 'Valid for one day',
  ),
];

// ════════════════════════════════════════════════════════════
//  DRAWER ITEM MODEL
// ════════════════════════════════════════════════════════════
class DrawerItem {
  final String label;
  final IconData icon;
  final Color color;
  final Widget screen;
  const DrawerItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

List<DrawerItem> get kDrawerItems => [
  DrawerItem(
    label: 'Academic Programs',
    icon: Icons.menu_book_rounded,
    color: const Color(0xFF1E88E5),
    screen: const AcademicScreen(),
  ),
  DrawerItem(
    label: 'Research',
    icon: Icons.science_rounded,
    color: const Color(0xFF1565C0),
    screen: const ResearchScreen(),
  ),
  DrawerItem(
    label: 'Student Life',
    icon: Icons.people_alt_rounded,
    color: const Color(0xFF1E88E5),
    screen: const StudentLifeScreen(),
  ),
  DrawerItem(
    label: 'Sports',
    icon: Icons.sports_soccer_rounded,
    color: const Color(0xFF0D47A1),
    screen: const SportsScreen(),
  ),
  DrawerItem(
    label: 'Contacts',
    icon: Icons.contact_phone_rounded,
    color: const Color(0xFF42A5F5),
    screen: const ContactsScreen(),
  ),
  DrawerItem(
    label: 'Admission',
    icon: Icons.how_to_reg_rounded,
    color: const Color(0xFF1565C0),
    screen: const AdmissionScreen(),
  ),
  DrawerItem(
    label: 'KYP Quiz',
    icon: Icons.quiz_rounded,
    color: const Color(0xFF1E88E5),
    screen: const KYPQuizScreen(),
  ),
  DrawerItem(
    label: 'KYP Enrollment',
    icon: Icons.app_registration_rounded,
    color: const Color(0xFF42A5F5),
    screen: const KYPAdmissionScreen(),
  ),
  DrawerItem(
    label: 'Student Test',
    icon: Icons.assignment_rounded,
    color: const Color(0xFF1565C0),
    screen: const StudentEntryScreen(),
  ),
  DrawerItem(
    label: 'Opportunities',
    icon: Icons.lightbulb_rounded,
    color: const Color(0xFF1E88E5),
    screen: const OpportunitiesScreen(),
  ),
  DrawerItem(
    label: 'Hajipur-Vaishali',
    icon: Icons.location_city_rounded,
    color: const Color(0xFF0D47A1),
    screen: const HajipurVaishaliScreen(),
  ),
  DrawerItem(
    label: 'Faculty Portal',
    icon: Icons.person_outline_rounded,
    color: const Color(0xFF42A5F5),
    screen: const FacultyPortalScreen(),
  ),
  DrawerItem(
    label: 'E-Library',
    icon: Icons.library_books_rounded,
    color: const Color(0xFF1E88E5),
    screen: const ELibraryScreen(),
  ),
  DrawerItem(
    label: 'Virtual Tour',
    icon: Icons.video_call_rounded,
    color: const Color(0xFF1565C0),
    screen: const VirtualTourScreen(),
  ),
  // NEW DRAWER ITEMS
  DrawerItem(
    label: 'Job Board',
    icon: Icons.work_rounded,
    color: const Color(0xFF1E88E5),
    screen: const JobBoardScreen(),
  ),
  DrawerItem(
    label: 'Campus Map',
    icon: Icons.map_rounded,
    color: const Color(0xFF0D47A1),
    screen: const CampusMapScreen(),
  ),
  DrawerItem(
    label: 'Scholarships',
    icon: Icons.monetization_on_rounded,
    color: const Color(0xFF42A5F5),
    screen: const ScholarshipScreen(),
  ),
  DrawerItem(
    label: 'Study Timer',
    icon: Icons.timer_rounded,
    color: const Color(0xFF1565C0),
    screen: const StudyTimerScreen(),
  ),
  DrawerItem(
    label: 'Grade Calculator',
    icon: Icons.calculate_rounded,
    color: const Color(0xFF1E88E5),
    screen: const GradeCalculatorScreen(),
  ),
  DrawerItem(
    label: 'Timetable',
    icon: Icons.table_chart_rounded,
    color: const Color(0xFF0D47A1),
    screen: const TimetableScreen(),
  ),
  DrawerItem(
    label: 'Attendance',
    icon: Icons.how_to_reg_rounded,
    color: const Color(0xFF42A5F5),
    screen: const AttendanceScreen(),
  ),
  DrawerItem(
    label: 'Leaderboard',
    icon: Icons.leaderboard_rounded,
    color: const Color(0xFF1565C0),
    screen: const LeaderboardScreen(),
  ),
  DrawerItem(
    label: 'Alumni Spotlight',
    icon: Icons.star_rounded,
    color: const Color(0xFF1E88E5),
    screen: const AlumniSpotlightScreen(),
  ),
  DrawerItem(
    label: 'Admin Panel',
    icon: Icons.admin_panel_settings_rounded,
    color: const Color(0xFF1E88E5),
    screen: const CenterLoginScreen(),
  ),
  DrawerItem(
    label: 'AI Assistant',
    icon: Icons.smart_toy_rounded,
    color: const Color(0xFF7E57C2),
    screen: const AIChatScreen(),
  ),
];

// ════════════════════════════════════════════════════════════
//  NAVIGATION HELPER
// ════════════════════════════════════════════════════════════
void pushScreen(BuildContext context, Widget screen) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionDuration: const Duration(milliseconds: 420),
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutQuart)),
        child: FadeTransition(opacity: anim, child: child),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  HOME SCREEN
// ════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  bool _showFab = false;

  late PageController _pageCtrl;
  int _carouselIdx = 0;
  late Timer _carouselTimer;

  late AnimationController _welcomeCtrl, _statsCtrl, _pulseCtrl, _fabCtrl;
  late Animation<double> _welcomeFade, _statsAnim, _pulseAnim, _fabAnim;
  late Animation<Offset> _welcomeSlide;

  int _tickerIdx = 0;
  late Timer _tickerTimer;

  bool _searchOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  List<String> _searchResults = [];

  late Timer _countdownTimer;
  int _countdownSeconds = 5 * 24 * 3600 + 14 * 3600 + 32 * 60 + 10;

  int _liveCount = 1247;
  late Timer _liveTimer;

  int _userRating = 0;
  int _exploreTab = 0;
  int _notificationCount = 5;
  bool _showHajipurSpotlight = true;
  bool _isDarkMode = false;

  // NEW STATE
  bool _radioPlaying = false;
  int _studyTimerSeconds = 0;
  bool _studyTimerRunning = false;
  Timer? _studyTimer;
  int _attendancePercent = 87;
  List<bool> _rsvpd = List.filled(kEvents.length, false);
  bool _chatbotOpen = false;
  final TextEditingController _chatInput = TextEditingController();
  final List<Map<String, String>> _chatMessages = [
    {'role': 'bot', 'text': 'Hi! I\'m BEEDI AI. How can I help you today? 🎓'},
  ];
  String _weatherInfo = '🌤 28°C · Hajipur, Vaishali';
  bool _weatherLoading = true;
  int _feeInstallment = 0;
  final List<String> _bookmarkedJobs = [];
  double _cgpa = 8.4;
  final List<bool> _scholarshipApplied = List.filled(
    kScholarships.length,
    false,
  );
  int _selectedMapPin = -1;
  bool _notifPanelOpen = false;
  final List<Map<String, String>> _notifications = [
    {'title': 'New job posted: Google SWE', 'time': '2 min ago', 'icon': '💼'},
    {'title': 'Quiz result published', 'time': '1 hr ago', 'icon': '📊'},
    {'title': 'Scholarship deadline: Jan 31', 'time': '3 hr ago', 'icon': '🏆'},
    {
      'title': 'Sports meet registration open',
      'time': '5 hr ago',
      'icon': '🏅',
    },
    {'title': 'KYP Enrollment extended', 'time': '1 day ago', 'icon': '📝'},
  ];

  @override
  void initState() {
    super.initState();

    _scroll.addListener(() {
      final show = _scroll.offset > 300;
      if (show != _showFab) setState(() => _showFab = show);
    });

    _pageCtrl = PageController(viewportFraction: 0.92);
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      _pageCtrl.animateToPage(
        (_carouselIdx + 1) % kCarousel.length,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });

    _welcomeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _welcomeFade = CurvedAnimation(parent: _welcomeCtrl, curve: Curves.easeIn);
    _welcomeSlide =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
          CurvedAnimation(parent: _welcomeCtrl, curve: Curves.easeOutCubic),
        );

    _statsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _statsAnim = CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnim = CurvedAnimation(parent: _fabCtrl, curve: Curves.elasticOut);

    _tickerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted)
        setState(() => _tickerIdx = (_tickerIdx + 1) % kTicker.length);
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _countdownSeconds > 0) setState(() => _countdownSeconds--);
    });

    _liveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _liveCount += (Random().nextInt(5) - 2);
          _liveCount = _liveCount.clamp(1200, 1350);
        });
      }
    });

    // Simulate weather loading
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _weatherLoading = false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _welcomeCtrl.forward();
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _statsCtrl.forward(),
      );
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _pageCtrl.dispose();
    _carouselTimer.cancel();
    _welcomeCtrl.dispose();
    _statsCtrl.dispose();
    _pulseCtrl.dispose();
    _fabCtrl.dispose();
    _tickerTimer.cancel();
    _countdownTimer.cancel();
    _liveTimer.cancel();
    _studyTimer?.cancel();
    _searchCtrl.dispose();
    _chatInput.dispose();
    super.dispose();
  }

  void _scrollToTop() => _scroll.animateTo(
    0,
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOutCubic,
  );

  String get _countdownStr {
    final d = _countdownSeconds ~/ 86400;
    final h = (_countdownSeconds % 86400) ~/ 3600;
    final m = (_countdownSeconds % 3600) ~/ 60;
    final s = _countdownSeconds % 60;
    return '${d}d ${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
  }

  String get _studyTimerStr {
    final h = _studyTimerSeconds ~/ 3600;
    final m = (_studyTimerSeconds % 3600) ~/ 60;
    final s = _studyTimerSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toggleStudyTimer() {
    if (_studyTimerRunning) {
      _studyTimer?.cancel();
      setState(() => _studyTimerRunning = false);
    } else {
      _studyTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _studyTimerSeconds++);
      });
      setState(() => _studyTimerRunning = true);
    }
  }

  void _sendChatMessage(String msg) {
    if (msg.trim().isEmpty) return;
    setState(() {
      _chatMessages.add({'role': 'user', 'text': msg});
      _chatInput.clear();
    });
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      String reply = _getBotReply(msg.toLowerCase());
      setState(() => _chatMessages.add({'role': 'bot', 'text': reply}));
    });
  }

 String _getBotReply(String msg) {
  String lowerMsg = msg.toLowerCase().trim();
  
  // ==================== ADMISSION QUERIES (15+) ====================
  if (lowerMsg.contains('admission') || lowerMsg.contains('apply') || lowerMsg.contains('enroll') || 
      lowerMsg.contains('last date') || lowerMsg.contains('deadline') || lowerMsg.contains('application')) {
    if (lowerMsg.contains('last date') || lowerMsg.contains('deadline')) 
      return '📅 Admission deadline: December 31, 2026. Apply early for scholarships! apply.beeedicollege.ac.in';
    if (lowerMsg.contains('process') || lowerMsg.contains('procedure'))
      return '📝 Admission Process: 1) Online application 2) Entrance exam 3) Personal interview 4) Document verification 5) Fee payment. Start now!';
    if (lowerMsg.contains('document') || lowerMsg.contains('documents'))
      return '📄 Required documents: 10th & 12th marksheets, Transfer certificate, Migration certificate, Passport photos, ID proof, Caste certificate (if applicable).';
    return '🎓 Admissions open till Dec 31, 2026! Courses: B.Tech, MBA, MCA, B.Sc, B.Com. Apply: apply.beeedicollege.ac.in Helpline: +91-80001-23456';
  }
  
  // ==================== FEE & FINANCE QUERIES (10+) ====================
  if (lowerMsg.contains('fee') || lowerMsg.contains('fees') || lowerMsg.contains('cost') || lowerMsg.contains('price') || 
      lowerMsg.contains('tuition') || lowerMsg.contains('payment') || lowerMsg.contains('refund')) {
    if (lowerMsg.contains('payment') || lowerMsg.contains('online payment'))
      return '💳 Online payment options: UPI, Credit/Debit Cards, Net Banking, NEFT/RTGS. Installment facility available. Contact accounts@beeedicollege.ac.in';
    if (lowerMsg.contains('refund') || lowerMsg.contains('cancellation'))
      return '🔄 Refund Policy: 100% before course start, 50% within 15 days, no refund after 30 days. Terms apply.';
    if (lowerMsg.contains('hostel') && lowerMsg.contains('fee'))
      return '🏠 Hostel fees: ₹60,000/year for double occupancy, ₹85,000/year for single occupancy. Includes mess, WiFi, laundry.';
    return '💰 Fee Structure:\n• B.Tech: ₹85,000/year\n• MBA: ₹1,20,000/year\n• MCA: ₹75,000/year\n• B.Sc: ₹50,000/year\nScholarships available for meritorious students!';
  }
  
  // ==================== PLACEMENT QUERIES (15+) ====================
  if (lowerMsg.contains('placement') || lowerMsg.contains('job') || lowerMsg.contains('recruit') || 
      lowerMsg.contains('package') || lowerMsg.contains('salary') || lowerMsg.contains('company') ||
      lowerMsg.contains('campus drive') || lowerMsg.contains('interview') || lowerMsg.contains('intern')) {
    if (lowerMsg.contains('highest') || lowerMsg.contains('top') || lowerMsg.contains('max'))
      return '🏆 Highest Package: ₹45 LPA (Google), ₹38 LPA (Amazon), ₹35 LPA (Microsoft). Multiple global offers!';
    if (lowerMsg.contains('average') || lowerMsg.contains('avg'))
      return '📊 Average Package: ₹7.2 LPA. Top companies: Google, Amazon, Microsoft, Flipkart, Infosys, TCS, Wipro, Deloitte.';
    if (lowerMsg.contains('intern') || lowerMsg.contains('internship'))
      return '💼 Internship opportunities: Paid internships starting ₹25K-50K/month. Stipend based on performance. 100% internship assistance provided.';
    if (lowerMsg.contains('profile') || lowerMsg.contains('role'))
      return '👨‍💻 Job Profiles: Software Engineer, Data Scientist, Cloud Architect, Product Manager, Business Analyst, Consultant, System Engineer.';
    if (lowerMsg.contains('batch') || lowerMsg.contains('year'))
      return '📅 2024 Placement Stats: 97% placed, 250+ companies visited, 1500+ offers made. Record-breaking placements!';
    return '💼 Placement Highlights:\n• 97% placement rate\n• ₹45 LPA highest package\n• 250+ recruiters\n• 1500+ offers\n• Top MNCs visit regularly\nNeed specific details? Ask about company, package, or role!';
  }
  
  // ==================== KYP/QUIZ QUERIES (10+) ====================
  if (lowerMsg.contains('kyp') || lowerMsg.contains('quiz') || lowerMsg.contains('certificate') || 
      lowerMsg.contains('test') || lowerMsg.contains('exam') || lowerMsg.contains('assessment') ||
      lowerMsg.contains('government') && lowerMsg.contains('certificate')) {
    if (lowerMsg.contains('enrollment') || lowerMsg.contains('register'))
      return '📝 KYP Enrollment: Free registration at kyp.beeedicollege.ac.in. Limited seats! Register now with your college ID.';
    if (lowerMsg.contains('syllabus') || lowerMsg.contains('topics'))
      return '📚 KYP Syllabus: Aptitude, Reasoning, General Knowledge, Technical Skills, Soft Skills, Communication. Mock tests available!';
    if (lowerMsg.contains('result') || lowerMsg.contains('score'))
      return '📊 KYP Results declared within 7 days. Check your scorecard online. Merit certificate for top performers.';
    if (lowerMsg.contains('validity') || lowerMsg.contains('valid') && lowerMsg.contains('certificate'))
      return '✅ Government certificate valid for lifetime. Accepted by all PSUs, banks, and government exams.';
    return '🎓 KYP Quiz: Free government-certified program!\n• Test your knowledge\n• Earn recognized certificate\n• Boost your resume\n• 5 lakh+ students enrolled\n• Open to all streams\nEnroll: kyp.beeedicollege.ac.in';
  }
  
  // ==================== HOSTEL QUERIES (10+) ====================
  if (lowerMsg.contains('hostel') || lowerMsg.contains('accommodation') || lowerMsg.contains('room') || 
      lowerMsg.contains('mess') || lowerMsg.contains('food') || lowerMsg.contains('living') ||
      lowerMsg.contains('pg') || lowerMsg.contains('rent')) {
    if (lowerMsg.contains('security') || lowerMsg.contains('safety'))
      return '🔒 24/7 security with CCTV cameras, biometric access, female wardens, and medical facility. Parents can visit anytime.';
    if (lowerMsg.contains('wifi') || lowerMsg.contains('internet'))
      return '🌐 High-speed WiFi (100 Mbps) throughout campus. 24/7 internet access in rooms, labs, and library.';
    if (lowerMsg.contains('room') && (lowerMsg.contains('type') || lowerMsg.contains('facility')))
      return '🛏️ Room types: Single occupancy, Double occupancy, Dormitory (4 sharing). Attached bathroom, AC/non-AC options available.';
    if (lowerMsg.contains('mess') || lowerMsg.contains('food'))
      return '🍽️ Mess facility: North Indian, South Indian, Chinese, Continental options. Breakfast, Lunch, Dinner, Snacks. Special diet available.';
    if (lowerMsg.contains('curfew') || lowerMsg.contains('timing'))
      return '⏰ Hostel timings: Girls hostel entry 8 PM, Boys hostel 10 PM. Late entry requires permission. Weekend passes available.';
    if (lowerMsg.contains('laundry') || lowerMsg.contains('washing'))
      return '🧺 Laundry facility: Washing machines available. Professional laundry service at ₹500/month.';
    return '🏠 Hostel Facilities:\n• Separate boys & girls hostels\n• AC/Non-AC rooms\n• 24/7 WiFi & power backup\n• Healthy mess food\n• Gym & recreation room\n• 24/7 security\n• Medical facility\nApply online for hostel allocation!';
  }
  
  // ==================== LIBRARY QUERIES (10+) ====================
  if (lowerMsg.contains('library') || lowerMsg.contains('book') || lowerMsg.contains('read') || 
      lowerMsg.contains('journal') || lowerMsg.contains('research paper') || lowerMsg.contains('e-book') ||
      lowerMsg.contains('magazine') || lowerMsg.contains('publication')) {
    if (lowerMsg.contains('e-library') || lowerMsg.contains('online') || lowerMsg.contains('digital'))
      return '💻 Digital Library: Access 500,000+ e-books, 200+ journals, IEEE, Springer, ACM, ScienceDirect. Login with college ID.';
    if (lowerMsg.contains('timing') || lowerMsg.contains('hours'))
      return '🕒 Library Hours: Monday-Saturday 8 AM to 10 PM, Sunday 10 AM to 6 PM. 24x7 study area available during exams.';
    if (lowerMsg.contains('borrow') || lowerMsg.contains('issue') || lowerMsg.contains('lending'))
      return '📖 Borrowing rules: 5 books for 15 days, ₹5/day fine for late return. Renew online up to 3 times.';
    if (lowerMsg.contains('membership') || lowerMsg.contains('card'))
      return '🪪 Library card: Free for all students. Online registration through student portal. Digital ID accepted.';
    if (lowerMsg.contains('photocopy') || lowerMsg.contains('print'))
      return '🖨️ Photocopy & Printing: ₹2/page for B&W, ₹5/page for color. Scanning free. Book binding available.';
    return '📚 Library Resources:\n• 5,00,000+ physical books\n• Digital library (24/7)\n• 200+ journals & magazines\n• Research databases\n• Reading hall (500+ seats)\n• Computer section (100 PCs)\nVisit the central library today!';
  }
  
  // ==================== SCHOLARSHIP QUERIES (10+) ====================
  if (lowerMsg.contains('scholarship') || lowerMsg.contains('financial aid') || lowerMsg.contains('grant') || 
      lowerMsg.contains('fee waiver') || lowerMsg.contains('stipend') || lowerMsg.contains('merit') && lowerMsg.contains('award')) {
    if (lowerMsg.contains('merit') || lowerMsg.contains('top'))
      return '🏅 Merit Scholarship: ₹75,000/year for top 10% students. Based on semester exam performance. Renewed automatically.';
    if (lowerMsg.contains('sc') || lowerMsg.contains('st') || lowerMsg.contains('obc') || lowerMsg.contains('caste'))
      return '👥 SC/ST/OBC Scholarship: Up to ₹50,000/year. Income certificate required. Apply through National Scholarship Portal.';
    if (lowerMsg.contains('girl') || lowerMsg.contains('women'))
      return '👩 Girls Empowerment Scholarship: ₹30,000/year for female students. Merit-based + income criteria. Special quota available.';
    if (lowerMsg.contains('sport') || lowerMsg.contains('athlete'))
      return '🏆 Sports Excellence: ₹40,000/year for state/national level players. Submit sports certificates.';
    if (lowerMsg.contains('research') || lowerMsg.contains('phd'))
      return '🔬 Research Grant: ₹2,00,000 for PhD scholars. Publish papers, attend conferences, lab funding available.';
    if (lowerMsg.contains('minority') || lowerMsg.contains('muslim') || lowerMsg.contains('christian'))
      return '🕯️ Minority Scholarship: Up to ₹35,000/year for Muslim, Sikh, Christian, Jain, Buddhist students. Government funded.';
    return '🏆 Scholarship Programs:\n• Merit: ₹75K/year\n• SC/ST/OBC: ₹50K/year\n• Girls: ₹30K/year\n• Sports: ₹40K/year\n• Research: ₹2L grant\n• Minority: ₹35K/year\nDeadline: Jan 31, 2026. Apply soon!';
  }
  
  // ==================== SPORTS QUERIES (10+) ====================
  if (lowerMsg.contains('sport') || lowerMsg.contains('game') || lowerMsg.contains('cricket') || 
      lowerMsg.contains('football') || lowerMsg.contains('tournament') || lowerMsg.contains('gym') ||
      lowerMsg.contains('fitness') || lowerMsg.contains('swimming') || lowerMsg.contains('competition')) {
    if (lowerMsg.contains('facility') || lowerMsg.contains('infrastructure'))
      return '🏟️ Sports Facilities: Olympic-size swimming pool, Basketball & Tennis courts, Football ground, Cricket pitch, Indoor stadium, Table tennis, Badminton courts.';
    if (lowerMsg.contains('coach') || lowerMsg.contains('training'))
      return '👨‍🏫 Professional coaches: National-level trainers for each sport. Daily practice sessions. Special coaching for competitions.';
    if (lowerMsg.contains('tournament') || lowerMsg.contains('event'))
      return '🏆 Annual Sports Meet in December. Inter-college tournaments: Zonal, State, National level participation. Prize money up to ₹1L.';
    if (lowerMsg.contains('gym') || lowerMsg.contains('workout'))
      return '💪 Modern gym: Cardio, Strength training, Free weights, CrossFit area. Personal trainers available. 6 AM - 10 PM.';
    if (lowerMsg.contains('swimming') || lowerMsg.contains('pool'))
      return '🏊 Olympic-size heated pool (50m). Swimming coach available. Learn-to-swim programs. Competition training.';
    if (lowerMsg.contains('yoga') || lowerMsg.contains('meditation'))
      return '🧘 Daily yoga & meditation sessions. Certified instructors. Stress management workshops. Free for all students.';
    return '🏅 Sports & Fitness:\n• 18+ sports disciplines\n• Olympic pool & gym\n• Professional coaches\n• Annual sports meet\n• Inter-college tournaments\n• Sports scholarships\nJoin the sports club today!';
  }
  
  // ==================== ACADEMIC PROGRAM QUERIES (10+) ====================
  if (lowerMsg.contains('course') || lowerMsg.contains('program') || lowerMsg.contains('degree') || 
      lowerMsg.contains('b.tech') || lowerMsg.contains('mba') || lowerMsg.contains('mca') ||
      lowerMsg.contains('b.sc') || lowerMsg.contains('b.com') || lowerMsg.contains('specialization')) {
    if (lowerMsg.contains('b.tech') || lowerMsg.contains('btech'))
      return '🔧 B.Tech Specializations: CSE, AI/ML, Data Science, Cloud Computing, Cybersecurity, ECE, Mechanical, Civil. 4-year program with industrial training.';
    if (lowerMsg.contains('mba'))
      return '💼 MBA Specializations: Marketing, Finance, HR, Operations, Business Analytics, Digital Marketing. 2-year program with internship.';
    if (lowerMsg.contains('mca'))
      return '💻 MCA: Master of Computer Applications. 2-year program. Advanced programming, AI, Cloud, Full-stack development.';
    if (lowerMsg.contains('b.sc') || lowerMsg.contains('bsc'))
      return '🔬 B.Sc Programs: Physics, Chemistry, Mathematics, Computer Science, Biotechnology, Data Science. 3-year program.';
    if (lowerMsg.contains('b.com') || lowerMsg.contains('bcom'))
      return '📊 B.Com Programs: Accountancy, Taxation, Finance, Banking & Insurance, E-Commerce. Professional certifications included.';
    if (lowerMsg.contains('phd') || lowerMsg.contains('doctorate'))
      return '🎓 PhD Programs: Engineering, Management, Science, Humanities. UGC-approved. Fellowships available. Research facilities.';
    return '📚 Academic Programs:\n• B.Tech (4 years)\n• MBA (2 years)\n• MCA (2 years)\n• B.Sc (3 years)\n• B.Com (3 years)\n• PhD Programs\nContact admissions for eligibility criteria!';
  }
  
  // ==================== FACULTY QUERIES (5+) ====================
  if (lowerMsg.contains('faculty') || lowerMsg.contains('teacher') || lowerMsg.contains('professor') || 
      lowerMsg.contains('staff') || lowerMsg.contains('lecturer')) {
    if (lowerMsg.contains('qualification') || lowerMsg.contains('phd'))
      return '👨‍🏫 Highly qualified faculty: 85% PhD holders, industry experts, published researchers. Student-teacher ratio 15:1.';
    if (lowerMsg.contains('student') && lowerMsg.contains('ratio'))
      return '📊 Student-Faculty Ratio: 15:1 ensuring personalized attention. Small class sizes for better learning.';
    return '👩‍🏫 Our Faculty: 250+ experienced professors, industry experts, and research scholars. Most have PhDs from IITs/NITs. Regular guest lectures from industry leaders.';
  }
  
  // ==================== CAMPUS FACILITIES QUERIES (10+) ====================
  if (lowerMsg.contains('campus') || lowerMsg.contains('facility') || lowerMsg.contains('infrastructure') || 
      lowerMsg.contains('building') || lowerMsg.contains('lab') || lowerMsg.contains('classroom') ||
      lowerMsg.contains('cafeteria') || lowerMsg.contains('canteen') || lowerMsg.contains('transport')) {
    if (lowerMsg.contains('lab') || lowerMsg.contains('laboratory'))
      return '🔬 Advanced Labs: AI/ML Lab, IoT Lab, Robotics Lab, Chemistry/Physics Labs, Language Lab, Electronics Lab. 24/7 access.';
    if (lowerMsg.contains('smart') && lowerMsg.contains('classroom'))
      return '📱 Smart Classrooms: Projectors, Digital boards, Recording facility, Comfortable seating, AC classrooms.';
    if (lowerMsg.contains('cafeteria') || lowerMsg.contains('canteen') || lowerMsg.contains('food court'))
      return '🍕 Multi-cuisine Cafeteria: 5 food outlets. Healthy food options. Student-run cafe. Daily specials.';
    if (lowerMsg.contains('transport') || lowerMsg.contains('bus'))
      return '🚌 College Bus Service: 20+ buses covering city routes. AC buses. GPS tracking. Safe transport for day scholars.';
    if (lowerMsg.contains('medical') || lowerMsg.contains('health') || lowerMsg.contains('clinic'))
      return '🏥 Health Center: 24/7 medical facility. Resident doctor. Free checkups. Ambulance service. Health insurance available.';
    if (lowerMsg.contains('bank') || lowerMsg.contains('atm'))
      return '🏧 Bank & ATM: SBI, HDFC, ICICI banks on campus. ATM facility. Banking hours 10 AM - 4 PM.';
    return '🏛️ Campus Facilities:\n• Smart classrooms\n• Advanced labs\n• Central library\n• Sports complex\n• Swimming pool\n• Gymnasium\n• Cafeteria\n• Medical center\n• Transport\n• Banking\nWorld-class infrastructure for holistic learning!';
  }
  
  // ==================== STUDENT LIFE QUERIES (15+) ====================
  if (lowerMsg.contains('student life') || lowerMsg.contains('club') || lowerMsg.contains('activity') || 
      lowerMsg.contains('festival') || lowerMsg.contains('event') || lowerMsg.contains('cultural') ||
      lowerMsg.contains('annual day') || lowerMsg.contains('celebration') || lowerMsg.contains('hobby')) {
    if (lowerMsg.contains('club') || lowerMsg.contains('society'))
      return '🎯 Student Clubs: Coding Club, Robotics Club, Debate Society, Music Club, Dance Club, Photography Club, Entrepreneurship Cell, NSS, NCC.';
    if (lowerMsg.contains('fest') || lowerMsg.contains('cultural') && lowerMsg.contains('fest'))
      return '🎉 Annual Cultural Fest \'BEEDI Utsav\' in February. 5 days of fun, competitions, celebrity nights, DJ nights, food festivals.';
    if (lowerMsg.contains('technical') && lowerMsg.contains('fest'))
      return '🤖 Tech Fest \'Innovation 2026\' in March. Hackathons, coding competitions, robotics challenge, paper presentations, project expo. Prize pool ₹5L.';
    if (lowerMsg.contains('calendar') || lowerMsg.contains('schedule') && lowerMsg.contains('event'))
      return '📅 Upcoming Events: Tech Fest (Mar 15-20), Sports Meet (Dec 10-15), Cultural Fest (Feb 5-10), Annual Day (Apr 25).';
    if (lowerMsg.contains('volunteer') || lowerMsg.contains('nss') || lowerMsg.contains('ncc'))
      return '🤝 Volunteer Programs: NSS, NCC, Red Cross, Animal Welfare. Social service certificates. Leadership development.';
    return '🎊 Student Life:\n• 25+ student clubs\n• Annual cultural fest\n• Technical symposium\n• Sports tournaments\n• Celebrity nights\n• Workshops & seminars\n• Industrial visits\n• Community service\nEvery day is a new adventure on campus!';
  }
  
  // ==================== PLACEMENT PREPARATION (10+) ====================
  if (lowerMsg.contains('aptitude') || lowerMsg.contains('coding') || lowerMsg.contains('interview prep') || 
      lowerMsg.contains('resume') || lowerMsg.contains('cv') || lowerMsg.contains('gd') ||
      lowerMsg.contains('group discussion') || lowerMsg.contains('hr') || lowerMsg.contains('mock interview')) {
    if (lowerMsg.contains('aptitude') || lowerMsg.contains('reasoning'))
      return '📊 Aptitude Training: Quantitative aptitude, Logical reasoning, Verbal ability. Weekly mock tests. Expert trainers.';
    if (lowerMsg.contains('coding') || lowerMsg.contains('programming'))
      return '💻 Coding Practice: DSA mastery, Competitive programming, Hackathon training. LeetCode style platform. Daily challenges.';
    if (lowerMsg.contains('resume') || lowerMsg.contains('cv'))
      return '📄 Resume Workshop: Professional resume building, LinkedIn optimization, Portfolio creation. Expert reviews available.';
    if (lowerMsg.contains('mock') || lowerMsg.contains('interview') && lowerMsg.contains('preparation'))
      return '🎯 Mock Interviews: Technical, HR, Case study interviews. Real-time feedback. Industry experts panel.';
    if (lowerMsg.contains('gd') || lowerMsg.contains('group discussion'))
      return '💬 Group Discussion Practice: Current affairs, Business topics, Technology trends. Weekly sessions. Tips & tricks.';
    return '📚 Placement Preparation:\n• Aptitude training\n• Coding practice\n• Resume building\n• Mock interviews\n• GD practice\n• Soft skills\n• Communication\n• LinkedIn profile\n100% placement assistance guaranteed!';
  }
  
  // ==================== GENERAL QUERIES (10+) ====================
  if (lowerMsg.contains('hello') || lowerMsg.contains('hi') || lowerMsg.contains('hey') || 
      lowerMsg.contains('greetings') || lowerMsg.contains('namaste')) {
    return '👋 Hello! Welcome to BEEDI College Assistant. I\'m here to help with:\n• Admissions & Courses\n• Fees & Scholarships\n• Placements & Jobs\n• Hostel & Facilities\n• Events & Activities\n• Any other questions!\nHow can I assist you today? 😊';
  }
  
  if (lowerMsg.contains('thank') || lowerMsg.contains('thanks') || lowerMsg.contains('grateful')) {
    return '🙏 You\'re welcome! Happy to help. Feel free to ask if you need anything else. Have a great day! 🎓';
  }
  
  if (lowerMsg.contains('help') || lowerMsg.contains('support') || lowerMsg.contains('assist')) {
    return '🆘 Help Center:\n• Academic helpline: +91-80001-23456\n• Admission office: +91-80001-23457\n• Hostel warden: +91-80001-23458\n• Email: help@beeedicollege.ac.in\n• Live chat: Available 9 AM - 9 PM\nWhat specific help do you need?';
  }
  
  if (lowerMsg.contains('contact') || lowerMsg.contains('phone') || lowerMsg.contains('email') || 
      lowerMsg.contains('reach') || lowerMsg.contains('call')) {
    return '📞 Contact Us:\n• Phone: +91-80001-23456\n• Email: info@beeedicollege.ac.in\n• Admissions: admissions@beeedicollege.ac.in\n• Website: www.beeedicollege.ac.in\n• Office hours: Mon-Sat, 9 AM - 5 PM';
  }
  
  if (lowerMsg.contains('location') || lowerMsg.contains('address') || lowerMsg.contains('directions') || 
      lowerMsg.contains('reach') && lowerMsg.contains('campus')) {
    return '📍 Address: BEEDI College, NH-48, Sector 62, Noida, Uttar Pradesh - 201301. Nearest metro: Noida Electronic City (5 min). Bus stop: Just outside campus.';
  }
  
  if (lowerMsg.contains('holiday') || lowerMsg.contains('vacation') || lowerMsg.contains('break')) {
    return '📅 Academic Calendar 2026:\n• Summer Break: May 15 - July 10\n• Winter Break: Dec 25 - Jan 5\n• Diwali Break: Nov 5-10\n• Holi Break: Mar 12-15\nCheck website for exact dates.';
  }
  
  if (lowerMsg.contains('exam') || lowerMsg.contains('semester') || lowerMsg.contains('result') || 
      lowerMsg.contains('marks') || lowerMsg.contains('grade')) {
    if (lowerMsg.contains('result') || lowerMsg.contains('marks'))
      return '📊 Results declared on student portal. Login with your ID. Revaluation available within 15 days.';
    if (lowerMsg.contains('exam') && (lowerMsg.contains('schedule') || lowerMsg.contains('date')))
      return '📅 Exam Schedule: Mid-sem exams Oct 15-25, End-sem exams Dec 1-15. Download from portal.';
    return '📖 Examination System:\n• Two semesters/year\n• Internal assessment 40%\n• Semester exam 60%\n• Regular exams in Dec & May\n• Supplementary exams in June\nNeed more details about exams?';
  }
  
  // ==================== SMART RESPONSES (5+) ====================
  if (lowerMsg.contains('weather') || lowerMsg.contains('temperature') || lowerMsg.contains('climate')) {
    return '☀️ Current weather at campus: Pleasant, 24°C. Check weather app for real-time updates. Campus is beautiful in all seasons!';
  }
  
  if (lowerMsg.contains('time') || lowerMsg.contains('clock') || lowerMsg.contains('schedule')) {
    return '⏰ Current campus time: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}. Regular schedule: Classes 9 AM - 5 PM. Library 8 AM - 10 PM.';
  }
  
  if (lowerMsg.contains('joke') || lowerMsg.contains('funny') || lowerMsg.contains('laugh')) {
    return '😄 Here\'s a college joke: Why did the student bring a ladder to college? Because they wanted to go to high school! 😂 Want another one?';
  }
  
  // ==================== DEFAULT RESPONSE ====================
  return '🤖 Great question! For detailed info about "$msg", please contact our helpline: +91-80001-23456 or email info@beeedicollege.ac.in. You can also visit our website or check the student portal. I\'m here to help with admissions, courses, fees, placements, hostels, scholarships, sports, events, and more! 📞';
}

void _performSearch(String query) {
  if (query.isEmpty) {
    setState(() => _searchResults = []);
    return;
  }
  
  // Expanded search items (200+ items)
  final allItems = [
    // Academic Programs (15+)
    'Academic Programs',
    'B.Tech Computer Science',
    'B.Tech Artificial Intelligence',
    'B.Tech Data Science',
    'B.Tech Cloud Computing',
    'B.Tech Cybersecurity',
    'B.Tech Electronics',
    'B.Tech Mechanical',
    'B.Tech Civil',
    'MBA Marketing',
    'MBA Finance',
    'MBA Human Resources',
    'MBA Business Analytics',
    'MBA Operations',
    'MCA Program',
    'B.Sc Computer Science',
    'B.Sc Data Science',
    'B.Sc Biotechnology',
    'B.Com Accountancy',
    'PhD Programs',
    
    // Admission (10+)
    'Admission 2026-2027',
    'Admission Process',
    'Application Form',
    'Entrance Exam',
    'Cutoff Marks',
    'Direct Admission',
    'Lateral Entry',
    'Documents Required',
    'Admission Helpline',
    'Last Date to Apply',
    
    // Scholarships (15+)
    'Scholarships',
    'Merit Scholarship',
    'SC/ST Scholarship',
    'OBC Scholarship',
    'Girls Scholarship',
    'Sports Scholarship',
    'Research Grant',
    'Minority Scholarship',
    'EWS Scholarship',
    'Defense Scholarship',
    'Single Girl Child',
    'North East Scholarship',
    'Fee Waiver',
    'Financial Aid',
    'Education Loan',
    
    // Placements (15+)
    'Placement Cell',
    'Placement Statistics',
    'Highest Package',
    'Average Package',
    'Top Recruiters',
    'Google Recruitment',
    'Amazon Jobs',
    'Microsoft Careers',
    'Internship Opportunities',
    'Campus Drive Schedule',
    'Mock Interviews',
    'Resume Building',
    'Aptitude Training',
    'Coding Practice',
    'Soft Skills Training',
    
    // Campus Facilities (20+)
    'Campus Map',
    'Library',
    'Digital Library',
    'Research Lab',
    'AI Lab',
    'Robotics Lab',
    'IoT Lab',
    'Smart Classrooms',
    'Auditorium',
    'Seminar Halls',
    'Hostel',
    'Boys Hostel',
    'Girls Hostel',
    'Mess & Cafeteria',
    'Gymnasium',
    'Swimming Pool',
    'Sports Complex',
    'Medical Center',
    'Bank & ATM',
    'Transport Bus',
    'Parking Area',
    
    // Student Life (20+)
    'Student Clubs',
    'Coding Club',
    'Robotics Club',
    'Music Club',
    'Dance Club',
    'Photography Club',
    'Entrepreneurship Cell',
    'NSS',
    'NCC',
    'Cultural Fest',
    'Tech Fest',
    'Sports Meet',
    'Annual Day',
    'Workshops',
    'Seminars',
    'Guest Lectures',
    'Industrial Visits',
    'Alumni Network',
    'Student Council',
    'College Events',
    'Hackathons',
    
    // Tools & Resources (20+)
    'Timetable',
    'Attendance Tracker',
    'Grade Calculator',
    'CGPA Predictor',
    'Study Timer',
    'Job Board',
    'KYP Quiz',
    'E-Learning Portal',
    'Online Courses',
    'Study Material',
    'Previous Papers',
    'Question Bank',
    'Lab Manuals',
    'Project Guidelines',
    'Internship Portal',
    'Research Papers',
    'Conference Alerts',
    'Competition Updates',
    'Scholarship Alert',
    'Exam Schedule',
    'Result Portal',
    
    // Important Contacts (15+)
    'Faculty Portal',
    'Faculty Directory',
    'HOD Contact',
    'Dean Office',
    'Admission Office',
    'Exam Cell',
    'Placement Office',
    'Hostel Warden',
    'Medical Officer',
    'Sports Director',
    'Library Staff',
    'Accounts Office',
    'Transport Office',
    'Security Office',
    'Student Grievance',
    
    // Rules & Regulations (10+)
    'Attendance Policy',
    'Exam Rules',
    'Hostel Rules',
    'Library Rules',
    'Dress Code',
    'Ragging Policy',
    'Anti-Ragging',
    'Discipline Committee',
    'Student Code of Conduct',
    
    // Additional Services (15+)
    'Virtual Tour',
    'College Gallery',
    'News & Updates',
    'Notifications',
    'Holiday List',
    'Academic Calendar',
    'Fee Structure',
    'Payment Portal',
    'Online Learning',
    'Career Counseling',
    'Mental Health Support',
    'Grievance Redressal',
    'Student Feedback',
    'Alumni Registration',
    'Parent Portal',
    
    // FAQs (20+)
    'How to Apply',
    'Admission Requirements',
    'Fee Payment Methods',
    'Hostel Application',
    'Scholarship Application',
    'Placement Process',
    'Internship Process',
    'Exam Registration',
    'Backlog Rules',
    'Certificate Process',
    'Transcript Request',
    'Bonafide Certificate',
    'Transfer Certificate',
    'Migration Certificate',
    'ID Card Process',
    'Library Card',
    'Bus Pass Application',
    'Gym Registration',
    'Sports Registration',
    'Club Membership',
  ];
  
  setState(() {
    _searchResults = allItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  });
}

  Color get _bg => _isDarkMode ? AC.darkBg : AC.bg;
  Color get _surface => _isDarkMode ? AC.darkSurface : AC.surface;
  Color get _cardBg => _isDarkMode ? AC.darkCard : AC.cardBg;
  Color get _textPri => _isDarkMode ? AC.darkTextPri : AC.textPri;
  Color get _textSec => _isDarkMode ? AC.darkTextSec : AC.textSec;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _bg,
      drawer: CustomDrawer(isDark: _isDarkMode),
      appBar: _buildAppBar(context),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chatbot FAB
          FloatingActionButton.small(
            heroTag: 'chatbot',
            onPressed: () => setState(() => _chatbotOpen = !_chatbotOpen),
            backgroundColor: AC.green,
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          // Scroll to top FAB
          AnimatedScale(
            scale: _showFab ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: FloatingActionButton(
              heroTag: 'scrollTop',
              onPressed: _scrollToTop,
              backgroundColor: AC.primaryBlue,
              elevation: 12,
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          BlueWhiteParticleBackground(isDark: _isDarkMode),
          CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _TickerBanner(
                  text: kTicker[_tickerIdx],
                  liveCount: _liveCount,
                  isDark: _isDarkMode,
                ),
              ),
              // NEW: Weather & Quick Info Bar
              SliverToBoxAdapter(
                child: _WeatherQuickBar(
                  weatherInfo: _weatherInfo,
                  weatherLoading: _weatherLoading,
                  attendancePercent: _attendancePercent,
                  cgpa: _cgpa,
                  isDark: _isDarkMode,
                  onTap: () => pushScreen(context, const AttendanceScreen()),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
                  child: _HeroCarousel(
                    controller: _pageCtrl,
                    currentIdx: _carouselIdx,
                    onPageChanged: (i) => setState(() => _carouselIdx = i),
                    onTap: (i) {
                      final screens = [
                        const AcademicScreen(),
                        const ResearchScreen(),
                        const StudentLifeScreen(),
                        const AdmissionScreen(),
                      ];
                      pushScreen(context, screens[i % screens.length]);
                    },
                  ),
                ),
              ),
              if (_showHajipurSpotlight)
                SliverToBoxAdapter(
                  child: _HajipurSpotlightBanner(
                    onClose: () =>
                        setState(() => _showHajipurSpotlight = false),
                    onTap: () =>
                        pushScreen(context, const HajipurVaishaliScreen()),
                  ),
                ),
              SliverToBoxAdapter(
                child: _AdmissionCountdownBanner(countdown: _countdownStr),
              ),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _statsAnim,
                  builder: (_, __) => _StatsStrip(
                    progress: _statsAnim.value,
                    isDark: _isDarkMode,
                  ),
                ),
              ),
              // NEW: Study Timer Widget
              SliverToBoxAdapter(
                child: _StudyTimerWidget(
                  timerStr: _studyTimerStr,
                  isRunning: _studyTimerRunning,
                  seconds: _studyTimerSeconds,
                  onToggle: _toggleStudyTimer,
                  onReset: () {
                    _studyTimer?.cancel();
                    setState(() {
                      _studyTimerRunning = false;
                      _studyTimerSeconds = 0;
                    });
                  },
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                  child: FadeTransition(
                    opacity: _welcomeFade,
                    child: SlideTransition(
                      position: _welcomeSlide,
                      child: _WelcomeHeroCard(
                        onExplore: () =>
                            pushScreen(context, const AcademicScreen()),
                        onApply: () =>
                            pushScreen(context, const AdmissionScreen()),
                        onQuiz: () =>
                            pushScreen(context, const StudentEntryScreen()),
                        isDark: _isDarkMode,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _QuickActionBar(
                  onTap: (s) => pushScreen(context, s),
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _SearchBarWidget(
                  open: _searchOpen,
                  controller: _searchCtrl,
                  results: _searchResults,
                  onToggle: () => setState(() {
                    _searchOpen = !_searchOpen;
                    if (!_searchOpen) _searchResults = [];
                  }),
                  onChanged: _performSearch,
                  isDark: _isDarkMode,
                ),
              ),
              // NEW: Attendance Progress Card
              SliverToBoxAdapter(
                child: _AttendanceProgressCard(
                  percent: _attendancePercent,
                  isDark: _isDarkMode,
                  onTap: () => pushScreen(context, const AttendanceScreen()),
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '🏆 BEEDI Achievements',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(child: const _AchievementsRow()),
              // NEW: Job Board Preview
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '💼 Latest Job Openings',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _JobBoardPreview(
                  bookmarked: _bookmarkedJobs,
                  onBookmark: (id) => setState(() {
                    if (_bookmarkedJobs.contains(id))
                      _bookmarkedJobs.remove(id);
                    else
                      _bookmarkedJobs.add(id);
                  }),
                  onViewAll: () => pushScreen(context, const JobBoardScreen()),
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '🔍 Explore BEEDI College',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _ExploreTabs(
                  currentTab: _exploreTab,
                  onTabChanged: (i) => setState(() => _exploreTab = i),
                  isDark: _isDarkMode,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                sliver: _ExploreGrid(
                  screenWidth: screenWidth,
                  onTap: (card) => pushScreen(context, card.screen),
                ),
              ),
              // NEW: Campus Interactive Map
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '🗺️ Interactive Campus Map',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _InteractiveCampusMap(
                  selectedPin: _selectedMapPin,
                  onPinTap: (i) => setState(
                    () => _selectedMapPin = _selectedMapPin == i ? -1 : i,
                  ),
                  isDark: _isDarkMode,
                ),
              ),
              // NEW: Alumni Spotlight
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '🌟 Alumni Spotlight',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _AlumniSpotlightSection(
                  onViewAll: () =>
                      pushScreen(context, const AlumniSpotlightScreen()),
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '✨ Why Choose BEEDI College ?',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _UniqueFeaturesSection(isDark: _isDarkMode),
              ),
              // NEW: Scholarship Finder
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '🎯 Scholarship Finder',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _ScholarshipFinderWidget(
                  applied: _scholarshipApplied,
                  onApply: (i) => setState(() {
                    _scholarshipApplied[i] = !_scholarshipApplied[i];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _scholarshipApplied[i]
                              ? '✅ Applied for ${kScholarships[i]['name']}!'
                              : '❌ Application withdrawn',
                        ),
                        backgroundColor: _scholarshipApplied[i]
                            ? AC.green
                            : AC.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }),
                  isDark: _isDarkMode,
                ),
              ),
              // NEW: Leaderboard Preview
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '🏅 BEEDI College Leaderboard',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _LeaderboardPreview(
                  onViewAll: () =>
                      pushScreen(context, const LeaderboardScreen()),
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '💬 Student Stories',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(child: const _TestimonialSection()),
              SliverToBoxAdapter(
                child: _RatingWidget(
                  currentRating: _userRating,
                  onRate: (r) => setState(() => _userRating = r),
                  isDark: _isDarkMode,
                ),
              ),
              // NEW: Fee Installment Tracker
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '💳 Fee Payment Tracker',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _FeeTrackerWidget(
                  currentInstallment: _feeInstallment,
                  onPay: (i) {
                    setState(() => _feeInstallment = i);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Redirecting to payment gateway...'),
                        backgroundColor: AC.green,
                      ),
                    );
                  },
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '📰 Latest News',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _NewsFeed(
                  onTap: () => pushScreen(context, const OpportunitiesScreen()),
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '📸 Campus Gallery',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(child: const _PhotoGallery()),
              SliverToBoxAdapter(
                child: _CampusBanner(
                  onTap: () => pushScreen(context, const ContactsScreen()),
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '📅 Upcoming Events',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _EventsSection(
                  rsvpd: _rsvpd,
                  onRSVP: (i) {
                    setState(() => _rsvpd[i] = !_rsvpd[i]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _rsvpd[i]
                              ? '✅ RSVP confirmed for ${kEvents[i]['title']}!'
                              : '❌ RSVP cancelled',
                        ),
                        backgroundColor: _rsvpd[i] ? AC.green : AC.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  onTap: () => pushScreen(context, const StudentLifeScreen()),
                ),
              ),
              // NEW: College Radio
              SliverToBoxAdapter(
                child: _CollegeRadioWidget(
                  isPlaying: _radioPlaying,
                  onToggle: () =>
                      setState(() => _radioPlaying = !_radioPlaying),
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(child: const _PlacementHighlightStrip()),
              SliverToBoxAdapter(
                child: _CommunityPollWidget(isDark: _isDarkMode),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '📍 Hajipur-Vaishali Initiatives',
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(
                child: _HajipurInitiativesSection(isDark: _isDarkMode),
              ),
              // NEW: Grade Calculator Preview
              SliverToBoxAdapter(
                child: _GradeCalculatorPreview(
                  cgpa: _cgpa,
                  onTap: () =>
                      pushScreen(context, const GradeCalculatorScreen()),
                  isDark: _isDarkMode,
                ),
              ),
              SliverToBoxAdapter(child: const _DownloadBanner()),
              SliverToBoxAdapter(
                child: _Footer(onNav: (s) => pushScreen(context, s)),
              ),
            ],
          ),
          // NEW: Notification Panel Overlay
          if (_notifPanelOpen)
            _NotificationPanel(
              notifications: _notifications,
              onClose: () => setState(() => _notifPanelOpen = false),
              onDismiss: (i) => setState(() {
                _notifications.removeAt(i);
                if (_notificationCount > 0) _notificationCount--;
              }),
              isDark: _isDarkMode,
            ),
          // NEW: Chatbot Overlay
          if (_chatbotOpen)
            _ChatbotOverlay(
              messages: _chatMessages,
              controller: _chatInput,
              onSend: _sendChatMessage,
              onClose: () => setState(() => _chatbotOpen = false),
              isDark: _isDarkMode,
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          gradient: _isDarkMode ? AC.darkAppBarGrad : AC.appBarGrad,
          boxShadow: const [
            BoxShadow(
              color: Color(0x88000000),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) =>
                      Transform.scale(scale: _pulseAnim.value, child: child),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'B',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'BEEDI College',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00FF88),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hajipur, Vaishali · +91 93041 67626',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Dark mode toggle
                IconButton(
                  icon: Icon(
                    _isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
                  tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
                ),
                // Notification bell
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => setState(() {
                        _notifPanelOpen = !_notifPanelOpen;
                        if (_notifPanelOpen) _notificationCount = 0;
                      }),
                    ),
                    if (_notificationCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Text(
                            '$_notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() => _searchOpen = !_searchOpen);
                    _scroll.animateTo(
                      400,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 1: WEATHER + QUICK INFO BAR
// ════════════════════════════════════════════════════════════
class _WeatherQuickBar extends StatelessWidget {
  final String weatherInfo;
  final bool weatherLoading;
  final int attendancePercent;
  final double cgpa;
  final bool isDark;
  final VoidCallback onTap;

  const _WeatherQuickBar({
    required this.weatherInfo,
    required this.weatherLoading,
    required this.attendancePercent,
    required this.cgpa,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AC.darkSurface : const Color(0xFFE8F4FD);
    final textColor = isDark ? Colors.white70 : AC.textSec;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AC.primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: weatherLoading
                ? Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AC.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Loading weather...',
                        style: TextStyle(color: textColor, fontSize: 11),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Text(
                        weatherInfo,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
          Container(width: 1, height: 22, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: attendancePercent >= 75 ? AC.green : AC.red,
                ),
                const SizedBox(width: 4),
                Text(
                  'Att: $attendancePercent%',
                  style: TextStyle(
                    color: attendancePercent >= 75 ? AC.green : AC.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 22, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(width: 10),
          Row(
            children: [
              const Icon(Icons.school_rounded, size: 14, color: AC.gold),
              const SizedBox(width: 4),
              Text(
                'CGPA: $cgpa',
                style: const TextStyle(
                  color: AC.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
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
//  NEW FEATURE 2: STUDY TIMER WIDGET
// ════════════════════════════════════════════════════════════
class _StudyTimerWidget extends StatelessWidget {
  final String timerStr;
  final bool isRunning;
  final int seconds;
  final VoidCallback onToggle, onReset;
  final bool isDark;

  const _StudyTimerWidget({
    required this.timerStr,
    required this.isRunning,
    required this.seconds,
    required this.onToggle,
    required this.onReset,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRunning
              ? [const Color(0xFF1565C0), const Color(0xFF1E88E5)]
              : [
                  isDark ? AC.darkCard : AC.surface,
                  isDark ? AC.darkSurface : AC.offWhite,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AC.primaryBlue.withOpacity(0.3)),
        boxShadow: isRunning
            ? [
                BoxShadow(
                  color: AC.primaryBlue.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isRunning
                  ? Colors.white.withOpacity(0.2)
                  : AC.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.timer_rounded,
              color: isRunning ? Colors.white : AC.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Timer',
                  style: TextStyle(
                    color: isRunning
                        ? Colors.white70
                        : (isDark ? Colors.white54 : AC.textSec),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  timerStr,
                  style: TextStyle(
                    color: isRunning ? Colors.white : AC.primaryBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (seconds > 0 && !isRunning)
                GestureDetector(
                  onTap: onReset,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AC.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: AC.red,
                      size: 18,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isRunning ? Colors.white : AC.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isRunning ? Colors.white : AC.primaryBlue)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: isRunning ? AC.primaryBlue : Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRunning ? 'Pause' : 'Start',
                        style: TextStyle(
                          color: isRunning ? AC.primaryBlue : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
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
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 3: ATTENDANCE PROGRESS CARD
// ════════════════════════════════════════════════════════════
class _AttendanceProgressCard extends StatelessWidget {
  final int percent;
  final bool isDark;
  final VoidCallback onTap;

  const _AttendanceProgressCard({
    required this.percent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = percent < 75;
    final color = isLow ? AC.red : (percent >= 90 ? AC.green : AC.orange);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AC.darkCard : AC.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.4)),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.how_to_reg_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Status',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AC.textSec,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$percent% Present',
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Text(
                    isLow
                        ? '⚠️ Low'
                        : (percent >= 90 ? '✅ Excellent' : '👍 Good'),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Minimum required: 75%',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : AC.textMuted,
                    fontSize: 10,
                  ),
                ),
                Text(
                  'View Details →',
                  style: TextStyle(
                    color: AC.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 4: JOB BOARD PREVIEW
// ════════════════════════════════════════════════════════════
class _JobBoardPreview extends StatelessWidget {
  final List<String> bookmarked;
  final void Function(String) onBookmark;
  final VoidCallback onViewAll;
  final bool isDark;

  const _JobBoardPreview({
    required this.bookmarked,
    required this.onBookmark,
    required this.onViewAll,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: kJobBoard.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final job = kJobBoard[i];
              final c = job['color'] as Color;
              final isBookmarked = bookmarked.contains('job_$i');
              return Container(
                width: 200,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AC.darkCard : AC.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          job['logo'] as String,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            job['company'] as String,
                            style: TextStyle(
                              color: c,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onBookmark('job_$i'),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: isBookmarked ? AC.gold : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job['role'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : AC.textPri,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 10,
                          color: isDark ? Colors.white38 : AC.textMuted,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          job['location'] as String,
                          style: TextStyle(
                            color: isDark ? Colors.white38 : AC.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AC.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              job['package'] as String,
                              style: const TextStyle(
                                color: AC.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: c.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '📅 ${job['deadline']}',
                            style: TextStyle(
                              color: c,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GestureDetector(
            onTap: onViewAll,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AC.primaryBlue.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
                color: AC.primaryBlue.withOpacity(0.05),
              ),
              child: const Center(
                child: Text(
                  'View All Jobs →',
                  style: TextStyle(
                    color: AC.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 5: INTERACTIVE CAMPUS MAP
// ════════════════════════════════════════════════════════════
class _InteractiveCampusMap extends StatelessWidget {
  final int selectedPin;
  final void Function(int) onPinTap;
  final bool isDark;

  const _InteractiveCampusMap({
    required this.selectedPin,
    required this.onPinTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D2040), const Color(0xFF1565C0)]
              : [const Color(0xFFBBDEFB), const Color(0xFFE3F2FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AC.primaryBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AC.primaryBlue.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grid lines for map effect
          CustomPaint(
            painter: _MapGridPainter(isDark: isDark),
            child: const SizedBox.expand(),
          ),
          // Map pins
          ...kCampusMap.asMap().entries.map((entry) {
            final i = entry.key;
            final pin = entry.value;
            final isSelected = selectedPin == i;
            return Positioned(
              left:
                  (pin['x'] as double) *
                      (MediaQuery.of(context).size.width - 56) -
                  20,
              top: (pin['y'] as double) * 200 + 10,
              child: GestureDetector(
                onTap: () => onPinTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AC.primaryBlue
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(isSelected ? 12 : 8),
                    boxShadow: [
                      BoxShadow(
                        color: AC.primaryBlue.withOpacity(
                          isSelected ? 0.5 : 0.2,
                        ),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : AC.primaryBlue.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pin['icon'] as String,
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            pin['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // Label
          Positioned(
            top: 10,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AC.primaryBlue.withOpacity(0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'BEEDI Colllege Campus Map',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (selectedPin >= 0)
            Positioned(
              bottom: 10,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AC.darkBlue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      kCampusMap[selectedPin]['icon'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      kCampusMap[selectedPin]['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Tap for directions →',
                      style: TextStyle(color: Color(0xFF90CAF9), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final bool isDark;
  const _MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : AC.primaryBlue).withOpacity(0.08)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => old.isDark != isDark;
}

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 6: ALUMNI SPOTLIGHT SECTION
// ════════════════════════════════════════════════════════════
class _AlumniSpotlightSection extends StatelessWidget {
  final VoidCallback onViewAll;
  const _AlumniSpotlightSection({required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: kAlumniSpotlight.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          if (i == kAlumniSpotlight.length) {
            return GestureDetector(
              onTap: onViewAll,
              child: Container(
                width: 130,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AC.primaryBlue.withOpacity(0.4),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_rounded, color: AC.primaryBlue, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'View All\nAlumni',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AC.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final a = kAlumniSpotlight[i];
          final c = a['color'] as Color;
          return Container(
            width: 185,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(a['img'] as String),
                      radius: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a['name'] as String,
                            style: TextStyle(
                              color: c,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            a['role'] as String,
                            style: const TextStyle(
                              color: AC.textSec,
                              fontSize: 9,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    a['batch'] as String,
                    style: TextStyle(
                      color: c,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"${a['quote']}"',
                  style: const TextStyle(
                    color: AC.textSec,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 7: SCHOLARSHIP FINDER WIDGET
// ════════════════════════════════════════════════════════════
class _ScholarshipFinderWidget extends StatelessWidget {
  final List<bool> applied;
  final void Function(int) onApply;
  final bool isDark;

  const _ScholarshipFinderWidget({
    required this.applied,
    required this.onApply,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Column(
        children: kScholarships.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final isApplied = applied[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AC.darkCard : AC.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isApplied
                    ? AC.green.withOpacity(0.5)
                    : AC.primaryBlue.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(s['icon']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['name']!,
                        style: TextStyle(
                          color: isDark ? Colors.white : AC.textPri,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        s['criteria']!,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : AC.textSec,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AC.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s['amount']!,
                              style: const TextStyle(
                                color: AC.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Deadline: ${s['deadline']}',
                            style: const TextStyle(
                              color: AC.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onApply(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isApplied
                          ? const LinearGradient(
                              colors: [AC.green, Color(0xFF388E3C)],
                            )
                          : const LinearGradient(
                              colors: [AC.primaryBlue, AC.darkBlue],
                            ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isApplied ? '✓ Applied' : 'Apply',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 8: LEADERBOARD PREVIEW
// ════════════════════════════════════════════════════════════
class _LeaderboardPreview extends StatelessWidget {
  final VoidCallback onViewAll;
  final bool isDark;
  const _LeaderboardPreview({required this.onViewAll, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AC.darkCard : AC.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AC.primaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AC.primaryBlue.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ...kLeaderboard
              .take(3)
              .map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Text(
                        l['badge'] as String,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundImage: NetworkImage(l['avatar'] as String),
                        radius: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l['name'] as String,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withOpacity(0.87)
                                    : AC.textPri,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              l['dept'] as String,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withOpacity(0.54)
                                    : AC.textSec,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AC.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AC.gold.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${l['score']} pts',
                          style: const TextStyle(
                            color: AC.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AC.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AC.primaryBlue.withOpacity(0.3)),
              ),
              child: const Center(
                child: Text(
                  'View Full Leaderboard →',
                  style: TextStyle(
                    color: AC.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 9: FEE PAYMENT TRACKER
// ════════════════════════════════════════════════════════════
class _FeeTrackerWidget extends StatelessWidget {
  final int currentInstallment;
  final void Function(int) onPay;
  final bool isDark;

  const _FeeTrackerWidget({
    required this.currentInstallment,
    required this.onPay,
    required this.isDark,
  });

  static const _installments = [
    {
      'label': '1st Installment',
      'amount': '₹21,250',
      'due': 'Paid ✓',
      'paid': true,
    },
    {
      'label': '2nd Installment',
      'amount': '₹21,250',
      'due': 'Dec 31',
      'paid': false,
    },
    {
      'label': '3rd Installment',
      'amount': '₹21,250',
      'due': 'Mar 31',
      'paid': false,
    },
    {
      'label': '4th Installment',
      'amount': '₹21,250',
      'due': 'Jun 30',
      'paid': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AC.darkCard : AC.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AC.primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💳', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Annual Fee: ₹85,000',
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.87) : AC.textPri,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AC.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(currentInstallment + 1) * 25}% Paid',
                  style: const TextStyle(
                    color: AC.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _installments.asMap().entries.map((entry) {
              final i = entry.key;
              final inst = entry.value;
              final isPaid = i <= currentInstallment;
              return Expanded(
                child: GestureDetector(
                  onTap: !isPaid ? () => onPay(i) : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AC.green.withOpacity(0.1)
                          : AC.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPaid
                            ? AC.green.withOpacity(0.4)
                            : AC.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isPaid
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isPaid ? AC.green : AC.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          inst['amount'] as String,
                          style: TextStyle(
                            color: isPaid
                                ? AC.green
                                : (isDark ? Colors.white70 : AC.textPri),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          isPaid ? 'Paid' : (inst['due'] as String),
                          style: TextStyle(
                            color: isPaid ? AC.green : AC.red,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 10: COLLEGE RADIO WIDGET
// ════════════════════════════════════════════════════════════
class _CollegeRadioWidget extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onToggle;
  final bool isDark;

  const _CollegeRadioWidget({
    required this.isPlaying,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPlaying
              ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
              : [
                  isDark ? AC.darkCard : const Color(0xFFE3F2FD),
                  isDark ? AC.darkSurface : const Color(0xFFF5F9FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AC.primaryBlue.withOpacity(0.3)),
        boxShadow: isPlaying
            ? [
                BoxShadow(
                  color: AC.primaryBlue.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPlaying
                    ? Colors.white.withOpacity(0.2)
                    : AC.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('📻', style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BEEDI FM 90.5',
                    style: TextStyle(
                      color: isPlaying
                          ? Colors.white
                          : (isDark
                                ? Colors.white.withOpacity(0.87)
                                : AC.textPri),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    isPlaying
                        ? '🎵 Now Playing: Campus Vibes Mix'
                        : 'College Radio Station',
                    style: TextStyle(
                      color: isPlaying
                          ? Colors.white70
                          : (isDark ? Colors.white54 : AC.textSec),
                      fontSize: 11,
                    ),
                  ),
                  if (isPlaying) ...[
                    const SizedBox(height: 6),
                    // Animated equalizer bars
                    Row(
                      children: List.generate(
                        12,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 3,
                          height: (8 + (i % 4) * 6).toDouble(),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              0.7 + (i % 3) * 0.1,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPlaying ? Colors.white : AC.primaryBlue,
                  boxShadow: [
                    BoxShadow(
                      color: (isPlaying ? Colors.white : AC.primaryBlue)
                          .withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isPlaying ? AC.primaryBlue : Colors.white,
                  size: 28,
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
//  NEW FEATURE 11: GRADE CALCULATOR PREVIEW
// ════════════════════════════════════════════════════════════
class _GradeCalculatorPreview extends StatelessWidget {
  final double cgpa;
  final VoidCallback onTap;
  final bool isDark;

  const _GradeCalculatorPreview({
    required this.cgpa,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final gradeColor = cgpa >= 9.0
        ? AC.green
        : (cgpa >= 7.5 ? AC.primaryBlue : AC.orange);
    final gradeLabel = cgpa >= 9.0
        ? 'Outstanding'
        : (cgpa >= 7.5 ? 'Distinction' : 'First Class');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AC.darkCard : AC.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gradeColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: gradeColor.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [gradeColor, gradeColor.withOpacity(0.7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradeColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cgpa.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'CGPA',
                    style: TextStyle(color: Colors.white70, fontSize: 8),
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
                    'Academic Performance',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : AC.textSec,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    gradeLabel,
                    style: TextStyle(
                      color: gradeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MiniSubject('Math', 9.0, gradeColor),
                      const SizedBox(width: 8),
                      _MiniSubject('DSA', 8.5, gradeColor),
                      const SizedBox(width: 8),
                      _MiniSubject('OS', 8.0, gradeColor),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AC.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSubject extends StatelessWidget {
  final String subject;
  final double grade;
  final Color color;
  const _MiniSubject(this.subject, this.grade, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      '$subject: $grade',
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 12: NOTIFICATION PANEL OVERLAY
// ════════════════════════════════════════════════════════════
class _NotificationPanel extends StatelessWidget {
  final List<Map<String, String>> notifications;
  final VoidCallback onClose;
  final void Function(int) onDismiss;
  final bool isDark;

  const _NotificationPanel({
    required this.notifications,
    required this.onClose,
    required this.onDismiss,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.fromLTRB(60, 70, 10, 0),
                decoration: BoxDecoration(
                  color: isDark ? AC.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
                      child: Row(
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withOpacity(0.87)
                                  : AC.textPri,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onClose,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: AC.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ...notifications.asMap().entries.map((entry) {
                      final i = entry.key;
                      final n = entry.value;
                      return Dismissible(
                        key: Key('notif_$i'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => onDismiss(i),
                        background: Container(
                          color: AC.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        child: ListTile(
                          leading: Text(
                            n['icon']!,
                            style: const TextStyle(fontSize: 20),
                          ),
                          title: Text(
                            n['title']!,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withOpacity(0.87)
                                  : AC.textPri,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            n['time']!,
                            style: TextStyle(
                              color: isDark ? Colors.white38 : AC.textMuted,
                              fontSize: 10,
                            ),
                          ),
                          dense: true,
                        ),
                      );
                    }),
                    if (notifications.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'All caught up! ✓',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : AC.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NEW FEATURE 13: CHATBOT OVERLAY
// ════════════════════════════════════════════════════════════
class _ChatbotOverlay extends StatefulWidget {
  final List<Map<String, String>> messages;
  final TextEditingController controller;
  final void Function(String) onSend;
  final VoidCallback onClose;
  final bool isDark;

  const _ChatbotOverlay({
    required this.messages,
    required this.controller,
    required this.onSend,
    required this.onClose,
    required this.isDark,
  });

  @override
  State<_ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends State<_ChatbotOverlay> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void didUpdateWidget(_ChatbotOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AC.darkCard : Colors.white;
    final textColor = widget.isDark
        ? Colors.white.withOpacity(0.87)
        : AC.textPri;

    return Positioned(
      bottom: 80,
      right: 10,
      left: 10,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AC.darkBlue, AC.primaryBlue]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BEEDI AI Assistant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Ask me anything!',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(12),
                itemCount: widget.messages.length,
                itemBuilder: (_, i) {
                  final msg = widget.messages[i];
                  final isBot = msg['role'] == 'bot';
                  return Align(
                    alignment: isBot
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65,
                      ),
                      decoration: BoxDecoration(
                        color: isBot
                            ? AC.primaryBlue.withOpacity(0.12)
                            : AC.primaryBlue,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isBot ? 2 : 14),
                          bottomRight: Radius.circular(isBot ? 14 : 2),
                        ),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: isBot ? textColor : Colors.white,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isDark ? AC.darkSurface : const Color(0xFFF5F9FF),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      style: TextStyle(color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Ask about admissions, fees...',
                        hintStyle: TextStyle(
                          color: widget.isDark ? Colors.white38 : AC.textMuted,
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AC.primaryBlue.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AC.primaryBlue.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AC.primaryBlue),
                        ),
                        filled: true,
                        fillColor: widget.isDark ? AC.darkCard : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      onSubmitted: widget.onSend,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => widget.onSend(widget.controller.text),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AC.darkBlue, AC.primaryBlue],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
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
  }
}

// ════════════════════════════════════════════════════════════
//  UPDATED EVENTS SECTION WITH RSVP
// ════════════════════════════════════════════════════════════
class _EventsSection extends StatelessWidget {
  final List<bool> rsvpd;
  final void Function(int) onRSVP;
  final VoidCallback onTap;

  const _EventsSection({
    required this.rsvpd,
    required this.onRSVP,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 175,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: kEvents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final e = kEvents[i];
          final c = e['color'] as Color;
          final isRsvpd = rsvpd[i];
          return Container(
            width: 190,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isRsvpd ? c.withOpacity(0.12) : c.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRsvpd ? c.withOpacity(0.6) : c.withOpacity(0.3),
                width: isRsvpd ? 1.5 : 1,
              ),
              boxShadow: isRsvpd
                  ? [
                      BoxShadow(
                        color: c.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      e['icon'] as String,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        e['date'] as String,
                        style: TextStyle(
                          color: c,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  e['title'] as String,
                  style: const TextStyle(
                    color: AC.textPri,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 10,
                      color: AC.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      e['time'] as String,
                      style: const TextStyle(color: AC.textMuted, fontSize: 9),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => onRSVP(i),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isRsvpd ? c : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c.withOpacity(0.6)),
                    ),
                    child: Center(
                      child: Text(
                        isRsvpd ? '✓ RSVP\'d' : 'RSVP',
                        style: TextStyle(
                          color: isRsvpd ? Colors.white : c,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  HAJIPUR SPOTLIGHT BANNER (unchanged)
// ════════════════════════════════════════════════════════════
class _HajipurSpotlightBanner extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onTap;
  const _HajipurSpotlightBanner({required this.onClose, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AC.primaryBlue.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Text('📍', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hajipur-Vaishali Campus Expansion',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'New 50-acre campus coming soon! 🎓',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Learn More →',
                            style: TextStyle(
                              color: Color(0xFF1565C0),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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

// ════════════════════════════════════════════════════════════
//  HAJIPUR INITIATIVES SECTION
// ════════════════════════════════════════════════════════════
class _HajipurInitiativesSection extends StatelessWidget {
  final bool isDark;
  const _HajipurInitiativesSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 4;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: kHajipurFeatures.length,
        itemBuilder: (_, i) {
          final f = kHajipurFeatures[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AC.darkCard : AC.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AC.primaryBlue.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(f['icon'] as String, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  f['title'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white.withOpacity(0.87) : AC.textPri,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  f['desc'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : AC.textSec,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  TICKER BANNER
// ════════════════════════════════════════════════════════════
class _TickerBanner extends StatelessWidget {
  final String text;
  final int liveCount;
  final bool isDark;
  const _TickerBanner({
    required this.text,
    required this.liveCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF050E1F), const Color(0xFF0D47A1)]
              : [const Color(0xFF0D47A1), const Color(0xFF1E88E5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                text,
                key: ValueKey(text),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FF88),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$liveCount online',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
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
//  HERO CAROUSEL
// ════════════════════════════════════════════════════════════
class _HeroCarousel extends StatelessWidget {
  final PageController controller;
  final int currentIdx;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onTap;

  const _HeroCarousel({
    required this.controller,
    required this.currentIdx,
    required this.onPageChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = (screenHeight * 0.28).clamp(0.0, 215.0);

    return Column(
      children: [
        SizedBox(
          height: carouselHeight,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: kCarousel.length,
            itemBuilder: (_, i) {
              final slide = kCarousel[i];
              return GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: (slide['color'] as Color).withOpacity(0.6),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          slide['img'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: slide['color'] as Color),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                (slide['color'] as Color).withOpacity(0.85),
                              ],
                              stops: const [0.2, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              slide['badge'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 18,
                          right: 18,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      slide['title'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      slide['sub'] as String,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AC.primaryBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  slide['cta'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            kCarousel.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: currentIdx == i ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: currentIdx == i ? AC.primaryBlue : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ADMISSION COUNTDOWN BANNER
// ════════════════════════════════════════════════════════════
class _AdmissionCountdownBanner extends StatelessWidget {
  final String countdown;
  const _AdmissionCountdownBanner({required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AC.primaryBlue.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('⏳', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admission Closing Soon!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Last date: December 31, 2024 · Don\'t miss out',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Apply →',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ResponsiveCountdown(countdown: countdown),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveCountdown extends StatelessWidget {
  final String countdown;
  const ResponsiveCountdown({super.key, required this.countdown});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final parts = countdown.split(' ');
    if (screenWidth < 500) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCompactPart(parts[0], 'd'),
          const SizedBox(width: 8),
          _buildCompactPart(parts[1], 'h'),
          const SizedBox(width: 8),
          _buildCompactPart(parts[2], 'm'),
          const SizedBox(width: 8),
          _buildCompactPart(parts[3], 's'),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: parts.map((part) {
        final isNum = part.contains(RegExp(r'\d'));
        return Text(
          part,
          style: TextStyle(
            color: isNum ? AC.yellow : Colors.white.withOpacity(0.7),
            fontSize: isNum ? 20 : 11,
            fontWeight: isNum ? FontWeight.w900 : FontWeight.w500,
            fontFamily: isNum ? 'monospace' : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactPart(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: AC.yellow,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════
//  STATS STRIP
// ════════════════════════════════════════════════════════════
class _StatsStrip extends StatelessWidget {
  final double progress;
  final bool isDark;
  const _StatsStrip({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth < 400 ? 80.0 : 90.0;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? AC.darkCard : AC.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AC.primaryBlue.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AC.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 12,
        children: kStats
            .map(
              (s) => Opacity(
                opacity: progress.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: (0.6 + 0.4 * progress).clamp(0.0, 1.0),
                  child: SizedBox(
                    width: itemWidth,
                    child: Column(
                      children: [
                        Text(s['icon']!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                          s['value']!,
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          s['label']!,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : AC.textSec,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  WELCOME HERO CARD
// ════════════════════════════════════════════════════════════
class _WelcomeHeroCard extends StatelessWidget {
  final VoidCallback onExplore, onApply, onQuiz;
  final bool isDark;
  const _WelcomeHeroCard({
    required this.onExplore,
    required this.onApply,
    required this.onQuiz,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AC.darkCard : AC.cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AC.primaryBlue.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: AC.primaryBlue.withOpacity(0.15),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 5,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF1E88E5),
                  Color(0xFF42A5F5),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to BEEDI College',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white.withOpacity(0.87)
                                  : AC.textPri,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Excellence · Innovation · Bihar\'s Pride',
                            style: TextStyle(
                              fontSize: 11,
                              color: AC.primaryBlue.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF1565C0).withOpacity(0.4),
                        ),
                      ),
                      child: const Text(
                        'NAAC A+',
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Bihar\'s premier institution for higher education, research & skill development. Join 15,000+ students shaping India\'s future.',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : AC.textSec,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: isSmallScreen
                      ? WrapAlignment.center
                      : WrapAlignment.start,
                  children: [
                    _WelcomeBtn(
                      label: 'Explore Courses',
                      icon: Icons.explore_rounded,
                      color: const Color(0xFF1E88E5),
                      outline: true,
                      onTap: onExplore,
                    ),
                    _WelcomeBtn(
                      label: 'Apply Now',
                      icon: Icons.send_rounded,
                      color: const Color(0xFF1565C0),
                      outline: false,
                      onTap: onApply,
                    ),
                    _WelcomeBtn(
                      label: 'Student Test',
                      icon: Icons.assignment_rounded,
                      color: const Color(0xFF42A5F5),
                      outline: true,
                      onTap: onQuiz,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outline;
  final VoidCallback onTap;
  const _WelcomeBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.outline,
    required this.onTap,
  });
  @override
  State<_WelcomeBtn> createState() => _WelcomeBtnState();
}

class _WelcomeBtnState extends State<_WelcomeBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: widget.outline
                ? null
                : LinearGradient(
                    colors: [widget.color, widget.color.withOpacity(0.7)],
                  ),
            color: widget.outline
                ? widget.color.withOpacity(_hovered ? 0.2 : 0.1)
                : null,
            borderRadius: BorderRadius.circular(10),
            border: widget.outline
                ? Border.all(color: widget.color.withOpacity(0.6), width: 1.5)
                : null,
            boxShadow: !widget.outline && _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.outline ? widget.color : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.outline ? widget.color : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  QUICK ACTION BAR
// ════════════════════════════════════════════════════════════
class _QuickActionBar extends StatelessWidget {
  final void Function(Widget) onTap;
  final bool isDark;
  const _QuickActionBar({required this.onTap, required this.isDark});

  static const _actions = [
    {
      'label': 'Apply',
      'icon': Icons.send_rounded,
      'color': Color(0xFF1565C0),
      'emoji': '📋',
    },
    {
      'label': 'Library',
      'icon': Icons.local_library_rounded,
      'color': Color(0xFF42A5F5),
      'emoji': '📚',
    },
    {
      'label': 'Fees',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF1E88E5),
      'emoji': '💳',
    },
    {
      'label': 'Events',
      'icon': Icons.event_rounded,
      'color': Color(0xFF0D47A1),
      'emoji': '🗓️',
    },
    {
      'label': 'Alumni',
      'icon': Icons.groups_rounded,
      'color': Color(0xFF1565C0),
      'emoji': '🤝',
    },
    {
      'label': 'Results',
      'icon': Icons.star_rounded,
      'color': Color(0xFF1E88E5),
      'emoji': '📊',
    },
    {
      'label': 'Hostel',
      'icon': Icons.hotel_rounded,
      'color': Color(0xFF0D47A1),
      'emoji': '🏠',
    },
    {
      'label': 'Jobs',
      'icon': Icons.work_rounded,
      'color': Color(0xFF42A5F5),
      'emoji': '💼',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      const AdmissionScreen(),
      const ELibraryScreen(),
      const ContactsScreen(),
      const StudentLifeScreen(),
      const AlumniSpotlightScreen(),
      const StudentEntryScreen(),
      const ContactsScreen(),
      const JobBoardScreen(),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AC.darkCard : AC.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300.withOpacity(isDark ? 0.2 : 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: TextStyle(
              color: isDark ? Colors.white54 : AC.textSec,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 400 ? 4 : 4;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _actions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (_, i) {
                  final a = _actions[i];
                  return _QuickBtn(
                    emoji: a['emoji'] as String,
                    label: a['label'] as String,
                    color: a['color'] as Color,
                    onTap: () => onTap(screens[i]),
                    isDark: isDark,
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

class _QuickBtn extends StatefulWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;
  const _QuickBtn({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });
  @override
  State<_QuickBtn> createState() => _QuickBtnState();
}

class _QuickBtnState extends State<_QuickBtn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_pressed ? 0.9 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.isDark
              ? widget.color.withOpacity(0.15)
              : widget.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SEARCH BAR WITH RESULTS
// ════════════════════════════════════════════════════════════
class _SearchBarWidget extends StatelessWidget {
  final bool open;
  final TextEditingController controller;
  final List<String> results;
  final VoidCallback onToggle;
  final void Function(String) onChanged;
  final bool isDark;

  const _SearchBarWidget({
    required this.open,
    required this.controller,
    required this.results,
    required this.onToggle,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AC.darkCard : AC.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: open
                      ? AC.primaryBlue
                      : (isDark ? Colors.white12 : Colors.grey.shade200),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AC.textSec, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Search courses, faculty, events...',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : AC.textSec,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AC.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '⌘ K',
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: open
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AC.darkCard : AC.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AC.primaryBlue.withOpacity(0.5)),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.87)
                          : AC.textPri,
                    ),
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: 'Type to search...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.38)
                            : AC.textSec,
                      ),
                      border: InputBorder.none,
                      icon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ),
                if (results.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AC.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AC.primaryBlue.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: results
                          .map(
                            (r) => ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.search_rounded,
                                color: AC.primaryBlue,
                                size: 16,
                              ),
                              title: Text(
                                r,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.87)
                                      : AC.textPri,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: AC.textMuted,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SECTION HEADER
// ════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white.withOpacity(0.87) : AC.textPri,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ACHIEVEMENTS ROW
// ════════════════════════════════════════════════════════════
class _AchievementsRow extends StatelessWidget {
  const _AchievementsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: kAchievements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final a = kAchievements[i];
          final c = a['color'] as Color;
          return Container(
            width: 165,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.withOpacity(0.35), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      a['emoji'] as String,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  a['title'] as String,
                  style: TextStyle(
                    color: c,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 2),
                Text(
                  a['sub'] as String,
                  style: const TextStyle(color: AC.textMuted, fontSize: 9),
                  maxLines: 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  EXPLORE TABS
// ════════════════════════════════════════════════════════════
class _ExploreTabs extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;
  final bool isDark;
  const _ExploreTabs({
    required this.currentTab,
    required this.onTabChanged,
    required this.isDark,
  });

  static const _tabs = ['All', 'Academic', 'Research', 'Student', 'Sports'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == currentTab;
          return GestureDetector(
            onTap: () => onTabChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AC.primaryBlue
                    : (isDark ? AC.darkCard : AC.surface),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AC.primaryBlue
                      : (isDark ? Colors.white12 : Colors.grey.shade300),
                  width: 1,
                ),
              ),
              child: Text(
                _tabs[i],
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : (isDark ? Colors.white54 : AC.textSec),
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  EXPLORE GRID
// ════════════════════════════════════════════════════════════
class _ExploreGrid extends StatelessWidget {
  final double screenWidth;
  final void Function(CardData) onTap;
  const _ExploreGrid({required this.screenWidth, required this.onTap});

  @override
  Widget build(BuildContext context) {
    int cols = screenWidth >= 900 ? 4 : (screenWidth >= 600 ? 3 : 2);
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _ExploreCard(data: kCards[i], onTap: () => onTap(kCards[i])),
        childCount: kCards.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
        childAspectRatio: 0.76,
      ),
    );
  }
}

class _ExploreCard extends StatefulWidget {
  final CardData data;
  final VoidCallback onTap;
  const _ExploreCard({required this.data, required this.onTap});
  @override
  State<_ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<_ExploreCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false, _pressed = false;
  late AnimationController _glowCtrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.3,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..scale(_pressed ? 0.93 : (_hovered ? 1.04 : 1.0)),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.data.accent.withOpacity(_hovered ? 0.4 : 0.1),
                blurRadius: _hovered ? 30 : 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: _hovered
                  ? widget.data.accent.withOpacity(0.8)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.data.networkImg,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: widget.data.accent.withOpacity(0.25),
                    child: Icon(
                      widget.data.icon,
                      color: widget.data.accent,
                      size: 50,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.35),
                        Colors.black.withOpacity(0.88),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _glow,
                            builder: (_, __) => Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: widget.data.accent.withOpacity(
                                  _hovered ? _glow.value * 0.5 : 0.22,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                widget.data.icon,
                                color: Colors.white,
                                size: 17,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.data.accent.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.data.tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        widget.data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.data.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: [
                                    widget.data.accent,
                                    widget.data.accent2,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedOpacity(
                            opacity: _hovered ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 13,
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
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  UNIQUE FEATURES SECTION
// ════════════════════════════════════════════════════════════
class _UniqueFeaturesSection extends StatefulWidget {
  final bool isDark;
  const _UniqueFeaturesSection({required this.isDark});
  @override
  State<_UniqueFeaturesSection> createState() => _UniqueFeaturesSectionState();
}

class _UniqueFeaturesSectionState extends State<_UniqueFeaturesSection> {
  int? _expandedIdx;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: Column(
        children: List.generate(kUniqueFeatures.length, (i) {
          final f = kUniqueFeatures[i];
          final c = f['color'] as Color;
          final isExp = _expandedIdx == i;
          return GestureDetector(
            onTap: () => setState(() => _expandedIdx = isExp ? null : i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isExp
                    ? c.withOpacity(0.08)
                    : (widget.isDark ? AC.darkCard : AC.surface),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isExp
                      ? c.withOpacity(0.5)
                      : (widget.isDark ? Colors.white12 : Colors.grey.shade200),
                  width: 1.5,
                ),
                boxShadow: isExp
                    ? [
                        BoxShadow(
                          color: c.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            f['icon'] as String,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f['title'] as String,
                              style: TextStyle(
                                color: isExp
                                    ? c
                                    : (widget.isDark
                                          ? Colors.white
                                          : AC.textPri),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              f['tag'] as String,
                              style: TextStyle(
                                color: c.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isExp
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: c,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: isExp
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Padding(
                      padding: const EdgeInsets.fromLTRB(54, 8, 0, 0),
                      child: Text(
                        f['desc'] as String,
                        style: TextStyle(
                          color: widget.isDark ? Colors.white54 : AC.textSec,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  TESTIMONIALS SECTION
// ════════════════════════════════════════════════════════════
class _TestimonialSection extends StatefulWidget {
  const _TestimonialSection();
  @override
  State<_TestimonialSection> createState() => _TestimonialSectionState();
}

class _TestimonialSectionState extends State<_TestimonialSection> {
  final PageController _pc = PageController(viewportFraction: 0.88);
  int _idx = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = (screenHeight * 0.22).clamp(0.0, 195.0);

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _pc,
            itemCount: kTestimonials.length,
            onPageChanged: (i) => setState(() => _idx = i),
            itemBuilder: (_, i) {
              final t = kTestimonials[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AC.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AC.primaryBlue.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AC.primaryBlue.withOpacity(0.1),
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
                        CircleAvatar(
                          backgroundImage: NetworkImage(t['img']!),
                          radius: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['name']!,
                                style: const TextStyle(
                                  color: AC.textPri,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                t['batch']!,
                                style: const TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            int.parse(t['rating']!),
                            (_) => const Icon(
                              Icons.star_rounded,
                              color: AC.gold,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '❝',
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 28,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t['text']!,
                      style: const TextStyle(
                        color: AC.textSec,
                        fontSize: 12,
                        height: 1.55,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            kTestimonials.length,
            (i) => GestureDetector(
              onTap: () => _pc.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _idx == i ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _idx == i ? AC.primaryBlue : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  RATING WIDGET
// ════════════════════════════════════════════════════════════
class _RatingWidget extends StatelessWidget {
  final int currentRating;
  final ValueChanged<int> onRate;
  final bool isDark;
  const _RatingWidget({
    required this.currentRating,
    required this.onRate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AC.darkCard, AC.darkSurface]
              : [const Color(0xFFE3F2FD), const Color(0xFFF5F9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AC.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Rate Your BEEDI Experience',
                style: TextStyle(
                  color: isDark ? Colors.white : AC.textPri,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < currentRating;
              return GestureDetector(
                onTap: () => onRate(i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()..scale(filled ? 1.2 : 1.0),
                  transformAlignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: filled ? AC.gold : Colors.grey.shade400,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          if (currentRating > 0) ...[
            const SizedBox(height: 10),
            Text(
              [
                '',
                'Poor',
                'Fair',
                'Good',
                'Great',
                'Excellent! 🎉',
              ][currentRating],
              style: TextStyle(
                color: [
                  Colors.transparent,
                  Colors.red,
                  Colors.orange,
                  Colors.blue,
                  Colors.green,
                  Colors.green,
                ][currentRating],
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 4),
          const Text(
            '4.9 / 5 · Based on 15,487 student reviews',
            style: TextStyle(color: AC.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NEWS FEED
// ════════════════════════════════════════════════════════════
class _NewsFeed extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;
  const _NewsFeed({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: kNews.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final n = kNews[i];
          final tagColors = {
            'Innovation': const Color(0xFF1E88E5),
            'Achievement': AC.gold,
            'Sports': const Color(0xFF42A5F5),
            'Startup': const Color(0xFF1565C0),
          };
          final tc = tagColors[n['tag']] ?? const Color(0xFF1E88E5);
          return GestureDetector(
            onTap: onTap,
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: isDark ? AC.darkCard : AC.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          n['img']!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(height: 100, color: AC.surface),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tc,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            n['tag']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['title']!,
                          style: TextStyle(
                            color: isDark ? Colors.white : AC.textPri,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              n['date']!,
                              style: const TextStyle(
                                color: AC.textMuted,
                                fontSize: 9,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              n['read']!,
                              style: const TextStyle(
                                color: Color(0xFF1565C0),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
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
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PHOTO GALLERY
// ════════════════════════════════════════════════════════════
class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: kGallery.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final g = kGallery[i];
          return _GalleryItem(img: g['img']!, label: g['label']!);
        },
      ),
    );
  }
}

class _GalleryItem extends StatefulWidget {
  final String img, label;
  const _GalleryItem({required this.img, required this.label});
  @override
  State<_GalleryItem> createState() => _GalleryItemState();
}

class _GalleryItemState extends State<_GalleryItem> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _hovered ? 160 : 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AC.primaryBlue.withOpacity(_hovered ? 0.3 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AC.surface),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_hovered)
                const Center(
                  child: Icon(
                    Icons.zoom_in_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  CAMPUS BANNER
// ════════════════════════════════════════════════════════════
class _CampusBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CampusBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = (screenHeight * 0.15).clamp(0.0, 130.0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 18, 14, 6),
        height: bannerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AC.primaryBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://picsum.photos/id/180/800/300',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AC.surface),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AC.bg.withOpacity(0.88), Colors.transparent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '📍 Visit Our Campus',
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'BEEDI Campus, Hajipur, Vaishali',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Get Directions →',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PLACEMENT HIGHLIGHT STRIP
// ════════════════════════════════════════════════════════════
class _PlacementHighlightStrip extends StatelessWidget {
  const _PlacementHighlightStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 18, 14, 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AC.primaryBlue.withOpacity(0.4),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💼', style: TextStyle(fontSize: 24)),
              SizedBox(width: 10),
              Text(
                'Placement Highlights 2024',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 400 ? 1 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: 3.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: const [
                  _PlaceStat('₹45 LPA', 'Highest Package'),
                  _PlaceStat('₹7.2 LPA', 'Average Package'),
                  _PlaceStat('250+', 'Companies Visited'),
                  _PlaceStat('97%', 'Placement Rate'),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Top Recruiters: Google · Microsoft · Amazon · TCS · Infosys · HDFC · Wipro · Accenture',
            style: TextStyle(
              color: Color(0xFFBBDEFB),
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceStat extends StatelessWidget {
  final String value, label;
  const _PlaceStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withOpacity(0.15)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AC.gold,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFBBDEFB), fontSize: 9),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  COMMUNITY POLL WIDGET
// ════════════════════════════════════════════════════════════
class _CommunityPollWidget extends StatefulWidget {
  final bool isDark;
  const _CommunityPollWidget({required this.isDark});
  @override
  State<_CommunityPollWidget> createState() => _CommunityPollWidgetState();
}

class _CommunityPollWidgetState extends State<_CommunityPollWidget> {
  int? _voted;
  final _options = ['B.Tech CSE', 'MBA', 'B.Sc Research', 'BBA', 'Other'];
  final _votes = [5023, 2404, 2032, 1656, 990];
  int get _totalVotes => _votes.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 18, 14, 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.isDark ? AC.darkCard : AC.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AC.primaryBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AC.primaryBlue.withOpacity(0.1),
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
              const Text('📊', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Community Poll',
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Which course are you most interested in?',
                      style: TextStyle(
                        color: widget.isDark ? Colors.white : AC.textPri,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final pct = _voted != null ? (_votes[i] / _totalVotes) : 0.0;
            final isWinner = _voted != null && _votes[i] == _votes.reduce(max);
            return GestureDetector(
              onTap: _voted == null ? () => setState(() => _voted = i) : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: _voted == i
                      ? AC.primaryBlue.withOpacity(0.1)
                      : (widget.isDark ? AC.darkSurface : AC.cardBg),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _voted == i
                        ? AC.primaryBlue
                        : (widget.isDark
                              ? Colors.white12
                              : Colors.grey.shade200),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    if (_voted != null)
                      Positioned.fill(
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: pct,
                          child: Container(
                            decoration: BoxDecoration(
                              color: (isWinner ? AC.gold : AC.primaryBlue)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              color: _voted == i
                                  ? AC.primaryBlue
                                  : (widget.isDark
                                        ? Colors.white70
                                        : AC.textSec),
                              fontSize: 13,
                              fontWeight: _voted == i
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_voted != null) ...[
                          if (isWinner)
                            const Text('🏆 ', style: TextStyle(fontSize: 12)),
                          Text(
                            '${(_votes[i] / _totalVotes * 100).round()}%',
                            style: TextStyle(
                              color: isWinner ? AC.gold : AC.textSec,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          Text(
            _voted != null
                ? '${_totalVotes.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} total votes'
                : 'Tap to vote · Results reveal instantly',
            style: const TextStyle(color: AC.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  DOWNLOAD BANNER
// ════════════════════════════════════════════════════════════
class _DownloadBanner extends StatelessWidget {
  const _DownloadBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 18, 14, 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AC.primaryBlue.withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 500;
          if (isSmallScreen) {
            return Column(
              children: [
                const Text('📱', style: TextStyle(fontSize: 42)),
                const SizedBox(height: 8),
                const Text(
                  'Download BEEDI App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Everything on the go — fees, results, events & more',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StoreBadge(
                      label: 'App Store',
                      icon: Icons.apple,
                      bgColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    _StoreBadge(
                      label: 'Play Store',
                      icon: Icons.android,
                      bgColor: Colors.white,
                    ),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              const Text('📱', style: TextStyle(fontSize: 42)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Download BEEDI App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Everything on the go — fees, results, events & more',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StoreBadge(
                          label: 'App Store',
                          icon: Icons.apple,
                          bgColor: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        _StoreBadge(
                          label: 'Play Store',
                          icon: Icons.android,
                          bgColor: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StoreBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  const _StoreBadge({
    required this.label,
    required this.icon,
    required this.bgColor,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF1565C0)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1565C0),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}









































// ════════════════════════════════════════════════════════════
//  FOOTER
// ════════════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  final void Function(Widget) onNav;
  const _Footer({required this.onNav});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 500;

    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'BEEDI College',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'BEEDI College, Hajipur, Vaishali, Bihar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Empowering Minds · Shaping Futures',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isSmallScreen ? 12 : 20,
            runSpacing: 10,
            children: [
              _FL('About', () => onNav(const ContactsScreen())),
              _FL('Admission', () => onNav(const AdmissionScreen())),
              _FL('Research', () => onNav(const ResearchScreen())),
              if (!isSmallScreen)
                _FL('KYP Quiz', () => onNav(const KYPQuizScreen())),
              _FL('Careers', () => onNav(const OpportunitiesScreen())),
              _FL('Contact', () => onNav(const ContactsScreen())),
              _FL('Job Board', () => onNav(const JobBoardScreen())),
              _FL('Scholarships', () => onNav(const ScholarshipScreen())),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialBtn(Icons.facebook, Colors.white),
              const SizedBox(width: 10),
              _SocialBtn(Icons.telegram, Colors.white),
              const SizedBox(width: 10),
              _SocialBtn(Icons.link, Colors.white),
              const SizedBox(width: 10),
              _SocialBtn(Icons.camera_alt, Colors.white),
              const SizedBox(width: 10),
              _SocialBtn(Icons.play_circle_outline_rounded, Colors.white),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 10),
          Text(
            '© 2024 BEEDI College. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Widget _FL(String label, VoidCallback onTap) => GestureDetector(
  onTap: onTap,
  child: Text(
    label,
    style: const TextStyle(color: Colors.white70, fontSize: 12),
  ),
);

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SocialBtn(this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    ),
    child: Icon(icon, color: color, size: 17),
  );
}





















// ════════════════════════════════════════════════════════════
//  CUSTOM DRAWER (UPDATED WITH DARK MODE)
// ════════════════════════════════════════════════════════════
class CustomDrawer extends StatelessWidget {
  final bool isDark;
  const CustomDrawer({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: isDark ? AC.darkSurface : AC.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1565C0),
                  Color(0xFF1E88E5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(26)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'B',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'BEEDI College',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'NAAC A+ · Hajipur, Vaishali',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _DStat('15K+', 'Students'),
                    const SizedBox(width: 18),
                    _DStat('550+', 'Faculty'),
                    const SizedBox(width: 18),
                    _DStat('97%', 'Placed'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: kDrawerItems.length,
              itemBuilder: (ctx, i) {
                final item = kDrawerItems[i];
                return _DrawerTile(
                  label: item.label,
                  icon: item.icon,
                  color: item.color,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(ctx);
                    pushScreen(ctx, item.screen);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              '© 2024 BEEDI College',
              style: TextStyle(
                color: isDark ? Colors.white24 : Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _DStat(String v, String l) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      v,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    ),
    Text(
      l,
      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9),
    ),
  ],
);

class _DrawerTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _DrawerTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });
  @override
  State<_DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<_DrawerTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: _hovered ? widget.color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, color: widget.color, size: 20),
          ),
          title: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: widget.isDark ? Colors.white : AC.textPri,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: AC.textMuted,
          ),
          onTap: widget.onTap,
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PARTICLE BACKGROUND (UPDATED WITH DARK MODE)
// ════════════════════════════════════════════════════════════
class BlueWhiteParticleBackground extends StatefulWidget {
  final bool isDark;
  const BlueWhiteParticleBackground({super.key, required this.isDark});
  @override
  State<BlueWhiteParticleBackground> createState() =>
      _BlueWhiteParticleBgState();
}

class _BlueWhiteParticleBgState extends State<BlueWhiteParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_BlueDot> _dots = [];
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 28; i++) {
      _dots.add(
        _BlueDot(
          x: _rand.nextDouble(),
          y: _rand.nextDouble(),
          r: _rand.nextDouble() * 3 + 1,
          speed: _rand.nextDouble() * 0.2 + 0.03,
          phase: _rand.nextDouble() * 2 * pi,
          opacity: _rand.nextDouble() * 0.1 + 0.02,
          colorIdx: _rand.nextInt(3),
        ),
      );
    }
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
      builder: (_, __) => CustomPaint(
        painter: _BlueDotPainter(
          dots: _dots,
          t: _ctrl.value,
          isDark: widget.isDark,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BlueDot {
  final double x, y, r, speed, phase, opacity;
  final int colorIdx;
  const _BlueDot({
    required this.x,
    required this.y,
    required this.r,
    required this.speed,
    required this.phase,
    required this.opacity,
    required this.colorIdx,
  });
}

class _BlueDotPainter extends CustomPainter {
  final List<_BlueDot> dots;
  final double t;
  final bool isDark;
  static const _colors = [
    Color(0xFF1E88E5),
    Color(0xFF42A5F5),
    Color(0xFF1565C0),
  ];
  const _BlueDotPainter({
    required this.dots,
    required this.t,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in dots) {
      final ft = (t * d.speed + d.phase) % 1.0;
      final dx = d.x * size.width + sin(ft * 2 * pi + d.phase) * 20;
      final dy = (d.y + ft * 0.3) % 1.0 * size.height;
      canvas.drawCircle(
        Offset(dx, dy),
        d.r,
        Paint()
          ..color = _colors[d.colorIdx].withOpacity(
            d.opacity * (isDark ? 2 : 1),
          )
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_BlueDotPainter old) => old.t != t || old.isDark != isDark;
}

// ════════════════════════════════════════════════════════════
//  STUDENT ENTRY SCREEN
// ════════════════════════════════════════════════════════════
class StudentEntryScreen extends StatelessWidget {
  const StudentEntryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(backgroundColor: AC.bg, body: StudentTestScreen());
}

// ════════════════════════════════════════════════════════════
//  NEW DESTINATION SCREENS
// ════════════════════════════════════════════════════════════

// class JobBoardScreen extends StatelessWidget {
//   const JobBoardScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: AC.bg,
//     appBar: _detailAppBar('Job Board', const Color(0xFF1E88E5)),
//     body: _detailBody(
//       '💼',
//       'Campus Placement Jobs',
//       'Latest job openings from 250+ companies visiting BEEDI College.',
//       const Color(0xFF1E88E5),
//       [
//         'Google Software Engineer L3 – ₹45 LPA',
//         'Amazon AWS Cloud Architect – ₹38 LPA',
//         'Microsoft Data Scientist – ₹35 LPA',
//         'Paytm ML Engineer Intern – ₹50K/month',
//         'Infosys Systems Engineer – ₹6.5 LPA',
//         'TCS Digital – ₹7.5 LPA',
//       ],
//     ),
//   );
// }

// class CampusMapScreen extends StatelessWidget {
//   const CampusMapScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: AC.bg,
//     appBar: _detailAppBar('Campus Map', const Color(0xFF0D47A1)),
//     body: _detailBody(
//       '🗺️',
//       'Interactive Campus Map',
//       'Navigate BEEDI\'s 100-acre campus with our interactive map.',
//       const Color(0xFF0D47A1),
//       [
//         'Main Academic Block – Central location',
//         'AI Research Lab – Building B, 3rd Floor',
//         'Olympic Pool & Sports Complex',
//         'Girls & Boys Hostels – East Wing',
//         'Central Library – 24/7 Open',
//         'Innovation Hub & Incubator Center',
//       ],
//     ),
//   );
// }

// class ScholarshipScreen extends StatelessWidget {
//   const ScholarshipScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: AC.bg,
//     appBar: _detailAppBar('Scholarships', const Color(0xFF42A5F5)),
//     body: _detailBody(
//       '🏆',
//       'Scholarship Finder',
//       'Find and apply for scholarships worth crores every year.',
//       const Color(0xFF42A5F5),
//       [
//         'Merit Scholarship – ₹75,000/year for top 10%',
//         'SC/ST Fellowship – ₹50,000/year',
//         'Sports Excellence – ₹40,000/year',
//         'Research Grant – ₹2,00,000 for PhD',
//         'Girls Empowerment – ₹30,000/year',
//         'National Scholarship Portal integration',
//       ],
//     ),
//   );
// }

// class StudyTimerScreen extends StatelessWidget {
//   const StudyTimerScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: AC.bg,
//     appBar: _detailAppBar('Study Timer', const Color(0xFF1565C0)),
//     body: _detailBody(
//       '⏱️',
//       'Pomodoro Study Timer',
//       'Boost your productivity with focused study sessions.',
//       const Color(0xFF1565C0),
//       [
//         '25-minute focused study sessions',
//         '5-minute short breaks',
//         'Long break after 4 Pomodoros',
//         'Track daily study hours',
//         'Weekly progress reports',
//         'Streak tracking for motivation',
//       ],
//     ),
//   );
// }

// class GradeCalculatorScreen extends StatelessWidget {
//   const GradeCalculatorScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: AC.bg,
//     appBar: _detailAppBar('Grade Calculator', const Color(0xFF1E88E5)),
//     body: _detailBody(
//       '📊',
//       'CGPA & Grade Calculator',
//       'Calculate your CGPA, semester GPA and expected grades.',
//       const Color(0xFF1E88E5),
//       [
//         'Semester-wise GPA calculator',
//         'CGPA predictor based on targets',
//         'Subject-wise grade tracker',
//         'Grade improvement planner',
//         'Percentage to CGPA converter',
//         'Export results as PDF',
//       ],
//     ),
//   );
// }

// class TimetableScreen extends StatelessWidget {
//   const TimetableScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: AC.bg,
//     appBar: _detailAppBar('Timetable', const Color(0xFF0D47A1)),
//     body: _detailBody(
//       '📅',
//       'Class Timetable',
//       'Your personalized class schedule and exam timetable.',
//       const Color(0xFF0D47A1),
//       [
//         'Mon: Mathematics 9AM, Physics 11AM',
//         'Tue: DSA Lab 10AM, English 2PM',
//         'Wed: OS 9AM, Networking 11AM',
//         'Thu: Project Work 10AM-1PM',
//         'Fri: Seminar/Guest Lecture',
//         'Export and sync with Google Calendar',
//       ],
//     ),
//   );
//}

// class AttendanceScreen extends StatelessWidget {
//   const AttendanceScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: AC.bg,
//     appBar: _detailAppBar('Attendance', const Color(0xFF42A5F5)),
//     body: _detailBody(
//       '✅',
//       'Attendance Tracker',
//       'Monitor your attendance across all subjects in real-time.',
//       const Color(0xFF42A5F5),
//       [
//         'Overall Attendance: 87%',
//         'Mathematics: 92% (22/24 classes)',
//         'Physics: 85% (17/20 classes)',
//         'DSA: 88% (21/24 classes)',
//         'Minimum required: 75% per subject',
//         'Get alerts when attendance drops below threshold',
//       ],
//     ),
//   );
// }

// class LeaderboardScreen extends StatelessWidget {
//   const LeaderboardScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: AC.bg,
//     appBar: _detailAppBar('Leaderboard', const Color(0xFF1565C0)),
//     body: _detailBody(
//       '🏅',
//       'BEEDI Student Leaderboard',
//       'Top performers across academics, sports, and activities.',
//       const Color(0xFF1565C0),
//       [
//         '🥇 Priya Sharma – CSE – 9,850 pts',
//         '🥈 Arjun Mehta – MBA – 9,720 pts',
//         '🥉 Sneha Roy – Physics – 9,650 pts',
//         '⭐ Rohit Kumar – ECE – 9,520 pts',
//         '⭐ Anjali Gupta – BBA – 9,410 pts',
//         'Rankings updated weekly based on academics + activities',
//       ],
//     ),
//   );
// }

// class AlumniSpotlightScreen extends StatelessWidget {
//   const AlumniSpotlightScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: AC.bg,
//     appBar: _detailAppBar('Alumni Spotlight', const Color(0xFF1E88E5)),
//     body: _detailBody(
//       '🌟',
//       'Our Distinguished Alumni',
//       'BEEDI alumni are making waves globally across all fields.',
//       const Color(0xFF1E88E5),
//       [
//         'Dr. Amit Verma – CTO, Zomato',
//         'Kavya Singh – IAS Officer, Bihar Cadre',
//         'Rahul Jha – NASA Researcher, USA',
//         'Meera Pandey – Forbes 30 Under 30',
//         'Sanjay Sinha – Founder, EduTech Unicorn',
//         'Connect via Alumni Portal for mentorship',
//       ],
//     ),
//   );
// }

// ════════════════════════════════════════════════════════════
//  DETAIL APP BAR & BODY HELPERS
// ════════════════════════════════════════════════════════════
AppBar _detailAppBar(String title, Color accent) => AppBar(
  title: Text(
    title,
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w900,
      fontSize: 18,
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  elevation: 0,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [const Color(0xFF0D47A1), accent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
  ),
);

Widget _detailBody(
  String emoji,
  String title,
  String desc,
  Color accent,
  List<String> features,
) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AC.bg, AC.bg2],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF0D47A1), accent.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Key Highlights',
                  style: TextStyle(
                    color: AC.textPri,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ...features.map(
                  (f) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AC.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: accent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(
                              color: AC.textPri,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.5),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        'Learn More →',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
}

// ════════════════════════════════════════════════════════════
//  EXISTING DESTINATION SCREENS (UNCHANGED)
// ════════════════════════════════════════════════════════════
