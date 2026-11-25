import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../watch/watch_screen.dart';

/// Devices and services the app can connect to.
class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watch = AppScope.of(context).watch;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Connections')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              ListenableBuilder(
                listenable: watch,
                builder: (context, _) => NeoCard(
                  accent: watch.isConnected,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const WatchScreen()),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.watch_rounded,
                          color: watch.isConnected
                              ? Theme.of(context).colorScheme.primary
                              : AppColors.gray300),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Heart-rate watch or strap',
                                style: text.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              watch.isConnected
                                  ? 'Connected to ${watch.deviceName ?? 'a device'}'
                                  : watch.isSupported
                                      ? 'Not connected. Tap to connect over Bluetooth.'
                                      : 'Not available in this browser.',
                              style: text.bodySmall
                                  ?.copyWith(color: AppColors.gray300),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.gray400),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SectionLabel('Not available yet'),
              const SizedBox(height: 8),
              for (final name in const [
                'Garmin Connect',
                'Apple Health',
                'Fitbit',
                'Google Health Connect',
                'Strava',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NeoCard(
                    child: Row(
                      children: [
                        const Icon(Icons.link_off,
                            color: AppColors.gray400, size: 20),
                        const SizedBox(width: 14),
                        Expanded(child: Text(name, style: text.bodyLarge)),
                        const Pill('Soon'),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'These services need their own developer approval and a '
                'server to keep sign-in tokens safe, so they are not built '
                'yet. See docs/WATCH.md.',
                style: text.bodySmall?.copyWith(color: AppColors.gray400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
