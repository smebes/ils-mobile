import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import '../audio_service.dart';
import '../tts_service.dart';

/// Her egzersiz widget'ı kendi kontrol → geri bildirim → Weiter döngüsünü
/// yönetir ve bitince onComplete(correct) çağırır.
typedef ExerciseDone = void Function(bool correct);

/// Ortak alt yapı: içerik + (Prüfen | FeedbackBar).
abstract class ExerciseScaffold extends StatefulWidget {
  final Exercise exercise;
  final ExerciseDone onComplete;
  const ExerciseScaffold(
      {super.key, required this.exercise, required this.onComplete});
}

mixin CheckFlow<T extends StatefulWidget> on State<T> {
  bool checked = false;
  bool correct = false;

  bool get canCheck; // alt sınıf: cevap seçildi mi?
  bool computeCorrect(); // alt sınıf: doğru mu?
  String get feedbackMessage => '';

  void doCheck() {
    setState(() {
      correct = computeCorrect();
      checked = true;
    });
  }

  Widget buildBottom(ExerciseDone onComplete) {
    if (checked) {
      return FeedbackBar(
        correct: correct,
        message: feedbackMessage,
        cta: 'Weiter',
        onNext: () => onComplete(correct),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: canCheck ? doCheck : null,
          child: const Text('Prüfen'),
        ),
      ),
    );
  }
}

Widget exerciseHeader(String instruction) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Text(instruction,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    );

// ─────────────────────────────── QUIZ ───────────────────────────────
class QuizWidget extends ExerciseScaffold {
  const QuizWidget(
      {super.key, required super.exercise, required super.onComplete});
  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> with CheckFlow {
  String? selected;
  late final List options =
      (widget.exercise.payload['options'] as List).cast<Map>();
  late final String answer =
      (widget.exercise.solution['answer']) as String;

  @override
  bool get canCheck => selected != null;
  @override
  bool computeCorrect() => selected == answer;
  @override
  String get feedbackMessage =>
      (widget.exercise.solution['explanation'] ?? '') as String;

  @override
  Widget build(BuildContext context) {
    final p = widget.exercise.payload;
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              exerciseHeader(widget.exercise.instruction),
              if (p['image'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MediaImage(AssetPaths.resolve(p['image']),
                        height: 160, fit: BoxFit.cover),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(p['question'] as String,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              ...options.map((o) {
                final id = o['id'] as String;
                return _OptionTile(
                  text: o['text'] as String,
                  selected: selected == id,
                  state: !checked
                      ? null
                      : id == answer
                          ? true
                          : (selected == id ? false : null),
                  onTap: checked ? null : () => setState(() => selected = id),
                );
              }),
            ],
          ),
        ),
        buildBottom(widget.onComplete),
      ],
    );
  }
}

// ─────────────────────────────── FILL BLANK ───────────────────────────────
class FillBlankWidget extends ExerciseScaffold {
  const FillBlankWidget(
      {super.key, required super.exercise, required super.onComplete});
  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> with CheckFlow {
  late final List blanks =
      (widget.exercise.payload['blanks'] as List).cast<Map>();
  final Map<String, String> answers = {}; // blankId -> girilen
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    for (final b in blanks) {
      final id = b['id'] as String;
      if (b['options'] == null) controllers[id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  bool get canCheck {
    for (final b in blanks) {
      final id = b['id'] as String;
      final v = b['options'] != null
          ? answers[id]
          : controllers[id]?.text.trim();
      if (v == null || v.isEmpty) return false;
    }
    return true;
  }

  String _norm(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[.,!?]'), '');

  @override
  bool computeCorrect() {
    final sol = widget.exercise.solution as Map;
    for (final b in blanks) {
      final id = b['id'] as String;
      final given = _norm(b['options'] != null
          ? (answers[id] ?? '')
          : (controllers[id]?.text ?? ''));
      final s = sol[id] as Map;
      final accept = <String>[
        s['answer'].toString(),
        ...((s['accept'] as List?)?.map((e) => e.toString()) ?? [])
      ].map(_norm).toSet();
      if (!accept.contains(given)) return false;
    }
    return true;
  }

  @override
  String get feedbackMessage {
    if (correct) return '';
    final sol = widget.exercise.solution as Map;
    final parts = blanks.map((b) {
      final id = b['id'] as String;
      return (sol[id] as Map)['answer'];
    }).join(', ');
    return 'Doğru cevap: $parts';
  }

  @override
  Widget build(BuildContext context) {
    final sentence = widget.exercise.payload['sentence'] as String;
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              exerciseHeader(widget.exercise.instruction),
              if (widget.exercise.payload['hint'] != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    widget.exercise.payload['hint'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.navy.withValues(alpha: 0.65),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: _renderSentence(sentence),
              ),
              ...blanks.where((b) => b['options'] != null).map((b) {
                final id = b['id'] as String;
                final opts = (b['options'] as List).cast<String>();
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: opts.map((o) {
                      final sel = answers[id] == o;
                      return ChoiceChip(
                        label: Text(o),
                        selected: sel,
                        onSelected: checked
                            ? null
                            : (_) => setState(() => answers[id] = o),
                        selectedColor: AppColors.teal.withValues(alpha: 0.25),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
        buildBottom(widget.onComplete),
      ],
    );
  }

  static const _sentStyle = TextStyle(fontSize: 22, height: 1.6);

  Widget _renderSentence(String sentence) {
    final re = RegExp(r'\{\{(\w+)\}\}');
    final children = <Widget>[];
    int last = 0;
    for (final m in re.allMatches(sentence)) {
      if (m.start > last) {
        children.add(Text(
          sentence.substring(last, m.start),
          style: _sentStyle,
        ));
      }
      final id = m.group(1)!;
      final hasOptions =
          blanks.firstWhere((b) => b['id'] == id)['options'] != null;

      // Trailing punctuation after blank (". " or ", " etc.) stays with blank
      String trailing = '';
      int afterBlank = m.end;
      while (afterBlank < sentence.length &&
          '.,;:!?'.contains(sentence[afterBlank])) {
        trailing += sentence[afterBlank];
        afterBlank++;
      }

      Widget blankWidget;
      if (hasOptions) {
        blankWidget = Text(
          answers[id] ?? '____',
          style: _sentStyle.copyWith(
            fontWeight: FontWeight.w800,
            color: answers[id] != null ? AppColors.teal : AppColors.coral,
          ),
        );
      } else {
        blankWidget = SizedBox(
          width: 120,
          child: TextField(
            controller: controllers[id],
            enabled: !checked,
            onChanged: (_) => setState(() {}),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              isDense: true,
              hintText: '…',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.teal, width: 2),
              ),
            ),
          ),
        );
      }

      if (trailing.isNotEmpty) {
        children.add(Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            blankWidget,
            Text(trailing, style: _sentStyle),
          ],
        ));
        last = afterBlank;
      } else {
        children.add(blankWidget);
        last = m.end;
      }
    }
    if (last < sentence.length) {
      final tail = sentence.substring(last);
      if (tail.trim().isNotEmpty) {
        children.add(Text(tail, style: _sentStyle));
      }
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 12,
      children: children,
    );
  }
}

// ─────────────────────────────── LISTENING ───────────────────────────────
class ListeningWidget extends ExerciseScaffold {
  const ListeningWidget(
      {super.key, required super.exercise, required super.onComplete});
  @override
  State<ListeningWidget> createState() => _ListeningWidgetState();
}

class _ListeningWidgetState extends State<ListeningWidget> with CheckFlow {
  final _audio = AudioService();
  late final List questions =
      (widget.exercise.payload['questions'] as List).cast<Map>();
  final Map<String, String> answers = {}; // qId -> optionId

  List<String> _audioList(String speed) => AssetPaths.resolveList(
      (widget.exercise.payload['audio'] as Map?)?[speed] as List?);

  List<String> get _transcriptLines {
    final lines = widget.exercise.payload['lines'] as List?;
    if (lines == null) return const [];
    return lines
        .map((e) => (e as Map)['text']?.toString() ?? '')
        .where((t) => t.isNotEmpty)
        .toList();
  }

  Future<void> _play(String speed) async {
    final files = _audioList(speed);
    if (files.isNotEmpty) {
      await _audio.playSequence(files);
      return;
    }
    // ElevenLabs henüz yoksa: satırları TTS ile oku (de-DE).
    final lines = _transcriptLines;
    if (lines.isEmpty) return;
    for (final t in lines) {
      TtsService.speak(t);
      await Future<void>.delayed(
        Duration(milliseconds: 600 + t.length * 55),
      );
    }
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  bool get canCheck => answers.length == questions.length;
  @override
  bool computeCorrect() {
    final sol = widget.exercise.solution as Map;
    for (final q in questions) {
      final id = q['id'] as String;
      if (answers[id] != sol[id]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.exercise.payload;
    final sol = widget.exercise.solution as Map;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              exerciseHeader(widget.exercise.instruction),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (p['scene_image'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: MediaImage(AssetPaths.resolve(p['scene_image']),
                            height: 80, fit: BoxFit.cover),
                      ),
                    if (p['scene_image'] != null) const SizedBox(width: 12),
                    Column(
                      children: [
                        SpeedButtons(
                          onSlow: () => _play('slow'),
                          onNormal: () => _play('normal'),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${answers.length} / ${questions.length} beantwortet',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.navy.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...questions.map((q) {
                final id = q['id'] as String;
                final opts = (q['options'] as List).cast<Map>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Text(q['q'] as String,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                    ...opts.map((o) {
                      final oid = o['id'] as String;
                      return _OptionTile(
                        text: o['text'] as String,
                        selected: answers[id] == oid,
                        state: !checked
                            ? null
                            : oid == sol[id]
                                ? true
                                : (answers[id] == oid ? false : null),
                        onTap: checked
                            ? null
                            : () => setState(() => answers[id] = oid),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
        buildBottom(widget.onComplete),
      ],
    );
  }
}

// ─────────────────────────────── MATCHING ───────────────────────────────
class MatchingWidget extends ExerciseScaffold {
  const MatchingWidget(
      {super.key, required super.exercise, required super.onComplete});
  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> with CheckFlow {
  late final List<Map> left;
  late final List<Map> right;
  final Map<String, String> pairs = {}; // leftId -> rightId
  String? activeLeft;

  @override
  void initState() {
    super.initState();
    left = List<Map>.from(
        (widget.exercise.payload['left'] as List).cast<Map>())
      ..shuffle();
    right = List<Map>.from(
        (widget.exercise.payload['right'] as List).cast<Map>())
      ..shuffle();
    activeLeft = left.first['id'] as String;
  }

  @override
  bool get canCheck => pairs.length == left.length;

  @override
  bool computeCorrect() {
    final sol = widget.exercise.solution as Map;
    for (final e in pairs.entries) {
      if (sol[e.key] != e.value) return false;
    }
    return pairs.length == sol.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        exerciseHeader(widget.exercise.instruction),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _leftColumn()),
                const SizedBox(width: 12),
                Expanded(child: _rightColumn()),
              ],
            ),
          ),
        ),
        buildBottom(widget.onComplete),
      ],
    );
  }

  Widget _leftColumn() {
    return ListView(
      children: left.asMap().entries.map((e) {
        final idx = e.key + 1;
        final item = e.value;
        final id = item['id'] as String;
        final assigned = pairs.containsKey(id);
        final isActive = activeLeft == id;
        Color? border;
        if (checked && assigned) {
          final sol = widget.exercise.solution as Map;
          border = sol[id] == pairs[id] ? AppColors.das : AppColors.coral;
        } else if (isActive) {
          border = AppColors.teal;
        } else if (assigned) {
          border = AppColors.mustard;
        }
        final pairColor = assigned ? _colorForLeft(id) : null;
        return GestureDetector(
          onTap: checked
              ? null
              : () => setState(() => activeLeft = id),
          child: Container(
            height: 64,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: cardDecoration(
              border: checked && assigned
                  ? border
                  : isActive
                      ? AppColors.teal
                      : assigned
                          ? pairColor
                          : null,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor:
                      assigned ? pairColor : AppColors.navy.withValues(alpha: 0.1),
                  child: Text('$idx',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: assigned ? Colors.white : AppColors.navy)),
                ),
                const SizedBox(width: 6),
                Expanded(child: _leftContent(item)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _leftContent(Map item) {
    if (item['image'] != null) {
      if (item['text'] != null) {
        return Row(
          children: [
            MediaImage(AssetPaths.resolve(item['image']), height: 36),
            const SizedBox(width: 4),
            Expanded(
              child: Text(item['text'] as String,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }
      return MediaImage(AssetPaths.resolve(item['image']), height: 42);
    }
    return Text(item['text'] as String,
        style: const TextStyle(fontWeight: FontWeight.w600));
  }

  static const _pairColors = [
    AppColors.teal,
    AppColors.coral,
    AppColors.mustard,
    AppColors.das,
    AppColors.der,
    AppColors.die,
  ];

  Color _colorForLeft(String leftId) {
    final idx = left.indexWhere((l) => l['id'] == leftId);
    return _pairColors[idx % _pairColors.length];
  }

  List<Map> get _unassignedLeft =>
      left.where((l) => !pairs.containsKey(l['id'])).toList();

  Widget _rightColumn() {
    return ListView(
      children: right.map((item) {
        final id = item['id'] as String;
        final pairedLeftIds = pairs.entries
            .where((e) => e.value == id)
            .map((e) => e.key)
            .toList();
        final pairedLeftId =
            pairedLeftIds.isEmpty ? null : pairedLeftIds.first;
        final assigned = pairedLeftId != null;
        final pairColor = assigned ? _colorForLeft(pairedLeftId) : null;
        final leftIdx = assigned
            ? left.indexWhere((l) => l['id'] == pairedLeftId) + 1
            : 0;
        return GestureDetector(
          onTap: checked || activeLeft == null
              ? null
              : () => setState(() {
                    final target = activeLeft!;
                    final manyToOne =
                        widget.exercise.payload['many_to_one'] == true;
                    if (!manyToOne) {
                      // 1:1 — aynı sağ seçenek başka sola bağlıysa kopar
                      pairs.removeWhere((k, v) => v == id);
                    }
                    pairs[target] = id;
                    final remaining = _unassignedLeft;
                    activeLeft = remaining.isEmpty
                        ? null
                        : remaining.first['id'] as String;
                  }),
          child: Container(
            height: 64,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: cardDecoration(border: pairColor),
            child: Row(
              children: [
                if (assigned)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: pairColor,
                    child: Text('$leftIdx',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                if (assigned) const SizedBox(width: 8),
                Expanded(
                  child: Text(item['text'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────── ortak option tile ───────────────────────────────
class _OptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final bool? state; // null=nötr, true=doğru vurgu, false=yanlış vurgu
  final VoidCallback? onTap;
  const _OptionTile({
    required this.text,
    required this.selected,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color border = Colors.transparent;
    Color bg = Colors.white;
    if (state == true) {
      border = AppColors.das;
      bg = AppColors.das.withValues(alpha: 0.1);
    } else if (state == false) {
      border = AppColors.coral;
      bg = AppColors.coral.withValues(alpha: 0.1);
    } else if (selected) {
      border = AppColors.teal;
      bg = AppColors.teal.withValues(alpha: 0.08);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: border == Colors.transparent
                    ? AppColors.navy.withValues(alpha: 0.12)
                    : border,
                width: 2),
          ),
          child: Text(text, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
