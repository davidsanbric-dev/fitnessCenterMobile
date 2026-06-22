import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';

abstract interface class ClassBookingRepository {
  Future<void> bookStandard({
    required AvailableSlotDto slot,
    MemberAvailabilityFilters? listingContext,
  });

  Future<void> bookByClassType({required AvailableSlotByCapabilityDto slot});
}
