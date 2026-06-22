import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/services/capabilities_service.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/domain/domain.dart';

class CapabilitiesCatalogRepositoryImpl
    implements CapabilitiesCatalogRepository {
  CapabilitiesCatalogRepositoryImpl({CapabilitiesService? service})
    : _service = service ?? CapabilitiesService();

  final CapabilitiesService _service;

  @override
  Future<List<CapabilityDto>> fetchCapabilities() {
    return _service.fetchCapabilities();
  }

  @override
  Future<List<CapabilityDto>> fetchSubgroup({required int groupId}) {
    return _service.fetchSubgroup(groupId: groupId);
  }

  @override
  Future<List<CapabilityDto>> fetchSubgroupItems({
    required int groupId,
    required int subgroupId,
  }) {
    return _service.fetchSubgroupItems(
      groupId: groupId,
      subgroupId: subgroupId,
    );
  }
}
