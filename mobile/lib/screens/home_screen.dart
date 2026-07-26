import 'package:flutter/material.dart';
import '../audio_service.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_ext.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'learning_map_tab.dart';
import 'onboarding_screen.dart';
import 'reminder_permission_sheet.dart';
import 'session_screen.dart';

/// L1 dilimleri — (n, deCode); başlık l10n.sliceNTitle ile çözülür.
const kLockedPathNs = [2, 3, 4, 5, 6, 7];

String pathTitle(AppLocalizations l10n, int n) {
  switch (n) {
    case 2:
      return l10n.pathTitleL2;
    case 3:
      return l10n.pathTitleL3;
    case 4:
      return l10n.pathTitleL4;
    case 5:
      return l10n.pathTitleL5;
    case 6:
      return l10n.pathTitleL6;
    case 7:
      return l10n.pathTitleL7;
    default:
      return '';
  }
}

String pathNote(AppLocalizations l10n, int n) =>
    n == 2 ? l10n.pathL2Note : l10n.pathSoon;

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
    // Web: olası <audio> katmanını temizle (sessiz pointer kilidi).
    AudioService.shared.stopIfPlaying();
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

  void _startSession({bool reviewMode = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => SessionScreen(reviewMode: reviewMode)),
    );
  }

  String _greeting(AppLocalizations l10n) {
    final name = progressStore.userName;
    final hour = DateTime.now().hour;
    final hi = hour < 12
        ? l10n.greetingMorning
        : hour < 18
            ? l10n.greetingHello
            : l10n.greetingEvening;
    return name == null ? '$hi!' : l10n.greetingWithName(hi, name);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progressStore,
      builder: (context, _) {
        final l10n = context.l10n;
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
                child: Text(l10n.loadError(_error!),
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
                  Text(l10n.loadingLesson,
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

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => AudioService.shared.stopIfPlaying(),
          child: Scaffold(
            body: SafeArea(
              child: IndexedStack(
                index: _tab,
                children: [
                  LearningMapTab(
                    greeting: _greeting(l10n),
                    mastery: mastery,
                    onStart: _startSession,
                    onLockedLesson: (n) =>
                        _showLockSheet(n, mastery, mastered),
                  ),
                  _ReviewTab(
                    dueCount: due,
                    vocab: l.vocab,
                    onStartReview: () => _startSession(reviewMode: true),
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
              onChanged: (i) {
                AudioService.shared.stopIfPlaying();
                setState(() => _tab = i);
              },
            ),
          ),
        );
      },
    );
  }

  void _showLockSheet(int n, double mastery, int mastered) {
    final l10n = context.l10n;
    final title = pathTitle(l10n, n);
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
                        Text(isL2 ? l10n.locked : l10n.preparing,
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
                isL2 ? l10n.lockMsgL2 : l10n.lockMsgSoon,
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
                          Text(l10n.section1Progress,
                              style: const TextStyle(
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
                        l10n.wordsLeftApprox((48 - mastered).clamp(0, 60)),
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
                  child: Text(isL2 ? l10n.backToTodayLesson : l10n.ok),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.later,
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
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final options = [5, 10, 15, 20];
        final labels = [
          l10n.goalEasy,
          l10n.goalNormal,
          l10n.goalIntense,
          l10n.goalSerious,
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.dailyGoalDuration,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              for (var i = 0; i < options.length; i++)
                ListTile(
                  title: Text(
                      '${l10n.minutesShort(options[i])} · ${labels[i]}'),
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
    final l10n = context.l10n;
    final items = [
      (Icons.school_outlined, l10n.tabLearn),
      (Icons.replay_outlined, l10n.tabReview),
      (Icons.person_outline, l10n.tabProfile),
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

class _ReviewTab extends StatelessWidget {
  final int dueCount;
  final List<VocabItem> vocab;
  final VoidCallback onStartReview;
  final VoidCallback onStartLesson;
  const _ReviewTab({
    required this.dueCount,
    required this.vocab,
    required this.onStartReview,
    required this.onStartLesson,
  });

  VocabItem? _byWort(String w) {
    for (final v in vocab) {
      if (v.wort == w) return v;
    }
    return null;
  }

  String _whenLabel(BuildContext context, DateTime when) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(when.year, when.month, when.day);
    final diff = d.difference(today).inDays;
    if (diff <= 1) return l10n.reviewTomorrow;
    return l10n.reviewInDays(diff);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final words = vocab.map((v) => v.wort).toList();
    final hasReview = dueCount > 0;
    final hasHistory = progressStore.srEntries.isNotEmpty;
    final mistakes = progressStore.mistakeWords(words);
    final weak = progressStore.weakWords(words);
    final upcoming = progressStore.upcomingReviews(words);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(l10n.reviewTitle,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          l10n.reviewSubtitle,
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
                  l10n.reviewDueToday(dueCount),
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800, height: 1.3),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.reviewDueHint,
                  style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.navy.withValues(alpha: 0.55)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onStartReview,
                    child: Text(l10n.startReview),
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
                  clipBehavior: Clip.antiAlias,
                  child: const MediaImage('assets/img/empty_review.svg',
                      height: 100, width: 100),
                ),
                const SizedBox(height: 16),
                Text(
                    hasHistory ? l10n.reviewCaughtUp : l10n.noReviewYet,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  hasHistory ? l10n.reviewCaughtUpHint : l10n.noReviewHint,
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
                    child: Text(
                        hasHistory
                            ? l10n.keepLearning
                            : l10n.startTodaysLesson,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
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
              _row(l10n.myMistakes, l10n.wordCount(mistakes.length),
                  AppColors.coral, onStartReview),
              _row(l10n.weakWords, l10n.wordCount(weak.length), AppColors.teal,
                  onStartReview),
              _row(l10n.listeningPractice, l10n.comingSoon,
                  AppColors.navy.withValues(alpha: 0.45), () {}),
              _row(l10n.pronunciation, l10n.comingSoon,
                  AppColors.navy.withValues(alpha: 0.45), () {},
                  last: true),
            ],
          ),
        ),
        if (mistakes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.myMistakes,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w800)),
                    ),
                    Text(l10n.wordCount(mistakes.length),
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC1502F))),
                  ],
                ),
                const SizedBox(height: 12),
                for (final w in mistakes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _mistakeRow(_byWort(w), w),
                  ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onStartReview,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC1502F),
                      side: BorderSide(
                          color: AppColors.coral.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(l10n.practiceMistakesOnly,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (weak.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.weakWords,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w800)),
                    ),
                    Text(l10n.wordCount(weak.length),
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 12),
                for (final w in weak) _weakRow(_byWort(w), w),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.upcomingReviews,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              if (upcoming.isEmpty)
                Text(l10n.noUpcomingReviews,
                    style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.navy.withValues(alpha: 0.5)))
              else
                for (final u in upcoming)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ArtikelDot(_byWort(u.wort)?.artikel),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _byWort(u.wort)?.display ?? u.wort,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.artikel(
                                  _byWort(u.wort)?.artikel),
                            ),
                          ),
                        ),
                        Text(
                          _whenLabel(context, u.when),
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.navy.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mistakeRow(VocabItem? v, String wort) {
    final color = AppColors.artikel(v?.artikel);
    final wrong = progressStore.wrongCountFor(wort);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: v?.image != null
                ? MediaImage(v!.image!, height: 44)
                : Icon(Icons.menu_book_outlined,
                    size: 22, color: AppColors.navy.withValues(alpha: 0.35)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ArtikelDot(v?.artikel),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        v?.display ?? wort,
                        style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: color),
                      ),
                    ),
                  ],
                ),
                if (v != null && v.uebersetzungTr.isNotEmpty)
                  Text(v.uebersetzungTr,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.navy.withValues(alpha: 0.55))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text('$wrong×',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC1502F))),
          ),
        ],
      ),
    );
  }

  Widget _weakRow(VocabItem? v, String wort) {
    final pct = progressStore.strengthPct(wort);
    final color = AppColors.artikel(v?.artikel);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ArtikelDot(v?.artikel),
          const SizedBox(width: 10),
          SizedBox(
            width: 112,
            child: Text(
              v?.display ?? wort,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w800, color: color),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 8,
                backgroundColor: AppColors.navy.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(
                    pct >= 60 ? AppColors.teal : AppColors.mustard),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 34,
            child: Text('$pct%',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy.withValues(alpha: 0.5))),
          ),
        ],
      ),
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

  String _uiLangLabel(AppLocalizations l10n) {
    switch (progressStore.uiLocaleCode) {
      case 'tr':
        return l10n.uiLangTr;
      case 'fr':
        return l10n.uiLangFr;
      default:
        return l10n.uiLangEn;
    }
  }

  void _pickLanguage(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final options = [
          ('tr', l10n.uiLangTr),
          ('en', l10n.uiLangEn),
          ('fr', l10n.uiLangFr),
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.chooseAppLanguage,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(l10n.langChromeHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.navy.withValues(alpha: 0.55))),
              ),
              for (final o in options)
                ListTile(
                  title: Text(o.$2),
                  trailing: progressStore.uiLocaleCode == o.$1
                      ? const Icon(Icons.check, color: AppColors.teal)
                      : null,
                  onTap: () async {
                    await progressStore.setUiLocale(o.$1);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _pickReminder(BuildContext context) {
    final l10n = context.l10n;
    final options = <(int?, String)>[
      (null, l10n.reminderOff),
      (8, '08:00'),
      (12, '12:00'),
      (18, '18:00'),
      (19, '19:00'),
      (20, '20:00'),
    ];
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Text(l10n.reminderTime,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(l10n.reminderHint,
                  style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.navy.withValues(alpha: 0.55))),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in options)
                    ChoiceChip(
                      label: Text(o.$2,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      selected: progressStore.reminderHour == o.$1,
                      selectedColor: AppColors.teal.withValues(alpha: 0.18),
                      onSelected: (_) async {
                        Navigator.pop(ctx);
                        if (o.$1 == null) {
                          await progressStore.setReminderHour(null);
                          return;
                        }
                        final ok = await ReminderPermissionSheet.show(
                            context,
                            hour: o.$1!);
                        if (ok) {
                          await progressStore.setReminderHour(o.$1);
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _editName(BuildContext context) {
    final l10n = context.l10n;
    final controller =
        TextEditingController(text: progressStore.userName ?? '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              22, 12, 22, 28 + MediaQuery.viewInsetsOf(ctx).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              Text(l10n.editName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: l10n.nameHint,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                        color: AppColors.teal, width: 2.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                        color: AppColors.navy.withValues(alpha: 0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                        color: AppColors.teal, width: 2.5),
                  ),
                ),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await progressStore.setUserName(controller.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(l10n.save),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy.withValues(alpha: 0.5))),
              ),
            ],
          ),
        );
      },
    );
  }

  String _reminderLabel(AppLocalizations l10n) {
    final h = progressStore.reminderHour;
    if (h == null) return l10n.reminderOff;
    return '${h.toString().padLeft(2, '0')}:00';
  }

  String _weekdayShort(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return l10n.dayMon;
      case DateTime.tuesday:
        return l10n.dayTue;
      case DateTime.wednesday:
        return l10n.dayWed;
      case DateTime.thursday:
        return l10n.dayThu;
      case DateTime.friday:
        return l10n.dayFri;
      case DateTime.saturday:
        return l10n.daySat;
      default:
        return l10n.daySun;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = progressStore.userName ?? l10n.studentFallback;
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    final week = progressStore.weekActivity();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _editName(context),
              child: Container(
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
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: () => _editName(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    Text(
                      l10n.profileA1Streak(progressStore.streak),
                      style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.navy.withValues(alpha: 0.55)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
                child: _statCard('🔥', '${progressStore.streak}',
                    l10n.statStreak, AppColors.coral)),
            const SizedBox(width: 8),
            Expanded(
                child: _statCard('⭐', '${progressStore.xp}', l10n.statXp,
                    const Color(0xFF8A6A16))),
            const SizedBox(width: 8),
            Expanded(
                child: _statCard('📈', '${(mastery * 100).round()}%',
                    l10n.statUnit1, AppColors.teal)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.thisWeek,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final d in week)
                    Builder(builder: (_) {
                      final isToday = d.day.year == todayKey.year &&
                          d.day.month == todayKey.month &&
                          d.day.day == todayKey.day;
                      final bg = d.done
                          ? AppColors.teal
                          : (isToday
                              ? AppColors.teal.withValues(alpha: 0.15)
                              : AppColors.navy.withValues(alpha: 0.06));
                      final fg = d.done
                          ? Colors.white
                          : (isToday
                              ? const Color(0xFF1F7268)
                              : AppColors.navy.withValues(alpha: 0.45));
                      return Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: bg,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              d.done ? '✓' : '${d.day.day}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: fg),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _weekdayShort(l10n, d.day.weekday),
                            style: TextStyle(
                                fontSize: 10.5,
                                color:
                                    AppColors.navy.withValues(alpha: 0.45)),
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: cardDecoration(),
          child: Column(
            children: [
              _settingsRow(l10n.editName, name, () => _editName(context)),
              _settingsRow(
                  l10n.dailyGoalDuration,
                  l10n.minutesShort(progressStore.dailyGoalMinutes),
                  onEditGoal),
              _settingsRow(l10n.reminderTime, _reminderLabel(l10n),
                  () => _pickReminder(context)),
              _settingsRow(l10n.appLanguage, _uiLangLabel(l10n),
                  () => _pickLanguage(context)),
              _settingsRow(
                  l10n.learningLanguage, l10n.learningLanguageValue, () {}),
              _settingsRow(
                  l10n.speakingPractice, l10n.comingSoon, () {},
                  last: true),
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
