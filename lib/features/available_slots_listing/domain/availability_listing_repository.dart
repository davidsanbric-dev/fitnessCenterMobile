import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';

abstract interface class AvailabilityListingRepository {
  Future<List<AvailableSlotDto>> fetchAvailableBookings({
    required MemberAvailabilityFilters filters,
  });

  Future<List<AvailableSlotByCapabilityDto>>
  fetchAvailableBookingsByCapability({
    required int locationId,
    required CapabilityDto capability,
  });
}
