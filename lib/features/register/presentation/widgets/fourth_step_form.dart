import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_avatar.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_bloc.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_event.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_state.dart';

class FourthStepForm extends StatefulWidget {
  const FourthStepForm({
    super.key,
    this.onContinue,
    this.onBack,
    this.isLoading = false,
  });

  final VoidCallback? onContinue;
  final VoidCallback? onBack;
  final bool isLoading;

  @override
  State<FourthStepForm> createState() => _FourthStepFormState();
}

class _FourthStepFormState extends State<FourthStepForm> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final bool compactLayout = MediaQuery.sizeOf(context).width < 420;

    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmPassword != current.confirmPassword,
      builder: (context, state) {
        final String? confirmError = state.confirmPasswordError;
        final bool canContinue = state.canContinuePassword;

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
                        'Create your password',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.brandBlue,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'For your security, create a strong password '
                        'to sign in to the portal.',
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
              initialValue: state.password,
              obscureText: _obscurePassword,
              onChanged: (value) {
                context.read<RegisterBloc>().add(
                  RegisterPasswordChanged(value),
                );
              },
              decoration: AppTheme.outlinedDecoration(
                label: 'Create your password *',
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
                    satisfied: state.passwordHasAlphaNumeric,
                  ),
                  const SizedBox(height: 10),
                  _RequirementRow(
                    text: 'At least 1 uppercase letter',
                    satisfied: state.passwordHasUppercase,
                  ),
                  const SizedBox(height: 10),
                  _RequirementRow(
                    text: 'At least 1 lowercase letter',
                    satisfied: state.passwordHasLowercase,
                  ),
                  const SizedBox(height: 10),
                  _RequirementRow(
                    text: 'At least 1 number',
                    satisfied: state.passwordHasNumber,
                  ),
                  const SizedBox(height: 10),
                  _RequirementRow(
                    text: 'At least 1 symbol, e.g. (.&#+)-!',
                    satisfied: state.passwordHasSymbol,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.confirmPassword,
              obscureText: _obscureConfirm,
              onChanged: (value) {
                context.read<RegisterBloc>().add(
                  RegisterConfirmPasswordChanged(value),
                );
              },
              decoration: AppTheme.outlinedDecoration(
                label: 'Enter password again *',
                errorText: confirmError,
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
                            widget.onBack ??
                            () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                        style: AppTheme.brandTextButtonStyle(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: canContinue && !widget.isLoading
                              ? widget.onContinue
                              : null,
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
                              : const Text('Continue'),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      TextButton.icon(
                        onPressed:
                            widget.onBack ??
                            () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                        style: AppTheme.brandTextButtonStyle(),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 200,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: canContinue && !widget.isLoading
                              ? widget.onContinue
                              : null,
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
                              : const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
          ],
        );
      },
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
