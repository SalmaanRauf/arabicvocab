# Build, Test, and CI/CD

## Build Process

- Development: `flutter run -d chrome`.
- Production: `flutter build web --release`.
- Output: `quran_vocab/build/web/`.

Defined in: `quran_vocab/README.md`.

## Test Strategy

| Test Type | Location | How to Run | Notes | Evidence |
| --- | --- | --- | --- | --- |
| Unit tests | `quran_vocab/test/` | `flutter test` | Audio utilities, alignment, FSRS, UI | `quran_vocab/test/*` |
| Widget tests | `quran_vocab/test/reader_view_test.dart` | `flutter test` | Ensures reader controls present | `quran_vocab/test/reader_view_test.dart` |
| Data validation | `tools/etl/validate_*.py` | `python3 tools/etl/validate_quran_text.py` | Compares against external sources | `tools/etl/validate_quran_text.py` |

## Linting and Formatting

- Analyzer: `flutter analyze`. Defined in: `quran_vocab/analysis_options.yaml`.
- Formatting: use `dart format .` if needed. This is a standard Flutter tool and not configured in repo; verify team preference. Defined in: `quran_vocab/analysis_options.yaml`.

## CI Pipeline

Unknown. No CI configuration was found in the repository root (no `.github/`, `.gitlab-ci.yml`, or similar). Verification steps:

- Search for CI configs in repo root.
- Ask maintainers about build and deploy automation.

## Release Process

Unknown. No versioning or release automation was found in the repository.

Suggested verification steps:

- Check for tags in git history.
- Ask maintainers about release cadence and hosting target.

## Deployment Pipeline

Unknown. No deployment configs found. For Flutter web, typical deployment is static hosting of `quran_vocab/build/web/`.

Verification steps:

- Look for hosting configs or a deployment README.
- Confirm hosting provider with maintainers.
