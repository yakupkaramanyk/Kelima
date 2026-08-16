// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get goodMorning => 'İyi sabahlar ☀️';

  @override
  String get goodAfternoon => 'İyi öğleden sonralar 🌤️';

  @override
  String get goodEvening => 'İyi akşamlar 🌙';

  @override
  String get startLearning => 'Öğrenmeye Başla';

  @override
  String startLearningSub(int count) {
    return '$count yeni kelime hazır · Başlamak için dokun';
  }

  @override
  String get todaySession => 'Bugünün oturumu';

  @override
  String get practiceQuiz => 'Alıştırma Testi';

  @override
  String get practiceQuizSub => 'Ne bildiğini test et';

  @override
  String get aiConversation => 'Yapay Zeka Sohbeti';

  @override
  String get aiConversationSub => 'Hedef dilinde sohbet et';

  @override
  String get dailyStreak => 'Günlük Seri';

  @override
  String get keepLearning => 'Her gün öğrenmeye devam et!';

  @override
  String get todayProgress => 'Bugünün İlerlemesi';

  @override
  String wordsOf(int done, int total) {
    return '$done / $total kelime';
  }

  @override
  String get startFirstSession => 'İlk oturumunuzu başlatın';

  @override
  String get navLearn => 'Öğren';

  @override
  String get navPractice => 'Pratik';

  @override
  String get navProgress => 'İlerleme';

  @override
  String wordOf(int current, int total) {
    return 'Kelime $current / $total';
  }

  @override
  String get howWellDidYouKnow => 'Bunu ne kadar iyi bildin?';

  @override
  String get forgot => 'Unuttum';

  @override
  String get hard => 'Zor';

  @override
  String get easy => 'Kolay';

  @override
  String get learned5Words => 'Bugün 5 kelime öğrendin!';

  @override
  String get greatWork => 'Harika iş — devam et!';

  @override
  String get startQuiz => 'Teste Başla';

  @override
  String get newSession => 'Yeni Oturum';

  @override
  String get backToHome => 'Ana Sayfaya Dön';

  @override
  String get tapCorrectPhoto => 'Doğru fotoğrafa dokun';

  @override
  String get typeWordHint => 'Kelimeyi yaz...';

  @override
  String get selectCorrectTranslation => 'Doğru çeviriyi seç';

  @override
  String get check => 'Kontrol Et';

  @override
  String get correctFeedback => 'Doğru!';

  @override
  String get incorrectFeedback => 'Yanlış!';

  @override
  String correctAnswer(String word) {
    return 'Doğru cevap: $word';
  }

  @override
  String get seeResults => 'Sonuçları Gör';

  @override
  String get next => 'İleri';

  @override
  String quizMessage(String score) {
    String _temp0 = intl.Intl.selectLogic(
      score,
      {
        '5': 'Mükemmel!',
        '4': 'Harika iş!',
        '3': 'İyi çaba!',
        'other': 'Pratik yapmaya devam et!',
      },
    );
    return '$_temp0';
  }

  @override
  String get progressTitle => 'İlerleme';

  @override
  String get levelAndXp => 'Seviye ve XP';

  @override
  String get streakLabel => 'Seri';

  @override
  String get vocabularyLabel => 'Kelime Hazinesi';

  @override
  String get wordsInLibrary => 'kelime\nkütüphanede';

  @override
  String get topicsLabel => 'Konular';

  @override
  String get nouns => 'İsimler';

  @override
  String get verbs => 'Fiiller';

  @override
  String get adjectives => 'Sıfatlar';

  @override
  String get other => 'Diğer';

  @override
  String get currentStreakLabel => 'Güncel\nSeri';

  @override
  String get longestStreakLabel => 'En Uzun\nSeri';

  @override
  String get wordsThisWeek => 'Bu Hafta\nKelime';

  @override
  String get onbNativeLangTitle => 'Ana diliniz hangisi?';

  @override
  String get onbNativeLangSubtitle =>
      'Deneyiminizi buna göre kişiselleştireceğiz.';

  @override
  String get continueBtn => 'Devam Et';

  @override
  String get onbNameTitle => 'Adınız ne?';

  @override
  String get onbNameSubtitle =>
      'Bunu deneyiminizi kişiselleştirmek için kullanacağız.';

  @override
  String get onbNameHint => 'Adınız';

  @override
  String get onbTargetTitle => 'Hangi dili öğrenmek istiyorsunuz?';

  @override
  String get onbTargetSubtitle => 'Öğrenmek istediğiniz dili seçin.';

  @override
  String get onbGoalTitle => 'Ana öğrenme hedefiniz nedir?';

  @override
  String get onbGoalSubtitle => 'Buna göre kelime hazinesi öneriyoruz.';

  @override
  String get onbTimeTitle => 'Günlük ne kadar çalışabilirsiniz?';

  @override
  String get onbTimeSubtitle => 'Düzenlilik, yoğunluktan daha önemlidir.';

  @override
  String get onbAccountTitle => 'Hesabınızı oluşturun';

  @override
  String get onbAccountSubtitle => 'İlerlemenizi kaydedin.';

  @override
  String get onbCreateAccount => 'Hesap Oluştur';

  @override
  String get onbAlreadyHaveAccount => 'Zaten hesabınız var mı? ';

  @override
  String get onbSignIn => 'Giriş yap';

  @override
  String get emailPlaceholder => 'E-posta adresi';

  @override
  String get passwordPlaceholder => 'Şifre';

  @override
  String get goalTravel => 'Seyahat';

  @override
  String get goalWork => 'İş';

  @override
  String get goalEducation => 'Eğitim';

  @override
  String get goalPersonal => 'Kişisel İlgi';

  @override
  String get goalVisaExam => 'Eş/Aile Vizesi Hazırlığı';

  @override
  String get goalDescTravel => 'Nereye gidersen git, iletişim kur';

  @override
  String get goalDescWork => 'Kariyerini uluslararası alanda geliştir';

  @override
  String get goalDescEducation => 'Akademi ve araştırmada başarılı ol';

  @override
  String get goalDescPersonal => 'Kendi hızında bir tutkuyu keşfet';

  @override
  String get goalDescVisaExam =>
      'Almanya veya Hollanda\'ya eş vizesi için dil sınavına hazırlanıyorum';

  @override
  String get timeDesc5 => 'Hızlı günlük alışkanlık';

  @override
  String get timeDesc10 => 'Düzenli ilerleme';

  @override
  String get timeDesc15 => 'Güçlü bağlılık';

  @override
  String get timeDesc30 => 'Ciddi öğrenci';

  @override
  String wordsPerDay(String count) {
    return '~$count kelime/gün';
  }

  @override
  String get backBtn => 'Geri';

  @override
  String stepOf(String step, String total) {
    return '$step. adım / $total';
  }

  @override
  String get topicFood => 'Yiyecek';

  @override
  String get topicDailyLife => 'Günlük Hayat';

  @override
  String get topicHome => 'Ev';

  @override
  String get topicTravel => 'Seyahat';

  @override
  String get topicNature => 'Doğa';

  @override
  String get topicHealth => 'Sağlık';

  @override
  String get topicWork => 'İş';

  @override
  String learningLang(String lang) {
    return '$lang Öğreniliyor';
  }

  @override
  String dayStreak(int count) {
    return '$count günlük seri';
  }

  @override
  String get tapToSeeTranslation => 'Çeviriyi görmek için dokun';

  @override
  String get posNoun => 'İsim';

  @override
  String get posVerb => 'Fiil';

  @override
  String get posAdjective => 'Sıfat';

  @override
  String get posAdverb => 'Zarf';

  @override
  String get posPhrase => 'İfade';

  @override
  String get topicOther => 'Diğer';

  @override
  String get lang_en => 'İngilizce';

  @override
  String get lang_tr => 'Türkçe';

  @override
  String get lang_nl => 'Felemenkçe';

  @override
  String get lang_de => 'Almanca';

  @override
  String get lang_fr => 'Fransızca';

  @override
  String get settings => 'Ayarlar';

  @override
  String get welcomeBack => 'Tekrar hoş geldiniz!';

  @override
  String get signInSubtitle => 'Öğrenme yolculuğunuza devam edin.';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get learnTarget => 'Öğrenilen Dil';

  @override
  String get changeLanguage => 'Değiştir';

  @override
  String get validationEnterEmail => 'Lütfen e-posta adresinizi girin.';

  @override
  String get validationValidEmail => 'Lütfen geçerli bir e-posta girin.';

  @override
  String get validationEnterPassword => 'Lütfen şifrenizi girin.';

  @override
  String get validationPasswordLength => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get errorLoadingSettings => 'Ayarlar yüklenemedi';

  @override
  String get signedInAs => 'Giriş yapıldı';

  @override
  String get defaultLearnerName => 'Öğrenci';

  @override
  String levelLabel(int level) {
    return '$level. Seviye';
  }

  @override
  String xpToNextLevel(int xp, int next) {
    return '$xp XP — $next. Seviyeye';
  }

  @override
  String get comingSoon => 'Çok yakında!';

  @override
  String get comingSoonDesc => 'Dinleme ve konuşma alıştırmaları geliyor.';

  @override
  String get practiceTitle => 'Pratik';

  @override
  String get photoMatch => '📸 Fotoğraf Eşleştir';

  @override
  String get writeIt => '✍️ Yaz Bakalım';

  @override
  String get multipleChoice => '🔤 Çoktan Seçmeli';

  @override
  String get howDoYouSay => 'Nasıl dersiniz...';

  @override
  String inLanguage(String lang) {
    return '$lang dilinde?';
  }

  @override
  String get weekdays => 'Pt,Sa,Ça,Pe,Cu,Ct,Pa';

  @override
  String get tabRegister => 'Kayıt Ol';

  @override
  String get tabSignIn => 'Giriş Yap';

  @override
  String get lastNameHint => 'Soyadınız';

  @override
  String get dailyTime => 'Günlük Süre';

  @override
  String get changeTime => 'Değiştir';

  @override
  String minutesSuffix(int min) {
    return '$min dk';
  }
}
