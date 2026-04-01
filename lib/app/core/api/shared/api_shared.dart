import 'dart:convert';

import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_exception_messages.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:http/http.dart' as http;

/// Collection of utilities shared across API clients to keep networking code DRY.
class ApiShared {
  const ApiShared._();

  /// Obtains the cached token or throws a standardized [ApiException].
  static Future<String> requireToken(AuthSessionCache cache) async {
    final token = (await cache.getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const ApiException(ApiExceptionMessages.sessionMissing);
    }
    return token;
  }

  /// Creates default JSON headers with an optional bearer token.
  static Map<String, String> buildJsonHeaders({
    String? token,
    bool includeContentType = true,
  }) {
    final headers = <String, String>{};
    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> safeGet(
    http.Client client,
    Uri uri, {
    Map<String, String>? headers,
  }) => _safeRequest(() => client.get(uri, headers: headers));

  static Future<http.Response> safePost(
    http.Client client,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) => _safeRequest(() => client.post(uri, headers: headers, body: body));

  static Future<http.Response> safePut(
    http.Client client,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) => _safeRequest(() => client.put(uri, headers: headers, body: body));

  static Future<http.Response> safePatch(
    http.Client client,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) => _safeRequest(() => client.patch(uri, headers: headers, body: body));

  static Future<http.Response> safeDelete(
    http.Client client,
    Uri uri, {
    Map<String, String>? headers,
  }) => _safeRequest(() => client.delete(uri, headers: headers));

  static Future<http.Response> _safeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } catch (error) {
      throw ApiException('${ApiExceptionMessages.networkErrorPrefix} $error');
    }
  }

  /// Extracts a friendly error message when the backend returns JSON.
  static String? extractErrorMessage(String body) {
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(trimmedBody);
      if (decoded is Map<String, dynamic>) {
        for (final key in ['message', 'error', 'detail']) {
          final value = decoded[key];
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }
      } else if (decoded is String && decoded.isNotEmpty) {
        return decoded;
      }
    } catch (_) {
      // Ignore parsing errors and fallback to the original text.
    }

    return trimmedBody;
  }
}
