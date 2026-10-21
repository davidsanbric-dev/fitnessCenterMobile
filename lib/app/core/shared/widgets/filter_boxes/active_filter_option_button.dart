import 'package:flutter/material.dart';

import 'package:fitnesscenter_mobile/app/core/shared/widgets/filter_boxes/filter_option.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ActiveFilterOptionButton<T> extends StatelessWidget {
  const ActiveFilterOptionButton({
    super.key,
    required this.option,
    required this.isSelected,
    required this.accentColor,
    required this.onPressed,
  });

  final FilterOption<T> option;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isSelected ? accentColor : colorScheme.surface;
    final borderColor = isSelected
        ? accentColor
        : accentColor.withValues(alpha: 0.6);
    final foregroundColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: 0.8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.4),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 24, 10, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: option.iconData != null
                      ? Icon(option.iconData, size: 28, color: foregroundColor)
                      : Image.asset(
                          excludeFromSemantics: true,
                          option.iconPath!,
                          height: 28,
                          width: 28,
                          errorBuilder: (context, _, __) {
                            return Icon(
                              LucideIcons.dumbbell,
                              color: foregroundColor,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
