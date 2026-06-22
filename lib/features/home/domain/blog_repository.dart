import 'package:fitnesscenter_mobile/app/core/shared/schemas/blog/blog_dto.dart';

/// The blog entries shown in the home info-slider.
abstract interface class BlogRepository {
  Future<List<BlogDto>> fetchBlogs();
}
