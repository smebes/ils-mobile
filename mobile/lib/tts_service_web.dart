import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('SpeechSynthesisUtterance')
extension type _Utterance._(JSObject _) implements JSObject {
  external factory _Utterance(JSString text);
  external set lang(JSString value);
  external set rate(JSNumber value);
}

/// Tarayıcı yerleşik TTS ile Almanca kelime okuma.
class TtsService {
  static const _lang = 'de-DE';
  static const _rate = 0.8;

  static void speak(String text) {
    final synth = globalContext['speechSynthesis'] as JSObject;
    synth.callMethod('cancel'.toJS);
    final utterance = _Utterance(text.toJS);
    utterance.lang = _lang.toJS;
    utterance.rate = _rate.toJS;
    synth.callMethod('speak'.toJS, utterance);
  }
}
