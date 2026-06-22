import 'package:fitnesscenter_mobile/app/core/api/shared/api_base.dart';
import 'package:fitnesscenter_mobile/app/core/constants/api_urls.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/blog/blog_dto.dart';

/// Read-only client for company-scoped blog entries. Writes happen only from
/// the web admin; the mobile app consumes the list to populate the home slider.
class BlogApi extends ApiBase {
  Future<List<BlogDto>> getBlogs({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return getDataListAsync<BlogDto>(
      url: ApiUrls.blogUrl,
      requestErrorMessage: 'Unable to load blog entries',
      fromJson: BlogDto.fromJson,
      queryParameters: <String, String>{
        'page': pageNumber.toString(),
        'page_size': pageSize.toString(),
      },
    );
  }
}
