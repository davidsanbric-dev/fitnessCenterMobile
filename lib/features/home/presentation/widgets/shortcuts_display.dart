import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';

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
                  child: SizedBox.square(
                    dimension: itemWidth,
                    child: _ShortcutCard(shortcut: shortcut),
                  ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.primary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: -1,
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
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
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor(context)),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shortcut.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: shortcut.iconData != null
                            ? Icon(
                                shortcut.iconData,
                                size: shortcut.iconSize,
                                color: accent,
                              )
                            : Image.asset(
                                excludeFromSemantics: true,
                                shortcut.iconPath!,
                                height: shortcut.iconSize,
                                width: shortcut.iconSize,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    LucideIcons.dumbbell,
                                    size: shortcut.iconSize,
                                    color: accent,
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
