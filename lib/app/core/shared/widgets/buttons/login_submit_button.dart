import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double? fontSize;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 48,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, height),
        backgroundColor: AppTheme.brandAccentColor(context),
        foregroundColor: Colors.white,
        // Web pairs primary fills with a --primary-soft edge.
        side: BorderSide(color: AppTheme.primarySoftColor(context)),
        shape: AppTheme.buttonShape,
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
      child: Text(text),
    );
  }
}
