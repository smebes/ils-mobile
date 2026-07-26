import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'motion.dart';
import 'theme.dart';

/// Artikel rengini metinden çıkar (ör. "die Sprache").
Color? artikelAccentFromText(String text) {
  final t = text.trim().toLowerCase();
  if (t.startsWith('der ')) return AppColors.der;
  if (t.startsWith('die ')) return AppColors.die;
  if (t.startsWith('das ')) return AppColors.das;
  return null;
}

/// Sonuç kartları: aşağıdan yükselerek belirir.
class RiseIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  const RiseIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.rise,
  });

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduce(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      curve: Interval(
        delay.inMilliseconds / (duration + delay).inMilliseconds,
        1,
        curve: AppMotion.curve,
      ),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// XP / sayı sayacı (makara hissi — Tween).
class CountUpText extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String prefix;
  final Duration duration;
  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduce(context) || value == 0) {
      return Text('$prefix$value', style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) =>
          Text('$prefix${v.round()}', style: style),
    );
  }
}

/// Aktif harita node nabız halkası.
class PulseRing extends StatefulWidget {
  final double size;
  final Color color;
  final Widget child;
  const PulseRing({
    super.key,
    required this.size,
    required this.color,
    required this.child,
  });

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.ring,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!AppMotion.reduce(context)) {
        _c.repeat(reverse: false);
        // Spec: 2 tur sonra dur
        Future<void>.delayed(AppMotion.ring * 2, () {
          if (mounted) _c.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduce(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_c.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size + 22 * t,
              height: widget.size + 22 * t,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.45 * (1 - t)),
                  width: 3,
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Seri takvim yaprağı flip (2e).
class StreakCalendarFlip extends StatelessWidget {
  final int streak;
  final bool play;
  const StreakCalendarFlip({
    super.key,
    required this.streak,
    this.play = true,
  });

  @override
  Widget build(BuildContext context) {
    final prev = (streak - 1).clamp(0, 999);

    Widget card(int n, {required bool accent}) {
      return Container(
        width: 64,
        height: 74,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GÜN',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: accent
                    ? const Color(0xFFC1502F)
                    : AppColors.navy.withValues(alpha: 0.4),
              ),
            ),
            Text(
              '$n',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: accent ? AppColors.coral : AppColors.navy,
              ),
            ),
          ],
        ),
      );
    }

    if (!play || AppMotion.reduce(context) || streak <= 1) {
      return card(streak, accent: true);
    }

    return SizedBox(
      width: 64,
      height: 74,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 640),
        curve: AppMotion.curve,
        builder: (context, t, _) {
          // 0..0.45 eski yaprak çıkar, 0.45..1 yeni gelir
          if (t < 0.45) {
            final p = t / 0.45;
            return Opacity(
              opacity: 1 - p,
              child: Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateX(p * 1.2),
                child: card(prev, accent: false),
              ),
            );
          }
          final p = (t - 0.45) / 0.55;
          return Opacity(
            opacity: p,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateX((1 - p) * -1.2),
              child: card(streak, accent: true),
            ),
          );
        },
      ),
    );
  }
}

/// XP jetonlarının üst sağdaki pill'e uçuşu (2h).
class XpFlightBurst extends StatelessWidget {
  final int xp;
  final Widget pill;
  const XpFlightBurst({super.key, required this.xp, required this.pill});

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduce(context) || xp <= 0) return pill;
    final coins = (xp / 10).round().clamp(1, 5);
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < coins; i++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 620),
              curve: const Cubic(0.4, 0, 0.6, 1),
              builder: (context, t, _) {
                final delay = (i * 0.09).clamp(0.0, 0.4);
                final local = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
                final left = 16.0 + i * 36;
                final tx = 220.0 - left;
                final ty = -70.0;
                return Positioned(
                  left: left + tx * local,
                  bottom: 8 - ty * local,
                  child: Opacity(
                    opacity: local < 0.12
                        ? local / 0.12
                        : (1 - local).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 1 - 0.55 * local,
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.mustard,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.navy, width: 2),
                        ),
                        child: const Text('+10',
                            style: TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                );
              },
            ),
          Positioned(
            right: 0,
            top: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 1.14),
              duration: const Duration(milliseconds: 400),
              curve: AppMotion.curve,
              builder: (context, s, child) =>
                  Transform.scale(scale: s > 1.07 ? 2.14 - s : s, child: child),
              child: pill,
            ),
          ),
        ],
      ),
    );
  }
}

/// Seri +1 kıvılcımları.
class StreakBurst extends StatelessWidget {
  final Widget child;
  final bool play;
  const StreakBurst({super.key, required this.child, this.play = true});

  static const _offsets = <Offset>[
    Offset(-46, -34),
    Offset(46, -34),
    Offset(-58, 6),
    Offset(58, 6),
    Offset(-26, -52),
    Offset(26, -52),
  ];
  static const _colors = [
    AppColors.teal,
    AppColors.coral,
    AppColors.mustard,
    AppColors.das,
  ];

  @override
  Widget build(BuildContext context) {
    if (!play || AppMotion.reduce(context)) return child;
    return SizedBox(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < _offsets.length; i++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 620),
              curve: AppMotion.curve,
              builder: (context, t, _) {
                final o = _offsets[i];
                return Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: 1 - t,
                      child: Transform.translate(
                        offset: Offset(o.dx * t, o.dy * t),
                        child: Transform.scale(
                          scale: 0.4 + 0.6 * t,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _colors[i % _colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: AppMotion.streak,
            curve: AppMotion.curve,
            builder: (context, s, child) =>
                Transform.scale(scale: s, child: child),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Adım geçişi: fade + hafif yatay kayma.
/// Outgoing child IgnorePointer — web'de görünmez katman tıklamayı yutmasın.
Widget sessionStepSwitcher({
  required BuildContext context,
  required Object? switchKey,
  required Widget child,
}) {
  final keyed = KeyedSubtree(key: ValueKey(switchKey), child: child);
  if (AppMotion.reduce(context)) return keyed;
  return AnimatedSwitcher(
    duration: AppMotion.transitionIn,
    reverseDuration: AppMotion.transitionOut,
    switchInCurve: AppMotion.curve,
    switchOutCurve: const Cubic(0.4, 0, 1, 1),
    layoutBuilder: (current, previous) {
      return Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.passthrough,
        children: [
            for (final p in previous)
              Positioned.fill(
                child: IgnorePointer(child: p),
              ),
            ?current,
        ],
      );
    },
    transitionBuilder: (c, anim) {
      final slide = Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(anim);
      return FadeTransition(
        opacity: anim,
        child: SlideTransition(position: slide, child: c),
      );
    },
    child: keyed,
  );
}

/// Doğru cevapta artikel renk dalgası (2a).
class ArtikelWaveFill extends StatelessWidget {
  final Color color;
  final bool play;
  final Widget child;
  const ArtikelWaveFill({
    super.key,
    required this.color,
    required this.play,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!play || AppMotion.reduce(context)) return child;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.2, end: 1.5),
              duration: const Duration(milliseconds: 520),
              curve: AppMotion.curve,
              builder: (context, s, _) => Align(
                alignment: Alignment.centerLeft,
                child: Transform.scale(
                  scale: s,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.22),
                    ),
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Yanlış cevap sarsıntısı.
class ShakeX extends StatefulWidget {
  final bool play;
  final Widget child;
  const ShakeX({super.key, required this.play, required this.child});

  @override
  State<ShakeX> createState() => _ShakeXState();
}

class _ShakeXState extends State<ShakeX> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.shake,
  );

  @override
  void initState() {
    super.initState();
    if (widget.play) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (AppMotion.reduce(context)) {
          _c.value = 1;
        } else {
          _c.forward(from: 0);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant ShakeX oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      if (AppMotion.reduce(context)) {
        _c.value = 1;
      } else {
        _c.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.play || AppMotion.reduce(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        // Spec keyframes: 0, -9, 8, -6, 4, -2, 0
        double x;
        if (t < 0.15) {
          x = -9 * (t / 0.15);
        } else if (t < 0.30) {
          x = -9 + 17 * ((t - 0.15) / 0.15);
        } else if (t < 0.45) {
          x = 8 - 14 * ((t - 0.30) / 0.15);
        } else if (t < 0.60) {
          x = -6 + 10 * ((t - 0.45) / 0.15);
        } else if (t < 0.80) {
          x = 4 - 6 * ((t - 0.60) / 0.20);
        } else {
          x = -2 + 2 * ((t - 0.80) / 0.20);
        }
        return Transform.translate(offset: Offset(x, 0), child: child);
      },
      child: widget.child,
    );
  }
}

/// Doğru tile nefes (scale 1 → 1.03 → 1).
class BreatheScale extends StatelessWidget {
  final bool play;
  final Widget child;
  const BreatheScale({super.key, required this.play, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!play || AppMotion.reduce(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.tile,
      curve: AppMotion.curve,
      builder: (context, t, child) {
        final s = t < 0.45
            ? 1 + 0.03 * (t / 0.45)
            : 1.03 - 0.03 * ((t - 0.45) / 0.55);
        return Transform.scale(scale: s, child: child);
      },
      child: child,
    );
  }
}

/// Basit press scale (buton).
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const PressScale({super.key, required this.child, this.onTap});

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down && !AppMotion.reduce(context) ? 0.955 : 1,
        duration: AppMotion.press,
        curve: AppMotion.curve,
        child: widget.child,
      ),
    );
  }
}

/// Flashcard çeviri alanı — sabit yükseklik + reveal.
class TranslationRevealSlot extends StatelessWidget {
  final bool revealed;
  final Widget button;
  final Widget translation;
  const TranslationRevealSlot({
    super.key,
    required this.revealed,
    required this.button,
    required this.translation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: AnimatedSwitcher(
        duration: AppMotion.d(context, AppMotion.reveal),
        switchInCurve: AppMotion.curve,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: revealed
            ? KeyedSubtree(key: const ValueKey('tr'), child: translation)
            : KeyedSubtree(key: const ValueKey('btn'), child: button),
      ),
    );
  }
}

/// Konfeti yerine hafif düşen parçalar (Result zaten confetti kullanıyor;
/// harita/ödül için küçük patlama).
class StampStar extends StatelessWidget {
  final bool play;
  final double size;
  const StampStar({super.key, this.play = true, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final star = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.mustard,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.mustard.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text('★',
          style: TextStyle(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w800,
              color: AppColors.navy)),
    );
    if (!play || AppMotion.reduce(context)) return star;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: AppMotion.curve,
      builder: (context, t, child) {
        final eased = AppMotion.curve.transform(t);
        final s = 2.4 - 1.4 * eased; // 2.4 → 1.0
        final rot = (-26 + 26 * eased) * math.pi / 180;
        return Opacity(
          opacity: eased.clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: rot,
            child: Transform.scale(scale: s.clamp(1.0, 2.4), child: child),
          ),
        );
      },
      child: star,
    );
  }
}
