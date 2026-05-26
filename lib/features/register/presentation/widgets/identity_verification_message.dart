import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class IdentityVerificationMessage extends StatefulWidget {
  const IdentityVerificationMessage({
    super.key,
    this.onContinue,
    this.isSuccess = true,
    this.message,
  });

  final VoidCallback? onContinue;
  final bool isSuccess;
  final String? message;

  @override
  State<IdentityVerificationMessage> createState() =>
      _IdentityVerificationMessageState();
}

class _IdentityVerificationMessageState
    extends State<IdentityVerificationMessage> {
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
    final textTheme = Theme.of(context).textTheme;
    final bool isSuccess = widget.isSuccess;
    final String title = widget.message?.trim().isNotEmpty ?? false
        ? widget.message!.trim()
        : isSuccess
        ? 'Identity verified successfully!'
        : 'Could not verify your identity.';
    final String buttonLabel = isSuccess ? 'Continue' : 'Verify again';
    final IconData buttonIcon = isSuccess
        ? LucideIcons.arrowRight
        : LucideIcons.refreshCw;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSuccess ? Colors.black87 : Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.shade300, thickness: 1),
        const SizedBox(height: 28),
        _IdentityVerificationIllustration(isSuccess: isSuccess),
        const SizedBox(height: 28),
        Center(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: widget.onContinue == null ? null : _handleContinue,
              icon: Icon(buttonIcon, size: 18),
              label: Text(buttonLabel),
              style: AppTheme.dialogPrimaryButtonStyle(),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentityVerificationIllustration extends StatelessWidget {
  const _IdentityVerificationIllustration({required this.isSuccess});

  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 120,
        child: Center(
          child: Icon(
            isSuccess ? LucideIcons.badgeCheck : LucideIcons.alertCircle,
            size: 120,
            color: isSuccess
                ? const Color.fromARGB(255, 84, 173, 87)
                : Colors.red.shade400,
          ),
        ),
      ),
    );
  }
}
