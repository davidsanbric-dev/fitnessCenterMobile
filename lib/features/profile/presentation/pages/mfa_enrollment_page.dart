import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/auth/infrastructure/auth_mfa_debug_log.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/input.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/buttons/login_submit_button.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/inline_error_text.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class MfaEnrollmentPage extends StatelessWidget {
  const MfaEnrollmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: MfaEnrollmentView(),
    );
  }
}

class MfaEnrollmentView extends StatefulWidget {
  const MfaEnrollmentView({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<MfaEnrollmentView> createState() => _MfaEnrollmentViewState();
}

class _MfaEnrollmentViewState extends State<MfaEnrollmentView> {
  final AuthService _authService = Get.find<AuthService>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final Set<String> _removing = {};

  List<AuthEnrolledPhoneFactor> _factors = [];
  bool _isLoadingFactors = true;
  bool _isCheckingEmail = true;
  bool _isEmailVerified = false;
  bool _isSendingCode = false;
  bool _isConfirming = false;
  String? _verificationId;
  int? _resendToken;
  String? _error;

  bool get _hasPendingVerification {
    final verificationId = _verificationId;
    return verificationId != null && verificationId.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _isEmailVerified = _authService.isEmailVerified;
    _refreshEmailVerification();
    _loadFactors();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _refreshEmailVerification() async {
    setState(() {
      _isCheckingEmail = true;
      _error = null;
    });
    try {
      final isVerified = await _authService.reloadAndCheckEmailVerified();
      if (!mounted) return;
      setState(() {
        _isEmailVerified = isVerified;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _mapError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
        });
      }
    }
  }

  Future<void> _sendEmailVerification() async {
    setState(() {
      _error = null;
    });
    try {
      await _authService.sendEmailVerification();
      _showSnack('We sent you a verification email.');
    } catch (error) {
      setState(() {
        _error = _mapError(error);
      });
    }
  }

  Future<void> _loadFactors() async {
    setState(() {
      _isLoadingFactors = true;
      _error = null;
    });
    try {
      final factors = await _authService.getEnrolledPhoneFactors();
      if (!mounted) return;
      setState(() {
        _factors = factors;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _mapError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFactors = false;
        });
      }
    }
  }

  Future<void> _sendCode({bool resend = false}) async {
    if (_isCheckingEmail || !_isEmailVerified) {
      setState(() {
        _error = 'Verify your email before enabling SMS.';
      });
      return;
    }
    if (!(_phoneFormKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSendingCode = true;
      _error = null;
    });

    try {
      _debugMfaUi('send-code-start', message: 'resend=$resend');
      final delivery = await _authService.sendMfaEnrollmentCode(
        phoneNumber: _phoneController.text.trim(),
        forceResendingToken: resend ? _resendToken : null,
      );
      if (!mounted) return;
      setState(() {
        _verificationId = delivery.verificationId;
        _resendToken = delivery.resendToken;
      });
      _debugMfaUi(
        'send-code-result',
        message:
            'confirmed=${delivery.isCodeSentConfirmed} resendToken=${delivery.resendToken ?? '-'}',
      );
      if (delivery.isCodeSentConfirmed) {
        _showSnack('SMS code sent.');
      } else {
        _showSnack(
          'Request sent. If you do not receive the SMS in 60 seconds, tap Resend.',
        );
      }
    } catch (error) {
      _debugMfaUi('send-code-error', message: '$error');
      if (!mounted) return;
      setState(() {
        _error = _mapError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  Future<void> _confirmEnrollment() async {
    if (_isCheckingEmail || !_isEmailVerified) {
      setState(() {
        _error = 'Verify your email before enabling SMS.';
      });
      return;
    }
    if (!(_codeFormKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isConfirming = true;
      _error = null;
    });

    try {
      _debugMfaUi('confirm-enrollment-start');
      final verificationId = _verificationId;
      if (verificationId == null || verificationId.isEmpty) {
        throw const ApiException('Request the SMS code first.');
      }
      await _authService.enrollPhoneFactor(
        verificationId: verificationId,
        smsCode: _codeController.text.trim(),
        displayName: _buildDisplayName(_phoneController.text),
      );
      _debugMfaUi('confirm-enrollment-success');
      _showSnack('SMS verification enabled successfully.');
      _codeController.clear();
      if (!mounted) return;
      setState(() {
        _verificationId = null;
        _resendToken = null;
      });
      await _loadFactors();
    } catch (error) {
      _debugMfaUi('confirm-enrollment-error', message: '$error');
      if (!mounted) return;
      setState(() {
        _error = _mapError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  Future<void> _removeFactor(AuthEnrolledPhoneFactor factor) async {
    final confirmed = await _confirmRemoval(factor);
    if (!confirmed) return;

    final uid = factor.uid;
    setState(() {
      _removing.add(uid);
      _error = null;
    });
    try {
      await _authService.unenrollPhoneFactor(factorUid: factor.uid);
      _showSnack('SMS verification removed.');
      await _loadFactors();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _mapError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _removing.remove(uid);
        });
      }
    }
  }

  Future<bool> _confirmRemoval(AuthEnrolledPhoneFactor factor) async {
    final label = maskPhone(factor.phoneNumber);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove SMS verification'),
          content: Text(
            'Do you want to remove the factor associated with the number ending in $label?\n'
            'You can enable it again anytime.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: AppTheme.dialogOutlinedButtonStyle(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: AppTheme.dialogPrimaryButtonStyle(),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Could not complete the operation: $error';
  }

  String _buildDisplayName(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) {
      return 'SMS';
    }
    final last4 = digits.substring(digits.length - 4);
    return 'SMS $last4';
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter a phone number in international format.';
    }
    final isValid = RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(trimmed);
    if (!isValid) {
      return 'Use international format. E.g.: +56912345678';
    }
    return null;
  }

  String? _validateSmsCode(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter the code received by SMS.';
    }
    return null;
  }

  void _debugMfaUi(String event, {String? message}) {
    AuthMfaDebugLog.recordEvent(
      scope: 'MFA/UI',
      event: event,
      fields: <String, Object?>{'message': message ?? '-'},
    );
  }

  Future<void> _copyMfaDiagnostics() async {
    final dump = AuthMfaDebugLog.dump(limit: 250);
    await Clipboard.setData(ClipboardData(text: dump));
    if (!mounted) {
      return;
    }
    _showSnack('MFA diagnostics copied.');
  }

  @override
  Widget build(BuildContext context) {
    final canEnroll = !_isCheckingEmail && _isEmailVerified;
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                _buildInfoCard(),
                if (!canEnroll) ...[
                  const SizedBox(height: 16),
                  _buildEmailVerificationCard(),
                ],
                const SizedBox(height: 20),
                _buildFactorsSection(),
                const SizedBox(height: 20),
                _buildEnrollmentSection(canEnroll: canEnroll),
                InlineErrorText(message: _error),
                if (kDebugMode)
                  TextButton(
                    onPressed: _copyMfaDiagnostics,
                    style: AppTheme.brandTextButtonStyle(),
                    child: const Text('Copy MFA diagnostics'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return PageHeader(
      title: 'Security',
      subtitle: 'SMS verification',
      subtitleIcon: LucideIcons.messageSquare,
      onBackButtonPressed: widget.onBack,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardDecoration.boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enable SMS verification',
            style: AppTheme.titleMediumEmphasis(context),
          ),
          const SizedBox(height: 8),
          Text(
            'You will receive an SMS code each time you sign in on a new '
            'device. Use your number in international format.',
            style: AppTheme.bodyMediumMuted(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailVerificationCard() {
    if (_isCheckingEmail) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Checking email status...',
                style: AppTheme.bodyMediumMuted(context),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email verification required',
            style: AppTheme.bodyMediumEmphasis(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Before enabling SMS, verify your email. '
            'We will send you a link if you have not done it yet.',
            style: AppTheme.bodyMediumMuted(context),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: _sendEmailVerification,
                style: AppTheme.brandTextButtonStyle(),
                child: const Text('Send verification'),
              ),
              TextButton(
                onPressed: _refreshEmailVerification,
                style: AppTheme.brandTextButtonStyle(),
                child: const Text('I already verified'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsSection() {
    if (_isLoadingFactors) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_factors.isEmpty) {
      return Text(
        'You do not have SMS verification enabled yet.',
        style: AppTheme.bodyMediumMuted(context),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Registered factors', style: AppTheme.bodyMediumEmphasis(context)),
        const SizedBox(height: 12),
        ..._factors.map(_buildFactorTile),
      ],
    );
  }

  Widget _buildFactorTile(AuthEnrolledPhoneFactor factor) {
    final masked = maskPhone(factor.phoneNumber);
    final displayLabel = factor.displayName?.trim();
    final title = (displayLabel != null && displayLabel.isNotEmpty)
        ? displayLabel
        : 'SMS phone';
    final isRemoving = _removing.contains(factor.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.badgeCheck, color: AppTheme.brandBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyMediumEmphasis(context)),
                const SizedBox(height: 4),
                Text(
                  'Ends with $masked',
                  style: AppTheme.bodySmallMuted(context),
                ),
              ],
            ),
          ),
          isRemoving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: () => _removeFactor(factor),
                  style: AppTheme.brandTextButtonStyle(),
                  child: const Text('Remove'),
                ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentSection({required bool canEnroll}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add new number', style: AppTheme.bodyMediumEmphasis(context)),
        const SizedBox(height: 12),
        Form(
          key: _phoneFormKey,
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: AppTheme.outlinedDecoration(
              label: 'Phone (+56912345678)',
            ),
            validator: _validatePhone,
          ),
        ),
        const SizedBox(height: 12),
        AppButton(
          text: _isSendingCode ? 'Sending...' : 'Send code',
          onPressed: (!_isSendingCode && canEnroll) ? _sendCode : null,
        ),
        const SizedBox(height: 16),
        if (_hasPendingVerification) ...[
          Form(
            key: _codeFormKey,
            child: TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: AppTheme.outlinedDecoration(label: 'SMS code'),
              validator: _validateSmsCode,
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: _isConfirming ? 'Validating...' : 'Confirm',
            onPressed: (!_isConfirming && canEnroll)
                ? _confirmEnrollment
                : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: (!_isSendingCode && canEnroll)
                  ? () => _sendCode(resend: true)
                  : null,
              style: AppTheme.brandTextButtonStyle(),
              child: const Text('Resend code'),
            ),
          ),
        ],
      ],
    );
  }
}
