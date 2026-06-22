import 'package:get/get.dart';

/// Returns the [T] registered in the GetX locator, creating and registering it
/// via [create] on first use. Idempotent, so feature injectors and pages that
/// share a view-model (through `SharedViewModelHost`) bind to one instance.
///
/// Pass [permanent] for dependencies that must outlive the page that first
/// resolves them (e.g. cross-feature singletons).
T getOrPut<T>(T Function() create, {bool permanent = false}) {
  if (!Get.isRegistered<T>()) {
    Get.put<T>(create(), permanent: permanent);
  }
  return Get.find<T>();
}
