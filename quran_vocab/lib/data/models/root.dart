class Root {
  const Root({
    required this.id,
    required this.rootText,
    required this.frequencyCount,
    required this.meaningShort,
    required this.meaningLong,
  });

  final int id;
  final String rootText;
  final int frequencyCount;
  final String meaningShort;
  final String meaningLong;

  factory Root.fromMap(Map<String, Object?> map) {
    return Root(
      id: map['id'] as int,
      rootText: map['root_text'] as String? ?? '',
      frequencyCount: map['frequency_count'] as int? ?? 0,
      meaningShort: map['meaning_short'] as String? ?? '',
      meaningLong: map['meaning_long'] as String? ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'root_text': rootText,
      'frequency_count': frequencyCount,
      'meaning_short': meaningShort,
      'meaning_long': meaningLong,
    };
  }
}
