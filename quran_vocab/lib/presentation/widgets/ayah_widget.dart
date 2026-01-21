import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/ayah.dart';
import '../../data/models/word.dart';
import '../state/quran_providers.dart';
import 'word_chip.dart';
import 'word_detail_popup.dart';

class AyahWidget extends ConsumerWidget {
  const AyahWidget({
    super.key,
    required this.ayah,
    required this.highlightWordId,
  });

  final Ayah ayah;
  final int? highlightWordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsForAyahProvider(ayah.id));
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${ayah.surahId}:${ayah.ayahNumber}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          wordsAsync.when(
            data: (words) => _AyahWords(
              words: words,
              highlightWordId: highlightWordId,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Failed to load words: $error'),
          ),
          if (ayah.translationEn.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              ayah.translationEn,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _AyahWords extends StatelessWidget {
  const _AyahWords({required this.words, required this.highlightWordId});

  final List<Word> words;
  final int? highlightWordId;

  void _showWordDetail(BuildContext context, Word word) {
    showDialog(
      context: context,
      builder: (_) => WordDetailPopup(word: word),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Text('No word-by-word data found for this ayah.');
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final word in words)
            WordChip(
              word: word,
              isHighlighted: highlightWordId == word.id,
              onTap: () => _showWordDetail(context, word),
            ),
        ],
      ),
    );
  }
}
