import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprachapp/content_repository.dart';
import 'package:sprachapp/curriculum.dart';
import 'package:sprachapp/progress_store.dart';
import 'package:sprachapp/slice_map.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('L2 schritte dilimleri A/B/C', () {
    expect(maxSlicesForLektion(2), 3);
    expect(schritteForSlice(1, lektionId: 2), ['A']);
    expect(schritteForSlice(2, lektionId: 2), ['B']);
    expect(schritteForSlice(3, lektionId: 2), ['C']);
    expect(schritteThroughSlice(2, lektionId: 2), ['A', 'B']);
  });

  test('ContentRepo: L2 %80 ile açılır', () {
    final repo = ContentRepository();
    expect(repo.hasContent(2), isTrue);
    expect(repo.isUnlocked(2, 0.79), isFalse);
    expect(repo.isUnlocked(2, 0.8), isTrue);
    expect(repo.isUnlocked(3, 1.0), isFalse); // içerik yok
  });

  test('L2 asset JSON yüklenir', () async {
    final repo = ContentRepository();
    final l = await repo.loadLektion(id: 2);
    expect(l.id, 2);
    expect(l.titel, contains('Familie'));
    expect(l.vocab.length, greaterThanOrEqualTo(20));
    expect(l.vocab.any((v) => v.wort == 'Mutter'), isTrue);

    final ex = await repo.loadExercises(id: 2);
    expect(ex.length, greaterThanOrEqualTo(10));
    expect(ex.every((e) => e.lektionId == 2), isTrue);
    expect(ex.any((e) => e.schritt == 'A'), isTrue);
    expect(ex.any((e) => e.schritt == 'C'), isTrue);
  });

  test('masteryOfWords L1 kapsamı — unlock eşiği', () async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final sr = <String, dynamic>{};
    for (var i = 0; i < 8; i++) {
      sr['w$i'] = {
        'box': 4,
        'nextReview': '${today}T00:00:00.000',
        'correctStreak': 3,
        'totalAttempts': 4,
        'wrongCount': 0,
      };
    }
    SharedPreferences.setMockInitialValues({
      'sr_entries_v2': json.encode(sr),
    });
    final store = ProgressStore();
    await store.init();
    final words = List.generate(10, (i) => 'w$i');
    expect(store.masteryOfWords(words), 0.8);
  });

  test('slicesDoneForLektion L2 boş vocab', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ProgressStore();
    await store.init();
    expect(kL2SliceTitlesDe.length, 3);
    expect(slicesDoneForLektion(store, const [], 2), 0);
  });
}
