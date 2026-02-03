# Repository Map

## Top-Level Tree

```text
arabicvocab/
├── HANDOFF.md
├── README.md
├── docs/
│   ├── 00-executive-overview.md
│   ├── 01-repository-map.md
│   ├── 02-architecture.md
│   ├── 03-local-development.md
│   ├── 04-build-test-cicd.md
│   ├── 05-runtime-infra.md
│   ├── 06-data-storage.md
│   ├── 07-api-interfaces.md
│   ├── 08-security.md
│   ├── 09-operations.md
│   ├── 10-contributing.md
│   ├── glossary.md
│   └── adr/
├── quran_vocab/
│   ├── lib/
│   ├── assets/
│   ├── test/
│   ├── web/
│   ├── pubspec.yaml
│   └── README.md
├── tools/
│   ├── etl/
│   └── flutter/ (optional, gitignored)
├── indopakjsons/
├── DesignInspo/
└── home_view.png
```

Defined in: repository tree, `.gitignore`.

## Directory Guide

| Path | Purpose | Notes | Evidence |
| --- | --- | --- | --- |
| `quran_vocab/` | Flutter web app source | Main app lives here | `quran_vocab/lib/main.dart` |
| `quran_vocab/lib/` | App code | Views, state, data loader, services | `quran_vocab/lib/presentation/routes/app_router.dart` |
| `quran_vocab/assets/` | Bundled data and fonts | JSON data and audio alignment | `quran_vocab/assets/data/*`, `quran_vocab/assets/fonts/*` |
| `quran_vocab/test/` | Tests | Widget, audio, alignment, FSRS tests | `quran_vocab/test/*` |
| `quran_vocab/web/` | Flutter web entry files | index.html, manifest | `quran_vocab/web/index.html`, `quran_vocab/web/manifest.json` |
| `tools/etl/` | Data tooling scripts | Download, validation, DB build | `tools/etl/*.py` |
| `tools/flutter/` | Optional local Flutter SDK | Gitignored | `.gitignore` |
| `docs/` | Project documentation | Generated docs | `docs/*` |
| `indopakjsons/` | Raw IndoPak word data downloads | Not wired into runtime | `indopakjsons/*` |
| `DesignInspo/` | UI inspiration images | Reference only | `DesignInspo/*` |
| `HANDOFF.md` | Historical project handoff | Prior context | `HANDOFF.md` |

## Entry Points

- App entry point: `quran_vocab/lib/main.dart`.
- Router configuration: `quran_vocab/lib/presentation/routes/app_router.dart`.
- Data loader: `quran_vocab/lib/data/data_loader.dart`.
- Audio manager: `quran_vocab/lib/services/audio/audio_manager.dart`.
- ETL entry point: `tools/etl/build_quran_db.py`.

## How Things Are Invoked

- Run the app locally: `cd quran_vocab` then `flutter run -d chrome`. Defined in: `quran_vocab/README.md`.
- Generate data: `python3 tools/etl/download_quran_data.py`. Defined in: `tools/etl/download_quran_data.py`.
- Build SQLite DB: `python3 tools/etl/build_quran_db.py`. Defined in: `tools/etl/README.md`.

## Legacy Docs

- `docs/ARCHITECTURE.md` and `docs/schema.md` are legacy references. Use `docs/02-architecture.md` and `docs/06-data-storage.md` as the current sources of truth.
