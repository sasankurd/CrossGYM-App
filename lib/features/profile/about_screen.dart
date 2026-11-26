import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About and credits')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('CrossGYM', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text('Exercise illustrations', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'The exercise drawings come from the GymMane project by InlitX '
            '(github.com/InlitX/GymMane), which uses art from Workout Guide by '
            'Bryl Lim and from Everkinetic. The art is licensed under CC '
            'BY-SA 4.0 (creativecommons.org/licenses/by-sa/4.0). The paths '
            'were converted to plain text by GymMane; the geometry is '
            'unchanged.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Two drawings, reverse-pec-deck and bayesian-cable-curl, start '
            'from Open Exercise Art by Alex Mollard (CC BY-SA 4.0). See '
            'CREDITS.md for details.',
          ),
          const SizedBox(height: 16),
          Text('Body diagram', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'The muscle outlines on the recovery map come from MuscleMap by '
            'Melih Colpan (github.com/melihcolpan/MuscleMap), used under the '
            'MIT License, through the openGym project. The outlines are '
            'unchanged.',
          ),
        ],
      ),
    );
  }
}
