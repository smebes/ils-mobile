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

bool schrittInSlice(String? schritt, int slice) {
  if (schritt == null) return false;
  return schritteForSlice(slice).contains(schritt);
}
