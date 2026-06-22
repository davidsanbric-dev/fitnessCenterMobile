import 'package:flutter_test/flutter_test.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';

void main() {
  group('AvailableSlotDto.fromJson', () {
    test('maps the SlotResponse contract', () {
      final json = <String, dynamic>{
        'slot_datetime': '2026-03-24T15:30:00Z',
        'slot_assignment_code': 'SL-1',
        'schedule_type': 'GROUP',
        'is_available': true,
        'trainer': {
          'trainer_id': 11,
          'trainer_code': 500,
          'full_name': 'Chris Trainer',
          'discipline_id': 8,
          'discipline_name': 'Functional',
        },
      };

      final dto = AvailableSlotDto.fromJson(json);

      expect(
        dto.schedulingDate,
        DateTime.parse('2026-03-24T15:30:00Z').toLocal(),
      );
      // Slot search carries no service entity.
      expect(dto.serviceName, 'GROUP');
      expect(dto.duration, null);
      expect(dto.trainerCode, 500);
      expect(dto.trainerName, 'Chris Trainer');
      expect(dto.disciplineCode, 8);
      expect(dto.disciplineName, 'Functional');
      // No booking id exists yet; a stable key is synthesized from identity.
      expect(dto.bookingId, startsWith('500|'));
    });

    test('synthesizes a date-only key when identity fields are missing', () {
      final json = <String, dynamic>{
        'slot_datetime': '2026-03-25T07:00:00Z',
        'schedule_type': 'PERSONAL',
        'is_available': true,
        'trainer': {
          'trainer_id': 15,
          'full_name': 'Coach K',
          'discipline_id': 3,
          'discipline_name': 'Strength',
        },
      };

      final dto = AvailableSlotDto.fromJson(json);

      expect(dto.trainerCode, null);
      expect(dto.trainerName, 'Coach K');
      expect(dto.disciplineCode, 3);
      expect(dto.disciplineName, 'Strength');
      expect(dto.serviceName, 'PERSONAL');
      expect(dto.bookingId, dto.schedulingDate.toIso8601String());
    });
  });
}
