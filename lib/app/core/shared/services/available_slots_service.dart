import 'package:portfolio_mobile_app/app/core/api/booking_agenda_api.dart';
import 'package:portfolio_mobile_app/app/core/api/available_slots_api.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/booking/schedule_booking_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/booking/schedule_booking_by_class_type_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slots_by_capability_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slots_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/utils/parse.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';

class AvailableSlotsService {
  AvailableSlotsService({
    AvailableSlotsApi? availableSlotsApi,
    BookingAgendaApi? bookingsApi,
  }) : _availableSlotsApi = availableSlotsApi ?? AvailableSlotsApi(),
       _bookingsApi = bookingsApi ?? BookingAgendaApi();

  static const Duration _availabilityLoadTimeout = Duration(seconds: 20);
  static const String _availabilityLoadTimeoutErrorMessage =
      'Timed out while loading available slots.';

  final AvailableSlotsApi _availableSlotsApi;
  final BookingAgendaApi _bookingsApi;

  Future<List<AvailableSlotDto>> fetchAvailableBookings({
    required MemberAvailabilityFilters filters,
  }) async {
    final request = AvailableSlotsRequest(
      disciplineId: filters.disciplineId,
      trainerId: filters.trainerId,
      locationId: filters.locationId,
      isOnline: filters.isOnline,
    );

    return _runWithAvailabilityTimeout(
      () => _availableSlotsApi.getAvailableBookings(request),
    );
  }

  Future<List<AvailableSlotByCapabilityDto>>
  fetchAvailableBookingsByCapability({
    required int locationId,
    required CapabilityDto capability,
  }) {
    return _availableSlotsApi.getAvailableBookingsByCapability(
      request: AvailableSlotsByCapabilityRequest(
        capabilityId: capability.id,
        locationId: locationId,
        capabilityDescription: capability.description,
      ),
    );
  }

  Future<void> reserveBooking({
    required AvailableSlotDto slot,
    required MemberAvailabilityFilters? lastFilters,
    String? online,
  }) async {
    final scheduleRequest = _buildScheduleRequest(
      slot: slot,
      lastFilters: lastFilters,
      online: online,
    );
    await _bookingsApi.scheduleBooking(request: scheduleRequest);
  }

  Future<void> reserveBookingByCapability({
    required AvailableSlotByCapabilityDto slot,
  }) async {
    final locationId = slot.locationId;
    final trainerCode = slot.trainerCode;
    final classTypeId = slot.classTypeId;
    final slotAssignmentCode = slot.slotAssignmentCode.trim();

    if (locationId <= 0 ||
        trainerCode <= 0 ||
        classTypeId <= 0 ||
        slotAssignmentCode.isEmpty) {
      throw const ApiException(
        'Could not resolve booking payload for this class slot.',
      );
    }

    final schedulingDate = slot.schedulingDate.toLocal();

    await _bookingsApi.scheduleBookingByClassType(
      request: ScheduleBookingByClassTypeRequest(
        bookingDate: formatDateIso(schedulingDate),
        bookingTime: formatTime(schedulingDate),
        locationCode: locationId.toString(),
        trainerCode: trainerCode,
        slotAssignmentCode: slotAssignmentCode,
        classTypeId: classTypeId,
      ),
    );
  }

  Future<T> _runWithAvailabilityTimeout<T>(Future<T> Function() loader) {
    return loader().timeout(
      _availabilityLoadTimeout,
      onTimeout: () =>
          throw const ApiException(_availabilityLoadTimeoutErrorMessage),
    );
  }

  ScheduleBookingRequest _buildScheduleRequest({
    required AvailableSlotDto slot,
    required MemberAvailabilityFilters? lastFilters,
    String? online,
  }) {
    final disciplineCode = slot.disciplineCode ?? lastFilters?.disciplineId;
    final trainerCode = slot.trainerCode ?? parseOptInt(lastFilters?.trainerId);
    final locationCode = slot.locationId ?? lastFilters?.locationId;

    final schedulingDate = slot.schedulingDate.toLocal();
    final onlineFlag = _resolveOnlineFlag(slot: slot, online: online);

    return ScheduleBookingRequest(
      date: formatDateIso(schedulingDate),
      time: formatTime(schedulingDate),
      locationCode: locationCode.toString(),
      bookingDuration: slot.duration ?? 0,
      disciplineCode: disciplineCode ?? 0,
      trainerCode: trainerCode ?? 0,
      online: onlineFlag,
    );
  }

  String _resolveOnlineFlag({required AvailableSlotDto slot, String? online}) {
    final explicitFlag = online?.trim() ?? '';
    if (explicitFlag.isNotEmpty) {
      return explicitFlag;
    }
    final slotFlag = slot.isOnline;
    if (slotFlag != null) {
      return slotFlag ? '1' : '0';
    }
    return '0';
  }
}
