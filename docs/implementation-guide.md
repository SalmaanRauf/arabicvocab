# Quranic Vocabulary App — Implementation Guide

**Audience:** New engineers joining the project (Flutter/Dart familiarity assumed).

**Goal:** Get a new developer productive quickly with a clear understanding of what the app is, how it works, why it was built this way, and how to extend it safely.

---

## 1) Product Overview

This is a Quranic Arabic vocabulary learning app designed for users who can **read Arabic script phonetically** but don’t understand the meaning. The product focus is to teach high‑frequency vocabulary that yields rapid comprehension gains.

Key product pillars:
- **Script fidelity**: pixel‑accurate diacritics and script support for both Uthmani and IndoPak styles.
- **Word‑by‑word learning**: tappable words with translation, transliteration, and root information.
- **Audio sync (“karaoke”)**: word highlighting aligned to recitation timestamps.
- **Offline‑first**: all essential data stored locally after initial load.
- **Spaced repetition**: FSRS‑based review to maximize retention.

---

## 2) Tech Stack & Rationale

- **Flutter Web**: selected for consistent Arabic rendering across platforms (Skia/Impeller). This avoids OS‑specific font/diacritic variance common in native stacks.
- **Riverpod**: predictable, testable state management with composable providers.
- **JSON Assets** (not SQLite): simpler for web; fast startup; avoids IndexedDB shims.
- **just_audio**: reliable audio playback with position streams.
- **shared_preferences**: persistence via browser localStorage.

---

## 3) Repo Layout

```
arabicvocab/
├── HANDOFF.md                 # Project background + roadmap
├── docs/
│   ├── ARCHITECTURE.md         # Data flow + provider graph
│   ├── schema.md               # Logical DB schema
│   └── implementation-guide.md # This guide
├── quran_vocab/                # Flutter app
│   ├── lib/
│   │   ├── data/               # Data loader + models
│   │   ├── presentation/       # UI + providers
│   │   ├── services/           # Audio + SRS
│   │   └── main.dart
│   ├── assets/
│   │   ├── data/               # Quran data JSON
│   │   └── fonts/              # Arabic fonts
│   └── test/                   # Flutter tests
└── tools/
    └── etl/                    # Data download + validation scripts
```

---

## 4) Running the App Locally

### Flutter SDK
The project vendors Flutter under `arabicvocab/tools/flutter/`. Use that by default.

### Run (Web)
```
cd arabicvocab/quran_vocab
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter run \
  -d web-server --web-port 8080 --web-hostname 0.0.0.0
```

### Tests
Targeted tests are preferred (Flutter test runs can be slow):
```
/Users/salmaanrauf/Documents/arabicapp/arabicvocab/tools/flutter/bin/flutter test test/<file>_test.dart
```

---

## 5) Data Assets & Schema

### Core Assets (`quran_vocab/assets/data/`)
- `surahs.json` — surah metadata
- `ayahs_full.json` — full Quran verses (Uthmani + IndoPak text)
- `words_full.json` — word‑level data (translation, transliteration, roots)
- `roots.json` — root meanings and frequency data
- `audio_align/Alafasy_128kbps.json` — word alignment timestamps
- `lessons.json` — curriculum placeholders (future)
- `validation_report.json` — data validation output

### Schema
See `docs/schema.md` for the normalized model. The Flutter app uses the same logical schema, even though data is stored in JSON.

---

## 6) Data Loading & In‑Memory Models

**DataLoader** (`lib/data/data_loader.dart`) loads all JSON assets once and builds lookup maps:
- Ayah IDs are generated sequentially at load time (not from file).
- Words are grouped by ayah; if explicit word data isn’t present, words are **auto‑split** from the ayah text.

**Key note:** If you change word data or ayah ordering, the generated IDs will change. Audio alignment should **not** depend on word IDs. It is mapped using word indices per ayah.

---

## 7) Script & Font Strategy

### Script toggle
- Users can toggle between **Uthmani** and **IndoPak** script.
- `WordChip` chooses between `text_uthmani` and `text_indopak` based on setting.

### Fonts
- **Active font for IndoPak**: **Lateef (OFL)**
- Avoid proprietary fonts unless explicitly licensed for distribution.

Fonts present in `assets/fonts/`:
- `Lateef-Regular.ttf` (used)
- `AwamiNastaliq-Regular.ttf` (not used currently)
- `NotoNastaliqUrdu-Regular.ttf` (not used currently)
- `PDMS_Saleem_QuranFont.ttf` (do **not** ship unless licensing is confirmed)

---

## 8) Audio + Word Highlighting

### Audio source
- Recitation: **EveryAyah CDN (Mishary al‑Afasy)**
- URLs are generated per ayah.

### Alignment data
- `audio_align/Alafasy_128kbps.json` from **quran‑align**.
- Segment format: `[word_start, word_end, start_ms, end_ms]` (start inclusive, end exclusive)
- Word indices are **0‑based** within the ayah.

### Flow
1. Load surah audio (concatenated source).
2. When user presses play on an ayah, seek to that ayah’s index.
3. Use alignment segments to map audio time → `wordId`.
4. `activeWordIdProvider` emits the current word ID.
5. `WordChip` highlights when `word.id == activeWordId`.

### Stop-at-end behavior
Playback now stops when the ayah’s last segment ends (does not continue to next ayah).

---

## 9) Reader UI

**ReaderView** is the main reading screen:
- Surah picker
- “Load Audio” button (loads all ayah audio for the surah)
- Per‑ayah play button
- Word‑by‑word layout (RTL wrap) with highlight

Search UI exists in providers but is currently hidden in the reader. It can be re‑enabled if needed.

---

## 10) Spaced Repetition (FSRS)

- FSRS v4 is implemented in `lib/services/srs/fsrs.dart`.
- Review state stored in localStorage via `progress_storage.dart`.
- Review UI is functional, but curriculum progression is still not wired.

---

## 11) ETL Scripts

Location: `tools/etl/`

Key scripts:
- `download_quran_data.py` — fetches base Quran text and metadata.
- `download_indopak.py` — updates IndoPak text using quran.com API.
- `build_quran_db.py` — builds a SQLite DB (future‑proofing).
- `validate_words.py` / `validate_quran_text.py` — consistency checks.

These scripts are optional for web runs but are the intended path for data refreshes.

---

## 12) Licensing & Data Sources

- **Quran text**: Tanzil / King Fahd (publicly available)
- **Word data**: QUL datasets (text is permissible; fonts are restricted)
- **Audio**: EveryAyah (Mishary al‑Afasy)
- **Alignment**: quran‑align (cpfair)
- **Font**: Lateef (OFL)

Always verify licensing before shipping fonts or proprietary assets.

---

## 13) Troubleshooting

### Flutter hangs or times out
- Check for stuck Dart processes:
  ```
  ps -ef | grep flutter_tools.snapshot | grep -v grep
  ```
- Kill stale processes if needed.
- Port 8080 issues:
  ```
  lsof -i :8080
  ```

### Word highlighting not appearing
- Ensure alignment JSON is bundled in `pubspec.yaml`.
- Verify alignment is loaded (data loader + alignment loader).
- Confirm `activeWordIdProvider` emits IDs during playback.

### Audio keeps playing beyond ayah
- Ensure stop‑at‑end guard is enabled in `AudioManager`.

---

## 14) Known Gaps & Roadmap

- Curriculum system is scaffolded but not implemented.
- Word‑by‑word translations are complete in data, but content quality may vary.
- Audio alignment is word‑level (not syllable‑level); future improvements could use forced alignment.

---

## 15) Dev Workflow & Best Practices

- Use small, focused commits (“one commit per feature”).
- Prefer worktrees for isolated feature work.
- Update documentation when altering data sources, licenses, or architecture.
- Add targeted tests for audio sync and UI changes.

---

## 16) Design System & UI Theming

This app uses a **global light/dark toggle**. Both modes follow the same layout system and component geometry, but differ in palette and atmospheric treatment.

### Theme Pairing

**Dark Mode — Warm Noir**
- Base: `#141413`
- Surfaces: `#1b1712`, `#221c16`
- Borders: `#2f281f`
- Text: `#f5efe6`
- Muted text: `#c7bbaa`
- Accent (primary): `#d97757`
- Secondary accents: `#6a9bcc`, `#788c5d`
- Ambient gradient: `#2a1e10 → #7b4c1b → #d97757`

**Light Mode — Parchment**
- Base: `#faf9f5`
- Surfaces: `#fff7ec`, `#f7f0e4`
- Borders: `#e8e0d3`
- Text: `#141413`
- Muted text: `#6e675e`
- Accent (primary): `#d97757`

### Typography
- Headings: **Poppins** (brand guideline)
- Body: **Lora** (brand guideline)
- Arabic scripts: **Lateef** (IndoPak), **Amiri** (Uthmani)

### Layout & Components
- Spacing scale: 4, 8, 12, 16, 24, 32, 48
- Cards: 14–18px radius, hairline borders, minimal or ultra‑soft shadow
- Buttons: primary uses accent with subtle gradient; secondary uses outline/text
- Inputs: flat borders + subtle surface tint

### Interaction & Accessibility
- Hover: subtle tint, no scaling
- Pressed: 5–8% luminance shift
- Focus: 2px outline with accent, subtle glow in dark mode
- Highlighting: active word uses fill + border and increased weight
- Contrast: body text meets WCAG AA (>=4.5:1)
- Motion: respect `prefers-reduced-motion`

---

## Appendix: Key Files

- `quran_vocab/lib/data/data_loader.dart`
- `quran_vocab/lib/services/audio/audio_manager.dart`
- `quran_vocab/lib/services/audio/segment_matcher.dart`
- `quran_vocab/lib/presentation/views/reader_view.dart`
- `quran_vocab/lib/presentation/widgets/word_chip.dart`
- `docs/ARCHITECTURE.md`
- `docs/schema.md`
- `HANDOFF.md`
