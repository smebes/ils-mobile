import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'l10n/l10n_ext.dart';
import 'motion.dart';
import 'theme.dart';

/// Soft asset placeholder — kırık ikon flaşı yok.
/// Yükleniyor: teal→navy gradient; hata: cream + nötr çerçeve.
class SoftMediaPlaceholder extends StatelessWidget {
  final double? height;
  final double? width;
  final bool loading;
  const SoftMediaPlaceholder({
    super.key,
    this.height,
    this.width,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? 80.0;
    final w = width;
    if (loading) {
      return SizedBox(
        key: const ValueKey('soft_media_loading'),
        height: h,
        width: w,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.teal, AppColors.navy],
            ),
          ),
        ),
      );
    }
    return SizedBox(
      key: const ValueKey('soft_media_error'),
      height: h,
      width: w,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.navy.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
    if (assetPath.isEmpty) {
      return SoftMediaPlaceholder(height: height, width: width);
    }
    if (assetPath.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        height: height,
        width: width,
        fit: fit,
        allowDrawingOutsideViewBox: true,
        placeholderBuilder: (_) => SoftMediaPlaceholder(
          height: height,
          width: width,
          loading: true,
        ),
        errorBuilder: (context, error, stackTrace) {
          debugPrint('SVG load failed: $assetPath → $error');
          return SoftMediaPlaceholder(height: height, width: width);
        },
      );
    }
    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, e, st) =>
          SoftMediaPlaceholder(height: height, width: width),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return SoftMediaPlaceholder(
          height: height,
          width: width,
          loading: true,
        );
      },
    );
  }
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

/// İlerleme çubuğu (oturum içinde) — değer animasyonlu dolar.
class SessionProgressBar extends StatefulWidget {
  final double value;
  const SessionProgressBar(this.value, {super.key});

  @override
  State<SessionProgressBar> createState() => _SessionProgressBarState();
}

class _SessionProgressBarState extends State<SessionProgressBar> {
  double _from = 0;

  @override
  void didUpdateWidget(covariant SessionProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final to = widget.value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: _from.clamp(0.0, 1.0), end: to),
        duration: AppMotion.d(context, AppMotion.bar),
        curve: AppMotion.curve,
        builder: (context, anim, _) => LinearProgressIndicator(
          value: anim,
          minHeight: 10,
          backgroundColor: Colors.white,
          valueColor: const AlwaysStoppedAnimation(AppColors.teal),
        ),
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
    final bar = Container(
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
    if (AppMotion.reduce(context)) return bar;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.rise,
      curve: AppMotion.curve,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - t)),
          child: child,
        ),
      ),
      child: bar,
    );
  }
}
