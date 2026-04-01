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

  factory MemberDto.fromJson(Map<String, dynamic> json) {
    final firstName = normOptString(json['name'] ?? json['first_name']) ?? '';
    final paternal =
        normOptString(json['paternalSurname'] ?? json['paternal_surname']) ??
        '';
    final maternal =
        normOptString(json['maternalSurname'] ?? json['maternal_surname']) ??
        '';
    return MemberDto(
      memberRut: normReqString(json['memberId'] ?? json['id']),
      memberName: firstName,
      paternalSurname: paternal,
      maternalSurname: maternal,
    );
  }
}
