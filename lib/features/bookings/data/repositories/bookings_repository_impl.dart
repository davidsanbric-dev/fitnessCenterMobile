import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/booking/booking_state_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/services/booking_service.dart';
import 'package:fitnesscenter_mobile/features/bookings/data/services/services.dart';
import 'package:fitnesscenter_mobile/features/bookings/domain/domain.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  BookingsRepositoryImpl({
    BookingsService? bookingsService,
    BookingService? bookingService,
  }) : _bookingsService = bookingsService ?? BookingsService(),
       _bookingService = bookingService ?? BookingService();

  // Agenda listing comes from the feature-local service; per-booking detail,
  // status catalog and status mutations come from the shared booking service.
  final BookingsService _bookingsService;
  final BookingService _bookingService;

  @override
  Future<List<BookingDto>> fetchBookings({
    String? bookingStatus,
    bool includeAllDates = false,
    int? pageSize,
  }) {
    return _bookingsService.fetchBookings(
      bookingStatus: bookingStatus,
      includeAllDates: includeAllDates,
      pageSize: pageSize,
    );
  }

  @override
  Future<BookingDto> fetchBookingDetails({required String bookingId}) {
    return _bookingService.fetchBookingDetails(bookingId: bookingId);
  }

  @override
  Future<List<BookingStateDto>> fetchBookingStates() {
    return _bookingService.fetchBookingStates();
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String state,
    String? observation,
  }) {
    return _bookingService.updateBookingStatus(
      bookingId: bookingId,
      state: state,
      observation: observation,
    );
  }
}
