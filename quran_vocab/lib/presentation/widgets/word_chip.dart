import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/word.dart';
import '../state/settings_providers.dart';

class WordChip extends ConsumerWidget {
  const WordChip({
    super.key,
    required this.word,
    required this.onTap,
    this.isHighlighted = false,
  });

  final Word word;
  final VoidCallback onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final script = ref.watch(scriptPreferenceProvider);
    final text =
        script == ScriptType.indopak ? word.textIndopak : word.textUthmani;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isHighlighted
              ? theme.colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          style: theme.textTheme.titleLarge?.copyWith(
            color:
                isHighlighted ? theme.colorScheme.primary : theme.primaryColor,
          ),
        ),
      ),
    );
  }
}
