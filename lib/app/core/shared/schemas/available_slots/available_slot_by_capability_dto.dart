import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:portfolio_mobile_app/app/core/utils/parse.dart';

class AvailableSlotByCapabilityDto {
  const AvailableSlotByCapabilityDto({
    required this.schedulingDate,
    required this.locationName,
    required this.trainerName,
    required this.disciplineName,
    required this.capabilityDescription,
    required this.locationId,
    required this.trainerCode,
    required this.classTypeId,
    required this.slotAssignmentCode,
    this.trainerId,
  });

  final DateTime schedulingDate;
  final String locationName;
  final String? trainerId;
  final String trainerName;
  final String disciplineName;
  final String capabilityDescription;
  final int locationId;
  final int trainerCode;
  final int classTypeId;
  final String slotAssignmentCode;

  factory AvailableSlotByCapabilityDto.fromJson(
    Map<String, dynamic> json, {
    int? defaultLocationId,
    int? defaultCapabilityId,
    String? defaultCapabilityDescription,
  }) {
    // Maps a `ClassTypeAvailabilityItem` from
    // GET /class-types/{id}/availability (snake_case). The item carries only the
    // slot time, assignment code and trainer node; the class option, location and
    // capability description aren't on the slot, so they come from the request
    // (the caller passes them as defaults).
    final trainer = normReqMap(json['trainer']);

    final schedulingDate = parseOptDateTime(json['slot_datetime']);

    final locationName = 'Club location';

    final trainerId = normOptString(trainer['trainer_id']) ?? '';
    // The item exposes no separate trainer_code; the trainer id doubles as it.
    final trainerCode = parseOptInt(trainer['trainer_id']) ?? 0;

    final trainerName = normOptString(trainer['full_name']) ?? trainerId;

    final disciplineName =
        normOptString(trainer['discipline_name']) ?? 'No discipline';

    final capabilityDescription =
        defaultCapabilityDescription ?? 'Class option';
    final classTypeId = defaultCapabilityId ?? 0;
    final locationId = defaultLocationId ?? 0;
    final slotAssignmentCode = normOptString(json['slot_assignment_code']) ?? '';

    return AvailableSlotByCapabilityDto(
      schedulingDate: schedulingDate,
      locationName: locationName,
      trainerId: trainerId,
      trainerName: trainerName,
      disciplineName: disciplineName,
      capabilityDescription: capabilityDescription,
      locationId: locationId,
      trainerCode: trainerCode,
      classTypeId: classTypeId,
      slotAssignmentCode: slotAssignmentCode,
    );
  }

  Map<String, dynamic> toTableRow() {
    return {
      'schedulingDate': schedulingDate,
      'trainer': trainerName.isEmpty ? 'Trainer not assigned' : trainerName,
      'discipline': disciplineName.isEmpty ? 'No discipline' : disciplineName,
      'slot': this,
    };
  }
}
