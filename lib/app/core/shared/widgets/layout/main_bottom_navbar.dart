import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final List<Map<String, dynamic>> items;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    required this.items,
  });

  Widget _buildIconWidget(
    BuildContext context,
    dynamic icon, {
    required bool isSelected,
    double size = 24,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.7);
    if (icon is IconData) {
      return Icon(icon, color: iconColor, size: size);
    }
    if (icon is String) {
      return Image.asset(
        icon,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          return Icon(LucideIcons.imageOff, color: iconColor, size: size);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _showDropupMenu(
    BuildContext context,
    List<Map<String, dynamic>> menuItems,
    int currentIndex,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final button = context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final selectedIndex = await showMenu<int>(
      context: context,
      position: position,
      items: menuItems.map((menuItem) {
        final menuIndex = menuItem['index'] as int;
        final isSelected = menuIndex == currentIndex;

        final colorScheme = Theme.of(context).colorScheme;
        return PopupMenuItem<int>(
          value: menuIndex,
          child: Row(
            children: [
              _buildIconWidget(
                context,
                menuItem['icon'],
                isSelected: isSelected,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                menuItem['label'] as String,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    if (selectedIndex == null) {
      return;
    }

    if (onTap != null) {
      onTap!(selectedIndex);
    }

    final selectedItem = menuItems.firstWhere(
      (item) => item['index'] == selectedIndex,
    );
    final route = selectedItem['route'] as String?;
    if (route != null) {
      await Get.offNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.primary;
    final labelMuted = colorScheme.onSurface.withValues(alpha: 0.7);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final menuItems = item['menuItems'] as List<Map<String, dynamic>>?;
          if (menuItems != null) {
            Map<String, dynamic>? activeMenuItem;
            for (final menuItem in menuItems) {
              if (menuItem['index'] == currentIndex) {
                activeMenuItem = menuItem;
                break;
              }
            }
            final isMenuSelected = activeMenuItem != null;
            final baseLabel = item['label'] as String? ?? 'Menu';
            final activeLabel = activeMenuItem?['label'] as String?;
            final label = activeLabel == null
                ? baseLabel
                : '$baseLabel/$activeLabel';
            final menuIcon = _buildIconWidget(
              context,
              LucideIcons.menu,
              isSelected: isMenuSelected,
            );
            final menuIconWithBadge = activeMenuItem == null
                ? menuIcon
                : Stack(
                    clipBehavior: Clip.none,
                    children: [
                      menuIcon,
                      Positioned(
                        right: -18,
                        top: -18,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: accent, width: 2),
                          ),
                          child: Center(
                            child: _buildIconWidget(
                              context,
                              activeMenuItem['icon'],
                              isSelected: true,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );

            final menuItemWidget = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (buttonContext) => GestureDetector(
                    onTap: () =>
                        _showDropupMenu(buttonContext, menuItems, currentIndex),
                    child: Container(
                      padding: item['padding'] ?? const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accent, width: 2),
                      ),
                      child: menuIconWithBadge,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isMenuSelected ? accent : labelMuted,
                  ),
                ),
              ],
            );
            return Expanded(child: menuItemWidget);
          }

          final dynamic override = item['index'];
          final int targetIndex = override is int ? override : index;
          final isSelected = targetIndex == currentIndex;

          final icon = item['icon'];
          final route = item['route'] as String?;
          final iconWidget = _buildIconWidget(
            context,
            icon,
            isSelected: isSelected,
          );

          final navItemWidget = GestureDetector(
            onTap: () {
              // Allow items to override the logical tab index so display order can differ.
              if (onTap != null) onTap!(targetIndex);
              if (route != null) Get.offNamed(route); // Navigation with GetX
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: item['padding'] ?? const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2),
                  ),
                  child: iconWidget,
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? accent : labelMuted,
                  ),
                ),
              ],
            ),
          );
          return Expanded(child: navItemWidget);
        }),
      ),
    );
  }
}
