import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class DisciplineDto {
  const DisciplineDto({
    required this.disciplineId,
    required this.disciplineName,
  });

  final int disciplineId;
  final String disciplineName;

  factory DisciplineDto.fromJson(Map<String, dynamic> json) {
    return DisciplineDto(
      disciplineId:
          normOptInt(json['disciplineId'] ?? json['discipline_id']) ?? 0,
      disciplineName:
          normOptString(json['disciplineName'] ?? json['name']) ?? '',
    );
  }

  Map<String, dynamic> toTableRow() {
    return {'discipline': this, 'id': disciplineId, 'name': disciplineName};
  }
}
