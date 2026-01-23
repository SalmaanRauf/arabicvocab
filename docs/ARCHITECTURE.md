# Architecture Overview

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter Web App                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │  HomeView   │    │ ReaderView  │    │ ReviewView  │         │
│  │ (Surah List)│    │ (Ayah/Word) │    │ (Flashcards)│         │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘         │
│         │                  │                  │                 │
│         └────────────┬─────┴────────────┬─────┘                 │
│                      │                  │                       │
│              ┌───────▼───────┐  ┌───────▼───────┐               │
│              │    Riverpod   │  │    Riverpod   │               │
│              │   Providers   │  │   Providers   │               │
│              │ (quran_state) │  │ (srs_state)   │               │
│              └───────┬───────┘  └───────┬───────┘               │
│                      │                  │                       │
│              ┌───────▼──────────────────▼───────┐               │
│              │         DataLoader               │               │
│              │   (Loads JSON → Memory)          │               │
│              └───────┬──────────────────┬───────┘               │
│                      │                  │                       │
│              ┌───────▼───────┐  ┌───────▼───────┐               │
│              │  JSON Assets  │  │  localStorage │               │
│              │ (surahs.json  │  │ (user_progress│               │
│              │  ayahs.json   │  │  via shared_  │               │
│              │  roots.json)  │  │  preferences) │               │
│              └───────────────┘  └───────────────┘               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## State Management (Riverpod)

### Provider Hierarchy

```
dataLoaderProvider (FutureProvider)
    │
    ├── surahsProvider (FutureProvider<List<Surah>>)
    │
    ├── selectedSurahIdProvider (StateProvider<int?>)
    │       │
    │       └── ayahsProvider (FutureProvider<List<Ayah>>)
    │               │
    │               └── wordsForAyahProvider.family (FutureProvider<List<Word>>)
    │
    ├── rootByIdProvider.family (FutureProvider<Root?>)
    │
    └── searchResultsProvider (FutureProvider<List<Word>>)
            │
            └── searchQueryProvider (StateProvider<String>)

progressStorageProvider (Provider<ProgressStorage>)
    │
    └── userProgressNotifierProvider (StateNotifierProvider)
            │
            ├── dueProgressProvider (FutureProvider<List<UserProgress>>)
            │       │
            │       └── currentProgressProvider (Provider<UserProgress?>)
            │               │
            │               └── currentRootProvider (FutureProvider<Root?>)
            │
            └── currentSrsIndexProvider (StateProvider<int>)

audioManagerProvider (Provider<AudioManager>)
    │
    ├── audioSegmentsProvider (FutureProvider<List<Segment>>)
    │
    ├── audioOffsetMsProvider (StateProvider<int>)
    │
    └── activeWordIdProvider (StreamProvider<int?>)

settingsProviders:
    ├── scriptPreferenceProvider (StateProvider<ScriptType>)
    └── audioOffsetMsProvider (StateProvider<int>)
```

## Database Schema

The schema is designed for future SQLite migration but currently uses JSON:

```sql
-- Core content
surahs (id, name_arabic, name_english, verse_count, type)
ayahs (id, surah_id, ayah_number, text_uthmani, text_indopak, translation_en)
words (id, ayah_id, position, text_uthmani, text_indopak, translation_en, 
       transliteration, root_id, lemma_id, audio_start_ms, audio_end_ms)

-- Vocabulary
roots (id, root_text, frequency_count, meaning_short, meaning_long)
lemmas (id, lemma_text, root_id, frequency_rank)

-- User data
user_progress (root_id, srs_stage, stability, difficulty, next_review_date)
curriculum (id, lesson_id, root_id, order_index)

-- Search
word_search (FTS5 virtual table)
```

## FSRS Algorithm Implementation

Located in `lib/services/srs/fsrs.dart`:

```dart
class FSRS {
  // Core parameters (from FSRS v4)
  static const double _decay = -0.5;
  static const double _factor = 19 / 81;
  
  // Calculate probability of recall
  double retrievability(double stability, double elapsedDays) {
    return pow(1 + _factor * elapsedDays / stability, _decay);
  }
  
  // Update difficulty based on rating (1-4)
  double updateDifficulty(double difficulty, int rating) {
    // Mean reversion + rating adjustment
    final newD = difficulty - 0.1 * (rating - 3);
    return newD.clamp(1.0, 10.0);
  }
  
  // Calculate new stability after review
  double updateStability(double stability, double difficulty, 
                         int rating, double elapsedDays) {
    if (rating == 1) {
      // "Again" - use forgetting curve formula
      return stability * pow(difficulty, -0.2);
    }
    // Success - grow stability
    final modifier = rating == 4 ? 1.3 : (rating == 3 ? 1.0 : 0.8);
    return stability * (1 + exp(-difficulty / 10) * modifier);
  }
}
```

## Audio Sync Flow

```
1. User pastes MP3 URL
2. AudioManager.setSource(url, segments)
3. just_audio loads and plays
4. Position stream emits current ms
5. Binary search finds active word in segments
6. activeWordIdProvider emits word ID
7. WordChip rebuilds with highlight
8. ScrollController auto-scrolls if needed
```

## File Loading Sequence

```
1. main.dart → runApp(ProviderScope(child: QuranVocabApp()))
2. QuranVocabApp builds MaterialApp.router
3. HomeView watches surahsProvider
4. surahsProvider watches dataLoaderProvider
5. DataLoader.load():
   a. rootBundle.loadString('assets/data/surahs.json')
   b. rootBundle.loadString('assets/data/ayahs_full.json')
   c. rootBundle.loadString('assets/data/words_sample.json')
   d. rootBundle.loadString('assets/data/roots.json')
   e. Parse JSON → Model objects
   f. Build lookup maps
6. Provider resolves with data
7. UI renders surah list
```

## Key Design Decisions

### 1. Word Fallback Strategy
For verses without explicit word-by-word translations:
```dart
if (explicitWords.containsKey(key)) {
  _wordsByAyahId[ayah.id] = explicitWords[key];
} else {
  // Split Arabic text by spaces
  final arabicWords = ayah.textUthmani.split(' ');
  // Generate Word objects with empty translations
}
```

### 2. Ayah ID Generation
Sequential IDs generated at load time (not from data):
```dart
int ayahId = 1;
_ayahs = ayahsList.map((e) {
  ayahIdMap['${surahId}:${ayahNumber}'] = ayahId;
  return Ayah(id: ayahId++, ...);
}).toList();
```

### 3. Progress Persistence
Using shared_preferences for web localStorage:
```dart
Future<void> save(Map<int, UserProgress> progress) async {
  final prefs = await SharedPreferences.getInstance();
  final list = progress.values.map((p) => p.toMap()).toList();
  await prefs.setString('user_progress', jsonEncode(list));
}
```

## Performance Considerations

1. **Large JSON (4MB ayahs_full.json)**
   - Loads once at startup
   - Stays in memory
   - Consider lazy loading by surah for mobile

2. **Word Lookup**
   - Pre-computed `_wordsByAyahId` map
   - O(1) lookup per ayah

3. **Search**
   - Linear scan through words with translations
   - Consider FTS index for full corpus

4. **RTL Rendering**
   - Flutter handles natively
   - Wrap widget for word flow
   - TextDirection.rtl on containers
