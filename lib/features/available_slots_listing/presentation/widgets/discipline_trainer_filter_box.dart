import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/filter_boxes/double_option_filter_box.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class DisciplineTrainerFilterBox extends StatelessWidget {
  const DisciplineTrainerFilterBox({
    super.key,
    this.accentColor = AppTheme.brandBlue,
    this.bottomSpacing = 32,
    required this.selectedMode,
    this.onChanged,
  });

  final Color accentColor;
  final double bottomSpacing;
  final DisciplineSearchMode selectedMode;
  final ValueChanged<DisciplineSearchMode>? onChanged;

  static const List<FilterOption<DisciplineSearchMode>> _options = [
    FilterOption<DisciplineSearchMode>(
      value: DisciplineSearchMode.discipline,
      label: 'By Discipline',
      iconData: LucideIcons.dumbbell,
    ),
    FilterOption<DisciplineSearchMode>(
      value: DisciplineSearchMode.trainer,
      label: 'By Trainer',
      iconData: LucideIcons.user,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DoubleOptionFilterBox<DisciplineSearchMode>(
          title: 'How do you want to search?',
          accentColor: accentColor,
          options: _options,
          selectedValue: selectedMode,
          onChanged: onChanged,
        ),
        if (bottomSpacing > 0) SizedBox(height: bottomSpacing),
      ],
    );
  }
}
