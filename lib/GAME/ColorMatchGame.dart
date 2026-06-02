// =============================================================================
// FILE: color_match_game_advanced.dart
// =============================================================================
// ADVANCED COLOR MATCH GAME - Premium Arcade Reflex & Brain Training
// Features: Dynamic difficulty, Power-ups, Combo system, Animations
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

class ColorMatchConfig {
  // Game Settings
  static const int baseTimeSeconds = 45;
  static const int baseScorePerMatch = 10;
  static const int timeBonusPerMatch = 1;
  static const int targetScoreForWin = 100;
  
  // Difficulty Scaling
  static const double speedIncreasePerScore = 0.02;
  static const double minSpeed = 0.5;
  static const double maxSpeed = 2.5;
  static const int difficultyIncreaseInterval = 5;
  
  // Combo System
  static const int comboTimeWindowMs = 2000;
  static const double comboMultiplierMax = 3.0;
  static const double comboMultiplierStep = 0.1;
  
  // Power-ups
  static const double powerUpSpawnChance = 0.12;
  static const int powerUpDuration = 8;
  
  // Rewards
  static const int winCoins = 35;
  static const int winXp = 55;
  static const int lossXp = 10;
  
  // Visual
  static const double wordPulseIntensity = 0.3;
  static const double buttonGlowIntensity = 0.4;
}

// =============================================================================
// ENUMS
// =============================================================================

enum GameState { idle, countdown, playing, paused, gameOver }
enum GameMode { classic, timeAttack, survival, challenge }
enum DifficultyLevel { easy, normal, hard, expert }
enum PowerUpType { slowMotion, doubleScore, timeFreeze, hint, autoMatch, shield }

// =============================================================================
// DATA MODELS
// =============================================================================

class ColorMatchData {
  final String word;
  final String inkColor;
  final bool isMatch;
  
  ColorMatchData({
    required this.word,
    required this.inkColor,
  }) : isMatch = word == inkColor;
  
  Color get wordColor {
    switch (inkColor) {
      case 'Red': return Colors.red;
      case 'Blue': return Colors.blue;
      case 'Green': return Colors.green;
      case 'Yellow': return Colors.yellow;
      case 'Purple': return Colors.purple;
      case 'Orange': return Colors.orange;
      default: return Colors.white;
    }
  }
  
  static List<String> get colors => ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange'];
  
  factory ColorMatchData.random(Random random) {
    final colors = ColorMatchData.colors;
    final word = colors[random.nextInt(colors.length)];
    final inkColor = colors[random.nextInt(colors.length)];
    return ColorMatchData(word: word, inkColor: inkColor);
  }
}

class PowerUp {
  final PowerUpType type;
  final String name;
  final String emoji;
  final Color color;
  int remainingDuration;
  bool isActive;
  
  PowerUp({
    required this.type,
    required this.name,
    required this.emoji,
    required this.color,
    this.remainingDuration = ColorMatchConfig.powerUpDuration,
    this.isActive = false,
  });
  
  static PowerUp fromType(PowerUpType type) {
    switch (type) {
      case PowerUpType.slowMotion:
        return PowerUp(
          type: type,
          name: 'Slow Motion',
          emoji: '🐢',
          color: const Color(0xFF9C27B0),
        );
      case PowerUpType.doubleScore:
        return PowerUp(
          type: type,
          name: 'Double Score',
          emoji: '2️⃣',
          color: const Color(0xFFFFD700),
        );
      case PowerUpType.timeFreeze:
        return PowerUp(
          type: type,
          name: 'Time Freeze',
          emoji: '❄️',
          color: const Color(0xFF00D4FF),
        );
      case PowerUpType.hint:
        return PowerUp(
          type: type,
          name: 'Hint',
          emoji: '💡',
          color: const Color(0xFF00FF88),
        );
      case PowerUpType.autoMatch:
        return PowerUp(
          type: type,
          name: 'Auto Match',
          emoji: '🤖',
          color: const Color(0xFFFF6B00),
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

class ColorMatchStatistics {
  int highestScore = 0;
  int longestCombo = 0;
  int fastestReactionMs = 0;
  int totalMatches = 0;
  double bestAccuracy = 0;  // This should be double
  int totalPlayTime = 0;
  int powerUpsUsed = 0;
  
  void updateStats(
    int score, 
    int combo, 
    int reactionMs, 
    int matches, 
    double accuracy,  // This parameter expects double
    int playTime
  ) {
    if (score > highestScore) highestScore = score;
    if (combo > longestCombo) longestCombo = combo;
    if (reactionMs > 0 && (fastestReactionMs == 0 || reactionMs < fastestReactionMs)) {
      fastestReactionMs = reactionMs;
    }
    totalMatches += matches;
    if (accuracy > bestAccuracy) bestAccuracy = accuracy;
    totalPlayTime += playTime;
  }
}

// =============================================================================
// MAIN COLOR MATCH GAME WIDGET
// =============================================================================

class AdvancedColorMatchGame extends StatefulWidget {
  final GameMode initialMode;
  
  const AdvancedColorMatchGame({super.key, this.initialMode = GameMode.classic});
  
  @override
  State<AdvancedColorMatchGame> createState() => _AdvancedColorMatchGameState();
}

class _AdvancedColorMatchGameState extends State<AdvancedColorMatchGame>
    with TickerProviderStateMixin {
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  late ColorMatchData _currentQuestion;
  int _score = 0;
  int _highScore = 0;
  int _combo = 0;
  int _level = 1;
  int _timeLeft = ColorMatchConfig.baseTimeSeconds;
  int _totalAnswered = 0;
  int _correctAnswers = 0;
  int _fastestReaction = 0;
  DateTime? _questionStartTime;
  
  GameState _gameState = GameState.idle;
  GameMode _currentMode = GameMode.classic;
  DifficultyLevel _currentDifficulty = DifficultyLevel.normal;
  
  // Power-ups
  PowerUp? _activePowerUp;
  Timer? _powerUpTimer;
  int _scoreMultiplier = 1;
  bool _hasShield = false;
  bool _isTimeFrozen = false;
  double _currentSpeed = 1.0;
  
  // Available power-ups
  final List<PowerUp> _availablePowerUps = [];
  
  // Timers
  Timer? _gameTimer;
  Timer? _comboTimer;
  Timer? _difficultyTimer;
  
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _comboController;
  late AnimationController _scoreController;
  late AnimationController _wordController;
  late AnimationController _backgroundController;
  late ConfettiController _confettiController;
  late ConfettiController _victoryController;
  
  // Visual effects
  final List<Particle> _particles = [];
  Timer? _particleTimer;
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _pointsEarned = 0;
  bool _showHint = false;
  bool _autoMatchActive = false;
  Timer? _autoMatchTimer;
  
  // Statistics
  final ColorMatchStatistics _statistics = ColorMatchStatistics();
  int _playTimeSeconds = 0;
  List<int> _reactionTimes = [];
  
  // Random generator
  final Random _random = Random();
  
  // Keyboard controls
  final FocusNode _focusNode = FocusNode();
  
  // =========================================================================
  // INITIALIZATION
  // =========================================================================
  
  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _initControllers();
    _loadHighScore();
    _loadStatistics();
    _initPowerUps();
    _newQuestion();
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
    
    _wordController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _victoryController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('color_match_highscore') ?? 0;
    });
  }
  
  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('color_match_highscore', _score);
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
      PowerUp.fromType(PowerUpType.slowMotion),
      PowerUp.fromType(PowerUpType.doubleScore),
      PowerUp.fromType(PowerUpType.timeFreeze),
      PowerUp.fromType(PowerUpType.hint),
      PowerUp.fromType(PowerUpType.autoMatch),
      PowerUp.fromType(PowerUpType.shield),
    ]);
    _availablePowerUps.shuffle();
  }
  
  void _newQuestion() {
    setState(() {
      _currentQuestion = ColorMatchData.random(_random);
      _questionStartTime = DateTime.now();
      _showHint = false;
    });
    _wordController.forward(from: 0);
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
      _timeLeft = _currentMode == GameMode.timeAttack ? 60 : ColorMatchConfig.baseTimeSeconds;
      _totalAnswered = 0;
      _correctAnswers = 0;
      _reactionTimes.clear();
      _playTimeSeconds = 0;
      _currentSpeed = 1.0;
      _scoreMultiplier = 1;
      _hasShield = false;
      _isTimeFrozen = false;
      _activePowerUp = null;
      _availablePowerUps.clear();
      _initPowerUps();
      _particles.clear();
    });
    
    _newQuestion();
    _startGameTimer();
    _startDifficultyTimer();
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
            if (_timeLeft <= 5 && _timeLeft > 0) {
              _pulseController.forward(from: 0);
              if (_timeLeft <= 3) {
                _shakeController.forward(from: 0);
              }
            }
          }
        });
      }
    });
  }
  
void _startDifficultyTimer() {
  _difficultyTimer?.cancel();
  _difficultyTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
    if (_gameState == GameState.playing && mounted && _score > 0) {
      setState(() {
        // Increase difficulty based on score
        final targetSpeed = 1.0 + (_score / 50) * ColorMatchConfig.speedIncreasePerScore;
        _currentSpeed = targetSpeed.clamp(ColorMatchConfig.minSpeed, ColorMatchConfig.maxSpeed);
        
        // Level progression
        final newLevel = 1 + (_score ~/ ColorMatchConfig.difficultyIncreaseInterval);
        if (newLevel > _level) {
          _level = newLevel;
          _showFeedback('LEVEL $_level! ⚡', const Color(0xFFFFD700)); // FIXED: _level instead of _LEVEL
          HapticFeedback.mediumImpact();
          _updateDifficultyEffects();
        }
      });
    }
  });
}
  
  void _updateDifficultyEffects() {
    // Visual feedback for difficulty increase
    _addDifficultyParticles();
    _pulseController.forward(from: 0);
  }
  
  void _startPlayTimeTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == GameState.playing && mounted) {
        setState(() => _playTimeSeconds++);
      } else if (_gameState != GameState.playing) {
        timer.cancel();
      }
    });
  }
  
  void _restartGame() {
    _gameTimer?.cancel();
    _difficultyTimer?.cancel();
    _powerUpTimer?.cancel();
    _comboTimer?.cancel();
    _autoMatchTimer?.cancel();
    
    _startCountdown();
    setState(() {});
  }
  
  // =========================================================================
  // GAME LOGIC
  // =========================================================================
  
  void _answer(bool userSaysMatch) {
    if (_gameState != GameState.playing) {
      if (_gameState == GameState.idle) {
        _startCountdown();
      }
      return;
    }
    
    if (_autoMatchActive) return;
    
    final reactionTime = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : 0;
    _reactionTimes.add(reactionTime);
    if (_fastestReaction == 0 || reactionTime < _fastestReaction) {
      _fastestReaction = reactionTime;
    }
    
    final isCorrect = userSaysMatch == _currentQuestion.isMatch;
    _totalAnswered++;
    
    if (isCorrect) {
      _handleCorrectAnswer(reactionTime);
    } else {
      _handleWrongAnswer();
    }
    
    // Check for win condition
    if (_score >= ColorMatchConfig.targetScoreForWin) {
      _victoryController.play();
      _gameOver();
      return;
    }
    
    _newQuestion();
  }
  
  void _handleCorrectAnswer(int reactionTime) {
    // Calculate points with speed bonus
    int pointsEarned = ColorMatchConfig.baseScorePerMatch;
    final speedBonus = ((1000 - reactionTime.clamp(0, 1000)) / 100).floor();
    pointsEarned += speedBonus.clamp(0, 10);
    
    // Apply combo multiplier
    _combo++;
    final comboMultiplier = 1 + (_combo * 0.1).clamp(0, ColorMatchConfig.comboMultiplierMax);
    pointsEarned = (pointsEarned * comboMultiplier).toInt();
    
    // Apply score multiplier from power-up
    pointsEarned *= _scoreMultiplier;
    
    _pointsEarned = pointsEarned;
    _score += pointsEarned;
    _correctAnswers++;
    
    // Time bonus in time attack mode
    if (_currentMode == GameMode.timeAttack) {
      _timeLeft += ColorMatchConfig.timeBonusPerMatch;
    }
    
    // Update combo display
    if (_combo > 1 && _combo % 5 == 0) {
      _comboController.forward(from: 0);
      _showFeedback('COMBO x${(_combo * 0.1).toStringAsFixed(1)}! 🔥', const Color(0xFFFF4081));
      _confettiController.play();
      HapticFeedback.mediumImpact();
    }
    
    // Add visual effects
    _addCorrectParticles();
    _scoreController.forward(from: 0);
    HapticFeedback.lightImpact();
    
    // Reset combo timer
    _comboTimer?.cancel();
    _comboTimer = Timer(Duration(milliseconds: ColorMatchConfig.comboTimeWindowMs), () {
      if (mounted && _gameState == GameState.playing) {
        setState(() {
          _combo = 0;
        });
      }
    });
    
    _saveHighScore();
  }
  
  void _handleWrongAnswer() {
    if (_hasShield) {
      _hasShield = false;
      _activePowerUp = null;
      _showFeedback('🛡️ Shield protected you!', const Color(0xFF2196F3));
      _addShieldParticles();
      HapticFeedback.mediumImpact();
      return;
    }
    
    // Reset combo on wrong answer
    _combo = 0;
    _comboTimer?.cancel();
    
    // Damage in survival mode
    if (_currentMode == GameMode.survival) {
      _timeLeft -= 5;
      if (_timeLeft <= 0) {
        _gameOver();
        return;
      }
    }
    
    _showFeedback('❌ Wrong!', const Color(0xFFFF0044));
    _shakeController.forward(from: 0);
    _addWrongParticles();
    HapticFeedback.heavyImpact();
  }
  
  // =========================================================================
  // POWER-UPS
  // =========================================================================
  
  void _usePowerUp(PowerUp powerUp) {
    if (_gameState != GameState.playing) return;
    
    setState(() {
      _activePowerUp = powerUp;
      powerUp.isActive = true;
      _statistics.powerUpsUsed++;
    });
    
    _showFeedback('${powerUp.emoji} ${powerUp.name} ACTIVATED!', powerUp.color);
    _addPowerUpParticles(powerUp.color);
    HapticFeedback.mediumImpact();
    
    switch (powerUp.type) {
      case PowerUpType.slowMotion:
        _currentSpeed = 0.5;
        break;
      case PowerUpType.doubleScore:
        _scoreMultiplier = 2;
        break;
      case PowerUpType.timeFreeze:
        _isTimeFrozen = true;
        break;
      case PowerUpType.hint:
        _showHint = true;
        _wordController.forward(from: 0);
        break;
      case PowerUpType.autoMatch:
        _autoMatchActive = true;
        _startAutoMatch();
        break;
      case PowerUpType.shield:
        _hasShield = true;
        break;
    }
    
    _availablePowerUps.remove(powerUp);
    _startPowerUpTimer(powerUp);
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
        case PowerUpType.slowMotion:
          _currentSpeed = 1.0;
          break;
        case PowerUpType.doubleScore:
          _scoreMultiplier = 1;
          break;
        case PowerUpType.timeFreeze:
          _isTimeFrozen = false;
          break;
        case PowerUpType.hint:
          _showHint = false;
          break;
        case PowerUpType.autoMatch:
          _autoMatchActive = false;
          _autoMatchTimer?.cancel();
          break;
        case PowerUpType.shield:
          _hasShield = false;
          break;
      }
      
      if (_activePowerUp == powerUp) {
        _activePowerUp = null;
      }
    });
    
    _showFeedback('${powerUp.emoji} ${powerUp.name} expired', Colors.white54);
  }
  
  void _startAutoMatch() {
    _autoMatchTimer?.cancel();
    _autoMatchTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_gameState == GameState.playing && _autoMatchActive && mounted) {
        _answer(true);
      } else if (!_autoMatchActive) {
        timer.cancel();
      }
    });
  }
  
  // =========================================================================
  // PARTICLE EFFECTS
  // =========================================================================
  
  void _addCorrectParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.4,
        vx: (_random.nextDouble() - 0.5) * 0.02,
        vy: -_random.nextDouble() * 0.02,
        size: 2 + _random.nextDouble() * 4,
        color: const Color(0xFF00FF88),
        lifetime: 0.5,
      ));
    }
  }
  
  void _addWrongParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.4,
        vx: (_random.nextDouble() - 0.5) * 0.025,
        vy: (_random.nextDouble() - 0.5) * 0.02,
        size: 2 + _random.nextDouble() * 4,
        color: const Color(0xFFFF0044),
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
  
  void _addShieldParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.03,
        vy: (_random.nextDouble() - 0.5) * 0.03,
        size: 2 + _random.nextDouble() * 4,
        color: const Color(0xFF2196F3),
        lifetime: 0.5,
      ));
    }
  }
  
  void _addDifficultyParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.04,
        vy: (_random.nextDouble() - 0.5) * 0.04,
        size: 2 + _random.nextDouble() * 5,
        color: const Color(0xFFFFD700),
        lifetime: 0.6,
      ));
    }
  }
  
  void _addTransitionParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.7,
        vx: (_random.nextDouble() - 0.5) * 0.015,
        vy: -_random.nextDouble() * 0.015,
        size: 2 + _random.nextDouble() * 3,
        color: const Color(0xFF00D4FF),
        lifetime: 0.4,
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
  _difficultyTimer?.cancel();
  _powerUpTimer?.cancel();
  _comboTimer?.cancel();
  _autoMatchTimer?.cancel();

  // Calculate accuracy
 void _gameOver() {
  if (_gameState != GameState.playing) return;

  setState(() {
    _gameState = GameState.gameOver;
  });

  _gameTimer?.cancel();
  _difficultyTimer?.cancel();
  _powerUpTimer?.cancel();
  _comboTimer?.cancel();
  _autoMatchTimer?.cancel();

  // Calculate accuracy (as percentage 0-100)
  final accuracy = _totalAnswered > 0 
      ? (_correctAnswers / _totalAnswered) * 100  // Convert to percentage
      : 0.0;
  
  final avgReaction = _reactionTimes.isNotEmpty
      ? _reactionTimes.reduce((a, b) => a + b) ~/ _reactionTimes.length
      : 0;

  // Update statistics
  _statistics.updateStats(
    _score,
    (_combo * 0.1).round(),
    _fastestReaction,
    _totalAnswered,
    accuracy,  // Now this is a double (percentage)
    _playTimeSeconds,
  );

  _saveHighScore();
  _addTransitionParticles();
  HapticFeedback.heavyImpact();

  Future.delayed(const Duration(milliseconds: 500), () {
    if (mounted) {
      _showResult();
    }
  });
}

  _saveHighScore();
  _addTransitionParticles();
  HapticFeedback.heavyImpact();

  Future.delayed(const Duration(milliseconds: 500), () {
    if (mounted) {
      _showResult();
    }
  });
}
  
  void _showResult() {
    final won = _score >= ColorMatchConfig.targetScoreForWin;
    final accuracyBonus = (_correctAnswers / _totalAnswered * 20).toInt();
    final totalCoins = (won ? ColorMatchConfig.winCoins : 0) + (_score ~/ 10) + accuracyBonus;
    final totalXp = (won ? ColorMatchConfig.winXp : ColorMatchConfig.lossXp) + (_level * 2) + (_combo ~/ 2);
    
    // Navigate to existing GameResultScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          won: won,
          coins: totalCoins.clamp(0, 100),
          xp: totalXp.clamp(0, 100),
          score: _score,
          gameName: 'Color Match',
          onContinue: () => Navigator.pop(context),
        ),
      ),
    );
  }
  
  void _pause() {
    if (_gameState == GameState.playing) {
      setState(() => _gameState = GameState.paused);
      _gameTimer?.cancel();
      _difficultyTimer?.cancel();
    } else if (_gameState == GameState.paused) {
      setState(() => _gameState = GameState.playing);
      _startGameTimer();
      _startDifficultyTimer();
    }
  }
  
  // =========================================================================
  // BUILD METHODS
  // =========================================================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _focusNode,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyT) {
              _answer(true);
            } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
              _answer(false);
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              _pause();
            }
          }
          return KeyEventResult.handled;
        },
        child: WillPopScope(
          onWillPop: () async {
            if (_gameState == GameState.playing) {
              _pause();
              return false;
            }
            return true;
          },
          child: Stack(
            children: [
              // Animated Background
              AnimatedBuilder(
                animation: _backgroundController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          0.5 + sin(_backgroundController.value * pi * 2) * 0.1,
                          0.5 + cos(_backgroundController.value * pi * 2) * 0.1,
                        ),
                        radius: 1.5,
                        colors: [
                          const Color(0xFF0A0A2A),
                          const Color(0xFF1A1A4A),
                          const Color(0xFF2A2A5A),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // Game Content
              SafeArea(
                child: _buildGameContent(),
              ),
              
              // Particles
              if (_particles.isNotEmpty)
                CustomPaint(
                  painter: _ParticlePainter(_particles),
                  child: const SizedBox.expand(),
                ),
              
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
        ),
      ),
    );
  }
  
  Widget _buildGameContent() {
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
    
    return _buildGameplayLayout();
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
                  child: const Text('🎨', style: TextStyle(fontSize: 80)),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'COLOR MATCH',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700),
              shadows: const [Shadow(color: Color(0xFFFFD700), blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Does the WORD match the COLOR?',
            style: TextStyle(fontSize: 14, color: Color(0xFF8AACCC)),
          ),
          const SizedBox(height: 32),
          _buildModeSelector(),
          const SizedBox(height: 24),
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
                'START GAME',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeChip(GameMode.classic, 'CLASSIC', const Color(0xFF00D4FF)),
        const SizedBox(width: 12),
        _buildModeChip(GameMode.timeAttack, 'TIME ATTACK', const Color(0xFFFFD700)),
        const SizedBox(width: 12),
        _buildModeChip(GameMode.survival, 'SURVIVAL', const Color(0xFFFF4081)),
      ],
    );
  }
  
  Widget _buildModeChip(GameMode mode, String label, Color color) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _currentMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.white70,
          ),
        ),
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
    final accuracy = _totalAnswered > 0 ? (_correctAnswers / _totalAnswered * 100).toInt() : 0;
    final avgReaction = _reactionTimes.isNotEmpty
        ? _reactionTimes.reduce((a, b) => a + b) ~/ _reactionTimes.length
        : 0;
    
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
            const Text('🎨', style: TextStyle(fontSize: 48)),
            const Text('GAME OVER', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF0044))),
            const SizedBox(height: 16),
            Text('Score: $_score', style: const TextStyle(fontSize: 18, color: Colors.white)),
            Text('Best: $_highScore', style: const TextStyle(color: Color(0xFFFFD700))),
            Text('Accuracy: $accuracy%', style: const TextStyle(color: Color(0xFF00FF88))),
            Text('Level: $_level', style: const TextStyle(color: Color(0xFF00D4FF))),
            Text('Fastest: ${_fastestReaction}ms', style: const TextStyle(color: Color(0xFFFF4081))),
            Text('Total: $_totalAnswered', style: const TextStyle(color: Color(0xFF8AACCC))),
            const SizedBox(height: 24),
            _buildMenuButton('PLAY AGAIN', _restartGame, const Color(0xFF00FF88)),
            const SizedBox(height: 12),
            _buildMenuButton('EXIT', () => Navigator.pop(context), const Color(0xFFFF0044)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGameplayLayout() {
    final screenSize = MediaQuery.of(context).size;
    final isWide = screenSize.width > 600;
    
    return isWide ? _buildWideLayout() : _buildMobileLayout();
  }
  
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // HUD
        _buildHUD(),
        
        const Spacer(),
        
        // Main Game Area
        _buildGameArea(),
        
        const Spacer(),
        
        // Answer Buttons
        _buildAnswerButtons(),
        
        const SizedBox(height: 24),
        
        // Power-ups
        if (_availablePowerUps.isNotEmpty)
          _buildPowerUpsRow(),
        
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left Panel - Stats & Power-ups
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildStatsCard(),
                const Spacer(),
                if (_availablePowerUps.isNotEmpty)
                  _buildPowerUpsColumn(),
                const Spacer(),
                _buildMenuButton('PAUSE', _pause, const Color(0xFF00D4FF)),
              ],
            ),
          ),
        ),
        
        // Right Panel - Game
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHUD(),
              const Spacer(),
              _buildGameArea(),
              const Spacer(),
              _buildAnswerButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
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
                  fontSize: 24,
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
              'x${(1 + _combo * 0.1).toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 18,
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
          child: Column(
            children: [
              const Text('TIME', style: TextStyle(fontSize: 10, color: Color(0xFF8AACCC))),
              Text('$_timeLeft', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: timeColor)),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGameArea() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question text
          AnimatedBuilder(
            animation: _wordController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + _wordController.value * 0.1,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        _currentQuestion.wordColor.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _currentQuestion.word,
                    style: TextStyle(
                      fontSize: _showHint ? 48 : 64,
                      fontWeight: FontWeight.bold,
                      color: _currentQuestion.wordColor,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: _currentQuestion.wordColor.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Hint indicator
          if (_showHint)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00FF88)),
              ),
              child: Text(
                _currentQuestion.isMatch ? '✓ MATCHES!' : '✗ DOES NOT MATCH',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00FF88),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildAnswerButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildAnswerButton(
              'MATCH ✓',
              const Color(0xFF00FF88),
              () => _answer(true),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildAnswerButton(
              'NO ✗',
              const Color(0xFFFF0044),
              () => _answer(false),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnswerButton(String text, Color color, VoidCallback onTap) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(_pulseController.value * ColorMatchConfig.buttonGlowIntensity),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPowerUpsRow() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _availablePowerUps.length,
        itemBuilder: (context, index) {
          final powerUp = _availablePowerUps[index];
          return GestureDetector(
            onTap: () => _usePowerUp(powerUp),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [powerUp.color.withOpacity(0.2), Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: powerUp.color),
              ),
              child: Row(
                children: [
                  Text(powerUp.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    powerUp.name,
                    style: TextStyle(fontSize: 12, color: powerUp.color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPowerUpsColumn() {
    return Column(
      children: _availablePowerUps.map((powerUp) {
        return GestureDetector(
          onTap: () => _usePowerUp(powerUp),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [powerUp.color.withOpacity(0.2), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: powerUp.color),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(powerUp.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  powerUp.name,
                  style: TextStyle(fontSize: 12, color: powerUp.color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildStatsCard() {
    final accuracy = _totalAnswered > 0 ? (_correctAnswers / _totalAnswered * 100).toInt() : 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0A1628), const Color(0xFF0F2040)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STATISTICS', style: TextStyle(fontSize: 12, color: Color(0xFF8AACCC), letterSpacing: 2)),
          const SizedBox(height: 16),
          _buildStatItem('Score', '$_score', const Color(0xFFFFD700)),
          _buildStatItem('Best', '$_highScore', const Color(0xFF00D4FF)),
          _buildStatItem('Accuracy', '$accuracy%', const Color(0xFF00FF88)),
          _buildStatItem('Combo', '${(_combo * 0.1).toStringAsFixed(1)}x', const Color(0xFFFF4081)),
          _buildStatItem('Correct', '$_correctAnswers/$_totalAnswered', const Color(0xFF9C27B0)),
          _buildStatItem('Fastest', '${_fastestReaction}ms', const Color(0xFFFFD700)),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8AACCC))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  Widget _buildMenuButton(String text, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    _difficultyTimer?.cancel();
    _powerUpTimer?.cancel();
    _comboTimer?.cancel();
    _autoMatchTimer?.cancel();
    _pulseController.dispose();
    _shakeController.dispose();
    _comboController.dispose();
    _scoreController.dispose();
    _wordController.dispose();
    _backgroundController.dispose();
    _confettiController.dispose();
    _victoryController.dispose();
    _focusNode.dispose();
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
// To use this advanced Color Match Game:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedColorMatchGame(),
  ),
);

// With specific mode:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedColorMatchGame(initialMode: GameMode.timeAttack),
  ),
);
*/