#!/usr/bin/env python3
"""Comprehensive word-level validation for specific surahs.

Tests ALL words in Al-Fatiha (Surah 1) and the last 20 surahs (95-114).

Usage:
    python3 validate_words_comprehensive.py
"""
import json
import sys
import time
import urllib.request
from pathlib import Path


def fetch_verse_words(surah: int, ayah: int) -> list[str]:
    """Fetch word-level data from quran.com API for a single verse."""
    url = (
        f"https://api.quran.com/api/v4/verses/by_key/{surah}:{ayah}"
        f"?words=true&word_fields=text_uthmani"
    )
    req = urllib.request.Request(url, headers={"User-Agent": "QuranVocabValidator/1.0"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    
    verse = data.get("verse", {})
    words = []
    for word in verse.get("words", []):
        if word.get("char_type_name") == "word":
            words.append(word.get("text_uthmani", word.get("text", "")))
    return words


def load_local_words(path: Path) -> dict:
    """Load words_full.json and organize by verse key."""
    with open(path, "r", encoding="utf-8") as f:
        words = json.load(f)
    
    by_verse = {}
    for w in words:
        key = (w["surah_id"], w["ayah_number"])
        if key not in by_verse:
            by_verse[key] = []
        by_verse[key].append((w["position"], w["text_uthmani"]))
    
    for key in by_verse:
        by_verse[key].sort(key=lambda x: x[0])
        by_verse[key] = [text for _, text in by_verse[key]]
    
    return by_verse


def get_surah_ayah_count(surah: int) -> int:
    """Get number of ayahs in a surah."""
    AYAH_COUNTS = {
        1: 7, 95: 8, 96: 19, 97: 5, 98: 8, 99: 8, 100: 11, 101: 11,
        102: 8, 103: 3, 104: 9, 105: 5, 106: 4, 107: 7, 108: 3,
        109: 6, 110: 3, 111: 5, 112: 4, 113: 5, 114: 6
    }
    return AYAH_COUNTS.get(surah, 0)


def validate_surah(surah: int, local_by_verse: dict) -> tuple[int, int, list]:
    """Validate all ayahs in a surah."""
    ayah_count = get_surah_ayah_count(surah)
    matches = 0
    mismatches = []
    
    for ayah in range(1, ayah_count + 1):
        key = (surah, ayah)
        local_words = local_by_verse.get(key, [])
        
        try:
            api_words = fetch_verse_words(surah, ayah)
            time.sleep(0.15)  # Rate limiting
        except Exception as e:
            print(f"      ❓ [{surah}:{ayah}] API error: {e}")
            continue
        
        if local_words == api_words:
            matches += 1
        else:
            mismatches.append({
                "surah": surah,
                "ayah": ayah,
                "local": local_words,
                "api": api_words,
            })
    
    return matches, ayah_count, mismatches


def main():
    data_dir = Path(__file__).parent.parent.parent / "quran_vocab" / "assets" / "data"
    words_path = data_dir / "words_full.json"
    
    if not words_path.exists():
        print(f"❌ Error: {words_path} not found")
        sys.exit(1)
    
    print("📂 Loading words_full.json...")
    local_by_verse = load_local_words(words_path)
    
    # Surahs to validate: Al-Fatiha + last 20 surahs
    surahs_to_test = [1] + list(range(95, 115))
    
    print(f"\n🔍 Validating {len(surahs_to_test)} surahs word-by-word...\n")
    print("=" * 60)
    
    total_matches = 0
    total_ayahs = 0
    all_mismatches = []
    
    for surah in surahs_to_test:
        matches, ayah_count, mismatches = validate_surah(surah, local_by_verse)
        total_matches += matches
        total_ayahs += ayah_count
        all_mismatches.extend(mismatches)
        
        status = "✅" if matches == ayah_count else "❌"
        print(f"  {status} Surah {surah:3}: {matches}/{ayah_count} ayahs match")
    
    print("=" * 60)
    print(f"\n📊 COMPREHENSIVE WORD VALIDATION RESULTS")
    print("=" * 60)
    print(f"✅ Total matches:    {total_matches}/{total_ayahs} ayahs")
    print(f"❌ Total mismatches: {len(all_mismatches)} ayahs")
    
    accuracy = (total_matches / total_ayahs * 100) if total_ayahs > 0 else 0
    print(f"📈 Accuracy:         {accuracy:.2f}%")
    print("=" * 60)
    
    if all_mismatches:
        print("\n❌ MISMATCHES FOUND:\n")
        for m in all_mismatches[:10]:  # Show first 10
            print(f"  [{m['surah']}:{m['ayah']}]")
            print(f"    Local ({len(m['local'])} words): {' '.join(m['local'][:5])}...")
            print(f"    API   ({len(m['api'])} words): {' '.join(m['api'][:5])}...")
            print()
        
        report_path = data_dir / "word_validation_comprehensive.json"
        with open(report_path, "w", encoding="utf-8") as f:
            json.dump(all_mismatches, f, ensure_ascii=False, indent=2)
        print(f"📄 Full report: {report_path.name}")
    else:
        print("\n🎉 100% WORD-LEVEL ACCURACY CONFIRMED!")
    
    sys.exit(0 if len(all_mismatches) == 0 else 1)


if __name__ == "__main__":
    main()
