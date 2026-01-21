import 'package:flutter_test/flutter_test.dart';

import 'package:quran_vocab/services/srs/fsrs.dart';

void main() {
  test('retrievability reaches 0.9 at stability interval', () {
    const params = FSRSParameters(weights: [2, 1, 0, 0, 0, 0, 0, 0]);
    final fsrs = FSRS(parameters: params);
    final review = fsrs.review(
      stability: 10,
      difficulty: 5,
      rating: 3,
      elapsedDays: 10,
    );
    expect(review.retrievability, closeTo(0.9, 1e-6));
  });

  test('difficulty updates with rating and clamps', () {
    const params = FSRSParameters(weights: [2, 1, 0, 0, 0, 0, 0, 0.5]);
    final fsrs = FSRS(parameters: params);

    final hard = fsrs.review(
      stability: 8,
      difficulty: 5,
      rating: 2,
      elapsedDays: 8,
    );
    expect(hard.difficulty, closeTo(4.5, 1e-6));

    final easy = fsrs.review(
      stability: 8,
      difficulty: 5,
      rating: 4,
      elapsedDays: 8,
    );
    expect(easy.difficulty, closeTo(5.5, 1e-6));
  });

  test('stability response for again rating uses base formula', () {
    const params = FSRSParameters(weights: [2, 1, 0, 0, 0, 0, 0, 0]);
    final fsrs = FSRS(parameters: params);
    final review = fsrs.review(
      stability: 8,
      difficulty: 4,
      rating: 1,
      elapsedDays: 8,
    );
    expect(review.stability, closeTo(8.0, 1e-6));
  });
}
