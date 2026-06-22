import 'package:fitnesscenter_mobile/app/core/api/booking_agenda_api.dart';
import 'package:fitnesscenter_mobile/app/core/api/available_slots_api.dart';
import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/booking/schedule_booking_request.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/booking/schedule_booking_by_class_type_request.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slots_by_capability_request.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slots_request.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/utils/format/date_time.dart';
import 'package:fitnesscenter_mobile/app/core/utils/parse.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';

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
    );

    return _runWithAvailabilityTimeout(
      () => _availableSlotsApi.getAvailableBookings(request),
    );
  }

  Future<List<AvailableSlotByCapabilityDto>>
  fetchAvailableBookingsByCapability({required CapabilityDto capability}) {
    return _availableSlotsApi.getAvailableBookingsByCapability(
      request: AvailableSlotsByCapabilityRequest(
        capabilityId: capability.id,
        capabilityDescription: capability.description,
      ),
    );
  }

  Future<void> reserveBooking({
    required AvailableSlotDto slot,
    required MemberAvailabilityFilters? lastFilters,
  }) async {
    final scheduleRequest = _buildScheduleRequest(
      slot: slot,
      lastFilters: lastFilters,
    );
    await _bookingsApi.scheduleBooking(request: scheduleRequest);
  }

  Future<void> reserveBookingByCapability({
    required AvailableSlotByCapabilityDto slot,
  }) async {
    final trainerCode = slot.trainerCode;
    final classTypeId = slot.classTypeId;
    final slotAssignmentCode = slot.slotAssignmentCode.trim();

    if (trainerCode <= 0 || classTypeId <= 0 || slotAssignmentCode.isEmpty) {
      throw const ApiException(
        'Could not resolve booking payload for this class slot.',
      );
    }

    final schedulingDate = slot.schedulingDate.toLocal();

    await _bookingsApi.scheduleBookingByClassType(
      request: ScheduleBookingByClassTypeRequest(
        bookingDate: formatDateIso(schedulingDate),
        bookingTime: formatTimeIso(schedulingDate),
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
  }) {
    final disciplineCode = slot.disciplineCode ?? lastFilters?.disciplineId;
    final trainerCode = slot.trainerCode ?? parseOptInt(lastFilters?.trainerId);

    final schedulingDate = slot.schedulingDate.toLocal();

    return ScheduleBookingRequest(
      date: formatDateIso(schedulingDate),
      time: formatTimeIso(schedulingDate),
      bookingDuration: slot.duration ?? 0,
      disciplineCode: disciplineCode ?? 0,
      trainerCode: trainerCode ?? 0,
    );
  }
}
