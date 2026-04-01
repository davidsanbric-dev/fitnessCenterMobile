import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class TrainerDto {
  const TrainerDto({
    required this.trainerId,
    required this.trainerName,
    this.disciplineId = 0,
    this.disciplineName = '',
  });

  final String trainerId;
  final String trainerName;
  final int disciplineId;
  final String disciplineName;

  factory TrainerDto.fromJson(Map<String, dynamic> json) {
    final trainerId =
        normOptString(json['trainerId']) ??
        normOptString(json['trainer_id']) ??
        normOptString(json['trainerId']) ??
        '';
    final trainerName =
        normOptString(json['trainerName']) ??
        normOptString(json['full_name']) ??
        normOptString(json['fullName']) ??
        '';
    return TrainerDto(
      trainerId: trainerId,
      trainerName: trainerName,
      disciplineId:
          normOptInt(
            json['disciplineId'] ??
                json['disciplineCode'] ??
                json['discipline_id'] ??
                json['disciplineId'],
          ) ??
          0,
      disciplineName:
          normOptString(
            (json['disciplineName'] ??
                    json['discipline_name'] ??
                    json['disciplineName'])
                ?.toString(),
          ) ??
          '',
    );
  }
}
