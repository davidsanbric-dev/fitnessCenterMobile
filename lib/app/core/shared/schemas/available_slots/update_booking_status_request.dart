/// Payload for a booking status change. The wire body is assembled in
/// `BookingsApi.updateBookingStatus` (snake_case: booking_status, notes); this
/// holds the raw values and trims them for that mapping.
class UpdateBookingStatusRequest {
  const UpdateBookingStatusRequest({
    required this.bookingId,
    required this.state,
    this.observation,
  });

  final String bookingId;
  final String state;
  final String? observation;

  String get trimmedState => state.trim();
  String get trimmedObservation => observation?.trim() ?? '';
  String get trimmedBookingStatus => trimmedState;
}
