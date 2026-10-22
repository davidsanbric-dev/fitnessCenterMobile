import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/row_cells/actions_cell_buttons/reserve_cell_button.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/row_cells/date_time_cell.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_body.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_card.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class AvailableSlotsByCapabilityTable extends StatelessWidget {
  const AvailableSlotsByCapabilityTable({
    super.key,
    required this.bookings,
    this.isLoading = false,
    this.errorMessage,
    this.subtitle,
    this.filterSummary,
    this.onReserveBooking,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.showPagination = false,
  });

  final List<Map<String, dynamic>> bookings;
  final bool isLoading;
  final String? errorMessage;
  final String? subtitle;
  final List<TableFiltersSummaryItemData>? filterSummary;
  final void Function(AvailableSlotByCapabilityDto slot)? onReserveBooking;
  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;

  @override
  Widget build(BuildContext context) {
    final headers = <String>[
      'Time',
      AppLocalizations.of(context).commonTrainerDiscipline,
      // AppLocalizations.of(context).commonBranch,
      if (onReserveBooking != null) AppLocalizations.of(context).commonAction,
    ];

    final summary = _buildFiltersSummary();
    final toolbarContent = summary == null && subtitle == null
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (summary != null) summary,
              if (summary != null && subtitle != null)
                const SizedBox(height: 8),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppTheme.brandAccentColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );
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
      title: AppLocalizations.of(context).slotAvailability,
      icon: LucideIcons.calendarCheck,
      headers: headers,
      toolbar: toolbarContent,
      heightFactor: 0.7,
      body: TableBodySection(
        data: bookings,
        fields: [
          (row) => DateTimeCell(value: row['schedulingDate'] as DateTime?),
          const ['trainer', 'discipline'],
          if (onReserveBooking != null)
            (row) => ReserveCellButton<AvailableSlotByCapabilityDto>.fromRow(
              key: ValueKey(
                'reserve-slot-${row['slotAssignmentCode'] ?? row['schedulingDate']}',
              ),
              row: row,
              onReserve: onReserveBooking,
            ),
        ],
        isLoading: isLoading,
        errorMessage: errorMessage,
        emptyLabel: AppLocalizations.of(context).emptyNoAvailClassOption,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      pagination: pagination,
    );
  }

  Widget? _buildFiltersSummary() {
    return TableFiltersSummary.maybe(items: filterSummary);
  }
}
