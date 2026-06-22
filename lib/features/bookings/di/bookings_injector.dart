import 'package:fitnesscenter_mobile/app/core/di/locator.dart';
import 'package:fitnesscenter_mobile/features/bookings/feature.dart';

class BookingsInjector {
  /// Returns the shared bookings view-model, registering it on first use.
  /// Idempotent so the page (via [SharedViewModelHost]) and the agenda-refresh
  /// port bind to the same instance.
  static BookingsViewModel getBookingsViewModel() =>
      getOrPut(() => BookingsViewModel(repository: BookingsRepositoryImpl()));
}
