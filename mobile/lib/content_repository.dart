import 'dart:convert';
import 'package:flutter/services.dart';
import 'models.dart';

/// İçeriği asset bundle'dan okur (offline-first).
class ContentRepository {
  Lektion? _lektion;
  List<Exercise>? _exercises;

  Future<Lektion> loadLektion() async {
    if (_lektion != null) return _lektion!;
    final raw =
        await rootBundle.loadString('assets/content/l3/lektion.json');
    _lektion = Lektion.fromJson(json.decode(raw) as Map<String, dynamic>);
    return _lektion!;
  }

  Future<List<Exercise>> loadExercises() async {
    if (_exercises != null) return _exercises!;
    final raw =
        await rootBundle.loadString('assets/content/l3/exercises.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    _exercises = (data['items'] as List)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
    return _exercises!;
  }
}
