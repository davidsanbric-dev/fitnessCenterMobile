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
    this.tapTargetSize,
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

  /// Overrides the button's tap-target sizing. Defaults to the framework's
  /// `padded` behavior; pass [MaterialTapTargetSize.shrinkWrap] to drop the
  /// extra invisible padding the framework adds to reach a 48px touch target
  /// (useful when a caller wants the button to sit flush against neighbours).
  final MaterialTapTargetSize? tapTargetSize;

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
                  backgroundColor: AppTheme.brandAccentColor(context),
                  foregroundColor: Colors.white,
                  shape: AppTheme.buttonShape,
                  tapTargetSize: tapTargetSize,
                ),
          ),
        ),
      ],
    );
  }
}
