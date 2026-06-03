import 'package:get/get.dart';

import 'package:portfolio_mobile_app/app/core/api/blog_api.dart';
import 'package:portfolio_mobile_app/app/core/services/push_notification_service.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/blog/blog_dto.dart';

/// Holds the blog entries shown in the home info-slider and refreshes them when
/// a "new blog" push arrives, so the slider updates on-time without a manual
/// reload.
class BlogController extends GetxController {
  BlogController({BlogApi? api}) : _api = api ?? BlogApi();

  final BlogApi _api;

  final RxList<BlogDto> blogs = <BlogDto>[].obs;
  final RxBool loading = false.obs;
  final RxBool loaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<PushNotificationService>()) {
      Get.find<PushNotificationService>().setOnBlogCreated(loadBlogs);
    }
    loadBlogs();
  }

  Future<void> loadBlogs() async {
    loading.value = true;
    try {
      final result = await _api.getBlogs();
      blogs.assignAll(result);
    } catch (_) {
      // Non-critical: keep whatever is already displayed (or none).
    } finally {
      loading.value = false;
      loaded.value = true;
    }
  }
}
