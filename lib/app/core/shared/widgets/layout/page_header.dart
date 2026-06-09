import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    required this.onPressed,
    this.label,
    this.tooltip = 'Back',
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
    this.secondarySubtitle,
    this.secondarySubtitleIcon,
    this.subtitleIconSize = 18,
    this.subtitleSpacing = 6,
    this.onBackButtonPressed,
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

  /// Optional second-level subtitle rendered below [subtitle] in a smaller,
  /// more muted style. Lets a single header express a three-tier hierarchy
  /// (title › subtitle › secondary subtitle), e.g. the bookings page showing
  /// `My Bookings › Book a Session › By Class Type`.
  final String? secondarySubtitle;
  final IconData? secondarySubtitleIcon;
  final double subtitleIconSize;
  final double subtitleSpacing;
  final VoidCallback? onBackButtonPressed;
  final EdgeInsets leadingPadding;
  final double leadingSlotWidth;

  @override
  Widget build(BuildContext context) {
    final resolvedSubtitle = subtitle?.trim();
    final hasSubtitle = resolvedSubtitle != null && resolvedSubtitle.isNotEmpty;
    final resolvedSecondary = secondarySubtitle?.trim();
    final hasSecondary =
        resolvedSecondary != null && resolvedSecondary.isNotEmpty;
    final content =
        child ??
        _buildTitleContent(
          resolvedSubtitle,
          hasSubtitle,
          resolvedSecondary,
          hasSecondary,
        );
    final onBackPressed = onBackButtonPressed;
    final resolvedLeading = onBackPressed == null
        ? null
        : AppBackButton(onPressed: onBackPressed);
    // Logout now lives on the member profile page, so the header keeps only an
    // empty trailing slot to balance the optional leading back button and keep
    // the centered content aligned.
    final Widget trailingSlot = SizedBox(width: leadingSlotWidth);

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
      constraints: BoxConstraints(
        minHeight: 90,
        // A second-level subtitle adds a third text line, so give the bar a
        // little more vertical room to avoid clipping it.
        maxHeight: hasSecondary ? 134 : 110,
      ),
      decoration: BoxDecoration(
        // Dark mode mirrors the web sidebar gradient so the aquamarine brand
        // mark reads as genuinely aqua; light mode keeps the solid brand blue.
        gradient: AppTheme.headerGradient(context),
        color: AppTheme.headerGradient(context) == null
            ? AppTheme.brandAccentColor(context)
            : null,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor(context)),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: headerContent,
    );
  }

  Widget _buildTitleContent(
    String? resolvedSubtitle,
    bool hasSubtitle,
    String? resolvedSecondary,
    bool hasSecondary,
  ) {
    final compact = hasSubtitle || hasSecondary;
    final titleWidget = Text(
      title!,
      style: _titleStyle(compact),
      textAlign: TextAlign.center,
    );
    if (!compact) {
      return titleWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        titleWidget,
        if (hasSubtitle) ...[
          SizedBox(height: _resolvedSubtitleSpacing()),
          _buildSubtitleRow(resolvedSubtitle!, compact),
        ],
        if (hasSecondary) ...[
          const SizedBox(height: 3),
          _buildSecondarySubtitleRow(resolvedSecondary!),
        ],
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

  Widget _buildSecondarySubtitleRow(String label) {
    final mutedColor = Colors.white.withValues(alpha: 0.62);
    final labelStyle = AppTheme.orangeBarTextNormal.copyWith(
      fontSize: 15,
      height: 1.1,
      fontWeight: FontWeight.w500,
      color: mutedColor,
    );
    final resolvedIconSize = subtitleIconSize - 4;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (secondarySubtitleIcon != null)
            Icon(secondarySubtitleIcon, size: resolvedIconSize, color: mutedColor),
          if (secondarySubtitleIcon != null) const SizedBox(width: 5),
          Text(label, style: labelStyle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
