import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';

/// The member-facing booking reads behind the profile sub-views (Training
/// History and Assessment Results): the member's completed sessions and the
/// full detail payload for a single booking.
abstract interface class MemberBookingsRepository {
  Future<List<BookingDto>> fetchCompletedBookings();

  Future<BookingDto> fetchBookingDetails({required String bookingId});
}
