/// Curriculum models for structured learning paths.
///
/// Units contain lessons, lessons contain vocabulary or surah references.
class Unit {
  const Unit({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCoverage,
    required this.lessons,
  });

  final int id;
  final String title;
  final String description;
  final int targetCoverage;
  final List<Lesson> lessons;

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      targetCoverage: json['targetCoverage'] as int? ?? 0,
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get totalWordCount =>
      lessons.fold(0, (sum, lesson) => sum + lesson.wordCount);
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    this.surahId,
    this.ayahRange,
    this.vocabulary,
    required this.wordCount,
  });

  final int id;
  final String title;
  final String description;
  final int? surahId;
  final List<int>? ayahRange;
  final List<String>? vocabulary;
  final int wordCount;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      surahId: json['surahId'] as int?,
      ayahRange: (json['ayahRange'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      vocabulary: (json['vocabulary'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      wordCount: json['wordCount'] as int? ?? 0,
    );
  }

  /// Whether this lesson is based on a specific surah's verses.
  bool get isSurahBased => surahId != null && ayahRange != null;
}
