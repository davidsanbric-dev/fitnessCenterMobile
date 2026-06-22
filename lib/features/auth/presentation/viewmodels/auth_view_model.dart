import 'package:fitnesscenter_mobile/app/config/app_routes.dart';
import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Drives the login screen: credential sign-in and the email-verification
/// gate. Orchestrates the shared [AuthService] (the auth domain lives in
/// `app/core/auth`) and routes via GetX once a session is established.
class AuthViewModel extends ViewModelBase {
  AuthViewModel({AuthService? authService})
    : _authService = authService ?? Get.find<AuthService>() {
    // Mirror the controller's `ever(isLoggedInRx)`: navigate home whenever the
    // session flips to logged-in (e.g. a session restored outside `login`).
    _loginWorker = ever<bool>(_authService.isLoggedInRx, (loggedIn) {
      if (loggedIn) _navigateToHome();
    });
  }

  final AuthService _authService;
  Worker? _loginWorker;

  bool isLoading = false;
  String error = '';
  bool isEmailVerificationRequired = false;
  String emailVerificationInfo = '';
  String emailVerificationError = '';
  String verificationEmail = '';

  Future<void> login({required AuthRequest request}) async {
    isLoading = true;
    error = '';
    notifyListeners();
    var shouldClearLoading = true;
    try {
      await _authService.loginWithEmailAndPassword(
        email: request.mail,
        password: request.password,
      );
      // Leave loading on through the navigation so the form never flashes back
      // to its idle state before the home route takes over.
      shouldClearLoading = false;
      await _navigateToHome();
    } on EmailNotVerifiedException catch (e) {
      _enterEmailVerification(e.email);
    } on ApiException catch (e) {
      error = _mapBackendError(e.message);
    } catch (e, s) {
      error = 'Authentication error: $e/$s';
    } finally {
      if (shouldClearLoading) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void _enterEmailVerification(String email) {
    isEmailVerificationRequired = true;
    verificationEmail = email;
    emailVerificationError = '';
    emailVerificationInfo = email.isEmpty
        ? 'Your email is not verified yet. Open the verification link we sent, '
              'then tap "I have verified".'
        : 'Your email is not verified yet. Open the verification link we sent to '
              '$email, then tap "I have verified".';
  }

  Future<void> resendVerificationEmail() async {
    isLoading = true;
    emailVerificationError = '';
    notifyListeners();
    try {
      await _authService.resendEmailVerification();
      final email = verificationEmail;
      emailVerificationInfo = email.isEmpty
          ? 'Verification email sent. Check your inbox and spam folder.'
          : 'Verification email sent to $email. Check your inbox and spam folder.';
    } on ApiException catch (e) {
      emailVerificationError = _mapBackendError(e.message);
    } catch (e) {
      emailVerificationError = 'Could not send the email: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmEmailVerified() async {
    isLoading = true;
    emailVerificationError = '';
    notifyListeners();
    var shouldClearLoading = true;
    try {
      final verified = await _authService.retryEmailVerification();
      if (!verified) {
        emailVerificationError =
            'Your email is still not verified. Open the link we emailed you and try again.';
        return;
      }
      isEmailVerificationRequired = false;
      shouldClearLoading = false;
      await _navigateToHome();
    } on ApiException catch (e) {
      emailVerificationError = _mapBackendError(e.message);
    } catch (e, s) {
      emailVerificationError = 'Could not verify the session: $e/$s';
    } finally {
      if (shouldClearLoading) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void cancelEmailVerification() {
    isEmailVerificationRequired = false;
    emailVerificationError = '';
    emailVerificationInfo = '';
    verificationEmail = '';
    _authService.cancelEmailVerification();
    notifyListeners();
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

  @override
  void dispose() {
    _loginWorker?.dispose();
    super.dispose();
  }
}
