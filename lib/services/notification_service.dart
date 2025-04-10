// services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await _requestPermissions();
    _configureHandlers();
  }

  static Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void _configureHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notifications
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification clicks
    });
  }
}