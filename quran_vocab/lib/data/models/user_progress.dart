enum SrsStage {
  newlyIntroduced,
  learning,
  review,
}

class UserProgress {
  const UserProgress({
    required this.rootId,
    required this.stage,
    required this.stability,
    required this.difficulty,
    required this.nextReviewDate,
  });

  final int rootId;
  final SrsStage stage;
  final double stability;
  final double difficulty;
  final DateTime nextReviewDate;

  factory UserProgress.fromMap(Map<String, Object?> map) {
    final stageRaw = map['srs_stage'] as String? ?? 'new';
    return UserProgress(
      rootId: map['root_id'] as int,
      stage: _parseStage(stageRaw),
      stability: (map['stability'] as num?)?.toDouble() ?? 0,
      difficulty: (map['difficulty'] as num?)?.toDouble() ?? 0,
      nextReviewDate:
          DateTime.tryParse(map['next_review_date'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'root_id': rootId,
      'srs_stage': _stageToString(stage),
      'stability': stability,
      'difficulty': difficulty,
      'next_review_date': nextReviewDate.toIso8601String(),
    };
  }

  static SrsStage _parseStage(String value) {
    switch (value) {
      case 'learning':
        return SrsStage.learning;
      case 'review':
        return SrsStage.review;
      case 'new':
      default:
        return SrsStage.newlyIntroduced;
    }
  }

  static String _stageToString(SrsStage stage) {
    switch (stage) {
      case SrsStage.learning:
        return 'learning';
      case SrsStage.review:
        return 'review';
      case SrsStage.newlyIntroduced:
        return 'new';
    }
  }
}
