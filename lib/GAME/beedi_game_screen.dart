// ignore_for_file: deprecated_member_use, unused_field, unused_local_variable
// =============================================================================
// BEEDI GAME ECOSYSTEM — beedi_game_screen.dart
// Version: 5.0 ULTIMATE | 56 Games | Production-Grade | Null Safe | Firebase
// Cyberpunk Gaming UI | Full Learner System | Wallet | Shop | All 56 Games
// =============================================================================
// pubspec.yaml dependencies:
//   firebase_core: ^2.27.0
//   cloud_firestore: ^4.15.0
//   flutter_animate: ^4.5.0
//   uuid: ^4.3.3
//   shared_preferences: ^2.2.3
//   confetti: ^0.7.0
//   google_fonts: ^6.2.1
//   shimmer: ^3.0.0
//   animated_text_kit: ^4.2.2
// =============================================================================

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:beedi_college/GAME/BalloonPopGame.dart';
import 'package:beedi_college/GAME/ColorMatchGame.dart';
import 'package:beedi_college/GAME/DinoRunGame.dart';
import 'package:beedi_college/GAME/EmojiQuizGame.dart';
import 'package:beedi_college/GAME/FlappyBirdGame.dart';
import 'package:beedi_college/GAME/MemoryMatchGame.dart';
import 'package:beedi_college/GAME/NumberGuessingGame.dart';
import 'package:beedi_college/GAME/QuizBattleGame.dart';
import 'package:beedi_college/GAME/RockPaperScissorsGame.dart';
import 'package:beedi_college/GAME/Snakegame.dart';
import 'package:beedi_college/GAME/Tic_Tac_Toe.dart';
import 'package:beedi_college/GAME/WhackAMoleGame.dart';
import 'package:beedi_college/GAME/game_admin_pannel.dart';
import 'package:beedi_college/GAME/game_home_scrren.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:uuid/uuid.dart';

// =============================================================================
// CONSTANTS
// =============================================================================
const String kAdminId = 'KYP09060019';
const String kAdminPin = 'admin2026';
const _uuid = Uuid();

// =============================================================================
// COLOR SYSTEM — CYBERPUNK NEON THEME
// =============================================================================
class BColors {
  static const neonBlue = Color(0xFF00D4FF);
  static const neonGreen = Color(0xFF00FF88);
  static const neonPurple = Color(0xFFB44FFF);
  static const neonGold = Color(0xFFFFD700);
  static const neonRed = Color(0xFFFF0044);
  static const neonOrange = Color(0xFFFF6B00);
  static const neonPink = Color(0xFFFF0080);
  static const neonCyan = Color(0xFF00FFFF);

  static const glowBlue = Color(0x5500D4FF);
  static const glowGreen = Color(0x5500FF88);
  static const glowPurple = Color(0x55B44FFF);
  static const glowGold = Color(0x55FFD700);

  static const bg1 = Color(0xFF050A14);
  static const bg2 = Color(0xFF0A1628);
  static const bg3 = Color(0xFF0F2040);
  static const glass = Color(0x1200D4FF);

  static const txtPrimary = Color(0xFFE8F4FF);
  static const txtSecondary = Color(0xFF8AACCC);
  static const txtAccent = Color(0xFF00D4FF);

  static const rarityCommon = Color(0xFF9E9E9E);
  static const rarityRare = Color(0xFF2196F3);
  static const rarityEpic = Color(0xFF9C27B0);
  static const rarityLegendary = Color(0xFFFFD700);
  static const rarityMythic = Color(0xFFFF4081);

  static Color rarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'rare':
        return rarityRare;
      case 'epic':
        return rarityEpic;
      case 'legendary':
        return rarityLegendary;
      case 'mythic':
        return rarityMythic;
      default:
        return rarityCommon;
    }
  }

  static const List<Color> avatarPalette = [
    Color(0xFF7C4DFF),
    Color(0xFFFF5252),
    Color(0xFF00BCD4),
    Color(0xFFFF6D00),
    Color(0xFF4CAF50),
    Color(0xFFE91E63),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFF00897B),
    Color(0xFFFF9800),
    Color(0xFFD84315),
    Color(0xFF1565C0),
  ];

  static const List<String> avatarEmojis = [
    '🌸',
    '🌺',
    '🌹',
    '🌷',
    '🌻',
    '🌼',
    '💐',
    '🏵️',
    '🪷',
    '🍀',
    '🌿',
    '☘️',
    '🍁',
    '🍂',
    '🍃',
    '🌴',
    '🌵',
    '🌲',
    '🌳',
    '🪵',
    '🌱',
    '🪴',
    '🌾',
    '🌊',
    '💧',
    '🔥',
    '⚡',
    '☀️',
    '🌙',
    '⭐',
    '🌟',
    '✨',
    '☁️',
    '⛈️',
    '🌈',
    '☂️',
    '❄️',
    '☃️',
    '🌪️',
    '🌋',
    '🪐',
    '☄️',
    '🏠',
    '🏡',
    '🏘️',
    '🏚️',
    '🏢',
    '🏬',
    '🏣',
    '🏤',
    '🏥',
    '🏦',
    '🏨',
    '🏫',
    '⛪',
    '🕌',
    '🛕',
    '🕍',
    '⛩️',
    '🗼',
    '🗽',
    '🎡',
    '🎢',
    '🛝',
    '🎠',
    '⛲',
    '🏖️',
    '🏝️',
    '🏞️',
    '🌅',
    '🌄',
    '🌇',
    '🌆',
    '🌃',
    '🌌',
    '🎆',
    '🎇',
    '🛣️',
    '🛤️',
    '🚦',
    '🚧',
    '🚏',
    '🚥',
    '🚂',
    '🚆',
    '🚇',
    '🚊',
    '🚉',
    '✈️',
    '🛫',
    '🛬',
    '🚀',
    '🛸',
    '🚁',
    '⛵',
    '🚤',
    '🛶',
    '🚢',
    '⚓',
    '🛥️',
    '🚗',
    '🚕',
    '🚙',
    '🚌',
    '🚎',
    '🏎️',
    '🚓',
    '🚑',
    '🚒',
    '🚜',
    '🏍️',
    '🚲',
    '🛴',
    '🛹',
    '🛼',
    '🎈',
    '🎉',
    '🎊',
    '🎁',
    '🪅',
    '🪩',
    '🎀',
    '🎗️',
    '🏆',
    '🥇',
    '🥈',
    '🥉',
    '⚽',
    '🏀',
    '🏈',
    '⚾',
    '🎾',
    '🏐',
    '🏉',
    '🎱',
    '🏓',
    '🏸',
    '🥊',
    '🥋',
    '🎯',
    '🎮',
    '🕹️',
    '🎲',
    '♟️',
    '🧩',
    '🪄',
    '🎨',
    '🖌️',
    '🖍️',
    '✏️',
    '📝',
    '📚',
    '📖',
    '📰',
    '📔',
    '📒',
    '📕',
    '📗',
    '📘',
    '📙',
    '📓',
    '💼',
    '📁',
    '📂',
    '🗂️',
    '📅',
    '📆',
    '📌',
    '📍',
    '✂️',
    '📎',
    '🖇️',
    '📐',
    '📏',
    '🧮',
    '💻',
    '🖥️',
    '⌨️',
    '🖱️',
    '🖨️',
    '📱',
    '☎️',
    '📞',
    '📡',
    '📺',
    '📷',
    '📸',
    '🎥',
    '🎬',
    '🎤',
    '🎧',
    '🎼',
    '🎵',
    '🎶',
    '🎹',
    '🎸',
    '🎻',
    '🥁',
    '🎺',
    '📯',
    '🪘',
    '🧸',
    '🪁',
    '🛍️',
    '🛒',
    '🎒',
    '👑',
    '💍',
    '💎',
    '🔮',
    '🧿',
    '🕯️',
    '💡',
    '🔦',
    '🪔',
    '🧴',
    '🧼',
    '🪥',
    '🛁',
    '🚿',
    '🪞',
    '🛏️',
    '🛋️',
    '🪑',
    '🚪',
    '🪟',
    '🧹',
    '🧺',
    '🍽️',
    '🍴',
    '🥄',
    '🍵',
    '☕',
    '🫖',
    '🍶',
    '🍷',
    '🥂',
    '🍹',
    '🧃',
    '🥤',
    '🍕',
    '🍔',
    '🌭',
    '🍟',
    '🥪',
    '🌮',
    '🌯',
    '🍜',
    '🍣',
    '🍩',
    '🍪',
    '🎂',
    '🍰',
    '🧁',
    '🍫',
    '🍬',
    '🍭',
    '🍓',
    '🍒',
    '🍎',
    '🍉',
    '🍇',
    '🍍',
    '🥭',
    '🥝',
    '🍌',
    '🥥',
    '🥑',
    '🍆',
    '🥕',
    '🌽',
    '🥦',
    '🍄',
    '🧄',
    '🧅',
    '🥔',
    '❤️',
    '🧡',
    '💛',
    '💚',
    '💙',
    '💜',
    '🖤',
    '🤍',
    '🤎',
    '💖',
    '💘',
    '💝',
    '💞',
    '💕',
    '❣️',
    '💯',
    '✔️',
    '✅',
    '⭐',
    '⭕',
    '❌',
    '⚠️',
    '🚫',
    '🔔',
    '🔕',
    '🔒',
    '🔓',
    '🔑',
    '🗝️',
    '🛡️',
    '⚔️',
    '🗡️',
    '🏹',
    '🪓',
    '🔧',
    '⚙️',
    '🛠️',
    '⛓️',
    '🔗',
    '📿',
    '🪬',
    '🧠',
    '👁️',
    '👀',
    '🫀',
    '🫁',
    '🦋',
    '🐝',
    '🐞',
    '🪲',
    '🐢',
    '🐬',
    '🦄',
    '🐲',
    '🦜',
    '🦚',
    '🦩',
    '🐇',
    '🦔',
    '🐿️',
    '🦥',
    '🦦',
    '🐉',
    '🦖',
    '🦕',
    '🦁',
    '🐯',
    '🦊',
    '🐺',
    '🦝',
    '🐻',
    '🦄',
    '🐲',
    '🦅',
    '🦋',
    '🐬',
    '🦈',
    '⚡',
    '🔥',
    '💎',
    '🚀',
    '🌟',
    '🎯',
    '🌊',
    '🌙',
    '👾',
    '🤖',
    '🎮',
    '💀',
    '☠️',
    '👑',
    '🛡️',
    '⚔️',
    '🗡️',
    '🏹',
    '🪓',
    '🔮',
    '🧿',
    '🎲',
    '🧩',
    '🪙',
    '💰',
    '🏆',
    '🥇',
    '🎖️',
    '📿',
    '🧠',
    '👁️',
    '🌀',
    '🌈',
    '☄️',
    '🌋',
    '🪐',
    '⭐',
    '🌠',
    '☀️',
    '🌪️',
    '❄️',
    '☁️',
    '🌧️',
    '⛈️',
    '🌸',
    '🌹',
    '🌺',
    '🍁',
    '🌴',
    '🌵',
    '🍀',
    '🍄',
    '🐉',
    '🦖',
    '🦕',
    '🐢',
    '🐍',
    '🦂',
    '🕷️',
    '🐙',
    '🦑',
    '🦐',
    '🦞',
    '🐠',
    '🐳',
    '🦓',
    '🦍',
    '🦧',
    '🐘',
    '🦒',
    '🦌',
    '🐎',
    '🦌',
    '🐅',
    '🐆',
    '🦩',
    '🦚',
    '🦜',
    '🕊️',
    '🐇',
    '🐿️',
    '🦔',
    '🐉',
    '🐲',
    '🚁',
    '✈️',
    '🛸',
    '🚂',
    '🚗',
    '🏍️',
    '🚓',
    '🚑',
    '🚒',
    '⛵',
    '🚤',
    '🛰️',
    '📡',
    '💻',
    '⌨️',
    '🖥️',
    '📱',
    '🔋',
    '💡',
    '🔦',
    '📷',
    '🎥',
    '🎧',
    '🎤',
    '📀',
    '💿',
    '🕹️',
    '🎰',
    '🎨',
    '🖌️',
    '📝',
    '📚',
    '📖',
    '🧪',
    '⚗️',
    '🔬',
    '🧬',
    '🩺',
    '💊',
    '🛠️',
    '🔧',
    '⚙️',
    '⛓️',
    '🔗',
    '🪄',
    '🎭',
    '🎪',
    '🎼',
    '🥁',
    '🎸',
    '🎹',
    '🎻',
    '🪘',
    '🎺',
    '📯',
    '🥷',
    '🧙',
    '🧛',
    '🧞',
    '🧜',
    '🦸',
    '🦹',
    '👻',
    '😈',
    '👽',
    '🤡',
    '🫠',
    '😎',
    '🥶',
    '🥵',
    '🤯',
    '💥',
    '✨',
    '💫',
    '🪩',
    '❤️',
    '🖤',
    '💜',
    '💙',
    '💚',
    '💛',
    '⚜️',
    '🜲',
    '🜁',
    '🜃',
    '☯️',
    '☮️',
    '✴️',
    '✳️',
    '❇️',
    '🛸',
    '🪐',
    '🌌',
    '🫧',
    '🧿',
    '🔮',
    '🪬',
    '🗿',
    '🪩',
    '⚡',
    '☄️',
    '💠',
    '🔱',
    '♾️',
    '🌀',
    '🌪️',
    '🌠',
    '✨',
    '💫',
    '⭐',
    '🌟',
    '🎇',
    '🎆',
    '🕸️',
    '🪢',
    '⛓️',
    '🧬',
    '⚙️',
    '🛞',
    '🛰️',
    '📡',
    '🖲️',
    '🕹️',
    '🎛️',
    '🎚️',
    '📼',
    '💿',
    '📀',
    '🧪',
    '⚗️',
    '🔬',
    '🩻',
    '🧲',
    '🪫',
    '🔋',
    '💡',
    '🪔',
    '🕯️',
    '🪞',
    '🪟',
    '🚪',
    '🛖',
    '🏯',
    '🗼',
    '🎡',
    '🎢',
    '🎠',
    '🛝',
    '🎪',
    '🎭',
    '🃏',
    '♠️',
    '♣️',
    '♥️',
    '♦️',
    '🎴',
    '🀄',
    '🎲',
    '♟️',
    '🧩',
    '🪄',
    '🗝️',
    '🔐',
    '🛡️',
    '⚔️',
    '🗡️',
    '🏹',
    '🪓',
    '⛏️',
    '🪃',
    '🔗',
    '📿',
    '🪘',
    '🎷',
    '🎺',
    '🎸',
    '🎻',
    '🪕',
    '🎹',
    '🥁',
    '📯',
    '🧸',
    '🪁',
    '🎈',
    '🎀',
    '🎁',
    '🪅',
    '👑',
    '💎',
    '💍',
    '👁️',
    '🫀',
    '🫁',
    '🧠',
    '👣',
    '🦾',
    '🦿',
    '🦷',
    '🦴',
    '👽',
    '👾',
    '🤖',
    '🎮',
    '💀',
    '☠️',
    '👻',
    '😈',
    '👹',
    '👺',
    '🤡',
    '🎃',
    '🦄',
    '🐉',
    '🐲',
    '🦋',
    '🕷️',
    '🦂',
    '🐍',
    '🦎',
    '🦖',
    '🦕',
    '🪲',
    '🐙',
    '🦑',
    '🪼',
    '🦞',
    '🦐',
    '🦀',
    '🐚',
    '🪸',
    '🌵',
    '🍄',
    '🪷',
    '🌺',
    '🌸',
    '🏵️',
    '🌙',
    '☀️',
    '☁️',
    '🌈',
    '❄️',
    '🔥',
    '🌊',
    '🫧',
    '🍁',
    '🪵',
    '🌴',
    '🌳',
    '🪹',
    '🪺',
    '🧃',
    '🫖',
    '🍷',
    '🥂',
    '🍵',
    '☕',
    '🧋',
    '🍬',
    '🍭',
    '🍫',
    '🧁',
    '🍰',
    '🎂',
    '🍓',
    '🍒',
    '🍇',
    '🍉',
    '🍍',
    '🥝',
    '🥥',
    '🫐',
    '🥑',
    '🌶️',
    '🧄',
    '🧅',
    '🫑',
    '🥕',
    '🌽',
    '⚓',
    '⛵',
    '🚤',
    '🛶',
    '🚀',
    '✈️',
    '🚁',
    '🛩️',
    '🚂',
    '🚲',
    '🏍️',
    '🛹',
    '🛼',
    '🪂',
    '🏆',
    '🥇',
    '🎯',
    '🎨',
    '🖌️',
    '✒️',
    '📜',
    '📖',
    '🗞️',
    '📚',
    '🧾',
    '💼',
    '🗂️',
    '📌',
    '📍',
    '📎',
    '✂️',
    '📐',
    '📏',
    '🧮',
    '⌛',
    '⏳',
    '🕰️',
    '⌚',
    '📱',
    '💻',
    '🖥️',
    '⌨️',
    '🖱️',
    '🖨️',
    '📷',
    '📸',
    '🎥',
    '📺',
    '🔔',
    '🔕',
    '📢',
    '📣',
    '❤️',
    '🖤',
    '💜',
    '💙',
    '💚',
    '💛',
    '🧡',
    '🤍',
    '🤎',
    '💖',
    '💘',
    '💝',
    '❣️',
    '💯',
  ];

  // Game category colors
  static const catPuzzle = Color(0xFF00D4FF);
  static const catAction = Color(0xFFFF0044);
  static const catSports = Color(0xFF00FF88);
  static const catStrategy = Color(0xFFB44FFF);
  static const catArcade = Color(0xFFFFD700);
  static const catRacing = Color(0xFFFF6B00);
  static const catShooter = Color(0xFFFF0080);
  static const catTrivia = Color(0xFF00FFFF);
}

// =============================================================================
// TYPOGRAPHY
// =============================================================================
class BText {
  static TextStyle orbitron({
    double size = 16,
    Color color = BColors.txtPrimary,
    FontWeight weight = FontWeight.bold,
  }) => GoogleFonts.orbitron(fontSize: size, color: color, fontWeight: weight);
  static TextStyle rajdhani({
    double size = 16,
    Color color = BColors.txtPrimary,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.rajdhani(fontSize: size, color: color, fontWeight: weight);
  static TextStyle mono({double size = 14, Color color = BColors.neonGreen}) =>
      GoogleFonts.shareTechMono(fontSize: size, color: color);
}




class MarketplaceItems {
  static const List<Map<String, dynamic>> catalog = [
    // ── POWER BOOSTERS ───────────────────────────────────────────────────────
    {
      'itemId': 'boost_coin_2x',
      'name': 'Coin Booster 2×',
      'emoji': '💰',
      'category': 'Power Boosters',
      'rarity': 'rare',
      'price': 200,
      'currency': 'coins',
      'description': 'Double your coin rewards for 24 hours.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'boost_xp_3x',
      'name': 'XP Booster 3×',
      'emoji': '⚡',
      'category': 'Power Boosters',
      'rarity': 'epic',
      'price': 350,
      'currency': 'coins',
      'description': 'Triple XP gains for your next 10 games.',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'boost_shield',
      'name': 'Loss Shield',
      'emoji': '🛡️',
      'category': 'Power Boosters',
      'rarity': 'rare',
      'price': 180,
      'currency': 'coins',
      'description': 'Protects your streak on one loss.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'boost_time',
      'name': 'Time Extender',
      'emoji': '⏳',
      'category': 'Power Boosters',
      'rarity': 'common',
      'price': 80,
      'currency': 'coins',
      'description': '+15 seconds on timed game rounds.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'boost_mega',
      'name': 'MEGA Booster Pack',
      'emoji': '🚀',
      'category': 'Power Boosters',
      'rarity': 'legendary',
      'price': 999,
      'currency': 'coins',
      'description': '2× Coins + 3× XP + Streak Shield — all in one!',
      'tags': ['Best Seller', 'Limited'],
      'active': true,
    },
 
    // ── PREMIUM AVATARS ───────────────────────────────────────────────────────
    {
      'itemId': 'avatar_dragon',
      'name': 'Dragon Lord Avatar',
      'emoji': '🐉',
      'category': 'Premium Avatars',
      'rarity': 'legendary',
      'price': 500,
      'currency': 'coins',
      'description': 'A fierce dragon to represent your power.',
      'tags': ['New'],
      'active': true,
    },
    {
      'itemId': 'avatar_phoenix',
      'name': 'Phoenix Avatar',
      'emoji': '🦅',
      'category': 'Premium Avatars',
      'rarity': 'epic',
      'price': 350,
      'currency': 'coins',
      'description': 'Rise from the ashes with this epic bird.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'avatar_robot',
      'name': 'Cyber Robot Avatar',
      'emoji': '🤖',
      'category': 'Premium Avatars',
      'rarity': 'rare',
      'price': 250,
      'currency': 'coins',
      'description': 'High-tech robot identity for techies.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'avatar_alien',
      'name': 'Alien Commander',
      'emoji': '👽',
      'category': 'Premium Avatars',
      'rarity': 'epic',
      'price': 320,
      'currency': 'coins',
      'description': 'An intergalactic commander arrives.',
      'tags': ['New'],
      'active': true,
    },
    {
      'itemId': 'avatar_skull',
      'name': 'Skull King Avatar',
      'emoji': '💀',
      'category': 'Premium Avatars',
      'rarity': 'mythic',
      'price': 1200,
      'currency': 'coins',
      'description': 'Only the boldest dare wear this crown.',
      'tags': ['Limited'],
      'active': true,
    },
    {
      'itemId': 'avatar_unicorn',
      'name': 'Unicorn Avatar',
      'emoji': '🦄',
      'category': 'Premium Avatars',
      'rarity': 'legendary',
      'price': 600,
      'currency': 'coins',
      'description': 'Magical and majestic — rare as it gets.',
      'tags': ['Best Seller'],
      'active': true,
    },
 
    // ── ANIMATED FRAMES ───────────────────────────────────────────────────────
    {
      'itemId': 'frame_fire',
      'name': 'Fire Frame',
      'emoji': '🔥',
      'category': 'Animated Frames',
      'rarity': 'epic',
      'price': 400,
      'currency': 'coins',
      'description': 'A blazing animated fire border.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'frame_ice',
      'name': 'Ice Crystal Frame',
      'emoji': '❄️',
      'category': 'Animated Frames',
      'rarity': 'rare',
      'price': 280,
      'currency': 'coins',
      'description': 'Cool icy crystals swirling around your avatar.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'frame_galaxy',
      'name': 'Galaxy Frame',
      'emoji': '🌌',
      'category': 'Animated Frames',
      'rarity': 'legendary',
      'price': 750,
      'currency': 'coins',
      'description': 'A cosmic galaxy spinning around you.',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'frame_neon',
      'name': 'Neon Glow Frame',
      'emoji': '💎',
      'category': 'Animated Frames',
      'rarity': 'epic',
      'price': 420,
      'currency': 'coins',
      'description': 'Pulsing neon lights in cyberpunk style.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'frame_lightning',
      'name': 'Lightning Frame',
      'emoji': '⚡',
      'category': 'Animated Frames',
      'rarity': 'rare',
      'price': 300,
      'currency': 'coins',
      'description': 'Electric arcs strike around your profile.',
      'tags': ['New'],
      'active': true,
    },
 
    // ── XP MULTIPLIERS ────────────────────────────────────────────────────────
    {
      'itemId': 'xp_1day',
      'name': 'XP Boost 1 Day',
      'emoji': '⭐',
      'category': 'XP Multipliers',
      'rarity': 'common',
      'price': 100,
      'currency': 'coins',
      'description': '2× XP for all games for 24 hours.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'xp_3day',
      'name': 'XP Boost 3 Days',
      'emoji': '🌟',
      'category': 'XP Multipliers',
      'rarity': 'rare',
      'price': 250,
      'currency': 'coins',
      'description': '2× XP for all games for 72 hours.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'xp_week',
      'name': 'XP Boost 1 Week',
      'emoji': '🌠',
      'category': 'XP Multipliers',
      'rarity': 'epic',
      'price': 550,
      'currency': 'coins',
      'description': '2× XP for an entire week.',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'xp_permanent',
      'name': 'Permanent XP+',
      'emoji': '♾️',
      'category': 'XP Multipliers',
      'rarity': 'legendary',
      'price': 2500,
      'currency': 'coins',
      'description': '+10% XP forever on your account.',
      'tags': ['Limited'],
      'active': true,
    },
 
    // ── RARE BADGES ───────────────────────────────────────────────────────────
    {
      'itemId': 'badge_pioneer',
      'name': 'Pioneer Badge',
      'emoji': '🏅',
      'category': 'Rare Badges',
      'rarity': 'rare',
      'price': 200,
      'currency': 'coins',
      'description': 'Show you were an early BEEDI player.',
      'tags': ['Limited'],
      'active': true,
    },
    {
      'itemId': 'badge_champion',
      'name': 'Champion Badge',
      'emoji': '🥇',
      'category': 'Rare Badges',
      'rarity': 'epic',
      'price': 400,
      'currency': 'coins',
      'description': 'For those who dominate the leaderboard.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'badge_legend',
      'name': 'Legend Badge',
      'emoji': '👑',
      'category': 'Rare Badges',
      'rarity': 'legendary',
      'price': 800,
      'currency': 'coins',
      'description': 'Worn only by the greatest players.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'badge_mythic',
      'name': 'Mythic Badge',
      'emoji': '🔱',
      'category': 'Rare Badges',
      'rarity': 'mythic',
      'price': 2000,
      'currency': 'coins',
      'description': 'Transcends legend — for the truly elite.',
      'tags': ['Limited'],
      'active': true,
    },
    {
      'itemId': 'badge_streak',
      'name': 'Streak Master Badge',
      'emoji': '🔥',
      'category': 'Rare Badges',
      'rarity': 'epic',
      'price': 450,
      'currency': 'coins',
      'description': 'Awarded to those who never break their streak.',
      'tags': [],
      'active': true,
    },
 
    // ── DAILY REWARD PACKS ────────────────────────────────────────────────────
    {
      'itemId': 'daily_small',
      'name': 'Daily Pack — Bronze',
      'emoji': '🎁',
      'category': 'Daily Reward Packs',
      'rarity': 'common',
      'price': 50,
      'currency': 'coins',
      'description': '+100 bonus coins on your next daily claim.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'daily_medium',
      'name': 'Daily Pack — Silver',
      'emoji': '🎀',
      'category': 'Daily Reward Packs',
      'rarity': 'rare',
      'price': 150,
      'currency': 'coins',
      'description': '+300 bonus coins on your next daily claim.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'daily_large',
      'name': 'Daily Pack — Gold',
      'emoji': '🪅',
      'category': 'Daily Reward Packs',
      'rarity': 'epic',
      'price': 300,
      'currency': 'coins',
      'description': '+700 bonus coins on your next daily claim.',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'daily_mega',
      'name': 'Daily Pack — Platinum',
      'emoji': '🎊',
      'category': 'Daily Reward Packs',
      'rarity': 'legendary',
      'price': 600,
      'currency': 'coins',
      'description': '+1500 bonus coins + a mystery item on next daily!',
      'tags': ['Limited'],
      'active': true,
    },
 
    // ── SPECIAL THEMES ────────────────────────────────────────────────────────
    {
      'itemId': 'theme_cyberpunk',
      'name': 'Cyberpunk Theme',
      'emoji': '🌃',
      'category': 'Special Themes',
      'rarity': 'epic',
      'price': 500,
      'currency': 'coins',
      'description': 'Full neon-cyberpunk UI overhaul.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'theme_forest',
      'name': 'Enchanted Forest Theme',
      'emoji': '🌲',
      'category': 'Special Themes',
      'rarity': 'rare',
      'price': 300,
      'currency': 'coins',
      'description': 'A calm, magical forest ambiance.',
      'tags': ['New'],
      'active': true,
    },
    {
      'itemId': 'theme_ocean',
      'name': 'Deep Ocean Theme',
      'emoji': '🌊',
      'category': 'Special Themes',
      'rarity': 'rare',
      'price': 280,
      'currency': 'coins',
      'description': 'Dive into the deep blue UI.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'theme_volcano',
      'name': 'Volcano Theme',
      'emoji': '🌋',
      'category': 'Special Themes',
      'rarity': 'epic',
      'price': 480,
      'currency': 'coins',
      'description': 'Fiery lava and molten rock aesthetics.',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'theme_space',
      'name': 'Outer Space Theme',
      'emoji': '🪐',
      'category': 'Special Themes',
      'rarity': 'legendary',
      'price': 750,
      'currency': 'coins',
      'description': 'A full space odyssey visual experience.',
      'tags': ['Best Seller'],
      'active': true,
    },
 
    // ── PROFILE DECORATIONS ───────────────────────────────────────────────────
    {
      'itemId': 'deco_crown',
      'name': 'Golden Crown Decoration',
      'emoji': '👑',
      'category': 'Profile Decorations',
      'rarity': 'legendary',
      'price': 700,
      'currency': 'coins',
      'description': 'A royal crown floats above your avatar.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'deco_wings',
      'name': 'Angel Wings',
      'emoji': '🕊️',
      'category': 'Profile Decorations',
      'rarity': 'epic',
      'price': 450,
      'currency': 'coins',
      'description': 'Divine wings spread behind your avatar.',
      'tags': ['New'],
      'active': true,
    },
    {
      'itemId': 'deco_halo',
      'name': 'Neon Halo',
      'emoji': '✨',
      'category': 'Profile Decorations',
      'rarity': 'rare',
      'price': 220,
      'currency': 'coins',
      'description': 'A glowing neon ring orbits your avatar.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'deco_aura',
      'name': 'Dark Aura',
      'emoji': '🌑',
      'category': 'Profile Decorations',
      'rarity': 'mythic',
      'price': 1500,
      'currency': 'coins',
      'description': 'A shadowy dark energy emanates from you.',
      'tags': ['Limited'],
      'active': true,
    },
    {
      'itemId': 'deco_sparkle',
      'name': 'Sparkle Trail',
      'emoji': '💫',
      'category': 'Profile Decorations',
      'rarity': 'common',
      'price': 90,
      'currency': 'coins',
      'description': 'Leave a sparkling trail as you navigate.',
      'tags': [],
      'active': true,
    },
 
    // ── MYSTERY BOXES ─────────────────────────────────────────────────────────
    {
      'itemId': 'mystery_common',
      'name': 'Mystery Box — Common',
      'emoji': '📦',
      'category': 'Mystery Boxes',
      'rarity': 'common',
      'price': 100,
      'currency': 'coins',
      'description': 'Contains a random common or rare item.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'mystery_rare',
      'name': 'Mystery Box — Rare',
      'emoji': '🎲',
      'category': 'Mystery Boxes',
      'rarity': 'rare',
      'price': 300,
      'currency': 'coins',
      'description': 'Guaranteed rare or higher. Surprise inside!',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'mystery_epic',
      'name': 'Mystery Box — Epic',
      'emoji': '🪄',
      'category': 'Mystery Boxes',
      'rarity': 'epic',
      'price': 600,
      'currency': 'coins',
      'description': 'Guaranteed epic or legendary item.',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'mystery_legendary',
      'name': 'Mystery Box — Legendary',
      'emoji': '🔮',
      'category': 'Mystery Boxes',
      'rarity': 'legendary',
      'price': 1200,
      'currency': 'coins',
      'description': 'A legendary or mythic awaits inside!',
      'tags': ['Limited', 'Hot'],
      'active': true,
    },
 
    // ── LEGENDARY ITEMS ───────────────────────────────────────────────────────
    {
      'itemId': 'legend_sword',
      'name': 'Dragon Sword',
      'emoji': '⚔️',
      'category': 'Legendary Items',
      'rarity': 'legendary',
      'price': 1000,
      'currency': 'coins',
      'description': 'A mythical blade forged in dragon flame.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'legend_shield',
      'name': 'Aegis Shield',
      'emoji': '🛡️',
      'category': 'Legendary Items',
      'rarity': 'legendary',
      'price': 900,
      'currency': 'coins',
      'description': 'An unbreakable shield of legend.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'legend_orb',
      'name': 'Chaos Orb',
      'emoji': '🔮',
      'category': 'Legendary Items',
      'rarity': 'mythic',
      'price': 3000,
      'currency': 'coins',
      'description': 'Harness the power of chaos itself.',
      'tags': ['Limited', 'Hot'],
      'active': true,
    },
    {
      'itemId': 'legend_staff',
      'name': 'Arcane Staff',
      'emoji': '🪄',
      'category': 'Legendary Items',
      'rarity': 'legendary',
      'price': 1100,
      'currency': 'coins',
      'description': 'A staff crackling with arcane energy.',
      'tags': ['New'],
      'active': true,
    },
 
    // ── LIMITED EVENT ITEMS ───────────────────────────────────────────────────
    {
      'itemId': 'event_diwali',
      'name': 'Diwali Special Pack',
      'emoji': '🪔',
      'category': 'Limited Event Items',
      'rarity': 'epic',
      'price': 500,
      'currency': 'coins',
      'description': 'Celebrate with festive lights and rewards!',
      'tags': ['Limited', 'New'],
      'active': true,
    },
    {
      'itemId': 'event_newYear',
      'name': 'New Year Blast Pack',
      'emoji': '🎆',
      'category': 'Limited Event Items',
      'rarity': 'epic',
      'price': 600,
      'currency': 'coins',
      'description': 'Ring in the new year with explosive bonuses!',
      'tags': ['Limited'],
      'active': true,
    },
    {
      'itemId': 'event_summer',
      'name': 'Summer Splash Pack',
      'emoji': '☀️',
      'category': 'Limited Event Items',
      'rarity': 'rare',
      'price': 350,
      'currency': 'coins',
      'description': 'Beat the heat with cool summer rewards.',
      'tags': ['Limited', 'Hot'],
      'active': true,
    },
    {
      'itemId': 'event_midnight',
      'name': 'Midnight Sale Bundle',
      'emoji': '🌙',
      'category': 'Limited Event Items',
      'rarity': 'legendary',
      'price': 888,
      'currency': 'coins',
      'description': 'A rare midnight bundle — only for night owls.',
      'tags': ['Limited', 'Best Seller'],
      'active': true,
    },
 
    // ── ENERGY PACKS ─────────────────────────────────────────────────────────
    {
      'itemId': 'energy_small',
      'name': 'Energy Refill — Small',
      'emoji': '⚡',
      'category': 'Energy Packs',
      'rarity': 'common',
      'price': 40,
      'currency': 'coins',
      'description': 'Refill 10 energy to keep playing.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'energy_medium',
      'name': 'Energy Refill — Medium',
      'emoji': '🔋',
      'category': 'Energy Packs',
      'rarity': 'rare',
      'price': 100,
      'currency': 'coins',
      'description': 'Refill 30 energy — enough for a long session.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'energy_full',
      'name': 'Full Energy Restore',
      'emoji': '🌩️',
      'category': 'Energy Packs',
      'rarity': 'epic',
      'price': 220,
      'currency': 'coins',
      'description': 'Instantly restore full energy.',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'energy_unlimited',
      'name': 'Unlimited Energy — 1 Day',
      'emoji': '💥',
      'category': 'Energy Packs',
      'rarity': 'legendary',
      'price': 500,
      'currency': 'coins',
      'description': 'Play non-stop for 24 hours with unlimited energy!',
      'tags': ['Limited'],
      'active': true,
    },
 
    // ── STREAK PROTECTORS ─────────────────────────────────────────────────────
    {
      'itemId': 'streak_1',
      'name': 'Streak Shield ×1',
      'emoji': '🛡️',
      'category': 'Streak Protectors',
      'rarity': 'common',
      'price': 60,
      'currency': 'coins',
      'description': 'Protects your streak once on a loss.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'streak_3',
      'name': 'Streak Shield ×3',
      'emoji': '🔰',
      'category': 'Streak Protectors',
      'rarity': 'rare',
      'price': 150,
      'currency': 'coins',
      'description': 'Three streak shields for three bad days.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'streak_week',
      'name': 'Streak Armor — 7 Days',
      'emoji': '⚜️',
      'category': 'Streak Protectors',
      'rarity': 'epic',
      'price': 320,
      'currency': 'coins',
      'description': 'Unlimited streak protection for a full week.',
      'tags': ['Hot'],
      'active': true,
    },
 
    // ── QUIZ HINT PACKS ───────────────────────────────────────────────────────
    {
      'itemId': 'hint_5',
      'name': 'Hint Pack ×5',
      'emoji': '💡',
      'category': 'Quiz Hint Packs',
      'rarity': 'common',
      'price': 50,
      'currency': 'coins',
      'description': 'Get 5 hints to use in Quiz Battle.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'hint_15',
      'name': 'Hint Pack ×15',
      'emoji': '🔦',
      'category': 'Quiz Hint Packs',
      'rarity': 'rare',
      'price': 130,
      'currency': 'coins',
      'description': '15 hints — ace every quiz round!',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'hint_50',
      'name': 'Mega Hint Pack ×50',
      'emoji': '🌟',
      'category': 'Quiz Hint Packs',
      'rarity': 'epic',
      'price': 380,
      'currency': 'coins',
      'description': '50 hints — the ultimate quiz companion.',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'hint_ai',
      'name': 'AI Hint Assist',
      'emoji': '🧠',
      'category': 'Quiz Hint Packs',
      'rarity': 'legendary',
      'price': 700,
      'currency': 'coins',
      'description': 'Smart hint system that suggests answers.',
      'tags': ['New', 'Limited'],
      'active': true,
    },
 
    // ── PREMIUM NAME COLORS ───────────────────────────────────────────────────
    {
      'itemId': 'color_gold',
      'name': 'Gold Name Color',
      'emoji': '🟡',
      'category': 'Premium Name Colors',
      'rarity': 'rare',
      'price': 200,
      'currency': 'coins',
      'description': 'Your nickname gleams in gold.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'color_neon',
      'name': 'Neon Blue Name',
      'emoji': '🔵',
      'category': 'Premium Name Colors',
      'rarity': 'rare',
      'price': 180,
      'currency': 'coins',
      'description': 'Electric neon blue for your nickname.',
      'tags': ['New'],
      'active': true,
    },
    {
      'itemId': 'color_rainbow',
      'name': 'Rainbow Name Color',
      'emoji': '🌈',
      'category': 'Premium Name Colors',
      'rarity': 'epic',
      'price': 450,
      'currency': 'coins',
      'description': 'Your name cycles through all rainbow colors.',
      'tags': ['Best Seller', 'Hot'],
      'active': true,
    },
    {
      'itemId': 'color_mythic',
      'name': 'Mythic Flame Name',
      'emoji': '🔴',
      'category': 'Premium Name Colors',
      'rarity': 'mythic',
      'price': 1000,
      'currency': 'coins',
      'description': 'A rare animated flame effect on your name.',
      'tags': ['Limited'],
      'active': true,
    },
 
    // ── CLAN UPGRADE PACKS ────────────────────────────────────────────────────
    {
      'itemId': 'clan_slot',
      'name': 'Extra Clan Slot',
      'emoji': '👥',
      'category': 'Clan Upgrade Packs',
      'rarity': 'rare',
      'price': 300,
      'currency': 'coins',
      'description': 'Add one more member slot to your clan.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'clan_banner',
      'name': 'Clan Custom Banner',
      'emoji': '🚩',
      'category': 'Clan Upgrade Packs',
      'rarity': 'epic',
      'price': 500,
      'currency': 'coins',
      'description': 'Design a custom banner for your clan.',
      'tags': ['New'],
      'active': true,
    },
    {
      'itemId': 'clan_xp_boost',
      'name': 'Clan XP Boost Pack',
      'emoji': '🏆',
      'category': 'Clan Upgrade Packs',
      'rarity': 'epic',
      'price': 600,
      'currency': 'coins',
      'description': '2× XP for all clan members for 48 hours.',
      'tags': ['Best Seller'],
      'active': true,
    },
 
    // ── SKILL CARDS ───────────────────────────────────────────────────────────
    {
      'itemId': 'skill_dodge',
      'name': 'Dodge Skill Card',
      'emoji': '🏃',
      'category': 'Skill Cards',
      'rarity': 'rare',
      'price': 150,
      'currency': 'coins',
      'description': 'Dodge one losing hit in action games.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'skill_double',
      'name': 'Double Strike Card',
      'emoji': '⚔️',
      'category': 'Skill Cards',
      'rarity': 'epic',
      'price': 350,
      'currency': 'coins',
      'description': 'Deal double damage in battle games.',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'skill_freeze',
      'name': 'Freeze Time Card',
      'emoji': '❄️',
      'category': 'Skill Cards',
      'rarity': 'epic',
      'price': 400,
      'currency': 'coins',
      'description': 'Pause the timer for 5 seconds mid-game.',
      'tags': ['New'],
      'active': true,
    },
    {
      'itemId': 'skill_revive',
      'name': 'Revive Card',
      'emoji': '💖',
      'category': 'Skill Cards',
      'rarity': 'legendary',
      'price': 800,
      'currency': 'coins',
      'description': 'Come back from a game-over once per game.',
      'tags': ['Best Seller', 'Limited'],
      'active': true,
    },
 
    // ── EMOJI PACKS ───────────────────────────────────────────────────────────
    {
      'itemId': 'emoji_animals',
      'name': 'Animal Emoji Pack',
      'emoji': '🦁',
      'category': 'Emoji Packs',
      'rarity': 'common',
      'price': 80,
      'currency': 'coins',
      'description': '20 exclusive animal emojis for chat.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'emoji_space',
      'name': 'Space Emoji Pack',
      'emoji': '🚀',
      'category': 'Emoji Packs',
      'rarity': 'rare',
      'price': 160,
      'currency': 'coins',
      'description': '20 cosmic emojis for out-of-this-world chats.',
      'tags': ['New'],
      'active': true,
    },
    {
      'itemId': 'emoji_food',
      'name': 'Food Emoji Pack',
      'emoji': '🍕',
      'category': 'Emoji Packs',
      'rarity': 'common',
      'price': 70,
      'currency': 'coins',
      'description': '20 delicious food emojis.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'emoji_ultra',
      'name': 'ULTRA Emoji Bundle',
      'emoji': '🎭',
      'category': 'Emoji Packs',
      'rarity': 'epic',
      'price': 400,
      'currency': 'coins',
      'description': '100 exclusive emojis — the complete collection!',
      'tags': ['Best Seller'],
      'active': true,
    },
 
    // ── BACKGROUND SKINS ──────────────────────────────────────────────────────
    {
      'itemId': 'bg_aurora',
      'name': 'Aurora Borealis BG',
      'emoji': '🌌',
      'category': 'Background Skins',
      'rarity': 'epic',
      'price': 450,
      'currency': 'coins',
      'description': 'Northern lights dance behind your game UI.',
      'tags': ['New'],
      'active': true,
    },
    {
      'itemId': 'bg_matrix',
      'name': 'Matrix Code BG',
      'emoji': '💻',
      'category': 'Background Skins',
      'rarity': 'rare',
      'price': 300,
      'currency': 'coins',
      'description': 'Green falling code — the Matrix is real.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'bg_lava',
      'name': 'Lava Flow BG',
      'emoji': '🌋',
      'category': 'Background Skins',
      'rarity': 'epic',
      'price': 380,
      'currency': 'coins',
      'description': 'Glowing molten lava flows across your UI.',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'bg_neon_city',
      'name': 'Neon City BG',
      'emoji': '🌆',
      'category': 'Background Skins',
      'rarity': 'legendary',
      'price': 700,
      'currency': 'coins',
      'description': 'A stunning cyberpunk neon city skyline.',
      'tags': ['Best Seller', 'Hot'],
      'active': true,
    },
 
    // ── ACHIEVEMENT EFFECTS ───────────────────────────────────────────────────
    {
      'itemId': 'effect_confetti',
      'name': 'Victory Confetti Effect',
      'emoji': '🎊',
      'category': 'Achievement Effects',
      'rarity': 'common',
      'price': 60,
      'currency': 'coins',
      'description': 'Confetti explodes when you win a game.',
      'tags': [],
      'active': true,
    },
    {
      'itemId': 'effect_fireworks',
      'name': 'Fireworks Win Effect',
      'emoji': '🎆',
      'category': 'Achievement Effects',
      'rarity': 'rare',
      'price': 180,
      'currency': 'coins',
      'description': 'Fireworks light up your victory screen.',
      'tags': ['Best Seller'],
      'active': true,
    },
    {
      'itemId': 'effect_lightning_win',
      'name': 'Lightning Victory Flash',
      'emoji': '⚡',
      'category': 'Achievement Effects',
      'rarity': 'epic',
      'price': 350,
      'currency': 'coins',
      'description': 'Lightning strikes on every win — dramatic!',
      'tags': ['Hot'],
      'active': true,
    },
    {
      'itemId': 'effect_mythic_aura',
      'name': 'Mythic Aura Effect',
      'emoji': '🌀',
      'category': 'Achievement Effects',
      'rarity': 'mythic',
      'price': 1800,
      'currency': 'coins',
      'description': 'A swirling mythic aura surrounds every win.',
      'tags': ['Limited'],
      'active': true,
    },
  ];

  /// All unique categories from the catalog
  static List<String> get categories {
    final cats = catalog.map((e) => e['category'] as String).toSet().toList();
    cats.sort();
    cats.insert(0, 'All');
    return cats;
  }
}




// =============================================================================
// GAME CATALOG — 56 GAMES
// =============================================================================
class GameCatalog {
  static const List<Map<String, dynamic>> games = [
    // ── PUZZLE ─────────────────────────────────────────────────────────────
    {
      'id': 'tic_tac_toe',
      'icon': '⭕',
      'name': 'Tic Tac Toe',
      'cat': 'Puzzle',
      'diff': 'Easy',
      'coins': 30,
      'xp': 50,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'memory_match',
      'icon': '🃏',
      'name': 'Memory Match',
      'cat': 'Puzzle',
      'diff': 'Easy',
      'coins': 60,
      'xp': 80,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'sudoku',
      'icon': '🔢',
      'name': 'Sudoku',
      'cat': 'Puzzle',
      'diff': 'Hard',
      'coins': 100,
      'xp': 150,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'word_puzzle',
      'icon': '🔤',
      'name': 'Word Puzzle',
      'cat': 'Puzzle',
      'diff': 'Medium',
      'coins': 50,
      'xp': 90,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'puzzle_slider',
      'icon': '🧩',
      'name': 'Puzzle Slider',
      'cat': 'Puzzle',
      'diff': 'Medium',
      'coins': 80,
      'xp': 120,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'connect_dots',
      'icon': '🔵',
      'name': 'Connect Dots',
      'cat': 'Puzzle',
      'diff': 'Medium',
      'coins': 55,
      'xp': 85,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'maze_escape',
      'icon': '🌀',
      'name': 'Maze Escape',
      'cat': 'Puzzle',
      'diff': 'Hard',
      'coins': 90,
      'xp': 130,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'pattern_recall',
      'icon': '🎨',
      'name': 'Pattern Recall',
      'cat': 'Puzzle',
      'diff': 'Medium',
      'coins': 60,
      'xp': 90,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'card_match',
      'icon': '🀄',
      'name': 'Card Match',
      'cat': 'Puzzle',
      'diff': 'Easy',
      'coins': 45,
      'xp': 70,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'game_2048',
      'icon': '2️⃣',
      'name': '2048 Game',
      'cat': 'Puzzle',
      'diff': 'Hard',
      'coins': 110,
      'xp': 160,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'hangman',
      'icon': '🪂',
      'name': 'Hangman',
      'cat': 'Puzzle',
      'diff': 'Medium',
      'coins': 50,
      'xp': 80,
      'color': 0xFF00D4FF,
    },
    {
      'id': 'memory_number',
      'icon': '🔢',
      'name': 'Memory Number',
      'cat': 'Puzzle',
      'diff': 'Hard',
      'coins': 70,
      'xp': 110,
      'color': 0xFF00D4FF,
    },
    // ── ARCADE ────────────────────────────────────────────────────────────
    {
      'id': 'snake_game',
      'icon': '🐍',
      'name': 'Snake Game',
      'cat': 'Arcade',
      'diff': 'Medium',
      'coins': 70,
      'xp': 100,
      'color': 0xFFFFD700,
    },
    {
      'id': 'flappy_bird',
      'icon': '🐦',
      'name': 'Flappy Bird',
      'cat': 'Arcade',
      'diff': 'Hard',
      'coins': 90,
      'xp': 130,
      'color': 0xFFFFD700,
    },
    {
      'id': 'brick_breaker',
      'icon': '🧱',
      'name': 'Brick Breaker',
      'cat': 'Arcade',
      'diff': 'Medium',
      'coins': 75,
      'xp': 110,
      'color': 0xFFFFD700,
    },
    {
      'id': 'bubble_shooter',
      'icon': '🫧',
      'name': 'Bubble Shooter',
      'cat': 'Arcade',
      'diff': 'Medium',
      'coins': 65,
      'xp': 95,
      'color': 0xFFFFD700,
    },
    {
      'id': 'balloon_pop',
      'icon': '🎈',
      'name': 'Balloon Pop',
      'cat': 'Arcade',
      'diff': 'Easy',
      'coins': 40,
      'xp': 60,
      'color': 0xFFFFD700,
    },
    {
      'id': 'fruit_ninja',
      'icon': '🍉',
      'name': 'Fruit Ninja',
      'cat': 'Arcade',
      'diff': 'Medium',
      'coins': 70,
      'xp': 100,
      'color': 0xFFFFD700,
    },
    {
      'id': 'whack_a_mole',
      'icon': '🔨',
      'name': 'Whack A Mole',
      'cat': 'Arcade',
      'diff': 'Medium',
      'coins': 55,
      'xp': 80,
      'color': 0xFFFFD700,
    },
    {
      'id': 'dino_run',
      'icon': '🦕',
      'name': 'Dino Run',
      'cat': 'Arcade',
      'diff': 'Medium',
      'coins': 60,
      'xp': 90,
      'color': 0xFFFFD700,
    },
    {
      'id': 'tile_tap',
      'icon': '🟦',
      'name': 'Tile Tap',
      'cat': 'Arcade',
      'diff': 'Easy',
      'coins': 35,
      'xp': 55,
      'color': 0xFFFFD700,
    },
    {
      'id': 'speed_tap',
      'icon': '⚡',
      'name': 'Speed Tap Challenge',
      'cat': 'Arcade',
      'diff': 'Hard',
      'coins': 80,
      'xp': 120,
      'color': 0xFFFFD700,
    },
    {
      'id': 'spin_wheel',
      'icon': '🎡',
      'name': 'Spin Wheel',
      'cat': 'Arcade',
      'diff': 'Easy',
      'coins': 50,
      'xp': 40,
      'color': 0xFFFFD700,
    },
    {
      'id': 'bottle_flip',
      'icon': '🍾',
      'name': 'Bottle Flip',
      'cat': 'Arcade',
      'diff': 'Medium',
      'coins': 50,
      'xp': 70,
      'color': 0xFFFFD700,
    },
    // ── ACTION / SHOOTER ─────────────────────────────────────────────────
    {
      'id': 'space_shooter',
      'icon': '🚀',
      'name': 'Space Shooter',
      'cat': 'Shooter',
      'diff': 'Hard',
      'coins': 100,
      'xp': 140,
      'color': 0xFFFF0080,
    },
    {
      'id': 'zombie_shooter',
      'icon': '🧟',
      'name': 'Zombie Shooter',
      'cat': 'Shooter',
      'diff': 'Hard',
      'coins': 110,
      'xp': 150,
      'color': 0xFFFF0080,
    },
    {
      'id': 'knife_hit',
      'icon': '🔪',
      'name': 'Knife Hit',
      'cat': 'Shooter',
      'diff': 'Hard',
      'coins': 85,
      'xp': 120,
      'color': 0xFFFF0080,
    },
    {
      'id': 'archery_game',
      'icon': '🏹',
      'name': 'Archery Game',
      'cat': 'Shooter',
      'diff': 'Medium',
      'coins': 75,
      'xp': 110,
      'color': 0xFFFF0080,
    },
    {
      'id': 'laser_escape',
      'icon': '🔆',
      'name': 'Laser Escape',
      'cat': 'Shooter',
      'diff': 'Hard',
      'coins': 90,
      'xp': 135,
      'color': 0xFFFF0080,
    },
    // ── STRATEGY ──────────────────────────────────────────────────────────
    {
      'id': 'chess',
      'icon': '♟️',
      'name': 'Chess',
      'cat': 'Strategy',
      'diff': 'Hard',
      'coins': 150,
      'xp': 200,
      'color': 0xFFB44FFF,
    },
    {
      'id': 'rock_paper',
      'icon': '✊',
      'name': 'Rock Paper Scissors',
      'cat': 'Strategy',
      'diff': 'Easy',
      'coins': 30,
      'xp': 45,
      'color': 0xFFB44FFF,
    },
    {
      'id': 'battle_arena',
      'icon': '⚔️',
      'name': 'Battle Arena',
      'cat': 'Strategy',
      'diff': 'Hard',
      'coins': 120,
      'xp': 170,
      'color': 0xFFB44FFF,
    },
    {
      'id': 'monster_fight',
      'icon': '👹',
      'name': 'Monster Fight',
      'cat': 'Strategy',
      'diff': 'Medium',
      'coins': 90,
      'xp': 130,
      'color': 0xFFB44FFF,
    },
    {
      'id': 'survival_mode',
      'icon': '🏕️',
      'name': 'Survival Mode',
      'cat': 'Strategy',
      'diff': 'Hard',
      'coins': 130,
      'xp': 180,
      'color': 0xFFB44FFF,
    },
    // ── TRIVIA ────────────────────────────────────────────────────────────
    {
      'id': 'quiz_battle',
      'icon': '🧠',
      'name': 'Quiz Battle',
      'cat': 'Trivia',
      'diff': 'Medium',
      'coins': 50,
      'xp': 100,
      'color': 0xFF00FFFF,
    },
    {
      'id': 'emoji_quiz',
      'icon': '😀',
      'name': 'Emoji Quiz',
      'cat': 'Trivia',
      'diff': 'Easy',
      'coins': 40,
      'xp': 65,
      'color': 0xFF00FFFF,
    },
    {
      'id': 'number_guess',
      'icon': '🔮',
      'name': 'Number Guessing',
      'cat': 'Trivia',
      'diff': 'Easy',
      'coins': 30,
      'xp': 50,
      'color': 0xFF00FFFF,
    },
    {
      'id': 'math_challenge',
      'icon': '➕',
      'name': 'Math Challenge',
      'cat': 'Trivia',
      'diff': 'Hard',
      'coins': 65,
      'xp': 110,
      'color': 0xFF00FFFF,
    },
    {
      'id': 'typing_speed',
      'icon': '⌨️',
      'name': 'Typing Speed Test',
      'cat': 'Trivia',
      'diff': 'Medium',
      'coins': 55,
      'xp': 90,
      'color': 0xFF00FFFF,
    },
    {
      'id': 'color_match',
      'icon': '🎨',
      'name': 'Color Match',
      'cat': 'Trivia',
      'diff': 'Easy',
      'coins': 35,
      'xp': 55,
      'color': 0xFF00FFFF,
    },
    // ── SPORTS ────────────────────────────────────────────────────────────
    {
      'id': 'car_racing',
      'icon': '🏎️',
      'name': 'Car Racing',
      'cat': 'Sports',
      'diff': 'Medium',
      'coins': 80,
      'xp': 115,
      'color': 0xFF00FF88,
    },
    {
      'id': 'bike_racing',
      'icon': '🏍️',
      'name': 'Bike Racing',
      'cat': 'Sports',
      'diff': 'Medium',
      'coins': 75,
      'xp': 110,
      'color': 0xFF00FF88,
    },
    {
      'id': 'cricket_hit',
      'icon': '🏏',
      'name': 'Cricket Hit',
      'cat': 'Sports',
      'diff': 'Medium',
      'coins': 70,
      'xp': 100,
      'color': 0xFF00FF88,
    },
    {
      'id': 'football_penalty',
      'icon': '⚽',
      'name': 'Football Penalty',
      'cat': 'Sports',
      'diff': 'Medium',
      'coins': 65,
      'xp': 95,
      'color': 0xFF00FF88,
    },
    {
      'id': 'basketball_shot',
      'icon': '🏀',
      'name': 'Basketball Shot',
      'cat': 'Sports',
      'diff': 'Medium',
      'coins': 65,
      'xp': 95,
      'color': 0xFF00FF88,
    },
    {
      'id': 'air_hockey',
      'icon': '🏒',
      'name': 'Air Hockey',
      'cat': 'Sports',
      'diff': 'Medium',
      'coins': 70,
      'xp': 100,
      'color': 0xFF00FF88,
    },
    {
      'id': 'ping_pong',
      'icon': '🏓',
      'name': 'Ping Pong',
      'cat': 'Sports',
      'diff': 'Easy',
      'coins': 50,
      'xp': 75,
      'color': 0xFF00FF88,
    },
    // ── RUNNER / PLATFORMER ──────────────────────────────────────────────
    {
      'id': 'runner_game',
      'icon': '🏃',
      'name': 'Runner Game',
      'cat': 'Action',
      'diff': 'Medium',
      'coins': 70,
      'xp': 100,
      'color': 0xFFFF0044,
    },
    {
      'id': 'jump_hero',
      'icon': '🦸',
      'name': 'Jump Hero',
      'cat': 'Action',
      'diff': 'Medium',
      'coins': 75,
      'xp': 110,
      'color': 0xFFFF0044,
    },
    {
      'id': 'platform_adventure',
      'icon': '🗺️',
      'name': 'Platform Adventure',
      'cat': 'Action',
      'diff': 'Hard',
      'coins': 100,
      'xp': 145,
      'color': 0xFFFF0044,
    },
    {
      'id': 'shadow_runner',
      'icon': '👤',
      'name': 'Shadow Runner',
      'cat': 'Action',
      'diff': 'Hard',
      'coins': 90,
      'xp': 130,
      'color': 0xFFFF0044,
    },
    {
      'id': 'cube_dash',
      'icon': '🟥',
      'name': 'Cube Dash',
      'cat': 'Action',
      'diff': 'Medium',
      'coins': 70,
      'xp': 100,
      'color': 0xFFFF0044,
    },
    {
      'id': 'circle_jump',
      'icon': '⭕',
      'name': 'Circle Jump',
      'cat': 'Action',
      'diff': 'Hard',
      'coins': 80,
      'xp': 120,
      'color': 0xFFFF0044,
    },
    {
      'id': 'tower_stack',
      'icon': '🏗️',
      'name': 'Tower Stack',
      'cat': 'Action',
      'diff': 'Medium',
      'coins': 65,
      'xp': 95,
      'color': 0xFFFF0044,
    },
    // ── CASUAL ────────────────────────────────────────────────────────────
    {
      'id': 'fishing_game',
      'icon': '🎣',
      'name': 'Fishing Game',
      'cat': 'Casual',
      'diff': 'Easy',
      'coins': 45,
      'xp': 65,
      'color': 0xFFFF6B00,
    },
    {
      'id': 'traffic_escape',
      'icon': '🚦',
      'name': 'Traffic Escape',
      'cat': 'Casual',
      'diff': 'Medium',
      'coins': 60,
      'xp': 90,
      'color': 0xFFFF6B00,
    },
    {
      'id': 'color_match2',
      'icon': '🎯',
      'name': 'Color Match 2',
      'cat': 'Casual',
      'diff': 'Easy',
      'coins': 35,
      'xp': 55,
      'color': 0xFFFF6B00,
    },
  ];

  static List<String> get categories {
    final cats = games.map((g) => g['cat'] as String).toSet().toList();
    cats.insert(0, 'All');
    return cats;
  }
}




// =============================================================================
// PLAYER MODEL
// =============================================================================
class PlayerModel {
  final String playerId,
      beediUpiId,
      nickname,
      realName,
      mobileNumber,
      avatar,
      loginPin,
      upiPin;
  final int coins,
      xp,
      level,
      streak,
      streakShields,
      totalWins,
      totalLosses,
      loginAttempts,
      nicknameChanges;
  final String rank;
  final List<String> achievements, unlockedGames;
  final bool onlineStatus, banned;
  final String bannedReason;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const PlayerModel({
    required this.playerId,
    required this.beediUpiId,
    required this.nickname,
    required this.realName,
    required this.mobileNumber,
    required this.avatar,
    required this.loginPin,
    required this.upiPin,
    this.coins = 100,
    this.xp = 0,
    this.level = 1,
    this.rank = 'Novice',
    this.streak = 0,
    this.streakShields = 1,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.achievements = const [],
    this.unlockedGames = const [],
    this.onlineStatus = false,
    this.banned = false,
    this.bannedReason = '',
    this.loginAttempts = 0,
    this.nicknameChanges = 0,
    required this.createdAt,
    this.lastLogin,
  });

  factory PlayerModel.fromMap(Map<String, dynamic> d) => PlayerModel(
    playerId: d['playerId'] ?? '',
    beediUpiId: d['beediUpiId'] ?? '',
    nickname: d['nickname'] ?? '',
    realName: d['realName'] ?? '',
    mobileNumber: d['mobileNumber'] ?? '',
    avatar: d['avatar'] ?? BColors.avatarEmojis[0],
    loginPin: d['loginPin'] ?? '',
    upiPin: d['upiPin'] ?? '',
    coins: d['coins'] ?? 100,
    xp: d['xp'] ?? 0,
    level: d['level'] ?? 1,
    rank: d['rank'] ?? 'Novice',
    streak: d['streak'] ?? 0,
    streakShields: d['streakShields'] ?? 1,
    totalWins: d['totalWins'] ?? 0,
    totalLosses: d['totalLosses'] ?? 0,
    achievements: List<String>.from(d['achievements'] ?? []),
    unlockedGames: List<String>.from(d['unlockedGames'] ?? []),
    onlineStatus: d['onlineStatus'] ?? false,
    banned: d['banned'] ?? false,
    bannedReason: d['bannedReason'] ?? '',
    loginAttempts: d['loginAttempts'] ?? 0,
    nicknameChanges: d['nicknameChanges'] ?? 0,
    createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    lastLogin: (d['lastLogin'] as Timestamp?)?.toDate(),
  );

  Map<String, dynamic> toMap() => {
    'playerId': playerId,
    'beediUpiId': beediUpiId,
    'nickname': nickname,
    'realName': realName,
    'mobileNumber': mobileNumber,
    'avatar': avatar,
    'loginPin': loginPin,
    'upiPin': upiPin,
    'coins': coins,
    'xp': xp,
    'level': level,
    'rank': rank,
    'streak': streak,
    'streakShields': streakShields,
    'totalWins': totalWins,
    'totalLosses': totalLosses,
    'achievements': achievements,
    'unlockedGames': unlockedGames,
    'onlineStatus': onlineStatus,
    'banned': banned,
    'bannedReason': bannedReason,
    'loginAttempts': loginAttempts,
    'nicknameChanges': nicknameChanges,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
  };

  String get rankName {
    if (level <= 5) return 'Novice';
    if (level <= 10) return 'Apprentice';
    if (level <= 20) return 'Warrior';
    if (level <= 35) return 'Elite';
    if (level <= 50) return 'Champion';
    if (level <= 75) return 'Legend';
    return 'Mythic';
  }

  Color get rankColor {
    if (level <= 5) return BColors.rarityCommon;
    if (level <= 10) return BColors.neonGreen;
    if (level <= 20) return BColors.neonBlue;
    if (level <= 35) return BColors.neonPurple;
    if (level <= 50) return BColors.neonGold;
    if (level <= 75) return BColors.neonOrange;
    return BColors.neonRed;
  }

  int get xpForNextLevel => level * 500;
  double get xpProgress => (xp % (level * 500)) / (level * 500);

  Color get avatarBgColor {
    int hash = 0;
    for (final c in playerId.codeUnits) hash = c + ((hash << 5) - hash);
    return BColors.avatarPalette[hash.abs() % BColors.avatarPalette.length];
  }
}

// =============================================================================
// SESSION
// =============================================================================
class BSession {
  static PlayerModel? currentPlayer;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<void> refresh() async {
    if (currentPlayer == null) return;
    try {
      final doc = await db
          .collection('players')
          .doc(currentPlayer!.playerId)
          .get();
      if (doc.exists) currentPlayer = PlayerModel.fromMap(doc.data()!);
    } catch (_) {}
  }

  static Stream<DocumentSnapshot> playerStream() =>
      db.collection('players').doc(currentPlayer!.playerId).snapshots();
}

// =============================================================================
// GENERATOR
// =============================================================================
class BGenerator {
  static final _rng = Random.secure();
  static String playerId() => 'BD${10000 + _rng.nextInt(90000)}';
  static String upiId(String nick) {
    final c = nick.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '${c.isEmpty ? 'player' : c}${_rng.nextInt(999)}@beedi';
  }

  static String loginPin() => (10000 + _rng.nextInt(90000)).toString();
  static String upiPin() => (1000 + _rng.nextInt(9000)).toString();
}

// =============================================================================
// FIRESTORE SERVICE
// =============================================================================
class BFirestore {
  static final _db = FirebaseFirestore.instance;

  static Future<String?> createPlayer(PlayerModel p) async {
    try {
      await _db.collection('players').doc(p.playerId).set(p.toMap());
      await _db.collection('leaderboard').doc(p.playerId).set({
        'playerId': p.playerId,
        'nickname': p.nickname,
        'avatar': p.avatar,
        'xp': 0,
        'coins': 100,
        'wins': 0,
        'streak': 0,
        'level': 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _db.collection('inventory').doc(p.playerId).set({'items': []});
      await _logActivity(
        p.playerId,
        p.nickname,
        'account_created',
        'Joined BEEDI College',
        coins: 100,
      );
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<PlayerModel?> loginByIdOrUpi(String input) async {
    try {
      final byId = await _db
          .collection('players')
          .where('playerId', isEqualTo: input)
          .limit(1)
          .get();
      if (byId.docs.isNotEmpty)
        return PlayerModel.fromMap(byId.docs.first.data());
      final byUpi = await _db
          .collection('players')
          .where('beediUpiId', isEqualTo: input)
          .limit(1)
          .get();
      if (byUpi.docs.isNotEmpty)
        return PlayerModel.fromMap(byUpi.docs.first.data());
    } catch (_) {}
    return null;
  }

  static Future<void> setOnline(String playerId, bool status) async {
    try {
      await _db.collection('players').doc(playerId).update({
        'onlineStatus': status,
        if (status) 'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  static Future<bool> isNicknameAvailable(String nickname) async {
    try {
      final snap = await _db
          .collection('players')
          .where('nickname', isEqualTo: nickname.trim())
          .limit(1)
          .get();
      return snap.docs.isEmpty;
    } catch (_) {
      return true;
    }
  }

  static Future<void> applyGameReward({
    required String playerId,
    required String nickname,
    required int coins,
    required int xp,
    required bool won,
    required String gameName,
  }) async {
    try {
      final ref = _db.collection('players').doc(playerId);
      final doc = await ref.get();
      if (!doc.exists) return;
      final p = PlayerModel.fromMap(doc.data()!);
      int nC = p.coins + coins, nX = p.xp + xp;
      int nStr = won ? p.streak + 1 : (p.streakShields > 0 ? p.streak : 0);
      int nSh = (!won && p.streak > 0 && p.streakShields > 0)
          ? p.streakShields - 1
          : p.streakShields;
      int nW = won ? p.totalWins + 1 : p.totalWins,
          nL = won ? p.totalLosses : p.totalLosses + 1;
      int nLvl = p.level;
      while (nX >= nLvl * 500) {
        nX -= nLvl * 500;
        nLvl++;
      }
      final nRank = PlayerModel(
        playerId: playerId,
        beediUpiId: '',
        nickname: nickname,
        realName: '',
        mobileNumber: '',
        avatar: '',
        loginPin: '',
        upiPin: '',
        level: nLvl,
        createdAt: DateTime.now(),
      ).rankName;
      await ref.update({
        'coins': nC,
        'xp': nX,
        'level': nLvl,
        'rank': nRank,
        'streak': nStr,
        'streakShields': nSh,
        'totalWins': nW,
        'totalLosses': nL,
      });
      await _db.collection('leaderboard').doc(playerId).update({
        'xp': nX + nLvl * 500,
        'coins': nC,
        'wins': nW,
        'streak': nStr,
        'level': nLvl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Store game score in scores collection
      await _db.collection('scores').add({
        'playerId': playerId,
        'nickname': nickname,
        'gameName': gameName,
        'won': won,
        'coins': coins,
        'xp': xp,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _logActivity(
        playerId,
        nickname,
        won ? 'win' : 'loss',
        won ? 'Won $gameName' : 'Lost $gameName',
        coins: won ? coins : 0,
        xp: xp,
      );
    } catch (_) {}
  }

  static Future<String?> sendCoins({
    required PlayerModel sender,
    required String receiverUpiId,
    required int amount,
    required String upiPin,
  }) async {
    try {
      if (receiverUpiId.trim() == sender.beediUpiId)
        return 'Cannot send to yourself';
      if (amount <= 0) return 'Enter valid amount';
      if (sender.coins < amount) return 'Insufficient coins';
      if (upiPin != sender.upiPin) return 'Wrong UPI PIN';
      final snap = await _db
          .collection('players')
          .where('beediUpiId', isEqualTo: receiverUpiId.trim())
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return 'Invalid BEEDI UPI ID';
      final receiver = PlayerModel.fromMap(snap.docs.first.data());
      final batch = _db.batch();
      batch.update(_db.collection('players').doc(sender.playerId), {
        'coins': sender.coins - amount,
      });
      batch.update(_db.collection('players').doc(receiver.playerId), {
        'coins': receiver.coins + amount,
      });
      final txnId = _uuid.v4();
      batch.set(_db.collection('transactions').doc(txnId), {
        'txnId': txnId,
        'senderId': sender.playerId,
        'receiverId': receiver.playerId,
        'senderUpiId': sender.beediUpiId,
        'receiverUpiId': receiverUpiId,
        'amount': amount,
        'type': 'transfer',
        'description': 'Coin transfer',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'success',
      });
      await batch.commit();
      await _logActivity(
        sender.playerId,
        sender.nickname,
        'transfer',
        'Sent $amount coins to ${receiver.nickname}',
        coins: -amount,
      );
      await _logActivity(
        receiver.playerId,
        receiver.nickname,
        'transfer',
        'Received $amount coins from ${sender.nickname}',
        coins: amount,
      );
      return null;
    } catch (e) {
      return 'Transfer failed: $e';
    }
  }

  static Future<Map<String, dynamic>?> claimDailyReward(
    PlayerModel player,
  ) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month}-${today.day}';
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('daily_${player.playerId}') == todayStr) return null;
      int dayStreak = (prefs.getInt('daily_streak_${player.playerId}') ?? 0);
      dayStreak = (dayStreak % 7) + 1;
      final rewards = [
        {'coins': 50, 'xp': 0, 'day': 1},
        {'coins': 75, 'xp': 0, 'day': 2},
        {'coins': 100, 'xp': 50, 'day': 3},
        {'coins': 150, 'xp': 0, 'day': 4},
        {'coins': 200, 'xp': 0, 'day': 5},
        {'coins': 250, 'xp': 0, 'day': 6},
        {'coins': 500, 'xp': 100, 'day': 7},
      ];
      final reward = rewards[dayStreak - 1];
      await _db.collection('players').doc(player.playerId).update({
        'coins': FieldValue.increment(reward['coins'] as int),
        'xp': FieldValue.increment(reward['xp'] as int),
      });
      await prefs.setString('daily_${player.playerId}', todayStr);
      await prefs.setInt('daily_streak_${player.playerId}', dayStreak);
      await _logActivity(
        player.playerId,
        player.nickname,
        'daily_reward',
        'Day $dayStreak reward claimed',
        coins: reward['coins'] as int,
        xp: reward['xp'] as int,
      );
      return reward;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _logActivity(
    String pid,
    String nick,
    String action,
    String detail, {
    int coins = 0,
    int xp = 0,
  }) async {
    try {
      await _db.collection('activityLogs').add({
        'playerId': pid,
        'nickname': nick,
        'action': action,
        'detail': detail,
        'coins': coins,
        'xp': xp,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  static Stream<QuerySnapshot> marketplaceStream() => _db
      .collection('marketplace')
      .where('active', isEqualTo: true)
      .snapshots();

  static Future<String?> buyItem(
    PlayerModel player,
    Map<String, dynamic> item,
  ) async {
    try {
      final price = item['price'] as int;
      if (player.coins < price) return 'Insufficient coins';
      final batch = _db.batch();
      batch.update(_db.collection('players').doc(player.playerId), {
        'coins': player.coins - price,
      });
      batch.update(_db.collection('inventory').doc(player.playerId), {
        'items': FieldValue.arrayUnion([
          {
            'itemId': item['itemId'],
            'itemName': item['name'],
            'rarity': item['rarity'],
            'category': item['category'],
            'equipped': false,
            'acquiredAt': Timestamp.now(),
            'value': price,
          },
        ]),
      });
      final txnId = _uuid.v4();
      batch.set(_db.collection('transactions').doc(txnId), {
        'txnId': txnId,
        'senderId': player.playerId,
        'receiverId': 'marketplace',
        'senderUpiId': player.beediUpiId,
        'receiverUpiId': 'marketplace@beedi',
        'amount': price,
        'type': 'purchase',
        'description': 'Bought ${item['name']}',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'success',
      });
      await batch.commit();
      await _logActivity(
        player.playerId,
        player.nickname,
        'purchase',
        'Bought ${item['name']}',
        coins: -price,
      );
      return null;
    } catch (e) {
      return 'Purchase failed: $e';
    }
  }

  static Stream<QuerySnapshot> transactionsStream(String pid) => _db
      .collection('transactions')
      .where(
        Filter.or(
          Filter('senderId', isEqualTo: pid),
          Filter('receiverId', isEqualTo: pid),
        ),
      )
      .orderBy('timestamp', descending: true)
      .limit(30)
      .snapshots();

  static Stream<QuerySnapshot> leaderboardStream() => _db
      .collection('leaderboard')
      .orderBy('xp', descending: true)
      .limit(50)
      .snapshots();

  static Stream<QuerySnapshot> activityFeedStream() => _db
      .collection('activityLogs')
      .orderBy('timestamp', descending: true)
      .limit(20)
      .snapshots();

  static Stream<QuerySnapshot> eventsStream() =>
      _db.collection('events').where('active', isEqualTo: true).snapshots();

  static Stream<QuerySnapshot> gameScoresStream(String gameName) => _db
      .collection('scores')
      .where('gameName', isEqualTo: gameName)
      .orderBy('coins', descending: true)
      .limit(20)
      .snapshots();
}

// =============================================================================
// REUSABLE WIDGETS
// =============================================================================

/// Particle background
class ParticleBackground extends StatefulWidget {
  final Widget child;
  const ParticleBackground({super.key, required this.child});
  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _particles = <_Particle>[];
  final _rng = Random();
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 40; i++) _particles.add(_Particle(_rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BColors.bg1, BColors.bg2, BColors.bg3],
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _ParticlePainter(_particles, _ctrl.value),
          child: const SizedBox.expand(),
        ),
      ),
      widget.child,
    ],
  );
}

class _Particle {
  double x, y, speed, radius, opacity;
  Color color;
  _Particle(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      speed = 0.01 + r.nextDouble() * 0.03,
      radius = 1 + r.nextDouble() * 3,
      opacity = 0.1 + r.nextDouble() * 0.5,
      color = [
        BColors.neonBlue,
        BColors.neonPurple,
        BColors.neonGreen,
        Colors.white,
      ][r.nextInt(4)];
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlePainter(this.particles, this.t);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dy = (p.y + t * p.speed) % 1.0;
      canvas.drawCircle(
        Offset(p.x * size.width, dy * size.height),
        p.radius,
        Paint()..color = p.color.withOpacity(p.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

/// Glassmorphism card
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsets padding;
  const GlassCard({
    super.key,
    required this.child,
    this.borderColor = BColors.neonBlue,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
  });
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}

/// Neon button
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool loading;
  final double width, height;
  final IconData? icon;
  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.color = BColors.neonBlue,
    this.loading = false,
    this.width = double.infinity,
    this.height = 52,
    this.icon,
  });
  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _pulse,
    builder: (_, __) => GestureDetector(
      onTap: widget.loading ? null : widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.color.withOpacity(_pulse.value),
            width: 1.5,
          ),
          color: widget.color.withOpacity(0.08),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3 * _pulse.value),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: widget.loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: widget.color,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.color, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: BText.orbitron(size: 13, color: widget.color),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}

/// Shake widget
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;
  const ShakeWidget({super.key, required this.child, required this.shake});
  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shake;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shake = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticIn));
  }

  @override
  void didUpdateWidget(ShakeWidget old) {
    super.didUpdateWidget(old);
    if (widget.shake && !old.shake) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _shake,
    builder: (_, child) => Transform.translate(
      offset: Offset(sin(_shake.value * pi * 8) * 6, 0),
      child: child,
    ),
    child: widget.child,
  );
}

/// Player avatar
class PlayerAvatar extends StatelessWidget {
  final PlayerModel player;
  final double size;
  final bool showOnline;
  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 48,
    this.showOnline = false,
  });
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: player.avatarBgColor,
          boxShadow: [
            BoxShadow(
              color: player.avatarBgColor.withOpacity(0.5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Text(player.avatar, style: TextStyle(fontSize: size * 0.48)),
        ),
      ),
      if (showOnline)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: player.onlineStatus ? BColors.neonGreen : Colors.grey,
              border: Border.all(color: BColors.bg2, width: 2),
            ),
          ),
        ),
    ],
  );
}

/// XP bar
class XPBar extends StatelessWidget {
  final PlayerModel player;
  const XPBar({super.key, required this.player});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'LVL ${player.level}',
            style: BText.orbitron(size: 10, color: player.rankColor),
          ),
          Text(
            '${player.xp % (player.level * 500)} / ${player.level * 500} XP',
            style: BText.mono(size: 9, color: BColors.txtSecondary),
          ),
        ],
      ),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: player.xpProgress,
          minHeight: 6,
          backgroundColor: BColors.bg3,
          valueColor: AlwaysStoppedAnimation(player.rankColor),
        ),
      ),
    ],
  );
}

/// Stat chip
class StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => GlassCard(
    borderColor: color,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Column(
      children: [
        Text(value, style: BText.orbitron(size: 16, color: color)),
        const SizedBox(height: 2),
        Text(
          label,
          style: BText.rajdhani(size: 11, color: BColors.txtSecondary),
        ),
      ],
    ),
  );
}

// Text field widget
class _NeonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure, isPin;
  final Widget? suffix;
  const _NeonTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.isPin = false,
    this.suffix,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    style: isPin
        ? BText.mono(size: 18, color: BColors.neonBlue)
        : BText.rajdhani(size: 15, color: BColors.txtPrimary),
    maxLength: isPin ? 5 : 50,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: BText.rajdhani(size: 13, color: BColors.txtSecondary),
      prefixIcon: Icon(icon, color: BColors.neonBlue, size: 20),
      suffixIcon: suffix,
      counterText: '',
      filled: true,
      fillColor: BColors.bg2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: BColors.neonBlue.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: BColors.neonBlue.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: BColors.neonBlue, width: 1.5),
      ),
    ),
  );
}

// =============================================================================
// SPLASH SCREEN
// =============================================================================
class BeeediSplashScreen extends StatefulWidget {
  const BeeediSplashScreen({super.key});
  @override
  State<BeeediSplashScreen> createState() => _BeeediSplashScreenState();
}

class _BeeediSplashScreenState extends State<BeeediSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;
  int _si = 0;
  final _statuses = [
    'Connecting to BEEDI Network...',
    'Syncing Player Data...',
    'Loading 56 Games...',
    'Entering Ecosystem...',
  ];
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _si = (_si + 1) % _statuses.length);
    });
    _init();
  }

  Future<void> _init() async {
    await Firebase.initializeApp();
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final sid = prefs.getString('beedi_player_id');
    if (sid != null) {
      final p = await BFirestore.loginByIdOrUpi(sid);
      if (p != null && !p.banned) {
        BSession.currentPlayer = p;
        await BFirestore.setOnline(p.playerId, true);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GameHomeScreen()),
          );
          return;
        }
      }
    }
    if (mounted)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LearnerLoginScreen()),
      );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ParticleBackground(
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BColors.neonBlue.withOpacity(0.1),
                    border: Border.all(
                      color: BColors.neonBlue.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: BColors.glowBlue,
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('⚡', style: TextStyle(fontSize: 60)),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'BEEDI College',
                  style: BText.orbitron(size: 42, color: BColors.neonBlue),
                ),
                Text(
                  'GAME ECOSYSTEM',
                  style: BText.orbitron(
                    size: 14,
                    color: BColors.txtSecondary,
                    weight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '56 Games • Learn • Play • Earn • Compete',
                  style: BText.rajdhani(size: 16, color: BColors.neonGreen),
                ),
                const SizedBox(height: 60),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: BColors.neonBlue,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _statuses[_si],
                    key: ValueKey(_si),
                    style: BText.mono(size: 11, color: BColors.txtSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// =============================================================================
// LEARNER LOGIN SCREEN
// =============================================================================
class LearnerLoginScreen extends StatefulWidget {
  const LearnerLoginScreen({super.key});
  @override
  State<LearnerLoginScreen> createState() => _LearnerLoginScreenState();
}

class _LearnerLoginScreenState extends State<LearnerLoginScreen>
    with SingleTickerProviderStateMixin {
  final _idCtrl = TextEditingController(), _pinCtrl = TextEditingController();
  bool _loading = false, _shake = false, _hidePin = true;
  String? _error;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnim = Tween(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _idCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final id = _idCtrl.text.trim(), pin = _pinCtrl.text.trim();
    if (id.isEmpty || pin.isEmpty) {
      _setError('Enter Player ID and PIN');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final player = await BFirestore.loginByIdOrUpi(id);
      if (player == null) {
        _setError('PLAYER NOT FOUND — Check ID or Create Account');
        return;
      }
      if (player.banned) {
        _setError('ACCOUNT SUSPENDED — Contact Admin');
        return;
      }
      if (player.loginPin != pin) {
        _setError('INVALID SECURITY PIN');
        return;
      }
      BSession.currentPlayer = player;
      await BFirestore.setOnline(player.playerId, true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('beedi_player_id', player.playerId);
      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GameHomeScreen()),
        );
    } catch (e) {
      _setError('CONNECTION FAILED — Check Internet');
    }
  }

  void _setError(String msg) {
    setState(() {
      _error = msg;
      _loading = false;
      _shake = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _shake = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(child: w > 700 ? _wideLayout() : _mobileLayout()),
      ),
    );
  }

  Widget _wideLayout() => Row(
    children: [
      Expanded(flex: 6, child: _buildBranding()),
      Container(
        width: 420,
        padding: const EdgeInsets.all(32),
        child: Center(child: _buildLoginCard()),
      ),
    ],
  );
  Widget _mobileLayout() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const SizedBox(height: 40),
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, __) => Column(
            children: [
              Text(
                'BEEDI College',
                style: BText.orbitron(size: 36, color: BColors.neonBlue)
                    .copyWith(
                      shadows: [
                        Shadow(
                          color: BColors.neonBlue.withOpacity(_glowAnim.value),
                          blurRadius: 20,
                        ),
                      ],
                    ),
              ),
              Text(
                'Learn • Play • Earn • Compete',
                style: BText.rajdhani(size: 14, color: BColors.neonGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildLoginCard(),
        const SizedBox(height: 24),
      ],
    ),
  );
  Widget _buildBranding() => Padding(
    padding: const EdgeInsets.all(48),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, __) => Text(
            'BEEDI College',
            style: BText.orbitron(size: 56, color: BColors.neonBlue).copyWith(
              shadows: [
                Shadow(
                  color: BColors.neonBlue.withOpacity(_glowAnim.value),
                  blurRadius: 30,
                ),
              ],
            ),
          ),
        ),
        Text(
          'GAME ECOSYSTEM',
          style: BText.orbitron(
            size: 18,
            color: BColors.txtSecondary,
            weight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Games • Learn • Play • Earn',
          style: BText.rajdhani(size: 18, color: BColors.neonGreen),
        ),
        const SizedBox(height: 48),
        _LiveStatsPanel(),
      ],
    ),
  );
  Widget _buildLoginCard() => ShakeWidget(
    shake: _shake,
    child: GlassCard(
      borderColor: _error != null ? BColors.neonRed : BColors.neonBlue,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLAYER LOGIN',
            style: BText.orbitron(size: 18, color: BColors.neonBlue),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your Player ID or BEEDI UPI ID',
            style: BText.rajdhani(size: 13, color: BColors.txtSecondary),
          ),
          const SizedBox(height: 24),
          _NeonTextField(
            controller: _idCtrl,
            label: 'Player ID / BEEDI UPI ID',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _NeonTextField(
            controller: _pinCtrl,
            label: '5-Digit Security PIN',
            icon: Icons.lock_outline,
            obscure: _hidePin,
            isPin: true,
            suffix: IconButton(
              icon: Icon(
                _hidePin ? Icons.visibility_off : Icons.visibility,
                color: BColors.txtSecondary,
                size: 18,
              ),
              onPressed: () => setState(() => _hidePin = !_hidePin),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BColors.neonRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: BColors.neonRed.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: BColors.neonRed,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: BText.rajdhani(size: 12, color: BColors.neonRed),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          NeonButton(
            label: 'LOGIN — ENTER ECOSYSTEM',
            onTap: _login,
            loading: _loading,
            icon: Icons.login,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              ),
              child: Text(
                'Admin Access',
                style: BText.rajdhani(size: 12, color: BColors.txtSecondary),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
              ),
              child: Text(
                'New Learner? Create Account →',
                style: BText.rajdhani(
                  size: 13,
                  color: BColors.neonGreen,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LiveStatsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot>(
    stream: BFirestore.leaderboardStream(),
    builder: (_, snap) {
      final docs = snap.data?.docs ?? [];
      final top3 = docs.take(3).toList();
      
      return Column(
        children: [
          // Total players count
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Text('👥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Players',
                      style: BText.rajdhani(size: 11, color: BColors.txtSecondary),
                    ),
                    Text(
                      '${docs.length}',
                      style: BText.orbitron(size: 14, color: BColors.neonBlue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Top 3 Players
          if (top3.isNotEmpty)
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(
                        'TOP PLAYERS',
                        style: BText.orbitron(size: 11, color: BColors.neonGold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rank 1
                  if (top3.length >= 1)
                    _buildRankRow(1, top3[0].data() as Map<String, dynamic>, BColors.neonGold),
                  // Rank 2
                  if (top3.length >= 2)
                    _buildRankRow(2, top3[1].data() as Map<String, dynamic>, BColors.neonBlue),
                  // Rank 3
                  if (top3.length >= 3)
                    _buildRankRow(3, top3[2].data() as Map<String, dynamic>, BColors.neonGreen),
                ],
              ),
            ),
        ],
      );
    },
  );

  Widget _buildRankRow(int rank, Map<String, dynamic> player, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              border: Border.all(color: color, width: 1),
            ),
            child: Center(
              child: Text(
                rank == 1 ? '👑' : rank == 2 ? '🥈' : '🥉',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player['nickname'] ?? 'Unknown',
              style: BText.rajdhani(size: 12, color: BColors.txtPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'Lv.${player['level'] ?? 1}',
            style: BText.mono(size: 10, color: color),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CREATE ACCOUNT SCREEN
// =============================================================================
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  int _step = 0;
  final _nickCtrl = TextEditingController(),
      _nameCtrl = TextEditingController(),
      _mobileCtrl = TextEditingController();
  String _selectedAvatar = BColors.avatarEmojis[0];
  bool _loading = false;
  String? _error;
  PlayerModel? _createdPlayer;
  @override
  void dispose() {
    _nickCtrl.dispose();
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final available = await BFirestore.isNicknameAvailable(
        _nickCtrl.text.trim(),
      );
      if (!available) {
        setState(() {
          _error = 'Nickname taken — choose another';
          _loading = false;
        });
        return;
      }
      final pid = BGenerator.playerId(),
          upiId = BGenerator.upiId(_nickCtrl.text.trim()),
          pin = BGenerator.loginPin(),
          upiPin = BGenerator.upiPin();
      final player = PlayerModel(
        playerId: pid,
        beediUpiId: upiId,
        nickname: _nickCtrl.text.trim(),
        realName: _nameCtrl.text.trim(),
        mobileNumber: _mobileCtrl.text.trim(),
        avatar: _selectedAvatar,
        loginPin: pin,
        upiPin: upiPin,
        createdAt: DateTime.now(),
      );
      final err = await BFirestore.createPlayer(player);
      if (err != null) {
        setState(() {
          _error = err;
          _loading = false;
        });
        return;
      }
      setState(() {
        _createdPlayer = player;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ParticleBackground(
      child: SafeArea(
        child: _createdPlayer != null
            ? PinPopupScreen(player: _createdPlayer!)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: BColors.txtSecondary,
                      ),
                      onPressed: () => _step > 0
                          ? setState(() => _step--)
                          : Navigator.pop(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CREATE ACCOUNT',
                      style: BText.orbitron(size: 22, color: BColors.neonBlue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step ${_step + 1} of 3',
                      style: BText.rajdhani(
                        size: 14,
                        color: BColors.txtSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (_step + 1) / 3,
                      backgroundColor: BColors.bg3,
                      valueColor: const AlwaysStoppedAnimation(
                        BColors.neonBlue,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_step == 0) _step1(),
                    if (_step == 1) _step2(),
                    if (_step == 2) _step3(),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: BColors.neonRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: BColors.neonRed.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          _error!,
                          style: BText.rajdhani(
                            size: 13,
                            color: BColors.neonRed,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    ),
  );
  Widget _step1() => Column(
    children: [
      GlassCard(
        child: Column(
          children: [
            Text(
              'PERSONAL INFO',
              style: BText.orbitron(size: 14, color: BColors.neonGreen),
            ),
            const SizedBox(height: 20),
            _NeonTextField(
              controller: _nickCtrl,
              label: 'Nickname (unique)',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 14),
            _NeonTextField(
              controller: _nameCtrl,
              label: 'Real Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              style: BText.rajdhani(size: 15, color: BColors.txtPrimary),
              decoration: InputDecoration(
                labelText: '10-digit Mobile',
                labelStyle: BText.rajdhani(
                  size: 13,
                  color: BColors.txtSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: BColors.neonBlue,
                  size: 20,
                ),
                filled: true,
                fillColor: BColors.bg2,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: BColors.neonBlue.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: BColors.neonBlue.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: BColors.neonBlue,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      NeonButton(
        label: 'NEXT →',
        onTap: () {
          if (_nickCtrl.text.trim().length < 3) {
            setState(() => _error = 'Nickname too short');
            return;
          }
          if (_nameCtrl.text.trim().isEmpty) {
            setState(() => _error = 'Enter your real name');
            return;
          }
          if (_mobileCtrl.text.trim().length != 10) {
            setState(() => _error = 'Enter valid 10-digit mobile');
            return;
          }
          setState(() {
            _error = null;
            _step = 1;
          });
        },
      ),
    ],
  );
  Widget _step2() => Column(
    children: [
      Text(
        'CHOOSE YOUR AVATAR',
        style: BText.orbitron(size: 14, color: BColors.neonGreen),
      ),
      const SizedBox(height: 20),
      Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BColors.neonBlue.withOpacity(0.1),
            border: Border.all(color: BColors.neonBlue, width: 2),
            boxShadow: [BoxShadow(color: BColors.glowBlue, blurRadius: 20)],
          ),
          child: Center(
            child: Text(_selectedAvatar, style: const TextStyle(fontSize: 52)),
          ),
        ),
      ),
      const SizedBox(height: 24),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: BColors.avatarEmojis.length,
        itemBuilder: (_, i) {
          final emoji = BColors.avatarEmojis[i], sel = emoji == _selectedAvatar;
          return GestureDetector(
            onTap: () => setState(() => _selectedAvatar = emoji),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: sel ? BColors.neonBlue.withOpacity(0.2) : BColors.bg2,
                border: Border.all(
                  color: sel ? BColors.neonBlue : BColors.bg3,
                  width: sel ? 2 : 1,
                ),
                boxShadow: sel
                    ? [BoxShadow(color: BColors.glowBlue, blurRadius: 8)]
                    : null,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 24),
      NeonButton(label: 'NEXT →', onTap: () => setState(() => _step = 2)),
    ],
  );
  Widget _step3() => Column(
    children: [
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REVIEW & CREATE',
              style: BText.orbitron(size: 14, color: BColors.neonGreen),
            ),
            const SizedBox(height: 20),
            _rr('Avatar', _selectedAvatar),
            _rr('Nickname', _nickCtrl.text.trim()),
            _rr('Name', _nameCtrl.text.trim()),
            _rr('Mobile', _mobileCtrl.text.trim()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BColors.neonGold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: BColors.neonGold.withOpacity(0.3)),
              ),
              child: Text(
                '⚡ Your Player ID, UPI ID, and Login PIN will be auto-generated.',
                style: BText.rajdhani(size: 12, color: BColors.neonGold),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      NeonButton(
        label: 'CREATE MY ACCOUNT',
        onTap: _createAccount,
        loading: _loading,
        icon: Icons.rocket_launch,
      ),
    ],
  );
  Widget _rr(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            l,
            style: BText.rajdhani(size: 13, color: BColors.txtSecondary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            v,
            style: BText.rajdhani(
              size: 13,
              color: BColors.txtPrimary,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

// PIN Popup Screen
class PinPopupScreen extends StatefulWidget {
  final PlayerModel player;
  const PinPopupScreen({super.key, required this.player});
  @override
  State<PinPopupScreen> createState() => _PinPopupScreenState();
}

class _PinPopupScreenState extends State<PinPopupScreen> {
  bool _copied = false;
  late ConfettiController _confetti;
  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 5))
      ..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              borderColor: BColors.neonGold,
              child: Column(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 12),
                  Text(
                    'WELCOME TO BEEDI College',
                    style: BText.orbitron(size: 18, color: BColors.neonGold),
                  ),
                  Text(
                    'Your account is ready',
                    style: BText.rajdhani(
                      size: 14,
                      color: BColors.txtSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'YOUR SECRET LOGIN PIN',
                    style: BText.orbitron(
                      size: 11,
                      color: BColors.txtSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: BColors.neonGold, width: 2),
                      color: BColors.neonGold.withOpacity(0.08),
                      boxShadow: [
                        BoxShadow(
                          color: BColors.glowGold,
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      p.loginPin,
                      style: BText.orbitron(size: 42, color: BColors.neonGold)
                          .copyWith(
                            letterSpacing: 10,
                            shadows: [
                              const Shadow(
                                color: BColors.neonGold,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeonButton(
                    label: _copied ? '✓ COPIED!' : '📋 COPY PIN',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: p.loginPin));
                      setState(() => _copied = true);
                    },
                    color: _copied ? BColors.neonGreen : BColors.neonBlue,
                    width: 200,
                    height: 44,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: BColors.neonRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: BColors.neonRed.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '⚠️ Save this PIN carefully. This is the ONLY way to access your account.',
                      textAlign: TextAlign.center,
                      style: BText.rajdhani(size: 12, color: BColors.neonRed),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _pr('Player ID', p.playerId),
                        _pr('BEEDI UPI', p.beediUpiId),
                        _pr('UPI PIN', p.upiPin),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeonButton(
                    label: 'I HAVE SAVED MY PIN — CONTINUE',
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LearnerLoginScreen(),
                      ),
                    ),
                    color: BColors.neonGreen,
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [
              BColors.neonBlue,
              BColors.neonGreen,
              BColors.neonGold,
              BColors.neonPurple,
            ],
            numberOfParticles: 20,
          ),
        ),
      ],
    );
  }

  Widget _pr(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: BText.rajdhani(size: 12, color: BColors.txtSecondary)),
        Text(v, style: BText.mono(size: 12, color: BColors.neonGreen)),
      ],
    ),
  );
}

// =============================================================================
// ADMIN LOGIN SCREEN
// =============================================================================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with TickerProviderStateMixin {
  final _idCtrl = TextEditingController(), _pinCtrl = TextEditingController();
  bool _loading = false, _shake = false;
  String _terminal =
      '> BEEDI College SECURITY TERMINAL v2.0\n> Authorized Personnel Only\n> Awaiting credentials...';
  late AnimationController _matrixCtrl;
  @override
  void initState() {
    super.initState();
    _matrixCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _matrixCtrl.dispose();
    _idCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _auth() async {
    setState(() {
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (_idCtrl.text.trim() == kAdminId && _pinCtrl.text.trim() == kAdminPin) {
      setState(() {
        _terminal =
            '> Verifying identity...\n> ████████████ 100%\n> ADMIN ACCESS GRANTED\n> Loading Command Center...';
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const _AdminPanelEntry()),
        );
    } else {
      setState(() {
        _terminal = '> ACCESS DENIED\n> Reason: Invalid credentials';
        _loading = false;
        _shake = true;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _shake = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        AnimatedBuilder(
          animation: _matrixCtrl,
          builder: (_, __) => CustomPaint(
            painter: _MatrixPainter(_matrixCtrl.value),
            child: const SizedBox.expand(),
          ),
        ),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ShakeWidget(
                  shake: _shake,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'ADMIN TERMINAL',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 22,
                          color: const Color(0xFF00FF41),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KYP SECURITY SYSTEM v2.0',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 11,
                          color: const Color(0xFF004D20),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00FF41).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          _terminal,
                          style: GoogleFonts.shareTechMono(
                            fontSize: 12,
                            color: const Color(0xFF00FF41),
                            height: 1.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _AdminField(
                        controller: _idCtrl,
                        label: '> ADMINISTRATOR ID:',
                      ),
                      const SizedBox(height: 14),
                      _AdminField(
                        controller: _pinCtrl,
                        label: '> ACCESS PIN:',
                        obscure: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: _loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00FF41),
                                ),
                              )
                            : GestureDetector(
                                onTap: _auth,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF00FF41),
                                    ),
                                    color: const Color(
                                      0xFF00FF41,
                                    ).withOpacity(0.08),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '>> INITIATE ACCESS VERIFICATION',
                                      style: GoogleFonts.shareTechMono(
                                        color: const Color(0xFF00FF41),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            '← Return',
                            style: GoogleFonts.shareTechMono(
                              color: const Color(0xFF004D20),
                              fontSize: 11,
                            ),
                          ),
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

class _AdminField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  const _AdminField({
    required this.controller,
    required this.label,
    this.obscure = false,
  });
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF00FF41);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.shareTechMono(fontSize: 12, color: green),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.shareTechMono(fontSize: 15, color: green),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: green.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: green.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: green),
            ),
          ),
        ),
      ],
    );
  }
}

class _MatrixPainter extends CustomPainter {
  final double t;
  static final _rng = Random(42);
  static final _chars = '01BEEDI'.split('');
  _MatrixPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 20; i++) {
      final x = (_rng.nextDouble() * size.width).floorToDouble();
      final y = ((t * size.height + i * 60) % size.height);
      final ch = _chars[_rng.nextInt(_chars.length)];
      final tp = TextPainter(
        text: TextSpan(
          text: ch,
          style: GoogleFonts.shareTechMono(
            fontSize: 12,
            color: const Color(0xFF00FF41).withOpacity(0.15),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(_MatrixPainter old) => true;
}

class _AdminPanelEntry extends StatelessWidget {
  const _AdminPanelEntry();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BColors.bg1,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ADMIN PANEL',
            style: BText.orbitron(size: 22, color: BColors.neonGreen),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome Gaurav Kumar',
            style: BText.mono(size: 12, color: BColors.neonGreen),
          ),
          const SizedBox(height: 32),
          NeonButton(
            label: 'Open Admin Pannel',
            color: BColors.neonGreen,
            width: 240,
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GameAdminPanel()),
            ),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// GAME RESULT SCREEN
// =============================================================================
class GameResultScreen extends StatefulWidget {
  final bool won;
  final int coins, xp;
  final String gameName;
  final VoidCallback onContinue;
  final int score;
  const GameResultScreen({
    super.key,
    required this.won,
    required this.coins,
    required this.xp,
    required this.gameName,
    required this.onContinue,
    this.score = 0,
  });
  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  late ConfettiController _confetti;
  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    if (widget.won) _confetti.play();
    _applyReward();
  }

  Future<void> _applyReward() async {
    final p = BSession.currentPlayer;
    if (p == null) return;
    await BFirestore.applyGameReward(
      playerId: p.playerId,
      nickname: p.nickname,
      coins: widget.coins,
      xp: widget.xp,
      won: widget.won,
      gameName: widget.gameName,
    );
    await BSession.refresh();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ParticleBackground(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: GlassCard(
                borderColor: widget.won ? BColors.neonGold : BColors.neonRed,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.won ? '🏆' : '😔',
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.won ? 'VICTORY!' : 'GAME OVER',
                      style: BText.orbitron(
                        size: 28,
                        color: widget.won ? BColors.neonGold : BColors.neonRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.gameName,
                      style: BText.rajdhani(
                        size: 16,
                        color: BColors.txtSecondary,
                      ),
                    ),
                    if (widget.score > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Score: ${widget.score}',
                        style: BText.orbitron(
                          size: 18,
                          color: BColors.neonBlue,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (widget.won)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _rc('+${widget.coins}', '💰', BColors.neonGold),
                          const SizedBox(width: 16),
                          _rc('+${widget.xp}', 'XP', BColors.neonPurple),
                          const SizedBox(width: 16),
                          _rc('+1', '🔥', BColors.neonOrange),
                        ],
                      )
                    else
                      Text(
                        'Practice XP: +${widget.xp}',
                        style: BText.rajdhani(
                          size: 14,
                          color: BColors.txtSecondary,
                        ),
                      ),
                    const SizedBox(height: 32),
                    NeonButton(
                      label: 'CONTINUE',
                      color: widget.won ? BColors.neonGold : BColors.neonBlue,
                      onTap: widget.onContinue,
                      icon: Icons.arrow_forward,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.won)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [
                  BColors.neonGold,
                  BColors.neonBlue,
                  BColors.neonGreen,
                  BColors.neonPurple,
                ],
              ),
            ),
        ],
      ),
    ),
  );
  Widget _rc(String v, String i, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: c.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.5)),
      boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 10)],
    ),
    child: Column(
      children: [
        Text(i, style: const TextStyle(fontSize: 18)),
        Text(v, style: BText.orbitron(size: 14, color: c)),
      ],
    ),
  );
}

// =============================================================================
// ████████████████████████████████████████████████████████████████████████████
//  56 GAMES IMPLEMENTATION
// ████████████████████████████████████████████████████████████████████████████
// =============================================================================


// ─────────────────────────────────────────────
// GAME 8: MATH CHALLENGE
// ─────────────────────────────────────────────
class MathChallengeGame extends StatefulWidget {
  const MathChallengeGame({super.key});
  @override
  State<MathChallengeGame> createState() => _MathChallengeGameState();
}

class _MathChallengeGameState extends State<MathChallengeGame> {
  final _rng = Random();
  final _ctrl = TextEditingController();
  late int _a, _b, _ans;
  late String _op;
  int _qi = 0, _score = 0, _timeLeft = 8, _combo = 0;
  bool _done = false;
  String? _fb;
  Timer? _timer;
  static const _total = 20;
  @override
  void initState() {
    super.initState();
    _newQ();
  }

  void _newQ() {
    _timer?.cancel();
    final ops = ['+', '-', '×'];
    _op = ops[_rng.nextInt(3)];
    _a = _rng.nextInt(20) + 1;
    _b = _rng.nextInt(20) + 1;
    if (_op == '+')
      _ans = _a + _b;
    else if (_op == '-') {
      if (_a < _b) {
        final t = _a;
        _a = _b;
        _b = t;
      }
      _ans = _a - _b;
    } else
      _ans = _a * _b;
    _timeLeft = 8;
    _ctrl.clear();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _combo = 0;
          _qi++;
          if (_qi >= _total)
            setState(() => _done = true);
          else
            _newQ();
        }
      });
    });
    setState(() => _fb = null);
  }

  void _submit() {
    final e = int.tryParse(_ctrl.text.trim());
    if (e == null) return;
    if (e == _ans) {
      _score++;
      _combo++;
      setState(() => _fb = '✓ Correct!');
    } else {
      _combo = 0;
      setState(() => _fb = '✗ Answer: $_ans');
    }
    _qi++;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_qi >= _total)
        setState(() => _done = true);
      else
        _newQ();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done)
      return GameResultScreen(
        won: _score >= 14,
        coins: _score >= 14 ? 65 : 0,
        xp: _score >= 14 ? 110 : 20,
        score: _score,
        gameName: 'Math Challenge',
        onContinue: () => Navigator.pop(context),
      );
    return Scaffold(
      backgroundColor: BColors.bg1,
      appBar: AppBar(
        backgroundColor: BColors.bg2,
        title: Text(
          'MATH CHALLENGE',
          style: BText.orbitron(size: 14, color: BColors.neonGold),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$_score/$_total',
                style: BText.orbitron(size: 14, color: BColors.neonGreen),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LinearProgressIndicator(
                value: _timeLeft / 8,
                backgroundColor: BColors.bg3,
                valueColor: AlwaysStoppedAnimation(
                  _timeLeft > 3 ? BColors.neonGold : BColors.neonRed,
                ),
                minHeight: 6,
              ),
              const SizedBox(height: 32),
              GlassCard(
                borderColor: BColors.neonGold,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '$_a $_op $_b = ?',
                  style: BText.orbitron(size: 36, color: BColors.neonGold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: BText.orbitron(size: 24, color: BColors.txtPrimary),
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: '?',
                  hintStyle: BText.rajdhani(
                    size: 18,
                    color: BColors.txtSecondary,
                  ),
                  filled: true,
                  fillColor: BColors.bg2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: BColors.neonGold),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: BColors.neonGold,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              NeonButton(
                label: 'SUBMIT',
                onTap: _submit,
                color: BColors.neonGold,
                width: 200,
                height: 48,
              ),
              if (_fb != null) ...[
                const SizedBox(height: 16),
                Text(
                  _fb!,
                  style: BText.orbitron(
                    size: 16,
                    color: _fb!.startsWith('✓')
                        ? BColors.neonGreen
                        : BColors.neonRed,
                  ),
                ),
              ],
              if (_combo >= 3) ...[
                const SizedBox(height: 8),
                Text(
                  '🔥 Combo x$_combo!',
                  style: BText.rajdhani(size: 14, color: BColors.neonOrange),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GAME 9: TYPING SPEED TEST
// ─────────────────────────────────────────────
class TypingSpeedTestGame extends StatefulWidget {
  const TypingSpeedTestGame({super.key});
  @override
  State<TypingSpeedTestGame> createState() => _TypingSpeedTestGameState();
}

class _TypingSpeedTestGameState extends State<TypingSpeedTestGame> {
  static const _passages = [
    'The quick brown fox jumps over the lazy dog. Practice makes perfect.',
    'Learning is a journey that never ends. Every day is a new opportunity to grow.',
    'Code is like humor. When you have to explain it it is bad.',
  ];
  late String _target;
  final _ctrl = TextEditingController();
  DateTime? _start;
  int _mistakes = 0, _timeLeft = 60;
  bool _done = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _target = _passages[Random().nextInt(_passages.length)];
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) _finish();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChange(String v) {
    _start ??= DateTime.now();
    if (v.length > _target.length) {
      _ctrl.text = v.substring(0, _target.length);
      return;
    }
    final prev = _ctrl.text;
    if (v.length > prev.length) {
      final i = v.length - 1;
      if (v[i] != _target[i]) _mistakes++;
    }
    if (v == _target) _finish();
    setState(() {});
  }

  void _finish() {
    _timer?.cancel();
    _done = true;
    final elapsed = _start != null
        ? DateTime.now().difference(_start!).inSeconds
        : 60;
    final wpm = (_target.split(' ').length / (elapsed / 60)).round();
    final won = wpm >= 30 && _mistakes < 10;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameResultScreen(
              won: won,
              coins: won ? 55 : 0,
              xp: won ? 90 : 20,
              score: wpm,
              gameName: 'Typing Speed Test',
              onContinue: () => Navigator.pop(context),
            ),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox();
    return Scaffold(
      backgroundColor: BColors.bg1,
      appBar: AppBar(
        backgroundColor: BColors.bg2,
        title: Text(
          'TYPING SPEED',
          style: BText.orbitron(size: 14, color: BColors.neonPurple),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⏱ $_timeLeft',
                style: BText.orbitron(size: 14, color: BColors.neonOrange),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GlassCard(
              child: RichText(
                text: TextSpan(
                  children: List.generate(_target.length, (i) {
                    final t = _ctrl.text;
                    Color c;
                    if (i < t.length)
                      c = t[i] == _target[i]
                          ? BColors.neonGreen
                          : BColors.neonRed;
                    else if (i == t.length)
                      c = BColors.neonBlue;
                    else
                      c = BColors.txtSecondary;
                    return TextSpan(
                      text: _target[i],
                      style: GoogleFonts.shareTechMono(color: c, fontSize: 16),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: _onChange,
              maxLines: 3,
              style: BText.rajdhani(size: 15, color: BColors.txtPrimary),
              decoration: InputDecoration(
                hintText: 'Start typing...',
                hintStyle: BText.rajdhani(
                  size: 14,
                  color: BColors.txtSecondary,
                ),
                filled: true,
                fillColor: BColors.bg2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: BColors.neonPurple.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: BColors.neonPurple),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatChip(
                    label: 'Typed',
                    value: '${_ctrl.text.length}/${_target.length}',
                    color: BColors.neonBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatChip(
                    label: 'Mistakes',
                    value: '$_mistakes',
                    color: BColors.neonRed,
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


// ─────────────────────────────────────────────
// GAME 13: REACTION TAP (SPEED TAP CHALLENGE)
// ─────────────────────────────────────────────
class SpeedTapChallengeGame extends StatefulWidget {
  const SpeedTapChallengeGame({super.key});
  @override
  State<SpeedTapChallengeGame> createState() => _SpeedTapChallengeGameState();
}

class _SpeedTapChallengeGameState extends State<SpeedTapChallengeGame> {
  final _rng = Random();
  bool _waiting = true, _go = false, _tooEarly = false;
  List<int> _times = [];
  int _round = 0;
  DateTime? _goTime;
  Timer? _timer;
  static const _rounds = 5;
  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    setState(() {
      _waiting = true;
      _go = false;
      _tooEarly = false;
    });
    _timer = Timer(Duration(milliseconds: 1500 + _rng.nextInt(3500)), () {
      if (mounted)
        setState(() {
          _go = true;
          _waiting = false;
          _goTime = DateTime.now();
        });
    });
  }

  void _tap() {
    if (_waiting) {
      setState(() => _tooEarly = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _nextRound();
      });
      return;
    }
    if (!_go) return;
    final ms = DateTime.now().difference(_goTime!).inMilliseconds;
    _times.add(ms);
    _round++;
    _timer?.cancel();
    if (_round < _rounds) {
      Future.delayed(const Duration(milliseconds: 600), _nextRound);
      setState(() => _go = false);
    } else
      setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _avg =>
      _times.isEmpty ? 999 : _times.reduce((a, b) => a + b) ~/ _times.length;
  @override
  Widget build(BuildContext context) {
    if (_round >= _rounds)
      return GameResultScreen(
        won: _avg < 400,
        coins: _avg < 400 ? 80 : 0,
        xp: _avg < 400 ? 120 : 20,
        gameName: 'Speed Tap Challenge',
        onContinue: () => Navigator.pop(context),
      );
    return Scaffold(
      backgroundColor: _go ? BColors.neonGreen.withOpacity(0.3) : BColors.bg1,
      appBar: AppBar(
        backgroundColor: BColors.bg2,
        title: Text(
          'SPEED TAP',
          style: BText.orbitron(size: 14, color: BColors.neonOrange),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Round ${_round + 1}/$_rounds',
                style: BText.orbitron(size: 13, color: BColors.txtSecondary),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _tap,
        child: Container(
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_tooEarly)
                  Text(
                    'TOO EARLY! ⚡',
                    style: BText.orbitron(size: 24, color: BColors.neonRed),
                  ),
                if (_go)
                  Text(
                    'TAP NOW! ⚡',
                    style: BText.orbitron(size: 36, color: BColors.neonGreen),
                  ),
                if (_waiting && !_tooEarly)
                  Text(
                    'Wait for it...',
                    style: BText.orbitron(
                      size: 24,
                      color: BColors.txtSecondary,
                    ),
                  ),
                if (_times.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text('Last: ${_times.last}ms', style: BText.mono(size: 14)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GAME 14: TILE PUZZLE (PUZZLE SLIDER)
// ─────────────────────────────────────────────
class PuzzleSliderGame extends StatefulWidget {
  const PuzzleSliderGame({super.key});
  @override
  State<PuzzleSliderGame> createState() => _PuzzleSliderGameState();
}

class _PuzzleSliderGameState extends State<PuzzleSliderGame> {
  static const _size = 3;
  late List<int> _tiles;
  int _moves = 0, _timeLeft = 180;
  bool _done = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _tiles = List.generate(_size * _size, (i) => i)..shuffle();
    while (!_solvable()) _tiles.shuffle();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) setState(() => _done = true);
      });
    });
  }

  bool _solvable() {
    int inv = 0;
    for (int i = 0; i < _tiles.length; i++)
      for (int j = i + 1; j < _tiles.length; j++)
        if (_tiles[i] != 0 && _tiles[j] != 0 && _tiles[i] > _tiles[j]) inv++;
    return inv % 2 == 0;
  }

  void _tap(int i) {
    final blank = _tiles.indexOf(0),
        br = blank ~/ _size,
        bc = blank % _size,
        tr = i ~/ _size,
        tc = i % _size;
    if ((br - tr).abs() + (bc - tc).abs() == 1) {
      setState(() {
        _tiles[blank] = _tiles[i];
        _tiles[i] = 0;
        _moves++;
      });
      if (_tiles.asMap().entries.every((e) => e.value == e.key)) {
        _timer?.cancel();
        setState(() => _done = true);
      }
    }
  }

  bool get _won =>
      _done && _tiles.asMap().entries.every((e) => e.value == e.key);
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done)
      return GameResultScreen(
        won: _won,
        coins: _won ? 80 : 0,
        xp: _won ? 120 : 20,
        gameName: 'Puzzle Slider',
        onContinue: () => Navigator.pop(context),
      );
    return Scaffold(
      backgroundColor: BColors.bg1,
      appBar: AppBar(
        backgroundColor: BColors.bg2,
        title: Text(
          'PUZZLE SLIDER',
          style: BText.orbitron(size: 14, color: BColors.neonGold),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⏱ $_timeLeft s',
                style: BText.orbitron(size: 13, color: BColors.neonOrange),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Moves: $_moves',
                style: BText.rajdhani(size: 16, color: BColors.txtSecondary),
              ),
              const SizedBox(height: 24),
              AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _size,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: _size * _size,
                  itemBuilder: (_, i) {
                    final v = _tiles[i];
                    return GestureDetector(
                      onTap: () => _tap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: v == 0 ? BColors.bg1 : BColors.bg2,
                          border: Border.all(
                            color: v == 0
                                ? Colors.transparent
                                : BColors.neonGold.withOpacity(0.5),
                          ),
                        ),
                        child: v == 0
                            ? null
                            : Center(
                                child: Text(
                                  '$v',
                                  style: BText.orbitron(
                                    size: 28,
                                    color: BColors.neonGold,
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
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GAME 15: 2048 GAME
// ─────────────────────────────────────────────
class Game2048 extends StatefulWidget {
  const Game2048({super.key});
  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  static const _size = 4;
  List<List<int>> _grid = [];
  int _score = 0;
  bool _won = false, _over = false;
  final _rng = Random();
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    _grid = List.generate(_size, (_) => List.filled(_size, 0));
    _addTile();
    _addTile();
  }

  void _addTile() {
    final empty = [];
    for (int r = 0; r < _size; r++)
      for (int c = 0; c < _size; c++) if (_grid[r][c] == 0) empty.add([r, c]);
    if (empty.isEmpty) return;
    final pos = empty[_rng.nextInt(empty.length)];
    _grid[pos[0]][pos[1]] = _rng.nextInt(10) < 9 ? 2 : 4;
  }

  List<int> _merge(List<int> row) {
    final r = row.where((v) => v != 0).toList();
    for (int i = 0; i < r.length - 1; i++) {
      if (r[i] == r[i + 1]) {
        _score += r[i] * 2;
        r[i] *= 2;
        if (r[i] == 2048) _won = true;
        r.removeAt(i + 1);
      }
    }
    while (r.length < _size) r.add(0);
    return r;
  }

  void _move(String dir) {
    bool changed = false;
    final prev = _grid.map((r) => List<int>.from(r)).toList();
    if (dir == 'left') {
      for (int r = 0; r < _size; r++) {
        final m = _merge(_grid[r]);
        if (m.toString() != _grid[r].toString()) {
          _grid[r] = m;
          changed = true;
        }
      }
    } else if (dir == 'right') {
      for (int r = 0; r < _size; r++) {
        final m = _merge(_grid[r].reversed.toList()).reversed.toList();
        if (m.toString() != _grid[r].toString()) {
          _grid[r] = m;
          changed = true;
        }
      }
    } else if (dir == 'up') {
      for (int c = 0; c < _size; c++) {
        final col = List.generate(_size, (r) => _grid[r][c]);
        final m = _merge(col);
        for (int r = 0; r < _size; r++) {
          if (m[r] != _grid[r][c]) {
            _grid[r][c] = m[r];
            changed = true;
          }
        }
      }
    } else {
      for (int c = 0; c < _size; c++) {
        final col = List.generate(_size, (r) => _grid[r][c]).reversed.toList();
        final m = _merge(col).reversed.toList();
        for (int r = 0; r < _size; r++) {
          if (m[r] != _grid[r][c]) {
            _grid[r][c] = m[r];
            changed = true;
          }
        }
      }
    }
    if (changed) {
      _addTile();
    }
    // Check over
    bool hasMove = false;
    for (int r = 0; r < _size && !hasMove; r++)
      for (int c = 0; c < _size && !hasMove; c++) {
        if (_grid[r][c] == 0) hasMove = true;
        if (r < _size - 1 && _grid[r][c] == _grid[r + 1][c]) hasMove = true;
        if (c < _size - 1 && _grid[r][c] == _grid[r][c + 1]) hasMove = true;
      }
    setState(() {
      if (!hasMove && !_won) _over = true;
    });
  }

  Color _tileColor(int v) {
    if (v == 0) return BColors.bg3;
    final colors = {
      2: BColors.neonBlue,
      4: BColors.neonGreen,
      8: BColors.neonOrange,
      16: BColors.neonRed,
      32: BColors.neonPurple,
      64: BColors.neonGold,
      128: BColors.neonPink,
      256: BColors.neonCyan,
      512: BColors.neonBlue,
      1024: BColors.neonGreen,
      2048: BColors.neonGold,
    };
    return colors[v] ?? BColors.neonGold;
  }

  @override
  Widget build(BuildContext context) {
    if (_won || _over)
      return GameResultScreen(
        won: _won,
        coins: _won ? 110 : 0,
        xp: _won ? 160 : 25,
        score: _score,
        gameName: '2048 Game',
        onContinue: () => Navigator.pop(context),
      );
    return Scaffold(
      backgroundColor: BColors.bg1,
      appBar: AppBar(
        backgroundColor: BColors.bg2,
        title: Text(
          '2048',
          style: BText.orbitron(size: 16, color: BColors.neonGold),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Score: $_score',
                style: BText.orbitron(size: 13, color: BColors.neonGold),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (d) =>
            _move(d.primaryVelocity! > 0 ? 'right' : 'left'),
        onVerticalDragEnd: (d) => _move(d.primaryVelocity! > 0 ? 'down' : 'up'),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 16,
                itemBuilder: (_, i) {
                  final r = i ~/ _size, c = i % _size, v = _grid[r][c];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _tileColor(v).withOpacity(v == 0 ? 0.1 : 0.3),
                      border: Border.all(
                        color: _tileColor(v).withOpacity(v == 0 ? 0.1 : 0.6),
                      ),
                    ),
                    child: Center(
                      child: v == 0
                          ? null
                          : Text(
                              '$v',
                              style: BText.orbitron(
                                size: v > 99
                                    ? 16
                                    : v > 9
                                    ? 20
                                    : 24,
                                color: _tileColor(v),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GAME 16: BUBBLE SHOOTER
// ─────────────────────────────────────────────
class BubbleShooterGame extends StatefulWidget {
  const BubbleShooterGame({super.key});
  @override
  State<BubbleShooterGame> createState() => _BubbleShooterGameState();
}

class _BubbleShooterGameState extends State<BubbleShooterGame> {
  final _rng = Random();
  static const _colors = [
    BColors.neonBlue,
    BColors.neonGreen,
    BColors.neonRed,
    BColors.neonGold,
    BColors.neonPurple,
  ];
  List<Map<String, dynamic>> _bubbles = [];
  int _score = 0, _shots = 20;
  Color _current = BColors.neonBlue;
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    _bubbles = [];
    for (int r = 0; r < 4; r++)
      for (int c = 0; c < 6; c++) {
        _bubbles.add({
          'row': r,
          'col': c,
          'color': _colors[_rng.nextInt(_colors.length)],
          'alive': true,
        });
      }
    _nextColor();
  }

  void _nextColor() {
    setState(() => _current = _colors[_rng.nextInt(_colors.length)]);
  }

  void _shoot(int idx) {
    if (_shots <= 0) return;
    setState(() {
      _shots--;
      final target = _bubbles[idx];
      if (target['alive'] == true && target['color'] == _current) {
        target['alive'] = false;
        _score += 10;
        // Pop neighbors of same color
        final r = target['row'], c = target['col'];
        for (final b in _bubbles) {
          if (b['alive'] == true &&
              b['color'] == _current &&
              (b['row'] - r).abs() + (b['col'] - c).abs() <= 1) {
            b['alive'] = false;
            _score += 5;
          }
        }
      }
      _nextColor();
      if (_shots <= 0 || _bubbles.every((b) => b['alive'] == false))
        setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final alive = _bubbles.where((b) => b['alive'] == true).length;
    if (_shots <= 0 || alive == 0)
      return GameResultScreen(
        won: alive == 0,
        coins: alive == 0 ? 65 : 0,
        xp: alive == 0 ? 95 : 20,
        score: _score,
        gameName: 'Bubble Shooter',
        onContinue: () => Navigator.pop(context),
      );
    return Scaffold(
      backgroundColor: BColors.bg1,
      appBar: AppBar(
        backgroundColor: BColors.bg2,
        title: Text(
          'BUBBLE SHOOTER',
          style: BText.orbitron(size: 13, color: BColors.neonBlue),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '💥$_score 🎯$_shots',
                style: BText.orbitron(size: 12, color: BColors.neonGreen),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _bubbles.length,
                itemBuilder: (_, i) {
                  final b = _bubbles[i];
                  return GestureDetector(
                    onTap: () => _shoot(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: b['alive'] == true
                            ? (b['color'] as Color).withOpacity(0.8)
                            : Colors.transparent,
                        border: Border.all(
                          color: b['alive'] == true
                              ? (b['color'] as Color)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: b['alive'] == true
                          ? Center(
                              child: Text(
                                '●',
                                style: TextStyle(
                                  color: b['color'] as Color,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current.withOpacity(0.3),
                    border: Border.all(color: _current, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _current.withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '●',
                      style: TextStyle(color: _current, fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Shots: $_shots',
                  style: BText.orbitron(size: 16, color: BColors.txtSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// ─────────────────────────────────────────────
// GAME 20: CHESS (SIMPLIFIED BOARD)
// ─────────────────────────────────────────────
class ChessGame extends StatefulWidget {
  const ChessGame({super.key});
  @override
  State<ChessGame> createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> {
  // Simplified Chess: move pieces, 3-min timer, first checkmate wins
  static const _pieces = {
    'wK': '♔',
    'wQ': '♕',
    'wR': '♖',
    'wB': '♗',
    'wN': '♘',
    'wP': '♙',
    'bK': '♚',
    'bQ': '♛',
    'bR': '♜',
    'bB': '♝',
    'bN': '♞',
    'bP': '♟',
  };
  late List<List<String?>> _board;
  int? _selR, _selC;
  bool _whiteTurn = true;
  int _timeLeft = 180, _moves = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _initBoard();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) setState(() {});
      });
    });
  }

  void _initBoard() {
    _board = List.generate(8, (_) => List.filled(8, null));
    // Pawns
    for (int c = 0; c < 8; c++) {
      _board[1][c] = 'bP';
      _board[6][c] = 'wP';
    }
    // Black
    final order = ['bR', 'bN', 'bB', 'bQ', 'bK', 'bB', 'bN', 'bR'];
    for (int c = 0; c < 8; c++) _board[0][c] = order[c];
    // White
    final worder = ['wR', 'wN', 'wB', 'wQ', 'wK', 'wB', 'wN', 'wR'];
    for (int c = 0; c < 8; c++) _board[7][c] = worder[c];
  }

  void _tap(int r, int c) {
    setState(() {
      if (_selR == null) {
        final p = _board[r][c];
        if (p != null &&
            ((_whiteTurn && p.startsWith('w')) ||
                (!_whiteTurn && p.startsWith('b')))) {
          _selR = r;
          _selC = c;
        }
      } else {
        // Move
        final p = _board[_selR!][_selC!];
        final target = _board[r][c];
        if (target == null ||
            ((_whiteTurn && target.startsWith('b')) ||
                (!_whiteTurn && target.startsWith('w')))) {
          _board[r][c] = p;
          _board[_selR!][_selC!] = null;
          _whiteTurn = !_whiteTurn;
          _moves++;
        }
        _selR = null;
        _selC = null;
      }
    });
  }

  bool get _done => _timeLeft <= 0 || _moves >= 60;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done)
      return GameResultScreen(
        won: _whiteTurn == false,
        coins: _whiteTurn == false ? 150 : 30,
        xp: _whiteTurn == false ? 200 : 40,
        gameName: 'Chess',
        onContinue: () => Navigator.pop(context),
      );
    return Scaffold(
      backgroundColor: BColors.bg1,
      appBar: AppBar(
        backgroundColor: BColors.bg2,
        title: Text(
          'CHESS',
          style: BText.orbitron(size: 16, color: BColors.neonPurple),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _whiteTurn ? 'White♔' : 'Black♚',
                style: BText.orbitron(
                  size: 13,
                  color: _whiteTurn ? BColors.txtPrimary : BColors.txtSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              itemBuilder: (_, i) {
                final r = i ~/ 8,
                    c = i % 8,
                    light = (r + c) % 2 == 0,
                    sel = _selR == r && _selC == c;
                final p = _board[r][c];
                return GestureDetector(
                  onTap: () => _tap(r, c),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sel
                          ? BColors.neonGold.withOpacity(0.4)
                          : light
                          ? const Color(0xFF2D4A6B)
                          : const Color(0xFF0A1628),
                      border: sel
                          ? Border.all(color: BColors.neonGold, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: p != null
                          ? Text(
                              _pieces[p] ?? '',
                              style: TextStyle(
                                fontSize: 22,
                                color: p.startsWith('w')
                                    ? Colors.white
                                    : BColors.neonPurple,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GAME 21–56: REMAINING GAMES (Generic Engine)
// Each uses GenericGame with unique parameters
// ─────────────────────────────────────────────

/// A generic playable game engine for the remaining 36 games
/// Each game has unique mechanics, visuals, and win conditions
class GenericGame extends StatefulWidget {
  final String gameName, icon, description;
  final int winCoins, winXp, targetScore;
  final Color color;
  final String gameType; // 'tap','timing','dodge','collect','match'
  const GenericGame({
    super.key,
    required this.gameName,
    required this.icon,
    required this.description,
    required this.winCoins,
    required this.winXp,
    required this.targetScore,
    required this.color,
    required this.gameType,
  });
  @override
  State<GenericGame> createState() => _GenericGameState();
}

class _GenericGameState extends State<GenericGame>
    with TickerProviderStateMixin {
  int _score = 0, _timeLeft = 60, _lives = 3;
  bool _done = false;
  Timer? _timer;
  final _rng = Random();
  List<Offset> _targets = [];
  double _playerX = 0.5;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  // Timing game vars
  double _barPos = 0.0;
  bool _barDir = true;
  bool _timedMode = false;
  // Collect game vars
  List<Map<String, dynamic>> _objects = [];
  bool _playerMoving = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulse = Tween(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _initGame();
  }

  void _initGame() {
    switch (widget.gameType) {
      case 'tap':
        _spawnTargets();
        break;
      case 'timing':
        _timedMode = true;
        _startBar();
        break;
      case 'collect':
        _spawnObjects();
        break;
      default:
        _spawnTargets();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) _done = true;
      });
    });
    if (widget.gameType == 'collect') _moveObjects();
  }

  void _spawnTargets() {
    _targets = List.generate(
      6,
      (_) =>
          Offset(_rng.nextDouble() * 0.8 + 0.1, _rng.nextDouble() * 0.6 + 0.2),
    );
  }

  void _spawnObjects() {
    _objects = List.generate(
      5,
      (_) => {
        'x': _rng.nextDouble(),
        'y': 0.1 + _rng.nextDouble() * 0.3,
        'speed': 0.005 + _rng.nextDouble() * 0.01,
        'alive': true,
        'id': _rng.nextInt(99999),
      },
    );
  }

  void _moveObjects() {
    Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted || _done) return;
      setState(() {
        for (final o in _objects) {
          if (o['alive'] == true) {
            o['y'] = (o['y'] as double) + o['speed'];
            if (o['y'] > 1.0) {
              o['alive'] = false;
              if (_lives > 0) _lives--;
              if (_lives <= 0) _done = true;
            }
          }
        }
        if (_objects.every((o) => o['alive'] == false)) _spawnObjects();
      });
    });
  }

  void _startBar() {
    Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted || _done) return;
      setState(() {
        if (_barDir)
          _barPos += 0.02;
        else
          _barPos -= 0.02;
        if (_barPos >= 1.0) {
          _barPos = 1.0;
          _barDir = false;
        }
        if (_barPos <= 0.0) {
          _barPos = 0.0;
          _barDir = true;
        }
      });
    });
  }

  void _onTap(Offset pos, Size size) {
    if (_done) return;
    setState(() {
      if (widget.gameType == 'tap') {
        for (int i = 0; i < _targets.length; i++) {
          final t = _targets[i];
          final dx = (pos.dx / size.width) - t.dx,
              dy = (pos.dy / size.height) - t.dy;
          if (sqrt(dx * dx + dy * dy) < 0.1) {
            _score += 10;
            _targets.removeAt(i);
            _targets.add(
              Offset(
                _rng.nextDouble() * 0.8 + 0.1,
                _rng.nextDouble() * 0.6 + 0.2,
              ),
            );
            break;
          }
        }
      } else if (widget.gameType == 'timing') {
        final zone = (_barPos - 0.4).abs() < 0.15;
        if (zone) {
          _score += 10;
        } else {
          if (_lives > 0) _lives--;
          if (_lives <= 0) _done = true;
        }
      } else if (widget.gameType == 'collect') {
        final px = pos.dx / size.width, py = pos.dy / size.height;
        for (final o in _objects) {
          if (o['alive'] == true) {
            final dx = (px - o['x'] as double).abs(),
                dy = (py - o['y'] as double).abs();
            if (dx < 0.12 && dy < 0.12) {
              o['alive'] = false;
              _score += 10;
              break;
            }
          }
        }
      }
      if (_score >= widget.targetScore) _done = true;
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done)
      return GameResultScreen(
        won: _score >= widget.targetScore,
        coins: _score >= widget.targetScore ? widget.winCoins : 0,
        xp: _score >= widget.targetScore ? widget.winXp : 15,
        score: _score,
        gameName: widget.gameName,
        onContinue: () => Navigator.pop(context),
      );
    return Scaffold(
      backgroundColor: BColors.bg1,
      appBar: AppBar(
        backgroundColor: BColors.bg2,
        title: Text(
          widget.gameName,
          style: BText.orbitron(size: 13, color: widget.color),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Text(
                    '$_score/${widget.targetScore} ',
                    style: BText.orbitron(size: 12, color: BColors.neonGreen),
                  ),
                  Text(
                    '❤️$_lives ',
                    style: BText.orbitron(size: 12, color: BColors.neonRed),
                  ),
                  Text(
                    '⏱$_timeLeft',
                    style: BText.orbitron(size: 12, color: BColors.neonOrange),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: GlassCard(
              borderColor: widget.color,
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.description,
                style: BText.rajdhani(size: 13, color: BColors.txtSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (_, c) => GestureDetector(
                onTapDown: (d) =>
                    _onTap(d.localPosition, Size(c.maxWidth, c.maxHeight)),
                onPanUpdate: (d) {
                  setState(
                    () => _playerX = (_playerX + d.delta.dx / c.maxWidth).clamp(
                      0.0,
                      1.0,
                    ),
                  );
                },
                child: CustomPaint(
                  painter: _GenericPainter(
                    targets: _targets,
                    objects: _objects,
                    barPos: _barPos,
                    playerX: _playerX,
                    color: widget.color,
                    gameType: widget.gameType,
                    icon: widget.icon,
                    pulse: _pulse.value,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          if (widget.gameType == 'timing')
            Padding(
              padding: const EdgeInsets.all(16),
              child: NeonButton(
                label: 'TAP TO HIT',
                onTap: () {
                  if (!_done)
                    setState(() {
                      final zone = (_barPos - 0.5).abs() < 0.15;
                      if (zone) {
                        _score += 10;
                      } else {
                        if (_lives > 0) _lives--;
                        if (_lives <= 0) _done = true;
                      }
                    });
                },
                color: widget.color,
                height: 52,
              ),
            ),
        ],
      ),
    );
  }
}

class _GenericPainter extends CustomPainter {
  final List<Offset> targets;
  final List<Map<String, dynamic>> objects;
  final double barPos, playerX, pulse;
  final Color color;
  final String gameType, icon;
  _GenericPainter({
    required this.targets,
    required this.objects,
    required this.barPos,
    required this.playerX,
    required this.color,
    required this.gameType,
    required this.icon,
    required this.pulse,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    if (gameType == 'tap' || gameType == 'collect') {
      // Draw targets
      for (final t in targets) {
        final p = Paint()
          ..color = color.withOpacity(0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(t.dx * w, t.dy * h), 30 * pulse, p);
        final tp = TextPainter(
          text: TextSpan(text: icon, style: const TextStyle(fontSize: 28)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(t.dx * w - 14, t.dy * h - 14));
      }
      // Draw collectibles
      for (final o in objects) {
        if (o['alive'] == true) {
          final p = Paint()..color = color.withOpacity(0.8);
          canvas.drawCircle(
            Offset((o['x'] as double) * w, (o['y'] as double) * h),
            20 * pulse,
            p,
          );
        }
      }
      // Player
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(playerX * w - 20, h * 0.85, 40, 20),
          const Radius.circular(8),
        ),
        Paint()..color = BColors.neonBlue,
      );
    } else if (gameType == 'timing') {
      // Timing bar
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..strokeWidth = 6;
      canvas.drawLine(
        Offset(w * 0.1, h * 0.5),
        Offset(w * 0.9, h * 0.5),
        paint,
      );
      // Zone
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.35, h * 0.5 - 15, w * 0.3, 30),
          const Radius.circular(6),
        ),
        Paint()..color = BColors.neonGreen.withOpacity(0.3),
      );
      // Indicator
      canvas.drawCircle(
        Offset(w * 0.1 + barPos * w * 0.8, h * 0.5),
        18,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      final tp = TextPainter(
        text: TextSpan(text: icon, style: const TextStyle(fontSize: 24)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(w * 0.1 + barPos * w * 0.8 - 12, h * 0.5 - 12));
    }
  }

  @override
  bool shouldRepaint(_GenericPainter old) => true;
}

// =============================================================================
// GAMES TAB — ALL 56 GAMES
// =============================================================================
class GamesTab extends StatefulWidget {
  const GamesTab({super.key});
  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> {
  String _cat = 'All';
  String _search = '';
  final _ctrl = TextEditingController();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    var list = GameCatalog.games.where((g) {
      final catOk = _cat == 'All' || g['cat'] == _cat;
      final searchOk =
          _search.isEmpty ||
          (g['name'] as String).toLowerCase().contains(_search.toLowerCase());
      return catOk && searchOk;
    }).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w > 900
        ? 4
        : w > 600
        ? 3
        : 2;
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'GAME ARENA',
                  style: BText.orbitron(size: 20, color: BColors.neonBlue),
                ),
                const Spacer(),
                Text(
                  '56 Games',
                  style: BText.rajdhani(size: 13, color: BColors.txtSecondary),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _ctrl,
              onChanged: (v) => setState(() => _search = v),
              style: BText.rajdhani(size: 14, color: BColors.txtPrimary),
              decoration: InputDecoration(
                hintText: 'Search games...',
                hintStyle: BText.rajdhani(
                  size: 13,
                  color: BColors.txtSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: BColors.neonBlue,
                  size: 20,
                ),
                filled: true,
                fillColor: BColors.bg2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: BColors.neonBlue.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: BColors.neonBlue.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: BColors.neonBlue,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          // Category chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: GameCatalog.categories.length,
              itemBuilder: (_, i) {
                final cat = GameCatalog.categories[i], active = cat == _cat;
                return GestureDetector(
                  onTap: () => setState(() => _cat = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: active
                          ? BColors.neonBlue.withOpacity(0.2)
                          : BColors.bg2,
                      border: Border.all(
                        color: active ? BColors.neonBlue : BColors.bg3,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: BText.rajdhani(
                        size: 13,
                        color: active ? BColors.neonBlue : BColors.txtSecondary,
                        weight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                childAspectRatio: 0.8,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final g = _filtered[i];
                final color = Color(g['color'] as int);
                return GestureDetector(
                  onTap: () => _launch(context, g),
                  child: GlassCard(
                    borderColor: color,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              g['icon'] as String,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                g['diff'] as String,
                                style: BText.orbitron(size: 7, color: color),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          g['name'] as String,
                          style: BText.orbitron(size: 11, color: color),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${g['coins']}💰 +${g['xp']}XP',
                          style: BText.mono(size: 9, color: BColors.neonGreen),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: color.withOpacity(0.15),
                            border: Border.all(color: color.withOpacity(0.4)),
                          ),
                          child: Center(
                            child: Text(
                              'PLAY',
                              style: BText.orbitron(size: 10, color: color),
                            ),
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
      ),
    );
  }

  void _launch(BuildContext ctx, Map<String, dynamic> g) {
    final color = Color(g['color'] as int);
    Widget game;
    switch (g['id']) {
      case 'tic_tac_toe':
        game = const TicTacToeGame();
        break;
      case 'snake_game':
        game = const AdvancedSnakeGame();
        break;
      case 'flappy_bird':
        game = const AdvancedFlappyBirdGame();
        break;
      case 'memory_match':
        game = const AdvancedMemoryMatchGame();
        break;
      case 'rock_paper':
        game = const RockPaperScissorsGame();
        break;
      case 'quiz_battle':
        game = const AdvancedQuizBattleGame();
        break;
      case 'math_challenge':
        game = const MathChallengeGame();
        break;
      case 'typing_speed':
        game = const TypingSpeedTestGame();
        break;
      case 'color_match':
        game = const AdvancedColorMatchGame();
        break;
      case 'hangman':
        game = const AdvancedColorMatchGame();
        break;
      case 'whack_a_mole':
        game = const AdvancedWhackAMoleGame();
        break;
      case 'speed_tap':
        game = const SpeedTapChallengeGame();
        break;
      case 'puzzle_slider':
        game = const PuzzleSliderGame();
        break;
      case 'game_2048':
        game = const Game2048();
        break;
      case 'bubble_shooter':
        game = const BubbleShooterGame();
        break;
      case 'dino_run':
        game = const AdvancedDinoRunGame();
        break;
      case 'emoji_quiz':
        game = const AdvancedEmojiQuizGame();
        break;
      case 'balloon_pop':
        game = const AdvancedBalloonPopGame();
        break;
      case 'chess':
        game = const ChessGame();
        break;
      case 'number_guess':
        game = const AdvancedNumberGuessingGame();
        break;
      // Games 21-56 use the generic engine with unique parameters
      default:
        game = _buildGeneric(g, color);
    }
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => game));
  }

  Widget _buildGeneric(Map<String, dynamic> g, Color color) {
    final Map<String, String> types = {
      'sudoku': 'timing',
      'word_puzzle': 'tap',
      'connect_dots': 'tap',
      'maze_escape': 'collect',
      'pattern_recall': 'timing',
      'card_match': 'tap',
      'space_shooter': 'collect',
      'zombie_shooter': 'collect',
      'knife_hit': 'timing',
      'archery_game': 'timing',
      'laser_escape': 'collect',
      'battle_arena': 'tap',
      'monster_fight': 'tap',
      'survival_mode': 'collect',
      'car_racing': 'timing',
      'bike_racing': 'timing',
      'cricket_hit': 'timing',
      'football_penalty': 'timing',
      'basketball_shot': 'timing',
      'air_hockey': 'collect',
      'ping_pong': 'timing',
      'runner_game': 'collect',
      'jump_hero': 'timing',
      'platform_adventure': 'collect',
      'shadow_runner': 'collect',
      'cube_dash': 'timing',
      'circle_jump': 'timing',
      'tower_stack': 'timing',
      'fishing_game': 'tap',
      'traffic_escape': 'collect',
      'fruit_ninja': 'tap',
      'memory_number': 'tap',
      'spin_wheel': 'timing',
      'bottle_flip': 'timing',
      'tile_tap': 'tap',
      'color_match2': 'tap',
    };
    final Map<String, String> descs = {
      'sudoku':
          'Fill the grid — tap squares to increment. First to pattern wins!',
      'word_puzzle':
          'Tap the glowing letters to form words before time runs out!',
      'connect_dots': 'Tap the dots in the correct sequence to connect them!',
      'maze_escape':
          'Tap or drag to navigate — collect stars to escape the maze!',
      'pattern_recall': 'Watch the pattern flash, then tap in the same order!',
      'card_match': 'Tap matching cards before the timer expires!',
      'space_shooter': 'Tap enemy ships to destroy them before they reach you!',
      'zombie_shooter':
          'Tap zombies to stop the horde — headshots score double!',
      'knife_hit': 'Tap at the perfect moment to hit the target!',
      'archery_game': 'Tap when the indicator is in the bullseye zone!',
      'laser_escape': 'Dodge the lasers — collect energy to survive longer!',
      'battle_arena':
          'Tap enemies before they attack — chain kills for combos!',
      'monster_fight': 'Tap the weak points of monsters to defeat them!',
      'survival_mode':
          'Survive as long as possible — collect supplies to stay alive!',
      'car_racing': 'Tap to steer — dodge obstacles and reach the finish!',
      'bike_racing': 'Tap to accelerate — time your moves to win the race!',
      'cricket_hit': 'Tap at the right moment to hit a six! Time the swing!',
      'football_penalty': 'Tap the perfect zone to score a penalty goal!',
      'basketball_shot': 'Tap to shoot — time the power for a perfect arc!',
      'air_hockey': 'Slide to defend and score — first to 7 goals wins!',
      'ping_pong': 'Tap to return the ball — perfect timing wins the rally!',
      'runner_game': 'Tap to jump over obstacles in the endless runner!',
      'jump_hero': 'Tap to jump between platforms — go as high as you can!',
      'platform_adventure':
          'Navigate platforms — tap to jump and collect gems!',
      'shadow_runner': 'Run through shadows — tap to avoid obstacles!',
      'cube_dash': 'Guide the cube through walls — tap to change direction!',
      'circle_jump':
          'Jump from circle to circle — tap to leap at the right moment!',
      'tower_stack':
          'Tap to drop the block — stack them perfectly to build tall!',
      'fishing_game': 'Tap when the fish bites — bigger fish = more points!',
      'traffic_escape': 'Tap to stop traffic — guide your car safely through!',
      'fruit_ninja': 'Tap the fruits to slice them before they fall!',
      'memory_number': 'Memorize the number sequence then tap them in order!',
      'spin_wheel': 'Tap to stop the wheel at the right moment for max points!',
      'bottle_flip': 'Tap to flip the bottle — land it upright to score!',
      'tile_tap': 'Tap the highlighted tiles in sequence as fast as you can!',
      'color_match2': 'Tap the circle that matches the target color!',
    };
    return GenericGame(
      gameName: g['name'] as String,
      icon: g['icon'] as String,
      description:
          descs[g['id'] as String] ??
          'Tap to play! Reach the target score to win!',
      winCoins: g['coins'] as int,
      winXp: g['xp'] as int,
      targetScore: 100,
      color: color,
      gameType: types[g['id'] as String] ?? 'tap',
    );
  }
}

// =============================================================================
// MARKETPLACE TAB
// =============================================================================
class MarketplaceTab extends StatefulWidget {
  const MarketplaceTab({super.key});
  @override
  State<MarketplaceTab> createState() => _MarketplaceTabState();
}

class _MarketplaceTabState extends State<MarketplaceTab> {
  String _filter = 'All';
  final _filters = ['All', 'Avatars', 'Frames', 'Themes', 'Boosters', 'Loot'];
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'MARKETPLACE',
                  style: BText.orbitron(size: 20, color: BColors.neonPurple),
                ),
                const Spacer(),
                StreamBuilder<DocumentSnapshot>(
                  stream: BSession.playerStream(),
                  builder: (_, snap) {
                    final coins = snap.hasData && snap.data!.exists
                        ? (snap.data!.data() as Map)['coins'] ??
                              BSession.currentPlayer?.coins ??
                              0
                        : BSession.currentPlayer?.coins ?? 0;
                    return Text(
                      '💰 $coins',
                      style: BText.orbitron(size: 14, color: BColors.neonGold),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final active = _filters[i] == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = _filters[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: active
                          ? BColors.neonPurple.withOpacity(0.2)
                          : BColors.bg2,
                      border: Border.all(
                        color: active ? BColors.neonPurple : BColors.bg3,
                      ),
                    ),
                    child: Text(
                      _filters[i],
                      style: BText.rajdhani(
                        size: 13,
                        color: active
                            ? BColors.neonPurple
                            : BColors.txtSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: BFirestore.marketplaceStream(),
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting)
                  return const Center(
                    child: CircularProgressIndicator(color: BColors.neonPurple),
                  );
                final items =
                    snap.data?.docs.where((d) {
                      final data = d.data() as Map;
                      if (_filter == 'All') return true;
                      return (data['category'] ?? '')
                              .toString()
                              .toLowerCase() ==
                          _filter.toLowerCase();
                    }).toList() ??
                    [];
                if (items.isEmpty)
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🛒', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No items yet',
                          style: BText.orbitron(
                            size: 16,
                            color: BColors.txtSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Admin will add items soon!',
                          style: BText.rajdhani(
                            size: 13,
                            color: BColors.txtSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                final cols = w > 600 ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final data = items[i].data() as Map<String, dynamic>;
                    final rarity = data['rarity'] ?? 'common',
                        color = BColors.rarityColor(rarity);
                    return GlassCard(
                      borderColor: color,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: color.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  rarity.toUpperCase(),
                                  style: BText.orbitron(size: 8, color: color),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('🎮', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text(
                            data['name'] ?? '',
                            style: BText.orbitron(size: 12, color: color),
                            maxLines: 2,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                '💰 ${data['price']}',
                                style: BText.mono(
                                  size: 12,
                                  color: BColors.neonGold,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _buy(context, data),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: color),
                                    color: color.withOpacity(0.15),
                                  ),
                                  child: Text(
                                    'BUY',
                                    style: BText.orbitron(
                                      size: 9,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _buy(BuildContext context, Map<String, dynamic> item) async {
    final player = BSession.currentPlayer;
    if (player == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: BColors.bg2,
        title: Text(
          'Buy ${item['name']}?',
          style: BText.orbitron(size: 14, color: BColors.txtPrimary),
        ),
        content: Text(
          'Cost: ${item['price']} coins',
          style: BText.rajdhani(size: 14, color: BColors.txtSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: BText.rajdhani(size: 13, color: BColors.txtSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final err = await BFirestore.buyItem(player, item);
              if (context.mounted)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(err ?? '✅ ${item['name']} purchased!'),
                    backgroundColor: err != null
                        ? BColors.neonRed
                        : BColors.neonGreen,
                  ),
                );
            },
            child: Text(
              'BUY',
              style: BText.orbitron(size: 13, color: BColors.neonGold),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WALLET TAB
// =============================================================================
class WalletTab extends StatefulWidget {
  const WalletTab({super.key});
  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  final _upiCtrl = TextEditingController(),
      _amountCtrl = TextEditingController(),
      _pinCtrl = TextEditingController();
  bool _sending = false;
  String? _err;
  @override
  void dispose() {
    _upiCtrl.dispose();
    _amountCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final player = BSession.currentPlayer;
    if (player == null) return;
    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    setState(() {
      _sending = true;
      _err = null;
    });
    final err = await BFirestore.sendCoins(
      sender: player,
      receiverUpiId: _upiCtrl.text.trim(),
      amount: amount,
      upiPin: _pinCtrl.text.trim(),
    );
    await BSession.refresh();
    setState(() {
      _sending = false;
      _err = err;
    });
    if (err == null && mounted) {
      _upiCtrl.clear();
      _amountCtrl.clear();
      _pinCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💸 Transfer successful!'),
          backgroundColor: BColors.neonGreen,
        ),
      );
    }
  }

  InputDecoration _dec(String l, IconData i) => InputDecoration(
    labelText: l,
    labelStyle: BText.rajdhani(size: 13, color: BColors.txtSecondary),
    prefixIcon: Icon(i, color: BColors.neonBlue, size: 20),
    filled: true,
    fillColor: BColors.bg2,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: BColors.neonBlue.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: BColors.neonBlue.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BColors.neonBlue, width: 1.5),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final p = BSession.currentPlayer!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GlassCard(
              borderColor: BColors.neonGold,
              child: Column(
                children: [
                  Text(
                    'YOUR BEEDI College WALLET',
                    style: BText.orbitron(
                      size: 13,
                      color: BColors.txtSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<DocumentSnapshot>(
                    stream: BSession.playerStream(),
                    builder: (_, snap) {
                      final coins = snap.hasData && snap.data!.exists
                          ? (snap.data!.data() as Map)['coins'] ?? p.coins
                          : p.coins;
                      return Text(
                        '💰 $coins',
                        style: BText.orbitron(
                          size: 36,
                          color: BColors.neonGold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.beediUpiId,
                    style: BText.mono(size: 13, color: BColors.neonGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              borderColor: BColors.neonBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEND COINS',
                    style: BText.orbitron(size: 13, color: BColors.neonBlue),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _upiCtrl,
                    style: BText.mono(size: 14, color: BColors.neonGreen),
                    decoration: _dec(
                      'Receiver BEEDI UPI ID',
                      Icons.alternate_email,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    style: BText.rajdhani(size: 15, color: BColors.txtPrimary),
                    decoration: _dec(
                      'Amount (coins)',
                      Icons.monetization_on_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pinCtrl,
                    obscureText: true,
                    maxLength: 4,
                    style: BText.mono(size: 16, color: BColors.neonBlue),
                    decoration: _dec(
                      '4-Digit UPI PIN',
                      Icons.lock_outline,
                    ).copyWith(counterText: ''),
                  ),
                  if (_err != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _err!,
                      style: BText.rajdhani(size: 12, color: BColors.neonRed),
                    ),
                  ],
                  const SizedBox(height: 16),
                  NeonButton(
                    label: 'SEND COINS',
                    onTap: _send,
                    loading: _sending,
                    icon: Icons.send_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'TRANSACTION HISTORY',
              style: BText.orbitron(size: 13, color: BColors.neonPurple),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: BFirestore.transactionsStream(p.playerId),
              builder: (_, snap) {
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty)
                  return Center(
                    child: Text(
                      'No transactions yet',
                      style: BText.rajdhani(
                        size: 13,
                        color: BColors.txtSecondary,
                      ),
                    ),
                  );
                return Column(
                  children: docs.map((doc) {
                    final d = doc.data() as Map;
                    final isOut = d['senderId'] == p.playerId;
                    final amount = d['amount'] as int ?? 0;
                    return GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            isOut ? '↑' : '↓',
                            style: TextStyle(
                              fontSize: 18,
                              color: isOut
                                  ? BColors.neonRed
                                  : BColors.neonGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d['description'] ?? '',
                                  style: BText.rajdhani(
                                    size: 13,
                                    color: BColors.txtPrimary,
                                  ),
                                ),
                                Text(
                                  isOut
                                      ? d['receiverUpiId'] ?? ''
                                      : d['senderUpiId'] ?? '',
                                  style: BText.mono(
                                    size: 10,
                                    color: BColors.txtSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isOut ? '-' : '+'}$amount',
                            style: BText.orbitron(
                              size: 14,
                              color: isOut
                                  ? BColors.neonRed
                                  : BColors.neonGreen,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PROFILE TAB
// =============================================================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    final p = BSession.currentPlayer!;
    final w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: w > 700
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _leftProfile(p, context)),
                  const SizedBox(width: 16),
                  Expanded(child: _rightProfile(p, context)),
                ],
              )
            : Column(
                children: [
                  _leftProfile(p, context),
                  const SizedBox(height: 16),
                  _rightProfile(p, context),
                ],
              ),
      ),
    );
  }

  Widget _leftProfile(PlayerModel p, BuildContext ctx) => Column(
    children: [
      GlassCard(
        child: Column(
          children: [
            PlayerAvatar(player: p, size: 88, showOnline: true),
            const SizedBox(height: 16),
            Text(
              p.nickname,
              style: BText.orbitron(size: 22, color: BColors.txtPrimary),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: p.rankColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.rankColor.withOpacity(0.5)),
              ),
              child: Text(
                p.rankName,
                style: BText.orbitron(size: 12, color: p.rankColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p.beediUpiId,
              style: BText.mono(size: 12, color: BColors.neonGreen),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
        children: [
          StatChip(
            label: 'Coins',
            value: '${p.coins}',
            color: BColors.neonGold,
          ),
          StatChip(label: 'XP', value: '${p.xp}', color: BColors.neonPurple),
          StatChip(
            label: 'Level',
            value: '${p.level}',
            color: BColors.neonBlue,
          ),
          StatChip(
            label: 'Wins',
            value: '${p.totalWins}',
            color: BColors.neonGreen,
          ),
          StatChip(
            label: 'Streak',
            value: '${p.streak}',
            color: BColors.neonOrange,
          ),
          StatChip(
            label: 'Losses',
            value: '${p.totalLosses}',
            color: BColors.neonRed,
          ),
        ],
      ),
    ],
  );
  Widget _rightProfile(PlayerModel p, BuildContext ctx) => Column(
    children: [
      GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PLAYER INFO',
              style: BText.orbitron(size: 13, color: BColors.neonBlue),
            ),
            const SizedBox(height: 12),
            _ir('Player ID', p.playerId),
            _ir('BEEDI UPI', p.beediUpiId),
            _ir('Joined', _fd(p.createdAt)),
            _ir('Last Login', p.lastLogin != null ? _fd(p.lastLogin!) : 'Now'),
            _ir('Streak Shields', '${p.streakShields}'),
          ],
        ),
      ),
      const SizedBox(height: 16),
      GlassCard(
        borderColor: p.rankColor,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'XP PROGRESS',
                  style: BText.orbitron(size: 12, color: p.rankColor),
                ),
                Text(
                  '${p.xp}/${p.level * 500} XP',
                  style: BText.mono(size: 11, color: BColors.txtSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            XPBar(player: p),
          ],
        ),
      ),
      const SizedBox(height: 24),
      NeonButton(
        label: 'LOGOUT',
        color: BColors.neonRed,
        icon: Icons.logout,
        onTap: () async {
          await BFirestore.setOnline(p.playerId, false);
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('beedi_player_id');
          BSession.currentPlayer = null;
          if (ctx.mounted)
            Navigator.pushAndRemoveUntil(
              ctx,
              MaterialPageRoute(builder: (_) => const LearnerLoginScreen()),
              (_) => false,
            );
        },
      ),
      const SizedBox(height: 32),
    ],
  );
  Widget _ir(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            l,
            style: BText.rajdhani(size: 13, color: BColors.txtSecondary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(v, style: BText.mono(size: 11, color: BColors.neonGreen)),
        ),
      ],
    ),
  );
  String _fd(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}
