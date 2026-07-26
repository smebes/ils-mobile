import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'audio_web_guard_stub.dart'
    if (dart.library.html) 'audio_web_guard_web.dart' as web_audio;

/// Tek paylaşımlı player — web'de biriken &lt;audio&gt; katmanlarını önler.
///
/// Tüm await'ler timeout'lu: web'de stop/getDuration asılı kalınca
/// UI (Prüfen / X) kilitlenmesin.
class AudioService {
  AudioService._() {
    unawaited(_player.setReleaseMode(ReleaseMode.stop));
  }

  static final AudioService shared = AudioService._();

  /// Geriye dönük: yeni instance yerine shared kullan.
  factory AudioService() => shared;

  final AudioPlayer _player = AudioPlayer();
  int _generation = 0;
  bool _playing = false;

  bool get isPlaying => _playing;

  Future<void> playOne(String assetPath) async {
    final gen = ++_generation;
    _playing = true;
    try {
      await _safeStop();
      if (gen != _generation) return;
      await _awaitLimited(
        _player.play(AssetSource(_strip(assetPath))),
        const Duration(seconds: 4),
        'play',
      );
      if (gen != _generation) return;
      await _waitComplete();
    } catch (e) {
      debugPrint('AudioService.playOne: $e');
    } finally {
      if (gen == _generation) _playing = false;
      web_audio.neutralizeWebAudioElements();
    }
  }

  Future<void> playSequence(List<String> assetPaths) async {
    final gen = ++_generation;
    _playing = true;
    try {
      for (final p in assetPaths) {
        if (gen != _generation) break;
        await _safeStop();
        if (gen != _generation) break;
        await _awaitLimited(
          _player.play(AssetSource(_strip(p))),
          const Duration(seconds: 4),
          'play',
        );
        if (gen != _generation) break;
        await _waitComplete();
      }
    } catch (e) {
      debugPrint('AudioService.playSequence: $e');
    } finally {
      if (gen == _generation) _playing = false;
      // finally içinde uzun stop yok — UI'yı bırak
      unawaited(_safeStop());
      web_audio.neutralizeWebAudioElements();
    }
  }

  /// Sadece onPlayerComplete + sert timeout.
  /// `stopped` dinlenmez: stop() erken bitirip sırayı bozuyordu.
  Future<void> _waitComplete() async {
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    // Timer ÖNCE — getDuration asılı kalsa bile çıkış var
    Timer? softTimer;
    final hardTimer = Timer(const Duration(seconds: 10), () {
      debugPrint('AudioService: clip timeout — devam');
      finish();
    });

    StreamSubscription<void>? completeSub;
    try {
      completeSub = _player.onPlayerComplete.listen((_) => finish());

      unawaited(() async {
        try {
          final d = await _player.getDuration().timeout(
            const Duration(milliseconds: 400),
          );
          if (d != null && d > Duration.zero && !done.isCompleted) {
            final wait = d + const Duration(milliseconds: 600);
            final capped = wait > const Duration(seconds: 12)
                ? const Duration(seconds: 12)
                : wait;
            softTimer = Timer(capped, finish);
          }
        } catch (_) {}
      }());

      await done.future;
    } catch (e) {
      debugPrint('AudioService: waitComplete $e');
    } finally {
      hardTimer.cancel();
      softTimer?.cancel();
      await completeSub?.cancel();
    }
  }

  Future<void> stop() async {
    _generation++;
    _playing = false;
    await _safeStop();
    web_audio.neutralizeWebAudioElements();
  }

  Future<void> _safeStop() async {
    try {
      await _player.stop().timeout(const Duration(milliseconds: 400));
    } on TimeoutException {
      debugPrint('AudioService: stop timeout');
    } catch (e) {
      debugPrint('AudioService.stop: $e');
    }
  }

  Future<void> _awaitLimited(
    Future<void> future,
    Duration limit,
    String label,
  ) async {
    try {
      await future.timeout(limit);
    } on TimeoutException {
      debugPrint('AudioService: $label timeout');
    }
  }

  /// Shared player: widget dispose'da yok etme, sadece durdur.
  void dispose() {
    _generation++;
    _playing = false;
    unawaited(_safeStop());
    web_audio.neutralizeWebAudioElements();
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
