import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';

class PasswordResetSuccessMessage extends StatefulWidget {
  const PasswordResetSuccessMessage({super.key, this.onContinue});

  final VoidCallback? onContinue;

  @override
  State<PasswordResetSuccessMessage> createState() =>
      _PasswordResetSuccessMessageState();
}

class _PasswordResetSuccessMessageState
    extends State<PasswordResetSuccessMessage> {
  bool _hasContinued = false;

  void _handleContinue() {
    if (_hasContinued) {
      return;
    }
    _hasContinued = true;
    widget.onContinue?.call();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Your password was reset successfully!',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.shade300, thickness: 1),
        const SizedBox(height: 16),
        Text(
          'You can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        const _PasswordResetSuccessIllustration(),
        const SizedBox(height: 28),
        Center(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: widget.onContinue == null ? null : _handleContinue,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Go to sign in'),
              style: AppTheme.dialogPrimaryButtonStyle(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordResetSuccessIllustration extends StatelessWidget {
  const _PasswordResetSuccessIllustration();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 200,
        height: 120,
        child: Center(
          child: Icon(
            Icons.check_circle,
            size: 120,
            color: Color.fromARGB(255, 84, 173, 87),
          ),
        ),
      ),
    );
  }
}
