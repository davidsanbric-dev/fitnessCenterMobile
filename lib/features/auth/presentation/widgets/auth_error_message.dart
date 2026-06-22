import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:flutter/material.dart';

class AuthErrorMessage extends StatelessWidget {
  final String message;

  const AuthErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTheme.errorMessage,
      ),
    );
  }
}
