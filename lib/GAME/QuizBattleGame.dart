// =============================================================================
// FILE: quiz_battle_game_advanced.dart
// =============================================================================
// ADVANCED QUIZ BATTLE GAME - Multiplayer-Style Battle Quiz
// Features: Real-time battle feel, Power-ups, HP System, Combo Streaks
// Compatible with existing BEEDI College ecosystem
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// CONSTANTS & CONFIGURATION
// =============================================================================

class QuizBattleConfig {
  static const int baseTimePerQuestion = 15;
  static const int minTimePerQuestion = 8;
  static const int speedBonusPerSecond = 5;
  static const int baseScorePerQuestion = 100;
  static const int comboMultiplierMax = 5;
  static const double comboMultiplierValue = 0.25;
  
  // HP System
  static const int startingHp = 100;
  static const int damageWrongAnswer = 20;
  static const int damageTimeOut = 25;
  static const int healCorrectAnswer = 5;
  static const int criticalHitMultiplier = 2;
  
  // Power-ups
  static const double powerUpSpawnChance = 0.15;
  static const int powerUpDurationSeconds = 10;
  
  // Victory conditions
  static const int questionsToWinClassic = 10;
  static const int survivalTargetScore = 500;
  
  // Visual
  static const double answerButtonHeight = 60;
  static const double timerBarHeight = 8;
}

// =============================================================================
// ENUMS
// =============================================================================

enum BattleMode { classic, survival, timeAttack, ranked }
enum BattleState { idle, matchmaking, countdown, playing, answered, gameOver }
enum PowerUpType { doublePoints, freezeTimer, shield, fiftyFifty, skipQuestion }
enum QuestionDifficulty { easy, medium, hard, expert }
enum BattleResult { victory, defeat, draw }

// =============================================================================
// DATA MODELS
// =============================================================================

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final QuestionDifficulty difficulty;
  final String? imageUrl;
  final String? explanation;
  final int points;
  final String category;
  
  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.difficulty = QuestionDifficulty.medium,
    this.imageUrl,
    this.explanation,
    this.points = QuizBattleConfig.baseScorePerQuestion,
    this.category = 'General',
  });
  
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: map['q'] as String,
      options: List<String>.from(map['opts']),
      correctIndex: map['ans'] as int,
      difficulty: _parseDifficulty(map['difficulty']),
      imageUrl: map['imageUrl'],
      explanation: map['explanation'],
      points: map['points'] ?? QuizBattleConfig.baseScorePerQuestion,
      category: map['category'] ?? 'General',
    );
  }
  
  static QuestionDifficulty _parseDifficulty(dynamic value) {
    if (value == null) return QuestionDifficulty.medium;
    switch (value.toString().toLowerCase()) {
      case 'easy': return QuestionDifficulty.easy;
      case 'hard': return QuestionDifficulty.hard;
      case 'expert': return QuestionDifficulty.expert;
      default: return QuestionDifficulty.medium;
    }
  }
}

class PowerUp {
  final PowerUpType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  bool isActive = false;
  int remainingDuration = 0;
  
  PowerUp({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
  
  factory PowerUp.fromType(PowerUpType type) {
    switch (type) {
      case PowerUpType.doublePoints:
        return PowerUp(
          type: type,
          name: 'Double Points',
          description: 'Double your score for 10 seconds',
          icon: Icons.stars,
          color: const Color(0xFFFFD700),
        );
      case PowerUpType.freezeTimer:
        return PowerUp(
          type: type,
          name: 'Freeze Timer',
          description: 'Stop the timer for 10 seconds',
          icon: Icons.ac_unit,
          color: const Color(0xFF00D4FF),
        );
      case PowerUpType.shield:
        return PowerUp(
          type: type,
          name: 'Shield',
          description: 'Block one wrong answer',
          icon: Icons.shield,
          color: const Color(0xFF2196F3),
        );
      case PowerUpType.fiftyFifty:
        return PowerUp(
          type: type,
          name: '50/50',
          description: 'Remove two wrong options',
          icon: Icons.filter_1,
          color: const Color(0xFF9C27B0),
        );
      case PowerUpType.skipQuestion:
        return PowerUp(
          type: type,
          name: 'Skip Question',
          description: 'Skip current question without penalty',
          icon: Icons.skip_next,
          color: const Color(0xFFFF6B00),
        );
    }
  }
}

class PlayerStats {
  int score = 0;
  int hp = QuizBattleConfig.startingHp;
  int combo = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int fastestAnswerMs = 0;
  int totalTimeSpent = 0;
  List<PowerUp> availablePowerUps = [];
  
  void reset() {
    score = 0;
    hp = QuizBattleConfig.startingHp;
    combo = 0;
    correctAnswers = 0;
    wrongAnswers = 0;
    fastestAnswerMs = 0;
    totalTimeSpent = 0;
  }
  
  double get accuracy => correctAnswers + wrongAnswers > 0
      ? correctAnswers / (correctAnswers + wrongAnswers)
      : 0;
  
  int get comboMultiplier => 1 + (combo * QuizBattleConfig.comboMultiplierValue).toInt();
}

class AIOpponent {
  final String name;
  final String avatar;
  final int difficulty;
  int score = 0;
  int hp = QuizBattleConfig.startingHp;
  int correctAnswers = 0;
  
  AIOpponent({
    required this.name,
    required this.avatar,
    this.difficulty = 70, // 0-100, higher = smarter
  });
  
  bool answerCorrectly(Question question) {
    final random = Random();
    final baseChance = difficulty / 100.0;
    // Adjust based on question difficulty
    double chance = baseChance;
    switch (question.difficulty) {
      case QuestionDifficulty.easy:
        chance += 0.15;
        break;
      case QuestionDifficulty.medium:
        break;
      case QuestionDifficulty.hard:
        chance -= 0.15;
        break;
      case QuestionDifficulty.expert:
        chance -= 0.25;
        break;
    }
    return random.nextDouble() < chance.clamp(0.2, 0.95);
  }
}

// =============================================================================
// QUESTION DATABASE
// =============================================================================

class QuestionDatabase {
  static final List<Map<String, dynamic>> _baseQuestions = [
    {'q': 'Capital of India?', 'opts': ['Mumbai', 'New Delhi', 'Kolkata', 'Chennai'], 'ans': 1, 'difficulty': 'easy', 'category': 'Geography'},
    {'q': 'Who invented telephone?', 'opts': ['Edison', 'Graham Bell', 'Tesla', 'Marconi'], 'ans': 1, 'difficulty': 'medium', 'category': 'Science'},
    {'q': '2+2×2=?', 'opts': ['6', '8', '4', '5'], 'ans': 0, 'difficulty': 'easy', 'category': 'Math'},
    {'q': 'Red Planet?', 'opts': ['Venus', 'Jupiter', 'Mars', 'Saturn'], 'ans': 2, 'difficulty': 'easy', 'category': 'Science'},
    {'q': 'H2O is?', 'opts': ['Hydrogen', 'Oxygen', 'Water', 'Salt'], 'ans': 2, 'difficulty': 'easy', 'category': 'Science'},
    {'q': 'Romeo & Juliet author?', 'opts': ['Dickens', 'Shakespeare', 'Keats', 'Twain'], 'ans': 1, 'difficulty': 'medium', 'category': 'Literature'},
    {'q': 'Hexagon sides?', 'opts': ['5', '6', '7', '8'], 'ans': 1, 'difficulty': 'easy', 'category': 'Math'},
    {'q': 'Light speed (km/s approx)?', 'opts': ['100k', '200k', '300k', '400k'], 'ans': 2, 'difficulty': 'hard', 'category': 'Science'},
    {'q': 'Largest ocean?', 'opts': ['Atlantic', 'Indian', 'Arctic', 'Pacific'], 'ans': 3, 'difficulty': 'easy', 'category': 'Geography'},
    {'q': 'CPU stands for?', 'opts': ['Central Process Unit', 'Central Processing Unit', 'Computer Process Unit', 'Core Processing Unit'], 'ans': 1, 'difficulty': 'medium', 'category': 'Technology'},
    {'q': 'Who painted Mona Lisa?', 'opts': ['Van Gogh', 'Picasso', 'Da Vinci', 'Rembrandt'], 'ans': 2, 'difficulty': 'medium', 'category': 'Art'},
    {'q': 'Fastest animal on land?', 'opts': ['Lion', 'Cheetah', 'Leopard', 'Horse'], 'ans': 1, 'difficulty': 'easy', 'category': 'Animals'},
    {'q': 'Largest planet in solar system?', 'opts': ['Saturn', 'Mars', 'Jupiter', 'Neptune'], 'ans': 2, 'difficulty': 'medium', 'category': 'Science'},
    {'q': 'Who wrote "Harry Potter"?', 'opts': ['J.R.R. Tolkien', 'J.K. Rowling', 'George Martin', 'Stephen King'], 'ans': 1, 'difficulty': 'easy', 'category': 'Literature'},
    {'q': 'What is the square root of 144?', 'opts': ['10', '11', '12', '13'], 'ans': 2, 'difficulty': 'medium', 'category': 'Math'},
    {'q': 'Which element has chemical symbol "O"?', 'opts': ['Gold', 'Oxygen', 'Silver', 'Iron'], 'ans': 1, 'difficulty': 'easy', 'category': 'Science'},
    {'q': 'Who directed "Inception"?', 'opts': ['Steven Spielberg', 'James Cameron', 'Christopher Nolan', 'Quentin Tarantino'], 'ans': 2, 'difficulty': 'hard', 'category': 'Entertainment'},
    {'q': 'What is the smallest prime number?', 'opts': ['0', '1', '2', '3'], 'ans': 2, 'difficulty': 'easy', 'category': 'Math'},
    {'q': 'Which country gifted the Statue of Liberty to USA?', 'opts': ['England', 'Spain', 'France', 'Germany'], 'ans': 2, 'difficulty': 'medium', 'category': 'History'},
    {'q': 'What is the hardest natural substance?', 'opts': ['Iron', 'Diamond', 'Gold', 'Platinum'], 'ans': 1, 'difficulty': 'easy', 'category': 'Science'},
  ];
  
  static final Set<String> _usedQuestionIds = {};
  static final Random _random = Random();
  
  static List<Question> getQuestions({int count = 10, String? category}) {
    final available = _baseQuestions.where((q) {
      if (category != null && q['category'] != category) return false;
      return true;
    }).toList();
    
    available.shuffle(_random);
    final selected = available.take(count).toList();
    
    return selected.map((q) => Question.fromMap(q)).toList();
  }
  
  static Question getRandomQuestion({String? excludeId}) {
    final available = _baseQuestions.where((q) {
      if (excludeId != null && q['id'] == excludeId) return false;
      return true;
    }).toList();
    
    if (available.isEmpty) {
      _usedQuestionIds.clear();
      return Question.fromMap(_baseQuestions[_random.nextInt(_baseQuestions.length)]);
    }
    
    return Question.fromMap(available[_random.nextInt(available.length)]);
  }
  
  static void reset() {
    _usedQuestionIds.clear();
  }
}

// =============================================================================
// PARTICLE SYSTEM
// =============================================================================

class BattleParticle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;
  double lifetime;
  double maxLifetime;
  
  BattleParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.lifetime,
  }) : maxLifetime = lifetime, opacity = 1.0;
  
  bool update() {
    position += velocity;
    lifetime -= 1 / 60;
    opacity = lifetime / maxLifetime;
    return lifetime > 0;
  }
}

// =============================================================================
// MAIN QUIZ BATTLE GAME WIDGET
// =============================================================================

class AdvancedQuizBattleGame extends StatefulWidget {
  final BattleMode initialMode;
  final String? category;
  
  const AdvancedQuizBattleGame({
    super.key,
    this.initialMode = BattleMode.classic,
    this.category,
  });
  
  @override
  State<AdvancedQuizBattleGame> createState() => _AdvancedQuizBattleGameState();
}

class _AdvancedQuizBattleGameState extends State<AdvancedQuizBattleGame>
    with TickerProviderStateMixin {
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  late List<Question> _questions;
  int _currentQuestionIndex = 0;
  int _timeLeft = QuizBattleConfig.baseTimePerQuestion;
  int? _selectedOption;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  
  // Player Stats
  final PlayerStats _playerStats = PlayerStats();
  late AIOpponent _aiOpponent;
  
  // Battle State
  BattleState _battleState = BattleState.idle;
  BattleMode _currentMode = BattleMode.classic;
  BattleResult? _battleResult;
  
  // Power-ups
  final List<PowerUp> _availablePowerUps = [];
  PowerUp? _activePowerUp;
  Timer? _powerUpTimer;
  List<int> _fiftyFiftyHidden = [];
  
  // Timers
  Timer? _questionTimer;
  Timer? _countdownTimer;
  Timer? _aiThinkingTimer;
  
  // Animation Controllers
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late AnimationController _hpAnimationController;
  late AnimationController _scoreAnimationController;
  late ConfettiController _confettiController;
  late ConfettiController _victoryConfettiController;
  
  // Particles
  final List<BattleParticle> _particles = [];
  Timer? _particleTimer;
  
  // Visual Effects
  String? _feedbackMessage;
  Color? _feedbackColor;
  int _pointsEarned = 0;
  int _comboDisplay = 0;
  
  // Statistics
  int _totalQuestionsAnswered = 0;
  final List<int> _answerTimes = [];
  
  // Sound effects structure
  final _hapticFeedback = true;
  
  final Random _random = Random();
  
  // =========================================================================
  // INITIALIZATION
  // =========================================================================
  
  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _aiOpponent = AIOpponent(
      name: 'Quiz Master AI',
      avatar: '🤖',
      difficulty: 65,
    );
    _initControllers();
    _initPowerUps();
    _loadQuestions();
  }
  
  void _initControllers() {
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _hpAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _victoryConfettiController = ConfettiController(duration: const Duration(seconds: 4));
  }
  
  void _initPowerUps() {
    _availablePowerUps.addAll([
      PowerUp.fromType(PowerUpType.doublePoints),
      PowerUp.fromType(PowerUpType.freezeTimer),
      PowerUp.fromType(PowerUpType.shield),
      PowerUp.fromType(PowerUpType.fiftyFifty),
      PowerUp.fromType(PowerUpType.skipQuestion),
    ]);
    _availablePowerUps.shuffle();
  }
  
  void _loadQuestions() {
    _questions = QuestionDatabase.getQuestions(
      count: _currentMode == BattleMode.survival ? 20 : 10,
      category: widget.category,
    );
  }
  
  // =========================================================================
  // GAME START
  // =========================================================================
  
  void _startMatchmaking() {
    setState(() {
      _battleState = BattleState.matchmaking;
    });
    
    // Simulate matchmaking
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _startCountdown();
      }
    });
  }
  
  void _startCountdown() {
    setState(() {
      _battleState = BattleState.countdown;
    });
    
    int countdown = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() => countdown--);
        HapticFeedback.lightImpact();
      } else {
        timer.cancel();
        setState(() {
          _battleState = BattleState.playing;
        });
        _startCurrentQuestion();
      }
    });
  }
  
  void _startCurrentQuestion() {
    setState(() {
      _hasAnswered = false;
      _selectedOption = null;
      _isCorrect = false;
      _timeLeft = _getTimeForCurrentQuestion();
      _fiftyFiftyHidden.clear();
      _feedbackMessage = null;
    });
    
    _startTimer();
    
    // AI thinking
    _aiThinking();
  }
  
  int _getTimeForCurrentQuestion() {
    final question = _questions[_currentQuestionIndex];
    int baseTime = QuizBattleConfig.baseTimePerQuestion;
    
    switch (question.difficulty) {
      case QuestionDifficulty.easy:
        baseTime = 12;
        break;
      case QuestionDifficulty.medium:
        baseTime = 15;
        break;
      case QuestionDifficulty.hard:
        baseTime = 20;
        break;
      case QuestionDifficulty.expert:
        baseTime = 25;
        break;
    }
    
    return baseTime.clamp(QuizBattleConfig.minTimePerQuestion, 30);
  }
  
  void _startTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      if (_battleState == BattleState.playing && !_hasAnswered) {
        setState(() {
          _timeLeft--;
          if (_timeLeft <= 0) {
            timer.cancel();
            _handleTimeout();
          }
        });
      }
    });
  }
  
  // =========================================================================
  // AI SYSTEM
  // =========================================================================
  
  void _aiThinking() {
    _aiThinkingTimer?.cancel();
    final thinkingTime = Duration(milliseconds: 800 + _random.nextInt(1200));
    
    _aiThinkingTimer = Timer(thinkingTime, () {
      if (mounted && _battleState == BattleState.playing && !_hasAnswered) {
        _aiAnswer();
      }
    });
  }
  
  void _aiAnswer() {
    final question = _questions[_currentQuestionIndex];
    final isCorrect = _aiOpponent.answerCorrectly(question);
    
    if (isCorrect) {
      final pointsEarned = question.points;
      _aiOpponent.score += pointsEarned;
      _aiOpponent.correctAnswers++;
      
      _addParticles(
        position: Offset(0.8, 0.2),
        color: const Color(0xFFFF0044),
        count: 15,
      );
    } else {
      _aiOpponent.hp -= QuizBattleConfig.damageWrongAnswer;
      _aiOpponent.hp = _aiOpponent.hp.clamp(0, QuizBattleConfig.startingHp);
    }
    
    setState(() {});
    
    if (_aiOpponent.hp <= 0) {
      _endBattle(BattleResult.victory);
    }
  }
  
  // =========================================================================
  // ANSWER HANDLING
  // =========================================================================
  
  void _handleAnswer(int selectedIndex) {
    if (_hasAnswered || _battleState != BattleState.playing) return;
    
    final question = _questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == question.correctIndex;
    final answerTime = QuizBattleConfig.baseTimePerQuestion - _timeLeft;
    _answerTimes.add(answerTime);
    
    _questionTimer?.cancel();
    _aiThinkingTimer?.cancel();
    
    // Apply 50/50 filter
    if (_fiftyFiftyHidden.contains(selectedIndex)) {
      _showFeedback('❌ 50/50 filtered option selected!', Colors.red);
      _handleIncorrectAnswer(question, selectedIndex);
      return;
    }
    
    if (isCorrect) {
      _handleCorrectAnswer(question, answerTime, selectedIndex);
    } else {
      _handleIncorrectAnswer(question, selectedIndex);
    }
    
    setState(() {
      _hasAnswered = true;
      _selectedOption = selectedIndex;
      _isCorrect = isCorrect;
      _battleState = BattleState.answered;
    });
    
    // Add visual effects
    if (isCorrect) {
      _addCorrectAnswerEffects();
      HapticFeedback.mediumImpact();
    } else {
      _addWrongAnswerEffects();
      HapticFeedback.heavyImpact();
    }
    
    // Move to next question after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }
  
  void _handleCorrectAnswer(Question question, int answerTime, int selectedIndex) {
    // Calculate points with bonuses
    int points = question.points;
    
    // Speed bonus
    final speedBonus = (_timeLeft * QuizBattleConfig.speedBonusPerSecond);
    points += speedBonus;
    
    // Combo multiplier
    _playerStats.combo++;
    points *= _playerStats.comboMultiplier;
    
    // Double points power-up
    if (_activePowerUp?.type == PowerUpType.doublePoints) {
      points *= 2;
    }
    
    // Critical hit (random)
    final isCritical = _random.nextDouble() < 0.1;
    if (isCritical) {
      points *= QuizBattleConfig.criticalHitMultiplier;
      _showFeedback('💥 CRITICAL HIT! x${QuizBattleConfig.criticalHitMultiplier}', const Color(0xFFFFD700));
    }
    
    _pointsEarned = points;
    _comboDisplay = _playerStats.combo;
    
    // Update stats
    _playerStats.score += points;
    _playerStats.correctAnswers++;
    _playerStats.totalTimeSpent += answerTime;
    
    if (_playerStats.fastestAnswerMs == 0 || answerTime < _playerStats.fastestAnswerMs) {
      _playerStats.fastestAnswerMs = answerTime;
    }
    
    // Heal HP
    _playerStats.hp += QuizBattleConfig.healCorrectAnswer;
    _playerStats.hp = _playerStats.hp.clamp(0, QuizBattleConfig.startingHp);
    
    // Update UI
    _hpAnimationController.forward(from: 0);
    _scoreAnimationController.forward(from: 0);
    
    _showFeedback('✓ +$points XP! ${_playerStats.combo > 1 ? "Combo x${_playerStats.comboMultiplier}!" : ""}', Colors.green);
    
    // Check for win conditions
    _checkWinConditions();
  }
  
  void _handleIncorrectAnswer(Question question, int selectedIndex) {
    // Check shield
    if (_activePowerUp?.type == PowerUpType.shield) {
      _activePowerUp = null;
      _showFeedback('🛡️ Shield protected you!', const Color(0xFF2196F3));
      return;
    }
    
    // Reset combo
    _playerStats.combo = 0;
    _playerStats.wrongAnswers++;
    
    // Damage HP
    _playerStats.hp -= QuizBattleConfig.damageWrongAnswer;
    _playerStats.hp = _playerStats.hp.clamp(0, QuizBattleConfig.startingHp);
    
    _hpAnimationController.forward(from: 0);
    _showFeedback('✗ Wrong! -${QuizBattleConfig.damageWrongAnswer} HP', Colors.red);
    
    _shakeController.forward(from: 0);
    
    // Check for defeat
    if (_playerStats.hp <= 0) {
      _endBattle(BattleResult.defeat);
    }
  }
  
  void _handleTimeout() {
    if (_hasAnswered) return;
    
    _playerStats.combo = 0;
    _playerStats.hp -= QuizBattleConfig.damageTimeOut;
    _playerStats.hp = _playerStats.hp.clamp(0, QuizBattleConfig.startingHp);
    
    _showFeedback('⏰ Time\'s up! -${QuizBattleConfig.damageTimeOut} HP', Colors.orange);
    _shakeController.forward(from: 0);
    
    setState(() {
      _hasAnswered = true;
      _battleState = BattleState.answered;
    });
    
    if (_playerStats.hp <= 0) {
      _endBattle(BattleResult.defeat);
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _nextQuestion();
      });
    }
  }
  
  void _nextQuestion() {
    _currentQuestionIndex++;
    
    if (_currentQuestionIndex >= _questions.length) {
      // Check winner based on mode
      if (_playerStats.score > _aiOpponent.score) {
        _endBattle(BattleResult.victory);
      } else if (_playerStats.score < _aiOpponent.score) {
        _endBattle(BattleResult.defeat);
      } else {
        _endBattle(BattleResult.draw);
      }
      return;
    }
    
    setState(() {
      _battleState = BattleState.playing;
      _hasAnswered = false;
      _selectedOption = null;
      _fiftyFiftyHidden.clear();
      _timeLeft = _getTimeForCurrentQuestion();
      _feedbackMessage = null;
    });
    
    _startTimer();
    _aiThinking();
  }
  
  // =========================================================================
  // POWER-UPS
  // =========================================================================
  
  void _usePowerUp(PowerUp powerUp) {
    if (_hasAnswered || _battleState != BattleState.playing) return;
    
    setState(() {
      _activePowerUp = powerUp;
      powerUp.isActive = true;
      powerUp.remainingDuration = QuizBattleConfig.powerUpDurationSeconds;
    });
    
    switch (powerUp.type) {
      case PowerUpType.doublePoints:
        _showFeedback('💰 Double Points Activated!', powerUp.color);
        break;
      case PowerUpType.freezeTimer:
        _questionTimer?.cancel();
        _showFeedback('❄️ Timer Frozen!', powerUp.color);
        break;
      case PowerUpType.shield:
        _showFeedback('🛡️ Shield Activated!', powerUp.color);
        break;
      case PowerUpType.fiftyFifty:
        _applyFiftyFifty();
        _showFeedback('🎯 50/50 Activated!', powerUp.color);
        break;
      case PowerUpType.skipQuestion:
        _skipQuestion();
        _showFeedback('⏭️ Question Skipped!', powerUp.color);
        break;
    }
    
    _availablePowerUps.remove(powerUp);
    
    if (powerUp.type != PowerUpType.freezeTimer && powerUp.type != PowerUpType.skipQuestion) {
      _startPowerUpTimer(powerUp);
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
          powerUp.isActive = false;
          if (_activePowerUp == powerUp) {
            _activePowerUp = null;
            if (powerUp.type == PowerUpType.freezeTimer && _questionTimer == null) {
              _startTimer();
            }
          }
        }
      });
    });
  }
  
  void _applyFiftyFifty() {
    final question = _questions[_currentQuestionIndex];
    final correctIndex = question.correctIndex;
    final otherIndices = List.generate(question.options.length, (i) => i)
        .where((i) => i != correctIndex)
        .toList();
    otherIndices.shuffle();
    _fiftyFiftyHidden = otherIndices.take(2).toList();
    setState(() {});
  }
  
  void _skipQuestion() {
    _questionTimer?.cancel();
    _currentQuestionIndex++;
    
    if (_currentQuestionIndex >= _questions.length) {
      if (_playerStats.score > _aiOpponent.score) {
        _endBattle(BattleResult.victory);
      } else {
        _endBattle(BattleResult.defeat);
      }
    } else {
      _startCurrentQuestion();
    }
  }
  
  // =========================================================================
  // BATTLE END
  // =========================================================================
  
  void _checkWinConditions() {
    // Survival mode - check score target
    if (_currentMode == BattleMode.survival && _playerStats.score >= QuizBattleConfig.survivalTargetScore) {
      _endBattle(BattleResult.victory);
      return;
    }
    
    // Check if player reached max correct answers
    if (_currentMode == BattleMode.classic && _playerStats.correctAnswers >= QuizBattleConfig.questionsToWinClassic) {
      _endBattle(BattleResult.victory);
      return;
    }
  }
  
  void _endBattle(BattleResult result) {
    _questionTimer?.cancel();
    _aiThinkingTimer?.cancel();
    _powerUpTimer?.cancel();
    
    setState(() {
      _battleResult = result;
      _battleState = BattleState.gameOver;
    });
    
    if (result == BattleResult.victory) {
      _victoryConfettiController.play();
      HapticFeedback.heavyImpact();
    }
    
    // Save statistics
    _totalQuestionsAnswered = _playerStats.correctAnswers + _playerStats.wrongAnswers;
    
    // Show result screen after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _showResultScreen();
      }
    });
  }
  
  void _showResultScreen() {
    final won = _battleResult == BattleResult.victory;
    final baseCoins = won ? 50 : 10;
    final baseXp = won ? 100 : 20;
    
    // Add bonus based on performance
    final accuracyBonus = (_playerStats.accuracy * 20).toInt();
    final comboBonus = _playerStats.comboMax * 5;
    final totalCoins = baseCoins + accuracyBonus + comboBonus;
    final totalXp = baseXp + accuracyBonus + comboBonus;
    
    // Navigate to existing GameResultScreen (uncomment when integrated)
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => GameResultScreen(
    //       won: won,
    //       coins: totalCoins,
    //       xp: totalXp,
    //       score: _playerStats.score,
    //       gameName: 'Quiz Battle',
    //       onContinue: () => Navigator.pop(context),
    //     ),
    //   ),
    // );
    
    // For now, show dialog
    _showBattleSummaryDialog(won, totalCoins, totalXp);
  }
  
  void _showBattleSummaryDialog(bool won, int coins, int xp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Text(
              won ? '🏆 VICTORY!' : '💀 DEFEAT!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: won ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                color: won ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('Final Score', '${_playerStats.score}', const Color(0xFFFFD700)),
              const SizedBox(height: 8),
              _buildStatRow('Correct', '${_playerStats.correctAnswers}', const Color(0xFF00FF88)),
              _buildStatRow('Wrong', '${_playerStats.wrongAnswers}', const Color(0xFFFF0044)),
              _buildStatRow('Accuracy', '${(_playerStats.accuracy * 100).toInt()}%', const Color(0xFF00D4FF)),
              _buildStatRow('Max Combo', 'x${_playerStats.comboMax}', const Color(0xFFFF4081)),
              _buildStatRow('Fastest Answer', '${_playerStats.fastestAnswerMs}s', const Color(0xFF9C27B0)),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white24,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 24)),
                      Text('+$coins', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 24)),
                      Text('+$xp', style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('EXIT', style: TextStyle(color: Color(0xFFFF0044))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text('REMATCH', style: TextStyle(color: Color(0xFF00FF88))),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8AACCC), fontSize: 14)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
  
  void _restartGame() {
    _playerStats.reset();
    _aiOpponent.score = 0;
    _aiOpponent.hp = QuizBattleConfig.startingHp;
    _aiOpponent.correctAnswers = 0;
    _currentQuestionIndex = 0;
    _battleResult = null;
    _answerTimes.clear();
    _totalQuestionsAnswered = 0;
    _initPowerUps();
    _loadQuestions();
    _startMatchmaking();
    setState(() {});
  }
  
  // =========================================================================
  // VISUAL EFFECTS
  // =========================================================================
  
  void _addCorrectAnswerEffects() {
    _confettiController.play();
    _addParticles(
      position: Offset(0.5, 0.7),
      color: const Color(0xFF00FF88),
      count: 20,
    );
    _pulseController.forward(from: 0);
  }
  
  void _addWrongAnswerEffects() {
    _addParticles(
      position: Offset(0.5, 0.7),
      color: const Color(0xFFFF0044),
      count: 15,
    );
  }
  
  void _addParticles({required Offset position, required Color color, required int count}) {
    for (int i = 0; i < count; i++) {
      _particles.add(BattleParticle(
        position: Offset(position.dx + (_random.nextDouble() - 0.5) * 0.3,
            position.dy + (_random.nextDouble() - 0.5) * 0.2),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 0.02,
          (_random.nextDouble() - 0.5) * 0.02 - 0.01,
        ),
        size: 2 + _random.nextDouble() * 4,
        color: color,
        lifetime: 0.5 + _random.nextDouble() * 0.5,
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
  // BUILD METHODS
  // =========================================================================
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWide = screenSize.width > 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  const Color(0xFF0A1628),
                  const Color(0xFF050A14),
                  Colors.black,
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),
          
          // Main Game Content
          SafeArea(
            child: _buildBattleArena(isWide),
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
              colors: const [Color(0xFF00FF88), Color(0xFFFFD700), Color(0xFF00D4FF)],
              numberOfParticles: 30,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _victoryConfettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Color(0xFFFFD700), Color(0xFFFF4081), Color(0xFF00FF88), Color(0xFF9C27B0)],
              numberOfParticles: 50,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBattleArena(bool isWide) {
    if (_battleState == BattleState.idle) {
      return _buildStartScreen();
    }
    
    if (_battleState == BattleState.matchmaking) {
      return _buildMatchmakingScreen();
    }
    
    if (_battleState == BattleState.countdown) {
      return _buildCountdownScreen();
    }
    
    if (_battleState == BattleState.gameOver) {
      return _buildGameOverOverlay();
    }
    
    return isWide ? _buildWideLayout() : _buildMobileLayout();
  }
  
  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedTextKit(
            animatedTexts: [
              WavyAnimatedText(
                'QUIZ BATTLE',
                textStyle: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  shadows: [Shadow(color: Color(0xFFFFD700), blurRadius: 20)],
                ),
              ),
            ],
            isRepeatingAnimation: false,
            totalRepeatCount: 1,
          ),
          const SizedBox(height: 16),
          Text(
            'Test your knowledge in battle!',
            style: const TextStyle(color: Color(0xFF8AACCC), fontSize: 16),
          ),
          const SizedBox(height: 48),
          _buildModeSelector(),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _startMatchmaking,
            child: Container(
              width: 240,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF6B00)],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFFD700), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: const Center(
                child: Text(
                  'FIND BATTLE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
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
        _buildModeChip(BattleMode.classic, 'CLASSIC', const Color(0xFF00D4FF)),
        const SizedBox(width: 12),
        _buildModeChip(BattleMode.survival, 'SURVIVAL', const Color(0xFFFF4081)),
        const SizedBox(width: 12),
        _buildModeChip(BattleMode.timeAttack, 'TIME ATTACK', const Color(0xFFFFD700)),
      ],
    );
  }
  
  Widget _buildModeChip(BattleMode mode, String label, Color color) {
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
  
  Widget _buildMatchmakingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: const Color(0xFFFFD700),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'FINDING OPPONENT...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Searching for Quiz Master AI',
            style: TextStyle(color: Color(0xFF8AACCC)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCountdownScreen() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + _pulseController.value * 0.4,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF6B00)],
                ),
                boxShadow: [BoxShadow(color: Color(0xFFFFD700), blurRadius: 30)],
              ),
              child: const Center(
                child: Text(
                  '3',
                  style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMobileLayout() {
    final question = _questions[_currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with VS display
          _buildBattleHeader(),
          const SizedBox(height: 16),
          
          // Timer and Question Progress
          _buildTimerAndProgress(),
          const SizedBox(height: 20),
          
          // Question Card
          _buildQuestionCard(question),
          const SizedBox(height: 20),
          
          // Power-ups Row
          if (_availablePowerUps.isNotEmpty)
            _buildPowerUpsRow(),
          
          const Spacer(),
          
          // Answer Options
          _buildAnswerOptions(question),
          const SizedBox(height: 16),
          
          // Feedback Message
          if (_feedbackMessage != null)
            _buildFeedbackMessage(),
        ],
      ),
    );
  }
  
  Widget _buildWideLayout() {
    final question = _questions[_currentQuestionIndex];
    
    return Row(
      children: [
        // Left Panel - Battle Info
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildBattleHeader(),
                const SizedBox(height: 24),
                _buildTimerAndProgress(),
                const SizedBox(height: 24),
                _buildPowerUpsRow(),
                const Spacer(),
                _buildPlayerStatsCard(),
              ],
            ),
          ),
        ),
        
        // Right Panel - Question & Answers
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildQuestionCard(question),
                const SizedBox(height: 24),
                _buildAnswerOptions(question),
                if (_feedbackMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildFeedbackMessage(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBattleHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFD700).withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Player
          Expanded(
            child: Column(
              children: [
                const Text('👤', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Text(
                  'YOU',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8AACCC)),
                ),
                AnimatedBuilder(
                  animation: _scoreAnimationController,
                  builder: (context, child) {
                    return Text(
                      '${_playerStats.score}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFFD700).withOpacity(_scoreAnimationController.value),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                _buildHpBar(_playerStats.hp, QuizBattleConfig.startingHp, const Color(0xFF00FF88)),
              ],
            ),
          ),
          
          // VS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD700)),
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
              ),
            ),
          ),
          
          // AI Opponent
          Expanded(
            child: Column(
              children: [
                Text(_aiOpponent.avatar, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Text(
                  _aiOpponent.name,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8AACCC)),
                ),
                Text(
                  '${_aiOpponent.score}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF0044),
                  ),
                ),
                const SizedBox(height: 4),
                _buildHpBar(_aiOpponent.hp, QuizBattleConfig.startingHp, const Color(0xFFFF0044)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHpBar(int current, int max, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: current / max,
        minHeight: 6,
        backgroundColor: Colors.white24,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
  
  Widget _buildTimerAndProgress() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    final timerColor = _timeLeft > 5 ? const Color(0xFF00FF88) : const Color(0xFFFF0044);
    
    return Column(
      children: [
        // Timer circle
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: timerColor.withOpacity(0.1),
            border: Border.all(color: timerColor, width: 2),
          ),
          child: Center(
            child: Text(
              '$_timeLeft',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: timerColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF00D4FF)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Q${_currentQuestionIndex + 1}/${_questions.length}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF8AACCC)),
        ),
        if (_playerStats.combo > 1)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4081).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'COMBO x${_playerStats.comboMultiplier}',
                style: const TextStyle(fontSize: 10, color: Color(0xFFFF4081), fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildQuestionCard(Question question) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A1628),
            const Color(0xFF0F2040),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getDifficultyColor(question.difficulty).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              question.difficulty.toString().split('.').last.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: _getDifficultyColor(question.difficulty),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Color _getDifficultyColor(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return const Color(0xFF00FF88);
      case QuestionDifficulty.medium:
        return const Color(0xFFFFD700);
      case QuestionDifficulty.hard:
        return const Color(0xFFFF6B00);
      case QuestionDifficulty.expert:
        return const Color(0xFFFF0044);
    }
  }
  
  Widget _buildAnswerOptions(Question question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final isHidden = _fiftyFiftyHidden.contains(index);
        if (isHidden) return const SizedBox.shrink();
        
        final isSelected = _selectedOption == index;
        final isCorrect = _hasAnswered && index == question.correctIndex;
        final isWrong = _hasAnswered && isSelected && !isCorrect;
        
        Color borderColor;
        if (_hasAnswered) {
          if (isCorrect) borderColor = const Color(0xFF00FF88);
          else if (isWrong) borderColor = const Color(0xFFFF0044);
          else borderColor = Colors.white24;
        } else {
          borderColor = Colors.white24;
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: QuizBattleConfig.answerButtonHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  borderColor.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _hasAnswered ? null : () => _handleAnswer(index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: borderColor.withOpacity(0.2),
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: borderColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: _hasAnswered && isCorrect
                                ? const Color(0xFF00FF88)
                                : _hasAnswered && isWrong
                                    ? const Color(0xFFFF0044)
                                    : Colors.white,
                          ),
                        ),
                      ),
                      if (_hasAnswered && isCorrect)
                        const Icon(Icons.check_circle, color: Color(0xFF00FF88), size: 24),
                      if (_hasAnswered && isWrong)
                        const Icon(Icons.cancel, color: Color(0xFFFF0044), size: 24),
                    ],
                  ),
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
        itemCount: _availablePowerUps.length,
        itemBuilder: (context, index) {
          final powerUp = _availablePowerUps[index];
          return GestureDetector(
            onTap: () => _usePowerUp(powerUp),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [powerUp.color.withOpacity(0.2), Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: powerUp.color),
              ),
              child: Row(
                children: [
                  Icon(powerUp.icon, color: powerUp.color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    powerUp.name,
                    style: TextStyle(fontSize: 10, color: powerUp.color),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPlayerStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0A1628), const Color(0xFF0F2040)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STATISTICS', style: TextStyle(fontSize: 12, color: Color(0xFF8AACCC), letterSpacing: 2)),
          const SizedBox(height: 12),
          _buildStatItem('Accuracy', '${(_playerStats.accuracy * 100).toInt()}%', const Color(0xFF00D4FF)),
          _buildStatItem('Correct', '${_playerStats.correctAnswers}', const Color(0xFF00FF88)),
          _buildStatItem('Wrong', '${_playerStats.wrongAnswers}', const Color(0xFFFF0044)),
          _buildStatItem('Best Combo', 'x${_playerStats.comboMax}', const Color(0xFFFF4081)),
          _buildStatItem('Fastest', '${_playerStats.fastestAnswerMs}s', const Color(0xFFFFD700)),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8AACCC))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  Widget _buildFeedbackMessage() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _feedbackColor?.withOpacity(0.1) ?? Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _feedbackColor ?? Colors.transparent, width: 1),
      ),
      child: Text(
        _feedbackMessage ?? '',
        style: TextStyle(fontSize: 14, color: _feedbackColor, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildGameOverOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _battleResult == BattleResult.victory ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _battleResult == BattleResult.victory ? '🏆 VICTORY!' : '💀 DEFEAT!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _battleResult == BattleResult.victory ? const Color(0xFFFFD700) : const Color(0xFFFF0044),
              ),
            ),
            const SizedBox(height: 16),
            Text('Final Score: ${_playerStats.score}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            Text('${_playerStats.correctAnswers} / ${_totalQuestionsAnswered} Correct', style: const TextStyle(color: Color(0xFF8AACCC))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF0044)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text('EXIT', style: TextStyle(color: Color(0xFFFF0044))),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _restartGame,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF6B00)]),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text('REMATCH', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _questionTimer?.cancel();
    _countdownTimer?.cancel();
    _aiThinkingTimer?.cancel();
    _powerUpTimer?.cancel();
    _particleTimer?.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
    _hpAnimationController.dispose();
    _scoreAnimationController.dispose();
    _confettiController.dispose();
    _victoryConfettiController.dispose();
    super.dispose();
  }
}

// =============================================================================
// PARTICLE PAINTER
// =============================================================================

class _ParticlePainter extends CustomPainter {
  final List<BattleParticle> particles;
  
  _ParticlePainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        Offset(particle.position.dx * size.width, particle.position.dy * size.height),
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

// =============================================================================
// EXTENSIONS
// =============================================================================

extension on PlayerStats {
  int get comboMax {
    // Track max combo separately in state
    return 0;
  }
}

// =============================================================================
// USAGE EXAMPLE:
// =============================================================================
/*
// To use this advanced Quiz Battle Game:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedQuizBattleGame(),
  ),
);

// With specific mode:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedQuizBattleGame(
      initialMode: BattleMode.survival,
      category: 'Science',
    ),
  ),
);

// To integrate with your existing GameResultScreen, uncomment the navigation
// in _showResultScreen() method and adjust imports.
*/