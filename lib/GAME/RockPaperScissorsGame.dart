// =============================================================================
// ROCK PAPER SCISSORS - ARCADE QUALITY GAME
// Version: 3.2 | Production-Ready | Smooth Animations | Premium UI
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'beedi_game_screen.dart';

// =============================================================================
// ROCK PAPER SCISSORS GAME - MAIN CLASS
// =============================================================================

class RockPaperScissorsGame extends StatefulWidget {
  const RockPaperScissorsGame({super.key});
  
  @override
  State<RockPaperScissorsGame> createState() => _RockPaperScissorsGameState();
}

class _RockPaperScissorsGameState extends State<RockPaperScissorsGame>
    with TickerProviderStateMixin {  // Changed from SingleTickerProviderStateMixin to TickerProviderStateMixin
  
  // =========================================================================
  // GAME CONSTANTS
  // =========================================================================
  static const int _totalRounds = 5;
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  final Random _rng = Random();
  int _playerWins = 0;
  int _cpuWins = 0;
  int _draws = 0;
  int _rounds = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalMatches = 0;
  int _accuracy = 0;
  
  String? _playerChoice;
  String? _cpuChoice;
  String? _result;
  String? _aiThought;
  
  bool _isPlaying = false;
  bool _isRevealing = false;
  int _winStreak = 0;
  
  // =========================================================================
  // ANIMATION CONTROLLERS
  // =========================================================================
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _celebrationAnimation;
  
  // =========================================================================
  // PARTICLES & EFFECTS
  // =========================================================================
  final List<EffectParticle> _particles = [];
  Timer? _particleTimer;
  
  // =========================================================================
  // STATISTICS
  // =========================================================================
  int _totalPlayerWins = 0;
  int _totalCpuWins = 0;
  int _totalDraws = 0;
  
  // =========================================================================
  // CONSTANTS
  // =========================================================================
  static const List<String> _choices = ['Rock', 'Paper', 'Scissors'];
  static const Map<String, String> _emojis = {
    'Rock': '✊', 
    'Paper': '✋', 
    'Scissors': '✌️'
  };
  static const Map<String, Color> _choiceColors = {
    'Rock': Color(0xFF8B7355),
    'Paper': Color(0xFF87CEEB),
    'Scissors': Color(0xFFC0C0C0),
  };
  
  // =========================================================================
  // AI THOUGHTS
  // =========================================================================
  final List<String> _aiThoughts = [
    'Hmm... 🤔',
    'I choose... 💭',
    'Think fast! ⚡',
    'You won\'t win! 😤',
    'Let\'s battle! ⚔️',
    'My turn! 🎯',
    'Get ready! 🔥',
  ];
  
  // =========================================================================
  // SHAKE STATE
  // =========================================================================
  bool _shakeNow = false;
  Timer? _shakeTimer;
  
  // =========================================================================
  // INITIALIZATION
  // =========================================================================
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadStats();
    _initParticleSystem();
  }
  
  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _celebrationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }
  
  void _triggerShake() {
    setState(() {
      _shakeNow = true;
    });
    _shakeTimer?.cancel();
    _shakeTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _shakeNow = false;
        });
      }
    });
  }
  
  void _initParticleSystem() {
    _particleTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) {
        setState(() {
          for (int i = _particles.length - 1; i >= 0; i--) {
            _particles[i].life--;
            _particles[i].y += _particles[i].vy;
            _particles[i].x += _particles[i].vx;
            if (_particles[i].life <= 0) {
              _particles.removeAt(i);
            }
          }
        });
      }
    });
  }
  
  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestStreak = prefs.getInt('rps_best_streak') ?? 0;
      _totalMatches = prefs.getInt('rps_total_matches') ?? 0;
      _totalPlayerWins = prefs.getInt('rps_player_wins') ?? 0;
      _totalCpuWins = prefs.getInt('rps_cpu_wins') ?? 0;
      _totalDraws = prefs.getInt('rps_draws') ?? 0;
    });
    _updateAccuracy();
  }
  
  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rps_best_streak', _bestStreak);
    await prefs.setInt('rps_total_matches', _totalMatches);
    await prefs.setInt('rps_player_wins', _totalPlayerWins);
    await prefs.setInt('rps_cpu_wins', _totalCpuWins);
    await prefs.setInt('rps_draws', _totalDraws);
  }
  
  void _updateAccuracy() {
    if (_totalMatches > 0) {
      setState(() {
        _accuracy = ((_totalPlayerWins / _totalMatches) * 100).round();
      });
    }
  }
  
  // =========================================================================
  // AI LOGIC
  // =========================================================================
  String _getAIChoice() {
    setState(() {
      _aiThought = _aiThoughts[_rng.nextInt(_aiThoughts.length)];
    });
    return _choices[_rng.nextInt(3)];
  }
  
  // =========================================================================
  // GAME LOGIC
  // =========================================================================
  void _play(String choice) async {
    if (_isPlaying || _isRevealing) return;
    
    setState(() {
      _isPlaying = true;
      _playerChoice = choice;
      _cpuChoice = _getAIChoice();
    });
    
    // Start shake animation
    _triggerShake();
    
    // Wait for dramatic effect
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Determine winner
    String result;
    if (_playerChoice == _cpuChoice) {
      result = 'DRAW';
      _draws++;
      _totalDraws++;
      _currentStreak = 0;
      _addParticles(_getChoiceColor(_playerChoice!), isWin: false);
    } else if (
      (_playerChoice == 'Rock' && _cpuChoice == 'Scissors') ||
      (_playerChoice == 'Paper' && _cpuChoice == 'Rock') ||
      (_playerChoice == 'Scissors' && _cpuChoice == 'Paper')
    ) {
      result = 'YOU WIN!';
      _playerWins++;
      _totalPlayerWins++;
      _currentStreak++;
      _winStreak++;
      _totalMatches++;
      _addParticles(_getChoiceColor(_playerChoice!), isWin: true);
      HapticFeedback.lightImpact();
      
      if (_currentStreak > _bestStreak) {
        setState(() => _bestStreak = _currentStreak);
        _saveStats();
      }
    } else {
      result = 'CPU WINS';
      _cpuWins++;
      _totalCpuWins++;
      _currentStreak = 0;
      _winStreak = 0;
      _totalMatches++;
      _addParticles(_getChoiceColor(_cpuChoice!), isWin: false);
      HapticFeedback.lightImpact();
    }
    
    setState(() {
      _result = result;
      _isRevealing = true;
      _rounds++;
    });
    
    // Celebration animation on win
    if (result == 'YOU WIN!') {
      _celebrationController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 800));
    }
    
    // Save stats
    _updateAccuracy();
    await _saveStats();
    
    // Reset for next round after delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      _isPlaying = false;
      _isRevealing = false;
    });
    
    // Show game over when rounds complete
    if (_rounds >= _totalRounds) {
      await Future.delayed(const Duration(milliseconds: 500));
      _showGameOverDialog();
    }
  }
  
  void _addParticles(Color color, {required bool isWin}) {
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < (isWin ? 30 : 15); i++) {
      _particles.add(EffectParticle(
        x: size.width / 2,
        y: size.height / 2,
        vx: (_rng.nextDouble() - 0.5) * 8,
        vy: (_rng.nextDouble() - 0.5) * 8,
        life: 40,
        color: color,
        size: 4 + _rng.nextDouble() * 4,
      ));
    }
  }
  
  Color _getChoiceColor(String choice) {
    switch (choice) {
      case 'Rock': return const Color(0xFF8B7355);
      case 'Paper': return const Color(0xFF87CEEB);
      case 'Scissors': return const Color(0xFFC0C0C0);
      default: return BColors.neonBlue;
    }
  }
  
  void _resetGame() {
    setState(() {
      _playerWins = 0;
      _cpuWins = 0;
      _draws = 0;
      _rounds = 0;
      _currentStreak = 0;
      _playerChoice = null;
      _cpuChoice = null;
      _result = null;
      _isPlaying = false;
      _isRevealing = false;
      _particles.clear();
    });
  }
  
  void _showGameOverDialog() {
    final won = _playerWins > _cpuWins;
    final totalCoins = won ? 30 + (_winStreak * 5).clamp(0, 100) : 0;
    final totalXp = won ? 45 + (_winStreak * 3).clamp(0, 150) : 15;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: BColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: won ? BColors.neonGold : BColors.neonRed, width: 2),
        ),
        title: Column(
          children: [
            Text(
              won ? '🏆 VICTORY! 🏆' : '💀 GAME OVER 💀',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: won ? BColors.neonGold : BColors.neonRed,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [BColors.bg3, BColors.bg2],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('Final Score: $_playerWins - $_cpuWins',
                      style: TextStyle(fontSize: 18, color: BColors.txtPrimary)),
                  const SizedBox(height: 5),
                  Text('Draws: $_draws',
                      style: TextStyle(fontSize: 14, color: BColors.txtSecondary)),
                  if (_winStreak > 0)
                    Text('🔥 Win Streak: $_winStreak',
                        style: TextStyle(fontSize: 14, color: BColors.neonOrange)),
                  if (_bestStreak > 0)
                    Text('🏆 Best Streak: $_bestStreak',
                        style: TextStyle(fontSize: 12, color: BColors.neonGold)),
                ],
              ),
            ),
          ],
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildRewardChip('+$totalCoins', '💰', BColors.neonGold),
            _buildRewardChip('+$totalXp', '⭐', BColors.neonPurple),
            _buildRewardChip('+$_winStreak', '🔥', BColors.neonOrange),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text('REMATCH', style: TextStyle(color: BColors.neonBlue, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BColors.neonGold,
              foregroundColor: Colors.black,
            ),
            child: const Text('EXIT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardChip(String text, String icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.bg1,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  BColors.bg2,
                  BColors.bg1,
                ],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Stats Section
                _buildStatsSection(),
                
                const SizedBox(height: 20),
                
                // Battle Arena
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // VS Display
                          _buildVSDisplay(),
                          
                          const SizedBox(height: 30),
                          
                          // Result Display
                          if (_result != null) _buildResultDisplay(),
                          
                          const SizedBox(height: 30),
                          
                          // Choice Buttons
                          if (!_isPlaying || _isRevealing)
                            _buildChoiceButtons(),
                          
                          const SizedBox(height: 20),
                          
                          // AI Thought Bubble
                          if (_aiThought != null && !_isRevealing)
                            _buildAIThought(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Particles
          CustomPaint(
            painter: ParticlePainter(_particles),
            child: const SizedBox.expand(),
          ),
        ],
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: BColors.bg2,
      elevation: 0,
      title: Text(
        'ROCK PAPER SCISSORS',
        style: BText.orbitron(size: 14, color: BColors.neonBlue),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [BColors.neonGold.withOpacity(0.2), BColors.neonOrange.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BColors.neonGold.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: BColors.neonGold, size: 16),
              const SizedBox(width: 4),
              Text(
                '$_playerWins - $_cpuWins',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: BColors.neonGold),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BColors.bg2.withOpacity(0.8), BColors.bg3.withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BColors.neonBlue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Round', '${_rounds + 1}/$_totalRounds', BColors.neonBlue),
          _buildStatItem('Streak', '$_currentStreak', BColors.neonOrange),
          _buildStatItem('Accuracy', '$_accuracy%', BColors.neonGreen),
          _buildStatItem('Best', '$_bestStreak', BColors.neonGold),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: BColors.txtSecondary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }
  
  Widget _buildVSDisplay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Player Choice
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getChoiceColor(_playerChoice ?? 'Rock').withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
                boxShadow: _playerChoice != null && !_isRevealing
                    ? [BoxShadow(color: _getChoiceColor(_playerChoice!), blurRadius: 30)]
                    : null,
              ),
              child: AnimatedScale(
                scale: _isRevealing ? 1.2 : 1,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BColors.bg2,
                    border: Border.all(
                      color: _playerChoice != null && !_isRevealing
                          ? _getChoiceColor(_playerChoice!)
                          : BColors.neonBlue.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _playerChoice != null && !_isRevealing
                          ? _emojis[_playerChoice]!
                          : '?',
                      style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            
            // VS Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [BColors.neonRed, BColors.neonPurple],
                ),
                boxShadow: [
                  BoxShadow(color: BColors.neonRed.withOpacity(0.5), blurRadius: 15),
                ],
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                ),
              ),
            ),
            
            // CPU Choice with shake effect
            Transform.translate(
              offset: Offset(_shakeNow ? (sin(DateTime.now().millisecondsSinceEpoch / 50) * 5) : 0, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getChoiceColor(_cpuChoice ?? 'Scissors').withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BColors.bg2,
                    border: Border.all(
                      color: _cpuChoice != null && !_isRevealing
                          ? _getChoiceColor(_cpuChoice!)
                          : BColors.neonRed.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _cpuChoice != null && !_isRevealing
                            ? _emojis[_cpuChoice]!
                            : '🤖',
                        key: ValueKey(_cpuChoice),
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildResultDisplay() {
    final isWin = _result == 'YOU WIN!';
    final isDraw = _result == 'DRAW';
    final color = isWin ? BColors.neonGreen : (isDraw ? BColors.neonBlue : BColors.neonRed);
    
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + _celebrationAnimation.value * 0.1,
          child: GlassCard(
            borderColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                if (isWin)
                  const Text('🎉', style: TextStyle(fontSize: 40)),
                Text(
                  '${_emojis[_playerChoice]} vs ${_emojis[_cpuChoice]}',
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(height: 8),
                Text(
                  _result!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                    shadows: [Shadow(color: color, blurRadius: 10)],
                  ),
                ),
                if (isWin && _currentStreak > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '🔥 STREAK x$_currentStreak! 🔥',
                      style: TextStyle(fontSize: 14, color: BColors.neonOrange),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildChoiceButtons() {
    return Column(
      children: [
        Text(
          'MAKE YOUR MOVE',
          style: BText.orbitron(size: 14, color: BColors.txtPrimary),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _choices.map((choice) {
            return _buildChoiceButton(choice);
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildChoiceButton(String choice) {
    return GestureDetector(
      onTap: () => _play(choice),
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getChoiceColor(choice).withOpacity(0.3),
              _getChoiceColor(choice).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getChoiceColor(choice).withOpacity(0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getChoiceColor(choice).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_emojis[choice]!, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              choice,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getChoiceColor(choice),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAIThought() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: BColors.bg2.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BColors.neonPurple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            _aiThought ?? 'Let\'s play!',
            style: TextStyle(fontSize: 12, color: BColors.txtSecondary),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _celebrationController.dispose();
    _particleTimer?.cancel();
    _shakeTimer?.cancel();
    super.dispose();
  }
}

// =============================================================================
// PARTICLE SYSTEM
// =============================================================================
class EffectParticle {
  double x, y, vx, vy;
  int life;
  Color color;
  double size;
  
  EffectParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    this.size = 4,
  });
}

class ParticlePainter extends CustomPainter {
  final List<EffectParticle> particles;
  
  ParticlePainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.life / 40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}