import 'package:fitnesscenter_mobile/app/core/shared/widgets/forms/inline_options_dropdown.dart';
import 'package:flutter/material.dart';

class AvailableSlotsDropdownOverlay extends StatelessWidget {
  const AvailableSlotsDropdownOverlay({
    super.key,
    required this.isVisible,
    required this.dropdownOffset,
    required this.dropdownWidth,
    required this.maxDropdownHeight,
    required this.title,
    required this.options,
    required this.filterText,
    required this.onOptionSelected,
    required this.onHide,
  });

  final bool isVisible;
  final Offset dropdownOffset;
  final double dropdownWidth;
  final double maxDropdownHeight;
  final String title;
  final List<String> options;
  final String filterText;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (isVisible)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onHide,
            ),
          ),
        Positioned(
          left: dropdownOffset.dx,
          top: dropdownOffset.dy,
          width: dropdownWidth,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            reverseDuration: const Duration(milliseconds: 200),
            child: isVisible
                ? InlineOptionsDropdown(
                    key: const ValueKey('options_dropdown'),
                    title: title,
                    options: options,
                    onOptionSelected: onOptionSelected,
                    filterText: filterText,
                    maxHeight: maxDropdownHeight,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
