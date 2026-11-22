import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final ids = state.conversationIds;
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ids.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No conversations yet. Open someone in Discover and tap '
                  'Message.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              itemCount: ids.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final user = state.userById(ids[i]);
                final last = state.chatWith(ids[i]).last;
                return ListTile(
                  leading: CircleAvatar(child: Text(user?.name[0] ?? '?')),
                  title: Text(user?.name ?? 'Unknown'),
                  subtitle: Text(
                    last.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatScreen(userId: ids[i]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
