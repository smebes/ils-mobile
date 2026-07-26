import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'l10n/l10n_ext.dart';
import 'theme.dart';

/// Vocab (SVG) veya sahne (webp) görselini yol uzantısına göre render eder.
class MediaImage extends StatelessWidget {
  final String assetPath;
  final double? height;
  final double? width;
  final BoxFit fit;
  const MediaImage(this.assetPath,
      {super.key, this.height, this.width, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    if (assetPath.endsWith('.svg')) {
      return SvgPicture(
        SvgAssetLoader(assetPath),
        height: height,
        width: width,
        fit: fit,
        allowDrawingOutsideViewBox: true,
        placeholderBuilder: (_) => _placeholder(),
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, e, st) => _placeholder(),
    );
  }

  Widget _placeholder() => SizedBox(
        height: height ?? 80,
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.image_outlined, size: 36, color: AppColors.navy),
          ),
        ),
      );
}

/// der/die/das renk kodlu artikel rozeti.
class ArtikelDot extends StatelessWidget {
  final String? artikel;
  const ArtikelDot(this.artikel, {super.key});

  @override
  Widget build(BuildContext context) {
    if (artikel == null) return const SizedBox.shrink();
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.artikel(artikel),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 🐢 / 🐇 ses hız butonları.
class SpeedButtons extends StatelessWidget {
  final VoidCallback onSlow;
  final VoidCallback onNormal;
  final bool playing;
  const SpeedButtons({
    super.key,
    required this.onSlow,
    required this.onNormal,
    this.playing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn('🐢', 'Langsam', onSlow),
        const SizedBox(width: 12),
        _btn('🐇', 'Normal', onNormal),
      ],
    );
  }

  Widget _btn(String label, String tip, VoidCallback onTap) => Tooltip(
        message: tip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: playing
                  ? AppColors.teal.withValues(alpha: 0.2)
                  : AppColors.cream,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: playing ? AppColors.teal : AppColors.mustard,
                  width: 2),
            ),
            child: Text(label, style: const TextStyle(fontSize: 22)),
          ),
        ),
      );
}

/// İlerleme çubuğu (oturum içinde).
class SessionProgressBar extends StatelessWidget {
  final double value;
  const SessionProgressBar(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
        backgroundColor: Colors.white,
        valueColor: const AlwaysStoppedAnimation(AppColors.teal),
      ),
    );
  }
}

/// Doğru/yanlış geri bildirim şeridi (altta belirir).
class FeedbackBar extends StatelessWidget {
  final bool correct;
  final String message;
  final String cta;
  final VoidCallback onNext;
  const FeedbackBar({
    super.key,
    required this.correct,
    required this.message,
    required this.cta,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = correct ? AppColors.das : AppColors.coral;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(correct ? Icons.check_circle : Icons.info,
                  color: color, size: 26),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    correct
                        ? l10n.feedbackCorrectDe
                        : l10n.feedbackAlmostDe,
                    style: TextStyle(
                        color: color, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    correct
                        ? l10n.feedbackCorrectLocal
                        : l10n.feedbackAlmostLocal,
                    style: TextStyle(
                        color: color.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(message, style: const TextStyle(fontSize: 15)),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(backgroundColor: color),
              child: Text(cta),
            ),
          ),
        ],
      ),
    );
  }
}
