import 'package:flutter/material.dart';

import '../../data/models/word.dart';

class WordChip extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          word.textUthmani,
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
