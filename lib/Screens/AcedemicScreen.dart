// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

// pubspec.yaml dependencies needed:
// dependencies:
//   flutter:
//     sdk: flutter
//   shared_preferences: ^2.2.2
//
// flutter:
//   assets:
//     - assets/Logoes/Logo.png

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MODEL
// ═══════════════════════════════════════════════════════════════════════════════

class ProgramModel {
  final String id;
  final String name;
  final String duration;
  final String degree;
  final int fee;
  final int placement;
  final int scholarship;
  final String eligibility;
  final String mode;
  final String status;
  final DateTime intakeDate;
  final String category;
  bool isFavorite;
  final String description;
  final List<String> highlights;

  ProgramModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.degree,
    required this.fee,
    required this.placement,
    required this.scholarship,
    required this.eligibility,
    required this.mode,
    required this.status,
    required this.intakeDate,
    required this.category,
    this.isFavorite = false,
    this.description = '',
    this.highlights = const [],
  });

  ProgramModel copyWith({bool? isFavorite}) => ProgramModel(
        id: id,
        name: name,
        duration: duration,
        degree: degree,
        fee: fee,
        placement: placement,
        scholarship: scholarship,
        eligibility: eligibility,
        mode: mode,
        status: status,
        intakeDate: intakeDate,
        category: category,
        isFavorite: isFavorite ?? this.isFavorite,
        description: description,
        highlights: highlights,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK DATA
// ═══════════════════════════════════════════════════════════════════════════════

final List<ProgramModel> _allMockPrograms = [
  ProgramModel(
    id: '1',
    name: 'B.Tech Computer Science',
    duration: '4 Years',
    degree: 'B.Tech',
    fee: 850000,
    placement: 94,
    scholarship: 20,
    eligibility: '10+2 with 60% PCM',
    mode: 'Offline',
    status: 'Open',
    intakeDate: DateTime(2026, 8, 15),
    category: 'Engineering',
    description: 'Premier CS program with AI/ML specialization and industry partnerships.',
    highlights: ['AI/ML Track', 'Industry Mentors', 'Internship Guarantee'],
  ),
  ProgramModel(
    id: '2',
    name: 'MBA Business Analytics',
    duration: '2 Years',
    degree: 'MBA',
    fee: 1200000,
    placement: 97,
    scholarship: 30,
    eligibility: 'Graduation + CAT/GMAT',
    mode: 'Hybrid',
    status: 'Open',
    intakeDate: DateTime(2026, 7, 1),
    category: 'Business',
    description: 'Data-driven MBA program for next-generation business leaders.',
    highlights: ['Global Exchange', 'Live Projects', 'CXO Interactions'],
  ),
  ProgramModel(
    id: '3',
    name: 'MBBS',
    duration: '5.5 Years',
    degree: 'MBBS',
    fee: 1500000,
    placement: 99,
    scholarship: 15,
    eligibility: '10+2 with 60% PCB + NEET',
    mode: 'Offline',
    status: 'Closing Soon',
    intakeDate: DateTime(2026, 8, 1),
    category: 'Medical',
    description: 'World-class medical education with state-of-the-art hospital facilities.',
    highlights: ['800-Bed Hospital', 'Simulation Lab', 'Research Grants'],
  ),
  ProgramModel(
    id: '4',
    name: 'LLB Integrated',
    duration: '5 Years',
    degree: 'LLB',
    fee: 750000,
    placement: 88,
    scholarship: 25,
    eligibility: '10+2 with 55%',
    mode: 'Offline',
    status: 'Open',
    intakeDate: DateTime(2026, 9, 1),
    category: 'Law',
    description: 'Integrated law program with moot court and legal clinic experience.',
    highlights: ['Moot Courts', 'Legal Clinics', 'Bar Council Approved'],
  ),
  ProgramModel(
    id: '5',
    name: 'B.Des Industrial Design',
    duration: '4 Years',
    degree: 'B.Des',
    fee: 650000,
    placement: 90,
    scholarship: 20,
    eligibility: '10+2 + Portfolio',
    mode: 'Offline',
    status: 'Open',
    intakeDate: DateTime(2026, 8, 10),
    category: 'Design',
    description: 'Creative design program bridging aesthetics and functionality.',
    highlights: ['Design Studio', 'Industry Collab', 'Startup Incubator'],
  ),
  ProgramModel(
    id: '6',
    name: 'M.Tech AI & Robotics',
    duration: '2 Years',
    degree: 'M.Tech',
    fee: 600000,
    placement: 95,
    scholarship: 35,
    eligibility: 'B.Tech with 65% + GATE',
    mode: 'Hybrid',
    status: 'Open',
    intakeDate: DateTime(2026, 7, 20),
    category: 'Engineering',
    description: 'Advanced program in AI, ML and robotics with research opportunities.',
    highlights: ['GATE Scholarship', 'Research Lab', 'Patent Support'],
  ),
  ProgramModel(
    id: '7',
    name: 'BBA International Business',
    duration: '3 Years',
    degree: 'BBA',
    fee: 450000,
    placement: 85,
    scholarship: 10,
    eligibility: '10+2 with 55%',
    mode: 'Offline',
    status: 'Open',
    intakeDate: DateTime(2026, 8, 5),
    category: 'Business',
    description: 'Comprehensive undergraduate business program with global exposure.',
    highlights: ['Forex Trading Lab', 'Global Tie-ups', 'SAP Training'],
  ),
  ProgramModel(
    id: '8',
    name: 'B.Arch Architecture',
    duration: '5 Years',
    degree: 'B.Arch',
    fee: 900000,
    placement: 89,
    scholarship: 20,
    eligibility: '10+2 with 50% + NATA',
    mode: 'Offline',
    status: 'Full',
    intakeDate: DateTime(2026, 8, 15),
    category: 'Design',
    description: 'Accredited architecture program with advanced studio facilities.',
    highlights: ['COA Approved', 'CAD Studio', 'Green Architecture'],
  ),
  ProgramModel(
    id: '9',
    name: 'B.Tech Mechanical Engg',
    duration: '4 Years',
    degree: 'B.Tech',
    fee: 780000,
    placement: 91,
    scholarship: 15,
    eligibility: '10+2 with 60% PCM',
    mode: 'Offline',
    status: 'Open',
    intakeDate: DateTime(2026, 8, 15),
    category: 'Engineering',
    description: 'Industry-focused mechanical engineering with hands-on learning.',
    highlights: ['EV Lab', 'Industry Projects', 'CNC Training'],
  ),
  ProgramModel(
    id: '10',
    name: 'MBA Healthcare Management',
    duration: '2 Years',
    degree: 'MBA',
    fee: 980000,
    placement: 93,
    scholarship: 25,
    eligibility: 'Graduation + Healthcare Experience',
    mode: 'Hybrid',
    status: 'Closing Soon',
    intakeDate: DateTime(2026, 7, 15),
    category: 'Business',
    description: 'Specialized MBA for healthcare sector professionals and leaders.',
    highlights: ['Hospital Visits', 'Policy Workshop', 'NABH Training'],
  ),
  ProgramModel(
    id: '11',
    name: 'Diploma Data Science',
    duration: '1 Year',
    degree: 'Diploma',
    fee: 180000,
    placement: 88,
    scholarship: 40,
    eligibility: '10+2 with 50%',
    mode: 'Online',
    status: 'Open',
    intakeDate: DateTime(2026, 6, 1),
    category: 'Engineering',
    description: 'Fast-track diploma program in data science and Python programming.',
    highlights: ['Python/SQL', 'Kaggle Projects', 'Job Assistance'],
  ),
  ProgramModel(
    id: '12',
    name: 'LLM Corporate Law',
    duration: '1 Year',
    degree: 'LLM',
    fee: 420000,
    placement: 92,
    scholarship: 20,
    eligibility: 'LLB with 55%',
    mode: 'Hybrid',
    status: 'Open',
    intakeDate: DateTime(2026, 9, 10),
    category: 'Law',
    description: 'Advanced law program with focus on corporate and commercial law.',
    highlights: ['Mock Arbitration', 'Law Firms Tie-up', 'Corporate Clinics'],
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// CONSTANTS & THEME
// ═══════════════════════════════════════════════════════════════════════════════

class AppColors {
  static const primary = Color(0xFF4361EE);
  static const secondary = Color(0xFF3F37C9);
  static const accent = Color(0xFFF72585);
  static const success = Color(0xFF06D6A0);
  static const warning = Color(0xFFFFD166);
  static const error = Color(0xFFEF476F);
  static const bgLight = Color(0xFFF8F9FA);
  static const bgDark = Color(0xFF121212);
  static const cardDark = Color(0xFF1E1E2E);
  static const cardLight = Colors.white;
  static const gradStart = Color(0xFF0F2027);
  static const gradMid = Color(0xFF203A43);
  static const gradEnd = Color(0xFF2C5364);
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK API SERVICE
// ═══════════════════════════════════════════════════════════════════════════════

class MockApiService {
  static Future<List<ProgramModel>> fetchPrograms() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulate occasional error (1 in 20 chance)
    if (math.Random().nextInt(20) == 0) {
      throw Exception('Network error. Please try again.');
    }
    return List.from(_allMockPrograms);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHIMMER WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isDark;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.isDark = false,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark ? const Color(0xFF2A2A3E) : const Color(0xFFE0E0E0);
    final highlight = widget.isDark ? const Color(0xFF3A3A5E) : const Color(0xFFF5F5F5);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: [base, highlight, base],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen>
    with TickerProviderStateMixin {
  // ── State Variables ──────────────────────────────────────────────────────────

  bool _isDarkMode = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  List<ProgramModel> _programs = [];
  List<ProgramModel> _filteredPrograms = [];
  List<String> _favoriteIds = [];
  List<String> _recentlyViewedIds = [];
  List<String> _compareIds = [];

  String _searchText = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Relevance';
  RangeValues _feeRange = const RangeValues(0, 1500000);
  int _activeFilterCount = 0;

  Timer? _debounceTimer;
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late AnimationController _fabAnimCtrl;
  late AnimationController _gradientAnimCtrl;
  late AnimationController _statsAnimCtrl;
  late Animation<double> _fabScaleAnim;
  late Animation<double> _gradientAnim;
  late Animation<int> _statsCountAnim;

  bool _showAppBar = true;
  double _lastScrollOffset = 0;

  int _bottomNavIndex = 0;

  static const List<String> _categories = [
    'All', 'Engineering', 'Business', 'Medical', 'Law', 'Design'
  ];
  static const List<String> _sortOptions = [
    'Relevance', 'Fee: Low to High', 'Fee: High to Low', 'Duration', 'Popularity'
  ];

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);

    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimCtrl, curve: Curves.elasticOut),
    );

    _gradientAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(_gradientAnimCtrl);

    _statsAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _statsCountAnim = IntTween(begin: 0, end: 0).animate(_statsAnimCtrl);

    _loadFromPrefs();
    _fetchPrograms();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimCtrl.dispose();
    _gradientAnimCtrl.dispose();
    _statsAnimCtrl.dispose();
    super.dispose();
  }

  // ── SharedPreferences ────────────────────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _favoriteIds = prefs.getStringList('favorites') ?? [];
        _recentlyViewedIds = prefs.getStringList('recently_viewed') ?? [];
      });
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favoriteIds);
      await prefs.setStringList('recently_viewed', _recentlyViewedIds);
    } catch (_) {}
  }

  // ── Data Fetching ────────────────────────────────────────────────────────────

  Future<void> _fetchPrograms({bool isRefresh = false}) async {
    if (!isRefresh) setState(() { _isLoading = true; _hasError = false; });
    try {
      final data = await MockApiService.fetchPrograms();
      setState(() {
        _programs = data.map((p) {
          p.isFavorite = _favoriteIds.contains(p.id);
          return p;
        }).toList();
        _isLoading = false;
        _hasError = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  // ── Scroll Behavior ───────────────────────────────────────────────────────────

  void _onScroll() {
    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;
    _lastScrollOffset = offset;

    if (delta > 5 && _showAppBar) {
      setState(() => _showAppBar = false);
    } else if (delta < -5 && !_showAppBar) {
      setState(() => _showAppBar = true);
    }
  }

  // ── Filter & Search ──────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchText = value);
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<ProgramModel> result = List.from(_programs);

    if (_searchText.isNotEmpty) {
      result = result.where((p) =>
        p.name.toLowerCase().contains(_searchText.toLowerCase()) ||
        p.category.toLowerCase().contains(_searchText.toLowerCase()) ||
        p.degree.toLowerCase().contains(_searchText.toLowerCase())
      ).toList();
    }

    if (_selectedCategory != 'All') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    result = result.where((p) =>
      p.fee >= _feeRange.start && p.fee <= _feeRange.end
    ).toList();

    switch (_selectedSort) {
      case 'Fee: Low to High':
        result.sort((a, b) => a.fee.compareTo(b.fee));
        break;
      case 'Fee: High to Low':
        result.sort((a, b) => b.fee.compareTo(a.fee));
        break;
      case 'Duration':
        result.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 'Popularity':
        result.sort((a, b) => b.placement.compareTo(a.placement));
        break;
    }

    int filterCount = 0;
    if (_selectedCategory != 'All') filterCount++;
    if (_feeRange != const RangeValues(0, 1500000)) filterCount++;
    if (_selectedSort != 'Relevance') filterCount++;

    setState(() {
      _filteredPrograms = result;
      _activeFilterCount = filterCount;
    });

    _statsCountAnim = IntTween(begin: 0, end: result.length).animate(
      CurvedAnimation(parent: _statsAnimCtrl, curve: Curves.easeOut),
    );
    _statsAnimCtrl.forward(from: 0);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedSort = 'Relevance';
      _feeRange = const RangeValues(0, 1500000);
      _searchText = '';
      _searchController.clear();
      _activeFilterCount = 0;
    });
    _applyFilters();
  }

  // ── Favorites ────────────────────────────────────────────────────────────────

  void _toggleFavorite(ProgramModel program) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_favoriteIds.contains(program.id)) {
        _favoriteIds.remove(program.id);
        program.isFavorite = false;
      } else {
        _favoriteIds.add(program.id);
        program.isFavorite = true;
      }
    });
    _saveToPrefs();
    _showSnackbar(
      program.isFavorite ? '❤️ Added to favorites' : '🤍 Removed from favorites',
      color: program.isFavorite ? AppColors.accent : Colors.grey,
    );
  }

  // ── Recently Viewed ──────────────────────────────────────────────────────────

  void _addToRecentlyViewed(String id) {
    setState(() {
      _recentlyViewedIds.remove(id);
      _recentlyViewedIds.insert(0, id);
      if (_recentlyViewedIds.length > 5) {
        _recentlyViewedIds = _recentlyViewedIds.sublist(0, 5);
      }
    });
    _saveToPrefs();
  }

  List<ProgramModel> get _recentlyViewedPrograms {
    return _recentlyViewedIds
        .map((id) => _programs.where((p) => p.id == id).isNotEmpty
            ? _programs.firstWhere((p) => p.id == id)
            : null)
        .whereType<ProgramModel>()
        .toList();
  }

  // ── Compare ──────────────────────────────────────────────────────────────────

  void _toggleCompare(ProgramModel program) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_compareIds.contains(program.id)) {
        _compareIds.remove(program.id);
        if (_compareIds.isEmpty) _fabAnimCtrl.reverse();
      } else {
        if (_compareIds.length >= 3) {
          _showSnackbar('Maximum 3 programs can be compared', color: AppColors.warning);
          return;
        }
        _compareIds.add(program.id);
        _fabAnimCtrl.forward();
      }
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _showSnackbar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color ?? AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatFee(int fee) {
    if (fee >= 100000) {
      return '₹${(fee / 100000).toStringAsFixed(1)}L';
    }
    return '₹${(fee / 1000).toStringAsFixed(0)}K';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open': return AppColors.success;
      case 'Closing Soon': return AppColors.warning;
      case 'Full': return AppColors.error;
      default: return Colors.grey;
    }
  }

  Color _modeColor(String mode) {
    switch (mode) {
      case 'Online': return AppColors.primary;
      case 'Offline': return AppColors.success;
      case 'Hybrid': return AppColors.warning;
      default: return Colors.grey;
    }
  }

  String _countdown(DateTime date) {
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'Intake Started';
    if (diff.inDays > 30) return '${diff.inDays} days';
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  int get _columns {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return 3;
    if (w > 600) return 2;
    return 1;
  }

  // ── Dialogs & Bottom Sheets ──────────────────────────────────────────────────

  void _showProgramDetail(ProgramModel program) {
    _addToRecentlyViewed(program.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProgramDetailSheet(
        program: program,
        isDark: _isDarkMode,
        onFavorite: () => _toggleFavorite(program),
        onApply: () => _showApplicationForm(program),
        onBrochure: () => _simulateBrochureDownload(program),
        formatFee: _formatFee,
        statusColor: _statusColor,
        modeColor: _modeColor,
        countdown: _countdown,
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => _FilterSheet(
          isDark: _isDarkMode,
          feeRange: _feeRange,
          selectedSort: _selectedSort,
          sortOptions: _sortOptions,
          onFeeChanged: (v) { setModal(() {}); setState(() => _feeRange = v); },
          onSortChanged: (v) { setModal(() {}); setState(() => _selectedSort = v!); },
          onApply: () { Navigator.pop(ctx); _applyFilters(); },
          onClear: () { Navigator.pop(ctx); _clearFilters(); },
        ),
      ),
    );
  }

  void _showCompareSheet() {
    final programs = _compareIds
        .map((id) => _programs.where((p) => p.id == id).isNotEmpty
            ? _programs.firstWhere((p) => p.id == id)
            : null)
        .whereType<ProgramModel>()
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompareSheet(
        programs: programs,
        isDark: _isDarkMode,
        formatFee: _formatFee,
        statusColor: _statusColor,
      ),
    );
  }

  void _showApplicationForm(ProgramModel program) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool submitted = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: _isDarkMode ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Apply for ${program.name}',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: submitted
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 60),
                  SizedBox(height: 12),
                  Text('Application Submitted!',
                      style: TextStyle(
                          color: _isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('We\'ll contact you within 24 hours.',
                      style: TextStyle(color: Colors.grey)),
                ])
              : Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    _formField(nameCtrl, 'Full Name', Icons.person),
                    SizedBox(height: 12),
                    _formField(emailCtrl, 'Email Address', Icons.email,
                        keyboardType: TextInputType.emailAddress),
                    SizedBox(height: 12),
                    _formField(phoneCtrl, 'Phone Number', Icons.phone,
                        keyboardType: TextInputType.phone),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        Icon(Icons.school, color: AppColors.primary, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(program.name,
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ),
                      ]),
                    ),
                  ]),
                ),
          actions: submitted
              ? [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Close', style: TextStyle(color: AppColors.primary)),
                  )
                ]
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        setDlg(() => submitted = true);
                      }
                    },
                    child: Text('Submit', style: TextStyle(color: Colors.white)),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: _isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  void _showEmiCalculator(ProgramModel program) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmiSheet(
        program: program,
        isDark: _isDarkMode,
        formatFee: _formatFee,
      ),
    );
  }

  Future<void> _simulateBrochureDownload(ProgramModel program) async {
    Navigator.pop(context);
    bool cancelled = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) {
          double progress = 0;
          Timer.periodic(const Duration(milliseconds: 100), (t) {
            if (cancelled || !ctx.mounted) { t.cancel(); return; }
            setDlg(() => progress += 0.05);
            if (progress >= 1) {
              t.cancel();
              Navigator.pop(ctx);
              _showSnackbar('📄 Brochure downloaded successfully!', color: AppColors.success);
            }
          });
          return AlertDialog(
            backgroundColor: _isDarkMode ? AppColors.cardDark : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Downloading Brochure',
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(program.name, style: TextStyle(color: Colors.grey, fontSize: 12)),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
              SizedBox(height: 8),
              Text('${(progress * 100).toInt()}%',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ]),
            actions: [
              TextButton(
                onPressed: () { cancelled = true; Navigator.pop(ctx); },
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showWhatsAppEnquiry(ProgramModel program) {
    _showSnackbar('📱 Opening WhatsApp enquiry for ${program.name}...', color: AppColors.success);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Theme(
      data: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(children: [
          // Animated gradient background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: Column(children: [
              // AppBar with hide on scroll
              AnimatedSlide(
                offset: _showAppBar ? Offset.zero : const Offset(0, -1),
                duration: const Duration(milliseconds: 200),
                child: AnimatedOpacity(
                  opacity: _showAppBar ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: _buildAppBar(),
                ),
              ),

              // Search + Filters
              _buildSearchBar(),
              _buildFilterChips(),

              // Stats
              if (!_isLoading && !_hasError) _buildStatsBar(),

              // Main list / grid
              Expanded(child: _buildBody()),
            ]),
          ),

          // FAB for compare
          Positioned(
            bottom: 80,
            right: 16,
            child: ScaleTransition(
              scale: _fabScaleAnim,
              child: FloatingActionButton.extended(
                onPressed: _compareIds.isNotEmpty ? _showCompareSheet : null,
                backgroundColor: AppColors.accent,
                icon: Icon(Icons.compare_arrows, color: Colors.white),
                label: Text(
                  '${_compareIds.length}/3 Compare',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ]),

        // Bottom Navigation
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _gradientAnim,
      builder: (_, __) {
        final t = _gradientAnim.value;
        return Container(
          decoration: BoxDecoration(
            gradient: _isDarkMode
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFF0F2027), const Color(0xFF1A1A2E), t)!,
                      Color.lerp(const Color(0xFF203A43), const Color(0xFF16213E), t)!,
                      Color.lerp(const Color(0xFF2C5364), const Color(0xFF0F3460), t)!,
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFFF0F8FF), const Color(0xFFEEF2FF), t)!,
                      Color.lerp(const Color(0xFFF8F9FA), const Color(0xFFF0F4FF), t)!,
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    final isDark = _isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        // Logo
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/Logoes/Logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.school, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Title
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BEEDI College',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                )),
            Text('Academic Programs',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 11,
                )),
          ]),
        ),

        // Dark mode toggle
        Semantics(
          label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          child: IconButton(
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
                color: isDark ? AppColors.warning : AppColors.primary,
              ),
            ),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          ),
        ),

        // Filter button with badge
        Stack(children: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: Icon(Icons.tune,
                color: isDark ? Colors.white70 : AppColors.primary),
            tooltip: 'Advanced Filters',
          ),
          if (_activeFilterCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$_activeFilterCount',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ]),
      ]),
    );
  }

  Widget _buildSearchBar() {
    final isDark = _isDarkMode;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by program name, category...',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchText = '');
                    _applyFilters();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory == cat;
          final count = cat == 'All'
              ? _programs.length
              : _programs.where((p) => p.category == cat).length;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Semantics(
              label: '$cat filter, $count programs',
              child: AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: FilterChip(
                  label: Text('$cat ($count)'),
                  selected: isSelected,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat);
                    _applyFilters();
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (_isDarkMode ? Colors.white70 : Colors.black87),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  elevation: isSelected ? 4 : 1,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        AnimatedBuilder(
          animation: _statsCountAnim,
          builder: (_, __) => Text(
            'Showing ${_statsCountAnim.value} of ${_programs.length} programs',
            style: TextStyle(
              color: _isDarkMode ? Colors.white60 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        if (_activeFilterCount > 0)
          TextButton.icon(
            onPressed: _clearFilters,
            icon: Icon(Icons.close, size: 14, color: AppColors.accent),
            label: Text('Clear all', style: TextStyle(color: AppColors.accent, fontSize: 12)),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),

        // Sort dropdown
        PopupMenuButton<String>(
          onSelected: (v) { setState(() => _selectedSort = v); _applyFilters(); },
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.sort, size: 14, color: AppColors.primary),
            SizedBox(width: 4),
            Text('Sort', style: TextStyle(color: AppColors.primary, fontSize: 12)),
          ]),
          itemBuilder: (_) => _sortOptions.map((s) => PopupMenuItem(
            value: s,
            child: Row(children: [
              if (_selectedSort == s)
                Icon(Icons.check, size: 16, color: AppColors.primary),
              SizedBox(width: _selectedSort == s ? 8 : 24),
              Text(s, style: TextStyle(fontSize: 13)),
            ]),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildShimmer();
    if (_hasError) return _buildError();
    if (_filteredPrograms.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      onRefresh: () => _fetchPrograms(isRefresh: true),
      color: AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            sliver: _columns == 1
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildProgramCard(_filteredPrograms[i], i),
                      childCount: _filteredPrograms.length,
                    ),
                  )
                : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _columns,
                      childAspectRatio: _columns == 2 ? 0.72 : 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _buildProgramCard(_filteredPrograms[i], i),
                      childCount: _filteredPrograms.length,
                    ),
                  ),
          ),

          // Recently Viewed Section
          if (_recentlyViewedPrograms.isNotEmpty)
            SliverToBoxAdapter(child: _buildRecentlyViewed()),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildProgramCard(ProgramModel program, int index) {
    final isDark = _isDarkMode;
    final isCompare = _compareIds.contains(program.id);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 50),
      curve: Curves.easeOutBack,
      builder: (_, val, child) => Transform.scale(scale: val, child: child),
      child: GestureDetector(
        onTap: () => _showProgramDetail(program),
        child: Hero(
          tag: 'program_${program.id}',
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isCompare
                    ? Border.all(color: AppColors.accent, width: 2)
                    : null,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Card header with gradient
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _categoryColor(program.category),
                        _categoryColor(program.category).withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Stack(children: [
                    // Pattern overlay
                    Positioned.fill(
                      child: CustomPaint(painter: _CardPatternPainter()),
                    ),

                    // Status badge
                    Positioned(
                      top: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor(program.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          program.status.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Scholarship ribbon
                    if (program.scholarship > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            '💰 ${program.scholarship}% OFF',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Degree badge
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: Text(
                          program.degree,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Compare checkbox
                    Positioned(
                      bottom: 8,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => _toggleCompare(program),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCompare ? AppColors.accent : Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: isCompare
                              ? Icon(Icons.check, color: Colors.white, size: 14)
                              : null,
                        ),
                      ),
                    ),
                  ]),
                ),

                // Card body
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          program.name,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Favorite button
                      GestureDetector(
                        onTap: () => _toggleFavorite(program),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            _favoriteIds.contains(program.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey(_favoriteIds.contains(program.id)),
                            color: _favoriteIds.contains(program.id)
                                ? AppColors.accent
                                : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 8),

                    // Info row
                    Row(children: [
                      Icon(Icons.access_time, size: 13, color: Colors.grey),
                      SizedBox(width: 3),
                      Text(program.duration,
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                      SizedBox(width: 10),
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: _modeColor(program.mode),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 3),
                      Text(program.mode,
                          style: TextStyle(
                              color: _modeColor(program.mode), fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),

                    const SizedBox(height: 10),

                    // Placement bar
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Placement Rate',
                            style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontSize: 11)),
                        Text('${program.placement}%',
                            style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: program.placement / 100,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(AppColors.success),
                          minHeight: 5,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 10),

                    // Fee + intake
                    Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Total Fee',
                              style: TextStyle(color: Colors.grey, fontSize: 10)),
                          Row(children: [
                            Text(
                              _formatFee(program.fee),
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('EMI',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ]),
                        ]),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('Intake in', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        Text(
                          _countdown(program.intakeDate),
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ]),
                    ]),

                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    // Quick action row
                    Row(children: [
                      _quickAction(Icons.download, 'Brochure',
                          () { Navigator.pop; _simulateBrochureDownload(program); }),
                      _quickAction(Icons.share, 'Share',
                          () => _showSnackbar('📤 Sharing ${program.name}...', color: AppColors.primary)),
                      _quickAction(Icons.edit_note, 'Apply',
                          () => _showApplicationForm(program), isAccent: true),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap, {bool isAccent = false}) {
    return Expanded(
      child: Semantics(
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(children: [
              Icon(icon,
                  size: 16,
                  color: isAccent ? AppColors.accent : AppColors.primary),
              SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                    color: isAccent ? AppColors.accent : AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  )),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyViewed() {
    final isDark = _isDarkMode;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
          child: Row(children: [
            Icon(Icons.history, color: AppColors.primary, size: 16),
            SizedBox(width: 6),
            Text('Recently Viewed',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                )),
          ]),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentlyViewedPrograms.length,
            itemBuilder: (_, i) {
              final p = _recentlyViewedPrograms[i];
              return GestureDetector(
                onTap: () => _showProgramDetail(p),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                    ],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _categoryColor(p.category).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(p.category,
                          style: TextStyle(
                              color: _categoryColor(p.category),
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 6),
                    Text(p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        )),
                    Spacer(),
                    Text(_formatFee(p.fee),
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isDarkMode ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShimmerWidget(width: double.infinity, height: 100, borderRadius: 12, isDark: _isDarkMode),
          SizedBox(height: 12),
          ShimmerWidget(width: 200, height: 16, isDark: _isDarkMode),
          SizedBox(height: 8),
          ShimmerWidget(width: 130, height: 12, isDark: _isDarkMode),
          SizedBox(height: 12),
          ShimmerWidget(width: double.infinity, height: 8, borderRadius: 4, isDark: _isDarkMode),
          SizedBox(height: 12),
          Row(children: [
            ShimmerWidget(width: 60, height: 24, borderRadius: 6, isDark: _isDarkMode),
            SizedBox(width: 8),
            ShimmerWidget(width: 80, height: 24, borderRadius: 6, isDark: _isDarkMode),
          ]),
        ]),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.wifi_off, size: 64, color: AppColors.error.withOpacity(0.7)),
          const SizedBox(height: 16),
          Text('Oops! Something went wrong',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),
          const SizedBox(height: 8),
          Text(_errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchPrograms,
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off, size: 64, color: Colors.grey.withOpacity(0.5)),
        const SizedBox(height: 16),
        Text('No programs found',
            style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _clearFilters,
          icon: Icon(Icons.clear_all, color: AppColors.primary),
          label: Text('Clear Filters', style: TextStyle(color: AppColors.primary)),
        ),
      ]),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (i) {
          if (i == 0) setState(() => _bottomNavIndex = i);
          else {
            setState(() => _bottomNavIndex = i);
            Future.delayed(Duration(milliseconds: 200), () {
              setState(() => _bottomNavIndex = 0);
            });
            final labels = ['Programs', 'Compare', 'Favorites', 'Profile'];
            _showSnackbar('${labels[i]} coming soon!', color: AppColors.secondary);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          _navItem(Icons.school_outlined, Icons.school, 'Programs'),
          _navItem(Icons.compare_arrows_outlined, Icons.compare_arrows, 'Compare',
              badge: _compareIds.isNotEmpty ? '${_compareIds.length}' : null),
          _navItem(Icons.favorite_outline, Icons.favorite, 'Favorites',
              badge: _favoriteIds.isNotEmpty ? '${_favoriteIds.length}' : null),
          _navItem(Icons.person_outline, Icons.person, 'Profile'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, IconData activeIcon, String label,
      {String? badge}) {
    Widget iconWidget = badge != null
        ? Stack(clipBehavior: Clip.none, children: [
            Icon(icon),
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(badge,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
          ])
        : Icon(icon);

    return BottomNavigationBarItem(
      icon: iconWidget,
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Engineering': return AppColors.primary;
      case 'Business': return const Color(0xFF7B2FBE);
      case 'Medical': return AppColors.error;
      case 'Law': return const Color(0xFF2D6A4F);
      case 'Design': return const Color(0xFFFF6B35);
      default: return AppColors.secondary;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARD PATTERN PAINTER
// ═══════════════════════════════════════════════════════════════════════════════

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.5),
        20.0 + i * 18,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROGRAM DETAIL BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _ProgramDetailSheet extends StatelessWidget {
  final ProgramModel program;
  final bool isDark;
  final VoidCallback onFavorite;
  final VoidCallback onApply;
  final VoidCallback onBrochure;
  final String Function(int) formatFee;
  final Color Function(String) statusColor;
  final Color Function(String) modeColor;
  final String Function(DateTime) countdown;

  const _ProgramDetailSheet({
    required this.program,
    required this.isDark,
    required this.onFavorite,
    required this.onApply,
    required this.onBrochure,
    required this.formatFee,
    required this.statusColor,
    required this.modeColor,
    required this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(controller: ctrl, padding: EdgeInsets.zero, children: [
              // Header gradient
              Hero(
                tag: 'program_${program.id}',
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [_catColor(program.category), _catColor(program.category).withOpacity(0.6)],
                    ),
                  ),
                  child: Stack(children: [
                    CustomPaint(size: Size.infinite, painter: _CardPatternPainter()),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(program.degree,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor(program.status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(program.status.toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                        Spacer(),
                        Text(program.name,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 4),
                        Text(program.category,
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ]),
                    ),
                  ]),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Description
                  if (program.description.isNotEmpty) ...[
                    Text(program.description,
                        style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                            height: 1.5)),
                    SizedBox(height: 16),
                  ],

                  // Info grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _infoTile(Icons.access_time, 'Duration', program.duration, isDark),
                      _infoTile(Icons.payments_outlined, 'Total Fee', formatFee(program.fee), isDark),
                      _infoTile(Icons.trending_up, 'Placement', '${program.placement}%', isDark),
                      _infoTile(Icons.calendar_today, 'Intake In', countdown(program.intakeDate), isDark),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Mode + scholarship
                  Row(children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: modeColor(program.mode).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: modeColor(program.mode).withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(
                            color: modeColor(program.mode), shape: BoxShape.circle)),
                          SizedBox(width: 8),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Mode', style: TextStyle(color: Colors.grey, fontSize: 10)),
                            Text(program.mode, style: TextStyle(
                                color: modeColor(program.mode), fontWeight: FontWeight.bold, fontSize: 13)),
                          ]),
                        ]),
                      ),
                    ),
                    SizedBox(width: 10),
                    if (program.scholarship > 0)
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                          ),
                          child: Row(children: [
                            Text('💰', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Scholarship', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              Text('${program.scholarship}% Off', style: TextStyle(
                                  color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 13)),
                            ]),
                          ]),
                        ),
                      ),
                  ]),

                  SizedBox(height: 16),

                  // Eligibility
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Eligibility', style: TextStyle(color: AppColors.primary,
                              fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(height: 2),
                          Text(program.eligibility,
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                        ]),
                      ),
                    ]),
                  ),

                  SizedBox(height: 16),

                  // Highlights
                  if (program.highlights.isNotEmpty) ...[
                    Text('Highlights', style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 6, children: program.highlights.map((h) =>
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.star, size: 12, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(h, style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ).toList()),
                    SizedBox(height: 16),
                  ],

                  // Placement progress
                  Text('Placement Rate', style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: program.placement / 100,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(AppColors.success),
                      minHeight: 10,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('0%', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('${program.placement}% placed', style: TextStyle(
                        color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('100%', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ]),

                  SizedBox(height: 20),

                  // Action buttons
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onBrochure,
                        icon: Icon(Icons.download, size: 16),
                        label: Text('Brochure'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onFavorite,
                        icon: Icon(Icons.favorite_border, size: 16),
                        label: Text('Save'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: BorderSide(color: AppColors.accent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(context); onApply(); },
                      icon: Icon(Icons.edit_note, color: Colors.white, size: 18),
                      label: Text('Apply Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('📱 Opening WhatsApp enquiry...'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ));
                      },
                      icon: Icon(Icons.chat, size: 18, color: AppColors.success),
                      label: Text('WhatsApp Enquiry',
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.success),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.primary),
        SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 9)),
            Text(value, style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'Engineering': return AppColors.primary;
      case 'Business': return const Color(0xFF7B2FBE);
      case 'Medical': return AppColors.error;
      case 'Law': return const Color(0xFF2D6A4F);
      case 'Design': return const Color(0xFFFF6B35);
      default: return AppColors.secondary;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FILTER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _FilterSheet extends StatelessWidget {
  final bool isDark;
  final RangeValues feeRange;
  final String selectedSort;
  final List<String> sortOptions;
  final ValueChanged<RangeValues> onFeeChanged;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.isDark,
    required this.feeRange,
    required this.selectedSort,
    required this.sortOptions,
    required this.onFeeChanged,
    required this.onSortChanged,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Advanced Filters', style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold, fontSize: 18)),
          Spacer(),
          TextButton(onPressed: onClear, child: Text('Reset', style: TextStyle(color: AppColors.accent))),
        ]),
        Divider(),
        SizedBox(height: 8),
        Text('Fee Range', style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('₹${(feeRange.start / 100000).toStringAsFixed(1)}L',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          Text('₹${(feeRange.end / 100000).toStringAsFixed(1)}L',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ]),
        RangeSlider(
          values: feeRange,
          min: 0,
          max: 1500000,
          divisions: 30,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.2),
          onChanged: onFeeChanged,
        ),
        SizedBox(height: 16),
        Text('Sort By', style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedSort,
          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: sortOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onSortChanged,
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMPARE BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _CompareSheet extends StatelessWidget {
  final List<ProgramModel> programs;
  final bool isDark;
  final String Function(int) formatFee;
  final Color Function(String) statusColor;

  const _CompareSheet({
    required this.programs,
    required this.isDark,
    required this.formatFee,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final headers = ['Program', 'Degree', 'Duration', 'Fee', 'Placement', 'Mode', 'Status'];
    final rows = [
      programs.map((p) => p.name).toList(),
      programs.map((p) => p.degree).toList(),
      programs.map((p) => p.duration).toList(),
      programs.map((p) => formatFee(p.fee)).toList(),
      programs.map((p) => '${p.placement}%').toList(),
      programs.map((p) => p.mode).toList(),
      programs.map((p) => p.status).toList(),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 4),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(children: [
              Icon(Icons.compare_arrows, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Program Comparison', style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              controller: ctrl,
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    // Header row
                    TableRow(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      children: [
                        _cell('Attribute', isDark, isHeader: true),
                        ...programs.map((p) => _cell(p.name.split(' ').take(2).join(' '), isDark, isHeader: true)),
                      ],
                    ),
                    // Data rows
                    ...List.generate(headers.length, (i) => TableRow(
                      decoration: BoxDecoration(
                        color: i.isEven
                            ? (isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.03))
                            : Colors.transparent,
                      ),
                      children: [
                        _cell(headers[i], isDark, isLabel: true),
                        ...rows[i].map((v) => _cell(v, isDark)),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _cell(String text, bool isDark, {bool isHeader = false, bool isLabel = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader
              ? AppColors.primary
              : isLabel
                  ? (isDark ? Colors.white54 : Colors.black45)
                  : (isDark ? Colors.white : Colors.black87),
          fontWeight: (isHeader || isLabel) ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 12 : 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EMI CALCULATOR SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _EmiSheet extends StatefulWidget {
  final ProgramModel program;
  final bool isDark;
  final String Function(int) formatFee;

  const _EmiSheet({required this.program, required this.isDark, required this.formatFee});

  @override
  State<_EmiSheet> createState() => _EmiSheetState();
}

class _EmiSheetState extends State<_EmiSheet> {
  int _months = 12;
  double _interest = 8.5;

  double get _emi {
    final p = widget.program.fee.toDouble();
    final r = _interest / 100 / 12;
    final n = _months;
    if (r == 0) return p / n;
    return p * r * math.pow(1 + r, n) / (math.pow(1 + r, n) - 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('EMI Calculator', style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height: 4),
        Text(widget.program.name,
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        Divider(height: 24),

        // EMI display
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Monthly EMI', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('₹${_emi.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('₹${(_emi * _months).toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
          ]),
        ),

        SizedBox(height: 16),
        Text('Loan Duration: $_months months', style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w600)),
        Slider(
          value: _months.toDouble(),
          min: 6, max: 60, divisions: 18,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _months = v.round()),
        ),

        Text('Interest Rate: ${_interest.toStringAsFixed(1)}%', style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w600)),
        Slider(
          value: _interest,
          min: 6, max: 18, divisions: 24,
          activeColor: AppColors.accent,
          onChanged: (v) => setState(() => _interest = v),
        ),

        SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Got it!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ]),
    );
  }
}