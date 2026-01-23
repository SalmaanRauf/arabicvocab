# Quranic Vocabulary App - Project Handoff Document

## Executive Summary

This document provides complete context for continuing development of a Quranic Arabic vocabulary learning application. The project implements an "80% Vocabulary" methodology - teaching the ~300-500 most frequent words that comprise 80% of the Quran's text, allowing users who can read Arabic script but don't understand it to comprehend the meaning.

---

## Original Vision (User's Master Specification)

### Core Premise
The app targets users who can **read Arabic script phonetically** but lack semantic understanding. Based on Zipf's Law applied to the Quran:
- 60-70 words = ~50% of text
- 300-400 words = ~70-80% of text
- This creates a "force multiplier" effect where learning high-frequency words yields disproportionate comprehension gains

### Pedagogical Framework

#### 1. The "Safety Net" Strategy
Particles and pronouns constitute 41.5% (~32,263 occurrences) of the Quran:
- Detached pronouns: Huwa (He), Hum (They)
- Attached pronouns: -hu (His), -kum (Yours)
- Prepositions: Min (From), Fi (In)

These should be taught FIRST in Level 1 because they appear in almost every verse.

#### 2. The Verb Engine (Trilateral Roots)
Arabic derives words from 3-letter roots. Example: K-T-B → Kataba (wrote), Kitab (book), Maktab (desk)

The "Big 3" verb tenses to teach:
- **Madhi** (Past): Nasara - He helped
- **Mudhari** (Present/Imperfect): Yansuru - He helps  
- **Amr** (Imperative): Unsur - Help!

#### 3. Curriculum Progression (from spec)

| Level | Focus | Coverage |
|-------|-------|----------|
| Unit 1 | Surah Al-Fatiha (1-4) | ~20% |
| Unit 2 | Surah Al-Fatiha (5-7) | ~35% |
| Unit 3 | Safety Net (Particles/Pronouns) | ~50% |
| Unit 4 | Salah Adhkar | ~55% |
| Unit 5 | Top 50 Verbs | ~65% |
| Unit 6 | Last 10 Surahs | ~75% |
| Unit 7 | Advanced Roots | ~80%+ |

### Technical Requirements (from spec)

1. **Text Rendering**: Pixel-perfect Arabic diacritics (Tashkeel)
2. **Script Support**: Uthmani AND IndoPak (Nastaliq) - non-negotiable for South Asian users
3. **Audio Sync**: "Karaoke-style" word highlighting synchronized with recitation
4. **Offline-First**: No internet required after initial load
5. **FSRS Algorithm**: Free Spaced Repetition Scheduler (superior to Anki's SM-2)

### Data Sources (specified in blueprint)
- **Text**: Tanzil Project / King Fahd Complex
- **Morphology**: Quranic Arabic Corpus (University of Leeds)
- **Audio Alignment**: cpfair/quran-align (Mishary Al-Afasy timestamps)
- **Word-by-Word**: marwan/quranwbw repository

---

## What Has Been Built

### Technology Stack
- **Framework**: Flutter Web (chosen for pixel-perfect Arabic text rendering via Skia/Impeller)
- **State Management**: Riverpod
- **Routing**: go_router
- **Database**: JSON assets loaded into memory (IndexedDB-ready)
- **Audio**: just_audio
- **Persistence**: shared_preferences (localStorage)

### Project Structure

```
quran_vocab/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app.dart                  # App widget with ProviderScope
│   ├── data/
│   │   ├── data_loader.dart      # Loads JSON assets into memory
│   │   ├── db/
│   │   │   ├── quran_database.dart  # SQLite schema (for future native)
│   │   │   └── quran_dao.dart       # Data access object
│   │   ├── models/
│   │   │   ├── surah.dart
│   │   │   ├── ayah.dart
│   │   │   ├── word.dart
│   │   │   ├── root.dart
│   │   │   ├── lemma.dart
│   │   │   ├── user_progress.dart
│   │   │   └── curriculum.dart
│   │   └── repository/
│   │       └── quran_repository.dart
│   ├── presentation/
│   │   ├── routes/
│   │   │   └── app_router.dart   # Route definitions
│   │   ├── state/
│   │   │   ├── quran_providers.dart    # Surah/Ayah/Word providers
│   │   │   ├── audio_providers.dart    # Audio playback state
│   │   │   ├── srs_providers.dart      # Spaced repetition state
│   │   │   └── settings_providers.dart # User preferences
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   ├── views/
│   │   │   ├── home_view.dart      # Surah list
│   │   │   ├── reader_view.dart    # Main reading interface
│   │   │   ├── review_view.dart    # SRS flashcard review
│   │   │   └── settings_view.dart  # Preferences
│   │   └── widgets/
│   │       ├── ayah_widget.dart        # Single verse display
│   │       ├── word_chip.dart          # Tappable word
│   │       └── word_detail_popup.dart  # Word info dialog
│   └── services/
│       ├── audio/
│       │   ├── audio_manager.dart  # Playback + word sync
│       │   └── segment.dart        # Audio timestamp model
│       ├── srs/
│       │   └── fsrs.dart           # FSRS v4 algorithm
│       └── storage/
│           └── progress_storage.dart  # localStorage persistence
├── assets/
│   └── data/
│       ├── surahs.json         # 114 surahs with metadata
│       ├── ayahs_full.json     # All 6,236 verses (4MB)
│       ├── words_sample.json   # Word-by-word for sample surahs
│       └── roots.json          # 50 high-frequency roots with meanings
├── test/
│   ├── widget_test.dart
│   └── fsrs_test.dart          # Algorithm verification
└── tools/
    └── etl/
        ├── build_quran_db.py       # Original SQLite builder
        ├── download_quran_data.py  # JSON data downloader
        └── README.md
```

### Features Implemented

#### ✅ Complete
1. **Surah Browser** - All 114 surahs with Arabic/English names, verse counts, revelation type
2. **Verse Reader** - Full RTL Arabic text with English translations for all 6,236 verses
3. **Word-by-Word Display** - Tappable words with meanings (explicit for Al-Fatiha, Al-Ikhlas, Al-Falaq, An-Nas, An-Nasr; auto-split for others)
4. **Word Detail Popup** - Shows word, transliteration, meaning, root info, frequency count
5. **Search** - Find words by English meaning or transliteration
6. **FSRS Spaced Repetition** - Full algorithm with stability/difficulty tracking
7. **Review UI** - Flashcard interface with Again/Hard/Good/Easy ratings
8. **Persistent Progress** - Reviews survive page refresh (localStorage)
9. **Script Toggle** - Switch Uthmani/IndoPak in settings
10. **Audio Offset** - Calibrate for Bluetooth latency
11. **Audio Infrastructure** - Manager with word sync stream (needs audio URL)

#### ⚠️ Partial
1. **Word-by-Word Data** - Only 5 surahs have explicit translations, others show Arabic-only
2. **Audio Files** - Infrastructure ready but no bundled audio (user must paste URL)
3. **Root Linkage** - 50 roots defined, but words aren't all linked to roots yet

#### ❌ Not Started
1. **Curriculum System** - Lesson progression not implemented
2. **TPI (Total Physical Interaction)** - Spatial UI for pronouns
3. **Progress Dashboard** - Coverage percentage, streak tracking
4. **IndoPak Script Rendering** - Toggle exists but uses same text (needs separate font/text)

---

## Key Technical Decisions

### Why Flutter Web (not React Native)?
From the original spec:
1. **Text Rendering**: Flutter uses Skia/Impeller to draw every pixel. Arabic diacritics render identically on all devices. React Native uses native bridges which vary by OS.
2. **RTL Performance**: Flutter's `Wrap` widget with RTL handles complex Arabic layout better.
3. **Strong Typing**: Dart catches errors at compile time, reducing bugs in AI-generated code.

### Why JSON Assets (not SQLite for Web)?
- Web SQLite requires IndexedDB shims which add complexity
- 4MB JSON loads fast and stays in memory
- Future: Can migrate to drift/sqflite for native apps

### Why FSRS (not SM-2/Anki)?
From spec: "FSRS is mathematically superior because it decouples Memory Stability (how long you remember) from Memory Difficulty (how hard it is to learn)."

The formula implemented:
```
R(t, S) = (1 + FACTOR × t/S)^DECAY
```

Where:
- R = Retrievability (probability of recall)
- t = days since last review
- S = Stability (days until 90% recall probability)

---

## How to Run

### Prerequisites
- Flutter SDK (bundled in `tools/flutter/` or install globally)
- Python 3.x (for data scripts)

### Development
```bash
cd quran_vocab

# If using bundled Flutter:
../tools/flutter/bin/flutter pub get
../tools/flutter/bin/flutter run -d chrome

# If Flutter is in PATH:
flutter pub get
flutter run -d chrome
```

### Production Build
```bash
flutter build web --release
# Output in build/web/
```

### Regenerate Data
```bash
python3 tools/etl/download_quran_data.py
# Downloads from alquran.cloud API, saves to assets/data/
```

---

## What's Left to Build

### Priority 1: Complete Word-by-Word Data
The app shows all verses but only 5 surahs have word translations. Options:
1. **Use quran.com API** - Has word-level data but rate-limited
2. **Use corpus.quran.com** - Academic dataset, needs parsing
3. **Manual curation** - Start with high-frequency vocabulary

### Priority 2: Curriculum Implementation
The `curriculum` table and model exist but aren't used. Need:
1. Lesson definitions (JSON or DB)
2. Progress tracking per lesson
3. Unlock logic (complete Unit 1 before Unit 2)
4. UI for lesson selection

### Priority 3: Audio Integration
Infrastructure is complete. Need:
1. Host audio files (or link to existing CDN like verses.quran.com)
2. Load alignment data from cpfair/quran-align
3. Bundle or stream per-verse audio

### Priority 4: Progress Dashboard
Show users their progress:
- Words learned vs total high-frequency
- Quran coverage percentage
- Review streak
- Daily goal tracking

### Priority 5: IndoPak Script
Currently toggles but shows same text. Need:
- IndoPak font (e.g., Noto Nastaliq Urdu)
- Separate text data (from tanzil.net IndoPak variant)
- RTL rendering adjustments for Nastaliq

---

## API & Data Sources (Free)

| Source | URL | Data |
|--------|-----|------|
| alquran.cloud | `api.alquran.cloud/v1/` | Verses, translations |
| quran.com | `api.quran.com/api/v4/` | Word-by-word, audio |
| Tanzil | `tanzil.net/res/` | Raw text files |
| Corpus | `corpus.quran.com` | Morphology, roots |
| Audio Align | `github.com/cpfair/quran-align` | Timestamp JSON |

---

## Codebase Patterns

### Adding a New Provider
```dart
// In lib/presentation/state/
final myProvider = FutureProvider<MyType>((ref) async {
  final loader = await ref.watch(dataLoaderProvider.future);
  return loader.getMyData();
});
```

### Adding a New View
1. Create widget in `lib/presentation/views/`
2. Add route in `lib/presentation/routes/app_router.dart`
3. Use `ConsumerWidget` or `ConsumerStatefulWidget` for Riverpod

### Adding Data
1. Add JSON to `assets/data/`
2. Register in `pubspec.yaml` under `flutter.assets`
3. Load in `DataLoader.load()`

---

## Testing

```bash
# Run all tests
flutter test

# Current tests:
# - fsrs_test.dart: Verifies FSRS math
# - widget_test.dart: App boot smoke test
```

---

## Git History (Key Commits)

1. `Set up Flutter web scaffold and routing`
2. `Add core data models and database schema`
3. `Add ETL script and database schema docs`
4. `Build reader UI with RTL word layout`
5. `Wire audio sync highlighting and offset`
6. `Add FSRS scheduler and review session UI`
7. `Polish settings and script toggle`
8. `Bundle seed Quran data as JSON assets for offline web`
9. `Update README with project documentation`
10. `Complete full Quran data and persistent progress`

---

## Known Issues

1. **Large Asset Size**: `ayahs_full.json` is 4MB. Consider lazy loading by surah.
2. **Web Audio**: just_audio web support is limited. May need howler.js integration.
3. **Font Loading**: google_fonts downloads at runtime. Consider bundling Amiri font.

---

## Contact / References

- **Understand Quran Academy**: Original pedagogy source (Dr. Abdulazeez Abdulraheem)
- **Quranic Arabic Corpus**: morphology.quran.com
- **FSRS Algorithm**: github.com/open-spaced-repetition/fsrs4anki

---

*Document created for LLM agent handoff. Contains full context from development session.*
