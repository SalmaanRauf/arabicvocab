#!/usr/bin/env python3
import argparse
import json
import sqlite3
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path


TANZIL_UTHMANI_URL = "https://tanzil.net/res/text/uthmani"
TANZIL_INDOPAK_URL = "https://tanzil.net/res/text/indopak"
QURAN_WBW_URL = "https://raw.githubusercontent.com/marwan/quranwbw/master/data/words.json"
LEMMA_FREQ_URL = "https://raw.githubusercontent.com/kaisdukes/quranic-corpus/master/data/lemmacount.txt"
ALIGN_URL = (
    "https://raw.githubusercontent.com/cpfair/quran-align/master/output/align.json"
)


@dataclass
class AyahText:
    surah: int
    ayah: int
    text: str


def download(url: str, dest: Path) -> None:
  dest.parent.mkdir(parents=True, exist_ok=True)
  if dest.exists():
    return
  with urllib.request.urlopen(url) as resp:  # noqa: S310
    dest.write_bytes(resp.read())


def parse_tanzil(path: Path) -> list[AyahText]:
  data = path.read_text(encoding="utf-8").splitlines()
  entries: list[AyahText] = []
  for line in data:
    if not line.strip():
      continue
    surah_str, ayah_str, text = line.split("|", 2)
    entries.append(
        AyahText(
            surah=int(surah_str),
            ayah=int(ayah_str),
            text=text.strip(),
        )
    )
  return entries


def load_wbw(path: Path) -> dict[tuple[int, int], list[dict]]:
  payload = json.loads(path.read_text(encoding="utf-8"))
  words: dict[tuple[int, int], list[dict]] = {}
  for entry in payload:
    surah = int(entry["surah"])
    ayah = int(entry["ayah"])
    words.setdefault((surah, ayah), []).append(entry)
  return words


def load_lemmas(path: Path) -> dict[str, int]:
  freqs: dict[str, int] = {}
  for line in path.read_text(encoding="utf-8").splitlines():
    if not line.strip():
      continue
    lemma, count = line.split("\t")
    freqs[lemma.strip()] = int(count.strip())
  return freqs


def load_alignment(path: Path) -> dict[tuple[int, int, int], tuple[int, int]]:
  payload = json.loads(path.read_text(encoding="utf-8"))
  alignment: dict[tuple[int, int, int], tuple[int, int]] = {}
  for entry in payload:
    surah = int(entry["surah"])
    ayah = int(entry["ayah"])
    for seg in entry.get("segments", []):
      pos = int(seg["position"])
      alignment[(surah, ayah, pos)] = (int(seg["start"]), int(seg["end"]))
  return alignment


def create_schema(conn: sqlite3.Connection) -> None:
  cur = conn.cursor()
  cur.executescript(
      """
      PRAGMA foreign_keys = ON;
      CREATE TABLE IF NOT EXISTS surahs (
        id INTEGER PRIMARY KEY,
        name_arabic TEXT NOT NULL,
        name_english TEXT NOT NULL,
        verse_count INTEGER NOT NULL,
        type TEXT NOT NULL
      );
      CREATE TABLE IF NOT EXISTS ayahs (
        id INTEGER PRIMARY KEY,
        surah_id INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        text_uthmani TEXT NOT NULL,
        text_indopak TEXT NOT NULL,
        translation_en TEXT NOT NULL,
        FOREIGN KEY (surah_id) REFERENCES surahs(id) ON DELETE CASCADE
      );
      CREATE TABLE IF NOT EXISTS roots (
        id INTEGER PRIMARY KEY,
        root_text TEXT NOT NULL,
        frequency_count INTEGER NOT NULL,
        meaning_short TEXT NOT NULL,
        meaning_long TEXT NOT NULL
      );
      CREATE TABLE IF NOT EXISTS lemmas (
        id INTEGER PRIMARY KEY,
        lemma_text TEXT NOT NULL,
        root_id INTEGER,
        frequency_rank INTEGER NOT NULL,
        FOREIGN KEY (root_id) REFERENCES roots(id) ON DELETE SET NULL
      );
      CREATE TABLE IF NOT EXISTS words (
        id INTEGER PRIMARY KEY,
        ayah_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        text_uthmani TEXT NOT NULL,
        text_indopak TEXT NOT NULL,
        translation_en TEXT NOT NULL,
        transliteration TEXT NOT NULL,
        root_id INTEGER,
        lemma_id INTEGER,
        audio_start_ms INTEGER,
        audio_end_ms INTEGER,
        FOREIGN KEY (ayah_id) REFERENCES ayahs(id) ON DELETE CASCADE,
        FOREIGN KEY (root_id) REFERENCES roots(id) ON DELETE SET NULL,
        FOREIGN KEY (lemma_id) REFERENCES lemmas(id) ON DELETE SET NULL
      );
      CREATE TABLE IF NOT EXISTS user_progress (
        root_id INTEGER PRIMARY KEY,
        srs_stage TEXT NOT NULL,
        stability REAL NOT NULL,
        difficulty REAL NOT NULL,
        next_review_date TEXT NOT NULL,
        FOREIGN KEY (root_id) REFERENCES roots(id) ON DELETE CASCADE
      );
      CREATE TABLE IF NOT EXISTS curriculum (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER NOT NULL,
        root_id INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (root_id) REFERENCES roots(id) ON DELETE CASCADE
      );
      CREATE VIRTUAL TABLE IF NOT EXISTS word_search USING fts5(
        content,
        word_id UNINDEXED
      );
      CREATE INDEX IF NOT EXISTS idx_ayahs_surah ON ayahs(surah_id);
      CREATE INDEX IF NOT EXISTS idx_words_ayah ON words(ayah_id);
      CREATE INDEX IF NOT EXISTS idx_words_root ON words(root_id);
      """
  )
  conn.commit()


def build_database(
    uthmani: list[AyahText],
    indopak: list[AyahText],
    wbw: dict[tuple[int, int], list[dict]],
    lemmas: dict[str, int],
    alignment: dict[tuple[int, int, int], tuple[int, int]],
    out_path: Path,
) -> None:
  if out_path.exists():
    out_path.unlink()
  conn = sqlite3.connect(out_path)
  create_schema(conn)
  cur = conn.cursor()

  # Basic surah metadata placeholder. Replace with authoritative data later.
  surah_counts: dict[int, int] = {}
  for entry in uthmani:
    surah_counts[entry.surah] = max(surah_counts.get(entry.surah, 0), entry.ayah)
  for surah_id, verse_count in surah_counts.items():
    cur.execute(
        """
        INSERT INTO surahs (id, name_arabic, name_english, verse_count, type)
        VALUES (?, ?, ?, ?, ?)
        """,
        (surah_id, f"Surah {surah_id}", f"Surah {surah_id}", verse_count, "Meccan"),
    )

  uthmani_map = {(a.surah, a.ayah): a.text for a in uthmani}
  indopak_map = {(a.surah, a.ayah): a.text for a in indopak}

  ayah_id = 1
  word_id = 1
  lemma_id_map: dict[str, int] = {}
  for (surah, ayah), text in uthmani_map.items():
    indopak_text = indopak_map.get((surah, ayah), text)
    cur.execute(
        """
        INSERT INTO ayahs (id, surah_id, ayah_number, text_uthmani, text_indopak, translation_en)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (ayah_id, surah, ayah, text, indopak_text, ""),
    )

    word_entries = wbw.get((surah, ayah), [])
    for position, word in enumerate(word_entries, start=1):
      lemma_text = word.get("lemma") or ""
      lemma_id = None
      if lemma_text:
        if lemma_text not in lemma_id_map:
          lemma_id_map[lemma_text] = len(lemma_id_map) + 1
          cur.execute(
              """
              INSERT INTO lemmas (id, lemma_text, root_id, frequency_rank)
              VALUES (?, ?, ?, ?)
              """,
              (
                  lemma_id_map[lemma_text],
                  lemma_text,
                  None,
                  lemmas.get(lemma_text, 0),
              ),
          )
        lemma_id = lemma_id_map[lemma_text]
      start_ms, end_ms = alignment.get((surah, ayah, position), (None, None))
      cur.execute(
          """
          INSERT INTO words (
            id, ayah_id, position, text_uthmani, text_indopak,
            translation_en, transliteration, root_id, lemma_id,
            audio_start_ms, audio_end_ms
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          """,
          (
              word_id,
              ayah_id,
              position,
              word.get("arabic", ""),
              word.get("arabic", ""),
              word.get("english", ""),
              word.get("transliteration", ""),
              None,
              lemma_id,
              start_ms,
              end_ms,
          ),
      )
      word_id += 1

    ayah_id += 1

  conn.commit()
  conn.close()


def parse_args() -> argparse.Namespace:
  parser = argparse.ArgumentParser(description="Build quran.db from sources.")
  parser.add_argument("--data-dir", type=Path, default=Path("data/raw"))
  parser.add_argument("--output", type=Path, default=Path("data/quran.db"))
  parser.add_argument("--skip-download", action="store_true")
  return parser.parse_args()


def main() -> None:
  args = parse_args()
  data_dir: Path = args.data_dir

  uthmani_path = data_dir / "quran_uthmani.txt"
  indopak_path = data_dir / "quran_indopak.txt"
  wbw_path = data_dir / "quran_wbw.json"
  lemma_path = data_dir / "lemmas.txt"
  alignment_path = data_dir / "alignment.json"

  if not args.skip_download:
    download(TANZIL_UTHMANI_URL, uthmani_path)
    download(TANZIL_INDOPAK_URL, indopak_path)
    download(QURAN_WBW_URL, wbw_path)
    download(LEMMA_FREQ_URL, lemma_path)
    download(ALIGN_URL, alignment_path)

  uthmani = parse_tanzil(uthmani_path)
  indopak = parse_tanzil(indopak_path)
  wbw = load_wbw(wbw_path)
  lemmas = load_lemmas(lemma_path)
  alignment = load_alignment(alignment_path)

  args.output.parent.mkdir(parents=True, exist_ok=True)
  build_database(uthmani, indopak, wbw, lemmas, alignment, args.output)
  print(f"Built database at {args.output}")


if __name__ == "__main__":
  main()
