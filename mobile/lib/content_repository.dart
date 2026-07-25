import 'dart:convert';
import 'package:flutter/services.dart';
import 'models.dart';

/// İçeriği asset bundle'dan okur (offline-first).
/// Müfredat sırası: L1 → L2 → … → L7 (kitap birebir).
class ContentRepository {
  static const int activeLektionId = 1;

  final Map<int, Lektion> _lektionen = {};
  final Map<int, List<Exercise>> _exercises = {};

  Future<Lektion> loadLektion({int id = activeLektionId}) async {
    if (_lektionen.containsKey(id)) return _lektionen[id]!;
    final raw =
        await rootBundle.loadString('assets/content/l$id/lektion.json');
    final lektion = Lektion.fromJson(json.decode(raw) as Map<String, dynamic>);
    _lektionen[id] = lektion;
    return lektion;
  }

  Future<List<Exercise>> loadExercises({int id = activeLektionId}) async {
    if (_exercises.containsKey(id)) return _exercises[id]!;
    final raw =
        await rootBundle.loadString('assets/content/l$id/exercises.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
    _exercises[id] = items;
    return items;
  }

  /// Lektion kilidi: önceki Lektion %80 hakimiyet → sonrakisi açılır.
  bool isUnlocked(int lektionId, double previousMastery) {
    if (lektionId <= 1) return true;
    // Henüz sadece L1 içerik yüklü; L2+ kilitli kalır.
    if (lektionId > activeLektionId) return false;
    return previousMastery >= 0.8;
  }
}
