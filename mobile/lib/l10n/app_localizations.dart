import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SprachApp'**
  String get appTitle;

  /// No description provided for @tabLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get tabLearn;

  /// No description provided for @tabReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get tabReview;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingHello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get greetingHello;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}!'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @todayMinutesEnough.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} minutes of German is enough for today.'**
  String todayMinutesEnough(int minutes);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String streakDays(int count);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @xpLabel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String xpLabel(int xp);

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'DAILY GOAL'**
  String get dailyGoal;

  /// No description provided for @dailyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} lesson'**
  String dailyGoalProgress(int done, int total);

  /// No description provided for @dailyGoalDoneCheck.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} lesson ✓'**
  String dailyGoalDoneCheck(int done, int total);

  /// No description provided for @goalHintNew.
  ///
  /// In en, this message translates to:
  /// **'One short lesson completes today.'**
  String get goalHintNew;

  /// No description provided for @goalHintProgress.
  ///
  /// In en, this message translates to:
  /// **'Almost there — continue the lesson.'**
  String get goalHintProgress;

  /// No description provided for @goalHintDone.
  ///
  /// In en, this message translates to:
  /// **'Today’s goal done. Streak +1.'**
  String get goalHintDone;

  /// No description provided for @todaysLesson.
  ///
  /// In en, this message translates to:
  /// **'TODAY’S LESSON'**
  String get todaysLesson;

  /// No description provided for @lessonNumber.
  ///
  /// In en, this message translates to:
  /// **'Lesson {id}'**
  String lessonNumber(int id);

  /// No description provided for @lessonTitleL1.
  ///
  /// In en, this message translates to:
  /// **'Guten Tag! Mein Name ist …'**
  String get lessonTitleL1;

  /// No description provided for @slice1Title.
  ///
  /// In en, this message translates to:
  /// **'Greetings & introductions'**
  String get slice1Title;

  /// No description provided for @slice2Title.
  ///
  /// In en, this message translates to:
  /// **'What’s your name?'**
  String get slice2Title;

  /// No description provided for @slice3Title.
  ///
  /// In en, this message translates to:
  /// **'Where are you from? Country & language'**
  String get slice3Title;

  /// No description provided for @slice4Title.
  ///
  /// In en, this message translates to:
  /// **'Letters & spelling'**
  String get slice4Title;

  /// No description provided for @slice5Title.
  ///
  /// In en, this message translates to:
  /// **'Address & business card'**
  String get slice5Title;

  /// No description provided for @metaLessonLine.
  ///
  /// In en, this message translates to:
  /// **'{words} words · 1 short dialogue · ~{minutes} min'**
  String metaLessonLine(int words, int minutes);

  /// No description provided for @reviewWaiting.
  ///
  /// In en, this message translates to:
  /// **'Due for review: {count}'**
  String reviewWaiting(int count);

  /// No description provided for @readyToStart.
  ///
  /// In en, this message translates to:
  /// **'Ready to start'**
  String get readyToStart;

  /// No description provided for @lessonProgressPct.
  ///
  /// In en, this message translates to:
  /// **'Lesson progress: {pct}%'**
  String lessonProgressPct(int pct);

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'continue'**
  String get continueLabel;

  /// No description provided for @sliceFinishedToday.
  ///
  /// In en, this message translates to:
  /// **'today’s slice done'**
  String get sliceFinishedToday;

  /// No description provided for @ctaStartToday.
  ///
  /// In en, this message translates to:
  /// **'Start today’s lesson'**
  String get ctaStartToday;

  /// No description provided for @ctaContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off'**
  String get ctaContinue;

  /// No description provided for @ctaExtraPractice.
  ///
  /// In en, this message translates to:
  /// **'Extra practice'**
  String get ctaExtraPractice;

  /// No description provided for @ctaSubNew.
  ///
  /// In en, this message translates to:
  /// **'~7 min · {words} words'**
  String ctaSubNew(int words);

  /// No description provided for @ctaSubProgress.
  ///
  /// In en, this message translates to:
  /// **'~4 min · continue'**
  String get ctaSubProgress;

  /// No description provided for @ctaSubDone.
  ///
  /// In en, this message translates to:
  /// **'+10 XP · short review'**
  String get ctaSubDone;

  /// No description provided for @lookAtTomorrow.
  ///
  /// In en, this message translates to:
  /// **'See tomorrow’s lesson'**
  String get lookAtTomorrow;

  /// No description provided for @tomorrowQueued.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow’s slice will be queued.'**
  String get tomorrowQueued;

  /// No description provided for @learningPath.
  ///
  /// In en, this message translates to:
  /// **'LEARNING PATH'**
  String get learningPath;

  /// No description provided for @sliceDoneNote.
  ///
  /// In en, this message translates to:
  /// **'Completed · {de}'**
  String sliceDoneNote(String de);

  /// No description provided for @sliceActiveNew.
  ///
  /// In en, this message translates to:
  /// **'Today’s lesson · {de}'**
  String sliceActiveNew(String de);

  /// No description provided for @sliceActiveProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress · {de}'**
  String sliceActiveProgress(String de);

  /// No description provided for @sliceLockedNote.
  ///
  /// In en, this message translates to:
  /// **'Not yet · {de}'**
  String sliceLockedNote(String de);

  /// No description provided for @sliceNextNote.
  ///
  /// In en, this message translates to:
  /// **'Up next · {de}'**
  String sliceNextNote(String de);

  /// No description provided for @sliceDoneSnack.
  ///
  /// In en, this message translates to:
  /// **'You finished this slice. Strengthen it in Review.'**
  String get sliceDoneSnack;

  /// No description provided for @finishTodayFirst.
  ///
  /// In en, this message translates to:
  /// **'Finish today’s lesson first.'**
  String get finishTodayFirst;

  /// No description provided for @lektionLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson {n} · {title}'**
  String lektionLockedTitle(int n, String title);

  /// No description provided for @pathL2Note.
  ///
  /// In en, this message translates to:
  /// **'Unlocks at 80% progress in L1'**
  String get pathL2Note;

  /// No description provided for @pathSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get pathSoon;

  /// No description provided for @pathTitleL2.
  ///
  /// In en, this message translates to:
  /// **'Meine Familie · My family'**
  String get pathTitleL2;

  /// No description provided for @pathTitleL3.
  ///
  /// In en, this message translates to:
  /// **'Einkaufen · Shopping'**
  String get pathTitleL3;

  /// No description provided for @pathTitleL4.
  ///
  /// In en, this message translates to:
  /// **'Meine Wohnung · My home'**
  String get pathTitleL4;

  /// No description provided for @pathTitleL5.
  ///
  /// In en, this message translates to:
  /// **'Tagesabläufe · Daily routines'**
  String get pathTitleL5;

  /// No description provided for @pathTitleL6.
  ///
  /// In en, this message translates to:
  /// **'Freizeit · Free time'**
  String get pathTitleL6;

  /// No description provided for @pathTitleL7.
  ///
  /// In en, this message translates to:
  /// **'Kinder und Schule · Kids & school'**
  String get pathTitleL7;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get preparing;

  /// No description provided for @lockMsgL2.
  ///
  /// In en, this message translates to:
  /// **'Unlocks when your L1 progress reaches 80%. Reviewing words raises this rate.'**
  String get lockMsgL2;

  /// No description provided for @lockMsgSoon.
  ///
  /// In en, this message translates to:
  /// **'This unit will be ready soon.'**
  String get lockMsgSoon;

  /// No description provided for @section1Progress.
  ///
  /// In en, this message translates to:
  /// **'Unit 1 progress'**
  String get section1Progress;

  /// No description provided for @wordsLeftApprox.
  ///
  /// In en, this message translates to:
  /// **'About {count} more words to go.'**
  String wordsLeftApprox(int count);

  /// No description provided for @backToTodayLesson.
  ///
  /// In en, this message translates to:
  /// **'Back to today’s lesson'**
  String get backToTodayLesson;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @dailyGoalDuration.
  ///
  /// In en, this message translates to:
  /// **'Daily goal length'**
  String get dailyGoalDuration;

  /// No description provided for @goalEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get goalEasy;

  /// No description provided for @goalNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get goalNormal;

  /// No description provided for @goalIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get goalIntense;

  /// No description provided for @goalSerious.
  ///
  /// In en, this message translates to:
  /// **'Serious'**
  String get goalSerious;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{m} min'**
  String minutesShort(int m);

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Error while loading: {error}'**
  String loadError(String error);

  /// No description provided for @loadingLesson.
  ///
  /// In en, this message translates to:
  /// **'Loading lesson…'**
  String get loadingLesson;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @reviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We refresh words so you don’t forget them.'**
  String get reviewSubtitle;

  /// No description provided for @reviewDueToday.
  ///
  /// In en, this message translates to:
  /// **'You have {count} words to review today'**
  String reviewDueToday(int count);

  /// No description provided for @reviewDueHint.
  ///
  /// In en, this message translates to:
  /// **'~3 minutes · words you know appear less often'**
  String get reviewDueHint;

  /// No description provided for @startReview.
  ///
  /// In en, this message translates to:
  /// **'Start review'**
  String get startReview;

  /// No description provided for @noReviewYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewYet;

  /// No description provided for @noReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Finish a short lesson first — your words will show up here tomorrow.'**
  String get noReviewHint;

  /// No description provided for @startTodaysLesson.
  ///
  /// In en, this message translates to:
  /// **'Start today’s lesson'**
  String get startTodaysLesson;

  /// No description provided for @myMistakes.
  ///
  /// In en, this message translates to:
  /// **'My mistakes'**
  String get myMistakes;

  /// No description provided for @weakWords.
  ///
  /// In en, this message translates to:
  /// **'Weak words'**
  String get weakWords;

  /// No description provided for @listeningPractice.
  ///
  /// In en, this message translates to:
  /// **'Listening practice'**
  String get listeningPractice;

  /// No description provided for @pronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get pronunciation;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @mistakesSoon.
  ///
  /// In en, this message translates to:
  /// **'Mistake journal coming soon.'**
  String get mistakesSoon;

  /// No description provided for @weakSoon.
  ///
  /// In en, this message translates to:
  /// **'Weak words list coming soon.'**
  String get weakSoon;

  /// No description provided for @studentFallback.
  ///
  /// In en, this message translates to:
  /// **'Learner'**
  String get studentFallback;

  /// No description provided for @profileA1Streak.
  ///
  /// In en, this message translates to:
  /// **'German A1 · {days} days in a row'**
  String profileA1Streak(int days);

  /// No description provided for @statStreak.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get statStreak;

  /// No description provided for @statXp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get statXp;

  /// No description provided for @statUnit1.
  ///
  /// In en, this message translates to:
  /// **'Unit 1'**
  String get statUnit1;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @learningLanguage.
  ///
  /// In en, this message translates to:
  /// **'Learning language'**
  String get learningLanguage;

  /// No description provided for @learningLanguageValue.
  ///
  /// In en, this message translates to:
  /// **'German A1'**
  String get learningLanguageValue;

  /// No description provided for @speakingPractice.
  ///
  /// In en, this message translates to:
  /// **'Speaking practice'**
  String get speakingPractice;

  /// No description provided for @uiLangTr.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get uiLangTr;

  /// No description provided for @uiLangEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get uiLangEn;

  /// No description provided for @uiLangFr.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get uiLangFr;

  /// No description provided for @uiLangDe.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get uiLangDe;

  /// No description provided for @chooseAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get chooseAppLanguage;

  /// No description provided for @langChromeHint.
  ///
  /// In en, this message translates to:
  /// **'Menus stay in your language. Lesson content stays in German.'**
  String get langChromeHint;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSub.
  ///
  /// In en, this message translates to:
  /// **'We only use your name in greetings.'**
  String get onboardingNameSub;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameHint;

  /// No description provided for @nameOptional.
  ///
  /// In en, this message translates to:
  /// **'Leave blank if you prefer — we’ll say “Hello!”'**
  String get nameOptional;

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW'**
  String get previewLabel;

  /// No description provided for @onboardingLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'How’s your German?'**
  String get onboardingLevelTitle;

  /// No description provided for @onboardingLevelSub.
  ///
  /// In en, this message translates to:
  /// **'We’ll adjust where you start.'**
  String get onboardingLevelSub;

  /// No description provided for @levelZero.
  ///
  /// In en, this message translates to:
  /// **'I’m starting from zero'**
  String get levelZero;

  /// No description provided for @levelZeroSub.
  ///
  /// In en, this message translates to:
  /// **'We begin at Lesson 1, first slice'**
  String get levelZeroSub;

  /// No description provided for @levelSome.
  ///
  /// In en, this message translates to:
  /// **'I know a little German'**
  String get levelSome;

  /// No description provided for @levelSomeSub.
  ///
  /// In en, this message translates to:
  /// **'A short placement test · coming soon'**
  String get levelSomeSub;

  /// No description provided for @levelCourse.
  ///
  /// In en, this message translates to:
  /// **'I’ve taken a course before'**
  String get levelCourse;

  /// No description provided for @levelCourseSub.
  ///
  /// In en, this message translates to:
  /// **'We’ll move faster through known words'**
  String get levelCourseSub;

  /// No description provided for @placementSoon.
  ///
  /// In en, this message translates to:
  /// **'Placement test coming soon.'**
  String get placementSoon;

  /// No description provided for @a1OnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Only A1 content is available for now. You can change this later in Profile.'**
  String get a1OnlyNote;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'How much time can you spare daily?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalSub.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Profile.'**
  String get onboardingGoalSub;

  /// No description provided for @goalPicked.
  ///
  /// In en, this message translates to:
  /// **'Your goal: {minutes} min\nOne short daily slice ≈ 15 words.'**
  String goalPicked(int minutes);

  /// No description provided for @onboardingArtikelTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn articles by color'**
  String get onboardingArtikelTitle;

  /// No description provided for @onboardingArtikelSub.
  ///
  /// In en, this message translates to:
  /// **'The hardest part of German becomes a color. Same colors everywhere in the app.'**
  String get onboardingArtikelSub;

  /// No description provided for @artikelDer.
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get artikelDer;

  /// No description provided for @artikelDie.
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get artikelDie;

  /// No description provided for @artikelDas.
  ///
  /// In en, this message translates to:
  /// **'neuter'**
  String get artikelDas;

  /// No description provided for @trTipNote.
  ///
  /// In en, this message translates to:
  /// **'Tip for many learners: instead of word-by-word “my name is…”, German often uses Ich heiße … as a whole phrase.'**
  String get trTipNote;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @letsStart.
  ///
  /// In en, this message translates to:
  /// **'Let’s start'**
  String get letsStart;

  /// No description provided for @newWord.
  ///
  /// In en, this message translates to:
  /// **'New word'**
  String get newWord;

  /// No description provided for @showTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show translation'**
  String get showTranslation;

  /// No description provided for @listenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listenTooltip;

  /// No description provided for @pluralLabel.
  ///
  /// In en, this message translates to:
  /// **'Plural: die {plural}'**
  String pluralLabel(String plural);

  /// No description provided for @checkAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkAnswer;

  /// No description provided for @answerAllQuestions.
  ///
  /// In en, this message translates to:
  /// **'Please answer all questions.'**
  String get answerAllQuestions;

  /// No description provided for @feedbackCorrectDe.
  ///
  /// In en, this message translates to:
  /// **'Richtig!'**
  String get feedbackCorrectDe;

  /// No description provided for @feedbackAlmostDe.
  ///
  /// In en, this message translates to:
  /// **'Fast!'**
  String get feedbackAlmostDe;

  /// No description provided for @feedbackCorrectLocal.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get feedbackCorrectLocal;

  /// No description provided for @feedbackAlmostLocal.
  ///
  /// In en, this message translates to:
  /// **'Almost'**
  String get feedbackAlmostLocal;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get resultTitle;

  /// No description provided for @resultDailyDone.
  ///
  /// In en, this message translates to:
  /// **'Daily goal completed'**
  String get resultDailyDone;

  /// No description provided for @resultExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get resultExercises;

  /// No description provided for @resultSuccess.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get resultSuccess;

  /// No description provided for @resultReviewsSaved.
  ///
  /// In en, this message translates to:
  /// **'Words saved for review 📚\n({count} in your plan)'**
  String resultReviewsSaved(int count);

  /// No description provided for @keepLearning.
  ///
  /// In en, this message translates to:
  /// **'Keep learning'**
  String get keepLearning;

  /// No description provided for @audioFailed.
  ///
  /// In en, this message translates to:
  /// **'Audio failed — please try again.'**
  String get audioFailed;

  /// No description provided for @audioCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Audio could not be loaded.'**
  String get audioCouldNotLoad;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
