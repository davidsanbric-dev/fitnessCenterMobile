import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

/// Filters for the bookings agenda list. Emits a camelCase intermediate that
/// `BookingAgendaApi.getAgenda` remaps to the backend's snake_case query params
/// (date_from/date_to/location_code/booking_status/discipline_id/trainer_id).
/// The endpoint scopes results to the authenticated user, so there is no member
/// filter.
class BookingRequest {
  const BookingRequest({
    this.startDate,
    this.endDate,
    this.locationCode,
    this.bookingStatus,
    this.disciplineId,
    this.trainerId,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? locationCode;
  final String? bookingStatus;
  final String? disciplineId;
  final String? trainerId;

  static DateTime _defaultStartDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _defaultEndDate(DateTime baseStartDate) =>
      baseStartDate.add(const Duration(days: 14));
  static const String _defaultLocationCode = '1';
  static const String _defaultBookingStatus = '';
  static const String _defaultDisciplineId = '0';
  static const String _defaultTrainerId = '0';

  Map<String, String> toQueryParameters({
    DateTime? defaultStartDate,
    DateTime? defaultEndDate,
    String? defaultLocationCode,
    String? defaultBookingStatus,
    String? defaultDisciplineId,
    String? defaultTrainerId,
  }) {
    final resolvedStartDate =
        (startDate ?? defaultStartDate ?? _defaultStartDate()).toLocal();
    final resolvedEndDate =
        (endDate ?? defaultEndDate ?? _defaultEndDate(resolvedStartDate))
            .toLocal();
    if (resolvedEndDate.isBefore(resolvedStartDate)) {
      throw const ApiException('End date must be later than start date.');
    }

    final resolvedLocationCode =
        normOptString(locationCode) ??
        defaultLocationCode ??
        _defaultLocationCode;
    final resolvedStatus =
        normOptString(bookingStatus) ??
        defaultBookingStatus ??
        _defaultBookingStatus;
    final resolvedDiscipline =
        normOptString(disciplineId) ??
        defaultDisciplineId ??
        _defaultDisciplineId;
    final resolvedTrainer =
        normOptString(trainerId) ?? defaultTrainerId ?? _defaultTrainerId;

    return <String, String>{
      'startDate': formatDate(resolvedStartDate),
      'endDate': formatDate(resolvedEndDate),
      'locationCode': resolvedLocationCode,
      'bookingStatus': resolvedStatus,
      'disciplineId': resolvedDiscipline,
      'trainerId': resolvedTrainer,
    };
  }
}
