#!/usr/bin/env python3
"""Validate word-level Quran text against authentic sources.

Word-by-word data is harder to validate since QUL doesn't provide word boundaries.
This script uses quran.com's API as the source of truth for word-level text.

Usage:
    python3 validate_words.py              # Validate words_full.json
    python3 validate_words.py --sample 10  # Check 10 random verses
"""
import json
import random
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
    
    # Organize: {(surah, ayah): [word_texts]}
    by_verse = {}
    for w in words:
        key = (w["surah_id"], w["ayah_number"])
        if key not in by_verse:
            by_verse[key] = []
        by_verse[key].append((w["position"], w["text_uthmani"]))
    
    # Sort by position
    for key in by_verse:
        by_verse[key].sort(key=lambda x: x[0])
        by_verse[key] = [text for _, text in by_verse[key]]
    
    return by_verse


def validate_sample(local_by_verse: dict, sample_size: int = 10):
    """Validate a random sample of verses against quran.com API."""
    print(f"🔍 Validating {sample_size} random verses against quran.com API...\n")
    
    all_keys = list(local_by_verse.keys())
    sample_keys = random.sample(all_keys, min(sample_size, len(all_keys)))
    
    matches = 0
    mismatches = []
    
    for surah, ayah in sample_keys:
        local_words = local_by_verse[(surah, ayah)]
        
        try:
            api_words = fetch_verse_words(surah, ayah)
            time.sleep(0.2)  # Rate limiting
        except Exception as e:
            print(f"  ❓ [{surah}:{ayah}] API error: {e}")
            continue
        
        if local_words == api_words:
            print(f"  ✅ [{surah}:{ayah}] {len(local_words)} words match")
            matches += 1
        else:
            print(f"  ❌ [{surah}:{ayah}] MISMATCH")
            mismatches.append({
                "surah": surah,
                "ayah": ayah,
                "local": local_words,
                "api": api_words,
            })
            
            # Show difference
            print(f"      Local: {' '.join(local_words[:5])}...")
            print(f"      API:   {' '.join(api_words[:5])}...")
    
    print(f"\n{'=' * 60}")
    print(f"WORD VALIDATION RESULTS (sample)")
    print(f"{'=' * 60}")
    print(f"✅ Matches:    {matches}/{sample_size}")
    print(f"❌ Mismatches: {len(mismatches)}/{sample_size}")
    
    return mismatches


def main():
    sample_size = 10
    if "--sample" in sys.argv:
        idx = sys.argv.index("--sample")
        if idx + 1 < len(sys.argv):
            sample_size = int(sys.argv[idx + 1])
    
    data_dir = Path(__file__).parent.parent.parent / "quran_vocab" / "assets" / "data"
    words_path = data_dir / "words_full.json"
    
    if not words_path.exists():
        print(f"❌ Error: {words_path} not found")
        sys.exit(1)
    
    print(f"📂 Loading {words_path.name}...")
    local_by_verse = load_local_words(words_path)
    print(f"   Found {len(local_by_verse)} verses with word data\n")
    
    mismatches = validate_sample(local_by_verse, sample_size)
    
    if mismatches:
        report_path = data_dir / "word_validation_report.json"
        with open(report_path, "w", encoding="utf-8") as f:
            json.dump(mismatches, f, ensure_ascii=False, indent=2)
        print(f"\n📄 Report saved to {report_path.name}")
    
    sys.exit(0 if len(mismatches) == 0 else 1)


if __name__ == "__main__":
    main()
