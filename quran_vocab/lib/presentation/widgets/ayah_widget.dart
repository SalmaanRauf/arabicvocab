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
    required this.isAudioReady,
    required this.onPlayAyah,
  });

  final Ayah ayah;
  final int? highlightWordId;
  final bool isAudioReady;
  final VoidCallback? onPlayAyah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsForAyahProvider(ayah.id));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '${ayah.surahId}:${ayah.ayahNumber}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.left,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Play ayah',
                  visualDensity: VisualDensity.compact,
                  onPressed: isAudioReady ? onPlayAyah : null,
                ),
              ],
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
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
