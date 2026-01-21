import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/audio_providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offsetMs = ref.watch(audioOffsetMsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio offset',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Current: ${offsetMs}ms'),
            Slider(
              value: offsetMs.toDouble(),
              min: -500,
              max: 500,
              divisions: 100,
              label: '${offsetMs}ms',
              onChanged: (value) {
                ref.read(audioOffsetMsProvider.notifier).state =
                    value.round();
              },
            ),
          ],
        ),
      ),
    );
  }
}
