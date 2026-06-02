import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/location/location_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/location_code_registry.dart';

class LocationsApi extends ApiBase {
  LocationsApi() : super();

  Future<List<LocationDto>> getLocations() async {
    final locations = await getDataListAsync<LocationDto>(
      url: ApiUrls.staticsUrl,
      requestErrorMessage: 'Error al obtener sucursales',
      extractItems: _extractLocationItems,
      fromJson: LocationDto.fromJson,
    );

    // Record the logged-in company's real location codes so request builders
    // resolve them from /statics instead of hardcoding LOC00x mappings.
    LocationCodeRegistry.instance.replaceAll(<String, String>{
      for (final location in locations)
        if ((location.locationCode ?? '').trim().isNotEmpty)
          location.locationId.toString(): location.locationCode!.trim(),
    });

    return locations;
  }

  List<Map<String, dynamic>> _extractLocationItems(dynamic data) {
    if (data is Map) {
      return _collectLocationItemMaps(data['locations']);
    }

    return const <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _collectLocationItemMaps(dynamic locations) {
    if (locations is Map) {
      return locations.entries
          .toList(growable: false)
          .asMap()
          .entries
          .map(
            (indexedEntry) => <String, dynamic>{
              'locationId': indexedEntry.key + 1,
              'locationName': indexedEntry.value.value?.toString(),
              'locationCode': indexedEntry.value.key?.toString(),
            },
          )
          .toList(growable: false);
    }

    if (locations is List) {
      return locations
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
    }

    return const <Map<String, dynamic>>[];
  }
}
