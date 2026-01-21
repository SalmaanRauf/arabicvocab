# ETL: Build `quran.db`

This script downloads Quran text, word-by-word data, lemma frequency counts,
and audio alignment metadata, then builds a local SQLite database.

## Usage

```bash
python tools/etl/build_quran_db.py
```

By default, files download into `data/raw/` and the DB is written to
`data/quran.db` (both ignored by git).

## Options

- `--data-dir`: directory for raw source files
- `--output`: path to the SQLite file
- `--skip-download`: use existing files without downloading

Example:

```bash
python tools/etl/build_quran_db.py --skip-download --data-dir data/raw --output data/quran.db
```
