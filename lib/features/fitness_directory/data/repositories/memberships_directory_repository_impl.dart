import 'package:fitnesscenter_mobile/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/domain/domain.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/data/services/memberships_service.dart';

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
