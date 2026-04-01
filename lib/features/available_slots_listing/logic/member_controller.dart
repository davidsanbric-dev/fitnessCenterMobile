import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/services/member_service.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:get/get.dart';

class MemberController extends ControllerBase {
  MemberController({MemberService? service})
    : _service = service ?? MemberService();

  final MemberService _service;

  final RxList<BookingsMemberOption> members = <BookingsMemberOption>[].obs;
  final RxString selectedMemberKey = ''.obs;

  bool get canSearchMembers => true;

  bool changeMember(String? memberKey) {
    return _updateNormalizedFilter(selectedMemberKey, memberKey);
  }

  Future<BookingsMemberOption?> searchMemberById(String memberId) async {
    final trimmedId = memberId.trim();
    if (trimmedId.isEmpty) {
      Get.snackbar('Invalid search', 'Enter the member ID.');
      return null;
    }

    try {
      final option = await _service.fetchMemberOptionById(trimmedId);
      if (option == null) {
        Get.snackbar(
          'Member not found',
          'No results found for the entered ID.',
        );
        return null;
      }

      members.assignAll([option]);
      return option;
    } on ApiException catch (error) {
      Get.snackbar('Search unavailable', error.message);
    } catch (error) {
      Get.snackbar('Unexpected error', 'Could not search member: $error');
    }
    return null;
  }

  String? resolveMemberId(String key) {
    final normalized = key.trim();
    if (normalized.isEmpty) return null;
    final parts = normalized.split('::');
    if (parts.length == 2) {
      final value = parts[1].trim();
      return value.isEmpty ? null : value;
    }
    return normalized;
  }

  bool _updateNormalizedFilter(RxString target, String? value) {
    final normalized = value?.trim() ?? '';
    if (target.value == normalized) return false;
    target.value = normalized;
    return true;
  }
}
