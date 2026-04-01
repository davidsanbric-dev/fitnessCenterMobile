import 'package:portfolio_mobile_app/app/core/api/capabilities_api.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';

class CapabilitiesService {
  CapabilitiesService({CapabilitiesApi? capabilitiesApi})
    : _capabilitiesApi = capabilitiesApi ?? CapabilitiesApi();

  final CapabilitiesApi _capabilitiesApi;

  Future<List<CapabilityDto>> fetchCapabilities({int? locationId}) async {
    return fetchGroups(locationId: locationId);
  }

  Future<List<CapabilityDto>> fetchGroups({int? locationId}) async {
    return _sortCapabilities(
      await _capabilitiesApi.getGroups(locationId: locationId),
    );
  }

  Future<List<CapabilityDto>> fetchSubgroup({
    required int locationId,
    required int groupId,
  }) async {
    return _sortCapabilities(
      await _capabilitiesApi.getSubgroupFor(
        locationId: locationId,
        groupId: groupId,
      ),
    );
  }

  Future<List<CapabilityDto>> fetchSubgroupItems({
    required int locationId,
    required int groupId,
    required int subgroupId,
  }) async {
    return _sortCapabilities(
      await _capabilitiesApi.getSubgroupItemsFor(
        locationId: locationId,
        groupId: groupId,
        subgroupId: subgroupId,
      ),
    );
  }

  List<CapabilityDto> _sortCapabilities(List<CapabilityDto> items) {
    return items.toList(growable: true)..sort(
      (a, b) =>
          a.description.toLowerCase().compareTo(b.description.toLowerCase()),
    );
  }
}
