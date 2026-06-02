import 'dart:math';
import 'dart:ui';
import 'package:beedi_college/CALLREPORT/SmartCallingScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Screens/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const BeeediCollegeApp());
}

class BeeediCollegeApp extends StatelessWidget {
  const BeeediCollegeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BEEDI College',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Georgia'),
      home: const SplashScreen(),
      //home: const BeediSmartCallingScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SPLASH SCREEN — Ultra Cinematic Edition
// ═══════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──
  late AnimationController _masterFade;
  late AnimationController _logoEntry;
  late AnimationController _logoFloat;
  late AnimationController _logoRotate;
  late AnimationController _glowPulse;
  late AnimationController _ripple;
  late AnimationController _orbit;
  late AnimationController _aurora;
  late AnimationController _particles;
  late AnimationController _stars;
  late AnimationController _shootingStars;
  late AnimationController _textReveal;
  late AnimationController _shimmer;
  late AnimationController _tagline;
  late AnimationController _sweep;
  late AnimationController _exit;
  late AnimationController _lensFlare;
  late AnimationController _nebula;

  // ── Animations ──
  late Animation<double> _screenFade;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _exitScale;
  late Animation<double> _exitFade;
  late Animation<double> _subtitleFade;
  late Animation<double> _sweepProgress;

  // ── Data ──
  final Random _rng = Random();
  final List<_Particle> _particleList = [];
  final List<_Star> _starList = [];
  final List<_ShootingStar> _shootingStarList = [];
  final List<_OrbitParticle> _orbitList = [];
  final String _title = 'BEEDI College';
  bool _exitStarted = false;

  // ── Colors ──
  static const Color _gold = Color(0xFFFFD700);
  static const Color _luxGold = Color(0xFFFFC107);
  static const Color _cyan = Color(0xFF00BFFF);
  static const Color _emerald = Color(0xFF00E676);
  static const Color _navy = Color(0xFF001D3D);
  static const Color _space = Color(0xFF000814);

  @override
  void initState() {
    super.initState();
    _buildParticles();
    _buildStars();
    _buildShootingStars();
    _buildOrbitParticles();
    _initControllers();
    _schedule();
  }

  // ── Build Data ──
  void _buildParticles() {
    final colors = [
      _cyan,
      _emerald,
      _gold,
      _luxGold,
      const Color(0xFF80FFEA),
      const Color(0xFFFFF176),
      Colors.white,
    ];
    for (int i = 0; i < 80; i++) {
      _particleList.add(
        _Particle(
          x: 0.02 + _rng.nextDouble() * 0.96,
          startY: 0.50 + _rng.nextDouble() * 0.50,
          size: 1.5 + _rng.nextDouble() * 4.5,
          speed: 0.20 + _rng.nextDouble() * 0.60,
          phase: _rng.nextDouble(),
          sway: 10 + _rng.nextDouble() * 22,
          color: colors[i % colors.length],
        ),
      );
    }
  }

  void _buildStars() {
    for (int i = 0; i < 120; i++) {
      _starList.add(
        _Star(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          size: 0.8 + _rng.nextDouble() * 2.5,
          phase: _rng.nextDouble(),
          gold: _rng.nextDouble() < 0.25,
        ),
      );
    }
  }

  void _buildShootingStars() {
    for (int i = 0; i < 4; i++) {
      _shootingStarList.add(
        _ShootingStar(
          startX: _rng.nextDouble() * 0.6,
          startY: _rng.nextDouble() * 0.4,
          angle: pi / 5 + _rng.nextDouble() * pi / 8,
          length: 80 + _rng.nextDouble() * 120,
          speed: 0.18 + _rng.nextDouble() * 0.25,
          delay: _rng.nextDouble(),
        ),
      );
    }
  }

  void _buildOrbitParticles() {
    for (int i = 0; i < 12; i++) {
      _orbitList.add(
        _OrbitParticle(
          angleOffset: (i / 12) * 2 * pi,
          radius: 0.54 + (i % 3) * 0.08,
          size: 2.5 + _rng.nextDouble() * 3.5,
          speed: 0.6 + _rng.nextDouble() * 0.8,
          color: i % 3 == 0
              ? _gold
              : i % 3 == 1
              ? _cyan
              : _emerald,
        ),
      );
    }
  }

  void _initControllers() {
    // Master fade
    _masterFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _screenFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _masterFade, curve: Curves.easeIn));

    // Logo entry (cinematic scale 0.0→1.0 with easeOutBack)
    _logoEntry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoEntry, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoEntry,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // Float breathe — looping sine ±8px
    _logoFloat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // Slow elegant rotation
    _logoRotate = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Glow pulse breathe
    _glowPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Ripple shockwave rings
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Orbit particles around logo
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // Aurora background motion
    _aurora = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Floating particles
    _particles = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    // Stars twinkle
    _stars = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Shooting stars
    _shootingStars = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Text reveal — letter by letter
    _textReveal = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + _title.length * 80),
    );

    // Shimmer on title
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    // Tagline fade
    _tagline = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _subtitleFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _tagline, curve: Curves.easeIn));

    // Light sweep
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _sweepProgress = Tween<double>(
      begin: -0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _sweep, curve: Curves.easeInOut));

    // Lens flare pulse
    _lensFlare = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    // Nebula drift
    _nebula = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    // Exit
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitScale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _exit, curve: Curves.easeInCubic));
    _exitFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _exit, curve: Curves.easeInCubic));

    // Trigger sweep after logo entry
    _logoEntry.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _sweep.forward();
      }
    });
  }

  void _schedule() {
    _masterFade.forward();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _logoEntry.forward();
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _textReveal.forward();
    });
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) _tagline.forward();
    });
    Future.delayed(const Duration(milliseconds: 4800), () {
      if (mounted && !_exitStarted) {
        _exitStarted = true;
        _exit.forward().then((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionDuration: const Duration(milliseconds: 700),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    for (final c in [
      _masterFade,
      _logoEntry,
      _logoFloat,
      _logoRotate,
      _glowPulse,
      _ripple,
      _orbit,
      _aurora,
      _particles,
      _stars,
      _shootingStars,
      _textReveal,
      _shimmer,
      _tagline,
      _sweep,
      _exit,
      _lensFlare,
      _nebula,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Per-letter helpers ──
  Animation<double> _letterOpacity(int i) {
    final s = (i / _title.length) * 0.70;
    final e = (s + 0.30).clamp(0.0, 1.0);
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textReveal,
        curve: Interval(s, e, curve: Curves.easeOutCubic),
      ),
    );
  }

  Animation<Offset> _letterSlide(int i) {
    final s = (i / _title.length) * 0.70;
    final e = (s + 0.30).clamp(0.0, 1.0);
    return Tween<Offset>(begin: const Offset(0, 0.7), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _textReveal,
        curve: Interval(s, e, curve: Curves.easeOutBack),
      ),
    );
  }

  Animation<double> _letterScale(int i) {
    final s = (i / _title.length) * 0.70;
    final e = (s + 0.30).clamp(0.0, 1.0);
    return Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _textReveal,
        curve: Interval(s, e, curve: Curves.easeOutBack),
      ),
    );
  }

  double _fs(double w, double sm, double md, double lg) {
    if (w < 360) return sm;
    if (w < 500) return md;
    return lg;
  }

  // ══════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final W = constraints.maxWidth;
        final H = constraints.maxHeight;
        final logoSize = (W * 0.42).clamp(110.0, 230.0);
        final sz = Size(W, H);

        return AnimatedBuilder(
          animation: Listenable.merge([_masterFade, _exit]),
          builder: (_, __) => Opacity(
            opacity: (_screenFade.value * _exitFade.value).clamp(0.0, 1.0),
            child: Scaffold(
              backgroundColor: _space,
              body: SizedBox.expand(
                child: Stack(
                  children: [
                    // ── 1. Deep space gradient ──
                    AnimatedBuilder(
                      animation: _aurora,
                      builder: (_, __) => CustomPaint(
                        painter: _BackgroundPainter(
                          aurora: _aurora.value,
                          nebula: _nebula.value,
                        ),
                        size: sz,
                      ),
                    ),

                    // ── 2. Star field (120 stars, golden + white) ──
                    AnimatedBuilder(
                      animation: _stars,
                      builder: (_, __) => CustomPaint(
                        painter: _StarPainter(
                          stars: _starList,
                          t: _stars.value,
                        ),
                        size: sz,
                      ),
                    ),

                    // ── 3. Shooting stars ──
                    AnimatedBuilder(
                      animation: _shootingStars,
                      builder: (_, __) => CustomPaint(
                        painter: _ShootingStarPainter(
                          stars: _shootingStarList,
                          t: _shootingStars.value,
                        ),
                        size: sz,
                      ),
                    ),

                    // ── 4. Light streaks (vertical) ──
                    ..._buildStreaks(sz),

                    // ── 5. Floating particles ──
                    AnimatedBuilder(
                      animation: _particles,
                      builder: (_, __) => CustomPaint(
                        painter: _ParticlePainter(
                          particles: _particleList,
                          t: _particles.value,
                        ),
                        size: sz,
                      ),
                    ),

                    // ── 6. Lens flare top-right ──
                    AnimatedBuilder(
                      animation: _lensFlare,
                      builder: (_, __) => Positioned(
                        top: H * 0.05,
                        right: W * 0.08,
                        child: Opacity(
                          opacity: 0.15 + _lensFlare.value * 0.25,
                          child: _LensFlare(size: W * 0.55),
                        ),
                      ),
                    ),

                    // ── 7. Main content ──
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Logo cluster ──
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              _logoEntry,
                              _logoFloat,
                              _logoRotate,
                              _glowPulse,
                              _ripple,
                              _orbit,
                              _sweep,
                              _exit,
                            ]),
                            builder: (_, __) {
                              final floatDy =
                                  sin(_logoFloat.value * 2 * pi) * 8.0;
                              final scale = _logoScale.value * _exitScale.value;

                              return Transform.translate(
                                offset: Offset(0, floatDy),
                                child: Transform.scale(
                                  scale: scale,
                                  child: SizedBox(
                                    width: logoSize + 80,
                                    height: logoSize + 80,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Outer aurora halo
                                        _AuroraHalo(
                                          size: logoSize + 70,
                                          glowV: _glowPulse.value,
                                          opacity: _logoOpacity.value,
                                        ),

                                        // Ripple rings (3)
                                        ..._buildRipples(logoSize),

                                        // Orbit particles
                                        ..._buildOrbitWidgets(logoSize),

                                        // Glow energy disc
                                        _GlowDisc(
                                          size: logoSize,
                                          v: _glowPulse.value,
                                          opacity: _logoOpacity.value,
                                        ),

                                        // Logo container
                                        Opacity(
                                          opacity: _logoOpacity.value,
                                          child: _LogoContainer(
                                            size: logoSize,
                                            rotation:
                                                _logoRotate.value *
                                                2 *
                                                pi *
                                                0.03,
                                            sweepProgress: _sweepProgress.value,
                                          ),
                                        ),

                                        // Spark burst (entry)
                                        if (_logoEntry.value > 0.7 &&
                                            _logoEntry.value < 1.0)
                                          CustomPaint(
                                            painter: _SparkBurstPainter(
                                              t: (_logoEntry.value - 0.7) / 0.3,
                                            ),
                                            size: Size(
                                              logoSize + 80,
                                              logoSize + 80,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: H * 0.04),

                          // ── Title ──
                          AnimatedBuilder(
                            animation: Listenable.merge([
                              _textReveal,
                              _shimmer,
                              _logoFloat,
                            ]),
                            builder: (_, __) {
                              final floatDy =
                                  sin(_logoFloat.value * 2 * pi) * 2.5;
                              return Transform.translate(
                                offset: Offset(0, floatDy),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(_title.length, (
                                        i,
                                      ) {
                                        final ch = _title[i];
                                        return FadeTransition(
                                          opacity: _letterOpacity(i),
                                          child: SlideTransition(
                                            position: _letterSlide(i),
                                            child: ScaleTransition(
                                              scale: _letterScale(i),
                                              child: ShaderMask(
                                                shaderCallback: (bounds) {
                                                  final shimX =
                                                      _shimmer.value *
                                                          bounds.width *
                                                          3 -
                                                      bounds.width;
                                                  return LinearGradient(
                                                    colors: const [
                                                      Color(0xFFFFD700),
                                                      Color(0xFFFFF8DC),
                                                      Color(0xFFFFD700),
                                                      Color(0xFFFFC107),
                                                      Color(0xFFFFFFFF),
                                                      Color(0xFFFFD700),
                                                    ],
                                                    stops: const [
                                                      0.0,
                                                      0.15,
                                                      0.35,
                                                      0.60,
                                                      0.75,
                                                      1.0,
                                                    ],
                                                  ).createShader(
                                                    Rect.fromLTWH(
                                                      shimX,
                                                      0,
                                                      bounds.width * 3,
                                                      bounds.height,
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  ch == ' ' ? '\u00A0' : ch,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: _fs(
                                                      W,
                                                      26,
                                                      30,
                                                      36,
                                                    ),
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 2.0,
                                                    fontFamily: 'Georgia',
                                                    shadows: [
                                                      Shadow(
                                                        color: _gold
                                                            .withOpacity(0.8),
                                                        blurRadius: 18,
                                                      ),
                                                      Shadow(
                                                        color: _cyan
                                                            .withOpacity(0.4),
                                                        blurRadius: 30,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),

                                    const SizedBox(height: 5),

                                    // Tagline 1 — "Dream • Learn • Achieve"
                                    ShaderMask(
                                      shaderCallback: (bounds) {
                                        final x =
                                            _shimmer.value * bounds.width * 2 -
                                            bounds.width;
                                        return LinearGradient(
                                          colors: [
                                            _cyan,
                                            Colors.white,
                                            _emerald,
                                            Colors.white,
                                            _gold,
                                          ],
                                          stops: const [
                                            0.0,
                                            0.25,
                                            0.5,
                                            0.75,
                                            1.0,
                                          ],
                                        ).createShader(
                                          Rect.fromLTWH(
                                            x,
                                            0,
                                            bounds.width * 2,
                                            bounds.height,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'D R E A M  •  L E A R N  •  A C H I E V E',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: _fs(W, 7, 8, 9),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 3.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          SizedBox(height: H * 0.025),

                          // ── Subtitle section ──
                          AnimatedBuilder(
                            animation: _tagline,
                            builder: (_, __) => Opacity(
                              opacity: _subtitleFade.value,
                              child: Column(
                                children: [
                                  // Ornamental divider
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _OrnateDivider(width: 60),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Icon(
                                          Icons.auto_awesome_rounded,
                                          size: 14,
                                          color: _gold,
                                        ),
                                      ),
                                      _OrnateDivider(width: 60, reverse: true),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    '"Education is the Key"',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFFCCEEFF,
                                      ).withOpacity(0.85),
                                      fontSize: _fs(W, 13, 15, 17),
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.8,
                                      fontFamily: 'Georgia',
                                      shadows: [
                                        Shadow(
                                          color: _cyan.withOpacity(0.55),
                                          blurRadius: 16,
                                        ),
                                        Shadow(
                                          color: _gold.withOpacity(0.25),
                                          blurRadius: 30,
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
                    ),

                    // ── Bottom brand strip ──
                    Positioned(
                      bottom: 28,
                      left: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: _tagline,
                        builder: (_, __) => Opacity(
                          opacity: _subtitleFade.value,
                          child: Text(
                            'Est. 2024  ·  Powered by Intelligence & Dreams',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.22),
                              fontSize: 9,
                              letterSpacing: 3.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Ripple rings ──
  List<Widget> _buildRipples(double logoSize) {
    const rippleColors = [_cyan, _gold, _emerald];
    final widths = [1.8, 1.2, 0.8];
    return List.generate(3, (i) {
      final offset = i / 3.0;
      final t = ((_ripple.value + offset) % 1.0);
      final scale = t;
      final opacity = (1.0 - t).clamp(0.0, 0.6) * _logoOpacity.value;
      return Opacity(
        opacity: opacity,
        child: Container(
          width: scale * (logoSize + 80),
          height: scale * (logoSize + 80),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: rippleColors[i], width: widths[i]),
          ),
        ),
      );
    });
  }

  // ── Orbit particles ──
  List<Widget> _buildOrbitWidgets(double logoSize) {
    return _orbitList.map((op) {
      final angle = op.angleOffset + _orbit.value * 2 * pi * op.speed;
      final r = logoSize * op.radius;
      final dx = cos(angle) * r;
      final dy = sin(angle) * r * 0.5; // ellipse
      return Transform.translate(
        offset: Offset(dx, dy),
        child: Opacity(
          opacity: _logoOpacity.value * (0.6 + sin(angle) * 0.4).abs(),
          child: Container(
            width: op.size,
            height: op.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: op.color,
              boxShadow: [
                BoxShadow(
                  color: op.color.withOpacity(0.8),
                  blurRadius: op.size * 2,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // ── Vertical light streaks ──
  List<Widget> _buildStreaks(Size sz) {
    return List.generate(
      14,
      (i) => _LightStreak(index: i, screenSize: sz, seed: i * 137),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PAINTERS
// ══════════════════════════════════════════════════════════════

// ── Background — nebula + aurora ──
class _BackgroundPainter extends CustomPainter {
  final double aurora;
  final double nebula;
  const _BackgroundPainter({required this.aurora, required this.nebula});

  @override
  void paint(Canvas canvas, Size size) {
    // Base space gradient
    final bg = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.3 + aurora * 0.2, -0.4),
        radius: 1.4,
        colors: const [Color(0xFF001D3D), Color(0xFF000E22), Color(0xFF000814)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // Aurora streaks
    _drawAurora(canvas, size, aurora);

    // Nebula glow clouds
    _drawNebula(canvas, size, nebula, aurora);
  }

  void _drawAurora(Canvas canvas, Size size, double t) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Cyan aurora
    paint.shader = RadialGradient(
      center: Alignment(-0.8 + t * 0.6, -0.5 + sin(t * pi) * 0.2),
      radius: 0.9,
      colors: [const Color(0xFF00BFFF).withOpacity(0.06), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Gold aurora
    paint.shader = RadialGradient(
      center: Alignment(0.8 - t * 0.4, 0.6),
      radius: 0.75,
      colors: [const Color(0xFFFFD700).withOpacity(0.05), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Emerald aurora
    paint.shader = RadialGradient(
      center: Alignment(0.2 + sin(t * pi) * 0.3, -0.8),
      radius: 0.6,
      colors: [const Color(0xFF00E676).withOpacity(0.04), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawNebula(Canvas canvas, Size size, double t, double aurora) {
    final paint = Paint()..style = PaintingStyle.fill;
    // Soft nebula blob — purple-ish
    paint.shader = RadialGradient(
      center: Alignment(0.3 + t * 0.1, 0.2 + aurora * 0.1),
      radius: 0.55,
      colors: [const Color(0xFF4400AA).withOpacity(0.07), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) =>
      old.aurora != aurora || old.nebula != nebula;
}

// ── Stars ──
class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  const _StarPainter({required this.stars, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle = (sin((t + s.phase) * 2 * pi) + 1) / 2;
      final opacity = s.gold ? 0.35 + twinkle * 0.65 : 0.10 + twinkle * 0.55;
      final color = s.gold
          ? Color.lerp(const Color(0xFFFFD700), Colors.white, twinkle * 0.5)!
          : Colors.white;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size * 0.5,
        paint,
      );

      // Gold star glow
      if (s.gold && twinkle > 0.6) {
        canvas.drawCircle(
          Offset(s.x * size.width, s.y * size.height),
          s.size * 1.5,
          Paint()
            ..color = const Color(0xFFFFD700).withOpacity(twinkle * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.t != t;
}

// ── Shooting stars ──
class _ShootingStarPainter extends CustomPainter {
  final List<_ShootingStar> stars;
  final double t;
  const _ShootingStarPainter({required this.stars, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final localT = ((t + s.delay) * s.speed) % 1.0;
      if (localT > 0.35) continue; // only visible during the shoot
      final visibility = localT < 0.28 ? localT / 0.28 : (0.35 - localT) / 0.07;

      final startX =
          s.startX * size.width + cos(s.angle) * localT * size.width * 1.5;
      final startY =
          s.startY * size.height + sin(s.angle) * localT * size.height * 1.5;
      final endX = startX - cos(s.angle) * s.length;
      final endY = startY - sin(s.angle) * s.length;

      final paint = Paint()
        ..shader =
            LinearGradient(
              colors: [
                Colors.white.withOpacity(visibility),
                Colors.white.withOpacity(0),
              ],
            ).createShader(
              Rect.fromPoints(Offset(startX, startY), Offset(endX, endY)),
            )
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(_ShootingStarPainter old) => old.t != t;
}

// ── Particles ──
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  const _ParticlePainter({required this.particles, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final pt = (t * p.speed + p.phase) % 1.0;
      final dx = p.x * size.width + sin(pt * 2 * pi + p.phase * pi) * p.sway;
      final dy = (p.startY - pt * 0.95) * size.height;
      if (dy < -p.size || dy > size.height + p.size) continue;

      final fade = pt < 0.12
          ? (pt / 0.12) * 0.85
          : pt > 0.70
          ? ((1 - pt) / 0.30) * 0.85
          : 0.85;

      // Glow ring
      canvas.drawCircle(
        Offset(dx, dy),
        p.size * 1.6,
        Paint()
          ..color = p.color.withOpacity(fade * 0.20)
          ..style = PaintingStyle.fill,
      );
      // Core
      canvas.drawCircle(
        Offset(dx, dy),
        p.size * 0.45,
        Paint()
          ..color = p.color.withOpacity(fade)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

// ── Spark burst (logo entry) ──
class _SparkBurstPainter extends CustomPainter {
  final double t;
  const _SparkBurstPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = t * size.width * 0.55;
    final sparkCount = 16;

    for (int i = 0; i < sparkCount; i++) {
      final angle = (i / sparkCount) * 2 * pi;
      final sparkLen = (20 + (i % 4) * 12) * t;
      final opacity = (1 - t).clamp(0.0, 1.0);
      final color = i % 3 == 0
          ? const Color(0xFFFFD700)
          : i % 3 == 1
          ? const Color(0xFF00BFFF)
          : const Color(0xFF00E676);

      canvas.drawLine(
        Offset(cx + cos(angle) * r, cy + sin(angle) * r),
        Offset(
          cx + cos(angle) * (r + sparkLen),
          cy + sin(angle) * (r + sparkLen),
        ),
        Paint()
          ..color = color.withOpacity(opacity)
          ..strokeWidth = 1.5 + (1 - t) * 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_SparkBurstPainter old) => old.t != t;
}

// ── Sweep painter (light reflection) ──
class _SweepPainter extends CustomPainter {
  final double progress;
  const _SweepPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= -0.1 || progress >= 1.1) return;
    final sx = progress * size.width * 1.8 - size.width * 0.4;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.45),
          Colors.white.withOpacity(0.65),
          Colors.white.withOpacity(0.45),
          Colors.white.withOpacity(0.0),
          Colors.transparent,
        ],
        stops: const [0.0, 0.30, 0.44, 0.50, 0.56, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(sx - 70, 0, 140, size.height));

    final path = Path()
      ..moveTo(sx - 50, 0)
      ..lineTo(sx + 50, 0)
      ..lineTo(sx + 25, size.height)
      ..lineTo(sx - 75, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SweepPainter old) => old.progress != progress;
}

// ══════════════════════════════════════════════════════════════
//  WIDGETS
// ══════════════════════════════════════════════════════════════

// ── Aurora halo behind logo ──
class _AuroraHalo extends StatelessWidget {
  final double size, glowV, opacity;
  const _AuroraHalo({
    required this.size,
    required this.glowV,
    required this.opacity,
  });
  @override
  Widget build(BuildContext context) {
    final pulse = 0.92 + glowV * 0.16;
    return Transform.scale(
      scale: pulse,
      child: Opacity(
        opacity: opacity * (0.5 + glowV * 0.5),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFFD700).withOpacity(0.22),
                const Color(0xFF00BFFF).withOpacity(0.18),
                const Color(0xFF00E676).withOpacity(0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.35, 0.65, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 60,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: const Color(0xFF00BFFF).withOpacity(0.25),
                blurRadius: 80,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.15),
                blurRadius: 100,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Glow energy disc ──
class _GlowDisc extends StatelessWidget {
  final double size, v, opacity;
  const _GlowDisc({required this.size, required this.v, required this.opacity});
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity * (0.4 + v * 0.6),
      child: Container(
        width: size + 14,
        height: size + 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF00BFFF).withOpacity(0.28),
              const Color(0xFFFFD700).withOpacity(0.18),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

// ── Logo container ──
class _LogoContainer extends StatelessWidget {
  final double size, rotation, sweepProgress;
  const _LogoContainer({
    required this.size,
    required this.rotation,
    required this.sweepProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF003875), Color(0xFF001D3D), Color(0xFF000A1E)],
          ),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.35),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.40),
              blurRadius: 30,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: const Color(0xFF00BFFF).withOpacity(0.50),
              blurRadius: 50,
              spreadRadius: 6,
            ),
            BoxShadow(
              color: const Color(0xFF00E676).withOpacity(0.20),
              blurRadius: 70,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: ClipOval(
          child: Stack(
            children: [
              Image.asset(
                'assets/Logoes/Logo.png',
                fit: BoxFit.contain,
                width: size,
                height: size,
                errorBuilder: (_, __, ___) => const _FallbackLogo(),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _SweepPainter(progress: sweepProgress),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Lens flare ──
class _LensFlare extends StatelessWidget {
  final double size;
  const _LensFlare({required this.size});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFD700).withOpacity(0.25),
                  const Color(0xFF00BFFF).withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Cross flare lines
          Container(
            width: size * 0.6,
            height: 1,
            color: const Color(0xFFFFFFFF).withOpacity(0.12),
          ),
          Container(
            width: 1,
            height: size * 0.6,
            color: const Color(0xFFFFFFFF).withOpacity(0.12),
          ),
        ],
      ),
    );
  }
}

// ── Ornate divider ──
class _OrnateDivider extends StatelessWidget {
  final double width;
  final bool reverse;
  const _OrnateDivider({required this.width, this.reverse = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reverse
              ? [const Color(0xFF00E676).withOpacity(0.6), Colors.transparent]
              : [Colors.transparent, const Color(0xFFFFD700).withOpacity(0.7)],
        ),
      ),
    );
  }
}

// ── Light streak widget ──
class _LightStreak extends StatefulWidget {
  final int index, seed;
  final Size screenSize;
  const _LightStreak({
    required this.index,
    required this.screenSize,
    required this.seed,
  });
  @override
  State<_LightStreak> createState() => _LightStreakState();
}

class _LightStreakState extends State<_LightStreak>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late double _x, _h;
  final Random _rng = Random();

  static const _colors = [
    Color(0xFF00BFFF),
    Color(0xFFFFD700),
    Color(0xFF00E676),
    Color(0xFFFFC107),
  ];

  @override
  void initState() {
    super.initState();
    _rng.nextInt(100); // advance
    _x = 0.02 + _rng.nextDouble() * 0.96;
    _h = 60 + _rng.nextDouble() * 150;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2800 + _rng.nextInt(3500)),
    );
    final delay = (_rng.nextDouble() * 4000).toInt();
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _colors[widget.index % _colors.length];
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final dy = -_h + t * (widget.screenSize.height + _h * 2.2);
        final opacity = t < 0.10
            ? t / 0.10
            : t > 0.85
            ? (1 - t) / 0.15
            : 0.50;
        return Positioned(
          left: _x * widget.screenSize.width,
          top: dy,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              width: 1.2,
              height: _h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    color.withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Fallback logo ──
class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.menu_book_rounded,
          size: 48,
          color: Colors.white.withOpacity(0.92),
        ),
        Positioned(
          top: 4,
          right: 6,
          child: Icon(
            Icons.language,
            size: 26,
            color: const Color(0xFF00BFFF).withOpacity(0.8),
          ),
        ),
        Positioned(
          bottom: 6,
          left: 8,
          child: Icon(
            Icons.star_rounded,
            size: 18,
            color: const Color(0xFFFFD700).withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DATA MODELS
// ══════════════════════════════════════════════════════════════
class _Particle {
  final double x, startY, size, speed, phase, sway;
  final Color color;
  const _Particle({
    required this.x,
    required this.startY,
    required this.size,
    required this.speed,
    required this.phase,
    required this.sway,
    required this.color,
  });
}

class _Star {
  final double x, y, size, phase;
  final bool gold;
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.gold,
  });
}

class _ShootingStar {
  final double startX, startY, angle, length, speed, delay;
  const _ShootingStar({
    required this.startX,
    required this.startY,
    required this.angle,
    required this.length,
    required this.speed,
    required this.delay,
  });
}

class _OrbitParticle {
  final double angleOffset, radius, size, speed;
  final Color color;
  const _OrbitParticle({
    required this.angleOffset,
    required this.radius,
    required this.size,
    required this.speed,
    required this.color,
  });
}
