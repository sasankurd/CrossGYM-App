import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../onboarding/onboarding_screen.dart';
import 'about_screen.dart';

/// Account, color theme, body details and sign out.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final account = state.account;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const SectionLabel('Account'),
              const SizedBox(height: 8),
              NeoCard(
                child: Row(
                  children: [
                    GradientAvatar(
                      initial: state.me.name.isEmpty ? '?' : state.me.name[0],
                      size: 48,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.me.name, style: text.titleMedium),
                          Text(
                            account == null
                                ? ''
                                : account.email.isNotEmpty
                                    ? account.email
                                    : 'Signed in with ${account.providerLabel}',
                            style: text.bodySmall
                                ?.copyWith(color: AppColors.gray300),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isGuest) ...[
                const SizedBox(height: 8),
                Text(
                  'You are using a guest account. Sign out and create an '
                  'account to keep it under your own name.',
                  style: text.bodySmall?.copyWith(color: AppColors.gray400),
                ),
              ],
              const SizedBox(height: 20),
              const SectionLabel('Color theme'),
              const SizedBox(height: 8),
              NeoCard(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < kAnimeThemes.length; i++)
                      ChoiceChip(
                        avatar: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [
                              kAnimeThemes[i].primary,
                              kAnimeThemes[i].secondary,
                            ]),
                          ),
                        ),
                        label: Text(kAnimeThemes[i].name),
                        selected: state.themeIndex == i,
                        onSelected: (_) => state.setTheme(i),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SectionLabel('Your plan'),
              const SizedBox(height: 8),
              if (state.profile != null)
                _Tile(
                  icon: Icons.tune,
                  title: 'Body details and goal',
                  subtitle: 'Change age, weight, training week or goal and '
                      'recalculate your calories.',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const OnboardingScreen(edit: true)),
                  ),
                ),
              const SizedBox(height: 8),
              _Tile(
                icon: Icons.info_outline,
                title: 'About and credits',
                subtitle: 'Exercise art licenses and how the app works.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  // Close this page first, or it would stay on top of the
                  // sign-in screen.
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  state.signOut();
                },
                icon: const Icon(Icons.logout, size: 18),
                label: Text(state.isGuest ? 'Leave guest mode' : 'Sign out'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return NeoCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        text.bodySmall?.copyWith(color: AppColors.gray300)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gray400),
        ],
      ),
    );
  }
}
