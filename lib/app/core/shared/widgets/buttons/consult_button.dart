import 'package:portfolio_mobile_app/app/core/shared/widgets/buttons/create_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ConsultButton extends StatelessWidget {
  const ConsultButton({
    super.key,
    required this.onPressed,
    this.horizontalPadding = 16,
    this.bottom = 16,
    this.label = 'Search',
    this.icon = const Icon(LucideIcons.search),
    this.alignment = Alignment.center,
    this.spacing = 0,
  });

  final VoidCallback? onPressed;
  final double horizontalPadding;
  final double bottom;
  final String label;
  final Widget icon;
  final Alignment alignment;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: CreateButton(
            label: label,
            icon: icon,
            alignment: alignment,
            spacing: spacing,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
