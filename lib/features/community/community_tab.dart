import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../profile/connections_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/settings_screen.dart';
import '../social/social_screen.dart';

/// The Community tab: feed, discover and messages. The three-dot menu holds
/// Profile, Settings and Connections.
class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  void _open(BuildContext context, String item) {
    final Widget page = switch (item) {
      'profile' => Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: const Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720),
              child: ProfileScreen(),
            ),
          ),
        ),
      'settings' => const SettingsScreen(),
      _ => const ConnectionsScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TabHeader(
            kicker: 'FEED, PEOPLE AND MESSAGES',
            title: 'Community',
            trailing: [
              PopupMenuButton<String>(
                tooltip: 'More',
                icon: const Icon(Icons.more_vert, color: AppColors.text),
                onSelected: (v) => _open(context, v),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'profile',
                    child: _MenuRow(Icons.person_outline, 'Profile'),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: _MenuRow(Icons.settings_outlined, 'Settings'),
                  ),
                  PopupMenuItem(
                    value: 'connections',
                    child: _MenuRow(Icons.watch_outlined, 'Connections'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Expanded(child: SocialScreen()),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gray300),
          const SizedBox(width: 12),
          Text(label),
        ],
      );
}
