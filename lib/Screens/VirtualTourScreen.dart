import 'package:flutter/material.dart';

class VirtualTourScreen extends StatefulWidget {
  const VirtualTourScreen({super.key});

  @override
  State<VirtualTourScreen> createState() => _VirtualTourScreenState();
}

class _VirtualTourScreenState extends State<VirtualTourScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _buildings = [
    {
      'name': 'Main Campus',
      'description': 'The heart of BEEDI College with modern architecture',
      'facilities': ['Administration Block', 'Central Library', 'Auditorium', 'Cafeteria'],
    },
    {
      'name': 'Engineering Block',
      'description': 'State-of-the-art engineering laboratories and classrooms',
      'facilities': ['Robotics Lab', 'AI Research Center', 'CAD/CAM Lab', 'Smart Classrooms'],
    },
    {
      'name': 'Science Complex',
      'description': 'Advanced scientific research facilities',
      'facilities': ['Physics Lab', 'Chemistry Lab', 'Biotech Center', 'Planetarium'],
    },
    {
      'name': 'Hostel Facilities',
      'description': 'Comfortable accommodation for students',
      'facilities': ['Mess', 'Gymnasium', 'Common Room', 'Wi-Fi Zone'],
    },
    {
      'name': 'Sports Complex',
      'description': 'World-class sports infrastructure',
      'facilities': ['Indoor Stadium', 'Swimming Pool', 'Tennis Courts', 'Football Ground'],
    },
  ];

  final List<Map<String, dynamic>> _tourSpots = [
    {'name': 'Entrance Gate', 'icon': Icons.gite, 'description': 'Welcome to BEEDI College'},
    {'name': 'Main Plaza', 'icon': Icons.location_city, 'description': 'Central gathering area'},
    {'name': 'Academic Block', 'icon': Icons.school, 'description': 'Main academic buildings'},
    {'name': 'Cafeteria', 'icon': Icons.restaurant, 'description': 'Food court area'},
  ];

  final List<Map<String, dynamic>> _videoTours = [
    {'title': 'Campus Overview', 'duration': '3:45', 'views': '12.5K'},
    {'title': 'Lab Walkthrough', 'duration': '5:20', 'views': '8.2K'},
    {'title': 'Hostel Life', 'duration': '4:15', 'views': '15.7K'},
    {'title': 'Library Tour', 'duration': '6:00', 'views': '9.3K'},
  ];

  final List<Map<String, dynamic>> _testimonials = [
    {'name': 'Sarah Johnson', 'year': 'Senior Year', 'text': 'The campus facilities are world-class!', 'rating': 5},
    {'name': 'Michael Chen', 'year': 'Alumni 2023', 'text': 'Best decision to study here', 'rating': 5},
    {'name': 'Priya Sharma', 'year': 'Junior', 'text': 'Amazing learning environment', 'rating': 4},
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
          _buildVRNotice(),
          _buildPanoramaViewer(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBuildingsTab(),
                _buildInteractiveMapTab(),
                _buildVideoToursTab(),
                _buildTestimonialsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF1565C0),
      title: const Text(
        'Virtual Campus Tour',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareTour(),
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showTourInfo(),
        ),
      ],
    );
  }

  Widget _buildVRNotice() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.vrpano, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'VR Mode Available • Use headphones for immersive experience',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () => _enableVRMode(),
            child: const Text(
              'Enable VR',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanoramaViewer() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.panorama, size: 60, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      '360° Virtual Tour',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Drag to look around', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Interactive View', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
        labelColor: const Color(0xFF1565C0),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1565C0).withOpacity(0.1),
        ),
        tabs: const [
          Tab(text: 'Buildings', icon: Icon(Icons.business)),
          Tab(text: 'Map', icon: Icon(Icons.map)),
          Tab(text: 'Videos', icon: Icon(Icons.video_library)),
          Tab(text: 'Reviews', icon: Icon(Icons.rate_review)),
        ],
      ),
    );
  }

  Widget _buildBuildingsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _buildings.length,
      itemBuilder: (context, index) {
        final building = _buildings[index];
        return _buildBuildingCard(building);
      },
    );
  }

  Widget _buildBuildingCard(Map<String, dynamic> building) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(
              child: Icon(Icons.location_city, size: 60, color: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  building['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(building['description'], style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (building['facilities'] as List<String>).map((facility) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        facility,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF1565C0)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _startVirtualTour(building),
                  icon: const Icon(Icons.vrpano),
                  label: const Text('Start 360° Tour'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMapTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.map, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text('Campus Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[100]!, Colors.blue[100]!],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Interactive Map', style: TextStyle(color: Colors.grey)),
                  Text('Tap on buildings for info', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tour Spots',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._tourSpots.map((spot) => ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
              child: Icon(spot['icon'] as IconData, color: const Color(0xFF1565C0)),
            ),
            title: Text(spot['name']),
            subtitle: Text(spot['description']),
            onTap: () => _navigateToSpot(spot['name']),
          )),
        ],
      ),
    );
  }

  Widget _buildVideoToursTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _videoTours.length,
      itemBuilder: (context, index) {
        final video = _videoTours[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () => _playVideo(video),
      child: Container(
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
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[400]!],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_filled, size: 50, color: Colors.white70),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(video['duration'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 8),
                      const Icon(Icons.visibility, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(video['views'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _testimonials.length,
      itemBuilder: (context, index) {
        final testimonial = _testimonials[index];
        return _buildTestimonialCard(testimonial);
      },
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
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
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF1565C0),
                child: Text(testimonial['name'][0], style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(testimonial['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(testimonial['year'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) => 
                  Icon(Icons.star, size: 16, color: index < testimonial['rating'] ? Colors.amber : Colors.grey[300])
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(testimonial['text'], style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _shareTour() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tour link copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showTourInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Virtual Tour'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 360° panoramic views of campus'),
            Text('• Interactive building walkthroughs'),
            Text('• VR headset compatible'),
            Text('• Student testimonials'),
            SizedBox(height: 12),
            Text('For best experience, use headphones.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _enableVRMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('VR Mode Enabled! Put your phone in a VR headset.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startVirtualTour(Map<String, dynamic> building) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Starting ${building['name']} Tour'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.vrpano, size: 60),
            SizedBox(height: 16),
            Text('Loading 360° experience...'),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }

  void _navigateToSpot(String spotName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $spotName...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _playVideo(Map<String, dynamic> video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(video['title']),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_filled, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text('Duration: ${video['duration']} • ${video['views']} views'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () {}, child: const Text('Watch Now')),
        ],
      ),
    );
  }
}