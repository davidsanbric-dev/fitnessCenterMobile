import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/api/shared/types.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';

class DisciplinesApi extends ApiBase {
  Future<PaginatedResult<DisciplineDto>> getDisciplines({
    int? pageNumber,
    int? pageSize,
  }) async {
    return getPaginatedDataListAsync<DisciplineDto>(
      url: ApiUrls.disciplinesUrl,
      requestErrorMessage: 'Error al obtener especialidades',
      fromJson: DisciplineDto.fromJson,
      queryParameters: <String, String>{
        if (pageNumber != null) 'page': pageNumber.toString(),
        if (pageSize != null) 'page_size': pageSize.toString(),
      },
      extractItems: _extractDisciplineItems,
    );
  }

  // Consider adding an extractItems Helper at ApiBase level
  static List<dynamic> _extractDisciplineItems(dynamic data) {
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'];
      if (items is List) {
        return items;
      }
      final value = data['value'];
      if (value is List) {
        return value;
      }
      final nestedData = data['data'];
      if (nestedData is List) {
        return nestedData;
      }
      if (nestedData is Map<String, dynamic>) {
        final nestedItems = nestedData['items'];
        if (nestedItems is List) {
          return nestedItems;
        }
        final nestedValue = nestedData['value'];
        if (nestedValue is List) {
          return nestedValue;
        }
      }
    }
    return const <dynamic>[];
  }
}
