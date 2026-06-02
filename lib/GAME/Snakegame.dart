// =============================================================================
// FILE: snake_game_advanced.dart
// =============================================================================
// ADVANCED SNAKE GAME - Arcade Quality | Neon Cyberpunk Theme
// Features: Smooth controls, Power-ups, Level progression, Animations
// Compatible with existing BEEDI College ecosystem
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';

// Import existing project dependencies
// Adjust imports based on your project structure
// import 'package:beedi_college/GAME/beedi_game_screen.dart';

// =============================================================================
// CONSTANTS & CONFIGURATION
// =============================================================================

class SnakeGameConfig {
  static const int gridCols = 20;
  static const int gridRows = 20;
  static const int baseSpeedMs = 180;
  static const int minSpeedMs = 60;
  static const int speedDecreasePerLevel = 8;
  static const int targetScoreForWin = 50;
  static const int baseWinCoins = 70;
  static const int baseWinXp = 100;
  
  // Power-up durations (seconds)
  static const int powerUpDurationSpeed = 8;
  static const int powerUpDurationShield = 12;
  static const int powerUpDurationMagnet = 6;
  static const int powerUpDurationDoublePoints = 10;
  
  // Spawn chances
  static const double powerUpSpawnChance = 0.12;
  static const double bonusFoodSpawnChance = 0.08;
  
  // Visual
  static const double gridLineOpacity = 0.08;
  static const double snakeGlowIntensity = 0.4;
  static const double foodGlowIntensity = 0.5;
  static const double cellBorderRadius = 6.0;
}

// =============================================================================
// ENUMS
// =============================================================================

enum GameMode { classic, survival, timeAttack, obstacle }
enum GameState { idle, countdown, playing, paused, gameOver }
enum PowerUpType { speed, shield, magnet, doublePoints }
enum FoodType { normal, bonus, superBonus }
enum SnakeSkin { neonGreen, cyberBlue, magmaRed, goldPhoenix, rainbow }

// =============================================================================
// DATA MODELS
// =============================================================================

class PowerUp {
  final PowerUpType type;
  Offset position;
  final DateTime spawnedAt;
  int remainingDuration;
  bool isActive = false;
  
  PowerUp({
    required this.type,
    required this.position,
    required this.spawnedAt,
    this.remainingDuration = 0,
  });
  
  int get durationSeconds {
    switch (type) {
      case PowerUpType.speed:
        return SnakeGameConfig.powerUpDurationSpeed;
      case PowerUpType.shield:
        return SnakeGameConfig.powerUpDurationShield;
      case PowerUpType.magnet:
        return SnakeGameConfig.powerUpDurationMagnet;
      case PowerUpType.doublePoints:
        return SnakeGameConfig.powerUpDurationDoublePoints;
    }
  }
  
  IconData get icon {
    switch (type) {
      case PowerUpType.speed:
        return Icons.speed;
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.magnet:
        return Icons.bolt;
      case PowerUpType.doublePoints:
        return Icons.stars;
    }
  }
  
  Color get color {
    switch (type) {
      case PowerUpType.speed:
        return const Color(0xFF00E5FF);
      case PowerUpType.shield:
        return const Color(0xFF2196F3);
      case PowerUpType.magnet:
        return const Color(0xFFFFD700);
      case PowerUpType.doublePoints:
        return const Color(0xFFFF4081);
    }
  }
}

class FoodItem {
  final FoodType type;
  final Offset position;
  final int points;
  final Color color;
  
  FoodItem({
    required this.type,
    required this.position,
    this.points = 10,
    this.color = const Color(0xFFFFD700),
  });
  
  factory FoodItem.normal(Offset position) {
    return FoodItem(
      type: FoodType.normal,
      position: position,
      points: 10,
      color: const Color(0xFFFFD700),
    );
  }
  
  factory FoodItem.bonus(Offset position) {
    return FoodItem(
      type: FoodType.bonus,
      position: position,
      points: 30,
      color: const Color(0xFF00FF88),
    );
  }
  
  factory FoodItem.superBonus(Offset position) {
    return FoodItem(
      type: FoodType.superBonus,
      position: position,
      points: 100,
      color: const Color(0xFFFF4081),
    );
  }
}

class SnakeStatistics {
  int highestScore = 0;
  int longestSnake = 0;
  int totalFoodEaten = 0;
  int totalGamesPlayed = 0;
  int totalTimeSurvived = 0;
  int comboMax = 0;
  
  SnakeStatistics();
  
  factory SnakeStatistics.fromMap(Map<String, dynamic> map) {
    final stats = SnakeStatistics();
    stats.highestScore = map['highestScore'] ?? 0;
    stats.longestSnake = map['longestSnake'] ?? 0;
    stats.totalFoodEaten = map['totalFoodEaten'] ?? 0;
    stats.totalGamesPlayed = map['totalGamesPlayed'] ?? 0;
    stats.totalTimeSurvived = map['totalTimeSurvived'] ?? 0;
    stats.comboMax = map['comboMax'] ?? 0;
    return stats;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'highestScore': highestScore,
      'longestSnake': longestSnake,
      'totalFoodEaten': totalFoodEaten,
      'totalGamesPlayed': totalGamesPlayed,
      'totalTimeSurvived': totalTimeSurvived,
      'comboMax': comboMax,
    };
  }
}

// =============================================================================
// PARTICLE SYSTEM
// =============================================================================

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;
  double lifetime;
  double maxLifetime;
  
  Particle({
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
// MAIN SNAKE GAME WIDGET
// =============================================================================

class AdvancedSnakeGame extends StatefulWidget {
  final GameMode initialMode;
  
  const AdvancedSnakeGame({super.key, this.initialMode = GameMode.classic});
  
  @override
  State<AdvancedSnakeGame> createState() => _AdvancedSnakeGameState();
}

class _AdvancedSnakeGameState extends State<AdvancedSnakeGame>
    with TickerProviderStateMixin {
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  late List<Offset> _snake;
  Offset _direction = const Offset(1, 0);
  Offset _nextDirection = const Offset(1, 0);
  late FoodItem _currentFood;
  final List<PowerUp> _activePowerUps = [];
  final List<PowerUp> _collectedPowerUps = [];
  final List<Particle> _particles = [];
  
  GameState _gameState = GameState.idle;
  GameMode _currentMode = GameMode.classic;
  int _score = 0;
  int _combo = 0;
  int _level = 1;
  int _foodEaten = 0;
  int _timeRemaining = 60;
  int _highScore = 0;
  double _currentSpeed = SnakeGameConfig.baseSpeedMs.toDouble();
  
  Timer? _gameLoopTimer;
  Timer? _countdownTimer;
  Timer? _powerUpTimer;
  Timer? _particleTimer;
  Timer? _timeAttackTimer;
  
  final Random _random = Random();
  late ConfettiController _confettiController;
  late AnimationController _foodAnimationController;
  late AnimationController _shakeController;
  
  bool _hasShield = false;
  bool _hasDoublePoints = false;
  bool _hasMagnet = false;
  int _speedBoostRemaining = 0;
  
  // Snake skin selection
  SnakeSkin _currentSkin = SnakeSkin.neonGreen;
  
  // Keyboard controls
  final FocusNode _focusNode = FocusNode();
  
  // Statistics
  SnakeStatistics _statistics = SnakeStatistics();
  
  // =========================================================================
  // INITIALIZATION
  // =========================================================================
  
  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _initControllers();
    _loadStatistics();
    _loadHighScore();
  }
  
  void _initControllers() {
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _foodAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }
  
  Future<void> _loadStatistics() async {
    // Load from SharedPreferences or Firebase
    // For now, use local storage simulation
    setState(() {});
  }
  
  Future<void> _loadHighScore() async {
    // Load from SharedPreferences
    setState(() {});
  }
  
  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      setState(() => _highScore = _score);
      // Save to SharedPreferences
    }
  }
  
  // =========================================================================
  // GAME INITIALIZATION
  // =========================================================================
  
  void _initGame() {
    setState(() {
      _snake = [const Offset(10, 10)];
      _direction = const Offset(1, 0);
      _nextDirection = const Offset(1, 0);
      _score = 0;
      _combo = 0;
      _level = 1;
      _foodEaten = 0;
      _hasShield = false;
      _hasDoublePoints = false;
      _hasMagnet = false;
      _speedBoostRemaining = 0;
      _activePowerUps.clear();
      _collectedPowerUps.clear();
      _particles.clear();
      _currentSpeed = SnakeGameConfig.baseSpeedMs.toDouble();
      
      if (_currentMode == GameMode.timeAttack) {
        _timeRemaining = 60;
      }
      
      _generateFood();
    });
  }
  
  void _startCountdown() {
    setState(() => _gameState = GameState.countdown);
    int countdown = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() => countdown--);
      } else {
        timer.cancel();
        setState(() => _gameState = GameState.playing);
        _startGameLoop();
        if (_currentMode == GameMode.timeAttack) {
          _startTimeAttackTimer();
        }
      }
    });
  }
  
  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(
      Duration(milliseconds: _currentSpeed.toInt()),
      (_) => _gameStep(),
    );
  }
  
  void _startTimeAttackTimer() {
    _timeAttackTimer?.cancel();
    _timeAttackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          timer.cancel();
          _gameOver();
        }
      });
    });
  }
  
  void _startPowerUpTimer() {
    _powerUpTimer?.cancel();
    _powerUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _activePowerUps.removeWhere((p) {
          p.remainingDuration--;
          if (p.remainingDuration <= 0) {
            _deactivatePowerUp(p.type);
            return true;
          }
          return false;
        });
      });
    });
  }
  
  void _deactivatePowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.speed:
        _speedBoostRemaining = 0;
        _currentSpeed = SnakeGameConfig.baseSpeedMs.toDouble() - (_level - 1) * SnakeGameConfig.speedDecreasePerLevel;
        _currentSpeed = _currentSpeed.clamp(SnakeGameConfig.minSpeedMs.toDouble(), 300);
        _restartGameLoop();
        break;
      case PowerUpType.shield:
        _hasShield = false;
        break;
      case PowerUpType.doublePoints:
        _hasDoublePoints = false;
        break;
      case PowerUpType.magnet:
        _hasMagnet = false;
        break;
    }
  }
  
  void _restartGameLoop() {
    _gameLoopTimer?.cancel();
    _startGameLoop();
  }
  
  // =========================================================================
  // GAME LOGIC
  // =========================================================================
  
  void _gameStep() {
    if (_gameState != GameState.playing) return;
    
    setState(() {
      _direction = _nextDirection;
      final head = _snake.first;
      final newHead = Offset(
        (head.dx + _direction.dx) % SnakeGameConfig.gridCols,
        (head.dy + _direction.dy) % SnakeGameConfig.gridRows,
      );
      
      // Check self collision
      if (_snake.contains(newHead)) {
        if (_hasShield) {
          _hasShield = false;
          _addShieldBreakEffect();
        } else {
          _gameOver();
          return;
        }
      }
      
      _snake = [newHead, ..._snake];
      
      // Check food collision
      if (newHead == _currentFood.position) {
        _eatFood();
      } else {
        _snake.removeLast();
      }
      
      // Check power-up collision
      for (int i = 0; i < _activePowerUps.length; i++) {
        final powerUp = _activePowerUps[i];
        if (newHead == powerUp.position) {
          _collectPowerUp(powerUp);
          _activePowerUps.removeAt(i);
          break;
        }
      }
      
      // Magnet effect - attract nearby power-ups
      if (_hasMagnet) {
        _attractPowerUps(newHead);
      }
      
      // Update particles
      _particles.removeWhere((p) => !p.update());
    });
  }
  
  void _eatFood() {
    int points = _currentFood.points;
    
    if (_hasDoublePoints) {
      points *= 2;
    }
    
    _score += points;
    _foodEaten++;
    _combo++;
    
    // Update statistics
    if (_score > _statistics.highestScore) {
      _statistics.highestScore = _score;
    }
    if (_snake.length > _statistics.longestSnake) {
      _statistics.longestSnake = _snake.length;
    }
    if (_combo > _statistics.comboMax) {
      _statistics.comboMax = _combo;
    }
    _statistics.totalFoodEaten++;
    
    // Level progression
    if (_foodEaten % 5 == 0) {
      _level++;
      _currentSpeed = (SnakeGameConfig.baseSpeedMs - (_level - 1) * SnakeGameConfig.speedDecreasePerLevel)
          .toDouble()
          .clamp(SnakeGameConfig.minSpeedMs.toDouble(), 300);
      _restartGameLoop();
    }
    
    // Add eating effect particles
    _addFoodEffectParticles(_currentFood.position);
    
    // Play food animation
    _foodAnimationController.forward(from: 0);
    
    // Generate new food
    _generateFood();
    
    // Spawn power-up
    if (_random.nextDouble() < SnakeGameConfig.powerUpSpawnChance) {
      _spawnPowerUp();
    }
    
    // Haptic feedback (if available)
    HapticFeedback.lightImpact();
  }
  
  void _generateFood() {
    Set<Offset> occupied = {..._snake};
    for (final p in _activePowerUps) {
      occupied.add(p.position);
    }
    
    List<Offset> available = [];
    for (int i = 0; i < SnakeGameConfig.gridCols; i++) {
      for (int j = 0; j < SnakeGameConfig.gridRows; j++) {
        final pos = Offset(i.toDouble(), j.toDouble());
        if (!occupied.contains(pos)) {
          available.add(pos);
        }
      }
    }
    
    if (available.isEmpty) {
      _gameWin();
      return;
    }
    
    final randomPos = available[_random.nextInt(available.length)];
    
    // Determine food type based on combo
    FoodType type;
    if (_combo > 10 && _random.nextDouble() < 0.3) {
      type = FoodType.superBonus;
    } else if (_combo > 5 && _random.nextDouble() < 0.2) {
      type = FoodType.bonus;
    } else {
      type = FoodType.normal;
    }
    
    switch (type) {
      case FoodType.normal:
        _currentFood = FoodItem.normal(randomPos);
        break;
      case FoodType.bonus:
        _currentFood = FoodItem.bonus(randomPos);
        break;
      case FoodType.superBonus:
        _currentFood = FoodItem.superBonus(randomPos);
        break;
    }
  }
  
  void _spawnPowerUp() {
    Set<Offset> occupied = {..._snake};
    occupied.add(_currentFood.position);
    for (final p in _activePowerUps) {
      occupied.add(p.position);
    }
    
    List<Offset> available = [];
    for (int i = 0; i < SnakeGameConfig.gridCols; i++) {
      for (int j = 0; j < SnakeGameConfig.gridRows; j++) {
        final pos = Offset(i.toDouble(), j.toDouble());
        if (!occupied.contains(pos)) {
          available.add(pos);
        }
      }
    }
    
    if (available.isEmpty) return;
    
    final types = PowerUpType.values;
    final type = types[_random.nextInt(types.length)];
    final powerUp = PowerUp(
      type: type,
      position: available[_random.nextInt(available.length)],
      spawnedAt: DateTime.now(),
    );
    
    setState(() {
      _activePowerUps.add(powerUp);
    });
  }
  
  void _collectPowerUp(PowerUp powerUp) {
    setState(() {
      powerUp.remainingDuration = powerUp.durationSeconds;
      powerUp.isActive = true;
      _collectedPowerUps.add(powerUp);
      
      switch (powerUp.type) {
        case PowerUpType.speed:
          _speedBoostRemaining = powerUp.durationSeconds;
          _currentSpeed = (SnakeGameConfig.baseSpeedMs / 2).toDouble();
          _restartGameLoop();
          break;
        case PowerUpType.shield:
          _hasShield = true;
          break;
        case PowerUpType.doublePoints:
          _hasDoublePoints = true;
          break;
        case PowerUpType.magnet:
          _hasMagnet = true;
          break;
      }
    });
    
    _addPowerUpEffect(powerUp.position);
    HapticFeedback.mediumImpact();
  }
  
  void _attractPowerUps(Offset head) {
    for (int i = 0; i < _activePowerUps.length; i++) {
      final powerUp = _activePowerUps[i];
      final dx = head.dx - powerUp.position.dx;
      final dy = head.dy - powerUp.position.dy;
      final distance = sqrt(dx * dx + dy * dy);
      
      if (distance < 5) {
        final newX = powerUp.position.dx + (dx / distance) * 0.3;
        final newY = powerUp.position.dy + (dy / distance) * 0.3;
        powerUp.position = Offset(newX, newY);
      }
    }
  }
  
  // =========================================================================
  // EFFECTS & PARTICLES
  // =========================================================================
  
  void _addFoodEffectParticles(Offset position) {
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(
        position: Offset(
          position.dx + (_random.nextDouble() - 0.5) * 0.5,
          position.dy + (_random.nextDouble() - 0.5) * 0.5,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 0.05,
          (_random.nextDouble() - 0.5) * 0.05,
        ),
        size: 2 + _random.nextDouble() * 3,
        color: _currentFood.color,
        lifetime: 0.5,
      ));
    }
    _confettiController.play();
  }
  
  void _addPowerUpEffect(Offset position) {
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(
        position: position,
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 0.08,
          (_random.nextDouble() - 0.5) * 0.08,
        ),
        size: 2 + _random.nextDouble() * 4,
        color: const Color(0xFFFFD700),
        lifetime: 0.6,
      ));
    }
    HapticFeedback.mediumImpact();
  }
  
  void _addShieldBreakEffect() {
    _shakeController.forward(from: 0);
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        position: _snake.first,
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 0.1,
          (_random.nextDouble() - 0.5) * 0.1,
        ),
        size: 2 + _random.nextDouble() * 3,
        color: const Color(0xFF2196F3),
        lifetime: 0.5,
      ));
    }
    HapticFeedback.heavyImpact();
  }
  
  void _addCollisionEffect() {
    for (int i = 0; i < 40; i++) {
      _particles.add(Particle(
        position: _snake.first,
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 0.15,
          (_random.nextDouble() - 0.5) * 0.15,
        ),
        size: 2 + _random.nextDouble() * 5,
        color: Colors.red,
        lifetime: 0.8,
      ));
    }
    HapticFeedback.heavyImpact();
  }
  
  // =========================================================================
  // GAME END CONDITIONS
  // =========================================================================
  
  void _gameOver() {
    if (_gameState != GameState.playing) return;
    
    setState(() {
      _gameState = GameState.gameOver;
    });
    
    _gameLoopTimer?.cancel();
    _timeAttackTimer?.cancel();
    _powerUpTimer?.cancel();
    
    _addCollisionEffect();
    _saveHighScore();
    _statistics.totalGamesPlayed++;
    _statistics.totalTimeSurvived += _level * 10;
    
    // Show game over result
    _showResultScreen();
  }
  
  void _gameWin() {
    setState(() {
      _gameState = GameState.gameOver;
    });
    
    _gameLoopTimer?.cancel();
    _timeAttackTimer?.cancel();
    
    _confettiController.play();
    _saveHighScore();
    _showResultScreen();
  }
  
  void _showResultScreen() {
    final won = _score >= SnakeGameConfig.targetScoreForWin;
    final coinsEarned = won ? SnakeGameConfig.baseWinCoins + (_level * 5) : _score ~/ 2;
    final xpEarned = won ? SnakeGameConfig.baseWinXp + (_level * 10) : _score ~/ 3;
    
    // Navigate to existing GameResultScreen
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => GameResultScreen(
    //       won: won,
    //       coins: coinsEarned,
    //       xp: xpEarned,
    //       gameName: 'Snake Game',
    //       score: _score,
    //       onContinue: () => Navigator.pop(context),
    //     ),
    //   ),
    // );
    
    // For now, show dialog
    _showGameOverDialog(won, coinsEarned, xpEarned);
  }
  
  void _showGameOverDialog(bool won, int coins, int xp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        title: Text(
          won ? '🏆 VICTORY!' : '💀 GAME OVER',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $_score', style: const TextStyle(color: Colors.white)),
            Text('Level: $_level', style: const TextStyle(color: Colors.white)),
            Text('Combo: x$_combo', style: const TextStyle(color: Color(0xFFFFD700))),
            const SizedBox(height: 16),
            Text('+$coins💰  +$xp✨', style: const TextStyle(color: Color(0xFF00FF88))),
          ],
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
              _restart();
            },
            child: const Text('PLAY AGAIN', style: TextStyle(color: Color(0xFF00FF88))),
          ),
        ],
      ),
    );
  }
  
  void _restart() {
    _initGame();
    _startCountdown();
    setState(() {});
  }
  
  void _pause() {
    if (_gameState == GameState.playing) {
      setState(() => _gameState = GameState.paused);
      _gameLoopTimer?.cancel();
      _timeAttackTimer?.cancel();
    } else if (_gameState == GameState.paused) {
      setState(() => _gameState = GameState.playing);
      _startGameLoop();
      if (_currentMode == GameMode.timeAttack) {
        _startTimeAttackTimer();
      }
    }
  }
  
  // =========================================================================
  // CONTROLS
  // =========================================================================
  
  void _changeDirection(Offset newDirection) {
    if (_direction.dx == -newDirection.dx && _direction.dy == -newDirection.dy) return;
    if (_direction.dx == newDirection.dx && _direction.dy == newDirection.dy) return;
    setState(() {
      _nextDirection = newDirection;
    });
  }
  
  // =========================================================================
  // BUILD METHODS
  // =========================================================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: Focus(
        focusNode: _focusNode,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _changeDirection(const Offset(0, -1));
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _changeDirection(const Offset(0, 1));
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _changeDirection(const Offset(-1, 0));
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _changeDirection(const Offset(1, 0));
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              _pause();
            }
          }
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF050A14), Color(0xFF0A1628), Color(0xFF0F2040)],
                ),
              ),
            ),
            
            // Game Board
            Column(
              children: [
                // HUD
                _buildHUD(),
                
                // Game Canvas
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          if (details.delta.dx.abs() > details.delta.dy.abs()) {
                            if (details.delta.dx > 0) {
                              _changeDirection(const Offset(1, 0));
                            } else {
                              _changeDirection(const Offset(-1, 0));
                            }
                          } else {
                            if (details.delta.dy > 0) {
                              _changeDirection(const Offset(0, 1));
                            } else {
                              _changeDirection(const Offset(0, -1));
                            }
                          }
                        },
                        child: CustomPaint(
                          painter: AdvancedSnakePainter(
                            snake: _snake,
                            food: _currentFood,
                            powerUps: _activePowerUps,
                            particles: _particles,
                            skin: _currentSkin,
                            foodAnimation: _foodAnimationController.value,
                            shakeOffset: _shakeController.isAnimating ? sin(_shakeController.value * pi * 8) * 4 : 0,
                          ),
                          child: _buildOverlay(),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // D-Pad (mobile)
                if (MediaQuery.of(context).size.width < 600)
                  _buildDPad(),
              ],
            ),
            
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [Color(0xFFFFD700), Color(0xFF00FF88), Color(0xFF00D4FF), Color(0xFFFF4081)],
                numberOfParticles: 30,
              ),
            ),
          ],
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
            _buildStatCard('SCORE', '$_score', const Color(0xFFFFD700)),
            
            // Level Card
            _buildStatCard('LEVEL', '$_level', const Color(0xFF00D4FF)),
            
            // Combo Card
            if (_combo > 1)
              _buildStatCard('COMBO', 'x$_combo', const Color(0xFFFF4081)),
            
            // Time (Time Attack mode)
            if (_currentMode == GameMode.timeAttack)
              _buildStatCard('TIME', '$_timeRemaining', _timeRemaining < 10 ? const Color(0xFFFF0044) : const Color(0xFF00FF88)),
            
            // Best Score
            _buildStatCard('BEST', '$_highScore', const Color(0xFF9C27B0)),
          ],
        ),
      ),
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
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  Widget? _buildOverlay() {
    if (_gameState == GameState.countdown) {
      return Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF6B00)],
            ),
            boxShadow: const [BoxShadow(color: Color(0xFFFFD700), blurRadius: 20)],
          ),
          child: const Center(
            child: Text(
              '3',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      );
    }
    
    if (_gameState == GameState.paused) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00D4FF), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('PAUSED', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00D4FF))),
              const SizedBox(height: 16),
              _buildMenuButton('RESUME', () => _pause(), const Color(0xFF00FF88)),
              const SizedBox(height: 8),
              _buildMenuButton('RESTART', _restart, const Color(0xFFFFD700)),
              const SizedBox(height: 8),
              _buildMenuButton('EXIT', () => Navigator.pop(context), const Color(0xFFFF0044)),
            ],
          ),
        ),
      );
    }
    
    if (_gameState == GameState.idle) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐍', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              'SNAKE ARCADE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700),
                shadows: [const Shadow(color: Color(0xFFFFD700), blurRadius: 12)],
              ),
            ),
            const SizedBox(height: 8),
            Text('Swipe or use arrows', style: TextStyle(color: const Color(0xFF8AACCC))),
            const SizedBox(height: 32),
            _buildMenuButton('START GAME', _startCountdown, const Color(0xFF00FF88)),
          ],
        ),
      );
    }
    
    return null;
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
  
  Widget _buildDPad() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dpadButton(Icons.arrow_upward, () => _changeDirection(const Offset(0, -1))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dpadButton(Icons.arrow_back, () => _changeDirection(const Offset(-1, 0))),
              const SizedBox(width: 60),
              _dpadButton(Icons.pause, () => _pause()),
              const SizedBox(width: 60),
              _dpadButton(Icons.arrow_forward, () => _changeDirection(const Offset(1, 0))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dpadButton(Icons.arrow_downward, () => _changeDirection(const Offset(0, 1))),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _dpadButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.4)),
        ),
        child: Icon(icon, color: const Color(0xFF00FF88), size: 24),
      ),
    );
  }
  
  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _countdownTimer?.cancel();
    _powerUpTimer?.cancel();
    _particleTimer?.cancel();
    _timeAttackTimer?.cancel();
    _confettiController.dispose();
    _foodAnimationController.dispose();
    _shakeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// =============================================================================
// ADVANCED SNAKE PAINTER
// =============================================================================

class AdvancedSnakePainter extends CustomPainter {
  final List<Offset> snake;
  final FoodItem food;
  final List<PowerUp> powerUps;
  final List<Particle> particles;
  final SnakeSkin skin;
  final double foodAnimation;
  final double shakeOffset;
  
  AdvancedSnakePainter({
    required this.snake,
    required this.food,
    required this.powerUps,
    required this.particles,
    required this.skin,
    required this.foodAnimation,
    required this.shakeOffset,
  });
  
  Color _getSnakeColor(int index) {
    final bool isHead = index == 0;
    final baseColor = _getSkinBaseColor();
    
    if (isHead) {
      return baseColor;
    }
    
    final opacity = 0.7 - (index / snake.length) * 0.3;
    return baseColor.withOpacity(opacity);
  }
  
  Color _getSkinBaseColor() {
    switch (skin) {
      case SnakeSkin.neonGreen:
        return const Color(0xFF00FF88);
      case SnakeSkin.cyberBlue:
        return const Color(0xFF00D4FF);
      case SnakeSkin.magmaRed:
        return const Color(0xFFFF0044);
      case SnakeSkin.goldPhoenix:
        return const Color(0xFFFFD700);
      case SnakeSkin.rainbow:
        return const Color(0xFFFF4081);
    }
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / SnakeGameConfig.gridCols;
    final double cellHeight = size.height / SnakeGameConfig.gridRows;
    
    canvas.save();
    canvas.translate(shakeOffset, 0);
    
    // Draw grid
    final gridPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(SnakeGameConfig.gridLineOpacity)
      ..strokeWidth = 1;
    
    for (int i = 0; i <= SnakeGameConfig.gridCols; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        gridPaint,
      );
    }
    for (int i = 0; i <= SnakeGameConfig.gridRows; i++) {
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        gridPaint,
      );
    }
    
    // Draw particles
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        Offset(particle.position.dx * cellWidth, particle.position.dy * cellHeight),
        particle.size,
        paint,
      );
    }
    
    // Draw power-ups
    for (final powerUp in powerUps) {
      final left = powerUp.position.dx * cellWidth;
      final top = powerUp.position.dy * cellHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 2, top + 2, cellWidth - 4, cellHeight - 4),
        Radius.circular(SnakeGameConfig.cellBorderRadius),
      );
      
      // Glow effect
      final glowPaint = Paint()
        ..color = powerUp.color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(rect, glowPaint);
      
      // Main shape
      canvas.drawRRect(rect, Paint()..color = powerUp.color.withOpacity(0.8));
      
      // Icon
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(powerUp.icon.codePoint),
          style: TextStyle(fontSize: cellWidth * 0.5, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(left + cellWidth / 2 - textPainter.width / 2, top + cellHeight / 2 - textPainter.height / 2),
      );
    }
    
    // Draw food with animation
    final foodLeft = food.position.dx * cellWidth;
    final foodTop = food.position.dy * cellHeight;
    final foodScale = 0.8 + foodAnimation * 0.4;
    final foodSize = (cellWidth - 4) * foodScale;
    final foodOffset = (cellWidth - foodSize) / 2;
    
    final foodRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(foodLeft + foodOffset, foodTop + foodOffset, foodSize, foodSize),
      Radius.circular(SnakeGameConfig.cellBorderRadius),
    );
    
    // Food glow
    final foodGlowPaint = Paint()
      ..color = food.color.withOpacity(SnakeGameConfig.foodGlowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(foodRect, foodGlowPaint);
    
    // Food main
    canvas.drawRRect(foodRect, Paint()..color = food.color);
    
    // Food inner highlight
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(foodLeft + foodOffset + 3, foodTop + foodOffset + 3, foodSize - 6, foodSize - 6),
      Radius.circular(SnakeGameConfig.cellBorderRadius - 2),
    );
    canvas.drawRRect(innerRect, Paint()..color = Colors.white.withOpacity(0.3));
    
    // Draw snake
    for (int i = 0; i < snake.length; i++) {
      final segment = snake[i];
      final left = segment.dx * cellWidth;
      final top = segment.dy * cellHeight;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 2, top + 2, cellWidth - 4, cellHeight - 4),
        Radius.circular(SnakeGameConfig.cellBorderRadius),
      );
      
      // Snake glow
      final glowPaint = Paint()
        ..color = _getSnakeColor(i).withOpacity(SnakeGameConfig.snakeGlowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(rect, glowPaint);
      
      // Snake body
      canvas.drawRRect(rect, Paint()..color = _getSnakeColor(i));
      
      // Snake eyes (head only)
      if (i == 0) {
        final eyeSize = cellWidth * 0.12;
        final eyeOffset = cellWidth * 0.25;
        
        canvas.drawCircle(
          Offset(left + eyeOffset, top + eyeOffset),
          eyeSize,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          Offset(left + cellWidth - eyeOffset, top + eyeOffset),
          eyeSize,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          Offset(left + eyeOffset, top + eyeOffset),
          eyeSize * 0.6,
          Paint()..color = Colors.black,
        );
        canvas.drawCircle(
          Offset(left + cellWidth - eyeOffset, top + eyeOffset),
          eyeSize * 0.6,
          Paint()..color = Colors.black,
        );
      }
    }
    
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(AdvancedSnakePainter oldDelegate) => true;
}

// =============================================================================
// USAGE EXAMPLE:
// =============================================================================
/*
// To use this advanced Snake Game in your existing app:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedSnakeGame(),
  ),
);

// With specific mode:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AdvancedSnakeGame(initialMode: GameMode.timeAttack),
  ),
);

// To integrate with your existing GameResultScreen, uncomment the navigation
// in _showResultScreen() method and adjust imports.
*/