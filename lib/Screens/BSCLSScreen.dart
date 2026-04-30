import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum QuizState { topic, quiz, result, review, leaderboard, settings, statistics }
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
      "options": ["I have 20 years.", "I am 20 years old.", "I feel 20 years.", "I do 20 years."],
      "answer": 1,
      "explanation": "'I am [age] years old' is the correct structure for introducing age.",
      "difficulty": "easy",
      "tags": ["self introduction", "age"],
      "keywords": ["age", "years old"],
    },
    {
      "question": "What do you say to tell someone where you live?",
      "options": ["I work New York.", "I go New York.", "I live in New York.", "I stay at New York."],
      "answer": 2,
      "explanation": "'I live in + city' is the standard way to state your residence.",
      "difficulty": "easy",
      "tags": ["self introduction", "location"],
      "keywords": ["live in", "city"],
    },
    {
      "question": "Choose the correct self-introduction:",
      "options": ["Me John.", "I is John.", "My name John.", "I am John."],
      "answer": 3,
      "explanation": "'I am + name' is a complete and correct simple sentence.",
      "difficulty": "easy",
      "tags": ["self introduction", "grammar"],
      "keywords": ["I am", "name"],
    },
    {
      "question": "What does 'I am from Canada' mean?",
      "options": ["I was born in Canada", "I like Canada", "I am going to Canada", "Canada is big"],
      "answer": 0,
      "explanation": "'I am from...' indicates your origin or nationality.",
      "difficulty": "easy",
      "tags": ["self introduction", "origin"],
      "keywords": ["from", "origin"],
    },
    {
      "question": "Which question asks for someone's occupation?",
      "options": ["What do you do?", "Where do you live?", "How old are you?", "What is your name?"],
      "answer": 0,
      "explanation": "'What do you do?' is the standard way to ask about someone's job.",
      "difficulty": "easy",
      "tags": ["self introduction", "occupation"],
      "keywords": ["occupation", "job"],
    },
    {
      "question": "Respond to: 'Nice to meet you.'",
      "options": ["I am nice.", "Nice to meet you too.", "Thank you.", "Okay."],
      "answer": 1,
      "explanation": "'Nice to meet you too' is the polite and expected response.",
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
      "question": "What do you say after stating your name in a formal setting?",
      "options": ["That's all.", "It's my pleasure to meet you.", "Call me.", "Name."],
      "answer": 1,
      "explanation": "'It's my pleasure to meet you' adds politeness after introducing yourself.",
      "difficulty": "medium",
      "tags": ["self introduction", "formal"],
      "keywords": ["pleasure", "formal"],
    },
    {
      "question": "Which is correct for introducing your family status?",
      "options": ["I live single.", "I am married.", "I do married.", "I have married."],
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
      "options": ["Short and fat", "High and thin", "Long and narrow", "Tall and thin"],
      "answer": 3,
      "explanation": "'Slim' means thin in a healthy way.",
      "difficulty": "easy",
      "tags": ["physical description", "adjectives"],
      "keywords": ["tall", "slim", "thin"],
    },
    {
      "question": "How do you ask about someone's best friend?",
      "options": ["Who is him?", "Who is your best friend?", "How best friend?", "Where best friend?"],
      "answer": 1,
      "explanation": "'Who is your best friend?' is the correct question form.",
      "difficulty": "easy",
      "tags": ["friends", "questions"],
      "keywords": ["best friend", "who"],
    },
    {
      "question": "Complete: 'My mother is very ______. She always helps others.'",
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
      "options": ["He has eyes blue.", "He blue eyes.", "He has blue eyes.", "He is blue eyes."],
      "answer": 2,
      "explanation": "The correct order is 'has + adjective + noun' — 'has blue eyes'.",
      "difficulty": "easy",
      "tags": ["descriptions", "grammar"],
      "keywords": ["has", "blue eyes"],
    },
    {
      "question": "What does 'look like' mean in 'What does your brother look like?'",
      "options": ["What is his job?", "What is his age?", "What is his appearance?", "What is his name?"],
      "answer": 2,
      "explanation": "'Look like' asks about physical appearance.",
      "difficulty": "easy",
      "tags": ["descriptions", "questions"],
      "keywords": ["look like", "appearance"],
    },
    // Daily routine conversation (21-30)
    {
      "question": "What time do most people eat breakfast?",
      "options": ["In the evening", "In the morning", "At midnight", "In the afternoon"],
      "answer": 1,
      "explanation": "Breakfast is the first meal of the day, eaten in the morning.",
      "difficulty": "easy",
      "tags": ["daily routine", "meals"],
      "keywords": ["breakfast", "morning"],
    },
    {
      "question": "Complete: 'I ______ up at 7 AM every day.'",
      "options": ["get", "wake", "stand", "rise"],
      "answer": 1,
      "explanation": "'Wake up' is the correct phrasal verb for ending sleep.",
      "difficulty": "easy",
      "tags": ["daily routine", "verbs"],
      "keywords": ["wake up"],
    },
    {
      "question": "What do you say after finishing work?",
      "options": ["I start work.", "I go to work.", "I finish work.", "I sleep work."],
      "answer": 2,
      "explanation": "'I finish work' means your workday ends.",
      "difficulty": "easy",
      "tags": ["daily routine", "work"],
      "keywords": ["finish work"],
    },
    {
      "question": "Choose the correct question for bedtime:",
      "options": ["When do you go to school?", "When do you go to bed?", "When do you eat?", "When do you play?"],
      "answer": 1,
      "explanation": "'Go to bed' means to lie down and sleep.",
      "difficulty": "easy",
      "tags": ["daily routine", "sleep"],
      "keywords": ["go to bed", "sleep"],
    },
    {
      "question": "What is a typical evening activity?",
      "options": ["Eat breakfast", "Watch TV", "Go to school", "Take a shower in the morning"],
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
      "explanation": "'Go home' is the most natural phrase (not 'come home' unless speaking from home).",
      "difficulty": "easy",
      "tags": ["daily routine", "home"],
      "keywords": ["go home"],
    },
    {
      "question": "How do you ask about someone's daily schedule?",
      "options": ["What is your day?", "How is your routine?", "What do you usually do in a day?", "When day?"],
      "answer": 2,
      "explanation": "'What do you usually do in a day?' is a clear and natural question.",
      "difficulty": "easy",
      "tags": ["daily routine", "questions"],
      "keywords": ["usually", "daily"],
    },
    {
      "question": "Which is a morning routine activity?",
      "options": ["Brush teeth", "Eat dinner", "Watch news at 10 PM", "Sleep"],
      "answer": 0,
      "explanation": "Brushing teeth is typically done in the morning (and night).",
      "difficulty": "easy",
      "tags": ["daily routine", "morning"],
      "keywords": ["brush teeth", "morning"],
    },
    {
      "question": "What does 'I have lunch at noon' mean?",
      "options": ["I eat lunch at 12 PM", "I skip lunch", "I eat lunch at night", "I cook lunch"],
      "answer": 0,
      "explanation": "'Noon' means 12:00 in the daytime.",
      "difficulty": "easy",
      "tags": ["daily routine", "time"],
      "keywords": ["lunch", "noon"],
    },
    {
      "question": "Respond to: 'What time do you get home?'",
      "options": ["Yes, I do.", "I get home at 6 PM.", "Home is nice.", "At morning."],
      "answer": 1,
      "explanation": "The answer should state the specific time you arrive home.",
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
      "options": ["A family member", "Someone who lives near you", "A shopkeeper", "A teacher"],
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
      "explanation": "'Near' means close to. 'Behind of' is incorrect (just 'behind').",
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
      "explanation": "The kitchen is designed for cooking and food preparation.",
      "difficulty": "easy",
      "tags": ["home", "rooms"],
      "keywords": ["kitchen", "cook"],
    },
    {
      "question": "What does 'downtown' mean?",
      "options": ["Outside the city", "The central business area", "Near a farm", "Under a bridge"],
      "answer": 1,
      "explanation": "'Downtown' refers to the main commercial center of a city.",
      "difficulty": "medium",
      "tags": ["neighborhood", "vocabulary"],
      "keywords": ["downtown", "city center"],
    },
    {
      "question": "Choose the correct sentence about a quiet street:",
      "options": ["There are many cars every minute.", "There is no noise.", "The street has concerts daily.", "People shout all day."],
      "answer": 1,
      "explanation": "A quiet street has little or no noise.",
      "difficulty": "easy",
      "tags": ["neighborhood", "description"],
      "keywords": ["quiet", "noise"],
    },
    {
      "question": "What is a 'balcony'?",
      "options": ["A type of door", "A platform outside a building", "A roof", "A basement"],
      "answer": 1,
      "explanation": "A balcony is an outdoor platform projecting from a wall.",
      "difficulty": "easy",
      "tags": ["home", "parts"],
      "keywords": ["balcony", "platform"],
    },
    {
      "question": "Complete: 'Turn left at the ______ and you will see my house.'",
      "options": ["corner", "inside", "table", "bed"],
      "answer": 0,
      "explanation": "A corner (of a street) is a common landmark for directions.",
      "difficulty": "easy",
      "tags": ["neighborhood", "directions"],
      "keywords": ["corner", "turn left"],
    },
    {
      "question": "What is the ground floor?",
      "options": ["The top floor", "The floor at street level", "The basement", "The roof"],
      "answer": 1,
      "explanation": "The ground floor is the floor at the same level as the outside ground.",
      "difficulty": "easy",
      "tags": ["home", "floors"],
      "keywords": ["ground floor", "street level"],
    },
    // School and classroom communication (41-50)
    {
      "question": "What do you say to ask for permission to enter the classroom?",
      "options": ["Close the door.", "May I come in?", "Sit down.", "Open window."],
      "answer": 1,
      "explanation": "'May I come in?' is a polite request for permission.",
      "difficulty": "easy",
      "tags": ["school", "permission"],
      "keywords": ["may I", "come in"],
    },
    {
      "question": "Complete: 'I don't understand. Can you ______ that, please?'",
      "options": ["stop", "repeat", "close", "write down"],
      "answer": 1,
      "explanation": "'Repeat' means to say again.",
      "difficulty": "easy",
      "tags": ["school", "classroom"],
      "keywords": ["repeat", "understand"],
    },
    {
      "question": "What is a 'whiteboard' used for?",
      "options": ["Eating lunch", "Writing with markers", "Playing football", "Sleeping"],
      "answer": 1,
      "explanation": "A whiteboard is a glossy surface for writing with dry-erase markers.",
      "difficulty": "easy",
      "tags": ["school", "objects"],
      "keywords": ["whiteboard", "markers"],
    },
    {
      "question": "How do you ask about today's homework?",
      "options": ["What is lunch?", "Where is the teacher?", "What is the homework for today?", "When is break?"],
      "answer": 2,
      "explanation": "'What is the homework for today?' directly asks for assignments.",
      "difficulty": "easy",
      "tags": ["school", "homework"],
      "keywords": ["homework", "today"],
    },
    {
      "question": "Choose the polite way to ask a classmate for a pen:",
      "options": ["Give me pen.", "Pen me.", "Can I borrow your pen, please?", "You give pen."],
      "answer": 2,
      "explanation": "'Can I borrow... please?' is polite and grammatically correct.",
      "difficulty": "easy",
      "tags": ["school", "requests"],
      "keywords": ["borrow", "please"],
    },
    {
      "question": "What does 'Turn to page 10' mean?",
      "options": ["Close the book", "Open the book to page 10", "Throw the book", "Draw page 10"],
      "answer": 1,
      "explanation": "'Turn to page X' means open your book to that specific page.",
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
      "options": ["A type of desk", "Someone who sits next to you", "A cleaning tool", "A subject"],
      "answer": 1,
      "explanation": "Your deskmate is the classmate who shares the same desk or sits beside you.",
      "difficulty": "easy",
      "tags": ["school", "vocabulary"],
      "keywords": ["deskmate", "sits next to"],
    },
    // Basic Speaking Skills: Likes and dislikes expressions (51-60)
    {
      "question": "How do you say you enjoy something?",
      "options": ["I hate it.", "I like it.", "It's terrible.", "I don't want it."],
      "answer": 1,
      "explanation": "'I like it' is the simplest positive expression of enjoyment.",
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
      "question": "What is a stronger way to say you like something very much?",
      "options": ["I hate it.", "I don't mind it.", "I love it.", "It's okay."],
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
      "explanation": "'It's okay' expresses neither strong like nor strong dislike.",
      "difficulty": "easy",
      "tags": ["expressions", "neutral"],
      "keywords": ["okay", "neutral"],
    },
    {
      "question": "How do you ask someone about their preference?",
      "options": ["Do you like pizza?", "Pizza good?", "Like pizza you?", "You pizza want?"],
      "answer": 0,
      "explanation": "'Do you like...?' is the standard question for preferences.",
      "difficulty": "easy",
      "tags": ["likes", "questions"],
      "keywords": ["do you like", "preferences"],
    },
    {
      "question": "Complete: 'I don't ______ horror movies because they scare me.'",
      "options": ["hate", "like", "enjoy", "prefer"],
      "answer": 2,
      "explanation": "'Don't enjoy' is a softer way to say you dislike something.",
      "difficulty": "medium",
      "tags": ["dislikes", "expressions"],
      "keywords": ["don't enjoy", "horror"],
    },
    {
      "question": "What does 'I prefer tea to coffee' mean?",
      "options": ["I like both equally", "I like tea more than coffee", "I like coffee more than tea", "I hate both"],
      "answer": 1,
      "explanation": "'Prefer A to B' means you like A more than B.",
      "difficulty": "medium",
      "tags": ["likes", "preferences"],
      "keywords": ["prefer", "more than"],
    },
    {
      "question": "Respond to: 'Do you like classical music?' (Say you love it)",
      "options": ["No.", "Yes, I love it.", "Maybe.", "Not really."],
      "answer": 1,
      "explanation": "'Yes, I love it' directly answers the question with enthusiasm.",
      "difficulty": "easy",
      "tags": ["likes", "responses"],
      "keywords": ["love it", "response"],
    },
    {
      "question": "Choose the phrase that means 'to enjoy very little':",
      "options": ["I'm crazy about it.", "I'm not very fond of it.", "I adore it.", "I'm passionate about it."],
      "answer": 1,
      "explanation": "'Not very fond of it' means mild dislike or very little enjoyment.",
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
      "explanation": "'Why?', 'What for?', and 'How come?' all ask for a reason.",
      "difficulty": "easy",
      "tags": ["questions", "reason"],
      "keywords": ["why", "reason"],
    },
    {
      "question": "Answer: 'How are you?'",
      "options": ["I am fine, thanks.", "Yes, I am.", "I am John.", "At home."],
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
      "options": ["Who did it?", "How did you do it?", "Where is it?", "When did it happen?"],
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
      "explanation": "Positive statement → negative tag: 'do' becomes 'don't you'.",
      "difficulty": "medium",
      "tags": ["questions", "tag questions"],
      "keywords": ["tag question", "don't you"],
    },
    {
      "question": "Choose the indirect question:",
      "options": ["Where is the bank?", "Can you tell me where the bank is?", "Bank where?", "Where bank?"],
      "answer": 1,
      "explanation": "'Can you tell me where the bank is?' is indirect and more polite.",
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
      "explanation": "'What do you mean?' asks the speaker to explain or clarify.",
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
      "options": ["I like apples but bananas.", "I like apples or bananas.", "I like apples and bananas.", "I like apples so bananas."],
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
      "options": ["Stand up", "Leave the room", "Take a seat", "Raise your hand"],
      "answer": 2,
      "explanation": "'Sit down' means to move from standing to sitting on a chair.",
      "difficulty": "easy",
      "tags": ["instructions", "classroom"],
      "keywords": ["sit down", "take a seat"],
    },
    {
      "question": "Complete the instruction: '______ your name at the top of the paper.'",
      "options": ["Draw", "Write", "Read", "Erase"],
      "answer": 1,
      "explanation": "'Write your name' is the correct verb for putting text on paper.",
      "difficulty": "easy",
      "tags": ["instructions", "writing"],
      "keywords": ["write", "name"],
    },
    {
      "question": "What does 'Wait a moment' mean?",
      "options": ["Leave now", "Be patient for a short time", "Run fast", "Speak loudly"],
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
      "explanation": "'Here you are' is the polite response when handing something over.",
      "difficulty": "easy",
      "tags": ["instructions", "responses"],
      "keywords": ["pass", "here you are"],
    },
    {
      "question": "What should you do if an instruction says 'Turn off your phone'?",
      "options": ["Call someone", "Power down your phone", "Hide your phone", "Turn up volume"],
      "answer": 1,
      "explanation": "'Turn off' means to power down or switch off a device.",
      "difficulty": "easy",
      "tags": ["instructions", "devices"],
      "keywords": ["turn off", "phone"],
    },
    // Polite conversation and requesting help (81-85)
    {
      "question": "Which phrase is most polite to ask for help?",
      "options": ["Help me.", "Could you help me, please?", "I need help now.", "You help."],
      "answer": 1,
      "explanation": "'Could you help me, please?' uses a polite modal and 'please'.",
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
      "explanation": "'Would you mind...?' is a very polite way to make a request.",
      "difficulty": "medium",
      "tags": ["polite", "requests"],
      "keywords": ["would you mind", "polite request"],
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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
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
    final correctAnswer = _currentQuestions[_currentQuestionIndex]['answer'] as int;
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
    if (_sessionHistory.length >= 3 && !_earnedBadges.contains('📚 3 Quizzes')) {
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
        topics.sort((a, b) =>
            quizData[b]!.length.compareTo(quizData[a]!.length));
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
    if (_searchQuery.isEmpty) return _sortedTopics.map((t) => {'topic': t}).toList();
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
  Color get _subTextColor =>
      _isDarkMode ? Colors.white60 : Colors.black54;
  Color get _cardColor =>
      _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;

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
      backgroundColor:
          _isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue[700],
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
          ]
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
            onPressed: () =>
                setState(() => _currentState = QuizState.settings),
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
              )
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
                    child: const Icon(Icons.science, size: 28, color: Colors.blue),
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
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Text('Practice', style: TextStyle(color: Colors.white70, fontSize: 11)),
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
                      const Text('Daily Goal', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('$_questionsToday/$_dailyGoal', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_questionsToday / _dailyGoal).clamp(0.0, 1.0),
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          .map((b) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Chip(
                                  label: Text(b, style: const TextStyle(fontSize: 10)),
                                  backgroundColor: Colors.amber[100],
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                              ))
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
                  const PopupMenuItem(value: SortOrder.alphabetical, child: Text('A–Z')),
                  const PopupMenuItem(value: SortOrder.questionCount, child: Text('Most Questions')),
                  const PopupMenuItem(value: SortOrder.difficulty, child: Text('Hardest First')),
                  const PopupMenuItem(value: SortOrder.recent, child: Text('Recent')),
                ],
              ),
              // Difficulty filter
              PopupMenuButton<Difficulty>(
                icon: Icon(Icons.filter_list, color: _subTextColor),
                tooltip: 'Difficulty',
                onSelected: (d) => setState(() => _selectedDifficulty = d),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: Difficulty.mixed, child: Text('All Levels')),
                  const PopupMenuItem(value: Difficulty.easy, child: Text('Easy')),
                  const PopupMenuItem(value: Difficulty.medium, child: Text('Medium')),
                  const PopupMenuItem(value: Difficulty.hard, child: Text('Hard')),
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
    final colors = _topicColors[topic] ??
        [Colors.blue[400]!, Colors.green[400]!];
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
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '🔥 $_currentStreak',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange[800]),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  '${((_currentQuestionIndex + 1) / _currentQuestions.length * 100).toInt()}%',
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_currentQuestionIndex + 1) /
                                _currentQuestions.length,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green),
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
                  ...((question['tags'] as List<dynamic>? ?? []).take(2).map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Chip(
                            label: Text(t.toString(), style: const TextStyle(fontSize: 10)),
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
                        minWidth: 32, minHeight: 32),
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
                    Expanded(flex: 3, child: _buildOptionsList(question, isTablet)),
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
                  color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
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
                        color: _textColor),
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
            color: _textColor),
      );
    }
    // Simple highlight: bold keywords
    final spans = <TextSpan>[];
    String remaining = text;
    for (final kw in keywords) {
      final idx = remaining.toLowerCase().indexOf(kw.toLowerCase());
      if (idx >= 0) {
        if (idx > 0) spans.add(TextSpan(text: remaining.substring(0, idx)));
        spans.add(TextSpan(
          text: remaining.substring(idx, idx + kw.length),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
            backgroundColor: Colors.blue[50],
          ),
        ));
        remaining = remaining.substring(idx + kw.length);
      }
    }
    if (remaining.isNotEmpty) spans.add(TextSpan(text: remaining));
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: _fontSize + 2,
            fontWeight: FontWeight.w600,
            color: _textColor),
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
                border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
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
                    Text('Explanation',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
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
          Text('How confident were you?',
              style: TextStyle(
                  color: _subTextColor, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              final selected =
                  _confidenceRatings[_currentQuestionIndex] == i + 1;
              return GestureDetector(
                onTap: () => setState(() =>
                    _confidenceRatings[_currentQuestionIndex] = i + 1),
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
        prefixIcon: Icon(Icons.note_add_outlined, color: _subTextColor, size: 18),
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: (v) => setState(
          () => _questionNotes[_currentQuestionIndex] = v),
      controller: TextEditingController(
          text: _questionNotes[_currentQuestionIndex] ?? ''),
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
                backgroundColor: _isDarkMode ? Colors.grey[700] : Colors.grey[300],
                foregroundColor: _isDarkMode ? Colors.white : Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            child: Text('Skip', style: TextStyle(fontSize: 13, color: _subTextColor)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
    bool showCorrect = _showCorrectOnWrong &&
        !_isPracticeMode &&
        _selectedOption != null &&
        index == correctAnswer &&
        !isSelected;

    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = isCorrect
          ? Colors.green[100]
          : Colors.red[100];
    } else if (showCorrect || (_isPracticeMode && _selectedOption != null && index == correctAnswer && !isSelected)) {
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
                      : (showCorrect
                          ? Colors.green[100]
                          : Colors.grey[200]),
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
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                  const Icon(Icons.assignment_turned_in, size: 56, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Quiz Complete!',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    _gradeLabel,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
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
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
              _buildStatCard('⏱️ Time', '${minutes}m ${seconds}s', Colors.purple),
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
                  Colors.green),
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
              child: Text('Badges',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _textColor)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _earnedBadges
                  .map((b) => Chip(
                        label: Text(b, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.amber[100],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Question summary
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Question Summary',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textColor)),
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
                            fontSize: 11),
                      ),
                      const Text(' • ', style: TextStyle(fontSize: 11)),
                      Text('${qTime}s',
                          style: TextStyle(
                              color: _subTextColor, fontSize: 11)),
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
                                color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _currentQuestions[index]['explanation'] as String,
                            style: TextStyle(color: _subTextColor, fontSize: 13),
                          ),
                          if (_questionNotes[index] != null &&
                              _questionNotes[index]!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.note, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text('Note: ${_questionNotes[index]}',
                                    style: const TextStyle(
                                        color: Colors.blue, fontSize: 12)),
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
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
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
                    borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  isCorrect ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCorrect ? '✓ Correct' : '✗ Wrong',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildDifficultyChip(q['difficulty'] as String),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(q['question'] as String,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _textColor,
                              fontSize: _fontSize)),
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
                              horizontal: 12, vertical: 10),
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
                                    color: _textColor),
                              ),
                              Expanded(
                                child: Text(opts[j] as String,
                                    style: TextStyle(color: _textColor, fontSize: 13)),
                              ),
                              if (isRight)
                                const Icon(Icons.check, color: Colors.green, size: 16),
                              if (isOpt && !isRight)
                                const Icon(Icons.close, color: Colors.red, size: 16),
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
                  _buildStatCard('Total Points', '$_totalPoints pts', Colors.amber),
                  const SizedBox(width: 10),
                  _buildStatCard('Best Streak', '$_bestStreak', Colors.orange),
                  const SizedBox(width: 10),
                  _buildStatCard('Quizzes', '${_sessionHistory.length}', Colors.blue),
                ],
              ),
              const SizedBox(height: 16),

              // Daily goal
              _buildSectionTitle('Today\'s Progress'),
              Card(
                color: _cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Daily Goal: $_dailyGoal questions',
                              style: TextStyle(color: _textColor)),
                          Text('Done: $_questionsToday',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (_questionsToday / _dailyGoal).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green),
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
              ..._topicMastery.entries.map((e) => Card(
                    color: _cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key,
                                  style: TextStyle(
                                      color: _textColor,
                                      fontWeight: FontWeight.w600)),
                              Text('${e.value}%',
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: e.value / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_masteryColor(e.value)),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              if (_topicMastery.isEmpty)
                Center(
                  child: Text('Complete quizzes to see mastery stats.',
                      style: TextStyle(color: _subTextColor)),
                ),
              const SizedBox(height: 16),

              // Session history
              _buildSectionTitle('Session History'),
              ..._sessionHistory.reversed.take(5).map((s) => Card(
                    color: _cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _gradeColorFromPct(s['score'] / s['total'] * 100),
                        child: Text(
                          '${(s['score'] / s['total'] * 100).toInt()}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(s['topic'] as String,
                          style: TextStyle(color: _textColor)),
                      subtitle: Text(
                          '${s['score']}/${s['total']} • ${s['time']}s',
                          style: TextStyle(color: _subTextColor, fontSize: 12)),
                    ),
                  )),
              if (_sessionHistory.isEmpty)
                Center(
                  child: Text('No sessions yet.',
                      style: TextStyle(color: _subTextColor)),
                ),

              const SizedBox(height: 16),

              // Badges
              if (_earnedBadges.isNotEmpty) ...[
                _buildSectionTitle('Earned Badges'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _earnedBadges
                      .map((b) => Chip(
                            label: Text(b, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.amber[100],
                          ))
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
                      onPressed: () => setState(() => _fontSize = (_fontSize - 1).clamp(12.0, 22.0)),
                    ),
                    Text('${_fontSize.toInt()}', style: TextStyle(color: _textColor)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _fontSize = (_fontSize + 1).clamp(12.0, 22.0)),
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
                        onPressed: () => setState(() =>
                            _timerDuration = (_timerDuration - 5).clamp(10, 120)),
                      ),
                      Text('${_timerDuration}s',
                          style: TextStyle(color: _textColor)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() =>
                            _timerDuration = (_timerDuration + 5).clamp(10, 120)),
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
                      onPressed: () =>
                          setState(() => _dailyGoal = (_dailyGoal - 5).clamp(5, 100)),
                    ),
                    Text('$_dailyGoal', style: TextStyle(color: _textColor)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () =>
                          setState(() => _dailyGoal = (_dailyGoal + 5).clamp(5, 100)),
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
        _buildSecondaryAppBar('Leaderboard', Icons.leaderboard, QuizState.topic),
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
                    borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        i == 0 ? Colors.amber : (i == 1 ? Colors.grey[400] : Colors.brown[300]),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(entry['badge'] as String,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(entry['name'] as String,
                          style: TextStyle(
                              color: _textColor,
                              fontWeight:
                                  isMe ? FontWeight.bold : FontWeight.normal)),
                      if (isMe)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Chip(
                            label: Text('You',
                                style: TextStyle(fontSize: 10)),
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
                        color: Colors.amber[700], fontWeight: FontWeight.bold),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pause_circle_filled, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                const Text('Quiz Paused',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isPaused = false),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
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
                      color: _textColor),
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
                  final isCorrect = isAnswered &&
                      _userAnswers[index] ==
                          _currentQuestions[index]['answer'];
                  final isBookmarked = _bookmarkedQuestions
                      .contains('${_selectedTopic}_$index');

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
                                color: isAnswered ? Colors.white : Colors.black87,
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
              Text('Best score: ${scores.reduce(max)}/${quizData[topic]!.length}'),
              Text('Average: ${(scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(1)}/${quizData[topic]!.length}'),
            ],
            const SizedBox(height: 8),
            Text('Difficulty breakdown:'),
            ...['easy', 'medium', 'hard'].map((d) {
              final count = quizData[topic]!.where((q) => q['difficulty'] == d).length;
              return Text('  ${d[0].toUpperCase()}${d.substring(1)}: $count');
            }),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
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
      backgroundColor:
          _isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue[700],
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
        subtitle: Text(subtitle,
            style: TextStyle(color: _subTextColor, fontSize: 12)),
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
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
      case 'easy': return Colors.green;
      case 'medium': return Colors.orange;
      case 'hard': return Colors.red;
      default: return Colors.grey;
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