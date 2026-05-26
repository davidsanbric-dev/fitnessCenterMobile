import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/ui/snackbar_messenger.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:portfolio_mobile_app/features/class_booking/logic/class_booking_controller.dart';
import 'package:flutter/material.dart';

class ClassBookingFlow {
  static Future<void> bookStandard({
    required BuildContext context,
    required ClassBookingController controller,
    required AvailableSlotDto slot,
    MemberAvailabilityFilters? listingContext,
    String? online,
    Future<void> Function()? onBooked,
  }) async {
    try {
      await controller.bookStandard(
        slot: slot,
        listingContext: listingContext,
        online: online,
      );
      if (onBooked != null) {
        await onBooked();
      }
      if (!context.mounted) {
        return;
      }
      final when = formatDateTimeLabel(slot.schedulingDate);
      showAppSnackBar(context, 'Session booked for $when.');
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      showAppSnackBar(
        context,
        controller.standardBookingError ?? 'Could not book the session.',
      );
    }
  }

  static Future<void> bookByClassType({
    required BuildContext context,
    required ClassBookingController controller,
    required AvailableSlotByCapabilityDto slot,
    Future<void> Function()? onBooked,
  }) async {
    try {
      await controller.bookByClassType(slot: slot);
      if (onBooked != null) {
        await onBooked();
      }
      if (!context.mounted) {
        return;
      }

      final when = formatDateTimeLabel(slot.schedulingDate);
      final capability = slot.capabilityDescription.trim().isEmpty
          ? 'Class option'
          : slot.capabilityDescription.trim();
      showAppSnackBar(context, '$capability booked for $when.');
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      showAppSnackBar(
        context,
        controller.classTypeBookingError ?? 'Could not book this class slot.',
      );
    }
  }
}
