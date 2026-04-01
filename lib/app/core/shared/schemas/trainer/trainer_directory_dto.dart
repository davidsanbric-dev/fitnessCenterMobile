import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class TrainerDirectoryDto {
  const TrainerDirectoryDto({
    required this.membershipId,
    required this.membershipName,
    required this.trainerId,
    required this.trainerName,
    required this.disciplineId,
    required this.disciplineName,
  });

  final String membershipId;
  final String membershipName;
  final String trainerId;
  final String trainerName;
  final int disciplineId;
  final String disciplineName;

  factory TrainerDirectoryDto.fromJson(Map<String, dynamic> json) {
    return TrainerDirectoryDto(
      membershipId: normReqString(json['membershipId']),
      membershipName: normReqString(json['membershipName']),
      trainerId: normReqString(json['trainerId']),
      trainerName: normReqString(json['trainerName']),
      disciplineId: normReqInt(json['disciplineId']),
      disciplineName: normReqString(json['disciplineName']),
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
    };
  }
}
