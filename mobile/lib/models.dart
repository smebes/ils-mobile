// Veri modelleri — content/l3/*.json şemasına karşılık gelir.

class VocabItem {
  final String wort;
  final String? artikel;
  final String? plural;
  final String image;
  final String? audio;
  final String uebersetzungTr;

  VocabItem({
    required this.wort,
    this.artikel,
    this.plural,
    required this.image,
    this.audio,
    required this.uebersetzungTr,
  });

  String get display => artikel != null ? '$artikel $wort' : wort;

  factory VocabItem.fromJson(Map<String, dynamic> j) => VocabItem(
        wort: j['wort'] as String,
        artikel: j['artikel'] as String?,
        plural: j['plural'] as String?,
        image: AssetPaths.resolve(j['image'] as String),
        audio: j['audio'] != null ? j['audio'] as String : null,
        uebersetzungTr: (j['uebersetzung_tr'] ?? '') as String,
      );
}

class Lektion {
  final int id;
  final String titel;
  final String thema;
  final String coverImage;
  final List<String> grammarFocus;
  final List<VocabItem> vocab;

  Lektion({
    required this.id,
    required this.titel,
    required this.thema,
    required this.coverImage,
    required this.grammarFocus,
    required this.vocab,
  });

  factory Lektion.fromJson(Map<String, dynamic> j) {
    final l = j['lektion'] as Map<String, dynamic>;
    return Lektion(
      id: l['id'] as int,
      titel: l['titel'] as String,
      thema: (l['thema'] ?? '') as String,
      coverImage: AssetPaths.resolve(l['cover_image'] as String),
      grammarFocus:
          (l['grammar_focus'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      vocab: (j['vocab'] as List)
          .map((e) => VocabItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

enum Mechanic { flashcard, matching, fillBlank, listening, quiz, unknown }

Mechanic mechanicFrom(String s) {
  switch (s) {
    case 'matching':
      return Mechanic.matching;
    case 'fill_blank':
      return Mechanic.fillBlank;
    case 'listening':
      return Mechanic.listening;
    case 'quiz':
      return Mechanic.quiz;
    default:
      return Mechanic.unknown;
  }
}

class Exercise {
  final String id;
  final Mechanic mechanic;
  final String grammarTopic;
  final Map<String, dynamic> payload;
  final dynamic solution;

  Exercise({
    required this.id,
    required this.mechanic,
    required this.grammarTopic,
    required this.payload,
    required this.solution,
  });

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
        id: j['id'] as String,
        mechanic: mechanicFrom(j['mechanic'] as String),
        grammarTopic: (j['grammar_topic'] ?? '') as String,
        payload: (j['payload'] as Map).cast<String, dynamic>(),
        solution: j['solution'],
      );

  String get instruction => (payload['instruction'] ?? '') as String;
}

/// JSON içindeki depo yollarını Flutter asset yollarına çevirir.
///   assets/vocab/x.svg     -> assets/vocab/x.svg
///   public/img/x.webp      -> assets/img/x.webp
///   storage/audio/l3/...   -> assets/audio/l3/...
class AssetPaths {
  static String resolve(String raw) {
    if (raw.startsWith('assets/vocab/')) return raw;
    if (raw.startsWith('public/img/')) {
      return 'assets/img/${raw.substring('public/img/'.length)}';
    }
    if (raw.startsWith('storage/audio/')) {
      return 'assets/audio/${raw.substring('storage/audio/'.length)}';
    }
    return raw;
  }

  static List<String> resolveList(List? raw) =>
      (raw ?? []).map((e) => resolve(e.toString())).toList();
}
