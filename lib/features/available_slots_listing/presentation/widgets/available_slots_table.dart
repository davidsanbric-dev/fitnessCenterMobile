import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/actions_cell_buttons/reserve_cell_button.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/row_cells/date_time_cell.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_body.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_card.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/feature.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class AvailableSlotsTable extends StatelessWidget {
  const AvailableSlotsTable({
    super.key,
    required this.controller,
    this.onEditFilters,
    this.onReserveBooking,
    this.showEditFiltersButton = true,
    this.pageNumber,
    this.pageSize,
    this.totalItems,
    this.onPageChanged,
    this.showPagination = false,
  });

  final AvailableSlotsController controller;
  final VoidCallback? onEditFilters;
  final void Function(AvailableSlotDto slot)? onReserveBooking;
  final bool showEditFiltersButton;
  final int? pageNumber;
  final int? pageSize;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final bool showPagination;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final resolvedPageNumber =
          pageNumber ?? controller.availabilityPageNumber.value;
      final resolvedPageSize =
          pageSize ?? controller.availabilityPageSize.value;
      final resolvedTotalItems =
          totalItems ?? controller.availabilityTotalItems.value;
      final resolvedOnPageChanged =
          onPageChanged ?? controller.setAvailabilityPageNumber;
      final shouldShowPagination =
          showPagination ||
          pageNumber != null ||
          pageSize != null ||
          totalItems != null ||
          onPageChanged != null;
      final pagination = shouldShowPagination
          ? TableCardPaginationConfig(
              pageNumber: resolvedPageNumber,
              pageSize: resolvedPageSize,
              totalItems: resolvedTotalItems,
              onPageChanged: resolvedOnPageChanged,
            )
          : null;

      return TableCard(
        title: 'Available Time Slots',
        icon: LucideIcons.calendarCheck,
        headers: [
          'Time',
          'Trainer / Discipline',
          if (onReserveBooking != null) 'Action',
        ],
        toolbar: _buildToolbar(context),
        toolbarSpacing: 12,
        body: TableBodySection(
          isLoading: controller.isAvailabilityLoading.value,
          errorMessage: controller.availabilityError.value,
          data: controller.availableSlotsTableRows,
          fields: [
            (row) => DateTimeCell(value: row['schedulingDate'] as DateTime?),
            const ['trainerName', 'disciplineName'],
            if (onReserveBooking != null)
              (row) => ReserveCellButton<AvailableSlotDto>.fromRow(
                row: row,
                onReserve: onReserveBooking,
              ),
          ],
          emptyLabel: 'No available time slots for the selected filters.',
        ),
        heightFactor: 0.7,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 16),
        pagination: pagination,
      );
    });
  }

  Widget? _buildToolbar(BuildContext context) {
    final summary = _buildFiltersSummary();
    final editButton = showEditFiltersButton ? _buildEditFiltersButton() : null;

    if (summary == null && editButton == null) {
      return null;
    }

    if (summary != null && editButton != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [summary, const SizedBox(height: 12), editButton],
      );
    }

    return summary ?? editButton;
  }

  Widget? _buildFiltersSummary() {
    final data = controller.lastSubmittedFilters.value;
    if (data == null) {
      return null;
    }

    final items = <TableFiltersSummaryItemData>[];
    final service = data.serviceLabel.trim();
    if (service.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Class type',
          value: service,
          icon: LucideIcons.dumbbell,
        ),
      );
    }

    final primaryLabel = data.primaryLabel.trim();
    if (primaryLabel.isNotEmpty) {
      final isDiscipline = data.searchMode == DisciplineSearchMode.discipline;
      items.add(
        TableFiltersSummaryItemData(
          label: isDiscipline ? 'Discipline' : 'Trainer',
          value: primaryLabel,
          icon: isDiscipline ? LucideIcons.star : LucideIcons.user,
        ),
      );

      if (!isDiscipline && (data.disciplineLabel?.trim().isEmpty ?? true)) {
        items.add(
          const TableFiltersSummaryItemData(
            label: 'Discipline',
            value: 'All disciplines',
            icon: LucideIcons.star,
          ),
        );
      }
    }

    final location = data.locationLabel.trim();
    if (location.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Club',
          value: location,
          icon: LucideIcons.building2,
        ),
      );
    }

    return TableFiltersSummary.maybe(items: items);
  }

  Widget? _buildEditFiltersButton() {
    if (onEditFilters == null) {
      return null;
    }
    return TextButton.icon(
      onPressed: onEditFilters,
      style: TextButton.styleFrom(foregroundColor: AppTheme.brandBlue),
      icon: const Icon(LucideIcons.chevronLeft, size: 18),
      label: const Text('Change filters'),
    );
  }
}
