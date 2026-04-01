import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';

void main() {
  group('AvailableSlotByCapabilityDto.fromJson', () {
    test('maps gym-domain capability booking payload', () {
      final json = <String, dynamic>{
        'bookingDateTime': '2026-03-24T13:00:00Z',
        'locationName': 'Central Gym',
        'capabilityDescription': 'Strength Intro Class',
        'trainer': {
          'id': '22',
          'name': 'Morgan Trainer',
          'discipline': 'Strength',
        },
      };

      final dto = AvailableSlotByCapabilityDto.fromJson(json);

      expect(
        dto.schedulingDate,
        DateTime.parse('2026-03-24T13:00:00Z').toLocal(),
      );
      expect(dto.locationName, 'Central Gym');
      expect(dto.trainerId, '22');
      expect(dto.trainerName, 'Morgan Trainer');
      expect(dto.disciplineName, 'Strength');
      expect(dto.capabilityDescription, 'Strength Intro Class');
    });

    test('maps partial legacy capability payload with defaults', () {
      final json = <String, dynamic>{
        'schedulingDateTime': '2026-03-25T17:45:00Z',
        'branchName': 'Legacy Branch',
        'serviceName': 'Legacy Capability Name',
        'professional': {
          'professionalCode': 'PRO-44',
          'professionalName': 'Legacy Professional',
          'especialidad': 'Kinesiologia',
        },
      };

      final dto = AvailableSlotByCapabilityDto.fromJson(json);

      expect(
        dto.schedulingDate,
        DateTime.parse('2026-03-25T17:45:00Z').toLocal(),
      );
      expect(dto.locationName, 'Club location');
      expect(dto.trainerId, '');
      expect(dto.trainerName, '');
      expect(dto.disciplineName, 'No discipline');
      expect(dto.capabilityDescription, 'Legacy Capability Name');
    });

    test('maps backend class-type availability slot payload', () {
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
        defaultCapabilityDescription: 'Sunrise Yoga',
      );

      expect(
        dto.schedulingDate,
        DateTime.parse('2026-03-27T12:00:00').toLocal(),
      );
      expect(dto.trainerId, '2');
      expect(dto.trainerName, 'Taylor Coach');
      expect(dto.disciplineName, 'Strength');
      expect(dto.capabilityDescription, 'Sunrise Yoga');
    });
  });
}
