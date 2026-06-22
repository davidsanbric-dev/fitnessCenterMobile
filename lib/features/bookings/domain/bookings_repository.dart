import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/booking/booking_state_dto.dart';

abstract interface class BookingsRepository {
  Future<List<BookingDto>> fetchBookings({
    String? bookingStatus,
    bool includeAllDates,
    int? pageSize,
  });

  Future<BookingDto> fetchBookingDetails({required String bookingId});

  Future<List<BookingStateDto>> fetchBookingStates();

  Future<void> updateBookingStatus({
    required String bookingId,
    required String state,
    String? observation,
  });
}
