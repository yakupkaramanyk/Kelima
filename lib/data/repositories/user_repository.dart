import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kelima/data/models/onboarding_data.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Save onboarding answers to Firestore under the user's UID
  Future<void> saveOnboardingData({
    required String uid,
    required OnboardingData data,
  }) async {
    await _usersCollection.doc(uid).set(
          data.toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<void> updatePartialOnboardingData({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    if (data.isEmpty) return;
    await _usersCollection.doc(uid).set(
          data,
          SetOptions(merge: true),
        );
  }

  /// Fetch a user's onboarding data
  Future<OnboardingData?> getOnboardingData(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    final rawData = doc.data()!;
    print('RAW FIRESTORE DATA: $rawData');
    return OnboardingData.fromFirestore(rawData);
  }
}
