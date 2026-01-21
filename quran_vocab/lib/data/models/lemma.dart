class Lemma {
  const Lemma({
    required this.id,
    required this.lemmaText,
    required this.rootId,
    required this.frequencyRank,
  });

  final int id;
  final String lemmaText;
  final int? rootId;
  final int frequencyRank;

  factory Lemma.fromMap(Map<String, Object?> map) {
    return Lemma(
      id: map['id'] as int,
      lemmaText: map['lemma_text'] as String? ?? '',
      rootId: map['root_id'] as int?,
      frequencyRank: map['frequency_rank'] as int? ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'lemma_text': lemmaText,
      'root_id': rootId,
      'frequency_rank': frequencyRank,
    };
  }
}
