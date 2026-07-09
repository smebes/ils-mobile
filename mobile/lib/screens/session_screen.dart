import 'dart:convert';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../widgets.dart';
import 'exercise_widgets.dart';
import 'flashcard_widget.dart';
import 'result_screen.dart';

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
  List<String> _sessionWords = [];
  int _index = 0;
  int _correct = 0;
  int _answerable = 0;
  int _reviewsScheduled = 0;

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    final lektion = await contentRepo.loadLektion();
    final exercises = await contentRepo.loadExercises();
    final allWorts = lektion.vocab.map((v) => v.wort).toList();

    _sessionWords = progressStore.dailyWordQueue(allWorts, size: 15);
    _reviewsScheduled = progressStore.dueReviewCount(allWorts);

    final vocabByWord = {for (final v in lektion.vocab) v.wort: v};
    final cards = _sessionWords
        .where(vocabByWord.containsKey)
        .map((w) => _Step.card(vocabByWord[w]!));

    final steps = <_Step>[
      ...cards,
      ...exercises.map((e) => _Step.ex(e)),
    ];
    _answerable = exercises.length;
    if (mounted) setState(() => _steps = steps);
  }

  Future<void> _advance(bool? correct, {Exercise? exercise}) async {
    if (correct == true) _correct++;
    if (exercise != null && correct != null) {
      await _updateSrForExercise(exercise, correct);
    }
    if (_index + 1 >= _steps!.length) {
      _finish();
    } else {
      setState(() => _index++);
    }
  }

  Future<void> _onFlashcardNext(VocabItem v) async {
    await progressStore.introduceWord(v.wort);
    _advance(null);
  }

  Future<void> _updateSrForExercise(Exercise ex, bool correct) async {
    for (final w in _wordsTouchedByExercise(ex)) {
      await progressStore.recordAnswer(w, correct);
    }
  }

  List<String> _wordsTouchedByExercise(Exercise ex) {
    final blob = json.encode(ex.payload).toLowerCase();
    return _sessionWords
        .where((w) => blob.contains(w.toLowerCase()))
        .toList();
  }

  Future<void> _finish() async {
    final xpGained = _correct * 10;
    await progressStore.addXp(xpGained);
    await progressStore.completeDailyGoal();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          correct: _correct,
          total: _answerable,
          xp: xpGained,
          reviewsSaved: _reviewsScheduled + _sessionWords.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    if (steps == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final step = steps[_index];
    final progress = (_index + 1) / steps.length;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(child: SessionProgressBar(progress)),
          ],
        ),
      ),
      body: SafeArea(top: false, child: _buildStep(step)),
    );
  }

  Widget _buildStep(_Step step) {
    if (step.isCard) {
      return FlashcardWidget(
        key: ValueKey('card_${step.vocab!.wort}'),
        vocab: step.vocab!,
        onNext: () => _onFlashcardNext(step.vocab!),
      );
    }
    final ex = step.exercise!;
    final key = ValueKey('ex_${ex.id}');
    void done(bool c) => _advance(c, exercise: ex);
    switch (ex.mechanic) {
      case Mechanic.quiz:
        return QuizWidget(key: key, exercise: ex, onComplete: done);
      case Mechanic.fillBlank:
        return FillBlankWidget(key: key, exercise: ex, onComplete: done);
      case Mechanic.listening:
        return ListeningWidget(key: key, exercise: ex, onComplete: done);
      case Mechanic.matching:
        return MatchingWidget(key: key, exercise: ex, onComplete: done);
      default:
        return Center(child: Text('Desteklenmeyen: ${ex.mechanic}'));
    }
  }
}
