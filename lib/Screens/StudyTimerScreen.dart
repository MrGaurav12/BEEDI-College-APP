import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Color constants (using existing AC class or define if missing)
class AC {
  static const Color bg = Color(0xFFF8FAFF);
  static const Color white = Colors.white;
  static const Color blue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFF1565C0);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color green = Color(0xFF10B981);
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFF1F5F9);
  static const Color darkGrey = Color(0xFF334155);
}

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen>
    with SingleTickerProviderStateMixin {
  // Timer State
  Timer? _timer;
  int _currentDuration = 25 * 60; // 25 minutes in seconds
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _pomodoroCount = 0;
  
  // Session Tracking
  int _todayStudyHours = 0;
  int _totalStudyHours = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  List<DateTime> _studyDays = [];
  
  // Animation Controllers
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  
  // Settings
  int _focusDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  int _pomodorosUntilLongBreak = 4;
  bool _autoStartBreaks = true;
  bool _autoStartPomodoros = true;
  bool _soundEnabled = true;
  String _selectedTheme = 'Blue';
  
  // Statistics
  final List<int> _weeklyStudyHours = [0, 0, 0, 0, 0, 0, 0];
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // Task List
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  
  // Quotes for motivation
  final List<String> _motivationalQuotes = [
    '🌟 "The future depends on what you do today." - Mahatma Gandhi',
    '📚 "Education is the most powerful weapon." - Nelson Mandela',
    '💪 "Success is no accident." - Pele',
    '🎯 "Dream it. Wish it. Do it."',
    '🔥 "Stay focused, stay determined."',
    '⭐ "Small progress is still progress."',
  ];
  String _currentQuote = '';

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _setupAnimations();
    _currentQuote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
    _updateWeeklyData();
  }
  
  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalStudyHours = prefs.getInt('totalStudyHours') ?? 0;
      _currentStreak = prefs.getInt('currentStreak') ?? 0;
      _longestStreak = prefs.getInt('longestStreak') ?? 0;
      _focusDuration = prefs.getInt('focusDuration') ?? 25;
      _shortBreakDuration = prefs.getInt('shortBreakDuration') ?? 5;
      _longBreakDuration = prefs.getInt('longBreakDuration') ?? 15;
      _pomodorosUntilLongBreak = prefs.getInt('pomodorosUntilLongBreak') ?? 4;
      _autoStartBreaks = prefs.getBool('autoStartBreaks') ?? true;
      _autoStartPomodoros = prefs.getBool('autoStartPomodoros') ?? true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _selectedTheme = prefs.getString('timerTheme') ?? 'Blue';
      
      // Load study days
      final daysStr = prefs.getStringList('studyDays') ?? [];
      _studyDays = daysStr.map((d) => DateTime.parse(d)).toList();
    });
    _updateCurrentDuration();
  }
  
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalStudyHours', _totalStudyHours);
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setInt('longestStreak', _longestStreak);
    await prefs.setInt('focusDuration', _focusDuration);
    await prefs.setInt('shortBreakDuration', _shortBreakDuration);
    await prefs.setInt('longBreakDuration', _longBreakDuration);
    await prefs.setInt('pomodorosUntilLongBreak', _pomodorosUntilLongBreak);
    await prefs.setBool('autoStartBreaks', _autoStartBreaks);
    await prefs.setBool('autoStartPomodoros', _autoStartPomodoros);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setString('timerTheme', _selectedTheme);
    
    final daysStr = _studyDays.map((d) => d.toIso8601String()).toList();
    await prefs.setStringList('studyDays', daysStr);
  }
  
  void _updateCurrentDuration() {
    if (_isBreak) {
      int breakDuration = _pomodoroCount % _pomodorosUntilLongBreak == 0 && _pomodoroCount > 0
          ? _longBreakDuration
          : _shortBreakDuration;
      _currentDuration = breakDuration * 60;
    } else {
      _currentDuration = _focusDuration * 60;
    }
    if (!_isRunning) {
      setState(() => _remainingSeconds = _currentDuration);
    }
  }
  
  void _startTimer() {
    if (_timer != null) _timer!.cancel();
    _isRunning = true;
    _pulseController.repeat(reverse: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else if (_remainingSeconds == 0) {
        _onTimerComplete();
      }
    });
  }
  
  void _pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    _pulseController.stop();
    setState(() {});
  }
  
  void _resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _pulseController.stop();
    setState(() {
      _remainingSeconds = _currentDuration;
    });
  }
  
  void _onTimerComplete() async {
    _timer?.cancel();
    _isRunning = false;
    _pulseController.stop();
    
    if (!_isBreak) {
      // Study session completed
      setState(() {
        _pomodoroCount++;
        _todayStudyHours += _focusDuration;
        _totalStudyHours += _focusDuration;
      });
      
      // Update streak
      await _updateStreak();
      _updateWeeklyData();
      await _saveData();
      
      // Show completion dialog
      _showCompletionDialog();
      
      if (_autoStartBreaks) {
        setState(() => _isBreak = true);
        _updateCurrentDuration();
        _startTimer();
      }
    } else {
      setState(() => _isBreak = false);
      _updateCurrentDuration();
      if (_autoStartPomodoros) {
        _startTimer();
      }
    }
    
    setState(() {});
  }
  
  Future<void> _updateStreak() async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (!_studyDays.any((d) => d.year == today.year && d.month == today.month && d.day == today.day)) {
      _studyDays.add(today);
      
      // Check if studied yesterday
      if (_studyDays.any((d) => d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day)) {
        _currentStreak++;
      } else {
        _currentStreak = 1;
      }
      
      if (_currentStreak > _longestStreak) {
        _longestStreak = _currentStreak;
      }
    }
  }
  
  void _updateWeeklyData() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      _weeklyStudyHours[i] = _studyDays
          .where((d) => d.year == day.year && d.month == day.month && d.day == day.day)
          .length * _focusDuration;
    }
    setState(() {});
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.celebration, color: AC.green),
            const SizedBox(width: 10),
            const Text('Pomodoro Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎉 You completed ${_focusDuration} minutes of focused study!'),
            const SizedBox(height: 10),
            Text('Total today: $_todayStudyHours hours'),
            Text('Current streak: $_currentStreak days 🔥'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
  
  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  double get _progressValue => 1 - (_remainingSeconds / _currentDuration);
  
  Color get _timerColor {
    switch (_selectedTheme) {
      case 'Blue': return AC.blue;
      case 'Green': return AC.green;
      case 'Purple': return AC.purple;
      case 'Orange': return AC.orange;
      default: return AC.blue;
    }
  }
  
  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;
    setState(() {
      _tasks.add({
        'title': _taskController.text,
        'completed': false,
        'createdAt': DateTime.now(),
      });
      _taskController.clear();
    });
  }
  
  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
    });
  }
  
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        title: const Text('Study Timer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: _timerColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_timerColor.withOpacity(0.1), AC.bg],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Timer Circle
              Container(
                margin: const EdgeInsets.all(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: _progressValue,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isBreak ? '🍵 Break Time' : '📚 Focus Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _timerColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) => Transform.scale(
                            scale: _isRunning ? _scaleAnimation.value : 1.0,
                            child: Text(
                              _formattedTime,
                              style: const TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Pomodoro #${_pomodoroCount + 1}',
                          style: const TextStyle(fontSize: 14, color: AC.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Timer Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: _isRunning ? Icons.pause : Icons.play_arrow,
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    color: _timerColor,
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: Icons.refresh,
                    onPressed: _resetTimer,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: Icons.skip_next,
                    onPressed: _onTimerComplete,
                    color: AC.purple,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Session Type Indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isBreak && !_isRunning) {
                            setState(() => _isBreak = false);
                            _updateCurrentDuration();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isBreak ? _timerColor : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Focus',
                              style: TextStyle(
                                color: !_isBreak ? Colors.white : AC.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_isBreak && !_isRunning) {
                            setState(() => _isBreak = true);
                            _updateCurrentDuration();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isBreak ? _timerColor : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Break',
                              style: TextStyle(
                                color: _isBreak ? Colors.white : AC.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Statistics Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '🎯',
                        'Today',
                        '$_todayStudyHours hrs',
                        AC.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '📊',
                        'Total',
                        '$_totalStudyHours hrs',
                        AC.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '🔥',
                        'Streak',
                        '$_currentStreak days',
                        AC.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Weekly Progress Chart
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Progress',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _weeklyStudyHours.isEmpty ? 10 : (_weeklyStudyHours.reduce((a, b) => a > b ? a : b).toDouble() + 1).clamp(1, 100),
                          barGroups: List.generate(7, (index) {
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: _weeklyStudyHours[index].toDouble(),
                                  color: _timerColor,
                                  width: 30,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(_weekDays[value.toInt()], style: const TextStyle(fontSize: 10));
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Motivational Quote
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_timerColor, _timerColor.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.format_quote, color: Colors.white, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      _currentQuote,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentQuote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
                        });
                      },
                      child: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Task List
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Study Tasks',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            decoration: InputDecoration(
                              hintText: 'Add a task...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AC.lightGrey,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: (_) => _addTask(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addTask,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _timerColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Dismissible(
                          key: Key(task['createdAt'].toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteTask(index),
                          background: Container(
                            color: AC.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: task['completed'],
                              onChanged: (_) => _toggleTask(index),
                              activeColor: AC.green,
                            ),
                            title: Text(
                              task['title'],
                              style: TextStyle(
                                decoration: task['completed'] ? TextDecoration.lineThrough : null,
                                color: task['completed'] ? AC.grey : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_tasks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text('No tasks yet. Add your study goals!', style: TextStyle(color: AC.grey)),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed, required Color color}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
  
  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AC.grey)),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Timer Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildSettingSlider(
                'Focus Duration: $_focusDuration min',
                _focusDuration.toDouble(),
                1, 60,
                (v) => setStateDialog(() => _focusDuration = v.round()),
              ),
              _buildSettingSlider(
                'Short Break: $_shortBreakDuration min',
                _shortBreakDuration.toDouble(),
                1, 15,
                (v) => setStateDialog(() => _shortBreakDuration = v.round()),
              ),
              _buildSettingSlider(
                'Long Break: $_longBreakDuration min',
                _longBreakDuration.toDouble(),
                1, 30,
                (v) => setStateDialog(() => _longBreakDuration = v.round()),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Auto-start Breaks'),
                value: _autoStartBreaks,
                onChanged: (v) => setStateDialog(() => _autoStartBreaks = v),
              ),
              SwitchListTile(
                title: const Text('Auto-start Pomodoros'),
                value: _autoStartPomodoros,
                onChanged: (v) => setStateDialog(() => _autoStartPomodoros = v),
              ),
              SwitchListTile(
                title: const Text('Sound Notifications'),
                value: _soundEnabled,
                onChanged: (v) => setStateDialog(() => _soundEnabled = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _updateCurrentDuration();
                  _resetTimer();
                  _saveData();
                  Navigator.pop(context);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _timerColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSettingSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            activeColor: _timerColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _taskController.dispose();
    super.dispose();
  }
}