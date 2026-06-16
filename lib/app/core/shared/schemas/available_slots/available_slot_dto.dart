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

  // Maps the `SlotResponse` contract from GET /slots (snake_case). Slot search
  // exposes only a `location_id` (no location name) and no service entity; the
  // `schedule_type` doubles as the displayed service label, and there is no
  // booking id yet, so a stable key is synthesized from the slot's identity.
  factory AvailableSlotDto.fromJson(Map<String, dynamic> json) {
    final trainer = normReqMap(json['trainer']);
    final trainerName = normOptString(trainer['full_name']) ?? '';
    final serviceName = normOptString(json['schedule_type']) ?? '';
    final disciplineName = normOptString(trainer['discipline_name']) ?? '';
    final locationId = parseOptInt(json['location_id']);
    final trainerCode = parseOptInt(trainer['trainer_code']);
    final disciplineCode = parseOptInt(trainer['discipline_id']);
    final parsedSchedulingDate = parseOptDateTime(json['slot_datetime']);
    final bookingId = [
      locationId?.toString(),
      trainerCode?.toString(),
      parsedSchedulingDate.toIso8601String(),
    ].whereType<String>().join('|');

    return AvailableSlotDto(
      bookingId: bookingId.isEmpty
          ? parsedSchedulingDate.toIso8601String()
          : bookingId,
      schedulingDate: parsedSchedulingDate,
      serviceName: serviceName,
      trainerName: trainerName.isNotEmpty
          ? trainerName
          : (trainerCode?.toString() ?? ''),
      disciplineName: disciplineName,
      // SlotResponse carries no location name; the UI falls back to a label.
      locationName: '',
      duration: null,
      locationId: locationId,
      trainerCode: trainerCode,
      disciplineCode: disciplineCode,
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
