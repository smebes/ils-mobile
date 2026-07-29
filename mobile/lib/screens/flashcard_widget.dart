import 'dart:async';

import 'package:flutter/material.dart';
import '../audio_service.dart';
import '../l10n/l10n_ext.dart';
import '../models.dart';
import '../motion_widgets.dart';
import '../sr_engine.dart';
import '../theme.dart';
import '../tts_service.dart';
import '../widgets.dart';

/// Tanıtım / tekrar kartı: görsel + artikel + kelime + öz-değerlendirme.
class FlashcardWidget extends StatefulWidget {
  final VocabItem vocab;
  /// Geriye uyum: rating yoksa Devam ile çağrılır.
  final VoidCallback? onNext;
  /// WordBit tarzı 3’lü feedback.
  final ValueChanged<SelfRating>? onRate;
  /// true → "Tekrar" etiketi.
  final bool isReview;
  const FlashcardWidget({
    super.key,
    required this.vocab,
    this.onNext,
    this.onRate,
    this.isReview = false,
  }) : assert(onNext != null || onRate != null);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool revealed = false;
  bool _busy = false;
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
    if (_busy) return;
    _audio.stopIfPlaying();
    widget.onNext?.call();
  }

  void _rate(SelfRating rating) {
    if (_busy) return;
    _busy = true;
    _audio.stopIfPlaying();
    final cb = widget.onRate;
    if (cb != null) {
      cb(rating);
    } else {
      widget.onNext?.call();
    }
  }

  @override
  void dispose() {
    _audio.stopIfPlaying();
    super.dispose();
  }

  String _langTag(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return code.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final v = widget.vocab;
    final useRating = widget.onRate != null;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            children: [
              Text(
                (widget.isReview ? l10n.reviewWordBadge : l10n.newWord)
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: AppColors.teal,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                decoration: cardDecoration(),
                child: Column(
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: v.image != null
                          ? MediaImage(v.image!,
                              height: 160, fit: BoxFit.contain)
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  v.beispiel ?? v.display,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    color:
                                        AppColors.navy.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (v.artikel != null) ...[
                          ArtikelDot(v.artikel),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            v.display,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: AppColors.artikel(v.artikel),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _speak,
                      icon: const Icon(Icons.volume_up_outlined, size: 18),
                      label: Text(l10n.listenTooltip),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: BorderSide(
                            color: AppColors.navy.withValues(alpha: 0.12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (v.beispiel != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        v.beispiel!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.5,
                          height: 1.5,
                          color: AppColors.navy.withValues(alpha: 0.75),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (v.plural != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.pluralLabel(v.plural!),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.navy.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Divider(
                        height: 1,
                        color: AppColors.navy.withValues(alpha: 0.08)),
                    const SizedBox(height: 16),
                    TranslationRevealSlot(
                      revealed: revealed,
                      button: OutlinedButton(
                        onPressed: () => setState(() => revealed = true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1F7268),
                          backgroundColor:
                              AppColors.teal.withValues(alpha: 0.06),
                          side: BorderSide(
                            color: AppColors.teal.withValues(alpha: 0.5),
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                        child: Text(l10n.showTranslation),
                      ),
                      translation: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _langTag(context),
                            style: TextStyle(
                              fontSize: 10.5,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.navy.withValues(alpha: 0.45),
                              fontFamily: 'IBMPlexMono',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            v.uebersetzungTr,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: useRating
              ? Column(
                  children: [
                    Text(
                      l10n.rateWordPrompt,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _RateBtn(
                            icon: Icons.help_outline_rounded,
                            label: l10n.rateUnknown,
                            color: AppColors.coral,
                            onTap: () => _rate(SelfRating.unknown),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RateBtn(
                            icon: Icons.priority_high_rounded,
                            label: l10n.rateUnsure,
                            color: AppColors.mustard,
                            onTap: () => _rate(SelfRating.unsure),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RateBtn(
                            icon: Icons.check_rounded,
                            label: l10n.rateKnown,
                            color: AppColors.teal,
                            onTap: () => _rate(SelfRating.known),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : SizedBox(
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

class _RateBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _RateBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: AppColors.navy.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
