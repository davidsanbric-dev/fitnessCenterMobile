import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/form_search_field.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/actions_cell_buttons/reserve_cell_button.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/date_time_cell.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_body.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_card.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_toolbar/table_toolbar.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/available_slots_dropdown_layout.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/available_slots_dropdown_overlay.dart';
import 'package:flutter/material.dart';

class AvailableSlotsForOnlineTable extends StatefulWidget {
  const AvailableSlotsForOnlineTable({
    super.key,
    required this.bookings,
    required this.disciplineOptions,
    this.selectedDiscipline,
    this.onDisciplineSelected,
    this.isLoading = false,
    this.errorMessage,
    this.onReserveBooking,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.showPagination = false,
  });

  final List<AvailableSlotDto> bookings;
  final List<String> disciplineOptions;
  final String? selectedDiscipline;
  final ValueChanged<String?>? onDisciplineSelected;
  final bool isLoading;
  final String? errorMessage;
  final void Function(AvailableSlotDto slot)? onReserveBooking;
  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;

  @override
  State<AvailableSlotsForOnlineTable> createState() =>
      _AvailableBookingsForOnlineTableState();
}

class _AvailableBookingsForOnlineTableState
    extends State<AvailableSlotsForOnlineTable> {
  final GlobalKey _disciplineFieldKey = GlobalKey();
  late final TextEditingController _disciplineSearchController;
  late final FocusNode _disciplineFocusNode;
  bool _isDropdownVisible = false;
  bool _hasTypedSinceFocus = false;

  @override
  void initState() {
    super.initState();
    _disciplineSearchController = TextEditingController(
      text: widget.selectedDiscipline?.trim() ?? '',
    );
    _disciplineFocusNode = FocusNode();
    _disciplineSearchController.addListener(_handleSearchTextChanged);
  }

  @override
  void didUpdateWidget(covariant AvailableSlotsForOnlineTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_normalized(widget.selectedDiscipline) !=
        _normalized(oldWidget.selectedDiscipline)) {
      _restoreSelectedDisciplineLabel();
    }
  }

  @override
  void dispose() {
    _disciplineSearchController.removeListener(_handleSearchTextChanged);
    _disciplineSearchController.dispose();
    _disciplineFocusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _tableRows {
    final rows = widget.bookings
        .map((slot) => slot.toOnlineRow())
        .toList(growable: false);
    final shouldShowPagination =
        widget.showPagination ||
        widget.pageNumber != null ||
        widget.pageSize != null ||
        widget.totalItems != null ||
        widget.onPageChanged != null;
    if (!shouldShowPagination) {
      return rows;
    }

    return sliceTablePage(
      rows,
      pageNumber: widget.pageNumber ?? 1,
      pageSize: widget.pageSize ?? 6,
      defaultPageSize: 6,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showAction = widget.onReserveBooking != null;
    final shouldShowPagination =
        widget.showPagination ||
        widget.pageNumber != null ||
        widget.pageSize != null ||
        widget.totalItems != null ||
        widget.onPageChanged != null;
    final pagination = shouldShowPagination
        ? TableCardPaginationConfig(
            pageNumber: widget.pageNumber,
            pageSize: widget.pageSize,
            totalItems: widget.totalItems,
            onPageChanged: widget.onPageChanged,
            defaultPageSize: 6,
          )
        : null;
    final headers = <String>['Time', 'Trainer', if (showAction) 'Action'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final dropdownLayout = resolveAvailableBookingsDropdownLayout(
          context: context,
          constraints: constraints,
          horizontalPadding: 0,
          shouldShowSheet: false,
          activeFieldKey: _disciplineFieldKey,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            TableCard(
              title: 'Available Time Slots',
              icon: Icons.event_available_outlined,
              headers: headers,
              toolbar: _buildToolbar(context),
              toolbarSpacing: 12,
              body: TableBodySection(
                data: _tableRows,
                fields: [
                  (row) =>
                      DateTimeCell(value: row['schedulingDate'] as DateTime?),
                  'trainerName',
                  if (showAction)
                    (row) => ReserveCellButton<AvailableSlotDto>.fromRow(
                      row: row,
                      onReserve: widget.onReserveBooking,
                    ),
                ],
                isLoading: widget.isLoading,
                errorMessage: widget.errorMessage,
                emptyLabel: _emptyLabel,
                wrapFields: const {'trainerName'},
              ),
              heightFactor: 0.66,
              margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              pagination: pagination,
            ),
            Positioned.fill(
              child: AvailableSlotsDropdownOverlay(
                isVisible: _isDropdownVisible,
                dropdownOffset: dropdownLayout.offset,
                dropdownWidth: dropdownLayout.width,
                maxDropdownHeight: dropdownLayout.maxHeight,
                title: 'Disciplines',
                options: widget.disciplineOptions,
                filterText: _dropdownFilterText,
                onOptionSelected: _handleDisciplineSelected,
                onHide: _hideDropdown,
              ),
            ),
          ],
        );
      },
    );
  }

  String get _emptyLabel {
    final hasSelection = widget.selectedDiscipline?.trim().isNotEmpty ?? false;
    if (!hasSelection) {
      return 'Select a discipline to view available time slots.';
    }
    return 'No available time slots for this discipline.';
  }

  Widget? _buildToolbar(BuildContext context) {
    final showFilter =
        widget.onDisciplineSelected != null ||
        widget.disciplineOptions.isNotEmpty;
    if (!showFilter) {
      return null;
    }

    final helperStyle = AppTheme.bodySmallMuted(context);
    final labelStyle = AppTheme.bodySmallLabel(context);

    return TableToolbar(
      filters: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Discipline', style: labelStyle),
              const SizedBox(height: 6),
              Container(
                key: _disciplineFieldKey,
                child: SearchField(
                  controller: _disciplineSearchController,
                  focusNode: _disciplineFocusNode,
                  hintText: 'Search for a discipline',
                  onTap: _showDropdown,
                ),
              ),
              if (widget.disciplineOptions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 6),
                  child: Text('No disciplines available.', style: helperStyle),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSearchTextChanged() {
    if (!_isDropdownVisible) {
      return;
    }
    setState(() {
      _hasTypedSinceFocus = true;
    });
  }

  void _showDropdown() {
    _disciplineFocusNode.requestFocus();
    setState(() {
      _isDropdownVisible = true;
      _hasTypedSinceFocus = false;
    });
  }

  void _hideDropdown() {
    _restoreSelectedDisciplineLabel();
    _disciplineFocusNode.unfocus();
    if (!_isDropdownVisible && !_hasTypedSinceFocus) {
      return;
    }
    setState(() {
      _isDropdownVisible = false;
      _hasTypedSinceFocus = false;
    });
  }

  void _handleDisciplineSelected(String value) {
    _setSearchText(value);
    _disciplineFocusNode.unfocus();
    setState(() {
      _isDropdownVisible = false;
      _hasTypedSinceFocus = false;
    });
    widget.onDisciplineSelected?.call(value);
  }

  void _restoreSelectedDisciplineLabel() {
    _setSearchText(widget.selectedDiscipline?.trim() ?? '');
  }

  void _setSearchText(String value) {
    if (_disciplineSearchController.text == value) {
      return;
    }
    _disciplineSearchController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String get _dropdownFilterText {
    if (!_hasTypedSinceFocus) {
      return '';
    }
    return _disciplineSearchController.text;
  }

  String _normalized(String? value) => value?.trim() ?? '';
}
