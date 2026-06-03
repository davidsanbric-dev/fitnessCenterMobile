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
    this.trainerId,
    this.trainerName,
    this.disciplineId,
    this.disciplineName,
    this.serviceId,
    this.serviceName,
    this.preparation,
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
  final String? trainerId;
  final String? trainerName;
  final int? disciplineId;
  final String? disciplineName;
  final int? serviceId;
  final String? serviceName;
  final String? preparation;

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    final trainer = normReqMap(json['trainer']);
    final service = normReqMap(json['service']);
    final classType = normReqMap(json['class_type']);
    final location = normReqMap(json['location']);
    final member = normReqMap(json['member']);
    final category = normReqMap(json['category']);
    final resolvedService = service;
    final resolvedCreationDate =
        json['creationDate'] ??
        json['scheduled_at'] ??
        json['schedulingDateTime'];
    final resolvedSchedulingDate =
        json['booking_datetime'] ??
        json['bookingDateTime'] ??
        json['schedulingDate'] ??
        json['schedulingDateTime'];
    final resolvedTrainer = trainer;
    final resolvedServiceNode = resolvedService.isNotEmpty
        ? resolvedService
        : classType;
    final resolvedLocation = location;
    final locationIdRaw =
        resolvedLocation['locationId'] ??
        resolvedLocation['location_id'] ??
        resolvedLocation['locationId'] ??
        json['locationId'];
    final locationNameRaw =
        resolvedLocation['locationName'] ??
        resolvedLocation['name'] ??
        json['locationName'];
    final serviceNameRaw =
        resolvedServiceNode['serviceName'] ?? resolvedServiceNode['name'];

    return BookingDto(
      bookingId: normReqString(json['bookingId'] ?? json['booking_id']),
      creationDate: parseOptDateTime(resolvedCreationDate),
      schedulingDate: parseOptDateTime(resolvedSchedulingDate),
      state: normReqString(
        json['bookingStatus'] ?? json['state'] ?? json['booking_status'],
      ),
      duration: normReqInt(
        json['durationMinutes'] ??
            json['duration'] ??
            json['session_duration_minutes'],
      ),
      memberRut: normOptString(member['rut']) ?? '',
      memberName: normOptString(member['fullName'] ?? member['name']) ?? '',
      memberPhone:
          normOptString(
            member['mobilePhone'] ?? member['landlinePhone'] ?? member['phone'],
          ) ??
          '',
      locationId: normReqInt(locationIdRaw ?? 0),
      locationName: normReqString(locationNameRaw ?? ''),
      trainerId: normOptString(
        resolvedTrainer['trainerId'] ??
            resolvedTrainer['trainer_id'] ??
            resolvedTrainer['id'],
      ),
      trainerName: normOptString(
        resolvedTrainer['fullName'] ??
            resolvedTrainer['name'] ??
            resolvedTrainer['full_name'],
      ),
      disciplineId: normOptInt(
        resolvedTrainer['disciplineId'] ??
            resolvedTrainer['discipline_id'] ??
            category['category_id'] ??
            category['categoryId'],
      ),
      disciplineName: normOptString(
        resolvedTrainer['disciplineName'] ??
            resolvedTrainer['discipline_name'] ??
            category['name'],
      ),
      serviceId: normOptInt(
        resolvedServiceNode['serviceId'] ??
            resolvedServiceNode['class_type_id'] ??
            resolvedServiceNode['classTypeId'],
      ),
      serviceName: normOptString(serviceNameRaw),
      preparation:
          normOptString(json['preparation']) ??
          normOptString(json['preparation_info']),
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
    String? trainerId,
    String? trainerName,
    int? disciplineId,
    String? disciplineName,
    int? serviceId,
    String? serviceName,
    String? preparation,
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
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      disciplineId: disciplineId ?? this.disciplineId,
      disciplineName: disciplineName ?? this.disciplineName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      preparation: preparation ?? this.preparation,
    );
  }
}
