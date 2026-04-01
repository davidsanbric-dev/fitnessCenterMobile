import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';

class RegistrationMessage extends StatefulWidget {
  const RegistrationMessage({
    super.key,
    this.onContinue,
    this.onRetry,
    this.errorMessage,
  });

  final VoidCallback? onContinue;
  final VoidCallback? onRetry;
  final String? errorMessage;

  @override
  State<RegistrationMessage> createState() => _RegistrationMessageState();
}

class _RegistrationMessageState extends State<RegistrationMessage> {
  bool _hasTriggeredAction = false;

  void _handleContinue() {
    if (_hasTriggeredAction) {
      return;
    }
    _hasTriggeredAction = true;
    widget.onContinue?.call();
  }

  void _handleRetry() {
    if (_hasTriggeredAction) {
      return;
    }
    _hasTriggeredAction = true;
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final String normalizedError = widget.errorMessage?.trim() ?? '';
    final bool hasError = normalizedError.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          hasError
              ? 'Could not complete your registration'
              : 'Your registration has been completed successfully!',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: hasError ? Colors.red.shade700 : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.shade300, thickness: 1),
        const SizedBox(height: 16),
        Text(
          hasError
              ? normalizedError
              : 'You can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: hasError ? Colors.red.shade700 : Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        _RegistrationStatusIllustration(hasError: hasError),
        const SizedBox(height: 28),
        Center(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: hasError
                  ? (widget.onRetry == null ? null : _handleRetry)
                  : (widget.onContinue == null ? null : _handleContinue),
              icon: Icon(
                hasError ? Icons.refresh : Icons.arrow_forward,
                size: 18,
              ),
              label: Text(hasError ? 'Retry' : 'Go to sign in'),
              style: AppTheme.dialogPrimaryButtonStyle(),
            ),
          ),
        ),
      ],
    );
  }
}

class _RegistrationStatusIllustration extends StatelessWidget {
  const _RegistrationStatusIllustration({required this.hasError});

  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 120,
        child: Center(
          child: Icon(
            hasError ? Icons.error : Icons.check_circle,
            size: 120,
            color: hasError
                ? const Color.fromARGB(255, 201, 64, 64)
                : const Color.fromARGB(255, 84, 173, 87),
          ),
        ),
      ),
    );
  }
}
