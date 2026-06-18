import 'package:portfolio_mobile_app/app/core/constants/app_strings.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class MemberDto {
  const MemberDto({
    required this.memberRut,
    required this.memberName,
    this.paternalSurname,
    this.maternalSurname = '',
    this.avatarUrl = '',
  });

  final String memberRut;
  final String memberName;
  final String? paternalSurname;
  final String? maternalSurname;

  /// Path relative to the API base (e.g. "/profile-images/media/3_ab12.webp"),
  /// or empty when the member has no avatar. Use [absoluteAvatarUrl] to fetch.
  final String avatarUrl;

  /// Fully-qualified avatar URL, or null when no avatar is set. Built from the
  /// same API base every other endpoint uses (which includes /api/v1).
  String? get absoluteAvatarUrl {
    final path = avatarUrl.trim();
    if (path.isEmpty) {
      return null;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '${AppStrings.baseUrl}$path';
  }

  String get fullName {
    final parts =
        [memberName.trim(), paternalSurname?.trim(), maternalSurname?.trim()]
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .toList(growable: false);
    return parts.join(' ');
  }

  // Maps the `CurrentUserResponse` contract from GET /users/me (snake_case).
  // The RUT is the member identification: it comes from `rut`, not the numeric
  // user `id`.
  factory MemberDto.fromJson(Map<String, dynamic> json) {
    return MemberDto(
      memberRut: normOptString(json['rut']) ?? '',
      memberName: normOptString(json['first_name']) ?? '',
      paternalSurname: normOptString(json['paternal_surname']) ?? '',
      maternalSurname: normOptString(json['maternal_surname']) ?? '',
      avatarUrl: normOptString(json['avatar_url']) ?? '',
    );
  }
}
