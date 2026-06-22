import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Mixin for [State]s that bind to a view-model shared through the GetX service
/// locator.
///
/// It acquires the instance (creating it via [createViewModel] when no one else
/// has registered it yet), remembers whether this State introduced it, and
/// tears it down on dispose **only when this State owns it** — so sibling pages
/// sharing the same instance keep working.
///
/// This keeps the locator lifecycle (`Get.isRegistered`/`find`/`put`/`delete`
/// + ownership tracking) out of the widgets, leaving them to read view-model
/// state declaratively.
mixin SharedViewModelHost<W extends StatefulWidget, T extends Object>
    on State<W> {
  late final T viewModel;
  bool _ownsViewModel = false;

  /// Creates (and registers) the view-model. Implementations typically delegate
  /// to the feature injector, which performs the `Get.put` registration.
  T createViewModel();

  /// Acquires the shared view-model. Call once from [initState].
  void acquireViewModel() {
    _ownsViewModel = !Get.isRegistered<T>();
    viewModel = createViewModel();
  }

  /// Releases the view-model if this State owns it. Call from [dispose].
  void releaseViewModel() {
    if (_ownsViewModel && Get.isRegistered<T>()) {
      Get.delete<T>();
    }
  }
}
