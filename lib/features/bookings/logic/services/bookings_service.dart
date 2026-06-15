import 'package:portfolio_mobile_app/app/core/api/booking_agenda_api.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';

class BookingsService {
  BookingsService({BookingAgendaApi? bookingsApi})
    : _bookingsApi = bookingsApi ?? BookingAgendaApi();

  final BookingAgendaApi _bookingsApi;

  Future<List<BookingDto>> fetchBookings({
    String? memberId,
    String? bookingStatus,
    bool includeAllDates = false,
    int? pageSize,
  }) {
    return _bookingsApi.getAgenda(
      memberId: memberId,
      bookingStatus: bookingStatus,
      includeAllLocations: true,
      includeAllDates: includeAllDates,
      pageSize: pageSize,
    );
  }
}
