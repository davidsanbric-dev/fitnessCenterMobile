import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/diagnostics/runtime_diagnostics.dart';

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
    dynamic icon, {
    required bool isSelected,
    double size = 24,
  }) {
    if (icon is IconData) {
      return Icon(
        icon,
        color: isSelected ? AppTheme.brandBlue : Colors.grey[800],
        size: size,
      );
    }
    if (icon is String) {
      return Image.asset(
        icon,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          RuntimeDiagnostics.missingAsset(
            icon,
            scope: 'MainBottomNavBar',
            error: error,
          );
          return Icon(
            Icons.image_not_supported_outlined,
            color: isSelected ? AppTheme.brandBlue : Colors.grey[800],
            size: size,
          );
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

        return PopupMenuItem<int>(
          value: menuIndex,
          child: Row(
            children: [
              _buildIconWidget(
                menuItem['icon'],
                isSelected: isSelected,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                menuItem['label'] as String,
                style: TextStyle(
                  color: isSelected ? AppTheme.brandBlue : Colors.grey.shade800,
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
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
              Icons.menu,
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
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: _buildIconWidget(
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
                        border: Border.all(color: AppTheme.brandBlue, width: 2),
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
                    color: isMenuSelected
                        ? AppTheme.brandBlue
                        : Colors.grey[800],
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
          final iconWidget = _buildIconWidget(icon, isSelected: isSelected);

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
                    border: Border.all(color: AppTheme.brandBlue, width: 2),
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
                    color: isSelected ? AppTheme.brandBlue : Colors.grey[800],
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
