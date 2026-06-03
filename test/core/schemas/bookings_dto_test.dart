import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';

void main() {
  group('BookingDto.fromJson', () {
    test('maps gym-domain payload fields', () {
      final json = <String, dynamic>{
        'bookingId': 'BK-001',
        'creationDate': '2026-03-23T08:15:00Z',
        'bookingDateTime': '2026-03-24T09:30:00Z',
        'bookingStatus': 'confirmed',
        'durationMinutes': 45,
        'member': {
          'rut': '11111111-1',
          'fullName': 'John Member',
          'mobilePhone': '+56912345678',
        },
        'location': {'locationId': 2, 'locationName': 'Downtown Gym'},
        'trainer': {
          'trainerId': 'TR-100',
          'fullName': 'Alex Trainer',
          'disciplineId': 22,
          'disciplineName': 'CrossFit',
        },
        'service': {'serviceId': 77, 'serviceName': 'HIIT Session'},
        'preparation': 'Bring water bottle',
      };

      final dto = BookingDto.fromJson(json);

      expect(dto.bookingId, 'BK-001');
      expect(
        dto.creationDate,
        DateTime.parse('2026-03-23T08:15:00Z').toLocal(),
      );
      expect(
        dto.schedulingDate,
        DateTime.parse('2026-03-24T09:30:00Z').toLocal(),
      );
      expect(dto.state, 'confirmed');
      expect(dto.duration, 45);
      expect(dto.memberRut, '11111111-1');
      expect(dto.memberName, 'John Member');
      expect(dto.memberPhone, '+56912345678');
      expect(dto.locationId, 2);
      expect(dto.locationName, 'Downtown Gym');
      expect(dto.trainerId, 'TR-100');
      expect(dto.trainerName, 'Alex Trainer');
      expect(dto.disciplineId, 22);
      expect(dto.disciplineName, 'CrossFit');
      expect(dto.serviceId, 77);
      expect(dto.serviceName, 'HIIT Session');
      expect(dto.preparation, 'Bring water bottle');
    });

    test('maps partial legacy payload with defaults', () {
      final json = <String, dynamic>{
        'appointmentId': 'APT-009',
        'scheduled_at': '2026-03-20T10:00:00Z',
        'schedulingDateTime': '2026-03-21T11:30:00Z',
        'state': 'scheduled',
        'session_duration_minutes': 30,
        'member': {
          'rut': '22222222-2',
          'name': 'Legacy Member',
          'phone': '+56998765432',
        },
        'branch': {'location_id': 9, 'name': 'Legacy Branch'},
        'professional': {
          'professionalCode': 'PRO-9',
          'professionalName': 'Legacy Professional',
          'idSpecialty': 5,
          'especialidad': 'Pilates',
        },
        'service': {'serviceId': 18, 'serviceName': 'Legacy Session'},
        'preparation_info': 'Legacy preparation',
      };

      final dto = BookingDto.fromJson(json);

      expect(dto.bookingId, 'null');
      expect(
        dto.creationDate,
        DateTime.parse('2026-03-20T10:00:00Z').toLocal(),
      );
      expect(
        dto.schedulingDate,
        DateTime.parse('2026-03-21T11:30:00Z').toLocal(),
      );
      expect(dto.state, 'scheduled');
      expect(dto.duration, 30);
      expect(dto.memberName, 'Legacy Member');
      expect(dto.memberPhone, '+56998765432');
      expect(dto.locationId, 0);
      expect(dto.locationName, '');
      expect(dto.trainerId, null);
      expect(dto.trainerName, null);
      expect(dto.disciplineId, null);
      expect(dto.disciplineName, null);
      expect(dto.serviceId, 18);
      expect(dto.serviceName, 'Legacy Session');
      expect(dto.preparation, 'Legacy preparation');
    });
  });
}
