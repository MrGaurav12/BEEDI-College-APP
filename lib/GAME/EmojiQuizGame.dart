// =============================================================================
// FILE: emoji_quiz_game_advanced.dart
// =============================================================================
// ADVANCED EMOJI QUIZ GAME - Premium Emoji Puzzle Experience
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

class EmojiQuizConfig {
  // Game Settings
  static const int baseTimeSeconds = 30;
  static const int baseScorePerQuestion = 100;
  static const int timeBonusPerSecond = 5;
  static const int comboBonusMultiplier = 10;
  
  // Difficulty Settings
  static const int easyQuestions = 8;
  static const int mediumQuestions = 12;
  static const int hardQuestions = 16;
  static const int expertQuestions = 20;
  
  // Combo System
  static const int comboTimeWindowMs = 3000;
  static const double maxComboMultiplier = 3.0;
  
  // Power-ups
  static const int powerUpCost = 50;
  static const int powerUpDuration = 10;
  
  // Rewards
  static const int winCoins = 40;
  static const int winXp = 65;
  static const int lossXp = 15;
  static const int targetScoreForWin = 400;
  
  // Visual
  static const double emojiSize = 120;
  static const double optionButtonHeight = 60;
}

// =============================================================================
// ENUMS
// =============================================================================

enum GameState { idle, countdown, playing, paused, gameOver }
enum DifficultyLevel { easy, medium, hard, expert }
enum QuizCategory { 
  movies, songs, countries, food, sports, technology, animals, gaming, brands, trends 
}
enum PowerUpType { revealLetter, removeOptions, freezeTimer, doubleScore, smartHint, skipQuestion }

// =============================================================================
// EMOJI PUZZLE DATABASE
// =============================================================================

class EmojiPuzzle {
  final String id;
  final String emoji;
  final String answer;
  final List<String> options;
  final QuizCategory category;
  final DifficultyLevel difficulty;
  final String explanation;
  
  EmojiPuzzle({
    required this.id,
    required this.emoji,
    required this.answer,
    required this.options,
    required this.category,
    required this.difficulty,
    this.explanation = '',
  });
  
  static List<EmojiPuzzle> getPuzzles({QuizCategory? category, DifficultyLevel? difficulty}) {
    List<EmojiPuzzle> allPuzzles = [
      // Food Category
      EmojiPuzzle(
        id: 'pizza', emoji: '🍕', answer: 'Pizza',
        options: ['Pizza', 'Burger', 'Pasta', 'Sandwich'],
        category: QuizCategory.food, difficulty: DifficultyLevel.easy,
        explanation: 'Pizza is an Italian dish consisting of a flat base of leavened wheat-based dough topped with tomatoes, cheese, and various other ingredients.'
      ),
      EmojiPuzzle(
        id: 'burger', emoji: '🍔', answer: 'Burger',
        options: ['Pizza', 'Burger', 'Hot Dog', 'Taco'],
        category: QuizCategory.food, difficulty: DifficultyLevel.easy,
        explanation: 'A hamburger is a food consisting of fillings placed inside a sliced bun.'
      ),
      EmojiPuzzle(
        id: 'sushi', emoji: '🍣', answer: 'Sushi',
        options: ['Sushi', 'Ramen', 'Tempura', 'Teriyaki'],
        category: QuizCategory.food, difficulty: DifficultyLevel.medium,
        explanation: 'Sushi is a Japanese dish of prepared vinegared rice, usually with sugar and salt.'
      ),
      
      // Animals Category
      EmojiPuzzle(
        id: 'lion', emoji: '🦁', answer: 'Lion',
        options: ['Tiger', 'Lion', 'Leopard', 'Cheetah'],
        category: QuizCategory.animals, difficulty: DifficultyLevel.easy,
        explanation: 'The lion is a large cat of the genus Panthera native to Africa and India.'
      ),
      EmojiPuzzle(
        id: 'eagle', emoji: '🦅', answer: 'Eagle',
        options: ['Hawk', 'Eagle', 'Falcon', 'Vulture'],
        category: QuizCategory.animals, difficulty: DifficultyLevel.easy,
        explanation: 'Eagles are large birds of prey with powerful hooked beaks and strong talons.'
      ),
      EmojiPuzzle(
        id: 'dolphin', emoji: '🐬', answer: 'Dolphin',
        options: ['Shark', 'Whale', 'Dolphin', 'Octopus'],
        category: QuizCategory.animals, difficulty: DifficultyLevel.medium,
        explanation: 'Dolphins are highly intelligent marine mammals known for their playful behavior.'
      ),
      
      // Technology Category
      EmojiPuzzle(
        id: 'rocket', emoji: '🚀', answer: 'Rocket',
        options: ['Airplane', 'Rocket', 'Satellite', 'UFO'],
        category: QuizCategory.technology, difficulty: DifficultyLevel.easy,
        explanation: 'A rocket is a vehicle that uses jet propulsion to accelerate without using atmospheric air.'
      ),
      EmojiPuzzle(
        id: 'laptop', emoji: '💻', answer: 'Laptop',
        options: ['Tablet', 'Phone', 'Laptop', 'Desktop'],
        category: QuizCategory.technology, difficulty: DifficultyLevel.easy,
        explanation: 'A laptop is a portable personal computer with a clamshell form factor.'
      ),
      EmojiPuzzle(
        id: 'robot', emoji: '🤖', answer: 'Robot',
        options: ['Android', 'Robot', 'Cyborg', 'AI'],
        category: QuizCategory.technology, difficulty: DifficultyLevel.medium,
        explanation: 'A robot is a machine designed to execute one or more tasks automatically.'
      ),
      
      // Movies Category
      EmojiPuzzle(
        id: 'clapper', emoji: '🎬', answer: 'Movie',
        options: ['Theater', 'Movie', 'Director', 'Camera'],
        category: QuizCategory.movies, difficulty: DifficultyLevel.easy,
        explanation: 'A clapperboard is used in filmmaking to help synchronize picture and sound.'
      ),
      EmojiPuzzle(
        id: 'popcorn', emoji: '🍿', answer: 'Popcorn',
        options: ['Candy', 'Popcorn', 'Nachos', 'Soda'],
        category: QuizCategory.movies, difficulty: DifficultyLevel.easy,
        explanation: 'Popcorn is a classic movie theater snack.'
      ),
      
      // Sports Category
      EmojiPuzzle(
        id: 'soccer', emoji: '⚽', answer: 'Soccer',
        options: ['Football', 'Soccer', 'Rugby', 'Tennis'],
        category: QuizCategory.sports, difficulty: DifficultyLevel.easy,
        explanation: 'Soccer is a team sport played with a spherical ball between two teams of 11 players.'
      ),
      EmojiPuzzle(
        id: 'basketball', emoji: '🏀', answer: 'Basketball',
        options: ['Baseball', 'Basketball', 'Volleyball', 'Handball'],
        category: QuizCategory.sports, difficulty: DifficultyLevel.easy,
        explanation: 'Basketball is a team sport in which two teams compete to shoot a ball through a hoop.'
      ),
      EmojiPuzzle(
        id: 'weightlifting', emoji: '🏋️', answer: 'Weightlifting',
        options: ['Running', 'Swimming', 'Weightlifting', 'Boxing'],
        category: QuizCategory.sports, difficulty: DifficultyLevel.medium,
        explanation: 'Weightlifting is a sport in which athletes compete in lifting a barbell loaded with weight plates.'
      ),
      
      // Music Category
      EmojiPuzzle(
        id: 'guitar', emoji: '🎸', answer: 'Guitar',
        options: ['Violin', 'Piano', 'Guitar', 'Drums'],
        category: QuizCategory.songs, difficulty: DifficultyLevel.easy,
        explanation: 'The guitar is a fretted musical instrument that typically has six strings.'
      ),
      EmojiPuzzle(
        id: 'piano', emoji: '🎹', answer: 'Piano',
        options: ['Organ', 'Piano', 'Keyboard', 'Synthesizer'],
        category: QuizCategory.songs, difficulty: DifficultyLevel.medium,
        explanation: 'The piano is a keyboard instrument that produces sound by striking strings with hammers.'
      ),
      
      // Gaming Category
      EmojiPuzzle(
        id: 'controller', emoji: '🎮', answer: 'Video Game',
        options: ['Console', 'Controller', 'Video Game', 'Arcade'],
        category: QuizCategory.gaming, difficulty: DifficultyLevel.easy,
        explanation: 'A video game controller is a device used to control video games.'
      ),
      EmojiPuzzle(
        id: 'dice', emoji: '🎲', answer: 'Dice',
        options: ['Cube', 'Dice', 'Gamble', 'Board Game'],
        category: QuizCategory.gaming, difficulty: DifficultyLevel.medium,
        explanation: 'Dice are small throwable objects with marked sides used in games of chance.'
      ),
      
      // Nature Category
      EmojiPuzzle(
        id: 'ocean', emoji: '🌊', answer: 'Ocean Wave',
        options: ['River', 'Lake', 'Ocean Wave', 'Waterfall'],
        category: QuizCategory.countries, difficulty: DifficultyLevel.medium,
        explanation: 'Ocean waves are caused by wind blowing across the surface of the water.'
      ),
      EmojiPuzzle(
        id: 'mountain', emoji: '⛰️', answer: 'Mountain',
        options: ['Hill', 'Volcano', 'Mountain', 'Cliff'],
        category: QuizCategory.countries, difficulty: DifficultyLevel.medium,
        explanation: 'A mountain is a large landform that rises prominently above its surroundings.'
      ),
      
      // Brands Category
      EmojiPuzzle(
        id: 'apple', emoji: '🍎', answer: 'Apple',
        options: ['Apple', 'Samsung', 'Google', 'Microsoft'],
        category: QuizCategory.brands, difficulty: DifficultyLevel.medium,
        explanation: 'Apple Inc. is an American technology company known for iPhone, Mac, and other devices.'
      ),
      EmojiPuzzle(
        id: 'target', emoji: '🎯', answer: 'Target',
        options: ['Archery', 'Darts', 'Target', 'Bullseye'],
        category: QuizCategory.brands, difficulty: DifficultyLevel.medium,
        explanation: 'Target is a retail corporation and a popular brand in the US.'
      ),
    ];
    
    var filtered = List<EmojiPuzzle>.from(allPuzzles);
    
    if (category != null) {
      filtered = filtered.where((p) => p.category == category).toList();
    }
    
    if (difficulty != null) {
      filtered = filtered.where((p) => p.difficulty == difficulty).toList();
    }
    
    return filtered;
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
    this.remainingDuration = EmojiQuizConfig.powerUpDuration,
    this.isActive = false,
    this.cost = EmojiQuizConfig.powerUpCost,
  });
  
  static PowerUp fromType(PowerUpType type) {
    switch (type) {
      case PowerUpType.revealLetter:
        return PowerUp(
          type: type,
          name: 'Reveal',
          emoji: '🔤',
          color: const Color(0xFF00D4FF),
        );
      case PowerUpType.removeOptions:
        return PowerUp(
          type: type,
          name: 'Remove 2',
          emoji: '❌',
          color: const Color(0xFFFF6B00),
        );
      case PowerUpType.freezeTimer:
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
      case PowerUpType.smartHint:
        return PowerUp(
          type: type,
          name: 'Smart Hint',
          emoji: '💡',
          color: const Color(0xFF9C27B0),
        );
      case PowerUpType.skipQuestion:
        return PowerUp(
          type: type,
          name: 'Skip',
          emoji: '⏭️',
          color: const Color(0xFFFF4081),
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

class EmojiQuizStatistics {
  int highestScore = 0;
  int fastestAnswerMs = 0;
  int totalPuzzlesSolved = 0;
  double bestAccuracy = 0;
  int longestCombo = 0;
  int totalPlayTime = 0;
  int perfectRounds = 0;
  int powerUpsUsed = 0;
  
  void updateStats(int score, int fastestTime, int puzzles, double accuracy, int combo, int playTime, bool perfect) {
    if (score > highestScore) highestScore = score;
    if (fastestTime > 0 && (fastestAnswerMs == 0 || fastestTime < fastestAnswerMs)) {
      fastestAnswerMs = fastestTime;
    }
    totalPuzzlesSolved += puzzles;
    if (accuracy > bestAccuracy) bestAccuracy = accuracy;
    if (combo > longestCombo) longestCombo = combo;
    totalPlayTime += playTime;
    if (perfect) perfectRounds++;
  }
}

// =============================================================================
// MAIN EMOJI QUIZ GAME WIDGET
// =============================================================================

class AdvancedEmojiQuizGame extends StatefulWidget {
  final DifficultyLevel initialDifficulty;
  final QuizCategory? initialCategory;
  
  const AdvancedEmojiQuizGame({
    super.key,
    this.initialDifficulty = DifficultyLevel.medium,
    this.initialCategory,
  });
  
  @override
  State<AdvancedEmojiQuizGame> createState() => _AdvancedEmojiQuizGameState();
}

class _AdvancedEmojiQuizGameState extends State<AdvancedEmojiQuizGame>
    with TickerProviderStateMixin {
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  late List<EmojiPuzzle> _questions;
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  
  int _score = 0;
  int _highScore = 0;
  int _combo = 0;
  int _level = 1;
  int _questionsAnswered = 0;
  int _correctAnswers = 0;
  int _timeLeft = EmojiQuizConfig.baseTimeSeconds;
  
  GameState _gameState = GameState.idle;
  DifficultyLevel _currentDifficulty = DifficultyLevel.medium;
  QuizCategory? _selectedCategory;
  
  // Power-ups
  PowerUp? _activePowerUp;
  Timer? _powerUpTimer;
  int _scoreMultiplier = 1;
  bool _isTimeFrozen = false;
  List<bool> _hiddenOptions = [];
  
  // Available power-ups
  final List<PowerUp> _availablePowerUps = [];
  
  // Timers
  Timer? _gameTimer;
  Timer? _comboTimer;
  Timer? _playTimeTimer;
  DateTime? _questionStartTime;
  
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _comboController;
  late AnimationController _scoreController;
  late AnimationController _emojiController;
  late ConfettiController _confettiController;
  late ConfettiController _victoryController;
  
  // Visual effects
  final List<Particle> _particles = [];
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _pointsEarned = 0;
  String? _hintMessage;
  
  // Statistics
  final EmojiQuizStatistics _statistics = EmojiQuizStatistics();
  int _playTimeSeconds = 0;
  List<int> _answerTimes = [];
  int _fastestAnswer = 0;
  
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
    _initControllers();
    _loadHighScore();
    _loadStatistics();
    _initPowerUps();
    _loadQuestions();
  }
  
  void _loadQuestions() {
    final allQuestions = EmojiPuzzle.getPuzzles(
      category: _selectedCategory,
      difficulty: _currentDifficulty,
    );
    
    // Shuffle and take based on difficulty
    allQuestions.shuffle(_random);
    int questionCount = EmojiQuizConfig.easyQuestions;
    switch (_currentDifficulty) {
      case DifficultyLevel.easy:
        questionCount = EmojiQuizConfig.easyQuestions;
        break;
      case DifficultyLevel.medium:
        questionCount = EmojiQuizConfig.mediumQuestions;
        break;
      case DifficultyLevel.hard:
        questionCount = EmojiQuizConfig.hardQuestions;
        break;
      case DifficultyLevel.expert:
        questionCount = EmojiQuizConfig.expertQuestions;
        break;
    }
    
    _questions = allQuestions.take(questionCount).toList();
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
    
    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _victoryController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('emoji_quiz_highscore') ?? 0;
    });
  }
  
  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('emoji_quiz_highscore', _score);
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
      PowerUp.fromType(PowerUpType.removeOptions),
      PowerUp.fromType(PowerUpType.freezeTimer),
      PowerUp.fromType(PowerUpType.doubleScore),
      PowerUp.fromType(PowerUpType.smartHint),
      PowerUp.fromType(PowerUpType.skipQuestion),
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
      _questionsAnswered = 0;
      _correctAnswers = 0;
      _timeLeft = EmojiQuizConfig.baseTimeSeconds;
      _playTimeSeconds = 0;
      _scoreMultiplier = 1;
      _isTimeFrozen = false;
      _activePowerUp = null;
      _answerTimes.clear();
      _fastestAnswer = 0;
      _hiddenOptions = List.filled(4, false);
    });
    
    _currentQuestionIndex = 0;
    _loadQuestions();
    _startGameTimer();
    _startPlayTimeTimer();
    _questionStartTime = DateTime.now();
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
  
  void _answerQuestion(int selectedIndex) {
    if (_gameState != GameState.playing) {
      if (_gameState == GameState.idle) {
        _startCountdown();
      }
      return;
    }
    
    if (_hasAnswered) return;
    if (_hiddenOptions[selectedIndex]) return;
    
    final question = _questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == question.options.indexOf(question.answer);
    final answerTime = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : 0;
    
    _answerTimes.add(answerTime);
    if (_fastestAnswer == 0 || answerTime < _fastestAnswer) {
      _fastestAnswer = answerTime;
    }
    
    setState(() {
      _selectedOption = selectedIndex;
      _hasAnswered = true;
      _isCorrect = isCorrect;
    });
    
    if (isCorrect) {
      _handleCorrectAnswer(answerTime);
    } else {
      _handleWrongAnswer();
    }
    
    // Move to next question after delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }
  
  void _handleCorrectAnswer(int answerTime) {
    final question = _questions[_currentQuestionIndex];
    
    // Calculate points
    int pointsEarned = EmojiQuizConfig.baseScorePerQuestion;
    
    // Time bonus
    final timeBonus = (_timeLeft * EmojiQuizConfig.timeBonusPerSecond);
    pointsEarned += timeBonus;
    
    // Combo multiplier
    _combo++;
    final comboMultiplier = 1 + (_combo * 0.1).clamp(0, EmojiQuizConfig.maxComboMultiplier);
    pointsEarned = (pointsEarned * comboMultiplier).toInt();
    
    // Apply score multiplier from power-up
    pointsEarned *= _scoreMultiplier;
    
    _pointsEarned = pointsEarned;
    _score += pointsEarned;
    _correctAnswers++;
    _questionsAnswered++;
    
    // Update combo display
    if (_combo > 1 && _combo % 3 == 0) {
      _comboController.forward(from: 0);
      _showFeedback('COMBO x${_combo}! 🔥', const Color(0xFFFF4081));
      _confettiController.play();
      HapticFeedback.mediumImpact();
    }
    
    // Show feedback with explanation
    _showFeedback('✓ +$pointsEarned!', const Color(0xFF00FF88));
    if (question.explanation.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showFeedback('💡 ${question.explanation}', const Color(0xFF00D4FF));
      });
    }
    
    _addCorrectParticles();
    _scoreController.forward(from: 0);
    _emojiController.forward(from: 0);
    HapticFeedback.lightImpact();
    
    // Reset combo timer
    _comboTimer?.cancel();
    _comboTimer = Timer(Duration(milliseconds: EmojiQuizConfig.comboTimeWindowMs), () {
      if (mounted && _gameState == GameState.playing) {
        setState(() {
          _combo = 0;
        });
      }
    });
    
    _saveHighScore();
    
    // Level progression
    final newLevel = 1 + (_score ~/ 500);
    if (newLevel > _level) {
      _level = newLevel;
      _showFeedback('LEVEL $_level! ⬆️', const Color(0xFFFFD700));
      HapticFeedback.mediumImpact();
    }
  }
  
  void _handleWrongAnswer() {
    _combo = 0;
    _comboTimer?.cancel();
    _questionsAnswered++;
    
    _showFeedback('✗ Wrong! The answer was ${_questions[_currentQuestionIndex].answer}', const Color(0xFFFF0044));
    _shakeController.forward(from: 0);
    _addWrongParticles();
    HapticFeedback.heavyImpact();
  }
  
  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _hasAnswered = false;
        _selectedOption = null;
        _isCorrect = false;
        _hiddenOptions = List.filled(4, false);
        _questionStartTime = DateTime.now();
      });
    } else {
      // Game completed
      _victoryController.play();
      _gameOver();
    }
  }
  
  // =========================================================================
  // POWER-UPS
  // =========================================================================
  
  void _usePowerUp(PowerUp powerUp) {
    if (_gameState != GameState.playing) return;
    if (_hasAnswered) {
      _showFeedback('Cannot use power-up now!', const Color(0xFFFF0044));
      return;
    }
    
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
        _revealLetter();
        break;
      case PowerUpType.removeOptions:
        _removeTwoOptions();
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
      case PowerUpType.skipQuestion:
        _skipQuestion();
        break;
    }
    
    _availablePowerUps.remove(powerUp);
    _startPowerUpTimer(powerUp);
  }
  
  void _revealLetter() {
    final answer = _questions[_currentQuestionIndex].answer;
    if (answer.length > 2) {
      final revealed = answer.substring(0, 2);
      _showFeedback('🔤 First 2 letters: $revealed', const Color(0xFF00D4FF));
    }
  }
  
  void _removeTwoOptions() {
    final question = _questions[_currentQuestionIndex];
    final correctIndex = question.options.indexOf(question.answer);
    final wrongIndices = <int>[];
    
    for (int i = 0; i < question.options.length; i++) {
      if (i != correctIndex && !_hiddenOptions[i]) {
        wrongIndices.add(i);
      }
    }
    
    wrongIndices.shuffle();
    final toRemove = wrongIndices.take(2);
    
    setState(() {
      for (final index in toRemove) {
        _hiddenOptions[index] = true;
      }
    });
    
    _showFeedback('2 options removed!', const Color(0xFFFF6B00));
  }
  
  void _showSmartHint() {
    final question = _questions[_currentQuestionIndex];
    final answer = question.answer;
    final category = _getCategoryName(question.category);
    _showFeedback('💡 Category: $category, ${answer.length} letters', const Color(0xFF9C27B0));
  }
  
  void _skipQuestion() {
    _nextQuestion();
    _showFeedback('Question skipped!', const Color(0xFFFF4081));
  }
  
  String _getCategoryName(QuizCategory category) {
    switch (category) {
      case QuizCategory.movies: return 'Movies';
      case QuizCategory.songs: return 'Music';
      case QuizCategory.countries: return 'Geography';
      case QuizCategory.food: return 'Food';
      case QuizCategory.sports: return 'Sports';
      case QuizCategory.technology: return 'Tech';
      case QuizCategory.animals: return 'Animals';
      case QuizCategory.gaming: return 'Gaming';
      case QuizCategory.brands: return 'Brands';
      case QuizCategory.trends: return 'Trends';
    }
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
        y: 0.5,
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
        y: 0.5,
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
    
    final accuracy = _questionsAnswered > 0 ? (_correctAnswers / _questionsAnswered) * 100 : 0.0;
    final isPerfect = _correctAnswers == _questions.length;
    
    _statistics.updateStats(
      _score,
      _fastestAnswer,
      _correctAnswers,
      accuracy,
      _combo,
      _playTimeSeconds,
      isPerfect,
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
    final won = _score >= EmojiQuizConfig.targetScoreForWin;
    final accuracyBonus = (_correctAnswers / _questions.length * 20).toInt();
    final totalCoins = (won ? EmojiQuizConfig.winCoins : 0) + (_score ~/ 20) + accuracyBonus;
    final totalXp = (won ? EmojiQuizConfig.winXp : EmojiQuizConfig.lossXp) + (_level * 3) + (_combo ~/ 3);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          won: won,
          coins: totalCoins.clamp(0, 100),
          xp: totalXp.clamp(0, 120),
          score: _score,
          gameName: 'Emoji Quiz',
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
                  const Color(0xFF1A0A2A),
                  const Color(0xFF2A1A4A),
                  const Color(0xFF3A2A5A),
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
                      child: isDesktop
                          ? _buildDesktopLayout()
                          : _buildMobileLayout(),
                    ),
                  ),
                ),
                if (_gameState == GameState.playing && _availablePowerUps.isNotEmpty)
                  _buildPowerUpsRow(),
                const SizedBox(height: 16),
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
          
          // Progress Card
          _buildStatCard(
            'Q${_currentQuestionIndex + 1}/${_questions.length}',
            '${(_correctAnswers / (_currentQuestionIndex + 1) * 100).toInt()}%',
            const Color(0xFF00D4FF),
          ),
          
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
    final comboMultiplier = 1 + (_combo * 0.1).clamp(0, EmojiQuizConfig.maxComboMultiplier);
    
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
  
  Widget _buildMobileLayout() {
    final question = _questions[_currentQuestionIndex];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getCategoryName(question.category),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Emoji Display
        AnimatedBuilder(
          animation: _emojiController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + _emojiController.value * 0.1,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [const Color(0xFFFFD700).withOpacity(0.2), Colors.transparent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  question.emoji,
                  style: const TextStyle(fontSize: EmojiQuizConfig.emojiSize),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),
        Text(
          'What is this emoji?',
          style: const TextStyle(fontSize: 16, color: Color(0xFF8AACCC)),
        ),
        
        const SizedBox(height: 30),
        
        // Answer Options
        ...List.generate(question.options.length, (index) {
          if (_hiddenOptions[index]) return const SizedBox.shrink();
          
          final isSelected = _selectedOption == index;
          final isCorrectAnswer = _hasAnswered && index == question.options.indexOf(question.answer);
          final isWrongAnswer = _hasAnswered && isSelected && !isCorrectAnswer;
          
          Color borderColor;
          if (_hasAnswered) {
            borderColor = isCorrectAnswer ? const Color(0xFF00FF88) : (isWrongAnswer ? const Color(0xFFFF0044) : Colors.white24);
          } else {
            borderColor = const Color(0xFFFFD700).withOpacity(0.5);
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: _hasAnswered ? null : () => _answerQuestion(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: EmojiQuizConfig.optionButtonHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      borderColor.withOpacity(0.2),
                      borderColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: borderColor.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    question.options[index],
                    style: TextStyle(
                      fontSize: 16,
                      color: isCorrectAnswer
                          ? const Color(0xFF00FF88)
                          : (isWrongAnswer
                              ? const Color(0xFFFF0044)
                              : Colors.white),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildDesktopLayout() {
    final question = _questions[_currentQuestionIndex];
    
    return Row(
      children: [
        // Left Panel - Emoji Display
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [const Color(0xFFFFD700).withOpacity(0.2), Colors.transparent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  question.emoji,
                  style: const TextStyle(fontSize: 160),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getCategoryName(question.category),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Right Panel - Options
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'What is this emoji?',
                style: TextStyle(fontSize: 18, color: Color(0xFF8AACCC)),
              ),
              const SizedBox(height: 30),
              ...List.generate(question.options.length, (index) {
                if (_hiddenOptions[index]) return const SizedBox.shrink();
                
                final isSelected = _selectedOption == index;
                final isCorrectAnswer = _hasAnswered && index == question.options.indexOf(question.answer);
                final isWrongAnswer = _hasAnswered && isSelected && !isCorrectAnswer;
                
                Color borderColor;
                if (_hasAnswered) {
                  borderColor = isCorrectAnswer ? const Color(0xFF00FF88) : (isWrongAnswer ? const Color(0xFFFF0044) : Colors.white24);
                } else {
                  borderColor = const Color(0xFFFFD700).withOpacity(0.5);
                }
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: _hasAnswered ? null : () => _answerQuestion(index),
                    child: Container(
                      width: 400,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            borderColor.withOpacity(0.2),
                            borderColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: borderColor.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          question.options[index],
                          style: TextStyle(
                            fontSize: 18,
                            color: isCorrectAnswer
                                ? const Color(0xFF00FF88)
                                : (isWrongAnswer
                                    ? const Color(0xFFFF0044)
                                    : Colors.white),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
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
                  child: const Text('🤔', style: TextStyle(fontSize: 80)),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'EMOJI QUIZ',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700),
              shadows: const [Shadow(color: Color(0xFFFFD700), blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Guess the meaning of each emoji!',
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
                'START QUIZ',
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
        _loadQuestions();
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
        children: [
          _buildCategoryChip(null, 'ALL', const Color(0xFFFFD700)),
          const SizedBox(width: 8),
          _buildCategoryChip(QuizCategory.movies, '🎬', const Color(0xFF00D4FF)),
          const SizedBox(width: 8),
          _buildCategoryChip(QuizCategory.songs, '🎵', const Color(0xFFFF4081)),
          const SizedBox(width: 8),
          _buildCategoryChip(QuizCategory.food, '🍕', const Color(0xFFFF6B00)),
          const SizedBox(width: 8),
          _buildCategoryChip(QuizCategory.animals, '🐾', const Color(0xFF00FF88)),
          const SizedBox(width: 8),
          _buildCategoryChip(QuizCategory.technology, '💻', const Color(0xFF9C27B0)),
          const SizedBox(width: 8),
          _buildCategoryChip(QuizCategory.sports, '⚽', const Color(0xFF2196F3)),
          const SizedBox(width: 8),
          _buildCategoryChip(QuizCategory.gaming, '🎮', const Color(0xFFFF0044)),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChip(QuizCategory? category, String label, Color color) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedCategory = isSelected ? null : category;
        _loadQuestions();
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
            fontSize: label.length > 3 ? 11 : 14,
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
    final accuracy = _questionsAnswered > 0 ? (_correctAnswers / _questionsAnswered * 100).toInt() : 0;
    final avgTime = _answerTimes.isNotEmpty ? _answerTimes.reduce((a, b) => a + b) ~/ _answerTimes.length : 0;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _score >= EmojiQuizConfig.targetScoreForWin ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_score >= EmojiQuizConfig.targetScoreForWin ? '🏆' : '💀', style: const TextStyle(fontSize: 48)),
            Text(
              _score >= EmojiQuizConfig.targetScoreForWin ? 'VICTORY!' : 'GAME OVER',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _score >= EmojiQuizConfig.targetScoreForWin ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
              ),
            ),
            const SizedBox(height: 16),
            Text('Score: $_score', style: const TextStyle(fontSize: 18, color: Colors.white)),
            Text('Best: $_highScore', style: const TextStyle(color: Color(0xFFFFD700))),
            Text('Correct: $_correctAnswers/$_questionsAnswered', style: const TextStyle(color: Color(0xFF00FF88))),
            Text('Accuracy: $accuracy%', style: const TextStyle(color: Color(0xFF00D4FF))),
            Text('Max Combo: $_combo', style: const TextStyle(color: Color(0xFFFF4081))),
            Text('Avg Time: ${avgTime}ms', style: const TextStyle(color: Color(0xFF9C27B0))),
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
    _emojiController.dispose();
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
// To use this advanced Emoji Quiz Game:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedEmojiQuizGame(),
  ),
);

// With specific difficulty and category:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedEmojiQuizGame(
      initialDifficulty: DifficultyLevel.hard,
      initialCategory: QuizCategory.movies,
    ),
  ),
);
*/