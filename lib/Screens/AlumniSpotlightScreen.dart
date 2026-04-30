// alumni_spotlight_screen.dart
// Self-contained — no external dependencies beyond Flutter SDK

import 'dart:ui';
import 'package:flutter/material.dart';

// ─── Colour Tokens ────────────────────────────────────────────────────────────
class _ALC {
  static const bg = Color(0xFFF0F6FF);
  static const primary = Color(0xFF1E88E5);
  static const dark = Color(0xFF1565C0);
  static const green = Color(0xFF2E7D32);
  static const card = Colors.white;
  static const textDark = Color(0xFF0D1B2A);
  static const textMid = Color(0xFF546E7A);
  static const textLight = Color(0xFF90A4AE);
  static const bgDark = Color(0xFF0D1B2A);
  static const cardDark = Color(0xFF162032);

  static const fieldColors = {
    'Tech': Color(0xFF1565C0),
    'Govt': Color(0xFF2E7D32),
    'Startup': Color(0xFFF57F17),
    'Research': Color(0xFF6A1B9A),
    'Finance': Color(0xFF00695C),
  };
}

// ─── Data Model ───────────────────────────────────────────────────────────────
class _Alumni {
  final String name;
  final String role;
  final String company;
  final String field;
  final String batch;
  final String department;
  final String achievement;
  final String quote;
  final String emoji;
  final bool isFeatured;
  final List<String> socialLinks;

  const _Alumni({
    required this.name,
    required this.role,
    required this.company,
    required this.field,
    required this.batch,
    required this.department,
    required this.achievement,
    required this.quote,
    required this.emoji,
    this.isFeatured = false,
    this.socialLinks = const [],
  });
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────
const _alumniList = [
  _Alumni(
    name: 'Dr. Amit Verma', role: 'CTO', company: 'Zomato',
    field: 'Tech', batch: '2010', department: 'CSE',
    achievement: 'Led tech team scaling to 50M+ users',
    quote: 'BEEDI gave me the foundation to dream big and build bigger.',
    emoji: '🚀', isFeatured: true,
    socialLinks: ['LinkedIn', 'Twitter', 'GitHub'],
  ),
  _Alumni(
    name: 'Kavya Singh', role: 'IAS Officer', company: 'Bihar Cadre',
    field: 'Govt', batch: '2012', department: 'Law',
    achievement: 'Ranked AIR 42 in UPSC 2016, youngest DM in Bihar',
    quote: 'Discipline from college life shaped my civil service journey.',
    emoji: '⚖️', isFeatured: true,
    socialLinks: ['LinkedIn'],
  ),
  _Alumni(
    name: 'Rahul Jha', role: 'Senior Researcher', company: 'NASA JPL',
    field: 'Research', batch: '2008', department: 'Physics',
    achievement: 'Published 15+ papers in Nature & Science',
    quote: 'The research culture at BEEDI ignited my curiosity.',
    emoji: '🔭', isFeatured: true,
    socialLinks: ['LinkedIn', 'ResearchGate'],
  ),
  _Alumni(
    name: 'Meera Pandey', role: 'Founder & CEO', company: 'FinLeap',
    field: 'Startup', batch: '2014', department: 'BBA',
    achievement: 'Forbes 30 Under 30, raised ₹200Cr Series B',
    quote: 'Entrepreneurship is about solving real problems at scale.',
    emoji: '💡', isFeatured: false,
    socialLinks: ['LinkedIn', 'Twitter'],
  ),
  _Alumni(
    name: 'Sanjay Sinha', role: 'Co-Founder', company: 'EduBridge',
    field: 'Startup', batch: '2011', department: 'MBA',
    achievement: 'Built India\'s largest rural EdTech platform',
    quote: 'Every student deserves world-class education, everywhere.',
    emoji: '📱', isFeatured: false,
    socialLinks: ['LinkedIn', 'Twitter'],
  ),
  _Alumni(
    name: 'Dr. Priti Gupta', role: 'VP Research', company: 'DRDO',
    field: 'Research', batch: '2007', department: 'Electronics',
    achievement: 'Led defense AI project saving 3000+ soldier lives',
    quote: 'Science in service of the nation is the highest calling.',
    emoji: '🛡️', isFeatured: false,
    socialLinks: ['LinkedIn'],
  ),
  _Alumni(
    name: 'Anil Tiwari', role: 'MD', company: 'HDFC Securities',
    field: 'Finance', batch: '2009', department: 'Commerce',
    achievement: 'Manages ₹5000Cr AUM portfolio',
    quote: 'Numbers tell stories — you just need to learn to listen.',
    emoji: '📈', isFeatured: false,
    socialLinks: ['LinkedIn', 'Twitter'],
  ),
  _Alumni(
    name: 'Ritika Chopra', role: 'Deputy Secretary', company: 'MoEF',
    field: 'Govt', batch: '2013', department: 'Environmental Sci',
    achievement: 'Framed India\'s landmark EV policy 2022',
    quote: 'Policy is the most powerful tool for systemic change.',
    emoji: '🌱', isFeatured: false,
    socialLinks: ['LinkedIn'],
  ),
];

const _fields = ['All', 'Tech', 'Govt', 'Startup', 'Research', 'Finance'];
const _successStories = [
  ('From Hostel Room to Unicorn HQ', 'Sanjay built EduBridge from a 2-laptop startup in BEEDI dorms to a unicorn with 5M+ users.', '📱'),
  ('UPSC Topper in First Attempt', 'Kavya cracked UPSC AIR 42 on her first attempt while managing college responsibilities.', '⚖️'),
  ('From Lab to NASA', 'Rahul\'s final year project caught the eye of a NASA professor, leading to a life-changing fellowship.', '🔭'),
];

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AlumniSpotlightScreen extends StatefulWidget {
  const AlumniSpotlightScreen({super.key});

  @override
  State<AlumniSpotlightScreen> createState() => _AlumniSpotlightScreenState();
}

class _AlumniSpotlightScreenState extends State<AlumniSpotlightScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _selectedField = 'All';
  bool _isDark = false;
  int _carouselIndex = 0;
  final _pageCtrl = PageController();

  late AnimationController _heroCtrl;
  late AnimationController _listCtrl;
  late Animation<double> _heroAnim;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _listCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _heroAnim = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutBack);
    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _listCtrl.forward());
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _listCtrl.dispose();
    _searchCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Color get _bg => _isDark ? _ALC.bgDark : _ALC.bg;
  Color get _cardColor => _isDark ? _ALC.cardDark : _ALC.card;
  Color get _textPrimary => _isDark ? Colors.white : _ALC.textDark;
  Color get _textSecondary => _isDark ? Colors.white54 : _ALC.textMid;

  List<_Alumni> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return _alumniList.where((a) {
      final fieldOk = _selectedField == 'All' || a.field == _selectedField;
      final nameOk = q.isEmpty
          || a.name.toLowerCase().contains(q)
          || a.company.toLowerCase().contains(q)
          || a.role.toLowerCase().contains(q)
          || a.department.toLowerCase().contains(q);
      return fieldOk && nameOk;
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + 64)),
          SliverToBoxAdapter(child: _buildHeroBanner()),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildFeaturedAlumni(isWide)),
          SliverToBoxAdapter(child: _buildSuccessStoriesCarousel()),
          SliverToBoxAdapter(child: _buildSearchAndFilter()),
          SliverToBoxAdapter(child: _buildSectionHeader('All Alumni')),
          _buildAlumniGrid(isWide),
          SliverToBoxAdapter(child: _buildVideoSection()),
          SliverToBoxAdapter(child: _buildMentorshipCTA()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text('Alumni Spotlight',
        style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.3)),
      actions: [
        IconButton(
          icon: Icon(_isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: _textPrimary),
          onPressed: () => setState(() => _isDark = !_isDark),
        ),
        IconButton(
          icon: Icon(Icons.bookmark_border_rounded, color: _textPrimary),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Bookmarks saved!'), backgroundColor: _ALC.primary, behavior: SnackBarBehavior.floating)),
          tooltip: 'Saved Alumni',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      backgroundColor: _ALC.dark,
      icon: const Icon(Icons.handshake_rounded, color: Colors.white),
      label: const Text('Request Mentor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      onPressed: _showMentorshipDialog,
    );
  }

  Widget _buildHeroBanner() {
    return ScaleTransition(
      scale: _heroAnim,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: _ALC.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(top: -40, right: -40,
              child: Container(width: 160, height: 160,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
            Positioned(bottom: -60, left: -20,
              child: Container(width: 200, height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🌟', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  const Text('Our Distinguished Alumni',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2)),
                  const SizedBox(height: 6),
                  Text('Making waves globally across all fields',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      ('${_alumniList.length}+', 'Alumni', Icons.people_rounded, _ALC.primary),
      ('12', 'Countries', Icons.public_rounded, _ALC.green),
      ('4', 'Unicorns', Icons.rocket_launch_rounded, Color(0xFFF57F17)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: stats.map((s) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(s.$3, color: s.$4, size: 20),
                const SizedBox(height: 8),
                Text(s.$1, style: TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                Text(s.$2, style: TextStyle(color: _textSecondary, fontSize: 11)),
              ]),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFeaturedAlumni(bool isWide) {
    final featured = _alumniList.where((a) => a.isFeatured).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('✨ Featured Alumni'),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: featured.length,
            itemBuilder: (ctx, i) => _FeaturedCard(
              alumni: featured[i],
              isDark: _isDark,
              textPrimary: _textPrimary,
              textSecondary: _textSecondary,
              onTap: () => _showAlumniDetail(featured[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStoriesCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('📖 Success Stories'),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _carouselIndex = i),
            itemCount: _successStories.length,
            itemBuilder: (ctx, i) {
              final s = _successStories[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$3, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 8),
                    Text(s.$1, style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(s.$2, style: TextStyle(color: _textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_successStories.length, (i) => GestureDetector(
            onTap: () { _pageCtrl.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _carouselIndex == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _carouselIndex == i ? _ALC.primary : _ALC.textLight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ))),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
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
                hintText: 'Search alumni, company, role…',
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
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _fields.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final f = _fields[i];
                final selected = _selectedField == f;
                final color = f == 'All' ? _ALC.primary : (_ALC.fieldColors[f] ?? _ALC.primary);
                return GestureDetector(
                  onTap: () => setState(() => _selectedField = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? color : _cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)] : [],
                    ),
                    child: Text(f,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(title, style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildAlumniGrid(bool isWide) {
    final list = _filtered;
    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('No alumni found', style: TextStyle(color: _textSecondary, fontSize: 16)),
          ]),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWide ? 3 : 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            final delay = (i * 0.07).clamp(0.0, 0.7);
            final slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
              CurvedAnimation(parent: _listCtrl, curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOut)),
            );
            return SlideTransition(
              position: slideAnim,
              child: FadeTransition(
                opacity: _listCtrl,
                child: _AlumniCard(
                  alumni: list[i],
                  isDark: _isDark,
                  cardColor: _cardColor,
                  textPrimary: _textPrimary,
                  textSecondary: _textSecondary,
                  onTap: () => _showAlumniDetail(list[i]),
                ),
              ),
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎬 Alumni Talks', style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: 3,
              itemBuilder: (ctx, i) {
                final titles = ['How I Built a Unicorn', 'UPSC: My Journey', 'Life at NASA'];
                final emojis = ['💡', '📚', '🔭'];
                return Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: _ALC.dark.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Center(child: Text(emojis[i], style: const TextStyle(fontSize: 36))),
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.black87, Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                          ),
                          child: Text(titles[i], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      Positioned(
                        top: 10, right: 10,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
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

  Widget _buildMentorshipCTA() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _ALC.green.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🤝 Need a Mentor?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Connect with 50+ BEEDI alumni mentors',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ])),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _ALC.green,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _showMentorshipDialog,
            child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ]),
      ),
    );
  }

  void _showAlumniDetail(_Alumni alumni) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlumniDetailSheet(
        alumni: alumni, isDark: _isDark, cardColor: _cardColor, textPrimary: _textPrimary, textSecondary: _textSecondary,
      ),
    );
  }

  void _showMentorshipDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Request Mentorship', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Choose your area of interest', style: TextStyle(color: _textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _fields.skip(1).map((f) {
              final color = _ALC.fieldColors[f] ?? _ALC.primary;
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mentorship request sent for $f!'), backgroundColor: color, behavior: SnackBarBehavior.floating));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
                  child: Text(f, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                ),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _AvatarBubble extends StatelessWidget {
  final String name;
  final String emoji;
  final double size;
  final String field;
  const _AvatarBubble({required this.name, required this.emoji, required this.size, required this.field});

  Color get _color => _ALC.fieldColors[field] ?? _ALC.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_color.withOpacity(0.7), _color],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.4))),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final _Alumni alumni;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;
  const _FeaturedCard({required this.alumni, required this.isDark, required this.textPrimary, required this.textSecondary, required this.onTap});

  Color get _fieldColor => _ALC.fieldColors[alumni.field] ?? _ALC.primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? _ALC.cardDark : _ALC.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _fieldColor.withOpacity(0.2), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _AvatarBubble(name: alumni.name, emoji: alumni.emoji, size: 44, field: alumni.field),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _fieldColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(alumni.field, style: TextStyle(color: _fieldColor, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 10),
            Text(alumni.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${alumni.role}, ${alumni.company}', style: TextStyle(color: textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('"${alumni.quote}"',
              style: TextStyle(color: textSecondary, fontSize: 10, fontStyle: FontStyle.italic),
              maxLines: 3, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(children: [
              Text('Batch \'${alumni.batch.substring(2)}', style: TextStyle(color: _fieldColor, fontSize: 10, fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: textSecondary),
            ]),
          ],
        ),
      ),
    );
  }
}

class _AlumniCard extends StatelessWidget {
  final _Alumni alumni;
  final bool isDark;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;
  const _AlumniCard({required this.alumni, required this.isDark, required this.cardColor, required this.textPrimary, required this.textSecondary, required this.onTap});

  Color get _fieldColor => _ALC.fieldColors[alumni.field] ?? _ALC.primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _AvatarBubble(name: alumni.name, emoji: alumni.emoji, size: 52, field: alumni.field),
            const SizedBox(height: 10),
            Text(alumni.name, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(alumni.role, style: TextStyle(color: textSecondary, fontSize: 10), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(alumni.company, style: TextStyle(color: _fieldColor, fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _fieldColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(alumni.field, style: TextStyle(color: _fieldColor, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlumniDetailSheet extends StatelessWidget {
  final _Alumni alumni;
  final bool isDark;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  const _AlumniDetailSheet({required this.alumni, required this.isDark, required this.cardColor, required this.textPrimary, required this.textSecondary});

  Color get _fieldColor => _ALC.fieldColors[alumni.field] ?? _ALC.primary;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          color: cardColor.withOpacity(0.97),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              _AvatarBubble(name: alumni.name, emoji: alumni.emoji, size: 80, field: alumni.field),
              const SizedBox(height: 12),
              Text(alumni.name, style: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
              Text('${alumni.role} · ${alumni.company}', style: TextStyle(color: textSecondary, fontSize: 14)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: _fieldColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(alumni.field, style: TextStyle(color: _fieldColor, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              const SizedBox(height: 16),
              // Info row
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _InfoPill(label: 'Batch', value: alumni.batch, color: _fieldColor),
                _InfoPill(label: 'Dept', value: alumni.department, color: _fieldColor),
              ]),
              const SizedBox(height: 16),
              // Achievement
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _fieldColor.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: _fieldColor.withOpacity(0.2))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('🏆 Achievement', style: TextStyle(color: _fieldColor, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(alumni.achievement, style: TextStyle(color: textPrimary, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 12),
              // Quote
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('💬 Quote', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('"${alumni.quote}"', style: TextStyle(color: textPrimary, fontSize: 13, fontStyle: FontStyle.italic)),
                ]),
              ),
              const SizedBox(height: 16),
              // Social Links
              if (alumni.socialLinks.isNotEmpty) ...[
                Align(alignment: Alignment.centerLeft, child: Text('Connect', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 15))),
                const SizedBox(height: 10),
                Row(children: alumni.socialLinks.map((link) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _fieldColor,
                      side: BorderSide(color: _fieldColor.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: Icon(_socialIcon(link), size: 14),
                    label: Text(link, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening $link…'), backgroundColor: _fieldColor, behavior: SnackBarBehavior.floating)),
                  ),
                )).toList()),
                const SizedBox(height: 16),
              ],
              // Connect & Mentorship
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _fieldColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.handshake_rounded, color: Colors.white, size: 18),
                  label: const Text('Request Mentorship', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mentorship request sent to ${alumni.name.split(' ').first}!'), backgroundColor: _fieldColor, behavior: SnackBarBehavior.floating));
                  },
                )),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: _fieldColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(14),
                  ),
                  icon: Icon(Icons.bookmark_border_rounded, color: _fieldColor),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Bookmarked!'), backgroundColor: _fieldColor, behavior: SnackBarBehavior.floating));
                  },
                ),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }

  IconData _socialIcon(String link) {
    switch (link) {
      case 'Twitter': return Icons.alternate_email_rounded;
      case 'GitHub': return Icons.code_rounded;
      case 'ResearchGate': return Icons.science_rounded;
      default: return Icons.link_rounded;
    }
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
    ),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: _ALC.textMid, fontSize: 12)),
  ]);
}