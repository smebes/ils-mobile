// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SprachApp';

  @override
  String get tabLearn => 'Apprendre';

  @override
  String get tabReview => 'Réviser';

  @override
  String get tabProfile => 'Profil';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingHello => 'Bonjour';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name !';
  }

  @override
  String todayMinutesEnough(int minutes) {
    return 'Environ $minutes minutes d’allemand suffisent pour aujourd’hui.';
  }

  @override
  String streakDays(int count) {
    return 'Série de $count jours';
  }

  @override
  String levelLabel(int level) {
    return 'Niveau $level';
  }

  @override
  String xpLabel(int xp) {
    return '$xp XP';
  }

  @override
  String get dailyGoal => 'OBJECTIF DU JOUR';

  @override
  String dailyGoalProgress(int done, int total) {
    return '$done / $total leçon';
  }

  @override
  String dailyGoalDoneCheck(int done, int total) {
    return '$done / $total leçon ✓';
  }

  @override
  String get goalHintNew => 'Une courte leçon complète la journée.';

  @override
  String get goalHintProgress => 'Presque fini — continue la leçon.';

  @override
  String get goalHintDone => 'Objectif du jour atteint. Série +1.';

  @override
  String get todaysLesson => 'LEÇON DU JOUR';

  @override
  String lessonNumber(int id) {
    return 'Leçon $id';
  }

  @override
  String get lessonTitleL1 => 'Guten Tag! Mein Name ist …';

  @override
  String get slice1Title => 'Salutations et présentations';

  @override
  String get slice2Title => 'Comment tu t’appelles ?';

  @override
  String get slice3Title => 'D’où viens-tu ? Pays et langue';

  @override
  String get slice4Title => 'Lettres et orthographe';

  @override
  String get slice5Title => 'Adresse et carte de visite';

  @override
  String metaLessonLine(int words, int minutes) {
    return '$words mots · 1 court dialogue · ~$minutes min';
  }

  @override
  String reviewWaiting(int count) {
    return 'À réviser : $count';
  }

  @override
  String get readyToStart => 'Prêt à commencer';

  @override
  String lessonProgressPct(int pct) {
    return 'Progression : $pct %';
  }

  @override
  String get continueLabel => 'continuer';

  @override
  String get sliceFinishedToday => 'tranche du jour terminée';

  @override
  String get ctaStartToday => 'Commencer la leçon du jour';

  @override
  String get ctaContinue => 'Reprendre où tu en étais';

  @override
  String get ctaExtraPractice => 'Pratique supplémentaire';

  @override
  String ctaSubNew(int words) {
    return '~7 min · $words mots';
  }

  @override
  String get ctaSubProgress => '~4 min · continuer';

  @override
  String get ctaSubDone => '+10 XP · courte révision';

  @override
  String get lookAtTomorrow => 'Voir la leçon de demain';

  @override
  String get tomorrowQueued => 'La tranche de demain sera ajoutée.';

  @override
  String get learningPath => 'PARCOURS';

  @override
  String sliceDoneNote(String de) {
    return 'Terminé · $de';
  }

  @override
  String sliceActiveNew(String de) {
    return 'Leçon du jour · $de';
  }

  @override
  String sliceActiveProgress(String de) {
    return 'En cours · $de';
  }

  @override
  String sliceLockedNote(String de) {
    return 'Pas encore · $de';
  }

  @override
  String sliceNextNote(String de) {
    return 'À suivre · $de';
  }

  @override
  String get sliceDoneSnack => 'Tranche terminée. Renforce-la dans Réviser.';

  @override
  String get finishTodayFirst => 'Termine d’abord la leçon du jour.';

  @override
  String lektionLockedTitle(int n, String title) {
    return 'Leçon $n · $title';
  }

  @override
  String get pathL2Note => 'S’ouvre à 80 % de progression en L1';

  @override
  String get pathSoon => 'Bientôt';

  @override
  String get pathTitleL1 => 'Guten Tag · Bonjour';

  @override
  String get pathTitleL2 => 'Meine Familie · Ma famille';

  @override
  String get pathTitleL3 => 'Einkaufen · Courses';

  @override
  String get pathTitleL4 => 'Meine Wohnung · Chez moi';

  @override
  String get pathTitleL5 => 'Tagesabläufe · Routine';

  @override
  String get pathTitleL6 => 'Freizeit · Temps libre';

  @override
  String get pathTitleL7 => 'Kinder und Schule · Enfants et école';

  @override
  String get locked => 'Verrouillé';

  @override
  String get preparing => 'Bientôt';

  @override
  String get lockMsgL2 =>
      'S’ouvre quand ta progression L1 atteint 80 %. Réviser augmente ce taux.';

  @override
  String get lockMsgSoon => 'Cette unité sera bientôt prête.';

  @override
  String get section1Progress => 'Progression unité 1';

  @override
  String wordsLeftApprox(int count) {
    return 'Environ $count mots restants.';
  }

  @override
  String get backToTodayLesson => 'Retour à la leçon du jour';

  @override
  String get ok => 'OK';

  @override
  String get later => 'Plus tard';

  @override
  String get dailyGoalDuration => 'Durée de l’objectif';

  @override
  String get goalEasy => 'Tranquille';

  @override
  String get goalNormal => 'Normal';

  @override
  String get goalIntense => 'Soutenu';

  @override
  String get goalSerious => 'Sérieux';

  @override
  String minutesShort(int m) {
    return '$m min';
  }

  @override
  String loadError(String error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String get loadingLesson => 'Chargement de la leçon…';

  @override
  String get reviewTitle => 'Réviser';

  @override
  String get reviewSubtitle =>
      'On rafraîchit les mots pour ne pas les oublier.';

  @override
  String reviewDueToday(int count) {
    return 'Tu as $count mots à réviser aujourd’hui';
  }

  @override
  String get reviewDueHint =>
      '~3 minutes · les mots bien connus reviennent moins souvent';

  @override
  String get startReview => 'Commencer la révision';

  @override
  String get noReviewYet => 'Pas encore de révision';

  @override
  String get noReviewHint =>
      'Termine d’abord une courte leçon — tes mots apparaîtront ici demain.';

  @override
  String get startTodaysLesson => 'Commencer la leçon du jour';

  @override
  String get myMistakes => 'Mes erreurs';

  @override
  String get weakWords => 'Mots faibles';

  @override
  String get listeningPractice => 'Écoute';

  @override
  String get pronunciation => 'Prononciation';

  @override
  String get comingSoon => 'Bientôt';

  @override
  String get mistakesSoon => 'Le journal d’erreurs arrive bientôt.';

  @override
  String get weakSoon => 'La liste des mots faibles arrive bientôt.';

  @override
  String get studentFallback => 'Apprenant';

  @override
  String profileA1Streak(int days) {
    return 'Allemand A1 · $days jours d’affilée';
  }

  @override
  String get statStreak => 'jours de série';

  @override
  String get statXp => 'XP';

  @override
  String get statUnit1 => 'Unité 1';

  @override
  String get appLanguage => 'Langue de l’app';

  @override
  String get learningLanguage => 'Langue apprise';

  @override
  String get learningLanguageValue => 'Allemand A1';

  @override
  String get speakingPractice => 'Pratique orale';

  @override
  String get uiLangTr => 'Turc';

  @override
  String get uiLangEn => 'Anglais';

  @override
  String get uiLangFr => 'Français';

  @override
  String get uiLangDe => 'Allemand';

  @override
  String get chooseAppLanguage => 'Langue de l’app';

  @override
  String get langChromeHint =>
      'Les menus restent dans ta langue. Le contenu des leçons reste en allemand.';

  @override
  String get onboardingNameTitle => 'Comment t’appeler ?';

  @override
  String get onboardingNameSub =>
      'On utilise ton prénom seulement pour te saluer.';

  @override
  String get nameHint => 'Ton prénom';

  @override
  String get nameOptional =>
      'Laisse vide si tu préfères — on dira « Bonjour ! »';

  @override
  String get previewLabel => 'APERÇU';

  @override
  String get onboardingLevelTitle => 'Où en es-tu en allemand ?';

  @override
  String get onboardingLevelSub => 'On ajuste ton point de départ.';

  @override
  String get levelZero => 'Je commence à zéro';

  @override
  String get levelZeroSub => 'On démarre à la leçon 1, première tranche';

  @override
  String get levelSome => 'Je connais un peu l’allemand';

  @override
  String get levelSomeSub => 'Court test de niveau · bientôt';

  @override
  String get levelCourse => 'J’ai déjà suivi un cours';

  @override
  String get levelCourseSub => 'On accélère sur les mots connus';

  @override
  String get placementSoon => 'Le test de niveau arrive bientôt.';

  @override
  String get a1OnlyNote =>
      'Seul le contenu A1 est disponible pour l’instant. Tu pourras changer ça dans Profil.';

  @override
  String get onboardingGoalTitle => 'Combien de temps par jour ?';

  @override
  String get onboardingGoalSub =>
      'Tu pourras changer ça plus tard dans Profil.';

  @override
  String goalPicked(int minutes) {
    return 'Ton objectif : $minutes min\nUne courte tranche ≈ 15 mots.';
  }

  @override
  String get onboardingArtikelTitle => 'Apprends les articles par couleur';

  @override
  String get onboardingArtikelSub =>
      'Le plus dur de l’allemand devient une couleur. Les mêmes partout dans l’app.';

  @override
  String get artikelDer => 'masculin';

  @override
  String get artikelDie => 'féminin';

  @override
  String get artikelDas => 'neutre';

  @override
  String get trTipNote =>
      'Astuce : au lieu de traduire mot à mot « je m’appelle… », l’allemand utilise souvent Ich heiße … comme formule entière.';

  @override
  String get continueBtn => 'Continuer';

  @override
  String get letsStart => 'C’est parti';

  @override
  String get newWord => 'Nouveau mot';

  @override
  String get showTranslation => 'Afficher la traduction';

  @override
  String get listenTooltip => 'Écouter';

  @override
  String pluralLabel(String plural) {
    return 'Pluriel : die $plural';
  }

  @override
  String get checkAnswer => 'Vérifier';

  @override
  String get answerAllQuestions => 'Réponds à toutes les questions.';

  @override
  String get feedbackCorrectDe => 'Richtig!';

  @override
  String get feedbackAlmostDe => 'Fast!';

  @override
  String get feedbackCorrectLocal => 'Correct';

  @override
  String get feedbackAlmostLocal => 'Presque';

  @override
  String get resultTitle => 'Super !';

  @override
  String get resultDailyDone => 'Tu as atteint l’objectif du jour';

  @override
  String get resultExercises => 'Exercices';

  @override
  String get resultSuccess => 'Réussite';

  @override
  String resultReviewsSaved(int count) {
    return 'Mots enregistrés pour révision 📚\n($count dans ton plan)';
  }

  @override
  String get resultReviewsSavedTitle => 'Mots ajoutés au plan de révision 📚';

  @override
  String resultReviewsSavedHint(int count) {
    return '$count mots prêts pour demain';
  }

  @override
  String resultStreakKept(int days) {
    return 'Série conservée · jour $days';
  }

  @override
  String get keepLearning => 'Continuer à apprendre';

  @override
  String get audioFailed => 'Audio échoué — réessaie.';

  @override
  String get audioCouldNotLoad => 'Impossible de charger l’audio.';

  @override
  String sessionSliceChip(int n, String title) {
    return 'Tranche $n/5 · $title';
  }

  @override
  String sessionStepLabel(int current, int total) {
    return '$current / $total étapes';
  }

  @override
  String get sessionTeaserDialog => 'Bientôt : court dialogue';

  @override
  String wordCount(int count) {
    return '$count mots';
  }

  @override
  String get practiceMistakesOnly => 'Travailler seulement mes erreurs';

  @override
  String get upcomingReviews => 'Révisions à venir';

  @override
  String get noUpcomingReviews => 'Pas encore de révisions planifiées.';

  @override
  String get reviewTomorrow => 'demain';

  @override
  String reviewInDays(int days) {
    return 'dans $days jours';
  }

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get reminderTime => 'Heure de rappel';

  @override
  String get reminderHint =>
      'Notifications bientôt — on enregistre ta préférence pour l’instant.';

  @override
  String get reminderOff => 'Désactivé';

  @override
  String get editName => 'Modifier ton prénom';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Jeu';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sam';

  @override
  String get daySun => 'Dim';

  @override
  String get reminderSoftTitle => 'Un rappel une fois par jour ?';

  @override
  String get reminderSoftSub =>
      'Un seul rappel à l’heure choisie pour garder ta série. On se tait les jours où tu as déjà fini.';

  @override
  String get reminderSoftHint => 'Modifiable plus tard dans Profil';

  @override
  String get reminderAllow => 'Me rappeler';

  @override
  String get reminderNotNow => 'Pas maintenant';

  @override
  String get reviewWordBadge => 'Révision';

  @override
  String get reviewCaughtUp => 'Révisions du jour terminées';

  @override
  String get reviewCaughtUpHint =>
      'Super — de nouveaux mots arriveront demain. Tu peux continuer une leçon si tu veux.';

  @override
  String get mapTitle => 'Carte d’apprentissage';

  @override
  String mapOverallProgress(int done, int total) {
    return '$done / $total tranches';
  }

  @override
  String get mapContinueCta => 'Continuer la leçon du jour';

  @override
  String get mapOverviewLabel => 'TOUT LE PARCOURS · 7 UNITÉS · 35 TRANCHES';

  @override
  String get mapLegendDone => 'terminé';

  @override
  String get mapLegendNext => 'suivant';

  @override
  String get mapLegendLocked => 'verrouillé';

  @override
  String get mapPillContinue => 'Continuer';

  @override
  String get mapPillDone => 'Terminé';

  @override
  String get mapPillLocked => 'Verrouillé';

  @override
  String get mapPillSoon => 'Bientôt';

  @override
  String mapBandProgress(int pct, int done) {
    return '$pct % · $done / 5 tranches';
  }

  @override
  String get mapSectionReward => 'Récompense d’unité';
}
