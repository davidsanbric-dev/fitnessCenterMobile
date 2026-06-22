import 'package:fitnesscenter_mobile/app/core/shared/services/disciplines_service.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/domain/domain.dart';

class MemberFiltersRepositoryImpl implements MemberFiltersRepository {
  MemberFiltersRepositoryImpl({DisciplinesService? service})
    : _service = service ?? DisciplinesService();

  final DisciplinesService _service;

  @override
  Future<DisciplinesFilterData> fetchDisciplinesFilterData() {
    return _service.fetchDisciplinesFilterData();
  }
}
