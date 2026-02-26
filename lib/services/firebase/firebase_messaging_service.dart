import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      // TODO: Save token to Firestore for the current user
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Handle notification when app is in foreground
    // You can show a local notification or update UI
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle notification tap when app was in background
    // Navigate to the relevant screen
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
