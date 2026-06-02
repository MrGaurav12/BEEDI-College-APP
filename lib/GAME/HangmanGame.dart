// =============================================================================
// FILE: hangman_game_advanced.dart
// =============================================================================
// ADVANCED HANGMAN GAME - Premium Word Puzzle Experience
// Features: Multiple categories, Power-ups, Combo system, Animations
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

class HangmanConfig {
  // Game Settings
  static const int maxWrong = 6;
  static const int baseTimeSeconds = 60;
  static const int baseScorePerLetter = 10;
  static const int wordCompleteBonus = 100;
  static const int perfectGameBonus = 200;
  
  // Difficulty Settings
  static const int easyMaxWrong = 8;
  static const int hardMaxWrong = 5;
  static const int expertMaxWrong = 4;
  
  // Combo System
  static const int comboTimeWindowMs = 3000;
  static const double comboMultiplierMax = 3.0;
  
  // Power-ups
  static const int powerUpCost = 30;
  static const int powerUpDuration = 10;
  
  // Rewards
  static const int winCoins = 50;
  static const int winXp = 80;
  static const int lossXp = 15;
  static const int targetWordsForWin = 5;
  
  // Visual
  static const double letterButtonSize = 48;
  static const double letterButtonSizeTablet = 56;
  static const double letterButtonSizeDesktop = 60;
}

// =============================================================================
// ENUMS
// =============================================================================

enum GameState { idle, countdown, playing, paused, gameOver }
enum DifficultyLevel { easy, normal, hard, expert }
enum WordCategory { 
  animals, technology, movies, science, space, sports, gaming, countries, food, history 
}
enum PowerUpType { revealLetter, freezeTimer, removeWrong, doubleScore, extraLife, skipWord }

// =============================================================================
// WORD DATABASE
// =============================================================================

class WordDatabase {
  static const Map<WordCategory, List<String>> words = {
    WordCategory.animals: [
      'ELEPHANT', 'GIRAFFE', 'KANGAROO', 'DOLPHIN', 'PENGUIN',
      'CHEETAH', 'ZEBRA', 'RHINOCEROS', 'HIPPOPOTAMUS', 'CROCODILE',
      'BUTTERFLY', 'CHAMELEON', 'FLAMINGO', 'OCTOPUS', 'SCORPION'
    ],
    WordCategory.technology: [
      'COMPUTER', 'PROCESSOR', 'KEYBOARD', 'MONITOR', 'SOFTWARE',
      'ALGORITHM', 'DATABASE', 'NETWORK', 'FIREWALL', 'ENCRYPTION',
      'ARTIFICIAL', 'INTELLIGENCE', 'ROBOTICS', 'CYBERSECURITY', 'CLOUD'
    ],
    WordCategory.movies: [
      'INCEPTION', 'TITANIC', 'AVATAR', 'GLADIATOR', 'MATRIX',
      'INTERSTELLAR', 'FORREST', 'GUMP', 'PULP', 'FICTION',
      'DARK', 'KNIGHT', 'FROZEN', 'COCO', 'PARASITE'
    ],
    WordCategory.science: [
      'GRAVITY', 'ELECTRON', 'MOLECULE', 'EVOLUTION', 'QUANTUM',
      'RELATIVITY', 'MICROSCOPE', 'TELESCOPE', 'ECOSYSTEM', 'ATMOSPHERE',
      'RADIATION', 'FISSION', 'FUSION', 'GENETICS', 'NEURON'
    ],
    WordCategory.space: [
      'ASTRONAUT', 'GALAXY', 'NEBULA', 'COMET', 'ASTEROID',
      'TELESCOPE', 'SATELLITE', 'ROCKET', 'METEOR', 'CONSTELLATION',
      'ORBIT', 'LAUNCH', 'MISSION', 'EXPLORATION', 'OBSERVATORY'
    ],
    WordCategory.sports: [
      'BASKETBALL', 'FOOTBALL', 'BASEBALL', 'SOCCER', 'TENNIS',
      'VOLLEYBALL', 'HOCKEY', 'CRICKET', 'RUGBY', 'BADMINTON',
      'SKATEBOARD', 'SURFING', 'BOXING', 'WRESTLING', 'GYMNASTICS'
    ],
    WordCategory.gaming: [
      'NINTENDO', 'PLAYSTATION', 'XBOX', 'MINECRAFT', 'FORTNITE',
      'POKEMON', 'ZELDA', 'MARIO', 'SONIC', 'PACMAN',
      'PORTAL', 'HALO', 'OVERWATCH', 'LEAGUE', 'LEGENDS'
    ],
    WordCategory.countries: [
      'AUSTRALIA', 'GERMANY', 'JAPAN', 'BRAZIL', 'CANADA',
      'INDIA', 'FRANCE', 'ITALY', 'MEXICO', 'EGYPT',
      'ARGENTINA', 'NETHERLANDS', 'PORTUGAL', 'SWEDEN', 'NORWAY'
    ],
    WordCategory.food: [
      'CHOCOLATE', 'BANANA', 'PINEAPPLE', 'BROCCOLI', 'SPAGHETTI',
      'PIZZA', 'BURGER', 'SUSHI', 'TACOS', 'PASTA',
      'CURRY', 'SALAD', 'PANCAKE', 'WAFFLE', 'SMOOTHIE'
    ],
    WordCategory.history: [
      'PYRAMID', 'COLOSSEUM', 'GREATWALL', 'EMPIRE', 'REVOLUTION',
      'RENAISSANCE', 'INDUSTRIAL', 'DEMOCRACY', 'MONARCHY', 'CIVILIZATION',
      'ARCHAEOLOGY', 'FOSSIL', 'ARTIFACT', 'HIEROGLYPH', 'CUNEIFORM'
    ],
  };
  
  static final Set<String> _recentWords = {};
  static final Random _random = Random();
  
  static String getRandomWord({WordCategory? category, String? excludeWord}) {
    List<String> availableWords;
    
    if (category != null) {
      availableWords = List.from(words[category]!);
    } else {
      availableWords = words.values.expand((list) => list).toList();
    }
    
    // Filter out recent words
    availableWords = availableWords
        .where((word) => !_recentWords.contains(word))
        .toList();
    
    if (availableWords.isEmpty) {
      _recentWords.clear();
      if (category != null) {
        availableWords = List.from(words[category]!);
      } else {
        availableWords = words.values.expand((list) => list).toList();
      }
    }
    
    final word = availableWords[_random.nextInt(availableWords.length)];
    _recentWords.add(word);
    
    // Keep only last 10 words
    if (_recentWords.length > 10) {
      final first = _recentWords.first;
      _recentWords.remove(first);
    }
    
    return word;
  }
  
  static String getWordMeaning(String word) {
    final meanings = {
      'FLUTTER': 'Google\'s UI toolkit for building natively compiled applications',
      'FIREBASE': 'Google\'s mobile platform for app development',
      'ANDROID': 'Mobile operating system by Google',
      'PYRAMID': 'Ancient Egyptian monumental structures',
      'ASTRONAUT': 'Person trained to travel in spacecraft',
      'CHOCOLATE': 'Sweet food made from cacao beans',
    };
    return meanings[word] ?? 'Test your vocabulary skills!';
  }
  
  static DifficultyLevel getDifficultyForWord(String word) {
    if (word.length <= 5) return DifficultyLevel.easy;
    if (word.length <= 7) return DifficultyLevel.normal;
    if (word.length <= 9) return DifficultyLevel.hard;
    return DifficultyLevel.expert;
  }
}

// =============================================================================
// DATA MODELS
// =============================================================================

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
    this.remainingDuration = HangmanConfig.powerUpDuration,
    this.isActive = false,
    this.cost = HangmanConfig.powerUpCost,
  });
  
  static PowerUp fromType(PowerUpType type) {
    switch (type) {
      case PowerUpType.revealLetter:
        return PowerUp(
          type: type,
          name: 'Reveal',
          emoji: '👁️',
          color: const Color(0xFF00D4FF),
        );
      case PowerUpType.freezeTimer:
        return PowerUp(
          type: type,
          name: 'Freeze',
          emoji: '❄️',
          color: const Color(0xFF2196F3),
        );
      case PowerUpType.removeWrong:
        return PowerUp(
          type: type,
          name: 'Remove',
          emoji: '❌',
          color: const Color(0xFFFF6B00),
        );
      case PowerUpType.doubleScore:
        return PowerUp(
          type: type,
          name: '2x Score',
          emoji: '2️⃣',
          color: const Color(0xFFFFD700),
        );
      case PowerUpType.extraLife:
        return PowerUp(
          type: type,
          name: 'Extra Life',
          emoji: '❤️',
          color: const Color(0xFFFF4081),
        );
      case PowerUpType.skipWord:
        return PowerUp(
          type: type,
          name: 'Skip',
          emoji: '⏭️',
          color: const Color(0xFF9C27B0),
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

class HangmanStatistics {
  int highestScore = 0;
  int totalWordsSolved = 0;
  double bestAccuracy = 0;
  int longestStreak = 0;
  int fastestSolveTime = 0;
  int totalPlayTime = 0;
  int perfectRounds = 0;
  int powerUpsUsed = 0;
  
  void updateStats(int score, int words, double accuracy, int streak, int solveTime, int playTime, bool perfect) {
    if (score > highestScore) highestScore = score;
    totalWordsSolved += words;
    if (accuracy > bestAccuracy) bestAccuracy = accuracy;
    if (streak > longestStreak) longestStreak = streak;
    if (solveTime > 0 && (fastestSolveTime == 0 || solveTime < fastestSolveTime)) fastestSolveTime = solveTime;
    totalPlayTime += playTime;
    if (perfect) perfectRounds++;
  }
}

// =============================================================================
// MAIN HANGMAN GAME WIDGET
// =============================================================================

class AdvancedHangmanGame extends StatefulWidget {
  final DifficultyLevel initialDifficulty;
  final WordCategory? initialCategory;
  
  const AdvancedHangmanGame({
    super.key,
    this.initialDifficulty = DifficultyLevel.normal,
    this.initialCategory,
  });
  
  @override
  State<AdvancedHangmanGame> createState() => _AdvancedHangmanGameState();
}

class _AdvancedHangmanGameState extends State<AdvancedHangmanGame>
    with TickerProviderStateMixin {
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  late String _currentWord;
  late String _currentWordMeaning;
  Set<String> _guessedLetters = {};
  int _wrongCount = 0;
  int _maxWrong = HangmanConfig.maxWrong;
  
  int _score = 0;
  int _highScore = 0;
  int _combo = 0;
  int _level = 1;
  int _wordsSolved = 0;
  int _timeLeft = HangmanConfig.baseTimeSeconds;
  
  GameState _gameState = GameState.idle;
  DifficultyLevel _currentDifficulty = DifficultyLevel.normal;
  WordCategory? _selectedCategory;
  
  // Power-ups
  PowerUp? _activePowerUp;
  Timer? _powerUpTimer;
  int _scoreMultiplier = 1;
  bool _isTimeFrozen = false;
  
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
  late AnimationController _hangmanController;
  late ConfettiController _confettiController;
  late ConfettiController _victoryController;
  
  // Visual effects
  final List<Particle> _particles = [];
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _pointsEarned = 0;
  
  // Statistics
  final HangmanStatistics _statistics = HangmanStatistics();
  int _playTimeSeconds = 0;
  Timer? _playTimeTimer;
  int _currentStreak = 0;
  
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
    _selectedCategory = widget.initialCategory;
    _updateMaxWrong();
    _initControllers();
    _loadHighScore();
    _loadStatistics();
    _initPowerUps();
    _newWord();
  }
  
  void _updateMaxWrong() {
    switch (_currentDifficulty) {
      case DifficultyLevel.easy:
        _maxWrong = HangmanConfig.easyMaxWrong;
        break;
      case DifficultyLevel.normal:
        _maxWrong = HangmanConfig.maxWrong;
        break;
      case DifficultyLevel.hard:
        _maxWrong = HangmanConfig.hardMaxWrong;
        break;
      case DifficultyLevel.expert:
        _maxWrong = HangmanConfig.expertMaxWrong;
        break;
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
    
    _hangmanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _victoryController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('hangman_highscore') ?? 0;
    });
  }
  
  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('hangman_highscore', _score);
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
      PowerUp.fromType(PowerUpType.revealLetter),
      PowerUp.fromType(PowerUpType.freezeTimer),
      PowerUp.fromType(PowerUpType.removeWrong),
      PowerUp.fromType(PowerUpType.doubleScore),
      PowerUp.fromType(PowerUpType.extraLife),
      PowerUp.fromType(PowerUpType.skipWord),
    ]);
    _availablePowerUps.shuffle();
  }
  
  void _newWord() {
    _currentWord = WordDatabase.getRandomWord(
      category: _selectedCategory,
    );
    _currentWordMeaning = WordDatabase.getWordMeaning(_currentWord);
    _guessedLetters.clear();
    setState(() {});
  }
  
  bool get _isWordComplete => _currentWord.split('').every((c) => _guessedLetters.contains(c));
  bool get _isGameLost => _wrongCount >= _maxWrong;
  
  String get _displayWord {
    return _currentWord
        .split('')
        .map((c) => _guessedLetters.contains(c) ? c : '_')
        .join(' ');
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
      _wordsSolved = 0;
      _currentStreak = 0;
      _timeLeft = HangmanConfig.baseTimeSeconds;
      _wrongCount = 0;
      _playTimeSeconds = 0;
      _scoreMultiplier = 1;
      _isTimeFrozen = false;
      _activePowerUp = null;
      _guessedLetters.clear();
      _particles.clear();
    });
    
    _newWord();
    _startGameTimer();
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
  
  void _guessLetter(String letter) {
    if (_gameState != GameState.playing) {
      if (_gameState == GameState.idle) {
        _startCountdown();
      }
      return;
    }
    
    if (_guessedLetters.contains(letter)) {
      _showFeedback('Already guessed!', Colors.white54);
      return;
    }
    
    setState(() {
      _guessedLetters.add(letter);
      
      if (_currentWord.contains(letter)) {
        // Correct guess
        _handleCorrectGuess(letter);
      } else {
        // Wrong guess
        _handleWrongGuess(letter);
      }
    });
    
    HapticFeedback.lightImpact();
    
    // Check win/loss
    if (_isWordComplete) {
      _handleWordComplete();
    } else if (_isGameLost) {
      _gameOver();
    }
  }
  
  void _handleCorrectGuess(String letter) {
    final occurrences = _currentWord.split('').where((c) => c == letter).length;
    int pointsEarned = HangmanConfig.baseScorePerLetter * occurrences;
    
    // Apply combo multiplier
    _combo++;
    final comboMultiplier = 1 + (_combo * 0.1).clamp(0, HangmanConfig.comboMultiplierMax);
    pointsEarned = (pointsEarned * comboMultiplier).toInt();
    
    // Apply score multiplier from power-up
    pointsEarned *= _scoreMultiplier;
    
    _pointsEarned = pointsEarned;
    _score += pointsEarned;
    
    // Update combo display
    if (_combo > 1 && _combo % 3 == 0) {
      _comboController.forward(from: 0);
      _showFeedback('COMBO x${(comboMultiplier).toStringAsFixed(1)}! 🔥', const Color(0xFFFF4081));
      _confettiController.play();
      HapticFeedback.mediumImpact();
    }
    
    _addCorrectParticles(letter);
    _scoreController.forward(from: 0);
    _showFeedback('✓ $letter! +$pointsEarned', const Color(0xFF00FF88));
    
    // Reset combo timer
    _comboTimer?.cancel();
    _comboTimer = Timer(Duration(milliseconds: HangmanConfig.comboTimeWindowMs), () {
      if (mounted && _gameState == GameState.playing) {
        setState(() {
          _combo = 0;
        });
      }
    });
  }
  
  void _handleWrongGuess(String letter) {
    _wrongCount++;
    _combo = 0;
    _comboTimer?.cancel();
    _currentStreak = 0;
    
    _addWrongParticles();
    _shakeController.forward(from: 0);
    _hangmanController.forward(from: 0);
    _showFeedback('✗ $letter is wrong!', const Color(0xFFFF0044));
    HapticFeedback.heavyImpact();
  }
  
  void _handleWordComplete() {
    // Word completion bonus
    int wordBonus = HangmanConfig.wordCompleteBonus;
    final isPerfect = _wrongCount == 0;
    
    if (isPerfect) {
      wordBonus += HangmanConfig.perfectGameBonus;
      _showFeedback('PERFECT! +${HangmanConfig.perfectGameBonus} 🎯', const Color(0xFFFFD700));
      _victoryController.play();
    }
    
    wordBonus *= _scoreMultiplier;
    _score += wordBonus;
    _wordsSolved++;
    _currentStreak++;
    _scoreController.forward(from: 0);
    
    // Level progression
    final newLevel = 1 + (_wordsSolved ~/ 3);
    if (newLevel > _level) {
      _level = newLevel;
      _showFeedback('LEVEL $_level! ⬆️', const Color(0xFFFFD700));
      HapticFeedback.mediumImpact();
    }
    
    _saveHighScore();
    
    // Show word meaning
    _showFeedback('📖 ${_currentWordMeaning}', const Color(0xFF00D4FF));
    
    // Load next word
    _newWord();
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
      case PowerUpType.revealLetter:
        _revealRandomLetter();
        break;
      case PowerUpType.freezeTimer:
        _isTimeFrozen = true;
        break;
      case PowerUpType.removeWrong:
        _removeWrongOption();
        break;
      case PowerUpType.doubleScore:
        _scoreMultiplier = 2;
        break;
      case PowerUpType.extraLife:
        _maxWrong++;
        _showFeedback('+1 Life! ❤️', const Color(0xFFFF4081));
        break;
      case PowerUpType.skipWord:
        _newWord();
        _showFeedback('Word skipped!', const Color(0xFF9C27B0));
        break;
    }
    
    _availablePowerUps.remove(powerUp);
    _startPowerUpTimer(powerUp);
  }
  
  void _revealRandomLetter() {
    final unguessedLetters = _currentWord
        .split('')
        .where((c) => !_guessedLetters.contains(c))
        .toSet()
        .toList();
    
    if (unguessedLetters.isNotEmpty) {
      final letterToReveal = unguessedLetters[_random.nextInt(unguessedLetters.length)];
      _guessLetter(letterToReveal);
    }
  }
  
  void _removeWrongOption() {
    // Remove a wrong letter from keyboard (visual only, actual removal happens on tap)
    _showFeedback('Wrong letter protection active!', const Color(0xFFFF6B00));
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
  
  void _addCorrectParticles(String letter) {
    for (int i = 0; i < 15; i++) {
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
  
  final accuracy = _wordsSolved > 0 ? (_currentStreak / _wordsSolved) * 100 : 0.0;
  final solveTime = HangmanConfig.baseTimeSeconds - _timeLeft;
  final isPerfect = _wrongCount == 0 && _wordsSolved > 0;
  
  // CORRECTED: Match the parameter order in HangmanStatistics.updateStats
  // The method expects: (score, words, accuracy, streak, solveTime, playTime, perfect)
  _statistics.updateStats(
    _score,        // int score
    _wordsSolved,  // int words
    accuracy,      // double accuracy
    _currentStreak, // int streak
    solveTime,     // int solveTime
    _playTimeSeconds, // int playTime
    isPerfect,     // bool perfect
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
    final won = _wordsSolved >= HangmanConfig.targetWordsForWin;
    final accuracyBonus = (_wordsSolved * 10).toInt();
    final totalCoins = (won ? HangmanConfig.winCoins : 0) + (_score ~/ 20) + accuracyBonus;
    final totalXp = (won ? HangmanConfig.winXp : HangmanConfig.lossXp) + (_level * 3) + (_combo ~/ 2);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          won: won,
          coins: totalCoins.clamp(0, 120),
          xp: totalXp.clamp(0, 120),
          score: _score,
          gameName: 'Hangman',
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
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 900;
    final buttonSize = isDesktop 
        ? HangmanConfig.letterButtonSizeDesktop
        : (isTablet 
            ? HangmanConfig.letterButtonSizeTablet 
            : HangmanConfig.letterButtonSize);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _focusNode,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.space) {
              _pause();
            } else if (event.logicalKey.keyLabel.length == 1) {
              final letter = event.logicalKey.keyLabel.toUpperCase();
              if (RegExp(r'^[A-Z]$').hasMatch(letter)) {
                _guessLetter(letter);
              }
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
                          _buildHangmanFigure(),
                          const SizedBox(height: 24),
                          _buildWordDisplay(),
                          const SizedBox(height: 24),
                          _buildLetterKeyboard(buttonSize),
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
          
          // Lives Card
          _buildLivesCard(),
          
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
    final comboMultiplier = 1 + (_combo * 0.1).clamp(0, HangmanConfig.comboMultiplierMax);
    
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
  
  Widget _buildLivesCard() {
    final remaining = _maxWrong - _wrongCount;
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
          const Icon(Icons.favorite, color: Color(0xFFFF4081), size: 16),
          const SizedBox(width: 4),
          Text(
            '$_wrongCount/$_maxWrong',
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
  
  Widget _buildHangmanFigure() {
    final progress = _wrongCount / _maxWrong;
    
    return AnimatedBuilder(
      animation: _hangmanController,
      builder: (context, child) {
        return Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
          ),
          child: CustomPaint(
            painter: HangmanPainter(
              wrongCount: _wrongCount,
              maxWrong: _maxWrong,
              animationValue: _hangmanController.value,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
  
  Widget _buildWordDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00D4FF).withOpacity(0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
      ),
      child: Text(
        _displayWord,
        style: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF00D4FF),
          letterSpacing: 4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildLetterKeyboard(double buttonSize) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(26, (i) {
        final letter = String.fromCharCode(65 + i);
        final isGuessed = _guessedLetters.contains(letter);
        final isInWord = _currentWord.contains(letter);
        
        Color buttonColor;
        if (isGuessed) {
          buttonColor = isInWord ? const Color(0xFF00FF88) : const Color(0xFFFF0044);
        } else {
          buttonColor = const Color(0xFF00D4FF);
        }
        
        return GestureDetector(
          onTap: isGuessed ? null : () => _guessLetter(letter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGuessed
                    ? [buttonColor.withOpacity(0.2), buttonColor.withOpacity(0.1)]
                    : [buttonColor.withOpacity(0.3), buttonColor.withOpacity(0.15)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isGuessed ? buttonColor.withOpacity(0.5) : buttonColor,
                width: isGuessed ? 1 : 2,
              ),
              boxShadow: [
                if (!isGuessed)
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3),
                    blurRadius: 8,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                letter,
                style: GoogleFonts.orbitron(
                  fontSize: buttonSize * 0.4,
                  fontWeight: FontWeight.bold,
                  color: isGuessed ? buttonColor : Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
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
                  child: const Text('🪢', style: TextStyle(fontSize: 80)),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'HANGMAN',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700),
              shadows: const [Shadow(color: Color(0xFFFFD700), blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Guess the word before the hangman is complete!',
            style: TextStyle(fontSize: 14, color: Color(0xFF8AACCC)),
          ),
          const SizedBox(height: 32),
          _buildDifficultySelector(),
          const SizedBox(height: 16),
          _buildCategorySelector(),
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
        _buildDifficultyChip(DifficultyLevel.normal, 'NORMAL', const Color(0xFFFFD700)),
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
        _updateMaxWrong();
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
  
  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: WordCategory.values.map((category) {
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategory = _selectedCategory == category ? null : category;
            }),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected ? const Color(0xFFFFD700).withOpacity(0.2) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                ),
              ),
              child: Text(
                _getCategoryName(category),
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  String _getCategoryName(WordCategory category) {
    switch (category) {
      case WordCategory.animals: return '🐾 Animals';
      case WordCategory.technology: return '💻 Tech';
      case WordCategory.movies: return '🎬 Movies';
      case WordCategory.science: return '🔬 Science';
      case WordCategory.space: return '🚀 Space';
      case WordCategory.sports: return '⚽ Sports';
      case WordCategory.gaming: return '🎮 Gaming';
      case WordCategory.countries: return '🌍 Countries';
      case WordCategory.food: return '🍕 Food';
      case WordCategory.history: return '🏛️ History';
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
    final accuracy = _wordsSolved > 0 ? (_currentStreak / _wordsSolved * 100).toInt() : 0;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _wordsSolved >= HangmanConfig.targetWordsForWin ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_wordsSolved >= HangmanConfig.targetWordsForWin ? '🏆' : '💀', style: const TextStyle(fontSize: 48)),
            Text(
              _wordsSolved >= HangmanConfig.targetWordsForWin ? 'VICTORY!' : 'GAME OVER',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _wordsSolved >= HangmanConfig.targetWordsForWin ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
              ),
            ),
            const SizedBox(height: 16),
            Text('Score: $_score', style: const TextStyle(fontSize: 18, color: Colors.white)),
            Text('Best: $_highScore', style: const TextStyle(color: Color(0xFFFFD700))),
            Text('Words Solved: $_wordsSolved', style: const TextStyle(color: Color(0xFF00FF88))),
            Text('Accuracy: $accuracy%', style: const TextStyle(color: Color(0xFF00D4FF))),
            Text('Level: $_level', style: const TextStyle(color: Color(0xFFFF4081))),
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
    _pulseController.dispose();
    _shakeController.dispose();
    _comboController.dispose();
    _scoreController.dispose();
    _hangmanController.dispose();
    _confettiController.dispose();
    _victoryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// =============================================================================
// HANGMAN PAINTER
// =============================================================================

class HangmanPainter extends CustomPainter {
  final int wrongCount;
  final int maxWrong;
  final double animationValue;
  
  HangmanPainter({
    required this.wrongCount,
    required this.maxWrong,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final progress = wrongCount / maxWrong;
    final animatedProgress = progress * animationValue;
    
    // Gallows base
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.85),
      Offset(size.width * 0.8, size.height * 0.85),
      paint,
    );
    
    // Vertical pole
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.85),
      Offset(size.width * 0.3, size.height * 0.15),
      paint,
    );
    
    // Top bar
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.15),
      Offset(size.width * 0.6, size.height * 0.15),
      paint,
    );
    
    // Rope
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.15),
      Offset(size.width * 0.6, size.height * 0.25),
      paint,
    );
    
    // Head
    if (wrongCount >= 1) {
      canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.32),
        size.width * 0.06,
        paint,
      );
    }
    
    // Body
    if (wrongCount >= 2) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.38),
        Offset(size.width * 0.6, size.height * 0.58),
        paint,
      );
    }
    
    // Left arm
    if (wrongCount >= 3) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.45),
        Offset(size.width * 0.52, size.height * 0.52),
        paint,
      );
    }
    
    // Right arm
    if (wrongCount >= 4) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.45),
        Offset(size.width * 0.68, size.height * 0.52),
        paint,
      );
    }
    
    // Left leg
    if (wrongCount >= 5) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.58),
        Offset(size.width * 0.52, size.height * 0.68),
        paint,
      );
    }
    
    // Right leg
    if (wrongCount >= 6) {
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.58),
        Offset(size.width * 0.68, size.height * 0.68),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(HangmanPainter oldDelegate) => true;
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
// To use this advanced Hangman Game:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedHangmanGame(),
  ),
);

// With specific difficulty and category:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedHangmanGame(
      initialDifficulty: DifficultyLevel.hard,
      initialCategory: WordCategory.space,
    ),
  ),
);
*/