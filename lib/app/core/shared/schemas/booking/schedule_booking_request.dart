class ScheduleBookingRequest {
  const ScheduleBookingRequest({
    required this.date,
    required this.time,
    this.identificationType = '',
    this.memberId = '',
    required this.locationCode,
    required this.bookingDuration,
    required this.disciplineCode,
    required this.trainerCode,
    this.observation = '',
    this.user = '',
  });

  final String date;
  final String time;
  final String identificationType;
  final String memberId;
  final String locationCode;
  final int bookingDuration;
  final int disciplineCode;
  final int trainerCode;
  final String observation;
  final String user;

  String get trimmedDate => date.trim();
  String get trimmedTime => time.trim();
  String get trimmedIdentificationType => identificationType.trim();
  String get trimmedMemberId => memberId.trim();
  String get trimmedLocationCode => locationCode.trim();
  String get trimmedObservation => observation.trim();
  String get trimmedUser => user.trim();

  Map<String, String> toQueryParameters({
    required String defaultUser,
    required String defaultIdentificationType,
    required String defaultMemberId,
  }) {
    final payload = toRequestBody(
      defaultUser: defaultUser,
      defaultIdentificationType: defaultIdentificationType,
      defaultMemberId: defaultMemberId,
    );

    return payload.map((key, value) => MapEntry(key, value.toString()));
  }

  Map<String, dynamic> toRequestBody({
    required String defaultUser,
    required String defaultIdentificationType,
    required String defaultMemberId,
  }) {
    final resolvedUser = trimmedUser.isEmpty ? defaultUser.trim() : trimmedUser;
    final resolvedIdentificationTypeRaw = trimmedIdentificationType.isEmpty
        ? defaultIdentificationType.trim()
        : trimmedIdentificationType;
    final resolvedIdentificationType = _normalizeIdentificationType(
      resolvedIdentificationTypeRaw,
    );
    final resolvedMemberIdRaw = trimmedMemberId.isEmpty
        ? defaultMemberId.trim()
        : trimmedMemberId;
    final resolvedMemberId = _normalizeMemberId(
      resolvedMemberIdRaw,
      identificationType: resolvedIdentificationType,
    );
    return <String, dynamic>{
      'date': _normalizeDate(trimmedDate),
      'time': _normalizeTime(trimmedTime),
      'identificationType': resolvedIdentificationType,
      'memberId': resolvedMemberId,
      'locationCode': trimmedLocationCode,
      'bookingDuration': bookingDuration,
      'disciplineCode': disciplineCode,
      'trainerCode': trainerCode,
      'observation': trimmedObservation,
      'user': resolvedUser,
    };
  }

  static String _normalizeDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    final compactMatch = RegExp(r'^\d{8}$').firstMatch(trimmed);
    if (compactMatch != null) {
      return trimmed;
    }

    final yyyyMmDdMatch = RegExp(
      r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$',
    ).firstMatch(trimmed);
    if (yyyyMmDdMatch != null) {
      final year = yyyyMmDdMatch.group(1)!;
      final month = yyyyMmDdMatch.group(2)!.padLeft(2, '0');
      final day = yyyyMmDdMatch.group(3)!.padLeft(2, '0');
      return '$year$month$day';
    }

    final ddMmYyyyMatch = RegExp(
      r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$',
    ).firstMatch(trimmed);
    if (ddMmYyyyMatch != null) {
      final day = ddMmYyyyMatch.group(1)!.padLeft(2, '0');
      final month = ddMmYyyyMatch.group(2)!.padLeft(2, '0');
      final year = ddMmYyyyMatch.group(3)!;
      return '$year$month$day';
    }

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return _formatDateCompact(parsed.toLocal());
    }

    return trimmed;
  }

  static String _normalizeTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    final hhMmMatch = RegExp(
      r'^(\d{1,2}):(\d{1,2})(?::\d{1,2})?$',
    ).firstMatch(trimmed);
    if (hhMmMatch != null) {
      final hour = hhMmMatch.group(1)!.padLeft(2, '0');
      final minute = hhMmMatch.group(2)!.padLeft(2, '0');
      return '$hour:$minute';
    }

    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 4) {
      return '${digits.substring(0, 2)}:${digits.substring(2, 4)}';
    }

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      final local = parsed.toLocal();
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return trimmed;
  }

  static String _normalizeIdentificationType(String value) {
    final upper = value.trim().toUpperCase();
    if (upper.isEmpty) return '';

    switch (upper) {
      case 'RUT':
      case 'RUN':
      case 'R':
        return 'R';
      case 'PASAPORTE':
      case 'PASSPORT':
      case 'P':
        return 'P';
      default:
        return upper;
    }
  }

  static String _normalizeMemberId(
    String value, {
    required String identificationType,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    if (identificationType != 'R') {
      return trimmed;
    }

    final normalized = trimmed
        .replaceAll(RegExp(r'[^0-9kK]'), '')
        .toUpperCase();
    if (normalized.isEmpty) {
      return '';
    }
    if (normalized.length == 1) {
      return normalized;
    }

    final body = normalized.substring(0, normalized.length - 1);
    final verifier = normalized.substring(normalized.length - 1);
    if (body.isEmpty) {
      return verifier;
    }
    return '$body-$verifier';
  }

  static String _formatDateCompact(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  ScheduleBookingRequest copyWith({
    String? date,
    String? time,
    String? identificationType,
    String? memberId,
    String? locationCode,
    int? bookingDuration,
    int? disciplineCode,
    int? trainerCode,
    String? observation,
    String? user,
  }) {
    return ScheduleBookingRequest(
      date: date ?? this.date,
      time: time ?? this.time,
      identificationType: identificationType ?? this.identificationType,
      memberId: memberId ?? this.memberId,
      locationCode: locationCode ?? this.locationCode,
      bookingDuration: bookingDuration ?? this.bookingDuration,
      disciplineCode: disciplineCode ?? this.disciplineCode,
      trainerCode: trainerCode ?? this.trainerCode,
      observation: observation ?? this.observation,
      user: user ?? this.user,
    );
  }
}
