import 'dart:convert';

import 'package:fitnesscenter_mobile/app/core/api/shared/api_envelope.dart';
import 'package:fitnesscenter_mobile/app/core/api/shared/api_shared.dart';
import 'package:fitnesscenter_mobile/app/core/api/shared/types.dart';
import 'package:fitnesscenter_mobile/app/core/auth/auth.dart';
import 'package:fitnesscenter_mobile/app/core/constants/api_exception_messages.dart';
import 'package:fitnesscenter_mobile/app/core/constants/route_paths.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/utils/parse.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// Shared helpers to keep API client methods concise.
abstract class ApiBase {
  ApiBase({AuthSessionCache? cache, http.Client? client})
    : _cache = cache ?? _resolveCache(),
      _client = client ?? _resolveClient();

  final AuthSessionCache _cache;
  final http.Client _client;
  AuthSessionCache get cache => _cache;
  http.Client get client => _client;

  // Prefer the permanent singletons registered in `AppBindings` so every API
  // client shares one HTTP client and one session cache; fall back to a fresh
  // instance only when nothing is registered (e.g. unit tests constructing a
  // client in isolation). Tests can still inject their own via the constructor.
  static AuthSessionCache _resolveCache() =>
      Get.isRegistered<AuthSessionCache>()
      ? Get.find<AuthSessionCache>()
      : AuthSessionCache();

  static http.Client _resolveClient() =>
      Get.isRegistered<http.Client>() ? Get.find<http.Client>() : http.Client();

  Future<List<T>> getDataListAsync<T>({
    required String url,
    required String requestErrorMessage,
    List<dynamic> Function(dynamic data)? extractItems,
    required T Function(Map<String, dynamic> json) fromJson,
    Future<List<T>> Function()? mockFallback,
    bool requireSession = true,
    Map<String, String>? queryParameters,
    int? pageNumber,
    int? pageSize,
    bool usePost = false,
    Map<String, dynamic>? requestBody,
  }) {
    final itemsExtractor = extractItems ?? _extractItems;
    return _getAsync<List<T>>(
      url: url,
      requestErrorMessage: requestErrorMessage,
      mockFallback: mockFallback,
      requireSession: requireSession,
      queryParameters: queryParameters,
      pageNumber: pageNumber,
      pageSize: pageSize,
      usePost: usePost,
      requestBody: requestBody,
      transform: (data) => _mapItems(itemsExtractor(data), fromJson),
    );
  }

  Future<PaginatedResult<T>> getPaginatedDataListAsync<T>({
    required String url,
    required String requestErrorMessage,
    List<dynamic> Function(dynamic data)? extractItems,
    required T Function(Map<String, dynamic> json) fromJson,
    Future<PaginatedResult<T>> Function()? mockFallback,
    bool requireSession = true,
    Map<String, String>? queryParameters,
    int? pageNumber,
    int? pageSize,
    bool usePost = false,
    Map<String, dynamic>? requestBody,
  }) {
    final itemsExtractor = extractItems ?? _extractItems;
    return _getAsync<PaginatedResult<T>>(
      url: url,
      requestErrorMessage: requestErrorMessage,
      mockFallback: mockFallback,
      requireSession: requireSession,
      queryParameters: queryParameters,
      pageNumber: pageNumber,
      pageSize: pageSize,
      usePost: usePost,
      requestBody: requestBody,
      transform: (data) {
        final pagination = _extractPagination(data);
        return PaginatedResult<T>(
          items: _mapItems(itemsExtractor(data), fromJson),
          totalItems: pagination.totalItems,
          pageNumber: pagination.pageNumber ?? pageNumber,
          pageSize: pagination.pageSize ?? pageSize,
        );
      },
    );
  }

  /// Shared pipeline for every reading call (`get`/paginated-`get`): build the
  /// URI, resolve the session token, send via GET (or POST when [usePost]),
  /// apply the uniform 401 → logout and error handling, then hand the validated
  /// envelope's `data` to [transform] to produce the typed result.
  ///
  /// Unlike the mutation pipeline, reads fall back to [mockFallback] on *any*
  /// server error (non-success status or a failed envelope validation), not
  /// just network failures — see [_orFallback] versus [_withMockFallback].
  Future<R> _getAsync<R>({
    required String url,
    required String requestErrorMessage,
    required R Function(dynamic data) transform,
    Future<R> Function()? mockFallback,
    required bool requireSession,
    Map<String, String>? queryParameters,
    int? pageNumber,
    int? pageSize,
    bool usePost = false,
    Map<String, dynamic>? requestBody,
  }) async {
    final uri = _buildUri(
      url,
      queryParameters: queryParameters,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    final token = await _resolveToken(requireSession: requireSession);
    if (!requireSession && token == null) {
      return _orFallback<R>(
        mockFallback,
        const ApiException(ApiExceptionMessages.sessionMissing),
      );
    }

    return _withMockFallback(mockFallback, () async {
      final headers = ApiShared.buildJsonHeaders(token: token);
      final response = usePost
          ? await ApiShared.safePost(
              client,
              uri,
              headers: headers,
              body: requestBody != null ? jsonEncode(requestBody) : '',
            )
          : await ApiShared.safeGet(client, uri, headers: headers);

      await _throwIfUnauthorized(response.statusCode, requireSession);

      if (!_isSuccessStatus(response.statusCode)) {
        return _orFallback<R>(
          mockFallback,
          ApiException(_statusErrorMessage(response, requestErrorMessage)),
        );
      }

      final envelope = ApiEnvelope.fromResponse(response);
      try {
        envelope.validateSuccess();
      } on ApiException catch (error) {
        return _orFallback<R>(mockFallback, error);
      }

      return transform(envelope.data);
    });
  }

  static List<T> _mapItems<T>(
    List<dynamic> items,
    T Function(Map<String, dynamic> json) fromJson,
  ) => items
      .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
      .toList(growable: false);

  Future<T?> createAsync<T>({
    required String url,
    required Map<String, dynamic> requestBody,
    required String requestErrorMessage,
    bool requireSession = true,
    bool includeOptionalSessionToken = true,
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    final uri = Uri.parse(url);
    return _sendMutation<T>(
      send: (headers) => ApiShared.safePost(
        client,
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      ),
      requestErrorMessage: requestErrorMessage,
      requireSession: requireSession,
      includeOptionalSessionToken: includeOptionalSessionToken,
      fromJson: fromJson,
    );
  }

  Future<T?> updateAsync<T>({
    required String url,
    required Map<String, dynamic> requestBody,
    required String requestErrorMessage,
    bool requireSession = true,
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    final uri = Uri.parse(url);
    return _sendMutation<T>(
      send: (headers) => ApiShared.safePost(
        client,
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      ),
      requestErrorMessage: requestErrorMessage,
      requireSession: requireSession,
      fromJson: fromJson,
    );
  }

  Future<T?> deleteAsync<T>({
    required String url,
    required String requestErrorMessage,
    bool requireSession = true,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? requestBody,
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    final uriWithParams = _buildUri(url, queryParameters: queryParameters);
    // Deletes are issued as POST (matching the backend's RPC-style endpoints).
    return _sendMutation<T>(
      send: (headers) => ApiShared.safePost(
        client,
        uriWithParams,
        headers: headers,
        body: requestBody != null ? jsonEncode(requestBody) : '',
      ),
      requestErrorMessage: requestErrorMessage,
      requireSession: requireSession,
      fromJson: fromJson,
    );
  }

  Future<T?> patchAsync<T>({
    required String url,
    required Map<String, dynamic> requestBody,
    required String requestErrorMessage,
    bool requireSession = true,
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    final uri = Uri.parse(url);
    return _sendMutation<T>(
      send: (headers) => ApiShared.safePatch(
        client,
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      ),
      requestErrorMessage: requestErrorMessage,
      requireSession: requireSession,
      fromJson: fromJson,
    );
  }

  Future<T?> relateToRecordAsync<T>({
    required String url,
    required Map<String, dynamic> requestBody,
    required String requestErrorMessage,
    bool requireSession = true,
    String? notFoundErrorMessage,
    T Function(Map<String, dynamic> json)? fromJson,
  }) {
    final uri = Uri.parse(url);
    return _sendMutation<T>(
      send: (headers) => ApiShared.safePut(
        client,
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      ),
      requestErrorMessage: requestErrorMessage,
      requireSession: requireSession,
      notFoundErrorMessage: notFoundErrorMessage,
      fromJson: fromJson,
    );
  }

  /// Shared pipeline for every mutating verb (`create/update/patch/delete/
  /// relate`): resolve the session token, send via the caller-supplied [send]
  /// closure, then apply the uniform 401 → logout, error-extraction,
  /// envelope-validation and `fromJson(data)` handling.
  ///
  /// [send] receives the prepared JSON headers and is responsible only for
  /// choosing the HTTP method/URL/body. [notFoundErrorMessage], when set, maps a
  /// 404 to that message before the generic error path (used by relate calls).
  Future<T?> _sendMutation<T>({
    required Future<http.Response> Function(Map<String, String> headers) send,
    required String requestErrorMessage,
    required bool requireSession,
    bool includeOptionalSessionToken = true,
    String? notFoundErrorMessage,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final token = await _resolveToken(
      requireSession: requireSession,
      includeOptionalSessionToken: includeOptionalSessionToken,
    );

    return _withMockFallback<T?>(null, () async {
      final response = await send(ApiShared.buildJsonHeaders(token: token));

      await _throwIfUnauthorized(response.statusCode, requireSession);

      if (notFoundErrorMessage != null && response.statusCode == 404) {
        throw ApiException(notFoundErrorMessage);
      }

      if (!_isSuccessStatus(response.statusCode)) {
        throw ApiException(_statusErrorMessage(response, requestErrorMessage));
      }

      final envelope = ApiEnvelope.fromResponse(response);
      envelope.validateSuccess();

      if (fromJson == null) {
        return null;
      }

      final data = envelope.data;
      if (data is Map<String, dynamic>) {
        return fromJson(data);
      }

      return null;
    });
  }

  static List<dynamic> _extractItems(dynamic data) {
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'];
      if (items is List) {
        return items;
      }
      final value = data['value'];
      if (value is List) {
        return value;
      }
    }
    return const <dynamic>[];
  }

  static PaginationMeta _extractPagination(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return const PaginationMeta();
    }

    final totalItems =
        _readInt(data, const ['totalCount']) ??
        _readInt(data, const ['total', 'count']) ??
        _readIntFromNested(
          data,
          const ['pagination', 'Pagination', 'page', 'Page', 'meta', 'Meta'],
          const ['totalItems', 'TotalItems', 'totalCount', 'TotalCount'],
        );

    final pageNumber =
        _readInt(data, const ['pageNumber']) ??
        _readInt(data, const ['page']) ??
        _readIntFromNested(
          data,
          const ['pagination', 'Pagination', 'page', 'Page', 'meta', 'Meta'],
          const ['pageNumber', 'PageNumber', 'currentPage', 'CurrentPage'],
        );

    final pageSize =
        _readInt(data, const ['pageSize']) ??
        _readInt(data, const ['per_page']) ??
        _readInt(data, const ['page_size']) ??
        _readIntFromNested(
          data,
          const ['pagination', 'Pagination', 'page', 'Page', 'meta', 'Meta'],
          const ['pageSize', 'PageSize', 'limit', 'Limit'],
        );

    return PaginationMeta(
      totalItems: totalItems,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  static int? _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      final parsed = parseOptInt(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  static int? _readIntFromNested(
    Map<String, dynamic> data,
    List<String> containerKeys,
    List<String> keys,
  ) {
    for (final key in containerKeys) {
      final nested = data[key];
      if (nested is Map<String, dynamic>) {
        final value = _readInt(nested, keys);
        if (value != null) {
          return value;
        }
      }
    }
    return null;
  }

  static List<dynamic> extractSingleItemList(dynamic data) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      final value = data['value'];

      if (value is List) return value;
      if (value is Map) return [value];

      return [data];
    }

    return const <dynamic>[];
  }

  static bool _isSuccessStatus(int statusCode) =>
      statusCode >= 200 && statusCode < 300;

  static bool shouldUseMock(ApiException error) =>
      error.message.startsWith(ApiExceptionMessages.networkErrorPrefix);

  static bool isSessionMissing(ApiException error) =>
      error.message.trim() == ApiExceptionMessages.sessionMissing;

  Future<String?> requireTokenOrNull() async {
    try {
      final token = await ApiShared.requireToken(cache);
      if (token.trim().isEmpty) {
        return null;
      }
      return token;
    } on ApiException catch (error) {
      if (shouldUseMock(error) || isSessionMissing(error)) {
        return null;
      }
      rethrow;
    }
  }

  /// Parses [url], then merges its existing query string with [queryParameters]
  /// and the optional `pageNumber`/`pageSize` cursor params into a single URI.
  Uri _buildUri(
    String url, {
    Map<String, String>? queryParameters,
    int? pageNumber,
    int? pageSize,
  }) {
    final uri = Uri.parse(url);
    final merged = <String, String>{
      ...uri.queryParameters,
      if (queryParameters != null) ...queryParameters,
      if (pageNumber != null) 'pageNumber': pageNumber.toString(),
      if (pageSize != null) 'pageSize': pageSize.toString(),
    };
    return merged.isEmpty ? uri : uri.replace(queryParameters: merged);
  }

  /// Applies the uniform 401 handling: log out (when [requireSession]) and throw
  /// a session-expired [ApiException]. No-op for any other status code.
  Future<void> _throwIfUnauthorized(int statusCode, bool requireSession) async {
    if (statusCode != 401) {
      return;
    }
    if (requireSession) {
      await _handleUnauthorized();
    }
    throw const ApiException(ApiExceptionMessages.sessionExpired);
  }

  /// Builds the error message for a non-success [response], preferring the
  /// backend's message and falling back to [requestErrorMessage] + status code.
  String _statusErrorMessage(
    http.Response response,
    String requestErrorMessage,
  ) =>
      ApiShared.extractErrorMessage(response.body) ??
      '$requestErrorMessage (${response.statusCode}).';

  Future<void> _handleUnauthorized() async {
    try {
      if (Get.isRegistered<AuthService>()) {
        await Get.find<AuthService>().logout();
      } else {
        await _cache.clearSession();
      }
    } catch (_) {
      await _cache.clearSession();
    }

    if (Get.currentRoute != RoutePaths.login) {
      await Get.offAllNamed(RoutePaths.login);
    }
  }

  Future<String?> _resolveToken({
    required bool requireSession,
    bool includeOptionalSessionToken = true,
  }) async {
    if (requireSession) {
      return ApiShared.requireToken(_cache);
    }
    if (!includeOptionalSessionToken) {
      return null;
    }
    return requireTokenOrNull();
  }

  Future<T> _orFallback<T>(
    Future<T> Function()? mockFallback,
    ApiException error,
  ) async {
    if (mockFallback != null) {
      return mockFallback();
    }
    throw error;
  }

  Future<T> _withMockFallback<T>(
    Future<T> Function()? mockFallback,
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } on ApiException catch (error) {
      if (mockFallback != null && shouldUseMock(error)) {
        return mockFallback();
      }
      rethrow;
    } catch (error) {
      if (mockFallback != null) {
        return mockFallback();
      }
      throw ApiException('Invalid server response: $error');
    }
  }
}
