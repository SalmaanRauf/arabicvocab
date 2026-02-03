# ADR 0002 (Suggested): JSON Assets Over SQLite for Web

## Status

Suggested ADR. Proposed. No recorded approval in repo.

## Context

The app targets Flutter web and needs offline-first data without complex web DB setup. Defined in: `HANDOFF.md`.

## Decision

Load Quran content from bundled JSON assets into memory at startup, rather than relying on SQLite in web builds. Defined in: `quran_vocab/lib/data/data_loader.dart`, `quran_vocab/pubspec.yaml`.

## Consequences

- Pro: Simple deployment and deterministic data.
- Con: Larger memory use and longer initial load.

Defined in: `quran_vocab/lib/data/data_loader.dart`.
