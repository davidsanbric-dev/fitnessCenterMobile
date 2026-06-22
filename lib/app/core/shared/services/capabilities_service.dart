import 'package:fitnesscenter_mobile/app/core/api/capabilities_api.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';

class CapabilitiesService {
  CapabilitiesService({CapabilitiesApi? capabilitiesApi})
    : _capabilitiesApi = capabilitiesApi ?? CapabilitiesApi();

  final CapabilitiesApi _capabilitiesApi;

  Future<List<CapabilityDto>> fetchCapabilities() async {
    return fetchGroups();
  }

  Future<List<CapabilityDto>> fetchGroups() async {
    return _sortCapabilities(await _capabilitiesApi.getGroups());
  }

  Future<List<CapabilityDto>> fetchSubgroup({required int groupId}) async {
    return _sortCapabilities(
      await _capabilitiesApi.getSubgroupFor(groupId: groupId),
    );
  }

  Future<List<CapabilityDto>> fetchSubgroupItems({
    required int groupId,
    required int subgroupId,
  }) async {
    return _sortCapabilities(
      await _capabilitiesApi.getSubgroupItemsFor(
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
