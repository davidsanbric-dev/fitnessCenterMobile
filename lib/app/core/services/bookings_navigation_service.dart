import 'package:get/get.dart';

/// Lightweight bus that lets any page request the Bookings page to open its
/// in-page "Book a Session" flow on the next tab-switch, without tight coupling
/// between pages. Mirrors [ProfileNavigationService].
class BookingsNavigationService extends GetxService {
  static BookingsNavigationService get instance {
    if (!Get.isRegistered<BookingsNavigationService>()) {
      Get.put(BookingsNavigationService(), permanent: true);
    }
    return Get.find<BookingsNavigationService>();
  }

  /// True when the in-page book-session flow should be opened on the next
  /// Bookings tab visit. Cleared by BookingsPage after consuming.
  final pendingBookFlow = false.obs;

  void requestBookFlow() => pendingBookFlow.value = true;

  void consume() => pendingBookFlow.value = false;
}
