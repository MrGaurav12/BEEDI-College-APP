import 'package:flutter/material.dart';

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({super.key});

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDepartment = 'All';
  
  // Research statistics
  final Map<String, dynamic> _researchStats = {
    'activeProjects': 52,
    'fundedProjects': 38,
    'publications': 245,
    'citations': 1250,
    'patents': 12,
    'researchCenters': 8,
    'collaborations': 25,
    'studentResearchers': 150,
  };
  
  // Research centers
  final List<Map<String, dynamic>> _researchCenters = [
    {
      'name': 'AI & Machine Learning Lab',
      'director': 'Dr. Rajesh Kumar',
      'focus': 'Deep Learning, Computer Vision, NLP',
      'projects': 12,
      'funding': '₹2.5 Cr',
      'icon': Igs.memory,
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Biotechnology Research Center',
      'director': 'Dr. Priya Singh',
      'focus': 'Genetic Engineering, Bioinformatics',
      'projects': 8,
      'funding': '₹1.8 Cr',
      'icon': Igs.biotech,
      'color': Color(0xFF4CAF50),
    },
    {
      'name': 'Renewable Energy Lab',
      'director': 'Dr. Anil Sharma',
      'focus': 'Solar Energy, Wind Power, Energy Storage',
      'projects': 10,
      'funding': '₹3.2 Cr',
      'icon': Igs.energy_savings_leaf,
      'color': Color(0xFFFF9800),
    },
    {
      'name': 'Social Sciences Research Centre',
      'director': 'Dr. Meena Verma',
      'focus': 'Rural Development, Public Policy',
      'projects': 7,
      'funding': '₹1.2 Cr',
      'icon': Igs.psychology,
      'color': Color(0xFF9C27B0),
    },
    {
      'name': 'Robotics & Automation Lab',
      'director': 'Dr. Suresh Patel',
      'focus': 'Industrial Robotics, Autonomous Systems',
      'projects': 9,
      'funding': '₹2.1 Cr',
      'icon': Igs.precision_manufacturing,
      'color': Color(0xFFE91E63),
    },
    {
      'name': 'Materials Science Lab',
      'director': 'Dr. Neha Gupta',
      'focus': 'Nanomaterials, Composites, Smart Materials',
      'projects': 6,
      'funding': '₹1.5 Cr',
      'icon': Igs.science,
      'color': Color(0xFF607D8B),
    },
  ];
  
  // Active research projects
  final List<Map<String, dynamic>> _researchProjects = [
    {
      'title': 'AI-Powered Disease Detection System',
      'principalInvestigator': 'Dr. Rajesh Kumar',
      'department': 'Computer Science',
      'fundingAgency': 'DST',
      'amount': '₹45 Lakhs',
      'duration': '2023-2026',
      'status': 'Active',
      'team': '5 Researchers, 8 Students',
    },
    {
      'title': 'Smart Grid Optimization Using ML',
      'principalInvestigator': 'Dr. Anil Sharma',
      'department': 'Electrical Engineering',
      'fundingAgency': 'SERB',
      'amount': '₹38 Lakhs',
      'duration': '2024-2027',
      'status': 'Active',
      'team': '4 Researchers, 6 Students',
    },
    {
      'title': 'CRISPR Based Genetic Modification',
      'principalInvestigator': 'Dr. Priya Singh',
      'department': 'Biotechnology',
      'fundingAgency': 'DBT',
      'amount': '₹52 Lakhs',
      'duration': '2023-2026',
      'status': 'Active',
      'team': '6 Researchers, 10 Students',
    },
    {
      'title': 'Rural Entrepreneurship Development',
      'principalInvestigator': 'Dr. Meena Verma',
      'department': 'Social Sciences',
      'fundingAgency': 'ICSSR',
      'amount': '₹25 Lakhs',
      'duration': '2024-2027',
      'status': 'Active',
      'team': '3 Researchers, 5 Students',
    },
    {
      'title': 'Autonomous Navigation for Drones',
      'principalInvestigator': 'Dr. Suresh Patel',
      'department': 'Robotics',
      'fundingAgency': 'DRDO',
      'amount': '₹75 Lakhs',
      'duration': '2024-2027',
      'status': 'Active',
      'team': '7 Researchers, 12 Students',
    },
  ];
  
  // Recent publications
  final List<Map<String, dynamic>> _publications = [
    {
      'title': 'Deep Learning Approaches for Medical Image Analysis',
      'authors': 'R. Kumar, S. Singh, P. Verma',
      'journal': 'IEEE Transactions on Medical Imaging',
      'impactFactor': 8.5,
      'year': 2024,
      'citations': 25,
    },
    {
      'title': 'Novel Biopolymer for Environmental Remediation',
      'authors': 'P. Singh, A. Sharma, R. Gupta',
      'journal': 'Nature Biotechnology',
      'impactFactor': 54.9,
      'year': 2024,
      'citations': 18,
    },
    {
      'title': 'Solar Cell Efficiency Enhancement Using Nanomaterials',
      'authors': 'A. Sharma, N. Gupta, S. Patel',
      'journal': 'Advanced Energy Materials',
      'impactFactor': 29.4,
      'year': 2023,
      'citations': 42,
    },
    {
      'title': 'Machine Learning for Renewable Energy Forecasting',
      'authors': 'R. Kumar, A. Sharma, M. Verma',
      'journal': 'Applied Energy',
      'impactFactor': 11.4,
      'year': 2024,
      'citations': 15,
    },
  ];
  
  // Patents
  final List<Map<String, dynamic>> _patents = [
    {
      'title': 'AI-Based Early Warning System for Natural Disasters',
      'inventors': 'Dr. Rajesh Kumar, Dr. Anil Sharma',
      'patentNo': 'IN2024/123456',
      'filedDate': 'March 2024',
      'status': 'Published',
    },
    {
      'title': 'Biodegradable Polymer for Agricultural Use',
      'inventors': 'Dr. Priya Singh, Dr. Neha Gupta',
      'patentNo': 'IN2024/234567',
      'filedDate': 'February 2024',
      'status': 'Granted',
    },
  ];
  
  // Funding opportunities
  final List<Map<String, dynamic>> _fundingOpportunities = [
    {
      'name': 'Student Research Grant',
      'amount': 'Up to ₹2 Lakhs',
      'deadline': 'Dec 31, 2024',
      'eligibility': 'All UG/PG Students',
      'type': 'Internal',
    },
    {
      'name': 'DST Early Career Research Award',
      'amount': '₹30 Lakhs',
      'deadline': 'Jan 15, 2025',
      'eligibility': 'Faculty with <5 years experience',
      'type': 'Government',
    },
    {
      'name': 'Serb POWER Grant',
      'amount': '₹50 Lakhs',
      'deadline': 'Feb 28, 2025',
      'eligibility': 'Women Researchers',
      'type': 'Government',
    },
    {
      'name': 'Industrial Research Fellowship',
      'amount': '₹15 Lakhs',
      'deadline': 'Mar 15, 2025',
      'eligibility': 'PhD Scholars',
      'type': 'Industry',
    },
  ];
  
  // Collaborations
  final List<Map<String, dynamic>> _collaborations = [
    {
      'name': 'IIT Delhi',
      'type': 'Joint Research',
      'projects': 3,
      'logo': 'IIT',
    },
    {
      'name': 'IIT Bombay',
      'type': 'Student Exchange',
      'projects': 2,
      'logo': 'IIT',
    },
    {
      'name': 'NIT Patna',
      'type': 'Research Partnership',
      'projects': 4,
      'logo': 'NIT',
    },
    {
      'name': 'CSIR - NPL',
      'type': 'Laboratory Access',
      'projects': 2,
      'logo': 'CSIR',
    },
  ];
  
  // Innovation achievements
  final List<Map<String, dynamic>> _innovationAchievements = [
    {
      'title': 'National Award for Research Excellence',
      'year': '2024',
      'organization': 'Government of India',
      'icon': Igs.emoji_events,
    },
    {
      'title': 'Best Innovation in Renewable Energy',
      'year': '2023',
      'organization': 'Ministry of New & Renewable Energy',
      'icon': Igs.energy_savings_leaf,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
          _buildStatsRow(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResearchCentersTab(),
                _buildProjectsTab(),
                _buildPublicationsTab(),
                _buildOpportunitiesTab(),
                _buildCollaborationsTab(),
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
      backgroundColor: const Color(0xFF1565C0),
      title: const Text(
        'Research & Innovation Hub',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Igs.filter_alt),
          onPressed: () => _showFilterDialog(),
        ),
        IconButton(
          icon: const Icon(Igs.download),
          onPressed: () => _downloadResearchReport(),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Igs.science, size: 50, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Research & Innovation Hub',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${_researchStats['activeProjects']}+ Active Projects • ${_researchStats['publications']}+ Publications',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
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
          _buildStatItem('Projects', '${_researchStats['activeProjects']}', Igs.science, Colors.blue),
          _buildStatItem('Publications', '${_researchStats['publications']}', Igs.article, Colors.green),
          _buildStatItem('Citations', '${_researchStats['citations']}', Igs.quote, Colors.orange),
          _buildStatItem('Patents', '${_researchStats['patents']}', Igs.assignment, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
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
        labelColor: const Color(0xFF1565C0),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1565C0).withOpacity(0.1),
        ),
        tabs: const [
          Tab(text: 'Centers', icon: Icon(Igs.business)),
          Tab(text: 'Projects', icon: Icon(Igs.science)),
          Tab(text: 'Publications', icon: Icon(Igs.article)),
          Tab(text: 'Funding', icon: Icon(Igs.attach_money)),
          Tab(text: 'Collaborations', icon: Icon(Igs.people)),
        ],
      ),
    );
  }

  Widget _buildResearchCentersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _researchCenters.length,
      itemBuilder: (context, index) {
        final center = _researchCenters[index];
        return _buildResearchCenterCard(center);
      },
    );
  }

  Widget _buildResearchCenterCard(Map<String, dynamic> center) {
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
                colors: [center['color'] as Color, (center['color'] as Color).withOpacity(0.7)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(center['icon'] as IconData, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        center['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Director: ${center['director']}',
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
                    center['funding'],
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
                const Text(
                  'Research Focus:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  center['focus'],
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCenterStat('Active Projects', '${center['projects']}'),
                    _buildCenterStat('Researchers', '${(center['projects'] as int) * 2}'),
                    _buildCenterStat('Students', '${(center['projects'] as int) * 3}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewCenterDetails(center),
                        icon: const Icon(Igs.info),
                        label: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _collaborateWithCenter(center['name']),
                        icon: const Icon(Igs.people),
                        label: const Text('Collaborate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: center['color'],
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

  Widget _buildCenterStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildProjectsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _researchProjects.length,
      itemBuilder: (context, index) {
        final project = _researchProjects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
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
                  project['title'],
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
                  project['status'],
                  style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('PI: ${project['principalInvestigator']}', style: const TextStyle(fontSize: 12)),
          Text('Funding Agency: ${project['fundingAgency']}', style: const TextStyle(fontSize: 12)),
          Text('Amount: ${project['amount']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          Text('Duration: ${project['duration']}', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProjectStat('Researchers', project['team'].toString().split(' ')[0]),
                _buildProjectStat('Students', project['team'].toString().split(' ')[2]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewProjectDetails(project),
                  icon: const Icon(Igs.info),
                  label: const Text('Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _applyForProject(project['title']),
                  icon: const Icon(Igs.assignment),
                  label: const Text('Join Team'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPublicationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPublicationStats(),
          const SizedBox(height: 16),
          ..._publications.map((pub) => _buildPublicationCard(pub)),
          const SizedBox(height: 16),
          _buildPatentsSection(),
        ],
      ),
    );
  }

  Widget _buildPublicationStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[400]!, Colors.teal[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPubStat('Total Papers', '${_researchStats['publications']}'),
          _buildPubStat('Citations', '${_researchStats['citations']}'),
          _buildPubStat('H-Index', '28'),
        ],
      ),
    );
  }

  Widget _buildPubStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildPublicationCard(Map<String, dynamic> pub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pub['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Authors: ${pub['authors']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text('Journal: ${pub['journal']}', style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPubDetail('IF: ${pub['impactFactor']}', Colors.blue),
              const SizedBox(width: 8),
              _buildPubDetail('Year: ${pub['year']}', Colors.green),
              const SizedBox(width: 8),
              _buildPubDetail('Citations: ${pub['citations']}', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPubDetail(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPatentsSection() {
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
            'Patents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._patents.map((patent) => _buildPatentCard(patent)),
          ElevatedButton.icon(
            onPressed: () => _filePatent(),
            icon: const Icon(Igs.add),
            label: const Text('File New Patent'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatentCard(Map<String, dynamic> patent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Igs.assignment, color: Color(0xFF1565C0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patent['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text('Patent No: ${patent['patentNo']}', style: const TextStyle(fontSize: 11)),
                Text('Status: ${patent['status']}', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: patent['status'] == 'Granted' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              patent['status'],
              style: TextStyle(
                color: patent['status'] == 'Granted' ? Colors.green : Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStudentResearchGrants(),
          const SizedBox(height: 16),
          ..._fundingOpportunities.map((funding) => _buildFundingCard(funding)),
          const SizedBox(height: 16),
          _buildResearchAwards(),
        ],
      ),
    );
  }

  Widget _buildStudentResearchGrants() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple[400]!, Colors.deepPurple[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Research Grants',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Up to ₹2 Lakhs for innovative research projects',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _applyForGrant('Student Research Grant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('Apply Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFundingCard(Map<String, dynamic> funding) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  funding['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: funding['type'] == 'Government' ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  funding['type'],
                  style: TextStyle(
                    color: funding['type'] == 'Government' ? Colors.green : Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Amount: ${funding['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          Text('Eligibility: ${funding['eligibility']}', style: const TextStyle(fontSize: 12)),
          Text('Deadline: ${funding['deadline']}', style: const TextStyle(fontSize: 12, color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _applyForGrant(funding['name']),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              minimumSize: const Size(double.infinity, 35),
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchAwards() {
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
            'Research Excellence Awards',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._innovationAchievements.map((achievement) => ListTile(
            leading: const Icon(Igs.emoji_events, color: Colors.amber),
            title: Text(achievement['title']),
            subtitle: Text('${achievement['year']} • ${achievement['organization']}'),
          )),
        ],
      ),
    );
  }

  Widget _buildCollaborationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCollaborationStats(),
          const SizedBox(height: 16),
          ..._collaborations.map((collab) => _buildCollaborationCard(collab)),
          const SizedBox(height: 16),
          _buildCollaborationForm(),
        ],
      ),
    );
  }

  Widget _buildCollaborationStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCollabStat('Collaborations', '${_researchStats['collaborations']}'),
          _buildCollabStat('MoUs Signed', '18'),
          _buildCollabStat('Joint Projects', '12'),
        ],
      ),
    );
  }

  Widget _buildCollabStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCollaborationCard(Map<String, dynamic> collab) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                collab['logo'],
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collab['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Type: ${collab['type']}', style: const TextStyle(fontSize: 12)),
                Text('Active Projects: ${collab['projects']}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _viewCollaborationDetails(collab['name']),
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborationForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Propose Collaboration',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Interested in collaborating with us? Submit your proposal.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _proposeCollaboration(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('Submit Collaboration Proposal'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _submitResearchIdea(),
      backgroundColor: const Color(0xFF1565C0),
      icon: const Icon(Igs.lightbulb),
      label: const Text('Research Idea'),
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
            const Text('Filter Research', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ListTile(
              title: Text('Department'),
              trailing: Icon(Igs.add, size: 16),
            ),
            const ListTile(
              title: Text('Funding Agency'),
              trailing: Icon(Igs.add, size: 16),
            ),
            const ListTile(
              title: Text('Year'),
              trailing: Icon(Igs.add, size: 16),
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

  void _downloadResearchReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Research report downloaded!'), backgroundColor: Colors.green),
    );
  }

  void _viewCenterDetails(Map<String, dynamic> center) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(center['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Director: ${center['director']}'),
            Text('Focus: ${center['focus']}'),
            Text('Funding: ${center['funding']}'),
            Text('Active Projects: ${center['projects']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _collaborateWithCenter(String centerName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Collaboration request sent to $centerName'), backgroundColor: Colors.green),
    );
  }

  void _viewProjectDetails(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PI: ${project['principalInvestigator']}'),
            Text('Funding: ${project['fundingAgency']}'),
            Text('Amount: ${project['amount']}'),
            Text('Team: ${project['team']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _applyForProject(String projectTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Application submitted for $projectTitle'), backgroundColor: Colors.green),
    );
  }

  void _filePatent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Patent filing process started'), backgroundColor: Colors.green),
    );
  }

  void _applyForGrant(String grantName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Application started for $grantName'), backgroundColor: Colors.green),
    );
  }

  void _viewCollaborationDetails(String collabName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing $collabName collaboration details'), backgroundColor: Colors.blue),
    );
  }

  void _proposeCollaboration() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Propose Collaboration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Organization Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Research Area', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Proposal Details', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proposal submitted!'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Submit Proposal'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitResearchIdea() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Submit Research Idea', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Research Area'),
              items: ['AI/ML', 'Biotechnology', 'Renewable Energy', 'Social Sciences'].map((area) {
                return DropdownMenuItem(value: area, child: Text(area));
              }).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Research idea submitted!'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Submit Idea'),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Icons class to handle Icons that might not exist
class Igs {
  static const IconData science = Icons.science;
  static const IconData article = Icons.article;
  static const IconData quote = Icons.format_quote;
  static const IconData assignment = Icons.assignment;
  static const IconData business = Icons.business;
  static const IconData people = Icons.people;
  static const IconData attach_money = Icons.attach_money;
  static const IconData filter_alt = Icons.filter_alt;
  static const IconData download = Icons.download;
  static const IconData memory = Icons.memory;
  static const IconData biotech = Icons.biotech;
  static const IconData energy_savings_leaf = Icons.energy_savings_leaf;
  static const IconData psychology = Icons.psychology;
  static const IconData precision_manufacturing = Icons.precision_manufacturing;
  static const IconData emoji_events = Icons.emoji_events;
  static const IconData lightbulb = Icons.lightbulb;
  static const IconData add = Icons.add;
  static const IconData info = Icons.info;
  
  static IconData? get arrow_forward_ios => null;
}