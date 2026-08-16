import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/data/models/word_model.dart';

class WordProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns wordId -> SrsData for words this user has rated for the given target language.
  /// Returns an empty map (never throws) if the subcollection is empty or on error.
  Future<Map<String, SrsData>> getAllProgress(String uid, String targetLang) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('wordProgress')
          .get();

      final map = <String, SrsData>{};
      final prefix = '${targetLang}_';
      for (final doc in snap.docs) {
        if (doc.id.startsWith(prefix)) {
          final wordId = doc.id.substring(prefix.length);
          map[wordId] = SrsData.fromMap(doc.data());
        }
      }
      return map;
    } catch (e) {
      debugPrint('⚠️ getAllProgress failed: $e');
      return {};
    }
  }

  /// Upserts progress for a single word in a specific target language.
  /// Never throws (logs and swallows errors), so a failed write never blocks
  /// the UI from moving to the next card.
  Future<void> saveProgress(
      String uid, String targetLang, String wordId, SrsData data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('wordProgress')
          .doc('${targetLang}_$wordId')
          .set(data.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('⚠️ saveProgress failed for ${targetLang}_$wordId: $e');
    }
  }
}

final wordProgressRepositoryProvider =
    Provider<WordProgressRepository>((ref) => WordProgressRepository());
