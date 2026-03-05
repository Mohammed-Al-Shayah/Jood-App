import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// معالجة الرسائل في الخلفية (عند إغلاق التطبيق) - يجب تسجيلها قبل runApp
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // يتم تنفيذ هذا عند استلام رسالة والتطبيق في الخلفية/مغلق
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// خدمة Firebase Cloud Messaging للإشعارات
class FirebaseMessagingService {
  FirebaseMessagingService() : _messaging = FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  /// تهيئة الإشعارات وطلب الأذونات (يُستدعى بعد عرض الإطار الأول)
  Future<void> initialize() async {
    // طلب إذن الإشعارات على iOS
    bool apnsAvailable = true;
    if (Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

      // APNS يعمل فقط على الجهاز الفعلي - لا يعمل على المحاكي
      String? apnsToken = await _messaging.getAPNSToken();
      for (int i = 0; apnsToken == null && i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        apnsToken = await _messaging.getAPNSToken();
      }
      if (apnsToken == null) {
        apnsAvailable = false;
        debugPrint('[FCM] APNS غير متوفر (المحاكي لا يدعم الإشعارات - اختبر على جهاز حقيقي)');
      }
    }

    // الحصول على FCM token - يتطلب APNS على iOS (لا يعمل على المحاكي)
    if (!Platform.isIOS || apnsAvailable) {
      try {
        final token = await _messaging.getToken();
        if (token != null) {
          debugPrint('[FCM] Token: $token');
        }
      } catch (e) {
        debugPrint('[FCM] تعذر الحصول على Token: $e');
      }
    }

    // الاستماع لتحديثات الـ token
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
      // أرسل الـ token الجديد للسيرفر هنا إن لزم
    });

    // معالجة الرسائل عند فتح التطبيق من إشعار
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Opened from notification: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // التحقق إذا فُتح التطبيق من إشعار (عند إغلاق التطبيق)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // معالجة الرسائل الواردة والتطبيق مفتوح (foreground)
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] Foreground message: ${message.notification?.title}');
      // يمكن عرض إشعار محلي أو تحديث الـ UI
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    // التنقل بناءً على data في الرسالة
    final data = message.data;
    if (data.isNotEmpty) {
      // مثال: data['type'] = 'booking', data['id'] = '123'
      debugPrint('[FCM] Notification data: $data');
    }
  }

  /// الاشتراك في topic (مثلاً للإشعارات العامة)
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// إلغاء الاشتراك من topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
