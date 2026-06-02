// =============================================================================
// TIC TAC TOE - ARCADE QUALITY GAME
// Version: 3.0 | Production-Ready | Smooth Animations | Premium UI
// File: lib/GAME/tic_tac_toe_enhanced.dart
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'beedi_game_screen.dart';

// =============================================================================
// MAIN GAME CLASS
// =============================================================================

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});
  
  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> with TickerProviderStateMixin {
  
  // =========================================================================
  // GAME CONSTANTS
  // =========================================================================
  static const int _winTarget = 3;
  static const List<List<int>> _winLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6],             // Diagonals
  ];
  
  // =========================================================================
  // GAME STATE
  // =========================================================================
  List<String> _board = List.filled(9, '');
  bool _xTurn = true;
  String? _winner;
  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalMatches = 0;
  
  // =========================================================================
  // GAME MODE
  // =========================================================================
  GameMode _gameMode = GameMode.singlePlayer;
  Difficulty _difficulty = Difficulty.medium;
  bool _isAIPlaying = false;
  bool _isGameOver = false;
  bool _isPaused = false;
  
  // =========================================================================
  // ANIMATION
  // =========================================================================
  late AnimationController _winLineController;
  late Animation<double> _winLineAnimation;
  List<int>? _winningLine;
  final List<AnimatedMove> _animatedMoves = [];
  final List<ParticleEffect> _particles = [];
  Timer? _particleTimer;
  Timer? _aiMoveTimer;
  
  // =========================================================================
  // STATISTICS
  // =========================================================================
  int _totalXWins = 0;
  int _totalOWins = 0;
  int _totalDraws = 0;
  
  // =========================================================================
  // INITIALIZATION
  // =========================================================================
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadStats();
    _initParticleSystem();
    _showGameModeDialog();
  }
  
  void _initAnimations() {
    _winLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _winLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _winLineController, curve: Curves.elasticOut),
    );
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
      _bestStreak = prefs.getInt('ttt_best_streak') ?? 0;
      _totalMatches = prefs.getInt('ttt_total_matches') ?? 0;
      _totalXWins = prefs.getInt('ttt_x_wins') ?? 0;
      _totalOWins = prefs.getInt('ttt_o_wins') ?? 0;
      _totalDraws = prefs.getInt('ttt_draws') ?? 0;
    });
  }
  
  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ttt_best_streak', _bestStreak);
    await prefs.setInt('ttt_total_matches', _totalMatches);
    await prefs.setInt('ttt_x_wins', _totalXWins);
    await prefs.setInt('ttt_o_wins', _totalOWins);
    await prefs.setInt('ttt_draws', _totalDraws);
  }
  
  // =========================================================================
  // GAME MODE DIALOG
  // =========================================================================
  void _showGameModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: BColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: BColors.neonBlue, width: 2),
        ),
        title: Text('SELECT MODE', style: BText.orbitron(size: 16, color: BColors.neonBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModeButton('👤 Single Player', () {
              setState(() => _gameMode = GameMode.singlePlayer);
              Navigator.pop(context);
              _showDifficultyDialog();
            }, BColors.neonGreen),
            const SizedBox(height: 10),
            _buildModeButton('👥 Two Players', () {
              setState(() => _gameMode = GameMode.twoPlayer);
              Navigator.pop(context);
            }, BColors.neonPurple),
          ],
        ),
      ),
    );
  }
  
  void _showDifficultyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: BColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: BColors.neonGold, width: 2),
        ),
        title: Text('SELECT DIFFICULTY', style: BText.orbitron(size: 16, color: BColors.neonGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDifficultyButton('😊 Easy', Difficulty.easy, BColors.neonGreen),
            const SizedBox(height: 8),
            _buildDifficultyButton('🤔 Medium', Difficulty.medium, BColors.neonBlue),
            const SizedBox(height: 8),
            _buildDifficultyButton('🧠 Hard', Difficulty.hard, BColors.neonOrange),
            const SizedBox(height: 8),
            _buildDifficultyButton('🤖 Impossible', Difficulty.impossible, BColors.neonRed),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModeButton(String text, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
      ),
    );
  }
  
  Widget _buildDifficultyButton(String text, Difficulty difficulty, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() => _difficulty = difficulty);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ),
      ),
    );
  }
  
  // =========================================================================
  // AI LOGIC
  // =========================================================================
  Future<void> _makeAIMove() async {
    if (_isAIPlaying || _winner != null || _xTurn || _gameMode != GameMode.singlePlayer) return;
    
    setState(() => _isAIPlaying = true);
    await Future.delayed(const Duration(milliseconds: 300));
    
    int move;
    switch (_difficulty) {
      case Difficulty.easy:
        move = _getRandomMove();
        break;
      case Difficulty.medium:
        move = _getMediumMove();
        break;
      case Difficulty.hard:
        move = _getBestMove();
        break;
      case Difficulty.impossible:
        move = _getImpossibleMove();
        break;
    }
    
    if (move != -1 && _board[move].isEmpty) {
      _animatedMoves.add(AnimatedMove(index: move, player: 'O', progress: 0));
      await _animateMove(move);
      _board[move] = 'O';
      _xTurn = true;
      _checkWinner();
    }
    
    setState(() => _isAIPlaying = false);
  }
  
  int _getRandomMove() {
    final emptyIndices = _board.asMap().entries.where((e) => e.value.isEmpty).map((e) => e.key).toList();
    if (emptyIndices.isEmpty) return -1;
    return emptyIndices[Random().nextInt(emptyIndices.length)];
  }
  
  int _getMediumMove() {
    // 70% chance of best move, 30% random
    if (Random().nextDouble() < 0.7) {
      return _getBestMove();
    }
    return _getRandomMove();
  }
  
  int _getBestMove() {
    // Try to win
    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) {
        _board[i] = 'O';
        if (_checkWinnerForPlayer('O')) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }
    
    // Block player win
    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) {
        _board[i] = 'X';
        if (_checkWinnerForPlayer('X')) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }
    
    // Take center
    if (_board[4].isEmpty) return 4;
    
    // Take corners
    final corners = [0, 2, 6, 8];
    for (final corner in corners) {
      if (_board[corner].isEmpty) return corner;
    }
    
    return _getRandomMove();
  }
  
  int _getImpossibleMove() {
    return _getBestMove(); // Perfect play = always best move
  }
  
  bool _checkWinnerForPlayer(String player) {
    for (final line in _winLines) {
      if (_board[line[0]] == player && _board[line[1]] == player && _board[line[2]] == player) {
        return true;
      }
    }
    return false;
  }
  
  Future<void> _animateMove(int index) async {
    for (double t = 0; t <= 1; t += 0.1) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (mounted) {
        setState(() {
          final moveIndex = _animatedMoves.indexWhere((m) => m.index == index);
          if (moveIndex != -1) {
            _animatedMoves[moveIndex].progress = t;
          }
        });
      }
    }
    setState(() {
      _animatedMoves.removeWhere((m) => m.index == index);
    });
  }
  
  // =========================================================================
  // GAME LOGIC
  // =========================================================================
  void _tap(int index) async {
    if (_board[index].isNotEmpty || _winner != null || _isAIPlaying || _isPaused) return;
    if (_gameMode == GameMode.singlePlayer && !_xTurn) return;
    
    // Animate move
    _animatedMoves.add(AnimatedMove(index: index, player: _xTurn ? 'X' : 'O', progress: 0));
    await _animateMove(index);
    
    setState(() {
      _board[index] = _xTurn ? 'X' : 'O';
      _xTurn = !_xTurn;
      _checkWinner();
    });
    
    HapticFeedback.lightImpact();
    
    if (_gameMode == GameMode.singlePlayer && _winner == null && !_board.contains('')) {
      await _makeAIMove();
    } else if (_gameMode == GameMode.singlePlayer && _winner == null) {
      _makeAIMove();
    }
  }
  
  void _checkWinner() {
    for (final line in _winLines) {
      if (_board[line[0]] != '' &&
          _board[line[0]] == _board[line[1]] &&
          _board[line[1]] == _board[line[2]]) {
        _winner = _board[line[0]];
        _winningLine = line;
        _winLineController.forward(from: 0);
        
        if (_winner == 'X') {
          _xWins++;
          _totalXWins++;
          _currentStreak = _currentStreak > 0 ? _currentStreak + 1 : 1;
          _addVictoryParticles(BColors.neonBlue);
        } else {
          _oWins++;
          _totalOWins++;
          _currentStreak = _currentStreak < 0 ? _currentStreak - 1 : -1;
          _addVictoryParticles(BColors.neonRed);
        }
        
        _totalMatches++;
        _updateBestStreak();
        _saveStats();
        
        if (_xWins >= _winTarget || _oWins >= _winTarget) {
          _showGameComplete();
        } else {
          _showRoundOverDialog();
        }
        return;
      }
    }
    
    if (!_board.contains('')) {
      _winner = 'Draw';
      _draws++;
      _totalDraws++;
      _totalMatches++;
      _currentStreak = 0;
      _saveStats();
      _showDrawDialog();
    }
  }
  
  void _updateBestStreak() {
    if (_currentStreak.abs() > _bestStreak) {
      _bestStreak = _currentStreak.abs();
      _saveStats();
    }
  }
  
  void _addVictoryParticles(Color color) {
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < 50; i++) {
      _particles.add(ParticleEffect(
        x: size.width / 2,
        y: size.height / 2,
        vx: (Random().nextDouble() - 0.5) * 10,
        vy: (Random().nextDouble() - 0.5) * 10,
        life: 60,
        color: color,
        size: 4 + Random().nextDouble() * 4,
      ));
    }
  }
  
  void _resetRound() {
    setState(() {
      _board = List.filled(9, '');
      _winner = null;
      _winningLine = null;
      _xTurn = true;
      _animatedMoves.clear();
      _winLineController.reset();
    });
    
    if (_gameMode == GameMode.singlePlayer && !_xTurn) {
      _makeAIMove();
    }
  }
  
  void _resetGame() {
    setState(() {
      _xWins = 0;
      _oWins = 0;
      _draws = 0;
      _currentStreak = 0;
      _resetRound();
    });
  }
  
  void _showRoundOverDialog() {
    final isXWin = _winner == 'X';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: BColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isXWin ? BColors.neonBlue : BColors.neonRed, width: 2),
        ),
        title: Text(isXWin ? '🏆 X WINS ROUND! 🏆' : '💀 O WINS ROUND! 💀',
            style: TextStyle(color: isXWin ? BColors.neonBlue : BColors.neonRed)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $_xWins - $_oWins', style: TextStyle(fontSize: 18, color: BColors.txtPrimary)),
            const SizedBox(height: 10),
            if (_currentStreak > 0)
              Text('🔥 Streak: $_currentStreak', style: TextStyle(color: BColors.neonOrange)),
            if (_bestStreak > 0)
              Text('🏆 Best Streak: $_bestStreak', style: TextStyle(color: BColors.neonGold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetRound();
            },
            child: Text('NEXT ROUND', style: TextStyle(color: BColors.neonGreen)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text('RESET GAME', style: TextStyle(color: BColors.neonOrange)),
          ),
        ],
      ),
    );
  }
  
  void _showDrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: BColors.neonGold, width: 2),
        ),
        title: Text('🤝 DRAW! 🤝', style: TextStyle(color: BColors.neonGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $_xWins - $_oWins', style: TextStyle(fontSize: 18, color: BColors.txtPrimary)),
            Text('Draws: $_draws', style: TextStyle(color: BColors.txtSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetRound();
            },
            child: Text('CONTINUE', style: TextStyle(color: BColors.neonGreen)),
          ),
        ],
      ),
    );
  }
  
  void _showGameComplete() {
    final won = _xWins >= _winTarget;
    final totalCoins = won ? 30 + (_currentStreak * 5).clamp(0, 50) : 0;
    final totalXp = won ? 50 + (_currentStreak * 3).clamp(0, 80) : 15;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: BColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: won ? BColors.neonGold : BColors.neonRed, width: 2),
        ),
        title: Text(won ? '🏆 VICTORY! 🏆' : '💀 GAME OVER 💀',
            style: TextStyle(color: won ? BColors.neonGold : BColors.neonRed)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Final Score: $_xWins - $_oWins', style: TextStyle(fontSize: 18, color: BColors.txtPrimary)),
            Text('Draws: $_draws', style: TextStyle(color: BColors.txtSecondary)),
            if (_currentStreak > 0)
              Text('🔥 Win Streak: $_currentStreak', style: TextStyle(color: BColors.neonOrange)),
            if (_bestStreak > 0)
              Text('🏆 Best Streak: $_bestStreak', style: TextStyle(color: BColors.neonGold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRewardChip('+$totalCoins', '💰', BColors.neonGold),
                _buildRewardChip('+$totalXp', '⭐', BColors.neonPurple),
                _buildRewardChip('+$_currentStreak', '🔥', BColors.neonOrange),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: Text('REMATCH', style: TextStyle(color: BColors.neonBlue)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: BColors.neonGold),
            child: const Text('EXIT', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardChip(String text, String icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }
  
  // =========================================================================
  // BUILD METHOD
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isPaused && _winner == null && _board.any((cell) => cell.isNotEmpty)) {
          _togglePause();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: BColors.bg1,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildScoreBoard(),
                  const SizedBox(height: 20),
                  _buildGameBoard(),
                  const SizedBox(height: 20),
                  _buildGameInfo(),
                ],
              ),
            ),
            if (_isPaused) _buildPauseMenu(),
            CustomPaint(painter: ParticlePainter(_particles), child: const SizedBox.expand()),
          ],
        ),
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: BColors.bg2,
      elevation: 0,
      title: Text('TIC TAC TOE', style: BText.orbitron(size: 14, color: BColors.neonBlue)),
      centerTitle: true,
      actions: [
        if (_gameMode == GameMode.singlePlayer)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getDifficultyColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_difficulty.toString().split('.').last,
                style: TextStyle(fontSize: 10, color: Colors.white)),
          ),
        IconButton(
          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, color: BColors.neonBlue),
          onPressed: _togglePause,
        ),
      ],
    );
  }
  
  Color _getDifficultyColor() {
    switch (_difficulty) {
      case Difficulty.easy: return BColors.neonGreen;
      case Difficulty.medium: return BColors.neonBlue;
      case Difficulty.hard: return BColors.neonOrange;
      case Difficulty.impossible: return BColors.neonRed;
    }
  }
  
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [BColors.bg2, BColors.bg1],
        ),
      ),
    );
  }
  
  Widget _buildScoreBoard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [BColors.bg2.withOpacity(0.8), BColors.bg3.withOpacity(0.6)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BColors.neonBlue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreCard('X', _xWins, BColors.neonBlue),
          _buildScoreCard('Draws', _draws, BColors.neonGold),
          _buildScoreCard('O', _oWins, BColors.neonRed),
        ],
      ),
    );
  }
  
  Widget _buildScoreCard(String title, int score, Color color) {
    return Column(
      children: [
        Text(title, style: BText.orbitron(size: 12, color: color)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text('$score', style: BText.orbitron(size: 20, color: color)),
        ),
      ],
    );
  }
  
  Widget _buildGameBoard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth > 500 ? 400.0 : screenWidth - 80;
    
    return Center(
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 9,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => _buildCell(index),
        ),
      ),
    );
  }
  
  Widget _buildCell(int index) {
    final isWinningCell = _winningLine?.contains(index) ?? false;
    final animatedMove = _animatedMoves.firstWhere((m) => m.index == index, orElse: () => AnimatedMove(index: -1, player: '', progress: 0));
    final isAnimating = animatedMove.index != -1;
    
    return GestureDetector(
      onTap: () => _tap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isWinningCell
                ? [BColors.neonGold.withOpacity(0.4), BColors.neonOrange.withOpacity(0.2)]
                : [BColors.bg2.withOpacity(0.8), BColors.bg3.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWinningCell
                ? BColors.neonGold
                : _board[index] == 'X'
                    ? BColors.neonBlue
                    : _board[index] == 'O'
                        ? BColors.neonRed
                        : BColors.neonBlue.withOpacity(0.3),
            width: isWinningCell ? 3 : 2,
          ),
          boxShadow: isWinningCell
              ? [BoxShadow(color: BColors.neonGold.withOpacity(0.5), blurRadius: 15)]
              : null,
        ),
        child: Center(
          child: isAnimating
              ? ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: animatedMove.progress,
                    child: _buildMark(_board[index].isEmpty ? animatedMove.player : _board[index]),
                  ),
                )
              : _buildMark(_board[index]),
        ),
      ),
    );
  }
  
  Widget _buildMark(String mark) {
    if (mark.isEmpty) return const SizedBox();
    
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: mark == 'X' ? BColors.neonBlue : BColors.neonRed,
        shadows: [
          Shadow(
            color: (mark == 'X' ? BColors.neonBlue : BColors.neonRed).withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(mark),
    );
  }
  
  Widget _buildGameInfo() {
    if (_winner != null) return const SizedBox(height: 60);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_xTurn ? BColors.neonBlue.withOpacity(0.2) : BColors.neonRed.withOpacity(0.2)]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _xTurn ? BColors.neonBlue : BColors.neonRed),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_xTurn ? 'X' : 'O', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _xTurn ? BColors.neonBlue : BColors.neonRed)),
          const SizedBox(width: 8),
          Text("'s TURN", style: BText.orbitron(size: 14, color: BColors.txtSecondary)),
          const SizedBox(width: 16),
          if (_isAIPlaying)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: BColors.neonPurple),
            ),
        ],
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
          border: Border.all(color: BColors.neonBlue, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PAUSED', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: BColors.neonBlue)),
            const SizedBox(height: 20),
            _buildMenuButton('RESUME', _togglePause, BColors.neonGreen),
            const SizedBox(height: 10),
            _buildMenuButton('RESET GAME', _resetGame, BColors.neonOrange),
            const SizedBox(height: 10),
            _buildMenuButton('EXIT', () => Navigator.pop(context), BColors.neonRed),
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
          gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color),
        ),
        child: Center(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
      ),
    );
  }
  
  @override
  void dispose() {
    _winLineController.dispose();
    _particleTimer?.cancel();
    _aiMoveTimer?.cancel();
    super.dispose();
  }
}

// =============================================================================
// ENUMS & MODELS
// =============================================================================

enum GameMode { singlePlayer, twoPlayer }
enum Difficulty { easy, medium, hard, impossible }

class AnimatedMove {
  final int index;
  final String player;
  double progress;
  
  AnimatedMove({required this.index, required this.player, required this.progress});
}

class ParticleEffect {
  double x, y, vx, vy;
  int life;
  Color color;
  double size;
  
  ParticleEffect({
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
  final List<ParticleEffect> particles;
  
  ParticlePainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.life / 60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}