import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/available_slots_service.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/domain/domain.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';

class AvailabilityListingRepositoryImpl
    implements AvailabilityListingRepository {
  AvailabilityListingRepositoryImpl({AvailableSlotsService? service})
    : _service = service ?? AvailableSlotsService();

  final AvailableSlotsService _service;

  @override
  Future<List<AvailableSlotDto>> fetchAvailableBookings({
    required MemberAvailabilityFilters filters,
  }) {
    return _service.fetchAvailableBookings(filters: filters);
  }

  @override
  Future<List<AvailableSlotByCapabilityDto>>
  fetchAvailableBookingsByCapability({
    required int locationId,
    required CapabilityDto capability,
  }) {
    return _service.fetchAvailableBookingsByCapability(
      locationId: locationId,
      capability: capability,
    );
  }
}
