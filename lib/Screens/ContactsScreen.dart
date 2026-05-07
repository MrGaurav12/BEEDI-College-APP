import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  
  // Main contact info
  final Map<String, dynamic> _mainContact = {
    'phone': '+91-98765-43210',
    'email': 'info@beedicollege.ac.in',
    'address': 'BEEDI Campus, Hajipur, Vaishali – 844101',
    'officeHours': 'Mon–Sat, 9 AM – 5 PM',
    'admissionHelpline': '+91-80001-23456',
    'website': 'www.beedicollege.ac.in',
  };
  
  // Department contacts
  final List<Map<String, dynamic>> _departments = [
    {
      'name': 'Admissions Office',
      'phone': '+91-80001-23456',
      'email': 'admissions@beedicollege.ac.in',
      'extension': '101',
      'timings': '9 AM - 6 PM',
      'icon': Icons.school,
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Academic Affairs',
      'phone': '+91-98765-12345',
      'email': 'academics@beedicollege.ac.in',
      'extension': '102',
      'timings': '10 AM - 5 PM',
      'icon': Icons.book,
      'color': Color(0xFF4CAF50),
    },
    {
      'name': 'Examination Cell',
      'phone': '+91-98765-23456',
      'email': 'exams@beedicollege.ac.in',
      'extension': '103',
      'timings': '9:30 AM - 4:30 PM',
      'icon': Icons.assignment,
      'color': Color(0xFFFF9800),
    },
    {
      'name': 'Student Affairs',
      'phone': '+91-98765-34567',
      'email': 'studentaffairs@beedicollege.ac.in',
      'extension': '104',
      'timings': '9 AM - 5 PM',
      'icon': Icons.people,
      'color': Color(0xFF9C27B0),
    },
    {
      'name': 'Placement Cell',
      'phone': '+91-98765-45678',
      'email': 'placements@beedicollege.ac.in',
      'extension': '105',
      'timings': '10 AM - 6 PM',
      'icon': Icons.work,
      'color': Color(0xFFE91E63),
    },
    {
      'name': 'Library Services',
      'phone': '+91-98765-56789',
      'email': 'library@beedicollege.ac.in',
      'extension': '106',
      'timings': '8 AM - 8 PM',
      'icon': Icons.library_books,
      'color': Color(0xFF607D8B),
    },
    {
      'name': 'Hostel Management',
      'phone': '+91-98765-67890',
      'email': 'hostel@beedicollege.ac.in',
      'extension': '107',
      'timings': '9 AM - 5 PM',
      'icon': Icons.hotel,
      'color': Color(0xFF795548),
    },
    {
      'name': 'Transport Office',
      'phone': '+91-98765-78901',
      'email': 'transport@beedicollege.ac.in',
      'extension': '108',
      'timings': '8 AM - 6 PM',
      'icon': Icons.directions_bus,
      'color': Color(0xFF00BCD4),
    },
    {
      'name': 'Finance & Accounts',
      'phone': '+91-98765-89012',
      'email': 'accounts@beedicollege.ac.in',
      'extension': '109',
      'timings': '10 AM - 4 PM',
      'icon': Icons.account_balance,
      'color': Color(0xFF3F51B5),
    },
    {
      'name': 'International Relations',
      'phone': '+91-98765-90123',
      'email': 'international@beedicollege.ac.in',
      'extension': '110',
      'timings': '10 AM - 5 PM',
      'icon': Icons.public,
      'color': Color(0xFF009688),
    },
  ];
  
  // Emergency contacts
  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      'name': 'Security Control Room',
      'phone': '+91-98765-01234',
      'extension': '199',
      'type': 'Security',
      'icon': Icons.security,
      'color': Color(0xFFF44336),
    },
    {
      'name': 'Campus Health Center',
      'phone': '+91-98765-12345',
      'extension': '108',
      'type': 'Medical',
      'icon': Icons.local_hospital,
      'color': Color(0xFF4CAF50),
    },
    {
      'name': 'Women Helpline',
      'phone': '+91-98765-23456',
      'extension': '109',
      'type': 'Support',
      'icon': Icons.woman,
      'color': Color(0xFFE91E63),
    },
    {
      'name': 'Anti-Ragging Helpline',
      'phone': '+91-98765-34567',
      'extension': '110',
      'type': 'Safety',
      'icon': Icons.report,
      'color': Color(0xFFFF5722),
    },
  ];
  
  // Social media links
  final List<Map<String, dynamic>> _socialMedia = [
    {
      'name': 'Facebook',
      'handle': '@BEEDICollege',
      'url': 'https://facebook.com/beedicollege',
      'icon': Icons.facebook,
      'color': Color(0xFF1877F2),
    },
    {
      'name': 'Twitter',
      'handle': '@BEEDICollege',
      'url': 'https://twitter.com/beedicollege',
      'icon': Icons.abc,
      'color': Color(0xFF1DA1F2),
    },
    {
      'name': 'Instagram',
      'handle': '@beedicollege',
      'url': 'https://instagram.com/beedicollege',
      'icon': Icons.camera_alt,
      'color': Color(0xFFE4405F),
    },
    {
      'name': 'LinkedIn',
      'handle': 'BEEDI College',
      'url': 'https://linkedin.com/school/beedicollege',
      'icon': Icons.business,
      'color': Color(0xFF0077B5),
    },
    {
      'name': 'YouTube',
      'handle': 'BEEDI College',
      'url': 'https://youtube.com/beedicollege',
      'icon': Icons.play_circle_filled,
      'color': Color(0xFFFF0000),
    },
  ];
  
  // Important locations
  final List<Map<String, dynamic>> _locations = [
    {
      'name': 'Main Campus',
      'address': 'BEEDI Campus, Hajipur, Vaishali – 844101',
      'landmark': 'Near Gandhi Setu',
      'coordinates': '25.6850° N, 85.2750° E',
    },
    {
      'name': 'City Office',
      'address': 'Patna Main Road, Near Gandhi Maidan',
      'landmark': 'Patna - 800001',
      'coordinates': '25.5941° N, 85.1376° E',
    },
  ];
  
  // Feedback categories
  final List<String> _feedbackCategories = [
    'General Query',
    'Academic Issue',
    'Technical Support',
    'Complaint',
    'Suggestion',
    'Other',
  ];
  String _selectedFeedbackCategory = 'General Query';

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
          _buildQuickActions(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDepartmentsTab(),
                _buildEmergencyTab(),
                _buildReachUsTab(),
                _buildFeedbackTab(),
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
      backgroundColor: const Color(0xFF42A5F5),
      title: const Text(
        'Contacts',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareContacts(),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.contact_phone, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Get in Touch',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _mainContact['address'],
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              Icons.phone,
              'Call',
              Colors.green,
              () => _makePhoneCall(_mainContact['admissionHelpline']),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickAction(
              Icons.email,
              'Email',
              Colors.blue,
              () => _sendEmail(_mainContact['email']),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickAction(
              Icons.map,
              'Location',
              Colors.orange,
              () => _openMap(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
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
        labelColor: const Color(0xFF42A5F5),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF42A5F5).withOpacity(0.1),
        ),
        tabs: const [
          Tab(text: 'Departments', icon: Icon(Icons.business)),
          Tab(text: 'Emergency', icon: Icon(Icons.warning)),
          Tab(text: 'Reach Us', icon: Icon(Icons.location_on)),
          Tab(text: 'Feedback', icon: Icon(Icons.feedback)),
        ],
      ),
    );
  }

  Widget _buildDepartmentsTab() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _departments.length,
            itemBuilder: (context, index) {
              final dept = _departments[index];
              if (_searchQuery.isNotEmpty &&
                  !dept['name'].toLowerCase().contains(_searchQuery.toLowerCase())) {
                return const SizedBox.shrink();
              }
              return _buildDepartmentCard(dept);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search departments...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> department) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [(department['color'] as Color), (department['color'] as Color).withOpacity(0.7)],
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
                  child: Icon(department['icon'] as IconData, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Ext: ${department['extension']}',
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
                    department['timings'],
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildContactButton(
                    Icons.phone,
                    'Call',
                    Colors.green,
                    () => _makePhoneCall(department['phone']),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildContactButton(
                    Icons.email,
                    'Email',
                    Colors.blue,
                    () => _sendEmail(department['email']),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildContactButton(
                    Icons.message,
                    'WhatsApp',
                    Colors.green,
                    () => _sendWhatsApp(department['phone']),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildEmergencyAlert(),
          const SizedBox(height: 16),
          ..._emergencyContacts.map((contact) => _buildEmergencyCard(contact)),
          const SizedBox(height: 16),
          _buildSafetyTips(),
        ],
      ),
    );
  }

  Widget _buildEmergencyAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[600]!, Colors.red[800]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency? Call 24/7 Helpline',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _emergencyContacts[0]['phone'],
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _makePhoneCall(_emergencyContacts[0]['phone']),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (contact['color'] as Color).withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (contact['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(contact['icon'] as IconData, color: contact['color'], size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Ext: ${contact['extension']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _makePhoneCall(contact['phone']),
            style: ElevatedButton.styleFrom(
              backgroundColor: contact['color'],
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(Icons.phone, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTips() {
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
            'Safety Tips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTipItem('📱 Keep emergency numbers saved in your phone'),
          _buildTipItem('🚶‍♀️ Travel in groups during late hours'),
          _buildTipItem('🔒 Report any suspicious activity to security'),
          _buildTipItem('📞 Use campus helpline for immediate assistance'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildReachUsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLocationCard(),
          const SizedBox(height: 16),
          _buildMapPlaceholder(),
          const SizedBox(height: 16),
          _buildSocialMediaSection(),
          const SizedBox(height: 16),
          _buildOfficeHours(),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
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
            'Our Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._locations.map((location) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF42A5F5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(location['address'], style: const TextStyle(fontSize: 12)),
                      Text(location['landmark'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _openMap(),
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42A5F5),
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: const NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=25.6850,85.2750&zoom=13&size=400x200&key=YOUR_API_KEY'),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => null,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 50, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Interactive Map',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
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
            'Connect With Us',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _socialMedia.map((social) => GestureDetector(
              onTap: () => _openSocialMedia(social['url']),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(social['icon'] as IconData, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(social['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(social['handle'], style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeHours() {
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
            'Office Hours',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildHourRow('Monday - Friday', '9:00 AM - 6:00 PM'),
          _buildHourRow('Saturday', '9:00 AM - 5:00 PM'),
          _buildHourRow('Sunday', 'Closed'),
          _buildHourRow('Emergency Support', '24/7 Available'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Visiting hours: 10 AM - 4 PM (Monday to Friday)',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(hours, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFeedbackForm(),
          const SizedBox(height: 16),
          _buildFAQ(),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
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
            'Send Feedback',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedFeedbackCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _feedbackCategories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
            onChanged: (value) => setState(() => _selectedFeedbackCategory = value!),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _submitFeedback(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42A5F5),
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('Submit Feedback'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
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
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildFAQItem('How do I contact admission office?', 'Call +91-80001-23456 or email admissions@beedicollege.ac.in'),
          _buildFAQItem('What are the office hours?', 'Monday to Saturday, 9 AM to 5 PM'),
          _buildFAQItem('How to reach the campus?', 'Located near Gandhi Setu, Hajipur. Regular buses and autos available.'),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _quickContact(),
      backgroundColor: const Color(0xFF42A5F5),
      child: const Icon(Icons.chat),
    );
  }

  // Action Methods
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Contacts'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter department name...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
            _tabController.animateTo(0);
          },
        ),
      ),
    );
  }

  void _shareContacts() async {
    String contactInfo = '''
BEEDI College Contact Information

Main Contact:
Phone: ${_mainContact['phone']}
Email: ${_mainContact['email']}
Address: ${_mainContact['address']}
Admission Helpline: ${_mainContact['admissionHelpline']}

For more information, visit: ${_mainContact['website']}
    ''';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact info copied!'), backgroundColor: Colors.green),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  void _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email app')),
      );
    }
  }

  void _sendWhatsApp(String phoneNumber) async {
    String whatsappUrl = "https://wa.me/${phoneNumber.replaceAll('-', '').replaceAll('+', '')}";
    final Uri launchUri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp not installed')),
      );
    }
  }

  void _openMap() async {
    String address = _mainContact['address'];
    String encodedAddress = Uri.encodeComponent(address);
    final Uri launchUri = Uri.parse('https://maps.google.com/?q=$encodedAddress');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps')),
      );
    }
  }

  void _openSocialMedia(String url) async {
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${url.split('/')[2]}')),
      );
    }
  }

  void _submitFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback submitted! Thank you.'), backgroundColor: Colors.green),
    );
  }

  void _quickContact() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quick Contact', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call Helpline'),
              subtitle: Text(_mainContact['admissionHelpline']),
              onTap: () {
                Navigator.pop(context);
                _makePhoneCall(_mainContact['admissionHelpline']);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Send Email'),
              subtitle: Text(_mainContact['email']),
              onTap: () {
                Navigator.pop(context);
                _sendEmail(_mainContact['email']);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('WhatsApp'),
              subtitle: Text(_mainContact['admissionHelpline']),
              onTap: () {
                Navigator.pop(context);
                _sendWhatsApp(_mainContact['admissionHelpline']);
              },
            ),
          ],
        ),
      ),
    );
  }
}