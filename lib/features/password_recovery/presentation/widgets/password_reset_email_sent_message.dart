import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_icon_name_white_background.dart';

class PasswordResetEmailSentMessage extends StatelessWidget {
  const PasswordResetEmailSentMessage({
    super.key,
    required this.email,
    this.onResend,
    this.onBack,
    this.isLoading = false,
  });

  final String email;
  final VoidCallback? onResend;
  final VoidCallback? onBack;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final String maskedEmail = _maskEmail(email);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: AppTheme.brandTextButtonStyle(),
          ),
        ),
        const BrandIconNameWhiteBackground(),
        const SizedBox(height: 16),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a reset link to $maskedEmail. '
          'Open the email and follow the instructions.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'If you cannot find it, check your spam folder.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 46,
          child: isLoading
              ? ElevatedButton(
                  onPressed: null,
                  style: AppTheme.dialogPrimaryButtonStyle(),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : OutlinedButton(
                  onPressed: onResend,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.brandBlue,
                    side: const BorderSide(
                      color: AppTheme.brandBlue,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Resend link'),
                ),
        ),
      ],
    );
  }

  String _maskEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'rp******@gm*******.c****';
    }

    final List<String> parts = email.trim().split('@');
    if (parts.length != 2) {
      return email.trim();
    }

    final String local = parts[0];
    final String domain = parts[1];
    final List<String> domainParts = domain.split('.');
    final String domainName = domainParts.isNotEmpty
        ? domainParts.first
        : domain;
    final String domainSuffix = domainParts.length > 1
        ? domainParts.sublist(1).join('.')
        : '';

    final String maskedLocal = _maskChunk(local);
    final String maskedDomain = _maskChunk(domainName);
    final String maskedSuffix = domainSuffix.isEmpty
        ? ''
        : _maskChunk(domainSuffix, keepStart: 1);

    return '$maskedLocal@$maskedDomain'
        '${maskedSuffix.isEmpty ? '' : '.$maskedSuffix'}';
  }

  String _maskChunk(String value, {int keepStart = 2, int keepEnd = 0}) {
    if (value.isEmpty) {
      return value;
    }

    if (value.length <= keepStart + keepEnd) {
      return '${value.substring(0, 1)}'
          '${List.filled(value.length - 1, '*').join()}';
    }

    final int maskedLength = value.length - keepStart - keepEnd;
    final String start = value.substring(0, keepStart);
    final String end = keepEnd > 0
        ? value.substring(value.length - keepEnd)
        : '';
    return '$start${List.filled(maskedLength, '*').join()}$end';
  }
}
