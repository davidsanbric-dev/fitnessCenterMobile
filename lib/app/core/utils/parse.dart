/// Utilities for parsing backend values into typed representations.
library;

/// Parses a dynamic value into a [DateTime].
/// Returns `null` when the input is empty or cannot be parsed.
DateTime? parseDateTime(dynamic raw) {
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

/// Parses a dynamic value into a boolean.
/// Strings like `"true"`, `"false"`, or numeric representations are supported.
bool parseBool(dynamic raw) {
  if (raw is bool) return raw;
  if (raw is num) return raw != 0;
  if (raw is String) {
    final normalized = raw.trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    final parsedNum = num.tryParse(normalized);
    if (parsedNum != null) return parsedNum != 0;
  }
  return false;
}

DateTime parseOptDateTime(dynamic value) {
  if (value is DateTime) return value;
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
  try {
    return DateTime.parse(raw).toLocal();
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

int? parseOptInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

Map<String, dynamic>? parseOptMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

String parseReqInt(int value) {
  return value.toString();
}

Duration? parseValidFor(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final parts = value.trim().split(':');
  if (parts.length < 2 || parts.length > 3) {
    return null;
  }
  final parsed = parts.map(int.tryParse).toList();
  if (parsed.any((element) => element == null)) {
    return null;
  }
  if (parts.length == 2) {
    return Duration(minutes: parsed[0]!, seconds: parsed[1]!);
  }
  return Duration(hours: parsed[0]!, minutes: parsed[1]!, seconds: parsed[2]!);
}

String normRut(String value) =>
    value.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();

Map<String, dynamic>? asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
