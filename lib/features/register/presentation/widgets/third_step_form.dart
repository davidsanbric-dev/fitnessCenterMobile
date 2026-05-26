import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_avatar.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_bloc.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_event.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_state.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ThirdStepForm extends StatelessWidget {
  const ThirdStepForm({super.key, this.onContinue, this.onBack});

  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final bool canContinue = state.canContinueThirdStep;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandAvatar(icon: LucideIcons.user),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'These are your registered details',
                        style: AppTheme.titleMediumBrand(context),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Complete the missing details to finish registration.',
                        style: AppTheme.bodyMediumMuted(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: state.firstName,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                context.read<RegisterBloc>().add(
                  RegisterFirstNameChanged(value),
                );
              },
              decoration: AppTheme.underlineDecoration(label: 'First names'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.paternalSurname,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                context.read<RegisterBloc>().add(
                  RegisterPaternalSurnameChanged(value),
                );
              },
              decoration: AppTheme.underlineDecoration(label: 'Last name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.maternalSurname,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                context.read<RegisterBloc>().add(
                  RegisterMaternalSurnameChanged(value),
                );
              },
              decoration: AppTheme.underlineDecoration(
                label: 'Second last name',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.identificationType,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                context.read<RegisterBloc>().add(
                  RegisterIdentificationTypeChanged(value),
                );
              },
              decoration: AppTheme.underlineDecoration(
                label: 'Identification type',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.landlinePhone,
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                context.read<RegisterBloc>().add(
                  RegisterLandlinePhoneChanged(value),
                );
              },
              decoration: AppTheme.underlineDecoration(
                label: 'Landline phone (optional)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.cellPhone,
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                context.read<RegisterBloc>().add(
                  RegisterCellPhoneChanged(value),
                );
              },
              decoration: AppTheme.underlineDecoration(label: 'Mobile phone'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.address,
              keyboardType: TextInputType.streetAddress,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                context.read<RegisterBloc>().add(RegisterAddressChanged(value));
              },
              decoration: AppTheme.underlineDecoration(label: 'Address'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  icon: const Icon(LucideIcons.arrowLeft),
                  label: const Text('Back'),
                  style: AppTheme.brandTextButtonStyle(),
                ),
                const Spacer(),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: canContinue ? onContinue : null,
                    style: AppTheme.dialogPrimaryButtonStyle(),
                    child: const Text('Continue'),
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
