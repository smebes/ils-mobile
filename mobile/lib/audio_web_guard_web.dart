// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web'de audioplayers'ın bıraktığı &lt;audio&gt; katmanı tıklamaları yutabiliyor.
void neutralizeWebAudioElements() {
  for (final el in html.document.querySelectorAll('audio')) {
    el.style
      ..setProperty('pointer-events', 'none')
      ..setProperty('position', 'fixed')
      ..setProperty('width', '0')
      ..setProperty('height', '0')
      ..setProperty('opacity', '0')
      ..setProperty('z-index', '-1');
  }
}
