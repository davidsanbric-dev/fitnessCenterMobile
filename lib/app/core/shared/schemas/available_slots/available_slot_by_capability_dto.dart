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
    final trainer = normReqMap(json['trainer']);
    final location = normReqMap(json['location']);
    final resolvedTrainer = trainer;
    final resolvedLocation = location;

    final schedulingDate = parseOptDateTime(
      json['bookingDateTime'] ??
          json['booking_datetime'] ??
          json['slot_datetime'] ??
          json['schedulingDateTime'] ??
          json['schedulingDate'],
    );

    final locationName =
        normOptString(json['locationName']) ??
        normOptString(resolvedLocation['locationName']) ??
        normOptString(resolvedLocation['name']) ??
        'Club location';

    final trainerId =
        normOptString(resolvedTrainer['id']) ??
        normOptString(resolvedTrainer['trainer_id']) ??
        normOptString(resolvedTrainer['trainerId']) ??
        '';
    final trainerCode =
        parseOptInt(resolvedTrainer['trainer_code']) ??
        parseOptInt(resolvedTrainer['trainer_id']) ??
        parseOptInt(resolvedTrainer['trainerId']) ??
        parseOptInt(resolvedTrainer['id']) ??
        0;

    final trainerName =
        normOptString(resolvedTrainer['name']) ??
        normOptString(resolvedTrainer['full_name']) ??
        normOptString(resolvedTrainer['fullName']) ??
        trainerId;

    final disciplineName =
        normOptString(resolvedTrainer['discipline']) ??
        normOptString(resolvedTrainer['discipline_name']) ??
        normOptString(resolvedTrainer['disciplineName']) ??
        'No discipline';

    final capabilityDescription =
        normOptString(json['capabilityDescription']) ??
        normOptString(json['classTypeDescription']) ??
        normOptString(json['serviceName']) ??
        defaultCapabilityDescription ??
        'Class option';
    final classTypeId =
        parseOptInt(json['class_type_id']) ??
        parseOptInt(json['classTypeId']) ??
        defaultCapabilityId ??
        0;
    final locationId =
        parseOptInt(json['location_id']) ??
        parseOptInt(json['locationId']) ??
        parseOptInt(resolvedLocation['location_id']) ??
        parseOptInt(resolvedLocation['locationId']) ??
        defaultLocationId ??
        0;
    final slotAssignmentCode =
        normOptString(json['slot_assignment_code']) ??
        normOptString(json['slotAssignmentCode']) ??
        '';

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
