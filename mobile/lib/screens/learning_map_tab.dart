import 'package:flutter/material.dart';
import '../curriculum.dart';
import '../l10n/l10n_ext.dart';
import '../main.dart';
import '../models.dart';
import '../motion_widgets.dart';
import '../theme.dart';

/// Öğren sekmesi: 1c özet şerit (sabit) + 1a yılan yol haritası.
class LearningMapTab extends StatelessWidget {
  final String greeting;
  final double mastery;
  final List<VocabItem> vocab;
  final VoidCallback onStart;
  final void Function(int lektionN) onLockedLesson;

  const LearningMapTab({
    super.key,
    required this.greeting,
    required this.mastery,
    required this.vocab,
    required this.onStart,
    required this.onLockedLesson,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final leks = buildLektionMap(l10n, progressStore, mastery, vocab);
    final bands = buildMapBands(l10n, leks);
    final doneTotal = totalSlicesDone(leks);
    final overall = l10n.mapOverallProgress(doneTotal, 35);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.mapTitle,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(overall,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.navy
                                      .withValues(alpha: 0.55))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.coral,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('${progressStore.streak}',
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFC1502F))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(greeting,
                    style: TextStyle(
                        fontSize: 14.5,
                        color: AppColors.navy.withValues(alpha: 0.6))),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onStart,
                    child: Text(l10n.mapContinueCta),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _OverviewHeaderDelegate(
            child: _OverviewStrip(leks: leks),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 28),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final band = bands[index];
                return _BandSection(
                  band: band,
                  onNodeTap: (node) =>
                      _handleNode(context, node, onStart, onLockedLesson),
                );
              },
              childCount: bands.length,
            ),
          ),
        ),
      ],
    );
  }

  void _handleNode(
    BuildContext context,
    MapNode node,
    VoidCallback onStart,
    void Function(int) onLockedLesson,
  ) {
    final l10n = context.l10n;
    if (node.lektionN == 1) {
      if (node.kind == MapNodeKind.active || node.kind == MapNodeKind.done) {
        onStart();
        return;
      }
      if (node.kind == MapNodeKind.next || node.kind == MapNodeKind.reward) {
        _infoSheet(
          context,
          title: node.kind == MapNodeKind.reward
              ? l10n.mapSectionReward
              : l10n.finishTodayFirst,
          cta: l10n.startTodaysLesson,
          onCta: onStart,
        );
        return;
      }
    }
    if (node.lektionN >= 2) {
      onLockedLesson(node.lektionN);
    }
  }

  void _infoSheet(
    BuildContext context, {
    required String title,
    required String cta,
    required VoidCallback onCta,
  }) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, height: 1.3)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                onCta();
              },
              child: Text(cta),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.ok),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStrip extends StatelessWidget {
  final List<LektionMapInfo> leks;
  const _OverviewStrip({required this.leks});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.mapOverviewLabel,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AppColors.navy.withValues(alpha: 0.5))),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final l in leks)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (var i = 0; i < 5; i++)
                                  Expanded(
                                    child: Container(
                                      height: _cellH(l, i),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 0.5),
                                      decoration: BoxDecoration(
                                        color: _cellColor(l, i),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text('${l.n}',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: l.state == LektionMapState.active
                                        ? AppColors.navy
                                        : AppColors.navy
                                            .withValues(alpha: 0.4))),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _legend(AppColors.teal, l10n.mapLegendDone),
                  _legend(AppColors.teal.withValues(alpha: 0.45),
                      l10n.mapLegendNext),
                  _legend(AppColors.navy.withValues(alpha: 0.12),
                      l10n.mapLegendLocked),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _cellH(LektionMapInfo l, int i) {
    if (l.state == LektionMapState.active ||
        l.state == LektionMapState.complete) {
      if (i < l.slicesDone) return 34;
      if (l.state == LektionMapState.complete) return 34;
      if (i == l.slicesDone) {
        // Aktif dilim: kelime ilerlemesine göre yükseklik
        return 16 + 18 * l.activeFrac;
      }
      return 16;
    }
    if (l.state == LektionMapState.next) return 14;
    return 10;
  }

  Color _cellColor(LektionMapInfo l, int i) {
    if (l.state == LektionMapState.active ||
        l.state == LektionMapState.complete) {
      if (i < l.slicesDone || l.state == LektionMapState.complete) {
        return AppColors.teal;
      }
      if (i == l.slicesDone) {
        return AppColors.teal.withValues(alpha: 0.25 + 0.55 * l.activeFrac);
      }
      return AppColors.navy.withValues(alpha: 0.12);
    }
    if (l.state == LektionMapState.next) {
      return AppColors.navy.withValues(alpha: 0.16);
    }
    return AppColors.navy.withValues(alpha: 0.08);
  }

  Widget _legend(Color bg, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 11.5,
                color: AppColors.navy.withValues(alpha: 0.6))),
      ],
    );
  }
}

class _OverviewHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _OverviewHeaderDelegate({required this.child});

  @override
  double get minExtent => 172;
  @override
  double get maxExtent => 172;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _OverviewHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}

class _BandSection extends StatelessWidget {
  final MapBand band;
  final void Function(MapNode node) onNodeTap;
  const _BandSection({required this.band, required this.onNodeTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final info = band.info;
    final active = info.state == LektionMapState.active;
    final locked = info.state == LektionMapState.locked;
    final opacity = locked ? 0.45 : (info.state == LektionMapState.next ? 0.7 : 1.0);

    final pill = active
        ? l10n.mapPillContinue
        : (info.state == LektionMapState.complete
            ? l10n.mapPillDone
            : (info.state == LektionMapState.next
                ? l10n.mapPillLocked
                : l10n.mapPillSoon));
    final sub = active
        ? (info.activeTotal > 0
            ? l10n.mapBandSliceWords(
                info.activeSliceN, info.activeSeen, info.activeTotal)
            : l10n.mapBandProgress(info.slicesDone * 20, info.slicesDone))
        : (info.state == LektionMapState.next
            ? l10n.pathL2Note
            : (info.state == LektionMapState.complete
                ? l10n.mapPillDone
                : l10n.pathSoon));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: active
              ? AppColors.teal.withValues(alpha: 0.07)
              : Colors.transparent,
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.teal
                      : AppColors.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('${info.n}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: active
                            ? Colors.white
                            : AppColors.navy.withValues(alpha: 0.45))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${info.titleDe} · ${info.titleTr}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: active
                                ? AppColors.navy
                                : AppColors.navy.withValues(alpha: 0.7))),
                    Text(sub,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.navy.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.teal.withValues(alpha: 0.14)
                      : AppColors.navy.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(pill,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: active
                            ? const Color(0xFF1F7268)
                            : AppColors.navy.withValues(alpha: 0.5))),
              ),
            ],
          ),
        ),
        Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 14),
            child: Column(
              children: [
                for (var i = 0; i < band.nodes.length; i++)
                  _SnakeNode(
                    node: band.nodes[i],
                    first: i == 0,
                    onTap: () => onNodeTap(band.nodes[i]),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SnakeNode extends StatelessWidget {
  final MapNode node;
  final bool first;
  final VoidCallback onTap;
  const _SnakeNode({
    required this.node,
    required this.first,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _style(node.kind);
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 6),
      child: Center(
        child: Transform.translate(
          offset: Offset(node.x, 0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Column(
                children: [
                  _nodeCircle(style),
                  const SizedBox(height: 5),
                  Text(
                    node.label,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: style.labelColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nodeCircle(_NodeVisual style) {
    final circle = Container(
      width: style.size,
      height: style.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: style.bg,
        border: Border.all(color: style.borderColor, width: style.borderW),
        boxShadow: style.shadows,
      ),
      alignment: Alignment.center,
      child: Text(style.mark,
          style: TextStyle(
              fontSize: style.markSize,
              fontWeight: FontWeight.w800,
              color: style.fg)),
    );
    if (node.kind == MapNodeKind.active) {
      return PulseRing(
        size: style.size,
        color: AppColors.teal,
        child: circle,
      );
    }
    if (node.kind == MapNodeKind.reward && node.celebrate) {
      return StampStar(size: style.size);
    }
    return circle;
  }

  _NodeVisual _style(MapNodeKind kind) {
    switch (kind) {
      case MapNodeKind.done:
        return _NodeVisual(
          bg: AppColors.teal,
          borderColor: Colors.white,
          borderW: 4,
          fg: Colors.white,
          mark: '✓',
          size: 58,
          markSize: 20,
          labelColor: AppColors.navy.withValues(alpha: 0.6),
          shadows: [
            BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        );
      case MapNodeKind.active:
        return _NodeVisual(
          bg: AppColors.teal,
          borderColor: Colors.white,
          borderW: 5,
          fg: Colors.white,
          mark: '▶',
          size: 74,
          markSize: 22,
          labelColor: AppColors.navy,
          shadows: [
            BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.18),
                blurRadius: 0,
                spreadRadius: 6),
            BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        );
      case MapNodeKind.reward:
        return _NodeVisual(
          bg: AppColors.mustard,
          borderColor: Colors.white,
          borderW: 4,
          fg: AppColors.navy,
          mark: '★',
          size: 52,
          markSize: 20,
          labelColor: AppColors.navy.withValues(alpha: 0.55),
          shadows: [
            BoxShadow(
                color: AppColors.mustard.withValues(alpha: 0.45),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        );
      case MapNodeKind.next:
        return _NodeVisual(
          bg: Colors.white,
          borderColor: AppColors.teal.withValues(alpha: 0.55),
          borderW: 3,
          fg: AppColors.teal,
          mark: '',
          size: 58,
          markSize: 18,
          labelColor: AppColors.navy.withValues(alpha: 0.55),
          shadows: [
            BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        );
      case MapNodeKind.locked:
        return _NodeVisual(
          bg: Colors.white,
          borderColor: AppColors.navy.withValues(alpha: 0.14),
          borderW: 3,
          fg: AppColors.navy.withValues(alpha: 0.35),
          mark: '🔒',
          size: 52,
          markSize: 15,
          labelColor: AppColors.navy.withValues(alpha: 0.4),
          shadows: const [],
        );
    }
  }
}

class _NodeVisual {
  final Color bg;
  final Color borderColor;
  final double borderW;
  final Color fg;
  final String mark;
  final double size;
  final double markSize;
  final Color labelColor;
  final List<BoxShadow> shadows;
  const _NodeVisual({
    required this.bg,
    required this.borderColor,
    required this.borderW,
    required this.fg,
    required this.mark,
    required this.size,
    required this.markSize,
    required this.labelColor,
    required this.shadows,
  });
}
