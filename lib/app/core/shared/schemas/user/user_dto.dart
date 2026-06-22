import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';
import 'package:fitnesscenter_mobile/app/core/utils/parse.dart';

class UserDetailsDto {
  const UserDetailsDto({
    this.identificationType = '',
    this.memberId = '',
    this.firstName = '',
    this.paternalLastName = '',
    this.maternalLastName = '',
    this.landlinePhone = '',
    this.mobilePhone = '',
    this.email = '',
    this.dateOfBirth = '',
    this.address = '',
    this.membership = '',
    this.documentId = '',
  });

  final String identificationType;
  final String memberId;
  final String firstName;
  final String paternalLastName;
  final String maternalLastName;
  final String landlinePhone;
  final String mobilePhone;
  final String email;
  final String dateOfBirth;
  final String address;
  final String membership;
  final String documentId;

  factory UserDetailsDto.fromJson(Map<String, dynamic> json) {
    return UserDetailsDto(
      identificationType: normOptString(json['identificationType']) ?? '',
      memberId: normOptString(json['memberId']) ?? '',
      firstName: normOptString(json['firstName']) ?? '',
      paternalLastName: normOptString(json['paternalLastName']) ?? '',
      maternalLastName: normOptString(json['maternalLastName']) ?? '',
      landlinePhone: normOptString(json['landlinePhone']) ?? '',
      mobilePhone: normOptString(json['mobilePhone']) ?? '',
      email: normOptString(json['email']) ?? '',
      dateOfBirth: normOptString(json['dateOfBirth']) ?? '',
      address: normOptString(json['address']) ?? '',
      membership: normOptString(json['membership']) ?? '',
      documentId: normOptString(json['documentId']) ?? '',
    );
  }

  factory UserDetailsDto.fromClaims(Map<String, dynamic> claims) {
    final detailsMap =
        parseOptMap(claims['details']) ?? const <String, dynamic>{};
    return UserDetailsDto.fromJson(detailsMap);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'identificationType': identificationType,
      'memberId': memberId,
      'firstName': firstName,
      'paternalLastName': paternalLastName,
      'maternalLastName': maternalLastName,
      'landlinePhone': landlinePhone,
      'mobilePhone': mobilePhone,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'membership': membership,
      'documentId': documentId,
    };
  }

  String? get fullLastName {
    final parts = [paternalLastName, maternalLastName]
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' ');
  }

  String? get preferredPhone {
    final mobile = normOptString(mobilePhone);
    if (mobile != null) {
      return mobile;
    }
    return normOptString(landlinePhone);
  }
}

class UserDto {
  const UserDto({
    required this.id,
    required this.roleId,
    required this.name,
    required this.lastname,
    required this.email,
    this.roleName = '',
    this.roleEliminated = false,
    this.rut = '',
    this.isEliminated = false,
    this.creationDate,
    this.dateLastModified,
    this.details,
  });

  final String id;
  final String roleId;
  final String roleName;
  final bool roleEliminated;
  final String name;
  final String lastname;
  final String email;
  final String rut;
  final bool isEliminated;
  final DateTime? creationDate;
  final DateTime? dateLastModified;
  final UserDetailsDto? details;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final roleMap = normReqMap(json['role']);
    final detailsMap = normReqMap(json['details']);
    final details = detailsMap.isEmpty
        ? _detailsFromFlatJson(json)
        : UserDetailsDto.fromJson(detailsMap);
    final firstName =
        normOptString(json['first_name']) ?? normOptString(json['name']) ?? '';
    final lastName = [
      normOptString(json['paternal_surname']) ??
          normOptString(json['paternalLastName']) ??
          '',
      normOptString(json['maternal_surname']) ??
          normOptString(json['maternalLastName']) ??
          '',
    ].where((value) => value.trim().isNotEmpty).join(' ');

    return UserDto(
      id: normReqString(json['id']),
      roleId:
          normOptString(json['roleId']) ?? normOptString(roleMap['id']) ?? '',
      roleName: normReqString(roleMap['name']),
      roleEliminated: parseBool(roleMap['isEliminated']),
      name: details?.firstName ?? firstName,
      lastname:
          details?.fullLastName ?? normOptString(json['lastName']) ?? lastName,
      email:
          details?.email ??
          normOptString(json['mail']) ??
          normOptString(json['email']) ??
          '',
      rut: details?.memberId ?? normOptString(json['rut']) ?? '',
      isEliminated: parseBool(json['isEliminated']),
      creationDate: parseDateTime(json['creationDate'] ?? json['created_at']),
      dateLastModified: parseDateTime(json['dateLastModified']),
      details: details,
    );
  }

  /// Builds a [UserDetailsDto] from the flat snake_case `/users/me` response
  /// (Firebase-only backend), which no longer nests a `details` object.
  /// Returns `null` when no relevant fields are present so callers keep their
  /// existing "no details" behavior.
  static UserDetailsDto? _detailsFromFlatJson(Map<String, dynamic> json) {
    final firstName = normOptString(json['first_name']);
    final paternal = normOptString(json['paternal_surname']);
    final maternal = normOptString(json['maternal_surname']);
    final mobile = normOptString(json['mobile_phone']);
    final landline = normOptString(json['landline_phone']);
    final email = normOptString(json['email']);
    final birthDate = normOptString(json['birth_date']);
    final address = normOptString(json['address']);
    final membership = normOptString(
      normReqMap(json['membership_plan'])['name'],
    );
    // The RUT is the member's identification; carry it into `memberId` so it
    // survives the details round-trip. `UserDto.rut` resolves from
    // `details.memberId` first, so leaving this empty would blank out the RUT
    // even when the flat payload supplies it.
    final rut = normOptString(json['rut']);

    final hasAnyField = [
      firstName,
      paternal,
      maternal,
      mobile,
      landline,
      birthDate,
      address,
      membership,
      rut,
    ].any((value) => value != null);
    if (!hasAnyField) {
      return null;
    }

    return UserDetailsDto(
      memberId: rut ?? '',
      firstName: firstName ?? '',
      paternalLastName: paternal ?? '',
      maternalLastName: maternal ?? '',
      mobilePhone: mobile ?? '',
      landlinePhone: landline ?? '',
      email: email ?? '',
      dateOfBirth: birthDate ?? '',
      address: address ?? '',
      membership: membership ?? '',
    );
  }

  UserDto copyWith({
    String? id,
    String? roleId,
    String? roleName,
    bool? roleEliminated,
    String? name,
    String? lastname,
    String? email,
    String? rut,
    bool? isEliminated,
    DateTime? creationDate,
    DateTime? dateLastModified,
    UserDetailsDto? details,
  }) {
    return UserDto(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      roleEliminated: roleEliminated ?? this.roleEliminated,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      rut: rut ?? this.rut,
      isEliminated: isEliminated ?? this.isEliminated,
      creationDate: creationDate ?? this.creationDate,
      dateLastModified: dateLastModified ?? this.dateLastModified,
      details: details ?? this.details,
    );
  }
}
