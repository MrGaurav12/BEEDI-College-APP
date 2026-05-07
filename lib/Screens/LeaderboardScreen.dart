// leaderboard_screen.dart
// Self-contained — no external dependencies beyond Flutter SDK

import 'dart:ui';
import 'package:flutter/material.dart';

// ─── Colour Tokens ────────────────────────────────────────────────────────────
class _LC {
  static const bg = Color(0xFFF0F6FF);
  static const primary = Color(0xFF1565C0);
  static const accent = Color(0xFF42A5F5);
  static const gold = Color(0xFFFFB300);
  static const silver = Color(0xFF90A4AE);
  static const bronze = Color(0xFFBF7A3A);
  static const green = Color(0xFF2E7D32);
  static const card = Colors.white;
  static const textDark = Color(0xFF0D1B2A);
  static const textMid = Color(0xFF546E7A);
  static const bgDark = Color(0xFF0D1B2A);
  static const cardDark = Color(0xFF162032);

  static const podiumGradients = [
    [Color(0xFFFFB300), Color(0xFFFFF176)], // gold
    [Color(0xFF90A4AE), Color(0xFFECEFF1)], // silver
    [Color(0xFFBF7A3A), Color(0xFFFFCCBC)], // bronze
  ];
}

// ─── Data Model ───────────────────────────────────────────────────────────────
class _Student {
  final int rank;
  final int prevRank;
  final String name;
  final String department;
  final int points;
  final String badge;
  final String avatar;
  final bool isMe;
  const _Student({
    required this.rank,
    required this.prevRank,
    required this.name,
    required this.department,
    required this.points,
    required this.badge,
    this.avatar = '',
    this.isMe = false,
  });

  int get rankChange => prevRank - rank;
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────
const _allStudents = [
  _Student(rank: 1, prevRank: 1, name: 'Priya Sharma', department: 'CSE', points: 9850, badge: '🏆', isMe: false),
  _Student(rank: 2, prevRank: 3, name: 'Arjun Mehta', department: 'MBA', points: 9720, badge: '🥈'),
  _Student(rank: 3, prevRank: 2, name: 'Sneha Roy', department: 'Physics', points: 9650, badge: '🥉'),
  _Student(rank: 4, prevRank: 5, name: 'Rohit Kumar', department: 'ECE', points: 9520, badge: '⭐'),
  _Student(rank: 5, prevRank: 4, name: 'Anjali Gupta', department: 'BBA', points: 9410, badge: '⭐'),
  _Student(rank: 6, prevRank: 6, name: 'Dev Nair', department: 'CSE', points: 9310, badge: '🌟'),
  _Student(rank: 7, prevRank: 9, name: 'Meera Pillai', department: 'EEE', points: 9180, badge: '🌟'),
  _Student(rank: 8, prevRank: 7, name: 'Vishal Joshi', department: 'MBA', points: 9050, badge: '🎖️'),
  _Student(rank: 9, prevRank: 8, name: 'Tanvi Singh', department: 'BCA', points: 8940, badge: '🎖️'),
  _Student(rank: 10, prevRank: 12, name: 'Rahul Verma', department: 'CSE', points: 8810, badge: '🎖️', isMe: true),
  _Student(rank: 11, prevRank: 10, name: 'Kriti Jain', department: 'Physics', points: 8720, badge: '📌'),
  _Student(rank: 12, prevRank: 11, name: 'Abhishek Das', department: 'ECE', points: 8650, badge: '📌'),
];

const _departments = ['All', 'CSE', 'MBA', 'Physics', 'ECE', 'BBA', 'EEE', 'BCA'];
const _tabs = ['Weekly', 'Monthly', 'Yearly'];

// ─── Main Screen ──────────────────────────────────────────────────────────────
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _selectedDept = 'All';
  int _selectedTab = 1;
  bool _isDark = false;
  bool _isSearching = false;

  late AnimationController _podiumCtrl;
  late AnimationController _listCtrl;
  late Animation<double> _podiumAnim;

  @override
  void initState() {
    super.initState();
    _podiumCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _listCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _podiumAnim = CurvedAnimation(parent: _podiumCtrl, curve: Curves.elasticOut);
    _podiumCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () => _listCtrl.forward());
  }

  @override
  void dispose() {
    _podiumCtrl.dispose();
    _listCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Color get _bg => _isDark ? _LC.bgDark : _LC.bg;
  Color get _cardColor => _isDark ? _LC.cardDark : _LC.card;
  Color get _textPrimary => _isDark ? Colors.white : _LC.textDark;
  Color get _textSecondary => _isDark ? Colors.white54 : _LC.textMid;

  List<_Student> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return _allStudents.where((s) {
      final deptOk = _selectedDept == 'All' || s.department == _selectedDept;
      final nameOk = q.isEmpty || s.name.toLowerCase().contains(q) || s.department.toLowerCase().contains(q);
      return deptOk && nameOk;
    }).toList();
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
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 56),
          _buildTabRow(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildPodium(isWide)),
                SliverToBoxAdapter(child: _buildSearchAndFilter()),
                SliverToBoxAdapter(child: _buildMyRankBanner()),
                SliverToBoxAdapter(child: _buildListHeader()),
                _buildStudentList(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text('Leaderboard',
        style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.3)),
      actions: [
        IconButton(
          icon: Icon(_isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: _textPrimary),
          onPressed: () => setState(() => _isDark = !_isDark),
        ),
        IconButton(
          icon: Icon(Icons.share_rounded, color: _textPrimary),
          onPressed: _shareRank,
          tooltip: 'Share your rank',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      backgroundColor: _LC.primary,
      icon: const Icon(Icons.emoji_events_rounded, color: Colors.white),
      label: const Text('My Badges', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      onPressed: _showBadgesSheet,
    );
  }

  Widget _buildTabRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: List.generate(_tabs.length, (i) => Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedTab = i);
              _podiumCtrl.reset(); _podiumCtrl.forward();
              _listCtrl.reset(); _listCtrl.forward();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _selectedTab == i ? _LC.primary : _cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _selectedTab == i ? [BoxShadow(color: _LC.primary.withOpacity(0.3), blurRadius: 8)] : [],
              ),
              child: Center(child: Text(_tabs[i],
                style: TextStyle(
                  color: _selectedTab == i ? Colors.white : _textSecondary,
                  fontWeight: FontWeight.w600, fontSize: 13))),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildPodium(bool isWide) {
    final top3 = _filtered.take(3).toList();
    if (top3.length < 3) return const SizedBox.shrink();

    // order: 2nd, 1st, 3rd for visual podium
    final order = [top3[1], top3[0], top3[2]];
    final heights = [110.0, 140.0, 90.0];

    return ScaleTransition(
      scale: _podiumAnim,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: _LC.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            Text('🏅 Top Performers', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(3, (i) {
                final s = order[i];
                final isFirst = i == 1;
                final podiumColors = [_LC.podiumGradients[1], _LC.podiumGradients[0], _LC.podiumGradients[2]];
                return Expanded(
                  child: Column(
                    children: [
                      if (isFirst) ...[
                        const Text('👑', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                      ],
                      _AvatarCircle(name: s.name, size: isFirst ? 60 : 48, colors: podiumColors[i]),
                      const SizedBox(height: 6),
                      Text(s.name.split(' ').first,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${s.points} pts',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Container(
                        height: heights[i],
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          gradient: LinearGradient(
                            colors: podiumColors[i],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(child: Text(
                          i == 1 ? '1st' : i == 0 ? '2nd' : '3rd',
                          style: TextStyle(
                            color: i == 0 ? _LC.textDark : Colors.white,
                            fontWeight: FontWeight.w800, fontSize: 14))),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Search student or department…',
                hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: _textSecondary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: Icon(Icons.close_rounded, color: _textSecondary), onPressed: () { _searchCtrl.clear(); setState(() {}); })
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Dept filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _departments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final dept = _departments[i];
                final selected = _selectedDept == dept;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDept = dept),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? _LC.primary : _cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: selected ? [BoxShadow(color: _LC.primary.withOpacity(0.3), blurRadius: 8)] : [],
                    ),
                    child: Text(dept,
                      style: TextStyle(
                        color: selected ? Colors.white : _textSecondary,
                        fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankBanner() {
    final me = _allStudents.firstWhere((s) => s.isMe, orElse: () => _allStudents.last);
    return GestureDetector(
      onTap: _shareRank,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_LC.accent, _LC.primary]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: Center(child: Text('#${me.rank}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Your Rank', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
            Text(me.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ])),
          Text('${me.points} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(width: 8),
          const Icon(Icons.share_rounded, color: Colors.white70, size: 18),
        ]),
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(children: [
        Text('Rankings', style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text('Updated weekly', style: TextStyle(color: _textSecondary, fontSize: 12)),
      ]),
    );
  }

  Widget _buildStudentList() {
    final list = _filtered;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) {
          final s = list[i];
          final delay = (i * 0.06).clamp(0.0, 0.8);
          final anim = Tween<Offset>(begin: const Offset(0.4, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: _listCtrl, curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOut)),
          );
          return SlideTransition(
            position: anim,
            child: FadeTransition(
              opacity: _listCtrl,
              child: _StudentTile(
                student: s,
                isDark: _isDark,
                cardColor: _cardColor,
                textPrimary: _textPrimary,
                textSecondary: _textSecondary,
                onTap: () => _showStudentDetail(s),
              ),
            ),
          );
        },
        childCount: list.length,
      ),
    );
  }

  void _showStudentDetail(_Student s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StudentDetailSheet(student: s, isDark: _isDark, cardColor: _cardColor, textPrimary: _textPrimary, textSecondary: _textSecondary),
    );
  }

  void _showBadgesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BadgesSheet(isDark: _isDark, cardColor: _cardColor, textPrimary: _textPrimary, textSecondary: _textSecondary),
    );
  }

  void _shareRank() {
    final me = _allStudents.firstWhere((s) => s.isMe, orElse: () => _allStudents.last);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: You\'re rank #${me.rank} with ${me.points} points! 🏆'),
        backgroundColor: _LC.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  final String name;
  final double size;
  final List<Color> colors;
  const _AvatarCircle({required this.name, required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Center(child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(color: _LC.textDark, fontWeight: FontWeight.w800, fontSize: size * 0.35))),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final _Student student;
  final bool isDark;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;
  const _StudentTile({required this.student, required this.isDark, required this.cardColor, required this.textPrimary, required this.textSecondary, required this.onTap});

  Color get _rankColor {
    if (student.rank == 1) return _LC.gold;
    if (student.rank == 2) return _LC.silver;
    if (student.rank == 3) return _LC.bronze;
    return _LC.textMid;
  }

  @override
  Widget build(BuildContext context) {
    final isMe = student.isMe;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? _LC.primary.withOpacity(0.08) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isMe ? Border.all(color: _LC.primary.withOpacity(0.4), width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          // Rank
          SizedBox(
            width: 36,
            child: Text('#${student.rank}',
              style: TextStyle(color: _rankColor, fontWeight: FontWeight.w800, fontSize: 14),
              textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          // Avatar
          _AvatarCircle(
            name: student.name,
            size: 40,
            colors: student.rank == 1 ? _LC.podiumGradients[0]
                : student.rank == 2 ? _LC.podiumGradients[1]
                : [_LC.accent.withOpacity(0.6), _LC.primary.withOpacity(0.8)],
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(student.name,
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              if (isMe) ...[const SizedBox(width: 6), Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _LC.primary, borderRadius: BorderRadius.circular(6)),
                child: const Text('You', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
              )],
            ]),
            Text(student.department, style: TextStyle(color: textSecondary, fontSize: 12)),
          ])),
          // Points + rank change
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${student.points}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
            _RankChangeBadge(change: student.rankChange),
          ]),
          const SizedBox(width: 8),
          Text(student.badge, style: const TextStyle(fontSize: 16)),
        ]),
      ),
    );
  }
}

class _RankChangeBadge extends StatelessWidget {
  final int change;
  const _RankChangeBadge({required this.change});

  @override
  Widget build(BuildContext context) {
    if (change == 0) return const SizedBox.shrink();
    final up = change > 0;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        color: up ? _LC.green : Colors.redAccent, size: 12),
      Text('${change.abs()}',
        style: TextStyle(color: up ? _LC.green : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _StudentDetailSheet extends StatelessWidget {
  final _Student student;
  final bool isDark;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  const _StudentDetailSheet({required this.student, required this.isDark, required this.cardColor, required this.textPrimary, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          color: cardColor.withOpacity(0.97),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            _AvatarCircle(
              name: student.name, size: 80,
              colors: student.rank == 1 ? _LC.podiumGradients[0]
                  : student.rank == 2 ? _LC.podiumGradients[1]
                  : [_LC.accent, _LC.primary],
            ),
            const SizedBox(height: 12),
            Text(student.name, style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
            Text(student.department, style: TextStyle(color: textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _StatPill(label: 'Rank', value: '#${student.rank}', color: _LC.primary),
              _StatPill(label: 'Points', value: '${student.points}', color: _LC.green),
              _StatPill(label: 'Badge', value: student.badge, color: _LC.gold),
            ]),
            const SizedBox(height: 20),
            // Points progress bar
            LinearProgressIndicator(
              value: student.points / 10000,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(_LC.primary),
              minHeight: 8,
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${student.points} pts', style: TextStyle(color: textSecondary, fontSize: 12)),
              Text('Goal: 10,000 pts', style: TextStyle(color: textSecondary, fontSize: 12)),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _LC.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                label: const Text('Share Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: _LC.textMid, fontSize: 12)),
    ]);
  }
}

class _BadgesSheet extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  const _BadgesSheet({required this.isDark, required this.cardColor, required this.textPrimary, required this.textSecondary});

  static const _badges = [
    ('🏆', 'Champion', 'Top rank 3 consecutive weeks', true),
    ('📚', 'Scholar', 'GPA above 9.0', true),
    ('🎯', 'Consistent', '30-day login streak', true),
    ('🏃', 'Active', '10+ events participated', false),
    ('🔬', 'Researcher', 'Published a paper', false),
    ('🌐', 'Global', 'International exchange', false),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          color: cardColor.withOpacity(0.97),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('My Badges', style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _badges.map((b) => _BadgeTile(
                emoji: b.$1, title: b.$2, desc: b.$3, earned: b.$4,
                textPrimary: textPrimary, textSecondary: textSecondary,
              )).toList(),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final bool earned;
  final Color textPrimary;
  final Color textSecondary;
  const _BadgeTile({required this.emoji, required this.title, required this.desc, required this.earned, required this.textPrimary, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1.0 : 0.35,
      child: Tooltip(
        message: desc,
        child: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: earned ? [_LC.gold, _LC.accent] : [Colors.grey[300]!, Colors.grey[200]!],
              ),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}