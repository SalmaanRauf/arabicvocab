# ADR 0001 (Suggested): Flutter Web for RTL and Diacritics

## Status

Suggested ADR. Proposed. No recorded approval in repo.

## Context

The app needs accurate Arabic rendering with diacritics and consistent RTL layout across devices. Defined in: `HANDOFF.md`.

## Decision

Use Flutter web to render text via Skia and ensure consistent diacritic placement across platforms. Defined in: `HANDOFF.md`, `quran_vocab/lib/main.dart`.

## Consequences

- Pro: Consistent text rendering and RTL support.
- Con: Web bundle size and Flutter web performance constraints.

Defined in: `quran_vocab/README.md`.
