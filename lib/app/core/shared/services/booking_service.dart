import 'package:fitnesscenter_mobile/app/core/api/bookings_api.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/booking/booking_request.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/booking/booking_state_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/update_booking_status_request.dart';

class BookingService {
  BookingService({BookingsApi? agendaApi})
    : _agendaApi = agendaApi ?? BookingsApi();

  final BookingsApi _agendaApi;

  Future<List<BookingStateDto>> fetchBookingStates() {
    return _agendaApi.getBookingStates();
  }

  Future<BookingDto> fetchBooking({required String bookingId}) {
    return _agendaApi.getBooking(BookingRequest(bookingId: bookingId.trim()));
  }

  Future<BookingDto> fetchBookingDetails({required String bookingId}) {
    return fetchBooking(bookingId: bookingId);
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String state,
    String? observation,
  }) {
    return _agendaApi.updateBookingStatus(
      UpdateBookingStatusRequest(
        bookingId: bookingId,
        state: state,
        observation: observation,
      ),
    );
  }
}
