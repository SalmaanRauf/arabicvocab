import 'dart:math';

class FSRSParameters {
  const FSRSParameters({
    required this.weights,
    this.requestRetention = 0.9,
    this.maximumInterval = 36500,
    this.factor = 19 / 81,
    this.decay = -0.5,
  });

  final List<double> weights;
  final double requestRetention;
  final int maximumInterval;
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
            // Official FSRS-5 default weights from open-spaced-repetition
            const FSRSParameters(
              weights: <double>[
                0.4072, // w0: initial stability for Again
                1.1829, // w1: initial stability for Hard
                3.1262, // w2: initial stability for Good
                15.4722, // w3: initial stability for Easy
                7.2102, // w4: difficulty weight
                0.5316, // w5: difficulty weight
                1.0651, // w6: difficulty weight
                0.0234, // w7: difficulty weight
                1.616, // w8: stability decay
                0.1544, // w9: stability weight
                1.0824, // w10: stability weight
                1.9813, // w11: stability weight
                0.0953, // w12: stability weight
                0.2975, // w13: forgetting weight
                2.2042, // w14: forgetting weight
                0.2407, // w15: forgetting weight
                2.9466, // w16: forgetting weight
                0.5034, // w17: same-day review weight
                0.6567, // w18: same-day review weight
              ],
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
