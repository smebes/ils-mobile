import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Diyalog satırlarını sırayla çalar (asset mp3).
///
/// Web'de `onPlayerComplete` bazen hiç gelmiyor; timeout + generation
/// token ile Future asılı kalmaz, UI kilitlenmez.
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  int _generation = 0;
  bool _playing = false;

  bool get isPlaying => _playing;

  Future<void> playOne(String assetPath) async {
    final gen = ++_generation;
    _playing = true;
    try {
      await _player.stop();
      if (gen != _generation) return;
      final done = _waitComplete();
      await _player.play(AssetSource(_strip(assetPath)));
      if (gen != _generation) return;
      await done;
    } catch (e) {
      debugPrint('AudioService.playOne: $e');
      rethrow;
    } finally {
      if (gen == _generation) _playing = false;
    }
  }

  Future<void> playSequence(List<String> assetPaths) async {
    final gen = ++_generation;
    _playing = true;
    try {
      for (final p in assetPaths) {
        if (gen != _generation) break;
        await _player.stop();
        if (gen != _generation) break;
        final done = _waitComplete();
        await _player.play(AssetSource(_strip(p)));
        if (gen != _generation) break;
        await done;
      }
    } catch (e) {
      debugPrint('AudioService.playSequence: $e');
      rethrow;
    } finally {
      if (gen == _generation) _playing = false;
    }
  }

  Future<void> _waitComplete() async {
    try {
      await _player.onPlayerComplete.first.timeout(
        const Duration(seconds: 12),
      );
    } on TimeoutException {
      debugPrint('AudioService: onPlayerComplete timeout — devam');
    } catch (e) {
      debugPrint('AudioService: waitComplete $e');
    }
  }

  Future<void> stop() async {
    _generation++;
    _playing = false;
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('AudioService.stop: $e');
    }
  }

  void dispose() {
    _generation++;
    _playing = false;
    _player.dispose();
  }

  String _strip(String p) {
    var s = p;
    if (s.startsWith('storage/audio/')) {
      s = 'assets/audio/${s.substring('storage/audio/'.length)}';
    }
    if (s.startsWith('assets/')) return s.substring('assets/'.length);
    return s;
  }
}
