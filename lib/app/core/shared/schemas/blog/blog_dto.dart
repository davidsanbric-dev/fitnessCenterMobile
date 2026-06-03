import 'package:portfolio_mobile_app/app/core/constants/app_strings.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

/// Read-only blog entry surfaced in the mobile home info-slider.
class BlogDto {
  const BlogDto({
    required this.id,
    required this.title,
    required this.text,
    this.heroImageUrl,
  });

  final int id;
  final String title;
  final String text;

  /// Path relative to the API base, e.g. "/blog/media/3_ab12.png". Use
  /// [absoluteHeroImageUrl] to obtain a fetchable URL.
  final String? heroImageUrl;

  /// Fully-qualified hero image URL, or null when no image is set. Built from
  /// the same API base every other endpoint uses (which includes /api/v1).
  String? get absoluteHeroImageUrl {
    final path = heroImageUrl;
    if (path == null || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '${AppStrings.baseUrl}$path';
  }

  factory BlogDto.fromJson(Map<String, dynamic> json) {
    return BlogDto(
      id: normOptInt(json['id']) ?? 0,
      title: normOptString(json['title']) ?? '',
      text: normOptString(json['text']) ?? '',
      heroImageUrl: normOptString(json['hero_image_url'] ?? json['heroImageUrl']),
    );
  }
}
