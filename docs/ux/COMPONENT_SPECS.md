# Component Specs

This document defines reusable components, variants, and interaction states.

---

## Global Components

### AppBar
**Purpose:** Top navigation and key actions.
- **Props:** title, actions[], showBack
- **Variants:** Default, Back
- **States:** default
- **Constraints:** 56px height, 16px horizontal padding

### BottomNav
**Purpose:** Primary navigation between Home/Quran/Daily/Review/Progress.
- **Items:** 5 items max
- **States:** active, inactive
- **Constraints:** 56px height, icons 24px

### Card
**Purpose:** Base container for content blocks.
- **Variants:** Standard, Highlight
- **States:** default, loading
- **Constraints:** 12–16px radius, 16–20px padding

### Button
**Purpose:** Primary actions.
- **Variants:** Primary, Secondary, Ghost
- **States:** default, hover, disabled, loading
- **Constraints:** 44px min height

### Chip
**Purpose:** Status badges (streak, tags).
- **Variants:** Info, Success
- **States:** default

### SectionHeader
**Purpose:** Section labels in lists.
- **Props:** title, actionText (optional)

---

## Feature Components

### TodayLessonCard
- **Props:** title, surahRange, eta, onOpen
- **States:** default, loading, error
- **Notes:** Primary CTA: “Open lesson”

### ContinueReadingCard
- **Props:** surahName, ayahNumber, onResume
- **States:** default, loading

### AyahCard
- **Props:** ayahNumber, arabicText, translation, words[], onPlay
- **States:** default, loading, error
- **Constraints:** RTL layout for Arabic, LTR for translation

### AudioLoadButton
- **Props:** surahId, isLoaded, onLoad
- **States:** idle, loading, loaded, disabled

### WordChip
- **Props:** arabic, transliteration, translation, onTap
- **States:** default, highlighted

### ReflectionPanel
- **Props:** bodyShort, bodyFull, expanded
- **States:** collapsed, expanded

### TakeawayList
- **Props:** items[] (1–2)
- **States:** default

### HistoryList
- **Props:** entries[] (date, title, status)
- **States:** default, empty

---

## Interaction States

### Loading
- Skeleton cards for Home + Daily
- Inline spinner for audio load

### Empty
- Saved: “No saved items yet. Save one from Daily.”
- Review: “You’re caught up. Come back tomorrow.”

### Error
- Daily: “Could not load lesson. Tap to retry.”

---

## Accessibility
- Minimum 44px tap targets
- RTL support for Arabic
- High-contrast light/dark modes
- Scalable font sizes for Arabic and body text

---

## Related Docs
- `docs/ux/UX_OVERVIEW.md`
