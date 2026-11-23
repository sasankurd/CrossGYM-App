import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../social/post_card.dart';
import '../social/post_composer.dart';
import 'about_screen.dart';
import 'profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final achievements = state.achievements;
    final unlocked = achievements.where((a) => a.unlocked).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        ProfileHeaderCard(
          name: state.me.name,
          handle: state.me.handle,
          bio: state.me.bio,
          subtitle: 'Level ${state.level}',
          metrics: [
            Metric('Followers', '${state.me.followers}'),
            Metric('Following', '${state.followingCount}'),
            Metric('Sessions', '${state.totalWorkouts}'),
          ],
        ),
        const SizedBox(height: 16),
        SubTabs(
          labels: ['Posts', 'Medals $unlocked/${achievements.length}', 'Plans'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 16),
        if (_tab == 0) ..._posts(state),
        if (_tab == 1) _medals(achievements),
        if (_tab == 2) ..._plans(context, state),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('About and credits'),
          ),
        ),
      ],
    );
  }

  List<Widget> _posts(AppState state) {
    final mine = state.postsBy(AppState.meId);
    return [
      const PostComposer(),
      const SizedBox(height: 12),
      for (final p in mine) ...[
        PostCard(post: p),
        const SizedBox(height: 12),
      ],
    ];
  }

  Widget _medals(List<Achievement> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 196,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, i) => _MedalCard(achievement: achievements[i]),
    );
  }

  List<Widget> _plans(BuildContext context, AppState state) {
    final text = Theme.of(context).textTheme;
    final mine = state.myPlans;
    final bought = state.purchasedPlans;
    if (mine.isEmpty && bought.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'You have no plans yet. Open the Store tab to sell or get one.',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: AppColors.gray400),
          ),
        ),
      ];
    }
    Widget tile(Plan p, String tag) {
      final color = typeColor(context, p.type);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: NeoCard(
          radius: 20,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(p.type.icon, color: color),
              const SizedBox(width: 12),
              Expanded(child: Text(p.title, style: text.titleMedium)),
              Pill(tag, color: color),
              const SizedBox(width: 8),
              Text(p.priceLabel, style: mono(size: 12)),
            ],
          ),
        ),
      );
    }

    return [
      for (final p in mine) tile(p, 'SELLING'),
      for (final p in bought) tile(p, 'OWNED'),
    ];
  }
}

/// Metallic trophy card for one achievement.
class _MedalCard extends StatelessWidget {
  const _MedalCard({required this.achievement});

  final Achievement achievement;

  static List<Color> _metal(MedalTier tier) => switch (tier) {
        MedalTier.bronze => const [Color(0xFFE0A267), Color(0xFF8C5A2B)],
        MedalTier.silver => const [Color(0xFFF3F4F6), Color(0xFF9CA3AF)],
        MedalTier.gold => const [Color(0xFFFDE68A), Color(0xFFF59E0B)],
        MedalTier.diamond => const [Color(0xFFA5F3FC), Color(0xFFC4B5FD)],
      };

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    final metal = _metal(a.tier);
    final text = Theme.of(context).textTheme;
    return Opacity(
      opacity: a.unlocked ? 1 : 0.55,
      child: NeoCard(
        radius: 20,
        selected: false,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: metal,
                    ),
                    boxShadow: a.unlocked
                        ? [
                            BoxShadow(
                              color: metal.last.withValues(alpha: 0.45),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(a.icon, color: AppColors.canvas, size: 22),
                ),
                const Spacer(),
                Pill(a.tier.label.toUpperCase(), color: metal.last),
              ],
            ),
            const SizedBox(height: 10),
            Text(a.title, style: text.titleMedium),
            const SizedBox(height: 2),
            Text(
              a.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(color: AppColors.gray400),
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: a.fraction,
              color: metal.last,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 6),
            Text(
              a.unlocked
                  ? 'UNLOCKED'
                  : '${a.progress}/${a.goal}',
              style: mono(
                size: 10,
                color: a.unlocked ? AppColors.emerald : AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
