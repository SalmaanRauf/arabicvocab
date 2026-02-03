# Security and Compliance

## AuthN and AuthZ

No authentication or authorization layers are present in the repository. The app runs entirely on the client with local data. Defined in: `quran_vocab/lib/main.dart`, `quran_vocab/lib/services/storage/progress_storage.dart`.

## Secret Management

No secret management system is defined. No environment variables or credential files were found. Defined in: absence of `.env` files and `fromEnvironment` usage in `quran_vocab/lib/`.

## External Data Sources

ETL scripts fetch data from public sources. These scripts do not store credentials in code. Defined in: `tools/etl/*.py`.

## Common Pitfalls and Mitigations

- Do not embed API keys in Flutter web builds. This repo does not currently use keys. Defined in: `quran_vocab/pubspec.yaml`.
- Avoid bundling copyrighted fonts without proper licensing. Only `Lateef` is configured in `pubspec.yaml`. Defined in: `quran_vocab/pubspec.yaml`.

## Dependency Management

Dependencies are pinned in `pubspec.lock`. There is no automated vulnerability scanning in this repo. Defined in: `quran_vocab/pubspec.lock`.

## Compliance

No compliance or privacy documentation is defined. Marked as Unknown.
