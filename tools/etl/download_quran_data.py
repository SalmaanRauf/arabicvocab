#!/usr/bin/env python3
"""Download Quran data from free APIs and save as JSON for the Flutter app."""
import json
import urllib.request
from pathlib import Path


def fetch_json(url: str) -> dict:
    """Fetch JSON from a URL."""
    req = urllib.request.Request(url, headers={"User-Agent": "QuranVocabApp/1.0"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


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
    """Download word-by-word data from quranwbw API."""
    print("Downloading word-by-word data...")
    words = []
    
    # Download WBW for each surah (using quran.com's API structure)
    for surah_num in range(1, 115):
        print(f"  Surah {surah_num}/114...", end="\r")
        try:
            url = f"https://api.quran.com/api/v4/quran/verses/uthmani?chapter_number={surah_num}"
            data = fetch_json(url)
            
            # Get words for this surah
            words_url = f"https://api.quran.com/api/v4/quran/verses/words?chapter_number={surah_num}"
            words_data = fetch_json(words_url)
            
            # Process words
            if "verses" in words_data:
                for verse in words_data["verses"]:
                    verse_key = verse.get("verse_key", "")
                    parts = verse_key.split(":")
                    if len(parts) == 2:
                        ayah_num = int(parts[1])
                        for pos, word in enumerate(verse.get("words", []), 1):
                            if word.get("char_type_name") == "word":
                                words.append({
                                    "surah_id": surah_num,
                                    "ayah_number": ayah_num,
                                    "position": pos,
                                    "text_uthmani": word.get("text_uthmani", ""),
                                    "translation_en": word.get("translation", {}).get("text", ""),
                                    "transliteration": word.get("transliteration", {}).get("text", ""),
                                    "root": "",  # Root data requires separate lookup
                                    "frequency": 1,
                                })
        except Exception as e:
            print(f"  Warning: Failed to get words for surah {surah_num}: {e}")
    
    print("  Done!                    ")
    return words


def main():
    output_dir = Path("quran_vocab/assets/data")
    output_dir.mkdir(parents=True, exist_ok=True)
    
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
    print(f"Saved {len(words)} words")
    
    print("\nDone! Data saved to quran_vocab/assets/data/")


if __name__ == "__main__":
    main()
