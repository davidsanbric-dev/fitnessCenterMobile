import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';

abstract interface class CapabilitiesDirectoryRepository {
  Future<List<CapabilityDto>> fetchGroups({required int locationId});

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
