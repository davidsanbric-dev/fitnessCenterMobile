import 'package:get/get.dart';

class AppRouter extends GetxController {
  static const int availableSlotsTabIndex = 4;

  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

}
