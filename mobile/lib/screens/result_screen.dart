import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme.dart';

class ResultScreen extends StatefulWidget {
  final int correct;
  final int total;
  final int xp;
  const ResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.xp,
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
    final pct = widget.total == 0
        ? 1.0
        : widget.correct / widget.total;
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 12),
                  const Text('Sehr gut!',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Tägliches Ziel erreicht',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.navy.withValues(alpha: 0.6))),
                  const SizedBox(height: 32),
                  _statRow('Doğru', '${widget.correct} / ${widget.total}'),
                  const SizedBox(height: 12),
                  _statRow('Başarı', '${(pct * 100).round()}%'),
                  const SizedBox(height: 12),
                  _statRow('Kazanılan XP', '+${widget.xp}'),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.of(context).maybePop(),
                      child: const Text('Fertig'),
                    ),
                  ),
                ],
              ),
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

  Widget _statRow(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: cardDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}
