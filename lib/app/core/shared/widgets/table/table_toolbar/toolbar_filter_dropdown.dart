import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:flutter/material.dart';

class ToolbarFilterDropdown extends StatelessWidget {
  const ToolbarFilterDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.emptyHelper,
    this.helperStyle,
    this.labelStyle,
    this.maxWidth = 360,
  });

  final String label;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final String emptyHelper;
  final TextStyle? helperStyle;
  final TextStyle? labelStyle;
  final double maxWidth;

  bool get _hasOptions => options.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: selectedValue,
            isExpanded: true,
            decoration: AppTheme.filterDecoration(),
            items: options
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(growable: false),
            onChanged: _hasOptions ? onChanged : null,
          ),
          if (!_hasOptions)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Text(emptyHelper, style: helperStyle),
            ),
        ],
      ),
    );
  }
}
