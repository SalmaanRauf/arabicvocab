# Contribution and Standards

## Code Style and Linting

- Lint rules are defined by `flutter_lints` via `analysis_options.yaml`. Defined in: `quran_vocab/analysis_options.yaml`.
- Run `flutter analyze` before submitting changes. Defined in: `quran_vocab/analysis_options.yaml`.

## Branching and Reviews

Branching strategy is not specified in the repo. Marked as Unknown. Suggested baseline:

- Use short-lived feature branches.
- Require at least one reviewer.
- Keep commits scoped to a single change.

Verification steps: ask maintainers about branching conventions.

## Review Checklist

- UI changes validated in `flutter run -d chrome`.
- Tests run with `flutter test`.
- Data changes validated with `tools/etl/validate_*.py` when applicable.
- No new fonts or data sources without licensing review.

Defined in: `quran_vocab/README.md`, `tools/etl/*.py`, `quran_vocab/pubspec.yaml`.

## Suggested ADRs

If no ADR system exists, create one under `docs/adr/` and document key decisions. Suggested stubs are included:

- `docs/adr/0001-flutter-web-for-rtl-and-diacritics.md`
- `docs/adr/0002-json-assets-over-db.md`
- `docs/adr/0003-audio-alignment-from-quran-align.md`

## Adding New Features Safely

- New views should be routed via `AppRouter`. Defined in: `quran_vocab/lib/presentation/routes/app_router.dart`.
- New data assets must be added to `pubspec.yaml` and loaded in `DataLoader`. Defined in: `quran_vocab/pubspec.yaml`, `quran_vocab/lib/data/data_loader.dart`.
- New SRS behavior should be isolated in `FSRS` or providers. Defined in: `quran_vocab/lib/services/srs/fsrs.dart`, `quran_vocab/lib/presentation/state/srs_providers.dart`.

## Quality Bar Checklist

- All components are documented and mapped to interfaces and dependencies.
- All run commands were derived from repo scripts or READMEs.
- All env vars are listed with source locations, or marked as none.
- At least two Mermaid diagrams are present in the docs.
- Onboarding steps match repository structure.
- Unknowns are explicitly called out with verification steps.
