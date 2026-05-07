import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  bool _isTyping = false;

  late AnimationController _logoAnimController;
  late AnimationController _pulseController;
  late AnimationController _typingController;
  late Animation<double> _logoRotation;
  late Animation<double> _logoPulse;
  late Animation<double> _typingAnim;

  final String apiUrl = "https://192.168.232.91:8002";

  // Color palette — deep navy + gold accent
  static const Color _bg = Color(0xFF0D1117);
  static const Color _surface = Color(0xFF161B22);
  static const Color _surfaceAlt = Color(0xFF1C2333);
  static const Color _accent = Color(0xFFF0A500);
  static const Color _accentLight = Color(0xFFFFD166);
  static const Color _userBubble = Color(0xFF1F4E79);
  static const Color _aiBubble = Color(0xFF1C2333);
  static const Color _textPrimary = Color(0xFFE6EDF3);
  static const Color _textSecondary = Color(0xFF8B949E);
  static const Color _inputBg = Color(0xFF21262D);
  static const Color _border = Color(0xFF30363D);

  @override
  void initState() {
    super.initState();

    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _logoRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _logoAnimController, curve: Curves.linear),
    );

    _logoPulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _typingAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      setState(() => _isTyping = _controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _logoAnimController.dispose();
    _pulseController.dispose();
    _typingController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    HapticFeedback.lightImpact();

    setState(() {
      _messages.add({
        "role": "user",
        "text": text,
        "timestamp": DateTime.now(),
      });
      _loading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _messages.add({
            "role": "ai",
            "text": data["reply"],
            "timestamp": DateTime.now(),
          });
        });
      } else {
        _addError("Server error ${res.statusCode}");
      }
    } catch (e) {
      _addError("Unable to connect. Please check your network.");
    }

    setState(() => _loading = false);
    _scrollToBottom();
    _focusNode.requestFocus();
  }

  void _addError(String msg) {
    setState(() {
      _messages.add({
        "role": "ai",
        "text": msg,
        "timestamp": DateTime.now(),
        "isError": true,
      });
    });
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoAnimController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _loading ? _logoPulse.value : 1.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              Transform.rotate(
                angle: _logoRotation.value,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _accent.withOpacity(0.3),
                      width: 1.5,
                    ),
                    gradient: SweepGradient(
                      colors: [
                        _accent.withOpacity(0.0),
                        _accent.withOpacity(0.6),
                        _accent.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Inner static ring
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _surface,
                  border: Border.all(color: _accent.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.25),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/Logoes/Logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.auto_awesome,
                      color: _accent,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Transform.scale(
              scale: 0.95 + 0.05 * _logoPulse.value,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accent.withOpacity(0.15),
                      _accent.withOpacity(0.0),
                    ],
                  ),
                  border: Border.all(
                    color: _accent.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/Logoes/Logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome,
                        color: _accent,
                        size: 42,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "BEEDI College AI",
            style: TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your intelligent campus assistant",
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 32),
          _buildSuggestionChips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      "📅  Exam Schedule",
      "📚  Course Info",
      "🎓  Admissions",
      "📞  Contact Faculty",
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: suggestions.map((s) {
        return GestureDetector(
          onTap: () {
            _controller.text = s.substring(3).trim();
            _sendMessage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _surfaceAlt,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Text(
              s,
              style: const TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    final isUser = msg["role"] == "user";
    final isError = msg["isError"] == true;
    final time = msg["timestamp"] as DateTime?;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(isUser ? 30 * (1 - value) : -30 * (1 - value), 0),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _surfaceAlt,
                  border: Border.all(
                    color: isError
                        ? Colors.redAccent.withOpacity(0.5)
                        : _accent.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/Logoes/Logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        isError ? Icons.error_outline : Icons.auto_awesome,
                        color: isError ? Colors.redAccent : _accent,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? _userBubble
                          : isError
                          ? const Color(0xFF2D1B1B)
                          : _aiBubble,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                      border: Border.all(
                        color: isUser
                            ? Colors.white.withOpacity(0.08)
                            : isError
                            ? Colors.redAccent.withOpacity(0.3)
                            : _border,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isUser
                              ? _userBubble.withOpacity(0.3)
                              : Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      gradient: isUser
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1F4E79),
                                const Color(0xFF163B5C),
                              ],
                            )
                          : null,
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: TextStyle(
                        color: isError ? Colors.redAccent[100] : _textPrimary,
                        fontSize: 14.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (time != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                      child: Text(
                        _formatTime(time),
                        style: TextStyle(
                          color: _textSecondary.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isUser) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _surfaceAlt,
              border: Border.all(color: _accent.withOpacity(0.4), width: 1),
            ),
            child: const Icon(Icons.auto_awesome, color: _accent, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _aiBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: _border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _typingController,
                  builder: (_, __) {
                    final delay = i * 0.25;
                    final t = (_typingController.value - delay).clamp(0.0, 1.0);
                    final scale = 0.6 + 0.4 * math.sin(t * math.pi);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accent.withOpacity(0.4 + 0.6 * scale),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _border, width: 1)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isTyping ? _accent.withOpacity(0.5) : _border,
                  width: 1,
                ),
                boxShadow: _isTyping
                    ? [
                        BoxShadow(
                          color: _accent.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      !HardwareKeyboard.instance.isShiftPressed) {
                    _sendMessage();
                  }
                },
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(color: _textPrimary, fontSize: 15),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: "Ask BEEDI AI anything...",
                    hintStyle: TextStyle(
                      color: _textSecondary.withOpacity(0.6),
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _isTyping && !_loading
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_accent, _accentLight],
                    )
                  : null,
              color: _isTyping && !_loading ? null : _surfaceAlt,
              boxShadow: _isTyping && !_loading
                  ? [
                      BoxShadow(
                        color: _accent.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _loading ? null : _sendMessage,
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _accent,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: _isTyping ? Colors.black87 : _textSecondary,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
        leadingWidth: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildLogo(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "BEEDI College AI",
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _loading ? _accent : const Color(0xFF3FB950),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_loading
                                            ? _accent
                                            : const Color(0xFF3FB950))
                                        .withOpacity(0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _loading ? "Thinking..." : "Online",
                          style: TextStyle(color: _textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: _textSecondary),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty && !_loading
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      itemCount: _messages.length + (_loading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _loading) {
                          return _buildTypingIndicator();
                        }
                        return _buildBubble(_messages[index]);
                      },
                    ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }
}
