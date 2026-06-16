import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class MemberDto {
  const MemberDto({
    required this.memberRut,
    required this.memberName,
    this.paternalSurname,
    this.maternalSurname = '',
  });

  final String memberRut;
  final String memberName;
  final String? paternalSurname;
  final String? maternalSurname;

  String get fullName {
    final parts =
        [memberName.trim(), paternalSurname?.trim(), maternalSurname?.trim()]
            .whereType<String>()
            .where((value) => value.isNotEmpty)
            .toList(growable: false);
    return parts.join(' ');
  }

  // Maps the `CurrentUserResponse` contract from GET /users/me (snake_case).
  // The RUT is the member identification: it comes from `rut`, not the numeric
  // user `id`.
  factory MemberDto.fromJson(Map<String, dynamic> json) {
    return MemberDto(
      memberRut: normOptString(json['rut']) ?? '',
      memberName: normOptString(json['first_name']) ?? '',
      paternalSurname: normOptString(json['paternal_surname']) ?? '',
      maternalSurname: normOptString(json['maternal_surname']) ?? '',
    );
  }
}
