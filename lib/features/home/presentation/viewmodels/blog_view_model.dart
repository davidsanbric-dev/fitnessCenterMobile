import 'dart:async';

import 'package:fitnesscenter_mobile/app/core/shared/schemas/blog/blog_dto.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/home/domain/domain.dart';

/// Holds the blog entries shown in the home info-slider and refreshes them when
/// a "new blog" push arrives, so the slider updates on-time without a manual
/// reload.
class BlogViewModel extends ViewModelBase {
  BlogViewModel({required BlogRepository repository})
    : _repository = repository;

  final BlogRepository _repository;

  final List<BlogDto> blogs = <BlogDto>[];
  bool loading = false;
  bool loaded = false;

  Timer? _pollTimer;
  // Guards against overlapping fetches (push + poll + resume can coincide).
  bool _inFlight = false;

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
    loading = true;
    try {
      final result = await _repository.fetchBlogs();
      blogs
        ..clear()
        ..addAll(result);
    } catch (_) {
      // Non-critical: keep whatever is already displayed (or none).
    } finally {
      _inFlight = false;
      loading = false;
      loaded = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
