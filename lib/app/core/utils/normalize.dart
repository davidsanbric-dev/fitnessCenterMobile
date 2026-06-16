import 'package:flutter/material.dart';

List<String> normalizeStringList(List<String> values) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    final normalized = trimmed.toLowerCase();
    if (seen.add(normalized)) {
      result.add(trimmed);
    }
  }
  result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return result;
}

DateTimeRange normalizeDateRange(DateTime start, DateTime end) {
  if (end.isBefore(start)) {
    return DateTimeRange(start: start, end: start);
  }
  return DateTimeRange(start: start, end: end);
}

String? normOptString(dynamic value) {
  final normalized = value?.toString().trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}

String normReqString(dynamic value) {
  return value.toString().trim();
}

String normalizeKey(String value) => value.trim().toLowerCase();

String? normalizeValue(String? value) {
  final normalized = value?.trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}

// Consider renaming it with 'normReqInt'
int normReqInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? normOptInt(dynamic value) {
  return int.tryParse(value?.toString() ?? '');
}

Map<String, dynamic> normReqMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

String sanitizeRutInput(String value) {
  final trimmed = value.trim();
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  final endsWithK = RegExp(r'[kK]$').hasMatch(trimmed);
  return endsWithK ? '${digits}K' : digits;
}

String normalizeAuthCode(String code) {
  return code.trim().toLowerCase().replaceAll('_', '-');
}
