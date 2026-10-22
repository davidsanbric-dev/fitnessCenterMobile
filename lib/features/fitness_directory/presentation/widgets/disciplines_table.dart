import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/row_cells/actions_cell_buttons/check_availability_button_cell.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_body.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_card.dart';
import 'package:flutter/material.dart';

class DisciplinesTable extends StatelessWidget {
  const DisciplinesTable({
    super.key,
    required this.disciplines,
    this.isLoading = false,
    this.errorMessage,
    this.onDisciplineSelected,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.showPagination = false,
  });

  final List<Map<String, dynamic>> disciplines;
  final bool isLoading;
  final String? errorMessage;
  final void Function(Map<String, dynamic> row)? onDisciplineSelected;
  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;

  @override
  Widget build(BuildContext context) {
    final showAction = onDisciplineSelected != null;
    final fields = [
      'name',
      if (showAction)
        (row) => CheckAvailabilityButtonCell(
          row: row,
          onCheckAvailability: onDisciplineSelected,
          height: 34,
        ),
    ];
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

    return TableCard(
      heightFactor: 0.65,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      toolbarSpacing: 0,
      body: TableBodySection(
        data: disciplines,
        fields: fields,
        isLoading: isLoading,
        errorMessage: errorMessage,
        emptyLabel: AppLocalizations.of(context).emptyNoDisciplines,
        wrapFields: const {'name'},
      ),
      pagination: pagination,
    );
  }
}
