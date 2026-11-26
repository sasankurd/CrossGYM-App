import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../data/rank.dart';
import '../social/user_profile_screen.dart';

/// A small rank badge, for example next to a name.
class RankPill extends StatelessWidget {
  const RankPill(this.tier, {super.key});

  final RankTier tier;

  @override
  Widget build(BuildContext context) =>
      Pill(tier.label, color: tier.color, icon: tier.icon);
}

/// Your rank, points and progress to the next rank. Tap for all medals.
class RankCard extends StatelessWidget {
  const RankCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final points = state.achievementPoints;
    final tier = state.rank;
    final next = tier.next;
    final medals = state.achievements;
    final unlocked = medals.where((a) => a.unlocked).length;
    return NeoCard(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AchievementsScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tier.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: tier.color.withValues(alpha: 0.6)),
                ),
                child: Icon(tier.icon, color: tier.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${tier.label} rank',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                    Text('$points points  -  $unlocked of ${medals.length} medals',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.gray300)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gray400),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: tier.progress(points),
              minHeight: 8,
              color: tier.color,
              backgroundColor: AppColors.hairline,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            next == null
                ? 'Top rank reached.'
                : '${next.minPoints - points} more points to ${next.label}',
            style: const TextStyle(fontSize: 12, color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}

/// Every medal with its progress, points and tier.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final medals = [...state.achievements]
      ..sort((a, b) {
        if (a.unlocked != b.unlocked) return a.unlocked ? 1 : -1;
        return b.fraction.compareTo(a.fraction);
      });
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const RankCard(),
                const SizedBox(height: 8),
                const Text(
                  'Each medal gives points: Bronze 10, Silver 25, Gold 50, '
                  'Diamond 100. Points set your rank.',
                  style: TextStyle(fontSize: 12, color: AppColors.gray400),
                ),
                const SizedBox(height: 14),
                for (final a in medals) ...[
                  _MedalRow(a),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _tierColor(MedalTier t) => switch (t) {
      MedalTier.bronze => const Color(0xFFCD7F32),
      MedalTier.silver => const Color(0xFFC0C8D4),
      MedalTier.gold => AppColors.amber,
      MedalTier.diamond => AppColors.cyan,
    };

class _MedalRow extends StatelessWidget {
  const _MedalRow(this.a);

  final Achievement a;

  @override
  Widget build(BuildContext context) {
    final c = a.unlocked ? _tierColor(a.tier) : AppColors.gray400;
    return NeoCard(
      padding: const EdgeInsets.all(12),
      radius: 16,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(a.unlocked ? a.icon : Icons.lock_outline,
                color: c, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text(a.description,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.gray300)),
                const SizedBox(height: 6),
                if (!a.unlocked)
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: a.fraction,
                            minHeight: 6,
                            color: c,
                            backgroundColor: AppColors.hairline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${a.progress}/${a.goal}',
                          style: mono(size: 11, color: AppColors.gray300)),
                    ],
                  )
                else
                  const Text('Unlocked',
                      style: TextStyle(fontSize: 12, color: AppColors.volt)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text('+${a.points}', style: mono(size: 14, color: c)),
              Text(a.tier.label,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.gray400)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Everyone ranked by achievement points.
class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final board = state.leaderboard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RankCard(),
        const SizedBox(height: 14),
        const SectionLabel('Ranking'),
        const SizedBox(height: 8),
        for (var i = 0; i < board.length; i++) ...[
          NeoCard(
            radius: 16,
            padding: const EdgeInsets.all(12),
            selected: board[i].id == AppState.meId,
            onTap: board[i].id == AppState.meId
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => UserProfileScreen(userId: board[i].id))),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text('${i + 1}',
                      style: mono(
                          size: 16,
                          weight: FontWeight.w800,
                          color: i == 0 ? AppColors.amber : AppColors.gray300)),
                ),
                UserAvatar(
                    name: board[i].name, photo: board[i].photo, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(board[i].id == AppState.meId ? 'You' : board[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      RankPill(state.rankOf(board[i].id)),
                    ],
                  ),
                ),
                Text('${state.pointsOf(board[i].id)} pts',
                    style: mono(size: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        const Text(
          'The other people here are demo accounts with fixed points. There '
          'is no server yet, so real users cannot appear in this list.',
          style: TextStyle(fontSize: 11, color: AppColors.gray400, height: 1.4),
        ),
      ],
    );
  }
}
