import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/location_code_registry.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/booking/schedule_booking_by_class_type_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/booking/schedule_booking_request.dart';

class BookingAgendaApi extends ApiBase {
  BookingAgendaApi() : super();

  // Statuses that must never surface as "upcoming": a cancelled or completed
  // booking is no longer a future commitment. Matches the backend's English
  // booking_status vocabulary (PENDING/CONFIRMED/CANCELLED/COMPLETED); the
  // legacy Spanish codes are kept so older data is filtered too.
  static const Set<String> _inactiveStates = {
    'CANCELLED',
    'ANULADA',
    'COMPLETED',
    'COMPLETADA',
  };

  /// Returns the soonest booking at or after "now", drawn from the same full
  /// agenda the Bookings table lists (all locations, no date window), so the
  /// home summary always mirrors the next entry the user sees in that table.
  /// Cancelled and completed bookings are skipped. Returns null when nothing
  /// is upcoming.
  Future<AvailableSlotDto?> getNextUpcomingBooking({String? memberId}) async {
    final trimmedId = memberId?.trim();
    final now = DateTime.now().toLocal();

    final agendas = await getAgenda(
      memberId: trimmedId?.isEmpty ?? true ? null : trimmedId,
      includeAllLocations: true,
    );

    if (agendas.isEmpty) {
      return null;
    }

    final upcoming = agendas
        .where((agenda) {
          final state = agenda.state.trim().toUpperCase();
          return !_inactiveStates.contains(state) &&
              !agenda.schedulingDate.toLocal().isBefore(now);
        })
        .toList(growable: false)
      ..sort((a, b) => a.schedulingDate.compareTo(b.schedulingDate));

    if (upcoming.isEmpty) {
      return null;
    }

    return _mapAgendaToAvailableBooking(upcoming.first);
  }

  Future<List<BookingDto>> getAgenda({
    String? memberId,
    DateTime? startDate,
    DateTime? endDate,
    String? locationCode,
    String? bookingStatus,
    String? disciplineId,
    String? trainerId,
    bool includeAllLocations = false,
  }) async {
    final request = BookingRequest(
      memberId: memberId,
      startDate: startDate,
      endDate: endDate,
      locationCode: locationCode,
      bookingStatus: bookingStatus,
      disciplineId: disciplineId,
      trainerId: trainerId,
    );
    final queryParameters = await request.toQueryParameters(
      defaultLocationCode: includeAllLocations ? '' : null,
    );
    final normalizedLocationCode = LocationCodeRegistry.instance.resolve(
      queryParameters['locationCode'] ?? '',
    );

    return getDataListAsync<BookingDto>(
      url: ApiUrls.bookingsUrl,
      requestErrorMessage: 'Error al obtener citas del paciente',
      queryParameters: <String, String>{
        'date_from': queryParameters['startDate'] ?? '',
        'date_to': queryParameters['endDate'] ?? '',
        if (normalizedLocationCode.trim().isNotEmpty)
          'location_code': normalizedLocationCode,
        if ((queryParameters['bookingStatus'] ?? '').trim().isNotEmpty &&
            queryParameters['bookingStatus'] != '0')
          'booking_status': queryParameters['bookingStatus']!,
        if ((queryParameters['disciplineId'] ?? '').trim().isNotEmpty &&
            queryParameters['disciplineId'] != '0')
          'discipline_id': queryParameters['disciplineId']!,
        if ((queryParameters['trainerId'] ?? '').trim().isNotEmpty &&
            queryParameters['trainerId'] != '0')
          'trainer_id': queryParameters['trainerId']!,
      },
      fromJson: BookingDto.fromJson,
    );
  }

  Future<void> scheduleBooking({
    required ScheduleBookingRequest request,
  }) async {
    await createAsync<void>(
      url: '${ApiUrls.bookingsUrl}/by-trainer',
      requestBody: <String, dynamic>{
        'booking_date': _toApiDate(request.trimmedDate),
        'booking_time': _toApiTime(request.trimmedTime),
        'location_code': LocationCodeRegistry.instance.resolve(
          request.trimmedLocationCode,
        ),
        'session_duration_minutes': request.bookingDuration,
        'discipline_code': request.disciplineCode.toString(),
        'trainer_code': request.trainerCode,
        'notes': request.trimmedObservation,
      },
      requestErrorMessage: 'Error al agendar cita',
    );
  }

  Future<void> scheduleBookingByClassType({
    required ScheduleBookingByClassTypeRequest request,
  }) async {
    await createAsync<void>(
      url: '${ApiUrls.bookingsUrl}/by-class-type',
      requestBody: <String, dynamic>{
        'booking_date': _toApiDate(request.bookingDate),
        'booking_time': _toApiTime(request.bookingTime),
        'location_code': LocationCodeRegistry.instance.resolve(
          request.locationCode,
        ),
        'trainer_code': request.trainerCode,
        'slot_assignment_code': request.slotAssignmentCode,
        'class_type_id': request.classTypeId,
        if ((request.notes ?? '').trim().isNotEmpty)
          'notes': request.notes!.trim(),
      },
      requestErrorMessage: 'Error al agendar clase',
    );
  }


  String _toApiDate(String rawDate) {
    final normalized = rawDate.trim();
    if (normalized.isEmpty) {
      return normalized;
    }
    if (RegExp(r'^\d{8}$').hasMatch(normalized)) {
      return '${normalized.substring(0, 4)}-${normalized.substring(4, 6)}-${normalized.substring(6, 8)}';
    }
    return normalized;
  }

  String _toApiTime(String rawTime) {
    final normalized = rawTime.trim();
    if (normalized.isEmpty) {
      return normalized;
    }
    if (RegExp(r'^\d{4}$').hasMatch(normalized)) {
      return '${normalized.substring(0, 2)}:${normalized.substring(2, 4)}';
    }
    return normalized;
  }

  AvailableSlotDto _mapAgendaToAvailableBooking(BookingDto agenda) {
    return AvailableSlotDto(
      bookingId: agenda.bookingId,
      schedulingDate: agenda.schedulingDate,
      serviceName: agenda.serviceName ?? '',
      trainerName: agenda.trainerName ?? '',
      disciplineName: agenda.disciplineName ?? '',
      locationName: agenda.locationName,
      duration: agenda.duration,
      locationId: agenda.locationId,
    );
  }
}
