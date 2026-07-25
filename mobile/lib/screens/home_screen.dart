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

  static const _catalog = [
    (1, 'Guten Tag. Mein Name ist …'),
    (2, 'Meine Familie'),
    (3, 'Einkaufen'),
    (4, 'Meine Wohnung'),
    (5, 'Tagesabläufe'),
    (6, 'Freizeit'),
    (7, 'Kinder und Schule'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      debugPrint('Home: loading Lektion…');
      final l = await contentRepo.loadLektion();
      debugPrint('Home: loaded L${l.id} · ${l.vocab.length} Wörter · ${l.coverImage}');
      if (mounted) setState(() => _lektion = l);
    } catch (e, st) {
      debugPrint('Home: load error $e\n$st');
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
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.teal),
                  const SizedBox(height: 16),
                  Text('Lektion wird geladen…',
                      style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
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
                  const Text('Guten Tag!',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Lass uns Deutsch lernen.',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.navy.withValues(alpha: 0.6))),
                  const SizedBox(height: 24),
                  _lektionCard(l, mastery, mastered),
                  const SizedBox(height: 16),
                  _mainCta(l),
                  const SizedBox(height: 28),
                  Text('Lehrplan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy.withValues(alpha: 0.8))),
                  const SizedBox(height: 10),
                  ..._catalog.map((e) => _catalogTile(e.$1, e.$2, mastery)),
                  const SizedBox(height: 24),
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
            // SVG kapak web'de bazen sessizce boş bırakıyordu — önce boyalı
            // gradient; üstüne SVG (başarısız olsa bile kart dolu kalır).
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.teal, AppColors.navy],
                    ),
                  ),
                ),
                MediaImage(l.coverImage, fit: BoxFit.cover),
              ],
            ),
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
                const SizedBox(height: 4),
                Text(
                  '${progressStore.srEntries.length} im SR · ${progressStore.xp} XP',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.teal.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600),
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
            Text('Lektion ${l.id} · $queueSize Wörter',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _catalogTile(int id, String title, double l1Mastery) {
    final unlocked = contentRepo.isUnlocked(id, l1Mastery);
    final isActive = id == _lektion?.id;
    return Opacity(
      opacity: unlocked ? 1 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: cardDecoration(
          border: isActive ? AppColors.teal : null,
        ),
        child: Row(
          children: [
            Text(
              unlocked ? (isActive ? '▶' : '○') : '🔒',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'L$id · $title',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (!unlocked)
              Text(
                id == 2 ? '80% L1' : 'Bald',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.navy.withValues(alpha: 0.5),
                ),
              ),
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
