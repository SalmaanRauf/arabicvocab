#!/usr/bin/env python3
"""Download Quran data from free APIs and save as JSON for the Flutter app.

Usage:
    python3 download_quran_data.py           # Download surahs, ayahs, and words
    python3 download_quran_data.py --words-only  # Only download word-by-word data
"""
import json
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

# Surah names for progress display
SURAH_NAMES = [
    "", "Al-Fatiha", "Al-Baqarah", "Aal-E-Imran", "An-Nisa", "Al-Ma'idah",
    "Al-An'am", "Al-A'raf", "Al-Anfal", "At-Tawbah", "Yunus", "Hud", "Yusuf",
    "Ar-Ra'd", "Ibrahim", "Al-Hijr", "An-Nahl", "Al-Isra", "Al-Kahf", "Maryam",
    "Ta-Ha", "Al-Anbiya", "Al-Hajj", "Al-Mu'minun", "An-Nur", "Al-Furqan",
    "Ash-Shu'ara", "An-Naml", "Al-Qasas", "Al-Ankabut", "Ar-Rum", "Luqman",
    "As-Sajdah", "Al-Ahzab", "Saba", "Fatir", "Ya-Sin", "As-Saffat", "Sad",
    "Az-Zumar", "Ghafir", "Fussilat", "Ash-Shura", "Az-Zukhruf", "Ad-Dukhan",
    "Al-Jathiyah", "Al-Ahqaf", "Muhammad", "Al-Fath", "Al-Hujurat", "Qaf",
    "Adh-Dhariyat", "At-Tur", "An-Najm", "Al-Qamar", "Ar-Rahman", "Al-Waqi'ah",
    "Al-Hadid", "Al-Mujadila", "Al-Hashr", "Al-Mumtahina", "As-Saff", "Al-Jumu'ah",
    "Al-Munafiqun", "At-Taghabun", "At-Talaq", "At-Tahrim", "Al-Mulk", "Al-Qalam",
    "Al-Haqqah", "Al-Ma'arij", "Nuh", "Al-Jinn", "Al-Muzzammil", "Al-Muddaththir",
    "Al-Qiyamah", "Al-Insan", "Al-Mursalat", "An-Naba", "An-Nazi'at", "Abasa",
    "At-Takwir", "Al-Infitar", "Al-Mutaffifin", "Al-Inshiqaq", "Al-Buruj", "At-Tariq",
    "Al-A'la", "Al-Ghashiyah", "Al-Fajr", "Al-Balad", "Ash-Shams", "Al-Layl",
    "Ad-Duha", "Ash-Sharh", "At-Tin", "Al-Alaq", "Al-Qadr", "Al-Bayyinah",
    "Az-Zalzalah", "Al-Adiyat", "Al-Qari'ah", "At-Takathur", "Al-Asr", "Al-Humazah",
    "Al-Fil", "Quraysh", "Al-Ma'un", "Al-Kawthar", "Al-Kafirun", "An-Nasr",
    "Al-Masad", "Al-Ikhlas", "Al-Falaq", "An-Nas"
]


def fetch_json(url: str, retries: int = 3) -> dict:
    """Fetch JSON from a URL with retry logic."""
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "QuranVocabApp/1.0"})
            with urllib.request.urlopen(req, timeout=30) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except (urllib.error.URLError, urllib.error.HTTPError) as e:
            if attempt < retries - 1:
                wait = 2 ** attempt  # Exponential backoff: 1s, 2s, 4s
                print(f"  Retry {attempt + 1}/{retries} after {wait}s: {e}")
                time.sleep(wait)
            else:
                raise


def download_surahs() -> list[dict]:
    """Download surah metadata from alquran.cloud API."""
    print("Downloading surah metadata...")
    data = fetch_json("https://api.alquran.cloud/v1/surah")
    surahs = []
    for s in data["data"]:
        surahs.append({
            "id": s["number"],
            "name_arabic": s["name"],
            "name_english": s["englishName"],
            "verse_count": s["numberOfAyahs"],
            "type": s["revelationType"],
        })
    return surahs


def download_ayahs() -> list[dict]:
    """Download all ayahs with Arabic text and English translation."""
    print("Downloading ayahs (this may take a minute)...")
    # Get Arabic text (Uthmani)
    arabic_data = fetch_json("https://api.alquran.cloud/v1/quran/quran-uthmani")
    # Get English translation
    english_data = fetch_json("https://api.alquran.cloud/v1/quran/en.sahih")
    
    ayahs = []
    arabic_surahs = {s["number"]: s for s in arabic_data["data"]["surahs"]}
    english_surahs = {s["number"]: s for s in english_data["data"]["surahs"]}
    
    for surah_num in range(1, 115):
        arabic_surah = arabic_surahs[surah_num]
        english_surah = english_surahs[surah_num]
        
        for i, ayah in enumerate(arabic_surah["ayahs"]):
            ayahs.append({
                "surah_id": surah_num,
                "ayah_number": ayah["numberInSurah"],
                "text_uthmani": ayah["text"],
                "text_indopak": ayah["text"],  # Using same for now
                "translation_en": english_surah["ayahs"][i]["text"],
            })
    return ayahs


def download_words() -> list[dict]:
    """Download word-by-word data from quran.com API for all 114 surahs."""
    print("Downloading word-by-word data for all 114 surahs...")
    words = []
    total_words = 0
    
    for surah_num in range(1, 115):
        surah_name = SURAH_NAMES[surah_num] if surah_num < len(SURAH_NAMES) else f"Surah {surah_num}"
        print(f"  [{surah_num:3}/114] {surah_name}...", end="", flush=True)
        
        surah_words = []
        page = 1
        
        while True:
            try:
                # Use word_fields to get text_uthmani, and per_page for pagination
                url = (
                    f"https://api.quran.com/api/v4/verses/by_chapter/{surah_num}"
                    f"?words=true&word_fields=text_uthmani&per_page=50&page={page}"
                )
                data = fetch_json(url)
                
                for verse in data.get("verses", []):
                    verse_key = verse.get("verse_key", "")
                    parts = verse_key.split(":")
                    if len(parts) != 2:
                        continue
                    
                    ayah_num = int(parts[1])
                    position = 0
                    
                    for word in verse.get("words", []):
                        # Skip verse number markers (char_type_name: "end")
                        if word.get("char_type_name") != "word":
                            continue
                        
                        position += 1
                        translation = word.get("translation", {})
                        transliteration = word.get("transliteration", {})
                        
                        surah_words.append({
                            "surah_id": surah_num,
                            "ayah_number": ayah_num,
                            "position": position,
                            "text_uthmani": word.get("text_uthmani", word.get("text", "")),
                            "translation_en": translation.get("text", "") if translation else "",
                            "transliteration": transliteration.get("text", "") if transliteration else "",
                            "root": "",  # Root data requires separate morphology lookup
                            "frequency": 1,
                        })
                
                # Check pagination
                pagination = data.get("pagination", {})
                if pagination.get("next_page") is None:
                    break
                page += 1
                
            except Exception as e:
                print(f" ERROR: {e}")
                break
        
        words.extend(surah_words)
        total_words += len(surah_words)
        print(f" {len(surah_words)} words")
        
        # Rate limiting: 0.3s delay between surahs to be nice to the API
        if surah_num < 114:
            time.sleep(0.3)
    
    print(f"\nTotal words downloaded: {total_words}")
    return words


def main():
    words_only = "--words-only" in sys.argv
    
    output_dir = Path(__file__).parent.parent.parent / "quran_vocab" / "assets" / "data"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    if not words_only:
        # Download and save surahs
        surahs = download_surahs()
        (output_dir / "surahs.json").write_text(json.dumps(surahs, ensure_ascii=False, indent=2))
        print(f"Saved {len(surahs)} surahs")
        
        # Download and save ayahs
        ayahs = download_ayahs()
        (output_dir / "ayahs_full.json").write_text(json.dumps(ayahs, ensure_ascii=False, indent=2))
        print(f"Saved {len(ayahs)} ayahs")
    
    # Download and save words
    words = download_words()
    (output_dir / "words_full.json").write_text(json.dumps(words, ensure_ascii=False, indent=2))
    print(f"Saved {len(words)} words to words_full.json")
    
    print("\nDone! Data saved to quran_vocab/assets/data/")


if __name__ == "__main__":
    main()
