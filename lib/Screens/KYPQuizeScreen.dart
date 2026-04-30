// ============================================================
//  kyp_quiz_screen.dart
//  BEEDI College - KYP Quiz & Learning Hub
//  ✨ Ultra-Enhanced Interactive Gaming & Learning Platform ✨
//  20+ Features | Full Navigation | Beautiful Animations
//  Fully Responsive for Mobile, Tablet & Desktop
// ============================================================

import 'dart:async';
import 'dart:math';
import 'package:beedi_college/QuzeScreens/BS_CITScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ════════════════════════════════════════════════════════════
//  CONSTANTS & THEME
// ════════════════════════════════════════════════════════════

class _AppColors {
  static const purple = Color(0xFF6C2BD9);
  static const purpleLight = Color(0xFF9B59F5);
  static const pink = Color(0xFFFF3B8C);
  static const orange = Color(0xFFFF8C42);
  static const yellow = Color(0xFFFFD166);
  static const green = Color(0xFF06D6A0);
  static const blue = Color(0xFF118AB2);
  static const darkBg = Color(0xFF0D0620);
  static const darkCard = Color(0xFF1A0B2E);
  static const cardBg = Color(0xFFFFFFFF);
  static const accent = Color(0xFFEF476F);
  static const teal = Color(0xFF00B4D8);
  static const indigo = Color(0xFF4361EE);
}

// ── Category data ─────────────────────────────────────────
const List<Map<String, dynamic>> _categories = [
  {
    'name': 'General Knowledge',
    'icon': Icons.public_rounded,
    'color': 0xFF6C2BD9,
  },
  {
    'name': 'Computer Basics',
    'icon': Icons.computer_rounded,
    'color': 0xFFFF3B8C,
  },
  {'name': 'Internet', 'icon': Icons.wifi_rounded, 'color': 0xFFFF8C42},
  {
    'name': 'Digital Literacy',
    'icon': Icons.phone_android_rounded,
    'color': 0xFF06D6A0,
  },
  {'name': 'Programming', 'icon': Icons.code_rounded, 'color': 0xFF118AB2},
  {'name': 'Reasoning', 'icon': Icons.psychology_rounded, 'color': 0xFFFFD166},
  {'name': 'Fun Games', 'icon': Icons.celebration_rounded, 'color': 0xFFEF476F},
  {'name': 'Science', 'icon': Icons.science_rounded, 'color': 0xFF00B4D8},
  {'name': 'Mathematics', 'icon': Icons.calculate_rounded, 'color': 0xFF4361EE},
];

// ── Game cards data ────────────────────────────────────────
const List<Map<String, dynamic>> _gameCards = [
  {
    'title': 'Quiz Challenge',
    'subtitle': 'Test your knowledge',
    'icon': Icons.quiz_rounded,
    'color': 0xFF6C2BD9,
    'difficulty': 'Medium',
    'points': 100,
  },
  {
    'title': 'Daily Quiz',
    'subtitle': 'New quiz every day',
    'icon': Icons.today_rounded,
    'color': 0xFFFF3B8C,
    'difficulty': 'Easy',
    'points': 50,
  },
  {
    'title': 'Rapid Fire Quiz',
    'subtitle': 'Quick 60-second challenge',
    'icon': Icons.timer_rounded,
    'color': 0xFFFF8C42,
    'difficulty': 'Hard',
    'points': 200,
  },
  {
    'title': 'Multiplayer Quiz',
    'subtitle': 'Play with friends',
    'icon': Icons.people_rounded,
    'color': 0xFF06D6A0,
    'difficulty': 'Medium',
    'points': 150,
  },
  {
    'title': 'Puzzle Game',
    'subtitle': 'Solve brain teasers',
    'icon': Icons.extension_rounded,
    'color': 0xFF118AB2,
    'difficulty': 'Medium',
    'points': 120,
  },
  {
    'title': 'Memory Game',
    'subtitle': 'Test your memory',
    'icon': Icons.memory_rounded,
    'color': 0xFFFFD166,
    'difficulty': 'Easy',
    'points': 80,
  },
  {
    'title': 'Typing Speed',
    'subtitle': 'Improve your typing',
    'icon': Icons.keyboard_rounded,
    'color': 0xFFEF476F,
    'difficulty': 'Medium',
    'points': 100,
  },
  {
    'title': 'Coding Quiz',
    'subtitle': 'Programming challenges',
    'icon': Icons.code_rounded,
    'color': 0xFF6C2BD9,
    'difficulty': 'Hard',
    'points': 250,
  },
  {
    'title': 'GK Battle',
    'subtitle': 'Compete in GK',
    'icon': Icons.emoji_events_rounded,
    'color': 0xFFFF3B8C,
    'difficulty': 'Medium',
    'points': 180,
  },
  {
    'title': 'Math Quiz',
    'subtitle': 'Solve math problems',
    'icon': Icons.calculate_rounded,
    'color': 0xFFFF8C42,
    'difficulty': 'Easy',
    'points': 90,
  },
  {
    'title': 'Science Quiz',
    'subtitle': 'Explore science world',
    'icon': Icons.science_rounded,
    'color': 0xFF00B4D8,
    'difficulty': 'Medium',
    'points': 110,
  },
  {
    'title': 'Word Scramble',
    'subtitle': 'Unscramble the words',
    'icon': Icons.text_fields_rounded,
    'color': 0xFF4361EE,
    'difficulty': 'Easy',
    'points': 70,
  },
];

// ── Degree programs ────────────────────────────────────────
const List<Map<String, dynamic>> _degreePrograms = [
  {
    'title': 'BS-CIT',
    'subtitle': 'Bachelor of Science in Information Technology',
    'duration': '4 Years',
    'credits': 132,
    'icon': Icons.computer_rounded,
    'color': 0xFF6C2BD9,
    'students': 1240,
    'rating': 4.8,
  },
  {
    'title': 'BS-CLS',
    'subtitle': 'Bachelor of Science in Computer Science',
    'duration': '4 Years',
    'credits': 136,
    'icon': Icons.code_rounded,
    'color': 0xFFFF3B8C,
    'students': 980,
    'rating': 4.9,
  },
  {
    'title': 'BS-CSS',
    'subtitle': 'Bachelor of Science in Clinical Lab Sciences',
    'duration': '4 Years',
    'credits': 140,
    'icon': Icons.science_rounded,
    'color': 0xFF06D6A0,
    'students': 670,
    'rating': 4.7,
  },
  {
    'title': 'Basic of IT',
    'subtitle': 'Bachelor of Science in Information Technology',
    'duration': '3 Years',
    'credits': 110,
    'icon': Icons.devices_rounded,
    'color': 0xFF118AB2,
    'students': 890,
    'rating': 4.6,
  },
  {
    'title': 'Basic of LS',
    'subtitle': 'Bachelor of Science in Business Administration',
    'duration': '4 Years',
    'credits': 128,
    'icon': Icons.business_rounded,
    'color': 0xFFFF8C42,
    'students': 1100,
    'rating': 4.5,
  },
];

// ── Recent plays ───────────────────────────────────────────
const List<Map<String, dynamic>> _recentPlays = [
  {
    'title': 'Quiz Challenge',
    'score': '850/1000',
    'date': '2 hours ago',
    'icon': Icons.quiz_rounded,
    'color': 0xFF6C2BD9,
    'percentage': 85,
  },
  {
    'title': 'Daily Quiz',
    'score': '45/50',
    'date': 'Yesterday',
    'icon': Icons.today_rounded,
    'color': 0xFFFF3B8C,
    'percentage': 90,
  },
  {
    'title': 'Rapid Fire',
    'score': '1200/1500',
    'date': '2 days ago',
    'icon': Icons.timer_rounded,
    'color': 0xFFFF8C42,
    'percentage': 80,
  },
];

// ── Leaderboard data ───────────────────────────────────────
const List<Map<String, dynamic>> _leaderboard = [
  {
    'name': 'Alex Kumar',
    'score': 12500,
    'avatar': '😎',
    'rank': 1,
    'badge': '🥇',
    'change': '+2',
  },
  {
    'name': 'Priya Sharma',
    'score': 11800,
    'avatar': '🦸',
    'rank': 2,
    'badge': '🥈',
    'change': '+1',
  },
  {
    'name': 'Rahul Verma',
    'score': 10900,
    'avatar': '🧑',
    'rank': 3,
    'badge': '🥉',
    'change': '-1',
  },
  {
    'name': 'You',
    'score': 9850,
    'avatar': '👤',
    'rank': 4,
    'badge': '🎯',
    'change': '+3',
  },
];

// ── Achievements data ──────────────────────────────────────
const List<Map<String, dynamic>> _achievements = [
  {
    'title': 'First Win',
    'icon': '🏆',
    'desc': 'Win your first quiz',
    'earned': true,
    'color': 0xFFFFD166,
  },
  {
    'title': 'Speed Demon',
    'icon': '⚡',
    'desc': 'Complete rapid fire under 30s',
    'earned': true,
    'color': 0xFFFF8C42,
  },
  {
    'title': 'Scholar',
    'icon': '📚',
    'desc': 'Complete 50 quizzes',
    'earned': true,
    'color': 0xFF6C2BD9,
  },
  {
    'title': 'Streak Master',
    'icon': '🔥',
    'desc': '7-day login streak',
    'earned': true,
    'color': 0xFFEF476F,
  },
  {
    'title': 'Perfect Score',
    'icon': '💯',
    'desc': 'Get 100% in any quiz',
    'earned': false,
    'color': 0xFF06D6A0,
  },
  {
    'title': 'Social Butterfly',
    'icon': '👥',
    'desc': 'Play 5 multiplayer games',
    'earned': false,
    'color': 0xFF118AB2,
  },
];

// ── Daily challenges ───────────────────────────────────────
const List<Map<String, dynamic>> _dailyChallenges = [
  {
    'title': 'Morning Warm-up',
    'desc': 'Complete 5 GK questions',
    'reward': 50,
    'progress': 3,
    'total': 5,
    'color': 0xFF6C2BD9,
  },
  {
    'title': 'Speed Round',
    'desc': 'Finish rapid fire quiz',
    'reward': 100,
    'progress': 0,
    'total': 1,
    'color': 0xFFFF8C42,
  },
  {
    'title': 'Social Challenge',
    'desc': 'Invite a friend to play',
    'reward': 75,
    'progress': 1,
    'total': 1,
    'color': 0xFF06D6A0,
  },
];

// ── Study materials ────────────────────────────────────────
const List<Map<String, dynamic>> _studyMaterials = [
  {
    'title': 'Computer Basics',
    'lessons': 12,
    'duration': '2h 30m',
    'icon': Icons.computer_rounded,
    'color': 0xFF6C2BD9,
    'progress': 0.75,
  },
  {
    'title': 'Internet Essentials',
    'lessons': 8,
    'duration': '1h 45m',
    'icon': Icons.wifi_rounded,
    'color': 0xFFFF3B8C,
    'progress': 0.40,
  },
  {
    'title': 'Digital Payments',
    'lessons': 6,
    'duration': '1h 15m',
    'icon': Icons.payment_rounded,
    'color': 0xFF06D6A0,
    'progress': 0.20,
  },
  {
    'title': 'Cybersecurity',
    'lessons': 10,
    'duration': '2h 00m',
    'icon': Icons.security_rounded,
    'color': 0xFFFF8C42,
    'progress': 0.60,
  },
];

// ════════════════════════════════════════════════════════════
//  PARTICLE MODEL
// ════════════════════════════════════════════════════════════
class _Particle {
  double x, y, speed, size, opacity;
  Color color;
  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

// ════════════════════════════════════════════════════════════
//  MAIN KYP QUIZ SCREEN
// ════════════════════════════════════════════════════════════

class KYPQuizScreen extends StatefulWidget {
  const KYPQuizScreen({super.key});
  @override
  State<KYPQuizScreen> createState() => _KYPQuizScreenState();
}

class _KYPQuizScreenState extends State<KYPQuizScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────
  int _userPoints = 2450;
  int _userStreak = 7;
  int _userLevel = 8;
  int _userXP = 850;
  int _maxXP = 1200;
  bool _soundEnabled = true;
  bool _isDarkMode = true;
  int _selectedCategoryIndex = -1;
  String _searchQuery = '';
  bool _showSearch = false;
  int _currentBannerIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  // ── Animation Controllers ─────────────────────────────────
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _bannerCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _floatAnim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _bannerAnim;

  // Particles
  final List<_Particle> _particles = [];
  late Timer _particleTimer;
  final _rng = Random();

  // Notifications
  final List<Map<String, dynamic>> _notifications = [
    {'msg': '🎯 New challenge unlocked!', 'time': '2m ago'},
    {'msg': '🏆 You ranked up to Level 8!', 'time': '1h ago'},
    {'msg': '👥 Friend challenge received', 'time': '3h ago'},
  ];
  int _unreadNotifications = 3;

  // Banner slides
  final List<Map<String, dynamic>> _bannerSlides = [
    {
      'text': '✨ Test Your Skills & Knowledge! ✨',
      'sub': 'Play • Learn • Grow',
      'color1': 0xFF6C2BD9,
      'color2': 0xFFFF3B8C,
    },
    {
      'text': '🔥 Daily Streak Bonus Active!',
      'sub': 'Keep it going — Day 7!',
      'color1': 0xFFFF8C42,
      'color2': 0xFFFFD166,
    },
    {
      'text': '🏆 Tournament Starts in 2h!',
      'sub': 'Register now for free',
      'color1': 0xFF06D6A0,
      'color2': 0xFF118AB2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initParticles();
    _startBannerTimer();
  }

  void _initAnimations() {
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _floatAnim = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _shimmerAnim = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear));
    _bannerAnim = CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOut);

    _fadeCtrl.forward();
  }

  void _initParticles() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final w = MediaQuery.of(context).size.width;
      for (int i = 0; i < 30; i++) {
        _particles.add(
          _Particle(
            x: _rng.nextDouble() * w,
            y: _rng.nextDouble() * 800,
            speed: _rng.nextDouble() * 1.5 + 0.5,
            size: _rng.nextDouble() * 4 + 2,
            opacity: _rng.nextDouble() * 0.6 + 0.2,
            color: [
              _AppColors.purple,
              _AppColors.pink,
              _AppColors.yellow,
              _AppColors.green,
              _AppColors.teal,
            ][_rng.nextInt(5)],
          ),
        );
      }
      _particleTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (!mounted) return;
        setState(() {
          for (final p in _particles) {
            p.y -= p.speed;
            if (p.y < -10) p.y = 900;
          }
        });
      });
    });
  }

  void _startBannerTimer() {
    Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _bannerCtrl.reverse().then((_) {
        setState(
          () => _currentBannerIndex =
              (_currentBannerIndex + 1) % _bannerSlides.length,
        );
        _bannerCtrl.forward();
      });
    });
    _bannerCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _shimmerCtrl.dispose();
    _bannerCtrl.dispose();
    _particleTimer.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _AppColors.darkBg,
      body: Stack(
        children: [
          // ── Animated particle background ───────────────────
          _buildParticleBackground(size),
          // ── Main scrollable content ────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildAppBar(context)),
                SliverToBoxAdapter(
                  child: _showSearch
                      ? _buildSearchBar()
                      : const SizedBox.shrink(),
                ),
                SliverToBoxAdapter(child: _buildHeroBanner()),
                SliverToBoxAdapter(child: _buildStatsRow()),
                SliverToBoxAdapter(child: _buildUserProfile()),
                SliverToBoxAdapter(child: _buildDailyChallenges()),
                SliverToBoxAdapter(child: _buildCategoriesSection()),
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    '🎮 Game Center',
                    onTap: () => _navigateTo(context, const AllGamesScreen()),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: _buildGameGrid(size),
                ),
                SliverToBoxAdapter(child: _buildStudyMaterials()),
                SliverToBoxAdapter(child: _buildDegreePrograms()),
                SliverToBoxAdapter(child: _buildContinueLearning()),
                SliverToBoxAdapter(child: _buildAchievements()),
                SliverToBoxAdapter(child: _buildLeaderboardSection()),
                SliverToBoxAdapter(child: _buildTournamentBanner()),
                SliverToBoxAdapter(child: _buildQuickActions()),
                // NEW: Exam Practice Card Section
                SliverToBoxAdapter(child: _buildExamPracticeCard()),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        ],
      ),
      // ── Floating Action Button ─────────────────────────────
      floatingActionButton: _buildFAB(),
    );
  }

  // ── Particle Background ────────────────────────────────────
  Widget _buildParticleBackground(Size size) {
    return CustomPaint(painter: _ParticlePainter(_particles), size: size);
  }

  // ════════════════════════════════════════════════════════════
  //  APP BAR  [FEATURE 1]
  // ════════════════════════════════════════════════════════════
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_AppColors.purple, _AppColors.pink, _AppColors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _AppColors.purple.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildIconBtn(
                Icons.arrow_back_rounded,
                () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFD166)],
                      ).createShader(b),
                      child: const Text(
                        'KYP Quiz & Games',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      'BEEDI College Platform',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Points badge
              _buildStatBadge(
                Icons.monetization_on_rounded,
                Colors.yellow,
                '$_userPoints',
              ),
              const SizedBox(width: 8),
              // Streak badge
              _buildStatBadge(
                Icons.local_fire_department_rounded,
                Colors.orange,
                '$_userStreak🔥',
              ),
              const SizedBox(width: 4),
              // Search
              _buildIconBtn(
                Icons.search_rounded,
                () => setState(() => _showSearch = !_showSearch),
              ),
              // Notifications
              Stack(
                children: [
                  _buildIconBtn(
                    Icons.notifications_rounded,
                    () => _showNotifications(context),
                  ),
                  if (_unreadNotifications > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: _AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$_unreadNotifications',
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
              // Sound & theme
              _buildIconBtn(
                _soundEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                () => setState(() => _soundEnabled = !_soundEnabled),
              ),
              _buildIconBtn(
                _isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                () => setState(() => _isDarkMode = !_isDarkMode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, Color iconColor, String label) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Transform.scale(
        scale: _pulseAnim.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  SEARCH BAR  [FEATURE 2]
  // ════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.purple.withOpacity(0.4)),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search games, quizzes...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: _AppColors.purple),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  HERO BANNER (Auto-sliding)  [FEATURE 3]
  // ════════════════════════════════════════════════════════════
  Widget _buildHeroBanner() {
    final slide = _bannerSlides[_currentBannerIndex];
    return FadeTransition(
      opacity: _bannerAnim,
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(slide['color1']), Color(slide['color2'])],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Color(slide['color1']).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            // Floating emoji
            AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, __) => Positioned(
                right: 24,
                top: 24 + _floatAnim.value,
                child: const Text('🎮', style: TextStyle(fontSize: 60)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slide['text'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    slide['sub'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _navigateTo(context, const TournamentScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Join Now →',
                        style: TextStyle(
                          color: _AppColors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Slide dots
            Positioned(
              bottom: 12,
              left: 24,
              child: Row(
                children: List.generate(
                  _bannerSlides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    width: i == _currentBannerIndex ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        i == _currentBannerIndex ? 1.0 : 0.4,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  STATS ROW  [FEATURE 4]
  // ════════════════════════════════════════════════════════════
  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            '2,450',
            'Total Points',
            Icons.stars_rounded,
            _AppColors.yellow,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            '7 Days',
            'Streak',
            Icons.local_fire_department_rounded,
            _AppColors.orange,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            'Rank #4',
            'Global',
            Icons.emoji_events_rounded,
            _AppColors.purple,
          ),
          const SizedBox(width: 10),
          _buildStatCard('48', 'Quizzes', Icons.quiz_rounded, _AppColors.green),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateTo(
          context,
          ProfileScreen(
            userPoints: _userPoints,
            userLevel: _userLevel,
            userXP: _userXP,
            maxXP: _maxXP,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  USER PROFILE  [FEATURE 5]
  // ════════════════════════════════════════════════════════════
  Widget _buildUserProfile() {
    return GestureDetector(
      onTap: () => _navigateTo(
        context,
        ProfileScreen(
          userPoints: _userPoints,
          userLevel: _userLevel,
          userXP: _userXP,
          maxXP: _maxXP,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _AppColors.purple.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: _AppColors.purple.withOpacity(0.1),
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with glow
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_AppColors.purple, _AppColors.pink],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _AppColors.purple.withOpacity(
                        _pulseAnim.value * 0.6,
                      ),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 34)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alex Kumar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _AppColors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Level $_userLevel: Knowledge Seeker',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _AppColors.yellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '⭐ Pro',
                          style: TextStyle(
                            color: _AppColors.yellow,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'XP Progress',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 10,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$_userXP/$_maxXP',
                                  style: const TextStyle(
                                    color: _AppColors.yellow,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _userXP / _maxXP,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  _AppColors.yellow,
                                ),
                                minHeight: 8,
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
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  DAILY CHALLENGES  [FEATURE 6]
  // ════════════════════════════════════════════════════════════
  Widget _buildDailyChallenges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '⚡ Daily Challenges',
          onTap: () => _navigateTo(context, const DailyChallengesScreen()),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _dailyChallenges.length,
            itemBuilder: (context, i) {
              final ch = _dailyChallenges[i];
              return GestureDetector(
                onTap: () => _navigateTo(context, DailyChallengesScreen()),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(ch['color']),
                        Color(ch['color']).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ch['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${ch['reward']} pts',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ch['desc'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ch['progress'] / ch['total'],
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ch['progress']}/${ch['total']} complete',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
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

  // ════════════════════════════════════════════════════════════
  //  CATEGORIES  [FEATURE 7]
  // ════════════════════════════════════════════════════════════
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '📚 Categories',
          onTap: () => _navigateTo(context, const AllCategoriesScreen()),
        ),
        SizedBox(
          height: 54,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (ctx, i) {
              final cat = _categories[i];
              final selected = _selectedCategoryIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategoryIndex = selected ? -1 : i);
                  _navigateTo(
                    context,
                    CategoryQuizScreen(categoryName: cat['name']),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Color(cat['color'])
                        : Color(cat['color']).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Color(
                        cat['color'],
                      ).withOpacity(selected ? 1.0 : 0.5),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Color(cat['color']).withOpacity(0.35),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat['icon'],
                        size: 16,
                        color: selected ? Colors.white : Color(cat['color']),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat['name'],
                        style: TextStyle(
                          color: selected ? Colors.white : Color(cat['color']),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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

  // ════════════════════════════════════════════════════════════
  //  GAME GRID  [FEATURE 8]
  // ════════════════════════════════════════════════════════════
  SliverGrid _buildGameGrid(Size size) {
    final cols = size.width < 600
        ? 2
        : size.width < 900
        ? 3
        : 4;
    final filtered = _searchQuery.isEmpty
        ? _gameCards
        : _gameCards
              .where(
                (g) => (g['title'] as String).toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => _buildGameCard(filtered[i], i),
        childCount: filtered.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.80,
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 60),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(
        scale: v,
        child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
      ),
      child: _GameCardWidget(
        game: game,
        onTap: () => _navigateToGame(context, game),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  STUDY MATERIALS  [FEATURE 9]
  // ════════════════════════════════════════════════════════════
  Widget _buildStudyMaterials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '📖 Study Materials',
          onTap: () => _navigateTo(context, const StudyMaterialsScreen()),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _studyMaterials.length,
            itemBuilder: (ctx, i) {
              final mat = _studyMaterials[i];
              return GestureDetector(
                onTap: () => _navigateTo(
                  context,
                  StudyMaterialDetailScreen(material: mat),
                ),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(mat['color']).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Color(mat['color']).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(mat['color']).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              mat['icon'],
                              color: Color(mat['color']),
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(mat['progress'] * 100).toInt()}%',
                            style: TextStyle(
                              color: Color(mat['color']),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mat['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${mat['lessons']} lessons • ${mat['duration']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: mat['progress'],
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(mat['color']),
                          ),
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

  // ════════════════════════════════════════════════════════════
  //  DEGREE PROGRAMS  [FEATURE 10]
  // ════════════════════════════════════════════════════════════
  Widget _buildDegreePrograms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '🎓 Featured Programs',
          onTap: () => _navigateTo(context, const AllProgramsScreen()),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _degreePrograms.length,
            itemBuilder: (ctx, i) {
              final prog = _degreePrograms[i];
              return GestureDetector(
                onTap: () => _navigateTo(
                  context,
                  DegreeDetailScreen(degree: prog['title'], program: prog),
                ),
                child: Container(
                  width: 290,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(prog['color']),
                        Color(prog['color']).withOpacity(0.65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(prog['color']).withOpacity(0.25),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              prog['icon'],
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prog['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  prog['subtitle'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 10,
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _programStat(
                            Icons.schedule_rounded,
                            prog['duration'],
                          ),
                          const SizedBox(width: 10),
                          _programStat(
                            Icons.credit_card_rounded,
                            '${prog['credits']} credits',
                          ),
                          const SizedBox(width: 10),
                          _programStat(
                            Icons.people_rounded,
                            '${prog['students']}+',
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.yellow,
                                size: 14,
                              ),
                              Text(
                                ' ${prog['rating']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _programStat(IconData icon, String val) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 12),
        const SizedBox(width: 3),
        Text(
          val,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  //  CONTINUE LEARNING  [FEATURE 11]
  // ════════════════════════════════════════════════════════════
  Widget _buildContinueLearning() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_AppColors.blue, _AppColors.green],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: _AppColors.blue.withOpacity(0.3), blurRadius: 16),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📖 Continue Learning',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      _navigateTo(context, const StudyMaterialsScreen()),
                  child: const Text(
                    'View All ›',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._recentPlays.map(
              (play) => GestureDetector(
                onTap: () => _navigateToGame(context, {
                  'title': play['title'],
                  'icon': play['icon'],
                  'color': play['color'],
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          play['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              play['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              play['date'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: play['percentage'] / 100,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.yellow,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          play['score'],
                          style: const TextStyle(
                            color: _AppColors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.play_circle_filled_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
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

  // ════════════════════════════════════════════════════════════
  //  ACHIEVEMENTS  [FEATURE 12]
  // ════════════════════════════════════════════════════════════
  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '🏅 Achievements',
          onTap: () => _navigateTo(context, const AchievementsScreen()),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _achievements.length,
            itemBuilder: (ctx, i) {
              final ach = _achievements[i];
              return GestureDetector(
                onTap: () => _navigateTo(context, const AchievementsScreen()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ach['earned']
                        ? Color(ach['color']).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ach['earned']
                          ? Color(ach['color']).withOpacity(0.5)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            ach['icon'],
                            style: TextStyle(
                              fontSize: 32,
                              color: ach['earned'] ? null : null,
                            ),
                          ),
                          if (!ach['earned'])
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: Colors.white54,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ach['title'],
                        style: TextStyle(
                          color: ach['earned'] ? Colors.white : Colors.white38,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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

  // ════════════════════════════════════════════════════════════
  //  LEADERBOARD  [FEATURE 13]
  // ════════════════════════════════════════════════════════════
  Widget _buildLeaderboardSection() {
    return GestureDetector(
      onTap: () => _navigateTo(context, const LeaderboardScreen()),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _AppColors.purple.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🏆 Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _AppColors.pink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'View All ›',
                    style: TextStyle(
                      color: _AppColors.pink,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._leaderboard.map((player) => _buildLeaderboardRow(player)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(Map<String, dynamic> player) {
    final isMe = player['name'] == 'You';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? _AppColors.purple.withOpacity(0.25) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: _AppColors.purple.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          Text(player['badge'], style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _AppColors.purple.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player['avatar'],
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${player['score']} pts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: player['change'].startsWith('+')
                  ? _AppColors.green.withOpacity(0.2)
                  : _AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              player['change'],
              style: TextStyle(
                color: player['change'].startsWith('+')
                    ? _AppColors.green
                    : _AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (player['rank'] <= 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#${player['rank']}',
                style: const TextStyle(
                  color: _AppColors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  TOURNAMENT BANNER  [FEATURE 14]
  // ════════════════════════════════════════════════════════════
  Widget _buildTournamentBanner() {
    return GestureDetector(
      onTap: () => _navigateTo(context, const TournamentScreen()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A0B2E), Color(0xFF6C2BD9)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _AppColors.yellow.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _AppColors.purple.withOpacity(0.4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _floatAnim.value * 0.5),
                child: const Text('🏆', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MEGA TOURNAMENT',
                    style: TextStyle(
                      color: _AppColors.yellow,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    'Prize Pool: ₹10,000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Starts in 2 hours • 248 registered',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _AppColors.yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Register Free →',
                      style: TextStyle(
                        color: _AppColors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
  //  QUICK ACTIONS  [FEATURE 15]
  // ════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.person_rounded,
        'label': 'Profile',
        'color': 0xFF6C2BD9,
        'screen': ProfileScreen(
          userPoints: _userPoints,
          userLevel: _userLevel,
          userXP: _userXP,
          maxXP: _maxXP,
        ),
      },
      {
        'icon': Icons.settings_rounded,
        'label': 'Settings',
        'color': 0xFF118AB2,
        'screen': const SettingsScreen(),
      },
      {
        'icon': Icons.share_rounded,
        'label': 'Share',
        'color': 0xFF06D6A0,
        'screen': const ShareScreen(),
      },
      {
        'icon': Icons.help_rounded,
        'label': 'Help',
        'color': 0xFFFF8C42,
        'screen': const HelpScreen(),
      },
      {
        'icon': Icons.card_giftcard_rounded,
        'label': 'Rewards',
        'color': 0xFFFF3B8C,
        'screen': const RewardsScreen(),
      },
      {
        'icon': Icons.history_rounded,
        'label': 'History',
        'color': 0xFFFFD166,
        'screen': const HistoryScreen(),
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('⚡ Quick Actions'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: actions.length,
          itemBuilder: (ctx, i) {
            final act = actions[i];
            return GestureDetector(
              onTap: () => _navigateTo(context, act['screen'] as Widget),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(act['color'] as int).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(act['color'] as int).withOpacity(0.35),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      act['icon'] as IconData,
                      color: Color(act['color'] as int),
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      act['label'] as String,
                      style: TextStyle(
                        color: Color(act['color'] as int),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
  }

  // ════════════════════════════════════════════════════════════
  //  EXAM PRACTICE CARD  [NEW FEATURE]
  // ════════════════════════════════════════════════════════════
  Widget _buildExamPracticeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9D4EDD), Color(0xFFFF8C42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D4EDD).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateTo(context, const QuizApp()),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📚 Exam Practice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Test your knowledge with subject-wise exams',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '3 Subjects Available',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── FAB  [FEATURE 16] ─────────────────────────────────────
  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Transform.scale(
        scale: _pulseAnim.value,
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToGame(context, _gameCards[0]),
          backgroundColor: _AppColors.purple,
          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          label: const Text(
            'Quick Play',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 12,
        ),
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _AppColors.purple.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'See All ›',
                  style: TextStyle(
                    color: _AppColors.purpleLight,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Navigation helpers ─────────────────────────────────────
  void _navigateTo(BuildContext context, Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: const Duration(milliseconds: 380),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, Map<String, dynamic> game) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameScreen(game: game),
        transitionDuration: const Duration(milliseconds: 420),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.88,
              end: 1.0,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
            child: child,
          ),
        ),
      ),
    );
  }

  // ── Notifications dialog  [FEATURE 17] ────────────────────
  void _showNotifications(BuildContext context) {
    setState(() => _unreadNotifications = 0);
    showModalBottomSheet(
      context: context,
      backgroundColor: _AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔔 Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ..._notifications.map(
              (n) => ListTile(
                leading: const CircleAvatar(
                  backgroundColor: _AppColors.purple,
                  child: Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                title: Text(
                  n['msg'],
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                subtitle: Text(
                  n['time'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
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

// ════════════════════════════════════════════════════════════
//  GAME CARD WIDGET (Stateful for hover/press)
// ════════════════════════════════════════════════════════════
class _GameCardWidget extends StatefulWidget {
  final Map<String, dynamic> game;
  final VoidCallback onTap;
  const _GameCardWidget({required this.game, required this.onTap});
  @override
  State<_GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<_GameCardWidget>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final color = Color(game['color']);
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        _ctrl.reverse();
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _ctrl.reverse();
        setState(() => _pressed = false);
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(_pressed ? 0.5 : 0.22),
                blurRadius: _pressed ? 18 : 8,
                spreadRadius: _pressed ? 2 : 0,
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(_pressed ? 0.5 : 0.12),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Shimmer overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.07),
                          Colors.white.withOpacity(0.0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(game['icon'], size: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      game['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      game['subtitle'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _tag(
                          game['difficulty'],
                          Colors.white.withOpacity(0.22),
                          Colors.white,
                        ),
                        const SizedBox(width: 5),
                        _tag(
                          '⭐ ${game['points']}',
                          Colors.yellow.withOpacity(0.28),
                          Colors.yellow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            size: 15,
                            color: _AppColors.purple,
                          ),
                          Text(
                            ' Play',
                            style: TextStyle(
                              color: _AppColors.purple,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  Widget _tag(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(color: fg, fontSize: 8, fontWeight: FontWeight.bold),
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  PARTICLE PAINTER
// ════════════════════════════════════════════════════════════
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity * 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ════════════════════════════════════════════════════════════
//  ──────────────────────────────────────────────────────────
//  ALL DESTINATION SCREENS
//  ──────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════

// ── Base scaffold helper ───────────────────────────────────
class _BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final Color color;
  const _BaseScreen({
    required this.title,
    required this.body,
    this.color = _AppColors.purple,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.darkBg,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          ),
        ),
      ),
      body: body,
    );
  }
}

// ════════════════════════════════════════════════════════════
//  GAME SCREEN  [Fully Functional Quiz]
// ════════════════════════════════════════════════════════════
class GameScreen extends StatefulWidget {
  final Map<String, dynamic> game;
  const GameScreen({super.key, required this.game});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int _currentQ = 0;
  int _score = 0;
  int _timeLeft = 30;
  int? _selectedAnswer;
  bool _answered = false;
  late Timer _timer;
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;
  late AnimationController _answerCtrl;
  late Animation<double> _answerAnim;

  final List<Map<String, dynamic>> _questions = [
    {
      'q': 'What is Flutter?',
      'options': ['Web Framework', 'UI SDK by Google', 'Database', 'Language'],
      'correct': 1,
      'explanation':
          'Flutter is Google\'s open-source UI SDK for building natively compiled apps.',
    },
    {
      'q': 'What is Dart?',
      'options': [
        'Programming Language',
        'Database Tool',
        'CSS Framework',
        'Server Tool',
      ],
      'correct': 0,
      'explanation':
          'Dart is an object-oriented programming language created by Google.',
    },
    {
      'q': 'Which widget enables scrolling?',
      'options': ['Container', 'Column', 'ListView', 'Row'],
      'correct': 2,
      'explanation':
          'ListView is Flutter\'s primary widget for creating scrollable lists.',
    },
    {
      'q': 'What does HTTP stand for?',
      'options': [
        'Hyper Text Markup Protocol',
        'Hyper Transfer Text Protocol',
        'HyperText Transfer Protocol',
        'High Tech Transfer Protocol',
      ],
      'correct': 2,
      'explanation':
          'HTTP = HyperText Transfer Protocol, the foundation of data on the Web.',
    },
    {
      'q': 'Which language is used for styling web pages?',
      'options': ['HTML', 'CSS', 'JavaScript', 'Python'],
      'correct': 1,
      'explanation':
          'CSS (Cascading Style Sheets) is used to style HTML elements on web pages.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _progressAnim = Tween<double>(begin: 1.0, end: 0.0).animate(_progressCtrl);
    _answerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _answerAnim = CurvedAnimation(
      parent: _answerCtrl,
      curve: Curves.elasticOut,
    );
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 30;
    _progressCtrl.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _nextQuestion();
    });
  }

  void _selectAnswer(int idx) {
    if (_answered) return;
    HapticFeedback.selectionClick();
    _timer.cancel();
    setState(() {
      _selectedAnswer = idx;
      _answered = true;
    });
    if (idx == _questions[_currentQ]['correct']) {
      _score += 10 + _timeLeft;
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    _answerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;
    _timer.cancel();
    _answerCtrl.reset();
    if (_currentQ < _questions.length - 1) {
      setState(() {
        _currentQ++;
        _selectedAnswer = null;
        _answered = false;
      });
      _startTimer();
    } else {
      setState(() {
        _currentQ = _questions.length;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _progressCtrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final color = game['color'] != null
        ? Color(game['color'])
        : _AppColors.purple;
    return Scaffold(
      backgroundColor: _AppColors.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_AppColors.darkBg, color.withOpacity(0.2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _currentQ < _questions.length
              ? _buildQuiz(color)
              : _buildResult(color),
        ),
      ),
    );
  }

  Widget _buildQuiz(Color color) {
    final q = _questions[_currentQ];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.game['title'] ?? 'Quiz',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '⭐ $_score',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Q ${_currentQ + 1}/${_questions.length}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: _timeLeft <= 10 ? Colors.red : Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_timeLeft s',
                          style: TextStyle(
                            color: _timeLeft <= 10
                                ? Colors.red
                                : Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progressAnim.value,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _timeLeft <= 10 ? Colors.red : color,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Text(
              q['q'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          // Options
          ...List.generate(4, (i) {
            final isCorrect = i == q['correct'];
            final isSelected = _selectedAnswer == i;
            Color bg = Colors.white.withOpacity(0.07);
            Color border = Colors.white.withOpacity(0.2);
            if (_answered) {
              if (isCorrect) {
                bg = _AppColors.green.withOpacity(0.25);
                border = _AppColors.green;
              } else if (isSelected) {
                bg = _AppColors.accent.withOpacity(0.25);
                border = _AppColors.accent;
              }
            }
            return GestureDetector(
              onTap: () => _selectAnswer(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + i),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        (q['options'] as List)[i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (_answered && isCorrect)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _AppColors.green,
                      ),
                    if (_answered && isSelected && !isCorrect)
                      const Icon(
                        Icons.cancel_rounded,
                        color: _AppColors.accent,
                      ),
                  ],
                ),
              ),
            );
          }),
          if (_answered) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _AppColors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _AppColors.blue.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_rounded,
                    color: _AppColors.blue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      q['explanation'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult(Color color) {
    final pct = (_score / (_questions.length * 40) * 100).clamp(0, 100).toInt();
    String emoji = pct >= 80
        ? '🏆'
        : pct >= 60
        ? '🎯'
        : pct >= 40
        ? '📚'
        : '💪';
    String msg = pct >= 80
        ? 'Outstanding!'
        : pct >= 60
        ? 'Well Done!'
        : pct >= 40
        ? 'Good Effort!'
        : 'Keep Practicing!';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $_score pts',
              style: const TextStyle(
                color: _AppColors.yellow,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Accuracy: $pct%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  _resultStat(
                    'Questions',
                    '${_questions.length}',
                    Icons.quiz_rounded,
                  ),
                  _resultStat(
                    'Correct',
                    '${(_score / (10 + 15)).round()}',
                    Icons.check_circle_rounded,
                  ),
                  _resultStat(
                    'Time Bonus',
                    '${_score - _questions.length * 10}',
                    Icons.timer_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _currentQ = 0;
                      _score = 0;
                      _selectedAnswer = null;
                      _answered = false;
                      _startTimer();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: color),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Back to Games',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget _resultStat(String label, String val, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: _AppColors.purple, size: 20),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7))),
        const Spacer(),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════
//  CATEGORY QUIZ SCREEN
// ════════════════════════════════════════════════════════════
class CategoryQuizScreen extends StatelessWidget {
  final String categoryName;
  const CategoryQuizScreen({super.key, required this.categoryName});
  @override
  Widget build(BuildContext context) {
    final cat = _categories.firstWhere(
      (c) => c['name'] == categoryName,
      orElse: () => _categories[0],
    );
    final color = Color(cat['color']);
    return _BaseScreen(
      title: categoryName,
      color: color,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat['icon'], color: color, size: 64),
              ),
              const SizedBox(height: 24),
              Text(
                categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Test your knowledge in $categoryName',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _difficultyBtn('Easy', _AppColors.green, context, categoryName),
              const SizedBox(height: 12),
              _difficultyBtn(
                'Medium',
                _AppColors.yellow,
                context,
                categoryName,
              ),
              const SizedBox(height: 12),
              _difficultyBtn('Hard', _AppColors.accent, context, categoryName),
            ],
          ),
        ),
      ),
    );
  }

  Widget _difficultyBtn(String diff, Color c, BuildContext ctx, String cat) =>
      GestureDetector(
        onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) =>
                GameScreen(game: {'title': '$cat - $diff', 'color': c.value}),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: c.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              '$diff Mode',
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════════
//  PROFILE SCREEN
// ════════════════════════════════════════════════════════════
class ProfileScreen extends StatelessWidget {
  final int userPoints, userLevel, userXP, maxXP;
  const ProfileScreen({
    super.key,
    required this.userPoints,
    required this.userLevel,
    required this.userXP,
    required this.maxXP,
  });
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: 'My Profile',
      color: _AppColors.purple,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_AppColors.purple, _AppColors.pink],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('👤', style: TextStyle(fontSize: 56)),
                    const Text(
                      'Alex Kumar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Level $userLevel: Knowledge Seeker',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _profileStat('$userPoints', 'Points', _AppColors.yellow),
                _profileStat('7', 'Streak', _AppColors.orange),
                _profileStat('48', 'Quizzes', _AppColors.green),
                _profileStat('#4', 'Global Rank', _AppColors.purple),
              ],
            ),
            const SizedBox(height: 20),
            _profileCard(
              'XP Progress',
              '${((userXP / maxXP) * 100).toInt()}% to next level',
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$userXP XP',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$maxXP XP',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: userXP / maxXP,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          _AppColors.yellow,
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _profileCard(
              'Recent Achievements',
              '',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _achievements
                    .where((a) => a['earned'] as bool)
                    .map(
                      (a) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(a['color']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(a['color']).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          '${a['icon']} ${a['title']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileStat(String val, String label, Color color) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9),
          ),
        ],
      ),
    ),
  );
  Widget _profileCard(String title, String sub, {required Widget child}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (sub.isNotEmpty)
              Text(
                sub,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            child,
          ],
        ),
      );
}

// ════════════════════════════════════════════════════════════
//  LEADERBOARD SCREEN
// ════════════════════════════════════════════════════════════
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: '🏆 Leaderboard',
      color: _AppColors.purple,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_AppColors.purple, _AppColors.pink],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('🥈', style: TextStyle(fontSize: 36)),
                    Text(
                      'Priya\n11800',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('🥇', style: TextStyle(fontSize: 48)),
                    Text(
                      'Alex\n12500',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('🥉', style: TextStyle(fontSize: 36)),
                    Text(
                      'Rahul\n10900',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ..._leaderboard.map(
            (p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p['name'] == 'You'
                    ? _AppColors.purple.withOpacity(0.25)
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: p['name'] == 'You'
                      ? _AppColors.purple.withOpacity(0.5)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                children: [
                  Text(p['badge'], style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${p['score']} pts',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '#${p['rank']}',
                    style: const TextStyle(
                      color: _AppColors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
}

// ════════════════════════════════════════════════════════════
//  ACHIEVEMENTS SCREEN
// ════════════════════════════════════════════════════════════
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: '🏅 Achievements',
      color: _AppColors.orange,
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
        ),
        itemCount: _achievements.length,
        itemBuilder: (ctx, i) {
          final a = _achievements[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: a['earned']
                  ? Color(a['color']).withOpacity(0.18)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: a['earned']
                    ? Color(a['color']).withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(a['icon'], style: const TextStyle(fontSize: 44)),
                    if (!a['earned'])
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Colors.white38,
                          size: 24,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  a['title'],
                  style: TextStyle(
                    color: a['earned'] ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  a['desc'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(a['earned'] ? 0.55 : 0.25),
                    fontSize: 10,
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
//  DAILY CHALLENGES SCREEN
// ════════════════════════════════════════════════════════════
class DailyChallengesScreen extends StatelessWidget {
  const DailyChallengesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: '⚡ Daily Challenges',
      color: _AppColors.orange,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_AppColors.orange, _AppColors.yellow],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Text('⚡', style: TextStyle(fontSize: 36)),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Reset in',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '06:42:18',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ..._dailyChallenges.map(
            (ch) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    game: {'title': ch['title'], 'color': ch['color']},
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Color(ch['color']).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Color(ch['color']).withOpacity(0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ch['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(ch['color']).withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '+${ch['reward']} pts',
                            style: TextStyle(
                              color: Color(ch['color']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ch['desc'],
                      style: TextStyle(color: Colors.white.withOpacity(0.65)),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ch['progress'] / ch['total'],
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(ch['color']),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ch['progress']}/${ch['total']} completed',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
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
//  TOURNAMENT SCREEN
// ════════════════════════════════════════════════════════════
class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: '🏆 Tournament',
      color: _AppColors.yellow.withOpacity(0.8) as Color,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A0B2E), _AppColors.purple],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _AppColors.yellow.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 64)),
                  const Text(
                    'MEGA TOURNAMENT',
                    style: TextStyle(
                      color: _AppColors.yellow,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Prize Pool: ₹10,000',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '248 Players Registered',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _AppColors.yellow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Register Now — FREE',
                        style: TextStyle(
                          color: _AppColors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tournament Rules',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...[
              '📋 Answer 20 questions in 10 minutes',
              '⚡ Bonus points for fast answers',
              '🏅 Top 3 win cash prizes',
              '🔒 No re-entries after start',
              '📱 Play from any device',
            ].map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(r, style: const TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  STUDY MATERIALS SCREEN
// ════════════════════════════════════════════════════════════
class StudyMaterialsScreen extends StatelessWidget {
  const StudyMaterialsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: '📖 Study Materials',
      color: _AppColors.blue,
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _studyMaterials.length,
        itemBuilder: (ctx, i) {
          final mat = _studyMaterials[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => StudyMaterialDetailScreen(material: mat),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(mat['color']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Color(mat['color']).withOpacity(0.35),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(mat['color']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      mat['icon'],
                      color: Color(mat['color']),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mat['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${mat['lessons']} lessons • ${mat['duration']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: mat['progress'],
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(mat['color']),
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${(mat['progress'] * 100).toInt()}% complete',
                          style: TextStyle(
                            color: Color(mat['color']),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white38,
                    size: 16,
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
//  STUDY MATERIAL DETAIL SCREEN
// ════════════════════════════════════════════════════════════
class StudyMaterialDetailScreen extends StatelessWidget {
  final Map<String, dynamic> material;
  const StudyMaterialDetailScreen({super.key, required this.material});
  @override
  Widget build(BuildContext context) {
    final color = Color(material['color']);
    return _BaseScreen(
      title: material['title'],
      color: color,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(material['icon'], color: Colors.white, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${material['lessons']} lessons • ${material['duration']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: material['progress'],
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        Text(
                          '${(material['progress'] * 100).toInt()}% complete',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lessons',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              material['lessons'],
              (i) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            i <
                                (material['lessons'] * material['progress'])
                                    .toInt()
                            ? color.withOpacity(0.3)
                            : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        i < (material['lessons'] * material['progress']).toInt()
                            ? Icons.check_rounded
                            : Icons.play_arrow_rounded,
                        color:
                            i <
                                (material['lessons'] * material['progress'])
                                    .toInt()
                            ? color
                            : Colors.white38,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Lesson ${i + 1}: Topic ${i + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      '5 min',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
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
//  DEGREE DETAIL SCREEN
// ════════════════════════════════════════════════════════════
class DegreeDetailScreen extends StatelessWidget {
  final String degree;
  final Map<String, dynamic> program;
  const DegreeDetailScreen({
    super.key,
    required this.degree,
    required this.program,
  });
  @override
  Widget build(BuildContext context) {
    final color = Color(program['color']);
    return _BaseScreen(
      title: degree,
      color: color,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.6)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Icon(program['icon'], color: Colors.white, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    degree,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    program['subtitle'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _progStat('⏱️', program['duration'], 'Duration'),
                      _progStat('📚', '${program['credits']}', 'Credits'),
                      _progStat('👥', '${program['students']}+', 'Students'),
                      _progStat('⭐', '${program['rating']}', 'Rating'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Program Highlights',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              'Industry-relevant curriculum',
              'Hands-on project experience',
              'Expert faculty mentorship',
              'Career placement support',
              'State-of-the-art labs',
              'Scholarship opportunities',
            ].map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: color, size: 20),
                    const SizedBox(width: 10),
                    Text(h, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Apply Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progStat(String emoji, String val, String label) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      Text(
        val,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════
//  ALL GAMES SCREEN
// ════════════════════════════════════════════════════════════
class AllGamesScreen extends StatelessWidget {
  const AllGamesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: '🎮 All Games',
      color: _AppColors.purple,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: _gameCards.length,
        itemBuilder: (ctx, i) => _GameCardWidget(
          game: _gameCards[i],
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => GameScreen(game: _gameCards[i])),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ALL CATEGORIES SCREEN
// ════════════════════════════════════════════════════════════
class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: '📚 All Categories',
      color: _AppColors.pink,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => CategoryQuizScreen(categoryName: cat['name']),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Color(cat['color']).withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Color(cat['color']).withOpacity(0.4)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'], color: Color(cat['color']), size: 40),
                  const SizedBox(height: 8),
                  Text(
                    cat['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
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
//  ALL PROGRAMS SCREEN
// ════════════════════════════════════════════════════════════
class AllProgramsScreen extends StatelessWidget {
  const AllProgramsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: '🎓 All Programs',
      color: _AppColors.green,
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _degreePrograms.length,
        itemBuilder: (ctx, i) {
          final p = _degreePrograms[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) =>
                    DegreeDetailScreen(degree: p['title'], program: p),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(p['color']).withOpacity(0.3),
                    Color(p['color']).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Color(p['color']).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(p['color']).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(p['icon'], color: Color(p['color']), size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          p['subtitle'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${p['duration']} • ${p['credits']} credits',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '⭐ ${p['rating']}',
                              style: const TextStyle(
                                color: _AppColors.yellow,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white38,
                    size: 14,
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
//  SETTINGS SCREEN  [FEATURE 18]
// ════════════════════════════════════════════════════════════
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sound = true,
      notifications = true,
      darkMode = true,
      autoPlay = false,
      haptics = true;
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: '⚙️ Settings',
      color: _AppColors.blue,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _settingsSection('🔔 Preferences', [
            _settingsTile(
              'Sound Effects',
              sound,
              (v) => setState(() => sound = v),
              Icons.volume_up_rounded,
            ),
            _settingsTile(
              'Notifications',
              notifications,
              (v) => setState(() => notifications = v),
              Icons.notifications_rounded,
            ),
            _settingsTile(
              'Dark Mode',
              darkMode,
              (v) => setState(() => darkMode = v),
              Icons.dark_mode_rounded,
            ),
            _settingsTile(
              'Auto-Play Next',
              autoPlay,
              (v) => setState(() => autoPlay = v),
              Icons.play_circle_rounded,
            ),
            _settingsTile(
              'Haptic Feedback',
              haptics,
              (v) => setState(() => haptics = v),
              Icons.vibration_rounded,
            ),
          ]),
          const SizedBox(height: 14),
          _settingsSection('👤 Account', [
            _settingsAction('Edit Profile', Icons.edit_rounded, () {}),
            _settingsAction('Change Password', Icons.lock_rounded, () {}),
            _settingsAction(
              'Privacy Settings',
              Icons.privacy_tip_rounded,
              () {},
            ),
          ]),
          const SizedBox(height: 14),
          _settingsSection('ℹ️ About', [
            _settingsAction('Version 2.0.0', Icons.info_rounded, () {}),
            _settingsAction('Rate the App', Icons.star_rounded, () {}),
            _settingsAction('Report an Issue', Icons.bug_report_rounded, () {}),
          ]),
        ],
      ),
    );
  }

  Widget _settingsSection(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(children: children),
      ),
    ],
  );
  Widget _settingsTile(
    String label,
    bool val,
    Function(bool) onChange,
    IconData icon,
  ) => ListTile(
    leading: Icon(icon, color: _AppColors.purple),
    title: Text(label, style: const TextStyle(color: Colors.white)),
    trailing: Switch(
      value: val,
      onChanged: onChange,
      activeColor: _AppColors.purple,
    ),
  );
  Widget _settingsAction(String label, IconData icon, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: _AppColors.purple),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.white38,
        ),
        onTap: onTap,
      );
}

// ════════════════════════════════════════════════════════════
//  REWARDS SCREEN  [FEATURE 19]
// ════════════════════════════════════════════════════════════
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final rewards = [
      {'title': '₹50 Recharge', 'pts': 500, 'icon': '📱', 'color': 0xFF6C2BD9},
      {
        'title': '₹100 Cashback',
        'pts': 1000,
        'icon': '💰',
        'color': 0xFF06D6A0,
      },
      {
        'title': 'Amazon Gift Card',
        'pts': 2000,
        'icon': '🎁',
        'color': 0xFFFF8C42,
      },
      {
        'title': 'Course Discount 20%',
        'pts': 750,
        'icon': '🎓',
        'color': 0xFFFF3B8C,
      },
      {
        'title': 'Premium Membership',
        'pts': 5000,
        'icon': '👑',
        'color': 0xFFFFD166,
      },
      {
        'title': 'Stationery Kit',
        'pts': 300,
        'icon': '✏️',
        'color': 0xFF118AB2,
      },
    ];
    return _BaseScreen(
      title: '🎁 Rewards Store',
      color: _AppColors.pink,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_AppColors.purple, _AppColors.pink],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Balance',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.yellow,
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '2,450 pts',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: rewards.length,
              itemBuilder: (ctx, i) {
                final r = rewards[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(r['color'] as int).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Color(r['color'] as int).withOpacity(0.35),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        r['icon'] as String,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        r['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(r['color'] as int).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${r['pts']} pts',
                          style: TextStyle(
                            color: Color(r['color'] as int),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
//  HISTORY SCREEN  [FEATURE 20]
// ════════════════════════════════════════════════════════════
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final history = [
      {
        'title': 'Quiz Challenge',
        'score': '850/1000',
        'date': 'Apr 18, 2:00 PM',
        'color': 0xFF6C2BD9,
        'icon': Icons.quiz_rounded,
        'result': 'Win',
      },
      {
        'title': 'Daily Quiz',
        'score': '45/50',
        'date': 'Apr 17, 10:30 AM',
        'color': 0xFFFF3B8C,
        'icon': Icons.today_rounded,
        'result': 'Win',
      },
      {
        'title': 'Rapid Fire',
        'score': '1200/1500',
        'date': 'Apr 16, 6:15 PM',
        'color': 0xFFFF8C42,
        'icon': Icons.timer_rounded,
        'result': 'Win',
      },
      {
        'title': 'Coding Quiz',
        'score': '80/250',
        'date': 'Apr 15, 4:00 PM',
        'color': 0xFF6C2BD9,
        'icon': Icons.code_rounded,
        'result': 'Loss',
      },
      {
        'title': 'Math Quiz',
        'score': '70/90',
        'date': 'Apr 14, 11:00 AM',
        'color': 0xFFFF8C42,
        'icon': Icons.calculate_rounded,
        'result': 'Win',
      },
    ];
    return _BaseScreen(
      title: '📋 Play History',
      color: _AppColors.indigo,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...history.map(
            (h) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(h['color'] as int).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      h['icon'] as IconData,
                      color: Color(h['color'] as int),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          h['date'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: h['result'] == 'Win'
                              ? _AppColors.green.withOpacity(0.2)
                              : _AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          h['result'] as String,
                          style: TextStyle(
                            color: h['result'] == 'Win'
                                ? _AppColors.green
                                : _AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        h['score'] as String,
                        style: const TextStyle(
                          color: _AppColors.yellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

// ════════════════════════════════════════════════════════════
//  SHARE SCREEN
// ════════════════════════════════════════════════════════════
class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseScreen(
      title: '📤 Share',
      color: _AppColors.green,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🚀', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 20),
              const Text(
                'Share KYP Quiz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Invite friends and earn 100 bonus points!',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'https://kyp.beedi.edu/share/alex123',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                    Icon(Icons.copy_rounded, color: _AppColors.green),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _shareBtn('WhatsApp', '💬', const Color(0xFF25D366)),
                  _shareBtn('Facebook', '📘', const Color(0xFF1877F2)),
                  _shareBtn('Telegram', '✈️', const Color(0xFF0088CC)),
                  _shareBtn('Copy Link', '🔗', _AppColors.purple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shareBtn(String label, String emoji, Color color) => Column(
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
      ),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ],
  );
}

// ════════════════════════════════════════════════════════════
//  HELP SCREEN
// ════════════════════════════════════════════════════════════
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I earn points?',
        'a':
            'Answer quiz questions correctly and quickly to earn more points. Bonus points are awarded for speed!',
      },
      {
        'q': 'What are daily challenges?',
        'a':
            'Daily challenges reset every 24 hours and offer bonus rewards for completion.',
      },
      {
        'q': 'How does the leaderboard work?',
        'a':
            'The leaderboard ranks players by total points. Rankings update in real-time.',
      },
      {
        'q': 'Can I play offline?',
        'a':
            'Some features require internet. Basic quizzes can be played offline with cached content.',
      },
      {
        'q': 'How do I redeem rewards?',
        'a':
            'Go to the Rewards Store, select your reward, and confirm redemption with your point balance.',
      },
    ];
    return _BaseScreen(
      title: '❓ Help & FAQ',
      color: _AppColors.teal,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_AppColors.blue, _AppColors.teal],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need More Help?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Chat with support 24/7',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...faqs.map(
            (f) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: ExpansionTile(
                title: Text(
                  f['q']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                iconColor: _AppColors.teal,
                collapsedIconColor: Colors.white38,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      f['a']!,
                      style: TextStyle(color: Colors.white.withOpacity(0.65)),
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
}

// ════════════════════════════════════════════════════════════
//  EXAM PRACTICE SCREEN  [NEW FEATURE]
// ════════════════════════════════════════════════════════════
