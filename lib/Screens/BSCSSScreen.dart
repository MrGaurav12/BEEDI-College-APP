import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================
// ENUMS & MODELS
// ============================================================

enum QuizState { topic, quiz, result, leaderboard, bookmarks, stats }

enum Difficulty { easy, medium, hard, all }

enum SortOrder { nameAsc, nameDesc, questionCount, difficulty }

class QuizAttempt {
  final String topic;
  final int score;
  final int total;
  final double percentage;
  final DateTime date;
  final int timeTakenSeconds;
  final bool isPracticeMode;

  QuizAttempt({
    required this.topic,
    required this.score,
    required this.total,
    required this.percentage,
    required this.date,
    required this.timeTakenSeconds,
    required this.isPracticeMode,
  });
}

// ============================================================
// MAIN SCREEN
// ============================================================

class BSCSSScreen extends StatefulWidget {
  const BSCSSScreen({super.key});

  @override
  State<BSCSSScreen> createState() => _BSCSSScreenState();
}

class _BSCSSScreenState extends State<BSCSSScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────
  QuizState _currentState = QuizState.topic;
  String _selectedTopic = '';
  List<Map<String, dynamic>> _currentQuestions = [];
  List<int?> _userAnswers = [];
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _showExplanation = false;
  bool _isPracticeMode = true;
  bool _isDarkMode = false;
  bool _isTimerEnabled = true;
  int _timerSeconds = 30;
  int _remainingSeconds = 30;
  Timer? _questionTimer;
  Timer? _totalTimer;
  int _totalElapsed = 0;
  Difficulty _selectedDifficulty = Difficulty.all;
  SortOrder _sortOrder = SortOrder.nameAsc;
  String _searchQuery = '';
  List<int> _bookmarkedQuestions = [];
  List<QuizAttempt> _attemptHistory = [];
  int _streak = 0;
  int _bestStreak = 0;
  int _totalQuestionsAnswered = 0;
  int _totalCorrectAnswers = 0;
  bool _showConfetti = false;
  double _fontSize = 15.0;
  bool _showHints = false;
  bool _hintsUsed = false;
  int _hintsAvailable = 3;
  int _hintsUsedCount = 0;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  late AnimationController _animationController;
  late AnimationController _confettiController;
  late AnimationController _timerAnimController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _timerAnim;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ── Quiz Data ──────────────────────────────────────────
  final Map<String, List<Map<String, dynamic>>> quizData = {
  "व्यक्तिगत विकास (Personal Development)": [
    {
      "question": "सफलता का सबसे महत्वपूर्ण रहस्य क्या है?",
      "options": ["भाग्य", "लगातार सीखना और अनुशासन", "दूसरों की मदद", "स्मार्ट दिखना"],
      "answer": 1,
      "explanation": "सफलता का कोई शॉर्टकट नहीं है। निरंतर सीखना, अनुशासन और मेहनत ही वास्तविक रहस्य हैं।",
      "difficulty": "easy",
      "hint": "क्या चीज़ आपको लगातार बेहतर बनाती है?",
      "tags": ["सफलता", "अनुशासन"],
    },
    {
      "question": "सेल्फ-मैनेजमेंट (आत्म-प्रबंधन) का सबसे अच्छा उदाहरण क्या है?",
      "options": ["बिना सोचे काम करना", "समय पर उठना और कार्यों को प्राथमिकता देना", "दूसरों को अपना काम सौंपना", "जब मन करे तब काम करना"],
      "answer": 1,
      "explanation": "आत्म-प्रबंधन का अर्थ है अपनी दिनचर्या, आदतों और कार्यों पर नियंत्रण रखना।",
      "difficulty": "easy",
      "hint": "इसमें 'अनुशासन' और 'योजना' दोनों शामिल हैं।",
      "tags": ["सेल्फ-मैनेजमेंट", "अनुशासन"],
    },
    {
      "question": "आत्म-जागरूकता (Self-awareness) क्यों ज़रूरी है?",
      "options": ["दूसरों को बताने के लिए", "अपनी ताकत और कमजोरियां जानने के लिए", "अहंकार बढ़ाने के लिए", "दिखावे के लिए"],
      "answer": 1,
      "explanation": "अपनी भावनाओं, विचारों और व्यवहार को समझना ही स्मार्ट निर्णय की पहली सीढ़ी है।",
      "difficulty": "easy",
      "hint": "सही फैसला लेने से पहले क्या जानना ज़रूरी है?",
      "tags": ["आत्म-जागरूकता", "निर्णय"],
    },
    {
      "question": "समय प्रबंधन (Time Management) का सही अर्थ क्या है?",
      "options": ["ज़्यादा घंटे काम करना", "कम समय में ज़्यादा महत्वपूर्ण काम करना", "बिना ब्रेक के पढ़ना", "सिर्फ़ आसान काम करना"],
      "answer": 1,
      "explanation": "यह आपके पास मौजूद समय का उपयोग सबसे ज़रूरी कार्यों के लिए करना है।",
      "difficulty": "easy",
      "hint": "इसमें 'प्राथमिकता' शब्द छिपा है।",
      "tags": ["समय प्रबंधन", "उत्पादकता"],
    },
    {
      "question": "अगर आप अपने बड़े सपने को पूरा करना चाहते हैं, तो पहला कदम क्या होगा?",
      "options": ["इंतज़ार करना", "सपने को छोटे-छोटे लक्ष्यों में बदलना", "सबको बताना", "पैसे गिनना"],
      "answer": 1,
      "explanation": "सपना तभी लक्ष्य बनता है जब उसकी योजना बनाई जाए और उसे छोटे-छोटे चरणों में तोड़ा जाए।",
      "difficulty": "medium",
      "hint": "एक बड़ी यात्रा की शुरुआत कैसे होती है?",
      "tags": ["लक्ष्य निर्धारण", "सपने"],
    },
    {
      "question": "'एकाग्रता' (Discipline) किसमें मदद करती है?",
      "options": ["टालमटोल करने में", "लंबे समय तक मेहनत करने में", "बहाने बनाने में", "आराम करने में"],
      "answer": 1,
      "explanation": "अनुशासन आपको तब भी काम करने की शक्ति देता है जब मन नहीं करता। यही सफलता की कुंजी है।",
      "difficulty": "easy",
      "hint": "यह motivation से ज़्यादा शक्तिशाली है।",
      "tags": ["अनुशासन", "मेहनत"],
    },
    {
      "question": "एक गलत निर्णय के बाद सबसे अच्छा तरीका क्या है?",
      "options": ["छुपाना", "उससे सीखना और आगे बढ़ना", "रोना", "किसी और को दोष देना"],
      "answer": 1,
      "explanation": "गलती से सीखना ही बुद्धिमानी है। यही आपको स्मार्ट बनाता है।",
      "difficulty": "easy",
      "hint": "हर गलती एक सीख है।",
      "tags": ["निर्णय", "सीखना"],
    },
    {
      "question": "स्मार्ट लक्ष्य (SMART Goal) में 'M' का क्या मतलब है?",
      "options": ["Motivational", "Measurable (मापने योग्य)", "Magical", "Monthly"],
      "answer": 1,
      "explanation": "SMART में M = Measurable यानी आपको पता होना चाहिए कि आपने कितनी प्रगति कर ली है।",
      "difficulty": "medium",
      "hint": "'S' Specific, 'M' Measurable, 'A' Achievable...",
      "tags": ["SMART", "लक्ष्य"],
    },
    {
      "question": "प्रोक्रैस्टिनेशन (टालमटोल) से बचने का सबसे अच्छा तरीका क्या है?",
      "options": ["सो जाना", "काम को छोटे हिस्सों में बांटना और 2 मिनट का नियम लागू करना", "काम को पूरी तरह से छोड़ देना", "फोन चलाना"],
      "answer": 1,
      "explanation": "2 मिनट का नियम कहता है कि अगर कोई काम 2 मिनट में हो सकता है तो उसे तुरंत करो। बड़े काम को छोटा बनाओ।",
      "difficulty": "medium",
      "hint": "शुरुआत करने का एक छोटा सा तरीका सोचो।",
      "tags": ["टालमटोल", "केलेण्डर"],
    },
    {
      "question": "आपके घर के पास दो रास्ते हैं - एक छोटा लेकिन खतरनाक, दूसरा लंबा लेकिन सुरक्षित। स्मार्ट निर्णय क्या होगा?",
      "options": ["हमेशा छोटा रास्ता", "हमेशा लंबा रास्ता", "समय और सुरक्षा दोनों देखकर फैसला", "कोई रास्ता न चुनें"],
      "answer": 2,
      "explanation": "स्मार्ट निर्णय का मतलब है परिस्थिति के अनुसार सही चुनाव करना। कभी सुरक्षा ज़्यादा ज़रूरी है, कभी समय।",
      "difficulty": "medium",
      "hint": "हर बार एक ही नियम नहीं चलता।",
      "tags": ["निर्णय", "समझदारी"],
    },
    {
      "question": "'Personal Development' का मुख्य उद्देश्य क्या है?",
      "options": ["दूसरों से बेहतर बनना", "अपने 'कल' के संस्करण को 'आज' से बेहतर बनाना", "ज़्यादा पैसे कमाना", "लोकप्रिय होना"],
      "answer": 1,
      "explanation": "यह आपकी अपनी यात्रा है। खुद से बेहतर बनना सबसे बड़ी जीत है।",
      "difficulty": "easy",
      "hint": "इसमें 'पिछला आप' और 'अगला आप' शामिल है।",
      "tags": ["व्यक्तिगत विकास", "ग्रोथ"],
    },
    {
      "question": "समय प्रबंधन में 'आइवरी आइजनहावर मैट्रिक्स' क्या सिखाता है?",
      "options": ["सब काम एक साथ करना", "कामों को जरूरी और महत्वपूर्ण के आधार पर बांटना", "सिर्फ मजेदार काम करना", "कभी काम न करना"],
      "answer": 1,
      "explanation": "यह मैट्रिक्स कामों को 4 हिस्सों में बांटता है: जरूरी+महत्वपूर्ण, जरूरी+अमहत्वपूर्ण, आदि।",
      "difficulty": "hard",
      "hint": "Urgent vs Important का फर्क समझाए।",
      "tags": ["आइजनहावर", "समय"],
    },
    {
      "question": "ड्रीम (सपना) और गोल (लक्ष्य) में मुख्य अंतर क्या है?",
      "options": ["दोनों एक ही हैं", "सपने की कोई डेडलाइन नहीं, लक्ष्य की होती है", "लक्ष्य छोटा होता है", "सपना पैसों से जुड़ा है"],
      "answer": 1,
      "explanation": "सपना एक अस्पष्ट इच्छा है, लेकिन लक्ष्य एक स्पष्ट योजना और समयसीमा वाला सपना है।",
      "difficulty": "medium",
      "hint": "अगर आपने तारीख और योजना जोड़ दी, तो सपना लक्ष्य बन जाता है।",
      "tags": ["ड्रीम", "गोल"],
    },
    {
      "question": "अगर आपको कोई बड़ा फैसला लेना है और आप डर रहे हैं, तो क्या करना चाहिए?",
      "options": ["हमेशा ना कहना", "डर के बावजूद छोटा कदम उठाना और risk को calculate करना", "दूसरों पर छोड़ देना", "बिना सोचे कूद जाना"],
      "answer": 1,
      "explanation": "बहादुरी का मतलब डर न होना नहीं, बल्कि डर के साथ चलना सीखना है। पहले सोचे, फिर छोटा कदम उठाएं।",
      "difficulty": "medium",
      "hint": "पहले डर को समझो, फिर उसके बावजूद आगे बढ़ो।",
      "tags": ["निर्णय", "हिम्मत"],
    },
    {
      "question": "सुबह उठने के बाद 'सबसे ज़रूरी' काम करने का नियम क्या कहलाता है?",
      "options": ["पोमोडोरो", "ईट दैट फ्रॉग (Eat That Frog)", "फोर्स टेक्नीक", "ब्रेक लॉ"],
      "answer": 1,
      "explanation": "मार्क ट्वेन ने कहा था, 'सुबह सबसे पहले मेंढक खाओ' - यानी सबसे मुश्किल काम सबसे पहले करो।",
      "difficulty": "medium",
      "hint": "'इसे खा जाओ' वाली तकनीक।",
      "tags": ["आदतें", "प्राथमिकता"],
    },
    {
      "question": "जब आपका मन काम नहीं करता तब भी काम करने की क्षमता को क्या कहते हैं?",
      "options": ["प्रतिभा", "अनुशासन (Self-Discipline)", "भाग्य", "लकी चार्म"],
      "answer": 1,
      "explanation": "प्रेरणा आती और जाती रहती है, लेकिन अनुशासन हमेशा आपको ज़मीन पर रखता है।",
      "difficulty": "easy",
      "hint": "यह वह चीज़ है जो Motivation को हराती है।",
      "tags": ["अनुशासन", "मानसिकता"],
    },
    {
      "question": "'Turning Dreams into Goals' के लिए सबसे पहले क्या चाहिए?",
      "options": ["पैसा", "एक कलम और कागज़ (लिखना)", "दोस्त", "इंटरनेट"],
      "answer": 1,
      "explanation": "अपने सपने को लिखना उसे हकीकत बनाने की पहली और सबसे शक्तिशाली क्रिया है।",
      "difficulty": "easy",
      "hint": "बिना लिखे तो वह सिर्फ ख्याल है।",
      "tags": ["लक्ष्य", "लेखन"],
    },
    {
      "question": "सेल्फ-अवेयरनेस बढ़ाने का सबसे अच्छा तरीका क्या है?",
      "options": ["ज़्यादा बोलना", "जर्नलिंग (Journaling) या डायरी लिखना", "दूसरों की आलोचना करना", "टीवी देखना"],
      "answer": 1,
      "explanation": "अपने विचारों और भावनाओं को लिखना आपको खुद को समझने का सबसे गहरा तरीका देता है।",
      "difficulty": "medium",
      "hint": "दिन में 5 मिनट लिखें, फर्क देखें।",
      "tags": ["जर्नलिंग", "सेल्फ-अवेयरनेस"],
    },
    {
      "question": "आपका सबसे बड़ा प्रतिस्पर्धी कौन है?",
      "options": ["आपका दोस्त", "आपका कल वाला संस्करण (Past You)", "अमीर लोग", "दूसरी कंपनी"],
      "answer": 1,
      "explanation": "असली मुकाबला किसी और से नहीं बल्कि खुद के पिछले संस्करण से है। बस कल से थोड़ा बेहतर बनो।",
      "difficulty": "easy",
      "hint": "दूसरों को देखना छोड़ो, खुद पर ध्यान दो।",
      "tags": ["ग्रोथ", "मानसिकता"],
    },
    {
      "question": "50 साल के एक व्यक्ति ने 60 साल की उम्र में PhD करने का फैसला किया। यह किसका उदाहरण है?",
      "options": ["समय की बर्बादी", "बेवकूफी", "कभी न हार मानने वाली मानसिकता और व्यक्तिगत विकास", "पैसे की बर्बादी"],
      "answer": 2,
      "explanation": "व्यक्तिगत विकास की कोई उम्र नहीं होती। सीखने का सिलसिला जीवनभर चलता है।",
      "difficulty": "easy",
      "hint": "क्या सीखने की कोई डेडलाइन होती है?",
      "tags": ["लाइफलांग लर्निंग", "प्रेरणा"],
    },
    {
      "question": "आपके पास एक दिन में 5 काम हैं, 3 महत्वपूर्ण हैं और 2 महत्वपूर्ण नहीं। पहले क्या करेंगे?",
      "options": ["आसान काम पहले", "मुश्किल काम पहले", "महत्वपूर्ण काम पहले", "बिना सोचे कोई भी"],
      "answer": 2,
      "explanation": "हमेशा 'Important' कामों को पहले निपटाएं, चाहे वे कितने भी मुश्किल क्यों न हों।",
      "difficulty": "easy",
      "hint": "किन कामों को न करने से सबसे बड़ा नुकसान होगा?",
      "tags": ["प्राथमिकता", "समय प्रबंधन"],
    },
    {
      "question": "'Self-discipline' सीखने का सबसे आसान तरीका क्या है?",
      "options": ["एक ही दिन में बड़ा बदलाव लाना", "एक छोटी आदत से शुरू करना (जैसे 5 मिनट पढ़ना)", "कभी शुरू न करना", "दोस्तों पर निर्भर रहना"],
      "answer": 1,
      "explanation": "अनुशासन छोटे-छोटे, लगातार किए गए कामों से बनता है। बड़े बदलाव असफल हो जाते हैं।",
      "difficulty": "medium",
      "hint": "एक समय में एक ही आदत।",
      "tags": ["आदतें", "डिसिप्लिन"],
    },
    {
      "question": "अगर कोई लक्ष्य बहुत बड़ा और डराने वाला लगे, तो क्या करें?",
      "options": ["छोड़ दें", "उसे छोटे-छोटे दैनिक कार्यों (Micro-Goals) में बांटें", "दूसरों से पूछें", "सोचते रहें"],
      "answer": 1,
      "explanation": "Every big task is just a series of small tasks. एक-एक कदम उठाइए।",
      "difficulty": "easy",
      "hint": "हाथी को कैसे खाया जाता है? एक निवाला काटकर।",
      "tags": ["लक्ष्य", "माइक्रो स्टेप्स"],
    },
    {
      "question": "'Time is money' कहावत को समय प्रबंधन में कैसे समझते हैं?",
      "options": ["ज़्यादा काम करो", "समय को उतनी ही कीमत दो जितनी पैसे को देते हो", "पैसा ही सब कुछ है", "समय खरीदा जा सकता है"],
      "answer": 1,
      "explanation": "जैसे आप पैसे को लेकर सतर्क होते हैं, वैसे ही हर एक घंटे की कीमत समझें।",
      "difficulty": "medium",
      "hint": "एक घंटा बर्बाद करना क्या पैसे फेंकने जैसा है?",
      "tags": ["समय", "मूल्य"],
    },
    {
      "question": "जब आप थके हुए हों, तब भी काम पर लगे रहना क्या कहलाता है?",
      "options": ["जुनून", "स्टैमिना और आत्म-अनुशासन", "पागलपन", "गलती"],
      "answer": 1,
      "explanation": "आराम उतना ही ज़रूरी है, लेकिन कभी-कभी लगातार बने रहना (Consistency) ही आपको दूसरों से अलग करता है।",
      "difficulty": "medium",
      "hint": "गेंद को लगातार आगे बढ़ाने की क्षमता।",
      "tags": ["स्टैमिना", "कंसिस्टेंसी"],
    },
    {
      "question": "स्मार्ट गोल (SMART Goal) में 'A' का क्या मतलब है?",
      "options": ["Amazing", "Achievable (प्राप्त करने योग्य)", "Angry", "Always"],
      "answer": 1,
      "explanation": "A = Achievable - यानी लक्ष्य चुनौतीपूर्ण हो लेकिन असंभव न हो।",
      "difficulty": "medium",
      "hint": "क्या यह आपकी पहुंच के अंदर है?",
      "tags": ["SMART", "योजना"],
    },
    {
      "question": "Failure (असफलता) को किस नज़रिए से देखना चाहिए?",
      "options": ["अपमान के तौर पर", "फीडबैक और नई शुरुआत के रूप में", "अंत के तौर पर", "सजा के तौर पर"],
      "answer": 1,
      "explanation": "असफलता सफलता की सीढ़ी है। यह यह बताती है कि कौन सा तरीका काम नहीं कर रहा।",
      "difficulty": "easy",
      "hint": "असफलता = Learning Opportunity",
      "tags": ["असफलता", "ग्रोथ माइंडसेट"],
    },
    {
      "question": "'Turning Dreams into Goals' के लिए 'Deadline' क्यों ज़रूरी है?",
      "options": ["तनाव बढ़ाने के लिए", "बिना डेडलाइन के सपने टलते रहते हैं", "दिखावे के लिए", "दूसरों को इंप्रेस करने के लिए"],
      "answer": 1,
      "explanation": "जब तक कोई तारीख न हो, आलस्य आपको रोक लेता है। डेडलाइन जिम्मेदारी देती है।",
      "difficulty": "easy",
      "hint": "अगर कल कोई डेडलाइन न हो, तो क्या आज काम करोगे?",
      "tags": ["डेडलाइन", "लक्ष्य"],
    },
    {
      "question": "रोज़ाना 1% बेहतर बनने का नियम किस सिद्धांत पर काम करता है?",
      "options": ["कंपाउंडिंग (Compound Effect)", "लकी चार्म", "जादू", "तेज दौड़"],
      "answer": 0,
      "explanation": "1% रोज़ाना सुधार एक साल में 37 गुना बेहतर बना देता है। यही कंपाउंडिंग प्रभाव है।",
      "difficulty": "medium",
      "hint": "छोटा बदलाव, बड़ा परिणाम।",
      "tags": ["कंपाउंडिंग", "आदतें"],
    },
    {
      "question": "एक स्टूडेंट रात 2 बजे तक रील्स देखता है और सुबह उठ नहीं पाता। उसे किसकी कमी है?",
      "options": ["स्मार्टनेस", "सेल्फ-डिसिप्लिन और टाइम मैनेजमेंट", "पैसा", "मोबाइल"],
      "answer": 1,
      "explanation": "अनुशासन और समय प्रबंधन की कमी का सीधा असर उसकी दिनचर्या और पढ़ाई पर पड़ेगा।",
      "difficulty": "easy",
      "hint": "फोन को दूर करना और समय तय करना इसकी दवा है।",
      "tags": ["अनुशासन", "खराब आदतें"],
    },
    {
      "question": "अगर दो काम एक साथ करने हों (Multitasking), तो क्या करना बेहतर है?",
      "options": ["दोनों एक साथ करना", "एक-एक करके फोकस करना", "दोनों आधा-आधा करना", "दोनों छोड़ देना"],
      "answer": 1,
      "explanation": "Multi-tasking से क्वालिटी घटती है और समय बढ़ता है। एक बार में एक काम पर पूरा फोकस करो।",
      "difficulty": "easy",
      "hint": "धागे से माला बनाते समय एक ही छेद में डालो।",
      "tags": ["फोकस", "मल्टीटास्किंग"],
    },
    {
      "question": "सेल्फ-अवेयरनेस (Self-awareness) की कमी से क्या होता है?",
      "options": ["बेहतर निर्णय", "अपनी गलतियों का पता न चलना और बार-बार गलती होना", "त्वरित सफलता", "शांति"],
      "answer": 1,
      "explanation": "जब आपको पता ही नहीं कि गलती कहाँ हो रही है, तो सुधार कैसे होगा?",
      "difficulty": "hard",
      "hint": "अगर आप खुद को नहीं समझते, तो दूसरे समझेंगे?",
      "tags": ["सेल्फ-अवेयरनेस", "गलतियाँ"],
    },
    {
      "question": "Pomodoro Technique क्या है?",
      "options": ["एक तरह का टमाटर", "25 मिनट काम, 5 मिनट ब्रेक", "बिना ब्रेक के पढ़ना", "दोस्तों के साथ पढ़ना"],
      "answer": 1,
      "explanation": "Pomodoro (टमाटर) तकनीक 25 मिनट फोकस और 5 मिनट ब्रेक के चक्र पर आधारित है।",
      "difficulty": "medium",
      "hint": "टाइमर सेट करो, फिर ब्रेक।",
      "tags": ["पोमोडोरो", "फोकस"],
    },
    {
      "question": "जब आप बहुत थक जाएं और कोई भी बड़ा फैसला लेना हो, तो क्या करना चाहिए?",
      "options": ["तुरंत लेना चाहिए", "रात की नींद के बाद, ताजा दिमाग से लेना चाहिए", "कभी न लें", "दूसरों से पूछ लेना चाहिए"],
      "answer": 1,
      "explanation": "थकान में लिए गए निर्णय अक्सर गलत होते हैं। हमेशा ताजा दिमाग से big decisions लो।",
      "difficulty": "easy",
      "hint": "रात को सोने से पहले कोई बड़ा फैसला मत करो।",
      "tags": ["निर्णय", "थकान"],
    },
    {
      "question": "If you fail to plan, you are planning to fail - यह किसके बारे में है?",
      "options": ["भाग्य", "लक्ष्य की योजना बनाने के महत्व", "प्रैंक", "फिल्म"],
      "answer": 1,
      "explanation": "बिना योजना के कोई भी लक्ष्य अधूरा रह जाता है। योजना सफलता की नींव है।",
      "difficulty": "easy",
      "hint": "बिना मैप के यात्रा पर निकलना।",
      "tags": ["योजना", "लक्ष्य"],
    },
    {
      "question": "आपके पास सिर्फ 2 घंटे हैं और 4 काम हैं। आपको तुरंत क्या करना चाहिए?",
      "options": ["सब आधा-आधा करो", "कामों को प्राथमिकता दो, urgent vs important निकालो", "रोना शुरू करो", "सब छोड़ो"],
      "answer": 1,
      "explanation": "हर काम महत्वपूर्ण नहीं होता। पहले सबसे जरूरी काम चुने।",
      "difficulty": "medium",
      "hint": "इनमें से कौन-सा काम न करने पर नौकरी जाएगी?",
      "tags": ["प्राथमिकता", "समय सीमा"],
    },
    {
      "question": "अपने डर (Fear) को पहचानने से क्या फायदा?",
      "options": ["डर बढ़ता है", "डर पर काबू पाने की रणनीति बना सकते हो", "कुछ नहीं", "शर्म आती है"],
      "answer": 1,
      "explanation": "Fear को name देना (जैसे 'मुझे फेल होने का डर है') उससे लड़ने का पहला कदम है।",
      "difficulty": "hard",
      "hint": "जिस चीज का नाम ले लो, उसका डर कम हो जाता है।",
      "tags": ["डर", "सेल्फ-अवेयरनेस"],
    },
    {
      "question": "स्मार्ट फैसले के लिए इमोशन (भावना) और लॉजिक (तर्क) में से क्या ज़रूरी है?",
      "options": ["सिर्फ इमोशन", "सिर्फ लॉजिक", "दोनों का संतुलन", "कुछ नहीं"],
      "answer": 2,
      "explanation": "पूरी तरह लॉजिकल फैसला सही नहीं होता और पूरी तरह इमोशनल भी नहीं। dono का मिलाजुला रूप।",
      "difficulty": "hard",
      "hint": "दिल और दिमाग दोनों से सोचो।",
      "tags": ["निर्णय", "भावना"],
    },
    {
      "question": "लक्ष्य तय करने के बाद सबसे ज़रूरी कदम क्या है?",
      "options": ["इंतज़ार", "एक्शन प्लान और फिर पहला छोटा कदम उठाना", "सोशल मीडिया पर पोस्ट करना", "सेलिब्रेट करना"],
      "answer": 1,
      "explanation": "बिना action के, goal सिर्फ एक कागज़ का टुकड़ा है। पहला step रोज़ उठाओ।",
      "difficulty": "easy",
      "hint": "चिड़िया को उड़ने के लिए पहला पंख फड़फड़ाना पड़ता है।",
      "tags": ["एक्शन", "आदत"],
    },
    {
      "question": "8 घंटे की नींद और समय प्रबंधन में क्या संबंध?",
      "options": ["कोई संबंध नहीं", "अच्छी नींद = दिमाग तेज = बेहतर समय प्रबंधन", "नींद समय की बर्बादी है", "नींद से आलस्य बढ़ता है"],
      "answer": 1,
      "explanation": "थका हुआ दिमाग फोकस नहीं कर सकता। नींद productivity के लिए ज़रूरी है।",
      "difficulty": "easy",
      "hint": "रात को देर तक जागना smartness नहीं, stupidity है।",
      "tags": ["नींद", "प्रोडक्टिविटी"],
    },
    {
      "question": "हर दिन 10 चीजों की gratitude लिस्ट बनाने से क्या होता है?",
      "options": ["पैसे मिलते हैं", "मानसिक शांति और पॉज़िटिविटी बढ़ती है", "नौकरी मिलती है", "वज़न घटता है"],
      "answer": 1,
      "explanation": "Gratitude practice आपको खुश रखती है और focus को negative से positive पर लाती है।",
      "difficulty": "easy",
      "hint": "जो है, उसकी कद्र करना सीखो।",
      "tags": ["ग्रेटिट्यूड", "मानसिक स्वास्थ्य"],
    },
    {
      "question": "Routine (दिनचर्या) क्यों ज़रूरी है?",
      "options": ["बोरियत के लिए", "अनिश्चितता को कम करने और discipline बनाने के लिए", "दूसरों को दिखाने के लिए", "बस ऐसे ही"],
      "answer": 1,
      "explanation": "Routine आपके दिमाग को बताती है कि आगे क्या करना है, जिससे ऊर्जा बचती है।",
      "difficulty": "easy",
      "hint": "जब पता हो कि आगे क्या करना है, तो confusion नहीं होता।",
      "tags": ["रूटीन", "डिसिप्लिन"],
    },
  ],
};

  Map<String, bool> _topicFavorites = {};
  Map<String, int> _topicBestScores = {};

  // ── Colors ─────────────────────────────────────────────
  Color get _primaryColor => _isDarkMode ? const Color(0xFF4FC3F7) : const Color(0xFF1565C0);
  Color get _accentColor => const Color(0xFF00E676);
  Color get _bgColor => _isDarkMode ? const Color(0xFF0D1117) : const Color(0xFFF0F4FF);
  Color get _cardColor => _isDarkMode ? const Color(0xFF161B22) : Colors.white;
  Color get _textColor => _isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
  Color get _subtextColor => _isDarkMode ? Colors.white54 : Colors.blueGrey;

  // ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _timerAnimController = AnimationController(
      duration: Duration(seconds: _timerSeconds),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    _timerAnim = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _timerAnimController, curve: Curves.linear));
    _animationController.forward();

    for (var topic in quizData.keys) {
      _topicFavorites[topic] = false;
      _topicBestScores[topic] = 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    _timerAnimController.dispose();
    _questionTimer?.cancel();
    _totalTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Timer Logic ────────────────────────────────────────
  void _startQuestionTimer() {
    if (!_isTimerEnabled) return;
    _questionTimer?.cancel();
    _remainingSeconds = _timerSeconds;
    _timerAnimController.reset();
    _timerAnimController.duration = Duration(seconds: _timerSeconds);
    _timerAnimController.forward();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        t.cancel();
        _onTimerExpired();
      }
    });
  }

  void _startTotalTimer() {
    _totalElapsed = 0;
    _totalTimer?.cancel();
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _totalElapsed++);
    });
  }

  void _stopTimers() {
    _questionTimer?.cancel();
    _totalTimer?.cancel();
  }

  void _onTimerExpired() {
    if (_selectedOption != null) return;
    setState(() {
      _userAnswers[_currentQuestionIndex] = -1; // -1 = timed out
      _selectedOption = -1;
      if (_isPracticeMode) _showExplanation = true;
    });
    _feedbackVibrate(false);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (_currentQuestionIndex < _currentQuestions.length - 1) {
          _nextQuestion();
        } else {
          _showResult();
        }
      }
    });
  }

  // ── Quiz Logic ─────────────────────────────────────────
  void _selectTopic(String topic) {
    var questions = List<Map<String, dynamic>>.from(quizData[topic]!);
    if (_selectedDifficulty != Difficulty.all) {
      final diffStr = _selectedDifficulty.name;
      questions = questions.where((q) => q['difficulty'] == diffStr).toList();
      if (questions.isEmpty) questions = List.from(quizData[topic]!);
    }
    if (_isPracticeMode) questions.shuffle();
    setState(() {
      _selectedTopic = topic;
      _currentQuestions = questions;
      _userAnswers = List.filled(questions.length, null);
      _currentQuestionIndex = 0;
      _selectedOption = null;
      _showExplanation = false;
      _hintsUsedCount = 0;
      _hintsUsed = false;
      _hintsAvailable = 3;
      _currentState = QuizState.quiz;
    });
    _animateTransition();
    _startTotalTimer();
    _startQuestionTimer();
  }

  void _selectAnswer(int optionIndex) {
    if (_selectedOption != null) return;
    _questionTimer?.cancel();
    _timerAnimController.stop();
    final isCorrect = optionIndex == _currentQuestions[_currentQuestionIndex]['answer'];
    if (isCorrect) {
      _streak++;
      _totalCorrectAnswers++;
      if (_streak > _bestStreak) _bestStreak = _streak;
    } else {
      _streak = 0;
    }
    _totalQuestionsAnswered++;
    setState(() {
      _selectedOption = optionIndex;
      _userAnswers[_currentQuestionIndex] = optionIndex;
      if (_isPracticeMode) _showExplanation = true;
    });
    _feedbackVibrate(isCorrect);
    final delay = _isPracticeMode ? 2500 : 600;
    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _currentQuestions.length - 1) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = _userAnswers[_currentQuestionIndex];
        _showExplanation = _isPracticeMode && _selectedOption != null;
        _hintsUsed = false;
      });
      if (_selectedOption == null) _startQuestionTimer();
    } else {
      _showResult();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _questionTimer?.cancel();
      setState(() {
        _currentQuestionIndex--;
        _selectedOption = _userAnswers[_currentQuestionIndex];
        _showExplanation = _isPracticeMode && _selectedOption != null;
      });
      if (_selectedOption == null) _startQuestionTimer();
    }
  }

  void _jumpToQuestion(int index) {
    _questionTimer?.cancel();
    setState(() {
      _currentQuestionIndex = index;
      _selectedOption = _userAnswers[index];
      _showExplanation = _isPracticeMode && _selectedOption != null;
    });
    if (_selectedOption == null) _startQuestionTimer();
    Navigator.pop(context);
  }

  void _showResult() {
    _stopTimers();
    final attempt = QuizAttempt(
      topic: _selectedTopic,
      score: _score,
      total: _currentQuestions.length,
      percentage: _percentage,
      date: DateTime.now(),
      timeTakenSeconds: _totalElapsed,
      isPracticeMode: _isPracticeMode,
    );
    setState(() {
      _attemptHistory.insert(0, attempt);
      if (_score > (_topicBestScores[_selectedTopic] ?? 0)) {
        _topicBestScores[_selectedTopic] = _score;
      }
      _currentState = QuizState.result;
      if (_percentage >= 80) {
        _showConfetti = true;
        _confettiController.forward(from: 0);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showConfetti = false);
        });
      }
    });
    _animateTransition();
  }

  void _restartQuiz() {
    _startTotalTimer();
    setState(() {
      _userAnswers = List.filled(_currentQuestions.length, null);
      _currentQuestionIndex = 0;
      _selectedOption = null;
      _showExplanation = false;
      _hintsUsed = false;
      _hintsUsedCount = 0;
      _hintsAvailable = 3;
      _currentState = QuizState.quiz;
    });
    _animateTransition();
    _startQuestionTimer();
  }

  void _resetToTopics() {
    _stopTimers();
    setState(() {
      _currentState = QuizState.topic;
      _selectedTopic = '';
      _currentQuestions = [];
      _userAnswers = [];
      _currentQuestionIndex = 0;
      _selectedOption = null;
    });
    _animateTransition();
  }

  void _toggleMode() => setState(() => _isPracticeMode = !_isPracticeMode);
  void _toggleDarkMode() => setState(() => _isDarkMode = !_isDarkMode);
  void _toggleFavorite(String topic) => setState(() => _topicFavorites[topic] = !(_topicFavorites[topic] ?? false));
  void _toggleBookmark() {
    setState(() {
      if (_bookmarkedQuestions.contains(_currentQuestionIndex)) {
        _bookmarkedQuestions.remove(_currentQuestionIndex);
      } else {
        _bookmarkedQuestions.add(_currentQuestionIndex);
      }
    });
  }

  void _useHint() {
    if (_hintsUsed || _hintsAvailable <= 0 || _selectedOption != null) return;
    setState(() {
      _hintsUsed = true;
      _hintsAvailable--;
      _hintsUsedCount++;
      _showHints = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHints = false);
    });
  }

  void _animateTransition() {
    _animationController.reset();
    _animationController.forward();
  }

  void _feedbackVibrate(bool correct) {
    if (!_vibrationEnabled) return;
    HapticFeedback.lightImpact();
  }

  // ── Computed ───────────────────────────────────────────
  int get _score {
    int correct = 0;
    for (int i = 0; i < _userAnswers.length; i++) {
      if (_userAnswers[i] != null && _userAnswers[i] == _currentQuestions[i]['answer']) correct++;
    }
    return correct;
  }

  double get _percentage => _currentQuestions.isEmpty ? 0 : (_score / _currentQuestions.length) * 100;

  List<String> get _filteredTopics {
    var topics = quizData.keys.toList();
    if (_searchQuery.isNotEmpty) {
      topics = topics.where((t) => t.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    switch (_sortOrder) {
      case SortOrder.nameAsc: topics.sort();
      case SortOrder.nameDesc: topics.sort((a, b) => b.compareTo(a));
      case SortOrder.questionCount: topics.sort((a, b) => quizData[b]!.length.compareTo(quizData[a]!.length));
      case SortOrder.difficulty: break;
    }
    return topics;
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _performanceLabel {
    if (_percentage >= 90) return '🏆 Excellent!';
    if (_percentage >= 75) return '⭐ Great Job!';
    if (_percentage >= 60) return '👍 Good';
    if (_percentage >= 40) return '📚 Keep Practicing';
    return '💪 Try Again';
  }

  Color get _performanceColor {
    if (_percentage >= 90) return Colors.amber;
    if (_percentage >= 75) return Colors.green;
    if (_percentage >= 60) return Colors.blue;
    if (_percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: _bgColor,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildCurrentState(),
              ),
            ),
            if (_showConfetti) _buildConfetti(),
          ],
        ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: _currentState == QuizState.topic
          ? Row(children: [
              const Icon(Icons.computer, size: 22),
              const SizedBox(width: 8),
              const Text('BS-CSS', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              if (_streak > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                  child: Text('🔥 $_streak', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ])
          : _currentState == QuizState.quiz
              ? Text(_selectedTopic, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
              : Text(_currentState.name.capitalize()),
      actions: [
        if (_currentState == QuizState.topic) ...[
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.dark_mode),
            onPressed: _toggleDarkMode,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => setState(() => _currentState = QuizState.stats),
            tooltip: 'Stats',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _showBookmarksSheet(),
            tooltip: 'Bookmarks',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune),
            onSelected: _handleMenuAction,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings, size: 18), SizedBox(width: 8), Text('Settings')])),
              const PopupMenuItem(value: 'history', child: Row(children: [Icon(Icons.history, size: 18), SizedBox(width: 8), Text('History')])),
              const PopupMenuItem(value: 'about', child: Row(children: [Icon(Icons.info, size: 18), SizedBox(width: 8), Text('About')])),
            ],
          ),
        ],
        if (_currentState == QuizState.quiz) ...[
          IconButton(icon: const Icon(Icons.settings), onPressed: _showModeDialog),
          IconButton(icon: const Icon(Icons.grid_view), onPressed: _showQuestionNavigator),
          IconButton(
            icon: Icon(_bookmarkedQuestions.contains(_currentQuestionIndex) ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
          ),
        ],
        if (_currentState == QuizState.stats || _currentState == QuizState.result)
          IconButton(icon: const Icon(Icons.home), onPressed: _resetToTopics),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings': _showSettingsSheet();
      case 'history': _showHistorySheet();
      case 'about': _showAboutDialog();
    }
  }

  // ── FAB ────────────────────────────────────────────────
  Widget? _buildFAB() {
    if (_currentState != QuizState.quiz) return null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_hintsAvailable > 0 && _selectedOption == null)
          FloatingActionButton.small(
            heroTag: 'hint',
            onPressed: _useHint,
            backgroundColor: Colors.amber,
            child: Stack(
              children: [
                const Icon(Icons.lightbulb, color: Colors.white),
                Positioned(
                  right: 0, top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('$_hintsAvailable', style: const TextStyle(fontSize: 8, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'finish',
          onPressed: _showResult,
          backgroundColor: Colors.green,
          child: const Icon(Icons.flag, color: Colors.white),
          tooltip: 'Finish Early',
        ),
      ],
    );
  }

  // ── Current State Router ───────────────────────────────
  Widget _buildCurrentState() {
    switch (_currentState) {
      case QuizState.topic: return _buildTopicSelection();
      case QuizState.quiz: return _buildQuizView();
      case QuizState.result: return _buildResultView();
      case QuizState.leaderboard: return _buildLeaderboardView();
      case QuizState.bookmarks: return _buildBookmarksView();
      case QuizState.stats: return _buildStatsView();
    }
  }

  // ============================================================
  // TOPIC SELECTION
  // ============================================================
  Widget _buildTopicSelection() {
    return Column(
      children: [
        _buildTopicHeader(),
        _buildSearchAndFilter(),
        Expanded(child: _buildTopicGrid()),
      ],
    );
  }

  Widget _buildTopicHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withOpacity(0.7), Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.school, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BS-CSS Quiz Master', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(_isPracticeMode ? '📚 Practice Mode' : '📝 Exam Mode',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                children: [
                  const Text('Practice', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Switch(
                    value: _isPracticeMode,
                    onChanged: (_) => _toggleMode(),
                    activeColor: Colors.greenAccent,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip('🏆', '$_totalCorrectAnswers', 'Correct'),
              const SizedBox(width: 8),
              _statChip('🔥', '$_bestStreak', 'Best Streak'),
              const SizedBox(width: 8),
              _statChip('📊', _totalQuestionsAnswered > 0 ? '${((_totalCorrectAnswers / _totalQuestionsAnswered) * 100).toInt()}%' : '0%', 'Accuracy'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Difficulty:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 8),
              ...Difficulty.values.map((d) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDifficulty = d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedDifficulty == d ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(d.name.capitalize(),
                        style: TextStyle(
                          color: _selectedDifficulty == d ? _primaryColor : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(color: _textColor),
              decoration: InputDecoration(
                hintText: 'Search topics...',
                hintStyle: TextStyle(color: _subtextColor),
                prefixIcon: Icon(Icons.search, color: _subtextColor),
                filled: true,
                fillColor: _cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<SortOrder>(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.sort, color: _primaryColor),
            ),
            onSelected: (s) => setState(() => _sortOrder = s),
            itemBuilder: (_) => [
              const PopupMenuItem(value: SortOrder.nameAsc, child: Text('Name A→Z')),
              const PopupMenuItem(value: SortOrder.nameDesc, child: Text('Name Z→A')),
              const PopupMenuItem(value: SortOrder.questionCount, child: Text('Most Questions')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicGrid() {
    final topics = _filteredTopics;
    if (topics.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.search_off, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        Text('No topics found', style: TextStyle(color: _subtextColor)),
      ]));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemCount: topics.length,
      itemBuilder: (_, i) => _buildTopicCard(topics[i]),
    );
  }

  Widget _buildTopicCard(String topic) {
    final colors = _topicColor(topic);
    final best = _topicBestScores[topic] ?? 0;
    final total = quizData[topic]!.length;
    final isFav = _topicFavorites[topic] ?? false;
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 8,
        shadowColor: colors[0].withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          onTap: () => _selectTopic(topic),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(_topicIcon(topic), size: 32, color: Colors.white),
                    GestureDetector(
                      onTap: () => _toggleFavorite(topic),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const Spacer(),
                Text(topic, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: Text('$total Q', style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                    const SizedBox(width: 6),
                    if (best > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: Text('Best: $best/$total', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                  ],
                ),
                if (best > 0) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: best / total,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _topicColor(String topic) {
    final map = {
      "Programming Basics": [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
      "Data Structures": [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
      "Web Basics": [const Color(0xFFF57F17), const Color(0xFFFFCA28)],
      "Operating Systems": [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)],
      "Networking": [const Color(0xFF00838F), const Color(0xFF4DD0E1)],
    };
    return map[topic] ?? [Colors.blueGrey, Colors.blueGrey.shade300];
  }

  IconData _topicIcon(String topic) {
    final map = {
      "Programming Basics": Icons.code,
      "Data Structures": Icons.account_tree,
      "Web Basics": Icons.web,
      "Operating Systems": Icons.memory,
      "Networking": Icons.wifi,
    };
    return map[topic] ?? Icons.school;
  }

  // ============================================================
  // QUIZ VIEW
  // ============================================================
  Widget _buildQuizView() {
    final question = _currentQuestions[_currentQuestionIndex];
    return Column(
      children: [
        _buildQuizHeader(question),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (_isTimerEnabled && _selectedOption == null) _buildTimerBar(),
                _buildQuestionCard(question),
                const SizedBox(height: 16),
                if (_showHints && _hintsUsed)
                  _buildHintCard(question['hint'] ?? ''),
                ...List.generate(4, (i) => _buildOptionCard(i, question['options'][i], question['answer'])),
                if (_showExplanation && _isPracticeMode)
                  _buildExplanationCard(question['explanation']),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildQuizFooter(),
      ],
    );
  }

  Widget _buildQuizHeader(Map q) {
    final tags = q['tags'] as List? ?? [];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: _cardColor,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text('Q${_currentQuestionIndex + 1}/${_currentQuestions.length}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _primaryColor, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              ...tags.take(2).map((tag) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: _primaryColor.withOpacity(0.1),
                ),
              )),
              const Spacer(),
              _buildDifficultyBadge(q['difficulty'] ?? 'easy'),
              const SizedBox(width: 8),
              Icon(_bookmarkedQuestions.contains(_currentQuestionIndex) ? Icons.bookmark : Icons.bookmark_border,
                  size: 20, color: _subtextColor),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text('⏱ ${_formatTime(_totalElapsed)}',
                    style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _currentQuestions.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String diff) {
    final colors = {'easy': Colors.green, 'medium': Colors.orange, 'hard': Colors.red};
    final icons = {'easy': '🟢', 'medium': '🟡', 'hard': '🔴'};
    final c = colors[diff] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.3))),
      child: Text('${icons[diff] ?? ''} ${diff.capitalize()}', style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTimerBar() {
    final ratio = _remainingSeconds / _timerSeconds;
    final color = ratio > 0.5 ? Colors.green : ratio > 0.25 ? Colors.orange : Colors.red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.timer, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$_remainingSeconds s', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map question) {
    return Card(
      elevation: 4,
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              question['question'],
              style: TextStyle(fontSize: _fontSize + 1, fontWeight: FontWeight.w600, height: 1.5, color: _textColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintCard(String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.amber.shade50, Colors.amber.shade100]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text('💡 Hint: $hint', style: const TextStyle(fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index, String text, int correctAnswer) {
    final isSelected = _selectedOption == index;
    final isTimedOut = _selectedOption == -1;
    final isCorrect = isSelected && index == correctAnswer;
    final isWrong = isSelected && index != correctAnswer;
    final showCorrect = (_selectedOption != null) && index == correctAnswer && !isSelected;

    Color? bg;
    Color border = Colors.grey.shade300;
    if (isCorrect || showCorrect) { bg = Colors.green.shade50; border = Colors.green; }
    if (isWrong) { bg = Colors.red.shade50; border = Colors.red; }
    if (isTimedOut && index == correctAnswer) { bg = Colors.green.shade50; border = Colors.green; }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isSelected ? 4 : 1,
      color: bg ?? _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: border, width: isSelected ? 2 : 1)),
      child: InkWell(
        onTap: _selectedOption == null ? () => _selectAnswer(index) : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: isCorrect || showCorrect ? Colors.green : isWrong ? Colors.red : _primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCorrect || isWrong || showCorrect ? Colors.white : _primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: TextStyle(fontSize: _fontSize, color: _textColor, height: 1.3))),
              if (isCorrect || showCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 22),
              if (isWrong) const Icon(Icons.cancel, color: Colors.red, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(String explanation) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.amber.shade50, Colors.yellow.shade50]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.lightbulb, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
          const SizedBox(height: 8),
          Text(explanation, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildQuizFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: _cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousQuestion,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _selectedOption != null
                  ? (_currentQuestionIndex < _currentQuestions.length - 1 ? _nextQuestion : _showResult)
                  : null,
              icon: Icon(_currentQuestionIndex < _currentQuestions.length - 1 ? Icons.arrow_forward : Icons.emoji_events, size: 18),
              label: Text(_currentQuestionIndex < _currentQuestions.length - 1 ? 'Next' : 'Finish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULT VIEW
  // ============================================================
  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildResultSummaryCard(),
          const SizedBox(height: 16),
          _buildResultStatsRow(),
          const SizedBox(height: 16),
          _buildPerformanceChart(),
          const SizedBox(height: 16),
          _buildReviewList(),
          const SizedBox(height: 16),
          _buildResultActions(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildResultSummaryCard() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, Colors.green.shade600, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Text(_performanceLabel, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text('$_score/${_currentQuestions.length} Correct',
                style: const TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 12),
            Text('${_percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _percentage / 100,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(_performanceColor),
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStatsRow() {
    final answered = _userAnswers.where((a) => a != null && a != -1).length;
    final skipped = _userAnswers.where((a) => a == null || a == -1).length;
    return Row(
      children: [
        Expanded(child: _resultStatCard('⏱', _formatTime(_totalElapsed), 'Time Taken', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _resultStatCard('✅', '$_score', 'Correct', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _resultStatCard('❌', '${_currentQuestions.length - _score}', 'Wrong', Colors.red)),
        const SizedBox(width: 12),
        Expanded(child: _resultStatCard('⏭', '$skipped', 'Skipped', Colors.orange)),
      ],
    );
  }

  Widget _resultStatCard(String emoji, String val, String label, Color color) {
    return Card(
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: _subtextColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    // Simple visual bar chart of correct vs wrong
    return Card(
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Answer Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textColor)),
            const SizedBox(height: 14),
            ...List.generate(_currentQuestions.length, (i) {
              final isCorrect = _userAnswers[i] == _currentQuestions[i]['answer'];
              final isTimedOut = _userAnswers[i] == -1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: _subtextColor)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 1.0,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isTimedOut ? Colors.orange : isCorrect ? Colors.green : Colors.red),
                          minHeight: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(isTimedOut ? Icons.timer_off : isCorrect ? Icons.check : Icons.close,
                        size: 16,
                        color: isTimedOut ? Colors.orange : isCorrect ? Colors.green : Colors.red),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    return Card(
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Detailed Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textColor)),
                const Spacer(),
                Icon(Icons.expand_more, color: _subtextColor),
              ],
            ),
          ),
          const Divider(height: 1),
          ...List.generate(_currentQuestions.length, (i) {
            final isCorrect = _userAnswers[i] == _currentQuestions[i]['answer'];
            final ans = _currentQuestions[i];
            return ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: isCorrect ? Colors.green : Colors.red,
                radius: 16,
                child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              title: Text(ans['question'], maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: _textColor)),
              subtitle: Text(
                _userAnswers[i] != null && _userAnswers[i] != -1
                    ? 'Your answer: ${String.fromCharCode(65 + _userAnswers[i]!)}'
                    : 'Timed out / Skipped',
                style: TextStyle(color: isCorrect ? Colors.green : Colors.red, fontSize: 12),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                            '${String.fromCharCode(65 + (ans['answer'] as int))}. ${ans['options'][ans['answer']]}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          )),
                        ]),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10)),
                        child: Text('📖 ${ans['explanation']}', style: const TextStyle(fontSize: 13, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _restartQuiz,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetToTopics,
            icon: const Icon(Icons.home),
            label: const Text('Topics'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showShareSheet(),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATS VIEW
  // ============================================================
  Widget _buildStatsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Statistics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textColor)),
          const SizedBox(height: 16),
          _buildOverallStatsCard(),
          const SizedBox(height: 16),
          _buildTopicsProgressSection(),
          const SizedBox(height: 16),
          _buildRecentHistorySection(),
        ],
      ),
    );
  }

  Widget _buildOverallStatsCard() {
    final accuracy = _totalQuestionsAnswered > 0
        ? ((_totalCorrectAnswers / _totalQuestionsAnswered) * 100).toStringAsFixed(1)
        : '0.0';
    return Card(
      color: _primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Overall Performance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bigStat('$_totalQuestionsAnswered', 'Questions\nAnswered'),
                _bigStat('$_totalCorrectAnswers', 'Correct\nAnswers'),
                _bigStat('$accuracy%', 'Accuracy'),
                _bigStat('$_bestStreak', 'Best\nStreak'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bigStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildTopicsProgressSection() {
    return Card(
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Topic Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
            const SizedBox(height: 14),
            ...quizData.keys.map((topic) {
              final best = _topicBestScores[topic] ?? 0;
              final total = quizData[topic]!.length;
              final ratio = total > 0 ? best / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_topicIcon(topic), size: 16, color: _primaryColor),
                        const SizedBox(width: 8),
                        Text(topic, style: TextStyle(fontSize: 13, color: _textColor)),
                        const Spacer(),
                        Text('$best/$total', style: TextStyle(fontSize: 12, color: _subtextColor)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(ratio >= 0.8 ? Colors.green : ratio >= 0.5 ? Colors.orange : Colors.red),
                        minHeight: 8,
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

  Widget _buildRecentHistorySection() {
    if (_attemptHistory.isEmpty) {
      return Card(
        color: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text('No quiz history yet.', style: TextStyle(color: _subtextColor))),
        ),
      );
    }
    return Card(
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Attempts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
            const SizedBox(height: 12),
            ...(_attemptHistory.take(5).map((a) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: a.percentage >= 80 ? Colors.green : a.percentage >= 60 ? Colors.orange : Colors.red,
                child: Text('${a.percentage.toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              title: Text(a.topic, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textColor)),
              subtitle: Text('${a.score}/${a.total} · ${_formatTime(a.timeTakenSeconds)} · ${a.isPracticeMode ? 'Practice' : 'Exam'}',
                  style: TextStyle(fontSize: 11, color: _subtextColor)),
              trailing: Text(
                '${a.date.day}/${a.date.month}',
                style: TextStyle(fontSize: 11, color: _subtextColor),
              ),
            ))),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LEADERBOARD & BOOKMARKS
  // ============================================================
  Widget _buildLeaderboardView() {
    return Center(child: Text('Leaderboard coming soon!', style: TextStyle(color: _textColor)));
  }

  Widget _buildBookmarksView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _bookmarkedQuestions.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text('No bookmarks yet.\nBookmark questions during a quiz!',
                  textAlign: TextAlign.center, style: TextStyle(color: _subtextColor)),
            ]))
          : ListView.builder(
              itemCount: _bookmarkedQuestions.length,
              itemBuilder: (_, i) {
                final idx = _bookmarkedQuestions[i];
                if (idx >= _currentQuestions.length) return const SizedBox();
                final q = _currentQuestions[idx];
                return Card(
                  color: _cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: _primaryColor, child: Text('${idx + 1}', style: const TextStyle(color: Colors.white))),
                    title: Text(q['question'], style: TextStyle(fontSize: 13, color: _textColor)),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark_remove, color: Colors.red),
                      onPressed: () => setState(() => _bookmarkedQuestions.remove(idx)),
                    ),
                  ),
                );
              }),
    );
  }

  // ============================================================
  // CONFETTI
  // ============================================================
  Widget _buildConfetti() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _confettiController,
        builder: (_, __) => CustomPaint(
          painter: ConfettiPainter(_confettiController.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  // ============================================================
  // SHEETS & DIALOGS
  // ============================================================
  void _showBookmarksSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: _buildBookmarksView()),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
              const SizedBox(height: 16),
              _settingSwitch('Dark Mode', Icons.dark_mode, _isDarkMode, (v) => setState(() { _isDarkMode = v; setS(() {}); })),
              _settingSwitch('Timer Per Question', Icons.timer, _isTimerEnabled, (v) => setState(() { _isTimerEnabled = v; setS(() {}); })),
              _settingSwitch('Sound Effects', Icons.volume_up, _soundEnabled, (v) => setState(() { _soundEnabled = v; setS(() {}); })),
              _settingSwitch('Vibration', Icons.vibration, _vibrationEnabled, (v) => setState(() { _vibrationEnabled = v; setS(() {}); })),
              if (_isTimerEnabled) ...[
                const SizedBox(height: 8),
                Text('Timer Duration: ${_timerSeconds}s', style: TextStyle(color: _textColor, fontWeight: FontWeight.w500)),
                Slider(
                  value: _timerSeconds.toDouble(),
                  min: 10, max: 60, divisions: 10,
                  label: '${_timerSeconds}s',
                  onChanged: (v) => setState(() { _timerSeconds = v.toInt(); setS(() {}); }),
                ),
              ],
              const SizedBox(height: 8),
              Text('Font Size: ${_fontSize.toStringAsFixed(0)}', style: TextStyle(color: _textColor, fontWeight: FontWeight.w500)),
              Slider(
                value: _fontSize,
                min: 12, max: 20, divisions: 8,
                label: _fontSize.toStringAsFixed(0),
                onChanged: (v) => setState(() { _fontSize = v; setS(() {}); }),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingSwitch(String label, IconData icon, bool val, ValueChanged<bool> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _primaryColor),
      title: Text(label, style: TextStyle(color: _textColor)),
      trailing: Switch(value: val, onChanged: onChanged, activeColor: _primaryColor),
    );
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quiz History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
              const SizedBox(height: 12),
              Expanded(
                child: _attemptHistory.isEmpty
                    ? Center(child: Text('No history yet.', style: TextStyle(color: _subtextColor)))
                    : ListView.builder(
                        itemCount: _attemptHistory.length,
                        itemBuilder: (_, i) {
                          final a = _attemptHistory[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: a.percentage >= 80 ? Colors.green : a.percentage >= 60 ? Colors.orange : Colors.red,
                              child: Text('${a.percentage.toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                            title: Text(a.topic, style: TextStyle(color: _textColor, fontSize: 13)),
                            subtitle: Text('${a.score}/${a.total} · ${_formatTime(a.timeTakenSeconds)}',
                                style: TextStyle(color: _subtextColor, fontSize: 11)),
                            trailing: Text('${a.date.day}/${a.date.month}/${a.date.year}',
                                style: TextStyle(fontSize: 10, color: _subtextColor)),
                          );
                        }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.computer, color: Colors.blue), SizedBox(width: 8), Text('BS-CSS Quiz')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Version 2.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('A comprehensive quiz app for Computer Systems & Security students.\n\n30+ features including practice mode, timer, bookmarks, analytics, and more!',
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Chip(label: const Text('🎯 5 Topics'), backgroundColor: Colors.blue.shade50),
              const SizedBox(width: 8),
              Chip(label: const Text('📚 40+ Questions'), backgroundColor: Colors.green.shade50),
            ]),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showShareSheet() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Share Result'),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
          child: Text(
            '🎓 BS-CSS Quiz Result\n\n'
            '📚 Topic: $_selectedTopic\n'
            '✅ Score: $_score/${_currentQuestions.length}\n'
            '📊 Percentage: ${_percentage.toStringAsFixed(1)}%\n'
            '⏱ Time: ${_formatTime(_totalElapsed)}\n\n'
            '$_performanceLabel',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: '🎓 BS-CSS Quiz: $_selectedTopic · $_score/${_currentQuestions.length} · ${_percentage.toStringAsFixed(1)}%',
              ));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard!'), behavior: SnackBarBehavior.floating),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showModeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quiz Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              value: true, groupValue: _isPracticeMode,
              onChanged: (_) { _toggleMode(); Navigator.pop(context); },
              title: const Text('Practice Mode'),
              subtitle: const Text('See explanations immediately'),
              secondary: const Icon(Icons.school, color: Colors.blue),
            ),
            RadioListTile<bool>(
              value: false, groupValue: _isPracticeMode,
              onChanged: (_) { _toggleMode(); Navigator.pop(context); },
              title: const Text('Exam Mode'),
              subtitle: const Text('Review after finishing'),
              secondary: const Icon(Icons.edit_note, color: Colors.green),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        height: 360,
        child: Column(
          children: [
            Text('Question Navigator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _navLegend(Colors.green, 'Correct'),
                const SizedBox(width: 12),
                _navLegend(Colors.red, 'Wrong'),
                const SizedBox(width: 12),
                _navLegend(Colors.grey.shade300, 'Not Attempted'),
                const SizedBox(width: 12),
                _navLegend(Colors.amber, 'Current'),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 400 ? 6 : 5,
                  crossAxisSpacing: 8, mainAxisSpacing: 8,
                ),
                itemCount: _currentQuestions.length,
                itemBuilder: (_, i) {
                  final isAnswered = _userAnswers[i] != null;
                  final isCurrent = i == _currentQuestionIndex;
                  final isCorrect = isAnswered && _userAnswers[i] == _currentQuestions[i]['answer'];
                  final isBookmarked = _bookmarkedQuestions.contains(i);
                  return GestureDetector(
                    onTap: () => _jumpToQuestion(i),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: isAnswered
                                ? LinearGradient(colors: isCorrect ? [Colors.green, Colors.green.shade300] : [Colors.red, Colors.red.shade300])
                                : null,
                            color: !isAnswered ? Colors.grey.shade300 : null,
                            shape: BoxShape.circle,
                            border: isCurrent ? Border.all(color: Colors.amber, width: 3) : null,
                          ),
                          child: Center(
                            child: Text('${i + 1}', style: TextStyle(
                              color: isAnswered ? Colors.white : Colors.black87,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            )),
                          ),
                        ),
                        if (isBookmarked)
                          const Positioned(right: 0, top: 0, child: Icon(Icons.bookmark, size: 12, color: Colors.amber)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: _subtextColor)),
      ],
    );
  }
}

// ============================================================
// CONFETTI PAINTER
// ============================================================
class ConfettiPainter extends CustomPainter {
  final double progress;
  final Random _random = Random(42);
  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange];
    for (int i = 0; i < 60; i++) {
      final x = _random.nextDouble() * size.width;
      final startY = -20.0;
      final endY = size.height + 20;
      final y = startY + (endY - startY) * progress + _random.nextDouble() * 50 * sin(progress * 3.14 + i);
      final paint = Paint()..color = colors[i % colors.length].withOpacity(1 - progress * 0.5);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 8, height: 8), paint);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter old) => old.progress != progress;
}

// ============================================================
// EXTENSION
// ============================================================
extension StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}