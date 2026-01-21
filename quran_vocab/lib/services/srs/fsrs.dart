import 'dart:math';

class FSRSParameters {
  const FSRSParameters({
    required this.weights,
    this.factor = 19 / 81,
    this.decay = -0.5,
  });

  final List<double> weights;
  final double factor;
  final double decay;
}

class FSRSReview {
  const FSRSReview({
    required this.stability,
    required this.difficulty,
    required this.nextIntervalDays,
    required this.retrievability,
  });

  final double stability;
  final double difficulty;
  final int nextIntervalDays;
  final double retrievability;
}

class FSRS {
  FSRS({
    FSRSParameters? parameters,
  }) : params = parameters ??
            const FSRSParameters(
              weights: <double>[2.0, 1.0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.5],
            );

  final FSRSParameters params;

  FSRSReview review({
    required double stability,
    required double difficulty,
    required int rating,
    double? elapsedDays,
  }) {
    final elapsed = elapsedDays ?? stability;
    final retrievability = _retrievability(elapsed, stability);
    final newDifficulty = _nextDifficulty(difficulty, rating);
    final newStability = _nextStability(
      stability: stability,
      difficulty: newDifficulty,
      retrievability: retrievability,
      rating: rating,
    );
    final nextInterval = _nextIntervalDays(newStability);
    return FSRSReview(
      stability: newStability,
      difficulty: newDifficulty,
      nextIntervalDays: nextInterval,
      retrievability: retrievability,
    );
  }

  double _retrievability(double elapsedDays, double stability) {
    return pow(1 + params.factor * elapsedDays / stability, params.decay)
        .toDouble();
  }

  double _nextDifficulty(double difficulty, int rating) {
    final delta = params.weights[7] * (rating - 3);
    final updated = difficulty + delta;
    return updated.clamp(1.0, 10.0);
  }

  double _nextStability({
    required double stability,
    required double difficulty,
    required double retrievability,
    required int rating,
  }) {
    if (rating <= 1) {
      return params.weights[0] *
          pow(difficulty, params.weights[1]) *
          pow(stability, params.weights[2]) *
          exp(params.weights[3] * (1 - retrievability));
    }
    final growth = exp(params.weights[4]) *
        (11 - difficulty) *
        pow(stability, -params.weights[5]) *
        (exp((1 - retrievability) * params.weights[6]) - 1);
    return stability * (1 + growth);
  }

  int _nextIntervalDays(double stability) {
    return max(1, stability.round());
  }
}
