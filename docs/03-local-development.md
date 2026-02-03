# Local Development Onboarding (Day 1)

## Prerequisites

- Flutter SDK 3.24.5 or later. Defined in: `quran_vocab/README.md`.
- Python 3 for data scripts. Defined in: `tools/etl/*.py`.
- A Chromium-based browser for Flutter web. Defined in: `quran_vocab/README.md`.

Optional:

- Bundled Flutter SDK under `tools/flutter/` if present. This path is gitignored, verify locally. Defined in: `.gitignore`, `HANDOFF.md`.

## Setup From Zero

1. Clone the repo.
2. `cd arabicvocab/quran_vocab`
3. `flutter pub get`
4. `flutter run -d chrome`

Defined in: `quran_vocab/README.md`.

## Environment Variables

No environment variables are referenced by the app code.

| Var | Purpose | Required | Default | Where Defined | Example |
| --- | --- | --- | --- | --- | --- |
| None | None | No | None | None | None |

Verification step: search for `fromEnvironment`, `.env`, or `dotenv` in `quran_vocab/lib/`.

## How to Run

- App: `flutter run -d chrome`.
- Tests: `flutter test`.
- Lints: `flutter analyze`.
- Build: `flutter build web --release`.

Defined in: `quran_vocab/README.md`, `quran_vocab/analysis_options.yaml`.

## Data Regeneration

- Regenerate Quran data: `python3 tools/etl/download_quran_data.py`.
- Update IndoPak text in ayahs: `python3 tools/etl/download_indopak.py`.
- Validate Uthmani text vs QUL: `python3 tools/etl/validate_quran_text.py`.
- Validate words vs quran.com: `python3 tools/etl/validate_words.py`.

Defined in: `tools/etl/*.py`.

## First 30 Minutes Checklist

1. Run the app locally and reach the Reader view.
2. Load a surah and verify word chips render.
3. Press Load Audio and play a single ayah.
4. Open Settings and toggle script type.
5. Open Review and complete a card.

Defined in: `quran_vocab/lib/presentation/routes/app_router.dart`, `quran_vocab/lib/presentation/views/*`.

## First PR Guide (Safe Change)

1. Update the text in the Home header copy or a small theme color.
2. Run `flutter test` and `flutter analyze`.
3. Verify UI manually by running `flutter run -d chrome`.
4. Open a PR referencing the change and test outputs.

Defined in: `quran_vocab/lib/presentation/views/home_view.dart`, `quran_vocab/analysis_options.yaml`.
