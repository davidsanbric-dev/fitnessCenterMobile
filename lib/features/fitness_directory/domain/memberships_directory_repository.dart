import 'package:portfolio_mobile_app/app/core/shared/schemas/memberships/membership_dto.dart';

abstract interface class MembershipsDirectoryRepository {
  Future<List<MembershipDto>> fetchMemberships();
}
