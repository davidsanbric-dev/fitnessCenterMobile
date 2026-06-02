import 'dart:convert';

import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/api/shared/api_envelope.dart';
import 'package:portfolio_mobile_app/app/core/api/shared/api_shared.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_exception_messages.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/user/user_dto.dart';

class UserApi extends ApiBase {
  UserApi() : super();

  Future<UserDto?> getUserByMail({required String mail, String? token}) async {
    final normalizedMail = mail.trim();
    if (normalizedMail.isEmpty) {
      return null;
    }

    final trimmedToken = token?.trim();
    if (trimmedToken == null || trimmedToken.isEmpty) {
      return null;
    }

    final response = await ApiShared.safeGet(
      client,
      Uri.parse('${ApiUrls.usersUrl}/me'),
      headers: ApiShared.buildJsonHeaders(token: trimmedToken),
    );

    if (response.statusCode == 401) {
      throw const ApiException(ApiExceptionMessages.sessionExpired);
    }
    if (response.statusCode != 200) {
      final message =
          ApiShared.extractErrorMessage(response.body) ??
          'Error al obtener usuario (${response.statusCode}).';
      throw ApiException(message);
    }

    final envelope = ApiEnvelope.fromResponse(response);
    envelope.validateSuccess(
      fallbackMessage: 'El servidor no pudo devolver el usuario.',
    );

    final users = ApiBase.extractSingleItemList(envelope.data)
        .map((item) => UserDto.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
    if (users.isEmpty) {
      return null;
    }

    final user = users.first;
    if (user.email.trim().toLowerCase() != normalizedMail.toLowerCase()) {
      return null;
    }

    return user;
  }

  /// Exchanges the Firebase ID token for an app session via the backend's
  /// origin-gated entry point (`/auth/firebase-login`).
  ///
  /// The backend verifies the token, enforces that only a member account may
  /// sign in from the mobile app (the `X-Client-Platform: mobile` header drives
  /// the ClientOrigin gate), and writes the custom claims (`app_role`,
  /// `app_display_name`, ...). The caller then force-refreshes the ID token to
  /// pick those claims up. The response body is not consumed here -- the rich
  /// session profile is hydrated separately from `/users/me`.
  Future<void> firebaseLogin({required String token}) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      throw const ApiException(ApiExceptionMessages.sessionMissing);
    }

    final response = await ApiShared.safePost(
      client,
      Uri.parse('${ApiUrls.authUrl}/firebase-login'),
      headers: ApiShared.buildJsonHeaders(),
      body: jsonEncode({'id_token': trimmedToken}),
    );

    if (response.statusCode == 401) {
      throw const ApiException(ApiExceptionMessages.sessionExpired);
    }
    if (response.statusCode != 200) {
      // Includes 403 from the origin gate (e.g. a non-member account); surface
      // the backend's detail message to the user.
      final message =
          ApiShared.extractErrorMessage(response.body) ??
          'Error al iniciar sesión (${response.statusCode}).';
      throw ApiException(message);
    }
  }

  Future<void> checkIdentityGovernment({
    required String rut,
    String document = '',
  }) async {
    final normalizedRut = rut
        .trim()
        .toUpperCase()
        .replaceAll('.', '')
        .replaceAll(' ', '');
    final formattedDocument = document.trim();

    final rutPattern = RegExp(r'^[0-9]{7,8}-[0-9K]$');

    if (normalizedRut.isEmpty ||
        (!rutPattern.hasMatch(normalizedRut) && formattedDocument.isEmpty)) {
      throw const ApiException(
        'No fue posible verificar tu identidad con los datos ingresados.',
      );
    }
  }
}
