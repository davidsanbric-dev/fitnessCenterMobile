import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:fitnesscenter_mobile/app/config/config.dart';
import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Spanish is the product language: the gyms and members this serves are
      // Spanish-speaking. English stays available as a fallback rather than as
      // the default.
      locale: kEnableDevicePreview
          ? DevicePreview.locale(context)
          : const Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: kEnableDevicePreview ? DevicePreview.appBuilder : null,
      title: 'FitnessCenter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialBinding: BindingsBuilder(() {
        AppBindings.ensureAuthDependencies();
        if (!Get.isRegistered<AuthService>()) {
          Get.put(
            AuthService(
              authApi: Get.find<AuthApi>(),
              cache: Get.find<AuthSessionCache>(),
            ),
          );
        }
      }),
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
    );
  }
}
