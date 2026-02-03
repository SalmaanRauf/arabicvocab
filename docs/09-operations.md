# Operations Runbooks

## Common Tasks

- Restart the app: stop `flutter run` and start again with `flutter run -d chrome`. Defined in: `quran_vocab/README.md`.
- Clear user progress: clear localStorage for the site in browser dev tools. The keys used are `user_progress`, `streak_count`, and `last_review_date`. Defined in: `quran_vocab/lib/services/storage/progress_storage.dart`.
- Regenerate Quran data: `python3 tools/etl/download_quran_data.py`. Defined in: `tools/etl/download_quran_data.py`.
- Update IndoPak text: `python3 tools/etl/download_indopak.py`. Defined in: `tools/etl/download_indopak.py`.
- Validate Uthmani text: `python3 tools/etl/validate_quran_text.py`. Defined in: `tools/etl/validate_quran_text.py`.
- Validate word alignment: `python3 tools/etl/validate_words.py`. Defined in: `tools/etl/validate_words.py`.

## Incident Response Basics

- First check: Flutter console logs in the browser dev tools. Defined in: `quran_vocab/lib/*` (runtime).
- Data-related errors usually stem from JSON parsing. Defined in: `quran_vocab/lib/data/data_loader.dart`.
- Audio issues typically relate to CDN access or alignment data. Defined in: `quran_vocab/lib/services/audio/audio_manager.dart`.

## Troubleshooting Guide

| Symptom | Likely Cause | Fix | Evidence |
| --- | --- | --- | --- |
| App stuck on loading | JSON asset missing or malformed | Rebuild assets, check `assets/data` | `quran_vocab/lib/data/data_loader.dart` |
| No words displayed | Missing word data for ayah | Verify `words_full.json` and word generation logic | `quran_vocab/lib/data/data_loader.dart` |
| Audio button disabled | Audio not loaded for surah | Click Load Audio, verify segments | `quran_vocab/lib/presentation/views/reader_view.dart` |
| Audio plays but no highlight | Alignment data missing or empty | Verify alignment file and segment builder | `quran_vocab/lib/data/audio_alignment_loader.dart` |
| Wrong script displayed | Script toggle not set | Change script in Settings | `quran_vocab/lib/presentation/views/settings_view.dart` |
| Review shows no cards | No due items or empty progress | Run a review to seed progress | `quran_vocab/lib/presentation/state/srs_providers.dart` |
| Progress resets after refresh | localStorage cleared | Check browser storage | `quran_vocab/lib/services/storage/progress_storage.dart` |
| Curriculum lessons locked | Completion not tracked | Mark prior lesson complete | `quran_vocab/lib/presentation/state/curriculum_provider.dart` |
| Fonts look incorrect | Missing font assets | Verify `assets/fonts` and `pubspec.yaml` | `quran_vocab/pubspec.yaml` |
| Flutter build fails | Missing SDK or dependencies | Run `flutter doctor` and `flutter pub get` | `quran_vocab/README.md` |
