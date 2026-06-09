import 'package:get/get.dart';

/// Lightweight bus that lets any page request the Profile page to open a
/// specific sub-view (e.g. Training History) on the next tab-switch without
/// tight coupling between pages.
class ProfileNavigationService extends GetxService {
  static ProfileNavigationService get instance {
    if (!Get.isRegistered<ProfileNavigationService>()) {
      Get.put(ProfileNavigationService(), permanent: true);
    }
    return Get.find<ProfileNavigationService>();
  }

  /// Non-null when a sub-view should be opened on the next Profile tab visit.
  /// Cleared by ProfilePage after consuming.
  final pendingSubView = RxnString();

  void requestTrainingHistory() => pendingSubView.value = 'training_history';

  void requestAssessmentResults() => pendingSubView.value = 'assessment_results';

  void consume() => pendingSubView.value = null;
}
