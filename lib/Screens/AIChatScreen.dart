import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════
//  THEME & CONSTANTS
// ═══════════════════════════════════════════════════════════════
class _C {
  static const bg0 = Color(0xFF010812);
  static const bg1 = Color(0xFF051428);
  static const bg2 = Color(0xFF082040);
  static const cyan = Color(0xFF00E5FF);
  static const cyanDim = Color(0xFF00B8CC);
  static const blue = Color(0xFF1565C0);
  static const purple = Color(0xFF7B2FBE);
  static const neonGreen = Color(0xFF00FFB3);
  static const neonPink = Color(0xFFFF006E);
  static const surface = Color(0x14FFFFFF);
  static const surfaceBorder = Color(0x1AFFFFFF);

  static final r28 = BorderRadius.circular(28);
  static final r22 = BorderRadius.circular(22);
  static final r16 = BorderRadius.circular(16);
  static final r12 = BorderRadius.circular(12);

  static TextStyle mono({
    double size = 12,
    Color color = Colors.white,
    double spacing = 1.5,
    FontWeight weight = FontWeight.normal,
  }) => GoogleFonts.spaceMono(
    fontSize: size,
    color: color,
    letterSpacing: spacing,
    fontWeight: weight,
  );

  static TextStyle body({
    double size = 15,
    Color color = Colors.white,
    double height = 1.6,
    FontWeight weight = FontWeight.normal,
  }) => GoogleFonts.inter(
    fontSize: size,
    color: color,
    height: height,
    fontWeight: weight,
  );

  static TextStyle display({
    double size = 22,
    Color color = Colors.white,
    FontWeight weight = FontWeight.bold,
    double spacing = 1.0,
  }) => GoogleFonts.exo2(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: spacing,
  );
}

// ═══════════════════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════════════════
class ChatMessage {
  final String role;
  final String text;
  final DateTime timestamp;
  final String id;
  bool isAnimated;

  ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
    String? id,
    this.isAnimated = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'role': role,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'id': id,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'],
    text: json['text'],
    timestamp: DateTime.parse(json['timestamp']),
    id: json['id'],
    isAnimated: true,
  );
}

class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  ChatSession({
    String? id,
    required this.title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       messages = messages ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'],
    title: json['title'],
    messages: (json['messages'] as List)
        .map((m) => ChatMessage.fromJson(m))
        .toList(),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

// ═══════════════════════════════════════════════════════════════
//  CHAT HISTORY MANAGER
// ═══════════════════════════════════════════════════════════════
class ChatHistoryManager {
  static const _key = 'beedi_ai_sessions';

  static Future<List<ChatSession>> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.map((s) => ChatSession.fromJson(s)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSessions(List<ChatSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(sessions.map((s) => s.toJson()).toList()),
      );
    } catch (_) {}
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

// ═══════════════════════════════════════════════════════════════
//  PARTICLE DATA
// ═══════════════════════════════════════════════════════════════
class _Particle {
  double x, y, vx, vy, radius, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
  });
}

// ═══════════════════════════════════════════════════════════════
//  NEURAL NETWORK PAINTER
// ═══════════════════════════════════════════════════════════════
class _NeuralPainter extends CustomPainter {
  final List<_Particle> particles;
  final double tick;

  _NeuralPainter(this.particles, this.tick);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()..style = PaintingStyle.stroke;

    final positions = particles.map((p) {
      return Offset(
        (p.x + p.vx * tick) % size.width,
        (p.y + p.vy * tick) % size.height,
      );
    }).toList();

    // Draw connection lines
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        final d = (positions[i] - positions[j]).distance;
        if (d < 120) {
          final opacity = (1 - d / 120) * 0.15;
          linePaint
            ..color = _C.cyan.withOpacity(opacity)
            ..strokeWidth = 0.5;
          canvas.drawLine(positions[i], positions[j], linePaint);
        }
      }
    }

    // Draw particles
    for (int i = 0; i < particles.length; i++) {
      paint.color = _C.cyan.withOpacity(particles[i].opacity * 0.7);
      canvas.drawCircle(positions[i], particles[i].radius, paint);
    }
  }

  @override
  bool shouldRepaint(_NeuralPainter old) => true;
}

// ═══════════════════════════════════════════════════════════════
//  CYBER GRID PAINTER
// ═══════════════════════════════════════════════════════════════
class _GridPainter extends CustomPainter {
  final double animation;

  _GridPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _C.cyan.withOpacity(0.04)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 60.0;
    final offset = (animation * spacing) % spacing;

    for (double x = -spacing + offset; x < size.width + spacing; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (
      double y = -spacing + offset;
      y < size.height + spacing;
      y += spacing
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.animation != animation;
}

// ═══════════════════════════════════════════════════════════════
//  AI ORB PAINTER
// ═══════════════════════════════════════════════════════════════
class _OrbPainter extends CustomPainter {
  final double pulse;
  final double wave;
  final bool active;

  _OrbPainter({required this.pulse, required this.wave, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseR = size.width * 0.28;

    if (active) {
      for (int i = 0; i < 4; i++) {
        final r = baseR + 12 + i * 16 + wave * 12;
        final opacity = (1.0 - (i * 0.25) - wave * 0.4).clamp(0.0, 0.45);
        canvas.drawCircle(
          center,
          r,
          Paint()
            ..color = _C.cyan.withOpacity(opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }

    // Purple outer glow
    canvas.drawCircle(
      center,
      baseR + 18 + pulse * 8,
      Paint()
        ..color = _C.purple.withOpacity(0.12 + pulse * 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    // Cyan glow
    canvas.drawCircle(
      center,
      baseR + 10 + pulse * 6,
      Paint()
        ..color = _C.cyan.withOpacity(0.18 + pulse * 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // Core gradient
    canvas.drawCircle(
      center,
      baseR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _C.cyan.withOpacity(0.95),
            _C.cyanDim.withOpacity(0.7),
            _C.purple.withOpacity(0.5),
            _C.blue.withOpacity(0.3),
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: baseR)),
    );

    // Hexagonal ring
    final hexPaint = Paint()
      ..color = Colors.white.withOpacity(0.1 + pulse * 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    _drawHexagon(canvas, center, baseR * 1.12, hexPaint);

    // Inner bright spot
    canvas.drawCircle(
      center - const Offset(7, 7),
      baseR * 0.28,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.pulse != pulse || old.wave != wave || old.active != active;
}

// ═══════════════════════════════════════════════════════════════
//  TYPING DOTS
// ═══════════════════════════════════════════════════════════════
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = ((_ctrl.value - i * 0.2).clamp(0.0, 1.0));
          final bounce = math.sin(t * math.pi);
          return Transform.translate(
            offset: Offset(0, -7 * bounce),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.cyan.withOpacity(0.4 + 0.6 * bounce),
                boxShadow: [
                  BoxShadow(
                    color: _C.cyan.withOpacity(0.6 * bounce),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  GLASS CARD
// ═══════════════════════════════════════════════════════════════
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? radius;
  final Color? borderColor;
  final double blur;
  final Gradient? gradient;

  const _GlassCard({
    required this.child,
    this.padding,
    this.radius,
    this.borderColor,
    this.blur = 20,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius ?? _C.r28,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient:
                gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
            borderRadius: radius ?? _C.r28,
            border: Border.all(
              color: borderColor ?? _C.surfaceBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SNACKBAR
// ═══════════════════════════════════════════════════════════════
void _showSnack(BuildContext context, String msg, {bool success = true}) {
  final color = success ? _C.cyan : Colors.orangeAccent;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg, style: _C.body(color: Colors.white, size: 13)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0D1F35),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: _C.r16,
        side: BorderSide(color: color.withOpacity(0.5)),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  SHIMMER BUBBLE
// ═══════════════════════════════════════════════════════════════
class _ShimmerBubble extends StatelessWidget {
  const _ShimmerBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.06),
        highlightColor: _C.cyan.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [240.0, 180.0, 120.0].map((w) {
            return Container(
              height: 11,
              width: w,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final Function(String) onSuggestion;

  const _EmptyState({required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      '🧠  Explain quantum computing',
      '💻  Write a Python script',
      '📝  Summarise a topic',
      '🔬  Solve a math problem',
      '🎨  Creative writing help',
      '🌐  Translate text',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _OrbPainter(pulse: 0.5, wave: 0, active: false),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.92, end: 1.08, duration: 2600.ms)
                .fadeIn(duration: 800.ms),
            const SizedBox(height: 32),
            Text(
              'BEEDI COLLEGE AI',
              style: _C.display(size: 22, color: _C.cyan, spacing: 4),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              'Your intelligent neural assistant — ask me anything',
              style: _C.body(size: 14, color: Colors.white.withOpacity(0.4)),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 40),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map(
                    (s) => _SuggestionChip(
                      label: s,
                      onTap: () =>
                          onSuggestion(s.replaceAll(RegExp(r'^[^\s]+\s+'), '')),
                    ),
                  )
                  .toList(),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered
                ? _C.cyan.withOpacity(0.15)
                : _C.cyan.withOpacity(0.07),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: _C.cyan.withOpacity(_hovered ? 0.5 : 0.2),
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: _C.cyan.withOpacity(0.2), blurRadius: 12)]
                : null,
          ),
          child: Text(widget.label, style: _C.body(size: 12, color: _C.cyan)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MESSAGE BUBBLE
// ═══════════════════════════════════════════════════════════════
class _MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;
  final bool isLast;

  const _MessageBubble({
    required this.message,
    required this.onCopy,
    required this.onRegenerate,
    this.isLast = false,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _hovered = false;

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == 'user';
    final text = widget.message.text;

    return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width *
                    (MediaQuery.of(context).size.width > 800 ? 0.58 : 0.82),
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Role + time
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4,
                      right: 4,
                      bottom: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isUser) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _C.neonGreen,
                              boxShadow: [
                                BoxShadow(
                                  color: _C.neonGreen.withOpacity(0.8),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          isUser ? 'YOU' : 'BEEDI AI',
                          style: _C.mono(
                            size: 9,
                            color: isUser
                                ? _C.cyan.withOpacity(0.7)
                                : _C.neonGreen.withOpacity(0.8),
                            spacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(widget.message.timestamp),
                          style: _C.mono(
                            size: 9,
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bubble
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(22),
                      topRight: const Radius.circular(22),
                      bottomLeft: Radius.circular(isUser ? 22 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 22),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isUser
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _C.cyan.withOpacity(0.28),
                                    _C.purple.withOpacity(0.2),
                                    _C.blue.withOpacity(0.35),
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(
                                      _hovered ? 0.1 : 0.07,
                                    ),
                                    Colors.white.withOpacity(0.03),
                                  ],
                                ),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(22),
                            topRight: const Radius.circular(22),
                            bottomLeft: Radius.circular(isUser ? 22 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 22),
                          ),
                          border: Border.all(
                            color: isUser
                                ? _C.cyan.withOpacity(0.4)
                                : Colors.white.withOpacity(
                                    _hovered ? 0.14 : 0.08,
                                  ),
                            width: 1,
                          ),
                          boxShadow: isUser
                              ? [
                                  BoxShadow(
                                    color: _C.cyan.withOpacity(0.12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: isUser
                            ? _buildSelectableText(text)
                            : MarkdownBody(
                                data: text,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: _C.body(
                                    color: Colors.white.withOpacity(0.92),
                                    size: 15,
                                  ),
                                  code: _C.mono(size: 13, color: _C.cyan),
                                  codeblockDecoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: _C.r12,
                                    border: Border.all(
                                      color: _C.cyan.withOpacity(0.25),
                                    ),
                                  ),
                                  h1: _C.display(size: 20, color: _C.cyan),
                                  h2: _C.display(size: 18, color: _C.cyan),
                                  h3: _C.display(size: 16, color: _C.cyan),
                                  listBullet: _C.body(color: _C.cyan, size: 15),
                                  blockquoteDecoration: BoxDecoration(
                                    color: _C.purple.withOpacity(0.08),
                                    border: Border(
                                      left: BorderSide(
                                        color: _C.purple.withOpacity(0.7),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  strong: _C.body(
                                    color: Colors.white,
                                    size: 15,
                                    weight: FontWeight.bold,
                                  ),
                                  em: _C.body(color: _C.cyanDim, size: 15),
                                  tableHead: _C.mono(
                                    size: 12,
                                    color: _C.cyan,
                                    weight: FontWeight.bold,
                                  ),
                                  tableBody: _C.body(
                                    size: 13,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                  tableHeadAlign: TextAlign.center,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Actions (AI only)
                  if (!isUser)
                    AnimatedOpacity(
                      opacity: _hovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MsgAction(
                              icon: Icons.copy_rounded,
                              label: 'Copy',
                              onTap: widget.onCopy,
                            ),
                            const SizedBox(width: 4),
                            if (widget.isLast)
                              _MsgAction(
                                icon: Icons.refresh_rounded,
                                label: 'Regenerate',
                                onTap: widget.onRegenerate,
                              ),
                            const SizedBox(width: 4),
                            _MsgAction(
                              icon: Icons.thumb_up_outlined,
                              label: 'Good response',
                              onTap: () {},
                            ),
                            const SizedBox(width: 4),
                            _MsgAction(
                              icon: Icons.thumb_down_outlined,
                              label: 'Bad response',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.12, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }

  Widget _buildSelectableText(String text) {
    return SelectableText(text, style: _C.body(color: Colors.white, size: 15));
  }
}

class _MsgAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MsgAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_MsgAction> createState() => _MsgActionState();
}

class _MsgActionState extends State<_MsgAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.label,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _hovered
                  ? Colors.white.withOpacity(0.12)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(_hovered ? 0.15 : 0.07),
              ),
            ),
            child: Icon(
              widget.icon,
              size: 13,
              color: Colors.white.withOpacity(_hovered ? 0.8 : 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SEARCH OVERLAY
// ═══════════════════════════════════════════════════════════════
class _SearchOverlay extends StatefulWidget {
  final List<ChatMessage> messages;
  final VoidCallback onClose;

  const _SearchOverlay({required this.messages, required this.onClose});

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay> {
  final _ctrl = TextEditingController();
  List<ChatMessage> _results = [];

  void _search(String q) {
    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() {
      _results = widget.messages
          .where((m) => m.text.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(32),
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
              child: _GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            autofocus: true,
                            onChanged: _search,
                            style: _C.body(color: Colors.white),
                            cursorColor: _C.cyan,
                            decoration: InputDecoration(
                              hintText: 'Search messages…',
                              hintStyle: _C.body(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: _C.cyan.withOpacity(0.7),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.close, color: Colors.white54),
                        ),
                      ],
                    ),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    Expanded(
                      child: _results.isEmpty
                          ? Center(
                              child: Text(
                                _ctrl.text.isEmpty
                                    ? 'Type to search…'
                                    : 'No results found',
                                style: _C.body(
                                  color: Colors.white.withOpacity(0.3),
                                  size: 14,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _results.length,
                              separatorBuilder: (_, __) => Divider(
                                color: Colors.white.withOpacity(0.06),
                              ),
                              itemBuilder: (_, i) {
                                final m = _results[i];
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    m.role == 'user'
                                        ? Icons.person_outline
                                        : Icons.smart_toy_outlined,
                                    color: m.role == 'user'
                                        ? _C.cyan
                                        : _C.neonGreen,
                                    size: 16,
                                  ),
                                  title: Text(
                                    m.text.length > 80
                                        ? '${m.text.substring(0, 80)}…'
                                        : m.text,
                                    style: _C.body(
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                  ),
                                  subtitle: Text(
                                    m.role == 'user' ? 'You' : 'BEEDI AI',
                                    style: _C.mono(
                                      size: 9,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HISTORY SIDEBAR ITEM
// ═══════════════════════════════════════════════════════════════
class _HistoryItem extends StatefulWidget {
  final ChatSession session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryItem({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? _C.cyan.withOpacity(0.12)
                : _hovered
                ? Colors.white.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: _C.r12,
            border: Border.all(
              color: widget.isActive
                  ? _C.cyan.withOpacity(0.35)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 14,
                color: widget.isActive
                    ? _C.cyan
                    : Colors.white.withOpacity(0.4),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _C.body(
                        size: 12,
                        color: widget.isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${widget.session.messages.length} messages',
                      style: _C.mono(
                        size: 9,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
              if (_hovered || widget.isActive)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 14,
                    color: Colors.redAccent.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ═══════════════════════════════════════════════════════════════
class MainTesterScreen extends StatefulWidget {
  const MainTesterScreen({super.key});

  @override
  State<MainTesterScreen> createState() => _MainTesterScreenState();
}

class _MainTesterScreenState extends State<MainTesterScreen>
    with TickerProviderStateMixin {
  // ── API ─────────────────────────────────────────────────────
  final String apiKey = "AIzaSyCVj-7e1nkHfT71vJ86p2DpPilZy7wXx10";
  final String modelName = "BEEDI College AI Version 2.0";

  // ── State ────────────────────────────────────────────────────
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  bool _isLoading = false;
  String _statusInfo = '';
  bool _showSearch = false;
  bool _showHistory = false;

  // ── Sessions ─────────────────────────────────────────────────
  List<ChatSession> _sessions = [];
  late ChatSession _currentSession;

  List<ChatMessage> get _messages => _currentSession.messages;

  // ── Animations ───────────────────────────────────────────────
  late AnimationController _bgCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _gridCtrl;
  late AnimationController _orbPulseCtrl;
  late AnimationController _orbWaveCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _sidebarCtrl;

  final List<_Particle> _particles = [];
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _currentSession = ChatSession(title: 'New Chat');

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();

    _gridCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _orbPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _orbWaveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _sidebarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _generateParticles();
    _loadHistory();
  }

  void _generateParticles() {
    for (int i = 0; i < 55; i++) {
      _particles.add(
        _Particle(
          x: _rng.nextDouble() * 500,
          y: _rng.nextDouble() * 900,
          vx: (_rng.nextDouble() - 0.5) * 0.35,
          vy: (_rng.nextDouble() - 0.5) * 0.25,
          radius: _rng.nextDouble() * 1.8 + 0.4,
          opacity: _rng.nextDouble() * 0.5 + 0.1,
        ),
      );
    }
  }

  Future<void> _loadHistory() async {
    final sessions = await ChatHistoryManager.loadSessions();
    setState(() => _sessions = sessions);
  }

  Future<void> _saveHistory() async {
    // Update or insert current session
    final idx = _sessions.indexWhere((s) => s.id == _currentSession.id);
    if (idx >= 0) {
      _sessions[idx] = _currentSession;
    } else if (_currentSession.messages.isNotEmpty) {
      _sessions.insert(0, _currentSession);
    }
    await ChatHistoryManager.saveSessions(_sessions);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _particleCtrl.dispose();
    _gridCtrl.dispose();
    _orbPulseCtrl.dispose();
    _orbWaveCtrl.dispose();
    _fadeCtrl.dispose();
    _sidebarCtrl.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  // ── API CALL (logic unchanged) ───────────────────────────────
  Future<void> _sendMessage({String? override}) async {
    final message = override ?? _messageController.text.trim();
    if (message.isEmpty) {
      _showSnack(context, 'Please enter a message', success: false);
      return;
    }

    // Auto-title session from first message
    if (_currentSession.messages.isEmpty) {
      _currentSession.title = message.length > 40
          ? '${message.substring(0, 40)}…'
          : message;
    }

    final userMsg = ChatMessage(
      role: 'user',
      text: message,
      timestamp: DateTime.now(),
      isAnimated: false,
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
      _messageController.clear();
    });

    _orbWaveCtrl.repeat();
    _scrollToBottom();

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
      );

      final result = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': _messages
                  .map(
                    (m) => {
                      'role': m.role == 'user' ? 'user' : 'model',
                      'parts': [
                        {'text': m.text},
                      ],
                    },
                  )
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      final Map<String, dynamic> data = jsonDecode(result.body);

      setState(() {
        _statusInfo = 'SYSTEM ONLINE • ${result.statusCode}';
      });

      if (result.statusCode == 200) {
        final aiText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        final aiMsg = ChatMessage(
          role: 'ai',
          text: aiText,
          timestamp: DateTime.now(),
        );

        setState(() => _messages.add(aiMsg));
        _currentSession.updatedAt = DateTime.now();
        await _saveHistory();
      } else {
        final errText =
            'Error ${result.statusCode}\n${data['error']?['message'] ?? 'Unknown Error'}';
        setState(
          () => _messages.add(
            ChatMessage(role: 'ai', text: errText, timestamp: DateTime.now()),
          ),
        );
      }
    } catch (e) {
      setState(
        () => _messages.add(
          ChatMessage(
            role: 'ai',
            text: 'Connection Failed\n$e',
            timestamp: DateTime.now(),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      _orbWaveCtrl.stop();
      _orbWaveCtrl.reset();
      _scrollToBottom();
    }
  }

  Future<void> _regenerateLast() async {
    if (_messages.length < 2) return;
    final lastUser = _messages.lastWhere(
      (m) => m.role == 'user',
      orElse: () => _messages.first,
    );
    // Remove last AI message
    setState(() {
      if (_messages.last.role == 'ai') _messages.removeLast();
    });
    await _sendMessage(override: lastUser.text);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _newChat() {
    setState(() {
      _currentSession = ChatSession(title: 'New Chat');
      _statusInfo = '';
    });
  }

  void _loadSession(ChatSession s) {
    setState(() {
      _currentSession = s;
      _showHistory = false;
    });
    _scrollToBottom();
  }

  void _deleteSession(ChatSession s) {
    setState(() {
      _sessions.removeWhere((x) => x.id == s.id);
      if (_currentSession.id == s.id) _newChat();
    });
    ChatHistoryManager.saveSessions(_sessions);
  }

  void _clearChat() {
    setState(() {
      _currentSession.messages.clear();
      _statusInfo = '';
    });
    _saveHistory();
  }

  void _exportTxt() {
    final buf = StringBuffer();
    buf.writeln('BEEDI AI Chat Export');
    buf.writeln('Session: ${_currentSession.title}');
    buf.writeln('Date: ${DateTime.now()}');
    buf.writeln('=' * 50);
    for (final m in _messages) {
      buf.writeln('[${m.role.toUpperCase()}] ${_formatDateTime(m.timestamp)}');
      buf.writeln(m.text);
      buf.writeln();
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    _showSnack(context, 'Chat exported to clipboard (TXT)');
  }

  void _exportJson() {
    final json = jsonEncode(_currentSession.toJson());
    Clipboard.setData(ClipboardData(text: json));
    _showSnack(context, 'Chat exported to clipboard (JSON)');
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ═══════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (e) {
        if (e is KeyDownEvent) {
          if (e.logicalKey == LogicalKeyboardKey.escape && _showSearch) {
            setState(() => _showSearch = false);
          }
          // Ctrl+K → search
          if (HardwareKeyboard.instance.isControlPressed &&
              e.logicalKey == LogicalKeyboardKey.keyK) {
            setState(() => _showSearch = !_showSearch);
          }
          // Ctrl+N → new chat
          if (HardwareKeyboard.instance.isControlPressed &&
              e.logicalKey == LogicalKeyboardKey.keyN) {
            _newChat();
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: AnimatedBuilder(
          animation: Listenable.merge([_bgCtrl, _particleCtrl, _gridCtrl]),
          builder: (context, _) {
            return Stack(
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _C.bg0,
                        Color.lerp(
                          _C.bg1,
                          const Color(0xFF0A2A50),
                          _bgCtrl.value,
                        )!,
                        Color.lerp(
                          _C.bg2,
                          const Color(0xFF140840),
                          _bgCtrl.value,
                        )!,
                      ],
                    ),
                  ),
                ),

                // Cyber grid
                SizedBox.expand(
                  child: CustomPaint(painter: _GridPainter(_gridCtrl.value)),
                ),

                // Neural particles
                SizedBox.expand(
                  child: CustomPaint(
                    painter: _NeuralPainter(
                      _particles,
                      _particleCtrl.value * 4800,
                    ),
                  ),
                ),

                // Ambient glows
                Positioned(
                  top: -100,
                  left: -80,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.cyan.withOpacity(0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -140,
                  right: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.purple.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4,
                  left: -60,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.blue.withOpacity(0.06),
                    ),
                  ),
                ),

                // Main UI
                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeCtrl,
                    child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
                  ),
                ),

                // Search overlay
                if (_showSearch)
                  _SearchOverlay(
                    messages: _messages,
                    onClose: () => setState(() => _showSearch = false),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── WIDE LAYOUT ──────────────────────────────────────────────
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Sidebar
        SizedBox(
          width: 268,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildLogo(),
                const SizedBox(height: 14),
                _buildNewChatButton(),
                const SizedBox(height: 14),
                _buildOrbWidget(),
                const SizedBox(height: 14),
                _buildSidebarStats(),
                const SizedBox(height: 14),
                // History
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RECENT CHATS',
                    style: _C.mono(
                      size: 9,
                      color: Colors.white.withOpacity(0.35),
                      spacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: _buildHistoryList()),
                const SizedBox(height: 10),
                _buildSidebarActions(),
              ],
            ),
          ),
        ),

        // Chat panel
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
            child: Column(
              children: [
                _buildTopBar(showLogo: false),
                const SizedBox(height: 14),
                Expanded(child: _buildChatArea()),
                const SizedBox(height: 10),
                _buildInputArea(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── NARROW LAYOUT ────────────────────────────────────────────
  Widget _buildNarrowLayout() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildTopBar(showLogo: true),
              const SizedBox(height: 12),
              Expanded(child: _buildChatArea()),
              const SizedBox(height: 8),
              _buildInputArea(),
            ],
          ),
        ),
        // Mobile history drawer
        if (_showHistory)
          GestureDetector(
            onTap: () => setState(() => _showHistory = false),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 280,
                    height: double.infinity,
                    color: _C.bg1,
                    padding: const EdgeInsets.all(16),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'CHAT HISTORY',
                                style: _C.mono(
                                  size: 11,
                                  color: _C.cyan,
                                  spacing: 2,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () =>
                                    setState(() => _showHistory = false),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildNewChatButton(),
                          const SizedBox(height: 12),
                          Expanded(child: _buildHistoryList()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── LOGO ─────────────────────────────────────────────────────
  Widget _buildLogo() {
    return _GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Hero(
            tag: 'logo',
            child: AnimatedBuilder(
              animation: _orbPulseCtrl,
              builder: (_, child) => Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: _C.cyan.withOpacity(
                        0.3 + 0.2 * _orbPulseCtrl.value,
                      ),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: child,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  'assets/Logoes/Logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BEEDI AI',
                  style: _C.display(size: 15, color: Colors.white),
                ),
                Text(
                  'BEEDI AI ADVANCE V 2.0',
                  style: _C.mono(size: 9, color: _C.cyan.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── NEW CHAT BUTTON ──────────────────────────────────────────
  Widget _buildNewChatButton() {
    return GestureDetector(
      onTap: _newChat,
      child: _GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        borderColor: _C.cyan.withOpacity(0.3),
        gradient: LinearGradient(
          colors: [_C.cyan.withOpacity(0.1), _C.purple.withOpacity(0.06)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 16, color: _C.cyan),
            const SizedBox(width: 8),
            Text(
              'NEW CHAT',
              style: _C.mono(size: 11, color: _C.cyan, spacing: 1.5),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: _C.r12,
              ),
              child: Text(
                'Ctrl+N',
                style: _C.mono(size: 8, color: Colors.white.withOpacity(0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ORB WIDGET ───────────────────────────────────────────────
  Widget _buildOrbWidget() {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbPulseCtrl, _orbWaveCtrl]),
      builder: (_, __) {
        return _GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _OrbPainter(
                    pulse: _orbPulseCtrl.value,
                    wave: _orbWaveCtrl.value,
                    active: _isLoading,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? const _TypingDots()
                    : Column(
                        children: [
                          Text(
                            _statusInfo.isEmpty
                                ? 'BEEDI AI ONLINE'
                                : _statusInfo,
                            key: const ValueKey('status'),
                            style: _C.mono(
                              size: 9,
                              color: _C.neonGreen.withOpacity(0.9),
                              spacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _C.neonGreen,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _C.neonGreen.withOpacity(0.8),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Active',
                                style: _C.body(
                                  size: 10,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── SIDEBAR STATS ────────────────────────────────────────────
  Widget _buildSidebarStats() {
    return _GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _StatRow('Messages', '${_messages.length}'),
          const SizedBox(height: 8),
          _StatRow('Sessions', '${_sessions.length}'),
          const SizedBox(height: 8),
          _StatRow('Model', 'BEEDI AI 2.0'),
          const SizedBox(height: 8),
          _StatRow(
            'Status',
            _isLoading ? 'Processing' : 'Ready',
            valueColor: _isLoading ? Colors.orangeAccent : _C.neonGreen,
          ),
        ],
      ),
    );
  }

  // ── HISTORY LIST ─────────────────────────────────────────────
  Widget _buildHistoryList() {
    if (_sessions.isEmpty) {
      return Center(
        child: Text(
          'No history yet',
          style: _C.body(size: 12, color: Colors.white.withOpacity(0.25)),
        ),
      );
    }
    return ListView.builder(
      itemCount: _sessions.length,
      itemBuilder: (_, i) {
        final s = _sessions[i];
        return _HistoryItem(
          session: s,
          isActive: s.id == _currentSession.id,
          onTap: () => _loadSession(s),
          onDelete: () => _deleteSession(s),
        );
      },
    );
  }

  // ── SIDEBAR ACTIONS ──────────────────────────────────────────
  Widget _buildSidebarActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionBtn(
                icon: Icons.search_rounded,
                label: 'Search',
                onTap: () => setState(() => _showSearch = true),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _ActionBtn(
                icon: Icons.file_download_outlined,
                label: 'Export',
                onTap: _showExportMenu,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _ActionBtn(
          icon: Icons.delete_sweep_rounded,
          label: 'CLEAR CHAT',
          onTap: _clearChat,
          color: Colors.redAccent.withOpacity(0.7),
          borderColor: Colors.redAccent.withOpacity(0.25),
        ),
      ],
    );
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.bg1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Export Chat', style: _C.display(size: 16)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.text_snippet_outlined,
                color: Colors.white70,
              ),
              title: Text('Export as TXT', style: _C.body(color: Colors.white)),
              subtitle: Text(
                'Copied to clipboard',
                style: _C.mono(size: 10, color: Colors.white.withOpacity(0.3)),
              ),
              onTap: () {
                Navigator.pop(context);
                _exportTxt();
              },
            ),
            ListTile(
              leading: const Icon(Icons.code_rounded, color: Colors.white70),
              title: Text(
                'Export as JSON',
                style: _C.body(color: Colors.white),
              ),
              subtitle: Text(
                'Copied to clipboard',
                style: _C.mono(size: 10, color: Colors.white.withOpacity(0.3)),
              ),
              onTap: () {
                Navigator.pop(context);
                _exportJson();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────────
  Widget _buildTopBar({required bool showLogo}) {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (showLogo) ...[
            GestureDetector(
              onTap: () => setState(() => _showHistory = true),
              child: Icon(
                Icons.menu_rounded,
                color: Colors.white.withOpacity(0.6),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Hero(
              tag: 'logo',
              child: AnimatedBuilder(
                animation: _orbPulseCtrl,
                builder: (_, child) => Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _C.cyan.withOpacity(
                          0.3 + 0.2 * _orbPulseCtrl.value,
                        ),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/Logoes/Logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentSession.title == 'New Chat'
                      ? 'BEEDI COLLEGE AI'
                      : _currentSession.title,
                  style: _C.display(size: 16, color: Colors.white, spacing: 1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  modelName,
                  style: _C.mono(size: 9, color: _C.cyan.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          // Online pill
          AnimatedBuilder(
            animation: _orbPulseCtrl,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _C.neonGreen.withOpacity(0.09),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: _C.neonGreen.withOpacity(
                    0.3 + 0.2 * _orbPulseCtrl.value,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _C.neonGreen,
                      boxShadow: [
                        BoxShadow(
                          color: _C.neonGreen.withOpacity(0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'ONLINE',
                    style: _C.mono(
                      size: 9,
                      color: _C.neonGreen,
                      weight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Search button
          _TopBarBtn(
            icon: Icons.search_rounded,
            tooltip: 'Search (Ctrl+K)',
            onTap: () => setState(() => _showSearch = true),
          ),
          const SizedBox(width: 4),
          // Export
          _TopBarBtn(
            icon: Icons.file_download_outlined,
            tooltip: 'Export',
            onTap: _showExportMenu,
          ),
          if (showLogo) ...[
            const SizedBox(width: 4),
            _TopBarBtn(
              icon: Icons.refresh_rounded,
              tooltip: 'Clear chat',
              onTap: _clearChat,
            ),
          ],
        ],
      ),
    );
  }

  // ── CHAT AREA ────────────────────────────────────────────────
  Widget _buildChatArea() {
    return _GlassCard(
      padding: const EdgeInsets.all(12),
      child: _messages.isEmpty
          ? _EmptyState(onSuggestion: (s) => _sendMessage(override: s))
          : Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              radius: const Radius.circular(3),
              thickness: 3,
              child: ListView.separated(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(4),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (ctx, i) {
                  if (i == _messages.length) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ShimmerBubble(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const _TypingDots(),
                            const SizedBox(width: 10),
                            Text(
                              'Neural processing…',
                              style: _C.mono(
                                size: 9,
                                color: _C.cyan.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  final msg = _messages[i];
                  final isLast = i == _messages.length - 1 && msg.role == 'ai';
                  return _MessageBubble(
                    message: msg,
                    isLast: isLast,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: msg.text));
                      _showSnack(context, 'Copied to clipboard');
                    },
                    onRegenerate: _regenerateLast,
                  );
                },
              ),
            ),
    );
  }

  // ── INPUT AREA ───────────────────────────────────────────────
  Widget _buildInputArea() {
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attach
          _InputAction(
            icon: Icons.attach_file_rounded,
            onTap: () =>
                _showSnack(context, 'Attachment coming soon', success: false),
          ),
          const SizedBox(width: 6),

          // Text field
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _inputFocus,
              minLines: 1,
              maxLines: 6,
              style: _C.body(color: Colors.white, size: 15),
              cursorColor: _C.cyan,
              decoration: InputDecoration(
                hintText: 'Ask BEEDI AI anything…',
                hintStyle: _C.body(
                  color: Colors.white.withOpacity(0.28),
                  size: 15,
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.22),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: _C.r22,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: _C.r22,
                  borderSide: BorderSide(
                    color: _C.cyan.withOpacity(0.14),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: _C.r22,
                  borderSide: BorderSide(
                    color: _C.cyan.withOpacity(0.55),
                    width: 1.5,
                  ),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 6),

          // Mic
          _InputAction(
            icon: Icons.mic_rounded,
            onTap: () =>
                _showSnack(context, 'Voice input coming soon', success: false),
          ),
          const SizedBox(width: 6),

          // Send
          AnimatedBuilder(
            animation: _orbPulseCtrl,
            builder: (_, __) => GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isLoading
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_C.cyan, _C.cyanDim],
                        ),
                  color: _isLoading ? Colors.white.withOpacity(0.07) : null,
                  boxShadow: _isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: _C.cyan.withOpacity(
                              0.4 + 0.25 * _orbPulseCtrl.value,
                            ),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _C.cyan.withOpacity(0.6),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.black,
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
}

// ═══════════════════════════════════════════════════════════════
//  SMALL REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: _C.body(size: 11, color: Colors.white.withOpacity(0.4)),
        ),
        Text(
          value,
          style: _C.mono(
            size: 11,
            color: valueColor ?? _C.cyan,
            weight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? borderColor;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.borderColor,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.white.withOpacity(0.5);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.04),
            borderRadius: _C.r16,
            border: Border.all(
              color:
                  widget.borderColor ??
                  Colors.white.withOpacity(_hovered ? 0.15 : 0.07),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: _C.mono(size: 10, color: color, spacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBarBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopBarBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_TopBarBtn> createState() => _TopBarBtnState();
}

class _TopBarBtnState extends State<_TopBarBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _hovered
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: _C.r12,
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: Colors.white.withOpacity(_hovered ? 0.8 : 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _InputAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.4), size: 18),
      ),
    );
  }
}
