class Surah {
  const Surah({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.verseCount,
    required this.type,
  });

  final int id;
  final String nameArabic;
  final String nameEnglish;
  final int verseCount;
  final String type;

  factory Surah.fromMap(Map<String, Object?> map) {
    return Surah(
      id: map['id'] as int,
      nameArabic: map['name_arabic'] as String? ?? '',
      nameEnglish: map['name_english'] as String? ?? '',
      verseCount: map['verse_count'] as int? ?? 0,
      type: map['type'] as String? ?? '',
    );
  }

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'] as int,
      nameArabic: json['name_arabic'] as String? ?? '',
      nameEnglish: json['name_english'] as String? ?? '',
      verseCount: json['verse_count'] as int? ?? 0,
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name_arabic': nameArabic,
      'name_english': nameEnglish,
      'verse_count': verseCount,
      'type': type,
    };
  }
}
