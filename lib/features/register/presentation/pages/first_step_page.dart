import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/features/register/presentation/widgets/first_step_form.dart';

class FirstStepPage extends StatelessWidget {
  const FirstStepPage({super.key, this.onContinue, this.onBack});

  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return FirstStepForm(onContinue: onContinue, onBack: onBack);
  }
}
