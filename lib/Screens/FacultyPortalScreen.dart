import 'package:flutter/material.dart';

class FacultyPortalScreen extends StatefulWidget {
  const FacultyPortalScreen({super.key});

  @override
  State<FacultyPortalScreen> createState() => _FacultyPortalScreenState();
}

class _FacultyPortalScreenState extends State<FacultyPortalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCourseIndex = 0;
  String _selectedDepartment = 'All Departments';
  
  // Faculty Data
  final Map<String, dynamic> _facultyProfile = {
    'name': 'Dr. Sarah Williams',
    'designation': 'Professor & Head of Department',
    'department': 'Computer Science',
    'employeeId': 'FAC2024001',
    'email': 'sarah.williams@beedi.edu',
    'phone': '+91 98765 43210',
    'joinDate': 'January 2020',
    'qualification': 'Ph.D. in Computer Science',
    'specialization': 'AI & Machine Learning',
    'profileImage': null,
  };
  
  // Courses taught
  final List<Map<String, dynamic>> _courses = [
    {
      'id': 'CS301',
      'name': 'Data Structures & Algorithms',
      'semester': 'Semester 5',
      'students': 65,
      'schedule': 'Mon/Wed 10:00 AM - 11:30 AM',
      'room': 'Room 301',
      'attendance': 92,
      'averageGrade': 78.5,
      'assignments': 4,
      'upcomingClasses': 12,
    },
    {
      'id': 'CS405',
      'name': 'Machine Learning',
      'semester': 'Semester 7',
      'students': 45,
      'schedule': 'Tue/Thu 2:00 PM - 3:30 PM',
      'room': 'Lab 405',
      'attendance': 88,
      'averageGrade': 82.3,
      'assignments': 3,
      'upcomingClasses': 10,
    },
    {
      'id': 'CS201',
      'name': 'Object Oriented Programming',
      'semester': 'Semester 3',
      'students': 85,
      'schedule': 'Mon/Wed/Fri 9:00 AM - 10:00 AM',
      'room': 'Room 201',
      'attendance': 85,
      'averageGrade': 76.2,
      'assignments': 5,
      'upcomingClasses': 15,
    },
    {
      'id': 'CS502',
      'name': 'Research Methodology',
      'semester': 'Ph.D. Program',
      'students': 12,
      'schedule': 'Friday 3:00 PM - 5:00 PM',
      'room': 'Seminar Hall',
      'attendance': 95,
      'averageGrade': 88.7,
      'assignments': 2,
      'upcomingClasses': 8,
    },
  ];
  
  // Students list
  final List<Map<String, dynamic>> _students = [
    {'id': 'S001', 'name': 'Alice Johnson', 'attendance': 92, 'performance': 'A', 'grade': 85, 'email': 'alice@beedi.edu'},
    {'id': 'S002', 'name': 'Bob Smith', 'attendance': 78, 'performance': 'B+', 'grade': 78, 'email': 'bob@beedi.edu'},
    {'id': 'S003', 'name': 'Charlie Brown', 'attendance': 95, 'performance': 'A+', 'grade': 92, 'email': 'charlie@beedi.edu'},
    {'id': 'S004', 'name': 'Diana Prince', 'attendance': 88, 'performance': 'A-', 'grade': 86, 'email': 'diana@beedi.edu'},
    {'id': 'S005', 'name': 'Ethan Hunt', 'attendance': 72, 'performance': 'B', 'grade': 74, 'email': 'ethan@beedi.edu'},
  ];
  
  // Upcoming tasks
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Mid-Term Exam Papers', 'deadline': '2024-12-15', 'priority': 'High', 'status': 'Pending'},
    {'title': 'Research Paper Submission', 'deadline': '2024-12-20', 'priority': 'High', 'status': 'In Progress'},
    {'title': 'Faculty Meeting', 'deadline': '2024-12-10', 'priority': 'Medium', 'status': 'Upcoming'},
    {'title': 'Lab Equipment Inventory', 'deadline': '2024-12-25', 'priority': 'Low', 'status': 'Not Started'},
  ];
  
  // Notifications
  final List<Map<String, dynamic>> _notifications = [
    {'message': 'Department meeting today at 3 PM', 'time': '2 hours ago', 'type': 'meeting'},
    {'message': 'New research grant opportunity', 'time': 'Yesterday', 'type': 'research'},
    {'message': 'Student assignment submissions pending', 'time': 'Yesterday', 'type': 'academic'},
    {'message': 'Faculty development workshop next week', 'time': '2 days ago', 'type': 'workshop'},
  ];
  
  // Department list
  final List<String> _departments = [
    'All Departments',
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
  ];
  
  // Quick stats
  final Map<String, dynamic> _stats = {
    'totalStudents': 207,
    'totalCourses': 4,
    'pendingAssignments': 23,
    'attendanceRate': 88,
    'researchPapers': 12,
    'workshopsAttended': 8,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildProfileHeader(),
          _buildStatsRow(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildCoursesTab(),
                _buildStudentsTab(),
                _buildResearchTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF1E88E5),
      title: const Text(
        'Faculty Portal',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showNotifications(),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(),
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'settings', child: Text('Settings')),
            const PopupMenuItem(value: 'help', child: Text('Help')),
            const PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
          onSelected: (value) {
            if (value == 'logout') _showLogoutDialog();
          },
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Color(0xFF1E88E5)),
                ),
                const SizedBox(height: 12),
                Text(
                  _facultyProfile['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _facultyProfile['designation'],
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(Icons.dashboard, 'Dashboard', () {
                  Navigator.pop(context);
                  _tabController.animateTo(0);
                }),
                _buildDrawerItem(Icons.book, 'My Courses', () {
                  Navigator.pop(context);
                  _tabController.animateTo(1);
                }),
                _buildDrawerItem(Icons.people, 'Students', () {
                  Navigator.pop(context);
                  _tabController.animateTo(2);
                }),
                _buildDrawerItem(Icons.science, 'Research', () {
                  Navigator.pop(context);
                  _tabController.animateTo(3);
                }),
                const Divider(),
                _buildDrawerItem(Icons.assignment, 'Attendance', () {}),
                _buildDrawerItem(Icons.grade, 'Grades', () {}),
                _buildDrawerItem(Icons.calendar_today, 'Schedule', () {}),
                _buildDrawerItem(Icons.payments, 'Payroll', () {}),
                const Divider(),
                _buildDrawerItem(Icons.settings, 'Settings', () {}),
                _buildDrawerItem(Icons.help, 'Help & Support', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E88E5)),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _facultyProfile['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _facultyProfile['designation'],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      _facultyProfile['email'],
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _editProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Students', _stats['totalStudents'].toString(), Icons.people, Colors.green)),
          Expanded(child: _buildStatCard('Courses', _stats['totalCourses'].toString(), Icons.book, Colors.blue)),
          Expanded(child: _buildStatCard('Assignments', _stats['pendingAssignments'].toString(), Icons.assignment, Colors.orange)),
          Expanded(child: _buildStatCard('Attendance', '${_stats['attendanceRate']}%', Icons.trending_up, Colors.purple)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1E88E5),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1E88E5).withOpacity(0.1),
        ),
        tabs: const [
          Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
          Tab(text: 'Courses', icon: Icon(Icons.book)),
          Tab(text: 'Students', icon: Icon(Icons.people)),
          Tab(text: 'Research', icon: Icon(Icons.science)),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildUpcomingTasks(),
          const SizedBox(height: 16),
          _buildPerformanceChart(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(Icons.assignment_turned_in, 'Take\nAttendance', () => _takeAttendance()),
              _buildActionButton(Icons.grade, 'Enter\nGrades', () => _enterGrades()),
              _buildActionButton(Icons.upload_file, 'Upload\nMaterial', () => _uploadMaterial()),
              _buildActionButton(Icons.message, 'Send\nNotice', () => _sendNotice()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1E88E5), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTasks() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'View All',
                style: TextStyle(color: Color(0xFF1E88E5), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._tasks.map((task) => _buildTaskItem(task)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    Color priorityColor;
    switch (task['priority']) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: priorityColor.withOpacity(0.1),
        child: Icon(Icons.task, color: priorityColor, size: 20),
      ),
      title: Text(task['title'], style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('Due: ${task['deadline']} • ${task['status']}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: priorityColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          task['priority'],
          style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assessment, size: 60, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  '${_stats['researchPapers']} Research Papers Published',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_stats['workshopsAttended']} Workshops Attended',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return _buildCourseCard(course, index);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: index % 2 == 0 
                    ? [Colors.blue[400]!, Colors.blue[700]!]
                    : [Colors.green[400]!, Colors.green[700]!],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      course['id'],
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course['semester'],
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  course['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text('${course['students']} Students', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.schedule, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(course['schedule'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCourseStat('Attendance', '${course['attendance']}%', Icons.trending_up),
                    _buildCourseStat('Avg Grade', '${course['averageGrade']}%', Icons.grade),
                    _buildCourseStat('Assignments', '${course['assignments']}', Icons.assignment),
                    _buildCourseStat('Classes Left', '${course['upcomingClasses']}', Icons.event),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewCourseDetails(course),
                        icon: const Icon(Icons.info),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _manageCourse(course),
                        icon: const Icon(Icons.manage_accounts),
                        label: const Text('Manage'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1E88E5), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStudentsTab() {
    return Column(
      children: [
        _buildStudentFilters(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              return _buildStudentCard(student);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentFilters() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
              items: _departments.map((dept) {
                return DropdownMenuItem(value: dept, child: Text(dept));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value!;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _addStudent(),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    Color performanceColor;
    if (student['performance'].toString().startsWith('A')) {
      performanceColor = Colors.green;
    } else if (student['performance'].toString().startsWith('B')) {
      performanceColor = Colors.blue;
    } else {
      performanceColor = Colors.orange;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
            child: Text(student['name'][0], style: const TextStyle(color: Color(0xFF1E88E5))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(student['id'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: performanceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              student['performance'],
              style: TextStyle(color: performanceColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'edit') _editStudent(student);
              if (value == 'attendance') _viewStudentAttendance(student);
              if (value == 'grades') _viewStudentGrades(student);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Details')),
              const PopupMenuItem(value: 'attendance', child: Text('View Attendance')),
              const PopupMenuItem(value: 'grades', child: Text('View Grades')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildResearchStats(),
          const SizedBox(height: 16),
          _buildPublications(),
          const SizedBox(height: 16),
          _buildResearchGrants(),
        ],
      ),
    );
  }

  Widget _buildResearchStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple[400]!, Colors.deepPurple[700]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResearchStat('Papers', '12', Icons.description),
          _buildResearchStat('Citations', '245', Icons.note),
          _buildResearchStat('Grants', '₹45L', Icons.attach_money),
          _buildResearchStat('Projects', '5', Icons.science),
        ],
      ),
    );
  }

  Widget _buildResearchStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildPublications() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Publications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.article, color: Color(0xFF1E88E5)),
            title: const Text('AI in Education: A Comprehensive Review'),
            subtitle: const Text('Published in IEEE Transactions • 2024'),
            trailing: const Icon(Icons.link),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.article, color: Color(0xFF1E88E5)),
            title: const Text('Machine Learning for Student Performance Prediction'),
            subtitle: const Text('Published in Elsevier • 2023'),
            trailing: const Icon(Icons.link),
            onTap: () {},
          ),
          ElevatedButton(
            onPressed: () => _addPublication(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
            child: const Text('+ Add Publication'),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchGrants() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Research Grants',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildGrantItem('DST Funded Project', '₹25,00,000', '2024-2027'),
          _buildGrantItem('ICSSR Research Grant', '₹12,00,000', '2023-2025'),
          _buildGrantItem('Industry Collaborative', '₹8,00,000', '2024-2026'),
        ],
      ),
    );
  }

  Widget _buildGrantItem(String title, String amount, String period) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.currency_rupee, color: Colors.green),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(period, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _quickMenu(),
      backgroundColor: const Color(0xFF1E88E5),
      child: const Icon(Icons.add),
    );
  }

  // Action Methods
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._notifications.map((notification) => ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
                child: Icon(_getNotificationIcon(notification['type']), color: const Color(0xFF1E88E5)),
              ),
              title: Text(notification['message']),
              subtitle: Text(notification['time']),
            )),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'meeting':
        return Icons.meeting_room;
      case 'research':
        return Icons.science;
      case 'academic':
        return Icons.school;
      default:
        return Icons.notifications;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search students, courses...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Searching for: $value')),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile - Feature coming soon')),
    );
  }

  void _takeAttendance() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Take Attendance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Select Course'),
              items: _courses.map((course) => DropdownMenuItem(
                value: course['id'],
                child: Text(course['name']),
              )).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Start Attendance'),
            ),
          ],
        ),
      ),
    );
  }

  void _enterGrades() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grade Entry - Feature coming soon')),
    );
  }

  void _uploadMaterial() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload Material - Feature coming soon')),
    );
  }

  void _sendNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send Notice - Feature coming soon')),
    );
  }

  void _viewCourseDetails(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Course ID: ${course['id']}'),
            Text('Semester: ${course['semester']}'),
            Text('Schedule: ${course['schedule']}'),
            Text('Room: ${course['room']}'),
            Text('Students: ${course['students']}'),
            Text('Attendance Rate: ${course['attendance']}%'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _manageCourse(Map<String, dynamic> course) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Managing ${course['name']}')),
    );
  }

  void _addStudent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Student - Feature coming soon')),
    );
  }

  void _editStudent(Map<String, dynamic> student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${student['name']}')),
    );
  }

  void _viewStudentAttendance(Map<String, dynamic> student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance for ${student['name']}: ${student['attendance']}%')),
    );
  }

  void _viewStudentGrades(Map<String, dynamic> student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Grade for ${student['name']}: ${student['grade']}%')),
    );
  }

  void _addPublication() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Publication - Feature coming soon')),
    );
  }

  void _quickMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Quick Attendance'),
              onTap: () {
                Navigator.pop(context);
                _takeAttendance();
              },
            ),
            ListTile(
              leading: const Icon(Icons.grade),
              title: const Text('Enter Grades'),
              onTap: () {
                Navigator.pop(context);
                _enterGrades();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Upload Content'),
              onTap: () {
                Navigator.pop(context);
                _uploadMaterial();
              },
            ),
          ],
        ),
      ),
    );
  }
}