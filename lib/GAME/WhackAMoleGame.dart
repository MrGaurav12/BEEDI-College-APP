// =============================================================================
// FILE: whack_a_mole_game_advanced.dart
// =============================================================================
// ADVANCED WHACK A MOLE GAME - Premium Arcade Reaction Game
// Features: Multiple mole types, Power-ups, Combo system, Animations
// Compatible with existing BEEDI College ecosystem
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// CONSTANTS & CONFIGURATION
// =============================================================================

class WhackMoleConfig {
  // Game Settings
  static const int gridSize = 3; // 3x3 grid = 9 holes
  static const int baseTimeSeconds = 30;
  static const int baseScore = 10;
  static const int targetScoreForWin = 100;
  
  // Mole Timing
  static const int baseMoleDurationMs = 800;
  static const int minMoleDurationMs = 400;
  static const int moleSpawnIntervalMs = 600;
  
  // Difficulty Progression
  static const int speedIncreasePerLevel = 30;
  static const int levelUpScore = 100;
  
  // Scoring
  static const Map<MoleType, int> molePoints = {
    MoleType.normal: 10,
    MoleType.fast: 15,
    MoleType.golden: 50,
    MoleType.bomb: -20,
    MoleType.shield: 5,
    MoleType.giant: 25,
  };
  
  // Rewards
  static const int winCoins = 55;
  static const int winXp = 80;
  static const int lossXp = 15;
  
  // Visual
  static const double holeSize = 80;
  static const int moleAnimationDuration = 200; 
}

// =============================================================================
// ENUMS
// =============================================================================

enum GameState { idle, countdown, playing, paused, gameOver }
enum MoleType { normal, fast, golden, bomb, shield, giant }
enum PowerUpType { freezeTime, doubleScore, slowMotion, autoHit, comboBoost, shield }

// =============================================================================
// DATA MODELS
// =============================================================================

class Mole {
  final int id;
  final MoleType type;
  final DateTime spawnTime;
  bool isActive;
  double animationScale;
  int hitCount;
  
  Mole({
    required this.id,
    required this.type,
    required this.spawnTime,
    this.isActive = true,
    this.animationScale = 0,
    this.hitCount = 0,
  });
  
  int get points => WhackMoleConfig.molePoints[type]!;
  
  String get emoji {
    switch (type) {
      case MoleType.normal:
        return '🐹';
      case MoleType.fast:
        return '🐭';
      case MoleType.golden:
        return '🦔';
      case MoleType.bomb:
        return '💣';
      case MoleType.shield:
        return '🛡️';
      case MoleType.giant:
        return '🐻';
    }
  }
  
  Color get color {
    switch (type) {
      case MoleType.normal:
        return const Color(0xFF795548);
      case MoleType.fast:
        return const Color(0xFFFF6B6B);
      case MoleType.golden:
        return const Color(0xFFFFD700);
      case MoleType.bomb:
        return const Color(0xFF2C2C2C);
      case MoleType.shield:
        return const Color(0xFF2196F3);
      case MoleType.giant:
        return const Color(0xFF8D6E63);
    }
  }
  
  int get durationMs {
    switch (type) {
      case MoleType.fast:
        return 500;
      case MoleType.golden:
        return 600;
      default:
        return WhackMoleConfig.baseMoleDurationMs;
    }
  }
}

class PowerUp {
  final PowerUpType type;
  final String name;
  final String emoji;
  final Color color;
  int remainingDuration;
  bool isActive;
  int cost;
  
  PowerUp({
    required this.type,
    required this.name,
    required this.emoji,
    required this.color,
    this.remainingDuration = 8,
    this.isActive = false,
    this.cost = 50,
  });
  
  static PowerUp fromType(PowerUpType type) {
    switch (type) {
      case PowerUpType.freezeTime:
        return PowerUp(
          type: type,
          name: 'Freeze',
          emoji: '❄️',
          color: const Color(0xFF00D4FF),
        );
      case PowerUpType.doubleScore:
        return PowerUp(
          type: type,
          name: '2x Score',
          emoji: '2️⃣',
          color: const Color(0xFFFFD700),
        );
      case PowerUpType.slowMotion:
        return PowerUp(
          type: type,
          name: 'Slow Mo',
          emoji: '🐢',
          color: const Color(0xFF9C27B0),
        );
      case PowerUpType.autoHit:
        return PowerUp(
          type: type,
          name: 'Auto Hit',
          emoji: '🤖',
          color: const Color(0xFF00FF88),
        );
      case PowerUpType.comboBoost:
        return PowerUp(
          type: type,
          name: 'Combo+',
          emoji: '⚡',
          color: const Color(0xFFFF4081),
        );
      case PowerUpType.shield:
        return PowerUp(
          type: type,
          name: 'Shield',
          emoji: '🛡️',
          color: const Color(0xFF2196F3),
        );
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
    lifetime -= 1 / 60;
    opacity = lifetime / maxLifetime;
    return lifetime > 0;
  }
}

class WhackMoleStatistics {
  int highestScore = 0;
  int fastestReactionMs = 0;
  int totalMolesHit = 0;
  double bestAccuracy = 0;
  int longestCombo = 0;
  int totalPlayTime = 0;
  int perfectRounds = 0;
  int powerUpsUsed = 0;
  
  void updateStats(int score, int fastestTime, int hits, double accuracy, int combo, int playTime, bool perfect) {
    if (score > highestScore) highestScore = score;
    if (fastestTime > 0 && (fastestReactionMs == 0 || fastestTime < fastestReactionMs)) {
      fastestReactionMs = fastestTime;
    }
    totalMolesHit += hits;
    if (accuracy > bestAccuracy) bestAccuracy = accuracy;
    if (combo > longestCombo) longestCombo = combo;
    totalPlayTime += playTime;
    if (perfect) perfectRounds++;
  }
}

// =============================================================================
// MAIN WHACK A MOLE GAME WIDGET
// =============================================================================

class AdvancedWhackAMoleGame extends StatefulWidget {
  const AdvancedWhackAMoleGame({super.key});
  
  @override
  State<AdvancedWhackAMoleGame> createState() => _AdvancedWhackAMoleGameState();
}

class _AdvancedWhackAMoleGameState extends State<AdvancedWhackAMoleGame>
    with TickerProviderStateMixin {
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  final List<Mole?> _activeMoles = List.filled(9, null);
  int _score = 0;
  int _highScore = 0;
  int _combo = 0;
  int _level = 1;
  int _molesHit = 0;
  int _totalSpawned = 0;
  int _timeLeft = WhackMoleConfig.baseTimeSeconds;
  
  GameState _gameState = GameState.idle;
  
  // Timing
  int _currentMoleDuration = WhackMoleConfig.baseMoleDurationMs;
  int _currentSpawnInterval = WhackMoleConfig.moleSpawnIntervalMs;
  
  // Power-ups
  PowerUp? _activePowerUp;
  Timer? _powerUpTimer;
  int _scoreMultiplier = 1;
  bool _isTimeFrozen = false;
  bool _hasShield = false;
  bool _autoHitActive = false;
  double _gameSpeed = 1.0;
  
  // Available power-ups
  final List<PowerUp> _availablePowerUps = [];
  
  // Reaction tracking
  DateTime? _lastHitTime;
  int _fastestReaction = 0;
  List<int> _reactionTimes = [];
  
  // Timers
  Timer? _gameTimer;
  Timer? _moleSpawnTimer;
  Timer? _moleHideTimer;
  Timer? _comboTimer;
  Timer? _playTimeTimer;
  
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _comboController;
  late AnimationController _scoreController;
  late AnimationController _molePopController;
  late ConfettiController _confettiController;
  late ConfettiController _victoryController;
  
  // Visual effects
  final List<Particle> _particles = [];
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _pointsEarned = 0;
  
  // Statistics
  final WhackMoleStatistics _statistics = WhackMoleStatistics();
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
    _initPowerUps();
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
  
  // FIXED: Remove 'const' keyword
  _molePopController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: WhackMoleConfig.moleAnimationDuration),
  );
  
  _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  _victoryController = ConfettiController(duration: const Duration(seconds: 3));
}
  
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('whack_mole_highscore') ?? 0;
    });
  }
  
  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('whack_mole_highscore', _score);
      setState(() {
        _highScore = _score;
        _showFeedback('NEW HIGH SCORE! 🏆', const Color(0xFFFFD700));
      });
    }
  }
  
  Future<void> _loadStatistics() async {
    // Load from SharedPreferences or Firebase
    setState(() {});
  }
  
  void _initPowerUps() {
    _availablePowerUps.clear();
    _availablePowerUps.addAll([
      PowerUp.fromType(PowerUpType.freezeTime),
      PowerUp.fromType(PowerUpType.doubleScore),
      PowerUp.fromType(PowerUpType.slowMotion),
      PowerUp.fromType(PowerUpType.autoHit),
      PowerUp.fromType(PowerUpType.comboBoost),
      PowerUp.fromType(PowerUpType.shield),
    ]);
    _availablePowerUps.shuffle();
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
      _molesHit = 0;
      _totalSpawned = 0;
      _timeLeft = WhackMoleConfig.baseTimeSeconds;
      _playTimeSeconds = 0;
      _currentMoleDuration = WhackMoleConfig.baseMoleDurationMs;
      _currentSpawnInterval = WhackMoleConfig.moleSpawnIntervalMs;
      _scoreMultiplier = 1;
      _isTimeFrozen = false;
      _hasShield = false;
      _autoHitActive = false;
      _gameSpeed = 1.0;
      _activePowerUp = null;
      _reactionTimes.clear();
      _fastestReaction = 0;
      _lastHitTime = null;
      
      // Clear all active moles
      for (int i = 0; i < _activeMoles.length; i++) {
        _activeMoles[i] = null;
      }
    });
    
    _startGameTimer();
    _startMoleSpawner();
    _startPlayTimeTimer();
  }
  
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == GameState.playing && mounted) {
        setState(() {
          if (!_isTimeFrozen) {
            _timeLeft--;
            
            if (_timeLeft <= 0) {
              timer.cancel();
              _gameOver();
            }
            
            // Time warning effects
            if (_timeLeft <= 10 && _timeLeft > 0) {
              _pulseController.forward(from: 0);
            }
          }
        });
      }
    });
  }
  
  void _startMoleSpawner() {
    _moleSpawnTimer?.cancel();
    _moleSpawnTimer = Timer.periodic(
      Duration(milliseconds: (_currentSpawnInterval / _gameSpeed).toInt()),
      (_) {
        if (_gameState == GameState.playing && mounted) {
          _spawnMole();
        }
      },
    );
  }
  
  void _startPlayTimeTimer() {
    _playTimeTimer?.cancel();
    _playTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == GameState.playing && mounted) {
        setState(() => _playTimeSeconds++);
      }
    });
  }
  
  void _restartGame() {
    _gameTimer?.cancel();
    _moleSpawnTimer?.cancel();
    _playTimeTimer?.cancel();
    _powerUpTimer?.cancel();
    _comboTimer?.cancel();
    _moleHideTimer?.cancel();
    
    _startCountdown();
    setState(() {});
  }
  
  // =========================================================================
  // MOLE SPAWNING & MANAGEMENT
  // =========================================================================
  
  void _spawnMole() {
    // Find empty holes
    final List<int> emptyHoles = [];
    for (int i = 0; i < _activeMoles.length; i++) {
      if (_activeMoles[i] == null) {
        emptyHoles.add(i);
      }
    }
    
    if (emptyHoles.isEmpty) return;
    
    // Determine mole type based on score and level
    MoleType type;
    final random = _random.nextDouble();
    
    if (_score > 200 && random < 0.05) {
      type = MoleType.golden;
    } else if (_score > 100 && random < 0.08) {
      type = MoleType.fast;
    } else if (_score > 50 && random < 0.1) {
      type = MoleType.giant;
    } else if (_level > 2 && random < 0.07) {
      type = MoleType.bomb;
    } else if (_level > 1 && random < 0.12) {
      type = MoleType.shield;
    } else {
      type = MoleType.normal;
    }
    
    final holeIndex = emptyHoles[_random.nextInt(emptyHoles.length)];
    final mole = Mole(
      id: DateTime.now().millisecondsSinceEpoch,
      type: type,
      spawnTime: DateTime.now(),
    );
    
    setState(() {
      _activeMoles[holeIndex] = mole;
      _totalSpawned++;
    });
    
    _molePopController.forward(from: 0);
    
    // Auto-hide mole after duration
    final duration = Duration(milliseconds: (mole.durationMs / _gameSpeed).toInt());
    Timer(duration, () {
      if (mounted && _gameState == GameState.playing && _activeMoles[holeIndex]?.id == mole.id) {
        setState(() {
          _activeMoles[holeIndex] = null;
        });
        _combo = 0;
        _comboTimer?.cancel();
      }
    });
  }
  
  void _whackMole(int holeIndex) {
    if (_gameState != GameState.playing) {
      if (_gameState == GameState.idle) {
        _startCountdown();
      }
      return;
    }
    
    final mole = _activeMoles[holeIndex];
    if (mole == null || !mole.isActive) return;
    
    // Calculate reaction time
    final reactionTime = DateTime.now().difference(mole.spawnTime).inMilliseconds;
    _reactionTimes.add(reactionTime);
    if (_fastestReaction == 0 || reactionTime < _fastestReaction) {
      _fastestReaction = reactionTime;
    }
    
    // Handle bomb mole
    if (mole.type == MoleType.bomb) {
      if (_hasShield) {
        _hasShield = false;
        _showFeedback('🛡️ Shield saved you!', const Color(0xFF2196F3));
        _addShieldParticles(holeIndex);
      } else {
        _combo = 0;
        _score = max(0, _score + mole.points);
        _showFeedback('💣 BOMB! ${mole.points} points', const Color(0xFFFF0044));
        _shakeController.forward(from: 0);
        HapticFeedback.heavyImpact();
      }
      _addExplosionParticles(holeIndex);
      setState(() {
        _activeMoles[holeIndex] = null;
      });
      return;
    }
    
    // Calculate points
    int pointsEarned = mole.points;
    
    // Apply combo multiplier
    _combo++;
    final comboMultiplier = 1 + (_combo * 0.1).clamp(0, 3.0);
    pointsEarned = (pointsEarned * comboMultiplier).toInt();
    
    // Apply score multiplier from power-up
    pointsEarned *= _scoreMultiplier;
    
    _pointsEarned = pointsEarned;
    _score += pointsEarned;
    _molesHit++;
    
    // Update combo display
    if (_combo > 1 && _combo % 5 == 0) {
      _comboController.forward(from: 0);
      _showFeedback('COMBO x${_combo}! 🔥', const Color(0xFFFF4081));
      _confettiController.play();
      HapticFeedback.mediumImpact();
    }
    
    // Add visual effects
    _addHitParticles(holeIndex, mole.color);
    _scoreController.forward(from: 0);
    _showFeedback('+$pointsEarned ${mole.emoji}', const Color(0xFF00FF88));
    HapticFeedback.lightImpact();
    
    // Reset combo timer
    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted && _gameState == GameState.playing) {
        setState(() {
          _combo = 0;
        });
      }
    });
    
    // Auto-hit power-up (adds extra combo)
    if (_autoHitActive) {
      _combo++;
    }
    
    // Remove mole
    setState(() {
      _activeMoles[holeIndex] = null;
    });
    
    _saveHighScore();
    
    // Level progression
    final newLevel = 1 + (_score ~/ WhackMoleConfig.levelUpScore);
    if (newLevel > _level) {
      _level = newLevel;
      _updateDifficulty();
      _showFeedback('LEVEL $_level! ⚡', const Color(0xFFFFD700));
      HapticFeedback.mediumImpact();
    }
    
    // Check for victory
    if (_score >= WhackMoleConfig.targetScoreForWin) {
      _victoryController.play();
      _gameOver();
    }
  }
  
  void _updateDifficulty() {
    // Increase game speed with level
    _gameSpeed = 1.0 + (_level * 0.1);
    _gameSpeed = _gameSpeed.clamp(1.0, 2.5);
    
    // Update mole duration
    _currentMoleDuration = (WhackMoleConfig.baseMoleDurationMs - 
        (_level * WhackMoleConfig.speedIncreasePerLevel))
        .clamp(WhackMoleConfig.minMoleDurationMs, WhackMoleConfig.baseMoleDurationMs);
    
    // Update spawn interval
    _currentSpawnInterval = (WhackMoleConfig.moleSpawnIntervalMs - 
        (_level * WhackMoleConfig.speedIncreasePerLevel ~/ 2))
        .clamp(300, WhackMoleConfig.moleSpawnIntervalMs);
    
    _startMoleSpawner();
  }
  
  // =========================================================================
  // POWER-UPS
  // =========================================================================
  
  void _usePowerUp(PowerUp powerUp) {
    if (_gameState != GameState.playing) return;
    if (_score < powerUp.cost) {
      _showFeedback('Not enough points!', const Color(0xFFFF0044));
      return;
    }
    
    setState(() {
      _score -= powerUp.cost;
      _activePowerUp = powerUp;
      powerUp.isActive = true;
      _statistics.powerUpsUsed++;
    });
    
    _showFeedback('${powerUp.emoji} ${powerUp.name} ACTIVATED!', powerUp.color);
    _addPowerUpParticles(powerUp.color);
    HapticFeedback.mediumImpact();
    
    switch (powerUp.type) {
      case PowerUpType.freezeTime:
        _isTimeFrozen = true;
        break;
      case PowerUpType.doubleScore:
        _scoreMultiplier = 2;
        break;
      case PowerUpType.slowMotion:
        _gameSpeed = 0.5;
        _startMoleSpawner();
        break;
      case PowerUpType.autoHit:
        _autoHitActive = true;
        _startAutoHit();
        break;
      case PowerUpType.comboBoost:
        _combo += 10;
        _showFeedback('COMBO BOOST! x$_combo', const Color(0xFFFF4081));
        break;
      case PowerUpType.shield:
        _hasShield = true;
        break;
    }
    
    _availablePowerUps.remove(powerUp);
    _startPowerUpTimer(powerUp);
  }
  
  void _startAutoHit() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_autoHitActive || _gameState != GameState.playing) {
        timer.cancel();
        return;
      }
      
      // Find active mole and auto-hit it
      for (int i = 0; i < _activeMoles.length; i++) {
        if (_activeMoles[i] != null && _activeMoles[i]!.type != MoleType.bomb) {
          _whackMole(i);
          break;
        }
      }
    });
  }
  
  void _startPowerUpTimer(PowerUp powerUp) {
    _powerUpTimer?.cancel();
    _powerUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        powerUp.remainingDuration--;
        if (powerUp.remainingDuration <= 0) {
          timer.cancel();
          _deactivatePowerUp(powerUp);
        }
      });
    });
  }
  
  void _deactivatePowerUp(PowerUp powerUp) {
    setState(() {
      powerUp.isActive = false;
      
      switch (powerUp.type) {
        case PowerUpType.freezeTime:
          _isTimeFrozen = false;
          break;
        case PowerUpType.doubleScore:
          _scoreMultiplier = 1;
          break;
        case PowerUpType.slowMotion:
          _gameSpeed = 1.0;
          _startMoleSpawner();
          break;
        case PowerUpType.autoHit:
          _autoHitActive = false;
          break;
        case PowerUpType.shield:
          _hasShield = false;
          break;
        default:
          break;
      }
      
      if (_activePowerUp == powerUp) {
        _activePowerUp = null;
      }
    });
    
    _showFeedback('${powerUp.emoji} ${powerUp.name} expired', Colors.white54);
  }
  
  // =========================================================================
  // PARTICLE EFFECTS
  // =========================================================================
  
  void _addHitParticles(int holeIndex, Color color) {
    // Get hole position (simplified - using grid calculation)
    final row = holeIndex ~/ 3;
    final col = holeIndex % 3;
    final x = 0.2 + col * 0.3;
    final y = 0.4 + row * 0.2;
    
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 0.02,
        vy: (_random.nextDouble() - 0.5) * 0.02,
        size: 2 + _random.nextDouble() * 4,
        color: color,
        lifetime: 0.5,
      ));
    }
  }
  
  void _addExplosionParticles(int holeIndex) {
    final row = holeIndex ~/ 3;
    final col = holeIndex % 3;
    final x = 0.2 + col * 0.3;
    final y = 0.4 + row * 0.2;
    
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 0.03,
        vy: (_random.nextDouble() - 0.5) * 0.03,
        size: 2 + _random.nextDouble() * 5,
        color: const Color(0xFFFF0044),
        lifetime: 0.6,
      ));
    }
  }
  
  void _addShieldParticles(int holeIndex) {
    final row = holeIndex ~/ 3;
    final col = holeIndex % 3;
    final x = 0.2 + col * 0.3;
    final y = 0.4 + row * 0.2;
    
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 0.03,
        vy: (_random.nextDouble() - 0.5) * 0.03,
        size: 2 + _random.nextDouble() * 4,
        color: const Color(0xFF2196F3),
        lifetime: 0.5,
      ));
    }
  }
  
  void _addPowerUpParticles(Color color) {
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.03,
        vy: (_random.nextDouble() - 0.5) * 0.03,
        size: 2 + _random.nextDouble() * 5,
        color: color,
        lifetime: 0.6,
      ));
    }
  }
  
  void _addVictoryParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.04,
        vy: (_random.nextDouble() - 0.5) * 0.04,
        size: 2 + _random.nextDouble() * 6,
        color: const Color(0xFFFFD700),
        lifetime: 0.8,
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
  _moleSpawnTimer?.cancel();
  _playTimeTimer?.cancel();
  _powerUpTimer?.cancel();
  _comboTimer?.cancel();
  _moleHideTimer?.cancel();
  
  final accuracy = _totalSpawned > 0 ? (_molesHit / _totalSpawned) * 100.0 : 0.0;
  final isPerfect = _molesHit == _totalSpawned && _totalSpawned > 0;
  
  // CORRECTED: Match the parameter order in WhackMoleStatistics.updateStats
  // The method expects: (score, fastestTime, hits, accuracy, combo, playTime, perfect)
  _statistics.updateStats(
    _score,           // int score
    _fastestReaction, // int fastestTime
    _molesHit,        // int hits
    accuracy,         // double accuracy
    _combo,           // int combo
    _playTimeSeconds, // int playTime
    isPerfect,        // bool perfect
  );
  
  _addVictoryParticles();
  _saveHighScore();
  HapticFeedback.heavyImpact();
  
  Future.delayed(const Duration(milliseconds: 500), () {
    if (mounted) {
      _showResult();
    }
  });
}
  
  void _showResult() {
    final won = _score >= WhackMoleConfig.targetScoreForWin;
    final accuracyBonus = (_molesHit / (_totalSpawned + 1) * 20).toInt();
    final totalCoins = (won ? WhackMoleConfig.winCoins : 0) + (_score ~/ 20) + accuracyBonus;
    final totalXp = (won ? WhackMoleConfig.winXp : WhackMoleConfig.lossXp) + (_level * 3) + (_combo ~/ 3);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          won: won,
          coins: totalCoins.clamp(0, 120),
          xp: totalXp.clamp(0, 120),
          score: _score,
          gameName: 'Whack A Mole',
          onContinue: () => Navigator.pop(context),
        ),
      ),
    );
  }
  
  void _pause() {
    if (_gameState == GameState.playing) {
      setState(() => _gameState = GameState.paused);
      _gameTimer?.cancel();
      _moleSpawnTimer?.cancel();
    } else if (_gameState == GameState.paused) {
      setState(() => _gameState = GameState.playing);
      _startGameTimer();
      _startMoleSpawner();
    }
  }
  
  // =========================================================================
  // BUILD METHODS
  // =========================================================================
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final holeSize = isTablet ? 100.0 : WhackMoleConfig.holeSize;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  const Color(0xFF0A2A0A),
                  const Color(0xFF1A3A1A),
                  const Color(0xFF0A1A0A),
                ],
              ),
            ),
          ),
          
          // Game Content
          SafeArea(
            child: Column(
              children: [
                _buildHUD(),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_gameState == GameState.playing || _gameState == GameState.paused)
                            _buildGameGrid(holeSize),
                          if (_gameState != GameState.playing && _gameState != GameState.paused)
                            _buildOverlay(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_gameState == GameState.playing && _availablePowerUps.isNotEmpty)
                  _buildPowerUpsRow(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Particles
          if (_particles.isNotEmpty)
            CustomPaint(
              painter: _ParticlePainter(_particles),
              child: const SizedBox.expand(),
            ),
          
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
        ],
      ),
    );
  }
  
  Widget _buildHUD() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score Card
          _buildScoreCard(),
          
          // Combo Card
          if (_combo > 0)
            _buildComboCard(),
          
          // Level Card
          _buildStatCard('LEVEL', '$_level', const Color(0xFF00D4FF)),
          
          // Time Card
          _buildTimeCard(),
        ],
      ),
    );
  }
  
  Widget _buildScoreCard() {
    return AnimatedBuilder(
      animation: _scoreController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFFFD700).withOpacity(0.2), const Color(0xFFFF6B00).withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(_scoreController.value * 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 8),
              Text(
                '$_score',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                  shadows: [Shadow(color: const Color(0xFFFFD700).withOpacity(_scoreController.value), blurRadius: 8)],
                ),
              ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4081), Color(0xFFFF6B6B)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4081).withOpacity(_comboController.value * 0.5),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Text(
              'x$_combo',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  Widget _buildTimeCard() {
    final timeColor = _timeLeft > 10 
        ? const Color(0xFF00FF88) 
        : _timeLeft > 5 
            ? const Color(0xFFFFD700) 
            : const Color(0xFFFF0044);
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [timeColor.withOpacity(0.2), timeColor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: timeColor.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: timeColor.withOpacity(_pulseController.value * 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.timer, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                '$_timeLeft',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: timeColor),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGameGrid(double holeSize) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final mole = _activeMoles[index];
        final isActive = mole != null;
        
        return GestureDetector(
          onTap: () => _whackMole(index),
          child: AnimatedBuilder(
            animation: _molePopController,
            builder: (context, child) {
              final scale = isActive 
                  ? 0.5 + _molePopController.value * 0.5 
                  : 1.0;
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2A1A0A),
                        const Color(0xFF1A0A00),
                      ],
                    ),
                    border: Border.all(
                      color: isActive 
                          ? (mole?.color ?? const Color(0xFFFF6B00)).withOpacity(0.8)
                          : const Color(0xFF8A6B4A).withOpacity(0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: (mole?.color ?? const Color(0xFFFF6B00)).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                  child: Center(
                    child: isActive
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                mole!.emoji,
                                style: TextStyle(
                                  fontSize: holeSize * 0.5,
                                  shadows: [
                                    Shadow(
                                      color: mole.color.withOpacity(0.8),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              if (mole.type != MoleType.normal)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: mole.color.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _getMoleLabel(mole.type),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: mole.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : const Text('🕳️', style: TextStyle(fontSize: 40)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  String _getMoleLabel(MoleType type) {
    switch (type) {
      case MoleType.normal: return '';
      case MoleType.fast: return 'FAST';
      case MoleType.golden: return 'GOLD';
      case MoleType.bomb: return 'BOMB';
      case MoleType.shield: return 'SHIELD';
      case MoleType.giant: return 'GIANT';
    }
  }
  
  Widget _buildPowerUpsRow() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _availablePowerUps.length,
        itemBuilder: (context, index) {
          final powerUp = _availablePowerUps[index];
          final canAfford = _score >= powerUp.cost;
          
          return GestureDetector(
            onTap: canAfford ? () => _usePowerUp(powerUp) : null,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [powerUp.color.withOpacity(canAfford ? 0.2 : 0.1), Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: canAfford ? powerUp.color : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  Text(powerUp.emoji, style: TextStyle(fontSize: 18, color: canAfford ? powerUp.color : Colors.white38)),
                  const SizedBox(width: 6),
                  Text(
                    '${powerUp.cost}',
                    style: TextStyle(
                      fontSize: 11,
                      color: canAfford ? const Color(0xFFFFD700) : Colors.white38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
                      colors: [const Color(0xFFFF6B00).withOpacity(0.3), Colors.transparent],
                    ),
                  ),
                  child: const Text('🐹', style: TextStyle(fontSize: 80)),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'WHACK A MOLE',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF6B00),
              shadows: const [Shadow(color: Color(0xFFFF6B00), blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the moles as fast as you can!',
            style: TextStyle(fontSize: 14, color: Color(0xFF8AACCC)),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _startCountdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFFFD700)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [BoxShadow(color: Color(0xFFFF6B00), blurRadius: 20)],
              ),
              child: const Text(
                'START GAME',
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
                gradient: RadialGradient(colors: [Color(0xFFFF6B00), Color(0xFFFFD700)]),
                boxShadow: [BoxShadow(color: Color(0xFFFF6B00), blurRadius: 30)],
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
    final accuracy = _totalSpawned > 0 ? (_molesHit / _totalSpawned * 100).toInt() : 0;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _score >= WhackMoleConfig.targetScoreForWin ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_score >= WhackMoleConfig.targetScoreForWin ? '🏆' : '💀', style: const TextStyle(fontSize: 48)),
            Text(
              _score >= WhackMoleConfig.targetScoreForWin ? 'VICTORY!' : 'GAME OVER',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _score >= WhackMoleConfig.targetScoreForWin ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
              ),
            ),
            const SizedBox(height: 16),
            Text('Score: $_score', style: const TextStyle(fontSize: 18, color: Colors.white)),
            Text('Best: $_highScore', style: const TextStyle(color: Color(0xFFFFD700))),
            Text('Moles Hit: $_molesHit', style: const TextStyle(color: Color(0xFF00FF88))),
            Text('Accuracy: $accuracy%', style: const TextStyle(color: Color(0xFF00D4FF))),
            Text('Max Combo: $_combo', style: const TextStyle(color: Color(0xFFFF4081))),
            Text('Level: $_level', style: const TextStyle(color: Color(0xFFFF6B00))),
            if (_fastestReaction > 0)
              Text('Fastest: ${_fastestReaction}ms', style: const TextStyle(color: Color(0xFF9C27B0))),
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
    _moleSpawnTimer?.cancel();
    _playTimeTimer?.cancel();
    _powerUpTimer?.cancel();
    _comboTimer?.cancel();
    _moleHideTimer?.cancel();
    _pulseController.dispose();
    _shakeController.dispose();
    _comboController.dispose();
    _scoreController.dispose();
    _molePopController.dispose();
    _confettiController.dispose();
    _victoryController.dispose();
    super.dispose();
  }
}

// =============================================================================
// PARTICLE PAINTER
// =============================================================================

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  
  _ParticlePainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
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
  }
  
  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

// =============================================================================
// TEMPORARY CLASS FOR COMPATIBILITY (Remove when integrating)
// =============================================================================

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
// To use this advanced Whack A Mole Game:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedWhackAMoleGame(),
  ),
);
*/