class BookingRequest {
  const BookingRequest({required this.bookingId, required this.locationCode});

  final String bookingId;
  final String locationCode;

  Map<String, String> toQueryParameters() => {
    'bookingId': bookingId.trim(),
    'locationCode': locationCode.trim(),
  };
}
