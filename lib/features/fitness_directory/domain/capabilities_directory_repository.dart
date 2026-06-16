import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';

abstract interface class CapabilitiesDirectoryRepository {
  // Null locationId lists every group across clubs (matches the booking flow);
  // each group carries its own location for the steps that follow.
  Future<List<CapabilityDto>> fetchGroups({int? locationId});

  Future<List<CapabilityDto>> fetchSubgroup({
    required int locationId,
    required int groupId,
  });

  Future<List<CapabilityDto>> fetchSubgroupItems({
    required int locationId,
    required int groupId,
    required int subgroupId,
  });

  Future<List<AvailableSlotByCapabilityDto>>
  fetchAvailableBookingsByCapability({
    required int locationId,
    required CapabilityDto capability,
  });
}
