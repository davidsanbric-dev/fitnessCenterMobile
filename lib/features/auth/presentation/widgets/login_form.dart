import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/buttons/login_submit_button.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/form_text_field.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/form_title.dart';
import 'package:portfolio_mobile_app/features/auth/logic/auth_controller.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final AuthController controller = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  final _mfaFormKey = GlobalKey<FormState>();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController smsCodeController = TextEditingController();

  @override
  void dispose() {
    mailController.dispose();
    passwordController.dispose();
    smsCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    final req = AuthRequest(
      mail: mailController.text.trim(),
      password: passwordController.text,
    );

    await controller.login(request: req);
  }

  Future<void> _submitMfa() async {
    if (!(_mfaFormKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await controller.verifyMfaCode(smsCodeController.text);
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
            child: Obx(() {
              final isMfa = controller.isMfaRequired.value;
              final isVerifyEmail = controller.isEmailVerificationRequired.value;
              final isLoading = controller.isLoading.value;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration,
                child: Form(
                  key: isMfa ? _mfaFormKey : _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionTitle(text: 'Access your account'),
                      if (isVerifyEmail) ...[
                        const SizedBox(height: 8),
                        Text(
                          controller.emailVerificationInfo.value,
                          textAlign: TextAlign.center,
                          style: AppTheme.cardSubHeading,
                        ),
                        const SizedBox(height: 12),
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : AppButton(
                                text: 'I have verified',
                                onPressed: controller.confirmEmailVerified,
                              ),
                        if (!isLoading) ...[
                          TextButton(
                            onPressed: controller.resendVerificationEmail,
                            style: AppTheme.brandTextButtonStyle(),
                            child: const Text('Resend verification email'),
                          ),
                          TextButton(
                            onPressed: controller.cancelEmailVerification,
                            style: AppTheme.brandTextButtonStyle(),
                            child: const Text('Back'),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (controller.emailVerificationError.isNotEmpty)
                          Text(
                            controller.emailVerificationError.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                      ] else ...[
                      if (!isMfa) ...[
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
                      ],
                      if (isMfa) ...[
                        Text(
                          controller.mfaInfo.value,
                          textAlign: TextAlign.center,
                          style: AppTheme.cardSubHeading,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: smsCodeController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'SMS code',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter the received code';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 10),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : AppButton(
                              text: isMfa ? 'Verify code' : 'Sign in',
                              onPressed: isMfa ? _submitMfa : _submit,
                            ),
                      isLoading
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                if (isMfa) ...[
                                  TextButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : controller.resendMfaCode,
                                    style: AppTheme.brandTextButtonStyle(),
                                    child: const Text('Resend code'),
                                  ),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : controller.cancelMfa,
                                    style: AppTheme.brandTextButtonStyle(),
                                    child: const Text('Back'),
                                  ),
                                ],
                              ],
                            ),
                      const SizedBox(height: 16),
                      if (!isMfa && controller.error.isNotEmpty)
                        Text(
                          controller.error.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (isMfa && controller.mfaError.isNotEmpty)
                        Text(
                          controller.mfaError.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
