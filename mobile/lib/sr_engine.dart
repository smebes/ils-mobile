/// Leitner SR kutusu aralıkları (gün) — PRODUCT.md §3.
const kBoxIntervals = [1, 3, 7, 14, 30];

/// Kutu 4–5 = "hakim" sayılır (görünmez bilim, görünür metrik).
const kMasteredMinBox = 4;

class SrEntry {
  final int box; // 1..5
  final DateTime nextReview;
  final int correctStreak;
  final int totalAttempts;
  final int wrongCount;

  const SrEntry({
    required this.box,
    required this.nextReview,
    this.correctStreak = 0,
    this.totalAttempts = 0,
    this.wrongCount = 0,
  });

  bool get isMastered => box >= kMasteredMinBox;
  bool isDue(DateTime today) => !nextReview.isAfter(today);

  SrEntry copyWith({
    int? box,
    DateTime? nextReview,
    int? correctStreak,
    int? totalAttempts,
    int? wrongCount,
  }) =>
      SrEntry(
        box: box ?? this.box,
        nextReview: nextReview ?? this.nextReview,
        correctStreak: correctStreak ?? this.correctStreak,
        totalAttempts: totalAttempts ?? this.totalAttempts,
        wrongCount: wrongCount ?? this.wrongCount,
      );

  Map<String, dynamic> toJson() => {
        'box': box,
        'nextReview': nextReview.toIso8601String(),
        'correctStreak': correctStreak,
        'totalAttempts': totalAttempts,
        'wrongCount': wrongCount,
      };

  factory SrEntry.fromJson(Map<String, dynamic> j) => SrEntry(
        box: j['box'] as int,
        nextReview: DateTime.parse(j['nextReview'] as String),
        correctStreak: j['correctStreak'] as int? ?? 0,
        totalAttempts: j['totalAttempts'] as int? ?? 0,
        wrongCount: j['wrongCount'] as int? ?? 0,
      );

  /// İlk kez görülen kelime → kutu 1, yarın tekrar.
  factory SrEntry.introduced(DateTime today) => SrEntry(
        box: 1,
        nextReview: today.add(const Duration(days: 1)),
      );
}

/// Doğru cevap → bir üst kutu; yanlış → kutu 1.
/// Aynı gün içinde (nextReview henüz gelmeden) tekrar doğru → kutu TERFİ ETMEZ
/// (sadece attempt sayacı artar). Böylece tek oturumda box 1→5 olmaz.
SrEntry applyAnswer(SrEntry e, bool correct, DateTime today) {
  final attempts = e.totalAttempts + 1;
  if (correct) {
    // Daha önce cevaplanmış ve vade gelmemişse: pratik say, terfi etme.
    if (e.totalAttempts > 0 && !e.isDue(today)) {
      return e.copyWith(
        totalAttempts: attempts,
        correctStreak: e.correctStreak + 1,
      );
    }
    final newBox = (e.box + 1).clamp(1, 5);
    final days = kBoxIntervals[newBox - 1];
    return e.copyWith(
      box: newBox,
      nextReview: today.add(Duration(days: days)),
      correctStreak: e.correctStreak + 1,
      totalAttempts: attempts,
    );
  }
  // Yanlış → kutu 1; aynı gün tekrar denenebilsin diye today'e due yap.
  return e.copyWith(
    box: 1,
    nextReview: today,
    correctStreak: 0,
    totalAttempts: attempts,
    wrongCount: e.wrongCount + 1,
  );
}

/// Günlük kuyruk: %60 vadesi gelmiş, %30 yeni, %10 zayıf (PRODUCT.md §3).
List<String> buildDailyQueue({
  required List<String> allWords,
  required Map<String, SrEntry> sr,
  required DateTime today,
  int targetSize = 15,
}) {
  if (allWords.isEmpty) return [];

  final due = <String>[];
  final fresh = <String>[];
  final weak = <String>[];

  for (final w in allWords) {
    final e = sr[w];
    if (e == null) {
      fresh.add(w);
    } else if (e.isDue(today)) {
      due.add(w);
    } else if (e.box <= 2 && e.wrongCount > 0) {
      weak.add(w);
    }
  }

  weak.sort((a, b) => sr[b]!.wrongCount.compareTo(sr[a]!.wrongCount));

  final nDue = (targetSize * 0.6).round();
  final nNew = (targetSize * 0.3).round();
  final nWeak = targetSize - nDue - nNew;

  final out = <String>[];
  void take(List<String> src, int n) {
    for (var i = 0; i < n && i < src.length; i++) {
      if (!out.contains(src[i])) out.add(src[i]);
    }
  }

  take(due, nDue);
  take(fresh, nNew);
  take(weak, nWeak);

  // Hedef dolmadıysa kalanlardan tamamla
  for (final w in [...due, ...fresh, ...weak, ...allWords]) {
    if (out.length >= targetSize) break;
    if (!out.contains(w)) out.add(w);
  }
  return out.take(targetSize).toList();
}

double masteryFraction(Map<String, SrEntry> sr, int totalVocab) {
  if (totalVocab == 0) return 0;
  final mastered = sr.values.where((e) => e.isMastered).length;
  return mastered / totalVocab;
}
