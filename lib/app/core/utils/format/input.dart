import 'package:flutter/services.dart';

class RutInputFormatter extends TextInputFormatter {
  const RutInputFormatter();

  static const int _maxRawLength = 9;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();
    final limited = raw.length > _maxRawLength
        ? raw.substring(0, _maxRawLength)
        : raw;

    if (limited.isEmpty) {
      return const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final body = limited.substring(0, limited.length - 1);
    final checkDigit = limited.substring(limited.length - 1);

    final buffer = StringBuffer();
    int groupCount = 0;
    for (int i = body.length - 1; i >= 0; i--) {
      buffer.write(body[i]);
      groupCount += 1;
      if (groupCount == 3 && i != 0) {
        buffer.write('.');
        groupCount = 0;
      }
    }

    final formattedBody = buffer.toString().split('').reversed.join();
    final formatted = body.isEmpty ? checkDigit : '$formattedBody-$checkDigit';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String maskEmail(String? email) {
  if (email == null || email.trim().isEmpty) {
    return 'rp******@gm*******.c****';
  }

  final parts = email.trim().split('@');
  if (parts.length != 2) {
    return email.trim();
  }

  final local = parts[0];
  final domain = parts[1];
  final domainParts = domain.split('.');
  final domainName = domainParts.isNotEmpty ? domainParts.first : domain;
  final String domainSuffix = domainParts.length > 1
      ? domainParts.sublist(1).join('.')
      : '';

  final maskedLocal = _maskChunk(local);
  final maskedDomain = _maskChunk(domainName);
  final maskedSuffix = domainSuffix.isEmpty
      ? ''
      : _maskChunk(domainSuffix, keepStart: 1);

  return '$maskedLocal@$maskedDomain${maskedSuffix.isEmpty ? '' : '.$maskedSuffix'}';
}

String _maskChunk(String value, {int keepStart = 2, int keepEnd = 0}) {
  if (value.isEmpty) {
    return value;
  }

  if (value.length <= keepStart + keepEnd) {
    return '${value.substring(0, 1)}${_repeatAsterisks(value.length - 1)}';
  }

  final maskedLength = value.length - keepStart - keepEnd;
  final start = value.substring(0, keepStart);
  final end = keepEnd > 0 ? value.substring(value.length - keepEnd) : '';
  return '$start${_repeatAsterisks(maskedLength)}$end';
}

String _repeatAsterisks(int length) {
  if (length <= 0) {
    return '';
  }
  return List.filled(length, '*').join();
}

String formatRut(String value) {
  if (value.isEmpty) return '';
  if (value.length == 1) return value.toUpperCase();

  final verifier = value.endsWith('K')
      ? 'K'
      : value.substring(value.length - 1);
  final body = value.substring(0, value.length - 1);
  final formattedBody = _formatBody(body);

  if (formattedBody.isEmpty) return verifier;
  return '$formattedBody-$verifier';
}

String _formatBody(String body) {
  if (body.isEmpty) return '';
  final parts = <String>[];
  for (var i = body.length; i > 0; i -= 3) {
    final start = i - 3;
    parts.add(body.substring(start < 0 ? 0 : start, i));
  }
  return parts.reversed.join('.');
}

String maskPhone(String? phoneNumber) {
  if (phoneNumber == null || phoneNumber.trim().isEmpty) {
    return '-';
  }
  final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return '-';
  }
  final suffixLength = digits.length >= 4 ? 4 : digits.length;
  final suffix = digits.substring(digits.length - suffixLength);
  return '***$suffix';
}
