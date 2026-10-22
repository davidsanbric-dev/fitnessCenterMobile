import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/filter_boxes/double_option_filter_box.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class DisciplineTrainerFilterBox extends StatelessWidget {
  const DisciplineTrainerFilterBox({
    super.key,
    this.accentColor,
    this.bottomSpacing = 32,
    required this.selectedMode,
    this.onChanged,
  });

  final Color? accentColor;
  final double bottomSpacing;
  final DisciplineSearchMode selectedMode;
  final ValueChanged<DisciplineSearchMode>? onChanged;

  static List<FilterOption<DisciplineSearchMode>> _options(
    BuildContext context,
  ) => [
    FilterOption<DisciplineSearchMode>(
      value: DisciplineSearchMode.discipline,
      label: AppLocalizations.of(context).filterByDiscipline,
      iconData: LucideIcons.dumbbell,
    ),
    FilterOption<DisciplineSearchMode>(
      value: DisciplineSearchMode.trainer,
      label: AppLocalizations.of(context).filterByTrainer,
      iconData: LucideIcons.user,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final resolvedAccent = accentColor ?? Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DoubleOptionFilterBox<DisciplineSearchMode>(
          title: AppLocalizations.of(context).filterHowToSearch,
          accentColor: resolvedAccent,
          options: _options(context),
          selectedValue: selectedMode,
          onChanged: onChanged,
        ),
        if (bottomSpacing > 0) SizedBox(height: bottomSpacing),
      ],
    );
  }
}
