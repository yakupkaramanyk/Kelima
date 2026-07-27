// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get goodMorning => 'Good morning ☀️';

  @override
  String get goodAfternoon => 'Good afternoon 🌤️';

  @override
  String get goodEvening => 'Good evening 🌙';

  @override
  String get startLearning => 'Start Learning';

  @override
  String startLearningSub(int count) {
    return '$count new words ready · Tap to begin';
  }

  @override
  String get todaySession => 'Today\'s session';

  @override
  String get practiceQuiz => 'Practice Quiz';

  @override
  String get practiceQuizSub => 'Test what you know';

  @override
  String get aiConversation => 'AI Conversation';

  @override
  String get aiConversationSub => 'Chat in your target language';

  @override
  String get dailyStreak => 'Daily Streak';

  @override
  String get keepLearning => 'Keep learning every day!';

  @override
  String get todayProgress => 'Today\'s Progress';

  @override
  String wordsOf(int done, int total) {
    return '$done / $total words';
  }

  @override
  String get startFirstSession => 'Start your first session to track progress';

  @override
  String get navLearn => 'Learn';

  @override
  String get navPractice => 'Practice';

  @override
  String get navProgress => 'Progress';

  @override
  String wordOf(int current, int total) {
    return 'Word $current of $total';
  }

  @override
  String get howWellDidYouKnow => 'How well did you know this?';

  @override
  String get forgot => 'Forgot';

  @override
  String get hard => 'Hard';

  @override
  String get easy => 'Easy';

  @override
  String get learned5Words => 'You learned 5 words today!';

  @override
  String get greatWork => 'Great work — keep it up!';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get newSession => 'New Session';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get tapCorrectPhoto => 'Tap the correct photo';

  @override
  String get typeWordHint => 'Type the word...';

  @override
  String get selectCorrectTranslation => 'Select the correct translation';

  @override
  String get check => 'Check';

  @override
  String get correctFeedback => 'Correct!';

  @override
  String get incorrectFeedback => 'Not quite!';

  @override
  String correctAnswer(String word) {
    return 'Correct answer: $word';
  }

  @override
  String get seeResults => 'See Results';

  @override
  String get next => 'Next';

  @override
  String quizMessage(String score) {
    String _temp0 = intl.Intl.selectLogic(
      score,
      {
        '5': 'Perfect score!',
        '4': 'Great job!',
        '3': 'Good effort!',
        'other': 'Keep practising!',
      },
    );
    return '$_temp0';
  }

  @override
  String get progressTitle => 'Progress';

  @override
  String get levelAndXp => 'Level & XP';

  @override
  String get streakLabel => 'Streak';

  @override
  String get vocabularyLabel => 'Vocabulary';

  @override
  String get wordsInLibrary => 'words\nin library';

  @override
  String get topicsLabel => 'Topics';

  @override
  String get nouns => 'Nouns';

  @override
  String get verbs => 'Verbs';

  @override
  String get adjectives => 'Adjectives';

  @override
  String get other => 'Other';

  @override
  String get currentStreakLabel => 'Current\nStreak';

  @override
  String get longestStreakLabel => 'Longest\nStreak';

  @override
  String get wordsThisWeek => 'Words\nThis Week';

  @override
  String get onbNativeLangTitle => 'What\'s your native language?';

  @override
  String get onbNativeLangSubtitle =>
      'We\'ll personalise your experience around it.';

  @override
  String get continueBtn => 'Continue';

  @override
  String get onbNameTitle => 'What\'s your name?';

  @override
  String get onbNameSubtitle =>
      'We\'ll use this to personalise your experience.';

  @override
  String get onbNameHint => 'Your first name';

  @override
  String get onbTargetTitle => 'Which language do you want to learn?';

  @override
  String get onbTargetSubtitle => 'Pick the language you\'d like to master.';

  @override
  String get onbGoalTitle => 'What\'s your main learning goal?';

  @override
  String get onbGoalSubtitle =>
      'This helps us tailor vocabulary to your needs.';

  @override
  String get onbTimeTitle => 'How much time can you study daily?';

  @override
  String get onbTimeSubtitle =>
      'Consistency beats intensity — any amount is great!';

  @override
  String get onbAccountTitle => 'Almost there!\nCreate your account.';

  @override
  String get onbAccountSubtitle => 'Save your progress and start your journey.';

  @override
  String get onbCreateAccount => 'Create Account';

  @override
  String get onbAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get onbSignIn => 'Sign in';

  @override
  String get emailPlaceholder => 'Email address';

  @override
  String get passwordPlaceholder => 'Password';

  @override
  String get goalTravel => 'Travel';

  @override
  String get goalWork => 'Work';

  @override
  String get goalEducation => 'Education';

  @override
  String get goalPersonal => 'Personal Interest';

  @override
  String get goalDescTravel => 'Navigate & connect wherever you go';

  @override
  String get goalDescWork => 'Boost your career internationally';

  @override
  String get goalDescEducation => 'Succeed in academia & research';

  @override
  String get goalDescPersonal => 'Explore a passion at your own pace';

  @override
  String get timeDesc5 => 'Quick daily habit';

  @override
  String get timeDesc10 => 'Steady progress';

  @override
  String get timeDesc15 => 'Solid commitment';

  @override
  String get timeDesc30 => 'Serious learner';

  @override
  String wordsPerDay(String count) {
    return '~$count words/day';
  }

  @override
  String get backBtn => 'Back';

  @override
  String stepOf(String step, String total) {
    return 'Step $step of $total';
  }

  @override
  String get topicFood => 'Food';

  @override
  String get topicDailyLife => 'Daily Life';

  @override
  String get topicHome => 'Home';

  @override
  String get topicTravel => 'Travel';

  @override
  String get topicNature => 'Nature';

  @override
  String get topicHealth => 'Health';

  @override
  String get topicWork => 'Work';

  @override
  String learningLang(String lang) {
    return 'Learning $lang';
  }

  @override
  String dayStreak(int count) {
    return '$count day streak';
  }

  @override
  String get tapToSeeTranslation => 'Tap to see translation';

  @override
  String get posNoun => 'Noun';

  @override
  String get posVerb => 'Verb';

  @override
  String get posAdjective => 'Adjective';

  @override
  String get posAdverb => 'Adverb';

  @override
  String get posPhrase => 'Phrase';

  @override
  String get topicOther => 'Other';

  @override
  String get lang_en => 'English';

  @override
  String get lang_tr => 'Turkish';

  @override
  String get lang_nl => 'Dutch';

  @override
  String get lang_de => 'German';

  @override
  String get lang_fr => 'French';

  @override
  String get settings => 'Settings';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get signInSubtitle => 'Sign in to continue your learning journey.';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get learnTarget => 'Learning Language';

  @override
  String get changeLanguage => 'Change';

  @override
  String get validationEnterEmail => 'Please enter your email.';

  @override
  String get validationValidEmail => 'Please enter a valid email.';

  @override
  String get validationEnterPassword => 'Please enter a password.';

  @override
  String get validationPasswordLength =>
      'Password must be at least 6 characters.';

  @override
  String get errorLoadingSettings => 'Error loading settings';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get defaultLearnerName => 'Learner';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String xpToNextLevel(int xp, int next) {
    return '$xp XP to Level $next';
  }

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get comingSoonDesc => 'Listening & speaking exercises are on the way.';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get photoMatch => '📸 Photo Match';

  @override
  String get writeIt => '✍️ Write It';

  @override
  String get multipleChoice => '🔤 Multiple Choice';

  @override
  String get howDoYouSay => 'How do you say…';

  @override
  String inLanguage(String lang) {
    return 'in $lang?';
  }

  @override
  String get weekdays => 'M,T,W,T,F,S,S';

  @override
  String get tabRegister => 'Register';

  @override
  String get tabSignIn => 'Sign In';

  @override
  String get lastNameHint => 'Last name';

  @override
  String get dailyTime => 'Daily Time';

  @override
  String get changeTime => 'Change';

  @override
  String minutesSuffix(int min) {
    return '$min min';
  }
}
