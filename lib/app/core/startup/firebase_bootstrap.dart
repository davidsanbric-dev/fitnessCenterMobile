import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:fitnesscenter_mobile/app/config/startup_policy.dart';
import 'package:fitnesscenter_mobile/app/core/services/push_notification_service.dart';
import 'package:fitnesscenter_mobile/firebase_options.dart';

/// Entry point invoked by the OS when a push arrives while the app is in the
/// background or terminated. Must be a top-level function annotated with
/// `@pragma('vm:entry-point')` so it survives tree-shaking in release builds.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.handleBackgroundMessage(message);
}

/// Initializes Firebase (idempotently) and registers the background message
/// handler, returning `false` if startup cannot be completed.
///
/// Failures are reported via [FlutterError.reportError] rather than thrown so
/// callers can branch on readiness.
Future<bool> ensureFirebaseReady() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(StartupPolicy.firebaseInitTimeout);
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    return true;
  } on TimeoutException catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'firebase_bootstrap.dart',
        context: ErrorDescription('while initializing Firebase during startup'),
      ),
    );
    return false;
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'firebase_bootstrap.dart',
        context: ErrorDescription(
          'while preparing Firebase dependencies during startup',
        ),
      ),
    );
    return false;
  }
}

/// Best-effort Firebase project id for log/diagnostic context, falling back to
/// the configured options and then `'-'` when Firebase is not yet initialized.
String firebaseProjectIdForLogs() {
  try {
    return Firebase.app().options.projectId;
  } catch (_) {
    try {
      return DefaultFirebaseOptions.currentPlatform.projectId;
    } catch (_) {
      return '-';
    }
  }
}

/// Best-effort Firebase app name for log/diagnostic context.
String firebaseAppNameForLogs() {
  try {
    return Firebase.app().name;
  } catch (_) {
    return '-';
  }
}
