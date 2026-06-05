/// Parses the provided ISO datetime value and returns a local [DateTime].
/// Returns `null` when the value is missing or cannot be parsed.
DateTime? formatBookingsdDateTime(dynamic rawValue) {
  final isoValue = rawValue?.toString().trim();
  if (isoValue == null || isoValue.isEmpty) {
    return null;
  }

  try {
    return DateTime.parse(isoValue).toLocal();
  } catch (_) {
    return null;
  }
}

DateTime _normalizeDateTime(DateTime value) =>
    value.year == 1970 ? value : value.toLocal();

/// Formats a [DateTime] value into `dd/MM/yyyy`.
String formatDateLabel(DateTime value) {
  final local = _normalizeDateTime(value);
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  return '$day/$month/$year';
}

/// Formats a [DateTime] value into `yyyy-MM-dd`.
String formatDateIso(DateTime value) {
  final local = _normalizeDateTime(value);
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Formats a [DateTime] value into `dd/MM/yyyy hh:mm AM/PM`.
String formatDateTimeLabel(DateTime value) {
  final local = _normalizeDateTime(value);
  return '${formatDateLabel(local)} ${formatTime(local)}';
}

/// Formats an optional [DateTime] or returns [placeholder] when `null`.
String formatNullableDateTimeLabel(
  DateTime? value, {
  String placeholder = '—',
}) {
  if (value == null) return placeholder;
  return formatDateTimeLabel(value);
}

String formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String formatDateSlash(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/'
    '${value.year.toString()}';

String formatRemaining(Duration value) {
  final int totalSeconds = value.inSeconds < 0 ? 0 : value.inSeconds;
  final int minutes = totalSeconds ~/ 60;
  final int seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

/// 12-hour clock with AM/PM, consistent with the admin web app's time format.
String formatTime(DateTime value) {
  final local = value.toLocal();
  final period = local.hour >= 12 ? 'PM' : 'AM';
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final hour = hour12.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}
