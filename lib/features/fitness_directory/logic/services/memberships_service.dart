import 'package:portfolio_mobile_app/app/core/api/memberships_api.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/memberships/membership_dto.dart';

class MembershipsService {
  MembershipsService({MembershipsApi? membershipsApi})
    : _membershipsApi = membershipsApi ?? MembershipsApi();

  final MembershipsApi _membershipsApi;

  Future<List<MembershipDto>> fetchMemberships() {
    return _membershipsApi.getMemberships();
  }
}
