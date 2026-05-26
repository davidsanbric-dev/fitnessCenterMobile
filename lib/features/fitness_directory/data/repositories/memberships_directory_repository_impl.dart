import 'package:portfolio_mobile_app/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/domain/domain.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/logic/services/memberships_service.dart';

class MembershipsDirectoryRepositoryImpl
    implements MembershipsDirectoryRepository {
  MembershipsDirectoryRepositoryImpl({MembershipsService? service})
    : _service = service ?? MembershipsService();

  final MembershipsService _service;

  @override
  Future<List<MembershipDto>> fetchMemberships() {
    return _service.fetchMemberships();
  }
}
