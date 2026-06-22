import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/app/core/constants/api_exception_messages.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:http/http.dart' as http;

/// Collection of utilities shared across API clients to keep networking code DRY.
class ApiShared {
  const ApiShared._();

  /// Resolves the bearer token for a protected call.
  ///
  /// Under the Firebase-only backend the bearer must be a current Firebase ID
  /// token (spec §5.3). The SDK's [User.getIdToken] auto-refreshes the token
  /// when it is near or past expiry, so fetching it per request keeps sessions
  /// alive instead of sending a stale, login-time token that the backend would
  /// reject with `401` after ~1h. The cached token is used only as a fallback
  /// when there is no live Firebase user (e.g. offline restart).
  static Future<String> requireToken(AuthSessionCache cache) async {
    final liveToken = await _liveFirebaseIdToken();
    if (liveToken != null) {
      return liveToken;
    }

    final token = (await cache.getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw const ApiException(ApiExceptionMessages.sessionMissing);
    }
    return token;
  }

  /// Returns the current Firebase ID token (auto-refreshed by the SDK) or
  /// `null` when there is no signed-in user or it cannot be obtained (offline).
  static Future<String?> _liveFirebaseIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return null;
      }
      final token = (await user.getIdToken())?.trim();
      return (token == null || token.isEmpty) ? null : token;
    } catch (_) {
      return null;
    }
  }

  /// Creates default JSON headers with an optional bearer token.
  static Map<String, String> buildJsonHeaders({
    String? token,
    bool includeContentType = true,
  }) {
    final headers = <String, String>{
      // Identifies the originating app so the backend can enforce that only
      // member accounts sign in from the mobile app. See the API's ClientOrigin
      // gate in /auth/firebase-login.
      'X-Client-Platform': 'mobile',
    };
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
