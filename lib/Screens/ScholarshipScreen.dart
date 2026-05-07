import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ==================== COLOR CONSTANTS ====================
class AC {
  static const Color bg = Color(0xFFF8FAFF);
  static const Color white = Colors.white;
  static const Color blue = Color(0xFF42A5F5);
  static const Color darkBlue = Color(0xFF1E88E5);
  static const Color deepBlue = Color(0xFF1565C0);
  static const Color green = Color(0xFF10B981);
  static const Color orange = Color(0xFFF59E0B);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color red = Color(0xFFEF4444);
  static const Color pink = Color(0xFFEC4899);
  static const Color teal = Color(0xFF14B8A6);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFF1F5F9);
}

// ==================== MAIN SCHOLARSHIP SCREEN ====================
class ScholarshipScreen extends StatefulWidget {
  const ScholarshipScreen({super.key});

  @override
  State<ScholarshipScreen> createState() => _ScholarshipScreenState();
}

class _ScholarshipScreenState extends State<ScholarshipScreen>
    with SingleTickerProviderStateMixin {
  // ==================== STATE VARIABLES ====================
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedAmount = 'All';
  String selectedDeadline = 'All';
  String selectedEligibility = 'All';
  bool isGridView = false;
  bool isDarkMode = false;
  Set<String> savedScholarships = {};
  Set<String> appliedScholarships = {};
  Set<String> scholarshipAlerts = {};
  List<String> recentlyViewed = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  String sortBy = 'deadline';
  Map<String, bool> expandedScholarships = {};
  Map<String, double> matchPercentages = {};

  // User profile for eligibility
  Map<String, dynamic> userProfile = {
    'cpi': 8.2,
    'annualIncome': 450000,
    'category': 'General',
    'gender': 'Female',
    'stream': 'Engineering',
  };

  final List<Map<String, dynamic>> allScholarships = [
    {
      'title': 'Merit Scholarship',
      'amount': '₹75,000/year',
      'amountNum': 75000,
      'provider': 'AICTE',
      'deadline': '2024-12-31',
      'category': 'Merit',
      'eligibility': 'CPI > 8.5',
      'description': 'For top-performing students across all streams',
      'icon': '🏆',
      'color': const Color(0xFFFFD700),
      'requirements': ['CPI > 8.5', 'No backlogs', 'Regular attendance'],
    },
    {
      'title': 'SC/ST Fellowship',
      'amount': '₹50,000/year',
      'amountNum': 50000,
      'provider': 'Govt of India',
      'deadline': '2024-12-15',
      'category': 'Caste Based',
      'eligibility': 'SC/ST candidates',
      'description': 'Financial assistance for SC/ST students',
      'icon': '🎓',
      'color': AC.blue,
      'requirements': [
        'Caste certificate',
        'Income < 6L',
        'College enrollment',
      ],
    },
    {
      'title': 'Sports Excellence',
      'amount': '₹40,000/year',
      'amountNum': 40000,
      'provider': 'Sports Authority',
      'deadline': '2024-12-20',
      'category': 'Sports',
      'eligibility': 'State/National level',
      'description': 'For outstanding sportspersons',
      'icon': '⚽',
      'color': AC.green,
      'requirements': [
        'Sports certificates',
        'Participation proof',
        'Coach recommendation',
      ],
    },
    {
      'title': 'Research Grant',
      'amount': '₹2,00,000',
      'amountNum': 200000,
      'provider': 'CSIR',
      'deadline': '2025-01-15',
      'category': 'Research',
      'eligibility': 'PhD students',
      'description': 'For PhD research projects',
      'icon': '🔬',
      'color': AC.purple,
      'requirements': [
        'Research proposal',
        'Guide approval',
        'Publications preferred',
      ],
    },
    {
      'title': 'Girls Empowerment',
      'amount': '₹30,000/year',
      'amountNum': 30000,
      'provider': 'Beti Bachao',
      'deadline': '2024-12-25',
      'category': 'Gender Based',
      'eligibility': 'Girl students',
      'description': 'Empowering girl child education',
      'icon': '👧',
      'color': AC.pink,
      'requirements': ['Female student', 'CPI > 7.0', 'Family income < 5L'],
    },
    {
      'title': 'OBC Scholarship',
      'amount': '₹35,000/year',
      'amountNum': 35000,
      'provider': 'Backward Classes',
      'deadline': '2024-12-28',
      'category': 'Caste Based',
      'eligibility': 'OBC candidates',
      'description': 'For OBC students',
      'icon': '🤝',
      'color': AC.orange,
      'requirements': ['OBC certificate', 'Income < 6L', 'Valid enrollment'],
    },
    {
      'title': 'Prime Minister\'s Scholarship',
      'amount': '₹90,000/year',
      'amountNum': 90000,
      'provider': 'PM Office',
      'deadline': '2025-01-10',
      'category': 'Merit',
      'eligibility': 'Top 5%',
      'description': 'Prestigious national scholarship',
      'icon': '🇮🇳',
      'color': AC.deepBlue,
      'requirements': [
        'Top 5% in board exams',
        'National level exam score',
        'Interview',
      ],
    },
    {
      'title': 'Digital India Scholarship',
      'amount': '₹45,000/year',
      'amountNum': 45000,
      'provider': 'MeitY',
      'deadline': '2024-12-30',
      'category': 'Stream Based',
      'eligibility': 'CS/IT students',
      'description': 'For digital skills development',
      'icon': '💻',
      'color': AC.teal,
      'requirements': ['CS/IT branch', 'Portfolio', 'Coding skills'],
    },
    {
      'title': 'Women in STEM',
      'amount': '₹60,000/year',
      'amountNum': 60000,
      'provider': 'Google',
      'deadline': '2025-01-05',
      'category': 'Gender Based',
      'eligibility': 'Girls in STEM',
      'description': 'Encouraging women in technology',
      'icon': '👩‍💻',
      'color': AC.purple,
      'requirements': ['STEM field', 'Project work', 'Leadership skills'],
    },
    {
      'title': 'North East Scholarship',
      'amount': '₹40,000/year',
      'amountNum': 40000,
      'provider': 'North East Council',
      'deadline': '2024-12-18',
      'category': 'Regional',
      'eligibility': 'NE students',
      'description': 'For North Eastern students',
      'icon': '🏔️',
      'color': AC.green,
      'requirements': ['Domicile of NE state', 'Enrollment proof'],
    },
  ];

  List<String> get categories => [
    'All',
    'Merit',
    'Caste Based',
    'Gender Based',
    'Sports',
    'Research',
    'Stream Based',
    'Regional',
  ];
  List<String> get amountRanges => [
    'All',
    'Under ₹40,000',
    '₹40,000 - ₹60,000',
    '₹60,000 - ₹1,00,000',
    'Above ₹1,00,000',
  ];
  List<String> get deadlines => [
    'All',
    'This Week',
    'This Month',
    'Next Month',
  ];
  List<String> get eligibilityLevels => [
    'All',
    'CPI > 8.5',
    'CPI > 8.0',
    'CPI > 7.5',
    'CPI > 7.0',
  ];

  List<Map<String, dynamic>> get filteredScholarships {
    var filtered = allScholarships.where((s) {
      if (searchQuery.isNotEmpty &&
          !s['title'].toLowerCase().contains(searchQuery.toLowerCase()) &&
          !s['provider'].toLowerCase().contains(searchQuery.toLowerCase()))
        return false;
      if (selectedCategory != 'All' && s['category'] != selectedCategory)
        return false;

      if (selectedAmount != 'All') {
        if (selectedAmount == 'Under ₹40,000' && s['amountNum'] >= 40000)
          return false;
        if (selectedAmount == '₹40,000 - ₹60,000' &&
            (s['amountNum'] < 40000 || s['amountNum'] > 60000))
          return false;
        if (selectedAmount == '₹60,000 - ₹1,00,000' &&
            (s['amountNum'] < 60000 || s['amountNum'] > 100000))
          return false;
        if (selectedAmount == 'Above ₹1,00,000' && s['amountNum'] <= 100000)
          return false;
      }

      return true;
    }).toList();

    switch (sortBy) {
      case 'amountHigh':
        filtered.sort((a, b) => b['amountNum'].compareTo(a['amountNum']));
        break;
      case 'amountLow':
        filtered.sort((a, b) => a['amountNum'].compareTo(b['amountNum']));
        break;
      case 'deadline':
        filtered.sort((a, b) => a['deadline'].compareTo(b['deadline']));
        break;
    }
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController.addListener(_onScroll);
    _calculateMatches();
  }

  void _calculateMatches() {
    for (var s in allScholarships) {
      double match = 65;
      if (userProfile['cpi'] >= 8.5 && s['eligibility'].contains('8.5'))
        match += 15;
      else if (userProfile['cpi'] >= 8.0 && s['eligibility'].contains('8.0'))
        match += 12;
      else if (userProfile['cpi'] >= 7.5)
        match += 8;
      matchPercentages[s['title']] = match.clamp(45, 98).toDouble();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !isLoading &&
        hasMore) {
      setState(() => isLoading = true);
      Future.delayed(
        const Duration(milliseconds: 800),
        () => setState(() {
          currentPage++;
          if (currentPage >= 2) hasMore = false;
          isLoading = false;
        }),
      );
    }
  }

  void _toggleSave(String title) {
    setState(() {
      if (savedScholarships.contains(title)) {
        savedScholarships.remove(title);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Removed from saved'),
            backgroundColor: AC.grey,
          ),
        );
      } else {
        savedScholarships.add(title);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⭐ Saved to favorites'),
            backgroundColor: AC.green,
          ),
        );
      }
    });
  }

  void _applyNow(Map<String, dynamic> scholarship) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(scholarship['icon']),
            const SizedBox(width: 10),
            Expanded(child: Text(scholarship['title'])),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match: ${matchPercentages[scholarship['title']]?.toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            LinearProgressIndicator(
              value: (matchPercentages[scholarship['title']] ?? 70) / 100,
              backgroundColor: Colors.grey[200],
              color: AC.green,
            ),
            const SizedBox(height: 12),
            const Text(
              'Required Documents:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...(scholarship['requirements'] as List).map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: AC.green),
                    const SizedBox(width: 8),
                    Text(r, style: const TextStyle(fontSize: 12)),
                  ],
                ),
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
              setState(() => appliedScholarships.add(scholarship['title']));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application submitted!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AC.blue),
            child: const Text('Confirm Apply'),
          ),
        ],
      ),
    );
  }

  void _shareScholarship(String title, String provider, String amount) {
    Clipboard.setData(
      ClipboardData(
        text: '🏆 Scholarship: $title by $provider - $amount. Apply now!',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 Scholarship details copied!')),
    );
  }

  int getDaysLeft(String deadline) {
    try {
      return DateTime.parse(deadline).difference(DateTime.now()).inDays;
    } catch (e) {
      return 15;
    }
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
        body: Column(
          children: [
            _buildSearchBar(),
            _buildStatsBar(),
            _buildCategoryChips(),
            _buildFilterBar(),
            _buildAdvancedFilters(),
            Expanded(child: _buildMainContent()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showEligibilityChecker(),
          backgroundColor: AC.blue,
          icon: const Icon(Icons.verified_user),
          label: const Text('Check Eligibility'),
        ),
      ),
    );
  }

  PreferredSizeWidget _advancedAppBar() => AppBar(
    backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
    elevation: 0,
    title: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AC.blue, AC.darkBlue]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('🏆'),
        ),
        const SizedBox(width: 12),
        const Text(
          'Scholarships',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AC.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${filteredScholarships.length} Available',
            style: TextStyle(color: AC.green, fontWeight: FontWeight.bold),
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
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => _showSavedDialog(),
          ),
          if (savedScholarships.isNotEmpty)
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
    ],
  );

  Widget _buildSearchBar() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    ),
    child: TextField(
      onChanged: (v) => setState(() => searchQuery = v),
      decoration: InputDecoration(
        hintText: '🔍 Search scholarships, providers...',
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
  );

  Widget _buildStatsBar() {
    double avgMatch = matchPercentages.values.isEmpty
        ? 70
        : matchPercentages.values.reduce((a, b) => a + b) /
              matchPercentages.values.length;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AC.blue, AC.darkBlue]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AC.blue.withOpacity(0.3), blurRadius: 15)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Eligibility Score',
                  style: TextStyle(color: Colors.white),
                ),
                LinearProgressIndicator(
                  value: avgMatch / 100,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(10),
                ),
                Text(
                  '${avgMatch.toStringAsFixed(0)}% Match • ${filteredScholarships.length} scholarships',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: categories
          .map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat),
                selected: selectedCategory == cat,
                onSelected: (s) => setState(() => selectedCategory = cat),
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                selectedColor: AC.blue.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: selectedCategory == cat ? AC.blue : AC.grey,
                ),
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _buildFilterBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _showFilterSheet(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AC.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.filter_list, size: 18, color: AC.blue),
                    SizedBox(width: 4),
                    Text('Filters'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showSortDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AC.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.sort, size: 18, color: AC.green),
                    SizedBox(width: 4),
                    Text('Sort'),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                isGridView ? Icons.view_list : Icons.grid_view,
                color: AC.blue,
              ),
              onPressed: () => setState(() => isGridView = !isGridView),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.recommend, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text('AI Picks', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildAdvancedFilters() {
    if (selectedAmount == 'All' &&
        selectedDeadline == 'All' &&
        selectedEligibility == 'All')
      return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AC.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (selectedAmount != 'All')
            Chip(
              label: Text('💰 $selectedAmount'),
              onDeleted: () => setState(() => selectedAmount = 'All'),
              backgroundColor: AC.blue.withOpacity(0.1),
            ),
          if (selectedDeadline != 'All')
            Chip(
              label: Text('📅 $selectedDeadline'),
              onDeleted: () => setState(() => selectedDeadline = 'All'),
              backgroundColor: AC.orange.withOpacity(0.1),
            ),
          if (selectedEligibility != 'All')
            Chip(
              label: Text('🎯 $selectedEligibility'),
              onDeleted: () => setState(() => selectedEligibility = 'All'),
              backgroundColor: AC.green.withOpacity(0.1),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (isLoading && currentPage == 0) return _buildShimmerList();
    if (filteredScholarships.isEmpty) return _buildEmptyState();
    return isGridView
        ? GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredScholarships.length + (hasMore ? 1 : 0),
            itemBuilder: (context, i) => i == filteredScholarships.length
                ? _buildLoadingIndicator()
                : _buildScholarshipCard(filteredScholarships[i]),
          )
        : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filteredScholarships.length + (hasMore ? 1 : 0),
            itemBuilder: (context, i) => i == filteredScholarships.length
                ? _buildLoadingIndicator()
                : _buildScholarshipCard(filteredScholarships[i]),
          );
  }

  Widget _buildScholarshipCard(Map<String, dynamic> s) {
    final isSaved = savedScholarships.contains(s['title']);
    final isApplied = appliedScholarships.contains(s['title']);
    final daysLeft = getDaysLeft(s['deadline']);
    final match = matchPercentages[s['title']] ?? 70;
    final isExpanded = expandedScholarships[s['title']] ?? false;

    return GestureDetector(
      onTap: () =>
          setState(() => expandedScholarships[s['title']] = !isExpanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15),
          ],
          border: Border.all(
            color: daysLeft < 7
                ? Colors.red.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [s['color'], s['color'].withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            s['icon'],
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              s['provider'],
                              style: TextStyle(color: AC.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AC.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              s['amount'],
                              style: const TextStyle(
                                color: AC.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (daysLeft < 7)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$daysLeft days left',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: match / 100,
                          backgroundColor: Colors.grey[200],
                          color: match > 80
                              ? AC.green
                              : match > 60
                              ? Colors.orange
                              : AC.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${match.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: match > 80 ? AC.green : AC.blue,
                        ),
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      s['description'],
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '📋 ${s['eligibility']}',
                      style: const TextStyle(fontSize: 12, color: AC.grey),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: (isDarkMode ? Colors.grey[850] : AC.lightGrey)
                    ?.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isApplied ? null : () => _applyNow(s),
                      icon: Icon(
                        isApplied ? Icons.check : Icons.send,
                        size: 18,
                      ),
                      label: Text(isApplied ? 'Applied' : 'Apply Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApplied ? AC.green : AC.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? AC.blue : AC.grey,
                    ),
                    onPressed: () => _toggleSave(s['title']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareScholarship(
                      s['title'],
                      s['provider'],
                      s['amount'],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() => ListView.builder(
    itemCount: 5,
    itemBuilder: (_, __) => Container(
      margin: const EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  Widget _buildLoadingIndicator() => const Padding(
    padding: EdgeInsets.all(20),
    child: Center(child: CircularProgressIndicator(color: AC.blue)),
  );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 80, color: AC.grey),
        const SizedBox(height: 16),
        Text(
          'No scholarships found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AC.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text('Try adjusting your filters', style: TextStyle(color: AC.grey)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => setState(() {
            selectedCategory = 'All';
            selectedAmount = 'All';
            selectedDeadline = 'All';
            searchQuery = '';
          }),
          child: const Text('Clear Filters'),
        ),
      ],
    ),
  );

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Advanced Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: selectedAmount,
                items: amountRanges
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) => setSheetState(() => selectedAmount = v!),
                decoration: const InputDecoration(
                  labelText: 'Amount Range',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: selectedDeadline,
                items: deadlines
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setSheetState(() => selectedDeadline = v!),
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: selectedEligibility,
                items: eligibilityLevels
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setSheetState(() => selectedEligibility = v!),
                decoration: const InputDecoration(
                  labelText: 'Eligibility',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedAmount = selectedAmount;
                    selectedDeadline = selectedDeadline;
                    selectedEligibility = selectedEligibility;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AC.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Scholarships'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Deadline (Soonest first)'),
              value: 'deadline',
              groupValue: sortBy,
              onChanged: (v) => setState(() => sortBy = v as String),
            ),
            RadioListTile(
              title: const Text('Amount (High to Low)'),
              value: 'amountHigh',
              groupValue: sortBy,
              onChanged: (v) => setState(() => sortBy = v as String),
            ),
            RadioListTile(
              title: const Text('Amount (Low to High)'),
              value: 'amountLow',
              groupValue: sortBy,
              onChanged: (v) => setState(() => sortBy = v as String),
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

  void _showSavedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Scholarships'),
        content: savedScholarships.isEmpty
            ? const Text('No saved scholarships')
            : Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: savedScholarships.length,
                  itemBuilder: (context, i) => ListTile(
                    title: Text(savedScholarships.elementAt(i)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(
                        () => savedScholarships.remove(
                          savedScholarships.elementAt(i),
                        ),
                      ),
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

  void _showEligibilityChecker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Eligibility Checker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: userProfile['cpi'].toString(),
              decoration: const InputDecoration(
                labelText: 'Current CPI',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(
                () => userProfile['cpi'] = double.tryParse(v) ?? 8.0,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: userProfile['annualIncome'].toString(),
              decoration: const InputDecoration(
                labelText: 'Annual Family Income (₹)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(
                () => userProfile['annualIncome'] = int.tryParse(v) ?? 500000,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: userProfile['category'],
              items: [
                'General',
                'OBC',
                'SC',
                'ST',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => userProfile['category'] = v!),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _calculateMatches();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Eligibility recalculated!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AC.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Update & Check'),
            ),
          ],
        ),
      ),
    );
  }
}
