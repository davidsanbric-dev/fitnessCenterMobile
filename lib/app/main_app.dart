import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/config/config.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: kEnableDevicePreview ? DevicePreview.locale(context) : null,
      builder: kEnableDevicePreview ? DevicePreview.appBuilder : null,
      title: 'FitnessCenter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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
