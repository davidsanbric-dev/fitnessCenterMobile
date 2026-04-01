import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/buttons/login_submit_button.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/form_text_field.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/form_title.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController locationCodeController = TextEditingController();
  final TextEditingController identificationTypeController =
      TextEditingController();
  final TextEditingController memberIdController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController paternalSurnameController =
      TextEditingController();
  final TextEditingController maternalSurnameController =
      TextEditingController();
  final TextEditingController cellPhoneController = TextEditingController();

  @override
  void dispose() {
    locationCodeController.dispose();
    identificationTypeController.dispose();
    memberIdController.dispose();
    firstNameController.dispose();
    paternalSurnameController.dispose();
    maternalSurnameController.dispose();
    cellPhoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Get.snackbar(
      'Registration ready',
      'Form validated. Integrate the registration service to continue.',
    );
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
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionTitle(text: 'Register member'),
                    // CustomTextField(
                    //   labelText: 'Código de sucursal',
                    //   controller: locationCodeController,
                    //   validatorText: 'Ingrese el código de sucursal',
                    // ),
                    CustomTextField(
                      labelText: 'Identification type',
                      controller: identificationTypeController,
                      validatorText: 'Enter identification type',
                    ),
                    CustomTextField(
                      labelText: 'Document ID',
                      controller: memberIdController,
                      validatorText: 'Enter member ID',
                    ),
                    CustomTextField(
                      labelText: 'First name',
                      controller: firstNameController,
                      validatorText: 'Enter first name',
                    ),
                    CustomTextField(
                      labelText: 'Last name',
                      controller: paternalSurnameController,
                      validatorText: 'Enter last name',
                    ),
                    CustomTextField(
                      labelText: 'Second last name',
                      controller: maternalSurnameController,
                      validatorText: 'Enter second last name',
                    ),
                    CustomTextField(
                      labelText: 'Mobile phone',
                      controller: cellPhoneController,
                      validatorText: 'Enter mobile phone',
                    ),
                    const SizedBox(height: 10),
                    AppButton(text: 'Register', onPressed: _submit),
                    const SizedBox(height: 8),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTheme.cardSubHeading,
                          ),
                          GestureDetector(
                            onTap: widget.onLoginTap,
                            child: Text(
                              'Sign in',
                              style: AppTheme.cardSubHeading.copyWith(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
