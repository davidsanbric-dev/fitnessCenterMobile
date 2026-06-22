import 'package:fitnesscenter_mobile/app/core/di/locator.dart';
import 'package:fitnesscenter_mobile/app/core/services/push_notification_service.dart';
import 'package:fitnesscenter_mobile/features/home/feature.dart';
import 'package:get/get.dart';

class HomeInjector {
  /// Returns the shared blog view-model, registering it permanently on first
  /// use. On creation it wires the "new blog" push to refresh the slider and
  /// kicks off the initial load — mirroring the controller's old `onInit`.
  static BlogViewModel getBlogViewModel() {
    return getOrPut<BlogViewModel>(() {
      final viewModel = BlogViewModel(repository: BlogRepositoryImpl());
      if (Get.isRegistered<PushNotificationService>()) {
        Get.find<PushNotificationService>().setOnBlogCreated(
          viewModel.loadBlogs,
        );
      }
      viewModel.loadBlogs();
      return viewModel;
    }, permanent: true);
  }
}
