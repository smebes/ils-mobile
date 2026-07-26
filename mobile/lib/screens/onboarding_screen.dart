import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../main.dart';
import '../theme.dart';

/// Prototype v2 onboarding 4 adım.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  int _goal = 10;
  String _level = 'zero';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await progressStore.setUserName(_nameCtrl.text);
    await progressStore.setDailyGoalMinutes(_goal);
    await progressStore.setOnboardingDone(true);
    widget.onDone();
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      height: 5,
                      margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? AppColors.teal
                            : AppColors.navy.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 26),
              Expanded(child: _body()),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_step == 3 ? l10n.letsStart : l10n.continueBtn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case 0:
        return _nameStep();
      case 1:
        return _levelStep();
      case 2:
        return _goalStep();
      default:
        return _artikelStep();
    }
  }

  Widget _nameStep() {
    final l10n = context.l10n;
    final name = _nameCtrl.text.trim();
    final preview = name.isEmpty
        ? '${l10n.greetingHello}!'
        : l10n.greetingWithName(l10n.greetingMorning, name);
    return ListView(
      children: [
        Text(l10n.onboardingNameTitle,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
        const SizedBox(height: 8),
        Text(l10n.onboardingNameSub,
            style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.navy.withValues(alpha: 0.6))),
        const SizedBox(height: 26),
        TextField(
          controller: _nameCtrl,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            hintText: l10n.nameHint,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                  color: AppColors.navy.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.teal, width: 2.5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(l10n.nameOptional,
            style: TextStyle(
                fontSize: 13,
                color: AppColors.navy.withValues(alpha: 0.45))),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.previewLabel,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AppColors.navy.withValues(alpha: 0.5))),
              const SizedBox(height: 8),
              Text(preview,
                  style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w800)),
              Text(
                l10n.todayMinutesEnough(7),
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.navy.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _levelStep() {
    final l10n = context.l10n;
    Widget card(String id, String title, String sub, {bool soon = false}) {
      final sel = _level == id;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: soon
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l10n.placementSoon),
                        duration: const Duration(seconds: 2)),
                  );
                }
              : () => setState(() => _level = id),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sel
                  ? AppColors.teal.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: sel
                    ? AppColors.teal
                    : AppColors.navy.withValues(alpha: 0.1),
                width: sel ? 2.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(sub,
                    style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.navy.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      children: [
        Text(l10n.onboardingLevelTitle,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
        const SizedBox(height: 8),
        Text(l10n.onboardingLevelSub,
            style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.navy.withValues(alpha: 0.6))),
        const SizedBox(height: 22),
        card('zero', l10n.levelZero, l10n.levelZeroSub),
        card('some', l10n.levelSome, l10n.levelSomeSub, soon: true),
        card('course', l10n.levelCourse, l10n.levelCourseSub),
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n.a1OnlyNote,
            style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.navy.withValues(alpha: 0.65)),
          ),
        ),
      ],
    );
  }

  Widget _goalStep() {
    final l10n = context.l10n;
    final opts = [
      (5, l10n.goalEasy),
      (10, l10n.goalNormal),
      (15, l10n.goalIntense),
      (20, l10n.goalSerious),
    ];
    return ListView(
      children: [
        Text(l10n.onboardingGoalTitle,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
        const SizedBox(height: 8),
        Text(l10n.onboardingGoalSub,
            style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.navy.withValues(alpha: 0.6))),
        const SizedBox(height: 22),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: opts.map((o) {
            final sel = _goal == o.$1;
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 54) / 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => setState(() => _goal = o.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.teal.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: sel
                          ? AppColors.teal
                          : AppColors.navy.withValues(alpha: 0.1),
                      width: sel ? 2.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(l10n.minutesShort(o.$1),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(o.$2,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.navy.withValues(alpha: 0.55))),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n.goalPicked(_goal),
            style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.navy.withValues(alpha: 0.65)),
          ),
        ),
      ],
    );
  }

  Widget _artikelStep() {
    final l10n = context.l10n;
    Widget col(String a, String label, Color c) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: cardDecoration(),
            child: Column(
              children: [
                Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                const SizedBox(height: 8),
                Text(a,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: c)),
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.navy.withValues(alpha: 0.5))),
              ],
            ),
          ),
        );

    return ListView(
      children: [
        Text(l10n.onboardingArtikelTitle,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingArtikelSub,
          style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.navy.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            col('der', l10n.artikelDer, AppColors.der),
            const SizedBox(width: 8),
            col('die', l10n.artikelDie, AppColors.die),
            const SizedBox(width: 8),
            col('das', l10n.artikelDas, AppColors.das),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: cardDecoration(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                        color: AppColors.die, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Text('die Sprache',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.die)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ich spreche ein bisschen Deutsch.',
                style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.navy.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n.trTipNote,
            style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.navy.withValues(alpha: 0.7)),
          ),
        ),
      ],
    );
  }
}
