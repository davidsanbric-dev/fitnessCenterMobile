import 'package:fitnesscenter_mobile/app/core/api/booking_agenda_api.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';

class BookingsService {
  BookingsService({BookingAgendaApi? bookingsApi})
    : _bookingsApi = bookingsApi ?? BookingAgendaApi();

  final BookingAgendaApi _bookingsApi;

  Future<List<BookingDto>> fetchBookings({
    String? bookingStatus,
    bool includeAllDates = false,
    int? pageSize,
  }) {
    return _bookingsApi.getAgenda(
      bookingStatus: bookingStatus,
      includeAllDates: includeAllDates,
      pageSize: pageSize,
    );
  }
}
