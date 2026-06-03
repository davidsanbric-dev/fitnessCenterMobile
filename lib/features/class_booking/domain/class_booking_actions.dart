import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';

abstract interface class ClassBookingActions {
  bool get isStandardBookingInProgress;
  bool get isClassTypeBookingInProgress;
  String? get standardBookingError;
  String? get classTypeBookingError;

  Future<void> bookStandard({
    required AvailableSlotDto slot,
    MemberAvailabilityFilters? listingContext,
  });

  Future<void> bookByClassType({required AvailableSlotByCapabilityDto slot});
}
