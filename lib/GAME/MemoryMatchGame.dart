// =============================================================================
// FILE: memory_match_game_advanced.dart
// =============================================================================
// ADVANCED MEMORY MATCH GAME - Premium Brain-Training Card Game
// Features: Multiple themes, Power-ups, Combo system, Animations
// Compatible with existing BEEDI College ecosystem
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' show pi, Random;

// =============================================================================
// CONSTANTS & CONFIGURATION
// =============================================================================

// =============================================================================
// CONSTANTS & CONFIGURATION
// =============================================================================

class MemoryMatchConfig {
  // Game Settings
  static const int gridSize = 4; // 4x4 grid = 16 cards
  static const int totalPairs = 8;
  static const int baseTimeSeconds = 90;
  static const int baseScorePerMatch = 50;
  static const int perfectMatchBonus = 100;
  
  // Card Animation
  static const int cardFlipDuration = 300; // milliseconds
  
  // Difficulty Scaling
  static const int easyPairs = 6;   // 3x4 grid
  static const int mediumPairs = 8;  // 4x4 grid
  static const int hardPairs = 12;   // 4x6 grid
  static const int expertPairs = 16; // 4x8 grid
  
  // Combo System
  static const int comboTimeWindowMs = 2000;
  static const double comboMultiplierMax = 3.0;
  static const double comboMultiplierStep = 0.1;
  
  // Power-ups
  static const int powerUpCost = 50;
  static const int powerUpDuration = 10;
  
  // Rewards
  static const int winCoins = 60;
  static const int winXp = 80;
  static const int lossXp = 15;
  static const int targetScoreForWin = 400;
  
  // Visual
  static const double cardGlowIntensity = 0.4;
}
// =============================================================================
// ENUMS
// =============================================================================

enum GameState { idle, countdown, playing, paused, gameOver }
enum DifficultyLevel { easy, medium, hard, expert }
enum CardTheme { animals, emoji, fantasy, neon, space, nature, gaming }
enum PowerUpType { reveal, slowTimer, autoHint, freezeMistakes, doubleScore, shuffle }

// =============================================================================
// DATA MODELS
// =============================================================================

class CardData {
  final String id;
  final String value;
  final String emoji;
  final Color color;
  bool isFlipped;
  bool isMatched;
  int flipAnimationValue;
  
  CardData({
    required this.id,
    required this.value,
    required this.emoji,
    required this.color,
    this.isFlipped = false,
    this.isMatched = false,
    this.flipAnimationValue = 0,
  });
  
  factory CardData.fromTheme(String value, CardTheme theme) {
    switch (theme) {
      case CardTheme.animals:
        return CardData(
          id: value,
          value: value,
          emoji: _getAnimalEmoji(value),
          color: const Color(0xFFFF6B6B),
        );
      case CardTheme.emoji:
        return CardData(
          id: value,
          value: value,
          emoji: value,
          color: const Color(0xFFFFD700),
        );
      case CardTheme.fantasy:
        return CardData(
          id: value,
          value: value,
          emoji: _getFantasyEmoji(value),
          color: const Color(0xFF9C27B0),
        );
      case CardTheme.neon:
        return CardData(
          id: value,
          value: value,
          emoji: _getNeonEmoji(value),
          color: const Color(0xFF00D4FF),
        );
      case CardTheme.space:
        return CardData(
          id: value,
          value: value,
          emoji: _getSpaceEmoji(value),
          color: const Color(0xFF2196F3),
        );
      case CardTheme.nature:
        return CardData(
          id: value,
          value: value,
          emoji: _getNatureEmoji(value),
          color: const Color(0xFF4CAF50),
        );
      case CardTheme.gaming:
        return CardData(
          id: value,
          value: value,
          emoji: _getGamingEmoji(value),
          color: const Color(0xFFFF4081),
        );
    }
  }
  
  static String _getAnimalEmoji(String value) {
    final animals = {
      'Lion': '🦁', 'Tiger': '🐯', 'Fox': '🦊', 'Wolf': '🐺',
      'Bear': '🐻', 'Eagle': '🦅', 'Snake': '🐍', 'Monkey': '🐒',
    };
    return animals[value] ?? '🐾';
  }
  
  static String _getFantasyEmoji(String value) {
    final fantasy = {
      'Dragon': '🐉', 'Phoenix': '🔥', 'Unicorn': '🦄', 'Wizard': '🧙',
      'Elf': '🧝', 'Knight': '⚔️', 'Castle': '🏰', 'Treasure': '💎',
    };
    return fantasy[value] ?? '✨';
  }
  
  static String _getNeonEmoji(String value) {
    final neon = {
      'Neon': '💚', 'Cyber': '🤖', 'Glow': '✨', 'Laser': '⚡',
      'Pixel': '🎮', 'Wave': '🌊', 'Future': '🚀', 'Synth': '🎵',
    };
    return neon[value] ?? '💫';
  }
  
  static String _getSpaceEmoji(String value) {
    final space = {
      'Earth': '🌍', 'Mars': '🔴', 'Jupiter': '🟠', 'Saturn': '🪐',
      'Moon': '🌙', 'Star': '⭐', 'Galaxy': '🌌', 'Rocket': '🚀',
    };
    return space[value] ?? '🛸';
  }
  
  static String _getNatureEmoji(String value) {
    final nature = {
      'Flower': '🌸', 'Tree': '🌳', 'Mountain': '⛰️', 'Ocean': '🌊',
      'Sun': '☀️', 'Cloud': '☁️', 'Rainbow': '🌈', 'Leaf': '🍃',
    };
    return nature[value] ?? '🌿';
  }
  
  static String _getGamingEmoji(String value) {
    final gaming = {
      'Sword': '⚔️', 'Shield': '🛡️', 'Crown': '👑', 'Dice': '🎲',
      'Controller': '🎮', 'Coin': '💰', 'Heart': '❤️', 'Star': '⭐',
    };
    return gaming[value] ?? '🎯';
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
    this.remainingDuration = MemoryMatchConfig.powerUpDuration,
    this.isActive = false,
    this.cost = MemoryMatchConfig.powerUpCost,
  });
  
  static PowerUp fromType(PowerUpType type) {
    switch (type) {
      case PowerUpType.reveal:
        return PowerUp(
          type: type,
          name: 'Reveal',
          emoji: '👁️',
          color: const Color(0xFF00D4FF),
        );
      case PowerUpType.slowTimer:
        return PowerUp(
          type: type,
          name: 'Slow Time',
          emoji: '🐢',
          color: const Color(0xFF9C27B0),
        );
      case PowerUpType.autoHint:
        return PowerUp(
          type: type,
          name: 'Auto Hint',
          emoji: '💡',
          color: const Color(0xFF00FF88),
        );
      case PowerUpType.freezeMistakes:
        return PowerUp(
          type: type,
          name: 'Freeze',
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
      case PowerUpType.shuffle:
        return PowerUp(
          type: type,
          name: 'Shuffle',
          emoji: '🔄',
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

class MemoryStatistics {
  int highestScore = 0;
  int fastestCompletion = 0;
  int totalMatches = 0;
  double bestAccuracy = 0;
  int longestCombo = 0;
  int totalPlayTime = 0;
  int perfectGames = 0;
  int powerUpsUsed = 0;
  
  void updateStats(
    int score,      // 1
    int time,       // 2
    int matches,    // 3
    double accuracy, // 4
    int combo,      // 5
    int playTime,   // 6
    bool perfect,   // 7
  ) {
    if (score > highestScore) highestScore = score;
    if (time > 0 && (fastestCompletion == 0 || time < fastestCompletion)) fastestCompletion = time;
    totalMatches += matches;
    if (accuracy > bestAccuracy) bestAccuracy = accuracy;
    if (combo > longestCombo) longestCombo = combo;
    totalPlayTime += playTime;
    if (perfect) perfectGames++;
  }
}

// =============================================================================
// MAIN MEMORY MATCH GAME WIDGET
// =============================================================================

class AdvancedMemoryMatchGame extends StatefulWidget {
  final DifficultyLevel initialDifficulty;
  final CardTheme initialTheme;
  
  const AdvancedMemoryMatchGame({
    super.key, 
    this.initialDifficulty = DifficultyLevel.medium,
    this.initialTheme = CardTheme.emoji,
  });
  
  @override
  State<AdvancedMemoryMatchGame> createState() => _AdvancedMemoryMatchGameState();
}

class _AdvancedMemoryMatchGameState extends State<AdvancedMemoryMatchGame>
    with TickerProviderStateMixin {
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  late List<CardData> _cards;
  int? _firstSelectedIndex;
  int? _secondSelectedIndex;
  bool _isProcessing = false;
  
  int _score = 0;
  int _highScore = 0;
  int _combo = 0;
  int _level = 1;
  int _moves = 0;
  int _matchesFound = 0;
  int _timeLeft = MemoryMatchConfig.baseTimeSeconds;
  int _perfectGameCounter = 0;
  
  GameState _gameState = GameState.idle;
  DifficultyLevel _currentDifficulty = DifficultyLevel.medium;
  CardTheme _currentTheme = CardTheme.emoji;
  
  // Power-ups
  PowerUp? _activePowerUp;
  Timer? _powerUpTimer;
  int _scoreMultiplier = 1;
  bool _mistakesFrozen = false;
  bool _timeSlowed = false;
  
  // Available power-ups
  final List<PowerUp> _availablePowerUps = [];
  
  // Timers
  Timer? _gameTimer;
  Timer? _comboTimer;
  
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _comboController;
  late AnimationController _scoreController;
  late AnimationController _cardFlipController;
  late ConfettiController _confettiController;
  late ConfettiController _victoryController;
  
  // Visual effects
  final List<Particle> _particles = [];
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _pointsEarned = 0;
  bool _showHint = false;
  Timer? _hintTimer;
  
  // Statistics
  final MemoryStatistics _statistics = MemoryStatistics();
  int _playTimeSeconds = 0;
  Timer? _playTimeTimer;
  
  // Card values based on difficulty
  late List<String> _cardValues;
  
  // Random generator
  final Random _random = Random();
  
  // =========================================================================
  // INITIALIZATION
  // =========================================================================
  
  @override
  void initState() {
    super.initState();
    _currentDifficulty = widget.initialDifficulty;
    _currentTheme = widget.initialTheme;
    _initCardValues();
    _initControllers();
    _loadHighScore();
    _loadStatistics();
    _initPowerUps();
    _initGame();
  }
  
  void _initCardValues() {
    switch (_currentDifficulty) {
      case DifficultyLevel.easy:
        _cardValues = ['Lion', 'Tiger', 'Fox', 'Wolf', 'Bear', 'Eagle'];
        break;
      case DifficultyLevel.medium:
        _cardValues = ['Lion', 'Tiger', 'Fox', 'Wolf', 'Bear', 'Eagle', 'Snake', 'Monkey'];
        break;
      case DifficultyLevel.hard:
        _cardValues = ['Lion', 'Tiger', 'Fox', 'Wolf', 'Bear', 'Eagle', 'Snake', 'Monkey',
                       'Dragon', 'Phoenix', 'Unicorn', 'Wizard'];
        break;
      case DifficultyLevel.expert:
        _cardValues = ['Lion', 'Tiger', 'Fox', 'Wolf', 'Bear', 'Eagle', 'Snake', 'Monkey',
                       'Dragon', 'Phoenix', 'Unicorn', 'Wizard', 'Elf', 'Knight', 'Castle', 'Treasure'];
        break;
    }
  }
  
  int get _gridColumns {
    switch (_currentDifficulty) {
      case DifficultyLevel.easy: return 3;
      case DifficultyLevel.medium: return 4;
      case DifficultyLevel.hard: return 4;
      case DifficultyLevel.expert: return 4;
    }
  }
  
  int get _gridRows {
    switch (_currentDifficulty) {
      case DifficultyLevel.easy: return 4;
      case DifficultyLevel.medium: return 4;
      case DifficultyLevel.hard: return 6;
      case DifficultyLevel.expert: return 8;
    }
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
    
    _cardFlipController = AnimationController(
  vsync: this,
  duration: Duration(
    milliseconds: MemoryMatchConfig.cardFlipDuration,
  ),
);
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _victoryController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('memory_match_highscore') ?? 0;
    });
  }
  
  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('memory_match_highscore', _score);
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
      PowerUp.fromType(PowerUpType.reveal),
      PowerUp.fromType(PowerUpType.slowTimer),
      PowerUp.fromType(PowerUpType.autoHint),
      PowerUp.fromType(PowerUpType.freezeMistakes),
      PowerUp.fromType(PowerUpType.doubleScore),
      PowerUp.fromType(PowerUpType.shuffle),
    ]);
  }
  
  void _initGame() {
    // Create pairs
    List<CardData> cards = [];
    for (final value in _cardValues) {
      cards.add(CardData.fromTheme(value, _currentTheme));
      cards.add(CardData.fromTheme(value, _currentTheme));
    }
    // Shuffle
    cards.shuffle(_random);
    _cards = cards;
    
    _firstSelectedIndex = null;
    _secondSelectedIndex = null;
    _isProcessing = false;
    _score = 0;
    _combo = 0;
    _moves = 0;
    _matchesFound = 0;
    _perfectGameCounter = 0;
    _timeLeft = MemoryMatchConfig.baseTimeSeconds;
    _playTimeSeconds = 0;
    _scoreMultiplier = 1;
    _mistakesFrozen = false;
    _timeSlowed = false;
    _activePowerUp = null;
    _showHint = false;
    _particles.clear();
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
    });
    
    _initGame();
    _startGameTimer();
    _startPlayTimeTimer();
  }
  
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == GameState.playing && mounted) {
        setState(() {
          if (!_timeSlowed) {
            _timeLeft--;
          }
          
          if (_timeLeft <= 0) {
            timer.cancel();
            _gameOver();
          }
          
          // Time warning effects
          if (_timeLeft <= 10 && _timeLeft > 0) {
            _pulseController.forward(from: 0);
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
    _hintTimer?.cancel();
    
    _initGame();
    _startCountdown();
    setState(() {});
  }
  
  // =========================================================================
  // GAME LOGIC
  // =========================================================================
  
  void _onCardTap(int index) async {
    if (_gameState != GameState.playing) {
      if (_gameState == GameState.idle) {
        _startCountdown();
      }
      return;
    }
    
    if (_isProcessing) return;
    if (_cards[index].isMatched) return;
    if (_cards[index].isFlipped) return;
    
    // Check for second card already selected
    if (_firstSelectedIndex != null && _secondSelectedIndex != null) return;
    
    // Flip the card
    setState(() {
      _cards[index].isFlipped = true;
      _cards[index].flipAnimationValue = 1;
    });
    
    HapticFeedback.lightImpact();
    _addFlipParticles(index);
    
    if (_firstSelectedIndex == null) {
      // First card selected
      _firstSelectedIndex = index;
    } else if (_secondSelectedIndex == null && _firstSelectedIndex != index) {
      // Second card selected
      _secondSelectedIndex = index;
      _moves++;
      
      // Check for match
      final card1 = _cards[_firstSelectedIndex!];
      final card2 = _cards[index];
      
      if (card1.value == card2.value) {
        // Match found
        await _handleMatch(_firstSelectedIndex!, index);
      } else {
        // No match
        await _handleMismatch(_firstSelectedIndex!, index);
      }
    }
  }
  
Future<void> _handleMatch(int index1, int index2) async {
  _isProcessing = true;
  
  // Calculate points
  int pointsEarned = MemoryMatchConfig.baseScorePerMatch;
  
  // Perfect game bonus (no mismatches yet)
  if (_perfectGameCounter == 0 && _moves <= _cardValues.length) {
    pointsEarned += MemoryMatchConfig.perfectMatchBonus;
    _showFeedback('PERFECT MATCH! +${MemoryMatchConfig.perfectMatchBonus}', const Color(0xFFFFD700));
  }
  
  // Apply combo multiplier
  _combo++;
  final comboMultiplier = 1 + (_combo * 0.1).clamp(0, MemoryMatchConfig.comboMultiplierMax);
  pointsEarned = (pointsEarned * comboMultiplier).toInt();
  
  // Apply score multiplier from power-up
  pointsEarned *= _scoreMultiplier;
  
  _pointsEarned = pointsEarned;
  _score += pointsEarned;
  _matchesFound++;
  _perfectGameCounter++;
  
  // Update combo display
  if (_combo > 1 && _combo % 3 == 0) {
    _comboController.forward(from: 0);
    _showFeedback('COMBO x${(comboMultiplier).toStringAsFixed(1)}! 🔥', const Color(0xFFFF4081));
    _confettiController.play();
    HapticFeedback.mediumImpact();
  }
  
  // Mark cards as matched
  setState(() {
    _cards[index1].isMatched = true;
    _cards[index2].isMatched = true;
  });
  
  _addMatchParticles(index1, index2);
  _scoreController.forward(from: 0);
  
  // Reset combo timer
  _comboTimer?.cancel();
  _comboTimer = Timer(Duration(milliseconds: MemoryMatchConfig.comboTimeWindowMs), () {
    if (mounted && _gameState == GameState.playing) {
      setState(() {
        _combo = 0;
      });
    }
  });
  
  // Clear selection
  setState(() {
    _firstSelectedIndex = null;
    _secondSelectedIndex = null;
    _isProcessing = false;
  });
  
  _saveHighScore();
  
  // Check for victory
  if (_matchesFound == _cardValues.length) {
    _victoryController.play();
    _gameOver();
  }
}
  
  Future<void> _handleMismatch(int index1, int index2) async {
    _isProcessing = true;
    
    if (!_mistakesFrozen) {
      // Reset combo on mismatch
      _combo = 0;
      _comboTimer?.cancel();
      _perfectGameCounter = 0;
      
      // Time penalty in hard/expert modes
      if (_currentDifficulty == DifficultyLevel.hard) {
        _timeLeft -= 2;
      } else if (_currentDifficulty == DifficultyLevel.expert) {
        _timeLeft -= 3;
      }
    }
    
    _showFeedback('❌ No match', const Color(0xFFFF0044));
    _shakeController.forward(from: 0);
    _addMismatchParticles(index1, index2);
    HapticFeedback.heavyImpact();
    
    // Wait before flipping back
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted && _gameState == GameState.playing) {
      setState(() {
        _cards[index1].isFlipped = false;
        _cards[index1].flipAnimationValue = 0;
        _cards[index2].isFlipped = false;
        _cards[index2].flipAnimationValue = 0;
        _firstSelectedIndex = null;
        _secondSelectedIndex = null;
        _isProcessing = false;
      });
    }
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
      case PowerUpType.reveal:
        _revealCards();
        break;
      case PowerUpType.slowTimer:
        _timeSlowed = true;
        break;
      case PowerUpType.autoHint:
        _startAutoHint();
        break;
      case PowerUpType.freezeMistakes:
        _mistakesFrozen = true;
        break;
      case PowerUpType.doubleScore:
        _scoreMultiplier = 2;
        break;
      case PowerUpType.shuffle:
        _shuffleBoard();
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
        case PowerUpType.slowTimer:
          _timeSlowed = false;
          break;
        case PowerUpType.autoHint:
          _hintTimer?.cancel();
          _showHint = false;
          break;
        case PowerUpType.freezeMistakes:
          _mistakesFrozen = false;
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
  
  void _revealCards() {
    // Reveal two random unmatched cards for 2 seconds
    final unmatchedIndices = <int>[];
    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].isMatched && !_cards[i].isFlipped) {
        unmatchedIndices.add(i);
      }
    }
    
    if (unmatchedIndices.length >= 2) {
      unmatchedIndices.shuffle();
      final idx1 = unmatchedIndices[0];
      final idx2 = unmatchedIndices[1];
      
      setState(() {
        _cards[idx1].isFlipped = true;
        _cards[idx2].isFlipped = true;
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _gameState == GameState.playing) {
          setState(() {
            _cards[idx1].isFlipped = false;
            _cards[idx2].isFlipped = false;
          });
        }
      });
    }
  }
  
  void _startAutoHint() {
    _showHint = true;
    _hintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_gameState == GameState.playing && _showHint && mounted) {
        _showRandomHint();
      }
    });
  }
  
  void _showRandomHint() {
    // Find unmatched cards
    final unmatchedIndices = <int>[];
    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].isMatched && !_cards[i].isFlipped) {
        unmatchedIndices.add(i);
      }
    }
    
    if (unmatchedIndices.isNotEmpty) {
      final hintIndex = unmatchedIndices[_random.nextInt(unmatchedIndices.length)];
      // Flash the card
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {
            _cards[hintIndex].isFlipped = true;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _gameState == GameState.playing && !_cards[hintIndex].isMatched) {
              setState(() {
                _cards[hintIndex].isFlipped = false;
              });
            }
          });
        }
      });
    }
  }
  
  void _shuffleBoard() {
    // Get all unmatched cards
    final unmatchedCards = <CardData>[];
    final matchedIndices = <int>[];
    
    for (int i = 0; i < _cards.length; i++) {
      if (_cards[i].isMatched) {
        matchedIndices.add(i);
      } else {
        unmatchedCards.add(_cards[i]);
      }
    }
    
    // Shuffle unmatched cards
    unmatchedCards.shuffle(_random);
    
    // Place back
    int unmatchedIndex = 0;
    for (int i = 0; i < _cards.length; i++) {
      if (!matchedIndices.contains(i)) {
        _cards[i] = unmatchedCards[unmatchedIndex++];
        _cards[i].isFlipped = false;
        _cards[i].flipAnimationValue = 0;
      }
    }
    
    setState(() {
      _firstSelectedIndex = null;
      _secondSelectedIndex = null;
    });
    
    _showFeedback('Board shuffled!', const Color(0xFFFF6B00));
  }
  
  // =========================================================================
  // PARTICLE EFFECTS
  // =========================================================================
  
  void _addFlipParticles(int index) {
    // Get card position (simplified)
    for (int i = 0; i < 5; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.02,
        vy: (_random.nextDouble() - 0.5) * 0.02,
        size: 2 + _random.nextDouble() * 3,
        color: _cards[index].color,
        lifetime: 0.3,
      ));
    }
  }
  
  void _addMatchParticles(int index1, int index2) {
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.025,
        vy: (_random.nextDouble() - 0.5) * 0.025,
        size: 2 + _random.nextDouble() * 4,
        color: const Color(0xFF00FF88),
        lifetime: 0.5,
      ));
    }
    _confettiController.play();
  }
  
  void _addMismatchParticles(int index1, int index2) {
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(
        x: 0.5,
        y: 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.03,
        vy: (_random.nextDouble() - 0.5) * 0.03,
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
  _playTimeTimer?.cancel();
  _powerUpTimer?.cancel();
  _comboTimer?.cancel();
  _hintTimer?.cancel();

  final isPerfect = _perfectGameCounter == _cardValues.length;
  final accuracy = _matchesFound > 0 ? (_matchesFound / _cardValues.length) * 100 : 0.0;
  final completionTime = MemoryMatchConfig.baseTimeSeconds - _timeLeft;

  // Update statistics - ALL 7 parameters in correct order
  _statistics.updateStats(
    _score,           // score
    completionTime,   // time
    _matchesFound,    // matches
    accuracy,         // accuracy (double)
    _combo,           // combo
    _playTimeSeconds, // playTime
    isPerfect,        // perfect (bool)
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
    final won = _matchesFound == _cardValues.length;
    final accuracyBonus = (_matchesFound / _cardValues.length * 30).toInt();
    final totalCoins = (won ? MemoryMatchConfig.winCoins : 0) + (_score ~/ 20) + accuracyBonus;
    final totalXp = (won ? MemoryMatchConfig.winXp : MemoryMatchConfig.lossXp) + (_level * 2) + (_combo ~/ 3);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          won: won,
          coins: totalCoins.clamp(0, 150),
          xp: totalXp.clamp(0, 120),
          score: _score,
          gameName: 'Memory Match',
          onContinue: () => Navigator.pop(context),
        ),
      ),
    );
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
    final cardSize = screenSize.width / _gridColumns - 12;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
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
            child: _buildGameContent(cardSize),
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
    );
  }
  
  Widget _buildGameContent(double cardSize) {
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
    
    return Column(
      children: [
        // HUD
        _buildHUD(),
        
        // Game Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gridColumns,
                childAspectRatio: 1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _cards.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildCard(index, cardSize);
              },
            ),
          ),
        ),
        
        // Power-ups Row
        if (_availablePowerUps.isNotEmpty)
          _buildPowerUpsRow(),
        
        const SizedBox(height: 16),
      ],
    );
  }
  
Widget _buildCard(int index, double cardSize) {
  final card = _cards[index];
  final isFlipped = card.isFlipped || card.isMatched;
  
  return GestureDetector(
    onTap: () => _onCardTap(index),
    child: AnimatedContainer(
      duration: Duration(milliseconds: MemoryMatchConfig.cardFlipDuration),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(isFlipped ? 0 : pi), // Now pi is imported
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card.isMatched
                ? [card.color.withOpacity(0.3), card.color.withOpacity(0.1)]
                : (isFlipped
                    ? [card.color.withOpacity(0.2), card.color.withOpacity(0.1)]
                    : [const Color(0xFF1A1A4A), const Color(0xFF0A0A2A)]),
          ),
          border: Border.all(
            color: card.isMatched
                ? card.color
                : (isFlipped ? card.color : const Color(0xFF00D4FF).withOpacity(0.3)),
            width: card.isMatched ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (card.isMatched || isFlipped)
                  ? card.color.withOpacity(MemoryMatchConfig.cardGlowIntensity)
                  : Colors.transparent,
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: isFlipped
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.emoji,
                      style: TextStyle(fontSize: cardSize * 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.value,
                      style: TextStyle(
                        fontSize: cardSize * 0.15,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Text(
                  '?',
                  style: TextStyle(
                    fontSize: cardSize * 0.4,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
        ),
      ),
    ),
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
            
            // Moves Card
            _buildStatCard('MOVES', '$_moves', const Color(0xFF9C27B0)),
            
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
    final comboMultiplier = 1 + (_combo * 0.1).clamp(0, MemoryMatchConfig.comboMultiplierMax);
    
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
              'x${comboMultiplier.toStringAsFixed(1)}',
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
                  child: const Text('🧠', style: TextStyle(fontSize: 80)),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'MEMORY MATCH',
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700),
              shadows: const [Shadow(color: Color(0xFFFFD700), blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Match all pairs to win!',
            style: TextStyle(fontSize: 14, color: Color(0xFF8AACCC)),
          ),
          const SizedBox(height: 32),
          _buildDifficultySelector(),
          const SizedBox(height: 16),
          _buildThemeSelector(),
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
      ],
    );
  }
  
  Widget _buildDifficultyChip(DifficultyLevel difficulty, String label, Color color) {
    final isSelected = _currentDifficulty == difficulty;
    return GestureDetector(
      onTap: () => setState(() {
        _currentDifficulty = difficulty;
        _initCardValues();
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
  
  Widget _buildThemeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: CardTheme.values.map((theme) {
          final isSelected = _currentTheme == theme;
          return GestureDetector(
            onTap: () => setState(() => _currentTheme = theme),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFFFD700).withOpacity(0.2) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                _getThemeEmoji(theme),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  String _getThemeEmoji(CardTheme theme) {
    switch (theme) {
      case CardTheme.animals: return '🐾';
      case CardTheme.emoji: return '😊';
      case CardTheme.fantasy: return '🐉';
      case CardTheme.neon: return '💚';
      case CardTheme.space: return '🚀';
      case CardTheme.nature: return '🌿';
      case CardTheme.gaming: return '🎮';
    }
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
    final accuracy = _matchesFound > 0 ? (_matchesFound / _cardValues.length * 100).toInt() : 0;
    final completionTime = MemoryMatchConfig.baseTimeSeconds - _timeLeft;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _matchesFound == _cardValues.length ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_matchesFound == _cardValues.length ? '🏆' : '💀', style: const TextStyle(fontSize: 48)),
            Text(
              _matchesFound == _cardValues.length ? 'PERFECT!' : 'GAME OVER',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _matchesFound == _cardValues.length ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
              ),
            ),
            const SizedBox(height: 16),
            Text('Score: $_score', style: const TextStyle(fontSize: 18, color: Colors.white)),
            Text('Best: $_highScore', style: const TextStyle(color: Color(0xFFFFD700))),
            Text('Moves: $_moves', style: const TextStyle(color: Color(0xFF8AACCC))),
            Text('Accuracy: $accuracy%', style: const TextStyle(color: Color(0xFF00FF88))),
            Text('Time: ${completionTime}s', style: const TextStyle(color: Color(0xFF00D4FF))),
            Text('Matches: $_matchesFound/${_cardValues.length}', style: const TextStyle(color: Color(0xFFFF4081))),
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
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    _playTimeTimer?.cancel();
    _powerUpTimer?.cancel();
    _comboTimer?.cancel();
    _hintTimer?.cancel();
    _pulseController.dispose();
    _shakeController.dispose();
    _comboController.dispose();
    _scoreController.dispose();
    _cardFlipController.dispose();
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
// To use this advanced Memory Match Game:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedMemoryMatchGame(),
  ),
);

// With specific difficulty and theme:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedMemoryMatchGame(
      initialDifficulty: DifficultyLevel.hard,
      initialTheme: CardTheme.space,
    ),
  ),
);
*/