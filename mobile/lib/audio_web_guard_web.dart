// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web'de audioplayers / media katmanı tıklamaları yutabiliyor.
/// Home dahil her etkileşim öncesi güvenli hale getir.
void neutralizeWebAudioElements() {
  try {
    for (final el in html.document.querySelectorAll('audio, video')) {
      _killPointer(el);
    }
    // audioplayers web bazen sabit konumlu sarmalayıcı bırakır
    for (final el in html.document.querySelectorAll(
        'flt-glass-pane audio, flt-scene-host audio, body > audio')) {
      _killPointer(el);
    }
  } catch (_) {}
}

void _killPointer(html.Element el) {
  el.style
    ..setProperty('pointer-events', 'none')
    ..setProperty('touch-action', 'none')
    ..setProperty('position', 'fixed')
    ..setProperty('left', '-9999px')
    ..setProperty('top', '-9999px')
    ..setProperty('width', '1px')
    ..setProperty('height', '1px')
    ..setProperty('opacity', '0')
    ..setProperty('z-index', '-1');
}
