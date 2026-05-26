import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';

abstract interface class ClassBookingRepository {
  Future<void> bookStandard({
    required AvailableSlotDto slot,
    MemberAvailabilityFilters? listingContext,
    String? online,
  });

  Future<void> bookByClassType({required AvailableSlotByCapabilityDto slot});
}
