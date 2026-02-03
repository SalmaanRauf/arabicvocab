import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/word.dart';
import '../state/settings_providers.dart';

class WordChip extends ConsumerWidget {
  const WordChip({
    super.key,
    required this.word,
    this.onTap,
    this.isHighlighted = false,
  });

  final Word word;
  final VoidCallback? onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final script = ref.watch(scriptPreferenceProvider);
    final isIndopak = script == ScriptType.indopak;
    final text = isIndopak ? word.textIndopak : word.textUthmani;

    // Use Lateef for IndoPak script, otherwise default Arabic font
    final textStyle = isIndopak
        ? TextStyle(
            fontFamily: 'Lateef',
            fontSize: 28, // Slightly larger for IndoPak readability
            height: 1.6,  // Slightly tighter for Lateef
            color: isHighlighted ? theme.colorScheme.primary : theme.primaryColor,
          )
        : theme.textTheme.titleLarge?.copyWith(
            color: isHighlighted ? theme.colorScheme.primary : theme.primaryColor,
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
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
          style: textStyle,
        ),
      ),
    );
  }
}
