import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portfolio_mobile_app/app/config/app_routes.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/features/password_recovery/presentation/widgets/email_asking_form.dart';
import 'package:portfolio_mobile_app/features/password_recovery/presentation/widgets/password_reset_email_sent_message.dart';
import 'package:portfolio_mobile_app/features/password_recovery/presentation/widgets/password_reset_form.dart';
import 'package:portfolio_mobile_app/features/password_recovery/presentation/widgets/password_reset_success_message.dart';

enum _PasswordRecoveryStep {
  email,
  emailSent,
  verifyingLink,
  resetPassword,
  invalidLink,
  success,
}

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key, this.oobCode});

  final String? oobCode;

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  static const Duration _switchDuration = Duration(milliseconds: 250);
  static const int _totalSteps = 3;

  final AuthApi _authApi = Get.find<AuthApi>();

  _PasswordRecoveryStep _step = _PasswordRecoveryStep.email;
  String _email = '';
  String? _oobCode;
  String? _verifiedEmail;
  String? _linkError;

  bool _isSendingEmail = false;
  bool _isVerifyingLink = false;
  bool _isResettingPassword = false;

  bool get _fromDeepLink => (widget.oobCode ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_fromDeepLink) {
      _oobCode = widget.oobCode?.trim();
      _verifyResetLink();
    }
  }

  void _handleBack() {
    switch (_step) {
      case _PasswordRecoveryStep.email:
        Navigator.of(context).maybePop();
        return;
      case _PasswordRecoveryStep.emailSent:
        setState(() => _step = _PasswordRecoveryStep.email);
        return;
      case _PasswordRecoveryStep.verifyingLink:
        Navigator.of(context).maybePop();
        return;
      case _PasswordRecoveryStep.resetPassword:
        if (_fromDeepLink) {
          Navigator.of(context).maybePop();
          return;
        }
        setState(() => _step = _PasswordRecoveryStep.emailSent);
        return;
      case _PasswordRecoveryStep.invalidLink:
        setState(() => _step = _PasswordRecoveryStep.email);
        return;
      case _PasswordRecoveryStep.success:
        Navigator.of(context).maybePop();
        return;
    }
  }

  Future<void> _handleEmailContinue(String email) async {
    if (_isSendingEmail) return;
    setState(() {
      _email = email;
      _isSendingEmail = true;
    });

    try {
      await _authApi.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: _buildActionCodeSettings(),
      );
      if (!mounted) return;
      setState(() => _step = _PasswordRecoveryStep.emailSent);
    } on ApiException catch (error) {
      Get.snackbar('Could not send', error.message);
    } catch (error) {
      Get.snackbar('Unexpected error', 'Could not send the link: $error');
    } finally {
      if (mounted) {
        setState(() => _isSendingEmail = false);
      }
    }
  }

  Future<void> _handleResend() async {
    if (_email.trim().isEmpty) {
      setState(() => _step = _PasswordRecoveryStep.email);
      return;
    }
    await _handleEmailContinue(_email.trim());
  }

  Future<void> _verifyResetLink() async {
    final code = _oobCode?.trim();
    if (code == null || code.isEmpty) {
      setState(() {
        _linkError = 'Invalid password reset link.';
        _step = _PasswordRecoveryStep.invalidLink;
      });
      return;
    }

    setState(() {
      _isVerifyingLink = true;
      _linkError = null;
      _step = _PasswordRecoveryStep.verifyingLink;
    });

    try {
      final email = await _authApi.verifyPasswordResetCode(code: code);
      if (!mounted) return;
      setState(() {
        _verifiedEmail = email;
        _step = _PasswordRecoveryStep.resetPassword;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _linkError = error.message;
        _step = _PasswordRecoveryStep.invalidLink;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _linkError = 'Internal error: $error';
        _step = _PasswordRecoveryStep.invalidLink;
      });
    } finally {
      if (mounted) {
        setState(() => _isVerifyingLink = false);
      }
    }
  }

  Future<void> _handlePasswordUpdated(String newPassword) async {
    if (_isResettingPassword) return;
    final code = _oobCode?.trim();
    if (code == null || code.isEmpty) {
      Get.snackbar('Invalid link', 'Request a new reset to continue.');
      return;
    }

    setState(() => _isResettingPassword = true);
    try {
      await _authApi.confirmPasswordReset(code: code, newPassword: newPassword);
      if (!mounted) return;
      setState(() => _step = _PasswordRecoveryStep.success);
    } on ApiException catch (error) {
      Get.snackbar('Could not update', error.message);
    } catch (error) {
      Get.snackbar('Unexpected error', 'Could not update: $error');
    } finally {
      if (mounted) {
        setState(() => _isResettingPassword = false);
      }
    }
  }

  void _handleFinish() {
    Get.offAllNamed(AppRoutes.login);
  }

  int _currentStepIndex() {
    switch (_step) {
      case _PasswordRecoveryStep.email:
      case _PasswordRecoveryStep.emailSent:
        return 1;
      case _PasswordRecoveryStep.verifyingLink:
      case _PasswordRecoveryStep.resetPassword:
      case _PasswordRecoveryStep.invalidLink:
        return 2;
      case _PasswordRecoveryStep.success:
        return 3;
    }
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case _PasswordRecoveryStep.email:
        return EmailAskingForm(
          initialEmail: _email,
          onBack: _handleBack,
          onContinue: _handleEmailContinue,
          isLoading: _isSendingEmail,
        );
      case _PasswordRecoveryStep.emailSent:
        return PasswordResetEmailSentMessage(
          email: _email,
          onBack: _handleBack,
          onResend: _handleResend,
          isLoading: _isSendingEmail,
        );
      case _PasswordRecoveryStep.verifyingLink:
        return _VerifyingLinkMessage(
          onBack: _handleBack,
          email: _verifiedEmail,
          isLoading: _isVerifyingLink,
        );
      case _PasswordRecoveryStep.resetPassword:
        return PasswordResetForm(
          onBack: _handleBack,
          onContinue: _handlePasswordUpdated,
          isLoading: _isResettingPassword,
        );
      case _PasswordRecoveryStep.invalidLink:
        return _InvalidLinkMessage(
          message: _linkError,
          onBack: _handleBack,
          onResend: () {
            setState(() => _step = _PasswordRecoveryStep.email);
          },
        );
      case _PasswordRecoveryStep.success:
        return PasswordResetSuccessMessage(onContinue: _handleFinish);
    }
  }

  ActionCodeSettings? _buildActionCodeSettings() {
    const continueUrl = String.fromEnvironment('PASSWORD_RESET_CONTINUE_URL');
    if (continueUrl.isEmpty) {
      return null;
    }

    const androidPackage = String.fromEnvironment('ANDROID_PACKAGE_NAME');
    const androidMinVersion = String.fromEnvironment('ANDROID_MIN_VERSION');
    const iosBundleId = String.fromEnvironment('IOS_BUNDLE_ID');
    const linkDomain = String.fromEnvironment('FIREBASE_DYNAMIC_LINK_DOMAIN');
    final bool hasAndroidPackage = androidPackage.isNotEmpty;

    return ActionCodeSettings(
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
    final int currentStep = _currentStepIndex();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step $currentStep of $_totalSteps',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.brandBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Recover password',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: _switchDuration,
                    child: SizedBox(
                      key: ValueKey(_step),
                      child: _buildCurrentStep(),
                    ),
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

class _VerifyingLinkMessage extends StatelessWidget {
  const _VerifyingLinkMessage({
    required this.onBack,
    required this.isLoading,
    this.email,
  });

  final VoidCallback onBack;
  final bool isLoading;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: AppTheme.brandTextButtonStyle(),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Validating reset link...',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (email != null && email!.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            email!.trim(),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
        ],
        if (!isLoading) const SizedBox(height: 12),
      ],
    );
  }
}

class _InvalidLinkMessage extends StatelessWidget {
  const _InvalidLinkMessage({
    required this.onBack,
    required this.onResend,
    this.message,
  });

  final VoidCallback onBack;
  final VoidCallback onResend;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final String errorMessage = message?.trim().isNotEmpty ?? false
        ? message!.trim()
        : 'The link is invalid or has expired.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: AppTheme.brandTextButtonStyle(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Could not validate the link',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: onResend,
            style: AppTheme.dialogPrimaryButtonStyle(),
            child: const Text('Request new link'),
          ),
        ),
      ],
    );
  }
}
