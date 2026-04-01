import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';

class InlineErrorText extends StatelessWidget {
  const InlineErrorText({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.only(top: 16),
    this.style,
  });

  final String? message;
  final EdgeInsetsGeometry padding;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final value = message?.trim();
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: padding,
      child: Text(value, style: style ?? AppTheme.bodySmallError(context)),
    );
  }
}
