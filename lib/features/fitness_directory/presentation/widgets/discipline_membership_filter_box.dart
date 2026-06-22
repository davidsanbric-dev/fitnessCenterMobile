import 'package:fitnesscenter_mobile/app/core/shared/widgets/filter_boxes/double_option_filter_box.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/types.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class DisciplineMembershipFilterBox extends StatelessWidget {
  const DisciplineMembershipFilterBox({
    super.key,
    required this.title,
    required this.accentColor,
    required this.selectedMode,
    this.onChanged,
  });

  final String title;
  final Color accentColor;
  final TrainersSearchMode selectedMode;
  final ValueChanged<TrainersSearchMode>? onChanged;

  static const List<FilterOption<TrainersSearchMode>> _options = [
    FilterOption<TrainersSearchMode>(
      value: TrainersSearchMode.discipline,
      label: 'By Discipline',
      iconData: LucideIcons.dumbbell,
    ),
    FilterOption<TrainersSearchMode>(
      value: TrainersSearchMode.membership,
      label: 'By Membership Plan',
      iconData: LucideIcons.creditCard,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DoubleOptionFilterBox<TrainersSearchMode>(
      title: title,
      accentColor: accentColor,
      options: _options,
      selectedValue: selectedMode,
      onChanged: onChanged,
    );
  }
}
