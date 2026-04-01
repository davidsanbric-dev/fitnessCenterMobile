import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/services/location_service.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:get/get.dart';

class LocationController extends ControllerBase {
  LocationController({LocationService? service})
    : _service = service ?? LocationService();

  final LocationService _service;

  static const int _noLocationSelectedId = -1;

  final RxList<BookingsLocationOption> locations =
      <BookingsLocationOption>[].obs;
  final RxInt selectedLocationId = _noLocationSelectedId.obs;

  Future<void> loadLocations() async {
    final options = await _service.fetchLocations();
    locations.assignAll(options);
    if (options.isEmpty) {
      selectedLocationId.value = _noLocationSelectedId;
      return;
    }
    if (!options.any((option) => option.id == selectedLocationId.value)) {
      selectedLocationId.value = options.first.id;
    }
  }
}
