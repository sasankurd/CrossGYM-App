import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/watch/watch_link.dart';
import 'heart_widgets.dart';

/// Connect a heart-rate watch or strap over Bluetooth and see live readings.
class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watch = AppScope.of(context).watch;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Watch')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListenableBuilder(
            listenable: watch,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text('Heart rate from your watch', style: text.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  'CrossGYM reads your heart rate live over Bluetooth, the '
                  'same standard chest straps use. Readings are shown while '
                  'you train and are not saved or sent anywhere.',
                  style: text.bodyMedium?.copyWith(color: AppColors.gray300),
                ),
                const SizedBox(height: 16),
                if (!watch.isSupported)
                  _Unsupported()
                else ...[
                  if (watch.isConnected) ...[
                    const LiveHeartCard(openable: false),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: watch.disconnect,
                      icon: const Icon(Icons.link_off, size: 18),
                      label: const Text('Disconnect'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Zones use an estimated maximum heart rate of '
                      '${estimatedMaxHr(AppScope.of(context))} (220 minus '
                      'your age). Your real maximum may differ.',
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.gray400),
                    ),
                  ] else ...[
                    FilledButton.icon(
                      onPressed: watch.status == WatchStatus.connecting
                          ? null
                          : watch.connect,
                      icon: watch.status == WatchStatus.connecting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bluetooth, size: 18),
                      label: Text(watch.status == WatchStatus.connecting
                          ? 'Connecting...'
                          : 'Connect a heart-rate device'),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52)),
                    ),
                    if (watch.error != null) ...[
                      const SizedBox(height: 12),
                      Semantics(
                        liveRegion: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 18, color: AppColors.rose),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                watch.error!,
                                style: text.bodySmall
                                    ?.copyWith(color: AppColors.rose),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const _HowTo(),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Unsupported extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return NeoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bluetooth_disabled, color: AppColors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This browser cannot connect to Bluetooth devices. Open '
              'CrossGYM in Chrome or Edge on Android, Windows, Mac or Linux. '
              'Safari and Firefox, and any browser on iPhone, do not support '
              'it.',
              style: text.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowTo extends StatelessWidget {
  const _HowTo();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget step(int n, String title, String body) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.container,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$n', style: mono(size: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(body,
                        style: text.bodySmall
                            ?.copyWith(color: AppColors.gray300)),
                  ],
                ),
              ),
            ],
          ),
        );

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          step(1, 'Turn on Bluetooth',
              'Switch it on for the device that is running CrossGYM.'),
          step(
            2,
            'Make the watch share your heart rate',
            'On a Garmin, turn on Broadcast Heart Rate in the watch settings '
                '(the exact name varies by model). Chest and arm straps from '
                'Polar, Wahoo, Coospo and others share it as soon as you wear '
                'them.',
          ),
          step(3, 'Connect',
              'Tap the button above and pick your device from the list.'),
          const Divider(height: 24),
          Text(
            'Apple Watch, Fitbit and Samsung watches do not share live heart '
            'rate with other devices by default, so they will not appear in '
            'the list. Syncing their saved workouts needs each maker\'s '
            'service and is not built yet.',
            style: text.bodySmall?.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}
