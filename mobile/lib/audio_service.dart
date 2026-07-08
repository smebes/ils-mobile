import 'package:audioplayers/audioplayers.dart';

/// Diyalog satırlarını sırayla çalar (asset mp3). slow/normal hız desteği.
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  bool get isPlaying => _playing;

  /// Tek asset çal (assets/ önekini AssetSource beklemez).
  Future<void> playOne(String assetPath) async {
    await _player.stop();
    await _player.play(AssetSource(_strip(assetPath)));
  }

  /// Bir diziyi sırayla çalar (diyalog).
  Future<void> playSequence(List<String> assetPaths) async {
    if (_playing) {
      await stop();
      return;
    }
    _playing = true;
    for (final p in assetPaths) {
      if (!_playing) break;
      await _player.stop();
      await _player.play(AssetSource(_strip(p)));
      await _player.onPlayerComplete.first;
    }
    _playing = false;
  }

  Future<void> stop() async {
    _playing = false;
    await _player.stop();
  }

  void dispose() => _player.dispose();

  // AssetSource kök olarak 'assets/' ekler; yolumuz zaten 'assets/...' → çıkar.
  String _strip(String p) =>
      p.startsWith('assets/') ? p.substring('assets/'.length) : p;
}
