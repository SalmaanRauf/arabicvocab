import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Use Noto Nastaliq Urdu for IndoPak script, otherwise default Arabic font
    // Use PDMS Saleem QuranFont for correct IndoPak rendering
    final textStyle = isIndopak
        ? TextStyle(
            fontFamily: 'PDMS_Saleem_QuranFont',
            fontSize: 28, // Slightly larger for Saleem font
            height: 1.8,  // Adjusted line height for Saleem font
            color: isHighlighted ? theme.colorScheme.primary : theme.primaryColor,
          )
        : theme.textTheme.titleLarge?.copyWith(
            color: isHighlighted ? theme.colorScheme.primary : theme.primaryColor,
          );

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
          style: textStyle,
        ),
      ),
    );
  }
}

