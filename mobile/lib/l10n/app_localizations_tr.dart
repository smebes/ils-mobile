// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'SprachApp';

  @override
  String get tabLearn => 'Öğren';

  @override
  String get tabReview => 'Tekrar';

  @override
  String get tabProfile => 'Profil';

  @override
  String get greetingMorning => 'Günaydın';

  @override
  String get greetingHello => 'Merhaba';

  @override
  String get greetingEvening => 'İyi akşamlar';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name!';
  }

  @override
  String todayMinutesEnough(int minutes) {
    return 'Bugün Almanca için yaklaşık $minutes dakikan yeterli.';
  }

  @override
  String streakDays(int count) {
    return '$count günlük seri';
  }

  @override
  String levelLabel(int level) {
    return 'Seviye $level';
  }

  @override
  String xpLabel(int xp) {
    return '$xp XP';
  }

  @override
  String get dailyGoal => 'GÜNLÜK HEDEF';

  @override
  String dailyGoalProgress(int done, int total) {
    return '$done / $total ders';
  }

  @override
  String dailyGoalDoneCheck(int done, int total) {
    return '$done / $total ders ✓';
  }

  @override
  String get goalHintNew => 'Bir kısa ders bugünü tamamlar.';

  @override
  String get goalHintProgress => 'Neredeyse tamam — derse devam et.';

  @override
  String get goalHintDone => 'Bugünün hedefi tamam. Seri +1.';

  @override
  String get todaysLesson => 'BUGÜNKÜ DERS';

  @override
  String lessonNumber(int id) {
    return 'Lektion $id';
  }

  @override
  String get lessonTitleL1 => 'Guten Tag! Mein Name ist …';

  @override
  String get slice1Title => 'Tanışma ve selamlaşma';

  @override
  String get slice2Title => 'Adım nedir? / İsim';

  @override
  String get slice3Title => 'Nerelisin? Ülke ve dil';

  @override
  String get slice4Title => 'Harfler ve heceleme';

  @override
  String get slice5Title => 'Adres ve kartvizit';

  @override
  String metaLessonLine(int words, int minutes) {
    return '$words kelime · 1 kısa konuşma · ~$minutes dakika';
  }

  @override
  String reviewWaiting(int count) {
    return 'Tekrar bekleyen: $count';
  }

  @override
  String get readyToStart => 'Başlamaya hazır';

  @override
  String lessonProgressPct(int pct) {
    return 'Ders ilerlemesi: %$pct';
  }

  @override
  String get continueLabel => 'devam';

  @override
  String get sliceFinishedToday => 'bugünkü dilim bitti';

  @override
  String get ctaStartToday => 'Bugünkü derse başla';

  @override
  String get ctaContinue => 'Kaldığın yerden devam et';

  @override
  String get ctaExtraPractice => 'Ek pratik yap';

  @override
  String ctaSubNew(int words) {
    return '~7 dk · $words kelime';
  }

  @override
  String get ctaSubProgress => '~4 dk · devam';

  @override
  String get ctaSubDone => '+10 XP · kısa tekrar';

  @override
  String get lookAtTomorrow => 'Yarınki derse bak';

  @override
  String get tomorrowQueued => 'Yarınki dilim sıraya girecek.';

  @override
  String get learningPath => 'ÖĞRENME YOLU';

  @override
  String sliceDoneNote(String de) {
    return 'Tamamlandı · $de';
  }

  @override
  String sliceActiveNew(String de) {
    return 'Bugünkü ders · $de';
  }

  @override
  String sliceActiveProgress(String de) {
    return 'Devam ediyor · $de';
  }

  @override
  String sliceLockedNote(String de) {
    return 'Sırada değil · $de';
  }

  @override
  String sliceNextNote(String de) {
    return 'Sıradaki · $de';
  }

  @override
  String get sliceDoneSnack =>
      'Bu dilimi tamamladın. Tekrar sekmesinden pekiştirebilirsin.';

  @override
  String get finishTodayFirst => 'Önce bugünkü dersi bitir.';

  @override
  String lektionLockedTitle(int n, String title) {
    return 'Lektion $n · $title';
  }

  @override
  String get pathL2Note => 'L1 ilerlemen %80 olunca açılır';

  @override
  String get pathSoon => 'Yakında';

  @override
  String get pathTitleL1 => 'Guten Tag · Merhaba';

  @override
  String get pathTitleL2 => 'Meine Familie · Ailem';

  @override
  String get pathTitleL3 => 'Einkaufen · Alışveriş';

  @override
  String get pathTitleL4 => 'Meine Wohnung · Evim';

  @override
  String get pathTitleL5 => 'Tagesabläufe · Günlük rutinler';

  @override
  String get pathTitleL6 => 'Freizeit · Boş zaman';

  @override
  String get pathTitleL7 => 'Kinder und Schule · Çocuklar ve okul';

  @override
  String get locked => 'Kilitli';

  @override
  String get preparing => 'Hazırlanıyor';

  @override
  String get lockMsgL2 =>
      'L1 ilerlemen %80 olunca açılır. Kelimeleri tekrar ettikçe bu oran yükselir.';

  @override
  String get lockMsgSoon => 'Bu bölüm yakında hazır olacak.';

  @override
  String get section1Progress => '1. bölüm ilerlemesi';

  @override
  String wordsLeftApprox(int count) {
    return 'Yaklaşık $count kelime daha kaldı.';
  }

  @override
  String get backToTodayLesson => 'Bugünkü derse dön';

  @override
  String get ok => 'Tamam';

  @override
  String get later => 'Daha sonra';

  @override
  String get dailyGoalDuration => 'Günlük hedef süresi';

  @override
  String get goalEasy => 'Rahat';

  @override
  String get goalNormal => 'Normal';

  @override
  String get goalIntense => 'Yoğun';

  @override
  String get goalSerious => 'Ciddi';

  @override
  String minutesShort(int m) {
    return '$m dk';
  }

  @override
  String loadError(String error) {
    return 'Yüklenirken hata: $error';
  }

  @override
  String get loadingLesson => 'Ders yükleniyor…';

  @override
  String get reviewTitle => 'Tekrar';

  @override
  String get reviewSubtitle => 'Öğrendiğin kelimeleri unutmadan tazeliyoruz.';

  @override
  String reviewDueToday(int count) {
    return 'Bugün tekrar etmen gereken $count kelime var';
  }

  @override
  String get reviewDueHint =>
      '~3 dakika · doğru bildiğin kelimeler daha seyrek gelir';

  @override
  String get startReview => 'Tekrara başla';

  @override
  String get noReviewYet => 'Henüz tekrar yok';

  @override
  String get noReviewHint =>
      'Önce kısa bir ders bitir — öğrendiğin kelimeler yarın tekrar için burada olacak.';

  @override
  String get startTodaysLesson => 'Bugünkü derse başla';

  @override
  String get myMistakes => 'Hatalarım';

  @override
  String get weakWords => 'Zayıf kelimeler';

  @override
  String get listeningPractice => 'Dinleme pratiği';

  @override
  String get pronunciation => 'Telaffuz';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get mistakesSoon => 'Hata defteri yakında.';

  @override
  String get weakSoon => 'Zayıf kelime listesi yakında.';

  @override
  String get studentFallback => 'Öğrenci';

  @override
  String profileA1Streak(int days) {
    return 'Almanca A1 · $days gündür aralıksız';
  }

  @override
  String get statStreak => 'gün seri';

  @override
  String get statXp => 'XP';

  @override
  String get statUnit1 => '1. bölüm';

  @override
  String get appLanguage => 'Uygulama dili';

  @override
  String get learningLanguage => 'Öğrenme dili';

  @override
  String get learningLanguageValue => 'Almanca A1';

  @override
  String get speakingPractice => 'Konuşma alıştırması';

  @override
  String get uiLangTr => 'Türkçe';

  @override
  String get uiLangEn => 'İngilizce';

  @override
  String get uiLangFr => 'Fransızca';

  @override
  String get uiLangDe => 'Almanca';

  @override
  String get chooseAppLanguage => 'Uygulama dili';

  @override
  String get langChromeHint =>
      'Menüler senin dilinde kalır. Ders içeriği Almanca kalır.';

  @override
  String get onboardingNameTitle => 'Sana nasıl hitap edelim?';

  @override
  String get onboardingNameSub => 'Adını sadece selamlamada kullanıyoruz.';

  @override
  String get nameHint => 'Adın';

  @override
  String get nameOptional => 'İstersen boş bırak — “Merhaba!” deriz.';

  @override
  String get previewLabel => 'BÖYLE GÖRÜNECEK';

  @override
  String get onboardingLevelTitle => 'Almanca ile aran nasıl?';

  @override
  String get onboardingLevelSub =>
      'Buna göre nereden başlayacağını ayarlıyoruz.';

  @override
  String get levelZero => 'Sıfırdan başlıyorum';

  @override
  String get levelZeroSub => 'Lektion 1, ilk dilimden başlarız';

  @override
  String get levelSome => 'Biraz Almanca biliyorum';

  @override
  String get levelSomeSub => 'Kısa bir test ile yerini bulalım · yakında';

  @override
  String get levelCourse => 'Daha önce kurs aldım';

  @override
  String get levelCourseSub => 'Bildiğin kelimeleri hızlı geçeriz';

  @override
  String get placementSoon => 'Seviye testi yakında.';

  @override
  String get a1OnlyNote =>
      'Şu an sadece A1 içeriği var. Seçimini sonra Profil’den değiştirebilirsin.';

  @override
  String get onboardingGoalTitle => 'Günde ne kadar ayırabilirsin?';

  @override
  String get onboardingGoalSub => 'Sonra Profil’den değiştirebilirsin.';

  @override
  String goalPicked(int minutes) {
    return 'Seçtiğin hedef: $minutes dk\nGünde 1 kısa ders dilimi ≈ 15 kelime.';
  }

  @override
  String get onboardingArtikelTitle => 'Artikel’i renkle öğren';

  @override
  String get onboardingArtikelSub =>
      'Almancanın en zor kısmı burada bir renge dönüşüyor. Uygulamanın her yerinde aynı renkler.';

  @override
  String get artikelDer => 'eril';

  @override
  String get artikelDie => 'dişil';

  @override
  String get artikelDas => 'nötr';

  @override
  String get trTipNote =>
      'Türkçe konuşanlara özel not: Türkçede “adım Lara” → Almancada Ich heiße Lara.';

  @override
  String get continueBtn => 'Devam';

  @override
  String get letsStart => 'Başlayalım';

  @override
  String get newWord => 'Yeni kelime';

  @override
  String get showTranslation => 'Çeviriyi göster';

  @override
  String get listenTooltip => 'Dinle';

  @override
  String pluralLabel(String plural) {
    return 'Plural: die $plural';
  }

  @override
  String get checkAnswer => 'Kontrol et';

  @override
  String get answerAllQuestions => 'Lütfen tüm soruları cevapla.';

  @override
  String get feedbackCorrectDe => 'Richtig!';

  @override
  String get feedbackAlmostDe => 'Fast!';

  @override
  String get feedbackCorrectLocal => 'Doğru';

  @override
  String get feedbackAlmostLocal => 'Neredeyse';

  @override
  String get resultTitle => 'Harika!';

  @override
  String get resultDailyDone => 'Günlük hedefini tamamladın';

  @override
  String get resultExercises => 'Alıştırmalar';

  @override
  String get resultSuccess => 'Başarı';

  @override
  String resultReviewsSaved(int count) {
    return 'Tekrar için kelimeler kaydedildi 📚\n($count kelime planında)';
  }

  @override
  String get resultReviewsSavedTitle => 'Kelimeler tekrar planına eklendi 📚';

  @override
  String resultReviewsSavedHint(int count) {
    return '$count kelime yarın tekrar için hazır';
  }

  @override
  String resultStreakKept(int days) {
    return 'Seri korundu · $days. gün';
  }

  @override
  String get keepLearning => 'Öğrenmeye devam';

  @override
  String get audioFailed => 'Ses başarısız — lütfen tekrar dene.';

  @override
  String get audioCouldNotLoad => 'Ses yüklenemedi.';

  @override
  String sessionSliceChip(int n, String title) {
    return 'Dilim $n/5 · $title';
  }

  @override
  String sessionStepLabel(int current, int total) {
    return '$current / $total adım';
  }

  @override
  String get sessionTeaserDialog => 'Birazdan: kısa diyalog';

  @override
  String wordCount(int count) {
    return '$count kelime';
  }

  @override
  String get practiceMistakesOnly => 'Sadece hatalarımı çalış';

  @override
  String get upcomingReviews => 'Yaklaşan tekrarlar';

  @override
  String get noUpcomingReviews => 'Henüz planlanmış tekrar yok.';

  @override
  String get reviewTomorrow => 'yarın';

  @override
  String reviewInDays(int days) {
    return '$days gün sonra';
  }

  @override
  String get thisWeek => 'Bu hafta';

  @override
  String get reminderTime => 'Hatırlatma saati';

  @override
  String get reminderHint =>
      'Bildirimler yakında — şimdilik tercihini kaydediyoruz.';

  @override
  String get reminderOff => 'Kapalı';

  @override
  String get editName => 'İsmini düzenle';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get dayMon => 'Pzt';

  @override
  String get dayTue => 'Sal';

  @override
  String get dayWed => 'Çar';

  @override
  String get dayThu => 'Per';

  @override
  String get dayFri => 'Cum';

  @override
  String get daySat => 'Cmt';

  @override
  String get daySun => 'Paz';

  @override
  String get reminderSoftTitle => 'Günde bir kez hatırlatalım mı?';

  @override
  String get reminderSoftSub =>
      'Serini korumak için seçtiğin saatte tek bir hatırlatma. Dersi bitirdiğin gün susuyoruz.';

  @override
  String get reminderSoftHint => 'Sonra Profil’den değişir';

  @override
  String get reminderAllow => 'Hatırlat';

  @override
  String get reminderNotNow => 'Şimdi değil';

  @override
  String get reviewWordBadge => 'Tekrar';

  @override
  String get reviewCaughtUp => 'Bugünlük tekrar bitti';

  @override
  String get reviewCaughtUpHint =>
      'Harika — yarın yeni kelimeler burada olacak. İstersen derse devam edebilirsin.';

  @override
  String get mapTitle => 'Öğrenme haritası';

  @override
  String mapOverallProgress(int done, int total) {
    return '$done / $total dilim';
  }

  @override
  String get mapContinueCta => 'Bugünkü derse devam';

  @override
  String get mapOverviewLabel => 'TÜM YOL · 7 BÖLÜM · 35 DİLİM';

  @override
  String get mapLegendDone => 'tamamlandı';

  @override
  String get mapLegendNext => 'sıradaki';

  @override
  String get mapLegendLocked => 'kilitli';

  @override
  String get mapPillContinue => 'Devam';

  @override
  String get mapPillDone => 'Bitti';

  @override
  String get mapPillLocked => 'Kilitli';

  @override
  String get mapPillSoon => 'Yakında';

  @override
  String mapBandProgress(int pct, int done) {
    return '%$pct · $done / 5 dilim';
  }

  @override
  String mapBandSliceWords(int slice, int seen, int total) {
    return 'Dilim $slice · $seen / $total kelime';
  }

  @override
  String get mapSectionReward => 'Bölüm ödülü';
}
