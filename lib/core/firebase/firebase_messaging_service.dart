import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles FCM messages received while the app is in the background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Firebase Cloud Messaging notification service.
class FirebaseMessagingService {
  FirebaseMessagingService() : _messaging = FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  /// Initializes permissions, token refresh, and foreground/open handlers.
  Future<void> initialize() async {
    bool apnsAvailable = true;
    if (Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

      String? apnsToken = await _messaging.getAPNSToken();
      for (int i = 0; apnsToken == null && i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        apnsToken = await _messaging.getAPNSToken();
      }
      if (apnsToken == null) {
        apnsAvailable = false;
        debugPrint(
          '[FCM] APNS is unavailable. Test notifications on a real device.',
        );
      }
    }

    if (!Platform.isIOS || apnsAvailable) {
      try {
        final token = await _messaging.getToken();
        if (token != null && kDebugMode) {
          debugPrint('[FCM] Token: $token');
        }
      } catch (e) {
        debugPrint('[FCM] Unable to get token: $e');
      }
    }

    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        debugPrint('[FCM] Token refreshed: $newToken');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Opened from notification: ${message.messageId}');
      _handleNotificationTap(message);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] Foreground message: ${message.notification?.title}');
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    if (data.isNotEmpty) {
      debugPrint('[FCM] Notification data: $data');
    }
  }

  /// Subscribes the device to an FCM topic.
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribes the device from an FCM topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
