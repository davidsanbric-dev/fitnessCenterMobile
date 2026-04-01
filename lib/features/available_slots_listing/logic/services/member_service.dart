import 'package:portfolio_mobile_app/app/core/api/members_api.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/member/member_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/member/member_request.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';

class MemberService {
  MemberService({MembersApi? membersApi})
    : _membersApi = membersApi ?? MembersApi();

  final MembersApi _membersApi;

  Future<BookingsMemberOption?> fetchMemberOptionById(String memberId) async {
    final trimmedId = memberId.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    final member = await _membersApi.getMember(
      MemberRequest(memberId: trimmedId),
    );
    if (member == null) {
      return null;
    }

    return _buildMemberOption(member, trimmedId);
  }

  BookingsMemberOption _buildMemberOption(MemberDto member, String fallbackId) {
    final resolvedId = member.memberRut.trim().isNotEmpty
        ? member.memberRut.trim()
        : fallbackId;
    final name = member.fullName.trim();
    final label = name.isNotEmpty
        ? name
        : (resolvedId.isNotEmpty ? resolvedId : 'Paciente sin datos');

    return BookingsMemberOption(
      key: resolvedId,
      label: label,
      kind: MemberFilterKind.rut,
    );
  }
}
