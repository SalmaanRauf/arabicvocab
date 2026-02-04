#!/usr/bin/env python3
"""Build daily lessons JSON from QUL abridged explanation data.

Inputs:
- abridged-explanation-of-the-quran.json (repo root)
- quran_vocab/assets/data/ayahs_full.json
- quran_vocab/assets/data/surahs.json

Output:
- quran_vocab/assets/data/daily_lessons.json
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ABRIDGED_PATH = ROOT / "abridged-explanation-of-the-quran.json"
AYAHS_PATH = ROOT / "quran_vocab" / "assets" / "data" / "ayahs_full.json"
SURAHS_PATH = ROOT / "quran_vocab" / "assets" / "data" / "surahs.json"
OUTPUT_PATH = ROOT / "quran_vocab" / "assets" / "data" / "daily_lessons.json"

SOURCE = {
    "work": "Abridged Explanation of the Quran",
    "author": "Al-Mukhtasar Committee",
    "dataset": "QUL",
    "version": "qul-abridged-v1",
}

TAG_RULES = {
    "mercy": ["mercy", "merciful", "compassion"],
    "patience": ["patience", "patient", "steadfast"],
    "prayer": ["prayer", "salah", "supplication"],
    "gratitude": ["gratitude", "thank", "thanks", "grateful"],
    "tawheed": ["tawhid", "tawheed", "oneness", "monotheism"],
}


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def normalize_text(value):
    if isinstance(value, dict):
        return value.get("text", "").strip()
    return str(value).strip()


def split_sentences(text: str):
    text = text.strip()
    if not text:
        return []
    return re.split(r"(?<=[.!?])\s+", text)


def truncate_words(text: str, limit: int):
    words = text.split()
    if len(words) <= limit:
        return text.strip()
    return " ".join(words[:limit]).strip()


def make_title(body_full: str, fallback: str):
    sentences = split_sentences(body_full)
    if not sentences:
        return fallback
    first = sentences[0]
    words = first.split()
    if len(words) <= 10:
        return first.strip()
    return " ".join(words[:10]).strip()


def make_body_short(sentences):
    if not sentences:
        return ""
    selection = []
    word_count = 0
    for sentence in sentences:
        if len(selection) >= 4:
            break
        selection.append(sentence)
        word_count = len(" ".join(selection).split())
        if len(selection) >= 2 and word_count >= 150:
            break
    short_text = " ".join(selection).strip()
    return truncate_words(short_text, 300)


def make_takeaways(sentences):
    if not sentences:
        return []
    if len(sentences) == 1:
        return [sentences[0].strip()]
    return [sentences[-2].strip(), sentences[-1].strip()]


def tags_for_text(text: str):
    lowered = text.lower()
    tags = []
    for tag, keywords in TAG_RULES.items():
        if any(k in lowered for k in keywords):
            tags.append(tag)
    return tags or ["general"]


def word_count(text: str) -> int:
    return len(text.split())


def build_lessons(abridged, ayahs, surahs):
    surah_names = {s["id"]: s["name_english"] for s in surahs}

    by_surah = {}
    for ayah in ayahs:
        by_surah.setdefault(ayah["surah_id"], []).append(ayah)

    lessons = []
    day_index = 0

    for surah_id in range(1, 115):
        surah_ayahs = by_surah.get(surah_id, [])
        surah_ayahs.sort(key=lambda a: a["ayah_number"])
        current = []
        current_texts = []
        current_words = 0

        for ayah in surah_ayahs:
            verse_key = f"{ayah['surah_id']}:{ayah['ayah_number']}"
            tafsir = normalize_text(abridged.get(verse_key, ""))
            if not tafsir:
                tafsir = ""
            current.append((ayah, verse_key))
            current_texts.append(tafsir)
            current_words += word_count(tafsir)

            if current_words >= 150 or len(current) >= 3:
                lessons.append(
                    build_lesson(
                        current,
                        current_texts,
                        surah_names.get(surah_id, f"Surah {surah_id}"),
                        day_index,
                    )
                )
                day_index += 1
                current = []
                current_texts = []
                current_words = 0

        if current:
            lessons.append(
                build_lesson(
                    current,
                    current_texts,
                    surah_names.get(surah_id, f"Surah {surah_id}"),
                    day_index,
                )
            )
            day_index += 1

    return lessons


def build_lesson(group, texts, surah_name, day_index):
    ayah_start = group[0][0]["ayah_number"]
    ayah_end = group[-1][0]["ayah_number"]
    verse_keys = [v for _, v in group]
    body_full = " ".join(t for t in texts if t).strip()
    sentences = split_sentences(body_full)
    title_fallback = f"{surah_name} (Ayah {ayah_start}-{ayah_end})"
    title = make_title(body_full, title_fallback)
    body_short = make_body_short(sentences)
    takeaways = make_takeaways(sentences)
    tags = tags_for_text(body_full)

    lesson_id = f"DL-{str(day_index + 1).zfill(6)}"

    return {
        "id": lesson_id,
        "dayIndex": day_index,
        "surahId": group[0][0]["surah_id"],
        "ayahStart": ayah_start,
        "ayahEnd": ayah_end,
        "verseKeys": verse_keys,
        "title": title,
        "bodyShort": body_short,
        "bodyFull": body_full,
        "takeaways": takeaways,
        "tags": tags,
        "source": SOURCE,
    }


def main():
    abridged = load_json(ABRIDGED_PATH)
    ayahs = load_json(AYAHS_PATH)
    surahs = load_json(SURAHS_PATH)

    lessons = build_lessons(abridged, ayahs, surahs)

    OUTPUT_PATH.write_text(
        json.dumps(lessons, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"Wrote {len(lessons)} lessons to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
