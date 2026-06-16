import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/member/member_dto.dart';

class MembersApi extends ApiBase {
  // /users/me returns the authenticated member; there is no member-by-id lookup
  // on the gym backend, so this resolves the current session's member only.
  Future<MemberDto?> getCurrentMember() async {
    final members = await getDataListAsync<MemberDto>(
      url: '${ApiUrls.usersUrl}/me',
      requestErrorMessage: 'Error al obtener paciente',
      extractItems: ApiBase.extractSingleItemList,
      fromJson: MemberDto.fromJson,
      requireSession: true,
    );

    return members.first;
  }
}
