// =============================================================================
// FILE: dino_run_game_advanced.dart
// =============================================================================
// ADVANCED DINO RUN GAME - Premium Endless Runner Arcade Game
// Features: Smooth physics, Multiple obstacles, Power-ups, Animations
// UPGRADED: Premium gaming UI with glassmorphism, neon glow, advanced HUD
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// CONSTANTS & CONFIGURATION
// =============================================================================

class DinoRunConfig {
  // Physics
  static const double gravity = 0.8;
  static const double jumpForce = -11;
  static const double doubleJumpForce = -9;
  static const double maxVelocity = 15;
  static const double groundY = 0.75;

  // Game Speed
  static const double baseSpeed = 8;
  static const double maxSpeed = 20;
  static const double speedIncreasePer100Score = 0.5;

  // Obstacle Spawning
  static const double minSpawnInterval = 1.0;
  static const double maxSpawnInterval = 2.5;
  static const int maxObstacles = 5;

  // Power-ups
  static const double powerUpSpawnChance = 0.08;
  static const int powerUpDuration = 8;

  // Collectibles
  static const double coinSpawnChance = 0.15;
  static const int coinValue = 10;

  // Victory Conditions
  static const int winScoreTarget = 50;
  static const int winCoins = 60;
  static const int winXp = 90;
  static const int lossXp = 15;

  // Visual
  static const double groundLineWidth = 3;
  static const double dinoSize = 45;
  static const double obstacleWidth = 30;
  static const double obstacleHeight = 40;
}

// =============================================================================
// DESIGN TOKENS - Premium Gaming Color System
// =============================================================================

class GameColors {
  // Core palette
  static const Color bgDeep = Color(0xFF03010A);
  static const Color bgMid = Color(0xFF07030F);
  static const Color bgSurface = Color(0xFF0D0520);

  // Neon accents
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonPurple = Color(0xFF9B5DE5);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonGold = Color(0xFFFFD700);
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonRed = Color(0xFFFF0044);
  static const Color neonCyan = Color(0xFF00F5FF);

  // Glass surfaces
  static Color glassWhite = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.12);
  static Color glassHighlight = Colors.white.withOpacity(0.08);

  // Text
  static const Color textPrimary = Color(0xFFF0F8FF);
  static const Color textSecondary = Color(0xFF8AACCC);
  static const Color textDim = Color(0xFF3A5A7A);
}

// =============================================================================
// ENUMS
// =============================================================================

enum GameState { idle, countdown, playing, paused, gameOver }

enum ObstacleType { cactus, bird, rock, movingTrap, fire }

enum PowerUpType { shield, speedBoost, magnet, doubleScore, invincibility }

enum DinoSkin { classic, neon, lava, ice, gold, shadow }

enum WeatherEffect { clear, rain, sandstorm, night, sunset }

// =============================================================================
// DATA MODELS
// =============================================================================

class Obstacle {
  final ObstacleType type;
  double x;
  final double y;
  final double width;
  final double height;
  bool isActive;
  double animationOffset = 0;

  Obstacle({
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.isActive = true,
  });

  factory Obstacle.random(double groundY, double screenHeight, Random random) {
    final types = ObstacleType.values;
    final type = types[random.nextInt(types.length)];

    double y = groundY;
    double width = DinoRunConfig.obstacleWidth;
    double height = DinoRunConfig.obstacleHeight;

    switch (type) {
      case ObstacleType.bird:
        y = groundY - 60 - random.nextDouble() * 40;
        width = 35;
        height = 25;
        break;
      case ObstacleType.rock:
        height = 25;
        break;
      case ObstacleType.movingTrap:
        width = 40;
        height = 30;
        break;
      case ObstacleType.fire:
        height = 35;
        width = 25;
        break;
      default:
        break;
    }

    return Obstacle(type: type, x: 1.0, y: y, width: width, height: height);
  }

  String get emoji {
    switch (type) {
      case ObstacleType.cactus: return '🌵';
      case ObstacleType.bird: return '🦅';
      case ObstacleType.rock: return '🪨';
      case ObstacleType.movingTrap: return '⚙️';
      case ObstacleType.fire: return '🔥';
    }
  }

  Color get color {
    switch (type) {
      case ObstacleType.cactus: return const Color(0xFF4CAF50);
      case ObstacleType.bird: return const Color(0xFFFF6B6B);
      case ObstacleType.rock: return const Color(0xFF795548);
      case ObstacleType.movingTrap: return const Color(0xFF9E9E9E);
      case ObstacleType.fire: return const Color(0xFFFF5722);
    }
  }
}

class PowerUp {
  final PowerUpType type;
  double x;
  final double y;
  bool isActive;
  int remainingDuration;

  PowerUp({
    required this.type,
    required this.x,
    required this.y,
    this.isActive = true,
    this.remainingDuration = DinoRunConfig.powerUpDuration,
  });

  factory PowerUp.random(double groundY, Random random) {
    final types = PowerUpType.values;
    final type = types[random.nextInt(types.length)];
    return PowerUp(type: type, x: 1.0, y: groundY - 40);
  }

  String get emoji {
    switch (type) {
      case PowerUpType.shield: return '🛡️';
      case PowerUpType.speedBoost: return '⚡';
      case PowerUpType.magnet: return '🧲';
      case PowerUpType.doubleScore: return '2️⃣';
      case PowerUpType.invincibility: return '✨';
    }
  }

  Color get color {
    switch (type) {
      case PowerUpType.shield: return const Color(0xFF2196F3);
      case PowerUpType.speedBoost: return const Color(0xFFFFD700);
      case PowerUpType.magnet: return const Color(0xFF9C27B0);
      case PowerUpType.doubleScore: return const Color(0xFFFF4081);
      case PowerUpType.invincibility: return const Color(0xFF00BCD4);
    }
  }

  String get name {
    switch (type) {
      case PowerUpType.shield: return 'Shield';
      case PowerUpType.speedBoost: return 'Speed';
      case PowerUpType.magnet: return 'Magnet';
      case PowerUpType.doubleScore: return '2x Score';
      case PowerUpType.invincibility: return 'Invincible';
    }
  }
}

class CollectibleCoin {
  double x;
  double y;
  bool isActive;
  double animationOffset;

  CollectibleCoin({
    required this.x,
    required this.y,
    this.isActive = true,
    this.animationOffset = 0,
  });

  factory CollectibleCoin.random(double groundY, Random random) {
    return CollectibleCoin(x: 1.0, y: groundY - 20 - random.nextDouble() * 40);
  }
}

class Particle {
  double x, y, vx, vy, size, opacity, lifetime, maxLifetime;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.lifetime,
  })  : maxLifetime = lifetime,
        opacity = 1.0;

  bool update() {
    x += vx;
    y += vy;
    vy += 0.2;
    lifetime -= 1 / 60;
    opacity = lifetime / maxLifetime;
    return lifetime > 0;
  }
}

class Cloud {
  double x, y, speed, size;
  Cloud({required this.x, required this.y, required this.speed, required this.size});
}

class DinoStatistics {
  int highestScore = 0;
  int totalDistance = 0;
  int totalCoinsCollected = 0;
  int totalGamesPlayed = 0;
  int totalObstaclesAvoided = 0;
  int longestSurvival = 0;

  void updateStats(int score, int coins, int obstacles, int survivalTime) {
    if (score > highestScore) highestScore = score;
    totalDistance += score;
    totalCoinsCollected += coins;
    totalGamesPlayed++;
    totalObstaclesAvoided += obstacles;
    if (survivalTime > longestSurvival) longestSurvival = survivalTime;
  }
}

// =============================================================================
// REUSABLE UI COMPONENTS
// =============================================================================

/// Glassmorphic card with neon border glow
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final double blurRadius;
  final EdgeInsets padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.borderColor = GameColors.neonBlue,
    this.borderWidth = 1.5,
    this.blurRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor.withOpacity(0.5), width: borderWidth),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GameColors.glassHighlight,
            GameColors.glassWhite,
          ],
        ),
        boxShadow: [
          BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: blurRadius, spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Neon glow text widget
class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double glowRadius;

  const NeonText(
    this.text, {
    super.key,
    required this.fontSize,
    required this.color,
    this.fontWeight = FontWeight.bold,
    this.glowRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.orbitron(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        shadows: [
          Shadow(color: color.withOpacity(0.9), blurRadius: glowRadius),
          Shadow(color: color.withOpacity(0.5), blurRadius: glowRadius * 2),
        ],
      ),
    );
  }
}

/// Animated neon button
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double width;
  final double height;
  final IconData? icon;

  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
    this.width = 220,
    this.height = 52,
    this.icon,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _ctrl.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _ctrl.reverse();
      },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(color: widget.color, width: _pressed ? 2 : 1.5),
            gradient: LinearGradient(
              colors: [
                widget.color.withOpacity(_pressed ? 0.35 : 0.18),
                widget.color.withOpacity(_pressed ? 0.12 : 0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_pressed ? 0.6 : 0.35),
                blurRadius: _pressed ? 24 : 14,
                spreadRadius: _pressed ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.color, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                  letterSpacing: 1.5,
                  shadows: [Shadow(color: widget.color, blurRadius: 8)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// HUD stat pill
class HUDStatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? prefix;

  const HUDStatPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.18), color.withOpacity(0.04)],
        ),
        boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 9,
              color: color.withOpacity(0.75),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            '${prefix ?? ''}$value',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
              shadows: [Shadow(color: color, blurRadius: 6)],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MAIN DINO RUN GAME WIDGET
// =============================================================================

class AdvancedDinoRunGame extends StatefulWidget {
  final DinoSkin initialSkin;

  const AdvancedDinoRunGame({super.key, this.initialSkin = DinoSkin.classic});

  @override
  State<AdvancedDinoRunGame> createState() => _AdvancedDinoRunGameState();
}

class _AdvancedDinoRunGameState extends State<AdvancedDinoRunGame>
    with TickerProviderStateMixin {
  // =========================================================================
  // GAME STATE
  // =========================================================================
  double _dinoY = 0;
  double _velocity = 0;
  bool _isOnGround = true;
  bool _canDoubleJump = true;
  bool _isSliding = false;
  double _currentSpeed = DinoRunConfig.baseSpeed;
  int _score = 0;
  int _combo = 0;
  int _level = 1;
  int _coinsCollected = 0;
  int _obstaclesAvoided = 0;
  double _distanceTraveled = 0;

  GameState _gameState = GameState.idle;
  DinoSkin _currentSkin = DinoSkin.classic;
  WeatherEffect _currentWeather = WeatherEffect.clear;

  final List<Obstacle> _obstacles = [];
  final List<PowerUp> _powerUps = [];
  final List<CollectibleCoin> _coins = [];
  final List<Particle> _particles = [];
  final List<Cloud> _clouds = [];

  PowerUpType? _activePowerUp;
  int _powerUpRemaining = 0;
  Timer? _powerUpTimer;
  int _scoreMultiplier = 1;
  bool _isInvincible = false;
  bool _hasShield = false;

  Timer? _gameLoopTimer;
  Timer? _spawnTimer;
  Timer? _weatherTimer;

  // Animation controllers
  late AnimationController _dinoRunController;
  late AnimationController _groundController;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late AnimationController _comboController;
  late AnimationController _hudEntranceController;
  late AnimationController _scorePopController;
  late AnimationController _overlayFadeController;
  late AnimationController _bgGridController;
  late ConfettiController _confettiController;
  late ConfettiController _victoryController;

  // Derived animations
  late Animation<double> _hudEntrance;
  late Animation<double> _scorePop;
  late Animation<double> _overlayFade;

  double _groundOffset = 0;
  double _dinoAnimationFrame = 0;
  int _dinoRunFrame = 0;
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _pointsEarned = 0;
  int _displayedScore = 0; // Smooth score animation
  int _countdownValue = 3;

  final DinoStatistics _statistics = DinoStatistics();
  int _survivalTime = 0;
  Timer? _survivalTimer;
  Timer? _scoreAnimTimer;

  final Random _random = Random();

  final List<String> _dinoEmojis = ['🦕', '🦖'];

  final FocusNode _focusNode = FocusNode();

  // =========================================================================
  // INITIALIZATION
  // =========================================================================

  @override
  void initState() {
    super.initState();
    _currentSkin = widget.initialSkin;
    _initControllers();
    _initClouds();
    _loadStatistics();
    _initWeather();
  }

  void _initControllers() {
    _dinoRunController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {
          _dinoAnimationFrame = _dinoRunController.value;
          _dinoRunFrame = (_dinoRunController.value * 2).toInt() % 2;
        });
      });

    _groundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _hudEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _hudEntrance = CurvedAnimation(parent: _hudEntranceController, curve: Curves.easeOutBack);

    _scorePopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scorePop = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _scorePopController, curve: Curves.elasticOut),
    );

    _overlayFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _overlayFade = CurvedAnimation(parent: _overlayFadeController, curve: Curves.easeOut);

    _bgGridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _victoryController = ConfettiController(duration: const Duration(seconds: 3));

    _overlayFadeController.forward();
  }

  void _initClouds() {
    for (int i = 0; i < 5; i++) {
      _clouds.add(Cloud(
        x: _random.nextDouble(),
        y: 0.1 + _random.nextDouble() * 0.3,
        speed: 0.5 + _random.nextDouble() * 1.5,
        size: 40 + _random.nextDouble() * 40,
      ));
    }
  }

  void _initWeather() {
    _weatherTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _gameState == GameState.playing) {
        setState(() {
          final weathers = WeatherEffect.values;
          _currentWeather = weathers[_random.nextInt(weathers.length)];
        });
      }
    });
  }

  Future<void> _loadStatistics() async {
    setState(() {});
  }

  // =========================================================================
  // GAME START & RESTART
  // =========================================================================

  void _startCountdown() {
    _overlayFadeController.forward(from: 0);
    setState(() {
      _gameState = GameState.countdown;
      _countdownValue = 3;
    });

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
      _dinoY = 0;
      _velocity = 0;
      _score = 0;
      _displayedScore = 0;
      _combo = 0;
      _level = 1;
      _coinsCollected = 0;
      _obstaclesAvoided = 0;
      _distanceTraveled = 0;
      _currentSpeed = DinoRunConfig.baseSpeed;
      _activePowerUp = null;
      _isInvincible = false;
      _hasShield = false;
      _scoreMultiplier = 1;
      _obstacles.clear();
      _powerUps.clear();
      _coins.clear();
      _particles.clear();
    });

    _hudEntranceController.forward(from: 0);
    _dinoRunController.repeat();
    _startGameLoop();
    _startSpawnTimer();
    _startSurvivalTimer();
    _startScoreAnimTimer();
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_gameState == GameState.playing && mounted) {
        _updateGame();
      }
    });
  }

  void _startSpawnTimer() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(
      Duration(milliseconds: (800 + _random.nextInt(700)).toInt()),
      (_) {
        if (_gameState == GameState.playing && mounted) {
          _spawnObstacle();
          if (_random.nextDouble() < DinoRunConfig.powerUpSpawnChance) _spawnPowerUp();
          if (_random.nextDouble() < DinoRunConfig.coinSpawnChance) _spawnCoin();
        }
      },
    );
  }

  void _startSurvivalTimer() {
    _survivalTimer?.cancel();
    _survivalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_gameState == GameState.playing && mounted) {
        setState(() => _survivalTime++);
      }
    });
  }

  /// Smooth animated score counter
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
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    _survivalTimer?.cancel();
    _powerUpTimer?.cancel();
    _scoreAnimTimer?.cancel();
    _survivalTime = 0;
    _startCountdown();
  }

  // =========================================================================
  // GAME UPDATE LOGIC
  // =========================================================================

  void _updateGame() {
    setState(() {
      _velocity += DinoRunConfig.gravity;
      if (_velocity > DinoRunConfig.maxVelocity) _velocity = DinoRunConfig.maxVelocity;
      _dinoY += _velocity;

      if (_dinoY >= 0) {
        _dinoY = 0;
        _velocity = 0;
        _isOnGround = true;
        _canDoubleJump = true;
        _isSliding = false;
      } else {
        _isOnGround = false;
      }

      _distanceTraveled += _currentSpeed / 100;
      _score = (_distanceTraveled).toInt();

      _updateDifficulty();

      for (var cloud in _clouds) {
        cloud.x -= cloud.speed / 1000;
        if (cloud.x < -0.2) {
          cloud.x = 1.2;
          cloud.y = 0.1 + _random.nextDouble() * 0.3;
        }
      }

      _groundOffset += _currentSpeed / 50;

      for (int i = 0; i < _obstacles.length; i++) {
        final obstacle = _obstacles[i];
        obstacle.x -= _currentSpeed / 100;
        if (obstacle.type == ObstacleType.movingTrap) obstacle.animationOffset += 0.1;
        if (obstacle.x < -0.1) {
          _obstacles.removeAt(i);
          _obstaclesAvoided++;
          i--;
        }
      }

      for (int i = 0; i < _powerUps.length; i++) {
        _powerUps[i].x -= _currentSpeed / 100;
        if (_powerUps[i].x < -0.1) { _powerUps.removeAt(i); i--; }
      }

      bool magnetActive = _activePowerUp == PowerUpType.magnet;
      for (int i = 0; i < _coins.length; i++) {
        final coin = _coins[i];
        if (magnetActive) {
          coin.x -= (_currentSpeed / 100) * 0.5;
          final dx = 0.15 - coin.x;
          if (dx.abs() < 0.2) coin.x += dx * 0.1;
        } else {
          coin.x -= _currentSpeed / 100;
        }
        coin.animationOffset += 0.1;
        if (coin.x < -0.1) { _coins.removeAt(i); i--; }
      }

      _particles.removeWhere((p) => !p.update());
      _checkCollisions();
    });
  }

  void _updateDifficulty() {
    final targetSpeed =
        DinoRunConfig.baseSpeed + (_score / 100) * DinoRunConfig.speedIncreasePer100Score;
    _currentSpeed = targetSpeed.clamp(DinoRunConfig.baseSpeed, DinoRunConfig.maxSpeed);

    final newLevel = 1 + (_score ~/ 100);
    if (newLevel > _level) {
      _level = newLevel;
      _showFeedback('LEVEL $_level!', GameColors.neonGold);
      HapticFeedback.mediumImpact();
    }
  }

  void _spawnObstacle() {
    if (_obstacles.length >= DinoRunConfig.maxObstacles) return;
    final obstacle = Obstacle.random(
      DinoRunConfig.groundY * MediaQuery.of(context).size.height,
      MediaQuery.of(context).size.height,
      _random,
    );
    _obstacles.add(obstacle);
  }

  void _spawnPowerUp() {
    final powerUp = PowerUp.random(
      DinoRunConfig.groundY * MediaQuery.of(context).size.height,
      _random,
    );
    _powerUps.add(powerUp);
  }

  void _spawnCoin() {
    final coin = CollectibleCoin.random(
      DinoRunConfig.groundY * MediaQuery.of(context).size.height,
      _random,
    );
    _coins.add(coin);
  }

  void _checkCollisions() {
    final dinoRect = Rect.fromLTWH(
      0.12,
      DinoRunConfig.groundY + (_dinoY / MediaQuery.of(context).size.height),
      DinoRunConfig.dinoSize / MediaQuery.of(context).size.width,
      DinoRunConfig.dinoSize / MediaQuery.of(context).size.height,
    );

    for (int i = 0; i < _obstacles.length; i++) {
      final obstacle = _obstacles[i];
      final obstacleRect = Rect.fromLTWH(
        obstacle.x,
        obstacle.y / MediaQuery.of(context).size.height,
        obstacle.width / MediaQuery.of(context).size.width,
        obstacle.height / MediaQuery.of(context).size.height,
      );

      if (dinoRect.overlaps(obstacleRect)) {
        if (_isInvincible || _hasShield) {
          if (_hasShield) {
            _hasShield = false;
            _showFeedback('🛡️ Shield protected you!', GameColors.neonBlue);
            _addShieldBreakParticles();
          }
          _obstacles.removeAt(i);
          i--;
        } else {
          _gameOver();
          return;
        }
      }
    }

    for (int i = 0; i < _powerUps.length; i++) {
      final powerUp = _powerUps[i];
      final powerUpRect = Rect.fromLTWH(
        powerUp.x,
        powerUp.y / MediaQuery.of(context).size.height,
        30 / MediaQuery.of(context).size.width,
        30 / MediaQuery.of(context).size.height,
      );
      if (dinoRect.overlaps(powerUpRect)) {
        _activatePowerUp(powerUp);
        _powerUps.removeAt(i);
        break;
      }
    }

    for (int i = 0; i < _coins.length; i++) {
      final coin = _coins[i];
      final coinRect = Rect.fromLTWH(
        coin.x,
        coin.y / MediaQuery.of(context).size.height,
        20 / MediaQuery.of(context).size.width,
        20 / MediaQuery.of(context).size.height,
      );

      if (dinoRect.overlaps(coinRect)) {
        final coinsEarned = DinoRunConfig.coinValue * _scoreMultiplier;
        _coinsCollected += coinsEarned;
        _score += coinsEarned;
        _combo++;

        _addCoinParticles(coin.x, coin.y);
        _showFeedback('+$coinsEarned 💰', GameColors.neonGold);
        _coins.removeAt(i);

        if (_combo > 0 && _combo % 10 == 0) {
          _showFeedback('COMBO x${_combo ~/ 10}!', GameColors.neonPink);
          _comboController.forward(from: 0);
        }

        HapticFeedback.lightImpact();
        _scorePopController.forward(from: 0);
        i--;
      }
    }
  }

  void _activatePowerUp(PowerUp powerUp) {
    setState(() {
      _activePowerUp = powerUp.type;
      _powerUpRemaining = powerUp.remainingDuration;
    });

    _showFeedback('${powerUp.emoji} ${powerUp.name} ACTIVATED!', powerUp.color);
    _addPowerUpParticles(powerUp);
    HapticFeedback.mediumImpact();

    switch (powerUp.type) {
      case PowerUpType.shield:
        _hasShield = true;
        break;
      case PowerUpType.speedBoost:
        _currentSpeed = (_currentSpeed * 1.5).clamp(DinoRunConfig.baseSpeed, DinoRunConfig.maxSpeed);
        break;
      case PowerUpType.magnet:
        break;
      case PowerUpType.doubleScore:
        _scoreMultiplier = 2;
        break;
      case PowerUpType.invincibility:
        _isInvincible = true;
        break;
    }

    _startPowerUpTimer(powerUp.type);
  }

  void _startPowerUpTimer(PowerUpType type) {
    _powerUpTimer?.cancel();
    _powerUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _powerUpRemaining--;
        if (_powerUpRemaining <= 0) {
          timer.cancel();
          _deactivatePowerUp(type);
        }
      });
    });
  }

  void _deactivatePowerUp(PowerUpType type) {
    setState(() {
      _activePowerUp = null;
      switch (type) {
        case PowerUpType.shield: _hasShield = false; break;
        case PowerUpType.speedBoost:
          _currentSpeed = _currentSpeed.clamp(DinoRunConfig.baseSpeed, DinoRunConfig.maxSpeed);
          break;
        case PowerUpType.magnet: break;
        case PowerUpType.doubleScore: _scoreMultiplier = 1; break;
        case PowerUpType.invincibility: _isInvincible = false; break;
      }
    });
    _showFeedback('${_getPowerUpEmoji(type)} ${_getPowerUpName(type)} expired', Colors.white38);
  }

  String _getPowerUpEmoji(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield: return '🛡️';
      case PowerUpType.speedBoost: return '⚡';
      case PowerUpType.magnet: return '🧲';
      case PowerUpType.doubleScore: return '2️⃣';
      case PowerUpType.invincibility: return '✨';
    }
  }

  String _getPowerUpName(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield: return 'Shield';
      case PowerUpType.speedBoost: return 'Speed';
      case PowerUpType.magnet: return 'Magnet';
      case PowerUpType.doubleScore: return '2x Score';
      case PowerUpType.invincibility: return 'Invincible';
    }
  }

  // =========================================================================
  // PLAYER ACTIONS
  // =========================================================================

  void _jump() {
    if (_gameState != GameState.playing) {
      if (_gameState == GameState.idle) _startCountdown();
      return;
    }

    if (_isOnGround) {
      setState(() {
        _velocity = DinoRunConfig.jumpForce;
        _isOnGround = false;
        _canDoubleJump = true;
      });
      _addJumpParticles();
      HapticFeedback.lightImpact();
    } else if (_canDoubleJump) {
      setState(() {
        _velocity = DinoRunConfig.doubleJumpForce;
        _canDoubleJump = false;
      });
      _addDoubleJumpParticles();
      HapticFeedback.mediumImpact();
    }
  }

  void _slide() {
    if (_gameState != GameState.playing) return;
    setState(() => _isSliding = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isSliding = false);
    });
  }

  void _pause() {
    if (_gameState == GameState.playing) {
      setState(() => _gameState = GameState.paused);
      _gameLoopTimer?.cancel();
      _spawnTimer?.cancel();
      _overlayFadeController.forward(from: 0);
    } else if (_gameState == GameState.paused) {
      setState(() => _gameState = GameState.playing);
      _startGameLoop();
      _startSpawnTimer();
    }
  }

  // =========================================================================
  // GAME OVER
  // =========================================================================

  void _gameOver() {
    if (_gameState != GameState.playing) return;

    setState(() => _gameState = GameState.gameOver);
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    _survivalTimer?.cancel();
    _dinoRunController.stop();
    _addCollisionParticles();
    _statistics.updateStats(_score, _coinsCollected, _obstaclesAvoided, _survivalTime);
    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _overlayFadeController.forward(from: 0);
        _showResult();
      }
    });
  }

  void _showResult() {
    final won = _score >= DinoRunConfig.winScoreTarget;
    final totalCoins = DinoRunConfig.winCoins + (_coinsCollected ~/ 10);
    final totalXp = (won ? DinoRunConfig.winXp : DinoRunConfig.lossXp) + (_level * 5);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameResultScreen(
          won: won,
          coins: totalCoins.clamp(0, 200),
          xp: totalXp.clamp(0, 150),
          score: _score,
          gameName: 'Dino Run',
          onContinue: () => Navigator.pop(context),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // =========================================================================
  // PARTICLE EFFECTS
  // =========================================================================

  void _addJumpParticles() {
    for (int i = 0; i < 10; i++) {
      _particles.add(Particle(
        x: 0.12, y: DinoRunConfig.groundY,
        vx: (_random.nextDouble() - 0.5) * 0.02,
        vy: -_random.nextDouble() * 0.03,
        size: 2 + _random.nextDouble() * 3,
        color: GameColors.neonGreen,
        lifetime: 0.3,
      ));
    }
  }

  void _addDoubleJumpParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(
        x: 0.12, y: DinoRunConfig.groundY - 0.1,
        vx: (_random.nextDouble() - 0.5) * 0.03,
        vy: -_random.nextDouble() * 0.04,
        size: 2 + _random.nextDouble() * 4,
        color: GameColors.neonGold,
        lifetime: 0.4,
      ));
    }
  }

  void _addCoinParticles(double x, double y) {
    for (int i = 0; i < 12; i++) {
      _particles.add(Particle(
        x: x, y: y,
        vx: (_random.nextDouble() - 0.5) * 0.02,
        vy: (_random.nextDouble() - 0.5) * 0.02,
        size: 2 + _random.nextDouble() * 3,
        color: GameColors.neonGold,
        lifetime: 0.5,
      ));
    }
    _confettiController.play();
  }

  void _addPowerUpParticles(PowerUp powerUp) {
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: powerUp.x,
        y: powerUp.y / MediaQuery.of(context).size.height,
        vx: (_random.nextDouble() - 0.5) * 0.03,
        vy: (_random.nextDouble() - 0.5) * 0.03,
        size: 3 + _random.nextDouble() * 5,
        color: powerUp.color,
        lifetime: 0.6,
      ));
    }
  }

  void _addShieldBreakParticles() {
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        x: 0.12, y: DinoRunConfig.groundY,
        vx: (_random.nextDouble() - 0.5) * 0.04,
        vy: (_random.nextDouble() - 0.5) * 0.04,
        size: 2 + _random.nextDouble() * 4,
        color: GameColors.neonBlue,
        lifetime: 0.5,
      ));
    }
  }

  void _addCollisionParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        x: 0.12, y: DinoRunConfig.groundY,
        vx: (_random.nextDouble() - 0.5) * 0.05,
        vy: (_random.nextDouble() - 0.5) * 0.05 - 0.02,
        size: 3 + _random.nextDouble() * 6,
        color: GameColors.neonRed,
        lifetime: 0.6,
      ));
    }
    _shakeController.forward(from: 0);
  }

  void _showFeedback(String message, Color color) {
    setState(() { _feedbackMessage = message; _feedbackColor = color; });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _feedbackMessage == message) setState(() => _feedbackMessage = null);
    });
  }

  // =========================================================================
  // BUILD METHODS
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: GameColors.bgDeep,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _jump();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _slide();
            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
              _pause();
            }
          }
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            // ── Animated BG grid ──────────────────────────────────────────
            AnimatedBuilder(
              animation: _bgGridController,
              builder: (_, __) => CustomPaint(
                painter: _BgGridPainter(_bgGridController.value),
                child: const SizedBox.expand(),
              ),
            ),

            // ── Game Canvas ───────────────────────────────────────────────
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _jump,
              onLongPress: _slide,
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                    _shakeController.isAnimating
                        ? sin(_shakeController.value * pi * 8) * 6
                        : 0,
                    0,
                  ),
                  child: child,
                ),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: AdvancedDinoPainter(
                      dinoY: _dinoY,
                      dinoRunFrame: _dinoRunFrame,
                      isSliding: _isSliding,
                      obstacles: _obstacles,
                      powerUps: _powerUps,
                      coins: _coins,
                      particles: _particles,
                      clouds: _clouds,
                      groundOffset: _groundOffset,
                      currentSpeed: _currentSpeed,
                      currentWeather: _currentWeather,
                      activePowerUp: _activePowerUp,
                      shakeOffset: 0,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // ── HUD ───────────────────────────────────────────────────────
            if (_gameState == GameState.playing || _gameState == GameState.paused)
              _buildHUD(),

            // ── Pause button ──────────────────────────────────────────────
            if (_gameState == GameState.playing)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 16,
                child: GestureDetector(
                  onTap: _pause,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: GameColors.neonBlue.withOpacity(0.6), width: 1.5),
                      color: GameColors.bgDeep.withOpacity(0.7),
                      boxShadow: [BoxShadow(color: GameColors.neonBlue.withOpacity(0.3), blurRadius: 12)],
                    ),
                    child: const Icon(Icons.pause_rounded, color: GameColors.neonBlue, size: 20),
                  ),
                ),
              ),

            // ── Overlays ──────────────────────────────────────────────────
            if (_gameState != GameState.playing)
              FadeTransition(opacity: _overlayFade, child: _buildOverlay()),

            // ── Feedback toast ────────────────────────────────────────────
            if (_feedbackMessage != null) _buildFeedbackMessage(),

            // ── Confetti ──────────────────────────────────────────────────
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [GameColors.neonGold, GameColors.neonGreen, GameColors.neonBlue],
                numberOfParticles: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HUD ─────────────────────────────────────────────────────────────────

  Widget _buildHUD() {
    final speedPct = ((_currentSpeed - DinoRunConfig.baseSpeed) /
            (DinoRunConfig.maxSpeed - DinoRunConfig.baseSpeed))
        .clamp(0.0, 1.0);

    return SafeArea(
      child: AnimatedBuilder(
        animation: _hudEntrance,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -30 * (1 - _hudEntrance.value)),
          child: Opacity(opacity: _hudEntrance.value, child: child),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 60, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top stats row
              Row(
                children: [
                  // Animated score
                  ScaleTransition(
                    scale: _scorePop,
                    child: HUDStatPill(label: 'SCORE', value: '$_displayedScore', color: GameColors.neonGold),
                  ),
                  const SizedBox(width: 8),
                  HUDStatPill(label: 'LVL', value: '$_level', color: GameColors.neonCyan),
                  const SizedBox(width: 8),
                  HUDStatPill(label: 'COINS', value: '$_coinsCollected', color: GameColors.neonGold, prefix: '💰 '),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),

              // Speed bar
              Row(
                children: [
                  Text('SPD', style: GoogleFonts.rajdhani(fontSize: 9, color: GameColors.textDim, letterSpacing: 1.5)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: GameColors.bgSurface,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: speedPct,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(colors: [
                              GameColors.neonGreen,
                              speedPct > 0.7 ? GameColors.neonRed : GameColors.neonBlue,
                            ]),
                            boxShadow: [BoxShadow(
                              color: (speedPct > 0.7 ? GameColors.neonRed : GameColors.neonGreen).withOpacity(0.6),
                              blurRadius: 6,
                            )],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentSpeed.toStringAsFixed(1)}',
                    style: GoogleFonts.orbitron(fontSize: 9, color: GameColors.neonGreen),
                  ),
                ],
              ),

              // Combo badge
              if (_combo >= 10)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: AnimatedBuilder(
                    animation: _comboController,
                    builder: (_, child) => Transform.scale(
                      scale: 1.0 + _comboController.value * 0.2,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GameColors.neonPink.withOpacity(0.7)),
                        gradient: LinearGradient(
                          colors: [GameColors.neonPink.withOpacity(0.25), GameColors.neonPurple.withOpacity(0.1)],
                        ),
                        boxShadow: [BoxShadow(color: GameColors.neonPink.withOpacity(0.4), blurRadius: 10)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'COMBO ×${_combo ~/ 10}',
                            style: GoogleFonts.orbitron(fontSize: 11, color: GameColors.neonPink, fontWeight: FontWeight.w800,
                              shadows: [Shadow(color: GameColors.neonPink, blurRadius: 6)]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Active power-up indicator
              if (_activePowerUp != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildPowerUpHUD(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerUpHUD() {
    final color = _getPowerUpColor(_activePowerUp!);
    final pct = _powerUpRemaining / DinoRunConfig.powerUpDuration;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
        gradient: LinearGradient(colors: [color.withOpacity(0.18), color.withOpacity(0.04)]),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getPowerUpEmoji(_activePowerUp!), style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getPowerUpName(_activePowerUp!),
                  style: GoogleFonts.rajdhani(fontSize: 10, color: color, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 2),
              SizedBox(
                width: 60,
                height: 3,
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Text('${_powerUpRemaining}s',
              style: GoogleFonts.orbitron(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ── Overlays ──────────────────────────────────────────────────────────────

  Widget _buildOverlay() {
    switch (_gameState) {
      case GameState.idle: return _buildStartScreen();
      case GameState.countdown: return _buildCountdownScreen();
      case GameState.paused: return _buildPauseMenu();
      case GameState.gameOver: return _buildGameOverScreen();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildStartScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameColors.bgDeep, GameColors.bgMid.withOpacity(0.85)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dino hero with pulse + glow
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                final scale = 0.85 + _pulseController.value * 0.25;
                final glow = _pulseController.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer halo
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: GameColors.neonGreen.withOpacity(0.15 + glow * 0.2),
                            blurRadius: 50 + glow * 30,
                            spreadRadius: 10 + glow * 10,
                          ),
                        ],
                      ),
                    ),
                    // Inner ring
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GameColors.neonGreen.withOpacity(0.2 + glow * 0.4),
                          width: 2,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: scale,
                      child: Text(_dinoEmojis[0], style: const TextStyle(fontSize: 72)),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // Title
            NeonText('DINO RUN', fontSize: 36, color: GameColors.neonGreen, glowRadius: 16),
            const SizedBox(height: 6),
            Text(
              'ENDLESS RUNNER',
              style: GoogleFonts.rajdhani(
                fontSize: 13, color: GameColors.textSecondary, letterSpacing: 5,
              ),
            ),

            const SizedBox(height: 40),

            // Controls hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameColors.glassBorder),
                color: GameColors.glassWhite,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _controlHint('TAP', 'Jump'),
                  Container(width: 1, height: 28, color: GameColors.glassBorder, margin: const EdgeInsets.symmetric(horizontal: 16)),
                  _controlHint('HOLD', 'Slide'),
                  Container(width: 1, height: 28, color: GameColors.glassBorder, margin: const EdgeInsets.symmetric(horizontal: 16)),
                  _controlHint('ESC', 'Pause'),
                ],
              ),
            ),

            const SizedBox(height: 36),

            NeonButton(
              label: 'START RUNNING',
              onTap: _startCountdown,
              color: GameColors.neonGreen,
              width: 240,
              height: 56,
              icon: Icons.play_arrow_rounded,
            ),

            const SizedBox(height: 16),

            // Hi score
            if (_statistics.highestScore > 0)
              Text(
                'BEST  ${_statistics.highestScore}',
                style: GoogleFonts.orbitron(fontSize: 12, color: GameColors.neonGold,
                    shadows: [Shadow(color: GameColors.neonGold, blurRadius: 8)]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _controlHint(String key, String action) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: GameColors.neonBlue.withOpacity(0.5)),
            color: GameColors.neonBlue.withOpacity(0.1),
          ),
          child: Text(key, style: GoogleFonts.orbitron(fontSize: 9, color: GameColors.neonBlue, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 4),
        Text(action, style: GoogleFonts.rajdhani(fontSize: 11, color: GameColors.textSecondary, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildCountdownScreen() {
    return Container(
      color: GameColors.bgDeep.withOpacity(0.6),
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_countdownValue),
          tween: Tween<double>(begin: 0.4, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (_, v, __) => Transform.scale(
            scale: v,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [GameColors.neonGold.withOpacity(0.3), Colors.transparent],
                ),
                border: Border.all(color: GameColors.neonGold, width: 2),
                boxShadow: [BoxShadow(color: GameColors.neonGold.withOpacity(0.5), blurRadius: 40, spreadRadius: 4)],
              ),
              child: Center(
                child: NeonText('$_countdownValue', fontSize: 52, color: GameColors.neonGold, glowRadius: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPauseMenu() {
    return Container(
      color: GameColors.bgDeep.withOpacity(0.8),
      child: Center(
        child: GlassCard(
          borderColor: GameColors.neonBlue,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_outline_rounded, color: GameColors.neonBlue, size: 44),
              const SizedBox(height: 12),
              NeonText('PAUSED', fontSize: 26, color: GameColors.neonBlue),
              const SizedBox(height: 6),
              Text(
                'Score: $_score  •  Level: $_level',
                style: GoogleFonts.rajdhani(fontSize: 13, color: GameColors.textSecondary),
              ),
              const SizedBox(height: 28),
              NeonButton(label: 'RESUME', onTap: _pause, color: GameColors.neonGreen, icon: Icons.play_arrow_rounded),
              const SizedBox(height: 12),
              NeonButton(label: 'RESTART', onTap: _restartGame, color: GameColors.neonGold, icon: Icons.refresh_rounded),
              const SizedBox(height: 12),
              NeonButton(label: 'EXIT', onTap: () => Navigator.pop(context), color: GameColors.neonRed, icon: Icons.exit_to_app_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Container(
      color: GameColors.bgDeep.withOpacity(0.85),
      child: Center(
        child: GlassCard(
          borderColor: GameColors.neonRed,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skull with glow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: GameColors.neonRed.withOpacity(0.4), blurRadius: 30)],
                ),
                child: const Center(child: Text('💀', style: TextStyle(fontSize: 48))),
              ),
              const SizedBox(height: 12),
              NeonText('GAME OVER', fontSize: 24, color: GameColors.neonRed, glowRadius: 12),
              const SizedBox(height: 20),

              // Stats grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statBox('SCORE', '$_score', GameColors.neonGold),
                  _statBox('LEVEL', '$_level', GameColors.neonCyan),
                  _statBox('COINS', '$_coinsCollected', GameColors.neonGold),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statBox('DIST', '${(_distanceTraveled).toInt()}m', GameColors.neonGreen),
                  const SizedBox(width: 16),
                  _statBox('TIME', '${_survivalTime}s', GameColors.neonPurple),
                ],
              ),

              const SizedBox(height: 24),

              NeonButton(label: 'PLAY AGAIN', onTap: _restartGame, color: GameColors.neonGreen, icon: Icons.replay_rounded),
              const SizedBox(height: 12),
              NeonButton(label: 'EXIT', onTap: () => Navigator.pop(context), color: GameColors.neonRed, icon: Icons.exit_to_app_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
        color: color.withOpacity(0.07),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.rajdhani(fontSize: 10, color: color.withOpacity(0.7), letterSpacing: 1.5)),
          Text(value, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w800, color: color,
              shadows: [Shadow(color: color, blurRadius: 6)])),
        ],
      ),
    );
  }

  Widget _buildFeedbackMessage() {
    return Positioned(
      top: 130,
      left: 0,
      right: 0,
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
                  border: Border.all(color: (_feedbackColor ?? Colors.white).withOpacity(0.6), width: 1),
                  gradient: LinearGradient(colors: [
                    (_feedbackColor ?? Colors.white).withOpacity(0.2),
                    (_feedbackColor ?? Colors.white).withOpacity(0.05),
                  ]),
                  boxShadow: [BoxShadow(color: (_feedbackColor ?? Colors.white).withOpacity(0.3), blurRadius: 16)],
                ),
                child: Text(
                  _feedbackMessage ?? '',
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    color: _feedbackColor ?? Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    shadows: [Shadow(color: _feedbackColor ?? Colors.white, blurRadius: 8)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield: return GameColors.neonBlue;
      case PowerUpType.speedBoost: return GameColors.neonGold;
      case PowerUpType.magnet: return GameColors.neonPurple;
      case PowerUpType.doubleScore: return GameColors.neonPink;
      case PowerUpType.invincibility: return GameColors.neonCyan;
    }
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    _survivalTimer?.cancel();
    _powerUpTimer?.cancel();
    _weatherTimer?.cancel();
    _scoreAnimTimer?.cancel();
    _dinoRunController.dispose();
    _groundController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _comboController.dispose();
    _hudEntranceController.dispose();
    _scorePopController.dispose();
    _overlayFadeController.dispose();
    _bgGridController.dispose();
    _confettiController.dispose();
    _victoryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// =============================================================================
// BACKGROUND GRID PAINTER (cyberpunk grid effect)
// =============================================================================

class _BgGridPainter extends CustomPainter {
  final double t;
  _BgGridPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Vertical lines
    final paint = Paint()..color = GameColors.neonGreen.withOpacity(0.04)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines with parallax offset
    final hOffset = (t * size.height) % 40;
    for (double y = -40 + hOffset; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Ambient corner glows
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [GameColors.neonPurple.withOpacity(0.08), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(0, size.height), radius: 200));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glow);
  }

  @override
  bool shouldRepaint(_BgGridPainter old) => old.t != t;
}

// =============================================================================
// ADVANCED DINO PAINTER  (game world renderer)
// =============================================================================

class AdvancedDinoPainter extends CustomPainter {
  final double dinoY;
  final int dinoRunFrame;
  final bool isSliding;
  final List<Obstacle> obstacles;
  final List<PowerUp> powerUps;
  final List<CollectibleCoin> coins;
  final List<Particle> particles;
  final List<Cloud> clouds;
  final double groundOffset;
  final double currentSpeed;
  final WeatherEffect currentWeather;
  final PowerUpType? activePowerUp;
  final double shakeOffset;

  AdvancedDinoPainter({
    required this.dinoY,
    required this.dinoRunFrame,
    required this.isSliding,
    required this.obstacles,
    required this.powerUps,
    required this.coins,
    required this.particles,
    required this.clouds,
    required this.groundOffset,
    required this.currentSpeed,
    required this.currentWeather,
    required this.activePowerUp,
    required this.shakeOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double groundY = size.height * DinoRunConfig.groundY;

    // ── Sky ──────────────────────────────────────────────────────────────
    _drawSky(canvas, size);

    // ── Clouds ───────────────────────────────────────────────────────────
    for (final cloud in clouds) {
      final p = Paint()..color = Colors.white.withOpacity(0.06)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset(cloud.x * size.width, cloud.y * size.height), cloud.size, p);
      final p2 = Paint()..color = Colors.white.withOpacity(0.04);
      canvas.drawCircle(Offset(cloud.x * size.width + cloud.size * 0.6, cloud.y * size.height - 8), cloud.size * 0.7, p2);
    }

    // ── Ground fill ───────────────────────────────────────────────────────
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF0A1A0A), const Color(0xFF050F05)],
      ).createShader(Rect.fromLTWH(0, groundY, size.width, size.height - groundY));
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.width, size.height - groundY), groundPaint);

    // ── Ground neon scanline ──────────────────────────────────────────────
    final glowLine = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, GameColors.neonGreen.withOpacity(0.7), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, groundY - 2, size.width, 4))
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, groundY - 1), Offset(size.width, groundY - 1), glowLine);

    // Secondary glow
    canvas.drawLine(
      Offset(0, groundY - 1),
      Offset(size.width, groundY - 1),
      Paint()..color = GameColors.neonGreen.withOpacity(0.3)..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // ── Animated dash marks ───────────────────────────────────────────────
    final dashPaint = Paint()..color = GameColors.neonGreen.withOpacity(0.25)..strokeWidth = 2;
    final dashOffset = groundOffset * 2 % 60;
    for (double x = -60 + dashOffset; x < size.width + 60; x += 60) {
      canvas.drawLine(Offset(x, groundY + 8), Offset(x + 30, groundY + 8), dashPaint);
    }

    // ── Dino shadow ───────────────────────────────────────────────────────
    final shadowOpacity = (1 + dinoY / 200).clamp(0.0, 0.4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.12 + DinoRunConfig.dinoSize / 2, groundY + 8), width: 36, height: 8),
      Paint()..color = Colors.black.withOpacity(shadowOpacity),
    );

    // ── Obstacles ────────────────────────────────────────────────────────
    for (final obstacle in obstacles) {
      final x = obstacle.x * size.width;
      final y = obstacle.y;

      // Glow
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y - obstacle.height, obstacle.width, obstacle.height), const Radius.circular(8)),
        Paint()..color = obstacle.color.withOpacity(0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      // Body
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y - obstacle.height, obstacle.width, obstacle.height), const Radius.circular(8)),
        Paint()..color = obstacle.color.withOpacity(0.85),
      );
      // Border
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y - obstacle.height, obstacle.width, obstacle.height), const Radius.circular(8)),
        Paint()..color = obstacle.color..style = PaintingStyle.stroke..strokeWidth = 1.5,
      );

      _drawText(canvas, obstacle.emoji, 24, Offset(x + obstacle.width / 2 - 12, y - obstacle.height + 4));
    }

    // ── Power-ups ────────────────────────────────────────────────────────
    for (final powerUp in powerUps) {
      final x = powerUp.x * size.width;
      final y = powerUp.y;
      final bounce = sin(DateTime.now().millisecondsSinceEpoch / 300) * 5;

      canvas.drawCircle(
        Offset(x + 16, y + bounce),
        22,
        Paint()..color = powerUp.color.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.drawCircle(
        Offset(x + 16, y + bounce),
        18,
        Paint()..color = powerUp.color.withOpacity(0.15)
          ..style = PaintingStyle.stroke..strokeWidth = 2,
      );
      _drawText(canvas, powerUp.emoji, 26, Offset(x, y + bounce - 14));
    }

    // ── Coins ────────────────────────────────────────────────────────────
    for (final coin in coins) {
      final x = coin.x * size.width;
      final y = coin.y;
      final bounce = sin(coin.animationOffset * 10) * 5;

      // Glow
      canvas.drawCircle(
        Offset(x + 10, y + bounce),
        16,
        Paint()..color = GameColors.neonGold.withOpacity(0.35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      // Body
      canvas.drawCircle(
        Offset(x + 10, y + bounce),
        11,
        Paint()..shader = RadialGradient(
          colors: [const Color(0xFFFFEF80), GameColors.neonGold, const Color(0xFFCC8800)],
        ).createShader(Rect.fromCircle(center: Offset(x + 10, y + bounce), radius: 11)),
      );
      // Rim
      canvas.drawCircle(
        Offset(x + 10, y + bounce),
        11,
        Paint()..color = GameColors.neonGold..style = PaintingStyle.stroke..strokeWidth = 1,
      );
      // $ symbol
      _drawText(canvas, '💰', 14, Offset(x + 3, y + bounce - 9));
    }

    // ── Particles ────────────────────────────────────────────────────────
    for (final particle in particles) {
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        Paint()
          ..color = particle.color.withOpacity(particle.opacity.clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // ── Dino ─────────────────────────────────────────────────────────────
    final dinoX = size.width * 0.12;
    final dinoYPos = groundY + (dinoY * size.height * 0.5) - DinoRunConfig.dinoSize;
    final dinoHeight = isSliding ? DinoRunConfig.dinoSize / 2 : DinoRunConfig.dinoSize;

    // Invincibility aura
    if (activePowerUp == PowerUpType.invincibility) {
      final pulse = (DateTime.now().millisecondsSinceEpoch % 600) / 600;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(dinoX - 6, dinoYPos - 6, DinoRunConfig.dinoSize + 12, dinoHeight + 12),
          const Radius.circular(14),
        ),
        Paint()
          ..color = GameColors.neonCyan.withOpacity(0.2 + pulse * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // Shield aura
    if (activePowerUp == PowerUpType.shield) {
      final pulse = (DateTime.now().millisecondsSinceEpoch % 500) / 500;
      canvas.drawCircle(
        Offset(dinoX + DinoRunConfig.dinoSize / 2, dinoYPos + dinoHeight / 2),
        36,
        Paint()
          ..color = GameColors.neonBlue.withOpacity(0.15 + pulse * 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawCircle(
        Offset(dinoX + DinoRunConfig.dinoSize / 2, dinoYPos + dinoHeight / 2),
        36,
        Paint()
          ..color = GameColors.neonBlue.withOpacity(0.3 + pulse * 0.2)
          ..style = PaintingStyle.stroke..strokeWidth = 1.5,
      );
    }

    // Dino body glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(dinoX, dinoYPos, DinoRunConfig.dinoSize, dinoHeight), const Radius.circular(12)),
      Paint()..color = GameColors.neonGreen.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Dino emoji
    final dinoEmoji = isSliding ? '🦕' : (dinoRunFrame == 0 ? '🦕' : '🦖');
    _drawText(canvas, dinoEmoji, isSliding ? 28 : 34, Offset(dinoX + 4, dinoYPos + (isSliding ? 8 : 0)));
  }

  void _drawText(Canvas canvas, String text, double fontSize, Offset offset) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawSky(Canvas canvas, Size size) {
    Color startColor, endColor;
    switch (currentWeather) {
      case WeatherEffect.clear:
        startColor = const Color(0xFF03010A);
        endColor = const Color(0xFF0D0520);
        break;
      case WeatherEffect.rain:
        startColor = const Color(0xFF080818);
        endColor = const Color(0xFF102030);
        break;
      case WeatherEffect.sandstorm:
        startColor = const Color(0xFF1A1005);
        endColor = const Color(0xFF2A2010);
        break;
      case WeatherEffect.night:
        startColor = const Color(0xFF000005);
        endColor = const Color(0xFF050010);
        break;
      case WeatherEffect.sunset:
        startColor = const Color(0xFF150508);
        endColor = const Color(0xFF251018);
        break;
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [startColor, endColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Weather overlays
    if (currentWeather == WeatherEffect.rain) {
      final rp = Paint()..color = GameColors.neonBlue.withOpacity(0.15)..strokeWidth = 1;
      final t = DateTime.now().millisecondsSinceEpoch;
      for (int i = 0; i < 60; i++) {
        final x = (i * 131 + (t ~/ 10) * 2) % size.width.toInt();
        final y = (t / 40 + i * 50) % size.height;
        canvas.drawLine(Offset(x.toDouble(), y), Offset(x - 3.0, y + 12), rp);
      }
    } else if (currentWeather == WeatherEffect.night) {
      final sp = Paint()..color = Colors.white.withOpacity(0.45);
      for (int i = 0; i < 60; i++) {
        final x = (i * 253) % size.width;
        final y = (i * 131) % (size.height * 0.55);
        final r = 0.8 + (i % 3) * 0.5;
        canvas.drawCircle(Offset(x, y), r, sp);
      }
    }
  }

  @override
  bool shouldRepaint(AdvancedDinoPainter old) => true;
}

// =============================================================================
// GAME RESULT SCREEN  (placeholder — remove when integrating)
// =============================================================================

class GameResultScreen extends StatefulWidget {
  final bool won;
  final int coins;
  final int xp;
  final int score;
  final String gameName;
  final VoidCallback onContinue;

  const GameResultScreen({
    super.key,
    required this.won,
    required this.coins,
    required this.xp,
    required this.score,
    required this.gameName,
    required this.onContinue,
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
    final color = widget.won ? GameColors.neonGold : GameColors.neonRed;
    return Scaffold(
      backgroundColor: GameColors.bgDeep,
      body: Stack(
        children: [
          // BG grid
          CustomPaint(painter: _BgGridPainter(0), child: const SizedBox.expand()),

          Center(
            child: ScaleTransition(
              scale: _enter,
              child: FadeTransition(
                opacity: _enter,
                child: GlassCard(
                  borderColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                  borderRadius: 32,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.won ? '🏆' : '💀', style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      NeonText(widget.won ? 'VICTORY!' : 'GAME OVER', fontSize: 28, color: color, glowRadius: 16),
                      const SizedBox(height: 6),
                      Text(widget.gameName,
                          style: GoogleFonts.rajdhani(fontSize: 13, color: GameColors.textSecondary, letterSpacing: 3)),
                      const SizedBox(height: 24),

                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withOpacity(0.4)),
                          color: color.withOpacity(0.07),
                        ),
                        child: NeonText('${widget.score}', fontSize: 44, color: color, glowRadius: 14),
                      ),
                      Text('SCORE', style: GoogleFonts.rajdhani(fontSize: 11, color: GameColors.textDim, letterSpacing: 3)),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _rewardPill('💰', '+${widget.coins}', GameColors.neonGold),
                          const SizedBox(width: 12),
                          _rewardPill('⭐', '+${widget.xp} XP', GameColors.neonCyan),
                        ],
                      ),
                      const SizedBox(height: 28),
                      NeonButton(
                        label: 'CONTINUE',
                        onTap: widget.onContinue,
                        color: GameColors.neonGreen,
                        width: 200,
                        icon: Icons.chevron_right_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (widget.won)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [GameColors.neonGold, GameColors.neonGreen, GameColors.neonCyan, GameColors.neonPink],
                numberOfParticles: 30,
              ),
            ),
        ],
      ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.orbitron(fontSize: 13, color: color, fontWeight: FontWeight.w700,
              shadows: [Shadow(color: color, blurRadius: 6)])),
        ],
      ),
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
    builder: (_) => const AdvancedDinoRunGame(),
  ),
);

// With custom skin:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedDinoRunGame(initialSkin: DinoSkin.neon),
  ),
);
*/