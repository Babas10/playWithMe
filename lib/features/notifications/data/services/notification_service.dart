import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This handler runs in a separate isolate
  // No Firebase.initializeApp() needed here as it's already initialized
  // by the main app
  print('Background message: ${message.notification?.title}');
}

/// Service responsible for handling Firebase Cloud Messaging and local notifications
class NotificationService {
  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  NotificationService({
    required FirebaseMessaging fcm,
    required FlutterLocalNotificationsPlugin localNotifications,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _fcm = fcm,
        _localNotifications = localNotifications,
        _firestore = firestore,
        _auth = auth;

  /// Initialize the notification service
  Future<void> initialize({
    required void Function(RemoteMessage) onMessageTapped,
  }) async {
    // Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('User declined notification permission');
      return;
    }

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          onMessageTapped(RemoteMessage(data: data.cast<String, dynamic>()));
        }
      },
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // For iOS: Get APNS token first, then FCM token
    try {
      // Wait for APNS token to be available on iOS
      final apnsToken = await _fcm.getAPNSToken();
      if (apnsToken != null) {
        print('APNS token obtained: ${apnsToken.substring(0, 10)}...');
      }
    } catch (e) {
      print('APNS token not available (may be Android or simulator): $e');
    }

    // Get and save FCM token
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToFirestore(token);
    } else {
      print('FCM token is null, will retry on token refresh');
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen(_saveTokenToFirestore);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps (app opened from terminated state)
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageTapped);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'lastTokenUpdate': FieldValue.serverTimestamp(),
    });
  }

  /// Handle foreground messages by showing local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Delete FCM token (for logout)
  Future<void> deleteToken() async {
    await _fcm.deleteToken();
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final token = await _fcm.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
