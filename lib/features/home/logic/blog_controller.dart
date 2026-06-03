import 'dart:async';

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

  Timer? _pollTimer;
  // Guards against overlapping fetches (push + poll + resume can coincide).
  bool _inFlight = false;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<PushNotificationService>()) {
      Get.find<PushNotificationService>().setOnBlogCreated(loadBlogs);
    }
    loadBlogs();
  }

  @override
  void onClose() {
    stopAutoRefresh();
    super.onClose();
  }

  /// Periodic safety net so the home slider stays current even if a foreground
  /// push is delayed or dropped. The home page starts this while visible and
  /// stops it when backgrounded. Idempotent.
  void startAutoRefresh({Duration interval = const Duration(seconds: 60)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) => loadBlogs());
  }

  void stopAutoRefresh() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> loadBlogs() async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    loading.value = true;
    try {
      final result = await _api.getBlogs();
      blogs.assignAll(result);
    } catch (_) {
      // Non-critical: keep whatever is already displayed (or none).
    } finally {
      _inFlight = false;
      loading.value = false;
      loaded.value = true;
    }
  }
}
