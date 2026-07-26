import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../l10n/l10n_ext.dart';
import '../theme.dart';

class ResultScreen extends StatefulWidget {
  final int correct;
  final int total;
  final int xp;
  final int reviewsSaved;
  final int streak;
  final bool streakIncreased;
  const ResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.xp,
    this.reviewsSaved = 0,
    this.streak = 0,
    this.streakIncreased = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = widget.total == 0 ? 1.0 : widget.correct / widget.total;
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 10),
                        Text(l10n.resultTitle,
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(l10n.resultDailyDone,
                            style: TextStyle(
                                fontSize: 15,
                                color: AppColors.navy.withValues(alpha: 0.6))),
                        if (widget.streak > 0) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppColors.coral.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥',
                                    style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.resultStreakKept(widget.streak),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFC1502F),
                                  ),
                                ),
                                if (widget.streakIncreased) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.coral,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Text(
                                      '+1',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _statRow(l10n.resultExercises,
                            '${widget.correct} / ${widget.total}'),
                        const SizedBox(height: 10),
                        _statRow(l10n.resultSuccess,
                            '${(pct * 100).round()}%'),
                        const SizedBox(height: 10),
                        _statRow(l10n.statXp, '+${widget.xp}',
                            valueColor: AppColors.teal),
                        if (widget.reviewsSaved > 0) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  l10n.resultReviewsSavedTitle,
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.resultReviewsSavedHint(
                                      widget.reviewsSaved),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.navy
                                          .withValues(alpha: 0.55)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.of(context)
                                .popUntil((route) => route.isFirst),
                            child: Text(l10n.keepLearning),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [
              AppColors.teal,
              AppColors.coral,
              AppColors.mustard,
              AppColors.das,
            ],
            numberOfParticles: 24,
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, {Color? valueColor}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: cardDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy.withValues(alpha: 0.65))),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? AppColors.navy)),
          ],
        ),
      );
}
