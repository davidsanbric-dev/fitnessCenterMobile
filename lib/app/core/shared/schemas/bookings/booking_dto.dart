import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:portfolio_mobile_app/app/core/utils/parse.dart';

class BookingDto {
  const BookingDto({
    required this.bookingId,
    required this.creationDate,
    required this.schedulingDate,
    required this.state,
    required this.duration,
    required this.memberRut,
    required this.memberName,
    required this.memberPhone,
    required this.locationId,
    required this.locationName,
    this.locationCode,
    this.trainerId,
    this.trainerName,
    this.disciplineId,
    this.disciplineName,
    this.serviceId,
    this.serviceName,
    this.preparation,
    this.notes,
  });

  final String bookingId;
  final DateTime creationDate;
  final DateTime schedulingDate;
  final String state;
  final int duration;
  final String memberRut;
  final String memberName;
  final String memberPhone;
  final int locationId;
  final String locationName;
  final String? locationCode;
  final String? trainerId;
  final String? trainerName;
  final int? disciplineId;
  final String? disciplineName;
  final int? serviceId;
  final String? serviceName;
  final String? preparation;
  final String? notes;

  // Maps the `BookingResponse` contract from GET /bookings and
  // GET /bookings/{id} (snake_case). `scheduled_at` is the booking's creation
  // timestamp; `booking_datetime` is the session time. The discipline comes from
  // the trainer node, falling back to the booking's class category (both are
  // real nodes on the response, not legacy aliases).
  factory BookingDto.fromJson(Map<String, dynamic> json) {
    final trainer = normReqMap(json['trainer']);
    final classType = normReqMap(json['class_type']);
    final location = normReqMap(json['location']);
    final member = normReqMap(json['member']);
    final category = normReqMap(json['category']);

    return BookingDto(
      bookingId: normReqString(json['booking_id']),
      creationDate: parseOptDateTime(json['scheduled_at']),
      schedulingDate: parseOptDateTime(json['booking_datetime']),
      state: normReqString(json['booking_status']),
      duration: normReqInt(json['session_duration_minutes']),
      memberRut: normOptString(member['rut']) ?? '',
      memberName: normOptString(member['full_name']) ?? '',
      memberPhone: normOptString(member['mobile_phone']) ?? '',
      locationId: normReqInt(location['location_id'] ?? 0),
      locationName: normReqString(location['name'] ?? ''),
      locationCode: normOptString(location['location_code']),
      trainerId: normOptString(trainer['trainer_id']),
      trainerName: normOptString(trainer['full_name']),
      disciplineId: normOptInt(
        trainer['discipline_id'] ?? category['category_id'],
      ),
      disciplineName: normOptString(
        trainer['discipline_name'] ?? category['name'],
      ),
      serviceId: normOptInt(classType['class_type_id']),
      serviceName: normOptString(classType['name']),
      preparation: normOptString(json['preparation_info']),
      notes: normOptString(json['notes']),
    );
  }

  Map<String, String> toTableRow() {
    return {
      'id': bookingId,
      'creationDate': formatDateTimeLabel(creationDate),
      'schedulingDateIso': schedulingDate.toIso8601String(),
      'state': state.isEmpty ? 'Sin estado' : state,
      'memberName': memberName,
      'location': locationName,
    };
  }

  BookingDto copyWith({
    String? bookingId,
    DateTime? creationDate,
    DateTime? schedulingDate,
    String? state,
    int? duration,
    String? memberRut,
    String? memberName,
    String? memberPhone,
    int? locationId,
    String? locationName,
    String? locationCode,
    String? trainerId,
    String? trainerName,
    int? disciplineId,
    String? disciplineName,
    int? serviceId,
    String? serviceName,
    String? preparation,
    String? notes,
  }) {
    return BookingDto(
      bookingId: bookingId ?? this.bookingId,
      creationDate: creationDate ?? this.creationDate,
      schedulingDate: schedulingDate ?? this.schedulingDate,
      state: state ?? this.state,
      duration: duration ?? this.duration,
      memberRut: memberRut ?? this.memberRut,
      memberName: memberName ?? this.memberName,
      memberPhone: memberPhone ?? this.memberPhone,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      locationCode: locationCode ?? this.locationCode,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      disciplineId: disciplineId ?? this.disciplineId,
      disciplineName: disciplineName ?? this.disciplineName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      preparation: preparation ?? this.preparation,
      notes: notes ?? this.notes,
    );
  }
}
