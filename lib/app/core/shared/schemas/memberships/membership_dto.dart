import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';

class MembershipDto {
  const MembershipDto({
    required this.membershipId,
    required this.membershipName,
  });

  final String membershipId;
  final String membershipName;

  factory MembershipDto.fromJson(Map<String, dynamic> json) {
    return MembershipDto(
      membershipId: normReqString(json['membership_plan_id']),
      membershipName: normReqString(json['name']),
    );
  }
}
