import 'dart:convert';
import 'package:flutter/services.dart';
import 'models.dart';

/// İçeriği asset bundle'dan okur (offline-first).
/// Müfredat sırası: L1 → L2 → … → L7 (kitap birebir).
class ContentRepository {
  /// Yüklü lektionen (içerik dosyası olanlar).
  static const List<int> bundledLektionIds = [1, 2];

  final Map<int, Lektion> _lektionen = {};
  final Map<int, List<Exercise>> _exercises = {};

  Future<Lektion> loadLektion({int id = 1}) async {
    if (_lektionen.containsKey(id)) return _lektionen[id]!;
    final raw =
        await rootBundle.loadString('assets/content/l$id/lektion.json');
    final lektion = Lektion.fromJson(json.decode(raw) as Map<String, dynamic>);
    _lektionen[id] = lektion;
    return lektion;
  }

  Future<List<Exercise>> loadExercises({int id = 1}) async {
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

  bool hasContent(int lektionId) => bundledLektionIds.contains(lektionId);

  /// Lektion kilidi: önceki Lektion %80 hakimiyet → sonrakisi açılır.
  bool isUnlocked(int lektionId, double previousMastery) {
    if (lektionId <= 1) return true;
    if (!hasContent(lektionId)) return false;
    return previousMastery >= 0.8;
  }
}
