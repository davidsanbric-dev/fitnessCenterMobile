import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/services/available_slots_service.dart';
import 'package:fitnesscenter_mobile/app/core/shared/services/capabilities_service.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/domain/domain.dart';

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
  Future<List<CapabilityDto>> fetchGroups() {
    return _capabilitiesService.fetchGroups();
  }

  @override
  Future<List<CapabilityDto>> fetchSubgroup({required int groupId}) {
    return _capabilitiesService.fetchSubgroup(groupId: groupId);
  }

  @override
  Future<List<CapabilityDto>> fetchSubgroupItems({
    required int groupId,
    required int subgroupId,
  }) {
    return _capabilitiesService.fetchSubgroupItems(
      groupId: groupId,
      subgroupId: subgroupId,
    );
  }

  @override
  Future<List<AvailableSlotByCapabilityDto>>
  fetchAvailableBookingsByCapability({required CapabilityDto capability}) {
    return _availableSlotsService.fetchAvailableBookingsByCapability(
      capability: capability,
    );
  }
}
