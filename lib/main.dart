import 'dart:async';

// import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:portfolio_mobile_app/app/config/config.dart';
import 'package:portfolio_mobile_app/app/core/constants/app_assets.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/diagnostics/runtime_diagnostics.dart';
import 'package:portfolio_mobile_app/app/core/services/deep_link_service.dart';
import 'package:portfolio_mobile_app/app/core/services/local_notification_service.dart';
import 'package:portfolio_mobile_app/app/core/services/push_notification_service.dart';
import 'package:portfolio_mobile_app/app/main_app.dart';
import 'package:portfolio_mobile_app/firebase_options.dart';

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late final Future<void> _bootstrapFuture = _initializeCriticalStartup();
  bool _startupDispatched = false;

  Future<void> _initializeCriticalStartup() async {
    RuntimeDiagnostics.breadcrumb('bootstrap-start');
    final firebaseReady = await _ensureFirebaseReady();
    if (!firebaseReady) {
      RuntimeDiagnostics.resourceWarning(
        'startup-degraded',
        data: 'firebase-ready=false',
      );
    }
    // _logEffectiveBaseUrl();
    RuntimeDiagnostics.breadcrumb('bootstrap-critical-ready');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          RuntimeDiagnostics.breadcrumb(
            'bootstrap-failure',
            data: 'error=${snapshot.error}',
          );
          return StartupFailureApp(error: snapshot.error!);
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (!_startupDispatched) {
          _startupDispatched = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            RuntimeDiagnostics.breadcrumb('startup-dispatch');
            unawaited(_startApp());
          });
        }

        return const MainApp();
      },
    );
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
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Startup failed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The app could not finish startup configuration.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
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

// void _logEffectiveBaseUrl() {
//   try {
//     debugPrint('[APP] effective BASE_URL=${AppStrings.baseUrl}');
//     RuntimeDiagnostics.breadcrumb(
//       'base-url',
//       data: 'value=${AppStrings.baseUrl}',
//     );
//   } catch (error) {
//     debugPrint('[APP] BASE_URL resolution failed: $error');
//     RuntimeDiagnostics.breadcrumb('base-url-error', data: 'error=$error');
//   }
// }

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.handleBackgroundMessage(message);
}

Future<void> _startApp() async {
  RuntimeDiagnostics.breadcrumb('start-app-begin');
  unawaited(_runStartupAssetPreflight());
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

  if (Firebase.apps.isEmpty) {
    RuntimeDiagnostics.resourceWarning(
      'push-init-skipped',
      data: 'firebase-not-ready',
    );
  } else {
    final pushService = Get.isRegistered<PushNotificationService>()
        ? Get.find<PushNotificationService>()
        : Get.put(
            PushNotificationService(
              localNotificationService: localNotifications,
            ),
          );
    await _runStartupStep('PushNotificationService.init', pushService.init);
  }

  final deepLinkService = Get.isRegistered<DeepLinkService>()
      ? Get.find<DeepLinkService>()
      : Get.put(DeepLinkService());
  await _runStartupStep('DeepLinkService.init', deepLinkService.init);
  RuntimeDiagnostics.breadcrumb('start-app-end');
}

Future<void> _runStartupAssetPreflight() async {
  const criticalAssets = <String>[
    AppAssets.logo,
    'assets/info_slider_image.png',
  ];
  const timeout = Duration(seconds: 2);

  RuntimeDiagnostics.breadcrumb(
    'startup-assets-preflight-start',
    data: 'count=${criticalAssets.length}',
  );

  for (final asset in criticalAssets) {
    try {
      final isSvg = asset.toLowerCase().endsWith('.svg');
      if (isSvg) {
        await rootBundle.loadString(asset).timeout(timeout);
      } else {
        await rootBundle.load(asset).timeout(timeout);
      }
      RuntimeDiagnostics.breadcrumb('startup-asset-ok', data: 'path=$asset');
    } catch (error) {
      RuntimeDiagnostics.missingAsset(
        asset,
        scope: 'startup-preflight',
        error: error,
      );
    }
  }

  RuntimeDiagnostics.breadcrumb('startup-assets-preflight-end');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RuntimeDiagnostics.installGlobalHandlers();
  RuntimeDiagnostics.breadcrumb('main-runapp');

  runApp(
    // kEnableDevicePreview
    //     ? DevicePreview(
    //         builder: (context) => const ProviderScope(child: BootstrapApp()),
    //       )
    //     :
    const ProviderScope(child: BootstrapApp()),
  );
}

Future<bool> _ensureFirebaseReady() async {
  const timeout = Duration(seconds: 8);
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(timeout);
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    RuntimeDiagnostics.breadcrumb('firebase-ready');
    return true;
  } on TimeoutException catch (error, stackTrace) {
    RuntimeDiagnostics.breadcrumb(
      'firebase-init-timeout',
      data: 'error=$error timeoutMs=${timeout.inMilliseconds}',
    );
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'main.dart',
        context: ErrorDescription('while initializing Firebase during startup'),
      ),
    );
    return false;
  } catch (error, stackTrace) {
    RuntimeDiagnostics.breadcrumb('firebase-init-error', data: 'error=$error');
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'main.dart',
        context: ErrorDescription(
          'while preparing Firebase dependencies during startup',
        ),
      ),
    );
    return false;
  }
}

Future<void> _runStartupStep(
  String name,
  Future<void> Function() action,
) async {
  const timeout = Duration(seconds: 8);
  try {
    RuntimeDiagnostics.breadcrumb('startup-step-start', data: 'name=$name');
    await action().timeout(timeout);
    RuntimeDiagnostics.breadcrumb('startup-step-ok', data: 'name=$name');
  } on TimeoutException catch (error) {
    RuntimeDiagnostics.resourceWarning(
      'startup-step-timeout',
      data: 'name=$name timeoutMs=${timeout.inMilliseconds} error=$error',
    );
  } catch (error, stackTrace) {
    RuntimeDiagnostics.breadcrumb(
      'startup-step-error',
      data: 'name=$name error=$error',
    );
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'main.dart',
        context: ErrorDescription('during startup step: $name'),
      ),
    );
  }
}
