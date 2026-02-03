import 'package:flutter_test/flutter_test.dart';

import 'package:quran_vocab/services/audio/audio_manager.dart';

void main() {
  test('buildAyahUrl pads surah and ayah numbers', () {
    final url = AudioManager.buildAyahUrl(1, 3);
    expect(
      url,
      'https://everyayah.com/data/Alafasy_128kbps/001003.mp3',
    );
  });

  test('buildSurahUrls generates ordered ayah urls', () {
    final urls = AudioManager.buildSurahUrls(2, 3);
    expect(urls, [
      'https://everyayah.com/data/Alafasy_128kbps/002001.mp3',
      'https://everyayah.com/data/Alafasy_128kbps/002002.mp3',
      'https://everyayah.com/data/Alafasy_128kbps/002003.mp3',
    ]);
  });
}
