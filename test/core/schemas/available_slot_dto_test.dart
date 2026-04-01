import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';

void main() {
  group('AvailableSlotDto.fromJson', () {
    test('maps gym-domain booking availability payload', () {
      final json = <String, dynamic>{
        'bookingId': 'BK-SLOT-01',
        'bookingDateTime': '2026-03-24T15:30:00Z',
        'durationMinutes': 50,
        'isOnline': false,
        'location': {'locationId': 4, 'name': 'North Gym'},
        'trainer': {
          'id': '11',
          'name': 'Chris Trainer',
          'discipline': 'Functional',
          'disciplineId': 8,
        },
        'service': {'serviceName': 'Functional Group'},
      };

      final dto = AvailableSlotDto.fromJson(json);

      expect(dto.bookingId, 'BK-SLOT-01');
      expect(
        dto.schedulingDate,
        DateTime.parse('2026-03-24T15:30:00Z').toLocal(),
      );
      expect(dto.duration, 50);
      expect(dto.locationId, 4);
      expect(dto.locationName, 'North Gym');
      expect(dto.trainerCode, 11);
      expect(dto.trainerName, 'Chris Trainer');
      expect(dto.disciplineCode, 8);
      expect(dto.disciplineName, 'Functional');
      expect(dto.serviceName, 'Functional Group');
      expect(dto.isOnline, false);
    });

    test('maps partial legacy availability payload with defaults', () {
      final json = <String, dynamic>{
        'id': 'legacy-slot-9',
        'bookingDateTime': '2026-03-25T07:00:00Z',
        'duration': 30,
        'Telemedicina': 1,
        'idSucursal': 19,
        'locationName': 'Legacy Branch Label',
        'trainerCode': '15',
        'disciplineCode': '44',
        'trainer': {
          'id': '15',
          'name': 'Legacy Professional',
          'especialidad': 'Pilates',
          'idespecialidad': '44',
        },
        'serviceName': 'Legacy Service Name',
      };

      final dto = AvailableSlotDto.fromJson(json);

      expect(dto.bookingId, 'legacy-slot-9');
      expect(
        dto.schedulingDate,
        DateTime.parse('2026-03-25T07:00:00Z').toLocal(),
      );
      expect(dto.duration, 30);
      expect(dto.locationId, null);
      expect(dto.locationName, 'Legacy Branch Label');
      expect(dto.trainerCode, 15);
      expect(dto.trainerName, 'Legacy Professional');
      expect(dto.disciplineCode, 44);
      expect(dto.disciplineName, '');
      expect(dto.serviceName, 'Legacy Service Name');
      expect(dto.isOnline, null);
    });
  });
}
