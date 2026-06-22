import 'package:flutter_test/flutter_test.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';

void main() {
  group('AvailableSlotByCapabilityDto.fromJson', () {
    test('maps the ClassTypeAvailabilityItem contract', () {
      final json = <String, dynamic>{
        'slot_datetime': '2026-03-27T12:00:00',
        'slot_assignment_code': 'SL-100',
        'schedule_type': 'GROUP',
        'trainer': {
          'trainer_id': 2,
          'full_name': 'Taylor Coach',
          'discipline_id': 2,
          'discipline_name': 'Strength',
        },
      };

      final dto = AvailableSlotByCapabilityDto.fromJson(
        json,
        defaultCapabilityId: 77,
        defaultCapabilityDescription: 'Sunrise Yoga',
      );

      expect(
        dto.schedulingDate,
        DateTime.parse('2026-03-27T12:00:00').toLocal(),
      );
      expect(dto.trainerId, '2');
      // The item has no separate trainer_code; the trainer id doubles as it.
      expect(dto.trainerCode, 2);
      expect(dto.trainerName, 'Taylor Coach');
      expect(dto.disciplineName, 'Strength');
      expect(dto.slotAssignmentCode, 'SL-100');
      // Class option and description aren't on the slot; they come from the
      // request-provided defaults.
      expect(dto.capabilityDescription, 'Sunrise Yoga');
      expect(dto.classTypeId, 77);
    });

    test('falls back to placeholder labels when defaults are absent', () {
      final json = <String, dynamic>{
        'slot_datetime': '2026-03-25T17:45:00',
        'slot_assignment_code': 'SL-200',
        'trainer': {'trainer_id': 8, 'full_name': 'Jordan Coach'},
      };

      final dto = AvailableSlotByCapabilityDto.fromJson(json);

      expect(dto.trainerId, '8');
      expect(dto.trainerName, 'Jordan Coach');
      expect(dto.disciplineName, 'No discipline');
      expect(dto.capabilityDescription, 'Class option');
      expect(dto.classTypeId, 0);
    });
  });
}
