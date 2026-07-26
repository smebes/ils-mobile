// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SprachApp';

  @override
  String get tabLearn => 'Learn';

  @override
  String get tabReview => 'Review';

  @override
  String get tabProfile => 'Profile';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingHello => 'Hello';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name!';
  }

  @override
  String todayMinutesEnough(int minutes) {
    return 'About $minutes minutes of German is enough for today.';
  }

  @override
  String streakDays(int count) {
    return '$count day streak';
  }

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String xpLabel(int xp) {
    return '$xp XP';
  }

  @override
  String get dailyGoal => 'DAILY GOAL';

  @override
  String dailyGoalProgress(int done, int total) {
    return '$done / $total lesson';
  }

  @override
  String dailyGoalDoneCheck(int done, int total) {
    return '$done / $total lesson ✓';
  }

  @override
  String get goalHintNew => 'One short lesson completes today.';

  @override
  String get goalHintProgress => 'Almost there — continue the lesson.';

  @override
  String get goalHintDone => 'Today’s goal done. Streak +1.';

  @override
  String get todaysLesson => 'TODAY’S LESSON';

  @override
  String lessonNumber(int id) {
    return 'Lesson $id';
  }

  @override
  String get lessonTitleL1 => 'Guten Tag! Mein Name ist …';

  @override
  String get slice1Title => 'Greetings & introductions';

  @override
  String get slice2Title => 'What’s your name?';

  @override
  String get slice3Title => 'Where are you from? Country & language';

  @override
  String get slice4Title => 'Letters & spelling';

  @override
  String get slice5Title => 'Address & business card';

  @override
  String metaLessonLine(int words, int minutes) {
    return '$words words · 1 short dialogue · ~$minutes min';
  }

  @override
  String reviewWaiting(int count) {
    return 'Due for review: $count';
  }

  @override
  String get readyToStart => 'Ready to start';

  @override
  String lessonProgressPct(int pct) {
    return 'Lesson progress: $pct%';
  }

  @override
  String get continueLabel => 'continue';

  @override
  String get sliceFinishedToday => 'today’s slice done';

  @override
  String get ctaStartToday => 'Start today’s lesson';

  @override
  String get ctaContinue => 'Continue where you left off';

  @override
  String get ctaExtraPractice => 'Extra practice';

  @override
  String ctaSubNew(int words) {
    return '~7 min · $words words';
  }

  @override
  String get ctaSubProgress => '~4 min · continue';

  @override
  String get ctaSubDone => '+10 XP · short review';

  @override
  String get lookAtTomorrow => 'See tomorrow’s lesson';

  @override
  String get tomorrowQueued => 'Tomorrow’s slice will be queued.';

  @override
  String get learningPath => 'LEARNING PATH';

  @override
  String sliceDoneNote(String de) {
    return 'Completed · $de';
  }

  @override
  String sliceActiveNew(String de) {
    return 'Today’s lesson · $de';
  }

  @override
  String sliceActiveProgress(String de) {
    return 'In progress · $de';
  }

  @override
  String sliceLockedNote(String de) {
    return 'Not yet · $de';
  }

  @override
  String sliceNextNote(String de) {
    return 'Up next · $de';
  }

  @override
  String get sliceDoneSnack =>
      'You finished this slice. Strengthen it in Review.';

  @override
  String get finishTodayFirst => 'Finish today’s lesson first.';

  @override
  String lektionLockedTitle(int n, String title) {
    return 'Lesson $n · $title';
  }

  @override
  String get pathL2Note => 'Unlocks at 80% progress in L1';

  @override
  String get pathSoon => 'Coming soon';

  @override
  String get pathTitleL1 => 'Guten Tag · Hello';

  @override
  String get pathTitleL2 => 'Meine Familie · My family';

  @override
  String get pathTitleL3 => 'Einkaufen · Shopping';

  @override
  String get pathTitleL4 => 'Meine Wohnung · My home';

  @override
  String get pathTitleL5 => 'Tagesabläufe · Daily routines';

  @override
  String get pathTitleL6 => 'Freizeit · Free time';

  @override
  String get pathTitleL7 => 'Kinder und Schule · Kids & school';

  @override
  String get locked => 'Locked';

  @override
  String get preparing => 'Coming soon';

  @override
  String get lockMsgL2 =>
      'Unlocks when your L1 progress reaches 80%. Reviewing words raises this rate.';

  @override
  String get lockMsgSoon => 'This unit will be ready soon.';

  @override
  String get section1Progress => 'Unit 1 progress';

  @override
  String wordsLeftApprox(int count) {
    return 'About $count more words to go.';
  }

  @override
  String get backToTodayLesson => 'Back to today’s lesson';

  @override
  String get ok => 'OK';

  @override
  String get later => 'Later';

  @override
  String get dailyGoalDuration => 'Daily goal length';

  @override
  String get goalEasy => 'Easy';

  @override
  String get goalNormal => 'Normal';

  @override
  String get goalIntense => 'Intense';

  @override
  String get goalSerious => 'Serious';

  @override
  String minutesShort(int m) {
    return '$m min';
  }

  @override
  String loadError(String error) {
    return 'Error while loading: $error';
  }

  @override
  String get loadingLesson => 'Loading lesson…';

  @override
  String get reviewTitle => 'Review';

  @override
  String get reviewSubtitle => 'We refresh words so you don’t forget them.';

  @override
  String reviewDueToday(int count) {
    return 'You have $count words to review today';
  }

  @override
  String get reviewDueHint => '~3 minutes · words you know appear less often';

  @override
  String get startReview => 'Start review';

  @override
  String get noReviewYet => 'No reviews yet';

  @override
  String get noReviewHint =>
      'Finish a short lesson first — your words will show up here tomorrow.';

  @override
  String get startTodaysLesson => 'Start today’s lesson';

  @override
  String get myMistakes => 'My mistakes';

  @override
  String get weakWords => 'Weak words';

  @override
  String get listeningPractice => 'Listening practice';

  @override
  String get pronunciation => 'Pronunciation';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get mistakesSoon => 'Mistake journal coming soon.';

  @override
  String get weakSoon => 'Weak words list coming soon.';

  @override
  String get studentFallback => 'Learner';

  @override
  String profileA1Streak(int days) {
    return 'German A1 · $days days in a row';
  }

  @override
  String get statStreak => 'day streak';

  @override
  String get statXp => 'XP';

  @override
  String get statUnit1 => 'Unit 1';

  @override
  String get appLanguage => 'App language';

  @override
  String get learningLanguage => 'Learning language';

  @override
  String get learningLanguageValue => 'German A1';

  @override
  String get speakingPractice => 'Speaking practice';

  @override
  String get uiLangTr => 'Turkish';

  @override
  String get uiLangEn => 'English';

  @override
  String get uiLangFr => 'French';

  @override
  String get uiLangDe => 'German';

  @override
  String get chooseAppLanguage => 'App language';

  @override
  String get langChromeHint =>
      'Menus stay in your language. Lesson content stays in German.';

  @override
  String get onboardingNameTitle => 'What should we call you?';

  @override
  String get onboardingNameSub => 'We only use your name in greetings.';

  @override
  String get nameHint => 'Your name';

  @override
  String get nameOptional => 'Leave blank if you prefer — we’ll say “Hello!”';

  @override
  String get previewLabel => 'PREVIEW';

  @override
  String get onboardingLevelTitle => 'How’s your German?';

  @override
  String get onboardingLevelSub => 'We’ll adjust where you start.';

  @override
  String get levelZero => 'I’m starting from zero';

  @override
  String get levelZeroSub => 'We begin at Lesson 1, first slice';

  @override
  String get levelSome => 'I know a little German';

  @override
  String get levelSomeSub => 'A short placement test · coming soon';

  @override
  String get levelCourse => 'I’ve taken a course before';

  @override
  String get levelCourseSub => 'We’ll move faster through known words';

  @override
  String get placementSoon => 'Placement test coming soon.';

  @override
  String get a1OnlyNote =>
      'Only A1 content is available for now. You can change this later in Profile.';

  @override
  String get onboardingGoalTitle => 'How much time can you spare daily?';

  @override
  String get onboardingGoalSub => 'You can change this later in Profile.';

  @override
  String goalPicked(int minutes) {
    return 'Your goal: $minutes min\nOne short daily slice ≈ 15 words.';
  }

  @override
  String get onboardingArtikelTitle => 'Learn articles by color';

  @override
  String get onboardingArtikelSub =>
      'The hardest part of German becomes a color. Same colors everywhere in the app.';

  @override
  String get artikelDer => 'masculine';

  @override
  String get artikelDie => 'feminine';

  @override
  String get artikelDas => 'neuter';

  @override
  String get trTipNote =>
      'Tip for many learners: instead of word-by-word “my name is…”, German often uses Ich heiße … as a whole phrase.';

  @override
  String get continueBtn => 'Continue';

  @override
  String get letsStart => 'Let’s start';

  @override
  String get newWord => 'New word';

  @override
  String get showTranslation => 'Show translation';

  @override
  String get listenTooltip => 'Listen';

  @override
  String pluralLabel(String plural) {
    return 'Plural: die $plural';
  }

  @override
  String get checkAnswer => 'Check';

  @override
  String get answerAllQuestions => 'Please answer all questions.';

  @override
  String get feedbackCorrectDe => 'Richtig!';

  @override
  String get feedbackAlmostDe => 'Fast!';

  @override
  String get feedbackCorrectLocal => 'Correct';

  @override
  String get feedbackAlmostLocal => 'Almost';

  @override
  String get resultTitle => 'Awesome!';

  @override
  String get resultDailyDone => 'You completed today’s goal';

  @override
  String get resultExercises => 'Exercises';

  @override
  String get resultSuccess => 'Accuracy';

  @override
  String resultReviewsSaved(int count) {
    return 'Words saved for review 📚\n($count in your plan)';
  }

  @override
  String get resultReviewsSavedTitle => 'Words added to your review plan 📚';

  @override
  String resultReviewsSavedHint(int count) {
    return '$count words ready for tomorrow';
  }

  @override
  String resultStreakKept(int days) {
    return 'Streak kept · day $days';
  }

  @override
  String get keepLearning => 'Keep learning';

  @override
  String get audioFailed => 'Audio failed — please try again.';

  @override
  String get audioCouldNotLoad => 'Audio could not be loaded.';

  @override
  String sessionSliceChip(int n, String title) {
    return 'Slice $n/5 · $title';
  }

  @override
  String sessionStepLabel(int current, int total) {
    return '$current / $total steps';
  }

  @override
  String get sessionTeaserDialog => 'Up next: short dialogue';

  @override
  String wordCount(int count) {
    return '$count words';
  }

  @override
  String get practiceMistakesOnly => 'Practice my mistakes only';

  @override
  String get upcomingReviews => 'Upcoming reviews';

  @override
  String get noUpcomingReviews => 'No upcoming reviews yet.';

  @override
  String get reviewTomorrow => 'tomorrow';

  @override
  String reviewInDays(int days) {
    return 'in $days days';
  }

  @override
  String get thisWeek => 'This week';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get reminderHint =>
      'Notifications soon — we save your preference for now.';

  @override
  String get reminderOff => 'Off';

  @override
  String get editName => 'Edit your name';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get reminderSoftTitle => 'Remind you once a day?';

  @override
  String get reminderSoftSub =>
      'One reminder at your chosen time to keep your streak. We stay quiet on days you already finished.';

  @override
  String get reminderSoftHint => 'You can change this later in Profile';

  @override
  String get reminderAllow => 'Remind me';

  @override
  String get reminderNotNow => 'Not now';

  @override
  String get reviewWordBadge => 'Review';

  @override
  String get reviewCaughtUp => 'You’re caught up for today';

  @override
  String get reviewCaughtUpHint =>
      'Nice — new review words will show up tomorrow. You can keep learning a lesson if you like.';

  @override
  String get mapTitle => 'Learning map';

  @override
  String mapOverallProgress(int done, int total) {
    return '$done / $total slices';
  }

  @override
  String get mapContinueCta => 'Continue today’s lesson';

  @override
  String get mapOverviewLabel => 'FULL PATH · 7 UNITS · 35 SLICES';

  @override
  String get mapLegendDone => 'done';

  @override
  String get mapLegendNext => 'next';

  @override
  String get mapLegendLocked => 'locked';

  @override
  String get mapPillContinue => 'Continue';

  @override
  String get mapPillDone => 'Done';

  @override
  String get mapPillLocked => 'Locked';

  @override
  String get mapPillSoon => 'Soon';

  @override
  String mapBandProgress(int pct, int done) {
    return '$pct% · $done / 5 slices';
  }

  @override
  String mapBandSliceWords(int slice, int seen, int total, int left) {
    return 'Slice $slice · $seen/$total words · ~$left lessons left';
  }

  @override
  String mapBandSliceAlmost(int slice, int seen, int total) {
    return 'Slice $slice · $seen/$total words · last lesson';
  }

  @override
  String get mapSectionReward => 'Unit reward';
}
