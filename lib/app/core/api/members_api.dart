import 'dart:convert';

import 'package:fitnesscenter_mobile/app/core/api/shared/api_base.dart';
import 'package:fitnesscenter_mobile/app/core/api/shared/api_envelope.dart';
import 'package:fitnesscenter_mobile/app/core/api/shared/api_shared.dart';
import 'package:fitnesscenter_mobile/app/core/constants/api_exception_messages.dart';
import 'package:fitnesscenter_mobile/app/core/constants/api_urls.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/member/member_dto.dart';

class MembersApi extends ApiBase {
  // /users/me returns the authenticated member; there is no member-by-id lookup
  // on the gym backend, so this resolves the current session's member only.
  Future<MemberDto?> getCurrentMember() async {
    final members = await getDataListAsync<MemberDto>(
      url: '${ApiUrls.usersUrl}/me',
      requestErrorMessage: 'Error al obtener paciente',
      extractItems: ApiBase.extractSingleItemList,
      fromJson: MemberDto.fromJson,
      requireSession: true,
    );

    return members.first;
  }

  /// Uploads a new avatar (a base64 data URL) via PUT /users/me and returns the
  /// refreshed member. The backend transcodes the image to WebP and derives
  /// `avatar_url` from the stored filename.
  Future<MemberDto> updateAvatar(String imageDataUrl) async {
    final token = await requireTokenOrNull();
    if (token == null) {
      throw const ApiException(ApiExceptionMessages.sessionMissing);
    }

    final response = await ApiShared.safePut(
      client,
      Uri.parse('${ApiUrls.usersUrl}/me'),
      headers: ApiShared.buildJsonHeaders(token: token),
      body: jsonEncode({'avatar_image': imageDataUrl}),
    );

    if (response.statusCode == 401) {
      throw const ApiException(ApiExceptionMessages.sessionExpired);
    }
    if (response.statusCode != 200) {
      final message =
          ApiShared.extractErrorMessage(response.body) ??
          'Error updating avatar (${response.statusCode}).';
      throw ApiException(message);
    }

    final envelope = ApiEnvelope.fromResponse(response);
    envelope.validateSuccess(
      fallbackMessage: 'The server could not update the avatar.',
    );

    final members = ApiBase.extractSingleItemList(envelope.data)
        .map(
          (item) => MemberDto.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
    if (members.isEmpty) {
      throw const ApiException('The server could not update the avatar.');
    }

    return members.first;
  }
}
