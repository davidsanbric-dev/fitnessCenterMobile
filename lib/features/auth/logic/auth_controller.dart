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
  var isEmailVerificationRequired = false.obs;
  var emailVerificationInfo = ''.obs;
  var emailVerificationError = ''.obs;
  var verificationEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    ever(_authService.isLoggedInRx, (bool loggedIn) {
      if (loggedIn) _navigateToHome();
    });
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
    var shouldClearLoading = true;
    try {
      await _authService.loginWithEmailAndPassword(
        email: request.mail,
        password: request.password,
      );
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

  Future<void> _navigateToHome() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (Get.currentRoute == AppRoutes.home ||
        Get.currentRoute == AppRoutes.postLogin) {
      return;
    }

    await Get.offAllNamed(AppRoutes.postLogin);
  }
}
