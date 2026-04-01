import 'package:portfolio_mobile_app/app/core/api/booking_api.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';

class BookingsService {
  BookingsService({BookingsApi? bookingsApi})
    : _bookingsApi = bookingsApi ?? BookingsApi();

  final BookingsApi _bookingsApi;

  Future<List<BookingDto>> fetchBookings({String? memberId}) {
    return _bookingsApi.getAgenda(
      memberId: memberId,
      includeAllLocations: true,
    );
  }
}
