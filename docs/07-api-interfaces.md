# API and Interfaces

## Public or External APIs

No first-party backend API exists in this repository. Runtime networking is limited to audio file downloads. Defined in: `quran_vocab/lib/services/audio/audio_manager.dart`.

## Runtime External Interfaces

| Interface | Purpose | Example | Evidence |
| --- | --- | --- | --- |
| EveryAyah CDN | Stream ayah audio | `https://everyayah.com/data/Alafasy_128kbps/001001.mp3` | `quran_vocab/lib/services/audio/audio_manager.dart` |

## Data and Tooling External Interfaces

| Interface | Used By | Purpose | Evidence |
| --- | --- | --- | --- |
| alquran.cloud API | ETL | Surah metadata, ayahs | `tools/etl/download_quran_data.py` |
| quran.com API | ETL, validation | Word-by-word data and IndoPak text | `tools/etl/download_quran_data.py`, `tools/etl/download_indopak.py`, `tools/etl/validate_words.py` |
| Tanzil | ETL | Uthmani and IndoPak raw text | `tools/etl/build_quran_db.py` |
| quran-align | ETL | Audio alignment raw data | `tools/etl/build_quran_db.py` |
| QUL (Tarteel AI via quran-validator) | Validation | Authoritative Uthmani text | `tools/etl/validate_quran_text.py` |

## Internal Interfaces (Riverpod Providers)

| Provider | Purpose | Evidence |
| --- | --- | --- |
| `dataLoaderProvider` | Loads JSON assets | `quran_vocab/lib/presentation/state/quran_providers.dart` |
| `surahsProvider` | Surah list | `quran_vocab/lib/presentation/state/quran_providers.dart` |
| `ayahsProvider` | Ayahs for selected surah | `quran_vocab/lib/presentation/state/quran_providers.dart` |
| `wordsForAyahProvider` | Words for an ayah | `quran_vocab/lib/presentation/state/quran_providers.dart` |
| `searchResultsProvider` | Word search | `quran_vocab/lib/presentation/state/quran_providers.dart` |
| `audioManagerProvider` | Audio playback manager | `quran_vocab/lib/presentation/state/audio_providers.dart` |
| `activeWordIdProvider` | Highlight stream | `quran_vocab/lib/presentation/state/audio_providers.dart` |
| `scriptPreferenceProvider` | Uthmani vs IndoPak | `quran_vocab/lib/presentation/state/settings_providers.dart` |
| `curriculumProvider` | Lesson units | `quran_vocab/lib/presentation/state/curriculum_provider.dart` |
| `dueProgressProvider` | Due SRS items | `quran_vocab/lib/presentation/state/srs_providers.dart` |

## Data Contracts and Versioning

- JSON schemas are implicit in the Dart models and parsing logic. Defined in: `quran_vocab/lib/data/models/*`, `quran_vocab/lib/data/data_loader.dart`.
- No explicit versioning is defined for asset schemas. Marked as Unknown.
