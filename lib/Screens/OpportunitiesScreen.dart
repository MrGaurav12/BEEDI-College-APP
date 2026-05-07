import 'package:flutter/material.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCompany = 'All';
  String _selectedType = 'All';
  
  // Placement data
  final Map<String, dynamic> _placementStats = {
    'totalOffers': 1250,
    'totalStudents': 850,
    'averagePackage': '7.2 LPA',
    'highestPackage': '45 LPA',
    'internationalOffers': 45,
    'dreamCompanies': 35,
    'placementRate': 94.5,
    'topRecruiters': 250,
  };
  
  // Top recruiting companies
  final List<Map<String, dynamic>> _companies = [
    {
      'name': 'Google',
      'logo': 'G',
      'package': '₹45 LPA',
      'offers': 12,
      'role': 'SDE',
      'location': 'Bangalore',
      'color': Color(0xFF4285F4),
    },
    {
      'name': 'Microsoft',
      'logo': 'M',
      'package': '₹38 LPA',
      'offers': 15,
      'role': 'Software Engineer',
      'location': 'Hyderabad',
      'color': Color(0xFF00A4EF),
    },
    {
      'name': 'Amazon',
      'logo': 'A',
      'package': '₹32 LPA',
      'offers': 25,
      'role': 'SDE',
      'location': 'Multiple',
      'color': Color(0xFFFF9900),
    },
    {
      'name': 'Flipkart',
      'logo': 'F',
      'package': '₹28 LPA',
      'offers': 18,
      'role': 'Software Developer',
      'location': 'Bangalore',
      'color': Color(0xFF2874F0),
    },
    {
      'name': 'TCS',
      'logo': 'T',
      'package': '₹7.5 LPA',
      'offers': 85,
      'role': 'System Engineer',
      'location': 'Pan India',
      'color': Color(0xFF007ACC),
    },
    {
      'name': 'Infosys',
      'logo': 'I',
      'package': '₹6.5 LPA',
      'offers': 72,
      'role': 'Developer',
      'location': 'Multiple',
      'color': Color(0xFF003B5C),
    },
    {
      'name': 'Wipro',
      'logo': 'W',
      'package': '₹6.8 LPA',
      'offers': 65,
      'role': 'Project Engineer',
      'location': 'Multiple',
      'color': Color(0xFF6CC24A),
    },
    {
      'name': 'Accenture',
      'logo': 'A',
      'package': '₹8.2 LPA',
      'offers': 58,
      'role': 'Associate Software Engineer',
      'location': 'Multiple',
      'color': Color(0xFFA100FF),
    },
  ];
  
  // Internships
  final List<Map<String, dynamic>> _internships = [
    {
      'title': 'Software Development Intern',
      'company': 'Google',
      'duration': '6 months',
      'stipend': '₹50,000/month',
      'location': 'Bangalore',
      'deadline': 'Dec 15, 2024',
      'eligible': 'B.Tech CSE/IT 3rd/4th year',
      'skills': ['DSA', 'Problem Solving', 'System Design'],
    },
    {
      'title': 'Data Science Intern',
      'company': 'Microsoft',
      'duration': '3 months',
      'stipend': '₹45,000/month',
      'location': 'Hyderabad',
      'deadline': 'Dec 20, 2024',
      'eligible': 'B.Tech/M.Tech AI/ML',
      'skills': ['Python', 'ML', 'Statistics'],
    },
    {
      'title': 'Product Management Intern',
      'company': 'Amazon',
      'duration': '6 months',
      'stipend': '₹40,000/month',
      'location': 'Remote',
      'deadline': 'Jan 5, 2025',
      'eligible': 'MBA/B.Tech Any Branch',
      'skills': ['Analytics', 'Communication', 'Leadership'],
    },
    {
      'title': 'Research Intern',
      'company': 'ISRO',
      'duration': '3 months',
      'stipend': '₹25,000/month',
      'location': 'Ahmedabad',
      'deadline': 'Jan 10, 2025',
      'eligible': 'B.Tech/M.Tech Electronics/CS',
      'skills': ['Research', 'Python', 'Aerospace'],
    },
  ];
  
  // Scholarships
  final List<Map<String, dynamic>> _scholarships = [
    {
      'name': 'Merit Cum Means Scholarship',
      'amount': '₹75,000/year',
      'eligibility': '90%+ in 10+2, Family income < ₹6 LPA',
      'deadline': 'Dec 30, 2024',
      'provider': 'Government of India',
      'type': 'Merit Based',
    },
    {
      'name': 'BEEDI Excellence Scholarship',
      'amount': '₹50,000/year',
      'eligibility': 'Top 10% in previous semester',
      'deadline': 'Jan 15, 2025',
      'provider': 'BEEDI College',
      'type': 'Academic Excellence',
    },
    {
      'name': 'Girl Child Education Scholarship',
      'amount': '₹40,000/year',
      'eligibility': 'Female students with 80%+ marks',
      'deadline': 'Jan 20, 2025',
      'provider': 'Ministry of Education',
      'type': 'Gender Equality',
    },
    {
      'name': 'Sports Quota Scholarship',
      'amount': '₹35,000/year',
      'eligibility': 'State/National level players',
      'deadline': 'Feb 10, 2025',
      'provider': 'Sports Authority',
      'type': 'Sports',
    },
    {
      'name': 'SC/ST/OBC Scholarship',
      'amount': '₹60,000/year',
      'eligibility': 'Reserved category students',
      'deadline': 'Jan 5, 2025',
      'provider': 'Social Welfare Dept',
      'type': 'Reservation',
    },
    {
      'name': 'International Study Grant',
      'amount': '₹2,00,000/year',
      'eligibility': 'CGPA 8.5+ with research potential',
      'deadline': 'Mar 1, 2025',
      'provider': 'Ministry of External Affairs',
      'type': 'International',
    },
  ];
  
  // Startup incubator programs
  final List<Map<String, dynamic>> _startupPrograms = [
    {
      'name': 'Seed Fund Program',
      'funding': 'Up to ₹50 Lakhs',
      'equity': '5-10%',
      'duration': '12 months',
      'mentorship': 'Industry Experts',
    },
    {
      'name': 'Incubation Support',
      'funding': 'Office Space + Resources',
      'equity': '2-5%',
      'duration': '18 months',
      'mentorship': 'Virtual + Physical',
    },
    {
      'name': 'Innovation Challenge',
      'funding': '₹5 Lakhs (Winning Prize)',
      'equity': 'None',
      'duration': '3 months',
      'mentorship': 'Business Mentors',
    },
  ];
  
  // Alumni success stories
  final List<Map<String, dynamic>> _alumniStories = [
    {
      'name': 'Rahul Sharma',
      'batch': '2022',
      'company': 'Google',
      'package': '₹52 LPA',
      'image': null,
      'quote': 'BEEDI provided the perfect platform to kickstart my career.',
    },
    {
      'name': 'Priya Singh',
      'batch': '2023',
      'company': 'Microsoft',
      'package': '₹45 LPA',
      'image': null,
      'quote': 'The placement training and alumni network were invaluable.',
    },
    {
      'name': 'Amit Kumar',
      'batch': '2021',
      'company': 'Started Own Venture',
      'package': '₹2 Cr Revenue',
      'image': null,
      'quote': 'Incubation support helped me turn my idea into a business.',
    },
  ];
  
  // Upcoming placement drives
  final List<Map<String, dynamic>> _upcomingDrives = [
    {
      'company': 'Google',
      'date': 'Dec 20, 2024',
      'mode': 'Online',
      'roles': 'SDE, ML Engineer',
    },
    {
      'company': 'Microsoft',
      'date': 'Jan 5, 2025',
      'mode': 'Hybrid',
      'roles': 'Software Engineer, Data Scientist',
    },
    {
      'company': 'Amazon',
      'date': 'Jan 15, 2025',
      'mode': 'Online',
      'roles': 'SDE, Cloud Associate',
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
          _buildStatsOverview(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlacementsTab(),
                _buildInternshipsTab(),
                _buildScholarshipsTab(),
                _buildEntrepreneurshipTab(),
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
        'Opportunities',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => _showNotifications(),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration, size: 50, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Unlock Your Potential',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${_placementStats['totalOffers']}+ Job Offers • ${_placementStats['totalStudents']}+ Placed Students',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '250+ Companies Visit Every Year',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Average\nPackage', _placementStats['averagePackage'], Icons.currency_rupee, Colors.green),
          _buildStatItem('Highest\nPackage', _placementStats['highestPackage'], Icons.trending_up, Colors.orange),
          _buildStatItem('Placement\nRate', '${_placementStats['placementRate']}%', Icons.percent, Colors.blue),
          _buildStatItem('Dream\nCompanies', '${_placementStats['dreamCompanies']}+', Icons.business, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
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
        labelColor: const Color(0xFF1E88E5),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1E88E5).withOpacity(0.1),
        ),
        tabs: const [
          Tab(text: 'Placements', icon: Icon(Icons.work)),
          Tab(text: 'Internships', icon: Icon(Icons.school)),
          Tab(text: 'Scholarships', icon: Icon(Icons.attach_money)),
          Tab(text: 'Startups', icon: Icon(Icons.rocket)),
        ],
      ),
    );
  }

  Widget _buildPlacementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUpcomingDrives(),
          const SizedBox(height: 16),
          _buildTopRecruiters(),
          const SizedBox(height: 16),
          _buildPlacementStats(),
          const SizedBox(height: 16),
          _buildAlumniStories(),
        ],
      ),
    );
  }

  Widget _buildUpcomingDrives() {
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
                'Upcoming Placement Drives',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'View All',
                style: TextStyle(color: Color(0xFF1E88E5), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._upcomingDrives.map((drive) => _buildDriveCard(drive)),
        ],
      ),
    );
  }

  Widget _buildDriveCard(Map<String, dynamic> drive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.business_center, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drive['company'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  drive['roles'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(drive['date'], style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(drive['mode'], style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _registerForDrive(drive),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              minimumSize: const Size(70, 30),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Apply', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRecruiters() {
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
            'Top Recruiters',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _companies.length,
            itemBuilder: (context, index) {
              final company = _companies[index];
              return _buildCompanyCard(company);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (company['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (company['color'] as Color).withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: company['color'],
            radius: 25,
            child: Text(
              company['logo'],
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(company['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(company['package'], style: TextStyle(color: company['color'], fontWeight: FontWeight.bold, fontSize: 12)),
          Text('${company['offers']} offers', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPlacementStats() {
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
            'Placement Highlights',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHighlightItem('International\nOffers', '${_placementStats['internationalOffers']}', Icons.public),
              _buildHighlightItem('Dream\nCompanies', '${_placementStats['dreamCompanies']}', Icons.star),
              _buildHighlightItem('Total\nRecruiters', '${_placementStats['topRecruiters']}', Icons.business),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildAlumniStories() {
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
            'Alumni Success Stories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._alumniStories.map((story) => _buildAlumniCard(story)),
        ],
      ),
    );
  }

  Widget _buildAlumniCard(Map<String, dynamic> story) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1E88E5),
            radius: 30,
            child: Text(
              story['name'][0],
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(story['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${story['company']} • ${story['package']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(story['quote'], style: const TextStyle(fontSize: 11), maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternshipsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _internships.length,
      itemBuilder: (context, index) {
        final internship = _internships[index];
        return _buildInternshipCard(internship);
      },
    );
  }

  Widget _buildInternshipCard(Map<String, dynamic> internship) {
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    internship['company'][0],
                    style: const TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        internship['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        internship['company'],
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
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
                    internship['stipend'],
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildInfoChip(Icons.access_time, internship['duration']),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.location_on, internship['location']),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.event, internship['deadline']),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Eligibility:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(internship['eligible'], style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (internship['skills'] as List<String>).map((skill) {
                    return Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 11)),
                      backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _viewDetails(internship),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _applyForInternship(internship),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                        ),
                        child: const Text('Apply Now'),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildScholarshipsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildScholarshipStats(),
          const SizedBox(height: 16),
          ..._scholarships.map((scholarship) => _buildScholarshipCard(scholarship)),
        ],
      ),
    );
  }

  Widget _buildScholarshipStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple[400]!, Colors.deepPurple[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScholarshipStat('Available\nScholarships', '${_scholarships.length}'),
          _buildScholarshipStat('Max Amount', '₹2 Lakhs'),
          _buildScholarshipStat('Students\nBenefited', '450+'),
        ],
      ),
    );
  }

  Widget _buildScholarshipStat(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildScholarshipCard(Map<String, dynamic> scholarship) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  scholarship['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  scholarship['amount'],
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(scholarship['provider'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          _buildScholarshipDetail('Eligibility', scholarship['eligibility']),
          _buildScholarshipDetail('Deadline', scholarship['deadline']),
          _buildScholarshipDetail('Type', scholarship['type']),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewScholarshipDetails(scholarship),
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _applyForScholarship(scholarship),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScholarshipDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text('$label:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrepreneurshipTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildIncubatorHeader(),
          const SizedBox(height: 16),
          ..._startupPrograms.map((program) => _buildStartupProgramCard(program)),
          const SizedBox(height: 16),
          _buildSuccessMetrics(),
          const SizedBox(height: 16),
          _buildApplyNowCard(),
        ],
      ),
    );
  }

  Widget _buildIncubatorHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.deepOrange[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.rocket, size: 50, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Startup Incubator',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Turn your innovative ideas into successful businesses',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('15+ Startups Incubated', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStartupProgramCard(Map<String, dynamic> program) {
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
          Text(program['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildProgramDetail('Funding', program['funding']),
          _buildProgramDetail('Equity', program['equity']),
          _buildProgramDetail('Duration', program['duration']),
          _buildProgramDetail('Mentorship', program['mentorship']),
        ],
      ),
    );
  }

  Widget _buildProgramDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildSuccessMetrics() {
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
            'Success Metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Startups', '15+'),
              _buildMetric('Jobs Created', '200+'),
              _buildMetric('Funding Raised', '₹5 Cr'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildApplyNowCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Ready to Launch Your Startup?',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Apply for incubation and get access to funding, mentorship, and resources',
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _applyForIncubation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('Apply for Incubation'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _quickApply(),
      backgroundColor: const Color(0xFF1E88E5),
      icon: const Icon(Icons.bolt),
      label: const Text('Quick Apply'),
    );
  }

  // Action Methods
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter Opportunities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ListTile(
              title: Text('Company Type'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            const ListTile(
              title: Text('Salary Range'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            const ListTile(
              title: Text('Location'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New opportunities available!'), backgroundColor: Colors.green),
    );
  }

  void _registerForDrive(Map<String, dynamic> drive) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registered for ${drive['company']} drive!'), backgroundColor: Colors.green),
    );
  }

  void _viewDetails(Map<String, dynamic> internship) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(internship['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Company: ${internship['company']}'),
            Text('Duration: ${internship['duration']}'),
            Text('Stipend: ${internship['stipend']}'),
            Text('Location: ${internship['location']}'),
            Text('Deadline: ${internship['deadline']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _applyForInternship(Map<String, dynamic> internship) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Application submitted for ${internship['title']}!'), backgroundColor: Colors.green),
    );
  }

  void _viewScholarshipDetails(Map<String, dynamic> scholarship) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(scholarship['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${scholarship['amount']}'),
            Text('Provider: ${scholarship['provider']}'),
            Text('Eligibility: ${scholarship['eligibility']}'),
            Text('Deadline: ${scholarship['deadline']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _applyForScholarship(Map<String, dynamic> scholarship) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applied for ${scholarship['name']}!'), backgroundColor: Colors.green),
    );
  }

  void _applyForIncubation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incubation application started!'), backgroundColor: Colors.green),
    );
  }

  void _quickApply() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quick Apply', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Resume Link', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application submitted!'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}