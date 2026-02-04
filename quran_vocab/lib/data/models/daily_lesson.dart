class LessonSource {
  const LessonSource({
    required this.work,
    required this.author,
    required this.dataset,
    required this.version,
  });

  final String work;
  final String author;
  final String dataset;
  final String version;

  factory LessonSource.fromJson(Map<String, dynamic> json) {
    return LessonSource(
      work: json['work'] as String? ?? '',
      author: json['author'] as String? ?? '',
      dataset: json['dataset'] as String? ?? '',
      version: json['version'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'work': work,
      'author': author,
      'dataset': dataset,
      'version': version,
    };
  }
}

class DailyLesson {
  const DailyLesson({
    required this.id,
    required this.dayIndex,
    required this.surahId,
    required this.ayahStart,
    required this.ayahEnd,
    required this.verseKeys,
    required this.title,
    required this.bodyShort,
    required this.bodyFull,
    required this.takeaways,
    required this.tags,
    required this.source,
  });

  final String id;
  final int dayIndex;
  final int surahId;
  final int ayahStart;
  final int ayahEnd;
  final List<String> verseKeys;
  final String title;
  final String bodyShort;
  final String bodyFull;
  final List<String> takeaways;
  final List<String> tags;
  final LessonSource source;

  factory DailyLesson.fromJson(Map<String, dynamic> json) {
    return DailyLesson(
      id: json['id'] as String? ?? '',
      dayIndex: json['dayIndex'] as int? ?? 0,
      surahId: json['surahId'] as int? ?? 0,
      ayahStart: json['ayahStart'] as int? ?? 0,
      ayahEnd: json['ayahEnd'] as int? ?? 0,
      verseKeys:
          (json['verseKeys'] as List<dynamic>? ?? const []).cast<String>(),
      title: json['title'] as String? ?? '',
      bodyShort: json['bodyShort'] as String? ?? '',
      bodyFull: json['bodyFull'] as String? ?? '',
      takeaways:
          (json['takeaways'] as List<dynamic>? ?? const []).cast<String>(),
      tags: (json['tags'] as List<dynamic>? ?? const []).cast<String>(),
      source: LessonSource.fromJson(
        (json['source'] as Map<String, dynamic>? ?? const {}),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayIndex': dayIndex,
      'surahId': surahId,
      'ayahStart': ayahStart,
      'ayahEnd': ayahEnd,
      'verseKeys': verseKeys,
      'title': title,
      'bodyShort': bodyShort,
      'bodyFull': bodyFull,
      'takeaways': takeaways,
      'tags': tags,
      'source': source.toJson(),
    };
  }
}
