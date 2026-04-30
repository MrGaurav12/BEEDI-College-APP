// student_test_screen.dart – BEEDI College
// ENTERPRISE PRODUCTION QUIZ APPLICATION
// Features: Global Timer | Responsive UI | 30+ Advanced Features

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';

// ============================================================
// THEME CONFIGURATION
// ============================================================
class AppTheme {
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color textDark = Color(0xFF1A237E);
  static const Color textLight = Color(0xFF455A64);
  static const Color bgLight = Color(0xFFF0F8FF);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color dangerRed = Color(0xFFF44336);
  static const Color purpleAccent = Color(0xFF9C27B0);
  static const Color tealAccent = Color(0xFF009688);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    colorScheme: const ColorScheme.light(primary: primaryBlue),
    scaffoldBackgroundColor: bgLight,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
cardTheme: CardThemeData(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryBlue,
    colorScheme: const ColorScheme.dark(primary: primaryBlue),
    scaffoldBackgroundColor: Colors.grey[900],
cardTheme: CardThemeData(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
),
  );
}

// ============================================================
// MAIN ENTRY POINT
// ============================================================
class StudentTestScreen extends StatefulWidget {
  const StudentTestScreen({super.key});

  @override
  State<StudentTestScreen> createState() => _StudentTestScreenState();
}

class _StudentTestScreenState extends State<StudentTestScreen> {
  bool _isLoggedIn = false;
  String? _studentName;

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return LoginScreen(onLogin: (name) {
        setState(() {
          _isLoggedIn = true;
          _studentName = name;
        });
      });
    }
    return QuizAppScreen(studentName: _studentName!);
  }
}

// ============================================================
// LOGIN SCREEN with Enhanced Security
// ============================================================
class LoginScreen extends StatefulWidget {
  final Function(String) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePin = true;
  int _loginAttempts = 0;

 static const Map<String, String> _credentials = {
  // Batch 1 Students (kqUkvA64SfZ_m8jL3i)
  'KUMARI TANUJA BHARTI': '481092',
  'SIRITI KUMARI': '579234',
  'NANDANI KUMARI': '835671',
  'ANNU BHARTI': '742908',
  'MADHU KUMARI': '316457',
  'KUMARI SNEHA BHARTI': '204583',
  'PAYAL KUMARI': '698321',
  'RANGILA KUMARI': '957160',
  'AARATI KUMARI': '173846',
  'sonali nandini': '428579',
  'NIKKI KUMARI': '365012',
  'ANJALI KUMARI': '791548',
  'PRIYANKA KUMARI': '604237',
  'ANKITA KUMARI': '829165',
  
  // Batch 2 Students (7DN9XgL4K7cW5WypSX)
  'SRISTI KUMARI': '273401',
  'ANSHU KUMAR': '946573',
  'VISHAL KUMAR': '518429',
  'SANDHYA KUMARI': '387206',
  'RAJNANDANI KUMARI': '692745',
  'KANCHAN KUMARI': '150398',
  'PRINCE KUMAR': '734621',
  'HIMANSHU RAJ': '819064',
  'SAHIL RAJ': '465278',
  'RANJEET KUMAR': '902317',
  'RUPA KUMARI': '146583',
  'DOLLY KUMARI': '678940',
  'NAFISHA KHATUN': '321765',
  'RAJNANDANI': '457891',
  'JYOTI RAJ': '903246',
  'KUNAL KUMAR': '287419',
  'AJIT KUMAR': '614573',
  'MD SARFUDDIN': '758901',
  
  // Batch 3 Students (XSPpEHD4T5QeWn4jX9)
  'SIMRAN KUMARI': '362185',
  'ANIRUDH KUMAR': '721409',
  'MANISH KUMAR': '854367',
  'HIMANSHU KUMAR SINGH': '590674',
  'ANKITA KUMARI 2': '418023',
  'RAUSHANI KUMARI': '763149',
  'SONAM KUMARI': '238761',
  'NISHA KUMARI': '632598',
  'SWETA KUMARI': '417830',
  'MONIKA KUMARI': '975241',
  'GAURAV KUMAR': '234567',
  'RANDHIR KUMAR': '123456',

'RAJA KUMAR': '741852',
'SAMRIDHI KUMARI': '852963',
'LALMOHAN KUMAR': '159753',
'PRITI KUMARI': '357951',
'RUBY KUMARI': '456789',
'DEEPA KUMARI': '258369',
'MANTU KUMAR': '369258',
'VISHAKHA KUMARI': '147258',
};

  void _login() {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
        _isLoading = false;
      });
      return;
    }

    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your PIN';
        _isLoading = false;
      });
      return;
    }

    if (pin.length != 6) {
      setState(() {
        _errorMessage = 'PIN must be 6 digits';
        _isLoading = false;
      });
      return;
    }

    if (_credentials.containsKey(name) && _credentials[name] == pin) {
      widget.onLogin(name);
    } else {
      _loginAttempts++;
      setState(() {
        _errorMessage = 'Invalid credentials. Please check your name and PIN.';
        _isLoading = false;
      });
      
      if (_loginAttempts >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Multiple failed attempts. Please try again later.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.darkBlue, AppTheme.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(child: Text('📚', style: TextStyle(fontSize: 44))),
                    ),
                    const SizedBox(height: 20),
                    const Text('BEEDI College', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text('Student Assessment Portal', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTheme.primaryBlue, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Test Information', style: TextStyle(color: AppTheme.darkBlue, fontSize: 13, fontWeight: FontWeight.w800)),
                                SizedBox(height: 2),
                                Text('• Total Questions: 70\n• 60 minutes total time\n• Certificate on completion', style: TextStyle(color: AppTheme.textLight, fontSize: 11, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Student Name', style: TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: TextStyle(color: AppTheme.textLight.withOpacity(0.7), fontSize: 13),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryBlue, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('6-Digit PIN', style: TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pinController,
                      style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      obscureText: _obscurePin,
                      obscuringCharacter: '•',
                      decoration: InputDecoration(
                        hintText: 'Enter 6-digit PIN',
                        hintStyle: TextStyle(color: AppTheme.textLight.withOpacity(0.7), fontSize: 13),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryBlue, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility, color: AppTheme.textLight),
                          onPressed: () => setState(() => _obscurePin = !_obscurePin),
                        ),
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                        child: Row(children: [Icon(Icons.error_outline, color: Colors.red.shade700, size: 18), const SizedBox(width: 8), Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade800, fontSize: 12)))]),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, size: 18)]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ACKNOWLEDGMENT SCREEN with Animated Features
// ============================================================
class AcknowledgmentScreen extends StatelessWidget {
  final String studentName;
  final VoidCallback onStart;

  const AcknowledgmentScreen({super.key, required this.studentName, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Test Information', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.darkBlue, AppTheme.primaryBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text('👋', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text('Hello, $studentName!', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    const Text('Welcome to your assessment', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('📋 Test Details', style: TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _InfoCard(icon: Icons.subject_rounded, title: 'Subject', value: 'BS-CIT (Computer Information Technology)', color: AppTheme.primaryBlue),
              const SizedBox(height: 10),
              _InfoCard(icon: Icons.quiz_rounded, title: 'Total Questions', value: '70 Questions', color: AppTheme.primaryBlue),
              const SizedBox(height: 10),
              _InfoCard(icon: Icons.timer_rounded, title: 'Total Time', value: '60 Minutes', color: AppTheme.accentYellow),
              const SizedBox(height: 10),
              _InfoCard(icon: Icons.assessment_rounded, title: 'Passing Score', value: '70%', color: AppTheme.successGreen),
              const SizedBox(height: 10),
              _InfoCard(icon: Icons.emoji_events_rounded, title: 'Certificate', value: 'E-certificate on completion', color: AppTheme.purpleAccent),
              const SizedBox(height: 24),
              const Text('📌 Important Rules', style: TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _RuleItem(text: '60 minutes total time for all questions', icon: Icons.timer_outlined),
              _RuleItem(text: 'Answer locks after selection - no changes allowed', icon: Icons.lock_outline_rounded),
              _RuleItem(text: 'Auto-save every answer', icon: Icons.save_rounded),
              _RuleItem(text: 'Minimum 5 questions required to submit', icon: Icons.assignment_turned_in_rounded),
              _RuleItem(text: 'Use the navigator panel to jump between questions', icon: Icons.grid_view_rounded),
              _RuleItem(text: 'Dark/Light theme support available', icon: Icons.brightness_6_rounded),
              _RuleItem(text: 'Keyboard shortcuts for desktop users', icon: Icons.keyboard_rounded),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Start Test', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), SizedBox(width: 8), Icon(Icons.play_arrow_rounded, size: 20)]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _InfoCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.w600)), Text(value, style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w800))])),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String text;
  final IconData icon;
  const _RuleItem({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppTheme.primaryBlue, size: 16)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}

// ============================================================
// QUESTION MODEL with Enhanced Features
// ============================================================
class Question {
  final String text;
  final List<String> options;
  final String correctAnswer;
  final String subject;
  final String difficulty;
  final String topic;
  final int points;

  const Question({
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.subject,
    this.difficulty = 'Medium',
    this.topic = 'General',
    this.points = 1,
  });
}

// ============================================================
// EXTENSIVE QUESTION BANK (70+ Questions)
// ============================================================
// Preloaded questions (70 questions from Lesson 1) – stored in memory at startup
const List<Question> _allQuestions = [
  // LESSON 1: IT Fundamentals (Questions 1-70)
  Question(
    subject: 'BS-CIT',
    text: 'IT का full form क्या है?',
    options: ['Internet Tool', 'Information Technology', 'Internal Tech', 'Intelligent Tool'],
    correctAnswer: 'Information Technology',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Information का मतलब क्या है?',
    options: ['Raw data', 'Processed data', 'Numbers', 'Text'],
    correctAnswer: 'Processed data',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Raw data कब information बनता है?',
    options: ['Store होने पर', 'Delete होने पर', 'Process होने पर', 'Copy होने पर'],
    correctAnswer: 'Process होने पर',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Technology का मुख्य काम क्या है?',
    options: ['Time waste करना', 'Human effort बढ़ाना', 'Time save करना', 'Data delete करना'],
    correctAnswer: 'Time save करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'निम्न में से कौन Technology का example है?',
    options: ['Book', 'Computer', 'Paper', 'Pen'],
    correctAnswer: 'Computer',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT का मुख्य काम क्या है?',
    options: ['केवल data store करना', 'Data collect, process, store और share करना', 'केवल typing करना', 'केवल calculation करना'],
    correctAnswer: 'Data collect, process, store और share करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware क्या होता है?',
    options: ['Invisible चीजें', 'Physical devices', 'Programs', 'Internet'],
    correctAnswer: 'Physical devices',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'कौन Hardware है?',
    options: ['MS Word', 'Mouse', 'App', 'Software'],
    correctAnswer: 'Mouse',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Software क्या होता है?',
    options: ['Physical device', 'Instructions/programs', 'Cable', 'Keyboard'],
    correctAnswer: 'Instructions/programs',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'OS किस category में आता है?',
    options: ['Hardware', 'Software', 'Network', 'Data'],
    correctAnswer: 'Software',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'MS Excel क्या है?',
    options: ['Hardware', 'Software', 'Network', 'Data'],
    correctAnswer: 'Software',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data का example क्या है?',
    options: ['Marks of student', 'Computer', 'Mouse', 'CPU'],
    correctAnswer: 'Marks of student',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Network का use किसलिए होता है?',
    options: ['खाना बनाने के लिए', 'Data transfer के लिए', 'Printing के लिए', 'Gaming के लिए'],
    correctAnswer: 'Data transfer के लिए',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Internet क्या है?',
    options: ['Software', 'Network system', 'Hardware', 'Data'],
    correctAnswer: 'Network system',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT का use किस field में होता है?',
    options: ['Education', 'Banking', 'Healthcare', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Online learning किसका example है?',
    options: ['IT application', 'Hardware', 'Software', 'Data'],
    correctAnswer: 'IT application',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'UPI किसका example है?',
    options: ['Manual system', 'Digital payment', 'Hardware', 'Data'],
    correctAnswer: 'Digital payment',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT से क्या benefit है?',
    options: ['Slow work', 'Fast work', 'No change', 'Error increase'],
    correctAnswer: 'Fast work',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT efficiency को क्या करता है?',
    options: ['Reduce', 'Increase', 'Delete', 'Ignore'],
    correctAnswer: 'Increase',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT accuracy को क्या करता है?',
    options: ['Improve करता है', 'घटाता है', 'हटाता है', 'ignore करता है'],
    correctAnswer: 'Improve करता है',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Keyboard क्या है?',
    options: ['Software', 'Hardware', 'Data', 'Network'],
    correctAnswer: 'Hardware',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Monitor क्या है?',
    options: ['Software', 'Hardware', 'Data', 'Internet'],
    correctAnswer: 'Hardware',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mobile app क्या है?',
    options: ['Hardware', 'Software', 'Data', 'Network'],
    correctAnswer: 'Software',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data transfer किससे होता है?',
    options: ['Hardware', 'Network', 'Software', 'CPU'],
    correctAnswer: 'Network',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT का use किसके लिए होता है?',
    options: ['Information management', 'Cooking', 'Sleeping', 'Drawing'],
    correctAnswer: 'Information management',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT किस world को create करता है?',
    options: ['Physical', 'Digital', 'Natural', 'Manual'],
    correctAnswer: 'Digital',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Printer क्या है?',
    options: ['Software', 'Hardware', 'Data', 'Network'],
    correctAnswer: 'Hardware',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data क्या है?',
    options: ['Raw facts', 'Processed info', 'Program', 'Device'],
    correctAnswer: 'Raw facts',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Technology क्या reduce करती है?',
    options: ['Time', 'Effort', 'Both A & B', 'None'],
    correctAnswer: 'Both A & B',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Internet का use क्या है?',
    options: ['Data sharing', 'Cooking', 'Writing', 'Drawing'],
    correctAnswer: 'Data sharing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Information और Data में मुख्य अंतर क्या है?',
    options: ['दोनों same हैं', 'Data processed होता है', 'Information processed data है', 'कोई अंतर नहीं'],
    correctAnswer: 'Information processed data है',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT system का main purpose क्या है?',
    options: ['Entertainment', 'Efficient information management', 'Gaming', 'Printing'],
    correctAnswer: 'Efficient information management',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'निम्न में से कौन IT component नहीं है?',
    options: ['Hardware', 'Software', 'Data', 'Electricity'],
    correctAnswer: 'Electricity',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware बिना Software के क्या होगा?',
    options: ['Work करेगा', 'Partially work', 'Work नहीं करेगा', 'Faster होगा'],
    correctAnswer: 'Work नहीं करेगा',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Software का role क्या है?',
    options: ['Device बनाना', 'Instruction देना', 'Data हटाना', 'Network बनाना'],
    correctAnswer: 'Instruction देना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data sharing possible कैसे होती है?',
    options: ['Hardware से', 'Software से', 'Network से', 'CPU से'],
    correctAnswer: 'Network से',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT का use business में क्यों होता है?',
    options: ['Automation के लिए', 'Drawing के लिए', 'Painting के लिए', 'Writing के लिए'],
    correctAnswer: 'Automation के लिए',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Healthcare में IT का use?',
    options: ['Patient records', 'Cooking', 'Driving', 'Playing'],
    correctAnswer: 'Patient records',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'E-governance किसका example है?',
    options: ['IT application', 'Hardware', 'Software', 'Data'],
    correctAnswer: 'IT application',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT global connectivity कैसे देता है?',
    options: ['Hardware', 'Network & Internet', 'Software', 'Data'],
    correctAnswer: 'Network & Internet',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'कौन IT का advantage नहीं है?',
    options: ['Speed', 'Accuracy', 'Time waste', 'Efficiency'],
    correctAnswer: 'Time waste',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Information useful कब होती है?',
    options: ['Raw होने पर', 'Process होने पर', 'Delete होने पर', 'Copy होने पर'],
    correctAnswer: 'Process होने पर',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU क्या है?',
    options: ['Software', 'Hardware', 'Data', 'Network'],
    correctAnswer: 'Hardware',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Network का main function?',
    options: ['Processing', 'Storage', 'Communication', 'Calculation'],
    correctAnswer: 'Communication',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT किसको improve करता है?',
    options: ['Speed', 'Accuracy', 'Efficiency', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Online booking क्या है?',
    options: ['IT service', 'Hardware', 'Software', 'Data'],
    correctAnswer: 'IT service',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data store कहाँ होता है?',
    options: ['Hardware devices', 'Software', 'Network', 'Internet'],
    correctAnswer: 'Hardware devices',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mobile phone किस category में आता है?',
    options: ['Software', 'Hardware', 'Data', 'Network'],
    correctAnswer: 'Hardware',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Internet बिना network के?',
    options: ['Possible', 'Impossible', 'Slow', 'Fast'],
    correctAnswer: 'Impossible',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT system smooth चलाने के लिए क्या जरूरी है?',
    options: ['Hardware', 'Software', 'Data', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT किसको reduce करता है?',
    options: ['Errors', 'Time', 'Effort', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT career opportunities क्या करता है?',
    options: ['Reduce', 'Increase', 'Delete', 'Ignore'],
    correctAnswer: 'Increase',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'कौन processed data है?',
    options: ['Raw marks', 'Result report', 'Numbers', 'Values'],
    correctAnswer: 'Result report',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT system में data flow कैसे होता है?',
    options: ['Manual', 'Automatic via network', 'Slow', 'None'],
    correctAnswer: 'Automatic via network',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT का foundation क्या है?',
    options: ['Data + Technology', 'Only hardware', 'Only software', 'Only network'],
    correctAnswer: 'Data + Technology',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT system में सबसे critical component कौन है?',
    options: ['Hardware', 'Software', 'Data', 'Network'],
    correctAnswer: 'Data',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'यदि data incorrect है तो result?',
    options: ['Correct', 'Wrong information', 'No change', 'Faster'],
    correctAnswer: 'Wrong information',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT में efficiency किससे आती है?',
    options: ['Automation + Speed', 'Manual work', 'Slow process', 'None'],
    correctAnswer: 'Automation + Speed',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT का primary function cycle क्या है?',
    options: ['Input → Process → Output → Storage → Share', 'Input → Output', 'Process → Output', 'Storage only'],
    correctAnswer: 'Input → Process → Output → Storage → Share',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'बिना network IT system?',
    options: ['Fully functional', 'Limited functional', 'Faster', 'Impossible'],
    correctAnswer: 'Limited functional',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT adoption का biggest impact?',
    options: ['Digital transformation', 'Manual work', 'Slow process', 'None'],
    correctAnswer: 'Digital transformation',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data processing का उद्देश्य?',
    options: ['Meaningful info बनाना', 'Delete करना', 'Store करना', 'Copy करना'],
    correctAnswer: 'Meaningful info बनाना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'कौन IT dependency दिखाता है?',
    options: ['Online class', 'Digital payment', 'E-commerce', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT का role modern world में?',
    options: ['Optional', 'Essential', 'Useless', 'Limited'],
    correctAnswer: 'Essential',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT systems fail कब होते हैं?',
    options: ['Hardware failure', 'Software bug', 'Network issue', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'सबसे fast data sharing medium?',
    options: ['Internet', 'Paper', 'Book', 'Manual'],
    correctAnswer: 'Internet',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT scalability क्या है?',
    options: ['System expand होना', 'System shrink', 'Delete data', 'Stop work'],
    correctAnswer: 'System expand होना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Automation का benefit?',
    options: ['Time saving', 'Accuracy', 'Efficiency', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT का core objective?',
    options: ['Entertainment', 'Information management', 'Gaming', 'Drawing'],
    correctAnswer: 'Information management',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Future world किस पर depend है?',
    options: ['Agriculture', 'IT systems', 'Manual work', 'Paper system'],
    correctAnswer: 'IT systems',
  ),

  // LESSON 2: Computer Fundamentals (Questions 71-140)
  Question(
    subject: 'BS-CIT',
    text: 'Computer शब्द किस भाषा से आया है?',
    options: ['English', 'Latin', 'Hindi', 'Greek'],
    correctAnswer: 'Latin',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Compute का मतलब क्या है?',
    options: ['Store करना', 'Calculate करना', 'Delete करना', 'Print करना'],
    correctAnswer: 'Calculate करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'शुरुआती कंप्यूटर का उपयोग किसलिए होता था?',
    options: ['Gaming', 'Calculation', 'Networking', 'Storage'],
    correctAnswer: 'Calculation',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Early computers किस problem को solve करते थे?',
    options: ['Text', 'Numeric problems', 'Image', 'Video'],
    correctAnswer: 'Numeric problems',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Modern computer क्या है?',
    options: ['Mechanical device', 'Electronic device', 'Manual device', 'Paper system'],
    correctAnswer: 'Electronic device',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer किससे काम करता है?',
    options: ['Paper', 'Electrical signals', 'Ink', 'Wood'],
    correctAnswer: 'Electrical signals',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer क्या है?',
    options: ['Non-programmable', 'Programmable machine', 'Manual device', 'केवल calculator'],
    correctAnswer: 'Programmable machine',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer खुद से काम करता है?',
    options: ['Yes', 'No', 'कभी-कभी', 'Always'],
    correctAnswer: 'No',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer किस पर depend करता है?',
    options: ['User instructions', 'Network', 'Internet', 'Hardware'],
    correctAnswer: 'User instructions',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Instructions को क्या कहते हैं?',
    options: ['Data', 'Program', 'Hardware', 'Network'],
    correctAnswer: 'Program',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Program क्या होता है?',
    options: ['Random data', 'Step-by-step instructions', 'Device', 'Cable'],
    correctAnswer: 'Step-by-step instructions',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT का core component क्या है?',
    options: ['Mobile', 'Computer', 'Internet', 'Data'],
    correctAnswer: 'Computer',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer क्या कर सकता है?',
    options: ['Process data', 'Store data', 'Transfer data', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data processing क्या है?',
    options: ['Data delete करना', 'Data को information में बदलना', 'Data copy करना', 'Data print करना'],
    correctAnswer: 'Data को information में बदलना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer data को कहाँ store करता है?',
    options: ['RAM/Storage', 'Monitor', 'Keyboard', 'Mouse'],
    correctAnswer: 'RAM/Storage',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data transmit का मतलब क्या है?',
    options: ['Delete', 'Send करना', 'Store', 'Print'],
    correctAnswer: 'Send करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data manipulate का मतलब क्या है?',
    options: ['Delete', 'Change करना', 'Store', 'Print'],
    correctAnswer: 'Change करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Retrieve का मतलब क्या है?',
    options: ['Save', 'Delete', 'वापस लाना', 'Copy'],
    correctAnswer: 'वापस लाना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Processing का main purpose क्या है?',
    options: ['Storage', 'Meaningful info बनाना', 'Delete', 'Print'],
    correctAnswer: 'Meaningful info बनाना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Arithmetic operations क्या हैं?',
    options: ['Logical', 'Calculations', 'Storage', 'Input'],
    correctAnswer: 'Calculations',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Addition किस category में आता है?',
    options: ['Logical', 'Arithmetic', 'Network', 'Data'],
    correctAnswer: 'Arithmetic',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Subtraction क्या है?',
    options: ['Logical', 'Arithmetic', 'Data', 'Storage'],
    correctAnswer: 'Arithmetic',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Logical operations किसलिए होते हैं?',
    options: ['Calculation', 'Comparison', 'Storage', 'Printing'],
    correctAnswer: 'Comparison',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Greater than क्या check करता है?',
    options: ['Equal', 'Bigger value', 'Smaller', 'None'],
    correctAnswer: 'Bigger value',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Less than क्या check करता है?',
    options: ['Bigger', 'Smaller value', 'Equal', 'None'],
    correctAnswer: 'Smaller value',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Equal to क्या check करता है?',
    options: ['Difference', 'Equality', 'Greater', 'Smaller'],
    correctAnswer: 'Equality',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'AND operator कब true होता है?',
    options: ['एक condition true', 'सभी condition true', 'कोई भी false', 'None'],
    correctAnswer: 'सभी condition true',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'OR operator कब true होता है?',
    options: ['सभी false', 'एक भी true हो तो', 'सब false', 'None'],
    correctAnswer: 'एक भी true हो तो',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'NOT operator क्या करता है?',
    options: ['Same रखता है', 'Reverse करता है', 'Delete', 'Store'],
    correctAnswer: 'Reverse करता है',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer का use कहाँ होता है?',
    options: ['IT', 'Education', 'Business', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer का original purpose क्या था?',
    options: ['Automation', 'Calculation only', 'Networking', 'Gaming'],
    correctAnswer: 'Calculation only',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Modern computer किस वजह से fast है?',
    options: ['Paper', 'Electronic circuits', 'Manual work', 'Ink'],
    correctAnswer: 'Electronic circuits',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer reliable क्यों है?',
    options: ['Manual', 'Accurate processing', 'Slow', 'Random'],
    correctAnswer: 'Accurate processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Program के बिना computer?',
    options: ['Fully work', 'Partial', 'Work नहीं करेगा', 'Faster'],
    correctAnswer: 'Work नहीं करेगा',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data processing में कौन important है?',
    options: ['Output', 'Input', 'Process', 'Storage'],
    correctAnswer: 'Process',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'कौन IT backbone है?',
    options: ['Internet', 'Computer', 'Data', 'Software'],
    correctAnswer: 'Computer',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer का main cycle क्या है?',
    options: ['Input-Output', 'Input-Process-Output', 'Process only', 'Storage only'],
    correctAnswer: 'Input-Process-Output',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data manipulation का use?',
    options: ['Change data', 'Delete', 'Print', 'Store'],
    correctAnswer: 'Change data',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Retrieval कब use होता है?',
    options: ['Data lost होने पर', 'Data save', 'Data delete', 'Data print'],
    correctAnswer: 'Data lost होने पर',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Arithmetic operations example?',
    options: ['AND', 'OR', 'Addition', 'NOT'],
    correctAnswer: 'Addition',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Logical operations example?',
    options: ['Addition', 'Division', 'Comparison', 'Multiplication'],
    correctAnswer: 'Comparison',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Decision making किससे होती है?',
    options: ['Arithmetic', 'Logical operations', 'Storage', 'Input'],
    correctAnswer: 'Logical operations',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Automation क्या है?',
    options: ['Manual work', 'Automatic task execution', 'Slow work', 'Data delete'],
    correctAnswer: 'Automatic task execution',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'High speed का मतलब?',
    options: ['Slow work', 'Fast processing', 'No work', 'Random'],
    correctAnswer: 'Fast processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Accuracy क्या है?',
    options: ['Error', 'Correctness', 'Slow', 'Fast'],
    correctAnswer: 'Correctness',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Large storage capacity क्या है?',
    options: ['कम data', 'ज्यादा data store करना', 'No data', 'Delete'],
    correctAnswer: 'ज्यादा data store करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Versatility क्या है?',
    options: ['Single work', 'Multi-tasking ability', 'No work', 'Slow'],
    correctAnswer: 'Multi-tasking ability',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer का role IT में?',
    options: ['Optional', 'Core component', 'Limited', 'None'],
    correctAnswer: 'Core component',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Logical operators कहाँ use होते हैं?',
    options: ['Programming', 'Printing', 'Storage', 'Input'],
    correctAnswer: 'Programming',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'AND operator किस पर depend करता है?',
    options: ['Values', 'Conditions', 'Data', 'Output'],
    correctAnswer: 'Conditions',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'OR operator का benefit?',
    options: ['Strict condition', 'Flexible condition', 'No condition', 'None'],
    correctAnswer: 'Flexible condition',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'NOT operator क्या करता है?',
    options: ['Same result', 'Reverse result', 'Delete', 'Store'],
    correctAnswer: 'Reverse result',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer की speed किससे related है?',
    options: ['Manual work', 'Electronic processing', 'Paper', 'Ink'],
    correctAnswer: 'Electronic processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT system में computer क्यों जरूरी है?',
    options: ['Decoration', 'Processing & control', 'Drawing', 'Writing'],
    correctAnswer: 'Processing & control',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer decision कैसे लेता है?',
    options: ['Random', 'Logical operations', 'Manual', 'Slow'],
    correctAnswer: 'Logical operations',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer evolution का main reason?',
    options: ['Technology development', 'Manual work', 'Paper', 'Ink'],
    correctAnswer: 'Technology development',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer programmable क्यों है?',
    options: ['खुद सोचता है', 'Instructions follow करता है', 'Random', 'Manual'],
    correctAnswer: 'Instructions follow करता है',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data processing का core क्या है?',
    options: ['Storage', 'Conversion to information', 'Input', 'Output'],
    correctAnswer: 'Conversion to information',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Logical decision किस पर depend है?',
    options: ['Arithmetic', 'Comparison results', 'Storage', 'Input'],
    correctAnswer: 'Comparison results',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Boolean logic क्या है?',
    options: ['Numbers', 'True/False system', 'Text', 'Image'],
    correctAnswer: 'True/False system',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer की reliability किससे आती है?',
    options: ['Speed', 'Accuracy + consistency', 'Manual work', 'Random'],
    correctAnswer: 'Accuracy + consistency',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer versatility का impact?',
    options: ['Limited use', 'Multi-domain usage', 'No use', 'Slow'],
    correctAnswer: 'Multi-domain usage',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data transmission का role?',
    options: ['Storage', 'Communication', 'Delete', 'Print'],
    correctAnswer: 'Communication',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IT systems depend on?',
    options: ['Only network', 'Only data', 'Computer systems', 'None'],
    correctAnswer: 'Computer systems',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer automation का benefit?',
    options: ['Slow work', 'Time saving + efficiency', 'Error increase', 'None'],
    correctAnswer: 'Time saving + efficiency',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Logical operators का use?',
    options: ['Calculation', 'Decision making', 'Storage', 'Input'],
    correctAnswer: 'Decision making',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer का limitation?',
    options: ['Self-thinking', 'Instruction dependent', 'Fast', 'Accurate'],
    correctAnswer: 'Instruction dependent',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Processing failure कब होगा?',
    options: ['Correct data', 'Wrong input data', 'Fast system', 'Good program'],
    correctAnswer: 'Wrong input data',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Modern IT system का base क्या है?',
    options: ['Paper', 'Computer', 'Pen', 'Book'],
    correctAnswer: 'Computer',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer का final role?',
    options: ['Only calculation', 'Complete IT control system', 'Only storage', 'Only input'],
    correctAnswer: 'Complete IT control system',
  ),

  // LESSON 3: Types of Computers (Questions 141-210)
  Question(
    subject: 'BS-CIT',
    text: 'कंप्यूटर को कितने main types में divide किया जाता है?',
    options: ['2', '3', '4', '5'],
    correctAnswer: '4',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'निम्न में से कौन कंप्यूटर का type है?',
    options: ['Analog', 'Digital', 'Hybrid', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Analog computer किस data पर काम करता है?',
    options: ['Discrete', 'Continuous', 'Binary', 'Text'],
    correctAnswer: 'Continuous',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Continuous data का example क्या है?',
    options: ['Marks', 'Temperature', 'Roll number', 'ID'],
    correctAnswer: 'Temperature',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Thermometer किस type का example है?',
    options: ['Digital', 'Analog', 'Hybrid', 'Quantum'],
    correctAnswer: 'Analog',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Speedometer किसका example है?',
    options: ['Analog computer', 'Digital', 'Hybrid', 'Quantum'],
    correctAnswer: 'Analog computer',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Digital computer किस data पर काम करता है?',
    options: ['Continuous', 'Discrete', 'Physical', 'Analog'],
    correctAnswer: 'Discrete',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Digital computer किस form में data use करता है?',
    options: ['Decimal', 'Binary (0,1)', 'Hexa', 'Text'],
    correctAnswer: 'Binary (0,1)',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Daily life में सबसे ज्यादा कौन सा computer use होता है?',
    options: ['Analog', 'Digital', 'Hybrid', 'Quantum'],
    correctAnswer: 'Digital',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Laptop किस category में आता है?',
    options: ['Analog', 'Digital', 'Hybrid', 'Quantum'],
    correctAnswer: 'Digital',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Smartphone किस type का computer है?',
    options: ['Analog', 'Digital', 'Hybrid', 'Quantum'],
    correctAnswer: 'Digital',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Digital computers की खासियत क्या है?',
    options: ['Slow', 'Accurate & fast', 'Only storage', 'None'],
    correctAnswer: 'Accurate & fast',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Digital computer को किस basis पर classify किया जाता है?',
    options: ['Color', 'Size & performance', 'Weight', 'Shape'],
    correctAnswer: 'Size & performance',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Supercomputer किस category में आता है?',
    options: ['Analog', 'Digital', 'Hybrid', 'Quantum'],
    correctAnswer: 'Digital',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Supercomputer क्या होता है?',
    options: ['Slow', 'Fastest computer', 'Small device', 'Mobile'],
    correctAnswer: 'Fastest computer',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Supercomputer का use कहाँ होता है?',
    options: ['Gaming', 'Weather forecasting', 'Typing', 'Drawing'],
    correctAnswer: 'Weather forecasting',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mainframe computer किसके लिए use होता है?',
    options: ['Individual', 'Large organizations', 'Students', 'Home'],
    correctAnswer: 'Large organizations',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mainframe कितने users support कर सकता है?',
    options: ['1', '2', 'Hundreds/Thousands', 'None'],
    correctAnswer: 'Hundreds/Thousands',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mini computer किसके लिए use होता है?',
    options: ['Large org', 'Small org', 'Only home', 'None'],
    correctAnswer: 'Small org',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mini computer कितने users support करता है?',
    options: ['1', '2', '4–200 users', 'Unlimited'],
    correctAnswer: '4–200 users',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Micro computer किसके लिए होता है?',
    options: ['Organization', 'Individual user', 'Government', 'Bank'],
    correctAnswer: 'Individual user',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Desktop किस type का computer है?',
    options: ['Mini', 'Micro', 'Mainframe', 'Super'],
    correctAnswer: 'Micro',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hybrid computer क्या होता है?',
    options: ['Analog only', 'Digital only', 'Both analog + digital', 'None'],
    correctAnswer: 'Both analog + digital',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hybrid computer कहाँ use होता है?',
    options: ['School', 'Hospital', 'Home', 'Bank'],
    correctAnswer: 'Hospital',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'ECG machine किसका example है?',
    options: ['Analog', 'Digital', 'Hybrid', 'Quantum'],
    correctAnswer: 'Hybrid',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Quantum computer किस principle पर काम करता है?',
    options: ['Electricity', 'Quantum mechanics', 'Heat', 'Motion'],
    correctAnswer: 'Quantum mechanics',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Quantum computer data किसमें store करता है?',
    options: ['Bits', 'Qubits', 'Bytes', 'KB'],
    correctAnswer: 'Qubits',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Qubit क्या allow करता है?',
    options: ['Only 0', 'Only 1', '0 और 1 दोनों साथ', 'None'],
    correctAnswer: '0 और 1 दोनों साथ',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Quantum computers क्या solve करते हैं?',
    options: ['Simple problems', 'Complex problems fast', 'Only typing', 'None'],
    correctAnswer: 'Complex problems fast',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Google Sycamore क्या है?',
    options: ['Analog', 'Digital', 'Quantum computer', 'Hybrid'],
    correctAnswer: 'Quantum computer',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Analog computers की limitation क्या है?',
    options: ['Continuous data', 'Less accuracy', 'High speed', 'Storage'],
    correctAnswer: 'Less accuracy',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Digital computers क्यों popular हैं?',
    options: ['Cheap', 'Accurate & reliable', 'Slow', 'None'],
    correctAnswer: 'Accurate & reliable',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Binary system में कितने digits होते हैं?',
    options: ['10', '2', '8', '16'],
    correctAnswer: '2',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Supercomputer की speed क्यों high होती है?',
    options: ['Size', 'Parallel processing', 'Weight', 'Shape'],
    correctAnswer: 'Parallel processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Weather forecasting में कौन सा computer use होता है?',
    options: ['Micro', 'Mini', 'Supercomputer', 'Hybrid'],
    correctAnswer: 'Supercomputer',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mainframe का main feature क्या है?',
    options: ['Single user', 'Multi-user support', 'Small size', 'Cheap'],
    correctAnswer: 'Multi-user support',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mainframe कहाँ use होता है?',
    options: ['Bank', 'Telecom', 'Government', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mini computer किसके बीच आता है?',
    options: ['Micro & Super', 'Mainframe & Micro', 'Analog & Digital', 'None'],
    correctAnswer: 'Mainframe & Micro',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Micro computer का example?',
    options: ['Laptop', 'Supercomputer', 'Mainframe', 'Mini'],
    correctAnswer: 'Laptop',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hybrid computer क्यों useful है?',
    options: ['Speed + accuracy दोनों', 'Slow', 'Only storage', 'None'],
    correctAnswer: 'Speed + accuracy दोनों',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'ECG machine hybrid क्यों है?',
    options: ['Analog data + digital processing', 'Only analog', 'Only digital', 'None'],
    correctAnswer: 'Analog data + digital processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Quantum computer का biggest advantage?',
    options: ['Size', 'Speed in complex problems', 'Cheap', 'Simple'],
    correctAnswer: 'Speed in complex problems',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Qubit vs Bit difference?',
    options: ['Same', 'Qubit multiple states allow करता है', 'Bit faster', 'None'],
    correctAnswer: 'Qubit multiple states allow करता है',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Digital computer का base क्या है?',
    options: ['Decimal', 'Binary system', 'Analog', 'None'],
    correctAnswer: 'Binary system',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Supercomputer का use scientific simulation में क्यों?',
    options: ['High speed computation', 'Low cost', 'Small size', 'None'],
    correctAnswer: 'High speed computation',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mini computer का use?',
    options: ['Inventory management', 'Weather', 'Space', 'Gaming'],
    correctAnswer: 'Inventory management',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Micro computer का main use?',
    options: ['Personal tasks', 'Multi-user', 'Large org', 'None'],
    correctAnswer: 'Personal tasks',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Analog computer का output कैसा होता है?',
    options: ['Discrete', 'Continuous', 'Binary', 'None'],
    correctAnswer: 'Continuous',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Digital computer का output कैसा होता है?',
    options: ['Continuous', 'Discrete', 'Random', 'None'],
    correctAnswer: 'Discrete',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hybrid computer किस environment में best है?',
    options: ['Low speed', 'Mixed data processing', 'Only storage', 'None'],
    correctAnswer: 'Mixed data processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Quantum computing future क्यों है?',
    options: ['Slow', 'Complex problem solving', 'Cheap', 'None'],
    correctAnswer: 'Complex problem solving',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mainframe vs Supercomputer difference?',
    options: ['Same', 'Multi-user vs high speed computing', 'Size', 'None'],
    correctAnswer: 'Multi-user vs high speed computing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer classification का base क्या है?',
    options: ['Color', 'Working principle & size', 'Shape', 'None'],
    correctAnswer: 'Working principle & size',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Digital computer की limitation?',
    options: ['Continuous data processing weak', 'Binary dependency', 'Speed', 'None'],
    correctAnswer: 'Binary dependency',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Analog vs Digital difference?',
    options: ['Same', 'Continuous vs discrete data', 'Speed', 'None'],
    correctAnswer: 'Continuous vs discrete data',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hybrid computer का architecture क्या combine करता है?',
    options: ['Speed + storage', 'Analog + digital systems', 'Input + output', 'None'],
    correctAnswer: 'Analog + digital systems',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Quantum superposition क्या है?',
    options: ['Single state', 'Multiple states at once', 'Binary', 'None'],
    correctAnswer: 'Multiple states at once',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Quantum computer complexity कैसे reduce करता है?',
    options: ['Parallel states processing', 'Sequential', 'Manual', 'None'],
    correctAnswer: 'Parallel states processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Supercomputer performance measure?',
    options: ['GB', 'FLOPS', 'MB', 'KB'],
    correctAnswer: 'FLOPS',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mainframe reliability क्यों high है?',
    options: ['Backup systems', 'Speed', 'Size', 'None'],
    correctAnswer: 'Backup systems',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mini computer scalability?',
    options: ['Low', 'Moderate scalability', 'High', 'None'],
    correctAnswer: 'Moderate scalability',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Micro computer limitation?',
    options: ['Single user focus', 'Speed', 'Accuracy', 'None'],
    correctAnswer: 'Single user focus',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Analog computer precision issue क्यों?',
    options: ['Continuous variation errors', 'Binary', 'Speed', 'None'],
    correctAnswer: 'Continuous variation errors',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Digital system error control कैसे करता है?',
    options: ['Approximation', 'Exact binary logic', 'Manual', 'None'],
    correctAnswer: 'Exact binary logic',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hybrid system का real-world benefit?',
    options: ['Only storage', 'Real-time processing + accuracy', 'Slow', 'None'],
    correctAnswer: 'Real-time processing + accuracy',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Quantum entanglement क्या है?',
    options: ['Independent data', 'Linked qubits behavior', 'Binary', 'None'],
    correctAnswer: 'Linked qubits behavior',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Future IT systems किस पर depend होंगे?',
    options: ['Analog', 'Quantum computing', 'Paper', 'None'],
    correctAnswer: 'Quantum computing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Supercomputer vs Quantum difference?',
    options: ['Same', 'Classical vs quantum computation', 'Size', 'None'],
    correctAnswer: 'Classical vs quantum computation',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer types evolution क्यों हुआ?',
    options: ['User needs + technology growth', 'Random', 'Slow', 'None'],
    correctAnswer: 'User needs + technology growth',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Most advanced computing paradigm?',
    options: ['Analog', 'Digital', 'Quantum computing', 'Hybrid'],
    correctAnswer: 'Quantum computing',
  ),

  // LESSON 4: Computer Hardware (Questions 211-280)
  Question(
    subject: 'BS-CIT',
    text: 'Monitor को और क्या कहा जाता है?',
    options: ['CPU', 'Display', 'Mouse', 'Printer'],
    correctAnswer: 'Display',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Monitor का काम क्या है?',
    options: ['Input देना', 'Output दिखाना', 'Data store करना', 'Print करना'],
    correctAnswer: 'Output दिखाना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Monitor का दूसरा नाम क्या है?',
    options: ['VDU', 'CPU', 'RAM', 'HDD'],
    correctAnswer: 'VDU',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU का full form क्या है?',
    options: ['Central Power Unit', 'Central Processing Unit', 'Control Processing Unit', 'Computer Power Unit'],
    correctAnswer: 'Central Processing Unit',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU को क्या कहा जाता है?',
    options: ['Heart', 'Brain', 'Memory', 'Device'],
    correctAnswer: 'Brain',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU का काम क्या है?',
    options: ['केवल store करना', 'Data process करना', 'केवल print करना', 'Sound play करना'],
    correctAnswer: 'Data process करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Keyboard का use क्या है?',
    options: ['Output', 'Typing text', 'Sound', 'Print'],
    correctAnswer: 'Typing text',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Keyboard में क्या होते हैं?',
    options: ['Keys', 'Buttons', 'Wires', 'Screens'],
    correctAnswer: 'Keys',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mouse क्या है?',
    options: ['Output device', 'Pointing device', 'Storage', 'CPU'],
    correctAnswer: 'Pointing device',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mouse का काम क्या है?',
    options: ['Typing', 'Cursor control करना', 'Printing', 'Storage'],
    correctAnswer: 'Cursor control करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Printer का use क्या है?',
    options: ['Input', 'Hard copy निकालना', 'Sound', 'Storage'],
    correctAnswer: 'Hard copy निकालना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hard copy क्या है?',
    options: ['Screen output', 'Printed paper', 'Soft copy', 'File'],
    correctAnswer: 'Printed paper',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Printer जरूरी है?',
    options: ['Yes', 'No (optional)', 'Always', 'None'],
    correctAnswer: 'No (optional)',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Speaker का use क्या है?',
    options: ['Typing', 'Sound play करना', 'Printing', 'Storage'],
    correctAnswer: 'Sound play करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'UPS का full form क्या है?',
    options: ['Universal Power Supply', 'Uninterruptible Power Supply', 'Unit Power System', 'User Power Supply'],
    correctAnswer: 'Uninterruptible Power Supply',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'UPS का काम क्या है?',
    options: ['Typing', 'Backup power देना', 'Printing', 'Storage'],
    correctAnswer: 'Backup power देना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Power cut में UPS क्या करता है?',
    options: ['Off', 'Backup देता है', 'Delete', 'Restart'],
    correctAnswer: 'Backup देता है',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Webcam का use क्या है?',
    options: ['Sound', 'Video capture', 'Typing', 'Printing'],
    correctAnswer: 'Video capture',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Webcam कहाँ use होता है?',
    options: ['Video call', 'Typing', 'Storage', 'Print'],
    correctAnswer: 'Video call',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microphone का use क्या है?',
    options: ['Output', 'Voice record करना', 'Print', 'Display'],
    correctAnswer: 'Voice record करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Monitor किस type का device है?',
    options: ['Input', 'Output', 'Storage', 'Processing'],
    correctAnswer: 'Output',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Keyboard किस type का device है?',
    options: ['Input', 'Output', 'Storage', 'CPU'],
    correctAnswer: 'Input',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mouse किस category में आता है?',
    options: ['Input device', 'Output', 'Storage', 'CPU'],
    correctAnswer: 'Input device',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Printer किस category में आता है?',
    options: ['Input', 'Output', 'Storage', 'CPU'],
    correctAnswer: 'Output',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Speaker किस category का है?',
    options: ['Input', 'Output', 'Storage', 'CPU'],
    correctAnswer: 'Output',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU के बिना computer?',
    options: ['Work करेगा', 'Work नहीं करेगा', 'Fast होगा', 'Slow'],
    correctAnswer: 'Work नहीं करेगा',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Keyboard किसके साथ जुड़ा होता है?',
    options: ['Monitor', 'CPU', 'Printer', 'Mouse'],
    correctAnswer: 'CPU',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Monitor क्या दिखाता है?',
    options: ['Sound', 'Information', 'Power', 'Data'],
    correctAnswer: 'Information',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microphone किसमें मदद करता है?',
    options: ['Sound output', 'Voice input', 'Printing', 'Storage'],
    correctAnswer: 'Voice input',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Webcam किसका part है?',
    options: ['Input device', 'Output', 'Storage', 'CPU'],
    correctAnswer: 'Input device',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'VDU का full form क्या है?',
    options: ['Visual Data Unit', 'Visual Display Unit', 'Video Display Unit', 'Virtual Data Unit'],
    correctAnswer: 'Visual Display Unit',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU का main role क्या है?',
    options: ['Input', 'Control & processing', 'Output', 'Storage'],
    correctAnswer: 'Control & processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Keyboard किस typewriter जैसा है?',
    options: ['Digital', 'Manual typing device', 'Printer', 'Screen'],
    correctAnswer: 'Manual typing device',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mouse pointer क्या control करता है?',
    options: ['Sound', 'Screen movement', 'Print', 'Storage'],
    correctAnswer: 'Screen movement',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Printer का output किस form में होता है?',
    options: ['Soft copy', 'Hard copy', 'Audio', 'Video'],
    correctAnswer: 'Hard copy',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Speaker क्या output देता है?',
    options: ['Visual', 'Audio', 'Text', 'Binary'],
    correctAnswer: 'Audio',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'UPS का main benefit क्या है?',
    options: ['Speed', 'Data safety', 'Storage', 'Sound'],
    correctAnswer: 'Data safety',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Webcam क्या capture करता है?',
    options: ['Sound', 'Image & video', 'Text', 'Binary'],
    correctAnswer: 'Image & video',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microphone किसके लिए जरूरी है?',
    options: ['Typing', 'Voice communication', 'Printing', 'Storage'],
    correctAnswer: 'Voice communication',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU को brain क्यों कहते हैं?',
    options: ['Size', 'Control function', 'Speed', 'Color'],
    correctAnswer: 'Control function',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Output device कौन है?',
    options: ['Keyboard', 'Mouse', 'Monitor', 'Microphone'],
    correctAnswer: 'Monitor',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Input device कौन है?',
    options: ['Printer', 'Speaker', 'Keyboard', 'Monitor'],
    correctAnswer: 'Keyboard',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'UPS computer को किससे बचाता है?',
    options: ['Virus', 'Power failure', 'Heat', 'Dust'],
    correctAnswer: 'Power failure',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Monitor किसके साथ work करता है?',
    options: ['Keyboard input', 'Printer', 'Mouse only', 'Speaker'],
    correctAnswer: 'Keyboard input',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU का function?',
    options: ['केवल display', 'Data processing & control', 'Sound', 'Print'],
    correctAnswer: 'Data processing & control',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hard copy vs soft copy difference?',
    options: ['Same', 'Paper vs digital', 'Speed', 'None'],
    correctAnswer: 'Paper vs digital',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Webcam का use education में?',
    options: ['Typing', 'Online classes', 'Printing', 'Storage'],
    correctAnswer: 'Online classes',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Speaker किस system का part है?',
    options: ['Input', 'Output system', 'Storage', 'Processing'],
    correctAnswer: 'Output system',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Keyboard special keys का use?',
    options: ['Only typing', 'Commands देना', 'Storage', 'Output'],
    correctAnswer: 'Commands देना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mouse के बिना क्या possible है?',
    options: ['Cursor control मुश्किल', 'Printing', 'Sound', 'Storage'],
    correctAnswer: 'Cursor control मुश्किल',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Printer optional क्यों है?',
    options: ['जरूरी नहीं', 'Digital work possible है', 'Slow', 'None'],
    correctAnswer: 'Digital work possible है',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU + Input + Output मिलकर क्या बनाते हैं?',
    options: ['Complete system', 'Network', 'Storage', 'None'],
    correctAnswer: 'Complete system',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microphone किस signal को convert करता है?',
    options: ['Audio to digital input', 'Text', 'Video', 'None'],
    correctAnswer: 'Audio to digital input',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'UPS battery based device है?',
    options: ['Yes', 'No', 'Maybe', 'None'],
    correctAnswer: 'Yes',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Webcam का limitation?',
    options: ['Low resolution issue', 'Lighting dependency', 'Speed', 'None'],
    correctAnswer: 'Lighting dependency',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU processing का core क्या है?',
    options: ['ALU + Control Unit', 'Monitor', 'Keyboard', 'Mouse'],
    correctAnswer: 'ALU + Control Unit',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Input-output cycle क्या है?',
    options: ['Data flow process', 'Storage', 'Printing', 'None'],
    correctAnswer: 'Data flow process',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Keyboard buffering क्या है?',
    options: ['Temporary input storage', 'Output', 'Print', 'None'],
    correctAnswer: 'Temporary input storage',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mouse DPI क्या define करता है?',
    options: ['Speed', 'Sensitivity', 'Size', 'Weight'],
    correctAnswer: 'Sensitivity',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Printer types किस base पर होते हैं?',
    options: ['Output method', 'Input', 'Speed', 'None'],
    correctAnswer: 'Output method',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'UPS power supply type?',
    options: ['Continuous backup power', 'Direct power', 'No power', 'Random'],
    correctAnswer: 'Continuous backup power',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microphone signal conversion?',
    options: ['Analog to digital', 'Digital to analog', 'Binary', 'None'],
    correctAnswer: 'Analog to digital',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Webcam frame rate क्या impact करता है?',
    options: ['Video smoothness', 'Sound', 'Storage', 'None'],
    correctAnswer: 'Video smoothness',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Monitor resolution क्या define करता है?',
    options: ['Size', 'Clarity of image', 'Speed', 'Sound'],
    correctAnswer: 'Clarity of image',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Speaker quality किस पर depend है?',
    options: ['Frequency response', 'Size', 'Weight', 'None'],
    correctAnswer: 'Frequency response',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU bottleneck कब होता है?',
    options: ['Slow processing', 'Fast', 'Normal', 'None'],
    correctAnswer: 'Slow processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Input latency क्या है?',
    options: ['Delay in input processing', 'Speed', 'Output', 'None'],
    correctAnswer: 'Delay in input processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware integration क्या है?',
    options: ['Devices coordination', 'Storage', 'Input', 'None'],
    correctAnswer: 'Devices coordination',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'System failure कब होता है?',
    options: ['Power loss बिना UPS', 'Fast', 'Normal', 'None'],
    correctAnswer: 'Power loss बिना UPS',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer efficiency किस पर depend है?',
    options: ['Hardware + input/output coordination', 'Color', 'Size', 'None'],
    correctAnswer: 'Hardware + input/output coordination',
  ),

  // LESSON 5: Computer Evolution & Generations (Questions 281-350)
  Question(
    subject: 'BS-CIT',
    text: 'कंप्यूटर का evolution कहाँ से शुरू हुआ?',
    options: ['AI', 'Counting tools', 'Internet', 'Robots'],
    correctAnswer: 'Counting tools',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Ancient time में लोग किससे counting करते थे?',
    options: ['Computers', 'Sticks, stones, bones', 'Mobile', 'Calculator'],
    correctAnswer: 'Sticks, stones, bones',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Abacus कहाँ develop हुआ था?',
    options: ['India', 'China', 'USA', 'Japan'],
    correctAnswer: 'China',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Abacus का use किसलिए होता था?',
    options: ['Gaming', 'Calculation', 'Storage', 'Printing'],
    correctAnswer: 'Calculation',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Abacus में क्या होता है?',
    options: ['स्क्रीन', 'Beads और rods', 'Keyboard', 'CPU'],
    correctAnswer: 'Beads और rods',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Napier Bones किसने invent किया?',
    options: ['Pascal', 'John Napier', 'Babbage', 'Ada'],
    correctAnswer: 'John Napier',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Napier Bones का use?',
    options: ['Addition', 'Multiplication & Division', 'Storage', 'Printing'],
    correctAnswer: 'Multiplication & Division',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Pascaline किसने बनाया?',
    options: ['John Napier', 'Blaise Pascal', 'Babbage', 'Ada'],
    correctAnswer: 'Blaise Pascal',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Pascaline क्या था?',
    options: ['Electronic device', 'Mechanical calculator', 'Software', 'Network'],
    correctAnswer: 'Mechanical calculator',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Analytical Engine किसने design किया?',
    options: ['Pascal', 'Charles Babbage', 'Ada', 'Napier'],
    correctAnswer: 'Charles Babbage',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Charles Babbage को क्या कहा जाता है?',
    options: ['Scientist', 'Father of Computer', 'Engineer', 'Teacher'],
    correctAnswer: 'Father of Computer',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Analytical Engine क्या use करता था?',
    options: ['Keyboard', 'Punch cards', 'Mouse', 'Monitor'],
    correctAnswer: 'Punch cards',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'First programmer कौन मानी जाती हैं?',
    options: ['Ada Lovelace', 'Marie Curie', 'Pascal', 'Napier'],
    correctAnswer: 'Ada Lovelace',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer की कितनी generations होती हैं?',
    options: ['3', '4', '5', '6'],
    correctAnswer: '5',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'First generation कब थी?',
    options: ['1900–1920', '1940–1956', '1960–1980', '2000–2020'],
    correctAnswer: '1940–1956',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'First generation में क्या use होता था?',
    options: ['Transistor', 'Vacuum tubes', 'IC', 'Microprocessor'],
    correctAnswer: 'Vacuum tubes',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'First generation computers कैसे थे?',
    options: ['Small', 'Large & heavy', 'Portable', 'Cheap'],
    correctAnswer: 'Large & heavy',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Second generation में क्या use हुआ?',
    options: ['IC', 'Transistor', 'Vacuum tube', 'AI'],
    correctAnswer: 'Transistor',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Third generation में क्या use हुआ?',
    options: ['IC (Integrated Circuit)', 'Transistor', 'Vacuum tube', 'AI'],
    correctAnswer: 'IC (Integrated Circuit)',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Fourth generation में क्या use हुआ?',
    options: ['IC', 'VLSI', 'Vacuum', 'Transistor'],
    correctAnswer: 'VLSI',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Fifth generation किस पर based है?',
    options: ['Vacuum', 'AI', 'Transistor', 'IC'],
    correctAnswer: 'AI',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Machine language किस generation में थी?',
    options: ['First', 'Second', 'Third', 'Fourth'],
    correctAnswer: 'First',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'COBOL किस generation में आया?',
    options: ['First', 'Second', 'Third', 'Fourth'],
    correctAnswer: 'Second',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Time-sharing system किस generation में आया?',
    options: ['First', 'Second', 'Third', 'Fourth'],
    correctAnswer: 'Third',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microprocessor किस generation में आया?',
    options: ['Third', 'Fourth', 'Fifth', 'Second'],
    correctAnswer: 'Fourth',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'PC (Personal Computer) कब आया?',
    options: ['1st gen', '4th gen', '2nd gen', '3rd gen'],
    correctAnswer: '4th gen',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'AI किस generation से जुड़ा है?',
    options: ['Fourth', 'Fifth', 'Third', 'Second'],
    correctAnswer: 'Fifth',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computers का size कैसे change हुआ?',
    options: ['बढ़ा', 'घटा', 'same', 'None'],
    correctAnswer: 'घटा',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Speed generations में क्या हुआ?',
    options: ['कम हुई', 'बढ़ी', 'same', 'None'],
    correctAnswer: 'बढ़ी',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Cost generations में क्या हुआ?',
    options: ['बढ़ी', 'घटी', 'same', 'None'],
    correctAnswer: 'घटी',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Abacus क्यों important है?',
    options: ['Storage', 'First calculating device', 'AI', 'None'],
    correctAnswer: 'First calculating device',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Napier Bones का main contribution?',
    options: ['Storage', 'Decimal calculation improvement', 'AI', 'Network'],
    correctAnswer: 'Decimal calculation improvement',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Pascaline limitation?',
    options: ['Only addition/subtraction', 'Fast', 'Portable', 'Cheap'],
    correctAnswer: 'Only addition/subtraction',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Analytical Engine advanced क्यों था?',
    options: ['Punch card + memory + processing', 'Only input', 'Only output', 'None'],
    correctAnswer: 'Punch card + memory + processing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Ada Lovelace का contribution?',
    options: ['Hardware', 'Programming concept', 'Network', 'Storage'],
    correctAnswer: 'Programming concept',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'First generation limitation?',
    options: ['Size', 'Heat', 'Power consumption', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Second generation advantage?',
    options: ['Smaller & reliable', 'Bigger', 'Slow', 'None'],
    correctAnswer: 'Smaller & reliable',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Third generation advantage?',
    options: ['IC usage', 'Speed increase', 'Reliability', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Fourth generation key feature?',
    options: ['Microprocessor', 'Vacuum', 'IC', 'None'],
    correctAnswer: 'Microprocessor',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Fifth generation focus?',
    options: ['AI & smart systems', 'Size', 'Storage', 'None'],
    correctAnswer: 'AI & smart systems',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Machine language क्या है?',
    options: ['High level', 'Binary language', 'English', 'None'],
    correctAnswer: 'Binary language',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'High-level language कब आया?',
    options: ['First', 'Third', 'Second', 'Fourth'],
    correctAnswer: 'Third',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mainframe evolution कब हुआ?',
    options: ['Early generations', 'Mid generations', 'Late', 'None'],
    correctAnswer: 'Mid generations',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Internet growth कब शुरू हुआ?',
    options: ['First', 'Fourth', 'Second', 'Third'],
    correctAnswer: 'Fourth',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'VLSI क्या है?',
    options: ['Small scale', 'Very large scale integration', 'Medium', 'None'],
    correctAnswer: 'Very large scale integration',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'ULSI किस generation में?',
    options: ['Fourth', 'Fifth', 'Third', 'Second'],
    correctAnswer: 'Fifth',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Punch card use किसमें था?',
    options: ['First gen', 'Second', 'Third', 'Fourth'],
    correctAnswer: 'First gen',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Transistor vs Vacuum difference?',
    options: ['Smaller & efficient', 'Bigger', 'Same', 'None'],
    correctAnswer: 'Smaller & efficient',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IC का impact?',
    options: ['Size reduce + speed increase', 'Slow', 'Big', 'None'],
    correctAnswer: 'Size reduce + speed increase',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microprocessor role?',
    options: ['CPU on chip', 'Storage', 'Input', 'Output'],
    correctAnswer: 'CPU on chip',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Evolution क्यों हुआ?',
    options: ['जरूरत', 'technology growth', 'efficiency', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'AI systems क्या करते हैं?',
    options: ['Think & learn', 'Only calculate', 'Only store', 'None'],
    correctAnswer: 'Think & learn',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Fifth gen example?',
    options: ['Smartphone', 'AI systems', 'Robotics', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer evolution का pattern?',
    options: ['Size ↓ Speed ↑ Efficiency ↑', 'Random', 'Slow', 'None'],
    correctAnswer: 'Size ↓ Speed ↑ Efficiency ↑',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Reliability कब improve हुई?',
    options: ['1st gen', '2nd gen onward', '3rd only', 'None'],
    correctAnswer: '2nd gen onward',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Analytical Engine modern computers का base क्यों है?',
    options: ['Input-output-memory concept', 'Size', 'Speed', 'None'],
    correctAnswer: 'Input-output-memory concept',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Evolution का biggest leap?',
    options: ['Mechanical → Electronic', 'Small', 'Big', 'None'],
    correctAnswer: 'Mechanical → Electronic',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Vacuum tube limitation root cause?',
    options: ['Heat & power inefficiency', 'Speed', 'Size', 'None'],
    correctAnswer: 'Heat & power inefficiency',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Transistor revolution क्यों था?',
    options: ['Reliability + size reduction', 'Big', 'Slow', 'None'],
    correctAnswer: 'Reliability + size reduction',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'IC revolution impact?',
    options: ['Integration of circuits', 'Storage', 'Input', 'None'],
    correctAnswer: 'Integration of circuits',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microprocessor innovation?',
    options: ['Single chip CPU', 'Memory', 'Network', 'None'],
    correctAnswer: 'Single chip CPU',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'AI generation future क्यों?',
    options: ['Self-learning systems', 'Slow', 'Manual', 'None'],
    correctAnswer: 'Self-learning systems',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Evolution dependency?',
    options: ['User needs', 'Tech growth', 'Efficiency', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Quantum + AI future impact?',
    options: ['Intelligent systems', 'Manual', 'Slow', 'None'],
    correctAnswer: 'Intelligent systems',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Programming evolution क्यों हुआ?',
    options: ['Ease of use', 'Hard', 'Slow', 'None'],
    correctAnswer: 'Ease of use',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Generation change driver?',
    options: ['Technology innovation', 'Random', 'Slow', 'None'],
    correctAnswer: 'Technology innovation',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Modern computer base?',
    options: ['Babbage design concept', 'Random', 'Manual', 'None'],
    correctAnswer: 'Babbage design concept',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Evolution trend क्या दिखाता है?',
    options: ['Continuous improvement', 'Random', 'Stop', 'None'],
    correctAnswer: 'Continuous improvement',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Future computers कैसे होंगे?',
    options: ['Slow', 'Intelligent & powerful', 'Big', 'None'],
    correctAnswer: 'Intelligent & powerful',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Computer evolution का final goal?',
    options: ['Speed', 'Efficiency', 'Intelligence', 'All of these'],
    correctAnswer: 'All of these',
  ),

  // LESSON 6: Computer System Components (Questions 351-420)
  Question(
    subject: 'BS-CIT',
    text: 'कंप्यूटर सिस्टम कितने main components से मिलकर बना है?',
    options: ['1', '2', '3', '4'],
    correctAnswer: '2',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'कंप्यूटर के दो मुख्य components कौन से हैं?',
    options: ['Input & Output', 'Hardware & Software', 'Data & Network', 'CPU & RAM'],
    correctAnswer: 'Hardware & Software',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware क्या होता है?',
    options: ['Instructions', 'Physical parts', 'Programs', 'Data'],
    correctAnswer: 'Physical parts',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Software क्या होता है?',
    options: ['Machine', 'Programs collection', 'Device', 'Cable'],
    correctAnswer: 'Programs collection',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware को हम क्या कर सकते हैं?',
    options: ['देख और छू सकते हैं', 'नहीं देख सकते', 'नहीं छू सकते', 'None'],
    correctAnswer: 'देख और छू सकते हैं',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Software को हम क्या कर सकते हैं?',
    options: ['छू सकते हैं', 'नहीं छू सकते', 'पकड़ सकते हैं', 'None'],
    correctAnswer: 'नहीं छू सकते',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Keyboard किस category में आता है?',
    options: ['Input device', 'Output', 'Storage', 'Processing'],
    correctAnswer: 'Input device',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Mouse किसका example है?',
    options: ['Input device', 'Output', 'Storage', 'CPU'],
    correctAnswer: 'Input device',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Scanner का use क्या है?',
    options: ['Print', 'Document digitize करना', 'Sound', 'Store'],
    correctAnswer: 'Document digitize करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microphone क्या करता है?',
    options: ['Sound output', 'Sound input', 'Print', 'Store'],
    correctAnswer: 'Sound input',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU किस category में आता है?',
    options: ['Input', 'Processing device', 'Output', 'Storage'],
    correctAnswer: 'Processing device',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU को क्या कहा जाता है?',
    options: ['Heart', 'Brain', 'Memory', 'Device'],
    correctAnswer: 'Brain',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microprocessor क्या है?',
    options: ['Large device', 'Small chip', 'Software', 'Cable'],
    correctAnswer: 'Small chip',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Output device का काम क्या है?',
    options: ['Input देना', 'Result दिखाना', 'Data store', 'Process'],
    correctAnswer: 'Result दिखाना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Monitor क्या करता है?',
    options: ['Sound', 'Visual output', 'Store', 'Process'],
    correctAnswer: 'Visual output',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Printer क्या देता है?',
    options: ['Soft copy', 'Hard copy', 'Sound', 'Data'],
    correctAnswer: 'Hard copy',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Speaker क्या देता है?',
    options: ['Visual', 'Sound output', 'Data', 'Input'],
    correctAnswer: 'Sound output',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Storage device का काम क्या है?',
    options: ['Process', 'Store data', 'Input', 'Output'],
    correctAnswer: 'Store data',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'RAM किस type की storage है?',
    options: ['Secondary', 'Primary', 'External', 'None'],
    correctAnswer: 'Primary',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hard disk किस type की storage है?',
    options: ['Primary', 'Secondary', 'Input', 'Output'],
    correctAnswer: 'Secondary',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Pen drive क्या है?',
    options: ['Input', 'Storage device', 'Output', 'CPU'],
    correctAnswer: 'Storage device',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Program क्या होता है?',
    options: ['Device', 'Instructions set', 'Data', 'Output'],
    correctAnswer: 'Instructions set',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Software का main काम क्या है?',
    options: ['Control hardware', 'Store data', 'Print', 'Input'],
    correctAnswer: 'Control hardware',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'System software क्या करता है?',
    options: ['User task', 'System control', 'Gaming', 'None'],
    correctAnswer: 'System control',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Operating system किस type का software है?',
    options: ['Application', 'System software', 'Utility', 'None'],
    correctAnswer: 'System software',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Compiler किसका example है?',
    options: ['Application', 'System software', 'Hardware', 'None'],
    correctAnswer: 'System software',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Application software किसके लिए होता है?',
    options: ['System', 'User tasks', 'Hardware', 'Network'],
    correctAnswer: 'User tasks',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'MS Word क्या है?',
    options: ['System software', 'Application software', 'Hardware', 'None'],
    correctAnswer: 'Application software',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Chrome क्या है?',
    options: ['Hardware', 'Browser (Application software)', 'OS', 'None'],
    correctAnswer: 'Browser (Application software)',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware और Software मिलकर क्या बनाते हैं?',
    options: ['Network', 'Complete system', 'Data', 'None'],
    correctAnswer: 'Complete system',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware का main role क्या है?',
    options: ['Control', 'Physical structure + processing capability', 'Storage', 'Input'],
    correctAnswer: 'Physical structure + processing capability',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Input devices का function?',
    options: ['Output', 'Data entry', 'Storage', 'Process'],
    correctAnswer: 'Data entry',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Processing devices क्या करते हैं?',
    options: ['Input', 'Execute instructions', 'Output', 'Store'],
    correctAnswer: 'Execute instructions',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Output devices क्या करते हैं?',
    options: ['Data entry', 'Result display', 'Storage', 'Process'],
    correctAnswer: 'Result display',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Storage devices का role?',
    options: ['Input', 'Store programs & data', 'Output', 'Process'],
    correctAnswer: 'Store programs & data',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Primary storage example?',
    options: ['RAM, ROM', 'HDD', 'SSD', 'Pen drive'],
    correctAnswer: 'RAM, ROM',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Secondary storage example?',
    options: ['RAM', 'HDD, SSD', 'CPU', 'Keyboard'],
    correctAnswer: 'HDD, SSD',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microprocessor का role?',
    options: ['Control + processing on chip', 'Storage', 'Input', 'Output'],
    correctAnswer: 'Control + processing on chip',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Modern CPU क्या है?',
    options: ['Mechanical', 'Microprocessor chip', 'Software', 'None'],
    correctAnswer: 'Microprocessor chip',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Software visible क्यों नहीं होता?',
    options: ['Physical नहीं है', 'Small है', 'Hidden', 'None'],
    correctAnswer: 'Physical नहीं है',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Program analogy क्या है?',
    options: ['Device', 'Recipe (step-by-step instructions)', 'Data', 'Output'],
    correctAnswer: 'Recipe (step-by-step instructions)',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'System software का main role?',
    options: ['User tasks', 'Manage system resources', 'Storage', 'Input'],
    correctAnswer: 'Manage system resources',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Utility programs क्या करते हैं?',
    options: ['Gaming', 'Assist system performance', 'Printing', 'None'],
    correctAnswer: 'Assist system performance',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Antivirus क्या है?',
    options: ['Hardware', 'Utility software', 'Input', 'Output'],
    correctAnswer: 'Utility software',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Application software का use?',
    options: ['System control', 'Specific user tasks', 'Storage', 'Network'],
    correctAnswer: 'Specific user tasks',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Word processor का काम?',
    options: ['Calculation', 'Text editing', 'Sound', 'Image'],
    correctAnswer: 'Text editing',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Spreadsheet software का काम?',
    options: ['Writing', 'Calculation & data analysis', 'Sound', 'None'],
    correctAnswer: 'Calculation & data analysis',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Browser का काम?',
    options: ['Offline', 'Internet access', 'Storage', 'Print'],
    correctAnswer: 'Internet access',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware बिना software?',
    options: ['Work करेगा', 'Work नहीं करेगा', 'Fast होगा', 'None'],
    correctAnswer: 'Work नहीं करेगा',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Software बिना hardware?',
    options: ['Possible', 'Not possible', 'Fast', 'None'],
    correctAnswer: 'Not possible',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Input → Process → Output cycle किसका है?',
    options: ['System working', 'Storage', 'Network', 'None'],
    correctAnswer: 'System working',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Storage का importance?',
    options: ['Temporary', 'Future use data save करना', 'Input', 'Output'],
    correctAnswer: 'Future use data save करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU operations कौन control करता है?',
    options: ['User', 'Software instructions', 'Network', 'None'],
    correctAnswer: 'Software instructions',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware categories कितनी हैं?',
    options: ['2', '3', '4', '5'],
    correctAnswer: '4',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microprocessor based devices?',
    options: ['Laptop', 'Smartphone', 'Desktop', 'All of these'],
    correctAnswer: 'All of these',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware-software coordination क्यों जरूरी है?',
    options: ['System functionality', 'Speed', 'Storage', 'None'],
    correctAnswer: 'System functionality',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'CPU architecture क्या control करता है?',
    options: ['Input', 'Processing efficiency', 'Output', 'Storage'],
    correctAnswer: 'Processing efficiency',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'RAM vs ROM difference?',
    options: ['Same', 'Volatile vs non-volatile', 'Size', 'None'],
    correctAnswer: 'Volatile vs non-volatile',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Secondary storage advantage?',
    options: ['Temporary', 'Permanent storage', 'Input', 'Output'],
    correctAnswer: 'Permanent storage',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Microprocessor evolution impact?',
    options: ['Smaller devices + higher power', 'Slow', 'Big', 'None'],
    correctAnswer: 'Smaller devices + higher power',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Software abstraction क्या है?',
    options: ['Hardware hide करना', 'Show', 'Store', 'None'],
    correctAnswer: 'Hardware hide करना',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Compiler vs Interpreter difference?',
    options: ['Same', 'Full vs line-by-line execution', 'Speed', 'None'],
    correctAnswer: 'Full vs line-by-line execution',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'OS role critical क्यों है?',
    options: ['Resource management', 'Input', 'Output', 'None'],
    correctAnswer: 'Resource management',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Hardware bottleneck कब होता है?',
    options: ['Slow component limit करता है', 'Fast', 'Normal', 'None'],
    correctAnswer: 'Slow component limit करता है',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'System performance depend करता है?',
    options: ['Hardware', 'Software', 'Both coordination', 'None'],
    correctAnswer: 'Both coordination',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Data storage hierarchy क्या है?',
    options: ['Random', 'Speed vs cost based levels', 'Size', 'None'],
    correctAnswer: 'Speed vs cost based levels',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Utility software importance?',
    options: ['Optional', 'System maintenance', 'Slow', 'None'],
    correctAnswer: 'System maintenance',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Application software limitation?',
    options: ['Specific tasks only', 'General', 'Fast', 'None'],
    correctAnswer: 'Specific tasks only',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Future systems trend?',
    options: ['Hardware only', 'Software only', 'Integrated systems', 'None'],
    correctAnswer: 'Integrated systems',
  ),
  Question(
    subject: 'BS-CIT',
    text: 'Complete computer system definition?',
    options: ['Hardware', 'Software', 'Hardware + Software interaction', 'None'],
    correctAnswer: 'Hardware + Software interaction',
  ),
];


// ============================================================
// MAIN QUIZ APP SCREEN with 30+ Advanced Features
// ============================================================
class QuizAppScreen extends StatefulWidget {
  final String studentName;
  const QuizAppScreen({super.key, required this.studentName});

  @override
  State<QuizAppScreen> createState() => _QuizAppScreenState();
}

class _QuizAppScreenState extends State<QuizAppScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  // ============================================================
  // FEATURE 1: GLOBAL TIMER SYSTEM
  // ============================================================
  static const int totalTimeSeconds = 60 * 60;
  static const int warningTime1 = 10 * 60;
  static const int warningTime2 = 5 * 60;
  static const int warningTime3 = 60;
  
  int _remainingSeconds = totalTimeSeconds;
  Timer? _globalTimer;
  bool _isQuizActive = true;
  bool _isPaused = false;
  late AnimationController _timerAnimationController;
  
  // ============================================================
  // FEATURE 2: QUIZ STATE MANAGEMENT
  // ============================================================
  int _currentIndex = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;
  
  // Answer tracking
  final List<String?> _userAnswers = List.filled(_allQuestions.length, null);
  final List<bool> _isCorrectList = List.filled(_allQuestions.length, false);
  final List<bool> _isSkippedList = List.filled(_allQuestions.length, false);
  
  // ============================================================
  // FEATURE 3: BOOKMARK & FLAG SYSTEM
  // ============================================================
  final List<bool> _isFlagged = List.filled(_allQuestions.length, false);
  final List<bool> _isBookmarked = List.filled(_allQuestions.length, false);
  final List<bool> _isMarkedForReview = List.filled(_allQuestions.length, false);
  
  // ============================================================
  // FEATURE 4: NOTES & ELIMINATION
  // ============================================================
  final List<String> _questionNotes = List.filled(_allQuestions.length, '');
  final List<Set<int>> _eliminatedOptions = List.generate(_allQuestions.length, (_) => {});
  
  // ============================================================
  // FEATURE 5: PERFORMANCE ANALYTICS
  // ============================================================
  int _answerStreak = 0;
  int _bestStreak = 0;
  final List<DateTime> _answerTimestamps = [];
  final List<int> _questionTimes = List.filled(_allQuestions.length, 0);
  int _questionStartTime = 0;
  
  // ============================================================
  // FEATURE 6: THEME & UI
  // ============================================================
  bool _isDarkMode = false;
  
  // ============================================================
  // FEATURE 7: RANDOMIZATION
  // ============================================================
  bool _randomizeQuestions = false;
  bool _randomizeOptions = false;
  List<int> _questionOrder = [];
  List<List<int>> _optionsOrder = [];
  
  // ============================================================
  // FEATURE 8: ACHIEVEMENT SYSTEM
  // ============================================================
  final Set<String> _unlockedAchievements = {};
  int _quickAnswers = 0;
  int _perfectSections = 0;
  
  // ============================================================
  // FEATURE 9: STATISTICS
  // ============================================================
  Map<String, int> _topicPerformance = {};
  Map<String, int> _difficultyPerformance = {};
  
  // ============================================================
  // FEATURE 10: EXAM MODE
  // ============================================================
  bool _isFullScreen = false;
  bool _focusMode = false;
  
  // Keyboard shortcuts service
  final Map<LogicalKeyboardKey, VoidCallback> _shortcuts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timerAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: totalTimeSeconds));
    _initializeQuiz();
    _setupKeyboardShortcuts();
  }
  
  void _setupKeyboardShortcuts() {
    _shortcuts[LogicalKeyboardKey.arrowLeft] = _goToPreviousQuestion;
    _shortcuts[LogicalKeyboardKey.arrowRight] = _goToNextQuestion;
    _shortcuts[LogicalKeyboardKey.keyN] = () => _showQuestionNoteDialog();
    _shortcuts[LogicalKeyboardKey.keyF] = () => _toggleFlag(_currentIndex);
    _shortcuts[LogicalKeyboardKey.keyB] = () => _toggleBookmark(_currentIndex);
    _shortcuts[LogicalKeyboardKey.keyR] = () => _toggleMarkForReview(_currentIndex);
    _shortcuts[LogicalKeyboardKey.enter] = _showSubmitPreviewDialog;
  }
  
  void _initializeQuiz() async {
    _initializeRandomization();
    await _loadSavedState();
    _startGlobalTimer();
    _questionStartTime = DateTime.now().millisecondsSinceEpoch;
    _timerAnimationController.forward();
  }
  
  void _initializeRandomization() {
    _questionOrder = List.generate(_allQuestions.length, (i) => i);
    if (_randomizeQuestions) _questionOrder.shuffle();
    _optionsOrder = List.generate(_allQuestions.length, (i) => List.generate(_allQuestions[i].options.length, (j) => j));
    if (_randomizeOptions) for (int i = 0; i < _optionsOrder.length; i++) _optionsOrder[i].shuffle();
  }
  
  int _getActualQuestionIndex(int displayIndex) => _questionOrder[displayIndex];
  
  List<String> _getShuffledOptions(int actualIndex) {
    if (!_randomizeOptions) return _allQuestions[actualIndex].options;
    return _optionsOrder[actualIndex].map((i) => _allQuestions[actualIndex].options[i]).toList();
  }
  
  // ============================================================
  // FEATURE 11: AUTO-SAVE & RESTORE
  // ============================================================
  void _startGlobalTimer() {
    _globalTimer?.cancel();
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isPaused || !_isQuizActive) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        if (_remainingSeconds == warningTime1 || _remainingSeconds == warningTime2 || _remainingSeconds == warningTime3) _showWarningToast();
        _saveTimerState();
        if (_remainingSeconds <= 0) timer.cancel();
      } else {
        timer.cancel();
        _autoSubmitOnTimerEnd();
      }
    });
  }
  
  void _showWarningToast() {
    String message;
    if (_remainingSeconds == warningTime1) message = '⚠️ 10 minutes remaining!';
    else if (_remainingSeconds == warningTime2) message = '⚠️ 5 minutes remaining!';
    else message = '⚠️ Last 1 minute!';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.warningOrange, duration: const Duration(seconds: 3)));
  }
  
  void _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_remaining_seconds', _remainingSeconds);
    await prefs.setInt('quiz_save_time', DateTime.now().millisecondsSinceEpoch);
  }
  
  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRemaining = prefs.getInt('quiz_remaining_seconds');
    final saveTime = prefs.getInt('quiz_save_time');
    if (savedRemaining != null && saveTime != null) {
      final elapsed = (DateTime.now().millisecondsSinceEpoch - saveTime) ~/ 1000;
      _remainingSeconds = (savedRemaining - elapsed).clamp(0, totalTimeSeconds);
    }
    for (int i = 0; i < _allQuestions.length; i++) {
      final answer = prefs.getString('answer_$i');
      if (answer != null) {
        _userAnswers[i] = answer;
        _isCorrectList[i] = answer == _allQuestions[i].correctAnswer;
        _checkAchievements(i, _isCorrectList[i]);
      }
      _isFlagged[i] = prefs.getBool('flagged_$i') ?? false;
      _isBookmarked[i] = prefs.getBool('bookmarked_$i') ?? false;
      _isMarkedForReview[i] = prefs.getBool('review_$i') ?? false;
      _questionNotes[i] = prefs.getString('note_$i') ?? '';
    }
  }
  
  Future<void> _saveAnswerState(int index) async {
    final prefs = await SharedPreferences.getInstance();
    if (index >= 0) {
      await prefs.setString('answer_$index', _userAnswers[index] ?? '');
      await prefs.setBool('flagged_$index', _isFlagged[index]);
      await prefs.setBool('bookmarked_$index', _isBookmarked[index]);
      await prefs.setBool('review_$index', _isMarkedForReview[index]);
      await prefs.setString('note_$index', _questionNotes[index]);
    }
  }
  
  // ============================================================
  // FEATURE 12: ACHIEVEMENT SYSTEM
  // ============================================================
  void _checkAchievements(int questionIndex, bool isCorrect) {
    if (isCorrect) {
      _answerStreak++;
      if (_answerStreak > _bestStreak) _bestStreak = _answerStreak;
      
      if (_bestStreak >= 5) _unlockAchievement('Streak Master: 5 correct answers in a row! 🎯');
      if (_bestStreak >= 10) _unlockAchievement('Legendary Streak: 10 correct answers! 🔥');
      
      if (_questionTimes[questionIndex] <= 5) {
        _quickAnswers++;
        if (_quickAnswers >= 3) _unlockAchievement('Speed Demon: 3 answers under 5 seconds! ⚡');
      }
    } else {
      _answerStreak = 0;
    }
    
    final topic = _allQuestions[questionIndex].topic;
    _topicPerformance[topic] = (_topicPerformance[topic] ?? 0) + (isCorrect ? 1 : 0);
    
    final difficulty = _allQuestions[questionIndex].difficulty;
    _difficultyPerformance[difficulty] = (_difficultyPerformance[difficulty] ?? 0) + (isCorrect ? 1 : 0);
    
    if (_attemptedCount == _allQuestions.length) _unlockAchievement('Quiz Completed: Finished all questions! 🏆');
    if (_liveAccuracy >= 90 && _attemptedCount >= 10) _unlockAchievement('Excellence Award: 90%+ accuracy! 🌟');
  }
  
  void _unlockAchievement(String achievement) {
    if (!_unlockedAchievements.contains(achievement)) {
      _unlockedAchievements.add(achievement);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🏆 Achievement Unlocked: $achievement'), backgroundColor: AppTheme.successGreen, duration: const Duration(seconds: 2)));
    }
  }
  
  void _autoSubmitOnTimerEnd() {
    if (!_isQuizActive) return;
    setState(() { _isQuizActive = false; _globalTimer?.cancel(); });
    _showSubmitPreviewDialog(isTimeout: true);
  }
  
  void _selectAnswer(String answer) {
    if (_isAnswered) return;
    final actualIndex = _getActualQuestionIndex(_currentIndex);
    final isCorrect = answer == _allQuestions[actualIndex].correctAnswer;
    final timeSpent = (DateTime.now().millisecondsSinceEpoch - _questionStartTime) ~/ 1000;
    _questionTimes[actualIndex] = timeSpent;
    _answerTimestamps.add(DateTime.now());
    
    setState(() {
      _isAnswered = true;
      _selectedAnswer = answer;
      _userAnswers[actualIndex] = answer;
      _isCorrectList[actualIndex] = isCorrect;
      _isSkippedList[actualIndex] = false;
      
      if (isCorrect) _answerStreak++;
      else _answerStreak = 0;
    });
    
    _checkAchievements(actualIndex, isCorrect);
    _saveAnswerState(actualIndex);
    
    Future.delayed(const Duration(milliseconds: 1000), () { if (mounted) _goToNextQuestion(); });
  }
  
  void _goToNextQuestion() {
    if (_currentIndex + 1 < _allQuestions.length) _loadQuestion(_currentIndex + 1);
  }
  
  void _goToPreviousQuestion() {
    if (_currentIndex > 0) _loadQuestion(_currentIndex - 1);
  }
  
  void _jumpToQuestion(int index) => _loadQuestion(index);
  
  void _loadQuestion(int index) {
    final actualIndex = _getActualQuestionIndex(index);
    final alreadyAnswered = _userAnswers[actualIndex] != null;
    setState(() {
      _currentIndex = index;
      _isAnswered = alreadyAnswered;
      _selectedAnswer = _userAnswers[actualIndex];
    });
    _questionStartTime = DateTime.now().millisecondsSinceEpoch;
  }
  
  void _toggleFlag(int index) {
    final actualIndex = _getActualQuestionIndex(index);
    setState(() => _isFlagged[actualIndex] = !_isFlagged[actualIndex]);
    _saveAnswerState(actualIndex);
  }
  
  void _toggleBookmark(int index) {
    final actualIndex = _getActualQuestionIndex(index);
    setState(() => _isBookmarked[actualIndex] = !_isBookmarked[actualIndex]);
    _saveAnswerState(actualIndex);
    if (_isBookmarked[actualIndex]) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📖 Question bookmarked!'), duration: Duration(milliseconds: 800)));
  }
  
  void _toggleMarkForReview(int index) {
    final actualIndex = _getActualQuestionIndex(index);
    setState(() => _isMarkedForReview[actualIndex] = !_isMarkedForReview[actualIndex]);
    _saveAnswerState(actualIndex);
    if (_isMarkedForReview[actualIndex]) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔍 Marked for review!'), duration: Duration(milliseconds: 800)));
  }
  
  void _toggleEliminateOption(int optionIndex) {
    if (_isAnswered) return;
    final actualIndex = _getActualQuestionIndex(_currentIndex);
    setState(() {
      if (_eliminatedOptions[actualIndex].contains(optionIndex)) _eliminatedOptions[actualIndex].remove(optionIndex);
      else _eliminatedOptions[actualIndex].add(optionIndex);
    });
  }
  
  void _showQuestionNoteDialog() {
    final actualIndex = _getActualQuestionIndex(_currentIndex);
    final controller = TextEditingController(text: _questionNotes[actualIndex]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Note', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(hintText: 'Write your note here...', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { setState(() => _questionNotes[actualIndex] = controller.text); _saveAnswerState(actualIndex); Navigator.pop(ctx); }, child: const Text('Save')),
        ],
      ),
    );
  }
  
  void _toggleRandomizeQuestions() {
    setState(() {
      _randomizeQuestions = !_randomizeQuestions;
      _initializeRandomization();
      _currentIndex = 0;
      _loadQuestion(0);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_randomizeQuestions ? 'Questions randomized!' : 'Original order restored'), duration: const Duration(milliseconds: 800)));
  }
  
  void _toggleRandomizeOptions() {
    setState(() {
      _randomizeOptions = !_randomizeOptions;
      _initializeRandomization();
      _loadQuestion(_currentIndex);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_randomizeOptions ? 'Options randomized!' : 'Original options restored'), duration: const Duration(milliseconds: 800)));
  }
  
  void _showStatisticsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Performance Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Container(
          width: double.maxFinite,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📊 Topic-wise Performance:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._topicPerformance.entries.map((e) => Text('• ${e.key}: ${e.value} correct')),
            const SizedBox(height: 12),
            const Text('⭐ Difficulty Analysis:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._difficultyPerformance.entries.map((e) => Text('• ${e.key}: ${e.value} correct')),
            const SizedBox(height: 12),
            const Text('🏆 Achievements Unlocked:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._unlockedAchievements.map((a) => Text('• $a')),
            const SizedBox(height: 12),
            Text('🎯 Best Streak: $_bestStreak'),
            Text('⚡ Quick Answers: $_quickAnswers'),
            Text('📈 Overall Accuracy: ${_liveAccuracy.toStringAsFixed(1)}%'),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }
  
  void _toggleFocusMode() {
    setState(() => _focusMode = !_focusMode);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_focusMode ? 'Focus Mode ON - Distraction free!' : 'Focus Mode OFF'), duration: const Duration(milliseconds: 800)));
  }
  
  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
    if (_isFullScreen) SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    else SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  
  int get _attemptedCount => _userAnswers.where((a) => a != null).length;
  int get _correctCount => _isCorrectList.where((c) => c).length;
  int get _skippedCount => _isSkippedList.where((s) => s).length;
  int get _leftCount => _allQuestions.length - _attemptedCount - _skippedCount;
  bool get _canSubmit => _attemptedCount >= 5;
  double get _liveAccuracy => _attemptedCount == 0 ? 0 : (_correctCount / _attemptedCount) * 100;
  String get _formattedTimeRemaining => '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}';
  double get _timerProgress => _remainingSeconds / totalTimeSeconds;
  Color get _timerColor => _remainingSeconds <= warningTime3 ? AppTheme.dangerRed : (_remainingSeconds <= warningTime2 ? AppTheme.warningOrange : AppTheme.successGreen);
  
  void _restartQuiz() {
    _globalTimer?.cancel();
    setState(() {
      _remainingSeconds = totalTimeSeconds;
      _currentIndex = 0;
      _isAnswered = false;
      _selectedAnswer = null;
      _answerStreak = 0;
      _answerTimestamps.clear();
      for (int i = 0; i < _allQuestions.length; i++) {
        _userAnswers[i] = null;
        _isCorrectList[i] = false;
        _isFlagged[i] = false;
        _isBookmarked[i] = false;
        _isMarkedForReview[i] = false;
        _isSkippedList[i] = false;
        _questionNotes[i] = '';
        _eliminatedOptions[i].clear();
        _questionTimes[i] = 0;
      }
      _topicPerformance.clear();
      _difficultyPerformance.clear();
      _unlockedAchievements.clear();
      _quickAnswers = 0;
    });
    _timerAnimationController.reset();
    _timerAnimationController.forward();
    _startGlobalTimer();
    _questionStartTime = DateTime.now().millisecondsSinceEpoch;
  }
  
  void _showSubmitPreviewDialog({bool isTimeout = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(isTimeout ? Icons.timer_off_rounded : Icons.assignment_turned_in_rounded, color: isTimeout ? AppTheme.dangerRed : AppTheme.successGreen, size: 24),
          const SizedBox(width: 8),
          Text(isTimeout ? 'Time\'s Up!' : 'Submit Test?', style: const TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.w900)),
        ]),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _PreviewStatRow(label: 'Answered', value: '$_attemptedCount / ${_allQuestions.length}', color: AppTheme.primaryBlue),
            const SizedBox(height: 6),
            _PreviewStatRow(label: 'Correct', value: '$_correctCount', color: AppTheme.successGreen),
            const SizedBox(height: 6),
            _PreviewStatRow(label: 'Skipped', value: '$_skippedCount', color: Colors.orange),
            const SizedBox(height: 6),
            _PreviewStatRow(label: 'Accuracy', value: '${_liveAccuracy.toStringAsFixed(1)}%', color: AppTheme.accentYellow),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Performance Summary:', style: TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('🏆 Best Streak: $_bestStreak', style: const TextStyle(fontSize: 12)),
            Text('⚡ Quick Answers: $_quickAnswers', style: const TextStyle(fontSize: 12)),
            Text('📚 Achievements: ${_unlockedAchievements.length}', style: const TextStyle(fontSize: 12)),
          ]),
        ),
        actions: [
          if (!isTimeout) TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continue Test', style: TextStyle(color: AppTheme.textLight))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _globalTimer?.cancel();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultScreen(
                studentName: widget.studentName,
                questions: _allQuestions,
                userAnswers: _userAnswers,
                isCorrectList: _isCorrectList,
                isSkippedList: _isSkippedList,
                questionTimes: _questionTimes,
                bestStreak: _bestStreak,
                achievements: _unlockedAchievements.toList(),
                onRestart: _restartQuiz,
              )));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _showExitWarning() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Test?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Your progress will be saved. You can resume later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { _saveAnswerState(-1); Navigator.pop(ctx); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Exit', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) { _isPaused = true; _saveTimerState(); }
    else if (state == AppLifecycleState.resumed) _isPaused = false;
  }
  
  @override
  void dispose() {
    _globalTimer?.cancel();
    _timerAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: _isDarkMode ? Colors.grey[900] : AppTheme.bgLight,
        appBar: _isFullScreen ? null : _buildAppBar(),
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) {
            if (_shortcuts.containsKey(event.logicalKey)) _shortcuts[event.logicalKey]!();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 900;
              final isMediumScreen = constraints.maxWidth > 600 && constraints.maxWidth <= 900;
              final navigatorColumns = isLargeScreen ? 5 : (isMediumScreen ? 4 : 3);
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: isLargeScreen ? 3 : 2, child: _buildQuestionArea()),
                  if (!_focusMode && isLargeScreen) Container(width: 300, margin: const EdgeInsets.fromLTRB(0, 12, 12, 12), child: _buildNavigatorPanel(columns: navigatorColumns)),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: _focusMode ? null : (MediaQuery.of(context).size.width <= 600 ? _buildMobileBottomBar() : null),
        floatingActionButton: _focusMode ? null : _buildFloatingActionMenu(),
      ),
    );
  }
  
  Widget _buildFloatingActionMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'stats',
          onPressed: _showStatisticsDialog,
          backgroundColor: AppTheme.purpleAccent,
          child: const Icon(Icons.assessment, color: Colors.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'focus',
          onPressed: _toggleFocusMode,
          backgroundColor: _focusMode ? AppTheme.successGreen : AppTheme.warningOrange,
          child: Icon(_focusMode ? Icons.center_focus_strong : Icons.center_focus_weak, color: Colors.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'fullscreen',
          onPressed: _toggleFullScreen,
          backgroundColor: _isFullScreen ? AppTheme.successGreen : AppTheme.primaryBlue,
          child: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white),
        ),
      ],
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('BS-CIT Assessment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
        Text('${widget.studentName} · Q${_currentIndex + 1}/${_allQuestions.length}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ]),
      backgroundColor: AppTheme.primaryBlue,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white), onPressed: _showExitWarning),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.timer_rounded, color: _timerColor, size: 16), const SizedBox(width: 4), Text(_formattedTimeRemaining, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800))]),
        ),
        IconButton(icon: const Icon(Icons.brightness_6_rounded, color: Colors.white), onPressed: () => setState(() => _isDarkMode = !_isDarkMode)),
        IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _restartQuiz),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(5),
        child: LinearProgressIndicator(value: _timerProgress, backgroundColor: Colors.grey.shade300, color: _timerColor, minHeight: 5),
      ),
    );
  }
  
  Widget _buildQuestionArea() {
    final actualIndex = _getActualQuestionIndex(_currentIndex);
    final question = _allQuestions[actualIndex];
    final shuffledOptions = _getShuffledOptions(actualIndex);
    final eliminatedSet = _eliminatedOptions[actualIndex];
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(question.subject, style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.w800))),
              const Spacer(),
              _buildActionButton(Icons.flag_outlined, _isFlagged[actualIndex], () => _toggleFlag(_currentIndex), AppTheme.accentYellow, 'Flag'),
              const SizedBox(width: 4),
              _buildActionButton(Icons.bookmark_border, _isBookmarked[actualIndex], () => _toggleBookmark(_currentIndex), AppTheme.successGreen, 'Bookmark'),
              const SizedBox(width: 4),
              _buildActionButton(Icons.preview, _isMarkedForReview[actualIndex], () => _toggleMarkForReview(_currentIndex), AppTheme.warningOrange, 'Review'),
              const SizedBox(width: 4),
              _buildActionButton(Icons.note_add, false, _showQuestionNoteDialog, AppTheme.primaryBlue, 'Note'),
              const SizedBox(width: 8),
              Text('Q${_currentIndex + 1}', style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.accentYellow.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(question.difficulty, style: TextStyle(color: AppTheme.accentYellow, fontSize: 10, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.purpleAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(question.topic, style: TextStyle(color: AppTheme.purpleAccent, fontSize: 10, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.tealAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text('${question.points} pts', style: TextStyle(color: AppTheme.tealAccent, fontSize: 10, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 12),
            Text(question.text, style: const TextStyle(color: AppTheme.textDark, fontSize: 17, fontWeight: FontWeight.w800, height: 1.3)),
            if (_isSkippedList[actualIndex]) _buildSkippedIndicator(),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Select your answer', style: TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...shuffledOptions.asMap().entries.map((entry) {
          final idx = entry.key;
          final option = entry.value;
          if (eliminatedSet.contains(idx)) return const SizedBox.shrink();
          final isSelected = _selectedAnswer == option;
          final isCorrect = _isAnswered && option == question.correctAnswer;
          final isWrong = _isAnswered && isSelected && option != question.correctAnswer;
          final shouldShowCorrect = _isAnswered && _selectedAnswer == null && option == question.correctAnswer;
          return GestureDetector(
            onTap: _isAnswered ? null : () => _selectAnswer(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: shouldShowCorrect ? AppTheme.successGreen.withOpacity(0.15) : isCorrect ? AppTheme.successGreen.withOpacity(0.1) : isWrong ? Colors.red.withOpacity(0.1) : isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : _isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: shouldShowCorrect ? AppTheme.successGreen : isCorrect ? AppTheme.successGreen : isWrong ? Colors.red : isSelected ? AppTheme.primaryBlue : Colors.grey.shade300, width: (isSelected || isCorrect || shouldShowCorrect || isWrong) ? 2 : 1),
              ),
              child: Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: shouldShowCorrect ? AppTheme.successGreen : isCorrect ? AppTheme.successGreen : isWrong ? Colors.red : isSelected ? AppTheme.primaryBlue : Colors.grey.shade300),
                  child: Center(child: Text(String.fromCharCode(65 + idx), style: TextStyle(color: (isSelected || isCorrect || shouldShowCorrect || isWrong) ? Colors.white : Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w800))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(option, style: TextStyle(color: shouldShowCorrect ? AppTheme.successGreen : isCorrect ? AppTheme.successGreen : isWrong ? Colors.red.shade800 : isSelected ? AppTheme.primaryBlue : AppTheme.textDark, fontSize: 14, fontWeight: (isSelected || shouldShowCorrect) ? FontWeight.w700 : FontWeight.w500))),
                if (isCorrect || shouldShowCorrect) const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 20),
                if (isWrong) const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
                if (!_isAnswered)
                  GestureDetector(
                    onTap: () => _toggleEliminateOption(idx),
                    child: Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Icon(Icons.remove_circle_outline, color: Colors.grey, size: 18)),
                  ),
              ]),
            ),
          );
        }),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: _currentIndex > 0 ? _goToPreviousQuestion : null, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primaryBlue), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 13)), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.arrow_back_rounded, size: 17), SizedBox(width: 6), Text('Previous')]))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: _currentIndex + 1 < _allQuestions.length ? _goToNextQuestion : null, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 13)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_currentIndex + 1 < _allQuestions.length ? 'Next' : 'Review'), const SizedBox(width: 6), Icon(_currentIndex + 1 < _allQuestions.length ? Icons.arrow_forward_rounded : Icons.assignment_rounded, size: 17)]))),
        ]),
      ]),
    );
  }
  
  Widget _buildActionButton(IconData icon, bool isActive, VoidCallback onTap, Color activeColor, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: isActive ? activeColor.withOpacity(0.15) : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: isActive ? activeColor : Colors.grey, size: 16)),
      ),
    );
  }
  
  Widget _buildSkippedIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.skip_next_rounded, color: Colors.orange, size: 14), SizedBox(width: 6), Text('Skipped - correct answer highlighted below', style: TextStyle(color: Colors.orange, fontSize: 11))]),
      ),
    );
  }
  
  Widget _buildNavigatorPanel({required int columns}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _isDarkMode ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Question Navigator', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        SizedBox(
          height: 320,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 1),
            itemCount: _allQuestions.length,
            itemBuilder: (_, idx) {
              final actualIdx = _getActualQuestionIndex(idx);
              Color bgColor;
              if (idx == _currentIndex) bgColor = AppTheme.primaryBlue;
              else if (_isFlagged[actualIdx]) bgColor = AppTheme.accentYellow;
              else if (_isSkippedList[actualIdx]) bgColor = Colors.orange;
              else if (_isBookmarked[actualIdx]) bgColor = AppTheme.successGreen;
              else if (_isMarkedForReview[actualIdx]) bgColor = AppTheme.warningOrange;
              else if (_userAnswers[actualIdx] != null) bgColor = AppTheme.successGreen.withOpacity(0.7);
              else bgColor = Colors.grey.shade400;
              return Tooltip(
                message: _userAnswers[actualIdx] != null ? 'Answered: ${_userAnswers[actualIdx]}' : 'Not attempted',
                child: GestureDetector(
                  onTap: () => _jumpToQuestion(idx),
                  child: Container(
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 4, children: [
          _LegendDot(color: AppTheme.primaryBlue, label: 'Current'),
          _LegendDot(color: AppTheme.successGreen, label: 'Answered'),
          _LegendDot(color: Colors.orange, label: 'Skipped'),
          _LegendDot(color: AppTheme.accentYellow, label: 'Flagged'),
          _LegendDot(color: AppTheme.successGreen, label: 'Bookmarked'),
          _LegendDot(color: AppTheme.warningOrange, label: 'Review'),
          _LegendDot(color: Colors.grey.shade400, label: 'Pending'),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Progress:', style: TextStyle(fontSize: 11)),
          Text('$_attemptedCount/${_allQuestions.length}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _attemptedCount / _allQuestions.length, backgroundColor: Colors.grey.shade300, color: AppTheme.successGreen, minHeight: 4),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: ElevatedButton.icon(onPressed: _toggleRandomizeQuestions, icon: Icon(Icons.shuffle, size: 16, color: _randomizeQuestions ? AppTheme.primaryBlue : Colors.white), label: Text('Shuffle Q', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: _randomizeQuestions ? Colors.white : AppTheme.primaryBlue, foregroundColor: _randomizeQuestions ? AppTheme.primaryBlue : Colors.white, padding: const EdgeInsets.symmetric(vertical: 8)))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(onPressed: _toggleRandomizeOptions, icon: Icon(Icons.shuffle_on, size: 16, color: _randomizeOptions ? AppTheme.primaryBlue : Colors.white), label: Text('Shuffle O', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: _randomizeOptions ? Colors.white : AppTheme.primaryBlue, foregroundColor: _randomizeOptions ? AppTheme.primaryBlue : Colors.white, padding: const EdgeInsets.symmetric(vertical: 8)))),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _canSubmit ? () => _showSubmitPreviewDialog() : null, style: ElevatedButton.styleFrom(backgroundColor: _canSubmit ? AppTheme.successGreen : Colors.grey.shade400, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Submit Test', style: TextStyle(fontWeight: FontWeight.w800)))),
      ]),
    );
  }
  
  Widget _buildMobileBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(color: _isDarkMode ? Colors.grey[800] : Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, -2))]),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [const Text('Done', style: TextStyle(fontSize: 10)), Text('$_attemptedCount/${_allQuestions.length}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue))])),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [const Text('Time', style: TextStyle(fontSize: 10)), Text(_formattedTimeRemaining, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _timerColor))])),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _allQuestions.length,
              itemBuilder: (_, idx) {
                final actualIdx = _getActualQuestionIndex(idx);
                Color bgColor;
                if (idx == _currentIndex) bgColor = AppTheme.primaryBlue;
                else if (_isFlagged[actualIdx]) bgColor = AppTheme.accentYellow;
                else if (_isSkippedList[actualIdx]) bgColor = Colors.orange;
                else if (_userAnswers[actualIdx] != null) bgColor = AppTheme.successGreen;
                else bgColor = Colors.grey.shade400;
                return GestureDetector(
                  onTap: () => _jumpToQuestion(idx),
                  child: Container(width: 32, margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)), child: Center(child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)))),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: _canSubmit ? () => _showSubmitPreviewDialog() : null, style: ElevatedButton.styleFrom(backgroundColor: _canSubmit ? AppTheme.successGreen : Colors.grey, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Submit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
      ]),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 10))]);
  }
}

class _PreviewStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PreviewStatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)), Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800))]);
  }
}

// ============================================================
// ENHANCED RESULT SCREEN with Advanced Analytics
// ============================================================
class ResultScreen extends StatefulWidget {
  final String studentName;
  final List<Question> questions;
  final List<String?> userAnswers;
  final List<bool> isCorrectList;
  final List<bool> isSkippedList;
  final List<int> questionTimes;
  final int bestStreak;
  final List<String> achievements;
  final VoidCallback onRestart;

  const ResultScreen({super.key, required this.studentName, required this.questions, required this.userAnswers, required this.isCorrectList, required this.isSkippedList, required this.questionTimes, required this.bestStreak, required this.achievements, required this.onRestart});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  bool _showReview = false;
  String _selectedFilter = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int get _correctCount => widget.isCorrectList.where((c) => c).length;
  int get _wrongCount => widget.userAnswers.asMap().entries.where((e) => e.value != null && !widget.isCorrectList[e.key]).length;
  int get _skippedCount => widget.isSkippedList.where((s) => s).length;
  double get _percentage => (_correctCount / widget.questions.length) * 100;
  double get _averageTime => widget.questionTimes.where((t) => t > 0).isEmpty ? 0 : widget.questionTimes.where((t) => t > 0).reduce((a, b) => a + b) / widget.questionTimes.where((t) => t > 0).length;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  List<int> get _filteredIndices {
    return List.generate(widget.questions.length, (i) => i).where((i) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Correct') return widget.isCorrectList[i];
      if (_selectedFilter == 'Wrong') return widget.userAnswers[i] != null && !widget.isCorrectList[i];
      if (_selectedFilter == 'Skipped') return widget.isSkippedList[i];
      return true;
    }).toList();
  }

  String get _grade {
    if (_percentage >= 90) return 'A+';
    if (_percentage >= 80) return 'A';
    if (_percentage >= 70) return 'B+';
    if (_percentage >= 60) return 'B';
    if (_percentage >= 50) return 'C';
    return 'F';
  }

  String get _performanceMessage {
    if (_percentage >= 80) return 'Excellent! You\'re a Computer Expert! 🏆';
    if (_percentage >= 60) return 'Good Job! Solid understanding! 👍';
    if (_percentage >= 40) return 'Fair effort! Room for improvement! 📚';
    return 'Needs Improvement — Keep Practising! ⚠';
  }

  Color get _performanceColor {
    if (_percentage >= 80) return AppTheme.successGreen;
    if (_percentage >= 60) return AppTheme.primaryBlue;
    if (_percentage >= 40) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(_showReview ? 'Answer Review' : 'Test Results', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        leading: IconButton(icon: Icon(_showReview ? Icons.arrow_back_rounded : Icons.home_rounded, color: Colors.white), onPressed: () => _showReview ? setState(() => _showReview = false) : Navigator.popUntil(context, (route) => route.isFirst)),
        actions: [!_showReview ? TextButton.icon(onPressed: widget.onRestart, icon: const Icon(Icons.refresh_rounded, color: Colors.white), label: const Text('Restart', style: TextStyle(color: Colors.white))) : null].whereType<Widget>().toList(),
      ),
      body: _showReview ? _buildReviewScreen() : _buildResultScreen(),
    );
  }

  Widget _buildResultScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) => Transform.scale(scale: value, child: child),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.darkBlue, AppTheme.primaryBlue]), borderRadius: BorderRadius.circular(24)),
              child: Column(children: [
                Text(_percentage >= 80 ? '🏆' : _percentage >= 60 ? '👍' : '📚', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('Hello, ${widget.studentName}!', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text('Grade: $_grade', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
                const SizedBox(height: 8),
                Text(_performanceMessage, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13), textAlign: TextAlign.center),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _StatCard(value: '$_correctCount', label: 'Correct', color: AppTheme.successGreen, icon: Icons.check_circle_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(value: '$_wrongCount', label: 'Wrong', color: Colors.red, icon: Icons.cancel_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(value: '$_skippedCount', label: 'Skipped', color: Colors.orange, icon: Icons.skip_next_rounded)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _StatCard(value: '${_averageTime.toStringAsFixed(0)}s', label: 'Avg Time', color: AppTheme.primaryBlue, icon: Icons.speed_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(value: '${widget.bestStreak}', label: 'Best Streak', color: AppTheme.accentYellow, icon: Icons.local_fire_department_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(value: '$_grade', label: 'Grade', color: AppTheme.purpleAccent, icon: Icons.grade_rounded)),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))]),
            child: Column(children: [
              const Text('Final Score', style: TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('$_correctCount / ${widget.questions.length}', style: TextStyle(color: _performanceColor, fontSize: 48, fontWeight: FontWeight.w900)),
              Text('${_percentage.toStringAsFixed(1)}%', style: const TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _percentage / 100, backgroundColor: Colors.grey.shade200, color: _performanceColor, minHeight: 10)),
            ]),
          ),
          if (widget.achievements.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🏆 Achievements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 4, children: widget.achievements.map((a) => Chip(label: Text(a, style: const TextStyle(fontSize: 11)), backgroundColor: AppTheme.accentYellow.withOpacity(0.2))).toList()),
              ]),
            ),
          ],
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() => _showReview = true), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primaryBlue), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Review Answers', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700)))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: widget.onRestart, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.refresh_rounded, color: Colors.white, size: 18), SizedBox(width: 6), Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]))),
          ]),
        ]),
      ),
    );
  }

  Widget _buildReviewScreen() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'All', label: Text('All')), ButtonSegment(value: 'Correct', label: Text('Correct')), ButtonSegment(value: 'Wrong', label: Text('Wrong')), ButtonSegment(value: 'Skipped', label: Text('Skipped'))],
            selected: {_selectedFilter},
            onSelectionChanged: (set) => setState(() => _selectedFilter = set.first),
          )),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredIndices.length,
          itemBuilder: (ctx, idx) {
            final i = _filteredIndices[idx];
            final q = widget.questions[i];
            final userAnswer = widget.userAnswers[i];
            final isCorrect = widget.isCorrectList[i];
            final isSkipped = widget.isSkippedList[i];
            final isWrong = userAnswer != null && !isCorrect;
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (idx * 50)),
              builder: (context, value, child) {
  return Transform.translate(
    offset: Offset(0, 50 * (1 - value)),
    child: Opacity(
      opacity: value,
      child: child,
    ),
  );
},
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: isCorrect ? AppTheme.successGreen.withOpacity(0.1) : isSkipped ? Colors.orange.withOpacity(0.1) : isWrong ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                    child: Row(children: [
                      Container(width: 28, height: 28, decoration: BoxDecoration(color: isCorrect ? AppTheme.successGreen : isSkipped ? Colors.orange : isWrong ? Colors.red : Colors.grey, borderRadius: BorderRadius.circular(8)), child: Center(child: Icon(isCorrect ? Icons.check_rounded : isSkipped ? Icons.skip_next_rounded : Icons.close_rounded, color: Colors.white, size: 16))),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Question ${i + 1} - ${q.topic}', style: TextStyle(color: isCorrect ? AppTheme.successGreen : isSkipped ? Colors.orange : isWrong ? Colors.red.shade800 : Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w800))),
                      Text('${widget.questionTimes[i]}s', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(q.text, style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      if (isSkipped) _ReviewAnswer(label: 'Status', answer: 'Skipped (Time Expired)', isCorrect: false, isSkipped: true),
                      if (!isSkipped && userAnswer != null) _ReviewAnswer(label: 'Your answer', answer: userAnswer, isCorrect: isCorrect, isSkipped: false),
                      if (!isCorrect && !isSkipped) const SizedBox(height: 6),
                      if (!isCorrect) _ReviewAnswer(label: 'Correct answer', answer: q.correctAnswer, isCorrect: true, isSkipped: false, forceGreen: true),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _ReviewAnswer extends StatelessWidget {
  final String label;
  final String answer;
  final bool isCorrect;
  final bool isSkipped;
  final bool forceGreen;
  const _ReviewAnswer({required this.label, required this.answer, required this.isCorrect, this.isSkipped = false, this.forceGreen = false});

  @override
  Widget build(BuildContext context) {
    final color = (isCorrect || forceGreen) ? AppTheme.successGreen : isSkipped ? Colors.orange : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color, width: 1)),
      child: Row(children: [
        Icon((isCorrect || forceGreen) ? Icons.check_circle_rounded : isSkipped ? Icons.skip_next_rounded : Icons.cancel_rounded, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text('$label: $answer', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _StatCard({required this.value, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3), width: 1)),
      child: Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 6), Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 11, fontWeight: FontWeight.w600))]),
    );
  }
}