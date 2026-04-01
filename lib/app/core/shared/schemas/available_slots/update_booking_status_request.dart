class UpdateBookingStatusRequest {
  const UpdateBookingStatusRequest({
    required this.bookingId,
    required this.state,
    this.locationCode,
    this.observation,
    this.user,
  });

  final String bookingId;
  final String state;
  final String? locationCode;
  final String? observation;
  final String? user;

  String get trimmedBookingId => bookingId.trim();
  String get trimmedState => state.trim();
  String get trimmedLocationCode => locationCode?.trim() ?? '';
  String get trimmedObservation => observation?.trim() ?? '';
  String get trimmedUser => user?.trim() ?? '';
  String get trimmedBookingStatus => trimmedState;

  Map<String, String> toQueryParameters({
    required String defaultLocationCode,
    required String defaultObservation,
    required String defaultUser,
  }) {
    final payload = toRequestBody(
      defaultLocationCode: defaultLocationCode,
      defaultObservation: defaultObservation,
      defaultUser: defaultUser,
    );

    return payload.map((key, value) => MapEntry(key, value.toString()));
  }

  Map<String, dynamic> toRequestBody({
    required String defaultLocationCode,
    required String defaultObservation,
    required String defaultUser,
  }) {
    final resolvedLocationCode = trimmedLocationCode.isEmpty
        ? defaultLocationCode.trim()
        : trimmedLocationCode;
    final resolvedObservation = trimmedObservation.isEmpty
        ? defaultObservation.trim()
        : trimmedObservation;
    final resolvedUser = trimmedUser.isEmpty ? defaultUser.trim() : trimmedUser;

    return <String, dynamic>{
      'bookingId': trimmedBookingId,
      'bookingStatus': trimmedBookingStatus,
      'locationCode': resolvedLocationCode,
      'observation': resolvedObservation,
      'user': resolvedUser,
    };
  }

  UpdateBookingStatusRequest copyWith({
    String? bookingId,
    String? state,
    String? locationCode,
    String? observation,
    String? user,
  }) {
    return UpdateBookingStatusRequest(
      bookingId: bookingId ?? this.bookingId,
      state: state ?? this.state,
      locationCode: locationCode ?? this.locationCode,
      observation: observation ?? this.observation,
      user: user ?? this.user,
    );
  }
}
