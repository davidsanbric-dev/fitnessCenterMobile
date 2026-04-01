import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/api/user_api.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/input.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_bloc.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_event.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_state.dart';

typedef IdentityVerificationResultCallback =
    void Function({required bool isSuccess, String? message});

class SecondStepForm extends StatefulWidget {
  const SecondStepForm({super.key, this.onVerify, this.userApi});

  final IdentityVerificationResultCallback? onVerify;
  final UserApi? userApi;

  @override
  State<SecondStepForm> createState() => _SecondStepFormState();
}

class _SecondStepFormState extends State<SecondStepForm> {
  bool _isVerifying = false;
  late final UserApi _userApi = widget.userApi ?? UserApi();

  Future<void> _handleVerify(RegisterState state) async {
    if (_isVerifying || !state.canVerifyIdentity) {
      return;
    }

    setState(() => _isVerifying = true);

    try {
      await _userApi.checkIdentityGovernment(rut: state.rut);
      if (!mounted) {
        return;
      }
      widget.onVerify?.call(isSuccess: true);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.message.trim();
      widget.onVerify?.call(
        isSuccess: false,
        message: message.isEmpty
            ? 'Could not verify your identity. Please try again.'
            : message,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      widget.onVerify?.call(
        isSuccess: false,
        message: 'Could not verify your identity. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final String? rutError = state.rutError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'VERIFY YOUR IDENTITY',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'To start the signing process, we need to validate your '
              'identity. Enter the requested details below.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: state.rut,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: const [RutInputFormatter()],
              onChanged: (value) {
                context.read<RegisterBloc>().add(RegisterRutChanged(value));
              },
              decoration: AppTheme.underlineDecoration(
                label: 'ID',
                errorText: rutError,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: state.memberId,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                context.read<RegisterBloc>().add(
                  RegisterMemberIdChanged(value),
                );
              },
              decoration: AppTheme.underlineDecoration(
                label: 'Document number',
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: state.canVerifyIdentity && !_isVerifying
                    ? () => _handleVerify(state)
                    : null,
                style: AppTheme.dialogPrimaryButtonStyle(),
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify'),
              ),
            ),
          ],
        );
      },
    );
  }
}
