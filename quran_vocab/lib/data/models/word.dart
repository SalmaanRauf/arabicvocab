class Word {
  const Word({
    required this.id,
    required this.ayahId,
    required this.position,
    required this.textUthmani,
    required this.textIndopak,
    required this.translationEn,
    required this.transliteration,
    required this.rootId,
    required this.lemmaId,
    required this.audioStartMs,
    required this.audioEndMs,
  });

  final int id;
  final int ayahId;
  final int position;
  final String textUthmani;
  final String textIndopak;
  final String translationEn;
  final String transliteration;
  final int? rootId;
  final int? lemmaId;
  final int? audioStartMs;
  final int? audioEndMs;

  factory Word.fromMap(Map<String, Object?> map) {
    return Word(
      id: map['id'] as int,
      ayahId: map['ayah_id'] as int? ?? 0,
      position: map['position'] as int? ?? 0,
      textUthmani: map['text_uthmani'] as String? ?? '',
      textIndopak: map['text_indopak'] as String? ?? '',
      translationEn: map['translation_en'] as String? ?? '',
      transliteration: map['transliteration'] as String? ?? '',
      rootId: map['root_id'] as int?,
      lemmaId: map['lemma_id'] as int?,
      audioStartMs: map['audio_start_ms'] as int?,
      audioEndMs: map['audio_end_ms'] as int?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'ayah_id': ayahId,
      'position': position,
      'text_uthmani': textUthmani,
      'text_indopak': textIndopak,
      'translation_en': translationEn,
      'transliteration': transliteration,
      'root_id': rootId,
      'lemma_id': lemmaId,
      'audio_start_ms': audioStartMs,
      'audio_end_ms': audioEndMs,
    };
  }
}
