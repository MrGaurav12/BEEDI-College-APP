// ─── Advanced Animated Footer ─────────────────────────────────────────────────
// Drop-in replacement — all existing names, logic & navigation preserved.
// New features layered on top without breaking anything.

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────────────────────────
// KEEP: original _FL helper (unchanged)
// ──────────────────────────────────────────────────────────────────────────────
Widget _FL(String label, VoidCallback onTap) => _AnimatedFooterLink(
  label: label,
  onTap: onTap,
);

// ──────────────────────────────────────────────────────────────────────────────
// KEEP: original _SocialBtn (enhanced, same class name & constructor)
// ──────────────────────────────────────────────────────────────────────────────
class _SocialBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final String label;
  const _SocialBtn(this.icon, this.color, {this.tooltip = '', this.label = ''});

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip.isNotEmpty ? widget.tooltip : widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () {
            _pulse.reset();
            _pulse.forward();
            if (widget.tooltip.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Opening ${widget.tooltip}…'),
                backgroundColor: const Color(0xFF1565C0),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _hovered
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: _hovered
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white.withOpacity(0.3),
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 2)
                    ]
                  : [],
            ),
            child: ScaleTransition(
              scale: _pulseAnim,
              child: Icon(widget.icon, color: widget.color, size: 17),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// KEEP: _Footer class name, constructor, onNav — everything enhanced in-place
// ──────────────────────────────────────────────────────────────────────────────
class _Footer extends StatefulWidget {
  final void Function(Widget) onNav;
  const _Footer({required this.onNav});

  @override
  State<_Footer> createState() => _FooterState();
}

class _FooterState extends State<_Footer> with TickerProviderStateMixin {
  // ── Animations ──
  late AnimationController _enterCtrl;
  late AnimationController _gradCtrl;
  late AnimationController _glowCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _gradAnim;
  late Animation<double> _glowAnim;

  // ── State ──
  late Timer _clockTimer;
  late DateTime _now;
  int _visitorCount = 24_817;
  bool _isOnline = true;
  bool _moreLinksExpanded = false;
  bool _footerCollapsed = false;
  int _typingIndex = 0;
  late Timer _typingTimer;
  static const _tagline = 'Empowering Minds · Shaping Futures';

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    // Entrance animation
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));

    // Gradient animation
    _gradCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _gradAnim =
        CurvedAnimation(parent: _gradCtrl, curve: Curves.easeInOut);

    // Glow animation
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _enterCtrl.forward();

    // Clock ticker
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    // Typing animation
    _typingTimer =
        Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted && _typingIndex < _tagline.length) {
        setState(() => _typingIndex++);
      }
    });

    // Simulate visitor count tick
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _visitorCount++);
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _gradCtrl.dispose();
    _glowCtrl.dispose();
    _clockTimer.cancel();
    _typingTimer.cancel();
    super.dispose();
  }

  String get _timeString =>
      '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';

  String get _dateString {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[_now.month - 1]} ${_now.day}, ${_now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: LayoutBuilder(builder: (ctx, constraints) {
          final w = constraints.maxWidth;
          final isSmall = w < 500;
          final isMedium = w >= 500 && w < 900;
          final isLarge = w >= 900;

          return Stack(
            children: [
              _buildAnimatedBackground(),
              _buildGlassLayer(),
              _buildContent(isSmall, isMedium, isLarge),
            ],
          );
        }),
      ),
    );
  }

  // ── Animated gradient background ──────────────────────────────────────────
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _gradAnim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(top: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [
              Color(0xFF0A3880),
              Color(0xFF0D47A1),
              Color(0xFF1565C0),
              Color(0xFF0D47A1),
            ],
            begin: Alignment(
                -1.0 + _gradAnim.value * 2, -1.0 + _gradAnim.value),
            end: Alignment(1.0 - _gradAnim.value, 1.0),
          ),
        ),
        child: const SizedBox(height: 600), // placeholder height
      ),
    );
  }

  // ── Glassmorphism blur layer ───────────────────────────────────────────────
  Widget _buildGlassLayer() {
    return Positioned.fill(
      top: 28,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  // ── Main content ──────────────────────────────────────────────────────────
  Widget _buildContent(bool isSmall, bool isMedium, bool isLarge) {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: EdgeInsets.fromLTRB(
        isLarge ? 48 : 20,
        28,
        isLarge ? 48 : 20,
        36,
      ),
      child: Column(
        children: [
          // Collapse toggle for small screens
          if (isSmall) _buildCollapseToggle(),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 350),
            crossFadeState: (_footerCollapsed && isSmall)
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                _buildBrandSection(),
                const SizedBox(height: 20),
                _buildSmartBar(isSmall),
                const SizedBox(height: 20),
                isLarge
                    ? _buildLinksGrid()
                    : _buildLinksWrap(isSmall),
                _buildMoreLinks(isSmall),
                const SizedBox(height: 20),
                _buildSocialSection(),
                const SizedBox(height: 20),
                _buildAnimatedDivider(),
                const SizedBox(height: 14),
                _buildBottomBar(),
                const SizedBox(height: 10),
                _buildCreatorCredit(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Collapse toggle ───────────────────────────────────────────────────────
  Widget _buildCollapseToggle() {
    return GestureDetector(
      onTap: () => setState(() => _footerCollapsed = !_footerCollapsed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_footerCollapsed ? 'Show Footer' : 'Hide Footer',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(width: 6),
          Icon(
            _footerCollapsed
                ? Icons.keyboard_arrow_down_rounded
                : Icons.keyboard_arrow_up_rounded,
            color: Colors.white70,
            size: 16,
          ),
        ]),
      ),
    );
  }

  // ── Brand / college name ──────────────────────────────────────────────────
  Widget _buildBrandSection() {
    return Column(children: [
      // Glowing animated college name
      AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, __) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(_glowAnim.value * 0.5),
                blurRadius: 20 * _glowAnim.value,
                spreadRadius: 2,
              ),
            ],
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
      ),
      const SizedBox(height: 12),
      const Text(
        'BEEDI College, Hajipur, Vaishali, Bihar',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 4),
      // Typing animation tagline
      Text(
        _tagline.substring(0, _typingIndex),
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    ]);
  }

  // ── Smart info bar: clock + visitors + online ─────────────────────────────
  Widget _buildSmartBar(bool isSmall) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 8,
        children: [
          // Live clock
          _SmartChip(
            icon: Icons.access_time_rounded,
            label: '$_timeString · $_dateString',
          ),
          // Visitor counter
          _SmartChip(
            icon: Icons.remove_red_eye_outlined,
            label: '${_visitorCount.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (m) => '${m[1]},',
                )} visitors',
          ),
          // Online indicator
          Row(mainAxisSize: MainAxisSize.min, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isOnline ? Colors.greenAccent : Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isOnline ? Colors.greenAccent : Colors.redAccent)
                        .withOpacity(0.7),
                    blurRadius: 6,
                  )
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: _isOnline ? Colors.greenAccent : Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ── Links grid (large screens) ────────────────────────────────────────────
  Widget _buildLinksGrid() {
    final links = _linkData();
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 4,
      children: links.map((l) => _FL(l.$1, l.$2)).toList(),
    );
  }

  // ── Links wrap (small/medium — original behavior preserved) ───────────────
  Widget _buildLinksWrap(bool isSmall) {
    final links = _linkData();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: isSmall ? 12 : 20,
      runSpacing: 10,
      children: [
        for (final l in links.take(isSmall ? 5 : links.length)) _FL(l.$1, l.$2),
      ],
    );
  }

  // ── Expandable "More Links" ───────────────────────────────────────────────
  Widget _buildMoreLinks(bool isSmall) {
    if (!isSmall) return const SizedBox.shrink();
    return Column(children: [
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () => setState(() => _moreLinksExpanded = !_moreLinksExpanded),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            _moreLinksExpanded ? 'Show Less' : 'More Links',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Icon(
            _moreLinksExpanded
                ? Icons.expand_less_rounded
                : Icons.expand_more_rounded,
            color: Colors.white70,
            size: 16,
          ),
        ]),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: _moreLinksExpanded
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: _linkData()
                      .skip(5)
                      .map((l) => _FL(l.$1, l.$2))
                      .toList(),
                ),
              )
            : const SizedBox.shrink(),
      ),
    ]);
  }

  // ── Social row ────────────────────────────────────────────────────────────
  Widget _buildSocialSection() {
    return Column(children: [
      Text(
        'Follow Us',
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 11,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SocialBtn(Icons.facebook, Colors.white, tooltip: 'Facebook', label: 'Facebook'),
          const SizedBox(width: 10),
          _SocialBtn(Icons.telegram, Colors.white, tooltip: 'Telegram', label: 'Telegram'),
          const SizedBox(width: 10),
          _SocialBtn(Icons.link, Colors.white, tooltip: 'Website', label: 'Website'),
          const SizedBox(width: 10),
          _SocialBtn(Icons.camera_alt, Colors.white, tooltip: 'Instagram', label: 'Instagram'),
          const SizedBox(width: 10),
          _SocialBtn(Icons.play_circle_outline_rounded, Colors.white, tooltip: 'YouTube', label: 'YouTube'),
        ],
      ),
    ]);
  }

  // ── Animated glowing divider ──────────────────────────────────────────────
  Widget _buildAnimatedDivider() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(_glowAnim.value * 0.5),
              Colors.lightBlueAccent.withOpacity(_glowAnim.value * 0.6),
              Colors.white.withOpacity(_glowAnim.value * 0.5),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.lightBlueAccent.withOpacity(_glowAnim.value * 0.4),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom bar: copyright + feedback + back-to-top ────────────────────────
  Widget _buildBottomBar() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        Text(
          '© ${_now.year} BEEDI College. All rights reserved.',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
          textAlign: TextAlign.center,
        ),
        GestureDetector(
          onTap: _showFeedbackDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Text(
              '💬 Feedback',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
        ),
        GestureDetector(
          onTap: _scrollToTop,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.arrow_upward_rounded, color: Colors.white70, size: 11),
              SizedBox(width: 4),
              Text('Top', style: TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Creator credit with fade animation ───────────────────────────────────
  Widget _buildCreatorCredit() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeIn,
      builder: (_, v, child) => Opacity(opacity: v, child: child),
      child: Text(
        'This website is created by G.S World Center and BEEDI College',
        style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 9.5,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  List<(String, VoidCallback)> _linkData() => [
    ('About', () => widget.onNav(const ContactsScreen())),
    ('Admission', () => widget.onNav(const AdmissionScreen())),
    ('Research', () => widget.onNav(const ResearchScreen())),
    ('KYP Quiz', () => widget.onNav(const KYPQuizScreen())),
    ('Careers', () => widget.onNav(const OpportunitiesScreen())),
    ('Contact', () => widget.onNav(const ContactsScreen())),
    ('Job Board', () => widget.onNav(const JobBoardScreen())),
    ('Scholarships', () => widget.onNav(const ScholarshipScreen())),
  ];

  void _scrollToTop() {
    // Scroll controller can be passed in; for now show snackbar as placeholder
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Scrolling to top…'),
      backgroundColor: Color(0xFF1565C0),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 1),
    ));
  }

  void _showFeedbackDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Send Feedback',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('We'd love to hear your thoughts!',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your feedback…',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF1565C0), width: 2),
              ),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Thank you for your feedback! 🙏'),
                backgroundColor: Color(0xFF1565C0),
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: const Text('Submit',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// NEW REUSABLE WIDGETS (same file, no external deps)
// ──────────────────────────────────────────────────────────────────────────────

/// Animated hover + scale footer link (replaces the simple GestureDetector _FL)
class _AnimatedFooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _AnimatedFooterLink({required this.label, required this.onTap});

  @override
  State<_AnimatedFooterLink> createState() => _AnimatedFooterLinkState();
}

class _AnimatedFooterLinkState extends State<_AnimatedFooterLink>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.92 : (_hovered ? 1.08 : 1.0),
            duration: const Duration(milliseconds: 150),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: _hovered ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
                decoration:
                    _hovered ? TextDecoration.underline : TextDecoration.none,
                decorationColor: Colors.white54,
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small chip used in the smart info bar
class _SmartChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SmartChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.white60, size: 13),
      const SizedBox(width: 5),
      Text(label,
          style: const TextStyle(
              color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
    ],
  );
}

// ──────────────────────────────────────────────────────────────────────────────
// PLACEHOLDER SCREENS — replace with your real imports
// ──────────────────────────────────────────────────────────────────────────────
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Contacts')));
}
class AdmissionScreen extends StatelessWidget {
  const AdmissionScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Admission')));
}
class ResearchScreen extends StatelessWidget {
  const ResearchScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Research')));
}
class KYPQuizScreen extends StatelessWidget {
  const KYPQuizScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('KYP Quiz')));
}
class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Opportunities')));
}
class JobBoardScreen extends StatelessWidget {
  const JobBoardScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Job Board')));
}
class ScholarshipScreen extends StatelessWidget {
  const ScholarshipScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Scholarships')));
}