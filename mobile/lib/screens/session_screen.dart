import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../audio_service.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_ext.dart';
import '../main.dart';
import '../models.dart';
import '../motion_widgets.dart';
import '../slice_map.dart';
import '../theme.dart';
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
  /// true = sadece due tekrarlar (Tekrar sekmesi).
  final bool reviewMode;
  const SessionScreen({super.key, this.reviewMode = false});
  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  List<_Step>? _steps;
  List<String> _sessionWords = [];
  List<String> _allWords = [];
  List<String> _sliceWords = [];
  int _index = 0;
  int _correct = 0;
  int _answerable = 0;
  int _reviewsScheduled = 0;
  int _cardCount = 0;
  int _slice = 1;
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
    _slice = progressStore.activeSlice;
    // Tamamlanmış dilimleri atla (SR ile activeSlice senkronu).
    for (var guard = 0; guard < 5; guard++) {
      final tags = schritteForSlice(_slice);
      final words = lektion.vocab
          .where((v) => tags.contains(v.schritt))
          .map((v) => v.wort)
          .toList();
      if (words.isEmpty) break;
      final allSeen = words.every((w) => progressStore.srEntries.containsKey(w));
      if (!allSeen || _slice >= 5) break;
      await progressStore.setActiveSlice(_slice + 1);
      _slice = progressStore.activeSlice;
    }
    final tags = schritteForSlice(_slice);
    final unlocked = schritteThroughSlice(_slice);
    final sliceVocab =
        lektion.vocab.where((v) => tags.contains(v.schritt)).toList();
    final reviewVocab =
        lektion.vocab.where((v) => unlocked.contains(v.schritt)).toList();
    _sliceWords = sliceVocab.map((v) => v.wort).toList();
    final reviewPool = reviewVocab.map((v) => v.wort).toList();

    if (widget.reviewMode) {
      final today = DateTime.now();
      final day = DateTime(today.year, today.month, today.day);
      _sessionWords = _allWords.where((w) {
        final e = progressStore.srEntries[w];
        return e != null && e.isDue(day);
      }).take(12).toList();
      // Due yoksa zayıf kelimelerle kısa tekrar — ama egzersiz ekleme.
      if (_sessionWords.isEmpty) {
        _sessionWords = progressStore.weakWords(_allWords, limit: 8);
      }
    } else {
      _sessionWords = progressStore.sliceSessionQueue(
        sliceWords: _sliceWords,
        reviewPool: reviewPool,
      );
    }

    _reviewsScheduled = widget.reviewMode
        ? _sessionWords.length
        : progressStore.dueReviewCount(reviewPool);

    final vocabByWord = {for (final v in lektion.vocab) v.wort: v};
    final cards = _sessionWords
        .where(vocabByWord.containsKey)
        .map((w) => _Step.card(vocabByWord[w]!))
        .toList();
    _cardCount = cards.length;

    final sliceExercises = widget.reviewMode
        ? <Exercise>[]
        : _pickDailyExercises(
            exercises.where((e) => schrittInSlice(e.schritt, _slice)).toList(),
            max: 4,
          );

    final steps = <_Step>[
      ...cards,
      ...sliceExercises.map((e) => _Step.ex(e)),
    ];
    _answerable = sliceExercises.length;
    if (steps.isEmpty) {
      // Güvenlik: boş dilim → dilim kelimelerinden kısa kart seti
      final fallback = _sliceWords.take(8).toList();
      steps.addAll(fallback
          .where(vocabByWord.containsKey)
          .map((w) => _Step.card(vocabByWord[w]!)));
      _cardCount = steps.length;
      _sessionWords = fallback;
    }
    if (mounted) setState(() => _steps = steps);
  }

  /// Günde en fazla [max] egzersiz; mekanik çeşitliliği koru.
  List<Exercise> _pickDailyExercises(List<Exercise> pool, {int max = 4}) {
    if (pool.length <= max) return pool;
    final byMech = <Mechanic, List<Exercise>>{};
    for (final e in pool) {
      byMech.putIfAbsent(e.mechanic, () => []).add(e);
    }
    final picked = <Exercise>[];
    // Her mekanikten birer tane (mümkünse)
    for (final list in byMech.values) {
      if (picked.length >= max) break;
      picked.add(list.first);
    }
    // Kalan slotları doldur
    for (final e in pool) {
      if (picked.length >= max) break;
      if (!picked.contains(e)) picked.add(e);
    }
    return picked;
  }

  void _advance(bool? correct, {Exercise? exercise}) {
    if (_advancing || _steps == null) return;
    _advancing = true;
    AudioService.shared.stopIfPlaying();

    if (correct == true) _correct++;

    final words = (exercise != null && correct != null)
        ? _wordsTouchedByExercise(exercise)
        : const <String>[];

    final isLast = _index + 1 >= _steps!.length;
    if (isLast) {
      unawaited(() async {
        try {
          if (words.isNotEmpty && correct != null) {
            try {
              await progressStore.recordAnswersBatch(words, correct);
            } catch (e) {
              debugPrint('SR batch: $e');
            }
          }
          if (!mounted) return;
          await _finish();
        } finally {
          _advancing = false;
        }
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
    AudioService.shared.stopIfPlaying();

    if (widget.reviewMode) {
      unawaited(
        progressStore.recordAnswer(v.wort, true).catchError((e) {
          debugPrint('review recordAnswer: $e');
        }),
      );
    } else {
      unawaited(
        progressStore.introduceWord(v.wort).catchError((e) {
          debugPrint('introduceWord: $e');
        }),
      );
    }

    if (_index + 1 >= _steps!.length) {
      unawaited(() async {
        try {
          if (!mounted) return;
          await _finish();
        } finally {
          _advancing = false;
        }
      }());
      return;
    }

    setState(() {
      _index++;
      _advancing = false;
    });
  }

  /// Sadece bu oturum / aktif dilim kelimeleri — ileri Schritt sızmasın.
  List<String> _wordsTouchedByExercise(Exercise ex) {
    final blob = json.encode(ex.payload).toLowerCase();
    final candidates = <String>{
      ..._sliceWords,
      ..._sessionWords,
    }.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    final hit = <String>[];
    for (final w in candidates) {
      final wl = w.toLowerCase().trim();
      if (wl.length <= 2) continue;
      final escaped = RegExp.escape(wl);
      final re = RegExp('(?<![a-zäöüß])$escaped(?![a-zäöüß])');
      if (re.hasMatch(blob)) {
        hit.add(w);
        if (hit.length >= 8) break;
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
      if (!widget.reviewMode) {
        await progressStore.completeDailyGoal();
        await progressStore.maybeAdvanceSlice(_sliceWords);
      }
    } catch (e) {
      debugPrint('finish persist: $e');
    }
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          correct: _correct,
          total: _answerable == 0 ? _cardCount : _answerable,
          xp: xpGained,
          reviewsSaved: _reviewsScheduled + _sessionWords.length,
          streak: progressStore.streak,
          streakIncreased: !alreadyDone &&
              !widget.reviewMode &&
              progressStore.streak >= streakBefore,
        ),
      ),
    );
  }

  void _closeSession() {
    AudioService.shared.stopIfPlaying();
    Navigator.of(context).pop();
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = _steps;
    if (steps == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final step = steps[_index];
    final progress = (_index + 1) / steps.length;
    final showTeaser =
        _cardCount > 0 && _index == _cardCount - 1 && step.isCard;

    return Scaffold(
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          // Yalnızca ses çalarken durdur — her tıkta DOM taraması UI kilidi riski.
          if (AudioService.shared.isPlaying) {
            AudioService.shared.stopIfPlaying();
          }
        },
        child: SafeArea(
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
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          widget.reviewMode
                              ? l10n.tabReview
                              : l10n.sessionSliceChip(
                                  _slice, _sliceTitle(l10n, _slice)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F7268),
                          ),
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
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.sessionTeaserDialog,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC1502F),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: sessionStepSwitcher(
                  context: context,
                  switchKey: step.isCard
                      ? 'card_${step.vocab!.wort}'
                      : 'ex_${step.exercise!.id}',
                  child: _buildStep(step),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(_Step step) {
    if (step.isCard) {
      return FlashcardWidget(
        key: ValueKey('card_${step.vocab!.wort}'),
        vocab: step.vocab!,
        isReview: widget.reviewMode,
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
