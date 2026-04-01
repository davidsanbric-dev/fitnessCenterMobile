import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/form_search_field.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/actions_cell_buttons/check_availability_button_cell.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_body.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_card.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_toolbar/toolbar_filter_dropdown.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_toolbar/table_toolbar.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';
import 'package:flutter/material.dart';

class TrainersTable extends StatelessWidget {
  const TrainersTable({
    super.key,
    required this.trainers,
    required this.mode,
    this.isLoading = false,
    this.errorMessage,
    this.onTrainerSelected,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.showPagination = false,
    this.disciplineOptions = const [],
    this.selectedDisciplineLabel,
    this.onDisciplineSelected,
    this.onDisciplineTap,
    this.disciplineSearchController,
    this.disciplineFocusNode,
    this.disciplineFieldKey,
    this.locationOptions = const [],
    this.selectedLocationLabel,
    this.onLocationSelected,
    this.disciplineFilterLabel = 'Discipline',
    this.locationFilterLabel = 'Club',
    this.emptyLabel = 'No trainers available.',
  });

  final List<Map<String, dynamic>> trainers;
  final TrainersSearchMode mode;
  final bool isLoading;
  final String? errorMessage;
  final void Function(Map<String, dynamic> row)? onTrainerSelected;
  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;
  final List<String> disciplineOptions;
  final String? selectedDisciplineLabel;
  final ValueChanged<String?>? onDisciplineSelected;
  final VoidCallback? onDisciplineTap;
  final TextEditingController? disciplineSearchController;
  final FocusNode? disciplineFocusNode;
  final Key? disciplineFieldKey;
  final List<String> locationOptions;
  final String? selectedLocationLabel;
  final ValueChanged<String?>? onLocationSelected;
  final String disciplineFilterLabel;
  final String locationFilterLabel;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final isDiscipline = mode == TrainersSearchMode.discipline;
    // final headerLabel = isDiscipline
    //     ? 'Profesional / Previsión'
    //     : 'Profesional / Especialidad';
    final fieldPair = isDiscipline
        ? ['trainerName', 'membershipName']
        : ['trainerName', 'disciplineName'];
    final showAction = onTrainerSelected != null;
    final toolbar = _buildToolbar(context);
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

    // final headers = [headerLabel, if (showAction) 'Acción'];
    final fields = [
      fieldPair,
      if (showAction)
        (row) => CheckAvailabilityButtonCell(
          row: row,
          onCheckAvailability: onTrainerSelected,
        ),
    ];

    return TableCard(
      icon: Icons.directions_run,
      // headers: headers,
      heightFactor: 0.71,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      toolbarSpacing: 0,
      toolbar: toolbar,
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

  Widget? _buildToolbar(BuildContext context) {
    final showDisciplineFilter =
        onDisciplineSelected != null ||
        onDisciplineTap != null ||
        disciplineOptions.isNotEmpty;
    final showLocationFilter =
        onLocationSelected != null || locationOptions.isNotEmpty;
    final hasToolbar = showDisciplineFilter || showLocationFilter;
    if (!hasToolbar) {
      return null;
    }

    final helperStyle = AppTheme.bodySmallMuted(context);
    final labelStyle = AppTheme.bodySmallLabel(context);

    return TableToolbar(
      padding: const EdgeInsets.only(bottom: 4),
      filters: [
        _buildDisciplineFilter(
          helperStyle: helperStyle,
          labelStyle: labelStyle,
        ),
        ToolbarFilterDropdown(
          label: locationFilterLabel,
          options: locationOptions,
          selectedValue: _resolveSelectedLabel(
            selectedLocationLabel,
            locationOptions,
          ),
          onChanged: locationOptions.isNotEmpty ? onLocationSelected : null,
          emptyHelper: 'No clubs available.',
          helperStyle: helperStyle,
          labelStyle: labelStyle,
        ),
      ],
    );
  }

  Widget _buildDisciplineFilter({
    TextStyle? helperStyle,
    TextStyle? labelStyle,
  }) {
    final hasOptions = disciplineOptions.isNotEmpty;
    final controller = disciplineSearchController;
    final focusNode = disciplineFocusNode;
    final canUseInlineSearch = controller != null && focusNode != null;
    final resolvedLabel = _resolveSelectedLabel(
      selectedDisciplineLabel,
      disciplineOptions,
    );

    if (!canUseInlineSearch) {
      return ToolbarFilterDropdown(
        label: disciplineFilterLabel,
        options: disciplineOptions,
        selectedValue: resolvedLabel,
        onChanged: hasOptions ? onDisciplineSelected : null,
        emptyHelper: 'No options available for filtering.',
        helperStyle: helperStyle,
        labelStyle: labelStyle,
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(disciplineFilterLabel, style: labelStyle),
          const SizedBox(height: 6),
          Container(
            key: disciplineFieldKey,
            child: SearchField(
              controller: controller,
              focusNode: focusNode,
              hintText: 'Search for a discipline',
              onTap: hasOptions ? onDisciplineTap : null,
            ),
          ),
          if (!hasOptions)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Text(
                'No options available for filtering.',
                style: helperStyle,
              ),
            ),
        ],
      ),
    );
  }

  String? _resolveSelectedLabel(String? label, List<String> options) {
    final resolved = label?.trim();
    if (resolved == null || resolved.isEmpty) {
      return null;
    }
    return options.contains(resolved) ? resolved : null;
  }
}
