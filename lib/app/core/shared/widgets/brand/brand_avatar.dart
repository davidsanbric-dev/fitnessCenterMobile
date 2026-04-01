import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';

class BrandAvatar extends StatelessWidget {
  const BrandAvatar({
    super.key,
    required this.icon,
    this.radius = 22,
    this.iconSize = 26,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final double radius;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? AppTheme.brandBlue.withValues(alpha: 0.12),
      child: Icon(icon, color: iconColor ?? AppTheme.brandBlue, size: iconSize),
    );
  }
}
