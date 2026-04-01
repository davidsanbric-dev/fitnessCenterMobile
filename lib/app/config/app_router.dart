import 'package:get/get.dart';

enum AvailableBookingsDestination { root, online }

class AppRouter extends GetxController {
  static const int availableSlotsTabIndex = 4;

  var currentIndex = 0.obs;
  final availableSlotsDestination = AvailableBookingsDestination.root.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    if (index != availableSlotsTabIndex) {
      resetAvailableBookingsDestination();
    }
  }

  void openAvailableBookings({
    AvailableBookingsDestination destination =
        AvailableBookingsDestination.root,
  }) {
    availableSlotsDestination.value = destination;
    currentIndex.value = availableSlotsTabIndex;
  }

  void resetAvailableBookingsDestination() {
    availableSlotsDestination.value = AvailableBookingsDestination.root;
  }
}
