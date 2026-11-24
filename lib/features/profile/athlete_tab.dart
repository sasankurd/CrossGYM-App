import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../data/app_state.dart';
import '../../core/widgets.dart';
import '../social/social_screen.dart';
import 'profile_screen.dart';

/// The Athlete tab: your profile, and the community (feed, discover, messages).
class AthleteTab extends StatefulWidget {
  const AthleteTab({super.key});

  @override
  State<AthleteTab> createState() => _AthleteTabState();
}

class _AthleteTabState extends State<AthleteTab> {
  int _view = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: SubTabs(
                  labels: const ['Profile', 'Community'],
                  index: _view,
                  onChanged: (i) => setState(() => _view = i),
                ),
              ),
              const SizedBox(width: 4),
              const _ThemeMenu(),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _view,
            children: const [ProfileScreen(), SocialScreen()],
          ),
        ),
      ],
    );
  }
}

class _ThemeMenu extends StatelessWidget {
  const _ThemeMenu();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PopupMenuButton<int>(
      tooltip: 'Color theme',
      icon: const Icon(Icons.palette_outlined, color: AppColors.gray300),
      initialValue: state.themeIndex,
      onSelected: state.setTheme,
      itemBuilder: (context) => [
        for (var i = 0; i < kAnimeThemes.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kAnimeThemes[i].primary, kAnimeThemes[i].secondary],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(kAnimeThemes[i].name),
              ],
            ),
          ),
      ],
    );
  }
}
