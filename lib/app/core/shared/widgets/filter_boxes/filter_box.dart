import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/filter_boxes/filter_box_option_button.dart';
import 'package:flutter/material.dart';

class FilterBox extends StatelessWidget {
  const FilterBox({
    super.key,
    required this.title,
    required this.accentColor,
    required this.options,
    required this.onOptionSelected,
    this.emptyStateMessage,
    this.isLoading = false,
  });

  final String title;
  final Color accentColor;
  final List<FilterBoxOptionData> options;
  final ValueChanged<String> onOptionSelected;
  final String? emptyStateMessage;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          emptyStateMessage ?? 'No hay opciones disponibles por el momento.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Text(title, style: AppTheme.titleMediumEmphasis(context)),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: accentColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: FilterBoxOptionButton(
                label: option.label,
                iconData: option.iconData,
                onTap: () => onOptionSelected(option.label),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class FilterBoxOptionData {
  const FilterBoxOptionData({required this.label, required this.iconData});

  final String label;
  final IconData iconData;
}
