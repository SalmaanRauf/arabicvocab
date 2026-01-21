# Quranic Vocabulary App

A Flutter web application for learning Quranic Arabic vocabulary through word-by-word study and spaced repetition.

## Features

- **114 Surahs**: Browse all surahs with Arabic and English names
- **Word-by-Word Reader**: Tap any word to see its meaning, root, and frequency
- **RTL Support**: Proper right-to-left rendering for Arabic text
- **Uthmani & IndoPak Scripts**: Toggle between script styles in settings
- **Search**: Find words by English meaning or transliteration
- **Spaced Repetition (FSRS)**: Review vocabulary with intelligent scheduling
- **Audio Sync**: Word highlighting synchronized with recitation audio (requires audio URL)
- **Offline-First**: All data bundled as JSON assets

## Getting Started

### Prerequisites

- Flutter SDK (3.24.5 or later)
- Web browser (Chrome recommended)

### Run Locally

```bash
cd quran_vocab
flutter pub get
flutter run -d chrome
```

### Build for Production

```bash
flutter build web --release
```

The build output will be in `build/web/`.

## Architecture

- **State Management**: Riverpod
- **Routing**: go_router
- **Data**: JSON assets loaded into memory (IndexedDB-ready)
- **SRS Algorithm**: FSRS v4 (Free Spaced Repetition Scheduler)

## Data Sources

The app uses bundled JSON data derived from:
- Tanzil.net (Quran text)
- Quranic Arabic Corpus (morphology)
- quran-align project (audio timestamps)

To build a full database from source, see `tools/etl/README.md`.

## Project Structure

```
lib/
├── data/           # Models, DB, data loader
├── presentation/   # Views, widgets, state providers
└── services/       # Audio manager, FSRS algorithm
```

## License

This project is for educational purposes. Quran text data is in the public domain.
