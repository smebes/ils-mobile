import 'package:flutter_test/flutter_test.dart';
import 'package:sprachapp/sr_engine.dart';

void main() {
  final today = DateTime(2026, 7, 8);

  test('doğru cevap kutuyu yükseltir', () {
    final e = SrEntry.introduced(today);
    final up = applyAnswer(e, true, today);
    expect(up.box, 2);
    expect(up.nextReview, today.add(const Duration(days: 3)));
  });

  test('aynı gün ikinci doğru cevap kutuyu TERFİ ETTİRMEZ', () {
    final e = SrEntry.introduced(today);
    final once = applyAnswer(e, true, today); // 1→2, nextReview = +3 gün
    expect(once.box, 2);
    final twice = applyAnswer(once, true, today);
    expect(twice.box, 2); // aynı gün tekrar terfi yok
    expect(twice.totalAttempts, 2);
    expect(twice.correctStreak, 2);
  });

  test('yanlış sonrası aynı gün doğru tekrar terfi edebilir', () {
    final e = SrEntry(box: 3, nextReview: today, totalAttempts: 2);
    final down = applyAnswer(e, false, today);
    expect(down.box, 1);
    expect(down.nextReview, today); // hemen due
    final up = applyAnswer(down, true, today);
    expect(up.box, 2);
  });

  test('yanlış cevap kutuyu 1\'e düşürür', () {
    final e = SrEntry(box: 3, nextReview: today);
    final down = applyAnswer(e, false, today);
    expect(down.box, 1);
    expect(down.wrongCount, 1);
  });

  test('hakimiyet sadece kutu 4-5', () {
    final sr = {
      'a': SrEntry(box: 5, nextReview: today),
      'b': SrEntry(box: 3, nextReview: today),
      'c': SrEntry(box: 4, nextReview: today),
    };
    expect(masteryFraction(sr, 3), closeTo(2 / 3, 0.001));
  });

  test('günlük kuyruk yeni kelimeleri içerir', () {
    final q = buildDailyQueue(
      allWords: ['Apfel', 'Banane', 'Brot'],
      sr: {},
      today: today,
      targetSize: 3,
    );
    expect(q.length, 3);
    expect(q, contains('Apfel'));
  });
}
