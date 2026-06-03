import 'package:portfolio_mobile_app/app/core/api/shared/api_base.dart';
import 'package:portfolio_mobile_app/app/core/api/shared/types.dart';
import 'package:portfolio_mobile_app/app/core/constants/api_urls.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/location_code_registry.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slots_by_capability_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slots_request.dart';

class AvailableSlotsApi extends ApiBase {
  AvailableSlotsApi() : super();

  Future<List<AvailableSlotDto>> getAvailableBookings(
    AvailableSlotsRequest request, {
    int? pageNumber,
    int? pageSize,
  }) async {
    final queryParameters = _buildQueryParameters(
      request,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return getDataListAsync<AvailableSlotDto>(
      url: ApiUrls.slotsUrl,
      requestErrorMessage: 'Error al obtener citas disponibles',
      queryParameters: queryParameters,
      fromJson: AvailableSlotDto.fromJson,
    );
  }

  Future<PaginatedResult<AvailableSlotDto>> getAvailableBookingsPaginated(
    AvailableSlotsRequest request, {
    int? pageNumber,
    int? pageSize,
  }) async {
    final items = await getAvailableBookings(
      request,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return PaginatedResult<AvailableSlotDto>(
      items: items,
      totalItems: items.length,
      pageNumber: pageNumber ?? 1,
      pageSize: pageSize ?? items.length,
    );
  }

  Map<String, String> _buildQueryParameters(
    AvailableSlotsRequest request, {
    int? pageNumber,
    int? pageSize,
  }) {
    final legacy = request.toQueryParameters();
    final mappedLocationCode = LocationCodeRegistry.instance.resolve(
      legacy['locationCode'] ?? '',
    );
    final mapped = <String, String>{
      'date_from': legacy['startDateTime'] ?? '',
      'date_to': legacy['endDateTime'] ?? '',
      if (mappedLocationCode.trim().isNotEmpty)
        'location_code': mappedLocationCode,
      if ((legacy['trainerCode'] ?? '').trim().isNotEmpty)
        'trainer_id': legacy['trainerCode']!,
      if ((legacy['disciplineCode'] ?? '').trim().isNotEmpty)
        'discipline_id': legacy['disciplineCode']!,
      if (pageNumber != null) 'page': pageNumber.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };

    mapped.removeWhere((_, value) => value.trim().isEmpty);
    return mapped;
  }

  Future<List<AvailableSlotByCapabilityDto>> getAvailableBookingsByCapability({
    required AvailableSlotsByCapabilityRequest request,
  }) async {
    return getDataListAsync<AvailableSlotByCapabilityDto>(
      url: '${ApiUrls.classTypesUrl}/${request.capabilityId}/availability',
      requestErrorMessage: 'Error fetching available slots by class option',
      queryParameters: _buildCapabilityAvailabilityQuery(request),
      extractItems: (data) {
        if (data is List) {
          return data;
        }
        if (data is Map<String, dynamic>) {
          final slots = data['slots'];
          if (slots is List) {
            return slots;
          }
          final items = data['items'];
          if (items is List) {
            return items;
          }
          final value = data['value'];
          if (value is List) {
            return value;
          }
        }
        return const <dynamic>[];
      },
      fromJson: (json) => AvailableSlotByCapabilityDto.fromJson(
        json,
        defaultLocationId: request.locationId,
        defaultCapabilityId: request.capabilityId,
        defaultCapabilityDescription: request.capabilityDescription,
      ),
    );
  }

  Map<String, String> _buildCapabilityAvailabilityQuery(
    AvailableSlotsByCapabilityRequest request,
  ) {
    final legacy = request.toQueryParameters();
    final query = <String, String>{
      'location_code': LocationCodeRegistry.instance.resolve(
        legacy['locationCode'] ?? '',
      ),
      'query_type': legacy['queryType'] ?? request.queryType.toString(),
      if ((legacy['startDate'] ?? '').trim().isNotEmpty)
        'date_from': legacy['startDate']!,
      if ((legacy['endDate'] ?? '').trim().isNotEmpty)
        'date_to': legacy['endDate']!,
      if ((legacy['trainerCode'] ?? '').trim().isNotEmpty)
        'trainer_id': legacy['trainerCode']!,
    };

    query.removeWhere((_, value) => value.trim().isEmpty);
    return query;
  }
}
