import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';



// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────
class Student {
  final String name;
  final String fatherName;
  final String dob;
  final String pin;
  final int cit;
  final int cls;
  final int css;

  const Student({
    required this.name,
    required this.fatherName,
    required this.dob,
    required this.pin,
    required this.cit,
    required this.cls,
    required this.css,
  });

  int get total => cit + cls + css;
  double get percentage => (total / 300) * 100;
  bool get citPass => cit >= 40;
  bool get clsPass => cls >= 40;
  bool get cssPass => css >= 40;
  bool get overallPass => citPass && clsPass && cssPass;

  String get rank => overallPass ? 'PASS' : 'FAIL';
}

// ─────────────────────────────────────────────
//  HARDCODED STUDENT DATA
// ─────────────────────────────────────────────
const List<Student> kStudents = [
  Student(
    name: 'RAJA KUMAR',
    fatherName: 'SURESH KUMAR',
    dob: '01-01-2005',
    pin: '741852',
    cit: 85,
    cls: 78,
    css: 90,
  ),
  Student(
    name: 'ALI RAZA',
    fatherName: 'RAZA AKBAR',
    dob: '12-03-2005',
    pin: '111111',
    cit: 85,
    cls: 78,
    css: 92,
  ),
  Student(
    name: 'SARA KHAN',
    fatherName: 'IMRAN KHAN',
    dob: '22-07-2006',
    pin: '222222',
    cit: 68,
    cls: 74,
    css: 70,
  ),
  Student(
    name: 'MOHD FARHAN',
    fatherName: 'MOHD SALIM',
    dob: '15-05-2005',
    pin: '333333',
    cit: 55,
    cls: 62,
    css: 48,
  ),
  Student(
    name: 'PRIYA SHARMA',
    fatherName: 'RAJESH SHARMA',
    dob: '08-11-2006',
    pin: '444444',
    cit: 92,
    cls: 88,
    css: 95,
  ),
  Student(
    name: 'ZARA SIDDIQUI',
    fatherName: 'KHALID SIDDIQUI',
    dob: '30-04-2005',
    pin: '555555',
    cit: 35,
    cls: 72,
    css: 60,
  ),
  Student(
    name: 'ARJUN VERMA',
    fatherName: 'DEEPAK VERMA',
    dob: '19-09-2006',
    pin: '666666',
    cit: 78,
    cls: 83,
    css: 76,
  ),
];

// ─────────────────────────────────────────────
//  THEME CONSTANTS
// ─────────────────────────────────────────────
class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFF00ACC1);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color warning = Color(0xFFE65100);
  static const Color surface = Color(0xFFF8FAFF);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5A6580);
  static const Color divider = Color(0xFFE8EDF5);
  static const Color goldRank1 = Color(0xFFFFD700);
  static const Color silverRank2 = Color(0xFFC0C0C0);
  static const Color bronzeRank3 = Color(0xFFCD7F32);
}

// ─────────────────────────────────────────────
//  ROOT APP
// ─────────────────────────────────────────────
class ResultManagementApp extends StatelessWidget {
  const ResultManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Result Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.surface,
cardTheme: CardThemeData(
  color: AppColors.cardBg,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: AppColors.divider, width: 1),
  ),
),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorLight),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  LOGIN SCREEN
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _pinVisible = false;
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final name = _nameController.text.trim().toUpperCase();
    final pin = _pinController.text.trim();

    Student? found;
    for (final s in kStudents) {
      if (s.name == name && s.pin == pin) {
        found = s;
        break;
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (found != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) =>
              ResultScreen(student: found!, loggedInName: found.name),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      setState(
          () => _errorMessage = 'Invalid credentials or no record found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: _decorCircle(200, Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            top: 60,
            right: 40,
            child: _decorCircle(100, Colors.white.withOpacity(0.07)),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: _decorCircle(250, Colors.white.withOpacity(0.04)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        // Logo / Header
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: AppColors.primary,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Result Management\nSystem',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'BS-CIT / BS-CLS / BS-CSS Programme',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Card form
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Student Login',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Enter your credentials to view result',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Name field
                                _buildLabel('Student Name'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your full name',
                                    prefixIcon: Icon(Icons.person_outline_rounded,
                                        color: AppColors.primary),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                // PIN field
                                _buildLabel('6-Digit PIN'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _pinController,
                                  obscureText: !_pinVisible,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter 6-digit PIN',
                                    counterText: '',
                                    prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppColors.primary),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _pinVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () => setState(
                                          () => _pinVisible = !_pinVisible),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Please enter your PIN';
                                    }
                                    if (v.length != 6) {
                                      return 'PIN must be exactly 6 digits';
                                    }
                                    return null;
                                  },
                                ),
                                // Error message
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorLight
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppColors.errorLight
                                              .withOpacity(0.4)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline,
                                            color: AppColors.errorLight,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              color: AppColors.error,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 26),
                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.search_rounded,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'View Result',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '© 2025 Result Management System',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );

  Widget _decorCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

// ─────────────────────────────────────────────
//  RESULT SCREEN
// ─────────────────────────────────────────────
class ResultScreen extends StatefulWidget {
  final Student student;
  final String loggedInName;

  const ResultScreen(
      {super.key, required this.student, required this.loggedInName});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Result',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, a, __) => LeaderboardScreen(
                    loggedInName: widget.loggedInName),
                transitionsBuilder: (_, anim, __, child) => FadeTransition(
                    opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 350),
              ),
            ),
            icon: const Icon(Icons.leaderboard_rounded,
                color: Colors.white, size: 18),
            label: const Text('Leaderboard',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Pass/Fail banner
              _buildResultBanner(s),
              const SizedBox(height: 16),
              // Student details card
              _buildStudentCard(s),
              const SizedBox(height: 16),
              // Marks card
              _buildMarksCard(s),
              const SizedBox(height: 16),
              // Summary card
              _buildSummaryCard(s),
              const SizedBox(height: 24),
              // Leaderboard button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, a, __) => LeaderboardScreen(
                          loggedInName: widget.loggedInName),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  ),
                  icon: const Icon(Icons.leaderboard_rounded),
                  label: const Text(
                    'View Leaderboard',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultBanner(Student s) {
    final isPass = s.overallPass;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPass
              ? [const Color(0xFF1B5E20), AppColors.successLight]
              : [const Color(0xFF7F0000), AppColors.errorLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPass ? AppColors.success : AppColors.error)
                .withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPass ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPass ? '🎉 Congratulations!' : '❌ Not Qualified',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPass
                      ? 'You have PASSED all subjects'
                      : 'You have FAILED one or more subjects',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
                Icons.person_rounded, 'Student Details', AppColors.primary),
            const SizedBox(height: 16),
            _detailRow(Icons.badge_outlined, 'Student Name', s.name),
            _divider(),
            _detailRow(Icons.family_restroom_rounded, 'Father Name', s.fatherName),
            _divider(),
            _detailRow(Icons.cake_outlined, 'Date of Birth', s.dob),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksCard(Student s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
                Icons.menu_book_rounded, 'Subject Marks', AppColors.accent),
            const SizedBox(height: 16),
            _subjectRow('BS-CIT', s.cit, s.citPass),
            const SizedBox(height: 10),
            _subjectRow('BS-CLS', s.cls, s.clsPass),
            const SizedBox(height: 10),
            _subjectRow('BS-CSS', s.css, s.cssPass),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '* Passing marks = 40 per subject',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectRow(String label, int marks, bool pass) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: (pass ? AppColors.success : AppColors.errorLight)
            .withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (pass ? AppColors.success : AppColors.errorLight)
              .withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (pass ? AppColors.success : AppColors.errorLight)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              pass ? Icons.check_rounded : Icons.close_rounded,
              color: pass ? AppColors.success : AppColors.errorLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '$marks / 100',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: pass ? AppColors.success : AppColors.errorLight,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pass ? AppColors.success : AppColors.errorLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pass ? 'PASS' : 'FAIL',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Student s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.analytics_rounded, 'Result Summary',
                AppColors.primaryLight),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _statBox(
                    'Total Marks',
                    '${s.total}',
                    '/ 300',
                    AppColors.primary,
                    Icons.calculate_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statBox(
                    'Percentage',
                    '${s.percentage.toStringAsFixed(1)}%',
                    '',
                    AppColors.accent,
                    Icons.percent_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: s.overallPass
                      ? [const Color(0xFF1B5E20), AppColors.successLight]
                      : [const Color(0xFF7F0000), AppColors.errorLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                s.overallPass ? '✅  OVERALL RESULT: PASS' : '❌  OVERALL RESULT: FAIL',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, String sub, Color color,
      IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: color)),
              if (sub.isNotEmpty)
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: AppColors.divider, height: 16);
}

// ─────────────────────────────────────────────
//  LEADERBOARD SCREEN
// ─────────────────────────────────────────────
class LeaderboardScreen extends StatefulWidget {
  final String loggedInName;

  const LeaderboardScreen({super.key, required this.loggedInName});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<_RankedStudent> _ranked;
  late List<_RankedStudent> _filtered;
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    // Sort by total marks desc, assign ranks
    final sorted = [...kStudents]
      ..sort((a, b) => b.total.compareTo(a.total));
    _ranked = sorted
        .asMap()
        .entries
        .map((e) => _RankedStudent(rank: e.key + 1, student: e.value))
        .toList();
    _filtered = [..._ranked];

    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? [..._ranked]
          : _ranked
              .where((r) => r.student.name.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Leaderboard',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: Column(
          children: [
            // Search bar
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by student name...',
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.white.withOpacity(0.8)),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            _searchCtrl.clear();
                            _filter();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
            // Count row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '${_filtered.length} student${_filtered.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Sorted by Total Marks ↓',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final r = _filtered[i];
                        final isMe = r.student.name == widget.loggedInName;
                        return _LeaderboardCard(
                          ranked: r,
                          isLoggedIn: isMe,
                          index: i,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 60, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text('No students found',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

class _RankedStudent {
  final int rank;
  final Student student;

  const _RankedStudent({required this.rank, required this.student});
}

class _LeaderboardCard extends StatelessWidget {
  final _RankedStudent ranked;
  final bool isLoggedIn;
  final int index;

  const _LeaderboardCard({
    required this.ranked,
    required this.isLoggedIn,
    required this.index,
  });

  Color _rankColor(int rank) {
    if (rank == 1) return AppColors.goldRank1;
    if (rank == 2) return AppColors.silverRank2;
    if (rank == 3) return AppColors.bronzeRank3;
    return AppColors.textSecondary;
  }

  IconData _rankIcon(int rank) {
    if (rank <= 3) return Icons.emoji_events_rounded;
    return Icons.person_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final s = ranked.student;
    final rankColor = _rankColor(ranked.rank);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLoggedIn
            ? AppColors.primaryLight.withOpacity(0.07)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLoggedIn
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.divider,
          width: isLoggedIn ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLoggedIn ? AppColors.primary : Colors.black)
                .withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Rank badge
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: rankColor.withOpacity(0.4)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_rankIcon(ranked.rank), color: rankColor, size: 16),
                      Text(
                        '#${ranked.rank}',
                        style: TextStyle(
                          color: rankColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Name & father
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              s.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isLoggedIn
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLoggedIn) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        's/o ${s.fatherName}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'DOB: ${s.dob}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // Total & %
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${s.total}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isLoggedIn
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '/ 300',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                    Text(
                      '${s.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: s.overallPass
                            ? AppColors.success
                            : AppColors.errorLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            // Subject marks row
            Row(
              children: [
                _subjectChip('BS-CIT', s.cit, s.citPass),
                const SizedBox(width: 8),
                _subjectChip('BS-CLS', s.cls, s.clsPass),
                const SizedBox(width: 8),
                _subjectChip('BS-CSS', s.css, s.cssPass),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: s.overallPass
                        ? AppColors.success
                        : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s.overallPass ? '✓ PASS' : '✗ FAIL',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectChip(String label, int marks, bool pass) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: (pass ? AppColors.success : AppColors.errorLight)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (pass ? AppColors.success : AppColors.errorLight)
              .withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: pass ? AppColors.success : AppColors.errorLight,
            ),
          ),
          Text(
            '$marks',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: pass ? AppColors.success : AppColors.errorLight,
            ),
          ),
        ],
      ),
    );
  }
}