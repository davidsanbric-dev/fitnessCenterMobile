/// Validation helpers for domain-specific input checks.
library;

import 'package:portfolio_mobile_app/app/core/utils/parse.dart';

/// Validates a RUT string (normalized internally to digits plus optional `K`).
bool isNormalizedRutValid(String rut) {
  final value = normRut(rut).trim();
  if (value.length < 8 || value.length > 9) {
    return false;
  }
  final body = value.substring(0, value.length - 1);
  final checkDigit = value.substring(value.length - 1);
  if (!RegExp(r'^\d+$').hasMatch(body)) {
    return false;
  }
  return RegExp(r'^[0-9K]$').hasMatch(checkDigit);
}

int? _parseOptionalInt(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  return int.tryParse(trimmed);
}

bool isDayValidValue(String? day) {
  final parsed = _parseOptionalInt(day);
  return parsed != null && parsed >= 1 && parsed <= 31;
}

bool isMonthValidValue(String? month) {
  final parsed = _parseOptionalInt(month);
  return parsed != null && parsed >= 1 && parsed <= 12;
}

bool isYearValidValue(String? year, {int? currentYear}) {
  final parsed = _parseOptionalInt(year);
  if (parsed == null) {
    return false;
  }
  final maxYear = currentYear ?? DateTime.now().year;
  return parsed >= 1900 && parsed <= maxYear;
}

bool isBirthDateValidValue({String? day, String? month, String? year}) {
  if (!isDayValidValue(day) ||
      !isMonthValidValue(month) ||
      !isYearValidValue(year)) {
    return false;
  }
  final parsedDay = _parseOptionalInt(day)!;
  final parsedMonth = _parseOptionalInt(month)!;
  final parsedYear = _parseOptionalInt(year)!;
  final maxDay = DateTime(parsedYear, parsedMonth + 1, 0).day;
  return parsedDay <= maxDay;
}

bool isEmailValidValue(String email) {
  final trimmed = email.trim();
  if (trimmed.isEmpty) {
    return false;
  }
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
}

bool passHasUppercase(String value) => RegExp(r'[A-Z]').hasMatch(value);
bool passHasLowercase(String value) => RegExp(r'[a-z]').hasMatch(value);
bool passHasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);
bool passHasSymbol(String value) =>
    RegExp(r'[!@#\$%\^&\*\(\)\-\+=\[\]\{\};:,.<>\/\?\|\\_`~]').hasMatch(value);

bool passHasAlphaNumeric(String value) =>
    value.length > 8 &&
    RegExp(r'[A-Za-z]').hasMatch(value) &&
    passHasNumber(value);
