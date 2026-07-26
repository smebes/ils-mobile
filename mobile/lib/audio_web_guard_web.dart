// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web'de audioplayers / media katmanı tıklamaları yutabiliyor.
/// Yalnızca audio/video öğelerine dokun — body>div taraması Flutter
/// katmanlarını bozup egzersiz UI'sını kilitleyebiliyordu.
void neutralizeWebAudioElements() {
  try {
    for (final el in html.document.querySelectorAll('audio, video')) {
      _killPointer(el);
    }
  } catch (_) {}
}

void _killPointer(html.Element el) {
  try {
    el.style
      ..setProperty('pointer-events', 'none')
      ..setProperty('touch-action', 'none')
      ..setProperty('z-index', '-1');
  } catch (_) {}
}
