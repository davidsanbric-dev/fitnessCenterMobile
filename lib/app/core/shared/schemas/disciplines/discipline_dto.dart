import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class DisciplineDto {
  const DisciplineDto({
    required this.disciplineId,
    required this.disciplineName,
    this.locationId,
    this.locationName,
  });

  final int disciplineId;
  final String disciplineName;

  /// Club the discipline is offered at, derived from its slots by GET
  /// /disciplines. Set when the discipline maps to a single club so availability
  /// can be scoped to it; null when it spans several clubs (or none).
  final int? locationId;

  /// Name of the offering club, shown under the discipline name. Lists every
  /// club when the discipline spans more than one.
  final String? locationName;

  // Maps the `DisciplineSummary` contract from GET /disciplines (snake_case).
  factory DisciplineDto.fromJson(Map<String, dynamic> json) {
    return DisciplineDto(
      disciplineId: normOptInt(json['discipline_id']) ?? 0,
      disciplineName: normOptString(json['name']) ?? '',
      locationId: normOptInt(json['location_id']),
      locationName: normOptString(json['location_name']),
    );
  }

  Map<String, dynamic> toTableRow() {
    return {
      'discipline': this,
      'id': disciplineId,
      'name': disciplineName,
      'location': locationName ?? '',
    };
  }
}
