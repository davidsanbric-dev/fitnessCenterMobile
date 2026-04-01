import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/api/shared/api_envelope.dart';
import 'package:portfolio_mobile_app/app/core/api/shared/api_shared.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_exception_messages.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/user/create_user_request.dart';
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

  Future<void> createUser({required CreateUserRequest request}) async {
    final requestBody = request.toRegisterRequestBody();

    await createAsync<void>(
      url: '${ApiUrls.authUrl}/register',
      requestErrorMessage: 'Error al crear usuario',
      requestBody: requestBody,
      requireSession: false,
      includeOptionalSessionToken: false,
    );
  }

  Future<Map<String, dynamic>?> syncFirebaseClaims({
    required String token,
  }) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      return null;
    }

    final response = await ApiShared.safePost(
      client,
      Uri.parse('${ApiUrls.authUrl}/firebase/sync-claims'),
      headers: ApiShared.buildJsonHeaders(token: trimmedToken),
      body: '',
    );

    if (response.statusCode == 401) {
      throw const ApiException(ApiExceptionMessages.sessionExpired);
    }
    if (response.statusCode != 200) {
      final message =
          ApiShared.extractErrorMessage(response.body) ??
          'Error al sincronizar claims (${response.statusCode}).';
      throw ApiException(message);
    }

    final envelope = ApiEnvelope.fromResponse(response);
    envelope.validateSuccess(
      fallbackMessage: 'No fue posible sincronizar los claims de Firebase.',
    );

    final data = envelope.data;
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final claims = data['claims'];
    if (claims is Map<String, dynamic>) {
      return claims;
    }
    if (claims is Map) {
      return Map<String, dynamic>.from(claims);
    }
    return null;
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
