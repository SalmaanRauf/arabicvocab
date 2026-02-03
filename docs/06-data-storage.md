# Data and Storage

## Data Stores

| Store | Purpose | Location | Persistence | Evidence |
| --- | --- | --- | --- | --- |
| JSON assets | Quran text, words, roots, lessons | `quran_vocab/assets/data/*` | Bundled with app | `quran_vocab/lib/data/data_loader.dart` |
| Audio alignment JSON | Word timing alignment | `quran_vocab/assets/data/audio_align/Alafasy_128kbps.json` | Bundled with app | `quran_vocab/lib/data/audio_alignment_loader.dart` |
| Local storage | User progress and streak | Browser localStorage via shared_preferences | User device | `quran_vocab/lib/services/storage/progress_storage.dart` |
| SQLite schema (optional) | Future persistence | `quran_vocab/lib/data/db/quran_database.dart` | Not wired into runtime | `quran_vocab/lib/data/db/quran_database.dart` |

## Data Files and Shapes

| File | Contents | Notes | Evidence |
| --- | --- | --- | --- |
| `quran_vocab/assets/data/surahs.json` | Surah metadata | Loaded into `Surah` model | `quran_vocab/lib/data/data_loader.dart` |
| `quran_vocab/assets/data/ayahs_full.json` | All ayahs with Uthmani and IndoPak text | IndoPak may be updated by script | `quran_vocab/lib/data/data_loader.dart`, `tools/etl/download_indopak.py` |
| `quran_vocab/assets/data/words_full.json` | Word-by-word data | Used for word display and search | `quran_vocab/lib/data/data_loader.dart` |
| `quran_vocab/assets/data/roots.json` | Root metadata | Used in word detail popup | `quran_vocab/lib/data/data_loader.dart` |
| `quran_vocab/assets/data/lessons.json` | Curriculum | Loaded into `Unit` and `Lesson` models | `quran_vocab/lib/presentation/state/curriculum_provider.dart` |

## ERD (Relational Schema)

```mermaid
erDiagram
  SURAH ||--o{ AYAH : contains
  AYAH ||--o{ WORD : contains
  ROOT ||--o{ WORD : links
  ROOT ||--o{ LEMMA : groups
  WORD }o--|| LEMMA : uses
  ROOT ||--o{ USER_PROGRESS : tracks
  LESSON ||--o{ CURRICULUM : orders

  SURAH {
    int id PK
    string name_arabic
    string name_english
    int verse_count
    string type
  }
  AYAH {
    int id PK
    int surah_id FK
    int ayah_number
    string text_uthmani
    string text_indopak
    string translation_en
  }
  WORD {
    int id PK
    int ayah_id FK
    int position
    string text_uthmani
    string text_indopak
    string translation_en
    string transliteration
    int root_id FK
    int lemma_id FK
    int audio_start_ms
    int audio_end_ms
  }
  ROOT {
    int id PK
    string root_text
    int frequency_count
    string meaning_short
    string meaning_long
  }
  LEMMA {
    int id PK
    string lemma_text
    int root_id FK
    int frequency_rank
  }
  USER_PROGRESS {
    int root_id PK
    string srs_stage
    float stability
    float difficulty
    string next_review_date
  }
  CURRICULUM {
    int id PK
    int lesson_id
    int root_id
    int order_index
  }
```

Defined in: `quran_vocab/lib/data/db/quran_database.dart`, `docs/schema.md`.

## Data Generation and Validation

- Download primary JSON: `python3 tools/etl/download_quran_data.py`. Defined in: `tools/etl/download_quran_data.py`.
- Update IndoPak text: `python3 tools/etl/download_indopak.py`. Defined in: `tools/etl/download_indopak.py`.
- Validate Uthmani text vs QUL: `python3 tools/etl/validate_quran_text.py`. Defined in: `tools/etl/validate_quran_text.py`.
- Validate word-by-word data vs quran.com API: `python3 tools/etl/validate_words.py`. Defined in: `tools/etl/validate_words.py`.

## Data Lifecycle and Retention

- JSON assets are bundled and shipped with the Flutter web build. Defined in: `quran_vocab/pubspec.yaml`.
- User progress persists in localStorage on the client only. Defined in: `quran_vocab/lib/services/storage/progress_storage.dart`.
- No backup or retention policy is defined in the repo. Marked as Unknown.

## Raw Downloads

- `indopakjsons/` contains raw IndoPak word data downloads used for data preparation, not runtime. Defined in: `indopakjsons/*`.
- `data/raw/` is used by ETL scripts for source files and is gitignored. Defined in: `tools/etl/README.md`, `.gitignore`.
