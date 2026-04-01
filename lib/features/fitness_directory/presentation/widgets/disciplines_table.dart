import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/actions_cell_buttons/check_availability_button_cell.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_body.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_card.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_toolbar/toolbar_filter_dropdown.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_toolbar/table_toolbar.dart';
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
    this.locationOptions = const [],
    this.selectedLocationLabel,
    this.onLocationSelected,
    this.locationFilterLabel = 'Club',
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
  final List<String> locationOptions;
  final String? selectedLocationLabel;
  final ValueChanged<String?>? onLocationSelected;
  final String locationFilterLabel;

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
    final toolbar = _buildToolbar(context);

    return TableCard(
      heightFactor: 0.65,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      toolbarSpacing: 0,
      toolbar: toolbar,
      body: TableBodySection(
        data: disciplines,
        fields: fields,
        isLoading: isLoading,
        errorMessage: errorMessage,
        emptyLabel: 'No disciplines available.',
        wrapFields: const {'name'},
      ),
      pagination: pagination,
    );
  }

  Widget? _buildToolbar(BuildContext context) {
    final showLocationFilter =
        onLocationSelected != null || locationOptions.isNotEmpty;
    if (!showLocationFilter) {
      return null;
    }

    final selectedValue = _resolveSelectedLocationLabel();
    final hasOptions = locationOptions.isNotEmpty;
    final helperStyle = AppTheme.bodySmallMuted(context);
    final labelStyle = AppTheme.bodySmallLabel(context);

    return TableToolbar(
      filters: [
        ToolbarFilterDropdown(
          label: locationFilterLabel,
          options: locationOptions,
          selectedValue: selectedValue,
          onChanged: hasOptions ? onLocationSelected : null,
          emptyHelper: 'No clubs available.',
          helperStyle: helperStyle,
          labelStyle: labelStyle,
        ),
      ],
    );
  }

  String? _resolveSelectedLocationLabel() {
    final label = selectedLocationLabel?.trim();
    if (label == null || label.isEmpty) {
      return null;
    }
    return locationOptions.contains(label) ? label : null;
  }
}
