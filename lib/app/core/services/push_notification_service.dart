import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/core/api/devices_api.dart';
import 'package:portfolio_mobile_app/app/core/services/local_notification_service.dart';

class PushNotificationService extends GetxService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    LocalNotificationService? localNotificationService,
    DevicesApi? devicesApi,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications = localNotificationService,
       _devicesApi = devicesApi ?? DevicesApi();

  final FirebaseMessaging _messaging;
  final RxnString _token = RxnString();
  final LocalNotificationService? _localNotifications;
  final DevicesApi _devicesApi;

  /// Invoked when a "new blog" push arrives (foreground or on app open) so the
  /// home info-slider can refresh on-time. Set by the blog controller.
  VoidCallback? _onBlogCreated;

  /// Invoked when a "slot_updated" push arrives (a trainer changed availability
  /// via the admin web) so the available-slots listing can refresh on-time. Set
  /// by the available-slots controller.
  VoidCallback? _onSlotsUpdated;

  String? get token => _token.value;

  void setOnBlogCreated(VoidCallback callback) {
    _onBlogCreated = callback;
  }

  void setOnSlotsUpdated(VoidCallback callback) {
    _onSlotsUpdated = callback;
  }

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

  /// Registers the current FCM token with the backend. Safe to call repeatedly
  /// (the API upserts) and after login, once a session exists. No-op without a
  /// token or session; failures are swallowed by [DevicesApi].
  Future<void> registerCurrentToken() async {
    final value = _token.value ?? await _safeGetToken();
    if (value == null || value.isEmpty) {
      return;
    }
    _token.value = value;
    await _devicesApi.registerDevice(token: value);
  }

  /// Drops the FCM token on logout so the device stops receiving the previous
  /// session's company pushes; a fresh token is minted on next login.
  Future<void> clearToken() async {
    try {
      await _messaging.deleteToken();
    } catch (_) {
      // Best-effort.
    }
    _token.value = null;
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  Future<String?> _safeGetToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _syncToken() async {
    _token.value = await _safeGetToken();
    // Register with the backend if a session is already present (e.g. app
    // relaunch with a persisted login). On a fresh login, AuthService triggers
    // registration once the session exists.
    await registerCurrentToken();
  }

  void _handleTokenRefresh(String token) {
    _token.value = token;
    unawaited(_devicesApi.registerDevice(token: token));
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? 'You have a new update';

    _localNotifications?.showLocalNotification(
      title: title,
      body: body,
      payload: message.data,
    );

    _maybeHandleBlog(message);
    _maybeHandleSlots(message);
  }

  void _handleOpenedApp(RemoteMessage message) {
    _maybeHandleBlog(message);
    _maybeHandleSlots(message);
  }

  void _maybeHandleBlog(RemoteMessage message) {
    if (message.data['type'] == 'blog_created') {
      _onBlogCreated?.call();
    }
  }

  void _maybeHandleSlots(RemoteMessage message) {
    if (message.data['type'] == 'slot_updated') {
      _onSlotsUpdated?.call();
    }
  }
}
