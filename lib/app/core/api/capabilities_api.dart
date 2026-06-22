import 'package:fitnesscenter_mobile/app/core/api/shared/api_base.dart';
import 'package:fitnesscenter_mobile/app/core/constants/api_urls.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capabilities_request.dart';

class CapabilitiesApi extends ApiBase {
  static const int queryTypeGroup = 1;
  static const int queryTypeSubgroup = 2;
  static const int queryTypeSubgroupItems = 3;

  CapabilitiesApi() : super();

  Future<List<CapabilityDto>> getCapabilities(
    CapabilitiesRequest request,
  ) async {
    final endpoint = _resolveCapabilitiesEndpoint(request);
    return getDataListAsync<CapabilityDto>(
      url: endpoint,
      requestErrorMessage: 'Error al obtener prestaciones',
      fromJson: CapabilityDto.fromJson,
    );
  }

  String _resolveCapabilitiesEndpoint(CapabilitiesRequest request) {
    final id = request.id;
    switch (request.queryType) {
      case queryTypeGroup:
        return ApiUrls.classCategoriesUrl;
      case queryTypeSubgroup:
        return '${ApiUrls.classCategoriesUrl}/$id/subcategories';
      case queryTypeSubgroupItems:
        final groupId = request.parentId ?? id;
        return '${ApiUrls.classCategoriesUrl}/$groupId/subcategories/$id/class-types';
      default:
        return ApiUrls.classCategoriesUrl;
    }
  }

  Future<List<CapabilityDto>> getGroups() =>
      getCapabilities(CapabilitiesRequest(queryType: queryTypeGroup, id: 0));

  Future<List<CapabilityDto>> getSubgroupFor({required int groupId}) =>
      getCapabilities(
        CapabilitiesRequest(queryType: queryTypeSubgroup, id: groupId),
      );

  Future<List<CapabilityDto>> getSubgroupItemsFor({
    required int groupId,
    required int subgroupId,
  }) => getCapabilities(
    CapabilitiesRequest(
      queryType: queryTypeSubgroupItems,
      id: subgroupId,
      parentId: groupId,
    ),
  );
}
