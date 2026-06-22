import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// A single bottom-nav entry. A leaf entry selects [index] (and optionally
/// navigates to a named [route]); an entry with [menuItems] is a dropup parent
/// whose children are themselves [NavBarItem]s.
class NavBarItem {
  const NavBarItem({
    required this.icon,
    required this.label,
    required this.index,
    this.route,
    this.menuItems,
    this.padding,
  });

  /// Either an [IconData] or an asset-path [String].
  final Object icon;
  final String label;
  final int index;

  /// Optional named route pushed via `Get.offNamed` on tap.
  final String? route;

  /// When non-null, this entry renders as a dropup menu of sub-entries instead
  /// of a leaf tab.
  final List<NavBarItem>? menuItems;
  final EdgeInsets? padding;
}

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;
  final List<NavBarItem> items;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    required this.items,
  });

  Widget _buildIconWidget(
    BuildContext context,
    Object icon, {
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
    List<NavBarItem> menuItems,
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
        final isSelected = menuItem.index == currentIndex;

        final colorScheme = Theme.of(context).colorScheme;
        return PopupMenuItem<int>(
          value: menuItem.index,
          child: Row(
            children: [
              _buildIconWidget(
                context,
                menuItem.icon,
                isSelected: isSelected,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                menuItem.label,
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

    onTap?.call(selectedIndex);

    final selectedItem = menuItems.firstWhere(
      (item) => item.index == selectedIndex,
    );
    final route = selectedItem.route;
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
          final menuItems = item.menuItems;
          if (menuItems != null) {
            NavBarItem? activeMenuItem;
            for (final menuItem in menuItems) {
              if (menuItem.index == currentIndex) {
                activeMenuItem = menuItem;
                break;
              }
            }
            final isMenuSelected = activeMenuItem != null;
            final baseLabel = item.label;
            final activeLabel = activeMenuItem?.label;
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
                              activeMenuItem.icon,
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
                      padding: item.padding ?? const EdgeInsets.all(8),
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

          final targetIndex = item.index;
          final isSelected = targetIndex == currentIndex;

          final route = item.route;
          final iconWidget = _buildIconWidget(
            context,
            item.icon,
            isSelected: isSelected,
          );

          final navItemWidget = GestureDetector(
            onTap: () {
              onTap?.call(targetIndex);
              if (route != null) Get.offNamed(route); // Navigation with GetX
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: item.padding ?? const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2),
                  ),
                  child: iconWidget,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
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
