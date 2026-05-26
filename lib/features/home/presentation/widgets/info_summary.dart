import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class InfoSummaryTab {
  const InfoSummaryTab({required this.label, required this.description});

  final String label;
  final String description;
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
    const accentColor = AppTheme.brandBlue;
    final tab = tabs[_selectedTab.clamp(0, tabs.length - 1)];
    final cardTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w500,
      fontSize: 13,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(tabs.length * 2 - 1, (index) {
            if (index.isOdd) {
              return Container(width: 1, height: 32, color: accentColor);
            }
            final tabIndex = index ~/ 2;
            final tabData = tabs[tabIndex];
            final isActive = tabIndex == _selectedTab;
            final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isActive ? Colors.black : Colors.grey.shade500,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            );
            return Expanded(
              child: InkWell(
                onTap: () => _handleTabSelected(tabIndex),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Text(
                        tabData.label,
                        style: textStyle,
                        textAlign: TextAlign.center,
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
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: Colors.grey.shade300),
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
                      child: widget.iconData != null
                          ? Icon(widget.iconData, color: accentColor, size: 28)
                          : Image.asset(
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
                  onPressed: widget.onActionPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    widget.actionLabel,
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
