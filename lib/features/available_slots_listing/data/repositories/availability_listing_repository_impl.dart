import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/services/available_slots_service.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/domain/domain.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';

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
  fetchAvailableBookingsByCapability({required CapabilityDto capability}) {
    return _service.fetchAvailableBookingsByCapability(capability: capability);
  }
}
