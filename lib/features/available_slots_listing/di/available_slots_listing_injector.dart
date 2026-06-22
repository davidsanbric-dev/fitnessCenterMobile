import 'package:fitnesscenter_mobile/app/core/di/locator.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/feature.dart';
import 'package:fitnesscenter_mobile/features/class_booking/feature.dart';

class AvailableSlotsListingInjector {
  static void ensureRegistered() {
    ClassBookingInjector.ensureRegistered();
  }

  static AvailableSlotsViewModel createAvailableSlotsViewModel() {
    ensureRegistered();
    return AvailableSlotsViewModel();
  }

  /// Returns the shared view-model, registering it on first use. Idempotent so
  /// sibling subpages (by-capability / by-discipline-trainer) bind to the same
  /// instance via [SharedViewModelHost].
  static AvailableSlotsViewModel getAvailableSlotsViewModel() =>
      getOrPut(createAvailableSlotsViewModel);
}
