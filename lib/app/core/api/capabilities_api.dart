import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/location_code_registry.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capabilities_request.dart';

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
      queryParameters: _resolveCapabilitiesQuery(request),
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

  Map<String, String> _resolveCapabilitiesQuery(CapabilitiesRequest request) {
    final shouldIncludeLocationCode =
        (request.queryType == queryTypeGroup ||
            request.queryType == queryTypeSubgroup ||
            request.queryType == queryTypeSubgroupItems) &&
        request.locationId != null;

    if (shouldIncludeLocationCode) {
      return {
        'location_code': LocationCodeRegistry.instance.resolve(
          request.locationId!.toString(),
        ),
      };
    }
    return const <String, String>{};
  }

  Future<List<CapabilityDto>> getGroups({int? locationId}) => getCapabilities(
    CapabilitiesRequest(
      locationId: locationId,
      queryType: queryTypeGroup,
      id: 0,
    ),
  );

  Future<List<CapabilityDto>> getSubgroupFor({
    required int locationId,
    required int groupId,
  }) => getCapabilities(
    CapabilitiesRequest(
      locationId: locationId,
      queryType: queryTypeSubgroup,
      id: groupId,
    ),
  );

  Future<List<CapabilityDto>> getSubgroupItemsFor({
    required int locationId,
    required int groupId,
    required int subgroupId,
  }) => getCapabilities(
    CapabilitiesRequest(
      locationId: locationId,
      queryType: queryTypeSubgroupItems,
      id: subgroupId,
      parentId: groupId,
    ),
  );
}
