import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sr_engine.dart';

/// Lokal ilerleme + Leitner SR (V2). Offline-first; V3'te backend sync.
class ProgressStore extends ChangeNotifier {
  static const _kStreak = 'streak';
  static const _kLastDay = 'last_active_day';
  static const _kXp = 'xp';
  static const _kSr = 'sr_entries_v2';

  SharedPreferences? _p;
  final Map<String, SrEntry> _sr = {};

  bool get isReady => _p != null;

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    try {
      final raw = _p!.getString(_kSr);
      if (raw != null) {
        final map = json.decode(raw) as Map<String, dynamic>;
        map.forEach((k, v) {
          _sr[k] = SrEntry.fromJson((v as Map).cast<String, dynamic>());
        });
      }
    } catch (e) {
      debugPrint('SR data load error: $e');
      _sr.clear();
    }
  }

  int get streak => _p?.getInt(_kStreak) ?? 0;
  int get xp => _p?.getInt(_kXp) ?? 0;
  int get level => 1 + xp ~/ 100;

  Map<String, SrEntry> get srEntries => Map.unmodifiable(_sr);

  Future<void> _persistSr({bool notify = true}) async {
    final map = _sr.map((k, v) => MapEntry(k, v.toJson()));
    await _p?.setString(_kSr, json.encode(map));
    if (notify) notifyListeners();
  }

  Future<void> addXp(int amount) async {
    await _p?.setInt(_kXp, xp + amount);
    notifyListeners();
  }

  /// Flashcard'da kelime tanıtıldı (henüz test edilmedi).
  Future<void> introduceWord(String wort) async {
    if (_sr.containsKey(wort)) return;
    _sr[wort] = SrEntry.introduced(_today());
    await _persistSr();
  }

  /// Egzersiz/cevap sonucu — Leitner güncelle.
  Future<void> recordAnswer(String wort, bool correct) async {
    final today = _today();
    final current = _sr[wort] ?? SrEntry.introduced(today);
    _sr[wort] = applyAnswer(current, correct, today);
    await _persistSr();
  }

  /// Birden fazla kelime — tek persist (Weiter gecikmesini önler).
  Future<void> recordAnswersBatch(List<String> words, bool correct) async {
    if (words.isEmpty) return;
    final today = _today();
    for (final wort in words) {
      final current = _sr[wort] ?? SrEntry.introduced(today);
      _sr[wort] = applyAnswer(current, correct, today);
    }
    await _persistSr();
  }

  /// Oturum sonunda toplu güncelleme (egzersiz kelimeleri).
  Future<void> recordAnswers(Map<String, bool> results) async {
    if (results.isEmpty) return;
    final today = _today();
    for (final e in results.entries) {
      final current = _sr[e.key] ?? SrEntry.introduced(today);
      _sr[e.key] = applyAnswer(current, e.value, today);
    }
    await _persistSr();
  }

  /// Hakimiyet = kutu 4–5'teki kelimeler / toplam (PRODUCT.md — "görüldü" değil).
  double masteryPct(int totalVocab) => masteryFraction(_sr, totalVocab);

  int masteredCount(int totalVocab) =>
      _sr.values.where((e) => e.isMastered).length;

  /// Bugün tekrar kuyruğunda kaç kelime var (sonuç ekranı metni için).
  int dueReviewCount(List<String> allWords) {
    final today = _today();
    return allWords.where((w) {
      final e = _sr[w];
      return e != null && e.isDue(today);
    }).length;
  }

  List<String> dailyWordQueue(List<String> allWords, {int size = 15}) =>
      buildDailyQueue(allWords: allWords, sr: _sr, today: _today(), targetSize: size);

  /// Zayıf kelimeler (ilerleme ekranı için).
  List<String> weakWords(List<String> allWords, {int limit = 5}) {
    final list = allWords
        .where((w) => _sr[w] != null && _sr[w]!.wrongCount > 0)
        .toList();
    list.sort((a, b) => _sr[b]!.wrongCount.compareTo(_sr[a]!.wrongCount));
    return list.take(limit).toList();
  }

  Future<void> completeDailyGoal() async {
    final p = _p;
    if (p == null) return;
    final todayKey = _dayKey(_today());
    final last = p.getString(_kLastDay);
    if (last == todayKey) return;
    final yesterday = _dayKey(_today().subtract(const Duration(days: 1)));
    final newStreak = (last == yesterday) ? streak + 1 : 1;
    await p.setInt(_kStreak, newStreak);
    await p.setString(_kLastDay, todayKey);
    notifyListeners();
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
