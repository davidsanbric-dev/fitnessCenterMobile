import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/available_slots_service.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/capabilities_service.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/domain/domain.dart';

class CapabilitiesDirectoryRepositoryImpl
    implements CapabilitiesDirectoryRepository {
  CapabilitiesDirectoryRepositoryImpl({
    CapabilitiesService? capabilitiesService,
    AvailableSlotsService? availableSlotsService,
  }) : _capabilitiesService = capabilitiesService ?? CapabilitiesService(),
       _availableSlotsService =
           availableSlotsService ?? AvailableSlotsService();

  final CapabilitiesService _capabilitiesService;
  final AvailableSlotsService _availableSlotsService;

  @override
  Future<List<CapabilityDto>> fetchGroups({required int locationId}) {
    return _capabilitiesService.fetchGroups(locationId: locationId);
  }

  @override
  Future<List<CapabilityDto>> fetchSubgroup({
    required int locationId,
    required int groupId,
  }) {
    return _capabilitiesService.fetchSubgroup(
      locationId: locationId,
      groupId: groupId,
    );
  }

  @override
  Future<List<CapabilityDto>> fetchSubgroupItems({
    required int locationId,
    required int groupId,
    required int subgroupId,
  }) {
    return _capabilitiesService.fetchSubgroupItems(
      locationId: locationId,
      groupId: groupId,
      subgroupId: subgroupId,
    );
  }

  @override
  Future<List<AvailableSlotByCapabilityDto>>
  fetchAvailableBookingsByCapability({
    required int locationId,
    required CapabilityDto capability,
  }) {
    return _availableSlotsService.fetchAvailableBookingsByCapability(
      locationId: locationId,
      capability: capability,
    );
  }
}
