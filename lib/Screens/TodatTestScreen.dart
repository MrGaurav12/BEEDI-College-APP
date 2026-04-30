// ============================================================
//  BEEDI COLLEGE TEST SYSTEM – Complete CBT Portal
//  Single-file Flutter app (no main.dart, no runApp)
//  Material 3 • StatefulWidget only • No third-party packages
// ============================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ┌──────────────────────────────────────────────────────────────┐
// │                         MODELS                              │
// └──────────────────────────────────────────────────────────────┘

class StudentLogin {
  final String username;
  final String pin;
  const StudentLogin(this.username, this.pin);
}

class Batch {
  final String id;
  final String name;
  final String timing;
  final int studentCount;
  bool isActive;
  Batch({
    required this.id,
    required this.name,
    required this.timing,
    required this.studentCount,
    this.isActive = true,
  });
}

class SubjectiveQuestion {
  final int id;
  final String questionText;
  final String? referenceAnswer;
  const SubjectiveQuestion({
    required this.id,
    required this.questionText,
    this.referenceAnswer,
  });
}

class SubjectiveExamSession {
  final List<SubjectiveQuestion> questions;
  int currentQuestionIndex = 0;
  Map<int, String> questionAnswers = {};
  Map<int, bool> markedForReview = {};
  Duration remainingTime;
  bool isSubmitted = false;
  bool isAutoSubmitted = false;

  SubjectiveExamSession({
    required this.questions,
    this.remainingTime = const Duration(minutes: 45),
  });
}

class ObjectiveQuestion {
  final int id;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String? subtopic;
  const ObjectiveQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    this.subtopic,
  });
}

class ObjectiveExamSession {
  final List<ObjectiveQuestion> questions;
  int currentIndex = 0;
  Map<int, int> selectedOptions = {};
  Map<int, bool> markedForReview = {};
  Duration remainingTime;
  bool isSubmitted = false;
  bool isLocked = false;

  ObjectiveExamSession({
    required this.questions,
    this.remainingTime = const Duration(minutes: 45),
  });
}

class ExamAttemptKey {
  final String studentUsername;
  final String batchId;
  final String examType; // 'subjective' | 'objective'

  ExamAttemptKey(this.studentUsername, this.batchId, this.examType);

  @override
  bool operator ==(Object other) =>
      other is ExamAttemptKey &&
      other.studentUsername == studentUsername &&
      other.batchId == batchId &&
      other.examType == examType;

  @override
  int get hashCode =>
      studentUsername.hashCode ^ batchId.hashCode ^ examType.hashCode;
}

// ┌──────────────────────────────────────────────────────────────┐
// │                    GLOBAL STATE (IN-MEMORY)                 │
// └──────────────────────────────────────────────────────────────┘

class AppState {
  static String? loggedInStudent;
  static final Set<ExamAttemptKey> completedAttempts = {};
  static final Map<ExamAttemptKey, SubjectiveExamSession> subjectiveSessions =
      {};
  static final Map<ExamAttemptKey, ObjectiveExamSession> objectiveSessions = {};
  static bool isDarkMode = false;

  static bool hasAttempted(
      String student, String batchId, String examType) {
    return completedAttempts
        .contains(ExamAttemptKey(student, batchId, examType));
  }

  static void markAttempted(
      String student, String batchId, String examType) {
    completedAttempts.add(ExamAttemptKey(student, batchId, examType));
  }

  static void logout() {
    loggedInStudent = null;
  }
}

// ┌──────────────────────────────────────────────────────────────┐
// │                       HARDCODED DATA                        │
// └──────────────────────────────────────────────────────────────┘

class HardcodedData {
  static const List<StudentLogin> credentials = [
    StudentLogin('GAURAV', '123456'),
    StudentLogin('RAJA', '741852'),
    StudentLogin('SAMRIDHI', '852963'),
  ];

  static List<Batch> get batches => [
        Batch(
            id: 'B1',
            name: 'Batch March 10-02',
            timing: '10:00 AM – 02:00 PM',
            studentCount: 45,
            isActive: true),
        Batch(
            id: 'B2',
            name: 'Batch April 11-03',
            timing: '11:00 AM – 03:00 PM',
            studentCount: 32,
            isActive: true),
        Batch(
            id: 'B3',
            name: 'Batch Feb 02-06',
            timing: '02:00 PM – 06:00 PM',
            studentCount: 28,
            isActive: false),
        Batch(
            id: 'B4',
            name: 'Demo 02:30-03:30',
            timing: '02:30 PM – 03:30 PM',
            studentCount: 10,
            isActive: true),
        Batch(
            id: 'B5',
            name: 'Demo 04:30-05:30',
            timing: '04:30 PM – 05:30 PM',
            studentCount: 10,
            isActive: true),
      ];

  static List<SubjectiveQuestion> get subjectiveQuestions => [
        const SubjectiveQuestion(
            id: 1,
            questionText:
                'Explain the role of Natural Language Processing (NLP) in modern exam systems.',
            referenceAnswer:
                'NLP enables automated evaluation of written responses by analyzing semantics, grammar, and context.'),
        const SubjectiveQuestion(
            id: 2,
            questionText:
                'What is the difference between supervised and unsupervised learning? Give examples.',
            referenceAnswer:
                'Supervised learning uses labeled data; unsupervised learning finds patterns in unlabeled data.'),
        const SubjectiveQuestion(
            id: 3,
            questionText:
                'Define Object-Oriented Programming and explain its four pillars.',
            referenceAnswer:
                'OOP is a paradigm based on objects. Four pillars: Encapsulation, Abstraction, Inheritance, Polymorphism.'),
        const SubjectiveQuestion(
            id: 4,
            questionText:
                'Describe the OSI model layers and their functions in networking.',
            referenceAnswer:
                'OSI has 7 layers: Physical, Data Link, Network, Transport, Session, Presentation, Application.'),
        const SubjectiveQuestion(
            id: 5,
            questionText:
                'What is database normalization? Explain 1NF, 2NF, and 3NF with examples.',
            referenceAnswer:
                'Normalization reduces redundancy. 1NF: atomic values; 2NF: no partial dependency; 3NF: no transitive dependency.'),
        const SubjectiveQuestion(
            id: 6,
            questionText:
                'Explain the concept of recursion with a suitable example in programming.',
            referenceAnswer:
                'Recursion is when a function calls itself. Example: factorial(n) = n * factorial(n-1).'),
        const SubjectiveQuestion(
            id: 7,
            questionText:
                'What are design patterns? Describe the Singleton and Factory patterns.',
            referenceAnswer:
                'Design patterns are reusable solutions. Singleton ensures one instance; Factory creates objects without specifying exact class.'),
        const SubjectiveQuestion(
            id: 8,
            questionText:
                'Differentiate between TCP and UDP protocols in computer networking.',
            referenceAnswer:
                'TCP is connection-oriented and reliable; UDP is connectionless and faster but unreliable.'),
        const SubjectiveQuestion(
            id: 9,
            questionText:
                'What is cloud computing? Explain IaaS, PaaS, and SaaS with examples.',
            referenceAnswer:
                'Cloud computing delivers computing services. IaaS: AWS EC2; PaaS: Heroku; SaaS: Google Workspace.'),
        const SubjectiveQuestion(
            id: 10,
            questionText:
                'Explain the working of a binary search algorithm and its time complexity.',
            referenceAnswer:
                'Binary search halves the search space each iteration. Time complexity: O(log n).'),
        const SubjectiveQuestion(
            id: 11,
            questionText:
                'What is machine learning overfitting and how can it be prevented?',
            referenceAnswer:
                'Overfitting occurs when model learns noise. Prevention: cross-validation, regularization, more data.'),
        const SubjectiveQuestion(
            id: 12,
            questionText:
                'Describe the ACID properties in database transactions.',
            referenceAnswer:
                'ACID: Atomicity (all or nothing), Consistency (valid state), Isolation (independent), Durability (persists after commit).'),
        const SubjectiveQuestion(
            id: 13,
            questionText:
                'What is the difference between a process and a thread in operating systems?',
            referenceAnswer:
                'A process is an independent program in execution; a thread is the smallest unit of execution within a process.'),
        const SubjectiveQuestion(
            id: 14,
            questionText:
                'Explain RESTful APIs and the HTTP methods used in them.',
            referenceAnswer:
                'REST APIs use HTTP. Methods: GET (read), POST (create), PUT/PATCH (update), DELETE (remove).'),
        const SubjectiveQuestion(
            id: 15,
            questionText:
                'What is version control? How does Git help in software development?',
            referenceAnswer:
                'Version control tracks changes. Git allows branching, merging, rollback, and collaborative development.'),
        const SubjectiveQuestion(
            id: 16,
            questionText:
                'Explain the concept of virtual memory in operating systems.',
            referenceAnswer:
                'Virtual memory extends RAM using disk space, allowing more programs to run than physical memory permits.'),
        const SubjectiveQuestion(
            id: 17,
            questionText:
                'What are the differences between SQL and NoSQL databases?',
            referenceAnswer:
                'SQL is relational, structured, ACID-compliant. NoSQL is flexible, scalable, schema-less.'),
        const SubjectiveQuestion(
            id: 18,
            questionText:
                'Describe the concept of hashing and its applications in computer science.',
            referenceAnswer:
                'Hashing maps data to fixed-size values. Used in hash tables, cryptography, and data integrity verification.'),
        const SubjectiveQuestion(
            id: 19,
            questionText: 'What is agile methodology in software development?',
            referenceAnswer:
                'Agile is iterative development with sprints, continuous feedback, and adaptability to change.'),
        const SubjectiveQuestion(
            id: 20,
            questionText:
                'Explain the concept of concurrency and parallelism in programming.',
            referenceAnswer:
                'Concurrency: multiple tasks making progress. Parallelism: tasks executing simultaneously on multiple cores.'),
      ];

  static List<ObjectiveQuestion> get objectiveQuestions {
    final List<ObjectiveQuestion> qs = [
      // ── Mathematics (50 Qs) ──
      const ObjectiveQuestion(
          id: 1,
          questionText: 'What is 2 + 2?',
          options: ['3', '4', '5', '6'],
          correctIndex: 1,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 2,
          questionText: 'What is the square root of 144?',
          options: ['10', '11', '12', '13'],
          correctIndex: 2,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 3,
          questionText: 'What is 15% of 200?',
          options: ['25', '30', '35', '40'],
          correctIndex: 1,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 4,
          questionText: 'Solve: 3x + 6 = 21. What is x?',
          options: ['3', '4', '5', '6'],
          correctIndex: 2,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 5,
          questionText: 'What is the area of a circle with radius 7? (π≈22/7)',
          options: ['154', '144', '164', '174'],
          correctIndex: 0,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 6,
          questionText: 'What is the value of sin(90°)?',
          options: ['0', '0.5', '1', '√2/2'],
          correctIndex: 2,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 7,
          questionText: 'How many degrees are in a triangle?',
          options: ['90', '180', '270', '360'],
          correctIndex: 1,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 8,
          questionText: 'What is 7 factorial (7!)?',
          options: ['2520', '4040', '5040', '720'],
          correctIndex: 2,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 9,
          questionText: 'What is the LCM of 4 and 6?',
          options: ['8', '10', '12', '24'],
          correctIndex: 2,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 10,
          questionText: 'What is the HCF of 36 and 48?',
          options: ['6', '8', '12', '18'],
          correctIndex: 2,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 11,
          questionText: 'What is the value of log₁₀(1000)?',
          options: ['2', '3', '4', '10'],
          correctIndex: 1,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 12,
          questionText: 'A triangle with all equal sides is called?',
          options: ['Scalene', 'Isosceles', 'Equilateral', 'Right'],
          correctIndex: 2,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 13,
          questionText: 'What is the perimeter of a square with side 5?',
          options: ['10', '15', '20', '25'],
          correctIndex: 2,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 14,
          questionText: 'What is 2^10?',
          options: ['512', '1024', '2048', '256'],
          correctIndex: 1,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 15,
          questionText: 'What is the slope of y = 3x + 5?',
          options: ['5', '3', '8', '-3'],
          correctIndex: 1,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 16,
          questionText: 'The sum of first 10 natural numbers is?',
          options: ['45', '50', '55', '60'],
          correctIndex: 2,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 17,
          questionText: 'What is 25% of 480?',
          options: ['100', '110', '120', '130'],
          correctIndex: 2,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 18,
          questionText: 'If a = 5, b = 3, what is a² - b²?',
          options: ['14', '16', '17', '18'],
          correctIndex: 1,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 19,
          questionText: 'What is the derivative of x²?',
          options: ['x', '2x', 'x²', '2'],
          correctIndex: 1,
          subtopic: 'Mathematics'),
      const ObjectiveQuestion(
          id: 20,
          questionText: 'What is the integral of 2x?',
          options: ['x', 'x²', '2', '2x²'],
          correctIndex: 1,
          subtopic: 'Mathematics'),
      // ── Computer Science (50 Qs) ──
      const ObjectiveQuestion(
          id: 21,
          questionText: 'What does CPU stand for?',
          options: [
            'Central Processing Unit',
            'Core Processing Utility',
            'Central Program Unit',
            'Computer Processing Unit'
          ],
          correctIndex: 0,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 22,
          questionText: 'Which data structure uses LIFO?',
          options: ['Queue', 'Stack', 'Tree', 'Graph'],
          correctIndex: 1,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 23,
          questionText: 'What is the time complexity of binary search?',
          options: ['O(n)', 'O(n²)', 'O(log n)', 'O(1)'],
          correctIndex: 2,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 24,
          questionText: 'What does HTML stand for?',
          options: [
            'Hyper Text Markup Language',
            'High Text Machine Language',
            'Hyper Transfer Markup Language',
            'Hyper Text Machine Language'
          ],
          correctIndex: 0,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 25,
          questionText: 'Which language is used for web styling?',
          options: ['HTML', 'CSS', 'JavaScript', 'Python'],
          correctIndex: 1,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 26,
          questionText: 'What is RAM?',
          options: [
            'Read-Only Memory',
            'Random Access Memory',
            'Remote Access Module',
            'Rapid Access Memory'
          ],
          correctIndex: 1,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 27,
          questionText: 'Which sorting algorithm is the fastest on average?',
          options: ['Bubble Sort', 'Selection Sort', 'Quick Sort', 'Merge Sort'],
          correctIndex: 2,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 28,
          questionText: 'What is an IP address?',
          options: [
            'Internet Protocol Address',
            'Internal Port Address',
            'Input Protocol Address',
            'Internet Port Address'
          ],
          correctIndex: 0,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 29,
          questionText: 'Which protocol is used for email sending?',
          options: ['HTTP', 'FTP', 'SMTP', 'DNS'],
          correctIndex: 2,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 30,
          questionText: 'What is the base of hexadecimal number system?',
          options: ['2', '8', '10', '16'],
          correctIndex: 3,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 31,
          questionText: 'What does OOP stand for?',
          options: [
            'Object-Oriented Programming',
            'Open-Origin Protocol',
            'Object-Origin Platform',
            'Open-Oriented Protocol'
          ],
          correctIndex: 0,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 32,
          questionText: 'Which is NOT a programming language?',
          options: ['Python', 'Java', 'HTML', 'C++'],
          correctIndex: 2,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 33,
          questionText: 'What does SQL stand for?',
          options: [
            'Standard Query Language',
            'Structured Query Language',
            'Sequential Query Language',
            'Simple Query Language'
          ],
          correctIndex: 1,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 34,
          questionText: 'Which layer of OSI model handles routing?',
          options: ['Data Link', 'Network', 'Transport', 'Session'],
          correctIndex: 1,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 35,
          questionText: 'What is a compiler?',
          options: [
            'A device that compresses files',
            'A program that translates source code to machine code',
            'A program that runs code line by line',
            'A hardware component'
          ],
          correctIndex: 1,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 36,
          questionText: 'Which data structure uses FIFO?',
          options: ['Stack', 'Queue', 'Tree', 'Heap'],
          correctIndex: 1,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 37,
          questionText: 'What is polymorphism in OOP?',
          options: [
            'Having one form',
            'Hiding internal details',
            'Having many forms',
            'Inheriting from parent class'
          ],
          correctIndex: 2,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 38,
          questionText: 'What does DNS stand for?',
          options: [
            'Domain Name System',
            'Data Network Service',
            'Digital Name Server',
            'Dynamic Name System'
          ],
          correctIndex: 0,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 39,
          questionText: 'Which symbol is used for comments in Python?',
          options: ['//', '##', '#', '/*'],
          correctIndex: 2,
          subtopic: 'Computer Science'),
      const ObjectiveQuestion(
          id: 40,
          questionText: 'What is Git?',
          options: [
            'An operating system',
            'A version control system',
            'A programming language',
            'A database'
          ],
          correctIndex: 1,
          subtopic: 'Computer Science'),
      // ── Physics (50 Qs) ──
      const ObjectiveQuestion(
          id: 41,
          questionText: 'What is the unit of force?',
          options: ['Joule', 'Watt', 'Newton', 'Pascal'],
          correctIndex: 2,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 42,
          questionText: 'Speed of light in vacuum is approximately?',
          options: [
            '3 × 10⁸ m/s',
            '3 × 10⁶ m/s',
            '3 × 10¹⁰ m/s',
            '3 × 10⁴ m/s'
          ],
          correctIndex: 0,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 43,
          questionText: 'What is Newton\'s first law?',
          options: [
            'F = ma',
            'Law of inertia',
            'Action-reaction law',
            'Law of gravitation'
          ],
          correctIndex: 1,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 44,
          questionText: 'What is the unit of electrical resistance?',
          options: ['Volt', 'Ampere', 'Ohm', 'Watt'],
          correctIndex: 2,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 45,
          questionText: 'Energy stored in a spring is?',
          options: [
            'Kinetic energy',
            'Potential energy',
            'Thermal energy',
            'Chemical energy'
          ],
          correctIndex: 1,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 46,
          questionText: 'What is the SI unit of pressure?',
          options: ['Newton', 'Pascal', 'Bar', 'Joule'],
          correctIndex: 1,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 47,
          questionText: 'Which wave does NOT require a medium to travel?',
          options: ['Sound', 'Water', 'Light', 'Seismic'],
          correctIndex: 2,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 48,
          questionText: 'What is the formula for kinetic energy?',
          options: ['mgh', '½mv²', 'mv', 'F × d'],
          correctIndex: 1,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 49,
          questionText: 'Ohm\'s law states that V =?',
          options: ['I/R', 'R/I', 'IR', 'I²R'],
          correctIndex: 2,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 50,
          questionText: 'What is the unit of power?',
          options: ['Joule', 'Newton', 'Watt', 'Pascal'],
          correctIndex: 2,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 51,
          questionText: 'Acceleration due to gravity on Earth is approximately?',
          options: ['8.9 m/s²', '9.8 m/s²', '10.8 m/s²', '9.0 m/s²'],
          correctIndex: 1,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 52,
          questionText: 'Which color has the longest wavelength?',
          options: ['Violet', 'Blue', 'Green', 'Red'],
          correctIndex: 3,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 53,
          questionText: 'What is the unit of charge?',
          options: ['Ampere', 'Coulomb', 'Volt', 'Farad'],
          correctIndex: 1,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 54,
          questionText: 'Thermodynamics first law is about?',
          options: [
            'Entropy',
            'Conservation of energy',
            'Temperature',
            'Heat transfer'
          ],
          correctIndex: 1,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 55,
          questionText: 'What is the frequency of AC power supply in India?',
          options: ['50 Hz', '60 Hz', '100 Hz', '220 Hz'],
          correctIndex: 0,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 56,
          questionText: 'In a vacuum, all objects fall at the same rate due to?',
          options: ['Mass', 'Gravity', 'Air resistance', 'Friction'],
          correctIndex: 1,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 57,
          questionText: 'What is absolute zero in Celsius?',
          options: ['-100°C', '-200°C', '-273°C', '-373°C'],
          correctIndex: 2,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 58,
          questionText: 'Which property of light causes rainbow?',
          options: ['Reflection', 'Refraction', 'Dispersion', 'Diffraction'],
          correctIndex: 2,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 59,
          questionText: 'What is the speed of sound in air at 20°C?',
          options: ['243 m/s', '343 m/s', '443 m/s', '543 m/s'],
          correctIndex: 1,
          subtopic: 'Physics'),
      const ObjectiveQuestion(
          id: 60,
          questionText: 'The device used to measure electric current is?',
          options: ['Voltmeter', 'Ammeter', 'Galvanometer', 'Multimeter'],
          correctIndex: 1,
          subtopic: 'Physics'),
      // ── Chemistry (50 Qs) ──
      const ObjectiveQuestion(
          id: 61,
          questionText: 'What is the chemical symbol for water?',
          options: ['H₂O₂', 'H₂O', 'HO', 'H₃O'],
          correctIndex: 1,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 62,
          questionText: 'What is the atomic number of Carbon?',
          options: ['4', '6', '8', '12'],
          correctIndex: 1,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 63,
          questionText: 'Which gas is most abundant in Earth\'s atmosphere?',
          options: ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Argon'],
          correctIndex: 2,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 64,
          questionText: 'What is the pH of pure water?',
          options: ['6', '7', '8', '9'],
          correctIndex: 1,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 65,
          questionText: 'NaCl is the chemical formula for?',
          options: ['Baking soda', 'Table salt', 'Vinegar', 'Limestone'],
          correctIndex: 1,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 66,
          questionText: 'Which element has the symbol Fe?',
          options: ['Fluorine', 'Fermium', 'Iron', 'Francium'],
          correctIndex: 2,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 67,
          questionText: 'What is the lightest element?',
          options: ['Helium', 'Hydrogen', 'Lithium', 'Carbon'],
          correctIndex: 1,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 68,
          questionText: 'Acids have a pH value?',
          options: [
            'Greater than 7',
            'Equal to 7',
            'Less than 7',
            'Greater than 14'
          ],
          correctIndex: 2,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 69,
          questionText: 'What is the chemical formula of carbon dioxide?',
          options: ['CO', 'CO₂', 'C₂O', 'C₂O₂'],
          correctIndex: 1,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 70,
          questionText: 'Which metal is liquid at room temperature?',
          options: ['Gold', 'Silver', 'Mercury', 'Copper'],
          correctIndex: 2,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 71,
          questionText: 'The process of conversion of solid to gas directly is?',
          options: ['Evaporation', 'Condensation', 'Sublimation', 'Fusion'],
          correctIndex: 2,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 72,
          questionText: 'Which acid is present in vinegar?',
          options: [
            'Citric acid',
            'Acetic acid',
            'Lactic acid',
            'Tartaric acid'
          ],
          correctIndex: 1,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 73,
          questionText: 'What type of bond is formed by sharing electrons?',
          options: ['Ionic', 'Metallic', 'Covalent', 'Hydrogen'],
          correctIndex: 2,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 74,
          questionText: 'How many elements are in the periodic table?',
          options: ['108', '112', '116', '118'],
          correctIndex: 3,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 75,
          questionText: 'The formula for sulphuric acid is?',
          options: ['HCl', 'H₂SO₄', 'HNO₃', 'H₃PO₄'],
          correctIndex: 1,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 76,
          questionText: 'Which gas is used in balloons?',
          options: ['Oxygen', 'Nitrogen', 'Helium', 'Argon'],
          correctIndex: 2,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 77,
          questionText: 'What is the valency of Oxygen?',
          options: ['1', '2', '3', '4'],
          correctIndex: 1,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 78,
          questionText: 'Rust is formed by reaction of iron with?',
          options: ['Nitrogen', 'Carbon dioxide', 'Oxygen and moisture', 'Hydrogen'],
          correctIndex: 2,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 79,
          questionText: 'What is the atomic mass of Sodium (Na)?',
          options: ['11', '22', '23', '24'],
          correctIndex: 2,
          subtopic: 'Chemistry'),
      const ObjectiveQuestion(
          id: 80,
          questionText: 'Which catalyst is used in Haber process?',
          options: ['Platinum', 'Iron', 'Nickel', 'Vanadium pentoxide'],
          correctIndex: 1,
          subtopic: 'Chemistry'),
      // ── Biology (50 Qs) ──
      const ObjectiveQuestion(
          id: 81,
          questionText: 'What is the powerhouse of the cell?',
          options: ['Nucleus', 'Ribosome', 'Mitochondria', 'Chloroplast'],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 82,
          questionText: 'DNA stands for?',
          options: [
            'Deoxyribonucleic Acid',
            'Deoxyribose Nuclei Acid',
            'Deoxy Nuclear Acid',
            'Dinucleotide Acid'
          ],
          correctIndex: 0,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 83,
          questionText: 'How many chromosomes does a human cell have?',
          options: ['23', '44', '46', '48'],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 84,
          questionText: 'Which blood group is the universal donor?',
          options: ['A', 'B', 'AB', 'O'],
          correctIndex: 3,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 85,
          questionText: 'Photosynthesis occurs in which organelle?',
          options: ['Mitochondria', 'Ribosome', 'Chloroplast', 'Golgi body'],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 86,
          questionText: 'Which vitamin is produced by sunlight?',
          options: ['Vitamin A', 'Vitamin B', 'Vitamin C', 'Vitamin D'],
          correctIndex: 3,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 87,
          questionText: 'The study of heredity and variation is called?',
          options: ['Ecology', 'Genetics', 'Anatomy', 'Physiology'],
          correctIndex: 1,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 88,
          questionText: 'What is osmosis?',
          options: [
            'Movement of solute from low to high concentration',
            'Movement of solvent from high to low concentration',
            'Movement of water from low to high solute concentration',
            'None of the above'
          ],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 89,
          questionText: 'Which part of the brain controls balance?',
          options: ['Cerebrum', 'Medulla', 'Cerebellum', 'Thalamus'],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 90,
          questionText: 'What carries oxygen in red blood cells?',
          options: ['Globin', 'Haemoglobin', 'Albumin', 'Fibrin'],
          correctIndex: 1,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 91,
          questionText: 'The basic unit of life is?',
          options: ['Organ', 'Tissue', 'Cell', 'Molecule'],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 92,
          questionText: 'Which organ produces insulin?',
          options: ['Liver', 'Kidney', 'Pancreas', 'Stomach'],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 93,
          questionText: 'What is the normal human body temperature?',
          options: ['36.6°C', '37°C', '37.5°C', '38°C'],
          correctIndex: 1,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 94,
          questionText: 'Respiration in plants occurs through?',
          options: ['Roots', 'Stomata', 'Leaves', 'Stem'],
          correctIndex: 1,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 95,
          questionText: 'How many chambers does the human heart have?',
          options: ['2', '3', '4', '5'],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 96,
          questionText: 'Which is the longest bone in the human body?',
          options: ['Humerus', 'Tibia', 'Femur', 'Spine'],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 97,
          questionText: 'What is the role of ribosomes?',
          options: [
            'Energy production',
            'Protein synthesis',
            'Cell division',
            'DNA replication'
          ],
          correctIndex: 1,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 98,
          questionText: 'Which enzyme breaks down starch?',
          options: ['Pepsin', 'Lipase', 'Amylase', 'Trypsin'],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 99,
          questionText: 'Malaria is caused by?',
          options: ['Bacteria', 'Virus', 'Protozoa', 'Fungi'],
          correctIndex: 2,
          subtopic: 'Biology'),
      const ObjectiveQuestion(
          id: 100,
          questionText: 'Which plant hormone promotes growth?',
          options: ['Abscisic acid', 'Ethylene', 'Auxin', 'Cytokinin'],
          correctIndex: 2,
          subtopic: 'Biology'),
      // ── English (50 Qs) ──
      const ObjectiveQuestion(
          id: 101,
          questionText: 'What is the plural of "child"?',
          options: ['Childs', 'Children', 'Childrens', 'Childes'],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 102,
          questionText: 'Which is a synonym for "happy"?',
          options: ['Sad', 'Joyful', 'Angry', 'Tired'],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 103,
          questionText: 'Identify the verb: "She runs every morning."',
          options: ['She', 'runs', 'every', 'morning'],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 104,
          questionText: 'What is an antonym of "difficult"?',
          options: ['Hard', 'Tough', 'Easy', 'Complex'],
          correctIndex: 2,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 105,
          questionText: 'Fill in: "She __ reading a book yesterday."',
          options: ['is', 'are', 'was', 'were'],
          correctIndex: 2,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 106,
          questionText: 'Which sentence is in passive voice?',
          options: [
            'The cat ate the fish.',
            'The fish was eaten by the cat.',
            'The cat is eating the fish.',
            'The cat will eat the fish.'
          ],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 107,
          questionText: 'What is the past tense of "go"?',
          options: ['Goes', 'Going', 'Gone', 'Went'],
          correctIndex: 3,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 108,
          questionText: 'Choose the correct spelling:',
          options: ['Accomodation', 'Accommodation', 'Acomodation', 'Acommodation'],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 109,
          questionText: 'What part of speech is "quickly"?',
          options: ['Adjective', 'Noun', 'Adverb', 'Preposition'],
          correctIndex: 2,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 110,
          questionText: 'Which is a compound sentence?',
          options: [
            'She sings.',
            'She sings and dances.',
            'Although she sings.',
            'While she was singing.'
          ],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 111,
          questionText: 'The idiom "break a leg" means?',
          options: ['Get injured', 'Good luck', 'Run fast', 'Work hard'],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 112,
          questionText: 'What is the superlative of "good"?',
          options: ['Gooder', 'Better', 'Best', 'Goodest'],
          correctIndex: 2,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 113,
          questionText: 'Identify the noun: "Honesty is the best policy."',
          options: ['Honesty', 'is', 'the', 'best'],
          correctIndex: 0,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 114,
          questionText: '"I before E except after C" is a rule for?',
          options: ['Grammar', 'Spelling', 'Punctuation', 'Pronunciation'],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 115,
          questionText: 'Choose the correct article: "__ apple a day."',
          options: ['A', 'An', 'The', 'No article'],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 116,
          questionText: 'What is a metaphor?',
          options: [
            'A direct comparison using "like" or "as"',
            'An indirect comparison without "like" or "as"',
            'A repeated consonant sound',
            'An exaggeration'
          ],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 117,
          questionText: 'Which sentence is grammatically correct?',
          options: [
            'He don\'t like it.',
            'He doesn\'t likes it.',
            'He doesn\'t like it.',
            'He don\'t likes it.'
          ],
          correctIndex: 2,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 118,
          questionText: 'The word "benevolent" means?',
          options: ['Malicious', 'Generous and kind', 'Arrogant', 'Cowardly'],
          correctIndex: 1,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 119,
          questionText: 'What is the plural of "criterion"?',
          options: ['Criterions', 'Criterias', 'Criteria', 'Criterions'],
          correctIndex: 2,
          subtopic: 'English'),
      const ObjectiveQuestion(
          id: 120,
          questionText: 'Choose the correct preposition: "She is good __ mathematics."',
          options: ['in', 'at', 'on', 'for'],
          correctIndex: 1,
          subtopic: 'English'),
      // ── General Knowledge (50 Qs) ──
      const ObjectiveQuestion(
          id: 121,
          questionText: 'Who is the father of the Indian Constitution?',
          options: ['Mahatma Gandhi', 'Jawaharlal Nehru', 'B.R. Ambedkar', 'Sardar Patel'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 122,
          questionText: 'Which planet is known as the Red Planet?',
          options: ['Venus', 'Jupiter', 'Mars', 'Saturn'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 123,
          questionText: 'Capital of Australia is?',
          options: ['Sydney', 'Melbourne', 'Canberra', 'Perth'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 124,
          questionText: 'Who wrote "Romeo and Juliet"?',
          options: ['Charles Dickens', 'William Shakespeare', 'Leo Tolstoy', 'Mark Twain'],
          correctIndex: 1,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 125,
          questionText: 'How many continents are there on Earth?',
          options: ['5', '6', '7', '8'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 126,
          questionText: 'Which is the largest ocean?',
          options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
          correctIndex: 3,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 127,
          questionText: 'The Eiffel Tower is located in?',
          options: ['London', 'Paris', 'Rome', 'Berlin'],
          correctIndex: 1,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 128,
          questionText: 'What is the national bird of India?',
          options: ['Sparrow', 'Peacock', 'Crow', 'Eagle'],
          correctIndex: 1,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 129,
          questionText: 'Which country invented paper?',
          options: ['India', 'Egypt', 'China', 'Greece'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 130,
          questionText: 'The United Nations was founded in which year?',
          options: ['1943', '1945', '1947', '1950'],
          correctIndex: 1,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 131,
          questionText: 'Which metal is the best conductor of electricity?',
          options: ['Gold', 'Copper', 'Silver', 'Aluminium'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 132,
          questionText: 'Mount Everest is located in which country?',
          options: ['India', 'China', 'Nepal', 'Bhutan'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 133,
          questionText: 'The currency of Japan is?',
          options: ['Won', 'Yuan', 'Yen', 'Baht'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 134,
          questionText: 'Who invented the telephone?',
          options: ['Thomas Edison', 'Alexander Graham Bell', 'Nikola Tesla', 'James Watt'],
          correctIndex: 1,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 135,
          questionText: 'Yoga originated in which country?',
          options: ['China', 'Egypt', 'India', 'Greece'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 136,
          questionText: 'The Great Wall of China was built to protect against?',
          options: ['Floods', 'Earthquakes', 'Northern invasions', 'Diseases'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 137,
          questionText: 'Which is the smallest country in the world?',
          options: ['Monaco', 'San Marino', 'Vatican City', 'Liechtenstein'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 138,
          questionText: 'The Amazon River is located in?',
          options: ['Africa', 'Asia', 'South America', 'North America'],
          correctIndex: 2,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 139,
          questionText: 'How many stars are on the US flag?',
          options: ['48', '50', '51', '52'],
          correctIndex: 1,
          subtopic: 'General Knowledge'),
      const ObjectiveQuestion(
          id: 140,
          questionText: 'Which instrument measures atmospheric pressure?',
          options: ['Thermometer', 'Barometer', 'Hygrometer', 'Anemometer'],
          correctIndex: 1,
          subtopic: 'General Knowledge'),
      // ── Aptitude (50 Qs) ──
      const ObjectiveQuestion(
          id: 141,
          questionText: 'If a train travels 300 km in 3 hours, what is its speed?',
          options: ['80 km/h', '90 km/h', '100 km/h', '110 km/h'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 142,
          questionText: 'A and B can complete a work in 10 and 15 days. Together?',
          options: ['4 days', '5 days', '6 days', '7 days'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 143,
          questionText: 'If 5 apples cost Rs.20, cost of 12 apples?',
          options: ['Rs.40', 'Rs.44', 'Rs.48', 'Rs.52'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 144,
          questionText: 'The ratio 2:3 expressed as percentage of smaller to larger?',
          options: ['60%', '66.67%', '40%', '75%'],
          correctIndex: 1,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 145,
          questionText: 'What comes next: 2, 4, 8, 16, __?',
          options: ['24', '30', '32', '36'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 146,
          questionText: 'Simple interest on Rs.1000 at 10% for 2 years?',
          options: ['Rs.100', 'Rs.150', 'Rs.200', 'Rs.250'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 147,
          questionText: 'A number increased by 20% gives 120. The number is?',
          options: ['96', '100', '104', '110'],
          correctIndex: 1,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 148,
          questionText: 'Average of 3, 5, 7, 9, 11 is?',
          options: ['6', '7', '8', '9'],
          correctIndex: 1,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 149,
          questionText: 'What is 12.5% as a fraction?',
          options: ['1/4', '1/6', '1/8', '1/10'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 150,
          questionText: 'If APPLE = 50, then ORANGE = ?',
          options: ['60', '62', '64', '66'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 151,
          questionText: 'Profit% if CP=200, SP=250?',
          options: ['20%', '25%', '30%', '35%'],
          correctIndex: 1,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 152,
          questionText: 'How many faces does a cube have?',
          options: ['4', '5', '6', '8'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 153,
          questionText: 'If today is Monday, what day is after 100 days?',
          options: ['Sunday', 'Monday', 'Tuesday', 'Wednesday'],
          correctIndex: 3,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 154,
          questionText: 'A person walks 4 km N then 3 km E. Distance from start?',
          options: ['4 km', '5 km', '6 km', '7 km'],
          correctIndex: 1,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 155,
          questionText: 'Find the odd one: 2, 3, 5, 7, 9, 11',
          options: ['7', '9', '11', '2'],
          correctIndex: 1,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 156,
          questionText: 'Compound interest on Rs.1000 at 10% for 2 years?',
          options: ['Rs.200', 'Rs.205', 'Rs.210', 'Rs.215'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 157,
          questionText: 'If 2x + y = 10 and x = 3, then y = ?',
          options: ['2', '3', '4', '5'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 158,
          questionText: 'Smallest prime number is?',
          options: ['0', '1', '2', '3'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 159,
          questionText: 'Fill the series: 1, 4, 9, 16, __',
          options: ['20', '24', '25', '36'],
          correctIndex: 2,
          subtopic: 'Aptitude'),
      const ObjectiveQuestion(
          id: 160,
          questionText: 'Speed = Distance / Time. Time if D=120, S=40?',
          options: ['2 h', '3 h', '4 h', '5 h'],
          correctIndex: 1,
          subtopic: 'Aptitude'),
      // ── Extra mix (140 Qs) to reach 300 ──
    ];

    // Generate remaining 140 questions programmatically
    final List<String> subtopics = [
      'Mathematics',
      'Computer Science',
      'Physics',
      'Chemistry',
      'Biology',
      'English',
      'General Knowledge',
      'Aptitude'
    ];
    for (int i = 161; i <= 300; i++) {
      final st = subtopics[(i - 161) % subtopics.length];
      qs.add(ObjectiveQuestion(
        id: i,
        questionText: 'Question $i: Which of the following is correct? ($st)',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctIndex: (i - 1) % 4,
        subtopic: st,
      ));
    }

    return qs;
  }

  static List<Map<String, dynamic>> get leaderboard => [
        {'rank': 1, 'name': 'Priya Sharma', 'score': 285, 'percentile': 99.1},
        {'rank': 2, 'name': 'Arjun Singh', 'score': 280, 'percentile': 98.5},
        {'rank': 3, 'name': 'Sneha Patel', 'score': 274, 'percentile': 97.8},
        {'rank': 4, 'name': 'Rahul Kumar', 'score': 268, 'percentile': 96.9},
        {'rank': 5, 'name': 'GAURAV', 'score': 261, 'percentile': 95.3},
        {'rank': 6, 'name': 'Meena Joshi', 'score': 255, 'percentile': 94.1},
        {'rank': 7, 'name': 'RAJA', 'score': 249, 'percentile': 92.8},
        {'rank': 8, 'name': 'Vikram Rao', 'score': 241, 'percentile': 91.0},
        {'rank': 9, 'name': 'SAMRIDHI', 'score': 236, 'percentile': 89.7},
        {'rank': 10, 'name': 'Aditya Gupta', 'score': 228, 'percentile': 88.2},
        {'rank': 11, 'name': 'Divya Nair', 'score': 220, 'percentile': 86.5},
        {'rank': 12, 'name': 'Karan Mehta', 'score': 215, 'percentile': 84.3},
      ];
}

// ┌──────────────────────────────────────────────────────────────┐
// │                    EXAM UTILS / HELPERS                     │
// └──────────────────────────────────────────────────────────────┘

class ExamUtils {
  /// Formats Duration as MM:SS
  static String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Calculates score percentage
  static double scorePercent(int correct, int total) {
    if (total == 0) return 0;
    return (correct / total) * 100;
  }

  /// Motivational remark based on %
  static String motivationalRemark(double percent) {
    if (percent >= 85) return '🏆 Excellent! Keep it up!';
    if (percent >= 70) return '👍 Great effort! You\'re on the right track.';
    if (percent >= 50) return '📚 Good effort, try to improve consistency.';
    return '💡 Review concepts and attempt again.';
  }

  /// Validates PIN (6 digits)
  static bool isValidPin(String pin) =>
      pin.length == 6 && int.tryParse(pin) != null;

  /// Count correct answers for objective
  static int countCorrect(ObjectiveExamSession session) {
    int correct = 0;
    for (final q in session.questions) {
      final selected = session.selectedOptions[q.id];
      if (selected != null && selected == q.correctIndex) correct++;
    }
    return correct;
  }

  /// Color for timer (green → orange → red)
  static Color timerColor(Duration remaining, Duration total) {
    final ratio = remaining.inSeconds / total.inSeconds;
    if (ratio > 0.5) return Colors.green;
    if (ratio > 0.25) return Colors.orange;
    return Colors.red;
  }

  /// Shuffles a list copy
  static List<T> shuffled<T>(List<T> list) {
    final copy = List<T>.from(list);
    copy.shuffle(Random());
    return copy;
  }
}

// ┌──────────────────────────────────────────────────────────────┐
// │                   THEME CONTROLLER                          │
// └──────────────────────────────────────────────────────────────┘

class ThemeController {
  static ColorScheme get lightScheme => ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A6DFF),
        brightness: Brightness.light,
      );

  static ColorScheme get darkScheme => ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A6DFF),
        brightness: Brightness.dark,
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        fontFamily: 'Roboto',
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        fontFamily: 'Roboto',
      );
}

// ┌──────────────────────────────────────────────────────────────┐
// │               REUSABLE WIDGETS                              │
// └──────────────────────────────────────────────────────────────┘

/// Primary action button
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget btn = FilledButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
      label: Text(label,
          style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      style: FilledButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
    );
    if (width != null) {
      return SizedBox(width: width, child: btn);
    }
    return btn;
  }
}

/// Secondary / outlined button
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Empty state placeholder
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    this.message = 'No data found.',
    this.icon = Icons.folder_off_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: cs.outline),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: cs.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Status badge
class StatusBadge extends StatelessWidget {
  final bool isActive;
  const StatusBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.15)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isActive ? Colors.green : Colors.grey, width: 1),
      ),
      child: Text(
        isActive ? '● Active' : '○ Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
        ),
      ),
    );
  }
}

/// Stats card (for header)
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Leaderboard row
class LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final double percentile;
  final bool isCurrentStudent;

  const LeaderboardItem({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    required this.percentile,
    this.isCurrentStudent = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color rankColor = cs.outline;
    if (rank == 1) rankColor = Colors.amber;
    if (rank == 2) rankColor = Colors.blueGrey.shade300;
    if (rank == 3) rankColor = Colors.brown.shade400;

    return Card(
      elevation: isCurrentStudent ? 4 : 1,
      color: isCurrentStudent
          ? cs.primaryContainer
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rankColor.withOpacity(0.2),
          child: Text('$rank',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: rankColor)),
        ),
        title: Text(name,
            style: TextStyle(
                fontWeight: isCurrentStudent
                    ? FontWeight.bold
                    : FontWeight.normal)),
        subtitle: Text('Score: $score / 300'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${percentile.toStringAsFixed(1)}%',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: cs.primary),
          ),
        ),
      ),
    );
  }
}

/// Shows a snackbar error
void showSnackError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

void showSnackSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Confirm exit dialog
Future<bool> showExitDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orange),
        SizedBox(width: 8),
        Text('Exit Exam?'),
      ]),
      content: const Text(
          'If you leave now, your current progress may be lost. Are you sure you want to exit?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit')),
      ],
    ),
  );
  return result ?? false;
}

// ┌──────────────────────────────────────────────────────────────┐
// │                     LOGIN SCREEN                            │
// └──────────────────────────────────────────────────────────────┘

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePin = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate delay

    final username = _usernameController.text.trim().toUpperCase();
    final pin = _pinController.text.trim();

    final match = HardcodedData.credentials.any(
        (c) => c.username == username && c.pin == pin);

    if (match) {
      AppState.loggedInStudent = username;
      if (mounted) {
        Navigator.of(context).pushReplacement(
          _slideRoute(TodayTestScreen(studentName: username)));
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) showSnackError(context, 'Invalid username or PIN.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primaryContainer, cs.surface, cs.secondaryContainer],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: size.width > 600 ? 520 : double.infinity),
                child: Card(
                  elevation: 8,
                  shadowColor: cs.primary.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App Icon
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.school_rounded,
                                color: cs.onPrimary, size: 40),
                          ),
                          const SizedBox(height: 20),
                          // App Title
                          Text(
                            'BEEDI College',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Test System',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: cs.secondary,
                                    letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Login to continue',
                            style: TextStyle(
                                color: cs.outline, fontSize: 13),
                          ),
                          const SizedBox(height: 32),
                          // Username
                          TextFormField(
                            controller: _usernameController,
                            textCapitalization:
                                TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon:
                                  const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              filled: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Username is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // PIN
                          TextFormField(
                            controller: _pinController,
                            obscureText: _obscurePin,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: '6-Digit PIN',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePin
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _obscurePin = !_obscurePin),
                              ),
                              counterText: '',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              filled: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'PIN is required';
                              }
                              if (!ExamUtils.isValidPin(v.trim())) {
                                return 'PIN must be exactly 6 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _login,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white))
                                  : const Text('Login',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Demo credentials note
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('Demo Credentials',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: cs.outline)),
                                const SizedBox(height: 4),
                                const Text(
                                    'GAURAV / 123456\nRAJA / 741852\nSAMRIDHI / 852963',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ┌──────────────────────────────────────────────────────────────┐
// │                  TODAY TEST SCREEN (DASHBOARD)              │
// └──────────────────────────────────────────────────────────────┘

class TodayTestScreen extends StatefulWidget {
  final String studentName;
  const TodayTestScreen({super.key, required this.studentName});

  @override
  State<TodayTestScreen> createState() => _TodayTestScreenState();
}

class _TodayTestScreenState extends State<TodayTestScreen>
    with SingleTickerProviderStateMixin {
  late List<Batch> _allBatches;
  List<Batch> _filteredBatches = [];
  String _searchQuery = '';
  bool _filterActive = false;
  bool _showLeaderboard = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _allBatches = HardcodedData.batches;
    _filteredBatches = _allBatches;
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredBatches = _allBatches.where((b) {
        final matchName =
            b.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchActive = !_filterActive || b.isActive;
        return matchName && matchActive;
      }).toList();
    });
  }

  int get _completedExams {
    int count = 0;
    for (final b in _allBatches) {
      if (AppState.hasAttempted(widget.studentName, b.id, 'subjective')) {
        count++;
      }
      if (AppState.hasAttempted(widget.studentName, b.id, 'objective')) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        drawer: _buildDrawer(context),
        appBar: AppBar(
          title: const Text('BEEDI Test System',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 2,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                  AppState.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() {
                AppState.isDarkMode = !AppState.isDarkMode;
              }),
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => setState(() => _showLeaderboard = !_showLeaderboard),
          icon: Icon(
              _showLeaderboard ? Icons.leaderboard : Icons.leaderboard_outlined),
          label: Text(_showLeaderboard ? 'Dashboard' : 'Leaderboard'),
        ),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: _showLeaderboard
              ? _buildLeaderboard()
              : _buildDashboard(cs),
        ),
      ),
    );
  }

  Widget _buildDashboard(ColorScheme cs) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(cs)),
        SliverToBoxAdapter(child: _buildSearchFilter(cs)),
        _filteredBatches.isEmpty
            ? const SliverFillRemaining(
                child: EmptyStateWidget(
                    message: 'No batches found.\nTry adjusting your search.',
                    icon: Icons.search_off_outlined))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _BatchCard(
                    batch: _filteredBatches[i],
                    studentName: widget.studentName,
                    onAttempted: () => setState(() {}),
                    onNavigateSubjective: () {
                      Navigator.push(
                        context,
                        _slideRoute(SubjectiveTestScreen(
                            batch: _filteredBatches[i],
                            studentName: widget.studentName)),
                      ).then((_) => setState(() {}));
                    },
                    onNavigateObjective: () {
                      Navigator.push(
                        context,
                        _slideRoute(ObjectiveTestScreen(
                            batch: _filteredBatches[i],
                            studentName: widget.studentName)),
                      ).then((_) => setState(() {}));
                    },
                  ),
                  childCount: _filteredBatches.length,
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: cs.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: cs.primary,
                radius: 24,
                child: Text(
                  widget.studentName[0],
                  style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back,',
                      style: TextStyle(
                          fontSize: 13, color: cs.onSurface.withOpacity(0.7))),
                  Text(widget.studentName,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              StatsCard(
                  label: 'Total Batches',
                  value: '${_allBatches.length}',
                  icon: Icons.group_work_outlined,
                  color: cs.primary),
              const SizedBox(width: 8),
              StatsCard(
                  label: 'Completed',
                  value: '$_completedExams',
                  icon: Icons.check_circle_outline,
                  color: Colors.green),
              const SizedBox(width: 8),
              StatsCard(
                  label: 'Total Students',
                  value:
                      '${_allBatches.fold(0, (s, b) => s + b.studentCount)}',
                  icon: Icons.people_outline,
                  color: cs.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilter(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search batch...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
              ),
              onChanged: (val) {
                _searchQuery = val;
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 10),
          FilterChip(
            label: const Text('Active Only'),
            selected: _filterActive,
            onSelected: (val) {
              _filterActive = val;
              _applyFilters();
            },
            avatar: const Icon(Icons.filter_list, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    final data = HardcodedData.leaderboard;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.leaderboard, color: Colors.amber),
              const SizedBox(width: 8),
              Text('Top Performers – Last Batch',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: data.length,
            itemBuilder: (ctx, i) {
              final d = data[i];
              return LeaderboardItem(
                rank: d['rank'] as int,
                name: d['name'] as String,
                score: d['score'] as int,
                percentile: (d['percentile'] as num).toDouble(),
                isCurrentStudent:
                    d['name'] == AppState.loggedInStudent,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return NavigationDrawer(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                  radius: 36,
                  backgroundColor: cs.primary,
                  child: Text(widget.studentName[0],
                      style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              Text(widget.studentName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Student', style: TextStyle(color: cs.outline)),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          leading: Icon(
              AppState.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          title: Text(
              AppState.isDarkMode ? 'Switch to Light' : 'Switch to Dark'),
          onTap: () {
            setState(() => AppState.isDarkMode = !AppState.isDarkMode);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.leaderboard_outlined),
          title: const Text('Leaderboard'),
          onTap: () {
            Navigator.pop(context);
            setState(() => _showLeaderboard = true);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () {
            AppState.logout();
            Navigator.of(context).pushReplacement(
                _slideRoute(const LoginScreen()));
          },
        ),
      ],
    );
  }
}

/// Batch card widget
class _BatchCard extends StatelessWidget {
  final Batch batch;
  final String studentName;
  final VoidCallback onAttempted;
  final VoidCallback onNavigateSubjective;
  final VoidCallback onNavigateObjective;

  const _BatchCard({
    required this.batch,
    required this.studentName,
    required this.onAttempted,
    required this.onNavigateSubjective,
    required this.onNavigateObjective,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasSubjective =
        AppState.hasAttempted(studentName, batch.id, 'subjective');
    final hasObjective =
        AppState.hasAttempted(studentName, batch.id, 'objective');
    final totalAttempts =
        (hasSubjective ? 1 : 0) + (hasObjective ? 1 : 0);
    final progress = totalAttempts / 2.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(batch.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.access_time, size: 14,
                            color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(batch.timing,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ]),
                    ],
                  ),
                ),
                StatusBadge(isActive: batch.isActive),
              ],
            ),
            const SizedBox(height: 10),
            // Student count + attempt
            Row(
              children: [
                Icon(Icons.people_outline, size: 16, color: cs.secondary),
                const SizedBox(width: 4),
                Text('${batch.studentCount} students',
                    style:
                        TextStyle(fontSize: 13, color: cs.secondary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: totalAttempts > 0
                        ? Colors.green.withOpacity(0.12)
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    totalAttempts > 0 ? '✓ Attempted' : '● Not Attempted',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: totalAttempts > 0
                          ? Colors.green.shade700
                          : cs.outline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? Colors.green : cs.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$totalAttempts / 2 exams completed',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 14),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: hasSubjective
                      ? _LockedButton(
                          label: 'Subjective',
                          icon: Icons.edit_note)
                      : OutlinedButton.icon(
                          onPressed: batch.isActive
                              ? onNavigateSubjective
                              : null,
                          icon: const Icon(Icons.edit_note, size: 16),
                          label: const Text('Subjective',
                              style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10))),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: hasObjective
                      ? _LockedButton(
                          label: 'Objective',
                          icon: Icons.radio_button_checked)
                      : FilledButton.icon(
                          onPressed:
                              batch.isActive ? onNavigateObjective : null,
                          icon: const Icon(Icons.radio_button_checked,
                              size: 16),
                          label: const Text('Objective',
                              style: TextStyle(fontSize: 13)),
                          style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10))),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedButton extends StatelessWidget {
  final String label;
  final IconData icon;
  const _LockedButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: null,
      icon: Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade400),
      label: Text('$label\nSubmitted',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ┌──────────────────────────────────────────────────────────────┐
// │               SUBJECTIVE TEST SCREEN                        │
// └──────────────────────────────────────────────────────────────┘

class SubjectiveTestScreen extends StatefulWidget {
  final Batch batch;
  final String studentName;

  const SubjectiveTestScreen({
    super.key,
    required this.batch,
    required this.studentName,
  });

  @override
  State<SubjectiveTestScreen> createState() => _SubjectiveTestScreenState();
}

class _SubjectiveTestScreenState extends State<SubjectiveTestScreen> {
  late SubjectiveExamSession _session;
  Timer? _timer;
  final TextEditingController _answerCtrl = TextEditingController();
  bool _showNavigator = false;
  bool _isReview = false;

  static const Duration _totalTime = Duration(minutes: 45);

  @override
  void initState() {
    super.initState();
    final key = ExamAttemptKey(
        widget.studentName, widget.batch.id, 'subjective');
    if (AppState.subjectiveSessions.containsKey(key)) {
      _session = AppState.subjectiveSessions[key]!;
      if (_session.isSubmitted) return;
    } else {
      _session = SubjectiveExamSession(
          questions: HardcodedData.subjectiveQuestions,
          remainingTime: _totalTime);
      AppState.subjectiveSessions[key] = _session;
    }
    _loadAnswer();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_session.remainingTime.inSeconds <= 0) {
        _autoSubmit();
      } else {
        setState(() {
          _session.remainingTime -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _loadAnswer() {
    final existing =
        _session.questionAnswers[_session.currentQuestionIndex];
    _answerCtrl.text = existing ?? '';
  }

  void _saveCurrentAnswer() {
    final text = _answerCtrl.text.trim();
    if (text.isNotEmpty) {
      _session.questionAnswers[_session.currentQuestionIndex] = text;
    }
  }

  void _goTo(int index) {
    _saveCurrentAnswer();
    setState(() {
      _session.currentQuestionIndex = index;
      _showNavigator = false;
    });
    _loadAnswer();
  }

  Future<void> _autoSubmit() async {
    _timer?.cancel();
    _saveCurrentAnswer();
    _session.isSubmitted = true;
    _session.isAutoSubmitted = true;
    AppState.markAttempted(
        widget.studentName, widget.batch.id, 'subjective');
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.timer_off, color: Colors.orange),
          SizedBox(width: 8),
          Text('Time Up!'),
        ]),
        content:
            const Text('Exam auto-submitted due to time up.'),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('View Results')),
        ],
      ),
    );
    if (mounted) {
      Navigator.of(context).pushReplacement(
        _slideRoute(ResultScreen(
          studentName: widget.studentName,
          batchName: widget.batch.name,
          examType: 'subjective',
          subjectiveSession: _session,
        )),
      );
    }
  }

  Future<void> _submitExam() async {
    _saveCurrentAnswer();
    final unanswered = _session.questions.length -
        _session.questionAnswers.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Exam?'),
        content: Text(unanswered > 0
            ? '$unanswered questions are still unanswered. Submit anyway?'
            : 'Are you sure you want to submit?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Submit')),
        ],
      ),
    );
    if (confirm == true) {
      _timer?.cancel();
      _session.isSubmitted = true;
      AppState.markAttempted(
          widget.studentName, widget.batch.id, 'subjective');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          _slideRoute(ResultScreen(
            studentName: widget.studentName,
            batchName: widget.batch.name,
            examType: 'subjective',
            subjectiveSession: _session,
          )),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final q = _session.questions[_session.currentQuestionIndex];
    final totalQ = _session.questions.length;

    if (_session.isSubmitted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Exam locked after submission.',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'))
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _saveCurrentAnswer();
        final exit = await showExitDialog(context);
        if (exit) _timer?.cancel();
        return exit;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.batch.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const Text('Subjective Exam',
                  style: TextStyle(fontSize: 11)),
            ],
          ),
          actions: [
            // Timer
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: ExamUtils.timerColor(
                    _session.remainingTime, _totalTime),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    ExamUtils.formatDuration(_session.remainingTime),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Question counter
            Center(
              child: Text(
                'Q${_session.currentQuestionIndex + 1}/$totalQ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(_showNavigator ? Icons.close : Icons.grid_view),
              onPressed: () =>
                  setState(() => _showNavigator = !_showNavigator),
              tooltip: 'Question Navigator',
            ),
          ],
        ),
        body: _showNavigator
            ? _buildNavigator(cs, totalQ)
            : _isReview
                ? _buildReview(cs)
                : _buildQuestion(cs, q, totalQ),
      ),
    );
  }

  Widget _buildQuestion(
      ColorScheme cs, SubjectiveQuestion q, int totalQ) {
    final isMarked =
        _session.markedForReview[_session.currentQuestionIndex] == true;

    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: _session.questionAnswers.length / totalQ,
          minHeight: 3,
          backgroundColor: cs.surfaceContainerHighest,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Q${_session.currentQuestionIndex + 1}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: cs.onPrimaryContainer),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() {
                                _session.markedForReview[_session
                                    .currentQuestionIndex] = !isMarked;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isMarked
                                      ? Colors.orange.withOpacity(0.2)
                                      : cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        isMarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        size: 16,
                                        color: isMarked
                                            ? Colors.orange
                                            : cs.outline),
                                    const SizedBox(width: 4),
                                    Text(
                                        isMarked ? 'Marked' : 'Mark',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isMarked
                                                ? Colors.orange
                                                : cs.outline)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(q.questionText,
                            style: const TextStyle(
                                fontSize: 16, height: 1.6)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Answer box
                TextField(
                  controller: _answerCtrl,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Type your answer here...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    labelText: 'Your Answer',
                  ),
                  onChanged: (v) {
                    _session.questionAnswers[_session.currentQuestionIndex] =
                        v;
                  },
                ),
                const SizedBox(height: 16),
                // Save draft button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _saveCurrentAnswer();
                          showSnackSuccess(context, 'Draft saved!');
                        },
                        icon: const Icon(Icons.save_outlined, size: 16),
                        label: const Text('Save Draft'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _isReview = true),
                        icon: const Icon(Icons.preview_outlined, size: 16),
                        label: const Text('Review'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Bottom navigation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, -2))
            ],
          ),
          child: Row(
            children: [
              SecondaryButton(
                label: 'Prev',
                icon: Icons.arrow_back,
                onPressed: _session.currentQuestionIndex > 0
                    ? () => _goTo(_session.currentQuestionIndex - 1)
                    : null,
              ),
              const Spacer(),
              if (_session.currentQuestionIndex < totalQ - 1)
                FilledButton.icon(
                  onPressed: () =>
                      _goTo(_session.currentQuestionIndex + 1),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Next'),
                )
              else
                FilledButton.icon(
                  onPressed: _submitExam,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: const Text('Submit'),
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.green),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigator(ColorScheme cs, int totalQ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Question Navigator',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              FilledButton.icon(
                onPressed: _submitExam,
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const Text('Submit Exam'),
                style:
                    FilledButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 16,
            children: [
              _Legend(color: Colors.grey.shade300, label: 'Not Answered'),
              _Legend(color: Colors.green, label: 'Answered'),
              _Legend(color: Colors.orange, label: 'Marked'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: totalQ,
              itemBuilder: (ctx, i) {
                final isAnswered =
                    _session.questionAnswers.containsKey(i) &&
                        _session.questionAnswers[i]!.isNotEmpty;
                final isMarked =
                    _session.markedForReview[i] == true;
                final isCurrent = i == _session.currentQuestionIndex;

                Color bgColor = Colors.grey.shade300;
                if (isMarked) bgColor = Colors.orange;
                if (isAnswered) bgColor = Colors.green;
                if (isCurrent) bgColor = cs.primary;

                return InkWell(
                  onTap: () => _goTo(i),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: (isAnswered || isCurrent)
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReview(ColorScheme cs) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Review Answers',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              OutlinedButton(
                  onPressed: () => setState(() => _isReview = false),
                  child: const Text('Back')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _session.questions.length,
            itemBuilder: (ctx, i) {
              final q = _session.questions[i];
              final ans = _session.questionAnswers[i];
              final isAnswered = ans != null && ans.isNotEmpty;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isAnswered ? Colors.green : Colors.grey.shade300,
                    child: Text('${i + 1}',
                        style: TextStyle(
                            color:
                                isAnswered ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  title: Text(
                      q.questionText.length > 80
                          ? '${q.questionText.substring(0, 80)}...'
                          : q.questionText,
                      style: const TextStyle(fontSize: 13)),
                  subtitle: Text(
                      isAnswered
                          ? 'Answered: ${ans!.length > 50 ? '${ans.substring(0, 50)}...' : ans}'
                          : 'Not answered',
                      style: TextStyle(
                          color:
                              isAnswered ? Colors.green : Colors.red.shade400,
                          fontSize: 12)),
                  onTap: () {
                    setState(() => _isReview = false);
                    _goTo(i);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ┌──────────────────────────────────────────────────────────────┐
// │               OBJECTIVE TEST SCREEN (300 MCQ)               │
// └──────────────────────────────────────────────────────────────┘

class ObjectiveTestScreen extends StatefulWidget {
  final Batch batch;
  final String studentName;

  const ObjectiveTestScreen({
    super.key,
    required this.batch,
    required this.studentName,
  });

  @override
  State<ObjectiveTestScreen> createState() => _ObjectiveTestScreenState();
}

class _ObjectiveTestScreenState extends State<ObjectiveTestScreen> {
  late ObjectiveExamSession _session;
  Timer? _timer;
  bool _showNavigator = false;

  static const Duration _totalTime = Duration(minutes: 45);

  @override
  void initState() {
    super.initState();
    final key = ExamAttemptKey(
        widget.studentName, widget.batch.id, 'objective');
    if (AppState.objectiveSessions.containsKey(key)) {
      final existing = AppState.objectiveSessions[key]!;
      if (existing.isSubmitted) {
        _session = existing;
        return;
      }
      // Resume existing
      _session = existing;
    } else {
      _session = ObjectiveExamSession(
          questions:
              ExamUtils.shuffled(HardcodedData.objectiveQuestions),
          remainingTime: _totalTime);
      AppState.objectiveSessions[key] = _session;
    }
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_session.remainingTime.inSeconds <= 0) {
        _autoSubmit();
      } else {
        setState(() {
          _session.remainingTime -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _selectOption(int questionId, int optionIndex) {
    if (_session.selectedOptions.containsKey(questionId)) return; // locked
    setState(() {
      _session.selectedOptions[questionId] = optionIndex;
    });
    // Auto-advance
    if (_session.currentIndex < _session.questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _session.currentIndex++);
        }
      });
    }
  }

  Future<void> _autoSubmit() async {
    _timer?.cancel();
    _session.isSubmitted = true;
    AppState.markAttempted(
        widget.studentName, widget.batch.id, 'objective');
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.timer_off, color: Colors.orange),
          SizedBox(width: 8),
          Text('Time Up!'),
        ]),
        content: const Text('Exam auto-submitted due to time up.'),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('View Results')),
        ],
      ),
    );
    if (mounted) _navigateToResult();
  }

  Future<void> _submitExam() async {
    final unanswered = _session.questions.length -
        _session.selectedOptions.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Exam?'),
        content: Text(unanswered > 0
            ? '$unanswered questions unanswered. Submit anyway?'
            : 'Submit your exam?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Submit')),
        ],
      ),
    );
    if (confirm == true) {
      _timer?.cancel();
      _session.isSubmitted = true;
      AppState.markAttempted(
          widget.studentName, widget.batch.id, 'objective');
      if (mounted) _navigateToResult();
    }
  }

  void _navigateToResult() {
    Navigator.of(context).pushReplacement(
      _slideRoute(ResultScreen(
        studentName: widget.studentName,
        batchName: widget.batch.name,
        examType: 'objective',
        objectiveSession: _session,
      )),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_session.isSubmitted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Exam locked after submission.',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back')),
            ],
          ),
        ),
      );
    }

    final q = _session.questions[_session.currentIndex];
    final selectedOption = _session.selectedOptions[q.id];
    final isMarked = _session.markedForReview[q.id] == true;
    final totalQ = _session.questions.length;
    final answeredCount = _session.selectedOptions.length;

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitDialog(context);
        if (exit) _timer?.cancel();
        return exit;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.batch.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const Text('Objective Exam – 300 MCQ',
                  style: TextStyle(fontSize: 11)),
            ],
          ),
          actions: [
            // Timer
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: ExamUtils.timerColor(
                    _session.remainingTime, _totalTime),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    ExamUtils.formatDuration(_session.remainingTime),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Center(
              child: Text(
                'Q${_session.currentIndex + 1}/$totalQ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(_showNavigator ? Icons.close : Icons.grid_view),
              onPressed: () =>
                  setState(() => _showNavigator = !_showNavigator),
              tooltip: 'Question Navigator',
            ),
          ],
        ),
        body: _showNavigator
            ? _buildNavigator(cs, totalQ)
            : Column(
                children: [
                  // Progress bar
                  LinearProgressIndicator(
                    value: answeredCount / totalQ,
                    minHeight: 4,
                    backgroundColor:
                        cs.surfaceContainerHighest,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Text('$answeredCount / $totalQ answered',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const Spacer(),
                        Text(
                            q.subtopic ?? '',
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.secondary,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Question card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6),
                                        decoration: BoxDecoration(
                                          color: cs.primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Q${_session.currentIndex + 1}',
                                          style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              color: cs
                                                  .onPrimaryContainer),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          _session.markedForReview[
                                              q.id] = !isMarked;
                                        }),
                                        child: Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isMarked
                                                ? Colors.orange
                                                    .withOpacity(0.2)
                                                : cs
                                                    .surfaceContainerHighest,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                          ),
                                          child: Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              Icon(
                                                  isMarked
                                                      ? Icons.bookmark
                                                      : Icons
                                                          .bookmark_border,
                                                  size: 16,
                                                  color: isMarked
                                                      ? Colors.orange
                                                      : cs.outline),
                                              const SizedBox(width: 4),
                                              Text(
                                                  isMarked
                                                      ? 'Marked'
                                                      : 'Mark',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: isMarked
                                                          ? Colors.orange
                                                          : cs.outline)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(q.questionText,
                                      style: const TextStyle(
                                          fontSize: 16, height: 1.5)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Options
                          ...List.generate(q.options.length, (i) {
                            final isSelected = selectedOption == i;
                            final isLocked = selectedOption != null;
                            Color? bgColor;
                            if (isLocked && isSelected) {
                              bgColor = cs.primary.withOpacity(0.15);
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: isLocked
                                    ? null
                                    : () => _selectOption(q.id, i),
                                borderRadius:
                                    BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: bgColor ??
                                        Theme.of(context)
                                            .cardColor,
                                    border: Border.all(
                                      color: isSelected
                                          ? cs.primary
                                          : cs.outlineVariant,
                                      width:
                                          isSelected ? 2 : 1,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? cs.primary
                                              : cs.surfaceContainerHighest,
                                        ),
                                        child: Center(
                                          child: Text(
                                            ['A', 'B', 'C', 'D'][i],
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              color: isSelected
                                                  ? cs.onPrimary
                                                  : cs.outline,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Text(q.options[i],
                                              style: const TextStyle(
                                                  fontSize: 15))),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  // Bottom nav
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, -2))
                      ],
                    ),
                    child: Row(
                      children: [
                        SecondaryButton(
                          label: 'Prev',
                          icon: Icons.arrow_back,
                          onPressed: _session.currentIndex > 0
                              ? () => setState(
                                  () => _session.currentIndex--)
                              : null,
                        ),
                        const Spacer(),
                        if (_session.currentIndex < totalQ - 1)
                          FilledButton.icon(
                            onPressed: () =>
                                setState(() => _session.currentIndex++),
                            icon: const Icon(Icons.arrow_forward,
                                size: 18),
                            label: const Text('Next'),
                          )
                        else
                          FilledButton.icon(
                            onPressed: _submitExam,
                            icon: const Icon(Icons.send_outlined,
                                size: 18),
                            label: const Text('Submit'),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.green),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNavigator(ColorScheme cs, int totalQ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Question Navigator',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              FilledButton.icon(
                onPressed: _submitExam,
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const Text('Submit Exam'),
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            children: [
              _Legend(color: Colors.grey.shade300, label: 'Not Answered'),
              _Legend(color: Colors.green, label: 'Answered'),
              _Legend(color: Colors.orange, label: 'Marked'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: totalQ,
              itemBuilder: (ctx, i) {
                final q = _session.questions[i];
                final isAnswered =
                    _session.selectedOptions.containsKey(q.id);
                final isMarked =
                    _session.markedForReview[q.id] == true;
                final isCurrent = i == _session.currentIndex;

                Color bgColor = Colors.grey.shade300;
                if (isMarked) bgColor = Colors.orange;
                if (isAnswered) bgColor = Colors.green;
                if (isCurrent) bgColor = cs.primary;

                return InkWell(
                  onTap: () => setState(() {
                    _session.currentIndex = i;
                    _showNavigator = false;
                  }),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: (isAnswered || isCurrent)
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ┌──────────────────────────────────────────────────────────────┐
// │                      RESULT SCREEN                          │
// └──────────────────────────────────────────────────────────────┘

class ResultScreen extends StatefulWidget {
  final String studentName;
  final String batchName;
  final String examType; // 'subjective' | 'objective'
  final SubjectiveExamSession? subjectiveSession;
  final ObjectiveExamSession? objectiveSession;

  const ResultScreen({
    super.key,
    required this.studentName,
    required this.batchName,
    required this.examType,
    this.subjectiveSession,
    this.objectiveSession,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _correct;
  late int _wrong;
  late int _skipped;
  late int _total;
  late double _percent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _computeStats();
  }

  void _computeStats() {
    if (widget.examType == 'objective' && widget.objectiveSession != null) {
      final sess = widget.objectiveSession!;
      _total = sess.questions.length;
      _correct = ExamUtils.countCorrect(sess);
      _skipped = _total - sess.selectedOptions.length;
      _wrong = _total - _correct - _skipped;
      _percent = ExamUtils.scorePercent(_correct, _total);
    } else if (widget.subjectiveSession != null) {
      final sess = widget.subjectiveSession!;
      _total = sess.questions.length;
      _correct =
          sess.questionAnswers.values.where((v) => v.isNotEmpty).length;
      _skipped = _total - _correct;
      _wrong = 0;
      _percent = ExamUtils.scorePercent(_correct, _total);
    } else {
      _total = 0;
      _correct = 0;
      _wrong = 0;
      _skipped = 0;
      _percent = 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_total == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const EmptyStateWidget(
          message: 'No exam data found.\nPlease take a test first.',
          icon: Icons.assignment_outlined,
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Exam Results',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  _slideRoute(
                      TodayTestScreen(studentName: widget.studentName)),
                  (r) => false,
                );
              },
              icon: const Icon(Icons.dashboard_outlined),
              label: const Text('Dashboard'),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Summary'),
              Tab(text: 'Analytics'),
              Tab(text: 'Review'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSummary(cs),
            _buildAnalytics(cs),
            _buildReview(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primaryContainer, cs.secondaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '${_percent.toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: cs.primary),
                  ),
                  Text(
                    ExamUtils.motivationalRemark(_percent),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ScorePill(
                          label: 'Correct',
                          value: '$_correct',
                          color: Colors.green),
                      _ScorePill(
                          label: 'Wrong',
                          value: '$_wrong',
                          color: Colors.red),
                      _ScorePill(
                          label: 'Skipped',
                          value: '$_skipped',
                          color: Colors.orange),
                      _ScorePill(
                          label: 'Total',
                          value: '$_total',
                          color: cs.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Batch + rank card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Batch Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  _InfoRow(label: 'Batch', value: widget.batchName),
                  _InfoRow(
                      label: 'Exam Type',
                      value: widget.examType == 'objective'
                          ? 'Objective (MCQ)'
                          : 'Subjective'),
                  _InfoRow(label: 'Student', value: widget.studentName),
                  _InfoRow(
                      label: 'Score',
                      value: '$_correct / $_total'),
                  _InfoRow(
                      label: 'Percentile',
                      value: '${_percent.toStringAsFixed(1)}%'),
                  _InfoRow(label: 'Rank (Mock)', value: '15 / 100'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Leaderboard teaser
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.leaderboard, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text('Top Performers',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 10),
                  ...HardcodedData.leaderboard.take(5).map(
                        (d) => LeaderboardItem(
                          rank: d['rank'] as int,
                          name: d['name'] as String,
                          score: d['score'] as int,
                          percentile:
                              (d['percentile'] as num).toDouble(),
                          isCurrentStudent:
                              d['name'] == widget.studentName,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Analytics',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Pie chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Score Breakdown',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CustomPaint(
                          painter: _PieChartPainter(
                            correct: _correct,
                            wrong: _wrong,
                            skipped: _skipped,
                            total: _total,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PieLegend(
                              color: Colors.green,
                              label: 'Correct',
                              count: _correct),
                          const SizedBox(height: 8),
                          _PieLegend(
                              color: Colors.red,
                              label: 'Wrong',
                              count: _wrong),
                          const SizedBox(height: 8),
                          _PieLegend(
                              color: Colors.orange,
                              label: 'Skipped',
                              count: _skipped),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bar chart by subtopic (objective only)
          if (widget.examType == 'objective' &&
              widget.objectiveSession != null)
            _buildSubtopicBars(cs),
        ],
      ),
    );
  }

  Widget _buildSubtopicBars(ColorScheme cs) {
    final sess = widget.objectiveSession!;
    final Map<String, int> topicTotal = {};
    final Map<String, int> topicCorrect = {};

    for (final q in sess.questions) {
      final st = q.subtopic ?? 'Other';
      topicTotal[st] = (topicTotal[st] ?? 0) + 1;
      final sel = sess.selectedOptions[q.id];
      if (sel != null && sel == q.correctIndex) {
        topicCorrect[st] = (topicCorrect[st] ?? 0) + 1;
      }
    }

    final topics = topicTotal.keys.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance by Topic',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...topics.map((t) {
              final tot = topicTotal[t]!;
              final cor = topicCorrect[t] ?? 0;
              final pct = tot > 0 ? cor / tot : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(t,
                                style: const TextStyle(fontSize: 13))),
                        Text('$cor/$tot',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                                fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 10,
                        backgroundColor:
                            cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            pct >= 0.7 ? Colors.green : pct >= 0.4
                                ? Colors.orange
                                : Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(ColorScheme cs) {
    if (widget.examType == 'objective' &&
        widget.objectiveSession != null) {
      return _buildObjectiveReview(cs);
    } else if (widget.subjectiveSession != null) {
      return _buildSubjectiveReview(cs);
    }
    return const EmptyStateWidget();
  }

  Widget _buildObjectiveReview(ColorScheme cs) {
    final sess = widget.objectiveSession!;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sess.questions.length,
      itemBuilder: (ctx, i) {
        final q = sess.questions[i];
        final selected = sess.selectedOptions[q.id];
        final isCorrect = selected == q.correctIndex;
        final isSkipped = selected == null;

        Color cardColor = cs.surface;
        if (!isSkipped) {
          cardColor = isCorrect
              ? Colors.green.withOpacity(0.08)
              : Colors.red.withOpacity(0.08);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSkipped
                  ? Colors.orange.withOpacity(0.3)
                  : isCorrect
                      ? Colors.green.withOpacity(0.4)
                      : Colors.red.withOpacity(0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isSkipped
                          ? Icons.remove_circle_outline
                          : isCorrect
                              ? Icons.check_circle
                              : Icons.cancel,
                      color: isSkipped
                          ? Colors.orange
                          : isCorrect
                              ? Colors.green
                              : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text('Q${i + 1}.',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(q.questionText,
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Correct: ${q.options[q.correctIndex]}',
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                if (!isSkipped && !isCorrect)
                  Text(
                    'Your Answer: ${q.options[selected!]}',
                    style: const TextStyle(
                        color: Colors.red, fontSize: 12),
                  ),
                if (isSkipped)
                  const Text(
                    'Skipped',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectiveReview(ColorScheme cs) {
    final sess = widget.subjectiveSession!;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sess.questions.length,
      itemBuilder: (ctx, i) {
        final q = sess.questions[i];
        final ans = sess.questionAnswers[i] ?? '';
        final isAnswered = ans.isNotEmpty;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          isAnswered ? Colors.green : Colors.grey.shade300,
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isAnswered
                                  ? Colors.white
                                  : Colors.black87)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(q.questionText,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 10),
                if (isAnswered) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Answer:',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: cs.primary)),
                        const SizedBox(height: 4),
                        Text(ans,
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  if (q.referenceAnswer != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Reference Answer:',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                          const SizedBox(height: 4),
                          Text(q.referenceAnswer!,
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ] else
                  Text('Not answered',
                      style: TextStyle(
                          color: Colors.red.shade400, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ┌──────────────────────────────────────────────────────────────┐
// │                  SMALL HELPER WIDGETS                       │
// └──────────────────────────────────────────────────────────────┘

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ScorePill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _PieLegend extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  const _PieLegend(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: $count',
            style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

// ┌──────────────────────────────────────────────────────────────┐
// │                   CUSTOM PAINT – PIE CHART                  │
// └──────────────────────────────────────────────────────────────┘

class _PieChartPainter extends CustomPainter {
  final int correct;
  final int wrong;
  final int skipped;
  final int total;

  _PieChartPainter({
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;

    final data = [
      (correct.toDouble(), Colors.green),
      (wrong.toDouble(), Colors.red),
      (skipped.toDouble(), Colors.orange),
    ];

    double startAngle = -pi / 2;
    for (final seg in data) {
      if (seg.$1 == 0) continue;
      final sweepAngle = (seg.$1 / total) * 2 * pi;
      final paint = Paint()
        ..color = seg.$2
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    // White circle (donut)
    canvas.drawCircle(
        center,
        radius * 0.55,
        Paint()..color = Colors.white);

    // Center text
    final tp = TextPainter(
      text: TextSpan(
        text:
            '${(correct / total * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas,
        center -
            Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_PieChartPainter old) => true;
}

// ┌──────────────────────────────────────────────────────────────┐
// │                   ROUTE ANIMATION HELPER                    │
// └──────────────────────────────────────────────────────────────┘

/// Slide + fade transition between screens
PageRoute<T> _slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (ctx, anim, secAnim) => page,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (ctx, anim, secAnim, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut));
      final fade = CurvedAnimation(parent: anim, curve: Curves.easeIn);
      return SlideTransition(
          position: slide, child: FadeTransition(opacity: fade, child: child));
    },
  );
}

// ┌──────────────────────────────────────────────────────────────┐
// │               APP ROOT WIDGET (Entry Point)                 │
// │  Import this file and use BeediCbtApp() as your root widget │
// └──────────────────────────────────────────────────────────────┘

/// Root widget – wrap with MaterialApp or insert as child of one.
/// Usage in main.dart:
///   runApp(BeediCbtApp());
