/// L1 dilim (1..5) ↔ content `schritt` etiketleri.
/// Dilim 1 = Folge + A; 2..5 = B..E (Prototype v4).
List<String> schritteForSlice(int slice) {
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
List<String> schritteThroughSlice(int slice) {
  final out = <String>[];
  for (var i = 1; i <= slice.clamp(1, 5); i++) {
    out.addAll(schritteForSlice(i));
  }
  return out;
}

bool schrittInSlice(String? schritt, int slice) {
  if (schritt == null) return false;
  return schritteForSlice(slice).contains(schritt);
}

bool schrittUnlocked(String? schritt, int activeSlice) {
  if (schritt == null) return false;
  return schritteThroughSlice(activeSlice).contains(schritt);
}
