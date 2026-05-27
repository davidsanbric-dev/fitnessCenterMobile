import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/config/app_routes.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    required this.onPressed,
    this.label,
    this.tooltip = 'Volver',
    this.color,
    this.iconSize = 24,
    this.style,
  });

  final VoidCallback onPressed;
  final String? label;
  final String tooltip;
  final Color? color;
  final double iconSize;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final resolvedLabel = label?.trim();
    if (resolvedLabel == null || resolvedLabel.isEmpty) {
      return IconButton(
        icon: Icon(LucideIcons.chevronLeft, size: iconSize),
        color: color ?? Colors.white,
        tooltip: tooltip,
        onPressed: onPressed,
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(LucideIcons.chevronLeft, size: iconSize, color: color),
      label: Text(resolvedLabel),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    this.title,
    this.child,
    this.subtitle,
    this.subtitleIcon,
    this.subtitleIconSize = 18,
    this.subtitleSpacing = 6,
    this.onBackButtonPressed,
    this.onLogout,
    this.leadingPadding = EdgeInsets.zero,
    this.leadingSlotWidth = kMinInteractiveDimension,
  }) : assert(
         title != null || child != null,
         'Either title or child must be provided',
       );

  final String? title;
  final Widget? child;
  final String? subtitle;
  final IconData? subtitleIcon;
  final double subtitleIconSize;
  final double subtitleSpacing;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onLogout;
  final EdgeInsets leadingPadding;
  final double leadingSlotWidth;

  @override
  Widget build(BuildContext context) {
    final resolvedSubtitle = subtitle?.trim();
    final hasSubtitle = resolvedSubtitle != null && resolvedSubtitle.isNotEmpty;
    final content = child ?? _buildTitleContent(resolvedSubtitle, hasSubtitle);
    final onBackPressed = onBackButtonPressed;
    final resolvedLeading = onBackPressed == null
        ? null
        : AppBackButton(onPressed: onBackPressed);
    // Determine the effective logout callback: use explicit `onLogout` if provided,
    // otherwise auto-wire to `AuthService` logout flow when available.
    VoidCallback? effectiveOnLogout = onLogout;
    if (effectiveOnLogout == null && Get.isRegistered<AuthService>()) {
      Future<void> _performLogout() async {
        final messenger = ScaffoldMessenger.of(context);
        final authService = Get.find<AuthService>();
        try {
          await authService.logout();
          await Get.offAllNamed(AppRoutes.login);
        } catch (error) {
          messenger.showSnackBar(
            SnackBar(content: Text('Could not sign out: $error')),
          );
        }
      }

      effectiveOnLogout = () {
        _performLogout();
      };
    }
    // Build an optional trailing logout button slot when `onLogout` is provided.
    final Widget trailingSlot = effectiveOnLogout == null
        ? SizedBox(width: leadingSlotWidth)
        : SizedBox(
            width: leadingSlotWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(LucideIcons.logOut, size: 20, color: Colors.white),
                tooltip: 'Sign out',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: leadingSlotWidth,
                  minHeight: kMinInteractiveDimension,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: effectiveOnLogout,
              ),
            ),
          );

    final headerContent = resolvedLeading == null
        ? Row(
            children: [
              Expanded(child: Align(child: content)),
              trailingSlot,
            ],
          )
        : Row(
            children: [
              SizedBox(
                width: leadingSlotWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: leadingPadding,
                    child: resolvedLeading,
                  ),
                ),
              ),
              Expanded(child: Align(child: content)),
              trailingSlot,
            ],
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 22),
      alignment: Alignment.bottomCenter,
      constraints: const BoxConstraints(minHeight: 90, maxHeight: 110),
      decoration: const BoxDecoration(
        color: AppTheme.brandBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: headerContent,
    );
  }

  Widget _buildTitleContent(String? resolvedSubtitle, bool hasSubtitle) {
    final titleWidget = Text(
      title!,
      style: _titleStyle(hasSubtitle),
      textAlign: TextAlign.center,
    );
    if (!hasSubtitle) {
      return titleWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        titleWidget,
        SizedBox(height: _resolvedSubtitleSpacing()),
        _buildSubtitleRow(resolvedSubtitle!, hasSubtitle),
      ],
    );
  }

  double _resolvedSubtitleSpacing() {
    if (subtitleSpacing <= 0) {
      return 0;
    }
    return subtitleSpacing.clamp(2, 8);
  }

  TextStyle _titleStyle(bool compact) {
    if (!compact) {
      return AppTheme.orangeBarText;
    }
    return AppTheme.orangeBarText.copyWith(height: 1.1);
  }

  Widget _buildSubtitleRow(String label, bool compact) {
    final mutedColor = Colors.white.withValues(alpha: 0.75);
    final labelStyle = AppTheme.orangeBarTextNormal.copyWith(
      fontSize: compact ? 18 : 19,
      height: compact ? 1.1 : null,
      fontWeight: FontWeight.w600,
      color: mutedColor,
    );
    final resolvedIconSize = compact
        ? (subtitleIconSize - 2)
        : subtitleIconSize;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (subtitleIcon != null)
            Icon(subtitleIcon, size: resolvedIconSize, color: mutedColor),
          if (subtitleIcon != null) const SizedBox(width: 6),
          Text(label, style: labelStyle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
