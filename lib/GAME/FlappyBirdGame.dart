// =============================================================================
// FILE: flappy_bird_game_advanced.dart
// =============================================================================
// ADVANCED FLAPPY BIRD GAME - Premium Arcade Flying Experience
// Features: Smooth physics, Multiple bird skins, Power-ups, Animations
// UPGRADED: Premium gaming UI with glassmorphism, neon glow, advanced HUD
// Compatible with existing BEEDI College ecosystem
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// CONSTANTS & CONFIGURATION
// =============================================================================

class FlappyBirdConfig {
  // Physics
  static const double gravity = 0.012;
  static const double jumpForce = -0.22;
  static const double maxVelocity = 0.35;
  static const double maxRotation = 0.8;
  static const double minRotation = -0.5;

  // Game World
  static const double pipeSpeed = 0.018;
  static const double pipeGap = 0.32;
  static const double pipeWidth = 0.12;
  static const double birdSize = 0.045;
  static const double groundHeight = 0.12;

  // Difficulty
  static const int targetScoreForWin = 10;
  static const double speedIncreasePer3Score = 0.001;
  static const double gravityIncreasePer5Score = 0.0005;
  static const double maxPipeSpeed = 0.035;
  static const double maxGravity = 0.018;

  // Spawn Settings
  static const int initialPipeCount = 3;
  static const double pipeSpawnInterval = 0.8;
  static const double minPipeGap = 0.25;
  static const double maxPipeGap = 0.7;

  // Power-ups
  static const double powerUpSpawnChance = 0.08;
  static const int powerUpDuration = 8;

  // Collectibles
  static const double coinSpawnChance = 0.15;
  static const int coinValue = 10;

  // Visual
  static const double pipeGlowIntensity = 0.3;
  static const double birdGlowIntensity = 0.4;
  static const double groundLineCount = 20;
}

// =============================================================================
// DESIGN TOKENS
// =============================================================================

class _GC {
  static const Color bgDeep    = Color(0xFF02010A);
  static const Color bgMid     = Color(0xFF06030F);
  static const Color bgSurf    = Color(0xFF0C051E);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonBlue  = Color(0xFF00D4FF);
  static const Color neonPurp  = Color(0xFF9B5DE5);
  static const Color neonPink  = Color(0xFFFF006E);
  static const Color neonGold  = Color(0xFFFFD700);
  static const Color neonOrange= Color(0xFFFF6B00);
  static const Color neonRed   = Color(0xFFFF0044);
  static const Color neonCyan  = Color(0xFF00F5FF);
  static const Color textPrim  = Color(0xFFF0F8FF);
  static const Color textSec   = Color(0xFF8AACCC);
  static const Color textDim   = Color(0xFF3A5A7A);
  static Color glassW          = Colors.white.withOpacity(0.05);
  static Color glassB          = Colors.white.withOpacity(0.12);
}

// =============================================================================
// ENUMS
// =============================================================================

enum GameState  { idle, countdown, playing, paused, gameOver }
enum BirdSkin   { classic, phoenix, cyber, rainbow, golden, shadow }
enum WeatherEffect { day, night, sunset, rain, space }
enum PowerUpType   { shield, slowMotion, doubleScore, magnet, invincibility }

// =============================================================================
// DATA MODELS
// =============================================================================

class Pipe {
  double x;
  double gapY;
  bool passed;
  double animationOffset;

  Pipe({required this.x, required this.gapY, this.passed = false, this.animationOffset = 0});

  void updateAnimation() => animationOffset += 0.05;
}

class Collectible {
  final String id;
  final CollectibleType type;
  double x;
  double y;
  bool isActive;
  double animationOffset;

  Collectible({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.isActive = true,
    this.animationOffset = 0,
  });

  int get value {
    switch (type) {
      case CollectibleType.coin: return FlappyBirdConfig.coinValue;
      case CollectibleType.gem:  return 50;
      case CollectibleType.star: return 25;
    }
  }

  String get emoji {
    switch (type) {
      case CollectibleType.coin: return '💰';
      case CollectibleType.gem:  return '💎';
      case CollectibleType.star: return '⭐';
    }
  }

  Color get color {
    switch (type) {
      case CollectibleType.coin: return _GC.neonGold;
      case CollectibleType.gem:  return _GC.neonBlue;
      case CollectibleType.star: return _GC.neonPink;
    }
  }
}

enum CollectibleType { coin, gem, star }

class PowerUp {
  final PowerUpType type;
  double x;
  double y;
  bool isActive;
  int remainingDuration;
  double animationOffset;

  PowerUp({
    required this.type,
    required this.x,
    required this.y,
    this.isActive = true,
    this.remainingDuration = FlappyBirdConfig.powerUpDuration,
    this.animationOffset = 0,
  });

  String get emoji {
    switch (type) {
      case PowerUpType.shield:        return '🛡️';
      case PowerUpType.slowMotion:    return '🐢';
      case PowerUpType.doubleScore:   return '2️⃣';
      case PowerUpType.magnet:        return '🧲';
      case PowerUpType.invincibility: return '✨';
    }
  }

  Color get color {
    switch (type) {
      case PowerUpType.shield:        return _GC.neonBlue;
      case PowerUpType.slowMotion:    return _GC.neonPurp;
      case PowerUpType.doubleScore:   return _GC.neonGold;
      case PowerUpType.magnet:        return _GC.neonGreen;
      case PowerUpType.invincibility: return _GC.neonPink;
    }
  }

  String get name {
    switch (type) {
      case PowerUpType.shield:        return 'Shield';
      case PowerUpType.slowMotion:    return 'Slow Mo';
      case PowerUpType.doubleScore:   return '2x Score';
      case PowerUpType.magnet:        return 'Magnet';
      case PowerUpType.invincibility: return 'Invincible';
    }
  }
}

class Particle {
  double x, y, vx, vy, size, opacity, lifetime, maxLifetime;
  Color color;

  Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.size, required this.color, required this.lifetime,
  }) : maxLifetime = lifetime, opacity = 1.0;

  bool update() {
    x += vx; y += vy; vy += 0.01;
    lifetime -= 1 / 60;
    opacity = lifetime / maxLifetime;
    return lifetime > 0;
  }
}

class Cloud {
  double x, y, speed, size, opacity;
  Cloud({required this.x, required this.y, required this.speed, required this.size, this.opacity = 0.3});
}

class BirdSkinData {
  final String name;
  final String emoji;
  final Color color;
  final Color glowColor;
  final List<Color> gradientColors;

  const BirdSkinData({
    required this.name, required this.emoji,
    required this.color, required this.glowColor,
    required this.gradientColors,
  });

  static const Map<BirdSkin, BirdSkinData> skins = {
    BirdSkin.classic: BirdSkinData(name:'Classic', emoji:'🐦',
      color:Color(0xFFFFD700), glowColor:Color(0xFFFFD700),
      gradientColors:[Color(0xFFFFD700), Color(0xFFFF6B00)]),
    BirdSkin.phoenix: BirdSkinData(name:'Phoenix', emoji:'🔥',
      color:Color(0xFFFF4081), glowColor:Color(0xFFFF4081),
      gradientColors:[Color(0xFFFF4081), Color(0xFFFF6B00)]),
    BirdSkin.cyber: BirdSkinData(name:'Cyber', emoji:'🤖',
      color:Color(0xFF00D4FF), glowColor:Color(0xFF00D4FF),
      gradientColors:[Color(0xFF00D4FF), Color(0xFF00FF88)]),
    BirdSkin.rainbow: BirdSkinData(name:'Rainbow', emoji:'🌈',
      color:Color(0xFF9C27B0), glowColor:Color(0xFFFFD700),
      gradientColors:[Color(0xFFFF4081), Color(0xFFFFD700), Color(0xFF00FF88), Color(0xFF00D4FF)]),
    BirdSkin.golden: BirdSkinData(name:'Golden', emoji:'🏆',
      color:Color(0xFFFFD700), glowColor:Color(0xFFFFD700),
      gradientColors:[Color(0xFFFFD700), Color(0xFFFFA500)]),
    BirdSkin.shadow: BirdSkinData(name:'Shadow', emoji:'🌑',
      color:Color(0xFF2C2C2C), glowColor:Color(0xFF9C27B0),
      gradientColors:[Color(0xFF2C2C2C), Color(0xFF1A1A2E)]),
  };
}

class FlappyStatistics {
  int highestScore = 0;
  int totalPipesPassed = 0;
  int totalCoinsCollected = 0;
  int totalGamesPlayed = 0;
  int longestSurvival = 0;
  int perfectFlights = 0;
  int powerUpsCollected = 0;

  void updateStats(int score, int pipes, int coins, int survivalTime, bool perfect) {
    if (score > highestScore) highestScore = score;
    totalPipesPassed += pipes;
    totalCoinsCollected += coins;
    totalGamesPlayed++;
    if (survivalTime > longestSurvival) longestSurvival = survivalTime;
    if (perfect) perfectFlights++;
  }
}

// =============================================================================
// REUSABLE PREMIUM UI COMPONENTS
// =============================================================================

/// Glassmorphic card with neon border
class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final EdgeInsets padding;
  final double radius;

  const _GlassCard({
    required this.child,
    this.borderColor = _GC.neonBlue,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
        ),
        boxShadow: [BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 1)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Neon glowing text
class _NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  const _NeonText(this.text, {required this.fontSize, required this.color,
      this.fontWeight = FontWeight.bold});

  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.orbitron(fontSize: fontSize, fontWeight: fontWeight,
      color: color,
      shadows: [Shadow(color: color.withOpacity(0.9), blurRadius: 8),
                Shadow(color: color.withOpacity(0.5), blurRadius: 16)]),
  );
}

/// Animated neon button
class _NeonBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double width;
  final IconData? icon;

  const _NeonBtn({required this.label, required this.onTap,
      required this.color, this.width = 220, this.icon});

  @override
  State<_NeonBtn> createState() => _NeonBtnState();
}

class _NeonBtnState extends State<_NeonBtn> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween(begin: 1.0, end: 0.93).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { _c.forward(); HapticFeedback.lightImpact(); },
      onTapUp: (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: widget.color, width: 1.5),
            gradient: LinearGradient(colors: [widget.color.withOpacity(0.18), widget.color.withOpacity(0.05)]),
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 16)],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (widget.icon != null) ...[Icon(widget.icon, color: widget.color, size: 17), const SizedBox(width: 8)],
            Text(widget.label, style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.w700,
              color: widget.color, letterSpacing: 1.5,
              shadows: [Shadow(color: widget.color, blurRadius: 8)])),
          ]),
        ),
      ),
    );
  }
}

/// HUD pill (score / level / coins)
class _HUDPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HUDPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.5)),
        gradient: LinearGradient(colors: [color.withOpacity(0.18), color.withOpacity(0.04)]),
        boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: GoogleFonts.rajdhani(fontSize: 9, color: color.withOpacity(0.75),
            fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        Text(value, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w800,
            color: color, shadows: [Shadow(color: color, blurRadius: 6)])),
      ]),
    );
  }
}

// =============================================================================
// MAIN FLAPPY BIRD GAME WIDGET
// =============================================================================

class AdvancedFlappyBirdGame extends StatefulWidget {
  final BirdSkin initialSkin;
  const AdvancedFlappyBirdGame({super.key, this.initialSkin = BirdSkin.classic});

  @override
  State<AdvancedFlappyBirdGame> createState() => _AdvancedFlappyBirdGameState();
}

class _AdvancedFlappyBirdGameState extends State<AdvancedFlappyBirdGame>
    with TickerProviderStateMixin {

  // =========================================================================
  // GAME STATE
  // =========================================================================
  double _birdY = 0.5;
  double _birdVelocity = 0;
  double _birdRotation = 0;
  late List<Pipe> _pipes;

  int _score = 0;
  int _bestScore = 0;
  int _combo = 0;
  int _level = 1;
  int _collectedCoins = 0;
  int _collectedGems = 0;
  int _collectedStars = 0;

  GameState _gameState = GameState.idle;
  BirdSkin _currentSkin = BirdSkin.classic;
  WeatherEffect _currentWeather = WeatherEffect.day;

  final List<Collectible> _collectibles = [];
  final List<PowerUp> _powerUps = [];
  final List<Particle> _particles = [];
  final List<Cloud> _clouds = [];

  PowerUpType? _activePowerUp;
  int _powerUpRemaining = 0;
  Timer? _powerUpTimer;
  int _scoreMultiplier = 1;
  bool _isInvincible = false;
  bool _hasShield = false;
  double _currentPipeSpeed = FlappyBirdConfig.pipeSpeed;
  double _currentGravity = FlappyBirdConfig.gravity;

  Timer? _gameLoop;
  Timer? _spawnTimer;
  Timer? _weatherTimer;
  Timer? _comboTimer;

  double _backgroundOffset = 0;
  double _groundOffset = 0;
  double _wingAngle = 0;
  bool _wingDirection = true;
  Timer? _wingAnimationTimer;
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _lastScoreIncrease = 0;

  // Smooth displayed score (animated counter)
  int _displayedScore = 0;
  Timer? _scoreAnimTimer;

  // Countdown value
  int _countdownValue = 3;

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _comboController;
  late AnimationController _scoreController;
  late AnimationController _hudInController;
  late AnimationController _bgGridController;
  late AnimationController _overlayFadeController;
  late ConfettiController _confettiController;
  late ConfettiController _victoryController;

  late Animation<double> _hudIn;
  late Animation<double> _scorePop;
  late Animation<double> _overlayFade;

  final FlappyStatistics _statistics = FlappyStatistics();
  int _survivalTime = 0;
  Timer? _survivalTimer;
  int _perfectRunCheck = 0;

  final Random _random = Random();
  final FocusNode _focusNode = FocusNode();

  // =========================================================================
  // INITIALIZATION
  // =========================================================================

  @override
  void initState() {
    super.initState();
    _currentSkin = widget.initialSkin;
    _initControllers();
    _loadBestScore();
    _loadStatistics();
    _initPipes();
    _initClouds();
    _initWingAnimation();
    _initWeather();
  }

  void _initControllers() {
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _comboController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _scoreController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scorePop = Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut));

    _hudInController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _hudIn = CurvedAnimation(parent: _hudInController, curve: Curves.easeOutBack);

    _bgGridController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

    _overlayFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _overlayFade = CurvedAnimation(parent: _overlayFadeController, curve: Curves.easeOut);
    _overlayFadeController.forward();

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _victoryController  = ConfettiController(duration: const Duration(seconds: 3));
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _bestScore = prefs.getInt('flappy_bird_best') ?? 0; });
  }

  Future<void> _saveBestScore() async {
    if (_score > _bestScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('flappy_bird_best', _score);
      if (mounted) {
        setState(() { _bestScore = _score; });
        _showFeedback('NEW BEST SCORE! 🏆', _GC.neonGold);
      }
    }
  }

  Future<void> _loadStatistics() async { setState(() {}); }

  void _initPipes() {
    _pipes = [];
    for (int i = 0; i < FlappyBirdConfig.initialPipeCount; i++) {
      _pipes.add(Pipe(x: 1.0 + i * FlappyBirdConfig.pipeSpawnInterval,
          gapY: 0.3 + _random.nextDouble() * 0.4));
    }
  }

  void _initClouds() {
    for (int i = 0; i < 8; i++) {
      _clouds.add(Cloud(
        x: _random.nextDouble(), y: _random.nextDouble() * 0.6,
        speed: 0.0005 + _random.nextDouble() * 0.002,
        size: 0.06 + _random.nextDouble() * 0.08,
        opacity: 0.12 + _random.nextDouble() * 0.15,
      ));
    }
  }

  void _initWingAnimation() {
    _wingAnimationTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_gameState == GameState.playing && mounted) {
        setState(() {
          if (_wingDirection) {
            _wingAngle += 0.15;
            if (_wingAngle >= 0.6) _wingDirection = false;
          } else {
            _wingAngle -= 0.15;
            if (_wingAngle <= -0.6) _wingDirection = true;
          }
        });
      }
    });
  }

  void _initWeather() {
    _weatherTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted && _gameState == GameState.playing) {
        setState(() {
          final weathers = WeatherEffect.values;
          _currentWeather = weathers[_random.nextInt(weathers.length)];
          _showFeedback(_getWeatherName(_currentWeather), _getWeatherColor(_currentWeather));
        });
      }
    });
  }

  String _getWeatherName(WeatherEffect weather) {
    switch (weather) {
      case WeatherEffect.day:    return '☀️ Sunny Day';
      case WeatherEffect.night:  return '🌙 Night Flight';
      case WeatherEffect.sunset: return '🌅 Golden Hour';
      case WeatherEffect.rain:   return '🌧️ Rainy Skies';
      case WeatherEffect.space:  return '🚀 Space Mode';
    }
  }

  Color _getWeatherColor(WeatherEffect weather) {
    switch (weather) {
      case WeatherEffect.day:    return _GC.neonGold;
      case WeatherEffect.night:  return _GC.neonPurp;
      case WeatherEffect.sunset: return _GC.neonOrange;
      case WeatherEffect.rain:   return _GC.neonBlue;
      case WeatherEffect.space:  return _GC.neonPink;
    }
  }

  // =========================================================================
  // GAME START & RESTART
  // =========================================================================

  void _startCountdown() {
    _overlayFadeController.forward(from: 0);
    setState(() { _gameState = GameState.countdown; _countdownValue = 3; });

    int countdown = 3;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        countdown--;
        setState(() => _countdownValue = countdown);
        HapticFeedback.lightImpact();
      } else {
        timer.cancel();
        _startGame();
      }
    });
  }

  void _startGame() {
    setState(() {
      _gameState = GameState.playing;
      _birdY = 0.5; _birdVelocity = 0; _birdRotation = 0;
      _score = 0; _displayedScore = 0; _combo = 0; _level = 1;
      _collectedCoins = 0; _collectedGems = 0; _collectedStars = 0;
      _survivalTime = 0; _perfectRunCheck = 0;
      _currentPipeSpeed = FlappyBirdConfig.pipeSpeed;
      _currentGravity = FlappyBirdConfig.gravity;
      _activePowerUp = null; _isInvincible = false; _hasShield = false;
      _scoreMultiplier = 1;
      _collectibles.clear(); _powerUps.clear(); _particles.clear();
    });

    _initPipes();
    _hudInController.forward(from: 0);
    _startGameLoop();
    _startSpawnTimer();
    _startSurvivalTimer();
    _startScoreAnimTimer();
  }

  void _startGameLoop() {
    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_gameState == GameState.playing && mounted) _updateGame();
    });
  }

  void _startSpawnTimer() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (_gameState == GameState.playing && mounted) {
        if (_random.nextDouble() < FlappyBirdConfig.coinSpawnChance) _spawnCollectible();
        if (_random.nextDouble() < FlappyBirdConfig.powerUpSpawnChance) _spawnPowerUp();
      }
    });
  }

  void _startSurvivalTimer() {
    _survivalTimer?.cancel();
    _survivalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_gameState == GameState.playing && mounted) setState(() => _survivalTime++);
    });
  }

  void _startScoreAnimTimer() {
    _scoreAnimTimer?.cancel();
    _scoreAnimTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted) return;
      if (_displayedScore < _score) {
        setState(() {
          _displayedScore += max(1, ((_score - _displayedScore) / 5).ceil());
          if (_displayedScore > _score) _displayedScore = _score;
        });
      }
    });
  }

  void _restartGame() {
    _gameLoop?.cancel(); _spawnTimer?.cancel();
    _survivalTimer?.cancel(); _powerUpTimer?.cancel();
    _comboTimer?.cancel(); _scoreAnimTimer?.cancel();
    _survivalTime = 0;
    _startCountdown();
  }

  // =========================================================================
  // GAME UPDATE LOGIC
  // =========================================================================

  void _updateGame() {
    setState(() {
      // Bird physics
      _birdVelocity += _currentGravity;
      if (_birdVelocity > FlappyBirdConfig.maxVelocity) _birdVelocity = FlappyBirdConfig.maxVelocity;
      _birdY += _birdVelocity;

      _birdRotation = (_birdVelocity * 1.8)
          .clamp(FlappyBirdConfig.minRotation, FlappyBirdConfig.maxRotation);

      _backgroundOffset += 0.001;
      _groundOffset += 0.008;

      for (var cloud in _clouds) {
        cloud.x -= cloud.speed;
        if (cloud.x < -0.2) { cloud.x = 1.2; cloud.y = _random.nextDouble() * 0.6; }
      }

      // Update pipes
      for (int i = 0; i < _pipes.length; i++) {
        _pipes[i].x -= _currentPipeSpeed;
        _pipes[i].updateAnimation();

        if (_pipes[i].x < -FlappyBirdConfig.pipeWidth) {
          if (!_pipes[i].passed) {
            _pipes[i].passed = true;
            _incrementScore();
            if (_score % 3 == 0 && _currentPipeSpeed < FlappyBirdConfig.maxPipeSpeed)
              _currentPipeSpeed += FlappyBirdConfig.speedIncreasePer3Score;
            if (_score % 5 == 0 && _currentGravity < FlappyBirdConfig.maxGravity)
              _currentGravity += FlappyBirdConfig.gravityIncreasePer5Score;
            final newLevel = 1 + (_score ~/ 10);
            if (newLevel > _level) {
              _level = newLevel;
              _showFeedback('LEVEL $_level! ⬆️', _GC.neonGold);
              HapticFeedback.mediumImpact();
            }
          }
          _pipes[i].x = 1.4;
          _pipes[i].gapY = FlappyBirdConfig.minPipeGap +
              _random.nextDouble() * (FlappyBirdConfig.maxPipeGap - FlappyBirdConfig.minPipeGap);
          _pipes[i].passed = false;
        }
      }

      for (int i = 0; i < _collectibles.length; i++) {
        _collectibles[i].x -= _currentPipeSpeed;
        _collectibles[i].animationOffset += 0.1;
        if (_collectibles[i].x < -0.1) { _collectibles.removeAt(i); i--; }
      }

      for (int i = 0; i < _powerUps.length; i++) {
        _powerUps[i].x -= _currentPipeSpeed;
        _powerUps[i].animationOffset += 0.1;
        if (_powerUps[i].x < -0.1) { _powerUps.removeAt(i); i--; }
      }

      _particles.removeWhere((p) => !p.update());

      if (_activePowerUp != null && _powerUpRemaining > 0) {
        _powerUpRemaining--;
        if (_powerUpRemaining <= 0) _deactivatePowerUp();
      }

      if (_combo > 0 && _comboTimer != null && !_comboTimer!.isActive) _combo = 0;

      _checkCollisions();

      if (_birdY > 1.0 - FlappyBirdConfig.groundHeight || _birdY < -0.05) _gameOver();
    });
  }

  void _incrementScore() {
    final pointsEarned = 10 * _scoreMultiplier;
    _score += pointsEarned;
    _combo++;
    _perfectRunCheck++;
    _lastScoreIncrease = pointsEarned;

    _scoreController.forward(from: 0);
    _addScoreParticles();
    HapticFeedback.lightImpact();

    if (_combo > 1 && _combo % 5 == 0) {
      _comboController.forward(from: 0);
      _showFeedback('COMBO x${_combo}! 🔥', _GC.neonPink);
      _confettiController.play();
      HapticFeedback.mediumImpact();
    }

    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _gameState == GameState.playing) setState(() { _combo = 0; });
    });

    _saveBestScore();
  }

  void _checkCollisions() {
    const birdCenterX = 0.2;
    final birdLeft   = birdCenterX - FlappyBirdConfig.birdSize / 2;
    final birdRight  = birdCenterX + FlappyBirdConfig.birdSize / 2;
    final birdTop    = _birdY - FlappyBirdConfig.birdSize;
    final birdBottom = _birdY + FlappyBirdConfig.birdSize;

    for (final pipe in _pipes) {
      final pipeLeft   = pipe.x - FlappyBirdConfig.pipeWidth / 2;
      final pipeRight  = pipe.x + FlappyBirdConfig.pipeWidth / 2;
      final gapTop     = pipe.gapY - FlappyBirdConfig.pipeGap / 2;
      final gapBottom  = pipe.gapY + FlappyBirdConfig.pipeGap / 2;

      if (birdRight > pipeLeft && birdLeft < pipeRight) {
        if (birdTop < gapTop || birdBottom > gapBottom) {
          if (_isInvincible) {
            _showFeedback('✨ Invincible! ✨', _GC.neonPink);
            _addInvincibleEffect();
          } else if (_hasShield) {
            _hasShield = false; _activePowerUp = null;
            _showFeedback('🛡️ Shield saved you!', _GC.neonBlue);
            _addShieldBreakEffect();
            HapticFeedback.mediumImpact();
          } else { _gameOver(); return; }
        }
      }
    }

    for (int i = 0; i < _collectibles.length; i++) {
      final c = _collectibles[i];
      if (birdRight > c.x - 0.03 && birdLeft < c.x + 0.03 &&
          birdBottom > c.y - 0.03 && birdTop < c.y + 0.03) {
        _collectCollectible(c); _collectibles.removeAt(i); i--;
      }
    }

    for (int i = 0; i < _powerUps.length; i++) {
      final p = _powerUps[i];
      if (birdRight > p.x - 0.03 && birdLeft < p.x + 0.03 &&
          birdBottom > p.y - 0.03 && birdTop < p.y + 0.03) {
        _activatePowerUp(p); _powerUps.removeAt(i); i--;
      }
    }
  }

  void _collectCollectible(Collectible collectible) {
    final value = collectible.value * _scoreMultiplier;
    _score += value;
    switch (collectible.type) {
      case CollectibleType.coin: _collectedCoins++; break;
      case CollectibleType.gem:  _collectedGems++;  break;
      case CollectibleType.star: _collectedStars++; break;
    }
    _addCollectibleParticles(collectible.x, collectible.y, collectible.color);
    _showFeedback('+$value ${collectible.emoji}', collectible.color);
    HapticFeedback.lightImpact();
    _scoreController.forward(from: 0);
  }

  void _activatePowerUp(PowerUp powerUp) {
    setState(() {
      _activePowerUp = powerUp.type;
      _powerUpRemaining = powerUp.remainingDuration;
      _statistics.powerUpsCollected++;
    });
    _showFeedback('${powerUp.emoji} ${powerUp.name} ACTIVATED!', powerUp.color);
    _addPowerUpParticles(powerUp.x, powerUp.y, powerUp.color);
    HapticFeedback.mediumImpact();

    switch (powerUp.type) {
      case PowerUpType.doubleScore:   _scoreMultiplier = 2; break;
      case PowerUpType.slowMotion:    _currentPipeSpeed = FlappyBirdConfig.pipeSpeed * 0.5; break;
      case PowerUpType.shield:        _hasShield = true; break;
      case PowerUpType.magnet:        break;
      case PowerUpType.invincibility: _isInvincible = true; break;
    }
    _startPowerUpTimer();
  }

  void _startPowerUpTimer() {
    _powerUpTimer?.cancel();
    _powerUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _powerUpRemaining--;
        if (_powerUpRemaining <= 0) { timer.cancel(); _deactivatePowerUp(); }
      });
    });
  }

  void _deactivatePowerUp() {
    setState(() {
      switch (_activePowerUp) {
        case PowerUpType.doubleScore:   _scoreMultiplier = 1; break;
        case PowerUpType.slowMotion:    _currentPipeSpeed = FlappyBirdConfig.pipeSpeed; break;
        case PowerUpType.shield:        _hasShield = false; break;
        case PowerUpType.invincibility: _isInvincible = false; break;
        default: break;
      }
      _activePowerUp = null;
    });
    _showFeedback('Power-up expired', Colors.white38);
  }

  void _spawnCollectible() {
    final types = CollectibleType.values;
    final type  = types[_random.nextInt(types.length)];
    final randomPipe = _pipes[_random.nextInt(_pipes.length)];
    final x = randomPipe.x + 0.2;
    final y = (randomPipe.gapY + (_random.nextDouble() - 0.5) * 0.2).clamp(0.1, 0.9);
    setState(() => _collectibles.add(Collectible(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type, x: x, y: y,
    )));
  }

  void _spawnPowerUp() {
    final types = PowerUpType.values;
    final type  = types[_random.nextInt(types.length)];
    final randomPipe = _pipes[_random.nextInt(_pipes.length)];
    final x = randomPipe.x + 0.3;
    final y = randomPipe.gapY.clamp(0.1, 0.9);
    setState(() => _powerUps.add(PowerUp(type: type, x: x, y: y)));
  }

  // =========================================================================
  // PARTICLE EFFECTS
  // =========================================================================

  void _addScoreParticles() {
    for (int i = 0; i < 10; i++) {
      _particles.add(Particle(x: 0.5, y: 0.3,
        vx: (_random.nextDouble() - 0.5) * 0.01,
        vy: -_random.nextDouble() * 0.015,
        size: 2 + _random.nextDouble() * 3, color: _GC.neonGold, lifetime: 0.5));
    }
  }

  void _addCollectibleParticles(double x, double y, Color color) {
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(x: x, y: y,
        vx: (_random.nextDouble() - 0.5) * 0.02, vy: (_random.nextDouble() - 0.5) * 0.02,
        size: 2 + _random.nextDouble() * 3, color: color, lifetime: 0.5));
    }
    _confettiController.play();
  }

  void _addPowerUpParticles(double x, double y, Color color) {
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(x: x, y: y,
        vx: (_random.nextDouble() - 0.5) * 0.025, vy: (_random.nextDouble() - 0.5) * 0.025,
        size: 2 + _random.nextDouble() * 4, color: color, lifetime: 0.6));
    }
  }

  void _addFlapParticles() {
    for (int i = 0; i < 12; i++) {
      _particles.add(Particle(x: 0.18, y: _birdY,
        vx: -(_random.nextDouble() * 0.015), vy: (_random.nextDouble() - 0.5) * 0.012,
        size: 2 + _random.nextDouble() * 3,
        color: BirdSkinData.skins[_currentSkin]!.glowColor, lifetime: 0.4));
    }
  }

  void _addCollisionParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(x: 0.2, y: _birdY,
        vx: (_random.nextDouble() - 0.5) * 0.03, vy: (_random.nextDouble() - 0.5) * 0.03,
        size: 3 + _random.nextDouble() * 5, color: _GC.neonRed, lifetime: 0.6));
    }
    _shakeController.forward(from: 0);
  }

  void _addShieldBreakEffect() {
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(x: 0.2, y: _birdY,
        vx: (_random.nextDouble() - 0.5) * 0.04, vy: (_random.nextDouble() - 0.5) * 0.04,
        size: 2 + _random.nextDouble() * 4, color: _GC.neonBlue, lifetime: 0.5));
    }
  }

  void _addInvincibleEffect() {
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(x: 0.2, y: _birdY,
        vx: (_random.nextDouble() - 0.5) * 0.03, vy: (_random.nextDouble() - 0.5) * 0.03,
        size: 2 + _random.nextDouble() * 4, color: _GC.neonPink, lifetime: 0.5));
    }
  }

  void _showFeedback(String message, Color color) {
    setState(() { _feedbackMessage = message; _feedbackColor = color; });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _feedbackMessage == message) setState(() => _feedbackMessage = null);
    });
  }

  // =========================================================================
  // GAME ACTIONS
  // =========================================================================

  void _flap() {
    if (_gameState == GameState.idle)   { _startCountdown(); return; }
    if (_gameState == GameState.paused) { _togglePause(); return; }
    if (_gameState != GameState.playing) return;

    setState(() {
      _birdVelocity = FlappyBirdConfig.jumpForce;
      _addFlapParticles();
    });
    HapticFeedback.lightImpact();
  }

  void _togglePause() {
    if (_gameState == GameState.playing) {
      setState(() => _gameState = GameState.paused);
      _gameLoop?.cancel(); _spawnTimer?.cancel();
      _overlayFadeController.forward(from: 0);
    } else if (_gameState == GameState.paused) {
      setState(() => _gameState = GameState.playing);
      _startGameLoop(); _startSpawnTimer();
    }
  }

  // =========================================================================
  // GAME OVER
  // =========================================================================

  void _gameOver() {
    if (_gameState != GameState.playing) return;
    setState(() => _gameState = GameState.gameOver);

    _gameLoop?.cancel(); _spawnTimer?.cancel();
    _survivalTimer?.cancel(); _powerUpTimer?.cancel();
    _comboTimer?.cancel();

    _addCollisionParticles();
    HapticFeedback.heavyImpact();

    final isPerfect = _perfectRunCheck == _score ~/ 10;
    _statistics.updateStats(_score, _score, _collectedCoins, _survivalTime, isPerfect);
    _saveBestScore();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _overlayFadeController.forward(from: 0);
        _showResult();
      }
    });
  }

  void _showResult() {
    final won = _score >= FlappyBirdConfig.targetScoreForWin;
    final totalCoins = _collectedCoins + (_collectedGems * 5) + (_collectedStars * 2);
    final totalRewardCoins = (won ? 90 : 0) + totalCoins;
    final totalXp = (won ? 130 : 20) + (_level * 5) + (_combo ~/ 2);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameResultScreen(
          won: won,
          coins: totalRewardCoins.clamp(0, 300),
          xp: totalXp.clamp(0, 200),
          score: _score,
          gameName: 'Flappy Bird',
          onContinue: () => Navigator.pop(context),
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _GC.bgDeep,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.space ||
               event.logicalKey == LogicalKeyboardKey.arrowUp)) {
            _flap();
          }
          return KeyEventResult.handled;
        },
        child: WillPopScope(
          onWillPop: () async {
            if (_gameState == GameState.playing) { _togglePause(); return false; }
            return true;
          },
          child: Stack(children: [
            // Animated BG grid
            AnimatedBuilder(
              animation: _bgGridController,
              builder: (_, __) => CustomPaint(
                painter: _BgGridPainter(_bgGridController.value),
                child: const SizedBox.expand(),
              ),
            ),

            // Game canvas with shake
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _flap,
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (_, child) => Transform.translate(
                  offset: Offset(_shakeController.isAnimating
                      ? sin(_shakeController.value * pi * 8) * 6 : 0, 0),
                  child: child,
                ),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: AdvancedFlappyPainter(
                      birdY: _birdY, birdRotation: _birdRotation, wingAngle: _wingAngle,
                      pipes: _pipes, collectibles: _collectibles, powerUps: _powerUps,
                      particles: _particles, clouds: _clouds,
                      backgroundOffset: _backgroundOffset, groundOffset: _groundOffset,
                      currentSkin: _currentSkin, currentWeather: _currentWeather,
                      activePowerUp: _activePowerUp, shakeOffset: 0,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // HUD
            if (_gameState == GameState.playing || _gameState == GameState.paused)
              _buildHUD(),

            // Pause button
            if (_gameState == GameState.playing)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 16,
                child: GestureDetector(
                  onTap: _togglePause,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _GC.neonBlue.withOpacity(0.6), width: 1.5),
                      color: _GC.bgDeep.withOpacity(0.7),
                      boxShadow: [BoxShadow(color: _GC.neonBlue.withOpacity(0.3), blurRadius: 12)],
                    ),
                    child: const Icon(Icons.pause_rounded, color: _GC.neonBlue, size: 20),
                  ),
                ),
              ),

            // Overlays
            if (_gameState != GameState.playing)
              FadeTransition(opacity: _overlayFade, child: _buildOverlay()),

            // Feedback toast
            if (_feedbackMessage != null) _buildFeedbackMessage(),

            // Confetti
            Align(alignment: Alignment.topCenter, child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [_GC.neonGold, _GC.neonGreen, _GC.neonPink],
              numberOfParticles: 30,
            )),
            Align(alignment: Alignment.topCenter, child: ConfettiWidget(
              confettiController: _victoryController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [_GC.neonGold, _GC.neonPink, _GC.neonBlue],
              numberOfParticles: 50,
            )),
          ]),
        ),
      ),
    );
  }

  // ── HUD ──────────────────────────────────────────────────────────────────

  Widget _buildHUD() {
    final speedPct = ((_currentPipeSpeed - FlappyBirdConfig.pipeSpeed) /
        (FlappyBirdConfig.maxPipeSpeed - FlappyBirdConfig.pipeSpeed)).clamp(0.0, 1.0);

    return SafeArea(
      child: AnimatedBuilder(
        animation: _hudIn,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -30 * (1 - _hudIn.value)),
          child: Opacity(opacity: _hudIn.value, child: child),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 60, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Stat row
            Row(children: [
              ScaleTransition(
                scale: _scorePop,
                child: _HUDPill(label: 'SCORE', value: '$_displayedScore', color: _GC.neonGold),
              ),
              const SizedBox(width: 8),
              _HUDPill(label: 'BEST', value: '$_bestScore', color: _GC.neonCyan),
              const SizedBox(width: 8),
              _HUDPill(label: 'LVL', value: '$_level', color: _GC.neonPurp),
              const SizedBox(width: 8),
              _HUDPill(label: '💰', value: '$_collectedCoins', color: _GC.neonGold),
            ]),
            const SizedBox(height: 8),

            // Speed bar
            Row(children: [
              Text('SPD', style: GoogleFonts.rajdhani(fontSize: 9, color: _GC.textDim, letterSpacing: 1.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: _GC.bgSurf),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: speedPct,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(colors: [
                          _GC.neonGreen,
                          speedPct > 0.7 ? _GC.neonRed : _GC.neonBlue,
                        ]),
                        boxShadow: [BoxShadow(
                          color: (speedPct > 0.7 ? _GC.neonRed : _GC.neonGreen).withOpacity(0.6),
                          blurRadius: 6,
                        )],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text('${(_currentPipeSpeed * 1000).toStringAsFixed(1)}',
                  style: GoogleFonts.orbitron(fontSize: 9, color: _GC.neonGreen)),
            ]),

            // Combo badge
            if (_combo > 1)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: AnimatedBuilder(
                  animation: _comboController,
                  builder: (_, child) => Transform.scale(scale: 1.0 + _comboController.value * 0.25, child: child),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _GC.neonPink.withOpacity(0.7)),
                      gradient: LinearGradient(colors: [_GC.neonPink.withOpacity(0.25), _GC.neonPurp.withOpacity(0.1)]),
                      boxShadow: [BoxShadow(color: _GC.neonPink.withOpacity(0.4), blurRadius: 10)],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text('🔥', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text('COMBO ×$_combo', style: GoogleFonts.orbitron(
                          fontSize: 11, color: _GC.neonPink, fontWeight: FontWeight.w800,
                          shadows: [Shadow(color: _GC.neonPink, blurRadius: 6)])),
                    ]),
                  ),
                ),
              ),

            // Power-up indicator
            if (_activePowerUp != null)
              Padding(padding: const EdgeInsets.only(top: 8), child: _buildPowerUpIndicator()),
          ]),
        ),
      ),
    );
  }

  Widget _buildPowerUpIndicator() {
    final color = _activePowerUp == null ? Colors.white : _getPowerUpColor(_activePowerUp!);
    final emoji = _activePowerUp == null ? '⭐' : _getPowerUpEmoji(_activePowerUp!);
    final name  = _activePowerUp == null ? '' : _getPowerUpName(_activePowerUp!);
    final pct   = _powerUpRemaining / FlappyBirdConfig.powerUpDuration;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
        gradient: LinearGradient(colors: [color.withOpacity(0.18), color.withOpacity(0.04)]),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(name, style: GoogleFonts.rajdhani(fontSize: 10, color: color,
              fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 2),
          SizedBox(width: 60, height: 3, child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          )),
        ]),
        const SizedBox(width: 6),
        Text('${_powerUpRemaining}s', style: GoogleFonts.orbitron(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  String _getPowerUpEmoji(PowerUpType t) {
    switch (t) {
      case PowerUpType.shield:        return '🛡️';
      case PowerUpType.slowMotion:    return '🐢';
      case PowerUpType.doubleScore:   return '2️⃣';
      case PowerUpType.magnet:        return '🧲';
      case PowerUpType.invincibility: return '✨';
    }
  }

  String _getPowerUpName(PowerUpType t) {
    switch (t) {
      case PowerUpType.shield:        return 'Shield';
      case PowerUpType.slowMotion:    return 'Slow Mo';
      case PowerUpType.doubleScore:   return '2x Score';
      case PowerUpType.magnet:        return 'Magnet';
      case PowerUpType.invincibility: return 'Invincible';
    }
  }

  Color _getPowerUpColor(PowerUpType t) {
    switch (t) {
      case PowerUpType.shield:        return _GC.neonBlue;
      case PowerUpType.slowMotion:    return _GC.neonPurp;
      case PowerUpType.doubleScore:   return _GC.neonGold;
      case PowerUpType.magnet:        return _GC.neonGreen;
      case PowerUpType.invincibility: return _GC.neonPink;
    }
  }

  // ── Overlays ─────────────────────────────────────────────────────────────

  Widget _buildOverlay() {
    switch (_gameState) {
      case GameState.idle:      return _buildStartScreen();
      case GameState.countdown: return _buildCountdownScreen();
      case GameState.paused:    return _buildPauseMenu();
      case GameState.gameOver:  return _buildGameOverScreen();
      default:                  return const SizedBox.shrink();
    }
  }

  Widget _buildStartScreen() {
    final skinData = BirdSkinData.skins[_currentSkin]!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [_GC.bgDeep, _GC.bgMid.withOpacity(0.9)]),
      ),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Bird hero with pulse
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              final s = 0.85 + _pulseController.value * 0.25;
              final g = _pulseController.value;
              return Stack(alignment: Alignment.center, children: [
                Container(width: 130, height: 130, decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: skinData.glowColor.withOpacity(0.15 + g * 0.2),
                      blurRadius: 50 + g * 30, spreadRadius: 10 + g * 10)],
                )),
                Container(width: 100, height: 100, decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: skinData.glowColor.withOpacity(0.2 + g * 0.35), width: 2),
                )),
                Transform.scale(scale: s,
                  child: Text(skinData.emoji, style: const TextStyle(fontSize: 68))),
              ]);
            },
          ),
          const SizedBox(height: 24),

          _NeonText('FLAPPY BIRD', fontSize: 32, color: _GC.neonGold),
          const SizedBox(height: 6),
          Text('FLY THROUGH THE PIPES',
              style: GoogleFonts.rajdhani(fontSize: 13, color: _GC.textSec, letterSpacing: 4)),

          const SizedBox(height: 32),

          // Control hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _GC.glassB),
              color: _GC.glassW,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _controlHint('TAP', 'Flap'),
              Container(width: 1, height: 28, color: _GC.glassB, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _controlHint('SPACE', 'Fly'),
              Container(width: 1, height: 28, color: _GC.glassB, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _controlHint('ESC', 'Pause'),
            ]),
          ),

          const SizedBox(height: 28),

          _NeonBtn(label: 'START FLYING', onTap: _startCountdown,
              color: _GC.neonGold, width: 240, icon: Icons.play_arrow_rounded),

          const SizedBox(height: 24),

          // Skin selector
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildSkinSelector(BirdSkin.classic, '🐦'),
            const SizedBox(width: 10),
            _buildSkinSelector(BirdSkin.phoenix, '🔥'),
            const SizedBox(width: 10),
            _buildSkinSelector(BirdSkin.cyber,   '🤖'),
            const SizedBox(width: 10),
            _buildSkinSelector(BirdSkin.golden,  '🏆'),
            const SizedBox(width: 10),
            _buildSkinSelector(BirdSkin.shadow,  '🌑'),
          ]),

          const SizedBox(height: 16),
          if (_bestScore > 0)
            Text('BEST  $_bestScore', style: GoogleFonts.orbitron(fontSize: 12, color: _GC.neonGold,
                shadows: [Shadow(color: _GC.neonGold, blurRadius: 8)])),
        ]),
      ),
    );
  }

  Widget _controlHint(String key, String action) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _GC.neonBlue.withOpacity(0.5)),
          color: _GC.neonBlue.withOpacity(0.1)),
        child: Text(key, style: GoogleFonts.orbitron(fontSize: 9, color: _GC.neonBlue, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 4),
      Text(action, style: GoogleFonts.rajdhani(fontSize: 11, color: _GC.textSec, letterSpacing: 1)),
    ]);
  }

  Widget _buildSkinSelector(BirdSkin skin, String emoji) {
    final isSelected = _currentSkin == skin;
    final skinData = BirdSkinData.skins[skin]!;
    return GestureDetector(
      onTap: () { setState(() => _currentSkin = skin); HapticFeedback.selectionClick(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? skinData.glowColor.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isSelected ? skinData.glowColor : Colors.white24, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: skinData.glowColor.withOpacity(0.4), blurRadius: 12)] : [],
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  Widget _buildCountdownScreen() {
    return Container(
      color: _GC.bgDeep.withOpacity(0.65),
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_countdownValue),
          tween: Tween(begin: 0.4, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (_, v, __) => Transform.scale(
            scale: v,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [_GC.neonGold.withOpacity(0.3), Colors.transparent]),
                border: Border.all(color: _GC.neonGold, width: 2),
                boxShadow: [BoxShadow(color: _GC.neonGold.withOpacity(0.5), blurRadius: 40, spreadRadius: 4)],
              ),
              child: Center(child: _NeonText('$_countdownValue', fontSize: 52, color: _GC.neonGold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPauseMenu() {
    return Container(
      color: _GC.bgDeep.withOpacity(0.82),
      child: Center(
        child: _GlassCard(
          borderColor: _GC.neonBlue,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.pause_circle_outline_rounded, color: _GC.neonBlue, size: 44),
            const SizedBox(height: 12),
            _NeonText('PAUSED', fontSize: 26, color: _GC.neonBlue),
            const SizedBox(height: 6),
            Text('Score: $_score  •  Level: $_level',
                style: GoogleFonts.rajdhani(fontSize: 13, color: _GC.textSec)),
            const SizedBox(height: 28),
            _NeonBtn(label: 'RESUME',  onTap: _togglePause, color: _GC.neonGreen, icon: Icons.play_arrow_rounded),
            const SizedBox(height: 12),
            _NeonBtn(label: 'RESTART', onTap: _restartGame,  color: _GC.neonGold,  icon: Icons.refresh_rounded),
            const SizedBox(height: 12),
            _NeonBtn(label: 'EXIT',    onTap: () => Navigator.pop(context), color: _GC.neonRed, icon: Icons.exit_to_app_rounded),
          ]),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final skinData = BirdSkinData.skins[_currentSkin]!;
    return Container(
      color: _GC.bgDeep.withOpacity(0.85),
      child: Center(
        child: _GlassCard(
          borderColor: _GC.neonRed,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(skinData.emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 8),
            _NeonText('GAME OVER', fontSize: 24, color: _GC.neonRed),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _statBox('SCORE', '$_score',         _GC.neonGold),
              _statBox('BEST',  '$_bestScore',      _GC.neonCyan),
              _statBox('LEVEL', '$_level',          _GC.neonPurp),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _statBox('💰', '$_collectedCoins',   _GC.neonGold),
              const SizedBox(width: 12),
              _statBox('⏱', '${_survivalTime}s',  _GC.neonGreen),
              const SizedBox(width: 12),
              if (_combo > 5) _statBox('COMBO', '×${_combo ~/ 5}', _GC.neonPink),
            ]),
            const SizedBox(height: 24),
            _NeonBtn(label: 'PLAY AGAIN', onTap: _restartGame, color: _GC.neonGreen, icon: Icons.replay_rounded),
            const SizedBox(height: 12),
            _NeonBtn(label: 'EXIT', onTap: () => Navigator.pop(context), color: _GC.neonRed, icon: Icons.exit_to_app_rounded),
          ]),
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
        color: color.withOpacity(0.07),
      ),
      child: Column(children: [
        Text(label, style: GoogleFonts.rajdhani(fontSize: 10, color: color.withOpacity(0.7), letterSpacing: 1.5)),
        Text(value, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w800, color: color,
            shadows: [Shadow(color: color, blurRadius: 6)])),
      ]),
    );
  }

  Widget _buildFeedbackMessage() {
    return Positioned(
      top: 130, left: 0, right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (_, v, __) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, -10 * (1 - v)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: (_feedbackColor ?? Colors.white).withOpacity(0.6)),
                  gradient: LinearGradient(colors: [
                    (_feedbackColor ?? Colors.white).withOpacity(0.2),
                    (_feedbackColor ?? Colors.white).withOpacity(0.05),
                  ]),
                  boxShadow: [BoxShadow(color: (_feedbackColor ?? Colors.white).withOpacity(0.3), blurRadius: 16)],
                ),
                child: Text(_feedbackMessage ?? '',
                  style: GoogleFonts.rajdhani(fontSize: 15, color: _feedbackColor ?? Colors.white,
                    fontWeight: FontWeight.w700, letterSpacing: 1,
                    shadows: [Shadow(color: _feedbackColor ?? Colors.white, blurRadius: 8)])),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Menu button kept for backward compat (used internally via _NeonBtn now)
  Widget _buildMenuButton(String text, VoidCallback onTap, Color color) =>
      _NeonBtn(label: text, onTap: onTap, color: color);

  @override
  void dispose() {
    _gameLoop?.cancel(); _spawnTimer?.cancel();
    _survivalTimer?.cancel(); _powerUpTimer?.cancel();
    _comboTimer?.cancel(); _weatherTimer?.cancel();
    _wingAnimationTimer?.cancel(); _scoreAnimTimer?.cancel();
    _pulseController.dispose(); _shakeController.dispose();
    _comboController.dispose(); _scoreController.dispose();
    _hudInController.dispose(); _bgGridController.dispose();
    _overlayFadeController.dispose();
    _confettiController.dispose(); _victoryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// =============================================================================
// BACKGROUND GRID PAINTER (cyberpunk parallax grid)
// =============================================================================

class _BgGridPainter extends CustomPainter {
  final double t;
  _BgGridPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final vp = Paint()..color = _GC.neonBlue.withOpacity(0.03)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 45) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), vp);
    }
    final ho = (t * size.height) % 45;
    final hp = Paint()..color = _GC.neonPurp.withOpacity(0.03)..strokeWidth = 1;
    for (double y = -45 + ho; y < size.height; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hp);
    }
    // Corner ambient glow
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = RadialGradient(colors: [_GC.neonPurp.withOpacity(0.06), Colors.transparent])
          .createShader(Rect.fromCircle(center: Offset(0, size.height), radius: 220)));
  }

  @override
  bool shouldRepaint(_BgGridPainter old) => old.t != t;
}

// =============================================================================
// ADVANCED FLAPPY PAINTER (game world renderer)
// =============================================================================

class AdvancedFlappyPainter extends CustomPainter {
  final double birdY;
  final double birdRotation;
  final double wingAngle;
  final List<Pipe> pipes;
  final List<Collectible> collectibles;
  final List<PowerUp> powerUps;
  final List<Particle> particles;
  final List<Cloud> clouds;
  final double backgroundOffset;
  final double groundOffset;
  final BirdSkin currentSkin;
  final WeatherEffect currentWeather;
  final PowerUpType? activePowerUp;
  final double shakeOffset;

  AdvancedFlappyPainter({
    required this.birdY, required this.birdRotation, required this.wingAngle,
    required this.pipes, required this.collectibles, required this.powerUps,
    required this.particles, required this.clouds,
    required this.backgroundOffset, required this.groundOffset,
    required this.currentSkin, required this.currentWeather,
    required this.activePowerUp, required this.shakeOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawSky(canvas, size);

    // Stars / rain
    if (currentWeather == WeatherEffect.night || currentWeather == WeatherEffect.space) {
      final sp = Paint()..color = Colors.white.withOpacity(0.4);
      for (int i = 0; i < 80; i++) {
        final x = (i * 131 + backgroundOffset * 50) % w;
        final y = (i * 253) % (h * 0.7);
        canvas.drawCircle(Offset(x, y), 0.8 + (i % 3) * 0.5, sp);
      }
    }
    if (currentWeather == WeatherEffect.rain) {
      final rp = Paint()..color = _GC.neonBlue.withOpacity(0.18)..strokeWidth = 1;
      final t = DateTime.now().millisecondsSinceEpoch;
      for (int i = 0; i < 80; i++) {
        final x = (i * 73.0 + (t / 30)) % w;
        final y = (i * 131.0) % h;
        canvas.drawLine(Offset(x, y), Offset(x - 3, y + 15), rp);
      }
    }

    // Clouds
    for (final cloud in clouds) {
      final cx = cloud.x * w; final cy = cloud.y * h; final cs = cloud.size * w;
      final cp = Paint()..color = Colors.white.withOpacity(cloud.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(cx, cy), cs, cp);
      canvas.drawCircle(Offset(cx - cs * 0.5, cy - cs * 0.2), cs * 0.7, cp);
      canvas.drawCircle(Offset(cx + cs * 0.5, cy - cs * 0.15), cs * 0.6, cp);
    }

    // Pipes
    for (final pipe in pipes) {
      final px = pipe.x * w;
      final pw = FlappyBirdConfig.pipeWidth * w;
      final gcy = pipe.gapY * h;
      final gh  = FlappyBirdConfig.pipeGap * h;

      // Top pipe
      _drawPipe(canvas, Rect.fromLTWH(px - pw / 2, 0, pw, gcy - gh / 2), true);
      // Top cap
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(px - pw / 2 - 7, gcy - gh / 2 - 30, pw + 14, 30), const Radius.circular(10)),
        Paint()..color = _GC.neonGreen,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(px - pw / 2 - 7, gcy - gh / 2 - 30, pw + 14, 30), const Radius.circular(10)),
        Paint()..color = _GC.neonGreen.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.5,
      );
      // Bottom pipe
      _drawPipe(canvas, Rect.fromLTWH(px - pw / 2, gcy + gh / 2, pw, h - (gcy + gh / 2)), false);
      // Bottom cap
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(px - pw / 2 - 7, gcy + gh / 2, pw + 14, 30), const Radius.circular(10)),
        Paint()..color = _GC.neonGreen,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(px - pw / 2 - 7, gcy + gh / 2, pw + 14, 30), const Radius.circular(10)),
        Paint()..color = _GC.neonGreen.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.5,
      );
    }

    // Collectibles
    for (final c in collectibles) {
      final x = c.x * w; final y = c.y * h;
      final bounce = sin(c.animationOffset * 8) * 5;
      canvas.drawCircle(Offset(x + 12, y + bounce), 16,
        Paint()..color = c.color.withOpacity(0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      canvas.drawCircle(Offset(x + 12, y + bounce), 12,
        Paint()..shader = RadialGradient(colors: [c.color, c.color.withOpacity(0.55)])
            .createShader(Rect.fromCircle(center: Offset(x + 12, y + bounce), radius: 12)));
      canvas.drawCircle(Offset(x + 12, y + bounce), 12,
        Paint()..color = c.color..style = PaintingStyle.stroke..strokeWidth = 1);
      _drawText(canvas, c.emoji, 15, Offset(x + 4, y + bounce - 9));
    }

    // Power-ups
    for (final p in powerUps) {
      final x = p.x * w; final y = p.y * h;
      final float = sin(p.animationOffset * 5) * 5;
      canvas.drawCircle(Offset(x + 15, y + float), 20,
        Paint()..color = p.color.withOpacity(0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y + float - 15, 30, 30), const Radius.circular(10)),
        Paint()..color = p.color.withOpacity(0.8));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y + float - 15, 30, 30), const Radius.circular(10)),
        Paint()..color = p.color..style = PaintingStyle.stroke..strokeWidth = 1.5);
      _drawText(canvas, p.emoji, 20, Offset(x + 5, y + float - 11));
    }

    // Particles
    for (final particle in particles) {
      canvas.drawCircle(
        Offset(particle.x * w, particle.y * h), particle.size,
        Paint()..color = particle.color.withOpacity(particle.opacity.clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    }

    // Ground
    final groundRect = Rect.fromLTWH(0, h - FlappyBirdConfig.groundHeight * h, w, FlappyBirdConfig.groundHeight * h);
    canvas.drawRect(groundRect, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [const Color(0xFF0A1A0A), const Color(0xFF040A04)],
    ).createShader(groundRect));

    // Ground neon scanline
    canvas.drawLine(
      Offset(0, h - FlappyBirdConfig.groundHeight * h - 1),
      Offset(w, h - FlappyBirdConfig.groundHeight * h - 1),
      Paint()..color = _GC.neonGreen.withOpacity(0.6)..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(0, h - FlappyBirdConfig.groundHeight * h - 1),
      Offset(w, h - FlappyBirdConfig.groundHeight * h - 1),
      Paint()..color = _GC.neonGreen.withOpacity(0.25)..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Ground dashes
    final dp = Paint()..color = _GC.neonGreen.withOpacity(0.2)..strokeWidth = 2;
    final dOff = (groundOffset * w) % 60;
    for (double x = -60 + dOff; x < w + 60; x += 60) {
      canvas.drawLine(
        Offset(x, h - FlappyBirdConfig.groundHeight * h + 10),
        Offset(x + 30, h - FlappyBirdConfig.groundHeight * h + 10), dp);
    }

    // Bird
    _drawBird(canvas, w, h);
  }

  void _drawSky(Canvas canvas, Size size) {
    Color s, e;
    switch (currentWeather) {
      case WeatherEffect.day:    s = const Color(0xFF03010A); e = const Color(0xFF0D0520); break;
      case WeatherEffect.night:  s = const Color(0xFF000008); e = const Color(0xFF050012); break;
      case WeatherEffect.sunset: s = const Color(0xFF150508); e = const Color(0xFF251018); break;
      case WeatherEffect.rain:   s = const Color(0xFF080818); e = const Color(0xFF102030); break;
      case WeatherEffect.space:  s = const Color(0xFF03000A); e = const Color(0xFF0A001A); break;
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [s, e]).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
  }

  void _drawPipe(Canvas canvas, Rect rect, bool isTop) {
    if (rect.height <= 0) return;

    // Gradient body
    canvas.drawRect(rect, Paint()..shader = LinearGradient(
      begin: Alignment.centerLeft, end: Alignment.centerRight,
      colors: [_GC.neonGreen.withOpacity(0.5), _GC.neonGreen.withOpacity(0.9), _GC.neonGreen.withOpacity(0.6)],
      stops: const [0, 0.5, 1],
    ).createShader(rect));

    // Glow
    canvas.drawRect(rect, Paint()..color = _GC.neonGreen.withOpacity(FlappyBirdConfig.pipeGlowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Edge highlight
    canvas.drawRect(rect, Paint()..color = _GC.neonGreen.withOpacity(0.5)
      ..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  void _drawBird(Canvas canvas, double w, double h) {
    final skinData = BirdSkinData.skins[currentSkin]!;
    final birdCenter = Offset(w * 0.2, h * birdY);
    final birdRadius = w * FlappyBirdConfig.birdSize;

    canvas.save();
    canvas.translate(birdCenter.dx, birdCenter.dy);
    canvas.rotate(birdRotation);

    // Glow
    canvas.drawCircle(Offset.zero, birdRadius * 1.15,
      Paint()..color = skinData.glowColor.withOpacity(FlappyBirdConfig.birdGlowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));

    // Invincibility aura
    if (activePowerUp == PowerUpType.invincibility) {
      final pulse = (DateTime.now().millisecondsSinceEpoch % 400) / 400;
      canvas.drawCircle(Offset.zero, birdRadius * 1.4,
        Paint()..color = _GC.neonPink.withOpacity(0.2 + pulse * 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16));
      canvas.drawCircle(Offset.zero, birdRadius * 1.4,
        Paint()..color = _GC.neonPink.withOpacity(0.4 + pulse * 0.2)
          ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }

    // Shield aura
    if (activePowerUp == PowerUpType.shield) {
      final pulse = (DateTime.now().millisecondsSinceEpoch % 500) / 500;
      canvas.drawCircle(Offset.zero, birdRadius * 1.3,
        Paint()..color = _GC.neonBlue.withOpacity(0.18 + pulse * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      canvas.drawCircle(Offset.zero, birdRadius * 1.3,
        Paint()..color = _GC.neonBlue.withOpacity(0.35 + pulse * 0.2)
          ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }

    // Body gradient
    canvas.drawCircle(Offset.zero, birdRadius,
      Paint()..shader = RadialGradient(
        colors: skinData.gradientColors, center: const Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: birdRadius)));

    // Body rim
    canvas.drawCircle(Offset.zero, birdRadius,
      Paint()..color = skinData.glowColor.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1);

    // Eye
    canvas.drawCircle(Offset(birdRadius * 0.35, -birdRadius * 0.2), birdRadius * 0.13, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(birdRadius * 0.40, -birdRadius * 0.22), birdRadius * 0.07, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(birdRadius * 0.43, -birdRadius * 0.25), birdRadius * 0.025, Paint()..color = Colors.white);

    // Beak
    final beakPath = Path()
      ..moveTo(birdRadius * 0.5, -birdRadius * 0.1)
      ..lineTo(birdRadius * 0.72, 0)
      ..lineTo(birdRadius * 0.5,  birdRadius * 0.05)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = _GC.neonOrange);

    // Wing
    canvas.save();
    canvas.translate(-birdRadius * 0.35, 0);
    canvas.rotate(wingAngle);
    final wingPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-birdRadius * 0.6, -birdRadius * 0.35, -birdRadius * 0.7, 0)
      ..quadraticBezierTo(-birdRadius * 0.5, birdRadius * 0.25, 0, 0);
    canvas.drawPath(wingPath, Paint()..color = skinData.color.withOpacity(0.85));
    canvas.drawPath(wingPath, Paint()..color = skinData.glowColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke..strokeWidth = 1);
    canvas.restore();

    // Tail
    final tailPath = Path()
      ..moveTo(-birdRadius * 0.8,  0)
      ..lineTo(-birdRadius * 1.1, -birdRadius * 0.25)
      ..lineTo(-birdRadius * 1.0,  birdRadius * 0.15)
      ..close();
    canvas.drawPath(tailPath, Paint()..color = skinData.color);

    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, double fontSize, Offset offset) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(AdvancedFlappyPainter old) => true;
}

// =============================================================================
// GAME RESULT SCREEN (placeholder — remove when integrating)
// =============================================================================

class GameResultScreen extends StatefulWidget {
  final bool won;
  final int coins;
  final int xp;
  final int score;
  final String gameName;
  final VoidCallback onContinue;

  const GameResultScreen({
    super.key, required this.won, required this.coins, required this.xp,
    required this.score, required this.gameName, required this.onContinue,
  });

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _enter;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _enter = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _ctrl.forward();
    if (widget.won) _confetti.play();
  }

  @override
  void dispose() { _ctrl.dispose(); _confetti.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = widget.won ? _GC.neonGold : _GC.neonRed;
    return Scaffold(
      backgroundColor: _GC.bgDeep,
      body: Stack(children: [
        CustomPaint(painter: _BgGridPainter(0), child: const SizedBox.expand()),
        Center(
          child: ScaleTransition(scale: _enter, child: FadeTransition(opacity: _enter,
            child: _GlassCard(borderColor: color, padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(widget.won ? '🏆' : '💀', style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                _NeonText(widget.won ? 'VICTORY!' : 'GAME OVER', fontSize: 28, color: color),
                const SizedBox(height: 6),
                Text(widget.gameName, style: GoogleFonts.rajdhani(fontSize: 13, color: _GC.textSec, letterSpacing: 3)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.4)), color: color.withOpacity(0.07)),
                  child: _NeonText('${widget.score}', fontSize: 44, color: color),
                ),
                Text('SCORE', style: GoogleFonts.rajdhani(fontSize: 11, color: _GC.textDim, letterSpacing: 3)),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _rewardPill('💰', '+${widget.coins}', _GC.neonGold),
                  const SizedBox(width: 12),
                  _rewardPill('⭐', '+${widget.xp} XP', _GC.neonCyan),
                ]),
                const SizedBox(height: 28),
                _NeonBtn(label: 'CONTINUE', onTap: widget.onContinue,
                    color: _GC.neonGreen, width: 200, icon: Icons.chevron_right_rounded),
              ]),
            ),
          )),
        ),
        if (widget.won)
          Align(alignment: Alignment.topCenter, child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [_GC.neonGold, _GC.neonGreen, _GC.neonCyan, _GC.neonPink],
            numberOfParticles: 35,
          )),
      ]),
    );
  }

  Widget _rewardPill(String icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        color: color.withOpacity(0.1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.orbitron(fontSize: 13, color: color, fontWeight: FontWeight.w700,
            shadows: [Shadow(color: color, blurRadius: 6)])),
      ]),
    );
  }
}

// =============================================================================
// USAGE EXAMPLE:
// =============================================================================
/*
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedFlappyBirdGame(),
  ),
);

// With custom skin:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedFlappyBirdGame(initialSkin: BirdSkin.phoenix),
  ),
);
*/