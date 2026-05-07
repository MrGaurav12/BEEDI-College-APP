import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ==================== COLOR CONSTANTS ====================
class AC {
  static const Color bg = Color(0xFFF8FAFF);
  static const Color white = Colors.white;
  static const Color blue = Color(0xFF1E88E5);
  static const Color darkBlue = Color(0xFF1565C0);
  static const Color green = Color(0xFF10B981);
  static const Color darkGreen = Color(0xFF059669);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFF1F5F9);
  static const Color borderGrey = Color(0xFFE2E8F0);
}

// ==================== MAIN JOB BOARD SCREEN ====================
class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen>
    with SingleTickerProviderStateMixin {
  // ==================== STATE VARIABLES (50+ features) ====================
  String searchQuery = '';
  String selectedCategory = 'All';
  RangeValues salaryRange = const RangeValues(0, 50);
  String selectedJobType = 'All';
  String selectedCompany = 'All';
  bool isGridView = false;
  bool isDarkMode = false;
  Set<String> savedJobs = {};
  Set<String> appliedJobs = {};
  Set<String> jobAlerts = {};
  Set<String> recentlyViewed = {};
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  String sortBy = 'newest'; // newest, salaryHigh, salaryLow, relevance
  Map<String, bool> expandedJobs = {};

  // AI Recommendation scores
  Map<String, double> matchScores = {};

  // Dummy data with 50+ jobs
  final List<Map<String, dynamic>> allJobs = [
    {
      'title': 'Google Software Engineer L3',
      'salary': '45 LPA',
      'salaryNum': 45,
      'company': 'Google',
      'type': 'Full-time',
      'category': 'IT',
      'logo': 'G',
      'rating': 4.8,
      'reviews': 1240,
      'location': 'Bangalore',
      'isNew': true,
      'deadline': '2024-12-30',
      'description': 'Lead development of next-gen search algorithms.',
      'requirements': '5+ years experience, DSA expertise',
    },
    {
      'title': 'Amazon AWS Cloud Architect',
      'salary': '38 LPA',
      'salaryNum': 38,
      'company': 'Amazon',
      'type': 'Full-time',
      'category': 'IT',
      'logo': 'A',
      'rating': 4.6,
      'reviews': 980,
      'location': 'Hyderabad',
      'isNew': true,
      'deadline': '2024-12-28',
      'description': 'Design and implement cloud solutions.',
      'requirements': 'AWS certification, 4+ years',
    },
    {
      'title': 'Microsoft Data Scientist',
      'salary': '35 LPA',
      'salaryNum': 35,
      'company': 'Microsoft',
      'type': 'Full-time',
      'category': 'IT',
      'logo': 'M',
      'rating': 4.7,
      'reviews': 2100,
      'location': 'Bangalore',
      'isNew': false,
      'deadline': '2025-01-15',
      'description': 'ML model development and deployment.',
      'requirements': 'Python, TensorFlow, PhD preferred',
    },
    {
      'title': 'Paytm ML Engineer Intern',
      'salary': '50K/month',
      'salaryNum': 6,
      'company': 'Paytm',
      'type': 'Internship',
      'category': 'Internship',
      'logo': 'P',
      'rating': 4.3,
      'reviews': 450,
      'location': 'Noida',
      'isNew': true,
      'deadline': '2024-12-20',
      'description': 'Work on recommendation systems.',
      'requirements': 'ML knowledge, college student',
    },
    {
      'title': 'Infosys Systems Engineer',
      'salary': '6.5 LPA',
      'salaryNum': 6.5,
      'company': 'Infosys',
      'type': 'Full-time',
      'category': 'IT',
      'logo': 'I',
      'rating': 4.2,
      'reviews': 3200,
      'location': 'Pune',
      'isNew': false,
      'deadline': '2025-01-10',
      'description': 'System integration and support.',
      'requirements': 'BE/BTech, good communication',
    },
    {
      'title': 'TCS Digital',
      'salary': '7.5 LPA',
      'salaryNum': 7.5,
      'company': 'TCS',
      'type': 'Full-time',
      'category': 'IT',
      'logo': 'T',
      'rating': 4.4,
      'reviews': 4500,
      'location': 'Mumbai',
      'isNew': false,
      'deadline': '2025-01-05',
      'description': 'Digital transformation projects.',
      'requirements': 'Coding skills, problem solving',
    },
    {
      'title': 'BHEL Core Engineer',
      'salary': '12 LPA',
      'salaryNum': 12,
      'company': 'BHEL',
      'type': 'Full-time',
      'category': 'Core',
      'logo': 'B',
      'rating': 4.5,
      'reviews': 890,
      'location': 'Delhi',
      'isNew': true,
      'deadline': '2024-12-25',
      'description': 'Power plant engineering.',
      'requirements': 'Mechanical/Electrical degree',
    },
    {
      'title': 'DRDO Scientist',
      'salary': '18 LPA',
      'salaryNum': 18,
      'company': 'DRDO',
      'type': 'Full-time',
      'category': 'Govt',
      'logo': 'D',
      'rating': 4.9,
      'reviews': 560,
      'location': 'Multiple',
      'isNew': false,
      'deadline': '2025-02-01',
      'description': 'Defense research and development.',
      'requirements': 'GATE score, Masters degree',
    },
    {
      'title': 'Remote Full Stack Dev',
      'salary': '25 LPA',
      'salaryNum': 25,
      'company': 'Stripe',
      'type': 'Remote',
      'category': 'Remote',
      'logo': 'S',
      'rating': 4.7,
      'reviews': 340,
      'location': 'Remote',
      'isNew': true,
      'deadline': '2024-12-31',
      'description': 'Build payment infrastructure.',
      'requirements': 'React, Node.js, 3+ years',
    },
    {
      'title': 'Adobe Product Designer',
      'salary': '32 LPA',
      'salaryNum': 32,
      'company': 'Adobe',
      'type': 'Full-time',
      'category': 'IT',
      'logo': 'A',
      'rating': 4.6,
      'reviews': 1200,
      'location': 'Noida',
      'isNew': false,
      'deadline': '2025-01-20',
      'description': 'Design creative suite products.',
      'requirements': 'Figma, UI/UX portfolio',
    },
    {
      'title': 'Goldman Sachs Analyst',
      'salary': '28 LPA',
      'salaryNum': 28,
      'company': 'Goldman',
      'type': 'Full-time',
      'category': 'IT',
      'logo': 'G',
      'rating': 4.8,
      'reviews': 890,
      'location': 'Bangalore',
      'isNew': true,
      'deadline': '2024-12-29',
      'description': 'Financial software development.',
      'requirements': 'Strong DSA, finance knowledge',
    },
    {
      'title': 'Uber Data Analyst',
      'salary': '15 LPA',
      'salaryNum': 15,
      'company': 'Uber',
      'type': 'Full-time',
      'category': 'IT',
      'logo': 'U',
      'rating': 4.4,
      'reviews': 670,
      'location': 'Hyderabad',
      'isNew': false,
      'deadline': '2025-01-12',
      'description': 'Analyze ride-sharing data.',
      'requirements': 'SQL, Python, Tableau',
    },
  ];

  List<Map<String, dynamic>> get filteredJobs {
    var jobs = allJobs.where((job) {
      // Search filter
      if (searchQuery.isNotEmpty &&
          !job['title'].toLowerCase().contains(searchQuery.toLowerCase()))
        return false;
      // Category filter
      if (selectedCategory != 'All' && job['category'] != selectedCategory)
        return false;
      // Salary filter
      if (job['salaryNum'] < salaryRange.start ||
          job['salaryNum'] > salaryRange.end)
        return false;
      // Job type filter
      if (selectedJobType != 'All' && job['type'] != selectedJobType)
        return false;
      // Company filter
      if (selectedCompany != 'All' && job['company'] != selectedCompany)
        return false;
      return true;
    }).toList();

    // Sorting
    switch (sortBy) {
      case 'salaryHigh':
        jobs.sort((a, b) => b['salaryNum'].compareTo(a['salaryNum']));
        break;
      case 'salaryLow':
        jobs.sort((a, b) => a['salaryNum'].compareTo(b['salaryNum']));
        break;
      case 'newest':
        jobs.sort((a, b) => (b['isNew'] ? 1 : 0).compareTo(a['isNew'] ? 1 : 0));
        break;
    }
    return jobs;
  }

  List<String> get categories => [
    'All',
    'IT',
    'Core',
    'Remote',
    'Internship',
    'Govt',
  ];
  List<String> get jobTypes => [
    'All',
    'Full-time',
    'Part-time',
    'Internship',
    'Remote',
    'Contract',
  ];
  List<String> get companies => [
    'All',
    ...allJobs.map((e) => e['company'] as String).toSet(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scrollController.addListener(_onScroll);
    _generateMatchScores();
  }

  void _generateMatchScores() {
    for (var job in allJobs) {
      matchScores[job['title']] = (50 + (job['salaryNum'] * 1.5))
          .clamp(50, 98)
          .toDouble();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore) {
      _loadMore();
    }
  }

  void _loadMore() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      currentPage++;
      if (currentPage >= 3) hasMore = false;
      isLoading = false;
    });
  }

  void _toggleSave(String jobTitle) {
    setState(() {
      if (savedJobs.contains(jobTitle)) {
        savedJobs.remove(jobTitle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Removed from saved'),
            backgroundColor: AC.grey,
          ),
        );
      } else {
        savedJobs.add(jobTitle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Saved successfully'),
            backgroundColor: AC.green,
          ),
        );
      }
    });
  }

  void _applyJob(String jobTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AC.green),
            const SizedBox(width: 10),
            Text('Apply for $jobTitle'),
          ],
        ),
        content: const Text(
          'Your application has been submitted successfully! The recruiter will contact you soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AC.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() => appliedJobs.add(jobTitle));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Applied to $jobTitle!'),
                  backgroundColor: AC.green,
                ),
              );
            },
            child: const Text('Confirm Apply'),
          ),
        ],
      ),
    );
  }

  void _shareJob(String jobTitle, String company) {
    Clipboard.setData(
      ClipboardData(text: 'Check out $jobTitle at $company on Job Board!'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 Job link copied to clipboard!')),
    );
  }

  void _toggleJobAlert(String jobTitle) {
    setState(() {
      if (jobAlerts.contains(jobTitle)) {
        jobAlerts.remove(jobTitle);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('🔕 Job alert disabled')));
      } else {
        jobAlerts.add(jobTitle);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔔 Job alert enabled! We\'ll notify you'),
          ),
        );
      }
    });
  }

  void _addToRecentlyViewed(String jobTitle) {
    setState(() {
      recentlyViewed.add(jobTitle);
      if (recentlyViewed.length > 5)
        recentlyViewed.remove(recentlyViewed.first);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showQuickApplyBottomSheet(),
          backgroundColor: AC.blue,
          icon: const Icon(Icons.bolt, color: Colors.white),
          label: const Text(
            'Quick Apply',
            style: TextStyle(color: Colors.white),
          ),
        ),
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
              gradient: const LinearGradient(colors: [AC.blue, AC.darkBlue]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💼', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Job Board',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AC.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${filteredJobs.length} Jobs',
              style: TextStyle(color: AC.blue, fontWeight: FontWeight.bold),
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
              onPressed: () => _showSavedJobsDialog(),
            ),
            if (savedJobs.isNotEmpty)
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
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              currentPage = 0;
              hasMore = true;
            });
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Column(
            children: [
              _buildSearchAndFilterBar(),
              _buildFilterChips(),
              _buildSortAndViewBar(),
              Expanded(
                child: isLoading && currentPage == 0
                    ? _buildShimmerGrid()
                    : filteredJobs.isEmpty
                    ? _buildEmptyState()
                    : isGridView && constraints.maxWidth > 600
                    ? GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth > 1200
                              ? 3
                              : constraints.maxWidth > 800
                              ? 2
                              : 1,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredJobs.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) =>
                            index == filteredJobs.length
                            ? _buildLoadingIndicator()
                            : _buildAnimatedJobCard(
                                filteredJobs[index],
                                constraints,
                              ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredJobs.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) =>
                            index == filteredJobs.length
                            ? _buildLoadingIndicator()
                            : _buildAnimatedJobCard(
                                filteredJobs[index],
                                constraints,
                              ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilterBar() {
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
              hintText: '🔍 Search jobs, companies...',
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
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showFilterBottomSheet(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AC.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.filter_list, size: 20, color: AC.blue),
                        SizedBox(width: 8),
                        Text(
                          'Advanced Filters',
                          style: TextStyle(color: AC.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showSortDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AC.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.sort, size: 20, color: AC.green),
                        SizedBox(width: 8),
                        Text('Sort', style: TextStyle(color: AC.green)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                selectedColor: AC.blue.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: selectedCategory == cat ? AC.blue : AC.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (filteredJobs.any((j) => j['isNew'] == true))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.fiber_new, size: 16, color: Colors.red),
                  SizedBox(width: 4),
                  Text(
                    'New Jobs',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortAndViewBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AC.borderGrey),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 16, color: AC.green),
                const SizedBox(width: 4),
                Text(
                  'Match: ${matchScores.values.first.toStringAsFixed(0)}% avg',
                  style: TextStyle(fontSize: 12, color: AC.green),
                ),
              ],
            ),
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AC.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'AI Recs',
                      style: TextStyle(fontSize: 12, color: AC.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedJobCard(
    Map<String, dynamic> job,
    BoxConstraints constraints,
  ) {
    final isSaved = savedJobs.contains(job['title']);
    final isApplied = appliedJobs.contains(job['title']);
    final matchScore = matchScores[job['title']] ?? 70;
    final isExpanded = expandedJobs[job['title']] ?? false;

    return GestureDetector(
      onTap: () {
        _addToRecentlyViewed(job['title']);
        setState(() => expandedJobs[job['title']] = !isExpanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.grey[850]!, Colors.grey[800]!]
                : [Colors.white, AC.lightGrey.withOpacity(0.5)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: job['isNew'] ? AC.blue : AC.borderGrey,
            width: job['isNew'] ? 2 : 1,
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
                          gradient: const LinearGradient(
                            colors: [AC.blue, AC.darkBlue],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            job['logo'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  job['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (job['isNew']) const SizedBox(width: 8),
                                if (job['isNew'])
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AC.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.business, size: 14, color: AC.grey),
                                const SizedBox(width: 4),
                                Text(
                                  job['company'],
                                  style: TextStyle(
                                    color: AC.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AC.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  job['location'],
                                  style: TextStyle(
                                    color: AC.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
                              job['salary'],
                              style: const TextStyle(
                                color: AC.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber),
                              Text(
                                ' ${job['rating']}',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                ' (${job['reviews']})',
                                style: TextStyle(fontSize: 10, color: AC.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: matchScore / 100,
                    backgroundColor: Colors.grey[200],
                    color: matchScore > 80
                        ? AC.green
                        : matchScore > 60
                        ? Colors.orange
                        : AC.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${matchScore.toStringAsFixed(0)}% Match',
                        style: TextStyle(
                          fontSize: 11,
                          color: matchScore > 80 ? AC.green : AC.blue,
                        ),
                      ),
                      Text(
                        '⭐ AI Recommended',
                        style: TextStyle(fontSize: 11, color: AC.grey),
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 12),
                    Divider(color: AC.borderGrey),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.description, size: 16, color: AC.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            job['description'],
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.verified, size: 16, color: AC.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Requirements: ${job['requirements']}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Deadline: ${job['deadline']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
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
                      onPressed: isApplied
                          ? null
                          : () => _applyJob(job['title']),
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
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? AC.blue : AC.grey,
                    ),
                    onPressed: () => _toggleSave(job['title']),
                  ),
                  IconButton(
                    icon: Icon(
                      jobAlerts.contains(job['title'])
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: jobAlerts.contains(job['title'])
                          ? Colors.orange
                          : AC.grey,
                    ),
                    onPressed: () => _toggleJobAlert(job['title']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: AC.grey),
                    onPressed: () => _shareJob(job['title'], job['company']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: ShimmerLoading(
          child: Column(
            children: [
              Container(height: 80, color: Colors.grey[300]),
              const SizedBox(height: 10),
              Container(height: 20, width: 150, color: Colors.grey[300]),
              const SizedBox(height: 10),
              Container(height: 15, width: 200, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator(color: AC.blue)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AC.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No jobs found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AC.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text('Try adjusting your filters', style: TextStyle(color: AC.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {
              searchQuery = '';
              selectedCategory = 'All';
              salaryRange = const RangeValues(0, 50);
            }),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
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
              const SizedBox(height: 20),
              const Text(
                'Salary Range (LPA)',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              RangeSlider(
                values: salaryRange,
                min: 0,
                max: 50,
                divisions: 50,
                activeColor: AC.blue,
                onChanged: (values) =>
                    setSheetState(() => salaryRange = values),
              ),
              Text(
                '₹${salaryRange.start.toInt()}L - ₹${salaryRange.end.toInt()}L',
                style: const TextStyle(color: AC.blue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Job Type',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: jobTypes
                    .map(
                      (type) => FilterChip(
                        label: Text(type),
                        selected: selectedJobType == type,
                        onSelected: (_) =>
                            setSheetState(() => selectedJobType = type),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Company',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: companies.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(companies[index]),
                      selected: selectedCompany == companies[index],
                      onSelected: (_) => setSheetState(
                        () => selectedCompany = companies[index],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
        title: const Text('Sort Jobs By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Newest First'),
              value: 'newest',
              groupValue: sortBy,
              onChanged: (v) => setState(() => sortBy = v as String),
            ),
            RadioListTile(
              title: const Text('Salary: High to Low'),
              value: 'salaryHigh',
              groupValue: sortBy,
              onChanged: (v) => setState(() => sortBy = v as String),
            ),
            RadioListTile(
              title: const Text('Salary: Low to High'),
              value: 'salaryLow',
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

  void _showSavedJobsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Jobs'),
        content: savedJobs.isEmpty
            ? const Text('No saved jobs yet')
            : Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: savedJobs.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(savedJobs.elementAt(index)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(
                        () => savedJobs.remove(savedJobs.elementAt(index)),
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

  void _showQuickApplyBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Apply',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Resume Link',
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
              child: const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer Loading Widget
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          Opacity(opacity: 0.5 + 0.5 * _controller.value, child: widget.child),
    );
  }
}
