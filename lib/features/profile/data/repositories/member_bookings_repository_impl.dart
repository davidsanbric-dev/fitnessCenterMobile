import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/services/booking_service.dart';
import 'package:fitnesscenter_mobile/features/bookings/data/services/services.dart';
import 'package:fitnesscenter_mobile/features/profile/domain/domain.dart';

class MemberBookingsRepositoryImpl implements MemberBookingsRepository {
  MemberBookingsRepositoryImpl({
    BookingsService? bookingsService,
    BookingService? bookingService,
  }) : _bookingsService = bookingsService ?? BookingsService(),
       _bookingService = bookingService ?? BookingService();

  // The completed-session listing comes from the feature-local agenda service;
  // the per-booking detail payload comes from the shared booking service.
  final BookingsService _bookingsService;
  final BookingService _bookingService;

  @override
  Future<List<BookingDto>> fetchCompletedBookings() {
    return _bookingsService.fetchBookings(
      bookingStatus: 'COMPLETED',
      // Completed sessions are past-dated; opt out of the default upcoming date
      // window so they aren't filtered out server-side, and fetch the full set
      // (page_size 0 = no server cap) so a long history / every assessment note
      // is paginated client-side rather than capped at the backend default.
      includeAllDates: true,
      pageSize: 0,
    );
  }

  @override
  Future<BookingDto> fetchBookingDetails({required String bookingId}) {
    return _bookingService.fetchBookingDetails(bookingId: bookingId);
  }
}
