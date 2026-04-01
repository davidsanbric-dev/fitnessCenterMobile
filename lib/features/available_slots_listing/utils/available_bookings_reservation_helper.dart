import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/ui/snackbar_messenger.dart';
import 'package:flutter/material.dart';

void showReservationPreviewSnackBar(
  BuildContext context,
  AvailableSlotDto slot,
) {
  final trainer = slot.trainerName.trim().isEmpty
      ? 'Trainer pending confirmation'
      : slot.trainerName.trim();
  final location = slot.locationName.trim().isEmpty
      ? 'Club pending confirmation'
      : slot.locationName.trim();
  final dateLabel = formatDateTimeLabel(slot.schedulingDate);

  showAppSnackBar(
    context,
    'Book a session on $dateLabel with $trainer at $location.',
  );
}
