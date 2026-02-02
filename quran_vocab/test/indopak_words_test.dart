import 'package:flutter_test/flutter_test.dart';

import 'package:quran_vocab/data/data_loader.dart';

void main() {
  test('DataLoader uses IndoPak word text from assets', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final loader = DataLoader.instance;
    await loader.load();

    final ayah6 = loader
        .getAyahsForSurah(1)
        .firstWhere((ayah) => ayah.ayahNumber == 6);
    final words = loader.getWordsForAyah(ayah6.id);
    final firstWord = words.firstWhere((word) => word.position == 1);

    // Expect IndoPak text from PDMS Saleem dataset.
    expect(firstWord.textIndopak, 'اِهۡدِنَا');
  });
}
