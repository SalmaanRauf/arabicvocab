import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/audio_providers.dart';
import '../state/settings_providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offsetMs = ref.watch(audioOffsetMsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
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
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: Text(isDarkMode ? 'Warm Noir' : 'Parchment'),
                value: isDarkMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state =
                      value ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Script',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ScriptType>(
              value: ref.watch(scriptPreferenceProvider),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Quran script',
              ),
              items: const [
                DropdownMenuItem(
                  value: ScriptType.uthmani,
                  child: Text('Uthmani'),
                ),
                DropdownMenuItem(
                  value: ScriptType.indopak,
                  child: Text('IndoPak'),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                ref.read(scriptPreferenceProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 20),
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
