import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_logo.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class EmailAskingForm extends StatefulWidget {
  const EmailAskingForm({
    super.key,
    this.initialEmail,
    this.onContinue,
    this.onBack,
    this.isLoading = false,
  });

  final String? initialEmail;
  final ValueChanged<String>? onContinue;
  final VoidCallback? onBack;
  final bool isLoading;

  @override
  State<EmailAskingForm> createState() => _EmailAskingFormState();
}

class _EmailAskingFormState extends State<EmailAskingForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void didUpdateWidget(covariant EmailAskingForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialEmail != widget.initialEmail &&
        (widget.initialEmail ?? '') != _emailController.text) {
      _emailController.text = widget.initialEmail ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (widget.isLoading) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    widget.onContinue?.call(_emailController.text.trim());
  }

  String? _validateEmail(String? value) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Enter an email address.';
    }
    final bool isValid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(trimmed);
    if (!isValid) {
      return 'Enter a valid email.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool compactLayout = MediaQuery.sizeOf(context).width < 420;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed:
                  widget.onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(LucideIcons.arrowLeft),
              label: const Text('Back'),
              style: AppTheme.brandTextButtonStyle(),
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: BrandLogo(height: 60)),
          const SizedBox(height: 18),
          Text(
            'We will help you recover your password.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enter the email linked to your account to receive '
            'a reset link.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: _validateEmail,
            onFieldSubmitted: (_) => _handleContinue(),
            decoration: AppTheme.outlinedDecoration(
              label: 'Email address',
              suffixIcon: const Icon(
                LucideIcons.mail,
                color: AppTheme.brandBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),
          compactLayout
              ? SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: widget.isLoading
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
                      : ElevatedButton.icon(
                          onPressed: _handleContinue,
                          icon: const Icon(LucideIcons.arrowRight),
                          label: const Text('Send link'),
                          style: AppTheme.dialogPrimaryButtonStyle(),
                        ),
                )
              : Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 220,
                    height: 48,
                    child: widget.isLoading
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
                        : ElevatedButton.icon(
                            onPressed: _handleContinue,
                            icon: const Icon(LucideIcons.arrowRight),
                            label: const Text('Send link'),
                            style: AppTheme.dialogPrimaryButtonStyle(),
                          ),
                  ),
                ),
        ],
      ),
    );
  }
}
