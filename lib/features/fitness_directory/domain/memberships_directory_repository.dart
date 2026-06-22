import 'package:fitnesscenter_mobile/app/core/shared/schemas/memberships/membership_dto.dart';

abstract interface class MembershipsDirectoryRepository {
  Future<List<MembershipDto>> fetchMemberships();
}
