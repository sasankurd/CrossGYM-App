import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../messages/chat_screen.dart';

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
    final theme = Theme.of(context);
    final following = state.isFollowing(userId);
    final plans = state.allPlans.where((p) => p.sellerId == userId).toList();
    return Scaffold(
      appBar: AppBar(title: Text('@${user.handle}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 36, child: Text(user.name[0])),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: theme.textTheme.titleLarge),
                    Text(user.city),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(user.bio),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('${user.followers}',
                        style: theme.textTheme.titleLarge),
                    const Text('Followers'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('${user.workouts}', style: theme.textTheme.titleLarge),
                    const Text('Workouts'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
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
                  icon: const Icon(Icons.chat_bubble_outline),
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
          if (plans.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Plans for sale', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final p in plans)
              Card(
                child: ListTile(
                  leading: Icon(p.type.icon),
                  title: Text(p.title),
                  subtitle: Text('${p.weeks} weeks'),
                  trailing: Text(p.priceLabel),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
