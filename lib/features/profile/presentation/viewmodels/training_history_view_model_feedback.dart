import 'package:fitnesscenter_mobile/l10n/app_localizations.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/widgets/booking_details_card_dialog.dart';
import 'package:fitnesscenter_mobile/features/profile/presentation/viewmodels/training_history_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Widget-facing binding that runs [TrainingHistoryViewModel] reads and surfaces
/// the outcome as a dialog/snackbar. It lives apart from the view-model so the
/// model stays free of [BuildContext]/UI dependencies.
extension TrainingHistoryFeedback on TrainingHistoryViewModel {
  Future<void> showBookingDetails(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final detail = await fetchBookingDetails(
        bookingId: normReqString(row['bookingId']),
      );

      if (!context.mounted) return;
      await BookingDetailsCardDialog.show(context, booking: detail);
    } on ApiException catch (error) {
      Get.snackbar(l10n.commonDetailsLoadFailed, error.message);
    } catch (error) {
      Get.snackbar(
        l10n.commonUnexpectedError,
        'Could not show booking details: $error',
      );
    }
  }
}
