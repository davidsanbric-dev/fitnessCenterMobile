import 'package:portfolio_mobile_app/app/core/api/locations_api.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';

class LocationService {
  LocationService({LocationsApi? locationsApi})
    : _locationsApi = locationsApi ?? LocationsApi();

  final LocationsApi _locationsApi;

  Future<List<BookingsLocationOption>> fetchLocations() async {
    final data = await _locationsApi.getLocations();
    return data
        .map(
          (dto) => BookingsLocationOption(
            id: dto.locationId,
            name: dto.locationName?.trim() ?? '',
          ),
        )
        .toList(growable: false);
  }
}
