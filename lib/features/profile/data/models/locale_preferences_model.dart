import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';

/// Model class for LocalePreferences with Firestore conversion
class LocalePreferencesModel {
  final String language;
  final String country;
  final String? timeZone;
  final DateTime? lastSyncedAt;

  const LocalePreferencesModel({
    required this.language,
    required this.country,
    this.timeZone,
    this.lastSyncedAt,
  });

  /// Convert from entity to model
  factory LocalePreferencesModel.fromEntity(LocalePreferencesEntity entity) {
    return LocalePreferencesModel(
      language: entity.locale.languageCode,
      country: entity.country,
      timeZone: entity.timeZone,
      lastSyncedAt: entity.lastSyncedAt,
    );
  }

  /// Convert from Firestore document to model
  factory LocalePreferencesModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Firestore document data is null');
    }

    return LocalePreferencesModel(
      language: data['language'] as String? ?? 'en',
      country: data['country'] as String? ?? 'United States',
      timeZone: data['timeZone'] as String?,
      lastSyncedAt: data['lastSyncedAt'] != null
          ? (data['lastSyncedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert from Firestore map to model
  factory LocalePreferencesModel.fromMap(Map<String, dynamic> data) {
    return LocalePreferencesModel(
      language: data['language'] as String? ?? 'en',
      country: data['country'] as String? ?? 'United States',
      timeZone: data['timeZone'] as String?,
      lastSyncedAt: data['lastSyncedAt'] != null
          ? (data['lastSyncedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to entity
  LocalePreferencesEntity toEntity() {
    return LocalePreferencesEntity(
      locale: Locale(language),
      country: country,
      timeZone: timeZone,
      lastSyncedAt: lastSyncedAt,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'language': language,
      'country': country,
      'timeZone': timeZone,
      'lastSyncedAt': lastSyncedAt != null
          ? Timestamp.fromDate(lastSyncedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Convert to SharedPreferences map
  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'country': country,
      'timeZone': timeZone,
      'lastSyncedAt': lastSyncedAt?.millisecondsSinceEpoch,
    };
  }
}
