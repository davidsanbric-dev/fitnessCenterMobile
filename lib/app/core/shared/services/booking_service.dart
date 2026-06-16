import 'package:portfolio_mobile_app/app/core/api/bookings_api.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/booking/booking_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/booking/booking_state_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/update_booking_status_request.dart';

class BookingService {
  BookingService({BookingsApi? agendaApi})
    : _agendaApi = agendaApi ?? BookingsApi();

  final BookingsApi _agendaApi;

  Future<List<BookingStateDto>> fetchBookingStates() {
    return _agendaApi.getBookingStates();
  }

  Future<BookingDto> fetchBooking({
    required String bookingId,
    required Object locationCode,
  }) {
    return _agendaApi.getBooking(
      BookingRequest(
        bookingId: bookingId.trim(),
        locationCode: _resolveLocationCode(locationCode),
      ),
    );
  }

  Future<BookingDto> fetchBookingDetails({
    required String bookingId,
    required Object locationCode,
  }) {
    return fetchBooking(bookingId: bookingId, locationCode: locationCode);
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String state,
    required Object locationCode,
    String? observation,
  }) {
    return _agendaApi.updateBookingStatus(
      UpdateBookingStatusRequest(
        bookingId: bookingId,
        state: state,
        locationCode: _resolveLocationCode(locationCode),
        observation: observation,
      ),
    );
  }

  String _resolveLocationCode(Object locationCode) {
    final resolved = locationCode.toString().trim();
    if (resolved.isEmpty) {
      throw ArgumentError.value(
        locationCode,
        'locationCode',
        'Cannot be empty',
      );
    }
    return resolved;
  }
}
