import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ELibraryScreen extends StatefulWidget {
  const ELibraryScreen({super.key});

  @override
  State<ELibraryScreen> createState() => _ELibraryScreenState();
}

class _ELibraryScreenState extends State<ELibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isGridView = true;
  int _selectedBookIndex = -1;

  final List<String> _categories = [
    'All',
    'Fiction',
    'Academic',
    'Journals',
    'Research Papers',
    'Audio Books',
    'Magazines'
  ];

  final List<Map<String, dynamic>> _books = [
    {
      'title': 'Flutter Complete Guide',
      'author': 'John Doe',
      'category': 'Academic',
      'type': 'ebook',
      'downloads': '1.2k',
      'rating': 4.8,
      'isAvailable': true,
    },
    {
      'title': 'Artificial Intelligence',
      'author': 'Sarah Johnson',
      'category': 'Academic',
      'type': 'ebook',
      'downloads': '950',
      'rating': 4.9,
      'isAvailable': true,
    },
    {
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'category': 'Fiction',
      'type': 'audiobook',
      'downloads': '2.5k',
      'rating': 4.7,
      'isAvailable': true,
    },
    {
      'title': 'Nature Journal 2024',
      'author': 'Nature Publishing',
      'category': 'Journals',
      'type': 'journal',
      'downloads': '3.1k',
      'rating': 4.9,
      'isAvailable': true,
    },
    {
      'title': 'Machine Learning Research',
      'author': 'DeepMind Team',
      'category': 'Research Papers',
      'type': 'research',
      'downloads': '780',
      'rating': 4.8,
      'isAvailable': false,
    },
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {'action': 'Downloaded', 'item': 'Flutter Guide', 'time': '2 hours ago', 'icon': Icons.download},
    {'action': 'Bookmarked', 'item': 'AI Research Paper', 'time': 'Yesterday', 'icon': Icons.bookmark},
    {'action': 'Read', 'item': 'The Great Gatsby', 'time': '2 days ago', 'icon': Icons.menu_book},
  ];

  final List<String> _recommendations = [
    'Based on your reading: "Clean Code"',
    'Popular this week: "Digital Marketing 2024"',
    'New arrival: "Quantum Computing Basics"',
    'From your category: "Psychology of Money"',
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
          _buildSearchBar(),
          _buildCategoryChips(),
          _buildStatsBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLibraryTab(),
                _buildRecentActivityTab(),
                _buildRecommendationsTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF42A5F5),
      title: const Text(
        'E-Library',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showNotificationDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.download_done_outlined),
          onPressed: () => _showDownloadsDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => _showSettingsDialog(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search books, journals, research papers...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () => _showFilterDialog(),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF42A5F5).withOpacity(0.2),
              checkmarkColor: const Color(0xFF42A5F5),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF42A5F5) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('5,000+', 'Books', Icons.menu_book),
          _buildStatItem('200+', 'Journals', Icons.article),
          _buildStatItem('1,000+', 'Papers', Icons.science),
          _buildStatItem('24/7', 'Access', Icons.schedule),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
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
        labelColor: const Color(0xFF42A5F5),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF42A5F5).withOpacity(0.1),
        ),
        tabs: const [
          Tab(text: 'Library', icon: Icon(Icons.menu_book)),
          Tab(text: 'Recent', icon: Icon(Icons.history)),
          Tab(text: 'For You', icon: Icon(Icons.recommend)),
          Tab(text: 'Profile', icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget _buildLibraryTab() {
    final filteredBooks = _books.where((book) {
      final matchesCategory = _selectedCategory == 'All' || book['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          book['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book['author'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredBooks.length} Resources Found',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isGridView ? Icons.grid_view : Icons.list),
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () => _showSortDialog(),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isGridView
              ? GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) => _buildBookCard(filteredBooks[index]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) => _buildBookListItem(filteredBooks[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () => _showBookDetails(book),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.menu_book, size: 50, color: Colors.white),
                  ),
                  if (!book['isAvailable'])
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Text('Not Available', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            book['rating'].toString(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book['author'],
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF42A5F5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book['category'],
                          style: const TextStyle(fontSize: 9, color: Color(0xFF42A5F5)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 16),
                        onPressed: () => _showBookOptions(book),
                      ),
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

  Widget _buildBookListItem(Map<String, dynamic> book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.menu_book, color: Colors.white),
        ),
        title: Text(book['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book['author'], style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    book['category'],
                    style: const TextStyle(fontSize: 10, color: Color(0xFF42A5F5)),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text(' ${book['rating']}'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.cloud_download_outlined),
          onPressed: book['isAvailable']
              ? () => _downloadBook(book)
              : null,
        ),
      ),
    );
  }

  Widget _buildRecentActivityTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentActivities.length,
      itemBuilder: (context, index) {
        final activity = _recentActivities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(activity['icon'], color: const Color(0xFF42A5F5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['action'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(activity['item'], style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Text(activity['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[100]!, Colors.white],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.recommend, color: Color(0xFF42A5F5)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(_recommendations[index])),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF42A5F5),
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text('John Doe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('john.doe@example.edu', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42A5F5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildProfileMenuItem(Icons.bookmark, 'Saved Items', '12 items'),
                _buildProfileMenuItem(Icons.download, 'Downloads', '8 items'),
                _buildProfileMenuItem(Icons.history, 'Reading History', '45 items'),
                _buildProfileMenuItem(Icons.favorite, 'Favorites', '6 items'),
                _buildProfileMenuItem(Icons.help, 'Help & Support', null),
                _buildProfileMenuItem(Icons.logout, 'Logout', null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title, String? subtitle) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF42A5F5)),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showUploadDialog(),
      backgroundColor: const Color(0xFF42A5F5),
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload Resource'),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF42A5F5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  // Dialog Methods
  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(title: Text('New book added'), subtitle: Text('2 hours ago')),
            ListTile(title: Text('Download complete'), subtitle: Text('Yesterday')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showDownloadsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Downloads'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _books.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(_books[index]['title']),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold))),
          const ListTile(leading: Icon(Icons.dark_mode), title: Text('Dark Mode'), trailing: Switch(value: false, onChanged: null)),
          const ListTile(leading: Icon(Icons.notifications), title: Text('Push Notifications'), trailing: Switch(value: true, onChanged: null)),
          const ListTile(leading: Icon(Icons.language), title: Text('Language'), trailing: Text('English')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ListTile(title: Text('Sort by Date'), trailing: Radio(value: 'date', groupValue: 'date', onChanged: null)),
            const ListTile(title: Text('Sort by Rating'), trailing: Radio(value: 'rating', groupValue: 'date', onChanged: null)),
            const ListTile(title: Text('Available Only'), trailing: Checkbox(value: false, onChanged: null)),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Apply Filters')),
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('Sort by', style: TextStyle(fontWeight: FontWeight.bold))),
          const ListTile(title: Text('Title A-Z'), leading: Icon(Icons.sort_by_alpha)),
          const ListTile(title: Text('Most Downloaded'), leading: Icon(Icons.trending_down)),
          const ListTile(title: Text('Highest Rated'), leading: Icon(Icons.star)),
        ],
      ),
    );
  }

  void _showBookDetails(Map<String, dynamic> book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(book['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(book['author'], style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  Text(' ${book['rating']}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.download),
                  Text(' ${book['downloads']} downloads'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.cloud_download, 'Download'),
                  _buildActionButton(Icons.bookmark_border, 'Save'),
                  _buildActionButton(Icons.share, 'Share'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF42A5F5)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showBookOptions(Map<String, dynamic> book) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Details'),
            onTap: () => _showBookDetails(book),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download'),
            onTap: () => _downloadBook(book),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report Issue'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Resource'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(leading: Icon(Icons.upload_file), title: Text('Upload PDF/EPUB')),
            const ListTile(leading: Icon(Icons.link), title: Text('Add URL Link')),
            const ListTile(leading: Icon(Icons.mic), title: Text('Record Audio Book')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _downloadBook(Map<String, dynamic> book) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${book['title']}...'),
        backgroundColor: Colors.green,
        action: SnackBarAction(label: 'View', onPressed: () => _showDownloadsDialog()),
      ),
    );
  }
}