import 'dart:convert';
import 'dart:typed_data';

import 'package:portfolio_mobile_app/app/core/api/shared/api_envelope.dart';
import 'package:portfolio_mobile_app/app/core/api/shared/api_shared.dart';
import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_exception_messages.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:http/http.dart' as http;

class DocumentApi extends ApiBase {
  DocumentApi() : super();

  Future<String> uploadDocument({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final trimmedFileName = fileName.trim();
    if (fileBytes.isEmpty) {
      throw const ApiException('The file to upload is empty.');
    }
    if (trimmedFileName.isEmpty) {
      throw const ApiException('File name is required.');
    }

    final token = await ApiShared.requireToken(cache);
    final uri = Uri.parse('${ApiUrls.documentsUrl}/Upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: trimmedFileName,
        ),
      );

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await request.send();
    } catch (error) {
      throw ApiException('${ApiExceptionMessages.networkErrorPrefix} $error');
    }

    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 401) {
      throw const ApiException(ApiExceptionMessages.sessionExpired);
    }
    if (response.statusCode == 404 || response.statusCode == 405) {
      return _buildFallbackDocumentId(fileBytes, trimmedFileName);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          ApiShared.extractErrorMessage(response.body) ??
          'Could not upload the document (${response.statusCode}).';
      throw ApiException(message);
    }

    final envelope = ApiEnvelope.fromResponse(response);
    envelope.validateSuccess(
      fallbackMessage: 'Could not upload the signed document.',
    );
    final documentId = _extractDocumentId(envelope.data);
    if (documentId == null || documentId.isEmpty) {
      throw const ApiException(
        'Could not obtain the uploaded document identifier.',
      );
    }

    return documentId;
  }

  String? _extractDocumentId(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is String) {
      return _normalizeDocumentId(data);
    }

    if (data is Map<String, dynamic>) {
      final direct = _normalizeDocumentId(
        data['documentId'] ?? data['DocumentId'] ?? data['id'] ?? data['Id'],
      );
      if (direct != null) {
        return direct;
      }
      return _normalizeDocumentId(data['value'] ?? data['Value']);
    }

    return _normalizeDocumentId(data);
  }

  String? _normalizeDocumentId(dynamic raw) {
    if (raw == null) {
      return null;
    }
    final normalized = raw.toString().trim();
    if (normalized.isEmpty) {
      return null;
    }
    final guidMatch = RegExp(
      r'^[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}$',
    ).hasMatch(normalized);
    if (guidMatch) {
      return normalized;
    }

    try {
      final decoded = jsonDecode(normalized);
      if (decoded is String) {
        final nested = decoded.trim();
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    } catch (_) {
      // Keep original normalized value if it's not JSON.
    }
    return normalized;
  }

  String _buildFallbackDocumentId(Uint8List fileBytes, String fileName) {
    final checksum = fileBytes.fold<int>(0, (acc, b) => (acc + b) % 1000000);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitized = fileName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'local-$timestamp-$checksum-$sanitized';
  }
}
