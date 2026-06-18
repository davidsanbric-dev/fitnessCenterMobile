import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class TrainerDto {
  const TrainerDto({
    required this.trainerId,
    required this.trainerName,
    this.disciplineId = 0,
    this.disciplineName = '',
    this.bio = '',
    this.photoUrl = '',
  });

  final String trainerId;
  final String trainerName;
  final int disciplineId;
  final String disciplineName;
  final String bio;

  /// Path relative to the API base (e.g. "/profile-images/media/3_ab12.webp"),
  /// or empty when the trainer has no photo.
  final String photoUrl;

  // Maps the `TrainerSummary` contract from GET /trainers (snake_case).
  factory TrainerDto.fromJson(Map<String, dynamic> json) {
    return TrainerDto(
      trainerId: normOptString(json['trainer_id']) ?? '',
      trainerName: normOptString(json['full_name']) ?? '',
      disciplineId: normOptInt(json['discipline_id']) ?? 0,
      disciplineName: normOptString(json['discipline_name']) ?? '',
      bio: normOptString(json['bio']) ?? '',
      photoUrl: normOptString(json['photo_url']) ?? '',
    );
  }
}
