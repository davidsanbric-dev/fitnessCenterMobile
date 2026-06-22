import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';

abstract interface class CapabilitiesCatalogRepository {
  Future<List<CapabilityDto>> fetchCapabilities();

  Future<List<CapabilityDto>> fetchSubgroup({required int groupId});

  Future<List<CapabilityDto>> fetchSubgroupItems({
    required int groupId,
    required int subgroupId,
  });
}
