import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final v = widget.vocab;
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Neues Wort',
                style: TextStyle(fontSize: 15, color: AppColors.teal,
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
                    MediaImage(v.image, height: 160),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ArtikelDot(v.artikel),
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
                      ],
                    ),
                    if (v.plural != null) ...[
                      const SizedBox(height: 4),
                      Text('Plural: die ${v.plural}',
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
                        child: const Text('Çeviriyi göster'),
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
              onPressed: widget.onNext,
              child: const Text('Weiter'),
            ),
          ),
        ),
      ],
    );
  }
}
