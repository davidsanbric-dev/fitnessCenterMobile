import 'dart:async';

import 'package:portfolio_mobile_app/app/config/app_routes.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/diagnostics/runtime_diagnostics.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_mfa_debug_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AuthController extends GetxController with WidgetsBindingObserver {
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = false.obs;
  var error = ''.obs;
  var isMfaRequired = false.obs;
  var mfaError = ''.obs;
  var mfaInfo = ''.obs;

  static const Duration _mfaControllerTimeout = Duration(seconds: 95);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _debugAuth(
      'controller-init',
      message:
          'lifecycle=${WidgetsBinding.instance.lifecycleState?.name ?? '-'}',
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _debugAuth('controller-close');
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _debugAuth('lifecycle', message: state.name);
  }

  Future<void> login({required AuthRequest request}) async {
    RuntimeDiagnostics.breadcrumb('auth-login-enter');
    isLoading.value = true;
    error.value = '';
    mfaError.value = '';
    try {
      _debugAuth('login-start');
      final mfaRequired = await _authService.loginWithEmailAndPassword(
        email: request.mail,
        password: request.password,
      );
      if (mfaRequired) {
        _debugAuth('login-mfa-required');
        isMfaRequired.value = true;
        mfaInfo.value = _buildMfaInfo(_authService.mfaPhoneNumber);
        await _sendMfaCode();
        return;
      }
      _debugAuth('login-success');
      RuntimeDiagnostics.breadcrumb('auth-login-success');
      isMfaRequired.value = false;
      await _navigateToHome();
    } on ApiException catch (e) {
      _debugAuth('login-api-error', message: e.message);
      error.value = _mapBackendError(e.message);
    } catch (e, s) {
      _debugAuth('login-unexpected-error', message: '$e/$s');
      error.value = 'Authentication error: $e/$s';
    } finally {
      isLoading.value = false;
      RuntimeDiagnostics.breadcrumb('auth-login-exit');
    }
  }

  Future<void> resendMfaCode() async {
    await _sendMfaCode(resend: true);
  }

  Future<void> verifyMfaCode(String smsCode) async {
    final trimmed = smsCode.trim();
    if (trimmed.isEmpty) {
      mfaError.value = 'Enter the SMS code.';
      return;
    }
    isLoading.value = true;
    mfaError.value = '';
    try {
      _debugAuth('mfa-verify-start');
      await _authService.confirmMfaSignIn(smsCode: trimmed);
      _debugAuth('mfa-verify-success');
      isMfaRequired.value = false;
      await _navigateToHome();
    } on ApiException catch (e) {
      _debugAuth('mfa-verify-api-error', message: e.message);
      mfaError.value = _mapBackendError(e.message);
    } catch (e, s) {
      _debugAuth('mfa-verify-unexpected-error', message: '$e/$s');
      mfaError.value = 'Error validating MFA: $e/$s';
    } finally {
      isLoading.value = false;
    }
  }

  void cancelMfa() {
    isMfaRequired.value = false;
    mfaError.value = '';
    mfaInfo.value = '';
    _authService.cancelMfaSignIn();
  }

  String _mapBackendError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('user not exist') ||
        normalized.contains('password must be correct') ||
        normalized.contains('credenciales') ||
        normalized.contains('incorrecto')) {
      return 'Incorrect email or password.';
    }
    if (normalized.contains('token')) {
      return 'Could not validate the session. Please try again.';
    }
    return message;
  }

  Future<void> _sendMfaCode({bool resend = false}) async {
    isLoading.value = true;
    mfaError.value = '';
    try {
      _debugAuth('mfa-send-start', message: 'resend=$resend');
      final delivery = await _authService
          .sendMfaSignInCode(resend: resend)
          .timeout(
            _mfaControllerTimeout,
            onTimeout: () => throw const ApiException(
              'Could not complete SMS delivery. Please try again.',
            ),
          );
      _debugAuth(
        'mfa-send-result',
        message:
            'confirmed=${delivery.isCodeSentConfirmed} resendToken=${delivery.resendToken ?? '-'}',
      );
      if (delivery.isCodeSentConfirmed) {
        mfaInfo.value = _buildMfaInfo(_authService.mfaPhoneNumber);
      } else {
        mfaInfo.value =
            '${_buildMfaInfo(_authService.mfaPhoneNumber)} '
            'If you do not receive the SMS in 60 seconds, use Resend code.';
      }
    } on ApiException catch (e) {
      _debugAuth('mfa-send-api-error', message: e.message);
      mfaError.value = _mapBackendError(e.message);
    } catch (e, s) {
      _debugAuth('mfa-send-unexpected-error', message: '$e/$s');
      mfaError.value = 'Error sending SMS: $e/$s';
    } finally {
      isLoading.value = false;
    }
  }

  String _buildMfaInfo(String? phoneNumber) {
    final number = phoneNumber?.trim();
    if (number == null || number.isEmpty) {
      return 'Enter the SMS code sent to your phone.';
    }
    final digits = number.replaceAll(RegExp(r'\\D'), '');
    if (digits.length < 4) {
      return 'Enter the SMS code sent to $number.';
    }
    final last4 = digits.substring(digits.length - 4);
    return 'Enter the SMS code sent to the number ending in $last4.';
  }

  void _debugAuth(String event, {String? message}) {
    AuthMfaDebugLog.recordEvent(
      scope: 'AUTH',
      event: event,
      fields: <String, Object?>{
        'message': message ?? '-',
        'platform': defaultTargetPlatform.name,
      },
    );
  }

  Future<void> _navigateToHome() async {
    FocusManager.instance.primaryFocus?.unfocus();
    RuntimeDiagnostics.breadcrumb(
      'auth-navigate-home-enter',
      data: 'route=${Get.currentRoute}',
    );
    if (Get.currentRoute == AppRoutes.home ||
        Get.currentRoute == AppRoutes.postLogin) {
      RuntimeDiagnostics.breadcrumb('auth-navigate-home-skip');
      return;
    }

    _debugAuth('navigate-home-start', message: 'from=${Get.currentRoute}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != AppRoutes.postLogin &&
          Get.currentRoute != AppRoutes.home) {
        RuntimeDiagnostics.breadcrumb(
          'auth-navigate-home-dispatch',
          data: 'route=${Get.currentRoute}',
        );
        Get.offAllNamed(AppRoutes.postLogin);
      }
    });
  }
}
