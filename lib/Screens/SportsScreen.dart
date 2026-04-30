import 'package:flutter/material.dart';

class SportsScreen extends StatefulWidget {
  const SportsScreen({super.key});

  @override
  State<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sports statistics
  final Map<String, dynamic> _sportsStats = {
    'totalSports': 18,
    'nationalMedals': 125,
    'stateMedals': 245,
    'nationalPlayers': 35,
    'sportsScholarships': 50,
    'annualEvents': 5,
  };
  
  // Sports facilities
  final List<Map<String, dynamic>> _facilities = [
    {
      'name': 'Cricket Ground',
      'icon': Icons.sports_cricket,
      'capacity': '5000+',
      'features': ['Floodlights', 'Practice Nets', 'Pavilion', 'Scoreboard'],
      'status': 'Available',
      'color': Color(0xFF4CAF50),
    },
    {
      'name': 'Football Field',
      'icon': Icons.sports_soccer,
      'capacity': '3000+',
      'features': ['Floodlights', 'Changing Rooms', 'Medical Room'],
      'status': 'Available',
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Basketball Court',
      'icon': Icons.sports_basketball,
      'capacity': '500',
      'features': ['Indoor Court', 'LED Scoreboard', 'Training Area'],
      'status': 'Available',
      'color': Color(0xFFFF9800),
    },
    {
      'name': 'Swimming Pool',
      'icon': Icons.pool,
      'capacity': '200',
      'features': ['Olympic Size', '8 Lanes', 'Diving Board', 'Heated Pool'],
      'status': 'Available',
      'color': Color(0xFF00BCD4),
    },
    {
      'name': 'Badminton Court',
      'icon': Icons.sports_kabaddi,
      'capacity': '100',
      'features': ['4 Indoor Courts', 'Wooden Flooring', 'Training Academy'],
      'status': 'Available',
      'color': Color(0xFF9C27B0),
    },
    {
      'name': 'Table Tennis',
      'icon': Icons.ac_unit_outlined,
      'capacity': '50',
      'features': ['6 Tables', 'International Quality', 'Coaching Available'],
      'status': 'Available',
      'color': Color(0xFFE91E63),
    },
    {
      'name': 'Volleyball Court',
      'icon': Icons.sports_volleyball,
      'capacity': '300',
      'features': ['Beach Court', 'Indoor Court', 'Training Nets'],
      'status': 'Available',
      'color': Color(0xFF795548),
    },
    {
      'name': 'Athletics Track',
      'icon': Icons.sports_gymnastics,
      'capacity': '1000',
      'features': ['400m Track', 'Long Jump Pit', 'High Jump Area', 'Shot Put Circle'],
      'status': 'Available',
      'color': Color(0xFFF44336),
    },
    {
      'name': 'Tennis Court',
      'icon': Icons.sports_tennis,
      'capacity': '200',
      'features': ['Clay Courts', 'Hard Courts', 'Night Lighting'],
      'status': 'Maintenance',
      'color': Color(0xFF607D8B),
    },
    {
      'name': 'Chess Arena',
      'icon': Icons.sports_esports,
      'capacity': '100',
      'features': ['AC Hall', 'Digital Boards', 'Library', 'Tournament Room'],
      'status': 'Available',
      'color': Color(0xFF3F51B5),
    },
  ];
  
  // Sports achievements
  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'National Basketball Champions',
      'year': '2024',
      'achievement': 'Gold Medal',
      'players': '12 Players',
      'icon': Icons.emoji_events,
      'color': Color(0xFFFFD700),
    },
    {
      'title': 'Inter-University Cricket',
      'year': '2023',
      'achievement': 'Runner Up',
      'players': '15 Players',
      'icon': Icons.sports_cricket,
      'color': Color(0xFFC0C0C0),
    },
    {
      'title': 'State Swimming Championship',
      'year': '2024',
      'achievement': '10 Medals',
      'players': '8 Players',
      'icon': Icons.pool,
      'color': Color(0xFFCD7F32),
    },
    {
      'title': 'National Chess Championship',
      'year': '2024',
      'achievement': 'Individual Gold',
      'players': '1 Player',
      'icon': Icons.sports_esports,
      'color': Color(0xFFFFD700),
    },
  ];
  
  // Upcoming events
  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'name': 'Annual Sports Meet 2024',
      'date': 'Dec 15-20, 2024',
      'venue': 'Main Sports Complex',
      'events': 'Athletics, Swimming, Team Sports',
      'registrationDeadline': 'Dec 10, 2024',
      'status': 'Registration Open',
    },
    {
      'name': 'Cricket Tournament',
      'date': 'Jan 5-15, 2025',
      'venue': 'Cricket Ground',
      'events': 'T20 Format',
      'registrationDeadline': 'Dec 30, 2024',
      'status': 'Coming Soon',
    },
    {
      'name': 'Chess Championship',
      'date': 'Feb 10-12, 2025',
      'venue': 'Indoor Sports Hall',
      'events': 'Individual & Team',
      'registrationDeadline': 'Feb 5, 2025',
      'status': 'Coming Soon',
    },
  ];
  
  // Sports teams
  final List<Map<String, dynamic>> _sportsTeams = [
    {
      'name': 'Cricket Team',
      'coach': 'Mr. Rajesh Kumar',
      'achievements': 'State Champions 2023',
      'members': 18,
      'icon': Icons.sports_cricket,
    },
    {
      'name': 'Football Team',
      'coach': 'Mr. Sanjay Singh',
      'achievements': 'University Champions 2024',
      'members': 22,
      'icon': Icons.sports_soccer,
    },
    {
      'name': 'Basketball Team',
      'coach': 'Mrs. Priya Sharma',
      'achievements': 'National Qualifiers 2024',
      'members': 15,
      'icon': Icons.sports_basketball,
    },
    {
      'name': 'Swimming Team',
      'coach': 'Mr. Anil Tiwari',
      'achievements': 'State Record Holders',
      'members': 12,
      'icon': Icons.pool,
    },
  ];
  
  // Training programs
  final List<Map<String, dynamic>> _trainingPrograms = [
    {
      'name': 'Summer Camp 2024',
      'duration': 'May-June',
      'sports': 'Cricket, Football, Swimming',
      'ageGroup': '10-18 years',
      'fee': '₹2000',
    },
    {
      'name': 'Weekend Training',
      'duration': 'Sat-Sun',
      'sports': 'All Sports',
      'ageGroup': 'All Age Groups',
      'fee': '₹1000/month',
    },
    {
      'name': 'Advanced Coaching',
      'duration': '6 Months',
      'sports': 'Select Sports',
      'ageGroup': 'Competitive Level',
      'fee': '₹5000',
    },
  ];
  
  // Gallery images (placeholders)
  final List<String> _galleryImages = [
    '🏏', '⚽', '🏀', '🏊‍♂️', '🏸', '🏓', '🎾', '🏃‍♂️'
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
                _buildFacilitiesTab(),
                _buildAchievementsTab(),
                _buildEventsTab(),
                _buildTeamsTab(),
                _buildGalleryTab(),
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
        'Sports Arena',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => _showNotifications(),
        ),
        IconButton(
          icon: const Icon(Icons.assessment),
          onPressed: () => _showLeaderboard(),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
          const SizedBox(height: 12),
          const Text(
            'Champions on Every Field',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${_sportsStats['totalSports']}+ Sports • ${_sportsStats['nationalMedals']}+ National Medals',
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
          _buildStatItem('Sports', '${_sportsStats['totalSports']}', Icons.sports, Colors.blue),
          _buildStatItem('National\nPlayers', '${_sportsStats['nationalPlayers']}', Icons.people, Colors.green),
          _buildStatItem('Medals', '${_sportsStats['nationalMedals']}', Icons.emoji_events, Colors.amber),
          _buildStatItem('Scholarships', '${_sportsStats['sportsScholarships']}', Icons.school, Colors.purple),
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
        labelColor: const Color(0xFF0D47A1),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF0D47A1).withOpacity(0.1),
        ),
        tabs: const [
          Tab(text: 'Facilities', icon: Icon(Icons.sports)),
          Tab(text: 'Achievements', icon: Icon(Icons.emoji_events)),
          Tab(text: 'Events', icon: Icon(Icons.event)),
          Tab(text: 'Teams', icon: Icon(Icons.group)),
          Tab(text: 'Gallery', icon: Icon(Icons.photo_library)),
        ],
      ),
    );
  }

  Widget _buildFacilitiesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _facilities.length,
      itemBuilder: (context, index) {
        final facility = _facilities[index];
        return _buildFacilityCard(facility);
      },
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> facility) {
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
                colors: [(facility['color'] as Color), (facility['color'] as Color).withOpacity(0.7)],
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
                  child: Icon(facility['icon'] as IconData, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Capacity: ${facility['capacity']}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: facility['status'] == 'Available' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    facility['status'],
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
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (facility['features'] as List<String>).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (facility['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 11,
                          color: facility['color'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _bookFacility(facility['name']),
                        icon: const Icon(Icons.book_online),
                        label: const Text('Book Now'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: facility['color'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewFacilityDetails(facility),
                        icon: const Icon(Icons.info),
                        label: const Text('Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: facility['color'],
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

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAchievementHighlights(),
          const SizedBox(height: 16),
          ..._achievements.map((achievement) => _buildAchievementCard(achievement)),
          const SizedBox(height: 16),
          _buildMedalTally(),
        ],
      ),
    );
  }

  Widget _buildAchievementHighlights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[700]!, Colors.orange[800]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 50, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Proud Moments',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: WordStyle.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${_sportsStats['nationalMedals']}+ National Medals • ${_sportsStats['stateMedals']}+ State Medals',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (achievement['color'] as Color).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (achievement['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(achievement['icon'] as IconData, color: achievement['color'], size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${achievement['year']} • ${achievement['achievement']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${achievement['players']} Players',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (achievement['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              achievement['achievement'],
              style: TextStyle(color: achievement['color'], fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalTally() {
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
            'Medal Tally (All Time)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMedalItem('🥇 Gold', '48', Colors.amber),
              _buildMedalItem('🥈 Silver', '42', Colors.grey),
              _buildMedalItem('🥉 Bronze', '35', Colors.brown),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedalItem(String medal, String count, Color color) {
    return Column(
      children: [
        Text(medal, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildEventRegistration(),
          const SizedBox(height: 16),
          ..._upcomingEvents.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildEventRegistration() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Register for Sports Events',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last date: ${_upcomingEvents[0]['registrationDeadline']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _registerForEvent(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
            ),
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
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
                  event['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: event['status'] == 'Registration Open' ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event['status'],
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(event['date'], style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(event['venue'], style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Events: ${event['events']}', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            'Registration Deadline: ${event['registrationDeadline']}',
            style: const TextStyle(fontSize: 11, color: Colors.red),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _registerForSpecificEvent(event['name']),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('Register Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sportsTeams.length,
      itemBuilder: (context, index) {
        final team = _sportsTeams[index];
        return _buildTeamCard(team);
      },
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(team['icon'] as IconData, color: const Color(0xFF0D47A1), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Coach: ${team['coach']}', style: const TextStyle(fontSize: 12)),
                Text('Achievement: ${team['achievements']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text('Members: ${team['members']}', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _viewTeamDetails(team['name']),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _galleryImages.length,
      itemBuilder: (context, index) {
        return _buildGalleryItem(_galleryImages[index]);
      },
    );
  }

  Widget _buildGalleryItem(String icon) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(icon),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Text(icon, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'View Photo',
                style: TextStyle(fontSize: 10, color: const Color(0xFF0D47A1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _joinTeam(),
      backgroundColor: const Color(0xFF0D47A1),
      icon: const Icon(Icons.group_add),
      label: const Text('Join Team'),
    );
  }

  // Action Methods
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.sports, color: Colors.blue),
              title: Text('Cricket trials on Dec 20'),
              subtitle: Text('2 hours ago'),
            ),
            const ListTile(
              leading: Icon(Icons.event, color: Colors.green),
              title: Text('Sports Meet registration open'),
              subtitle: Text('Yesterday'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaderboard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leaderboard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLeaderboardItem('Dept. of Engineering', 125),
            _buildLeaderboardItem('Dept. of Science', 98),
            _buildLeaderboardItem('Dept. of Management', 76),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(String dept, int points) {
    return ListTile(
      leading: const Icon(Icons.emoji_events, color: Colors.amber),
      title: Text(dept),
      trailing: Text('$points points', style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _bookFacility(String facilityName) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Book Facility', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Booking $facilityName', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Time Slot', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking request sent!'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  void _viewFacilityDetails(Map<String, dynamic> facility) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(facility['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capacity: ${facility['capacity']}'),
            Text('Status: ${facility['status']}'),
            const SizedBox(height: 8),
            const Text('Features:'),
            ...(facility['features'] as List<String>).map((f) => Text('• $f')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _registerForEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration started! Fill the form.'), backgroundColor: Colors.green),
    );
  }

  void _registerForSpecificEvent(String eventName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registered for $eventName!'), backgroundColor: Colors.green),
    );
  }

  void _viewTeamDetails(String teamName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing $teamName details'), backgroundColor: Colors.blue),
    );
  }

  void _showFullScreenImage(String icon) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 100)),
              const SizedBox(height: 20),
              const Text('Sports Event Photo', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _joinTeam() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Join a Team', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Sport'),
              items: ['Cricket', 'Football', 'Basketball', 'Swimming'].map((sport) {
                return DropdownMenuItem(value: sport, child: Text(sport));
              }).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Previous Experience', border: OutlineInputBorder()),
              maxLines: 3,
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
                backgroundColor: const Color(0xFF0D47A1),
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

class WordStyle {
  static FontWeight? get bold => null;
}