import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/memberships/membership_dto.dart';

class MembershipsApi extends ApiBase {
  Future<List<MembershipDto>> getMemberships() async {
    return getDataListAsync<MembershipDto>(
      url: ApiUrls.membershipPlansUrl,
      requestErrorMessage: 'Error al obtener membershipes',
      fromJson: MembershipDto.fromJson,
    );
  }
}
