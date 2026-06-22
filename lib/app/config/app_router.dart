import 'package:get/get.dart';
import 'package:fitnesscenter_mobile/app/config/app_tab.dart';

/// Holds the active navigation destination as a typed [AppTab]. Features react
/// to changes via `ever<AppTab>(appRouter.current, ...)`; [goTo] sets it
/// type-safely, while [changeTab] adapts the bottom nav's int-based callback.
class AppRouter extends GetxController {
  final current = AppTab.home.obs;

  AppTab get currentTab => current.value;

  void goTo(AppTab tab) => current.value = tab;

  /// Adapter for the bottom nav, whose `onTap` reports a logical [AppTab.id].
  void changeTab(int id) => current.value = AppTab.fromId(id);
}
