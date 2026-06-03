import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:portfolio_mobile_app/app/core/utils/parse.dart';

class AvailableSlotDto {
  const AvailableSlotDto({
    required this.bookingId,
    required this.schedulingDate,
    required this.serviceName,
    required this.trainerName,
    required this.disciplineName,
    required this.locationName,
    this.duration,
    this.locationId,
    this.trainerCode,
    this.disciplineCode,
  });

  final String bookingId;
  final DateTime schedulingDate;
  final String serviceName;
  final String trainerName;
  final String disciplineName;
  final String locationName;
  final int? duration;
  final int? locationId;
  final int? trainerCode;
  final int? disciplineCode;

  factory AvailableSlotDto.fromJson(Map<String, dynamic> json) {
    final trainer = normReqMap(json['trainer']);
    final service = normReqMap(json['service']);
    final location = normReqMap(json['location']);
    final trainerCode =
        normOptString(trainer['id']) ??
        normOptString(trainer['trainer_id']) ??
        '';
    final trainerName =
        normOptString(trainer['name']) ??
        normOptString(trainer['full_name']) ??
        '';
    final serviceName =
        normOptString(service['serviceName']) ??
        normOptString(json['schedule_type']) ??
        normOptString(json['serviceName']) ??
        '';
    final disciplineName =
        normOptString(trainer['discipline']) ??
        normOptString(trainer['discipline_name']) ??
        normOptString(trainer['disciplineName']) ??
        '';
    final locationName =
        normOptString(json['locationName']) ??
        normOptString(location['name']) ??
        '';
    final locationId =
        parseOptInt(location['locationId']) ??
        parseOptInt(location['location_id']) ??
        parseOptInt(json['locationId']) ??
        parseOptInt(json['location_id']);
    final duration =
        parseOptInt(json['durationMinutes']) ??
        parseOptInt(json['bookingDuration']) ??
        parseOptInt(json['duration']);
    final parsedTrainerCode =
        parseOptInt(trainer['trainer_code']) ??
        parseOptInt(trainer['id']) ??
        parseOptInt(trainer['trainer_id']) ??
        parseOptInt(json['trainerCode']) ??
        parseOptInt(json['trainer_id']) ??
        parseOptInt(json['trainer_code']);
    final parsedDisciplineCode =
        parseOptInt(trainer['disciplineId']) ??
        parseOptInt(trainer['discipline_id']) ??
        parseOptInt(trainer['idDiscipline']) ??
        parseOptInt(json['disciplineCode']) ??
        parseOptInt(json['discipline_id']);
    final parsedSchedulingDate =
        parseOptDateTime(json['bookingDateTime']) !=
            DateTime.fromMillisecondsSinceEpoch(0)
        ? parseOptDateTime(json['bookingDateTime'])
        : parseOptDateTime(
            json['slot_datetime'] ?? json['slotDateTime'] ?? json['dateTime'],
          );
    final bookingId =
        normOptString(json['bookingId']) ??
        normOptString(json['id']) ??
        [
          locationId?.toString(),
          parsedTrainerCode?.toString(),
          parsedSchedulingDate.toIso8601String(),
        ].whereType<String>().join('|');

    return AvailableSlotDto(
      bookingId: bookingId.isEmpty
          ? parsedSchedulingDate.toIso8601String()
          : bookingId,
      schedulingDate: parsedSchedulingDate,
      serviceName: serviceName,
      trainerName: trainerName.isNotEmpty ? trainerName : trainerCode,
      disciplineName: disciplineName,
      locationName: locationName,
      duration: duration,
      locationId: locationId,
      trainerCode: parsedTrainerCode,
      disciplineCode: parsedDisciplineCode,
    );
  }

  Map<String, dynamic> toTrainerAvailabilityRow() {
    final serviceLabel = serviceName.trim();
    final locationLabel = locationName.trim();
    return {
      'schedulingDate': schedulingDate,
      'service': serviceLabel.isEmpty ? 'Servicio sin nombre' : serviceLabel,
      'location': locationLabel.isEmpty
          ? 'Centro por confirmar'
          : locationLabel,
      'slot': this,
    };
  }

  Map<String, dynamic> toDisciplineAvailabilityRow() {
    final trainerLabel = trainerName.trim();
    final disciplineLabel = disciplineName.trim();
    final locationLabel = locationName.trim();
    return {
      'schedulingDate': schedulingDate,
      'trainerName': trainerLabel.isEmpty
          ? 'Profesional por confirmar'
          : trainerLabel,
      'disciplineName': disciplineLabel.isEmpty
          ? 'Especialidad por confirmar'
          : disciplineLabel,
      'locationName': locationLabel.isEmpty
          ? 'Centro por confirmar'
          : locationLabel,
      'slot': this,
    };
  }

  Map<String, dynamic> toBookingsTableRow() {
    final trainerLabel = trainerName.trim();
    final locationLabel = locationName.trim();
    final serviceLabel = serviceName.trim();
    final disciplineLabel = disciplineName.trim();
    return {
      'schedulingDate': schedulingDate,
      'trainerName': trainerLabel.isEmpty
          ? 'Profesional por confirmar'
          : trainerLabel,
      'locationName': locationLabel.isEmpty
          ? 'Centro por confirmar'
          : locationLabel,
      'serviceName': serviceLabel.isEmpty
          ? 'Servicio sin nombre'
          : serviceLabel,
      'disciplineName': disciplineLabel.isEmpty
          ? 'Especialidad por confirmar'
          : disciplineLabel,
      'bookingId': bookingId,
      'slot': this,
    };
  }
}
