import 'package:portfolio_mobile_app/app/core/constants/app_strings.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class TrainerDirectoryDto {
  const TrainerDirectoryDto({
    required this.membershipId,
    required this.membershipName,
    required this.trainerId,
    required this.trainerName,
    required this.disciplineId,
    required this.disciplineName,
    this.bio = '',
    this.photoUrl = '',
  });

  final String membershipId;
  final String membershipName;
  final String trainerId;
  final String trainerName;
  final int disciplineId;
  final String disciplineName;
  final String bio;

  /// Path relative to the API base (e.g. "/profile-images/media/3_ab12.webp").
  /// Use [absolutePhotoUrl] to obtain a fetchable URL.
  final String photoUrl;

  /// Fully-qualified photo URL, or null when no photo is set. Built from the
  /// same API base every other endpoint uses (which includes /api/v1).
  String? get absolutePhotoUrl {
    final path = photoUrl.trim();
    if (path.isEmpty) {
      return null;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '${AppStrings.baseUrl}$path';
  }

  factory TrainerDirectoryDto.fromJson(Map<String, dynamic> json) {
    return TrainerDirectoryDto(
      membershipId: normReqString(json['membershipId']),
      membershipName: normReqString(json['membershipName']),
      trainerId: normReqString(json['trainerId']),
      trainerName: normReqString(json['trainerName']),
      disciplineId: normReqInt(json['disciplineId']),
      disciplineName: normReqString(json['disciplineName']),
      bio: normOptString(json['bio']) ?? '',
      photoUrl: normOptString(json['photoUrl']) ?? '',
    );
  }

  Map<String, dynamic> toTableRow() {
    return {
      'trainer': this,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'disciplineId': disciplineId,
      'disciplineName': disciplineName,
      'membershipId': membershipId,
      'membershipName': membershipName,
      'bio': bio,
      'photoUrl': photoUrl,
    };
  }
}
