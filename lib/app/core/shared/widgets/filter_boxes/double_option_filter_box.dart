import 'package:flutter/material.dart';

import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/filter_boxes/active_filter_option_button.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/filter_boxes/filter_option.dart';

export 'package:portfolio_mobile_app/app/core/shared/widgets/filter_boxes/filter_option.dart';

typedef FilterOptionButtonBuilder<T> =
    Widget Function(
      BuildContext context,
      FilterOption<T> option, {
      required bool isSelected,
      required Color accentColor,
      required VoidCallback onPressed,
    });

class DoubleOptionFilterBox<T> extends StatelessWidget {
  const DoubleOptionFilterBox({
    super.key,
    required this.title,
    required this.accentColor,
    required this.options,
    required this.selectedValue,
    this.onChanged,
    this.optionBuilder,
    this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
    this.optionPaddingBuilder,
    this.decoration,
  }) : assert(
         options.length == 2,
         'DoubleOptionFilterBox requires exactly 2 options',
       );

  final String title;
  final Color accentColor;
  final List<FilterOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T>? onChanged;
  final FilterOptionButtonBuilder<T>? optionBuilder;
  final EdgeInsetsGeometry padding;
  final EdgeInsets Function(int index, int total)? optionPaddingBuilder;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          decoration ??
          BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.titleMediumEmphasis(context)),
            const SizedBox(height: 16),
            Row(
              children: options
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected =
                        selectedValue != null && option.value == selectedValue;
                    final optionPadding =
                        optionPaddingBuilder?.call(index, options.length) ??
                        _defaultOptionPadding(index, options.length);

                    return Expanded(
                      child: Padding(
                        padding: optionPadding,
                        child: optionBuilder != null
                            ? optionBuilder!(
                                context,
                                option,
                                isSelected: isSelected,
                                accentColor: accentColor,
                                onPressed: () => onChanged?.call(option.value),
                              )
                            : ActiveFilterOptionButton<T>(
                                option: option,
                                isSelected: isSelected,
                                accentColor: accentColor,
                                onPressed: () => onChanged?.call(option.value),
                              ),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

EdgeInsets _defaultOptionPadding(int index, int total) {
  if (index == 0) {
    return const EdgeInsets.only(right: 12);
  }
  if (index == total - 1) {
    return const EdgeInsets.only(left: 18);
  }
  return EdgeInsets.zero;
}
