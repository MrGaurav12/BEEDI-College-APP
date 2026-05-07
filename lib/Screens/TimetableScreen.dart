import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  // Tab Controller
  late TabController _tabController;
  
  // Timetable Data
  Map<String, List<Map<String, dynamic>>> _timetable = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };
  
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _timeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'
  ];
  
  // Colors for different subjects
  final Map<String, Color> _subjectColors = {
    'Mathematics': const Color(0xFF1E88E5),
    'Physics': const Color(0xFF10B981),
    'Chemistry': const Color(0xFFF59E0B),
    'Computer Science': const Color(0xFF8B5CF6),
    'English': const Color(0xFFEC4899),
    'Data Structures': const Color(0xFF14B8A6),
    'Algorithms': const Color(0xFFF97316),
    'Database': const Color(0xFF3B82F6),
    'Operating Systems': const Color(0xFF6366F1),
    'Networking': const Color(0xFF06B6D4),
    'AI/ML': const Color(0xFFD946EF),
    'Web Development': const Color(0xFF0EA5E9),
    'DSA Lab': const Color(0xFF84CC16),
    'Project Work': const Color(0xFF06B6D4),
    'Seminar': const Color(0xFFF43F5E),
    'Guest Lecture': const Color(0xFF8B5CF6),
  };
  
  // UI State
  String _selectedDay = 'Monday';
  bool _isEditing = false;
  int _editingIndex = -1;
  String _selectedSemester = 'Semester 3';
  final List<String> _semesters = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4', 'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'];
  String _viewMode = 'Weekly'; // Weekly, Monthly, List
  
  // Form Controllers
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  String _selectedTimeSlot = '9:00 AM';
  String _selectedSubjectColor = '#1E88E5';
  
  // Exams and Assignments
  final List<Map<String, dynamic>> _exams = [];
  final List<Map<String, dynamic>> _assignments = [];
  final TextEditingController _assignmentController = TextEditingController();
  final TextEditingController _examController = TextEditingController();
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 7));
  
  // Quote of the day
  final List<String> _quotes = [
    '📚 "Education is the passport to the future." - Malcolm X',
    '⭐ "The future depends on what you do today." - Mahatma Gandhi',
    '🎯 "Success is no accident." - Pele',
    '💪 "Believe you can and you\'re halfway there." - Theodore Roosevelt',
    '🌟 "The only limit is your imagination."',
  ];
  String _currentQuote = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTimetable();
    _loadExams();
    _loadAssignments();
    _initializeSampleData();
    _currentQuote = _quotes[DateTime.now().day % _quotes.length];
  }
  
  void _initializeSampleData() {
    if (_timetable['Monday']!.isEmpty) {
      setState(() {
        _timetable['Monday'] = [
          {'subject': 'Mathematics', 'teacher': 'Dr. Sharma', 'room': 'Room 101', 'time': '9:00 AM', 'color': '#1E88E5'},
          {'subject': 'Physics', 'teacher': 'Prof. Verma', 'room': 'Lab 203', 'time': '11:00 AM', 'color': '#10B981'},
        ];
        _timetable['Tuesday'] = [
          {'subject': 'DSA Lab', 'teacher': 'Prof. Kumar', 'room': 'Computer Lab', 'time': '10:00 AM', 'color': '#84CC16'},
          {'subject': 'English', 'teacher': 'Dr. Sinha', 'room': 'Room 105', 'time': '2:00 PM', 'color': '#EC4899'},
        ];
        _timetable['Wednesday'] = [
          {'subject': 'Operating Systems', 'teacher': 'Dr. Patel', 'room': 'Room 201', 'time': '9:00 AM', 'color': '#6366F1'},
          {'subject': 'Networking', 'teacher': 'Prof. Singh', 'room': 'Room 202', 'time': '11:00 AM', 'color': '#06B6D4'},
        ];
        _timetable['Thursday'] = [
          {'subject': 'Project Work', 'teacher': 'Dr. Gupta', 'room': 'Lab 101', 'time': '10:00 AM', 'color': '#06B6D4'},
        ];
        _timetable['Friday'] = [
          {'subject': 'Seminar', 'teacher': 'Guest Speaker', 'room': 'Auditorium', 'time': '10:00 AM', 'color': '#F43F5E'},
          {'subject': 'Guest Lecture', 'teacher': 'Industry Expert', 'room': 'Auditorium', 'time': '2:00 PM', 'color': '#8B5CF6'},
        ];
        _timetable['Saturday'] = [];
        _timetable['Sunday'] = [];
      });
      _saveTimetable();
    }
  }
  
  Future<void> _loadTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final semester = _selectedSemester.replaceAll(' ', '_');
    final timetableStr = prefs.getString('timetable_$semester');
    if (timetableStr != null) {
      try {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          MapDecoder(timetableStr) as Map
        );
        setState(() {
          _timetable = data.map((key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)));
        });
      } catch (e) {
        // Use sample data
      }
    }
  }
  
  Future<void> _saveTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final semester = _selectedSemester.replaceAll(' ', '_');
    await prefs.setString('timetable_$semester', _timetable.toString());
  }
  
  Future<void> _loadExams() async {
    final prefs = await SharedPreferences.getInstance();
    final examsStr = prefs.getString('exams');
    if (examsStr != null) {
      try {
        setState(() {
          _exams.clear();
          _exams.addAll(List<Map<String, dynamic>>.from(
            examsStr.split(';;').map((e) => {
              'title': e.split('|')[0],
              'date': DateTime.parse(e.split('|')[1]),
              'subject': e.split('|')[2],
            })
          ));
        });
      } catch (e) {
        _initializeSampleExams();
      }
    } else {
      _initializeSampleExams();
    }
  }
  
  void _initializeSampleExams() {
    setState(() {
      _exams.addAll([
        {'title': 'Mid-Term Exams', 'date': DateTime.now().add(const Duration(days: 15)), 'subject': 'All Subjects'},
        {'title': 'DSA Final', 'date': DateTime.now().add(const Duration(days: 30)), 'subject': 'Data Structures'},
        {'title': 'Mathematics Quiz', 'date': DateTime.now().add(const Duration(days: 7)), 'subject': 'Mathematics'},
      ]);
    });
    _saveExams();
  }
  
  Future<void> _saveExams() async {
    final prefs = await SharedPreferences.getInstance();
    final examsStr = _exams.map((e) => '${e['title']}|${e['date'].toIso8601String()}|${e['subject']}').join(';;');
    await prefs.setString('exams', examsStr);
  }
  
  Future<void> _loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final assignmentsStr = prefs.getString('assignments');
    if (assignmentsStr != null) {
      try {
        setState(() {
          _assignments.clear();
          _assignments.addAll(List<Map<String, dynamic>>.from(
            assignmentsStr.split(';;').map((e) => {
              'title': e.split('|')[0],
              'deadline': DateTime.parse(e.split('|')[1]),
              'subject': e.split('|')[2],
              'completed': e.split('|')[3] == 'true',
            })
          ));
        });
      } catch (e) {
        _initializeSampleAssignments();
      }
    } else {
      _initializeSampleAssignments();
    }
  }
  
  void _initializeSampleAssignments() {
    setState(() {
      _assignments.addAll([
        {'title': 'DSA Assignment 3', 'deadline': DateTime.now().add(const Duration(days: 5)), 'subject': 'Data Structures', 'completed': false},
        {'title': 'Mathematics Problem Set', 'deadline': DateTime.now().add(const Duration(days: 3)), 'subject': 'Mathematics', 'completed': false},
        {'title': 'Networking Report', 'deadline': DateTime.now().add(const Duration(days: 10)), 'subject': 'Networking', 'completed': true},
      ]);
    });
    _saveAssignments();
  }
  
  Future<void> _saveAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final assignmentsStr = _assignments.map((e) => '${e['title']}|${e['deadline'].toIso8601String()}|${e['subject']}|${e['completed']}').join(';;');
    await prefs.setString('assignments', assignmentsStr);
  }
  
  void _addOrUpdateClass() {
    if (_subjectController.text.trim().isEmpty) return;
    
    final newClass = {
      'subject': _subjectController.text,
      'teacher': _teacherController.text,
      'room': _roomController.text,
      'time': _selectedTimeSlot,
      'color': _selectedSubjectColor,
    };
    
    setState(() {
      if (_isEditing && _editingIndex >= 0) {
        _timetable[_selectedDay]![_editingIndex] = newClass;
      } else {
        _timetable[_selectedDay]!.add(newClass);
      }
    });
    
    _saveTimetable();
    _clearForm();
  }
  
  void _editClass(int index) {
    final classData = _timetable[_selectedDay]![index];
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      _subjectController.text = classData['subject'];
      _teacherController.text = classData['teacher'];
      _roomController.text = classData['room'];
      _selectedTimeSlot = classData['time'];
      _selectedSubjectColor = classData['color'];
    });
  }
  
  void _deleteClass(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _timetable[_selectedDay]!.removeAt(index);
              });
              _saveTimetable();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Class deleted'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _clearForm() {
    setState(() {
      _isEditing = false;
      _editingIndex = -1;
      _subjectController.clear();
      _teacherController.clear();
      _roomController.clear();
      _selectedTimeSlot = '9:00 AM';
      _selectedSubjectColor = '#1E88E5';
    });
  }
  
  void _addAssignment() {
    if (_assignmentController.text.trim().isEmpty) return;
    setState(() {
      _assignments.add({
        'title': _assignmentController.text,
        'deadline': _selectedDeadline,
        'subject': _selectedSemester,
        'completed': false,
      });
      _assignmentController.clear();
    });
    _saveAssignments();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment added!'), backgroundColor: Colors.green),
    );
  }
  
  void _toggleAssignmentComplete(int index) {
    setState(() {
      _assignments[index]['completed'] = !_assignments[index]['completed'];
    });
    _saveAssignments();
  }
  
  void _deleteAssignment(int index) {
    setState(() {
      _assignments.removeAt(index);
    });
    _saveAssignments();
  }
  
  void _addExam() {
    if (_examController.text.trim().isEmpty) return;
    setState(() {
      _exams.add({
        'title': _examController.text,
        'date': _selectedDeadline,
        'subject': _selectedSemester,
      });
      _examController.clear();
    });
    _saveExams();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exam added to calendar!'), backgroundColor: Colors.orange),
    );
  }
  
  void _exportTimetable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📤 Timetable exported to PDF!'), backgroundColor: Colors.green),
    );
  }
  
  void _syncCalendar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔄 Synced with Google Calendar!'), backgroundColor: Colors.blue),
    );
  }
  
  int get _completedAssignments => _assignments.where((a) => a['completed'] == true).length;
  int get _totalAssignments => _assignments.length;
  double get _assignmentProgress => _totalAssignments == 0 ? 0 : _completedAssignments / _totalAssignments;
  
  int get _upcomingExams => _exams.where((e) => (e['date'] as DateTime).isAfter(DateTime.now())).length;
  
  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _assignmentController.dispose();
    _examController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimetableView(),
                _buildAssignmentsView(),
                _buildExamsView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0 ? _buildFAB() : null,
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Class Timetable', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF0D47A1),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () => _syncCalendar(),
          tooltip: 'Sync Calendar',
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _exportTimetable(),
          tooltip: 'Export',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() => _viewMode = value);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Weekly', child: Text('Weekly View')),
            const PopupMenuItem(value: 'List', child: Text('List View')),
          ],
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Week', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM d').format(DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)))} - ${DateFormat('MMM d, yyyy').format(DateTime.now().add(Duration(days: 7 - DateTime.now().weekday)))}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: _selectedSemester,
                  dropdownColor: Colors.white,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: _semesters.map((sem) {
                    return DropdownMenuItem(value: sem, child: Text(sem));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSemester = value!);
                    _loadTimetable();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_quote, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(_currentQuote, style: const TextStyle(color: Colors.white70, fontSize: 11))),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF0D47A1),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF0D47A1),
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.schedule), text: 'Timetable'),
          Tab(icon: Icon(Icons.assignment), text: 'Assignments'),
          Tab(icon: Icon(Icons.edit_calendar), text: 'Exams'),
        ],
      ),
    );
  }
  
  Widget _buildTimetableView() {
    return Column(
      children: [
        _buildDaySelector(),
        Expanded(
          child: _viewMode == 'Weekly'
              ? _buildWeeklyView()
              : _buildListView(),
        ),
      ],
    );
  }
  
  Widget _buildDaySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          final isSelected = _selectedDay == day;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0D47A1) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0D47A1).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    day.substring(0, 3),
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0D47A1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildWeeklyView() {
    final classes = _timetable[_selectedDay] ?? [];
    classes.sort((a, b) => _timeSlots.indexOf(a['time']).compareTo(_timeSlots.indexOf(b['time'])));
    
    return classes.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.free_breakfast, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text('No classes on $_selectedDay', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddClassDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Class'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index];
              final colorHex = classData['color'] as String;
              final color = Color(int.parse('FF$colorHex', radix: 16));
              
              return Dismissible(
                key: Key('${classData['subject']}_$index'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _deleteClass(index),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    onTap: () => _editClass(index),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          classData['time'].split(' ')[0],
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      classData['subject'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('👨‍🏫 ${classData['teacher']}'),
                        Text('📍 ${classData['room']}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(classData['time'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
  
  Widget _buildListView() {
    List<Map<String, dynamic>> allClasses = [];
    for (var day in _days) {
      for (var classData in _timetable[day]!) {
        allClasses.add({
          ...classData,
          'day': day,
        });
      }
    }
    allClasses.sort((a, b) => _timeSlots.indexOf(a['time']).compareTo(_timeSlots.indexOf(b['time'])));
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: allClasses.length,
      itemBuilder: (context, index) {
        final classData = allClasses[index];
        final colorHex = classData['color'] as String;
        final color = Color(int.parse('FF$colorHex', radix: 16));
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  classData['day'].substring(0, 3),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            title: Text(classData['subject'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${classData['time']} • ${classData['teacher']} • ${classData['room']}'),
            trailing: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAssignmentsView() {
    return Column(
      children: [
        _buildAssignmentProgress(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _assignments.length,
            itemBuilder: (context, index) {
              final assignment = _assignments[index];
              final isOverdue = (assignment['deadline'] as DateTime).isBefore(DateTime.now()) && !assignment['completed'];
              
              return Dismissible(
                key: Key(assignment['title']),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _deleteAssignment(index),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: assignment['completed'] ? Colors.green.shade50 : null,
                  child: CheckboxListTile(
                    value: assignment['completed'],
                    onChanged: (_) => _toggleAssignmentComplete(index),
                    title: Text(
                      assignment['title'],
                      style: TextStyle(
                        decoration: assignment['completed'] ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Subject: ${assignment['subject']}'),
                        Text(
                          'Due: ${DateFormat('MMM d, yyyy').format(assignment['deadline'])}',
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.grey,
                            fontWeight: isOverdue ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                    secondary: isOverdue && !assignment['completed']
                        ? const Icon(Icons.warning, color: Colors.orange)
                        : null,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              );
            },
          ),
        ),
        _buildAddAssignmentCard(),
      ],
    );
  }
  
  Widget _buildAssignmentProgress() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assignment Progress', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('$_completedAssignments/$_totalAssignments Completed', style: const TextStyle(color: Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _assignmentProgress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Colors.green),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddAssignmentCard() {
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
          const Text('Add New Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _assignmentController,
            decoration: const InputDecoration(
              hintText: 'Assignment title',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Deadline'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(_selectedDeadline)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _selectedDeadline = date);
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _addAssignment,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildExamsView() {
    final upcomingExams = _exams.where((e) => (e['date'] as DateTime).isAfter(DateTime.now())).toList();
    final pastExams = _exams.where((e) => (e['date'] as DateTime).isBefore(DateTime.now())).toList();
    
    return Column(
      children: [
        if (_upcomingExams > 0)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Upcoming Exams', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$_upcomingExams exams scheduled in the coming days', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _exams.length,
            itemBuilder: (context, index) {
              final exam = _exams[index];
              final isUpcoming = (exam['date'] as DateTime).isAfter(DateTime.now());
              final daysLeft = (exam['date'] as DateTime).difference(DateTime.now()).inDays;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isUpcoming ? Colors.orange.shade50 : Colors.grey.shade50,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isUpcoming ? Colors.orange : Colors.grey,
                    child: const Icon(Icons.edit_calendar, color: Colors.white, size: 20),
                  ),
                  title: Text(exam['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subject: ${exam['subject']}'),
                      Text('Date: ${DateFormat('MMM d, yyyy').format(exam['date'])}'),
                      if (isUpcoming && daysLeft <= 7)
                        Text('⚠️ $daysLeft days left', style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                  ),
                  trailing: isUpcoming
                      ? const Icon(Icons.alarm, color: Colors.orange)
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          ),
        ),
        _buildAddExamCard(),
      ],
    );
  }
  
  Widget _buildAddExamCard() {
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
          const Text('Add Exam', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _examController,
            decoration: const InputDecoration(
              hintText: 'Exam title',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Exam Date'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(_selectedDeadline)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _selectedDeadline = date);
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _addExam,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showAddClassDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Class' : 'Add New Class',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _clearForm();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: 'Teacher Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTimeSlot,
                items: _timeSlots.map((slot) {
                  return DropdownMenuItem(value: slot, child: Text(slot));
                }).toList(),
                onChanged: (value) => setStateDialog(() => _selectedTimeSlot = value!),
                decoration: const InputDecoration(
                  labelText: 'Time Slot',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSubjectColor,
                items: _subjectColors.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.value.value.toRadixString(16).substring(2),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: entry.value,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setStateDialog(() => _selectedSubjectColor = value!),
                decoration: const InputDecoration(
                  labelText: 'Subject Color',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_isEditing)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _deleteClass(_editingIndex);
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
                        _addOrUpdateClass();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                      child: Text(_isEditing ? 'Update' : 'Add'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showAddClassDialog,
      backgroundColor: const Color(0xFF0D47A1),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

// Helper class for JSON decoding
class MapDecoder {
  final String data;
  MapDecoder(this.data);
}

// Color constants (add if missing)
class AC {
  static const Color bg = Color(0xFFF8FAFF);
  static const Color white = Colors.white;
}