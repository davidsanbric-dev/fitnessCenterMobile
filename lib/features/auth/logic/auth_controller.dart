import 'dart:async';

import 'package:portfolio_mobile_app/app/config/app_routes.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:flutter/material.dart';
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
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  Future<void> login({required AuthRequest request}) async {
    isLoading.value = true;
    error.value = '';
    mfaError.value = '';
    var shouldClearLoading = true;
    try {
      final mfaRequired = await _authService.loginWithEmailAndPassword(
        email: request.mail,
        password: request.password,
      );
      if (mfaRequired) {
        isMfaRequired.value = true;
        mfaInfo.value = _buildMfaInfo(_authService.mfaPhoneNumber);
        await _sendMfaCode();
        return;
      }
      isMfaRequired.value = false;
      shouldClearLoading = false;
      await _navigateToHome();
    } on ApiException catch (e) {
      error.value = _mapBackendError(e.message);
    } catch (e, s) {
      error.value = 'Authentication error: $e/$s';
    } finally {
      if (shouldClearLoading) {
        isLoading.value = false;
      }
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
    var shouldClearLoading = true;
    try {
      await _authService.confirmMfaSignIn(smsCode: trimmed);
      isMfaRequired.value = false;
      shouldClearLoading = false;
      await _navigateToHome();
    } on ApiException catch (e) {
      mfaError.value = _mapBackendError(e.message);
    } catch (e, s) {
      mfaError.value = 'Error validating MFA: $e/$s';
    } finally {
      if (shouldClearLoading) {
        isLoading.value = false;
      }
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
      final delivery = await _authService
          .sendMfaSignInCode(resend: resend)
          .timeout(
            _mfaControllerTimeout,
            onTimeout: () => throw const ApiException(
              'Could not complete SMS delivery. Please try again.',
            ),
          );
      if (delivery.isCodeSentConfirmed) {
        mfaInfo.value = _buildMfaInfo(_authService.mfaPhoneNumber);
      } else {
        mfaInfo.value =
            '${_buildMfaInfo(_authService.mfaPhoneNumber)} '
            'If you do not receive the SMS in 60 seconds, use Resend code.';
      }
    } on ApiException catch (e) {
      mfaError.value = _mapBackendError(e.message);
    } catch (e, s) {
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

  Future<void> _navigateToHome() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (Get.currentRoute == AppRoutes.home ||
        Get.currentRoute == AppRoutes.postLogin) {
      return;
    }

    await Get.offAllNamed(AppRoutes.postLogin);
  }
}
