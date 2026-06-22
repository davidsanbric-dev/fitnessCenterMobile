import 'dart:convert';

import 'package:fitnesscenter_mobile/app/core/constants/api_exception_messages.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/utils/parse.dart';
import 'package:http/http.dart' as http;

/// Represents the standard response envelope returned by most backend endpoints.
class ApiEnvelope {
  const ApiEnvelope({
    required this.isException,
    required this.statusCode,
    this.errorMessage,
    this.data,
  });

  final bool isException;
  final int statusCode;
  final String? errorMessage;
  final dynamic data;

  /// Parses the HTTP response body into an [ApiEnvelope].
  factory ApiEnvelope.fromResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      return ApiEnvelope(isException: false, statusCode: response.statusCode);
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final hasEnvelopeKeys =
            decoded.containsKey('data') ||
            decoded.containsKey('Data') ||
            decoded.containsKey('isException') ||
            decoded.containsKey('IsException') ||
            decoded.containsKey('errorMessage') ||
            decoded.containsKey('ErrorMessage');
        if (!hasEnvelopeKeys) {
          return ApiEnvelope(
            isException: false,
            data: decoded,
            statusCode: response.statusCode,
          );
        }

        final data = decoded.containsKey('data')
            ? decoded['data']
            : decoded['Data'];
        final errorMessage = decoded.containsKey('errorMessage')
            ? decoded['errorMessage']
            : decoded['ErrorMessage'];

        return ApiEnvelope(
          isException: parseBool(
            decoded.containsKey('isException')
                ? decoded['isException']
                : decoded['IsException'],
          ),
          errorMessage: _normalizeMessage(errorMessage?.toString()),
          data: data,
          statusCode: _extractStateCode(data) ?? response.statusCode,
        );
      }

      return ApiEnvelope(
        isException: false,
        data: decoded,
        statusCode: response.statusCode,
      );
    } catch (error) {
      throw ApiException('Invalid server response: $error');
    }
  }

  static int? _extractStateCode(dynamic data) {
    if (data is Map<String, dynamic>) {
      final raw = data['statusCode'] ?? data['StatusCode'];
      if (raw is int) return raw;
      if (raw is String) return int.tryParse(raw);
    }
    return null;
  }

  static String? _normalizeMessage(String? message) {
    if (message == null) return null;
    final trimmed = message.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

extension ApiEnvelopeValidation on ApiEnvelope {
  void validateSuccess({
    String fallbackMessage = ApiExceptionMessages.serverError,
  }) {
    final isSuccessfulStatus = statusCode >= 200 && statusCode < 300;
    if (isException || !isSuccessfulStatus) {
      throw ApiException(errorMessage ?? fallbackMessage);
    }
  }
}
