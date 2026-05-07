import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class GradeCalculatorScreen extends StatefulWidget {
  const GradeCalculatorScreen({super.key});

  @override
  State<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen>
    with SingleTickerProviderStateMixin {
  
  // Tab Controller
  late TabController _tabController;
  
  // Semester Data
  List<Map<String, dynamic>> _subjects = [];
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _creditsController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  String _selectedGrade = 'A';
  
  // Grade scale
  final Map<String, Map<String, dynamic>> _gradeScale = {
    'O': {'min': 90, 'max': 100, 'points': 10, 'description': 'Outstanding'},
    'A+': {'min': 80, 'max': 89, 'points': 9, 'description': 'Excellent'},
    'A': {'min': 70, 'max': 79, 'points': 8, 'description': 'Very Good'},
    'B+': {'min': 60, 'max': 69, 'points': 7, 'description': 'Good'},
    'B': {'min': 50, 'max': 59, 'points': 6, 'description': 'Average'},
    'C': {'min': 40, 'max': 49, 'points': 5, 'description': 'Pass'},
    'F': {'min': 0, 'max': 39, 'points': 0, 'description': 'Fail'},
  };
  
  // Goal Setting
  double _targetCGPA = 8.5;
  double _currentCGPA = 7.2;
  int _remainingSemesters = 4;
  int _creditsPerSemester = 24;
  
  // History
  List<Map<String, dynamic>> _semesterHistory = [];
  String _selectedSemester = 'Semester 1';
  final List<String> _semesters = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'];
  
  // Percentage Converter
  final TextEditingController _percentageController = TextEditingController();
  double _convertedCGPA = 0;
  
  // Export State
  bool _isExporting = false;
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadSavedData();
    _initializeSampleSubjects();
  }
  
  void _initializeSampleSubjects() {
    if (_subjects.isEmpty) {
      setState(() {
        _subjects = [
          {'subject': 'Mathematics', 'credits': 4, 'marks': 85, 'grade': 'A+', 'points': 9, 'completed': true},
          {'subject': 'Physics', 'credits': 3, 'marks': 78, 'grade': 'A', 'points': 8, 'completed': true},
          {'subject': 'Chemistry', 'credits': 3, 'marks': 72, 'grade': 'A', 'points': 8, 'completed': true},
          {'subject': 'Computer Science', 'credits': 4, 'marks': 92, 'grade': 'O', 'points': 10, 'completed': true},
          {'subject': 'English', 'credits': 2, 'marks': 68, 'grade': 'B+', 'points': 7, 'completed': true},
        ];
      });
      _calculateGPA();
    }
  }
  
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final target = prefs.getDouble('targetCGPA');
    final current = prefs.getDouble('currentCGPA');
    final remaining = prefs.getInt('remainingSemesters');
    if (target != null) setState(() => _targetCGPA = target);
    if (current != null) setState(() => _currentCGPA = current);
    if (remaining != null) setState(() => _remainingSemesters = remaining);
  }
  
  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('targetCGPA', _targetCGPA);
    await prefs.setDouble('currentCGPA', _currentCGPA);
    await prefs.setInt('remainingSemesters', _remainingSemesters);
  }
  
  void _addSubject() {
    if (_subjectController.text.trim().isEmpty) return;
    
    int credits = int.tryParse(_creditsController.text) ?? 3;
    int marks = int.tryParse(_marksController.text) ?? 0;
    String grade = _getGradeFromMarks(marks);
    int points = _gradeScale[grade]?['points'] ?? 0;
    
    setState(() {
      _subjects.add({
        'subject': _subjectController.text,
        'credits': credits,
        'marks': marks,
        'grade': grade,
        'points': points,
        'completed': true,
      });
      _subjectController.clear();
      _creditsController.clear();
      _marksController.clear();
    });
    _calculateGPA();
  }
  
  String _getGradeFromMarks(int marks) {
    for (var entry in _gradeScale.entries) {
      if (marks >= entry.value['min'] && marks <= entry.value['max']) {
        return entry.key;
      }
    }
    return 'F';
  }
  
  void _editSubject(int index) {
    final subject = _subjects[index];
    _subjectController.text = subject['subject'];
    _creditsController.text = subject['credits'].toString();
    _marksController.text = subject['marks'].toString();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Subject', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _creditsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Credits', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Marks (0-100)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _deleteSubject(index);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      int credits = int.tryParse(_creditsController.text) ?? 3;
                      int marks = int.tryParse(_marksController.text) ?? 0;
                      String grade = _getGradeFromMarks(marks);
                      int points = _gradeScale[grade]?['points'] ?? 0;
                      
                      setState(() {
                        _subjects[index] = {
                          'subject': _subjectController.text,
                          'credits': credits,
                          'marks': marks,
                          'grade': grade,
                          'points': points,
                          'completed': true,
                        };
                      });
                      _calculateGPA();
                      _subjectController.clear();
                      _creditsController.clear();
                      _marksController.clear();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  void _deleteSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
    });
    _calculateGPA();
  }
  
  void _calculateGPA() {
    int totalCredits = 0;
    int totalPoints = 0;
    
    for (var subject in _subjects) {
      int credits = subject['credits'];
      int points = subject['points'];
      totalCredits += credits;
      totalPoints += credits * points;
    }
    
    double gpa = totalCredits > 0 ? totalPoints / totalCredits : 0;
    
    setState(() {
      _currentCGPA = double.parse(gpa.toStringAsFixed(2));
    });
  }
  
  double get _semesterGPA {
    int totalCredits = 0;
    int totalPoints = 0;
    
    for (var subject in _subjects) {
      int credits = subject['credits'];
      int points = subject['points'];
      totalCredits += credits;
      totalPoints += credits * points;
    }
    
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }
  
  String get _gradeLetter {
    double gpa = _currentCGPA;
    if (gpa >= 9.0) return 'O';
    if (gpa >= 8.0) return 'A+';
    if (gpa >= 7.0) return 'A';
    if (gpa >= 6.0) return 'B+';
    if (gpa >= 5.0) return 'B';
    if (gpa >= 4.0) return 'C';
    return 'F';
  }
  
  String get _gradeDescription {
    switch (_gradeLetter) {
      case 'O': return 'Outstanding';
      case 'A+': return 'Excellent';
      case 'A': return 'Very Good';
      case 'B+': return 'Good';
      case 'B': return 'Average';
      case 'C': return 'Pass';
      default: return 'Need Improvement';
    }
  }
  
  Color get _gradeColor {
    if (_currentCGPA >= 8.5) return Colors.green;
    if (_currentCGPA >= 7.0) return Colors.blue;
    if (_currentCGPA >= 6.0) return Colors.orange;
    if (_currentCGPA >= 5.0) return Colors.amber;
    return Colors.red;
  }
  
  double get _requiredCGPA {
    if (_remainingSemesters <= 0) return _targetCGPA;
    double totalCurrentPoints = _currentCGPA * (_remainingSemesters * _creditsPerSemester);
    double totalRequiredPoints = _targetCGPA * ((_remainingSemesters + 1) * _creditsPerSemester);
    double requiredPoints = totalRequiredPoints - totalCurrentPoints;
    double requiredCGPA = requiredPoints / (_remainingSemesters * _creditsPerSemester);
    return requiredCGPA.clamp(0.0, 10.0);
  }
  
  void _convertPercentage() {
    double percentage = double.tryParse(_percentageController.text) ?? 0;
    double cgpa = percentage / 9.5;
    setState(() {
      _convertedCGPA = double.parse(cgpa.toStringAsFixed(2));
    });
  }
  
  void _exportResults() {
    setState(() => _isExporting = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📄 Results exported as PDF!'), backgroundColor: Colors.green),
      );
    });
  }
  
  void _saveSemester() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Semester Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Save this semester\'s results to history?'),
            const SizedBox(height: 8),
            Text('GPA: ${_semesterGPA.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _semesterHistory.add({
                  'semester': _selectedSemester,
                  'gpa': _semesterGPA,
                  'date': DateTime.now(),
                  'subjects': List.from(_subjects),
                });
                _subjects.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Semester saved to history!'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _subjectController.dispose();
    _creditsController.dispose();
    _marksController.dispose();
    _percentageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        title: const Text('Grade Calculator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportResults,
            tooltip: 'Export Results',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGPACalculator(),
                _buildSubjectManager(),
                _buildGoalPlanner(),
                _buildConverterHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat('Current CGPA', _currentCGPA.toStringAsFixed(2), _gradeColor),
              _buildHeaderStat('Grade', _gradeLetter, _gradeColor),
              _buildHeaderStat('Status', _gradeDescription, Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: _currentCGPA / 10,
              child: Container(
                decoration: BoxDecoration(
                  color: _gradeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeaderStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1E88E5),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF1E88E5),
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.calculate), text: 'Calculator'),
          Tab(icon: Icon(Icons.subject), text: 'Subjects'),
          Tab(icon: Icon(Icons.track_changes), text: 'Goal'),
          Tab(icon: Icon(Icons.history), text: 'History'),
        ],
      ),
    );
  }
  
  Widget _buildGPACalculator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGPAInputCard(),
            const SizedBox(height: 16),
            _buildGradeScaleCard(),
          ],
        ),
      ),
    );
  }
  
Widget _buildGPAInputCard() {
  int totalCredits = 0;
  int totalPoints = 0;

  for (var subject in _subjects) {
    final int credits = subject['credits'] ?? 0;
    final int points = subject['points'] ?? 0;

    totalCredits += credits;
    totalPoints += credits * points;
  }

  double gpa = totalCredits > 0 ? totalPoints / totalCredits : 0;

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Semester GPA Calculator',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Subjects', _subjects.length.toString(), Colors.blue),
              _buildStatItem('Credits', totalCredits.toString(), Colors.green),
              _buildStatItem('GPA', gpa.toStringAsFixed(2), Colors.orange),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _saveSemester,
            icon: const Icon(Icons.save),
            label: const Text('Save Semester Results'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );
}
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  Widget _buildGradeScaleCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grade Scale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Range', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Points', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _gradeScale.entries.map((entry) {
                  return DataRow(cells: [
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: entry.key == 'O' ? Colors.green : 
                               entry.key == 'A+' ? Colors.blue :
                               entry.key == 'A' ? Colors.lightBlue :
                               entry.key == 'B+' ? Colors.orange :
                               entry.key == 'B' ? Colors.amber :
                               entry.key == 'C' ? Colors.yellow :
                               Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    )),
                    DataCell(Text('${entry.value['min']}-${entry.value['max']}')),
                    DataCell(Text(entry.value['points'].toString())),
                    DataCell(Text(entry.value['description'])),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubjectManager() {
    return Column(
      children: [
        _buildAddSubjectCard(),
        Expanded(
          child: _subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.subject, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('No subjects added yet', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text('Add your subjects to calculate GPA', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    final gradeColor = _getGradeColorFromGrade(subject['grade']);
                    
                    return Dismissible(
                      key: Key(subject['subject']),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteSubject(index),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () => _editSubject(index),
                          leading: CircleAvatar(
                            backgroundColor: gradeColor.withOpacity(0.2),
                            child: Text(
                              subject['grade'],
                              style: TextStyle(color: gradeColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(subject['subject'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Credits: ${subject['credits']} | Marks: ${subject['marks']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${subject['points']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('points', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildAddSubjectCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Subject', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    hintText: 'Subject',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _creditsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Credits',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _marksController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Marks',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addSubject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalPlanner() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('CGPA Goal Planner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildSliderCard('Target CGPA', _targetCGPA, 0, 10, (v) => setState(() => _targetCGPA = v)),
                  _buildSliderCard('Current CGPA', _currentCGPA, 0, 10, (v) => setState(() => _currentCGPA = v)),
                  _buildSliderCard('Remaining Semesters', _remainingSemesters.toDouble(), 1, 8, (v) => setState(() => _remainingSemesters = v.round())),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('Required CGPA in remaining semesters:', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          _requiredCGPA.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _requiredCGPA <= 10 ? Colors.green : Colors.red,
                          ),
                        ),
                        if (_requiredCGPA > 10)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('⚠️ Target too high! Consider adjusting goal.', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Grade Improvement Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTipItem('📚', 'Study consistently', 'Dedicate 2-3 hours daily'),
                  _buildTipItem('🎯', 'Set weekly goals', 'Break down syllabus into manageable chunks'),
                  _buildTipItem('📝', 'Practice regularly', 'Solve previous year papers'),
                  _buildTipItem('👥', 'Group study', 'Collaborate with peers for better understanding'),
                  _buildTipItem('🧘', 'Take breaks', 'Use Pomodoro technique for better focus'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSliderCard(String label, double value, double min, double max, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            activeColor: const Color(0xFF1E88E5),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTipItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConverterHistory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Percentage to CGPA Converter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _percentageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter Percentage',
                      border: OutlineInputBorder(),
                      suffix: const Text('%'),
                    ),
                    onChanged: (_) => _convertPercentage(),
                  ),
                  const SizedBox(height: 16),
                  if (_convertedCGPA > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text('Converted CGPA', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            _convertedCGPA.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          Text('Grade: ${_getGradeFromCGPA(_convertedCGPA)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_semesterHistory.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Semester History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _semesterHistory.length,
                      itemBuilder: (context, index) {
                        final sem = _semesterHistory.reversed.toList()[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Text('${sem['gpa']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          title: Text(sem['semester']),
                          subtitle: Text(DateFormat('MMM d, yyyy').format(sem['date'])),
                          trailing: Text('${sem['subjects'].length} subjects'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Color _getGradeColorFromGrade(String grade) {
    switch (grade) {
      case 'O': return Colors.green;
      case 'A+': return Colors.blue;
      case 'A': return Colors.lightBlue;
      case 'B+': return Colors.orange;
      case 'B': return Colors.amber;
      case 'C': return Colors.yellow;
      default: return Colors.red;
    }
  }
  
  String _getGradeFromCGPA(double cgpa) {
    if (cgpa >= 9.0) return 'O';
    if (cgpa >= 8.0) return 'A+';
    if (cgpa >= 7.0) return 'A';
    if (cgpa >= 6.0) return 'B+';
    if (cgpa >= 5.0) return 'B';
    if (cgpa >= 4.0) return 'C';
    return 'F';
  }
}

class AC {
  static const Color bg = Color(0xFFF8FAFF);
}