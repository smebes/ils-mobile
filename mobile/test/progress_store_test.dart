import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprachapp/progress_store.dart';
import 'package:sprachapp/sr_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SR / hakimiyet — oturum simülasyonu', () {
    late ProgressStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = ProgressStore();
      await store.init();
    });

    test('introduceWord → localStorage (sr_entries_v2) yazılır', () async {
      await store.introduceWord('Hallo');
      expect(store.srEntries.containsKey('Hallo'), isTrue);
      expect(store.srEntries['Hallo']!.box, 1);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('sr_entries_v2');
      expect(raw, isNotNull);
      expect(raw!, contains('Hallo'));
    });

    test('tek doğru cevap kutuyu yükseltir ama hakimiyet hâlâ 0', () async {
      // PRODUCT: hakim = kutu 4–5. Bir oturumda en fazla 1→2.
      await store.introduceWord('Name');
      await store.recordAnswer('Name', true);

      expect(store.srEntries['Name']!.box, 2);
      expect(store.srEntries['Name']!.isMastered, isFalse);
      // 60 kelimelik L1'de tek kelime kutu 2 → Meisterschaft %0
      expect(store.masteryPct(60), 0.0);
      expect(store.masteredCount(60), 0);
    });

    test('üç doğru terfi → kutu 4 → hakimiyet artar', () async {
      await store.introduceWord('danke'); // box 1
      await store.recordAnswer('danke', true); // → 2
      await store.recordAnswer('danke', true); // → 3
      await store.recordAnswer('danke', true); // → 4 = mastered

      expect(store.srEntries['danke']!.box, 4);
      expect(store.srEntries['danke']!.isMastered, isTrue);
      expect(store.masteryPct(60), closeTo(1 / 60, 0.0001));
      expect(store.masteredCount(60), 1);
    });

    test('XP oturum sonunda artar', () async {
      expect(store.xp, 0);
      await store.addXp(50);
      expect(store.xp, 50);
      expect(store.level, 1);
    });

    test('masteryFraction sadece kutu 4–5 sayar', () {
      final sr = {
        'a': SrEntry(
            box: 1,
            nextReview: DateTime(2026, 1, 2),
            totalAttempts: 1),
        'b': SrEntry(
            box: 4,
            nextReview: DateTime(2026, 2, 1),
            totalAttempts: 4),
        'c': SrEntry(
            box: 5,
            nextReview: DateTime(2026, 3, 1),
            totalAttempts: 5),
      };
      expect(masteryFraction(sr, 10), closeTo(0.2, 0.0001));
    });
  });
}
