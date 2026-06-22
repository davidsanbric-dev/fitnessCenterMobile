import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/ui/snackbar_messenger.dart';
import 'package:fitnesscenter_mobile/app/core/utils/format/date_time.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';
import 'package:fitnesscenter_mobile/features/class_booking/presentation/viewmodels/class_booking_view_model.dart';
import 'package:flutter/material.dart';

/// Widget-facing binding that runs a booking through [ClassBookingViewModel]
/// and surfaces the outcome as a snackbar. It lives apart from the view-model
/// so the model stays free of [BuildContext]/UI dependencies.
extension ClassBookingFeedback on ClassBookingViewModel {
  Future<void> bookStandardAndNotify({
    required BuildContext context,
    required AvailableSlotDto slot,
    MemberAvailabilityFilters? listingContext,
    Future<void> Function()? onBooked,
  }) {
    return _bookAndNotify(
      context: context,
      book: () => bookStandard(slot: slot, listingContext: listingContext),
      successMessage: () =>
          'Session booked for ${formatDateTimeLabel(slot.schedulingDate)}.',
      errorMessage: () => standardBookingError ?? 'Could not book the session.',
      onBooked: onBooked,
    );
  }

  Future<void> bookByClassTypeAndNotify({
    required BuildContext context,
    required AvailableSlotByCapabilityDto slot,
    Future<void> Function()? onBooked,
  }) {
    return _bookAndNotify(
      context: context,
      book: () => bookByClassType(slot: slot),
      successMessage: () {
        final when = formatDateTimeLabel(slot.schedulingDate);
        final capability = slot.capabilityDescription.trim().isEmpty
            ? 'Class option'
            : slot.capabilityDescription.trim();
        return '$capability booked for $when.';
      },
      errorMessage: () =>
          classTypeBookingError ?? 'Could not book this class slot.',
      onBooked: onBooked,
    );
  }

  Future<void> _bookAndNotify({
    required BuildContext context,
    required Future<void> Function() book,
    required String Function() successMessage,
    required String Function() errorMessage,
    Future<void> Function()? onBooked,
  }) async {
    try {
      await book();
      if (onBooked != null) {
        await onBooked();
      }
      if (!context.mounted) {
        return;
      }
      showAppSnackBar(context, successMessage());
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      showAppSnackBar(context, errorMessage());
    }
  }
}
