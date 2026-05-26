import 'package:portfolio_mobile_app/app/core/shared/services/disciplines_service.dart';

abstract interface class MemberFiltersRepository {
  Future<DisciplinesFilterData> fetchDisciplinesFilterData();
}
