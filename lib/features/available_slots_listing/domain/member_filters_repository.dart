import 'package:fitnesscenter_mobile/app/core/shared/services/disciplines_service.dart';

abstract interface class MemberFiltersRepository {
  Future<DisciplinesFilterData> fetchDisciplinesFilterData();
}
