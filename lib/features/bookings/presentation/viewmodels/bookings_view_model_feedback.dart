import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/dialogs/assign_row_value_dialog.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/booking_details_card_dialog.dart';
import 'package:fitnesscenter_mobile/features/bookings/presentation/viewmodels/bookings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Widget-facing binding that runs [BookingsViewModel] intents and surfaces the
/// outcome as dialogs/snackbars. It lives apart from the view-model so the model
/// stays free of [BuildContext]/UI dependencies.
extension BookingsFeedback on BookingsViewModel {
  Future<void> showBookingDetails(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    try {
      final detail = await fetchBookingDetails(
        bookingId: normReqString(row['bookingId']),
      );

      if (!context.mounted) return;
      await BookingDetailsCardDialog.show(context, booking: detail);
    } on ApiException catch (error) {
      Get.snackbar('Could not load details', error.message);
    } catch (error) {
      Get.snackbar(
        'Unexpected error',
        'Could not show booking details: $error',
      );
    }
  }

  Future<void> confirmReservationAndNotify(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    final result = await confirmReservation(row);
    Get.snackbar(result.title, result.message);
  }

  Future<void> cancelReservationAndNotify(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    final result = await cancelReservation(row);
    Get.snackbar(result.title, result.message);
  }

  /// Generic status picker: lets the member pick any backend-supported booking
  /// status and apply it, mirroring the available-slots / web-admin flow.
  Future<void> updateBookingStatusAndNotify(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    await ensureBookingStatesLoaded();

    final options = buildStateOptions();
    if (options.isEmpty) {
      Get.snackbar(
        'Action unavailable',
        'No booking statuses are available to apply.',
      );
      return;
    }

    final initialValue = resolveStateOptionIdForRow(options, row);

    if (!context.mounted) return;
    final updatedState = await showAssignRowValueDialog(
      context: context,
      title: 'Update Status',
      fieldLabel: 'Status',
      emptySelectionMessage: 'Select a status',
      confirmLabel: 'Update',
      initialValue: initialValue,
      options: options,
      onSubmit: (value) => applyBookingStatus(
        bookingId: normReqString(row['bookingId']),
        state: value,
      ),
    );

    if (updatedState != null) {
      Get.snackbar('Status updated', 'Booking changed to $updatedState.');
    }
  }
}
