import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/member/member_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/member/member_request.dart';

class MembersApi extends ApiBase {
  Future<MemberDto?> getMember(MemberRequest request) async {
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
