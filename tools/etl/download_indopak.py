#!/usr/bin/env python3
"""
Download authentic IndoPak Quran text from quran.com API 
and update ayahs_full.json with the correct text_indopak values.
"""

import json
import urllib.request
import time
from pathlib import Path

# Paths
SCRIPT_DIR = Path(__file__).parent
ASSETS_DIR = SCRIPT_DIR.parent.parent / 'quran_vocab' / 'assets' / 'data'
AYAHS_FILE = ASSETS_DIR / 'ayahs_full.json'

# API endpoint
API_BASE = 'https://api.quran.com/api/v4/quran/verses/indopak'

def fetch_indopak_for_surah(surah_number: int) -> dict:
    """Fetch IndoPak text for a single surah, returns dict of verse_key -> text"""
    url = f"{API_BASE}?chapter_number={surah_number}"
    
    req = urllib.request.Request(url, headers={'User-Agent': 'QuranVocabApp/1.0'})
    with urllib.request.urlopen(req, timeout=30) as response:
        data = json.loads(response.read().decode('utf-8'))
    
    result = {}
    for verse in data.get('verses', []):
        verse_key = verse['verse_key']  # e.g., "1:2"
        text = verse['text_indopak']
        result[verse_key] = text
    
    return result

def main():
    print("IndoPak Text Updater")
    print("=" * 50)
    
    # Load existing ayahs
    print(f"Loading {AYAHS_FILE}...")
    with open(AYAHS_FILE, 'r', encoding='utf-8') as f:
        ayahs = json.load(f)
    
    print(f"Found {len(ayahs)} ayahs")
    
    # Build lookup: verse_key -> ayah index
    ayah_lookup = {}
    for i, ayah in enumerate(ayahs):
        key = f"{ayah['surah_id']}:{ayah['ayah_number']}"
        ayah_lookup[key] = i
    
    # Download IndoPak text for each surah
    total_updated = 0
    
    for surah_num in range(1, 115):
        print(f"Fetching Surah {surah_num}/114...", end=' ', flush=True)
        
        try:
            indopak_texts = fetch_indopak_for_surah(surah_num)
            updated_count = 0
            
            for verse_key, text in indopak_texts.items():
                if verse_key in ayah_lookup:
                    idx = ayah_lookup[verse_key]
                    ayahs[idx]['text_indopak'] = text
                    updated_count += 1
            
            print(f"✓ {updated_count} verses updated")
            total_updated += updated_count
            
            # Rate limiting - be nice to the API
            time.sleep(0.1)
            
        except Exception as e:
            print(f"✗ Error: {e}")
            continue
    
    print("=" * 50)
    print(f"Total verses updated: {total_updated}")
    
    # Save updated file
    print(f"Saving to {AYAHS_FILE}...")
    with open(AYAHS_FILE, 'w', encoding='utf-8') as f:
        json.dump(ayahs, f, ensure_ascii=False, indent=2)
    
    print("Done! IndoPak text has been updated.")
    
    # Show sample
    print("\nSample (Al-Fatiha 1:6):")
    for ayah in ayahs:
        if ayah['surah_id'] == 1 and ayah['ayah_number'] == 6:
            print(f"  Uthmani: {ayah['text_uthmani']}")
            print(f"  IndoPak: {ayah['text_indopak']}")
            break

if __name__ == '__main__':
    main()
