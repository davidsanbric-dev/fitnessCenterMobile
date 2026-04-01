import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_bloc.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/security_verification_box.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/third_step_form.dart';
import 'package:get/get.dart';

class ThirdStepPage extends StatefulWidget {
  const ThirdStepPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<ThirdStepPage> createState() => _ThirdStepPageState();
}

class _ThirdStepPageState extends State<ThirdStepPage> {
  final EnsureRegisterEmailSessionUseCase _ensureRegisterEmailSessionUseCase =
      Get.find<EnsureRegisterEmailSessionUseCase>();
  final AuthService _authService = Get.find<AuthService>();

  bool _showVerification = false;
  bool _isSendingVerificationLink = false;
  bool _hasSentVerificationLink = false;

  Future<void> _handleContinue() async {
    if (_showVerification) {
      return;
    }
    setState(() => _showVerification = true);
    if (!_hasSentVerificationLink) {
      await _sendVerificationLink();
    }
  }

  void _handleBack() {
    if (_showVerification) {
      setState(() => _showVerification = false);
      return;
    }
    widget.onBack?.call();
  }

  Future<void> _sendVerificationLink() async {
    if (_isSendingVerificationLink) {
      return;
    }

    setState(() => _isSendingVerificationLink = true);
    try {
      final registerEmail = context.read<RegisterBloc>().state.email.trim();
      await _ensureRegisterEmailSessionUseCase(email: registerEmail);
      await _authService.sendEmailVerification(
        actionCodeSettings: _buildActionCodeSettings(),
      );
      if (!mounted) {
        return;
      }
      setState(() => _hasSentVerificationLink = true);
      Get.snackbar(
        'Link sent',
        'Check your email and open the verification link.',
      );
    } on ApiException catch (error) {
      Get.snackbar('Could not send', error.message);
    } catch (error) {
      Get.snackbar('Unexpected error', 'Could not send the link: $error');
    } finally {
      if (mounted) {
        setState(() => _isSendingVerificationLink = false);
      }
    }
  }

  AuthActionCodeSettings? _buildActionCodeSettings() {
    const registerContinueUrl = String.fromEnvironment(
      'REGISTER_EMAIL_VERIFICATION_CONTINUE_URL',
    );
    const passwordResetContinueUrl = String.fromEnvironment(
      'PASSWORD_RESET_CONTINUE_URL',
    );
    final continueUrl = registerContinueUrl.isNotEmpty
        ? registerContinueUrl
        : passwordResetContinueUrl;
    if (continueUrl.isEmpty) {
      return null;
    }

    const androidPackage = String.fromEnvironment('ANDROID_PACKAGE_NAME');
    const androidMinVersion = String.fromEnvironment('ANDROID_MIN_VERSION');
    const iosBundleId = String.fromEnvironment('IOS_BUNDLE_ID');
    const linkDomain = String.fromEnvironment('FIREBASE_DYNAMIC_LINK_DOMAIN');
    final hasAndroidPackage = androidPackage.isNotEmpty;

    return AuthActionCodeSettings(
      url: continueUrl,
      handleCodeInApp: true,
      androidPackageName: hasAndroidPackage ? androidPackage : null,
      androidInstallApp: hasAndroidPackage,
      androidMinimumVersion: hasAndroidPackage && androidMinVersion.isNotEmpty
          ? androidMinVersion
          : null,
      iOSBundleId: iosBundleId.isEmpty ? null : iosBundleId,
      linkDomain: linkDomain.isEmpty ? null : linkDomain,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showVerification) {
      return SecurityVerificationBox(
        onBack: _handleBack,
        onResend: _sendVerificationLink,
        isLoading: _isSendingVerificationLink,
        hasSentLink: _hasSentVerificationLink,
      );
    }

    return ThirdStepForm(onContinue: _handleContinue, onBack: _handleBack);
  }
}
