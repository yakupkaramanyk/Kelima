import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kelima/l10n/app_localizations.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum WordCategory { noun, verb, adjective, adverb, phrase }

enum WordTopic { food, health, work, travel, home, nature, dailyLife }

extension WordCategoryLabel on WordCategory {
  String get label {
    switch (this) {
      case WordCategory.noun:
        return 'Noun';
      case WordCategory.verb:
        return 'Verb';
      case WordCategory.adjective:
        return 'Adjective';
      case WordCategory.adverb:
        return 'Adverb';
      case WordCategory.phrase:
        return 'Phrase';
    }
  }

  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case WordCategory.noun:
        return s.posNoun;
      case WordCategory.verb:
        return s.posVerb;
      case WordCategory.adjective:
        return s.posAdjective;
      case WordCategory.adverb:
        return s.posAdverb;
      case WordCategory.phrase:
        return s.posPhrase;
    }
  }
}

extension WordTopicLabel on WordTopic {
  String get label {
    switch (this) {
      case WordTopic.food:
        return 'Food';
      case WordTopic.health:
        return 'Health';
      case WordTopic.work:
        return 'Work';
      case WordTopic.travel:
        return 'Travel';
      case WordTopic.home:
        return 'Home';
      case WordTopic.nature:
        return 'Nature';
      case WordTopic.dailyLife:
        return 'Daily Life';
    }
  }

  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case WordTopic.food:
        return s.topicFood;
      case WordTopic.health:
        return s.topicHealth;
      case WordTopic.work:
        return s.topicWork;
      case WordTopic.travel:
        return s.topicTravel;
      case WordTopic.home:
        return s.topicHome;
      case WordTopic.nature:
        return s.topicNature;
      case WordTopic.dailyLife:
        return s.topicDailyLife;
    }
  }
}

// ── Supported language codes ──────────────────────────────────────────────────
// 'en' | 'tr' | 'nl' | 'de' | 'fr'

// ── SRS Data ─────────────────────────────────────────────────────────────────

class SrsData {
  final DateTime nextReviewDate;
  final int interval; // days
  final double easeFactor;

  const SrsData({
    required this.nextReviewDate,
    required this.interval,
    required this.easeFactor,
  });

  static SrsData fresh() => SrsData(
        nextReviewDate: DateTime.now(),
        interval: 1,
        easeFactor: 2.5,
      );

  SrsData copyWith({
    DateTime? nextReviewDate,
    int? interval,
    double? easeFactor,
  }) =>
      SrsData(
        nextReviewDate: nextReviewDate ?? this.nextReviewDate,
        interval: interval ?? this.interval,
        easeFactor: easeFactor ?? this.easeFactor,
      );

  Map<String, dynamic> toMap() => {
        'nextReviewDate': Timestamp.fromDate(nextReviewDate),
        'interval': interval,
        'easeFactor': easeFactor,
      };

  factory SrsData.fromMap(Map<String, dynamic> map) => SrsData(
        nextReviewDate:
            (map['nextReviewDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        interval: map['interval'] as int? ?? 1,
        easeFactor: (map['easeFactor'] as num?)?.toDouble() ?? 2.5,
      );
}

// ── Word Model ────────────────────────────────────────────────────────────────
//
// MULTI-LANGUAGE DESIGN:
//   translations  : Map<langCode, word>        e.g. {'en':'apple','tr':'elma','nl':'appel',...}
//   definitions   : Map<langCode, definition>
//   examples      : Map<langCode, sentence>
//
// The UI resolves the correct string via helper getters that take
// targetLang and nativeLang as parameters.

class WordModel {
  final String id;

  /// translations['en'], translations['tr'], translations['nl'], etc.
  final Map<String, String> translations;

  /// Short definition in each language
  final Map<String, String> definitions;

  /// Example sentence in each language
  final Map<String, String> examples;

  final WordCategory category;
  final WordTopic topic;
  final String? imageUrl; // null = gradient placeholder
  final int difficulty; // 1–5
  final SrsData srsData;

  const WordModel({
    required this.id,
    required this.translations,
    required this.definitions,
    required this.examples,
    required this.category,
    required this.topic,
    this.imageUrl,
    required this.difficulty,
    required this.srsData,
  });

  // ── Convenience helpers ───────────────────────────────────────────────────

  /// The word in the TARGET language (shown on card front)
  String wordIn(String langCode) =>
      translations[langCode] ?? translations['en'] ?? id;

  /// The translation in the NATIVE language (shown on card back)
  String translationIn(String langCode) =>
      translations[langCode] ?? translations['tr'] ?? id;

  /// Example sentence in any language
  String exampleIn(String langCode) =>
      examples[langCode] ?? examples['en'] ?? '';

  /// Definition in any language
  String definitionIn(String langCode) =>
      definitions[langCode] ?? definitions['en'] ?? '';

  // ── Legacy aliases so existing UI code still compiles ─────────────────────
  // These default to English target / Turkish native — they will be replaced
  // by the language-aware getters once providers are wired up.
  String get word => wordIn('en');
  String get translation => translationIn('tr');
  String get definitionTarget => definitionIn('en');
  String get definitionNative => definitionIn('tr');
  String get exampleTarget => exampleIn('en');
  String get exampleNative => exampleIn('tr');

  // ─────────────────────────────────────────────────────────────────────────

  WordModel copyWith({SrsData? srsData}) => WordModel(
        id: id,
        translations: translations,
        definitions: definitions,
        examples: examples,
        category: category,
        topic: topic,
        imageUrl: imageUrl,
        difficulty: difficulty,
        srsData: srsData ?? this.srsData,
      );
}
