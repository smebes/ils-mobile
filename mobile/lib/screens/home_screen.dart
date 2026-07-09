import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'session_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Lektion? _lektion;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final l = await contentRepo.loadLektion();
      if (mounted) setState(() => _lektion = l);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progressStore,
      builder: (context, _) {
        if (_error != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('Fehler beim Laden: $_error',
                    textAlign: TextAlign.center),
              ),
            ),
          );
        }
        final l = _lektion;
        if (l == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final mastery = progressStore.masteryPct(l.vocab.length);
        final mastered = progressStore.masteredCount(l.vocab.length);
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  const SizedBox(height: 24),
                  const Text('Guten Tag! 👋',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Lass uns Deutsch lernen.',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.navy.withValues(alpha: 0.6))),
                  const SizedBox(height: 24),
                  _lektionCard(l, mastery, mastered),
                  const SizedBox(height: 24),
                  _mainCta(l),
                  const SizedBox(height: 16),
                  _secondaryActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topBar() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _pill('🔥 ${progressStore.streak}', AppColors.coral),
        _pill('⭐ Lvl ${progressStore.level}', AppColors.mustard),
        _pill('${progressStore.xp} XP', AppColors.teal),
      ],
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      );

  Widget _lektionCard(Lektion l, double mastery, int mastered) {
    return Container(
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: MediaImage(l.coverImage, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lektion ${l.id} · ${l.titel}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(l.thema,
                    style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.6))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: SessionProgressBar(mastery)),
                    const SizedBox(width: 10),
                    Text(
                      '${(mastery * 100).round()}% Meisterschaft',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$mastered / ${l.vocab.length} Wörter sicher (Kiste 4–5)',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.navy.withValues(alpha: 0.55)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainCta(Lektion l) {
    final queueSize = progressStore.dailyWordQueue(
      l.vocab.map((v) => v.wort).toList(),
      size: 15,
    ).length;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SessionScreen()),
        ),
        child: Column(
          children: [
            const Text('HEUTE LERNEN'),
            const SizedBox(height: 2),
            Text('${l.titel} · $queueSize Wörter',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _secondaryActions() {
    return Row(
      children: [
        Expanded(child: _secBtn('💬', 'Sprechen', 'Bald verfügbar')),
        const SizedBox(width: 12),
        Expanded(child: _secBtn('🎯', 'Test', 'Bald verfügbar')),
      ],
    );
  }

  Widget _secBtn(String emoji, String title, String sub) => Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(sub,
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.navy.withValues(alpha: 0.5))),
          ],
        ),
      );
}
