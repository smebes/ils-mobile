import 'dart:async';

import 'package:flutter/material.dart';
import '../audio_service.dart';
import '../l10n/l10n_ext.dart';
import '../models.dart';
import '../theme.dart';
import '../tts_service.dart';
import '../widgets.dart';

/// Tanıtım kartı: görsel + artikel renk kodu + kelime + çeviri (tap ile).
class FlashcardWidget extends StatefulWidget {
  final VocabItem vocab;
  final VoidCallback onNext;
  const FlashcardWidget(
      {super.key, required this.vocab, required this.onNext});

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool revealed = false;
  final _audio = AudioService();

  void _speak() {
    final v = widget.vocab;
    if (v.audio != null) {
      unawaited(_audio.playOne(v.audio!));
    } else {
      TtsService.speak(v.display);
    }
  }

  void _goNext() {
    // stop await etme — web'de player.stop UI'yı kilitleyebiliyor
    _audio.stopIfPlaying();
    widget.onNext();
  }

  @override
  void dispose() {
    _audio.stopIfPlaying();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final v = widget.vocab;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.newWord,
                style: const TextStyle(fontSize: 15, color: AppColors.teal,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: cardDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (v.image != null)
                      MediaImage(v.image!, height: 160)
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          v.beispiel ?? v.display,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ArtikelDot(v.artikel),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            v.display,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.artikel(v.artikel),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: IconButton(
                            icon: const Icon(Icons.volume_up,
                                color: AppColors.teal, size: 28),
                            onPressed: _speak,
                            tooltip: l10n.listenTooltip,
                          ),
                        ),
                      ],
                    ),
                    if (v.beispiel != null && v.image != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        v.beispiel!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.navy.withValues(alpha: 0.55),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (v.plural != null) ...[
                      const SizedBox(height: 4),
                      Text(l10n.pluralLabel(v.plural!),
                          style: TextStyle(
                              color: AppColors.navy.withValues(alpha: 0.5))),
                    ],
                    const SizedBox(height: 20),
                    if (revealed)
                      Text(v.uebersetzungTr,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600))
                    else
                      TextButton(
                        onPressed: () => setState(() => revealed = true),
                        child: Text(l10n.showTranslation),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _goNext,
              child: Text(l10n.continueBtn),
            ),
          ),
        ),
      ],
    );
  }
}
