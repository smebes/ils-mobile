/// Lektion dilim (1..N) ↔ content `schritt` etiketleri.
/// L1: Dilim 1 = Folge + A; 2..5 = B..E (Prototype v4).
/// L2: Dilim 1..3 = A..C (Meine Familie açılış).
int maxSlicesForLektion(int lektionId) {
  switch (lektionId) {
    case 2:
      return 3;
    default:
      return 5;
  }
}

List<String> schritteForSlice(int slice, {int lektionId = 1}) {
  if (lektionId == 2) {
    switch (slice.clamp(1, 3)) {
      case 1:
        return const ['A'];
      case 2:
        return const ['B'];
      default:
        return const ['C'];
    }
  }
  switch (slice.clamp(1, 5)) {
    case 1:
      return const ['folge', 'A'];
    case 2:
      return const ['B'];
    case 3:
      return const ['C'];
    case 4:
      return const ['D'];
    default:
      return const ['E'];
  }
}

/// Dilim 1..[slice] dahil tüm Schritt etiketleri (tekrar havuzu).
List<String> schritteThroughSlice(int slice, {int lektionId = 1}) {
  final out = <String>[];
  final max = maxSlicesForLektion(lektionId);
  for (var i = 1; i <= slice.clamp(1, max); i++) {
    out.addAll(schritteForSlice(i, lektionId: lektionId));
  }
  return out;
}

bool schrittInSlice(String? schritt, int slice, {int lektionId = 1}) {
  if (schritt == null) return false;
  return schritteForSlice(slice, lektionId: lektionId).contains(schritt);
}

bool schrittUnlocked(String? schritt, int activeSlice, {int lektionId = 1}) {
  if (schritt == null) return false;
  return schritteThroughSlice(activeSlice, lektionId: lektionId)
      .contains(schritt);
}
