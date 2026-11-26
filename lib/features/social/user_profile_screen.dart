import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../messages/chat_screen.dart';
import '../profile/profile_header.dart';
import 'post_card.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.userById(userId);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('User not found')),
      );
    }
    final text = Theme.of(context).textTheme;
    final following = state.isFollowing(userId);
    final plans = state.allPlans.where((p) => p.sellerId == userId).toList();
    final posts = state.postsBy(userId);

    return Scaffold(
      appBar: AppBar(title: Text('@${user.handle}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileHeaderCard(
            name: user.name,
            handle: user.handle,
            bio: user.bio,
            subtitle: user.city,
            photo: user.photo,
            rank: state.rankOf(userId),
            metrics: [
              Metric('Followers', '${user.followers}'),
              Metric('Sessions', '${user.workouts}'),
            ],
            actions: Row(
              children: [
                Expanded(
                  child: following
                      ? OutlinedButton(
                          onPressed: () => state.toggleFollow(userId),
                          child: const Text('Following'),
                        )
                      : FilledButton(
                          onPressed: () => state.toggleFollow(userId),
                          child: const Text('Follow'),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Message'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChatScreen(userId: userId),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (plans.isNotEmpty) ...[
            const SizedBox(height: 20),
            const SectionLabel('Plans for sale'),
            const SizedBox(height: 8),
            for (final p in plans)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NeoCard(
                  radius: 20,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(p.type.icon, color: typeColor(context, p.type)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title, style: text.titleMedium),
                            Text(
                              '${p.weeks} weeks',
                              style: mono(
                                size: 11,
                                weight: FontWeight.w500,
                                color: AppColors.gray400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(p.priceLabel, style: mono(size: 13)),
                    ],
                  ),
                ),
              ),
          ],
          if (posts.isNotEmpty) ...[
            const SizedBox(height: 12),
            const SectionLabel('Posts'),
            const SizedBox(height: 8),
            for (final p in posts) ...[
              PostCard(post: p),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}
