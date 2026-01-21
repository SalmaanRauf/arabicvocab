class CurriculumEntry {
  const CurriculumEntry({
    required this.id,
    required this.lessonId,
    required this.rootId,
    required this.orderIndex,
  });

  final int id;
  final int lessonId;
  final int rootId;
  final int orderIndex;

  factory CurriculumEntry.fromMap(Map<String, Object?> map) {
    return CurriculumEntry(
      id: map['id'] as int,
      lessonId: map['lesson_id'] as int? ?? 0,
      rootId: map['root_id'] as int? ?? 0,
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'root_id': rootId,
      'order_index': orderIndex,
    };
  }
}
