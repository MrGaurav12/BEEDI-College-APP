import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// ═══════════════════════════════════════════════════════════════
//  ENUMS & MODELS
// ═══════════════════════════════════════════════════════════════

enum QuizState { topic, quiz, result, review, leaderboard, settings, analytics }

enum Difficulty { easy, medium, hard, all }

enum SortOption { alphabetical, questionCount, difficulty }

class QuizAttempt {
  final String topic;
  final int score;
  final int total;
  final DateTime date;
  final int timeTakenSeconds;
  final bool isPracticeMode;

  QuizAttempt({
    required this.topic,
    required this.score,
    required this.total,
    required this.date,
    required this.timeTakenSeconds,
    required this.isPracticeMode,
  });

  double get percentage => (score / total) * 100;
  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
  });
}

// ═══════════════════════════════════════════════════════════════
//  APP COLOR PALETTE
// ═══════════════════════════════════════════════════════════════

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF2E7D32);
  static const Color secondaryLight = Color(0xFF388E3C);
  static const Color accent = Color(0xFF00BCD4);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F9FF);
  static const Color surface = Color(0xFFECF4FF);
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFB8C00);
  static const Color textDark = Color(0xFF0D1B2A);
  static const Color textMid = Color(0xFF37474F);
  static const Color textLight = Color(0xFF78909C);
  static const Color cardShadow = Color(0x1A1565C0);
  static const Color greenGrad1 = Color(0xFF1B5E20);
  static const Color greenGrad2 = Color(0xFF43A047);
  static const Color blueGrad1 = Color(0xFF0D47A1);
  static const Color blueGrad2 = Color(0xFF42A5F5);
}

// ═══════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ═══════════════════════════════════════════════════════════════

class BSCITScreen extends StatefulWidget {
  const BSCITScreen({super.key});

  @override
  State<BSCITScreen> createState() => _BSCITScreenState();
}

class _BSCITScreenState extends State<BSCITScreen>
    with TickerProviderStateMixin {
  // ─── State ───────────────────────────────────────────────────
  QuizState _currentState = QuizState.topic;
  String _selectedTopic = '';
  List<Map<String, dynamic>> _currentQuestions = [];
  List<int?> _userAnswers = [];
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _showExplanation = false;
  bool _isPracticeMode = true;
  bool _isDarkMode = false;
  bool _isSoundEnabled = true;
  bool _isTimerEnabled = true;
  int _questionTimeLimit = 30;
  int _remainingTime = 30;
  Timer? _questionTimer;
  int _totalQuizTime = 0;
  Timer? _totalTimer;
  Difficulty _selectedDifficulty = Difficulty.all;
  SortOption _sortOption = SortOption.alphabetical;
  String _searchQuery = '';
  int _streakCount = 0;
  int _totalPoints = 0;
  int _quizzesCompleted = 0;
  List<QuizAttempt> _attemptHistory = [];
  List<Achievement> _achievements = [];
  bool _showHint = false;
  int _hintsUsed = 0;
  int _maxHints = 3;
  bool _isBookmarked = false;
  List<int> _bookmarkedQuestions = [];
  Map<String, int> _topicBestScores = {};
  bool _showConfetti = false;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  late AnimationController _timerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _timerAnimation;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _reviewIndex = 0;
  bool _showCorrectOnly = false;
  bool _showWrongOnly = false;

 final Map<String, List<Map<String, dynamic>>> quizData = {
  "1. Introduction to Computers": [
    {
      "question": "निम्न में से कौन स्टोरेज डिवाइस है?",
      "options": ["Keyboard", "Hard Disk", "Mouse", "Printer"],
      "answer": 1,
      "explanation": "Hard Disk एक स्टोरेज डिवाइस है जो डेटा स्थायी रूप से स्टोर करता है।",
      "difficulty": "easy",
      "hint": "यह आपके सारे डेटा को सेव करके रखता है।",
      "points": 10
    },
    {
      "question": "कंप्यूटर की पहली पीढ़ी में किसका उपयोग हुआ?",
      "options": ["Microprocessors", "Integrated Circuits", "Vacuum Tubes", "Transistors"],
      "answer": 2,
      "explanation": "पहली पीढ़ी (1940-1956) के कंप्यूटरों में वैक्यूम ट्यूब का उपयोग हुआ।",
      "difficulty": "easy",
      "hint": "ये बल्ब की तरह दिखते थे और बहुत गर्म होते थे।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सा पोर्टेबल स्टोरेज डिवाइस है?",
      "options": ["Internal Hard Disk", "CPU", "Pen Drive", "RAM"],
      "answer": 2,
      "explanation": "Pen Drive (USB drive) पोर्टेबल स्टोरेज डिवाइस है जिसे आप कहीं भी ले जा सकते हैं।",
      "difficulty": "easy",
      "hint": "यह छोटा और ढोने लायक होता है।",
      "points": 10
    },
    {
      "question": "HDMI का पूरा नाम क्या है?",
      "options": ["High Digital Multimedia Interface", "High Display Multimedia Interface", "High Definition Multimedia Interface", "High Definition Media Interface"],
      "answer": 2,
      "explanation": "HDMI आधुनिक ऑडियो-वीडियो कनेक्शन का स्टैंडर्ड है।",
      "difficulty": "medium",
      "hint": "यह TV, मॉनिटर, लैपटॉप में होता है।",
      "points": 15
    },
    {
      "question": "निम्न में से कौन सी कंप्यूटर जनरेशन में हुआ?",
      "options": ["Fourth Generation", "Second Generation", "Third Generation", "First Generation"],
      "answer": 1,
      "explanation": "Transistors की खोज दूसरी पीढ़ी (1956-1963) में हुई।",
      "difficulty": "medium",
      "hint": "पहली पीढ़ी में वैक्यूम ट्यूब थे।",
      "points": 15
    },
    {
      "question": "निम्न में से कौन सी एक्सटर्नल मेमोरी है?",
      "options": ["Cache", "ROM", "Pen Drive", "RAM"],
      "answer": 2,
      "explanation": "Pen Drive एक्सटर्नल मेमोरी है जिसे बाहर से लगाया जा सकता है।",
      "difficulty": "easy",
      "hint": "यह USB पोर्ट में लगती है।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सा इनपुट डिवाइस है?",
      "options": ["Printer", "Speaker", "Keyboard", "Monitor"],
      "answer": 2,
      "explanation": "Keyboard इनपुट डिवाइस है क्योंकि यह कंप्यूटर में डेटा भेजता है।",
      "difficulty": "easy",
      "hint": "इससे हम कंप्यूटर को कमांड देते हैं।",
      "points": 10
    },
    {
      "question": "कंप्यूटर की स्पीड किसमें मापी जाती है?",
      "options": ["MB", "KB", "GB", "GHz"],
      "answer": 3,
      "explanation": "CPU स्पीड GHz (Gigahertz) में मापी जाती है।",
      "difficulty": "medium",
      "hint": "यह प्रोसेसर की घड़ी की गति है।",
      "points": 15
    },
    {
      "question": "कंप्यूटर में डेटा प्रोसेसिंग का सही क्रम क्या है?",
      "options": ["Storage → Input → Process → Output", "Input → Output → Process → Storage", "Process → Input → Output → Storage", "Input → Process → Output → Storage"],
      "answer": 3,
      "explanation": "सही क्रम है: पहले इनपुट (डेटा डालें) → फिर प्रोसेस (कैलकुलेशन) → आउटपुट (परिणाम) → स्टोरेज (सेव करें)।",
      "difficulty": "medium",
      "hint": "IPOS Cycle याद रखें।",
      "points": 15
    },
    {
      "question": "निम्न में से कौन सा ऑप्टिकल स्टोरेज डिवाइस है?",
      "options": ["Pen Drive", "Hard Disk", "SSD", "DVD"],
      "answer": 3,
      "explanation": "DVD (Digital Versatile Disc) एक ऑप्टिकल स्टोरेज डिवाइस है जिसे laser से पढ़ा जाता है।",
      "difficulty": "medium",
      "hint": "इसमें laser का उपयोग होता है।",
      "points": 15
    },
    {
      "question": "निम्न में से कौन सा आउटपुट डिवाइस नहीं है?",
      "options": ["Printer", "Monitor", "Scanner", "Speaker"],
      "answer": 2,
      "explanation": "Scanner एक इनपुट डिवाइस है जो दस्तावेज़ों को डिजिटल बनाता है।",
      "difficulty": "easy",
      "hint": "यह बाहर से कंप्यूटर में डेटा लाता है।",
      "points": 10
    },
    {
      "question": "CPU का पूरा नाम क्या है?",
      "options": ["Central Program Unit", "Central Process Utility", "Computer Personal Unit", "Central Processing Unit"],
      "answer": 3,
      "explanation": "CPU (Central Processing Unit) कंप्यूटर का मस्तिष्क है जो सभी गणनाएं करता है।",
      "difficulty": "easy",
      "hint": "यह सभी निर्देशों को प्रोसेस करता है।",
      "points": 10
    },
    {
      "question": "कंप्यूटर की जनरेशन कितनी होती है?",
      "options": ["3", "6", "4", "5"],
      "answer": 3,
      "explanation": "अब तक कंप्यूटर की 5 जनरेशन हो चुकी हैं। 5वीं जनरेशन AI पर आधारित है।",
      "difficulty": "easy",
      "hint": "वैक्यूम ट्यूब से AI तक का सफर।",
      "points": 10
    },
    {
      "question": "कंप्यूटर का पूरा नाम क्या है?",
      "options": ["Computer Operating Machine Particularly Used for Technical Education", "Common Operating Machine Particularly Used for Technical Education Research", "Common Oriented Machine Particularly Used for Technical Education Research", "Common Operating Memory Particularly Used for Technical Research"],
      "answer": 1,
      "explanation": "COMPUTER stands for Common Operating Machine Particularly Used for Technical Education Research.",
      "difficulty": "medium",
      "hint": "यह एक ऐसी मशीन है जो तकनीकी शिक्षा और शोध के लिए बनी है।",
      "points": 10
    },
    {
      "question": "ROM किस प्रकार की मेमोरी है?",
      "options": ["Temporary", "Cache", "Volatile", "Non-volatile"],
      "answer": 3,
      "explanation": "ROM नॉन-वोलेटाइल मेमोरी है - बिजली जाने पर भी डेटा नहीं मिटता।",
      "difficulty": "easy",
      "hint": "यह स्थायी मेमोरी है।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सी प्रोसेसर कंपनी है?",
      "options": ["Apple", "Microsoft", "Google", "Intel"],
      "answer": 3,
      "explanation": "Intel और AMD प्रमुख प्रोसेसर निर्माता कंपनियाँ हैं।",
      "difficulty": "easy",
      "hint": "इनके प्रोसेसर कंप्यूटर में लगे होते हैं।",
      "points": 10
    },
    {
      "question": "पांचवीं पीढ़ी के कंप्यूटर किस पर आधारित हैं?",
      "options": ["Quantum Computing", "Microprocessors", "Nanotechnology", "Artificial Intelligence"],
      "answer": 3,
      "explanation": "पांचवीं पीढ़ी AI (Artificial Intelligence) और parallel processing पर आधारित है।",
      "difficulty": "medium",
      "hint": "ये कंप्यूटर खुद सोच सकते हैं और सीख सकते हैं।",
      "points": 15
    },
    {
      "question": "कंप्यूटर में BIOS का क्या कार्य है?",
      "options": ["Input data", "Display graphics", "Store files", "Boot the computer"],
      "answer": 3,
      "explanation": "BIOS (Basic Input Output System) कंप्यूटर को बूट करने वाला पहला सॉफ्टवेयर है।",
      "difficulty": "hard",
      "hint": "जब आप कंप्यूटर ऑन करते हैं तो सबसे पहले यह चलता है।",
      "points": 20
    },
    {
      "question": "कंप्यूटर में रीबूटिंग का क्या अर्थ है?",
      "options": ["Starting", "Shutting down", "Sleeping", "Restarting"],
      "answer": 3,
      "explanation": "रीबूटिंग कंप्यूटर को पुनः चालू करना है - restart करना।",
      "difficulty": "easy",
      "hint": "जब कंप्यूटर हैंग हो जाता है तो यह करते हैं।",
      "points": 10
    },
    {
      "question": "कंप्यूटर के आविष्कारक किसे माना जाता है?",
      "options": ["Steve Jobs", "Bill Gates", "Alan Turing", "Charles Babbage"],
      "answer": 3,
      "explanation": "Charles Babbage को 'Father of Computer' कहा जाता है। उन्होंने 1837 में Analytical Engine का डिज़ाइन बनाया।",
      "difficulty": "easy",
      "hint": "इन्हें 'कंप्यूटर का पिता' कहा जाता है।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सा नेटवर्क डिवाइस है?",
      "options": ["HDD", "RAM", "CPU", "Router"],
      "answer": 3,
      "explanation": "Router कंप्यूटर नेटवर्क को आपस में जोड़ता है।",
      "difficulty": "medium",
      "hint": "यह इंटरनेट चलाने के काम आता है।",
      "points": 15
    },
    {
      "question": "SSD का पूरा नाम क्या है?",
      "options": ["System Storage Drive", "Secure State Drive", "Super Speed Drive", "Solid State Drive"],
      "answer": 3,
      "explanation": "SSD (Solid State Drive) एक तेज़ स्टोरेज डिवाइस है जिसमें कोई moving part नहीं होता।",
      "difficulty": "medium",
      "hint": "यह Hard Disk से तेज़ होता है।",
      "points": 15
    },
    {
      "question": "निम्न में से कौन सी स्टोरेज यूनिट सबसे बड़ी है?",
      "options": ["MB", "KB", "GB", "TB"],
      "answer": 3,
      "explanation": "TB (Terabyte) सबसे बड़ा होता है। 1 TB = 1024 GB.",
      "difficulty": "easy",
      "hint": "Terabyte सबसे बड़ी है।",
      "points": 10
    },
    {
      "question": "Cache मेमोरी का मुख्य कार्य क्या है?",
      "options": ["Display output", "Input data", "Store permanently", "Speed up CPU access"],
      "answer": 3,
      "explanation": "Cache मेमोरी CPU की स्पीड बढ़ाने के लिए बार-बार उपयोग होने वाले डेटा को स्टोर करती है।",
      "difficulty": "hard",
      "hint": "यह RAM से भी तेज मेमोरी है।",
      "points": 20
    },
    {
      "question": "निम्न में से कौन सी आउटपुट डिवाइस है?",
      "options": ["Mouse", "Scanner", "Keyboard", "Speaker"],
      "answer": 3,
      "explanation": "Speaker ऑडियो आउटपुट डिवाइस है जो ध्वनि निकालता है।",
      "difficulty": "easy",
      "hint": "इससे आवाज़ सुनाई देती है।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सा सॉफ्टवेयर का उदाहरण है?",
      "options": ["RAM", "Hard Disk", "CPU", "MS Paint"],
      "answer": 3,
      "explanation": "MS Paint एक सॉफ्टवेयर एप्लीकेशन है। बाकी हार्डवेयर हैं।",
      "difficulty": "easy",
      "hint": "जिसे आप छू नहीं सकते - वह सॉफ्टवेयर।",
      "points": 10
    },
    {
      "question": "कंप्यूटर का मस्तिष्क किसे कहते हैं?",
      "options": ["Motherboard", "Hard Disk", "RAM", "CPU"],
      "answer": 3,
      "explanation": "CPU (Central Processing Unit) कंप्यूटर का मस्तिष्क होता है।",
      "difficulty": "easy",
      "hint": "यह सब कुछ कंट्रोल करता है।",
      "points": 10
    },
    {
      "question": "दूसरी पीढ़ी के कंप्यूटर में किसका उपयोग हुआ?",
      "options": ["Microprocessors", "IC Chips", "Vacuum Tubes", "Transistors"],
      "answer": 3,
      "explanation": "दूसरी पीढ़ी (1956-1963) में ट्रांजिस्टर का उपयोग हुआ, जो छोटे और कुशल थे।",
      "difficulty": "easy",
      "hint": "ये वैक्यूम ट्यूब से छोटे और भरोसेमंद थे।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सा टच स्क्रीन डिवाइस है?",
      "options": ["Mouse", "Speaker", "Printer", "Smartphone"],
      "answer": 3,
      "explanation": "Smartphone टच स्क्रीन डिवाइस है जिसे छूकर ऑपरेट किया जाता है।",
      "difficulty": "easy",
      "hint": "इसे आप उंगली से चला सकते हैं।",
      "points": 10
    },
    {
      "question": "ALU का क्या कार्य है?",
      "options": ["Power supply", "Data storage", "Memory management", "Arithmetic & Logical operations"],
      "answer": 3,
      "explanation": "ALU (Arithmetic Logic Unit) सभी गणितीय और तार्किक संचालन करता है।",
      "difficulty": "medium",
      "hint": "इसमें +, -, ×, ÷ और तुलनाएं होती हैं।",
      "points": 15
    },
    {
      "question": "USB का पूरा नाम क्या है?",
      "options": ["United Serial Bus", "Universal Storage Bus", "Universal System Bus", "Universal Serial Bus"],
      "answer": 3,
      "explanation": "USB एक मानक कनेक्शन है जिससे डिवाइस कंप्यूटर से जुड़ते हैं।",
      "difficulty": "easy",
      "hint": "इसमें Pen Drive लगती है।",
      "points": 10
    },
    {
      "question": "कंप्यूटर की सबसे बेसिक जानकारी के लिए क्या पढ़ना चाहिए?",
      "options": ["Advanced Programming", "Hardware only", "Networking only", "Computer Fundamentals"],
      "answer": 3,
      "explanation": "Computer Fundamentals सबसे बेसिक टॉपिक है जो हार्डवेयर, सॉफ्टवेयर, संचालन आदि सिखाता है।",
      "difficulty": "easy",
      "hint": "यह वह विषय है जिसमें सब कुछ बेसिक से समझाया जाता है।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सा ऑपरेटिंग सिस्टम है?",
      "options": ["Google Chrome", "Photoshop", "MS Word", "Windows 11"],
      "answer": 3,
      "explanation": "Windows 11 एक ऑपरेटिंग सिस्टम है जो कंप्यूटर के सभी कार्यों को मैनेज करता है।",
      "difficulty": "easy",
      "hint": "यह पूरे कंप्यूटर को चलाता है।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सी जनरेशन AI पर आधारित है?",
      "options": ["Third Generation", "First Generation", "Fourth Generation", "Fifth Generation"],
      "answer": 3,
      "explanation": "पांचवीं पीढ़ी (वर्तमान और भविष्य) आर्टिफिशियल इंटेलिजेंस पर आधारित है।",
      "difficulty": "medium",
      "hint": "इसमें कंप्यूटर खुद सोच सकते हैं।",
      "points": 15
    },
    {
      "question": "HDD का पूरा नाम क्या है?",
      "options": ["High Density Drive", "Hard Data Drive", "Heavy Duty Drive", "Hard Disk Drive"],
      "answer": 3,
      "explanation": "HDD (Hard Disk Drive) पारंपरिक स्टोरेज डिवाइस है जो magnetic disks का उपयोग करता है।",
      "difficulty": "medium",
      "hint": "इसमें घूमने वाली प्लेटें होती हैं।",
      "points": 10
    },
    {
      "question": "1 बाइट में कितने बिट होते हैं?",
      "options": ["2", "16", "4", "8"],
      "answer": 3,
      "explanation": "1 Byte में 8 Bits होते हैं। एक Byte एक अक्षर को स्टोर कर सकता है।",
      "difficulty": "easy",
      "hint": "जैसे 'A' को स्टोर करने के लिए 8 बिट चाहिए।",
      "points": 10
    },
    {
      "question": "पहली इलेक्ट्रॉनिक कंप्यूटर कौन सा था?",
      "options": ["EDSAC", "ABC", "UNIVAC", "ENIAC"],
      "answer": 3,
      "explanation": "ENIAC (Electronic Numerical Integrator and Computer) 1946 में बना पहला इलेक्ट्रॉनिक कंप्यूटर था।",
      "difficulty": "medium",
      "hint": "यह 1946 में बना था और इसका नाम E से शुरू होता है।",
      "points": 15
    },
    {
      "question": "कंप्यूटर में SMPS का क्या कार्य है?",
      "options": ["Display", "Processing", "Data Storage", "Power Supply"],
      "answer": 3,
      "explanation": "SMPS (Switched Mode Power Supply) सभी components को पावर देता है।",
      "difficulty": "hard",
      "hint": "यह AC को DC में बदलता है।",
      "points": 20
    },
    {
      "question": "निम्न में से कौन नॉन-वोलेटाइल मेमोरी है?",
      "options": ["Register", "Cache", "RAM", "ROM"],
      "answer": 3,
      "explanation": "ROM नॉन-वोलेटाइल है - बिजली जाने पर भी डेटा बना रहता है।",
      "difficulty": "easy",
      "hint": "यह स्थायी मेमोरी है।",
      "points": 10
    },
    {
      "question": "1 गीगाबाइट (GB) कितने मेगाबाइट (MB) के बराबर होता है?",
      "options": ["512", "2048", "1000", "1024"],
      "answer": 3,
      "explanation": "1 GB = 1024 MB। यह स्टोरेज की मानक इकाई है।",
      "difficulty": "easy",
      "hint": "1 GB में 1024 MB होते हैं।",
      "points": 10
    },
    {
      "question": "कंप्यूटर हार्डवेयर का उदाहरण कौन सा है?",
      "options": ["Google Chrome", "MS Word", "Windows 10", "Motherboard"],
      "answer": 3,
      "explanation": "Motherboard एक भौतिक हार्डवेयर है। बाकी सॉफ्टवेयर हैं।",
      "difficulty": "easy",
      "hint": "जिसे आप छू सकते हैं - वह हार्डवेयर।",
      "points": 10
    },
    {
      "question": "1 KB (Kilobyte) कितने बाइट्स के बराबर होता है?",
      "options": ["1000", "2048", "512", "1024"],
      "answer": 3,
      "explanation": "1 KB = 1024 Bytes। कंप्यूटर बाइनरी सिस्टम पर काम करता है।",
      "difficulty": "easy",
      "hint": "यह 1024 होता है, 1000 नहीं।",
      "points": 10
    },
    {
      "question": "कंप्यूटर केवल किस भाषा को समझता है?",
      "options": ["Assembly", "Hindi", "English", "Binary"],
      "answer": 3,
      "explanation": "कंप्यूटर केवल बाइनरी भाषा (0 और 1) को समझता है।",
      "difficulty": "easy",
      "hint": "यह दो अंकों की भाषा है।",
      "points": 10
    },
    {
      "question": "IC चिप्स किस पीढ़ी में आए?",
      "options": ["First", "Fourth", "Second", "Third"],
      "answer": 3,
      "explanation": "Integrated Circuits (ICs) तीसरी पीढ़ी (1964-1971) में आए।",
      "difficulty": "medium",
      "hint": "इससे पहले ट्रांजिस्टर थे।",
      "points": 15
    },
    {
      "question": "निम्न में से कौन सा इनपुट डिवाइस नहीं है?",
      "options": ["Scanner", "Mouse", "Microphone", "Printer"],
      "answer": 3,
      "explanation": "Printer एक आउटपुट डिवाइस है, इनपुट नहीं। यह कंप्यूटर से कागज पर प्रिंट करता है।",
      "difficulty": "easy",
      "hint": "यह कंप्यूटर से बाहर काम करता है।",
      "points": 10
    },
    {
      "question": "कंप्यूटर में मल्टीटास्किंग का क्या अर्थ है?",
      "options": ["Shutting down", "Restarting", "Running one program", "Running multiple programs at once"],
      "answer": 3,
      "explanation": "मल्टीटास्किंग एक साथ कई प्रोग्राम चलाने की क्षमता है।",
      "difficulty": "easy",
      "hint": "जैसे गाना सुनते हुए Word में टाइप करना।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सा सर्वर का मुख्य कार्य है?",
      "options": ["Only storage", "Only printing", "Only gaming", "Provide services to other computers"],
      "answer": 3,
      "explanation": "सर्वर दूसरे कंप्यूटर्स (क्लाइंट्स) को सेवाएं जैसे फाइल, वेब, मेल, डेटाबेस प्रदान करता है।",
      "difficulty": "medium",
      "hint": "जैसे वेबसाइट चलाने वाला कंप्यूटर।",
      "points": 15
    },
    {
      "question": "निम्न में से कौन कंप्यूटर का रूप है?",
      "options": ["Mouse", "RAM", "CPU", "Desktop"],
      "answer": 3,
      "explanation": "Desktop, Laptop, Tablet, Smartphone कंप्यूटर के अलग-अलग रूप हैं।",
      "difficulty": "easy",
      "hint": "जैसे आपके घर का PC।",
      "points": 10
    },
    {
      "question": "कंप्यूटर में कैश मेमोरी कहाँ होती है?",
      "options": ["On Motherboard only", "In RAM", "On Hard Disk", "Inside CPU"],
      "answer": 3,
      "explanation": "Cache मेमोरी CPU के अंदर या बहुत करीब होती है।",
      "difficulty": "hard",
      "hint": "यह सबसे तेज मेमोरी है।",
      "points": 20
    },
    {
      "question": "RAM का पूरा नाम क्या है?",
      "options": ["Read Access Memory", "Random Available Memory", "Rapid Access Memory", "Random Access Memory"],
      "answer": 3,
      "explanation": "RAM (Random Access Memory) एक अस्थायी मेमोरी है।",
      "difficulty": "easy",
      "hint": "जितनी ज्यादा RAM उतना ज्यादा काम एक साथ।",
      "points": 10
    },
    {
      "question": "तीसरी पीढ़ी के कंप्यूटर की मुख्य तकनीक क्या थी?",
      "options": ["Microprocessors", "Vacuum Tubes", "Transistors", "Integrated Circuits (ICs)"],
      "answer": 3,
      "explanation": "तीसरी पीढ़ी (1964-1971) में IC (Integrated Circuit) चिप्स का उपयोग हुआ।",
      "difficulty": "easy",
      "hint": "एक चिप में हजारों ट्रांजिस्टर एक साथ।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सी वोलेटाइल मेमोरी है?",
      "options": ["SSD", "Hard Disk", "ROM", "RAM"],
      "answer": 3,
      "explanation": "RAM (Random Access Memory) वोलेटाइल है - बिजली जाते ही डेटा मिट जाता है।",
      "difficulty": "easy",
      "hint": "यह अस्थायी मेमोरी है।",
      "points": 10
    },
    {
      "question": "कंप्यूटर में फर्मवेयर क्या है?",
      "options": ["Application software", "Antivirus", "Temporary software", "Permanent software in ROM"],
      "answer": 3,
      "explanation": "फर्मवेयर ROM में स्टोर स्थायी सॉफ्टवेयर होता है जैसे BIOS।",
      "difficulty": "hard",
      "hint": "यह हार्डवेयर और सॉफ्टवेयर के बीच की कड़ी है।",
      "points": 20
    },
    {
      "question": "निम्न में से कौन सी इंटरनल मेमोरी है?",
      "options": ["Memory Card", "CD", "Pen Drive", "RAM"],
      "answer": 3,
      "explanation": "RAM इंटरनल मेमोरी है जो CPU के अंदर या पास होती है। बाकी सब एक्सटर्नल हैं।",
      "difficulty": "easy",
      "hint": "यह मदरबोर्ड पर लगी होती है।",
      "points": 10
    },
    {
      "question": "हार्डवेयर का क्या अर्थ है?",
      "options": ["Software programs", "Operating system", "Data files", "Physical parts of computer"],
      "answer": 3,
      "explanation": "हार्डवेयर कंप्यूटर के वे भौतिक भाग हैं जिन्हें आप छू सकते हैं - जैसे मॉनिटर, कीबोर्ड, CPU।",
      "difficulty": "easy",
      "hint": "जिसे आप छू सकते हैं, वह हार्डवेयर है।",
      "points": 10
    },
    {
      "question": "कंप्यूटर में VGA का क्या अर्थ है?",
      "options": ["Visual Graphics Adapter", "Video Generic Array", "Virtual General Array", "Video Graphics Array"],
      "answer": 3,
      "explanation": "VGA (Video Graphics Array) एक डिस्प्ले स्टैंडर्ड है जो 640×480 resolution देता है।",
      "difficulty": "hard",
      "hint": "यह मॉनिटर से जुड़ने वाला नीला कनेक्टर होता है।",
      "points": 20
    },
    {
      "question": "कंप्यूटर में क्लॉक स्पीड किसमें मापी जाती है?",
      "options": ["Mbps", "KB/TB", "MB/GB", "MHz/GHz"],
      "answer": 3,
      "explanation": "क्लॉक स्पीड मेगाहर्ट्ज़ (MHz) या गीगाहर्ट्ज़ (GHz) में मापी जाती है।",
      "difficulty": "medium",
      "hint": "जितनी ज्यादा उतना तेज़ कंप्यूटर।",
      "points": 15
    },
    {
      "question": "चौथी पीढ़ी के कंप्यूटर की पहचान क्या है?",
      "options": ["ICs", "AI Chips", "Transistors", "Microprocessors"],
      "answer": 3,
      "explanation": "चौथी पीढ़ी (1971-1980) में माइक्रोप्रोसेसर का विकास हुआ, जिससे PC का जन्म हुआ।",
      "difficulty": "easy",
      "hint": "एक ही चिप में पूरा CPU।",
      "points": 10
    },
    {
      "question": "निम्न में से कौन सा आउटपुट डिवाइस है?",
      "options": ["Microphone", "Scanner", "Mouse", "Monitor"],
      "answer": 3,
      "explanation": "Monitor आउटपुट डिवाइस है क्योंकि यह कंप्यूटर से जानकारी दिखाता है।",
      "difficulty": "easy",
      "hint": "यह हमें परिणाम दिखाता है।",
      "points": 10
    },
    {
      "question": "CUI का क्या अर्थ है?",
      "options": ["Control User Interface", "Central User Interface", "Computer User Interface", "Character User Interface"],
      "answer": 3,
      "explanation": "CUI वह इंटरफ़ेस है जहाँ आपको कमांड टाइप करने होते हैं (जैसे DOS, Linux Terminal)।",
      "difficulty": "medium",
      "hint": "इसमें सिर्फ टेक्स्ट और कमांड लाइन होती है।",
      "points": 15
    },
    {
      "question": "कंप्यूटर में डेटा की सबसे छोटी इकाई क्या है?",
      "options": ["Nibble", "KB", "Byte", "Bit"],
      "answer": 3,
      "explanation": "Bit (0 या 1) डेटा की सबसे छोटी इकाई है।",
      "difficulty": "easy",
      "hint": "यह सिर्फ 2 मान ले सकता है - ऑन या ऑफ।",
      "points": 10
    },
    {
      "question": "1 मेगाबाइट (MB) कितने किलोबाइट (KB) के बराबर होता है?",
      "options": ["512", "2048", "1000", "1024"],
      "answer": 3,
      "explanation": "1 MB = 1024 KB। यह कंप्यूटर की बाइनरी सिस्टम है।",
      "difficulty": "easy",
      "hint": "यह 1024 होता है क्योंकि 2^10 = 1024।",
      "points": 10
    },
    {
      "question": "कंप्यूटर साइंस में GUI का क्या अर्थ है?",
      "options": ["General Unit Interface", "Graphical Unit Interface", "General User Interface", "Graphical User Interface"],
      "answer": 3,
      "explanation": "GUI वह इंटरफ़ेस है जहाँ आप आइकन, बटन, मेनू देखते और क्लिक करते हैं।",
      "difficulty": "medium",
      "hint": "Windows, macOS, Android का इंटरफ़ेस।",
      "points": 15
    },
    {
      "question": "RAM किस प्रकार की मेमोरी है?",
      "options": ["Read-only", "Permanent", "Non-volatile", "Volatile"],
      "answer": 3,
      "explanation": "RAM वोलेटाइल मेमोरी है - बिजली जाते ही डेटा मिट जाता है।",
      "difficulty": "easy",
      "hint": "यह अस्थायी मेमोरी है।",
      "points": 10
    },
    {
      "question": "सॉफ्टवेयर क्या है?",
      "options": ["Output devices", "Input devices", "Physical parts", "Set of instructions/programs"],
      "answer": 3,
      "explanation": "सॉफ्टवेयर निर्देशों और प्रोग्रामों का समूह है जो हार्डवेयर को बताता है कि क्या करना है।",
      "difficulty": "easy",
      "hint": "जिसे आप छू नहीं सकते, पर देख सकते हैं।",
      "points": 10
    },
    {
      "question": "माइक्रोप्रोसेसर किस पीढ़ी में आया?",
      "options": ["Second", "First", "Third", "Fourth"],
      "answer": 3,
      "explanation": "माइक्रोप्रोसेसर चौथी पीढ़ी (1971-1980) में आया।",
      "difficulty": "medium",
      "hint": "Intel 4004 पहला माइक्रोप्रोसेसर था।",
      "points": 15
    },
    {
      "question": "ROM का पूरा नाम क्या है?",
      "options": ["Random Only Memory", "Rapid Only Memory", "Read Online Memory", "Read Only Memory"],
      "answer": 3,
      "explanation": "ROM (Read Only Memory) जिसे सिर्फ पढ़ा जा सकता है, लिखा नहीं।",
      "difficulty": "easy",
      "hint": "इसमें factory से डेटा लिखा होता है।",
      "points": 10
    },
    {
      "question": "कंप्यूटर के प्रदर्शन के लिए कौन सा ज़्यादा महत्वपूर्ण है?",
      "options": ["Only Hard Disk", "Only RAM", "Only CPU", "Balance of all components"],
      "answer": 3,
      "explanation": "कंप्यूटर का प्रदर्शन सभी कॉम्पोनेंट्स - CPU, RAM, Storage - के संतुलन पर निर्भर करता है।",
      "difficulty": "medium",
      "hint": "तीनों का तालमेल जरूरी है।",
      "points": 15
    },
    {
      "question": "निम्न में से कौन सा एप्लीकेशन सॉफ्टवेयर है?",
      "options": ["macOS", "Linux", "Windows 10", "MS Word"],
      "answer": 3,
      "explanation": "MS Word एक एप्लीकेशन सॉफ्टवेयर है। बाकी ऑपरेटिंग सिस्टम हैं।",
      "difficulty": "easy",
      "hint": "यह एक प्रोग्राम है जो OS के ऊपर चलता है।",
      "points": 10
    },
    {
      "question": "कंप्यूटर में 'डिफ्रैग्मेंटेशन' क्या करता है?",
      "options": ["Encrypts files", "Compresses files", "Deletes files", "Reorganizes files on hard disk"],
      "answer": 3,
      "explanation": "डिफ्रैग्मेंटेशन हार्ड डिस्क पर बिखरे फ़ाइलों को व्यवस्थित करता है जिससे कंप्यूटर तेज़ चलता है।",
      "difficulty": "hard",
      "hint": "यह फ़ाइलों को एक जगह इकट्ठा करता है।",
      "points": 20
    },
    {
      "question": "कंप्यूटर में बूटिंग का क्या अर्थ है?",
      "options": ["Sleep mode", "Restarting", "Shutting down", "Starting the computer"],
      "answer": 3,
      "explanation": "बूटिंग कंप्यूटर को चालू करने की प्रक्रिया है।",
      "difficulty": "easy",
      "hint": "जब आप पावर बटन दबाते हैं तो booting होती है।",
      "points": 10
    },
    {
      "question": "कंप्यूटर में एक्सटेंशन .exe का क्या अर्थ है?",
      "options": ["Exchange file", "Extra file", "Excel file", "Executable file"],
      "answer": 3,
      "explanation": ".exe (Executable) फ़ाइलें वे हैं जिन्हें सीधे चलाया जा सकता है।",
      "difficulty": "medium",
      "hint": "जैसे setup.exe - डबल क्लिक करने पर चलती है।",
      "points": 15
    },
    {
      "question": "निम्न में से कौन सा सिस्टम सॉफ्टवेयर है?",
      "options": ["Photoshop", "Google Chrome", "MS Excel", "Windows OS"],
      "answer": 3,
      "explanation": "Windows OS एक सिस्टम सॉफ्टवेयर है जो कंप्यूटर को चलाता है।",
      "difficulty": "easy",
      "hint": "यह ऑपरेटिंग सिस्टम है।",
      "points": 10
    },
    {
      "question": "कंप्यूटर में पोर्ट क्या होता है?",
      "options": ["Memory location", "File extension", "Type of software", "Connection point for devices"],
      "answer": 3,
      "explanation": "पोर्ट वह जगह है जहाँ आप USB, कीबोर्ड, माउस जैसे डिवाइस कनेक्ट करते हैं।",
      "difficulty": "medium",
      "hint": "जैसे USB पोर्ट, HDMI पोर्ट।",
      "points": 15
    },
    {
      "question": "DRAM और SRAM में क्या अंतर है?",
      "options": ["Both are same", "DRAM is faster", "SRAM is slower", "DRAM is slower and cheaper"],
      "answer": 3,
      "explanation": "DRAM धीमा और सस्ता है। SRAM तेज़ और महंगा है (cache मेमोरी में उपयोग)।",
      "difficulty": "hard",
      "hint": "DRAM = मेन RAM, SRAM = Cache।",
      "points": 20
    },
    {
      "question": "निम्न में से कौन सा पोर्ट सबसे तेज़ होता है?",
      "options": ["Ethernet", "VGA", "USB 2.0", "Thunderbolt/USB-C"],
      "answer": 3,
      "explanation": "Thunderbolt और USB-C सबसे तेज़ डेटा ट्रांसफर सपोर्ट करते हैं (40 Gbps तक)।",
      "difficulty": "hard",
      "hint": "नए लैपटॉप में यह छोटा अंडाकार पोर्ट होता है।",
      "points": 20
    }
  ],
  "2. Basic Software Tools": [
    {
      "question": "Windows में 'Windows Security' (पहले Windows Defender) क्या है?",
      "options": ["Password manager", "Email client", "Browser", "Built-in antivirus and security"],
      "answer": 3,
      "explanation": "Windows Security (Windows Defender) Microsoft का बिल्ट-इन एंटीवायरस और सुरक्षा सूट है।",
      "difficulty": "medium",
      "hint": "Windows 10/11 में यह पहले से आता है।",
      "points": 15
    },
    {
      "question": "Windows में 'System Restore' का क्या कार्य है?",
      "options": ["RAM बढ़ाना", "हार्ड ड्राइव फॉर्मेट करना", "OS रीइंस्टॉल करना", "कंप्यूटर को पिछली अच्छी स्थिति में ले जाना"],
      "answer": 3,
      "explanation": "System Restore कंप्यूटर को एक पिछले 'Restore Point' पर ले जाता है, बिना आपकी पर्सनल फाइल्स को हटाए।",
      "difficulty": "hard",
      "hint": "अगर कोई प्रॉब्लम आ जाए तो पुरानी तारीख पर वापस जाएँ।",
      "points": 20
    },
    {
      "question": "Windows में 'Task Manager' कैसे खोलें?",
      "options": ["Windows + R", "Alt + F4", "Ctrl + Alt + Del", "Ctrl + Shift + Esc"],
      "answer": 3,
      "explanation": "Ctrl + Shift + Esc सीधे Task Manager खोलता है। Ctrl + Alt + Del से भी खोल सकते हैं लेकिन एक क्लिक और लगता है।",
      "difficulty": "medium",
      "hint": "जब कंप्यूटर हैंग हो जाए तो यह use करें।",
      "points": 15
    },
    {
      "question": "Windows में 'Disk Cleanup' टूल क्या करता है?",
      "options": ["RAM साफ करता है", "वायरस हटाता है", "हार्ड डिस्क फॉर्मेट करता है", "टेंपररी फाइल्स और कचरा हटाता है"],
      "answer": 3,
      "explanation": "Disk Cleanup अनावश्यक फाइल्स (temporary files, recycle bin, cache) को हटाकर डिस्क स्पेस खाली करता है।",
      "difficulty": "hard",
      "hint": "यह आपका स्टोरेज साफ करता है।",
      "points": 20
    },
    {
      "question": "Windows में 'Ctrl + Z' का क्या कार्य है?",
      "options": ["Redo", "Copy", "Paste", "Undo (पिछला action वापस लेना)"],
      "answer": 3,
      "explanation": "Ctrl + Z आपके आखिरी किए गए action (टाइपिंग, डिलीट, मूव) को उलट देता है।",
      "difficulty": "easy",
      "hint": "गलती हो जाए तो यह press करें।",
      "points": 10
    },
    {
      "question": "Windows में 'Alt + Tab' का क्या उपयोग है?",
      "options": ["फ़ोल्डर खोलना", "ब्राउज़र खोलना", "कंप्यूटर बंद करना", "खुले एप्लिकेशन के बीच स्विच करना"],
      "answer": 3,
      "explanation": "Alt+Tab सभी खुले हुए प्रोग्रामों के बीच तुरंत स्विच करने के लिए होता है।",
      "difficulty": "easy",
      "hint": "एक स्क्रीन से दूसरी पर जाने के लिए।",
      "points": 10
    },
    {
      "question": "Windows में 'Start' बटन का क्या कार्य है?",
      "options": ["प्रिंटर चलाना", "इंटरनेट खोलना", "कंप्यूटर बंद करना", "सभी एप्लिकेशन और सेटिंग्स तक पहुँच"],
      "answer": 3,
      "explanation": "Start बटन से आप सभी इंस्टॉल्ड एप्लिकेशन, सेटिंग्स, पावर ऑप्शन और फाइलों तक पहुँच सकते हैं।",
      "difficulty": "easy",
      "hint": "स्क्रीन के नीचे बायें तरफ होता है।",
      "points": 10
    },
    {
      "question": "Windows में 'Focus Assist' क्या करता है?",
      "options": ["बैटरी बचाता है", "वॉल्यूम बढ़ाता है", "स्क्रीन ब्राइट करता है", "Notifications को block करता है जब आप focus mode में हों"],
      "answer": 3,
      "explanation": "Focus Assist (पहले Quiet Hours) distractions को रोकता है - notifications नहीं आते जब आप प्रेजेंटेशन बना रहे हों या गेम खेल रहे हों।",
      "difficulty": "hard",
      "hint": "परेशान करने वाले pop-ups बंद हो जाते हैं।",
      "points": 20
    },
    {
      "question": "Windows में 'System Information' (msinfo32) क्या दिखाता है?",
      "options": ["सिर्फ OS version", "सिर्फ CPU", "सिर्फ RAM", "Hardware resources, components, software environment"],
      "answer": 3,
      "explanation": "System Information आपके कंप्यूटर का पूरा स्पेसिफिकेशन देता है - OS version, BIOS, Processor, RAM, Motherboard, Drivers, सब कुछ।",
      "difficulty": "hard",
      "hint": "अपने कंप्यूटर के बारे में सबकुछ यहाँ देख सकते हैं।",
      "points": 20
    },
    {
      "question": "Windows में 'Startup Programs' को कैसे manage करें?",
      "options": ["File Explorer", "Settings → Apps", "Control Panel → Programs", "Task Manager → Startup tab"],
      "answer": 3,
      "explanation": "Task Manager के Startup टैब से आप decide कर सकते हैं कि कौन से programs कंप्यूटर ऑन होते ही automatically चलें।",
      "difficulty": "medium",
      "hint": "कंप्यूटर धीमा चलता है तो यहाँ disable करें।",
      "points": 15
    },
    {
      "question": "Windows में 'Power Options' में क्या सेट कर सकते हैं?",
      "options": ["Language", "Font size", "Desktop wallpaper", "Sleep, Hibernate, Shutdown timing, display off timing"],
      "answer": 3,
      "explanation": "Power Options से आप control करते हैं कि कंप्यूटर कब सोए, डिस्प्ले कब बंद हो, कब हाइबरनेट हो, और battery performance।",
      "difficulty": "medium",
      "hint": "बैटरी बचाने वाली सेटिंग्स यहाँ होती हैं।",
      "points": 15
    },
    {
      "question": "Windows में 'Device Manager' का उपयोग किसके लिए होता है?",
      "options": ["गेम इंस्टॉल करना", "इंटरनेट सेट करना", "फाइलें डिलीट करना", "Hardware drivers को manage करना"],
      "answer": 3,
      "explanation": "Device Manager से आप सभी हार्डवेयर (ड्राइवर, डिस्प्ले, कीबोर्ड, USB) को देख, अपडेट, डिसेबल या अनइंस्टॉल कर सकते हैं।",
      "difficulty": "hard",
      "hint": "यहाँ से driver update होता है।",
      "points": 20
    },
    {
      "question": "Windows में 'Taskbar' कहाँ स्थित होता है?",
      "options": ["स्क्रीन के बायें", "स्क्रीन के दायें", "स्क्रीन के ऊपर", "आमतौर पर स्क्रीन के नीचे"],
      "answer": 3,
      "explanation": "Taskbar आमतौर पर स्क्रीन के नीचे होता है, जहाँ Start बटन, खुले हुए एप्लिकेशन और नोटिफिकेशन एरिया होता है।",
      "difficulty": "easy",
      "hint": "वहाँ 'Start' बटन होता है।",
      "points": 10
    },
    {
      "question": "Windows में 'Disk Defragmenter' का क्या उपयोग है?",
      "options": ["बैकअप लेना", "वायरस स्कैन करना", "फाइलें डिलीट करना", "हार्ड ड्राइव की स्पीड बढ़ाना"],
      "answer": 3,
      "explanation": "Disk Defragmenter हार्ड ड्राइव पर बिखरी फाइलों को व्यवस्थित करता है, जिससे ड्राइव तेज़ हो जाती है।",
      "difficulty": "hard",
      "hint": "यह SSD के लिए जरूरी नहीं है, HDD के लिए है।",
      "points": 20
    },
    {
      "question": "Windows 'God Mode' क्या है?",
      "options": ["hacker tool", "virus", "एक secret game", "एक hidden folder जिसमें सभी settings एक साथ हैं"],
      "answer": 3,
      "explanation": "God Mode एक स्पेशल फ़ोल्डर होता है जिसमें Windows की लगभग सभी सेटिंग्स (200 से अधिक) एक जगह लिस्ट होती हैं।",
      "difficulty": "hard",
      "hint": "डेस्कटॉप पर नया फ़ोल्डर बनाएं और नाम दें: GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}",
      "points": 20
    },
    {
      "question": "Windows में 'Sticky Notes' का क्या उपयोग है?",
      "options": ["ईमेल भेजना", "चित्र बनाना", "गणित करना", "डेस्कटॉप पर नोट्स चिपकाना"],
      "answer": 3,
      "explanation": "Sticky Notes आपको डेस्कटॉप पर छोटे-छोटे पीले नोट्स चिपकाने की सुविधा देता है - रिमाइंडर के लिए।",
      "difficulty": "easy",
      "hint": "यह actual sticky note की तरह काम करता है।",
      "points": 10
    },
    {
      "question": "Windows में 'Remote Desktop Connection' का क्या उपयोग है?",
      "options": ["इंटरनेट स्पीड टेस्ट करना", "फाइलें ट्रांसफर करना", "प्रिंटर शेयर करना", "दूसरे कंप्यूटर को remotely access करना"],
      "answer": 3,
      "explanation": "Remote Desktop से आप दूसरे कंप्यूटर (जो network पर हो) को अपने कंप्यूटर से कंट्रोल कर सकते हैं।",
      "difficulty": "hard",
      "hint": "जैसे टेक सपोर्ट आपका कंप्यूटर दूर से ठीक करता है।",
      "points": 20
    },
    {
      "question": "Windows में 'Recycle Bin' का क्या कार्य है?",
      "options": ["वायरस हटाना", "नई फाइलें बनाना", "कचरा डालना", "डिलीट की गई फाइलों को temporarily store करना"],
      "answer": 3,
      "explanation": "Recycle Bin डिलीट की गई फाइलों को अस्थायी रूप से स्टोर करता है, जहाँ से आप उन्हें रिस्टोर कर सकते हैं।",
      "difficulty": "easy",
      "hint": "यह कूड़ेदान के आइकॉन जैसा होता है।",
      "points": 10
    },
    {
      "question": "Windows में 'Windows + L' का क्या उपयोग है?",
      "options": ["Restart करना", "Shutdown करना", "Logout करना", "कंप्यूटर को Lock करना"],
      "answer": 3,
      "explanation": "Windows + L तुरंत कंप्यूटर को लॉक कर देता है, जिससे पासवर्ड डालने के बाद ही कोई एक्सेस कर सकता है।",
      "difficulty": "easy",
      "hint": "जब आप अपनी सीट छोड़ें तो यह करें।",
      "points": 10
    },
    {
      "question": "Windows में 'Backup and Restore' टूल का क्या उपयोग है?",
      "options": ["डिस्क साफ करना", "ड्राइवर अपडेट करना", "फाइलें डिलीट करना", "फाइलों की कॉपी security के लिए बनाना"],
      "answer": 3,
      "explanation": "Backup and Restore आपकी महत्वपूर्ण फाइलों की कॉपी बनाता है ताकि डेटा लॉस होने पर रिकवर किया जा सके।",
      "difficulty": "hard",
      "hint": "डेटा खोने से बचाता है।",
      "points": 20
    },
    {
      "question": "Windows में 'Control Panel' का क्या उपयोग है?",
      "options": ["गाने सुनना", "इंटरनेट चलाना", "फाइलें डिलीट करना", "System settings बदलना"],
      "answer": 3,
      "explanation": "Control Panel से आप डिस्प्ले, साउंड, नेटवर्क, यूजर अकाउंट्स, प्रिंटर आदि की सेटिंग्स बदल सकते हैं।",
      "difficulty": "medium",
      "hint": "यहाँ से सिस्टम कस्टमाइज़ होता है।",
      "points": 15
    },
    {
      "question": "Windows में 'Notification Area' (System Tray) कहाँ होता है?",
      "options": ["Start Menu में", "स्क्रीन के बीच में", "Taskbar के बायें छोर पर", "Taskbar के दाहिने छोर पर"],
      "answer": 3,
      "explanation": "Notification Area Taskbar के दाहिने तरफ होता है, जहाँ घड़ी, वॉल्यूम, नेटवर्क, बैटरी और अन्य आइकॉन होते हैं।",
      "difficulty": "easy",
      "hint": "यहाँ आपको time दिखता है।",
      "points": 10
    },
    {
      "question": "Windows में 'Virtual Desktop' क्या है?",
      "options": ["केवल office desktop", "गेमिंग desktop", "ऑनलाइन desktop", "अलग-अलग desktops बनाकर apps को group करना"],
      "answer": 3,
      "explanation": "Virtual Desktop (Task View) से आप कई डेस्कटॉप बना सकते हैं - एक पर काम, दूसरे पर मनोरंजन, और उनके बीच स्विच कर सकते हैं।",
      "difficulty": "hard",
      "hint": "Windows + Tab से Task View खोलें ➔ New Desktop।",
      "points": 20
    },
    {
      "question": "Windows में 'Desktop Background' कैसे बदलें?",
      "options": ["Task Manager", "File Explorer → View", "Control Panel → Fonts", "Settings → Personalization → Background"],
      "answer": 3,
      "explanation": "Settings → Personalization → Background से आप डेस्कटॉप वॉलपेपर बदल सकते हैं। Windows 7/8 में Personalize पर राइट क्लिक करें।",
      "difficulty": "medium",
      "hint": "डेस्कटॉप पर राइट क्लिक करें → Personalize।",
      "points": 15
    },
    {
      "question": "Windows PowerShell क्या है?",
      "options": ["Media player", "Browser", "Power management tool", "Advanced command-line shell और scripting language"],
      "answer": 3,
      "explanation": "PowerShell CMD से ज्यादा powerful है - इसमें admin tasks, system automation, scripting और .NET objects access किए जा सकते हैं।",
      "difficulty": "hard",
      "hint": "CMD का ज्यादा शक्तिशाली भाई।",
      "points": 20
    },
    {
      "question": "Windows में 'Snipping Tool' का क्या उपयोग है?",
      "options": ["वायरस स्कैन करना", "फाइलें कॉपी करना", "वीडियो एडिट करना", "स्क्रीनशॉट लेना"],
      "answer": 3,
      "explanation": "Snipping Tool स्क्रीन का चुनिंदा हिस्सा या पूरी स्क्रीन का स्क्रीनशॉट लेने के लिए होता है।",
      "difficulty": "medium",
      "hint": "यह एक कैंची के आइकॉन जैसा दिखता है।",
      "points": 15
    },
    {
      "question": "Google Workspace (पहले G Suite) में कौन सा टूल शामिल है?",
      "options": ["Zoom", "Photoshop", "MS Word, Excel", "Google Docs, Sheets, Slides, Gmail"],
      "answer": 3,
      "explanation": "Google Workspace में Google Docs (Word), Google Sheets (Excel), Google Slides (PowerPoint), Gmail, Google Calendar, Google Drive शामिल हैं।",
      "difficulty": "medium",
      "hint": "यह cloud-based office suite है।",
      "points": 15
    },
    {
      "question": "Windows में 'Ctrl + Y' का क्या कार्य है?",
      "options": ["Paste", "Copy", "Undo", "Redo (Undo को वापस करना)"],
      "answer": 3,
      "explanation": "Ctrl + Y आपके 'Undo' (Ctrl+Z) को रिवर्स करता है। कई प्रोग्राम्स में यह Redo है।",
      "difficulty": "medium",
      "hint": "Ctrl+Z के उलट।",
      "points": 15
    },
    {
      "question": "कमांड प्रॉम्प्ट (CMD) क्या है?",
      "options": ["Game", "Text editor", "Browser", "Command-line interface where text commands type करते हैं"],
      "answer": 3,
      "explanation": "CMD (Command Prompt) एक टेक्स्ट-बेस्ड इंटरफेस है जहाँ आप कमांड टाइप करके फाइलें, नेटवर्क, सिस्टम को कंट्रोल कर सकते हैं।",
      "difficulty": "medium",
      "hint": "यह black & white window होती है।",
      "points": 15
    },
    {
      "question": "Windows में 'Reset this PC' क्या करता है?",
      "options": ["Disk clean करता है", "Drivers अपडेट करता है", "Antivirus चलाता है", "Windows को fresh install करता है (keep files या remove all)"],
      "answer": 3,
      "explanation": "Reset this PC Windows को फिर से इंस्टॉल करता है। दो options: Keep my files (पर्सनल फाइलें रहती हैं) या Remove everything (पूरी तरह साफ)।",
      "difficulty": "hard",
      "hint": "जब कंप्यूटर बहुत slow हो जाए या virus आ जाए।",
      "points": 20
    },
    {
      "question": "Windows 'Reliability Monitor' क्या दिखाता है?",
      "options": ["Network speed", "Installed apps", "Hardware specs", "System crashes, errors, warnings की timeline"],
      "answer": 3,
      "explanation": "Reliability Monitor एक ग्राफ दिखाता है (1-10 scale) कि कब क्रैश हुआ, कब एप्लिकेशन failed, कब updates हुए। Problem diagnosis के लिए।",
      "difficulty": "hard",
      "hint": "Control Panel → Security and Maintenance → Reliability Monitor।",
      "points": 20
    },
    {
      "question": "Windows में 'Task View' कैसे खोलें?",
      "options": ["Windows + D", "Ctrl + Tab", "Alt + Tab", "Windows + Tab"],
      "answer": 3,
      "explanation": "Windows + Tab Task View खोलता है जहाँ सभी खुले एप्स और virtual desktops दिखते हैं।",
      "difficulty": "medium",
      "hint": "Alt+Tab के बीच अंतर है - यह देखता है।",
      "points": 15
    },
    {
      "question": "Windows में 'WordPad' और 'Notepad' में क्या अंतर है?",
      "options": ["WordPad सिर्फ números समझता है", "Notepad में pictures डाल सकते हैं", "दोनों एक जैसे हैं", "WordPad में formatting की जा सकती है"],
      "answer": 3,
      "explanation": "WordPad में बेसिक फॉर्मेटिंग (bold, italic, font size) होती है, जबकि Notepad सिर्फ प्लेन टेक्स्ट।",
      "difficulty": "medium",
      "hint": "WordPad 'Write' जैसा है, Notepad 'Typewriter' जैसा।",
      "points": 15
    },
    {
      "question": "Windows में 'Calculator' यूटिलिटी कहाँ मिलती है?",
      "options": ["File Explorer", "Start Menu → Settings", "Start Menu → Games", "Start Menu → Windows Accessories → Calculator"],
      "answer": 3,
      "explanation": "Calculator Start Menu के Windows Accessories या Windows Tools फ़ोल्डर में मिलती है। Windows 10/11 में सर्च करें।",
      "difficulty": "easy",
      "hint": "Start मेनू में 'calc' सर्च करें।",
      "points": 10
    },
    {
      "question": "Windows में 'Windows Sandbox' क्या है?",
      "options": ["Game mode", "Browser", "Antivirus", "Isolated temporary environment for testing unsafe apps"],
      "answer": 3,
      "explanation": "Windows Sandbox एक lightweight virtual machine है जहाँ आप unsafe एप्लिकेशन चला सकते हैं। Sandbox बंद होते ही सब कुछ delete हो जाता है।",
      "difficulty": "hard",
      "hint": "Virus डर लगता है तो पहले यहाँ test करें।",
      "points": 20
    },
    {
      "question": "Windows में 'Environment Variables' क्या होती हैं?",
      "options": ["Browser cookies", "Excel variables", "Variables in programming", "Paths और system settings को store करती हैं"],
      "answer": 3,
      "explanation": "Environment Variables सिस्टम पाथ, temp folders, OS रूट जैसी जानकारी store करती हैं। जैसे PATH variable कमांड प्रॉम्प्ट से कमांड चलाने में मदद करता है।",
      "difficulty": "hard",
      "hint": "Advanced system settings में मिलता है।",
      "points": 20
    },
    {
      "question": "Windows में 'Registry Editor' (regedit) क्या है?",
      "options": ["Email client", "Browser", "Text editor", "Windows settings का hierarchical database"],
      "answer": 3,
      "explanation": "Registry एक सेंट्रल डेटाबेस है जिसमें Windows और apps की सभी लो-लेवल सेटिंग्स store होती हैं। इसे बदलना खतरनाक हो सकता है।",
      "difficulty": "hard",
      "hint": "यह Windows की 'नसें' हैं। गलत बदलाव से कंप्यूटर काम करना बंद कर सकता है।",
      "points": 20
    },
    {
      "question": "Windows में 'Notepad' किस प्रकार का टूल है?",
      "options": ["प्रेजेंटेशन टूल", "स्प्रेडशीट", "वर्ड प्रोसेसर", "साधारण टेक्स्ट एडिटर"],
      "answer": 3,
      "explanation": "Notepad एक साधारण टेक्स्ट एडिटर है जो बिना फॉर्मेटिंग के टेक्स्ट फाइलें (.txt) बनाता है।",
      "difficulty": "easy",
      "hint": "यह बहुत basic है, इसमें font bold नहीं कर सकते।",
      "points": 10
    },
    {
      "question": "Windows में 'Windows + D' का क्या उपयोग है?",
      "options": ["Lock करना", "Settings खोलना", "Browser खोलना", "All windows minimize करके desktop दिखाना"],
      "answer": 3,
      "explanation": "Windows + D सभी खुली हुई विंडोज़ को मिनिमाइज़ कर देता है और डेस्कटॉप दिखाता है। फिर से दबाने पर विंडोज़ वापस आ जाती हैं।",
      "difficulty": "medium",
      "hint": "डेस्कटॉप पर तुरंत जाने के लिए।",
      "points": 15
    },
    {
      "question": "Windows में 'Windows Explorer / File Explorer' का उपयोग किसके लिए होता है?",
      "options": ["गेम खेलना", "ईमेल भेजना", "इंटरनेट ब्राउज़ करना", "फाइलों और फ़ोल्डरों को मैनेज करना"],
      "answer": 3,
      "explanation": "File Explorer फाइलों, फ़ोल्डरों, ड्राइव्स को देखने, कॉपी, मूव, डिलीट और ऑर्गनाइज़ करने के लिए होता है।",
      "difficulty": "easy",
      "hint": "यह एक फ़ोल्डर के आइकॉन जैसा दिखता है।",
      "points": 10
    },
    {
      "question": "Windows में 'System File Checker' (sfc /scannow) क्या करता है?",
      "options": ["Drivers अपडेट करता है", "Antivirus scan करता है", "Disk cleanup करता है", "Corrupted system files को scan और repair करता है"],
      "answer": 3,
      "explanation": "sfc /scannow command CMD (admin mode) में चलाएँ तो यह सभी प्रोटेक्टेड सिस्टम फाइल्स को scan करता है और corrupted files को DLLcache से रिपेयर करता है।",
      "difficulty": "hard",
      "hint": "Windows files खराब हों तो यह ठीक करता है।",
      "points": 20
    },
    {
      "question": "CMD में 'ipconfig' कमांड क्या करती है?",
      "options": ["प्रिंटर सेट करती है", "कंप्यूटर बंद करती है", "फाइलें डिलीट करती है", "IP address और network information दिखाती है"],
      "answer": 3,
      "explanation": "ipconfig (IP Configuration) आपके computer की IP address, Subnet Mask, Default Gateway और DNS सेटिंग्स दिखाता है।",
      "difficulty": "hard",
      "hint": "अपना IP address जानने के लिए यह टाइप करें।",
      "points": 20
    },
    {
      "question": "Linux OS किस पर आधारित है?",
      "options": ["Android code", "macOS code", "Windows code", "Open source Unix-like kernel"],
      "answer": 3,
      "explanation": "Linux Linus Torvalds द्वारा बनाया गया एक ओपन-सोर्स Unix-like ऑपरेटिंग सिस्टम है। Ubuntu, Fedora, Debian इसी पर आधारित हैं।",
      "difficulty": "medium",
      "hint": "यह free और open source है।",
      "points": 15
    },
    {
      "question": "Android किस OS पर आधारित है?",
      "options": ["iOS", "macOS", "Windows", "Linux kernel"],
      "answer": 3,
      "explanation": "Android Google का मोबाइल OS है जो Linux kernel पर आधारित है।",
      "difficulty": "medium",
      "hint": "Linux का ही एक modified version है।",
      "points": 15
    },
    {
      "question": "Driver update क्यों जरूरी है?",
      "options": ["डिस्क भरने के लिए", "वायरस डालने के लिए", "कंप्यूटर slow करने के लिए", "Performance improve, bugs fix, security patches"],
      "answer": 3,
      "explanation": "Driver updates से नई सुविधाएँ आती हैं, performance सुधरती है, bugs ठीक होते हैं और security patches आते हैं।",
      "difficulty": "medium",
      "hint": "ग्राफिक्स driver update से गेम fast चलता है।",
      "points": 15
    },
    {
      "question": "Ubuntu किस प्रकार का OS है?",
      "options": ["Mobile OS", "macOS version", "Windows version", "Linux distribution"],
      "answer": 3,
      "explanation": "Ubuntu एक लोकप्रिय Linux distribution है जो desktop और server के लिए free में मिलता है।",
      "difficulty": "medium",
      "hint": "यह Linux का एक 'स्वाद' है।",
      "points": 15
    },
    {
      "question": "Chrome OS किस पर based है?",
      "options": ["Android", "macOS kernel", "Windows kernel", "Linux kernel"],
      "answer": 3,
      "explanation": "Chrome OS Google का lightweight OS है जो Linux kernel पर आधारित है और मुख्य रूप से Chromebooks में web apps के लिए बना है।",
      "difficulty": "hard",
      "hint": "Chromebook में चलता है।",
      "points": 20
    },
    {
      "question": "64-bit और 32-bit OS में मुख्य अंतर क्या है?",
      "options": ["64-bit slower है", "दोनों एक समान हैं", "32-bit ज्यादा RAM support करता है", "64-bit ज्यादा RAM support करता है (4GB से ज्यादा)"],
      "answer": 3,
      "explanation": "32-bit OS ज्यादा से ज्यादा 4GB RAM support करता है। 64-bit OS सैकड़ों GB RAM support करता है और दक्षता ज्यादा है।",
      "difficulty": "hard",
      "hint": "नए कंप्यूटर सभी 64-bit होते हैं।",
      "points": 20
    },
    {
      "question": "किस shortcut key से Windows Explorer खुलता है?",
      "options": ["Windows + F", "Alt + E", "Ctrl + E", "Windows + E"],
      "answer": 3,
      "explanation": "Windows + E दबाने से सीधे File Explorer (This PC) खुल जाता है।",
      "difficulty": "medium",
      "hint": "E का मतलब Explorer है।",
      "points": 15
    },
    {
      "question": "Dual booting क्या है?",
      "options": ["दो mice लगाना", "दो keyboards लगाना", "दो monitors लगाना", "एक कंप्यूटर पर दो OS install करना और boot time पर choose करना"],
      "answer": 3,
      "explanation": "Dual boot आपको एक ही कंप्यूटर पर Windows और Linux जैसे दो ऑपरेटिंग सिस्टम install करने देता है - शुरू में select करना होता है कि कौन चलाना है।",
      "difficulty": "hard",
      "hint": "एक पीसी में Windows + Ubuntu।",
      "points": 20
    },
    {
      "question": "Virtual Machine (VM) क्या है?",
      "options": ["एक network device", "एक type of RAM", "एक physical computer", "एक software जो दूसरे OS को current OS के अंदर चलाता है"],
      "answer": 3,
      "explanation": "Virtual Machine (जैसे VirtualBox, VMware) एक सॉफ्टवेयर है जो आपके current OS (host) के अंदर दूसरा OS (guest) चलाती है - बिना dual boot के।",
      "difficulty": "hard",
      "hint": "Windows के अंदर Linux चलाना।",
      "points": 20
    },
    {
      "question": "macOS किस कंपनी का OS है?",
      "options": ["IBM", "Google", "Microsoft", "Apple"],
      "answer": 3,
      "explanation": "macOS Apple Inc. का कंप्यूटर OS है जो केवल Macintosh कंप्यूटर्स पर चलता है।",
      "difficulty": "easy",
      "hint": "जो iPhone बनाती है वही।",
      "points": 10
    }
  ]
};

  // ─── Init / Dispose ───────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initAchievements();
    _animationController.forward();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _timerController = AnimationController(
      duration: Duration(seconds: _questionTimeLimit),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.linear),
    );
  }

  void _initAchievements() {
    _achievements = [
      Achievement(id: 'first_quiz', title: 'First Quiz', description: 'Complete your first quiz', icon: Icons.star, color: AppColors.warning),
      Achievement(id: 'perfect_score', title: 'Perfect Score', description: 'Score 100% on any quiz', icon: Icons.emoji_events, color: AppColors.warning),
      Achievement(id: 'speed_demon', title: 'Speed Demon', description: 'Complete a quiz in under 60 seconds', icon: Icons.flash_on, color: AppColors.accent),
      Achievement(id: 'streak_3', title: 'On Fire!', description: 'Answer 3 questions correctly in a row', icon: Icons.local_fire_department, color: AppColors.error),
      Achievement(id: 'bookworm', title: 'Bookworm', description: 'Bookmark 5 questions', icon: Icons.bookmark, color: AppColors.secondary),
      Achievement(id: 'all_topics', title: 'Explorer', description: 'Try all available topics', icon: Icons.explore, color: AppColors.primary),
      Achievement(id: 'no_hints', title: 'No Cheating!', description: 'Complete a quiz without using hints', icon: Icons.psychology, color: AppColors.primaryDark),
      Achievement(id: 'hundred_points', title: 'Century Club', description: 'Earn 100 total points', icon: Icons.monetization_on, color: AppColors.warning),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _timerController.dispose();
    _questionTimer?.cancel();
    _totalTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Timer Logic ──────────────────────────────────────────────
  void _startQuestionTimer() {
    if (!_isTimerEnabled) return;
    _remainingTime = _questionTimeLimit;
    _timerController.reset();
    _timerController.forward();
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _remainingTime--);
      if (_remainingTime <= 0) {
        t.cancel();
        _autoSkipQuestion();
      }
    });
  }

  void _stopQuestionTimer() {
    _questionTimer?.cancel();
    _timerController.stop();
  }

  void _startTotalTimer() {
    _totalQuizTime = 0;
    _totalTimer?.cancel();
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _totalQuizTime++);
    });
  }

  void _stopTotalTimer() => _totalTimer?.cancel();

  void _autoSkipQuestion() {
    if (_selectedOption == null) {
      setState(() {
        _userAnswers[_currentQuestionIndex] = -1;
        _selectedOption = -1;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          if (_currentQuestionIndex < _currentQuestions.length - 1) {
            _nextQuestion();
          } else {
            _showResult();
          }
        }
      });
    }
  }

  // ─── Navigation Logic ─────────────────────────────────────────
  void _selectTopic(String topic) {
    var questions = List<Map<String, dynamic>>.from(quizData[topic]!);
    if (_selectedDifficulty != Difficulty.all) {
      questions = questions
          .where((q) => q['difficulty'] == _selectedDifficulty.name)
          .toList();
    }
    if (questions.isEmpty) {
      _showSnackBar('No questions for selected difficulty. Showing all.', AppColors.warning);
      questions = List<Map<String, dynamic>>.from(quizData[topic]!);
    }
    if (_isPracticeMode) questions.shuffle();
    setState(() {
      _selectedTopic = topic;
      _currentQuestions = questions;
      _userAnswers = List.filled(questions.length, null);
      _currentQuestionIndex = 0;
      _selectedOption = null;
      _showExplanation = false;
      _hintsUsed = 0;
      _showHint = false;
      _isBookmarked = false;
      _streakCount = 0;
      _currentState = QuizState.quiz;
    });
    _animateTransition();
    _startTotalTimer();
    _startQuestionTimer();
  }

  void _selectAnswer(int optionIndex) {
    if (_selectedOption != null && _selectedOption != -1) return;
    _stopQuestionTimer();
    final isCorrect = optionIndex == _currentQuestions[_currentQuestionIndex]['answer'];
    setState(() {
      _selectedOption = optionIndex;
      _userAnswers[_currentQuestionIndex] = optionIndex;
      if (isCorrect) {
        _streakCount++;
        _totalPoints += (_currentQuestions[_currentQuestionIndex]['points'] as int);
        if (_streakCount >= 3) _checkAchievement('streak_3');
      } else {
        _streakCount = 0;
      }
      if (_isPracticeMode) _showExplanation = true;
    });
    if (_isPracticeMode) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _currentQuestionIndex < _currentQuestions.length - 1) _nextQuestion();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _currentQuestionIndex < _currentQuestions.length - 1) _nextQuestion();
      });
    }
  }

  void _nextQuestion() {
    _stopQuestionTimer();
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = _userAnswers[_currentQuestionIndex];
        _showExplanation = _isPracticeMode && _selectedOption != null;
        _showHint = false;
        _isBookmarked = _bookmarkedQuestions.contains(_currentQuestionIndex);
      });
      _startQuestionTimer();
    } else {
      _showResult();
    }
  }

  void _previousQuestion() {
    _stopQuestionTimer();
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedOption = _userAnswers[_currentQuestionIndex];
        _showExplanation = _isPracticeMode && _selectedOption != null;
        _showHint = false;
        _isBookmarked = _bookmarkedQuestions.contains(_currentQuestionIndex);
      });
      _startQuestionTimer();
    }
  }

  void _jumpToQuestion(int index) {
    _stopQuestionTimer();
    setState(() {
      _currentQuestionIndex = index;
      _selectedOption = _userAnswers[index];
      _showExplanation = _isPracticeMode && _selectedOption != null;
      _showHint = false;
      _isBookmarked = _bookmarkedQuestions.contains(index);
    });
    _startQuestionTimer();
    Navigator.pop(context);
  }

  void _showResult() {
    _stopQuestionTimer();
    _stopTotalTimer();
    final attempt = QuizAttempt(
      topic: _selectedTopic,
      score: _score,
      total: _currentQuestions.length,
      date: DateTime.now(),
      timeTakenSeconds: _totalQuizTime,
      isPracticeMode: _isPracticeMode,
    );
    setState(() {
      _attemptHistory.insert(0, attempt);
      _quizzesCompleted++;
      if (_quizzesCompleted == 1) _checkAchievement('first_quiz');
      if (_percentage == 100) {
        _checkAchievement('perfect_score');
        _showConfetti = true;
      }
      if (_totalQuizTime < 60) _checkAchievement('speed_demon');
      if (_hintsUsed == 0) _checkAchievement('no_hints');
      if (_totalPoints >= 100) _checkAchievement('hundred_points');
      final prevBest = _topicBestScores[_selectedTopic] ?? 0;
      if (_score > prevBest) _topicBestScores[_selectedTopic] = _score;
      _currentState = QuizState.result;
    });
    _animateTransition();
    if (_showConfetti) {
      _confettiController.forward();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showConfetti = false);
      });
    }
  }

  void _checkAchievement(String id) {
    final ach = _achievements.firstWhere((a) => a.id == id, orElse: () => _achievements[0]);
    if (!ach.isUnlocked) {
      ach.isUnlocked = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showAchievementPopup(ach);
      });
    }
  }

  void _restartQuiz() {
    if (_isPracticeMode) _currentQuestions.shuffle();
    setState(() {
      _userAnswers = List.filled(_currentQuestions.length, null);
      _currentQuestionIndex = 0;
      _selectedOption = null;
      _showExplanation = false;
      _hintsUsed = 0;
      _showHint = false;
      _streakCount = 0;
      _currentState = QuizState.quiz;
    });
    _animateTransition();
    _startTotalTimer();
    _startQuestionTimer();
  }

  void _resetToTopics() {
    _stopQuestionTimer();
    _stopTotalTimer();
    setState(() {
      _currentState = QuizState.topic;
      _selectedTopic = '';
      _currentQuestions = [];
      _userAnswers = [];
      _currentQuestionIndex = 0;
      _selectedOption = null;
      _showHint = false;
    });
    _animateTransition();
  }

  void _toggleMode() => setState(() => _isPracticeMode = !_isPracticeMode);

  void _animateTransition() {
    _animationController.reset();
    _animationController.forward();
  }

  void _toggleHint() {
    if (!_showHint && _hintsUsed < _maxHints) {
      setState(() { _showHint = true; _hintsUsed++; });
    } else if (_showHint) {
      setState(() => _showHint = false);
    } else {
      _showSnackBar('No hints remaining!', AppColors.error);
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      if (_isBookmarked) {
        _bookmarkedQuestions.add(_currentQuestionIndex);
      } else {
        _bookmarkedQuestions.remove(_currentQuestionIndex);
      }
      if (_bookmarkedQuestions.length >= 5) _checkAchievement('bookworm');
    });
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAchievementPopup(Achievement ach) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(ach.icon, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('🏆 Achievement Unlocked!', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text(ach.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(ach.description, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Computed ─────────────────────────────────────────────────
  int get _score {
    int correct = 0;
    for (int i = 0; i < _userAnswers.length; i++) {
      if (_userAnswers[i] != null &&
          _userAnswers[i] != -1 &&
          _userAnswers[i] == _currentQuestions[i]['answer']) correct++;
    }
    return correct;
  }

  double get _percentage => (_score / _currentQuestions.length) * 100;

  String get _formattedTime {
    final m = _totalQuizTime ~/ 60;
    final s = _totalQuizTime % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> get _filteredTopics {
    return quizData.keys
        .where((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()))
        .map((t) => {'topic': t, 'count': quizData[t]!.length})
        .toList()
      ..sort((a, b) {
        if (_sortOption == SortOption.alphabetical) return (a['topic'] as String).compareTo(b['topic'] as String);
        if (_sortOption == SortOption.questionCount) return (b['count'] as int).compareTo(a['count'] as int);
        return 0;
      });
  }

  // ─── RESPONSIVE HELPERS ───────────────────────────────────────
  bool _isTablet(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 600;
  bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1024;
  int _gridCols(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w >= 1024) return 4;
    if (w >= 600) return 3;
    return 2;
  }

  double _cardAspect(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w >= 1024) return 1.5;
    if (w >= 600) return 1.4;
    return 1.3;
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isTab = _isTablet(context);
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF0A1628) : AppColors.offWhite,
      appBar: _buildAppBar(isTab),
      body: Container(
        decoration: _isDarkMode
            ? const BoxDecoration(color: Color(0xFF0A1628))
            : const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8F4FD), Color(0xFFE8F5E9), AppColors.white],
                ),
              ),
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildCurrentState(),
              ),
            ),
            if (_showConfetti) _buildConfettiOverlay(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isTab) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.computer, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            'BS-CIT Quiz',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    switch (_currentState) {
      case QuizState.quiz:
        return [
          if (_isTimerEnabled)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _remainingTime <= 10 ? AppColors.error : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '$_remainingTime s',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 3),
                  Text(
                    '$_totalPoints',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white), onPressed: _toggleBookmark, tooltip: 'Bookmark'),
          IconButton(icon: const Icon(Icons.lightbulb_outline, color: Colors.amber), onPressed: _toggleHint, tooltip: 'Hint (${ _maxHints - _hintsUsed} left)'),
          IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: _showModeDialog),
          IconButton(icon: const Icon(Icons.grid_view, color: Colors.white), onPressed: _showQuestionNavigator),
        ];
      case QuizState.topic:
        return [
          IconButton(icon: const Icon(Icons.leaderboard, color: Colors.white), onPressed: () => setState(() { _currentState = QuizState.leaderboard; _animateTransition(); }), tooltip: 'History'),
          IconButton(icon: const Icon(Icons.emoji_events, color: Colors.amber), onPressed: _showAchievementsDialog, tooltip: 'Achievements'),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            tooltip: 'Toggle Theme',
          ),
        ];
      case QuizState.result:
        return [
          IconButton(icon: const Icon(Icons.analytics, color: Colors.white), onPressed: _showAnalyticsDialog, tooltip: 'Analytics'),
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () => _showSnackBar('Share feature coming soon!', AppColors.primary), tooltip: 'Share'),
        ];
      default:
        return [];
    }
  }

  Widget _buildCurrentState() {
    switch (_currentState) {
      case QuizState.topic: return _buildTopicSelection();
      case QuizState.quiz: return _buildQuizView();
      case QuizState.result: return _buildResultView();
      case QuizState.leaderboard: return _buildHistoryView();
      default: return _buildTopicSelection();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  TOPIC SELECTION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTopicSelection() {
    final isTab = _isTablet(context);
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(isTab ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 20),
          _buildSearchAndFilter(),
          const SizedBox(height: 16),
          _buildTopicGrid(),
          const SizedBox(height: 16),
          _buildRecentActivity(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.computer, size: 36, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BS-CIT Quiz Master', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 4),
                    Text('Build your computer skills one topic at a time', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildModeToggle(),
              const Spacer(),
              _buildDifficultySelector(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.school, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          const Text('Practice', style: TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(width: 8),
          SizedBox(
            height: 24,
            child: Switch(
              value: _isPracticeMode,
              onChanged: (_) => _toggleMode(),
              activeColor: Colors.white,
              activeTrackColor: AppColors.secondaryLight,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Difficulty>(
          value: _selectedDifficulty,
          dropdownColor: AppColors.primary,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
          items: Difficulty.values.map((d) => DropdownMenuItem(
            value: d,
            child: Text(d.name[0].toUpperCase() + d.name.substring(1), style: const TextStyle(color: Colors.white)),
          )).toList(),
          onChanged: (v) => setState(() => _selectedDifficulty = v!),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('Quizzes', '$_quizzesCompleted', Icons.quiz, AppColors.primary),
        const SizedBox(width: 12),
        _buildStatCard('Points', '$_totalPoints', Icons.star, AppColors.warning),
        const SizedBox(width: 12),
        _buildStatCard('Streak', '$_streakCount', Icons.local_fire_department, AppColors.error),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : AppColors.textDark)),
            Text(label, style: TextStyle(fontSize: 11, color: _isDarkMode ? Colors.white54 : AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: _isDarkMode ? Colors.white : AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Search topics...',
                hintStyle: TextStyle(color: _isDarkMode ? Colors.white38 : AppColors.textLight),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: PopupMenuButton<SortOption>(
            color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (v) => setState(() => _sortOption = v),
            itemBuilder: (_) => [
              PopupMenuItem(value: SortOption.alphabetical, child: Text('A-Z', style: TextStyle(color: _isDarkMode ? Colors.white : AppColors.textDark))),
              PopupMenuItem(value: SortOption.questionCount, child: Text('By Questions', style: TextStyle(color: _isDarkMode ? Colors.white : AppColors.textDark))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicGrid() {
    final topics = _filteredTopics;
    if (topics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.textLight.withOpacity(0.5)),
              const SizedBox(height: 12),
              Text('No topics found', style: TextStyle(color: _isDarkMode ? Colors.white54 : AppColors.textLight, fontSize: 16)),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridCols(context),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: _cardAspect(context),
      ),
      itemCount: topics.length,
      itemBuilder: (_, i) => _buildTopicCard(topics[i]['topic'] as String),
    );
  }

  Widget _buildTopicCard(String topic) {
    final best = _topicBestScores[topic];
    final total = quizData[topic]!.length;
    return Card(
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _selectTopic(topic),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getTopicGradient(topic),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: Icon(_getTopicIcon(topic), size: 26, color: Colors.white),
                        ),
                        const Spacer(),
                        if (best != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(8)),
                            child: Text('Best: $best/$total', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(topic, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text('$total Q', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text(_getDifficultyLabel(topic), style: const TextStyle(color: Colors.white, fontSize: 11)),
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
    );
  }

  List<Color> _getTopicGradient(String topic) {
    final gradients = [
      [AppColors.primary, AppColors.primaryLight],
      [AppColors.secondary, AppColors.secondaryLight],
      [AppColors.primaryDark, AppColors.accent],
      [const Color(0xFF1B5E20), const Color(0xFF43A047)],
      [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
      [const Color(0xFF004D40), const Color(0xFF00897B)],
    ];
    final i = quizData.keys.toList().indexOf(topic) % gradients.length;
    return gradients[i];
  }

  String _getDifficultyLabel(String topic) {
    final qs = quizData[topic]!;
    final hard = qs.where((q) => q['difficulty'] == 'hard').length;
    if (hard > 2) return '🔴 Hard';
    final med = qs.where((q) => q['difficulty'] == 'medium').length;
    if (med > 2) return '🟡 Medium';
    return '🟢 Easy';
  }

  Widget _buildRecentActivity() {
    if (_attemptHistory.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 12),
        ..._attemptHistory.take(3).map((a) => _buildAttemptTile(a)),
      ],
    );
  }

  Widget _buildAttemptTile(QuizAttempt a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: a.percentage >= 70 ? [AppColors.secondary, AppColors.secondaryLight] : [AppColors.error, Colors.red[300]!],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(a.grade, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.topic, style: TextStyle(fontWeight: FontWeight.w600, color: _isDarkMode ? Colors.white : AppColors.textDark)),
                Text('${a.score}/${a.total} • ${a.percentage.toStringAsFixed(0)}% • ${a.timeTakenSeconds}s',
                    style: TextStyle(fontSize: 12, color: _isDarkMode ? Colors.white54 : AppColors.textLight)),
              ],
            ),
          ),
          Text(
            '${a.date.day}/${a.date.month}',
            style: TextStyle(fontSize: 12, color: _isDarkMode ? Colors.white38 : AppColors.textLight),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  QUIZ VIEW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildQuizView() {
    final question = _currentQuestions[_currentQuestionIndex];
    return Column(
      children: [
        _buildQuizHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_isTablet(context) ? 24 : 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _isDesktop(context) ? 800 : double.infinity),
              child: Column(
                children: [
                  _buildQuestionCard(question),
                  const SizedBox(height: 16),
                  ...List.generate(4, (i) => _buildOptionCard(i, question['options'][i], question['answer'] as int)),
                  if (_showHint) _buildHintCard(question),
                  if (_showExplanation && _isPracticeMode) _buildExplanationCard(question),
                  if (_bookmarkedQuestions.contains(_currentQuestionIndex))
                    _buildBookmarkBadge(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        _buildQuizFooter(),
      ],
    );
  }

  Widget _buildQuizHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedTopic,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const Spacer(),
              _buildTimerWidget(),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⏱ $_formattedTime',
                  style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Q ${_currentQuestionIndex + 1} of ${_currentQuestions.length}',
                style: TextStyle(color: _isDarkMode ? Colors.white70 : AppColors.textMid, fontWeight: FontWeight.w600),
              ),
              Text(
                '${((_currentQuestionIndex + 1) / _currentQuestions.length * 100).toInt()}%',
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _currentQuestions.length,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 7,
            ),
          ),
          if (_isTimerEnabled) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedBuilder(
                animation: _timerAnimation,
                builder: (_, __) => LinearProgressIndicator(
                  value: _remainingTime / _questionTimeLimit,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _remainingTime <= 10 ? AppColors.error : AppColors.accent,
                  ),
                  minHeight: 4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerWidget() {
    if (!_isTimerEnabled) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _remainingTime <= 10 ? AppColors.error.withOpacity(0.15) : AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, size: 14, color: _remainingTime <= 10 ? AppColors.error : AppColors.accent),
          const SizedBox(width: 4),
          Text(
            '$_remainingTime s',
            style: TextStyle(
              color: _remainingTime <= 10 ? AppColors.error : AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final diff = question['difficulty'] as String;
    final pts = question['points'] as int;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: const Offset(0, 6))],
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildDifficultyBadge(diff),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('+$pts pts', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            question['question'] as String,
            style: TextStyle(
              fontSize: _isTablet(context) ? 20 : 17,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: _isDarkMode ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String diff) {
    final colors = {'easy': AppColors.success, 'medium': AppColors.warning, 'hard': AppColors.error};
    final labels = {'easy': '🟢 Easy', 'medium': '🟡 Medium', 'hard': '🔴 Hard'};
    final c = colors[diff] ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(labels[diff] ?? diff, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _buildOptionCard(int index, String text, int correctAnswer) {
    bool isSelected = _selectedOption == index;
    bool isCorrect = isSelected && index == correctAnswer;
    bool isWrong = isSelected && index != correctAnswer;
    bool showCorrect = _selectedOption != null && index == correctAnswer;
    bool isTimeout = _selectedOption == -1;

    Color borderColor;
    Color bgColor;
    if (isSelected) {
      borderColor = isCorrect ? AppColors.success : AppColors.error;
      bgColor = isCorrect ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1);
    } else if (showCorrect) {
      borderColor = AppColors.success;
      bgColor = AppColors.success.withOpacity(0.08);
    } else {
      borderColor = _isDarkMode ? Colors.white12 : AppColors.primary.withOpacity(0.15);
      bgColor = _isDarkMode ? const Color(0xFF1A2740) : Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (_selectedOption == null || _selectedOption == -1) && !isTimeout ? () => _selectAnswer(index) : null,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: isSelected || showCorrect ? 2 : 1),
              boxShadow: [BoxShadow(color: borderColor.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? (isCorrect ? AppColors.success : AppColors.error)
                        : (showCorrect ? AppColors.success : (isTimeout && index == correctAnswer ? AppColors.success : AppColors.primary.withOpacity(0.12))),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: (isSelected || showCorrect) ? Colors.white : (_isDarkMode ? Colors.white70 : AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: _isTablet(context) ? 16 : 14,
                      height: 1.4,
                      color: _isDarkMode ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected || showCorrect ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCorrect) const Icon(Icons.check_circle, color: AppColors.success, size: 22),
                if (isWrong) const Icon(Icons.cancel, color: AppColors.error, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHintCard(Map<String, dynamic> question) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: AppColors.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hint', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning, fontSize: 13)),
                const SizedBox(height: 4),
                Text(question['hint'] as String, style: TextStyle(color: _isDarkMode ? Colors.white70 : AppColors.textMid, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(Map<String, dynamic> question) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.menu_book, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                const SizedBox(height: 6),
                Text(question['explanation'] as String,
                    style: TextStyle(color: _isDarkMode ? Colors.white70 : AppColors.textMid, height: 1.5, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark, color: AppColors.secondary, size: 16),
          SizedBox(width: 6),
          Text('Bookmarked', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuizFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            _buildFooterButton('Prev', Icons.arrow_back_ios_new, AppColors.textLight, _previousQuestion)
          else
            _buildFooterButton('Topics', Icons.home_outlined, AppColors.textLight, _resetToTopics),
          const Spacer(),
          if (_currentQuestionIndex < _currentQuestions.length - 1)
            _buildFooterButton(
              'Next',
              Icons.arrow_forward_ios,
              _selectedOption != null ? AppColors.primary : AppColors.textLight,
              _selectedOption != null ? _nextQuestion : null,
              isForward: true,
            )
          else
            _buildFooterButton(
              'Finish',
              Icons.check_circle_outline,
              _selectedOption != null ? AppColors.success : AppColors.textLight,
              _selectedOption != null ? _showResult : null,
              isForward: true,
            ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String label, IconData icon, Color color, VoidCallback? onTap, {bool isForward = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: onTap != null ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: onTap != null ? color.withOpacity(0.3) : Colors.transparent),
          ),
          child: Row(
            children: isForward
                ? [Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)), const SizedBox(width: 6), Icon(icon, size: 16, color: color)]
                : [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700))],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  RESULT VIEW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildResultView() {
    final attempt = _attemptHistory.isNotEmpty ? _attemptHistory.first : null;
    return SingleChildScrollView(
      padding: EdgeInsets.all(_isTablet(context) ? 24 : 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _isDesktop(context) ? 800 : double.infinity),
        child: Column(
          children: [
            _buildResultCard(),
            const SizedBox(height: 20),
            _buildResultStats(attempt),
            const SizedBox(height: 20),
            _buildQuestionReviewList(),
            const SizedBox(height: 20),
            _buildResultActions(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final grade = _score / _currentQuestions.length >= 0.9 ? 'A+' :
                  _score / _currentQuestions.length >= 0.8 ? 'A' :
                  _score / _currentQuestions.length >= 0.7 ? 'B' :
                  _score / _currentQuestions.length >= 0.6 ? 'C' : 'D';
    final message = _percentage >= 90 ? '🎉 Outstanding!' :
                    _percentage >= 70 ? '✅ Well Done!' :
                    _percentage >= 50 ? '👍 Keep Going!' : '📚 Need Practice';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(message, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CircularProgressIndicator(
                  value: _percentage / 100,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 10,
                ),
              ),
              Column(
                children: [
                  Text(grade, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('${_percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('$_score / ${_currentQuestions.length} Correct', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildResultChip(Icons.timer, _formattedTime),
              const SizedBox(width: 12),
              _buildResultChip(Icons.star, '+$_totalPoints pts'),
              const SizedBox(width: 12),
              _buildResultChip(Icons.local_fire_department, 'Streak: $_streakCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildResultStats(QuizAttempt? a) {
    if (a == null) return const SizedBox.shrink();
    final correct = _userAnswers.where((ans) => ans != null && ans != -1 && ans == _currentQuestions[_userAnswers.indexOf(ans)]['answer']).length;
    final skipped = _userAnswers.where((ans) => ans == -1 || ans == null).length;
    final wrong = _currentQuestions.length - correct - skipped;
    return Row(
      children: [
        _buildMiniStatCard('Correct', '$correct', AppColors.success),
        const SizedBox(width: 10),
        _buildMiniStatCard('Wrong', '$wrong', AppColors.error),
        const SizedBox(width: 10),
        _buildMiniStatCard('Skipped', '$skipped', AppColors.warning),
        const SizedBox(width: 10),
        _buildMiniStatCard('Hints', '$_hintsUsed', AppColors.accent),
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: _isDarkMode ? Colors.white54 : AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionReviewList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Review Answers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : AppColors.textDark)),
            const Spacer(),
            _buildFilterChip('All', !_showCorrectOnly && !_showWrongOnly, () => setState(() { _showCorrectOnly = false; _showWrongOnly = false; })),
            const SizedBox(width: 6),
            _buildFilterChip('✓', _showCorrectOnly, () => setState(() { _showCorrectOnly = true; _showWrongOnly = false; })),
            const SizedBox(width: 6),
            _buildFilterChip('✗', _showWrongOnly, () => setState(() { _showWrongOnly = true; _showCorrectOnly = false; })),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_currentQuestions.length, (i) {
          final isCorrect = _userAnswers[i] != null && _userAnswers[i] != -1 && _userAnswers[i] == _currentQuestions[i]['answer'];
          final isSkipped = _userAnswers[i] == null || _userAnswers[i] == -1;
          if (_showCorrectOnly && !isCorrect) return const SizedBox.shrink();
          if (_showWrongOnly && (isCorrect || isSkipped)) return const SizedBox.shrink();
          return _buildReviewTile(i, isCorrect, isSkipped);
        }),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildReviewTile(int i, bool isCorrect, bool isSkipped) {
    final q = _currentQuestions[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSkipped ? AppColors.warning.withOpacity(0.3) : (isCorrect ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3)),
        ),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSkipped ? AppColors.warning : (isCorrect ? AppColors.success : AppColors.error),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isSkipped
                ? const Icon(Icons.skip_next, color: Colors.white, size: 16)
                : Icon(isCorrect ? Icons.check : Icons.close, color: Colors.white, size: 16),
          ),
        ),
        title: Text(
          q['question'] as String,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _isDarkMode ? Colors.white : AppColors.textDark),
        ),
        subtitle: Text(
          isSkipped ? 'Skipped / Timed Out'
              : 'Your: ${_userAnswers[i] != null ? String.fromCharCode(65 + _userAnswers[i]!) : '-'}',
          style: TextStyle(color: isSkipped ? AppColors.warning : (isCorrect ? AppColors.success : AppColors.error), fontSize: 12),
        ),
        children: [
          const Divider(),
          Row(
            children: [
              const Text('✓ Correct: ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
              Expanded(child: Text(
                '${String.fromCharCode(65 + (q['answer'] as int))}. ${q['options'][q['answer']]}',
                style: TextStyle(color: _isDarkMode ? Colors.white70 : AppColors.textMid),
              )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📖 ', style: TextStyle(fontSize: 14)),
              Expanded(child: Text(
                q['explanation'] as String,
                style: TextStyle(color: _isDarkMode ? Colors.white54 : AppColors.textLight, height: 1.5),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton('Restart', Icons.refresh, AppColors.primary, _restartQuiz),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton('New Topic', Icons.home, AppColors.secondary, _resetToTopics),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionButton('View History', Icons.history, AppColors.accent, () => setState(() { _currentState = QuizState.leaderboard; _animateTransition(); }), fullWidth: true),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap, {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HISTORY VIEW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHistoryView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() { _currentState = QuizState.topic; _animateTransition(); }),
              ),
              const Text('Quiz History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              Text('${_attemptHistory.length} attempts', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        Expanded(
          child: _attemptHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: AppColors.textLight.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No quiz history yet', style: TextStyle(color: _isDarkMode ? Colors.white54 : AppColors.textLight, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Complete a quiz to see your history', style: TextStyle(color: _isDarkMode ? Colors.white38 : AppColors.textLight, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _attemptHistory.length,
                  itemBuilder: (_, i) => _buildHistoryCard(_attemptHistory[i], i),
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(QuizAttempt a, int i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
        border: Border(left: BorderSide(color: a.percentage >= 70 ? AppColors.success : AppColors.error, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: a.percentage >= 70 ? [AppColors.secondary, AppColors.secondaryLight] : [AppColors.error, Colors.red[300]!],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(a.grade, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.topic, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _isDarkMode ? Colors.white : AppColors.textDark)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${a.score}/${a.total}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text('${a.percentage.toStringAsFixed(0)}%', style: TextStyle(color: a.percentage >= 70 ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text('⏱ ${a.timeTakenSeconds}s', style: TextStyle(color: _isDarkMode ? Colors.white54 : AppColors.textLight, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: a.percentage / 100,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(a.percentage >= 70 ? AppColors.success : AppColors.error),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${a.date.day}/${a.date.month}', style: TextStyle(fontSize: 11, color: _isDarkMode ? Colors.white38 : AppColors.textLight)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: a.isPracticeMode ? AppColors.secondary.withOpacity(0.15) : AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  a.isPracticeMode ? 'Practice' : 'Exam',
                  style: TextStyle(fontSize: 10, color: a.isPracticeMode ? AppColors.secondary : AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  DIALOGS / MODALS
  // ═══════════════════════════════════════════════════════════════

  void _showModeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Quiz Settings', style: TextStyle(color: _isDarkMode ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              value: true,
              groupValue: _isPracticeMode,
              onChanged: (v) { _toggleMode(); Navigator.pop(context); },
              title: Text('Practice Mode', style: TextStyle(color: _isDarkMode ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600)),
              subtitle: Text('Shows explanation after each answer', style: TextStyle(color: _isDarkMode ? Colors.white54 : AppColors.textLight, fontSize: 12)),
              secondary: const Icon(Icons.school, color: AppColors.primary),
              activeColor: AppColors.primary,
            ),
            RadioListTile<bool>(
              value: false,
              groupValue: _isPracticeMode,
              onChanged: (v) { _toggleMode(); Navigator.pop(context); },
              title: Text('Exam Mode', style: TextStyle(color: _isDarkMode ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w600)),
              subtitle: Text('Review answers at the end only', style: TextStyle(color: _isDarkMode ? Colors.white54 : AppColors.textLight, fontSize: 12)),
              secondary: const Icon(Icons.edit_note, color: AppColors.secondary),
              activeColor: AppColors.secondary,
            ),
            const Divider(),
            SwitchListTile(
              value: _isTimerEnabled,
              onChanged: (v) => setState(() => _isTimerEnabled = v),
              title: Text('Question Timer', style: TextStyle(color: _isDarkMode ? Colors.white : AppColors.textDark)),
              secondary: const Icon(Icons.timer, color: AppColors.accent),
              activeColor: AppColors.accent,
            ),
            SwitchListTile(
              value: _isSoundEnabled,
              onChanged: (v) => setState(() => _isSoundEnabled = v),
              title: Text('Sound Effects', style: TextStyle(color: _isDarkMode ? Colors.white : AppColors.textDark)),
              secondary: const Icon(Icons.volume_up, color: AppColors.warning),
              activeColor: AppColors.warning,
            ),
            if (_isTimerEnabled) ...[
              const SizedBox(height: 8),
              Text('Time per question: $_questionTimeLimit s', style: TextStyle(color: _isDarkMode ? Colors.white70 : AppColors.textMid)),
              Slider(
                value: _questionTimeLimit.toDouble(),
                min: 10,
                max: 60,
                divisions: 10,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _questionTimeLimit = v.toInt()),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Quick Navigation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavLegend(AppColors.success, 'Correct'),
                const SizedBox(width: 16),
                _buildNavLegend(AppColors.error, 'Wrong'),
                const SizedBox(width: 16),
                _buildNavLegend(Colors.grey, 'Unanswered'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, crossAxisSpacing: 10, mainAxisSpacing: 10,
                ),
                itemCount: _currentQuestions.length,
                itemBuilder: (_, i) {
                  final answered = _userAnswers[i] != null && _userAnswers[i] != -1;
                  final correct = answered && _userAnswers[i] == _currentQuestions[i]['answer'];
                  final bookmarked = _bookmarkedQuestions.contains(i);
                  final isCurrent = i == _currentQuestionIndex;
                  return InkWell(
                    onTap: () => _jumpToQuestion(i),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _userAnswers[i] == -1 ? AppColors.warning.withOpacity(0.3)
                            : (answered ? (correct ? AppColors.success : AppColors.error) : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(10),
                        border: isCurrent ? Border.all(color: AppColors.primary, width: 2.5) : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: answered ? Colors.white : Colors.black87,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          if (bookmarked)
                            Positioned(top: 2, right: 2, child: Icon(Icons.bookmark, size: 8, color: answered ? Colors.white : AppColors.secondary)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: _isDarkMode ? Colors.white54 : AppColors.textLight)),
      ],
    );
  }

  void _showAchievementsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Achievements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : AppColors.textDark)),
            Text('${_achievements.where((a) => a.isUnlocked).length}/${_achievements.length} unlocked',
                style: TextStyle(color: _isDarkMode ? Colors.white54 : AppColors.textLight)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _achievements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final a = _achievements[i];
                  return AnimatedOpacity(
                    opacity: a.isUnlocked ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isDarkMode ? const Color(0xFF243552) : AppColors.offWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: a.isUnlocked ? a.color.withOpacity(0.4) : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: a.isUnlocked ? a.color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(a.icon, color: a.isUnlocked ? a.color : Colors.grey, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.title, style: TextStyle(fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : AppColors.textDark)),
                                Text(a.description, style: TextStyle(fontSize: 12, color: _isDarkMode ? Colors.white54 : AppColors.textLight)),
                              ],
                            ),
                          ),
                          if (a.isUnlocked) const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalyticsDialog() {
    if (_attemptHistory.isEmpty) { _showSnackBar('No history yet!', AppColors.warning); return; }
    final byTopic = <String, List<QuizAttempt>>{};
    for (final a in _attemptHistory) {
      byTopic.putIfAbsent(a.topic, () => []).add(a);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1A2740) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Performance Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: byTopic.entries.map((e) {
                  final attempts = e.value;
                  final avg = attempts.map((a) => a.percentage).reduce((a, b) => a + b) / attempts.length;
                  final best = attempts.map((a) => a.percentage).reduce(max);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? const Color(0xFF243552) : AppColors.offWhite,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _isDarkMode ? Colors.white : AppColors.textDark)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildAnalyticChip('Attempts', '${attempts.length}', AppColors.primary),
                            const SizedBox(width: 8),
                            _buildAnalyticChip('Avg', '${avg.toStringAsFixed(0)}%', AppColors.accent),
                            const SizedBox(width: 8),
                            _buildAnalyticChip('Best', '${best.toStringAsFixed(0)}%', AppColors.success),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: avg / 100,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(avg >= 70 ? AppColors.success : AppColors.error),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticChip(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
        ],
      ),
    );
  }

  // ─── Confetti ─────────────────────────────────────────────────
  Widget _buildConfettiOverlay() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _confettiController,
        builder: (_, __) => CustomPaint(
          painter: _ConfettiPainter(_confettiController.value),
          size: MediaQuery.of(context).size,
        ),
      ),
    );
  }

  // ─── Icon Map ─────────────────────────────────────────────────
  IconData _getTopicIcon(String topic) {
    const icons = {
      "Computer Basics": Icons.computer,
      "Internet": Icons.wifi,
      "MS Word": Icons.description,
      "MS Excel": Icons.table_chart,
      "Operating Systems": Icons.settings_applications,
      "Networking": Icons.lan,
    };
    return icons[topic] ?? Icons.school;
  }
}

// ═══════════════════════════════════════════════════════════════
//  CONFETTI PAINTER
// ═══════════════════════════════════════════════════════════════

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final _rng = Random(42);

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [AppColors.primary, AppColors.secondary, AppColors.warning, AppColors.accent, AppColors.success];
    for (int i = 0; i < 80; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = (_rng.nextDouble() * size.height * progress * 1.5) - 20;
      final paint = Paint()..color = colors[i % colors.length].withOpacity(1 - progress);
      canvas.drawCircle(Offset(x, y), 5 + _rng.nextDouble() * 5, paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}