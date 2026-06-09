import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/date_time_status_cell.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_body.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_card.dart';
import 'package:flutter/material.dart';

class BookingsTable extends StatelessWidget {
  const BookingsTable({
    super.key,
    required this.bookings,
    required this.isLoading,
    required this.errorMessage,
    this.onViewDetails,
    this.onConfirmReservation,
    this.onCancelReservation,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.showPagination = false,
  });

  final List<BookingDto> bookings;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function(BuildContext context, Map<String, dynamic> row)?
  onViewDetails;
  final Future<void> Function(BuildContext context, Map<String, dynamic> row)?
  onConfirmReservation;
  final Future<void> Function(BuildContext context, Map<String, dynamic> row)?
  onCancelReservation;
  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;

  List<Map<String, dynamic>> get _rows => bookings
      .map((item) {
        final serviceName = item.serviceName?.trim() ?? '';
        final trainerName = item.trainerName?.trim() ?? '';
        final disciplineName = item.disciplineName?.trim() ?? '';
        final locationName = item.locationName.trim();
        const fallbackServiceName = 'Not specified';

        return <String, dynamic>{
          'bookingId': item.bookingId,
          'schedulingDate': item.schedulingDate,
          'state': item.state,
          'bookingStatus': item.state,
          'serviceName': serviceName.isEmpty
              ? fallbackServiceName
              : serviceName,
          'trainerName': trainerName.isEmpty
              ? 'Trainer pending assignment'
              : trainerName,
          'disciplineName': disciplineName,
          'locationName': locationName.isEmpty
              ? 'Club pending assignment'
              : locationName,
          'locationId': item.locationId,
          'duration': item.duration,
          'slot': item,
        };
      })
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
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
      headers: const ['Time', 'Class / Trainer', 'Actions'],
      body: TableBodySection(
        isLoading: isLoading,
        errorMessage: errorMessage,
        data: _rows,
        fields: [
          (row) => DateTimeStatusCell(
            value: row['schedulingDate'] as DateTime?,
            status: row['state'] as String?,
          ),
          const ['serviceName', 'trainerName'],
        ],
        actions: () {
          final handlers = <String, void Function(Map<String, dynamic>)>{};
          if (onViewDetails != null) {
            handlers['onView'] = (row) => onViewDetails!(context, row);
          }
          if (onConfirmReservation != null) {
            handlers['onConfirmReservation'] = (row) =>
                onConfirmReservation!(context, row);
          }
          if (onCancelReservation != null) {
            handlers['onCancelReservation'] = (row) =>
                onCancelReservation!(context, row);
          }
          return handlers.isEmpty ? null : handlers;
        }(),
        emptyLabel: 'You have no assigned bookings.',
      ),
      heightFactor: 0.72,
      margin: const EdgeInsets.fromLTRB(2, 0, 2, 16),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      toolbarSpacing: 6,
      pagination: pagination,
    );
  }
}
