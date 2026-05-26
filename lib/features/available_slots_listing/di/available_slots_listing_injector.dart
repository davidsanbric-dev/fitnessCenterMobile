import 'package:portfolio_mobile_app/features/available_slots_listing/feature.dart';
import 'package:portfolio_mobile_app/features/class_booking/class_booking.dart';
import 'package:get/get.dart';

class AvailableSlotsListingInjector {
  static void ensureRegistered() {
    ClassBookingInjector.ensureRegistered();
  }

  static AvailableSlotsController createAvailableSlotsController() {
    ensureRegistered();
    return AvailableSlotsController();
  }

  static AvailableSlotsController getSharedAvailableSlotsController() {
    ensureRegistered();
    if (!Get.isRegistered<AvailableSlotsController>()) {
      Get.put(AvailableSlotsController());
    }
    return Get.find<AvailableSlotsController>();
  }
}
