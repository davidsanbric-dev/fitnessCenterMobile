import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/dialogs/assign_row_value_dialog.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/booking_details_card_dialog.dart';
import 'package:fitnesscenter_mobile/features/bookings/presentation/viewmodels/bookings_view_model.dart';
import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final result = await confirmReservation(row);
    _notifyBookingAction(l10n, result);
  }

  Future<void> cancelReservationAndNotify(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    final l10n = AppLocalizations.of(context);
    final result = await cancelReservation(row);
    _notifyBookingAction(l10n, result);
  }

  /// Turns a [BookingActionResult] into localized snackbar copy.
  ///
  /// The view-model reports only what happened; the wording lives here, where
  /// there is a locale to resolve it against.
  void _notifyBookingAction(AppLocalizations l10n, BookingActionResult result) {
    final isCancel = result.action == BookingAction.cancel;

    switch (result.outcome) {
      case BookingActionOutcome.unavailable:
        Get.snackbar(
          l10n.bookingActionUnavailableTitle,
          isCancel
              ? l10n.bookingCancelUnavailable
              : l10n.bookingConfirmUnavailable,
        );
      case BookingActionOutcome.updated:
        Get.snackbar(
          l10n.bookingStatusUpdatedTitle,
          isCancel
              ? l10n.bookingChangedToCanceled
              : l10n.bookingChangedToConfirmed,
        );
      case BookingActionOutcome.apiFailure:
        // Server-authored message: already in the user's language.
        Get.snackbar(l10n.bookingUpdateFailedTitle, result.detail ?? '');
      case BookingActionOutcome.unexpectedFailure:
        Get.snackbar(
          l10n.bookingUnexpectedErrorTitle,
          l10n.bookingUnexpectedErrorDetail(result.detail ?? ''),
        );
    }
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
