import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:portfolio_mobile_app/app/core/utils/parse.dart';

class AvailableSlotDto {
  const AvailableSlotDto({
    required this.bookingId,
    required this.schedulingDate,
    required this.serviceName,
    required this.trainerName,
    required this.disciplineName,
    this.duration,
    this.trainerCode,
    this.disciplineCode,
  });

  final String bookingId;
  final DateTime schedulingDate;
  final String serviceName;
  final String trainerName;
  final String disciplineName;
  final int? duration;
  final int? trainerCode;
  final int? disciplineCode;

  // Maps the `SlotResponse` contract from GET /slots (snake_case). Slot search
  // exposes no service entity; the `schedule_type` doubles as the displayed
  // service label, and there is no booking id yet, so a stable key is
  // synthesized from the slot's identity.
  factory AvailableSlotDto.fromJson(Map<String, dynamic> json) {
    final trainer = normReqMap(json['trainer']);
    final trainerName = normOptString(trainer['full_name']) ?? '';
    final serviceName = normOptString(json['schedule_type']) ?? '';
    final disciplineName = normOptString(trainer['discipline_name']) ?? '';
    final trainerCode = parseOptInt(trainer['trainer_code']);
    final disciplineCode = parseOptInt(trainer['discipline_id']);
    final parsedSchedulingDate = parseOptDateTime(json['slot_datetime']);
    final bookingId = [
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
      duration: null,
      trainerCode: trainerCode,
      disciplineCode: disciplineCode,
    );
  }

  Map<String, dynamic> toTrainerAvailabilityRow() {
    final serviceLabel = serviceName.trim();
    return {
      'schedulingDate': schedulingDate,
      'service': serviceLabel.isEmpty ? 'Servicio sin nombre' : serviceLabel,
      'slot': this,
    };
  }

  Map<String, dynamic> toDisciplineAvailabilityRow() {
    final trainerLabel = trainerName.trim();
    final disciplineLabel = disciplineName.trim();
    return {
      'schedulingDate': schedulingDate,
      'trainerName': trainerLabel.isEmpty
          ? 'Profesional por confirmar'
          : trainerLabel,
      'disciplineName': disciplineLabel.isEmpty
          ? 'Especialidad por confirmar'
          : disciplineLabel,
      'slot': this,
    };
  }

  Map<String, dynamic> toBookingsTableRow() {
    final trainerLabel = trainerName.trim();
    final serviceLabel = serviceName.trim();
    final disciplineLabel = disciplineName.trim();
    return {
      'schedulingDate': schedulingDate,
      'trainerName': trainerLabel.isEmpty
          ? 'Profesional por confirmar'
          : trainerLabel,
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
