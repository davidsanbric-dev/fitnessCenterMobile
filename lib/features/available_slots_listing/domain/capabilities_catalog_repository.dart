import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';

abstract interface class CapabilitiesCatalogRepository {
  Future<List<CapabilityDto>> fetchCapabilities({int? locationId});

  Future<List<CapabilityDto>> fetchSubgroup({
    required int locationId,
    required int groupId,
  });

  Future<List<CapabilityDto>> fetchSubgroupItems({
    required int locationId,
    required int groupId,
    required int subgroupId,
  });
}
