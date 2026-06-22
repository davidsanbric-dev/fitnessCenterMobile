import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/config/startup_policy.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/startup_exception.dart';
import 'package:fitnesscenter_mobile/app/config/app_bindings.dart';
import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/app/core/services/local_notification_service.dart';
import 'package:fitnesscenter_mobile/app/core/services/push_notification_service.dart';

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
    for (final asset in StartupPolicy.criticalAssets) {
      try {
        final isSvg = asset.toLowerCase().endsWith('.svg');
        if (isSvg) {
          await rootBundle
              .loadString(asset)
              .timeout(StartupPolicy.assetPreflightTimeout);
        } else {
          await rootBundle
              .load(asset)
              .timeout(StartupPolicy.assetPreflightTimeout);
        }
      } catch (_) {}
    }
  }

  Future<void> _runStartupStep(
    String name,
    Future<void> Function() action,
  ) async {
    try {
      await action().timeout(StartupPolicy.stepTimeout);
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

class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 48,
                    color: AppTheme.danger,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    StartupException.title,
                    style: AppTheme.startupFailureTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    StartupException.description,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: AppTheme.startupFailureDetail,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
