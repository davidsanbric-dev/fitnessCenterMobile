import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  void Function(String?)? _onTapHandler;
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'default_fitness_center',
        'General',
        description: 'General notifications',
        importance: Importance.high,
      );

  Future<void> init() async {
    const darwinInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: darwinInitializationSettings,
      macOS: darwinInitializationSettings,
    );
    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _onTapHandler?.call(response.payload);
      },
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_defaultChannel);
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    final macosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void setOnNotificationTap(void Function(String?)? handler) {
    _onTapHandler = handler;
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    int? id,
    Map<String, dynamic>? payload,
  }) async {
    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _defaultChannel.id,
        _defaultChannel.name,
        channelDescription: _defaultChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    await _plugin.show(
      notificationId,
      title,
      body,
      details,
      payload: payload?.toString(),
    );
  }
}
