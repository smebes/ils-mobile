import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../audio_service.dart';
import '../l10n/l10n_ext.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'exercise_widgets.dart';
import '../l10n/app_localizations.dart';
import 'flashcard_widget.dart';
import 'result_screen.dart';

String _sliceTitle(AppLocalizations l10n, int n) {
  switch (n) {
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
  List<String> _allWords = [];
  int _index = 0;
  int _correct = 0;
  int _answerable = 0;
  int _reviewsScheduled = 0;
  int _cardCount = 0;
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    final lektion = await contentRepo.loadLektion();
    final exercises = await contentRepo.loadExercises();
    _allWords = lektion.vocab.map((v) => v.wort).toList();

    _sessionWords = progressStore.dailyWordQueue(_allWords, size: 15);
    _reviewsScheduled = progressStore.dueReviewCount(_allWords);

    final vocabByWord = {for (final v in lektion.vocab) v.wort: v};
    final cards = _sessionWords
        .where(vocabByWord.containsKey)
        .map((w) => _Step.card(vocabByWord[w]!))
        .toList();
    _cardCount = cards.length;

    final steps = <_Step>[
      ...cards,
      ...exercises.map((e) => _Step.ex(e)),
    ];
    _answerable = exercises.length;
    if (mounted) setState(() => _steps = steps);
  }

  /// UI önce ilerler; SR/disk arka planda — Weiter/X kilitlenmesin.
  void _advance(bool? correct, {Exercise? exercise}) {
    if (_advancing || _steps == null) return;
    _advancing = true;

    if (correct == true) _correct++;

    final words = (exercise != null && correct != null)
        ? _wordsTouchedByExercise(exercise)
        : const <String>[];

    if (_index + 1 >= _steps!.length) {
      unawaited(() async {
        if (words.isNotEmpty && correct != null) {
          try {
            await progressStore.recordAnswersBatch(words, correct);
          } catch (e) {
            debugPrint('SR batch: $e');
          }
        }
        if (!mounted) return;
        await _finish();
        _advancing = false;
      }());
      return;
    }

    setState(() {
      _index++;
      _advancing = false;
    });

    if (words.isNotEmpty && correct != null) {
      unawaited(
        progressStore.recordAnswersBatch(words, correct).catchError((e) {
          debugPrint('SR batch: $e');
        }),
      );
    }
  }

  void _onFlashcardNext(VocabItem v) {
    if (_advancing || _steps == null) return;
    _advancing = true;

    unawaited(
      progressStore.introduceWord(v.wort).catchError((e) {
        debugPrint('introduceWord: $e');
      }),
    );

    if (_index + 1 >= _steps!.length) {
      unawaited(() async {
        if (!mounted) return;
        await _finish();
        _advancing = false;
      }());
      return;
    }

    setState(() {
      _index++;
      _advancing = false;
    });
  }

  List<String> _wordsTouchedByExercise(Exercise ex) {
    final blob = json.encode(ex.payload).toLowerCase();
    final candidates = _allWords.isNotEmpty ? _allWords : _sessionWords;
    final sorted = [...candidates]
      ..sort((a, b) => b.length.compareTo(a.length));

    final hit = <String>[];
    for (final w in sorted) {
      final wl = w.toLowerCase().trim();
      if (wl.length <= 2) continue;
      final escaped = RegExp.escape(wl);
      final re = RegExp('(?<![a-zäöüß])$escaped(?![a-zäöüß])');
      if (re.hasMatch(blob)) {
        hit.add(w);
        if (hit.length >= 12) break;
      }
    }
    return hit;
  }

  Future<void> _finish() async {
    final xpGained = _correct * 10;
    final streakBefore = progressStore.streak;
    final alreadyDone = progressStore.dailyGoalDoneToday;
    try {
      await progressStore.addXp(xpGained);
      await progressStore.completeDailyGoal();
    } catch (e) {
      debugPrint('finish persist: $e');
    }
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          correct: _correct,
          total: _answerable,
          xp: xpGained,
          reviewsSaved: _reviewsScheduled + _sessionWords.length,
          streak: progressStore.streak,
          streakIncreased: !alreadyDone && progressStore.streak >= streakBefore,
        ),
      ),
    );
  }

  void _closeSession() {
    AudioService.shared.stopIfPlaying();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = _steps;
    if (steps == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final step = steps[_index];
    final progress = (_index + 1) / steps.length;
    final slice = progressStore.activeSlice;
    final showTeaser =
        _cardCount > 0 && _index == _cardCount - 1 && step.isCard;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 18, 6),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.07),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18),
                    ),
                    onPressed: _closeSession,
                  ),
                  Expanded(child: SessionProgressBar(progress)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${_index + 1}/${steps.length}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      l10n.sessionSliceChip(slice, _sliceTitle(l10n, slice)),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F7268),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.sessionStepLabel(_index + 1, steps.length),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy.withValues(alpha: 0.5),
                    ),
                  ),
                  if (showTeaser) ...[
                    const Spacer(),
                    Text(
                      l10n.sessionTeaserDialog,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC1502F),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(child: _buildStep(step)),
          ],
        ),
      ),
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
