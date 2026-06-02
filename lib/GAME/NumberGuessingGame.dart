// =============================================================================
// FILE: number_guessing_game_advanced.dart
// =============================================================================
// ADVANCED NUMBER GUESSING GAME - Premium Brain-Training Puzzle
// Features: Multiple difficulty ranges, Power-ups, Combo system, Animations
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

class NumberGuessConfig {
  // Difficulty Ranges
  static const Map<String, int> difficultyRanges = {
    'Easy': 10,
    'Medium': 50,
    'Hard': 100,
    'Expert': 500,
    'Master': 1000,
  };
  
  // Attempts per difficulty
  static const Map<String, int> maxAttempts = {
    'Easy': 5,
    'Medium': 7,
    'Hard': 10,
    'Expert': 12,
    'Master': 15,
  };
  
  // Scoring
  static const int baseScore = 100;
  static const int perfectGuessBonus = 50;
  static const int streakBonus = 10;
  static const int timeBonus = 5;
  
  // Timer Settings
  static const int baseTimeSeconds = 60;
  static const int timeBonusPerGuess = 2;
  
  // Visual
  static const double guessButtonSize = 60;
  static const double numberPadButtonSize = 70;
}

// =============================================================================
// ENUMS
// =============================================================================

enum GameState { idle, countdown, playing, paused, gameOver }
enum DifficultyLevel { easy, medium, hard, expert, master }
enum GameMode { classic, timeAttack, survival, challenge }
enum PowerUpType { revealDigit, extraAttempt, freezeTimer, doubleScore, smartHint, skipNumber }

// =============================================================================
// DATA MODELS
// =============================================================================

class Guess {
  final int number;
  final DateTime timestamp;
  final bool isCorrect;
  final String hint;
  
  Guess({
    required this.number,
    required this.timestamp,
    required this.isCorrect,
    required this.hint,
  });
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
    this.remainingDuration = 10,
    this.isActive = false,
    this.cost = 50,
  });
  
  static PowerUp fromType(PowerUpType type) {
    switch (type) {
      case PowerUpType.revealDigit:
        return PowerUp(
          type: type,
          name: 'Reveal Digit',
          emoji: '🔢',
          color: const Color(0xFF00D4FF),
        );
      case PowerUpType.extraAttempt:
        return PowerUp(
          type: type,
          name: 'Extra Life',
          emoji: '❤️',
          color: const Color(0xFFFF4081),
        );
      case PowerUpType.freezeTimer:
        return PowerUp(
          type: type,
          name: 'Freeze Time',
          emoji: '❄️',
          color: const Color(0xFF2196F3),
        );
      case PowerUpType.doubleScore:
        return PowerUp(
          type: type,
          name: '2x Score',
          emoji: '2️⃣',
          color: const Color(0xFFFFD700),
        );
      case PowerUpType.smartHint:
        return PowerUp(
          type: type,
          name: 'Smart Hint',
          emoji: '🧠',
          color: const Color(0xFF9C27B0),
        );
      case PowerUpType.skipNumber:
        return PowerUp(
          type: type,
          name: 'Skip',
          emoji: '⏭️',
          color: const Color(0xFFFF6B00),
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

class NumberGuessStatistics {
  int highestScore = 0;
  int fastestGuessMs = 0;
  int totalWins = 0;
  double bestAccuracy = 0;
  int longestStreak = 0;
  int totalPlayTime = 0;
  int perfectRounds = 0;
  int powerUpsUsed = 0;
  
  void updateStats(int score, int fastestTime, int wins, double accuracy, int streak, int playTime, bool perfect) {
    if (score > highestScore) highestScore = score;
    if (fastestTime > 0 && (fastestGuessMs == 0 || fastestTime < fastestGuessMs)) fastestGuessMs = fastestTime;
    totalWins += wins;
    if (accuracy > bestAccuracy) bestAccuracy = accuracy;
    if (streak > longestStreak) longestStreak = streak;
    totalPlayTime += playTime;
    if (perfect) perfectRounds++;
  }
}

// =============================================================================
// MAIN NUMBER GUESSING GAME WIDGET
// =============================================================================

class AdvancedNumberGuessingGame extends StatefulWidget {
  final DifficultyLevel initialDifficulty;
  final GameMode initialMode;
  
  const AdvancedNumberGuessingGame({
    super.key,
    this.initialDifficulty = DifficultyLevel.medium,
    this.initialMode = GameMode.classic,
  });
  
  @override
  State<AdvancedNumberGuessingGame> createState() => _AdvancedNumberGuessingGameState();
}

class _AdvancedNumberGuessingGameState extends State<AdvancedNumberGuessingGame>
    with TickerProviderStateMixin {
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  late int _secretNumber;
  late int _minRange;
  late int _maxRange;
  int _attemptsUsed = 0;
  int _maxAttempts = 7;
  int _score = 0;
  int _highScore = 0;
  int _combo = 0;
  int _level = 1;
  int _currentStreak = 0;
  int _timeLeft = NumberGuessConfig.baseTimeSeconds;
  String? _hint;
  bool _isGameWon = false;
  
  GameState _gameState = GameState.idle;
  DifficultyLevel _currentDifficulty = DifficultyLevel.medium;
  GameMode _currentMode = GameMode.classic;
  
  // Guess history
  final List<Guess> _guessHistory = [];
  
  // Power-ups
  PowerUp? _activePowerUp;
  Timer? _powerUpTimer;
  int _scoreMultiplier = 1;
  bool _isTimeFrozen = false;
  int _extraAttempts = 0;
  
  // Available power-ups
  final List<PowerUp> _availablePowerUps = [];
  
  // Input
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  String _currentInput = '';
  
  // Timers
  Timer? _gameTimer;
  Timer? _comboTimer;
  Timer? _playTimeTimer;
  
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _comboController;
  late AnimationController _scoreController;
  late AnimationController _numberRevealController;
  late ConfettiController _confettiController;
  late ConfettiController _victoryController;
  
  // Visual effects
  final List<Particle> _particles = [];
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _pointsEarned = 0;
  bool _isRevealing = false;
  
  // Statistics
  final NumberGuessStatistics _statistics = NumberGuessStatistics();
  int _playTimeSeconds = 0;
  List<int> _guessTimes = [];
  DateTime? _lastGuessTime;
  
  // Keyboard
  final FocusNode _focusNode = FocusNode();
  
  // Random generator
  final Random _random = Random();
  
  // =========================================================================
  // INITIALIZATION
  // =========================================================================
  
  @override
  void initState() {
    super.initState();
    _currentDifficulty = widget.initialDifficulty;
    _currentMode = widget.initialMode;
    _updateDifficultySettings();
    _initControllers();
    _loadHighScore();
    _loadStatistics();
    _initPowerUps();
    _newGame();
  }
  
  void _updateDifficultySettings() {
    String difficultyKey;
    switch (_currentDifficulty) {
      case DifficultyLevel.easy:
        difficultyKey = 'Easy';
        break;
      case DifficultyLevel.medium:
        difficultyKey = 'Medium';
        break;
      case DifficultyLevel.hard:
        difficultyKey = 'Hard';
        break;
      case DifficultyLevel.expert:
        difficultyKey = 'Expert';
        break;
      case DifficultyLevel.master:
        difficultyKey = 'Master';
        break;
    }
    
    _maxRange = NumberGuessConfig.difficultyRanges[difficultyKey]!;
    _maxAttempts = NumberGuessConfig.maxAttempts[difficultyKey]!;
    _minRange = 1;
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
    
    _numberRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _victoryController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('number_guess_highscore') ?? 0;
    });
  }
  
  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('number_guess_highscore', _score);
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
      PowerUp.fromType(PowerUpType.revealDigit),
      PowerUp.fromType(PowerUpType.extraAttempt),
      PowerUp.fromType(PowerUpType.freezeTimer),
      PowerUp.fromType(PowerUpType.doubleScore),
      PowerUp.fromType(PowerUpType.smartHint),
      PowerUp.fromType(PowerUpType.skipNumber),
    ]);
    _availablePowerUps.shuffle();
  }
  
  void _newGame() {
    _secretNumber = _random.nextInt(_maxRange) + _minRange;
    _attemptsUsed = 0;
    _score = 0;
    _combo = 0;
    _level = 1;
    _currentStreak = 0;
    _timeLeft = NumberGuessConfig.baseTimeSeconds;
    _guessHistory.clear();
    _guessTimes.clear();
    _hint = null;
    _isGameWon = false;
    _scoreMultiplier = 1;
    _isTimeFrozen = false;
    _extraAttempts = 0;
    _activePowerUp = null;
    _currentInput = '';
    _inputController.clear();
    
    _showFeedback('New number generated!', const Color(0xFF00D4FF));
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
      _playTimeSeconds = 0;
      _isGameWon = false;
    });
    
    _newGame();
    _startGameTimer();
    _startPlayTimeTimer();
    _inputFocusNode.requestFocus();
  }
  
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == GameState.playing && mounted) {
        setState(() {
          if (!_isTimeFrozen) {
            _timeLeft--;
            
            if (_timeLeft <= 0 && _currentMode == GameMode.timeAttack) {
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
    _playTimeTimer?.cancel();
    _powerUpTimer?.cancel();
    _comboTimer?.cancel();
    
    _startCountdown();
    setState(() {});
  }
  
  // =========================================================================
  // GAME LOGIC
  // =========================================================================
  
  void _makeGuess() {
    if (_gameState != GameState.playing) {
      if (_gameState == GameState.idle) {
        _startCountdown();
      }
      return;
    }
    
    final guessNumber = int.tryParse(_currentInput);
    if (guessNumber == null) {
      _showFeedback('Enter a valid number!', const Color(0xFFFF0044));
      return;
    }
    
    if (guessNumber < _minRange || guessNumber > _maxRange) {
      _showFeedback('Enter number between $_minRange-$_maxRange!', const Color(0xFFFF0044));
      return;
    }
    
    // Calculate reaction time
    int reactionTime = 0;
    if (_lastGuessTime != null) {
      reactionTime = DateTime.now().difference(_lastGuessTime!).inMilliseconds;
    }
    _lastGuessTime = DateTime.now();
    _guessTimes.add(reactionTime);
    
    _attemptsUsed++;
    final isCorrect = guessNumber == _secretNumber;
    
    if (isCorrect) {
      _handleCorrectGuess(guessNumber, reactionTime);
    } else {
      _handleWrongGuess(guessNumber);
    }
    
    _currentInput = '';
    _inputController.clear();
    
    if (_isGameWon) {
      _gameWin();
    } else if (_attemptsUsed >= _maxAttempts + _extraAttempts) {
      _gameOver();
    }
  }
  
  void _handleCorrectGuess(int guessNumber, int reactionTime) {
    // Calculate points
    int pointsEarned = NumberGuessConfig.baseScore;
    
    // Perfect guess bonus (first attempt)
    if (_attemptsUsed == 1) {
      pointsEarned += NumberGuessConfig.perfectGuessBonus;
      _showFeedback('PERFECT GUESS! +${NumberGuessConfig.perfectGuessBonus}', const Color(0xFFFFD700));
    }
    
    // Combo bonus
    _combo++;
    pointsEarned += _combo * NumberGuessConfig.streakBonus;
    
    // Time bonus
    final timeBonus = (_timeLeft ~/ 5) * NumberGuessConfig.timeBonus;
    pointsEarned += timeBonus;
    
    // Apply score multiplier
    pointsEarned *= _scoreMultiplier;
    
    _pointsEarned = pointsEarned;
    _score += pointsEarned;
    _currentStreak++;
    _isGameWon = true;
    
    // Update combo display
    if (_combo > 1 && _combo % 3 == 0) {
      _comboController.forward(from: 0);
      _showFeedback('COMBO x${_combo}! 🔥', const Color(0xFFFF4081));
      _confettiController.play();
      HapticFeedback.mediumImpact();
    }
    
    // Add guess to history
    _guessHistory.add(Guess(
      number: guessNumber,
      timestamp: DateTime.now(),
      isCorrect: true,
      hint: '🎉 Correct!',
    ));
    
    _addCorrectParticles();
    _scoreController.forward(from: 0);
    _showFeedback('✓ CORRECT! +$pointsEarned', const Color(0xFF00FF88));
    HapticFeedback.lightImpact();
    
    // Reset combo timer
    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted && _gameState == GameState.playing) {
        setState(() {
          _combo = 0;
        });
      }
    });
    
    _saveHighScore();
  }
  
  void _handleWrongGuess(int guessNumber) {
    _combo = 0;
    _comboTimer?.cancel();
    _currentStreak = 0;
    
    String hintText;
    if (guessNumber < _secretNumber) {
      hintText = '⬆️ Too LOW! (${_maxAttempts + _extraAttempts - _attemptsUsed} attempts left)';
    } else {
      hintText = '⬇️ Too HIGH! (${_maxAttempts + _extraAttempts - _attemptsUsed} attempts left)';
    }
    
    setState(() {
      _hint = hintText;
    });
    
    // Add guess to history
    _guessHistory.add(Guess(
      number: guessNumber,
      timestamp: DateTime.now(),
      isCorrect: false,
      hint: hintText,
    ));
    
    _addWrongParticles();
    _shakeController.forward(from: 0);
    _showFeedback('✗ WRONG! $hintText', const Color(0xFFFF0044));
    HapticFeedback.heavyImpact();
    
    // Time penalty in survival mode
    if (_currentMode == GameMode.survival) {
      setState(() {
        _timeLeft -= 5;
      });
    }
  }
  
void _gameWin() {
  setState(() {
    _gameState = GameState.gameOver;
  });
  
  _gameTimer?.cancel();
  _playTimeTimer?.cancel();
  _powerUpTimer?.cancel();
  
  // Level progression
  final newLevel = 1 + (_score ~/ 500);
  if (newLevel > _level) {
    _level = newLevel;
  }
  
  // Calculate accuracy (ensure it's a double between 0 and 100)
  final accuracy = _guessHistory.isNotEmpty 
      ? (_guessHistory.where((g) => g.isCorrect).length / _guessHistory.length) * 100.0
      : 0.0;
  
  final isPerfect = _attemptsUsed == 1;
  final fastestGuess = _guessTimes.isNotEmpty ? _guessTimes.reduce(min) : 0;
  
  // CORRECTED: Make sure all parameters match the method signature
  _statistics.updateStats(
    _score,           // int score
    fastestGuess,     // int fastestTime
    1,                // int wins (1 for winning this game)
    accuracy,         // double accuracy
    _currentStreak,   // int streak
    _playTimeSeconds, // int playTime
    isPerfect,        // bool perfect
  );
  
  _addVictoryParticles();
  _victoryController.play();
  _saveHighScore();
  HapticFeedback.heavyImpact();
  
  Future.delayed(const Duration(milliseconds: 800), () {
    if (mounted) {
      _showResult();
    }
  });
}
    

  
void _gameOver() {
  if (_gameState != GameState.playing) return;
  
  setState(() {
    _gameState = GameState.gameOver;
  });
  
  _gameTimer?.cancel();
  _playTimeTimer?.cancel();
  _powerUpTimer?.cancel();
  
  // Calculate statistics - explicitly cast to double
  final double accuracy = _guessHistory.isNotEmpty 
      ? (_guessHistory.where((g) => g.isCorrect).length / _guessHistory.length) * 100.0
      : 0.0;
  final int fastestGuess = _guessTimes.isNotEmpty ? _guessTimes.reduce(min) : 0;
  
  _statistics.updateStats(
    _score,        // int
    fastestGuess,  // int
    0,             // int (wins)
    accuracy,      // double
    _currentStreak, // int
    _playTimeSeconds, // int
    false,         // bool
  );
  
  _addGameOverParticles();
  HapticFeedback.heavyImpact();
  
  Future.delayed(const Duration(milliseconds: 500), () {
    if (mounted) {
      _showResult();
    }
  });
}
  
  void _showResult() {
    final won = _isGameWon;
    final accuracy = _guessHistory.isNotEmpty 
        ? (_guessHistory.where((g) => g.isCorrect).length / _guessHistory.length * 100).toInt()
        : 0;
    
    // Calculate rewards
    int totalCoins = won ? 30 : 0;
    totalCoins += (_score ~/ 20);
    totalCoins += (_level * 2);
    
    int totalXp = won ? 50 : 10;
    totalXp += (_level * 3);
    totalXp += (_currentStreak ~/ 2);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          won: won,
          coins: totalCoins.clamp(0, 100),
          xp: totalXp.clamp(0, 100),
          score: _score,
          gameName: 'Number Guess',
          onContinue: () => Navigator.pop(context),
        ),
      ),
    );
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
      case PowerUpType.revealDigit:
        _revealDigit();
        break;
      case PowerUpType.extraAttempt:
        _extraAttempts++;
        _showFeedback('+1 Extra Attempt!', const Color(0xFFFF4081));
        break;
      case PowerUpType.freezeTimer:
        _isTimeFrozen = true;
        break;
      case PowerUpType.doubleScore:
        _scoreMultiplier = 2;
        break;
      case PowerUpType.smartHint:
        _showSmartHint();
        break;
      case PowerUpType.skipNumber:
        _skipNumber();
        break;
    }
    
    _availablePowerUps.remove(powerUp);
    _startPowerUpTimer(powerUp);
  }
  
  void _revealDigit() {
    final secretStr = _secretNumber.toString();
    final hiddenPositions = <int>[];
    
    // Find positions that haven't been revealed
    for (int i = 0; i < secretStr.length; i++) {
      hiddenPositions.add(i);
    }
    
    if (hiddenPositions.isNotEmpty) {
      final pos = hiddenPositions[_random.nextInt(hiddenPositions.length)];
      final digit = secretStr[pos];
      _showFeedback('🔢 Digit revealed: $digit', const Color(0xFF00D4FF));
    }
  }
  
  void _showSmartHint() {
    final range = _maxRange - _minRange;
    final quarter = range ~/ 4;
    final lowerQuarter = _minRange + quarter;
    final upperQuarter = _maxRange - quarter;
    
    if (_secretNumber < lowerQuarter) {
      _showFeedback('💡 Hint: Number is in the lower range', const Color(0xFF9C27B0));
    } else if (_secretNumber > upperQuarter) {
      _showFeedback('💡 Hint: Number is in the upper range', const Color(0xFF9C27B0));
    } else {
      _showFeedback('💡 Hint: Number is in the middle range', const Color(0xFF9C27B0));
    }
  }
  
  void _skipNumber() {
    _newGame();
    _showFeedback('New number generated!', const Color(0xFFFF6B00));
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
        case PowerUpType.freezeTimer:
          _isTimeFrozen = false;
          break;
        case PowerUpType.doubleScore:
          _scoreMultiplier = 1;
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
  
  void _addCorrectParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.6,
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
        y: 0.6,
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
  
  void _addGameOverParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.04,
        vy: (_random.nextDouble() - 0.5) * 0.04,
        size: 2 + _random.nextDouble() * 5,
        color: const Color(0xFFFF0044),
        lifetime: 0.6,
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
  // INPUT HANDLING
  // =========================================================================
  
  void _onNumberTap(String number) {
    if (_gameState != GameState.playing) return;
    
    setState(() {
      if (number == '⌫') {
        if (_currentInput.isNotEmpty) {
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        }
      } else if (number == 'C') {
        _currentInput = '';
      } else {
        // Limit input length based on max range
        final maxDigits = _maxRange.toString().length;
        if (_currentInput.length < maxDigits) {
          _currentInput += number;
        }
      }
      _inputController.text = _currentInput;
    });
    HapticFeedback.lightImpact();
  }
  
  void _pause() {
    if (_gameState == GameState.playing) {
      setState(() => _gameState = GameState.paused);
      _gameTimer?.cancel();
    } else if (_gameState == GameState.paused) {
      setState(() => _gameState = GameState.playing);
      _startGameTimer();
    }
  }
  
  // =========================================================================
  // BUILD METHODS
  // =========================================================================
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 900;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _focusNode,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.space) {
              _pause();
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              _makeGuess();
            }
          }
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            // Animated Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF0A0A2A),
                    const Color(0xFF1A1A4A),
                    const Color(0xFF2A2A5A),
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildGameInfo(),
                          const SizedBox(height: 24),
                          if (_hint != null) _buildHintCard(),
                          const SizedBox(height: 24),
                          _buildInputDisplay(),
                          const SizedBox(height: 24),
                          _buildNumberPad(isTablet, isDesktop),
                          const SizedBox(height: 16),
                          if (_availablePowerUps.isNotEmpty)
                            _buildPowerUpsRow(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Overlays
            if (_gameState != GameState.playing)
              _buildOverlay(),
            
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
          
          // Attempts Card
          _buildAttemptsCard(),
          
          // Time Card
          if (_currentMode == GameMode.timeAttack || _currentMode == GameMode.survival)
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
  
  Widget _buildAttemptsCard() {
    final remaining = _maxAttempts + _extraAttempts - _attemptsUsed;
    final color = remaining > 3 
        ? const Color(0xFF00FF88) 
        : (remaining > 1 
            ? const Color(0xFFFFD700) 
            : const Color(0xFFFF0044));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.try_sms_star_outlined, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            '$remaining/$_maxAttempts',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeCard() {
    final timeColor = _timeLeft > 20 
        ? const Color(0xFF00FF88) 
        : _timeLeft > 10 
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
  
  Widget _buildGameInfo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
          ),
          child: Text(
            'Guess the Number',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              color: const Color(0xFF00D4FF),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Range: $_minRange - $_maxRange',
          style: const TextStyle(fontSize: 14, color: Color(0xFF8AACCC)),
        ),
      ],
    );
  }
  
  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF9C27B0).withOpacity(0.2), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFF9C27B0), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _hint!,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF9C27B0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInputDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00D4FF).withOpacity(0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
      ),
      child: AnimatedBuilder(
        animation: _numberRevealController,
        builder: (context, child) {
          return Text(
            _currentInput.isEmpty ? '?' : _currentInput,
            style: GoogleFonts.orbitron(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00D4FF),
              letterSpacing: 4,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
  
  Widget _buildNumberPad(bool isTablet, bool isDesktop) {
    final buttonSize = isDesktop 
        ? NumberGuessConfig.numberPadButtonSize
        : (isTablet 
            ? NumberGuessConfig.numberPadButtonSize * 0.9
            : NumberGuessConfig.numberPadButtonSize * 0.8);
    
    final numbers = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['C', '0', '⌫'],
    ];
    
    return Column(
      children: numbers.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((num) {
              return GestureDetector(
                onTap: () => _onNumberTap(num),
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00D4FF).withOpacity(0.2),
                        const Color(0xFF00D4FF).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      num,
                      style: GoogleFonts.orbitron(
                        fontSize: buttonSize * 0.35,
                        fontWeight: FontWeight.bold,
                        color: num == 'C' || num == '⌫' 
                            ? const Color(0xFFFF6B00)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
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
                      colors: [const Color(0xFFFFD700).withOpacity(0.3), Colors.transparent],
                    ),
                  ),
                  child: const Text('🔢', style: TextStyle(fontSize: 80)),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'NUMBER GUESS',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700),
              shadows: const [Shadow(color: Color(0xFFFFD700), blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Guess the number within the range!',
            style: TextStyle(fontSize: 14, color: Color(0xFF8AACCC)),
          ),
          const SizedBox(height: 32),
          _buildDifficultySelector(),
          const SizedBox(height: 16),
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
  
  Widget _buildDifficultySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDifficultyChip(DifficultyLevel.easy, 'EASY', const Color(0xFF00FF88)),
        const SizedBox(width: 8),
        _buildDifficultyChip(DifficultyLevel.medium, 'MEDIUM', const Color(0xFFFFD700)),
        const SizedBox(width: 8),
        _buildDifficultyChip(DifficultyLevel.hard, 'HARD', const Color(0xFFFF6B00)),
        const SizedBox(width: 8),
        _buildDifficultyChip(DifficultyLevel.expert, 'EXPERT', const Color(0xFFFF0044)),
        const SizedBox(width: 8),
        _buildDifficultyChip(DifficultyLevel.master, 'MASTER', const Color(0xFF9C27B0)),
      ],
    );
  }
  
  Widget _buildDifficultyChip(DifficultyLevel difficulty, String label, Color color) {
    final isSelected = _currentDifficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() {
        _currentDifficulty = difficulty;
        _updateDifficultySettings();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.white70,
          ),
        ),
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
          borderRadius: BorderRadius.circular(20),
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
    final accuracy = _guessHistory.isNotEmpty 
        ? (_guessHistory.where((g) => g.isCorrect).length / _guessHistory.length * 100).toInt()
        : 0;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isGameWon ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isGameWon ? '🏆' : '💀', style: const TextStyle(fontSize: 48)),
            Text(
              _isGameWon ? 'VICTORY!' : 'GAME OVER',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isGameWon ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
              ),
            ),
            const SizedBox(height: 16),
            Text('Score: $_score', style: const TextStyle(fontSize: 18, color: Colors.white)),
            Text('Best: $_highScore', style: const TextStyle(color: Color(0xFFFFD700))),
            Text('Attempts: $_attemptsUsed/$_maxAttempts', style: const TextStyle(color: Color(0xFF00FF88))),
            Text('Accuracy: $accuracy%', style: const TextStyle(color: Color(0xFF00D4FF))),
            Text('Level: $_level', style: const TextStyle(color: Color(0xFFFF4081))),
            if (_isGameWon)
              Text('Perfect: ${_attemptsUsed == 1 ? "YES! 🎯" : "No"}', style: const TextStyle(color: Color(0xFFFFD700))),
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
    _playTimeTimer?.cancel();
    _powerUpTimer?.cancel();
    _comboTimer?.cancel();
    _inputController.dispose();
    _inputFocusNode.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _comboController.dispose();
    _scoreController.dispose();
    _numberRevealController.dispose();
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
// To use this advanced Number Guessing Game:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedNumberGuessingGame(),
  ),
);

// With specific difficulty and mode:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedNumberGuessingGame(
      initialDifficulty: DifficultyLevel.expert,
      initialMode: GameMode.timeAttack,
    ),
  ),
);
*/