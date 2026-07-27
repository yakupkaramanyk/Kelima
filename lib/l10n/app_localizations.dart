import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('tr')
  ];

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning ☀️'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon 🌤️'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening 🌙'**
  String get goodEvening;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get startLearning;

  /// No description provided for @startLearningSub.
  ///
  /// In en, this message translates to:
  /// **'{count} new words ready · Tap to begin'**
  String startLearningSub(int count);

  /// No description provided for @todaySession.
  ///
  /// In en, this message translates to:
  /// **'Today\'s session'**
  String get todaySession;

  /// No description provided for @practiceQuiz.
  ///
  /// In en, this message translates to:
  /// **'Practice Quiz'**
  String get practiceQuiz;

  /// No description provided for @practiceQuizSub.
  ///
  /// In en, this message translates to:
  /// **'Test what you know'**
  String get practiceQuizSub;

  /// No description provided for @aiConversation.
  ///
  /// In en, this message translates to:
  /// **'AI Conversation'**
  String get aiConversation;

  /// No description provided for @aiConversationSub.
  ///
  /// In en, this message translates to:
  /// **'Chat in your target language'**
  String get aiConversationSub;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get dailyStreak;

  /// No description provided for @keepLearning.
  ///
  /// In en, this message translates to:
  /// **'Keep learning every day!'**
  String get keepLearning;

  /// No description provided for @todayProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get todayProgress;

  /// No description provided for @wordsOf.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} words'**
  String wordsOf(int done, int total);

  /// No description provided for @startFirstSession.
  ///
  /// In en, this message translates to:
  /// **'Start your first session to track progress'**
  String get startFirstSession;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @wordOf.
  ///
  /// In en, this message translates to:
  /// **'Word {current} of {total}'**
  String wordOf(int current, int total);

  /// No description provided for @howWellDidYouKnow.
  ///
  /// In en, this message translates to:
  /// **'How well did you know this?'**
  String get howWellDidYouKnow;

  /// No description provided for @forgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get forgot;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @learned5Words.
  ///
  /// In en, this message translates to:
  /// **'You learned 5 words today!'**
  String get learned5Words;

  /// No description provided for @greatWork.
  ///
  /// In en, this message translates to:
  /// **'Great work — keep it up!'**
  String get greatWork;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @newSession.
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get newSession;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @tapCorrectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap the correct photo'**
  String get tapCorrectPhoto;

  /// No description provided for @typeWordHint.
  ///
  /// In en, this message translates to:
  /// **'Type the word...'**
  String get typeWordHint;

  /// No description provided for @selectCorrectTranslation.
  ///
  /// In en, this message translates to:
  /// **'Select the correct translation'**
  String get selectCorrectTranslation;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @correctFeedback.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correctFeedback;

  /// No description provided for @incorrectFeedback.
  ///
  /// In en, this message translates to:
  /// **'Not quite!'**
  String get incorrectFeedback;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {word}'**
  String correctAnswer(String word);

  /// No description provided for @seeResults.
  ///
  /// In en, this message translates to:
  /// **'See Results'**
  String get seeResults;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @quizMessage.
  ///
  /// In en, this message translates to:
  /// **'{score, select, 5{Perfect score!} 4{Great job!} 3{Good effort!} other{Keep practising!}}'**
  String quizMessage(String score);

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @levelAndXp.
  ///
  /// In en, this message translates to:
  /// **'Level & XP'**
  String get levelAndXp;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @vocabularyLabel.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabularyLabel;

  /// No description provided for @wordsInLibrary.
  ///
  /// In en, this message translates to:
  /// **'words\nin library'**
  String get wordsInLibrary;

  /// No description provided for @topicsLabel.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topicsLabel;

  /// No description provided for @nouns.
  ///
  /// In en, this message translates to:
  /// **'Nouns'**
  String get nouns;

  /// No description provided for @verbs.
  ///
  /// In en, this message translates to:
  /// **'Verbs'**
  String get verbs;

  /// No description provided for @adjectives.
  ///
  /// In en, this message translates to:
  /// **'Adjectives'**
  String get adjectives;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @currentStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Current\nStreak'**
  String get currentStreakLabel;

  /// No description provided for @longestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Longest\nStreak'**
  String get longestStreakLabel;

  /// No description provided for @wordsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Words\nThis Week'**
  String get wordsThisWeek;

  /// No description provided for @onbNativeLangTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your native language?'**
  String get onbNativeLangTitle;

  /// No description provided for @onbNativeLangSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll personalise your experience around it.'**
  String get onbNativeLangSubtitle;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @onbNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get onbNameTitle;

  /// No description provided for @onbNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this to personalise your experience.'**
  String get onbNameSubtitle;

  /// No description provided for @onbNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get onbNameHint;

  /// No description provided for @onbTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Which language do you want to learn?'**
  String get onbTargetTitle;

  /// No description provided for @onbTargetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the language you\'d like to master.'**
  String get onbTargetSubtitle;

  /// No description provided for @onbGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your main learning goal?'**
  String get onbGoalTitle;

  /// No description provided for @onbGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps us tailor vocabulary to your needs.'**
  String get onbGoalSubtitle;

  /// No description provided for @onbTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'How much time can you study daily?'**
  String get onbTimeTitle;

  /// No description provided for @onbTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Consistency beats intensity — any amount is great!'**
  String get onbTimeSubtitle;

  /// No description provided for @onbAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost there!\nCreate your account.'**
  String get onbAccountTitle;

  /// No description provided for @onbAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your progress and start your journey.'**
  String get onbAccountSubtitle;

  /// No description provided for @onbCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get onbCreateAccount;

  /// No description provided for @onbAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get onbAlreadyHaveAccount;

  /// No description provided for @onbSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get onbSignIn;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailPlaceholder;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordPlaceholder;

  /// No description provided for @goalTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get goalTravel;

  /// No description provided for @goalWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get goalWork;

  /// No description provided for @goalEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get goalEducation;

  /// No description provided for @goalPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal Interest'**
  String get goalPersonal;

  /// No description provided for @goalDescTravel.
  ///
  /// In en, this message translates to:
  /// **'Navigate & connect wherever you go'**
  String get goalDescTravel;

  /// No description provided for @goalDescWork.
  ///
  /// In en, this message translates to:
  /// **'Boost your career internationally'**
  String get goalDescWork;

  /// No description provided for @goalDescEducation.
  ///
  /// In en, this message translates to:
  /// **'Succeed in academia & research'**
  String get goalDescEducation;

  /// No description provided for @goalDescPersonal.
  ///
  /// In en, this message translates to:
  /// **'Explore a passion at your own pace'**
  String get goalDescPersonal;

  /// No description provided for @timeDesc5.
  ///
  /// In en, this message translates to:
  /// **'Quick daily habit'**
  String get timeDesc5;

  /// No description provided for @timeDesc10.
  ///
  /// In en, this message translates to:
  /// **'Steady progress'**
  String get timeDesc10;

  /// No description provided for @timeDesc15.
  ///
  /// In en, this message translates to:
  /// **'Solid commitment'**
  String get timeDesc15;

  /// No description provided for @timeDesc30.
  ///
  /// In en, this message translates to:
  /// **'Serious learner'**
  String get timeDesc30;

  /// No description provided for @wordsPerDay.
  ///
  /// In en, this message translates to:
  /// **'~{count} words/day'**
  String wordsPerDay(String count);

  /// No description provided for @backBtn.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backBtn;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOf(String step, String total);

  /// No description provided for @topicFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get topicFood;

  /// No description provided for @topicDailyLife.
  ///
  /// In en, this message translates to:
  /// **'Daily Life'**
  String get topicDailyLife;

  /// No description provided for @topicHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get topicHome;

  /// No description provided for @topicTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get topicTravel;

  /// No description provided for @topicNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get topicNature;

  /// No description provided for @topicHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get topicHealth;

  /// No description provided for @topicWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get topicWork;

  /// No description provided for @learningLang.
  ///
  /// In en, this message translates to:
  /// **'Learning {lang}'**
  String learningLang(String lang);

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String dayStreak(int count);

  /// No description provided for @tapToSeeTranslation.
  ///
  /// In en, this message translates to:
  /// **'Tap to see translation'**
  String get tapToSeeTranslation;

  /// No description provided for @posNoun.
  ///
  /// In en, this message translates to:
  /// **'Noun'**
  String get posNoun;

  /// No description provided for @posVerb.
  ///
  /// In en, this message translates to:
  /// **'Verb'**
  String get posVerb;

  /// No description provided for @posAdjective.
  ///
  /// In en, this message translates to:
  /// **'Adjective'**
  String get posAdjective;

  /// No description provided for @posAdverb.
  ///
  /// In en, this message translates to:
  /// **'Adverb'**
  String get posAdverb;

  /// No description provided for @posPhrase.
  ///
  /// In en, this message translates to:
  /// **'Phrase'**
  String get posPhrase;

  /// No description provided for @topicOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get topicOther;

  /// No description provided for @lang_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get lang_en;

  /// No description provided for @lang_tr.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get lang_tr;

  /// No description provided for @lang_nl.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get lang_nl;

  /// No description provided for @lang_de.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get lang_de;

  /// No description provided for @lang_fr.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get lang_fr;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your learning journey.'**
  String get signInSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @learnTarget.
  ///
  /// In en, this message translates to:
  /// **'Learning Language'**
  String get learnTarget;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLanguage;

  /// No description provided for @validationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get validationEnterEmail;

  /// No description provided for @validationValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get validationValidEmail;

  /// No description provided for @validationEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get validationEnterPassword;

  /// No description provided for @validationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get validationPasswordLength;

  /// No description provided for @errorLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings'**
  String get errorLoadingSettings;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get signedInAs;

  /// No description provided for @defaultLearnerName.
  ///
  /// In en, this message translates to:
  /// **'Learner'**
  String get defaultLearnerName;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @xpToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to Level {next}'**
  String xpToNextLevel(int xp, int next);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @comingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'Listening & speaking exercises are on the way.'**
  String get comingSoonDesc;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @photoMatch.
  ///
  /// In en, this message translates to:
  /// **'📸 Photo Match'**
  String get photoMatch;

  /// No description provided for @writeIt.
  ///
  /// In en, this message translates to:
  /// **'✍️ Write It'**
  String get writeIt;

  /// No description provided for @multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'🔤 Multiple Choice'**
  String get multipleChoice;

  /// No description provided for @howDoYouSay.
  ///
  /// In en, this message translates to:
  /// **'How do you say…'**
  String get howDoYouSay;

  /// No description provided for @inLanguage.
  ///
  /// In en, this message translates to:
  /// **'in {lang}?'**
  String inLanguage(String lang);

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'M,T,W,T,F,S,S'**
  String get weekdays;

  /// No description provided for @tabRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get tabRegister;

  /// No description provided for @tabSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get tabSignIn;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameHint;

  /// No description provided for @dailyTime.
  ///
  /// In en, this message translates to:
  /// **'Daily Time'**
  String get dailyTime;

  /// No description provided for @changeTime.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeTime;

  /// No description provided for @minutesSuffix.
  ///
  /// In en, this message translates to:
  /// **'{min} min'**
  String minutesSuffix(int min);
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
