import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:portfolio_mobile_app/app/core/constants/app_assets.dart';
import 'package:portfolio_mobile_app/app/config/app_bindings.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/services/local_notification_service.dart';
import 'package:portfolio_mobile_app/app/core/services/push_notification_service.dart';

class StartupManager {
  const StartupManager();

  Future<void> run() async {
    unawaited(_runAssetPreflight());
    AppBindings.ensureAuthDependencies();

    final authService = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>()
        : Get.put(
            AuthService(
              authApi: Get.find<AuthApi>(),
              cache: Get.find<AuthSessionCache>(),
            ),
          );
    await _runStartupStep('AuthService.init', authService.init);

    final localNotifications = Get.isRegistered<LocalNotificationService>()
        ? Get.find<LocalNotificationService>()
        : Get.put(LocalNotificationService());
    await _runStartupStep(
      'LocalNotificationService.init',
      localNotifications.init,
    );

    if (Firebase.apps.isNotEmpty) {
      final pushService = Get.isRegistered<PushNotificationService>()
          ? Get.find<PushNotificationService>()
          : Get.put(
              PushNotificationService(
                localNotificationService: localNotifications,
              ),
            );
      await _runStartupStep('PushNotificationService.init', pushService.init);
    }
  }

  Future<void> _runAssetPreflight() async {
    const criticalAssets = <String>[
      AppAssets.logo,
    ];
    const timeout = Duration(seconds: 2);

    for (final asset in criticalAssets) {
      try {
        final isSvg = asset.toLowerCase().endsWith('.svg');
        if (isSvg) {
          await rootBundle.loadString(asset).timeout(timeout);
        } else {
          await rootBundle.load(asset).timeout(timeout);
        }
      } catch (_) {}
    }
  }

  Future<void> _runStartupStep(
    String name,
    Future<void> Function() action,
  ) async {
    const timeout = Duration(seconds: 8);
    try {
      await action().timeout(timeout);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'startup_manager.dart',
          context: ErrorDescription('during startup step: $name'),
        ),
      );
    }
  }
}
