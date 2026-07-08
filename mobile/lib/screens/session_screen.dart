import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../widgets.dart';
import 'exercise_widgets.dart';
import 'flashcard_widget.dart';
import 'result_screen.dart';

/// Bir oturum adımı: ya bir flashcard (vocab) ya da bir egzersiz.
class _Step {
  final VocabItem? vocab;
  final Exercise? exercise;
  _Step.card(this.vocab) : exercise = null;
  _Step.ex(this.exercise) : vocab = null;
  bool get isCard => vocab != null;
}

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});
  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  List<_Step>? _steps;
  int _index = 0;
  int _correct = 0;
  int _answerable = 0; // puanlanabilir adım sayısı (egzersizler)

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    final lektion = await contentRepo.loadLektion();
    final exercises = await contentRepo.loadExercises();
    final steps = <_Step>[
      // İlk 6 kelime tanıtım kartı
      ...lektion.vocab.take(6).map((v) => _Step.card(v)),
      // Sonra tüm egzersizler
      ...exercises.map((e) => _Step.ex(e)),
    ];
    _answerable = exercises.length;
    if (mounted) setState(() => _steps = steps);
  }

  void _advance(bool? correct) {
    if (correct == true) _correct++;
    if (_index + 1 >= _steps!.length) {
      _finish();
    } else {
      setState(() => _index++);
    }
  }

  Future<void> _finish() async {
    final xpGained = _correct * 10;
    await progressStore.addXp(xpGained);
    await progressStore.completeDailyGoal();
    // Tanıtılan kelimeleri "görüldü" say (V2'de SR kutusuyla değişecek)
    final lektion = await contentRepo.loadLektion();
    for (final v in lektion.vocab.take(6)) {
      await progressStore.markMastered(v.wort);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ResultScreen(
        correct: _correct,
        total: _answerable,
        xp: xpGained,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    if (steps == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final step = steps[_index];
    final progress = _index / steps.length;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Expanded(child: SessionProgressBar(progress)),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: _buildStep(step),
      ),
    );
  }

  Widget _buildStep(_Step step) {
    if (step.isCard) {
      return FlashcardWidget(
        key: ValueKey('card_$_index'),
        vocab: step.vocab!,
        onNext: () => _advance(null),
      );
    }
    final ex = step.exercise!;
    final key = ValueKey('ex_${ex.id}');
    switch (ex.mechanic) {
      case Mechanic.quiz:
        return QuizWidget(key: key, exercise: ex, onComplete: _advance);
      case Mechanic.fillBlank:
        return FillBlankWidget(key: key, exercise: ex, onComplete: _advance);
      case Mechanic.listening:
        return ListeningWidget(key: key, exercise: ex, onComplete: _advance);
      case Mechanic.matching:
        return MatchingWidget(key: key, exercise: ex, onComplete: _advance);
      default:
        return Center(child: Text('Desteklenmeyen: ${ex.mechanic}'));
    }
  }
}
