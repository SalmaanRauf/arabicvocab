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
    final scheme = theme.colorScheme;

    // Use Lateef for IndoPak script, otherwise default Arabic font
    final textStyle = isIndopak
        ? TextStyle(
            fontFamily: 'Lateef',
            fontSize: 28, // Slightly larger for IndoPak readability
            height: 1.6, // Slightly tighter for Lateef
            color: scheme.onSurface,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
            decoration:
                isHighlighted ? TextDecoration.underline : TextDecoration.none,
            decorationColor: scheme.primary,
          )
        : theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
            decoration:
                isHighlighted ? TextDecoration.underline : TextDecoration.none,
            decorationColor: scheme.primary,
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isHighlighted ? scheme.primary.withOpacity(0.12) : Colors.transparent,
          border: Border.all(
            color: isHighlighted ? scheme.primary.withOpacity(0.55) : Colors.transparent,
            width: 1,
          ),
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
