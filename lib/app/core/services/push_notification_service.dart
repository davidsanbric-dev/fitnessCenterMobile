import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/core/services/local_notification_service.dart';

class PushNotificationService extends GetxService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    LocalNotificationService? localNotificationService,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications = localNotificationService;

  final FirebaseMessaging _messaging;
  final RxnString _token = RxnString();
  final LocalNotificationService? _localNotifications;

  String? get token => _token.value;

  Future<void> init() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    await _messaging.setAutoInitEnabled(true);
    await _requestPermission();
    await _syncToken();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedApp);
    FirebaseMessaging.instance.onTokenRefresh.listen(_handleTokenRefresh);
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    // TODO: persist analytics or enqueue work here if needed.
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission();

  }

  Future<void> _syncToken() async {
    final token = await _messaging.getToken();
    _token.value = token;
    // TODO: send the token to your backend tied to the authenticated user.
  }

  void _handleTokenRefresh(String token) {
    _token.value = token;
    // TODO: push the refreshed token to your backend.
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? 'You have a new update';

    _localNotifications?.showLocalNotification(
      title: title,
      body: body,
      payload: message.data,
    );
  }

  void _handleOpenedApp(RemoteMessage message) {
    // TODO: navigate to the appropriate screen based on the payload.
  }
}
