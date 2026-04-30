import 'dart:math';
import 'package:beedi_college/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint(
      'Firebase initialized successfully',
    );
  } catch (e) {
    debugPrint(
      'Firebase initialization error: $e',
    );
  }
  runApp(
    const BeeediCollegeApp(),
  );
}

class BeeediCollegeApp extends StatelessWidget {
  const BeeediCollegeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BEEDI College',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  SPLASH SCREEN
// ─────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Screen-wide fade-in from black ──
  late AnimationController _screenFadeController;
  late Animation<double> _screenFade;

  // ── Logo: scale (easeOutBack 0.6→1.0) + opacity ──
  late AnimationController _logoEntryController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;

  // ── Floating breathe (sine ±6px, looping) ──
  late AnimationController _floatController;
  late Animation<double> _floatOffset;

  // ── Exit: scale 1.0→1.2 + fade out ──
  late AnimationController _exitController;
  late Animation<double> _exitScale;
  late Animation<double> _exitFade;

  // ── Glow pulse behind logo ──
  late AnimationController _glowController;
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;

  // ── Ripple rings ──
  late AnimationController _rippleController;
  late Animation<double> _ripple1;
  late Animation<double> _ripple2;

  // ── Light sweep (left→right once) ──
  late AnimationController _sweepController;
  late Animation<double> _sweepProgress;

  // ── Letter-by-letter title ──
  late AnimationController _lettersController;
  final String _titleText = 'BEEDI College';

  // ── Shimmer on title ──
  late AnimationController _shimmerController;

  // ── Subtitle fade ──
  late AnimationController _subtitleController;
  late Animation<double> _subtitleOpacity;

  // ── Particles (30–50, native ticker) ──
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  // ── Star twinkles ──
  late AnimationController _twinkleController;
  final List<_StarTwinkle> _stars = [];

  bool _exitStarted = false;

  @override
  void initState() {
    super.initState();
    _generateParticles();
    _generateStars();
    _initAnimations();
    _scheduleSequence();
  }

  // ── Generate 40 particles: light-blue / soft-green / golden ──
  void _generateParticles() {
    const particleColors = [
      Color(0xFF00BFFF), // light blue
      Color(0xFF00E676), // soft green
      Color(0xFFFFD700), // golden yellow
      Color(0xFF80FFEA), // cyan accent
      Color(0xFFFFF176), // pale gold
    ];
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        x: 0.03 + _rng.nextDouble() * 0.94,
        startY: 0.55 + _rng.nextDouble() * 0.45,
        size: 2.0 + _rng.nextDouble() * 4.0,
        speed: 0.25 + _rng.nextDouble() * 0.55,
        phase: _rng.nextDouble(),
        color: particleColors[i % particleColors.length],
      ));
    }
  }

  void _generateStars() {
    for (int i = 0; i < 24; i++) {
      _stars.add(_StarTwinkle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble() * 0.6,
        size: 1.2 + _rng.nextDouble() * 2.2,
        phase: _rng.nextDouble(),
      ));
    }
  }

  void _initAnimations() {
    // 1. Full-screen fade from black
    _screenFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _screenFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _screenFadeController, curve: Curves.easeIn),
    );

    // 2. Logo entry — scale 0.6→1.0 easeOutBack, opacity 0→1
    _logoEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoEntryController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoEntryController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );
    _logoRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(parent: _logoEntryController, curve: Curves.easeOutCubic),
    );

    // 3. Floating breathe — looping sine ±6px
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _floatOffset = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.linear),
    );

    // 4. Exit sequence — scale 1.0→1.2 + fade 1→0
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    // 5. Glow pulse breathing
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowScale = Tween<double>(begin: 0.85, end: 1.3).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowOpacity = Tween<double>(begin: 0.35, end: 0.80).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 6. Ripple rings — energy-wave sine pulse
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _ripple1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _ripple2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // 7. Light sweep — diagonal stripe left→right once
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _sweepProgress = Tween<double>(begin: -0.4, end: 1.4).animate(
      CurvedAnimation(parent: _sweepController, curve: Curves.easeInOut),
    );

    // 8. Letter-by-letter title
    _lettersController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200 + _titleText.length * 70),
    );

    // 9. Shimmer sweep on title
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 10. Subtitle fade
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );

    // 11. Particles — native ticker refresh rate
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 12. Star twinkle
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Listen for exit on logo entry complete
    _logoEntryController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _sweepController.forward();
      }
    });
  }

  void _scheduleSequence() {
    // Screen fade starts immediately
    _screenFadeController.forward();

    // Logo entry after screen fade
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoEntryController.forward();
    });

    // Title letters after logo
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _lettersController.forward();
    });

    // Subtitle after title
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _subtitleController.forward();
    });

    // Exit after 4 seconds total
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted && !_exitStarted) {
        _exitStarted = true;
        _exitController.forward().then((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _screenFadeController.dispose();
    _logoEntryController.dispose();
    _floatController.dispose();
    _exitController.dispose();
    _glowController.dispose();
    _rippleController.dispose();
    _sweepController.dispose();
    _lettersController.dispose();
    _shimmerController.dispose();
    _subtitleController.dispose();
    _particleController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  // ── Letter animation helper ──
  Animation<double> _letterOpacity(int index) {
    final start = (index / _titleText.length) * 0.75;
    final end = start + 0.25;
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _lettersController,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );
  }

  Animation<Offset> _letterSlide(int index) {
    final start = (index / _titleText.length) * 0.75;
    final end = start + 0.25;
    return Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _lettersController,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        // Responsive logo size
        final logoSize = (maxW * 0.45).clamp(100.0, 220.0);
        final size = Size(maxW, maxH);

        return AnimatedBuilder(
          animation: Listenable.merge([_screenFadeController, _exitController]),
          builder: (_, __) {
            return Opacity(
              opacity: (_screenFade.value * _exitFade.value).clamp(0.0, 1.0),
              child: Scaffold(
                backgroundColor: Colors.black,
                body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.2, -0.35),
                      radius: 1.25,
                      colors: [
                        Color(0xFF001A33), // dark blue-navy center
                        Color(0xFF000D1A),
                        Color(0xFF000005), // near-black edge
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // ── Layer 1: Star field ──
                      AnimatedBuilder(
                        animation: _twinkleController,
                        builder: (_, __) => CustomPaint(
                          painter: _StarFieldPainter(
                            stars: _stars,
                            progress: _twinkleController.value,
                          ),
                          size: size,
                        ),
                      ),

                      // ── Layer 2: Light streaks ──
                      ...List.generate(10, (i) =>
                          _LightStreak(index: i, screenSize: size)),

                      // ── Layer 3: Particles (30–50 glowing, native tick) ──
                      AnimatedBuilder(
                        animation: _particleController,
                        builder: (_, __) => CustomPaint(
                          painter: _ParticlePainter(
                            particles: _particles,
                            progress: _particleController.value,
                          ),
                          size: size,
                        ),
                      ),

                      // ── Layer 4: Main content ──
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ── Logo section ──
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _logoEntryController,
                                _floatController,
                                _glowController,
                                _rippleController,
                                _sweepController,
                                _exitController,
                              ]),
                              builder: (_, __) {
                                // Breathing float: sine ±6 px
                                final floatDy = sin(_floatOffset.value * 2 * pi) * 6.0;
                                // Exit scale multiplier
                                final combinedScale = _logoScale.value * _exitScale.value;

                                return Transform.translate(
                                  offset: Offset(0, floatDy),
                                  child: Transform.scale(
                                    scale: combinedScale,
                                    child: SizedBox(
                                      width: logoSize + 40,
                                      height: logoSize + 40,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Radial energy-wave (sine-pulse 0.95→1.05)
                                          _EnergyWave(
                                            logoSize: logoSize,
                                            glowScale: _glowScale.value,
                                            glowOpacity: _glowOpacity.value *
                                                _logoOpacity.value,
                                          ),

                                          // Ripple ring 1
                                          Opacity(
                                            opacity: (1.0 - _ripple1.value)
                                                .clamp(0.0, 0.65) *
                                                _logoOpacity.value,
                                            child: Container(
                                              width: _ripple1.value * (logoSize + 50),
                                              height: _ripple1.value * (logoSize + 50),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(0xFF00BFFF),
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Ripple ring 2
                                          Opacity(
                                            opacity: (1.0 - _ripple2.value)
                                                .clamp(0.0, 0.5) *
                                                _logoOpacity.value,
                                            child: Container(
                                              width: _ripple2.value * (logoSize + 30),
                                              height: _ripple2.value * (logoSize + 30),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(0xFF00E676),
                                                  width: 1.0,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Logo image + light-sweep ShaderMask
                                          Opacity(
                                            opacity: _logoOpacity.value,
                                            child: Transform.rotate(
                                              angle: _logoRotation.value,
                                              child: Container(
                                                width: logoSize,
                                                height: logoSize,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: const LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Color(0xFF003366),
                                                      Color(0xFF001A44),
                                                      Color(0xFF000A22),
                                                    ],
                                                  ),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.18),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFF00BFFF)
                                                          .withOpacity(0.45),
                                                      blurRadius: 40,
                                                      spreadRadius: 6,
                                                    ),
                                                    BoxShadow(
                                                      color: const Color(0xFF00E676)
                                                          .withOpacity(0.2),
                                                      blurRadius: 60,
                                                      spreadRadius: 2,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.5),
                                                      blurRadius: 20,
                                                      offset: const Offset(0, 8),
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.all(14),
                                                // Light-sweep ShaderMask overlay
                                                child: ClipOval(
                                                  child: Stack(
                                                    children: [
                                                      Image.asset(
                                                        'assets/Logoes/Logo.png',
                                                        fit: BoxFit.contain,
                                                        width: logoSize,
                                                        height: logoSize,
                                                        errorBuilder: (_, __, ___) =>
                                                        const _FallbackLogoIcon(),
                                                      ),
                                                      // Diagonal gloss sweep
                                                      Positioned.fill(
                                                        child: CustomPaint(
                                                          painter: _SweepPainter(
                                                            progress: _sweepProgress.value,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: maxH * 0.04),

                            // ── Letter-by-letter title with gradient ShaderMask ──
                            AnimatedBuilder(
                              animation: Listenable.merge(
                                  [_lettersController, _shimmerController]),
                              builder: (_, __) {
                                return Column(
                                  children: [
                                    // Letter-by-letter row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        _titleText.length,
                                        (index) {
                                          final char = _titleText[index];
                                          return FadeTransition(
                                            opacity: _letterOpacity(index),
                                            child: SlideTransition(
                                              position: _letterSlide(index),
                                              child: ShaderMask(
                                                shaderCallback: (bounds) {
                                                  // Blue→Green→Yellow gradient per letter
                                                  return const LinearGradient(
                                                    colors: [
                                                      Color(0xFF1565C0),
                                                      Color(0xFF2E7D32),
                                                      Color(0xFFF9A825),
                                                    ],
                                                  ).createShader(Rect.fromLTWH(
                                                    0, 0,
                                                    bounds.width,
                                                    bounds.height,
                                                  ));
                                                },
                                                child: Text(
                                                  char == ' ' ? '\u00A0' : char,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: _fontSize(
                                                        maxW, 24, 28, 34),
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 1.5,
                                                    height: 1.1,
                                                    fontFamily: 'Georgia',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    // Tagline with shimmer
                                    ShaderMask(
                                      shaderCallback: (bounds) {
                                        final shimX =
                                            _shimmerController.value *
                                                (bounds.width * 2) -
                                                bounds.width;
                                        return LinearGradient(
                                          colors: const [
                                            Color(0xFF00BFFF),
                                            Color(0xFFFFFFFF),
                                            Color(0xFF00E676),
                                            Color(0xFFFFFFFF),
                                            Color(0xFFFFD700),
                                          ],
                                          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                        ).createShader(Rect.fromLTWH(
                                          shimX, 0, bounds.width * 3, bounds.height,
                                        ));
                                      },
                                      child: Text(
                                        'YOUR BRIGHT FUTURE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: _fontSize(maxW, 8, 10, 11),
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 5.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            SizedBox(height: maxH * 0.025),

                            // ── Subtitle + divider ──
                            AnimatedBuilder(
                              animation: _subtitleController,
                              builder: (_, __) => FadeTransition(
                                opacity: _subtitleOpacity,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _GoldDivider(),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Icon(Icons.auto_awesome,
                                              size: 13,
                                              color: Color(0xFFFFD700)),
                                        ),
                                        _GoldDivider(reverse: true),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      '"Education is the Key"',
                                      style: TextStyle(
                                        color: const Color(0xFFCCE8FF)
                                            .withOpacity(0.82),
                                        fontSize: _fontSize(maxW, 13, 15, 17),
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 0.6,
                                        shadows: [
                                          Shadow(
                                            color: const Color(0xFF00BFFF)
                                                .withOpacity(0.5),
                                            blurRadius: 14,
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

                      // ── Bottom brand text ──
                      Positioned(
                        bottom: 26,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _subtitleController,
                          builder: (_, __) => Opacity(
                            opacity: _subtitleOpacity.value,
                            child: Text(
                              'Est. 2024  ·  Excellence in Education',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.26),
                                fontSize: 9.5,
                                letterSpacing: 2.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _fontSize(double maxW, double sm, double md, double lg) {
    if (maxW < 360) return sm;
    if (maxW < 480) return md;
    return lg;
  }
}

// ─────────────────────────────────────────────
//  Energy Wave — radial gradient pulse (0.95→1.05)
// ─────────────────────────────────────────────
class _EnergyWave extends StatelessWidget {
  final double logoSize;
  final double glowScale;
  final double glowOpacity;

  const _EnergyWave({
    required this.logoSize,
    required this.glowScale,
    required this.glowOpacity,
  });

  @override
  Widget build(BuildContext context) {
    // Sine-wave clamp: 0.95 → 1.05 pulse
    final pulseScale = 0.95 + (glowScale - 0.85) / (1.3 - 0.85) * 0.10;

    return Transform.scale(
      scale: pulseScale,
      child: Opacity(
        opacity: glowOpacity,
        child: Container(
          width: logoSize + 20,
          height: logoSize + 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF00BFFF).withOpacity(0.35),
                const Color(0xFF00E676).withOpacity(0.20),
                const Color(0xFFFFD700).withOpacity(0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BFFF).withOpacity(0.3),
                blurRadius: 50,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.15),
                blurRadius: 80,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Light Sweep Painter — diagonal stripe once
// ─────────────────────────────────────────────
class _SweepPainter extends CustomPainter {
  final double progress;
  const _SweepPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= -0.05 || progress >= 1.05) return;
    final sweepX = progress * size.width * 1.6 - size.width * 0.3;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.55),
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.0),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.42, 0.5, 0.58, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(sweepX - 60, 0, 120, size.height));

    // Diagonal stripe
    final path = Path()
      ..moveTo(sweepX - 40, 0)
      ..lineTo(sweepX + 40, 0)
      ..lineTo(sweepX + 20, size.height)
      ..lineTo(sweepX - 60, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SweepPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
//  Fallback Logo
// ─────────────────────────────────────────────
class _FallbackLogoIcon extends StatelessWidget {
  const _FallbackLogoIcon();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 4, top: 6,
          child: Icon(Icons.language,
              size: 32, color: const Color(0xFF00BFFF).withOpacity(0.7)),
        ),
        Positioned(
          left: 4, bottom: 4,
          child: Icon(Icons.menu_book_rounded,
              size: 42, color: Colors.white.withOpacity(0.95)),
        ),
        Positioned(
          top: 4, left: 10,
          child: Icon(Icons.star_rounded,
              size: 15, color: const Color(0xFFFFD700).withOpacity(0.9)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Gold Gradient Divider
// ─────────────────────────────────────────────
class _GoldDivider extends StatelessWidget {
  final bool reverse;
  const _GoldDivider({this.reverse = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reverse
              ? [const Color(0xFF00E676).withOpacity(0.6), Colors.transparent]
              : [Colors.transparent, const Color(0xFF00BFFF).withOpacity(0.6)],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Light Streak Widget
// ─────────────────────────────────────────────
class _LightStreak extends StatefulWidget {
  final int index;
  final Size screenSize;
  const _LightStreak({required this.index, required this.screenSize});
  @override
  State<_LightStreak> createState() => _LightStreakState();
}

class _LightStreakState extends State<_LightStreak>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late double _x, _h;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _x = _rng.nextDouble();
    _h = 50 + _rng.nextDouble() * 130;
    final delay = _rng.nextDouble() * 3000;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 + _rng.nextInt(3000)),
    );
    Future.delayed(Duration(milliseconds: delay.toInt()), () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final w = widget.screenSize.width;
    final h = widget.screenSize.height;
    // Alternate between blue and green streaks
    final streakColor = widget.index.isEven
        ? const Color(0xFF00BFFF)
        : const Color(0xFF00E676);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final dy = -_h + t * (h + _h * 2);
        final opacity =
            t < 0.12 ? t / 0.12 : t > 0.82 ? (1 - t) / 0.18 : 0.55;
        return Positioned(
          left: _x * w,
          top: dy,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              width: 1,
              height: _h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    streakColor.withOpacity(0.45),
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

// ─────────────────────────────────────────────
//  Data models
// ─────────────────────────────────────────────
class _Particle {
  final double x, startY, size, speed, phase;
  final Color color;
  const _Particle({
    required this.x,
    required this.startY,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });
}

class _StarTwinkle {
  final double x, y, size, phase;
  const _StarTwinkle({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
  });
}

// ─────────────────────────────────────────────
//  Particle Painter — 40 particles, native tick
//  Light-blue / soft-green / golden opacity fade
// ─────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  const _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final dx =
          p.x * size.width + sin(t * 2 * pi + p.phase * pi) * 18;
      final dy = (p.startY - t * 0.90) * size.height;
      if (dy < -p.size || dy > size.height + p.size) continue;

      // Fade in 0→0.8 then fade out 0.8→0 as particle rises
      final fade = t < 0.12
          ? (t / 0.12) * 0.8
          : t > 0.72
              ? ((1 - t) / 0.28) * 0.8
              : 0.8;

      final paint = Paint()
        ..color = p.color.withOpacity(fade)
        ..style = PaintingStyle.fill;

      // Small glow ring around each particle
      final glowPaint = Paint()
        ..color = p.color.withOpacity(fade * 0.25)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), p.size * 0.9, glowPaint);
      canvas.drawCircle(Offset(dx, dy), p.size * 0.45, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
//  Star Field Painter
// ─────────────────────────────────────────────
class _StarFieldPainter extends CustomPainter {
  final List<_StarTwinkle> stars;
  final double progress;
  const _StarFieldPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle = (sin((progress + s.phase) * 2 * pi) + 1) / 2;
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size * 0.5,
        Paint()..color = Colors.white.withOpacity(0.12 + twinkle * 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => old.progress != progress;
}