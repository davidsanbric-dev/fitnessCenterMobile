import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_logo.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/signing_message.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/verifying_and_signing_dialog.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class SecondStepPage extends StatefulWidget {
  const SecondStepPage({super.key, this.onBack, this.onContinue});

  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  @override
  State<SecondStepPage> createState() => _SecondStepPageState();
}

class _SecondStepPageState extends State<SecondStepPage> {
  bool _showSigningResult = false;
  String? _signingErrorMessage;

  Future<void> _openTermsDialog() async {
    if (_showSigningResult) {
      return;
    }
    final result = await TermsAndConditionsDialog.show(context);
    if (!mounted) {
      return;
    }
    if (result == null) {
      return;
    }
    setState(() {
      _showSigningResult = true;
      _signingErrorMessage = result.errorMessage?.trim();
    });
  }

  void _handleRetrySigning() {
    if (!_showSigningResult) {
      return;
    }
    setState(() {
      _showSigningResult = false;
      _signingErrorMessage = null;
    });
    _openTermsDialog();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSigningResult) {
      final hasError = (_signingErrorMessage?.isNotEmpty ?? false);
      return SigningMessage(
        onContinue: hasError ? null : widget.onContinue,
        onRetry: hasError ? _handleRetrySigning : null,
        errorMessage: _signingErrorMessage,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              const BrandLogo(height: 60),
              const SizedBox(height: 18),
              Text(
                'We are about to verify your identity.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'After your identity is verified, you will need to '
                'digitally sign the terms and conditions.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _openTermsDialog,
            icon: const Icon(LucideIcons.arrowRight),
            label: const Text('Verify and sign'),
            style: AppTheme.dialogPrimaryButtonStyle(),
          ),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(LucideIcons.arrowLeft),
          label: const Text('Back'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.brandBlue,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
