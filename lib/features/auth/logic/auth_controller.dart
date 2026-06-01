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
  var isEmailVerificationRequired = false.obs;
  var emailVerificationInfo = ''.obs;
  var emailVerificationError = ''.obs;
  var verificationEmail = ''.obs;

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
    } on EmailNotVerifiedException catch (e) {
      _enterEmailVerification(e.email);
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

  void _enterEmailVerification(String email) {
    isMfaRequired.value = false;
    isEmailVerificationRequired.value = true;
    verificationEmail.value = email;
    emailVerificationError.value = '';
    emailVerificationInfo.value = email.isEmpty
        ? 'Your email is not verified yet. Open the verification link we sent, '
              'then tap "I have verified".'
        : 'Your email is not verified yet. Open the verification link we sent to '
              '$email, then tap "I have verified".';
  }

  Future<void> resendVerificationEmail() async {
    isLoading.value = true;
    emailVerificationError.value = '';
    try {
      await _authService.resendEmailVerification();
      final email = verificationEmail.value;
      emailVerificationInfo.value = email.isEmpty
          ? 'Verification email sent. Check your inbox and spam folder.'
          : 'Verification email sent to $email. Check your inbox and spam folder.';
    } on ApiException catch (e) {
      emailVerificationError.value = _mapBackendError(e.message);
    } catch (e) {
      emailVerificationError.value = 'Could not send the email: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmEmailVerified() async {
    isLoading.value = true;
    emailVerificationError.value = '';
    var shouldClearLoading = true;
    try {
      final verified = await _authService.retryEmailVerification();
      if (!verified) {
        emailVerificationError.value =
            'Your email is still not verified. Open the link we emailed you and try again.';
        return;
      }
      isEmailVerificationRequired.value = false;
      shouldClearLoading = false;
      await _navigateToHome();
    } on ApiException catch (e) {
      emailVerificationError.value = _mapBackendError(e.message);
    } catch (e, s) {
      emailVerificationError.value = 'Could not verify the session: $e/$s';
    } finally {
      if (shouldClearLoading) {
        isLoading.value = false;
      }
    }
  }

  void cancelEmailVerification() {
    isEmailVerificationRequired.value = false;
    emailVerificationError.value = '';
    emailVerificationInfo.value = '';
    verificationEmail.value = '';
    _authService.cancelEmailVerification();
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
    if (normalized.contains('not verified')) {
      return 'Your email is not verified. Open the verification link we emailed you.';
    }
    if (normalized.contains('not provisioned')) {
      return 'Your account is not set up yet. Please contact support.';
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
