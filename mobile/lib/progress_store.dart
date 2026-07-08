import 'package:shared_preferences/shared_preferences.dart';

/// Basit lokal ilerleme (V1). V2'de Leitner SR motoruna genişler.
class ProgressStore {
  static const _kStreak = 'streak';
  static const _kLastDay = 'last_active_day';
  static const _kXp = 'xp';
  static const _kMastered = 'mastered_words'; // set of wort

  late SharedPreferences _p;

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  int get streak => _p.getInt(_kStreak) ?? 0;
  int get xp => _p.getInt(_kXp) ?? 0;
  Set<String> get mastered => (_p.getStringList(_kMastered) ?? []).toSet();

  int get level => 1 + xp ~/ 100;

  Future<void> addXp(int amount) async {
    await _p.setInt(_kXp, xp + amount);
  }

  Future<void> markMastered(String wort) async {
    final m = mastered..add(wort);
    await _p.setStringList(_kMastered, m.toList());
  }

  double masteryPct(int totalVocab) {
    if (totalVocab == 0) return 0;
    return mastered.length / totalVocab;
  }

  /// Günlük hedef tamamlandığında çağrılır; streak'i günceller.
  Future<void> completeDailyGoal() async {
    final today = _dayKey(DateTime.now());
    final last = _p.getString(_kLastDay);
    if (last == today) return; // bugün zaten sayıldı
    final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    final newStreak = (last == yesterday) ? streak + 1 : 1;
    await _p.setInt(_kStreak, newStreak);
    await _p.setString(_kLastDay, today);
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
