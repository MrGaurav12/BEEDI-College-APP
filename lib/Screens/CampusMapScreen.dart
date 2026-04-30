import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ==================== COLOR CONSTANTS ====================
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

// ==================== MAIN CAMPUS MAP SCREEN ====================
class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen>
    with SingleTickerProviderStateMixin {
  // ==================== STATE VARIABLES ====================
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedBuilding = 'All';
  bool isSatelliteView = false;
  bool show3DBuildings = false;
  bool isDarkMode = false;
  bool showTraffic = false;
  bool showWeather = true;
  bool showAccessibility = false;
  bool isNavigating = false;
  String currentNavigationTarget = '';
  List<String> favorites = [];
  List<String> recentlyVisited = [];
  Set<String> savedLocations = {};
  Set<String> reportedIssues = {};
  double zoomLevel = 1.0;
  int currentFloor = 1;
  int maxFloors = 5;
  String selectedTimeSlot = 'Now';
  String selectedTransportMode = 'Walking';
  late AnimationController _pulseController;
  late AnimationController _navigationController;
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  int currentFeaturedIndex = 0;

  // Floor plan visibility
  Map<int, bool> floorVisibility = {
    1: true,
    2: false,
    3: false,
    4: false,
    5: false,
  };

  // Dummy coordinates for buildings (latitude, longitude simulation)
  final Map<String, Map<String, dynamic>> buildingLocations = {
    'Main Academic Block': {
      'x': 0.5,
      'y': 0.4,
      'icon': '🏛️',
      'color': AC.blue,
      'schedule': '8AM - 8PM',
      'crowd': 'Medium',
      'facilities': ['Elevator', 'WiFi', 'Cafeteria'],
    },
    'AI Research Lab': {
      'x': 0.7,
      'y': 0.3,
      'icon': '🤖',
      'color': AC.purple,
      'schedule': '9AM - 6PM',
      'crowd': 'Low',
      'facilities': ['GPU Lab', 'VR Room', 'Library'],
    },
    'Olympic Pool & Sports Complex': {
      'x': 0.3,
      'y': 0.7,
      'icon': '🏊',
      'color': AC.green,
      'schedule': '6AM - 10PM',
      'crowd': 'High',
      'facilities': ['Pool', 'Gym', 'Court'],
    },
    'Girls Hostel': {
      'x': 0.2,
      'y': 0.2,
      'icon': '👧',
      'color': Colors.pink,
      'schedule': '24/7',
      'crowd': 'Medium',
      'facilities': ['Security', 'Mess', 'Laundry'],
    },
    'Boys Hostel': {
      'x': 0.8,
      'y': 0.8,
      'icon': '👦',
      'color': Colors.blue,
      'schedule': '24/7',
      'crowd': 'High',
      'facilities': ['Security', 'Mess', 'Gym'],
    },
    'Central Library': {
      'x': 0.5,
      'y': 0.5,
      'icon': '📚',
      'color': AC.orange,
      'schedule': '24/7',
      'crowd': 'High',
      'facilities': ['Study Rooms', 'Computer Lab', 'Cafe'],
    },
    'Innovation Hub': {
      'x': 0.6,
      'y': 0.6,
      'icon': '💡',
      'color': AC.accentBlue,
      'schedule': '10AM - 8PM',
      'crowd': 'Medium',
      'facilities': ['3D Printer', 'Workshop', 'Meeting Rooms'],
    },
    'Medical Center': {
      'x': 0.4,
      'y': 0.8,
      'icon': '🏥',
      'color': Colors.red,
      'schedule': '24/7',
      'crowd': 'Low',
      'facilities': ['Pharmacy', 'Emergency', 'Clinic'],
    },
    'Food Court': {
      'x': 0.6,
      'y': 0.2,
      'icon': '🍔',
      'color': Colors.orange,
      'schedule': '7AM - 11PM',
      'crowd': 'Very High',
      'facilities': ['Multiple Cuisines', 'Seating'],
    },
    'Auditorium': {
      'x': 0.3,
      'y': 0.4,
      'icon': '🎭',
      'color': AC.purple,
      'schedule': 'Event Based',
      'crowd': 'Variable',
      'facilities': ['Stage', 'Sound System', 'Projector'],
    },
    'Parking Area': {
      'x': 0.9,
      'y': 0.5,
      'icon': '🅿️',
      'color': AC.grey,
      'schedule': '24/7',
      'crowd': 'High',
      'facilities': ['EV Charging', 'Security'],
    },
    'Temple/Meditation Center': {
      'x': 0.1,
      'y': 0.9,
      'icon': '🕉️',
      'color': Colors.deepPurple,
      'schedule': '5AM - 9PM',
      'crowd': 'Low',
      'facilities': ['Meditation Hall', 'Garden'],
    },
  };

  List<Map<String, dynamic>> get filteredLocations {
    var locations = buildingLocations.entries.where((entry) {
      if (searchQuery.isNotEmpty &&
          !entry.key.toLowerCase().contains(searchQuery.toLowerCase()))
        return false;
      if (selectedCategory != 'All' &&
          entry.value['icon'] != _getCategoryIcon(selectedCategory))
        return false;
      if (selectedBuilding != 'All' && entry.key != selectedBuilding)
        return false;
      return true;
    }).toList();
    return locations.map((e) => {'name': e.key, ...e.value}).toList();
  }

  List<String> get categories => [
    'All',
    'Academic',
    'Hostels',
    'Sports',
    'Amenities',
    'Food',
  ];
  List<String> get buildings => ['All', ...buildingLocations.keys];

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Academic':
        return '🏛️';
      case 'Hostels':
        return '🏠';
      case 'Sports':
        return '🏊';
      case 'Amenities':
        return '📚';
      case 'Food':
        return '🍔';
      default:
        return '';
    }
  }

  // Real-time crowd data
  final Map<String, String> crowdLevels = {
    'Main Academic Block': 'Medium',
    'Central Library': 'High',
    'Food Court': 'Very High',
    'Sports Complex': 'Medium',
  };

  // Events happening today
  final List<Map<String, dynamic>> todayEvents = [
    {
      'title': 'Tech Symposium',
      'time': '10:00 AM',
      'location': 'Auditorium',
      'speaker': 'Dr. Smith',
    },
    {
      'title': 'Yoga Session',
      'time': '7:00 AM',
      'location': 'Sports Complex',
      'speaker': 'Expert',
    },
    {
      'title': 'Library Workshop',
      'time': '2:00 PM',
      'location': 'Central Library',
      'speaker': 'Librarian',
    },
    {
      'title': 'Coding Competition',
      'time': '4:00 PM',
      'location': 'AI Research Lab',
      'speaker': 'Google',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _navigationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _startAutoSlide();
    _loadSavedData();
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          currentFeaturedIndex = (currentFeaturedIndex + 1) % 3;
        });
        _startAutoSlide();
      }
    });
  }

  void _loadSavedData() async {
    // Simulate loading saved preferences
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      favorites = ['Central Library', 'Sports Complex'];
      recentlyVisited = ['Main Academic Block', 'Food Court'];
    });
  }

  void _toggleFavorite(String location) {
    setState(() {
      if (favorites.contains(location)) {
        favorites.remove(location);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Removed $location from favorites'),
            backgroundColor: AC.grey,
          ),
        );
      } else {
        favorites.add(location);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⭐ Added $location to favorites'),
            backgroundColor: AC.green,
          ),
        );
      }
    });
  }

  void _startNavigation(String destination) {
    setState(() {
      isNavigating = true;
      currentNavigationTarget = destination;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚶 Navigating to $destination... Estimated time: 5 mins',
        ),
        backgroundColor: AC.blue,
        duration: const Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => isNavigating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ You have arrived at your destination!'),
            backgroundColor: AC.green,
          ),
        );
      }
    });
  }

  void _reportIssue(String location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Report an Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Report issue at $location'),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Issue Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Your Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => reportedIssues.add(location));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📧 Issue reported! We\'ll look into it.'),
                  backgroundColor: AC.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AC.red),
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _navigationController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode
          ? ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.grey[900])
          : ThemeData.light().copyWith(scaffoldBackgroundColor: AC.bg),
      home: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : AC.bg,
        appBar: _advancedAppBar(),
        body: _advancedBody(),
        floatingActionButton: _buildFloatingButton(),
        bottomNavigationBar: _buildBottomNavBar(),
        drawer: _buildDrawer(),
      ),
    );
  }

  PreferredSizeWidget _advancedAppBar() {
    return AppBar(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AC.blue, AC.lightBlue]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🗺️', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Campus Map',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AC.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.location_on, size: 14, color: AC.green),
                SizedBox(width: 4),
                Text(
                  'You are here',
                  style: TextStyle(fontSize: 12, color: AC.green),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: AC.blue,
          ),
          onPressed: () => setState(() => isDarkMode = !isDarkMode),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () => _showFavoritesDialog(),
            ),
            if (favorites.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _advancedBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            _buildSearchAndFilters(),
            _buildQuickActions(constraints),
            _buildFeaturedSection(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _buildInteractiveMap(constraints),
                    _buildBuildingList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: '🔍 Search buildings, departments...',
              prefixIcon: const Icon(Icons.search, color: AC.blue),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => searchQuery = ''),
                    )
                  : null,
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : AC.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (selected) =>
                          setState(() => selectedCategory = cat),
                      backgroundColor: isDarkMode
                          ? Colors.grey[800]
                          : Colors.white,
                      selectedColor: AC.blue.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: selectedCategory == cat ? AC.blue : AC.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BoxConstraints constraints) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildActionChip(
            Icons.navigation,
            'Navigate',
            () => _showNavigationSheet(),
          ),
          _buildActionChip(Icons.event, 'Events', () => _showEventsDialog()),
          _buildActionChip(Icons.people, 'Crowd Map', () => _showCrowdMap()),
          _buildActionChip(Icons.notifications, 'Alerts', () => _showAlerts()),
          _buildActionChip(Icons.share, 'Share Map', () => _shareMap()),
          _buildActionChip(
            Icons.qr_code_scanner,
            'Scan QR',
            () => _scanQRCode(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AC.blue),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: AC.blue, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [AC.blue, AC.lightBlue]),
      ),
      child: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) =>
                setState(() => currentFeaturedIndex = index),
            children: [
              _buildFeaturedCard(
                '📢 Today\'s Events',
                '4 events happening now',
                Icons.event,
                Colors.orange,
              ),
              _buildFeaturedCard(
                '🎓 Orientation Week',
                'New student guide available',
                Icons.school,
                Colors.green,
              ),
              _buildFeaturedCard(
                '🚧 Construction Alert',
                'East wing pathway closed',
                Icons.construction,
                Colors.red,
              ),
            ],
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentFeaturedIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMap(BoxConstraints constraints) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Interactive Map',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () => setState(
                    () => zoomLevel = (zoomLevel + 0.1).clamp(0.5, 2.0),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: () => setState(
                    () => zoomLevel = (zoomLevel - 0.1).clamp(0.5, 2.0),
                  ),
                ),
                IconButton(
                  icon: Icon(isSatelliteView ? Icons.map : Icons.satellite),
                  onPressed: () =>
                      setState(() => isSatelliteView = !isSatelliteView),
                ),
              ],
            ),
          ),
          Container(
            height: 400,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSatelliteView ? Colors.green[900] : Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              image: isSatelliteView
                  ? const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1577153766931-2dfa2a8e8d5d?w=800',
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Grid lines
                  ...List.generate(
                    10,
                    (i) => Positioned(
                      left: 0,
                      right: 0,
                      top: i * 40.0,
                      child: Container(
                        height: 1,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ),
                  ...List.generate(
                    10,
                    (i) => Positioned(
                      top: 0,
                      bottom: 0,
                      left: i * 40.0,
                      child: Container(
                        width: 1,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ),
                  // Building markers
                  ...filteredLocations.map(
                    (building) => _buildMapMarker(building),
                  ),
                  // Navigation path animation
                  if (isNavigating)
                    AnimatedBuilder(
                      animation: _navigationController,
                      builder: (context, child) => CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: NavigationPathPainter(
                          progress: _navigationController.value,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMapLegend('🏛️', 'Academic', AC.blue),
                _buildMapLegend('🏠', 'Hostels', Colors.pink),
                _buildMapLegend('🏊', 'Sports', AC.green),
                _buildMapLegend('🍔', 'Food', Colors.orange),
                _buildMapLegend('📚', 'Amenities', AC.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLegend(String icon, String label, Color color) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }

  Widget _buildMapMarker(Map<String, dynamic> building) {
    return Positioned(
      left: (building['x'] as double) * 300,
      top: (building['y'] as double) * 300,
      child: GestureDetector(
        onTap: () => _showBuildingDetails(building['name']),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) => Transform.scale(
            scale: 1 + (_pulseController.value * 0.2),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (building['color'] as Color).withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (building['color'] as Color).withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                building['icon'] as String,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuildingList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📍 All Locations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${filteredLocations.length} places',
                style: TextStyle(color: AC.grey),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredLocations.length,
          itemBuilder: (context, index) =>
              _buildLocationCard(filteredLocations[index]),
        ),
      ],
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location) {
    final isFavorite = favorites.contains(location['name']);
    final crowdLevel = crowdLevels[location['name']] ?? 'Low';
    Color crowdColor = crowdLevel == 'High'
        ? Colors.red
        : crowdLevel == 'Medium'
        ? Colors.orange
        : AC.green;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [location['color'] as Color, (location['color'] as Color).withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(location['icon'] as String, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          location['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: AC.grey),
                const SizedBox(width: 4),
                Text(
                  location['schedule'] as String,
                  style: TextStyle(fontSize: 11, color: AC.grey),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.people, size: 12, color: crowdColor),
                const SizedBox(width: 4),
                Text(
                  'Crowd: $crowdLevel',
                  style: TextStyle(fontSize: 11, color: crowdColor),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : AC.grey,
              ),
              onPressed: () => _toggleFavorite(location['name'] as String),
            ),
            IconButton(
              icon: const Icon(Icons.navigation, color: AC.blue),
              onPressed: () => _startNavigation(location['name'] as String),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Facilities:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (location['facilities'] as List<dynamic>)
                      .map(
                        (f) => Chip(label: Text(f.toString()), backgroundColor: AC.lightGrey),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => _reportIssue(location['name'] as String),
                      icon: const Icon(Icons.warning, size: 18),
                      label: const Text('Report Issue'),
                    ),
                    TextButton.icon(
                      onPressed: () => _showRouteOptions(location['name'] as String),
                      icon: const Icon(Icons.route, size: 18),
                      label: const Text('Get Route'),
                    ),
                    TextButton.icon(
                      onPressed: () => _shareLocation(location['name'] as String),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share'),
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

  Widget _buildFloatingButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickNavigation(),
      backgroundColor: AC.blue,
      icon: const Icon(Icons.my_location, color: Colors.white),
      label: const Text('Find My Way', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      selectedItemColor: AC.blue,
      unselectedItemColor: AC.grey,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) _showFavoritesDialog();
        if (index == 2) _showEventsDialog();
        if (index == 3) _showSettings();
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AC.blue, AC.lightBlue]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    '🗺️ Campus Navigator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'BEEDI College',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Recent Places'),
              onTap: () => _showRecentDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Campus Alerts'),
              trailing: const Icon(
                Icons.brightness_1,
                size: 10,
                color: Colors.red,
              ),
              onTap: () => _showAlerts(),
            ),
            ListTile(
              leading: const Icon(Icons.accessibility),
              title: const Text('Accessibility Mode'),
              trailing: Switch(
                value: showAccessibility,
                onChanged: (v) => setState(() => showAccessibility = v),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_queue),
              title: const Text('Weather Info'),
              trailing: Switch(
                value: showWeather,
                onChanged: (v) => setState(() => showWeather = v),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.traffic),
              title: const Text('Traffic Layer'),
              trailing: Switch(
                value: showTraffic,
                onChanged: (v) => setState(() => showTraffic = v),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () => _showHelp(),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Campus'),
              onTap: () => _showAbout(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DIALOGS AND SHEETS ====================
  void _showBuildingDetails(String buildingName) {
    var building = buildingLocations[buildingName];
    if (building == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(building['icon'] as String, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Text(
                  buildingName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.access_time, 'Schedule', building['schedule'] as String),
            _buildInfoRow(Icons.people, 'Current Crowd', building['crowd'] as String),
            _buildInfoRow(
              Icons.checklist,
              'Facilities',
              (building['facilities'] as List<dynamic>).join(', '),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _startNavigation(buildingName),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(backgroundColor: AC.blue),
                ),
                OutlinedButton.icon(
                  onPressed: () => _toggleFavorite(buildingName),
                  icon: Icon(
                    favorites.contains(buildingName)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  label: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AC.blue),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showNavigationSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Plan Your Route',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedTransportMode,
              items: const ['Walking', 'Bike', 'Campus Bus', 'Wheelchair']
                  .map(
                    (mode) => DropdownMenuItem(value: mode, child: Text(mode)),
                  )
                  .toList(),
              onChanged: (v) =>
                  setState(() => selectedTransportMode = v ?? 'Walking'),
              decoration: const InputDecoration(
                labelText: 'Transport Mode',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedTimeSlot,
              items: const ['Now', 'Depart At', 'Arrive By']
                  .map(
                    (time) => DropdownMenuItem(value: time, child: Text(time)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedTimeSlot = v ?? 'Now'),
              decoration: const InputDecoration(
                labelText: 'Time Preference',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AC.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Start Navigation'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFavoritesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⭐ Favorite Places'),
        content: favorites.isEmpty
            ? const Text(
                'No favorite places yet. Tap the heart icon on any location to add!',
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: favorites.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(favorites[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.navigation),
                      onPressed: () => _startNavigation(favorites[index]),
                    ),
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEventsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Events",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...todayEvents
                .map(
                  (event) => ListTile(
                    leading: const Icon(Icons.event, color: AC.orange),
                    title: Text(event['title'] as String),
                    subtitle: Text('${event['time']} • ${event['location']}'),
                    trailing: TextButton(
                      onPressed: () => _startNavigation(event['location'] as String),
                      child: const Text('Go'),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  void _showCrowdMap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crowd Heat Map'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Real-time crowd levels across campus:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...crowdLevels.entries.map(
                (entry) => ListTile(
                  title: Text(entry.key),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: entry.value == 'High'
                          ? Colors.red
                          : entry.value == 'Medium'
                          ? Colors.orange
                          : AC.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAlerts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔔 Campus Alerts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('East Wing Construction'),
              subtitle: Text('Pathway closed till Dec 25'),
            ),
            ListTile(
              leading: Icon(Icons.cake, color: Colors.pink),
              title: Text('Annual Fest Next Week'),
              subtitle: Text('Dec 20-22, Main Ground'),
            ),
            ListTile(
              leading: Icon(Icons.volunteer_activism, color: AC.green),
              title: Text('Blood Donation Camp'),
              subtitle: Text('Tomorrow, Medical Center'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _shareMap() {
    Clipboard.setData(
      const ClipboardData(text: 'Check out BEEDI College Campus Map! 🗺️'),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('📋 Map link copied!')));
  }

  void _scanQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '📱 QR Scanner would open here (camera permission required)',
        ),
      ),
    );
  }

  void _showRouteOptions(String destination) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Route Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.directions_walk),
              title: const Text('Walking - 5 mins'),
              trailing: const Text('🚶 450m'),
              onTap: () => _startNavigation(destination),
            ),
            ListTile(
              leading: const Icon(Icons.directions_bike),
              title: const Text('Bike - 2 mins'),
              trailing: const Text('🚲 450m'),
              onTap: () => _startNavigation(destination),
            ),
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text('Campus Bus - 3 mins'),
              trailing: const Text('🚌 Stop at Library'),
              onTap: () => _startNavigation(destination),
            ),
          ],
        ),
      ),
    );
  }

  void _shareLocation(String location) {
    Clipboard.setData(
      ClipboardData(text: '📍 Check out $location on BEEDI Campus Map!'),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('📍 Shared $location location!')));
  }

  void _showRecentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recently Visited'),
        content: recentlyVisited.isEmpty
            ? const Text('No recently visited places')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: recentlyVisited
                    .map(
                      (place) => ListTile(
                        title: Text(place),
                        onTap: () => _startNavigation(place),
                      ),
                    )
                    .toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Map Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Satellite View'),
              value: isSatelliteView,
              onChanged: (v) => setState(() => isSatelliteView = v),
            ),
            SwitchListTile(
              title: const Text('3D Buildings'),
              value: show3DBuildings,
              onChanged: (v) => setState(() => show3DBuildings = v),
            ),
            SwitchListTile(
              title: const Text('Show Traffic'),
              value: showTraffic,
              onChanged: (v) => setState(() => showTraffic = v),
            ),
            SwitchListTile(
              title: const Text('Accessibility Mode'),
              value: showAccessibility,
              onChanged: (v) => setState(() => showAccessibility = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Tips'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Tap any building for details',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '• Use FAB to navigate to any location',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '• Save favorites for quick access',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '• Check Events tab for daily activities',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '• Report issues to help improve campus',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Campus Map'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 60, color: AC.blue),
            const SizedBox(height: 12),
            const Text(
              'BEEDI College Campus Map',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Version 2.0.0', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            const Text(
              'Interactive campus navigation with real-time updates',
              style: TextStyle(fontSize: 12, color: AC.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickNavigation() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Navigation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...buildingLocations.keys.take(6).map(
              (building) => ListTile(
                leading: Text(buildingLocations[building]!['icon'] as String),
                title: Text(building),
                trailing: const Icon(Icons.navigation, color: AC.blue),
                onTap: () {
                  Navigator.pop(context);
                  _startNavigation(building);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CUSTOM PAINTER FOR NAVIGATION PATH ====================
class NavigationPathPainter extends CustomPainter {
  final double progress;

  NavigationPathPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AC.blue.withOpacity(0.6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(50, 200);
    path.lineTo(150 + (progress * 100), 150);
    path.lineTo(250 + (progress * 50), 200 + (progress * 50));
    path.lineTo(300, 300);

    canvas.drawPath(path, paint);

    // Draw dashed line effect
    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < 1; i += 0.05) {
      final distance = i * path.computeMetrics().first.length;
      final tangent = path.computeMetrics().first.getTangentForOffset(distance);
      if (tangent != null) {
        canvas.drawCircle(tangent.position, 3, dashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant NavigationPathPainter oldDelegate) =>
      oldDelegate.progress != progress;
}