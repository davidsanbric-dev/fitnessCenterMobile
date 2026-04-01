import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';

/// Reusable button that toggles advanced filter sheets or dialogs. It handles
/// the active state, tooltip messaging, dynamic icon, and padding so every
/// usage looks consistent.
class AdvancedFiltersButton extends StatelessWidget {
  const AdvancedFiltersButton({
    super.key,
    required this.hasActiveFilters,
    required this.hasAvailableFilters,
    this.isLoading = false,
    this.onPressed,
    this.activeLabel = 'Advanced filters\n(active)',
    this.inactiveLabel = 'Advanced\nfilters',
    this.activeTooltip = 'Advanced filters active',
    this.inactiveTooltip = 'Open advanced filters',
    this.activeIcon,
    this.inactiveIcon,
    this.activePadding = const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 8),
    this.inactivePadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 8,
    ),
    this.labelConstraints = const BoxConstraints(minHeight: 36),
    this.labelTextAlign = TextAlign.center,
    this.style,
  });

  final bool hasActiveFilters;
  final bool hasAvailableFilters;
  final bool isLoading;
  final VoidCallback? onPressed;
  final String activeLabel;
  final String inactiveLabel;
  final String activeTooltip;
  final String inactiveTooltip;
  final Widget? activeIcon;
  final Widget? inactiveIcon;
  final EdgeInsetsGeometry activePadding;
  final EdgeInsetsGeometry inactivePadding;
  final BoxConstraints labelConstraints;
  final TextAlign labelTextAlign;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled =
        !isLoading && hasAvailableFilters && onPressed != null;
    final String tooltipMessage = hasActiveFilters
        ? activeTooltip
        : inactiveTooltip;
    final Widget resolvedIcon = hasActiveFilters
        ? (activeIcon ?? const Icon(Icons.filter_alt))
        : (inactiveIcon ?? const Icon(Icons.tune));
    final String resolvedLabel = hasActiveFilters ? activeLabel : inactiveLabel;
    final EdgeInsetsGeometry resolvedPadding = hasActiveFilters
        ? activePadding
        : inactivePadding;

    return Tooltip(
      message: tooltipMessage,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: resolvedIcon,
        label: ConstrainedBox(
          constraints: labelConstraints,
          child: Text(resolvedLabel, textAlign: labelTextAlign),
        ),
        style:
            style ??
            ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandBlue,
              foregroundColor: Colors.white,
              shape: AppTheme.buttonShape,
              padding: resolvedPadding,
            ),
      ),
    );
  }
}
