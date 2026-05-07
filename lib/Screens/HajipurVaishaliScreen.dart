import 'package:flutter/material.dart';

class HajipurVaishaliScreen extends StatefulWidget {
  const HajipurVaishaliScreen({super.key});

  @override
  State<HajipurVaishaliScreen> createState() => _HajipurVaishaliScreenState();
}

class _HajipurVaishaliScreenState extends State<HajipurVaishaliScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMilestone = -1;
  String _selectedView = 'overview';
  
  // Campus expansion data
  final Map<String, dynamic> _campusInfo = {
    'name': 'Hajipur-Vaishali Campus',
    'location': 'Hajipur, Bihar',
    'area': '50 Acres',
    'expectedCompletion': 'December 2026',
    'totalInvestment': '₹250 Crores',
    'studentCapacity': '5000+',
    'hostelCapacity': '2000+',
    'startDate': 'January 2024',
    'currentProgress': 35,
  };
  
  // Construction milestones
  final List<Map<String, dynamic>> _milestones = [
    {
      'title': 'Foundation Laying',
      'date': 'Jan 2024',
      'status': 'Completed',
      'progress': 100,
      'description': 'Groundbreaking ceremony with Chief Minister',
      'icon': Icons.celebration,
      'color': Colors.green,
    },
    {
      'title': 'Main Building Construction',
      'date': 'Feb - Aug 2024',
      'status': 'In Progress',
      'progress': 60,
      'description': 'Academic block and admin building under construction',
      'icon': Icons.business,
      'color': Colors.blue,
    },
    {
      'title': 'Hostel Construction',
      'date': 'Mar - Oct 2024',
      'status': 'In Progress',
      'progress': 40,
      'description': 'Boys and girls hostel blocks',
      'icon': Icons.house,
      'color': Colors.orange,
    },
    {
      'title': 'Sports Complex',
      'date': 'Jun - Nov 2024',
      'status': 'Upcoming',
      'progress': 15,
      'description': 'Indoor stadium and outdoor fields',
      'icon': Icons.sports_score,
      'color': Colors.purple,
    },
    {
      'title': 'Lab & Research Center',
      'date': 'Aug - Dec 2024',
      'status': 'Upcoming',
      'progress': 10,
      'description': 'Modern laboratories and research facilities',
      'icon': Icons.science,
      'color': Colors.teal,
    },
    {
      'title': 'Landscaping & Finishing',
      'date': 'Jan - Nov 2025',
      'status': 'Not Started',
      'progress': 0,
      'description': 'Green campus development',
      'icon': Icons.landscape,
      'color': Colors.green,
    },
  ];
  
  // Facilities list
  final List<Map<String, dynamic>> _facilities = [
    {
      'name': 'Smart Classrooms',
      'icon': Icons.class_,
      'count': '50+',
      'description': 'Technology-enabled learning spaces',
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Computer Labs',
      'icon': Icons.computer,
      'count': '15',
      'description': 'State-of-the-art computing facilities',
      'color': Color(0xFF4CAF50),
    },
    {
      'name': 'Library',
      'icon': Icons.library_books,
      'count': '2 Floors',
      'description': 'Digital + Traditional library',
      'color': Color(0xFFFF9800),
    },
    {
      'name': 'Hostel',
      'icon': Icons.hotel,
      'count': '2000+ Beds',
      'description': 'Separate boys & girls hostels',
      'color': Color(0xFF9C27B0),
    },
    {
      'name': 'Sports Complex',
      'icon': Icons.sports_soccer,
      'count': '10+ Sports',
      'description': 'Indoor & outdoor facilities',
      'color': Color(0xFFE91E63),
    },
    {
      'name': 'Cafeteria',
      'icon': Icons.restaurant,
      'count': 'Multi-cuisine',
      'description': 'Healthy food options',
      'color': Color(0xFF795548),
    },
    {
      'name': 'Medical Center',
      'icon': Icons.local_hospital,
      'count': '24/7',
      'description': 'Healthcare facilities',
      'color': Color(0xFFF44336),
    },
    {
      'name': 'Transport Hub',
      'icon': Icons.directions_bus,
      'count': '20+ Buses',
      'description': 'City & hostel connectivity',
      'color': Color(0xFF607D8B),
    },
  ];
  
  // Courses offered
  final List<Map<String, dynamic>> _courses = [
    {
      'name': 'B.Tech Computer Science',
      'duration': '4 Years',
      'seats': 120,
      'specialization': 'AI, ML, Cybersecurity',
      'fee': '₹95,000/year',
    },
    {
      'name': 'B.Tech Electronics',
      'duration': '4 Years',
      'seats': 60,
      'specialization': 'VLSI, IoT, Robotics',
      'fee': '₹95,000/year',
    },
    {
      'name': 'B.Tech Mechanical',
      'duration': '4 Years',
      'seats': 60,
      'specialization': 'Design, Manufacturing',
      'fee': '₹95,000/year',
    },
    {
      'name': 'BCA',
      'duration': '3 Years',
      'seats': 120,
      'specialization': 'Software Development',
      'fee': '₹75,000/year',
    },
    {
      'name': 'MBA',
      'duration': '2 Years',
      'seats': 60,
      'specialization': 'Marketing, Finance, HR',
      'fee': '₹1,50,000/year',
    },
    {
      'name': 'Diploma Programs',
      'duration': '3 Years',
      'seats': 180,
      'specialization': 'Engineering & Technology',
      'fee': '₹55,000/year',
    },
  ];
  
  // Nearby attractions
  final List<Map<String, dynamic>> _attractions = [
    {
      'name': 'Vaishali Stupa',
      'distance': '5 km',
      'description': 'Ancient Buddhist site',
      'icon': Icons.account_balance,
    },
    {
      'name': 'Gandhi Setu',
      'distance': '3 km',
      'description': 'Iconic bridge over Ganges',
      'icon': Icons.badge,
    },
    {
      'name': 'Sonepur Mela',
      'distance': '15 km',
      'description': 'Asia\'s largest cattle fair',
      'icon': Icons.festival,
    },
    {
      'name': 'Patna City',
      'distance': '25 km',
      'description': 'State capital',
      'icon': Icons.location_city,
    },
  ];
  
  // News updates
  final List<Map<String, dynamic>> _newsUpdates = [
    {
      'title': 'Foundation Stone Laid',
      'date': 'January 15, 2024',
      'description': 'Hon\'ble Chief Minister laid the foundation stone for the new campus.',
      'image': null,
    },
    {
      'title': 'Construction Progressing Rapidly',
      'date': 'March 10, 2024',
      'description': 'Main building structure nearing completion ahead of schedule.',
      'image': null,
    },
    {
      'title': 'MoU with Industry Partners',
      'date': 'April 5, 2024',
      'description': 'Signed MoUs with 15+ companies for placements and internships.',
      'image': null,
    },
  ];
  
  // Skill development programs
  final List<Map<String, dynamic>> _skillPrograms = [
    {
      'title': 'Digital Literacy',
      'duration': '3 Months',
      'seats': 500,
      'status': 'Ongoing',
    },
    {
      'title': 'Vocational Training',
      'duration': '6 Months',
      'seats': 300,
      'status': 'Starting Soon',
    },
    {
      'title': 'Entrepreneurship',
      'duration': '2 Months',
      'seats': 200,
      'status': 'Upcoming',
    },
  ];

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
      body: Column(
        children: [
          _buildHeroSection(),
          _buildProgressBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildFacilitiesTab(),
                _buildCoursesTab(),
                _buildCommunityTab(),
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
      backgroundColor: const Color(0xFF0D47A1),
      title: const Text(
        'Hajipur-Vaishali Campus',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareCampusInfo(),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () => _saveForLater(),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.location_city, size: 200, color: Colors.white),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 40, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  _campusInfo['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_campusInfo['location']} • ${_campusInfo['area']} • ${_campusInfo['studentCapacity']} Capacity',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Expected: ${_campusInfo['expectedCompletion']}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Construction Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '35% Complete',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _campusInfo['currentProgress'] / 100,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF0D47A1),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressDetail('Start', 'Jan 2024', true),
              _buildProgressDetail('Current', '35%', true),
              _buildProgressDetail('Expected', 'Dec 2026', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetail(String label, String value, bool isActive) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF0D47A1) : Colors.grey,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isActive ? Colors.grey[600] : Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF0D47A1),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF0D47A1).withOpacity(0.1),
        ),
        tabs: const [
          Tab(text: 'Overview', icon: Icon(Icons.info)),
          Tab(text: 'Facilities', icon: Icon(Icons.build)),
          Tab(text: 'Courses', icon: Icon(Icons.school)),
          Tab(text: 'Community', icon: Icon(Icons.people)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildKeyMetrics(),
          const SizedBox(height: 16),
          _buildMilestones(),
          const SizedBox(height: 16),
          _buildNewsUpdates(),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
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
            'Key Metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildMetricCard('Total Investment', _campusInfo['totalInvestment'], Icons.currency_rupee, Colors.green),
              _buildMetricCard('Student Capacity', _campusInfo['studentCapacity'], Icons.people, Colors.blue),
              _buildMetricCard('Hostel Capacity', _campusInfo['hostelCapacity'], Icons.hotel, Colors.orange),
              _buildMetricCard('Campus Area', _campusInfo['area'], Icons.landscape, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones() {
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
            'Construction Milestones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _milestones.length,
            itemBuilder: (context, index) {
              final milestone = _milestones[index];
              return _buildMilestoneItem(milestone, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(Map<String, dynamic> milestone, int index) {
    return Column(
      children: [
        ListTile(
          onTap: () => _showMilestoneDetails(milestone),
          leading: CircleAvatar(
            backgroundColor: (milestone['color'] as Color).withOpacity(0.1),
            child: Icon(milestone['icon'] as IconData, color: milestone['color'], size: 24),
          ),
          title: Text(
            milestone['title'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(milestone['date']),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: milestone['progress'] / 100,
                backgroundColor: Colors.grey[200],
                color: milestone['color'],
                minHeight: 4,
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(milestone['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              milestone['status'],
              style: TextStyle(
                color: _getStatusColor(milestone['status']),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (index < _milestones.length - 1) const Divider(),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Upcoming':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildNewsUpdates() {
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
            'Latest Updates',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._newsUpdates.map((news) => _buildNewsCard(news)),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.newspaper, color: Color(0xFF0D47A1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  news['description'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  news['date'],
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _facilities.length,
            itemBuilder: (context, index) {
              final facility = _facilities[index];
              return _buildFacilityCard(facility);
            },
          ),
          const SizedBox(height: 16),
          _buildSkillDevelopment(),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> facility) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (facility['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(facility['icon'] as IconData, color: facility['color'], size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            facility['name'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            facility['count'],
            style: TextStyle(fontSize: 14, color: facility['color'], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            facility['description'],
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillDevelopment() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange[400]!, Colors.deepOrange[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Skill Development Center',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Empowering local youth with industry-ready skills',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ..._skillPrograms.map((program) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(program['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('${program['duration']} • ${program['seats']} seats', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    program['status'],
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _registerForTraining(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepOrange,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('Register for Free Training'),
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
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  course['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  course['duration'],
                  style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Seats: ${course['seats']}', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.currency_rupee, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(course['fee'], style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Specializations:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  course['specialization'],
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewCourseDetails(course),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _applyNow(course),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                  ),
                  child: const Text('Apply Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildNearbyAttractions(),
          const SizedBox(height: 16),
          _buildCommunityBenefits(),
          const SizedBox(height: 16),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildNearbyAttractions() {
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
            'Nearby Attractions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._attractions.map((attraction) => ListTile(
            leading: Icon(attraction['icon'] as IconData, color: const Color(0xFF0D47A1)),
            title: Text(attraction['name']),
            subtitle: Text(attraction['description']),
            trailing: Text(attraction['distance'], style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _buildCommunityBenefits() {
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
            'Community Benefits',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildBenefitItem('Local Employment', '500+ jobs created for local residents'),
          _buildBenefitItem('Skill Development', 'Free training programs for youth'),
          _buildBenefitItem('Economic Growth', 'Boost to local businesses and economy'),
          _buildBenefitItem('Educational Access', 'Quality education in the region'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
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

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildContactItem(Icons.phone, '+91 12345 67890'),
          _buildContactItem(Icons.email, 'hajipur@beedi.edu'),
          _buildContactItem(Icons.location_on, 'Hajipur-Vaishali Highway, Bihar'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _requestCallback(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('Request Callback'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showInterestForm(),
      backgroundColor: const Color(0xFF0D47A1),
      icon: const Icon(Icons.assignment_turned_in),
      label: const Text('Register Interest'),
    );
  }

  // Action Methods
  void _shareCampusInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Campus information shared!'), backgroundColor: Colors.green),
    );
  }

  void _saveForLater() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to bookmarks'), backgroundColor: Colors.green),
    );
  }

  void _showMilestoneDetails(Map<String, dynamic> milestone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(milestone['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${milestone['date']}'),
            Text('Status: ${milestone['status']}'),
            Text('Progress: ${milestone['progress']}%'),
            const SizedBox(height: 8),
            Text(milestone['description']),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _registerForTraining() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration form will open soon!'), backgroundColor: Colors.green),
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
            Text('Duration: ${course['duration']}'),
            Text('Seats: ${course['seats']}'),
            Text('Fee: ${course['fee']}'),
            Text('Specializations: ${course['specialization']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () => _applyNow(course), child: const Text('Apply')),
        ],
      ),
    );
  }

  void _applyNow(Map<String, dynamic> course) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Application started for ${course['name']}'), backgroundColor: Colors.green),
    );
  }

  void _requestCallback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Callback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('We will contact you soon!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showInterestForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Register Your Interest',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Email ID', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Interested Course'),
              items: ['B.Tech', 'BCA', 'MBA', 'Diploma'].map((course) {
                return DropdownMenuItem(value: course, child: Text(course));
              }).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Interest registered successfully!'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Submit Interest'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}