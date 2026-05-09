import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ============================================================
// DATA MODELS
// ============================================================

class StudentProgress {
  int coins;
  int xp;
  int level;
  int rank;
  int streak;
  int totalQuizzes;
  int correctAnswers;
  String rankTitle;
  String avatarId;
  String themeId;
  DateTime lastLoginDate;
  List<String> achievements;
  Map<String, int> subjectProgress;
  String nickname;
  String realName;
  int reputation;
  String clanId;
  List<String> inventory;
  List<String> shopPurchases;
  int dailyStreakRewardClaimed;
  int weeklyStreakRewardClaimed;
  List<Map<String, dynamic>> activityHistory;
  List<Map<String, dynamic>> rewardHistory;
  List<String> notifications;
  Map<String, dynamic> settings;
  int totalCoinsEarned;
  int totalXPEarned;
  int perfectQuizCount;
  int comboCount;
  int speedBonusCount;
  String currentBannerId;
  int prestigeLevel;
  int reputationPoints;
  List<Map<String, dynamic>> missionHistory;
  Map<String, int> weeklyXP;
  Map<String, int> monthlyXP;
  int luckySpinCount;
  int chestCount;
  List<String> unlockedWorlds;
  List<String> equippedEffects;
  int survivalHighScore;
  int bossQuizzesCompleted;
  Map<String, dynamic> clanData;
  List<String> friendIds;
  int rankBattleWins;
  List<Map<String, dynamic>> loginHistory;
  Map<String, int> subjectChampion;
  String frame;
  bool isBanned;
  bool isMuted;
  int streakFreezes;

  StudentProgress({
    this.coins = 0,
    this.xp = 0,
    this.level = 1,
    this.rank = 999,
    this.streak = 0,
    this.totalQuizzes = 0,
    this.correctAnswers = 0,
    this.rankTitle = 'Beginner',
    this.avatarId = '🔥',
    this.themeId = 'default',
    DateTime? lastLoginDate,
    this.achievements = const [],
    this.subjectProgress = const {},
    this.nickname = '',
    this.realName = '',
    this.reputation = 0,
    this.clanId = '',
    this.inventory = const [],
    this.shopPurchases = const [],
    this.dailyStreakRewardClaimed = 0,
    this.weeklyStreakRewardClaimed = 0,
    this.activityHistory = const [],
    this.rewardHistory = const [],
    this.notifications = const [],
    this.settings = const {},
    this.totalCoinsEarned = 0,
    this.totalXPEarned = 0,
    this.perfectQuizCount = 0,
    this.comboCount = 0,
    this.speedBonusCount = 0,
    this.currentBannerId = 'default',
    this.prestigeLevel = 0,
    this.reputationPoints = 0,
    this.missionHistory = const [],
    this.weeklyXP = const {},
    this.monthlyXP = const {},
    this.luckySpinCount = 0,
    this.chestCount = 0,
    this.unlockedWorlds = const [],
    this.equippedEffects = const [],
    this.survivalHighScore = 0,
    this.bossQuizzesCompleted = 0,
    this.clanData = const {},
    this.friendIds = const [],
    this.rankBattleWins = 0,
    this.loginHistory = const [],
    this.subjectChampion = const {},
    this.frame = 'default',
    this.isBanned = false,
    this.isMuted = false,
    this.streakFreezes = 0,
  }) : lastLoginDate = lastLoginDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'xp': xp,
    'level': level,
    'rank': rank,
    'streak': streak,
    'totalQuizzes': totalQuizzes,
    'correctAnswers': correctAnswers,
    'rankTitle': rankTitle,
    'avatarId': avatarId,
    'themeId': themeId,
    'lastLoginDate': lastLoginDate.toIso8601String(),
    'achievements': achievements,
    'subjectProgress': subjectProgress,
    'nickname': nickname,
    'realName': realName,
    'reputation': reputation,
    'clanId': clanId,
    'inventory': inventory,
    'shopPurchases': shopPurchases,
    'dailyStreakRewardClaimed': dailyStreakRewardClaimed,
    'weeklyStreakRewardClaimed': weeklyStreakRewardClaimed,
    'activityHistory': activityHistory,
    'rewardHistory': rewardHistory,
    'notifications': notifications,
    'settings': settings,
    'totalCoinsEarned': totalCoinsEarned,
    'totalXPEarned': totalXPEarned,
    'perfectQuizCount': perfectQuizCount,
    'comboCount': comboCount,
    'speedBonusCount': speedBonusCount,
    'currentBannerId': currentBannerId,
    'prestigeLevel': prestigeLevel,
    'reputationPoints': reputationPoints,
    'missionHistory': missionHistory,
    'weeklyXP': weeklyXP,
    'monthlyXP': monthlyXP,
    'luckySpinCount': luckySpinCount,
    'chestCount': chestCount,
    'unlockedWorlds': unlockedWorlds,
    'equippedEffects': equippedEffects,
    'survivalHighScore': survivalHighScore,
    'bossQuizzesCompleted': bossQuizzesCompleted,
    'clanData': clanData,
    'friendIds': friendIds,
    'rankBattleWins': rankBattleWins,
    'loginHistory': loginHistory,
    'subjectChampion': subjectChampion,
    'frame': frame,
    'isBanned': isBanned,
    'isMuted': isMuted,
    'streakFreezes': streakFreezes,
  };

  factory StudentProgress.fromJson(
    Map<String, dynamic> json,
  ) => StudentProgress(
    coins: json['coins'] ?? 0,
    xp: json['xp'] ?? 0,
    level: json['level'] ?? 1,
    rank: json['rank'] ?? 999,
    streak: json['streak'] ?? 0,
    totalQuizzes: json['totalQuizzes'] ?? 0,
    correctAnswers: json['correctAnswers'] ?? 0,
    rankTitle: json['rankTitle'] ?? 'Beginner',
    avatarId: json['avatarId'] ?? '🔥',
    themeId: json['themeId'] ?? 'default',
    lastLoginDate: json['lastLoginDate'] != null
        ? DateTime.parse(json['lastLoginDate'])
        : DateTime.now(),
    achievements: List<String>.from(json['achievements'] ?? []),
    subjectProgress: Map<String, int>.from(json['subjectProgress'] ?? {}),
    nickname: json['nickname'] ?? '',
    realName: json['realName'] ?? '',
    reputation: json['reputation'] ?? 0,
    clanId: json['clanId'] ?? '',
    inventory: List<String>.from(json['inventory'] ?? []),
    shopPurchases: List<String>.from(json['shopPurchases'] ?? []),
    dailyStreakRewardClaimed: json['dailyStreakRewardClaimed'] ?? 0,
    weeklyStreakRewardClaimed: json['weeklyStreakRewardClaimed'] ?? 0,
    activityHistory: List<Map<String, dynamic>>.from(
      json['activityHistory'] ?? [],
    ),
    rewardHistory: List<Map<String, dynamic>>.from(json['rewardHistory'] ?? []),
    notifications: List<String>.from(json['notifications'] ?? []),
    settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    totalCoinsEarned: json['totalCoinsEarned'] ?? 0,
    totalXPEarned: json['totalXPEarned'] ?? 0,
    perfectQuizCount: json['perfectQuizCount'] ?? 0,
    comboCount: json['comboCount'] ?? 0,
    speedBonusCount: json['speedBonusCount'] ?? 0,
    currentBannerId: json['currentBannerId'] ?? 'default',
    prestigeLevel: json['prestigeLevel'] ?? 0,
    reputationPoints: json['reputationPoints'] ?? 0,
    missionHistory: List<Map<String, dynamic>>.from(
      json['missionHistory'] ?? [],
    ),
    weeklyXP: Map<String, int>.from(json['weeklyXP'] ?? {}),
    monthlyXP: Map<String, int>.from(json['monthlyXP'] ?? {}),
    luckySpinCount: json['luckySpinCount'] ?? 0,
    chestCount: json['chestCount'] ?? 0,
    unlockedWorlds: List<String>.from(json['unlockedWorlds'] ?? []),
    equippedEffects: List<String>.from(json['equippedEffects'] ?? []),
    survivalHighScore: json['survivalHighScore'] ?? 0,
    bossQuizzesCompleted: json['bossQuizzesCompleted'] ?? 0,
    clanData: Map<String, dynamic>.from(json['clanData'] ?? {}),
    friendIds: List<String>.from(json['friendIds'] ?? []),
    rankBattleWins: json['rankBattleWins'] ?? 0,
    loginHistory: List<Map<String, dynamic>>.from(json['loginHistory'] ?? []),
    subjectChampion: Map<String, int>.from(json['subjectChampion'] ?? {}),
    frame: json['frame'] ?? 'default',
    isBanned: json['isBanned'] ?? false,
    isMuted: json['isMuted'] ?? false,
    streakFreezes: json['streakFreezes'] ?? 0,
  );
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final int xpReward;
  final int coinReward;
  final String difficulty;
  final String subject;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.xpReward = 20,
    this.coinReward = 5,
    this.difficulty = 'Easy',
    required this.subject,
  });
}

class QuizResult {
  final int score, total, coinsEarned, xpEarned;
  final String subject;
  final bool isPerfect;
  QuizResult({
    required this.score,
    required this.total,
    required this.coinsEarned,
    required this.xpEarned,
    required this.subject,
    this.isPerfect = false,
  });
}

// ============================================================
// QUIZ DATA (HARDCODED)
// ============================================================

const Map<String, List<QuizQuestion>> kQuizData = {
  'C Programming': [
    QuizQuestion(
      question: 'What is the size of int in C (32-bit)?',
      options: ['2 bytes', '4 bytes', '8 bytes', '1 byte'],
      correctIndex: 1,
      subject: 'C Programming',
    ),
    QuizQuestion(
      question: 'Which operator is used for pointer dereferencing?',
      options: ['&', '*', '->', '.'],
      correctIndex: 1,
      xpReward: 25,
      coinReward: 8,
      subject: 'C Programming',
    ),
    QuizQuestion(
      question: 'What does malloc() return?',
      options: ['void*', 'int*', 'char*', 'NULL pointer'],
      correctIndex: 0,
      xpReward: 35,
      coinReward: 12,
      difficulty: 'Hard',
      subject: 'C Programming',
    ),
    QuizQuestion(
      question: 'Which header file is used for string functions?',
      options: ['stdio.h', 'string.h', 'stdlib.h', 'math.h'],
      correctIndex: 1,
      xpReward: 20,
      coinReward: 5,
      subject: 'C Programming',
    ),
    QuizQuestion(
      question: 'What is the output of sizeof(char)?',
      options: ['2', '4', '1', '8'],
      correctIndex: 2,
      xpReward: 25,
      coinReward: 8,
      difficulty: 'Medium',
      subject: 'C Programming',
    ),
  ],
  'Python': [
    QuizQuestion(
      question: 'Which of these is a mutable data type?',
      options: ['tuple', 'string', 'list', 'int'],
      correctIndex: 2,
      subject: 'Python',
    ),
    QuizQuestion(
      question: "What is the output of type([])?",
      options: ['list', '<class list>', "<class 'list'>", 'array'],
      correctIndex: 2,
      xpReward: 25,
      coinReward: 8,
      subject: 'Python',
    ),
    QuizQuestion(
      question: 'Which keyword defines a generator?',
      options: ['return', 'yield', 'async', 'gen'],
      correctIndex: 1,
      xpReward: 35,
      coinReward: 12,
      difficulty: 'Hard',
      subject: 'Python',
    ),
    QuizQuestion(
      question: 'What does len() return for an empty list?',
      options: ['null', '-1', '0', 'None'],
      correctIndex: 2,
      subject: 'Python',
    ),
    QuizQuestion(
      question: 'Which method adds an element to a list?',
      options: ['add()', 'push()', 'append()', 'insert()'],
      correctIndex: 2,
      xpReward: 20,
      coinReward: 5,
      subject: 'Python',
    ),
  ],
  'DBMS': [
    QuizQuestion(
      question: 'What does SQL stand for?',
      options: [
        'Structured Query Language',
        'Simple Query Language',
        'System Query Language',
        'Standard Query Language',
      ],
      correctIndex: 0,
      subject: 'DBMS',
    ),
    QuizQuestion(
      question: 'Which key uniquely identifies a record?',
      options: ['Foreign Key', 'Primary Key', 'Composite Key', 'Alternate Key'],
      correctIndex: 1,
      xpReward: 25,
      coinReward: 8,
      subject: 'DBMS',
    ),
    QuizQuestion(
      question: 'What is normalization?',
      options: [
        'Sorting data',
        'Reducing redundancy',
        'Encrypting data',
        'Indexing',
      ],
      correctIndex: 1,
      xpReward: 30,
      coinReward: 10,
      difficulty: 'Medium',
      subject: 'DBMS',
    ),
    QuizQuestion(
      question: 'Which SQL command retrieves data?',
      options: ['INSERT', 'UPDATE', 'SELECT', 'DELETE'],
      correctIndex: 2,
      subject: 'DBMS',
    ),
  ],
  'Networking': [
    QuizQuestion(
      question: 'What does IP stand for?',
      options: [
        'Internet Protocol',
        'Internal Protocol',
        'Interconnect Protocol',
        'International Protocol',
      ],
      correctIndex: 0,
      subject: 'Networking',
    ),
    QuizQuestion(
      question: 'Which layer is responsible for routing?',
      options: ['Physical', 'Data Link', 'Network', 'Transport'],
      correctIndex: 2,
      xpReward: 25,
      coinReward: 8,
      subject: 'Networking',
    ),
    QuizQuestion(
      question: 'What is the default port for HTTP?',
      options: ['21', '80', '443', '22'],
      correctIndex: 1,
      subject: 'Networking',
    ),
    QuizQuestion(
      question: 'What does DNS stand for?',
      options: [
        'Domain Name System',
        'Data Network Service',
        'Domain Network Service',
        'Data Name System',
      ],
      correctIndex: 0,
      xpReward: 20,
      coinReward: 5,
      subject: 'Networking',
    ),
  ],
  'Mathematics': [
    QuizQuestion(
      question: 'What is the derivative of sin(x)?',
      options: ['cos(x)', '-cos(x)', 'sin(x)', '-sin(x)'],
      correctIndex: 0,
      subject: 'Mathematics',
    ),
    QuizQuestion(
      question: 'What is the value of π (pi) to 2 decimals?',
      options: ['3.12', '3.14', '3.16', '3.18'],
      correctIndex: 1,
      xpReward: 25,
      coinReward: 8,
      subject: 'Mathematics',
    ),
    QuizQuestion(
      question: 'What is 7 factorial (7!)?',
      options: ['720', '5040', '4320', '2520'],
      correctIndex: 1,
      xpReward: 30,
      coinReward: 10,
      difficulty: 'Medium',
      subject: 'Mathematics',
    ),
    QuizQuestion(
      question: 'What is the integral of 1/x?',
      options: ['ln|x|', 'x', '1/x²', 'e^x'],
      correctIndex: 0,
      xpReward: 35,
      coinReward: 12,
      difficulty: 'Hard',
      subject: 'Mathematics',
    ),
  ],
  'English': [
    QuizQuestion(
      question: 'Which word is a synonym for "happy"?',
      options: ['Sad', 'Joyful', 'Angry', 'Tired'],
      correctIndex: 1,
      subject: 'English',
    ),
    QuizQuestion(
      question: 'What is the past tense of "go"?',
      options: ['Went', 'Gone', 'Goed', 'Going'],
      correctIndex: 0,
      xpReward: 25,
      coinReward: 8,
      subject: 'English',
    ),
    QuizQuestion(
      question: 'What is an antonym of "ancient"?',
      options: ['Old', 'Historical', 'Modern', 'Classic'],
      correctIndex: 2,
      subject: 'English',
    ),
    QuizQuestion(
      question: 'Identify the noun: "The dog runs fast."',
      options: ['runs', 'fast', 'The', 'dog'],
      correctIndex: 3,
      xpReward: 20,
      coinReward: 5,
      subject: 'English',
    ),
  ],
  'Aptitude': [
    QuizQuestion(
      question: 'If a train travels 120 km in 2 hours, what is its speed?',
      options: ['40 km/h', '60 km/h', '80 km/h', '100 km/h'],
      correctIndex: 1,
      subject: 'Aptitude',
    ),
    QuizQuestion(
      question: 'What is 15% of 200?',
      options: ['20', '25', '30', '35'],
      correctIndex: 2,
      xpReward: 25,
      coinReward: 8,
      subject: 'Aptitude',
    ),
    QuizQuestion(
      question:
          'A shop gives 20% discount. Price is ₹800. Find original price.',
      options: ['₹900', '₹960', '₹1000', '₹1200'],
      correctIndex: 2,
      xpReward: 30,
      coinReward: 10,
      difficulty: 'Medium',
      subject: 'Aptitude',
    ),
    QuizQuestion(
      question: 'Find the next in series: 2, 4, 8, 16, ?',
      options: ['24', '32', '30', '20'],
      correctIndex: 1,
      subject: 'Aptitude',
    ),
  ],
  'Computer Fundamentals': [
    QuizQuestion(
      question: 'What is the brain of the computer?',
      options: ['CPU', 'RAM', 'Hard Disk', 'Motherboard'],
      correctIndex: 0,
      subject: 'Computer Fundamentals',
    ),
    QuizQuestion(
      question: 'Which of these is an output device?',
      options: ['Mouse', 'Keyboard', 'Monitor', 'Scanner'],
      correctIndex: 2,
      xpReward: 25,
      coinReward: 8,
      subject: 'Computer Fundamentals',
    ),
    QuizQuestion(
      question: '1 KB equals how many bytes?',
      options: ['1000', '1024', '512', '2048'],
      correctIndex: 1,
      subject: 'Computer Fundamentals',
    ),
    QuizQuestion(
      question: 'What does RAM stand for?',
      options: [
        'Read Access Memory',
        'Random Access Memory',
        'Read Arithmetic Memory',
        'Random Arithmetic Memory',
      ],
      correctIndex: 1,
      xpReward: 20,
      coinReward: 5,
      subject: 'Computer Fundamentals',
    ),
  ],
};

// ============================================================
// CONSTANTS & THEME
// ============================================================

class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF43A047);
  static const accent = Color(0xFF1565C0);
  static const gold = Color(0xFFFFD700);
  static const silver = Color(0xFFC0C0C0);
  static const bronze = Color(0xFFCD7F32);
  static const background = Color(0xFFF8FFF8);
  static const surface = Colors.white;
  static const danger = Color(0xFFE53935);
  static const success = Color(0xFF43A047);
  static const xpPurple = Color(0xFF7B1FA2);
  static const coinAmber = Color(0xFFFF8F00);
  static const streakOrange = Color(0xFFE65100);
  static const gradientStart = Color(0xFF1B5E20);
  static const gradientEnd = Color(0xFF1565C0);
  static const cardShadow = Color(0x1A000000);
  static const adminPrimary = Color(0xFF0D1B2A);
  static const adminAccent = Color(0xFF1E90FF);
  static const adminCard = Color(0xFF162032);
}

const kRankTitles = [
  (0, 'Beginner', '🌱'),
  (500, 'Bronze', '🥉'),
  (1500, 'Silver', '🥈'),
  (3000, 'Gold', '🥇'),
  (5000, 'Platinum', '💎'),
  (10000, 'Diamond', '💠'),
  (20000, 'Master', '👑'),
  (50000, 'Legend', '🌟'),
];

const kAvatars = [
  '🦁',
  '🐯',
  '🦊',
  '🐺',
  '🦝',
  '🐸',
  '🦄',
  '🐲',
  '🤖',
  '👾',
  '🎭',
  '🔥',
  '🐵',
  '🦅',
  '🦉',
  '🐼',
  '🐨',
  '🐻',
  '🐹',
  '🐰',
  '🦓',
  '🦍',
  '🦈',
  '🐬',
  '🐙',
  '🦂',
  '🐢',
  '🐍',
  '🦖',
  '🦕',
  '🐧',
  '🦜',
  '🦚',
  '🦋',
  '🐞',
  '🐝',
  '🕷️',
  '👑',
  '⚡',
  '🌟',
  '💀',
  '☠️',
  '👽',
  '🛸',
  '🚀',
  '🎮',
  '🧠',
  '💎',
  '🛡️',
  '⚔️',

  '🐱',
  '🐶',
  '🐭',
  '🐗',
  '🦌',
  '🦬',
  '🐴',
  '🫎',
  '🐐',
  '🐑',
  '🐪',
  '🐫',
  '🦙',
  '🦒',
  '🐘',
  '🦏',
  '🦛',
  '🐊',
  '🦎',
  '🐌',
  '🐜',
  '🪲',
  '🪳',
  '🦟',
  '🪰',
  '🪱',
  '🐠',
  '🐟',
  '🐡',
  '🦐',
  '🦑',
  '🦞',
  '🦀',
  '🐳',
  '🐋',
  '🦭',
  '🪼',
  '🦢',
  '🦩',
  '🕊️',
  '🦤',
  '🪿',
  '🐓',
  '🦃',
  '🦆',
  '🦇',
  '🐿️',
  '🦔',
  '🦦',
  '🦥',

  '😀',
  '😎',
  '🤩',
  '🥶',
  '😈',
  '👹',
  '👺',
  '🤡',
  '👻',
  '💩',
  '👑',
  '💥',
  '✨',
  '🌈',
  '🌙',
  '☀️',
  '🌪️',
  '❄️',
  '☄️',
  '🌋',
  '🎯',
  '🏆',
  '🥇',
  '🥈',
  '🥉',
  '🎲',
  '🧩',
  '🎸',
  '🎹',
  '🥁',
  '📚',
  '💻',
  '⌨️',
  '🖥️',
  '📱',
  '📷',
  '🎥',
  '📡',
  '🔮',
  '🧪',
  '⚙️',
  '🔧',
  '🛠️',
  '🪄',
  '🧿',
  '📀',
  '💿',
  '🕹️',
  '🎰',
  '🎨',

  '🍎',
  '🍕',
  '🍔',
  '🌮',
  '🍣',
  '🍩',
  '🍪',
  '🍫',
  '🍿',
  '🧃',
  '☕',
  '🧋',
  '🍉',
  '🍇',
  '🍓',
  '🍒',
  '🥭',
  '🍍',
  '🥥',
  '🥝',
  '🌵',
  '🌴',
  '🌲',
  '🌳',
  '🍁',
  '🍂',
  '🌸',
  '🌺',
  '🌻',
  '🌼',
  '🏀',
  '⚽',
  '🏈',
  '⚾',
  '🎾',
  '🏐',
  '🏓',
  '🥊',
  '🥋',
  '⛳',
  '🚗',
  '🏎️',
  '🚓',
  '🚑',
  '🚒',
  '✈️',
  '🚁',
  '🚂',
  '🚀',
  '🛸',

  '🔱',
  '🪓',
  '🔨',
  '🗡️',
  '🏹',
  '🛡️',
  '⚔️',
  '💣',
  '🧨',
  '🔫',
  '🎖️',
  '🏵️',
  '🎗️',
  '📛',
  '🔰',
  '🪙',
  '💰',
  '💵',
  '💳',
  '📈',
  '🕶️',
  '👟',
  '🎒',
  '⌚',
  '💍',
  '👒',
  '🧢',
  '🎩',
  '🪖',
  '🥽',
  '🛋️',
  '🛏️',
  '🚪',
  '🪑',
  '🪞',
  '🧸',
  '🎁',
  '🪅',
  '🎈',
  '🎊',

  '🧬',
  '🛰️',
  '🌌',
  '🪐',
  '⭐',
  '🌠',
  '🌍',
  '🌎',
  '🌏',
  '☄️',
  '📖',
  '✏️',
  '📘',
  '📗',
  '📕',
  '📙',
  '📓',
  '📒',
  '🗂️',
  '📂',
  '📎',
  '📌',
  '✂️',
  '🖊️',
  '🖍️',
  '📏',
  '📐',
  '🧮',
  '🔬',
  '🔭',
  '⚕️',
  '🩺',
  '💉',
  '🩹',
  '🧫',
  '🧯',
  '🚨',
  '🔐',
  '🔑',
  '🗝️',

  '🎤',
  '🎧',
  '📻',
  '📺',
  '🎬',
  '🎼',
  '🎻',
  '🎷',
  '🪗',
  '🎺',
  '🪘',
  '🎹',
  '🎚️',
  '🎛️',
  '📀',
  '💽',
  '📼',
  '📹',
  '📽️',
  '🔊',
  '🌐',
  '📶',
  '📡',
  '🛰️',
  '💡',
  '🔦',
  '🕯️',
  '🪔',
  '⚡',
  '🔋',
  '🪫',
  '🔌',
  '💻',
  '🖨️',
  '⌨️',
  '🖱️',
  '🖲️',
  '💾',
  '💿',
  '📀',

  '🧊',
  '🔥',
  '💧',
  '🌊',
  '🌪️',
  '🌫️',
  '🌈',
  '⛈️',
  '🌤️',
  '☁️',
  '☔',
  '❄️',
  '☃️',
  '⛄',
  '🌞',
  '🌝',
  '🌚',
  '🌛',
  '🌜',
  '⭐',
];
const kFrames = ['default', 'gold', 'diamond', 'fire', 'ice', 'neon'];

// ============================================================
// ADMIN CONSTANTS — NEVER EXPOSE TO STUDENTS
// ============================================================

class _AdminSecurity {
  static const String _adminName = 'KYP09060019';
  static const String _adminPin = '202601';

  static bool validateAdmin(String name, String pin) =>
      name.trim() == _adminName && pin.trim() == _adminPin;
}

// ============================================================
// OFFLINE STORAGE SERVICE
// ============================================================

class OfflineStorageService {
  static const String _keyStudentProgress = 'student_progress';
  static const String _keyPendingSync = 'pending_sync';
  static const String _keyLastSync = 'last_sync';

  static Future<SharedPreferences> _getPrefs() async =>
      await SharedPreferences.getInstance();

  static Future<void> saveProgress(StudentProgress progress) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_keyStudentProgress, jsonEncode(progress.toJson()));
    } catch (e) {
      debugPrint('Error saving progress locally: $e');
    }
  }

  static Future<StudentProgress?> loadProgress() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_keyStudentProgress);
      if (jsonString != null)
        return StudentProgress.fromJson(jsonDecode(jsonString));
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
    return null;
  }

  static Future<void> addToPendingSync(Map<String, dynamic> quizResult) async {
    try {
      final prefs = await _getPrefs();
      final pending = prefs.getStringList(_keyPendingSync) ?? [];
      pending.add(jsonEncode(quizResult));
      await prefs.setStringList(_keyPendingSync, pending);
    } catch (e) {
      debugPrint('Error adding to pending sync: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingSync() async {
    try {
      final prefs = await _getPrefs();
      final pending = prefs.getStringList(_keyPendingSync) ?? [];
      return pending.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearPendingSync() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_keyPendingSync);
    } catch (e) {}
  }

  static Future<void> setLastSync(DateTime time) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_keyLastSync, time.toIso8601String());
    } catch (e) {}
  }

  static Future<DateTime?> getLastSync() async {
    try {
      final prefs = await _getPrefs();
      final t = prefs.getString(_keyLastSync);
      return t != null ? DateTime.parse(t) : null;
    } catch (e) {
      return null;
    }
  }
}

// ============================================================
// FIREBASE SYNC SERVICE
// ============================================================

class FirebaseSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isLoggedIn => _auth.currentUser != null;
  String? get userId => _auth.currentUser?.uid;

  Future<bool> syncProgress(StudentProgress progress) async {
    if (!isLoggedIn) return false;
    try {
      await _firestore
          .collection('students')
          .doc(userId)
          .set(progress.toJson(), SetOptions(merge: true));
      await OfflineStorageService.setLastSync(DateTime.now());
      return true;
    } catch (e) {
      debugPrint('Error syncing to Firebase: $e');
      return false;
    }
  }

  Future<StudentProgress?> loadFromFirebase() async {
    if (!isLoggedIn) return null;
    try {
      final doc = await _firestore.collection('students').doc(userId).get();
      if (doc.exists && doc.data() != null)
        return StudentProgress.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Error loading from Firebase: $e');
    }
    return null;
  }

  Future<void> syncPendingQuizzes() async {
    if (!isLoggedIn) return;
    final pending = await OfflineStorageService.getPendingSync();
    if (pending.isEmpty) return;
    final batch = _firestore.batch();
    final userRef = _firestore.collection('students').doc(userId);
    for (final quiz in pending) {
      batch.set(userRef, quiz, SetOptions(merge: true));
    }
    try {
      await batch.commit();
      await OfflineStorageService.clearPendingSync();
    } catch (e) {
      debugPrint('Error syncing pending quizzes: $e');
    }
  }

  Future<Map<String, dynamic>?> authenticateStudent(
    String nickname,
    String pin,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('nickname', isEqualTo: nickname)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return null;
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      if (data['pin'] == pin) {
        await _auth.signInWithCustomToken(doc.id);
        return {'id': doc.id, ...data};
      }
      return null;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> leaderboardStream() => _firestore
      .collection('students')
      .orderBy('xp', descending: true)
      .limit(50)
      .snapshots();

  // ADMIN FUNCTIONS — SECURE FIRESTORE WRITES
  Future<String?> adminCreateStudent({
    required String nickname,
    required String realName,
    required String pin,
    required String avatarId,
    int coins = 0,
    int xp = 0,
    int level = 1,
  }) async {
    try {
      // Sanitize inputs
      final cleanNickname = nickname.trim();
      final cleanRealName = realName.trim();
      if (cleanNickname.isEmpty || pin.length != 6) return 'Invalid data';

      // Check duplicate
      final existing = await _firestore
          .collection('students')
          .where('nickname', isEqualTo: cleanNickname)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) return 'Nickname already exists';

      final docRef = _firestore.collection('students').doc();
      final now = DateTime.now().toIso8601String();
      await docRef.set({
        ...StudentProgress(
          nickname: cleanNickname,
          realName: cleanRealName,
          avatarId: avatarId,
          coins: coins,
          xp: xp,
          level: level,
        ).toJson(),
        'pin': pin,
        'createdAt': now,
        'createdBy': 'admin',
        'role': 'student',
      });
      await _logAdminAction(
        'create_student',
        'Created student: $cleanNickname',
      );
      return null; // success
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> adminUpdateStudent(
    String docId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Never allow updating security-sensitive fields via student path
      updates.remove('role');
      updates.remove('createdBy');
      await _firestore.collection('students').doc(docId).update(updates);
      await _logAdminAction('update_student', 'Updated student doc: $docId');
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> adminDeleteStudent(String docId) async {
    try {
      await _firestore.collection('students').doc(docId).delete();
      await _logAdminAction('delete_student', 'Deleted student: $docId');
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> adminBanStudent(String docId, bool ban) async {
    try {
      await _firestore.collection('students').doc(docId).update({
        'isBanned': ban,
      });
      await _logAdminAction('ban_toggle', 'Banned=$ban for doc: $docId');
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> adminMuteStudent(String docId, bool mute) async {
    try {
      await _firestore.collection('students').doc(docId).update({
        'isMuted': mute,
      });
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> adminResetProgress(String docId) async {
    try {
      final snap = await _firestore.collection('students').doc(docId).get();
      if (!snap.exists) return 'Student not found';
      final data = snap.data()!;
      final resetData = StudentProgress(
        nickname: data['nickname'] ?? '',
        realName: data['realName'] ?? '',
        avatarId: data['avatarId'] ?? '🔥',
      ).toJson();
      resetData['pin'] = data['pin'];
      resetData['role'] = data['role'] ?? 'student';
      resetData['createdAt'] = data['createdAt'];
      await _firestore.collection('students').doc(docId).set(resetData);
      await _logAdminAction('reset_progress', 'Reset progress for: $docId');
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> adminGiveCoins(String docId, int amount) async {
    try {
      await _firestore.collection('students').doc(docId).update({
        'coins': FieldValue.increment(amount),
        'totalCoinsEarned': FieldValue.increment(amount > 0 ? amount : 0),
      });
      await _logAdminAction('give_coins', 'Gave $amount coins to: $docId');
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> adminGiveXP(String docId, int amount) async {
    try {
      await _firestore.collection('students').doc(docId).update({
        'xp': FieldValue.increment(amount),
        'totalXPEarned': FieldValue.increment(amount > 0 ? amount : 0),
      });
      await _logAdminAction('give_xp', 'Gave $amount XP to: $docId');
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> adminSendAnnouncement(String title, String message) async {
    try {
      await _firestore.collection('announcements').add({
        'title': title,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'active': true,
      });
      await _logAdminAction('announcement', 'Sent: $title');
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> adminCreateMission({
    required String title,
    required String description,
    required int rewardCoins,
    required int targetCount,
    required String type,
  }) async {
    try {
      await _firestore.collection('missions').add({
        'title': title,
        'description': description,
        'rewardCoins': rewardCoins,
        'targetCount': targetCount,
        'type': type,
        'active': true,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> adminCreateEvent({
    required String title,
    required String description,
    required String expiresAt,
    required int bonusMultiplier,
  }) async {
    try {
      await _firestore.collection('events').add({
        'title': title,
        'description': description,
        'expiresAt': expiresAt,
        'bonusMultiplier': bonusMultiplier,
        'active': true,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<Map<String, dynamic>> adminGetAnalytics() async {
    try {
      final students = await _firestore.collection('students').get();
      int totalCoins = 0, totalXP = 0, totalQuizzes = 0, bannedCount = 0;
      for (final doc in students.docs) {
        final d = doc.data();
        totalCoins += (d['coins'] as int? ?? 0);
        totalXP += (d['xp'] as int? ?? 0);
        totalQuizzes += (d['totalQuizzes'] as int? ?? 0);
        if (d['isBanned'] == true) bannedCount++;
      }
      return {
        'totalStudents': students.docs.length,
        'totalCoins': totalCoins,
        'totalXP': totalXP,
        'totalQuizzes': totalQuizzes,
        'bannedCount': bannedCount,
      };
    } catch (e) {
      return {};
    }
  }

  Future<void> _logAdminAction(String action, String detail) async {
    try {
      await _firestore.collection('securityLogs').add({
        'action': action,
        'detail': detail,
        'timestamp': DateTime.now().toIso8601String(),
        'by': 'admin',
      });
    } catch (_) {}
  }

  Stream<QuerySnapshot> get allStudentsStream => _firestore
      .collection('students')
      .orderBy('xp', descending: true)
      .snapshots();

  Stream<QuerySnapshot> get announcementsStream => _firestore
      .collection('announcements')
      .where('active', isEqualTo: true)
      .orderBy('timestamp', descending: true)
      .snapshots();
}

// ============================================================
// CONNECTIVITY SERVICE
// ============================================================

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static final StreamController<ConnectivityResult> _controller =
      StreamController<ConnectivityResult>.broadcast();
  static Stream<ConnectivityResult> get onConnectivityChanged =>
      _controller.stream;
  static ConnectivityResult _currentStatus = ConnectivityResult.none;
  static ConnectivityResult get currentStatus => _currentStatus;

  static Future<void> init() async {
    _currentStatus =
        (await _connectivity.checkConnectivity()) as ConnectivityResult;
    _connectivity.onConnectivityChanged.listen((result) {
      _currentStatus = result as ConnectivityResult;
      _controller.add(result as ConnectivityResult);
    });
  }

  static bool get isConnected => _currentStatus != ConnectivityResult.none;
}

// ============================================================
// FLOATING REWARD OVERLAY
// ============================================================

class FloatingRewardOverlay {
  static OverlayEntry? _currentEntry;
  static void show(
    BuildContext context,
    String message, {
    Color color = AppColors.gold,
  }) {
    _currentEntry?.remove();
    _currentEntry = OverlayEntry(
      builder: (ctx) => _FloatingRewardWidget(message: message, color: color),
    );
    Overlay.of(context).insert(_currentEntry!);
    Future.delayed(const Duration(seconds: 3), () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
  }
}

class _FloatingRewardWidget extends StatefulWidget {
  final String message;
  final Color color;
  const _FloatingRewardWidget({required this.message, required this.color});
  @override
  State<_FloatingRewardWidget> createState() => _FloatingRewardWidgetState();
}

class _FloatingRewardWidgetState extends State<_FloatingRewardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.2)));
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned(
    top: MediaQuery.of(context).size.height * 0.15,
    left: 0,
    right: 0,
    child: AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _offset,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ============================================================
// GAME STATE MANAGER
// ============================================================

class GameStateManager extends ChangeNotifier {
  StudentProgress _progress = StudentProgress();
  StudentProgress get progress => _progress;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  String? _error;
  String? get error => _error;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  BuildContext? _overlayContext;
  void setOverlayContext(BuildContext ctx) => _overlayContext = ctx;

  final FirebaseSyncService _firebaseSync = FirebaseSyncService();
  Timer? _autoSaveTimer;
  Timer? _streakCheckTimer;
  Timer? _eventTimer;
  Timer? _motivationTimer;

  String _motivationalMessage = '';
  String get motivationalMessage => _motivationalMessage;

  final List<String> _motivationalMessages = [
    '🔥 You\'re on fire! Keep going!',
    '⚡ Only 1 quiz away from a reward chest!',
    '💎 You are close to Top 10!',
    '🚀 2 correct answers to level up!',
    '🏆 Streak bonus unlocking soon!',
    '🌟 A mystery reward is waiting!',
    '🎯 Perfect score = massive XP boost!',
    '⚔️ A rival is gaining on you!',
  ];

  GameStateManager() {
    _init();
    _setupAutoSave();
    _setupConnectivityListener();
    _setupStreakChecker();
    _setupEventSystem();
    _setupMotivationSystem();
  }

  Future<void> _init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await ConnectivityService.init();
      _isOnline = ConnectivityService.isConnected;
      final localProgress = await OfflineStorageService.loadProgress();
      if (localProgress != null) _progress = localProgress;
      _checkAndUpdateStreak();
      await _saveToLocal();
      if (_isOnline && _firebaseSync.isLoggedIn) await _syncToFirebase();
    } catch (e) {
      _error = 'Failed to load game data: $e';
      debugPrint('Init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String nickname, String pin) async {
    _isLoading = true;
    notifyListeners();
    try {
      final authData = await _firebaseSync.authenticateStudent(nickname, pin);
      if (authData != null) {
        final progress = StudentProgress.fromJson(authData);
        if (progress.isBanned) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _isLoggedIn = true;
        _currentUserId = authData['id'];
        _progress = progress;
        _progress.loginHistory.insert(0, {
          'timestamp': DateTime.now().toIso8601String(),
          'device': 'mobile',
        });
        await _syncToFirebase();
        _checkAndUpdateStreak();
        await _saveToLocal();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _currentUserId = null;
    _progress = StudentProgress();
    _saveToLocal();
    notifyListeners();
  }

  void _setupMotivationSystem() {
    _motivationTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _motivationalMessage =
          _motivationalMessages[Random().nextInt(_motivationalMessages.length)];
      notifyListeners();
    });
  }

  void _setupEventSystem() {
    _eventTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkEventRewards(),
    );
  }

  void _checkEventRewards() {
    final now = DateTime.now();
    if (now.hour == 12 &&
        now.minute == 0 &&
        !_progress.settings.containsKey('dailyRewardClaimed')) {
      _showFloatingReward(
        'Daily Reward Available! Claim now! 🎁',
        AppColors.gold,
      );
    }
  }

  void _showFloatingReward(String message, Color color) {
    if (_overlayContext != null)
      FloatingRewardOverlay.show(_overlayContext!, message, color: color);
    debugPrint('✨ REWARD: $message');
  }

  void _setupConnectivityListener() {
    ConnectivityService.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      if (!wasOnline && _isOnline) {
        _syncToFirebase();
        _firebaseSync.syncPendingQuizzes();
      }
      notifyListeners();
    });
  }

  void _setupAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _saveToLocal();
      if (_isOnline && _firebaseSync.isLoggedIn) await _syncToFirebase();
    });
  }

  void _setupStreakChecker() {
    _streakCheckTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _checkAndUpdateStreak(),
    );
  }

  void _checkAndUpdateStreak() {
    final now = DateTime.now();
    final diff = now.difference(_progress.lastLoginDate).inDays;
    if (diff == 1) {
      _progress.streak++;
      _showStreakNotification();
      _rewardStreakBonus();
    } else if (diff > 1) {
      if (_progress.streakFreezes > 0) {
        _progress.streakFreezes--;
        _addActivity(
          'Streak Freeze Used',
          'Streak protected! ${_progress.streakFreezes} freezes left',
        );
      } else {
        _progress.streak = 1;
      }
    }
    _progress.lastLoginDate = now;
    notifyListeners();
  }

  void _rewardStreakBonus() {
    final bonus = _progress.streak * 5;
    _progress.coins += bonus;
    _progress.totalCoinsEarned += bonus;
    _addActivity(
      'Streak Bonus',
      'Earned $bonus coins for ${_progress.streak} day streak!',
    );
  }

  void _showStreakNotification() {
    if (_progress.streak % 7 == 0)
      _showFloatingReward(
        '🔥 ${_progress.streak} DAY STREAK! 🔥',
        AppColors.streakOrange,
      );
  }

  Future<void> _saveToLocal() async {
    try {
      await OfflineStorageService.saveProgress(_progress);
    } catch (e) {
      debugPrint('Error saving locally: $e');
    }
  }

  Future<void> _syncToFirebase() async {
    if (!_isOnline || !_firebaseSync.isLoggedIn) return;
    try {
      await _firebaseSync.syncProgress(_progress);
    } catch (e) {
      debugPrint('Error syncing: $e');
    }
  }

  Future<void> addCoins(int amount, {String source = 'quiz'}) async {
    _progress.coins += amount;
    _progress.totalCoinsEarned += amount;
    _addActivity('Coins Earned', '+$amount coins from $source');
    _updateRank();
    notifyListeners();
    await _saveToLocal();
  }

  Future<void> addXP(int amount, {String source = 'quiz'}) async {
    _progress.xp += amount;
    _progress.totalXPEarned += amount;
    _updateWeeklyMonthlyXP(amount);
    final xpNeeded = _getXpNeededForNextLevel();
    if (_progress.xp >= xpNeeded) {
      _progress.level++;
      _progress.xp -= xpNeeded;
      _showLevelUpReward();
    }
    _updateRank();
    _addActivity('XP Earned', '+$amount XP from $source');
    notifyListeners();
    await _saveToLocal();
  }

  void _updateWeeklyMonthlyXP(int amount) {
    final weekKey = 'week_${DateTime.now().year}_${_weekOfYear()}';
    final monthKey = 'month_${DateTime.now().year}_${DateTime.now().month}';
    _progress.weeklyXP = Map.from(_progress.weeklyXP)
      ..[weekKey] = (_progress.weeklyXP[weekKey] ?? 0) + amount;
    _progress.monthlyXP = Map.from(_progress.monthlyXP)
      ..[monthKey] = (_progress.monthlyXP[monthKey] ?? 0) + amount;
  }

  int _weekOfYear() {
    final now = DateTime.now();
    return ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).ceil();
  }

  void _addActivity(String type, String description) {
    final h = List<Map<String, dynamic>>.from(_progress.activityHistory);
    h.insert(0, {
      'type': type,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (h.length > 50) h.removeLast();
    _progress.activityHistory = h;
  }

  int _getXpNeededForNextLevel() => _progress.level * 500;

  void _updateRank() {
    for (int i = kRankTitles.length - 1; i >= 0; i--) {
      if (_progress.totalXPEarned >= kRankTitles[i].$1) {
        _progress.rankTitle = kRankTitles[i].$2;
        break;
      }
    }
  }

  void _showLevelUpReward() {
    final reward = _progress.level * 100;
    _progress.coins += reward;
    _progress.totalCoinsEarned += reward;
    _showFloatingReward(
      '🎊 LEVEL ${_progress.level}! +$reward COINS!',
      AppColors.gold,
    );
  }

  Future<QuizResult> completeQuiz(
    String subject,
    int score,
    int total, {
    int combo = 1,
    int timeBonus = 0,
  }) async {
    final isPerfect = score == total;
    final isCorrect = score > total / 2;
    int coinsEarned = isPerfect ? 150 : (isCorrect ? 50 + (score * 5) : 10);
    int xpEarned = isPerfect ? 250 : (isCorrect ? 100 + (score * 10) : 20);
    if (combo > 1) {
      final b = (coinsEarned * (combo * 0.1)).round();
      coinsEarned += b;
      xpEarned += b;
    }
    if (timeBonus > 0) {
      coinsEarned += timeBonus;
      xpEarned += timeBonus;
    }
    await addCoins(coinsEarned, source: 'quiz_$subject');
    await addXP(xpEarned, source: 'quiz_$subject');
    _progress.totalQuizzes++;
    if (isCorrect) _progress.correctAnswers += score;
    if (isPerfect) {
      _progress.perfectQuizCount++;
      _unlockAchievement('Perfect Score: $subject');
    }
    final cur = _progress.subjectProgress[subject] ?? 0;
    final newP = min(100, cur + ((score / total) * 20).round());
    _progress.subjectProgress = Map.from(_progress.subjectProgress)
      ..[subject] = newP;
    if (newP >= 100 && cur < 100)
      _unlockAchievement('Subject Master: $subject');
    if (Random().nextInt(10) == 0) {
      _progress.chestCount++;
      _showFloatingReward('🎁 Lucky Chest Dropped!', AppColors.gold);
    }
    _checkAllAchievements();
    notifyListeners();
    await _saveToLocal();
    await OfflineStorageService.addToPendingSync({
      'subject': subject,
      'score': score,
      'total': total,
      'coinsEarned': coinsEarned,
      'xpEarned': xpEarned,
      'timestamp': DateTime.now().toIso8601String(),
      'perfect': isPerfect,
    });
    return QuizResult(
      score: score,
      total: total,
      coinsEarned: coinsEarned,
      xpEarned: xpEarned,
      subject: subject,
      isPerfect: isPerfect,
    );
  }

  void _checkAllAchievements() {
    if (_progress.totalQuizzes >= 10) _unlockAchievement('Quiz Enthusiast 🎓');
    if (_progress.totalQuizzes >= 50) _unlockAchievement('Quiz Master 🏆');
    if (_progress.streak >= 7) _unlockAchievement('Week Warrior 🔥');
    if (_progress.streak >= 30) _unlockAchievement('Monthly Legend 🌟');
    if (_progress.perfectQuizCount >= 5) _unlockAchievement('Perfectionist 💎');
    if (_progress.totalCoinsEarned >= 1000) _unlockAchievement('Coin King 💰');
    if (_progress.level >= 10) _unlockAchievement('Elite Student ⚡');
  }

  void _unlockAchievement(String achievement) {
    if (!_progress.achievements.contains(achievement)) {
      _progress.achievements = List.from(_progress.achievements)
        ..add(achievement);
      _progress.coins += 200;
      _progress.totalCoinsEarned += 200;
      _showFloatingReward(
        '🏆 ACHIEVEMENT: $achievement! +200 COINS!',
        AppColors.success,
      );
    }
  }

  void claimDailyReward() {
    final today = DateTime.now().day;
    if (_progress.dailyStreakRewardClaimed != today) {
      final reward = 50 + (_progress.streak * 10);
      _progress.coins += reward;
      _progress.totalCoinsEarned += reward;
      _progress.dailyStreakRewardClaimed = today;
      _addActivity('Daily Reward', 'Claimed $reward coins!');
      _showFloatingReward(
        '🎁 Daily Reward: +$reward Coins!',
        AppColors.coinAmber,
      );
      _saveToLocal();
      notifyListeners();
    }
  }

  bool get canClaimDaily =>
      _progress.dailyStreakRewardClaimed != DateTime.now().day;

  Future<int> spinLucky() async {
    if (_progress.coins < 50) return 0;
    _progress.coins -= 50;
    final rewards = [10, 25, 50, 100, 200, 500, 1000, 5];
    final reward = rewards[Random().nextInt(rewards.length)];
    _progress.coins += reward;
    _progress.totalCoinsEarned += reward;
    _progress.luckySpinCount++;
    _addActivity('Lucky Spin', 'Won $reward coins!');
    _showFloatingReward('🎰 Lucky Spin: +$reward Coins!', AppColors.xpPurple);
    await _saveToLocal();
    notifyListeners();
    return reward;
  }

  Future<Map<String, dynamic>> openChest() async {
    if (_progress.chestCount <= 0) return {};
    _progress.chestCount--;
    final rng = Random();
    final cr = 50 + rng.nextInt(450);
    final xr = 100 + rng.nextInt(400);
    _progress.coins += cr;
    _progress.totalCoinsEarned += cr;
    _progress.xp += xr;
    _progress.totalXPEarned += xr;
    _addActivity('Chest Opened', '+$cr coins, +$xr XP!');
    _showFloatingReward('🎁 Chest: +$cr Coins +$xr XP!', AppColors.gold);
    await _saveToLocal();
    notifyListeners();
    return {'coins': cr, 'xp': xr};
  }

  void updateAvatar(String a) {
    _progress.avatarId = a;
    _saveToLocal();
    _syncToFirebase();
    notifyListeners();
  }

  void updateFrame(String f) {
    _progress.frame = f;
    _saveToLocal();
    _syncToFirebase();
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _streakCheckTimer?.cancel();
    _eventTimer?.cancel();
    _motivationTimer?.cancel();
    super.dispose();
  }
}

// ============================================================
// PARTICLE PAINTER
// ============================================================

class ParticlePainter extends CustomPainter {
  final double animation;
  ParticlePainter(this.animation);
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = AppColors.primary.withOpacity(0.08);
    final p2 = Paint()..color = AppColors.accent.withOpacity(0.05);
    for (int i = 0; i < 60; i++) {
      final x = (i * 37 + sin(animation * 2 * pi + i) * 20) % size.width;
      final y = (i * 73 + animation * 150) % size.height;
      final r = 1.5 + (sin(animation * pi + i) * 1.5).abs();
      canvas.drawCircle(Offset(x, y), r, i % 3 == 0 ? p2 : p1);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter o) => true;
}

// ============================================================
// PREMIUM LOGIN SCREEN
// ============================================================

class PremiumLoginScreen extends StatefulWidget {
  final GameStateManager gameManager;
  const PremiumLoginScreen({Key? key, required this.gameManager})
    : super(key: key);
  @override
  State<PremiumLoginScreen> createState() => _PremiumLoginScreenState();
}

class _PremiumLoginScreenState extends State<PremiumLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  bool _pinVisible = false;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _fadeAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _pinController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final nick = _nicknameController.text.trim();
    final pin = _pinController.text.trim();
    if (nick.isEmpty || pin.isEmpty) {
      setState(() => _errorMessage = 'Please enter nickname and PIN');
      return;
    }

    // ADMIN LOGIN CHECK — never expose admin credentials to student path
    if (_AdminSecurity.validateAdmin(nick, pin)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
      return;
    }

    if (pin.length != 6) {
      setState(() => _errorMessage = 'PIN must be exactly 6 digits');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final success = await widget.gameManager.login(nick, pin);
    if (!success && mounted)
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid nickname or PIN. Contact admin.';
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FFF8), Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (_, __) => CustomPaint(
                painter: ParticlePainter(_particleController.value),
                size: Size.infinite,
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedLogo(),
                      const SizedBox(height: 40),
                      _buildLoginCard(),
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

  Widget _buildAnimatedLogo() => Column(
    children: [
      AnimatedBuilder(
        animation: _particleController,
        builder: (_, __) => Transform.rotate(
          angle: sin(_particleController.value * 2 * pi) * 0.05,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.school, size: 55, color: Colors.white),
          ),
        ),
      ),
      const SizedBox(height: 20),
      ShaderMask(
        shaderCallback: (b) => const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        ).createShader(b),
        child: const Text(
          'BEEDI College',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Learn. Compete. Excel.',
        style: TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 1.5),
      ),
    ],
  );

  Widget _buildLoginCard() => ClipRRect(
    borderRadius: BorderRadius.circular(32),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Welcome Back! 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Login to continue your journey',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              _nicknameController,
              'Nickname',
              Icons.person,
              false,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _pinController,
              '6-digit PIN',
              Icons.lock,
              !_pinVisible,
              suffix: IconButton(
                icon: Icon(
                  _pinVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _pinVisible = !_pinVisible),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: const Text('Contact Admin'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Please reach out to your college administrator for account setup or PIN reset.',
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.help_outline, size: 16),
              label: const Text('Need help? Contact Admin'),
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    bool obscure, {
    Widget? suffix,
  }) => TextField(
    controller: ctrl,
    obscureText: obscure,
    keyboardType: label.contains('PIN')
        ? TextInputType.number
        : TextInputType.text,
    maxLength: label.contains('PIN') ? 6 : null,
    decoration: InputDecoration(
      labelText: label,
      counterText: '',
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}

// ============================================================
// ADMIN PANEL SCREEN
// ============================================================

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with TickerProviderStateMixin {
  final FirebaseSyncService _firebase = FirebaseSyncService();
  late TabController _tabController;
  Map<String, dynamic> _analytics = {};
  bool _analyticsLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _analyticsLoading = true);
    _analytics = await _firebase.adminGetAnalytics();
    if (mounted) setState(() => _analyticsLoading = false);
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.adminPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.adminAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: AppColors.adminAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Admin Control Panel',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GameScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.adminAccent,
          labelColor: AppColors.adminAccent,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Students'),
            Tab(text: 'Create'),
            Tab(text: 'Events'),
            Tab(text: 'Missions'),
            Tab(text: 'Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(),
          _buildStudentManager(),
          _buildCreateStudent(),
          _buildEventManager(),
          _buildMissionManager(),
          _buildSecurityLogs(),
        ],
      ),
    );
  }

  // --- DASHBOARD ---
  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      color: AppColors.adminAccent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Live Analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _analyticsLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.adminAccent,
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildAnalyticsCard(
                        'Total Students',
                        '${_analytics['totalStudents'] ?? 0}',
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildAnalyticsCard(
                        'Total Coins',
                        '${_analytics['totalCoins'] ?? 0}',
                        Icons.monetization_on,
                        Colors.amber,
                      ),
                      _buildAnalyticsCard(
                        'Total XP',
                        '${_analytics['totalXP'] ?? 0}',
                        Icons.star,
                        Colors.purple,
                      ),
                      _buildAnalyticsCard(
                        'Quizzes Taken',
                        '${_analytics['totalQuizzes'] ?? 0}',
                        Icons.quiz,
                        Colors.green,
                      ),
                      _buildAnalyticsCard(
                        'Banned',
                        '${_analytics['bannedCount'] ?? 0}',
                        Icons.block,
                        Colors.red,
                      ),
                      _buildAnalyticsCard(
                        'Active Events',
                        '—',
                        Icons.event,
                        Colors.teal,
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
            const Text(
              '📢 Recent Announcements',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _firebase.announcementsStream,
              builder: (ctx, snap) {
                if (!snap.hasData)
                  return const CircularProgressIndicator(
                    color: AppColors.adminAccent,
                  );
                if (snap.data!.docs.isEmpty)
                  return const Text(
                    'No announcements yet.',
                    style: TextStyle(color: Colors.white60),
                  );
                return Column(
                  children: snap.data!.docs.take(5).map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.adminCard,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.campaign,
                            color: AppColors.adminAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data['message'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('announcements')
                                  .doc(d.id)
                                  .update({'active': false});
                              _showSnack('Announcement removed');
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildAnnouncementComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.adminCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _buildAnnouncementComposer() {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adminCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Announcement',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _adminTextField(titleCtrl, 'Title', Icons.title),
          const SizedBox(height: 10),
          _adminTextField(msgCtrl, 'Message', Icons.message, maxLines: 3),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || msgCtrl.text.isEmpty) {
                  _showSnack('Fill all fields', error: true);
                  return;
                }
                final err = await _firebase.adminSendAnnouncement(
                  titleCtrl.text.trim(),
                  msgCtrl.text.trim(),
                );
                if (err == null) {
                  _showSnack('Announcement sent!');
                  titleCtrl.clear();
                  msgCtrl.clear();
                } else
                  _showSnack(err, error: true);
              },
              icon: const Icon(Icons.send),
              label: const Text('Send to All Students'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adminAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STUDENT MANAGER ---
  Widget _buildStudentManager() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by nickname...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: AppColors.adminCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firebase.allStudentsStream,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.adminAccent,
                  ),
                );
              if (!snap.hasData || snap.data!.docs.isEmpty)
                return const Center(
                  child: Text(
                    'No students found.',
                    style: TextStyle(color: Colors.white60),
                  ),
                );
              final docs = snap.data!.docs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                final nick = (data['nickname'] ?? '').toString().toLowerCase();
                return _searchQuery.isEmpty || nick.contains(_searchQuery);
              }).toList();
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final doc = docs[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final isBanned = data['isBanned'] == true;
                  final isMuted = data['isMuted'] == true;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.adminCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isBanned
                            ? Colors.red.withOpacity(0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: ExpansionTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.adminAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            data['avatarId'] ?? '🔥',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            data['nickname'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isBanned)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'BANNED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isMuted)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'MUTED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        'Lv.${data['level'] ?? 1} · ${data['xp'] ?? 0} XP · ${data['coins'] ?? 0} 🪙',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white54,
                      children: [_buildStudentActions(doc.id, data)],
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

  Widget _buildStudentActions(String docId, Map<String, dynamic> data) {
    final coinCtrl = TextEditingController();
    final xpCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: coinCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _adminInputDecoration(
                    'Coins (±)',
                    Icons.monetization_on,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final amt = int.tryParse(coinCtrl.text);
                  if (amt == null) return;
                  final err = await _firebase.adminGiveCoins(docId, amt);
                  _showSnack(err ?? 'Coins updated!', error: err != null);
                  coinCtrl.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coinAmber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: xpCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _adminInputDecoration('XP (±)', Icons.star),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final amt = int.tryParse(xpCtrl.text);
                  if (amt == null) return;
                  final err = await _firebase.adminGiveXP(docId, amt);
                  _showSnack(err ?? 'XP updated!', error: err != null);
                  xpCtrl.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.xpPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _adminActionChip(
                data['isBanned'] == true ? '✅ Unban' : '🚫 Ban',
                data['isBanned'] == true ? Colors.green : Colors.red,
                () async {
                  final err = await _firebase.adminBanStudent(
                    docId,
                    !(data['isBanned'] == true),
                  );
                  _showSnack(err ?? 'Done!', error: err != null);
                },
              ),
              _adminActionChip(
                data['isMuted'] == true ? '🔊 Unmute' : '🔇 Mute',
                data['isMuted'] == true ? Colors.green : Colors.orange,
                () async {
                  final err = await _firebase.adminMuteStudent(
                    docId,
                    !(data['isMuted'] == true),
                  );
                  _showSnack(err ?? 'Done!', error: err != null);
                },
              ),
              _adminActionChip(
                '🔄 Reset Progress',
                Colors.orange,
                () => _confirmDialog(
                  'Reset all progress for ${data['nickname']}?',
                  () async {
                    final err = await _firebase.adminResetProgress(docId);
                    _showSnack(err ?? 'Progress reset!', error: err != null);
                  },
                ),
              ),
              _adminActionChip(
                '🗑 Delete',
                Colors.red,
                () => _confirmDialog(
                  'Delete student ${data['nickname']}? This cannot be undone.',
                  () async {
                    final err = await _firebase.adminDeleteStudent(docId);
                    _showSnack(err ?? 'Student deleted!', error: err != null);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _adminInfoRow('Real Name', data['realName'] ?? '—'),
                _adminInfoRow('Streak', '${data['streak'] ?? 0} days'),
                _adminInfoRow('Total Quizzes', '${data['totalQuizzes'] ?? 0}'),
                _adminInfoRow(
                  'Perfect Quizzes',
                  '${data['perfectQuizCount'] ?? 0}',
                ),
                _adminInfoRow(
                  'Achievements',
                  '${(data['achievements'] as List?)?.length ?? 0}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDialog(String msg, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.adminCard,
        title: const Text(
          'Confirm Action',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(msg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _adminActionChip(String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );

  Widget _adminInfoRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(
          v,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  // --- CREATE STUDENT ---
  Widget _buildCreateStudent() {
    final nicknameCtrl = TextEditingController();
    final realNameCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    String selectedAvatar = '🔥';
    bool isLoading = false;

    return StatefulBuilder(
      builder: (ctx, setSt) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '➕ Create New Student',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Only admin can create student accounts.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.adminCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _adminTextField(nicknameCtrl, 'Nickname *', Icons.person),
                  const SizedBox(height: 12),
                  _adminTextField(realNameCtrl, 'Real Name *', Icons.badge),
                  const SizedBox(height: 12),
                  _adminTextField(
                    pinCtrl,
                    '6-digit PIN *',
                    Icons.lock,
                    keyboardType: TextInputType.number,
                    maxLen: 6,
                    obscure: true,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Select Avatar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: kAvatars
                        .map(
                          (a) => GestureDetector(
                            onTap: () => setSt(() => selectedAvatar = a),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: selectedAvatar == a
                                    ? AppColors.adminAccent.withOpacity(0.25)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedAvatar == a
                                      ? AppColors.adminAccent
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  a,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final nick = nicknameCtrl.text.trim();
                              final real = realNameCtrl.text.trim();
                              final pin = pinCtrl.text.trim();
                              if (nick.isEmpty ||
                                  real.isEmpty ||
                                  pin.length != 6) {
                                _showSnack(
                                  'All fields required. PIN must be exactly 6 digits.',
                                  error: true,
                                );
                                return;
                              }
                              setSt(() => isLoading = true);
                              final err = await _firebase.adminCreateStudent(
                                nickname: nick,
                                realName: real,
                                pin: pin,
                                avatarId: selectedAvatar,
                              );
                              setSt(() => isLoading = false);
                              if (err == null) {
                                _showSnack(
                                  'Student "$nick" created successfully!',
                                );
                                nicknameCtrl.clear();
                                realNameCtrl.clear();
                                pinCtrl.clear();
                                setSt(() => selectedAvatar = '🔥');
                              } else {
                                _showSnack(err, error: true);
                              }
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.person_add),
                      label: Text(
                        isLoading ? 'Creating...' : 'Create Student Account',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Security Notes',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• PINs are stored securely in Firebase only\n• Students can never see or change their PIN\n• Accounts can only be created by admin\n• All admin actions are logged in security logs',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.6,
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

  // --- EVENT MANAGER ---
  Widget _buildEventManager() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final multiplierCtrl = TextEditingController(text: '2');
    DateTime? expiresAt;

    return StatefulBuilder(
      builder: (ctx, setSt) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎉 Event Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.adminCard,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _adminTextField(titleCtrl, 'Event Title', Icons.celebration),
                  const SizedBox(height: 12),
                  _adminTextField(
                    descCtrl,
                    'Description',
                    Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _adminTextField(
                    multiplierCtrl,
                    'Bonus Multiplier (e.g. 2 = 2x XP)',
                    Icons.bolt,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) setSt(() => expiresAt = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.adminAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            expiresAt == null
                                ? 'Select Expiry Date'
                                : 'Expires: ${expiresAt!.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: expiresAt == null
                                  ? Colors.white38
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (titleCtrl.text.isEmpty || expiresAt == null) {
                          _showSnack('Fill all required fields', error: true);
                          return;
                        }
                        final err = await _firebase.adminCreateEvent(
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          expiresAt: expiresAt!.toIso8601String(),
                          bonusMultiplier:
                              int.tryParse(multiplierCtrl.text) ?? 2,
                        );
                        _showSnack(err ?? 'Event created!', error: err != null);
                        if (err == null) {
                          titleCtrl.clear();
                          descCtrl.clear();
                          setSt(() => expiresAt = null);
                        }
                      },
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Create Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Active Events',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('active', isEqualTo: true)
                  .snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData)
                  return const CircularProgressIndicator(
                    color: AppColors.adminAccent,
                  );
                if (snap.data!.docs.isEmpty)
                  return const Text(
                    'No active events.',
                    style: TextStyle(color: Colors.white60),
                  );
                return Column(
                  children: snap.data!.docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.adminCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.teal.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${data['bonusMultiplier']}x bonus · Expires: ${(data['expiresAt'] ?? '').toString().split('T')[0]}',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.stop_circle,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('events')
                                  .doc(d.id)
                                  .update({'active': false});
                              _showSnack('Event ended');
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- MISSION MANAGER ---
  Widget _buildMissionManager() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final rewardCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    String selectedType = 'quiz';

    return StatefulBuilder(
      builder: (ctx, setSt) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Mission Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.adminCard,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _adminTextField(titleCtrl, 'Mission Title', Icons.flag),
                  const SizedBox(height: 12),
                  _adminTextField(descCtrl, 'Description', Icons.description),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _adminTextField(
                          rewardCtrl,
                          'Reward (Coins)',
                          Icons.monetization_on,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _adminTextField(
                          targetCtrl,
                          'Target Count',
                          Icons.numbers,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: AppColors.adminCard,
                    style: const TextStyle(color: Colors.white),
                    decoration: _adminInputDecoration(
                      'Mission Type',
                      Icons.category,
                    ),
                    items: ['quiz', 'streak', 'coins', 'xp', 'perfect']
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setSt(() => selectedType = v ?? 'quiz'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (titleCtrl.text.isEmpty ||
                            rewardCtrl.text.isEmpty ||
                            targetCtrl.text.isEmpty) {
                          _showSnack('Fill all fields', error: true);
                          return;
                        }
                        final err = await _firebase.adminCreateMission(
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          rewardCoins: int.tryParse(rewardCtrl.text) ?? 50,
                          targetCount: int.tryParse(targetCtrl.text) ?? 1,
                          type: selectedType,
                        );
                        _showSnack(
                          err ?? 'Mission created!',
                          error: err != null,
                        );
                        if (err == null) {
                          titleCtrl.clear();
                          descCtrl.clear();
                          rewardCtrl.clear();
                          targetCtrl.clear();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Mission'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Active Missions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('missions')
                  .where('active', isEqualTo: true)
                  .snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData)
                  return const CircularProgressIndicator(
                    color: AppColors.adminAccent,
                  );
                if (snap.data!.docs.isEmpty)
                  return const Text(
                    'No active missions.',
                    style: TextStyle(color: Colors.white60),
                  );
                return Column(
                  children: snap.data!.docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.adminCard,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '+${data['rewardCoins']} coins · ${data['type']} · Target: ${data['targetCount']}',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('missions')
                                  .doc(d.id)
                                  .update({'active': false});
                              _showSnack('Mission removed');
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- SECURITY LOGS ---
  Widget _buildSecurityLogs() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('securityLogs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(
            child: CircularProgressIndicator(color: AppColors.adminAccent),
          );
        if (!snap.hasData || snap.data!.docs.isEmpty)
          return const Center(
            child: Text(
              'No logs yet.',
              style: TextStyle(color: Colors.white60),
            ),
          );
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snap.data!.docs.length,
          itemBuilder: (ctx, i) {
            final data = snap.data!.docs[i].data() as Map<String, dynamic>;
            final ts = data['timestamp'] ?? '';
            final action = data['action'] ?? '';
            final detail = data['detail'] ?? '';
            final isDelete =
                action.contains('delete') || action.contains('ban');
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.adminCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDelete
                      ? Colors.red.withOpacity(0.3)
                      : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDelete ? Icons.warning_amber : Icons.admin_panel_settings,
                    color: isDelete ? Colors.redAccent : AppColors.adminAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.toUpperCase(),
                          style: TextStyle(
                            color: isDelete
                                ? Colors.redAccent
                                : AppColors.adminAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          detail,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ts.length > 10
                        ? ts.substring(0, 16).replaceAll('T', ' ')
                        : ts,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- HELPERS ---
  Widget _adminTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int? maxLines,
    TextInputType? keyboardType,
    int? maxLen,
    bool obscure = false,
  }) => TextField(
    controller: ctrl,
    style: const TextStyle(color: Colors.white),
    obscureText: obscure,
    keyboardType: keyboardType,
    maxLines: maxLines ?? 1,
    maxLength: maxLen,
    decoration: _adminInputDecoration(label, icon),
  );

  InputDecoration _adminInputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppColors.adminAccent, size: 18),
        filled: true,
        fillColor: Colors.white10,
        counterStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.adminAccent,
            width: 1.5,
          ),
        ),
      );
}

// ============================================================
// ENHANCED QUIZ SCREEN
// ============================================================

class EnhancedQuizScreen extends StatefulWidget {
  final GameStateManager gameManager;
  final String subject;
  final List<QuizQuestion> questions;
  final String mode;
  const EnhancedQuizScreen({
    Key? key,
    required this.gameManager,
    required this.subject,
    required this.questions,
    this.mode = 'normal',
  }) : super(key: key);
  @override
  State<EnhancedQuizScreen> createState() => _EnhancedQuizScreenState();
}

class _EnhancedQuizScreenState extends State<EnhancedQuizScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0,
      _score = 0,
      _combo = 0,
      _timeSpent = 0,
      _questionTimeLeft = 30;
  List<int?> _answers = [];
  bool _quizCompleted = false;
  late Timer _timer, _questionTimer;
  late AnimationController _shakeController,
      _comboController,
      _correctController,
      _progressController,
      _timerController;

  @override
  void initState() {
    super.initState();
    _answers = List.filled(widget.questions.length, null);
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _timeSpent++),
    );
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_questionTimeLeft > 0) {
        setState(() => _questionTimeLeft--);
        _timerController.animateTo(1 - (_questionTimeLeft / 30));
      } else
        _answerQuestion(-1);
    });
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _correctController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _timerController.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _questionTimer.cancel();
    _shakeController.dispose();
    _comboController.dispose();
    _correctController.dispose();
    _progressController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _resetQuestionTimer() {
    _questionTimeLeft = 30;
    _timerController.reset();
    _timerController.forward();
  }

  Future<void> _submitQuiz() async {
    final timeBonus = max(0, 300 - _timeSpent) ~/ 30;
    final result = await widget.gameManager.completeQuiz(
      widget.subject,
      _score,
      widget.questions.length,
      combo: _combo,
      timeBonus: timeBonus,
    );
    if (mounted) _showResultDialog(result);
  }

  void _showResultDialog(QuizResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: result.isPerfect
                  ? [const Color(0xFFFFF9C4), Colors.white]
                  : [const Color(0xFFE8F5E9), Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.isPerfect
                    ? '🏆 PERFECT!'
                    : result.score >= result.total / 2
                    ? '✅ Great Job!'
                    : '😅 Keep Trying!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${result.score}/${result.total} Correct',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildResultRow(
                '🪙 Coins',
                '+${result.coinsEarned}',
                AppColors.coinAmber,
              ),
              _buildResultRow(
                '⭐ XP',
                '+${result.xpEarned}',
                AppColors.xpPurple,
              ),
              if (_combo > 1)
                _buildResultRow('🔥 Combo', 'x$_combo', AppColors.streakOrange),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _currentIndex = 0;
                          _score = 0;
                          _combo = 0;
                          _timeSpent = 0;
                          _answers = List.filled(widget.questions.length, null);
                          _quizCompleted = false;
                          _resetQuestionTimer();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );

  void _answerQuestion(int selectedIndex) {
    if (_answers[_currentIndex] != null) return;
    _questionTimer.cancel();
    final isCorrect =
        selectedIndex == widget.questions[_currentIndex].correctIndex;
    setState(() {
      _answers[_currentIndex] = selectedIndex;
      if (isCorrect) {
        _score++;
        _combo++;
        _comboController.forward(from: 0);
        _correctController.forward(from: 0);
        HapticFeedback.lightImpact();
      } else {
        _combo = 0;
        _shakeController.forward(from: 0);
        HapticFeedback.mediumImpact();
      }
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_currentIndex + 1 < widget.questions.length) {
        setState(() {
          _currentIndex++;
          _resetQuestionTimer();
          _questionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (_questionTimeLeft > 0) {
              setState(() => _questionTimeLeft--);
              _timerController.animateTo(1 - (_questionTimeLeft / 30));
            } else
              _answerQuestion(-1);
          });
        });
      } else {
        setState(() => _quizCompleted = true);
        _submitQuiz();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted)
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    final question = widget.questions[_currentIndex];
    final hasAnswered = _answers[_currentIndex] != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.subject,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.streakOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer,
                    size: 16,
                    color: AppColors.streakOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_questionTimeLeft s',
                    style: const TextStyle(
                      color: AppColors.streakOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.questions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: _timerController,
            builder: (_, __) => LinearProgressIndicator(
              value: 1 - _timerController.value,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                _questionTimeLeft > 10 ? AppColors.success : AppColors.danger,
              ),
              minHeight: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentIndex + 1}/${widget.questions.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_combo > 1)
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _comboController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.streakOrange, AppColors.coinAmber],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.streakOrange.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        '🔥 x$_combo COMBO!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Text(
                  'Score: $_score',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedBuilder(
              animation: _shakeController,
              builder: (_, __) => Transform.translate(
                offset: Offset(sin(_shakeController.value * pi * 6) * 8, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: hasAnswered
                          ? (_answers[_currentIndex] == question.correctIndex
                                ? AppColors.success
                                : AppColors.danger)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: question.difficulty == 'Hard'
                              ? AppColors.danger.withOpacity(0.1)
                              : question.difficulty == 'Medium'
                              ? AppColors.coinAmber.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          question.difficulty,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: question.difficulty == 'Hard'
                                ? AppColors.danger
                                : question.difficulty == 'Medium'
                                ? AppColors.coinAmber
                                : AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: question.options.length,
              itemBuilder: (_, idx) {
                Color borderColor = Colors.grey.shade200,
                    bgColor = Colors.white;
                Widget? trailingIcon;
                if (hasAnswered) {
                  if (idx == question.correctIndex) {
                    borderColor = AppColors.success;
                    bgColor = AppColors.success.withOpacity(0.08);
                    trailingIcon = const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                    );
                  } else if (idx == _answers[_currentIndex] &&
                      idx != question.correctIndex) {
                    borderColor = AppColors.danger;
                    bgColor = AppColors.danger.withOpacity(0.08);
                    trailingIcon = const Icon(
                      Icons.cancel,
                      color: AppColors.danger,
                    );
                  }
                }
                return GestureDetector(
                  onTap: hasAnswered ? null : () => _answerQuestion(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient:
                                hasAnswered && idx == question.correctIndex
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.success,
                                      AppColors.primaryLight,
                                    ],
                                  )
                                : hasAnswered &&
                                      idx == _answers[_currentIndex] &&
                                      idx != question.correctIndex
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.danger,
                                      Color(0xFFEF9A9A),
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      AppColors.accent,
                                      AppColors.primary,
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + idx),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            question.options[idx],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
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

// ============================================================
// LUCKY SPIN SCREEN
// ============================================================

class LuckySpinScreen extends StatefulWidget {
  final GameStateManager gameManager;
  const LuckySpinScreen({Key? key, required this.gameManager})
    : super(key: key);
  @override
  State<LuckySpinScreen> createState() => _LuckySpinScreenState();
}

class _LuckySpinScreenState extends State<LuckySpinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  bool _isSpinning = false;
  int _lastReward = 0;
  final List<int> _rewards = [10, 25, 50, 100, 200, 500, 1000, 5];
  final List<Color> _segmentColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_isSpinning || widget.gameManager.progress.coins < 50) return;
    setState(() {
      _isSpinning = true;
      _lastReward = 0;
    });
    _spinController.reset();
    _spinController.forward();
    final reward = await widget.gameManager.spinLucky();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted)
      setState(() {
        _isSpinning = false;
        _lastReward = reward;
      });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text(
        'Lucky Spin 🎰',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Cost: 50 Coins',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Balance: ${widget.gameManager.progress.coins} 🪙',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.coinAmber,
            ),
          ),
          const SizedBox(height: 40),
          AnimatedBuilder(
            animation: _spinAnimation,
            builder: (_, __) => Transform.rotate(
              angle: _spinAnimation.value * 10 * pi,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _WheelPainter(_rewards, _segmentColors),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          if (_lastReward > 0)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (_, val, __) => Transform.scale(
                scale: val,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.coinAmber, AppColors.gold],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Text(
                    '🎉 You Won +$_lastReward Coins!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _spin,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isSpinning
                      ? [Colors.grey, Colors.grey]
                      : [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: _isSpinning
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Text(
                _isSpinning ? 'Spinning...' : 'SPIN! (50 🪙)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _WheelPainter extends CustomPainter {
  final List<int> rewards;
  final List<Color> colors;
  _WheelPainter(this.rewards, this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / rewards.length;
    for (int i = 0; i < rewards.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle - pi / 2,
        sweepAngle,
        true,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.fill,
      );
      final textAngle = i * sweepAngle + sweepAngle / 2 - pi / 2;
      final textX = center.dx + radius * 0.65 * cos(textAngle);
      final textY = center.dy + radius * 0.65 * sin(textAngle);
      final tp = TextPainter(
        text: TextSpan(
          text: '${rewards[i]}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(center, 20, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      20,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_WheelPainter o) => false;
}

// ============================================================
// OFFLINE BANNER
// ============================================================

class OfflineBanner extends StatelessWidget {
  final bool isOnline;
  const OfflineBanner({required this.isOnline});
  @override
  Widget build(BuildContext context) => isOnline
      ? const SizedBox.shrink()
      : Container(
          color: Colors.orange.shade700,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 14, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Offline Mode — Changes will sync when online',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
}

// ============================================================
// SKELETON LOADER
// ============================================================

class _SkeletonBox extends StatefulWidget {
  final double width, height;
  final double borderRadius;
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });
  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
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
    _anim = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        color: Colors.grey.withOpacity(_anim.value),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
    ),
  );
}

// ============================================================
// GAME SCREEN — MAIN ENTRY POINT
// ============================================================

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with RestorationMixin, TickerProviderStateMixin {
  late GameStateManager _gameManager;
  final RestorableInt _selectedTab = RestorableInt(0);
  final PageController _pageController = PageController();
  late AnimationController _xpBarController, _navController, _appBarController;

  final List<Map<String, dynamic>> _subjects = [
    {
      'name': 'C Programming',
      'icon': '⚙️',
      'questions': kQuizData['C Programming'] ?? [],
      'color': [const Color(0xFF1A237E), const Color(0xFF283593)],
    },
    {
      'name': 'Python',
      'icon': '🐍',
      'questions': kQuizData['Python'] ?? [],
      'color': [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
    },
    {
      'name': 'DBMS',
      'icon': '🗄️',
      'questions': kQuizData['DBMS'] ?? [],
      'color': [const Color(0xFF880E4F), const Color(0xFFC2185B)],
    },
    {
      'name': 'Networking',
      'icon': '🌐',
      'questions': kQuizData['Networking'] ?? [],
      'color': [const Color(0xFF004D40), const Color(0xFF00796B)],
    },
    {
      'name': 'Mathematics',
      'icon': '📐',
      'questions': kQuizData['Mathematics'] ?? [],
      'color': [const Color(0xFFE65100), const Color(0xFFF4511E)],
    },
    {
      'name': 'English',
      'icon': '📖',
      'questions': kQuizData['English'] ?? [],
      'color': [const Color(0xFF4A148C), const Color(0xFF7B1FA2)],
    },
    {
      'name': 'Aptitude',
      'icon': '🧠',
      'questions': kQuizData['Aptitude'] ?? [],
      'color': [const Color(0xFF006064), const Color(0xFF0097A7)],
    },
    {
      'name': 'Computer Fundamentals',
      'icon': '💻',
      'questions': kQuizData['Computer Fundamentals'] ?? [],
      'color': [const Color(0xFF3E2723), const Color(0xFF6D4C41)],
    },
  ];

  @override
  String? get restorationId => 'game_screen';
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) =>
      registerForRestoration(_selectedTab, 'selected_tab');

  @override
  void initState() {
    super.initState();
    _gameManager = GameStateManager();
    _xpBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _appBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameManager.setOverlayContext(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _gameManager.dispose();
    _xpBarController.dispose();
    _navController.dispose();
    _appBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gameManager,
      builder: (context, _) {
        if (_gameManager.isLoading)
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading your progress...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );

        if (!_gameManager.isLoggedIn)
          return PremiumLoginScreen(gameManager: _gameManager);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              OfflineBanner(isOnline: _gameManager.isOnline),
              _buildPremiumAppBar(),
              if (_gameManager.motivationalMessage.isNotEmpty)
                _buildMotivationBanner(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _selectedTab.value = i),
                  children: [
                    _buildHomeDashboard(),
                    _buildLeaderboardScreen(),
                    _buildQuizHub(),
                    _buildPremiumProfile(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildPremiumNav(),
        );
      },
    );
  }

  Widget _buildMotivationBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
    ),
    child: Text(
      _gameManager.motivationalMessage,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _buildPremiumNav() => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 20,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
            _buildNavItem(
              1,
              Icons.leaderboard_rounded,
              Icons.leaderboard_outlined,
              'Ranks',
            ),
            _buildNavItem(2, Icons.quiz_rounded, Icons.quiz_outlined, 'Quiz'),
            _buildNavItem(
              3,
              Icons.person_rounded,
              Icons.person_outline,
              'Profile',
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isActive = _selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _pageController.jumpToPage(index);
          setState(() => _selectedTab.value = index);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: isActive
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive ? AppColors.primary : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumAppBar() {
    final progress = _gameManager.progress;
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _appBarController,
              curve: Curves.easeOutCubic,
            ),
          ),
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _selectedTab.value = 3),
              child: Hero(
                tag: 'avatar',
                child: Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          progress.avatarId,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Lv${progress.level}',
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.nickname.isEmpty ? 'Student' : progress.nickname,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${progress.rankTitle} · #${progress.rank}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            _buildAppBarChip(
              Icons.monetization_on,
              '${progress.coins}',
              AppColors.coinAmber,
            ),
            const SizedBox(width: 6),
            _buildAppBarChip(Icons.star, '${progress.xp}', AppColors.xpPurple),
            const SizedBox(width: 6),
            _buildAppBarChip(
              Icons.local_fire_department,
              '${progress.streak}',
              AppColors.streakOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarChip(IconData icon, String value, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );

  // ============================================================
  // HOME DASHBOARD
  // ============================================================

  Widget _buildHomeDashboard() {
    final progress = _gameManager.progress;
    final xpNeeded = progress.level * 500;
    final xpPercent = progress.xp / xpNeeded;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _xpBarController.animateTo(
        xpPercent,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      ),
    );

    return RefreshIndicator(
      onRefresh: () async => _gameManager._syncToFirebase(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildXPCard(progress, xpNeeded),
            const SizedBox(height: 16),
            _buildStatsRow(progress),
            const SizedBox(height: 16),
            _buildDailyRewardCard(),
            const SizedBox(height: 16),
            _buildChestSection(progress),
            const SizedBox(height: 16),
            _buildMissionsCard(),
            const SizedBox(height: 16),
            _buildAnnouncementsSection(),
            const SizedBox(height: 16),
            _buildSubjectMasteryGrid(),
            const SizedBox(height: 16),
            _buildLeaderboardPreview(),
            const SizedBox(height: 16),
            _buildActivityFeed(progress),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .where('active', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty)
          return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📢 Announcements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...snap.data!.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.08),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Text('📢', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            data['message'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildXPCard(StudentProgress progress, int xpNeeded) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.gradientStart, AppColors.gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.gradientStart.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${progress.level}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  progress.rankTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${progress.streak} day streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'XP Progress',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              '${progress.xp} / $xpNeeded XP',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AnimatedBuilder(
            animation: _xpBarController,
            builder: (_, __) => LinearProgressIndicator(
              value: _xpBarController.value,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${xpNeeded - progress.xp} XP to next level',
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _buildStatsRow(StudentProgress progress) => Row(
    children: [
      _buildStatCard(
        'Coins',
        '${progress.coins}',
        Icons.monetization_on,
        AppColors.coinAmber,
      ),
      const SizedBox(width: 10),
      _buildStatCard(
        'Quizzes',
        '${progress.totalQuizzes}',
        Icons.quiz,
        AppColors.accent,
      ),
      const SizedBox(width: 10),
      _buildStatCard(
        'Perfect',
        '${progress.perfectQuizCount}',
        Icons.star,
        AppColors.gold,
      ),
    ],
  );

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    ),
  );

  Widget _buildDailyRewardCard() {
    final canClaim = _gameManager.canClaimDaily;
    return GestureDetector(
      onTap: canClaim
          ? () {
              _gameManager.claimDailyReward();
              setState(() {});
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canClaim
                ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]
                : [Colors.grey.shade400, Colors.grey.shade500],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (canClaim ? AppColors.primary : Colors.grey).withOpacity(
                0.3,
              ),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Reward',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    canClaim
                        ? 'Claim ${50 + _gameManager.progress.streak * 10} coins now!'
                        : 'Come back tomorrow!',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: canClaim ? Colors.white : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                canClaim ? 'Claim' : '✓ Done',
                style: TextStyle(
                  color: canClaim ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChestSection(StudentProgress progress) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LuckySpinScreen(gameManager: _gameManager),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B1FA2).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Column(
              children: [
                Text('🎰', style: TextStyle(fontSize: 30)),
                SizedBox(height: 6),
                Text(
                  'Lucky Spin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '50 🪙',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: GestureDetector(
          onTap: progress.chestCount > 0
              ? () async {
                  final reward = await _gameManager.openChest();
                  if (reward.isNotEmpty && mounted)
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        title: const Text(
                          '🎁 Chest Opened!',
                          textAlign: TextAlign.center,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+${reward['coins']} Coins',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.coinAmber,
                              ),
                            ),
                            Text(
                              '+${reward['xp']} XP',
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.xpPurple,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Awesome!'),
                          ),
                        ],
                      ),
                    );
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: progress.chestCount > 0
                    ? [const Color(0xFFFF8F00), const Color(0xFFFFA000)]
                    : [Colors.grey.shade300, Colors.grey.shade400],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color:
                      (progress.chestCount > 0
                              ? const Color(0xFFFF8F00)
                              : Colors.grey)
                          .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 30)),
                const SizedBox(height: 6),
                const Text(
                  'Reward Chest',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${progress.chestCount} available',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildMissionsCard() {
    final progress = _gameManager.progress;
    final missions = [
      {
        'icon': '🎯',
        'title': 'Complete 3 quizzes',
        'current': min(
          progress.totalQuizzes % 3 == 0 ? 3 : progress.totalQuizzes % 3,
          3,
        ),
        'target': 3,
        'reward': 50,
      },
      {
        'icon': '⭐',
        'title': 'Score 90%+ in any quiz',
        'current': progress.perfectQuizCount > 0 ? 1 : 0,
        'target': 1,
        'reward': 100,
      },
      {
        'icon': '🔥',
        'title': 'Maintain 5 day streak',
        'current': min(progress.streak, 5),
        'target': 5,
        'reward': 200,
      },
      {
        'icon': '⚡',
        'title': 'Earn 500 XP today',
        'current': min(progress.xp, 500),
        'target': 500,
        'reward': 75,
      },
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Daily Missions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Text('🎯', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 14),
          ...missions.map(
            (m) => _buildMissionItem(
              m['icon'] as String,
              m['title'] as String,
              m['current'] as int,
              m['target'] as int,
              m['reward'] as int,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionItem(
    String icon,
    String title,
    int current,
    int target,
    int reward,
  ) {
    final isDone = current >= target;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.success.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? AppColors.success.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDone ? AppColors.success : Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: current / target,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? AppColors.success : AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$current / $target',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.coinAmber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isDone ? '✓' : '+$reward 🪙',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isDone ? AppColors.success : AppColors.coinAmber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectMasteryGrid() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Subject Mastery',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _subjects.length,
        itemBuilder: (_, index) {
          final subject = _subjects[index];
          final sp =
              _gameManager.progress.subjectProgress[subject['name']] ?? 0;
          final colors = subject['color'] as List<Color>;
          return GestureDetector(
            onTap: () {
              _pageController.jumpToPage(2);
              setState(() => _selectedTab.value = 2);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        subject['icon'],
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subject['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: sp / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors[0],
                            ),
                            minHeight: 5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$sp%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
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
    ],
  );

  Widget _buildLeaderboardPreview() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Players',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                _pageController.jumpToPage(1);
                setState(() => _selectedTab.value = 1);
              },
              child: const Text(
                'View All ›',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('students')
              .orderBy('xp', descending: true)
              .limit(3)
              .snapshots(),
          builder: (ctx, snap) {
            if (!snap.hasData)
              return const _SkeletonBox(
                width: double.infinity,
                height: 120,
                borderRadius: 12,
              );
            return Column(
              children: List.generate(snap.data!.docs.length, (i) {
                final data = snap.data!.docs[i].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        ['🥇', '🥈', '🥉'][i],
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            data['avatarId'] ?? '🔥',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['nickname'] ?? 'Student',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              data['rankTitle'] ?? 'Beginner',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${data['xp'] ?? 0} XP',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.xpPurple,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ],
    ),
  );

  Widget _buildActivityFeed(StudentProgress progress) {
    if (progress.activityHistory.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...progress.activityHistory
            .take(5)
            .map(
              (activity) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 6),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.history,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['type'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            activity['description'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  // ============================================================
  // LEADERBOARD SCREEN
  // ============================================================

  Widget _buildLeaderboardScreen() => DefaultTabController(
    length: 3,
    child: Column(
      children: [
        Container(
          color: Colors.white,
          child: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Global'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildLeaderboardList('xp'),
              _buildLeaderboardList('xp'),
              _buildLeaderboardList('xp'),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildLeaderboardList(
    String sortField,
  ) => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('students')
        .orderBy('xp', descending: true)
        .limit(50)
        .snapshots(),
    builder: (ctx, snap) {
      if (!snap.hasData)
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: const _SkeletonBox(
              width: double.infinity,
              height: 72,
              borderRadius: 16,
            ),
          ),
        );
      final students = snap.data!.docs;
      return RefreshIndicator(
        onRefresh: () async => _gameManager._syncToFirebase(),
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (_, index) {
            final data = students[index].data() as Map<String, dynamic>;
            final rank = index + 1;
            final isCurrentUser =
                data['nickname'] == _gameManager.progress.nickname;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppColors.primary.withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isCurrentUser
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: rank <= 3
                        ? AppColors.gold.withOpacity(0.15)
                        : AppColors.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                leading: SizedBox(
                  width: 48,
                  child: Center(
                    child: rank == 1
                        ? const Text('🥇', style: TextStyle(fontSize: 26))
                        : rank == 2
                        ? const Text('🥈', style: TextStyle(fontSize: 26))
                        : rank == 3
                        ? const Text('🥉', style: TextStyle(fontSize: 26))
                        : Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '#$rank',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: rank == 1
                              ? [AppColors.gold, const Color(0xFFFFF176)]
                              : rank == 2
                              ? [AppColors.silver, Colors.grey]
                              : rank == 3
                              ? [AppColors.bronze, Colors.brown]
                              : [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          data['avatarId'] ?? '🔥',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data['nickname'] ?? 'Student',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (isCurrentUser)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'You',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          'Lv.${data['level'] ?? 1} ${data['rankTitle'] ?? 'Beginner'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${data['xp'] ?? 0} XP',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.xpPurple,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 12,
                          color: AppColors.streakOrange,
                        ),
                        Text(
                          ' ${data['streak'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
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
    },
  );

  // ============================================================
  // QUIZ HUB
  // ============================================================

  Widget _buildQuizHub() {
    final available = _subjects
        .where((s) => (s['questions'] as List).isNotEmpty)
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Subject',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${available.length} subjects',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: available.length,
            itemBuilder: (_, index) {
              final subject = available[index];
              final questions = subject['questions'] as List<QuizQuestion>;
              final mastery =
                  _gameManager.progress.subjectProgress[subject['name']] ?? 0;
              final colors = subject['color'] as List<Color>;
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnhancedQuizScreen(
                        gameManager: _gameManager,
                        subject: subject['name'],
                        questions: questions,
                      ),
                    ),
                  );
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -15,
                        right: -15,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject['icon'],
                              style: const TextStyle(fontSize: 36),
                            ),
                            const Spacer(),
                            Text(
                              subject['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: mastery / 100,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                minHeight: 5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$mastery% mastered',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${questions.length} Q',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
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
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PREMIUM PROFILE
  // ============================================================

  Widget _buildPremiumProfile() {
    final progress = _gameManager.progress;
    return RefreshIndicator(
      onRefresh: () async => _gameManager._syncToFirebase(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(progress),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileStats(progress),
                  const SizedBox(height: 16),
                  _buildAvatarCustomizer(progress),
                  const SizedBox(height: 16),
                  _buildAchievementsCard(progress),
                  const SizedBox(height: 16),
                  _buildProfileActivity(progress),
                  const SizedBox(height: 16),
                  _buildLogoutButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(StudentProgress progress) => Container(
    width: double.infinity,
    padding: const EdgeInsets.only(top: 24, bottom: 30, left: 20, right: 20),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.gradientStart, AppColors.gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      children: [
        Hero(
          tag: 'avatar',
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20),
              ],
            ),
            child: Center(
              child: Text(
                progress.avatarId,
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          progress.nickname.isEmpty ? 'Student' : progress.nickname,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${progress.rankTitle} • Level ${progress.level} • Rank #${progress.rank}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeaderStat('🔥', '${progress.streak}', 'Streak'),
            const SizedBox(width: 24),
            _buildHeaderStat('🏆', '${progress.achievements.length}', 'Badges'),
            const SizedBox(width: 24),
            _buildHeaderStat('💎', '${progress.perfectQuizCount}', 'Perfect'),
          ],
        ),
      ],
    ),
  );

  Widget _buildHeaderStat(String icon, String value, String label) => Column(
    children: [
      Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
    ],
  );

  Widget _buildProfileStats(StudentProgress progress) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        _buildStatRow('Total Quizzes', '${progress.totalQuizzes}'),
        _buildStatRow('Correct Answers', '${progress.correctAnswers}'),
        _buildStatRow('Perfect Quizzes', '${progress.perfectQuizCount}'),
        _buildStatRow('Total Coins Earned', '${progress.totalCoinsEarned}'),
        _buildStatRow('Total XP Earned', '${progress.totalXPEarned}'),
        _buildStatRow('Achievements', '${progress.achievements.length}'),
        _buildStatRow('Chests Opened', '${progress.luckySpinCount}'),
        _buildStatRow('Boss Quizzes', '${progress.bossQuizzesCompleted}'),
      ],
    ),
  );

  Widget _buildStatRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    ),
  );

  Widget _buildAvatarCustomizer(StudentProgress progress) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customize Avatar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: kAvatars
              .map(
                (avatar) => GestureDetector(
                  onTap: () => _gameManager.updateAvatar(avatar),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: progress.avatarId == avatar
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: progress.avatarId == avatar
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(avatar, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );

  Widget _buildAchievementsCard(StudentProgress progress) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${progress.achievements.length}',
                style: const TextStyle(
                  color: AppColors.coinAmber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (progress.achievements.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('🏅', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 8),
                  Text(
                    'No achievements yet.\nKeep learning to unlock them!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: progress.achievements
                .map(
                  (a) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      a,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    ),
  );

  Widget _buildProfileActivity(StudentProgress progress) {
    if (progress.activityHistory.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...progress.activityHistory
              .take(8)
              .map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.history,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['type'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              activity['description'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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

  Widget _buildLogoutButton() => Container(
    width: double.infinity,
    height: 52,
    decoration: BoxDecoration(
      color: AppColors.danger.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
    ),
    child: ElevatedButton.icon(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Logout?'),
          content: const Text(
            'Are you sure you want to logout? Your progress is saved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _gameManager.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      icon: const Icon(Icons.logout, color: AppColors.danger),
      label: const Text(
        'Logout',
        style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}
