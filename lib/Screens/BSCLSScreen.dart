import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum QuizState {
  topic,
  quiz,
  result,
  review,
  leaderboard,
  settings,
  statistics,
}

enum Difficulty { easy, medium, hard, mixed }

enum ThemeMode { light, dark, system }

enum SortOrder { alphabetical, questionCount, difficulty, recent }

class BSCLSScreen extends StatefulWidget {
  const BSCLSScreen({super.key});

  @override
  State<BSCLSScreen> createState() => _BSCLSScreenState();
}

class _BSCLSScreenState extends State<BSCLSScreen>
    with SingleTickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────────────
  QuizState _currentState = QuizState.topic;
  String _selectedTopic = '';
  List<Map<String, dynamic>> _currentQuestions = [];
  List<int?> _userAnswers = [];
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _showExplanation = false;
  bool _isPracticeMode = true;

  // ── NEW FEATURES ─────────────────────────────────────────────────────────
  // 1. Timer
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _isTimerEnabled = true;
  int _timerDuration = 30;

  // 2. Dark Mode
  bool _isDarkMode = false;

  // 3. Difficulty Filter
  Difficulty _selectedDifficulty = Difficulty.mixed;

  // 4. Search / Filter
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // 5. Bookmarks
  Set<String> _bookmarkedQuestions = {};

  // 6. Streak / Gamification
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalPoints = 0;
  int _xpPoints = 0;

  // 7. Time Tracking
  DateTime? _quizStartTime;
  int _totalTimeSeconds = 0;

  // 8. Hint System
  int _hintsUsed = 0;
  int _hintsAvailable = 3;
  Set<int> _eliminatedOptions = {};

  // 9. Per-question time tracking
  List<int> _questionTimes = [];
  DateTime? _questionStartTime;

  // 10. Favorite Topics
  Set<String> _favoriteTopics = {};

  // 11. Session History
  List<Map<String, dynamic>> _sessionHistory = [];

  // 12. Sound / Haptic
  bool _hapticEnabled = true;
  bool _soundEnabled = true;

  // 13. Font size
  double _fontSize = 16.0;

  // 14. Question shuffle toggle
  bool _shuffleOptions = false;

  // 15. Auto-advance
  bool _autoAdvance = true;

  // 16. Show correct on wrong
  bool _showCorrectOnWrong = true;

  // 17. Confidence rating
  List<int?> _confidenceRatings = [];

  // 18. Notes per question
  Map<int, String> _questionNotes = {};

  // 19. Study plan
  int _dailyGoal = 10;
  int _questionsToday = 0;

  // 20. Sort order for topics
  SortOrder _topicSortOrder = SortOrder.alphabetical;

  // 21. Quick Review mode
  bool _quickReviewMode = false;

  // 22. Highlight keywords
  bool _highlightKeywords = true;

  // 23. Statistics
  Map<String, List<int>> _topicScoreHistory = {};

  // 24. Badges
  List<String> _earnedBadges = [];

  // 25. Report question flag
  Set<int> _reportedQuestions = {};

  // 26. Read-aloud placeholder
  bool _readAloudEnabled = false;

  // 27. Full screen mode
  bool _isFullScreen = false;

  // 28. Countdown before start
  int _countdownValue = 0;
  bool _showCountdown = false;

  // 29. Pause quiz
  bool _isPaused = false;

  // 30. Skip question
  int _skippedCount = 0;

  // 31. Category tags per question
  // (included in quizData metadata below)

  // 32. Mastery level per topic
  Map<String, int> _topicMastery = {};

  // 33. Answer history for analytics
  List<Map<String, dynamic>> _answerHistory = [];

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ── Quiz Data ─────────────────────────────────────────────────────────────
  final Map<String, List<Map<String, dynamic>>> quizData = {
    "Foundation Communication": [
      // Self introduction in simple English (1-10)
      {
        "question": "How do you complete 'Hello, my ______ is John'?",
        "options": ["name", "old", "from", "live"],
        "answer": 0,
        "explanation": "We say 'my name is' to introduce ourselves.",
        "difficulty": "easy",
        "tags": ["self introduction", "beginner"],
        "keywords": ["introduction", "name"],
      },
      {
        "question": "Which sentence correctly introduces your age?",
        "options": [
          "I have 20 years.",
          "I am 20 years old.",
          "I feel 20 years.",
          "I do 20 years.",
        ],
        "answer": 1,
        "explanation":
            "'I am [age] years old' is the correct structure for introducing age.",
        "difficulty": "easy",
        "tags": ["self introduction", "age"],
        "keywords": ["age", "years old"],
      },
      {
        "question": "What do you say to tell someone where you live?",
        "options": [
          "I work New York.",
          "I go New York.",
          "I live in New York.",
          "I stay at New York.",
        ],
        "answer": 2,
        "explanation":
            "'I live in + city' is the standard way to state your residence.",
        "difficulty": "easy",
        "tags": ["self introduction", "location"],
        "keywords": ["live in", "city"],
      },
      {
        "question": "Choose the correct self-introduction:",
        "options": ["Me John.", "I is John.", "My name John.", "I am John."],
        "answer": 3,
        "explanation":
            "'I am + name' is a complete and correct simple sentence.",
        "difficulty": "easy",
        "tags": ["self introduction", "grammar"],
        "keywords": ["I am", "name"],
      },
      {
        "question": "What does 'I am from Canada' mean?",
        "options": [
          "I was born in Canada",
          "I like Canada",
          "I am going to Canada",
          "Canada is big",
        ],
        "answer": 0,
        "explanation": "'I am from...' indicates your origin or nationality.",
        "difficulty": "easy",
        "tags": ["self introduction", "origin"],
        "keywords": ["from", "origin"],
      },
      {
        "question": "Which question asks for someone's occupation?",
        "options": [
          "What do you do?",
          "Where do you live?",
          "How old are you?",
          "What is your name?",
        ],
        "answer": 0,
        "explanation":
            "'What do you do?' is the standard way to ask about someone's job.",
        "difficulty": "easy",
        "tags": ["self introduction", "occupation"],
        "keywords": ["occupation", "job"],
      },
      {
        "question": "Respond to: 'Nice to meet you.'",
        "options": [
          "I am nice.",
          "Nice to meet you too.",
          "Thank you.",
          "Okay.",
        ],
        "answer": 1,
        "explanation":
            "'Nice to meet you too' is the polite and expected response.",
        "difficulty": "easy",
        "tags": ["self introduction", "greetings"],
        "keywords": ["nice to meet you", "response"],
      },
      {
        "question": "Complete: 'Let me introduce ______. I am Maria.'",
        "options": ["me", "myself", "I", "mine"],
        "answer": 1,
        "explanation": "'Let me introduce myself' is the correct phrase.",
        "difficulty": "easy",
        "tags": ["self introduction", "phrase"],
        "keywords": ["introduce myself"],
      },
      {
        "question":
            "What do you say after stating your name in a formal setting?",
        "options": [
          "That's all.",
          "It's my pleasure to meet you.",
          "Call me.",
          "Name.",
        ],
        "answer": 1,
        "explanation":
            "'It's my pleasure to meet you' adds politeness after introducing yourself.",
        "difficulty": "medium",
        "tags": ["self introduction", "formal"],
        "keywords": ["pleasure", "formal"],
      },
      {
        "question": "Which is correct for introducing your family status?",
        "options": [
          "I live single.",
          "I am married.",
          "I do married.",
          "I have married.",
        ],
        "answer": 1,
        "explanation": "'I am married/single' is the correct adjective form.",
        "difficulty": "easy",
        "tags": ["self introduction", "family status"],
        "keywords": ["married", "single"],
      },
      // Family and friend descriptions (11-20)
      {
        "question": "How do you say your father's brother in English?",
        "options": ["Cousin", "Uncle", "Grandfather", "Brother"],
        "answer": 1,
        "explanation": "Your father's brother is your uncle.",
        "difficulty": "easy",
        "tags": ["family", "relations"],
        "keywords": ["uncle", "family"],
      },
      {
        "question": "Complete: 'My sister ______ long black hair.'",
        "options": ["have", "is", "has", "are"],
        "answer": 2,
        "explanation": "'Has' is used for third-person singular (she/he/it).",
        "difficulty": "easy",
        "tags": ["descriptions", "grammar"],
        "keywords": ["has", "hair"],
      },
      {
        "question": "Which word describes a friendly person?",
        "options": ["Shy", "Outgoing", "Lazy", "Quiet"],
        "answer": 1,
        "explanation": "'Outgoing' describes someone sociable and friendly.",
        "difficulty": "easy",
        "tags": ["friend descriptions", "adjectives"],
        "keywords": ["outgoing", "friendly"],
      },
      {
        "question": "What is a 'sibling'?",
        "options": ["Parent", "Brother or sister", "Cousin", "Friend"],
        "answer": 1,
        "explanation": "A sibling is a brother or sister.",
        "difficulty": "easy",
        "tags": ["family", "vocabulary"],
        "keywords": ["sibling", "brother", "sister"],
      },
      {
        "question": "Describe someone who is 'tall and slim'.",
        "options": [
          "Short and fat",
          "High and thin",
          "Long and narrow",
          "Tall and thin",
        ],
        "answer": 3,
        "explanation": "'Slim' means thin in a healthy way.",
        "difficulty": "easy",
        "tags": ["physical description", "adjectives"],
        "keywords": ["tall", "slim", "thin"],
      },
      {
        "question": "How do you ask about someone's best friend?",
        "options": [
          "Who is him?",
          "Who is your best friend?",
          "How best friend?",
          "Where best friend?",
        ],
        "answer": 1,
        "explanation":
            "'Who is your best friend?' is the correct question form.",
        "difficulty": "easy",
        "tags": ["friends", "questions"],
        "keywords": ["best friend", "who"],
      },
      {
        "question":
            "Complete: 'My mother is very ______. She always helps others.'",
        "options": ["mean", "selfish", "caring", "loud"],
        "answer": 2,
        "explanation": "'Caring' describes someone kind and helpful.",
        "difficulty": "easy",
        "tags": ["family", "personality"],
        "keywords": ["caring", "helps"],
      },
      {
        "question": "What do you call your mother's mother?",
        "options": ["Grandma", "Aunt", "Niece", "Cousin"],
        "answer": 0,
        "explanation": "Your mother's mother is your grandmother (grandma).",
        "difficulty": "easy",
        "tags": ["family", "relations"],
        "keywords": ["grandmother", "grandma"],
      },
      {
        "question": "Which sentence correctly describes a friend's appearance?",
        "options": [
          "He has eyes blue.",
          "He blue eyes.",
          "He has blue eyes.",
          "He is blue eyes.",
        ],
        "answer": 2,
        "explanation":
            "The correct order is 'has + adjective + noun' — 'has blue eyes'.",
        "difficulty": "easy",
        "tags": ["descriptions", "grammar"],
        "keywords": ["has", "blue eyes"],
      },
      {
        "question":
            "What does 'look like' mean in 'What does your brother look like?'",
        "options": [
          "What is his job?",
          "What is his age?",
          "What is his appearance?",
          "What is his name?",
        ],
        "answer": 2,
        "explanation": "'Look like' asks about physical appearance.",
        "difficulty": "easy",
        "tags": ["descriptions", "questions"],
        "keywords": ["look like", "appearance"],
      },
      // Daily routine conversation (21-30)
      {
        "question": "What time do most people eat breakfast?",
        "options": [
          "In the evening",
          "In the morning",
          "At midnight",
          "In the afternoon",
        ],
        "answer": 1,
        "explanation":
            "Breakfast is the first meal of the day, eaten in the morning.",
        "difficulty": "easy",
        "tags": ["daily routine", "meals"],
        "keywords": ["breakfast", "morning"],
      },
      {
        "question": "Complete: 'I ______ up at 7 AM every day.'",
        "options": ["get", "wake", "stand", "rise"],
        "answer": 1,
        "explanation":
            "'Wake up' is the correct phrasal verb for ending sleep.",
        "difficulty": "easy",
        "tags": ["daily routine", "verbs"],
        "keywords": ["wake up"],
      },
      {
        "question": "What do you say after finishing work?",
        "options": [
          "I start work.",
          "I go to work.",
          "I finish work.",
          "I sleep work.",
        ],
        "answer": 2,
        "explanation": "'I finish work' means your workday ends.",
        "difficulty": "easy",
        "tags": ["daily routine", "work"],
        "keywords": ["finish work"],
      },
      {
        "question": "Choose the correct question for bedtime:",
        "options": [
          "When do you go to school?",
          "When do you go to bed?",
          "When do you eat?",
          "When do you play?",
        ],
        "answer": 1,
        "explanation": "'Go to bed' means to lie down and sleep.",
        "difficulty": "easy",
        "tags": ["daily routine", "sleep"],
        "keywords": ["go to bed", "sleep"],
      },
      {
        "question": "What is a typical evening activity?",
        "options": [
          "Eat breakfast",
          "Watch TV",
          "Go to school",
          "Take a shower in the morning",
        ],
        "answer": 1,
        "explanation": "Watching TV is a common evening leisure activity.",
        "difficulty": "easy",
        "tags": ["daily routine", "evening"],
        "keywords": ["evening", "TV"],
      },
      {
        "question": "Complete: 'After work, I usually ______ home.'",
        "options": ["come", "go", "return", "arrive"],
        "answer": 1,
        "explanation":
            "'Go home' is the most natural phrase (not 'come home' unless speaking from home).",
        "difficulty": "easy",
        "tags": ["daily routine", "home"],
        "keywords": ["go home"],
      },
      {
        "question": "How do you ask about someone's daily schedule?",
        "options": [
          "What is your day?",
          "How is your routine?",
          "What do you usually do in a day?",
          "When day?",
        ],
        "answer": 2,
        "explanation":
            "'What do you usually do in a day?' is a clear and natural question.",
        "difficulty": "easy",
        "tags": ["daily routine", "questions"],
        "keywords": ["usually", "daily"],
      },
      {
        "question": "Which is a morning routine activity?",
        "options": [
          "Brush teeth",
          "Eat dinner",
          "Watch news at 10 PM",
          "Sleep",
        ],
        "answer": 0,
        "explanation":
            "Brushing teeth is typically done in the morning (and night).",
        "difficulty": "easy",
        "tags": ["daily routine", "morning"],
        "keywords": ["brush teeth", "morning"],
      },
      {
        "question": "What does 'I have lunch at noon' mean?",
        "options": [
          "I eat lunch at 12 PM",
          "I skip lunch",
          "I eat lunch at night",
          "I cook lunch",
        ],
        "answer": 0,
        "explanation": "'Noon' means 12:00 in the daytime.",
        "difficulty": "easy",
        "tags": ["daily routine", "time"],
        "keywords": ["lunch", "noon"],
      },
      {
        "question": "Respond to: 'What time do you get home?'",
        "options": [
          "Yes, I do.",
          "I get home at 6 PM.",
          "Home is nice.",
          "At morning.",
        ],
        "answer": 1,
        "explanation":
            "The answer should state the specific time you arrive home.",
        "difficulty": "easy",
        "tags": ["daily routine", "response"],
        "keywords": ["get home", "time"],
      },
      // Home and neighborhood vocabulary (31-40)
      {
        "question": "Where do you sleep in a house?",
        "options": ["Kitchen", "Living room", "Bedroom", "Bathroom"],
        "answer": 2,
        "explanation": "The bedroom is the room designated for sleeping.",
        "difficulty": "easy",
        "tags": ["home", "rooms"],
        "keywords": ["bedroom", "sleep"],
      },
      {
        "question": "What is a 'neighbor'?",
        "options": [
          "A family member",
          "Someone who lives near you",
          "A shopkeeper",
          "A teacher",
        ],
        "answer": 1,
        "explanation": "A neighbor lives in a nearby house or apartment.",
        "difficulty": "easy",
        "tags": ["neighborhood", "vocabulary"],
        "keywords": ["neighbor", "near"],
      },
      {
        "question": "Complete: 'There is a park ______ my house.'",
        "options": ["near", "inside", "under", "behind of"],
        "answer": 0,
        "explanation":
            "'Near' means close to. 'Behind of' is incorrect (just 'behind').",
        "difficulty": "easy",
        "tags": ["neighborhood", "prepositions"],
        "keywords": ["near", "park"],
      },
      {
        "question": "What do you call the place where you buy food?",
        "options": ["Library", "Hospital", "Supermarket", "School"],
        "answer": 2,
        "explanation": "A supermarket sells groceries and food items.",
        "difficulty": "easy",
        "tags": ["neighborhood", "places"],
        "keywords": ["supermarket", "food"],
      },
      {
        "question": "Which room is for cooking?",
        "options": ["Bathroom", "Bedroom", "Kitchen", "Garage"],
        "answer": 2,
        "explanation":
            "The kitchen is designed for cooking and food preparation.",
        "difficulty": "easy",
        "tags": ["home", "rooms"],
        "keywords": ["kitchen", "cook"],
      },
      {
        "question": "What does 'downtown' mean?",
        "options": [
          "Outside the city",
          "The central business area",
          "Near a farm",
          "Under a bridge",
        ],
        "answer": 1,
        "explanation":
            "'Downtown' refers to the main commercial center of a city.",
        "difficulty": "medium",
        "tags": ["neighborhood", "vocabulary"],
        "keywords": ["downtown", "city center"],
      },
      {
        "question": "Choose the correct sentence about a quiet street:",
        "options": [
          "There are many cars every minute.",
          "There is no noise.",
          "The street has concerts daily.",
          "People shout all day.",
        ],
        "answer": 1,
        "explanation": "A quiet street has little or no noise.",
        "difficulty": "easy",
        "tags": ["neighborhood", "description"],
        "keywords": ["quiet", "noise"],
      },
      {
        "question": "What is a 'balcony'?",
        "options": [
          "A type of door",
          "A platform outside a building",
          "A roof",
          "A basement",
        ],
        "answer": 1,
        "explanation":
            "A balcony is an outdoor platform projecting from a wall.",
        "difficulty": "easy",
        "tags": ["home", "parts"],
        "keywords": ["balcony", "platform"],
      },
      {
        "question":
            "Complete: 'Turn left at the ______ and you will see my house.'",
        "options": ["corner", "inside", "table", "bed"],
        "answer": 0,
        "explanation":
            "A corner (of a street) is a common landmark for directions.",
        "difficulty": "easy",
        "tags": ["neighborhood", "directions"],
        "keywords": ["corner", "turn left"],
      },
      {
        "question": "What is the ground floor?",
        "options": [
          "The top floor",
          "The floor at street level",
          "The basement",
          "The roof",
        ],
        "answer": 1,
        "explanation":
            "The ground floor is the floor at the same level as the outside ground.",
        "difficulty": "easy",
        "tags": ["home", "floors"],
        "keywords": ["ground floor", "street level"],
      },
      // School and classroom communication (41-50)
      {
        "question":
            "What do you say to ask for permission to enter the classroom?",
        "options": [
          "Close the door.",
          "May I come in?",
          "Sit down.",
          "Open window.",
        ],
        "answer": 1,
        "explanation": "'May I come in?' is a polite request for permission.",
        "difficulty": "easy",
        "tags": ["school", "permission"],
        "keywords": ["may I", "come in"],
      },
      {
        "question":
            "Complete: 'I don't understand. Can you ______ that, please?'",
        "options": ["stop", "repeat", "close", "write down"],
        "answer": 1,
        "explanation": "'Repeat' means to say again.",
        "difficulty": "easy",
        "tags": ["school", "classroom"],
        "keywords": ["repeat", "understand"],
      },
      {
        "question": "What is a 'whiteboard' used for?",
        "options": [
          "Eating lunch",
          "Writing with markers",
          "Playing football",
          "Sleeping",
        ],
        "answer": 1,
        "explanation":
            "A whiteboard is a glossy surface for writing with dry-erase markers.",
        "difficulty": "easy",
        "tags": ["school", "objects"],
        "keywords": ["whiteboard", "markers"],
      },
      {
        "question": "How do you ask about today's homework?",
        "options": [
          "What is lunch?",
          "Where is the teacher?",
          "What is the homework for today?",
          "When is break?",
        ],
        "answer": 2,
        "explanation":
            "'What is the homework for today?' directly asks for assignments.",
        "difficulty": "easy",
        "tags": ["school", "homework"],
        "keywords": ["homework", "today"],
      },
      {
        "question": "Choose the polite way to ask a classmate for a pen:",
        "options": [
          "Give me pen.",
          "Pen me.",
          "Can I borrow your pen, please?",
          "You give pen.",
        ],
        "answer": 2,
        "explanation":
            "'Can I borrow... please?' is polite and grammatically correct.",
        "difficulty": "easy",
        "tags": ["school", "requests"],
        "keywords": ["borrow", "please"],
      },
      {
        "question": "What does 'Turn to page 10' mean?",
        "options": [
          "Close the book",
          "Open the book to page 10",
          "Throw the book",
          "Draw page 10",
        ],
        "answer": 1,
        "explanation":
            "'Turn to page X' means open your book to that specific page.",
        "difficulty": "easy",
        "tags": ["school", "instructions"],
        "keywords": ["turn to page", "instructions"],
      },
      {
        "question": "Complete: '______ I go to the bathroom?'",
        "options": ["Can", "Do", "Am", "Have"],
        "answer": 0,
        "explanation": "'Can I' or 'May I' is used to ask permission.",
        "difficulty": "easy",
        "tags": ["school", "permission"],
        "keywords": ["can I", "bathroom"],
      },
      {
        "question": "What do you call the person who teaches you?",
        "options": ["Student", "Principal", "Teacher", "Driver"],
        "answer": 2,
        "explanation": "A teacher instructs students in a classroom.",
        "difficulty": "easy",
        "tags": ["school", "people"],
        "keywords": ["teacher"],
      },
      {
        "question": "Respond to: 'Please open your books.'",
        "options": ["Yes, close.", "Okay, I open.", "Okay, teacher.", "No."],
        "answer": 2,
        "explanation": "'Okay, teacher' is a respectful acknowledgment.",
        "difficulty": "easy",
        "tags": ["school", "responses"],
        "keywords": ["okay teacher"],
      },
      {
        "question": "What is a 'deskmate'?",
        "options": [
          "A type of desk",
          "Someone who sits next to you",
          "A cleaning tool",
          "A subject",
        ],
        "answer": 1,
        "explanation":
            "Your deskmate is the classmate who shares the same desk or sits beside you.",
        "difficulty": "easy",
        "tags": ["school", "vocabulary"],
        "keywords": ["deskmate", "sits next to"],
      },
      // Basic Speaking Skills: Likes and dislikes expressions (51-60)
      {
        "question": "How do you say you enjoy something?",
        "options": [
          "I hate it.",
          "I like it.",
          "It's terrible.",
          "I don't want it.",
        ],
        "answer": 1,
        "explanation":
            "'I like it' is the simplest positive expression of enjoyment.",
        "difficulty": "easy",
        "tags": ["likes", "expressions"],
        "keywords": ["like", "enjoy"],
      },
      {
        "question": "Complete: 'I ______ eating fast food. It's unhealthy.'",
        "options": ["love", "enjoy", "dislike", "adore"],
        "answer": 2,
        "explanation": "'Dislike' means you do not like something.",
        "difficulty": "easy",
        "tags": ["dislikes", "vocabulary"],
        "keywords": ["dislike", "unhealthy"],
      },
      {
        "question":
            "What is a stronger way to say you like something very much?",
        "options": [
          "I hate it.",
          "I don't mind it.",
          "I love it.",
          "It's okay.",
        ],
        "answer": 2,
        "explanation": "'I love it' expresses strong positive feelings.",
        "difficulty": "easy",
        "tags": ["likes", "intensity"],
        "keywords": ["love", "strong like"],
      },
      {
        "question": "Choose the neutral opinion:",
        "options": ["I hate it.", "I love it.", "It's okay.", "It's terrible."],
        "answer": 2,
        "explanation":
            "'It's okay' expresses neither strong like nor strong dislike.",
        "difficulty": "easy",
        "tags": ["expressions", "neutral"],
        "keywords": ["okay", "neutral"],
      },
      {
        "question": "How do you ask someone about their preference?",
        "options": [
          "Do you like pizza?",
          "Pizza good?",
          "Like pizza you?",
          "You pizza want?",
        ],
        "answer": 0,
        "explanation":
            "'Do you like...?' is the standard question for preferences.",
        "difficulty": "easy",
        "tags": ["likes", "questions"],
        "keywords": ["do you like", "preferences"],
      },
      {
        "question":
            "Complete: 'I don't ______ horror movies because they scare me.'",
        "options": ["hate", "like", "enjoy", "prefer"],
        "answer": 2,
        "explanation":
            "'Don't enjoy' is a softer way to say you dislike something.",
        "difficulty": "medium",
        "tags": ["dislikes", "expressions"],
        "keywords": ["don't enjoy", "horror"],
      },
      {
        "question": "What does 'I prefer tea to coffee' mean?",
        "options": [
          "I like both equally",
          "I like tea more than coffee",
          "I like coffee more than tea",
          "I hate both",
        ],
        "answer": 1,
        "explanation": "'Prefer A to B' means you like A more than B.",
        "difficulty": "medium",
        "tags": ["likes", "preferences"],
        "keywords": ["prefer", "more than"],
      },
      {
        "question":
            "Respond to: 'Do you like classical music?' (Say you love it)",
        "options": ["No.", "Yes, I love it.", "Maybe.", "Not really."],
        "answer": 1,
        "explanation":
            "'Yes, I love it' directly answers the question with enthusiasm.",
        "difficulty": "easy",
        "tags": ["likes", "responses"],
        "keywords": ["love it", "response"],
      },
      {
        "question": "Choose the phrase that means 'to enjoy very little':",
        "options": [
          "I'm crazy about it.",
          "I'm not very fond of it.",
          "I adore it.",
          "I'm passionate about it.",
        ],
        "answer": 1,
        "explanation":
            "'Not very fond of it' means mild dislike or very little enjoyment.",
        "difficulty": "medium",
        "tags": ["dislikes", "phrases"],
        "keywords": ["fond of", "little enjoyment"],
      },
      {
        "question": "Complete: 'What ______ your hobbies?'",
        "options": ["is", "are", "am", "be"],
        "answer": 1,
        "explanation": "'Hobbies' is plural, so use 'are'.",
        "difficulty": "easy",
        "tags": ["likes", "grammar"],
        "keywords": ["hobbies", "are"],
      },
      // Asking and answering questions (61-70)
      {
        "question": "Which word asks about a place?",
        "options": ["Who", "Where", "When", "Why"],
        "answer": 1,
        "explanation": "'Where' is the question word for location.",
        "difficulty": "easy",
        "tags": ["questions", "wh-words"],
        "keywords": ["where", "place"],
      },
      {
        "question": "Complete: '______ is your birthday?'",
        "options": ["What", "Where", "When", "Who"],
        "answer": 2,
        "explanation": "'When' asks for time or date.",
        "difficulty": "easy",
        "tags": ["questions", "time"],
        "keywords": ["when", "birthday"],
      },
      {
        "question": "How do you ask about the reason?",
        "options": ["What for?", "Why?", "How come?", "All of these"],
        "answer": 3,
        "explanation":
            "'Why?', 'What for?', and 'How come?' all ask for a reason.",
        "difficulty": "easy",
        "tags": ["questions", "reason"],
        "keywords": ["why", "reason"],
      },
      {
        "question": "Answer: 'How are you?'",
        "options": [
          "I am fine, thanks.",
          "Yes, I am.",
          "I am John.",
          "At home.",
        ],
        "answer": 0,
        "explanation": "'I am fine, thanks' is the standard positive response.",
        "difficulty": "easy",
        "tags": ["answers", "greetings"],
        "keywords": ["how are you", "fine"],
      },
      {
        "question": "What is the correct reply to 'How old are you?'",
        "options": ["I am 25.", "I have 25.", "I do 25.", "I am old."],
        "answer": 0,
        "explanation": "'I am + age' is the correct structure.",
        "difficulty": "easy",
        "tags": ["answers", "age"],
        "keywords": ["age", "I am"],
      },
      {
        "question": "Which question asks about a method?",
        "options": [
          "Who did it?",
          "How did you do it?",
          "Where is it?",
          "When did it happen?",
        ],
        "answer": 1,
        "explanation": "'How' asks about the way or method something is done.",
        "difficulty": "easy",
        "tags": ["questions", "method"],
        "keywords": ["how", "method"],
      },
      {
        "question": "Complete the tag question: 'You like coffee, ______?'",
        "options": ["don't you", "do you", "isn't it", "aren't you"],
        "answer": 0,
        "explanation":
            "Positive statement → negative tag: 'do' becomes 'don't you'.",
        "difficulty": "medium",
        "tags": ["questions", "tag questions"],
        "keywords": ["tag question", "don't you"],
      },
      {
        "question": "Choose the indirect question:",
        "options": [
          "Where is the bank?",
          "Can you tell me where the bank is?",
          "Bank where?",
          "Where bank?",
        ],
        "answer": 1,
        "explanation":
            "'Can you tell me where the bank is?' is indirect and more polite.",
        "difficulty": "medium",
        "tags": ["questions", "indirect"],
        "keywords": ["indirect question", "polite"],
      },
      {
        "question": "Respond to: 'Would you like some tea?' (Accept politely)",
        "options": ["No.", "Yes, I would.", "Yes, please.", "Give me."],
        "answer": 2,
        "explanation": "'Yes, please' is the standard polite acceptance.",
        "difficulty": "easy",
        "tags": ["answers", "offers"],
        "keywords": ["yes please", "accept"],
      },
      {
        "question": "What does 'What do you mean?' ask for?",
        "options": ["Clarification", "Repetition", "Translation", "Spelling"],
        "answer": 0,
        "explanation":
            "'What do you mean?' asks the speaker to explain or clarify.",
        "difficulty": "easy",
        "tags": ["questions", "clarification"],
        "keywords": ["what do you mean", "clarify"],
      },
      // Sentence linking and connectors (71-75)
      {
        "question": "Which word shows a reason?",
        "options": ["but", "because", "or", "so"],
        "answer": 1,
        "explanation": "'Because' introduces a reason or cause.",
        "difficulty": "easy",
        "tags": ["connectors", "reason"],
        "keywords": ["because", "reason"],
      },
      {
        "question": "Complete: 'I was tired, ______ I went to bed early.'",
        "options": ["but", "or", "so", "because"],
        "answer": 2,
        "explanation": "'So' shows a result or consequence.",
        "difficulty": "easy",
        "tags": ["connectors", "result"],
        "keywords": ["so", "result"],
      },
      {
        "question": "Choose the contrast connector:",
        "options": ["and", "because", "but", "so"],
        "answer": 2,
        "explanation": "'But' shows contrast or opposition.",
        "difficulty": "easy",
        "tags": ["connectors", "contrast"],
        "keywords": ["but", "contrast"],
      },
      {
        "question": "Combine: 'I like apples. I like bananas.'",
        "options": [
          "I like apples but bananas.",
          "I like apples or bananas.",
          "I like apples and bananas.",
          "I like apples so bananas.",
        ],
        "answer": 2,
        "explanation": "'And' adds similar ideas together.",
        "difficulty": "easy",
        "tags": ["sentence linking", "and"],
        "keywords": ["and", "combine"],
      },
      {
        "question": "Complete: 'I don't want coffee, ______ tea.'",
        "options": ["and", "but", "or", "so"],
        "answer": 2,
        "explanation": "'Or' presents an alternative.",
        "difficulty": "easy",
        "tags": ["connectors", "alternative"],
        "keywords": ["or", "alternative"],
      },
      // Following instructions (76-80)
      {
        "question": "What do you do when a teacher says 'Sit down'?",
        "options": [
          "Stand up",
          "Leave the room",
          "Take a seat",
          "Raise your hand",
        ],
        "answer": 2,
        "explanation":
            "'Sit down' means to move from standing to sitting on a chair.",
        "difficulty": "easy",
        "tags": ["instructions", "classroom"],
        "keywords": ["sit down", "take a seat"],
      },
      {
        "question":
            "Complete the instruction: '______ your name at the top of the paper.'",
        "options": ["Draw", "Write", "Read", "Erase"],
        "answer": 1,
        "explanation":
            "'Write your name' is the correct verb for putting text on paper.",
        "difficulty": "easy",
        "tags": ["instructions", "writing"],
        "keywords": ["write", "name"],
      },
      {
        "question": "What does 'Wait a moment' mean?",
        "options": [
          "Leave now",
          "Be patient for a short time",
          "Run fast",
          "Speak loudly",
        ],
        "answer": 1,
        "explanation": "'Wait a moment' asks you to pause briefly.",
        "difficulty": "easy",
        "tags": ["instructions", "patience"],
        "keywords": ["wait", "moment"],
      },
      {
        "question": "Respond to: 'Please pass the salt.'",
        "options": ["Here you are.", "No.", "Why?", "Salt is bad."],
        "answer": 0,
        "explanation":
            "'Here you are' is the polite response when handing something over.",
        "difficulty": "easy",
        "tags": ["instructions", "responses"],
        "keywords": ["pass", "here you are"],
      },
      {
        "question":
            "What should you do if an instruction says 'Turn off your phone'?",
        "options": [
          "Call someone",
          "Power down your phone",
          "Hide your phone",
          "Turn up volume",
        ],
        "answer": 1,
        "explanation": "'Turn off' means to power down or switch off a device.",
        "difficulty": "easy",
        "tags": ["instructions", "devices"],
        "keywords": ["turn off", "phone"],
      },
      // Polite conversation and requesting help (81-85)
      {
        "question": "Which phrase is most polite to ask for help?",
        "options": [
          "Help me.",
          "Could you help me, please?",
          "I need help now.",
          "You help.",
        ],
        "answer": 1,
        "explanation":
            "'Could you help me, please?' uses a polite modal and 'please'.",
        "difficulty": "easy",
        "tags": ["polite", "requests"],
        "keywords": ["could you", "please"],
      },
      {
        "question": "Complete: '______ me, where is the station?'",
        "options": ["Sorry", "Excuse", "Hello", "Thanks"],
        "answer": 1,
        "explanation": "'Excuse me' is used to get attention politely.",
        "difficulty": "easy",
        "tags": ["polite", "attention"],
        "keywords": ["excuse me"],
      },
      {
        "question": "How do you thank someone after they help you?",
        "options": ["Sorry.", "Thank you so much.", "No problem.", "I know."],
        "answer": 1,
        "explanation": "'Thank you so much' expresses sincere gratitude.",
        "difficulty": "easy",
        "tags": ["polite", "thanks"],
        "keywords": ["thank you", "gratitude"],
      },
      {
        "question": "Choose the polite refusal:",
        "options": ["No way.", "I can't, sorry.", "Never.", "Forget it."],
        "answer": 1,
        "explanation": "'I can't, sorry' politely declines while apologizing.",
        "difficulty": "easy",
        "tags": ["polite", "refusal"],
        "keywords": ["sorry", "refusal"],
      },
      {
        "question": "What does 'Would you mind...?' ask?",
        "options": ["An order", "A polite request", "A complaint", "A story"],
        "answer": 1,
        "explanation":
            "'Would you mind...?' is a very polite way to make a request.",
        "difficulty": "medium",
        "tags": ["polite", "requests"],
        "keywords": ["would you mind", "polite request"],
      },
    ],
    "Basic Speaking Skills": [
      // ========== LIKES AND DISLIKES EXPRESSIONS (1-16) ==========
      {
        "question": "How do you say you really enjoy playing football?",
        "options": [
          "I hate football.",
          "I am crazy about football.",
          "Football is boring.",
          "I never play football.",
        ],
        "answer": 1,
        "explanation":
            "'I am crazy about' means you really enjoy something very much.",
        "difficulty": "easy",
        "tags": ["likes", "intensity"],
        "keywords": ["crazy about", "enjoy"],
      },
      {
        "question":
            "Complete: 'I ______ going to the gym. It's my favorite activity.'",
        "options": ["dislike", "hate", "love", "avoid"],
        "answer": 2,
        "explanation":
            "'Love' expresses strong positive feeling, matching 'favorite activity'.",
        "difficulty": "easy",
        "tags": ["likes", "expressions"],
        "keywords": ["love", "favorite"],
      },
      {
        "question": "What does 'I can't stand loud music' mean?",
        "options": [
          "I really like loud music.",
          "I really hate loud music.",
          "I play loud music.",
          "I don't hear loud music.",
        ],
        "answer": 1,
        "explanation":
            "'Can't stand' is a strong way to say you hate or strongly dislike something.",
        "difficulty": "easy",
        "tags": ["dislikes", "strong expressions"],
        "keywords": ["can't stand", "hate"],
      },
      {
        "question": "Choose the softest way to say you don't like something:",
        "options": [
          "I hate it.",
          "I detest it.",
          "I'm not very keen on it.",
          "I can't stand it.",
        ],
        "answer": 2,
        "explanation":
            "'I'm not very keen on it' is a mild, polite expression of dislike.",
        "difficulty": "medium",
        "tags": ["dislikes", "soft expressions"],
        "keywords": ["not keen on", "mild dislike"],
      },
      {
        "question": "Complete: 'What kind of music do you ______?'",
        "options": ["prefer", "prefers", "preferring", "preferred"],
        "answer": 0,
        "explanation":
            "After 'do you', use the base form of the verb: 'prefer'.",
        "difficulty": "easy",
        "tags": ["preferences", "grammar"],
        "keywords": ["prefer", "grammar"],
      },
      {
        "question":
            "Respond: 'Do you like spicy food?' (Say you love it dramatically)",
        "options": [
          "No.",
          "It's okay.",
          "I'm absolutely crazy about it!",
          "I don't know.",
        ],
        "answer": 2,
        "explanation":
            "'I'm absolutely crazy about it!' shows strong enthusiasm.",
        "difficulty": "medium",
        "tags": ["likes", "responses"],
        "keywords": ["crazy about", "enthusiasm"],
      },
      {
        "question": "What does 'I'm fond of reading' mean?",
        "options": [
          "I hate reading.",
          "I like reading.",
          "I read every day.",
          "Reading is boring.",
        ],
        "answer": 1,
        "explanation":
            "'Fond of' means to like something, often in a gentle way.",
        "difficulty": "easy",
        "tags": ["likes", "vocabulary"],
        "keywords": ["fond of", "like"],
      },
      {
        "question": "Complete: 'I don't ______ waking up early on weekends.'",
        "options": ["mind", "love", "adore", "enjoy very much"],
        "answer": 0,
        "explanation":
            "'Don't mind' means it doesn't bother you; a neutral expression.",
        "difficulty": "easy",
        "tags": ["likes/dislikes", "neutral"],
        "keywords": ["don't mind", "neutral"],
      },
      {
        "question":
            "How do you ask someone about their favorite free time activity?",
        "options": [
          "What do you do in your free time?",
          "Where do you work?",
          "How old are you?",
          "What is your job?",
        ],
        "answer": 0,
        "explanation":
            "'What do you do in your free time?' asks about hobbies and leisure activities.",
        "difficulty": "easy",
        "tags": ["hobbies", "questions"],
        "keywords": ["free time", "hobby"],
      },
      {
        "question": "Choose the correct sentence:",
        "options": [
          "I like very much pizza.",
          "I like pizza very much.",
          "I very much like pizza.",
          "Like I pizza very much.",
        ],
        "answer": 1,
        "explanation":
            "The correct word order is 'I like + object + very much'.",
        "difficulty": "easy",
        "tags": ["likes", "word order"],
        "keywords": ["word order", "very much"],
      },
      {
        "question": "What does 'I'm into photography' mean?",
        "options": [
          "I'm inside photography.",
          "I'm interested in photography.",
          "I hate photography.",
          "I am a camera.",
        ],
        "answer": 1,
        "explanation":
            "'I'm into' is casual for 'I am interested in' or 'I like'.",
        "difficulty": "easy",
        "tags": ["likes", "slang"],
        "keywords": ["into", "interested"],
      },
      {
        "question": "Complete: 'I ______ eating vegetables. I never eat them.'",
        "options": ["love", "enjoy", "loathe", "prefer"],
        "answer": 2,
        "explanation":
            "'Loathe' means to hate very strongly, matching 'never eat them'.",
        "difficulty": "medium",
        "tags": ["dislikes", "strong"],
        "keywords": ["loathe", "never"],
      },
      {
        "question":
            "Choose the question that asks about preference between two options:",
        "options": [
          "Do you like tea?",
          "Would you prefer tea or coffee?",
          "When do you drink tea?",
          "Where is tea?",
        ],
        "answer": 1,
        "explanation":
            "'Would you prefer A or B?' directly asks for a choice between two things.",
        "difficulty": "easy",
        "tags": ["preferences", "questions"],
        "keywords": ["prefer", "or"],
      },
      {
        "question":
            "Respond to: 'How do you feel about modern art?' (Say you don't like it)",
        "options": [
          "I'm a huge fan.",
          "It's not really my thing.",
          "I adore it.",
          "I'm passionate about it.",
        ],
        "answer": 1,
        "explanation":
            "'It's not really my thing' is a polite, casual way to say you don't like something.",
        "difficulty": "medium",
        "tags": ["dislikes", "polite responses"],
        "keywords": ["not my thing", "polite dislike"],
      },
      {
        "question": "Complete: 'I have a ______ for classical music.'",
        "options": ["hate", "weakness", "dislike", "passion"],
        "answer": 3,
        "explanation":
            "'Have a passion for' means very strong liking or love for something.",
        "difficulty": "medium",
        "tags": ["likes", "strong expressions"],
        "keywords": ["passion", "strong like"],
      },
      {
        "question": "What does 'I don't care for action movies' mean?",
        "options": [
          "I love action movies.",
          "I don't like action movies much.",
          "I act in movies.",
          "Movies are for kids.",
        ],
        "answer": 1,
        "explanation":
            "'Don't care for' is a polite, soft way to say you don't like something.",
        "difficulty": "medium",
        "tags": ["dislikes", "polite"],
        "keywords": ["don't care for", "soft dislike"],
      },

      // ========== ASKING AND ANSWERING QUESTIONS (17-32) ==========
      {
        "question":
            "What is the correct question to ask about someone's profession?",
        "options": [
          "What do you do?",
          "How do you do?",
          "Where do you go?",
          "When do you work?",
        ],
        "answer": 0,
        "explanation":
            "'What do you do?' is the standard way to ask about someone's job.",
        "difficulty": "easy",
        "tags": ["questions", "profession"],
        "keywords": ["what do you do", "job"],
      },
      {
        "question": "Complete: '______ bag is this?'",
        "options": ["Who", "Whose", "Whom", "Which"],
        "answer": 1,
        "explanation": "'Whose' asks about possession or ownership.",
        "difficulty": "easy",
        "tags": ["questions", "possession"],
        "keywords": ["whose", "possession"],
      },
      {
        "question": "Answer the question: 'How long have you lived here?'",
        "options": [
          "Three years ago.",
          "For three years.",
          "Since three years.",
          "Three years before.",
        ],
        "answer": 1,
        "explanation":
            "'For + duration' is used to answer 'how long' + present perfect.",
        "difficulty": "medium",
        "tags": ["answers", "duration"],
        "keywords": ["how long", "for"],
      },
      {
        "question": "Which question asks about frequency?",
        "options": [
          "How often do you exercise?",
          "How much do you exercise?",
          "How many exercises?",
          "How long exercise?",
        ],
        "answer": 0,
        "explanation": "'How often' asks about the frequency of an action.",
        "difficulty": "easy",
        "tags": ["questions", "frequency"],
        "keywords": ["how often", "frequency"],
      },
      {
        "question": "Complete the question: '______ did you arrive? At 8 PM.'",
        "options": ["Who", "Why", "What time", "How many"],
        "answer": 2,
        "explanation":
            "The answer 'At 8 PM' specifies a time, so the question uses 'What time'.",
        "difficulty": "easy",
        "tags": ["questions", "time"],
        "keywords": ["what time", "arrive"],
      },
      {
        "question": "Respond to: 'How much is this shirt?'",
        "options": ["It's 25.", "It's small.", "It's blue.", "It's cotton."],
        "answer": 0,
        "explanation":
            "'How much' asks about price, so answer with a dollar amount.",
        "difficulty": "easy",
        "tags": ["answers", "price"],
        "keywords": ["how much", "price"],
      },
      {
        "question": "What is the correct indirect question?",
        "options": [
          "Where is the station?",
          "Where the station is?",
          "Do you know where the station is?",
          "You know station?",
        ],
        "answer": 2,
        "explanation":
            "'Do you know where the station is?' has correct indirect question word order (subject before verb after 'where').",
        "difficulty": "medium",
        "tags": ["questions", "indirect"],
        "keywords": ["indirect question", "do you know"],
      },
      {
        "question": "Complete the tag question: 'She can swim, ______?'",
        "options": ["can she", "can't she", "does she", "isn't she"],
        "answer": 1,
        "explanation":
            "Positive statement with 'can' → negative tag 'can't she'.",
        "difficulty": "medium",
        "tags": ["questions", "tag questions"],
        "keywords": ["tag question", "can't she"],
      },
      {
        "question":
            "Choose the correct short answer to 'Does he like coffee?':",
        "options": [
          "Yes, he does.",
          "Yes, he likes.",
          "Yes, he do.",
          "Yes, he is.",
        ],
        "answer": 0,
        "explanation":
            "Short answer uses auxiliary verb: 'Yes, he does' (not 'likes' again).",
        "difficulty": "easy",
        "tags": ["answers", "short answers"],
        "keywords": ["short answer", "does"],
      },
      {
        "question": "What does 'How come?' mean?",
        "options": [
          "For what reason?",
          "In what way?",
          "To what place?",
          "At what time?",
        ],
        "answer": 0,
        "explanation":
            "'How come?' is an informal way to ask 'Why?' or 'For what reason?'",
        "difficulty": "easy",
        "tags": ["questions", "informal"],
        "keywords": ["how come", "why"],
      },
      {
        "question": "Respond to 'What's up?' (informal greeting):",
        "options": [
          "My name is John.",
          "Not much, you?",
          "I am fine thank you.",
          "The sky.",
        ],
        "answer": 1,
        "explanation":
            "'Not much, you?' is a common informal response to 'What's up?'.",
        "difficulty": "easy",
        "tags": ["answers", "informal greetings"],
        "keywords": ["what's up", "not much"],
      },
      {
        "question":
            "Complete: '______ of these is yours? The red one or the blue one?'",
        "options": ["Which", "What", "Who", "Whose"],
        "answer": 0,
        "explanation":
            "'Which' is used when choosing from a limited set of options.",
        "difficulty": "easy",
        "tags": ["questions", "choice"],
        "keywords": ["which", "choice"],
      },
      {
        "question": "Answer: 'Would you like sugar in your tea?' (Say no)",
        "options": [
          "Yes, please.",
          "No, thank you.",
          "Give me sugar.",
          "Why not?",
        ],
        "answer": 1,
        "explanation": "'No, thank you' is the polite refusal.",
        "difficulty": "easy",
        "tags": ["answers", "offers"],
        "keywords": ["no thank you", "refuse"],
      },
      {
        "question": "What is the correct negative question?",
        "options": [
          "Don't you like pizza?",
          "You don't like pizza?",
          "Like you pizza don't?",
          "Do you not pizza like?",
        ],
        "answer": 0,
        "explanation":
            "'Don't you like pizza?' is the standard negative question form (contracted).",
        "difficulty": "medium",
        "tags": ["questions", "negative"],
        "keywords": ["negative question", "don't you"],
      },
      {
        "question": "Complete: 'I didn't see anyone. ______ did you see?'",
        "options": ["Who", "Whom", "What", "Where"],
        "answer": 0,
        "explanation": "'Who' asks about a person (subject).",
        "difficulty": "easy",
        "tags": ["questions", "person"],
        "keywords": ["who", "person"],
      },
      {
        "question":
            "Respond to: 'Could you help me carry this?' (Agree politely)",
        "options": [
          "No.",
          "Of course, I'd be happy to.",
          "Maybe later.",
          "I don't know.",
        ],
        "answer": 1,
        "explanation":
            "'Of course, I'd be happy to' is a polite, willing agreement.",
        "difficulty": "easy",
        "tags": ["answers", "requests"],
        "keywords": ["of course", "happy to"],
      },

      // ========== SENTENCE LINKING AND CONNECTORS (33-48) ==========
      {
        "question":
            "Choose the correct connector to add information: 'I like reading, ______ my sister enjoys painting.'",
        "options": ["but", "or", "and", "so"],
        "answer": 2,
        "explanation": "'And' adds similar or related information.",
        "difficulty": "easy",
        "tags": ["connectors", "addition"],
        "keywords": ["and", "addition"],
      },
      {
        "question": "Complete: 'It was raining, ______ we stayed home.'",
        "options": ["because", "so", "but", "or"],
        "answer": 1,
        "explanation":
            "'So' shows a result or consequence (raining → stayed home).",
        "difficulty": "easy",
        "tags": ["connectors", "result"],
        "keywords": ["so", "result"],
      },
      {
        "question": "What does 'however' show in a sentence?",
        "options": ["Addition", "Contrast", "Reason", "Time"],
        "answer": 1,
        "explanation":
            "'However' is used to show contrast or a different idea.",
        "difficulty": "medium",
        "tags": ["connectors", "contrast"],
        "keywords": ["however", "contrast"],
      },
      {
        "question":
            "Combine: 'She is smart. She is hardworking.' using 'not only... but also'",
        "options": [
          "She not only smart but also hardworking.",
          "She is not only smart but also hardworking.",
          "Not only she is smart but also hardworking.",
          "She is smart not only hardworking but also.",
        ],
        "answer": 1,
        "explanation": "Correct structure: 'She is not only X but also Y'.",
        "difficulty": "hard",
        "tags": ["connectors", "correlative"],
        "keywords": ["not only but also", "combine"],
      },
      {
        "question": "Complete: 'I was late ______ the traffic was heavy.'",
        "options": ["so", "but", "because", "or"],
        "answer": 2,
        "explanation": "'Because' gives the reason for being late.",
        "difficulty": "easy",
        "tags": ["connectors", "reason"],
        "keywords": ["because", "reason"],
      },
      {
        "question":
            "Choose the correct connector for a condition: 'You won't pass the test ______ you study.'",
        "options": ["if", "unless", "so", "because"],
        "answer": 1,
        "explanation":
            "'Unless' means 'if not' — you won't pass if you don't study.",
        "difficulty": "medium",
        "tags": ["connectors", "condition"],
        "keywords": ["unless", "condition"],
      },
      {
        "question": "What is the function of 'therefore'?",
        "options": ["Contrast", "Conclusion/Result", "Addition", "Example"],
        "answer": 1,
        "explanation": "'Therefore' introduces a logical conclusion or result.",
        "difficulty": "medium",
        "tags": ["connectors", "conclusion"],
        "keywords": ["therefore", "conclusion"],
      },
      {
        "question": "Complete: 'He is poor, ______ he is honest.'",
        "options": ["but", "so", "because", "and"],
        "answer": 0,
        "explanation": "'But' shows contrast between being poor and honest.",
        "difficulty": "easy",
        "tags": ["connectors", "contrast"],
        "keywords": ["but", "contrast"],
      },
      {
        "question": "Choose the correct sentence using 'although':",
        "options": [
          "Although he is tired, he continues working.",
          "He continues working although is tired.",
          "Although tired he continues working he.",
          "He although tired continues working.",
        ],
        "answer": 0,
        "explanation":
            "'Although + clause, main clause' is the correct structure.",
        "difficulty": "medium",
        "tags": ["connectors", "concession"],
        "keywords": ["although", "concession"],
      },
      {
        "question": "Complete: 'First, boil the water. ______, add the pasta.'",
        "options": ["Finally", "Then", "However", "Because"],
        "answer": 1,
        "explanation": "'Then' shows sequence or next step in a process.",
        "difficulty": "easy",
        "tags": ["connectors", "sequence"],
        "keywords": ["then", "sequence"],
      },
      {
        "question": "What does 'for example' introduce?",
        "options": [
          "A reason",
          "A contrast",
          "A specific instance",
          "A conclusion",
        ],
        "answer": 2,
        "explanation":
            "'For example' introduces a specific example or illustration.",
        "difficulty": "easy",
        "tags": ["connectors", "examples"],
        "keywords": ["for example", "instance"],
      },
      {
        "question":
            "Combine using 'either...or': 'You can have tea. You can have coffee.'",
        "options": [
          "You can have either tea or coffee.",
          "Either you can have tea or coffee.",
          "You can have tea either or coffee.",
          "You either can have tea or coffee.",
        ],
        "answer": 0,
        "explanation":
            "Correct structure: 'either + option A + or + option B'.",
        "difficulty": "medium",
        "tags": ["connectors", "choices"],
        "keywords": ["either or", "choice"],
      },
      {
        "question":
            "Complete: 'She studied hard; ______, she passed the exam easily.'",
        "options": [
          "however",
          "consequently",
          "nevertheless",
          "on the other hand",
        ],
        "answer": 1,
        "explanation": "'Consequently' shows a result (studied hard → passed).",
        "difficulty": "medium",
        "tags": ["connectors", "result"],
        "keywords": ["consequently", "result"],
      },
      {
        "question":
            "Choose the correct connector for adding a similar idea in academic writing:",
        "options": ["But", "However", "Furthermore", "Although"],
        "answer": 2,
        "explanation":
            "'Furthermore' adds a similar or supporting idea in formal writing.",
        "difficulty": "medium",
        "tags": ["connectors", "formal addition"],
        "keywords": ["furthermore", "addition"],
      },
      {
        "question": "Complete: 'He didn't study. ______, he failed the test.'",
        "options": ["Moreover", "In contrast", "As a result", "For instance"],
        "answer": 2,
        "explanation":
            "'As a result' shows consequence, matching cause-effect.",
        "difficulty": "medium",
        "tags": ["connectors", "cause-effect"],
        "keywords": ["as a result", "consequence"],
      },
      {
        "question": "What is the purpose of 'in addition to'?",
        "options": [
          "To show contrast",
          "To show time",
          "To add information",
          "To show reason",
        ],
        "answer": 2,
        "explanation":
            "'In addition to' introduces extra information or items.",
        "difficulty": "medium",
        "tags": ["connectors", "addition"],
        "keywords": ["in addition to", "add"],
      },

      // ========== FOLLOWING INSTRUCTIONS (49-60) ==========
      {
        "question": "What should you do when you hear 'Line up at the door'?",
        "options": [
          "Run to the door",
          "Form a single-file line at the door",
          "Push everyone",
          "Sit down",
        ],
        "answer": 1,
        "explanation":
            "'Line up' means to form an orderly line, usually single-file.",
        "difficulty": "easy",
        "tags": ["instructions", "classroom"],
        "keywords": ["line up", "order"],
      },
      {
        "question":
            "Complete the instruction: 'Please ______ your homework before Friday.'",
        "options": ["take", "submit", "throw", "ignore"],
        "answer": 1,
        "explanation": "'Submit' means to hand in or turn in your homework.",
        "difficulty": "easy",
        "tags": ["instructions", "homework"],
        "keywords": ["submit", "hand in"],
      },
      {
        "question": "What does 'Cross out the wrong answer' require you to do?",
        "options": [
          "Circle the answer",
          "Draw a line through the wrong answer",
          "Erase the answer",
          "Write the answer again",
        ],
        "answer": 1,
        "explanation":
            "'Cross out' means to draw a line through text to delete or mark it wrong.",
        "difficulty": "easy",
        "tags": ["instructions", "test"],
        "keywords": ["cross out", "delete"],
      },
      {
        "question": "Respond correctly to 'Please hold the door for me':",
        "options": [
          "Let the door close",
          "Keep the door open and wait",
          "Run away",
          "Push the door hard",
        ],
        "answer": 1,
        "explanation":
            "Holding the door means keeping it open for someone behind you.",
        "difficulty": "easy",
        "tags": ["instructions", "politeness"],
        "keywords": ["hold the door", "polite"],
      },
      {
        "question":
            "Complete: '______ carefully to the audio and choose the correct picture.'",
        "options": ["See", "Look", "Listen", "Hear"],
        "answer": 2,
        "explanation":
            "'Listen' is used for paying attention to audio or sound.",
        "difficulty": "easy",
        "tags": ["instructions", "listening"],
        "keywords": ["listen", "audio"],
      },
      {
        "question": "What does 'Skip question 5' mean?",
        "options": [
          "Answer question 5 last",
          "Do not answer question 5",
          "Answer question 5 twice",
          "Erase question 5",
        ],
        "answer": 1,
        "explanation": "'Skip' means to leave out or not do that question.",
        "difficulty": "easy",
        "tags": ["instructions", "test"],
        "keywords": ["skip", "leave out"],
      },
      {
        "question":
            "You hear 'Raise your hand if you know the answer.' What do you do?",
        "options": [
          "Shout the answer",
          "Stand up",
          "Lift your hand in the air",
          "Look at the teacher",
        ],
        "answer": 2,
        "explanation":
            "'Raise your hand' means to lift your hand to signal you want to speak.",
        "difficulty": "easy",
        "tags": ["instructions", "classroom"],
        "keywords": ["raise hand", "signal"],
      },
      {
        "question":
            "Complete the instruction: '______ the form with your personal details.'",
        "options": ["Fill in", "Fill out", "Both A and B", "Make"],
        "answer": 2,
        "explanation":
            "'Fill in' and 'fill out' are both correct for completing a form.",
        "difficulty": "easy",
        "tags": ["instructions", "forms"],
        "keywords": ["fill in", "fill out"],
      },
      {
        "question": "What does 'Disregard the previous email' mean?",
        "options": ["Read it carefully", "Print it", "Ignore it", "Forward it"],
        "answer": 2,
        "explanation":
            "'Disregard' means to ignore or pay no attention to something.",
        "difficulty": "medium",
        "tags": ["instructions", "professional"],
        "keywords": ["disregard", "ignore"],
      },
      {
        "question": "Respond to: 'Please proceed to Gate B12.'",
        "options": ["Go to Gate B12", "Stay here", "Go home", "Call someone"],
        "answer": 0,
        "explanation": "'Proceed to' means to go or move towards a location.",
        "difficulty": "easy",
        "tags": ["instructions", "directions"],
        "keywords": ["proceed to", "go to"],
      },
      {
        "question": "Complete: '______ the circle. Do not color inside it.'",
        "options": ["Color", "Shade", "Trace", "Fill"],
        "answer": 2,
        "explanation":
            "'Trace' means to draw around the outline without filling.",
        "difficulty": "medium",
        "tags": ["instructions", "drawing"],
        "keywords": ["trace", "outline"],
      },
      {
        "question":
            "What should you do if an instruction says 'Pause the video'?",
        "options": [
          "Stop the video temporarily",
          "Stop permanently",
          "Play faster",
          "Turn off sound",
        ],
        "answer": 0,
        "explanation": "'Pause' means temporary stop, not permanent.",
        "difficulty": "easy",
        "tags": ["instructions", "media"],
        "keywords": ["pause", "temporary stop"],
      },

      // ========== POLITE CONVERSATION AND REQUESTING HELP (61-72) ==========
      {
        "question":
            "Which is the most polite way to ask a stranger for the time?",
        "options": [
          "Time?",
          "What time is it?",
          "Excuse me, could you tell me the time, please?",
          "Hey, time?",
        ],
        "answer": 2,
        "explanation":
            "This includes 'excuse me', 'could you', and 'please' — all polite markers.",
        "difficulty": "easy",
        "tags": ["polite", "strangers"],
        "keywords": ["excuse me", "could you", "please"],
      },
      {
        "question":
            "Complete: 'I'm sorry to ______ you, but do you have a moment?'",
        "options": ["help", "bother", "love", "ignore"],
        "answer": 1,
        "explanation":
            "'Bother' is used to politely acknowledge inconvenience.",
        "difficulty": "medium",
        "tags": ["polite", "apology"],
        "keywords": ["sorry to bother", "polite"],
      },
      {
        "question": "How do you politely interrupt a conversation?",
        "options": [
          "Shout 'Hey!'",
          "Tap hard on shoulder",
          "Say 'Pardon me for interrupting'",
          "Walk away",
        ],
        "answer": 2,
        "explanation":
            "'Pardon me for interrupting' is a polite way to break into a conversation.",
        "difficulty": "easy",
        "tags": ["polite", "interruption"],
        "keywords": ["pardon me", "interrupt"],
      },
      {
        "question": "Respond to 'Thank you for your help' politely:",
        "options": [
          "No problem.",
          "You're welcome.",
          "Don't mention it.",
          "All of these",
        ],
        "answer": 3,
        "explanation": "All three are polite responses to thanks.",
        "difficulty": "easy",
        "tags": ["polite", "responses to thanks"],
        "keywords": ["you're welcome", "no problem"],
      },
      {
        "question":
            "Complete: 'Would you mind ______ the window? It's hot in here.'",
        "options": ["open", "to open", "opening", "opened"],
        "answer": 2,
        "explanation": "After 'Would you mind', use the -ing form: 'opening'.",
        "difficulty": "medium",
        "tags": ["polite", "requests"],
        "keywords": ["would you mind", "ing form"],
      },
      {
        "question": "What does 'I apologize for the inconvenience' mean?",
        "options": [
          "I am happy",
          "I am sorry for the trouble",
          "Please help me",
          "Thank you",
        ],
        "answer": 1,
        "explanation":
            "This is a formal apology for causing trouble or difficulty.",
        "difficulty": "easy",
        "tags": ["polite", "apology"],
        "keywords": ["apologize", "inconvenience"],
      },
      {
        "question": "Choose the polite way to say you don't understand:",
        "options": [
          "What?",
          "Huh?",
          "I'm sorry, I don't follow.",
          "Say again.",
        ],
        "answer": 2,
        "explanation": "'I'm sorry, I don't follow' is polite and clear.",
        "difficulty": "easy",
        "tags": ["polite", "clarification"],
        "keywords": ["don't follow", "polite"],
      },
      {
        "question": "Complete: 'Could you ______ me a hand with this box?'",
        "options": ["give", "take", "lend", "borrow"],
        "answer": 0,
        "explanation": "'Give me a hand' is an idiom meaning 'help me'.",
        "difficulty": "easy",
        "tags": ["requests", "idioms"],
        "keywords": ["give a hand", "help"],
      },
      {
        "question": "How do you politely decline a dinner invitation?",
        "options": [
          "No.",
          "I don't want to.",
          "Thank you, but I have other plans.",
          "Maybe never.",
        ],
        "answer": 2,
        "explanation":
            "This politely refuses while giving a (possibly neutral) reason.",
        "difficulty": "easy",
        "tags": ["polite", "refusal"],
        "keywords": ["thank you but", "other plans"],
      },
      {
        "question":
            "What should you say if you bump into someone accidentally?",
        "options": [
          "Watch out!",
          "Excuse me, I'm so sorry.",
          "Move!",
          "Not my fault.",
        ],
        "answer": 1,
        "explanation": "Apologizing immediately is the polite response.",
        "difficulty": "easy",
        "tags": ["polite", "apology"],
        "keywords": ["sorry", "accident"],
      },
      {
        "question": "Complete: '______, could you please speak more slowly?'",
        "options": ["Hey", "Listen", "I'm sorry", "Shut up"],
        "answer": 2,
        "explanation":
            "'I'm sorry' softens the request when asking for repetition/slower speech.",
        "difficulty": "easy",
        "tags": ["polite", "requests"],
        "keywords": ["I'm sorry", "please"],
      },
      {
        "question":
            "What is the polite way to ask someone to repeat what they said?",
        "options": [
          "Say it again.",
          "What did you say?",
          "Pardon me?",
          "Repeat.",
        ],
        "answer": 2,
        "explanation":
            "'Pardon me?' is the most polite and common way to ask for repetition.",
        "difficulty": "easy",
        "tags": ["polite", "repetition"],
        "keywords": ["pardon me", "repeat"],
      },
    ],
    "Practical Conversation": [
      // ========== DESCRIBING PEOPLE, PLACES AND THINGS (1-14) ==========
      {
        "question":
            "Which adjective describes someone who is happy to wait without getting angry?",
        "options": ["Impatient", "Patient", "Angry", "Sad"],
        "answer": 1,
        "explanation":
            "'Patient' means able to wait calmly without getting upset.",
        "difficulty": "easy",
        "tags": ["describing people", "personality"],
        "keywords": ["patient", "wait"],
      },
      {
        "question":
            "Complete: 'The Eiffel Tower is very ______. It is over 300 meters tall.'",
        "options": ["short", "tall", "wide", "small"],
        "answer": 1,
        "explanation":
            "'Tall' describes great height, especially for structures.",
        "difficulty": "easy",
        "tags": ["describing places", "size"],
        "keywords": ["tall", "height"],
      },
      {
        "question": "What does 'cozy' mean when describing a room?",
        "options": [
          "Very large and empty",
          "Cold and uncomfortable",
          "Warm, comfortable and small",
          "Dark and scary",
        ],
        "answer": 2,
        "explanation":
            "'Cozy' describes a warm, comfortable, and inviting small space.",
        "difficulty": "easy",
        "tags": ["describing places", "atmosphere"],
        "keywords": ["cozy", "comfortable"],
      },
      {
        "question":
            "Choose the correct order of adjectives: 'She has ______ hair.'",
        "options": [
          "long beautiful black",
          "beautiful long black",
          "black beautiful long",
          "long black beautiful",
        ],
        "answer": 1,
        "explanation":
            "Correct adjective order: opinion (beautiful) → size (long) → color (black).",
        "difficulty": "medium",
        "tags": ["describing people", "adjective order"],
        "keywords": ["adjective order", "opinion", "size", "color"],
      },
      {
        "question": "Which word describes a place with many people?",
        "options": ["Empty", "Crowded", "Quiet", "Deserted"],
        "answer": 1,
        "explanation": "'Crowded' means full of people.",
        "difficulty": "easy",
        "tags": ["describing places", "people"],
        "keywords": ["crowded", "many people"],
      },
      {
        "question": "Complete: 'The glass is ______. I can see through it.'",
        "options": ["opaque", "translucent", "transparent", "solid"],
        "answer": 2,
        "explanation":
            "'Transparent' means light passes through so you can see clearly.",
        "difficulty": "medium",
        "tags": ["describing things", "properties"],
        "keywords": ["transparent", "see through"],
      },
      {
        "question": "Describe someone who always tells the truth:",
        "options": ["Honest", "Lazy", "Funny", "Serious"],
        "answer": 0,
        "explanation": "'Honest' means truthful and not deceptive.",
        "difficulty": "easy",
        "tags": ["describing people", "character"],
        "keywords": ["honest", "truth"],
      },
      {
        "question": "What does 'picturesque' mean for a village?",
        "options": [
          "Ugly and dirty",
          "Very modern",
          "Visually attractive like a painting",
          "Very noisy",
        ],
        "answer": 2,
        "explanation":
            "'Picturesque' means visually charming or beautiful, like a picture.",
        "difficulty": "medium",
        "tags": ["describing places", "beauty"],
        "keywords": ["picturesque", "beautiful"],
      },
      {
        "question": "Choose the correct sentence:",
        "options": [
          "He is a man tall.",
          "He is tall a man.",
          "He is a tall man.",
          "He tall is a man.",
        ],
        "answer": 2,
        "explanation":
            "Correct order: 'a/an + adjective + noun' — 'a tall man'.",
        "difficulty": "easy",
        "tags": ["describing people", "word order"],
        "keywords": ["adjective order", "a tall man"],
      },
      {
        "question": "What does 'spacious' describe?",
        "options": [
          "A very small room",
          "A room with a lot of space",
          "A dirty room",
          "A dark room",
        ],
        "answer": 1,
        "explanation": "'Spacious' means having plenty of room or space.",
        "difficulty": "easy",
        "tags": ["describing places", "size"],
        "keywords": ["spacious", "large space"],
      },
      {
        "question":
            "Complete: 'She has a ______ personality. She always makes people laugh.'",
        "options": ["serious", "quiet", "humorous", "shy"],
        "answer": 2,
        "explanation": "'Humorous' means funny or able to make others laugh.",
        "difficulty": "easy",
        "tags": ["describing people", "personality"],
        "keywords": ["humorous", "laugh"],
      },
      {
        "question": "Which word describes something that costs a lot of money?",
        "options": ["Cheap", "Affordable", "Expensive", "Free"],
        "answer": 2,
        "explanation": "'Expensive' means high-priced or costing much money.",
        "difficulty": "easy",
        "tags": ["describing things", "price"],
        "keywords": ["expensive", "cost"],
      },
      {
        "question": "Describe a 'bustling' city:",
        "options": [
          "Empty and quiet",
          "Full of busy activity and noise",
          "Very old and broken",
          "Underwater",
        ],
        "answer": 1,
        "explanation": "'Bustling' means full of energetic and noisy activity.",
        "difficulty": "medium",
        "tags": ["describing places", "activity"],
        "keywords": ["bustling", "busy"],
      },
      {
        "question":
            "Complete: 'The antique table is very ______. It was made in 1750.'",
        "options": ["new", "modern", "old", "young"],
        "answer": 2,
        "explanation": "'Old' describes something that existed long ago.",
        "difficulty": "easy",
        "tags": ["describing things", "age"],
        "keywords": ["old", "antique"],
      },

      // ========== GIVING DIRECTIONS (15-30) ==========
      {
        "question": "What does 'Go straight ahead' mean?",
        "options": [
          "Turn left",
          "Turn right",
          "Continue forward without turning",
          "Go back",
        ],
        "answer": 2,
        "explanation":
            "'Go straight ahead' means continue moving forward in the same direction.",
        "difficulty": "easy",
        "tags": ["directions", "basic"],
        "keywords": ["straight ahead", "forward"],
      },
      {
        "question": "Complete: 'Turn ______ at the traffic lights.'",
        "options": ["on", "in", "left", "to"],
        "answer": 2,
        "explanation":
            "'Turn left' or 'turn right' are the correct directional phrases.",
        "difficulty": "easy",
        "tags": ["directions", "turns"],
        "keywords": ["turn left", "traffic lights"],
      },
      {
        "question": "What does 'It's on the corner of Main and 5th' mean?",
        "options": [
          "It is inside a building",
          "It is where two streets meet",
          "It is far away",
          "It is underground",
        ],
        "answer": 1,
        "explanation": "A corner is the intersection point of two streets.",
        "difficulty": "easy",
        "tags": ["directions", "locations"],
        "keywords": ["corner", "intersection"],
      },
      {
        "question":
            "Choose the correct direction to a place behind the post office:",
        "options": [
          "It's opposite the post office.",
          "It's behind the post office.",
          "It's in front of the post office.",
          "It's next to the post office.",
        ],
        "answer": 1,
        "explanation": "'Behind' means at the back of something.",
        "difficulty": "easy",
        "tags": ["directions", "prepositions"],
        "keywords": ["behind", "back"],
      },
      {
        "question":
            "Complete: 'Walk ______ the bridge and you will see the museum on your left.'",
        "options": ["over", "under", "through", "across"],
        "answer": 0,
        "explanation": "'Walk over the bridge' means cross it by going on top.",
        "difficulty": "easy",
        "tags": ["directions", "prepositions"],
        "keywords": ["over", "bridge"],
      },
      {
        "question": "What does 'take the second turning on your right' mean?",
        "options": [
          "Turn right at the first street",
          "Turn right at the second street",
          "Turn left at the second street",
          "Go straight",
        ],
        "answer": 1,
        "explanation":
            "You count the turnings (streets/roads) and take the second one to the right.",
        "difficulty": "medium",
        "tags": ["directions", "turning"],
        "keywords": ["second turning", "right"],
      },
      {
        "question": "Respond to: 'How do I get to the library?'",
        "options": [
          "It's blue.",
          "Go straight, then turn left.",
          "The library is big.",
          "I don't read books.",
        ],
        "answer": 1,
        "explanation": "This gives actual step-by-step directions.",
        "difficulty": "easy",
        "tags": ["directions", "responses"],
        "keywords": ["get to", "directions"],
      },
      {
        "question": "What does 'It's across from the bank' mean?",
        "options": [
          "It is next to the bank",
          "It is on the opposite side of the street from the bank",
          "It is inside the bank",
          "It is behind the bank",
        ],
        "answer": 1,
        "explanation":
            "'Across from' means on the other side of the road or street.",
        "difficulty": "easy",
        "tags": ["directions", "prepositions"],
        "keywords": ["across from", "opposite"],
      },
      {
        "question":
            "Complete: 'The hotel is ______ the church and the supermarket.'",
        "options": ["between", "among", "inside", "behind"],
        "answer": 0,
        "explanation":
            "'Between' is used when something has two things on either side.",
        "difficulty": "easy",
        "tags": ["directions", "prepositions"],
        "keywords": ["between", "two"],
      },
      {
        "question": "What does 'It's a 5-minute walk from here' mean?",
        "options": [
          "You need a car",
          "You can walk there in 5 minutes",
          "It takes 5 hours",
          "It is 5 kilometers",
        ],
        "answer": 1,
        "explanation": "This indicates distance in terms of walking time.",
        "difficulty": "easy",
        "tags": ["directions", "distance"],
        "keywords": ["walk", "minutes"],
      },
      {
        "question": "Choose the correct way to say something is not far:",
        "options": [
          "It's far away.",
          "It's close by.",
          "It's across the city.",
          "It's in another country.",
        ],
        "answer": 1,
        "explanation": "'Close by' or 'near' means short distance.",
        "difficulty": "easy",
        "tags": ["directions", "distance"],
        "keywords": ["close by", "near"],
      },
      {
        "question": "Complete: 'Go ______ the tunnel and then turn right.'",
        "options": ["over", "through", "around", "on"],
        "answer": 1,
        "explanation":
            "'Go through' means to enter and exit from the other side of a tunnel.",
        "difficulty": "easy",
        "tags": ["directions", "prepositions"],
        "keywords": ["through", "tunnel"],
      },
      {
        "question": "What is a 'landmark' when giving directions?",
        "options": [
          "A map",
          "An easy-to-see building or feature",
          "A secret code",
          "A type of car",
        ],
        "answer": 1,
        "explanation":
            "Landmarks are recognizable features (like statues, tall buildings) used as reference points.",
        "difficulty": "easy",
        "tags": ["directions", "landmarks"],
        "keywords": ["landmark", "reference"],
      },
      {
        "question": "How do you ask for directions politely?",
        "options": [
          "Where is it?",
          "Tell me the way.",
          "Excuse me, could you tell me how to get to the station?",
          "Directions now.",
        ],
        "answer": 2,
        "explanation":
            "This includes 'excuse me', 'could you', and a full polite question.",
        "difficulty": "easy",
        "tags": ["directions", "polite"],
        "keywords": ["excuse me", "could you"],
      },
      {
        "question": "Complete: 'Walk ______ this road for two blocks.'",
        "options": ["along", "in", "at", "to"],
        "answer": 0,
        "explanation": "'Walk along' means to follow the length of the road.",
        "difficulty": "easy",
        "tags": ["directions", "prepositions"],
        "keywords": ["along", "road"],
      },
      {
        "question":
            "What does 'You can't miss it' mean when giving directions?",
        "options": [
          "It is hidden",
          "It is very easy to see or find",
          "You should not look at it",
          "It moves",
        ],
        "answer": 1,
        "explanation":
            "'You can't miss it' means the place is very obvious or easy to locate.",
        "difficulty": "easy",
        "tags": ["directions", "phrases"],
        "keywords": ["can't miss", "obvious"],
      },

      // ========== FOOD AND MEAL CONVERSATIONS (31-45) ==========
      {
        "question": "What do you say to order food at a restaurant?",
        "options": [
          "Give me food.",
          "I want eat.",
          "I'd like the chicken, please.",
          "Food now.",
        ],
        "answer": 2,
        "explanation":
            "'I'd like' (I would like) is a polite and common way to order.",
        "difficulty": "easy",
        "tags": ["food", "ordering"],
        "keywords": ["I'd like", "order"],
      },
      {
        "question":
            "Complete: 'Could I have the ______, please?' (List of dishes with prices)",
        "options": ["book", "newspaper", "menu", "recipe"],
        "answer": 2,
        "explanation":
            "The 'menu' is the list of food options at a restaurant.",
        "difficulty": "easy",
        "tags": ["food", "restaurant"],
        "keywords": ["menu", "restaurant"],
      },
      {
        "question": "What does 'appetizer' mean?",
        "options": [
          "Main dish",
          "Drink",
          "Small dish before the main meal",
          "Dessert",
        ],
        "answer": 2,
        "explanation":
            "An appetizer is a small dish served before the main course.",
        "difficulty": "easy",
        "tags": ["food", "meal parts"],
        "keywords": ["appetizer", "starter"],
      },
      {
        "question": "How do you ask for the check/bill?",
        "options": [
          "How much?",
          "Check please?",
          "Could I have the bill, please?",
          "Money now.",
        ],
        "answer": 2,
        "explanation":
            "'Could I have the bill, please?' is the standard polite request.",
        "difficulty": "easy",
        "tags": ["food", "payment"],
        "keywords": ["bill", "check"],
      },
      {
        "question":
            "Complete: 'This soup is too ______. I can't eat it. It has no salt.'",
        "options": ["salty", "spicy", "bland", "sweet"],
        "answer": 2,
        "explanation":
            "'Bland' means lacking flavor, often because of no salt or seasoning.",
        "difficulty": "easy",
        "tags": ["food", "taste"],
        "keywords": ["bland", "no salt"],
      },
      {
        "question": "What does 'I'm full' mean after a meal?",
        "options": [
          "I am still hungry",
          "I have eaten enough",
          "The plate is full",
          "I want dessert",
        ],
        "answer": 1,
        "explanation":
            "'I'm full' means you have eaten enough and cannot eat more.",
        "difficulty": "easy",
        "tags": ["food", "satisfaction"],
        "keywords": ["full", "enough"],
      },
      {
        "question": "Choose the correct server question to start an order:",
        "options": [
          "What do you want?",
          "Are you ready to order?",
          "Tell me now.",
          "Food?",
        ],
        "answer": 1,
        "explanation":
            "'Are you ready to order?' is the standard, polite server question.",
        "difficulty": "easy",
        "tags": ["food", "restaurant"],
        "keywords": ["ready to order", "server"],
      },
      {
        "question":
            "Complete: 'I'd like my steak ______.' (cooked only on the outside, red inside)",
        "options": ["well done", "rare", "medium", "burnt"],
        "answer": 1,
        "explanation":
            "'Rare' means cooked very little, red inside. 'Well done' is fully cooked.",
        "difficulty": "medium",
        "tags": ["food", "cooking"],
        "keywords": ["rare", "steak"],
      },
      {
        "question": "What do you say to compliment the food?",
        "options": [
          "This is terrible.",
          "This is delicious!",
          "I don't like it.",
          "Too expensive.",
        ],
        "answer": 1,
        "explanation": "'This is delicious!' expresses enjoyment of the food.",
        "difficulty": "easy",
        "tags": ["food", "compliments"],
        "keywords": ["delicious", "compliment"],
      },
      {
        "question": "What does 'I'm allergic to nuts' mean?",
        "options": [
          "I love nuts",
          "I hate nuts",
          "Nuts make me sick/are dangerous for me",
          "I cook nuts",
        ],
        "answer": 2,
        "explanation": "An allergy means your body reacts badly to that food.",
        "difficulty": "easy",
        "tags": ["food", "allergies"],
        "keywords": ["allergic", "nuts"],
      },
      {
        "question": "Complete: 'Can you ______ me the salt, please?'",
        "options": ["take", "give", "pass", "bring"],
        "answer": 2,
        "explanation":
            "'Pass the salt' is the common phrase for asking someone to hand it to you.",
        "difficulty": "easy",
        "tags": ["food", "table manners"],
        "keywords": ["pass the salt", "request"],
      },
      {
        "question": "Choose the correct question for dietary restrictions:",
        "options": [
          "Is this spicy?",
          "Does this dish contain dairy?",
          "How much?",
          "Where is it from?",
        ],
        "answer": 1,
        "explanation":
            "Asking about dairy is a dietary restriction/allergy question.",
        "difficulty": "easy",
        "tags": ["food", "diet"],
        "keywords": ["contain", "dairy"],
      },
      {
        "question": "What is 'street food'?",
        "options": [
          "Food eaten in a fine dining restaurant",
          "Food sold on the street from carts or stalls",
          "Frozen food",
          "Food delivered to home",
        ],
        "answer": 1,
        "explanation":
            "Street food is prepared and sold by vendors on streets or in markets.",
        "difficulty": "easy",
        "tags": ["food", "types"],
        "keywords": ["street food", "vendors"],
      },
      {
        "question":
            "Complete: 'For dessert, I'll have the ______.' (frozen sweet food)",
        "options": ["salad", "soup", "ice cream", "bread"],
        "answer": 2,
        "explanation": "Ice cream is a common frozen dessert.",
        "difficulty": "easy",
        "tags": ["food", "dessert"],
        "keywords": ["dessert", "ice cream"],
      },
      {
        "question": "What does 'beverage' mean?",
        "options": ["Food", "Drink", "Napkin", "Plate"],
        "answer": 1,
        "explanation":
            "A 'beverage' is any drink, like water, soda, juice, or alcohol.",
        "difficulty": "easy",
        "tags": ["food", "drinks"],
        "keywords": ["beverage", "drink"],
      },

      // ========== SHOPPING CONVERSATIONS (46-58) ==========
      {
        "question": "What do you say to ask for the price of an item?",
        "options": ["How many?", "How much is this?", "What price?", "Cost?"],
        "answer": 1,
        "explanation":
            "'How much is this?' is the standard question for price.",
        "difficulty": "easy",
        "tags": ["shopping", "price"],
        "keywords": ["how much", "price"],
      },
      {
        "question": "Complete: 'Can I ______ this shirt in a larger size?'",
        "options": ["try on", "try out", "try with", "try for"],
        "answer": 0,
        "explanation":
            "'Try on' means to put on clothes to check fit and appearance.",
        "difficulty": "easy",
        "tags": ["shopping", "clothes"],
        "keywords": ["try on", "larger size"],
      },
      {
        "question": "What does 'It's on sale' mean?",
        "options": [
          "It is expensive",
          "It is not available",
          "It is being sold at a lower price than usual",
          "It is broken",
        ],
        "answer": 2,
        "explanation": "'On sale' means reduced price, discount period.",
        "difficulty": "easy",
        "tags": ["shopping", "discounts"],
        "keywords": ["on sale", "lower price"],
      },
      {
        "question": "How do you ask for a discount?",
        "options": [
          "Make it cheap.",
          "Can you give me a discount?",
          "Less money.",
          "Free please?",
        ],
        "answer": 1,
        "explanation":
            "'Can you give me a discount?' is a direct and polite request.",
        "difficulty": "easy",
        "tags": ["shopping", "bargaining"],
        "keywords": ["discount", "bargain"],
      },
      {
        "question":
            "Choose the correct response when an item is too expensive:",
        "options": [
          "I'll take it.",
          "That's too expensive for me. Do you have something cheaper?",
          "It's perfect.",
          "I love the color.",
        ],
        "answer": 1,
        "explanation":
            "This politely states the issue and asks for an alternative.",
        "difficulty": "easy",
        "tags": ["shopping", "budget"],
        "keywords": ["too expensive", "cheaper"],
      },
      {
        "question":
            "Complete: 'I'd like to ______ this sweater. It doesn't fit.'",
        "options": ["buy", "keep", "return", "hide"],
        "answer": 2,
        "explanation":
            "'Return' means to take back an item for a refund or exchange.",
        "difficulty": "easy",
        "tags": ["shopping", "returns"],
        "keywords": ["return", "doesn't fit"],
      },
      {
        "question": "What does 'Do you have this in another color?' ask?",
        "options": ["Size", "Price", "Color variation", "Material"],
        "answer": 2,
        "explanation":
            "This asks if the same item exists in a different color.",
        "difficulty": "easy",
        "tags": ["shopping", "color"],
        "keywords": ["another color", "variation"],
      },
      {
        "question": "What is a 'receipt'?",
        "options": [
          "The money you pay",
          "A paper proving you paid",
          "The bag for items",
          "The item itself",
        ],
        "answer": 1,
        "explanation": "A receipt is a document showing proof of purchase.",
        "difficulty": "easy",
        "tags": ["shopping", "payment"],
        "keywords": ["receipt", "proof"],
      },
      {
        "question":
            "Complete: 'I'm just ______, thank you.' (Looking without buying)",
        "options": ["buying", "stealing", "browsing", "shouting"],
        "answer": 2,
        "explanation":
            "'Browsing' or 'just looking' means you are not ready to buy yet.",
        "difficulty": "easy",
        "tags": ["shopping", "browsing"],
        "keywords": ["browsing", "just looking"],
      },
      {
        "question": "How do you ask about the return policy?",
        "options": [
          "Can I return this if it doesn't fit?",
          "What is the price?",
          "Is it new?",
          "Where is it made?",
        ],
        "answer": 0,
        "explanation": "This directly asks about the store's return rules.",
        "difficulty": "easy",
        "tags": ["shopping", "returns"],
        "keywords": ["return", "policy"],
      },
      {
        "question": "What does 'cash back' mean at a store?",
        "options": [
          "Money returned for defective goods",
          "Withdrawing extra cash when paying by debit card",
          "Getting a discount",
          "Paying with coins",
        ],
        "answer": 1,
        "explanation":
            "Cash back is when you withdraw money from your bank account at the checkout.",
        "difficulty": "medium",
        "tags": ["shopping", "payment"],
        "keywords": ["cash back", "withdraw"],
      },
      {
        "question":
            "Complete: 'Does this come with a ______?' (Promise to repair or replace)",
        "options": ["receipt", "warranty", "bag", "tag"],
        "answer": 1,
        "explanation":
            "A warranty is a guarantee that the product will be repaired or replaced.",
        "difficulty": "medium",
        "tags": ["shopping", "guarantee"],
        "keywords": ["warranty", "guarantee"],
      },
      {
        "question": "What do you say to pay with plastic?",
        "options": [
          "I'll pay with card.",
          "I'll give paper.",
          "Cash please.",
          "Check please.",
        ],
        "answer": 0,
        "explanation":
            "'I'll pay with card' means credit or debit card (plastic).",
        "difficulty": "easy",
        "tags": ["shopping", "payment"],
        "keywords": ["pay with card", "credit card"],
      },

      // ========== HEALTH-RELATED COMMUNICATION (59-70) ==========
      {
        "question": "How do you tell a doctor about a pain in your head?",
        "options": [
          "My leg hurts.",
          "I have a headache.",
          "My stomach aches.",
          "I feel cold.",
        ],
        "answer": 1,
        "explanation": "'Headache' is the specific word for head pain.",
        "difficulty": "easy",
        "tags": ["health", "symptoms"],
        "keywords": ["headache", "head pain"],
      },
      {
        "question":
            "Complete: 'I think I have a ______. I'm sneezing and coughing.'",
        "options": ["broken leg", "cold", "headache", "toothache"],
        "answer": 1,
        "explanation": "Sneezing and coughing are common cold symptoms.",
        "difficulty": "easy",
        "tags": ["health", "symptoms"],
        "keywords": ["cold", "sneezing"],
      },
      {
        "question": "What do you say to make an appointment with a doctor?",
        "options": [
          "I need medicine.",
          "I would like to schedule an appointment, please.",
          "Doctor here.",
          "Help me now.",
        ],
        "answer": 1,
        "explanation":
            "This politely requests to book a time to see the doctor.",
        "difficulty": "easy",
        "tags": ["health", "appointments"],
        "keywords": ["schedule", "appointment"],
      },
      {
        "question": "Choose the correct way to describe a fever:",
        "options": [
          "I have a high body temperature.",
          "My bones hurt.",
          "I can't sleep.",
          "My eyes are red.",
        ],
        "answer": 0,
        "explanation":
            "Fever is an elevated body temperature, usually above 38°C/100.4°F.",
        "difficulty": "easy",
        "tags": ["health", "symptoms"],
        "keywords": ["fever", "temperature"],
      },
      {
        "question":
            "Complete: 'I've been feeling ______ for two days.' (Wanting to throw up)",
        "options": ["happy", "energetic", "nauseous", "strong"],
        "answer": 2,
        "explanation":
            "'Nauseous' means feeling sick to your stomach, like you might vomit.",
        "difficulty": "medium",
        "tags": ["health", "symptoms"],
        "keywords": ["nauseous", "sick"],
      },
      {
        "question": "What does 'Do you have any allergies?' ask?",
        "options": [
          "Your food preferences",
          "Things that make you sick",
          "Your address",
          "Your age",
        ],
        "answer": 1,
        "explanation":
            "Allergies are substances or conditions that cause an adverse reaction.",
        "difficulty": "easy",
        "tags": ["health", "allergies"],
        "keywords": ["allergies", "reaction"],
      },
      {
        "question": "How do you ask a pharmacist for medicine?",
        "options": [
          "Give me pills.",
          "Can you recommend something for a cough?",
          "Medicine now.",
          "I need drugs.",
        ],
        "answer": 1,
        "explanation":
            "This politely asks for a recommendation based on your symptom.",
        "difficulty": "easy",
        "tags": ["health", "pharmacy"],
        "keywords": ["recommend", "cough"],
      },
      {
        "question":
            "Complete: 'I have a ______ appointment at 10 AM.' (Tooth doctor)",
        "options": ["cardiologist", "dentist", "eye doctor", "psychologist"],
        "answer": 1,
        "explanation": "A dentist specializes in teeth and oral health.",
        "difficulty": "easy",
        "tags": ["health", "specialists"],
        "keywords": ["dentist", "teeth"],
      },
      {
        "question": "What does 'prescription' mean?",
        "options": [
          "A type of medicine",
          "Doctor's written order for medicine",
          "A hospital room",
          "A medical test",
        ],
        "answer": 1,
        "explanation":
            "A prescription is a written instruction from a doctor to get specific medication.",
        "difficulty": "easy",
        "tags": ["health", "medicine"],
        "keywords": ["prescription", "order"],
      },
      {
        "question":
            "How do you describe feeling unwell without a specific symptom?",
        "options": [
          "I am perfect.",
          "I feel under the weather.",
          "I am strong.",
          "I am ready to run.",
        ],
        "answer": 1,
        "explanation":
            "'Under the weather' is an idiom meaning slightly ill or unwell.",
        "difficulty": "medium",
        "tags": ["health", "idioms"],
        "keywords": ["under the weather", "unwell"],
      },
      {
        "question":
            "Complete: 'I ______ my arm while playing football.' (Past tense of hurt/injure)",
        "options": ["hurted", "hurt", "hurtle", "hurting"],
        "answer": 1,
        "explanation": "'Hurt' is the same in present and past tense.",
        "difficulty": "easy",
        "tags": ["health", "injuries"],
        "keywords": ["hurt", "past tense"],
      },
      {
        "question": "What do you say at a pharmacy if you have a prescription?",
        "options": [
          "I need a doctor.",
          "I'd like to have this prescription filled, please.",
          "Where is the hospital?",
          "Give me vitamins.",
        ],
        "answer": 1,
        "explanation":
            "'Have this prescription filled' means to get the medicine from the pharmacist.",
        "difficulty": "medium",
        "tags": ["health", "pharmacy"],
        "keywords": ["prescription filled", "pharmacy"],
      },

      // ========== WEATHER AND SEASONS DISCUSSIONS (71-80) ==========
      {
        "question": "How do you ask about the weather?",
        "options": [
          "What time is it?",
          "What's the weather like today?",
          "Where is the sun?",
          "How much weather?",
        ],
        "answer": 1,
        "explanation":
            "'What's the weather like?' is the standard question for weather conditions.",
        "difficulty": "easy",
        "tags": ["weather", "questions"],
        "keywords": ["weather like", "today"],
      },
      {
        "question": "Complete: 'It's ______ outside. Take an umbrella.'",
        "options": ["sunny", "cloudy", "rainy", "snowy"],
        "answer": 2,
        "explanation": "You need an umbrella when it's raining.",
        "difficulty": "easy",
        "tags": ["weather", "conditions"],
        "keywords": ["rainy", "umbrella"],
      },
      {
        "question": "What does 'It's freezing' mean?",
        "options": ["Very hot", "Very cold (below 0°C/32°F)", "Windy", "Foggy"],
        "answer": 1,
        "explanation":
            "'Freezing' means extremely cold, at or below the freezing point of water.",
        "difficulty": "easy",
        "tags": ["weather", "temperature"],
        "keywords": ["freezing", "cold"],
      },
      {
        "question": "Choose the correct season for 'leaves fall from trees':",
        "options": ["Spring", "Summer", "Autumn/Fall", "Winter"],
        "answer": 2,
        "explanation":
            "Autumn (Fall) is when leaves change color and fall from deciduous trees.",
        "difficulty": "easy",
        "tags": ["seasons", "autumn"],
        "keywords": ["autumn", "falling leaves"],
      },
      {
        "question": "Complete: 'The temperature is 30°C. It's very ______.'",
        "options": ["cold", "cool", "hot", "freezing"],
        "answer": 2,
        "explanation": "30°C (86°F) is considered hot weather.",
        "difficulty": "easy",
        "tags": ["weather", "temperature"],
        "keywords": ["hot", "30 degrees"],
      },
      {
        "question": "What does 'It's humid' mean?",
        "options": [
          "There is a lot of moisture in the air",
          "There is strong wind",
          "It is snowing",
          "It is very dry",
        ],
        "answer": 0,
        "explanation":
            "Humidity means high water vapor content in the air, feeling sticky or muggy.",
        "difficulty": "easy",
        "tags": ["weather", "humidity"],
        "keywords": ["humid", "moisture"],
      },
      {
        "question": "Respond to: 'Beautiful day, isn't it?'",
        "options": [
          "Yes, it's lovely.",
          "No, go away.",
          "I don't know weather.",
          "Maybe raining.",
        ],
        "answer": 0,
        "explanation":
            "Agreeing with the positive sentiment is a natural response.",
        "difficulty": "easy",
        "tags": ["weather", "small talk"],
        "keywords": ["beautiful day", "agree"],
      },
      {
        "question":
            "What is the weather called with strong wind and heavy rain?",
        "options": ["Storm", "Breeze", "Fog", "Drought"],
        "answer": 0,
        "explanation":
            "A storm involves strong winds, rain, thunder, or lightning.",
        "difficulty": "easy",
        "tags": ["weather", "extreme"],
        "keywords": ["storm", "heavy rain"],
      },
      {
        "question":
            "Complete: 'In ______, flowers bloom and trees grow new leaves.'",
        "options": ["Winter", "Spring", "Summer", "Autumn"],
        "answer": 1,
        "explanation":
            "Spring is known for new plant growth and blooming flowers.",
        "difficulty": "easy",
        "tags": ["seasons", "spring"],
        "keywords": ["spring", "bloom"],
      },
      {
        "question": "What does 'chilly' describe?",
        "options": ["Very hot", "Slightly cold", "Windy", "Foggy"],
        "answer": 1,
        "explanation":
            "'Chilly' means unpleasantly cold, but not extremely so.",
        "difficulty": "easy",
        "tags": ["weather", "temperature"],
        "keywords": ["chilly", "slightly cold"],
      },
    ],
    "Grammar Through Speaking": [
      // ========== PRESENT TENSE SPEAKING PRACTICE (1-15) ==========
      {
        "question": "Complete the sentence: 'She ______ to school every day.'",
        "options": ["go", "goes", "going", "gone"],
        "answer": 1,
        "explanation":
            "For third-person singular (she/he/it), add 'es' to 'go' → 'goes'.",
        "difficulty": "easy",
        "tags": ["present tense", "simple present"],
        "keywords": ["goes", "every day"],
      },
      {
        "question":
            "Choose the correct negative form: 'I ______ like spicy food.'",
        "options": ["don't", "doesn't", "not", "no"],
        "answer": 0,
        "explanation":
            "With 'I', use 'don't' (do not) for negative simple present.",
        "difficulty": "easy",
        "tags": ["present tense", "negatives"],
        "keywords": ["don't", "negative"],
      },
      {
        "question": "What is the correct question? '______ you speak English?'",
        "options": ["Does", "Do", "Is", "Are"],
        "answer": 1,
        "explanation":
            "For 'you', use 'Do' to form a question in simple present.",
        "difficulty": "easy",
        "tags": ["present tense", "questions"],
        "keywords": ["do", "question"],
      },
      {
        "question": "Complete: 'The Earth ______ around the Sun.'",
        "options": ["revolve", "revolves", "revolving", "has revolved"],
        "answer": 1,
        "explanation":
            "This is a universal truth/unchanging fact, so use third-person singular 'revolves'.",
        "difficulty": "easy",
        "tags": ["present tense", "facts"],
        "keywords": ["revolves", "universal truth"],
      },
      {
        "question": "Choose the correct sentence:",
        "options": [
          "He don't work here.",
          "He doesn't works here.",
          "He doesn't work here.",
          "He don't works here.",
        ],
        "answer": 2,
        "explanation":
            "Negative with 'he': 'doesn't' + base form of verb (work).",
        "difficulty": "easy",
        "tags": ["present tense", "negatives"],
        "keywords": ["doesn't work", "correct"],
      },
      {
        "question": "Complete: 'My parents ______ in a bank.'",
        "options": ["work", "works", "working", "is working"],
        "answer": 0,
        "explanation":
            "'My parents' is plural, so use the base form 'work' (no 's').",
        "difficulty": "easy",
        "tags": ["present tense", "subject-verb agreement"],
        "keywords": ["parents plural", "work"],
      },
      {
        "question": "What does 'I usually wake up at 7 AM' express?",
        "options": [
          "A past action",
          "A future plan",
          "A habit or routine",
          "A continuous action",
        ],
        "answer": 2,
        "explanation":
            "Simple present with 'usually' describes a habitual action or routine.",
        "difficulty": "easy",
        "tags": ["present tense", "habits"],
        "keywords": ["usually", "habit"],
      },
      {
        "question":
            "Complete the question: 'What time ______ the movie start?'",
        "options": ["do", "does", "is", "are"],
        "answer": 1,
        "explanation": "'The movie' is third-person singular, so use 'does'.",
        "difficulty": "easy",
        "tags": ["present tense", "questions"],
        "keywords": ["does", "movie start"],
      },
      {
        "question":
            "Choose the correct frequency adverb position: 'She ______ eats breakfast.' (always)",
        "options": [
          "Eats always breakfast",
          "Always eats breakfast",
          "Eats breakfast always",
          "Breakfast always eats",
        ],
        "answer": 1,
        "explanation":
            "Frequency adverbs (always) come BEFORE the main verb (eats).",
        "difficulty": "easy",
        "tags": ["present tense", "adverbs"],
        "keywords": ["always", "frequency"],
      },
      {
        "question": "Complete: '______ he live in New York?'",
        "options": ["Do", "Does", "Is", "Are"],
        "answer": 1,
        "explanation":
            "'He' is third-person singular, so use 'Does' for questions.",
        "difficulty": "easy",
        "tags": ["present tense", "questions"],
        "keywords": ["does he", "live"],
      },
      {
        "question":
            "What is the stative verb in this sentence? 'I believe you are right.'",
        "options": ["believe", "are", "right", "I"],
        "answer": 0,
        "explanation":
            "'Believe' is a stative verb (expresses a state/opinion, not an action).",
        "difficulty": "medium",
        "tags": ["present tense", "stative verbs"],
        "keywords": ["believe", "stative"],
      },
      {
        "question": "Complete: 'The train ______ at 6 PM every evening.'",
        "options": ["leave", "leaves", "is leaving", "has left"],
        "answer": 1,
        "explanation":
            "Scheduled events (timetables) use simple present: 'leaves'.",
        "difficulty": "easy",
        "tags": ["present tense", "schedules"],
        "keywords": ["leaves", "timetable"],
      },
      {
        "question": "Choose the correct sentence for a general truth:",
        "options": [
          "Water boils at 100°C.",
          "Water is boiling at 100°C.",
          "Water boiled at 100°C.",
          "Water has boiled at 100°C.",
        ],
        "answer": 0,
        "explanation":
            "General truths and scientific facts use simple present tense.",
        "difficulty": "easy",
        "tags": ["present tense", "general truths"],
        "keywords": ["boils", "scientific fact"],
      },
      {
        "question": "Complete: 'How often ______ you visit your grandparents?'",
        "options": ["do", "does", "are", "is"],
        "answer": 0,
        "explanation": "'You' takes 'do' in questions.",
        "difficulty": "easy",
        "tags": ["present tense", "questions"],
        "keywords": ["how often", "do you"],
      },
      {
        "question": "What is the error? 'She go to the gym every Monday.'",
        "options": [
          "She should be Her",
          "go should be goes",
          "Monday should be Mondays",
          "gym should be gyms",
        ],
        "answer": 1,
        "explanation": "Third-person singular 'She' requires 'goes', not 'go'.",
        "difficulty": "easy",
        "tags": ["present tense", "error correction"],
        "keywords": ["goes", "third person"],
      },

      // ========== SIMPLE PAST TENSE COMMUNICATION (16-30) ==========
      {
        "question": "Complete: 'I ______ to the park yesterday.'",
        "options": ["go", "goes", "went", "gone"],
        "answer": 2,
        "explanation":
            "'Yesterday' indicates past time, so use past tense 'went'.",
        "difficulty": "easy",
        "tags": ["past tense", "regular/irregular"],
        "keywords": ["went", "yesterday"],
      },
      {
        "question":
            "Choose the correct negative: 'She ______ the movie last night.'",
        "options": [
          "didn't watched",
          "didn't watch",
          "doesn't watch",
          "not watched",
        ],
        "answer": 1,
        "explanation": "Past negative: 'didn't' + base form of verb (watch).",
        "difficulty": "easy",
        "tags": ["past tense", "negatives"],
        "keywords": ["didn't watch", "negative past"],
      },
      {
        "question": "Complete the question: '______ you see John yesterday?'",
        "options": ["Did", "Do", "Does", "Were"],
        "answer": 0,
        "explanation": "Past questions use 'Did' + base form of verb.",
        "difficulty": "easy",
        "tags": ["past tense", "questions"],
        "keywords": ["did", "past question"],
      },
      {
        "question": "What is the past tense of 'buy'?",
        "options": ["buyed", "bought", "brought", "buy"],
        "answer": 1,
        "explanation": "'Buy' is irregular: buy → bought.",
        "difficulty": "easy",
        "tags": ["past tense", "irregular verbs"],
        "keywords": ["bought", "irregular"],
      },
      {
        "question": "Complete: 'When I was a child, I ______ to be a pilot.'",
        "options": ["want", "wanted", "wanting", "have wanted"],
        "answer": 1,
        "explanation":
            "'When I was a child' refers to a past state, so use simple past 'wanted'.",
        "difficulty": "easy",
        "tags": ["past tense", "past states"],
        "keywords": ["wanted", "was a child"],
      },
      {
        "question": "Choose the correct sentence:",
        "options": [
          "I did go to the store yesterday.",
          "I went to the store yesterday.",
          "Both A and B",
          "I go to the store yesterday.",
        ],
        "answer": 2,
        "explanation":
            "Both are correct: 'I went' (normal) and 'I did go' (emphatic past).",
        "difficulty": "medium",
        "tags": ["past tense", "emphatic"],
        "keywords": ["emphatic past", "did go"],
      },
      {
        "question": "Complete: 'She ______ born in 1995.'",
        "options": ["is", "am", "were", "was"],
        "answer": 3,
        "explanation":
            "'Born' with past time uses 'was/were' → 'She was born'.",
        "difficulty": "easy",
        "tags": ["past tense", "passive", "birth"],
        "keywords": ["was born", "past"],
      },
      {
        "question": "What is the past tense of 'eat'?",
        "options": ["eated", "ate", "eaten", "eating"],
        "answer": 1,
        "explanation": "'Eat' is irregular: eat → ate.",
        "difficulty": "easy",
        "tags": ["past tense", "irregular verbs"],
        "keywords": ["ate", "past"],
      },
      {
        "question":
            "Complete: 'They ______ (not/come) to the party last week.'",
        "options": ["didn't came", "didn't come", "not came", "did not came"],
        "answer": 1,
        "explanation": "Past negative: 'didn't' + base form 'come'.",
        "difficulty": "easy",
        "tags": ["past tense", "negatives"],
        "keywords": ["didn't come", "negative"],
      },
      {
        "question": "Choose the correct 'used to' sentence:",
        "options": [
          "I used to play football when I was young.",
          "I use to play football when I was young.",
          "I used to playing football.",
          "I was used to play football.",
        ],
        "answer": 0,
        "explanation":
            "'Used to + base verb' describes past habits or states that no longer exist.",
        "difficulty": "medium",
        "tags": ["past tense", "used to"],
        "keywords": ["used to", "past habit"],
      },
      {
        "question": "Complete: 'What ______ you do last weekend?'",
        "options": ["do", "does", "did", "was"],
        "answer": 2,
        "explanation": "Past question with 'do' requires 'What did you do'.",
        "difficulty": "easy",
        "tags": ["past tense", "questions"],
        "keywords": ["did", "last weekend"],
      },
      {
        "question": "What is the error? 'I didn't went to school yesterday.'",
        "options": [
          "didn't should be don't",
          "went should be go",
          "yesterday should be today",
          "to should be at",
        ],
        "answer": 1,
        "explanation": "After 'didn't', use base form: 'go', not past 'went'.",
        "difficulty": "easy",
        "tags": ["past tense", "error correction"],
        "keywords": ["didn't go", "base form"],
      },
      {
        "question":
            "Complete: 'We ______ (meet) our friends at the mall an hour ago.'",
        "options": ["meet", "met", "meeted", "have met"],
        "answer": 1,
        "explanation":
            "'An hour ago' is a specific past time, so use simple past 'met'.",
        "difficulty": "easy",
        "tags": ["past tense", "time markers"],
        "keywords": ["met", "ago"],
      },
      {
        "question": "Choose the correct sentence about a past sequence:",
        "options": [
          "I wake up, then I eat breakfast.",
          "I woke up, then I ate breakfast.",
          "I woken up, then I eaten breakfast.",
          "I waking up, then I eating breakfast.",
        ],
        "answer": 1,
        "explanation":
            "Sequence of past actions uses simple past for both verbs.",
        "difficulty": "easy",
        "tags": ["past tense", "sequence"],
        "keywords": ["woke up", "ate"],
      },
      {
        "question":
            "Complete: 'She ______ (be) very shy when she was little, but now she's outgoing.'",
        "options": ["is", "were", "was", "be"],
        "answer": 2,
        "explanation": "Past state: 'was' (singular past of 'be').",
        "difficulty": "easy",
        "tags": ["past tense", "past states"],
        "keywords": ["was", "was little"],
      },

      // ========== FUTURE TENSE CONVERSATION (31-45) ==========
      {
        "question": "Complete: 'I ______ call you tomorrow.'",
        "options": ["will", "am", "have", "was"],
        "answer": 0,
        "explanation": "'Will' is used for future actions or promises.",
        "difficulty": "easy",
        "tags": ["future tense", "will"],
        "keywords": ["will", "tomorrow"],
      },
      {
        "question": "Choose the correct 'going to' sentence:",
        "options": [
          "I am going to study tonight.",
          "I going to study tonight.",
          "I am go to study tonight.",
          "I will going to study tonight.",
        ],
        "answer": 0,
        "explanation":
            "'Be going to' structure: am/is/are + going to + base verb.",
        "difficulty": "easy",
        "tags": ["future tense", "going to"],
        "keywords": ["going to", "plan"],
      },
      {
        "question":
            "What is the difference between 'will' and 'going to' for predictions?",
        "options": [
          "No difference",
          "Going to = evidence now, will = opinion",
          "Will = evidence, going to = opinion",
          "Both are past",
        ],
        "answer": 1,
        "explanation":
            "'Going to' is used when there is present evidence; 'will' is for general predictions/opinions.",
        "difficulty": "medium",
        "tags": ["future tense", "predictions"],
        "keywords": ["evidence", "opinion"],
      },
      {
        "question": "Complete: 'Look at those dark clouds! It ______ rain.'",
        "options": ["will", "is going to", "might", "should"],
        "answer": 1,
        "explanation":
            "Present evidence (dark clouds) suggests 'is going to' for a certain prediction.",
        "difficulty": "medium",
        "tags": ["future tense", "predictions"],
        "keywords": ["dark clouds", "going to"],
      },
      {
        "question": "Choose the correct future question:",
        "options": [
          "Will you come to the party?",
          "You will come to the party?",
          "Will you to come?",
          "You will coming?",
        ],
        "answer": 0,
        "explanation":
            "Future question with 'will': 'Will + subject + base verb'.",
        "difficulty": "easy",
        "tags": ["future tense", "questions"],
        "keywords": ["will you", "question"],
      },
      {
        "question":
            "Complete: 'The train ______ at 8 PM tonight.' (scheduled event)",
        "options": ["will leave", "is going to leave", "leaves", "has left"],
        "answer": 2,
        "explanation":
            "For scheduled events (timetables), use simple present for future.",
        "difficulty": "medium",
        "tags": ["future tense", "present for future"],
        "keywords": ["leaves", "scheduled"],
      },
      {
        "question": "What does 'I'm meeting my friend at 6 PM' express?",
        "options": [
          "A plan happening now",
          "A scheduled future arrangement",
          "A past event",
          "A general truth",
        ],
        "answer": 1,
        "explanation":
            "Present continuous with a future time expresses a fixed future arrangement.",
        "difficulty": "easy",
        "tags": ["future tense", "present continuous future"],
        "keywords": ["meeting", "arrangement"],
      },
      {
        "question": "Complete: 'I promise I ______ forget your birthday.'",
        "options": ["will not", "am not going to", "don't", "didn't"],
        "answer": 0,
        "explanation":
            "Promises use 'will' (or 'won't' for negative promises).",
        "difficulty": "easy",
        "tags": ["future tense", "promises"],
        "keywords": ["promise", "will not"],
      },
      {
        "question": "Choose the correct spontaneous decision:",
        "options": [
          "I'm going to answer the phone.",
          "I will answer the phone.",
          "I answer the phone.",
          "I answered the phone.",
        ],
        "answer": 1,
        "explanation":
            "'Will' is used for spontaneous decisions made at the moment of speaking.",
        "difficulty": "easy",
        "tags": ["future tense", "spontaneous"],
        "keywords": ["spontaneous", "will"],
      },
      {
        "question":
            "Complete: 'They ______ (move) to a new apartment next month.' (definite plan)",
        "options": ["will move", "are moving", "move", "moved"],
        "answer": 1,
        "explanation":
            "Present continuous ('are moving') = definite future arrangement.",
        "difficulty": "easy",
        "tags": ["future tense", "arrangements"],
        "keywords": ["are moving", "definite plan"],
      },
      {
        "question":
            "What is the future continuous form of 'I work at 10 AM tomorrow'?",
        "options": [
          "I will work",
          "I will be working",
          "I am working",
          "I work",
        ],
        "answer": 1,
        "explanation":
            "Future continuous: will be + present participle (working).",
        "difficulty": "medium",
        "tags": ["future tense", "future continuous"],
        "keywords": ["will be working", "future continuous"],
      },
      {
        "question": "Complete: 'By 2025, I ______ (graduate) from university.'",
        "options": [
          "will graduate",
          "will have graduated",
          "am graduating",
          "graduate",
        ],
        "answer": 1,
        "explanation":
            "'By + future time' requires future perfect: will have + past participle.",
        "difficulty": "hard",
        "tags": ["future tense", "future perfect"],
        "keywords": ["will have graduated", "by 2025"],
      },
      {
        "question": "Choose the correct 'shall' usage:",
        "options": [
          "Shall I open the window?",
          "I shall go to store yesterday.",
          "She shalls come.",
          "They shall not went.",
        ],
        "answer": 0,
        "explanation":
            "'Shall' is used for offers/suggestions with 'I' or 'we'.",
        "difficulty": "medium",
        "tags": ["future tense", "shall"],
        "keywords": ["shall I", "offer"],
      },
      {
        "question": "Complete: 'I think it ______ snow tomorrow.'",
        "options": ["is going to", "will", "shall", "is"],
        "answer": 1,
        "explanation": "With 'I think', 'will' expresses a prediction/opinion.",
        "difficulty": "easy",
        "tags": ["future tense", "predictions"],
        "keywords": ["I think will", "prediction"],
      },
      {
        "question": "What does 'I'm about to leave' mean?",
        "options": [
          "I may leave",
          "I will leave very soon/now",
          "I left already",
          "I never leave",
        ],
        "answer": 1,
        "explanation":
            "'About to' means something will happen in the immediate future.",
        "difficulty": "medium",
        "tags": ["future tense", "immediate future"],
        "keywords": ["about to", "immediate"],
      },

      // ========== CONTINUOUS TENSES USAGE (46-60) ==========
      {
        "question": "Complete: 'Right now, I ______ dinner.'",
        "options": ["cook", "cooks", "am cooking", "have cooked"],
        "answer": 2,
        "explanation":
            "'Right now' indicates present continuous: am/is/are + verb-ing.",
        "difficulty": "easy",
        "tags": ["continuous", "present continuous"],
        "keywords": ["right now", "am cooking"],
      },
      {
        "question": "Choose the correct past continuous:",
        "options": [
          "I was watch TV.",
          "I was watching TV.",
          "I watched TV.",
          "I am watching TV.",
        ],
        "answer": 1,
        "explanation": "Past continuous: was/were + verb-ing.",
        "difficulty": "easy",
        "tags": ["continuous", "past continuous"],
        "keywords": ["was watching", "past continuous"],
      },
      {
        "question": "Complete: 'What ______ you doing at 8 PM last night?'",
        "options": ["was", "were", "are", "is"],
        "answer": 1,
        "explanation": "'You' takes 'were' in past continuous.",
        "difficulty": "easy",
        "tags": ["continuous", "past continuous"],
        "keywords": ["were", "last night"],
      },
      {
        "question":
            "What does 'I'm learning Spanish' mean if you're not studying right this second?",
        "options": [
          "I am studying right now",
          "It's a temporary ongoing action around now",
          "It's finished",
          "It's a future plan",
        ],
        "answer": 1,
        "explanation":
            "Present continuous can describe actions in progress around the present time (not necessarily at this exact moment).",
        "difficulty": "medium",
        "tags": ["continuous", "temporary actions"],
        "keywords": ["learning", "ongoing"],
      },
      {
        "question":
            "Complete: 'While I ______ (walk) home, I saw an accident.'",
        "options": ["walk", "walked", "was walking", "have walked"],
        "answer": 2,
        "explanation":
            "Interrupted action in past: use past continuous for the longer action (walking) and simple past for the interruption (saw).",
        "difficulty": "medium",
        "tags": ["continuous", "interrupted actions"],
        "keywords": ["was walking", "while"],
      },
      {
        "question": "Choose the correct future continuous:",
        "options": [
          "I will be waiting at 5 PM.",
          "I will waiting at 5 PM.",
          "I am be waiting at 5 PM.",
          "I wait at 5 PM.",
        ],
        "answer": 0,
        "explanation":
            "Future continuous: will be + present participle (waiting).",
        "difficulty": "medium",
        "tags": ["continuous", "future continuous"],
        "keywords": ["will be waiting", "future continuous"],
      },
      {
        "question": "Complete: 'She ______ (study) when I called her.'",
        "options": ["studied", "was studying", "has studied", "is studying"],
        "answer": 1,
        "explanation":
            "Action in progress in the past at a specific time (when I called).",
        "difficulty": "easy",
        "tags": ["continuous", "past continuous"],
        "keywords": ["was studying", "when I called"],
      },
      {
        "question":
            "What is the present continuous of 'He is sleeping' in negative?",
        "options": [
          "He doesn't sleeping",
          "He isn't sleeping",
          "He not sleeping",
          "He sleeping not",
        ],
        "answer": 1,
        "explanation":
            "Negative present continuous: am/is/are + not + verb-ing.",
        "difficulty": "easy",
        "tags": ["continuous", "negatives"],
        "keywords": ["isn't sleeping", "negative"],
      },
      {
        "question":
            "Complete: 'Tomorrow at this time, I ______ (fly) to Paris.'",
        "options": ["will fly", "am flying", "will be flying", "fly"],
        "answer": 2,
        "explanation":
            "'At this time tomorrow' indicates future continuous for ongoing future action.",
        "difficulty": "medium",
        "tags": ["continuous", "future continuous"],
        "keywords": ["will be flying", "future time"],
      },
      {
        "question": "Choose the correct stative verb error:",
        "options": [
          "I am knowing the answer.",
          "I know the answer.",
          "I knew the answer.",
          "I have known the answer.",
        ],
        "answer": 0,
        "explanation":
            "'Know' is a stative verb and is not used in continuous forms.",
        "difficulty": "medium",
        "tags": ["continuous", "stative verbs"],
        "keywords": ["stative verb", "know"],
      },
      {
        "question": "Complete: 'I ______ (work) on a new project this week.'",
        "options": ["work", "works", "am working", "have worked"],
        "answer": 2,
        "explanation":
            "Present continuous for temporary action happening around this week (not permanent).",
        "difficulty": "easy",
        "tags": ["continuous", "temporary"],
        "keywords": ["am working", "this week"],
      },
      {
        "question":
            "What is the past continuous used for two simultaneous past actions?",
        "options": [
          "While I was cooking, he was watching TV.",
          "I cooked, he watched TV.",
          "I have cooked, he has watched.",
          "I cook, he watches.",
        ],
        "answer": 0,
        "explanation":
            "Two past continuous actions show two things happening at the same time in the past.",
        "difficulty": "medium",
        "tags": ["continuous", "simultaneous"],
        "keywords": ["was cooking", "was watching"],
      },
      {
        "question": "Complete: 'The phone rang while we ______ (have) dinner.'",
        "options": ["were having", "had", "have had", "are having"],
        "answer": 0,
        "explanation":
            "Interrupted action: longer action (were having dinner) in past continuous, interruption (rang) in simple past.",
        "difficulty": "easy",
        "tags": ["continuous", "interruption"],
        "keywords": ["were having", "rang"],
      },
      {
        "question": "Choose the correct present continuous question:",
        "options": [
          "Are you working now?",
          "Do you working now?",
          "Is you working now?",
          "You are working now?",
        ],
        "answer": 0,
        "explanation":
            "Present continuous question: am/is/are + subject + verb-ing.",
        "difficulty": "easy",
        "tags": ["continuous", "questions"],
        "keywords": ["are you working", "question"],
      },
      {
        "question": "What does 'I'm always losing my keys' express?",
        "options": [
          "Habit",
          "Annoying repeated action (with always)",
          "Future plan",
          "Past event",
        ],
        "answer": 1,
        "explanation":
            "Present continuous with 'always' expresses a repeated action that annoys the speaker.",
        "difficulty": "medium",
        "tags": ["continuous", "always complaint"],
        "keywords": ["always losing", "annoying"],
      },

      // ========== PERFECT TENSES IN DAILY SPEAKING (61-72) ==========
      {
        "question": "Complete: 'I ______ (see) that movie already.'",
        "options": ["saw", "have seen", "see", "was seeing"],
        "answer": 1,
        "explanation":
            "'Already' with present perfect: have/has + past participle (seen).",
        "difficulty": "easy",
        "tags": ["perfect", "present perfect"],
        "keywords": ["have seen", "already"],
      },
      {
        "question": "Choose the correct 'never' sentence:",
        "options": [
          "I have never been to Japan.",
          "I never have been to Japan.",
          "I have never go to Japan.",
          "I never went to Japan.",
        ],
        "answer": 0,
        "explanation":
            "Present perfect with 'never': have/has + never + past participle.",
        "difficulty": "easy",
        "tags": ["perfect", "present perfect"],
        "keywords": ["have never been", "experience"],
      },
      {
        "question": "What does 'She has lived here for 10 years' mean?",
        "options": [
          "She lived here in the past",
          "She started living here 10 years ago and still lives here",
          "She will live here",
          "She lived here for 10 years and left",
        ],
        "answer": 1,
        "explanation":
            "'For + duration' with present perfect indicates an action that started in the past and continues to now.",
        "difficulty": "easy",
        "tags": ["perfect", "present perfect duration"],
        "keywords": ["has lived for 10 years", "continues"],
      },
      {
        "question": "Complete: '______ you ever eaten sushi?'",
        "options": ["Did", "Have", "Were", "Are"],
        "answer": 1,
        "explanation":
            "Question about life experience uses 'Have you ever + past participle'.",
        "difficulty": "easy",
        "tags": ["perfect", "present perfect questions"],
        "keywords": ["have you ever", "experience"],
      },
      {
        "question": "Choose the correct past perfect sentence:",
        "options": [
          "When I arrived, she left.",
          "When I arrived, she had left.",
          "When I arrived, she has left.",
          "When I arrived, she was leaving.",
        ],
        "answer": 1,
        "explanation":
            "Past perfect (had left) shows the earlier action before another past action (arrived).",
        "difficulty": "medium",
        "tags": ["perfect", "past perfect"],
        "keywords": ["had left", "earlier past"],
      },
      {
        "question": "Complete: 'I ______ (finish) my homework already.'",
        "options": [
          "have finished",
          "finished",
          "was finishing",
          "had finished",
        ],
        "answer": 0,
        "explanation":
            "'Already' with present perfect: have + past participle.",
        "difficulty": "easy",
        "tags": ["perfect", "present perfect"],
        "keywords": ["have finished", "already"],
      },
      {
        "question":
            "What is the difference between 'I went to Paris' and 'I have been to Paris'?",
        "options": [
          "No difference",
          "Past simple = specific time, Present perfect = experience with no specific time",
          "Present perfect = past only",
          "Past simple = experience",
        ],
        "answer": 1,
        "explanation":
            "Past simple mentions a specific completed past time; present perfect focuses on the experience itself without a specific time.",
        "difficulty": "medium",
        "tags": ["perfect", "past simple vs present perfect"],
        "keywords": ["experience", "specific time"],
      },
      {
        "question":
            "Complete: 'By the time we arrived, the movie ______ (start).'",
        "options": ["started", "had started", "has started", "was starting"],
        "answer": 1,
        "explanation":
            "'By the time' + past simple requires past perfect for the earlier action.",
        "difficulty": "medium",
        "tags": ["perfect", "past perfect"],
        "keywords": ["had started", "by the time"],
      },
      {
        "question": "Choose the correct negative present perfect:",
        "options": [
          "I haven't seen him today.",
          "I didn't see him today.",
          "I don't see him today.",
          "I wasn't seeing him today.",
        ],
        "answer": 0,
        "explanation":
            "Negative present perfect: haven't/hasn't + past participle.",
        "difficulty": "easy",
        "tags": ["perfect", "negatives"],
        "keywords": ["haven't seen", "negative"],
      },
      {
        "question": "Complete: 'She ______ (work) here since 2018.'",
        "options": ["works", "worked", "has worked", "is working"],
        "answer": 2,
        "explanation":
            "'Since + starting point' requires present perfect: has worked.",
        "difficulty": "easy",
        "tags": ["perfect", "present perfect since"],
        "keywords": ["has worked since", "starting point"],
      },
      {
        "question": "What does 'I've just eaten' mean?",
        "options": [
          "I ate a long time ago",
          "I finished eating very recently",
          "I will eat soon",
          "I am eating now",
        ],
        "answer": 1,
        "explanation":
            "'Just' with present perfect means a very recent action.",
        "difficulty": "easy",
        "tags": ["perfect", "just"],
        "keywords": ["just eaten", "recent"],
      },
      {
        "question":
            "Complete: 'They ______ (live) in three different countries so far.'",
        "options": ["lived", "have lived", "were living", "had lived"],
        "answer": 1,
        "explanation":
            "'So far' indicates an experience up to now → present perfect.",
        "difficulty": "easy",
        "tags": ["perfect", "present perfect experience"],
        "keywords": ["have lived", "so far"],
      },

      // ========== MASTERING TENSE COMBINATIONS (73-80) ==========
      {
        "question":
            "Complete the mixed tense sentence: 'I usually ______ (wake) up at 7, but today I ______ (wake) up at 6.'",
        "options": [
          "wake / wake",
          "wake / woke",
          "woke / wake",
          "waking / waking",
        ],
        "answer": 1,
        "explanation":
            "Usually = present simple (wake); today (specific past) = past simple (woke).",
        "difficulty": "medium",
        "tags": ["tense combinations", "present vs past"],
        "keywords": ["usually", "today"],
      },
      {
        "question":
            "Choose the correct combination: 'If it rains tomorrow, I ______ (stay) home.'",
        "options": ["stay", "will stay", "stayed", "have stayed"],
        "answer": 1,
        "explanation":
            "First conditional: present simple (rains) + will + base verb (will stay).",
        "difficulty": "medium",
        "tags": ["tense combinations", "conditionals"],
        "keywords": ["if rains", "will stay"],
      },
      {
        "question":
            "Complete: 'While I ______ (walk) to work, I ______ (see) my old friend.'",
        "options": [
          "walk / see",
          "was walking / saw",
          "walked / was seeing",
          "have walked / have seen",
        ],
        "answer": 1,
        "explanation":
            "Past continuous (was walking) for longer action + simple past (saw) for interruption.",
        "difficulty": "medium",
        "tags": ["tense combinations", "past continuous + past simple"],
        "keywords": ["was walking", "saw"],
      },
      {
        "question":
            "Choose the correct sequence of tenses: 'She said that she ______ (be) tired.'",
        "options": ["is", "was", "has been", "will be"],
        "answer": 1,
        "explanation":
            "Reported speech: present in original → past in reported (she is → she was).",
        "difficulty": "medium",
        "tags": ["tense combinations", "reported speech"],
        "keywords": ["said that", "reported"],
      },
      {
        "question": "Complete: 'By next year, I ______ (complete) my degree.'",
        "options": [
          "complete",
          "will complete",
          "will have completed",
          "am completing",
        ],
        "answer": 2,
        "explanation":
            "'By + future time' requires future perfect: will have + past participle.",
        "difficulty": "hard",
        "tags": ["tense combinations", "future perfect"],
        "keywords": ["by next year", "will have completed"],
      },
      {
        "question":
            "Choose the correct sentence mixing present perfect and past simple:",
        "options": [
          "I have seen that movie last week.",
          "I saw that movie last week.",
          "I have seen that movie already last week.",
          "I see that movie last week.",
        ],
        "answer": 1,
        "explanation":
            "Specific past time (last week) requires past simple, not present perfect.",
        "difficulty": "medium",
        "tags": ["tense combinations", "present perfect vs past simple"],
        "keywords": ["last week", "saw"],
      },
      {
        "question":
            "Complete: 'I ______ (not/eat) breakfast yet, so I ______ (be) hungry now.'",
        "options": [
          "didn't eat / am",
          "haven't eaten / am",
          "wasn't eating / was",
          "don't eat / am",
        ],
        "answer": 1,
        "explanation":
            "'Yet' = present perfect (haven't eaten). Result now = present simple (am).",
        "difficulty": "medium",
        "tags": ["tense combinations", "present perfect + present simple"],
        "keywords": ["haven't eaten", "am hungry"],
      },
      {
        "question":
            "Choose the correct mixed tense for the past future: 'He told me he ______ (call) me later, but he never did.'",
        "options": ["will call", "would call", "calls", "has called"],
        "answer": 1,
        "explanation":
            "Past of 'will call' = 'would call' (future in the past).",
        "difficulty": "hard",
        "tags": ["tense combinations", "future in past"],
        "keywords": ["would call", "told me"],
      },
    ],
  };

  // ── Icons per topic ───────────────────────────────────────────────────────
  final Map<String, IconData> _topicIcons = {
    "Fundamentals": Icons.science,
    "Advanced Concepts": Icons.biotech,
    "Cell Biology": Icons.circle_outlined,
    "Genetics": Icons.abc_rounded,
  };

  final Map<String, List<Color>> _topicColors = {
    "Fundamentals": [Color(0xFF1565C0), Color(0xFF00897B)],
    "Advanced Concepts": [Color(0xFF6A1B9A), Color(0xFFE53935)],
    "Cell Biology": [Color(0xFF2E7D32), Color(0xFF00838F)],
    "Genetics": [Color(0xFFE65100), Color(0xFFC62828)],
  };

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Timer Logic ───────────────────────────────────────────────────────────
  void _startTimer() {
    if (!_isTimerEnabled) return;
    _timer?.cancel();
    _secondsRemaining = _timerDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isPaused) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timeUp();
        }
      });
    });
  }

  void _stopTimer() => _timer?.cancel();

  void _timeUp() {
    _stopTimer();
    if (_hapticEnabled) HapticFeedback.heavyImpact();
    _selectAnswer(-1); // -1 = timed out
  }

  // ── Core Quiz Logic (preserved + enhanced) ───────────────────────────────
  void _selectTopic(String topic) {
    setState(() {
      _selectedTopic = topic;
      _currentQuestions = List.from(quizData[topic]!);
      _applyDifficultyFilter();
      if (_isPracticeMode) _shuffleQuestions();
      _userAnswers = List.filled(_currentQuestions.length, null);
      _confidenceRatings = List.filled(_currentQuestions.length, null);
      _questionTimes = List.filled(_currentQuestions.length, 0);
      _currentQuestionIndex = 0;
      _selectedOption = null;
      _showExplanation = false;
      _eliminatedOptions = {};
      _hintsUsed = 0;
      _hintsAvailable = 3;
      _skippedCount = 0;
      _quizStartTime = DateTime.now();
      _questionStartTime = DateTime.now();
      _currentState = QuizState.quiz;
    });
    _startCountdown();
  }

  void _applyDifficultyFilter() {
    if (_selectedDifficulty == Difficulty.mixed) return;
    final diffMap = {
      Difficulty.easy: 'easy',
      Difficulty.medium: 'medium',
      Difficulty.hard: 'hard',
    };
    _currentQuestions = _currentQuestions
        .where((q) => q['difficulty'] == diffMap[_selectedDifficulty])
        .toList();
    if (_currentQuestions.isEmpty) {
      _currentQuestions = List.from(quizData[_selectedTopic]!);
    }
  }

  void _shuffleQuestions() => _currentQuestions.shuffle();

  void _selectAnswer(int optionIndex) {
    if (_selectedOption != null) return;
    _stopTimer();

    // Record question time
    if (_questionStartTime != null) {
      final elapsed = DateTime.now().difference(_questionStartTime!).inSeconds;
      if (_currentQuestionIndex < _questionTimes.length) {
        _questionTimes[_currentQuestionIndex] = elapsed;
      }
    }

    if (_hapticEnabled) {
      if (optionIndex == _currentQuestions[_currentQuestionIndex]['answer']) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    }

    setState(() {
      _selectedOption = optionIndex;
      if (optionIndex >= 0) {
        _userAnswers[_currentQuestionIndex] = optionIndex;
      }

      // Streak logic
      if (optionIndex >= 0 &&
          optionIndex == _currentQuestions[_currentQuestionIndex]['answer']) {
        _currentStreak++;
        _totalPoints += 10 + (_currentStreak > 3 ? 5 : 0);
        _xpPoints += 15;
        if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
      } else {
        _currentStreak = 0;
      }

      // Answer history
      _answerHistory.add({
        'topic': _selectedTopic,
        'questionIndex': _currentQuestionIndex,
        'selected': optionIndex,
        'correct': _currentQuestions[_currentQuestionIndex]['answer'],
        'time': _questionTimes.isNotEmpty
            ? _questionTimes[_currentQuestionIndex]
            : 0,
      });

      _questionsToday++;

      if (_isPracticeMode) {
        _showExplanation = true;
        if (_autoAdvance) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted &&
                _currentQuestionIndex < _currentQuestions.length - 1) {
              _nextQuestion();
            }
          });
        }
      } else {
        if (_autoAdvance) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted &&
                _currentQuestionIndex < _currentQuestions.length - 1) {
              _nextQuestion();
            }
          });
        }
      }
    });

    _checkBadges();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = _userAnswers[_currentQuestionIndex];
        _showExplanation = _isPracticeMode && _selectedOption != null;
        _eliminatedOptions = {};
        _questionStartTime = DateTime.now();
      });
      if (_isTimerEnabled && _selectedOption == null) _startTimer();
    } else {
      _showResult();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _stopTimer();
      setState(() {
        _currentQuestionIndex--;
        _selectedOption = _userAnswers[_currentQuestionIndex];
        _showExplanation = _isPracticeMode && _selectedOption != null;
        _eliminatedOptions = {};
      });
      if (_isTimerEnabled && _selectedOption == null) _startTimer();
    }
  }

  void _jumpToQuestion(int index) {
    _stopTimer();
    setState(() {
      _currentQuestionIndex = index;
      _selectedOption = _userAnswers[index];
      _showExplanation = _isPracticeMode && _selectedOption != null;
      _eliminatedOptions = {};
      _questionStartTime = DateTime.now();
    });
    if (_isTimerEnabled && _selectedOption == null) _startTimer();
  }

  void _skipQuestion() {
    setState(() => _skippedCount++);
    _nextQuestion();
  }

  void _showResult() {
    _stopTimer();
    final elapsed = _quizStartTime != null
        ? DateTime.now().difference(_quizStartTime!).inSeconds
        : 0;
    _totalTimeSeconds = elapsed;

    // Save to topic history
    _topicScoreHistory.putIfAbsent(_selectedTopic, () => []).add(_score);
    _updateMastery();

    // Save session
    _sessionHistory.add({
      'topic': _selectedTopic,
      'score': _score,
      'total': _currentQuestions.length,
      'time': elapsed,
      'date': DateTime.now().toIso8601String(),
    });

    setState(() => _currentState = QuizState.result);
    _animateTransition();
    _checkBadges();
  }

  void _updateMastery() {
    final pct = _percentage.round();
    final prev = _topicMastery[_selectedTopic] ?? 0;
    _topicMastery[_selectedTopic] = ((prev + pct) / 2).round();
  }

  void _restartQuiz() {
    setState(() {
      _userAnswers = List.filled(_currentQuestions.length, null);
      _confidenceRatings = List.filled(_currentQuestions.length, null);
      _questionTimes = List.filled(_currentQuestions.length, 0);
      _currentQuestionIndex = 0;
      _selectedOption = null;
      _showExplanation = false;
      _currentState = QuizState.quiz;
      _currentStreak = 0;
      _eliminatedOptions = {};
      _hintsUsed = 0;
      _hintsAvailable = 3;
      _skippedCount = 0;
      _quizStartTime = DateTime.now();
      _questionStartTime = DateTime.now();
    });
    _animateTransition();
    if (_isTimerEnabled) _startTimer();
  }

  void _resetToTopics() {
    _stopTimer();
    setState(() {
      _currentState = QuizState.topic;
      _selectedTopic = '';
      _currentQuestions = [];
      _userAnswers = [];
      _currentQuestionIndex = 0;
      _selectedOption = null;
      _currentStreak = 0;
      _eliminatedOptions = {};
    });
    _animateTransition();
  }

  void _toggleMode() => setState(() => _isPracticeMode = !_isPracticeMode);

  void _animateTransition() {
    _animationController.reset();
    _animationController.forward();
  }

  // ── NEW FEATURE: Countdown before quiz ───────────────────────────────────
  void _startCountdown() {
    setState(() {
      _showCountdown = true;
      _countdownValue = 3;
    });
    Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _countdownValue--);
      if (_countdownValue <= 0) {
        t.cancel();
        setState(() => _showCountdown = false);
        _animateTransition();
        if (_isTimerEnabled) _startTimer();
        _questionStartTime = DateTime.now();
      }
    });
  }

  // ── NEW FEATURE: Hint / Eliminate ─────────────────────────────────────────
  void _useHint() {
    if (_hintsAvailable <= 0 || _selectedOption != null) return;
    final correctAnswer =
        _currentQuestions[_currentQuestionIndex]['answer'] as int;
    final wrongOptions = List.generate(4, (i) => i)
        .where((i) => i != correctAnswer && !_eliminatedOptions.contains(i))
        .toList();
    if (wrongOptions.isEmpty) return;
    wrongOptions.shuffle();
    setState(() {
      _eliminatedOptions.add(wrongOptions.first);
      _hintsAvailable--;
      _hintsUsed++;
      _totalPoints -= 2;
    });
    if (_hapticEnabled) HapticFeedback.selectionClick();
  }

  // ── NEW FEATURE: Bookmark ─────────────────────────────────────────────────
  void _toggleBookmark() {
    final key = '${_selectedTopic}_$_currentQuestionIndex';
    setState(() {
      if (_bookmarkedQuestions.contains(key)) {
        _bookmarkedQuestions.remove(key);
      } else {
        _bookmarkedQuestions.add(key);
      }
    });
    if (_hapticEnabled) HapticFeedback.selectionClick();
  }

  bool get _isCurrentBookmarked =>
      _bookmarkedQuestions.contains('${_selectedTopic}_$_currentQuestionIndex');

  // ── NEW FEATURE: Badge system ─────────────────────────────────────────────
  void _checkBadges() {
    final newBadges = <String>[];
    if (_totalPoints >= 50 && !_earnedBadges.contains('🔥 First 50 XP')) {
      newBadges.add('🔥 First 50 XP');
    }
    if (_bestStreak >= 5 && !_earnedBadges.contains('⚡ 5 Streak')) {
      newBadges.add('⚡ 5 Streak');
    }
    if (_sessionHistory.length >= 3 &&
        !_earnedBadges.contains('📚 3 Quizzes')) {
      newBadges.add('📚 3 Quizzes');
    }
    if (_questionsToday >= _dailyGoal &&
        !_earnedBadges.contains('🎯 Daily Goal')) {
      newBadges.add('🎯 Daily Goal');
    }
    if (_percentage >= 100 && !_earnedBadges.contains('💯 Perfect Score')) {
      newBadges.add('💯 Perfect Score');
    }
    if (newBadges.isNotEmpty) {
      setState(() => _earnedBadges.addAll(newBadges));
      for (final badge in newBadges) {
        _showBadgeNotification(badge);
      }
    }
  }

  void _showBadgeNotification(String badge) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Badge earned: $badge'),
        backgroundColor: Colors.amber[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── NEW FEATURE: Report question ─────────────────────────────────────────
  void _reportQuestion() {
    setState(() => _reportedQuestions.add(_currentQuestionIndex));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Question reported. Thank you!'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── NEW FEATURE: Favorite topic ───────────────────────────────────────────
  void _toggleFavorite(String topic) {
    setState(() {
      if (_favoriteTopics.contains(topic)) {
        _favoriteTopics.remove(topic);
      } else {
        _favoriteTopics.add(topic);
      }
    });
    if (_hapticEnabled) HapticFeedback.selectionClick();
  }

  // ── Computed ──────────────────────────────────────────────────────────────
  int get _score {
    int correct = 0;
    for (int i = 0; i < _userAnswers.length; i++) {
      if (_userAnswers[i] != null &&
          _userAnswers[i] == _currentQuestions[i]['answer']) {
        correct++;
      }
    }
    return correct;
  }

  double get _percentage =>
      _currentQuestions.isEmpty ? 0 : (_score / _currentQuestions.length) * 100;

  String get _gradeLabel {
    if (_percentage >= 90) return 'Excellent! 🌟';
    if (_percentage >= 75) return 'Good Job! 👍';
    if (_percentage >= 50) return 'Keep Practicing! 💪';
    return 'Needs Improvement 📖';
  }

  Color get _gradeColor {
    if (_percentage >= 90) return Colors.green;
    if (_percentage >= 75) return Colors.blue;
    if (_percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  List<String> get _sortedTopics {
    final topics = quizData.keys.toList();
    switch (_topicSortOrder) {
      case SortOrder.alphabetical:
        topics.sort();
        break;
      case SortOrder.questionCount:
        topics.sort(
          (a, b) => quizData[b]!.length.compareTo(quizData[a]!.length),
        );
        break;
      case SortOrder.difficulty:
        topics.sort((a, b) {
          final aHard = quizData[a]!
              .where((q) => q['difficulty'] == 'hard')
              .length;
          final bHard = quizData[b]!
              .where((q) => q['difficulty'] == 'hard')
              .length;
          return bHard.compareTo(aHard);
        });
        break;
      case SortOrder.recent:
        final recent = _sessionHistory.map((s) => s['topic'] as String).toSet();
        topics.sort((a, b) {
          final aR = recent.contains(a) ? 0 : 1;
          final bR = recent.contains(b) ? 0 : 1;
          return aR.compareTo(bR);
        });
        break;
    }
    // Favorites first
    topics.sort((a, b) {
      final aFav = _favoriteTopics.contains(a) ? 0 : 1;
      final bFav = _favoriteTopics.contains(b) ? 0 : 1;
      return aFav.compareTo(bFav);
    });
    return topics;
  }

  List<Map<String, dynamic>> get _filteredTopics {
    if (_searchQuery.isEmpty)
      return _sortedTopics.map((t) => {'topic': t}).toList();
    return _sortedTopics
        .where((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()))
        .map((t) => {'topic': t})
        .toList();
  }

  // ── Theme ─────────────────────────────────────────────────────────────────
  Color get _bgColor => _isDarkMode ? const Color(0xFF121212) : Colors.white;
  Color get _surfaceColor =>
      _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
  Color get _textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get _subTextColor => _isDarkMode ? Colors.white60 : Colors.black54;
  Color get _cardColor => _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(isTablet),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _isDarkMode
                    ? [const Color(0xFF1A1A2E), const Color(0xFF121212)]
                    : [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildCurrentState(isTablet),
              ),
            ),
          ),
          if (_showCountdown) _buildCountdownOverlay(),
          if (_isPaused) _buildPauseOverlay(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isTablet) {
    return AppBar(
      backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue[700],
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.science, size: 24),
          const SizedBox(width: 8),
          Text(
            'BS-CLS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          if (_currentState == QuizState.quiz) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _selectedTopic,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Points badge
        if (_totalPoints > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.white),
                  Text(
                    '$_totalPoints',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_currentState == QuizState.quiz) ...[
          // Pause
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            tooltip: _isPaused ? 'Resume' : 'Pause',
            onPressed: () => setState(() => _isPaused = !_isPaused),
          ),
          // Bookmark
          IconButton(
            icon: Icon(
              _isCurrentBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isCurrentBookmarked ? Colors.amber : Colors.white,
            ),
            tooltip: 'Bookmark',
            onPressed: _toggleBookmark,
          ),
          // Hint
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.lightbulb_outline),
                tooltip: 'Use Hint ($_hintsAvailable left)',
                onPressed: _hintsAvailable > 0 ? _useHint : null,
              ),
              if (_hintsAvailable > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_hintsAvailable',
                      style: const TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showModeDialog,
          ),
          // Navigator
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: _showQuestionNavigator,
          ),
        ] else ...[
          // Dark Mode toggle
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
          // Stats
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () =>
                setState(() => _currentState = QuizState.statistics),
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => setState(() => _currentState = QuizState.settings),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentState(bool isTablet) {
    switch (_currentState) {
      case QuizState.topic:
        return _buildTopicSelection(isTablet);
      case QuizState.quiz:
        return _buildQuizView(isTablet);
      case QuizState.result:
        return _buildResultView(isTablet);
      case QuizState.review:
        return _buildReviewView();
      case QuizState.statistics:
        return _buildStatisticsView();
      case QuizState.settings:
        return _buildSettingsView();
      case QuizState.leaderboard:
        return _buildLeaderboardView();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOPIC SELECTION
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopicSelection(bool isTablet) {
    return Column(
      children: [
        // Header card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.green[600]!],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.science,
                      size: 28,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BS-CLS Life Sciences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${_questionsToday}/$_dailyGoal daily goal • $_totalPoints pts',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Practice',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Switch(
                        value: _isPracticeMode,
                        onChanged: (_) => _toggleMode(),
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green[400],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Daily goal progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily Goal',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '$_questionsToday/$_dailyGoal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_questionsToday / _dailyGoal).clamp(0.0, 1.0),
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.amber,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Streak & badges row
        if (_currentStreak > 0 || _earnedBadges.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (_currentStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '$_currentStreak Streak',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _earnedBadges
                          .map(
                            (b) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Chip(
                                label: Text(
                                  b,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.amber[100],
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // Search + Sort
        Padding(
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
                    hintStyle: TextStyle(color: _subTextColor),
                    prefixIcon: Icon(Icons.search, color: _subTextColor),
                    filled: true,
                    fillColor: _surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Sort dropdown
              PopupMenuButton<SortOrder>(
                icon: Icon(Icons.sort, color: _subTextColor),
                tooltip: 'Sort',
                onSelected: (o) => setState(() => _topicSortOrder = o),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: SortOrder.alphabetical,
                    child: Text('A–Z'),
                  ),
                  const PopupMenuItem(
                    value: SortOrder.questionCount,
                    child: Text('Most Questions'),
                  ),
                  const PopupMenuItem(
                    value: SortOrder.difficulty,
                    child: Text('Hardest First'),
                  ),
                  const PopupMenuItem(
                    value: SortOrder.recent,
                    child: Text('Recent'),
                  ),
                ],
              ),
              // Difficulty filter
              PopupMenuButton<Difficulty>(
                icon: Icon(Icons.filter_list, color: _subTextColor),
                tooltip: 'Difficulty',
                onSelected: (d) => setState(() => _selectedDifficulty = d),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: Difficulty.mixed,
                    child: Text('All Levels'),
                  ),
                  const PopupMenuItem(
                    value: Difficulty.easy,
                    child: Text('Easy'),
                  ),
                  const PopupMenuItem(
                    value: Difficulty.medium,
                    child: Text('Medium'),
                  ),
                  const PopupMenuItem(
                    value: Difficulty.hard,
                    child: Text('Hard'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Topics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              if (_selectedDifficulty != Difficulty.mixed)
                Chip(
                  label: Text(
                    _selectedDifficulty.name.toUpperCase(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: _difficultyColor(_selectedDifficulty.name),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),

        // Topic grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: isTablet ? 1.4 : 1.25,
            ),
            itemCount: _filteredTopics.length,
            itemBuilder: (context, index) {
              final topic = _filteredTopics[index]['topic'] as String;
              return _buildTopicCard(topic, isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(String topic, bool isTablet) {
    final colors =
        _topicColors[topic] ?? [Colors.blue[400]!, Colors.green[400]!];
    final icon = _topicIcons[topic] ?? Icons.book;
    final mastery = _topicMastery[topic];
    final isFav = _favoriteTopics.contains(topic);
    final lastScore = (_topicScoreHistory[topic]?.isNotEmpty ?? false)
        ? _topicScoreHistory[topic]!.last
        : null;
    final totalQ = quizData[topic]!.length;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => _selectTopic(topic),
        onLongPress: () => _showTopicDetails(topic),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 22, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => _toggleFavorite(topic),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.pink[200] : Colors.white60,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                topic,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$totalQ Q',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  if (lastScore != null) ...[
                    const Text(' • ', style: TextStyle(color: Colors.white38)),
                    Text(
                      'Last: $lastScore/$totalQ',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
              if (mastery != null) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mastery / 100,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mastery $mastery%',
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // QUIZ VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildQuizView(bool isTablet) {
    final question = _currentQuestions[_currentQuestionIndex];
    return Column(
      children: [
        // Progress + Timer
        Container(
          color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Q ${_currentQuestionIndex + 1} / ${_currentQuestions.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _textColor,
                              ),
                            ),
                            Row(
                              children: [
                                // Streak display
                                if (_currentStreak > 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '🔥 $_currentStreak',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  '${((_currentQuestionIndex + 1) / _currentQuestions.length * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value:
                                (_currentQuestionIndex + 1) /
                                _currentQuestions.length,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                            minHeight: 7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Timer widget
                  if (_isTimerEnabled) ...[
                    const SizedBox(width: 12),
                    _buildTimerWidget(),
                  ],
                ],
              ),
              // Difficulty badge
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildDifficultyChip(question['difficulty'] as String),
                  const SizedBox(width: 6),
                  ...((question['tags'] as List<dynamic>? ?? [])
                      .take(2)
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Chip(
                            label: Text(
                              t.toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            backgroundColor: _surfaceColor,
                            labelStyle: TextStyle(color: _subTextColor),
                          ),
                        ),
                      )),
                  const Spacer(),
                  // Report button
                  IconButton(
                    icon: Icon(
                      _reportedQuestions.contains(_currentQuestionIndex)
                          ? Icons.flag
                          : Icons.flag_outlined,
                      size: 18,
                      color: _reportedQuestions.contains(_currentQuestionIndex)
                          ? Colors.red
                          : _subTextColor,
                    ),
                    onPressed: _reportQuestion,
                    tooltip: 'Report Question',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Question + Options
        Expanded(
          child: isTablet
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildQuestionCard(question)),
                    Expanded(
                      flex: 3,
                      child: _buildOptionsList(question, isTablet),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildQuestionCard(question),
                      const SizedBox(height: 16),
                      _buildOptionsList(question, isTablet),
                    ],
                  ),
                ),
        ),
        // Navigation
        _buildNavigationBar(),
      ],
    );
  }

  Widget _buildTimerWidget() {
    final ratio = _secondsRemaining / _timerDuration;
    final color = ratio > 0.5
        ? Colors.green
        : ratio > 0.25
        ? Colors.orange
        : Colors.red;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: ratio,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 4,
          ),
          Text(
            '$_secondsRemaining',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Card(
      elevation: 3,
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _highlightKeywords
                ? _buildHighlightedText(
                    question['question'] as String,
                    (question['keywords'] as List<dynamic>? ?? [])
                        .map((e) => e.toString())
                        .toList(),
                  )
                : Text(
                    question['question'] as String,
                    style: TextStyle(
                      fontSize: _fontSize + 2,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                    textAlign: TextAlign.left,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, List<String> keywords) {
    if (keywords.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: _fontSize + 2,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      );
    }
    // Simple highlight: bold keywords
    final spans = <TextSpan>[];
    String remaining = text;
    for (final kw in keywords) {
      final idx = remaining.toLowerCase().indexOf(kw.toLowerCase());
      if (idx >= 0) {
        if (idx > 0) spans.add(TextSpan(text: remaining.substring(0, idx)));
        spans.add(
          TextSpan(
            text: remaining.substring(idx, idx + kw.length),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
              backgroundColor: Colors.blue[50],
            ),
          ),
        );
        remaining = remaining.substring(idx + kw.length);
      }
    }
    if (remaining.isNotEmpty) spans.add(TextSpan(text: remaining));
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: _fontSize + 2,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildOptionsList(Map<String, dynamic> question, bool isTablet) {
    return Column(
      children: [
        ...List.generate(4, (index) {
          if (_eliminatedOptions.contains(index)) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 56,
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Text(
                  'Eliminated',
                  style: TextStyle(color: _subTextColor, fontSize: 13),
                ),
              ),
            );
          }
          return _buildOptionCard(
            index,
            question['options'][index] as String,
            question['answer'] as int,
          );
        }),
        // Explanation
        if (_showExplanation && _isPracticeMode)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isDarkMode
                  ? Colors.blue[900]!.withOpacity(0.4)
                  : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Explanation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  question['explanation'] as String,
                  style: TextStyle(color: _textColor, fontSize: _fontSize - 1),
                ),
              ],
            ),
          ),
        // Confidence rating
        if (_selectedOption != null) ...[
          const SizedBox(height: 12),
          _buildConfidenceRating(),
        ],
        // Note input
        const SizedBox(height: 12),
        _buildNoteInput(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildConfidenceRating() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How confident were you?',
            style: TextStyle(color: _subTextColor, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              final selected =
                  _confidenceRatings[_currentQuestionIndex] == i + 1;
              return GestureDetector(
                onTap: () => setState(
                  () => _confidenceRatings[_currentQuestionIndex] = i + 1,
                ),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected ? Colors.blue : _surfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.blue : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: selected ? Colors.white : _subTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      style: TextStyle(color: _textColor, fontSize: 13),
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'Add a note for this question...',
        hintStyle: TextStyle(color: _subTextColor, fontSize: 13),
        prefixIcon: Icon(
          Icons.note_add_outlined,
          color: _subTextColor,
          size: 18,
        ),
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      onChanged: (v) =>
          setState(() => _questionNotes[_currentQuestionIndex] = v),
      controller: TextEditingController(
        text: _questionNotes[_currentQuestionIndex] ?? '',
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            ElevatedButton.icon(
              onPressed: _previousQuestion,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Prev'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDarkMode
                    ? Colors.grey[700]
                    : Colors.grey[300],
                foregroundColor: _isDarkMode ? Colors.white : Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            )
          else
            const SizedBox(width: 80),
          const SizedBox(width: 8),
          // Skip button
          OutlinedButton(
            onPressed: _selectedOption == null ? _skipQuestion : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            child: Text(
              'Skip',
              style: TextStyle(fontSize: 13, color: _subTextColor),
            ),
          ),
          const Spacer(),
          if (_currentQuestionIndex < _currentQuestions.length - 1)
            ElevatedButton.icon(
              onPressed: _selectedOption != null ? _nextQuestion : null,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _selectedOption != null ? _showResult : null,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Finish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index, String text, int correctAnswer) {
    bool isSelected = _selectedOption == index;
    bool isCorrect = isSelected && index == correctAnswer;
    bool isWrong = isSelected && index != correctAnswer;
    bool showCorrect =
        _showCorrectOnWrong &&
        !_isPracticeMode &&
        _selectedOption != null &&
        index == correctAnswer &&
        !isSelected;

    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = isCorrect ? Colors.green[100] : Colors.red[100];
    } else if (showCorrect ||
        (_isPracticeMode &&
            _selectedOption != null &&
            index == correctAnswer &&
            !isSelected)) {
      backgroundColor = Colors.green[50];
    } else {
      backgroundColor = _cardColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isSelected ? 4 : 1,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _selectedOption == null ? () => _selectAnswer(index) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isCorrect ? Colors.green : Colors.red)
                  : (showCorrect ? Colors.green : Colors.grey[300]!),
              width: isSelected || showCorrect ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isCorrect ? Colors.green : Colors.red)
                      : (showCorrect ? Colors.green[100] : Colors.grey[200]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : _textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: _fontSize, color: _textColor),
                ),
              ),
              if (isSelected && isCorrect)
                const Icon(Icons.check_circle, color: Colors.green, size: 22),
              if (isSelected && isWrong)
                const Icon(Icons.cancel, color: Colors.red, size: 22),
              if (showCorrect)
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RESULT VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildResultView(bool isTablet) {
    final minutes = _totalTimeSeconds ~/ 60;
    final seconds = _totalTimeSeconds % 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.green[600]!],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.assignment_turned_in,
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Quiz Complete!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _gradeLabel,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$_score / ${_currentQuestions.length} Correct',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _percentage / 100,
                      backgroundColor: Colors.white30,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _buildStatCard(
                '⏱️ Time',
                '${minutes}m ${seconds}s',
                Colors.purple,
              ),
              const SizedBox(width: 10),
              _buildStatCard('🔥 Best Streak', '$_bestStreak', Colors.orange),
              const SizedBox(width: 10),
              _buildStatCard('⭐ Points', '$_totalPoints', Colors.amber),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard('💡 Hints', '$_hintsUsed used', Colors.blue),
              const SizedBox(width: 10),
              _buildStatCard('⏭️ Skipped', '$_skippedCount', Colors.teal),
              const SizedBox(width: 10),
              _buildStatCard(
                '📊 Mastery',
                '${_topicMastery[_selectedTopic] ?? 0}%',
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _restartQuiz,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Restart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      setState(() => _currentState = QuizState.review),
                  icon: const Icon(Icons.rate_review, size: 16),
                  label: const Text('Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetToTopics,
                  icon: const Icon(Icons.home, size: 16),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Badges earned
          if (_earnedBadges.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Badges',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _textColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _earnedBadges
                  .map(
                    (b) => Chip(
                      label: Text(b, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.amber[100],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Question summary
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Question Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentQuestions.length,
            itemBuilder: (context, index) {
              final isCorrect =
                  _userAnswers[index] == _currentQuestions[index]['answer'];
              final qTime = index < _questionTimes.length
                  ? _questionTimes[index]
                  : 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: _cardColor,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: isCorrect ? Colors.green : Colors.red,
                    child: Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  title: Text(
                    _currentQuestions[index]['question'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: _textColor),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'Your: ${_userAnswers[index] != null ? String.fromCharCode(65 + _userAnswers[index]!) : 'Skipped'}',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontSize: 11,
                        ),
                      ),
                      const Text(' • ', style: TextStyle(fontSize: 11)),
                      Text(
                        '${qTime}s',
                        style: TextStyle(color: _subTextColor, fontSize: 11),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Correct: ${String.fromCharCode(65 + (_currentQuestions[index]['answer'] as int))}. ${(_currentQuestions[index]['options'] as List)[_currentQuestions[index]['answer']]}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _currentQuestions[index]['explanation'] as String,
                            style: TextStyle(
                              color: _subTextColor,
                              fontSize: 13,
                            ),
                          ),
                          if (_questionNotes[index] != null &&
                              _questionNotes[index]!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.note,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Note: ${_questionNotes[index]}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: _subTextColor)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REVIEW VIEW (new)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildReviewView() {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Text('Review Answers'),
          actions: [
            TextButton(
              onPressed: () => setState(() => _currentState = QuizState.result),
              child: const Text('Back', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _currentQuestions.length,
            itemBuilder: (ctx, i) {
              final q = _currentQuestions[i];
              final isCorrect = _userAnswers[i] == q['answer'];
              return Card(
                color: _cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isCorrect ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCorrect ? '✓ Correct' : '✗ Wrong',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildDifficultyChip(q['difficulty'] as String),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        q['question'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                          fontSize: _fontSize,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(4, (j) {
                        final opts = q['options'] as List;
                        final isOpt = _userAnswers[i] == j;
                        final isRight = q['answer'] == j;
                        Color? bg;
                        if (isOpt && isRight) bg = Colors.green[50];
                        if (isOpt && !isRight) bg = Colors.red[50];
                        if (!isOpt && isRight) bg = Colors.green[50];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: bg ?? _surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isRight
                                  ? Colors.green
                                  : (isOpt && !isRight)
                                  ? Colors.red
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${String.fromCharCode(65 + j)}. ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _textColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  opts[j] as String,
                                  style: TextStyle(
                                    color: _textColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (isRight)
                                const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 16,
                                ),
                              if (isOpt && !isRight)
                                const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 16,
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isDarkMode
                              ? Colors.blue[900]!.withOpacity(0.3)
                              : Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          q['explanation'] as String,
                          style: TextStyle(color: _subTextColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STATISTICS VIEW (new)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStatisticsView() {
    return Column(
      children: [
        _buildSecondaryAppBar('Statistics', Icons.bar_chart, QuizState.topic),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary
              _buildSectionTitle('Overall Performance'),
              Row(
                children: [
                  _buildStatCard(
                    'Total Points',
                    '$_totalPoints pts',
                    Colors.amber,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard('Best Streak', '$_bestStreak', Colors.orange),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    'Quizzes',
                    '${_sessionHistory.length}',
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Daily goal
              _buildSectionTitle('Today\'s Progress'),
              Card(
                color: _cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Goal: $_dailyGoal questions',
                            style: TextStyle(color: _textColor),
                          ),
                          Text(
                            'Done: $_questionsToday',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (_questionsToday / _dailyGoal).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                          minHeight: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Topic mastery
              _buildSectionTitle('Topic Mastery'),
              ..._topicMastery.entries.map(
                (e) => Card(
                  color: _cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.key,
                              style: TextStyle(
                                color: _textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${e.value}%',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: e.value / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _masteryColor(e.value),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_topicMastery.isEmpty)
                Center(
                  child: Text(
                    'Complete quizzes to see mastery stats.',
                    style: TextStyle(color: _subTextColor),
                  ),
                ),
              const SizedBox(height: 16),

              // Session history
              _buildSectionTitle('Session History'),
              ..._sessionHistory.reversed
                  .take(5)
                  .map(
                    (s) => Card(
                      color: _cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _gradeColorFromPct(
                            s['score'] / s['total'] * 100,
                          ),
                          child: Text(
                            '${(s['score'] / s['total'] * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          s['topic'] as String,
                          style: TextStyle(color: _textColor),
                        ),
                        subtitle: Text(
                          '${s['score']}/${s['total']} • ${s['time']}s',
                          style: TextStyle(color: _subTextColor, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
              if (_sessionHistory.isEmpty)
                Center(
                  child: Text(
                    'No sessions yet.',
                    style: TextStyle(color: _subTextColor),
                  ),
                ),

              const SizedBox(height: 16),

              // Badges
              if (_earnedBadges.isNotEmpty) ...[
                _buildSectionTitle('Earned Badges'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _earnedBadges
                      .map(
                        (b) => Chip(
                          label: Text(b, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.amber[100],
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SETTINGS VIEW (new)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSettingsView() {
    return Column(
      children: [
        _buildSecondaryAppBar('Settings', Icons.settings, QuizState.topic),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Appearance'),
              _buildSettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark',
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (v) => setState(() => _isDarkMode = v),
                ),
              ),
              _buildSettingsTile(
                icon: Icons.text_fields,
                title: 'Font Size',
                subtitle: 'Current: ${_fontSize.toInt()}px',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(
                        () => _fontSize = (_fontSize - 1).clamp(12.0, 22.0),
                      ),
                    ),
                    Text(
                      '${_fontSize.toInt()}',
                      style: TextStyle(color: _textColor),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(
                        () => _fontSize = (_fontSize + 1).clamp(12.0, 22.0),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('Quiz Behaviour'),
              _buildSettingsTile(
                icon: Icons.timer,
                title: 'Timer',
                subtitle: 'Enable countdown timer',
                trailing: Switch(
                  value: _isTimerEnabled,
                  onChanged: (v) => setState(() => _isTimerEnabled = v),
                ),
              ),
              if (_isTimerEnabled)
                _buildSettingsTile(
                  icon: Icons.timer_outlined,
                  title: 'Timer Duration',
                  subtitle: '$_timerDuration seconds per question',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(
                          () => _timerDuration = (_timerDuration - 5).clamp(
                            10,
                            120,
                          ),
                        ),
                      ),
                      Text(
                        '${_timerDuration}s',
                        style: TextStyle(color: _textColor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(
                          () => _timerDuration = (_timerDuration + 5).clamp(
                            10,
                            120,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildSettingsTile(
                icon: Icons.fast_forward,
                title: 'Auto-Advance',
                subtitle: 'Automatically go to next question',
                trailing: Switch(
                  value: _autoAdvance,
                  onChanged: (v) => setState(() => _autoAdvance = v),
                ),
              ),
              _buildSettingsTile(
                icon: Icons.check_circle_outline,
                title: 'Show Correct on Wrong',
                subtitle: 'Highlight correct answer after wrong pick',
                trailing: Switch(
                  value: _showCorrectOnWrong,
                  onChanged: (v) => setState(() => _showCorrectOnWrong = v),
                ),
              ),
              _buildSettingsTile(
                icon: Icons.shuffle,
                title: 'Shuffle Options',
                subtitle: 'Randomise answer order',
                trailing: Switch(
                  value: _shuffleOptions,
                  onChanged: (v) => setState(() => _shuffleOptions = v),
                ),
              ),
              _buildSettingsTile(
                icon: Icons.highlight,
                title: 'Highlight Keywords',
                subtitle: 'Bold key terms in questions',
                trailing: Switch(
                  value: _highlightKeywords,
                  onChanged: (v) => setState(() => _highlightKeywords = v),
                ),
              ),

              _buildSectionTitle('Accessibility'),
              _buildSettingsTile(
                icon: Icons.vibration,
                title: 'Haptic Feedback',
                subtitle: 'Vibration on interaction',
                trailing: Switch(
                  value: _hapticEnabled,
                  onChanged: (v) => setState(() => _hapticEnabled = v),
                ),
              ),
              _buildSettingsTile(
                icon: Icons.record_voice_over,
                title: 'Read Aloud',
                subtitle: 'Text-to-speech (coming soon)',
                trailing: Switch(
                  value: _readAloudEnabled,
                  onChanged: (v) => setState(() => _readAloudEnabled = v),
                ),
              ),

              _buildSectionTitle('Study Goals'),
              _buildSettingsTile(
                icon: Icons.flag,
                title: 'Daily Goal',
                subtitle: '$_dailyGoal questions per day',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(
                        () => _dailyGoal = (_dailyGoal - 5).clamp(5, 100),
                      ),
                    ),
                    Text('$_dailyGoal', style: TextStyle(color: _textColor)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(
                        () => _dailyGoal = (_dailyGoal + 5).clamp(5, 100),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LEADERBOARD VIEW (new)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildLeaderboardView() {
    final mock = [
      {'name': 'You', 'pts': _totalPoints, 'badge': '🧬'},
      {'name': 'Arjun', 'pts': 285, 'badge': '🏆'},
      {'name': 'Priya', 'pts': 230, 'badge': '🥈'},
      {'name': 'Rahul', 'pts': 190, 'badge': '🥉'},
      {'name': 'Sneha', 'pts': 145, 'badge': '⭐'},
    ]..sort((a, b) => (b['pts'] as int).compareTo(a['pts'] as int));
    return Column(
      children: [
        _buildSecondaryAppBar(
          'Leaderboard',
          Icons.leaderboard,
          QuizState.topic,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mock.length,
            itemBuilder: (ctx, i) {
              final entry = mock[i];
              final isMe = entry['name'] == 'You';
              return Card(
                color: isMe ? Colors.blue[50] : _cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: i == 0
                        ? Colors.amber
                        : (i == 1 ? Colors.grey[400] : Colors.brown[300]),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        entry['badge'] as String,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry['name'] as String,
                        style: TextStyle(
                          color: _textColor,
                          fontWeight: isMe
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isMe)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Chip(
                            label: Text('You', style: TextStyle(fontSize: 10)),
                            backgroundColor: Colors.blue,
                            labelStyle: TextStyle(color: Colors.white),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    '${entry['pts']} pts',
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // OVERLAYS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _countdownValue > 0 ? '$_countdownValue' : 'GO!',
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Get ready!',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pause_circle_filled,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quiz Paused',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isPaused = false),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DIALOGS
  // ══════════════════════════════════════════════════════════════════════════
  void _showModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Radio<bool>(
                value: true,
                groupValue: _isPracticeMode,
                onChanged: (value) {
                  _toggleMode();
                  Navigator.pop(context);
                },
              ),
              title: const Text('Practice Mode'),
              subtitle: const Text('Show explanation after each answer'),
            ),
            ListTile(
              leading: Radio<bool>(
                value: false,
                groupValue: _isPracticeMode,
                onChanged: (value) {
                  _toggleMode();
                  Navigator.pop(context);
                },
              ),
              title: const Text('Exam Mode'),
              subtitle: const Text('Show explanation only in results'),
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

  void _showQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 420,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Question Navigator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const Spacer(),
                _buildLegendDot(Colors.green, 'Correct'),
                const SizedBox(width: 10),
                _buildLegendDot(Colors.red, 'Wrong'),
                const SizedBox(width: 10),
                _buildLegendDot(Colors.grey, 'Unseen'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _currentQuestions.length,
                itemBuilder: (context, index) {
                  final isAnswered = _userAnswers[index] != null;
                  final isCurrent = index == _currentQuestionIndex;
                  final isCorrect =
                      isAnswered &&
                      _userAnswers[index] == _currentQuestions[index]['answer'];
                  final isBookmarked = _bookmarkedQuestions.contains(
                    '${_selectedTopic}_$index',
                  );

                  return GestureDetector(
                    onTap: () {
                      _jumpToQuestion(index);
                      Navigator.pop(context);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isAnswered
                                ? (isCorrect ? Colors.green : Colors.red)
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                            border: isCurrent
                                ? Border.all(color: Colors.blue, width: 3)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isAnswered
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        if (isBookmarked)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
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

  void _showTopicDetails(String topic) {
    final scores = _topicScoreHistory[topic] ?? [];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(topic),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Questions: ${quizData[topic]!.length}'),
            Text('Times played: ${scores.length}'),
            if (scores.isNotEmpty) ...[
              Text(
                'Best score: ${scores.reduce(max)}/${quizData[topic]!.length}',
              ),
              Text(
                'Average: ${(scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(1)}/${quizData[topic]!.length}',
              ),
            ],
            const SizedBox(height: 8),
            Text('Difficulty breakdown:'),
            ...['easy', 'medium', 'hard'].map((d) {
              final count = quizData[topic]!
                  .where((q) => q['difficulty'] == d)
                  .length;
              return Text('  ${d[0].toUpperCase()}${d.substring(1)}: $count');
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _selectTopic(topic);
            },
            child: const Text('Start Quiz'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSecondaryAppBar(String title, IconData icon, QuizState back) {
    return AppBar(
      backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue[700],
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _currentState = back),
          child: const Text('← Back', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: _textColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Card(
      color: _cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(title, style: TextStyle(color: _textColor, fontSize: 14)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: _subTextColor, fontSize: 12),
        ),
        trailing: trailing,
        dense: true,
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _difficultyColor(difficulty),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: _subTextColor)),
      ],
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _masteryColor(int pct) {
    if (pct >= 80) return Colors.green;
    if (pct >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _gradeColorFromPct(double pct) {
    if (pct >= 90) return Colors.green;
    if (pct >= 75) return Colors.blue;
    if (pct >= 50) return Colors.orange;
    return Colors.red;
  }
}
