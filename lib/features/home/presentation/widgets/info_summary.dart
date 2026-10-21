import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';

class InfoSummaryTab {
  const InfoSummaryTab({
    required this.label,
    required this.description,
    this.iconData,
    this.actionLabel,
    this.onActionPressed,
  });

  final String label;
  final String description;

  /// Optional icon shown beside the tab label and in the summary circle while
  /// this tab is active.
  final IconData? iconData;

  /// When set, overrides the widget-level [InfoSummary.actionLabel] for this
  /// specific tab. Falls back to the widget-level value when null.
  final String? actionLabel;

  /// When set, overrides [InfoSummary.onActionPressed] for this tab.
  final VoidCallback? onActionPressed;
}

class InfoSummary extends StatefulWidget {
  const InfoSummary({
    super.key,
    required this.tabs,
    this.iconAsset,
    this.iconData,
    this.actionLabel = 'View all',
    this.onActionPressed,
  }) : assert(tabs.length >= 2, 'Provide at least two tabs'),
       assert(
         iconAsset != null || iconData != null,
         'Provide either iconAsset or iconData',
       );

  final List<InfoSummaryTab> tabs;
  final String? iconAsset;
  final IconData? iconData;
  final String actionLabel;
  final VoidCallback? onActionPressed;

  @override
  State<InfoSummary> createState() => _InfoSummaryState();
}

class _InfoSummaryState extends State<InfoSummary> {
  int _selectedTab = 0;

  void _handleTabSelected(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.primary;
    final tab = tabs[_selectedTab.clamp(0, tabs.length - 1)];
    final cardTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.75),
      fontWeight: FontWeight.w500,
      fontSize: 13,
    );

    final resolvedActionLabel = tab.actionLabel ?? widget.actionLabel;
    final resolvedActionPressed = tab.onActionPressed ?? widget.onActionPressed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(tabs.length * 2 - 1, (index) {
            if (index.isOdd) {
              // Neutral --border separator (web uses one border token, not the
              // bright primary, for dividers).
              return Container(
                width: 1,
                height: 32,
                color: AppTheme.borderColor(context),
              );
            }
            final tabIndex = index ~/ 2;
            final tabData = tabs[tabIndex];
            final isActive = tabIndex == _selectedTab;
            final textStyle = theme.textTheme.titleMedium?.copyWith(
              color: isActive
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            );
            final labelColor = textStyle?.color;
            return Expanded(
              child: InkWell(
                onTap: () => _handleTabSelected(tabIndex),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tabData.iconData != null) ...[
                              Icon(
                                tabData.iconData,
                                size: 15,
                                color: labelColor,
                              ),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              tabData.label,
                              style: textStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isActive ? accentColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: accentColor, width: 2.4),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: (tab.iconData ?? widget.iconData) != null
                          ? Icon(
                              tab.iconData ?? widget.iconData,
                              color: accentColor,
                              size: 28,
                            )
                          : Image.asset(
                              excludeFromSemantics: true,
                              widget.iconAsset!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  LucideIcons.dumbbell,
                                  color: accentColor,
                                );
                              },
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(tab.description, style: cardTextStyle),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                height: 1.2,
                color: accentColor.withValues(alpha: 0.3),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: resolvedActionPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    resolvedActionLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
