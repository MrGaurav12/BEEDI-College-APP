// attendance_screen.dart
// Self-contained, no external dependencies needed beyond Flutter SDK

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// ─── Colour Tokens ────────────────────────────────────────────────────────────
class _AC {
  static const bg = Color(0xFFF0F6FF);
  static const primary = Color(0xFF1565C0);
  static const accent = Color(0xFF42A5F5);
  static const green = Color(0xFF2E7D32);
  static const greenLight = Color(0xFF66BB6A);
  static const warn = Color(0xFFF57F17);
  static const danger = Color(0xFFC62828);
  static const card = Colors.white;
  static const textDark = Color(0xFF0D1B2A);
  static const textMid = Color(0xFF546E7A);
  static const textLight = Color(0xFF90A4AE);
  static const bgDark = Color(0xFF0D1B2A);
  static const cardDark = Color(0xFF162032);
}

// ─── Data Models ─────────────────────────────────────────────────────────────
class _Subject {
  final String name;
  final int attended;
  final int total;
  final Color color;
  final IconData icon;

  const _Subject({
    required this.name,
    required this.attended,
    required this.total,
    required this.color,
    required this.icon,
  });

  double get percent => attended / total;
  bool get isAtRisk => percent < 0.75;
  int get classesNeeded {
    if (percent >= 0.75) return 0;
    // solve: (attended + x) / (total + x) = 0.75
    final n = ((0.75 * total - attended) / 0.25).ceil();
    return n < 0 ? 0 : n;
  }
}

class _CalendarDay {
  final int day;
  final bool? present; // null = no class
  const _CalendarDay(this.day, this.present);
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────
final _subjects = [
  const _Subject(
    name: 'Mathematics',
    attended: 22,
    total: 24,
    color: Color(0xFF1565C0),
    icon: Icons.calculate_rounded,
  ),
  const _Subject(
    name: 'Physics',
    attended: 17,
    total: 20,
    color: Color(0xFF6A1B9A),
    icon: Icons.science_rounded,
  ),
  const _Subject(
    name: 'DSA',
    attended: 21,
    total: 24,
    color: Color(0xFF00695C),
    icon: Icons.account_tree_rounded,
  ),
  const _Subject(
    name: 'Chemistry',
    attended: 14,
    total: 22,
    color: Color(0xFFC62828),
    icon: Icons.biotech_rounded,
  ),
  const _Subject(
    name: 'English',
    attended: 18,
    total: 20,
    color: Color(0xFF2E7D32),
    icon: Icons.menu_book_rounded,
  ),
];

List<_CalendarDay> _buildCalendar() {
  final r = Random(42);
  return List.generate(30, (i) {
    final isWeekend = (i % 7 == 5 || i % 7 == 6);
    return _CalendarDay(i + 1, isWeekend ? null : (r.nextBool()));
  });
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {
  bool _isDark = false;
  bool _isLoading = false;
  String _period = 'Monthly';
  String? _selectedSubject;
  final _calendar = _buildCalendar();
  late AnimationController _heroCtrl;
  late AnimationController _listCtrl;
  late Animation<double> _heroAnim;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heroAnim = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutBack);
    _heroCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _listCtrl.forward(),
    );
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  Color get _bg => _isDark ? _AC.bgDark : _AC.bg;
  Color get _cardColor => _isDark ? _AC.cardDark : _AC.card;
  Color get _textPrimary => _isDark ? Colors.white : _AC.textDark;
  Color get _textSecondary => _isDark ? Colors.white54 : _AC.textMid;

  double get _overallPercent {
    int a = 0, t = 0;
    for (final s in _subjects) {
      a += s.attended;
      t += s.total;
    }
    return a / t;
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFAB(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: _AC.accent,
        child: _isLoading
            ? _ShimmerList(isDark: _isDark)
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).padding.top + 64,
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildHeroCard(size)),
                  SliverToBoxAdapter(child: _buildPeriodToggle()),
                  SliverToBoxAdapter(child: _buildStatsRow(isWide)),
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Subject-wise Attendance'),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _AnimatedListItem(
                        index: i,
                        controller: _listCtrl,
                        child: _SubjectCard(
                          subject: _subjects[i],
                          isDark: _isDark,
                          cardColor: _cardColor,
                          textPrimary: _textPrimary,
                          textSecondary: _textSecondary,
                          isSelected: _selectedSubject == _subjects[i].name,
                          onTap: () => setState(
                            () => _selectedSubject =
                                _selectedSubject == _subjects[i].name
                                ? null
                                : _subjects[i].name,
                          ),
                        ),
                      ),
                      childCount: _subjects.length,
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildCalendarSection()),
                  SliverToBoxAdapter(child: _buildAlertSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Attendance',
        style: TextStyle(
          color: _textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: _textPrimary,
          ),
          onPressed: () => setState(() => _isDark = !_isDark),
          tooltip: 'Toggle theme',
        ),
        IconButton(
          icon: Icon(Icons.download_rounded, color: _textPrimary),
          onPressed: _showDownloadDialog,
          tooltip: 'Download Report',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      backgroundColor: _AC.primary,
      icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
      label: const Text(
        'Filter',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      onPressed: _showFilterSheet,
    );
  }

  Widget _buildHeroCard(Size size) {
    return ScaleTransition(
      scale: _heroAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFF00BCD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _AC.primary.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -20,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Overall Attendance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(_overallPercent * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _overallPercent,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Min. Required: 75%',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _CircularPercent(percent: _overallPercent, size: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: ['Weekly', 'Monthly', 'Semester']
            .map(
              (p) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _period = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _period == p ? _AC.primary : _cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _period == p ? _AC.primary : Colors.transparent,
                      ),
                      boxShadow: _period == p
                          ? [
                              BoxShadow(
                                color: _AC.primary.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        color: _period == p ? Colors.white : _textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildStatsRow(bool isWide) {
    final stats = [
      ('Total Classes', '110', Icons.class_rounded, _AC.primary),
      ('Attended', '92', Icons.check_circle_rounded, _AC.green),
      ('Missed', '18', Icons.cancel_rounded, _AC.danger),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: stats
            .map(
              (s) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(s.$3, color: s.$4, size: 22),
                        const SizedBox(height: 8),
                        Text(
                          s.$2,
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          s.$1,
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: _textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Calendar — May 2025',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map(
                        (d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: _calendar.length,
                  itemBuilder: (ctx, i) {
                    final day = _calendar[i];
                    Color bg;
                    Color fg;
                    if (day.present == null) {
                      bg = Colors.transparent;
                      fg = _bg;
                    } else if (day.present!) {
                      bg = _AC.green.withOpacity(0.15);
                      fg = _AC.green;
                    } else {
                      bg = _AC.danger.withOpacity(0.12);
                      fg = _AC.danger;
                    }
                    final _textLight = _isDark ? Colors.white24 : _AC.textLight;
                    return Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: fg,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _CalLegend(color: _AC.green, label: 'Present'),
                    const SizedBox(width: 16),
                    _CalLegend(color: _AC.danger, label: 'Absent'),
                    const SizedBox(width: 16),
                    _CalLegend(color: _textSecondary, label: 'Holiday'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSection() {
    final atRisk = _subjects.where((s) => s.isAtRisk).toList();
    if (atRisk.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠️  Attendance Alerts',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...atRisk.map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _AC.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _AC.danger.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: _AC.danger,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: const TextStyle(
                            color: _AC.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Attend ${s.classesNeeded} more class${s.classesNeeded == 1 ? '' : 'es'} to reach 75%',
                          style: TextStyle(color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(s.percent * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: _AC.danger,
                      fontWeight: FontWeight.w800,
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

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Download Report',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose format', style: TextStyle(color: _textSecondary)),
            const SizedBox(height: 16),
            ...[
              ('PDF Report', Icons.picture_as_pdf_rounded, Colors.red),
              ('Excel Sheet', Icons.table_chart_rounded, Colors.green),
              ('Share Link', Icons.share_rounded, _AC.primary),
            ].map(
              (f) => ListTile(
                leading: Icon(f.$2, color: f.$3),
                title: Text(
                  f.$1,
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${f.$1} downloaded!'),
                      backgroundColor: f.$3,
                      behavior: SnackBarBehavior.floating,
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        isDark: _isDark,
        cardColor: _cardColor,
        textPrimary: _textPrimary,
        textSecondary: _textSecondary,
      ),
    );
  }
}

// ─── Reusable Sub-widgets ─────────────────────────────────────────────────────

class _CircularPercent extends StatelessWidget {
  final double percent;
  final double size;
  const _CircularPercent({required this.percent, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent,
            strokeWidth: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
          Center(
            child: Text(
              '${(percent * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final _Subject subject;
  final bool isDark;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isSelected;
  final VoidCallback onTap;
  const _SubjectCard({
    required this.subject,
    required this.isDark,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? subject.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: subject.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(subject.icon, color: subject.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subject.name,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (subject.isAtRisk ? _AC.danger : _AC.green)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(subject.percent * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: subject.isAtRisk ? _AC.danger : _AC.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: subject.percent,
                backgroundColor: subject.color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(subject.color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${subject.attended}/${subject.total} classes',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
                if (subject.isAtRisk)
                  Text(
                    'Need ${subject.classesNeeded} more',
                    style: const TextStyle(
                      color: _AC.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _BarChart(subject: subject),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final _Subject subject;
  const _BarChart({required this.subject});

  @override
  Widget build(BuildContext context) {
    final weeks = [0.88, 0.75, 0.92, subject.percent];
    final labels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          4,
          (i) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${(weeks[i] * 100).round()}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: subject.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 50 * weeks[i],
                    decoration: BoxDecoration(
                      color: subject.color.withOpacity(i == 3 ? 1.0 : 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: const TextStyle(fontSize: 9, color: _AC.textMid),
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

class _CalLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _CalLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color.withOpacity(0.6),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

class _AnimatedListItem extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;
  const _AnimatedListItem({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.1).clamp(0.0, 0.8);
    final anim = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              start,
              (start + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );
    return SlideTransition(
      position: anim,
      child: FadeTransition(opacity: controller, child: child),
    );
  }
}

class _ShimmerList extends StatefulWidget {
  final bool isDark;
  const _ShimmerList({required this.isDark});

  @override
  State<_ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<_ShimmerList>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          5,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment(_anim.value - 1, 0),
                end: Alignment(_anim.value + 1, 0),
                colors: widget.isDark
                    ? [
                        const Color(0xFF162032),
                        const Color(0xFF1E2D40),
                        const Color(0xFF162032),
                      ]
                    : [
                        const Color(0xFFE8F0FE),
                        const Color(0xFFFFFFFF),
                        const Color(0xFFE8F0FE),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final bool isDark;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  const _FilterSheet({
    required this.isDark,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          color: widget.cardColor.withOpacity(0.95),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filter Subjects',
                style: TextStyle(
                  color: widget.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _subjects
                    .map(
                      (s) => FilterChip(
                        label: Text(s.name),
                        selected: _selected.contains(s.name),
                        onSelected: (v) => setState(
                          () => v
                              ? _selected.add(s.name)
                              : _selected.remove(s.name),
                        ),
                        selectedColor: s.color.withOpacity(0.2),
                        checkmarkColor: s.color,
                        labelStyle: TextStyle(
                          color: _selected.contains(s.name)
                              ? s.color
                              : widget.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AC.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Apply Filter',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
