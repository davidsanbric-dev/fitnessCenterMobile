import 'package:flutter_test/flutter_test.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';

void main() {
  group('BookingDto.fromJson', () {
    test('maps the full BookingResponse contract', () {
      final json = <String, dynamic>{
        'booking_id': 5,
        'booking_status': 'COMPLETED',
        // scheduled_at is the creation timestamp; booking_datetime the session.
        'scheduled_at': '2026-03-23T08:15:00Z',
        'booking_datetime': '2026-03-24T09:30:00Z',
        'session_duration_minutes': 45,
        'preparation_info': 'Bring water bottle',
        'notes': 'Great session',
        'member': {
          'user_id': 1,
          'full_name': 'John Member',
          'rut': '11111111-1',
          'mobile_phone': '+56912345678',
          'email': 'john@example.com',
        },
        'trainer': {
          'trainer_id': 100,
          'full_name': 'Alex Trainer',
          'discipline_id': 22,
          'discipline_name': 'CrossFit',
        },
        'class_type': {
          'class_type_id': 77,
          'name': 'HIIT Session',
          'type_name': 'GROUP',
        },
        // Present to confirm the trainer discipline takes precedence over it.
        'category': {'category_id': 9, 'name': 'Conditioning'},
      };

      final dto = BookingDto.fromJson(json);

      expect(dto.bookingId, '5');
      expect(
        dto.creationDate,
        DateTime.parse('2026-03-23T08:15:00Z').toLocal(),
      );
      expect(
        dto.schedulingDate,
        DateTime.parse('2026-03-24T09:30:00Z').toLocal(),
      );
      expect(dto.state, 'COMPLETED');
      expect(dto.duration, 45);
      expect(dto.memberRut, '11111111-1');
      expect(dto.memberName, 'John Member');
      expect(dto.memberPhone, '+56912345678');
      expect(dto.trainerId, '100');
      expect(dto.trainerName, 'Alex Trainer');
      expect(dto.disciplineId, 22);
      expect(dto.disciplineName, 'CrossFit');
      expect(dto.serviceId, 77);
      expect(dto.serviceName, 'HIIT Session');
      expect(dto.preparation, 'Bring water bottle');
      expect(dto.notes, 'Great session');
    });

    test('falls back to the class category for the discipline', () {
      final json = <String, dynamic>{
        'booking_id': 6,
        'booking_status': 'CONFIRMED',
        'scheduled_at': '2026-03-20T10:00:00Z',
        'booking_datetime': '2026-03-21T11:30:00Z',
        // Trainer without a discipline -> discipline resolves from the category.
        'trainer': {'trainer_id': 100, 'full_name': 'Alex Trainer'},
        'category': {'category_id': 9, 'name': 'Conditioning'},
      };

      final dto = BookingDto.fromJson(json);

      expect(dto.disciplineId, 9);
      expect(dto.disciplineName, 'Conditioning');
    });

    test('applies defaults when optional nodes are absent', () {
      final json = <String, dynamic>{
        'booking_id': 9,
        'booking_status': 'CONFIRMED',
        'scheduled_at': '2026-03-20T10:00:00Z',
        'booking_datetime': '2026-03-21T11:30:00Z',
        'member': {'user_id': 2, 'full_name': 'Jane Doe'},
      };

      final dto = BookingDto.fromJson(json);

      expect(dto.bookingId, '9');
      expect(dto.state, 'CONFIRMED');
      expect(dto.duration, 0);
      expect(dto.memberRut, '');
      expect(dto.memberName, 'Jane Doe');
      expect(dto.memberPhone, '');
      expect(dto.trainerId, null);
      expect(dto.trainerName, null);
      expect(dto.disciplineId, null);
      expect(dto.disciplineName, null);
      expect(dto.serviceId, null);
      expect(dto.serviceName, null);
      expect(dto.preparation, null);
      expect(dto.notes, null);
    });
  });
}
