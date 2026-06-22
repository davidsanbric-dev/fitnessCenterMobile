import 'package:fitnesscenter_mobile/app/core/api/blog_api.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/blog/blog_dto.dart';
import 'package:fitnesscenter_mobile/features/home/domain/domain.dart';

class BlogRepositoryImpl implements BlogRepository {
  BlogRepositoryImpl({BlogApi? api}) : _api = api ?? BlogApi();

  final BlogApi _api;

  @override
  Future<List<BlogDto>> fetchBlogs() => _api.getBlogs();
}
