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
  ],
    "3. Windows Settings and Personalization": [
    {
      "question": "Windows में 'Settings' ऐप कैसे खोलें?",
      "options": ["Windows + I", "Windows + S", "Windows + R", "Windows + E"],
      "answer": 1,
      "explanation": "Windows + I सीधे Settings ऐप खोलता है। Start Menu में गियर आइकन से भी खोल सकते हैं।",
      "difficulty": "easy",
      "hint": "I का मतलब Settings का गियर आइकन नहीं बल्कि 'I' key है।",
      "points": 10
    },
    {
      "question": "Windows में Desktop Background (Wallpaper) कैसे बदलें?",
      "options": ["Settings → Personalization → Background", "Settings → System → Display", "Control Panel → Fonts", "File Explorer → View"],
      "answer": 2,
      "explanation": "Settings → Personalization → Background से आप Picture, Solid Color, या Slideshow के रूप में वॉलपेपर सेट कर सकते हैं।",
      "difficulty": "easy",
      "hint": "डेस्कटॉप पर राइट क्लिक → Personalize भी कर सकते हैं।",
      "points": 10
    },
    {
      "question": "Windows में Lock Screen Background कैसे बदलें?",
      "options": ["Settings → Personalization → Lock screen", "Settings → Accounts", "Control Panel → Display", "Settings → System"],
      "answer": 3,
      "explanation": "Lock screen वह स्क्रीन होती है जो कंप्यूटर लॉक होने पर दिखती है। इसे Personalization → Lock screen से बदला जा सकता है।",
      "difficulty": "medium",
      "hint": "Windows + L दबाने पर जो स्क्रीन आती है, वह Lock screen है।",
      "points": 15
    },
    {
      "question": "Windows में Theme क्या होता है?",
      "options": ["Background, colors, sounds का पैकेज", "एक फॉन्ट", "एक स्क्रीनसेवर", "एक गेम"],
      "answer": 0,
      "explanation": "Theme आपके डेस्कटॉप बैकग्राउंड, विंडो कलर, साउंड्स और माउस कर्सर का एक कलेक्शन होता है।",
      "difficulty": "easy",
      "hint": "एक क्लिक में पूरा लुक बदल देता है।",
      "points": 10
    },
    {
      "question": "Windows में Dark Mode कैसे Enable करें?",
      "options": ["Settings → Personalization → Colors → Choose your default app mode → Dark", "Settings → System → Display → Dark Mode", "Control Panel → Appearance", "File Explorer → View"],
      "answer": 1,
      "explanation": "Personalization → Colors में 'Choose your default app mode' के लिए Dark select करें। Windows 11 में Personalization → Colors → Choose your mode → Dark।",
      "difficulty": "medium",
      "hint": "रात में आंखों पर कम जोर पड़ता है।",
      "points": 15
    },
    {
      "question": "Windows में Accent Color क्या होता है?",
      "options": ["Start menu, taskbar, windows borders का highlight color", "Desktop background", "Font color", "Icon color"],
      "answer": 2,
      "explanation": "Accent Color वह रंग होता है जो Start मेनू, टास्कबार, टाइटल बार और बटनों पर highlight के रूप में दिखता है।",
      "difficulty": "medium",
      "hint": "यह थीम का एक्सेंट रंग होता है।",
      "points": 15
    },
    {
      "question": "Windows में Screen Resolution कैसे बदलें?",
      "options": ["Settings → System → Display → Display resolution", "Settings → Personalization → Display", "Control Panel → Screen", "Right click → View"],
      "answer": 0,
      "explanation": "Settings → System → Display में जाकर 'Display resolution' के dropdown से resolution बदलें। जितना ज्यादा resolution, उतना clear लेकिन छोटा text।",
      "difficulty": "easy",
      "hint": "1920x1080 (Full HD) सबसे common है।",
      "points": 10
    },
    {
      "question": "Windows में Scale and Layout (डिस्प्ले स्केलिंग) क्या करता है?",
      "options": ["Text, apps, icons का size बढ़ाता/घटाता है", "Resolution बदलता है", "Wallpaper बदलता है", "Font बदलता है"],
      "answer": 1,
      "explanation": "Scale (जैसे 100%, 125%, 150%) text, apps और icons के साइज को बदलता है। High-resolution screens पर बिना स्केलिंग के सब कुछ बहुत छोटा दिखता है।",
      "difficulty": "medium",
      "hint": "बड़े मॉनिटर पर text बड़ा करने के लिए।",
      "points": 15
    },
    {
      "question": "Windows में Multiple Monitors कैसे सेट करें?",
      "options": ["Settings → System → Display → Multiple displays", "Settings → Personalization → Multiple displays", "Control Panel → Displays", "Right click desktop → Graphic properties"],
      "answer": 1,
      "explanation": "Settings → System → Display में 'Multiple displays' से आप 'Extend' (दोनों मॉनिटर अलग-अलग), 'Duplicate' (एक ही दिखे), या 'Second screen only' सेट कर सकते हैं।",
      "difficulty": "hard",
      "hint": "दूसरा मॉनिटर लगाकर काम करने की जगह double करें।",
      "points": 20
    },
    {
      "question": "Windows में Night Light (Blue Light Filter) क्या करता है?",
      "options": ["Blue light कम करता है जिससे आंखों को आराम", "स्क्रीन bright करता है", "कंट्रास्ट बढ़ाता है", "रंग उलट देता है"],
      "answer": 2,
      "explanation": "Night Light blue light की मात्रा कम कर देता है और screen को गर्म (yellowish) रंग में बदल देता है, जिससे रात में आंखों पर कम दबाव पड़ता है और नींद बेहतर आती है।",
      "difficulty": "medium",
      "hint": "सूर्यास्त के बाद ऑटो ऑन हो सकता है।",
      "points": 15
    },
    {
      "question": "Windows में Taskbar Position कैसे बदलें?",
      "options": ["Taskbar पर राइट क्लिक → Taskbar settings → Taskbar location on screen", "Settings → Personalization → Taskbar → Taskbar location on screen", "Control Panel → Taskbar", "Settings → System → Taskbar"],
      "answer": 1,
      "explanation": "Taskbar पर राइट क्लिक करें → Taskbar settings → Taskbar location on screen से Bottom, Left, Right या Top पर ले जा सकते हैं। (Windows 11 में थोड़ा limited है)",
      "difficulty": "easy",
      "hint": "पुराने Windows में Taskbar को किनारे ले जा सकते हैं।",
      "points": 10
    },
    {
      "question": "Windows 11 में Start Menu की Alignment कैसे बदलें?",
      "options": ["Settings → Personalization → Taskbar → Taskbar alignment → Left or Center", "Settings → System → Start Menu", "Control Panel → Taskbar", "Right click taskbar → Properties"],
      "answer": 3,
      "explanation": "Windows 11 में Start Menu (और Taskbar icons) बायें (Left) या सेंटर में सेट किए जा सकते हैं। Settings → Personalization → Taskbar → Taskbar alignment से।",
      "difficulty": "medium",
      "hint": "Windows 11 में डिफॉल्ट Center होता है।",
      "points": 15
    },
    {
      "question": "Windows में Taskbar Auto-hide कैसे करें?",
      "options": ["Settings → Personalization → Taskbar → Taskbar behaviors → Automatically hide the taskbar", "Right click taskbar → Properties → Auto-hide", "Control Panel → Taskbar", "Settings → System → Taskbar"],
      "answer": 0,
      "explanation": "Auto-hide ऑन करने पर Taskbar छिप जाता है और माउस नीचे ले जाने पर दिखता है। इससे स्क्रीन स्पेस बचती है।",
      "difficulty": "medium",
      "hint": "Movie देखते समय विंडोज की टास्कबार गायब रहेगी।",
      "points": 15
    },
    {
      "question": "Windows में Notification Center (Action Center) कैसे खोलें?",
      "options": ["Windows + A", "Windows + N", "Windows + C", "Windows + B"],
      "answer": 0,
      "explanation": "Windows + A से Action Center (Notifications + Quick Settings) खुलता है। Taskbar के दाहिने छोर पर date/time के पास के आइकन से भी खोल सकते हैं।",
      "difficulty": "easy",
      "hint": "A का मतलब Action Center।",
      "points": 10
    },
    {
      "question": "Windows में Focus Assist कैसे Enable करें?",
      "options": ["Settings → System → Focus Assist", "Settings → Personalization → Focus", "Action Center → Focus Assist button", "Settings → Gaming → Focus Mode"],
      "answer": 1,
      "explanation": "Focus Assist notifications को म्यूट कर देता है। Settings → System → Focus Assist से सेट करें। Action Center में भी इसका बटन होता है।",
      "difficulty": "medium",
      "hint": "प्रेजेंटेशन या गेम खेलते समय कोई डिस्टर्ब नहीं करेगा।",
      "points": 15
    },
    {
      "question": "Windows में Default Apps कैसे बदलें?",
      "options": ["Settings → Apps → Default Apps", "Settings → System → Default Apps", "Control Panel → Programs → Default Programs", "Right click on file → Open with → Choose another app → Always"],
      "answer": 2,
      "explanation": "Settings → Apps → Default Apps से आप ब्राउज़र, मीडिया प्लेयर, इमेज व्यूअर, PDF रीडर जैसे डिफॉल्ट ऐप बदल सकते हैं। One way: Right click on file → Open with → Choose another app → Always।",
      "difficulty": "medium",
      "hint": "Chrome को डिफॉल्ट ब्राउज़र बनाने के लिए।",
      "points": 15
    },
    {
      "question": "Windows में Notification Settings कहाँ मिलती हैं?",
      "options": ["Settings → System → Notifications", "Settings → Personalization → Notifications", "Settings → Privacy → Notifications", "Control Panel → Notifications"],
      "answer": 0,
      "explanation": "Settings → System → Notifications से आप सभी ऐप्स के नोटिफिकेशन को ऑन/ऑफ कर सकते हैं, 'Do not disturb' सेट कर सकते हैं, और priority नोटिफिकेशन तय कर सकते हैं।",
      "difficulty": "easy",
      "hint": "कौन सा ऐप आपको परेशान कर रहा है, यहाँ बंद करें।",
      "points": 10
    },
    {
      "question": "Windows में 'Do Not Disturb' कैसे चालू करें?",
      "options": ["Settings → System → Notifications → Do not disturb", "Action Center में Focus Assist या Do not disturb बटन", "Settings → Focus Assist", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "आप Settings या Action Center से Do Not Disturb (Windows 11) या Focus Assist (Windows 10) चालू कर सकते हैं। इससे सभी नोटिफिकेशन silent हो जाते हैं।",
      "difficulty": "medium",
      "hint": "जरूरी काम करते समय यह on करें।",
      "points": 15
    },
    {
      "question": "Windows में Power & Sleep Settings कहाँ हैं?",
      "options": ["Settings → System → Power & battery", "Settings → Personalization → Power", "Control Panel → Power Options", "Settings → System → Sleep"],
      "answer": 0,
      "explanation": "Settings → System → Power & battery से आप तय कर सकते हैं कि कितनी देर बाद स्क्रीन बंद हो या कंप्यूटर सो जाए, और बैटरी सेविंग सेटिंग्स।",
      "difficulty": "easy",
      "hint": "लैपटॉप में बैटरी बचाने के लिए जरूरी है।",
      "points": 10
    },
    {
      "question": "Windows में 'Additional Power Settings' (Old Control Panel) कैसे खोलें?",
      "options": ["Control Panel → Hardware and Sound → Power Options", "Settings → System → Power → Additional settings", "Run → powercfg.cpl", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "पुराना Power Options Control Panel से खुलता है जहाँ High Performance, Balanced, Power Saver जैसे प्लान्स हैं। powercfg.cpl run करके भी खोल सकते हैं।",
      "difficulty": "medium",
      "hint": "यहाँ से 'Choose what the power button does' भी सेट करें।",
      "points": 15
    },
    {
      "question": "Windows में Storage Sense क्या है?",
      "options": ["Auto cleanup temporary files और Recycle Bin", "Antivirus", "Disk defragmenter", "Backup tool"],
      "answer": 0,
      "explanation": "Storage Sense एक स्मार्ट टूल है जो स्वचालित रूप से temporary files, Recycle Bin और Downloads फ़ोल्डर से पुरानी फाइलें हटाता है।",
      "difficulty": "medium",
      "hint": "डिस्क फुल होने से बचाता है।",
      "points": 15
    },
    {
      "question": "Windows में Storage Sense कैसे Enable करें?",
      "options": ["Settings → System → Storage → Storage Sense", "Settings → System → Storage → Configure Storage Sense or run now", "Settings → Personalization → Storage Sense", "Control Panel → Storage Sense"],
      "answer": 0,
      "explanation": "Settings → System → Storage में Storage Sense को on करें और 'Configure Storage Sense or run now' में schedule तय करें।",
      "difficulty": "medium",
      "hint": "इसे हफ्ते में एक बार चलने के लिए सेट करें।",
      "points": 15
    },
    {
      "question": "Windows में 'Find my device' feature क्या करता है?",
      "options": ["खोए हुए laptop की location track करता है", "फाइलें ढूंढता है", "प्रिंटर ढूंढता है", "ब्लूटूथ डिवाइस ढूंढता है"],
      "answer": 0,
      "explanation": "Find my device Windows की वह feature है जो आपके laptop/tablet की approximate location को Microsoft account पर स्टोर करती है ताकि खोने पर आप उसे track कर सकें।",
      "difficulty": "hard",
      "hint": "लैपटॉप खो जाए तो login.microsoft.com पर देखें।",
      "points": 20
    },
    {
      "question": "Windows में 'Activity History' क्या है?",
      "options": ["आपकी गतिविधियों (जैसे docs, sites) का रिकॉर्ड", "Browser history", "File explorer history", "Search history"],
      "answer": 1,
      "explanation": "Activity History वह जानकारी है जो Windows आपके द्वारा खोली गई फाइलों, वेबसाइटों और ऐप्स को ट्रैक करती है। इसे Settings → Privacy → Activity history में मैनेज कर सकते हैं।",
      "difficulty": "hard",
      "hint": "Timeline feature के लिए इस्तेमाल होता था।",
      "points": 20
    },
    {
      "question": "Windows में 'Clipboard History' कैसे Enable करें?",
      "options": ["Settings → System → Clipboard → Clipboard history सेट करें", "Settings → Personalization → Clipboard", "Control Panel → Clipboard", "Settings → Privacy → Clipboard"],
      "answer": 0,
      "explanation": "Settings → System → Clipboard में 'Clipboard history' को on करें। फिर Windows + V दबाने पर आपके सारे कॉपी किए गए आइटम दिखेंगे।",
      "difficulty": "hard",
      "hint": "एक से ज्यादा चीज़ें कॉपी कर पाएंगे।",
      "points": 20
    },
    {
      "question": "Windows में 'Sync your settings' क्या करता है?",
      "options": ["आपकी theme, passwords, language preferences को Microsoft account से sync करता है", "फाइलें sync करता है", "OneDrive sync करता है", "Browser sync करता है"],
      "answer": 2,
      "explanation": "Sync your settings आपके Windows सेटिंग्स, थीम्स, पासवर्ड, भाषा को Microsoft account में save करता है ताकि दूसरे Windows PC पर login करने पर ये सब अपने-आप apply हो जाएँ।",
      "difficulty": "hard",
      "hint": "दूसरे कंप्यूटर पर भी अपनी settings मिलेंगी।",
      "points": 20
    },
    {
      "question": "Windows में 'Typing' settings से क्या कर सकते हैं?",
      "options": ["Autocorrect, spell check, keyboard settings", "Font बदलना", "रंग बदलना", "साउंड बदलना"],
      "answer": 1,
      "explanation": "Settings → Devices → Typing (Windows 10) या Settings → Time & Language → Typing (Windows 11) से autocorrect, capital letters, और spell checking की settings बदल सकते हैं।",
      "difficulty": "medium",
      "hint": "मोबाइल जैसा autocorrect लाने के लिए।",
      "points": 15
    },
    {
      "question": "Windows में 'Touch Keyboard' कैसे Enable करें?",
      "options": ["Taskbar पर राइट क्लिक → 'Show touch keyboard button'", "Settings → Devices → Typing → Touch keyboard", "Control Panel → Keyboard", "Settings → Personalization → Keyboard"],
      "answer": 0,
      "explanation": "Taskbar पर राइट क्लिक करें, 'Show touch keyboard button' select करें, फिर taskbar पर keyboard icon दिखेगा। उस पर click करके on-screen keyboard खोल सकते हैं।",
      "difficulty": "easy",
      "hint": "टच स्क्रीन पर या जब कीबोर्ड काम न करे तो उपयोगी।",
      "points": 10
    },
    {
      "question": "Windows में 'Mouse pointer speed' कैसे बदलें?",
      "options": ["Settings → Bluetooth & devices → Mouse → Mouse pointer speed", "Settings → Personalization → Mouse", "Control Panel → Mouse → Pointer Options", "Settings → System → Mouse"],
      "answer": 0,
      "explanation": "Settings → Bluetooth & devices → Mouse (Windows 11) में slider से speed बदलें। या Control Panel → Mouse → Pointer Options में भी बदल सकते हैं।",
      "difficulty": "easy",
      "hint": "धीमा कर्सर अच्छा नहीं लगता तो बढ़ाएँ।",
      "points": 10
    },
    {
      "question": "Windows में 'Additional Mouse Options' कहाँ हैं?",
      "options": ["Settings → Bluetooth & devices → Mouse → Additional mouse settings", "Control Panel → Mouse", "Settings → Personalization → Mouse → Additional", "उपरोक्त a और b दोनों"],
      "answer": 3,
      "explanation": "'Additional mouse settings' से पुराना Mouse Properties डायलॉग खुलता है जहाँ pointer scheme (cursor style), button configuration (left/right swap), wheel settings, और pointer precision जैसे ऑप्शन मिलते हैं।",
      "difficulty": "medium",
      "hint": "यहाँ से cursor style भी बदल सकते हैं।",
      "points": 15
    },
    {
      "question": "Windows में 'Sound Output Device' कैसे बदलें?",
      "options": ["Taskbar के speaker icon पर click → device select करें", "Settings → System → Sound → Choose where to play sound", "Control Panel → Sound", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "सबसे आसान: Taskbar पर speaker icon click करें और ऊपर current device पर click करके दूसरा select करें (स्पीकर, हेडफोन, HDMI)।",
      "difficulty": "easy",
      "hint": "हेडफोन लगाए और output वहीं चाहिए तो यहाँ बदलें।",
      "points": 10
    },
    {
      "question": "Windows में 'App volume and device preferences' क्या है?",
      "options": ["अलग-अलग apps के volume और output device set करना", "Microphone settings", "Speaker test", "Sound effects"],
      "answer": 1,
      "explanation": "Settings → System → Sound → Volume mixer → 'App volume and device preferences' (Windows 11) से आप हर चल रहे एप्लिकेशन का volume अलग से set कर सकते हैं और अलग output/input device दे सकते हैं।",
      "difficulty": "hard",
      "hint": "गाना स्पीकर पर, गेम की आवाज़ हेडफोन में।",
      "points": 20
    },
    {
      "question": "Windows में 'Date and Time' कैसे बदलें?",
      "options": ["Taskbar पर time पर right click → Adjust date/time", "Settings → Time & Language → Date & time", "Control Panel → Date and Time", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "आप taskbar के time पर right click करके 'Adjust date/time' जा सकते हैं, या Settings में जाकर। Automatic time zone और manual set करने का option होता है।",
      "difficulty": "easy",
      "hint": "गलत time दिखे तो यहाँ से ठीक करें।",
      "points": 10
    },
    {
      "question": "Windows में 'Region and Language' से क्या कर सकते हैं?",
      "options": ["Display language बदलना, keyboard layout बदलना, regional format बदलना", "Font बदलना", "Currencies बदलना", "Date format बदलना"],
      "answer": 1,
      "explanation": "Settings → Time & Language → Language & region से आप नई भाषा (जैसे हिंदी) add कर सकते हैं, keyboard layout (QWERTY, देवनागरी) बदल सकते हैं, और date/time format set कर सकते हैं।",
      "difficulty": "medium",
      "hint": "हिंदी में टाइप करने के लिए भाषा add करें।",
      "points": 15
    },
    {
      "question": "Windows में 'Hindi Language Pack' कैसे Install करें?",
      "options": ["Settings → Time & Language → Language & region → Add a language → Hindi select करें", "Settings → Personalization → Language", "Control Panel → Language", "Microsoft Store से Download करें"],
      "answer": 1,
      "explanation": "Language & region में 'Add a language' पर click करें, Hindi ढूंढें और install करें। फिर Hindi को 'Set as display language' भी कर सकते हैं।",
      "difficulty": "medium",
      "hint": "Hindi language pack आने से Windows की सारी menus हिंदी में हो जाती हैं।",
      "points": 15
    },
    {
      "question": "Windows में 'Default keyboard layout' कैसे बदलें?",
      "options": ["Settings → Time & Language → Typing → Advanced keyboard settings → Override for default input method", "Control Panel → Keyboard", "Settings → Devices → Typing", "Taskbar पर ENG पर click → Language preferences"],
      "answer": 0,
      "explanation": "Advanced keyboard settings में 'Override for default input method' से आप तय कर सकते हैं कि कंप्यूटर चालू होने पर कौन सा keyboard layout (जैसे US Keyboard या Hindi Phonetic) active रहे।",
      "difficulty": "hard",
      "hint": "हर बार keyboard change न करना पड़े।",
      "points": 20
    },
    {
      "question": "Windows में 'Speech Recognition' कैसे Enable करें?",
      "options": ["Settings → Accessibility → Speech → Start speech recognition", "Control Panel → Ease of Access → Speech Recognition", "Settings → Privacy → Speech", "Both A and B"],
      "answer": 3,
      "explanation": "Windows Speech Recognition आपको voice commands से computer control करने देता है। Settings → Accessibility → Speech (Windows 11) या Control Panel से enable करें। 'Hey Cortana' भी इसी से जुड़ा है।",
      "difficulty": "hard",
      "hint": "बोलकर files खोल सकते हैं।",
      "points": 20
    },
    {
      "question": "Windows में 'Dictation' कैसे शुरू करें?",
      "options": ["Windows + H", "Windows + D", "Windows + V", "Windows + C"],
      "answer": 0,
      "explanation": "Windows + H दबाने पर dictation toolbar खुलता है, जहाँ आप बोलकर text type कर सकते हैं। यह speech to text feature है।",
      "difficulty": "medium",
      "hint": "Typing न करना चाहते तो बोलिए।",
      "points": 15
    },
    {
      "question": "Windows में 'Ease of Access' (Accessibility) settings कहाँ हैं?",
      "options": ["Settings → Accessibility", "Control Panel → Ease of Access", "Windows + U से सीधे खुलता है", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Windows + U (Universal Access) shortcut Ease of Access खोलता है। यहाँ Magnifier, Narrator, High Contrast, Closed Captions, Color Filters, Keyboard settings मिलती हैं।",
      "difficulty": "medium",
      "hint": "विजुअल या हियरिंग impairment वालों के लिए।",
      "points": 15
    },
    {
      "question": "Windows में 'Magnifier' कैसे चालू करें?",
      "options": ["Windows + Plus (+)", "Windows + Minus (-)", "Windows + ESC (बंद करने के लिए)", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Magnifier screen के हिस्से को बड़ा करके दिखाता है। Windows + (+) से zoom in, Windows + (-) से zoom out, Windows + ESC से बंद। Ease of Access से भी on कर सकते हैं।",
      "difficulty": "medium",
      "hint": "बहुत छोटा text पढ़ने के लिए।",
      "points": 15
    },
    {
      "question": "Windows में 'Narrator' क्या है?",
      "options": ["Screen reader जो टेक्स्ट को बोलकर सुनाता है", "Voice assistant", "Dictation tool", "Speech recognition"],
      "answer": 0,
      "explanation": "Narrator एक built-in screen reader है जो आपके द्वारा की गई activities (टाइपिंग, मेनू selection, बटन press) को बोलकर सुनाता है। Visually impaired users के लिए।",
      "difficulty": "hard",
      "hint": "Narrator on करने के लिए Windows logo key + Enter।",
      "points": 20
    },
    {
      "question": "Windows में 'High Contrast Mode' क्या करता है?",
      "options": ["Black/white या high contrast colors में display करता है", "Screen bright करता है", "रंग उलट देता है", "Screen dim करता है"],
      "answer": 0,
      "explanation": "High Contrast theme कुछ users (low vision) के लिए देखना आसान बनाता है। Settings → Accessibility → High contrast से on करें।",
      "difficulty": "hard",
      "hint": "Black background पर white text।",
      "points": 20
    },
    {
      "question": "Windows में 'Color Filters' (Grayscale, Invert) कैसे Enable करें?",
      "options": ["Settings → Accessibility → Color filters", "Settings → Personalization → Colors → Color filters", "Control Panel → Display", "Settings → System → Display → Color filters"],
      "answer": 1,
      "explanation": "Color filters से आप grayscale, invert (negative), color blindness filters (deuteranopia, protanopia, tritanopia) on कर सकते हैं। स्क्रीन कम देखने वालों के लिए।",
      "difficulty": "hard",
      "hint": "स्क्रीन black & white में करने के लिए।",
      "points": 20
    },
    {
      "question": "Windows में 'Sticky Keys' क्या है?",
      "options": ["Modifier keys (Ctrl, Alt, Shift, Win) को locked रखता है, एक बार press करना काफी होता है", "Keys sticker लगाना", "Keyboard language change", "Typing speed बढ़ाना"],
      "answer": 0,
      "explanation": "Sticky Keys physical difficulty वाले users के लिए है। Ctrl+Alt+Del को Ctrl, फिर Alt, फिर Del एक-एक करके press करने देता है। Settings → Accessibility → Keyboard से on करें।",
      "difficulty": "hard",
      "hint": "एक हाथ से काम करने वालों के लिए।",
      "points": 20
    },
    {
      "question": "Windows में 'Filter Keys' क्या करता है?",
      "options": ["Repeated keys को ignore करता है (जब एक key बार-बार press हो)", "Keys को और sensitive बनाता है", "Keyboard backlight चालू करता है", "Keys को remap करता है"],
      "answer": 2,
      "explanation": "Filter Keys उन लोगों के लिए है जो एक key को लंबे समय तक या गलती से बार-बार दबाते हैं। यह repeat keys को ignore करता है।",
      "difficulty": "hard",
      "hint": "Tremors या slow reaction वालों के लिए।",
      "points": 20
    },
    {
      "question": "Windows में 'Toggle Keys' क्या करता है?",
      "options": ["Caps Lock, Num Lock, Scroll Lock press करने पर beep sound आता है", "Windows sound on/off करता है", "Keyboard lights on/off करता है", "Mute on/off करता है"],
      "answer": 1,
      "explanation": "Toggle Keys enable करने पर Caps Lock, Num Lock, Scroll Lock दबाने पर beep (high/low) आवाज़ आती है, जिससे पता चलता है कि ये toggles on या off हुईं।",
      "difficulty": "hard",
      "hint": "पता लगाने के लिए कि Caps Lock on है या off।",
      "points": 20
    },
    {
      "question": "Windows में 'Mouse Keys' क्या है?",
      "options": ["Numpad keys से mouse cursor को move करना", "Mouse buttons swap करना", "Mouse pointer speed बढ़ाना", "Mouse click sound बदलना"],
      "answer": 0,
      "explanation": "Mouse Keys आपको numeric keypad (8=up, 2=down, 4=left, 6=right, 5=click) से mouse चलाने देता है। जब mouse काम न करे तब उपयोगी।",
      "diffaulty": "hard",
      "hint": "Broke mouse के लिए backup plan।",
      "points": 20
    },
    {
      "question": "Windows में 'Text Cursor Indicator' क्या है?",
      "options": ["Text cursor (typing line) को thicker और color देता है जिससे देखना आसान हो", "Mouse pointer बदलता है", "Font बदलता है", "Cursor blink rate बदलता है"],
      "answer": 0,
      "explanation": "Low vision users के लिए Text Cursor Indicator से cursor को मोटा और उसके चारों ओर color ring add किया जा सकता है। Settings → Accessibility → Text cursor से।",
      "difficulty": "hard",
      "hint": "टाइप करते समय cursor कहाँ है यह आसानी से दिखेगा।",
      "points": 20
    },
    {
      "question": "Windows में 'Accounts' settings से क्या manage कर सकते हैं?",
      "options": ["Microsoft account से sign in, family, sign-in options (PIN, password, fingerprint)", "Desktop background", "Volume settings", "Network settings"],
      "answer": 0,
      "explanation": "Settings → Accounts से आप अपना Microsoft account जोड़ सकते हैं, Local account से switch कर सकते हैं, Sign-in options (PIN, Windows Hello, password, fingerprint, face) सेट कर सकते हैं।",
      "difficulty": "medium",
      "hint": "अपना PIN change करने के लिए यहाँ जाएँ।",
      "points": 15
    },
    {
      "question": "Windows में 'PIN' क्या है और password से कैसे अलग है?",
      "options": ["Device-specific numeric code (4-6 digits), Microsoft account से linked, local login के लिए", "Same as password", "PIN भूलने पर password लगता है", "Both A and C"],
      "answer": 3,
      "explanation": "PIN (Personal Identification Number) device-specific होता है, सिर्फ उसी PC पर काम करता है। Password से ज्यादा fast और convenient है। Settings → Accounts → Sign-in options → PIN से set करें।",
      "difficulty": "medium",
      "hint": "Password टाइप करने से PIN तेज़ है।",
      "points": 15
    },
    {
      "question": "Windows Hello क्या है?",
      "options": ["Biometric authentication (face, fingerprint, iris)", "Voice assistant", "Password manager", "Security software"],
      "answer": 0,
      "explanation": "Windows Hello आपको face recognition (IR camera) या fingerprint से बिना पासवर्ड टाइप किए Windows में sign-in करने देता है। Secure और fast।",
      "difficulty": "medium",
      "hint": "लैपटॉप खोला और face scan होते ही login हो गए।",
      "points": 15
    },
    {
      "question": "Windows Hello Face setup के लिए क्या चाहिए?",
      "options": ["Infrared (IR) camera", "Normal webcam", "Fingerprint scanner", "Microphone"],
      "answer": 0,
      "explanation": "Windows Hello Face के लिए specialized IR camera चाहिए (जो depth perceive कर सके)। Normal webcam से काम नहीं करता। लैपटॉप में 'Windows Hello compatible' लिखा होता है।",
      "difficulty": "hard",
      "hint": "अंधेरे में भी face scan कर सकता है।",
      "points": 20
    },
    {
      "question": "Windows में 'Dynamic Lock' क्या करता है?",
      "options": ["जब आपका Bluetooth phone (paired) दूर चला जाए तो PC lock हो जाता है", "Screen time lock", "Parental control", "Auto shutdown"],
      "answer": 0,
      "explanation": "Dynamic Lock आपके Bluetooth paired phone (Android/iPhone) का use करता है। जब phone range से बाहर चला जाता है (आप अपनी seat से उठ गए), तो PC अपने-आप lock हो जाता है।",
      "difficulty": "hard",
      "hint": "Security के लिए - जाते ही lock हो जाए।",
      "points": 20
    },
    {
      "question": "Windows में Sign-in Options में 'Picture Password' क्या है?",
      "options": ["किसी picture पर clicks और gestures से sign-in करना", "Password change करना", "PIN set करना", "Fingerprint set करना"],
      "answer": 0,
      "explanation": "Picture password में आप एक picture select करते हैं और उस पर 3 gestures (circle, line, tap) define करते हैं। सही sequence और location पर gestures करने पर login होता है।",
      "difficulty": "hard",
      "hint": "Password याद न हो, लेकिन picture पर पैटर्न याद हो।",
      "points": 20
    },
    {
      "question": "Windows में 'Family & other users' से क्या कर सकते हैं?",
      "options": ["बच्चों के लिए child account बनाना, screen time limit set करना, app restrictions", "नया local user बनाना", "Guest account बनाना", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Family & other users से आप Microsoft family groups में members add कर सकते हैं (child accounts के लिए parental controls - screen time, content restrictions, spending limits) और अन्य users (local or Microsoft) add कर सकते हैं।",
      "difficulty": "hard",
      "hint": "बच्चों के PC use को control करने के लिए।",
      "points": 20
    },
    {
      "question": "Windows में 'Assigned Access' (Kiosk Mode) क्या है?",
      "options": ["एक specific app को lockdown करना, user सिर्फ वही app use कर सकता है, बाकी सब block", "Admin access देना", "Guest access देना", "Remote access देना"],
      "answer": 0,
      "explanation": "Kiosk Mode (Assigned Access) में आप एक Standard user account को सिर्फ एक specific UWP app (जैसे Edge browser या Calculator) तक limit कर देते हैं। Public kiosks, school labs, digital signage के लिए।",
      "difficulty": "hard",
      "hint": "स्टूडेंट सिर्फ Calculator ही चला सके।",
      "points": 20
    },
    {
      "question": "Windows में 'Sync your settings' कैसे on करें?",
      "options": ["Settings → Accounts → Windows backup → Remember my preferences", "Settings → Accounts → Sync your settings (Windows 10)", "उपरोक्त A और B दोनों", "Settings → Personalization → Sync"],
      "answer": 2,
      "explanation": "Windows 10 में Settings → Accounts → Sync your settings से on करें। Windows 11 में Settings → Accounts → Windows backup → 'Remember my preferences' में toggles हैं।",
      "difficulty": "hard",
      "hint": "Theme, passwords, language preferences दूसरे PC पर auto apply होंगे।",
      "points": 20
    },
    {
      "question": "Windows में 'Optional Features' क्या हैं?",
      "options": ["वे features जो default install नहीं होते (जैसे .NET Framework, OpenSSH, Internet Explorer mode)", "Compulsory updates", "Drivers", "Games"],
      "answer": 0,
      "explanation": "Settings → Apps → Optional features से आप extra features add कर सकते हैं। उदाहरण: Windows Subsystem for Linux (WSL), .NET Framework 3.5, OpenSSH Client, RSAT tools, Windows Media Player Legacy।",
      "difficulty": "hard",
      "hint": "Devs और IT pros के लिए जरूरी features।",
      "points": 20
    },
    {
      "question": "Windows में 'Startup Apps' कैसे manage करें?",
      "options": ["Task Manager → Startup tab", "Settings → Apps → Startup", "Settings → System → Startup (Windows 11 में)", "उपरोक्त A और C"],
      "answer": 3,
      "explanation": "Windows 10 और 11 में Task Manager (Ctrl+Shift+Esc) के Startup टैब में जाकर apps को disable/enable कर सकते हैं। Windows 11 में Settings → Apps → Startup में भी।",
      "difficulty": "meduim",
      "hint": "ज्यादा startup apps कंप्यूटर slow बनाते हैं।",
      "points": 15
    },
    {
      "question": "Windows में 'Default location' सेट करने से क्या होता है?",
      "options": ["Apps (जैसे Weather, Maps) को approximate location मिलती है", "Internet speed बढ़ती है", "Time zone set होता है", "VPN चलता है"],
      "answer": 0,
      "explanation": "Settings → Privacy → Location में 'Default location' सेट करने से apps जैसे Weather, Maps, News को गलत location देने के बजाय सही मिलती है।",
      "difficulty": "hard",
      "hint": "Weather app अपने शहर का temperature दिखाएगा।",
      "points": 20
    },
    {
      "question": "Windows में 'Camera privacy settings' कहाँ हैं?",
      "options": ["Settings → Privacy & security → Camera", "Settings → Privacy → Camera", "Settings → System → Camera", "Control Panel → Camera"],
      "answer": 0,
      "explanation": "Settings → Privacy & security → Camera से आप तय कर सकते हैं कि किन apps को camera access मिले। 'Camera access' master toggle से सबकी access बंद भी कर सकते हैं।",
      "difficulty": "medium",
      "hint": "जब webcam use न कर रहे हों तो बंद रखें - security के लिए।",
      "points": 15
    },
    {
      "question": "Windows में 'Microphone privacy settings' कैसे पहुँचें?",
      "options": ["Settings → Privacy & security → Microphone", "Settings → Privacy → Microphone", "Settings → System → Sound → Microphone privacy", "उपरोक्त सभी (OS version पर निर्भर)"],
      "answer": 3,
      "explanation": "Windows 11 में Settings → Privacy & security → Microphone। यहाँ से आप control कर सकते हैं कि किन apps को mic access मिले। Untrusted apps को block करें।",
      "difficulty": "medium",
      "hint": "Apps को बिना permission mic on करने से रोकें।",
      "points": 15
    },
    {
      "question": "Windows में 'Advanced Startup Options' कैसे पहुँचें?",
      "options": ["Settings → System → Recovery → Advanced startup → Restart now", "Shift + Restart from Start menu", "Startup के दौरान F8 या F11 (पुराने Windows में)", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Advanced Startup Options (WinRE - Windows Recovery Environment) से आप Safe Mode, System Restore, Command Prompt, Startup Repair, UEFI Firmware Settings में जा सकते हैं।",
      "difficulty": "hard",
      "hint": "Windows boot न हो तो यहाँ से repair करें।",
      "points": 20
    },
    {
      "question": "Windows में 'Safe Mode' कैसे Boot करें?",
      "options": ["Shift + Restart → Troubleshoot → Advanced options → Startup Settings → Restart → 4 (Safe Mode) या 5 (Safe Mode with Networking)", "F8 बार-बार दबाएँ (पुराने Windows)", "Settings → System → Recovery → Advanced startup → Safe Mode", "उपरोक्त A और B"],
      "answer": 3,
      "explanation": "Safe Mode minimal drivers और services के साथ boot होता है। Troubleshooting के लिए (virus, driver issues, malware removal)। आजकल Shift + Restart से पहुँचते हैं।",
      "difficulty": "hard",
      "hint": "कंप्यूटर में problem आए तो Safe Mode में जाकर fix करें।",
      "points": 20
    },
    {
      "question": "Windows में 'System Restore Point' कैसे बनाएँ?",
      "options": ["Settings → System → About → System protection → Create", "Control Panel → System → System protection → Create", "Search 'Create a restore point'", "उपरोक्त B aur C"],
      "answer": 3,
      "explanation": "Restore Point आपके system files, settings, registry का snapshot है। System Restore से PC को पिछली good state में ले जा सकते हैं। Drivers install करने से पहले restore point बनाएँ।",
      "difficulty": "hard",
      "hint": "पहले सुरक्षा, फिर प्रयोग।",
      "points": 20
    },
    {
      "question": "Windows में 'System Restore' कैसे करें?",
      "options": ["Advanced Startup → Troubleshoot → Advanced options → System Restore", "Control Panel → System → System Protection → System Restore", "Settings → System → Recovery → System Restore (Windows 11)", "उपरोक्त सभी तरीकों से"],
      "answer": 3,
      "explanation": "System Restore आपके PC को बिना personal files delete किए पिछले Restore Point पर ले जाता है। Driver या software install करने के बाद problem आए तो use करें।",
      "difficulty": "hard",
      "hint": "Undo changes without losing documents।",
      "points": 20
    },
    {
      "question": "Windows में 'Reset this PC' के options क्या हैं?",
      "options": ["Keep my files (apps remove होंगे, personal files रहेंगी)", "Remove everything (सब कुछ clean)", "Cloud download या Local reinstall", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "'Reset this PC' में दो main options: Keep my files (Windows reinstall होगा, apps हटेंगी, personal files रहेंगी) और Remove everything (पूरा साफ)। Cloud download या Local reinstall भी चुन सकते हैं।",
      "difficulty": "hard",
      "hint": "बिना installation disk के PC fresh कर सकते हैं।",
      "points": 20
    },
    {
      "question": "Windows में 'Go back to previous version of Windows' कब काम आता है?",
      "options": ["Windows update के बाद 10 दिन के अंदर, अगर नया version problem करे तो पुराने पर लौटने के लिए", "Any time, unlimited", "सिर्फ 1 दिन के लिए", "बिना backup के काम नहीं करता"],
      "answer": 0,
      "explanation": "Windows 10/11 में major update के बाद 10 दिन तक 'Go back' option रहता है। इससे आप update से पहले की version में वापस जा सकते हैं। 10 दिन बाद option गायब हो जाता है।",
      "difficulty": "hard",
      "hint": "नया update stable न लगे तो वापस जाएँ।",
      "points": 20
    },
    {
      "question": "Windows में 'Windows Security' (Virus & threat protection) कैसे खोलें?",
      "options": ["Settings → Privacy & security → Windows Security", "Start menu → Windows Security search करें", "Taskbar shield icon पर click करें", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Windows Security (पहले Windows Defender) built-in antivirus और security suite है। यहाँ Virus & threat protection, Firewall, App & browser control, Device security, Family options हैं।",
      "difficulty": "medium",
      "hint": "Third-party antivirus न हो तो यह active रहता है।",
      "points": 15
    },
    {
      "question": "Windows Security में 'Quick scan' और 'Full scan' में क्या अंतर है?",
      "options": ["Quick scan - common locations scan करता है, Full scan - पूरी hard drive scan", "Quick scan - faster, Full scan - slower", "Quick scan सिर्फ memory scan करता है", "A और B दोनों"],
      "answer": 3,
      "explanation": "Quick scan जल्दी खतरे वाली जगहों (memory, startup, temp) को scan करता है, Full scan सारी files, folders, drives को - बहुत time लेता है। Custom scan से specific folder भी scan कर सकते हैं।",
      "difficulty": "medium",
      "hint": "रोज Quick scan, सप्ताह में एक बार Full scan।",
      "points": 15
    },
    {
      "question": "Windows Security में 'Controlled folder access' क्या करता है?",
      "options": ["Ransomware से documents, pictures folders protect करता है - only trusted apps को access देता है", "Folder hide करता है", "Folder encrypt करता है", "Folder compress करता है"],
      "answer": 0,
      "explanation": "Controlled folder access एक ransomware protection feature है। इसमें आप protected folders (जैसे Documents, Pictures, Desktop) list करते हैं और सिर्फ trusted apps को ही उनमें changes करने देते हैं।",
      "difficulty": "hard",
      "hint": "Ransomware से बचने का strongest तरीका।",
      "points": 20
    },
    {
      "question": "Windows Security में 'Firewall & network protection' कहाँ से set करें?",
      "options": ["Windows Security → Firewall & network protection", "Control Panel → Windows Defender Firewall", "Settings → Privacy & security → Windows Security → Firewall", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Firewall incoming और outgoing traffic को नियंत्रित करता है। यहाँ Domain network, Private network, Public network के लिए अलग-अलग firewall toggles हैं। 'Allow an app through firewall' भी यहीं से।",
      "difficulty": "hard",
      "hint": "किसी app को internet से block करना हो तो यहाँ से।",
      "points": 20
    },
    {
      "question": "Windows Security में 'App & browser control' क्या सेट करता है?",
      "options": ["SmartScreen filter for Edge browser, Microsoft Store apps, and downloaded files", "Parental control", "Antivirus settings", "Firewall settings"],
      "answer": 0,
      "explanation": "App & browser control Microsoft Defender SmartScreen को manage करता है। यह malicious websites, downloads, और apps को block करता है। Reputation-based protection।",
      "difficulty": "hard",
      "hint": "Phishing और malware से बचाता है।",
      "points": 20
    },
    {
      "question": "Windows Security में 'Device security' क्या दिखाता है?",
      "options": ["Core isolation (Memory integrity), Secure Boot, TPM (Trusted Platform Module), Data Encryption", "Antivirus version", "Firewall status", "App permissions"],
      "answer": 0,
      "explanation": "Device security hardware-based security features दिखाता है। Core isolation (Virtualization-based security) process को kernel से isolate करता है। Secure Boot boot-time malware से बचाता है। TPM encryption keys store करता है।",
      "difficulty": "hard",
      "hint": "बहुत advanced security settings।",
      "points": 20
    },
    {
      "question": "TPM (Trusted Platform Module) क्या है?",
      "options": ["Hardware chip that stores encryption keys, passwords, certificates securely", "Antivirus software", "Firewall", "Windows feature"],
      "answer": 0,
      "explanation": "TPM एक physical chip (मदरबोर्ड पर) है जो सुरक्षा संबंधी sensitive data (BitLocker key, Windows Hello biometrics) को हार्डवेयर लेवल पर store करता है। Windows 11 के लिए TPM 2.0 mandatory है।",
      "difficulty": "hard",
      "hint": "यह chip सुरक्षित तिजोरी की तरह काम करता है।",
      "points": 20
    },
    {
      "question": "Windows 11 installation के लिए TPM कौन सा संस्करण चाहिए?",
      "options": ["TPM 2.0", "TPM 1.2", "No TPM needed", "TPM 3.0"],
      "answer": 0,
      "explanation": "Windows 11 के लिए TPM 2.0 mandatory है। अगर आपके PC में TPM 2.0 नहीं है तो Windows 11 install नहीं कर सकते (या unsupported तरीके से करना पड़ता है, जो recommend नहीं)।",
      "difficulty": "medium",
      "hint": "PC Health Check app से check करें।",
      "points": 15
    },
    {
      "question": "Windows में 'BitLocker Drive Encryption' क्या करता है?",
      "options": ["पूरी drive को encrypt करता है - बिना key/password के कोई data access नहीं कर सकता", "Drive को compress करता है", "Drive को backup करता है", "Drive को format करता है"],
      "answer": 0,
      "explanation": "BitLocker full-disk encryption feature है (केवल Windows Pro, Enterprise editions में)। पूरी drive (OS drive या other drives) encrypt हो जाती है। लैपटॉप खो जाने पर कोई data नहीं पढ़ सकता।",
      "difficulty": "hard",
      "hint": "Data theft से बचने का best तरीका।",
      "points": 20
    },
    {
      "question": "Windows में 'Device Encryption' (BitLocker का simple version) किन PCs पर होता है?",
      "options": ["Modern devices जो Modern Standby support करते हैं और Windows की version Home हो तो भी", "सिर्फ Pro में", "किसी में नहीं", "सिर्फ ARM PCs में"],
      "answer": 0,
      "explanation": "डिवाइस एन्क्रिप्शन (BitLocker Device Encryption) कुछ modern PCs (जिनमें TPM है और Modern Standby है) पर Windows Home edition में भी automatically on हो जाता है। Settings → Privacy & security → Device encryption से देखें।",
      "difficulty": "hard",
      "hint": "Microsoft account से linked recovery key Microsoft cloud पर store होती है।",
      "points": 20
    },
    {
      "question": "Windows में 'Find My Device' कैसे Turn On करें?",
      "options": ["Settings → Privacy & security → Find my device", "Settings → Update & Security → Find my device", "Settings → Accounts → Find my device", "Settings → System → Find my device"],
      "answer": 0,
      "explanation": "Windows 11 में Settings → Privacy & security → Find my device से on करें। यह location regularly Microsoft account पर save करता है। Laptop खोने पर login.microsoft.com पर देख सकते हैं।",
      "difficulty": "hard",
      "hint": "खोने से पहले on करना जरूरी है।",
      "points": 20
    },
    {
      "question": "Windows में 'Delivery Optimization' क्या है?",
      "options": ["Windows updates को local network या internet से peering करना", "Network speed बढ़ाना", "गेम optimize करना", "Browser cache"],
      "answer": 0,
      "explanation": "Delivery Optimization updates और Microsoft Store apps को P2P (peer to peer) तरीके से download करता है। यानी अन्य PCs से (local network या internet) updates ले सकते हैं। Settings → Windows Update → Advanced options → Delivery Optimization।",
      "difficulty": "hard",
      "hint": "Internet खर्च कम करने के लिए Off कर सकते हैं।",
      "points": 20
    },
    {
      "question": "Windows में 'Remote Desktop' कैसे enable करें?",
      "options": ["Settings → System → Remote Desktop → On करें", "Settings → Remote Desktop", "Control Panel → System → Remote Settings", "उपरोक्त A और C"],
      "answer": 3,
      "explanation": "Remote Desktop enable करने के लिए Settings → System → Remote Desktop पर जाएँ (केवल Pro, Enterprise editions में)। इससे दूसरे device से इस PC को remotely control कर सकते हैं। User को password set करना जरूरी है।",
      "difficulty": "hard",
      "hint": "Office से घर के PC को control करने के लिए।",
      "points": 20
    },
    {
      "question": "Windows में 'Clipboard' settings से क्या manage करते हैं?",
      "options": ["Clipboard history (Windows+V), sync across devices, clear clipboard data", "Copy करना", "Paste करना", "Cut करना"],
      "answer": 0,
      "explanation": "Settings → System → Clipboard से आप Clipboard history on/off कर सकते हैं, cross-device sync (Microsoft account से) कर सकते हैं, और 'Clear clipboard data' कर सकते हैं।",
      "difficulty": "medium",
      "hint": "ज्यादा copy/paste के लिए useful।",
      "points": 15
    },
    {
      "question": "Windows में 'Keyboard shortcuts' कहाँ देख सकते हैं?",
      "options": ["Settings → Accessibility → Keyboard → On-screen keyboard shortcuts", "Microsoft website पर list", "Taskbar shortcuts", "Start menu shortcuts"],
      "answer": 0,
      "explanation": "Windows के built-in सभी shortcut keys (Windows, Ctrl, Alt combinations) के लिए Microsoft documentation है। Settings → Accessibility → Keyboard में कुछ common shortcuts mention हैं।",
      "difficulty": "medium",
      "hint": "काम तेज़ करने के लिए shortcuts सीखो।",
      "points": 15
    },
    {
      "question": "Windows में 'Multitasking settings' (Snap windows, Virtual desktops) कहाँ हैं?",
      "options": ["Settings → System → Multitasking", "Settings → Personalization → Multitasking", "Settings → Display → Multitasking", "Task View settings"],
      "answer": 0,
      "explanation": "Settings → System → Multitasking से Snap windows on/off कर सकते हैं, Snap assist यह बताता है कि window को edge पर drag करने पर कौनसे layouts show हों। Virtual desktop settings भी यहीं।",
      "difficulty": "medium",
      "hint": "Window split करने की habit हो तो on रखें।",
      "points": 15
    },
    {
      "question": "Windows 11 में 'Snap Layouts' कैसे use करें?",
      "options": ["Window के maximize button पर hover करें या Windows + Z दबाएँ", "Windows + दायाँ arrow", "Shift + दायाँ arrow", "Ctrl + दायाँ arrow"],
      "answer": 0,
      "explanation": "Windows 11 में Snap Layouts हैं - आप window को स्क्रीन के अलग-अलग layout (2, 3, 4 windows) में arrange कर सकते हैं। Maximize button पर hover करें या Windows + Z दबाएँ और layout select करें।",
      "difficulty": "medium",
      "hint": "बिना बार-बार size change किए मल्टीटास्किंग करें।",
      "points": 15
    },
    {
      "question": "Windows में 'Virtual Desktop' कैसे बनाएँ?",
      "options": ["Task View (Windows + Tab) → New Desktop", "Alt + Tab → New Desktop", "Ctrl + Windows + D", "A और C दोनों"],
      "answer": 3,
      "explanation": "Virtual Desktop बनाने के दो shortcuts: Task View में New Desktop बटन पर click करें या Ctrl + Windows + D दबाएँ। Ctrl + Windows + left/right arrow से desktops के बीच switch करें। Ctrl + Windows + F4 से current desktop close करें।",
      "difficulty": "hard",
      "hint": "काम और मनोरंजन अलग desktops पर।",
      "points": 20
    }
  ],
    "4. File and Folder Management": [
    {
      "question": "फ़ाइल क्या होती है?",
      "options": ["Data का एक collection जो storage में save होती है", "एक folder", "एक program", "एक shortcut"],
      "answer": 2,
      "explanation": "फ़ाइल डेटा का एक संग्रह होती है जो स्टोरेज (हार्ड डिस्क, SSD, पेन ड्राइव) में सेव रहती है। जैसे text file, image, video, music, program।",
      "difficulty": "easy",
      "hint": "जिसका अपना नाम और extension होता है।",
      "points": 10
    },
    {
      "question": "फ़ोल्डर क्या होता है?",
      "options": ["Files को organise करने का container", "एक type की file", "एक program", "एक drive"],
      "answer": 1,
      "explanation": "फ़ोल्डर (Directory) एक कंटेनर होता है जिसमें आप फाइलें और अन्य फ़ोल्डर्स रख सकते हैं। इससे फाइलों को व्यवस्थित रखना आसान होता है।",
      "difficulty": "easy",
      "hint": "फाइलों को रखने की डिजिटल अलमारी।",
      "points": 10
    },
    {
      "question": "Root Directory क्या होती है?",
      "options": ["Drive की सबसे ऊपर वाली directory (जैसे C:\\)", "एक sub-folder", "Desktop folder", "Documents folder"],
      "answer": 2,
      "explanation": "Root Directory किसी भी ड्राइव (C:, D:, E:) की मुख्य या सबसे ऊपर वाली डायरेक्टरी होती है। उदाहरण: C:\\",
      "difficulty": "medium",
      "hint": "ड्राइव खोलने पर जो सबसे पहले दिखता है।",
      "points": 15
    },
    {
      "question": "File Extension क्या होती है?",
      "options": ["Filename के बाद डॉट के बाद का भाग (जैसे .txt, .jpg)", "File का नाम", "File size", "File का type नहीं बताता"],
      "answer": 3,
      "explanation": "File Extension फ़ाइल नाम के अंत में डॉट (.) के बाद आने वाला भाग होता है (जैसे document.pdf में .pdf)। यह बताता है कि फ़ाइल किस type की है।",
      "difficulty": "easy",
      "hint": ".exe, .docx, .mp3 ये सब extensions हैं।",
      "points": 10
    },
    {
      "question": ".txt extension वाली फ़ाइल किस प्रकार की होती है?",
      "options": ["Plain text file", "Image file", "Video file", "Audio file"],
      "answer": 1,
      "explanation": ".txt extension plain text फ़ाइलों के लिए होती है। इसे Notepad जैसे किसी भी text editor से खोला जा सकता है।",
      "difficulty": "easy",
      "hint": "Notepad से खुलने वाली फ़ाइल।",
      "points": 10
    },
    {
      "question": ".jpg / .jpeg extension किस प्रकार की फ़ाइल के लिए है?",
      "options": ["Image file", "Document file", "Video file", "Audio file"],
      "answer": 0,
      "explanation": ".jpg या .jpeg image फ़ाइलों (फोटो) के लिए standard extension है। यह compressed image format है।",
      "difficulty": "easy",
      "hint": "कैमरा और फोन की फोटो का format।",
      "points": 10
    },
    {
      "question": ".exe extension वाली फ़ाइल क्या होती है?",
      "options": ["Executable file (program)", "Excel file", "Text file", "Image file"],
      "answer": 2,
      "explanation": ".exe (executable) फ़ाइल एक प्रोग्राम होती है जिसे डबल-क्लिक करके चलाया जा सकता है। जैसे setup.exe, chrome.exe।",
      "difficulty": "easy",
      "hint": "जिस पर click करने से program चलता है।",
      "points": 10
    },
    {
      "question": "Windows में File Explorer कैसे खोलें?",
      "options": ["Windows + E", "Windows + F", "Windows + R", "Windows + D"],
      "answer": 2,
      "explanation": "Windows + E सीधे File Explorer (This PC) खोलता है। यह फाइल और फ़ोल्डर मैनेज करने का मुख्य टूल है।",
      "difficulty": "easy",
      "hint": "E का मतलब Explorer।",
      "points": 10
    },
    {
      "question": "File Explorer में 'This PC' क्या दिखाता है?",
      "options": ["सभी drives (C:, D:, E:), Downloads, Documents, Desktop folders", "सिर्फ C: drive", "Network locations", "Recycle Bin"],
      "answer": 0,
      "explanation": "This PC में आपकी सभी drives (C:, D:, E:), साथ ही Quick Access के कुछ फ़ोल्डर्स (Downloads, Documents, Desktop, Music, Pictures, Videos) दिखते हैं।",
      "difficulty": "easy",
      "hint": "मेरा कंप्यूटर का नया नाम।",
      "points": 10
    },
    {
      "question": "नई फ़ोल्डर बनाने का shortcut key क्या है?",
      "options": ["Ctrl + Shift + N", "Ctrl + N", "Ctrl + F", "Ctrl + Alt + N"],
      "answer": 0,
      "explanation": "File Explorer में Ctrl + Shift + N दबाने से तुरंत नया फ़ोल्डर बन जाता है। Right click → New → Folder से भी बना सकते हैं।",
      "difficulty": "medium",
      "hint": "N का मतलब New Folder।",
      "points": 15
    },
    {
      "question": "किसी फ़ाइल या फ़ोल्डर को Copy करने का shortcut key क्या है?",
      "options": ["Ctrl + C", "Ctrl + X", "Ctrl + V", "Ctrl + D"],
      "answer": 1,
      "explanation": "Ctrl + C फ़ाइल/फ़ोल्डर को कॉपी करता है (क्लिपबोर्ड में)। Ctrl + V से paste करते हैं।",
      "difficulty": "easy",
      "hint": "C = Copy।",
      "points": 10
    },
    {
      "question": "किसी फ़ाइल या फ़ोल्डर को Cut (Move) करने का shortcut key क्या है?",
      "options": ["Ctrl + X", "Ctrl + C", "Ctrl + V", "Ctrl + Z"],
      "answer": 0,
      "explanation": "Ctrl + X फ़ाइल को cut करता है (मूल जगह से हटाता है और clipboard में रखता है)। फिर Ctrl + V नई जगह paste करने पर move हो जाती है।",
      "difficulty": "easy",
      "hint": "X कैंची की तरह।",
      "points": 10
    },
    {
      "question": "Copy या Cut की गई फ़ाइल को Paste करने का shortcut key क्या है?",
      "options": ["Ctrl + V", "Ctrl + P", "Ctrl + C", "Ctrl + X"],
      "answer": 0,
      "explanation": "Ctrl + V clipboard से फ़ाइल/फ़ोल्डर को current location पर paste करता है।",
      "difficulty": "easy",
      "hint": "V = insert की तरह।",
      "points": 10
    },
    {
      "question": "किसी फ़ाइल को Delete करने का shortcut key क्या है?",
      "options": ["Delete", "Ctrl + D", "Shift + Delete", "Backspace"],
      "answer": 0,
      "explanation": "Delete key (या Ctrl + D) फ़ाइल को Recycle Bin में भेजता है। Shift + Delete सीधे permanently delete करता है (Recycle Bin को bypass करके)।",
      "difficulty": "easy",
      "hint": "कीबोर्ड पर Del button।",
      "points": 10
    },
    {
      "question": "Recycle Bin क्या होता है?",
      "options": ["Deleted files को temporarily store करता है", "Permanently delete करता है", "Files को compress करता है", "Files को encrypt करता है"],
      "answer": 2,
      "explanation": "Recycle Bin एक temporary storage है जहाँ Delete की गई फ़ाइलें जाती हैं। यहाँ से आप files को restore (वापस ला) भी सकते हैं। Recycle Bin खाली करने पर files permanently delete हो जाती हैं।",
      "difficulty": "easy",
      "hint": "कूड़ेदान का icon।",
      "points": 10
    },
    {
      "question": "Recycle Bin को खाली (Empty) करने का क्या मतलब है?",
      "options": ["Deleted files permanently delete हो जाती हैं", "Files restore हो जाती हैं", "Files compress हो जाती हैं", "Files move हो जाती हैं"],
      "answer": 0,
      "explanation": "Recycle Bin empty करने से उसमें पड़ी सभी फ़ाइलें permanently delete हो जाती हैं और hard disk space free होता है। इसके बाद वे files restore नहीं हो सकतीं (बिना special recovery tool के)।",
      "difficulty": "easy",
      "hint": "स्थायी रूप से हटाना।",
      "points": 10
    },
    {
      "question": "Shift + Delete का क्या प्रभाव होता है?",
      "options": ["File permanently delete होती है (Recycle Bin नहीं जाती)", "File Recycle Bin में जाती है", "File copy होती है", "File cut होती है"],
      "answer": 0,
      "explanation": "Shift + Delete फ़ाइल को बिना Recycle Bin भेजे permanently delete कर देता है। इसलिए सावधानी से use करें।",
      "difficulty": "medium",
      "hint": "Delete से पहले सोचो, फिर Shift+Delete।",
      "points": 15
    },
    {
      "question": "फ़ाइल या फ़ोल्डर का नाम बदलने (Rename) का shortcut key क्या है?",
      "options": ["F2", "Ctrl + R", "Alt + R", "Shift + F2"],
      "answer": 0,
      "explanation": "F2 key दबाने से selected file/folder rename mode में आ जाता है। नया नाम टाइप करें और Enter दबाएँ।",
      "difficulty": "easy",
      "hint": "F2 = Rename का standard key।",
      "points": 10
    },
    {
      "question": "एक से अधिक फ़ाइलों को select करने के लिए किस key का उपयोग करें?",
      "options": ["Ctrl key (individual select)", "Shift key (range select)", "Ctrl + A (all select)", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Ctrl + click से अलग-अलग files select करें, Shift + click से पहले और आखिरी के बीच की सभी files select करें, Ctrl + A से सब select करें।",
      "difficulty": "medium",
      "hint": "विभिन्न selection methods।",
      "points": 15
    },
    {
      "question": "सभी फ़ाइलों को एक साथ select करने का shortcut key क्या है?",
      "options": ["Ctrl + A", "Ctrl + C", "Ctrl + X", "Ctrl + V"],
      "answer": 0,
      "explanation": "Ctrl + A (Select All) current folder की सभी files और folders को select कर लेता है।",
      "difficulty": "easy",
      "hint": "A = All।",
      "points": 10
    },
    {
      "question": "किसी फ़ाइल को खोलने के लिए क्या करें?",
      "options": ["Double-click", "Right click → Open", "Select करके Enter दबाएँ", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "फ़ाइल खोलने के कई तरीके हैं: डबल-क्लिक करें, राइट क्लिक करके Open चुनें, या file select करके Enter दबाएँ।",
      "difficulty": "easy",
      "hint": "सबसे common है double-click।",
      "points": 10
    },
    {
      "question": "किसी फ़ाइल पर Right Click करने पर क्या मिलता है?",
      "options": ["Context menu (Open, Copy, Cut, Delete, Rename, Properties)", "File खुल जाती है", "File delete हो जाती है", "File move हो जाती है"],
      "answer": 0,
      "explanation": "Right click से context menu खुलता है जिसमें सारे file operations (Open, Edit, Copy, Cut, Delete, Rename, Properties, Send to, Share) होते हैं।",
      "difficulty": "easy",
      "hint": "सब कुछ यहाँ मिलेगा।",
      "points": 10
    },
    {
      "question": "File या Folder की Properties कैसे देखें?",
      "options": ["Right click → Properties", "Alt + Enter", "Select file और Alt + Enter", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "File/folder पर right click करके Properties चुनें, या file select करके Alt + Enter दबाएँ। Properties में आप size, location, created/modified date, attributes (read-only, hidden) देख/बदल सकते हैं।",
      "difficulty": "medium",
      "hint": "Alt + Enter shortcut याद रखें।",
      "points": 15
    },
    {
      "question": "Hidden Files क्या होती हैं?",
      "options": ["वे files जो normal view में नहीं दिखतीं", "Deleted files", "Password protected files", "Encrypted files"],
      "answer": 0,
      "explanation": "Hidden files वे होती हैं जिनका 'Hidden' attribute on होता है। ये File Explorer में default रूप से नहीं दिखतीं। View → Show → Hidden items से दिखा सकते हैं।",
      "difficulty": "medium",
      "hint": "System files अक्सर hidden होती हैं।",
      "points": 15
    },
    {
      "question": "Read-only attribute क्या करता है?",
      "options": ["File को modify होने से protect करता है", "File को hide करता है", "File को delete होने से रोकता है", "File को compress करता है"],
      "answer": 0,
      "explanation": "Read-only attribute on होने पर file को edit (modify) नहीं किया जा सकता। Delete कर सकते हैं लेकिन save नहीं कर सकते। Properties → General → Read-only।",
      "difficulty": "hard",
      "hint": "सिर्फ पढ़ सकते हैं, लिख नहीं सकते।",
      "points": 20
    },
    {
      "question": ".tmp file क्या होती है?",
      "options": ["Temporary file (आमतौर पर delete की जा सकती है)", "System file", "Image file", "Video file"],
      "answer": 0,
      "explanation": ".tmp (temporary) files programs द्वारा अस्थायी डेटा store करने के लिए बनाई जाती हैं। Program बंद होने पर ये auto delete हो जानी चाहिए, लेकिन कभी-कभी रह जाती हैं - Disk Cleanup से साफ कर सकते हैं।",
      "difficulty": "medium",
      "hint": "ज्यादा जमा हो जाएँ तो delete कर दें।",
      "points": 15
    },
    {
      "question": "File को Search करने के लिए File Explorer में क्या use करते हैं?",
      "options": ["Search Box (top right corner)", "Ctrl + F", "F3", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "File Explorer के ऊपर दाहिने तरफ search box है। वहाँ टाइप करें। Ctrl + F या F3 भी search box में focus कर देता है।",
      "difficulty": "easy",
      "hint": "Magnifying glass icon।",
      "points": 10
    },
    {
      "question": "File Explorer में 'Quick Access' क्या है?",
      "options": ["Frequently used folders और recently accessed files की list", "C: drive", "Recycle Bin", "Network locations"],
      "answer": 0,
      "explanation": "Quick Access में आपके बार-बार उपयोग होने वाले फ़ोल्डर्स pin किए जा सकते हैं। साथ ही हाल ही में खोली गई फ़ाइलें भी यहाँ दिखती हैं।",
      "difficulty": "easy",
      "hint": "जल्दी पहुँचने के लिए।",
      "points": 10
    },
    {
      "question": "किसी फ़ोल्डर को Quick Access में Pin कैसे करें?",
      "options": ["Folder पर right click → Pin to Quick Access", "Folder को Quick Access में drag करें", "Folder properties में pin option", "A और B दोनों"],
      "answer": 3,
      "explanation": "फ़ोल्डर पर right click करें और 'Pin to Quick Access' चुनें। या फ़ोल्डर को सीधे Quick Access section में drag and drop करें।",
      "difficulty": "medium",
      "hint": "अपने favourite folders को top पर रखें।",
      "points": 15
    },
    {
      "question": "File को Compress (Zip) करने का क्या फायदा है?",
      "options": ["File size कम हो जाता है, multiple files एक साथ share कर सकते हैं", "File secure हो जाती है", "File delete हो जाती है", "File move हो जाती है"],
      "answer": 0,
      "explanation": "Compress (Zip) करने से file का size कम हो जाता है (save space) और कई files को एक .zip file में pack करके आसानी से share किया जा सकता है।",
      "difficulty": "medium",
      "hint": "Email भेजने से पहले zip करें।",
      "points": 15
    },
    {
      "question": "Zip file को Extract (unzip) कैसे करें?",
      "options": ["Right click → Extract All", "Double click zip file then Extract", "File Explorer → Compressed Folder Tools → Extract", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Zip file पर right click → Extract All से सभी files निकल जाती हैं। या zip file को double click करें, फिर ऊपर Extract all बटन से।",
      "difficulty": "easy",
      "hint": "Zip का उल्टा।",
      "points": 10
    },
    {
      "question": "File or Folder को Shortcut कैसे बनाएँ?",
      "options": ["Right click → Create shortcut", "Alt + drag file to new location", "Right click → Send to → Desktop (create shortcut)", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Shortcut एक link होता है (small arrow icon)। Original file को delete करने पर shortcut काम नहीं करता। Method: Right click → Create shortcut, या file को Alt + drag करें, या Send to → Desktop (create shortcut)।",
      "difficulty": "medium",
      "hint": "बिना original को move किए quick access।",
      "points": 15
    },
    {
      "question": "Shortcut file का extension क्या होता है?",
      "options": [".lnk", ".sh", ".shortcut", ".exe"],
      "answer": 0,
      "explanation": "Windows shortcuts का file extension .lnk होता है। यह original file/folder का path store करता है।",
      "difficulty": "hard",
      "hint": "Link का short form।",
      "points": 20
    },
    {
      "question": "Folder Options में 'Show hidden files' कैसे enable करें?",
      "options": ["File Explorer → View → Show → Hidden items", "File Explorer → View → Options → View tab → Show hidden files", "Control Panel → Folder Options", "उपरोक्त A और B दोनों"],
      "answer": 3,
      "explanation": "File Explorer में View टैब में 'Hidden items' checkbox है (Windows 10/11)। या View → Options → View tab में 'Show hidden files, folders, and drives' select करें।",
      "difficulty": "easy",
      "hint": "Hidden files अब दिखने लगेंगी।",
      "points": 10
    },
    {
      "question": "Folder Options में 'File name extensions' कैसे show करें?",
      "options": ["File Explorer → View → Show → File name extensions", "File Explorer → Options → View → uncheck 'Hide extensions for known file types'", "उपरोक्त A या B", "Alt + V + E"],
      "answer": 2,
      "explanation": "File Explorer के View टैब में 'File name extensions' checkbox है। इसे on करने पर सभी फ़ाइलों के extensions (जैसे .txt, .jpg) दिखने लगेंगे।",
      "difficulty": "easy",
      "hint": "असली filename पता चलेगा।",
      "points": 10
    },
    {
      "question": "File को ड्रैग करते समय Ctrl key दबाने से क्या होता है?",
      "options": ["Copy होती है (same drive में भी)", "Move होती है", "Shortcut बनती है", "Delete होती है"],
      "answer": 0,
      "explanation": "Same drive में drag करना default move होता है। Ctrl + drag करने से copy होती है। (Different drive में drag default copy होता है, Ctrl+ drag move करता है)",
      "difficulty": "hard",
      "hint": "Ctrl = Copy।",
      "points": 20
    },
    {
      "question": "File को ड्रैग करते समय Alt key दबाने से क्या होता है?",
      "options": ["Shortcut बनती है", "Copy होती है", "Move होती है", "Delete होती है"],
      "answer": 0,
      "explanation": "Alt + drag करने से file/folder का shortcut बन जाता है destination पर।",
      "difficulty": "hard",
      "hint": "Alt = अल्टरनेट (shortcut)।",
      "points": 20
    },
    {
      "question": "File को ड्रैग करते समय Shift key दबाने से क्या होता है?",
      "options": ["Move होती है (same drive में default copy को move में बदलता है)", "Copy होती है", "Shortcut बनती है", "Delete होती है"],
      "answer": 0,
      "explanation": "Different drive में drag default copy होता है। Shift + drag करने पर move होती है। Same drive में Shift + drag default move ही है।",
      "difficulty": "hard",
      "hint": "Shift = Move (जबरदस्ती)।",
      "points": 20
    },
    {
      "question": "File Explorer में 'Group by' feature क्या करता है?",
      "options": ["Files को type, date, size आदि के आधार पर group करता है", "Files को sort करता है", "Files को filter करता है", "Files को search करता है"],
      "answer": 0,
      "explanation": "View → Group by से आप files को type (folder, document, image), date modified, size, name के हिसाब से group कर सकते हैं। जैसे सभी images एक group में, videos दूसरे में।",
      "difficulty": "medium",
      "hint": "Organise files by categories।",
      "points": 15
    },
    {
      "question": "File Explorer में 'Sort by' क्या करता है?",
      "options": ["Files को name, date, size, type के हिसाब से ascending/descending order में arrange करता है", "Files को group करता है", "Files को filter करता है", "Files को delete करता है"],
      "answer": 0,
      "explanation": "Sort by (View → Sort by या right click → Sort by) से files को नाम, तारीख, साइज, टाइप के अनुसार क्रम में लगा सकते हैं।",
      "difficulty": "easy",
      "hint": "नई फाइल सबसे ऊपर दिखाने के लिए Date modified।",
      "points": 10
    },
    {
      "question": "File Explorer में 'Filter' कैसे apply करें?",
      "options": ["Column header पर mouse ले जाकर dropdown arrow → filter options", "Search box में type करें", "View → Filter", "Ctrl + Shift + F"],
      "answer": 0,
      "explanation": "Details view में किसी भी column header (Name, Date modified, Type, Size) पर arrow पर click करें और filter options (जैसे date range, file type) select करें।",
      "difficulty": "hard",
      "hint": "ज्यादा files में से चुनिंदा दिखाने के लिए।",
      "points": 20
    },
    {
      "question": "पुरानी कटी/कॉपी की गई फ़ाइलों को Undo (वापस लाने) का shortcut key क्या है?",
      "options": ["Ctrl + Z", "Ctrl + Y", "Ctrl + R", "Ctrl + U"],
      "answer": 0,
      "explanation": "Ctrl + Z last action undo करता है। अगर आपने गलती से file move/copy/delete कर दी, तो Ctrl + Z से वापस ला सकते हैं।",
      "difficulty": "easy",
      "hint": "Z = ज़ीरो (वापस ज़ीरो पर)।",
      "points": 10
    },
    {
      "question": "Undo किए हुए action को Redo (फिर से करने) का shortcut key क्या है?",
      "options": ["Ctrl + Y", "Ctrl + Z", "Ctrl + R", "Ctrl + Shift + Z"],
      "answer": 0,
      "explanation": "Ctrl + Y (Redo) Ctrl+Z को reverse करता है। यानी undo किए हुए action को फिर से apply करता है।",
      "difficulty": "medium",
      "hint": "Y = why not (दोबारा करो)।",
      "points": 15
    },
    {
      "question": "File Explorer को Administrator mode में कैसे खोलें?",
      "options": ["File Explorer icon पर right click → Run as administrator", "Windows + E दबाकर", "Ctrl + Shift + File Explorer click", "A और C दोनों"],
      "answer": 3,
      "explanation": "Taskbar या Start menu में File Explorer icon पर right click → Run as administrator। या Windows + E के साथ Ctrl+Shift दबाए रखें। Elevation की जरूरत होती है।",
      "difficulty": "hard",
      "hint": "System files modify करने के लिए जरूरी।",
      "points": 20
    },
    {
      "question": "File या Folder को पासवर्ड से protect कैसे करें (without third-party)?",
      "options": ["Windows में built-in फ़ीचर नहीं है (third-party tool या BitLocker / zipped folder with password)", "Right click → Password protect", "Properties → Security", "File → Encrypt"],
      "answer": 0,
      "explanation": "Windows Home edition में folder password protect का built-in option नहीं है। Pro में BitLocker है। सेकंड ऑप्शन: Zip folder बनाकर उसमें password डालें (7-Zip, WinRAR से), या third-party software।",
      "difficulty": "hard",
      "hint": "Windows मूल रूप से simple password protect नहीं देता।",
      "points": 20
    },
    {
      "question": "File को 'Send to' कहाँ से कर सकते हैं?",
      "options": ["Right click → Send to (Compressed folder, Desktop, Mail, Bluetooth)", "File menu → Send to", "Edit menu → Send to", "View menu → Send to"],
      "answer": 0,
      "explanation": "फ़ाइल पर right click करें → Send to मेनू से आप file को zip, desktop (shortcut), mail recipient, bluetooth device, या किसी specific folder (जैसे Documents) में भेज सकते हैं।",
      "difficulty": "easy",
      "hint": "Quickly share करने का तरीका।",
      "points": 10
    },
    {
      "question": "Files को बिना Delete किए permanently हटाने का shortcut जो Recycle Bin को skip करता है?",
      "options": ["Shift + Delete", "Ctrl + Delete", "Alt + Delete", "Delete"],
      "answer": 0,
      "explanation": "Shift + Delete permanently delete कर देता है, Recycle Bin में नहीं जाती। बहुत सावधानी से उपयोग करें।",
      "difficulty": "medium",
      "hint": "No second chance after this।",
      "points": 15
    },
    {
      "question": "Network drive (Shared folder) को Map (assign drive letter) कैसे करें?",
      "options": ["This PC → Map network drive → Select drive letter → Folder path (\\server\\share)", "Right click on network folder → Map network drive", "Net use command in CMD", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "This PC में ऊपर 'Map network drive' button है। या \\servername\\sharename पर right click → Map network drive। Command line: net use Z: \\server\share। इससे drive my computer में दिखेगी।",
      "difficulty": "hard",
      "hint": "Network folder को अपनी drive की तरह use करें।",
      "points": 20
    },
    {
      "question": "OneDrive में फ़ाइलें sync करने का क्या मतलब है?",
      "options": ["File cloud (OneDrive) और PC पर दोनों जगह same रहती है", "File सिर्फ cloud में रहती है", "File सिर्फ PC में रहती है", "File compress हो जाती है"],
      "answer": 0,
      "explanation": "Sync का मतलब है कि PC पर जो बदलाव करोगे, वो cloud पर भी हो जाएगा और vice versa। OneDrive folder में files रखो तो वो automatically cloud पर backup हो जाती हैं और दूसरे PCs पर भी available होंगी।",
      "difficulty": "medium",
      "hint": "Cloud backup + Access anywhere।",
      "points": 15
    },
    {
      "question": "OneDrive में 'Files On-Demand' क्या है?",
      "options": ["Files सिर्फ cloud में दिखती हैं, download tabahi jab open करो तो", "सिर्फ download नहीं होती बिना demand के", "लोकल space बचती है", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Files On-Demand से files लोकल हार्ड ड्राइव पर जगह नहीं लेतीं (just placeholder). जब आप file open करते हैं तभी download होती है। Online-only vs locally available।",
      "difficulty": "hard",
      "hint": "कम space वालों के लिए वरदान।",
      "points": 20
    },
    {
      "question": "File path का क्या मतलब है?",
      "options": ["File का storage location (जैसे C:\\Users\\Name\\Desktop\\file.txt)", "File का नाम", "File size", "File extension"],
      "answer": 0,
      "explanation": "File Path (Address) बताता है कि file किस drive, किस folder और sub-folder में रखी है। Example: D:\\Music\\Songs\\song.mp3",
      "difficulty": "medium",
      "hint": "File का पूरा घर का पता।",
      "points": 15
    },
    {
      "question": "File Explorer के Address Bar का क्या उपयोग है?",
      "options": ["Current folder path दिखाता है और सीधे path टाइप करके जा सकते हैं", "Search करना", "File delete करना", "Rename करना"],
      "answer": 0,
      "explanation": "Address Bar (top) में current folder का path दिखता है। आप सीधे path लिख कर (जैसे C:\\Windows) उस folder में jump कर सकते हैं।",
      "difficulty": "easy",
      "hint": "Path यहाँ से copy कर सकते हैं।",
      "points": 10
    },
    {
      "question": "File Explorer में 'Refresh' (ताज़ा) करने का shortcut key क्या है?",
      "options": ["F5", "Ctrl + R", "Shift + F5", "A और B दोनों"],
      "answer": 3,
      "explanation": "F5 या Ctrl + R से current folder refresh होता है (नई files दिखती हैं, यदि कोई changes हुए हों तो update हो जाता है)।",
      "difficulty": "easy",
      "hint": "File delete के बाद दिख रही है तो F5 दबाएँ।",
      "points": 10
    },
    {
      "question": "File Explorer में 'New Folder' का दूसरा तरीका (menu से) क्या है?",
      "options": ["Right click → New → Folder", "Home tab → New Folder", "Ctrl + Shift + N", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "तीनों तरीके काम करते हैं: Right click, Home टैब में New Folder button, या Ctrl+Shift+N।",
      "difficulty": "easy",
      "hint": "जो भी आसानी हो।",
      "points": 10
    },
    {
      "question": ".dll file क्या होती है?",
      "options": ["Dynamic Link Library - multiple programs द्वारा shared code", "Document file", "Image file", "Executable file"],
      "answer": 0,
      "explanation": ".dll (Dynamic Link Library) files contain code, data, resources that multiple programs can use simultaneously. ये standalone नहीं चलतीं। Missing DLL errors आम हैं।",
      "difficulty": "hard",
      "hint": "Programs के shared library।",
      "points": 20
    },
    {
      "question": "Naming convention के अनुसार Windows में फ़ाइल नाम में कौन से characters invalid हैं?",
      "options": ["\\ / : * ? \" < > |", ". (dot)", "- (hyphen)", "_ (underscore)"],
      "answer": 0,
      "explanation": "Windows file name में ये characters नहीं दे सकते: \\ / : * ? \" < > | (backslash, forward slash, colon, asterisk, question mark, double quote, less than, greater than, pipe)। Dot allowed है (extension के अलावा)",
      "difficulty": "hard",
      "hint": "ये symbols path और commands में इस्तेमाल होते हैं।",
      "points": 20
    },
    {
      "question": "Maximum file name length in Windows (with full path) कितनी होती है?",
      "options": ["260 characters (MAX_PATH)", "100 characters", "500 characters", "Unlimited"],
      "answer": 0,
      "explanation": "Windows traditionally has 260 characters limit for full path (including drive letter, folders, file name) - MAX_PATH। Windows 10/11 में long path enable कर सकते हैं (registry/group policy से)।",
      "difficulty": "hard",
      "hint": "File path बहुत लंबा हो तो error आता है।",
      "points": 20
    },
    {
      "question": "What happens if you delete a file in use by another program?",
      "options": ["File delete नहीं होगी, 'File in use' error आएगा", "File delete हो जाएगी", "Program crash हो जाएगा", "Computer restart होगा"],
      "answer": 0,
      "explanation": "If a file is currently opened by a program (locked), Windows will prevent deletion and show 'The action can't be completed because the file is open in another program' error।",
      "difficulty": "medium",
      "hint": "पहले program बंद करो, फिर delete करो।",
      "points": 15
    },
    {
      "question": "How to open Command Prompt from a specific folder in File Explorer?",
      "options": ["Type 'cmd' in address bar और Enter", "Shift + right click on folder → Open command window here", "File → Open command prompt", "A और B दोनों"],
      "answer": 3,
      "explanation": "Address bar में 'cmd' लिखकर Enter करने से CMD उसी folder path में खुलता है। या Shift + right click → 'Open PowerShell window here' (or Command Prompt)।",
      "difficulty": "medium",
      "hint": "CMD में cd path टाइप करने की जरूरत नहीं।",
      "points": 15
    },
    {
      "question": "File Explorer में 'Preview Pane' क्या करता है?",
      "options": ["File की content बिना खोले दिखाता है (images, text, pdf, video thumbnails)", "File properties दिखाता है", "File size दिखाता है", "File path दिखाता है"],
      "answer": 0,
      "explanation": "View → Preview Pane enable करने पर right side panel खुलता है। उसमें selected file का content (text, image preview, video thumbnail) देख सकते हैं बिना file खोले।",
      "difficulty": "medium",
      "hint": "Quick preview के लिए।",
      "points": 15
    },
    {
      "question": "File Explorer में 'Details Pane' क्या दिखाता है?",
      "options": ["Selected file का size, date modified, author, type, dimensions", "File preview", "Folder tree", "Search results"],
      "answer": 0,
      "explanation": "Details Pane (View → Details pane) selected file/folder के मेटाडेटा (properties) दिखाता है। Images में dimensions, documents में author, etc.",
      "difficulty": "medium",
      "hint": "Quick properties देखने के लिए।",
      "points": 15
    },
    {
      "question": "NTFS (file system) में 'Alternate Data Streams' (ADS) क्या है?",
      "options": ["Additional hidden data attached to a file (मैलवेयर इस्तेमाल करते हैं)", "File backup", "File encryption", "File compression"],
      "answer": 0,
      "explanation": "ADS एक NTFS feature है जो एक file में extra hidden data stream attach कर सकता है। Command: echo hidden > file.txt:hidden। Malware कभी-कभी इसका इस्तेमाल करते हैं।",
      "difficulty": "hard",
      "hint": "File size change किए बिना extra data छुपा सकते हैं।",
      "points": 20
    },
    {
      "question": "File को permanently delete करने के बाद वापस लाने के लिए क्या use करते हैं?",
      "options": ["Data recovery software (जैसे Recuva, EaseUS Data Recovery)", "Recycle Bin", "Undo (Ctrl+Z)", "File history"],
      "answer": 0,
      "explanation": "Shift+Delete या Recycle Bin empty करने के बाद files permanently delete हो जाती हैं (mark as available space)। Data recovery software से possibility होती है जबतक data overwrite न हो।",
      "difficulty": "hard",
      "hint": "जल्दी करो, data recover होने की probability high होती है।",
      "points": 20
    },
    {
      "question": "Disk space कैसे check करें कि कितनी free है?",
      "options": ["This PC → Drive (C:) पर right click → Properties", "Settings → System → Storage", "File Explorer में drive का free space दिखता है", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "This PC में drives के नीचे free space bar दिखता है। Drive पर right click → Properties में भी देख सकते हैं। Settings → Storage में भी।",
      "difficulty": "easy",
      "hint": "Red bar means almost full।",
      "points": 10
    },
    {
      "question": "Disk Cleanup tool कैसे खोलें?",
      "options": ["Start menu search 'Disk Cleanup'", "This PC → drive properties → Disk Cleanup", "Run → cleanmgr", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Disk Cleanup temporary files, recycle bin, thumbnails, delivery optimization files हटाता है। cleanmgr run करके खोलें।",
      "difficulty": "easy",
      "hint": "Free up disk space quickly।",
      "points": 10
    },
    {
      "question": ".tmp और .temp फ़ाइलों को safely delete कैसे करें?",
      "options": ["Disk Cleanup use करें", "Run → %temp% → सब select करें → Delete", "Settings → Storage → Temporary files", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Run box में %temp% टाइप करने पर temp folder खुलता है। यहाँ की files आमतौर पर safe to delete। Disk Cleanup भी साफ कर सकता है।",
      "difficulty": "medium",
      "hint": "कई GB space free हो सकता है।",
      "points": 15
    },
    {
      "question": "File Explorer में 'Open with' क्या करता है?",
      "options": ["File को चुनकर किसी specific program से खोलना (जैसे image को Photoshop से)", "File को delete करना", "File को rename करना", "File को copy करना"],
      "answer": 0,
      "explanation": "Right click → Open with → Choose another app। यह file type के default program को override करता है। 'Always use this app' भी check कर सकते हैं।",
      "difficulty": "easy",
      "hint": "File गलत program में खुल रही है तो यहाँ से बदलें।",
      "points": 10
    },
    {
      "question": "File प्रकार के default program को कैसे बदलें (जैसे सभी .txt files Notepad++ से खुलें)?",
      "options": ["Settings → Apps → Default Apps → Choose default apps by file type", "Right click on .txt file → Open with → Choose another app → Always use this app", "Control Panel → Default Programs", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "तीनों तरीकों से आप permanently default program change कर सकते हैं।",
      "difficulty": "medium",
      "hint": "Set default once, always use।",
      "points": 15
    },
    {
      "question": "File Explorer में 'Previous Versions' (File History restore) कहाँ मिलती है?",
      "options": ["File पर right click → Properties → Previous Versions tab", "File Explorer → History", "Settings → File History", "Control Panel → File History"],
      "answer": 0,
      "explanation": "File या folder पर right click → Properties → Previous Versions tab में older versions दिखती हैं (यदि File History enabled हो और backup available हो)।",
      "difficulty": "hard",
      "hint": "Undelete file using backup।",
      "points": 20
    }
  ],
  "5. Internet Fundamentals": [
    {
      "question": "इंटरनेट क्या है?",
      "options": ["Computers का worldwide network", "एक software", "एक company", "एक browser"],
      "answer": 1,
      "explanation": "Internet दुनिया भर के कंप्यूटर नेटवर्क का एक विशाल नेटवर्क है जो TCP/IP प्रोटोकॉल का उपयोग करके आपस में जुड़े होते हैं।",
      "difficulty": "easy",
      "hint": "यह networks का नेटवर्क है।",
      "points": 10
    },
    {
      "question": "WWW का पूरा नाम क्या है?",
      "options": ["World Wide Web", "World Web Wide", "Web World Wide", "Wide World Web"],
      "answer": 0,
      "explanation": "WWW (World Wide Web) इंटरनेट पर उपलब्ध सभी वेबसाइटों और वेब पेजों का एक सिस्टम है। यह इंटरनेट की एक सेवा है।",
      "difficulty": "easy",
      "hint": "Web pages का collection।",
      "points": 10
    },
    {
      "question": "Internet और WWW में क्या अंतर है?",
      "options": ["Internet is network infrastructure, WWW is a service on it", "दोनों एक ही हैं", "WWW is bigger", "Internet is only for email"],
      "answer": 2,
      "explanation": "Internet भौतिक नेटवर्क इंफ्रास्ट्रक्चर है (cables, routers, servers). WWW एक सेवा है जो इंटरनेट पर चलती है (websites, links). Email, FTP, VoIP भी इंटरनेट की सेवाएं हैं, WWW नहीं।",
      "difficulty": "medium",
      "hint": "Internet सड़क है, WWW उस पर चलने वाली कार।",
      "points": 15
    },
    {
      "question": "URL का पूरा नाम क्या है?",
      "options": ["Uniform Resource Locator", "Universal Resource Locator", "Uniform Response Locator", "Universal Response Link"],
      "answer": 1,
      "explanation": "URL (Uniform Resource Locator) वेब पर किसी संसाधन ( webpage, image, video) का unique address होता है। जैसे https://www.google.com",
      "difficulty": "easy",
      "hint": "Website का पता।",
      "points": 10
    },
    {
      "question": "URL में 'https://' क्या दर्शाता है?",
      "options": ["Protocol (secure HTTP)", "Website name", "Domain name", "File path"],
      "answer": 3,
      "explanation": "HTTPS (Hypertext Transfer Protocol Secure) एक प्रोटोकॉल है जो encryption (SSL/TLS) का उपयोग करता है ताकि data सुरक्षित रहे।",
      "difficulty": "easy",
      "hint": "S का मतलब Secure।",
      "points": 10
    },
    {
      "question": "Domain name क्या होता है?",
      "options": ["Website का मानव-पठनीय पता (जैसे google.com)", "IP address", "Server name", "Protocol"],
      "answer": 0,
      "explanation": "Domain name IP address का एक आसान नाम है। हमें 172.217.166.46 याद रखने की बजाय google.com याद रखना आसान है।",
      "difficulty": "easy",
      "hint": "Website का नाम।",
      "points": 10
    },
    {
      "question": "DNS (Domain Name System) क्या करता है?",
      "options": ["Domain names को IP addresses में translate करता है", "Websites को block करता है", "Internet speed बढ़ाता है", "Emails भेजता है"],
      "answer": 1,
      "explanation": "DNS domain names (google.com) को machine-readable IP addresses (142.250.183.46) में बदलता है। इसे 'इंटरनेट का फोनबुक' कहते हैं।",
      "difficulty": "medium",
      "hint": "नाम बताओ, नंबर (IP) दे देगा।",
      "points": 15
    },
    {
      "question": "IP address का पूरा नाम क्या है?",
      "options": ["Internet Protocol Address", "Internal Protocol Address", "Internet Process Address", "Internal Process Address"],
      "answer": 0,
      "explanation": "IP address एक unique identifier है जो प्रत्येक device को नेटवर्क पर पहचानता है। IPv4 में 4 numbers (192.168.1.1) होते हैं।",
      "difficulty": "easy",
      "hint": "Internet पर device का ID।",
      "points": 10
    },
    {
      "question": "IPv4 एड्रेस में कितने बिट्स होते हैं?",
      "options": ["32 bits", "16 bits", "64 bits", "128 bits"],
      "answer": 2,
      "explanation": "IPv4 में 32 bits होते हैं, जो 4 octets (0-255) के रूप में लिखे जाते हैं (जैसे 192.168.1.1)। लगभग 4.3 बिलियन unique addresses।",
      "difficulty": "hard",
      "hint": "4 numbers × 8 bits = 32 bits।",
      "points": 20
    },
    {
      "question": "IPv6 एड्रेस में कितने बिट्स होते हैं?",
      "options": ["128 bits", "32 bits", "64 bits", "256 bits"],
      "answer": 0,
      "explanation": "IPv6 में 128 bits होते हैं, जो 8 groups के hexadecimal numbers में लिखे जाते हैं (2001:0db8:85a3:0000:0000:8a2e:0370:7334)। IPv4 addresses खत्म हो रहे थे तो IPv6 बनाया गया।",
      "difficulty": "hard",
      "hint": "बहुत ज्यादा addresses possible हैं।",
      "points": 20
    },
    {
      "question": "Web Browser क्या है?",
      "options": ["Software जो websites देखने के लिए होता है (Chrome, Firefox, Edge)", "Search engine", "Email client", "Operating system"],
      "answer": 0,
      "explanation": "Web browser एक एप्लिकेशन है जो HTML, CSS, JavaScript को render करके वेब पेज दिखाता है। Browser से आप internet पर सर्फ करते हैं।",
      "difficulty": "easy",
      "hint": "Google Chrome, Mozilla Firefox।",
      "points": 10
    },
    {
      "question": "Search Engine क्या है?",
      "options": ["Website जो internet पर information ढूंढता है (Google, Bing)", "Browser", "Email service", "Social media"],
      "answer": 0,
      "explanation": "Search Engine (जैसे Google, Bing, Yahoo) एक वेबसाइट है जो आपके keyword के आधार पर billions of web pages में से relevant results ढूंढकर दिखाती है।",
      "difficulty": "easy",
      "hint": "गूगल सबसे लोकप्रिय है।",
      "points": 10
    },
    {
      "question": "HTML का पूरा नाम क्या है?",
      "options": ["HyperText Markup Language", "HighText Markup Language", "HyperText Machine Language", "HyperText Multi Language"],
      "answer": 0,
      "explanation": "HTML (HyperText Markup Language) वेब पेजों को बनाने की standard language है। ब्राउज़र HTML को पढ़कर पेज दिखाता है।",
      "difficulty": "medium",
      "hint": "Webpages की skeleton।",
      "points": 15
    },
    {
      "question": "HTTP का पूरा नाम क्या है?",
      "options": ["HyperText Transfer Protocol", "HighText Transfer Protocol", "HyperText Transport Protocol", "HighText Transport Protocol"],
      "answer": 0,
      "explanation": "HTTP एक प्रोटोकॉल है जो web server और browser के बीच data transfer को नियंत्रित करता है।",
      "difficulty": "medium",
      "hint": "Web पर communication का rule book।",
      "points": 15
    },
    {
      "question": "FTP का पूरा नाम क्या है?",
      "options": ["File Transfer Protocol", "Fast Transfer Protocol", "File Transport Protocol", "Folder Transfer Protocol"],
      "answer": 0,
      "explanation": "FTP (File Transfer Protocol) का उपयोग कंप्यूटर और server के बीच files transfer करने के लिए होता है।",
      "difficulty": "medium",
      "hint": "Files upload/download करने का protocol।",
      "points": 15
    },
    {
      "question": "ISP क्या होता है?",
      "options": ["Internet Service Provider (Jio, Airtel, BSNL)", "Internet Security Provider", "Internet Speed Provider", "Internet Software Provider"],
      "answer": 0,
      "explanation": "ISP वह कंपनी होती है जो आपको इंटरनेट कनेक्शन प्रदान करती है। उदाहरण: Jio, Airtel, BSNL, ACT, Vi।",
      "difficulty": "easy",
      "hint": "जिससे internet plan लेते हो।",
      "points": 10
    },
    {
      "question": "बैंडविड्थ (Bandwidth) क्या है?",
      "options": ["Data transfer की maximum rate (Mbps में)", "Internet speed", "Data limit", "Latency"],
      "answer": 1,
      "explanation": "Bandwidth किसी नेटवर्क कनेक्शन की अधिकतम डेटा ट्रांसफर क्षमता होती है। इसे Mbps (megabits per second) में मापते हैं। ज्यादा bandwidth = ज्यादा speed।",
      "difficulty": "medium",
      "hint": "Pipe की चौड़ाई जितनी ज्यादा, उतना ज्यादा पानी।",
      "points": 15
    },
    {
      "question": "Latency क्या है?",
      "options": ["Data को source से destination तक पहुँचने में लगा समय (ms में)", "Download speed", "Upload speed", "Data limit"],
      "answer": 1,
      "explanation": "Latency (Ping) वह समय है जो data packet को भेजने और response आने में लगता है। मिलीसेकंड (ms) में मापा जाता है। Low latency good (gaming, video calls के लिए important)।",
      "difficulty": "hard",
      "hint": "जितना कम उतना अच्छा।",
      "points": 20
    },
    {
      "question": "Modem क्या करता है?",
      "options": ["Digital signals को analog में और analog को digital में बदलता है", "Network switch करता है", "Router का काम करता है", "WiFi signal बढ़ाता है"],
      "answer": 0,
      "explanation": "Modem (Modulator-Demodulator) ISP के signal (coaxial/phone line) को digital data में बदलता है जिसे computer समझ सके। आमतौर पर ISP देता है।",
      "difficulty": "medium",
      "hint": "Internet cable को Ethernet में बदलता है।",
      "points": 15
    },
    {
      "question": "Router क्या करता है?",
      "options": ["Multiple devices के बीच internet connection share करता है", "Modem का काम करता है", "Signal बढ़ाता है", "IP address बदलता है"],
      "answer": 0,
      "explanation": "Router एक नेटवर्क डिवाइस है जो एक internet connection को multiple devices (WiFi और Ethernet) के बीच distribute करता है। यह local IP addresses assign करता है।",
      "difficulty": "easy",
      "hint": "WiFi चलाने वाला device।",
      "points": 10
    },
    {
      "question": "WiFi क्या है?",
      "options": ["Wireless networking technology (devices को बिना cable के internet से जोड़ती है)", "Mobile data", "Bluetooth", "Ethernet"],
      "answer": 1,
      "explanation": "WiFi (Wireless Fidelity) एक wireless technology है जो radio waves का उपयोग करके devices को internet और नेटवर्क से जोड़ती है।",
      "difficulty": "easy",
      "hint": "बिना तार के internet।",
      "points": 10
    },
    {
      "question": "Ethernet क्या है?",
      "options": ["Wired networking technology (LAN cable)", "Wireless technology", "Internet protocol", "Browser"],
      "answer": 0,
      "explanation": "Ethernet एक wired नेटवर्किंग तकनीक है जो LAN (Local Area Network) के लिए ethernet cable (RJ45) का उपयोग करती है। WiFi से ज्यादा stable और fast होता है।",
      "difficulty": "medium",
      "hint": "LAN cable जो router से PC में लगती है।",
      "points": 15
    },
    {
      "question": "LAN क्या है?",
      "options": ["Local Area Network (small area like home, office)", "Large Area Network", "Long Area Network", "Low Area Network"],
      "answer": 0,
      "explanation": "LAN एक नेटवर्क है जो छोटे भौगोलिक क्षेत्र (घर, ऑफिस, स्कूल) में devices को जोड़ता है।",
      "difficulty": "easy",
      "hint": "घर का नेटवर्क।",
      "points": 10
    },
    {
      "question": "WAN क्या है?",
      "options": ["Wide Area Network (large geographical area - countries, continents)", "Wireless Area Network", "World Area Network", "Web Area Network"],
      "answer": 0,
      "explanation": "WAN एक नेटवर्क है जो बहुत बड़े भौगोलिक क्षेत्र (देशों, महाद्वीपों) में फैला होता है। इंटरनेट सबसे बड़ा WAN है।",
      "difficulty": "medium",
      "hint": "देशों को जोड़ने वाला नेटवर्क।",
      "points": 15
    },
    {
      "question": "MAN क्या है?",
      "options": ["Metropolitan Area Network (city size)", "Medium Area Network", "Mini Area Network", "Multiple Area Network"],
      "answer": 0,
      "explanation": "MAN एक नेटवर्क है जो एक शहर या महानगर के आकार का होता है। जैसे एक शहर के सभी government offices आपस में जुड़े हों।",
      "difficulty": "medium",
      "hint": "LAN से बड़ा, WAN से छोटा।",
      "points": 15
    },
    {
      "question": "Topology क्या होती है?",
      "options": ["Network devices के arrange करने का physical/logical layout", "Internet speed", "Network security", "IP address"],
      "answer": 0,
      "explanation": "Network topology यह बताती है कि कंप्यूटर, switches, routers एक दूसरे से कैसे जुड़े हैं। जैसे Star, Bus, Ring, Mesh topology।",
      "difficulty": "hard",
      "hint": "Network का नक्शा।",
      "points": 20
    },
    {
      "question": "VPN क्या है?",
      "options": ["Virtual Private Network (encrypts connection और IP hide करता है)", "Very Private Network", "Virtual Public Network", "Virus Protection Network"],
      "answer": 0,
      "explanation": "VPN आपके internet connection को encrypt करता है और आपके real IP address को hide करके दूसरी location का IP दिखाता है। Privacy और geo-restrictions bypass के लिए।",
      "difficulty": "medium",
      "hint": "Internet पर गुमनामी।",
      "points": 15
    },
    {
      "question": "Proxy Server क्या है?",
      "options": ["Intermediate server जो आपकी request को forward करता है और IP hide करता है", "VPN जैसा", "Firewall", "DNS server"],
      "answer": 1,
      "explanation": "Proxy server आपके और internet के बीच एक मध्यस्थ (middleman) है। यह आपकी real IP address को छुपाता है। VPN की तुलना में कम secure होता है।",
      "difficulty": "hard",
      "hint": "VPN से सस्ता विकल्प।",
      "points": 20
    },
    {
      "question": "Firewall क्या करता है?",
      "options": ["Incoming और outgoing network traffic को नियंत्रित करता है (एक security बैरियर)", "Virus हटाता है", "Internet speed बढ़ाता है", "Websites block करता है"],
      "answer": 0,
      "explanation": "Firewall एक नेटवर्क सुरक्षा प्रणाली है जो pre-set security rules के आधार पर traffic को allow या block करती है। Hardware या software हो सकता है।",
      "difficulty": "medium",
      "hint": "Digital दीवार।",
      "points": 15
    },
    {
      "question": "Port नंबर क्या है?",
      "options": ["Network connection का endpoint जो specific service को identify करता है (जैसे 80 for HTTP, 443 for HTTPS)", "USB port", "IP address का हिस्सा", "Cable type"],
      "answer": 1,
      "explanation": "Port numbers (0-65535) यह बताते हैं कि traffic किस service के लिए है। HTTP=80, HTTPS=443, SSH=22, DNS=53, FTP=21, SMTP=25, RDP=3389।",
      "difficulty": "hard",
      "hint": "IP address मकान नंबर है, port कमरा नंबर।",
      "points": 20
    },
    {
      "question": "HTTPS किस port का उपयोग करता है?",
      "options": ["443", "80", "8080", "21"],
      "answer": 1,
      "explanation": "HTTPS secure web traffic के लिए default port 443 का उपयोग करता है। HTTP (non-secure) port 80 का उपयोग करता है।",
      "difficulty": "medium",
      "hint": "HTTP 80, HTTPS 443।",
      "points": 15
    },
    {
      "question": "SMTP किसके लिए उपयोग होता है?",
      "options": ["Emails भेजने के लिए (sending)", "Emails receive करने के लिए", "File transfer के लिए", "Web browsing के लिए"],
      "answer": 0,
      "explanation": "SMTP (Simple Mail Transfer Protocol) email भेजने के लिए उपयोग होता है। POP3 और IMAP emails receive करने के लिए होते हैं।",
      "difficulty": "hard",
      "hint": "Send Mail Protocol।",
      "points": 20
    },
    {
      "question": "POP3 और IMAP में क्या अंतर है?",
      "options": ["POP3 emails को device पर download करता है और server से delete करता है, IMAP server पर रखता है और sync करता है", "दोनों एक जैसे हैं", "POP3 newer है", "IMAP older है"],
      "answer": 0,
      "explanation": "POP3 emails को local device पर download करके server से हटा देता है (एक device के लिए good). IMAP emails server पर रखता है और सभी devices में sync रखता है (multiple devices के लिए good)।",
      "difficulty": "hard",
      "hint": "IMAP से phone और laptop दोनों पर same inbox।",
      "points": 20
    },
    {
      "question": "Cloud Computing क्या है?",
      "options": ["Internet पर services (storage, computing) on-demand प्रदान करना", "Weather computing", "Local storage", "Offline computing"],
      "answer": 0,
      "explanation": "Cloud Computing का मतलब है 'internet पर' computing services (servers, storage, databases, software) का उपयोग करना। जैसे Google Drive, Netflix, Gmail, AWS, Azure।",
      "difficulty": "medium",
      "hint": "डेटा दूसरे के server पर, लेकिन तुम use कर सकते हो।",
      "points": 15
    },
    {
      "question": "SaaS क्या है?",
      "options": ["Software as a Service (software को install किए बिना browser से use करना)", "Storage as a Service", "Security as a Service", "System as a Service"],
      "answer": 0,
      "explanation": "SaaS (Software as a Service) cloud computing model है जहाँ आप software (जैसे Google Docs, Microsoft 365, Gmail) को install किए बिना internet पर use करते हैं।",
      "difficulty": "hard",
      "hint": "Browser में चलने वाला software।",
      "points": 20
    },
    {
      "question": "PaaS क्या है?",
      "options": ["Platform as a Service (developers के लिए platform - coding, testing, deployment)", "Program as a Service", "Product as a Service", "Process as a Service"],
      "answer": 0,
      "explanation": "PaaS cloud में platform (OS, runtime, database, web server) provide करता है ताकि developers infrastructure की चिंता किए बिना apps बना सकें। जैसे Google App Engine, Heroku।",
      "difficulty": "hard",
      "hint": "Developers के लिए।",
      "points": 20
    },
    {
      "question": "IaaS क्या है?",
      "options": ["Infrastructure as a Service (virtual machines, storage, networking)", "Internet as a Service", "Integration as a Service", "Information as a Service"],
      "answer": 0,
      "explanation": "IaaS cloud में basic infrastructure (VMs, storage, networking) प्रदान करता है। आप OS और applications खुद manage करते हैं। जैसे AWS EC2, Google Compute Engine, Microsoft Azure।",
      "difficulty": "hard",
      "hint": "Virtual computer rent करना।",
      "points": 20
    },
    {
      "question": "Cookies क्या होती हैं?",
      "options": ["छोटी text files जो websites आपके browser में store करती हैं (login, preferences याद रखने के लिए)", "Virus", "Browser extension", "Temporary files"],
      "answer": 1,
      "explanation": "Cookies आपके browsing data (login status, cart items, preferences) store करती हैं। Session cookies temporary होती हैं, persistent cookies long-term। इनसे tracking भी हो सकती है।",
      "difficulty": "medium",
      "hint": "Website आपको 'पहचाने' रखता है।",
      "points": 15
    },
    {
      "question": "Cache memory in browser क्या करती है?",
      "options": ["Web pages के elements (images, CSS, JS) को locally store करती है ताकि下次 loading fast हो", "Cookies store करती है", "History store करती है", "Passwords store करती है"],
      "answer": 0,
      "explanation": "Browser cache downloaded web resources को store करता है। जब आप दोबारा same site visit करते हैं तो cached files use होती हैं, जिससे page जल्दी load होता है।",
      "difficulty": "medium",
      "hint": "पुरानी files को reuse करना = speed।",
      "points": 15
    },
    {
      "question": "पहला Web Browser कौन सा था?",
      "options": ["WorldWideWeb (later renamed Nexus)", "Netscape Navigator", "Internet Explorer", "Mosaic"],
      "answer": 3,
      "explanation": "पहला web browser 'WorldWideWeb' था जिसे Tim Berners-Lee ने 1990 में बनाया था। बाद में इसका नाम 'Nexus' रखा गया। Mosaic (1993) पहला popular browser था।",
      "difficulty": "hard",
      "hint": "Tim Berners-Lee ने बनाया था।",
      "points": 20
    },
    {
      "question": "World Wide Web का आविष्कार किसने किया?",
      "options": ["Tim Berners-Lee", "Bill Gates", "Steve Jobs", "Mark Zuckerberg"],
      "answer": 0,
      "explanation": "Tim Berners-Lee ने 1989 में CERN में World Wide Web का आविष्कार किया। उन्होंने पहला web browser और web server भी बनाया।",
      "difficulty": "medium",
      "hint": "WWW के जनक।",
      "points": 15
    },
    {
      "question": "HTML का आविष्कार किसने किया?",
      "options": ["Tim Berners-Lee", "Bill Gates", "Larry Page", "Sergey Brin"],
      "answer": 0,
      "explanation": "Tim Berners-Lee ने 1991 में HTML (HyperText Markup Language) का आविष्कार किया। यह web pages बनाने की मानक भाषा है।",
      "difficulty": "medium",
      "hint": "WWW के inventor ने ही HTML बनाया।",
      "points": 15
    },
    {
      "question": "Internet का जन्म किस project से हुआ?",
      "options": ["ARPANET (US Department of Defense, 1969)", "CERN", "Microsoft", "Google"],
      "answer": 0,
      "explanation": "Internet का precursor ARPANET था जिसे 1969 में US Department of Defense ने बनाया था। यह पहला packet-switching network था।",
      "difficulty": "hard",
      "hint": "Cold War के दौरान बना था।",
      "points": 20
    },
    {
      "question": "TCP/IP क्या है?",
      "options": ["Internet के लिए fundamental communication protocol suite", "Antivirus", "Browser", "Search engine"],
      "answer": 0,
      "explanation": "TCP/IP (Transmission Control Protocol/Internet Protocol) इंटरनेट का मुख्य संचार प्रोटोकॉल सूट है। यह तय करता है कि data packets कैसे भेजे, रूट किए, और receive किए जाएँ।",
      "difficulty": "hard",
      "hint": "Internet की language।",
      "points": 20
    },
    {
      "question": "पहला search engine कौन सा था?",
      "options": ["Archie (1990)", "Google (1998)", "Yahoo (1994)", "AltaVista (1995)"],
      "answer": 0,
      "explanation": "Archie को 1990 में McGill University के students ने बनाया था। यह FTP sites के files को index करता था, लेकिन web content के लिए नहीं।",
      "difficulty": "hard",
      "hint": "Google से भी पहले।",
      "points": 20
    },
    {
      "question": "Google का founding year क्या है?",
      "options": ["1998", "1996", "2000", "1994"],
      "answer": 0,
      "explanation": "Google की स्थापना Larry Page और Sergey Brin ने 4 सितंबर 1998 को Stanford University में PhD students के रूप में की थी।",
      "difficulty": "medium",
      "hint": "BackRub original name था।",
      "points": 15
    },
    {
      "question": "Deep Web क्या है?",
      "options": ["Internet का वह हिस्सा जो search engines द्वारा indexed नहीं है (private databases, medical records, banking)", "Dark Web", "Surface Web", "Illegal websites"],
      "answer": 0,
      "explanation": "Deep Web वह हिस्सा है जो search engines (Google, Bing) crawl नहीं कर पाते। इसमें password-protected pages, private databases, email inboxes, banking portals शामिल हैं। Surface Web से बहुत बड़ा है।",
      "difficulty": "hard",
      "hint": "वेब का 'अदृश्य' भाग।",
      "points": 20
    },
    {
      "question": "Dark Web क्या है?",
      "options": ["Deep web का एक छोटा हिस्सा जिसे special software (Tor) से access किया जाता है और जो anonymous होता है", "Illegal केवल", "Surface web", "Social media"],
      "answer": 0,
      "explanation": "Dark Web Deep Web का एक छोटा सबसेट है जिसे Tor Browser जैसे specialized tools से ही access किया जा सकता है। यह intentionally hidden और anonymous होता है। इसमें कानूनी और illegal दोनों तरह की चीज़ें हैं।",
      "difficulty": "hard",
      "hint": "Requires Tor browser।",
      "points": 20
    },
    {
      "question": "Tor Browser किसके लिए उपयोग होता है?",
      "options": ["Anonymous रूप से internet access करने के लिए", "Internet speed बढ़ाने के लिए", "Virus हटाने के लिए", "Downloads के लिए"],
      "answer": 0,
      "explanation": "Tor (The Onion Router) Browser आपके traffic को multiple servers (nodes) से bounce करता है और encrypt करता है, जिससे आपकी identity (IP address) hidden रहती है। Dark Web access के लिए प्रयोग होता है।",
      "difficulty": "hard",
      "hint": "Anonymous browsing।",
      "points": 20
    },
    {
      "question": "Internet के लिए कौन सा organization domain names और IP addresses manage करता है?",
      "options": ["ICANN (Internet Corporation for Assigned Names and Numbers)", "ISOC", "IETF", "W3C"],
      "answer": 0,
      "explanation": "ICANN global domain name system (DNS), IP addresses, और protocol parameters को coordinate करता है। यह a non-profit organization है।",
      "difficulty": "hard",
      "hint": "Internet का 'पता' देने वाला।",
      "points": 20
    },
    {
      "question": ".com, .org, .in जैसे extensions क्या कहलाते हैं?",
      "options": ["TLD (Top Level Domain)", "SLD (Second Level Domain)", "Subdomain", "Domain name"],
      "answer": 0,
      "explanation": "TLD (Top Level Domain) domain name का last part होता है। Generic TLDs: .com, .org, .net. Country code TLDs: .in (India), .us, .uk, .ca। Sponsored TLDs: .edu, .gov, .mil।",
      "difficulty": "medium",
      "hint": "Dot के बाद वाला हिस्सा।",
      "points": 15
    },
    {
      "question": ".in domain किस देश का है?",
      "options": ["India", "Indonesia", "Iran", "Iceland"],
      "answer": 0,
      "explanation": ".in India का country code top-level domain (ccTLD) है। इसे INRegistry (NIXI) manage करता है।",
      "difficulty": "easy",
      "hint": "India का code।",
      "points": 10
    },
    {
      "question": "Blog क्या है?",
      "options": ["Website या webpage जहाँ व्यक्ति अपने विचार, जानकारी regularly post करता है", "Social media", "Search engine", "Email service"],
      "answer": 0,
      "explanation": "Blog (Web Log) एक प्रकार की website है जहाँ व्यक्ति (blogger) articles (posts) लिखता है। Comments, categories, tags जैसे features होते हैं।",
      "difficulty": "easy",
      "hint": "Online diary/journal।",
      "points": 10
    },
    {
      "question": "वेबसाइट और वेब पेज में क्या अंतर है?",
      "options": ["Website multiple pages (पूरी site), Webpage एक single page", "दोनों एक हैं", "Webpage bigger है", "Website sirf homepage है"],
      "answer": 0,
      "explanation": "Website वेब पेजों का एक collection है (जैसे flipkart.com, google.com)। Webpage एक single document है (जैसे flipkart.com/mobiles पर एक webpage)।",
      "difficulty": "easy",
      "hint": "Website किताब है, webpage उसका एक पन्ना।",
      "points": 10
    },
    {
      "question": "Web Server क्या है?",
      "options": ["Software/hardware जो web pages को internet पर serve करता है (store और deliver करता है)", "Browser", "Search engine", "Database"],
      "answer": 0,
      "explanation": "Web server एक computer और software है जो HTTP requests को handle करता है। जब आप URL type करते हैं, server आपको webpage (HTML, images) भेजता है। Examples: Apache, Nginx, IIS।",
      "difficulty": "medium",
      "hint": "जहाँ websites रहती हैं।",
      "points": 15
    },
    {
      "question": "Client-Server model क्या है?",
      "options": ["Client (browser) request भेजता है, Server response भेजता है", "Client सब कुछ करता है", "Server सब कुछ करता है", "Peer to peer model"],
      "answer": 0,
      "explanation": "Client-Server model में client (जैसे browser, email client) server को request भेजता है और server response (webpage, email) return करता है। इंटरनेट इसी model पर काम करता है।",
      "difficulty": "medium",
      "hint": "Request → Response।",
      "points": 15
    },
    {
      "question": "P2P (Peer to Peer) network क्या है?",
      "options": ["Devices एक दूसरे से directly connect होते हैं बिना central server के", "Client-Server model", "Internet model", "Cloud model"],
      "answer": 0,
      "explanation": "P2P नेटवर्क में सभी devices (peers) equal होते हैं और बिना central server के files/resources share करते हैं। Examples: BitTorrent, blockchain, Skype (old version)।",
      "difficulty": "hard",
      "hint": "सब बराबर, कोई king नहीं।",
      "points": 20
    },
    {
      "question": "Streaming क्या है?",
      "options": ["Media (video, audio) को real-time में play करना बिना पूरा download किए", "Downloading", "Uploading", "Browsing"],
      "answer": 0,
      "explanation": "Streaming media को chunks में receive करके real-time में play करता है। आप पूरी file download होने का इंतजार नहीं करते। बस buffer होता है। Examples: YouTube, Netflix, Spotify, Hotstar।",
      "difficulty": "easy",
      "hint": "रुको मत, देखते जाओ।",
      "points": 10
    },
    {
      "question": "Buffer क्या होता है?",
      "options": ["Temporary storage जहाँ streaming media का data पहले से load रहता है smooth playback के लिए", "Hard disk", "RAM का हिस्सा", "Cache"],
      "answer": 0,
      "explanation": "Buffer एक temporary storage area है। Streaming में buffer media data को ahead में load करता है ताकि network slow होने पर playback रुके नहीं।",
      "difficulty": "medium",
      "hint": "Video चलने से पहले 'loading' circle।",
      "points": 15
    },
    {
      "question": "आपके घर पर इंटरनेट कनेक्शन कैसे आता है? (में से एक तरीका)",
      "options": ["FTTH (Fiber to the Home)", "DSL (phone line)", "Cable broadband", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "कई तरीके: Fiber optic (सबसे तेज़, Jio Fiber, Airtel Xstream), DSL (phone line, BSNL), Cable broadband (local cable वाला), Mobile hotspot, Satellite, 5G/4G routers।",
      "difficulty": "easy",
      "hint": "Wire या wireless।",
      "points": 10
    },
    {
      "question": "Fiber optic internet क्यों बेहतर है?",
      "options": ["Faster speed, lower latency, more reliable, no electrical interference", "सस्ता है", "आसान है", "पुराना तकनीक है"],
      "answer": 0,
      "explanation": "Fiber optic cable glass fibers के माध्यम से light signals की मदद से data transfer करती है। यह copper cables (DSL, cable) से बहुत तेज़ (up to 1-10 Gbps), low latency, और distance पर signal degrade नहीं होता।",
      "difficulty": "medium",
      "hint": "Light speed internet।",
      "points": 15
    },
    {
      "question": "Mobile Internet में 4G और 5G में क्या अंतर है?",
      "options": ["5G बहुत तेज़ (10-100x), कम latency (1ms), ज्यादा devices support", "4G faster है", "Both same", "5G slower है"],
      "answer": 0,
      "explanation": "5G (Fifth Generation) 4G से बहुत तेज़ है (up to 10-20 Gbps vs 4G max 1 Gbps), latency 1ms से कम (4G ~30-50ms), और ज्यादा devices (IoT) support कर सकता है।",
      "difficulty": "medium",
      "hint": "5G = future of connectivity।",
      "points": 15
    },
    {
      "question": "Mobile hotspot क्या है?",
      "options": ["अपने phone के internet को WiFi के जरिए दूसरे devices के साथ share करना", "Public WiFi", "Bluetooth tethering", "USB tethering"],
      "answer": 0,
      "explanation": "Mobile hotspot आपके phone के mobile data को WiFi network में बदल देता है, जिससे laptop, tablet, दूसरे phones internet use कर सकते हैं।",
      "difficulty": "easy",
      "hint": "Phone ko router बनाओ।",
      "points": 10
    },
    {
      "question": "Tethering क्या है?",
      "options": ["Device के internet को दूसरे device के साथ share करना (USB, Bluetooth, WiFi)", "Internet बंद करना", "VPN use करना", "Proxy use करना"],
      "answer": 0,
      "explanation": "Tethering का मतलब है अपने phone या tablet के internet connection को दूसरे device (laptop/computer) के साथ share करना। तरीके: USB tethering (cable), Bluetooth tethering, WiFi hotspot।",
      "difficulty": "medium",
      "hint": "Internet sharing।",
      "points": 15
    },
    {
      "question": "Public WiFi networks (cafe, airport) safe क्यों नहीं होते?",
      "options": ["Encryption नहीं होती, hackers आपका data आसानी से देख सकते हैं (MITM attacks)", "Slow होते हैं", "Paid होते हैं", "Malware होता है"],
      "answer": 0,
      "explanation": "Public WiFi अक्सर open (unencrypted) होते हैं या encryption weak होती है। Hackers man-in-the-middle (MITM) attack करके आपका traffic (passwords, emails) आसानी से देख सकते हैं। VPN use करें।",
      "difficulty": "medium",
      "hint": "Cafe में बैंकिंग मत करो।",
      "points": 15
    },
    {
      "question": "Mbps और MBps में क्या अंतर है?",
      "options": ["Mbps = Megabits per second, MBps = MegaBytes per second (1 Byte = 8 bits)", "दोनों एक हैं", "Mbps faster है", "MBps faster है"],
      "answer": 0,
      "explanation": "ISPs usually Mbps (megabits per second) में speed बताते हैं। लेकिन download speed MBps (megabytes per second) में दिखती है। 8 Mbps = 1 MBps। 50 Mbps connection से ~6.25 MB/s download speed।",
      "difficulty": "hard",
      "hint": "big B = Bytes (×8), small b = bits।",
      "points": 20
    },
    {
      "question": "Data cap (Fair Usage Policy) क्या है?",
      "options": ["आपके monthly download limit (जितना data use कर सकते हैं उससे ज्यादा पर speed slow हो जाती है)", "Internet speed", "Data security", "VPN limit"],
      "answer": 0,
      "explanation": "Data cap (FUP) आपको एक निश्चित amount data (जैसे 1000 GB per month) देता है। उसके बाद speed 1-2 Mbps पर गिर जाती है। Unlimited plans में भी often FUP होता है।",
      "difficulty": "medium",
      "hint": "Limit cross करने पर internet slow।",
      "points": 15
    },
    {
      "question": "What is 'Ping' in internet terms?",
      "options": ["Command to test network latency (response time in ms)", "Download speed", "Upload speed", "Data limit"],
      "answer": 0,
      "explanation": "Ping command (ping google.com) measures round-trip time for data packets - जितना कम (under 50ms) gaming और video calls के लिए अच्छा। High ping (150ms+) means lag।",
      "difficulty": "medium",
      "hint": "Internet की 'रिएक्शन टाइम'।",
      "points": 15
    },
    {
      "question": "Jitter क्या है?",
      "options": ["Latency में उतार-चढ़ाव (inconsistent ping)", "High latency", "Low latency", "Packet loss"],
      "answer": 0,
      "explanation": "Jitter ping time का variation है। उदाहरण: कभी 20ms, कभी 200ms - इससे video calls या gaming में problem आती है। Stable connection के लिए jitter कम होना चाहिए।",
      "difficulty": "hard",
      "hint": "Unstable connection का संकेत।",
      "points": 20
    },
    {
      "question": "Packet loss क्या है?",
      "options": ["Data packets destination तक पहुँचने में fail हो जाते हैं", "Slow speed", "High latency", "Network error"],
      "answer": 0,
      "explanation": "Packet loss तब होता है जब data packets रास्ते में खो जाते हैं (1-2% तक ठीक है, 5%+ problem). इससे वेबसाइट slow लोड होती है, voice calls टूटती हैं, files corrupt होती हैं।",
      "difficulty": "hard",
      "hint": "रास्ते में डेटा गुम होना।",
      "points": 20
    },
    {
      "question": "URL encoding क्या है?",
      "options": ["Special characters को % के बाद hex code में बदलना (जैसे space = %20)", "Encryption", "Compression", "Minification"],
      "answer": 0,
      "explanation": "URL में spaces, #, %, & जैसे characters allowed नहीं होते। URL encoding उन्हें % और hex code से replace करता है। Example: 'hello world' → 'hello%20world', '#' → '%23'।",
      "difficulty": "hard",
      "hint": "स्पेस %20 में बदलता है।",
      "points": 20
    },
    {
      "question": "Web hosting क्या है?",
      "options": ["Website की files को store करने की service (किराए की जगह internet पर)", "Domain name registration", "Website design", "SEO"],
      "answer": 0,
      "explanation": "Web hosting एक service है जो आपकी website की files (HTML, images, CSS, JS) को एक server पर रखती है ताकि वे internet पर accessible हों। Types: Shared, VPS, Dedicated, Cloud hosting।",
      "difficulty": "medium",
      "hint": "Website का घर।",
      "points": 15
    },
    {
      "question": "CMS (Content Management System) क्या है?",
      "options": ["Software जिससे बिना coding के website बना और manage कर सकते हैं (WordPress, Joomla, Drupal)", "Hosting control panel", "Domain registrar", "SEO tool"],
      "answer": 0,
      "explanation": "CMS आपको HTML/CSS लिखे बिना websites बनाने और manage करने देता है। Examples: WordPress (most popular), Joomla, Drupal, Shopify (ecommerce).",
      "difficulty": "medium",
      "hint": "बिना coding के वेबसाइट।",
      "points": 15
    },
    {
      "question": "कौन सा CMS internet पर सबसे ज्यादा use होता है?",
      "options": ["WordPress", "Joomla", "Drupal", "Shopify"],
      "answer": 0,
      "explanation": "WordPress दुनिया की लगभग 40%+ websites पर use होता है। यह free, open-source, और बहुत flexible है। Blogs से लेकर ecommerce sites तक।",
      "difficulty": "easy",
      "hint": "सबसे popular CMS।",
      "points": 10
    },
    {
      "question": "CDN (Content Delivery Network) क्या है?",
      "options": ["दुनिया भर के servers का network जो content (images, videos) को users के close से deliver करता है, जिससे speed बढ़ती है", "Cloud storage", "Web hosting", "Domain service"],
      "answer": 0,
      "explanation": "CDN (जैसे Cloudflare, Akamai, Amazon CloudFront) आपके website के static content (images, CSS, JS) को दुनिया भर के servers पर copy (cache) करता है। User जहाँ से access करता है, nearest server से content आता है - speed बहुत बढ़ जाती है।",
      "difficulty": "hard",
      "hint": "Content को ज्यादा पास ले जाना।",
      "points": 20
    },
    {
      "question": "POP (Point of Presence) क्या होता है?",
      "options": ["ISP का वह physical location जहाँ से internet service किसी area में provide होता है", "Email protocol", "Post office protocol", "Network switch"],
      "answer": 0,
      "explanation": "POP वह जगह है जहाँ ISP (Jio, Airtel, etc.) अपना equipment (routers, switches) रखता है और आपको connection देता है। ज्यादा POPs का मतलब better coverage।",
      "difficulty": "hard",
      "hint": "ISP का local office (technical)।",
      "points": 20
    },
    {
      "question": "IXP (Internet Exchange Point) क्या है?",
      "options": ["Physical infrastructure जहाँ different ISPs आपस में जुड़ते हैं और traffic exchange करते हैं, जिससे latency कम होती है", "ISP का POP", "Data center", "Server farm"],
      "answer": 0,
      "explanation": "IXP (जैसे NIXI - National Internet Exchange of India) वह जगह है जहाँ multiple ISPs (Airtel, Jio, BSNL) आपस में connect होते हैं। इससे local traffic को बाहर जाने की जरूरत नहीं पड़ती, speed बढ़ती है और cost कम होती है।",
      "difficulty": "hard",
      "hint": "ISPs का आपसी मिलन स्थल।",
      "points": 20
    }
  ],
  "6. Search Engines and Effective Web Search": [
    {
      "question": "Search Engine का मुख्य कार्य क्या है?",
      "options": ["Internet पर information को index करना और relevant results दिखाना", "Email भेजना", "Social media चलाना", "Games खेलना"],
      "answer": 2,
      "explanation": "Search Engine (जैसे Google, Bing) billions of web pages को crawl और index करता है। जब आप search करते हैं, यह algorithm से most relevant results दिखाता है।",
      "difficulty": "easy",
      "hint": "ज्ञान का भंडार खोलने वाला।",
      "points": 10
    },
    {
      "question": "दुनिया का सबसे लोकप्रिय Search Engine कौन सा है?",
      "options": ["Google", "Bing", "Yahoo", "DuckDuckGo"],
      "answer": 1,
      "explanation": "Google दुनिया का सबसे लोकप्रिय search engine है, जिसमें 90% से अधिक market share है।",
      "difficulty": "easy",
      "hint": "गूगल करना common phrase है।",
      "points": 10
    },
    {
      "question": "Microsoft का Search Engine कौन सा है?",
      "options": ["Bing", "Google", "Yahoo", "Ask.com"],
      "answer": 0,
      "explanation": "Bing Microsoft का search engine है। इसे पहले MSN Search और Live Search के नाम से जाना जाता था।",
      "difficulty": "easy",
      "hint": "Microsoft Edge का default search engine।",
      "points": 10
    },
    {
      "question": "DuckDuckGo Search Engine की सबसे बड़ी विशेषता क्या है?",
      "options": ["Privacy (user tracking नहीं करता, no personalized ads)", "Fastest search", "Most results", "Video search"],
      "answer": 3,
      "explanation": "DuckDuckGo users को track नहीं करता, search history save नहीं करता, और personalized ads नहीं दिखाता। इसलिए privacy-concerned users इसे पसंद करते हैं।",
      "difficulty": "medium",
      "hint": "प्राइवेसी चाहिए तो यह।",
      "points": 15
    },
    {
      "question": "SEO (Search Engine Optimization) क्या है?",
      "options": ["Website को search engine rankings में ऊपर लाने की techniques", "Search engine design", "Social media marketing", "Email marketing"],
      "answer": 0,
      "explanation": "SEO वह प्रक्रिया है जिससे website को search engines (Google) के organic (non-paid) results में higher rank मिलता है, जिससे ज्यादा visitors आते हैं।",
      "difficulty": "medium",
      "hint": "Google में first page पर आने का तरीका।",
      "points": 15
    },
    {
      "question": "Google Search में 'site:' operator का क्या उपयोग है?",
      "options": ["एक specific website के अंदर search करना", "Site map देखना", "Website block करना", "Website speed check"],
      "answer": 0,
      "explanation": "site: operator से आप सिर्फ एक specific domain पर search कर सकते हैं। उदाहरण: 'site:wikipedia.org India' से सिर्फ wikipedia.org पर India से related pages दिखेंगे।",
      "difficulty": "medium",
      "hint": "किसी एक वेबसाइट में ढूंढो।",
      "points": 15
    },
    {
      "question": "Google Search में quotes (\" \") का क्या उपयोग है?",
      "options": ["Exact phrase search (शब्दों का exact क्रम)", "शब्दों को बदलना", "शब्दों को छोड़ना", "Synonyms ढूंढना"],
      "answer": 1,
      "explanation": "Double quotes में phrase लिखने से Google उन्हीं words को exactly same order में खोजता है। Example: \"Mahatma Gandhi\" से सिर्फ exact name वाले results।",
      "difficulty": "medium",
      "hint": "बिल्कुल सटीक वाक्य ढूंढना।",
      "points": 15
    },
    {
      "question": "Google Search में '-' (minus) operator का क्या उपयोग है?",
      "options": ["कुछ words को results से exclude करना", "Subtract करना", "Negative search", "Remove spaces"],
      "answer": 0,
      "explanation": "Minus sign (-) उन शब्दों को हटा देता है जो आप results में नहीं चाहते। Example: 'apple -fruit' से apple fruit नहीं दिखेगा, सिर्फ Apple company से related results आएंगे।",
      "difficulty": "medium",
      "hint": "बाहर करना है तो minus।",
      "points": 15
    },
    {
      "question": "Google Search में '*' (asterisk) का क्या उपयोग है?",
      "options": ["Wildcard (unknown word के लिए placeholder)", "Multiply", "All words", "Any character"],
      "answer": 0,
      "explanation": "Asterisk (*) एक wildcard है। आप किसी phrase में * डाल सकते हैं तो Google उस जगह कोई भी शब्द fill करके search करता है। Example: 'ईश्वर * है' से 'ईश्वर सर्वव्यापी है', 'ईश्वर दयालु है' आदि आएंगे।",
      "difficulty": "hard",
      "hint": "कुछ भी आ सकता है।",
      "points": 20
    },
    {
      "question": "Google Search में 'OR' operator का क्या उपयोग है?",
      "options": ["या तो यह शब्द हो या वह शब्द", "AND की तरह", "Exclude करना", "Group करना"],
      "answer": 0,
      "explanation": "OR operator से आप multiple search terms दे सकते हैं। Google कोई भी term match होने पर result दिखाता है। Example: 'Delhi OR Mumbai' से दोनों में से किसी का result आएगा। OR caps में लिखना जरूरी है।",
      "difficulty": "hard",
      "hint": "यह या वो।",
      "points": 20
    },
    {
      "question": "Google Search में 'intitle:' operator क्या करता है?",
      "options": ["Page title में specific word ढूंढता है", "URL में ढूंढता है", "Body में ढूंढता है", "Image alt में ढूंढता है"],
      "answer": 0,
      "explanation": "intitle: operator से आप सिर्फ उन pages को ढूंढते हैं जिनके title (browser tab का text) में आपका search term हो। Example: 'intitle:COVID vaccine'।",
      "difficulty": "hard",
      "hint": "Page के शीर्षक में खोजो।",
      "points": 20
    },
    {
      "question": "Google Search में 'inurl:' operator क्या करता है?",
      "options": ["URL (website address) में specific word ढूंढता है", "Title में ढूंढता है", "Content में ढूंढता है", "File में ढूंढता है"],
      "answer": 0,
      "explanation": "inurl: operator से आप सिर्फ उन pages को ढूंढते हैं जिनके URL में आपका word हो। Example: 'inurl:blog' से सभी URLs में 'blog' word वाले pages।",
      "difficulty": "hard",
      "hint": "Web address में खोजो।",
      "points": 20
    },
    {
      "question": "Google Search में 'filetype:' operator क्या करता है?",
      "options": ["Specific type की files ढूंढता है (PDF, DOC, PPT, XLS)", "File size filter", "File name filter", "File date filter"],
      "answer": 0,
      "explanation": "filetype: (या ext:) operator से आप सिर्फ specific extension वाली files search करते हैं। Example: 'Budget 2024 filetype:pdf' से सिर्फ PDF files दिखेंगी।",
      "difficulty": "medium",
      "hint": "PDF, DOC, PPT ढूंढने के लिए।",
      "points": 15
    },
    {
      "question": "Google Search में 'after:' और 'before:' operators क्या करते हैं?",
      "options": ["Specific date range में results filter करना", "Time travel", "Recent results", "Old results"],
      "answer": 0,
      "explanation": "after: और before: operators से आप specific date range में published pages देख सकते हैं। Example: 'after:2024-01-01 before:2024-12-31'। अलग से Tools → Any time से भी कर सकते हैं।",
      "difficulty": "hard",
      "hint": "तारीख के हिसाब से छानना।",
      "points": 20
    },
    {
      "question": "Google Images में 'Tools' button से क्या कर सकते हैं?",
      "options": ["Image size, color, type, time filter", "Image edit", "Image download", "Image share"],
      "answer": 0,
      "explanation": "Google Images search के बाद 'Tools' button से आप size (Large, Medium), color (Black/white, Transparent), type (Face, Photo, Clip art), time (Past hour, Past 24 hours, etc.) filter कर सकते हैं।",
      "difficulty": "easy",
      "hint": "जरूरत के हिसाब से image filter।",
      "points": 10
    },
    {
      "question": "Google Search में 'related:' operator क्या करता है?",
      "options": ["Similar websites ढूंढता है", "Related keywords", "Related images", "Related news"],
      "answer": 0,
      "explanation": "related: operator से आप उन websites को ढूंढ सकते हैं जो किसी given website के समान हैं। Example: 'related:amazon.com' से Flipkart, eBay जैसी e-commerce sites दिखेंगी।",
      "difficulty": "hard",
      "hint": "जैसी ये वेबसाइट, वैसी और।",
      "points": 20
    },
    {
      "question": "Google Scholar क्या है?",
      "options": ["Academic papers, theses, books, articles के लिए search engine", "School search", "Student search", "Learning platform"],
      "answer": 0,
      "explanation": "Google Scholar (scholar.google.com) research papers, academic journals, theses, conference papers, और books search करने के लिए है। यह scholarly literature के लिए specialist search engine है।",
      "difficulty": "medium",
      "hint": "Research के लिए।",
      "points": 15
    },
    {
      "question": "Google Books क्या है?",
      "options": ["Books का search और preview platform", "Library catalog", "Book store", "PDF search"],
      "answer": 0,
      "explanation": "Google Books (books.google.com) आपको books के अंदर search करने और preview (कुछ पन्ने) देखने की सुविधा देता है। Public domain books पूरी download की जा सकती हैं।",
      "difficulty": "medium",
      "hint": "किताबों के अंदर ढूंढो।",
      "points": 15
    },
    {
      "question": "Google News क्या है?",
      "options": ["समाचार articles का aggregation platform", "Newspaper", "TV news", "Radio news"],
      "answer": 0,
      "explanation": "Google News (news.google.com) दुनिया भर के news sources से headlines और articles को automatically aggregate और categorize करता है। Personalized news feed भी बना सकते हैं।",
      "difficulty": "easy",
      "hint": "सारी खबरें एक जगह।",
      "points": 10
    },
    {
      "question": "Google Alerts क्या है?",
      "options": ["नए search results के लिए email या notification भेजना", "Security alert", "Virus alert", "System alert"],
      "answer": 0,
      "explanation": "Google Alerts (google.com/alerts) आपको अपने chosen keywords के नए results (news, web pages, blogs) मिलने पर email या RSS feed भेजता है। Brand monitoring, research, news tracking के लिए उपयोगी।",
      "difficulty": "hard",
      "hint": "Something new हो तो बता दे।",
      "points": 20
    },
    {
      "question": "Google Trends क्या है?",
      "options": ["Search terms की popularity over time दिखाता है", "Fashion trends", "Stock market trends", "News trends"],
      "answer": 0,
      "explanation": "Google Trends (trends.google.com) किसी भी search term की relative popularity दिखाता है (0-100 scale). आप compare कर सकते हैं कि कौन सा term ज्यादा search हो रहा है, किस region में, किस time period में।",
      "difficulty": "medium",
      "hint": "लोग क्या ढूंढ रहे हैं।",
      "points": 15
    },
    {
      "question": "Google में 'I'm Feeling Lucky' button क्या करता है?",
      "options": ["सीधा पहले search result पर ले जाता है", "Random website खोलता है", "Lucky draw", "Game खेलाता है"],
      "answer": 0,
      "explanation": "I'm Feeling Lucky button bypasses the search results page and directly opens the top-ranked website for your query. It's mostly for fun; Google estimates it costs them millions in lost ad revenue.",
      "difficulty": "medium",
      "hint": "सीधा नंबर वन पर।",
      "points": 15
    },
    {
      "question": "Google Keyword Planner किसके लिए है?",
      "options": ["SEO और Google Ads के लिए keywords की search volume और competition दिखाना", "Content writing", "Website design", "Email marketing"],
      "answer": 0,
      "explanation": "Google Keyword Planner एक free tool है जो advertisers और SEO professionals को keywords की monthly search volume, competition level, और suggested bid दिखाता है। यह Google Ads account के साथ accessible है।",
      "difficulty": "hard",
      "hint": "लोग क्या सर्च कर रहे हैं।",
      "points": 20
    },
    {
      "question": "Google Search Console क्या है?",
      "options": ["Website owners के लिए free tool जो search performance, indexing issues, और errors दिखाता है", "Search engine", "Analytics tool", "Ad tool"],
      "answer": 0,
      "explanation": "Google Search Console (formerly Webmaster Tools) आपको देखने देता है कि Google आपकी website को कैसे देखता है - कौन से keywords से visitors आ रहे हैं, कितने pages indexed हैं, क्या errors (404, crawl issues) हैं।",
      "difficulty": "hard",
      "hint": "अपनी साइट की Google में रिपोर्ट।",
      "points": 20
    },
    {
      "question": "Google में 'define:' operator क्या करता है?",
      "options": ["शब्द की definition दिखाता है", "Dictionary", "Meaning", "Translation"],
      "answer": 0,
      "explanation": "define: शब्द के साथ search करने पर Google dictionary definition, synonyms, और example sentences दिखाता है। Example: 'define:procrastination'।",
      "difficulty": "easy",
      "hint": "मतलब जानने के लिए।",
      "points": 10
    },
    {
      "question": "Google में Calculator कैसे use करें?",
      "options": ["सीधे search box में गणित लिखें (जैसे 25*4+10)", "Google Calculator app", "Search 'calculator'", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google के search box में आप सीधे mathematical expressions (25*4+10, sqrt(144), sin(30), 5^3, 10! - factorial) type करके calculate कर सकते हैं।",
      "difficulty": "easy",
      "hint": "कैलकुलेटर ढूंढने की जरूरत नहीं।",
      "points": 10
    },
    {
      "question": "Google में Unit Conversion कैसे करें?",
      "options": ["Search box में '10 km to miles' लिखें", "Convert app", "Search 'unit converter'", "उपरोक्त सभी"],
      "answer": 0,
      "explanation": "Google आपको सीधे search box में unit conversions (currency, length, weight, temperature, area, volume, speed, time) करने देता है। Example: '100 USD to INR', '32°C to °F', '5 feet to cm'।",
      "difficulty": "easy",
      "hint": "गणित का झंझट नहीं।",
      "points": 10
    },
    {
      "question": "Google में Time और World Clock कैसे देखें?",
      "options": ["Search 'time in Tokyo' या 'New York time'", "Search 'world clock'", "Google Calendar", "Both A and B"],
      "answer": 3,
      "explanation": "Google में 'time in [city name]' लिखने पर वहाँ का current time दिखता है। 'world clock' search से multiple cities के times compare कर सकते हैं।",
      "difficulty": "easy",
      "hint": "दुनिया भर का समय।",
      "points": 10
    },
    {
      "question": "Google में Weather कैसे check करें?",
      "options": ["Search 'weather in [city name]'", "Search 'weather' (auto detects your location)", "Google Assistant", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google search पर 'weather Delhi' लिखने से temperature, humidity, wind speed, 7-day forecast दिखता है। 'weather' सिर्फ लिखने से आपकी current location का weather दिखता है।",
      "difficulty": "easy",
      "hint": "मौसम जानना है तो।",
      "points": 10
    },
    {
      "question": "Google में Flip a coin कैसे करें?",
      "options": ["Search 'flip a coin'", "Search 'coin toss'", "Google Assistant से कहें", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google में 'flip a coin' या 'coin toss' search करते ही एक animated coin flip होता है और Heads या Tails result आता है।",
      "difficulty": "easy",
      "hint": "निर्णय लेने का मजेदार तरीका।",
      "points": 10
    },
    {
      "question": "Google में Roll a dice कैसे करें?",
      "options": ["Search 'roll a die' या 'roll a dice'", "विजेट्स से", "गूगल असिस्टेंट से", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google में 'roll a dice' search करते ही एक animated dice roll होता है और random number (1-6) दिखाता है। आप multiple dice भी roll कर सकते हैं (जैसे 'roll 2 dice')।",
      "difficulty": "easy",
      "hint": "पासा फेंको।",
      "points": 10
    },
    {
      "question": "Google में 'random number generator' कैसे use करें?",
      "options": ["Search 'random number generator' और range set करें", "Search 'random number between X and Y'", "Google Assistant", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google में 'random number between 1 and 100' search करने पर एक random number generate होता है। आप range customize कर सकते हैं।",
      "difficulty": "easy",
      "hint": "कोई भी नंबर चाहिए।",
      "points": 10
    },
    {
      "question": "Google में 'timer' कैसे set करें?",
      "options": ["Search 'set timer for X minutes'", "Search 'timer' और adjust करें", "Google Assistant 'set timer'", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google में 'set timer for 10 minutes' search करने पर timer start हो जाता है और time complete होने पर sound बजता है।",
      "difficulty": "easy",
      "hint": "समय याद दिलाने के लिए।",
      "points": 10
    },
    {
      "question": "Google में 'stopwatch' कैसे use करें?",
      "options": ["Search 'stopwatch'", "Search 'count up timer'", "Google Assistant", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google में 'stopwatch' search करते ही एक stopwatch खुल जाता है जिसे start, pause, lap, reset कर सकते हैं।",
      "difficulty": "easy",
      "hint": "समय मापने के लिए।",
      "points": 10
    },
    {
      "question": "Google में Image Search करने पर 'Search by image' (Reverse Image Search) कैसे करें?",
      "options": ["Camera icon पर click → image upload करें या image URL paste करें", "Right click on image", "Drag and drop image", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Reverse Image Search से आप किसी image के बारे में information (कहाँ और कहाँ use हुई, similar images, higher resolution versions) पता कर सकते हैं। यह fake profile और duplicate content detect करने में उपयोगी है।",
      "difficulty": "medium",
      "hint": "तस्वीर से ढूंढो।",
      "points": 15
    },
    {
      "question": "Reverse Image Search का उपयोग किसलिए करते हैं?",
      "options": ["Fake profiles detect करना", "Duplicate images ढूंढना", "Original source पता करना", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Reverse image search से पता चलता है कि कोई image कहाँ-कहाँ internet पर use हुई है। इससे fake social media profiles, image theft, और misinformation (old image को current event से जोड़ना) पकड़ी जा सकती है।",
      "difficulty": "medium",
      "hint": "Photo की सच्चाई जानो।",
      "points": 15
    },
    {
      "question": "Google में मूवी showtimes कैसे देखें?",
      "options": ["Search 'movies near me' या 'movie name showtimes'", "Search 'cinema name'", "Google Maps", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google में 'movies near me' search करने पर पास के cinemas की movie listings और showtimes दिखती हैं। किसी specific movie का नाम लिखने पर उसकी showtimes, trailers, ratings, और cinema locations मिलते हैं।",
      "difficulty": "easy",
      "hint": "फिल्म कहाँ लग रही है।",
      "points": 10
    },
    {
      "question": "Google में Flight status कैसे check करें?",
      "options": ["Search 'flight number' (जैसे AI 101)", "Search 'flight status'", "Google Flights", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google में flight number (जैसे 'AI 101' या 'Air India 101') search करने पर current status, departure/arrival times, gate, और delay information दिखती है।",
      "difficulty": "easy",
      "hint": "विमान कहाँ है।",
      "points": 10
    },
    {
      "question": "Google में Sports scores कैसे देखें?",
      "options": ["Search 'team name' (जैसे 'India cricket' या 'RCB')", "Search 'scores'", "Search 'IPL 2024'", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google में किसी sports team या tournament का नाम search करने पर live scores, match schedule, points table, और upcoming matches दिखते हैं।",
      "difficulty": "easy",
      "hint": "खेल का लाइव स्कोर।",
      "points": 10
    },
    {
      "question": "Google में Stock prices कैसे देखें?",
      "options": ["Search 'stock symbol' (जैसे 'RELIANCE', 'AAPL')", "Search 'stock price'", "Google Finance", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google में company name या stock symbol (RELIANCE, TCS, AAPL, MSFT) search करने पर current price, graph, market cap, P/E ratio, और 52-week high/low दिखते हैं।",
      "difficulty": "easy",
      "hint": "शेयर बाजार का भाव।",
      "points": 10
    },
    {
      "question": "Google में Birthday और Holiday calendar कैसे देखें?",
      "options": ["Search 'celebrity name birthday'", "Search 'public holidays 2025 India'", "Search 'today in history'", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "आप किसी celebrity का birthday (जैसे 'Amitabh Bachchan birthday'), country के public holidays, या 'today in history' search कर सकते हैं।",
      "difficulty": "easy",
      "hint": "कब क्या है।",
      "points": 10
    },
    {
      "question": "Google में Translate कैसे करें?",
      "options": ["Search 'translate [word] to [language]'", "Google Translate website", "Search box में directly translation", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google में 'hello in Hindi' या 'translate good morning to French' लिखने पर सीधा translation दिखता है। या translate.google.com पर जाकर full sentences translate कर सकते हैं।",
      "difficulty": "easy",
      "hint": "भाषा बदलो।",
      "points": 10
    },
    {
      "question": "Voice Search कैसे use करें?",
      "options": ["Google app में microphone icon", "Desktop Chrome में microphone icon (google.com पर)", "Hey Google / Ok Google", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Mobile Google app या browser में microphone icon पर click करके बोलें, तो Google आपकी voice को text में convert करके search करता है। 'Ok Google' या 'Hey Google' hotword से bina touch किए search कर सकते हैं।",
      "difficulty": "easy",
      "hint": "बोलकर सर्च करो।",
      "points": 10
    },
    {
      "question": "Google में हिंदी या अन्य भाषाओं में कैसे search करें?",
      "options": ["सीधे हिंदी में लिखें (Google हिंदी results भी समझता है)", "Settings में language change करें", "हिंदी में बोलें (voice search)", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google हिंदी और कई other languages में search को support करता है। आप देवनागरी में लिख सकते हैं या Roman (Hindi) में (जैसे 'aaj ka mausam')। Google आपको हिंदी में relevant results दिखाएगा।",
      "difficulty": "easy",
      "hint": "अपनी भाषा में सर्च करो।",
      "points": 10
    },
    {
      "question": "Google SafeSearch क्या है?",
      "options": ["Adult content को filter करने की setting", "Virus protection", "Privacy setting", "Parental control"],
      "answer": 0,
      "explanation": "SafeSearch एक Google setting है जो explicit (adult) content को search results से filter (block) करती है। Parents इसे on करके बच्चों को inappropriate content से बचा सकते हैं।",
      "difficulty": "medium",
      "hint": "गंदा कंटेंट न दिखे।",
      "points": 15
    },
    {
      "question": "Google SafeSearch कैसे enable करें?",
      "options": ["Settings → SafeSearch → Filter (On)", "Search results page के ऊपर Settings → SafeSearch", "Google app → Settings → General → SafeSearch", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google search page के ऊपर right corner में Settings (gear icon) → SafeSearch में Filter (On) select करें। यह device पर saved रहता है। Google account में भी lock कर सकते हैं।",
      "difficulty": "easy",
      "hint": "बच्चों के लिए on कर दो।",
      "points": 10
    },
    {
      "question": "Private/Incognito Mode क्या होता है?",
      "options": ["Browsing history, cookies, form data save नहीं होती (local level पर)", "100% anonymous नहीं है (ISP और websites देख सकते हैं)", "Chrome में Ctrl+Shift+N, Firefox में Ctrl+Shift+P", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Incognito/Private mode आपके device पर browsing history, cookies, और form data को save नहीं करता। यह आपको anonymous नहीं बनाता - ISP, employer, और visited websites आपकी activity देख सकते हैं। VPN use करें।",
      "difficulty": "medium",
      "hint": "बिना निशान के।",
      "points": 15
    },
    {
      "question": "Google पर अपनी search history कैसे देखें और delete करें?",
      "options": ["myactivity.google.com", "Google app → Search history", "Browser history भी check कर सकते हैं", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "myactivity.google.com पर जाकर आप अपनी सारी Google search history (day-wise, time-wise) देख सकते हैं। यहाँ से individual items delete कर सकते हैं, या auto-delete schedule (3/18/36 months) set कर सकते हैं।",
      "difficulty": "medium",
      "hint": "गूगल को बताओ क्या याद रखना है।",
      "points": 15
    },
    {
      "question": "Google में 'People also ask' section क्या है?",
      "options": ["Related questions that other users have searched", "Advertisement", "Sponsored content", "User comments"],
      "answer": 0,
      "explanation": "People Also Ask (PAA) एक SERP feature है जो आपके search query से related सवाल और unclickable dropdown answers दिखाता है। यह आपको topic के different angles explore करने में मदद करता है।",
      "difficulty": "easy",
      "hint": "लोग और क्या पूछते हैं।",
      "points": 10
    },
    {
      "question": "Google में 'Featured Snippet' क्या है?",
      "options": ["Search results के ऊपर एक box जो question का सीधा answer देता है (answer box)", "Advertisement", "News box", "Image carousel"],
      "answer": 0,
      "explanation": "Featured Snippet (Answer Box) Google का वह result है जो search query का सीधा जवाब एक box में दिखाता है - अक्सर paragraph, list, या table के रूप में। यह #0 position (organic results से ऊपर) होता है।",
      "difficulty": "medium",
      "hint": "Google सीधा जवाब देता है।",
      "points": 15
    },
    {
      "question": "Google में 'Knowledge Panel' क्या है?",
      "options": ["Right side का box जो person, place, organization की summary (bio, image, social links, website) दिखाता है", "Left side results", "Ad panel", "Search filters"],
      "answer": 0,
      "explanation": "Knowledge Panel search results के right side में (desktop) दिखता है। इसमें famous personalities, places, movies, organizations के बारे में structured information होती है - photos, birth/death date, spouse, children, social media links, Wikipedia excerpt, etc.",
      "difficulty": "medium",
      "hint": "Quick facts।",
      "points": 15
    },
    {
      "question": "Google में 'Local Pack' क्या है?",
      "options": ["Local businesses के 3 results map के साथ (जैसे 'restaurants near me')", "Advertisement", "News", "Videos"],
      "answer": 0,
      "explanation": "Local Pack map के साथ 3 local business listings show करता है जब आप 'near me' keywords (पास के रेस्टोरेंट, डॉक्टर, स्कूल) search करते हैं। इसमें name, rating, reviews, address, phone number, और दूरी (distance) होती है।",
      "difficulty": "easy",
      "hint": "आस-पास क्या है।",
      "points": 10
    },
    {
      "question": "Google में 'Video Carousel' क्या है?",
      "options": ["Horizontal scrollable videos (mostly YouTube)", "Images", "News articles", "Shopping results"],
      "answer": 0,
      "explanation": "Video Carousel search results में horizontal scrollable row of video thumbnails दिखाता है (mostly YouTube videos)। Recipe, tutorial, music, news queries के लिए common है।",
      "difficulty": "easy",
      "hint": "वीडियो की कतार।",
      "points": 10
    },
    {
      "question": "Google में 'Sitelinks' क्या हैं?",
      "options": ["Main result के नीचे internal page links (जैसे Flipkart के नीचे Mobiles, Electronics links)", "External links", "Ad links", "Social links"],
      "answer": 0,
      "explanation": "Sitelinks आपको main website result के नीचे उसी website के internal pages के direct links देते हैं, जिससे users quickly desired page पर जा सकते हैं। यह auto-generated होते हैं।",
      "difficulty": "easy",
      "hint": "वेबसाइट के अंदर के पन्ने।",
      "points": 10
    },
    {
      "question": "Google में 'Sponsored' label क्या दर्शाता है?",
      "options": ["Advertisement (paid search result)", "Organic result", "Featured result", "Popular result"],
      "answer": 0,
      "explanation": "Sponsored (या 'Ad') label उन search results पर होता है जिनके लिए advertiser ने Google Ads में payment किया है। ये organic (non-paid) results से अलग होते हैं।",
      "difficulty": "easy",
      "hint": "पैसे देकर आया हुआ।",
      "points": 10
    },
    {
      "question": "Google में 'Organic Results' क्या होते हैं?",
      "options": ["Non-paid search results (Google की algorithm से determine होते हैं)", "Ads", "Sponsored results", "Paid results"],
      "answer": 0,
      "explanation": "Organic results वे search results होते हैं जिनके लिए website owner Google को payment नहीं करता। ये relevance और quality के आधार पर Google के algorithm के द्वारा rank किए जाते हैं। SEO यहीं improve करता है।",
      "difficulty": "easy",
      "hint": "बिना पैसे के नंबर वन।",
      "points": 10
    },
    {
      "question": "Google Search को 'safer' कैसे बनाएं?",
      "options": ["SafeSearch on करें", "HTTPS websites पर ध्यान दें", "Suspicious links पर click न करें", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google search को safe रखने के लिए SafeSearch on करें, unverified websites से बचें, suspicious redirects पर click न करें, और हमेशा HTTPS sites को प्राथमिकता दें।",
      "difficulty": "easy",
      "hint": "सुरक्षित रहो।",
      "points": 10
    },
    {
      "question": "किसी पुराने संस्करण या कैश्ड (cached) webpage को कैसे देखें?",
      "options": ["Search 'cache:URL' (जैसे cache:example.com)", "Result के आगे तीन dots → Cached", "Google search के URL के साथ &strip=1&vwsrc=0", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Google अपने index में web pages का cached (snapshot) रखता है। 'cache:' operator या search result के तीन dots में 'Cached' button से आप पुराना version देख सकते हैं, भले ही current page down हो।",
      "difficulty": "hard",
      "hint": "पेज डाउन हो तो यहाँ से देखो।",
      "points": 20
    },
    {
      "question": "Google में 'related:' operator क्या करता है? (पुनः सुदृढ़ीकरण)",
      "options": ["Similar websites ढूंढना", "Synonyms", "Related keywords", "Related images"],
      "answer": 0,
      "explanation": "related:example.com से आप उन websites को ढूंढ सकते हैं जो example.com के समान topic या niche में हैं। यह competitor research के लिए उपयोगी है।",
      "difficulty": "hard",
      "hint": "जैसी ये वेबसाइट, वैसी और।",
      "points": 20
    },
    {
      "question": "Boolean Search क्या होता है?",
      "options": ["AND, OR, NOT operators का उपयोग करके search करना", "Math search", "Boolean algebra", "Logic gates"],
      "answer": 0,
      "explanation": "Boolean search आपको AND, OR, NOT (या -) operators से search results को combine या exclude करने देता है। उदाहरण: 'cats AND dogs' (दोनों), 'cars NOT luxury' (luxury exclude), 'Delhi OR Mumbai' (any one)।",
      "difficulty": "hard",
      "hint": "AND, OR, NOT से ढूंढो।",
      "points": 20
    },
    {
      "question": "Google में 'inposttitle:' operator क्या करता है? (कुछ पुराने Google में)",
      "options": ["Blog post के title में search करना", "URL में search", "Content में search", "Comments में search"],
      "answer": 0,
      "explanation": "inposttitle: operator (जो अब mostly deprecated है) blog posts के titles के अंदर search करता था। अब intitle: mostly sufficient है।",
      "difficulty": "hard",
      "hint": "ब्लॉग पोस्ट के शीर्षक में ढूंढो।",
      "points": 20
    },
    {
      "question": "Yahoo Search Engine अब किस पर based है?",
      "options": ["Bing", "Google", "Yandex", "Own algorithm"],
      "answer": 0,
      "explanation": "Yahoo Search currently Microsoft's Bing search engine पर based है। Yahoo अपना search crawler नहीं रखता, बल्कि Bing के results को serve करता है।",
      "difficulty": "hard",
      "hint": "Microsoft का दूसरा नाम।",
      "points": 20
    },
    {
      "question": "Ask.com (पहले Ask Jeeves) किसलिए famous था?",
      "options": ["Natural language questions (Question/Answer format)", "Image search", "Video search", "News search"],
      "answer": 0,
      "explanation": "Ask.com (originally Ask Jeeves) natural language questions (जैसे 'Who is the President of India?') में specialized था। यह users को direct answers देने की कोशिश करता था।",
      "difficulty": "hard",
      "hint": "सवाल पूछो, जवाब मिलेगा।",
      "points": 20
    },
    {
      "question": "Baidu किस country का popular search engine है?",
      "options": ["China", "Japan", "Russia", "South Korea"],
      "answer": 0,
      "explanation": "Baidu China का leading search engine है। China में Google often blocked है, इसलिए Baidu ~70%+ market share रखता है।",
      "difficulty": "medium",
      "hint": "चीन का गूगल।",
      "points": 15
    },
    {
      "question": "Yandex किस country का search engine है?",
      "options": ["Russia", "Germany", "France", "UK"],
      "answer": 0,
      "explanation": "Yandex Russia का leading search engine और tech company है। यह Russia और neighboring countries में popular है। 'Google of Russia' कहलाता है।",
      "difficulty": "medium",
      "hint": "रूस का गूगल।",
      "points": 15
    },
    {
      "question": "Naver किस country का popular search engine है?",
      "options": ["South Korea", "Japan", "China", "Vietnam"],
      "answer": 0,
      "explanation": "Naver South Korea का leading search engine है (Google की जगह)। इसमें unique 'Cafe' (forums) और 'Knowledge iN' (Q&A) features हैं।",
      "difficulty": "hard",
      "hint": "दक्षिण कोरिया का गूगल।",
      "points": 20
    },
    {
      "question": "Google में न्यूज़ result को time के हिसाब से कैसे filter करें?",
      "options": ["Search results page → Tools → Any time → select Past hour/day/week/year", "Search 'news' tab", "Search 'after:' operator", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "News tab में Tools → Any time dropdown से आप results को past hour, past 24 hours, past week, past month, past year, या custom range के हिसाब से filter कर सकते हैं।",
      "difficulty": "easy",
      "hint": "ताज़ा खबर चाहिए तो।",
      "points": 10
    },
    {
      "question": "Google Scholar में 'Cited by' feature क्या दिखाता है?",
      "options": ["कितने दूसरे research papers ने इस paper को reference किया है", "Citations count", "Paper popularity", "Paper quality"],
      "answer": 0,
      "explanation": "Google Scholar में 'Cited by [number]' link के पीछे उन सभी papers की list होती है जिन्होंने current paper को reference (cite) किया है। More citations generally means more influential paper।",
      "difficulty": "hard",
      "hint": "कितनों ने उद्धृत किया।",
      "points": 20
    },
    {
      "question": "Google Patents क्या है?",
      "options": ["Patents (आविष्कार पेटेंट) search करने का platform", "Patent filing", "Patent law", "Patent images"],
      "answer": 0,
      "explanation": "Google Patents (patents.google.com) worldwide patents और patent applications को search करने के लिए है। इसमें 100+ million patents हैं।",
      "difficulty": "hard",
      "hint": "नए आविष्कार खोजो।",
      "points": 20
    },
    {
      "question": "Google Dataset Search किसके लिए है?",
      "options": ["Researchers के लिए free datasets ढूंढना", "Data science", "Machine learning", "Statistics"],
      "answer": 0,
      "explanation": "Google Dataset Search (datasetsearch.research.google.com) researchers को open-access datasets (जैसे government data, university research data) ढूंढने में मदद करता है।",
      "difficulty": "hard",
      "hint": "डेटा साइंटिस्ट के लिए।",
      "points": 20
    },
    {
      "question": "Google में 'filetype:pdf' और 'ext:pdf' में क्या अंतर है?",
      "options": ["दोनों एक ही हैं (synonyms)", "filetype only works, ext नहीं", "ext only works", "Alag functionality"],
      "answer": 0,
      "explanation": "Google में filetype: और ext: दोनों operators same काम करते हैं - specific file extension search करने के लिए। 'filetype:pdf' और 'ext:pdf' same results देंगे।",
      "difficulty": "medium",
      "hint": "Same same।",
      "points": 15
    },
    {
      "question": "Google Search में 'AROUND(N)' operator क्या करता है?",
      "options": ["Two words के बीच N words का gap allowed", "Distance filter", "Location filter", "Radius filter"],
      "answer": 0,
      "explanation": "AROUND(N) operator दो शब्दों के बीच maximum N words का gap allowed करता है (proximity search)। Example: 'privacy AROUND(5) policy' उन pages को ढूंढेगा जहाँ 'privacy' और 'policy' के बीच 5 से कम words हैं। (Operator works as of old Google, now spotty)।",
      "difficulty": "hard",
      "hint": "शब्दों के बीच दूरी limit।",
      "points": 20
    },
    {
      "question": "Google Programmable Search Engine (पहले CSE) क्या है?",
      "options": ["अपनी खुद की custom search engine बनाना (specific websites पर search)", "Google का search API", "Google Search का विकल्प", "SEO tool"],
      "answer": 0,
      "explanation": "Google Programmable Search Engine (CSE) आपको अपनी website, या specific set of websites पर customized search engine बनाने देता है। आप search results को अपनी need के अनुसार style और filter कर सकते हैं।",
      "difficulty": "hard",
      "hint": "अपना गूगल बनाओ।",
      "points": 20
    },
    {
      "question": "Google में 'Verbatim' mode क्या करता है?",
      "options": ["Search terms को exactly as typed search करता है (no synonyms, no spelling correction, no personalization)", "Temporary mode", "Word for word", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Verbatim mode (Tools → All results → Verbatim) Google को synonyms, spelling corrections, और personalization skip करने देता है। यह आपके typed words को exactly मैच करता है। Useful जब Google बहुत smart हो जाए।",
      "difficulty": "hard",
      "hint": "बिल्कुल वैसे ही ढूंढो।",
      "points": 20
    },
    {
      "question": "पहली बार Google Search कब launch हुआ?",
      "options": ["1998", "1996", "2000", "1994"],
      "answer": 0,
      "explanation": "Google Search (गूगल) 4 सितंबर 1998 को launch हुआ था, लेकिन यह 1996 में BackRub के रूप में Stanford University में शुरू हुआ था।",
      "difficulty": "hard",
      "hint": "1998 सही साल।",
      "points": 20
    },
    {
      "question": "Google का original name (पहला नाम) क्या था?",
      "options": ["BackRub", "BackRun", "PageRank", "Goolag"],
      "answer": 0,
      "explanation": "Google का first name 'BackRub' था (1996 में) क्योंकि यह 'backlinks' की system पर based था। बाद में Larry Page और Sergey Brin ने 'Google' नाम रखा (googol - 1 के बाद 100 zeros)।",
      "difficulty": "hard",
      "hint": "पीठ मलना।",
      "points": 20
    },
    {
      "question": "Google का नाम 'Google' क्यों रखा गया?",
      "options": ["'Googol' (1 followed by 100 zeros) का misspelling - बहुत बड़ी संख्या को represent करने के लिए", "Google - Go and look", "Gullible", "Goggles"],
      "answer": 0,
      "explanation": "Google name 'googol' की misspelling है - googol 1 के बाद 100 zeros वाली संख्या है। यह उनके mission को दर्शाता है: internet पर available विशाल amount of information को organize करना।",
      "difficulty": "hard",
      "hint": "बहुत बड़ी संख्या।",
      "points": 20
    },
    {
      "question": "Google का algorithms में से एक PigeonRank (unofficial term) क्या था?",
      "options": ["Local search results algorithm (Google para joke)", "PageRank", "Bird algorithm", "Image search"],
      "answer": 0,
      "explanation": "PigeonRank एक April Fools joke था (2002) जिसमें Google ने कहा कि वो pigeons (कबूतर) का use करता है। बाद में असली local search algorithm को अनौपचारिक रूप से 'Pigeon' कहा गया।",
      "difficulty": "hard",
      "hint": "April Fools joke।",
      "points": 20
    },
    {
      "question": "Google 'Did you mean' feature कैसे काम करता है?",
      "options": ["Spelling mistakes को detect करता है और autocorrect suggestion देता है", "Grammar check", "Synonym suggestion", "Translation"],
      "answer": 0,
      "explanation": "Google 'Did you mean:' spelling correction algorithm common misspellings को detect करता है और corrected version suggest करता है। यह user behavior, dictionary, और statistical language model पर based है।",
      "difficulty": "medium",
      "hint": "गलत spelling हो तो सुधार देता है।",
      "points": 15
    },
    {
      "question": "Google में 'Autocomplete' (predictive search) कैसे काम करता है?",
      "options": ["Popular searches, past searches, and real-time trends के आधार पर predictions देता है", "AI generate", "Random words", "Dictionary words"],
      "answer": 0,
      "explanation": "Google Autocomplete जैसे ही आप टाइप करना शुरू करते हैं, उन terms के सुझाव देता है जो popular हैं, आपकी past search history पर based हैं, और real-time trending topics के आधार पर।",
      "difficulty": "medium",
      "hint": "बताओ क्या ढूंढ़ना चाहते हो।",
      "points": 15
    },
    {
      "question": "Search results को 'Past year' में कैसे filter करें?",
      "options": ["Tools → Any time → Past year", "Tools → Custom range", "before: operator", "उपरोक्त सभी"],
      "answer": 3,
      "explanation": "Search results page पर 'Tools' पर click करें, फिर 'Any time' dropdown से 'Past year' select करें। या 'before:YYYY-MM-DD' operator use करें।",
      "difficulty": "easy",
      "hint": "एक साल पुराने results।",
      "points": 10
    }
  ],
  "7. Safe Internet Usage and Digital Security": [
    {
      "question": "मजबूत पासवर्ड की सबसे अच्छी प्रैक्टिस क्या है?",
      "options": ["कम से कम 12 कैरेक्टर, uppercase, lowercase, numbers, special symbols का मिक्स", "अपना नाम लिखें", "123456", "password"],
      "answer": 1,
      "explanation": "Strong password लंबा (12+ characters) होना चाहिए, जिसमें uppercase, lowercase, numbers, और special symbols (@, #, %) हों। आम words या personal info (जन्मतिथि, नाम) से बचें।",
      "difficulty": "easy",
      "hint": "लंबा और जटिल।",
      "points": 10
    },
    {
      "question": "2FA (Two-Factor Authentication) क्या है?",
      "options": ["पासवर्ड के अलावा second verification step (OTP, biometric, authenticator app)", "Single password", "No password", "Fingerprint only"],
      "answer": 0,
      "explanation": "2FA सिक्योरिटी की एक अतिरिक्त परत है। पासवर्ड डालने के बाद, आपको दूसरा factor (SMS या ऐप से OTP, fingerprint, face scan, या security key) डालना होता है।",
      "difficulty": "easy",
      "hint": "दो ताले, दो चाबियाँ।",
      "points": 10
    },
    {
      "question": "Password Manager क्या होता है?",
      "options": ["सभी पासवर्ड secure तरीके से store और manage करने वाला software", "Password guesser", "Password cracker", "Keylogger"],
      "answer": 0,
      "explanation": "Password Manager (जैसे LastPass, Bitwarden, 1Password, Google Password Manager) आपके सभी पासवर्ड encrypted vault में store करता है। आपको सिर्फ एक master password याद रखना होता है, बाकी पासवर्ड यह auto-fill करता है और strong passwords generate करता है।",
      "difficulty": "medium",
      "hint": "पासवर्ड की डिजिटल डायरी।",
      "points": 15
    },
    {
      "question": "Phishing Attack क्या है?",
      "options": ["नकली email, message, या website बनाकर आपका sensitive data (पासवर्ड, credit card) चुराना", "Virus attack", "Hacking", "Malware"],
      "answer": 0,
      "explanation": "Phishing में attacker legitimate कंपनी (bank, Google, Amazon) के नाम पर fake email/SMS/website बनाता है। आपको link click करके fake login page पर भेजा जाता है जहाँ आप अपना पासवर्ड डाल देते हैं।",
      "difficulty": "easy",
      "hint": "मछली पकड़ने का तरीका (fishing)।",
      "points": 10
    },
    {
      "question": "Phishing से कैसे बचें?",
      "options": ["संदिग्ध emails में links पर click न करें, sender का email address check करें, URL को verify करें", "All links click करें", "Password share करें", "OTP share करें"],
      "answer": 0,
      "explanation": "हमेशा sender's email address carefully check करें (क्या exact domain है? google.com या g00gle.com?), hover over link देखें, कभी भी OTP या password किसी से share न करें, और suspicious emails में embedded links पर click न करें।",
      "difficulty": "easy",
      "hint": "लाल झंडा पहचानो।",
      "points": 10
    },
    {
      "question": "Malware क्या है?",
      "options": ["Malicious software (virus, worm, trojan, ransomware, spyware)", "Microsoft software", "Google software", "Antivirus"],
      "answer": 0,
      "explanation": "Malware 'malicious software' का short form है। यह कोई भी software जो आपके computer को damage करे, data चुराए, system को control करे, या बिना permission काम करे।",
      "difficulty": "easy",
      "hint": "बुरा सॉफ्टवेयर।",
      "points": 10
    },
    {
      "question": "Virus क्या है?",
      "options": ["Self-replicating malware जो दूसरी files में attach हो जाता है और फैलता है", "Worm", "Trojan", "Spyware"],
      "answer": 0,
      "explanation": "Virus एक प्रकार का malware है जो legitimate files को infect करता है और जब वो file run होती है तो virus activate होकर आगे फैलता है। यह user interaction (file open, program run) के बिना नहीं फैलता।",
      "difficulty": "easy",
      "hint": "बीमारी फैलाने वाला।",
      "points": 10
    },
    {
      "question": "Worm और Virus में क्या अंतर है?",
      "options": ["Worm बिना user interaction के खुद फैलता है (network में), virus को user action चाहिए", "दोनों same हैं", "Worm less dangerous", "Virus faster"],
      "answer": 0,
      "explanation": "Worm एक self-replicating malware है जो बिना किसी user action (file open किए) के network या vulnerability के through फैलता है। Worm को आपको कुछ भी click नहीं करना पड़ता।",
      "difficulty": "hard",
      "hint": "कीड़ा खुद रेंगता है।",
      "points": 20
    },
    {
      "question": "Trojan Horse क्या है?",
      "options": ["Malware जो legitimate software disguise में आता है (लेकिन अंदर malicious)", "Virus", "Worm", "Spyware"],
      "answer": 0,
      "explanation": "Trojan (Trojan Horse) एक malware है जो legitimate software (जैसे game, PDF reader, crack) का रूप धारण करता है। User उसे download और install करता है सोचकर वो real है, लेकिन ये secret background में malicious काम करता है और नहीं self-replicate करता।",
      "difficulty": "hard",
      "hint": "ट्रोजन घोड़ा - अंदर बुराई छुपी।",
      "points": 20
    },
    {
      "question": "Ransomware क्या करता है?",
      "options": ["आपकी files को encrypt कर देता है और उन्हें unlock करने के लिए ransom (फिरौती) मांगता है", "Files delete करता है", "Files hide करता है", "Computer slow करता है"],
      "answer": 0,
      "explanation": "Ransomware malware (जैसे WannaCry, NotPetya) आपकी files (documents, photos) को encrypt (lock) कर देता है और उन्हें वापस पाने के लिए Bitcoin में फिरौती मांगता है। Regular backups इसका best बचाव है।",
      "difficulty": "hard",
      "hint": "फ़ाइलें बंधक बना लेता है।",
      "points": 20
    },
    {
      "question": "Spyware क्या करता है?",
      "options": ["आपकी activities की spying (जासूसी) करता है - keystrokes, browsing habits, passwords चुराता है", "Screen lock करता है", "Files delete करता है", "Computer slow करता है"],
      "answer": 0,
      "explanation": "Spyware आपकी जानकारी के बिना आपके activities को monitor करता है: websites visited, keystrokes (keylogger), usernames/passwords, credit card numbers, और ये data attacker को भेज देता है।",
      "difficulty": "hard",
      "hint": "जासूस।",
      "points": 20
    },
    {
      "question": "Adware क्या है?",
      "options": ["Unwanted विज्ञापन (ads) दिखाता है, pop-ups, browser redirects", "Antivirus", "Virus", "Trojan"],
      "answer": 0,
      "explanation": "Adware software जो excessive और intrusive विज्ञापन दिखाता है (pop-ups, banners, in-text ads)। अक्सर free software के साथ bundle होकर आता है। यह annoying है लेकिन सीधा harmful नहीं। कभी-कभी adware spyware के साथ आता है।",
      "difficulty": "medium",
      "hint": "परेशान करने वाले ads।",
      "points": 15
    },
    {
      "question": "Keylogger क्या है?",
      "options": ["आपके keyboard की हर key press को record करता है (passwords चुराने के लिए)", "Screenshot लेता है", "Microphone record करता है", "Webcam record करता है"],
      "answer": 0,
      "explanation": "Keylogger एक spyware है जो आपके टाइप किए गए हर key को log (record) करता है। यह passwords, credit card numbers, messages सब चुरा सकता है। Hardware keylogger (USB device) या software हो सकता है।",
      "difficulty": "hard",
      "hint": "हर बटन की निगरानी।",
      "points": 20
    },
    {
      "question": "Rootkit क्या है?",
      "options": ["Malware जो operating system के deep level (kernel) में छिप जाता है और antivirus से detection को avoid करता है", "Virus", "Trojan", "Worm"],
      "answer": 0,
      "explanation": "Rootkit एक stealth malware है जो OS के kernel (सबसे low level) में छिप जाता है। यह files, processes, registry keys, और network connections को हाइड कर सकता है, जिससे antivirus और user इसे detect नहीं कर पाते। Detect और remove करना बहुत मुश्किल होता है।",
      "difficulty": "hard",
      "hint": "अंदर ही अंदर छुप जाता है।",
      "points": 20
    },
    {
      "question": "Antivirus Software क्या करता है?",
      "options": ["Malware को detect, quarantine, और remove करता है", "Internet speed बढ़ाता है", "Battery save करता है", "Games optimize करता है"],
      "answer": 0,
      "explanation": "Antivirus (या Anti-malware) real-time protection, signature-based detection, और heuristic analysis के द्वारा malware को scan, detect, quarantine (isolate), और remove करता है।",
      "difficulty": "easy",
      "hint": "कंप्यूटर का नाई।",
      "points": 10
    },
    {
      "question": "Firewall क्या करता है? (पुनः सुदृढ़ीकरण)",
      "options": ["Incoming और outgoing network traffic को rules के आधार पर allow या block करता है", "Malware हटाता है", "Virus scan करता है", "Password save करता है"],
      "answer": 0,
      "explanation": "Firewall एक सुरक्षा चौकी है जो traffic को monitor और control करता है। Unauthorized access को block करता है। Network-level (hardware firewall) या host-based (software firewall जैसे Windows Firewall) हो सकता है।",
      "difficulty": "easy",
      "hint": "डिजिटल चौकीदार।",
      "points": 10
    },
    {
      "question": "VPN क्यों use करें? (Security aspect)",
      "options": ["Internet traffic को encrypt करता है और IP address छुपाता है, public WiFi पर सुरक्षित बनाता है", "Internet speed बढ़ाता है", "Virus हटाता है", "Ads ब्लॉक करता है"],
      "answer": 0,
      "explanation": "VPN (Virtual Private Network) आपके internet traffic को encrypt करता है और आपकी real IP address को छुपा देता है। यह public WiFi (cafe, airport, hotel) पर सुरक्षित है क्योंकि hackers आपका traffic नहीं देख सकते। ISP भी नहीं देख सकता आप क्या कर रहे हो।",
      "difficulty": "medium",
      "hint": "सुरंग में भेजो internet को।",
      "points": 15
    },
    {
      "question": "Public WiFi (Free WiFi) पर banking या password entry क्यों avoid करनी चाहिए?",
      "options": ["Public WiFi often unencrypted होता है, hackers MITM attack कर सकते हैं और आपका data चुरा सकते हैं", "Slow होता है", "Paid होता है", "Malware होता है"],
      "answer": 0,
      "explanation": "Public WiFi आमतौर पर open (no encryption) या weak encryption (VPN) के साथ होते हैं। Hackers same network पर खड़े होकर आपका traffic sniff कर सकते हैं (man-in-the-middle attack) और आपके passwords, emails, credit card जानकारी चुरा सकते हैं। Sensitive काम के लिए VPN use करें या mobile data पर करें।",
      "difficulty": "medium",
      "hint": "Cafe में free WiFi = hacker friendly।",
      "points": 15
    },
    {
      "question": "HTTPS और HTTP में सुरक्षा अंतर क्या है?",
      "options": ["HTTPS encrypted (SSL/TLS) होता है, HTTP plain text होता है", "HTTPS faster है", "HTTP secure है", "कोई अंतर नहीं"],
      "answer": 0,
      "explanation": "HTTPS (HTTP over SSL/TLS) आपके browser और website के बीच के data को encrypt करता है। HTTP में सब कुछ plain text में travel करता है, जो hackers आसानी से पढ़ सकते हैं। हमेशा URL में 'https' और padlock icon देखें।",
      "difficulty": "easy",
      "hint": "हरा ताला = सुरक्षित।",
      "points": 10
    },
    {
      "question": "SSL/TLS Certificate क्या है?",
      "options": ["Digital certificate जो website की identity को verify करता है और encryption enable करता है (HTTPS)", "Antivirus", "Firewall", "VPN"],
      "answer": 0,
      "explanation": "SSL/TLS certificate एक digital document है जो यह साबित करता है कि website वास्तव में legitimate है। यह encrypted connection (HTTPS) को enable करता है। यदि certificate invalid है तो browser warning देता है।",
      "difficulty": "medium",
      "hint": "वेबसाइट की पहचान पत्र।",
      "points": 15
    },
    {
      "question": "Social Engineering Attack क्या है?",
      "options": ["इंसानों को manipulate करके information चुराना (जैसे फोन पर झांसा देकर पासवर्ड माँगना)", "Virus attack", "Hacking", "Network attack"],
      "answer": 0,
      "explanation": "Social Engineering technical हैकिंग नहीं है, बल्कि psychological manipulation है। Attacker trust या fear का फायदा उठाकर आपसे sensitive information (पासवर्ड, OTP, bank details) पूछ लेता है। Phishing, vishing (phone), tailgating, pretexting इसके उदाहरण हैं।",
      "difficulty": "medium",
      "hint": "इंसान को हैक करना।",
      "points": 15
    },
    {
      "question": "Vishing क्या है?",
      "options": ["Phone call से phishing (फोन पर bank बनकर OTP, कार्ड details माँगना)", "Email phishing", "SMS phishing", "Malware"],
      "answer": 0,
      "explanation": "Vishing (Voice + Phishing) phone call के through होता है। Attacker bank, government, या tech support बनकर call करता है और आपको डराकर या ललचाकर sensitive information (जैसे OTP, credit card number, password) पूछ लेता है। Legitimate organization कभी भी phone पर OTP या password नहीं माँगता।",
      "difficulty": "medium",
      "hint": "फोन पर धोखाधड़ी।",
      "points": 15
    },
    {
      "question": "Smishing क्या है?",
      "options": ["SMS phishing (fake text message से लिंक भेजकर या जानकारी माँगना)", "Email phishing", "Phone phishing", "Malware"],
      "answer": 0,
      "explanation": "Smishing (SMS + Phishing) fake text messages (SMS) भेजकर किया जाता है। Message में अक्सर 'Your bank account blocked', 'You won prize', 'Package delayed' जैसा लिखा होता है और एक malicious link होता है। Link click करने पर personal information माँगी जाती है या malware install होता है।",
      "difficulty": "medium",
      "hint": "SMS में झांसा।",
      "points": 15
    },
    {
      "question": "Zero-day vulnerability क्या है?",
      "options": ["Security flaw जो software developer को पता है, लेकिन उसके पास patch करने का zero days (time) है", "Old vulnerability", "Minor bug", "User error"],
      "answer": 0,
      "explanation": "Zero-day vulnerability एक software security hole है जो developer (जैसे Microsoft, Google) को पता है, लेकिन उनके पास patch release करने के लिए zero days (कोई समय नहीं) - यानी attacker already इसका फायदा उठा रहे हैं। यह very dangerous होता है।",
      "difficulty": "hard",
      "hint": "पता तो है लेकिन अभी तक ठीक नहीं है।",
      "points": 20
    },
    {
      "question": "Man-in-the-Middle (MITM) attack क्या है?",
      "options": ["Attacker आपके और website के बीच में खड़ा होकर traffic को intercept और modify करता है", "Virus attack", "Malware attack", "DoS attack"],
      "answer": 0,
      "explanation": "MITM attack में hacker आपकी और जिससे आप communicate कर रहे हैं (जैसे bank website) के बीच में बैठ जाता है। आप सोचते हो सीधे bank से बात हो रही है, लेकिन hacker सारे messages पढ़ और modify सकता है। Public WiFi पर common है।",
      "difficulty": "hard",
      "hint": "बीच में चोर।",
      "points": 20
    },
    {
      "question": "DDoS Attack क्या है?",
      "options": ["Multiple compromised computers (botnet) एक website पर इतना traffic flood करते हैं कि website down हो जाती है", "Data theft", "Password cracking", "Virus spread"],
      "answer": 0,
      "explanation": "DDoS (Distributed Denial of Service) attack में attacker 'zombie' computers (botnet) को use करता है वो target website (जैसे bank, government) पर millions of requests भेजने के लिए। Server overload होकर crash हो जाता है, और legitimate users access नहीं कर पाते।",
      "difficulty": "hard",
      "hint": "भीड़ लगाकर दुकान बंद करवाना।",
      "points": 20
    },
    {
      "question": "Brute Force Attack क्या है?",
      "options": ["सभी possible password combinations try करना (क्रमशः) ताकि password guess किया जा सके", "Dictionary attack", "Phishing", "Malware"],
      "answer": 0,
      "explanation": "Brute force attack automated tool से हर possible password combination को try करता है (जैसे 'a', 'aa', 'ab', 'ac' ..., '1111', '1234', ...)। यह time-consuming है, लेकिन weak और short passwords आसानी से crack हो जाते हैं। Long and complex passwords इससे सुरक्षित हैं।",
      "difficulty": "hard",
      "hint": "हर ताला खोलने की कोशिश।",
      "points": 20
    },
    {
      "question": "Dictionary Attack क्या है?",
      "options": ["Common words और passwords (dictionary words) की list try करता है", "Brute force", "Phishing", "Malware"],
      "answer": 0,
      "explanation": "Dictionary attack pre-made list of common passwords (जैसे 'password', '123456', 'qwerty', 'admin', 'iloveyou') और dictionary words को try करता है। यह brute force से तेज़ है क्योंकि बहुत सारे users weak passwords use करते हैं।",
      "difficulty": "hard",
      "hint": "आम शब्दों की सूची।",
      "points": 20
    },
    {
      "question": "Credential Stuffing क्या है?",
      "options": ["एक website से चुराए गए username/password को दूसरी websites पर try करना", "Brute force", "Phishing", "Keylogging"],
      "answer": 0,
      "explanation": "Credential stuffing में attack एक data breach (जैसे किसी website का database leak) से चुराए गए username/password combinations को दूसरी popular websites (जैसे Amazon, Gmail, Facebook) पर try करता है (क्योंकि लोग अक्सर same password reuse करते हैं।)",
      "difficulty": "hard",
      "hint": "एक ताला टूटा, सब जगह try करेंगे।",
      "points": 20
    },
    {
      "question": "Data Breach क्या है?",
      "options": ["Sensitive data (passwords, emails, credit cards) का unauthorized access और exposure", "Virus attack", "Computer crash", "Network failure"],
      "answer": 0,
      "explanation": "Data breach में hacker कंपनी के database से लाखों users का personal data चुरा लेता है (हैक)। Often यह data dark web पर बिकता है। यदि आप breached हैं, तो तुरंत password change करें और 2FA on करें।",
      "difficulty": "medium",
      "hint": "डेटा लीक हो जाना।",
      "points": 15
    },
    {
      "question": "Have I Been Pwned (HIBP) क्या है?",
      "options": ["Free service जो बताता है कि आपका email या password किसी data breach में शामिल है या नहीं", "Antivirus", "VPN", "Firewall"],
      "answer": 0,
      "explanation": "Have I Been Pwned (haveibeenpwned.com) Troy Hunt का एक free service है। आप अपना email या phone डालकर check कर सकते हैं कि क्या आपका account किसी known data breach में compromised हुआ है। यदि हाँ, तो तुरंत password change करें।",
      "difficulty": "medium",
      "hint": "देखो, लीक हुए क्या?",
      "points": 15
    },
    {
      "question": "OAuth क्या है?",
      "options": ["'Login with Google/Facebook' की permission-based access system (बिना password share किए)", "Security protocol", "Encryption", "Authentication"],
      "answer": 0,
      "explanation": "OAuth (Open Authorization) आपको किसी website/app को अपना पासवर्ड दिए बिना access देने की अनुमति देता है ('Login with Google', 'Sign in with Facebook')। आप password Google को देते हो, Google app को एक token देता है और app आपको identify कर सकता है।",
      "difficulty": "hard",
      "hint": "बिना पासवर्ड बताए login।",
      "points": 20
    },
    {
      "question": "GDPR क्या है?",
      "options": ["EU का data protection law जो users को control देता है कि companies उनका data कैसे collect, store, और use कर सकती हैं", "India law", "US law", "China law"],
      "answer": 0,
      "explanation": "GDPR (General Data Protection Regulation) EU का एक strict privacy law है (2018 में effective)। यह users को 'right to be forgotten' (data delete करवाना), data access, और consent का अधिकार देता है। Violation पर huge fines (€20 million या 4% global revenue) लग सकते हैं। India का समान law Digital Personal Data Protection Act, 2023 है।",
      "difficulty": "hard",
      "hint": "European data privacy law।",
      "points": 20
    },
    {
      "question": "Digital Personal Data Protection Act, 2023 (India) क्या है?",
      "options": ["India का data protection law जो users का personal data सुरक्षित रखने और companies accountability के नियम बनाता है", "GDPR का Indian version", "IT Act 2000 update", "साइबर क्राइम लॉ"],
      "answer": 0,
      "explanation": "DPDP Act, 2023 India का पहला comprehensive data protection law है। इसमें citizens को data के collection, processing, storage के बारे में rights दी गई हैं, Data Fiduciaries (companies) की obligations हैं, और data breach पर penalties हैं।",
      "difficulty": "hard",
      "hint": "भारत का डेटा सुरक्षा कानून।",
      "points": 20
    },
    {
      "question": "Regular software updates (patches) क्यों जरूरी हैं?",
      "options": ["Security vulnerabilities को fix करने के लिए (पुरानी version में hackers exploits ढूंढ सकते हैं)", "Naye features देने के लिए", "Speed बढ़ाने के लिए", "Battery save करने के लिए"],
      "answer": 0,
      "explanation": "Software updates (जैसे Windows Update, app updates) में security patches होते हैं जो newly discovered vulnerabilities (जिन्हें hackers abuse कर सकते हैं) को fix करते हैं। पुरानी unpatched version को ransomware, malware, हमलों का खतरा अधिक होता है। Auto-updates on रखें।",
      "difficulty": "easy",
      "hint": "पैबंद लगाना।",
      "points": 10
    },
    {
      "question": "BIOS/UEFI password क्या होता है?",
      "options": ["Computer boot होने से पहले password (जो कंप्यूटर चालू करने पर लगता है)", "Windows password", "User password", "Admin password"],
      "answer": 0,
      "explanation": "BIOS/UEFI password एक hardware-level password है। कंप्यूटर ऑन करने के तुरंत बाद, OS load होने से पहले यह password पूछता है। यह सुरक्षा की extra परत है, लेकिन अगर भूल गए तो reset करना मुश्किल होता है (motherboard jumper या CMOS battery निकालनी पड़ती है)।",
      "difficulty": "hard",
      "hint": "पॉवर ऑन के बाद सबसे पहले पासवर्ड।",
      "points": 20
    },
    {
      "question": "Secure Boot क्या है?",
      "options": ["UEFI feature जो boot time पर malicious software और unauthorized OS को load होने से prevent करता है", "Antivirus", "Firewall", "Encryption"],
      "answer": 0,
      "explanation": "Secure Boot एक UEFI security standard है। यह ensure करता है कि boot process के दौरान सिर्फ trusted (digitally signed) firmware, bootloader, और OS ही load हों। यह rootkits और bootkits (boot time malware) से बचाता है। Windows 11 के लिए mandatory है।",
      "difficulty": "hard",
      "hint": "सुरक्षित शुरुआत।",
      "points": 20
    },
    {
      "question": "MAC Address Filtering क्या है?",
      "options": ["सिर्फ specific MAC address वाले devices को WiFi network access देने की technique", "IP filtering", "Port filtering", "Protocol filtering"],
      "answer": 0,
      "explanation": "MAC Address Filtering एक WiFi security method है जहाँ router सिर्फ उन devices को allow करता है जिनके MAC addresses को आपने manually allowed list में डाला होता है। हालाँकि experience hackers MAC address spoof कर सकते हैं, इसलिए ये primary security नहीं है।",
      "difficulty": "hard",
      "hint": "घर में किसी और का WiFi न चले।",
      "points": 20
    },
    {
      "question": "WPA3 क्या है?",
      "options": ["WiFi security protocol (WPA2 से ज्यादा secure)", "VPN protocol", "Antivirus", "Firewall"],
      "answer": 0,
      "explanation": "WPA3 (Wi-Fi Protected Access 3) WiFi security का latest standard है (2018 में आया)। यह WPA2 की तुलना में ज्यादा strong encryption (192-bit), better password protection, और open WiFi networks पर individualized data encryption प्रदान करता है। नए राउटर और devices support करते हैं।",
      "difficulty": "hard",
      "hint": "WiFi सुरक्षा का आखिरी संस्करण।",
      "points": 20
    },
    {
      "question": "Why should you never share OTP (One Time Password)?",
      "options": ["Because OTP means 'Onetime Password' and only you should know it. Bank, tech support, or any legitimate organization will never ask for OTP over phone/email/SMS.", "OTP is not important", "OTP can be shared", "OTP has no value"],
      "answer": 0,
      "explanation": "OTP कभी भी किसी के साथ share न करें। Bank, credit card company, tech support, Facebook, Google, Amazon कभी भी phone call, email, या SMS पर OTP या password नहीं माँगते। OTP share करना = account compromise।",
      "difficulty": "easy",
      "hint": "OTP सिर्फ तुम्हारे लिए है।",
      "points": 10
    },
    {
      "question": "UPI PIN किसके साथ share कर सकते हैं?",
      "options": ["किसी के साथ नहीं (UPI PIN कभी share न करें)", "Bank staff", "Customer care", "Family members"],
      "answer": 0,
      "explanation": "UPI PIN (जैसे Google Pay, PhonePe, Paytm) कभी भी किसी से share न करें। यह आपकी बैंक से authorization की key है। Legitimate bank employee, customer care, या family member भी UPI PIN नहीं पूछेगा। Fraudsters UPI PIN पूछकर पैसे निकाल सकते हैं।",
      "difficulty": "easy",
      "hint": "ATM PIN की तरह गुप्त।",
      "points": 10
    },
    {
      "question": "Fake customer care numbers से कैसे बचें?",
      "options": ["Always use official website या app से customer care number लें (Google search पर 'official' tag देखें)", "जो भी number देखें call करें", "Top result पर click करें", "SMS में भेजे number use करें"],
      "answer": 0,
      "explanation": "Scammers fake customer care numbers Google search, ads, या SMS पर डाल देते हैं। जब आप call करते हो, वो OTP, UPI PIN, या पैसे transfer करवाने का तरीका कहते हैं। Always official app या company website से verified number ही use करें।",
      "difficulty": "medium",
      "hint": "गलत number पड़ सकता है भारी।",
      "points": 15
    },
    {
      "question": "Safe browsing practices में से क्या शामिल है?",
      "options": ["Unknown links पर hover करके देखें (true URL), suspicious pop-ups बंद करें, trusted websites पर ही personal info डालें", "सब links पर click करें", "Pop-ups allow करें", "Personal info everywhere डालें"],
      "answer": 0,
      "explanation": "Safe browsing के नियम: unknown links पर click करने से पहले hover करके real URL देखें, ads और pop-ups (खासकर 'Your computer is infected') पर click न करें, और sensitive information हमेशा trusted (HTTPS) websites पर ही डालें।",
      "difficulty": "easy",
      "hint": "जालसाज़ी से बचो।",
      "points": 10
    },
    {
      "question": "Browser में 'Remember password' feature का उपयोग करना कितना safe है?",
      "options": ["Safe है अगर आप अकेले computer use करते हैं (लेकिन public/shared computer पर न करें)। Password manager better है", "Never use", "Always safe", "Not safe at all"],
      "answer": 0,
      "explanation": "Browser password saving convenient है लेकिन यह passwords को (कुछ browsers में) plain text में store नहीं करता, लेकिन जो anyone आपके computer का access रखता है वो saved passwords देख सकते हैं। अकेले personal PC पर ठीक है, लेकिन shared/public computer पर 'Never' option चुनें।",
      "difficulty": "medium",
      "hint": "अपने कंप्यूटर पर तो ठीक, दूसरे के पर नहीं।",
      "points": 15
    },
    {
      "question": "Email में suspicious attachment (जैसे .exe, .scr, .zip) खोलने से पहले क्या करें?",
      "options": ["Scan antivirus से, sender से verify करें, unknown sender से तो कभी न खोलें", "तुरंत खोलें", "Double-click करें", "Forward करें"],
      "answer": 0,
      "explanation": "Suspicious email attachments (especially .exe, .scr, .zip, .js) malware हो सकते हैं। Unknown sender से तो कभी भी न खोलें। Expected attachments को भी antivirus से scan करें या sender से (दूसरे channel से) verify करें कि वास्तव में उन्होंने भेजा है।",
      "difficulty": "easy",
      "hint": "लगाव (attachment) खतरनाक हो सकता है।",
      "points": 10
    },
    {
      "question": "कोई website अगर 'Your computer is infected! Call Microsoft Support at 1-888-xxx' जैसा pop-up दिखाए तो क्या करें?",
      "options": ["Pop-up बंद करें (Task Manager से browser close करें), और कभी भी number पर call न करें", "Call करें", "Download करें antivirus", "Enter credit card details"],
      "answer": 0,
      "explanation": "यह एक typical tech support scam है। यह scare tactic है यह दिखाने का कि आपका computer virus से infected है। Pop-up को बंद कर दें, दिए गए number पर कभी call न करें, क्योंकि वो scammers होंगे जो आपको remote access देने को कहेंगे या payment माँगेंगे।",
      "difficulty": "easy",
      "hint": "डरो मत, बंद करो।",
      "points": 10
    },
    {
      "question": "Rogue Antivirus क्या होता है?",
      "options": ["Fake antivirus जो virus दिखाता है (जो हैं ही नहीं) और आपको paid version खरीदने को कहता है", "Real antivirus", "Free antivirus", "Open source antivirus"],
      "answer": 0,
      "explanation": "Rogue Antivirus (scareware) एक fake security software है जो pop-ups दिखाता है '100 viruses found' (जबकि कोई virus नहीं है)। यह आपको डराता है 'full version' खरीदने के लिए या आपकी जानकारी के बिना malware install कर देता है। Legitimate antivirus से ही scan करें।",
      "difficulty": "hard",
      "hint": "नकली डॉक्टर।",
      "points": 20
    },
    {
      "question": "Dark Web से कभी क्यों नहीं खरीदना चाहिए?",
      "options": ["Illegal goods और services (stolen credit cards, drugs, weapons, hacker services) के लिए जाना जाता है, अत्यधिक खतरनाक और कानूनी परेशानी", "Cheap होता है", "Easy है", "Safe है"],
      "answer": 0,
      "explanation": "Dark Web पर ज़्यादातर चीज़ें illegal हैं। वहाँ से सामान खरीदना (जैसे stolen data, drugs, fake currencies) आपको कानूनी trouble में डाल सकता है। साथ ही scammers भरे हैं, आपको पैसे देने के बाद सामान नहीं मिलेगा या आपकी identity चोरी हो जाएगी।",
      "difficulty": "hard",
      "hint": "जहाँ काला बाज़ार हो, वहाँ मत जाओ।",
      "points": 20
    },
    {
      "question": "Tor Browser का उपयोग dark web के अलावा किस legitimate काम में होता है?",
      "options": ["Whistleblowers, journalists, activists, law enforcement for anonymous communication", "Online shopping", "Gaming", "Social media"],
      "answer": 0,
      "explanation": "Tor Browser कई legitimate users भी use करते हैं: whistleblowers (Wikileaks), journalists (sources से secure communication), activists (oppressive regimes में), और law enforcement (undercover operations) का use anonymous रहने के लिए।",
      "difficulty": "hard",
      "hint": "गुमनामी कभी-कभी जरूरी है।",
      "points": 20
    },
    {
      "question": "अपने online accounts को secure रखने के लिए 3 golden rules क्या हैं?",
      "options": ["1) Unique & strong passwords 2) 2FA on 3) Regular monitoring and backup", "Same password everywhere", "No 2FA", "Ignore security"],
      "answer": 0,
      "explanation": "Teen main rules: (1) Har account ke liye strong और unique password (password manager use करें), (2) Jahan possible ho 2FA enable करें (SMS nahi, authenticator app better), (3) Regular monitoring (suspicious activity check) और backups।",
      "difficulty": "medium",
      "hint": "तीन तीर, एक निशाना।",
      "points": 15
    },
    {
      "question": "SIM Swap Fraud क्या है?",
      "options": ["Hacker आपकी SIM card duplicate करवाकर आपके mobile number पर control ले लेता है (OTP intercept करके)", "New SIM लेना", "SIM card खराब होना", "Network change"],
      "answer": 0,
      "explanation": "SIM swap में hacker impersonate करके mobile operator से आपके number की duplicate SIM card ले लेता है। फिर आपका phone network से disconnected हो जाता है और hacker सारे OTP और calls receive कर सकता है। फिर bank accounts, UPI, email तक access कर सकता है। Bank और mobile operator से extra security (sim lock, port block) Lagwa sakte hain.",
      "difficulty": "hard",
      "hint": "आपकी SIM, आपके बिना।",
      "points": 20
    },
    {
      "question": "Remote Access Scam में scammers क्या करते हैं?",
      "options": ["बताते हैं 'computer problem ठीक कर देंगे', आपको TeamViewer, AnyDesk install करवाके remote access देने को कहते हैं, फिर आपके bank से पैसे निकाल लेते हैं", "Virus infection", "Phishing", "Malware"],
      "answer": 0,
      "explanation": "Scammers call करते हैं (Microsoft, bank, Amazon बताकर) कि 'आपके computer में virus है, हम remote access से ठीक कर देंगे'। वो आपको TeamViewer, AnyDesk, या UltraViewer install करवाते हैं और remote access लेकर आपके bank accounts से पैसे ट्रांसफर कर लेते हैं। कभी भी अनजान को remote access न दें।",
      "difficulty": "hard",
      "hint": "किसी को तुम्हारे कंप्यूटर में न आने दो।",
      "points": 20
    },
    {
      "question": "Ad Blocker क्यों उपयोगी है security के लिए?",
      "options": ["Malicious ads (malvertising) को block करता है जो malware deliver कर सकते हैं (drive-by downloads)", "Speed बढ़ाता है", "Data save करता है", "Battery बचाता है"],
      "answer": 0,
      "explanation": "Ad blockers सिर्फ website की annoyance ही नहीं हटाते, बल्कि malvertising (malicious ads) से भी बचाते हैं। कुछ ads में hidden malicious code होता है जिसे click न करने पर भी drive-by download के द्वारा malware install हो सकता है। uBlock Origin recommended है।",
      "difficulty": "medium",
      "hint": "बुरे ads को रोको।",
      "points": 15
    },
    {
      "question": "किसी डिवाइस को sell या recycle करने से पहले क्या करना चाहिए?",
      "options": ["पूरा storage wipe करें (factory reset के साथ overwrite करें), या disk encryption के बाद reset करें", "सिर्फ delete files", "Format करें", "बिना wipe के दे दें"],
      "answer": 0,
      "explanation": "सिर्फ delete करने से files recover हो सकती हैं। Secure erase करें: Windows PC पर 'Reset this PC' → 'Remove everything' → 'Clean drives fully'। Phone पर factory reset के बाद overwrite करें। प्रो way: DBAN (Darik's Boot and Nuke) या encrypted के बाद reset।",
      "difficulty": "hard",
      "hint": "पुराना डेटा पूरी तरह मिटाओ।",
      "points": 20
    },
    {
      "question": "Shoulder surfing क्या है?",
      "options": ["आपके पीछे खड़े होकर आपका password (या PIN) देख लेना जब आप type कर रहे हो", "Virus", "Malware", "Hacking"],
      "answer": 0,
      "explanation": "Shoulder surfing एक low-tech attack है - attacker आपके पीछे खड़ा होकर (या hidden camera लगाकर) आपको ATM PIN, phone passcode, या laptop password type करते हुए देख लेता है। Public places में सावधानी बरतें, screen को cover करें।",
      "difficulty": "easy",
      "hint": "कंधे पर नज़र।",
      "points": 10
    },
    {
      "question": "Session Hijacking क्या है?",
      "options": ["Attacker आपका session cookie चुराकर आपकी identity से (बिना password डाले) website में logged in रहता है", "Password steal", "MITM", "Phishing"],
      "answer": 0,
      "explanation": "जब आप website (जैसे Facebook) में login करते हैं, तो website एक temporary 'session cookie' आपके browser में रखती है। Hacker इस cookie को चुरा सकता है (MITM attack, क्रॉस-साइट स्क्रिप्टिंग, या malware द्वारा) और बिना password डाले आपके account में प्रवेश कर सकता है। Session hijacking से बचने के लिए HTTPS, VPN, और session timeout।",
      "difficulty": "hard",
      "hint": "कुकी चुराकर बिना पासवर्ड घुस जाना।",
      "points": 20
    },
    {
      "question": "Evil Twin Attack क्या है?",
      "options": ["Hacker एक fake WiFi access point बनाता है जो legitimate public WiFi (जैसे 'Starbucks WiFi') जैसा नाम होता है, आपसे connect करवाकर आपका data चुराता है", "Phishing", "MITM", "DDoS"],
      "answer": 0,
      "explanation": "Evil twin attack में hacker एक fake WiFi hotspot बनाता है जिसका SSID (नाम) legitimate WiFi (जैसे 'Airport_Free_WiFi', 'CoffeeShopWiFi') के समान होता है। जब आप connect करते हैं, attacker सारा traffic देख सकता है और sensitive जानकारी (passwords, emails) चुरा सकता है। Always verify hotspot with staff।",
      "difficulty": "hard",
      "hint": "जाली WiFi।",
      "points": 20
    },
    {
      "question": "स्मार्टफोन को malware से सुरक्षित रखने के लिए क्या करें?",
      "options": ["Only official app store (Google Play, Apple App Store) से apps install करें, unknown sources install न करें, apps की permissions check करें", "All apps install करें", "Permissions ignore करें", "Unknown sources on करें"],
      "answer": 0,
      "explanation": "Android में 'Install from unknown sources' बंद रखें। सिर्फ official app store से apps install करें। हर app install करते समय permissions (जैसे camera, contacts, location) देखें - कोई torch app contacts permission क्यों माँग रहा है? Suspicious apps को हटा दें।",
      "difficulty": "easy",
      "hint": "अनजान स्रोत से मत लगाओ।",
      "points": 10
    },
    {
      "question": "क्या Android phones को antivirus की जरूरत होती है?",
      "options": ["Google Play Protect built-in है, but extra antivirus may help for extreme cases. सिर्फ official store apps install करें तो ज्यादा जरूरत नहीं", "Yes, mandatory", "No need ever", "Only paid antivirus works"],
      "answer": 0,
      "explanation": "Android में Google Play Protect built-in malware scanner है। अगर आप केवल Play Store से apps install करते हैं और unknown sources से नहीं, तो extra antivirus की जरूरत नहीं। भारी भरकम 'antivirus' apps खुद adware हो सकती है। Be careful।",
      "difficulty": "medium",
      "hint": "जरूरत से ज्यादा संतरी भी खतरनाक।",
      "points": 15
    },
    {
      "question": "iPhone security में 'Walled Garden' क्या है?",
      "options": ["Apple का ecosystem जहाँ सिर्फ App Store से apps आती है (strict review) - malware का खतरा बहुत कम", "Garden", "Prison", "Open system"],
      "answer": 0,
      "explanation": "Apple का 'walled garden' approach है - iPhones पर apps सिर्फ Apple's App Store से आती हैं, जहाँ स्ट्रिक्ट review होता है। यह Android (जहाँ sideloading हो सकती है) से ज्यादा secure है, लेकिन flexibility कम है।",
      "difficulty": "medium",
      "hint": "बागान की दीवार सुरक्षित।",
      "points": 15
    },
    {
      "question": "Fake Mobile Charging Station (Juice Jacking) क्या है?",
      "options": ["Public USB charging ports (airport, mall) में malware डाला जा सकता है जो data चुरा ले", "Overcharging", "Fast charging", "Wireless charging"],
      "answer": 0,
      "explanation": "Juice jacking में hackers public USB charging stations को modify कर देते हैं ताकि वो phone से data चुरा सकें या malware install कर सकें। इससे बचने के लिए अपना charger और AC adapter use करें या USB data blocker (USB condom) use करें, या सिर्फ power-only USB cable use करें।",
      "difficulty": "hard",
      "hint": "चार्ज करो लेकिन डेटा मत दो।",
      "points": 20
    },
    {
      "question": "किसी suspicious link में click करने से पहले उसकी real URL कैसे देखें?",
      "options": ["Desktop: Hover करें (mouse ले जाओ, click न करो), Mobile: press and hold या URL preview देखें", "Click करें", "Copy link", "Ignore"],
      "answer": 0,
      "explanation": "Desktop browser में link पर mouse hover (ले जाएं, click न करें) करें - status bar (नीचे) या tooltip में real URL दिखता है। Mobile पर link को long-press (hold) करें, popup में URL preview दिखता है। Link shorteners (bit.ly, tinyurl) से भी बचें।",
      "difficulty": "easy",
      "hint": "बिना click किए देखो।",
      "points": 10
    },
    {
      "question": "रोजमर्रा के लिए सबसे safe email provider कौन सा है (privacy focused)?",
      "options": ["ProtonMail (end-to-end encrypted, zero access, Switzerland based)", "Gmail", "Outlook", "Yahoo"],
      "answer": 0,
      "explanation": "ProtonMail, Tutanota, Mailbox.org privacy-focussed email providers हैं जो zero-access encryption offer करते हैं - उनके servers पर भी emails encrypted रहते हैं। Gmail और Outlook convenient हैं लेकिन आपके emails scan करते हैं (ads, spam filtering के लिए)। Choose based on threat model।",
      "difficulty": "hard",
      "hint": "प्राइवेसी चाहिए तो।",
      "points": 20
    },
    {
      "question": "Metadata क्या होता है? (जो privacy risk बन सकता है)",
      "options": ["Data about data (photo में date, time, location, camera model), document में author, edit time", "Photo content", "File name", "Extension"],
      "answer": 0,
      "answerIndex": 0,
      "explanation": "Metadata 'डेटा के बारे में डेटा' है। Photos में EXIF metadata includes GPS coordinates, timestamp, camera model, and sometimes even device serial number। You share a photo, you might be sharing your home address! You can strip metadata using tools।",
      "difficulty": "hard",
      "hint": "तस्वीर अपने आप में जानकारी दे सकती है।",
      "points": 20
    },
    {
      "question": "How often should you change your passwords (according to modern security guidelines)?",
      "options": ["Only when you suspect a breach or every 1-2 years (forced frequent changes lead to weak passwords)", "Every month", "Every week", "Never"],
      "answer": 0,
      "explanation": "New NIST (National Institute of Standards) guidelines advise AGAINST forced periodic password changes (like every 60 days). This leads to weak, predictable passwords (Summer2024! -> Fall2024! etc). Only change when you suspect a compromise or after a data breach.",
      "difficulty": "hard",
      "hint": "बार-बार बदलना जरूरी नहीं, मजबूत रखो।",
      "points": 20
    },
    {
      "question": "Your organization's IT security team sends you an urgent email asking to 'verify your account' by clicking a link and entering password. What do you do?",
      "options": ["Report as suspicious/phishing without clicking link (call IT department using known phone number)", "Click link and verify", "Enter password", "Forward to colleague"],
      "answer": 0,
      "explanation": "यह classic phishing है। Legitimate IT कभी भी email में password reset link नहीं भेजेगा। Always report to IT, और कभी भी unsolicited email asking for password या verify account पर respond न करें।",
      "difficulty": "easy",
      "hint": "दो बार सोचो, क्लिक करने से पहले।",
      "points": 10
    },
    {
      "question": "Green padlock in browser address bar indicates...",
      "options": ["Connection is secure (HTTPS with valid certificate)", "Website is safe", "Website is authentic", "No viruses"],
      "answer": 0,
      "explanation": "Green padlock (or lock icon) यह बताता है कि website SSL/TLS certificate valid है और connection encrypted (HTTPS) है। यह website अपने आप की authenticity या safety की guarantee नहीं देता - phishing sites भी HTTPS use कर सकती हैं।",
      "difficulty": "easy",
      "hint": "Encryption to है, लेकिन पहचान सुनिश्चित नहीं।",
      "points": 10
    },
    {
      "question": "When using a password manager, what's the most important thing to protect?",
      "options": ["Master password (कभी किसी को न बताएँ, कहीं लिखकर न रखें)", "All other passwords", "Email", "Phone"],
      "answer": 0,
      "explanation": "Password manager की security उसके master password पर निर्भर करती है (one key to all locks). Master password strong, long, unique होना चाहिए और आपको याद होना चाहिए। Use 2FA (like authenticator app) with password manager।",
      "difficulty": "medium",
      "hint": "जिससे सब खुलता है, उसे बचाओ।",
      "points": 15
    },
    {
      "question": "What is 'security through obscurity'? And why is it bad?",
      "options": ["Believing that hiding something (like changing SSH port from 22 to 2222) is secure. It's bad because it's not real security (hackers can find it easily)", "Real encryption", "Strong password", "Firewall"],
      "answer": 0,
      "explanation": "Security through obscurity छुपाकर सुरक्षा का false sense है। यह real security नहीं है, क्योंकि attacker को जैसे ही secret पता चलता है (या वो scratch करता है) सब खत्म। Real security defense in depth: encryption, authentication, patching।",
      "difficulty": "hard",
      "hint": "छुपना safe नहीं है।",
      "points": 20
    },
    {
      "question": "What action should you take if your online account is compromised?",
      "options": ["Change password immediately, enable/check 2FA, check for any unauthorized changes, check 'logged in devices'", "Ignore", "Delete account", "Call hacker"],
      "answer": 0,
      "explanation": "Steps: 1) Change password immediately (unique new password). 2) Enable 2FA if not already. 3) Check account settings (email forward rules, recovery email changed?). 4) Log out all unknown devices. 5) Check if any damage (emails sent, purchases made).",
      "difficulty": "medium",
      "hint": "जल्दी से कार्यवाही।",
      "points": 15
    },
    {
      "question": "What does 'incognito mode' NOT protect against?",
      "options": ["ISP tracking, employer monitoring, downloaded files, bookmarks, malware", "Local browsing history", "Cookies", "Form data"],
      "answer": 0,
      "explanation": "Incognito mode सिर्फ local device पर browsing history, cookies, form data साफ करता है। यह आपको ISP, employer, government, या visited websites से नहीं छुपाता। DNS requests still visible। For real anonymity you need Tor + VPN.",
      "difficulty": "medium",
      "hint": "घर में तो अँधेरा, बाहर सब दिखेगा।",
      "points": 15
    },
    {
      "question": "QR code scanning related security risk क्या है?",
      "options": ["QR code किसी malicious URL (phishing site या malware download) को छुपा सकता है", "QR code steal data", "QR code virus", "QR code battery drain"],
      "answer": 0,
      "explanation": "Attackers stickers को legitimate QR codes के ऊपर लगा देते हैं (parking meters, restaurants). जब आप scan करते हैं, तो आप malicious website पर चले जाते हैं जो password माँगे या malware download करवाए। Always check URL after scanning before clicking.",
      "difficulty": "medium",
      "hint": "QR कोड के पीछे क्या है, देखो।",
      "points": 15
    },
    {
      "question": "Sensor-based tracking क्या है? (smartphone privacy)",
      "options": ["Apps use accelerometer, gyroscope data से fingerprint बना सकते हैं (बिना permission के भी)", "GPS tracking", "Camera tracking", "Microphone tracking"],
      "answer": 0,
      "explanation": "Even without GPS, apps can use motion sensors (accelerometer, gyroscope) to create a unique 'fingerprint' of your device for tracking across apps. Some browsers now limit sensor access for privacy.",
      "difficulty": "hard",
      "hint": "आपकी चाल बता सकती है कि आप कौन हैं।",
      "points": 20
    },
    {
      "question": "Paper-based security: What is a 'burn bag' in corporate security?",
      "options": ["Container for shredding sensitive documents (never throw confidential papers in trash)", "Fire-proof bag", "Recycle bin", "Trash can"],
      "answer": 0,
      "explanation": "Physical security equally important. Sensitive papers (bank statements, medical records, confidential business docs) should be shredded (cross-cut) before disposal. Dumpster diving एक real threat है।",
      "difficulty": "medium",
      "hint": "कागज भी गोपनीय हो सकता है।",
      "points": 15
    },
    {
      "question": "WiFi Pineapple (network device) किस attack में use होता है?",
      "options": ["Evil twin / Rogue access point (MITM attack)", "Password cracking", "DDoS", "Virus spread"],
      "answer": 0,
      "explanation": "WiFi Pineapple एक commercial device है जो legitimate WiFi networks impersonate करता है (evil twin attack). बिना suspicious के devices automatically इससे connect हो जाती हैं, और attacker traffic monitor और modify कर सकता है। Security testing में use होता है, लेकिन malicious actors भी use करते हैं।",
      "difficulty": "hard",
      "hint": "WiFi का जाल।",
      "points": 20
    },
    {
      "question": "FIDO2/WebAuthn क्या है?",
      "options": ["Passwordless authentication standard using biometrics or security key (YubiKey)", "New password", "2FA method", "VPN"],
      "answer": 0,
      "explanation": "FIDO2 (Fast Identity Online) passwordless authentication standard है। आप एक physical security key (जैसे YubiKey) या biometric (face, fingerprint) से login कर सकते हैं। यह phishing के लिए immune है क्योंकि authentication domain-specific होती है।",
      "difficulty": "hard",
      "hint": "बिना पासवर्ड के, सुरक्षित।",
      "points": 20
    },
    {
      "question": "When setting up a new router, what security steps are essential?",
      "options": ["Change default admin password, update firmware, enable WPA3/WPA2, disable WPS, change SSID (don't reveal make/model)", "Plug and play", "Keep default password", "Keep WPS on"],
      "answer": 0,
      "explanation": "Default राउटर passwords (admin/admin) hackers well-known हैं। Immediately change. Disable WPS (WiFi Protected Setup) - it has vulnerabilities. Update firmware for security patches. WPA3 (or WPA2) encryption enable करें। Don't put your address as SSID.",
      "difficulty": "hard",
      "hint": "राउटर ही बचाएगा या डुबोएगा।",
      "points": 20
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