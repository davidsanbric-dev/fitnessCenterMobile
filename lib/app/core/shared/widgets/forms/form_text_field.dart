import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final String validatorText;
  final bool isPassword;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.validatorText,
    this.isPassword = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        enabled: enabled,
        decoration: InputDecoration(labelText: labelText),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return validatorText;
          }
          return null;
        },
      ),
    );
  }
}
