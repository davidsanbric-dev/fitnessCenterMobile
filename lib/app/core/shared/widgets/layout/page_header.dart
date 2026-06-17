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
        // Trim the default 48px tap target so the back button no longer forces
        // the title row taller than the title text itself.
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
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
    this.subtitleSpacing = 2,
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

  /// How long the subtitle fade-in/fade-out and the header's height change take
  /// when the feature flow moves between stages.
  static const Duration _subtitleAnimationDuration = Duration(
    milliseconds: 260,
  );

  /// Vertical space always reserved below the title for a single subtitle line.
  /// Reserving it even on subtitle-less pages keeps the bar (and the title's
  /// position within it) identical between a feature's root and its subpages,
  /// so the header never resizes or shifts when a subtitle fades in.
  static const double _reservedSubtitleHeight = 22;

  /// Fixed height of the single subtitle line. Together with the 2px subtitle
  /// spacing this sums to [_reservedSubtitleHeight], so the rendered subtitle
  /// exactly fills its reserved slot and never grows the bar.
  static const double _subtitleLineHeight = 20;

  /// Exact height of the title row. Comfortably clears both the title text and
  /// the trimmed back-button tap target so neither can resize the row.
  static const double _titleRowHeight = 40;

  @override
  Widget build(BuildContext context) {
    final resolvedSubtitle = subtitle?.trim();
    final hasSubtitle = resolvedSubtitle != null && resolvedSubtitle.isNotEmpty;
    final resolvedSecondary = secondarySubtitle?.trim();
    final hasSecondary =
        resolvedSecondary != null && resolvedSecondary.isNotEmpty;

    final onBackPressed = onBackButtonPressed;
    final resolvedLeading = onBackPressed == null
        ? null
        : AppBackButton(onPressed: onBackPressed);
    // The leading slot always occupies the same width — holding the back button
    // when present, empty otherwise — and the trailing slot mirrors it. This
    // keeps the centered title truly centered, so it no longer shifts sideways
    // when the back button appears on a subpage. (Logout now lives on the
    // member profile page, so the trailing slot is purely a spacer.)
    final Widget leadingSlot = SizedBox(
      width: leadingSlotWidth,
      child: resolvedLeading == null
          ? null
          : Align(
              alignment: Alignment.centerLeft,
              child: Padding(padding: leadingPadding, child: resolvedLeading),
            ),
    );
    final Widget trailingSlot = SizedBox(width: leadingSlotWidth);

    // The title (or custom child) is locked into a fixed row pinned to the top
    // of the bar. It never moves when a subtitle appears below it, so reaching
    // a subpage no longer makes the title jump upwards.
    final Widget titleContent =
        child ??
        Text(
          title!,
          style: AppTheme.orangeBarText.copyWith(height: 1.1),
          textAlign: TextAlign.center,
        );

    final Widget titleRow = Row(
      children: [
        leadingSlot,
        Expanded(child: Align(child: titleContent)),
        trailingSlot,
      ],
    );

    // Subtitles live in their own animated slot below the title. A single
    // subtitle line's worth of height is always reserved so the bar keeps the
    // same dimensions with or without a subtitle; only a rare second-level
    // subtitle grows it further, which the AnimatedSize then eases.
    final Widget subtitleSlot = AnimatedSize(
      duration: _subtitleAnimationDuration,
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _reservedSubtitleHeight),
        child: AnimatedSwitcher(
          duration: _subtitleAnimationDuration,
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          // Hug the top of the reserved slot so the subtitle sits right under
          // the title instead of floating in the middle of the slot.
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _buildSubtitleStack(
            resolvedSubtitle,
            hasSubtitle,
            resolvedSecondary,
            hasSecondary,
          ),
        ),
      ),
    );

    // Adds the status-bar inset to the base padding so the title clears the
    // notch/camera cutout on every device instead of relying on a fixed inset.
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(24, topInset + 14, 24, 14),
      alignment: Alignment.topCenter,
      constraints: BoxConstraints(minHeight: topInset + 68),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pin the title row to an exact height (not just a minimum) so the
          // back button's tap target can never grow the row taller on a
          // subpage, which would otherwise nudge both the centered title and
          // the subtitle below it downwards.
          SizedBox(height: _titleRowHeight, child: titleRow),
          subtitleSlot,
        ],
      ),
    );
  }

  /// Builds the keyed subtitle stack consumed by the header's [AnimatedSwitcher].
  ///
  /// Returns a zero-height placeholder (keyed `none`) when there is no subtitle
  /// so the switcher fades the previous subtitle out. The key encodes the
  /// subtitle text so moving between two subpages still cross-fades.
  Widget _buildSubtitleStack(
    String? resolvedSubtitle,
    bool hasSubtitle,
    String? resolvedSecondary,
    bool hasSecondary,
  ) {
    if (!hasSubtitle && !hasSecondary) {
      return const SizedBox(width: double.infinity, key: ValueKey('none'));
    }

    return Column(
      key: ValueKey('${resolvedSubtitle ?? ''}|${resolvedSecondary ?? ''}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSubtitle) ...[
          SizedBox(height: _resolvedSubtitleSpacing()),
          // Fixed line height so spacing + line exactly fills the reserved slot
          // (_reservedSubtitleHeight); the FittedBox scales the label to fit.
          // This keeps the bar the same height with or without a subtitle, so
          // it no longer elongates when a subtitle fades in.
          SizedBox(
            height: _subtitleLineHeight,
            child: _buildSubtitleRow(resolvedSubtitle!),
          ),
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

  Widget _buildSubtitleRow(String label) {
    final mutedColor = Colors.white.withValues(alpha: 0.75);
    final labelStyle = AppTheme.orangeBarTextNormal.copyWith(
      fontSize: 18,
      height: 1.1,
      fontWeight: FontWeight.w600,
      color: mutedColor,
    );
    final resolvedIconSize = subtitleIconSize - 2;

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
            Icon(
              secondarySubtitleIcon,
              size: resolvedIconSize,
              color: mutedColor,
            ),
          if (secondarySubtitleIcon != null) const SizedBox(width: 5),
          Text(label, style: labelStyle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
