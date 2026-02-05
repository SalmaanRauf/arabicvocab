# UX Overview

## Purpose
Provide a single, authoritative UX reference for the product. This document defines the information architecture, navigation model, key user flows, design direction, tokens, and screen-by-screen wireframe specs.

## Product Positioning
A focused daily habit app for Quran study that combines:
- Daily lessons (short, 5–10 minutes)
- Quran reading with word-by-word definitions
- Audio playback with word-level highlighting
- Review and progress tracking

The UX prioritizes calm focus, clarity, and repeatable daily use.

---

## Information Architecture

### Primary Areas
- **Home**: daily hub and quick actions
- **Quran**: reader hub and navigation
- **Daily**: daily lesson stream and history
- **Review**: spaced repetition and flashcards
- **Progress**: streaks and completion

### Supporting Areas
- **Saved**: saved lessons, ayahs, words
- **Settings**: script, translation, theme, audio controls

---

## Navigation Model

### Bottom Navigation (Primary)
- Home
- Quran
- Daily
- Review
- Progress

### Secondary Navigation
- Settings in overflow menu or top-right icon
- Saved as tab inside a dedicated Saved screen, accessed from Home quick actions

### Deep Links
- Daily lesson ayah tap can open Reader anchored to that ayah
- Saved lesson tap opens Daily Lesson view on that lesson

---

## Core User Flows

### Daily Habit Flow
1. Open app → Home
2. Tap "Today’s Lesson" card
3. Read ayahs (word-by-word + translation)
4. Load surah audio (once) → play ayah
5. Read reflection and takeaways
6. Mark complete → streak updates

### Study Flow
1. Home → Quran
2. Select surah → Reader
3. Word-by-word study, audio playback, save ayah

### Review Flow
1. Home → Review
2. Choose deck (Due / Weak / Saved)
3. Answer cards → rating
4. See updated progress

---

## Visual Design Direction

### Tone
Calm, reverent, editorial clarity. Not flashy. Prioritize legibility and focus.

### Typography
- **Headings**: `Sora` or `Manrope` (semibold)
- **Body**: `Lora` (regular)
- **Arabic**: Quran font (Lateef or PDMS Saleem) for scripture only

### Color Tokens
**Light**
- Background: `#F7F4EF`
- Surface: `#FFFFFF`
- Primary: `#2E8B7E`
- Primary Dark: `#1F5E55`
- Accent Gold: `#C8A25E`
- Text Primary: `#1E1E1E`
- Text Secondary: `#5A5A5A`
- Border: `#E6E2DA`

**Dark**
- Background: `#141413`
- Surface: `#1E1D1B`
- Primary: `#3FAE9A`
- Accent Gold: `#D5B36C`
- Text Primary: `#F8F5EF`
- Text Secondary: `#B6B2A9`
- Border: `#2C2A26`

### Spacing
- Base: 8px
- Section: 24px
- Card padding: 16–20px

### Components Styling
- Cards: 12–16px radius, subtle shadow
- Buttons: 12px radius
- Chips: 999px radius

---

## Screen Wireframes (Textual)

### Home (Dashboard)
1. App Bar: title + theme toggle + overflow
2. Hero: Today’s Lesson card (title + ayah range + CTA)
3. Continue Reading card
4. Quick Actions grid (Daily, Quran, Review, Saved, Progress)
5. Progress Snapshot (streak + chart)
6. Optional spotlight section

### Quran Hub
1. Search
2. Tabs: Surahs | Juz | Bookmarks
3. Surah list
4. Resume pill

### Reader
1. App bar: surah title, script toggle, translation toggle
2. Audio row: Load surah audio
3. Ayah cards: Arabic + translation + word-by-word + play

### Daily Lesson
1. Header card: Day #, streak, title
2. Actions: Mark complete + Save
3. Audio card: Load audio
4. Verse section: Ayah cards
5. Reflection card: short + expand
6. Takeaways card
7. Source (collapsed)
8. Past lessons + catch-up

### Review
1. Deck selection
2. Flashcard
3. Rating buttons
4. Progress indicator

### Progress
1. Weekly streak chart
2. Completion %
3. Vocabulary coverage

### Saved
1. Tabs: Lessons | Ayahs | Words
2. List view with quick open

---

## Onboarding
1. Choose script (Uthmani / IndoPak)
2. Choose translation
3. Enable daily reminders (optional)

---

## Empty / Loading / Error Copy

**Empty**
- Saved: “No saved items yet. Save one from Daily.”
- Review: “You’re caught up. Come back tomorrow.”

**Loading**
- Skeleton cards for Home and Daily

**Error**
- “Could not load lesson. Tap to retry.”

---

## Related Specs
- `docs/ux/COMPONENT_SPECS.md`
