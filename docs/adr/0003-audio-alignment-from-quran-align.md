# ADR 0003 (Suggested): Audio Alignment from quran-align

## Status

Suggested ADR. Proposed. No recorded approval in repo.

## Context

The app requires word-level audio highlighting synchronized with recitation. Alignment data is not generated in runtime. Defined in: `HANDOFF.md`.

## Decision

Use precomputed alignment data from the quran-align dataset and EveryAyah CDN audio files for Mishary al-Afasy. Defined in: `quran_vocab/assets/data/audio_align/Alafasy_128kbps.json`, `quran_vocab/lib/services/audio/audio_manager.dart`.

## Consequences

- Pro: Offline alignment data with consistent highlighting.
- Con: Alignment accuracy depends on word segmentation and source data.

Defined in: `quran_vocab/lib/data/audio_alignment_loader.dart`.
