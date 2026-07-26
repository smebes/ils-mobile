import 'package:flutter/material.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'onboarding_screen.dart';
import 'session_screen.dart';

/// L1 dilimleri — Prototype v2 / Home_v2_Spec
const kL1Slices = [
  (1, 'Tanışma ve selamlaşma', 'Folge + Schritt A'),
  (2, 'Adım nedir? / İsim', 'Schritt B'),
  (3, 'Nerelisin? Ülke ve dil', 'Schritt C'),
  (4, 'Harfler ve heceleme', 'Schritt D'),
  (5, 'Adres ve kartvizit', 'Schritt E'),
];

const kLockedPath = [
  (2, 'Meine Familie · Ailem', 'L1 ilerlemen %80 olunca açılır'),
  (3, 'Einkaufen · Alışveriş', 'Yakında'),
  (4, 'Meine Wohnung · Evim', 'Yakında'),
  (5, 'Tagesabläufe · Günlük rutinler', 'Yakında'),
  (6, 'Freizeit · Boş zaman', 'Yakında'),
  (7, 'Kinder und Schule · Çocuklar ve okul', 'Yakında'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Lektion? _lektion;
  String? _error;
  int _tab = 0; // 0 öğren · 1 tekrar · 2 profil

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final l = await contentRepo.loadLektion();
      if (mounted) setState(() => _lektion = l);
    } catch (e, st) {
      debugPrint('Home: load error $e\n$st');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _startSession() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SessionScreen()),
    );
  }

  String _greeting() {
    final name = progressStore.userName;
    final hour = DateTime.now().hour;
    final hi = hour < 12
        ? 'Günaydın'
        : hour < 18
            ? 'Merhaba'
            : 'İyi akşamlar';
    return name == null ? '$hi!' : '$hi, $name!';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progressStore,
      builder: (context, _) {
        if (!progressStore.onboardingDone) {
          return OnboardingScreen(
            onDone: () => setState(() {}),
          );
        }
        if (_error != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('Yüklenirken hata: $_error',
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
                  Text('Ders yükleniyor…',
                      style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }

        final words = l.vocab.map((v) => v.wort).toList();
        final due = progressStore.dueReviewCount(words);
        final mastery = progressStore.masteryPct(l.vocab.length);
        final mastered = progressStore.masteredCount(l.vocab.length);

        return Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: _tab,
              children: [
                _LearnTab(
                  lektion: l,
                  greeting: _greeting(),
                  dueCount: due,
                  mastery: mastery,
                  mastered: mastered,
                  onStart: _startSession,
                  onLockedLesson: (n, title, note) =>
                      _showLockSheet(n, title, note, mastery, mastered),
                ),
                _ReviewTab(
                  dueCount: due,
                  onStartReview: _startSession,
                  onStartLesson: () {
                    setState(() => _tab = 0);
                    _startSession();
                  },
                ),
                _ProfileTab(
                  mastery: mastery,
                  onEditGoal: _editGoal,
                ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomNav(
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
        );
      },
    );
  }

  void _showLockSheet(
    int n,
    String title,
    String note,
    double mastery,
    int mastered,
  ) {
    final isL2 = n == 2;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                        child: Text('🔒', style: TextStyle(fontSize: 19))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$n. $title',
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w800)),
                        Text(isL2 ? 'Kilitli' : 'Hazırlanıyor',
                            style: TextStyle(
                                fontSize: 13,
                                color:
                                    AppColors.navy.withValues(alpha: 0.55))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                isL2
                    ? 'L1 ilerlemen %80 olunca açılır. Kelimeleri tekrar ettikçe bu oran yükselir.'
                    : 'Bu bölüm yakında hazır olacak.',
                style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: AppColors.navy.withValues(alpha: 0.75)),
              ),
              if (isL2) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('1. bölüm ilerlemesi',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(
                            '${(mastery * 100).round()}% / 80%',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F7268)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SessionProgressBar(mastery.clamp(0, 1)),
                      const SizedBox(height: 10),
                      Text(
                        'Yaklaşık ${(48 - mastered).clamp(0, 60)} kelime daha kaldı.',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.navy.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (isL2) _startSession();
                  },
                  child: Text(isL2 ? 'Bugünkü derse dön' : 'Tamam'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Daha sonra',
                    style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editGoal() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final options = [5, 10, 15, 20];
        final labels = ['Rahat', 'Normal', 'Yoğun', 'Ciddi'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Günlük hedef süresi',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              for (var i = 0; i < options.length; i++)
                ListTile(
                  title: Text('${options[i]} dk · ${labels[i]}'),
                  trailing: progressStore.dailyGoalMinutes == options[i]
                      ? const Icon(Icons.check, color: AppColors.teal)
                      : null,
                  onTap: () async {
                    await progressStore.setDailyGoalMinutes(options[i]);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.school_outlined, 'Öğren'),
      (Icons.replay_outlined, 'Tekrar'),
      (Icons.person_outline, 'Profil'),
    ];
    return Material(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.94),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.navy.withValues(alpha: 0.1)),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(i),
                    borderRadius: BorderRadius.circular(12),
                    child: Opacity(
                      opacity: index == i ? 1 : 0.45,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(items[i].$1,
                                color: index == i
                                    ? AppColors.teal
                                    : AppColors.navy,
                                size: 22),
                            const SizedBox(height: 3),
                            Text(items[i].$2,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: index == i
                                        ? AppColors.teal
                                        : AppColors.navy)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnTab extends StatelessWidget {
  final Lektion lektion;
  final String greeting;
  final int dueCount;
  final double mastery;
  final int mastered;
  final VoidCallback onStart;
  final void Function(int n, String title, String note) onLockedLesson;

  const _LearnTab({
    required this.lektion,
    required this.greeting,
    required this.dueCount,
    required this.mastery,
    required this.mastered,
    required this.onStart,
    required this.onLockedLesson,
  });

  @override
  Widget build(BuildContext context) {
    final phase = progressStore.homePhase;
    final slice = progressStore.activeSlice;
    final goalDone = phase == 'done';
    final queueSize = progressStore
        .dailyWordQueue(lektion.vocab.map((v) => v.wort).toList(), size: 15)
        .length;

    final ctaLabel = phase == 'new'
        ? 'Bugünkü derse başla'
        : phase == 'progress'
            ? 'Kaldığın yerden devam et'
            : 'Ek pratik yap';
    final ctaSub = phase == 'new'
        ? '~7 dk · $queueSize kelime'
        : phase == 'progress'
            ? '~4 dk · devam'
            : '+10 XP · kısa tekrar';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(greeting,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          'Bugün Almanca için yaklaşık ${progressStore.dailyGoalMinutes} dakikan yeterli.',
          style: TextStyle(
              fontSize: 14.5,
              height: 1.45,
              color: AppColors.navy.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _statPill('${progressStore.streak} günlük seri', AppColors.coral),
            _statPill('Seviye ${progressStore.level}', AppColors.mustard),
            _statPill('${progressStore.xp} XP', AppColors.teal),
          ],
        ),
        const SizedBox(height: 14),
        _goalCard(goalDone),
        const SizedBox(height: 14),
        _todayLessonCard(phase, dueCount),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onStart,
            child: Column(
              children: [
                Text(ctaLabel),
                const SizedBox(height: 2),
                Text(ctaSub,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ),
        if (phase == 'done') ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Yarınki dilim sıraya girecek.'),
                    duration: Duration(seconds: 2)),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1F7268),
              side: BorderSide(color: AppColors.teal.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('Yarınki derse bak',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'ÖĞRENME YOLU',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.navy.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 10),
        ...kL1Slices.map((s) {
          final n = s.$1;
          final st = n < slice
              ? 'done'
              : n == slice
                  ? 'active'
                  : 'next';
          final locked = n > slice + 1;
          final note = st == 'done'
              ? 'Tamamlandı · ${s.$3}'
              : st == 'active'
                  ? (phase == 'new'
                      ? 'Bugünkü ders · ${s.$3}'
                      : 'Devam ediyor · ${s.$3}')
                  : locked
                      ? 'Sırada değil · ${s.$3}'
                      : 'Sıradaki · ${s.$3}';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (st == 'active') {
                  onStart();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(st == 'done'
                          ? 'Bu dilimi tamamladın. Tekrar sekmesinden pekiştirebilirsin.'
                          : 'Önce bugünkü dersi bitir.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Opacity(
                opacity: locked ? 0.55 : 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 14),
                  decoration: cardDecoration(
                    border: st == 'active' ? AppColors.teal : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: st == 'done'
                              ? AppColors.teal.withValues(alpha: 0.16)
                              : st == 'active'
                                  ? AppColors.teal
                                  : AppColors.navy.withValues(alpha: 0.07),
                        ),
                        child: Center(
                          child: Text(
                            st == 'done'
                                ? '✓'
                                : st == 'active'
                                    ? '●'
                                    : '○',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: st == 'active'
                                  ? Colors.white
                                  : AppColors.teal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$n. ${s.$2}',
                                style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800)),
                            Text(note,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.navy
                                        .withValues(alpha: 0.5))),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: st == 'active'
                              ? AppColors.teal
                              : AppColors.navy.withValues(alpha: 0.25)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Divider(color: AppColors.navy.withValues(alpha: 0.08)),
        const SizedBox(height: 8),
        ...kLockedPath.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onLockedLesson(p.$1, p.$2, p.$3),
                child: Opacity(
                  opacity: p.$1 == 2 ? 0.75 : 0.45,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: cardDecoration(),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.navy.withValues(alpha: 0.07),
                          ),
                          child: const Center(
                              child:
                                  Text('🔒', style: TextStyle(fontSize: 13))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Lektion ${p.$1} · ${p.$2}',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800)),
                              Text(p.$3,
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.navy
                                          .withValues(alpha: 0.5))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _goalCard(bool done) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GÜNLÜK HEDEF',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AppColors.navy.withValues(alpha: 0.5))),
              Text(
                done ? '1 / 1 ders ✓' : '0 / 1 ders',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: done
                        ? AppColors.teal
                        : AppColors.navy.withValues(alpha: 0.45)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              final on = done;
              return Expanded(
                child: Container(
                  height: 11,
                  margin: EdgeInsets.only(right: i < 4 ? 7 : 0),
                  decoration: BoxDecoration(
                    color: on
                        ? AppColors.teal
                        : AppColors.navy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            progressStore.homePhase == 'new'
                ? 'Bir kısa ders bugünü tamamlar.'
                : progressStore.homePhase == 'progress'
                    ? 'Neredeyse tamam — derse devam et.'
                    : 'Bugünün hedefi tamam. Seri +1.',
            style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.navy.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }

  Widget _todayLessonCard(String phase, int due) {
    final pct = phase == 'done' ? 100 : phase == 'progress' ? 60 : 0;
    return Container(
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
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
                MediaImage(lektion.coverImage, fit: BoxFit.cover),
                Positioned(
                  top: 12,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text('BUGÜNKÜ DERS',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lektion ${lektion.id}',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy.withValues(alpha: 0.5))),
                const SizedBox(height: 3),
                const Text('Guten Tag! Mein Name ist …',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.25)),
                const SizedBox(height: 5),
                const Text('Tanışma ve selamlaşma',
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F7268))),
                const SizedBox(height: 12),
                Text(
                  '15 kelime · 1 kısa konuşma · ~${progressStore.dailyGoalMinutes} dakika',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.navy.withValues(alpha: 0.6)),
                ),
                Text(
                  'Tekrar bekleyen: $due',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.navy.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: AppColors.navy.withValues(alpha: 0.08)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      phase == 'new'
                          ? 'Başlamaya hazır'
                          : 'Ders ilerlemesi: %$pct',
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: phase == 'new'
                              ? AppColors.navy.withValues(alpha: 0.55)
                              : AppColors.teal),
                    ),
                    if (phase == 'progress')
                      Text('devam',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy.withValues(alpha: 0.45))),
                    if (phase == 'done')
                      Text('bugünkü dilim bitti',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy.withValues(alpha: 0.45))),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: List.generate(5, (i) {
                    final on = i < (pct / 20).round();
                    return Expanded(
                      child: Container(
                        height: 8,
                        margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: on
                              ? AppColors.teal
                              : AppColors.navy.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(text,
                style: TextStyle(
                    color: color.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5)),
          ],
        ),
      );
}

class _ReviewTab extends StatelessWidget {
  final int dueCount;
  final VoidCallback onStartReview;
  final VoidCallback onStartLesson;
  const _ReviewTab({
    required this.dueCount,
    required this.onStartReview,
    required this.onStartLesson,
  });

  @override
  Widget build(BuildContext context) {
    final hasReview = dueCount > 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Text('Tekrar',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          'Öğrendiğin kelimeleri unutmadan tazeliyoruz.',
          style: TextStyle(
              fontSize: 14.5, color: AppColors.navy.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 18),
        if (hasReview)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugün tekrar etmen gereken $dueCount kelime var',
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800, height: 1.3),
                ),
                const SizedBox(height: 6),
                Text(
                  '~3 dakika · doğru bildiğin kelimeler daha seyrek gelir',
                  style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.navy.withValues(alpha: 0.55)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onStartReview,
                    child: const Text('Tekrara başla'),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            decoration: cardDecoration(),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(Icons.inbox_outlined,
                      size: 40,
                      color: AppColors.navy.withValues(alpha: 0.35)),
                ),
                const SizedBox(height: 16),
                const Text('Henüz tekrar yok',
                    style:
                        TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  'Önce kısa bir ders bitir — öğrendiğin kelimeler yarın tekrar için burada olacak.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: AppColors.navy.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onStartLesson,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1F7268),
                      side: BorderSide(
                          color: AppColors.teal.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('Bugünkü derse başla',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Container(
          decoration: cardDecoration(),
          child: Column(
            children: [
              _row('Hatalarım', 'Yakında', AppColors.coral, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Hata defteri yakında.'),
                      duration: Duration(seconds: 2)),
                );
              }),
              _row('Zayıf kelimeler', 'Yakında', AppColors.teal, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Zayıf kelime listesi yakında.'),
                      duration: Duration(seconds: 2)),
                );
              }),
              _row('Dinleme pratiği', 'Yakında',
                  AppColors.navy.withValues(alpha: 0.45), () {}),
              _row('Telaffuz', 'Yakında',
                  AppColors.navy.withValues(alpha: 0.45), () {},
                  last: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, Color color, VoidCallback onTap,
      {bool last = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(
                  bottom: BorderSide(
                      color: AppColors.navy.withValues(alpha: 0.07))),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700))),
            Text(value,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right,
                size: 18, color: AppColors.navy.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final double mastery;
  final VoidCallback onEditGoal;
  const _ProfileTab({required this.mastery, required this.onEditGoal});

  @override
  Widget build(BuildContext context) {
    final name = progressStore.userName ?? 'Öğrenci';
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(initial,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800)),
                  Text(
                    'Almanca A1 · ${progressStore.streak} gündür aralıksız',
                    style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.navy.withValues(alpha: 0.55)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
                child: _statCard(
                    '🔥', '${progressStore.streak}', 'gün seri', AppColors.coral)),
            const SizedBox(width: 8),
            Expanded(
                child: _statCard(
                    '⭐', '${progressStore.xp}', 'XP', const Color(0xFF8A6A16))),
            const SizedBox(width: 8),
            Expanded(
                child: _statCard('📈', '${(mastery * 100).round()}%',
                    '1. bölüm', AppColors.teal)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: cardDecoration(),
          child: Column(
            children: [
              _settingsRow('Günlük hedef süresi',
                  '${progressStore.dailyGoalMinutes} dk', onEditGoal),
              _settingsRow('Uygulama dili', 'Türkçe', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Arayüz Türkçe, içerik Almanca.'),
                      duration: Duration(seconds: 2)),
                );
              }),
              _settingsRow('Öğrenme dili', 'Almanca A1', () {}),
              _settingsRow('Konuşma alıştırması', 'Yakında', () {}, last: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 19)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.navy.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _settingsRow(String label, String value, VoidCallback onTap,
      {bool last = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(
                  bottom: BorderSide(
                      color: AppColors.navy.withValues(alpha: 0.07))),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700))),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.teal)),
          ],
        ),
      ),
    );
  }
}
