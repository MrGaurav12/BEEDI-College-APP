// import 'package:flutter/material.dart';
//
// // ─────────────────────────────────────────────
// //  BATCH SELECTION SCREEN
// // ─────────────────────────────────────────────
// class BatchSelectionScreen extends StatefulWidget {
//   const BatchSelectionScreen({super.key});
//
//   @override
//   State<BatchSelectionScreen> createState() => _BatchSelectionScreenState();
// }
//
// class _BatchSelectionScreenState extends State<BatchSelectionScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;
//   int? _pressedIndex;
//
//   final List<_BatchInfo> _batches = const [
//     _BatchInfo(
//       key: 'FEB 2026',
//       label: 'BATCH FEB 2026',
//       subtitle: 'February 2026 Session',
//       icon: Icons.calendar_month_rounded,
//       gradientColors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
//     ),
//     _BatchInfo(
//       key: 'MARCH 2026',
//       label: 'BATCH MARCH 2026',
//       subtitle: 'March 2026 Session',
//       icon: Icons.school_rounded,
//       gradientColors: [Color(0xFF00838F), Color(0xFF00ACC1)],
//     ),
//     _BatchInfo(
//       key: 'APRIL 2026',
//       label: 'BATCH APRIL 2026',
//       subtitle: 'April 2026 Session',
//       icon: Icons.menu_book_rounded,
//       gradientColors: [Color(0xFF2E7D32), Color(0xFF43A047)],
//     ),
//     _BatchInfo(
//       key: 'MAY 2026',
//       label: 'BATCH MAY 2026',
//       subtitle: 'May 2026 Session',
//       icon: Icons.star_rounded,
//       gradientColors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _fadeAnim =
//         CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.12),
//       end: Offset.zero,
//     ).animate(
//         CurvedAnimation(parent: _animController, curve: Curves.easeOut));
//     _animController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }
//
//   void _selectBatch(BuildContext context, _BatchInfo batch, int index) async {
//     setState(() => _pressedIndex = index);
//     await Future.delayed(const Duration(milliseconds: 180));
//     if (!mounted) return;
//     setState(() => _pressedIndex = null);
//
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, a, __) => Login(batchName: batch.key),
//         transitionsBuilder: (_, anim, __, child) => FadeTransition(
//           opacity: anim,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0.05, 0),
//               end: Offset.zero,
//             ).animate(anim),
//             child: child,
//           ),
//         ),
//         transitionDuration: const Duration(milliseconds: 400),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Gradient background
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color(0xFF0D47A1),
//                   Color(0xFF1565C0),
//                   Color(0xFF1E88E5)
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           // Decorative circles
//           Positioned(
//             top: -80,
//             right: -60,
//             child: _decorCircle(240, Colors.white.withOpacity(0.05)),
//           ),
//           Positioned(
//             top: 80,
//             right: 30,
//             child: _decorCircle(110, Colors.white.withOpacity(0.07)),
//           ),
//           Positioned(
//             bottom: -100,
//             left: -70,
//             child: _decorCircle(280, Colors.white.withOpacity(0.04)),
//           ),
//           Positioned(
//             bottom: 100,
//             right: -40,
//             child: _decorCircle(160, Colors.white.withOpacity(0.04)),
//           ),
//           SafeArea(
//             child: FadeTransition(
//               opacity: _fadeAnim,
//               child: SlideTransition(
//                 position: _slideAnim,
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 36),
//                     // Header
//                     Container(
//                       width: 72,
//                       height: 72,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 20,
//                             offset: const Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.school_rounded,
//                         color: Color(0xFF1565C0),
//                         size: 38,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Result Management\nSystem',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.w700,
//                         height: 1.3,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'BS-CIT / BS-CLS / BS-CSS Programme',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.75),
//                         fontSize: 13,
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     // Card container
//                     Expanded(
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 0),
//                         decoration: const BoxDecoration(
//                           color: Color(0xFFF8FAFF),
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(32),
//                             topRight: Radius.circular(32),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Select Your Batch',
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w800,
//                                   color: Color(0xFF1A1A2E),
//                                   letterSpacing: 0.3,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Choose your batch to view result',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               const SizedBox(height: 24),
//                               Expanded(
//                                 child: ListView.separated(
//                                   physics: const BouncingScrollPhysics(),
//                                   itemCount: _batches.length,
//                                   separatorBuilder: (_, __) =>
//                                       const SizedBox(height: 14),
//                                   itemBuilder: (context, i) {
//                                     final batch = _batches[i];
//                                     final isPressed = _pressedIndex == i;
//                                     return _AnimatedBatchCard(
//                                       batch: batch,
//                                       index: i,
//                                       isPressed: isPressed,
//                                       onTap: () =>
//                                           _selectBatch(context, batch, i),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               Center(
//                                 child: Text(
//                                   '© 2025 Result Management System',
//                                   style: TextStyle(
//                                     color: Colors.grey[400],
//                                     fontSize: 11,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _decorCircle(double size, Color color) => Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(shape: BoxShape.circle, color: color),
//       );
// }
//
// class _BatchInfo {
//   final String key;
//   final String label;
//   final String subtitle;
//   final IconData icon;
//   final List<Color> gradientColors;
//
//   const _BatchInfo({
//     required this.key,
//     required this.label,
//     required this.subtitle,
//     required this.icon,
//     required this.gradientColors,
//   });
// }
//
// class _AnimatedBatchCard extends StatefulWidget {
//   final _BatchInfo batch;
//   final int index;
//   final bool isPressed;
//   final VoidCallback onTap;
//
//   const _AnimatedBatchCard({
//     required this.batch,
//     required this.index,
//     required this.isPressed,
//     required this.onTap,
//   });
//
//   @override
//   State<_AnimatedBatchCard> createState() => _AnimatedBatchCardState();
// }
//
// class _AnimatedBatchCardState extends State<_AnimatedBatchCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _scaleAnim;
//   late Animation<double> _fadeAnim;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 400 + widget.index * 80),
//     );
//     _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
//         CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
//     _fadeAnim =
//         CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
//     Future.delayed(Duration(milliseconds: widget.index * 80), () {
//       if (mounted) _ctrl.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fadeAnim,
//       child: ScaleTransition(
//         scale: _scaleAnim,
//         child: GestureDetector(
//           onTap: widget.onTap,
//           child: AnimatedScale(
//             scale: widget.isPressed ? 0.97 : 1.0,
//             duration: const Duration(milliseconds: 120),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(18),
//                 gradient: LinearGradient(
//                   colors: widget.batch.gradientColors,
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: widget.batch.gradientColors.last.withOpacity(0.35),
//                     blurRadius: 14,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 20, vertical: 18),
//                 child: Row(
//                   children: [
//                     // Icon container
//                     Container(
//                       width: 52,
//                       height: 52,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: Icon(
//                         widget.batch.icon,
//                         color: Colors.white,
//                         size: 28,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     // Labels
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.batch.label,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: 0.4,
//                             ),
//                           ),
//                           const SizedBox(height: 3),
//                           Text(
//                             widget.batch.subtitle,
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.78),
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Arrow
//                     Container(
//                       width: 34,
//                       height: 34,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.arrow_forward_ios_rounded,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }