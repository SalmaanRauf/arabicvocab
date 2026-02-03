# Quranic Vocabulary App

A Flutter web application for learning Quranic Arabic vocabulary through word-by-word study and spaced repetition. Defined in: `quran_vocab/README.md`.

## Quickstart

1. `cd quran_vocab`
2. `flutter pub get`
3. `flutter run -d chrome`

If you have a bundled Flutter SDK at `tools/flutter/`, you can run `../tools/flutter/bin/flutter` instead of `flutter`. This path is gitignored, so verify it exists locally. Defined in: `.gitignore`, `HANDOFF.md`.

## Project Docs

- [Executive Overview](docs/00-executive-overview.md)
- [Repository Map](docs/01-repository-map.md)
- [Architecture](docs/02-architecture.md)
- [Local Development](docs/03-local-development.md)
- [Build, Test, CI/CD](docs/04-build-test-cicd.md)
- [Runtime and Infra](docs/05-runtime-infra.md)
- [Data and Storage](docs/06-data-storage.md)
- [API and Interfaces](docs/07-api-interfaces.md)
- [Security](docs/08-security.md)
- [Operations](docs/09-operations.md)
- [Contributing](docs/10-contributing.md)
- [Glossary](docs/glossary.md)
- [ADR 0001](docs/adr/0001-flutter-web-for-rtl-and-diacritics.md)
- [ADR 0002](docs/adr/0002-json-assets-over-db.md)
- [ADR 0003](docs/adr/0003-audio-alignment-from-quran-align.md)

## What You Will See Running Locally

- Surah list, reader, review, curriculum, settings, and dashboard views. Defined in: `quran_vocab/lib/presentation/routes/app_router.dart`.
- Word-by-word display with optional audio highlighting. Defined in: `quran_vocab/lib/presentation/widgets/ayah_widget.dart`, `quran_vocab/lib/services/audio/audio_manager.dart`.
- IndoPak vs Uthmani script toggle. Defined in: `quran_vocab/lib/presentation/state/settings_providers.dart`, `quran_vocab/lib/presentation/widgets/word_chip.dart`.

## Source of Truth

These docs are generated directly from the repository contents. If behavior changes, update the docs and point to the new source files.
