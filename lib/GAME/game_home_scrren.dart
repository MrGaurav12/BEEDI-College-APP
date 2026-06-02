// =============================================================================
// GAME HOME SCREEN - Separated from beedi_game_screen.dart
// =============================================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'beedi_game_screen.dart';

// =============================================================================
// GAME HOME SCREEN
// =============================================================================

class GameHomeScreen extends StatefulWidget {
  const GameHomeScreen({super.key});
  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen> {
  int _tab = 0;

  final _tabs = [
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.sports_esports_outlined, label: 'Games'),
    (icon: Icons.store_outlined, label: 'Market'),
    (icon: Icons.account_balance_wallet_outlined, label: 'Wallet'),
    (icon: Icons.leaderboard, label: 'Leaderboard'), // Changed icon and label
    (icon: Icons.person_outline, label: 'Profile'), // Moved Profile to end
  ];

  @override
  void dispose() {
    BFirestore.setOnline(BSession.currentPlayer?.playerId ?? '', false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodies = [
      const HomeTab(),
      const GamesTab(),
      const MarketplaceTab(),
      const WalletTab(),
      const LeaderboardTab(), // Leaderboard before Profile
      const ProfileTab(), // Profile at the end
    ];

    return Scaffold(
      backgroundColor: BColors.bg1,
      body: StreamBuilder<DocumentSnapshot>(
        stream: BSession.playerStream(),
        builder: (_, snap) {
          if (snap.hasData && snap.data!.exists) {
            BSession.currentPlayer = PlayerModel.fromMap(
              snap.data!.data() as Map<String, dynamic>,
            );
          }
          return bodies[_tab];
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: BColors.bg2,
          border: Border(
            top: BorderSide(color: BColors.neonBlue.withOpacity(0.2)),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final active = i == _tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: active ? BColors.neonBlue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          color: active
                              ? BColors.neonBlue
                              : BColors.txtSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: BText.rajdhani(
                            size: 10,
                            color: active
                                ? BColors.neonBlue
                                : BColors.txtSecondary,
                            weight: active ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HOME TAB
// =============================================================================

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final p = BSession.currentPlayer!;
    return ParticleBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(p, context)),
            SliverToBoxAdapter(child: _buildDailyRewardCard(context, p)),
            SliverToBoxAdapter(child: _buildEventsSection()),
            SliverToBoxAdapter(child: _buildActivityFeed()),
            SliverToBoxAdapter(child: _buildMiniLeaderboard()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PlayerModel p, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: GlassCard(
        child: Column(
          children: [
            Row(
              children: [
                PlayerAvatar(player: p, size: 56, showOnline: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            p.nickname,
                            style: BText.orbitron(
                              size: 16,
                              color: BColors.txtPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: p.rankColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: p.rankColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              p.rankName,
                              style: BText.orbitron(
                                size: 9,
                                color: p.rankColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      XPBar(player: p),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text('💰', style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${p.coins}',
                          style: BText.orbitron(
                            size: 14,
                            color: BColors.neonGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🔥 ${p.streak}',
                      style: BText.rajdhani(
                        size: 13,
                        color: BColors.neonOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatChip(
                    label: 'Wins',
                    value: '${p.totalWins}',
                    color: BColors.neonGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatChip(
                    label: 'Level',
                    value: '${p.level}',
                    color: BColors.neonBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatChip(
                    label: 'Streak',
                    value: '${p.streak}',
                    color: BColors.neonOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatChip(
                    label: 'XP',
                    value: '${p.xp}',
                    color: BColors.neonPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRewardCard(BuildContext context, PlayerModel p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: GlassCard(
        borderColor: BColors.neonGold,
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY REWARD',
                    style: BText.orbitron(size: 13, color: BColors.neonGold),
                  ),
                  Text(
                    'Claim your daily coins & XP!',
                    style: BText.rajdhani(
                      size: 12,
                      color: BColors.txtSecondary,
                    ),
                  ),
                ],
              ),
            ),
            NeonButton(
              label: 'CLAIM',
              color: BColors.neonGold,
              width: 100,
              height: 40,
              onTap: () async {
                final reward = await BFirestore.claimDailyReward(p);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        reward != null
                            ? '🎁 Claimed! +${reward['coins']} coins, +${reward['xp']} XP!'
                            : '✅ Already claimed today. Come back tomorrow!',
                      ),
                      backgroundColor: reward != null
                          ? BColors.neonGold
                          : BColors.bg3,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: BFirestore.eventsStream(),
      builder: (_, snap) {
        final events = snap.data?.docs ?? [];
        if (events.isEmpty) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '⚡ ACTIVE EVENTS',
                  style: BText.orbitron(size: 12, color: BColors.neonPurple),
                ),
              ),
              ...events.map((e) {
                final data = e.data() as Map;
                return GlassCard(
                  borderColor: BColors.neonPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? '',
                              style: BText.orbitron(
                                size: 12,
                                color: BColors.neonPurple,
                              ),
                            ),
                            Text(
                              'XP ×${data['xpMultiplier'] ?? 1}  |  Coins ×${data['coinMultiplier'] ?? 1}',
                              style: BText.mono(
                                size: 10,
                                color: BColors.neonGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: BFirestore.activityFeedStream(),
      builder: (_, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📡 LIVE ACTIVITY',
                  style: BText.orbitron(size: 12, color: BColors.neonBlue),
                ),
                const SizedBox(height: 12),
                ...docs.take(8).map((doc) {
                  final d = doc.data() as Map;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        _actionIcon(d['action'] ?? ''),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${d['nickname'] ?? '?'} — ${d['detail'] ?? ''}',
                            style: BText.rajdhani(
                              size: 12,
                              color: BColors.txtSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if ((d['coins'] ?? 0) != 0)
                          Text(
                            '${(d['coins'] as int) > 0 ? '+' : ''}${d['coins']}💰',
                            style: BText.mono(
                              size: 10,
                              color: (d['coins'] as int) > 0
                                  ? BColors.neonGreen
                                  : BColors.neonRed,
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
      },
    );
  }

  Widget _actionIcon(String action) {
    switch (action) {
      case 'win':
        return const Text('🏆', style: TextStyle(fontSize: 14));
      case 'purchase':
        return const Text('🛒', style: TextStyle(fontSize: 14));
      case 'level_up':
        return const Text('⬆️', style: TextStyle(fontSize: 14));
      case 'daily_reward':
        return const Text('🎁', style: TextStyle(fontSize: 14));
      case 'transfer':
        return const Text('💸', style: TextStyle(fontSize: 14));
      case 'account_created':
        return const Text('🆕', style: TextStyle(fontSize: 14));
      default:
        return const Text(
          '•',
          style: TextStyle(fontSize: 14, color: BColors.txtSecondary),
        );
    }
  }

  Widget _buildMiniLeaderboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: BFirestore.leaderboardStream(),
      builder: (_, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox();

        // Find current player's rank
        int currentRank = -1;
        for (int i = 0; i < docs.length; i++) {
          final d = docs[i].data() as Map;
          if (d['playerId'] == BSession.currentPlayer?.playerId) {
            currentRank = i + 1;
            break;
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '🏆 TOP PLAYERS',
                      style: BText.orbitron(size: 12, color: BColors.neonGold),
                    ),
                    const Spacer(),
                    if (currentRank > 0)
                      Text(
                        'Your Rank: #$currentRank',
                        style: BText.mono(size: 10, color: BColors.neonGold),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(min(5, docs.length), (i) {
                  final d = docs[i].data() as Map;
                  final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
                  final isCurrent =
                      d['playerId'] == BSession.currentPlayer?.playerId;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(medals[i], style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Text(
                          d['avatar'] ?? '⚡',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            d['nickname'] ?? '',
                            style: BText.rajdhani(
                              size: 13,
                              color: isCurrent
                                  ? BColors.neonGold
                                  : BColors.txtPrimary,
                              weight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        Text(
                          '${d['xp'] ?? 0} XP',
                          style: BText.mono(
                            size: 11,
                            color: isCurrent
                                ? BColors.neonGold
                                : BColors.neonPurple,
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
      },
    );
  }
}

// Add this as a new tab in GameHomeScreen's _buildBody method
class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  '🏆 GLOBAL LEADERBOARD',
                  style: BText.orbitron(size: 20, color: BColors.neonGold),
                ),
                const Spacer(),
                Text(
                  'Top 50 Players',
                  style: BText.rajdhani(size: 13, color: BColors.txtSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: BFirestore.leaderboardStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: BColors.neonGold),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No players yet',
                      style: BText.rajdhani(
                        size: 16,
                        color: BColors.txtSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final rank = index + 1;
                    final isCurrentPlayer =
                        data['playerId'] == BSession.currentPlayer?.playerId;

                    Color rankColor;
                    if (rank == 1)
                      rankColor = BColors.neonGold;
                    else if (rank == 2)
                      rankColor = BColors.neonBlue;
                    else if (rank == 3)
                      rankColor = BColors.neonGreen;
                    else
                      rankColor = BColors.txtSecondary;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        borderColor: isCurrentPlayer
                            ? BColors.neonGold
                            : rankColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: rankColor.withOpacity(0.2),
                                border: Border.all(
                                  color: rankColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  rank == 1
                                      ? '👑'
                                      : rank == 2
                                      ? '🥈'
                                      : rank == 3
                                      ? '🥉'
                                      : '$rank',
                                  style: TextStyle(
                                    fontSize: rank <= 3 ? 20 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: rankColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        data['nickname'] ?? 'Unknown',
                                        style: BText.orbitron(
                                          size: 14,
                                          color: isCurrentPlayer
                                              ? BColors.neonGold
                                              : BColors.txtPrimary,
                                        ),
                                      ),
                                      if (isCurrentPlayer) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BColors.neonGold.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'YOU',
                                            style: BText.orbitron(
                                              size: 8,
                                              color: BColors.neonGold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Lv.${data['level'] ?? 1}',
                                        style: BText.mono(
                                          size: 10,
                                          color: BColors.txtSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '🏆 ${data['wins'] ?? 0} wins',
                                        style: BText.mono(
                                          size: 10,
                                          color: BColors.txtSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '💰 ${data['coins'] ?? 0}',
                                  style: BText.orbitron(
                                    size: 12,
                                    color: BColors.neonGold,
                                  ),
                                ),
                                Text(
                                  '⚡ ${data['xp'] ?? 0} XP',
                                  style: BText.mono(
                                    size: 10,
                                    color: BColors.neonPurple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
}
