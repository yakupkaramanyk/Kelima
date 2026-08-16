import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kelima/application/auth/auth_provider.dart';
import 'package:kelima/application/auth/user_prefs_provider.dart';
import 'package:kelima/data/models/user_stats_model.dart';

// Provides the current user's stats
final userStatsProvider = StreamProvider<UserStatsModel>((ref) {
  final user = ref.watch(currentUserProvider);
  final prefsAsync = ref.watch(userLangPrefsProvider);
  final dailyMinutes = prefsAsync.valueOrNull?.dailyMinutes ?? 10;

  if (user == null) {
    return Stream.value(UserStatsModel.empty(dailyMinutes: dailyMinutes));
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists || doc.data() == null) {
      return UserStatsModel.empty(dailyMinutes: dailyMinutes);
    }
    
    var stats = UserStatsModel.fromMap(doc.data()!, dailyMinutes: dailyMinutes);
    
    // Check if we need to reset todayWordsLearned for a new day.
    // Guard uses lastResetDate (not lastActivityDate) so the condition becomes
    // false after the first write and the stream mapper never fires again for
    // the same day. lastActivityDate is reserved for streak counting only.
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (stats.lastResetDate != todayStr && stats.todayWordsLearned > 0) {
      // Return a 0-count copy immediately for the UI, and kick off the
      // Firestore write (which will also stamp lastResetDate = today).
      Future.microtask(() {
        ref.read(userStatsServiceProvider).resetDailyWordsLearnedIfNewDay();
      });
      stats = stats.copyWith(todayWordsLearned: 0);
    }
    
    return stats;
  });
});

final userStatsServiceProvider = Provider<UserStatsService>((ref) {
  return UserStatsService(ref);
});

class UserStatsService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserStatsService(this._ref);

  String? get _uid => _ref.read(currentUserProvider)?.uid;

  String get _todayStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> resetDailyWordsLearnedIfNewDay() async {
    final uid = _uid;
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final lastReset = data['lastResetDate'] as String?;
      final wordsLearned = data['todayWordsLearned'] as int? ?? 0;
      final dailyMinutes = data['dailyMinutes'] as int? ?? 10;

      if (lastReset != _todayStr) {
        transaction.set(docRef, {
          if (wordsLearned > 0) 'todayWordsLearned': 0,
          'todayGoal': wordsPerSession(dailyMinutes),
          'lastResetDate': _todayStr, // stamps today so the loop stops
        }, SetOptions(merge: true));
      }
    });
  }

  /// Called after each word rating
  Future<void> addWordRating(int xpGained) async {
    final uid = _uid;
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      
      int totalXP = 0;
      int wordsLearned = 0;
      String? lastDate;

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        totalXP = data['totalXP'] as int? ?? 0;
        wordsLearned = data['todayWordsLearned'] as int? ?? 0;
        lastDate = data['lastActivityDate'] as String?;
      }

      if (lastDate != today) {
        wordsLearned = 0;
      }

      transaction.set(docRef, {
        'totalXP': totalXP + xpGained,
        'todayWordsLearned': wordsLearned + 1,
      }, SetOptions(merge: true));
    });
  }

  /// Called after completing a session
  Future<void> completeSession() async {
    final uid = _uid;
    if (uid == null) return;
    
    final docRef = _firestore.collection('users').doc(uid);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      
      int currentStreak = 0;
      String? lastDate;
      
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        currentStreak = data['streakCount'] as int? ?? 0;
        lastDate = data['lastActivityDate'] as String?;
      }
      
      int newStreak;
      if (lastDate == null) {
        newStreak = 1;
      } else if (lastDate == today) {
        newStreak = currentStreak; // already counted today
      } else {
        final last = DateTime.parse(lastDate);
        // Using difference in days. Note: if time was involved it might be tricky,
        // but since it's just parsing 'yyyy-MM-dd', difference(last).inDays works if timezones align.
        final todayDt = DateTime.parse(today);
        final diff = todayDt.difference(last).inDays;
        newStreak = diff == 1 ? currentStreak + 1 : 1;
      }
      
      transaction.set(docRef, {
        'streakCount': newStreak,
        'lastActivityDate': today,
      }, SetOptions(merge: true));
    });
  }
}
