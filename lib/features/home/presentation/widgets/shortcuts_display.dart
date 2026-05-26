import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ShortcutCardData {
  const ShortcutCardData({
    required this.title,
    this.iconPath,
    this.iconData,
    this.iconSize = 28,
    this.onTap,
  }) : assert(
         iconPath != null || iconData != null,
         'Provide either iconPath or iconData',
       );

  final String title;
  final String? iconPath;
  final IconData? iconData;
  final double iconSize;
  final VoidCallback? onTap;
}

class ShortcutsDisplay extends StatelessWidget {
  const ShortcutsDisplay({
    super.key,
    required this.shortcuts,
    this.spacing = 12,
  });

  final List<ShortcutCardData> shortcuts;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (shortcuts.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Keep a consistent three-column layout across screen sizes.
        const crossAxisCount = 3;
        final itemWidth =
            (width - spacing * (crossAxisCount - 1)) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: shortcuts
              .map(
                (shortcut) => SizedBox(
                  width: itemWidth,
                  child: _ShortcutCard(shortcut: shortcut),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({required this.shortcut});

  final ShortcutCardData shortcut;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: -1,
          child: Container(
            height: 12,
            decoration: const BoxDecoration(
              color: AppTheme.brandBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: shortcut.onTap,
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.brandBlue.withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(7, 8, 6, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shortcut.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: shortcut.iconData != null
                            ? Icon(
                                shortcut.iconData,
                                size: shortcut.iconSize,
                                color: AppTheme.brandBlue,
                              )
                            : Image.asset(
                                shortcut.iconPath!,
                                height: shortcut.iconSize,
                                width: shortcut.iconSize,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    LucideIcons.dumbbell,
                                    size: shortcut.iconSize,
                                    color: AppTheme.brandBlue,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
