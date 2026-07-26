import 'l10n/app_localizations.dart';
import 'models.dart';
import 'progress_store.dart';
import 'slice_map.dart';

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

const kL2CurriculumSlices = [
  CurriculumSlice(1, 'A'),
  CurriculumSlice(2, 'B'),
  CurriculumSlice(3, 'C'),
];

const kL2SliceTitlesDe = [
  'Meine Familie',
  'Mein / Meine',
  'Wer ist das?',
];

/// Zigzag yatay ofset (px) — prototip 1a.
const kMapZigzag = [0.0, 52.0, 84.0, 52.0, 0.0, -56.0];

class LektionMapInfo {
  final int n;
  final String titleDe;
  final String titleTr;
  final LektionMapState state;
  final int slicesDone; // tamamlanan dilim
  final int sliceCount; // bu lektion'daki dilim sayısı (L1:5, L2:3)
  final int activeSliceN; // sıradaki dilim (aktifken)
  final int activeSeen; // aktif dilimde görülen kelime
  final int activeTotal; // aktif dilim kelime sayısı
  const LektionMapInfo({
    required this.n,
    required this.titleDe,
    required this.titleTr,
    required this.state,
    required this.slicesDone,
    this.sliceCount = 5,
    this.activeSliceN = 1,
    this.activeSeen = 0,
    this.activeTotal = 0,
  });

  /// Aktif dilim içi ilerleme 0..1
  double get activeFrac {
    if (activeTotal <= 0) return 0;
    return (activeSeen / activeTotal).clamp(0.0, 1.0);
  }
}

class MapNode {
  final MapNodeKind kind;
  final String label;
  final double x;
  final bool isReward;
  final bool celebrate;
  final int? sliceIndex; // 1..5, null = reward
  final int lektionN;
  const MapNode({
    required this.kind,
    required this.label,
    required this.x,
    required this.lektionN,
    this.isReward = false,
    this.celebrate = false,
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

/// L1 dilim ilerlemesi: SR'de tüm kelimeleri görülen dilim sayısı (0..5).
int l1SlicesDone(ProgressStore store, List<VocabItem> vocab) {
  var done = 0;
  for (var i = 1; i <= 5; i++) {
    final tags = schritteForSlice(i);
    final words =
        vocab.where((v) => tags.contains(v.schritt)).map((v) => v.wort);
    if (words.isEmpty) break;
    if (words.every((w) => store.srEntries.containsKey(w))) {
      done = i;
    } else {
      break;
    }
  }
  return done;
}

({int seen, int total, int sliceN}) l1ActiveSliceWords(
  ProgressStore store,
  List<VocabItem> vocab,
) {
  final done = l1SlicesDone(store, vocab);
  final sliceN = (done + 1).clamp(1, 5);
  final tags = schritteForSlice(sliceN);
  final words =
      vocab.where((v) => tags.contains(v.schritt)).map((v) => v.wort).toList();
  final seen = words.where((w) => store.srEntries.containsKey(w)).length;
  return (seen: seen, total: words.length, sliceN: sliceN);
}

int slicesDoneForLektion(
  ProgressStore store,
  List<VocabItem> vocab,
  int lektionId,
) {
  final max = maxSlicesForLektion(lektionId);
  var done = 0;
  for (var i = 1; i <= max; i++) {
    final tags = schritteForSlice(i, lektionId: lektionId);
    final words =
        vocab.where((v) => tags.contains(v.schritt)).map((v) => v.wort);
    if (words.isEmpty) break;
    if (words.every((w) => store.srEntries.containsKey(w))) {
      done = i;
    } else {
      break;
    }
  }
  return done;
}

({int seen, int total, int sliceN}) activeSliceWordsFor(
  ProgressStore store,
  List<VocabItem> vocab,
  int lektionId,
) {
  final max = maxSlicesForLektion(lektionId);
  final done = slicesDoneForLektion(store, vocab, lektionId);
  final sliceN = (done + 1).clamp(1, max);
  final tags = schritteForSlice(sliceN, lektionId: lektionId);
  final words =
      vocab.where((v) => tags.contains(v.schritt)).map((v) => v.wort).toList();
  final seen = words.where((w) => store.srEntries.containsKey(w)).length;
  return (seen: seen, total: words.length, sliceN: sliceN);
}

List<LektionMapInfo> buildLektionMap(
  AppLocalizations l10n,
  ProgressStore store,
  double l1Mastery,
  List<VocabItem> l1Vocab, {
  List<VocabItem> l2Vocab = const [],
}) {
  final done = l1SlicesDone(store, l1Vocab);
  final activeWords = l1ActiveSliceWords(store, l1Vocab);
  final l1Complete = done >= 5;
  final l2Unlocked = l1Mastery >= 0.8 && l2Vocab.isNotEmpty;
  final l2Done = l2Vocab.isEmpty
      ? 0
      : slicesDoneForLektion(store, l2Vocab, 2);
  final l2Active = l2Vocab.isEmpty
      ? (seen: 0, total: 0, sliceN: 1)
      : activeSliceWordsFor(store, l2Vocab, 2);
  final l2Complete = l2Vocab.isNotEmpty && l2Done >= 3;

  final out = <LektionMapInfo>[];
  for (var n = 1; n <= 7; n++) {
    late LektionMapState state;
    var slicesDone = 0;
    var sliceCount = 5;
    var activeSliceN = 1;
    var activeSeen = 0;
    var activeTotal = 0;
    if (n == 1) {
      state = l1Complete ? LektionMapState.complete : LektionMapState.active;
      // L2 aktifken L1 complete kalır; incomplete L1 her zaman active öncelikli
      if (!l1Complete && store.activeLektionId == 2 && l2Unlocked) {
        state = LektionMapState.active;
      }
      slicesDone = done;
      activeSliceN = activeWords.sliceN;
      activeSeen = activeWords.seen;
      activeTotal = activeWords.total;
    } else if (n == 2) {
      sliceCount = 3;
      if (!l2Unlocked) {
        state = LektionMapState.locked;
      } else if (l2Complete) {
        state = LektionMapState.complete;
        slicesDone = 3;
      } else if (l1Complete || store.activeLektionId == 2) {
        state = LektionMapState.active;
        slicesDone = l2Done;
        activeSliceN = l2Active.sliceN;
        activeSeen = l2Active.seen;
        activeTotal = l2Active.total;
      } else {
        state = LektionMapState.next;
        slicesDone = l2Done;
        activeSliceN = l2Active.sliceN;
        activeSeen = l2Active.seen;
        activeTotal = l2Active.total;
      }
    } else {
      state = LektionMapState.locked;
    }
    out.add(LektionMapInfo(
      n: n,
      titleDe: _lektionDe(n),
      titleTr: _lektionTr(l10n, n),
      state: state,
      slicesDone: slicesDone,
      sliceCount: sliceCount,
      activeSliceN: activeSliceN,
      activeSeen: activeSeen,
      activeTotal: activeTotal,
    ));
  }
  return out;
}

List<MapBand> buildMapBands(AppLocalizations l10n, List<LektionMapInfo> leks) {
  return leks.map((l) {
    final nodes = <MapNode>[];
    final sliceCount = l.sliceCount;
    for (var i = 0; i < sliceCount; i++) {
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
      final label = l.n == 2
          ? '$sliceN. ${kL2SliceTitlesDe[i]} · ${kL2CurriculumSlices[i].schrittCode}'
          : '$sliceN. ${sliceLabel(l10n, sliceN)} · ${kCurriculumSlices[i].schrittCode}';
      nodes.add(MapNode(
        kind: kind,
        label: label,
        x: kMapZigzag[i.clamp(0, kMapZigzag.length - 1)],
        lektionN: l.n,
        sliceIndex: sliceN,
      ));
    }
    final rewardDone =
        l.state == LektionMapState.complete || l.slicesDone >= sliceCount;
    final rewardKind = rewardDone
        ? MapNodeKind.reward
        : (l.state == LektionMapState.active
            ? MapNodeKind.reward
            : MapNodeKind.locked);
    nodes.add(MapNode(
      kind: rewardKind,
      label: '${l10n.mapSectionReward} · ${l.titleDe}',
      x: kMapZigzag[(sliceCount).clamp(0, kMapZigzag.length - 1)],
      lektionN: l.n,
      isReward: true,
      celebrate: rewardDone,
    ));
    return MapBand(info: l, nodes: nodes);
  }).toList();
}

int totalSlicesDone(List<LektionMapInfo> leks) {
  var t = 0;
  for (final l in leks) {
    t += l.slicesDone.clamp(0, l.sliceCount);
  }
  return t;
}
