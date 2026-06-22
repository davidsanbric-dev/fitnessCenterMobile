import 'package:flutter/material.dart';

import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/filter_boxes/active_filter_option_button.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/filter_boxes/filter_option.dart';

export 'package:fitnesscenter_mobile/app/core/shared/widgets/filter_boxes/filter_option.dart';

typedef TripleFilterOptionButtonBuilder<T> =
    Widget Function(
      BuildContext context,
      FilterOption<T> option, {
      required bool isSelected,
      required Color accentColor,
      required VoidCallback onPressed,
    });

class TripleOptionFilterBox<T> extends StatelessWidget {
  const TripleOptionFilterBox({
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
    this.optionsSpacing = 16,
  }) : assert(
         options.length == 3,
         'TripleOptionFilterBox requires exactly 3 options',
       );

  final String title;
  final Color accentColor;
  final List<FilterOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T>? onChanged;
  final TripleFilterOptionButtonBuilder<T>? optionBuilder;
  final EdgeInsetsGeometry padding;
  final EdgeInsets Function(int index, int total)? optionPaddingBuilder;
  final BoxDecoration? decoration;
  final double optionsSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topOptions = options.take(2).toList(growable: false);
    final bottomOption = options.last;

    return Container(
      decoration:
          decoration ??
          BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor),
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
            SizedBox(height: optionsSpacing),
            Row(
              children: topOptions
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
            SizedBox(height: optionsSpacing),
            Padding(
              padding:
                  optionPaddingBuilder?.call(2, options.length) ??
                  _defaultOptionPadding(2, options.length),
              child: SizedBox(
                width: double.infinity,
                child: optionBuilder != null
                    ? optionBuilder!(
                        context,
                        bottomOption,
                        isSelected:
                            selectedValue != null &&
                            bottomOption.value == selectedValue,
                        accentColor: accentColor,
                        onPressed: () => onChanged?.call(bottomOption.value),
                      )
                    : ActiveFilterOptionButton<T>(
                        option: bottomOption,
                        isSelected:
                            selectedValue != null &&
                            bottomOption.value == selectedValue,
                        accentColor: accentColor,
                        onPressed: () => onChanged?.call(bottomOption.value),
                      ),
              ),
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
  if (index == 1) {
    return const EdgeInsets.only(left: 18);
  }
  if (index == total - 1) {
    return EdgeInsets.zero;
  }
  return EdgeInsets.zero;
}
