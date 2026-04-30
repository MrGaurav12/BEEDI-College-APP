import 'package:beedi_college/Screens/BSCITScreen.dart';
import 'package:beedi_college/Screens/BSCLSScreen.dart';
import 'package:beedi_college/Screens/BSCSSScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────
//  THEME CONSTANTS  (Blue · Green · Yellow)
// ─────────────────────────────────────────────
class AppColors {
  static const blue = Color(0xFF1565C0);
  static const blueLight = Color(0xFF42A5F5);
  static const blueDark = Color(0xFF0D47A1);
  static const green = Color(0xFF2E7D32);
  static const greenLight = Color(0xFF66BB6A);
  static const teal = Color(0xFF00695C);
  static const yellow = Color(0xFFF9A825);
  static const yellowLight = Color(0xFFFFEE58);
  static const yellowDark = Color(0xFFF57F17);
  static const bgLight = Color(0xFFF0F7FF);
  static const cardBg = Colors.white;
}

// ─────────────────────────────────────────────
//  SUBJECT MODEL  (unchanged + new fields)
// ─────────────────────────────────────────────
class Subject {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final int totalQuestions;       // NEW
  final int durationMinutes;      // NEW
  final String difficultyLabel;   // NEW
  final double rating;            // NEW
  final int attemptedByCount;     // NEW
  final List<Color> gradientColors; // NEW

  const Subject({
    required this.name,
    required this.icon,
    required this.color,
    this.description = '',
    this.totalQuestions = 30,
    this.durationMinutes = 45,
    this.difficultyLabel = 'Medium',
    this.rating = 4.5,
    this.attemptedByCount = 0,
    this.gradientColors = const [],
  });
}

// ─────────────────────────────────────────────
//  SUBJECTS DATA  (extended)
// ─────────────────────────────────────────────
const List<Subject> subjects = [
  Subject(
    name: 'BS-CIT',
    icon: Icons.computer_rounded,
    color: AppColors.blue,
    description: 'Computer Information Technology',
    totalQuestions: 40,
    durationMinutes: 60,
    difficultyLabel: 'Intermediate',
    rating: 4.7,
    attemptedByCount: 1240,
    gradientColors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
  ),
  Subject(
    name: 'BS-CLS',
    icon: Icons.biotech_rounded,
    color: AppColors.green,
    description: 'Computer Life Sciences',
    totalQuestions: 35,
    durationMinutes: 50,
    difficultyLabel: 'Easy',
    rating: 4.4,
    attemptedByCount: 870,
    gradientColors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
  ),
  Subject(
    name: 'BS-CSS',
    icon: Icons.security_rounded,
    color: AppColors.teal,
    description: 'Computer Security Systems',
    totalQuestions: 45,
    durationMinutes: 70,
    difficultyLabel: 'Advanced',
    rating: 4.9,
    attemptedByCount: 560,
    gradientColors: [Color(0xFF00695C), Color(0xFF26A69A)],
  ),
];

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class SubjectChooseScreen extends StatefulWidget {
  const SubjectChooseScreen({super.key});

  @override
  State<SubjectChooseScreen> createState() => _SubjectChooseScreenState();
}

class _SubjectChooseScreenState extends State<SubjectChooseScreen>
    with TickerProviderStateMixin {

  // ── FEATURE 1: Search / Filter ──
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── FEATURE 2: View Mode (Grid / List) ──
  bool _isGridView = true;

  // ── FEATURE 3: Sort ──
  String _sortBy = 'Name';
  final List<String> _sortOptions = ['Name', 'Rating', 'Questions', 'Duration'];

  // ── FEATURE 4: Favourites ──
  final Set<String> _favourites = {};

  // ── FEATURE 5: Dark Mode Toggle ──
  bool _isDarkMode = false;

  // ── FEATURE 6: Pulse animation controller ──
  late AnimationController _pulseController;

  // ── FEATURE 7: Floating badge animation ──
  late AnimationController _badgeController;
  late Animation<double> _badgeAnimation;

  // ── FEATURE 8: Stats banner expand ──
  bool _statsExpanded = false;

  // ── FEATURE 9: Recently viewed ──
  final List<String> _recentlyViewed = [];

  // ── FEATURE 10: Selected subject highlight ──
  String? _hoveredSubject;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _badgeAnimation = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.elasticOut,
    );
    _badgeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  List<Subject> get _filteredSortedSubjects {
    List<Subject> result = subjects
        .where((s) =>
            s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    switch (_sortBy) {
      case 'Rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Questions':
        result.sort((a, b) => b.totalQuestions.compareTo(a.totalQuestions));
        break;
      case 'Duration':
        result.sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
        break;
      default:
        result.sort((a, b) => a.name.compareTo(b.name));
    }
    return result;
  }

  void _navigateToSubject(BuildContext context, Subject subject) {
    // ── FEATURE 9: Track recently viewed ──
    setState(() {
      _recentlyViewed.remove(subject.name);
      _recentlyViewed.insert(0, subject.name);
    });

    // ── FEATURE 11: Haptic feedback ──
    HapticFeedback.mediumImpact();

    Widget screen;
    switch (subject.name) {
      case 'BS-CIT':
        screen = const BSCITScreen();
        break;
      case 'BS-CLS':
        screen = const BSCLSScreen();
        break;
      case 'BS-CSS':
        screen = const BSCSSScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.3);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeIn),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ── FEATURE 12: Quick Info Bottom Sheet ──
  void _showQuickInfo(Subject subject) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QuickInfoSheet(
        subject: subject,
        isFavourite: _favourites.contains(subject.name),
        onToggleFavourite: () {
          setState(() {
            if (_favourites.contains(subject.name)) {
              _favourites.remove(subject.name);
            } else {
              _favourites.add(subject.name);
            }
          });
          Navigator.pop(context);
        },
        onStartTest: () {
          Navigator.pop(context);
          _navigateToSubject(context, subject);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSortedSubjects;
    final isDark = _isDarkMode;
    final bgColor = isDark ? const Color(0xFF0D1B2A) : AppColors.bgLight;
    final cardColor = isDark ? const Color(0xFF1A2F4A) : AppColors.cardBg;
    final textColor = isDark ? Colors.white : const Color(0xFF0D2137);

    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: bgColor,
        // ── FEATURE 13: Custom AppBar with animated gradient ──
        appBar: _buildAppBar(isDark, textColor),
        // ── FEATURE 14: Floating Action Button for scroll-to-top ──
        floatingActionButton: _buildFAB(),
        body: Column(
          children: [
            // ── FEATURE 15: Stats Banner ──
            _StatsBanner(
              expanded: _statsExpanded,
              onToggle: () => setState(() => _statsExpanded = !_statsExpanded),
              isDark: isDark,
            ),
            // ── FEATURE 16: Search + Sort + View toggle toolbar ──
            _buildToolbar(isDark, textColor),
            // ── FEATURE 17: Recently Viewed chips ──
            if (_recentlyViewed.isNotEmpty)
              _RecentlyViewedBar(
                recent: _recentlyViewed,
                subjects: subjects,
                onTap: (s) => _navigateToSubject(context, s),
                isDark: isDark,
              ),
            // Cards
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(query: _searchQuery)
                  : _isGridView
                      ? _buildGrid(filtered, cardColor, textColor)
                      : _buildList(filtered, cardColor, textColor),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ───
  PreferredSizeWidget _buildAppBar(bool isDark, Color textColor) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.blueDark, AppColors.blue, AppColors.blueLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // ── FEATURE 18: Animated logo pulse ──
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Transform.scale(
                    scale: 0.92 + 0.08 * _pulseController.value,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white38, width: 1.5),
                      ),
                      child: const Icon(Icons.school_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Subject',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: 0.3)),
                      Text('Beedi College · Online Test',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                // ── FEATURE 5: Dark mode toggle ──
                IconButton(
                  tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
                  onPressed: () =>
                      setState(() => _isDarkMode = !_isDarkMode),
                  icon: Icon(
                    _isDarkMode
                        ? Icons.wb_sunny_rounded
                        : Icons.nightlight_round,
                    color: AppColors.yellowLight,
                    size: 24,
                  ),
                ),
                // ── FEATURE 19: Notification bell ──
                Stack(
                  children: [
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () => _showNotifications(),
                      icon: const Icon(Icons.notifications_rounded,
                          color: Colors.white, size: 24),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: ScaleTransition(
                        scale: _badgeAnimation,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Toolbar: Search + Sort + View Mode ───
  Widget _buildToolbar(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: _SearchField(
              controller: _searchController,
              isDark: isDark,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(width: 8),
          // Sort dropdown
          _SortButton(
            sortBy: _sortBy,
            options: _sortOptions,
            isDark: isDark,
            onChanged: (v) => setState(() => _sortBy = v!),
          ),
          const SizedBox(width: 6),
          // View mode toggle
          _ViewToggle(
            isGrid: _isGridView,
            onToggle: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
    );
  }

  // ─── Grid View ───
  Widget _buildGrid(
      List<Subject> list, Color cardColor, Color textColor) {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = 1;
      if (constraints.maxWidth >= 1100) {
        crossAxisCount = 3;
      } else if (constraints.maxWidth >= 700) {
        crossAxisCount = 2;
      }
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 80),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: crossAxisCount == 1 ? 1.18 : 0.95,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final subject = list[index];
          return FadeSlideTransition(
            delay: Duration(milliseconds: 80 * index),
            child: SubjectCard(
              subject: subject,
              isFavourite: _favourites.contains(subject.name),
              isRecent: _recentlyViewed.isNotEmpty &&
                  _recentlyViewed.first == subject.name,
              onTap: () => _navigateToSubject(context, subject),
              onLongPress: () => _showQuickInfo(subject),
              onFavouriteTap: () => setState(() {
                _favourites.contains(subject.name)
                    ? _favourites.remove(subject.name)
                    : _favourites.add(subject.name);
              }),
            ),
          );
        },
      );
    });
  }

  // ─── List View ───
  Widget _buildList(
      List<Subject> list, Color cardColor, Color textColor) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final subject = list[index];
        return FadeSlideTransition(
          delay: Duration(milliseconds: 80 * index),
          child: _SubjectListTile(
            subject: subject,
            isFavourite: _favourites.contains(subject.name),
            onTap: () => _navigateToSubject(context, subject),
            onLongPress: () => _showQuickInfo(subject),
            onFavouriteTap: () => setState(() {
              _favourites.contains(subject.name)
                  ? _favourites.remove(subject.name)
                  : _favourites.add(subject.name);
            }),
          ),
        );
      },
    );
  }

  // ── FEATURE 14: FAB ──
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickStats(),
      backgroundColor: AppColors.yellow,
      foregroundColor: AppColors.blueDark,
      icon: const Icon(Icons.bar_chart_rounded),
      label: const Text('Stats',
          style: TextStyle(fontWeight: FontWeight.bold)),
      elevation: 6,
    );
  }

  // ── FEATURE 20: Quick Stats Dialog ──
  void _showQuickStats() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (_) => _QuickStatsDialog(subjects: subjects),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.notifications_active_rounded, color: AppColors.yellow),
          SizedBox(width: 8),
          Text('Notifications'),
        ]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NotifTile(
                icon: Icons.new_releases_rounded,
                color: AppColors.blue,
                text: 'New BS-CSS questions added!'),
            _NotifTile(
                icon: Icons.emoji_events_rounded,
                color: AppColors.yellow,
                text: 'You scored top 10% last week!'),
            _NotifTile(
                icon: Icons.update_rounded,
                color: AppColors.green,
                text: 'BS-CIT syllabus updated'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'))
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SUBJECT CARD  (Grid)
// ─────────────────────────────────────────────
class SubjectCard extends StatefulWidget {
  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavouriteTap;
  final bool isFavourite;
  final bool isRecent;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
    required this.onLongPress,
    required this.onFavouriteTap,
    this.isFavourite = false,
    this.isRecent = false,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.subject;
    final gradColors = s.gradientColors.isNotEmpty
        ? s.gradientColors
        : [s.color, s.color.withOpacity(0.6)];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: s.color.withOpacity(_isHovered ? 0.45 : 0.22),
                  blurRadius: _isHovered ? 20 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Card background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, s.color.withOpacity(0.06)],
                      ),
                    ),
                  ),
                  // Decorative circle BG
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.color.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.yellow.withOpacity(0.08),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: icon + favourite
                        Row(
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: gradColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: s.color.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Icon(s.icon, size: 32, color: Colors.white),
                            ),
                            const Spacer(),
                            // ── FEATURE 4: Favourite button ──
                            GestureDetector(
                              onTap: widget.onFavouriteTap,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  widget.isFavourite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(widget.isFavourite),
                                  color: widget.isFavourite
                                      ? Colors.redAccent
                                      : Colors.grey[400],
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Name
                        Text(
                          s.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: s.color,
                            letterSpacing: 0.5,
                          ),
                        ),
                        // Description
                        if (s.description.isNotEmpty)
                          Text(
                            s.description,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 10),
                        // ── FEATURE: Info chips row ──
                        _InfoChipsRow(subject: s),
                        const SizedBox(height: 10),
                        // ── FEATURE: Rating bar ──
                        _RatingRow(rating: s.rating, color: s.color),
                        const Spacer(),
                        // Start Test button
                        Row(
                          children: [
                            // ── FEATURE: Difficulty badge ──
                            _DifficultyBadge(label: s.difficultyLabel),
                            const Spacer(),
                            // ── FEATURE: Attempted count ──
                            if (s.attemptedByCount > 0)
                              Text(
                                '${_formatCount(s.attemptedByCount)} attempts',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey[500]),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // CTA button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.onTap,
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: const Text('Start Test',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: s.color,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                          ),
                        ),
                        // ── FEATURE: Recent tag ──
                        if (widget.isRecent)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Icon(Icons.history_rounded,
                                    size: 12, color: AppColors.yellow),
                                const SizedBox(width: 4),
                                Text('Recently Viewed',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.yellowDark,
                                        fontWeight: FontWeight.w600)),
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
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LIST TILE VIEW
// ─────────────────────────────────────────────
class _SubjectListTile extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavouriteTap;
  final bool isFavourite;

  const _SubjectListTile({
    required this.subject,
    required this.onTap,
    required this.onLongPress,
    required this.onFavouriteTap,
    this.isFavourite = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = subject;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: s.color.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: s.gradientColors.isNotEmpty
                          ? s.gradientColors
                          : [s.color, s.color.withOpacity(0.6)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: s.color)),
                    Text(s.description,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(height: 6),
                    Row(children: [
                      _MiniChip(
                          icon: Icons.quiz_rounded,
                          label: '${s.totalQuestions}Q',
                          color: s.color),
                      const SizedBox(width: 6),
                      _MiniChip(
                          icon: Icons.timer_rounded,
                          label: '${s.durationMinutes}m',
                          color: AppColors.green),
                      const SizedBox(width: 6),
                      _DifficultyBadge(label: s.difficultyLabel, compact: true),
                    ]),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: onFavouriteTap,
                    child: Icon(
                      isFavourite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color:
                          isFavourite ? Colors.redAccent : Colors.grey[300],
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: s.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Go',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
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

// ─────────────────────────────────────────────
//  HELPER WIDGETS
// ─────────────────────────────────────────────

class _InfoChipsRow extends StatelessWidget {
  final Subject subject;
  const _InfoChipsRow({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _MiniChip(
            icon: Icons.quiz_rounded,
            label: '${subject.totalQuestions} Qs',
            color: subject.color),
        _MiniChip(
            icon: Icons.timer_rounded,
            label: '${subject.durationMinutes}m',
            color: AppColors.green),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;
  final Color color;

  const _RatingRow({required this.rating, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return Icon(Icons.star_rounded, size: 14, color: AppColors.yellow);
          } else if (i < rating) {
            return Icon(Icons.star_half_rounded,
                size: 14, color: AppColors.yellow);
          }
          return Icon(Icons.star_outline_rounded,
              size: 14, color: Colors.grey[300]);
        }),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700])),
      ],
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String label;
  final bool compact;

  const _DifficultyBadge({required this.label, this.compact = false});

  Color get _color {
    switch (label) {
      case 'Easy':
        return AppColors.green;
      case 'Intermediate':
      case 'Medium':
        return AppColors.yellow;
      case 'Advanced':
      case 'Hard':
        return Colors.redAccent;
      default:
        return AppColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8, vertical: compact ? 2 : 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: compact ? 9 : 10,
              color: _color,
              fontWeight: FontWeight.w700)),
    );
  }
}

// ─────────────────────────────────────────────
//  SEARCH FIELD
// ─────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _SearchField(
      {required this.controller,
      required this.onChanged,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: AppColors.blue.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : AppColors.blueDark),
        decoration: InputDecoration(
          hintText: 'Search subjects…',
          hintStyle:
              TextStyle(fontSize: 13, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.blue, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: Colors.grey, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SORT BUTTON
// ─────────────────────────────────────────────
class _SortButton extends StatelessWidget {
  final String sortBy;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool isDark;

  const _SortButton(
      {required this.sortBy,
      required this.options,
      required this.onChanged,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: AppColors.blue.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: sortBy,
          items: options
              .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o,
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white : AppColors.blueDark))))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.sort_rounded,
              color: AppColors.blue, size: 18),
          style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : AppColors.blueDark),
          dropdownColor: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  VIEW MODE TOGGLE
// ─────────────────────────────────────────────
class _ViewToggle extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onToggle;

  const _ViewToggle({required this.isGrid, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: AppColors.blue.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Icon(
          isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STATS BANNER
// ─────────────────────────────────────────────
class _StatsBanner extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final bool isDark;

  const _StatsBanner(
      {required this.expanded,
      required this.onToggle,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final totalQs = subjects.fold<int>(0, (s, e) => s + e.totalQuestions);
    final totalAttempts =
        subjects.fold<int>(0, (s, e) => s + e.attemptedByCount);
    final avgRating =
        subjects.fold<double>(0, (s, e) => s + e.rating) / subjects.length;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          padding: EdgeInsets.all(expanded ? 16 : 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blueDark, AppColors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: AppColors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_rounded,
                      color: AppColors.yellowLight, size: 18),
                  const SizedBox(width: 8),
                  const Text('Platform Statistics',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const Spacer(),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatItem(
                        value: '${subjects.length}',
                        label: 'Subjects',
                        icon: Icons.book_rounded,
                        color: AppColors.yellowLight),
                    _StatItem(
                        value: '$totalQs',
                        label: 'Total Qs',
                        icon: Icons.quiz_rounded,
                        color: AppColors.greenLight),
                    _StatItem(
                        value: _formatCount(totalAttempts),
                        label: 'Attempts',
                        icon: Icons.people_rounded,
                        color: Colors.orangeAccent),
                    _StatItem(
                        value: avgRating.toStringAsFixed(1),
                        label: 'Avg Rating',
                        icon: Icons.star_rounded,
                        color: AppColors.yellowLight),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RECENTLY VIEWED BAR
// ─────────────────────────────────────────────
class _RecentlyViewedBar extends StatelessWidget {
  final List<String> recent;
  final List<Subject> subjects;
  final void Function(Subject) onTap;
  final bool isDark;

  const _RecentlyViewedBar(
      {required this.recent,
      required this.subjects,
      required this.onTap,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Row(
        children: [
          Icon(Icons.history_rounded,
              size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Text('Recent:',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: math.min(recent.length, 3),
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final name = recent[i];
                final sub = subjects.firstWhere((s) => s.name == name,
                    orElse: () => subjects.first);
                return GestureDetector(
                  onTap: () => onTap(sub),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: sub.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sub.color.withOpacity(0.3)),
                    ),
                    child: Text(name,
                        style: TextStyle(
                            fontSize: 11,
                            color: sub.color,
                            fontWeight: FontWeight.bold)),
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

// ─────────────────────────────────────────────
//  QUICK INFO BOTTOM SHEET
// ─────────────────────────────────────────────
class _QuickInfoSheet extends StatelessWidget {
  final Subject subject;
  final bool isFavourite;
  final VoidCallback onToggleFavourite;
  final VoidCallback onStartTest;

  const _QuickInfoSheet({
    required this.subject,
    required this.isFavourite,
    required this.onToggleFavourite,
    required this.onStartTest,
  });

  @override
  Widget build(BuildContext context) {
    final s = subject;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: s.gradientColors.isNotEmpty
                          ? s.gradientColors
                          : [s.color, s.color.withOpacity(0.6)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(s.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: s.color)),
                    Text(s.description,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavourite,
                icon: Icon(
                  isFavourite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavourite ? Colors.redAccent : Colors.grey[400],
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          // Details grid
          Row(
            children: [
              _SheetInfo(
                  label: 'Questions',
                  value: '${s.totalQuestions}',
                  icon: Icons.quiz_rounded,
                  color: s.color),
              _SheetInfo(
                  label: 'Duration',
                  value: '${s.durationMinutes} min',
                  icon: Icons.timer_rounded,
                  color: AppColors.green),
              _SheetInfo(
                  label: 'Rating',
                  value: s.rating.toStringAsFixed(1),
                  icon: Icons.star_rounded,
                  color: AppColors.yellow),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SheetInfo(
                  label: 'Difficulty',
                  value: s.difficultyLabel,
                  icon: Icons.bar_chart_rounded,
                  color: Colors.orange),
              _SheetInfo(
                  label: 'Attempts',
                  value: _formatCount(s.attemptedByCount),
                  icon: Icons.people_rounded,
                  color: Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStartTest,
              icon: const Icon(Icons.play_circle_filled_rounded),
              label: const Text('Start Test Now',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: s.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SheetInfo(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style:
                    TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  QUICK STATS DIALOG
// ─────────────────────────────────────────────
class _QuickStatsDialog extends StatelessWidget {
  final List<Subject> subjects;

  const _QuickStatsDialog({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.bar_chart_rounded, color: AppColors.blue),
          SizedBox(width: 8),
          Text('Quick Stats', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: subjects
            .map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: s.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                      Text('${s.totalQuestions}Q · ${s.durationMinutes}m',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ))
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No results for "$query"',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Try a different keyword',
              style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NOTIFICATION TILE
// ─────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _NotifTile(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FADE SLIDE TRANSITION  (unchanged logic)
// ─────────────────────────────────────────────
class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: child,
          );
        }
        return const Opacity(opacity: 0, child: SizedBox.shrink());
      },
    );
  }
}

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
String _formatCount(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}k';
  }
  return '$count';
}