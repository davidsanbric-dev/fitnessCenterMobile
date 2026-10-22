import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
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

  static List<FilterOption<TrainersSearchMode>> _options(
    BuildContext context,
  ) => [
    FilterOption<TrainersSearchMode>(
      value: TrainersSearchMode.discipline,
      label: AppLocalizations.of(context).filterByDiscipline,
      iconData: LucideIcons.dumbbell,
    ),
    FilterOption<TrainersSearchMode>(
      value: TrainersSearchMode.membership,
      label: AppLocalizations.of(context).filterByPlan,
      iconData: LucideIcons.creditCard,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DoubleOptionFilterBox<TrainersSearchMode>(
      title: title,
      accentColor: accentColor,
      options: _options(context),
      selectedValue: selectedMode,
      onChanged: onChanged,
    );
  }
}
