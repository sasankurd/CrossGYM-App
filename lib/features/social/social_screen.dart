import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../messages/chat_screen.dart';
import 'post_card.dart';
import 'user_profile_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(16, contentTop(context), 16, 24),
      children: [
        SubTabs(
          labels: const ['Feed', 'Discover', 'Messages'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 16),
        if (_tab == 0) ..._feed(state),
        if (_tab == 1) ..._discover(context, state),
        if (_tab == 2) ..._messages(context, state),
      ],
    );
  }

  List<Widget> _feed(AppState state) {
    final posts = state.feed;
    return [
      for (final p in posts) ...[
        PostCard(post: p),
        const SizedBox(height: 12),
      ],
    ];
  }

  List<Widget> _discover(BuildContext context, AppState state) {
    return [
      for (final u in state.otherUsers) ...[
        _UserTile(user: u),
        const SizedBox(height: 10),
      ],
    ];
  }

  List<Widget> _messages(BuildContext context, AppState state) {
    final ids = state.conversationIds;
    if (ids.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No conversations yet. Open someone in Discover and tap Message.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.gray400),
          ),
        ),
      ];
    }
    return [
      for (final id in ids) ...[
        _ConversationTile(userId: id),
        const SizedBox(height: 10),
      ],
    ];
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final following = state.isFollowing(user.id);
    const compact = Size(0, 36);
    return NeoCard(
      radius: 20,
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => UserProfileScreen(userId: user.id),
        ),
      ),
      child: Row(
        children: [
          GradientAvatar(initial: user.name[0], size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '@${user.handle}',
                  style: mono(
                    size: 11,
                    weight: FontWeight.w500,
                    color: AppColors.gray400,
                  ),
                ),
                Text(
                  '${user.followers} followers',
                  style: mono(
                    size: 11,
                    weight: FontWeight.w500,
                    color: AppColors.gray300,
                  ),
                ),
              ],
            ),
          ),
          following
              ? OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: compact),
                  onPressed: () => state.toggleFollow(user.id),
                  child: const Text('Following'),
                )
              : FilledButton(
                  style: FilledButton.styleFrom(minimumSize: compact),
                  onPressed: () => state.toggleFollow(user.id),
                  child: const Text('Follow'),
                ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.userById(userId);
    final last = state.chatWith(userId).last;
    return NeoCard(
      radius: 20,
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ChatScreen(userId: userId)),
      ),
      child: Row(
        children: [
          GradientAvatar(initial: user?.name[0] ?? '?', size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? 'Unknown',
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  last.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.gray300),
                ),
              ],
            ),
          ),
          Text(
            ago(last.sentAt),
            style: mono(size: 11, weight: FontWeight.w500, color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}
