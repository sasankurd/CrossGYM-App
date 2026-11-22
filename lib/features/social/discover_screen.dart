import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import 'user_profile_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final users = state.otherUsers;
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _UserTile(user: users[i]),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final following = state.isFollowing(user.id);
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(user.name[0])),
        title: Text(user.name),
        subtitle: Text('@${user.handle} - ${user.followers} followers'),
        trailing: following
            ? OutlinedButton(
                onPressed: () => state.toggleFollow(user.id),
                child: const Text('Following'),
              )
            : FilledButton(
                onPressed: () => state.toggleFollow(user.id),
                child: const Text('Follow'),
              ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => UserProfileScreen(userId: user.id),
          ),
        ),
      ),
    );
  }
}
