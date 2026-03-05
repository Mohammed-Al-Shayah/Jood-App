import Flutter
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseAppCheck
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    #if DEBUG
    // App Check Debug provider - يتجنب "App attestation failed" أثناء التطوير
    AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
    #endif

    // 1. تهيئة Firebase قبل تسجيل الإضافات
    FirebaseApp.configure()

    // 2. تسجيل إضافات Flutter (مثل firebase_auth, google_sign_in وغيرها)
    GeneratedPluginRegistrant.register(with: self)

    // 3. طلب APNs token - مطلوب لـ Phone Auth على iOS (silent push)
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // تمرير APNs token إلى Firebase Auth و Firebase Messaging - مطلوب لـ Phone Auth و FCM على iOS
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    #if DEBUG
    print("[APNs] ✅ APNS device token received - length: \(deviceToken.count)")
    #endif
    Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
