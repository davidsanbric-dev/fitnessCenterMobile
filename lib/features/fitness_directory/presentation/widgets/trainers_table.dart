import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/actions_cell_buttons/check_availability_button_cell.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/actions_cell_buttons/trainer_info_button_cell.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_body.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_card.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class TrainersTable extends StatelessWidget {
  const TrainersTable({
    super.key,
    required this.trainers,
    required this.mode,
    this.isLoading = false,
    this.errorMessage,
    this.onTrainerSelected,
    this.onTrainerInfo,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.showPagination = false,
    this.emptyLabel = 'No trainers available.',
  });

  final List<Map<String, dynamic>> trainers;
  final TrainersSearchMode mode;
  final bool isLoading;
  final String? errorMessage;
  final void Function(Map<String, dynamic> row)? onTrainerSelected;
  final void Function(Map<String, dynamic> row)? onTrainerInfo;
  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final isDiscipline = mode == TrainersSearchMode.discipline;
    // First cell stacks the trainer name, their specialty (discipline or
    // membership plan) and their club, since the club is no longer a filter.
    final fieldPair = isDiscipline
        ? ['trainerName', 'disciplineName', 'locationName']
        : ['trainerName', 'membershipName', 'locationName'];
    final showAction = onTrainerSelected != null;
    final showInfo = onTrainerInfo != null;
    final shouldShowPagination =
        showPagination ||
        pageNumber != null ||
        pageSize != null ||
        totalItems != null ||
        onPageChanged != null;
    final pagination = shouldShowPagination
        ? TableCardPaginationConfig(
            pageNumber: pageNumber,
            pageSize: pageSize,
            totalItems: totalItems,
            onPageChanged: onPageChanged,
          )
        : null;

    final fields = [
      fieldPair,
      // A single action column holding the info button (profile dialog) beside
      // the existing Schedule availability button, so the name/specialty/club
      // cell keeps its width instead of being squeezed by a third column.
      if (showInfo || showAction)
        (row) => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showInfo)
              TrainerInfoButtonCell(row: row, onInfo: onTrainerInfo),
            if (showInfo && showAction) const SizedBox(width: 8),
            if (showAction)
              Flexible(
                child: CheckAvailabilityButtonCell(
                  row: row,
                  onCheckAvailability: onTrainerSelected,
                ),
              ),
          ],
        ),
    ];

    return TableCard(
      icon: LucideIcons.user,
      heightFactor: 0.65,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      toolbarSpacing: 0,
      body: TableBodySection(
        data: trainers,
        fields: fields,
        isLoading: isLoading,
        errorMessage: errorMessage,
        emptyLabel: emptyLabel,
        wrapFields: const {'trainerName'},
      ),
      pagination: pagination,
    );
  }
}
