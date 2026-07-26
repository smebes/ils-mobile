import 'l10n/app_localizations.dart';
import 'progress_store.dart';

/// Müfredat haritası: 7 bölüm × 5 dilim (+ bölüm ödülü).
enum MapNodeKind { done, active, next, locked, reward }

enum LektionMapState { active, next, locked, complete }

class CurriculumSlice {
  final int index; // 1..5
  final String schrittCode;
  const CurriculumSlice(this.index, this.schrittCode);
}

const kCurriculumSlices = [
  CurriculumSlice(1, 'Folge + A'),
  CurriculumSlice(2, 'B'),
  CurriculumSlice(3, 'C'),
  CurriculumSlice(4, 'D'),
  CurriculumSlice(5, 'E'),
];

/// Zigzag yatay ofset (px) — prototip 1a.
const kMapZigzag = [0.0, 52.0, 84.0, 52.0, 0.0, -56.0];

class LektionMapInfo {
  final int n;
  final String titleDe;
  final String titleTr;
  final LektionMapState state;
  final int slicesDone; // 0..5
  const LektionMapInfo({
    required this.n,
    required this.titleDe,
    required this.titleTr,
    required this.state,
    required this.slicesDone,
  });
}

class MapNode {
  final MapNodeKind kind;
  final String label;
  final double x;
  final bool isReward;
  final int? sliceIndex; // 1..5, null = reward
  final int lektionN;
  const MapNode({
    required this.kind,
    required this.label,
    required this.x,
    required this.lektionN,
    this.isReward = false,
    this.sliceIndex,
  });
}

class MapBand {
  final LektionMapInfo info;
  final List<MapNode> nodes;
  const MapBand({required this.info, required this.nodes});
}

String _lektionDe(int n) {
  switch (n) {
    case 1:
      return 'Guten Tag';
    case 2:
      return 'Meine Familie';
    case 3:
      return 'Einkaufen';
    case 4:
      return 'Meine Wohnung';
    case 5:
      return 'Tagesabläufe';
    case 6:
      return 'Freizeit';
    case 7:
      return 'Kinder und Schule';
    default:
      return 'Lektion $n';
  }
}

String _lektionTr(AppLocalizations l10n, int n) {
  String tr(String pathTitle) => pathTitle.split('·').last.trim();
  switch (n) {
    case 1:
      return tr(l10n.pathTitleL1);
    case 2:
      return tr(l10n.pathTitleL2);
    case 3:
      return tr(l10n.pathTitleL3);
    case 4:
      return tr(l10n.pathTitleL4);
    case 5:
      return tr(l10n.pathTitleL5);
    case 6:
      return tr(l10n.pathTitleL6);
    case 7:
      return tr(l10n.pathTitleL7);
    default:
      return '';
  }
}

String sliceLabel(AppLocalizations l10n, int i) {
  switch (i) {
    case 1:
      return l10n.slice1Title;
    case 2:
      return l10n.slice2Title;
    case 3:
      return l10n.slice3Title;
    case 4:
      return l10n.slice4Title;
    default:
      return l10n.slice5Title;
  }
}

/// L1 dilim ilerlemesi: tamamlanan dilim sayısı (0..5).
int l1SlicesDone(ProgressStore store) {
  final active = store.activeSlice;
  // activeSlice = sıradaki çalışılacak dilim → öncekiler bitti.
  return (active - 1).clamp(0, 5);
}

List<LektionMapInfo> buildLektionMap(
  AppLocalizations l10n,
  ProgressStore store,
  double l1Mastery,
) {
  final done = l1SlicesDone(store);
  final l1Complete = done >= 5;
  final out = <LektionMapInfo>[];
  for (var n = 1; n <= 7; n++) {
    late LektionMapState state;
    var slicesDone = 0;
    if (n == 1) {
      state = l1Complete ? LektionMapState.complete : LektionMapState.active;
      slicesDone = done;
    } else if (n == 2) {
      state = l1Mastery >= 0.8 ? LektionMapState.next : LektionMapState.locked;
    } else {
      state = LektionMapState.locked;
    }
    out.add(LektionMapInfo(
      n: n,
      titleDe: _lektionDe(n),
      titleTr: _lektionTr(l10n, n),
      state: state,
      slicesDone: slicesDone,
    ));
  }
  return out;
}

List<MapBand> buildMapBands(AppLocalizations l10n, List<LektionMapInfo> leks) {
  return leks.map((l) {
    final nodes = <MapNode>[];
    for (var i = 0; i < 5; i++) {
      final MapNodeKind kind;
      if (l.state == LektionMapState.active ||
          l.state == LektionMapState.complete) {
        if (i < l.slicesDone) {
          kind = MapNodeKind.done;
        } else if (l.state == LektionMapState.complete) {
          kind = MapNodeKind.done;
        } else if (i == l.slicesDone) {
          kind = MapNodeKind.active;
        } else {
          kind = MapNodeKind.next;
        }
      } else if (l.state == LektionMapState.next) {
        kind = MapNodeKind.next;
      } else {
        kind = MapNodeKind.locked;
      }
      final sliceN = i + 1;
      nodes.add(MapNode(
        kind: kind,
        label: '$sliceN. ${sliceLabel(l10n, sliceN)} · ${kCurriculumSlices[i].schrittCode}',
        x: kMapZigzag[i],
        lektionN: l.n,
        sliceIndex: sliceN,
      ));
    }
    final rewardKind = (l.state == LektionMapState.complete || l.slicesDone >= 5)
        ? MapNodeKind.reward
        : (l.state == LektionMapState.active
            ? MapNodeKind.reward
            : MapNodeKind.locked);
    nodes.add(MapNode(
      kind: rewardKind,
      label: '${l10n.mapSectionReward} · ${l.titleDe}',
      x: kMapZigzag[5],
      lektionN: l.n,
      isReward: true,
    ));
    return MapBand(info: l, nodes: nodes);
  }).toList();
}

int totalSlicesDone(List<LektionMapInfo> leks) {
  var t = 0;
  for (final l in leks) {
    t += l.slicesDone.clamp(0, 5);
  }
  return t;
}
