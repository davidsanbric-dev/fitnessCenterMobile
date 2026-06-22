import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/services/available_slots_service.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';
import 'package:fitnesscenter_mobile/features/class_booking/domain/class_booking_repository.dart';

class ClassBookingRepositoryImpl implements ClassBookingRepository {
  ClassBookingRepositoryImpl({AvailableSlotsService? service})
    : _service = service ?? AvailableSlotsService();

  final AvailableSlotsService _service;

  @override
  Future<void> bookStandard({
    required AvailableSlotDto slot,
    MemberAvailabilityFilters? listingContext,
  }) {
    return _service.reserveBooking(slot: slot, lastFilters: listingContext);
  }

  @override
  Future<void> bookByClassType({required AvailableSlotByCapabilityDto slot}) {
    return _service.reserveBookingByCapability(slot: slot);
  }
}
