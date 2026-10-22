import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/row_cells/actions_cell_buttons/reserve_cell_button.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/row_cells/date_time_cell.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_body.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_card.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class AvailableBookingsByTrainerTable extends StatelessWidget {
  const AvailableBookingsByTrainerTable({
    super.key,
    required this.bookings,
    this.isLoading = false,
    this.errorMessage,
    this.filterSummary,
    this.onReserveBooking,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.showPagination = false,
    this.outerPadding = const EdgeInsets.fromLTRB(16, 10, 16, 24),
  });

  final List<Map<String, dynamic>> bookings;
  final bool isLoading;
  final String? errorMessage;
  final List<TableFiltersSummaryItemData>? filterSummary;
  final void Function(AvailableSlotDto slot)? onReserveBooking;
  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;
  final EdgeInsetsGeometry outerPadding;

  @override
  Widget build(BuildContext context) {
    final showReserveAction = onReserveBooking != null;
    // final headers = <String>[
    //   AppLocalizations.of(context).commonSchedule,
    //   showReserveAction ? AppLocalizations.of(context).commonAction : AppLocalizations.of(context).commonServiceCentre,
    // ];

    final summary = TableFiltersSummary.maybe(items: filterSummary);
    final toolbarContent = summary == null
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [summary],
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

    return Padding(
      padding: outerPadding,
      child: TableCard(
        title: AppLocalizations.of(context).slotAvailability,
        icon: LucideIcons.calendarCheck,
        // headers: headers,
        toolbar: toolbarContent,
        heightFactor: 0.68,
        body: TableBodySection(
          data: bookings,
          fields: [
            (row) => DateTimeCell(value: row['schedulingDate'] as DateTime?),
            if (showReserveAction)
              (row) => ReserveCellButton<AvailableSlotDto>.fromRow(
                row: row,
                onReserve: onReserveBooking,
              )
            else
              'service',
          ],
          isLoading: isLoading,
          errorMessage: errorMessage,
          emptyLabel: AppLocalizations.of(context).emptyNoAvailTrainer,
        ),
        margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        pagination: pagination,
      ),
    );
  }
}
