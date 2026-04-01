import 'dart:convert';

import 'package:portfolio_mobile_app/app/core/api/shared/api_envelope.dart';
import 'package:portfolio_mobile_app/app/core/api/shared/api_shared.dart';
import 'package:portfolio_mobile_app/app/core/api/shared/types.dart';
import 'package:portfolio_mobile_app/app/core/auth/auth.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_exception_messages.dart';
import 'package:portfolio_mobile_app/app/core/constants/route_paths.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/utils/parse.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// Shared helpers to keep API client methods concise.
abstract class ApiBase {
  ApiBase({AuthSessionCache? cache, http.Client? client})
    : _cache = cache ?? AuthSessionCache(),
      _client = client ?? http.Client();

  final AuthSessionCache _cache;
  final http.Client _client;
  AuthSessionCache get cache => _cache;
  http.Client get client => _client;

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
  }) async {
    final itemsExtractor = extractItems ?? _extractItems;
    final uri = Uri.parse(url);
    final mergedQueryParameters = <String, String>{
      ...uri.queryParameters,
      if (queryParameters != null) ...queryParameters,
      if (pageNumber != null) 'pageNumber': pageNumber.toString(),
      if (pageSize != null) 'pageSize': pageSize.toString(),
    };
    final uriWithParams = mergedQueryParameters.isEmpty
        ? uri
        : uri.replace(queryParameters: mergedQueryParameters);
    final token = await _resolveToken(requireSession: requireSession);
    if (!requireSession && token == null) {
      return _orFallback<List<T>>(
        mockFallback,
        const ApiException(ApiExceptionMessages.sessionMissing),
      );
    }

    return _withMockFallback(mockFallback, () async {
      final headers = ApiShared.buildJsonHeaders(token: token);
      final response = usePost
          ? await ApiShared.safePost(
              client,
              uriWithParams,
              headers: headers,
              body: requestBody != null ? jsonEncode(requestBody) : '',
            )
          : await ApiShared.safeGet(client, uriWithParams, headers: headers);

      if (response.statusCode == 401) {
        if (requireSession) {
          await _handleUnauthorized();
        }
        throw const ApiException(ApiExceptionMessages.sessionExpired);
      }

      if (!_isSuccessStatus(response.statusCode)) {
        final message =
            ApiShared.extractErrorMessage(response.body) ??
            '$requestErrorMessage (${response.statusCode}).';
        return _orFallback<List<T>>(mockFallback, ApiException(message));
      }

      final envelope = ApiEnvelope.fromResponse(response);
      try {
        envelope.validateSuccess();
      } on ApiException catch (error) {
        return _orFallback<List<T>>(mockFallback, error);
      }

      final items = itemsExtractor(envelope.data);
      return items
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false);
    });
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
  }) async {
    final itemsExtractor = extractItems ?? _extractItems;
    final uri = Uri.parse(url);
    final mergedQueryParameters = <String, String>{
      ...uri.queryParameters,
      if (queryParameters != null) ...queryParameters,
      if (pageNumber != null) 'pageNumber': pageNumber.toString(),
      if (pageSize != null) 'pageSize': pageSize.toString(),
    };
    final uriWithParams = mergedQueryParameters.isEmpty
        ? uri
        : uri.replace(queryParameters: mergedQueryParameters);
    final token = await _resolveToken(requireSession: requireSession);
    if (!requireSession && token == null) {
      return _orFallback<PaginatedResult<T>>(
        mockFallback,
        const ApiException(ApiExceptionMessages.sessionMissing),
      );
    }

    return _withMockFallback(mockFallback, () async {
      final headers = ApiShared.buildJsonHeaders(token: token);
      final response = usePost
          ? await ApiShared.safePost(
              client,
              uriWithParams,
              headers: headers,
              body: requestBody != null ? jsonEncode(requestBody) : '',
            )
          : await ApiShared.safeGet(client, uriWithParams, headers: headers);

      if (response.statusCode == 401) {
        if (requireSession) {
          await _handleUnauthorized();
        }
        throw const ApiException(ApiExceptionMessages.sessionExpired);
      }

      if (!_isSuccessStatus(response.statusCode)) {
        final message =
            ApiShared.extractErrorMessage(response.body) ??
            '$requestErrorMessage (${response.statusCode}).';
        return _orFallback<PaginatedResult<T>>(
          mockFallback,
          ApiException(message),
        );
      }

      final envelope = ApiEnvelope.fromResponse(response);
      try {
        envelope.validateSuccess();
      } on ApiException catch (error) {
        return _orFallback<PaginatedResult<T>>(mockFallback, error);
      }

      final data = envelope.data;
      final items = itemsExtractor(data)
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false);
      final pagination = _extractPagination(data);

      return PaginatedResult<T>(
        items: items,
        totalItems: pagination.totalItems,
        pageNumber: pagination.pageNumber ?? pageNumber,
        pageSize: pagination.pageSize ?? pageSize,
      );
    });
  }

  Future<T?> createAsync<T>({
    required String url,
    required Map<String, dynamic> requestBody,
    required String requestErrorMessage,
    bool requireSession = true,
    bool includeOptionalSessionToken = true,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final uri = Uri.parse(url);
    final token = await _resolveToken(
      requireSession: requireSession,
      includeOptionalSessionToken: includeOptionalSessionToken,
    );

    return _withMockFallback<T?>(null, () async {
      final response = await ApiShared.safePost(
        client,
        uri,
        headers: ApiShared.buildJsonHeaders(token: token),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 401) {
        if (requireSession) {
          await _handleUnauthorized();
        }
        throw const ApiException(ApiExceptionMessages.sessionExpired);
      }

      if (!_isSuccessStatus(response.statusCode)) {
        final message =
            ApiShared.extractErrorMessage(response.body) ??
            '$requestErrorMessage (${response.statusCode}).';
        throw ApiException(message);
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

  Future<T?> updateAsync<T>({
    required String url,
    required Map<String, dynamic> requestBody,
    required String requestErrorMessage,
    bool requireSession = true,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final uri = Uri.parse(url);
    final token = await _resolveToken(requireSession: requireSession);

    return _withMockFallback<T?>(null, () async {
      final response = await ApiShared.safePost(
        client,
        uri,
        headers: ApiShared.buildJsonHeaders(token: token),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 401) {
        if (requireSession) {
          await _handleUnauthorized();
        }
        throw const ApiException(ApiExceptionMessages.sessionExpired);
      }

      if (!_isSuccessStatus(response.statusCode)) {
        final message =
            ApiShared.extractErrorMessage(response.body) ??
            '$requestErrorMessage (${response.statusCode}).';
        throw ApiException(message);
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

  Future<T?> deleteAsync<T>({
    required String url,
    required String requestErrorMessage,
    bool requireSession = true,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? requestBody,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final uri = Uri.parse(url);
    final mergedQueryParameters = <String, String>{
      ...uri.queryParameters,
      if (queryParameters != null) ...queryParameters,
    };
    final uriWithParams = mergedQueryParameters.isEmpty
        ? uri
        : uri.replace(queryParameters: mergedQueryParameters);
    final token = await _resolveToken(requireSession: requireSession);

    return _withMockFallback<T?>(null, () async {
      final response = await ApiShared.safePost(
        client,
        uriWithParams,
        headers: ApiShared.buildJsonHeaders(token: token),
        body: requestBody != null ? jsonEncode(requestBody) : '',
      );

      if (response.statusCode == 401) {
        if (requireSession) {
          await _handleUnauthorized();
        }
        throw const ApiException(ApiExceptionMessages.sessionExpired);
      }

      if (!_isSuccessStatus(response.statusCode)) {
        final message =
            ApiShared.extractErrorMessage(response.body) ??
            '$requestErrorMessage (${response.statusCode}).';
        throw ApiException(message);
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

  Future<T?> patchAsync<T>({
    required String url,
    required Map<String, dynamic> requestBody,
    required String requestErrorMessage,
    bool requireSession = true,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final uri = Uri.parse(url);
    final token = await _resolveToken(requireSession: requireSession);

    return _withMockFallback<T?>(null, () async {
      final response = await ApiShared.safePatch(
        client,
        uri,
        headers: ApiShared.buildJsonHeaders(token: token),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 401) {
        if (requireSession) {
          await _handleUnauthorized();
        }
        throw const ApiException(ApiExceptionMessages.sessionExpired);
      }

      if (!_isSuccessStatus(response.statusCode)) {
        final message =
            ApiShared.extractErrorMessage(response.body) ??
            '$requestErrorMessage (${response.statusCode}).';
        throw ApiException(message);
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

  Future<T?> relateToRecordAsync<T>({
    required String url,
    required Map<String, dynamic> requestBody,
    required String requestErrorMessage,
    bool requireSession = true,
    String? notFoundErrorMessage,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final uri = Uri.parse(url);
    final token = await _resolveToken(requireSession: requireSession);

    return _withMockFallback<T?>(null, () async {
      final response = await ApiShared.safePut(
        client,
        uri,
        headers: ApiShared.buildJsonHeaders(token: token),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 401) {
        if (requireSession) {
          await _handleUnauthorized();
        }
        throw const ApiException(ApiExceptionMessages.sessionExpired);
      }

      if (response.statusCode == 404 && notFoundErrorMessage != null) {
        throw ApiException(notFoundErrorMessage);
      }

      if (response.statusCode != 200) {
        final message =
            ApiShared.extractErrorMessage(response.body) ??
            '$requestErrorMessage (${response.statusCode}).';
        throw ApiException(message);
      }

      if (fromJson == null) {
        return null;
      }

      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return fromJson(body);
      } catch (error) {
        throw ApiException('Invalid server response: $error');
      }
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
