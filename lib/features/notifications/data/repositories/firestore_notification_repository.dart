import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/repositories/notification_repository.dart';

/// Firestore implementation of NotificationRepository
class FirestoreNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreNotificationRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<NotificationPreferencesEntity> getPreferences() async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final doc = await _firestore.collection('users').doc(userId).get();

    final prefsData = doc.data()?['notificationPreferences'] as Map<String, dynamic>?;

    if (prefsData == null) {
      // Return default preferences if none exist
      return const NotificationPreferencesEntity();
    }

    return NotificationPreferencesEntity.fromJson(prefsData);
  }

  @override
  Future<void> updatePreferences(NotificationPreferencesEntity preferences) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore.collection('users').doc(userId).update({
      'notificationPreferences': preferences.toJson(),
    });
  }

  @override
  Stream<NotificationPreferencesEntity> preferencesStream() {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final prefsData = snapshot.data()?['notificationPreferences'] as Map<String, dynamic>?;

      if (prefsData == null) {
        return const NotificationPreferencesEntity();
      }

      return NotificationPreferencesEntity.fromJson(prefsData);
    });
  }
}
