import 'package:fitnesscenter_mobile/app/core/shared/schemas/user/user_dto.dart';
import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthSessionClaimsMapper {
  const AuthSessionClaimsMapper();

  Map<String, dynamic> fromUserDto({
    required UserDto userDto,
    required User firebaseUser,
  }) {
    final claims = Map<String, dynamic>.from(_userDataFromDto(userDto));
    final details = UserDetailsDto.fromJson(
      (userDto.details ?? const UserDetailsDto()).toJson(),
    );
    final normalizedDetails = details.toJson();
    // Keep original nested payload and expose details fields at root level.
    claims['details'] = normalizedDetails;
    for (final entry in normalizedDetails.entries) {
      claims[entry.key] = entry.value;
    }

    claims['lastName'] = normReqString(details.paternalLastName);
    claims['email'] = claims['mail'] ?? claims['email'] ?? '';
    claims['userName'] = claims['userName'] ?? '';

    return claims;
  }

  Map<String, dynamic> fromFirebaseUser(User user, {String? fallbackEmail}) {
    final claims = <String, dynamic>{};
    claims['email'] = normOptString(user.email) ?? normReqString(fallbackEmail);
    claims['userName'] = normReqString(user.displayName);

    return claims;
  }

  Map<String, dynamic> _userDataFromDto(UserDto dto) {
    final details = dto.details;

    return <String, dynamic>{
      'id': dto.id,
      'roleId': dto.roleId,
      'name': dto.name,
      'lastName': dto.lastname,
      'mail': dto.email,
      'email': dto.email,
      'rut': dto.rut,
      'isEliminated': dto.isEliminated,
      'creationDate': dto.creationDate?.toIso8601String(),
      'dateLastModified': dto.dateLastModified?.toIso8601String(),
      'role': <String, dynamic>{
        'id': dto.roleId,
        'name': dto.roleName,
        'isEliminated': dto.roleEliminated,
      },
      if (details != null) 'details': details.toJson(),
    };
  }
}
