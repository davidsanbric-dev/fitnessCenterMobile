import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_logo.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_bloc.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_event.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_state.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class SecurityVerificationBox extends StatefulWidget {
  const SecurityVerificationBox({
    super.key,
    this.onBack,
    this.onResend,
    this.validFor,
    this.isLoading = false,
    this.hasSentLink = false,
  });

  final VoidCallback? onBack;
  final Future<void> Function()? onResend;
  final String? validFor;
  final bool isLoading;
  final bool hasSentLink;

  @override
  State<SecurityVerificationBox> createState() =>
      _SecurityVerificationBoxState();
}

class _SecurityVerificationBoxState extends State<SecurityVerificationBox> {
  @override
  void initState() {
    super.initState();
    context.read<RegisterBloc>().add(
      RegisterVerificationStarted(validFor: widget.validFor),
    );
  }

  @override
  void didUpdateWidget(covariant SecurityVerificationBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.validFor != widget.validFor) {
      context.read<RegisterBloc>().add(
        RegisterVerificationStarted(validFor: widget.validFor),
      );
    }
  }

  Future<void> _handleResend() async {
    await widget.onResend?.call();
    if (!mounted) {
      return;
    }
    context.read<RegisterBloc>().add(
      RegisterVerificationStarted(validFor: widget.validFor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String maskedEmail = context.select<RegisterBloc, String>(
      (bloc) => bloc.state.maskedEmail,
    );
    final bool hasSentLink = widget.hasSentLink;
    final String title = hasSentLink
        ? 'Email verification'
        : 'Confirm your email';
    final String description = hasSentLink
        ? 'We sent a verification link to $maskedEmail. '
              'Open it on this device to continue to the next step.'
        : 'To continue, we will send a verification link to '
              '$maskedEmail.';
    final String buttonLabel = hasSentLink
        ? 'Resend verification link'
        : 'Send verification link';

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(LucideIcons.arrowLeft),
            label: const Text('Back'),
            style: AppTheme.brandTextButtonStyle(),
          ),
        ),
        const BrandLogo(height: 60),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'When the link is valid and opened in the app, we will '
          'automatically redirect you to Step 4.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'This link is valid for:',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ),
            BlocBuilder<RegisterBloc, RegisterState>(
              buildWhen: (previous, current) =>
                  previous.verificationRemaining !=
                  current.verificationRemaining,
              builder: (context, state) {
                return Text(
                  state.formattedVerificationRemaining,
                  style: AppTheme.bodyMediumEmphasis(context),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : _handleResend,
            style: AppTheme.dialogPrimaryButtonStyle(),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(buttonLabel),
          ),
        ),
      ],
    );
  }
}
