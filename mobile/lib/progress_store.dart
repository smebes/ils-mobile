import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sr_engine.dart';

/// Lokal ilerleme + Leitner SR (V2). Offline-first; V3'te backend sync.
class ProgressStore extends ChangeNotifier {
  static const _kStreak = 'streak';
  static const _kLastDay = 'last_active_day';
  static const _kXp = 'xp';
  static const _kSr = 'sr_entries_v2';
  static const _kUserName = 'user_name';
  static const _kDailyGoalMin = 'daily_goal_min';
  static const _kOnboarding = 'onboarding_done';
  static const _kActiveSlice = 'active_slice';
  static const _kUiLocale = 'ui_locale';
  static const _kActiveDays = 'active_days_v1';
  static const _kReminderHour = 'reminder_hour';

  SharedPreferences? _p;
  final Map<String, SrEntry> _sr = {};
  final Set<String> _activeDays = {};

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
    try {
      final days = _p!.getStringList(_kActiveDays);
      if (days != null) _activeDays.addAll(days);
      final last = _p!.getString(_kLastDay);
      if (last != null) _activeDays.add(last);
    } catch (e) {
      debugPrint('active days load error: $e');
    }
  }

  int get streak => _p?.getInt(_kStreak) ?? 0;
  int get xp => _p?.getInt(_kXp) ?? 0;
  int get level => 1 + xp ~/ 100;

  /// UI chrome dili: tr | en | fr (içerik her zaman de-DE).
  String get uiLocaleCode {
    final saved = _p?.getString(_kUiLocale);
    if (saved != null && saved.isNotEmpty) return saved;
    final platform = PlatformDispatcher.instance.locale.languageCode;
    if (platform == 'tr' || platform == 'fr' || platform == 'en') {
      return platform;
    }
    return 'en';
  }

  Locale get uiLocale => Locale(uiLocaleCode);

  Future<void> setUiLocale(String code) async {
    await _p?.setString(_kUiLocale, code);
    notifyListeners();
  }

  String? get userName {
    final n = _p?.getString(_kUserName);
    if (n == null || n.trim().isEmpty) return null;
    return n.trim();
  }

  int get dailyGoalMinutes => _p?.getInt(_kDailyGoalMin) ?? 10;

  bool get onboardingDone => _p?.getBool(_kOnboarding) ?? false;

  /// 1..5 — L1 Schritt dilimi (Folge+A = 1 … E = 5)
  int get activeSlice => (_p?.getInt(_kActiveSlice) ?? 1).clamp(1, 5);

  /// Günlük hatırlatma saati (0–23). null = kapalı.
  int? get reminderHour {
    if (_p == null || !_p!.containsKey(_kReminderHour)) return null;
    return _p!.getInt(_kReminderHour);
  }

  Future<void> setReminderHour(int? hour) async {
    if (hour == null) {
      await _p?.remove(_kReminderHour);
    } else {
      await _p?.setInt(_kReminderHour, hour.clamp(0, 23));
    }
    notifyListeners();
  }

  bool get dailyGoalDoneToday {
    final last = _p?.getString(_kLastDay);
    return last == _dayKey(_today());
  }

  /// Home CTA fazı: new | progress | done
  String get homePhase {
    if (dailyGoalDoneToday) return 'done';
    if (_sr.isNotEmpty || xp > 0) return 'progress';
    return 'new';
  }

  Future<void> setUserName(String? name) async {
    if (name == null || name.trim().isEmpty) {
      await _p?.remove(_kUserName);
    } else {
      await _p?.setString(_kUserName, name.trim());
    }
    notifyListeners();
  }

  Future<void> setDailyGoalMinutes(int minutes) async {
    await _p?.setInt(_kDailyGoalMin, minutes);
    notifyListeners();
  }

  Future<void> setOnboardingDone(bool v) async {
    await _p?.setBool(_kOnboarding, v);
    notifyListeners();
  }

  Future<void> setActiveSlice(int slice) async {
    await _p?.setInt(_kActiveSlice, slice.clamp(1, 5));
    notifyListeners();
  }

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
        .where((w) => _sr[w] != null && !_sr[w]!.isMastered)
        .toList();
    list.sort((a, b) {
      final wa = _sr[a]!;
      final wb = _sr[b]!;
      final byWrong = wb.wrongCount.compareTo(wa.wrongCount);
      if (byWrong != 0) return byWrong;
      return wa.box.compareTo(wb.box);
    });
    return list.take(limit).toList();
  }

  /// En çok yanlış yapılan kelimeler (Hatalarım).
  List<String> mistakeWords(List<String> allWords, {int limit = 3}) {
    final list = allWords
        .where((w) => (_sr[w]?.wrongCount ?? 0) > 0)
        .toList();
    list.sort((a, b) => _sr[b]!.wrongCount.compareTo(_sr[a]!.wrongCount));
    return list.take(limit).toList();
  }

  int wrongCountFor(String wort) => _sr[wort]?.wrongCount ?? 0;

  int boxFor(String wort) => _sr[wort]?.box ?? 1;

  /// Zayıf güç çubuğu % — kutu yükseldikçe artar.
  int strengthPct(String wort) {
    final e = _sr[wort];
    if (e == null) return 0;
    return ((e.box / 5.0) * 100).round().clamp(0, 100);
  }

  /// Yaklaşan (bugün dışı) tekrarlar — en yakın vadeler.
  List<({String wort, DateTime when})> upcomingReviews(
    List<String> allWords, {
    int limit = 3,
  }) {
    final today = _today();
    final list = <({String wort, DateTime when})>[];
    for (final w in allWords) {
      final e = _sr[w];
      if (e == null) continue;
      if (!e.nextReview.isAfter(today)) continue;
      list.add((wort: w, when: e.nextReview));
    }
    list.sort((a, b) => a.when.compareTo(b.when));
    return list.take(limit).toList();
  }

  /// Bu haftanın 7 günü (Pzt→Paz): aktif mi?
  List<({DateTime day, bool done})> weekActivity() {
    final today = _today();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return (day: d, done: _activeDays.contains(_dayKey(d)));
    });
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
    _activeDays.add(todayKey);
    // Son ~60 gün tut — SharedPreferences şişmesin.
    final cutoff = _today().subtract(const Duration(days: 60));
    _activeDays.removeWhere((k) {
      try {
        final parts = k.split('-');
        final d = DateTime(
            int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        return d.isBefore(cutoff);
      } catch (_) {
        return true;
      }
    });
    await p.setStringList(_kActiveDays, _activeDays.toList());
    notifyListeners();
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
