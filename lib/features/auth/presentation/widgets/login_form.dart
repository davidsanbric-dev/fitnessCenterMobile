import 'package:flutter/material.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/buttons/login_submit_button.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/forms/form_text_field.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/forms/form_title.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/shared_view_model_host.dart';
import 'package:fitnesscenter_mobile/features/auth/feature.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SharedViewModelHost<LoginForm, AuthViewModel> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  AuthViewModel createViewModel() => AuthInjector.getAuthViewModel();

  @override
  void initState() {
    super.initState();
    acquireViewModel();
  }

  @override
  void dispose() {
    mailController.dispose();
    passwordController.dispose();
    releaseViewModel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    final req = AuthRequest(
      mail: mailController.text.trim(),
      password: passwordController.text,
    );

    await viewModel.login(request: req);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth * 0.9;
        final width = maxWidth > 600 ? 600.0 : maxWidth;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                final isVerifyEmail = viewModel.isEmailVerificationRequired;
                final isLoading = viewModel.isLoading;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cardDecoration,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionTitle(text: 'Access your account'),
                        if (isVerifyEmail) ...[
                          const SizedBox(height: 8),
                          Text(
                            viewModel.emailVerificationInfo,
                            textAlign: TextAlign.center,
                            style: AppTheme.cardSubHeading,
                          ),
                          const SizedBox(height: 12),
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : AppButton(
                                  text: 'I have verified',
                                  onPressed: viewModel.confirmEmailVerified,
                                ),
                          if (!isLoading) ...[
                            TextButton(
                              onPressed: viewModel.resendVerificationEmail,
                              style: AppTheme.brandTextButtonStyle(),
                              child: const Text('Resend verification email'),
                            ),
                            TextButton(
                              onPressed: viewModel.cancelEmailVerification,
                              style: AppTheme.brandTextButtonStyle(),
                              child: const Text('Back'),
                            ),
                          ],
                          const SizedBox(height: 8),
                          if (viewModel.emailVerificationError.isNotEmpty)
                            Text(
                              viewModel.emailVerificationError,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                        ] else ...[
                          CustomTextField(
                            labelText: 'Email',
                            controller: mailController,
                            validatorText: 'Enter your email',
                            enabled: !isLoading,
                          ),
                          CustomTextField(
                            labelText: 'Password',
                            controller: passwordController,
                            validatorText: 'Enter your password',
                            isPassword: true,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 10),
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : AppButton(text: 'Sign in', onPressed: _submit),
                          const SizedBox(height: 16),
                          if (viewModel.error.isNotEmpty)
                            Text(
                              viewModel.error,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
