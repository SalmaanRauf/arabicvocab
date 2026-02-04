#!/usr/bin/env python3
"""Validate daily lessons JSON."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LESSONS_PATH = ROOT / "quran_vocab" / "assets" / "data" / "daily_lessons.json"


def word_count(text: str) -> int:
    return len(text.split())


def main():
    if not LESSONS_PATH.exists():
        raise SystemExit(f"Missing {LESSONS_PATH}")

    lessons = json.loads(LESSONS_PATH.read_text(encoding="utf-8"))
    if len(lessons) < 500:
        raise SystemExit("Expected at least 500 lessons")

    for idx, lesson in enumerate(lessons):
        day_index = lesson.get("dayIndex")
        if day_index != idx:
            raise SystemExit(f"dayIndex mismatch at {idx}")
        surah_id = lesson.get("surahId")
        verse_keys = lesson.get("verseKeys") or []
        if not verse_keys:
            raise SystemExit(f"Missing verseKeys at {lesson.get('id')}")
        for key in verse_keys:
            surah_str = key.split(":")[0]
            if int(surah_str) != surah_id:
                raise SystemExit(f"Cross-surah lesson {lesson.get('id')}")
        body_short = lesson.get("bodyShort", "")
        if word_count(body_short) > 400:
            raise SystemExit(f"Body short too long at {lesson.get('id')}")
        if not lesson.get("bodyFull"):
            raise SystemExit(f"Empty body full at {lesson.get('id')}")

    print(f"Validated {len(lessons)} lessons")


if __name__ == "__main__":
    main()
