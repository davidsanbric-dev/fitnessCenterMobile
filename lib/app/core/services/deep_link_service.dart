import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/config/app_routes.dart';
import 'package:portfolio_mobile_app/app/core/services/register_email_verification_service.dart';

class DeepLinkService extends GetxService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _subscription;
  bool _initialized = false;

  Future<DeepLinkService> init() async {
    if (_initialized) return this;
    _initialized = true;

    if (kIsWeb) return this;

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (_) {}

    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleUri(uri);
      },
      onError: (_) {},
    );

    return this;
  }

  void _handleUri(Uri uri) {
    final params = _extractActionParams(uri);
    if (params == null) return;

    final mode = params['mode'] as String;
    final oobCode = params['oobCode'] as String;

    if (mode == 'verifyEmail') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute == AppRoutes.register) {
          final registerEmailVerificationService =
              Get.find<RegisterEmailVerificationService>();
          registerEmailVerificationService.pushCode(oobCode);
          return;
        }
        Get.toNamed(AppRoutes.register, arguments: {'oobCode': oobCode});
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute == AppRoutes.passwordRecovery) {
        Get.offNamed(
          AppRoutes.passwordRecovery,
          arguments: {'oobCode': oobCode},
        );
        return;
      }
      Get.toNamed(AppRoutes.passwordRecovery, arguments: {'oobCode': oobCode});
    });
  }

  Map<String, dynamic>? _extractActionParams(Uri uri) {
    Uri candidate = uri;
    final deepLink = uri.queryParameters['link'];
    if (deepLink != null && deepLink.isNotEmpty) {
      final parsed = Uri.tryParse(deepLink);
      if (parsed != null) {
        candidate = parsed;
      }
    }

    final mode = candidate.queryParameters['mode'];
    if (mode != 'resetPassword' && mode != 'verifyEmail') return null;

    final oobCode = candidate.queryParameters['oobCode'];
    if (oobCode == null || oobCode.trim().isEmpty) return null;

    return {'mode': mode, 'oobCode': oobCode.trim()};
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
