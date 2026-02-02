#!/usr/bin/env python3
"""Validate Quran text accuracy against authentic QUL (Quranic Universal Library) data.

This script compares our ayahs_full.json against the authoritative Medina Mushaf
text from Tarteel AI's Quranic Universal Library via the quran-validator project.

Usage:
    python3 validate_quran_text.py           # Validate and report differences
    python3 validate_quran_text.py --fix     # Validate and auto-fix using QUL data
"""
import json
import sys
import urllib.request
from pathlib import Path

# Source: Tarteel AI's Quranic Universal Library (Medina Mushaf)
QUL_URL = "https://raw.githubusercontent.com/yazinsai/quran-validator/main/data/quran-verses.json"


def fetch_qul_data() -> list[dict]:
    """Download authentic Quran text from QUL."""
    print("📥 Downloading authentic Quran text from QUL (Tarteel AI)...")
    req = urllib.request.Request(QUL_URL, headers={"User-Agent": "QuranVocabValidator/1.0"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode("utf-8"))


def load_local_ayahs(path: Path) -> list[dict]:
    """Load our local ayahs_full.json."""
    print(f"📂 Loading local data from {path.name}...")
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def normalize_arabic(text: str) -> str:
    """Normalize Arabic text for comparison (remove diacritics)."""
    # Arabic diacritics (tashkeel)
    diacritics = [
        '\u064B',  # Fathatan
        '\u064C',  # Dammatan
        '\u064D',  # Kasratan
        '\u064E',  # Fatha
        '\u064F',  # Damma
        '\u0650',  # Kasra
        '\u0651',  # Shadda
        '\u0652',  # Sukun
        '\u0653',  # Maddah
        '\u0654',  # Hamza above
        '\u0655',  # Hamza below
        '\u0656',  # Subscript alef
        '\u0670',  # Superscript alef
        '\u06E5',  # Small waw
        '\u06E6',  # Small yeh
    ]
    for d in diacritics:
        text = text.replace(d, '')
    return text.strip()


def compare_verses(local_ayahs: list[dict], qul_verses: list[dict], fix_mode: bool = False) -> tuple[int, list[dict]]:
    """Compare local verses against QUL authentic text."""
    
    # Build QUL lookup: (surah, ayah) -> verse
    qul_lookup = {(v["surah"], v["ayah"]): v for v in qul_verses}
    
    differences = []
    exact_matches = 0
    normalized_matches = 0
    mismatches = 0
    missing_in_qul = 0
    
    print(f"\n🔍 Comparing {len(local_ayahs)} local ayahs against {len(qul_verses)} QUL verses...\n")
    
    for i, local_ayah in enumerate(local_ayahs):
        surah = local_ayah["surah_id"]
        ayah = local_ayah["ayah_number"]
        local_text = local_ayah["text_uthmani"]
        
        key = (surah, ayah)
        if key not in qul_lookup:
            missing_in_qul += 1
            continue
        
        qul_verse = qul_lookup[key]
        qul_text = qul_verse["text"]
        
        # Exact match check
        if local_text == qul_text:
            exact_matches += 1
            continue
        
        # Normalized match check (without diacritics)
        local_normalized = normalize_arabic(local_text)
        qul_normalized = normalize_arabic(qul_text)
        
        if local_normalized == qul_normalized:
            normalized_matches += 1
            # Still record as difference (diacritics matter!)
            differences.append({
                "surah": surah,
                "ayah": ayah,
                "local": local_text,
                "qul": qul_text,
                "match_type": "normalized_only",
            })
        else:
            mismatches += 1
            differences.append({
                "surah": surah,
                "ayah": ayah,
                "local": local_text,
                "qul": qul_text,
                "match_type": "mismatch",
            })
        
        # Fix if requested
        if fix_mode:
            local_ayahs[i]["text_uthmani"] = qul_text
    
    # Summary
    print("=" * 60)
    print("📊 VALIDATION RESULTS")
    print("=" * 60)
    print(f"✅ Exact matches:      {exact_matches:,} verses")
    print(f"⚠️  Diacritic only:    {normalized_matches:,} verses (need fix)")
    print(f"❌ Mismatches:         {mismatches:,} verses (need fix)")
    print(f"❓ Missing in QUL:     {missing_in_qul:,} verses")
    print("=" * 60)
    
    total_issues = normalized_matches + mismatches
    if total_issues == 0:
        print("\n🎉 ALL VERSES MATCH THE AUTHENTIC QUL TEXT!")
    else:
        print(f"\n⚠️  {total_issues} verses need correction\n")
        
        # Show first few differences
        print("First 5 differences:")
        for diff in differences[:5]:
            print(f"\n  [{diff['surah']}:{diff['ayah']}] ({diff['match_type']})")
            print(f"    Local: {diff['local'][:80]}...")
            print(f"    QUL:   {diff['qul'][:80]}...")
    
    return total_issues, differences


def main():
    fix_mode = "--fix" in sys.argv
    
    # Paths
    data_dir = Path(__file__).parent.parent.parent / "quran_vocab" / "assets" / "data"
    ayahs_path = data_dir / "ayahs_full.json"
    
    if not ayahs_path.exists():
        print(f"❌ Error: {ayahs_path} not found")
        print("   Run download_quran_data.py first to generate the data.")
        sys.exit(1)
    
    # Load data
    qul_verses = fetch_qul_data()
    local_ayahs = load_local_ayahs(ayahs_path)
    
    # Compare
    issues, differences = compare_verses(local_ayahs, qul_verses, fix_mode=fix_mode)
    
    if fix_mode and issues > 0:
        print("\n✏️  Applying fixes from QUL data...")
        with open(ayahs_path, "w", encoding="utf-8") as f:
            json.dump(local_ayahs, f, ensure_ascii=False, indent=2)
        print(f"   Saved corrected data to {ayahs_path.name}")
    
    # Save diff report
    if differences:
        report_path = data_dir / "validation_report.json"
        with open(report_path, "w", encoding="utf-8") as f:
            json.dump(differences, f, ensure_ascii=False, indent=2)
        print(f"\n📄 Detailed report saved to {report_path.name}")
    
    sys.exit(0 if issues == 0 else 1)


if __name__ == "__main__":
    main()
