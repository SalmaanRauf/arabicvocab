# Glossary

| Term | Meaning | Evidence |
| --- | --- | --- |
| Ayah | A verse within a surah | `quran_vocab/lib/data/models/ayah.dart` |
| Surah | A chapter of the Quran | `quran_vocab/lib/data/models/surah.dart` |
| Uthmani script | Standard Quran script variant | `quran_vocab/lib/data/models/ayah.dart` |
| IndoPak script | South Asian script variant | `quran_vocab/lib/data/models/ayah.dart` |
| Word-by-word | Words split per ayah with translations | `quran_vocab/lib/data/data_loader.dart` |
| Root | Three-letter root for Arabic morphology | `quran_vocab/lib/data/models/root.dart` |
| Lemma | Canonical root form used for frequency | `quran_vocab/lib/data/db/quran_database.dart` |
| FSRS | Free Spaced Repetition Scheduler | `quran_vocab/lib/services/srs/fsrs.dart` |
| SRS | Spaced repetition system | `quran_vocab/lib/presentation/views/review_view.dart` |
| Alignment data | Timing data for word highlights | `quran_vocab/lib/data/audio_alignment_loader.dart` |
| EveryAyah CDN | Audio source for recitation | `quran_vocab/lib/services/audio/audio_manager.dart` |
