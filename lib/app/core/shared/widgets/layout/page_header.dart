import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
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
        key: const Key('page-header-back'),
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

  /// How long the title and subtitle crossfade when their content changes (e.g.
  /// switching tabs, or advancing through a feature flow). The gradient bar
  /// itself never animates and never resizes — only the content inside it fades.
  /// The fade only ever runs when the content actually changes, so a header
  /// whose title is fixed never animates on its own.
  static const Duration _contentFadeDuration = Duration(milliseconds: 260);

  /// Vertical space always reserved below the title for a single subtitle line.
  /// Reserving it even on subtitle-less pages keeps the bar (and the title's
  /// position within it) identical between a feature's root and its subpages,
  /// so the header never resizes or shifts when a subtitle fades in.
  static const double _reservedSubtitleHeight = 22;

  /// Fixed height of the single subtitle line. Together with the 2px subtitle
  /// spacing this sums to [_reservedSubtitleHeight], so the rendered subtitle
  /// exactly fills its reserved slot and never grows the bar.
  static const double _subtitleLineHeight = 20;

  /// Gap above the second-level subtitle line.
  static const double _secondarySubtitleSpacing = 3;

  /// Fixed height of the second-level subtitle line (fontSize 15 × 1.1 line
  /// height, rounded up), mirroring [_subtitleLineHeight] so it too exactly
  /// fills its reserved slot.
  static const double _secondarySubtitleLineHeight = 17;

  /// Vertical space always reserved for the optional second-level subtitle.
  /// Reserving it unconditionally — like [_reservedSubtitleHeight] does for the
  /// first line — keeps the bar at its tallest (title › subtitle › secondary)
  /// on every page, so it never resizes when a feature flow advances into a
  /// stage that adds the secondary line (e.g. the booking flow's filters →
  /// availability step).
  static const double _reservedSecondarySubtitleHeight =
      _secondarySubtitleSpacing + _secondarySubtitleLineHeight;

  /// Exact height of the title row. Comfortably clears both the title text and
  /// the trimmed back-button tap target so neither can resize the row.
  static const double _titleRowHeight = 40;

  /// A fade-only [AnimatedSwitcher] shared by the title and subtitle slots: the
  /// incoming content fades in over the outgoing one (stacked at [alignment])
  /// without moving or animating anything around it — notably never the gradient
  /// bar, whose drift this content/background separation exists to avoid.
  static Widget _crossFade({
    required Duration duration,
    required AlignmentGeometry alignment,
    required Widget child,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: alignment,
        children: <Widget>[
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      ),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final onBackPressed = onBackButtonPressed;
    // The leading slot always occupies the same width — holding the back button
    // when present, empty otherwise — and the trailing slot mirrors it, keeping
    // the centered title truly centered so it never shifts sideways when the
    // back button appears on a subpage.
    final Widget leadingSlot = SizedBox(
      width: leadingSlotWidth,
      child: onBackPressed == null
          ? null
          : Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: leadingPadding,
                child: AppBackButton(onPressed: onBackPressed),
              ),
            ),
    );

    // The title (or custom brand child) is pinned to a fixed-height row at the
    // top of the bar so it never moves when a subtitle appears below it. Only
    // the content crossfades (keyed by its identity); the gradient stays put.
    final Widget titleContent =
        child ??
        Text(
          title!,
          style: AppTheme.orangeBarText.copyWith(height: 1.1),
          textAlign: TextAlign.center,
        );
    final String titleContentKey = child != null
        ? 'brand-child'
        : 'title:${title ?? ''}';
    final Widget titleRow = Row(
      children: [
        leadingSlot,
        Expanded(
          child: Align(
            child: _crossFade(
              duration: _contentFadeDuration,
              alignment: Alignment.center,
              child: KeyedSubtree(
                key: ValueKey(titleContentKey),
                child: titleContent,
              ),
            ),
          ),
        ),
        // Mirrors the leading slot's width to keep the title centered.
        SizedBox(width: leadingSlotWidth),
      ],
    );

    // Subtitles live in their own slot below the title. Both a subtitle line and
    // a second-level subtitle line are always reserved, so the bar's height is
    // identical on every page and across every flow stage — whether zero, one,
    // or two subtitle lines are actually shown. Only the content crossfades; the
    // bar never resizes, so there is nothing to ease.
    final Widget subtitleSlot = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: _reservedSubtitleHeight + _reservedSecondarySubtitleHeight,
      ),
      child: _crossFade(
        duration: _contentFadeDuration,
        alignment: Alignment.topCenter,
        child: _buildSubtitleStack(),
      ),
    );

    // Fold the status-bar inset into the top padding so the title clears the
    // notch/cutout on every device, keeping the bar one seamless gradient.
    final topInset = MediaQuery.of(context).padding.top;
    final gradient = AppTheme.headerGradient(context);

    return Container(
      padding: EdgeInsets.fromLTRB(24, topInset + 14, 24, 14),
      alignment: Alignment.topCenter,
      constraints: BoxConstraints(minHeight: topInset + 68),
      decoration: BoxDecoration(
        // Dark mode mirrors the web sidebar gradient so the aquamarine brand
        // mark reads as genuinely aqua; light mode keeps the solid brand blue.
        gradient: gradient,
        color: gradient == null ? AppTheme.brandAccentColor(context) : null,
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
          // back button's tap target can never grow it on a subpage, which would
          // otherwise nudge the centered title and subtitle downwards.
          SizedBox(height: _titleRowHeight, child: titleRow),
          subtitleSlot,
        ],
      ),
    );
  }

  /// Builds the keyed subtitle stack consumed by the header's crossfade.
  ///
  /// Returns a zero-height placeholder (keyed `none`) when there is no subtitle
  /// so the switcher fades the previous one out; otherwise the key encodes the
  /// subtitle text so moving between two subpages still crossfades.
  Widget _buildSubtitleStack() {
    final resolvedSubtitle = subtitle?.trim();
    final hasSubtitle = resolvedSubtitle != null && resolvedSubtitle.isNotEmpty;
    final resolvedSecondary = secondarySubtitle?.trim();
    final hasSecondary =
        resolvedSecondary != null && resolvedSecondary.isNotEmpty;

    if (!hasSubtitle && !hasSecondary) {
      return const SizedBox(width: double.infinity, key: ValueKey('none'));
    }

    return Column(
      key: ValueKey('${resolvedSubtitle ?? ''}|${resolvedSecondary ?? ''}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSubtitle) ...[
          SizedBox(height: _resolvedSubtitleSpacing()),
          // Fixed line height so spacing + line exactly fills the reserved slot,
          // keeping the bar the same height with or without a subtitle.
          SizedBox(
            height: _subtitleLineHeight,
            child: _subtitleLabel(
              label: resolvedSubtitle,
              icon: subtitleIcon,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              alpha: 0.75,
              iconSize: subtitleIconSize - 2,
              iconGap: 6,
            ),
          ),
        ],
        if (hasSecondary) ...[
          const SizedBox(height: _secondarySubtitleSpacing),
          // Fixed line height so spacing + line exactly fills the reserved
          // secondary slot, matching the height the bar always carries.
          SizedBox(
            height: _secondarySubtitleLineHeight,
            child: _subtitleLabel(
              label: resolvedSecondary,
              icon: secondarySubtitleIcon,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              alpha: 0.62,
              iconSize: subtitleIconSize - 4,
              iconGap: 5,
            ),
          ),
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

  /// Shared builder for both subtitle tiers — a centered, scale-to-fit icon+label
  /// row differing only in size, weight and muted opacity.
  Widget _subtitleLabel({
    required String label,
    required IconData? icon,
    required double fontSize,
    required FontWeight fontWeight,
    required double alpha,
    required double iconSize,
    required double iconGap,
  }) {
    final color = Colors.white.withValues(alpha: alpha);
    final style = AppTheme.orangeBarTextNormal.copyWith(
      fontSize: fontSize,
      height: 1.1,
      fontWeight: fontWeight,
      color: color,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: color),
            SizedBox(width: iconGap),
          ],
          Text(label, style: style, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
