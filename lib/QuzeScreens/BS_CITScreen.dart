import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String subject;
  final String description;
  final String difficulty; // easy, medium, hard
  final String topic;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.subject,
    required this.description,
    this.difficulty = 'medium',
    this.topic = 'General',
  });
}

class UserCredential {
  final String name;
  final String pin;
  const UserCredential({required this.name, required this.pin});
}

class Subject {
  final String code;
  final String name;
  final String icon;
  final int totalMinutes;

  const Subject({
    required this.code,
    required this.name,
    required this.icon,
    this.totalMinutes = 60,
  });
}

enum AnswerStatus {
  unattempted,
  attempted,
  skipped,
  markedForReview,
  bookmarked,
}

class AttemptRecord {
  final String studentName;
  final String subjectCode;
  final int score;
  final int total;
  final DateTime attemptTime;
  final int timeTakenSeconds;

  AttemptRecord({
    required this.studentName,
    required this.subjectCode,
    required this.score,
    required this.total,
    required this.attemptTime,
    required this.timeTakenSeconds,
  });

  Map<String, dynamic> toJson() => {
    'studentName': studentName,
    'subjectCode': subjectCode,
    'score': score,
    'total': total,
    'attemptTime': attemptTime.toIso8601String(),
    'timeTakenSeconds': timeTakenSeconds,
  };
}

// ─────────────────────────────────────────────
//  HARDCODED DATA
// ─────────────────────────────────────────────
const List<UserCredential> _validUsers = [
  // Batch 1 Students (kqUkvA64SfZ_m8jL3i)
  UserCredential(name: 'KUMARI TANUJA BHARTI', pin: '481092'),
  UserCredential(name: 'SIRITI KUMARI', pin: '579234'),
  UserCredential(name: 'NANDANI KUMARI', pin: '835671'),
  UserCredential(name: 'ANNU BHARTI', pin: '742908'),
  UserCredential(name: 'MADHU KUMARI', pin: '316457'),
  UserCredential(name: 'KUMARI SNEHA BHARTI', pin: '204583'),
  UserCredential(name: 'PAYAL KUMARI', pin: '698321'),
  UserCredential(name: 'RANGILA KUMARI', pin: '957160'),
  UserCredential(name: 'AARATI KUMARI', pin: '173846'),
  UserCredential(name: 'sonali nandini', pin: '428579'),
  UserCredential(name: 'NIKKI KUMARI', pin: '365012'),
  UserCredential(name: 'ANJALI KUMARI', pin: '791548'),
  UserCredential(name: 'PRIYANKA KUMARI', pin: '604237'),
  UserCredential(name: 'ANKITA KUMARI', pin: '829165'),
  
  // Batch 2 Students (7DN9XgL4K7cW5WypSX)
  UserCredential(name: 'SRISTI KUMARI', pin: '273401'),
  UserCredential(name: 'ANSHU KUMAR', pin: '946573'),
  UserCredential(name: 'VISHAL KUMAR', pin: '518429'),
  UserCredential(name: 'SANDHYA KUMARI', pin: '387206'),
  UserCredential(name: 'RAJNANDANI KUMARI', pin: '692745'),
  UserCredential(name: 'KANCHAN KUMARI', pin: '150398'),
  UserCredential(name: 'PRINCE KUMAR', pin: '734621'),
  UserCredential(name: 'HIMANSHU RAJ', pin: '819064'),
  UserCredential(name: 'SAHIL RAJ', pin: '465278'),
  UserCredential(name: 'RANJEET KUMAR', pin: '902317'),
  UserCredential(name: 'RUPA KUMARI', pin: '146583'),
  UserCredential(name: 'DOLLY KUMARI', pin: '678940'),
  UserCredential(name: 'NAFISHA KHATUN', pin: '321765'),
  UserCredential(name: 'RAJNANDANI', pin: '457891'),
  UserCredential(name: 'JYOTI RAJ', pin: '903246'),
  UserCredential(name: 'KUNAL KUMAR', pin: '287419'),
  UserCredential(name: 'AJIT KUMAR', pin: '614573'),
  UserCredential(name: 'MD SARFUDDIN', pin: '758901'),
  
  // Batch 3 Students (XSPpEHD4T5QeWn4jX9)
  UserCredential(name: 'SIMRAN KUMARI', pin: '362185'),
  UserCredential(name: 'ANIRUDH KUMAR', pin: '721409'),
  UserCredential(name: 'MANISH KUMAR', pin: '854367'),
  UserCredential(name: 'HIMANSHU KUMAR SINGH', pin: '590674'),
  UserCredential(name: 'ANKITA KUMARI', pin: '418023'),
  UserCredential(name: 'RAUSHANI KUMARI', pin: '763149'),
  UserCredential(name: 'SONAM KUMARI', pin: '238761'),
  UserCredential(name: 'NISHA KUMARI', pin: '632598'),
  UserCredential(name: 'SWETA KUMARI', pin: '417830'),
  UserCredential(name: 'MONIKA KUMARI', pin: '975241'),
  UserCredential(name: 'GAURAV KUMAR', pin: '234567'),
  UserCredential(name: 'RANDHIR KUMAR', pin: '123456'),
  UserCredential(name: 'SUMAN KUMARI', pin: '654321'),  
  UserCredential(name: 'PRIYANKA KUMARI', pin: '987654'),


UserCredential(name: 'RAJA KUMAR', pin: '741852'),
UserCredential(name: 'SAMRIDHI KUMARI', pin: '852963'),
UserCredential(name: 'LALMOHAN KUMAR', pin: '159753'),
UserCredential(name: 'PRITI KUMARI', pin: '357951'),
UserCredential(name: 'RUBY KUMARI', pin: '456789'),
UserCredential(name: 'DEEPA KUMARI', pin: '258369'),
UserCredential(name: 'MANTU KUMAR', pin: '369258'),
UserCredential(name: 'VISHAKHA KUMARI', pin: '147258'),
];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
const List<Subject> _subjects = [
  Subject(
    code: 'BS-CIT',
    name: 'Bihar State Certificate in Information Technology',
    icon: '💻',
    totalMinutes: 60,
  ),
  Subject(
    code: 'BS-CLS',
    name: 'Bihar State Certificate in Language Skill',
    icon: '🔬',
    totalMinutes: 60,
  ),
  Subject(
    code: 'BS-CSS',
    name: 'CBihar State Certificate in Soft Skill',
    icon: '🛡️',
    totalMinutes: 60,
  ),
    Subject(
    code: 'Mock Test',
    name: 'Ready For Final Exam',
    icon: '🛡️',
    totalMinutes: 60,
  ),
    Subject(
    code: 'Exam BS-CIT',
    name: 'Ready For Final Exam',
    icon: '🛡️',
    totalMinutes: 60,
  ),
      Subject(
    code: 'Exam BS-CLS',
    name: 'Ready For Final Exam',
    icon: '🛡️',
    totalMinutes: 60,
  ),
      Subject(
    code: 'Exam BS-CSS',
    name: 'Ready For Final Exam',
    icon: '🛡️',
    totalMinutes: 60,
  ),
];

// BS-CIT Questions
const List<QuizQuestion> _citQuestions = [
  QuizQuestion(
    id: 'cit1',
    question: 'कंप्यूटर का \'Brain\' किस Component को कहा जाता है?',
    options: ['Monitor', 'Mouse', 'CPU', 'Keyboard'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'CPU (Central Processing Unit) को कंप्यूटर का मस्तिष्क कहा जाता है क्योंकि यह सभी निर्देशों को प्रोसेस करता है।',
  ),
  QuizQuestion(
    id: 'cit2',
    question: 'Monitor का कार्य क्या होता है?',
    options: [
      'Processes Data',
      'Displays Visual Output',
      'Sends E-mails',
      'Stores Files',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Monitor का मुख्य कार्य विजुअल आउटपुट प्रदर्शित करना है, जैसे टेक्स्ट, इमेज और वीडियो।',
  ),
  QuizQuestion(
    id: 'cit3',
    question: 'Windows कंप्यूटर को बंद करने का सही तरीका क्या है?',
    options: [
      'Plug को Socket से निकालना',
      'Power बटन को 10 सेकंड तक दबाना',
      'Start Menu → Power → Shut Down',
      'सिर्फ सभी Windows बंद कर देना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'कंप्यूटर को सही तरीके से बंद करने के लिए Start Menu में जाकर Power और फिर Shut Down विकल्प चुनना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit4',
    question: 'Power बटन पर आमतौर पर कौन-सा Symbol होता है?',
    options: [
      'Arrow',
      'Lightning Bolt',
      'Circle With A Vertical Line',
      'Triangle',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पॉवर बटन पर आमतौर पर एक वृत्त और उसके ऊपर एक ऊर्ध्वाधर रेखा (Circle with a vertical line) का चिन्ह होता है।',
  ),
  QuizQuestion(
    id: 'cit5',
    question: 'Freezing Screen का एक सामान्य कारण क्या है?',
    options: [
      'New Updates',
      'Too Many Open Applications',
      'Brightness Too High',
      'Loud Sound Settings',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'स्क्रीन फ्रीज होने का एक सामान्य कारण बहुत सारे एप्लिकेशन एक साथ खुले होना है, जिससे सिस्टम की मेमोरी ओवरलोड हो जाती है।',
  ),
  QuizQuestion(
    id: 'cit6',
    question: 'Windows में Task Manager जल्दी खोलने का तरीका क्या है?',
    options: [
      'Ctrl + Alt + Del',
      'Ctrl + Shift + Esc',
      'Alt + Tab',
      'Shift + Enter',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Ctrl + Shift + Esc दबाने से सीधे Task Manager खुल जाता है। Ctrl + Alt + Del से भी खोला जा सकता है, लेकिन यह शॉर्टकट सबसे तेज है।',
  ),
  QuizQuestion(
    id: 'cit7',
    question: 'Copy करने के लिए कौन-सा Keyboard Shortcut है?',
    options: ['Ctrl + Z', 'Ctrl + X', 'Ctrl + V', 'Ctrl + C'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'Ctrl + C यूनिवर्सल शॉर्टकट है जिसका उपयोग टेक्स्ट, फाइल या फोल्डर को कॉपी करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit8',
    question: 'किस Mouse Action से File या Folder खुलता है?',
    options: ['Right-Click', 'Drag And Drop', 'Double-Click', 'Scroll'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'किसी फाइल या फोल्डर को खोलने के लिए उस पर डबल-क्लिक (Double-Click) किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit9',
    question: 'अगर USB Device Detect नहीं हो रहा है तो क्या करना चाहिए?',
    options: [
      'उसे फेंक दें',
      'Restart The Computer',
      'Volume बढ़ाएं',
      'Microsoft Word खोलें',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'USB डिवाइस डिटेक्ट न होने पर कंप्यूटर को रीस्टार्ट करना अक्सर इस समस्या का समाधान करता है क्योंकि यह ड्राइवर्स को रीलोड करता है।',
  ),
  QuizQuestion(
    id: 'cit10',
    question: 'कंप्यूटर को सही तरीके से Shut Down करना क्यों ज़रूरी है?',
    options: [
      'यह उसे तेज़ बना देता है।',
      'यह नए Apps Install करता है।',
      'यह File Corruption और Hardware Damage से बचाता है।',
      'यह Antivirus Software Update करता है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सही तरीके से Shut Down करने से फाइल करप्ट (File Corruption) होने और हार्डवेयर को नुकसान पहुंचने का खतरा नहीं होता है।',
  ),
  QuizQuestion(
    id: 'cit11',
    question:
        'Plain, Unformatted Text लिखने के लिए कौन सा Software Tool सबसे उपयुक्त है?',
    options: ['Wordpad', 'Notepad', 'Paint', 'Excel'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Notepad एक साधारण टेक्स्ट एडिटर है जो बिना किसी फॉर्मेटिंग (Plain/Unformatted) के टेक्स्ट लिखने के लिए सबसे उपयुक्त है।',
  ),
  QuizQuestion(
    id: 'cit12',
    question:
        'इनमें से कौन सा Tool Bold और Italics Formatting की सुविधा देता है?',
    options: ['Paint', 'Notepad', 'Wordpad', 'Cmd'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'WordPad एक रिच टेक्स्ट एडिटर है जो बोल्ड, इटैलिक, अंडरलाइन जैसी फॉर्मेटिंग सुविधाएं प्रदान करता है।',
  ),
  QuizQuestion(
    id: 'cit13',
    question: 'MS Paint का मुख्य उद्देश्य क्या है?',
    options: [
      'कोड लिखना',
      'चित्र बनाना और रंग भरना',
      'ईमेल भेजना',
      'दस्तावेज़ बनाना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'MS Paint एक बेसिक ग्राफिक्स एडिटिंग टूल है जिसका मुख्य उद्देश्य सरल चित्र बनाना और उनमें रंग भरना है।',
  ),
  QuizQuestion(
    id: 'cit14',
    question: 'इनमें से कौन सा Windows का Built-In Application नहीं है?',
    options: ['Notepad', 'Wordpad', 'Paint', 'Photoshop'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'Photoshop Adobe कंपनी का सॉफ्टवेयर है, जो Windows में बिल्ट-इन नहीं आता है। Notepad, Wordpad और Paint Windows के साथ ही आते हैं।',
  ),
  QuizQuestion(
    id: 'cit15',
    question:
        'Command Prompt में नया Folder बनाने के लिए कौन सा Command उपयोग होता है?',
    options: ['cd', 'dir', 'md', 'del'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Command Prompt में नया फोल्डर बनाने के लिए "md" (Make Directory) कमांड का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit16',
    question: 'Notepad से Save की गई फाइल का Extension क्या होता है?',
    options: ['.docx', '.rtf', '.txt', '.png'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Notepad से सेव की गई फाइलों का एक्सटेंशन .txt (टेक्स्ट फाइल) होता है।',
  ),
  QuizQuestion(
    id: 'cit17',
    question:
        'Paint में किसी क्षेत्र में रंग भरने के लिए कौन सा टूल उपयोग होता है?',
    options: ['Pencil', 'Fill', 'Eraser', 'Select'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'MS Paint में किसी बंद आकृति या क्षेत्र में रंग भरने के लिए "Fill with color" (बकेट) टूल का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit18',
    question: 'CMD में Dir Command का क्या कार्य है?',
    options: [
      'फाइल Delete करना',
      'फाइल और फोल्डर दिखाना',
      'फोल्डर का नाम बदलना',
      'विंडो बंद करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'CMD में "dir" (Directory) कमांड का उपयोग करंट डायरेक्ट्री में मौजूद सभी फाइलों और फोल्डरों की लिस्ट दिखाने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit19',
    question:
        'Text में Headings और रंग जोड़ने के लिए कौन सा Software सबसे अच्छा है?',
    options: ['Notepad', 'Wordpad', 'Paint', 'CMD'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'WordPad में आप टेक्स्ट में हेडिंग स्टाइल और रंग जोड़ सकते हैं, जबकि Notepad में यह सुविधा नहीं है।',
  ),
  QuizQuestion(
    id: 'cit20',
    question:
        'Windows में किसी फाइल या फोल्डर को खोलने के लिए कौन सी क्रिया की जाती है?',
    options: ['Right-Click', 'Single-Click', 'Double-Click', 'Drag And Drop'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Windows में किसी भी फाइल या फोल्डर को खोलने के लिए उस पर डबल-क्लिक (Double-Click) किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit21',
    question: 'Operating System का मुख्य कार्य क्या है?',
    options: [
      'म्यूजिक चलाना',
      'इंटरनेट से कनेक्ट करना',
      'Hardware और Software को Manage करना',
      'स्क्रीन को साफ़ करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑपरेटिंग सिस्टम (जैसे Windows, macOS) का मुख्य कार्य कंप्यूटर के हार्डवेयर और सॉफ्टवेयर संसाधनों को मैनेज करना है।',
  ),
  QuizQuestion(
    id: 'cit22',
    question: 'Windows Desktop पर Applications के Shortcut कहाँ मिलते हैं?',
    options: [
      'Task Manager',
      'Desktop Icons',
      'Control Panel',
      'File Explorer',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'एप्लीकेशन के शॉर्टकट (Icons) सीधे Windows Desktop पर मिलते हैं, जिन पर क्लिक करके एप खोले जा सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit23',
    question:
        'कौन सा Menu Programs और System Settings तक पहुँच प्रदान करता है?',
    options: ['Taskbar', 'Start Menu', 'Recycle Bin', 'Run Command'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Start Menu (स्टार्ट मेन्यू) Windows का केंद्रीय हब है, जहाँ से सभी प्रोग्राम्स, फोल्डर्स और सिस्टम सेटिंग्स तक पहुँचा जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit24',
    question: 'Taskbar का मुख्य कार्य क्या है?',
    options: [
      'Wallpaper दिखाना',
      'Printer Settings करना',
      'खुले हुए Applications और Notifications दिखाना',
      'केवल Antivirus Alerts',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Taskbar (टास्कबार) आमतौर पर स्क्रीन के नीचे होता है, जो वर्तमान में खुले हुए एप्लिकेशन और नोटिफिकेशन दिखाता है।',
  ),
  QuizQuestion(
    id: 'cit25',
    question: 'Windows में Personalisation Settings कैसे खोलते हैं?',
    options: [
      'BIOS के माध्यम से',
      'Recycle Bin पर Double-Click करके',
      'Desktop पर Right-Click → Personalise',
      'Microsoft Word में टाइप करके',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Desktop पर खाली जगह राइट-क्लिक करके "Personalise" विकल्प चुनने से थीम, बैकग्राउंड और कलर सेटिंग्स खुलती हैं।',
  ),
  QuizQuestion(
    id: 'cit26',
    question: 'कौन सा Mode आँखों के तनाव को कम करता है?',
    options: ['Sleep Mode', 'Safe Mode', 'Dark Mode', 'High Contrast Mode'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डार्क मोड (Dark Mode) स्क्रीन की चमक कम करता है और डार्क थीम प्रदान करता है, जिससे कम रोशनी में आंखों का तनाव कम होता है।',
  ),
  QuizQuestion(
    id: 'cit27',
    question: 'Screen Resolution बदलने से क्या प्रभावित होता है?',
    options: [
      'इंटरनेट स्पीड',
      'साउंड क्वालिटी',
      'डिस्प्ले की Sharpness',
      'कीबोर्ड लेआउट',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Screen Resolution (स्क्रीन रेजोल्यूशन) बदलने से टेक्स्ट और इमेजेज की शार्पनेस और साफ-सफाई प्रभावित होती है।',
  ),
  QuizQuestion(
    id: 'cit28',
    question:
        'कौन सी Setting, Text और Apps का आकार बढ़ाती है बिना Resolution बदलें?',
    options: ['Refresh Rate', 'Brightness', 'Scaling', 'DPI Reset'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'स्केलिंग (Scaling) सेटिंग रेजोल्यूशन बदले बिना टेक्स्ट और एप्लीकेशन के आकार को बड़ा या छोटा करती है।',
  ),
  QuizQuestion(
    id: 'cit29',
    question: 'अगर Wi-Fi पर कोई पेज धीरे लोड हो रहा हो, तो क्या करना चाहिए?',
    options: [
      'पेज को रीफ्रेश करें',
      'राउटर के पास जाएं',
      'मोबाइल डाटा बंद करें',
      'मोडेम को अनप्लग करें',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Wi-Fi सिग्नल कमजोर होने पर राउटर के करीब जाने से सिग्नल मजबूत हो सकता है और पेज लोडिंग स्पीड बढ़ सकती है।',
  ),
  QuizQuestion(
    id: 'cit30',
    question: 'निम्न में से कौन एक वैध (Valid) URL का उदाहरण है?',
    options: [
      'Google@com',
      'www_google_com',
      'https://www.google.com',
      'http//Google',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'https://www.google.com एक वैध URL है क्योंकि यह प्रोटोकॉल (https), सबडोमेन (www) और डोमेन नाम (google.com) के सही फॉर्मेट में है।',
  ),
  QuizQuestion(
    id: 'cit31',
    question: 'File का उपयोग किसलिए किया जाता है?',
    options: [
      'Desktop सजाने के लिए',
      'Text, Images या Videos को स्टोर करने के लिए',
      'Internet खोलने के लिए',
      'Mouse को कंट्रोल करने के लिए',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'फाइल (File) एक डिजिटल कंटेनर है जिसका उपयोग टेक्स्ट, इमेज, वीडियो या अन्य डाटा को स्टोर करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit32',
    question:
        'किसका उपयोग कई Files को एक साथ व्यवस्थित करने के लिए किया जाता है?',
    options: ['Toolbar', 'Mouse', 'Folder', 'Icon'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फोल्डर (Folder/Directory) का उपयोग संबंधित फाइलों को एक साथ रखकर व्यवस्थित करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit33',
    question: 'Windows में File का नाम बदलने का सही तरीका क्या है?',
    options: [
      'Double-Click करके Delete करना',
      'File को किसी और Folder में Drag करना',
      'Right-Click > Rename',
      'Ctrl + R दबाना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फाइल या फोल्डर पर राइट-क्लिक करके "Rename" विकल्प चुनना नाम बदलने का सही और आम तरीका है।',
  ),
  QuizQuestion(
    id: 'cit34',
    question: 'File Delete करने के बाद कहाँ जाती है?',
    options: ['Control Panel', 'Settings', 'Recycle Bin', 'Taskbar'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Windows में डिलीट की गई फाइलें पहले "Recycle Bin" (रिसायकल बिन) में जाती हैं, जहाँ से उन्हें रिस्टोर किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit35',
    question: 'Files को व्यवस्थित करने का आसान तरीका क्या है?',
    options: [
      '"Untitled1" जैसे नामों का उपयोग करें',
      'सभी Files को Desktop पर Save करें',
      'Files को स्पष्ट नाम वाले Folders में Group करें',
      'पुरानी Files कभी Delete न करें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फाइलों को स्पष्ट और सार्थक नामों वाले फोल्डरों में रखना उन्हें व्यवस्थित और आसानी से खोजने योग्य बनाता है।',
  ),
  QuizQuestion(
    id: 'cit36',
    question: 'Zip File का उपयोग किसलिए किया जाता है?',
    options: [
      'Software Update के लिए',
      'File Size कम करने और Multiple Files को Group करने के लिए',
      'Antivirus Install करने के लिए',
      'Files को Password से Protect करने के लिए',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'ZIP फाइल का उपयोग एक या एक से अधिक फाइलों को कंप्रेस (File Size कम) करके एक साथ ग्रुप करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit37',
    question: 'Zip File से Content कैसे निकाला जाता है?',
    options: [
      'Right-Click > Extract All',
      'Power Button दबाकर',
      'उसे Desktop पर Move करके',
      'Double-Click करके Delete करके',
    ],
    correctIndex: 0,
    subject: 'BS-CIT',
    description:
        'ZIP फाइल पर राइट-क्लिक करके "Extract All" विकल्प चुनने से उसकी कंटेंट बाहर निकाली (Unzip) जा सकती है।',
  ),
  QuizQuestion(
    id: 'cit38',
    question: 'निम्न में से कौन सा Local Storage का उदाहरण है?',
    options: ['Google Drive', 'Dropbox', 'Hard Disk Drive', 'Onedrive'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'हार्ड डिस्क ड्राइव (Hard Disk Drive) आपके कंप्यूटर में लगा एक फिजिकल स्टोरेज डिवाइस है, जो लोकल स्टोरेज का उदाहरण है।',
  ),
  QuizQuestion(
    id: 'cit39',
    question:
        'कौन-सी Storage Internet से किसी भी डिवाइस से Access की जा सकती है?',
    options: ['Local Storage', 'USB Drive', 'Cloud Storage', 'Control Panel'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'क्लाउड स्टोरेज (Cloud Storage) इंटरनेट पर स्थित होता है, जिसे किसी भी डिवाइस और कहीं से भी एक्सेस किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit40',
    question: 'Local Storage का एक नुकसान क्या है?',
    options: [
      'हमेशा Internet की ज़रूरत होती है',
      'कोई भी Space नहीं लेता',
      'Device Damage होने पर Data Lost हो सकता है',
      'कहीं से भी Access किया जा सकता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'लोकल स्टोरेज (जैसे हार्ड डिस्क) का सबसे बड़ा नुकसान यह है कि यदि डिवाइस खराब या क्षतिग्रस्त हो जाए, तो डाटा हमेशा के लिए लॉस्ट हो सकता है।',
  ),
  QuizQuestion(
    id: 'cit41',
    question: 'इंटरनेट क्या है?',
    options: [
      'एक लोकल नेटवर्क',
      'एक मैसेजिंग ऐप',
      'जुड़े हुए डिवाइसों का एक वैश्विक नेटवर्क',
      'एक कंप्यूटर प्रोग्राम',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'इंटरनेट दुनिया भर में फैले कंप्यूटरों और डिवाइसों का एक विशाल वैश्विक नेटवर्क है, जो आपस में जुड़े होते हैं।',
  ),
  QuizQuestion(
    id: 'cit42',
    question: 'एक राउटर आपके डिवाइस को किससे जोड़ता है?',
    options: [
      'मॉनिटर',
      'Isp (Internet Service Provider)',
      'कीबोर्ड',
      'स्क्रीन',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'राउटर (Router) आपके होम नेटवर्क को ISP (इंटरनेट सर्विस प्रोवाइडर) से जोड़ता है, जिससे इंटरनेट का कनेक्शन मिलता है।',
  ),
  QuizQuestion(
    id: 'cit43',
    question: 'निम्न में से कौन एक वायरलेस इंटरनेट कनेक्शन का तरीका है?',
    options: ['DSL', 'Ethernet', 'Wi-Fi', 'USB केबल'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Wi-Fi एक वायरलेस तकनीक है जिसका उपयोग बिना केबल के इंटरनेट से जुड़ने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit44',
    question: 'इनमें से कौन सा कारक इंटरनेट की गति को प्रभावित नहीं करता है?',
    options: [
      'उपयोगकर्ताओं की संख्या',
      'सिग्नल की ताकत',
      'कनेक्शन का प्रकार',
      'स्क्रीन की ब्राइटनेस',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'स्क्रीन की ब्राइटनेस का इंटरनेट की स्पीड पर कोई प्रभाव नहीं पड़ता है।',
  ),
  QuizQuestion(
    id: 'cit45',
    question: 'URL में https क्या दर्शाता है?',
    options: [
      'यह एक विज्ञापन है',
      'साइट सुरक्षित है',
      'यह एक समाचार साइट है',
      'यह धीरे लोड होती है',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'URL में "https" (Hypertext Transfer Protocol Secure) दर्शाता है कि वेबसाइट और आपके ब्राउज़र के बीच का कनेक्शन एन्क्रिप्टेड और सुरक्षित है।',
  ),
  QuizQuestion(
    id: 'cit46',
    question: 'किसी भरोसेमंद वेबसाइट की पहचान करने का एक अच्छा तरीका क्या है?',
    options: [
      '.xyz डोमेन',
      'लेखक का नाम नहीं होना',
      '.gov या .edu डोमेन',
      'बहुत चमकदार डिजाइन',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        '.gov (सरकार) और .edu (शिक्षा) डोमेन आमतौर पर अधिक भरोसेमंद और प्रमाणित स्रोत होते हैं।',
  ),
  QuizQuestion(
    id: 'cit47',
    question: 'URL का कौन सा भाग डोमेन नाम को दर्शाता है?',
    options: ['https://', 'www', 'Wikipedia.org', '.com'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'URL में "wikipedia.org" डोमेन नाम है, जो वेबसाइट की यूनिक पहचान होती है।',
  ),
  QuizQuestion(
    id: 'cit48',
    question: 'Google सर्च में कोटेशन मार्क्स (" ") का क्या उद्देश्य होता है?',
    options: [
      'इमेज जोड़ने के लिए',
      'Pdf खोजने के लिए',
      'बिल्कुल वैसी ही वाक्यांशों की सर्च करने के लिए',
      'कुछ शब्दों को सर्च से बाहर करने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'कोटेशन मार्क्स (" ") का उपयोग करने पर Google उन शब्दों को एक सटीक वाक्यांश (Exact Phrase) के रूप में खोजता है।',
  ),
  QuizQuestion(
    id: 'cit49',
    question: 'अगर Wi-Fi पर कोई पेज धीरे लोड हो रहा हो, तो क्या करना चाहिए?',
    options: [
      'पेज को रीफ्रेश करें',
      'राउटर के पास जाएं',
      'मोबाइल डाटा बंद करें',
      'मोडेम को अनप्लग करें',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Wi-Fi सिग्नल कमजोर होने पर राउटर के करीब जाने से सिग्नल मजबूत हो सकता है और पेज लोडिंग स्पीड बढ़ सकती है।',
  ),
  QuizQuestion(
    id: 'cit50',
    question: 'निम्न में से कौन एक वैध (Valid) URL का उदाहरण है?',
    options: [
      'Google@com',
      'www_google_com',
      'https://www.google.com',
      'http//Google',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'https://www.google.com एक वैध URL है क्योंकि यह प्रोटोकॉल (https), सबडोमेन (www) और डोमेन नाम (google.com) के सही फॉर्मेट में है।',
  ),
  QuizQuestion(
    id: 'cit51',
    question: 'Search Engine का मुख्य कार्य क्या है?',
    options: [
      'वेबसाइट बनाना',
      'मोबाइल ऐप्स को रैंक करना',
      'इंटरनेट पर जानकारी खोजने में मदद करना',
      'कंप्यूटर को वायरस से सुरक्षित रखना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सर्च इंजन (जैसे Google, Bing) का मुख्य कार्य यूजर्स को इंटरनेट पर मौजूद जानकारी को खोजने में मदद करना है।',
  ),
  QuizQuestion(
    id: 'cit52',
    question: 'इनमें से कौन एक लोकप्रिय Search Engine है?',
    options: ['Facebook', 'Google', 'Excel', 'Windows'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description: 'Google दुनिया का सबसे लोकप्रिय सर्च इंजन है।',
  ),
  QuizQuestion(
    id: 'cit53',
    question: 'वेबसाइटों को स्कैन करने की प्रक्रिया क्या कहलाती है?',
    options: ['Filtering', 'Indexing', 'Crawling', 'Ranking'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'वेबसाइटों को स्कैन करके उनका डाटा इकट्ठा करने की प्रक्रिया को "Crawling" (क्रॉलिंग) कहते हैं।',
  ),
  QuizQuestion(
    id: 'cit54',
    question: 'एक ही Query के लिए दो लोगों को अलग परिणाम क्यों मिलते हैं?',
    options: [
      'स्क्रीन का आकार अलग होता है',
      'Keyboard अलग होता है',
      'Location और Search History',
      'Browser थीम',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सर्च इंजन परिणामों को प्रभावित करने के लिए यूजर की लोकेशन और सर्च हिस्ट्री जैसे कारकों का उपयोग करते हैं।',
  ),
  QuizQuestion(
    id: 'cit55',
    question: 'कौन सा Google Feature समाचार खोजने में मदद करता है?',
    options: ['Google Maps', 'Google News Tab', 'Gmail', 'Google Forms'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google का "News" टैब विशेष रूप से विभिन्न स्रोतों से नवीनतम समाचार और लेख खोजने के लिए डिज़ाइन किया गया है।',
  ),
  QuizQuestion(
    id: 'cit56',
    question: 'किसी चित्र की असली जानकारी जानने के लिए कौन सा Tool काम आता है?',
    options: [
      'Google Translate',
      'Google Slides',
      'Reverse Image Search',
      'Google Calendar',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Reverse Image Search (रिवर्स इमेज सर्च) आपको किसी चित्र के बारे में असली जानकारी, जैसे उसका स्रोत या समान चित्र, खोजने में मदद करता है।',
  ),
  QuizQuestion(
    id: 'cit57',
    question: 'इनमें से कौन सी वेबसाइट Copyright-Free Images देती है?',
    options: ['Netflix', 'Amazon', 'Unsplash', 'Wikipedia'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Unsplash एक लोकप्रिय वेबसाइट है जो हाई-क्वालिटी, कॉपीराइट-फ्री इमेजेज प्रदान करती है जिनका उपयोग बिना अनुमति के किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit58',
    question: 'किसी Phrase को Quotes (" ") में लिखने से क्या होता है?',
    options: [
      'केवल Images मिलती हैं',
      'Exact Phrase के लिए Search होता है',
      'Duplicates हटते हैं',
      'Text Highlight होता है',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Quotes में लिखे phrase की एक्सैक्ट (सटीक) मैचिंग सर्च होती है।',
  ),
  QuizQuestion(
    id: 'cit59',
    question: 'कौन सा Search Operator किसी शब्द को Exclude करता है?',
    options: ['+', '#', '-', '/'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'माइनस साइन (-) एक सर्च ऑपरेटर है जिसका उपयोग किसी विशेष शब्द को सर्च परिणामों से बाहर करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit60',
    question: 'Site Operator का उपयोग किस लिए होता है?',
    options: [
      'वेबसाइट खोलने के लिए',
      'किसी विशेष साइट से परिणाम खोजने के लिए',
      'पेज सेव करने के लिए',
      'इंटरनेट स्पीड चेक करने के लिए',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'site: ऑपरेटर का उपयोग सर्च को एक विशिष्ट वेबसाइट या डोमेन तक सीमित करने के लिए किया जाता है (जैसे, site:wikipedia.org)।',
  ),
  QuizQuestion(
    id: 'cit61',
    question: 'Phishing क्या है?',
    options: [
      'इंटरनेट स्पीड बढ़ाना',
      'नकली E-mails या Websites से जानकारी चुराना',
      'Antivirus इंस्टॉल करना',
      'Browser अपडेट करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'फिशिंग एक साइबर अटैक है जिसमें हमलावर नकली ईमेल या वेबसाइट बनाकर पासवर्ड और क्रेडिट कार्ड नंबर जैसी संवेदनशील जानकारी चुराते हैं।',
  ),
  QuizQuestion(
    id: 'cit62',
    question: 'एक सुरक्षित Website की पहचान कैसे करें?',
    options: [
      'उसका नाम बहुत लंबा हो',
      'उसमें केवल Images हों',
      'URL में https हो',
      'Password के बिना खुले',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'URL की शुरुआत में "https" होना और एड्रेस बार में लॉक आइकन दिखना एक सुरक्षित वेबसाइट की पहचान है।',
  ),
  QuizQuestion(
    id: 'cit63',
    question: 'Chrome में Safe Browsing कैसे ऑन करें?',
    options: [
      'Extensions के जरिए',
      'Privacy & Security Settings में',
      'Desktop Settings में',
      'Device Manager से',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Chrome में Safe Browsing को Privacy and Security सेटिंग्स में जाकर चालू किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit64',
    question: 'SSL Certificate का कार्य क्या है?',
    options: [
      'Website को रंगीन बनाना',
      'इंटरनेट स्पीड बढ़ाना',
      'Website को सुरक्षित बनाना और डाटा की रक्षा करना',
      'Pop-Ups दिखाना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'SSL सर्टिफिकेट वेबसाइट और यूजर के ब्राउज़र के बीच डाटा को एन्क्रिप्ट करता है, जिससे हैकर्स उसे पढ़ नहीं पाते और वेबसाइट सुरक्षित हो जाती है।',
  ),
  QuizQuestion(
    id: 'cit65',
    question: 'Fake News से बचने के लिए क्या करना चाहिए?',
    options: [
      'सिर्फ WhatsApp मैसेज पर भरोसा करें',
      'Clickbait Headlines को मान लें',
      'भरोसेमंद स्रोतों से Cross-Check करें',
      'बिना पढ़े शेयर करें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फेक न्यूज से बचने का सबसे अच्छा तरीका विभिन्न विश्वसनीय और आधिकारिक स्रोतों से जानकारी को क्रॉस-चेक करना है।',
  ),
  QuizQuestion(
    id: 'cit66',
    question: 'इनमें से कौन Safe Browsing फीचर नहीं है?',
    options: [
      'खतरनाक Websites को Block करना',
      'Enhanced Protection को Enable करना',
      'Auto-Play Videos',
      'Tracking को Disable करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑटो-प्ले वीडियो एक सुविधा है, न कि सुरक्षित ब्राउज़िंग फीचर। बाकी सभी विकल्प सुरक्षा बढ़ाने से जुड़े हैं।',
  ),
  QuizQuestion(
    id: 'cit67',
    question: 'Scam होने पर आपको क्या करना चाहिए?',
    options: [
      'कुछ न करें',
      'Bank को Inform करें और Password बदलें',
      'इंटरनेट बंद कर दें',
      'फ़ोन Format कर दें',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'स्कैम होने पर तुरंत बैंक को सूचित करना और अपने सभी पासवर्ड बदल देना चाहिए ताकि आगे के नुकसान से बचा जा सके।',
  ),
  QuizQuestion(
    id: 'cit68',
    question: 'Website असुरक्षित कब मानी जा सकती है?',
    options: [
      'उसमें SSL Certificate न हो',
      'उसमें सुंदर तस्वीरें हों',
      'उसमें "Contact Us" पेज हो',
      'वह Search Engine में दिखे',
    ],
    correctIndex: 0,
    subject: 'BS-CIT',
    description:
        'जिस वेबसाइट पर SSL सर्टिफिकेट नहीं होता (URL http:// से शुरू होता है), उसे असुरक्षित माना जाता है क्योंकि डाटा एन्क्रिप्ट नहीं होता।',
  ),
  QuizQuestion(
    id: 'cit69',
    question: 'भारत में साइबर अपराध की रिपोर्ट कहाँ करें?',
    options: ['upsc.gov.in', 'cybercrime.gov.in', 'irctc.co.in', 'mail.gov.in'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'भारत में साइबर अपराध की ऑनलाइन शिकायत करने के लिए आधिकारिक पोर्टल cybercrime.gov.in है।',
  ),
  QuizQuestion(
    id: 'cit70',
    question: 'Duckduckgo Search Engine की मुख्य विशेषता क्या है?',
    options: [
      'केवल Videos दिखाता है',
      'केवल Games खोजता है',
      'Privacy पर Focus करता है और Tracking नहीं करता',
      'केवल सरकारी Websites दिखाता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'DuckDuckGo की मुख्य विशेषता यूजर की प्राइवेसी पर फोकस करना है; यह यूजर के सर्च हिस्ट्री को ट्रैक या स्टोर नहीं करता है।',
  ),
  QuizQuestion(
    id: 'cit71',
    question: 'Aadhaar का उद्देश्य क्या है?',
    options: [
      'इंटरनेट का उपयोग ट्रैक करना',
      'बैंक पासवर्ड स्टोर करना',
      'नागरिकों को यूनिक पहचान नंबर देना',
      'सोशल मीडिया निगरानी',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'आधार (Aadhaar) भारत सरकार द्वारा नागरिकों को दी जाने वाली एक यूनिक 12-अंकीय पहचान संख्या है।',
  ),
  QuizQuestion(
    id: 'cit72',
    question: 'PAN का पूरा नाम क्या है?',
    options: [
      'Personal Area Network',
      'Public Access Number',
      'Permanent Account Number',
      'Private Access Node',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'PAN का पूरा नाम Permanent Account Number है, जो आयकर विभाग द्वारा जारी एक यूनिक पहचान संख्या है।',
  ),
  QuizQuestion(
    id: 'cit73',
    question: 'किस प्लेटफ़ॉर्म पर डिजिटल डॉक्यूमेंट्स सुरक्षित रखे जाते हैं?',
    options: ['UMANG', 'DigiLocker', 'IRCTC', 'Paytm'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'DigiLocker भारत सरकार का एक प्लेटफॉर्म है जो नागरिकों को ड्राइविंग लाइसेंस, रजिस्ट्रेशन सर्टिफिकेट आदि जैसे डिजिटल दस्तावेज़ सुरक्षित रूप से स्टोर करने की सुविधा देता है।',
  ),
  QuizQuestion(
    id: 'cit74',
    question: 'UMANG ऐप का उपयोग किसलिए होता है?',
    options: [
      'गेम खेलने के लिए',
      'एक ही ऐप से सरकारी सेवाएँ प्राप्त करने के लिए',
      'केवल रेलवे टिकट बुकिंग के लिए',
      'SMS भेजने के लिए',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'UMANG (Unified Mobile Application for New-age Governance) एक एकीकृत ऐप है जो विभिन्न सरकारी सेवाओं (जैसे पेंशन, पैन, पासपोर्ट) तक पहुंच प्रदान करता है।',
  ),
  QuizQuestion(
    id: 'cit75',
    question: 'सरकारी नौकरी की सूचना कहाँ मिलेगी?',
    options: ['YouTube', 'WhatsApp', 'SSC या UPSC वेबसाइट्स', 'Facebook'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सरकारी नौकरियों (जैसे SSC, UPSC, Banking) की आधिकारिक सूचना और अपडेट संबंधित आयोगों की आधिकारिक वेबसाइटों पर मिलती है।',
  ),
  QuizQuestion(
    id: 'cit76',
    question: 'सरकारी नौकरी के लिए ऑनलाइन आवेदन का पहला चरण क्या है?',
    options: [
      'पहले परीक्षा देना',
      'पोर्टल पर पंजीकरण और आवेदन भरना',
      'पुलिस स्टेशन जाना',
      'साइबर कैफ़े जाना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'सरकारी नौकरी के लिए ऑनलाइन आवेदन करने से पहले संबंधित पोर्टल (जैसे SSC या UPSC) पर रजिस्ट्रेशन करके आवेदन फॉर्म भरना आवश्यक होता है।',
  ),
  QuizQuestion(
    id: 'cit77',
    question: 'Aadhaar को ऑनलाइन सुरक्षित रखने के लिए क्या करना चाहिए?',
    options: [
      'दोस्तों से साझा करना',
      'सोशल मीडिया पर पोस्ट करना',
      'Masked Aadhaar का उपयोग और बायोमेट्रिक लॉक करना',
      'ईमेल ड्राफ्ट में सेव करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'आधार को सुरक्षित रखने के लिए मास्क्ड आधार (Masked Aadhaar) का उपयोग करना चाहिए और UIDAI पोर्टल पर जाकर बायोमेट्रिक लॉक ऑन करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit78',
    question: 'DigiLocker का एक लाभ क्या है?',
    options: [
      'इंटरनेट स्पीड बढ़ाता है',
      'ऑनलाइन गेम्स देता है',
      'डॉक्यूमेंट्स डिजिटल रूप में सुरक्षित रखता है',
      'SIM कार्ड को बदल देता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'DigiLocker का मुख्य लाभ यह है कि यह आपके महत्वपूर्ण दस्तावेजों (जैसे ड्राइविंग लाइसेंस, शैक्षिक प्रमाणपत्र) को डिजिटल और सुरक्षित रूप से स्टोर करता है।',
  ),
  QuizQuestion(
    id: 'cit79',
    question: 'केंद्रीय सरकारी योजनाएँ कहाँ खोजी जा सकती हैं?',
    options: ['india.gov.in', 'amazon.in', 'myntra.com', 'flipkart.com'],
    correctIndex: 0,
    subject: 'BS-CIT',
    description:
        'भारत सरकार की विभिन्न योजनाओं और सेवाओं के बारे में जानकारी india.gov.in (नेशनल पोर्टल ऑफ इंडिया) पर उपलब्ध है।',
  ),
  QuizQuestion(
    id: 'cit80',
    question: 'Aadhaar को ऑनलाइन लॉक करने का उद्देश्य क्या है?',
    options: [
      'उसे अहश्य बनाना',
      'बायोमेट्रिक डाटा के दुरुपयोग को रोकना',
      'Aadhaar नंबर हटाना',
      'सभी के लिए उपलब्ध कराना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'आधार को ऑनलाइन लॉक करने से किसी भी तीसरे पक्ष के लिए आपके बायोमेट्रिक डाटा (फिंगरप्रिंट, आईरिस) का उपयोग करना असंभव हो जाता है, जिससे दुरुपयोग रुकता है।',
  ),
  QuizQuestion(
    id: 'cit81',
    question: 'डिजिटल लर्निंग प्लेटफ़ॉर्म का मुख्य लाभ क्या है?',
    options: [
      'ये शिक्षकों को पूरी तरह बदल देते हैं',
      'कभी भी, कहीं भी सीखने की सुविधा देते हैं',
      'केवल सरकारी कर्मचारियों के लिए होते हैं',
      'इंटरनेट की आवश्यकता नहीं होती है',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल लर्निंग प्लेटफॉर्म (जैसे Coursera, Khan Academy) का सबसे बड़ा लाभ यह है कि आप कभी भी और कहीं भी (Anywhere, Anytime) सीख सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit82',
    question: 'निम्न में से कौन सा Self-Paced Learning फॉर्मैट है?',
    options: [
      'Live क्लासरूम सेशन',
      'In-Person वर्कशॉप',
      'Recorded वीडियो कोर्स',
      'Group Discussion',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Recorded वीडियो कोर्स सेल्फ-पेस्ड लर्निंग का एक उदाहरण है, जहां आप अपनी गति से सीख सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit83',
    question: 'OER का पूरा रूप क्या है?',
    options: [
      'Online Educational Records',
      'Open Educational Resources',
      'Official Exam References',
      'Organised Education Resources',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'OER का पूरा रूप Open Educational Resources है। ये निःशुल्क शैक्षिक सामग्री होती हैं।',
  ),
  QuizQuestion(
    id: 'cit84',
    question: 'इनमें से कौन सा ऑनलाइन लर्निंग संसाधन नहीं है?',
    options: [
      'E-Books',
      'Video Lectures',
      'Printed Newspapers',
      'Online Courses',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'प्रिंटेड समाचार पत्र (Printed Newspapers) एक ऑफलाइन या फिजिकल संसाधन है, जबकि अन्य सभी ऑनलाइन लर्निंग संसाधन हैं।',
  ),
  QuizQuestion(
    id: 'cit85',
    question: 'OERs के उपयोग का एक मुख्य लाभ क्या है?',
    options: [
      'ये निजी और पेड होते हैं',
      'केवल यूनिवर्सिटी छात्रों के लिए होते हैं',
      'ये सभी के लिए नि:शुल्क उपलब्ध होते हैं',
      'केवल वीकेंड पर उपलब्ध होते हैं',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'OER (Open Educational Resources) का मुख्य लाभ यह है कि ये सभी के लिए निःशुल्क उपलब्ध होते हैं।',
  ),
  QuizQuestion(
    id: 'cit86',
    question: 'ऑनलाइन अध्ययन सामग्री डाउनलोड करने से पहले क्या जांचना चाहिए?',
    options: [
      'वो रंगीन है या नहीं?',
      'वेबसाइट जूते बेचती है या नहीं?',
      'सामग्री भरोसेमंद और कानूनी स्रोत से है या नहीं?',
      'वह प्रिंटेड बुक में उपलब्ध है या नहीं?',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑनलाइन सामग्री डाउनलोड करते समय यह सुनिश्चित करना चाहिए कि वह किसी विश्वसनीय और कानूनी स्रोत (जैसे सरकारी वेबसाइट, मान्यता प्राप्त शिक्षण पोर्टल) से हो।',
  ),
  QuizQuestion(
    id: 'cit87',
    question:
        'कौन सा प्लेटफ़ॉर्म भारतीय शैक्षिक सामग्री तक नि:शुल्क और वैध पहुंच देता है?',
    options: ['Instagram', 'Swayam', 'Netflix', 'Flipkart'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'SWAYAM भारत सरकार का एक ऑनलाइन प्लेटफॉर्म है जो निःशुल्क शैक्षिक पाठ्यक्रम प्रदान करता है।',
  ),
  QuizQuestion(
    id: 'cit88',
    question:
        'कौन सा लर्निंग फॉर्मेट शिक्षक के इंटरएक्शन और निर्धारित समय पर आधारित होता है?',
    options: [
      'Self-Paced कोर्स',
      'Instructor-Led कोर्स',
      'E-Book पढ़ना',
      'Podcast सुनना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Instructor-Led कोर्स (जैसे लाइव क्लास या वेबिनार) एक शिक्षक के मार्गदर्शन और एक निर्धारित समय-सारणी पर आधारित होता है।',
  ),
  QuizQuestion(
    id: 'cit89',
    question:
        'डाउनलोड की गई अध्ययन सामग्री को संगठित करने का एक अच्छा अभ्यास क्या है?',
    options: [
      'डेस्कटॉप पर सब कुछ बेतरतीब सेव करना',
      'विषय या टॉपिक के अनुसार फोल्डर बनाना',
      'सबको "New" नाम देना',
      'कुछ भी सेव न करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डाउनलोड की गई फाइलों को विषय या टॉपिक के अनुसार अलग-अलग फोल्डरों में रखना एक अच्छा अभ्यास है।',
  ),
  QuizQuestion(
    id: 'cit90',
    question:
        'डिजिटल लर्निंग संसाधनों के उपयोग में कॉपीराइट जागरूकता क्यों ज़रूरी है?',
    options: [
      'इससे पैसा कमाया जा सकता है',
      'इससे इंटरनेट का उपयोग नहीं करना पड़ता है',
      'इससे सामग्री का कानूनी और नैतिक उपयोग सुनिश्चित होता है',
      'ये केवल लॉ छात्रों के लिए है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'कॉपीराइट जागरूकता यह सुनिश्चित करने के लिए जरूरी है कि आप सामग्री का उपयोग कानूनी और नैतिक रूप से कर रहे हैं, जिससे कॉपीराइट उल्लंघन से बचा जा सके।',
  ),
  QuizQuestion(
    id: 'cit91',
    question: 'Structured Online Learning क्या है?',
    options: [
      'Social Media पोस्ट्स से सीखना',
      'बिना योजना के सीखना',
      'तय Syllabus और Timeline के साथ सीखना',
      'Entertainment Videos देखना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'स्ट्रक्चर्ड ऑनलाइन लर्निंग (Structured Online Learning) का मतलब एक निर्धारित पाठ्यक्रम (Syllabus) और समय-सीमा (Timeline) के साथ सीखना है।',
  ),
  QuizQuestion(
    id: 'cit92',
    question: 'Smart Learning Goal का क्या अर्थ है?',
    options: [
      'Simple, Measured, Accurate, Realistic, Timely',
      'Specific, Measurable, Achievable, Relevant, Time-Bound',
      'Strategic, Motivated, Active, Regular, Timed',
      'Short, Medium, Agile, Reliable, Targeted',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Smart Learning Goal का मतलब Specific, Measurable, Achievable, Relevant, और Time-Bound लक्ष्य निर्धारित करना है।',
  ),
  QuizQuestion(
    id: 'cit93',
    question: 'Industry Value वाले Course की पहचान कैसे की जाती है?',
    options: [
      'Instructor मज़ेदार हो',
      'Celebrity के Ads हों',
      'Accreditation और मान्यता प्राप्त Certificate हो',
      'Short Video हो',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'इंडस्ट्री वैल्यू वाले कोर्स की पहचान मान्यता प्राप्त (Accredited) और इंडस्ट्री में स्वीकृत प्रमाणपत्र से की जाती है।',
  ),
  QuizQuestion(
    id: 'cit94',
    question: 'कौन सा Platform College-Level Free Courses देता है?',
    options: ['Facebook', 'Coursera (Audit Mode)', 'Instagram', 'IRCTC'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Coursera एक ऑनलाइन प्लेटफॉर्म है जो Audit Mode में कॉलेज-लेवल के कई कोर्सेज को मुफ्त में एक्सेस करने की सुविधा देता है।',
  ),
  QuizQuestion(
    id: 'cit95',
    question: 'Math और Science के लिए कौन सा Platform जाना जाता है?',
    options: ['Khan Academy', 'Netflix', 'Spotify', 'Reddit'],
    correctIndex: 0,
    subject: 'BS-CIT',
    description:
        'Khan Academy एक लोकप्रिय नॉन-प्रॉफिट प्लेटफॉर्म है जो गणित और विज्ञान सहित कई विषयों में मुफ्त शिक्षा प्रदान करता है।',
  ),
  QuizQuestion(
    id: 'cit96',
    question: 'सही Online Course चुनने का सबसे अच्छा तरीका क्या है?',
    options: [
      'सबसे महँगा चुनें',
      'Memes देखें',
      'Reviews, Relevance और Certificate देखें',
      'Shortest Video चुनें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सही ऑनलाइन कोर्स चुनने के लिए आपको उसके Reviews (समीक्षाएँ), Relevance (प्रासंगिकता) और Certificate (प्रमाणपत्र) की जांच करनी चाहिए।',
  ),
  QuizQuestion(
    id: 'cit97',
    question: 'नई भाषा सीखने के लिए लोकप्रिय ऐप कौन सा है?',
    options: ['Amazon', 'Duolingo', 'Flipkart', 'Zoom'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Duolingo एक लोकप्रिय भाषा सीखने वाला ऐप है जो गेमिफिकेशन (gamification) तकनीक का उपयोग करता है।',
  ),
  QuizQuestion(
    id: 'cit98',
    question: 'Youtube से सीखते समय Best Practice क्या है?',
    options: [
      'जो सामने आए, देख लें',
      'Playlist Skip करें',
      'Educational Channel Follow करें और Learning Plan बनाएं',
      'केवल Music Videos देखें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'YouTube से सीखने का सबसे अच्छा तरीका एजुकेशनल चैनल्स को फॉलो करना और एक निर्धारित लर्निंग प्लान बनाना है।',
  ),
  QuizQuestion(
    id: 'cit99',
    question: 'Self-Paced Course क्या है?',
    options: [
      'Instructor-Led Course',
      'Live Webinar',
      'अपनी गति से सीखने वाला Course',
      'Group Classroom Session',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सेल्फ-पेस्ड कोर्स वह कोर्स होता है जिसमें आप अपनी सुविधानुसार गति से सीख सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit100',
    question: 'Free Learning Platforms का मुख्य लाभ क्या है?',
    options: [
      'बड़ी Payment चाहिए',
      'केवल Paid Members को Access',
      'Free और Accessible Education',
      'केवल Entertainment Content',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फ्री लर्निंग प्लेटफॉर्म (जैसे Khan Academy, SWAYAM) का मुख्य लाभ यह है कि ये मुफ्त और सुलभ शिक्षा प्रदान करते हैं।',
  ),
  QuizQuestion(
    id: 'cit101',
    question: 'नया ईमेल खाता बनाने का पहला चरण क्या है?',
    options: [
      'ईमेल लिखना शुरू करें',
      'फ़ोल्डर सेट करें',
      'ईमेल प्रोवाइडर पर जाकर "Create Account" क्लिक करें',
      'Pdf डाउनलोड करें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'नया ईमेल अकाउंट बनाने के लिए सबसे पहले किसी ईमेल प्रोवाइडर (जैसे Gmail, Outlook) की साइट पर जाकर "Create Account" या "Sign Up" पर क्लिक करना होता है।',
  ),
  QuizQuestion(
    id: 'cit102',
    question: 'ईमेल में "To" फ़ील्ड का क्या मतलब है?',
    options: [
      'छुपा हुआ प्राप्तकर्ता',
      'Subject Line',
      'संदेश का प्राथमिक प्राप्तकर्ता',
      'प्रेषक का नाम',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ईमेल में "To" फ़ील्ड उस मुख्य व्यक्ति या व्यक्तियों के ईमेल पते के लिए होता है, जिसे आप सीधे संदेश भेज रहे हैं।',
  ),
  QuizQuestion(
    id: 'cit103',
    question: 'Bcc का पूरा रूप क्या है?',
    options: [
      'Blind Carbon Copy',
      'Backup Contact Code',
      'Basic Contact Category',
      'Bulk Contact Count',
    ],
    correctIndex: 0,
    subject: 'BS-CIT',
    description:
        'Bcc का पूरा रूप Blind Carbon Copy है। इसका उपयोग प्राप्तकर्ताओं को एक-दूसरे से छुपाने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit104',
    question: 'एक अच्छा ईमेल Subject Line कैसा होना चाहिए?',
    options: [
      'विस्तृत विवरण',
      'एक मजाक',
      'ईमेल के उद्देश्य का संक्षिप्त और स्पष्ट सारांश',
      'खाली छोड़ा हुआ',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एक अच्छी Subject Line ईमेल के उद्देश्य का संक्षिप्त और स्पष्ट सारांश प्रस्तुत करती है।',
  ),
  QuizQuestion(
    id: 'cit105',
    question: 'अपने ईमेल अकाउंट को सुरक्षित करने का एक तरीका क्या है?',
    options: [
      'सभी साइट्स के लिए एक जैसा पासवर्ड',
      'पासवर्ड दोस्तों के साथ साझा करें',
      'Two-Factor Authentication का उपयोग करें',
      'पासवर्ड को सरल रखें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'टू-फैक्टर ऑथेंटिकेशन (2FA) आपके ईमेल अकाउंट की सुरक्षा के लिए एक अतिरिक्त परत प्रदान करता है।',
  ),
  QuizQuestion(
    id: 'cit106',
    question: 'ईमेल में फ़ोल्डर्स या लेबल का क्या उद्देश्य है?',
    options: [
      'ईमेल को अपने आप डिलीट करना',
      'पासवर्ड स्टोर करना',
      'ईमेल को विषय या श्रेणी के अनुसार व्यवस्थित करना',
      'समूह ईमेल भेजना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फोल्डर या लेबल का उपयोग ईमेल को विषय, प्रेषक या श्रेणी के अनुसार व्यवस्थित करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit107',
    question: 'निम्न में से कौन सा फ़िशिंग ईमेल की पहचान है?',
    options: [
      'आपके अपने ईमेल पते से भेजा गया',
      'आपके बैंक से व्यक्तिगत अभिवादन',
      'खराब Grammar और लिंक क्लिक करने की तुरंत मांग',
      'एक संपर्क नंबर शामिल है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फिशिंग ईमेल में अक्सर व्याकरण की गलतियाँ (खराब Grammar) होती हैं और वे आपात स्थिति बनाकर लिंक पर क्लिक करने का दबाव बनाते हैं।',
  ),
  QuizQuestion(
    id: 'cit108',
    question: 'कौन सा ईमेल, फ़ील्ड प्राप्तकर्ता को दूसरों से छुपाता है?',
    options: ['To', 'Cc', 'Bcc', 'Subject'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Bcc (Blind Carbon Copy) फ़ील्ड में डाले गए प्राप्तकर्ताओं के ईमेल पते अन्य सभी प्राप्तकर्ताओं से छुपे रहते हैं।',
  ),
  QuizQuestion(
    id: 'cit109',
    question: 'एक पेशेवर ईमेल को समाप्त करने का सही तरीका क्या है?',
    options: ['Lol', 'Regards या Thanks', 'Bye-Bye', 'Cu Soon'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'एक पेशेवर ईमेल को समाप्त करने के लिए "Regards", "Sincerely", या "Thanks" जैसे विनम्र क्लोजिंग का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit110',
    question: 'संदिग्ध ईमेल में लिंक पर क्लिक करने से क्यों बचना चाहिए?',
    options: [
      'यह आपका ब्राउज़र बंद कर देगा',
      'आपकी स्क्रीन चमकने लगेगी',
      'यह फ़िशिंग वेबसाइट या मैलवेयर की ओर ले जा सकता है',
      'यह आपका अकाउंट डिलीट कर देगा',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'संदिग्ध ईमेल में लिंक आपको फिशिंग वेबसाइट पर ले जा सकते हैं या आपके डिवाइस में मैलवेयर इंस्टॉल कर सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit111',
    question: 'पेशेवर ऑनलाइन संचार का मुख्य उद्देश्य क्या है?',
    options: [
      'मज़ेदार भाषा का प्रयोग करना',
      'इमोजी से दूसरों को प्रभावित करना',
      'स्पष्ट और सम्मानजनक संवाद करना',
      'हर बहस जीतना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पेशेवर ऑनलाइन संचार का मुख्य उद्देश्य जानकारी को स्पष्ट, संक्षिप्त और सम्मानजनक तरीके से साझा करना है।',
  ),
  QuizQuestion(
    id: 'cit112',
    question: 'निम्न में से कौन विनम्र डिजिटल संवाद का उदाहरण है?',
    options: [
      '"Send it now."',
      '"Why didn\'t you do this yet?"',
      '"Could you please share the file?"',
      '"Hurry up, I\'m waiting."',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        '"Could you please share the file?" एक विनम्र अनुरोध का उदाहरण है, जो पेशेवर संवाद में उपयुक्त है।',
  ),
  QuizQuestion(
    id: 'cit113',
    question: 'ईमेल में "BCC" का क्या अर्थ है?',
    options: [
      'Blind Contact Confirmation',
      'Blind Carbon Copy',
      'Basic Communication Code',
      'Background Chat Copy',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'BCC का पूरा रूप Blind Carbon Copy है, जिसका उपयोग ईमेल प्राप्तकर्ताओं को एक-दूसरे से छुपाने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit114',
    question: 'निम्न में से कौन ऑनलाइन स्केम या धोखाधड़ी का संकेत हो सकता है?',
    options: [
      'Personalised greeting',
      'Email from known company domain',
      'Poor grammar और urgent messages',
      'Clear privacy policy',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'खराब व्याकरण (Poor grammar) और तत्काल कार्रवाई (urgent messages) के दबाव ऑनलाइन घोटाले (Scam) के सामान्य संकेत हैं।',
  ),
  QuizQuestion(
    id: 'cit115',
    question:
        'ईमेल और चैट में गलतफहमियों से बचने की कौन सी रणनीति सबसे उपयुक्त है?',
    options: [
      'इमोजी का इस्तेमाल करना',
      'विनम्र भाषा और स्पष्ट टोन का उपयोग करना',
      'ALL CAPS में टाइप करना',
      'शुभकामनाएँ और समापन छोड़ देना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'गलतफहमियों से बचने के लिए विनम्र भाषा और स्पष्ट टोन (स्वर) का उपयोग करना सबसे प्रभावी रणनीति है।',
  ),
  QuizQuestion(
    id: 'cit116',
    question:
        'सोशल मीडिया पर अपनी गोपनीयता को प्रबंधित करने का एक प्रभावी तरीका क्या है?',
    options: [
      'रीयल-टाइम लोकेशन शेयर करना',
      'प्रोफ़ाइल को पूरी तरह सार्वजनिक करना',
      'डाटा शेयरिंग सीमित करना और प्रोफ़ाइल को प्राइवेट रखना',
      'व्यक्तिगत दस्तावेज़ पोस्ट करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया पर गोपनीयता बनाए रखने के लिए प्रोफ़ाइल को प्राइवेट रखना और डाटा शेयरिंग को सीमित करना आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit117',
    question: 'किसी रूखे या नकारात्मक ऑनलाइन संदेश का सबसे अच्छा जवाब क्या है?',
    options: [
      'व्यंग्य से उत्तर देना',
      'बिना रिपोर्ट किए नजरअंदाज कर देना',
      'शांत और पेशेवर तरीके से उत्तर देना',
      'तुरंत तर्क करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'नकारात्मक संदेश का सबसे अच्छा जवाब शांत और पेशेवर तरीके से देना होता है, जिससे स्थिति और खराब न हो।',
  ),
  QuizQuestion(
    id: 'cit118',
    question: 'पेशेवर डिजिटल संवाद में आपको क्या करने से बचना चाहिए?',
    options: [
      'स्पष्ट विषय पंक्तियों का प्रयोग करना',
      'भेजने से पहले प्रूफरीड करना',
      'Slang और भावनात्मक भाषा का उपयोग करना',
      'संदेश को संक्षेप और प्रासंगिक रखना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पेशेवर डिजिटल संवाद में स्लैंग (Slang) और अत्यधिक भावनात्मक भाषा के उपयोग से बचना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit119',
    question: 'निम्न में से कौन एक सामान्य ऑनलाइन धोखाधड़ी का प्रकार है?',
    options: [
      'Email newsletter',
      'Feedback form',
      'Phishing email',
      'Subscription confirmation',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फिशिंग ईमेल (Phishing email) एक सामान्य ऑनलाइन धोखाधड़ी है जिसमें संवेदनशील जानकारी चुराई जाती है।',
  ),
  QuizQuestion(
    id: 'cit120',
    question: 'पेशेवर संचार में डिजिटल टोन क्यों महत्वपूर्ण है?',
    options: [
      'यह आपकी टाइपिंग गति दर्शाता है',
      'यह आपकी भावनाओं को स्पष्ट रूप से दर्शाता है',
      'यह सम्मान और उद्देश्य को प्रकट करता है',
      'यह केवल मौखिक संवाद में मायने रखता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डिजिटल टोन (Digital Tone) महत्वपूर्ण है क्योंकि यह आपके संदेश के सम्मान और उद्देश्य को स्पष्ट करता है, खासकर जब चेहरे के भाव दिखाई न दें।',
  ),
  QuizQuestion(
    id: 'cit121',
    question: 'MS Word में Ribbon का उपयोग क्या होता है?',
    options: [
      'इंटरनेट ब्राउज करने के लिए',
      'Tools और Formatting Options दिखाने के लिए',
      'कोड लिखने के लिए',
      'ऑडियो फाइल चलाने के लिए',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Ribbon (रिबन) MS Word का टॉप पर मौजूद टूलबार होता है जिसमें सभी टूल्स और फॉर्मेटिंग ऑप्शन (जैसे Font, Paragraph, Insert) दिखते हैं।',
  ),
  QuizQuestion(
    id: 'cit122',
    question:
        'कौन-सा फाइल फॉर्मिट डॉक्यूमेंट को Read-only और Secure शेयर करने की सुविधा देता है?',
    options: ['.DOCX', '.TXT', '.PDF', '.HTML'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'PDF (पोर्टेबल डॉक्यूमेंट फॉर्मेट) फाइलें आमतौर पर Read-Only होती हैं और इन्हें आसानी से एडिट नहीं किया जा सकता, जिससे ये सुरक्षित शेयरिंग के लिए उपयुक्त होती हैं।',
  ),
  QuizQuestion(
    id: 'cit123',
    question: 'टेक्स्ट को Bold करने के लिए कौन-सा टूल इस्तेमाल होता है?',
    options: ['Italics', 'Underline', 'Font Color', 'Bold (B)'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'टेक्स्ट को Bold (मोटा) करने के लिए Bold टूल (Ctrl+B) का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit124',
    question: 'MS Word में Table कैसे Insert की जाती है?',
    options: [
      'File → Table',
      'Insert → Table',
      'Layout → Chart',
      'Right-click → Table',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'MS Word में Table Insert करने के लिए "Insert" टैब पर जाकर "Table" ऑप्शन पर क्लिक किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit125',
    question:
        'इमेज के चारों ओर टेक्स्ट को एडजस्ट करने के लिए कौन-सा फीचर होता है?',
    options: [
      'Image Clickable बनाना',
      'Image को Text में बदलना',
      'Wrap Text',
      'Image का Color बदलना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Wrap Text (टेक्स्ट रैप) फीचर आपको यह नियंत्रित करने की सुविधा देता है कि इमेज के आसपास टेक्स्ट कैसे फ्लो हो।',
  ),
  QuizQuestion(
    id: 'cit126',
    question:
        'पैराग्राफ की लाइनों के बीच की दूरी को एडजस्ट करने के लिए कौन-सा ऑप्शन है?',
    options: ['Font Size', 'Line Spacing', 'Margins', 'Indentation'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'पैराग्राफ की लाइनों के बीच की दूरी (Line Spacing) को "Home" टैब के Paragraph सेक्शन में Line and Paragraph Spacing आइकन से एडजस्ट किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit127',
    question: 'डॉक्यूमेंट प्रिंट करने के लिए सही स्टेप क्या है?',
    options: ['Edit → Copy', 'View → Layout', 'File → Print', 'Home → Format'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डॉक्यूमेंट प्रिंट करने के लिए "File" टैब में जाकर "Print" विकल्प पर क्लिक करना होता है।',
  ),
  QuizQuestion(
    id: 'cit128',
    question:
        'प्रोसेस के स्टेप्स दिखाने के लिए सबसे अच्छा लिस्ट फॉर्मिट कौन-सा है?',
    options: ['Bullet List', 'Numbered List', 'Alphabet List', 'Dot Chart'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'प्रोसेस के स्टेप्स या अनुक्रम दिखाने के लिए Numbered List (क्रमांकित सूची) सबसे उपयुक्त है।',
  ),
  QuizQuestion(
    id: 'cit129',
    question: 'डॉक्यूमेंट का Orientation कहाँ बदला जाता है?',
    options: ['Review Tab', 'View Tab', 'Layout Tab', 'Insert Tab'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डॉक्यूमेंट का Orientation (Portrait या Landscape) "Layout" या "Page Layout" टैब में बदला जाता है।',
  ),
  QuizQuestion(
    id: 'cit130',
    question:
        'Word फाइल्स को नाम देने और ऑर्गनाइज़ करने का मुख्य कारण क्या है?',
    options: [
      'ताकि उन्हें ढूँढना मुश्किल हो',
      'फाइल साइज़ कम करने के लिए',
      'टाइपिंग स्पीड बढ़ाने के लिए',
      'ताकि फाइल्स को आसानी से खोजा और स्टोर किया जा सके',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'फाइलों को सार्थक नाम देने और व्यवस्थित करने से उन्हें ढूंढना और स्टोर करना आसान हो जाता है।',
  ),
  QuizQuestion(
    id: 'cit131',
    question: 'MS Word में Header का क्या कार्य होता है?',
    options: [
      'केवल इमेज दिखाने के लिए',
      'Footnotes लिखने के लिए',
      'हर पेज के ऊपर Text दिखाने के लिए',
      'Font Color बदलने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Header (हेडर) एक ऐसा सेक्शन होता है जो डॉक्यूमेंट के हर पेज के टॉप पर दिखता है, जैसे पेज नंबर या लोगो।',
  ),
  QuizQuestion(
    id: 'cit132',
    question: 'Page Numbers कहाँ से Insert किए जाते हैं?',
    options: ['Review Tab', 'Insert Tab', 'View Tab', 'Home Tab'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'पेज नंबर Insert करने के लिए "Insert" टैब में जाकर "Page Number" विकल्प का चयन किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit133',
    question: 'MS Word में \'Style\' का क्या अर्थ है?',
    options: [
      'नया Document Format',
      'Background Image',
      'Font और Size जैसे Formatting Options का Set',
      'Chart का एक प्रकार',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'MS Word में Style (स्टाइल) फॉन्ट, साइज, कलर आदि फॉर्मेटिंग ऑप्शन्स का एक प्री-डिफाइंड सेट होता है (जैसे Heading 1, Normal)।',
  ),
  QuizQuestion(
    id: 'cit134',
    question: 'लंबे Document में Styles क्यों उपयोगी हैं?',
    options: [
      'File Size बढ़ाने के लिए',
      'पाठकों को भ्रमित करने के लिए',
      'Formatting Consistency बनाए रखने के लिए',
      'Document के Margin बदलने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'लंबे डॉक्यूमेंट में स्टाइल्स का उपयोग करने से पूरे डॉक्यूमेंट में फॉर्मेटिंग की एकरूपता (Consistency) बनी रहती है।',
  ),
  QuizQuestion(
    id: 'cit135',
    question: 'Table of Contents (TOC) Insert करने से पहले क्या ज़रूरी है?',
    options: [
      'इमेज Insert करना',
      'Cover Page बनाना',
      'Heading Styles का उपयोग',
      'Page Breaks जोड़ना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Table of Contents (TOC) इंसर्ट करने से पहले डॉक्यूमेंट में Heading Styles (जैसे Heading 1, Heading 2) का उपयोग करना आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit136',
    question: 'TOC को Document में बदलाव के बाद कैसे Update करें?',
    options: [
      'दोबारा TOC Insert करें',
      'Document को Save करके बंद करें',
      'TOC पर Right Click करें → \'Update Field\' चुनें',
      'Print Command का उपयोग करें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'TOC को अपडेट करने के लिए उस पर Right-Click करें और "Update Field" चुनें, फिर "Update entire table" का विकल्प चुनें।',
  ),
  QuizQuestion(
    id: 'cit137',
    question: 'Mail Merge का मुख्य लाभ क्या है?',
    options: [
      'Paragraphs को Format करना',
      'Personalised Documents को Bulk में बनाना',
      'Tables Insert करना',
      'Spell Check करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Mail Merge का सबसे बड़ा लाभ यह है कि इससे हजारों व्यक्तिगत (Personalised) दस्तावेज़ जैसे लेटर या ईमेल एक साथ बनाए जा सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit138',
    question: 'Mail Merge के लिए कौन-से File Types सामान्यतः उपयोग होते हैं?',
    options: ['JPG और PNG', 'DOC और TXT', 'EXCEL और CSV', 'PDF और ZIP'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Mail Merge में डाटा सोर्स के रूप में आमतौर पर Excel फाइल (.xlsx) या CSV (.csv) फाइल का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit139',
    question: 'Mail Merge Feature किस Tab में मिलता है?',
    options: ['Home', 'Insert', 'Layout', 'Mailings'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'MS Word में Mail Merge से संबंधित सभी विकल्प "Mailings" टैब में मिलते हैं।',
  ),
  QuizQuestion(
    id: 'cit140',
    question: '\'Wrap Text\' Feature क्या करता है?',
    options: [
      'Table जोड़ता है',
      'Document को Encrypt करता है',
      'इमेज के चारों ओर Text Flow को Adjust करता है',
      'Watermark Insert करता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Wrap Text फीचर यह नियंत्रित करता है कि किसी इमेज या ऑब्जेक्ट के चारों ओर टेक्स्ट कैसे लपेटा जाएगा (Flow)।',
  ),
  QuizQuestion(
    id: 'cit141',
    question: 'MS Excel में Cell क्या होता है?',
    options: [
      'एक प्रकार का Graph',
      'Spreadsheet की सबसे छोटी इकाई',
      'Ribbon पर एक Button',
      'एक नई Worksheet',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Excel में Cell (सेल) स्प्रेडशीट की सबसे छोटी इकाई होती है, जो एक Row और एक Column के इंटरसेक्शन पर बनती है।',
  ),
  QuizQuestion(
    id: 'cit142',
    question: 'A1 से A5 तक के मान जोड़ने के लिए कौन-सा Formula सही है?',
    options: ['=ADD(A1:A5)', '=TOTAL(A1:A5)', '=SUM(A1:A5)', '=PLUS(A1:A5)'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Excel में सेल्स की रेंज को जोड़ने के लिए SUM फंक्शन का उपयोग किया जाता है, जैसे =SUM(A1:A5)।',
  ),
  QuizQuestion(
    id: 'cit143',
    question: 'किसी Cell में टेक्स्ट को Bold कैसे करें?',
    options: ['Home → Insert', 'Home → Bold (B)', 'View → Bold', 'File → Font'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Excel में सेल के टेक्स्ट को Bold करने के लिए Home टैब के Font ग्रुप में Bold (B) बटन पर क्लिक करें या Ctrl+B दबाएं।',
  ),
  QuizQuestion(
    id: 'cit144',
    question: 'Wrap Text क्या करता है?',
    options: [
      'Text को छुपाता है',
      'Text को Right Align करता है',
      'लंबे Text को Cell में कई पंक्तियों में दिखाता है',
      'Text का रंग बदलता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Wrap Text फीचर लंबे टेक्स्ट को एक ही लाइन में फैलने से रोकता है और उसे सेल के अंदर मल्टीपल लाइनों में दिखाता है।',
  ),
  QuizQuestion(
    id: 'cit145',
    question: 'कौन-सा Function मानों का औसत निकालता है?',
    options: ['=COUNT()', '=MEAN()', '=AVERAGE()', '=MID()'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Excel में AVERAGE फंक्शन का उपयोग दी गई सेल्स के मानों का औसत (Mean) निकालने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit146',
    question: 'Filter Tool का उद्देश्य क्या है?',
    options: [
      'सारा डाटा हटाना',
      'शर्तों के आधार पर विशिष्ट डाटा ढूंढना और दिखाना',
      'Rows को स्थायी रूप से छुपाना',
      'Graph बनाना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Filter (फ़िल्टर) टूल का उपयोग बड़े डाटासेट से कुछ निश्चित शर्तों के आधार पर सिर्फ वही डाटा दिखाने के लिए किया जाता है जिसकी आपको जरूरत है।',
  ),
  QuizQuestion(
    id: 'cit147',
    question: 'COUNT Function क्या करता है?',
    options: [
      'संख्याएँ जोड़ता है',
      'Numeric Entries की गिनती करता है',
      'Minimum ढूंढता है',
      'Duplicates ढूंढता है',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'COUNT फंक्शन एक रेंज में उन सेल्स की संख्या गिनता है जिनमें संख्यात्मक मान (Numeric Entries) मौजूद हैं।',
  ),
  QuizQuestion(
    id: 'cit148',
    question: 'Excel में Columns कैसे पहचाने जाते हैं?',
    options: ['Numbers से', 'Letters से', 'Symbols से', 'Colours से'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Excel में Columns (कॉलम) को Letters (A, B, C, ...) से पहचाना जाता है और Rows (पंक्तियों) को Numbers (1, 2, 3, ...) से।',
  ),
  QuizQuestion(
    id: 'cit149',
    question: 'Data को Sort करने के लिए कौन-सा Tab प्रयोग होता है?',
    options: ['File', 'View', 'Data', 'Review'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Excel में डाटा को सॉर्ट (Sort) करने के लिए "Data" टैब में दिए गए Sort विकल्पों का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit150',
    question: 'Excel में एक नया Blank Worksheet कैसे बनाया जाता है?',
    options: [
      'Insert → New Worksheet',
      'Home → New',
      'File → Print',
      'Data → Add',
    ],
    correctIndex: 0,
    subject: 'BS-CIT',
    description:
        'Excel में नई Blank Worksheet जोड़ने के लिए शीट्स के टैब के पास "+" आइकन पर क्लिक करें या Insert → New Worksheet का उपयोग करें।',
  ),
  QuizQuestion(
    id: 'cit151',
    question: 'Excel में Data Visualisation का मुख्य उद्देश्य क्या है?',
    options: [
      'Cells को फॉर्मेट करना',
      'बहुत सारा डाटा दर्ज करना',
      'डाटा को विजुअली और आसानी से समझने योग्य रूप में प्रस्तुत करना',
      'Worksheet को सुरक्षित करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डाटा विज़ुअलाइज़ेशन (जैसे चार्ट और ग्राफ) का उद्देश्य जटिल डाटा को आसानी से समझने योग्य विजुअल फॉर्मेट में पेश करना है।',
  ),
  QuizQuestion(
    id: 'cit152',
    question: 'कौन-सी सुविधा वैल्यू के आधार पर Cells को रंग देती है?',
    options: [
      'VLOOKUP',
      'Conditional Formatting',
      'Data Validation',
      'Pivot Table',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Conditional Formatting (कंडीशनल फॉर्मेटिंग) से आप सेल की वैल्यू के आधार पर उसका रंग, फॉन्ट या स्टाइल अपने आप बदल सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit153',
    question: 'कौन-सा चार्ट "whole" के हिस्सों को दिखाने के लिए उपयुक्त है?',
    options: ['Bar Chart', 'Line Graph', 'Pie Chart', 'Column Chart'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Pie Chart (पाई चार्ट) कुल (Whole) के प्रतिशत या हिस्सों (Parts) को दिखाने के लिए सबसे उपयुक्त होता है।',
  ),
  QuizQuestion(
    id: 'cit154',
    question: 'Excel में VLOOKUP क्या करता है?',
    options: [
      'सभी वैल्यू को जोड़ता है',
      'इनपुट डाटा को मान्य करता है',
      'पहले कॉलम में वैल्यू खोजता है और संबंधित वैल्यू लौटाता है',
      'Headers को फॉर्मेट करता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'VLOOKUP फंक्शन टेबल के पहले कॉलम में एक वैल्यू को खोजता है और फिर उसी पंक्ति में किसी दूसरे कॉलम से संबंधित वैल्यू लौटाता है।',
  ),
  QuizQuestion(
    id: 'cit155',
    question: 'कौन-सा Formula टेक्स्ट को जोड़ता है?',
    options: ['IF', 'VLOOKUP', 'SUM', 'CONCATENATE'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'CONCATENATE फंक्शन का उपयोग दो या दो से अधिक टेक्स्ट स्ट्रिंग्स को जोड़ने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit156',
    question: 'Pivot Table का उपयोग क्यों किया जाता है?',
    options: [
      'डाटा को फिल्टर करने के लिए',
      'इमेज दिखाने के लिए',
      'बड़े डाटा सेट का सारांश और विश्लेषण करने के लिए',
      'Spelling Errors दिखाने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Pivot Table (पिवोट टेबल) एक शक्तिशाली टूल है जिसका उपयोग बड़े डाटा सेट का सारांश (Summarize) और विश्लेषण (Analyze) करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit157',
    question: 'Conditional Formatting में Color Scale क्या करता है?',
    options: [
      'केवल Title Row को फॉर्मेट करता है',
      'वैल्यू को Text में बदलता है',
      'Cell वैल्यू के आधार पर Gradient रंग लागू करता है',
      'Spreadsheet को Encrypt करता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Color Scale (कलर स्केल) सेल की वैल्यू के आधार पर उस पर एक ग्रेडिएंट (Gradient) रंग लागू करता है, जैसे कम वैल्यू पर लाल और ज्यादा पर हरा।',
  ),
  QuizQuestion(
    id: 'cit158',
    question: 'Excel में IF Function क्या करने देता है?',
    options: [
      'Dropdown Lists बनाना',
      'Condition के आधार पर Decision लेना',
      'Cell की गिनती करना',
      'डाटा को Sort करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'IF फंक्शन एक लॉजिकल टेस्ट करता है और शर्त सही (TRUE) होने पर एक मान और गलत (FALSE) होने पर दूसरा मान रिटर्न करता है।',
  ),
  QuizQuestion(
    id: 'cit159',
    question: 'Worksheet Editing से रोकने का एक तरीका क्या है?',
    options: [
      'CONCATENATE का उपयोग',
      'Data Validation लागू करना',
      'Password Protection',
      'Pie Chart बनाना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'वर्कशीट को एडिट होने से बचाने के लिए आप उसे पासवर्ड प्रोटेक्ट (Password Protection) कर सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit160',
    question: 'Data Validation का उपयोग किसलिए होता है?',
    options: [
      'डाटा को ऑटोमैटिकली सारांशित करने के लिए',
      'विशिष्ट वैल्यू या फॉर्मेट की एंट्री सीमित करने के लिए',
      'Spreadsheets को मर्ज करने के लिए',
      'Pivot Charts डालने के लिए',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Data Validation (डाटा वैलिडेशन) का उपयोग यह नियंत्रित करने के लिए किया जाता है कि सेल में किस प्रकार का डाटा (जैसे नंबर, डेट, या लिस्ट से) डाला जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit161',
    question: 'MS PowerPoint का मुख्य उपयोग किस लिए किया जाता है?',
    options: [
      'औपचारिक पत्र लिखने के लिए',
      'डेटाबेस प्रबंधन के लिए',
      'डिजिटल प्रस्तुतियाँ बनाने के लिए',
      'कोड लिखने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'MS PowerPoint एक प्रेजेंटेशन सॉफ्टवेयर है, जिसका उपयोग डिजिटल स्लाइड शो (प्रस्तुतियाँ) बनाने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit162',
    question: 'कौन-सा टैब नई स्लाइड जोड़ने के विकल्प देता है?',
    options: ['File', 'View', 'Home', 'Review'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'PowerPoint में नई स्लाइड जोड़ने के लिए "Home" टैब में "New Slide" विकल्प पर क्लिक किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit163',
    question: 'Slide Layouts का उद्देश्य क्या है?',
    options: [
      'स्लाइड्स को प्रिंट करना',
      'फॉन्ट स्टाइल बदलना',
      'स्लाइड कंटेंट की संरचना तय करना',
      'फाइल को सेव करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Slide Layout (स्लाइड लेआउट) आपको प्लेसहोल्डर्स (टेक्स्ट, इमेज, चार्ट) के साथ स्लाइड की स्ट्रक्चर (संरचना) तय करने की सुविधा देता है।',
  ),
  QuizQuestion(
    id: 'cit164',
    question: 'स्लाइड में चित्र कहाँ से जोड़ा जा सकता है?',
    options: ['Review टैब', 'Insert टैब', 'File टैब', 'Design टैब'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'PowerPoint में स्लाइड में चित्र (Picture) जोड़ने के लिए "Insert" टैब का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit165',
    question: '"Transition" फीचर क्या करता है?',
    options: [
      'बैकग्राउंड कलर बदलता है',
      'साउंड इफेक्ट जोड़ता है',
      'स्लाइड पर वस्तुओं को एनिमेट करता है',
      'स्लाइड्स के बीच इफेक्ट्स लागू करता है',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'Transition (ट्रांज़िशन) वह विजुअल इफेक्ट है जो एक स्लाइड से दूसरी स्लाइड पर जाने के दौरान दिखता है।',
  ),
  QuizQuestion(
    id: 'cit166',
    question: 'स्लाइड पर टेक्स्ट जोड़ते समय अच्छा अभ्यास क्या है?',
    options: [
      'लंबे पैराग्राफ का प्रयोग',
      'हेडिंग से बचना',
      'संक्षिप्त और स्पष्ट टेक्स्ट रखना',
      'एक स्लाइड पर कई फॉन्ट्स जोड़ना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'प्रभावी प्रेजेंटेशन के लिए स्लाइड्स पर टेक्स्ट संक्षिप्त (Concise) और स्पष्ट (Clear) होना चाहिए, लंबे पैराग्राफ से बचना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit167',
    question: 'स्लाइड्स शो शुरू करने के लिए कौनसी Key दबाते हैं?',
    options: ['F1', 'Insert', 'F5', 'Esc'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'PowerPoint में स्लाइड शो शुरू करने के लिए F5 की दबाई जाती है।',
  ),
  QuizQuestion(
    id: 'cit168',
    question: 'Animation फीचर क्या नियंत्रित करता है?',
    options: [
      'बैकग्राउंड म्यूज़िक',
      'स्लाइड ट्रांज़िशन',
      'स्लाइड पर टेक्स्ट और इमेज का दिखना',
      'फॉन्ट साइज़',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Animation (एनिमेशन) यह नियंत्रित करता है कि स्लाइड पर मौजूद टेक्स्ट या इमेज कैसे, कब और किस क्रम में दिखाई देगी।',
  ),
  QuizQuestion(
    id: 'cit169',
    question: 'Design Theme से क्या किया जा सकता है?',
    options: [
      'Slide Sorter खोलना',
      'Font Style बदलना',
      'पूरी प्रस्तुति का लुक एक क्लिक में बदलना',
      'प्रिंट प्रीव्यू देखना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Design Theme (डिज़ाइन थीम) से आप पूरी प्रेजेंटेशन के कलर, फॉन्ट और इफेक्ट्स को एक क्लिक में बदल सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit170',
    question: 'एक प्रभावी प्रेज़ेंटेशन का एक मुख्य तत्व क्या है?',
    options: [
      'स्लाइड्स का हर शब्द पढ़ना',
      'बहुत तेज बोलना',
      'आँखों का संपर्क और स्पष्ट भाषण',
      'सभी एनिमेशन का प्रयोग',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एक प्रभावी प्रेजेंटेशन के लिए ऑडियंस से आँखों का संपर्क (Eye Contact) बनाए रखना और स्पष्ट भाषण देना आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit171',
    question: 'Powerpoint में Smartart का मुख्य उद्देश्य क्या है?',
    options: [
      'एनिमेशन बनाना',
      'जटिल जानकारी को दृश्य रूप से प्रदर्शित करना',
      'ऑडियो सम्मिलित करना',
      'स्लाइड ट्रांज़िशन जोड़ना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'SmartArt का उपयोग जटिल जानकारी (जैसे प्रोसेस, पदानुक्रम) को ग्राफिकल और आकर्षक तरीके से दिखाने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit172',
    question: 'Powerpoint में Chart कहाँ से जोड़ा जा सकता है?',
    options: ['Design टैब', 'View टैब', 'Insert टैब', 'Review टैब'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'PowerPoint में चार्ट (ग्राफ) जोड़ने के लिए "Insert" टैब में "Chart" विकल्प पर क्लिक किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit173',
    question: 'Slide Master का कार्य क्या है?',
    options: [
      'स्लाइड हटाना',
      'ट्रांज़िशन जोड़ना',
      'समान स्लाइड लेआउट बनाना और संपादित करना',
      'नैरेशन रिकॉर्ड करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Slide Master (स्लाइड मास्टर) एक टेम्पलेट है जो प्रेजेंटेशन की सभी स्लाइड्स के लिए समान लेआउट, फॉन्ट और कलर सेट करता है।',
  ),
  QuizQuestion(
    id: 'cit174',
    question: 'Powerpoint टेम्पलेट को किस फ़ाइल एक्सटेंशन में सहेजा जाता है?',
    options: ['.ppt', '.potx', '.docx', '.xlsx'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'PowerPoint टेम्पलेट (Template) फाइल का एक्सटेंशन .potx होता है।',
  ),
  QuizQuestion(
    id: 'cit175',
    question:
        'स्लाइड शो के दौरान वीडियो चलाने के लिए कौन-सा टैब प्रयोग होता है?',
    options: ['Animation टैब', 'Design टैब', 'Playback टैब', 'Review टैब'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'स्लाइड में डाले गए वीडियो को कंट्रोल (जैसे ऑटो प्ले, लूप) करने के लिए "Playback" टैब का उपयोग होता है।',
  ),
  QuizQuestion(
    id: 'cit176',
    question: 'Action Button का प्रयोग किसलिए किया जाता है?',
    options: [
      'बुलेट जोड़ने के लिए',
      'पृष्ठभूमि बदलने के लिए',
      'इंटरैक्टिव नेविगेशन के लिए',
      'आकृतियों को फ़ॉर्मेट करने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Action Button (एक्शन बटन) का उपयोग प्रेजेंटेशन में इंटरैक्टिव नेविगेशन बनाने के लिए किया जाता है, जैसे अगली स्लाइड पर जाने के लिए बटन।',
  ),
  QuizQuestion(
    id: 'cit177',
    question: 'Powerpoint में Hyperlink जोड़ने की प्रक्रिया क्या है?',
    options: [
      'Insert → Smartart',
      'Review → Link',
      'Insert → Link',
      'File → Share',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'PowerPoint में Hyperlink जोड़ने के लिए "Insert" टैब में जाकर "Link" विकल्प पर क्लिक किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit178',
    question: 'वीडियो उपयोग करते समय सर्वोत्तम अभ्यास क्या है?',
    options: [
      'उच्च-गुणवत्ता लंबे वीडियो का उपयोग करें',
      'सभी वीडियो को Autoplay पर सेट करें',
      'वीडियो छोटा और प्रासंगिक रखें',
      'सभी ऑडियो म्यूट करें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'प्रेजेंटेशन में वीडियो का उपयोग करते समय उसे छोटा (Short) और विषय से प्रासंगिक (Relevant) रखना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit179',
    question: 'स्लाइड डिज़ाइन में पठनीयता सुधारने का सिद्धांत कौन-सा है?',
    options: [
      'अधिकतम फ़ॉन्ट का प्रयोग करें',
      'उज्ज्वल पृष्ठभूमि और सफेद टेक्स्ट',
      'उच्च कंट्रास्ट और उचित संरेखण',
      'बैकग्राउंड म्यूजिक जोड़ें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'स्लाइड्स को पढ़ने में आसान बनाने के लिए टेक्स्ट और बैकग्राउंड के बीच उच्च कंट्रास्ट (High Contrast) और उचित संरेखण (Alignment) होना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit180',
    question: 'Powerpoint में Custom Templates का उपयोग क्यों किया जाता है?',
    options: [
      'स्लाइड तेजी से लोड होती हैं',
      'फ़ाइल आकार बढ़ता है',
      'ब्रांडिंग और लेआउट स्थिरता बनाए रखना',
      'एनिमेशन अक्षम करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Custom Templates (कस्टम टेम्पलेट) का उपयोग कंपनी की ब्रांडिंग और स्लाइड्स के लेआउट में एकरूपता (Consistency) बनाए रखने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit181',
    question: 'Google Workspace टूल्स का मुख्य लाभ क्या है?',
    options: [
      'उन्हें हर डिवाइस पर इंस्टॉल करना पड़ता है',
      'वे ऑनलाइन रीयल-टाइम सहयोग की अनुमति देते हैं',
      'वे केवल ऑफलाइन उपलब्ध हैं',
      'वे केवल Google Chrome पर काम करते हैं',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google Workspace (Docs, Sheets, Slides) का मुख्य लाभ यह है कि कई लोग एक ही फाइल पर रियल-टाइम में एक साथ काम कर सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit182',
    question:
        'Google Workspace में स्प्रेडशीट बनाने के लिए कौन सा टूल उपयोग किया जाता है?',
    options: ['Google Docs', 'Google Slides', 'Google Forms', 'Google Sheets'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'Google Sheets (गूगल शीट्स) Google Workspace में स्प्रेडशीट बनाने और एडिट करने का टूल है।',
  ),
  QuizQuestion(
    id: 'cit183',
    question: 'आप Google Docs फ़ाइल को किसी के साथ कैसे साझा कर सकते हैं?',
    options: [
      'File → Download As Pdf',
      'Insert → Share',
      '"Share" पर क्लिक करें और उनका ईमेल एड्रेस डालें',
      'File → Save As',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Docs फाइल को शेयर करने के लिए ऊपर दाईं ओर "Share" बटन पर क्लिक करके व्यक्ति का ईमेल पता डालना होता है।',
  ),
  QuizQuestion(
    id: 'cit184',
    question: 'Google Docs में पेज मार्जिन बदलने के लिए कहाँ जाएं?',
    options: ['Insert Tab', 'File → Page Setup', 'Tools Menu', 'Format Tab'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google Docs में पेज मार्जिन बदलने के लिए "File" मेन्यू में जाकर "Page Setup" विकल्प चुनना होता है।',
  ),
  QuizQuestion(
    id: 'cit185',
    question:
        'Google Docs में बदलावों को और किसने किया यह देखने के लिए कौन सी सुविधा होती है?',
    options: [
      'Download History',
      'Version History',
      'Activity Tracker',
      'Edit Summary',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google Docs में "Version History" (वर्जन हिस्ट्री) से आप देख सकते हैं कि डॉक्यूमेंट में किसने, कब और क्या बदलाव किए हैं।',
  ),
  QuizQuestion(
    id: 'cit186',
    question: 'Google Sheets में कॉलम का जोड़ करने के लिए कौन सा फ़ॉर्मूला है?',
    options: [
      '=Add(A1:A10)',
      '=Total(A1:A10)',
      '=Sum(A1:A10)',
      '=Combine(A1:A10)',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Sheets में भी Excel की तरह कॉलम के मानों को जोड़ने के लिए =SUM() फॉर्मूले का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit187',
    question: 'Google Slides में Themes का उद्देश्य क्या होता है?',
    options: [
      'स्लाइड को ऑफलाइन एडिटेबल बनाना',
      'स्लाइड में एकसमान डिज़ाइन देना',
      'टेक्स्ट का अनुवाद करना',
      'पासवर्ड से सुरक्षा देना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google Slides में Themes (थीम) का उद्देश्य प्रेजेंटेशन की सभी स्लाइड्स को एक समान और पेशेवर डिज़ाइन देना होता है।',
  ),
  QuizQuestion(
    id: 'cit188',
    question: 'Google Slides में एनिमेशन जोड़ने के लिए कौन सा टैब होता है?',
    options: ['Insert', 'Tools', 'View', 'Format → Animation'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'Google Slides में एनिमेशन जोड़ने के लिए "Insert" मेन्यू में जाकर "Animation" पर क्लिक करें या Right-Click करें।',
  ),
  QuizQuestion(
    id: 'cit189',
    question: 'Google Docs में इमेज कैसे जोड़ते हैं?',
    options: [
      'Tools → Image',
      'View → Picture',
      'Insert → Image',
      'File → Insert',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Docs में इमेज जोड़ने के लिए "Insert" मेन्यू में जाकर "Image" विकल्प चुनना होता है।',
  ),
  QuizQuestion(
    id: 'cit190',
    question:
        'जब कई यूज़र्स एक ही Google Doc को एक साथ एडिट करते हैं तो क्या होता है?',
    options: [
      'केवल एक यूज़र सेव कर सकता है',
      'बाकी यूज़र्स लॉक हो जाते हैं',
      'सभी एडिट्स रीयल-टाइम में सिंक होते हैं',
      'सेव करने के बाद बदलाव खो जाते हैं',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Docs में रियल-टाइम सहयोग (Collaboration) की सुविधा है, जहाँ सभी यूजर्स के बदलाव एक साथ सिंक होते दिखाई देते हैं।',
  ),
  QuizQuestion(
    id: 'cit191',
    question: 'ऑनलाइन फॉर्म का मुख्य लाभ क्या है?',
    options: [
      'दस्तावेज़ प्रिंट करना',
      'जल्दी और डिजिटल रूप से डाटा एकत्र करना',
      'अपने आप ईमेल भेजना',
      'वेबसाइट ट्रैफ़िक बढ़ाना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'ऑनलाइन फॉर्म (जैसे Google Forms) का मुख्य लाभ डाटा को जल्दी और डिजिटल रूप से इकट्ठा करना है, जो अपने आप सारणीबद्ध हो जाता है।',
  ),
  QuizQuestion(
    id: 'cit192',
    question:
        'Google Workspace में ऑनलाइन फॉर्म बनाने के लिए कौन-सा टूल सामान्यतः उपयोग होता है?',
    options: ['Google Docs', 'Google Sheets', 'Google Forms', 'Google Slides'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Forms (गूगल फॉर्म्स) Google Workspace का वह टूल है जिसका उपयोग ऑनलाइन सर्वे, क्विज और फॉर्म बनाने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit193',
    question:
        'ऑपन इनपुट - जैसे नाम या सुझाव इकट्ठा करने के लिए कौन-सा प्रश्न प्रकार उपयुक्त है?',
    options: ['Multiple Choice', 'Dropdown', 'Short Answer', 'Checkboxes'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Short Answer (लघु उत्तरीय) प्रश्न का उपयोग उन उत्तरों के लिए किया जाता है जहाँ उपयोगकर्ता अपने शब्दों में टेक्स्ट टाइप करता है।',
  ),
  QuizQuestion(
    id: 'cit194',
    question:
        'फॉर्म प्रतिक्रियाओं को ग्राफ़िकल फॉर्मेट में कहाँ देखा जा सकता है?',
    options: [
      'Google Docs',
      'Form Editor',
      'Response Summary Tab In Google Forms',
      'Google Meet',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Forms में "Responses" टैब पर क्लिक करने पर "Summary" सेक्शन में सारे जवाबों का ग्राफिकल विश्लेषण (चार्ट) देखा जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit195',
    question:
        'गहराई से विश्लेषण के लिए फॉर्म प्रतिक्रियाओं को कैसे एक्सपोर्ट किया जा सकता है?',
    options: [
      'Pdf में बदलें',
      'सभी प्रतिक्रियाएं ईमेल करें',
      'Google Sheets में एक्सपोर्ट करें',
      'स्क्रीनशॉट लें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Forms के जवाबों को डीप एनालिसिस के लिए Google Sheets (स्प्रेडशीट) में एक्सपोर्ट (निर्यात) किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit196',
    question:
        'कौन सी विशेषता यह सुनिश्चित करती है कि उपयोगकर्ता कोई प्रश्न छोड़ न सकें?',
    options: [
      'Short Answer',
      'Shuffle Option Order',
      'Required Field',
      'Drop-Down Menu',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फॉर्म में "Required" (अनिवार्य) टॉगल ऑन करने से यूजर उस प्रश्न का उत्तर दिए बिना फॉर्म सबमिट नहीं कर सकता।',
  ),
  QuizQuestion(
    id: 'cit197',
    question: 'Dropdown प्रश्न का उपयोग करने का एक कारण क्या है?',
    options: [
      'फॉर्म में वर्तिकन वर्टिकल स्थान बचाना',
      'कई उत्तरों की अनुमित देना',
      'वीडियो शामिल करना',
      'केवल नंबर की प्रतिक्रिया सीमित करना',
    ],
    correctIndex: 0,
    subject: 'BS-CIT',
    description:
        'Dropdown (ड्रॉपडाउन) प्रश्न का उपयोग फॉर्म में जगह बचाने के लिए किया जाता है, खासकर जब विकल्पों की सूची लंबी हो।',
  ),
  QuizQuestion(
    id: 'cit198',
    question: 'एक अच्छा फॉर्म डिज़ाइन करते समय आपको क्या नहीं करना चाहिए?',
    options: [
      'स्पष्ट प्रश्न',
      'तार्किक प्रवाह',
      'बहुत सारे अनिवार्य प्रश्न और अव्यवस्था',
      'सुसंगत',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'अच्छे फॉर्म डिज़ाइन में बहुत सारे अनिवार्य प्रश्न और अव्यवस्था (Clutter) से बचना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit199',
    question: 'Google Forms का उपयोग किसके लिए किया जा सकता है?',
    options: [
      'न्यूज़लेटर भेजने के लिए',
      'वेबसाइट बनाने के लिए',
      'सर्वेक्षण प्रतिक्रियाएं और फीडबैक एकत्र करने के लिए',
      'ब्लॉग लेख लिखने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Forms का उपयोग सर्वेक्षण (Surveys), फीडबैक, रजिस्ट्रेशन और क्विज़ के लिए प्रतिक्रियाएं एकत्र करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit200',
    question: 'फॉर्म डिज़ाइन करते समय कौन-सा सर्वोत्तम अभ्यास है?',
    options: [
      'जटिल भाषा का उपयोग करना',
      'संबंधित प्रश्नों को एक साथ समूहित करना',
      'केवल एक प्रश्न पूछना',
      'सभी प्रश्नों को वैकल्पिक बनाना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'फॉर्म डिज़ाइन का एक सर्वोत्तम अभ्यास संबंधित प्रश्नों को एक साथ समूहित (Group) करना है, जिससे फॉर्म भरना आसान हो जाता है।',
  ),
  QuizQuestion(
    id: 'cit201',
    question: 'Remote Collaboration क्या है?',
    options: [
      'केवल अपने शहर के लोगों के साथ काम करना',
      'कंप्यूटर को दूर से संचालित करना',
      'अलग-अलग स्थानों से ऑनलाइन मिलकर कार्य करना',
      'मशीनों को रिमोट से ऑपरेट करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'रिमोट कोलैबोरेशन (Remote Collaboration) का मतलब अलग-अलग भौगोलिक स्थानों पर बैठे लोगों का ऑनलाइन मिलकर काम करना है।',
  ),
  QuizQuestion(
    id: 'cit202',
    question:
        'निम्न में से कौन-सा Tool आमतौर पर Virtual Meetings के लिए उपयोग किया जाता है?',
    options: ['Microsoft Paint', 'Vlc Media Player', 'Zoom', 'Adobe Reader'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Zoom एक लोकप्रिय वीडियो कॉन्फ्रेंसिंग टूल है जिसका उपयोग वर्चुअल मीटिंग के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit203',
    question: 'Google Meet में मीटिंग शुरू करने का सही तरीका क्या है?',
    options: [
      'Google Sheets में "New Sheet" पर क्लिक करना',
      'Meet.google.com पर जाकर "New Meeting" पर क्लिक करना',
      'Youtube खोलकर लाइवस्ट्रीम शुरू करना',
      'Google Docs खोलकर लिंक साझा करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google Meet में मीटिंग शुरू करने के लिए meet.google.com पर जाएं और "New Meeting" विकल्प चुनें।',
  ),
  QuizQuestion(
    id: 'cit204',
    question:
        'Virtual Meeting के दौरान शिष्टाचार बनाए रखने के लिए आपको क्या करना चाहिए?',
    options: [
      'दूसरों की बात काटना',
      'हमेशा माइक्रोफ़ोन ऑन रखना',
      'बेड पर लेटकर कैजुअल कपड़ों में बैठना',
      'जब बात न कर रहे हों तब म्यूट रखना',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'वर्चुअल मीटिंग में शिष्टाचार के लिए जब आप बोल नहीं रहे हों, तो माइक्रोफोन को म्यूट (Mute) रखना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit205',
    question:
        'Google Drive में कौन-सी सुविधा Multiple Users को एक साथ फाइल पर काम करने की अनुमति देती है?',
    options: [
      'Offline Mode',
      'Sync Later',
      'Collaborative Editing',
      'File Locking',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Drive (Docs, Sheets) में Collaborative Editing (सहयोगी संपादन) की सुविधा कई यूजर्स को एक साथ एक फाइल पर काम करने की अनुमति देती है।',
  ),
  QuizQuestion(
    id: 'cit206',
    question:
        'Google Docs में Comment Feature का उपयोग किसलिए किया जा सकता है?',
    options: [
      'कंटेंट डिलीट करने के लिए',
      'Pdf के रूप में सेव करने के लिए',
      'डॉक्यूमेंट को बदलें बिना Feedback देने के लिए',
      'वीडियो अपलोड करने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Comment (कमेंट) फीचर का उपयोग डॉक्यूमेंट में बदलाव किए बिना सुझाव या फीडबैक देने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit207',
    question: 'Shared Files को Manage करते समय कौन-सा Best Practice है?',
    options: [
      'सभी को Editing Access देना',
      'फोल्डर का नाम न रखना',
      'Access Permissions को नियमित रूप से Review करना',
      'सभी फाइलें एक ही फ़ोल्डर में रखना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'शेयर्ड फाइलों को मैनेज करने का एक अच्छा अभ्यास है कि एक्सेस परमिशन्स (Access Permissions) की नियमित रूप से समीक्षा (Review) करें।',
  ),
  QuizQuestion(
    id: 'cit208',
    question: 'Google Drive में Viewer का Role क्या होता है?',
    options: [
      'फ़ाइल Edit कर सकता है',
      'केवल फ़ाइल देख सकता है, Edit या Comment नहीं कर सकता',
      'केवल Comment कर सकता है',
      'सभी एक्सेस को नियंत्रित कर सकता है',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Viewer (दर्शक) की भूमिका वाला व्यक्ति फाइल को केवल देख सकता है, उसे एडिट या कमेंट नहीं कर सकता।',
  ),
  QuizQuestion(
    id: 'cit209',
    question: 'एक Structured Virtual Meeting Agenda में क्या शामिल होना चाहिए?',
    options: [
      'Personal Photos',
      'Internet Memes',
      'चर्चा विषयों और समय का सूचीबद्ध विवरण',
      'Game Links',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एक संरचित (Structured) वर्चुअल मीटिंग एजेंडा में चर्चा के विषयों और उनके लिए निर्धारित समय की सूची शामिल होनी चाहिए।',
  ),
  QuizQuestion(
    id: 'cit210',
    question:
        'आधुनिक कार्य परिवेश में Remote Collaboration क्यों महत्वपूर्ण है?',
    options: [
      'यह लोगों को हमेशा घर से काम करने के लिए मजबूर करता है',
      'यह ऑफिस खर्च बढ़ाता है',
      'यह लचीलापन और वैश्विक टीमवर्क को बढ़ावा देता है',
      'यह ईमेल को पूरी तरह से बदल देता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Remote Collaboration आधुनिक कार्य परिवेश में लचीलापन (Flexibility) और वैश्विक टीमवर्क (Global Teamwork) को बढ़ावा देने के लिए महत्वपूर्ण है।',
  ),
  QuizQuestion(
    id: 'cit211',
    question: 'Digital Security का मुख्य उद्देश्य क्या है?',
    options: [
      'Internet Browsing की गति बढ़ाना',
      'Personal Data और Devices की सुरक्षा करना',
      'बिजली बचाना',
      'Videos सुरक्षित देखना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल सुरक्षा (Digital Security) का मुख्य उद्देश्य आपके व्यक्तिगत डाटा और डिवाइसों को साइबर खतरों से बचाना है।',
  ),
  QuizQuestion(
    id: 'cit212',
    question: 'निम्न में से कौन सा एक Cyber Threat का उदाहरण है?',
    options: [
      'Wi-Fi का उपयोग करना',
      'Youtube देखना',
      'Phishing',
      'E-Books पढ़ना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Phishing (फिशिंग) एक साइबर खतरा (Cyber Threat) है, जबकि अन्य सामान्य ऑनलाइन गतिविधियाँ हैं।',
  ),
  QuizQuestion(
    id: 'cit213',
    question: 'एक मजबूत Password की क्या विशेषता होनी चाहिए?',
    options: [
      'आपका जन्मदिन',
      'सरल और छोटा',
      'Letters, Numbers और Symbols का मिश्रण',
      'अनुमान लगाना आसान हो',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एक मजबूत पासवर्ड में बड़े और छोटे अक्षरों (Letters), संख्याओं (Numbers) और प्रतीकों (Symbols) का मिश्रण होना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit214',
    question: 'एक Password Manager का मुख्य कार्य क्या है?',
    options: [
      'दोस्तों के साथ Password साझा करना',
      'सुरक्षित Password याद रखना और प्रबंधित करना',
      'वायरस बनाना',
      'कंप्यूटर को तेज़ बनाना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Password Manager (पासवर्ड मैनेजर) आपके सभी पासवर्ड्स को सुरक्षित रूप से स्टोर और मैनेज करता है, जिससे आपको उन्हें याद रखने की जरूरत नहीं पड़ती।',
  ),
  QuizQuestion(
    id: 'cit215',
    question: '2FA का पूरा रूप क्या है?',
    options: [
      'Two-Face Authentication',
      'Two-Factor Authentication',
      'Fast Access Authorisation',
      'File Access Application',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        '2FA का पूरा रूप Two-Factor Authentication है। यह सुरक्षा की दो परतें प्रदान करता है।',
  ),
  QuizQuestion(
    id: 'cit216',
    question:
        'निम्न में से कौन सा आपकी Account की सुरक्षा के लिए एक अतिरिक्त Layer प्रदान करता है?',
    options: [
      'Strong Password',
      '2FA का उपयोग करना',
      'कई Devices पर Login करना',
      'Browser खुला रखना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        '2FA (Two-Factor Authentication) आपके अकाउंट की सुरक्षा के लिए पासवर्ड के अलावा एक अतिरिक्त परत (Extra Layer) जोड़ता है।',
  ),
  QuizQuestion(
    id: 'cit217',
    question:
        'यदि आपको कोई संदिग्ध email मिलता है जो आपसे password मांगता है, तो क्या करना चाहिए?',
    options: [
      'तुरंत उत्तर देना',
      'दोस्तों को भेजना',
      'Delete या report करना',
      'Link पर क्लिक करके देखना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'संदिग्ध ईमेल जो पासवर्ड मांगे, उसे तुरंत डिलीट (Delete) कर देना चाहिए या फिशिंग रिपोर्ट करनी चाहिए।',
  ),
  QuizQuestion(
    id: 'cit218',
    question: 'Malware क्या है?',
    options: ['Game', 'Malicious Software', 'Hardware', 'Coding Language'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Malware (मैलवेयर) दुर्भावनापूर्ण सॉफ्टवेयर (Malicious Software) का संक्षिप्त रूप है, जैसे वायरस या रैनसमवेयर।',
  ),
  QuizQuestion(
    id: 'cit219',
    question: 'इनमें से कौन Malware नहीं है?',
    options: ['Ransomware', 'Spreadsheet', 'Trojan', 'Spyware'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Spreadsheet (जैसे Excel) एक एप्लिकेशन सॉफ्टवेयर है, यह Malware नहीं है। Ransomware, Trojan और Spyware Malware के प्रकार हैं।',
  ),
  QuizQuestion(
    id: 'cit220',
    question: 'Antivirus क्या करता है?',
    options: [
      'Storage बढ़ाता है',
      'Games तेज़ करता है',
      'Threats हटाता है',
      'Drives Format करता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एंटीवायरस (Antivirus) सॉफ्टवेयर का मुख्य कार्य कंप्यूटर से खतरों (Threats) जैसे वायरस, मैलवेयर को हटाना है।',
  ),
  QuizQuestion(
    id: 'cit221',
    question: 'संदिग्ध फाइल की पहचान कैसे करें?',
    options: [
      '.Txt फाइल',
      'जाना-पहचाना स्रोत',
      'अजीब नाम/Extension',
      'Auto Open',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'संदिग्ध फाइलों में अक्सर अजीब फाइल नाम या एक्सटेंशन (जैसे .exe) होते हैं जो सामान्य नहीं होते।',
  ),
  QuizQuestion(
    id: 'cit222',
    question: 'किस टूल से खतरे वाली फाइल को Quarantine किया जा सकता है?',
    options: ['Paint', 'Calculator', 'Antivirus', 'Wordpad'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एंटीवायरस सॉफ्टवेयर (Antivirus) खतरनाक फाइलों को क्वारंटाइन (Quarantine) कर सकता है, जिससे वे सिस्टम को नुकसान नहीं पहुंचा सकतीं।',
  ),
  QuizQuestion(
    id: 'cit223',
    question: 'फाइल खोलने से पहले क्या करें?',
    options: ['Share करें', 'Rename करें', 'Scan करें', 'Print करें'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'किसी भी फाइल, खासकर इंटरनेट से डाउनलोड की गई फाइल को खोलने से पहले एंटीवायरस से स्कैन (Scan) कर लेना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit224',
    question: 'सुरक्षित वेबसाइट कौन-सी होती है?',
    options: ['http://', 'ftp://', 'www', 'https://'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'सुरक्षित वेबसाइटें URL में "https://" का उपयोग करती हैं, जो एन्क्रिप्टेड कनेक्शन दर्शाता है।',
  ),
  QuizQuestion(
    id: 'cit225',
    question: 'सॉफ्टवेयर अपडेट न करने पर क्या हो सकता है?',
    options: [
      'ज़्यादा Speed',
      'Battery बढ़ेगी',
      'Security Risk बढ़ेगा',
      'Free Wi-Fi',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सॉफ्टवेयर अपडेट न करने पर सुरक्षा जोखिम (Security Risk) बढ़ जाता है, क्योंकि पुराने सॉफ्टवेयर में कमजोरियाँ हो सकती हैं।',
  ),
  QuizQuestion(
    id: 'cit226',
    question: 'किसे चालू रखें ताकि नए खतरे से बच सकें?',
    options: ['Auto-Play', 'Auto-Save', 'Auto-Update', 'Auto-Shutdown'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑटो-अपडेट (Auto-Update) चालू रखने से सॉफ्टवेयर अपने आप अपडेट होते रहते हैं, जिससे नए खतरों से सुरक्षा बनी रहती है।',
  ),
  QuizQuestion(
    id: 'cit227',
    question: 'Malware कहाँ से आ सकता है?',
    options: [
      'Trusted Store',
      'अनजान ईमेल Attachment',
      'Password Protected फाइल',
      'System Settings',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Malware अक्सर अनजान ईमेल अटैचमेंट (Unknown Email Attachments) या फिशिंग लिंक के माध्यम से आता है।',
  ),
  QuizQuestion(
    id: 'cit228',
    question: 'सॉफ्टवेयर अपडेट न करने पर क्या हो सकता है?',
    options: [
      'ज़्यादा Speed',
      'Battery बढ़ेगी',
      'Security Risk बढ़ेगा',
      'Free Wi-Fi',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सॉफ्टवेयर अपडेट न करने पर सुरक्षा जोखिम (Security Risk) बढ़ जाता है।',
  ),
  QuizQuestion(
    id: 'cit229',
    question: 'किसे चालू रखें ताकि नए खतरे से बच सकें?',
    options: ['Auto-Play', 'Auto-Save', 'Auto-Update', 'Auto-Shutdown'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑटो-अपडेट (Auto-Update) चालू रखने से सॉफ्टवेयर अपने आप अपडेट होते रहते हैं।',
  ),
  QuizQuestion(
    id: 'cit230',
    question: 'Malware कहाँ से आ सकता है?',
    options: [
      'Trusted Store',
      'अनजान ईमेल Attachment',
      'Password Protected फाइल',
      'System Settings',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Malware अक्सर अनजान ईमेल अटैचमेंट (Unknown Email Attachments) के माध्यम से आता है।',
  ),
  QuizQuestion(
    id: 'cit231',
    question: 'Cyber Crime क्या है?',
    options: [
      'ऑनलाइन वीडियो देखना',
      'ईमेल का उपयोग करना',
      'कंप्यूटर या नेटवर्क का उपयोग करके अवैध गतिविधियाँ करना',
      'सॉफ्टवेयर इंस्टॉल करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'साइबर क्राइम (Cyber Crime) वह अवैध गतिविधि है जिसमें कंप्यूटर या इंटरनेट नेटवर्क का उपयोग किया जाता है, जैसे हैकिंग या फ्रॉड।',
  ),
  QuizQuestion(
    id: 'cit232',
    question: 'निम्नलिखित में से कौन-सा साइबर अपराध है?',
    options: [
      'डॉक्यूमेंट बनाना',
      'सोशल मीडिया अकाउंट हैक करना',
      'एंटीवायरस सॉफ्टवेयर का उपयोग करना',
      'पासवर्ड टाइप करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया अकाउंट हैक करना एक साइबर अपराध है, जबकि अन्य सामान्य गतिविधियाँ हैं।',
  ),
  QuizQuestion(
    id: 'cit233',
    question: 'Phishing का क्या मतलब है?',
    options: [
      'बड़ी फाइलें भेजना',
      'फर्जी ईमेल भेजना ताकि जानकारी चुराई जा सके',
      'ऑनलाइन ट्यूटोरियल देखना',
      'इंटरनेट कनेक्शन साझा करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Phishing (फिशिंग) एक साइबर अपराध है जिसमें फर्जी ईमेल या वेबसाइट बनाकर व्यक्तिगत जानकारी चुराई जाती है।',
  ),
  QuizQuestion(
    id: 'cit234',
    question: 'भारत में IT Act किस वर्ष लागू हुआ?',
    options: ['1995', '2000', '2010', '2020'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'भारत में साइबर कानून (Information Technology Act) वर्ष 2000 में लागू हुआ था।',
  ),
  QuizQuestion(
    id: 'cit235',
    question: 'IT Act का मुख्य उद्देश्य क्या है?',
    options: [
      'गेमिंग को बढ़ावा देना',
      'मोबाइल ऐप्स को मैनेज करना',
      'साइबर गतिविधियों को नियंत्रित करना और उपयोगकर्ताओं की सुरक्षा करना',
      'ऑनलाइन शॉपिंग को ट्रैक करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'IT Act (सूचना प्रौद्योगिकी अधिनियम) का मुख्य उद्देश्य साइबर गतिविधियों को वैधानिकता प्रदान करना और उपयोगकर्ताओं की सुरक्षा करना है।',
  ),
  QuizQuestion(
    id: 'cit236',
    question: 'निम्न में से कौन-सा एक उपयोगकर्ता का Digital Right है?',
    options: [
      'डाटा का दुरुपयोग करने का अधिकार',
      'गुमनाम रहने का अधिकार',
      'Privacy और Expression का अधिकार',
      'नियमों से बचने का अधिकार',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Privacy (गोपनीयता) और Expression (अभिव्यक्ति) का अधिकार उपयोगकर्ता के मूलभूत डिजिटल अधिकार (Digital Rights) हैं।',
  ),
  QuizQuestion(
    id: 'cit237',
    question: 'भारत में साइबर क्राइम की रिपोर्ट कहाँ की जा सकती है?',
    options: [
      'Income.gov.in',
      'Cybercrime.gov.in',
      'Google.com',
      'Court.gov.in',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'भारत में साइबर अपराध की शिकायत cybercrime.gov.in पोर्टल पर दर्ज की जा सकती है।',
  ),
  QuizQuestion(
    id: 'cit238',
    question: 'निम्न में से कौन-सा एक सामान्य साइबर अपराध है?',
    options: [
      'ऑनलाइन टिकट बुकिंग',
      'ऑनलाइन बैंकिंग',
      'साइबर बुलिंग',
      'लाइव टीवी देखना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'साइबर बुलिंग (Cyber Bullying) एक सामान्य साइबर अपराध है, जबकि अन्य सामान्य ऑनलाइन सेवाएँ हैं।',
  ),
  QuizQuestion(
    id: 'cit239',
    question: 'साइबर स्केम से बचने का एक तरीका क्या है?',
    options: [
      'अज्ञात लिंक खोलना',
      'पासवर्ड साझा करना',
      'ईमेल और लिंक की जांच करना',
      'अपडेट को नजरअंदाज करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'साइबर स्कैम से बचने के लिए प्राप्त ईमेल और लिंक्स की सावधानीपूर्वक जांच (Verify) करना आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit240',
    question: 'एक इंटरनेट उपयोगकर्ता की मुख्य जिम्मेदारी क्या है?',
    options: [
      'दूसरों का निजी डाटा साझा करना',
      'ऑनलाइन नैतिक व्यवहार करना',
      'संदिग्ध ईमेल को नजरअंदाज करना',
      'एंटीवायरस का उपयोग न करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'एक इंटरनेट उपयोगकर्ता की मुख्य जिम्मेदारी ऑनलाइन नैतिक और जिम्मेदार व्यवहार (Ethical Behavior) करना है।',
  ),
  QuizQuestion(
    id: 'cit241',
    question: 'Online Privacy का मुख्य उद्देश्य क्या है?',
    options: [
      'विज्ञापन को ब्लॉक करना',
      'सब से अपनी पहचान छुपाना',
      'व्यक्तिगत जानकारी को अनधिकृत पहुंच से बचाना',
      'इंटरनेट उपयोग को सीमित करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑनलाइन गोपनीयता (Online Privacy) का मुख्य उद्देश्य आपकी व्यक्तिगत जानकारी को अनधिकृत पहुंच से बचाना है।',
  ),
  QuizQuestion(
    id: 'cit242',
    question: 'सोशल मीडिया पर अत्यधिक जानकारी साझा करने का एक खतरा क्या है?',
    options: [
      'लोकप्रियता में वृद्धि',
      'Data Breach और Identity Theft',
      'तेज इंटरनेट',
      'अनलिमिटेड क्लाउड स्टोरेज',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया पर अत्यधिक जानकारी साझा करने से डाटा ब्रीच (Data Breach) और पहचान की चोरी (Identity Theft) का खतरा बढ़ जाता है।',
  ),
  QuizQuestion(
    id: 'cit243',
    question: 'वेबसाइटों में Cookies का क्या मतलब होता है?',
    options: [
      'एक प्रकार का सुरक्षा सॉफ़्टवेयर',
      'फाइलें, जो यूजर डाटा और पसंद को स्टोर करती हैं',
      'एंटीवायरस प्रोग्राम',
      'ब्राउज़र गेम्स',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Cookies (कुकीज) छोटी टेक्स्ट फाइलें होती हैं जो वेबसाइटें आपके ब्राउज़र में आपकी प्राथमिकताओं और डाटा को स्टोर करने के लिए रखती हैं।',
  ),
  QuizQuestion(
    id: 'cit244',
    question:
        'किसी वेबसाइट पर व्यक्तिगत जानकारी भरने से पहले आपको क्या करना चाहिए?',
    options: [
      'ब्राउज़र बंद कर दें',
      'यह सुनिश्चित करें कि वेबसाइट https का उपयोग कर रही हो',
      'हिस्ट्री क्लियर करें',
      'Incognito Mode चालू करें',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'व्यक्तिगत जानकारी भरने से पहले सुनिश्चित करें कि वेबसाइट सुरक्षित है, यानी उसका URL "https" से शुरू होता है।',
  ),
  QuizQuestion(
    id: 'cit245',
    question:
        'कौन सी सेटिंग यह नियंत्रित करती है कि आपकी पोस्ट कौन देख सकता है?',
    options: [
      'Display Settings',
      'Notification Settings',
      'Privacy Settings',
      'Language Settings',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Privacy Settings (गोपनीयता सेटिंग्स) यह नियंत्रित करती हैं कि आपकी सोशल मीडिया पोस्ट कौन देख सकता है।',
  ),
  QuizQuestion(
    id: 'cit246',
    question: 'संवेदनशील जानकारी को भेजने का सबसे सुरक्षित तरीका कौन-सा है?',
    options: [
      'सार्वजनिक मंच पर पोस्ट करना',
      'Unencrypted Email का उपयोग करना',
      'Encrypted Messaging Apps से साझा करना',
      'सोशल मीडिया पर कमेंट करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'संवेदनशील जानकारी भेजने का सबसे सुरक्षित तरीका एन्क्रिप्टेड मैसेजिंग ऐप्स (जैसे Signal, WhatsApp) का उपयोग करना है।',
  ),
  QuizQuestion(
    id: 'cit247',
    question: 'Identity Theft क्या है?',
    options: [
      'नकली प्रोफाइल बनाना',
      'हैकर द्वारा एंटीवायरस इंस्टॉल करना',
      'किसी का व्यक्तिगत डाटा चुराना और दुरुपयोग करना',
      'प्रमोशनल ईमेल भेजना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Identity Theft (पहचान की चोरी) तब होती है जब कोई आपकी व्यक्तिगत जानकारी (जैसे आधार, पैन) चुराकर आपके नाम पर धोखाधड़ी करता है।',
  ),
  QuizQuestion(
    id: 'cit248',
    question: 'ऑनलाइन ट्रैक होने से बचने का एक अच्छा तरीका क्या है?',
    options: [
      'हमेशा वेबसाइट्स में लॉग इन रहना',
      'ब्राउज़र सुरक्षा फीचर्स को डिसेबल करना',
      'Private/Incognito Mode का उपयोग करना',
      'बिना जाँचे सभी Cookies स्वीकार करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑनलाइन ट्रैकिंग से बचने के लिए प्राइवेट (Private) या इन्कॉग्निटो (Incognito) मोड का उपयोग करना एक अच्छा तरीका है।',
  ),
  QuizQuestion(
    id: 'cit249',
    question: 'Identity Fraud को रोकने में क्या मदद कर सकता है?',
    options: [
      'आसान पासवर्ड का उपयोग',
      'दोस्तों के साथ पासवर्ड साझा करना',
      'Phishing E-Mails और संदिग्ध लिंक से बचना',
      'फ्री गिफ्ट के पॉपअप्स पर क्लिक करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फिशिंग ईमेल और संदिग्ध लिंक से बचना पहचान की धोखाधड़ी (Identity Fraud) को रोकने में मदद करता है।',
  ),
  QuizQuestion(
    id: 'cit250',
    question: 'वेबसाइट यूज़र्स से डाटा कैसे एकत्र करती हैं?',
    options: [
      'वॉइस कमांड के जरिए',
      'कैमरा एक्सेस के जरिए',
      'Scripts और Cookies के जरिए यूज़र बिहेवियर को ट्रैक कर',
      'ऑफलाइन सर्वे के माध्यम से',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'वेबसाइट्स स्क्रिप्ट्स और कुकीज (Cookies) के माध्यम से यूजर के व्यवहार को ट्रैक करके डाटा एकत्र करती हैं।',
  ),
  QuizQuestion(
    id: 'cit251',
    question: 'Cyber Harassment क्या है?',
    options: [
      'कार्य से संबंधित ईमेल भेजना',
      'डिजिटल प्लेटफ़ॉर्म के माध्यम से अनचाहा, धमकीपूर्ण या अपमानजनक व्यवहार करना',
      'ऑनलाइन मीटिंग में भाग लेना',
      'व्यक्तिगत फोटो पोस्ट करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'साइबर उत्पीड़न (Cyber Harassment) डिजिटल प्लेटफॉर्म (जैसे सोशल मीडिया) के माध्यम से किया जाने वाला दुर्व्यवहार है।',
  ),
  QuizQuestion(
    id: 'cit252',
    question: 'इनमें से कौन-सा Cyber Bullying का उदाहरण है?',
    options: [
      'एक सुरक्षित पासवर्ड बनाना',
      'नकली समाचार साझा करना',
      'बार-बार अपमानजनक मैसेज भेजना',
      'समाचार अपडेट शेयर करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'बार-बार अपमानजनक मैसेज भेजना साइबर बुलिंग (Cyber Bullying) का एक उदाहरण है।',
  ),
  QuizQuestion(
    id: 'cit253',
    question: 'Doxxing क्या है?',
    options: [
      'प्रोफाइल चित्र बदलना',
      'बिना अनुमति के किसी की निजी जानकारी ऑनलाइन साझा करना',
      'अपनी सोशल मीडिया पोस्ट हटाना',
      'ऑनलाइन गेम खेलना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Doxxing (डॉक्सिंग) किसी की निजी जानकारी (जैसे पता, फोन नंबर) को बिना अनुमति के ऑनलाइन सार्वजनिक करने का कृत्य है।',
  ),
  QuizQuestion(
    id: 'cit254',
    question:
        'यदि आपको साइबर बुली किया जा रहा है, तो सबसे पहला कदम क्या होना चाहिए?',
    options: [
      'अपने अकाउंट को अनदेखा करें',
      'प्रोफाइल डिलीट करें',
      'स्क्रीन शॉट लें और रिपोर्ट करें',
      'गुस्से में जवाब दें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'साइबर बुलिंग होने पर सबूत के लिए स्क्रीनशॉट लें और तुरंत उस प्लेटफॉर्म पर रिपोर्ट करें।',
  ),
  QuizQuestion(
    id: 'cit255',
    question: 'भारत में Cyber Stalking के लिए कानूनी प्रावधान कौन-सा है?',
    options: [
      'IT Act Section 66C',
      'Ipc Section 354D',
      'Income Tax Act',
      'Banking Regulation Act',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'भारत में साइबर स्टॉकिंग (Cyber Stalking) के लिए IPC की धारा 354D में कानूनी प्रावधान है।',
  ),
  QuizQuestion(
    id: 'cit256',
    question: 'Cyber Harassment पीड़ितों पर क्या प्रभाव डाल सकता है?',
    options: [
      'आत्मविश्वास में वृद्धि',
      'बेहतर संचार कौशल',
      'तनाव, चिंता और अवसाद',
      'कोई प्रभाव नहीं',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'साइबर उत्पीड़न (Cyber Harassment) पीड़ितों में तनाव (Stress), चिंता (Anxiety) और अवसाद (Depression) जैसे गंभीर मानसिक प्रभाव डाल सकता है।',
  ),
  QuizQuestion(
    id: 'cit257',
    question:
        'अपनी व्यक्तिगत जानकारी को सुरक्षित रूप से साझा करने का सबसे अच्छा तरीका कौन-सा है?',
    options: [
      'सार्वजनिक मंचों पर पोस्ट करें',
      'कमेंट्स में साझा करें',
      'केवल सुरक्षित और भरोसेमंद प्लेटफ़ॉर्म पर साझा करें',
      'सोशल मीडिया बायो में डालें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'व्यक्तिगत जानकारी साझा करने का सबसे अच्छा तरीका केवल सुरक्षित (Secure) और भरोसेमंद (Trusted) प्लेटफॉर्म का उपयोग करना है।',
  ),
  QuizQuestion(
    id: 'cit258',
    question: 'सोशल मीडिया पर Privacy कैसे प्रबंधित करें?',
    options: [
      'प्रोफ़ाइल को सार्वजनिक छोड़ें',
      'प्राइवेसी सेटिंग्स को अनदेखा करें',
      'दृश्यता समायोजित करें और नियंत्रित करें कि कौन आपकी सामग्री देख सकता है',
      'बार-बार पोस्ट करें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया पर गोपनीयता प्रबंधित करने के लिए प्राइवेसी सेटिंग्स में जाकर यह समायोजित (Adjust) करें कि आपकी सामग्री कौन देख सकता है।',
  ),
  QuizQuestion(
    id: 'cit259',
    question: 'इनमें से कौन-सा टूल Online Abuse को रोकने में मदद करता है?',
    options: [
      'Like बटन',
      'Share बटन',
      'Block और Report विकल्प',
      'Add To Playlist',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया पर ऑनलाइन दुर्व्यवहार (Online Abuse) को रोकने के लिए "Block" (ब्लॉक) और "Report" (रिपोर्ट) विकल्प मदद करते हैं।',
  ),
  QuizQuestion(
    id: 'cit260',
    question: 'भारत में साइबर अपराध की ऑनलाइन रिपोर्ट कहाँ की जा सकती है?',
    options: [
      'www.email.com',
      'www.photoshare.net',
      'www.cybercrime.gov.in',
      'www.onlinegames.org',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'भारत में साइबर अपराध की ऑनलाइन शिकायत www.cybercrime.gov.in पर की जा सकती है।',
  ),
  QuizQuestion(
    id: 'cit261',
    question: 'स्मार्टफोन के दो सबसे आम Operating Systems कौन से हैं?',
    options: [
      'Windows और Linux',
      'Android और iOS',
      'Java और Symbian',
      'Chrome और Ubuntu',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'दुनिया भर में स्मार्टफोन में सबसे ज्यादा उपयोग किए जाने वाले ऑपरेटिंग सिस्टम Android और iOS हैं।',
  ),
  QuizQuestion(
    id: 'cit262',
    question:
        'कौन-सी सुविधा स्मार्टफोन को वायरलेस तरीके से इंटरनेट से जोड़ती है?',
    options: ['Bluetooth', 'NFC', 'Wi-Fi', 'GPS'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Wi-Fi (वाई-फाई) एक वायरलेस तकनीक है जो स्मार्टफोन को बिना केबल के इंटरनेट से जोड़ती है।',
  ),
  QuizQuestion(
    id: 'cit263',
    question: 'Android फ़ोन में ऐप्स कहाँ से डाउनलोड किए जाते हैं?',
    options: ['App Store', 'Play Store', 'Windows Store', 'Amazon Store'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Android फोन में ऐप्स डाउनलोड करने का आधिकारिक स्टोर "Google Play Store" है।',
  ),
  QuizQuestion(
    id: 'cit264',
    question: 'Airplane Mode का क्या उद्देश्य है?',
    options: [
      'Screen Brightness बढ़ाना',
      'Signal Strength बढ़ाना',
      'Wireless Communication को बंद करना',
      'केवल Gps चालू करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Airplane Mode (हवाई जहाज मोड) सभी वायरलेस कम्युनिकेशन (Wi-Fi, Bluetooth, Cellular) को एक साथ बंद कर देता है।',
  ),
  QuizQuestion(
    id: 'cit265',
    question: 'ऐप्स को नियमित रूप से अपडेट करना क्यों ज़रूरी है?',
    options: [
      'Battery Life कम करने के लिए',
      'अधिक Data उपयोग के लिए',
      'Bugs को ठीक करने और Security बढ़ाने के लिए',
      'App Icon बदलने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऐप्स को अपडेट करने से उनमें मौजूद Bugs (त्रुटियाँ) ठीक होती हैं और सुरक्षा (Security) बढ़ती है।',
  ),
  QuizQuestion(
    id: 'cit266',
    question: 'कौन-सी Setting फ़ोन को सुरक्षित लॉक करने में मदद करती है?',
    options: [
      'Display Mode',
      'Notification Tone',
      'Password या Biometric Lock',
      'Wallpaper Settings',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फोन को सुरक्षित लॉक करने के लिए Password (पासवर्ड), PIN, Pattern या Biometric Lock (फिंगरप्रिंट, फेस अनलॉक) सेट करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit267',
    question: '"Permissions" Setting क्या नियंत्रित करती है?',
    options: [
      'Font Size',
      'Camera, Location, Contacts जैसे डाटा की पहुँच',
      'App Icon',
      'Screen Timeout',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Permissions (अनुमतियाँ) सेटिंग यह नियंत्रित करती है कि कोई ऐप आपके कैमरा, लोकेशन या कॉन्टैक्ट्स जैसे डाटा का उपयोग कर सकता है या नहीं।',
  ),
  QuizQuestion(
    id: 'cit268',
    question: 'App Security के लिए सबसे अच्छी प्रथा है?',
    options: [
      'अनजान स्रोतों से ऐप इंस्टॉल करना',
      'Password दूसरों से शेयर करना',
      'App Permissions को नियमित रूप से जांचना',
      'Update Notifications को नजरअंदाज करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऐप सिक्योरिटी के लिए यह एक अच्छी प्रथा है कि आप ऐप्स को दी गई अनुमतियों (Permissions) की नियमित रूप से जांच करें।',
  ),
  QuizQuestion(
    id: 'cit269',
    question: 'Smartphone पर डाटा Backup का सबसे सुरक्षित तरीका क्या है?',
    options: [
      'कागज़ पर लिख लेना',
      'Cloud Storage या Backup Apps का उपयोग करना',
      'फ़ोन को उपयोग न करना',
      'पुराने Apps को Delete करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'स्मार्टफोन डाटा बैकअप का सबसे सुरक्षित तरीका क्लाउड स्टोरेज (जैसे Google Drive, iCloud) या बैकअप ऐप्स का उपयोग करना है।',
  ),
  QuizQuestion(
    id: 'cit270',
    question: 'Factory Reset करने से क्या होता है?',
    options: [
      'फ़ोन नई Version में Update होता है',
      'Files Backup होती हैं',
      'सभी डाटा डिलीट होकर Original Settings Restore होती हैं',
      'Battery Size बढ़ती है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Factory Reset (फैक्ट्री रीसेट) फोन के सभी डाटा और सेटिंग्स को डिलीट करके उसे फैक्ट्री (जैसा खरीदा था) स्थिति में ले आता है।',
  ),
  QuizQuestion(
    id: 'cit271',
    question: 'Google Maps का मुख्य उद्देश्य क्या है?',
    options: [
      'संगीत सुनना',
      'ईमेल भेजना',
      'नेविगेशन और लोकेशन सर्च',
      'सोशल मीडिया चैटिंग',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Maps का मुख्य उद्देश्य नेविगेशन (रास्ता दिखाना) और लोकेशन सर्च (जगह ढूंढना) है।',
  ),
  QuizQuestion(
    id: 'cit272',
    question: 'Real-Time यात्रा के लिए Google Maps कौन-सी सुविधा देता है?',
    options: [
      'Video Editing',
      'Traffic Updates',
      'Antivirus Scanning',
      'Calendar Reminders',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google Maps रियल-टाइम में ट्रैफिक की जानकारी (Traffic Updates) देता है, जिससे भीड़भाड़ से बचा जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit273',
    question:
        'किसी स्थान को खोजने के लिए Google Maps के Search Bar में क्या डालना चाहिए?',
    options: [
      'Hashtags',
      'पूरा ईमेल पता',
      'स्थान का नाम या Address',
      'वेबसाइट Url',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Maps में सर्च बार में स्थान का नाम (Place Name) या पूरा पता (Address) डालकर खोजा जाता है।',
  ),
  QuizQuestion(
    id: 'cit274',
    question:
        'Google Maps का कौन-सा View आपको ऐसा महसूस कराता है, जैसे आप सड़क पर चल रहे हों?',
    options: ['Map View', 'Earth View', 'Street View', 'List View'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Street View (स्ट्रीट व्यू) एक फीचर है जो आपको 360-डिग्री व्यू देता है, मानो आप असल में उस सड़क पर खड़े हों।',
  ),
  QuizQuestion(
    id: 'cit275',
    question: 'Google Maps में आप कौन-कौन से यात्रा मोड चुन सकते हैं?',
    options: [
      'Surfing और Flying',
      'Running और Swimming',
      'Driving, Walking, Public Transport',
      'Typing और Gaming',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Maps ड्राइविंग (Driving), वॉकिंग (Walking), पब्लिक ट्रांसपोर्ट (Public Transport) और साइकिल (Biking) के विकल्प देता है।',
  ),
  QuizQuestion(
    id: 'cit276',
    question: 'Offline Maps का उपयोग कब करना चाहिए?',
    options: [
      'Music सुनते समय',
      'जब Internet कनेक्शन न हो',
      'Phone Call के दौरान',
      'Documents अपलोड करते समय',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'ऑफलाइन मैप्स (Offline Maps) का उपयोग तब किया जाता है जब आपके पास इंटरनेट कनेक्शन न हो।',
  ),
  QuizQuestion(
    id: 'cit277',
    question: 'Offline उपयोग के लिए Map कैसे डाउनलोड करते हैं?',
    options: [
      'Pdf में सेव करके',
      'लोकेशन मेन्यू में "Download" ऑप्शन से',
      'Screenshot लेकर',
      'Address कॉपी-पेस्ट करके',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google Maps में ऑफलाइन यूज के लिए मैप डाउनलोड करने के लिए लोकेशन पर टैप करें और "Download" ऑप्शन चुनें।',
  ),
  QuizQuestion(
    id: 'cit278',
    question: 'Google Maps में Live Location शेयर करने का लाभ क्या है?',
    options: [
      'Gaming Speed बढ़ जाती है',
      'दोस्त और परिवार आपकी Location Real-Time में देख सकते हैं',
      'Internet Speed तेज हो जाती है',
      'पासवर्ड स्टोर होता है',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Live Location शेयर करने से आपके दोस्त या परिवार रियल-टाइम में देख सकते हैं कि आप कहाँ हैं, जो सुरक्षा के लिए उपयोगी है।',
  ),
  QuizQuestion(
    id: 'cit279',
    question:
        'Google Maps में Privacy सुरक्षित रखने के लिए कौन-सी Setting उपयोगी है?',
    options: [
      'Video Filters',
      'Dark Mode',
      'Location Sharing Time Limits और Permissions',
      'Color Themes',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'गूगल मैप्स में प्राइवेसी के लिए लोकेशन शेयरिंग का समय सीमित (Time Limits) करने और अनुमतियों (Permissions) को मैनेज करने की सेटिंग उपयोगी है।',
  ),
  QuizQuestion(
    id: 'cit280',
    question: 'Location Sharing के लिए एक अच्छा Safety Tip क्या है?',
    options: [
      'Group Chat में सबको शेयर करें',
      'GPS बंद करके शेयर करें',
      'केवल Trusted Contacts के साथ शेयर करें',
      'हमेशा के लिए Location शेयर करें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'लोकेशन शेयर करने का एक अच्छा सेफ्टी टिप है कि इसे केवल विश्वसनीय (Trusted) कॉन्टैक्ट्स के साथ ही शेयर करें।',
  ),
  QuizQuestion(
    id: 'cit281',
    question: 'निम्न में से कौन सा पेशेवर नेटवर्किंग के लिए है?',
    options: ['Facebook', 'Instagram', 'Linkedin', 'Whatsapp'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'LinkedIn दुनिया का सबसे बड़ा प्रोफेशनल नेटवर्किंग प्लेटफॉर्म है, जिसका उपयोग करियर और बिजनेस कनेक्शन के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit282',
    question: 'सोशल मीडिया का एक बड़ा जोखिम क्या है?',
    options: [
      'मुफ्त सामग्री',
      'गोपनीयता का उल्लंघन',
      'त्वरित अपडेट',
      'रीयल-टाइम चैट',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया का एक बड़ा जोखिम गोपनीयता का उल्लंघन (Privacy Violation) है, क्योंकि व्यक्तिगत जानकारी गलत हाथों में जा सकती है।',
  ),
  QuizQuestion(
    id: 'cit283',
    question:
        'एक नया सोशल मीडिया खाता बनाने के लिए आमतौर पर क्या आवश्यक होता है?',
    options: [
      'बैंक खाता नंबर',
      'ईमेल या फ़ोन नंबर',
      'पासपोर्ट नंबर',
      'घर का पता',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया (जैसे Facebook, Instagram) पर नया खाता बनाने के लिए आमतौर पर ईमेल आईडी या फोन नंबर की आवश्यकता होती है।',
  ),
  QuizQuestion(
    id: 'cit284',
    question: 'किस फ़ीचर से आप अपनी पोस्ट कौन देख सकता है, यह तय कर सकते हैं?',
    options: [
      'नोटिफिकेशन',
      'डाटा उपयोग',
      'गोपनीयता सेटिंग्स',
      'डिस्प्ले सेटिंग्स',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'गोपनीयता सेटिंग्स (Privacy Settings) में जाकर आप तय कर सकते हैं कि आपकी पोस्ट कौन देख सकता है।',
  ),
  QuizQuestion(
    id: 'cit285',
    question: 'आपको सोशल मीडिया पर सार्वजनिक रूप से क्या साझा नहीं करना चाहिए?',
    options: ['शौक', 'यात्रा की तस्वीरें', 'जन्मतिथि और पता', 'प्रोफाइल फोटो'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया पर जन्मतिथि (Date of Birth) और पता (Address) जैसी निजी जानकारी सार्वजनिक रूप से साझा करने से बचना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit286',
    question: 'डिजिटल फुटप्रिंट का क्या मतलब है?',
    options: [
      'आपकी पोस्ट पर मिले लाइक की संख्या',
      'आपकी ऑनलाइन छोड़ी गई जानकारी की छाप',
      'आपके अनुयायियों और मित्रों की संख्या',
      'आपकी इंटरनेट स्पीड',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल फुटप्रिंट (Digital Footprint) इंटरनेट पर आपके द्वारा छोड़ी गई डाटा की छाप होती है, जैसे कमेंट, लाइक, और हिस्ट्री।',
  ),
  QuizQuestion(
    id: 'cit287',
    question: 'निम्न में से कौन सी जिम्मेदार सोशल मीडिया आदत नहीं है?',
    options: [
      'तथ्य सत्यापित करना',
      'दूसरों की राय का सम्मान करना',
      'फर्जी खबरें फैलाना',
      'शिष्ट भाषा का प्रयोग करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फर्जी खबरें (Fake News) फैलाना एक गैर-जिम्मेदार सोशल मीडिया आदत है।',
  ),
  QuizQuestion(
    id: 'cit288',
    question: 'अगर कोई गाली-गलौज वाला संदेश भेजे तो क्या करना चाहिए?',
    options: [
      'दूसरों को दिखाना',
      'बहस करना',
      'उसे ब्लॉक और रिपोर्ट करें',
      'अनदेखा करके चैट करना जारी रखें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'अभद्र संदेश मिलने पर उपयोगकर्ता को ब्लॉक (Block) और रिपोर्ट (Report) करना सही कदम है।',
  ),
  QuizQuestion(
    id: 'cit289',
    question: 'अपनी सोशल मीडिया सुरक्षा के लिए आपको क्या करना चाहिए?',
    options: [
      'ज्यादा फोटो पोस्ट करना',
      'कमजोर पासवर्ड रखना',
      'टू-फैक्टर ऑथेंटिकेशन ऑन करना',
      'सभी फ्रेंड रिक्वेस्ट स्वीकार करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया सुरक्षा के लिए टू-फैक्टर ऑथेंटिकेशन (2FA) चालू करना बहुत जरूरी है।',
  ),
  QuizQuestion(
    id: 'cit290',
    question: 'सोशल मीडिया पर किसी यूज़र को रिपोर्ट करने से क्या होता है?',
    options: [
      'आपका खाता डिलीट हो जाता है',
      'आपकी शिकायत प्लेटफॉर्म को भेजी जाती है',
      'वह पोस्ट वायरल हो जाती है',
      'उन्हें एडमिन बना दिया जाता है',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'किसी यूजर को रिपोर्ट (Report) करने पर उस यूजर के खिलाफ आपकी शिकायत सोशल मीडिया प्लेटफॉर्म को भेजी जाती है।',
  ),
  QuizQuestion(
    id: 'cit291',
    question: 'UPI का पूरा नाम क्या है?',
    options: [
      'Unified Personal Interface',
      'Universal Payment Identification',
      'Unified Payments Interface',
      'Unique Payment Identifier',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'UPI का पूरा नाम Unified Payments Interface है। यह भारत सरकार का एक रियल-टाइम भुगतान प्रणाली है।',
  ),
  QuizQuestion(
    id: 'cit292',
    question: 'इनमें से कौन सा डिजिटल पेमेंट ऐप नहीं है?',
    options: ['Google Pay', 'PhonePe', 'WhatsApp', 'Paytm'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'WhatsApp मुख्य रूप से एक मैसेजिंग ऐप है, हालाँकि इसमें पेमेंट फीचर है, लेकिन यह मुख्यतः पेमेंट ऐप नहीं है। Google Pay, PhonePe और Paytm डिजिटल पेमेंट ऐप हैं।',
  ),
  QuizQuestion(
    id: 'cit293',
    question: 'UPI ट्रांजैक्शन पूरा करने के लिए क्या जरूरी होता है?',
    options: ['Email address', 'UPI PIN', 'ATM कार्ड स्वाइप', 'Aadhaar नंबर'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'UPI ट्रांजैक्शन को पूरा करने और पैसे डेबिट करने के लिए UPI PIN (पिन) डालना अनिवार्य है।',
  ),
  QuizQuestion(
    id: 'cit294',
    question: 'Mobile Wallets कहाँ से डाउनलोड करने चाहिए?',
    options: [
      'Random Websites',
      'Sms Links',
      'Official App Stores (Play Store/App Store)',
      'Email Attachments',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'मोबाइल वॉलेट (जैसे Paytm) हमेशा आधिकारिक ऐप स्टोर (Google Play Store या Apple App Store) से ही डाउनलोड करने चाहिए।',
  ),
  QuizQuestion(
    id: 'cit295',
    question: 'अगर कोई अनजान Qr Code मिलता है तो क्या करना चाहिए?',
    options: [
      'तुरंत स्कैन करें',
      'इग्नोर करके डिलीट करें',
      'दूसरों के साथ शेयर करें',
      'सोशल मीडिया पर पोस्ट करें',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'अनजान QR Code को कभी स्कैन नहीं करना चाहिए; इसे नज़रअंदाज (Ignore) करके डिलीट कर देना चाहिए क्योंकि यह फ्रॉड हो सकता है।',
  ),
  QuizQuestion(
    id: 'cit296',
    question: 'पेमेंट ऐप्स को अपडेट करना क्यों जरूरी है?',
    options: [
      'बैटरी बचाने के लिए',
      'नए ऑफर पाने के लिए',
      'सुरक्षा बढ़ाने और बग्स ठीक करने के लिए',
      'ऐप को सुंदर बनाने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पेमेंट ऐप्स को अपडेट करने से सुरक्षा बढ़ती है और बग्स (त्रुटियाँ) ठीक होती हैं।',
  ),
  QuizQuestion(
    id: 'cit297',
    question: 'UPI Id का उपयोग किस लिए होता है?',
    options: [
      'Email लॉगिन के लिए',
      'पैसा भेजने और प्राप्त करने के लिए',
      'वीडियो देखने के लिए',
      'Wi-Fi कनेक्ट करने के लिए',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'UPI ID (जैसे name@okhdfcbank) का उपयोग पैसे भेजने और प्राप्त करने के लिए एक वर्चुअल पते की तरह किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit298',
    question:
        'पैसा सुरक्षित रूप से प्राप्त करने का सबसे अच्छा तरीका कौन सा है?',
    options: [
      'UPI PIN डालना',
      'OTP शेयर करना',
      'UPI Id शेयर करना',
      'अनजान लिंक पर क्लिक करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पैसे सुरक्षित रूप से प्राप्त करने के लिए आप केवल अपनी UPI ID (VPA) साझा कर सकते हैं। UPI PIN या OTP कभी साझा न करें।',
  ),
  QuizQuestion(
    id: 'cit299',
    question: 'अगर आपको पेमेंट फ्रॉड का शक हो तो क्या करना चाहिए?',
    options: [
      'कुछ न करें',
      'दोस्त को कॉल करें',
      'ऐप या बैंक को तुरंत रिपोर्ट करें',
      'रीफंड का इंतजार करें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पेमेंट फ्रॉड का शक होने पर तुरंत संबंधित भुगतान ऐप या अपने बैंक को रिपोर्ट करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit300',
    question: 'Qr Code स्कैन करने पर सामान्यतः क्या होता है?',
    options: [
      'वीडियो चलता है',
      'कॉल शुरू होता है',
      'व्यापारी को पैसा भेजा जाता है',
      'गूगल मेप खुलता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पेमेंट QR Code स्कैन करने पर आमतौर पर व्यापारी (Merchant) को पैसे भेजने का पेज खुलता है।',
  ),
  QuizQuestion(
    id: 'cit301',
    question: 'Online Shopping का मुख्य लाभ क्या है?',
    options: [
      'फ्री फूड डिलीवरी',
      'प्रोडक्ट का फिजिकल ट्रायल',
      'सुविधा और होम डिलीवरी',
      'बिना पेमेंट के शॉपिंग',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑनलाइन शॉपिंग का मुख्य लाभ घर बैठे सुविधा (Convenience) और होम डिलीवरी (Home Delivery) है।',
  ),
  QuizQuestion(
    id: 'cit302',
    question: 'इनमें से कौन सा भारत में विश्वसनीय ई-कॉमर्स प्लेटफॉर्म है?',
    options: ['Myntra', 'Reddit', 'Instagram', 'Pinterest'],
    correctIndex: 0,
    subject: 'BS-CIT',
    description:
        'Myntra एक विश्वसनीय भारतीय ई-कॉमर्स प्लेटफॉर्म है जो फैशन उत्पाद बेचता है।',
  ),
  QuizQuestion(
    id: 'cit303',
    question: 'Online Shopping वेबसाइट पर अकाउंट बनाने का पहला कदम क्या है?',
    options: [
      'आइटम सर्च करना',
      'OTP डालना',
      '"Sign Up" या "Create Account" पर जाना',
      '"Return Policy" क्लिक करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑनलाइन शॉपिंग साइट पर अकाउंट बनाने के लिए सबसे पहले "Sign Up" या "Create Account" पर क्लिक करना होता है।',
  ),
  QuizQuestion(
    id: 'cit304',
    question: 'प्रोडक्ट रिव्यू पढ़ना क्यों ज़रूरी है?',
    options: [
      'कीमत बढ़ाने के लिए',
      'डिलीवरी पर्सन का नाम जानने के लिए',
      'दूसरों से प्रोडक्ट की गुणवत्ता समझने के लिए',
      'डिस्काउंट कूपन पाने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'प्रोडक्ट रिव्यू (Product Reviews) पढ़ने से आपको अन्य ग्राहकों के अनुभव से उत्पाद की गुणवत्ता समझने में मदद मिलती है।',
  ),
  QuizQuestion(
    id: 'cit305',
    question: 'Seller Rating से आपको क्या पता चलता है?',
    options: [
      'सेलर की उम्र',
      'सेलर का स्थान',
      'सेलर की विश्वसनीयता',
      'प्रोडक्ट की Expiry Date',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Seller Rating (विक्रेता रेटिंग) आपको बताता है कि विक्रेता कितना विश्वसनीय (Reliable) है और उसकी सेवा कैसी है।',
  ),
  QuizQuestion(
    id: 'cit306',
    question: 'इनमें से कौन सी सुरक्षित भुगतान विधि है?',
    options: [
      'कार्ड नंबर WhatsApp पर भेजना',
      'भरोसेमंद ऐप पर UPI का इस्तेमाल',
      'फोन पर OTP शेयर करना',
      'किसी अजनबी को कैश देना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'भरोसेमंद ऐप (Trusted App) पर UPI का उपयोग करना एक सुरक्षित भुगतान विधि है।',
  ),
  QuizQuestion(
    id: 'cit307',
    question: 'Payment के समय सुरक्षित वेबसाइट की पहचान क्या है?',
    options: [
      'बहुत सारे Ads होना',
      'URL "Http" से शुरू होना',
      'Login की आवश्यकता न होना',
      'URL "Https" से शुरू होना',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'भुगतान करते समय सुरक्षित वेबसाइट की पहचान URL का "https://" से शुरू होना और लॉक आइकन है।',
  ),
  QuizQuestion(
    id: 'cit308',
    question: 'अगर आपको नकली प्रोडक्ट मिले तो क्या करें?',
    options: [
      'आइटम तोड़ दें',
      'सेलर को फोन करें',
      'प्लेटफॉर्म से Return या Replacement Request करें',
      'Online Shopping बंद कर दें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'नकली या खराब प्रोडक्ट मिलने पर ई-कॉमर्स प्लेटफॉर्म के माध्यम से रिटर्न (Return) या रिप्लेसमेंट (Replacement) का अनुरोध करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit309',
    question: 'ई-कॉमर्स प्लेटफॉर्म पर Customer Support से कैसे संपर्क करें?',
    options: [
      'प्रोडक्ट वापस भेज कर',
      'सोशल मीडिया पर कमेंट करके',
      'Live Chat, Call या Email से',
      'प्रोडक्ट Manufacturer को कॉल करके',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ई-कॉमर्स प्लेटफॉर्म पर कस्टमर सपोर्ट से संपर्क करने के लिए आमतौर पर लाइव चैट (Live Chat), कॉल या ईमेल के विकल्प होते हैं।',
  ),
  QuizQuestion(
    id: 'cit310',
    question:
        'इनमे से कौन सी Online Shopping के दौरान अच्छी प्रैक्टिस नहीं है?',
    options: [
      'Trusted Payment Methods का इस्तेमाल',
      'Seller Rating चेक करना',
      'OTP दूसरों से शेयर करना',
      'Return Policy पढ़ना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'OTP (One Time Password) किसी के साथ साझा करना एक बहुत ही खतरनाक प्रैक्टिस है और यह अच्छी प्रैक्टिस नहीं है।',
  ),
  QuizQuestion(
    id: 'cit311',
    question: 'Online Booking का एक लाभ क्या है?',
    options: [
      'ऑफिस जाना पड़ता है',
      'केवल ऑफिस टाइम में संभव',
      'कहीं से भी, कभी भी बुकिंग संभव',
      'केवल नकद भुगतान पर काम करता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑनलाइन बुकिंग (जैसे IRCTC) का सबसे बड़ा लाभ यह है कि आप कभी भी और कहीं से भी बुकिंग कर सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit312',
    question: 'ऑनलाइन बुकिंग की पहली स्टेप क्या है?',
    options: [
      'स्टोर जाएं',
      'बुकिंग वेबसाइट पर अकाउंट बनाएं',
      'प्रोवाइडर को कॉल करें',
      'ऑफलाइन फॉर्म भरें',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'ऑनलाइन बुकिंग की पहली स्टेप संबंधित वेबसाइट पर अकाउंट बनाना (Sign Up) या लॉगिन करना होता है।',
  ),
  QuizQuestion(
    id: 'cit313',
    question: 'इनमें से कौन-सी एक बुकिंग सेवा है?',
    options: [
      'Youtube पर वीडियो देखना',
      'IRCTC से ट्रेन टिकट बुक करना',
      'ऑनलाइन समाचार पढ़ना',
      'मोबाइल पर गेम खेलना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'IRCTC (Indian Railway Catering and Tourism Corporation) एक बुकिंग सेवा है, विशेष रूप से रेल टिकटों के लिए।',
  ),
  QuizQuestion(
    id: 'cit314',
    question: 'बुकिंग विकल्प खोजने में Filters क्यों ज़रूरी हैं?',
    options: [
      'वेबसाइट को भ्रमित करने के लिए',
      'रेंडम रिजल्ट देखने के लिए',
      'Price, Rating और Availability से सर्च को सीमित करने के लिए',
      'कोई निर्णय न लेने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Filters (फ़िल्टर) आपको कीमत (Price), रेटिंग (Rating) और उपलब्धता (Availability) के आधार पर सर्च रिजल्ट्स को सीमित (Limit) करने में मदद करते हैं।',
  ),
  QuizQuestion(
    id: 'cit315',
    question: 'ऑनलाइन बुकिंग के लिए एक सामान्य भुगतान विधि कौन-सी है?',
    options: ['Barter', 'Cheque', 'UPI या Debit Card', 'Cash In Envelope'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑनलाइन बुकिंग के लिए UPI, डेबिट कार्ड (Debit Card), क्रेडिट कार्ड (Credit Card) और नेट बैंकिंग सामान्य भुगतान विधियाँ हैं।',
  ),
  QuizQuestion(
    id: 'cit316',
    question: 'एक सुरक्षित Payment Website को कैसे पहचानें?',
    options: [
      '"Http" से शुरू होती है।',
      'बहुत से Pop-Up Ads दिखाती है।',
      '"Https" से शुरू होती है और Lock Icon दिखता है।',
      'कई बार Redirect करती है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एक सुरक्षित भुगतान वेबसाइट की पहचान URL के "https" से शुरू होने और एड्रेस बार में लॉक आइकन (Lock Icon) से होती है।',
  ),
  QuizQuestion(
    id: 'cit317',
    question: 'बुकिंग से पहले क्या चेक करना चाहिए?',
    options: [
      'मौसम की भविष्यवाणी',
      'कैंसिलेशन और रिफंडस पॉलिसी',
      'कितने लोग ऑनलाइन हैं।',
      'वेबसाइट का टेक्स्ट कितना लंबा है।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'बुकिंग करने से पहले कैंसिलेशन और रिफंड पॉलिसी (Cancellation and Refund Policy) को जरूर पढ़ लेना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit318',
    question:
        'तेज़ Checkout के लिए भुगतान विवरण को कैसे सुरक्षित रूप से स्टोर करें?',
    options: [
      'Sticky Notes पर लिख लें।',
      'किसी दोस्त को बता दें।',
      'OTP से अकाउंट में सुरक्षित सेव करें।',
      'ईमेल ड्राफ्ट में सेव करें।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'तेज़ चेकआउट के लिए भुगतान विवरण को वेबसाइट पर सुरक्षित रूप से सेव (Save) करें, जिसके लिए अक्सर OTP की पुष्टि होती है।',
  ),
  QuizQuestion(
    id: 'cit319',
    question: 'ऑनलाइन बुकिंग में एक Red Flag क्या हो सकता है?',
    options: [
      'Verified Seller',
      'Trusted Payment Gateway',
      'अत्यधिक कम कीमत और कोई Reviews नहीं',
      'स्पष्ट Cancellation Terms',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'अत्यधिक कम कीमत (Too good to be true) और किसी भी रिव्यू (Reviews) का न होना एक रेड फ्लैग (चेतावनी संकेत) है।',
  ),
  QuizQuestion(
    id: 'cit320',
    question: 'बुकिंग कैंसिल करने के बाद Refund Status कैसे चेक करें?',
    options: [
      'बैंक को सीधे कॉल करें।',
      'बिना चेक किए इंतज़ार करें।',
      'वेबसाइट पर आर्डर हिस्ट्री या रिफंड सेक्शन देखें।',
      'पुलिस रिपोर्ट दर्ज करें।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'कैंसिलेशन के बाद रिफंड स्टेटस चेक करने के लिए वेबसाइट के "My Orders" या "Refund" सेक्शन में जाना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit321',
    question: 'Youtube मुख्य रूप से किस प्रकार का कंटेंट प्रदान करता है?',
    options: [
      'केवल लाइव स्पोर्ट्स',
      'वीडियो ट्यूटोरियल्स, म्यूजिक और एंटरटेनमेंट',
      'केवल टेक्स्ट न्यूज',
      'केवल पॉडकास्ट',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'YouTube दुनिया का सबसे बड़ा वीडियो शेयरिंग प्लेटफॉर्म है जिसमें ट्यूटोरियल्स, संगीत, मनोरंजन और बहुत कुछ होता है।',
  ),
  QuizQuestion(
    id: 'cit322',
    question: 'निम्न में से कौन-सी एक Paid Subscription Service है?',
    options: [
      'Youtube Free',
      'Spotify Free',
      'Amazon Prime Video',
      'Google Drive',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Amazon Prime Video एक पेड सब्सक्रिप्शन सेवा है, जबकि YouTube और Spotify के फ्री वर्जन भी उपलब्ध हैं।',
  ),
  QuizQuestion(
    id: 'cit323',
    question: 'वीडियो या म्यूजिक को ऑफलाइन देखने के लिए कौन-सी सुविधा होती है?',
    options: ['Filter Option', 'History Tab', 'Download Option', 'Like Button'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'वीडियो या संगीत को ऑफलाइन देखने के लिए "Download" (डाउनलोड) सुविधा का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit324',
    question:
        'Netflix या Spotify Premium जैसे Paid Subscriptions का मुख्य लाभ क्या है?',
    options: [
      'Free मोबाइल रिचार्ज',
      'Premium कंटेंट और No Ads',
      'फ्री इंटरनेट',
      'अनलिमिटेड गेमिंग',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'पेड सब्सक्रिप्शन (जैसे Netflix Premium) का मुख्य लाभ प्रीमियम कंटेंट तक पहुंच और बिना विज्ञापन (No Ads) के अनुभव है।',
  ),
  QuizQuestion(
    id: 'cit325',
    question: 'Streaming Apps में Parental Controls का उद्देश्य क्या है?',
    options: [
      'स्ट्रीमिंग स्पीड बढ़ाना',
      'Subtitles चालू करना',
      'बच्चों को उम्र के अनुसार कंटेंट तक सीमित रखना',
      'स्क्रीन ब्राइटनेस बढ़ाना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Parental Controls (पैरेंटल कंट्रोल) का उद्देश्य बच्चों को उनकी उम्र के लिए अनुपयुक्त कंटेंट देखने से रोकना है।',
  ),
  QuizQuestion(
    id: 'cit326',
    question: 'Spotify पर किस प्रकार का कंटेंट पाया जाता है?',
    options: ['किताबें', 'म्यूजिक और पॉडकास्ट', 'टीवी शोज', 'ऑनलाइन कोर्सेस'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Spotify एक ऑडियो स्ट्रीमिंग प्लेटफॉर्म है जहाँ मुख्य रूप से संगीत (Music) और पॉडकास्ट (Podcasts) मिलते हैं।',
  ),
  QuizQuestion(
    id: 'cit327',
    question: 'Youtube पर खास प्रकार के वीडियो कैसे खोजे जा सकते हैं?',
    options: [
      'Payment Gateway से',
      'Ads पर क्लिक करके',
      'Search और Filter Options से',
      'Downloads Folder खोलकर',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'YouTube पर विशेष प्रकार के वीडियो खोजने के लिए सर्च बार और फ़िल्टर ऑप्शन (Filter Options) का उपयोग करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit328',
    question:
        'Streaming Apps पर Mature Content को ब्लॉक करने के लिए कौन-सी सुविधा है?',
    options: [
      'Volume Control',
      'Playback Speed',
      'Password Protection और Content Filters',
      'Comment Section',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'स्ट्रीमिंग ऐप्स पर मैच्योर कंटेंट को ब्लॉक करने के लिए पासवर्ड प्रोटेक्शन (Password Protection) और कंटेंट फ़िल्टर (Content Filters) होते हैं।',
  ),
  QuizQuestion(
    id: 'cit329',
    question: 'जब डाउनलोड किया गया कंटेंट Expire हो जाता है तो क्या होता है?',
    options: [
      'Auto-Renew होता है',
      'Permanent Save हो जाता है',
      'फिर से डाउनलोड करने तक Inaccessible रहता है',
      'Email पर भेजा जाता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डाउनलोड किया गया कंटेंट एक्सपायर होने पर तब तक एक्सेस नहीं किया जा सकता जब तक उसे दोबारा डाउनलोड न किया जाए (सब्सक्रिप्शन होने पर)।',
  ),
  QuizQuestion(
    id: 'cit330',
    question:
        'कौन-सा App फ्री और पेड दोनों वर्जन देता है, जिसमें Ads और Offline Access में फर्क होता है?',
    options: ['Whatsapp', 'Instagram', 'Youtube', 'Zoom'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'YouTube फ्री वर्जन में विज्ञापन (Ads) दिखाता है और ऑफलाइन एक्सेस नहीं देता, जबकि YouTube Premium (पेड) में ये सुविधाएँ होती हैं।',
  ),
  QuizQuestion(
    id: 'cit331',
    question: 'Voice Assistant का मुख्य उद्देश्य क्या है?',
    options: [
      'Video Games खेलना',
      'Documents टाइप करना',
      'Voice Commands के ज़रिए उपयोगकर्ता की मदद करना',
      'Fax भेजना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Voice Assistant (जैसे Siri, Google Assistant) का मुख्य उद्देश्य वॉयस कमांड के माध्यम से उपयोगकर्ता की सहायता करना है।',
  ),
  QuizQuestion(
    id: 'cit332',
    question: 'निम्न में से कौन-सा एक लोकप्रिय Voice Assistant नहीं है?',
    options: ['Google Assistant', 'Siri', 'Cortana', 'Firefox'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'Firefox एक वेब ब्राउज़र है, वॉइस असिस्टेंट नहीं। Google Assistant, Siri (Apple), और Cortana (Microsoft) लोकप्रिय वॉइस असिस्टेंट हैं।',
  ),
  QuizQuestion(
    id: 'cit333',
    question:
        'Google Assistant को स्मार्टफोन पर एक्टिवेट करने के लिए क्या आवश्यक है?',
    options: [
      'Google Maps से डाउनलोड करना',
      '"Hey Google" कहना या Home Button दबाना',
      'कोई कोड डायल करना',
      'Youtube खोलना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google Assistant को सक्रिय करने के लिए "Hey Google" या "OK Google" बोलें, या होम बटन दबाएं (जैसे Pixel फोन में)।',
  ),
  QuizQuestion(
    id: 'cit334',
    question: 'Amazon Alexa सामान्यतः किस डिवाइस में पाया जाता है?',
    options: ['iPhone', 'Google Nest', 'Amazon Echo', 'Microsoft Surface'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Amazon Alexa, Amazon के स्मार्ट स्पीकर "Amazon Echo" और अन्य Alexa-बिल्ट डिवाइसों में पाया जाता है।',
  ),
  QuizQuestion(
    id: 'cit335',
    question:
        'कौन-सी विशेषता Voice Assistant को मानव भाषा समझने में मदद करती है?',
    options: [
      'Remote Access',
      'Natural Language Processing (NLP)',
      'Digital Zoom',
      'Auto-Correct',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Natural Language Processing (NLP) तकनीक वॉइस असिस्टेंट को मानव भाषा को समझने और प्रोसेस करने में मदद करती है।',
  ),
  QuizQuestion(
    id: 'cit336',
    question: 'निम्न में से कौन-सा एक सामान्य Voice Command है?',
    options: [
      'फ्रिज खोलो',
      '"Set An Alarm For 7 Am"',
      'एसी इंस्टॉल करे',
      'इंटरनेट बंद करे',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        '"Set an alarm for 7 AM" (सुबह 7 बजे का अलार्म सेट करें) एक सामान्य और उपयोगी वॉइस कमांड है।',
  ),
  QuizQuestion(
    id: 'cit337',
    question: 'Voice Assistant की Privacy बढ़ाने के लिए क्या किया जा सकता है?',
    options: [
      'Passwords को Voice से शेयर करें।',
      'Microphone की जगह Speaker का इस्तेमाल करें।',
      'Voice History को Manage करें और अनावश्यक Permissions Disable करें।',
      'Assistant को हमेशा सुनते रहने दें।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'वॉइस असिस्टेंट की प्राइवेसी बढ़ाने के लिए वॉइस हिस्ट्री मैनेज करें और अनावश्यक परमिशन को डिसेबल करें।',
  ),
  QuizQuestion(
    id: 'cit338',
    question: 'Voice Assistant किस Task में आपकी मदद कर सकता है?',
    options: [
      'डायग्राम बनाना',
      'Voice के ज़रिए Text Messages भेजना',
      'पेन से लिखना',
      '3D फिल्में देखना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Voice Assistant आपकी आवाज से टेक्स्ट मैसेज भेजने (Voice to Text) में आपकी मदद कर सकता है।',
  ),
  QuizQuestion(
    id: 'cit339',
    question:
        'Voice Assistant के Setup के दौरान कौन-सी Setting Configure की जा सकती है?',
    options: [
      'Data Encryption Level',
      'Voice Recognition और Custom Commands',
      'Power Supply Mode',
      'Battery Design',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Voice Assistant सेटअप के दौरान वॉइस रिकग्निशन (Voice Recognition) और कस्टम कमांड्स (Custom Commands) को कॉन्फ़िगर किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit340',
    question:
        'Voice Assistant Permissions को Review करना क्यों ज़रूरी होता है?',
    options: [
      'Phone की Brightness सुधारने के लिए',
      'Apps को बेहतर दिखाने के लिए',
      'Personal Data की सुरक्षा और Security को मजबूत करने के लिए',
      'Calls को तेज़ी से करने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'वॉइस असिस्टेंट परमिशन की समीक्षा (Review) करना आपके व्यक्तिगत डाटा की सुरक्षा (Security) के लिए आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit341',
    question: 'डिजिटल कैलेंडर का मुख्य लाभ क्या है?',
    options: [
      'Manual नोट लेना',
      'Automatic Event Sharing',
      'Time Management और Scheduling',
      'Phone Storage सफाई',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डिजिटल कैलेंडर (जैसे Google Calendar) का मुख्य लाभ समय प्रबंधन (Time Management) और कार्य निर्धारण (Scheduling) में मदद करना है।',
  ),
  QuizQuestion(
    id: 'cit342',
    question: 'निम्न में से कौन सा डिजिटल कैलेंडर टूल नहीं है?',
    options: [
      'Google Calendar',
      'Outlook Calendar',
      'Apple Calendar',
      'WhatsApp Calendar',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'WhatsApp एक मैसेजिंग ऐप है, इसमें "WhatsApp Calendar" नाम का कोई अलग कैलेंडर टूल नहीं होता है।',
  ),
  QuizQuestion(
    id: 'cit343',
    question:
        'Google Calendar में नया इवेंट बनाने के लिए किस आइकन पर क्लिक किया जाता है?',
    options: ['Trash', 'Share', '+ Create', 'Sync'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Calendar में नया इवेंट बनाने के लिए "+ Create" (या फ्लोटिंग एक्शन बटन) पर क्लिक किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit344',
    question: 'उपयोगकर्ता इवेंट की सूचना कैसे प्राप्त कर सकते हैं?',
    options: [
      'केवल टेक्स्ट मैसेज से',
      'Pop-up alerts, E-mails और Notifications',
      'Voice Calls',
      'Video Messages',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल कैलेंडर इवेंट्स की सूचना (Notification) पॉप-अप अलर्ट, ईमेल और नोटिफिकेशन के माध्यम से मिलती है।',
  ),
  QuizQuestion(
    id: 'cit345',
    question: 'Recurring Event का सही उपयोग क्या है?',
    options: [
      'Birthday reminder',
      'साप्ताहिक Team Meeting',
      'एक इवेंट को Edit करना',
      'पुराने इवेंट्स को Delete करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Recurring Event (आवर्ती घटना) का सही उपयोग साप्ताहिक टीम मीटिंग जैसे दोहराए जाने वाले कार्यों के लिए है।',
  ),
  QuizQuestion(
    id: 'cit346',
    question: 'Calendar Event में Guests जोड़ने का उद्देश्य क्या है?',
    options: [
      'Calendar साइज बढ़ाने के लिए',
      'खुद को याद दिलाने के लिए',
      'Event Details शेयर करना और Invites Manage करना',
      'Spam भेजने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'इवेंट में Guests जोड़ने का उद्देश्य उनके साथ इवेंट डिटेल्स शेयर करना और इनवाइट्स मैनेज करना है।',
  ),
  QuizQuestion(
    id: 'cit347',
    question: 'आप दूसरों के साथ कैलेंडर इवेंट कैसे शेयर कर सकते हैं?',
    options: [
      'केवल Bluetooth से',
      'उनके Email को Guest के रूप में जोड़कर',
      'Printed Calendar Pages से',
      'वीडियो भेजकर',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'दूसरों के साथ कैलेंडर इवेंट शेयर करने के लिए उनके ईमेल पते को Guest (अतिथि) के रूप में जोड़ा जाता है।',
  ),
  QuizQuestion(
    id: 'cit348',
    question:
        'अगर आपका कैलेंडर डिवाइस पर Sync नहीं हो रहा है तो आपको क्या करना चाहिए?',
    options: [
      'फोन बंद करें।',
      '24 घंटे प्रतीक्षा करें।',
      'इंटरनेट कनेक्शन और लॉगिन Credentials जाँचें।',
      'ऐप Delete करें।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'कैलेंडर सिंक न होने पर सबसे पहले इंटरनेट कनेक्शन और लॉगिन क्रेडेंशियल्स (अकाउंट) की जाँच करें।',
  ),
  QuizQuestion(
    id: 'cit349',
    question: 'डिजिटल कैलेंडर में आप किस प्रकार के इवेंट सेट कर सकते हैं?',
    options: [
      'Cooking Recipes',
      'Audio Playlists',
      'One-Time और Recurring Events',
      'ऊपर में से कोई नहीं',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डिजिटल कैलेंडर में आप एक बार होने वाले (One-Time) और बार-बार होने वाले (Recurring Events) इवेंट सेट कर सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit350',
    question: 'कई उपकरणों पर कैलेंडर को sync करने के लिए क्या मदद करता है?',
    options: [
      'अलग-अलग Email ID का उपयोग करना',
      'बार-बार Logout करना',
      'एक ही Account और Sync Enable करना',
      'Cloud Backup को Disable करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'कई उपकरणों पर कैलेंडर सिंक करने के लिए सभी डिवाइसों में एक ही अकाउंट (जैसे Google) से लॉगिन करें और Sync Enable करें।',
  ),
  QuizQuestion(
    id: 'cit351',
    question: 'डिजिटल संसाधन (Digital Resources) क्या हैं?',
    options: [
      'कागजी फाइलें और दस्तावेज़',
      'केवल मीडिया फाइलें जैसे वीडियो',
      'डिजिटल उपकरणों में संग्रहित फाइलें और डाटा',
      'फोल्डर में रखे गए हस्तलिखित नोट्स',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डिजिटल संसाधन (Digital Resources) वे फाइलें और डाटा हैं जो कंप्यूटर, फोन या टैबलेट जैसे डिजिटल उपकरणों में संग्रहित होते हैं।',
  ),
  QuizQuestion(
    id: 'cit352',
    question: 'फाइलों का नाम रखने का सबसे अच्छा तरीका कौन सा है?',
    options: [
      'रेंडम संख्या और अक्षर',
      'File1, File2, File3',
      'Project_Report_Final_2024',
      'Untitled1',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फाइलों का नाम रखने का सबसे अच्छा तरीका वर्णनात्मक (Descriptive) और सार्थक नाम देना है, जैसे "Project_Report_Final_2024".',
  ),
  QuizQuestion(
    id: 'cit353',
    question: 'फाइलों को फोल्डर में व्यवस्थित करने का उद्देश्य क्या है?',
    options: [
      'अधिक स्टोरेज स्थान का उपयोग करना',
      'डिवाइस को धीमा बनाना',
      'फाइलों को आसानी से ढूंढने और प्रबंधित करने के लिए',
      'उन्हें जल्दी से हटाने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फाइलों को फोल्डर में व्यवस्थित करने का उद्देश्य उन्हें आसानी से ढूंढने (Search) और प्रबंधित (Manage) करने में सक्षम बनाना है।',
  ),
  QuizQuestion(
    id: 'cit354',
    question:
        'कौन-सा टूल इंटरनेट की मदद से कई डिवाइस पर फाइलों को एक्सेस करने में मदद करता है?',
    options: ['USB ड्राइव', 'Cloud Storage', 'Notepad', 'Recycle Bin'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Cloud Storage (क्लाउड स्टोरेज) जैसे Google Drive, iCloud इंटरनेट की मदद से कई डिवाइसों पर फाइलों को एक्सेस करने की सुविधा देता है।',
  ),
  QuizQuestion(
    id: 'cit355',
    question: 'Windows में फाइल को जल्दी कैसे ढूंढ सकते हो?',
    options: [
      'स्टिकी नोट का उपयोग करें।',
      'केवल स्टार्ट मेन्यू का उपयोग करें।',
      'फाइल एक्सप्लोर File Explorer के सर्च बार का उपयोग करें।',
      'टेक्निकल सपोर्ट को कॉल करें।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Windows में फाइल को जल्दी ढूंढने के लिए File Explorer के सर्च बार (Search Bar) का उपयोग करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit356',
    question: 'फाइल सर्च में फिल्टर का एक लाभ क्या है?',
    options: [
      'फिल्टर फाइलों को जल्दी डिलीट करते हैं।',
      'फिल्टर केवल फोल्डर दिखाते हैं।',
      'फिल्टर सर्च परिणामों को सीमित करते हैं।',
      'फिल्टर फाइलों को अहश्य बना देते हैं।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फाइल सर्च में फिल्टर (Filter) का लाभ यह है कि यह सर्च परिणामों को सीमित (Limit) करता है, जिससे ढूंढना आसान हो जाता है।',
  ),
  QuizQuestion(
    id: 'cit357',
    question: 'डुप्लीकेट फाइलों के साथ क्या करना चाहिए?',
    options: [
      'उन्हें प्रिंट करें।',
      'नाम बदलें और सबको रखें।',
      'उन्हें बिखरे हुए छोड़ दें।',
      'उन्हें डिलीट या हटा दें।',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'डुप्लीकेट (Duplicate) फाइलों को स्टोरेज बचाने के लिए डिलीट या हटा देना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit358',
    question: 'डिजिटल फाइलों के प्रबंधन के लिए एक अच्छी आदत क्या है?',
    options: [
      'सब कुछ डेस्कटॉप पर सेव करना',
      'नियमित क्लीन-अप और बैकअप लेना',
      'फाइलों को नाम न देना',
      'क्लाउड स्टोरेज से बचना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल फाइलों के प्रबंधन के लिए एक अच्छी आदत नियमित रूप से क्लीन-अप (Clean-up) और बैकअप (Backup) लेना है।',
  ),
  QuizQuestion(
    id: 'cit359',
    question: 'कौन-सा टूल फाइल ऑर्गनाइज़ेशन को ऑटोमेट कर सकता है?',
    options: [
      'स्टिकी नोट्स',
      'Zapier या IFTTT',
      'मैन्युअल नाम बदलना',
      'कैलकुलेटर',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Zapier या IFTTT जैसे ऑटोमेशन टूल फाइल ऑर्गनाइज़ेशन और वर्कफ़्लो को ऑटोमेट कर सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit360',
    question:
        'अगर आप गलती से कोई फाइल डिलीट कर दें तो सबसे पहले कहाँ देखना चाहिए?',
    options: [
      'कंट्रोल पैनल',
      'क्लाउड एप्स',
      'Recycle Bin या Trash',
      'टास्क मैनेजर',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'गलती से फाइल डिलीट होने पर सबसे पहले Recycle Bin (विंडोज) या Trash (Mac) में देखना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit361',
    question: 'Cloud Storage का एक मुख्य लाभ क्या है?',
    options: [
      'यह कम बिजली का उपयोग करता है।',
      'यह केवल आपके डिवाइस में डाटा स्टोर करता है।',
      'यह कई डिवाइस से एक्सेस की सुविधा देता है।',
      'इसके लिए इंटरनेट की आवश्यकता नहीं होती है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Cloud Storage का मुख्य लाभ यह है कि आप अपने डाटा को कई डिवाइसों से एक्सेस कर सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit362',
    question: 'निम्नलिखित में से कौन-सी एक लोकप्रिय Cloud Storage सेवा है?',
    options: ['Notepad', 'Dropbox', 'VLC', 'Chrome'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Dropbox एक लोकप्रिय क्लाउड स्टोरेज सेवा है। Google Drive, OneDrive और iCloud भी उदाहरण हैं।',
  ),
  QuizQuestion(
    id: 'cit363',
    question: 'Cloud Storage में फाइलों को कैसे व्यवस्थित किया जा सकता है?',
    options: [
      'उन्हें कंप्रेस करके',
      'क्लाउड का नाम बदलकर',
      'फोल्डर बनाकर',
      'ऐप्स Uninstall करके',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Cloud Storage में भी फाइलों को व्यवस्थित करने के लिए फोल्डर (Folder) बनाए जा सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit364',
    question:
        'जब किसी फाइल को व्यू-ओनली परमिशन के साथ शेयर किया जाता है, तो इसका क्या मतलब होता है?',
    options: [
      'दूसरा व्यक्ति उसमें बदलाव कर सकता है।',
      'दूसरा व्यक्ति उसे डिलीट कर सकता है।',
      'दूसरा व्यक्ति सिर्फ कंटेंट देख सकता है।',
      'दूसरा व्यक्ति उसे मूव कर सकता है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'View-Only permission का मतलब है कि दूसरा व्यक्ति फाइल को केवल देख सकता है, उसमें एडिट या डिलीट नहीं कर सकता।',
  ),
  QuizQuestion(
    id: 'cit365',
    question: 'निम्नलिखित में से कौन-सी क्रिया Cloud Storage में संभव नहीं है?',
    options: ['Upload', 'Download', 'Edit online', 'Microwave'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'Cloud Storage में माइक्रोवेव (Microwave) करना संभव नहीं है, क्योंकि यह एक फिजिकल क्रिया है।',
  ),
  QuizQuestion(
    id: 'cit366',
    question: 'Cloud Storage प्लान को अपग्रेड करने का उद्देश्य क्या है?',
    options: [
      'इंटरनेट स्पीड बदलना।',
      'अधिक स्टोरेज स्पेस प्राप्त करना।',
      'कंप्यूटर ठीक करना।',
      'फाइलें तेजी से डिलीट करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Cloud Storage प्लान को अपग्रेड (Upgrade) करने का मुख्य उद्देश्य अधिक स्टोरेज स्पेस प्राप्त करना होता है।',
  ),
  QuizQuestion(
    id: 'cit367',
    question: 'Cloud Storage को manage करने की एक अच्छी आदत क्या है?',
    options: [
      'डुप्लिकेट फाइलें अपलोड करना।',
      'सारी फाइलें Root Folder में रखना।',
      'फोल्डर्स से फाइलें ऑर्गनाइज़ करना।',
      'स्टोरेज लिमिट को नजरअंदाज करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Cloud Storage मैनेज करने की एक अच्छी आदत फोल्डर्स बनाकर फाइलों को व्यवस्थित (Organize) करना है।',
  ),
  QuizQuestion(
    id: 'cit368',
    question:
        'Google Drive पर फाइल को सुरक्षित रूप से कैसे शेयर किया जा सकता है?',
    options: [
      'सभी को Full Access देकर',
      'फाइल टाइप बदलकर',
      'Permission Controls के साथ Shareable Link देकर',
      'उसे desktop पर कॉपी करके',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Drive पर फाइल सुरक्षित रूप से शेयर करने के लिए Permission Controls (जैसे Viewer) के साथ Shareable Link बनाएं।',
  ),
  QuizQuestion(
    id: 'cit369',
    question: 'Cloud Storage को काम करने के लिए किसकी जरूरत होती है?',
    options: ['गैस', 'पानी', 'Internet connection', 'Microwave oven'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Cloud Storage (क्लाउड स्टोरेज) का उपयोग करने के लिए इंटरनेट कनेक्शन (Internet Connection) आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit370',
    question: 'अगर आपकी Cloud Storage भर जाती है तो क्या होगा?',
    options: [
      'फाइलें अपने आप डिलीट हो जाएंगी।',
      'आप नई फाइल अपलोड नहीं कर पाएंगे।',
      'स्टोरेज अपने आप बढ़ जाएगा।',
      'आपका फ़ोन बंद हो जाएगा।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'यदि आपकी क्लाउड स्टोरेज भर जाती है, तो आप तब तक नई फाइल अपलोड नहीं कर पाएंगे जब तक आप जगह खाली न करें या प्लान अपग्रेड न करें।',
  ),
  QuizQuestion(
    id: 'cit371',
    question: 'डाटा बैकअप का मुख्य उद्देश्य क्या है?',
    options: [
      'Computer speed बढ़ाना',
      'Internet data बचाना',
      'Data loss रोकना',
      'Screen resolution सुधारना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डाटा बैकअप (Data Backup) का मुख्य उद्देश्य डाटा लॉस (Data Loss) को रोकना है।',
  ),
  QuizQuestion(
    id: 'cit372',
    question: 'निम्नलिखित में से कौन सी एक क्लाउड बैकअप सेवा है?',
    options: ['USB Drive', 'External Hard Disk', 'Google Drive', 'DVD'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Drive एक क्लाउड बैकअप सेवा है, जबकि USB, External HDD और DVD लोकल बैकअप डिवाइस हैं।',
  ),
  QuizQuestion(
    id: 'cit373',
    question: 'Local Backup क्या होता है?',
    options: [
      'Data saved to the Internet',
      'Data saved to nearby cloud servers',
      'Data stored on physical storage devices like Hard drives या USBs',
      'Data deleted from the device',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'लोकल बैकअप (Local Backup) डाटा को फिजिकल स्टोरेज डिवाइस (जैसे Hard Drive, USB) पर सेव करना होता है।',
  ),
  QuizQuestion(
    id: 'cit374',
    question: 'क्लाउड बैकअप का एक मुख्य लाभ क्या है?',
    options: [
      'Electricity के बिना भी काम करता है',
      'आप किसी भी device से data access कर सकते हैं',
      'वे RAM से तेज होते हैं',
      'वे screen brightness कम कर देते हैं',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'क्लाउड बैकअप का मुख्य लाभ यह है कि आप किसी भी डिवाइस और कहीं से भी अपने डाटा को एक्सेस कर सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit375',
    question: 'बैकअप प्रक्रिया को ऑटोमैटिक बनाने में क्या मदद करता है?',
    options: [
      'Manual file copy',
      'Disk formatting',
      'Scheduling automatic backups',
      'Display settings बदलना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'बैकअप प्रक्रिया को ऑटोमैटिक बनाने के लिए शेड्यूलिंग (Scheduling Automatic Backups) की सुविधा का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit376',
    question:
        'अधिकांश ऑपरेटिंग सिस्टम में डिलीट हुई फाइल को रिकवर करने के लिए क्या विकल्प है?',
    options: ['Uninstall', 'Control Panel', 'Recycle Bin या Trash', 'Paint'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'अधिकांश OS (जैसे Windows) में डिलीट हुई फाइल को Recycle Bin (Windows) या Trash (Mac) से रिकवर किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit377',
    question:
        'वह कौन सा Malware है जो आपकी फाइलों को एन्क्रिएट कर फिरौती मांगता है?',
    options: ['Trojan', 'Worm', 'Ransomware', 'Adware'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Ransomware (रैनसमवेयर) एक प्रकार का Malware है जो फाइलों को एन्क्रिप्ट (लॉक) कर देता है और उन्हें खोलने के लिए फिरौती (Ransom) मांगता है।',
  ),
  QuizQuestion(
    id: 'cit378',
    question: 'एन्क्रिप्शन बैकअप डाटा के साथ क्या करता है?',
    options: [
      'उसे Delete कर देता है',
      'उसे Compress कर देता है',
      'उसे Unreadable Format में बदलकर Protect करता है',
      'उसे सभी Computers पर Visible बना देता है',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एन्क्रिप्शन (Encryption) बैकअप डाटा को एक अपठनीय (Unreadable) फॉर्मेट में बदल देता है, जिससे वह सुरक्षित हो जाता है।',
  ),
  QuizQuestion(
    id: 'cit379',
    question:
        'एक्सटर्नल बैकअप ड्राइव को सुरक्षित करने का सर्वोत्तम तरीका क्या है?',
    options: [
      'उन्हें हमेशा Connected रखना',
      'Weak Passwords Use करना',
      'Strong Passwords से Lock करना',
      'सभी के साथ Share करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एक्सटर्नल बैकअप ड्राइव को सुरक्षित करने का सबसे अच्छा तरीका मजबूत पासवर्ड (Strong Password) लगाना है।',
  ),
  QuizQuestion(
    id: 'cit380',
    question: 'बैकअप से फाइल रीस्टोर करते समय सबसे पहले जरूरी कदम क्या है?',
    options: [
      'Original File को Delete करना',
      'Backup of The Backup बनाना',
      'यह Check करना कि Backup Up To Date है या नहीं',
      'File को Rename करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'बैकअप रिस्टोर करने से पहले यह चेक करना जरूरी है कि बैकअप अप टू डेट (Up to Date) है या नहीं।',
  ),
  QuizQuestion(
    id: 'cit381',
    question: 'Slow Performing Computer का एक सामान्य लक्षण क्या है?',
    options: [
      'Blue Screen',
      'तेज Internet Speed',
      'धीमा Startup और Application Loading',
      'लगातार Beeping Sounds',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'धीमी परफॉर्मेंस वाले कंप्यूटर में स्टार्टअप (Startup) और एप्लीकेशन लोड होने में समय लगता है।',
  ),
  QuizQuestion(
    id: 'cit382',
    question:
        'जब कोई Application Freeze हो जाए, तो Troubleshooting का पहला चरण क्या होता है?',
    options: [
      'App को Delete करना',
      'Device को Restart करना',
      'Browser को Update करना',
      'Operating System को Reinstall करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'एप्लीकेशन फ्रीज होने पर ट्रबलशूटिंग (Troubleshooting) का पहला कदम डिवाइस को रीस्टार्ट (Restart) करना होता है।',
  ),
  QuizQuestion(
    id: 'cit383',
    question:
        'निम्न में से कौन-सा Step Software Crash को ठीक करने में मदद करता है?',
    options: [
      'Screen को Replace करना',
      'Software को Update करना',
      'Keyboard को Remove करना',
      'Wallpaper बदलना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'सॉफ्टवेयर क्रैश (Crash) होने पर उसे अपडेट (Update) करने से अक्सर समस्या ठीक हो जाती है।',
  ),
  QuizQuestion(
    id: 'cit384',
    question: 'Router को Reset करने का उद्देश्य क्या होता है?',
    options: [
      'Password बदलना',
      'Battery Life बढ़ाना',
      'Internet Connectivity Issues को ठीक करना',
      'नया Software Install करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Router को रीसेट (Reset) करने का उद्देश्य आमतौर पर इंटरनेट कनेक्टिविटी की समस्याओं को ठीक करना होता है।',
  ),
  QuizQuestion(
    id: 'cit385',
    question: 'निम्नलिखित में से कौन-सी Hardware-Related Problem है?',
    options: [
      'App नहीं खुलना',
      'Wi-Fi से Connect नहीं होना',
      'Screen का Flicker करना (Loose Cable के कारण)',
      'Website पर Login Error',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'स्क्रीन का फ्लिकर (Flicker) करना, खासकर लूज़ केबल (Loose Cable) के कारण, एक हार्डवेयर संबंधी समस्या है।',
  ),
  QuizQuestion(
    id: 'cit386',
    question:
        'यदि Mobile Network काम नहीं कर रहा हो, तो सबसे पहले क्या करना चाहिए?',
    options: [
      'कुछ सेकंड के लिए Airplane Mode On करना',
      'Device को Format करना',
      'SIM Card बदलना',
      'दूसरा Charger इस्तेमाल करना',
    ],
    correctIndex: 0,
    subject: 'BS-CIT',
    description:
        'मोबाइल नेटवर्क न चलने पर सबसे पहले Airplane Mode ऑन करके कुछ सेकंड बाद ऑफ करें, इससे नेटवर्क रीफ्रेश हो जाता है।',
  ),
  QuizQuestion(
    id: 'cit387',
    question: 'Hard Drive Failure का संकेत क्या हो सकता है?',
    options: [
      'Apps धीरे खुलना',
      'Device से Clicking Sounds आना',
      'Wi-Fi Disconnect होना',
      'Screen का Dim होना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'हार्ड ड्राइव फेल होने पर अक्सर डिवाइस से क्लिक करने (Clicking Sounds) या घरघराहट की आवाज आती है।',
  ),
  QuizQuestion(
    id: 'cit388',
    question: 'Ram Issue आमतौर पर किसका कारण बनता है?',
    options: [
      'Display न आना',
      'तेज Internet Speed',
      'Frequent System Crashes और Slow Performance',
      'Touchscreen काम न करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'RAM की समस्या (RAM Issue) के कारण सिस्टम बार-बार क्रैश (Crash) हो सकता है और परफॉर्मेंस धीमी हो सकती है।',
  ),
  QuizQuestion(
    id: 'cit389',
    question: 'Professional IT Help कब लेनी चाहिए?',
    options: [
      'जब Wallpaper न बदलें।',
      'जब Motherboard खराब हो।',
      'जब App खुलने में देर लगे।',
      'जब Keyboard Layout बदल जाए।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'मदरबोर्ड (Motherboard) खराब होने जैसी हार्डवेयर समस्या पर प्रोफेशनल IT Help लेनी चाहिए।',
  ),
  QuizQuestion(
    id: 'cit390',
    question:
        'कंप्यूटर में Hardware Problems को Diagnose करने वाला Tool कौन-सा है?',
    options: [
      'Paint',
      'Task Manager',
      'Disk Cleanup',
      'Diagnostic Tool या Bios Check',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'हार्डवेयर समस्याओं का निदान (Diagnose) करने के लिए BIOS या Diagnostic Tool का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit391',
    question: 'कार्यस्थल में Ergonomics का उद्देश्य क्या है?',
    options: [
      'डेस्क को सजाना।',
      'कंप्यूटर की Speed बढ़ाना।',
      'आराम सुनिश्चित करना और Physical Strain कम करना।',
      'सॉफ़्टवेयर की Performance सुधारना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एर्गोनॉमिक्स (Ergonomics) का उद्देश्य कार्यस्थल पर आराम सुनिश्चित करना और शारीरिक तनाव (Physical Strain) को कम करना है।',
  ),
  QuizQuestion(
    id: 'cit392',
    question: 'खराब Posture का सामान्य परिणाम क्या होता है?',
    options: [
      'तेज़ Typing Speed',
      'गर्दन और पीठ में दर्द',
      'बेहतर Battery Life',
      'बेहतर Eyesight',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'लंबे समय तक खराब मुद्रा (Posture) में बैठने से गर्दन और पीठ में दर्द होना आम है।',
  ),
  QuizQuestion(
    id: 'cit393',
    question: 'डेस्क पर बैठते समय पैरों की सही स्थिति क्या होनी चाहिए?',
    options: [
      'हवा में लटकते हुए',
      'फर्श पर सपाट टिके हुए',
      'कुर्सी के नीचे क्रॉस किए हुए',
      'डेस्क पर रखे हुए',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description: 'बैठते समय पैरों को फर्श पर सपाट (Flat) टिका होना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit394',
    question: 'Monitor की ऊँचाई क्या होनी चाहिए?',
    options: [
      'डेस्क से नीचे',
      'आंखों के स्तर पर या थोड़ा नीचे',
      'सिर से ऊपर',
      'कंधे के स्तर पर',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'मॉनिटर की ऊंचाई आंखों के स्तर (Eye Level) पर या उससे थोड़ा नीचे होनी चाहिए।',
  ),
  QuizQuestion(
    id: 'cit395',
    question: 'निम्न में से कौन-सा Ergonomic Accessory नहीं है?',
    options: ['Wrist Support', 'Standing Desk', 'Loudspeaker', 'Footrest'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Loudspeaker (स्पीकर) एक एर्गोनोमिक एक्सेसरी नहीं है। Wrist Support, Standing Desk और Footrest एर्गोनोमिक एक्सेसरी हैं।',
  ),
  QuizQuestion(
    id: 'cit396',
    question: 'Monitor आंखों से कितनी दूरी पर होना चाहिए?',
    options: ['एक इंच', 'एक Arm\'s Length', 'दो फीट पीछे', 'नाक से सटा हुआ'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'मॉनिटर आंखों से एक हाथ की दूरी (Arm\'s Length) पर होना चाहिए, लगभग 20-24 इंच।',
  ),
  QuizQuestion(
    id: 'cit397',
    question: '20-20-20 Rule क्या सुझाव देता है?',
    options: [
      'हर 20 कार्यों के बाद 20 मिनट का आराम',
      'हर 20 मिनट में 20 फीट दूर देखें, 20 सेकंड तक',
      'हर महीने की 20 तारीख को 20 घंटे की नींद',
      'लगातार 20 घंटे काम करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        '20-20-20 नियम के अनुसार, हर 20 मिनट में 20 सेकंड के लिए 20 फीट दूर देखना चाहिए, इससे आंखों का तनाव कम होता है।',
  ),
  QuizQuestion(
    id: 'cit398',
    question: 'टाइपिंग के दौरान कलाई में तनाव कम करने का एक तरीका क्या है?',
    options: [
      'हाथों को सिर के ऊपर रखें',
      'Wrist Support का उपयोग करें और हाथों को सीधा रखें',
      'केवल अंगूठों से टाइप करें',
      'कोहनी को Keyboard पर टिकाएं',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'टाइपिंग करते समय Wrist Support (कलाई का सहारा) का उपयोग करें और हाथों को सीधा (Straight) रखें।',
  ),
  QuizQuestion(
    id: 'cit399',
    question: 'निम्न में से कौन-सा Digital Fatigue का संकेत है?',
    options: [
      'बेहतर Multitasking',
      'सिरदर्द और आंखों में तनाव',
      'स्क्रीन की बेहतर Visibility',
      'Memory में वृद्धि',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल थकान (Digital Fatigue) के लक्षणों में सिरदर्द (Headache) और आंखों में तनाव (Eye Strain) शामिल हैं।',
  ),
  QuizQuestion(
    id: 'cit400',
    question: 'Workstation पर Footrest का उपयोग क्यों सहायक होता है?',
    options: [
      'लंबा दिखने के लिए',
      'सजावट के लिए',
      'पैरों को Support देने और Posture सुधारने के लिए',
      'पैरों से Drum बजाने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Footrest (पैरों का सहारा) पैरों को सहारा देता है और मुद्रा (Posture) सुधारने में मदद करता है।',
  ),
  QuizQuestion(
    id: 'cit401',
    question: 'Digital Eye Strain का एक सामान्य लक्षण क्या है?',
    options: ['पीठ दर्द', 'धुंधली नज़र', 'कलाई का दर्द', 'पेट में ऐंठन'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल आई स्ट्रेन (Digital Eye Strain) का एक सामान्य लक्षण धुंधली नज़र (Blurred Vision) है।',
  ),
  QuizQuestion(
    id: 'cit402',
    question: '20-20-20 Rule क्या है?',
    options: [
      'हर 20 मिनट पर 20 सेकंड के लिए अपना फोन देखें',
      'हर 20 मिनट पर 20 mL पानी पिएं',
      'हर 20 मिनट पर, 20 फीट दूर देखें, 20 सेकंड तक',
      'हर 20 सेकंड पर 20 बार पलकें झपकाएं',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        '20-20-20 नियम: हर 20 मिनट में 20 सेकंड के लिए 20 फीट दूर देखें।',
  ),
  QuizQuestion(
    id: 'cit403',
    question:
        'लंबे समय तक तेज़ आवाज़ में Headphones इस्तेमाल करने से क्या प्रभाव हो सकता है?',
    options: ['आंखों में जलन', 'गर्दन में दर्द', 'बहरापन', 'उंगलियों में ऐंठन'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'तेज़ आवाज़ में हेडफोन लगाने से सुनने की क्षमता पर प्रभाव पड़ सकता है, जिससे बहरापन (Hearing Loss) हो सकता है।',
  ),
  QuizQuestion(
    id: 'cit404',
    question: 'Hearing Damage से बचने के लिए कौन-सा Listening Practice सही है?',
    options: ['90/90 Rule', '60/60 Rule', '10/10 Rule', '70/30 Rule'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'सुनने की क्षमता को बचाने के लिए 60/60 नियम का पालन करना चाहिए: 60% वॉल्यूम में अधिकतम 60 मिनट।',
  ),
  QuizQuestion(
    id: 'cit405',
    question: 'गर्दन और कंधों के तनाव से बचने में क्या सहायक है?',
    options: [
      'स्क्रीन को नीचे देखना।',
      'स्क्रीन को आंखों के स्तर पर रखना।',
      'डिवाइस का उपयोग करते समय लाइट्स बंद रखना।',
      'एक हाथ से टाइप करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'गर्दन और कंधों के तनाव से बचने के लिए स्क्रीन को सीधे आंखों के स्तर पर रखना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit406',
    question: 'टाइपिंग करते समय कलाई के तनाव को कम करने में क्या मदद करता है?',
    options: [
      'कलाई को Desk पर सीधा रखना।',
      'Mouse को कस कर पकड़ना।',
      'Wrist Rests का उपयोग करना।',
      'हाथों को हवा में रखना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'टाइपिंग करते समय Wrist Rests (कलाई का सहारा) का उपयोग करने से कलाई का तनाव कम होता है।',
  ),
  QuizQuestion(
    id: 'cit407',
    question: 'Screen Brightness को नियंत्रित करने की अनुशंसित तकनीक क्या है?',
    options: [
      'दिन भर Brightness को Maximum पर रखें।',
      'Brightness को Room Lighting के अनुसार सेट करें।',
      'हर स्थिति में Screen Brightness को Low रखें।',
      'Auto-Brightness को बंद कर दें।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'स्क्रीन ब्राइटनेस को कमरे की रोशनी (Room Lighting) के अनुसार सेट करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit408',
    question:
        'रात में आंखों के Strain को कम करने के लिए कौन-सा Feature उपयोगी है?',
    options: [
      'Contrast बढ़ाना',
      'Night Mode या Blue Light Filter',
      'Auto-Correct',
      'Airplane Mode',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'रात में आंखों के तनाव को कम करने के लिए Night Mode या Blue Light Filter का उपयोग करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit409',
    question: 'Computer Users के लिए कौन-सी Stretching Exercise उपयोगी है?',
    options: ['Knee Rolls', 'Shoulder Rolls', 'Leg Jumps', 'Finger Flicks'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'कंप्यूटर यूजर्स के लिए Shoulder Rolls (कंधों को घुमाना) एक उपयोगी स्ट्रेचिंग एक्सरसाइज है।',
  ),
  QuizQuestion(
    id: 'cit410',
    question:
        'Visually Impaired Users के लिए Screen पढ़ना आसान बनाने वाला Setting कौन-सा है?',
    options: [
      'Low Brightness',
      'Low Volume',
      'High Contrast Mode',
      'Wi-Fi Optimisation',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'High Contrast Mode (उच्च कंट्रास्ट मोड) दृष्टिबाधित (Visually Impaired) उपयोगकर्ताओं के लिए स्क्रीन पढ़ना आसान बनाता है।',
  ),
  QuizQuestion(
    id: 'cit411',
    question:
        'अत्यधिक प्रिंटिंग से होने वाली एक प्रमुख पर्यावरणीय समस्या क्या है?',
    options: [
      'Internet Congestion',
      'Air Pollution',
      'Paper Waste',
      'Software Bugs',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'अत्यधिक प्रिंटिंग से पेपर वेस्ट (Paper Waste) बढ़ता है, जो पर्यावरण के लिए हानिकारक है।',
  ),
  QuizQuestion(
    id: 'cit412',
    question: 'पेपरलेस Workflows का एक लाभ क्या है?',
    options: [
      'Communication धीमा होता है।',
      'Hardware उपयोग बढ़ता है।',
      'Storage की कम आवश्यकता होती है।',
      'Printer Maintenance अधिक होती है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पेपरलेस वर्कफ़्लो (Paperless Workflow) का एक लाभ स्टोरेज (Storage) की कम आवश्यकता होना है।',
  ),
  QuizQuestion(
    id: 'cit413',
    question:
        'अनावश्यक Printing Errors से बचने के लिए कौन-सी सुविधा उपयोगी है?',
    options: [
      'Print History',
      'Print Preview',
      'Font Change',
      'Header/Footer Setup',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'अनावश्यक प्रिंटिंग एरर से बचने के लिए प्रिंट प्रीव्यू (Print Preview) का उपयोग करना उपयोगी है।',
  ),
  QuizQuestion(
    id: 'cit414',
    question: 'Printing करते समय Paper बचाने का एक अच्छा अभ्यास क्या है?',
    options: [
      'बड़े Fonts का उपयोग करना।',
      'केवल Single-Sided प्रिंट करना।',
      'Bold Ink का उपयोग करना।',
      'Double-Sided प्रिंट करना।',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'प्रिंटिंग में पेपर बचाने का एक अच्छा अभ्यास दोनों तरफ (Double-Sided) प्रिंट करना है।',
  ),
  QuizQuestion(
    id: 'cit415',
    question:
        'कौन-सा Digital Tool Documents को Online Store करने के लिए उपयोग होता है?',
    options: ['Scanner', 'Fax Machine', 'Google Drive', 'Printer Settings'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google Drive (Cloud Storage) एक डिजिटल टूल है जिसका उपयोग दस्तावेज़ों को ऑनलाइन स्टोर करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit416',
    question: 'Digital Signatures का मुख्य लाभ क्या है?',
    options: [
      'अधिक Paperwork',
      'तेज़ इंटरनेट',
      'Quick और Secure Document Signing',
      'Ink-Free Paper',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Digital Signature (डिजिटल हस्ताक्षर) का मुख्य लाभ दस्तावेज़ों पर त्वरित (Quick) और सुरक्षित (Secure) हस्ताक्षर करना है।',
  ),
  QuizQuestion(
    id: 'cit417',
    question: 'E-Signature के लिए आमतौर पर कौन-सा Tool उपयोग किया जाता है?',
    options: ['Adobe Reader', 'Docusign', 'Paint', 'Vlc Media Player'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'DocuSign दुनिया में सबसे अधिक उपयोग किया जाने वाला ई-सिग्नेचर (E-Signature) टूल है।',
  ),
  QuizQuestion(
    id: 'cit418',
    question:
        'निम्न में से कौन-सा Ink Waste को कम करने के लिए Best Practice नहीं है?',
    options: [
      'Print Preview का उपयोग करना।',
      'Grayscale Printing करना।',
      'केवल ज़रूरी Pages को प्रिंट करना।',
      'सभी E-Mails को स्वतः प्रिंट करना।',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'सभी ईमेल को ऑटोमैटिक प्रिंट करना इंक वेस्ट (Ink Waste) कम करने की अच्छी प्रैक्टिस नहीं है।',
  ),
  QuizQuestion(
    id: 'cit419',
    question: 'Digital Documents भेजते समय Encryption क्यों ज़रूरी है?',
    options: [
      'यह Paper बचाता है।',
      'यह Overheating से बचाता है।',
      'यह Unauthorised Access से Data को सुरक्षित करता है।',
      'यह Download Speed बढ़ाता है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एन्क्रिप्शन (Encryption) अनधिकृत पहुंच (Unauthorised Access) से डाटा की सुरक्षा के लिए आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit420',
    question: 'Paperless Communication में एक सामान्य गलती क्या है?',
    options: [
      'Files को Cloud Storage में सेव करना।',
      'मजबूत पासवर्ड का उपयोग करना।',
      'Files को Encryption के बिना साझा करना।',
      'Documents को Digitally Sign करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पेपरलेस कम्युनिकेशन में एक सामान्य गलती फाइलों को बिना एन्क्रिप्शन के साझा करना है।',
  ),
  QuizQuestion(
    id: 'cit421',
    question: 'निम्न में से क्या E-Waste माना जाता है?',
    options: [
      'Food Wrappers',
      'Plastic Bottles',
      'Old Mobile Phones और Batteries',
      'Books',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पुराने मोबाइल फोन और बैटरी (Old Mobile Phones and Batteries) ई-वेस्ट (Electronic Waste) के उदाहरण हैं।',
  ),
  QuizQuestion(
    id: 'cit422',
    question: 'E-Waste से होने वाला एक बड़ा पर्यावरणीय खतरा क्या है?',
    options: [
      'Noise Pollution',
      'Oil Leakage',
      'Toxic Chemical Release',
      'Global Warming',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ई-वेस्ट से टॉक्सिक केमिकल (Toxic Chemicals) जैसे लेड, मरकरी का रिसाव होता है, जो पर्यावरण के लिए खतरनाक है।',
  ),
  QuizQuestion(
    id: 'cit423',
    question: 'इनमें से कौन-सा आइटम आमतौर पर Recycle किया जा सकता है?',
    options: [
      'Broken Glass Panels',
      'Crt Monitors With Cracked Screens',
      'Smartphones जिनके Parts काम कर रहे हों',
      'Wet Paper',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'जिन स्मार्टफोन के पार्ट्स काम कर रहे हों, उन्हें आमतौर पर रीसायकल (Recycle) किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit424',
    question:
        'भारत में अधिकृत E-Waste Disposal Centers की जानकारी किस प्लेटफॉर्म से मिल सकती है?',
    options: ['Facebook', 'Youtube', 'Moef.gov.in', 'Flipkart'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'भारत में अधिकृत ई-वेस्ट डिस्पोजल सेंटर की जानकारी moef.gov.in (Ministry of Environment, Forest and Climate Change) पर मिलती है।',
  ),
  QuizQuestion(
    id: 'cit425',
    question: 'पुराने डिवाइसेज़ को Refurbish करने का मुख्य लाभ क्या है?',
    options: [
      'यह बिजली की खपत बढ़ाता है।',
      'डिवाइस भारी हो जाता है।',
      'डिवाइस का Lifespan बढ़ता है और E-Waste कम होता है।',
      'Screen की Brightness घटती है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Refurbish (पुनर्निर्मित) करने से डिवाइस का जीवनकाल (Lifespan) बढ़ता है और ई-वेस्ट कम होता है।',
  ),
  QuizQuestion(
    id: 'cit426',
    question: 'इनमें से कौन-सा E-Waste Disposal का सुरक्षित तरीका नहीं है?',
    options: [
      'पुराने फोन को अधिकृत केंद्रों को देना।',
      'Batteries को नियमित कचरे में फेंकना।',
      'Disposal से पहले Personal Data हटाना।',
      'Government-Approved Drop-Off Points का उपयोग करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'बैटरी को नियमित कचरे (Regular Waste) में फेंकना सुरक्षित नहीं है, क्योंकि वे खतरनाक रसायन छोड़ सकती हैं।',
  ),
  QuizQuestion(
    id: 'cit427',
    question: 'निर्माता Sustainability को बढ़ावा देने के लिए क्या करते हैं?',
    options: [
      'Unrepairable डिवाइसेज़ बनाना।',
      'Non-Recyclable सामग्री का उपयोग।',
      'Device Take-Back Programs देना।',
      'डिवाइस की कीमतें बढ़ाना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'निर्माता सस्टेनेबिलिटी (Sustainability) के लिए Device Take-Back Programs (पुराने डिवाइस वापस लेने के कार्यक्रम) चलाते हैं।',
  ),
  QuizQuestion(
    id: 'cit428',
    question: 'E-Waste Recycling किस चीज़ के संरक्षण में मदद करता है?',
    options: ['Fuel', 'Water', 'Natural Resources और Metals', 'Paper'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ई-वेस्ट रीसाइक्लिंग (Recycling) प्राकृतिक संसाधनों (Natural Resources) और कीमती धातुओं (Metals) के संरक्षण में मदद करता है।',
  ),
  QuizQuestion(
    id: 'cit429',
    question: 'E-Waste को सही तरीके से न निपटाने का मुख्य खतरा क्या है?',
    options: [
      'Slow Internet Speed',
      'High Phone Bills',
      'Pollution और Health Hazards',
      'Screen की कम Brightness',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ई-वेस्ट का सही तरीके से निपटान न करने से प्रदूषण (Pollution) और स्वास्थ्य के लिए खतरा (Health Hazards) बढ़ता है।',
  ),
  QuizQuestion(
    id: 'cit430',
    question:
        'यदि किसी आइटम की स्थिति अच्छी हो, तो कौन-सा Item Donate करने योग्य है?',
    options: [
      'Burnt Out Led',
      'Cracked Crt Monitor',
      'Working Tablet With Charger',
      'Broken Refrigerator With Gas Leak',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'अगर किसी आइटम की स्थिति अच्छी है और वह काम कर रहा है (जैसे Tablet with Charger), तो उसे दान (Donate) किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit431',
    question:
        'डिजिटल डिवाइसों की सबसे ज्यादा ऊर्जा खपत करने वाली सुविधा कौन-सी है?',
    options: ['Wi-Fi', 'Screen Brightness', 'File Size', 'Keyboard Backlight'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल डिवाइसों में सबसे अधिक ऊर्जा स्क्रीन ब्राइटनेस (Screen Brightness) खपत करती है।',
  ),
  QuizQuestion(
    id: 'cit432',
    question: 'Smartphone में "Battery Saver" Mode ऑन करने से क्या होता है?',
    options: [
      'Screen Resolution बढ़ता है।',
      'Background Apps तेज़ी से चलते हैं।',
      'Background Activity कम होती है और Battery बचती है।',
      'Unused Files अपने आप Delete हो जाती हैं।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Battery Saver Mode ऑन करने से बैकग्राउंड एक्टिविटी कम हो जाती है, जिससे बैटरी बचती है।',
  ),
  QuizQuestion(
    id: 'cit433',
    question: 'Laptop में Battery बचाने वाली Setting कौन-सी है?',
    options: [
      'Bluetooth को लगातार ऑन रखना।',
      'Screen Brightness बढ़ाना।',
      'Inactivity के बाद Device को Sleep Mode में सेट करना।',
      'Full-Screen Mode का उपयोग करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'लैपटॉप की बैटरी बचाने के लिए इनएक्टिविटी (Inactivity) के बाद डिवाइस को स्लीप मोड (Sleep Mode) में जाने के लिए सेट करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit434',
    question: '"Phantom Power Consumption" क्या है?',
    options: [
      'System Crash के दौरान उपयोग की गई ऊर्जा।',
      'डिवाइस बंद होने पर भी खपत की गई बिजली।',
      'Charging के दौरान उपयोग की गई बिजली।',
      'Apps के Fullscreen Mode में ऊर्जा खपत।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Phantom Power (फैंटम पावर) वह बिजली है जो डिवाइस बंद होने पर भी (जैसे चार्जर लगा हो) खपत होती है।',
  ),
  QuizQuestion(
    id: 'cit435',
    question: 'Phantom Power को कम करने का स्मार्ट तरीका क्या है?',
    options: [
      'Sound Settings तेज़ रखें।',
      'सभी डिवाइसों को Sleep Mode में रखें।',
      'Smart Power Strips का उपयोग करें।',
      'Multiple Adapters का उपयोग करें।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Phantom Power को कम करने के लिए स्मार्ट पावर स्ट्रिप्स (Smart Power Strips) का उपयोग करें, जो डिवाइस बंद होने पर पावर काट देती हैं।',
  ),
  QuizQuestion(
    id: 'cit436',
    question: 'यदि आप Screen Brightness को 50% घटाते हैं तो क्या होगा?',
    options: [
      'Device की Speed कम हो जाती है।',
      'Battery Life बेहतर होती है।',
      'Internet Speed बढ़ती है।',
      'Audio म्यूट हो जाता है।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'स्क्रीन ब्राइटनेस 50% कम करने से बैटरी लाइफ (Battery Life) बेहतर हो जाती है।',
  ),
  QuizQuestion(
    id: 'cit437',
    question: 'Computer में "Sleep Mode" का उद्देश्य क्या है?',
    options: [
      'Performance बढ़ाना',
      'आंखों के तनाव को कम करना',
      'Activity घटाकर बिजली बचाना',
      'Unnecessary Apps Delete करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Sleep Mode का उद्देश्य कंप्यूटर की एक्टिविटी कम करके बिजली बचाना है।',
  ),
  QuizQuestion(
    id: 'cit438',
    question: 'Background Apps को Disable क्यों करना चाहिए?',
    options: [
      'ये डिवाइस को भारी बनाते हैं।',
      'ये अतिरिक्त Battery और Power की खपत करते हैं।',
      'ये ज़रूरी डाटा Delete कर देते हैं।',
      'ये Operating System Crash कर देते हैं।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'बैकग्राउंड ऐप्स अतिरिक्त बैटरी और पावर खपत करते हैं, इसलिए इन्हें डिसेबल करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit439',
    question:
        'कौन-सी Setting Device Idle Time के दौरान अनावश्यक ऊर्जा खपत को कम करती है?',
    options: [
      'App Auto-Update',
      'Display Timeout और Sleep Settings',
      'Ringtone Volume',
      'Notification Vibration',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Display Timeout और Sleep Settings डिवाइस के आइडल (Idle) समय के दौरान ऊर्जा खपत कम करने में मदद करती हैं।',
  ),
  QuizQuestion(
    id: 'cit440',
    question: 'Unused Devices को Unplug करना क्यों महत्वपूर्ण है?',
    options: [
      'इससे Internet Speed बढ़ती है।',
      'यह Software Updates को रोकता है।',
      'यह Phantom Power को रोकता है और बिजली बचाता है।',
      'यह Data Storage बढ़ाता है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'अनुपयोगी डिवाइसों को अनप्लग (Unplug) करना महत्वपूर्ण है क्योंकि यह फैंटम पावर (Phantom Power) को रोकता है और बिजली बचाता है।',
  ),
  QuizQuestion(
    id: 'cit441',
    question: '"Sustainability In Digital Technology" का क्या अर्थ है?',
    options: [
      'नवीनतम डिवाइस का उपयोग करना।',
      'तकनीकी उपयोग से होने वाले पर्यावरणीय प्रभाव को कम करना।',
      'स्क्रीन टाइम बढ़ाना।',
      'ज़्यादा Storage खरीदना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल टेक्नोलॉजी में सस्टेनेबिलिटी (Sustainability) का अर्थ तकनीकी उपयोग से होने वाले पर्यावरणीय प्रभाव को कम करना है।',
  ),
  QuizQuestion(
    id: 'cit442',
    question: 'Digital Carbon Footprint क्या है?',
    options: [
      'Apps द्वारा लिया गया Space।',
      'Devices की संख्या।',
      'Digital उपयोग से उत्पन्न ऊर्जा और उत्सर्जन।',
      'Internet Bills की कीमत।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डिजिटल कार्बन फुटप्रिंट (Digital Carbon Footprint) डिजिटल उपयोग (जैसे सर्वर, डेटा सेंटर) से उत्पन्न ऊर्जा और उत्सर्जन की मात्रा है।',
  ),
  QuizQuestion(
    id: 'cit443',
    question: 'निम्न में से कौन-सी Green IT Solution है?',
    options: [
      'Devices को रातभर चालू रखना।',
      'पुराने Servers का उपयोग करना।',
      'Energy-Efficient Hardware।',
      'सभी डाटा को USB में स्टोर करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Energy-Efficient Hardware (ऊर्जा-कुशल हार्डवेयर) एक ग्रीन IT सॉल्यूशन (Green IT Solution) है।',
  ),
  QuizQuestion(
    id: 'cit444',
    question: 'व्यक्ति अपना Digital Carbon Footprint कैसे घटा सकते हैं?',
    options: [
      'कई Cloud Accounts बनाकर।',
      'बार-बार Devices Upgrade करके।',
      'Cloud Storage से पुराने डाटा हटाकर।',
      'Power-Saving Settings को बंद करके।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'व्यक्ति क्लाउड स्टोरेज से पुराने और अनुपयोगी डाटा को हटाकर अपना डिजिटल कार्बन फुटप्रिंट कम कर सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit445',
    question: 'Sustainability के लिए Cloud Computing का एक लाभ क्या है?',
    options: [
      'स्थानीय Power उपयोग बढ़ाना।',
      'ज़्यादा Paper उपयोग करना।',
      'Hardware पर निर्भरता और Energy Waste को कम करना।',
      'रोज़ाना Downloads को बढ़ावा देना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'क्लाउड कंप्यूटिंग (Cloud Computing) हार्डवेयर पर निर्भरता और एनर्जी वेस्ट (Energy Waste) को कम करने में मदद करता है।',
  ),
  QuizQuestion(
    id: 'cit446',
    question:
        'इनमें से कौन-सी क्रिया Internet Energy Consumption को बढ़ाती है?',
    options: [
      'Unused Apps हटाना।',
      'Videos को लगातार Stream करना।',
      'Files को Compress करना।',
      'Auto-Sync बंद करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'वीडियो को लगातार स्ट्रीम (Stream) करना इंटरनेट एनर्जी कंजम्पशन (Energy Consumption) को बढ़ाता है।',
  ),
  QuizQuestion(
    id: 'cit447',
    question: 'Digital Storage Waste को घटाने का प्रभावी तरीका क्या है?',
    options: [
      'सभी Files को हमेशा रखना।',
      'केवल HD में वीडियो डाउनलोड करना।',
      'Unused Files हटाना और Documents Compress करना।',
      'Files को कई जगह Duplicate करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डिजिटल स्टोरेज वेस्ट कम करने के लिए अनुपयोगी फाइलें हटाएं और दस्तावेज़ों को कंप्रेस (Compress) करें।',
  ),
  QuizQuestion(
    id: 'cit448',
    question: 'AI Sustainability को कैसे Support करता है?',
    options: [
      'Gaming Performance बढ़ाकर।',
      'Background Processes बढ़ाकर।',
      'Energy Usage को Optimise करके।',
      'पारंपरिक तरीकों से ज़्यादा बिजली उपयोग करके।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'AI (Artificial Intelligence) एनर्जी उपयोग को ऑप्टिमाइज़ (Optimise) करके सस्टेनेबिलिटी (Sustainability) का समर्थन करता है।',
  ),
  QuizQuestion(
    id: 'cit449',
    question:
        'निम्न में से कौन-सा Smart Home Device Energy Saving में मदद करता है?',
    options: [
      'Bluetooth Speaker',
      'Smart Thermostat',
      'USB Charger',
      'Regular Lightbulb',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Smart Thermostat (स्मार्ट थर्मोस्टेट) एनर्जी सेविंग (Energy Saving) में मदद करता है।',
  ),
  QuizQuestion(
    id: 'cit450',
    question: 'Apps का Unnecessary Auto-Sync क्यों Avoid करना चाहिए?',
    options: [
      'इससे Internet Speed बढ़ती है।',
      'यह Manual Updates कम करता है।',
      'यह ज़्यादा Energy और Data Consume करता है।',
      'इससे Storage Space बढ़ती है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'अनावश्यक ऑटो-सिंक (Auto-Sync) अधिक ऊर्जा (Energy) और डाटा (Data) की खपत करता है, इसलिए इससे बचना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit451',
    question: 'Resume का मुख्य उद्देश्य क्या है?',
    options: [
      'Loan के लिए आवेदन करना।',
      'Personal Hobbies को बताना।',
      'Employers को Qualification और Work Experience दिखाना।',
      'Biography लिखना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'रिज्यूमे (Resume) का मुख्य उद्देश्य नियोक्ताओं (Employers) को आपकी योग्यता (Qualification) और कार्य अनुभव (Work Experience) दिखाना है।',
  ),
  QuizQuestion(
    id: 'cit452',
    question: 'Resume में कौन-सा सेक्शन ऊपर होता है?',
    options: ['Education', 'Hobbies', 'Professional Summary', 'References'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'रिज्यूमे में सबसे ऊपर प्रोफेशनल समरी (Professional Summary) या उद्देश्य (Objective) सेक्शन होता है।',
  ),
  QuizQuestion(
    id: 'cit453',
    question:
        'लगातार अनुभव वाले व्यक्ति के लिए सबसे उपयुक्त Resume Format कौन-सा है?',
    options: ['Functional', 'Chronological', 'Infographic', 'Narrative'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'लगातार (Continuous) अनुभव वाले व्यक्ति के लिए Chronological Resume Format सबसे उपयुक्त है।',
  ),
  QuizQuestion(
    id: 'cit454',
    question: 'Star Method का अर्थ क्या है?',
    options: [
      'Skills, Tasks, Abilities, Resume',
      'Situation, Task, Action, Result',
      'Start, Train, Apply, Repeat',
      'Summary, Time, Action, Resume',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'STAR Method का अर्थ है: Situation (परिस्थिति), Task (कार्य), Action (कार्रवाई), Result (परिणाम)।',
  ),
  QuizQuestion(
    id: 'cit455',
    question: 'निम्न में से कौन-सी Strong Resume Summary है?',
    options: [
      '"सीखने के लिए नौकरी की तलाश।"',
      '"कुछ अनुभव नहीं है लेकिन कोशिश करूंगा।"',
      '"Marketing Specialist With 4+ Years Of Experience In SEO And Campaign Strategy."',
      '"किसी भी Role के लिए उपलब्ध।"',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एक मजबूत रिज्यूमे समरी विशिष्ट (Specific), अनुभव-आधारित और उपलब्धियों पर केंद्रित होती है, जैसे विकल्प 3।',
  ),
  QuizQuestion(
    id: 'cit456',
    question: 'निम्न में से कौन-सा Resume Format नहीं है?',
    options: ['Functional', 'Chronological', 'Rotational', 'Hybrid'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Rotational Resume Format मान्य (Standard) फॉर्मेट नहीं है। Functional, Chronological, और Hybrid प्रमुख फॉर्मेट हैं।',
  ),
  QuizQuestion(
    id: 'cit457',
    question: 'Resume को Pdf में सेव करने का लाभ क्या है?',
    options: [
      'ताकि अन्य लोग Edit कर सकें।',
      'Password से सुरक्षित करने के लिए।',
      'Formatting हर डिवाइस पर वैसी ही बनी रहे।',
      'क्योंकि हर कंपनी केवल Pdf स्वीकार करती है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'PDF में सेव करने से फॉर्मेटिंग (Formatting) हर डिवाइस पर वैसी ही बनी रहती है।',
  ),
  QuizQuestion(
    id: 'cit458',
    question: 'Resume के लिए एक अच्छा फाइल नाम क्या है?',
    options: [
      'Resume.doc',
      'Finalresume2.Pdf',
      'Myresumenew.pdf',
      'John_doe_resume.pdf',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'एक अच्छा फाइल नाम प्रोफेशनल और वर्णनात्मक होता है, जैसे john_doe_resume.pdf।',
  ),
  QuizQuestion(
    id: 'cit459',
    question: 'Professional Resume Templates कहाँ मिल सकते हैं?',
    options: ['MS Paint', 'Google Docs', 'Calculator', 'Youtube'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google Docs में बिल्ट-इन प्रोफेशनल रिज्यूमे टेम्पलेट्स (Resume Templates) मिलते हैं।',
  ),
  QuizQuestion(
    id: 'cit460',
    question: 'Resume ईमेल करते समय क्या नहीं करना चाहिए?',
    options: [
      'PDF Attach करना।',
      'विनम्र संदेश लिखना।',
      'Subject Line खाली छोड़ना।',
      'प्रोफेशनल फाइल नाम का उपयोग करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'रिज्यूमे ईमेल करते समय Subject Line खाली नहीं छोड़नी चाहिए; यह अव्यवसायिक (Unprofessional) है।',
  ),
  QuizQuestion(
    id: 'cit461',
    question: 'Linkedin का मुख्य उद्देश्य क्या है?',
    options: [
      'Entertainment',
      'Online Shopping',
      'Professional Networking',
      'Video Sharing',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'LinkedIn का मुख्य उद्देश्य प्रोफेशनल नेटवर्किंग (Professional Networking) है।',
  ),
  QuizQuestion(
    id: 'cit462',
    question:
        'Linkedin प्रोफाइल का कौन-सा सेक्शन आपके अनुभव और उपलब्धियाँ दिखाता है?',
    options: ['Connections', 'Summary', 'Notifications', 'Experience'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'LinkedIn प्रोफाइल में "Experience" (अनुभव) सेक्शन आपके कार्य अनुभव और उपलब्धियों को दर्शाता है।',
  ),
  QuizQuestion(
    id: 'cit463',
    question: 'Linkedin पर Professional Headline क्यों महत्वपूर्ण होती है?',
    options: [
      'इससे आप वीडियो देख सकते हैं।',
      'यह Search Results में दिखती है और Recruiters का ध्यान खींचती है।',
      'यह ADS को ब्लॉक करती है।',
      'इससे Messages भेजे जा सकते हैं।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Professional Headline (प्रोफेशनल हेडलाइन) सर्च रिजल्ट्स में दिखती है और रिक्रूटर्स (Recruiters) का ध्यान खींचती है।',
  ),
  QuizQuestion(
    id: 'cit464',
    question: 'Linkedin पर आपकी Credibility बढ़ाने के लिए क्या फायदेमंद है?',
    options: [
      'Random Posts को Like करना।',
      'Skill Endorsements प्राप्त करना।',
      'बार-बार नाम बदलना।',
      'Selfies पोस्ट करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'LinkedIn पर Skill Endorsements (कौशल समर्थन) प्राप्त करना आपकी विश्वसनीयता (Credibility) बढ़ाने में फायदेमंद है।',
  ),
  QuizQuestion(
    id: 'cit465',
    question: 'एक अच्छा Linkedin Summary किस पर केंद्रित होना चाहिए?',
    options: [
      'Jokes और Quotes',
      'Irrelevant Job History',
      'Career Goals और Achievements',
      'पसंदीदा फिल्में',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'एक अच्छा LinkedIn समरी (Summary) करियर लक्ष्यों (Career Goals) और उपलब्धियों (Achievements) पर केंद्रित होना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit466',
    question: 'Linkedin पर नई नौकरियाँ खोजने में कौन-सी सुविधा मदद करती है?',
    options: ['Stories', 'Linkedin Live', 'Job Search Filters', 'Emojis'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'LinkedIn पर Job Search Filters (नौकरी खोज फ़िल्टर) नई नौकरियाँ खोजने में मदद करते हैं।',
  ),
  QuizQuestion(
    id: 'cit467',
    question: 'Linkedin पर किसी से Connect करने का सबसे अच्छा तरीका क्या है?',
    options: [
      'Blank Connection Request भेजना।',
      'Personalised Message भेजना।',
      'उन्हें Unrelated Posts में Tag करना।',
      'Memes भेजना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'LinkedIn पर किसी से कनेक्ट (Connect) करने का सबसे अच्छा तरीका एक व्यक्तिगत संदेश (Personalised Message) भेजना है।',
  ),
  QuizQuestion(
    id: 'cit468',
    question: 'Recruiters को अपनी प्रोफाइल दिखाने के लिए कौन-सी चीज़ सहायक है?',
    options: [
      'Travel Photos शेयर करना।',
      'Certifications और Skills जोड़ना।',
      'साल में एक बार पोस्ट करना।',
      'Messages को Ignore करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'रिक्रूटर्स (Recruiters) को अपनी प्रोफाइल दिखाने के लिए सर्टिफिकेशन (Certifications) और स्किल्स (Skills) जोड़ना सहायक होता है।',
  ),
  QuizQuestion(
    id: 'cit469',
    question: 'Linkedin पर Industry News से अपडेट रहने के लिए क्या करें?',
    options: [
      'Games खेलें।',
      'Industry Pages और Groups को Follow करें।',
      'Notifications को Ignore करें।',
      'Connections को Block करें।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'LinkedIn पर Industry News से अपडेट रहने के लिए Industry Pages और Groups को Follow (फॉलो) करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit470',
    question: 'Linkedin पर Job Apply करने के बाद क्या करना चाहिए?',
    options: [
      'कुछ न करें और इंतजार करें।',
      'कंपनी को रोज़ कॉल करें।',
      'Recruiter को एक Professional Message भेजें।',
      'Random Posts पर Comment करें।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'LinkedIn पर जॉब अप्लाई करने के बाद रिक्रूटर (Recruiter) को एक प्रोफेशनल मैसेज भेजना एक अच्छा अभ्यास है।',
  ),
  QuizQuestion(
    id: 'cit471',
    question: 'Freelancing की मुख्य विशेषता क्या है?',
    options: [
      'एक नियोक्ता के साथ Full-Time कार्य करना।',
      'Physical Business चलाना।',
      'एक से अधिक क्लाइंट्स को प्रोजेक्ट आधार पर सेवाएं देना।',
      'Unpaid Internship करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फ्रीलांसिंग (Freelancing) की मुख्य विशेषता एक से अधिक क्लाइंट्स को प्रोजेक्ट के आधार पर सेवाएं देना है।',
  ),
  QuizQuestion(
    id: 'cit472',
    question: 'Freelancing का कौन-सा लाभ है?',
    options: [
      'Guaranteed Pension',
      'Fixed Monthly Salary',
      'काम के समय और स्थान में लचीलापन',
      'फ्री Office Space',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फ्रीलांसिंग का एक बड़ा लाभ काम के समय और स्थान में लचीलापन (Flexibility) है।',
  ),
  QuizQuestion(
    id: 'cit473',
    question:
        'कौन-सा Platform Gig-Based है और Specific Services की Listing की अनुमति देता है?',
    options: ['Freelancer', 'Upwork', 'Fiverr', 'Linkedin'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Fiverr एक Gig-Based प्लेटफॉर्म है जहाँ फ्रीलांसर विशिष्ट सेवाओं (Services) को "Gig" के रूप में सूचीबद्ध कर सकते हैं।',
  ),
  QuizQuestion(
    id: 'cit474',
    question: 'Upwork पर औसतन Commission Fee कितनी होती है?',
    options: ['2%', '10–20%', '50%', '0%'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Upwork पर कमीशन फीस (Commission Fee) आमतौर पर 10-20% के बीच होती है।',
  ),
  QuizQuestion(
    id: 'cit475',
    question: 'Freelancer को अपनी Profile Summary में क्या शामिल करना चाहिए?',
    options: [
      'Personal Hobbies',
      'बचपन का विस्तृत इतिहास',
      'स्किल्स और अनुभव का सारांश',
      'राजनीतिक विचार',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फ्रीलांसर को अपनी प्रोफाइल समरी (Profile Summary) में अपने कौशल (Skills) और अनुभव का सारांश शामिल करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit476',
    question:
        'Freelancing Platforms पर Payments को सुरक्षित रूप से संभालने का सही तरीका क्या है?',
    options: [
      'Cash में Payment स्वीकार करना।',
      'Platform के Escrow Services का उपयोग करना।',
      'Client को सीधे Bank Details भेजना',
      'पहले Client को पैसे देना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'फ्रीलांसिंग प्लेटफॉर्म पर भुगतान सुरक्षित रूप से संभालने के लिए प्लेटफॉर्म की एस्क्रो (Escrow) सेवाओं का उपयोग करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit477',
    question: 'Freelancer को Job Post का जवाब कैसे देना चाहिए?',
    options: [
      'Generic Message के साथ।',
      'Personalised Proposal के साथ जो Client की ज़रूरतों को संबोधित करे।',
      'Client के पहले Reach करने का इंतजार करना।',
      'किसी और Freelancer की Proposal Copy करके।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'फ्रीलांसर को जॉब पोस्ट का जवाब एक व्यक्तिगत प्रस्ताव (Personalised Proposal) के साथ देना चाहिए जो क्लाइंट की जरूरतों को संबोधित करता हो।',
  ),
  QuizQuestion(
    id: 'cit478',
    question: 'Long-Term और Ongoing Work के लिए Ideal Payment Model क्या है?',
    options: ['Fixed Price', 'Monthly Salary', 'Hourly', 'Barter System'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'लॉन्ग-टर्म (दीर्घकालिक) काम के लिए आदर्श भुगतान मॉडल "Hourly" (प्रति घंटा) होता है।',
  ),
  QuizQuestion(
    id: 'cit479',
    question: 'Freelancing Platforms पर Scams से कैसे बचा जा सकता है?',
    options: [
      'हर Job बिना Details चेक किए स्वीकार करना।',
      'पहले Client को पैसे भेजना।',
      'Official Platform के माध्यम से Communication और Payments करना।',
      'Trust के लिए Passwords साझा करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फ्रीलांसिंग प्लेटफॉर्म पर स्कैम (Scams) से बचने के लिए आधिकारिक प्लेटफॉर्म के माध्यम से कम्युनिकेशन और भुगतान करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit480',
    question: 'अगर कोई Client Offer बहुत अच्छा लगे, तो क्या करना चाहिए?',
    options: [
      'तुरंत स्वीकार कर लेना।',
      'Ignore कर देना।',
      'सतर्क रहना और जरूरत पड़ने पर उसे Report करना।',
      'Verification के लिए अपनी सारी Personal Details भेजना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'बहुत अच्छा ऑफर (Too Good to be True) लगने पर सतर्क रहना चाहिए और आवश्यकता पड़ने पर रिपोर्ट (Report) करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit481',
    question: 'Digital Portfolio क्या है?',
    options: [
      'आपके Resume की Hard Copy',
      'एक Photo Editing Software',
      'आपके कार्यों और प्रोफेशनल प्रोफाइल का ऑनलाइन संग्रह',
      'एक प्रकार का Social Media Account',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डिजिटल पोर्टफोलियो (Digital Portfolio) आपके कार्यों और प्रोफेशनल प्रोफाइल का ऑनलाइन संग्रह है।',
  ),
  QuizQuestion(
    id: 'cit482',
    question: 'डिजिटल पोर्टफोलियो का कौन-सा लाभ है?',
    options: [
      'यह आपके Skills को Recruiters से छिपा देता है।',
      'यह सभी Email Communication को Replace कर देता है।',
      'यह आपके कार्य को कभी भी ऑनलाइन एक्सेसिबल बनाता है।',
      'यह Interview की जरूरत को खत्म कर देता है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डिजिटल पोर्टफोलियो का लाभ यह है कि यह आपके कार्य को कभी भी ऑनलाइन एक्सेसिबल बनाता है।',
  ),
  QuizQuestion(
    id: 'cit483',
    question:
        'Graphic Designers जैसे Creative Professionals के लिए कौन-सा प्लेटफ़ॉर्म सबसे उपयुक्त है?',
    options: ['Linkedin', 'Behance', 'Whatsapp', 'Google Docs'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Behance (Adobe का प्लेटफॉर्म) ग्राफिक डिजाइनर जैसे क्रिएटिव प्रोफेशनल्स के लिए सबसे उपयुक्त है।',
  ),
  QuizQuestion(
    id: 'cit484',
    question: 'किस सेक्शन में आपके Background और Goals का वर्णन होता है?',
    options: ['Gallery', 'Contact', 'About Me', 'Feedback'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पोर्टफोलियो में "About Me" (मेरे बारे में) सेक्शन में आपकी पृष्ठभूमि (Background) और लक्ष्यों (Goals) का वर्णन होता है।',
  ),
  QuizQuestion(
    id: 'cit485',
    question: 'पोर्टफोलियो में प्रोजेक्ट Descriptions का उद्देश्य क्या है?',
    options: [
      'Viewer को Confuse करना।',
      'संदर्भ देना और उपलब्धियाँ दिखाना।',
      'खाली जगह भरना।',
      'अधूरे कार्य को छिपाना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'पोर्टफोलियो में प्रोजेक्ट विवरण (Descriptions) का उद्देश्य संदर्भ (Context) देना और उपलब्धियाँ दिखाना है।',
  ),
  QuizQuestion(
    id: 'cit486',
    question: 'पोर्टफोलियो Content को Organise करते समय अच्छा अभ्यास क्या है?',
    options: [
      'Random Titles का उपयोग करना।',
      'सभी Projects को एक लम्बी लिस्ट में रखना।',
      'कार्य को Categories में बांटना और एक जैसे Formatting का उपयोग करना।',
      'Visuals से बचना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पोर्टफोलियो कंटेंट व्यवस्थित करते समय कार्य को श्रेणियों (Categories) में बांटना और एक जैसी फॉर्मेटिंग का उपयोग करना एक अच्छा अभ्यास है।',
  ),
  QuizQuestion(
    id: 'cit487',
    question: 'Testimonials पोर्टफोलियो में किसमें मदद करते हैं?',
    options: [
      'पहचान छिपाने में',
      'Credibility बढ़ाने में',
      'Users को Block करने में',
      'Layout को Colorful बनाने में',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Testimonials (प्रशंसापत्र) पोर्टफोलियो की विश्वसनीयता (Credibility) बढ़ाने में मदद करते हैं।',
  ),
  QuizQuestion(
    id: 'cit488',
    question: 'Digital Portfolio को कहाँ साझा नहीं करना चाहिए?',
    options: [
      'Professional Email',
      'Job Portals',
      'Linkedin',
      'Random Gaming Forums',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'डिजिटल पोर्टफोलियो को रैंडम गेमिंग फोरम (Random Gaming Forums) जैसी अनुपयुक्त जगहों पर साझा नहीं करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit489',
    question:
        'Beginners के लिए सबसे आसान पोर्टफोलियो बनाने वाला प्लेटफ़ॉर्म कौन-सा है?',
    options: ['Google Sites', 'Photoshop', 'Excel', 'Powerpoint'],
    correctIndex: 0,
    subject: 'BS-CIT',
    description:
        'शुरुआती (Beginners) के लिए Google Sites पोर्टफोलियो बनाने का सबसे आसान प्लेटफॉर्म है।',
  ),
  QuizQuestion(
    id: 'cit490',
    question: 'पोर्टफोलियो को नियमित रूप से अपडेट करना क्यों ज़रूरी है?',
    options: [
      'हर हफ्ते Font बदलने के लिए',
      'इसे प्राइवेट रखने के लिए',
      'अपने नवीनतम कार्य को दिखाने और प्रासंगिक बने रहने के लिए',
      'पुराने Jobs को Delete करने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पोर्टफोलियो को नियमित रूप से अपडेट करना आपके नवीनतम कार्य को दिखाने और प्रासंगिक बने रहने के लिए आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit491',
    question: 'Digital Financial Management Tools का मुख्य उद्देश्य क्या है?',
    options: [
      'Users को Online Entertain करना।',
      'Expenses और Income को Track और Manage करना।',
      'Online Shopping को Promote करना।',
      'Users को Social Media से Connect करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल फाइनेंशियल मैनेजमेंट टूल्स (जैसे Money View) का मुख्य उद्देश्य खर्चों (Expenses) और आय (Income) को ट्रैक और मैनेज करना है।',
  ),
  QuizQuestion(
    id: 'cit492',
    question: 'निम्न में से कौन-सा एक भारत में लोकप्रिय UPI-Based App है?',
    options: ['Whatsapp', 'Google Pay', 'Zoom', 'Linkedin'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Google Pay भारत में एक लोकप्रिय UPI-आधारित भुगतान ऐप है। PhonePe और Paytm भी उदाहरण हैं।',
  ),
  QuizQuestion(
    id: 'cit493',
    question: 'UPI का पूरा नाम क्या है?',
    options: [
      'Unified Payment Interface',
      'Universal Payment Integration',
      'Unique Payment Instruction',
      'United Platform For India',
    ],
    correctIndex: 0,
    subject: 'BS-CIT',
    description: 'UPI का पूरा नाम Unified Payments Interface है।',
  ),
  QuizQuestion(
    id: 'cit494',
    question: 'Budgeting Apps का एक Benefit क्या है?',
    options: [
      'Games खेलने के लिए',
      'Entertainment बढ़ाने के लिए',
      'Spending Monitor और Control करने के लिए',
      'Phone Memory कम करने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Budgeting Apps (बजटिंग ऐप्स) का एक लाभ खर्च (Spending) की निगरानी और नियंत्रण करना है।',
  ),
  QuizQuestion(
    id: 'cit495',
    question:
        'Phonepe या Google Pay से Digital Payment की Key Feature क्या है?',
    options: [
      'Payments सिर्फ रात में किए जा सकते हैं।',
      'Transactions में एक हफ्ता लगता है।',
      'Real-Time पैसे भेजना Using Mobile Number या UPI Id।',
      'Physical Bank Visit ज़रूरी होता है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'PhonePe या Google Pay की प्रमुख विशेषता मोबाइल नंबर या UPI ID का उपयोग करके रियल-टाइम (Real-Time) में पैसे भेजना है।',
  ),
  QuizQuestion(
    id: 'cit496',
    question: 'इनमें से कौन एक Common Online Fraud है?',
    options: ['Phishing', 'Networking', 'Streaming', 'Data Backup'],
    correctIndex: 0,
    subject: 'BS-CIT',
    description: 'Phishing (फिशिंग) एक आम ऑनलाइन फ्रॉड (Online Fraud) है।',
  ),
  QuizQuestion(
    id: 'cit497',
    question: 'Digital Transactions के दौरान Safe Practice क्या है?',
    options: [
      'OTPS को दूसरों से Share करना।',
      'Unknown Payment Links पर Click करना।',
      'Secure Apps का उपयोग करना और Sensitive Details Share न करना।',
      'Public Wi-Fi का उपयोग करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डिजिटल लेनदेन के दौरान सुरक्षित ऐप्स (Secure Apps) का उपयोग करना और संवेदनशील जानकारी साझा न करना एक सुरक्षित अभ्यास (Safe Practice) है।',
  ),
  QuizQuestion(
    id: 'cit498',
    question:
        'Recurring Payments Track और Schedule करने के लिए कौन सा टूल मदद करता है?',
    options: [
      'Music App',
      'Alarm Clock',
      'Bill Payment App With Reminders',
      'Weather App',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'रिमाइंडर (Reminders) वाला बिल पेमेंट ऐप (Bill Payment App) आवर्ती भुगतान (Recurring Payments) को ट्रैक और शेड्यूल करने में मदद करता है।',
  ),
  QuizQuestion(
    id: 'cit499',
    question: 'निम्न में से कौन-सा Financial Management App नहीं है?',
    options: ['Money View', 'Paytm', 'Monefy', 'Spotify'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'Spotify एक म्यूजिक स्ट्रीमिंग ऐप है, यह फाइनेंशियल मैनेजमेंट ऐप नहीं है।',
  ),
  QuizQuestion(
    id: 'cit500',
    question: 'यदि आपको Suspicious Payment Request मिले तो क्या करें?',
    options: [
      'तुरंत भुगतान करें।',
      'Friends से Share करें।',
      'Sender से Verify करें या Ignore करें।',
      'Social Media पर Post करें।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'संदिग्ध (Suspicious) भुगतान अनुरोध मिलने पर प्रेषक (Sender) से सत्यापन (Verify) करें या उसे नज़रअंदाज (Ignore) करें।',
  ),
  QuizQuestion(
    id: 'cit501',
    question: 'ऑफिस कार्यों में अच्छी टाइपिंग स्किल का एक प्रमुख लाभ क्या है?',
    options: [
      'बेहतर ड्राइंग क्षमता',
      'संचार में देरी',
      'कार्यों में बेहतर गति और सटीकता',
      'इंटरनेट की गति बढ़ना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'अच्छी टाइपिंग स्किल (Typing Skills) का लाभ कार्यों में बेहतर गति (Speed) और सटीकता (Accuracy) है।',
  ),
  QuizQuestion(
    id: 'cit502',
    question:
        'निम्न में से कौन-सा Job Role मजबूत डाटा एंट्री कौशल की आवश्यकता रखता है?',
    options: ['Chef', 'Data Analyst', 'Electrician', 'Tour Guide'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डाटा एनालिस्ट (Data Analyst) की भूमिका के लिए मजबूत डाटा एंट्री कौशल (Data Entry Skills) की आवश्यकता होती है।',
  ),
  QuizQuestion(
    id: 'cit503',
    question:
        'डाटा एंट्री के लिए आम तौर पर उपयोग किया जाने वाला Tool कौन-सा है?',
    options: ['Photoshop', 'Excel', 'Zoom', 'VLC Media Player'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डाटा एंट्री (Data Entry) के लिए आमतौर पर Excel (स्प्रेडशीट) का उपयोग किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit504',
    question: 'टाइपिंग करते समय सही Posture क्यों जरूरी है?',
    options: [
      'स्क्रीन की Brightness कम करने के लिए',
      'टाइपिंग Noise बढ़ाने के लिए',
      'तनाव को कम करने और दक्षता बढ़ाने के लिए',
      'कीबोर्ड को सुंदर दिखाने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'टाइपिंग करते समय सही मुद्रा (Posture) तनाव कम करने और दक्षता (Efficiency) बढ़ाने के लिए आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit505',
    question: 'Numeric Keypad किसमें सहायक होता है?',
    options: [
      'दस्तावेज़ों का Formatting',
      'इंटरनेट ब्राउज़िंग',
      'संख्याओं को जल्दी और कुशलतापूर्वक दर्ज करना',
      'Games खेलना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Numeric Keypad (न्यूमेरिक कीपैड) संख्याओं को जल्दी और कुशलतापूर्वक दर्ज करने में सहायक होता है।',
  ),
  QuizQuestion(
    id: 'cit506',
    question: 'टाइपिंग स्पीड बढ़ाने में क्या सहायक होता है?',
    options: [
      'Video देखना',
      'Random Keys टाइप करना',
      'Structured Typing Exercises का अभ्यास',
      'Mouse का अधिक उपयोग',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'संरचित टाइपिंग अभ्यास (Structured Typing Exercises) का अभ्यास टाइपिंग स्पीड बढ़ाने में सहायक होता है।',
  ),
  QuizQuestion(
    id: 'cit507',
    question: 'डाटा एंट्री में एक सामान्य गलती क्या है?',
    options: [
      'Templates का उपयोग करना',
      'डाटा को मैन्युअली एंटर करना',
      'गलत मान दर्ज करना',
      'फाइल्स को सेव करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डाटा एंट्री में एक सामान्य गलती गलत मान (Incorrect Values) दर्ज करना है।',
  ),
  QuizQuestion(
    id: 'cit508',
    question: 'Short-Form Data Entry के लिए सबसे उपयुक्त Software कौन-सा है?',
    options: ['Paint', 'Google Sheets', 'Whatsapp', 'Powerpoint'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'शॉर्ट-फॉर्म डाटा एंट्री के लिए Google Sheets (या Excel) सबसे उपयुक्त है।',
  ),
  QuizQuestion(
    id: 'cit509',
    question: 'डाटा एंट्री में Formatting Errors से बचने का एक तरीका क्या है?',
    options: [
      'Formatting को अनदेखा करना',
      'Random Shortcuts का उपयोग करना',
      'Consistent Formatting Rules का पालन करना',
      'Tables का उपयोग न करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डाटा एंट्री में फॉर्मेटिंग एरर से बचने के लिए Consistent Formatting Rules (एकसमान फॉर्मेटिंग नियम) का पालन करना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit510',
    question: 'डाटा एंट्री में Quality Control का उद्देश्य क्या है?',
    options: [
      'Files को रंगीन बनाना।',
      'डाटा को सटीक और भरोसेमंद बनाना।',
      'केवल गति बढ़ाना।',
      'कम उपयोगकर्ता एक्सेस देना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Quality Control (गुणवत्ता नियंत्रण) का उद्देश्य डाटा को सटीक (Accurate) और भरोसेमंद (Reliable) बनाना है।',
  ),
  QuizQuestion(
    id: 'cit511',
    question: 'Digital Customer Service का मुख्य उद्देश्य क्या है?',
    options: [
      'सभी ईमेल का उत्तर देना।',
      'Email, Chat और Social Media के माध्यम से ग्राहक की सहायता करना।',
      'बिक्री लेनदेन करना।',
      'कंपनी के सोशल मीडिया अकाउंट्स प्रबंधित करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल कस्टमर सर्विस (Digital Customer Service) का मुख्य उद्देश्य ईमेल, चैट और सोशल मीडिया के माध्यम से ग्राहकों की सहायता करना है।',
  ),
  QuizQuestion(
    id: 'cit512',
    question: 'इनमें से कौन Digital Customer Service का सामान्य चैनल नहीं है?',
    options: ['Email', 'In-Person Interactions', 'Chat', 'Social Media'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'In-Person Interactions (व्यक्तिगत बातचीत) डिजिटल कस्टमर सर्विस का चैनल नहीं है।',
  ),
  QuizQuestion(
    id: 'cit513',
    question: 'Digital Customer Service का कौन-सा लाभ है?',
    options: [
      'परिचालन लागत बढ़ाना।',
      'वैश्विक स्तर पर ग्राहकों से संवाद करना।',
      'केवल कार्य समय में ही सेवा देना।',
      'ग्राहक को कॉल करने के लिए मजबूर करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'डिजिटल कस्टमर सर्विस का एक लाभ वैश्विक स्तर पर ग्राहकों से संवाद करना है।',
  ),
  QuizQuestion(
    id: 'cit514',
    question:
        'Email या Chat के माध्यम से ग्राहक प्रश्न का उत्तर देने की सर्वोत्तम प्रथा क्या है?',
    options: [
      'पेशेवर दिखने के लिए कठिन शब्दों का प्रयोग करें।',
      'समय पर उत्तर दें, सरल और स्पष्ट भाषा में।',
      'तब तक समाधान न दें जब तक पूरी जानकारी न हो।',
      'एक सामान्य उत्तर भेजें।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'ग्राहक प्रश्नों का उत्तर समय पर (Timely) और सरल एवं स्पष्ट भाषा (Simple and Clear Language) में देना सर्वोत्तम प्रथा है।',
  ),
  QuizQuestion(
    id: 'cit515',
    question: 'Digital Customer Service में सामान्य गलती क्या है?',
    options: [
      'व्यक्तिगत सहायता देना।',
      'Professional और विनम्र भाषा का प्रयोग।',
      'ग्राहक फीडबैक की अनदेखी करना।',
      'समय पर प्रतिक्रिया देना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डिजिटल कस्टमर सर्विस में ग्राहक फीडबैक (Customer Feedback) की अनदेखी करना एक सामान्य गलती है।',
  ),
  QuizQuestion(
    id: 'cit516',
    question:
        'कौन-सा Crm टूल हेल्प सेंटर और ग्राहक प्रश्नों को प्रबंधित करने के लिए जाना जाता है?',
    options: ['Google Drive', 'Zendesk', 'Microsoft Excel', 'Slack'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Zendesk एक प्रसिद्ध CRM टूल है जो हेल्प सेंटर (Help Center) और ग्राहक प्रश्नों को प्रबंधित करने के लिए जाना जाता है।',
  ),
  QuizQuestion(
    id: 'cit517',
    question: 'Digital Customer Service में CRM टूल का कार्य क्या है?',
    options: [
      'आंतरिक कार्यों का प्रबंधन करना।',
      'ग्राहक समस्याओं, बातचीत और समाधानों का रिकॉर्ड रखना।',
      'मार्केटिंग अभियान स्वचालित करना।',
      'कंपनी की वित्तीय स्थिति प्रबंधित करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'CRM टूल का कार्य ग्राहक समस्याओं, बातचीत और समाधानों का रिकॉर्ड रखना है।',
  ),
  QuizQuestion(
    id: 'cit518',
    question: 'कठिन ग्राहकों की शिकायतों को कैसे संभालना चाहिए?',
    options: [
      'शिकायत को तब तक अनदेखा करें जब तक ग्राहक शांत न हो।',
      'ईमानदारी से क्षमा मांगें और समाधान पेश करें।',
      'बिना हल किए शिकायत को बढ़ा दें।',
      'प्रतिक्रिया न दें।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'कठिन ग्राहकों की शिकायतों को ईमानदारी से माफी मांगकर और समाधान पेश करके संभालना चाहिए।',
  ),
  QuizQuestion(
    id: 'cit519',
    question: 'CRM का पूर्ण रूप क्या है?',
    options: [
      'Customer Resource Management',
      'Customer Repair Method',
      'Customer Relationship Management',
      'Client Review Management',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description: 'CRM का पूरा रूप Customer Relationship Management है।',
  ),
  QuizQuestion(
    id: 'cit520',
    question: 'CRM टूल्स में "Ticket" में क्या ट्रैक किया जाता है?',
    options: [
      'ग्राहक की भुगतान जानकारी',
      'ग्राहक की समस्या और उसकी स्थिति',
      'मार्केटिंग अभियान',
      'ग्राहक की खरीदारी का इतिहास',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'CRM टूल्स में "Ticket" (टिकट) में ग्राहक की समस्या (Issue) और उसकी स्थिति (Status) ट्रैक की जाती है।',
  ),
  QuizQuestion(
    id: 'cit521',
    question: 'Data Analytics का मुख्य कार्य क्या है?',
    options: [
      'वेबसाइट डिज़ाइन करना।',
      'ग्राफिक्स एडिट करना।',
      'डाटा को इकट्ठा करना, व्यवस्थित करना और विश्लेषण करना।',
      'कंटेंट लिखना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डाटा एनालिटिक्स (Data Analytics) का मुख्य कार्य डाटा को इकट्ठा (Collect), व्यवस्थित (Organize) और विश्लेषण (Analyze) करना है।',
  ),
  QuizQuestion(
    id: 'cit522',
    question:
        'कौन-सा उद्योग धोखाधड़ी पहचानने के लिए डाटा एनालिटिक्स का उपयोग करता है?',
    options: ['Education', 'Agriculture', 'Finance', 'Tourism'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Finance (वित्त) उद्योग धोखाधड़ी (Fraud) का पता लगाने के लिए डाटा एनालिटिक्स का उपयोग करता है।',
  ),
  QuizQuestion(
    id: 'cit523',
    question: 'कौन-सा एनालिटिक्स भविष्य की संभावनाओं का अनुमान लगाता है?',
    options: [
      'Descriptive Analytics',
      'Diagnostic Analytics',
      'Predictive Analytics',
      'Comparative Analytics',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Predictive Analytics (भविष्यसूचक विश्लेषण) भविष्य की संभावनाओं का अनुमान लगाता है।',
  ),
  QuizQuestion(
    id: 'cit524',
    question:
        'निम्न में से कौन-सा टूल डाटा विज़ुअलाइज़ेशन के लिए सामान्यतः उपयोग होता है?',
    options: ['Photoshop', 'Excel', 'MS Word', 'Notepad'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Excel (स्प्रेडशीट) में बिल्ट-इन चार्ट और ग्राफ के माध्यम से डाटा विज़ुअलाइज़ेशन (Data Visualization) की सुविधा होती है।',
  ),
  QuizQuestion(
    id: 'cit525',
    question: 'Prescriptive Analytics व्यवसायों को किस प्रकार मदद करता है?',
    options: [
      'पुराने डाटा की समीक्षा करता है।',
      'वर्तनी सुधारता है।',
      'भविष्य के लिए कार्य की सिफारिश करता है।',
      'रिकॉर्ड करता है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Prescriptive Analytics (निर्देशात्मक विश्लेषण) व्यवसायों को भविष्य के लिए कार्रवाई की सिफारिश (Recommend) करने में मदद करता है।',
  ),
  QuizQuestion(
    id: 'cit526',
    question: 'साफ और व्यवस्थित डाटा क्यों ज़रूरी है?',
    options: [
      'अच्छा दिखता है।',
      'SEO बेहतर बनाता है।',
      'सही विश्लेषण और बेहतर निर्णय में मदद करता है।',
      'फ़ाइल का आकार कम करता है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'साफ और व्यवस्थित डाटा (Clean and Organized Data) सही विश्लेषण और बेहतर निर्णय लेने में मदद करता है।',
  ),
  QuizQuestion(
    id: 'cit527',
    question: 'पेशेवर डाटा विज़ुअलाइज़ेशन टूल कौन-सा है?',
    options: ['Paint', 'Tableau', 'VLC Media Player', 'Tally'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Tableau दुनिया में सबसे अधिक उपयोग किया जाने वाला पेशेवर डाटा विज़ुअलाइज़ेशन टूल है।',
  ),
  QuizQuestion(
    id: 'cit528',
    question: 'Business Analyst आमतौर पर डाटा का प्रयोग किस लिए करता है?',
    options: [
      'विज्ञापन डिज़ाइन करने के लिए',
      'ग्राहक विवरण दर्ज करने के लिए',
      'व्यापारिक निर्णयों के लिए',
      'हार्डवेयर समस्याओं को ठीक करने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Business Analyst (बिजनेस एनालिस्ट) डाटा का प्रयोग व्यापारिक निर्णय (Business Decisions) लेने के लिए करता है।',
  ),
  QuizQuestion(
    id: 'cit529',
    question: 'Data Analytics करियर के लिए मुख्य कौशल क्या है?',
    options: [
      'गायन क्षमता',
      'HTML कोडिंग',
      'विश्लेषणात्मक सोच',
      'कार्टून बनाना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डाटा एनालिटिक्स करियर के लिए विश्लेषणात्मक सोच (Analytical Thinking) मुख्य कौशल है।',
  ),
  QuizQuestion(
    id: 'cit530',
    question: 'इनमें से कौन-सी भूमिका Data Analytics ज्ञान की मांग करती है?',
    options: ['Plumber', 'Content Moderator', 'Data Scientist', 'Waiter'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Data Scientist (डाटा वैज्ञानिक) की भूमिका के लिए डाटा एनालिटिक्स ज्ञान की आवश्यकता होती है।',
  ),
  QuizQuestion(
    id: 'cit531',
    question: 'प्रोग्रामिंग का मुख्य उद्देश्य क्या है?',
    options: [
      'ग्राफिक्स डिजाइन करना।',
      'कंप्यूटर के लिए निर्देश लिखना।',
      'दस्तावेज संपादित करना।',
      'गेम खेलना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'प्रोग्रामिंग (Programming) का मुख्य उद्देश्य कंप्यूटर को निर्देश (Instructions) देना है कि उसे क्या करना है।',
  ),
  QuizQuestion(
    id: 'cit532',
    question: 'निम्नलिखित में से कौन-सा प्रोग्रामिंग का वास्तविक अनुप्रयोग है?',
    options: [
      'सोशल मीडिया ब्राउज़िंग',
      'स्प्रेडशीट फॉर्मेटिंग',
      'कार्यों का ऑटोमेशन',
      'ऑनलाइन वीडियो देखना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'प्रोग्रामिंग का एक वास्तविक अनुप्रयोग कार्यों का ऑटोमेशन (Automation) है, जैसे बार-बार होने वाले कार्यों को स्वचालित करना।',
  ),
  QuizQuestion(
    id: 'cit533',
    question: 'एक Front-End Developer मुख्य रूप से किस पर कार्य करता है?',
    options: [
      'सर्वर सुरक्षा',
      'आंतरिक व्यापार लॉजिक',
      'उपयोगकर्ता इंटरफेस और डिज़ाइन',
      'डेटाबेस केरी',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Front-End Developer (फ्रंट-एंड डेवलपर) मुख्य रूप से उपयोगकर्ता इंटरफेस (User Interface) और डिज़ाइन पर कार्य करता है।',
  ),
  QuizQuestion(
    id: 'cit534',
    question:
        'कौन-सी प्रोग्रामिंग भाषा डाटा साइंस और मशीन लर्निंग के लिए सामान्य है?',
    options: ['Java', 'Python', 'HTML', 'C'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Python (पायथन) डाटा साइंस (Data Science) और मशीन लर्निंग (Machine Learning) के लिए सबसे सामान्य प्रोग्रामिंग भाषा है।',
  ),
  QuizQuestion(
    id: 'cit535',
    question: '"Hello, World!" प्रोग्राम क्या होता है?',
    options: [
      'सोशल मीडिया अभिवादन',
      'वेबसाइट होमपेज',
      'प्रोग्रामिंग भाषा का परिचय देने वाला मूल उदाहरण',
      'टेक्स्ट एडिटर टूल',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        '"Hello, World!" प्रोग्राम प्रोग्रामिंग भाषा सीखने का सबसे पहला और मूल उदाहरण है।',
  ),
  QuizQuestion(
    id: 'cit536',
    question: 'निम्नलिखित में से कौन-सी बैकएंड डेवलपमेंट भूमिका है?',
    options: [
      'UI/UX डिज़ाइनर',
      'नेटवर्क एडमिनिस्ट्रेटर',
      'डेटाबेस डेवलपर',
      'कंटेंट क्रिएटर',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'डेटाबेस डेवलपर (Database Developer) एक बैकएंड डेवलपमेंट भूमिका है।',
  ),
  QuizQuestion(
    id: 'cit537',
    question: 'प्रोग्रामिंग में Loop क्या करता है?',
    options: [
      'प्रोग्राम को समाप्त करता है।',
      'ईमेल भेजता है।',
      'कोड के ब्लॉक को दोहराता है।',
      'टेक्स्ट को फॉर्मेट करता है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'प्रोग्रामिंग में Loop (लूप) कोड के एक ब्लॉक (Block) को बार-बार दोहराता है।',
  ),
  QuizQuestion(
    id: 'cit538',
    question:
        'Android में मोबाइल ऐप्स बनाने के लिए सबसे उपयुक्त टूल कौन-सा है?',
    options: ['HTML', 'Java', 'SQL', 'Python'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Android मोबाइल ऐप्स बनाने के लिए Java (कोटलिन) सबसे उपयुक्त प्रोग्रामिंग भाषा है।',
  ),
  QuizQuestion(
    id: 'cit539',
    question:
        'प्रोग्रामिंग ऑनलाइन सीखने के लिए कौन-सा प्लेटफ़ॉर्म शुरुआती लोगों के लिए अनुशंसित है?',
    options: ['Facebook', 'Udemy', 'Canva', 'Spotify'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Udemy (जैसे Coursera, Codecademy) शुरुआती (Beginners) लोगों के लिए प्रोग्रामिंग सीखने का एक अनुशंसित प्लेटफॉर्म है।',
  ),
  QuizQuestion(
    id: 'cit540',
    question: 'प्रोग्रामिंग में "Variable" क्या होता है?',
    options: [
      'एक प्रकार का कीबोर्ड शॉर्टकट',
      'डाटा संग्रहीत करने का स्थान',
      'सॉफ्टवेयर इंस्टॉलेशन',
      'प्रोग्रामिंग त्रुटि',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'प्रोग्रामिंग में Variable (चर) डाटा को स्टोर करने के लिए एक कंटेनर या स्थान होता है।',
  ),
  QuizQuestion(
    id: 'cit541',
    question: 'Youtube पर पैसे कमाने का एक सामान्य तरीका क्या है?',
    options: [
      'दर्शकों से नकद भुगतान लेना।',
      'चैनल के शेयर बेचना।',
      'Youtube Partner Program के माध्यम से Ads चलाना।',
      'लोगों से पैसे मांगना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'YouTube पर पैसे कमाने का एक सामान्य तरीका YouTube Partner Program (YPP) के माध्यम से विज्ञापन (Ads) चलाना है।',
  ),
  QuizQuestion(
    id: 'cit542',
    question: 'Affiliate Marketing का उदाहरण क्या है?',
    options: [
      'Sponsored Instagram पोस्ट बनाना।',
      'एक उत्पाद लिंक साझा करना और बिक्री पर कमीशन कमाना।',
      'खुद का Merchandise बेचना।',
      'मुफ्त में Ads पोस्ट करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Affiliate Marketing (एफिलिएट मार्केटिंग) का उदाहरण उत्पाद लिंक साझा करना और बिक्री पर कमीशन (Commission) कमाना है।',
  ),
  QuizQuestion(
    id: 'cit543',
    question: 'Niche चुनने का क्या लाभ है?',
    options: [
      'Editing समय बढ़ता है।',
      'कंटेंट महंगा हो जाता है।',
      'Targeted और वफादार ऑडियंस मिलती है।',
      'Monetisation के अवसर खत्म हो जाते हैं।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Niche (विशेष क्षेत्र) चुनने से Targeted (लक्षित) और वफादार (Loyal) ऑडियंस प्राप्त होती है।',
  ),
  QuizQuestion(
    id: 'cit544',
    question: 'Instagram पर प्रदर्शन मापने के लिए कौन सा Tool उपयुक्त है?',
    options: [
      'Whatsapp Analytics',
      'Instagram Insights',
      'Youtube Studio',
      'Canva',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Instagram पर प्रदर्शन मापने (Measure Performance) के लिए "Instagram Insights" टूल उपयुक्त है।',
  ),
  QuizQuestion(
    id: 'cit545',
    question: 'इनमें से कौन सुरक्षित Monetisation तरीका है?',
    options: [
      'Login Details साझा करना।',
      'अनजान Wallets से Payment स्वीकार करना।',
      'Youtube का Ad Revenue System उपयोग करना।',
      'Dm में पैसे मंगाना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'YouTube का Ad Revenue System (विज्ञापन राजस्व प्रणाली) एक सुरक्षित मुद्रीकरण (Monetisation) तरीका है।',
  ),
  QuizQuestion(
    id: 'cit546',
    question: 'Sponsored Content बनाते समय क्या जरूरी है?',
    options: [
      'Sponsor का नाम छिपाना।',
      'Hashtag #Ad से स्पष्ट रूप से बताना।',
      'Product को अपना बताना।',
      'इसके बारे में बात न करना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Sponsored Content (प्रायोजित सामग्री) बनाते समय #Ad (हैशटैग) के साथ स्पष्ट रूप से बताना आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit547',
    question: 'Content Calendar का क्या उपयोग है?',
    options: [
      'ऑडियंस बदलना।',
      'Advance में नियमित Content की योजना बनाना।',
      'Videos को अपने आप Upload करना।',
      'तुरंत Followers बढ़ाना।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Content Calendar (कंटेंट कैलेंडर) का उपयोग Advance में नियमित कंटेंट की योजना बनाने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit548',
    question: 'सोशल मीडिया घोटाले का लाल झंडा क्या है?',
    options: [
      'Verified Email',
      'Partnership से पहले Payment की मांग',
      'Official Brand Proposal',
      'Terms और Conditions का विवरण',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया घोटाले (Scam) का एक लाल झंडा (Red Flag) साझेदारी (Partnership) से पहले भुगतान (Payment) की मांग करना है।',
  ),
  QuizQuestion(
    id: 'cit549',
    question: 'Analytics Tools का उद्देश्य क्या है?',
    options: [
      'Ads की कीमत बढ़ाना।',
      'Competitors की जासूसी करना।',
      'यह मापना कि कौन-सा कंटेंट अच्छा प्रदर्शन करता है।',
      'Bank Details जांचना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Analytics Tools (एनालिटिक्स टूल्स) का उद्देश्य यह मापना (Measure) है कि कौन-सा कंटेंट अच्छा प्रदर्शन (Performance) करता है।',
  ),
  QuizQuestion(
    id: 'cit550',
    question: 'सोशल मीडिया पर Engagement क्यों महत्वपूर्ण है?',
    options: [
      'यह आपकी कमाई घटाता है।',
      'Algorithms के माध्यम से Reach बढ़ाता है।',
      'आपके Profile को छिपा देता है।',
      'आपके Account को Private बनाता है।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'सोशल मीडिया पर Engagement (सहभागिता) महत्वपूर्ण है क्योंकि यह Algorithms के माध्यम से Reach (पहुंच) बढ़ाता है।',
  ),
  QuizQuestion(
    id: 'cit551',
    question: 'Industry 4.0 मुख्य रूप से किस पर केंद्रित है?',
    options: [
      'Manual Labor और Mechanical Tools',
      'Digital Marketing और E-Commerce',
      'AI, IoT और Automation का एकीकरण।',
      'पारंपरिक निर्माण तकनीकें।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Industry 4.0 (उद्योग 4.0) AI, IoT (इंटरनेट ऑफ थिंग्स) और ऑटोमेशन (Automation) के एकीकरण (Integration) पर केंद्रित है।',
  ),
  QuizQuestion(
    id: 'cit552',
    question: 'निम्नलिखित में से कौन सा Industry 4.0 की एक प्रमुख विशेषता है?',
    options: [
      'Steam Engines का उपयोग।',
      'हस्तलिखित रिकॉर्ड्स का उपयोग।',
      'Smart Sensors और Data Analytics का उपयोग।',
      'कृषि उपकरणों पर ध्यान।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Industry 4.0 की एक प्रमुख विशेषता स्मार्ट सेंसर (Smart Sensors) और डाटा एनालिटिक्स (Data Analytics) का उपयोग है।',
  ),
  QuizQuestion(
    id: 'cit553',
    question:
        'भारत में किस इंडस्ट्री को AI द्वारा Predictive Healthcare से बदला जा रहा है?',
    options: ['शिक्षा', 'रियल एस्टेट', 'स्वास्थ्य सेवा (Healthcare)', 'कृषि'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'भारत में स्वास्थ्य सेवा (Healthcare) उद्योग में AI द्वारा Predictive Healthcare (भविष्यसूचक स्वास्थ्य सेवा) लागू की जा रही है।',
  ),
  QuizQuestion(
    id: 'cit554',
    question: 'Smart Factory सिस्टम को मैनेज करने वाले जॉब रोल का नाम क्या है?',
    options: [
      'Graphic Designer',
      'IoT Architect',
      'School Teacher',
      'Financial Advisor',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'IoT Architect (इंटरनेट ऑफ थिंग्स आर्किटेक्ट) स्मार्ट फैक्ट्री सिस्टम को मैनेज करता है।',
  ),
  QuizQuestion(
    id: 'cit555',
    question:
        'AI और Machine Learning करियर में कौन सी Programming Language सबसे सामान्य है?',
    options: ['HTML', 'Python', 'Css', 'Cobol'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'AI और Machine Learning करियर में Python प्रोग्रामिंग भाषा सबसे सामान्य (Common) है।',
  ),
  QuizQuestion(
    id: 'cit556',
    question: 'Automation का Job Market पर मुख्य प्रभाव क्या है?',
    options: [
      'इंटरनेट उपयोग में कमी।',
      'Manual Data Entry Jobs में वृद्धि।',
      'दोहराए जाने वाले कार्यों का मशीनों द्वारा प्रतिस्थापन।',
      'सभी White-Collar Jobs समाप्त होना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Automation (ऑटोमेशन) का Job Market पर मुख्य प्रभाव दोहराए जाने वाले कार्यों (Repetitive Tasks) का मशीनों द्वारा प्रतिस्थापन (Replacement) है।',
  ),
  QuizQuestion(
    id: 'cit557',
    question: 'Industry 4.0 के युग में Upskilling क्यों जरूरी है?',
    options: [
      'विदेश जाने के लिए।',
      'बदलती तकनीकों के साथ बने रहने के लिए।',
      'कंप्यूटर से बचने के लिए।',
      'कृषि कौशल सीखने के लिए।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Industry 4.0 के युग में Upskilling (कौशल वृद्धि) बदलती तकनीकों (Changing Technologies) के साथ बने रहने के लिए आवश्यक है।',
  ),
  QuizQuestion(
    id: 'cit558',
    question: 'Tech Skills सीखने के लिए कौन सा Free Platform है?',
    options: ['Netflix', 'Coursera', 'Myntra', 'IRCTC'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Coursera (ऑडिट मोड में) और अन्य जैसे freeCodeCamp टेक स्किल्स (Tech Skills) सीखने के लिए फ्री प्लेटफॉर्म हैं।',
  ),
  QuizQuestion(
    id: 'cit559',
    question: 'AI के निर्णय लेने में एक प्रमुख नैतिक चिंता क्या है?',
    options: [
      'टेक्नोलॉजी की ऊँची कीमत।',
      'बहुत अधिक जॉब अवसर।',
      'निर्णयों में मानव पारदर्शिता की कमी।',
      'डिवाइस की बैटरी जल्दी खत्म होना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'AI के निर्णय लेने (Decision Making) में एक प्रमुख नैतिक चिंता निर्णयों में मानव पारदर्शिता (Human Transparency) की कमी है।',
  ),
  QuizQuestion(
    id: 'cit560',
    question:
        'Technological Advancement और Employment को संतुलित करने का एक तरीका क्या है?',
    options: [
      'सभी मानव कर्मचारियों को प्रतिस्थापित करना।',
      'टेक्नोलॉजी का उपयोग नहीं करना।',
      'Upskilling और Reskilling Programs को समर्थन देना।',
      'केवल AI विशेषज्ञों को हायर करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Technological Advancement और Employment को संतुलित करने का एक तरीका Upskilling और Reskilling Programs को समर्थन देना है।',
  ),
  QuizQuestion(
    id: 'cit561',
    question: 'कृत्रिम बुद्धिमत्ता (AI) क्या है?',
    options: [
      'ईमेल तेज़ी से भेजने का तरीका',
      'डाटा ऑनलाइन स्टोर करने का एक उपकरण',
      'मशीनों द्वारा मानवीय बुद्धिमत्ता का अनुकरण',
      'एक प्रकार का सोशल मीडिया प्लेटफ़ॉर्म',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'कृत्रिम बुद्धिमत्ता (Artificial Intelligence - AI) मशीनों द्वारा मानवीय बुद्धिमत्ता (Human Intelligence) का अनुकरण (Simulation) है।',
  ),
  QuizQuestion(
    id: 'cit562',
    question: 'निम्नलिखित में से कौन-सा AI-संचालित लेखन सहायक है?',
    options: ['Excel', 'Whatsapp', 'Grammarly', 'Google Maps'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Grammarly एक AI-संचालित (AI-Powered) लेखन सहायक टूल है जो व्याकरण और शैली में सुधार करता है।',
  ),
  QuizQuestion(
    id: 'cit563',
    question: 'स्वचालन कार्यस्थलों में कैसे मदद करता है?',
    options: [
      'मैन्युअल कार्यभार बढ़ाता है।',
      'बिजली की आवश्यकता को समाप्त करता है।',
      'दोहराव वाले कार्यों को कम करता है और दक्षता बढ़ाता है।',
      'सभी मानवीय सहभागिता को रोकता है।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'स्वचालन (Automation) दोहराव वाले कार्यों (Repetitive Tasks) को कम करता है और दक्षता (Efficiency) बढ़ाता है।',
  ),
  QuizQuestion(
    id: 'cit564',
    question: 'कौन सा भारतीय अस्पताल निदान के लिए AI का उपयोग करता है?',
    options: ['Max Healthcare', 'Fortis', 'Apollo Hospitals', 'AIIMS'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Apollo Hospitals भारत में निदान (Diagnosis) के लिए AI का उपयोग करने वाले अस्पतालों में से एक है।',
  ),
  QuizQuestion(
    id: 'cit565',
    question: 'कार्य पर ChatGPT जैसे उपकरणों के उपयोग का मुख्य लाभ क्या है?',
    options: [
      'यह पासवर्ड स्टोर करता है।',
      'यह कंटेंट निर्माण को स्वचालित करता है और समय बचाता है।',
      'यह संगीत चलाता है।',
      'यह भुगतान भेजता है।',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'ChatGPT जैसे AI टूल्स का उपयोग कंटेंट निर्माण (Content Creation) को स्वचालित (Automate) करके समय बचाता है।',
  ),
  QuizQuestion(
    id: 'cit566',
    question: 'एआई से संबंधित एक प्रमुख नैतिक चिंता क्या है?',
    options: [
      'बहुत सारे विज्ञापन',
      'ईमेल समर्थन की कमी',
      'गोपनीयता मुद्दे और एल्गोरिदमिक पक्षपात',
      'खराब बैटरी जीवन',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'AI से संबंधित प्रमुख नैतिक चिंताओं (Ethical Concerns) में गोपनीयता के मुद्दे (Privacy Issues) और एल्गोरिदमिक पक्षपात (Algorithmic Bias) शामिल हैं।',
  ),
  QuizQuestion(
    id: 'cit567',
    question: 'स्वचालन में RPA का क्या अर्थ है?',
    options: [
      'Real-Time Processing Application',
      'Robotic Process Automation',
      'Rapid Program Assignment',
      'Responsive Platform App',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description: 'RPA का पूरा रूप Robotic Process Automation है।',
  ),
  QuizQuestion(
    id: 'cit568',
    question:
        'निम्नलिखित में से कौन से कार्य को AI उपकरणों से स्वचालित किया जा सकता है?',
    options: [
      'सोना',
      'दस्तावेज़ लिखना और सारांश बनाना',
      'खाना बनाना',
      'कपड़े धोना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'दस्तावेज़ लिखना (Document Writing) और सारांश बनाना (Summarization) AI टूल्स द्वारा स्वचालित किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit569',
    question:
        'निम्नलिखित में से कौन-सा क्षेत्र आमतौर पर एआई अनुप्रयोगों से संबद्ध नहीं है?',
    options: ['Healthcare', 'Retail', 'Education', 'Bricklaying'],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'Bricklaying (ईंटें लगाना) आमतौर पर AI अनुप्रयोगों (AI Applications) से संबद्ध नहीं है; यह अभी भी मुख्यतः मैनुअल कार्य है।',
  ),
  QuizQuestion(
    id: 'cit570',
    question:
        'कार्यस्थल में एआई उपकरणों का जिम्मेदारीपूर्वक उपयोग कैसे किया जा सकता है?',
    options: [
      'सूचनाओं को बंद करके।',
      'अपडेट को अनदेखा करके।',
      'सीमाओं को समझकर और मानवीय निगरानी बनाए रखकर।',
      'सभी मानव कर्मचारियों को बदलकर।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'AI टूल्स का जिम्मेदारीपूर्वक उपयोग उनकी सीमाओं (Limitations) को समझकर और मानवीय निगरानी (Human Oversight) बनाए रखकर किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit571',
    question: 'स्वचालन का मुख्य उद्देश्य क्या है?',
    options: [
      'कर्मचारियों की संख्या बढ़ाना।',
      'सभी नौकरियों को समाप्त करना।',
      'न्यूनतम मानवीय प्रयास में कार्य करना।',
      'मनोरंजन मूल्य बढ़ाना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'स्वचालन (Automation) का मुख्य उद्देश्य न्यूनतम मानवीय प्रयास (Minimum Human Effort) में कार्य करना है।',
  ),
  QuizQuestion(
    id: 'cit572',
    question: 'निम्नलिखित में से कौन-सा दैनिक जीवन में स्वचालन का उदाहरण है?',
    options: [
      'हाथ से लिखा पत्र भेजना।',
      'मैन्युअल अलार्म घड़ी सेट करना।',
      'अपने आप जलने वाली स्मार्ट लाइट्स।',
      'टाइपराइटर का उपयोग करना।',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'अपने आप जलने वाली (Self-Activating) स्मार्ट लाइट्स दैनिक जीवन में स्वचालन (Automation) का एक उदाहरण है।',
  ),
  QuizQuestion(
    id: 'cit573',
    question:
        'कौन-सा टूल विभिन्न ऐप्स को जोड़कर Workflows को स्वचालित करता है?',
    options: ['Zoom', 'Canva', 'Zapier', 'Google Meet'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Zapier एक टूल है जो विभिन्न ऐप्स (Applications) को जोड़कर Workflows को स्वचालित (Automate) करता है।',
  ),
  QuizQuestion(
    id: 'cit574',
    question: 'Ifttt का उपयोग किस लिए किया जाता है?',
    options: [
      'ग्राफिक डिज़ाइन बनाने के लिए',
      'सेवाओं और उपकरणों के बीच कार्यों को स्वचालित करने के लिए',
      'कोड लिखने के लिए',
      'वीडियो कॉन्फ्रेंसिंग के लिए',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'IFTTT (If This Then That) का उपयोग विभिन्न सेवाओं और उपकरणों के बीच कार्यों को स्वचालित (Automate) करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit575',
    question:
        'Microsoft Power Automate मुख्य रूप से किसलिए उपयोग किया जाता है?',
    options: [
      'वीडियो संपादन के लिए',
      'वेबसाइट बनाने के लिए',
      'पेशेवर दोहराव वाले कार्यों को स्वचालित करने के लिए',
      'गेम बनाने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Microsoft Power Automate (पहले Microsoft Flow) का उपयोग मुख्य रूप से पेशेवर दोहराव वाले कार्यों (Professional Repetitive Tasks) को स्वचालित करने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit576',
    question: 'स्वचालन उपकरणों में "ट्रिगर" क्या होता है?',
    options: [
      'कोड लिखने वाला व्यक्ति',
      'वह घटना जो स्वचालित क्रिया शुरू करती है',
      'पासवर्ड',
      'डिज़ाइन टूल',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'स्वचालन टूल्स (Automation Tools) में "Trigger" (ट्रिगर) वह घटना (Event) है जो स्वचालित क्रिया (Action) शुरू करती है।',
  ),
  QuizQuestion(
    id: 'cit577',
    question: 'निम्न में से कौन-सा स्वचालन का लाभ नहीं है?',
    options: [
      'मैन्युअल त्रुटियों में कमी',
      'समय की बचत',
      'दक्षता में वृद्धि',
      'अधिक मैन्युअल डाटा एंट्री की आवश्यकता',
    ],
    correctIndex: 3,
    subject: 'BS-CIT',
    description:
        'अधिक मैन्युअल डाटा एंट्री (Manual Data Entry) की आवश्यकता स्वचालन (Automation) का लाभ नहीं है; वास्तव में स्वचालन इसे कम करता है।',
  ),
  QuizQuestion(
    id: 'cit578',
    question:
        'Zapier या Ifttt का उपयोग कर कौन-सा कार्य स्वचालित किया जा सकता है?',
    options: [
      'निबंध लिखना',
      'निर्धारित समय पर घर की लाइट्स बंद करना',
      'ड्राइविंग टेस्ट देना',
      'चित्र बनाना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Zapier या IFTTT का उपयोग निर्धारित समय पर घर की लाइट्स बंद करने जैसे कार्यों को स्वचालित करने के लिए किया जा सकता है।',
  ),
  QuizQuestion(
    id: 'cit579',
    question: 'व्यवसायों में स्वचालन की एक चुनौती क्या है?',
    options: [
      'बेहतर संवाद',
      'असीमित बजट',
      'नौकरी विस्थापन का खतरा',
      'अत्यधिक फुर्सत का समय',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'व्यवसायों (Businesses) में स्वचालन की एक चुनौती नौकरी विस्थापन (Job Displacement) का खतरा है।',
  ),
  QuizQuestion(
    id: 'cit580',
    question: 'ग्राहक सहायता में स्वचालन कैसे मदद करता है?',
    options: [
      'अधिक स्टाफ को नियुक्त कर',
      'ईमेल को मैन्युअली छांटकर',
      'स्वचालित उत्तर और चैटबॉट्स के माध्यम से',
      'ग्राहक प्रश्नों को अक्षम करके',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ग्राहक सहायता (Customer Support) में स्वचालन स्वचालित उत्तर (Auto-Replies) और चैटबॉट्स (Chatbots) के माध्यम से मदद करता है।',
  ),
  QuizQuestion(
    id: 'cit581',
    question: 'रिमोट नौकरियों का एक प्रमुख लाभ क्या है?',
    options: [
      'सीमित कार्य समय',
      'केवल निश्चित वेतन',
      'कहीं से भी काम करने की सुविधा',
      'इंटरनेट की आवश्यकता नहीं',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'रिमोट नौकरियों (Remote Jobs) का एक प्रमुख लाभ कहीं से भी काम करने की सुविधा (Flexibility) है।',
  ),
  QuizQuestion(
    id: 'cit582',
    question: 'निम्न में से कौन-सी स्थानीय नौकरी का उदाहरण है?',
    options: [
      'US ग्राहक के लिए फ्रीलांस राइटर',
      'MNC के लिए घर से सॉफ्टवेयर डेवलपर',
      'स्थानीय रिटेल स्टोर में सेल्स असिस्टेंट',
      'अंतरराष्ट्रीय छात्रों को पढ़ाने वाला ऑनलाइन ट्यूटर',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'स्थानीय रिटेल स्टोर (Local Retail Store) में सेल्स असिस्टेंट एक स्थानीय नौकरी (Local Job) का उदाहरण है।',
  ),
  QuizQuestion(
    id: 'cit583',
    question: 'रिमोट कार्य की एक सामान्य चुनौती क्या है?',
    options: [
      'उच्च परिवहन लागत',
      'समय क्षेत्र का अंतर और संचार की कमी',
      'प्रतिदिन कार्यालय में उपस्थिति',
      'इंटरनेट की अनुपस्थिति',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'रिमोट कार्य (Remote Work) की एक सामान्य चुनौती समय क्षेत्र का अंतर (Time Zone Difference) और संचार की कमी (Lack of Communication) है।',
  ),
  QuizQuestion(
    id: 'cit584',
    question:
        'भारत के डिजिटल नौकरी बाजार में वर्तमान में कौन-सी स्किल माँग में है?',
    options: [
      'सुंदर लेखन',
      'टाइपराइटर पर टाइप करना',
      'Data Analysis',
      'टिकट संग्रह',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'भारत के डिजिटल नौकरी बाजार (Digital Job Market) में वर्तमान में Data Analysis (डाटा विश्लेषण) कौशल की मांग है।',
  ),
  QuizQuestion(
    id: 'cit585',
    question:
        'निम्न में से कौन-सा प्लेटफ़ॉर्म वैश्विक ग्राहकों से फ्रीलांसरों को जोड़ने के लिए प्रसिद्ध है?',
    options: ['IRCTC', 'Upwork', 'Youtube', 'Google Maps'],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Upwork (और Fiverr, Freelancer) वैश्विक ग्राहकों से फ्रीलांसरों (Freelancers) को जोड़ने के लिए प्रसिद्ध प्लेटफॉर्म हैं।',
  ),
  QuizQuestion(
    id: 'cit586',
    question:
        'ऑनलाइन प्लेटफ़ॉर्म के माध्यम से डिजिटल स्किल्स सीखने का एक प्रमुख लाभ क्या है?',
    options: [
      'उच्च शुल्क',
      'सीमित पहुँच',
      'लचीलापन और सस्ती शिक्षा',
      'प्रमाणपत्र नहीं मिलता',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'ऑनलाइन प्लेटफॉर्म से सीखने का प्रमुख लाभ लचीलापन (Flexibility) और सस्ती शिक्षा (Affordable Education) है।',
  ),
  QuizQuestion(
    id: 'cit587',
    question:
        'भारत में नौकरी खोजने के लिए सामान्यतः किस वेबसाइट का उपयोग किया जाता है?',
    options: ['Redbus', 'Swiggy', 'Naukri.com', 'Cricbuzz'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'भारत में नौकरी खोजने के लिए Naukri.com एक लोकप्रिय वेबसाइट है।',
  ),
  QuizQuestion(
    id: 'cit588',
    question: 'फ्रीलांसिंग प्लेटफॉर्म पर धोखाधड़ी से कैसे बचें?',
    options: [
      'प्लेटफॉर्म के बाहर भुगतान स्वीकार करें',
      'व्यक्तिगत बैंक PIN साझा करें',
      'रिव्यू पढ़ें और सुरक्षित भुगतान विधि अपनाएं',
      'सत्यापन के लिए ग्राहक को पैसे भेजें',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'फ्रीलांसिंग प्लेटफॉर्म पर धोखाधड़ी (Fraud) से बचने के लिए रिव्यू (Reviews) पढ़ें और सुरक्षित भुगतान विधि (Secure Payment Method) अपनाएं।',
  ),
  QuizQuestion(
    id: 'cit589',
    question: 'नौकरी खोजों में फिल्टर और कीवर्ड्स का उपयोग क्यों किया जाता है?',
    options: [
      'इंटरनेट का अधिक उपयोग करने के लिए',
      'सर्च को धीमा करने के लिए',
      'अधिक प्रासंगिक नौकरी लिस्टिंग खोजने के लिए',
      'आवेदन करने से बचने के लिए',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'नौकरी खोजों में फिल्टर (Filters) और कीवर्ड्स (Keywords) का उपयोग अधिक प्रासंगिक (Relevant) नौकरी लिस्टिंग खोजने के लिए किया जाता है।',
  ),
  QuizQuestion(
    id: 'cit590',
    question:
        'कौन-सा नौकरी बाजार आमतौर पर आपके क्षेत्र या शहर में ऑनसाइट भूमिकाएं प्रदान करता है?',
    options: ['Remote', 'International', 'Local', 'Cloud-Based'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Local Job Market (स्थानीय नौकरी बाजार) आमतौर पर आपके क्षेत्र या शहर में ऑनसाइट (Onsite) भूमिकाएं प्रदान करता है।',
  ),
  QuizQuestion(
    id: 'cit591',
    question: 'पाठ्यक्रम के अंत में परियोजना का मुख्य उद्देश्य क्या है?',
    options: [
      'तथ्यों को याद रखना',
      'सीखी गई कौशलों का आवेदन और प्रयोग करना',
      'Resume बनाना',
      'कोडिंग की मूल बातें सीखना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'पाठ्यक्रम के अंत में परियोजना (Project) का मुख्य उद्देश्य सीखी गई कौशलों का आवेदन (Application) और प्रयोग (Practice) करना है।',
  ),
  QuizQuestion(
    id: 'cit592',
    question:
        'निम्नलिखित में से कौन सा IT Support के लिए वैश्विक रूप से मान्यता प्राप्त प्रमाणपत्र है?',
    options: [
      'Google Digital Garage',
      'Microsoft Excel Pro',
      'Google IT Support',
      'Amazon Web Starter',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Google IT Support Certificate IT Support के लिए एक वैश्विक रूप से मान्यता प्राप्त प्रमाणपत्र (Certification) है।',
  ),
  QuizQuestion(
    id: 'cit593',
    question:
        'नौकरी के लिए आवेदन करते समय उद्योग प्रमाणपत्र क्यों महत्वपूर्ण हैं?',
    options: [
      'वे नौकरी की गारंटी देते हैं',
      'केवल आत्मविश्वास बढ़ाते हैं',
      'नियोक्ताओं के सामने आपकी कौशलों की पुष्टि करते हैं',
      'Linkedin पर नाम बदलने में मदद करते हैं',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'उद्योग प्रमाणपत्र (Industry Certifications) नियोक्ताओं (Employers) के सामने आपकी कौशलों की पुष्टि (Validate) करते हैं।',
  ),
  QuizQuestion(
    id: 'cit594',
    question:
        'इस पाठ्यक्रम में मुख्य रूप से किस प्रकार की कौशलें सिखाई गई थीं?',
    options: [
      'खाना बनाना और आतिथ्य',
      'खेल और मनोरंजन',
      'Digital, Career, AI और Automation Skills',
      'भाषा और साहित्य',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'इस पाठ्यक्रम (Course) में मुख्य रूप से Digital, Career, AI और Automation Skills सिखाई गईं।',
  ),
  QuizQuestion(
    id: 'cit595',
    question:
        'Microsoft Office Specialist जैसे प्रमाणपत्र का एक प्रमुख लाभ क्या है?',
    options: [
      'ये सभी के लिए निःशुल्क हैं',
      'वीडियो संपादन कौशल में सुधार करते हैं',
      'MS Office Tools में दक्षता प्रदर्शित करते हैं',
      'आपके कॉलेज डिग्री को बदल देते हैं',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'Microsoft Office Specialist (MOS) प्रमाणपत्र MS Office Tools में दक्षता (Proficiency) प्रदर्शित करते हैं।',
  ),
  QuizQuestion(
    id: 'cit596',
    question: 'आईटी प्रमाणन परीक्षाओं की तैयारी में क्या सहायक होता है?',
    options: [
      'फिल्में देखना',
      'केवल सोशल मीडिया समूह में शामिल होना',
      'किताबों का अध्ययन, ऑनलाइन कोर्सेज और प्रैक्टिस टेस्ट देना',
      'परीक्षा के दिन तक प्रतीक्षा करना',
    ],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'IT प्रमाणन परीक्षाओं (Certification Exams) की तैयारी के लिए किताबों का अध्ययन, ऑनलाइन कोर्स और प्रैक्टिस टेस्ट देना सहायक होता है।',
  ),
  QuizQuestion(
    id: 'cit597',
    question: 'पाठ्यक्रम पूरा करने के बाद अगला सुझाया गया कदम क्या है?',
    options: [
      'अपना Resume हटा देना',
      'उपयुक्त नौकरियों और Internships के लिए आवेदन करना',
      'Linkedin से पूरी तरह बचना',
      'कौशल विकास की उपेक्षा करना',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'पाठ्यक्रम पूरा करने के बाद अगला सुझाया गया कदम उपयुक्त नौकरियों और इंटर्नशिप (Internships) के लिए आवेदन करना है।',
  ),
  QuizQuestion(
    id: 'cit598',
    question: 'पेशेवर से जुड़ने के लिए कौन सा प्लेटफॉर्म अच्छा है?',
    options: ['Tiktok', 'Instagram', 'Linkedin', 'Pinterest'],
    correctIndex: 2,
    subject: 'BS-CIT',
    description:
        'पेशेवरों (Professionals) से जुड़ने के लिए LinkedIn सबसे अच्छा प्लेटफॉर्म है।',
  ),
  QuizQuestion(
    id: 'cit599',
    question: 'एक पाठ्यक्रम अंत परियोजना क्या दर्शाती है?',
    options: [
      'आप अच्छी Selfies कैसे लेते हैं',
      'सीखी गई कौशलों का व्यावहारिक अनुप्रयोग',
      'आपका पसंदीदा रंग',
      'उपस्थिति रिकॉर्ड',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'एक पाठ्यक्रम अंत परियोजना (Final Project) सीखी गई कौशलों के व्यावहारिक अनुप्रयोग (Practical Application) को दर्शाती है।',
  ),
  QuizQuestion(
    id: 'cit600',
    question:
        'निम्नलिखित में से कौन निरंतर सीखने के लिए अनुशंसित संसाधन नहीं है?',
    options: [
      'Youtube Tutorials',
      'Netflix',
      'Online Certification Courses',
      'Industry Blogs',
    ],
    correctIndex: 1,
    subject: 'BS-CIT',
    description:
        'Netflix मुख्य रूप से एक मनोरंजन (Entertainment) प्लेटफॉर्म है, यह निरंतर सीखने (Continuous Learning) के लिए अनुशंसित संसाधन नहीं है।',
  ),
];
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BS-CLS Questions
const List<QuizQuestion> _clsQuestions = [
  QuizQuestion(
    id: 'cls1',
    question: 'What is the correct way to introduce your name in English?',
    options: ['Myself is Ankit.', 'My name Ankit.', 'My name is Ankit.', 'I name is Ankit.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"My name is Ankit" is the standard and grammatically correct way to introduce yourself in English.',
  ),
  QuizQuestion(
    id: 'cls2',
    question: 'Which of the following is a formal greeting?',
    options: ['Hey!', 'What\'s up?', 'Hi!', 'Good morning.'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: '"Good morning" is a formal greeting, while "Hey", "What\'s up", and "Hi" are informal.',
  ),
  QuizQuestion(
    id: 'cls3',
    question: 'What does the pronoun "I" refer to?',
    options: ['A person you are talking to', 'A thing you see', 'Yourself', 'Someone else'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The pronoun "I" refers to yourself, the person speaking.',
  ),
  QuizQuestion(
    id: 'cls4',
    question: 'Choose the correct sentence:',
    options: ['I are a student.', 'I is a teacher.', 'I am a student.', 'I be a boy.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"I am a student" is correct because the pronoun "I" always takes the verb "am".',
  ),
  QuizQuestion(
    id: 'cls5',
    question: 'Which greeting would you use when meeting a teacher in the morning?',
    options: ['What\'s up, teacher?', 'Good morning, teacher.', 'Hey!', 'Yo, teacher!'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Good morning, teacher" is the most polite and respectful greeting for a teacher in the morning.',
  ),
  QuizQuestion(
    id: 'cls6',
    question: 'What is the polite way to say where you\'re from?',
    options: ['I from Delhi.', 'I am Delhi.', 'I is from Delhi.', 'I am from Delhi.'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: '"I am from Delhi" is the correct and polite way to state your origin.',
  ),
  QuizQuestion(
    id: 'cls7',
    question: 'Which of these is a correct self-introduction sentence?',
    options: ['I name is Raju.', 'My name is Raju.', 'Me name Raju.', 'Mine name is Raju.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"My name is Raju" is the correct possessive structure for introducing yourself.',
  ),
  QuizQuestion(
    id: 'cls8',
    question: 'What does "My" show in the sentence: "My book is new"?',
    options: ['Action', 'Possession', 'Greeting', 'Question'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"My" is a possessive adjective that shows ownership or possession of the book.',
  ),
  QuizQuestion(
    id: 'cls9',
    question: 'How do you use "You" in a sentence?',
    options: ['You am nice.', 'You is friend.', 'You are my friend.', 'You be a student.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The pronoun "You" always takes the verb "are", so "You are my friend" is correct.',
  ),
  QuizQuestion(
    id: 'cls10',
    question: 'Why do we repeat sentences when learning?',
    options: ['To get bored', 'To write more', 'To improve pronunciation and fluency', 'To avoid mistakes'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Repetition helps improve muscle memory for pronunciation and builds fluency through practice.',
  ),
  QuizQuestion(
    id: 'cls11',
    question: 'What is the correct way to introduce your father?',
    options: ['He is the my father.', 'That are my father.', 'This is my father.', 'My father this is.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"This is my father" is the standard way to introduce someone using "this" as a demonstrative pronoun.',
  ),
  QuizQuestion(
    id: 'cls12',
    question: 'Which word correctly completes the sentence: "This is Tina. _______ mother is a doctor."',
    options: ['His', 'Their', 'Her', 'She'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Her" is the correct possessive adjective to refer to Tina, who is female.',
  ),
  QuizQuestion(
    id: 'cls13',
    question: 'Which pronoun should be used to describe a group that includes you?',
    options: ['They', 'He', 'We', 'She'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"We" is the first-person plural pronoun that includes the speaker and others.',
  ),
  QuizQuestion(
    id: 'cls14',
    question: 'Choose the correct sentence using "they."',
    options: ['They is my parents.', 'They are my cousins.', 'They am my friends.', 'They be my neighbours.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"They" is a plural pronoun and requires the plural verb "are".',
  ),
  QuizQuestion(
    id: 'cls15',
    question: 'What is the correct possessive word in this sentence: "Ravi and Neha are siblings. _______ house is big."',
    options: ['Her', 'Their', 'His', 'Ours'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Their" is the possessive adjective for the plural subject "Ravi and Neha".',
  ),
  QuizQuestion(
    id: 'cls16',
    question: 'Which adjective best describes someone who makes you laugh?',
    options: ['Funny', 'Tall', 'Strong', 'Quiet'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: '"Funny" is the adjective used to describe someone who causes laughter.',
  ),
  QuizQuestion(
    id: 'cls17',
    question: 'Identify the sentence with the correct use of "her."',
    options: ['This is Seema. Her brother are kind.', 'This is Seema. Her name is Raci.', 'This is Seema. Her is my cousin.', 'This is Seema. Her are good.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Her name is Raci" correctly uses "her" as a possessive adjective before the noun "name".',
  ),
  QuizQuestion(
    id: 'cls18',
    question: 'Which sentence uses both a pronoun and an adjective correctly?',
    options: ['They is helpful.', 'We are tall and kind.', 'Her is funny.', 'His are strong.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"We are tall and kind" uses the pronoun "We" correctly with the verb "are" and the adjectives "tall" and "kind".',
  ),
  QuizQuestion(
    id: 'cls19',
    question: 'Which word fits best in the sentence: "My grandmother is _______ and kind."',
    options: ['tall', 'strict', 'old', 'lazy'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Old" is a typical and appropriate adjective to describe a grandmother alongside "kind".',
  ),
  QuizQuestion(
    id: 'cls20',
    question: 'Choose the correct sentence using "his."',
    options: ['This is Rohit. His sister is a teacher.', 'This is Rohit. He\'s sister is a teacher.', 'This is Rohit. Her sister is a teacher.', 'This is Rohit. Him sister is a teacher.'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: '"His sister" correctly uses the possessive adjective "his" for the male subject Rohit.',
  ),
  QuizQuestion(
    id: 'cls21',
    question: 'Choose the correct sentence.',
    options: ['He go to school.', 'He goes to school.', 'He going to school.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The third-person singular subject "He" requires the verb to end in "-s" (goes).',
  ),
  QuizQuestion(
    id: 'cls22',
    question: 'Which sentence is correct?',
    options: ['She play football.', 'She plays football.', 'She playing football.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The third-person singular subject "She" requires the verb to end in "-s" (plays).',
  ),
  QuizQuestion(
    id: 'cls23',
    question: 'Which verb form is correct with "They"?',
    options: ['They eats lunch.', 'They eat lunch.', 'They eating lunch.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The plural subject "They" takes the base form of the verb (eat).',
  ),
  QuizQuestion(
    id: 'cls24',
    question: 'What is the correct sentence?',
    options: ['I gets up at 6 a.m.', 'I get up at 6 a.m.', 'I getting up at 6 a.m.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The first-person singular subject "I" takes the base form of the verb (get).',
  ),
  QuizQuestion(
    id: 'cls25',
    question: 'Choose the correct sentence.',
    options: ['We goes to class.', 'We go to class.', 'We going to class.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The plural subject "We" takes the base form of the verb (go).',
  ),
  QuizQuestion(
    id: 'cls26',
    question: 'Which sentence is correct?',
    options: ['She study every day.', 'She studies every day.', 'She studying every day.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The third-person singular subject "She" requires the verb to end in "-s" (studies).',
  ),
  QuizQuestion(
    id: 'cls27',
    question: 'What is the correct form of the verb for "He"?',
    options: ['He walk to the market.', 'He walks to the market.', 'He walking to the market.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The third-person singular subject "He" requires the verb to end in "-s" (walks).',
  ),
  QuizQuestion(
    id: 'cls28',
    question: 'Which is correct?',
    options: ['They wakes up late.', 'They wake up late.', 'They waking up late.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The plural subject "They" takes the base form of the verb (wake).',
  ),
  QuizQuestion(
    id: 'cls29',
    question: 'Fill in the blank: She _______ tea in the morning.',
    options: ['drink', 'drinks', 'drinking', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The third-person singular subject "She" requires the verb to end in "-s" (drinks).',
  ),
  QuizQuestion(
    id: 'cls30',
    question: 'Choose the correct sentence.',
    options: ['He watches TV at night.', 'He watch TV at night.', 'He watching TV at night.', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'The third-person singular subject "He" requires the verb to end in "-es" (watches).',
  ),
  QuizQuestion(
    id: 'cls31',
    question: 'Which sentence is correct?',
    options: ['There is a kitchen in my house.', 'There kitchen is in my house.', 'Is kitchen there my house.', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: '"There is" is the correct existential construction to state the existence of a kitchen.',
  ),
  QuizQuestion(
    id: 'cls32',
    question: 'What is a place where you cook food?',
    options: ['Bedroom', 'Kitchen', 'Bathroom', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'A kitchen is the room specifically designed and used for cooking food.',
  ),
  QuizQuestion(
    id: 'cls33',
    question: 'What is used to sit on?',
    options: ['Table', 'Fan', 'Chair', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A chair is a piece of furniture designed for a single person to sit on.',
  ),
  QuizQuestion(
    id: 'cls34',
    question: 'Choose the correct sentence.',
    options: ['My house have four rooms.', 'My house has four rooms.', 'My house haves four rooms.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The third-person singular subject "My house" takes the verb "has".',
  ),
  QuizQuestion(
    id: 'cls35',
    question: 'What is "near" used for?',
    options: ['To show direction', 'To show closeness', 'To show number', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Near" is a preposition used to indicate that something is close in distance.',
  ),
  QuizQuestion(
    id: 'cls36',
    question: 'What do you use to sleep on?',
    options: ['Chair', 'Cupboard', 'Bed', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A bed is a piece of furniture specifically designed for sleeping.',
  ),
  QuizQuestion(
    id: 'cls37',
    question: 'Which sentence uses "There are" correctly?',
    options: ['There are one window in my room.', 'There are two windows in my room.', 'There are a table in my room.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"There are" is used with plural nouns like "two windows".',
  ),
  QuizQuestion(
    id: 'cls38',
    question: 'What is the correct sentence?',
    options: ['The bathroom is beside the bedroom.', 'Bathroom the is beside bedroom.', 'The is beside bathroom bedroom.', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'This sentence has the correct word order: subject + verb + prepositional phrase.',
  ),
  QuizQuestion(
    id: 'cls39',
    question: 'What do we use a cupboard for?',
    options: ['Sleeping', 'Eating', 'Storing clothes or items', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A cupboard (or closet) is used for storing clothes, linens, or other household items.',
  ),
  QuizQuestion(
    id: 'cls40',
    question: 'Where do we usually watch TV?',
    options: ['Kitchen', 'Living room', 'Bathroom', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The living room is the common area in a house where a television is typically placed for family viewing.',
  ),
  QuizQuestion(
    id: 'cls41',
    question: 'Which sentence correctly describes a classroom?',
    options: ['There are a blackboard in the room.', 'There is a blackboard in the room.', 'Is blackboard there in room.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"There is" is used with the singular noun "a blackboard".',
  ),
  QuizQuestion(
    id: 'cls42',
    question: 'What do students usually do in class?',
    options: ['Eat food', 'Watch movies', 'Read and write', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The primary activities in a classroom are reading and writing as part of learning.',
  ),
  QuizQuestion(
    id: 'cls43',
    question: 'Choose the correct action verb for this sentence: "We _______ to the teacher."',
    options: ['Say', 'Speak', 'Listen', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'In a classroom, students "listen" to the teacher.',
  ),
  QuizQuestion(
    id: 'cls44',
    question: 'Which question is polite and correct to ask in school?',
    options: ['Give me pen.', 'Can I borrow a pen?', 'I want pen.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Can I borrow a pen?" is a polite request using a modal verb.',
  ),
  QuizQuestion(
    id: 'cls45',
    question: 'What is the correct answer to "Where is the library?"',
    options: ['It is next to the staff room.', 'It is study place.', 'Library is book.', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'This answers the question by providing a specific location using a prepositional phrase.',
  ),
  QuizQuestion(
    id: 'cls46',
    question: 'What is the opposite of "open"?',
    options: ['Close', 'Closed', 'Shut', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Shut" is a direct antonym of "open" when used as a verb or adjective.',
  ),
  QuizQuestion(
    id: 'cls47',
    question: 'Complete the sentence: "The new bag is light. My old bag is _______."',
    options: ['Soft', 'Clean', 'Heavy', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Heavy" is the opposite of "light" in terms of weight.',
  ),
  QuizQuestion(
    id: 'cls48',
    question: 'Which sentence is correct?',
    options: ['May I to go outside?', 'Can I go outside?', 'Do I go outside?', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Can I go outside?" is a grammatically correct and common polite request.',
  ),
  QuizQuestion(
    id: 'cls49',
    question: 'What is the opposite of "big"?',
    options: ['Low', 'Small', 'Short', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Small" is the direct antonym of "big" when referring to size.',
  ),
  QuizQuestion(
    id: 'cls50',
    question: 'What do teachers and students do in the classroom?',
    options: ['Dance and sleep', 'Read, write, ask, and answer', 'Cook and clean', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The classroom is an environment for educational activities like reading, writing, asking, and answering questions.',
  ),
  QuizQuestion(
    id: 'cls51',
    question: 'What is the correct sentence to express a preference?',
    options: ['I liking mangoes.', 'I like mangoes.', 'I likes mangoes.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"I like mangoes" is the simple present tense form for expressing a general preference.',
  ),
  QuizQuestion(
    id: 'cls52',
    question: 'Which sentence shows a dislike?',
    options: ['I like milk.', 'I love milk.', 'I do not like milk.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"I do not like milk" is the negative form expressing dislike.',
  ),
  QuizQuestion(
    id: 'cls53',
    question: 'What is the correct sentence using "because"?',
    options: ['I like mangoes they are sweet.', 'I like mangoes because they are sweet.', 'Because I like mangoes they are sweet.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The conjunction "because" correctly joins the main clause and the reason clause.',
  ),
  QuizQuestion(
    id: 'cls54',
    question: 'Which hobby is an indoor activity?',
    options: ['Gardening', 'Reading', 'Cycling', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Reading is typically done indoors, while gardening and cycling are often outdoor activities.',
  ),
  QuizQuestion(
    id: 'cls55',
    question: 'Which word shows a stronger feeling than "like"?',
    options: ['Enjoy', 'Dislike', 'Love', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Love" expresses a much stronger positive feeling or affection than "like".',
  ),
  QuizQuestion(
    id: 'cls56',
    question: 'Choose the correct sentence using "enjoy."',
    options: ['I enjoy to play football.', 'I enjoy playing football.', 'I enjoys football.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The verb "enjoy" is correctly followed by a gerund (playing).',
  ),
  QuizQuestion(
    id: 'cls57',
    question: 'What is the opposite of "I like sweets"?',
    options: ['I do not like sweets.', 'I do no like sweets.', 'I dislike sweets not.', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'The correct negative form to express the opposite of liking is "I do not like sweets."',
  ),
  QuizQuestion(
    id: 'cls58',
    question: 'Which sentence gives a reason for a hobby?',
    options: ['I play football because it is fun.', 'I play football because fun.', 'I play football is fun.', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'This sentence correctly uses "because" to provide a reason (it is fun).',
  ),
  QuizQuestion(
    id: 'cls59',
    question: 'Choose the correct use of "love."',
    options: ['I loves chocolate.', 'I love chocolate.', 'I love chocolates is.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"I love chocolate" has the correct subject-verb agreement (I + love).',
  ),
  QuizQuestion(
    id: 'cls60',
    question: 'Which sentence would you repeat in a speaking practice?',
    options: ['I dislike because vegetables.', 'I like drawing.', 'I am hobby is music.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"I like drawing" is a simple, correct, and useful sentence for practicing basic sentence structure and expressing interests.',
  ),
  QuizQuestion(
    id: 'cls61',
    question: 'Which word is used to ask about a person?',
    options: ['What', 'Who', 'Where', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The WH-question word "Who" is specifically used to ask about a person.',
  ),
  QuizQuestion(
    id: 'cls62',
    question: 'Choose the correct question for the answer "I live in Patna."',
    options: ['Where do you live?', 'What do you live?', 'Who do you live?', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: '"Where" is the correct question word to ask about a place or location.',
  ),
  QuizQuestion(
    id: 'cls63',
    question: 'Which question asks about time?',
    options: ['Where are you?', 'When is the exam?', 'What is your name?', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The question word "When" is used to ask about time.',
  ),
  QuizQuestion(
    id: 'cls64',
    question: 'What is the correct helping verb in this question: "_______ she go to school?"',
    options: ['Do', 'Does', 'Did', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'For the third-person singular subject "she", the auxiliary verb "Does" is used to form a question in the simple present.',
  ),
  QuizQuestion(
    id: 'cls65',
    question: '"What do you eat for lunch at school?" is an example of a:',
    options: ['Yes/No question', 'Expanded WH-question', 'Command sentence', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'It is an expanded WH-question because it starts with "What" and asks for specific information about lunch.',
  ),
  QuizQuestion(
    id: 'cls66',
    question: 'Which question is best to ask about a place?',
    options: ['What is your teacher\'s name?', 'Where is your book?', 'Why do you like music?', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Where" is the question word specifically used to ask about a place or location.',
  ),
  QuizQuestion(
    id: 'cls67',
    question: 'Given: "He goes to school at 8 a.m." What is the correct question?',
    options: ['Why he goes to school?', 'When he go to school?', 'When does he go to school?', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'To ask about time, use "When". The correct structure requires the auxiliary verb "does" for the subject "he".',
  ),
  QuizQuestion(
    id: 'cls68',
    question: 'Choose the correct question to ask about reason:',
    options: ['Who do you like?', 'Why are you late?', 'Where are you from?', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Why" is the question word used to ask for a reason or explanation.',
  ),
  QuizQuestion(
    id: 'cls69',
    question: 'In conversation practice, which sentence is a correct response?',
    options: ['I am go at home.', 'I go to school by bus.', 'I school like bus.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This sentence has correct subject-verb-object order and answers a "how" or "by what means" question.',
  ),
  QuizQuestion(
    id: 'cls70',
    question: 'What is the purpose of WH-questions in real life?',
    options: ['To answer yes or no', 'To give orders', 'To ask for information', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'WH-questions (Who, What, Where, When, Why, How) are used to gather specific information.',
  ),
  QuizQuestion(
    id: 'cls71',
    question: 'Which connector is used to add similar ideas?',
    options: ['But', 'Because', 'And', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The conjunction "And" is used to add one similar or related idea to another.',
  ),
  QuizQuestion(
    id: 'cls72',
    question: 'Choose the correct sentence using "but".',
    options: ['I was tired, and I went to bed.', 'I was tired, but I finished my homework.', 'I was tired because I finished my homework.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"But" correctly shows a contrast between being tired and finishing homework.',
  ),
  QuizQuestion(
    id: 'cls73',
    question: 'What does the connector "because" show?',
    options: ['Result', 'Addition', 'Reason', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Because" is used to show the reason or cause for something.',
  ),
  QuizQuestion(
    id: 'cls74',
    question: 'Which connector shows contrast?',
    options: ['So', 'But', 'Since', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"But" is a conjunction used to introduce a phrase or clause contrasting with what has already been mentioned.',
  ),
  QuizQuestion(
    id: 'cls75',
    question: 'Choose the correct sentence using "so".',
    options: ['I was hungry, so I ate lunch.', 'I was hungry because I ate lunch.', 'I was hungry but I ate lunch.', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: '"So" correctly shows the result or effect of being hungry (eating lunch).',
  ),
  QuizQuestion(
    id: 'cls76',
    question: 'Fill in the blank: I stayed home _______ it was raining.',
    options: ['but', 'since', 'and', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Since" (or because) correctly gives the reason for staying home.',
  ),
  QuizQuestion(
    id: 'cls77',
    question: 'Join "I like oranges. I like apples." using a connector.',
    options: ['I like oranges but apples.', 'I like oranges because apples.', 'I like oranges and apples.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"And" is the correct conjunction to add two similar preferences together.',
  ),
  QuizQuestion(
    id: 'cls78',
    question: 'What is the effect of using "since" in a sentence?',
    options: ['It shows a result.', 'It gives a reason.', 'It adds two ideas.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Like "because", the conjunction "since" is used to provide a reason or cause.',
  ),
  QuizQuestion(
    id: 'cls79',
    question: 'Which connector completes this sentence correctly? "She was sick, _______ she didn\'t go to school."',
    options: ['because', 'but', 'so', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"So" correctly connects the cause (being sick) with the effect (not going to school).',
  ),
  QuizQuestion(
    id: 'cls80',
    question: 'Choose the sentence where the meaning changes with the connector.',
    options: ['I played and studied.', 'I played because I studied.', 'I played so I studied.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The meaning changes significantly based on the connector: "and" adds, "because" gives a reason, and "so" shows a result.',
  ),
  QuizQuestion(
    id: 'cls81',
    question: 'What type of sentence is "Sit down"?',
    options: ['Question', 'Imperative sentence', 'Exclamation', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Sit down" is an imperative sentence because it gives a direct command or instruction.',
  ),
  QuizQuestion(
    id: 'cls82',
    question: 'Which is the most polite way to ask someone to sit?',
    options: ['Sit!', 'Sit now.', 'Please sit down.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Adding "please" makes a command into a polite request.',
  ),
  QuizQuestion(
    id: 'cls83',
    question: 'What does the instruction "Don\'t run" mean?',
    options: ['You can walk slowly', 'You must run fast', 'You are not allowed to run', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Don\'t" is a contraction of "do not", which makes the command negative, prohibiting the action.',
  ),
  QuizQuestion(
    id: 'cls84',
    question: 'Which word begins a negative command?',
    options: ['Doesn\'t', 'Not', 'Can\'t', 'Don\'t'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'Negative commands (prohibitions) typically begin with "Don\'t" (e.g., Don\'t touch that).',
  ),
  QuizQuestion(
    id: 'cls85',
    question: 'Where are you likely to hear "Please keep silence"?',
    options: ['Playground', 'Hospital', 'Market', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Hospitals often require silence to ensure a peaceful environment for patients.',
  ),
  QuizQuestion(
    id: 'cls86',
    question: 'What does "Please form a queue" mean?',
    options: ['Shout loudly', 'Stand in a line', 'Run to the front', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'To "form a queue" means to stand in an orderly line, waiting for a turn.',
  ),
  QuizQuestion(
    id: 'cls87',
    question: 'Which instruction would you find in a classroom?',
    options: ['Wash your hands', 'Turn to page ten', 'Exit this way', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Turn to page ten" is a common instruction given by a teacher to students during a lesson.',
  ),
  QuizQuestion(
    id: 'cls88',
    question: 'What kind of word is "Open" in the sentence "Open your book"?',
    options: ['Noun', 'Verb', 'Adjective', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'In this imperative sentence, "Open" is an action verb.',
  ),
  QuizQuestion(
    id: 'cls89',
    question: 'Which of these is a public instruction?',
    options: ['Sit in your chair', 'Raise your hand', 'Do not enter', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Do not enter" is a sign or instruction meant for the general public in a shared space.',
  ),
  QuizQuestion(
    id: 'cls90',
    question: 'What should you do if a sign says, "Exit this way"?',
    options: ['Stand still', 'Enter the other door', 'Leave through the marked path', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The sign is directing you to leave the building by following the indicated path.',
  ),
  QuizQuestion(
    id: 'cls91',
    question: 'Which of the following is the most polite way to ask a teacher for help?',
    options: ['Help me with this.', 'Tell me now.', 'Could you please explain this question?', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Using "Could you please" is a formal and polite way to make a request to a teacher.',
  ),
  QuizQuestion(
    id: 'cls92',
    question: 'What makes a polite request sound more respectful?',
    options: ['Using a louder voice', 'Adding "please" and a kind tone', 'Asking without explanation', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The word "please" and a kind, respectful tone are key elements of politeness in a request.',
  ),
  QuizQuestion(
    id: 'cls93',
    question: 'Which expression is formal and polite?',
    options: ['May I borrow your pen, sir?', 'Can I take your pen?', 'Give me your pen.', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: '"May I" is more formal than "Can I", and adding "sir" shows respect, making this the most formal option.',
  ),
  QuizQuestion(
    id: 'cls94',
    question: 'What is the polite response if you can\'t help someone?',
    options: ['Go ask someone else.', 'No.', 'I\'m really sorry, I can\'t help right now.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This response is polite because it offers an apology ("I\'m sorry") and states the inability to help without being rude.',
  ),
  QuizQuestion(
    id: 'cls95',
    question: 'What should you say when someone gives you something?',
    options: ['Please', 'Sorry', 'Thank you', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Thank you" is the standard polite expression of gratitude when receiving something.',
  ),
  QuizQuestion(
    id: 'cls96',
    question: 'In which situation would you use "Excuse me"?',
    options: ['When refusing to help', 'When walking away from someone', 'When interrupting or trying to speak politely', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Excuse me" is used to politely get someone\'s attention or to apologize for an interruption.',
  ),
  QuizQuestion(
    id: 'cls97',
    question: 'Which of these is an appropriate informal polite request?',
    options: ['May I speak to the principal?', 'Can you help me with this drawing?', 'Would you mind giving me your ID card?', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Can you help me" is suitable for informal situations, like asking a friend for assistance with a drawing.',
  ),
  QuizQuestion(
    id: 'cls98',
    question: 'Which is a rude way to respond to "Can I borrow your pen?"',
    options: ['Sure, here you go.', 'No, I\'m using it right now.', 'Get your own.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Get your own" is a dismissive and rude response that does not offer any polite explanation.',
  ),
  QuizQuestion(
    id: 'cls99',
    question: 'What is the correct polite version of the sentence: "Move now"?',
    options: ['Get out of the way.', 'Move already!', 'Could you move a little, please?', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This turns a rude command into a polite request using "Could you" and "please".',
  ),
  QuizQuestion(
    id: 'cls100',
    question: 'Which polite expression shows that you\'re happy to help someone?',
    options: ['I can\'t help right now.', 'Sure, I\'d be happy to!', 'You should ask someone else.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This response directly and enthusiastically expresses willingness and happiness to assist.',
  ),
  QuizQuestion(
    id: 'cls101',
    question: 'Which word best completes the sentence: "My school is _______ and clean."',
    options: ['tall', 'short', 'big', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Big" is an adjective that appropriately describes the size of a school along with "clean".',
  ),
  QuizQuestion(
    id: 'cls102',
    question: 'Choose the correct comparative form: "This chair is _______ than that one."',
    options: ['soft', 'softest', 'softer', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The comparative form "softer" is used when comparing two things (this chair vs. that one).',
  ),
  QuizQuestion(
    id: 'cls103',
    question: 'Which adjective is used to describe how something feels?',
    options: ['colourful', 'shiny', 'rough', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Rough" describes a texture, which is related to the sense of touch (how something feels).',
  ),
  QuizQuestion(
    id: 'cls104',
    question: '"This is the _______ building in our neighbourhood." Choose the correct superlative.',
    options: ['tall', 'taller', 'most tall', 'tallest'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'The superlative form "tallest" is used to compare one thing against all others in a group.',
  ),
  QuizQuestion(
    id: 'cls105',
    question: 'What does the sentence "The flower smells fresh" describe?',
    options: ['Taste', 'Touch', 'Sight', 'Smell'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'The verb "smells" refers to the sense of smell.',
  ),
  QuizQuestion(
    id: 'cls106',
    question: 'Which sentence uses a superlative adjective correctly?',
    options: ['This road is more longer.', 'She is the tallest girl in class.', 'He is taller than the tallest.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Tallest" is the correct superlative form, and it is used correctly to compare her to all other girls in the class.',
  ),
  QuizQuestion(
    id: 'cls107',
    question: 'Choose the adjective that describes sound.',
    options: ['Bitter', 'Loud', 'Smooth', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Loud" describes the volume or intensity of a sound.',
  ),
  QuizQuestion(
    id: 'cls108',
    question: '"That painting is more beautiful than the others." Which kind of adjective is used?',
    options: ['Positive', 'Superlative', 'Descriptive', 'Comparative'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'The phrase "more beautiful... than" indicates a comparison between two or more things, which is the comparative form.',
  ),
  QuizQuestion(
    id: 'cls109',
    question: 'Which of these is a correct pair of sense and adjective?',
    options: ['Taste - soft', 'Touch - shiny', 'Smell - spicy', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Spicy foods are detected by the sense of smell (and taste).',
  ),
  QuizQuestion(
    id: 'cls110',
    question: 'Which word would you use to describe fruit\'s taste?',
    options: ['Bitter', 'Noisy', 'Crowded', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: '"Bitter" is a taste adjective, appropriate for describing the flavor of some fruits (like grapefruit or unripe fruit).',
  ),
  QuizQuestion(
    id: 'cls111',
    question: 'What does the phrase "next to" mean?',
    options: ['On top of', 'Far from', 'Beside', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Next to" and "beside" are synonyms that mean something is at the side of something else, in close proximity.',
  ),
  QuizQuestion(
    id: 'cls112',
    question: 'Which sentence uses the word "behind" correctly?',
    options: ['The school is behind the park.', 'The bank is behind the money.', 'Behind is the road.', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'This sentence correctly uses "behind" as a preposition to indicate the school is at the back of the park.',
  ),
  QuizQuestion(
    id: 'cls113',
    question: 'How would you politely ask someone for directions?',
    options: ['"Tell me where it is."', '"Where is that thing?"', '"Excuse me, can you help me find the bank?"', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is polite because it uses "Excuse me" and "Can you help me" to make a request.',
  ),
  QuizQuestion(
    id: 'cls114',
    question: 'Which of these is a correct direction phrase?',
    options: ['Cross under the house', 'Walk pass the road', 'Go straight and take the second left', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is a standard and clear set of directions using common phrases like "go straight" and "take the second left".',
  ),
  QuizQuestion(
    id: 'cls115',
    question: 'If a place is "across from" your school, where is it?',
    options: ['Next door to it', 'On the same side', 'Opposite the school', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Across from" means on the opposite side of a street or area.',
  ),
  QuizQuestion(
    id: 'cls116',
    question: 'What is the polite way to begin asking for directions?',
    options: ['Hey!', 'You know where is...?', 'Excuse me', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Excuse me" is the standard polite phrase to get someone\'s attention before asking for help.',
  ),
  QuizQuestion(
    id: 'cls117',
    question: 'Which location word means "in the middle of two things"?',
    options: ['Behind', 'Between', 'Beside', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Between" is used when something is positioned in the middle of two separate objects or points.',
  ),
  QuizQuestion(
    id: 'cls118',
    question: 'What should you avoid when giving directions?',
    options: ['Using clear steps', 'Mentioning landmarks', 'Using short phrases', 'Giving too many steps at once'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'Overwhelming someone with too many steps at once can be confusing. It\'s better to give them in a simple, clear order.',
  ),
  QuizQuestion(
    id: 'cls119',
    question: 'What is the best response to: "Excuse me, where is the train station?"',
    options: ['Just go.', 'Why are you asking?', 'Go straight, then turn right. It\'s beside the post office.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is the most helpful response because it provides clear, step-by-step directions and a landmark.',
  ),
  QuizQuestion(
    id: 'cls120',
    question: 'Which word correctly completes the sentence: "The shop is _______ the corner of the street"?',
    options: ['behind', 'at', 'to', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The preposition "at" is used to indicate a specific point or intersection, like a corner.',
  ),
  QuizQuestion(
    id: 'cls121',
    question: 'Which of the following is a fruit?',
    options: ['Carrot', 'Mango', 'Bread', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'A mango is a sweet, tropical fruit.',
  ),
  QuizQuestion(
    id: 'cls122',
    question: 'What is usually eaten in the morning?',
    options: ['Dinner', 'Snack', 'Breakfast', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Breakfast is the first meal of the day, typically eaten in the morning.',
  ),
  QuizQuestion(
    id: 'cls123',
    question: 'Which sentence is in passive voice?',
    options: ['She eats an apple.', 'They cook rice.', 'An apple is eaten by her.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'In passive voice, the subject (An apple) receives the action (is eaten).',
  ),
  QuizQuestion(
    id: 'cls124',
    question: 'What taste does lemon have?',
    options: ['Sweet', 'Bitter', 'Salty', 'Sour'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'Lemons are well-known for their sharp, sour taste.',
  ),
  QuizQuestion(
    id: 'cls125',
    question: '"The chef prepares the food." Convert this to passive voice.',
    options: ['The food prepares the chef.', 'The chef is prepared by the food.', 'The food is prepared by the chef.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The object of the active sentence (the food) becomes the subject, and the verb changes to "is prepared".',
  ),
  QuizQuestion(
    id: 'cls126',
    question: 'Which of these is a dairy product?',
    options: ['Fish', 'Juice', 'Cheese', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Cheese is a dairy product, made from milk.',
  ),
  QuizQuestion(
    id: 'cls127',
    question: 'Which of these meals is usually eaten at night?',
    options: ['Breakfast', 'Dinner', 'Snack', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Dinner is the main meal of the day, often eaten in the evening or at night.',
  ),
  QuizQuestion(
    id: 'cls128',
    question: 'What is the correct taste word for "chips"?',
    options: ['Sweet', 'Spicy', 'Salty', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Chips (crisps) are typically known for being salty.',
  ),
  QuizQuestion(
    id: 'cls129',
    question: 'Choose the passive form of "They eat bread."',
    options: ['Bread is eaten by them.', 'They are eaten by bread.', 'Eating bread is by them.', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'The object (Bread) becomes the subject, and the verb changes to the correct passive form "is eaten".',
  ),
  QuizQuestion(
    id: 'cls130',
    question: 'What is the correct category for "rice"?',
    options: ['Meat', 'Grain', 'Dairy', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Rice is a cereal grain, a staple food for a large part of the world\'s population.',
  ),
  QuizQuestion(
    id: 'cls131',
    question: 'What does the word "receipt" mean?',
    options: ['A type of shopping bag', 'A written record of a purchase', 'A discount coupon', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'A receipt is a document provided by a seller to a buyer that lists the items purchased and the amount paid.',
  ),
  QuizQuestion(
    id: 'cls132',
    question: 'Which of the following is a polite way to ask for a price?',
    options: ['"Give me the cost."', '"Tell price."', '"How much does this cost?"', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is a complete and polite sentence using the standard question format for asking price.',
  ),
  QuizQuestion(
    id: 'cls133',
    question: 'Which payment method is NOT digital?',
    options: ['UPI', 'Card', 'Wallet app', 'Cash'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'Cash is physical money (notes and coins), whereas UPI, cards, and wallet apps are electronic/digital forms of payment.',
  ),
  QuizQuestion(
    id: 'cls134',
    question: 'What does "many" go with?',
    options: ['Rice', 'Sugar', 'Apples', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Many" is used with plural, countable nouns like "apples".',
  ),
  QuizQuestion(
    id: 'cls135',
    question: 'Which of these is uncountable?',
    options: ['Pens', 'Bottles', 'Salt', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Salt is an uncountable noun. You cannot say "one salt" or "two salts" in standard English.',
  ),
  QuizQuestion(
    id: 'cls136',
    question: 'What would you say to a shopkeeper to ask for a shirt politely?',
    options: ['"Give me shirt."', '"I want that."', '"I\'d like to buy this shirt, please."', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is the most polite option, using "I\'d like" and "please" to make a request.',
  ),
  QuizQuestion(
    id: 'cls137',
    question: 'What does the word "discount" mean?',
    options: ['A fee added to the bill', 'A higher price', 'A reduced price', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A discount is a reduction in the original price of an item.',
  ),
  QuizQuestion(
    id: 'cls138',
    question: 'Which of the following is a correct sentence?',
    options: ['"I want much apples."', '"Give me some sugar."', '"I\'d like many water"', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This sentence is correct. "Some" is used with the uncountable noun "sugar".',
  ),
  QuizQuestion(
    id: 'cls139',
    question: 'Which question is correct to ask in a shop?',
    options: ['"How much are these shoes?"', '"These shoes how much?"', '"Much this shoes cost?"', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'This has the correct word order for a question: Question word (How much) + verb (are) + subject (these shoes).',
  ),
  QuizQuestion(
    id: 'cls140',
    question: 'If the total bill is 520 and you give 600, how much is the balance?',
    options: ['100', '-20', '80', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The balance (change) is calculated by subtracting the bill from the amount given: 600 - 520 = 80.',
  ),
  QuizQuestion(
    id: 'cls141',
    question: 'Which of the following is a health-related word?',
    options: ['Basket', 'Fever', 'Wallet', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Fever is a common medical symptom indicating an elevated body temperature due to illness.',
  ),
  QuizQuestion(
    id: 'cls142',
    question: 'What would you say if you had a headache yesterday?',
    options: ['I have a headache.', 'I am headache.', 'I had a headache.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The past tense "I had" is used to describe an event that happened yesterday.',
  ),
  QuizQuestion(
    id: 'cls143',
    question: 'Which of these is a preventive health habit?',
    options: ['Skipping breakfast', 'Eating junk food', 'Washing hands before meals', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Washing hands before meals is a key hygiene practice that helps prevent the spread of germs and illness.',
  ),
  QuizQuestion(
    id: 'cls144',
    question: 'What does the sentence "She is feeling weak" describe?',
    options: ['An activity', 'A payment', 'A health condition', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Feeling weak is a symptom or condition related to one\'s physical health.',
  ),
  QuizQuestion(
    id: 'cls145',
    question: 'Choose the correct sentence in indirect speech:',
    options: ['He said to drink water.', 'He said drink water.', 'He said that he drinks water.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This correctly uses the reporting verb "said" and the conjunction "that" to introduce the reported clause.',
  ),
  QuizQuestion(
    id: 'cls146',
    question: 'What is the correct Indirect form of: Doctor: "Take rest"?',
    options: ['Doctor said me take rest.', 'The doctor told to take rest.', 'The doctor told me to take rest.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'When reporting a command, we use "told + person + to + infinitive".',
  ),
  QuizQuestion(
    id: 'cls147',
    question: 'Which sentence uses a reporting verb correctly?',
    options: ['He talk me to eat fruits.', 'She said me to go home.', 'They told me to drink warm water.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Told" is correctly followed by an object (me) and then the infinitive phrase (to drink...).',
  ),
  QuizQuestion(
    id: 'cls148',
    question: 'Which of the following shows good health practice?',
    options: ['I skip breakfast.', 'I eat chips every day.', 'I brush my teeth twice a day.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Brushing teeth twice a day is a standard recommendation for good dental hygiene.',
  ),
  QuizQuestion(
    id: 'cls149',
    question: 'What tense is used in this sentence: "I had a cold last week"?',
    options: ['Present continuous', 'Past simple', 'Future perfect', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The verb "had" is the past simple form of "have", and the time marker "last week" indicates past tense.',
  ),
  QuizQuestion(
    id: 'cls150',
    question: 'Which sentence describes a symptom?',
    options: ['I bought vegetables.', 'I went to the market.', 'I have a sore throat.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A sore throat is a physical symptom of illness.',
  ),
  QuizQuestion(
    id: 'cls151',
    question: 'What does "sunny" weather mean?',
    options: ['It is snowing.', 'The sun is shining.', 'It is raining heavily.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Sunny weather is characterized by the sun being clearly visible and shining brightly.',
  ),
  QuizQuestion(
    id: 'cls152',
    question: 'Which of the following is an advanced weather word?',
    options: ['Hot', 'Rainy', 'Drizzling', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Drizzling" is more specific and advanced than "rainy" or "hot", describing light, fine rain.',
  ),
  QuizQuestion(
    id: 'cls153',
    question: 'Choose the correct sentence:',
    options: ['It raining outside.', 'Is rain today.', 'It is raining outside.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence has the correct present continuous structure: subject (It) + verb (is) + verb-ing (raining).',
  ),
  QuizQuestion(
    id: 'cls154',
    question: 'Which word means "slightly cold"?',
    options: ['Chilly', 'Humid', 'Hot', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: '"Chilly" describes weather that is uncomfortably cool, but not extremely cold.',
  ),
  QuizQuestion(
    id: 'cls155',
    question: 'What does "foggy" weather reduce?',
    options: ['Sound', 'Smell', 'Vision', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Fog is a thick cloud of tiny water droplets near the ground that severely limits visibility.',
  ),
  QuizQuestion(
    id: 'cls156',
    question: 'What does a "heatwave" mean?',
    options: ['Many days of heavy rain', 'Sudden cold in winter', 'A long period of very hot weather', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A heatwave is a prolonged period of excessively hot weather, often accompanied by high humidity.',
  ),
  QuizQuestion(
    id: 'cls157',
    question: 'Choose the correct sentence to describe today\'s weather',
    options: ['There foggy morning is.', 'It was fog.', 'It is foggy this morning.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence has the correct structure: subject (It) + verb (is) + adjective (foggy) + time (this morning).',
  ),
  QuizQuestion(
    id: 'cls158',
    question: 'What does the term "low pressure" usually mean in a weather report?',
    options: ['Clear skies', 'Thunderstorm or rain', 'Cold wind', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'In meteorology, a low-pressure system is typically associated with clouds, precipitation, and storms.',
  ),
  QuizQuestion(
    id: 'cls159',
    question: 'What would you likely see during a thunderstorm?',
    options: ['Bright sunshine', 'Lightning and heavy rain', 'Snowfall', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Thunderstorms are characterized by lightning, thunder, and often heavy rain.',
  ),
  QuizQuestion(
    id: 'cls160',
    question: 'Which of these cities might experience a heatwave in summer?',
    options: ['Shimla', 'Delhi', 'Manali', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Delhi, being in the northern plains of India, experiences extremely high temperatures and heatwaves in the summer.',
  ),
  QuizQuestion(
    id: 'cls161',
    question: 'Which sentence is in the simple present tense?',
    options: ['I will go to school.', 'I went to school.', 'I go to school.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"I go to school" describes a habitual action or a general truth, which is the function of the simple present tense.',
  ),
  QuizQuestion(
    id: 'cls162',
    question: 'Which subject needs an -s added to the verb in the present tense?',
    options: ['I', 'You', 'They', 'He'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'For most verbs, the third-person singular subjects (He, She, It) require an -s or -es ending.',
  ),
  QuizQuestion(
    id: 'cls163',
    question: 'Choose the correct sentence in present tense:',
    options: ['She read books every day.', 'She reads books every day.', 'She reading books every day.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The third-person singular subject "She" requires the verb to end in "-s" (reads).',
  ),
  QuizQuestion(
    id: 'cls164',
    question: 'Which verb form is correct for "He" in the present tense?',
    options: ['play', 'playing', 'plays', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The third-person singular subject "He" requires the verb to end in "-s" (plays).',
  ),
  QuizQuestion(
    id: 'cls165',
    question: 'What is the correct sentence to describe a fact?',
    options: ['The sun rising in the east.', 'The sun rose in the east.', 'The sun rises in the east.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'General truths and scientific facts are expressed using the simple present tense (rises).',
  ),
  QuizQuestion(
    id: 'cls166',
    question: 'Identify the sentence that describes a daily routine:',
    options: ['She brushed her teeth.', 'She brushes her teeth every morning.', 'She will brush her teeth.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The simple present tense ("brushes") combined with "every morning" describes a daily routine.',
  ),
  QuizQuestion(
    id: 'cls167',
    question: 'Which of the following is NOT used in simple present tense?',
    options: ['Goes', 'Eats', 'Played', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Played" is the past tense form of the verb "play".',
  ),
  QuizQuestion(
    id: 'cls168',
    question: 'Choose the sentence that shows a third-person habit.',
    options: ['I go for a walk.', 'They play football.', 'He goes for a walk.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"He" is a third-person singular pronoun, and the verb "goes" correctly shows the habit.',
  ),
  QuizQuestion(
    id: 'cls169',
    question: 'Which is a correct general fact?',
    options: ['Water boiling at 100°C.', 'Water boils at 100°C.', 'Water is boiling at 100°C.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'A general fact like the boiling point of water is stated in the simple present tense: "Water boils..."',
  ),
  QuizQuestion(
    id: 'cls170',
    question: 'What is the simple present form of the verb in this sentence: "He ______ to school every day"?',
    options: ['go', 'goes', 'going', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The third-person singular subject "He" requires the verb to end in "-es" (goes).',
  ),
  QuizQuestion(
    id: 'cls171',
    question: 'Which sentence is in the simple past tense?',
    options: ['I am going to school.', 'I go to school.', 'I went to school.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Went" is the past tense form of the verb "to go", indicating a completed action in the past.',
  ),
  QuizQuestion(
    id: 'cls172',
    question: 'What is the past tense of "eat"?',
    options: ['eaten', 'eat', 'eats', 'ate'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: '"Ate" is the irregular past tense form of the verb "eat".',
  ),
  QuizQuestion(
    id: 'cls173',
    question: 'Choose the correct past tense sentence:',
    options: ['She play football yesterday.', 'She played football yesterday.', 'She is playing football yesterday.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This sentence correctly uses the past tense verb "played" with the past time marker "yesterday".',
  ),
  QuizQuestion(
    id: 'cls174',
    question: 'Which of the following is a regular verb in past tense?',
    options: ['went', 'took', 'studied', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Studied" is a regular verb because it forms its past tense by adding "-ied" (a variant of -ed). "Went" and "took" are irregular.',
  ),
  QuizQuestion(
    id: 'cls175',
    question: 'What is the past tense of "go"?',
    options: ['goes', 'going', 'gone', 'went'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: '"Went" is the irregular past tense form of the verb "go".',
  ),
  QuizQuestion(
    id: 'cls176',
    question: 'Complete the sentence: "He ______ to the market."',
    options: ['goes', 'went', 'go', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Without a time marker, the simple past "went" is a common choice, but context is key. Given the options, "went" is the simple past.',
  ),
  QuizQuestion(
    id: 'cls177',
    question: 'Which sentence uses the time marker "last week"?',
    options: ['She goes to school.', 'She will go to school.', 'She went to school last week.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Last week" is a time marker that indicates the past tense, and "went" is correctly used.',
  ),
  QuizQuestion(
    id: 'cls178',
    question: 'What is the past tense of "write"?',
    options: ['wrote', 'writing', 'writes', ''],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: '"Wrote" is the irregular past tense form of the verb "write".',
  ),
  QuizQuestion(
    id: 'cls179',
    question: 'Which sentence is grammatically correct?',
    options: ['We watch a movie yesterday.', 'We watched a movie yesterday.', 'We watches a movie yesterday.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This sentence correctly uses the past tense verb "watched" with the past time marker "yesterday".',
  ),
  QuizQuestion(
    id: 'cls180',
    question: 'Complete the sentence: "They ______ a cake for her birthday."',
    options: ['bake', 'baking', 'baked', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The context of "for her birthday" (an event that is likely over) implies the past tense, so "baked" is correct.',
  ),
  QuizQuestion(
    id: 'cls181',
    question: 'Which sentence correctly uses the simple future tense?',
    options: ['I went to the market.', 'I will go to the market.', 'I am go to the market.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The simple future tense is formed with "will + base form of the verb".',
  ),
  QuizQuestion(
    id: 'cls182',
    question: 'What is the correct form of the verb in this sentence: "She _______ buy a new phone"?',
    options: ['is going to', 'will', 'is go to', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Will" is the auxiliary verb used to form the simple future tense. "Will buy" is correct.',
  ),
  QuizQuestion(
    id: 'cls183',
    question: 'Choose the sentence that shows a future plan:',
    options: ['I eat lunch at 1 p.m.', 'I will ate lunch soon.', 'I am going to eat lunch at 1 p.m.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Going to" is often used to express a planned future action.',
  ),
  QuizQuestion(
    id: 'cls184',
    question: 'Which expression is used for a prediction?',
    options: ['going to', 'has been', 'will', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Will" is commonly used to make predictions about the future (e.g., "It will rain tomorrow").',
  ),
  QuizQuestion(
    id: 'cls185',
    question: 'Identify the correct sentence using "going to":',
    options: ['She is going to plays football.', 'She going to play football.', 'She is going to play football.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The correct structure is: subject + am/is/are + going to + base form of the verb.',
  ),
  QuizQuestion(
    id: 'cls186',
    question: 'What does "will" indicate in the sentence: "He will call you later"?',
    options: ['A past habit', 'A command', 'A future decision', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'In this context, "will" indicates a spontaneous decision or a promise to perform a future action.',
  ),
  QuizQuestion(
    id: 'cls187',
    question: 'Change the sentence into future tense: "They walk to school."',
    options: ['They will walked to school.', 'They will walk to school.', 'They will walking to school.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The simple future is formed by adding "will" before the base form of the verb, "walk".',
  ),
  QuizQuestion(
    id: 'cls188',
    question: 'Which of the following describes a future prediction?',
    options: ['He is watching TV now.', 'He watched TV yesterday.', 'He will watch TV tomorrow.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence uses "will" to make a prediction about an action that will happen tomorrow.',
  ),
  QuizQuestion(
    id: 'cls189',
    question: 'Select the sentence showing a plan already made:',
    options: ['I will visit the doctor.', 'I am going to visit the doctor.', 'I was visiting the doctor.', ''],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Be going to" is specifically used to talk about plans and intentions that have already been decided.',
  ),
  QuizQuestion(
    id: 'cls190',
    question: 'Which sentence is incorrect?',
    options: ['We are going to the zoo.', 'We are going to visit the zoo.', 'We going to visit the zoo.', ''],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence is missing the necessary auxiliary verb "are". The correct form is "We are going to visit...".',
  ),
  QuizQuestion(
    id: 'cls191',
    question: 'Which sentence is in the present continuous tense?',
    options: ['I read a book.', 'I was reading a book.', 'I will read a book.', 'I am reading a book.'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'The present continuous tense is formed with am/is/are + present participle (verb-ing).',
  ),
  QuizQuestion(
    id: 'cls192',
    question: 'What is the structure of the past continuous tense?',
    options: ['am/is/are + verb-ing', 'was/were + verb-ing', 'will + verb', 'had + verb'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The past continuous tense is formed with the past tense of "to be" (was/were) + the present participle of the main verb.',
  ),
  QuizQuestion(
    id: 'cls193',
    question: 'Choose the correct sentence in future continuous tense:',
    options: ['I am going to the market.', 'I was going to the market.', 'I will be going to the market.', 'I go to the market.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The future continuous tense is formed with will + be + present participle (verb-ing).',
  ),
  QuizQuestion(
    id: 'cls194',
    question: 'Which action shows something happening now?',
    options: ['She will be sleeping.', 'She is sleeping.', 'She was sleeping.', 'She sleeps.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The present continuous tense ("is sleeping") is used to describe an action that is happening at the moment of speaking.',
  ),
  QuizQuestion(
    id: 'cls195',
    question: 'Fill in the blank: "They ______ watching TV when I arrived."',
    options: ['is', 'are', 'were', 'be'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The sentence describes an action in progress in the past when another action happened, so the past continuous is needed. The correct auxiliary is "were" for the subject "They".',
  ),
  QuizQuestion(
    id: 'cls196',
    question: 'Identify the incorrect sentence:',
    options: ['I am cooking dinner now.', 'She was reading when the lights went out.', 'He will be swim tomorrow.', 'They are playing outside.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence is incorrect because the future continuous requires "be + verb-ing". The correct form is "He will be swimming tomorrow."',
  ),
  QuizQuestion(
    id: 'cls197',
    question: 'What is the time reference used with future continuous tense?',
    options: ['Yesterday', 'Now', 'Tomorrow at 5 PM', 'Last night'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The future continuous tense refers to an action that will be in progress at a specific time in the future.',
  ),
  QuizQuestion(
    id: 'cls198',
    question: '"He will be working late tonight." Which tense is this?',
    options: ['Present continuous', 'Past continuous', 'Simple future', 'Future continuous'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'The structure "will be working" is the future continuous tense.',
  ),
  QuizQuestion(
    id: 'cls199',
    question: 'Which of the following best describes an interrupted action in the past?',
    options: ['I was studying when the power went out.', 'I study hard for exams.', 'I am studying now.', 'I will be studying at 8.'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'The past continuous (was studying) describes an ongoing action that was interrupted by another action in the past simple (went out).',
  ),
  QuizQuestion(
    id: 'cls200',
    question: 'Choose the correct comparison:',
    options: ['I study vs. I studied', 'I will read vs. I read', 'I am reading vs. I will be reading', 'I read vs. I have read'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This option correctly contrasts the present continuous (action happening now) with the future continuous (action in progress at a future time).',
  ),
  QuizQuestion(
    id: 'cls201',
    question: 'Which sentence is in the present perfect tense?',
    options: ['I will go to the market.', 'I have gone to the market.', 'I went to the market.', 'I am going to the market.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The present perfect tense is formed with "have/has + past participle".',
  ),
  QuizQuestion(
    id: 'cls202',
    question: 'What is the correct form for past perfect tense?',
    options: ['have + past participle', 'has + past participle', 'had + past participle', 'will have + past participle'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The past perfect tense is formed with "had + past participle".',
  ),
  QuizQuestion(
    id: 'cls203',
    question: 'Which of the following is an example of future perfect tense?',
    options: ['She eats lunch.', 'She ate lunch.', 'She is eating lunch.', 'She will have eaten lunch.'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'The future perfect tense is formed with "will have + past participle".',
  ),
  QuizQuestion(
    id: 'cls204',
    question: 'Which word commonly goes with present perfect tense?',
    options: ['yesterday', 'now', 'ever', 'tomorrow'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Words like "ever," "never," "already," "yet," and "just" are commonly used with the present perfect tense.',
  ),
  QuizQuestion(
    id: 'cls205',
    question: 'Choose the correct sentence in past perfect tense:',
    options: ['He has finished his work.', 'He had finished his work before dinner.', 'He finishes his work every day.', 'He will have finished his work.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This sentence correctly uses "had finished" (past perfect) to show an action completed before another past action (dinner).',
  ),
  QuizQuestion(
    id: 'cls206',
    question: 'Which sentence uses future perfect correctly?',
    options: ['I had arrived by noon.', 'I have arrived by noon.', 'I will have arrived by noon.', 'I am arriving by noon.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The future perfect tense ("will have arrived") is used to say that an action will be completed by a certain time in the future.',
  ),
  QuizQuestion(
    id: 'cls207',
    question: 'Fill in the blank: "They ______ already left when we arrived."',
    options: ['have', 'had', 'will have', 'are'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The action of leaving was completed before the action of arriving in the past, so the past perfect ("had left") is correct.',
  ),
  QuizQuestion(
    id: 'cls208',
    question: '"I have never seen a tiger." Which tense is this?',
    options: ['Present perfect', 'Past perfect', 'Future perfect', 'Simple past'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'The structure "have + past participle" (have seen) is the present perfect tense.',
  ),
  QuizQuestion(
    id: 'cls209',
    question: 'Which auxiliary verb is used in future perfect tense?',
    options: ['was', 'had', 'will have', 'has'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The future perfect tense is formed with "will have" followed by the past participle.',
  ),
  QuizQuestion(
    id: 'cls210',
    question: 'What does this sentence mean: "She has just eaten lunch."',
    options: ['She ate lunch long ago.', 'She is eating lunch now.', 'She will eat lunch later.', 'She recently finished eating.'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'The word "just" in the present perfect tense indicates that the action was completed a very short time ago.',
  ),
  QuizQuestion(
    id: 'cls211',
    question: 'Which sentence is in the present perfect tense?',
    options: ['I have breakfast at 8 AM.', 'I had breakfast at 8 AM.', 'I have had breakfast already.', 'I will have breakfast soon.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence correctly uses the present perfect structure "have + had" (past participle of "have").',
  ),
  QuizQuestion(
    id: 'cls212',
    question: 'Choose the correct past continuous sentence:',
    options: ['He was walk to the park.', 'He is walking to the park.', 'He walked to the park.', 'He was walking to the park.'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'The past continuous tense is formed with "was/were + verb-ing".',
  ),
  QuizQuestion(
    id: 'cls213',
    question: 'What is the correct future perfect form of "She completes the project"?',
    options: ['She has completed the project.', 'She had completed the project.', 'She will complete the project.', 'She will have completed the project.'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'The future perfect tense is "will have + past participle". The past participle of "completes" is "completed".',
  ),
  QuizQuestion(
    id: 'cls214',
    question: 'Identify the simple present sentence:',
    options: ['She will cook dinner.', 'She is cooking dinner.', 'She cooks dinner every day.', 'She has cooked dinner.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The simple present tense is used for habitual actions, as indicated by "every day".',
  ),
  QuizQuestion(
    id: 'cls215',
    question: 'Which sentence shows a correct use of past perfect?',
    options: ['They have finished the task.', 'They had finished the task before the bell rang.', 'They finish the task before the bell.', 'They are finishing the task.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This sentence correctly uses the past perfect ("had finished") to show the first action was completed before another past action ("rang").',
  ),
  QuizQuestion(
    id: 'cls216',
    question: 'Complete the sentence: "By this evening, I ______ my homework."',
    options: ['will finish', 'will be finishing', 'will have finished', 'have finished'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The phrase "By this evening" indicates a deadline in the future, so the future perfect tense ("will have finished") is correct.',
  ),
  QuizQuestion(
    id: 'cls217',
    question: 'Which of the following uses present continuous correctly?',
    options: ['He writing a letter.', 'He is writing a letter.', 'He write a letter.', 'He wrote a letter.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The present continuous tense requires the auxiliary verb "is" with the present participle "writing".',
  ),
  QuizQuestion(
    id: 'cls218',
    question: 'What is the past simple form of "go"?',
    options: ['going', 'gone', 'went', 'goed'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Went" is the irregular past tense form of the verb "go".',
  ),
  QuizQuestion(
    id: 'cls219',
    question: '"I had eaten lunch when he arrived." Which two tenses are used here?',
    options: ['Present perfect and past simple', 'Past perfect and past simple', 'Past continuous and past perfect', 'Present continuous and past simple'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Had eaten" is past perfect, and "arrived" is past simple.',
  ),
  QuizQuestion(
    id: 'cls220',
    question: 'Choose the future continuous sentence:',
    options: ['She is studying.', 'She studied yesterday.', 'She will be studying at 5 PM.', 'She has studied.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The future continuous tense is formed with "will be + present participle (studying)".',
  ),
  QuizQuestion(
    id: 'cls221',
    question: 'Which of the following is a typical feature of a village?',
    options: ['Tall buildings', 'Traffic signals', 'Green fields', 'Shopping malls'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Green fields, farms, and open natural spaces are typical features of a village landscape.',
  ),
  QuizQuestion(
    id: 'cls222',
    question: 'What word best describes a city?',
    options: ['Silent', 'Crowded', 'Empty', 'Deserted'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Cities are typically known for having large populations, traffic, and bustling activity, making "crowded" a suitable adjective.',
  ),
  QuizQuestion(
    id: 'cls223',
    question: 'Which sentence uses an adjective correctly?',
    options: ['The school is a.', 'My city has a lake.', 'The park is beautiful.', 'Is there a temple?'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence correctly uses the adjective "beautiful" after the linking verb "is" to describe the subject "park".',
  ),
  QuizQuestion(
    id: 'cls224',
    question: 'Choose the correct comparison:',
    options: ['The lake is more clean than the river.', 'The temple is bigger than the bus.', 'The village is more peaceful than the city.', 'The road is most smoother.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence correctly uses the comparative form "more peaceful" (for a multi-syllable adjective) followed by "than".',
  ),
  QuizQuestion(
    id: 'cls225',
    question: 'Which of the following is a noun used in place descriptions?',
    options: ['Old', 'Busy', 'Park', 'Beautiful'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Park" is a noun (a person, place, or thing), while the other options are adjectives.',
  ),
  QuizQuestion(
    id: 'cls226',
    question: 'What is the correct structure for describing a place?',
    options: ['There big building is.', 'It has a green park.', 'My village quiet is.', 'Go temple to.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This sentence has the correct English word order: Subject (It) + Verb (has) + Object (a green park).',
  ),
  QuizQuestion(
    id: 'cls227',
    question: 'Which sentence uses a comparison word?',
    options: ['The city is light.', 'It is the lake.', 'My school is older than yours.', 'There are students.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence uses the comparative word "older... than" to make a comparison.',
  ),
  QuizQuestion(
    id: 'cls228',
    question: 'What makes speech more engaging?',
    options: ['Speaking slowly all the time', 'Using a monotone voice', 'Adding emotion and expression', 'Whispering descriptions'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Varying your tone, volume, and pace to express emotion and emphasis keeps the listener interested and engaged.',
  ),
  QuizQuestion(
    id: 'cls229',
    question: 'Which word is used to describe something visually attractive?',
    options: ['Crowded', 'Beautiful', 'Narrow', 'Dusty'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Beautiful" is an adjective used to describe something that is very pleasing to look at.',
  ),
  QuizQuestion(
    id: 'cls230',
    question: 'What can you say about a quiet place?',
    options: ['It is full of traffic.', 'It has many loud horns.', 'It is peaceful and calm.', 'It is larger than the mall.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A quiet place is often characterized by peace and calm, with little noise or disturbance.',
  ),
  QuizQuestion(
    id: 'cls231',
    question: 'Why do some people prefer mountains for travel?',
    options: ['For shopping malls', 'For swimming competitions', 'For hiking and nature', 'For traffic signals'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Mountains offer opportunities for outdoor activities like hiking and scenic views of nature, which are a major draw for travelers.',
  ),
  QuizQuestion(
    id: 'cls232',
    question: 'Which sentence correctly uses the past tense?',
    options: ['I going to beach.', 'I go to the beach.', 'I went to the beach.', 'I will going beach.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Went" is the past tense of "go", correctly used to describe a past action.',
  ),
  QuizQuestion(
    id: 'cls233',
    question: 'Which of the following is a travel-related activity?',
    options: ['Brushing teeth', 'Sightseeing', 'Watching TV', 'Sleeping late'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Sightseeing, or visiting interesting places, is a common activity people do while traveling.',
  ),
  QuizQuestion(
    id: 'cls234',
    question: 'What does the word "must" express in the sentence: "You must carry your ID card"?',
    options: ['A question', 'A wish', 'A strong requirement', 'A past event'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Must" is a modal verb used to express a strong obligation or necessity.',
  ),
  QuizQuestion(
    id: 'cls235',
    question: 'Which phrase helps organise steps when packing?',
    options: ['At the end', 'Yesterday', 'Next', 'Why'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Next" is a sequencing word used to indicate the following step in a process.',
  ),
  QuizQuestion(
    id: 'cls236',
    question: 'What is a good reason to use "should" in travel advice?',
    options: ['To describe the weather', 'To talk about past trips', 'To give suggestions', 'To talk about hobbies'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Should" is a modal verb used to give advice or make recommendations.',
  ),
  QuizQuestion(
    id: 'cls237',
    question: 'Which of the following is an example of describing a travel destination?',
    options: ['The room is very dark.', 'The city is full of tall buildings and lights.', 'I watched a film yesterday.', 'I Am Eating Lunch Now'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This sentence provides descriptive details about the features of a city, which helps paint a picture of the destination.',
  ),
  QuizQuestion(
    id: 'cls238',
    question: 'What is the purpose of a packing checklist?',
    options: ['To make the bag heavier', 'To delay the trip', 'To help remember important items', 'To reduce fun'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A checklist ensures you don\'t forget essential items like your passport, tickets, clothes, and toiletries.',
  ),
  QuizQuestion(
    id: 'cls239',
    question: 'Which is the correct order using sequencing words?',
    options: ['First, sleep. Then, eat.', 'Next, pack clothes. First, buy ticket.', 'First, check tickets. Then, pack bags.', 'Eat, sleep, pack.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This option uses logical order and correct sequencing. You check tickets first, then pack bags.',
  ),
  QuizQuestion(
    id: 'cls240',
    question: 'What should you take to the beach?',
    options: ['Woolen sweater', 'Gloves and scarf', 'Sunglasses and sunscreen', 'Boots and cap'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Sunglasses protect your eyes from the sun, and sunscreen protects your skin from UV rays, making them essential beach items.',
  ),
  QuizQuestion(
    id: 'cls241',
    question: 'Which verb form should you use to describe past travel experiences?',
    options: ['Present tense', 'Past tense', 'Future tense', 'Continuous'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'To talk about experiences that have already happened, you must use the past tense.',
  ),
  QuizQuestion(
    id: 'cls242',
    question: 'Which sentence uses correct past tense?',
    options: ['I go to Goa last summer.', 'I will go to Goa last summer.', 'I went to Goa last summer.', 'I going to Goa last summer.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence correctly uses the past tense verb "went" with the past time marker "last summer".',
  ),
  QuizQuestion(
    id: 'cls243',
    question: 'What is the purpose of using "Who, What, Where, When, Why" in a story?',
    options: ['To confuse the reader', 'To shorten the story', 'To structure the story clearly', 'To use more verbs'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'These 5 Ws help establish the key elements of a story: characters, plot, setting, time, and motivation, providing a clear framework.',
  ),
  QuizQuestion(
    id: 'cls244',
    question: 'Which sentence gives more descriptive detail?',
    options: ['We stayed at a hotel.', 'We stayed.', 'Hotel stay was.', 'We stayed in a small hotel near the beach with a sunset view.'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'This sentence adds adjectives ("small"), location details ("near the beach"), and additional imagery ("sunset view"), making it far more descriptive.',
  ),
  QuizQuestion(
    id: 'cls245',
    question: 'Which of the following is a transition word?',
    options: ['Because', 'First', 'Tall', 'Happy'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"First" is a transition word used to indicate the beginning of a sequence.',
  ),
  QuizQuestion(
    id: 'cls246',
    question: 'What do transition words help with in storytelling?',
    options: ['Making the story longer', 'Adding more characters', 'Organising the sequence of events', 'Changing the topic'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Transition words like "then," "next," and "finally" help the listener follow the order in which events happened.',
  ),
  QuizQuestion(
    id: 'cls247',
    question: 'Which is the best way to start a travel story?',
    options: ['It was fun.', 'Goa is a place.', 'Last year, I visited Goa with my cousins.', 'Go everywhere.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is a strong start because it sets the time ("Last year"), the place ("Goa"), and the main characters ("my cousins"), drawing the listener in.',
  ),
  QuizQuestion(
    id: 'cls248',
    question: 'Which of these is NOT a helpful transition word?',
    options: ['First', 'Next', 'Quickly', 'Finally'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Quickly" is an adverb describing how an action is performed, not a transition word for sequencing events.',
  ),
  QuizQuestion(
    id: 'cls249',
    question: 'Which part of a story adds emotion and interest?',
    options: ['Sentence fragments', 'Descriptive language', 'Spelling mistakes', 'Using only names'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Using vivid adjectives, strong verbs, and sensory details (descriptive language) helps the listener visualize and feel the story.',
  ),
  QuizQuestion(
    id: 'cls250',
    question: 'Which of the following helps improve story flow?',
    options: ['Skipping details', 'Using short commands', 'Using transition words like "Then" and "After that"', 'Repeating the same sentence'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Transition words create logical connections between sentences and paragraphs, guiding the listener smoothly through the narrative.',
  ),
  QuizQuestion(
    id: 'cls251',
    question: 'What is a folk tale?',
    options: ['A scientific fact', 'A traditional story with a moral', 'A newspaper report', 'A biography'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'A folk tale is a traditional story passed down through generations, often featuring animals or mythical beings and teaching a moral lesson.',
  ),
  QuizQuestion(
    id: 'cls252',
    question: 'Which of the following is an example of a folk tale?',
    options: ['The Discovery of Gravity', 'The Thirsty Crow', 'How to Use a Computer', 'News about Sports'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The story of the thirsty crow is a well-known folk tale from Indian tradition that teaches a lesson about problem-solving.',
  ),
  QuizQuestion(
    id: 'cls253',
    question: 'What lesson does "The Hare and the Tortoise" teach?',
    options: ['Fast runners always win', 'Winning doesn\'t matter', 'Slow and steady wins the race', 'Animals should not race'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The moral of this fable is that consistent, persistent effort ("slow and steady") will succeed over arrogant, inconsistent speed.',
  ),
  QuizQuestion(
    id: 'cls254',
    question: 'Which character is usually known for being clever or tricky?',
    options: ['The Tortoise', 'The Lion', 'The Fox', 'The Mouse'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'In many folk tales and fables, the fox is a common archetype for a clever, cunning, or tricky character.',
  ),
  QuizQuestion(
    id: 'cls255',
    question: 'What are the three main parts of a folk tale structure?',
    options: ['Problem, Setting, Action', 'Morning, Afternoon, Night', 'Beginning, Middle, End', 'Past, Present, Future'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Most narratives, including folk tales, follow a three-part structure: the beginning (introduction), the middle (conflict/problem), and the end (resolution/moral).',
  ),
  QuizQuestion(
    id: 'cls256',
    question: 'Which adjective best describes the crow in "The Thirsty Crow"?',
    options: ['Lazy', 'Brave', 'Foolish', 'Intelligent'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'The crow is considered intelligent because it cleverly drops stones into the pot to raise the water level.',
  ),
  QuizQuestion(
    id: 'cls257',
    question: 'What happens in the middle part of a folk tale?',
    options: ['The story ends', 'The characters are introduced', 'The problem or challenge appears', 'The moral is explained'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The middle of the story is where the main conflict, problem, or challenge is introduced, which the characters must then overcome.',
  ),
  QuizQuestion(
    id: 'cls258',
    question: 'How can you make a folk tale more creative?',
    options: ['Add real dates', 'Change all the words', 'Change small details or the ending', 'Use difficult language'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Putting a new twist on a classic story by altering minor plot points or creating an unexpected ending is a great way to be creative.',
  ),
  QuizQuestion(
    id: 'cls259',
    question: 'What would happen if the lion in "The Lion and the Mouse" didn\'t free the mouse?',
    options: ['The mouse would grow bigger', 'The mouse would help him later anyway', 'The lion might not be saved later', 'The story would stay the same'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'If the lion had not shown mercy, the mouse would not have been free to gnaw the net and save the lion, changing the moral of the story.',
  ),
  QuizQuestion(
    id: 'cls260',
    question: 'Why do folk tales use animals as characters?',
    options: ['Animals are easy to draw', 'To teach human values in a fun way', 'Because there are no human stories', 'Because children like only animals'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Using animal characters with human-like traits (anthropomorphism) makes the moral lessons more engaging, accessible, and less direct or preachy.',
  ),
  QuizQuestion(
    id: 'cls261',
    question: 'Why do we read stories?',
    options: ['Only to pass time', 'To travel in real life', 'To learn, imagine, and feel emotions', 'To memorise facts'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Stories serve many purposes, including entertainment, education, sparking imagination, and helping us understand different perspectives and emotions.',
  ),
  QuizQuestion(
    id: 'cls262',
    question: 'Which of the following is a type of book?',
    options: ['Phonebook', 'Comic', 'Receipt', 'Calendar'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'A comic book is a legitimate genre of book, while a phonebook, receipt, and calendar are not typically considered "books" for reading.',
  ),
  QuizQuestion(
    id: 'cls263',
    question: 'What kind of book uses speech bubbles and drawings?',
    options: ['Magazine', 'Picture book', 'Comic', 'Textbook'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Comics and graphic novels are defined by their use of sequential art and speech bubbles to tell a story.',
  ),
  QuizQuestion(
    id: 'cls264',
    question: 'Which book type usually has large pictures and few words?',
    options: ['Novel', 'Picture book', 'Comic', 'Magazine'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Picture books are designed for young children and primarily use illustrations to convey the story, with minimal text.',
  ),
  QuizQuestion(
    id: 'cls265',
    question: 'Which genre includes kings, queens, and magic?',
    options: ['Comedy', 'Thriller', 'Fairy Tale', 'Adventure'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Fairy tales are a genre of folklore that typically feature magical beings, royalty, and fantastical elements.',
  ),
  QuizQuestion(
    id: 'cls266',
    question: 'What is a common theme in mystery books?',
    options: ['Cooking', 'Solving puzzles or crimes', 'Making friends', 'Animal stories'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The central plot of a mystery novel revolves around solving a crime, uncovering a secret, or resolving a puzzling event.',
  ),
  QuizQuestion(
    id: 'cls267',
    question: 'What should a good travel story include?',
    options: ['Who, What, Where, When, Why', 'Only names', 'Only pictures', 'Just one sentence'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'A good travel story needs context: the people involved, the activities, the location, the time, and the reasons, which are the 5 Ws.',
  ),
  QuizQuestion(
    id: 'cls268',
    question: 'Which of the following is a sequencing word used in stories?',
    options: ['However', 'Because', 'First', 'Maybe'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"First" is a sequencing word used to indicate the initial step or event in a chronological order.',
  ),
  QuizQuestion(
    id: 'cls269',
    question: 'What is one benefit of writing your own comic book?',
    options: ['Memorising grammar rules', 'Improving your handwriting', 'Expressing creativity and sequencing', 'Drawing animals only'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Creating a comic book allows you to be creative with characters and plot while also practicing how to sequence events logically from panel to panel.',
  ),
  QuizQuestion(
    id: 'cls270',
    question: 'What helps make a story more interesting and detailed?',
    options: ['Using short, simple words only', 'Adding long paragraphs', 'Expanding sentences with description and action', 'Writing only one scene'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Adding descriptive details (adjectives, adverbs) and action verbs makes the narrative more vivid and engaging for the reader.',
  ),
  QuizQuestion(
    id: 'cls271',
    question: 'What makes a story engaging when spoken aloud?',
    options: ['Using a flat tone', 'Reading quickly', 'Using expressions and voice changes', 'Avoiding gestures'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Varying your voice (pitch, pace, volume) and using facial expressions adds emotion and emphasis, keeping the audience engaged.',
  ),
  QuizQuestion(
    id: 'cls272',
    question: 'What is a good reason to use different voices for different characters?',
    options: ['It makes the story harder to understand', 'It helps listeners tell characters apart', 'It keeps your voice the same', 'It removes the need for acting'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Distinct voices for each character help the audience know who is speaking without needing dialogue tags like "he said" or "she said".',
  ),
  QuizQuestion(
    id: 'cls273',
    question: 'What could be a fun twist to the story where a Genie grants a wish?',
    options: ['The Genie says no and leaves', 'The Genie makes it rain sweets instead of water', 'The Genie does nothing', 'The Genie goes to sleep'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This is a creative and unexpected twist because it subverts the normal expectation of a wish (like water) with something silly and imaginative (rain of sweets).',
  ),
  QuizQuestion(
    id: 'cls274',
    question: 'Why is using voice tone important in storytelling?',
    options: ['It changes the plot', 'It helps listeners stay awake', 'It adds emotion and energy to the story', 'It is not important'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Tone conveys the narrator\'s or characters\' feelings (excitement, fear, sadness), making the story more dynamic and emotionally resonant.',
  ),
  QuizQuestion(
    id: 'cls275',
    question: 'What is one way to end a story creatively?',
    options: ['Repeat the beginning', 'Use a funny or unexpected outcome', 'Stop in the middle', 'Make the ending confusing'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'A surprising or humorous resolution can leave a lasting impression on the audience and is a common technique in creative writing.',
  ),
  QuizQuestion(
    id: 'cls276',
    question: 'What should you do if a story starts "A village had no water"?',
    options: ['Leave it simple', 'Add details like weather, people\'s emotions, and what happened next', 'Say it quickly', 'Ignore the problem in the story'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'To build a compelling narrative, you should expand on the initial problem by adding sensory details (scorching sun), emotional impact (thirsty, worried people), and subsequent events.',
  ),
  QuizQuestion(
    id: 'cls277',
    question: 'What is a rhyme?',
    options: ['A type of dance', 'A word that has the same beginning sound', 'A word that has the same ending sound', 'A long sentence'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A rhyme is a repetition of similar sounds, usually the ending sounds, in two or more words (e.g., cat/hat, sky/fly).',
  ),
  QuizQuestion(
    id: 'cls278',
    question: 'Which of these pairs are rhyming words?',
    options: ['Book - Chair', 'Cat - Hat', 'Sun - Light', 'School - Learn'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Cat" and "Hat" share the same ending sound "-at", making them a perfect rhyme.',
  ),
  QuizQuestion(
    id: 'cls279',
    question: 'Why do poems use rhyming words?',
    options: ['To make them difficult', 'To confuse the reader', 'To give rhythm and make them fun', 'To make them longer'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Rhyme creates a musical quality and a predictable pattern (rhythm) that makes poems pleasing to hear, easier to remember, and often more enjoyable.',
  ),
  QuizQuestion(
    id: 'cls280',
    question: 'Which of these rhymes with "Sky"?',
    options: ['Tree', 'Day', 'Fly', 'Run'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Sky" and "Fly" share the same ending sound "-y" (or "-ai" sound).',
  ),
  QuizQuestion(
    id: 'cls281',
    question: 'Which word rhymes with "Night"?',
    options: ['Bright', 'Read', 'Sun', 'Cloud'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: '"Night" and "Bright" share the same ending sound "-ight".',
  ),
  QuizQuestion(
    id: 'cls282',
    question: 'What is the second line of this poem likely to be? "The cat sat on a mat..."',
    options: ['And wore a red hat', 'And ran very fast', 'And jumped into a pool', 'And opened a book'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'A second line rhyming with "mat" is "hat". The other options do not rhyme.',
  ),
  QuizQuestion(
    id: 'cls283',
    question: 'What helps poems sound musical and smooth?',
    options: ['Difficult vocabulary', 'Long sentences', 'Rhyming words', 'Big paragraphs'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Rhyme creates a pattern of repeated sounds, which is the primary device that gives poetry its musical and flowing quality.',
  ),
  QuizQuestion(
    id: 'cls284',
    question: 'Which of the following is a good way to say a poem?',
    options: ['In a flat, quiet voice', 'With no emotion', 'Loudly and with expression', 'Very fast and without pausing'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Reciting a poem with appropriate volume and emotional expression (using tone, pace, and emphasis) brings the words to life for the listener.',
  ),
  QuizQuestion(
    id: 'cls285',
    question: 'Which line can follow this one? "The dog barked loud all day..."',
    options: ['He ran away to play', 'The cat was sleeping', 'The boy ate food', 'It rained in the city'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'This line continues the story of the dog with a logical action that rhymes with "day" (play).',
  ),
  QuizQuestion(
    id: 'cls286',
    question: 'Why should we use gestures and expressions while saying a poem?',
    options: ['To make it longer', 'To confuse others', 'To make it more engaging and fun', 'To finish'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Gestures and facial expressions add a visual and emotional layer to the recitation, making it more interesting and dynamic for the audience.',
  ),
  QuizQuestion(
    id: 'cls287',
    question: 'What is one example of entertainment media?',
    options: ['Newspaper', 'Cartoons', 'Textbook', 'Dictionary'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Cartoons are a form of animated entertainment, while the other options are primarily for information or reference.',
  ),
  QuizQuestion(
    id: 'cls288',
    question: 'What do actors use to show emotions in a movie?',
    options: ['Colors and shapes', 'Facial expressions, tone, and gestures', 'Only their voices', 'Only background music'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Actors use their body (facial expressions, gestures, posture) and their voice (tone, pitch, volume) as their primary tools to convey emotion.',
  ),
  QuizQuestion(
    id: 'cls289',
    question: 'Which genre is meant to make people laugh?',
    options: ['Drama', 'Action', 'Comedy', 'Thriller'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Comedy is a genre of entertainment that aims to amuse and evoke laughter from the audience.',
  ),
  QuizQuestion(
    id: 'cls290',
    question: 'What is a sign that a character is scared?',
    options: ['Smiling face', 'Wide eyes and a shaky voice', 'Loud laughter', 'Calm voice and closed eyes'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Wide eyes (a startle response) and a shaky, uneven voice are classic physical and vocal indicators of fear.',
  ),
  QuizQuestion(
    id: 'cls291',
    question: 'What helps you understand the emotion behind a movie line?',
    options: ['The background color', 'The actor\'s body language', 'The length of the scene', 'The number of actors'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'An actor\'s body language (posture, gestures, facial expressions) provides crucial non-verbal cues that reveal the true emotion underlying the spoken words.',
  ),
  QuizQuestion(
    id: 'cls292',
    question: 'Which of the following is a TV show format?',
    options: ['Long newspaper article', 'One-time live event', 'Multiple short episodes', 'Comic strip'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Television shows are typically structured as a series of individual episodes, often released weekly or in seasons.',
  ),
  QuizQuestion(
    id: 'cls293',
    question: 'Which sentence shows excitement when said with energy?',
    options: ['"Let\'s go on an adventure!"', '"I have to do homework."', '"I lost my pen."', '"Close the door."'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'This line, when delivered with enthusiasm and a rising intonation, clearly expresses excitement.',
  ),
  QuizQuestion(
    id: 'cls294',
    question: 'What do you look for while recreating a movie scene?',
    options: ['Grammar rules', 'Weather in the movie', 'Expressions, gestures, and tone', 'Title of the movie'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'To effectively recreate a scene, you must mimic the actors\' emotions and delivery, which are conveyed through their expressions, body language, and vocal tone.',
  ),
  QuizQuestion(
    id: 'cls295',
    question: 'What does a drama usually focus on?',
    options: ['Magic and wizards', 'Funny jokes', 'Serious and emotional stories', 'Animals'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The drama genre is characterized by realistic storytelling that focuses on character development and serious, often emotional, themes.',
  ),
  QuizQuestion(
    id: 'cls296',
    question: 'Why is it helpful to watch movies with subtitles?',
    options: ['To read faster', 'To learn spelling', 'To understand dialogues and match them with expression', 'To guess what happens next'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Subtitles allow you to read the exact dialogue while hearing it spoken and seeing the actor\'s expression, which greatly aids language comprehension and vocabulary building.',
  ),
  QuizQuestion(
    id: 'cls297',
    question: 'What is a common reason people enjoy festivals?',
    options: ['Because they are boring', 'Because they are always quiet', 'Because they bring joy and celebration', 'Because people go to work'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Festivals are times of celebration, community gathering, and often a break from routine, which brings people joy.',
  ),
  QuizQuestion(
    id: 'cls298',
    question: 'Which of the following words is related to festival vocabulary?',
    options: ['Calculate', 'Decorate', 'Swim', 'Drive'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Decorate" is a common activity associated with festivals, where people adorn their homes and spaces.',
  ),
  QuizQuestion(
    id: 'cls299',
    question: 'What do many people do during Diwali?',
    options: ['Fly kites', 'Eat only fruits', 'Decorate with lamps and lights', 'Wear black clothes'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Diwali, the festival of lights, is celebrated by lighting oil lamps (diyas) and decorating homes with lights and rangoli.',
  ),
  QuizQuestion(
    id: 'cls300',
    question: 'What do people commonly do during Eid?',
    options: ['Fast all day', 'Exchange gifts and enjoy a feast', 'Swim in the sea', 'Play video games'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Eid al-Fitr is celebrated with special prayers, festive meals, and the exchange of gifts and sweets with family and friends.',
  ),
  QuizQuestion(
    id: 'cls301',
    question: 'What is a feature of Christmas celebrations?',
    options: ['Playing Holi with colors', 'Lighting oil lamps', 'Decorating a Christmas tree', 'Breaking coconuts'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Decorating a Christmas tree with ornaments and lights is a central tradition of the Christmas holiday.',
  ),
  QuizQuestion(
    id: 'cls302',
    question: 'What makes Holi different from other festivals?',
    options: ['It is a silent festival', 'People stay at home', 'People play with colored powder', 'It only happens at night'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Holi is uniquely known as the "festival of colors," where people throw colored powder and water at each other in celebration.',
  ),
  QuizQuestion(
    id: 'cls303',
    question: 'Which of the following is a harvest festival in Tamil Nadu?',
    options: ['Pongal', 'Diwali', 'Raksha Bandhan', 'Christmas'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'Pongal is a major harvest festival celebrated in Tamil Nadu, thanking the Sun God and nature for a bountiful harvest.',
  ),
  QuizQuestion(
    id: 'cls304',
    question: 'Which of these is a correct sentence using festival vocabulary?',
    options: ['We calculate rice during Pongal.', 'I decorate my exam sheet.', 'We celebrate with fireworks during Diwali.', 'He eats food with a calculator.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence accurately uses the verb "celebrate" and the festival-related noun "fireworks" in the context of Diwali.',
  ),
  QuizQuestion(
    id: 'cls305',
    question: 'What do many festivals across India have in common?',
    options: ['They only happen in summer', 'They involve food, prayers, and decorations', 'They are all the same', 'They happen on the same day'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'While specific rituals differ, most Indian festivals share common elements like special foods, prayer rituals, and decorating homes.',
  ),
  QuizQuestion(
    id: 'cls306',
    question: 'What helps learners describe a festival better?',
    options: ['Using made-up words', 'Speaking very fast', 'Using festival-related vocabulary and full sentences', 'Drawing cartoons'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Using specific vocabulary (e.g., "decorate," "celebrate," "feast") and forming complete, grammatically correct sentences allows for a clear and accurate description.',
  ),
  QuizQuestion(
    id: 'cls307',
    question: 'Which of the following is an example of a hobby?',
    options: ['Sleeping', 'Painting', 'Eating', 'Brushing teeth'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Painting is a creative activity done for enjoyment in one\'s free time, which is the definition of a hobby.',
  ),
  QuizQuestion(
    id: 'cls308',
    question: 'What kind of activity is reading?',
    options: ['Outdoor activity', 'Indoor activity', 'Group sport', 'Physical exercise'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Reading is typically a quiet, sedentary activity that is done indoors.',
  ),
  QuizQuestion(
    id: 'cls309',
    question: '"My favorite hobby is gardening because it is peaceful." - What is the reason given here?',
    options: ['It is easy', 'It is colorful', 'It is peaceful', 'It is fast'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The sentence explicitly states the reason: "because it is peaceful."',
  ),
  QuizQuestion(
    id: 'cls310',
    question: 'Which activity is considered relaxing?',
    options: ['Fighting', 'Yoga', 'Shouting', 'Jumping'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Yoga is a mind-body practice that combines physical postures, breathing exercises, and meditation, known for its relaxing effects.',
  ),
  QuizQuestion(
    id: 'cls311',
    question: 'What is the hobby of a person playing the guitar?',
    options: ['Drawing', 'Singing', 'Playing music', 'Dancing'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Playing a musical instrument like the guitar falls under the general hobby category of "playing music".',
  ),
  QuizQuestion(
    id: 'cls312',
    question: 'Which of the following is an outdoor hobby?',
    options: ['Chess', 'Reading', 'Swimming', 'Sketching'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Swimming is an activity typically done in an outdoor pool, lake, or ocean.',
  ),
  QuizQuestion(
    id: 'cls313',
    question: '"Journaling" is a hobby that involves:',
    options: ['Playing a sport', 'Writing thoughts and ideas', 'Cooking food', 'Hiking mountains'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Journaling is the practice of regularly writing down one\'s thoughts, feelings, and experiences.',
  ),
  QuizQuestion(
    id: 'cls314',
    question: '"Crafting" is best described as:',
    options: ['Running races', 'Making creative things with hands', 'Watching TV', 'Climbing trees'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Crafting involves creating handmade items, such as knitting, woodworking, or pottery, using manual skill and creativity.',
  ),
  QuizQuestion(
    id: 'cls315',
    question: 'What does the sentence "Drawing makes me happy" express?',
    options: ['A fact', 'An order', 'An opinion', 'A warning'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence expresses a personal feeling or belief ("makes me happy"), which is a subjective opinion, not an objective fact.',
  ),
  QuizQuestion(
    id: 'cls316',
    question: 'Which of these hobbies is best for someone who enjoys nature?',
    options: ['Video gaming', 'Hiking', 'Watching movies', 'Studying indoors'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Hiking involves walking in natural environments like forests, mountains, or trails, allowing for direct immersion in nature.',
  ),
  QuizQuestion(
    id: 'cls317',
    question: 'What is an important part of a good conversation?',
    options: ['Talking the most', 'Interrupting often', 'Listening and asking questions', 'Avoiding eye contact'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Effective conversation is a two-way street that requires active listening to understand the other person and asking questions to show interest and keep the dialogue flowing.',
  ),
  QuizQuestion(
    id: 'cls318',
    question: 'Which of these is a good way to start a conversation?',
    options: ['"Go away."', '"Why are you here?"', '"Hi, how are you?"', '"Don\'t talk to me."'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A simple, friendly greeting like "Hi" followed by a general question like "How are you?" is a standard and polite conversation starter.',
  ),
  QuizQuestion(
    id: 'cls319',
    question: 'What can help keep a conversation going?',
    options: ['Saying "I don\'t care"', 'Asking follow-up questions', 'Staying silent', 'Changing the topic suddenly'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Asking follow-up questions (e.g., "What did you like most about it?") shows you are listening and encourages the other person to elaborate.',
  ),
  QuizQuestion(
    id: 'cls320',
    question: 'Which of these is a polite way to end a conversation?',
    options: ['"Bye."', '"It was nice talking to you!"', '"I\'m bored."', '"Stop talking."'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This is a polite closing statement that expresses appreciation for the interaction before ending it.',
  ),
  QuizQuestion(
    id: 'cls321',
    question: 'Which phrase shows interest in what someone said?',
    options: ['"Tell me more!"', '"That\'s boring."', '"I don\'t know."', '"Whatever."'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'Saying "Tell me more!" is an enthusiastic request for additional details, which clearly demonstrates interest.',
  ),
  QuizQuestion(
    id: 'cls322',
    question: 'Why is eye contact important in conversation?',
    options: ['It shows you are angry', 'It shows you are listening and engaged', 'It means you are distracted', 'It helps you ignore the speaker'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Eye contact is a non-verbal cue that signals attentiveness, respect, and engagement with the speaker.',
  ),
  QuizQuestion(
    id: 'cls323',
    question: 'What should you avoid in a friendly conversation?',
    options: ['Smiling', 'Asking about someone\'s day', 'Interrupting often', 'Listening carefully'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Interrupting is considered rude because it prevents the other person from finishing their thought and shows a lack of respect.',
  ),
  QuizQuestion(
    id: 'cls324',
    question: 'Which is a friendly follow-up question?',
    options: ['"Why are you still talking?"', '"What did you do next?"', '"This is boring."', '"Can you stop?"'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This question encourages the speaker to continue their story and shows genuine interest in what they are saying.',
  ),
  QuizQuestion(
    id: 'cls325',
    question: 'When someone says "I love painting," what\'s a good response?',
    options: ['"That\'s weird."', '"Tell me more about it!"', '"So what?"', '"Never mind."'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This is a positive and encouraging response that invites the person to share more about their hobby, fostering a friendly conversation.',
  ),
  QuizQuestion(
    id: 'cls326',
    question: 'How can you make someone feel comfortable in a conversation?',
    options: ['Ignore what they say', 'Keep looking at your phone', 'Smile and listen carefully', 'Talk only about yourself'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Smiling creates a warm, welcoming atmosphere, and listening carefully shows respect and value for the other person, making them feel at ease.',
  ),
  QuizQuestion(
    id: 'cls327',
    question: 'Which of the following is a basic emotion?',
    options: ['Running', 'Drawing', 'Happy', 'Reading'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Happiness is one of the core, fundamental human emotions, along with sadness, fear, anger, surprise, and disgust.',
  ),
  QuizQuestion(
    id: 'cls328',
    question: 'What does a smile usually show?',
    options: ['Anger', 'Sadness', 'Happiness', 'Fear'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A smile is a universal facial expression that typically signals happiness, friendliness, or pleasure.',
  ),
  QuizQuestion(
    id: 'cls329',
    question: 'What is a polite way to ask about someone\'s feelings?',
    options: ['"What\'s your problem?"', '"Why are you like this?"', '"Are you okay?"', '"Don\'t talk to me."'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Are you okay?" is a gentle, non-confrontational, and caring question to check on someone\'s emotional state.',
  ),
  QuizQuestion(
    id: 'cls330',
    question: 'Which emotion might be shown by biting nails and looking worried?',
    options: ['Happy', 'Nervous', 'Angry', 'Excited'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Nail-biting is a common nervous habit, and a worried facial expression is a sign of anxiety or nervousness.',
  ),
  QuizQuestion(
    id: 'cls331',
    question: 'How do people often look when they are sad?',
    options: ['They laugh loudly', 'They jump and smile', 'They look down or cry', 'They clap and cheer'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Looking down, avoiding eye contact, crying, and having a downturned mouth are common visual indicators of sadness.',
  ),
  QuizQuestion(
    id: 'cls332',
    question: 'What is an example of an empathetic response?',
    options: ['"I don\'t care."', '"That sounds amazing!"', '"Why are you sad?"', '"Stop crying."'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Sharing in someone\'s positive emotion ("That sounds amazing!") is a form of empathetic response. An empathetic response to sadness would be "That sounds really hard, I\'m sorry."',
  ),
  QuizQuestion(
    id: 'cls333',
    question: 'Which of these is a good way to show you are listening to someone\'s feelings?',
    options: ['Ignore them', 'Use your phone', 'Make eye contact and nod', 'Walk away'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Making eye contact shows focus, and nodding signals that you are following and understanding what is being said, validating the speaker\'s feelings.',
  ),
  QuizQuestion(
    id: 'cls334',
    question: 'What emotion might someone feel before an exam?',
    options: ['Angry', 'Nervous', 'Excited', 'Bored'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Exams often cause feelings of anxiety, worry, or nervousness due to the pressure to perform well.',
  ),
  QuizQuestion(
    id: 'cls335',
    question: 'Which body language shows someone is happy?',
    options: ['Frowning', 'Slouching', 'Smiling and standing tall', 'Crossing arms'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A genuine smile (with eyes) and an open, upright posture are strong, positive body language cues for happiness and confidence.',
  ),
  QuizQuestion(
    id: 'cls336',
    question: 'What does "I\'m sorry to hear that" show in a conversation?',
    options: ['Anger', 'Surprise', 'Care and empathy', 'Confusion'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This phrase is used to express sympathy and regret upon hearing about someone else\'s misfortune or bad news, demonstrating care and empathy.',
  ),
  QuizQuestion(
    id: 'cls337',
    question: 'Which of the following is an opinion?',
    options: ['The sun rises in the east', 'Water freezes at 0°C', 'I think chocolate is the best dessert', 'Dogs are mammals'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This statement expresses a personal belief or preference ("best") that cannot be proven true or false, which is the definition of an opinion.',
  ),
  QuizQuestion(
    id: 'cls338',
    question: 'Which phrase is used to politely express an opinion?',
    options: ['You are wrong', 'I think...', 'It is hot outside', 'This is not true'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Using "I think" or "In my opinion" before a statement makes it clear that you are sharing a personal view, which is a polite way to express it.',
  ),
  QuizQuestion(
    id: 'cls339',
    question: 'What is the difference between a fact and an opinion?',
    options: ['Facts are false, opinions are true', 'Opinions can be proven, facts cannot', 'Facts can be proven, opinions are personal thoughts', 'Both are guesses'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A fact is an objective statement that can be verified with evidence. An opinion is a subjective statement that reflects an individual\'s feelings or beliefs.',
  ),
  QuizQuestion(
    id: 'cls340',
    question: 'Which of the following is a fact?',
    options: ['Apples are the tastiest fruit', 'I believe books are better than movies', 'The earth orbits the sun', 'I feel happy on rainy days'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is a scientific fact that has been proven and can be verified.',
  ),
  QuizQuestion(
    id: 'cls341',
    question: 'Which is the best way to politely disagree with someone?',
    options: ['That\'s a silly idea', 'I don\'t agree at all', 'I respect your view, but I prefer something else', 'You\'re totally wrong'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is polite because it first validates the other person\'s perspective ("I respect your view") before stating a different preference ("but I prefer...").',
  ),
  QuizQuestion(
    id: 'cls342',
    question: 'Which sentence includes a reason for the opinion?',
    options: ['I like mangoes.', 'I like mangoes because they are sweet.', 'Mangoes are yellow.', 'I want mangoes.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The conjunction "because" is used to introduce the reason ("they are sweet") for the opinion ("I like mangoes").',
  ),
  QuizQuestion(
    id: 'cls343',
    question: 'What word helps connect an opinion with a reason?',
    options: ['So', 'Then', 'Because', 'When'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"Because" is the conjunction used to show cause and effect, linking the opinion to the underlying reason.',
  ),
  QuizQuestion(
    id: 'cls344',
    question: 'Choose a polite sentence starter for giving your view:',
    options: ['It\'s obvious that...', 'I don\'t care but...', 'I feel that...', 'Whatever, I guess...'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"I feel that..." is a gentle and respectful way to introduce a personal opinion.',
  ),
  QuizQuestion(
    id: 'cls345',
    question: 'What should you avoid when someone has a different opinion?',
    options: ['Listening carefully', 'Saying "That\'s interesting"', 'Saying "That makes no sense"', 'Using "I see your point..."'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Dismissing someone\'s opinion as nonsense is rude and disrespectful, shutting down the conversation rather than engaging with it.',
  ),
  QuizQuestion(
    id: 'cls346',
    question: 'Which of the following is a respectful reply?',
    options: ['That\'s wrong!', 'You\'re not making sense.', 'I see your point, but I think differently.', 'I don\'t want to hear it.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This reply is respectful because it acknowledges the other person\'s viewpoint ("I see your point") before politely stating a differing opinion.',
  ),
  QuizQuestion(
    id: 'cls347',
    question: 'Why is clear speaking important?',
    options: ['It makes you sound louder', 'It helps others understand you easily', 'It saves time while speaking', 'It impresses people'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The primary goal of clear speaking is effective communication: ensuring your listener can understand your words without confusion or effort.',
  ),
  QuizQuestion(
    id: 'cls348',
    question: 'What is the correct way to say: "My name is Anil. I live in Delhi"?',
    options: ['My name is anil live in Delhi', 'My name is Anil i live in Delhi', 'My name is Anil. I live in Delhi.', 'My name is Anil live in Delhi'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This option correctly separates the two ideas into two distinct sentences, each with a clear subject and verb, and uses correct capitalization and punctuation.',
  ),
  QuizQuestion(
    id: 'cls349',
    question: 'Which is an example of speaking too fast?',
    options: ['Speaking word by word slowly', 'Saying a sentence with no pauses', 'Reading with correct pauses', 'Speaking in a friendly tone'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Speaking too fast often involves rushing through sentences and not taking natural breaths or pauses, making it hard for the listener to process the words.',
  ),
  QuizQuestion(
    id: 'cls350',
    question: 'What helps control the pace of speaking?',
    options: ['Memorising long words', 'Using complex grammar', 'Practicing simple sentences at different speeds', 'Reading silently'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Practicing with simple sentences allows you to focus on your speed and rhythm, learning to slow down, speed up, and pause intentionally.',
  ),
  QuizQuestion(
    id: 'cls351',
    question: 'What changes the meaning of a spoken sentence?',
    options: ['Handwriting', 'Vocabulary', 'Tone and volume', 'Number of words'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Paralinguistic features like tone (e.g., sarcastic, sincere) and volume (e.g., loud, soft) can dramatically alter the intended meaning of a sentence, even if the words are the same.',
  ),
  QuizQuestion(
    id: 'cls352',
    question: 'Which of the following has a flat tone?',
    options: ['"I AM HAPPY TO SEE YOU!" (said with excitement)', '"I am happy to see you." (said without emotion)', '"Wow! That\'s amazing!" (said cheerfully)', '"Let\'s celebrate!" (said with a smile)'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'A flat tone is characterized by a lack of pitch variation or emotional expression, making the speech sound monotonous.',
  ),
  QuizQuestion(
    id: 'cls353',
    question: 'How should you speak in a noisy room?',
    options: ['Very softly', 'In a whisper', 'A little louder than usual', 'Without moving your lips'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'To be heard over background noise, you need to increase your volume slightly (project) without shouting, and enunciate clearly.',
  ),
  QuizQuestion(
    id: 'cls354',
    question: 'What is the correct pronunciation of the word "comfortable"?',
    options: ['Comfort-table', 'Cum-fort-table', 'Kumf-tuh-buhl', 'Com-fur-table'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The most common and natural pronunciation of "comfortable" in standard English is "KUMF-tuh-buhl", where the "or" syllable is reduced or dropped.',
  ),
  QuizQuestion(
    id: 'cls355',
    question: 'Which of these is commonly mispronounced?',
    options: ['Dog', 'Library', 'Apple', 'Train'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Library" is frequently mispronounced as "libary" or "lie-berry" because people often drop the first "r" sound.',
  ),
  QuizQuestion(
    id: 'cls356',
    question: 'What helps build confidence in pronunciation?',
    options: ['Speaking quietly', 'Ignoring difficult words', 'Listening and repeating correct words', 'Reading only in your head'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Active listening to native or proficient speakers, followed by intentional repetition (shadowing), is one of the most effective ways to improve pronunciation and build confidence.',
  ),
  QuizQuestion(
    id: 'cls357',
    question: 'What does a "future plan" mean?',
    options: ['Something you did yesterday', 'Something you are doing now', 'Something you want to do later', 'Something someone else did'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'A future plan is an intention or goal to do something at a time that has not yet happened (in the future).',
  ),
  QuizQuestion(
    id: 'cls358',
    question: 'Which of the following shows a future plan?',
    options: ['I ate lunch.', 'I am watching TV.', 'I want to visit Mumbai next year.', 'I like cartoons.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This sentence expresses a desire or intention to do something ("visit Mumbai") at a specific future time ("next year").',
  ),
  QuizQuestion(
    id: 'cls359',
    question: 'Which sentence talks about a career goal?',
    options: ['I will play cricket today', 'I want to be a doctor', 'I ate biryani', 'I like cartoons'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'A career goal is a professional ambition. "I want to be a doctor" expresses a long-term professional aspiration.',
  ),
  QuizQuestion(
    id: 'cls360',
    question: 'What word can we use to explain why we have a goal?',
    options: ['And', 'Or', 'Because', 'But'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The conjunction "because" is used to provide a reason or explanation for something, including why you have a particular goal.',
  ),
  QuizQuestion(
    id: 'cls361',
    question: 'Choose the sentence with "will" used correctly:',
    options: ['I will played football.', 'I will going to market', 'I will go to school tomorrow.', 'I will went to the shop.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The simple future tense "will" must be followed by the base form of the verb. "Will go" is correct.',
  ),
  QuizQuestion(
    id: 'cls362',
    question: 'Which sentence uses "going to" correctly?',
    options: ['I going to sleep now.', 'I am going to the zoo this Sunday', 'I go to going market.', 'I am go to eat'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'The correct structure for "going to" for a plan is: subject + am/is/are + going to + base verb. "I am going to the zoo" is correct (though here "to" is a preposition for place, not part of the future tense, but the sentence is grammatically correct).',
  ),
  QuizQuestion(
    id: 'cls363',
    question: 'What does "ambition" mean?',
    options: ['A boring story', 'A past event', 'A dream or goal for the future', 'A type of movie'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Ambition is a strong desire to achieve something, typically a long-term goal or dream for the future.',
  ),
  QuizQuestion(
    id: 'cls364',
    question: 'Which of these is a good question to ask about someone\'s future?',
    options: ['What did you eat yesterday?', 'Where do you live now?', 'What do you want to become?', 'Are you tired?'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This question directly asks about a person\'s future career or life aspirations, making it relevant to the topic of "future".',
  ),
  QuizQuestion(
    id: 'cls365',
    question: '"I want to become an artist because..." Choose the best ending:',
    options: ['I like drawing and painting.', 'I am hungry.', 'I am tired.', 'I was sad.'],
    correctIndex: 0,
    subject: 'BS-CLS',
    description: 'This is the only option that provides a logical reason for wanting to become an artist, as drawing and painting are key artistic activities.',
  ),
  QuizQuestion(
    id: 'cls366',
    question: 'How can you start a sentence about your dream?',
    options: ['I had a dog.', 'I watched TV.', 'One day, I want to...', 'I played football.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"One day, I want to..." is a classic and effective opening phrase for talking about a future dream or aspiration.',
  ),
  QuizQuestion(
    id: 'cls367',
    question: 'Why is it important to speak clearly?',
    options: ['To impress others', 'To be understood easily', 'To speak quickly', 'To memorise long speeches'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Clarity in speech ensures that your message is received and understood by the listener without confusion or misinterpretation.',
  ),
  QuizQuestion(
    id: 'cls368',
    question: 'Which of the following is a correct sentence?',
    options: ['He go to school.', 'I am tired.', 'She going to market', 'They is happy.'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'This sentence has correct subject-verb agreement ("I am") and is a complete thought.',
  ),
  QuizQuestion(
    id: 'cls369',
    question: 'What is a common speaking mistake?',
    options: ['Using full sentences', 'Speaking with eye contact', 'Saying "She is doctor" (missing a/an)', 'Pausing while speaking'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Forgetting to use the indefinite article ("a" or "an") before a singular, countable noun is a very common error for English learners (e.g., "She is a doctor").',
  ),
  QuizQuestion(
    id: 'cls370',
    question: 'What helps in expressing ideas clearly?',
    options: ['Speaking fast', 'Using long words', 'Organising thoughts before speaking', 'Repeating the same sentence'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Taking a moment to mentally structure what you want to say before you start speaking helps avoid rambling and makes your point clearer.',
  ),
  QuizQuestion(
    id: 'cls371',
    question: 'What is a good way to fix grammar errors in speaking?',
    options: ['Speak without stopping', 'Memorise difficult words', 'Learn from examples and correct yourself', 'Ignore mistakes'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Self-correction is a key learning skill. By listening to examples, identifying your own errors, and rephrasing correctly, you gradually improve your grammar.',
  ),
  QuizQuestion(
    id: 'cls372',
    question: 'Which tool improves confidence while speaking?',
    options: ['Using a flat tone', 'Looking down while talking', 'Practicing eye contact', 'Speaking in a whisper'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Making eye contact with your listener creates a connection and shows confidence. It also helps you gauge if they are understanding you.',
  ),
  QuizQuestion(
    id: 'cls373',
    question: 'Which is an example of voice modulation?',
    options: ['Speaking in one tone', 'Speaking without pauses', 'Emphasising important words', 'Speaking without moving lips'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Voice modulation is the variation in pitch, volume, and pace. Emphasizing (stressing) certain words is a key modulation technique to highlight important information.',
  ),
  QuizQuestion(
    id: 'cls374',
    question: 'What is a filler word that should be avoided?',
    options: ['Hello', 'Umm', 'Thank you', 'Because'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: '"Umm," "uh," "like," and "you know" are filler words that add no meaning. Overusing them can make you sound hesitant or unprepared.',
  ),
  QuizQuestion(
    id: 'cls375',
    question: 'What can help you avoid filler words when speaking?',
    options: ['Speaking without stopping', 'Thinking before you speak', 'Looking away from the listener', 'Speaking in a rush'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Pausing briefly to think is much more effective than saying "umm". A silent pause makes you sound thoughtful, while filler words make you sound unsure.',
  ),
  QuizQuestion(
    id: 'cls376',
    question: 'What is a confident way to end a self-introduction?',
    options: ['That\'s all, I guess.', 'So, umm, yeah...', 'Thank you for listening to me.', 'I forgot the rest.'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Ending with a polite "thank you" shows confidence, professionalism, and appreciation for the listener\'s time.',
  ),
  QuizQuestion(
    id: 'cls377',
    question: 'What is one key element of a good conversation?',
    options: ['Talking non-stop', 'Asking follow-up questions', 'Ignoring the other person', 'Using only short answers'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Asking follow-up questions shows you are listening and are interested, which keeps the conversation flowing.',
  ),
  QuizQuestion(
    id: 'cls378',
    question: 'Which phrase is polite when asking for something in a restaurant?',
    options: ['"Give me food."', '"I want it now."', '"I would like a dosa, please."', '"Where\'s the food?"'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"I would like" is a standard, polite phrase for ordering, and adding "please" makes it even more courteous.',
  ),
  QuizQuestion(
    id: 'cls379',
    question: 'Which sentence is a complete and detailed response?',
    options: ['"I like movies."', '"Yes"', '"Movies."', '"I like movies because they make me feel relaxed after a long day."'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'This response is full and detailed because it states an opinion ("I like movies") and provides a specific reason ("because they make me feel relaxed").',
  ),
  QuizQuestion(
    id: 'cls380',
    question: 'What makes a conversation flow better?',
    options: ['Long silences', 'Changing the topic quickly', 'Giving one-word answers', 'Active listening and replying with interest'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'Active listening (paying attention) and showing interest with your replies encourages the other person to continue, creating a natural, smooth exchange.',
  ),
  QuizQuestion(
    id: 'cls381',
    question: 'Which is a good example of asking for directions?',
    options: ['"Where is it?"', '"I\'m lost!"', '"Excuse me, can you please tell me the way to the market?"', '"Tell me now."'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is polite ("Excuse me," "please"), clear, and specific, making it the best way to ask for help with directions.',
  ),
  QuizQuestion(
    id: 'cls382',
    question: 'What is the correct pronunciation of the word "comfortable"?',
    options: ['Com-fort-able', 'Comf-terr-bull', 'Kumf-tuh-buhl', 'Kum-fer-table'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'The standard pronunciation in American and British English reduces the word to three syllables: "KUMF-tuh-buhl".',
  ),
  QuizQuestion(
    id: 'cls383',
    question: 'Which technique helps improve fluency?',
    options: ['Whispering', 'Speaking very fast', 'Using tongue twisters', 'Avoiding speaking'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Tongue twisters help improve articulation, muscle memory, and the ability to switch between similar sounds, which are key components of fluency.',
  ),
  QuizQuestion(
    id: 'cls384',
    question: 'Which sentence uses a polite closing for a conversation?',
    options: ['"I\'m done talking."', '"That\'s all."', '"Let\'s not talk again."', '"It was nice talking to you!"'],
    correctIndex: 3,
    subject: 'BS-CLS',
    description: 'This is a standard, polite way to end a conversation as it expresses appreciation for the interaction.',
  ),
  QuizQuestion(
    id: 'cls385',
    question: 'What does breaking words into syllables help with?',
    options: ['Making speech slower', 'Pronouncing clearly', 'Avoiding hard words', 'Skipping long words'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Breaking a long or difficult word into syllables helps you sound out each part slowly, which is a fundamental strategy for clear pronunciation.',
  ),
  QuizQuestion(
    id: 'cls386',
    question: 'What should you avoid in a conversation?',
    options: ['Greeting the person', 'Making eye contact', 'Using filler words like "uh," "umm" repeatedly', 'Asking questions'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Overusing filler words is a bad habit that makes you sound less confident and can be distracting for the listener.',
  ),
  QuizQuestion(
    id: 'cls387',
    question: 'Why is it important to practice everyday conversations?',
    options: ['To learn new grammar rules', 'To build confidence and fluency in real situations', 'To memorise difficult words', 'To avoid speaking in public'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Practicing realistic dialogues helps you apply your knowledge in a practical context, reducing anxiety and improving your ability to speak naturally and fluently.',
  ),
  QuizQuestion(
    id: 'cls388',
    question: 'Which of the following is a good example of responding in a shop?',
    options: ['"Go away."', '"I don\'t want to talk."', '"I\'m looking for a blue shirt."', '"Why are you talking to me?"'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is a helpful and polite response that tells the shopkeeper exactly what you need, facilitating a productive interaction.',
  ),
  QuizQuestion(
    id: 'cls389',
    question: 'What is one tip for speaking confidently in public?',
    options: ['Look at the floor', 'Cross your arms', 'Make eye contact', 'Speak very fast'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Making eye contact with individuals in the audience creates a connection and projects confidence, even if you feel nervous inside.',
  ),
  QuizQuestion(
    id: 'cls390',
    question: 'What kind of body language shows nervousness?',
    options: ['Smiling naturally', 'Standing tall', 'Crossing arms and avoiding eye contact', 'Speaking clearly'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Closed-off postures (crossed arms) and looking away are classic non-verbal signs of anxiety, discomfort, or nervousness.',
  ),
  QuizQuestion(
    id: 'cls391',
    question: 'Which of these is a sentence starter to share your opinion?',
    options: ['"I am bored."', '"I forgot."', '"I think..."', '"I won\'t talk."'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: '"I think" is a standard and effective phrase for introducing a personal opinion in a conversation.',
  ),
  QuizQuestion(
    id: 'cls392',
    question: 'What should you do when expressing an opinion in a group?',
    options: ['Interrupt others', 'Shout your answer', 'Wait your turn and speak clearly', 'Stay silent'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Respecting conversational turn-taking (not interrupting) and speaking clearly ensures your opinion is heard and considered politely.',
  ),
  QuizQuestion(
    id: 'cls393',
    question: 'How can you improve English daily after training ends?',
    options: ['Stop speaking for a few weeks', 'Watch English movies without trying to understand', 'Practice speaking for 5-10 minutes each day', 'Learn only written grammar'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Consistency is key to language learning. A short, daily practice habit is far more effective than long, infrequent study sessions.',
  ),
  QuizQuestion(
    id: 'cls394',
    question: 'What is one way to check your speaking improvement?',
    options: ['Write an essay', 'Record your voice and listen', 'Watch cartoons', 'Don\'t speak at all'],
    correctIndex: 1,
    subject: 'BS-CLS',
    description: 'Recording yourself allows you to listen objectively to your pronunciation, fluency, and clarity, helping you identify areas for improvement that you might not notice while speaking.',
  ),
  QuizQuestion(
    id: 'cls395',
    question: 'What is a good personal goal for practicing English?',
    options: ['"I will write a diary once a month"', '"I will talk in English once a year"', '"I will talk to one friend in English every evening"', '"I will not speak English again."'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'This is a SMART goal: Specific (talk to one friend), Measurable (every evening), Achievable, Relevant, and Time-bound.',
  ),
  QuizQuestion(
    id: 'cls396',
    question: 'What should you do when someone asks you a question in a conversation?',
    options: ['Stay silent', 'Walk away', 'Respond politely and continue the talk', 'Change the topic immediately'],
    correctIndex: 2,
    subject: 'BS-CLS',
    description: 'Politely answering the question and then adding a related thought or asking a question back is the best way to keep the conversation going.',
  ),
];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BS-CSS Questions
const List<QuizQuestion> _cssQuestions = [
  QuizQuestion(
    id: 'css1',
    question: 'What is the most appropriate definition of success?',
    options: [
      'Becoming famous',
      'Buying expensive things',
      'Achieving your personal goals',
      'Getting only good marks',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Success is defined as the achievement of personal goals that are meaningful to you, not external validation or material possessions.',
  ),
  QuizQuestion(
    id: 'css2',
    question: 'Who played the biggest role in making Ajit Kumar successful?',
    options: [
      'Online coaching classes',
      'Availability of money and resources',
      'Ability to learn and teach others despite limited resources',
      'Going to the city for studies',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Ajit Kumar\'s success came from his ability to learn and teach others even with limited resources, showing that determination matters more than resources.',
  ),
  QuizQuestion(
    id: 'css3',
    question: 'What does Sunil Kumar\'s story teach us?',
    options: [
      'Farming is an unsuccessful career',
      'Success only comes from college education',
      'Sustainable and meaningful work can also be success',
      'Farming should be the last option',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Sunil Kumar\'s story demonstrates that success can be found in sustainable, meaningful work like farming, not just traditional corporate careers.',
  ),
  QuizQuestion(
    id: 'css4',
    question: 'Who passed the difficult collector exam after many failures?',
    options: [
      'Pinki Kumari',
      'Shalini Singh',
      'Rajni Singh',
      'Ajit Kumar',
    ],
    correctIndex: 0,
    subject: 'BS-CSS',
    description: 'Pinki Kumari successfully passed the collector examination after facing multiple failures, demonstrating persistence and resilience.',
  ),
  QuizQuestion(
    id: 'css5',
    question: 'In which situation can a person achieve success despite obstacles?',
    options: [
      'When they stop trying after failure',
      'When they depend on others for decisions',
      'When they change strategy after failures, maintain self-confidence, and keep trying continuously',
      'When they wait for luck without any initiative',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Success despite obstacles requires adapting strategies, maintaining self-confidence, and persistent effort even after failures.',
  ),
  QuizQuestion(
    id: 'css6',
    question: 'Why is comparing your success with others wrong?',
    options: [
      'Because everyone is competing',
      'It motivates you to win',
      'Because everyone has different goals and circumstances',
      'It helps you copy others',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Comparing success is meaningless because each person has unique goals, circumstances, and definitions of success.',
  ),
  QuizQuestion(
    id: 'css7',
    question: 'What does Shravan Kumar\'s story teach us?',
    options: [
      'Waiting is better than hard work',
      'Only rich people can be successful',
      'Success comes from hard work and skill',
      'Mobile repairing is easy work',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Shravan Kumar\'s story illustrates that success is achieved through dedication, hard work, and developing valuable skills.',
  ),
  QuizQuestion(
    id: 'css8',
    question: 'What is a major benefit of setting goals?',
    options: [
      'It lets you compare yourself with others',
      'It makes you rich instantly',
      'It gives you direction and motivation',
      'It guarantees you fame',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Setting goals provides clear direction and sustained motivation, helping you focus your efforts effectively.',
  ),
  QuizQuestion(
    id: 'css9',
    question: 'How did Pinki Kumari take her first step toward success?',
    options: [
      'Studying hard every day',
      'Complaining',
      'Speaking five English sentences daily',
      'Going to coaching classes',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Pinki Kumari started her journey to success by consistently speaking five English sentences every day, showing the power of small, consistent actions.',
  ),
  QuizQuestion(
    id: 'css10',
    question: 'How did J.K. Rowling finally achieve success?',
    options: [
      'Winning a lottery',
      'Having connections in publishing houses',
      'Continuing to try even after repeated rejections',
      'Social media promotion',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'J.K. Rowling achieved success through persistence, continuing to submit her work despite multiple rejections from publishers.',
  ),
  QuizQuestion(
    id: 'css11',
    question: 'Which obstacle is NOT mentioned in the study material?',
    options: [
      'Lack of money',
      'Slow internet speed',
      'Family pressure',
      'Self-doubt',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'While lack of money, family pressure, and self-doubt are mentioned as obstacles, slow internet speed is not discussed in the material.',
  ),
  QuizQuestion(
    id: 'css12',
    question: 'What is self-management?',
    options: [
      'Controlling others',
      'Controlling your work, emotions, and habits',
      'Avoiding all emotions',
      'Memorizing facts',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Self-management is the ability to regulate your own actions, emotions, and habits to achieve desired outcomes.',
  ),
  QuizQuestion(
    id: 'css13',
    question: 'Which student is practicing self-management?',
    options: [
      'One who studies only before exams',
      'One who delays work and blames others',
      'One who plans their day and completes work on time',
      'One who skips homework and plays',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'A student who plans their day and completes work on time demonstrates effective self-management skills.',
  ),
  QuizQuestion(
    id: 'css14',
    question: 'What is the best description of discipline?',
    options: [
      'Working only when you feel like it',
      'Working due to others\' pressure',
      'Doing necessary work even when you don\'t feel like it',
      'Waiting until the last moment',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Discipline means doing what needs to be done even when you lack motivation or desire to do it.',
  ),
  QuizQuestion(
    id: 'css15',
    question: 'What is the first step to understanding yourself better?',
    options: [
      'Asking friends what they like',
      'Knowing your routine',
      'Identifying your strengths and weaknesses',
      'Getting good grades',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Self-understanding begins with honestly identifying your personal strengths and areas for improvement.',
  ),
  QuizQuestion(
    id: 'css16',
    question: 'How can you discover your strengths?',
    options: [
      'Waiting for someone to tell you',
      'Avoiding new experiences',
      'Self-reflection, feedback, and trying new things',
      'Getting perfect scores in exams only',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Discovering strengths requires active self-reflection, seeking feedback from others, and experimenting with new activities.',
  ),
  QuizQuestion(
    id: 'css17',
    question: 'What does Geeta\'s story teach us?',
    options: [
      'Only talented people succeed',
      'Weaknesses cannot be changed',
      'Consistent practice can turn weaknesses into strengths',
      'Speaking English is more important than studying',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Geeta\'s story demonstrates that regular practice and effort can transform perceived weaknesses into strengths.',
  ),
  QuizQuestion(
    id: 'css18',
    question: 'What is a growth mindset?',
    options: [
      'Believing your abilities are fixed',
      'Thinking improvement is impossible',
      'Believing abilities can grow with effort',
      'Comparing yourself to others',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'A growth mindset is the belief that abilities and intelligence can be developed through dedication and hard work.',
  ),
  QuizQuestion(
    id: 'css19',
    question: 'What is the first step to making wise decisions?',
    options: [
      'Acting immediately',
      'Asking friends what to do',
      'Identifying the problem',
      'Ignoring the problem',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Wise decision-making starts with clearly identifying and understanding the problem you need to solve.',
  ),
  QuizQuestion(
    id: 'css20',
    question: 'Which is a mistake in decision-making?',
    options: [
      'Thinking about long-term consequences',
      'Acting without thinking',
      'Asking for advice',
      'Making a list of pros and cons',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Acting impulsively without thoughtful consideration is a common mistake in decision-making.',
  ),
  QuizQuestion(
    id: 'css21',
    question: 'How did Kabir make better decisions than Joya?',
    options: [
      'Acting hastily',
      'Following others',
      'Thinking and planning carefully',
      'Avoiding all decisions',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Kabir made better decisions by taking time to think through options and plan carefully before acting.',
  ),
  QuizQuestion(
    id: 'css22',
    question: 'Why is self-awareness important in career choices?',
    options: [
      'So you can copy successful people',
      'So you can avoid hard work',
      'So you can choose according to your qualities and values',
      'So you can be like everyone else',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Self-awareness helps you choose a career that aligns with your personal strengths, values, and interests.',
  ),
  QuizQuestion(
    id: 'css23',
    question: 'What should you do if you are uncertain about a decision?',
    options: [
      'Make a quick decision',
      'Avoid deciding',
      'Gather information and consider options',
      'Do what your friend did',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'When uncertain, gather relevant information and carefully evaluate your options before deciding.',
  ),
  QuizQuestion(
    id: 'css24',
    question: 'Which is an example of good self-awareness?',
    options: [
      'Blaming others for failure',
      'Knowing what you are good at and where you need improvement',
      'Always listening to friends\' advice',
      'Changing your goal every day',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Good self-awareness involves honestly recognizing both your strengths and areas needing improvement.',
  ),
  QuizQuestion(
    id: 'css25',
    question: 'Why is time considered a valuable resource?',
    options: [
      'Because it is free for everyone',
      'Because it can be saved for later',
      'Because everyone gets only 24 hours per day',
      'Because it is available in unlimited quantity',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Time is valuable because it is equally distributed and limited, with everyone receiving the same 24 hours each day.',
  ),
  QuizQuestion(
    id: 'css26',
    question: 'Why was Aman more successful than Rahul in daily life?',
    options: [
      'Aman played more and avoided studying',
      'Rahul studied non-stop',
      'Aman planned his day and avoided distractions',
      'Rahul used social media properly',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Aman succeeded by planning his daily schedule and avoiding distractions that waste time.',
  ),
  QuizQuestion(
    id: 'css27',
    question: 'Which is an example of wasting time?',
    options: [
      'Studying with concentration',
      'Taking planned short breaks',
      'Creating a daily timetable',
      'Scrolling social media for hours',
    ],
    correctIndex: 3,
    subject: 'BS-CSS',
    description: 'Spending excessive time on social media scrolling is a common way people waste valuable time.',
  ),
  QuizQuestion(
    id: 'css28',
    question: 'What is the main difference between dreams and goals?',
    options: [
      'Dreams are more important than goals',
      'Goals are desires without direction',
      'Dreams give direction, but goals give results',
      'Dreams are easier to achieve than goals',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Dreams provide vision and direction, while goals are specific targets with plans to achieve measurable results.',
  ),
  QuizQuestion(
    id: 'css29',
    question: 'What does "S" stand for in SMART goals?',
    options: [
      'Simple',
      'Strong',
      'Specific',
      'Speedy',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'In SMART goals, S stands for Specific - meaning the goal should be clear and well-defined.',
  ),
  QuizQuestion(
    id: 'css30',
    question: 'Which is a SMART goal?',
    options: [
      'I want to become rich',
      'I will complete 12th grade and prepare for NEET by 2026',
      'I hope to be successful someday',
      'I wish to read more books sometime',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'This goal is SMART because it is Specific, Measurable, Achievable, Relevant, and Time-bound with a clear deadline of 2026.',
  ),
  QuizQuestion(
    id: 'css31',
    question: 'Why is goal setting important?',
    options: [
      'It helps us waste less time',
      'It gives us a roadmap and keeps us focused',
      'It gives our dreams a shape',
      'It helps us copy others\' goals',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Goal setting provides a clear roadmap for action and helps maintain focus on what matters most.',
  ),
  QuizQuestion(
    id: 'css32',
    question: 'What is a major benefit of setting goals according to this lesson?',
    options: [
      'It makes studying unnecessary',
      'It creates confusion',
      'It helps track progress and builds confidence',
      'It wastes time',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Setting goals enables you to measure your progress and builds self-confidence as you achieve milestones.',
  ),
  QuizQuestion(
    id: 'css33',
    question: 'What is problem-solving?',
    options: [
      'Complaining',
      'Ignoring problems',
      'Finding solutions to problems',
      'Depending on others',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Problem-solving is the process of identifying issues and finding effective solutions to address them.',
  ),
  QuizQuestion(
    id: 'css34',
    question: 'What is logical thinking?',
    options: [
      'Making decisions without thinking',
      'Making decisions based on emotions',
      'Making decisions based on facts and logic',
      'Copying others',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Logical thinking involves using facts, evidence, and rational analysis to make decisions.',
  ),
  QuizQuestion(
    id: 'css35',
    question: 'What is the first step in the problem-solving process?',
    options: [
      'Taking immediate action',
      'Thinking of solutions',
      'Identifying the problem',
      'Seeing the results',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Effective problem-solving begins with correctly identifying and defining the problem to be solved.',
  ),
  QuizQuestion(
    id: 'css36',
    question: 'What is the next step after choosing a solution?',
    options: [
      'Forgetting the problem',
      'Taking action and observing results',
      'Giving orders to others',
      'Starting over',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'After selecting a solution, you must implement it and evaluate the outcomes.',
  ),
  QuizQuestion(
    id: 'css37',
    question: 'What does the "3-second rule" suggest?',
    options: [
      'Run away',
      'Count to 3',
      'Take a deep breath and think before reacting',
      'Speak quickly',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'The 3-second rule advises pausing to breathe and think before responding impulsively to a situation.',
  ),
  QuizQuestion(
    id: 'css38',
    question: 'Which is an example of logical thinking?',
    options: [
      'Shouting in anger',
      'Quitting studying',
      'Making a pros-cons list before deciding',
      'Buying things without thinking',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Creating a pros and cons list demonstrates logical thinking by evaluating options systematically.',
  ),
  QuizQuestion(
    id: 'css39',
    question: 'How should you logically handle peer pressure?',
    options: [
      'Agree to avoid conflict',
      'Stay silent',
      'Think about consequences and politely refuse',
      'Agree without thinking',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Handle peer pressure by considering outcomes and politely but firmly declining when necessary.',
  ),
  QuizQuestion(
    id: 'css40',
    question: 'What is the result of impulsive decisions?',
    options: [
      'Happiness',
      'Better relationships',
      'Regret and bad outcomes',
      'Clear communication',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Impulsive decisions often lead to regret and negative consequences because they lack thoughtful consideration.',
  ),
  QuizQuestion(
    id: 'css41',
    question: 'What problem can be solved with a daily routine?',
    options: [
      'Peer pressure',
      'Time management',
      'Stress',
      'Memory',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'A daily routine helps solve time management problems by organizing activities efficiently.',
  ),
  QuizQuestion(
    id: 'css42',
    question: 'Why is logical thinking important?',
    options: [
      'To ignore emotions',
      'To increase problems',
      'To make wise decisions',
      'To make fewer friends',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Logical thinking enables wise, well-reasoned decisions that lead to better outcomes.',
  ),
  QuizQuestion(
    id: 'css43',
    question: 'What is change?',
    options: [
      'Doing the same thing every day',
      'Becoming something new or different',
      'Avoiding new experiences',
      'Refusing to move forward',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Change involves becoming different, whether in circumstances, behaviors, or perspectives.',
  ),
  QuizQuestion(
    id: 'css44',
    question: 'Which is an example of change?',
    options: [
      'Watching the same TV show daily',
      'Eating your favorite food repeatedly',
      'Going to a new school',
      'Talking to the same friend every day',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Moving to a new school represents a significant change in environment and routine.',
  ),
  QuizQuestion(
    id: 'css45',
    question: 'Why is adapting to change important?',
    options: [
      'It keeps everything the same',
      'It prevents learning new skills',
      'It helps us grow and be successful',
      'It avoids hard work',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Adapting to change enables personal growth and success in evolving circumstances.',
  ),
  QuizQuestion(
    id: 'css46',
    question: 'Why do people resist change?',
    options: [
      'They like challenges',
      'They fear failure and uncertainty',
      'They want to grow quickly',
      'They like surprises',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'People often resist change due to fear of failure, uncertainty, and the unknown.',
  ),
  QuizQuestion(
    id: 'css47',
    question: 'Who welcomes change?',
    options: [
      'I will never do anything new',
      'Learning new things will advance me',
      'Everything should remain the same',
      'I don\'t care',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'A growth-oriented person sees learning new things as a path to advancement.',
  ),
  QuizQuestion(
    id: 'css48',
    question: 'How does change lead to growth?',
    options: [
      'By confusing us',
      'By helping us avoid work',
      'By giving new experiences and lessons',
      'By keeping us in our comfort zone',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Change provides new experiences and lessons that contribute to personal development and growth.',
  ),
  QuizQuestion(
    id: 'css49',
    question: 'What is a good way to adapt to change?',
    options: [
      'Stay negative',
      'Be flexible and take small steps',
      'Refuse to cooperate',
      'Ignore the situation',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Adapting to change effectively requires flexibility and taking manageable, small steps forward.',
  ),
  QuizQuestion(
    id: 'css50',
    question: 'What does staying positive during change mean?',
    options: [
      'Pretend nothing happened',
      'Complain about everything',
      'Thinking things can get better',
      'Blaming others',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Staying positive means maintaining an optimistic outlook that circumstances can improve.',
  ),
  QuizQuestion(
    id: 'css51',
    question: 'What is an example of turning change into opportunity?',
    options: [
      'Not making new friends at a new school',
      'Giving up after a failure',
      'Learning a new skill after losing a job',
      'Ignoring your goals',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Learning new skills after job loss demonstrates turning an adverse change into a growth opportunity.',
  ),
  QuizQuestion(
    id: 'css52',
    question: 'How should we face change?',
    options: [
      'Run away from it',
      'See it as an opportunity for growth',
      'Live in the past',
      'Not talk about it',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Change should be viewed as a chance for personal growth and development rather than a threat.',
  ),
  QuizQuestion(
    id: 'css53',
    question: 'What is communication?',
    options: [
      'Only writing notes',
      'Only speaking loudly',
      'Sharing thoughts, feelings, and information',
      'Copying others',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Communication is the process of sharing ideas, emotions, and information between people.',
  ),
  QuizQuestion(
    id: 'css54',
    question: 'Which is poor communication?',
    options: [
      'Could you help me, please?',
      'Keep the file on the other shelf.',
      'Whatever... leave it.',
      'I will call you later.',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Vague, dismissive responses like "whatever... leave it" indicate poor communication.',
  ),
  QuizQuestion(
    id: 'css55',
    question: 'What is included in verbal communication?',
    options: [
      'Only body language',
      'Speaking, tone, and clarity',
      'Only gestures',
      'Only messages',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Verbal communication involves spoken words, vocal tone, and clear expression.',
  ),
  QuizQuestion(
    id: 'css56',
    question: 'What is essential for effective communication?',
    options: [
      'Using difficult words',
      'Clear words and polite tone',
      'Speaking without listening',
      'Speaking very fast',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Effective communication requires clarity in word choice and politeness in tone.',
  ),
  QuizQuestion(
    id: 'css57',
    question: 'What identifies an active listener?',
    options: [
      'Interrupting in between',
      'Looking at phone',
      'Nodding and asking questions',
      'Changing the subject',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Active listeners show engagement through nonverbal cues like nodding and asking relevant questions.',
  ),
  QuizQuestion(
    id: 'css58',
    question: 'What is body language?',
    options: [
      'A type of sign language',
      'Posture, gestures, and facial expressions',
      'Speaking loudly',
      'Lip reading',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Body language includes physical behaviors like posture, hand movements, and facial expressions.',
  ),
  QuizQuestion(
    id: 'css59',
    question: 'Standing with folded arms indicates:',
    options: [
      'Happiness',
      'Confidence',
      'Defensive attitude',
      'Enthusiasm',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Crossed arms often signal defensiveness, discomfort, or resistance.',
  ),
  QuizQuestion(
    id: 'css60',
    question: 'Which are good non-verbal communication in conversation?',
    options: [
      'Avoiding eye contact',
      'Playing with things',
      'Sitting slumped',
      'Smiling and making eye contact',
    ],
    correctIndex: 3,
    subject: 'BS-CSS',
    description: 'Smiling and maintaining appropriate eye contact are positive non-verbal communication cues.',
  ),
  QuizQuestion(
    id: 'css61',
    question: 'If someone misunderstands your message, what should you do?',
    options: [
      'Blame them',
      'Walk away',
      'Stay calm and clarify',
      'Shout loudly',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'When misunderstandings occur, remain composed and provide clarification.',
  ),
  QuizQuestion(
    id: 'css62',
    question: 'Why is listening important in communication?',
    options: [
      'It makes you look calm',
      'Misunderstandings are reduced',
      'You get more time to speak',
      'It is just etiquette',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Effective listening reduces misunderstandings and improves communication quality.',
  ),
  QuizQuestion(
    id: 'css63',
    question: 'Why do humans need to connect with others?',
    options: [
      'To compete with everyone',
      'To receive support and understanding',
      'To stay alone',
      'To avoid problems',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Humans have an inherent need for social connection, support, and mutual understanding.',
  ),
  QuizQuestion(
    id: 'css64',
    question: 'How did Riya build strong social relationships?',
    options: [
      'Ignoring classmates',
      'Sitting alone in class',
      'Smiling, listening, and helping others',
      'Avoiding school activities',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Riya built strong relationships through positive behaviors like smiling, active listening, and helping others.',
  ),
  QuizQuestion(
    id: 'css65',
    question: 'What is a "first impression"?',
    options: [
      'How you meet someone for the last time',
      'Others\' opinions on social media',
      'Your behavior when meeting someone for the first time',
      'How fast you speak',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'A first impression is the initial perception formed about a person based on their behavior during first encounters.',
  ),
  QuizQuestion(
    id: 'css66',
    question: 'What helps create a good first impression?',
    options: [
      'Not making eye contact',
      'Wearing dirty clothes',
      'Speaking with clear and polite tone',
      'Ignoring questions',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Speaking clearly and politely helps create a positive first impression.',
  ),
  QuizQuestion(
    id: 'css67',
    question: 'What helps build trust in relationships?',
    options: [
      'Making fun of others',
      'Breaking promises',
      'Lying when needed',
      'Being honest and keeping promises',
    ],
    correctIndex: 3,
    subject: 'BS-CSS',
    description: 'Trust is built through consistent honesty and following through on commitments.',
  ),
  QuizQuestion(
    id: 'css68',
    question: 'How is trust broken?',
    options: [
      'Helping during difficult times',
      'Listening patiently',
      'Lying and not keeping promises',
      'Sharing useful suggestions',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Trust is broken through dishonesty and failure to keep promises.',
  ),
  QuizQuestion(
    id: 'css69',
    question: 'What is "small talk"?',
    options: [
      'Serious debate',
      'Loud arguing',
      'Light conversation to start a connection',
      'Talking only to successful friends',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Small talk is casual, light conversation used to initiate social connections.',
  ),
  QuizQuestion(
    id: 'css70',
    question: 'What is a good example of small talk?',
    options: [
      'Your idea is wrong!',
      'I am busy, go away.',
      'Hello, how was your day?',
      'Saying nothing',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'A simple greeting asking about someone\'s day is an appropriate example of small talk.',
  ),
  QuizQuestion(
    id: 'css71',
    question: 'Why is showing respect important in conversation?',
    options: [
      'To win arguments',
      'To make others feel inferior',
      'To force your opinion by shouting',
      'To build strong relationships and avoid conflicts',
    ],
    correctIndex: 3,
    subject: 'BS-CSS',
    description: 'Respectful communication builds stronger relationships and prevents unnecessary conflicts.',
  ),
  QuizQuestion(
    id: 'css72',
    question: 'Which behavior is disrespectful?',
    options: [
      'Listening without interrupting',
      'Saying "please" and "thank you"',
      'Shouting when disagreeing',
      'Staying calm and expressing views',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Shouting during disagreements is disrespectful and unproductive.',
  ),
  QuizQuestion(
    id: 'css73',
    question: 'Why are presentation skills important?',
    options: [
      'To read faster',
      'To speak without preparation',
      'To express thoughts clearly and confidently',
      'To avoid school work',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Presentation skills enable clear, confident expression of ideas to others.',
  ),
  QuizQuestion(
    id: 'css74',
    question: 'What makes a good presentation?',
    options: [
      'Speaking in a low tone',
      'Looking away',
      'Clear structure with confidence',
      'Reading from slides',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Good presentations combine clear organization with confident delivery.',
  ),
  QuizQuestion(
    id: 'css75',
    question: 'What is the first part of a presentation?',
    options: [
      'Main body',
      'Conclusion',
      'Closing',
      'Beginning',
    ],
    correctIndex: 3,
    subject: 'BS-CSS',
    description: 'Presentations typically begin with an introduction or opening section.',
  ),
  QuizQuestion(
    id: 'css76',
    question: 'What happens in the main body of a presentation?',
    options: [
      'Unrelated talk',
      'Repetition of topic',
      'Clear explanation of main points',
      'Audience questions',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'The main body presents and explains the key points clearly and systematically.',
  ),
  QuizQuestion(
    id: 'css77',
    question: 'What is positive body language?',
    options: [
      'Looking down',
      'Folding arms',
      'Speaking with eye contact and using gestures',
      'Expressionless face',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Positive body language includes maintaining eye contact and using purposeful gestures.',
  ),
  QuizQuestion(
    id: 'css78',
    question: 'What is the importance of tone?',
    options: [
      'Helps with memorization',
      'Affects audience interest and understanding',
      'Replaces content',
      'Only for humor',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Vocal tone significantly influences how the audience receives and understands the message.',
  ),
  QuizQuestion(
    id: 'css79',
    question: 'What is a common mistake in presentations?',
    options: [
      'Speaking clearly',
      'Using hand gestures',
      'Speaking too fast or too slow',
      'Smiling at the audience',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Poor pacing, either too fast or too slow, is a frequent presentation error.',
  ),
  QuizQuestion(
    id: 'css80',
    question: 'How to overcome mistakes in presentations?',
    options: [
      'Speak without planning',
      'Avoid eye contact',
      'Practice and speak clearly',
      'Read long paragraphs',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Mistakes can be reduced through practice and focusing on clear speech.',
  ),
  QuizQuestion(
    id: 'css81',
    question: 'How can confidence be increased?',
    options: [
      'Thinking negative thoughts',
      'Deep breathing and preparation',
      'Ignoring the audience',
      'Memorizing everything',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Confidence grows with proper preparation and calming techniques like deep breathing.',
  ),
  QuizQuestion(
    id: 'css82',
    question: 'How to end a presentation?',
    options: [
      'Leave silently',
      'Repeat everything',
      'Conclude with a summary and message',
      'Say nothing',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Effective presentations end with a clear summary and final message.',
  ),
  QuizQuestion(
    id: 'css83',
    question: 'What does a confident speaker do?',
    options: [
      'Mumbles and avoids eye contact',
      'Speaks clearly and makes eye contact',
      'Hides behind notes',
      'Avoids questions',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Confident speakers communicate clearly and maintain appropriate eye contact with listeners.',
  ),
  QuizQuestion(
    id: 'css84',
    question: 'Why is confidence important while speaking?',
    options: [
      'To avoid speaking',
      'To express thoughts clearly',
      'To always speak loudly',
      'To interrupt others',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Confidence enables clear expression of thoughts and ideas to others.',
  ),
  QuizQuestion(
    id: 'css85',
    question: 'What is a sign of nervousness?',
    options: [
      'Making eye contact',
      'Smiling while speaking',
      'Sweating and avoiding eyes',
      'Using hand gestures',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Physical signs like sweating and eye avoidance often indicate nervousness.',
  ),
  QuizQuestion(
    id: 'css86',
    question: 'Why do people get nervous when speaking?',
    options: [
      'They enjoy speaking',
      'They are very confident',
      'They fear criticism',
      'They know the topic well',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Fear of negative evaluation or criticism is a common cause of speaking anxiety.',
  ),
  QuizQuestion(
    id: 'css87',
    question: 'What is an easy way to reduce fear?',
    options: [
      'Avoiding practice',
      'Speaking very fast',
      'Taking deep breaths',
      'Staying silent',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Deep breathing is a simple technique that can help reduce anxiety and fear.',
  ),
  QuizQuestion(
    id: 'css88',
    question: 'What effect does daily practice have on confidence?',
    options: [
      'Increases fear more',
      'Slowly builds confidence',
      'Makes you forget the topic',
      'Increases fear',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Regular daily practice gradually builds confidence over time.',
  ),
  QuizQuestion(
    id: 'css89',
    question: 'What helps build confidence?',
    options: [
      'Thinking you will fail',
      'Practicing regularly',
      'Hiding in class',
      'Avoiding conversation',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Consistent practice is a key factor in developing confidence.',
  ),
  QuizQuestion(
    id: 'css90',
    question: 'What is a good daily habit to build confidence?',
    options: [
      'Avoiding eye contact',
      'Staying silent in groups',
      'Smiling and greeting',
      'Waiting for others to speak',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Daily habits like smiling and greeting others help build social confidence.',
  ),
  QuizQuestion(
    id: 'css91',
    question: 'What should you focus on while speaking?',
    options: [
      'Your fear',
      'Your mistakes',
      'The message you want to convey',
      'Others\' speaking style',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Focus on delivering your message effectively rather than on fear or mistakes.',
  ),
  QuizQuestion(
    id: 'css92',
    question: 'What to do before speaking to calm yourself?',
    options: [
      'Shout loudly',
      'Run away',
      'Take deep breaths and think positively',
      'Close eyes and stay quiet',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Calm yourself before speaking with deep breathing and positive thinking.',
  ),
  QuizQuestion(
    id: 'css93',
    question: 'Why are good relationships important in life?',
    options: [
      'To avoid work',
      'To become popular',
      'For support, happiness, and growth',
      'To get everything',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Good relationships provide essential support, happiness, and opportunities for personal growth.',
  ),
  QuizQuestion(
    id: 'css94',
    question: 'What does trusting someone mean?',
    options: [
      'Watching their actions',
      'Having confidence they will keep their promise',
      'Ignoring their mistakes',
      'Talking only when needed',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Trust means having confidence that someone will follow through on their commitments.',
  ),
  QuizQuestion(
    id: 'css95',
    question: 'What is a sign of respectful conversation?',
    options: [
      'Interrupting repeatedly',
      'Avoiding eye contact',
      'Listening carefully and responding politely',
      'Speaking without thinking',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Respectful conversation involves attentive listening and courteous responses.',
  ),
  QuizQuestion(
    id: 'css96',
    question: 'What can break trust?',
    options: [
      'Helping others',
      'Keeping promises',
      'Lying or breaking promises',
      'Saying thank you',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Trust is broken through dishonesty and failure to keep promises.',
  ),
  QuizQuestion(
    id: 'css97',
    question: 'What is the first step to resolving differences?',
    options: [
      'Leaving angrily',
      'Blaming the other person',
      'Listening carefully to what is said',
      'Ignoring the matter',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Active listening is the essential first step in resolving disagreements.',
  ),
  QuizQuestion(
    id: 'css98',
    question: 'What is a good example of helping?',
    options: [
      'Ignoring someone asking for help',
      'Making fun of them',
      'Explaining a topic to a struggling student',
      'Staying away from group work',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Helping others learn is a positive example of providing assistance.',
  ),
  QuizQuestion(
    id: 'css99',
    question: 'How do small acts of kindness help society?',
    options: [
      'They waste time',
      'They create confusion',
      'They bring positive change and connection',
      'Nobody notices them',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Small kind acts accumulate to create positive social change and strengthen community bonds.',
  ),
  QuizQuestion(
    id: 'css100',
    question: 'What does ethics mean?',
    options: [
      'Do whatever feels good',
      'Rules of right and wrong',
      'Only following friends\' advice',
      'Making no decisions',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Ethics are moral principles that govern what is right and wrong behavior.',
  ),
  QuizQuestion(
    id: 'css101',
    question: 'What are values?',
    options: [
      'Laws of the country',
      'Only teachers\' words',
      'Personal beliefs that guide behavior',
      'What others tell you to do',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Values are personal beliefs that influence and direct behavior and choices.',
  ),
  QuizQuestion(
    id: 'css102',
    question: 'What most influences ethical decisions?',
    options: [
      'TV shows',
      'Upbringing and personal values',
      'Expensive gifts',
      'Power',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Ethical decisions are primarily shaped by upbringing and personal value systems.',
  ),
  QuizQuestion(
    id: 'css103',
    question: 'What is an example of honesty and integrity?',
    options: [
      'Taking someone else\'s achievement quietly',
      'Telling a teacher about your mistake',
      'Hiding a stolen item',
      'Copying others',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Admitting mistakes to authority figures demonstrates honesty and integrity.',
  ),
  QuizQuestion(
    id: 'css104',
    question: 'What can peer pressure do?',
    options: [
      'Always helps us',
      'Increases thinking speed',
      'Forces us to make wrong decisions',
      'Has no effect on anyone',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Peer pressure can negatively influence people to make poor decisions.',
  ),
  QuizQuestion(
    id: 'css105',
    question: 'How to avoid negative pressure?',
    options: [
      'Join the crowd',
      'Stay silent',
      'Say "no" with confidence',
      'Stay away from all friends',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Confidently saying "no" is an effective way to resist negative peer pressure.',
  ),
  QuizQuestion(
    id: 'css106',
    question: 'What is an example of ethical behavior in the workplace?',
    options: [
      'Lying to the boss',
      'Ignoring the team\'s effort',
      'Giving credit to the whole team',
      'Taking hidden breaks',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Giving proper credit to team members demonstrates workplace ethics.',
  ),
  QuizQuestion(
    id: 'css107',
    question: 'What does an ethical person typically do?',
    options: [
      'Breaks promises for profit',
      'Only chooses easy paths',
      'Does the right thing even in difficulty',
      'Follows the crowd',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Ethical individuals maintain their principles even when facing challenges.',
  ),
  QuizQuestion(
    id: 'css108',
    question: 'Why are honesty and integrity important?',
    options: [
      'They create fear',
      'They build trust and respect',
      'They help in cheating',
      'They bring quick fame',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Honesty and integrity are essential for building trust and earning respect.',
  ),
  QuizQuestion(
    id: 'css109',
    question: 'What is the main purpose of creativity?',
    options: [
      'Only remembering facts',
      'Following rules',
      'Thinking in new and useful ways',
      'Copying others',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Creativity involves generating novel and valuable ideas or solutions.',
  ),
  QuizQuestion(
    id: 'css110',
    question: 'What is a real-life example of creativity?',
    options: [
      'Repeating someone else\'s idea',
      'Creating a study schedule to save time',
      'Leaving the problem to someone else',
      'Reading textbooks repeatedly',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Creating an efficient study schedule demonstrates practical creativity in daily life.',
  ),
  QuizQuestion(
    id: 'css111',
    question: 'What does "Creativity is only for successful artists" ignore?',
    options: [
      'Artists are not creative',
      'Every person can be creative in daily life',
      'Only writers are creative',
      'Creativity is not needed',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'This statement ignores that everyone can apply creativity in everyday situations.',
  ),
  QuizQuestion(
    id: 'css112',
    question: 'Which technique organizes thoughts?',
    options: [
      'Mind mapping',
      'Sleeping',
      'Guessing',
      'Crying',
    ],
    correctIndex: 0,
    subject: 'BS-CSS',
    description: 'Mind mapping is a visual technique for organizing thoughts and ideas.',
  ),
  QuizQuestion(
    id: 'css113',
    question: 'What is the purpose of "thinking outside the box"?',
    options: [
      'Thinking in old ways',
      'Strictly following rules',
      'Finding new and unique solutions',
      'Avoiding problems',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Thinking outside the box means finding innovative and unconventional solutions.',
  ),
  QuizQuestion(
    id: 'css114',
    question: 'What is an example of reverse thinking?',
    options: [
      'Thinking about a solution\'s failure',
      'Adopting a common perspective',
      'Starting with the solution and reaching the problem',
      'Ignoring the problem',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Reverse thinking involves working backward from the solution to identify the problem.',
  ),
  QuizQuestion(
    id: 'css115',
    question: 'Which statement about creativity is incorrect?',
    options: [
      'Only children are creative',
      'Some people are born creative',
      'Anyone can become creative with practice',
      'Creativity has no use',
    ],
    correctIndex: 3,
    subject: 'BS-CSS',
    description: 'The statement that creativity has no use is incorrect; creativity is highly valuable.',
  ),
  QuizQuestion(
    id: 'css116',
    question: 'What does creativity improve?',
    options: [
      'Repetitive work',
      'Problem-solving in new ways',
      'Remembering information',
      'Avoiding challenges',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Creativity enhances problem-solving by generating innovative approaches.',
  ),
  QuizQuestion(
    id: 'css117',
    question: 'What is an example of a creative solution in a low-resource school?',
    options: [
      'Using only computer projectors',
      'Repeating old textbooks',
      'Making teaching tools from reused materials',
      'Making students memorize everything',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Creating teaching tools from recycled materials demonstrates creativity with limited resources.',
  ),
  QuizQuestion(
    id: 'css118',
    question: 'Which technique connects unrelated ideas?',
    options: [
      'Mind mapping',
      'Random connection',
      'Making notes',
      'Daydreaming',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Random connection is a technique that links seemingly unrelated concepts to generate new ideas.',
  ),
  QuizQuestion(
    id: 'css119',
    question: 'What is the benefit of staying calm in stressful situations?',
    options: [
      'You don\'t look serious',
      'Helps make better decisions',
      'Increases confusion',
      'Makes others angry',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Remaining calm under stress enables clearer thinking and better decision-making.',
  ),
  QuizQuestion(
    id: 'css120',
    question: 'What is a good way to handle stress?',
    options: [
      'Ignoring problems',
      'Shouting at others',
      'Taking deep breaths',
      'Running from responsibilities',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Deep breathing is an effective technique for managing stress.',
  ),
  QuizQuestion(
    id: 'css121',
    question: 'What is an example of positive self-talk?',
    options: [
      'I can never do this',
      'This is not in my control',
      'This is difficult, but I will try',
      'Everyone is better than me',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Positive self-talk acknowledges challenges while maintaining determination to try.',
  ),
  QuizQuestion(
    id: 'css122',
    question: 'How can you perform well under pressure?',
    options: [
      'By panicking',
      'By staying calm and thinking clearly',
      'By blaming others',
      'By ignoring the situation',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Good performance under pressure requires calmness and clear thinking.',
  ),
  QuizQuestion(
    id: 'css123',
    question: 'What habit leads to long-term happiness?',
    options: [
      'Complaining all the time',
      'Working without breaks',
      'Expressing gratitude and social connection',
      'Staying away from experiences',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Long-term happiness comes from practicing gratitude and maintaining social connections.',
  ),
  QuizQuestion(
    id: 'css124',
    question: 'Which daily habit helps reduce stress?',
    options: [
      'Time management',
      'Skipping meals',
      'Distance from friends',
      'Less sleep',
    ],
    correctIndex: 0,
    subject: 'BS-CSS',
    description: 'Good time management reduces stress by helping organize responsibilities effectively.',
  ),
  QuizQuestion(
    id: 'css125',
    question: 'What does positive thinking do?',
    options: [
      'Increases anger',
      'Can replace negative thinking',
      'Increases pressure',
      'Creates laziness',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Positive thinking can help transform and replace negative thought patterns.',
  ),
  QuizQuestion(
    id: 'css126',
    question: 'What is a good way to handle anger calmly?',
    options: [
      'Shouting loudly',
      'Blaming others',
      'Walking away for a while',
      'Ignoring your feelings',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Taking a temporary break or walk helps manage anger constructively.',
  ),
  QuizQuestion(
    id: 'css127',
    question: 'What is the difference between stress and pressure?',
    options: [
      'Pressure matters less',
      'Stress brings success',
      'Pressure involves high expectations',
      'Stress only happens to adults',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Pressure typically involves high expectations and demands for performance.',
  ),
  QuizQuestion(
    id: 'css128',
    question: 'What is a calm way to express anger?',
    options: [
      'Shouting',
      'Dropping the topic',
      'Sarcasm',
      'Using "I" statements',
    ],
    correctIndex: 3,
    subject: 'BS-CSS',
    description: '"I" statements (e.g., "I feel frustrated when...") express anger constructively without attacking others.',
  ),
  QuizQuestion(
    id: 'css129',
    question: 'What are personal resources?',
    options: [
      'Only money and land',
      'Time, money, skills, and knowledge',
      'Only purchasable items',
      'None of these',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Personal resources include intangible assets like time, skills, and knowledge, as well as material resources like money.',
  ),
  QuizQuestion(
    id: 'css130',
    question: 'Why is resource management necessary?',
    options: [
      'To waste time',
      'To show talent',
      'To achieve success and avoid stress',
      'To spend money quickly',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Managing resources effectively helps achieve success while minimizing stress.',
  ),
  QuizQuestion(
    id: 'css131',
    question: 'Which is a personal resource?',
    options: [
      'Mobile phone',
      'Public speaking skill',
      'Car model',
      'Furniture',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Public speaking is a personal skill resource, unlike physical objects.',
  ),
  QuizQuestion(
    id: 'css132',
    question: 'What is a good time management habit?',
    options: [
      'Sleeping all day',
      'Making a to-do list',
      'Skipping important tasks',
      'Playing during study time',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Creating to-do lists helps organize and prioritize tasks effectively.',
  ),
  QuizQuestion(
    id: 'css133',
    question: 'What does the 20-30-50 rule mean?',
    options: [
      'Spend 50% on entertainment',
      'Save 50%, spend 50%',
      '50% for needs, 30% for wants, 20% for savings',
      'Put everything into savings',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'The 20-30-50 rule suggests allocating 50% to needs, 30% to wants, and 20% to savings.',
  ),
  QuizQuestion(
    id: 'css134',
    question: 'What is one benefit of saving money?',
    options: [
      'Cannot spend',
      'You will forget where you kept it',
      'Helps in emergency situations',
      'It will get lost',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Savings provide financial security and resources for emergency situations.',
  ),
  QuizQuestion(
    id: 'css135',
    question: 'Which habit is considered bad for time management?',
    options: [
      'Planning the day',
      'Watching TV for 5 hours before studying',
      'Using a clock',
      'Writing goals',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Excessive entertainment before important tasks wastes valuable time.',
  ),
  QuizQuestion(
    id: 'css136',
    question: 'How can students use free resources?',
    options: [
      'Buying expensive items',
      'From libraries and online lessons',
      'Not doing homework',
      'Depending only on teachers',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Libraries and free online resources provide valuable learning materials without cost.',
  ),
  QuizQuestion(
    id: 'css137',
    question: 'What is the best use of personal strengths?',
    options: [
      'Hiding them',
      'Comparing with others',
      'Using them to help yourself and others',
      'Ignoring them',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Personal strengths should be utilized for self-improvement and helping others.',
  ),
  QuizQuestion(
    id: 'css138',
    question: 'What identifies a resourceful person?',
    options: [
      'Spending without thinking',
      'Getting frustrated easily',
      'Planning regularly, learning, and saving',
      'Delaying every task',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Resourceful people consistently plan, learn, and practice financial discipline.',
  ),
  QuizQuestion(
    id: 'css139',
    question: 'What is the first step to developing emotional intelligence?',
    options: [
      'Controlling others\' emotions',
      'Ignoring emotions',
      'Recognizing your own emotions',
      'Speaking loudly in arguments',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Emotional intelligence begins with self-awareness of your own emotional states.',
  ),
  QuizQuestion(
    id: 'css140',
    question: 'Which is NOT a component of EI?',
    options: [
      'Self-awareness',
      'Motivation',
      'Arrogance',
      'Empathy',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Arrogance is not a component of emotional intelligence; it hinders emotional awareness.',
  ),
  QuizQuestion(
    id: 'css141',
    question: 'Which technique helps in managing emotions?',
    options: [
      'Shouting loudly',
      'Taking deep breaths',
      'Avoiding conversation',
      'Changing the subject',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Deep breathing is an effective technique for emotional regulation.',
  ),
  QuizQuestion(
    id: 'css142',
    question: 'What is empathy?',
    options: [
      'Quickly solving difficult questions',
      'Controlling your emotions',
      'Understanding others\' feelings',
      'Winning arguments',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Empathy is the ability to understand and share the feelings of others.',
  ),
  QuizQuestion(
    id: 'css143',
    question: 'What is an example of emotional self-regulation?',
    options: [
      'Walking away in anger',
      'Ignoring everyone',
      'Responding calmly after deep breathing',
      'Shouting in frustration',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Self-regulation involves managing emotional responses, such as responding calmly instead of reacting impulsively.',
  ),
  QuizQuestion(
    id: 'css144',
    question: 'What is a sign of empathy in conversation?',
    options: [
      'Interrupting the speaker',
      'Avoiding eye contact',
      'Giving advice without listening',
      'Making eye contact and nodding',
    ],
    correctIndex: 3,
    subject: 'BS-CSS',
    description: 'Attentive behaviors like eye contact and nodding demonstrate empathic listening.',
  ),
  QuizQuestion(
    id: 'css145',
    question: 'What does motivation mean in EI?',
    options: [
      'Being forced to do something',
      'Working only for rewards',
      'Internal drive to improve',
      'Working only for praise',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'In emotional intelligence, motivation refers to intrinsic drive for self-improvement.',
  ),
  QuizQuestion(
    id: 'css146',
    question: 'What to do when receiving negative feedback?',
    options: [
      'Argue immediately',
      'Leave angrily',
      'Stay calm and listen carefully',
      'Criticize in return',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Respond to negative feedback with calm, attentive listening rather than defensiveness.',
  ),
  QuizQuestion(
    id: 'css147',
    question: 'What is the appropriate response in a stressful situation?',
    options: [
      'Panicking',
      'Taking deep breaths and understanding the situation',
      'Blaming others',
      'Avoiding thinking about it',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Manage stress by pausing to breathe and assess the situation calmly.',
  ),
  QuizQuestion(
    id: 'css148',
    question: 'Which skill helps build strong relationships at home, school, or work?',
    options: [
      'Emotional intelligence',
      'Memorizing facts',
      'Avoiding responsibilities',
      'Always winning conversations',
    ],
    correctIndex: 0,
    subject: 'BS-CSS',
    description: 'Emotional intelligence enables stronger, healthier relationships in all settings.',
  ),
  QuizQuestion(
    id: 'css149',
    question: 'What is the first step to resolving conflict?',
    options: [
      'Compromise',
      'Listening to the other person',
      'Sticking to your point',
      'Walking away',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Conflict resolution begins with actively listening to the other person\'s perspective.',
  ),
  QuizQuestion(
    id: 'css150',
    question: 'What is a constructive way to handle conflict?',
    options: [
      'Blaming',
      'Speaking loudly',
      'Listening and finding solutions',
      'Ignoring',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Constructive conflict resolution involves listening and collaboratively finding solutions.',
  ),
  QuizQuestion(
    id: 'css151',
    question: 'What is active listening?',
    options: [
      'Cutting off speech',
      'Nodding, asking questions, paying attention',
      'Avoiding eye contact',
      'Continuously speaking',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Active listening involves engaging nonverbally and asking clarifying questions.',
  ),
  QuizQuestion(
    id: 'css152',
    question: 'Which is NOT part of the conflict resolution process?',
    options: [
      'Listening',
      'Understanding',
      'Shouting',
      'Compromising',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Shouting is counterproductive and not part of effective conflict resolution.',
  ),
  QuizQuestion(
    id: 'css153',
    question: 'Why use "I" statements?',
    options: [
      'To criticize others',
      'To express feelings peacefully',
      'To win arguments',
      'To change the subject',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: '"I" statements allow expression of feelings without attacking or blaming others.',
  ),
  QuizQuestion(
    id: 'css154',
    question: 'What is an example of professional workplace conflict resolution?',
    options: [
      'Blaming others publicly',
      'Discussing calmly and finding solutions',
      'Always avoiding the person',
      'Complaining loudly',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Professional conflict resolution involves calm discussion focused on solutions.',
  ),
  QuizQuestion(
    id: 'css155',
    question: 'What to do when someone is angry?',
    options: [
      'Respond with anger',
      'Walk away without saying anything',
      'Stay calm and try to understand them',
      'Interrupt them',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'When someone is angry, remaining calm and seeking to understand helps de-escalate.',
  ),
  QuizQuestion(
    id: 'css156',
    question: 'Which conflict leads to better understanding and solutions?',
    options: [
      'Destructive conflict',
      'Constructive conflict',
      'Ignored conflict',
      'Staying silent',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Constructive conflict, when managed well, can lead to improved understanding and better solutions.',
  ),
  QuizQuestion(
    id: 'css157',
    question: 'What to do to reduce misunderstanding in disagreement?',
    options: [
      'Interrupt',
      'Listen actively',
      'Speak loudly',
      'Speak without thinking',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Active listening helps clarify positions and reduce misunderstandings during disagreements.',
  ),
  QuizQuestion(
    id: 'css158',
    question: 'What is a good way to face criticism?',
    options: [
      'Argue immediately',
      'Criticize back',
      'Stay calm and learn',
      'Ignore it',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Handle criticism constructively by staying calm and extracting lessons from it.',
  ),
  QuizQuestion(
    id: 'css159',
    question: 'What is resilience?',
    options: [
      'Ignoring failure',
      'Bouncing back from failure and trying again',
      'Avoiding challenges',
      'Never making mistakes',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Resilience is the ability to recover from setbacks and persist in efforts.',
  ),
  QuizQuestion(
    id: 'css160',
    question: 'Which is an example of resilience?',
    options: [
      'Giving up after bad grades',
      'Blaming others for mistakes',
      'Learning from mistakes and trying again',
      'Pretending nothing happened',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Resilience means learning from failures and continuing to try rather than giving up.',
  ),
  QuizQuestion(
    id: 'css161',
    question: 'Which mindset believes improvement is possible through effort?',
    options: [
      'Fixed mindset',
      'Growth mindset',
      'Negative mindset',
      'Fixed thinking',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'A growth mindset is the belief that abilities can develop through effort and learning.',
  ),
  QuizQuestion(
    id: 'css162',
    question: 'Which technique does NOT build mental toughness?',
    options: [
      'Taking deep breaths',
      'Negative self-talk',
      'Visualization',
      'Positive self-talk',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Negative self-talk undermines mental toughness, unlike positive techniques.',
  ),
  QuizQuestion(
    id: 'css163',
    question: 'What does the "reflection" step mean?',
    options: [
      'Turning away from failure',
      'Thinking about what went wrong',
      'Celebrating success',
      'Doing the same thing again',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Reflection involves analyzing failures to understand what went wrong.',
  ),
  QuizQuestion(
    id: 'css164',
    question: 'How do resilient people face criticism?',
    options: [
      'Respond with anger',
      'Completely ignore it',
      'Learn from it',
      'Blame others',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Resilient individuals view criticism as an opportunity to learn and improve.',
  ),
  QuizQuestion(
    id: 'css165',
    question: 'What is an example of someone who moved forward after failure?',
    options: [
      'Student who quit after failure',
      'Businessperson who closed shop after loss',
      'J.K. Rowling who succeeded after rejection',
      'Player who quit after defeat',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'J.K. Rowling exemplifies resilience by persisting despite repeated rejections.',
  ),
  QuizQuestion(
    id: 'css166',
    question: 'What helps adopt a growth mindset?',
    options: [
      'Avoiding difficult tasks',
      'Saying "I\'m not good at this"',
      'Practicing and learning from mistakes',
      'Getting someone else to do it',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Adopting a growth mindset involves practice and learning from errors.',
  ),
  QuizQuestion(
    id: 'css167',
    question: 'What is the purpose of visualization?',
    options: [
      'Imagining failure',
      'Remembering problem steps',
      'Seeing yourself succeed',
      'Forgetting the task',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Visualization is a technique of mentally rehearsing successful performance.',
  ),
  QuizQuestion(
    id: 'css168',
    question: 'What is the correct sequence of the "Reflection, Learn, Action" process?',
    options: [
      'Learn → Reflection → Action',
      'Reflection → Action → Learn',
      'Action → Learn → Reflection',
      'Reflection → Learn → Action',
    ],
    correctIndex: 3,
    subject: 'BS-CSS',
    description: 'The process flows from reflecting on experience, to learning from it, then taking improved action.',
  ),
  QuizQuestion(
    id: 'css169',
    question: 'What is a key sign of professionalism in the workplace?',
    options: [
      'Wearing expensive clothes',
      'Punctuality and showing respect',
      'Gossiping with colleagues',
      'Avoiding all communication',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Professionalism is demonstrated through punctuality and respectful behavior toward others.',
  ),
  QuizQuestion(
    id: 'css170',
    question: 'Which shows good workplace etiquette?',
    options: [
      'Ignoring emails',
      'Interrupting in meetings',
      'Listening carefully and responding politely',
      'Always agreeing with everyone',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Good workplace etiquette includes attentive listening and courteous responses.',
  ),
  QuizQuestion(
    id: 'css171',
    question: 'What should you NOT do in a professional email?',
    options: [
      'Proper greeting',
      'Clear message',
      'Using slang and unclear words',
      'Polite closing',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Professional emails should avoid informal language, slang, and unclear expressions.',
  ),
  QuizQuestion(
    id: 'css172',
    question: 'Which is NOT a good non-verbal cue in the workplace?',
    options: [
      'Making eye contact',
      'Slouching',
      'Smiling',
      'Good posture',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Slouching indicates poor posture and lack of engagement in professional settings.',
  ),
  QuizQuestion(
    id: 'css173',
    question: 'What is appropriate formal business attire?',
    options: [
      'Shorts and t-shirts',
      'Shiny, flashy clothes',
      'Suit, tie, and polished shoes',
      'Casual jeans',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Traditional business attire includes suits, ties, and polished formal shoes.',
  ),
  QuizQuestion(
    id: 'css174',
    question: 'Why is professionalism important?',
    options: [
      'To impress friends',
      'To avoid hard work',
      'To build a good image and succeed in career',
      'To talk less at work',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Professionalism builds a positive reputation and contributes to career success.',
  ),
  QuizQuestion(
    id: 'css175',
    question: 'What should you do if a colleague is speaking in a meeting?',
    options: [
      'Wait for your turn and listen carefully',
      'Interrupt them',
      'Talk to others',
      'Look at your phone',
    ],
    correctIndex: 0,
    subject: 'BS-CSS',
    description: 'Respect meeting etiquette by waiting your turn and giving full attention to the speaker.',
  ),
  QuizQuestion(
    id: 'css176',
    question: 'Which behavior demonstrates strong work ethics?',
    options: [
      'Ignoring tasks',
      'Completing work responsibly and on time',
      'Copying others\' work',
      'Leaving early without notice',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Strong work ethics involve taking responsibility and completing work punctually.',
  ),
  QuizQuestion(
    id: 'css177',
    question: 'What is a good time management method at work?',
    options: [
      'Doing everything at the last moment',
      'Depending on others to remind you',
      'Creating a task list and prioritizing',
      'Doing many tasks at once without planning',
    ],
    correctIndex: 2,
    subject: 'BS-CSS',
    description: 'Effective time management includes creating task lists and establishing priorities.',
  ),
  QuizQuestion(
    id: 'css178',
    question: 'Why is communication important at work?',
    options: [
      'To show your style',
      'To make a good impression and show respect',
      'To win fashion competitions',
      'To avoid buying work clothes',
    ],
    correctIndex: 1,
    subject: 'BS-CSS',
    description: 'Professional communication creates positive impressions and demonstrates respect for others.',
  ),
];

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
const List<QuizQuestion> _mocktestQuestions = [
  QuizQuestion(
    id: 'mocktest01',
    question: 'What is the main benefit of automation?',
    options: [
      'Increased paperwork',
      'Increased efficiency and fewer errors',
      'More electricity usage',
      'Slower work',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Automation uses technology to perform tasks with minimal human intervention, leading to higher speed, consistency, and a significant reduction in manual errors.',
  ),
  QuizQuestion(
    id: 'mocktest02',
    question: 'What does High Contrast mode help with?',
    options: [
      'Playing music',
      'Saving battery',
      'Reading text more clearly',
      'Increasing brightness',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'High Contrast mode is an accessibility feature that changes the color scheme to make text and images stand out more, which is especially helpful for users with low vision.',
  ),
  QuizQuestion(
    id: 'mocktest03',
    question: 'What should you do to use Google Maps offline?',
    options: [
      'Restart the phone',
      'Log out of your Google account',
      'Turn on airplane mode',
      'Download the map in advance',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'Google Maps allows you to download specific map areas over Wi-Fi. Once downloaded, you can navigate and search in that area without an active internet connection.',
  ),
  QuizQuestion(
    id: 'mocktest04',
    question: 'Where should you ideally drop your old electronics?',
    options: [
      'Street corner',
      'With scrap dealers',
      'Certified e-waste centre',
      'In a lake',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Old electronics contain hazardous materials. Certified e-waste centers ensure they are recycled properly, recovering valuable materials and preventing environmental pollution.',
  ),
  QuizQuestion(
    id: 'mocktest05',
    question: 'Why is AI useful in schools?',
    options: [
      'It gives personal learning to students',
      'It takes attendance manually',
      'It builds classrooms',
      'It cooks lunch',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'AI can personalize learning by adapting to each student\'s pace and style, providing customized resources and feedback, which is difficult for a single teacher to do for every student.',
  ),
  QuizQuestion(
    id: 'mocktest06',
    question: 'Which of the following is a simple text editor in Windows 10?',
    options: [
      'Paint',
      'WordPad',
      'Notepad',
      'Excel',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Notepad is a basic text editor for creating plain text files without formatting. WordPad is more advanced (rich text), Paint is for graphics, and Excel is a spreadsheet program.',
  ),
  QuizQuestion(
    id: 'mocktest07',
    question: 'Which key is used to remove characters to the left of the cursor?',
    options: [
      'Shift',
      'Enter',
      'Tab',
      'Backspace',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'The Backspace key erases the character immediately to the left of the blinking cursor. The Delete key erases the character to the right.',
  ),
  QuizQuestion(
    id: 'mocktest08',
    question: 'What is an example of phishing?',
    options: [
      'Game request',
      'Message: "Your account is blocked"',
      'Birthday wishes',
      'Weather update',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Phishing is a cybercrime where attackers disguise themselves as a trustworthy entity in a message to trick you into revealing sensitive data. An urgent message about a blocked account is a classic example.',
  ),
  QuizQuestion(
    id: 'mocktest09',
    question: 'What is the main function of a spam filter?',
    options: [
      'Adding jokes',
      'Making emails look colorful',
      'Hiding spam',
      'Sending emails only under certain conditions',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'A spam filter automatically detects and diverts unwanted, malicious, or irrelevant emails (spam) away from a user\'s primary inbox, often to a "spam" or "junk" folder.',
  ),
  QuizQuestion(
    id: 'mocktest10',
    question: 'Which file format is good for sharing documents without printing?',
    options: [
      'ZIP',
      'PDF',
      'MP3',
      'EXE',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'PDF (Portable Document Format) preserves the exact layout, fonts, and images of a document, making it ideal for sharing and viewing on any device without needing the original software or printing it.',
  ),
  QuizQuestion(
    id: 'mocktest11',
    question: 'What do cookies on websites do?',
    options: [
      'Cook data',
      'Play music',
      'Clean viruses',
      'Track and store user activity',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'HTTP cookies are small text files that websites store on your device to remember information about you, such as login details, site preferences, and items in a shopping cart.',
  ),
  QuizQuestion(
    id: 'mocktest12',
    question: 'How can you check if a backup was successful?',
    options: [
      'Restart your computer',
      'Delete the backup',
      'Check antivirus settings',
      'Open last backup time',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'Most backup software logs the date and time of the last successful backup. Checking this log or the backup destination to see if new files were added is the primary way to verify success.',
  ),
  QuizQuestion(
    id: 'mocktest13',
    question: 'What is the best practice after using a public computer?',
    options: [
      'Save password on browser',
      'Log out immediately',
      'Leave it open',
      'Share password',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Logging out of all accounts (email, social media, etc.) and clearing the browsing history/cache ensures the next user cannot access your personal information on a shared or public device.',
  ),
  QuizQuestion(
    id: 'mocktest14',
    question: 'What is the role of descriptive analytics?',
    options: [
      'Giving suggestions for action',
      'Telling what might happen',
      'Telling what has already happened',
      'Ignoring past data',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Descriptive analytics is the first stage of data analysis, focusing on summarizing historical data to understand what has happened in the past, often using dashboards and reports.',
  ),
  QuizQuestion(
    id: 'mocktest15',
    question: 'In Google Sheets, a single box is called a:',
    options: [
      'Cell',
      'Table',
      'Block',
      'Box',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'The intersection of a row and a column in a spreadsheet (like Google Sheets or Excel) is called a cell. It is the basic unit for holding data.',
  ),
  QuizQuestion(
    id: 'mocktest16',
    question: 'Which IT skill helps in protecting data?',
    options: [
      'Data entry',
      'Graphic design',
      'Photography',
      'Cybersecurity',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'Cybersecurity is the practice of protecting systems, networks, and programs from digital attacks. It focuses on ensuring the confidentiality, integrity, and availability of data.',
  ),
  QuizQuestion(
    id: 'mocktest17',
    question: 'What should you do before publishing your portfolio?',
    options: [
      'Review and update all sections',
      'Delete samples',
      'Lock it',
      'Hide your name',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'Reviewing your portfolio ensures there are no spelling or grammatical errors, all links work, the content is up-to-date, and it accurately presents your best work to potential employers.',
  ),
  QuizQuestion(
    id: 'mocktest18',
    question: 'What does a hybrid resume include?',
    options: [
      'Only personal details',
      'Just a skills list',
      'Skills + Chronological work history',
      'Only hobbies',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'A hybrid (or combination) resume lists your relevant skills and qualifications at the top, followed by your chronological work history. It combines the best of functional and chronological formats.',
  ),
  QuizQuestion(
    id: 'mocktest19',
    question: 'What to do if your internet is slow during a call?',
    options: [
      'Increase volume',
      'Leave the meeting',
      'Turn off video',
      'Use multiple devices',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Video calls consume significantly more bandwidth than audio-only calls. Turning off your video can free up bandwidth, stabilizing the connection and improving audio quality.',
  ),
  QuizQuestion(
    id: 'mocktest20',
    question: 'What does OTP stand for?',
    options: [
      'Open Time PIN',
      'One Time Password',
      'Online Transaction PIN',
      'Official Transaction Password',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'OTP stands for One-Time Password. It is an automatically generated numeric or alphanumeric string that is valid for only one login session or transaction, providing enhanced security.',
  ),
  QuizQuestion(
    id: 'mocktest21',
    question: 'What is the internet?',
    options: [
      'A digital post office that connects devices',
      'A place to play games',
      'A smartphone app',
      'A type of TV',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'The internet is a global network of billions of computers and other electronic devices. It allows you to access information and communicate with anyone else on the network.',
  ),
  QuizQuestion(
    id: 'mocktest22',
    question: 'What should you add to make your LinkedIn profile complete?',
    options: [
      'Cartoon photo',
      'Education, skills, and photo',
      'Game scores',
      'Favorite movies',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'A complete LinkedIn profile includes a professional photo, a detailed work history, education, skills, and a summary. These elements help recruiters find you and assess your qualifications.',
  ),
  QuizQuestion(
    id: 'mocktest23',
    question: 'What is the primary purpose of a computer network?',
    options: [
      'Making paper documents',
      'Connecting computers and sharing information',
      'Watching TV only',
      'Charging mobile phones',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Computer networks connect multiple devices to allow them to share resources like files, printers, and internet access, as well as to communicate with each other.',
  ),
  QuizQuestion(
    id: 'mocktest24',
    question: 'What is the first step to fix a slow internet connection?',
    options: [
      'Turn off antivirus',
      'Restart router',
      'Format device',
      'Delete all data',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Restarting your router (power cycling) clears its temporary memory (cache) and can resolve many common connectivity issues and speed problems by forcing it to re-establish a fresh connection to your ISP.',
  ),
  QuizQuestion(
    id: 'mocktest25',
    question: 'What is a "Smart Factory" in Industry 4.0?',
    options: [
      'A factory that runs on solar power',
      'A factory with only human workers',
      'A factory using connected machines and data',
      'A factory that makes smartphones',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'A smart factory is a highly digitized and connected production facility that uses machines, sensors, and systems to constantly collect and share data, enabling self-optimization and efficiency.',
  ),
  QuizQuestion(
    id: 'mocktest26',
    question: 'What is a computer worm?',
    options: [
      'A part of antivirus',
      'An insect',
      'A browser extension',
      'A program that spreads across networks without a file',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'A worm is a standalone malware computer program that replicates itself to spread to other computers. Unlike a virus, it does not need to attach itself to an existing program and can spread without user action.',
  ),
  QuizQuestion(
    id: 'mocktest27',
    question: 'What helped Sita succeed in remote work?',
    options: [
      'Learning graphic design and freelancing',
      'Joining a local store',
      'Working at a call center',
      'Moving to a city',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'Acquiring a digital skill like graphic design allowed her to offer services online through freelancing platforms, providing location independence and a flexible income stream suitable for remote work.',
  ),
  QuizQuestion(
    id: 'mocktest28',
    question: 'Which of these is a challenge of automation?',
    options: [
      'Increased accuracy',
      'Over-reliance on machines',
      'Cost saving',
      'Better speed',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'While automation has many benefits, a key challenge is the potential for over-reliance, where human skills atrophy and the system creates new, complex failure modes if it breaks down.',
  ),
  QuizQuestion(
    id: 'mocktest29',
    question: 'What does URL stand for?',
    options: [
      'Uniform Resource Locator',
      'Useful Reading List',
      'United Resource Language',
      'User Registered Link',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'URL stands for Uniform Resource Locator. It is the web address you type into a browser to access a specific webpage, like "https://www.google.com".',
  ),
  QuizQuestion(
    id: 'mocktest30',
    question: 'Which of these is a simple text editor in Windows?',
    options: [
      'Notepad',
      'WordPad',
      'CMD',
      'Paint',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'Notepad is a basic text editor for creating plain text files without formatting. WordPad is more advanced (rich text), Paint is for graphics, and CMD is the command prompt.',
  ),
  QuizQuestion(
    id: 'mocktest31',
    question: 'What should you do every 30-40 minutes while working?',
    options: [
      'Play video games',
      'Check messages',
      'Take a small break and stretch',
      'Sleep',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Taking short, frequent breaks to stand, stretch, and walk around reduces physical strain, prevents eye fatigue, and can help maintain focus and productivity throughout the workday.',
  ),
  QuizQuestion(
    id: 'mocktest32',
    question: 'What is the main purpose of Customer Relationship Management (CRM) software?',
    options: [
      'Cooking for customers',
      'Managing customer interactions and data',
      'Making advertisements',
      'Designing websites',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'CRM software helps businesses manage and analyze customer interactions and data throughout the customer lifecycle, with the goal of improving relationships, retention, and driving sales growth.',
  ),
  QuizQuestion(
    id: 'mocktest33',
    question: 'Why should we avoid excessive punctuation in professional messages?',
    options: [
      'Looks fun',
      'Seems aggressive',
      'Makes message stylish',
      'Increases length',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Using too many exclamation marks or question marks can make a message appear overly emotional, unprofessional, or aggressive, similar to shouting or showing intense frustration in a face-to-face conversation.',
  ),
  QuizQuestion(
    id: 'mocktest34',
    question: 'Which sentence uses the word "enjoy" correctly?',
    options: [
      'I enjoy to paint.',
      'They enjoy drawing.',
      'He enjoy to run.',
      'She enjoy dancing.',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'The verb "enjoy" must be followed by a gerund (the -ing form of a verb). Among the options, "They enjoy drawing" correctly uses "enjoy" with the gerund "drawing".',
  ),
  QuizQuestion(
    id: 'mocktest35',
    question: 'Which letter is silent in the word "receipt"?',
    options: [
      'p',
      'c',
      'e',
      't',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'In "receipt", the letter "p" is silent. The word is pronounced "ree-seet".',
  ),
  QuizQuestion(
    id: 'mocktest36',
    question: 'Which question helps you know if something comes in other colours?',
    options: [
      'Do you have it in another colour?',
      'What is the final price?',
      'Where is the bag?',
      'Can I try this on?',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'Asking "Do you have it in another colour?" directly inquires about the availability of different color options for the same item.',
  ),
  QuizQuestion(
    id: 'mocktest37',
    question: 'Which of the following is the correct order to form a question from the words: "you", "what", "eat", "do"?',
    options: [
      'Do what you eat?',
      'Eat you do what?',
      'What do you eat?',
      'You what do eat?',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'The correct structure for a question in English often follows the pattern: Question word (What) + auxiliary verb (do) + subject (you) + main verb (eat).',
  ),
  QuizQuestion(
    id: 'mocktest38',
    question: 'Which type of book has big, colorful pictures and often few words?',
    options: [
      'Simple Storybooks',
      'Magazines',
      'Picture Books',
      'Comics',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Picture books are a genre of children\'s literature where the illustrations are as important as, or more important than, the text, often telling the story primarily through images with minimal words.',
  ),
  QuizQuestion(
    id: 'mocktest39',
    question: 'Choose the correct sentence that describes a past weather condition.',
    options: [
      'It is raining since yesterday.',
      'Yesterday it was very cold.',
      'It rains heavily yesterday.',
      'It cold yesterday was.',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        '"Yesterday it was very cold" correctly uses the past tense ("was") to describe a weather condition that happened on a specific day in the past.',
  ),
  QuizQuestion(
    id: 'mocktest40',
    question: 'Which of these tastes is considered sweet?',
    options: [
      'Spicy',
      'Sweet',
      'Sour',
      'Salty',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Sweet is one of the five basic tastes, typically produced by sugars and some other substances.',
  ),
  QuizQuestion(
    id: 'mocktest41',
    question: 'Choose the correct sentence that uses simple past tense to describe a weather event.',
    options: [
      'The weather rains yesterday.',
      'The weather will rain yesterday.',
      'There was heavy rainfall last night.',
      'It raining very much last night.',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        '"There was heavy rainfall last night" correctly uses the simple past tense ("was") to describe a completed weather event in the past.',
  ),
  QuizQuestion(
    id: 'mocktest42',
    question: 'Which question would be best to ask a mall assistant?',
    options: [
      'Excuse me, can you help me find the bookshop?',
      'Excuse me, help me find!',
      'Food court where?',
      'Show bookshop now.',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'This option is polite, clear, and specific. It uses standard English for requesting help and clearly states the destination (bookshop).',
  ),
  QuizQuestion(
    id: 'mocktest43',
    question: 'What does "Take out your notebook" mean?',
    options: [
      'Tear a page from the notebook',
      'Bring your notebook from your bag',
      'Draw a notebook',
      'Put your notebook away',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'The instruction "take out your notebook" means to remove your notebook from your bag or desk and place it on your work surface, ready for use.',
  ),
  QuizQuestion(
    id: 'mocktest44',
    question: 'Which of these correctly describes a heatwave using a simple sentence?',
    options: [
      'A heatwave means many days of extreme heat.',
      'Heatwave is cold and foggy weather.',
      'A heatwave is when wind blow fast.',
      'Heatwave mean it rainy every day.',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'This is the only sentence that is both grammatically correct and contains the correct definition of a heatwave: a prolonged period of excessively hot weather.',
  ),
  QuizQuestion(
    id: 'mocktest45',
    question: 'Which of these is an outdoor activity?',
    options: [
      'Gardening',
      'Playing football',
      'Reading',
      'Cycling',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Playing football is primarily an outdoor activity. While reading and gardening can be both indoors and outdoors, and cycling is outdoor, "Playing football" is most distinctly an outdoor sport.',
  ),
  QuizQuestion(
    id: 'mocktest46',
    question: 'Which student is following the classroom rule of being organized?',
    options: [
      'A student who put the crayons neatly in the box',
      'A student who started colouring',
      'A student who went outside',
      'A student who drew on the table',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'Putting crayons neatly back in the box demonstrates organization and care for shared materials, which is a key classroom rule.',
  ),
  QuizQuestion(
    id: 'mocktest47',
    question: 'Why is it important to practice pronunciation?',
    options: [
      'To make it harder for others to understand you',
      'To learn more words',
      'To speak clearer and more confidently',
      'To speak faster',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Good pronunciation ensures that others can understand you easily. This reduces frustration, builds confidence, and makes communication more effective.',
  ),
  QuizQuestion(
    id: 'mocktest48',
    question: 'Which sentence has the correct use of "a" or "an"?',
    options: [
      'He eats an egg for breakfast.',
      'We drink a water at school.',
      'I eat an banana every day.',
      'She has a orange.',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'Use "an" before a vowel sound. The word "egg" starts with a vowel sound, so "an egg" is correct. "A banana," "an orange," and "water" is uncountable, so "a water" is incorrect.',
  ),
  QuizQuestion(
    id: 'mocktest49',
    question: 'Which sentence correctly describes a picture?',
    options: [
      'He is raising his hand.',
      'She clean the desk.',
      'I dream with crayons.',
      'We listening to the teacher.',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        '"He is raising his hand" is the only sentence that is grammatically correct (using the present continuous tense "is raising") and describes a clear, observable action.',
  ),
  QuizQuestion(
    id: 'mocktest50',
    question: 'What does the modal verb "can" primarily express?',
    options: [
      'Permission',
      'Advice',
      'Possibility',
      'Ability',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'The modal verb "can" is most commonly used to express ability (e.g., "I can swim"). It can also express permission or possibility, but "ability" is its primary meaning.',
  ),
  QuizQuestion(
    id: 'mocktest51',
    question: 'How do you introduce yourself correctly?',
    options: [
      'My name is Rahul.',
      'I name is Rahul.',
      'Name my Rahul is.',
      'Rahul name is my.',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        '"My name is Rahul" follows the standard English sentence structure: possessive adjective (My) + noun (name) + verb (is) + proper noun (Rahul).',
  ),
  QuizQuestion(
    id: 'mocktest52',
    question: 'Which sentence shows the future continuous tense?',
    options: [
      'He is playing football now.',
      'He will be playing football at 6 p.m.',
      'He plays football.',
      'He was playing football.',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'The future continuous tense describes an action that will be in progress at a specific time in the future. Its structure is: will + be + present participle (verb-ing).',
  ),
  QuizQuestion(
    id: 'mocktest53',
    question: 'Choose the correct sentence using "in front of":',
    options: [
      'The teacher is standing in front of the students.',
      'The car is in front of under the bridge.',
      'The tree is in front of from the box.',
      'The balloon is flying in front of next to the wall.',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'The prepositional phrase "in front of" correctly indicates that one thing (the teacher) is positioned before or facing another (the students). The other options misuse additional prepositions.',
  ),
  QuizQuestion(
    id: 'mocktest54',
    question: 'Choose the sentence that shows future perfect tense:',
    options: [
      'I had graduated last year.',
      'I was graduating last year.',
      'I will have graduated by next year.',
      'I have graduated last year.',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'The future perfect tense describes an action that will be completed before a specific time in the future. Its structure is: will + have + past participle.',
  ),
  QuizQuestion(
    id: 'mocktest55',
    question: 'Which of the following is the correct comparative sentence?',
    options: [
      'That street is more crowded than this one.',
      'This chair is more comfortable than the old one.',
      'This bag is more heavier than mine.',
      'The car is fastly more than the bike.',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'For two-syllable adjectives not ending in -y (like "comfortable"), we use "more + adjective + than". The other options have double comparatives or incorrect word order.',
  ),
  QuizQuestion(
    id: 'mocktest56',
    question: 'Which word is an auxiliary (helping) verb?',
    options: [
      'Can',
      'Eat',
      'Read',
      'Run',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        '"Can" is a modal auxiliary verb. It "helps" the main verb by expressing possibility, ability, or permission (e.g., "I *can* eat fast"). Read, run, and eat are main action verbs.',
  ),
  QuizQuestion(
    id: 'mocktest57',
    question: 'Which activity is a fine motor skill?',
    options: [
      'Playing music',
      'Reading',
      'Running',
      'Painting',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'Fine motor skills involve the small muscles of the hands and fingers. Painting (holding a brush, making precise strokes) requires fine motor control. Running is a gross motor skill.',
  ),
  QuizQuestion(
    id: 'mocktest58',
    question: 'Which sentence is in the simple present tense?',
    options: [
      'I play football every evening.',
      'I am play football in evening.',
      'I playing football in the evening.',
      'I plays football every evening.',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'The simple present tense for the subject "I" uses the base form of the verb (play). It describes a habitual action (every evening).',
  ),
  QuizQuestion(
    id: 'mocktest59',
    question: 'Why is it important to use respectful language with elders?',
    options: [
      'To sound formal',
      'To end a conversation',
      'To show respect',
      'To impress others',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Using respectful language (like "please," "thank you," "Mr./Ms.") is a primary way to show respect, honor their life experience, and acknowledge their position or age.',
  ),
  QuizQuestion(
    id: 'mocktest60',
    question: 'What is "empathy"?',
    options: [
      'A person',
      'The ability to understand another\'s feelings',
      'A reason',
      'A method',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Empathy is the ability to sense, understand, and share the feelings of another person. It is often described as "putting yourself in someone else\'s shoes."',
  ),
  QuizQuestion(
    id: 'mocktest61',
    question: 'Which sentence is correct?',
    options: [
      'He has a fever.',
      'I have an headache.',
      'She has an cold.',
      'I have an cough.',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'We say "a fever" because "fever" starts with a consonant sound. "Headache," "cold," and "cough" take the article "a" because they start with a consonant sound as well.',
  ),
  QuizQuestion(
    id: 'mocktest62',
    question: 'Which sentence describes a future action?',
    options: [
      'She played football yesterday.',
      'She will play football tomorrow.',
      'She is playing football now.',
      'She plays football.',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'The sentence uses the future tense ("will play") and the time marker "tomorrow" to describe an action that has not happened yet but will happen in the future.',
  ),
  QuizQuestion(
    id: 'mocktest63',
    question: 'What is the past tense of "play"?',
    options: [
      'playing',
      'will play',
      'played',
      'plays',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'The simple past tense of most regular verbs is formed by adding "-ed" to the base form. Therefore, the past tense of "play" is "played".',
  ),
  QuizQuestion(
    id: 'mocktest64',
    question: 'What key skill would a principal use when responding to a teacher\'s emotional breakdown?',
    options: [
      'Punishment and silence',
      'Empathy, self-regulation, and social skills',
      'Strict discipline',
      'Ignoring the situation',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'An emotional breakdown requires emotional intelligence. The principal needs empathy to listen and understand, self-regulation to remain calm and supportive, and social skills to guide the teacher toward help and resolution.',
  ),
  QuizQuestion(
    id: 'mocktest65',
    question: 'What is a noun in the sentence: "The blue pencil is on the desk"?',
    options: [
      'Desk',
      'The',
      'Blue',
      'On',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'A noun is a word that names a person, place, thing, or idea. In this sentence, "pencil" and "desk" are nouns. "Desk" is listed as an option.',
  ),
  QuizQuestion(
    id: 'mocktest66',
    question: 'What does "resilience" mean in a professional context?',
    options: [
      'Avoid all future challenges',
      'Ensure you never fail',
      'Recover from difficulties and keep going',
      'Ignore problems',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Resilience is the ability to bounce back from setbacks, adapt well to change, and keep going in the face of adversity. It is a key skill for long-term career success.',
  ),
  QuizQuestion(
    id: 'mocktest67',
    question: 'What is a good tip for building a personal brand online?',
    options: [
      'Avoid posting personal views',
      'Stay true to your voice and values',
      'Follow trends to become famous',
      'Speak only in English to grow',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Authenticity is the foundation of a strong personal brand. When your online presence reflects your genuine voice and core values, you attract an audience that resonates with you and builds trust.',
  ),
  QuizQuestion(
    id: 'mocktest68',
    question: 'How does a positive and inclusive classroom environment benefit students?',
    options: [
      'It makes one feel motivated and comfortable sharing creative ideas',
      'One doesn\'t need any help from others',
      'It helps in staying away from all group discussions and projects',
      'It helps in getting special treatment and less homework',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'A positive and inclusive environment fosters psychological safety. When students feel respected and valued, they are more willing to take risks, share unique ideas, and engage creatively without fear of ridicule.',
  ),
  QuizQuestion(
    id: 'mocktest69',
    question: 'What helps a person in making sound decisions?',
    options: [
      'Making decisions impulsively without thinking',
      'Collecting all necessary information, evaluating choices, and predicting outcomes',
      'Ignoring important facts and hoping for the best',
      'Always following others\' choices without evaluating',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'A sound decision-making process is rational and systematic. It involves gathering relevant information, identifying and evaluating alternatives based on criteria, and assessing the potential consequences of each option.',
  ),
  QuizQuestion(
    id: 'mocktest70',
    question: 'Which of the following is an example of poor time management?',
    options: [
      'Using a to-do list',
      'Breaking tasks into blocks',
      'Scrolling on the phone and missing deadlines',
      'Saying no to distractions',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Scrolling on your phone is a common form of procrastination and distraction. When it directly causes you to miss deadlines, it is a clear sign of poor time management.',
  ),
  QuizQuestion(
    id: 'mocktest71',
    question: 'What budgeting method divides income into 50% needs, 30% wants, and 20% savings?',
    options: [
      'Rule of Three',
      'Zero-Based Budgeting',
      'Pareto Principle',
      '50-30-20 Rule',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'The 50/30/20 rule is a simple budgeting framework that allocates 50% of after-tax income to needs, 30% to wants, and 20% to savings and debt repayment.',
  ),
  QuizQuestion(
    id: 'mocktest72',
    question: 'Which of the following could be the biggest difference between two students presenting the same topic?',
    options: [
      'One has better slides',
      'One speaks clearly and confidently',
      'One wears formal clothes',
      'One has more facts',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Compelling delivery is paramount. A speaker who is clear, confident, and engaging can hold the audience\'s attention and make even average content impactful. The others are secondary enhancements.',
  ),
  QuizQuestion(
    id: 'mocktest73',
    question: 'What would a person do to manage their loneliness and stress after retirement?',
    options: [
      'Start multiple businesses',
      'Volunteer, walk daily, practice gratitude',
      'Watch TV all day',
      'Move to a new city',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'This combination addresses all key areas: volunteering provides social connection and purpose, walking daily improves physical and mental health, and practicing gratitude shifts focus from loss to appreciation.',
  ),
  QuizQuestion(
    id: 'mocktest74',
    question: 'Which of the following could help in gaining confidence in giving presentations?',
    options: [
      'Joining a debate club',
      'Avoiding public speaking',
      'Practise recording oneself in small segments',
      'Memorising entire speeches',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Practicing in small segments reduces overwhelm. Recording yourself allows you to see your performance objectively, identify areas for improvement, and track your progress, which builds confidence.',
  ),
  QuizQuestion(
    id: 'mocktest75',
    question: 'How could you improve your communication before a campus job fair?',
    options: [
      'Hire a personal coach',
      'Avoid group projects',
      'Read more textbooks',
      'Practise, record your voice, and rehearse',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'Active practice is the most effective method. Rehearsing your "elevator pitch" out loud, recording it to check clarity and tone, and refining it builds confidence and ensures you are prepared for conversations with recruiters.',
  ),
  QuizQuestion(
    id: 'mocktest76',
    question: 'Which of the following is a characteristic of a SMART goal?',
    options: [
      'Measurable',
      'Time-bound',
      'Specific',
      'Achievable',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'SMART is an acronym that stands for Specific, Measurable, Achievable, Relevant, and Time-bound. "Specific" is one of the core five and a valid correct answer.',
  ),
  QuizQuestion(
    id: 'mocktest77',
    question: 'What does the "S" in the SMART goal framework stand for?',
    options: [
      'Offer',
      'Outcome',
      'Operation',
      'Specific',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'In the widely used SMART framework, the "S" stands for "Specific". This means the goal is clear, well-defined, and unambiguous.',
  ),
  QuizQuestion(
    id: 'mocktest78',
    question: 'What is the "Paying it Forward" concept?',
    options: [
      'A repeated apology for mistakes',
      'A series of rewards for good behaviour',
      'A chain reaction where helping inspires more helping',
      'A school club activity',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Paying it forward is the concept of repaying a good deed by doing a good deed for someone else, rather than returning the favor to the original person, thus creating a chain of kindness.',
  ),
  QuizQuestion(
    id: 'mocktest79',
    question: 'What is a key belief of a "Growth Mindset"?',
    options: [
      'Abilities can grow with practice',
      'Talent is built over time',
      'Failure is a chance to learn',
      'Skills are unchangeable',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'The core belief of a growth mindset, as defined by Carol Dweck, is that basic abilities and intelligence can be developed and improved through dedication, effort, and learning.',
  ),
  QuizQuestion(
    id: 'mocktest80',
    question: 'What is a common myth about creativity?',
    options: [
      'It\'s only useful in emergencies',
      'It is an inborn gift, not something you can develop',
      'It can be taught only in an art school',
      'It only exists in science',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'This is a common myth. While some may have a natural aptitude, research strongly shows that creativity is a skill that can be learned, practiced, and developed by anyone through training and a supportive environment.',
  ),
  QuizQuestion(
    id: 'mocktest81',
    question: 'What is the benefit of using filters in email automation?',
    options: [
      'Making emails look colorful',
      'Hiding spam',
      'Adding jokes',
      'Sending emails only under certain conditions',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'Email filters allow you to create rules that automatically sort, label, forward, or delete incoming emails based on specific conditions like sender, subject, or keywords, making email management more efficient.',
  ),
  QuizQuestion(
    id: 'mocktest82',
    question: 'What is the correct sentence to talk about what we do in the library?',
    options: [
      'We reading books in the library.',
      'We read books in the library.',
      'We are read books in library.',
      'We reads book in the library.',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        '"We read books in the library" uses the simple present tense correctly for a habitual action. The other options have incorrect verb forms or missing articles.',
  ),
  QuizQuestion(
    id: 'mocktest83',
    question: 'By the time she arrives, we ___ dinner.',
    options: [
      'will have finished',
      'finished',
      'have finished',
      'had finished',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'This sentence describes an action that will be completed before another future action. The future perfect tense ("will have finished") is the correct choice.',
  ),
  QuizQuestion(
    id: 'mocktest84',
    question: 'What is the function of "should" in this sentence? You should drink more water.',
    options: [
      'Ability',
      'Permission',
      'Possibility',
      'Advice',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'The modal verb "should" is used to give or ask for advice or recommendations. In this sentence, it is suggesting a healthy action (drinking more water).',
  ),
  QuizQuestion(
    id: 'mocktest85',
    question: 'Complete the sentence: "___ you accept credit cards?"',
    options: [
      'Are',
      'Can',
      'Will',
      'Do',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        '"Can" is used to ask about possibility or ability. The question "Can you accept credit cards?" politely asks if the business has the capability to accept that form of payment.',
  ),
  QuizQuestion(
    id: 'mocktest86',
    question: 'What is the purpose of using polite expressions like "please" and "thank you"?',
    options: [
      'to sound formal',
      'to end a conversation',
      'to show respect',
      'to impress others',
    ],
    correctIndex: 2,
    subject: 'Mock Test',
    description:
        'Polite expressions are fundamental to showing respect and consideration for others. They acknowledge the other person\'s effort and help maintain positive social interactions.',
  ),
  QuizQuestion(
    id: 'mocktest87',
    question: 'Which pronoun replaces "a book"?',
    options: [
      'It',
      'She',
      'They',
      'He',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'The pronoun "it" is used to refer to a singular, inanimate object or thing, such as a book.',
  ),
  QuizQuestion(
    id: 'mocktest88',
    question: 'Which sentence is correct?',
    options: [
      'I draws with crayons.',
      'We listening to the teacher.',
      'She clean the desk.',
      'He is raising his hand.',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        '"He is raising his hand" correctly uses the present continuous tense ("is raising") and has proper subject-verb agreement. The other options have incorrect verb conjugations.',
  ),
  QuizQuestion(
    id: 'mocktest89',
    question: 'Which hobby helps you learn new words and imagine new worlds?',
    options: [
      'Playing music',
      'Painting',
      'Running',
      'Reading',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'Reading exposes you to new vocabulary in context and allows your imagination to create the settings, characters, and worlds described in the text.',
  ),
  QuizQuestion(
    id: 'mocktest90',
    question: 'What tense is used in "I will be going to the store"?',
    options: [
      'Future continuous',
      'Past continuous',
      'Present perfect',
      'Future simple',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'The future continuous tense describes an action that will be in progress at a specific time in the future. Its structure is "will + be + verb-ing".',
  ),
  QuizQuestion(
    id: 'mocktest91',
    question: 'What is the final price?',
    options: [
      'What is the discount?',
      'What is the total?',
      'What is the tax?',
      'What is the cost?',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'The final price refers to the total amount to be paid after all calculations (including taxes, discounts, fees) are applied.',
  ),
  QuizQuestion(
    id: 'mocktest92',
    question: 'What does a CRM tool help businesses with?',
    options: [
      'Managing customer interactions and data',
      'Making advertisements',
      'Cooking for customers',
      'Designing websites',
    ],
    correctIndex: 0,
    subject: 'Mock Test',
    description:
        'CRM software helps businesses manage and analyze customer interactions and data throughout the customer lifecycle, with the goal of improving relationships, retention, and driving sales growth.',
  ),
  QuizQuestion(
    id: 'mocktest93',
    question: 'Which sentence correctly uses the simple present tense to describe a daily action?',
    options: [
      'I playing football in the evening.',
      'I play football every evening.',
      'I plays football every evening.',
      'I am play football in evening.',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'The simple present tense for the subject "I" uses the base form of the verb (play). It is used to describe habits, routines, and general truths.',
  ),
  QuizQuestion(
    id: 'mocktest94',
    question: 'What does the teacher mean when she says, "Take out your notebook"?',
    options: [
      'Draw a notebook',
      'Put your notebook away',
      'Tear a page from the notebook',
      'Bring your notebook from your bag',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'The instruction "take out your notebook" means to remove your notebook from your bag and place it on your desk, ready for use.',
  ),
  QuizQuestion(
    id: 'mocktest95',
    question: 'Which of these is an indoor hobby?',
    options: [
      'Cycling',
      'Playing football',
      'Gardening',
      'Reading',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'Reading is typically done indoors, such as in a home, library, or quiet room. It does not require outdoor space or elements.',
  ),
  QuizQuestion(
    id: 'mocktest96',
    question: 'Which of the following is the correct order to form a question from the words: "you", "what", "eat", "do"?',
    options: [
      'You what do eat?',
      'Eat you do what?',
      'Do what you eat?',
      'What do you eat?',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        'The correct structure for a question in English is: Question word (What) + auxiliary verb (do) + subject (you) + main verb (eat)?.',
  ),
  QuizQuestion(
    id: 'mocktest97',
    question: 'What is the correct sentence to talk about what we do in the library?',
    options: [
      'We reads book in the library.',
      'We reading books in the library.',
      'We are read books in library.',
      'We read books in the library.',
    ],
    correctIndex: 3,
    subject: 'Mock Test',
    description:
        '"We read books in the library" uses the simple present tense correctly for a habitual action. The other options have incorrect verb forms or missing articles.',
  ),
  QuizQuestion(
    id: 'mocktest98',
    question: 'Which sentence is correct?',
    options: [
      'We listening to the teacher.',
      'He is raising his hand.',
      'I draws with crayons.',
      'She clean the desk.',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        '"He is raising his hand" correctly uses the present continuous tense ("is raising") and has proper subject-verb agreement. The other options have incorrect verb conjugations.',
  ),
  QuizQuestion(
    id: 'mocktest99',
    question: 'Which hobby helps you learn new words and imagine new worlds?',
    options: [
      'Playing music',
      'Reading',
      'Running',
      'Painting',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'Reading exposes you to new vocabulary in context and allows your imagination to create the settings, characters, and worlds described in the text.',
  ),
  QuizQuestion(
    id: 'mocktest100',
    question: 'What is the function of "should" in this sentence? You should drink more water.',
    options: [
      'Permission',
      'Advice',
      'Ability',
      'Possibility',
    ],
    correctIndex: 1,
    subject: 'Mock Test',
    description:
        'The modal verb "should" is used to give or ask for advice or recommendations. In this sentence, it is suggesting a healthy action (drinking more water).',
  ),
];

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////  BS-CIT /////////////////////////////////////////
 const List<QuizQuestion> _examcitQuestions = [
  QuizQuestion(
    id: 'examcit1',
    question: 'Which website allows you to lock/unlock Aadhaar?',
    options: [
      'www.incometax.gov.in',
      'www.uidai.gov.in',
      'www.mygov.in',
      'www.indiapost.gov.in'
    ],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'UIDAI (Unique Identification Authority of India) official website uidai.gov.in allows Aadhaar locking/unlocking for security.',
  ),
  QuizQuestion(
    id: 'examcit2',
    question: 'What happens if you sit in bad posture for a long time?',
    options: [
      'You type faster',
      'You learn more',
      'You become more active',
      'You may feel neck and back pain'
    ],
    correctIndex: 3,
    subject: 'Exam BS-CIT',
    description: 'Poor posture over time strains muscles and spine, leading to neck pain, back pain, and other musculoskeletal issues.',
  ),
  QuizQuestion(
    id: 'examcit3',
    question: 'What happens when you use the "Freeze Top Row" option?',
    options: [
      'Top row moves down',
      'Top row stays visible while scrolling',
      'Top row is deleted',
      'Top row changes colour'
    ],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'Freeze Top Row keeps the top row visible even when you scroll down, making it easier to reference column headers.',
  ),
  QuizQuestion(
    id: 'examcit4',
    question: 'Which household appliance is an example of automation?',
    options: ['Chair', 'Spoon', 'Washing machine', 'Bucket'],
    correctIndex: 2,
    subject: 'Exam BS-CIT',
    description: 'A washing machine automates the laundry process, reducing manual effort through programmed cycles.',
  ),
  QuizQuestion(
    id: 'examcit5',
    question: 'Why should you update antivirus software?',
    options: [
      'To install games',
      'To get new virus definitions',
      'To reduce battery',
      'To change wallpapers'
    ],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'Antivirus updates include new virus definitions that help detect and protect against recently discovered threats.',
  ),
  QuizQuestion(
    id: 'examcit6',
    question: 'What should you always do in a paid promotion?',
    options: [
      'Hide that it\'s paid',
      'Delete old posts',
      'Clearly say it\'s an ad or sponsorship',
      'Never mention the brand'
    ],
    correctIndex: 2,
    subject: 'Exam BS-CIT',
    description: 'Disclosing paid promotions is legally required and maintains transparency and trust with your audience.',
  ),
  QuizQuestion(
    id: 'examcit7',
    question: 'Which of these should you avoid for safe digital payments?',
    options: ['Strong passwords', 'Updating apps', 'Secure networks', 'Sharing OTP'],
    correctIndex: 3,
    subject: 'Exam BS-CIT',
    description: 'Sharing OTP (One Time Password) is dangerous as it can lead to unauthorized access to your accounts and financial loss.',
  ),
  QuizQuestion(
    id: 'examcit8',
    question: 'Why is checking the date of a webpage important?',
    options: [
      'To download it faster',
      'To find spelling errors',
      'To see if its colourful',
      'To ensure information is recent'
    ],
    correctIndex: 3,
    subject: 'Exam BS-CIT',
    description: 'Checking the date helps verify that the information is current and relevant, as outdated information may be inaccurate.',
  ),
  QuizQuestion(
    id: 'examcit9',
    question: 'What should you check before accepting a friend request?',
    options: ['Number of posts', 'Internet speed', 'Profile picture only', 'Mutual friends and real identity'],
    correctIndex: 3,
    subject: 'Exam BS-CIT',
    description: 'Checking mutual friends and real identity helps verify authenticity and avoid connecting with fake or malicious accounts.',
  ),
  QuizQuestion(
    id: 'examcit10',
    question: 'What is one common requirement for remote jobs?',
    options: ['Office attendance', 'Strong internet connection', 'Vehicle license', 'Uniform'],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'Remote jobs require a strong internet connection for communication, file sharing, and accessing work platforms.',
  ),
  QuizQuestion(
    id: 'examcit11',
    question: 'What is 2FA in cloud storage?',
    options: [
      'Two Factor Authentication',
      'Two File Access',
      'Two Fast Access',
      'Two Folder Arrangement'
    ],
    correctIndex: 0,
    subject: 'Exam BS-CIT',
    description: 'Two Factor Authentication (2FA) adds an extra layer of security by requiring two forms of verification to access accounts.',
  ),
  QuizQuestion(
    id: 'examcit12',
    question: 'What is the use of the COUNT function?',
    options: [
      'To count number of cells with numbers',
      'To format cells',
      'To calculate difference',
      'To find the total'
    ],
    correctIndex: 0,
    subject: 'Exam BS-CIT',
    description: 'The COUNT function in spreadsheet software counts only cells that contain numeric values, ignoring blanks and text.',
  ),
  QuizQuestion(
    id: 'examcit13',
    question: 'What happens when you delete a file from Documents?',
    options: [
      'It goes to Recycle Bin',
      'It disappears forever',
      'It renames itself',
      'It becomes a folder'
    ],
    correctIndex: 0,
    subject: 'Exam BS-CIT',
    description: 'On Windows systems, deleted files go to the Recycle Bin where they can be restored before permanent deletion.',
  ),
  QuizQuestion(
    id: 'examcit14',
    question: 'What is the benefit of remote collaboration?',
    options: [
      'People must travel',
      'People can work from anywhere',
      'You cannot share files',
      'It wastes time'
    ],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'Remote collaboration allows team members to work from different locations, increasing flexibility and reducing travel needs.',
  ),
  QuizQuestion(
    id: 'examcit15',
    question: 'What is the advantage of organizing files into folders?',
    options: [
      'Hides files from others',
      'Folders take less space',
      'Looks colourful',
      'Helps find files easily'
    ],
    correctIndex: 3,
    subject: 'Exam BS-CIT',
    description: 'Organizing files into folders makes retrieval quicker and easier by categorizing related files together.',
  ),
  QuizQuestion(
    id: 'examcit16',
    question: 'What does a feedback form usually collect?',
    options: ['News reports', 'User opinions and ratings', 'Music files', 'Movie reviews'],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'Feedback forms are designed to gather user opinions, ratings, and suggestions to improve products or services.',
  ),
  QuizQuestion(
    id: 'examcit17',
    question: 'Where is cloud data typically stored? (From page 17)',
    options: ['In Google Drive', 'In your email inbox', 'On YouTube', 'On your computer'],
    correctIndex: 0,
    subject: 'Exam BS-CIT',
    description: 'Cloud data is stored on remote servers like Google Drive, accessible via the internet rather than local storage.',
  ),
  QuizQuestion(
    id: 'examcit18',
    question: 'What is a good password example?',
    options: ['rahul123', '123456', 'password', 'R@huLI672#'],
    correctIndex: 3,
    subject: 'Exam BS-CIT',
    description: 'R@huLI672# contains uppercase, lowercase, numbers, and special characters, making it strong against password attacks.',
  ),
  QuizQuestion(
    id: 'examcit19',
    question: 'Which tool is used for creating websites? (From page 19)',
    options: ['Photoshop', 'Google Sites', 'Excel', 'CorelDRAW'],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'Google Sites is a website builder tool, while Photoshop and CorelDRAW are design tools and Excel is for spreadsheets.',
  ),
  QuizQuestion(
    id: 'examcit20',
    question: 'What is a benefit of cloud storage?',
    options: ['Access from anywhere', 'Backup of data', 'Data is always 100% safe', 'File sharing from hacking'],
    correctIndex: 0,
    subject: 'Exam BS-CIT',
    description: 'Cloud storage allows access to files from anywhere with an internet connection, providing convenience and flexibility.',
  ),
  QuizQuestion(
    id: 'examcit21',
    question: 'What is a SMART goal?',
    options: [
      'Specific and measurable targets',
      'No timeline',
      'A vague plan',
      'Confusing steps'
    ],
    correctIndex: 0,
    subject: 'Exam BS-CIT',
    description: 'SMART goals are Specific, Measurable, Achievable, Relevant, and Time-bound, providing clear direction for achieving objectives.',
  ),
  QuizQuestion(
    id: 'examcit22',
    question: 'What is a benefit of structured online learning?',
    options: [
      'Random videos',
      'No deadlines',
      'Clear learning path',
      'No exams'
    ],
    correctIndex: 2,
    subject: 'Exam BS-CIT',
    description: 'Structured online learning provides a clear, organized path with defined objectives and progression through topics.',
  ),
  QuizQuestion(
    id: 'examcit23',
    question: 'What is a Trojan Horse?',
    options: [
      'Antivirus software',
      'A fake program that hides malware',
      'A type of game',
      'Security patch'
    ],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'A Trojan Horse disguises itself as legitimate software but contains malicious code that can harm your system.',
  ),
  QuizQuestion(
    id: 'examcit24',
    question: 'What is the use of the COUNT function?',
    options: [
      'To count number of cells with numbers',
      'To format cells',
      'To calculate difference',
      'To find the total'
    ],
    correctIndex: 0,
    subject: 'Exam BS-CIT',
    description: 'COUNT function counts only cells containing numeric values, useful for data analysis in spreadsheets.',
  ),
  QuizQuestion(
    id: 'examcit25',
    question: 'What is VLOOKUP used for?',
    options: [
      'Combining cells',
      'Looking up values in a table',
      'Sorting data',
      'Formatting cells'
    ],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'VLOOKUP searches for a value in the first column of a table and returns a corresponding value from another column.',
  ),
  QuizQuestion(
    id: 'examcit26',
    question: 'Which of these is an effect of cyberbullying?',
    options: ['Confidence boost', 'Fear and sadness', 'Better concentration', 'Happiness'],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'Cyberbullying causes emotional distress including fear, sadness, anxiety, and depression in victims.',
  ),
  QuizQuestion(
    id: 'examcit27',
    question: 'Why should we follow sustainable digital habits?',
    options: [
      'To save energy and protect the planet',
      'To harm the environment',
      'To use more electricity',
      'To waste more data'
    ],
    correctIndex: 0,
    subject: 'Exam BS-CIT',
    description: 'Sustainable digital habits like reducing screen time and cloud storage use help save energy and reduce environmental impact.',
  ),
  QuizQuestion(
    id: 'examcit28',
    question: 'Siri works only on which type of devices?',
    options: ['Windows PC', 'Apple devices', 'Amazon Echo', 'Android phones'],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'Siri is Apple\'s virtual assistant and is exclusively available on Apple devices like iPhone, iPad, Mac, and Apple Watch.',
  ),
  QuizQuestion(
    id: 'examcit29',
    question: 'Which button helps you preview your Google Form?',
    options: ['Link icon', 'Eye icon', 'Microphone icon', 'Trash icon'],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'The eye icon in Google Forms allows you to preview how the form will appear to respondents before publishing.',
  ),
  QuizQuestion(
    id: 'examcit30',
    question: 'Which of these is NOT a way to save energy on devices?',
    options: [
      'Adjusting brightness',
      'Closing unused apps',
      'Using sleep mode',
      'Playing games all day'
    ],
    correctIndex: 3,
    subject: 'Exam BS-CIT',
    description: 'Playing games all day consumes significant energy, unlike brightness adjustment, closing apps, or using sleep mode which save energy.',
  ),
  QuizQuestion(
    id: 'examcit31',
    question: 'What must we protect while using AI?',
    options: ['TV remotes', 'Personal data', 'Shoes', 'Hair'],
    correctIndex: 1,
    subject: 'Exam BS-CIT',
    description: 'AI systems often process personal data, which must be protected to ensure privacy and prevent misuse.',
  ),
  QuizQuestion(
    id: 'examcit32',
    question: 'What is a strong password made of?',
    options: [
      'Only numbers',
      'Only letters',
      'Letters, numbers, and special characters',
      'Only your name'
    ],
    correctIndex: 2,
    subject: 'Exam BS-CIT',
    description: 'Strong passwords combine uppercase/lowercase letters, numbers, and special characters to resist guessing and brute-force attacks.',
  ),
  QuizQuestion(
    id: 'examcit33',
    question: 'What does screen resolution affect?',
    options: ['CPU speed', 'Internet speed', 'Volume', 'Sharpness and clarity of the screen'],
    correctIndex: 3,
    subject: 'Exam BS-CIT',
    description: 'Screen resolution determines pixel density, affecting how sharp and clear images and text appear on the display.',
  ),
  QuizQuestion(
    id: 'examcit34',
    question: 'What is the first step to apply for a government job online?',
    options: [
      'Attend the interview',
      'Download the admit card',
      'Register on the recruitment portal',
      'Pay the fee'
    ],
    correctIndex: 2,
    subject: 'Exam BS-CIT',
    description: 'Registration on the official recruitment portal is the first step to create an account and proceed with the application.',
  ),
  QuizQuestion(
    id: 'examcit35',
    question: 'Which app is commonly used for booking train tickets in India?',
    options: ['IRCTC', 'Practo', 'RedBus', 'BookMyShow'],
    correctIndex: 0,
    subject: 'Exam BS-CIT',
    description: 'IRCTC (Indian Railway Catering and Tourism Corporation) is the official app for booking train tickets in India.',
  ),
];


///////////////////////////////////////////////// BS-CLS ///////////////////
const List<QuizQuestion> _examclsQuestions = [
  QuizQuestion(
    id: 'examcls1',
    question: 'Which adjectives describes someone who is always happy?',
    options: ['CHEERFUL', 'SAD', 'ANGRY', 'TIRED'],
    correctIndex: 0,
    subject: 'Exam BS-CLS',
    description: 'CHEERFUL is the adjective that describes someone who is always happy.',
  ),
  QuizQuestion(
    id: 'examcls2',
    question: 'She told me not to eat sugar. (Choose the correct sentence)',
    options: ['She told me not to eat sugar.', 'She said me not to eat sugar.', 'She tell me not to eat sugar.', 'She saying me not to eat sugar.'],
    correctIndex: 0,
    subject: 'Exam BS-CLS',
    description: 'The correct structure is "She told me not to eat sugar" (tell + person + infinitive).',
  ),
  QuizQuestion(
    id: 'examcls3',
    question: 'What is one benefit of using transitional phrases?',
    options: ['They replace body language', 'They help structure your opinion', 'They make you sound informal', 'They make you sound formal'],
    correctIndex: 1,
    subject: 'Exam BS-CLS',
    description: 'Transitional phrases help organize thoughts and structure opinions clearly.',
  ),
  QuizQuestion(
    id: 'examcls4',
    question: 'Choose the correct future continuous sentence.',
    options: ['They travel to Mumbai.', 'They were traveling to Mumbai.', 'They are traveling to Mumbai tomorrow.', 'They will be traveling to Mumbai tomorrow.'],
    correctIndex: 3,
    subject: 'Exam BS-CLS',
    description: '"They will be traveling to Mumbai tomorrow" correctly expresses a future continuous action.',
  ),
  QuizQuestion(
    id: 'examcls5',
    question: 'What do comics use to show what characters say?',
    options: ['Large photos', 'Easy sentences', 'Speech bubbles', 'Short articles'],
    correctIndex: 2,
    subject: 'Exam BS-CLS',
    description: 'Comics use speech bubbles to show what characters say.',
  ),
  QuizQuestion(
    id: 'examcls6',
    question: 'Complete the sentence: The library is _____ the police station.',
    options: ['beside the street', 'above the road', 'on the road', 'beside'],
    correctIndex: 3,
    subject: 'Exam BS-CLS',
    description: '"Beside" correctly indicates the library is next to the police station.',
  ),
  QuizQuestion(
    id: 'examcls7',
    question: 'What is the purpose of festivals?',
    options: ['To have fun', 'To bond with family and friends', 'To feel good after studying hard', 'All of the above'],
    correctIndex: 3,
    subject: 'Exam BS-CLS',
    description: 'Festivals serve multiple purposes including having fun, bonding with others, and celebrating achievements.',
  ),
  QuizQuestion(
    id: 'examcls8',
    question: 'Choose the sentence in the past simple tense.',
    options: ['She has eaten dinner.', 'She is eating dinner.', 'She eats dinner.', 'She ate dinner.'],
    correctIndex: 3,
    subject: 'Exam BS-CLS',
    description: '"She ate dinner" is in past simple tense, indicating a completed action in the past.',
  ),
  QuizQuestion(
    id: 'examcls9',
    question: 'Which pronoun replaces "a car"?',
    options: ['We', 'He', 'It', 'She'],
    correctIndex: 2,
    subject: 'Exam BS-CLS',
    description: '"It" is the pronoun used for objects or things like a car.',
  ),
  QuizQuestion(
    id: 'examcls10',
    question: 'What is the polite way to ask for a discount?',
    options: ['I want cheaper.', 'That\'s too much!', 'You give discount?', 'Is there a discount on this?'],
    correctIndex: 3,
    subject: 'Exam BS-CLS',
    description: '"Is there a discount on this?" is a polite and appropriate way to ask about discounts.',
  ),
  QuizQuestion(
    id: 'examcls11',
    question: 'Identify the sentence that asks a question.',
    options: ['It tells you to do something.', 'It makes a statement.', 'It asks a question.', 'It gives a command.'],
    correctIndex: 2,
    subject: 'Exam BS-CLS',
    description: 'An interrogative sentence is one that asks a question.',
  ),
  QuizQuestion(
    id: 'examcls12',
    question: 'What is the meaning of "dialogue" in a story?',
    options: ['The words characters say to each other', 'The actions characters perform', 'The costumes worn by actors', 'The description of the setting'],
    correctIndex: 0,
    subject: 'Exam BS-CLS',
    description: 'Dialogue refers to the conversation or words spoken between characters in a story or movie.',
  ),
  QuizQuestion(
    id: 'examcls13',
    question: 'Which tip can help you when you are nervous about speaking?',
    options: ['think it - say it - check it', 'speaking in one word answers', 'speak as fast as you can', 'whispering sentence'],
    correctIndex: 0,
    subject: 'Exam BS-CLS',
    description: 'The "think it - say it - check it" tip helps organize thoughts and reduces nervousness while speaking.',
  ),
  QuizQuestion(
    id: 'examcls14',
    question: 'Choose the correct sentence using "Go" appropriately.',
    options: ['Go to the back of the room.', 'Go to the front of the line.', 'Go to the side.', 'Go to the corner.'],
    correctIndex: 1,
    subject: 'Exam BS-CLS',
    description: '"Go to the front of the line" is a commonly used and correct imperative sentence.',
  ),
  QuizQuestion(
    id: 'examcls15',
    question: 'What is a characteristic of science fiction?',
    options: ['Only humans as characters', 'Stories with no problems', 'A made-up setting with aliens', 'Historical events only'],
    correctIndex: 2,
    subject: 'Exam BS-CLS',
    description: 'Science fiction often features made-up settings including aliens, futuristic technology, or other worlds.',
  ),
  QuizQuestion(
    id: 'examcls16',
    question: 'How to politely express you want to purchase something?',
    options: ['I want this now.', 'Buy this for me.', 'I like this, so I have it.', 'I\'d like to buy this, please.'],
    correctIndex: 3,
    subject: 'Exam BS-CLS',
    description: '"I\'d like to buy this, please" is the most polite and appropriate way to express a purchase intention.',
  ),
  QuizQuestion(
    id: 'examcls17',
    question: 'Complete the sentence: This is my brother. _____ likes to play football.',
    options: ['He', 'We', 'She', 'It'],
    correctIndex: 0,
    subject: 'Exam BS-CLS',
    description: '"He" is the correct pronoun to refer to a male person (brother).',
  ),
  QuizQuestion(
    id: 'examcls18',
    question: 'Choose the best word to complete this sentence. It was very cold, _____ I wore a jacket.',
    options: ['So', 'But', 'And', 'Because'],
    correctIndex: 0,
    subject: 'Exam BS-CLS',
    description: '"So" indicates the result or consequence - because it was cold, wearing a jacket was the result.',
  ),
  QuizQuestion(
    id: 'examcls19',
    question: 'In the question, "Why are you sad?", which word is the "Wh-word"?',
    options: ['Why', 'Are', 'Sad', 'You'],
    correctIndex: 0,
    subject: 'Exam BS-CLS',
    description: '"Why" is the Wh-word as it starts with \'Wh\' and asks for a reason.',
  ),
  QuizQuestion(
    id: 'examcls20',
    question: 'What is an "opinion"?',
    options: ['Something that can be proven with science', 'Something that is always true', 'Something that someone believes or feels', 'Something that is a fact'],
    correctIndex: 2,
    subject: 'Exam BS-CLS',
    description: 'An opinion is a personal belief, feeling, or thought that may vary from person to person.',
  ),
  QuizQuestion(
    id: 'examcls21',
    question: 'Choose the correct future perfect sentence.',
    options: ['I have finished my homework.', 'I finish my homework.', 'I will finish my homework.', 'I will have finished my homework.'],
    correctIndex: 3,
    subject: 'Exam BS-CLS',
    description: '"I will have finished" is future perfect tense, indicating completion before a future time.',
  ),
  QuizQuestion(
    id: 'examcls22',
    question: 'What type of language is used in a formal setting?',
    options: ['casual and short', 'funny and fast', 'polite and complete', 'slang and relaxed'],
    correctIndex: 2,
    subject: 'Exam BS-CLS',
    description: 'Formal settings require polite, complete, and professional language.',
  ),
  QuizQuestion(
    id: 'examcls23',
    question: 'Which of these is a classroom instruction?',
    options: ['Open your book', 'I like chocolate', 'Dogs can run fast', 'The sky is blue'],
    correctIndex: 0,
    subject: 'Exam BS-CLS',
    description: '"Open your book" is a command or instruction commonly used in classrooms.',
  ),
  QuizQuestion(
    id: 'examcls24',
    question: 'Identify the present continuous sentence.',
    options: ['They walk to school.', 'They walked to school.', 'They are walking to school.', 'They will walk to school.'],
    correctIndex: 2,
    subject: 'Exam BS-CLS',
    description: '"They are walking to school" is present continuous tense (am/is/are + verb-ing).',
  ),
  QuizQuestion(
    id: 'examcls25',
    question: 'What does "pronunciation" refer to?',
    options: ['Writing words correctly', 'Saying the sounds of words correctly', 'Spelling words correctly', 'Understanding word meanings'],
    correctIndex: 1,
    subject: 'Exam BS-CLS',
    description: 'Pronunciation is the way in which a word is spoken, including saying sounds correctly.',
  ),
  QuizQuestion(
    id: 'examcls26',
    question: 'Which point would you use if you want to speak during a meeting?',
    options: ['I want to talk.', 'Excuse me.', 'Look here!', 'Hey!'],
    correctIndex: 1,
    subject: 'Exam BS-CLS',
    description: '"Excuse me" is the polite and appropriate way to speak during a meeting.',
  ),
  QuizQuestion(
    id: 'examcls27',
    question: 'What is good advice for a library?',
    options: ['Keep your voice down', 'Talk loudly', 'Close the library door', 'Read outside'],
    correctIndex: 0,
    subject: 'Exam BS-CLS',
    description: 'Libraries require quiet environments, so "Keep your voice down" is proper etiquette.',
  ),
];


///////////////////////////////////////////////////////////////////////////// BS-CSS /////////////////////////////////////////////
const List<QuizQuestion> _examcssQuestions = [
  QuizQuestion(
    id: 'examcss1',
    question: 'What should you do when you notice a weakness in yourself?',
    options: ['Hide it from others.', 'Take small steps to improve it.', 'Give up on your goal.', 'Ignore it.'],
    correctIndex: 1,
    subject: 'Exam BS-CSS',
    description: 'Taking small steps to improve is the most constructive approach to personal growth.',
  ),
  QuizQuestion(
    id: 'examcss2',
    question: 'What could help you grow and find job leads?',
    options: ['Moving to a new city', 'Buying a new laptop', 'Joining an online group', 'Working late hours'],
    correctIndex: 2,
    subject: 'Exam BS-CSS',
    description: 'Joining an online group provides networking and learning opportunities that help in growth and job search.',
  ),
  QuizQuestion(
    id: 'examcss3',
    question: 'Why is it important to know both your strengths and weaknesses?',
    options: ['To impress others.', 'To help you grow and make better choices.', 'To look smart.', 'To avoid difficult conversations.'],
    correctIndex: 1,
    subject: 'Exam BS-CSS',
    description: 'Knowing strengths and weaknesses helps in personal development and informed decision-making.',
  ),
  QuizQuestion(
    id: 'examcss4',
    question: 'How should you approach achieving a goal?',
    options: ['Focus only on long-term goals', 'Define a clear goal and take small steps', 'Avoid setting goals to reduce failure', 'Wait for the right opportunity'],
    correctIndex: 1,
    subject: 'Exam BS-CSS',
    description: 'Breaking down a goal into small steps makes it manageable and increases chances of success.',
  ),
  QuizQuestion(
    id: 'examcss5',
    question: 'What helps reduce stress and improve long-term emotional health?',
    options: ['Skipping meals under pressure', 'Staying online longer', 'Avoiding all social contact', 'Staying active'],
    correctIndex: 3,
    subject: 'Exam BS-CSS',
    description: 'Regular physical activity reduces stress and improves emotional well-being.',
  ),
  QuizQuestion(
    id: 'examcss6',
    question: 'Which of the following is the most effective way to communicate important medical information to a local community?',
    options: ['Using technical terms', 'Using formal medical language', 'Using simple and clear language', 'Using complex medical charts'],
    correctIndex: 2,
    subject: 'Exam BS-CSS',
    description: 'Simple and clear language ensures better understanding and accessibility for the community.',
  ),
  QuizQuestion(
    id: 'examcss7',
    question: 'Which of the following methods can help reach families effectively?',
    options: ['Conducting large meetings', 'Television ads', 'Written pamphlets', 'Voice messages in local language'],
    correctIndex: 3,
    subject: 'Exam BS-CSS',
    description: 'Voice messages in local language are personal and easily understandable, making them effective for family communication.',
  ),
  QuizQuestion(
    id: 'examcss8',
    question: 'What could confidence help you achieve?',
    options: ['Create opportunities and trust', 'Make fewer friends', 'Memorise faster', 'Avoid difficult conversations'],
    correctIndex: 0,
    subject: 'Exam BS-CSS',
    description: 'Confidence helps build trust and seize opportunities, leading to personal and professional growth.',
  ),
  QuizQuestion(
    id: 'examcss9',
    question: 'What helped P.V. Sindhu succeed, besides talent and hard work?',
    options: ['A lucky tournament draw', 'Fewer matches to play', 'Her rivals\' injuries', 'Strong support from her team'],
    correctIndex: 3,
    subject: 'Exam BS-CSS',
    description: 'Strong support system including coaches, family, and teammates contributes significantly to an athlete\'s success.',
  ),
  QuizQuestion(
    id: 'examcss10',
    question: 'Which behaviour shows lack of adaptability in a team?',
    options: ['Ignoring colleagues\' ideas and sticking only to your own methods', 'Following the same routine process even when it is inefficient', 'Avoiding challenges and waiting for instructions', 'All of the above'],
    correctIndex: 3,
    subject: 'Exam BS-CSS',
    description: 'All these behaviours resist change and improvement, showing lack of adaptability.',
  ),
  QuizQuestion(
    id: 'examcss11',
    question: 'Why is paraphrasing important in communication?',
    options: ['It proves you\'re smarter', 'It helps you win the argument', 'It shows you\'re listening and clarifies meaning', 'It ends the argument quickly'],
    correctIndex: 2,
    subject: 'Exam BS-CSS',
    description: 'Paraphrasing ensures mutual understanding and shows active listening.',
  ),
  QuizQuestion(
    id: 'examcss12',
    question: 'What should you do when someone yells at you?',
    options: ['Raise your voice to match theirs.', 'Set kind boundaries and stay calm', 'Ignore them completely', 'Walk away without responding'],
    correctIndex: 1,
    subject: 'Exam BS-CSS',
    description: 'Setting boundaries calmly maintains respect and de-escalates conflict.',
  ),
  QuizQuestion(
    id: 'examcss13',
    question: 'How do notifications on devices typically affect focus?',
    options: ['They help us take breaks between tasks, improving focus', 'They help us take breaks between tasks, reducing focus', 'They make us switch between tasks, improving focus', 'They make us switch between tasks, reducing focus'],
    correctIndex: 3,
    subject: 'Exam BS-CSS',
    description: 'Constant notifications cause task switching, which reduces concentration and productivity.',
  ),
];
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////
// ─────────────────────────────────────────────
//  THEME & CONSTANTS
// ─────────────────────────────────────────────

const Color _primary = Color(0xFF1565C0);
const Color _primaryLight = Color(0xFF1E88E5);
const Color _primaryDark = Color(0xFF0D47A1);
const Color _accent = Color(0xFFFDD835);
const Color _success = Color(0xFF2E7D32);
const Color _successLight = Color(0xFF43A047);
const Color _error = Color(0xFFC62828);
const Color _errorLight = Color(0xFFEF5350);
const Color _surface = Color(0xFFFFFFFF);
const Color _background = Color(0xFFF0F4FF);
const Color _textPrimary = Color(0xFF0D1B3E);
const Color _textSecondary = Color(0xFF4A5568);
const Color _grey = Color(0xFF9E9E9E);
const Color _greyLight = Color(0xFFE8ECF4);
const Color _warning = Color(0xFFE65100);
const Color _reviewColor = Color(0xFF6A1B9A);
const Color _bookmarkColor = Color(0xFFF57F17);
const Color _infoColor = Color(0xFF0288D1);
const Color _gold = Color(0xFFFFD700);
const Color _bronze = Color(0xFFCD7F32);

const int _minQuestionsToSubmit = 5;

// Dark theme colors
const Color _darkBg = Color(0xFF0A0E1A);
const Color _darkSurface = Color(0xFF141828);
const Color _darkCard = Color(0xFF1E2438);
const Color _darkText = Color(0xFFE8ECF4);
const Color _darkTextSec = Color(0xFF8892A4);
const Color _darkBorder = Color(0xFF2A3450);

// ─────────────────────────────────────────────
//  RESPONSIVE HELPER
// ─────────────────────────────────────────────

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1440;

  static double panelWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1440) return 280;
    if (w >= 1024) return 220;
    if (w >= 600) return 180;
    return 72;
  }

  static int paletteColumns(double panelWidth) {
    if (panelWidth >= 240) return 5;
    if (panelWidth >= 180) return 4;
    if (panelWidth >= 120) return 3;
    return 2;
  }

  static double questionFontSize(BuildContext context) {
    if (isDesktop(context)) return 18;
    if (isTablet(context)) return 16;
    return 15;
  }

  static double optionFontSize(BuildContext context) {
    if (isDesktop(context)) return 15.5;
    if (isTablet(context)) return 14.5;
    return 14;
  }
}

// ─────────────────────────────────────────────
//  THEME PROVIDER (simple state)
// ─────────────────────────────────────────────

class AppThemeState extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }

  Color get bg => _isDark ? _darkBg : _background;
  Color get surface => _isDark ? _darkSurface : _surface;
  Color get cardBg => _isDark ? _darkCard : _surface;
  Color get textPrimary => _isDark ? _darkText : _textPrimary;
  Color get textSecondary => _isDark ? _darkTextSec : _textSecondary;
  Color get border => _isDark ? _darkBorder : _greyLight;
  Color get inputFill => _isDark ? _darkCard : _greyLight;
}

// ─────────────────────────────────────────────
//  ROOT APP
// ─────────────────────────────────────────────

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _ThemeProvider(
      child: Builder(
        builder: (ctx) {
          final themeState = _ThemeProvider.of(ctx);
          return MaterialApp(
            title: 'BS Program Quiz',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: _primary,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: _background,
              appBarTheme: const AppBarTheme(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: _primary,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: _darkBg,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0D1B3E),
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
            ),
            themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}

// Simple InheritedWidget for theme
class _ThemeProvider extends StatefulWidget {
  final Widget child;
  const _ThemeProvider({required this.child});

  static AppThemeState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_ThemeProviderState>();
    return state!.themeState;
  }

  @override
  State<_ThemeProvider> createState() => _ThemeProviderState();
}

class _ThemeProviderState extends State<_ThemeProvider> {
  final AppThemeState themeState = AppThemeState();

  @override
  void initState() {
    super.initState();
    themeState.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ─────────────────────────────────────────────
//  SCREEN 1 – LOGIN
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
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePin = true;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await Future.delayed(const Duration(milliseconds: 800));

    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();
    final user = _validUsers.cast<UserCredential?>().firstWhere(
      (u) => u!.name.toLowerCase() == name.toLowerCase() && u.pin == pin,
      orElse: () => null,
    );

    if (user != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              SubjectSelectionScreen(studentName: user.name),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid credentials. Please check your name and PIN.';
      });
      _shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryDark, _primary, _primaryLight],
          ),
        ),
        child: SafeArea(
          child: isWide ? _buildWideLogin(size) : _buildNarrowLogin(size),
        ),
      ),
    );
  }

  Widget _buildWideLogin(Size size) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/Logoes/Logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'BS Program Online Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Student Assessment Portal',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  const _InfoBadge(
                    icon: Icons.timer,
                    text: '60 min per subject',
                  ),
                  const SizedBox(height: 10),
                  const _InfoBadge(
                    icon: Icons.quiz,
                    text: 'Multiple subjects available',
                  ),
                  const SizedBox(height: 10),
                  const _InfoBadge(
                    icon: Icons.analytics,
                    text: 'Instant result & analytics',
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 440,
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: _buildLoginForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLogin(Size size) {
    return SingleChildScrollView(
      child: SizedBox(
        height: size.height - MediaQuery.of(context).padding.top,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/Logoes/Logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.school, size: 55, color: _primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'KUSHAL YUVA PROGRAM Online Test',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const Text(
              'Student Assessment Portal',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: _buildLoginForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Student Login',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your credentials to begin the test',
            style: TextStyle(color: _textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _buildLabel('Student Name'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              hint: 'Enter your full name',
              icon: Icons.person_outline,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('6-Digit PIN'),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (_, child) => Transform.translate(
              offset: Offset(
                _shakeAnimation.value *
                    ((_shakeController.value < 0.5) ? 1 : -1),
                0,
              ),
              child: child,
            ),
            child: TextFormField(
              controller: _pinController,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration(
                hint: 'Enter 6-digit PIN',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePin
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _grey,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'PIN is required';
                if (v.length != 6) return 'PIN must be exactly 6 digits';
                return null;
              },
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _errorLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _errorLight.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: _error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: _error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: _primary.withOpacity(0.4),
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
                  : const Text(
                      'Login & Proceed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: _textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _grey, fontSize: 14),
      prefixIcon: Icon(icon, color: _primaryLight, size: 20),
      suffixIcon: suffix,
      counterText: '',
      filled: true,
      fillColor: _greyLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _error, width: 1.5),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SCREEN 2 – SUBJECT SELECTION
// ─────────────────────────────────────────────

class SubjectSelectionScreen extends StatelessWidget {
  final String studentName;
  const SubjectSelectionScreen({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    final themeState = _ThemeProvider.of(context);

    return Scaffold(
      backgroundColor: themeState.bg,
      appBar: AppBar(
        title: const Text(
          'Select Your Subject',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeState.isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () => themeState.toggle(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: Column(
              children: [
                _WelcomeBanner(studentName: studentName),
                const SizedBox(height: 24),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _subjects
                        .map(
                          (s) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: _SubjectCard(
                                subject: s,
                                studentName: studentName,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  )
                else
                  ..._subjects.map(
                    (s) => _SubjectCard(subject: s, studentName: studentName),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final String studentName;
  const _WelcomeBanner({required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.waving_hand, color: _accent, size: 36),
          const SizedBox(height: 10),
          Text(
            'Welcome, $studentName!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose your subject to begin the assessment. You have 60 minutes per subject.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final String studentName;

  const _SubjectCard({required this.subject, required this.studentName});

  List<QuizQuestion> _getQuestionsForSubject(String code) {
    switch (code) {
      case 'BS-CIT':
        return List.from(_citQuestions)..shuffle(Random());
      case 'BS-CLS':
        return List.from(_clsQuestions)..shuffle(Random());
      case 'BS-CSS':
        return List.from(_cssQuestions)..shuffle(Random());
      case 'Mock Test':
        return List.from(_mocktestQuestions)..shuffle(Random()); 
      case 'Exam BS-CIT':
        return List.from(_examcitQuestions)..shuffle(Random());
      case 'Exam BS-CLS':
        return List.from(_examclsQuestions)..shuffle(Random());
      case 'BS-CSS':
        return List.from(_examcssQuestions)..shuffle(Random());      
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = _ThemeProvider.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeState.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final questions = _getQuestionsForSubject(subject.code);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AcknowledgmentScreen(
                  studentName: studentName,
                  subject: subject,
                  questions: questions,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primary, _primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      subject.icon,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.code,
                        style: TextStyle(
                          color: themeState.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subject.name,
                        style: TextStyle(
                          color: themeState.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          _SubjectTag(
                            '${_getQuestionsForSubject(subject.code).length} Questions',
                          ),
                          _SubjectTag('${subject.totalMinutes} min total'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectTag extends StatelessWidget {
  final String text;
  const _SubjectTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SCREEN 3 – ACKNOWLEDGMENT
// ─────────────────────────────────────────────

class AcknowledgmentScreen extends StatelessWidget {
  final String studentName;
  final Subject subject;
  final List<QuizQuestion> questions;

  const AcknowledgmentScreen({
    super.key,
    required this.studentName,
    required this.subject,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final themeState = _ThemeProvider.of(context);
    return Scaffold(
      backgroundColor: themeState.bg,
      appBar: AppBar(
        title: Text(
          '${subject.code} Assessment',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: isWide
                ? _buildWideLayout(context, themeState)
                : _buildNarrowLayout(context, themeState),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, AppThemeState t) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildHeader(t),
              const SizedBox(height: 16),
              _buildTestDetails(t),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              _buildInstructions(t),
              const SizedBox(height: 20),
              _buildStartButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, AppThemeState t) {
    return Column(
      children: [
        _buildHeader(t),
        const SizedBox(height: 16),
        _buildTestDetails(t),
        const SizedBox(height: 16),
        _buildInstructions(t),
        const SizedBox(height: 24),
        _buildStartButton(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeader(AppThemeState t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(subject.icon, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(
            'Welcome, $studentName!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'You are about to start your ${subject.code} test',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTestDetails(AppThemeState t) {
    return _SectionCard(
      title: 'Test Details',
      icon: Icons.info_outline,
      themeState: t,
      children: [
        _DetailRow(
          label: 'Subject',
          value: subject.code,
          isHighlight: true,
          themeState: t,
        ),
        _DetailRow(label: 'Subject Name', value: subject.name, themeState: t),
        _DetailRow(
          label: 'Total Questions',
          value: '${questions.length}',
          themeState: t,
        ),
        _DetailRow(
          label: 'Total Time',
          value: '${subject.totalMinutes} minutes',
          isHighlight: true,
          themeState: t,
        ),
        _DetailRow(
          label: 'Minimum to Submit',
          value: '$_minQuestionsToSubmit Questions',
          themeState: t,
        ),
      ],
    );
  }

  Widget _buildInstructions(AppThemeState t) {
    return _SectionCard(
      title: 'Instructions & Rules',
      icon: Icons.rule,
      themeState: t,
      children: [
        _RuleItem(
          icon: Icons.timer,
          text:
              '${subject.totalMinutes}-minute countdown for the entire subject. Manage your time wisely.',
          color: _primary,
        ),
        _RuleItem(
          icon: Icons.warning_amber,
          text:
              'Auto-submit when time expires. Warnings at 10 min, 5 min, and 1 min left.',
          color: _warning,
        ),
        _RuleItem(
          icon: Icons.insights,
          text:
              'Instant feedback when you select an answer with detailed explanation.',
          color: _primaryLight,
        ),
        _RuleItem(
          icon: Icons.bookmark,
          text: 'Bookmark questions and mark for review to revisit later.',
          color: _bookmarkColor,
        ),
        _RuleItem(
          icon: Icons.check_circle,
          text:
              'You must attempt at least $_minQuestionsToSubmit questions before submitting.',
          color: _success,
        ),
        _RuleItem(
          icon: Icons.shuffle,
          text: 'Questions are randomized for each attempt.',
          color: _grey,
        ),
        _RuleItem(
          icon: Icons.keyboard,
          text:
              'Use keyboard shortcuts: A/B/C/D to answer, → ← to navigate (desktop).',
          color: _textSecondary,
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => QuizScreen(
                studentName: studentName,
                subject: subject,
                questions: questions,
              ),
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeInOut),
                    ),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 450),
            ),
          );
        },
        icon: const Icon(Icons.play_arrow_rounded, size: 28),
        label: const Text(
          'Start Test',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _success,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: _success.withOpacity(0.4),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final AppThemeState themeState;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: themeState.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: themeState.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: themeState.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final bool isHighlight;
  final AppThemeState themeState;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: themeState.textSecondary, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? _primary : themeState.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _RuleItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _textSecondary, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GLOBAL TIMER STATE
// ─────────────────────────────────────────────

class GlobalTimerState {
  int totalSeconds;
  int remainingSeconds;
  bool isRunning;
  bool isPaused;
  Timer? _timer;
  VoidCallback? onTick;
  VoidCallback? onExpired;

  GlobalTimerState({required this.totalSeconds})
    : remainingSeconds = totalSeconds,
      isRunning = false,
      isPaused = false;

  void start() {
    isRunning = true;
    isPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        onTick?.call();
      } else {
        stop();
        onExpired?.call();
      }
    });
  }

  void pause() {
    isPaused = true;
    _timer?.cancel();
  }

  void resume() {
    if (isPaused) start();
  }

  void stop() {
    isRunning = false;
    isPaused = false;
    _timer?.cancel();
    _timer = null;
  }

  String get formattedRemaining {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedUsed {
    final used = totalSeconds - remainingSeconds;
    final m = used ~/ 60;
    final s = used % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progress => remainingSeconds / totalSeconds;
  bool get isLow => remainingSeconds <= 300; // 5 min
  bool get isCritical => remainingSeconds <= 60; // 1 min
  bool get isWarning => remainingSeconds <= 600; // 10 min
}

// ─────────────────────────────────────────────
//  SCREEN 4 – QUIZ (UPDATED WITH 30+ FEATURES)
// ─────────────────────────────────────────────

class QuizScreen extends StatefulWidget {
  final String studentName;
  final Subject subject;
  final List<QuizQuestion> questions;

  const QuizScreen({
    super.key,
    required this.studentName,
    required this.subject,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late List<int?> _selectedAnswers;
  late List<bool> _isLocked;
  late List<bool> _showAnswerFeedback;
  late List<bool> _isBookmarked;
  late List<bool> _isMarkedForReview;
  late List<bool> _isVisited;
  late List<Set<int>> _eliminatedOptions;
  late List<String> _questionNotes;

  late GlobalTimerState _globalTimer;
  bool _isFullScreen = false;
  bool _eliminationMode = false;
  bool _showNotePanel = false;

  // New Features Variables
  late List<bool> _isStarred;
  late List<int> _attemptCounts;
  late List<DateTime> _lastAttemptTime;
  bool _showStatsPanel = false;
  bool _showQuickNav = false;
  String _searchQuery = '';
  List<int> _filteredIndices = [];
  bool _focusMode = false;
  bool _hideAnswered = false;
  bool _autoSave = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _showConfetti = false;
  String _selectedDifficulty = 'all';
  String _selectedTopic = 'all';
  late List<double> _questionTimes;
  late List<double> _optionHoverTimes;
  bool _isPaused = false;
  int _streakCount = 0;
  int _bestStreak = 0;
  Map<String, int> _topicMastery = {};
  List<String> _recentlyCorrect = [];
  bool _showMasteryIndicator = true;
  bool _smartSuggestions = true;
  String _currentHint = '';
  List<String> _hints = [];
  int _hintIndex = 0;
  bool _showSplash = true;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  late AnimationController _optionAnimController;
  late Animation<double> _optionFadeAnim;

  final FocusNode _keyboardFocus = FocusNode();
  final ScrollController _paletteScrollController = ScrollController();
  final ScrollController _searchScrollController = ScrollController();

  List<QuizQuestion> get _questions => widget.questions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize all lists
    _selectedAnswers = List.filled(_questions.length, null);
    _isLocked = List.filled(_questions.length, false);
    _showAnswerFeedback = List.filled(_questions.length, false);
    _isBookmarked = List.filled(_questions.length, false);
    _isMarkedForReview = List.filled(_questions.length, false);
    _isVisited = List.filled(_questions.length, false);
    _eliminatedOptions = List.generate(_questions.length, (_) => {});
    _questionNotes = List.filled(_questions.length, '');
    _isStarred = List.filled(_questions.length, false);
    _attemptCounts = List.filled(_questions.length, 0);
    _lastAttemptTime = List.filled(_questions.length, DateTime.now());
    _questionTimes = List.filled(_questions.length, 0);
    _optionHoverTimes = List.filled(_questions.length, 0);
    _isVisited[0] = true;

    // Initialize hints for each question
    _hints = _questions.map((q) => _generateHint(q)).toList();

    _optionAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _optionFadeAnim = CurvedAnimation(
      parent: _optionAnimController,
      curve: Curves.easeOut,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_celebrationController);

    _globalTimer = GlobalTimerState(
      totalSeconds: widget.subject.totalMinutes * 60,
    );
    _globalTimer.onTick = () {
      if (mounted) {
        setState(() {});
        if (_globalTimer.remainingSeconds == 600 ||
            _globalTimer.remainingSeconds == 300 ||
            _globalTimer.remainingSeconds == 60) {
          _showTimerWarning(_globalTimer.remainingSeconds);
        }
      }
    };
    _globalTimer.onExpired = () {
      if (mounted) _autoSubmitOnExpiry();
    };
    _globalTimer.start();
    _optionAnimController.forward();

    _filteredIndices = List.generate(_questions.length, (i) => i);
    _loadUserPreferences();

    // Start splash screen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  String _generateHint(QuizQuestion q) {
    final hints = [
      'Read the question carefully!',
      'Think about the key concept here.',
      'Consider the definition of ${q.topic}.',
      'What would be the most logical answer?',
      'Remember the examples from class.',
      'Focus on the ${q.difficulty} level concepts.',
    ];
    return hints[Random().nextInt(hints.length)];
  }

  void _loadUserPreferences() async {
    // Simulate loading preferences
    await Future.delayed(Duration.zero);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _globalTimer.pause();
      _isPaused = true;
    } else if (state == AppLifecycleState.resumed) {
      _globalTimer.resume();
      _isPaused = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _globalTimer.stop();
    _optionAnimController.dispose();
    _celebrationController.dispose();
    _keyboardFocus.dispose();
    _paletteScrollController.dispose();
    _searchScrollController.dispose();
    super.dispose();
  }

  void _showTimerWarning(int secondsLeft) {
    if (!mounted) return;
    final msg = secondsLeft == 600
        ? '⚠️ 10 minutes remaining!'
        : secondsLeft == 300
        ? '🔴 5 minutes remaining!'
        : '🚨 Last 1 minute!';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        backgroundColor: secondsLeft <= 60 ? _error : _warning,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (_soundEnabled) _playSound('warning');
  }

  void _playSound(String type) {
    // Sound implementation placeholder
    print('Playing sound: $type');
  }

  void _vibrate() {
    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void _autoSubmitOnExpiry() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '⏰ Time expired! Auto-submitting...',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: _error,
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), _submitQuiz);
  }

  void _navigateTo(int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
      _isVisited[index] = true;
    });
    _optionAnimController.reset();
    _optionAnimController.forward();

    // Update current hint
    _currentHint = _hints[_currentIndex];
    _hintIndex = _currentIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_paletteScrollController.hasClients) {
        final itemsPerRow = ResponsiveHelper.paletteColumns(
          ResponsiveHelper.panelWidth(context),
        );
        final row = index ~/ itemsPerRow;
        final offset = row * 46.0;
        _paletteScrollController.animateTo(
          offset.clamp(0, _paletteScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _selectAnswer(int optionIndex) {
    if (_isLocked[_currentIndex]) return;

    final startTime = DateTime.now();
    final isCorrect = optionIndex == _questions[_currentIndex].correctIndex;

    setState(() {
      _selectedAnswers[_currentIndex] = optionIndex;
      _isLocked[_currentIndex] = true;
      _showAnswerFeedback[_currentIndex] = true;
      _attemptCounts[_currentIndex]++;
      _lastAttemptTime[_currentIndex] = DateTime.now();
      _questionTimes[_currentIndex] =
          (_globalTimer.totalSeconds - _globalTimer.remainingSeconds) as double;

      if (isCorrect) {
        _streakCount++;
        if (_streakCount > _bestStreak) _bestStreak = _streakCount;
        _recentlyCorrect.add(_questions[_currentIndex].topic);
        if (_recentlyCorrect.length > 5) _recentlyCorrect.removeAt(0);

        // Update topic mastery
        _topicMastery[_questions[_currentIndex].topic] =
            (_topicMastery[_questions[_currentIndex].topic] ?? 0) + 1;

        if (_soundEnabled) _playSound('correct');
        _vibrate();

        // Show celebration for streak
        if (_streakCount >= 5 && _streakCount % 5 == 0) {
          _showConfetti = true;
          _celebrationController.forward();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _showConfetti = false);
          });
        }
      } else {
        _streakCount = 0;
        if (_soundEnabled) _playSound('incorrect');
        _vibrate();
      }
    });

    // Auto-advance after delay
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _currentIndex < _questions.length - 1) {
        _navigateTo(_currentIndex + 1);
      }
    });
  }

  void _toggleBookmark() => setState(
    () => _isBookmarked[_currentIndex] = !_isBookmarked[_currentIndex],
  );
  void _toggleMarkForReview() => setState(
    () =>
        _isMarkedForReview[_currentIndex] = !_isMarkedForReview[_currentIndex],
  );
  void _toggleStar() =>
      setState(() => _isStarred[_currentIndex] = !_isStarred[_currentIndex]);
  void _toggleElimination() =>
      setState(() => _eliminationMode = !_eliminationMode);
  void _toggleStatsPanel() =>
      setState(() => _showStatsPanel = !_showStatsPanel);
  void _toggleFocusMode() => setState(() => _focusMode = !_focusMode);
  void _toggleHideAnswered() => setState(() => _hideAnswered = !_hideAnswered);
  void _toggleAutoSave() => setState(() => _autoSave = !_autoSave);
  void _toggleSound() => setState(() => _soundEnabled = !_soundEnabled);
  void _toggleVibration() =>
      setState(() => _vibrationEnabled = !_vibrationEnabled);
  void _toggleMasteryIndicator() =>
      setState(() => _showMasteryIndicator = !_showMasteryIndicator);
  void _toggleSmartSuggestions() =>
      setState(() => _smartSuggestions = !_smartSuggestions);

  void _showNextHint() {
    if (_hintIndex < _questions.length - 1) {
      setState(() {
        _hintIndex++;
        _currentHint = _hints[_hintIndex];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '💡 ${_currentHint}',
            style: const TextStyle(fontSize: 12),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _eliminateOption(int optionIndex) {
    if (_isLocked[_currentIndex]) return;
    setState(() {
      if (_eliminatedOptions[_currentIndex].contains(optionIndex)) {
        _eliminatedOptions[_currentIndex].remove(optionIndex);
      } else {
        _eliminatedOptions[_currentIndex].add(optionIndex);
      }
    });
  }

  void _resetCurrentQuestion() {
    if (_isLocked[_currentIndex]) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Reset Question?'),
          content: const Text(
            'This will clear your answer for this question. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedAnswers[_currentIndex] = null;
                  _isLocked[_currentIndex] = false;
                  _showAnswerFeedback[_currentIndex] = false;
                  _eliminatedOptions[_currentIndex].clear();
                });
                Navigator.pop(context);
                _vibrate();
              },
              style: ElevatedButton.styleFrom(backgroundColor: _error),
              child: const Text('Reset'),
            ),
          ],
        ),
      );
    }
  }

  void _jumpToFirstUnanswered() {
    final index = _selectedAnswers.indexWhere((a) => a == null);
    if (index != -1) _navigateTo(index);
  }

  void _jumpToFirstMarked() {
    final index = _isMarkedForReview.indexWhere((m) => m);
    if (index != -1) _navigateTo(index);
  }

  void _jumpToFirstBookmarked() {
    final index = _isBookmarked.indexWhere((b) => b);
    if (index != -1) _navigateTo(index);
  }

  void _applyFilters() {
    setState(() {
      _filteredIndices = List.generate(_questions.length, (i) => i).where((i) {
        if (_selectedDifficulty != 'all' &&
            _questions[i].difficulty != _selectedDifficulty)
          return false;
        if (_selectedTopic != 'all' && _questions[i].topic != _selectedTopic)
          return false;
        if (_hideAnswered && _selectedAnswers[i] != null) return false;
        if (_searchQuery.isNotEmpty &&
            !_questions[i].question.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) &&
            !_questions[i].topic.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ))
          return false;
        return true;
      }).toList();
    });
  }

  List<String> get _availableTopics {
    return _questions.map((q) => q.topic).toSet().toList();
  }

  int get _attemptedCount => _selectedAnswers.where((a) => a != null).length;
  int get _bookmarkedCount => _isBookmarked.where((b) => b).length;
  int get _markedForReviewCount => _isMarkedForReview.where((m) => m).length;
  int get _starredCount => _isStarred.where((s) => s).length;
  double get _completionPercentage => _attemptedCount / _questions.length * 100;
  String get _streakEmoji => _streakCount >= 10
      ? '🔥'
      : _streakCount >= 5
      ? '⚡'
      : '📝';

  bool get _canSubmit => _attemptedCount >= _minQuestionsToSubmit;

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    if (_isLocked[_currentIndex]) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          _currentIndex < _questions.length - 1)
        _navigateTo(_currentIndex + 1);
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft && _currentIndex > 0)
        _navigateTo(_currentIndex - 1);
      return;
    }
    final q = _questions[_currentIndex];
    if (event.logicalKey == LogicalKeyboardKey.keyA && q.options.length > 0)
      _selectAnswer(0);
    if (event.logicalKey == LogicalKeyboardKey.keyB && q.options.length > 1)
      _selectAnswer(1);
    if (event.logicalKey == LogicalKeyboardKey.keyC && q.options.length > 2)
      _selectAnswer(2);
    if (event.logicalKey == LogicalKeyboardKey.keyD && q.options.length > 3)
      _selectAnswer(3);
    if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        _currentIndex < _questions.length - 1)
      _navigateTo(_currentIndex + 1);
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && _currentIndex > 0)
      _navigateTo(_currentIndex - 1);
    if (event.logicalKey == LogicalKeyboardKey.keyB) _toggleBookmark();
    if (event.logicalKey == LogicalKeyboardKey.keyR) _toggleMarkForReview();
    if (event.logicalKey == LogicalKeyboardKey.keyS) _toggleStar();
    if (event.logicalKey == LogicalKeyboardKey.keyH) _showNextHint();
  }

  void _showSubmitDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubmitPreviewSheet(
        questions: _questions,
        selectedAnswers: _selectedAnswers,
        onConfirm: _submitQuiz,
        canSubmit: _canSubmit,
        attemptedCount: _attemptedCount,
        markedForReviewCount: _markedForReviewCount,
        bookmarkedCount: _bookmarkedCount,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exit Exam?'),
        content: const Text(
          'Your progress will be lost if you exit now. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: _error),
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  void _submitQuiz() {
    _globalTimer.stop();
    final timeTaken = _globalTimer.totalSeconds - _globalTimer.remainingSeconds;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultScreen(
          questions: _questions,
          selectedAnswers: _selectedAnswers,
          studentName: widget.studentName,
          subject: widget.subject,
          timeTakenSeconds: timeTaken,
          streakCount: _bestStreak,
          topicMastery: _topicMastery,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = _ThemeProvider.of(context);
    final question = _questions[_currentIndex];
    final isLocked = _isLocked[_currentIndex];
    final showFeedback = _showAnswerFeedback[_currentIndex];
    final selectedAnswer = _selectedAnswers[_currentIndex];
    final isCorrect =
        selectedAnswer != null && selectedAnswer == question.correctIndex;

    if (_showSplash) {
      return Scaffold(
        backgroundColor: themeState.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: _primary),
              const SizedBox(height: 20),
              Text(
                'Loading ${widget.subject.code} Test...',
                style: TextStyle(color: themeState.textPrimary, fontSize: 18),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: RawKeyboardListener(
        focusNode: _keyboardFocus,
        autofocus: true,
        onKey: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: themeState.bg,
          appBar: _buildAppBar(themeState),
          body: Stack(
            children: [
              Column(
                children: [
                  _GlobalTimerBar(timerState: _globalTimer),
                  if (_focusMode)
                    Expanded(
                      child: _buildFocusModeQuestionArea(
                        context,
                        question,
                        isLocked,
                        showFeedback,
                        selectedAnswer,
                        isCorrect,
                        themeState,
                      ),
                    )
                  else
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildQuestionArea(
                                    context,
                                    question,
                                    isLocked,
                                    showFeedback,
                                    selectedAnswer,
                                    isCorrect,
                                    themeState,
                                  ),
                                ),
                                SizedBox(
                                  width: ResponsiveHelper.panelWidth(context),
                                  child: _buildSidePanel(themeState),
                                ),
                              ],
                            );
                          } else {
                            return _buildQuestionArea(
                              context,
                              question,
                              isLocked,
                              showFeedback,
                              selectedAnswer,
                              isCorrect,
                              themeState,
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
              if (_showQuickNav && ResponsiveHelper.isMobile(context))
                Positioned(bottom: 80, right: 16, child: _buildQuickNavMenu()),
            ],
          ),
          bottomNavigationBar: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 700 && !_focusMode)
                return _buildMobileBottomBar(themeState);
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: _buildFloatingButtons(),
        ),
      ),
    );
  }

  Widget? _buildFloatingButtons() {
    if (_focusMode) return null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'stats',
          onPressed: _toggleStatsPanel,
          backgroundColor: _infoColor,
          child: const Icon(Icons.bar_chart, size: 20),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'focus',
          onPressed: _toggleFocusMode,
          backgroundColor: _focusMode ? _success : _primary,
          child: Icon(
            _focusMode ? Icons.fullscreen_exit : Icons.fullscreen,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'search',
          onPressed: () => setState(() => _showQuickNav = !_showQuickNav),
          backgroundColor: _primaryLight,
          child: const Icon(Icons.search, size: 20),
        ),
      ],
    );
  }

  Widget _buildSidePanel(AppThemeState t) {
    return Container(
      color: t.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _buildStatsMiniCard(t),
            const Divider(),
            _buildFiltersCard(t),
            const Divider(),
            _buildStreakCard(t),
            const Divider(),
            _buildMasteryCard(t),
            const Divider(),
            _buildSettingsCard(t),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsMiniCard(AppThemeState t) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: t.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStatCard(
                  'Attempted',
                  '$_attemptedCount/${_questions.length}',
                  _completionPercentage,
                  _success,
                ),
                _MiniStatCard(
                  'Bookmarked',
                  '$_bookmarkedCount',
                  _bookmarkedCount / _questions.length * 100,
                  _bookmarkColor,
                ),
                _MiniStatCard(
                  'Review',
                  '$_markedForReviewCount',
                  _markedForReviewCount / _questions.length * 100,
                  _reviewColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _completionPercentage / 100,
              backgroundColor: t.border,
            ),
            const SizedBox(height: 4),
            Text(
              '${_completionPercentage.toStringAsFixed(0)}% Complete',
              style: TextStyle(color: t.textSecondary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _MiniStatCard(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard(AppThemeState t) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: t.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            DropdownButton<String>(
              value: _selectedDifficulty,
              isExpanded: true,
              items: ['all', 'easy', 'medium', 'hard']
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(d, style: const TextStyle(fontSize: 11)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() => _selectedDifficulty = v!);
                _applyFilters();
              },
              underline: const SizedBox(),
            ),
            const SizedBox(height: 6),
            DropdownButton<String>(
              value: _selectedTopic,
              isExpanded: true,
              items:
                  [
                        ['all', 'All'],
                        ..._availableTopics.map((t) => [t, t]),
                      ]
                      .map(
                        (item) => DropdownMenuItem(
                          value: item[0],
                          child: Text(
                            item[1],
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (v) {
                setState(() => _selectedTopic = v!);
                _applyFilters();
              },
              underline: const SizedBox(),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    value: _hideAnswered,
                    onChanged: (_) => _toggleHideAnswered(),
                    title: const Text(
                      'Hide Done',
                      style: TextStyle(fontSize: 10),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(AppThemeState t) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: t.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🔥 Streak: $_streakCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '🏆 Best: $_bestStreak',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: _streakCount / 10,
              backgroundColor: t.border,
              valueColor: const AlwaysStoppedAnimation(_gold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryCard(AppThemeState t) {
    if (!_showMasteryIndicator) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.all(8),
      color: t.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Topic Mastery',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            ..._topicMastery.entries
                .take(3)
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            e.key,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: LinearProgressIndicator(
                            value: (e.value / 5).clamp(0.0, 1.0),
                            backgroundColor: t.border,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${e.value}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(AppThemeState t) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: t.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.volume_up, size: 14, color: t.textSecondary),
                const SizedBox(width: 4),
                const Text('Sound', style: TextStyle(fontSize: 11)),
                const Spacer(),
                Switch(
                  value: _soundEnabled,
                  onChanged: (_) => _toggleSound(),
                  activeColor: _primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.vibration, size: 14, color: t.textSecondary),
                const SizedBox(width: 4),
                const Text('Vibration', style: TextStyle(fontSize: 11)),
                const Spacer(),
                Switch(
                  value: _vibrationEnabled,
                  onChanged: (_) => _toggleVibration(),
                  activeColor: _primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: t.textSecondary),
                const SizedBox(width: 4),
                const Text('Auto Save', style: TextStyle(fontSize: 11)),
                const Spacer(),
                Switch(
                  value: _autoSave,
                  onChanged: (_) => _toggleAutoSave(),
                  activeColor: _primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusModeQuestionArea(
    BuildContext context,
    QuizQuestion question,
    bool isLocked,
    bool showFeedback,
    int? selectedAnswer,
    bool isCorrect,
    AppThemeState t,
  ) {
    return Container(
      color: _darkBg,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  question.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                ...List.generate(
                  question.options.length,
                  (i) => GestureDetector(
                    onTap: () => _selectAnswer(i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedAnswer == i ? _primary : _darkBorder,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              String.fromCharCode(65 + i),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.options[i],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentIndex > 0)
                      ElevatedButton(
                        onPressed: () => _navigateTo(_currentIndex - 1),
                        child: const Text('Previous'),
                      ),
                    const SizedBox(width: 16),
                    if (_currentIndex < _questions.length - 1)
                      ElevatedButton(
                        onPressed: () => _navigateTo(_currentIndex + 1),
                        child: const Text('Next'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionArea(
    BuildContext context,
    QuizQuestion question,
    bool isLocked,
    bool showFeedback,
    int? selectedAnswer,
    bool isCorrect,
    AppThemeState t,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: _primary.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _QuestionCard(
            question: question,
            currentIndex: _currentIndex,
            subjectCode: widget.subject.code,
            isLocked: isLocked,
            isCorrect: isCorrect,
            isBookmarked: _isBookmarked[_currentIndex],
            isMarkedForReview: _isMarkedForReview[_currentIndex],
            isStarred: _isStarred[_currentIndex],
            themeState: t,
            onBookmark: _toggleBookmark,
            onMarkForReview: _toggleMarkForReview,
            onStar: _toggleStar,
            note: _questionNotes[_currentIndex],
            onNoteChanged: (v) =>
                setState(() => _questionNotes[_currentIndex] = v),
          ),
          const SizedBox(height: 14),

          if (_smartSuggestions && _streakCount < 3 && !isLocked)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: _infoColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentHint,
                      style: const TextStyle(color: _infoColor, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    onPressed: _showNextHint,
                  ),
                ],
              ),
            ),

          if (!isLocked)
            GestureDetector(
              onTap: _toggleElimination,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _eliminationMode ? _error.withOpacity(0.1) : t.border,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _eliminationMode ? _error : t.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      size: 16,
                      color: _eliminationMode ? _error : t.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Elimination Mode',
                      style: TextStyle(
                        color: _eliminationMode ? _error : t.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),

          FadeTransition(
            opacity: _optionFadeAnim,
            child: Column(
              children: List.generate(
                question.options.length,
                (i) => _OptionTileWithFeedback(
                  option: question.options[i],
                  index: i,
                  isSelected: _selectedAnswers[_currentIndex] == i,
                  isCorrect: question.correctIndex == i,
                  isLocked: isLocked,
                  showResult: showFeedback,
                  correctAnswer: question.options[question.correctIndex],
                  onTap: () =>
                      _eliminationMode ? _eliminateOption(i) : _selectAnswer(i),
                  isEliminated: _eliminatedOptions[_currentIndex].contains(i),
                  eliminationMode: _eliminationMode,
                  themeState: t,
                  fontSize: ResponsiveHelper.optionFontSize(context),
                ),
              ),
            ),
          ),

          if (showFeedback)
            _FeedbackBox(
              question: question,
              isCorrect: isCorrect,
              selectedAnswer: selectedAnswer,
              themeState: t,
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateTo(_currentIndex - 1),
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: const BorderSide(color: _primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: 10),
              if (_currentIndex < _questions.length - 1)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateTo(_currentIndex + 1),
                    icon: const Icon(Icons.chevron_right_rounded),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              if (_currentIndex == _questions.length - 1)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showSubmitDialog,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick actions row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionChip(
                icon: Icons.refresh,
                label: 'Reset Q',
                onTap: _resetCurrentQuestion,
                color: _error,
              ),
              _QuickActionChip(
                icon: Icons.skip_next,
                label: 'First Unanswered',
                onTap: _jumpToFirstUnanswered,
                color: _primary,
              ),
              _QuickActionChip(
                icon: Icons.flag,
                label: 'Marked',
                onTap: _jumpToFirstMarked,
                color: _reviewColor,
              ),
              _QuickActionChip(
                icon: Icons.bookmark,
                label: 'Bookmarked',
                onTap: _jumpToFirstBookmarked,
                color: _bookmarkColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavMenu() {
    return Card(
      elevation: 8,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _showQuickNav = false),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (v) {
                setState(() => _searchQuery = v);
                _applyFilters();
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                controller: _searchScrollController,
                itemCount: _filteredIndices.length,
                itemBuilder: (_, idx) {
                  final i = _filteredIndices[idx];
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedAnswers[i] != null
                            ? _success
                            : _greyLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: _selectedAnswers[i] != null
                              ? Colors.white
                              : _textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      _questions[i].question.length > 40
                          ? '${_questions[i].question.substring(0, 40)}...'
                          : _questions[i].question,
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      _questions[i].topic,
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: _isBookmarked[i]
                        ? const Icon(
                            Icons.bookmark,
                            size: 16,
                            color: _bookmarkColor,
                          )
                        : null,
                    onTap: () {
                      setState(() => _showQuickNav = false);
                      _navigateTo(i);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBottomBar(AppThemeState t) {
    return SafeArea(
      child: Container(
        color: t.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _showSubmitDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSubmit ? _success : _grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _canSubmit
                      ? 'Submit Test'
                      : 'Attempt $_minQuestionsToSubmit+ to Submit',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _PaletteBottomSheet(
              total: _questions.length,
              currentIndex: _currentIndex,
              selectedAnswers: _selectedAnswers,
              isBookmarked: _isBookmarked,
              isMarkedForReview: _isMarkedForReview,
              isVisited: _isVisited,
              onTap: _navigateTo,
              themeState: t,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppThemeState t) {
    return AppBar(
      title: Text(
        '${widget.subject.code} – Q${_currentIndex + 1}/${_questions.length}',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () async {
          if (await _onWillPop()) Navigator.pop(context);
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _globalTimer.isCritical
                ? _error.withOpacity(0.9)
                : _globalTimer.isLow
                ? _warning.withOpacity(0.8)
                : Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                _globalTimer.formattedRemaining,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            color: Colors.white,
          ),
          onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart, color: Colors.white),
          onPressed: _toggleStatsPanel,
        ),
        IconButton(
          icon: const Icon(Icons.send_rounded, size: 18),
          onPressed: _showSubmitDialog,
          tooltip: 'Submit Test',
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onTap,
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}

// Question Card Updated
class _QuestionCard extends StatefulWidget {
  final QuizQuestion question;
  final int currentIndex;
  final String subjectCode;
  final bool isLocked, isCorrect, isBookmarked, isMarkedForReview, isStarred;
  final AppThemeState themeState;
  final VoidCallback onBookmark, onMarkForReview, onStar;
  final String note;
  final ValueChanged<String> onNoteChanged;

  const _QuestionCard({
    required this.question,
    required this.currentIndex,
    required this.subjectCode,
    required this.isLocked,
    required this.isCorrect,
    required this.isBookmarked,
    required this.isMarkedForReview,
    required this.isStarred,
    required this.themeState,
    required this.onBookmark,
    required this.onMarkForReview,
    required this.onStar,
    required this.note,
    required this.onNoteChanged,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _showNote = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.themeState;
    final diffColor = widget.question.difficulty == 'easy'
        ? _success
        : widget.question.difficulty == 'hard'
        ? _error
        : _warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q ${widget.currentIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.subjectCode,
                  style: const TextStyle(
                    color: Color(0xFFF57F17),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: diffColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: diffColor.withOpacity(0.4)),
                ),
                child: Text(
                  widget.question.difficulty.toUpperCase(),
                  style: TextStyle(
                    color: diffColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.question.topic,
                  style: const TextStyle(
                    color: _primaryLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.isLocked)
                Icon(
                  widget.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: widget.isCorrect ? _success : _error,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.question.question,
            style: TextStyle(
              color: t.textPrimary,
              fontSize: ResponsiveHelper.questionFontSize(context),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _IconBtn(
                icon: widget.isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: _bookmarkColor,
                active: widget.isBookmarked,
                label: 'Bookmark',
                onTap: widget.onBookmark,
              ),
              const SizedBox(width: 8),
              _IconBtn(
                icon: Icons.flag,
                color: _reviewColor,
                active: widget.isMarkedForReview,
                label: 'Review',
                onTap: widget.onMarkForReview,
              ),
              const SizedBox(width: 8),
              _IconBtn(
                icon: widget.isStarred ? Icons.star : Icons.star_border,
                color: _gold,
                active: widget.isStarred,
                label: 'Star',
                onTap: widget.onStar,
              ),
              const SizedBox(width: 8),
              _IconBtn(
                icon: Icons.note_alt_outlined,
                color: _primary,
                active: _showNote,
                label: 'Note',
                onTap: () => setState(() => _showNote = !_showNote),
              ),
            ],
          ),
          if (_showNote) ...[
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: widget.note)
                ..selection = TextSelection.collapsed(
                  offset: widget.note.length,
                ),
              onChanged: widget.onNoteChanged,
              maxLines: 2,
              style: TextStyle(color: t.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add a note for this question...',
                hintStyle: TextStyle(color: t.textSecondary, fontSize: 13),
                filled: true,
                fillColor: t.inputFill,
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool active;
  final String label;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.active,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : _greyLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? color.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? color : _textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active ? color : _textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Option Tile
class _OptionTileWithFeedback extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected,
      isCorrect,
      isLocked,
      showResult,
      isEliminated,
      eliminationMode;
  final String correctAnswer;
  final VoidCallback onTap;
  final AppThemeState themeState;
  final double fontSize;

  const _OptionTileWithFeedback({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.isLocked,
    required this.showResult,
    required this.correctAnswer,
    required this.onTap,
    required this.isEliminated,
    required this.eliminationMode,
    required this.themeState,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeState;
    Color borderColor = t.border;
    Color bgColor = t.cardBg;
    Color textColor = t.textPrimary;
    Widget? trailingIcon;

    if (isEliminated && !showResult) {
      bgColor = _grey.withOpacity(0.08);
      borderColor = _grey.withOpacity(0.4);
      textColor = _grey;
    } else if (showResult) {
      if (isCorrect) {
        borderColor = _success;
        bgColor = _success.withOpacity(0.15);
        textColor = _success;
        trailingIcon = const Icon(
          Icons.check_circle,
          color: _success,
          size: 20,
        );
      } else if (isSelected && !isCorrect) {
        borderColor = _error;
        bgColor = _error.withOpacity(0.15);
        textColor = _error;
        trailingIcon = const Icon(Icons.cancel, color: _error, size: 20);
      }
    } else if (isSelected) {
      borderColor = _primary;
      bgColor = _primary.withOpacity(0.08);
      textColor = _primary;
      trailingIcon = const Icon(Icons.check_circle, color: _primary, size: 20);
    }

    final labels = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: (!isLocked || eliminationMode) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? (showResult ? (isCorrect ? _success : _error) : _primary)
                    : (showResult && isCorrect ? _success : t.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: (isSelected || (showResult && isCorrect))
                      ? Colors.white
                      : t.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  decoration: isEliminated && !showResult
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            if (eliminationMode && !isLocked)
              Icon(
                isEliminated
                    ? Icons.add_circle_outline
                    : Icons.remove_circle_outline,
                color: isEliminated ? _success : _error,
                size: 18,
              ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon!,
            ],
          ],
        ),
      ),
    );
  }
}

// Feedback Box
class _FeedbackBox extends StatelessWidget {
  final QuizQuestion question;
  final bool isCorrect;
  final int? selectedAnswer;
  final AppThemeState themeState;

  const _FeedbackBox({
    required this.question,
    required this.isCorrect,
    required this.selectedAnswer,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? _success.withOpacity(0.1) : _error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? _success.withOpacity(0.3)
              : _error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_outline : Icons.info_outline,
                color: isCorrect ? _success : _primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect
                    ? '✓ Correct!'
                    : selectedAnswer == null
                    ? '⏰ Timed Out'
                    : '✗ Incorrect',
                style: TextStyle(
                  color: isCorrect ? _success : _error,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.description,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (!isCorrect && selectedAnswer != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: _success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Correct: ${question.options[question.correctIndex]}',
                      style: const TextStyle(
                        color: _success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Global Timer Bar
class _GlobalTimerBar extends StatelessWidget {
  final GlobalTimerState timerState;
  const _GlobalTimerBar({required this.timerState});

  @override
  Widget build(BuildContext context) {
    final color = timerState.isCritical
        ? _error
        : timerState.isLow
        ? _warning
        : _success;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: color.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                'Time Remaining: ',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                timerState.formattedRemaining,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                'Used: ${timerState.formattedUsed}',
                style: const TextStyle(color: _textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: timerState.progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 4,
        ),
      ],
    );
  }
}

// Question Palette (Simplified - keeping existing working implementation)
class _QuestionPalette extends StatelessWidget {
  final int total, currentIndex, attemptedCount;
  final List<int?> selectedAnswers;
  final List<bool> isBookmarked, isMarkedForReview, isVisited;
  final ScrollController scrollController;
  final double panelWidth;
  final void Function(int) onTap;
  final AppThemeState themeState;

  const _QuestionPalette({
    required this.total,
    required this.currentIndex,
    required this.selectedAnswers,
    required this.isBookmarked,
    required this.isMarkedForReview,
    required this.isVisited,
    required this.scrollController,
    required this.panelWidth,
    required this.onTap,
    required this.attemptedCount,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    final crossCount = ResponsiveHelper.paletteColumns(panelWidth);

    return Container(
      color: themeState.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: _primary,
            child: const Text(
              'Q Palette',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(6),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: total,
              itemBuilder: (_, i) => _PaletteCell(
                index: i,
                isCurrent: i == currentIndex,
                isAttempted: selectedAnswers[i] != null,
                isBookmarked: isBookmarked[i],
                isMarkedForReview: isMarkedForReview[i],
                isVisited: isVisited[i],
                onTap: () => onTap(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteCell extends StatelessWidget {
  final int index;
  final bool isCurrent, isAttempted, isBookmarked, isMarkedForReview, isVisited;
  final VoidCallback onTap;

  const _PaletteCell({
    required this.index,
    required this.isCurrent,
    required this.isAttempted,
    required this.isBookmarked,
    required this.isMarkedForReview,
    required this.isVisited,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (isCurrent)
      bg = _primary;
    else if (isMarkedForReview)
      bg = _reviewColor.withOpacity(0.8);
    else if (isBookmarked)
      bg = _bookmarkColor.withOpacity(0.8);
    else if (isAttempted)
      bg = _successLight;
    else if (isVisited)
      bg = _greyLight;
    else
      bg = _greyLight;

    final textColor =
        (isCurrent || isAttempted || isMarkedForReview || isBookmarked)
        ? Colors.white
        : _textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            if (isBookmarked && !isCurrent)
              const Positioned(
                top: 2,
                right: 2,
                child: Icon(Icons.bookmark, size: 8, color: Colors.white),
              ),
            if (isMarkedForReview && !isCurrent)
              const Positioned(
                top: 2,
                left: 2,
                child: Icon(Icons.flag, size: 8, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

// Mobile palette bottom sheet
class _PaletteBottomSheet extends StatelessWidget {
  final int total, currentIndex;
  final List<int?> selectedAnswers;
  final List<bool> isBookmarked, isMarkedForReview, isVisited;
  final void Function(int) onTap;
  final AppThemeState themeState;

  const _PaletteBottomSheet({
    required this.total,
    required this.currentIndex,
    required this.selectedAnswers,
    required this.isBookmarked,
    required this.isMarkedForReview,
    required this.isVisited,
    required this.onTap,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: themeState.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _greyLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Question Palette',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _QuestionPalette(
                    total: total,
                    currentIndex: currentIndex,
                    selectedAnswers: selectedAnswers,
                    isBookmarked: isBookmarked,
                    isMarkedForReview: isMarkedForReview,
                    isVisited: isVisited,
                    scrollController: ScrollController(),
                    panelWidth: MediaQuery.of(context).size.width,
                    onTap: (i) {
                      Navigator.pop(context);
                      onTap(i);
                    },
                    attemptedCount: selectedAnswers
                        .where((a) => a != null)
                        .length,
                    themeState: themeState,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      icon: const Icon(Icons.grid_view_rounded, size: 18),
      label: const Text('Palette'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }
}

// Submit Preview Sheet
class _SubmitPreviewSheet extends StatelessWidget {
  final List<QuizQuestion> questions;
  final List<int?> selectedAnswers;
  final VoidCallback onConfirm;
  final bool canSubmit;
  final int attemptedCount, markedForReviewCount, bookmarkedCount;

  const _SubmitPreviewSheet({
    required this.questions,
    required this.selectedAnswers,
    required this.onConfirm,
    required this.canSubmit,
    required this.attemptedCount,
    required this.markedForReviewCount,
    required this.bookmarkedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Submit Test?',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatPill(
                  label: 'Attempted',
                  value: '$attemptedCount',
                  color: _success,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  label: 'Skipped',
                  value: '${questions.length - attemptedCount}',
                  color: _grey,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  label: 'Review',
                  value: '$markedForReviewCount',
                  color: _reviewColor,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  label: 'Saved',
                  value: '$bookmarkedCount',
                  color: _bookmarkColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!canSubmit)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: _error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You need at least $_minQuestionsToSubmit attempted questions. Currently: $attemptedCount.',
                        style: const TextStyle(color: _error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            if (markedForReviewCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _reviewColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _reviewColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: _reviewColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$markedForReviewCount question(s) are still marked for review.',
                        style: const TextStyle(
                          color: _reviewColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Question Summary',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(questions.length, (i) {
                final isAttempted = selectedAnswers[i] != null;
                return Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isAttempted ? _successLight : _greyLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: isAttempted ? Colors.white : _textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textSecondary,
                      side: const BorderSide(color: _greyLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canSubmit
                        ? () {
                            Navigator.pop(context);
                            onConfirm();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _success,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Submit Now',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
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

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SCREEN 5 – RESULT (UPDATED)
// ─────────────────────────────────────────────

class ResultScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final List<int?> selectedAnswers;
  final String studentName;
  final Subject subject;
  final int timeTakenSeconds;
  final int streakCount;
  final Map<String, int> topicMastery;

  const ResultScreen({
    super.key,
    required this.questions,
    required this.selectedAnswers,
    required this.studentName,
    required this.subject,
    required this.timeTakenSeconds,
    this.streakCount = 0,
    this.topicMastery = const {},
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  bool _showReview = false;
  bool _showDetailedAnalytics = false;
  late AnimationController _scoreAnim;
  late Animation<double> _scoreScale;

  @override
  void initState() {
    super.initState();
    _scoreAnim = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _scoreScale = CurvedAnimation(parent: _scoreAnim, curve: Curves.elasticOut);
    _scoreAnim.forward();
  }

  @override
  void dispose() {
    _scoreAnim.dispose();
    super.dispose();
  }

  int get _correct => List.generate(
    widget.questions.length,
    (i) =>
        widget.selectedAnswers[i] == widget.questions[i].correctIndex ? 1 : 0,
  ).fold(0, (a, b) => a + b);
  int get _wrong => List.generate(
    widget.questions.length,
    (i) =>
        widget.selectedAnswers[i] != null &&
            widget.selectedAnswers[i] != widget.questions[i].correctIndex
        ? 1
        : 0,
  ).fold(0, (a, b) => a + b);
  int get _skipped => widget.selectedAnswers.where((a) => a == null).length;
  double get _percentage => _correct / widget.questions.length * 100;
  double get _accuracy =>
      _correct + _wrong == 0 ? 0 : _correct / (_correct + _wrong) * 100;

  String get _formattedTime {
    final m = widget.timeTakenSeconds ~/ 60;
    final s = widget.timeTakenSeconds % 60;
    return '${m}m ${s}s';
  }

  String get _avgTimePerQ {
    if (_correct + _wrong == 0) return 'N/A';
    final avg = widget.timeTakenSeconds / (_correct + _wrong);
    return '${avg.toStringAsFixed(0)}s';
  }

  String get _performanceMessage {
    if (_percentage >= 80) return 'Excellent! 🎉';
    if (_percentage >= 60) return 'Good Job! 👍';
    if (_percentage >= 40) return 'Keep Trying! 📚';
    return 'Needs Improvement 💪';
  }

  Color get _performanceColor {
    if (_percentage >= 80) return _success;
    if (_percentage >= 60) return _primaryLight;
    if (_percentage >= 40) return const Color(0xFFF57F17);
    return _error;
  }

  Map<String, List<bool>> get _topicPerformance {
    final map = <String, List<bool>>{};
    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      map.putIfAbsent(q.topic, () => []);
      map[q.topic]!.add(widget.selectedAnswers[i] == q.correctIndex);
    }
    return map;
  }

  List<String> get _weakTopics {
    return _topicPerformance.entries
        .where((e) {
          final correct = e.value.where((v) => v).length;
          return correct / e.value.length < 0.5;
        })
        .map((e) => e.key)
        .toList();
  }

  List<String> get _strongTopics {
    return _topicPerformance.entries
        .where((e) {
          final correct = e.value.where((v) => v).length;
          return correct / e.value.length >= 0.8;
        })
        .map((e) => e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = _ThemeProvider.of(context);
    return Scaffold(
      backgroundColor: themeState.bg,
      appBar: AppBar(
        title: Text(
          '${widget.subject.code} Result',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (r) => false,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => setState(
              () => _showDetailedAnalytics = !_showDetailedAnalytics,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 32 : 16),
            child: isWide
                ? _buildWideResult(context, themeState)
                : _buildNarrowResult(context, themeState),
          );
        },
      ),
    );
  }

  Widget _buildWideResult(BuildContext ctx, AppThemeState t) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildScoreCard(),
              const SizedBox(height: 16),
              _buildStatsGrid(t),
              const SizedBox(height: 16),
              _buildAnalytics(t),
              const SizedBox(height: 16),
              _buildWeakTopics(t),
              const SizedBox(height: 16),
              _buildAchievements(t),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              if (_showDetailedAnalytics) _buildDetailedAnalytics(t),
              if (_showDetailedAnalytics) const SizedBox(height: 16),
              _buildReviewSection(t),
              const SizedBox(height: 16),
              _buildHomeButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowResult(BuildContext ctx, AppThemeState t) {
    return Column(
      children: [
        _buildScoreCard(),
        const SizedBox(height: 16),
        _buildStatsGrid(t),
        const SizedBox(height: 16),
        _buildAnalytics(t),
        const SizedBox(height: 16),
        _buildWeakTopics(t),
        const SizedBox(height: 16),
        _buildAchievements(t),
        const SizedBox(height: 16),
        if (_showDetailedAnalytics) _buildDetailedAnalytics(t),
        if (_showDetailedAnalytics) const SizedBox(height: 16),
        _buildReviewSection(t),
        const SizedBox(height: 16),
        _buildHomeButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildScoreCard() {
    return ScaleTransition(
      scale: _scoreScale,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_performanceColor, _performanceColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _performanceColor.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              _performanceMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.studentName,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38, width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_correct/${widget.questions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${_percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.streakCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: _gold,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Best Streak: ${widget.streakCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(AppThemeState t) {
    return Row(
      children: [
        _ResultStat(
          label: 'Correct',
          value: '$_correct',
          icon: Icons.check_circle,
          color: _success,
        ),
        const SizedBox(width: 8),
        _ResultStat(
          label: 'Wrong',
          value: '$_wrong',
          icon: Icons.cancel,
          color: _error,
        ),
        const SizedBox(width: 8),
        _ResultStat(
          label: 'Skipped',
          value: '$_skipped',
          icon: Icons.remove_circle,
          color: _grey,
        ),
      ],
    );
  }

  Widget _buildAnalytics(AppThemeState t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Performance Analytics',
            style: TextStyle(
              color: t.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _AnalyticsRow(
            'Accuracy',
            '${_accuracy.toStringAsFixed(1)}%',
            _success,
            t,
          ),
          _AnalyticsRow('Time Taken', _formattedTime, _primary, t),
          _AnalyticsRow('Avg. per Question', _avgTimePerQ, _primaryLight, t),
          _AnalyticsRow(
            'Attempted',
            '${_correct + _wrong}/${widget.questions.length}',
            _warning,
            t,
          ),
          const SizedBox(height: 12),
          const Text(
            'Accuracy',
            style: TextStyle(color: _textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _accuracy / 100,
              backgroundColor: _greyLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                _accuracy >= 60 ? _success : _error,
              ),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakTopics(AppThemeState t) {
    if (_weakTopics.isEmpty && _strongTopics.isEmpty)
      return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Topic Analysis',
            style: TextStyle(
              color: _error,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (_weakTopics.isNotEmpty) ...[
            const Text(
              '⚠️ Needs Improvement:',
              style: TextStyle(
                color: _warning,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _weakTopics
                  .map(
                    (topic) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _error.withOpacity(0.3)),
                      ),
                      child: Text(
                        topic,
                        style: const TextStyle(
                          color: _error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          if (_strongTopics.isNotEmpty) ...[
            const Text(
              '✅ Strong Areas:',
              style: TextStyle(
                color: _success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _strongTopics
                  .map(
                    (topic) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _success.withOpacity(0.3)),
                      ),
                      child: Text(
                        topic,
                        style: const TextStyle(
                          color: _success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievements(AppThemeState t) {
    final achievements = <Map<String, dynamic>>[];
    if (_percentage >= 80)
      achievements.add({
        'icon': '🏆',
        'title': 'Top Performer',
        'desc': 'Scored 80% or above',
      });
    if (widget.streakCount >= 5)
      achievements.add({
        'icon': '🔥',
        'title': 'Streak Master',
        'desc': 'Got 5+ correct in a row',
      });
    if (_accuracy >= 90)
      achievements.add({
        'icon': '🎯',
        'title': 'Accuracy King',
        'desc': '90%+ accuracy',
      });
    if (_skipped == 0)
      achievements.add({
        'icon': '📖',
        'title': 'Complete Attempt',
        'desc': 'Attempted all questions',
      });

    if (achievements.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏅 Achievements Unlocked',
            style: TextStyle(
              color: _gold,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: achievements
                .map(
                  (a) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(a['icon'], style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a['title'],
                              style: const TextStyle(
                                color: _gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              a['desc'],
                              style: const TextStyle(
                                color: _textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalytics(AppThemeState t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Detailed Performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ..._topicPerformance.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  LinearProgressIndicator(
                    value: e.value.where((v) => v).length / e.value.length,
                    backgroundColor: _greyLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      e.value.where((v) => v).length / e.value.length >= 0.7
                          ? _success
                          : _warning,
                    ),
                  ),
                  Text(
                    '${e.value.where((v) => v).length}/${e.value.length} correct',
                    style: const TextStyle(fontSize: 10, color: _textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(AppThemeState t) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _showReview = !_showReview),
            icon: Icon(
              _showReview ? Icons.visibility_off : Icons.visibility,
              size: 20,
            ),
            label: Text(
              _showReview ? 'Hide Answer Review' : 'View Answer Review',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (_showReview) ...[
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Answer Review',
              style: TextStyle(
                color: t.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            widget.questions.length,
            (i) => _ReviewCard(
              question: widget.questions[i],
              selected: widget.selectedAnswers[i],
              index: i,
              themeState: t,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHomeButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
        ),
        icon: const Icon(Icons.home_rounded),
        label: const Text(
          'Back to Home',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final AppThemeState t;
  const _AnalyticsRow(this.label, this.value, this.color, this.t);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: t.textSecondary, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final QuizQuestion question;
  final int? selected;
  final int index;
  final AppThemeState themeState;

  const _ReviewCard({
    required this.question,
    required this.selected,
    required this.index,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeState;
    final isCorrect = selected == question.correctIndex;
    final isSkipped = selected == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isSkipped
              ? t.border
              : isCorrect
              ? _success.withOpacity(0.4)
              : _error.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSkipped
                  ? t.border.withOpacity(0.3)
                  : isCorrect
                  ? _success.withOpacity(0.08)
                  : _error.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Q${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question.question,
                    style: TextStyle(
                      color: t.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSkipped
                      ? Icons.remove_circle_outline
                      : isCorrect
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: isSkipped
                      ? _grey
                      : isCorrect
                      ? _success
                      : _error,
                  size: 20,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List.generate(
                question.options.length,
                (oi) => _OptionTile(
                  option: question.options[oi],
                  index: oi,
                  isSelected: selected == oi,
                  isCorrect: question.correctIndex == oi,
                  isLocked: true,
                  showResult: true,
                  onTap: () {},
                  themeState: themeState,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect
                    ? _success.withOpacity(0.1)
                    : _primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📖 Explanation:',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSkipped)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                '⚠️ This question was skipped (not answered).',
                style: TextStyle(color: _grey, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected, isCorrect, isLocked, showResult;
  final VoidCallback onTap;
  final AppThemeState themeState;

  const _OptionTile({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.isLocked,
    required this.showResult,
    required this.onTap,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    final t = themeState;
    Color borderColor = t.border;
    Color bgColor = t.cardBg;
    Color textColor = t.textPrimary;
    Widget? trailingIcon;

    if (showResult) {
      if (isCorrect) {
        borderColor = _success;
        bgColor = _success.withOpacity(0.08);
        textColor = _success;
        trailingIcon = const Icon(
          Icons.check_circle,
          color: _success,
          size: 20,
        );
      } else if (isSelected && !isCorrect) {
        borderColor = _error;
        bgColor = _error.withOpacity(0.08);
        textColor = _error;
        trailingIcon = const Icon(Icons.cancel, color: _error, size: 20);
      }
    } else if (isSelected) {
      borderColor = _primary;
      bgColor = _primary.withOpacity(0.08);
      textColor = _primary;
      trailingIcon = const Icon(Icons.check_circle, color: _primary, size: 20);
    }

    final labels = ['A', 'B', 'C', 'D'];
    return GestureDetector(
      onTap: (!isLocked && !showResult) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? (showResult ? (isCorrect ? _success : _error) : _primary)
                    : (showResult && isCorrect ? _success : t.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: (isSelected || (showResult && isCorrect))
                      ? Colors.white
                      : t.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon!,
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
