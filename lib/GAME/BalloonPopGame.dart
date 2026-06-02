
// =============================================================================
// FILE: balloon_pop_game_advanced.dart
// =============================================================================
// ADVANCED BALLOON POP GAME - Premium Arcade Balloon Popping Experience
// Features: Multiple balloon types, Power-ups, Combo system, Animations
// Compatible with existing BEEDI College ecosystem
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// CONSTANTS & CONFIGURATION
// =============================================================================

class BalloonPopConfig {
  // Game Settings
  static const int baseTimeSeconds = 45;
  static const int maxBalloonsOnScreen = 15;
  static const int baseSpawnIntervalMs = 800;
  static const int minSpawnIntervalMs = 400;
  
  // Scoring
  static const int normalBalloonPoints = 10;
  static const int goldenBalloonPoints = 50;
  static const int rainbowBalloonPoints = 30;
  static const int speedBalloonPoints = 20;
  static const int giantBalloonPoints = 25;
  static const int bombBalloonPenalty = 20;
  
  // Combo System
  static const int comboTimeWindowMs = 1500;
  static const int maxComboMultiplier = 5;
  static const double comboMultiplierStep = 0.25;
  
  // Level Progression
  static const int balloonsPerLevel = 15;
  static const double speedIncreasePerLevel = 0.08;
  static const int targetScoreForWin = 300;
  
  // Victory Conditions
  static const int winCoins = 40;
  static const int winXp = 60;
  static const int lossXp = 10;
  
  // Power-ups
  static const double powerUpChance = 0.12;
  static const int powerUpDuration = 8;
  
  // Visual
  static const double balloonBaseSize = 48;
  static const double giantBalloonSize = 70;
}

// =============================================================================
// ENUMS
// =============================================================================

enum GameState { idle, countdown, playing, paused, gameOver }
enum BalloonType { normal, golden, bomb, rainbow, speed, giant }
enum PowerUpType { doubleScore, freezeTime, slowMotion, autoPop, comboBoost, shield }

// =============================================================================
// DATA MODELS
// =============================================================================

class Balloon {
  final String id;
  final BalloonType type;
  double x;
  double y;
  double speed;
  double rotation;
  double wobbleOffset;
  bool isActive;
  DateTime? poppedAt;
  
  Balloon({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.speed,
    this.rotation = 0,
    this.wobbleOffset = 0,
    this.isActive = true,
  });
  
  int get points {
    switch (type) {
      case BalloonType.normal:
        return BalloonPopConfig.normalBalloonPoints;
      case BalloonType.golden:
        return BalloonPopConfig.goldenBalloonPoints;
      case BalloonType.rainbow:
        return BalloonPopConfig.rainbowBalloonPoints;
      case BalloonType.speed:
        return BalloonPopConfig.speedBalloonPoints;
      case BalloonType.giant:
        return BalloonPopConfig.giantBalloonPoints;
      case BalloonType.bomb:
        return -BalloonPopConfig.bombBalloonPenalty;
    }
  }
  
  String get emoji {
    switch (type) {
      case BalloonType.normal:
        return '🎈';
      case BalloonType.golden:
        return '🎈';
      case BalloonType.rainbow:
        return '🎈';
      case BalloonType.speed:
        return '🎈';
      case BalloonType.giant:
        return '🎈';
      case BalloonType.bomb:
        return '💣';
    }
  }
  
  Color get color {
    switch (type) {
      case BalloonType.normal:
        return const Color(0xFFFF6B6B);
      case BalloonType.golden:
        return const Color(0xFFFFD700);
      case BalloonType.rainbow:
        return const Color(0xFFFF4081);
      case BalloonType.speed:
        return const Color(0xFF00D4FF);
      case BalloonType.giant:
        return const Color(0xFF9C27B0);
      case BalloonType.bomb:
        return const Color(0xFF2C2C2C);
    }
  }
  
  double get size {
    return type == BalloonType.giant 
        ? BalloonPopConfig.giantBalloonSize 
        : BalloonPopConfig.balloonBaseSize;
  }
  
  String get name {
    switch (type) {
      case BalloonType.normal: return 'Normal';
      case BalloonType.golden: return 'Golden';
      case BalloonType.rainbow: return 'Rainbow';
      case BalloonType.speed: return 'Speed';
      case BalloonType.giant: return 'Giant';
      case BalloonType.bomb: return 'Bomb';
    }
  }
}

class PowerUp {
  final PowerUpType type;
  double x;
  double y;
  bool isActive;
  int remainingDuration;
  
  PowerUp({
    required this.type,
    required this.x,
    required this.y,
    this.isActive = true,
    this.remainingDuration = BalloonPopConfig.powerUpDuration,
  });
  
  String get emoji {
    switch (type) {
      case PowerUpType.doubleScore: return '2️⃣';
      case PowerUpType.freezeTime: return '❄️';
      case PowerUpType.slowMotion: return '🐢';
      case PowerUpType.autoPop: return '🤖';
      case PowerUpType.comboBoost: return '⚡';
      case PowerUpType.shield: return '🛡️';
    }
  }
  
  Color get color {
    switch (type) {
      case PowerUpType.doubleScore: return const Color(0xFFFFD700);
      case PowerUpType.freezeTime: return const Color(0xFF00D4FF);
      case PowerUpType.slowMotion: return const Color(0xFF9C27B0);
      case PowerUpType.autoPop: return const Color(0xFF00FF88);
      case PowerUpType.comboBoost: return const Color(0xFFFF4081);
      case PowerUpType.shield: return const Color(0xFF2196F3);
    }
  }
  
  String get name {
    switch (type) {
      case PowerUpType.doubleScore: return '2x Score';
      case PowerUpType.freezeTime: return 'Freeze';
      case PowerUpType.slowMotion: return 'Slow Mo';
      case PowerUpType.autoPop: return 'Auto Pop';
      case PowerUpType.comboBoost: return 'Combo+';
      case PowerUpType.shield: return 'Shield';
    }
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;
  double lifetime;
  double maxLifetime;
  
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.lifetime,
  }) : maxLifetime = lifetime, opacity = 1.0;
  
  bool update() {
    x += vx;
    y += vy;
    vy += 0.2;
    lifetime -= 1 / 60;
    opacity = lifetime / maxLifetime;
    return lifetime > 0;
  }
}

class BalloonStatistics {
  int highestScore = 0;
  int totalBalloonsPopped = 0;
  int highestCombo = 0;
  int bombHits = 0;
  int fastestReactionMs = 0;
  int totalPlayTime = 0;
  int goldenBalloonsPopped = 0;
  int powerUpsCollected = 0;
  
  void updateStats(int score, int balloons, int combo, int reactionMs, int playTime) {
    if (score > highestScore) highestScore = score;
    totalBalloonsPopped += balloons;
    if (combo > highestCombo) highestCombo = combo;
    if (reactionMs > 0 && (fastestReactionMs == 0 || reactionMs < fastestReactionMs)) {
      fastestReactionMs = reactionMs;
    }
    totalPlayTime += playTime;
  }
}

// =============================================================================
// MAIN BALLOON POP GAME WIDGET
// =============================================================================

class AdvancedBalloonPopGame extends StatefulWidget {
  const AdvancedBalloonPopGame({super.key});
  
  @override
  State<AdvancedBalloonPopGame> createState() => _AdvancedBalloonPopGameState();
}

class _AdvancedBalloonPopGameState extends State<AdvancedBalloonPopGame>
    with TickerProviderStateMixin {
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  final List<Balloon> _balloons = [];
  final List<PowerUp> _powerUps = [];
  final List<Particle> _particles = [];
  
  int _score = 0;
  int _combo = 0;
  int _level = 1;
  int _balloonsPopped = 0;
  int _timeLeft = BalloonPopConfig.baseTimeSeconds;
  int _highScore = 0;
  double _currentSpawnInterval = BalloonPopConfig.baseSpawnIntervalMs.toDouble();
  
  GameState _gameState = GameState.idle;
  
  // Power-up effects
  PowerUpType? _activePowerUp;
  int _powerUpRemaining = 0;
  Timer? _powerUpTimer;
  int _scoreMultiplier = 1;
  bool _isTimeFrozen = false;
  bool _hasShield = false;
  Timer? _autoPopTimer;
  
  // Timers
  Timer? _gameTimer;
  Timer? _spawnTimer;
  Timer? _animationTimer;
  Timer? _comboTimer;
  
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _comboController;
  late AnimationController _scoreController;
  late ConfettiController _confettiController;
  late ConfettiController _victoryController;
  
  // Visual effects
  double _backgroundOffset = 0;
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _lastPoppedPoints = 0;
  DateTime? _lastPopTime;
  int _reactionTime = 0;
  
  // Statistics
  final BalloonStatistics _statistics = BalloonStatistics();
  int _playTimeSeconds = 0;
  
  // Random generator
  final Random _random = Random();
  
  // =========================================================================
  // INITIALIZATION
  // =========================================================================
  
  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadHighScore();
    _loadStatistics();
  }
  
  void _initControllers() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _victoryController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  Future<void> _loadHighScore() async {
    // Load from SharedPreferences
    setState(() {});
  }
  
  Future<void> _loadStatistics() async {
    // Load from SharedPreferences or Firebase
    setState(() {});
  }
  
  // =========================================================================
  // GAME START & RESTART
  // =========================================================================
  
  void _startCountdown() {
    setState(() {
      _gameState = GameState.countdown;
    });
    
    int countdown = 3;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() => countdown--);
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
      _score = 0;
      _combo = 0;
      _level = 1;
      _balloonsPopped = 0;
      _timeLeft = BalloonPopConfig.baseTimeSeconds;
      _currentSpawnInterval = BalloonPopConfig.baseSpawnIntervalMs.toDouble();
      _activePowerUp = null;
      _scoreMultiplier = 1;
      _isTimeFrozen = false;
      _hasShield = false;
      _balloons.clear();
      _powerUps.clear();
      _particles.clear();
      _playTimeSeconds = 0;
    });
    
    _startGameTimer();
    _startSpawnTimer();
    _startAnimationTimer();
  }
  
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      if (_gameState == GameState.playing && !_isTimeFrozen) {
        setState(() {
          _timeLeft--;
          _playTimeSeconds++;
          
          if (_timeLeft <= 0) {
            timer.cancel();
            _gameOver();
          }
          
          // Level progression based on time
          final newLevel = 1 + ((BalloonPopConfig.baseTimeSeconds - _timeLeft) ~/ 30);
          if (newLevel > _level) {
            _level = newLevel;
            _updateDifficulty();
            _showFeedback('LEVEL $_level!', const Color(0xFFFFD700));
            HapticFeedback.mediumImpact();
          }
        });
      }
    });
  }
  
  void _startSpawnTimer() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(
      Duration(milliseconds: _currentSpawnInterval.toInt()),
      (_) {
        if (_gameState == GameState.playing && mounted) {
          _spawnBalloon();
          
          // Spawn power-up
          if (_random.nextDouble() < BalloonPopConfig.powerUpChance) {
            _spawnPowerUp();
          }
        }
      },
    );
  }
  
  void _startAnimationTimer() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      
      setState(() {
        // Update balloon positions
        for (int i = 0; i < _balloons.length; i++) {
          final balloon = _balloons[i];
          
          // Move upward
          balloon.y -= balloon.speed;
          
          // Wobble effect
          balloon.wobbleOffset += 0.1;
          balloon.x += sin(balloon.wobbleOffset) * 0.002;
          
          // Rotate
          balloon.rotation += 0.02;
          
          // Remove if off screen
          if (balloon.y < -0.1) {
            _balloons.removeAt(i);
            i--;
            
            // Break combo if balloon escapes
            if (_combo > 0 && !_hasShield) {
              _combo = 0;
              _comboTimer?.cancel();
              _showFeedback('COMBO BROKEN!', const Color(0xFFFF0044));
            }
          }
        }
        
        // Update power-up positions
        for (int i = 0; i < _powerUps.length; i++) {
          final powerUp = _powerUps[i];
          powerUp.y -= 0.003;
          
          if (powerUp.y < -0.1) {
            _powerUps.removeAt(i);
            i--;
          }
        }
        
        // Auto-pop balloons when power-up is active
        if (_activePowerUp == PowerUpType.autoPop) {
          _autoPopBalloons();
        }
        
        // Update background offset for parallax
        _backgroundOffset += 0.01;
        
        // Update particles
        _particles.removeWhere((p) => !p.update());
      });
    });
  }
  
  void _updateDifficulty() {
    // Increase spawn speed with level
    final newInterval = BalloonPopConfig.baseSpawnIntervalMs -
        (_level * BalloonPopConfig.speedIncreasePerLevel * 10);
    _currentSpawnInterval = newInterval.clamp(
      BalloonPopConfig.minSpawnIntervalMs.toDouble(),
      BalloonPopConfig.baseSpawnIntervalMs.toDouble(),
    );
    
    _startSpawnTimer();
  }
  
  void _spawnBalloon() {
    if (_balloons.length >= BalloonPopConfig.maxBalloonsOnScreen) return;
    
    // Determine balloon type based on score and level
    BalloonType type;
    final random = _random.nextDouble();
    
    if (_score > 500 && random < 0.05) {
      type = BalloonType.golden;
    } else if (_score > 300 && random < 0.08) {
      type = BalloonType.rainbow;
    } else if (_level > 3 && random < 0.1) {
      type = BalloonType.speed;
    } else if (_level > 2 && random < 0.15 && _score > 100) {
      type = BalloonType.giant;
    } else if (_level > 1 && random < 0.07) {
      type = BalloonType.bomb;
    } else {
      type = BalloonType.normal;
    }
    
    // Calculate speed based on type and level
    double speed = 0.003 + (_level * 0.0005);
    if (type == BalloonType.speed) speed *= 1.8;
    if (type == BalloonType.giant) speed *= 0.7;
    
    final balloon = Balloon(
      id: DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(10000).toString(),
      type: type,
      x: 0.1 + _random.nextDouble() * 0.8,
      y: 1.0,
      speed: speed,
    );
    
    setState(() {
      _balloons.add(balloon);
    });
  }
  
  void _spawnPowerUp() {
    final types = PowerUpType.values;
    final type = types[_random.nextInt(types.length)];
    
    final powerUp = PowerUp(
      type: type,
      x: 0.1 + _random.nextDouble() * 0.8,
      y: 1.0,
    );
    
    setState(() {
      _powerUps.add(powerUp);
    });
  }
  
  void _autoPopBalloons() {
    // Auto-pop random balloons every 0.5 seconds
    if (_autoPopTimer != null) return;
    
    _autoPopTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_gameState != GameState.playing || _activePowerUp != PowerUpType.autoPop) {
        timer.cancel();
        _autoPopTimer = null;
        return;
      }
      
      final activeBalloons = _balloons.where((b) => b.type != BalloonType.bomb).toList();
      if (activeBalloons.isNotEmpty) {
        final randomBalloon = activeBalloons[_random.nextInt(activeBalloons.length)];
        _popBalloon(randomBalloon, isAutoPop: true);
      }
    });
  }
  
  // =========================================================================
  // BALLOON POPPING LOGIC
  // =========================================================================
  
  void _popBalloon(Balloon balloon, {bool isAutoPop = false}) {
    if (!balloon.isActive) return;
    
    // Calculate reaction time
    final now = DateTime.now();
    if (_lastPopTime != null && !isAutoPop) {
      _reactionTime = now.difference(_lastPopTime!).inMilliseconds;
    }
    _lastPopTime = now;
    
    // Handle bomb balloon
    if (balloon.type == BalloonType.bomb) {
      if (_hasShield) {
        _hasShield = false;
        _showFeedback('🛡️ Shield saved you!', const Color(0xFF2196F3));
        _addShieldBreakParticles(balloon.x, balloon.y);
      } else {
        _combo = 0;
        _score = max(0, _score + balloon.points);
        _statistics.bombHits++;
        _showFeedback('💣 BOMB! -${-balloon.points} points', const Color(0xFFFF0044));
        _shakeController.forward(from: 0);
        HapticFeedback.heavyImpact();
      }
      
      _addExplosionParticles(balloon.x, balloon.y, Colors.red);
      balloon.isActive = false;
      
      setState(() {
        _balloons.remove(balloon);
      });
      return;
    }
    
    // Calculate points with multipliers
    int pointsEarned = balloon.points;
    
    // Apply combo multiplier
    final comboMultiplier = 1 + (_combo * 0.1);
    pointsEarned = (pointsEarned * comboMultiplier).toInt();
    
    // Apply power-up multiplier
    pointsEarned *= _scoreMultiplier;
    
    _lastPoppedPoints = pointsEarned;
    _score += pointsEarned;
    _balloonsPopped++;
    
    // Update combo
    _comboTimer?.cancel();
    _combo++;
    
    if (_combo > 0 && _combo % 5 == 0) {
      _comboController.forward(from: 0);
      _showFeedback('COMBO x${_combo}!', const Color(0xFFFF4081));
      _confettiController.play();
      HapticFeedback.mediumImpact();
    }
    
    // Update statistics
    if (balloon.type == BalloonType.golden) {
      _statistics.goldenBalloonsPopped++;
    }
    
    // Start combo timer
    _comboTimer = Timer(Duration(milliseconds: BalloonPopConfig.comboTimeWindowMs), () {
      if (mounted && _gameState == GameState.playing) {
        setState(() {
          _combo = 0;
        });
      }
    });
    
    // Add visual effects
    _addPopParticles(balloon.x, balloon.y, balloon.color);
    _scoreController.forward(from: 0);
    HapticFeedback.lightImpact();
    
    // Check for win
    if (_score >= BalloonPopConfig.targetScoreForWin) {
      _victoryController.play();
      _gameOver();
      return;
    }
    
    // Remove balloon
    setState(() {
      balloon.isActive = false;
      _balloons.remove(balloon);
    });
  }
  
  void _collectPowerUp(PowerUp powerUp) {
    setState(() {
      _activePowerUp = powerUp.type;
      _powerUpRemaining = powerUp.remainingDuration;
      _statistics.powerUpsCollected++;
    });
    
    _showFeedback('${powerUp.emoji} ${powerUp.name} ACTIVATED!', powerUp.color);
    _addPowerUpParticles(powerUp.x, powerUp.y, powerUp.color);
    HapticFeedback.mediumImpact();
    
    switch (powerUp.type) {
      case PowerUpType.doubleScore:
        _scoreMultiplier = 2;
        break;
      case PowerUpType.freezeTime:
        _isTimeFrozen = true;
        break;
      case PowerUpType.slowMotion:
        // Slow down balloon movement
        for (final balloon in _balloons) {
          balloon.speed *= 0.5;
        }
        break;
      case PowerUpType.autoPop:
        _autoPopBalloons();
        break;
      case PowerUpType.comboBoost:
        _combo += 10;
        _showFeedback('COMBO BOOST! x$_combo', const Color(0xFFFF4081));
        break;
      case PowerUpType.shield:
        _hasShield = true;
        break;
    }
    
    _startPowerUpTimer(powerUp.type);
    
    // Remove power-up
    setState(() {
      _powerUps.remove(powerUp);
    });
  }
  
  void _startPowerUpTimer(PowerUpType type) {
    _powerUpTimer?.cancel();
    _powerUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
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
        case PowerUpType.doubleScore:
          _scoreMultiplier = 1;
          break;
        case PowerUpType.freezeTime:
          _isTimeFrozen = false;
          break;
        case PowerUpType.slowMotion:
          // Restore normal speed
          for (final balloon in _balloons) {
            balloon.speed = 0.003 + (_level * 0.0005);
            if (balloon.type == BalloonType.speed) balloon.speed *= 1.8;
            if (balloon.type == BalloonType.giant) balloon.speed *= 0.7;
          }
          break;
        case PowerUpType.autoPop:
          _autoPopTimer?.cancel();
          _autoPopTimer = null;
          break;
        case PowerUpType.comboBoost:
          break;
        case PowerUpType.shield:
          _hasShield = false;
          break;
      }
    });
    
    _showFeedback('${_getPowerUpEmoji(type)} ${_getPowerUpName(type)} expired', Colors.white54);
  }
  
  String _getPowerUpEmoji(PowerUpType type) {
    switch (type) {
      case PowerUpType.doubleScore: return '2️⃣';
      case PowerUpType.freezeTime: return '❄️';
      case PowerUpType.slowMotion: return '🐢';
      case PowerUpType.autoPop: return '🤖';
      case PowerUpType.comboBoost: return '⚡';
      case PowerUpType.shield: return '🛡️';
    }
  }
  
  String _getPowerUpName(PowerUpType type) {
    switch (type) {
      case PowerUpType.doubleScore: return '2x Score';
      case PowerUpType.freezeTime: return 'Freeze';
      case PowerUpType.slowMotion: return 'Slow Mo';
      case PowerUpType.autoPop: return 'Auto Pop';
      case PowerUpType.comboBoost: return 'Combo+';
      case PowerUpType.shield: return 'Shield';
    }
  }
  
  // =========================================================================
  // PARTICLE EFFECTS
  // =========================================================================
  
  void _addPopParticles(double x, double y, Color color) {
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 0.03,
        vy: (_random.nextDouble() - 0.5) * 0.03 - 0.02,
        size: 2 + _random.nextDouble() * 4,
        color: color,
        lifetime: 0.5,
      ));
    }
  }
  
  void _addExplosionParticles(double x, double y, Color color) {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 0.05,
        vy: (_random.nextDouble() - 0.5) * 0.05,
        size: 3 + _random.nextDouble() * 5,
        color: color,
        lifetime: 0.6,
      ));
    }
  }
  
  void _addPowerUpParticles(double x, double y, Color color) {
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 0.04,
        vy: (_random.nextDouble() - 0.5) * 0.04 - 0.03,
        size: 2 + _random.nextDouble() * 5,
        color: color,
        lifetime: 0.7,
      ));
    }
  }
  
  void _addShieldBreakParticles(double x, double y) {
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 0.04,
        vy: (_random.nextDouble() - 0.5) * 0.04,
        size: 2 + _random.nextDouble() * 4,
        color: const Color(0xFF2196F3),
        lifetime: 0.5,
      ));
    }
  }
  
  void _showFeedback(String message, Color color) {
    setState(() {
      _feedbackMessage = message;
      _feedbackColor = color;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _feedbackMessage == message) {
        setState(() => _feedbackMessage = null);
      }
    });
  }
  
  // =========================================================================
  // GAME OVER
  // =========================================================================
  
  void _gameOver() {
    if (_gameState != GameState.playing) return;
    
    setState(() {
      _gameState = GameState.gameOver;
    });
    
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _animationTimer?.cancel();
    _comboTimer?.cancel();
    _powerUpTimer?.cancel();
    _autoPopTimer?.cancel();
    
    // Update high score
    if (_score > _highScore) {
      _highScore = _score;
      _saveHighScore();
    }
    
    // Update statistics
    _statistics.updateStats(
      _score,
      _balloonsPopped,
      _combo,
      _reactionTime,
      _playTimeSeconds,
    );
    
    // Show result
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showResult();
      }
    });
  }
  
  Future<void> _saveHighScore() async {
    // Save to SharedPreferences
  }
  
  void _showResult() {
    final won = _score >= BalloonPopConfig.targetScoreForWin;
    final totalCoins = (won ? BalloonPopConfig.winCoins : 0) + (_score ~/ 20);
    final totalXp = (won ? BalloonPopConfig.winXp : BalloonPopConfig.lossXp) + (_level * 2);
    
    // Navigate to existing GameResultScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          won: won,
          coins: totalCoins.clamp(0, 100),
          xp: totalXp.clamp(0, 100),
          score: _score,
          gameName: 'Balloon Pop',
          onContinue: () => Navigator.pop(context),
        ),
      ),
    );
  }
  
  void _restartGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _animationTimer?.cancel();
    _comboTimer?.cancel();
    _powerUpTimer?.cancel();
    _autoPopTimer?.cancel();
    
    _startCountdown();
    setState(() {});
  }
  
  void _pause() {
    if (_gameState == GameState.playing) {
      setState(() => _gameState = GameState.paused);
      _gameTimer?.cancel();
      _spawnTimer?.cancel();
      _animationTimer?.cancel();
    } else if (_gameState == GameState.paused) {
      setState(() => _gameState = GameState.playing);
      _startGameTimer();
      _startSpawnTimer();
      _startAnimationTimer();
    }
  }
  
  // =========================================================================
  // BUILD METHODS
  // =========================================================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: Stack(
        children: [
          // Game Canvas
          GestureDetector(
            onTapDown: (details) {
              if (_gameState != GameState.playing) {
                if (_gameState == GameState.idle) {
                  _startCountdown();
                }
                return;
              }
              
              // Check for balloon taps
              final size = MediaQuery.of(context).size;
              final tapX = details.localPosition.dx / size.width;
              final tapY = details.localPosition.dy / size.height;
              
              // Check balloons (from top to bottom for better hit detection)
              for (int i = _balloons.length - 1; i >= 0; i--) {
                final balloon = _balloons[i];
                final balloonLeft = balloon.x - (balloon.size / size.width / 2);
                final balloonRight = balloon.x + (balloon.size / size.width / 2);
                final balloonTop = balloon.y - (balloon.size / size.height / 2);
                final balloonBottom = balloon.y;
                
                if (tapX >= balloonLeft && tapX <= balloonRight &&
                    tapY >= balloonTop && tapY <= balloonBottom) {
                  _popBalloon(balloon);
                  break;
                }
              }
              
              // Check power-ups
              for (int i = _powerUps.length - 1; i >= 0; i--) {
                final powerUp = _powerUps[i];
                final powerUpLeft = powerUp.x - 25 / size.width;
                final powerUpRight = powerUp.x + 25 / size.width;
                final powerUpTop = powerUp.y - 25 / size.height;
                final powerUpBottom = powerUp.y;
                
                if (tapX >= powerUpLeft && tapX <= powerUpRight &&
                    tapY >= powerUpTop && tapY <= powerUpBottom) {
                  _collectPowerUp(powerUp);
                  break;
                }
              }
            },
            child: CustomPaint(
              painter: AdvancedBalloonPainter(
                balloons: _balloons,
                powerUps: _powerUps,
                particles: _particles,
                backgroundOffset: _backgroundOffset,
                activePowerUp: _activePowerUp,
                shakeOffset: _shakeController.isAnimating 
                    ? sin(_shakeController.value * pi * 8) * 5 
                    : 0,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          
          // HUD Overlay
          _buildHUD(),
          
          // Game Overlay
          if (_gameState != GameState.playing)
            _buildOverlay(),
          
          // Feedback Message
          if (_feedbackMessage != null)
            _buildFeedbackMessage(),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Color(0xFFFFD700), Color(0xFF00FF88), Color(0xFFFF4081)],
              numberOfParticles: 30,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _victoryController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Color(0xFFFFD700), Color(0xFFFF4081), Color(0xFF00D4FF)],
              numberOfParticles: 50,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score Card
                _buildHUDCard('SCORE', '$_score', const Color(0xFFFFD700)),
                
                // Combo Card
                if (_combo > 0)
                  _buildComboCard(),
                
                // Level Card
                _buildHUDCard('LEVEL', '$_level', const Color(0xFF00D4FF)),
                
                // Time Card
                _buildTimeCard(),
              ],
            ),
            const Spacer(),
            
            // Power-up Indicator
            if (_activePowerUp != null)
              _buildPowerUpIndicator(),
            
            // Pause Button
            if (_gameState == GameState.playing)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: _pause,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.pause, color: Colors.white, size: 24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHUDCard(String label, String value, Color color) {
    return AnimatedBuilder(
      animation: _scoreController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(_scoreController.value * 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildComboCard() {
    return AnimatedBuilder(
      animation: _comboController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + _comboController.value * 0.3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4081), Color(0xFFFF6B6B)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4081).withOpacity(_comboController.value * 0.5),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('COMBO', style: TextStyle(fontSize: 10, color: Colors.white70)),
                Text('x$_combo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTimeCard() {
    final timeColor = _timeLeft > 10 
        ? const Color(0xFF00FF88) 
        : _timeLeft > 5 
            ? const Color(0xFFFFD700) 
            : const Color(0xFFFF0044);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [timeColor.withOpacity(0.2), timeColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: timeColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text('TIME', style: TextStyle(fontSize: 10, color: timeColor.withOpacity(0.8))),
          Text('$_timeLeft', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: timeColor)),
        ],
      ),
    );
  }
  
  Widget _buildPowerUpIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPowerUpColor(_activePowerUp!).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getPowerUpColor(_activePowerUp!)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getPowerUpEmoji(_activePowerUp!), style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            '$_powerUpRemaining',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.doubleScore: return const Color(0xFFFFD700);
      case PowerUpType.freezeTime: return const Color(0xFF00D4FF);
      case PowerUpType.slowMotion: return const Color(0xFF9C27B0);
      case PowerUpType.autoPop: return const Color(0xFF00FF88);
      case PowerUpType.comboBoost: return const Color(0xFFFF4081);
      case PowerUpType.shield: return const Color(0xFF2196F3);
    }
  }
  
  Widget _buildOverlay() {
    if (_gameState == GameState.idle) {
      return _buildStartScreen();
    }
    
    if (_gameState == GameState.countdown) {
      return _buildCountdownScreen();
    }
    
    if (_gameState == GameState.paused) {
      return _buildPauseMenu();
    }
    
    if (_gameState == GameState.gameOver) {
      return _buildGameOverScreen();
    }
    
    return const SizedBox.shrink();
  }
  
  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + _pulseController.value * 0.4,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [const Color(0xFFFFD700).withOpacity(0.3), Colors.transparent],
                    ),
                  ),
                  child: const Text('🎈', style: TextStyle(fontSize: 80)),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'BALLOON POP',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700),
              shadows: const [Shadow(color: Color(0xFFFFD700), blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pop as many balloons as you can!',
            style: TextStyle(color: Color(0xFF8AACCC), fontSize: 14),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _startCountdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF6B00)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [BoxShadow(color: Color(0xFFFFD700), blurRadius: 20)],
              ),
              child: const Text(
                'START POPPING',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCountdownScreen() {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.5 + value * 0.5,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0xFFFFD700), Color(0xFFFF6B00)]),
                boxShadow: [BoxShadow(color: Color(0xFFFFD700), blurRadius: 30)],
              ),
              child: const Center(
                child: Text(
                  '3',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPauseMenu() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00D4FF), width: 2),
          boxShadow: const [BoxShadow(color: Color(0xFF00D4FF), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PAUSED', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00D4FF))),
            const SizedBox(height: 24),
            _buildMenuButton('RESUME', _pause, const Color(0xFF00FF88)),
            const SizedBox(height: 12),
            _buildMenuButton('RESTART', _restartGame, const Color(0xFFFFD700)),
            const SizedBox(height: 12),
            _buildMenuButton('EXIT', () => Navigator.pop(context), const Color(0xFFFF0044)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFF0044), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎈', style: TextStyle(fontSize: 48)),
            const Text('GAME OVER', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF0044))),
            const SizedBox(height: 16),
            Text('Score: $_score', style: const TextStyle(fontSize: 18, color: Colors.white)),
            Text('Balloons: $_balloonsPopped', style: const TextStyle(color: Color(0xFF8AACCC))),
            Text('Highest Combo: $_combo', style: const TextStyle(color: Color(0xFFFF4081))),
            Text('Level: $_level', style: const TextStyle(color: Color(0xFF00D4FF))),
            if (_highScore > 0)
              Text('High Score: $_highScore', style: const TextStyle(color: Color(0xFFFFD700))),
            const SizedBox(height: 24),
            _buildMenuButton('PLAY AGAIN', _restartGame, const Color(0xFF00FF88)),
            const SizedBox(height: 12),
            _buildMenuButton('EXIT', () => Navigator.pop(context), const Color(0xFFFF0044)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuButton(String text, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
      ),
    );
  }
  
  Widget _buildFeedbackMessage() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _feedbackColor?.withOpacity(0.2) ?? Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _feedbackColor ?? Colors.transparent, width: 1),
          ),
          child: Text(
            _feedbackMessage ?? '',
            style: TextStyle(fontSize: 16, color: _feedbackColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _animationTimer?.cancel();
    _comboTimer?.cancel();
    _powerUpTimer?.cancel();
    _autoPopTimer?.cancel();
    _pulseController.dispose();
    _shakeController.dispose();
    _comboController.dispose();
    _scoreController.dispose();
    _confettiController.dispose();
    _victoryController.dispose();
    super.dispose();
  }
}

// =============================================================================
// ADVANCED BALLOON PAINTER
// =============================================================================

class AdvancedBalloonPainter extends CustomPainter {
  final List<Balloon> balloons;
  final List<PowerUp> powerUps;
  final List<Particle> particles;
  final double backgroundOffset;
  final PowerUpType? activePowerUp;
  final double shakeOffset;
  
  AdvancedBalloonPainter({
    required this.balloons,
    required this.powerUps,
    required this.particles,
    required this.backgroundOffset,
    required this.activePowerUp,
    required this.shakeOffset,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(shakeOffset, 0);
    
    // Draw animated gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0A0A2A),
        const Color(0xFF1A1A4A),
        const Color(0xFF2A2A5A),
      ],
      stops: const [0, 0.5, 1],
    );
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    
    // Draw decorative elements
    for (int i = 0; i < 20; i++) {
      final x = (i * 131 + backgroundOffset * 100) % size.width;
      final y = (i * 253) % size.height;
      final paint = Paint()..color = Colors.white.withOpacity(0.05);
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
    
    // Draw particles
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
    
    // Draw power-ups
    for (final powerUp in powerUps) {
      final x = powerUp.x * size.width;
      final y = powerUp.y * size.height;
      
      final glowPaint = Paint()
        ..color = powerUp.color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawCircle(Offset(x + 20, y), 25, glowPaint);
      
      // Draw power-up background
      final paint = Paint()..color = powerUp.color.withOpacity(0.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y - 20, 40, 40),
          const Radius.circular(10),
        ),
        paint,
      );
      
      // Draw power-up icon
      final textPainter = TextPainter(
        text: TextSpan(text: powerUp.emoji, style: const TextStyle(fontSize: 24)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 8, y - 12));
    }
    
    // Draw balloons
    for (final balloon in balloons) {
      final x = balloon.x * size.width;
      final y = balloon.y * size.height;
      final balloonSize = balloon.size;
      
      // Glow effect
      final glowPaint = Paint()
        ..color = balloon.color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      
      canvas.drawCircle(Offset(x + balloonSize / 2, y + balloonSize / 2), balloonSize / 1.5, glowPaint);
      
      // Draw balloon string
      final stringPaint = Paint()
        ..color = Colors.brown.withOpacity(0.6)
        ..strokeWidth = 2;
      
      canvas.drawLine(
        Offset(x + balloonSize / 2, y + balloonSize),
        Offset(x + balloonSize / 2, y + balloonSize + 15),
        stringPaint,
      );
      
      // Draw balloon body
      final balloonPaint = Paint()
        ..shader = RadialGradient(
          colors: [balloon.color, balloon.color.withOpacity(0.6)],
          center: Alignment(-0.3, -0.3),
        ).createShader(Rect.fromCircle(center: Offset(x + balloonSize / 2, y + balloonSize / 2), radius: balloonSize / 2));
      
      canvas.drawCircle(
        Offset(x + balloonSize / 2, y + balloonSize / 2),
        balloonSize / 2,
        balloonPaint,
      );
      
      // Draw balloon highlight
      final highlightPaint = Paint()..color = Colors.white.withOpacity(0.3);
      canvas.drawCircle(
        Offset(x + balloonSize / 3, y + balloonSize / 3),
        balloonSize / 6,
        highlightPaint,
      );
      
      // Draw balloon emoji
      final textPainter = TextPainter(
        text: TextSpan(text: balloon.emoji, style: TextStyle(fontSize: balloonSize / 1.5)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + balloonSize / 4, y + balloonSize / 4));
    }
    
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(AdvancedBalloonPainter oldDelegate) => true;
}

// =============================================================================
// TEMPORARY CLASS FOR COMPATIBILITY (Remove when integrating)
// =============================================================================

// This is a placeholder for the existing GameResultScreen
// Remove this and use your actual GameResultScreen import
class GameResultScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(won ? '🏆 VICTORY!' : '💀 GAME OVER',
                style: const TextStyle(fontSize: 32, color: Color(0xFFFFD700))),
            const SizedBox(height: 16),
            Text('Score: $score', style: const TextStyle(color: Colors.white)),
            Text('+$coins coins, +$xp XP', style: const TextStyle(color: Color(0xFF00FF88))),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onContinue, child: const Text('Continue')),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// USAGE EXAMPLE:
// =============================================================================
/*
// To use this advanced Balloon Pop Game:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedBalloonPopGame(),
  ),
);
*/