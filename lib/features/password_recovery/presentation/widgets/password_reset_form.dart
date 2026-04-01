import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_avatar.dart';

class PasswordResetForm extends StatefulWidget {
  const PasswordResetForm({
    super.key,
    this.onContinue,
    this.onBack,
    this.isLoading = false,
  });

  final ValueChanged<String>? onContinue;
  final VoidCallback? onBack;
  final bool isLoading;

  @override
  State<PasswordResetForm> createState() => _PasswordResetFormState();
}

class _PasswordResetFormState extends State<PasswordResetForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String get _password => _passwordController.text;

  bool get _passwordHasMinLength => _password.length >= 8;

  bool get _passwordHasUppercase => RegExp(r'[A-Z]').hasMatch(_password);

  bool get _passwordHasLowercase => RegExp(r'[a-z]').hasMatch(_password);

  bool get _passwordHasNumber => RegExp(r'[0-9]').hasMatch(_password);

  bool get _passwordHasSymbol => RegExp(
    r'[!@#\$%\^&\*\(\)\-\+=\[\]\{\};:,.<>\/\?\|\\_`~]',
  ).hasMatch(_password);

  bool get _passwordHasAlphaNumeric =>
      _passwordHasMinLength &&
      RegExp(r'[A-Za-z]').hasMatch(_password) &&
      _passwordHasNumber;

  bool get _isPasswordValid =>
      _passwordHasAlphaNumeric &&
      _passwordHasUppercase &&
      _passwordHasLowercase &&
      _passwordHasNumber &&
      _passwordHasSymbol;

  bool get _doesConfirmPasswordMatch =>
      _confirmPasswordController.text.isNotEmpty &&
      _confirmPasswordController.text == _password;

  bool get _canContinue => _isPasswordValid && _doesConfirmPasswordMatch;

  String? get _confirmError {
    if (_confirmPasswordController.text.isEmpty) {
      return null;
    }
    if (!_doesConfirmPasswordMatch) {
      return 'Passwords do not match.';
    }
    return null;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (widget.isLoading) {
      return;
    }
    if (!_canContinue) {
      return;
    }
    widget.onContinue?.call(_password);
  }

  @override
  Widget build(BuildContext context) {
    final bool compactLayout = MediaQuery.sizeOf(context).width < 420;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandAvatar(icon: Icons.lock_outline, iconSize: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create your new password',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.brandBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a strong password to recover access '
                    'to your account.',
                    style: AppTheme.bodyMediumMuted(
                      context,
                    )?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          decoration: AppTheme.outlinedDecoration(
            label: 'New password *',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.brandBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.list_alt, color: AppTheme.brandBlue, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'For security, your password must include:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4F4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RequirementRow(
                text:
                    'At least 8 alphanumeric characters (letters and numbers)',
                satisfied: _passwordHasAlphaNumeric,
              ),
              const SizedBox(height: 10),
              _RequirementRow(
                text: 'At least 1 uppercase letter',
                satisfied: _passwordHasUppercase,
              ),
              const SizedBox(height: 10),
              _RequirementRow(
                text: 'At least 1 lowercase letter',
                satisfied: _passwordHasLowercase,
              ),
              const SizedBox(height: 10),
              _RequirementRow(
                text: 'At least 1 number',
                satisfied: _passwordHasNumber,
              ),
              const SizedBox(height: 10),
              _RequirementRow(
                text: 'At least 1 symbol, e.g. (.&#+)-!',
                satisfied: _passwordHasSymbol,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          onChanged: (_) => setState(() {}),
          decoration: AppTheme.outlinedDecoration(
            label: 'Confirm your new password *',
            errorText: _confirmError,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              },
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.brandBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        compactLayout
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton.icon(
                    onPressed:
                        widget.onBack ?? () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: AppTheme.brandTextButtonStyle(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
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
                        : ElevatedButton(
                            onPressed: _canContinue ? _handleContinue : null,
                            style: AppTheme.dialogPrimaryButtonStyle(),
                            child: const Text('Continue'),
                          ),
                  ),
                ],
              )
            : Row(
                children: [
                  TextButton.icon(
                    onPressed:
                        widget.onBack ?? () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: AppTheme.brandTextButtonStyle(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 200,
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
                        : ElevatedButton(
                            onPressed: _canContinue ? _handleContinue : null,
                            style: AppTheme.dialogPrimaryButtonStyle(),
                            child: const Text('Continue'),
                          ),
                  ),
                ],
              ),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.text, required this.satisfied});

  final String text;
  final bool satisfied;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = satisfied
        ? AppTheme.brandBlue
        : Colors.grey.shade400;
    final Color textColor = satisfied
        ? Colors.grey.shade800
        : Colors.grey.shade600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.radio_button_unchecked,
          color: iconColor,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: textColor, height: 1.4),
          ),
        ),
      ],
    );
  }
}
