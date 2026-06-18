class BookingRequest {
  const BookingRequest({required this.bookingId});

  final String bookingId;

  Map<String, String> toQueryParameters() => {
    'bookingId': bookingId.trim(),
  };
}
