import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_avatar.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/input.dart';
import 'package:portfolio_mobile_app/app/core/utils/date_time.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_bloc.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_event.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_state.dart';

class FirstStepForm extends StatelessWidget {
  const FirstStepForm({super.key, this.onContinue, this.onBack});

  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final bool compactLayout = MediaQuery.sizeOf(context).width < 420;

    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final String? rutError = state.rutError;
        final bool showRutErrorIcon = state.showRutErrorIcon;
        final bool canContinue = state.canContinue;
        final bool hasMonthValue = monthOptions.any(
          (option) => option.value == state.birthMonth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandAvatar(icon: Icons.person_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start by entering your details',
                        style: AppTheme.titleMediumBrand(context),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'It will only take a few minutes',
                        style: AppTheme.bodyMediumMuted(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: const [RutInputFormatter()],
              initialValue: state.rut,
              onChanged: (value) {
                context.read<RegisterBloc>().add(RegisterRutChanged(value));
              },
              decoration: AppTheme.outlinedDecoration(
                label: 'Your ID',
                labelColor: rutError != null
                    ? Colors.red.shade700
                    : Colors.grey.shade700,
                errorText: rutError,
                suffixIcon: showRutErrorIcon
                    ? Icon(Icons.error, color: Colors.red.shade400)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppTheme.brandBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your birth date',
                  style: AppTheme.bodyMediumEmphasis(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: state.birthDay,
                    onChanged: (value) {
                      context.read<RegisterBloc>().add(
                        RegisterBirthDayChanged(value),
                      );
                    },
                    decoration: AppTheme.outlinedDecoration(label: 'Day'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: hasMonthValue ? state.birthMonth : null,
                    items: monthOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option.value,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      context.read<RegisterBloc>().add(
                        RegisterBirthMonthChanged(value),
                      );
                    },
                    decoration: AppTheme.outlinedDecoration(label: 'Month'),
                    isExpanded: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: state.birthYear,
                    onChanged: (value) {
                      context.read<RegisterBloc>().add(
                        RegisterBirthYearChanged(value),
                      );
                    },
                    decoration: AppTheme.outlinedDecoration(label: 'Year'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              initialValue: state.email,
              onChanged: (value) {
                context.read<RegisterBloc>().add(RegisterEmailChanged(value));
              },
              decoration: AppTheme.outlinedDecoration(
                label: 'Enter your email',
                suffixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppTheme.brandBlue,
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
                            onBack ?? () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                        style: AppTheme.brandTextButtonStyle(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: canContinue
                              ? () {
                                  context.read<RegisterBloc>().add(
                                    const RegisterSubmitted(),
                                  );
                                  onContinue?.call();
                                }
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Continue'),
                          style: AppTheme.dialogPrimaryButtonStyle(),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      TextButton.icon(
                        onPressed:
                            onBack ?? () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                        style: AppTheme.brandTextButtonStyle(),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 210,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: canContinue
                              ? () {
                                  context.read<RegisterBloc>().add(
                                    const RegisterSubmitted(),
                                  );
                                  onContinue?.call();
                                }
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Continue'),
                          style: AppTheme.dialogPrimaryButtonStyle(),
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
