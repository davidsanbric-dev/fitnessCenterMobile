import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CreateButton extends StatelessWidget {
  const CreateButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
    this.icon = const Icon(LucideIcons.plus),
    this.loadingIcon,
    this.spacing = 12,
    this.alignment = Alignment.centerLeft,
    this.style,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final String? loadingLabel;
  final Widget icon;
  final Widget? loadingIcon;
  final double spacing;
  final Alignment alignment;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = onPressed != null && !isLoading;
    final Widget resolvedIcon = isLoading
        ? (loadingIcon ??
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ))
        : icon;
    final String resolvedLabel = isLoading ? (loadingLabel ?? label) : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing),
        Align(
          alignment: alignment,
          child: ElevatedButton.icon(
            onPressed: isButtonEnabled ? onPressed : null,
            icon: resolvedIcon,
            label: Text(resolvedLabel),
            style:
                style ??
                ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandBlue,
                  foregroundColor: Colors.white,
                  shape: AppTheme.buttonShape,
                ),
          ),
        ),
      ],
    );
  }
}
