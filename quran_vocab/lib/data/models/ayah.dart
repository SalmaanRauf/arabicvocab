class Ayah {
  const Ayah({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.textUthmani,
    required this.textIndopak,
    required this.translationEn,
  });

  final int id;
  final int surahId;
  final int ayahNumber;
  final String textUthmani;
  final String textIndopak;
  final String translationEn;

  factory Ayah.fromMap(Map<String, Object?> map) {
    return Ayah(
      id: map['id'] as int,
      surahId: map['surah_id'] as int? ?? 0,
      ayahNumber: map['ayah_number'] as int? ?? 0,
      textUthmani: map['text_uthmani'] as String? ?? '',
      textIndopak: map['text_indopak'] as String? ?? '',
      translationEn: map['translation_en'] as String? ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'text_uthmani': textUthmani,
      'text_indopak': textIndopak,
      'translation_en': translationEn,
    };
  }
}
