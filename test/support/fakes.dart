import 'dart:async';

import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/booking/booking_state_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';
import 'package:fitnesscenter_mobile/features/bookings/domain/domain.dart';
import 'package:fitnesscenter_mobile/features/class_booking/domain/agenda_refresh_port.dart';
import 'package:fitnesscenter_mobile/features/class_booking/domain/class_booking_repository.dart';

/// Hand-written fakes over the feature repository interfaces.
///
/// The view-models take their collaborators through constructor injection
/// against `abstract interface class` ports, so the tests need no mocking
/// package: each fake records the calls it received and replays a scripted
/// result or error.

// -----------------------------------------------------------------------------
// Fixtures
// -----------------------------------------------------------------------------

/// Fixed clock so scheduling dates never depend on the wall clock.
final DateTime kTestNow = DateTime.utc(2026, 3, 10, 9);

BookingDto buildBooking({
  String bookingId = 'bk-1',
  String state = 'PENDING',
  String memberName = 'Alex Miembro',
  String? serviceName = 'Yoga al Amanecer',
  DateTime? schedulingDate,
}) {
  return BookingDto(
    bookingId: bookingId,
    creationDate: kTestNow.subtract(const Duration(days: 1)),
    schedulingDate: schedulingDate ?? kTestNow.add(const Duration(days: 2)),
    state: state,
    duration: 60,
    memberRut: '11.111.111-1',
    memberName: memberName,
    memberPhone: '+56911111111',
    serviceName: serviceName,
    disciplineName: 'Yoga',
    trainerName: 'Jordan Entrenador',
  );
}

AvailableSlotDto buildSlot({
  String bookingId = 'slot-1',
  DateTime? schedulingDate,
}) {
  return AvailableSlotDto(
    bookingId: bookingId,
    schedulingDate: schedulingDate ?? kTestNow.add(const Duration(days: 1)),
    serviceName: 'GROUP',
    trainerName: 'Jordan Entrenador',
    disciplineName: 'Yoga',
    duration: 60,
  );
}

AvailableSlotByCapabilityDto buildCapabilitySlot({
  int classTypeId = 7,
  String slotAssignmentCode = 'slot-assign-1',
  DateTime? schedulingDate,
}) {
  return AvailableSlotByCapabilityDto(
    schedulingDate: schedulingDate ?? kTestNow.add(const Duration(days: 1)),
    trainerName: 'Jordan Entrenador',
    disciplineName: 'Yoga',
    capabilityDescription: 'Yoga al Amanecer',
    trainerCode: 2001,
    classTypeId: classTypeId,
    slotAssignmentCode: slotAssignmentCode,
  );
}

/// Row shape the bookings table hands back to the view-model.
Map<String, dynamic> buildRow({
  String bookingId = 'bk-1',
  String bookingStatus = 'PENDING',
}) {
  return <String, dynamic>{
    'bookingId': bookingId,
    'bookingStatus': bookingStatus,
  };
}

// -----------------------------------------------------------------------------
// Fakes
// -----------------------------------------------------------------------------

class FakeBookingsRepository implements BookingsRepository {
  FakeBookingsRepository({
    List<BookingDto>? bookings,
    List<BookingStateDto>? states,
  }) : _bookings = bookings ?? <BookingDto>[],
       _states = states ?? <BookingStateDto>[];

  List<BookingDto> _bookings;
  final List<BookingStateDto> _states;

  /// When set, the matching call throws this instead of returning.
  Object? fetchBookingsError;
  Object? fetchBookingStatesError;
  Object? updateBookingStatusError;

  /// Recorded calls, in order.
  final List<({String bookingId, String state})> statusUpdates = [];
  int fetchBookingsCallCount = 0;

  /// Lets a test swap what the post-update refresh returns.
  void setBookings(List<BookingDto> value) => _bookings = value;

  @override
  Future<List<BookingDto>> fetchBookings({
    String? bookingStatus,
    bool includeAllDates = false,
    int? pageSize,
  }) async {
    fetchBookingsCallCount++;
    if (fetchBookingsError != null) throw fetchBookingsError!;
    return List<BookingDto>.of(_bookings);
  }

  @override
  Future<BookingDto> fetchBookingDetails({required String bookingId}) async {
    return _bookings.firstWhere((booking) => booking.bookingId == bookingId);
  }

  @override
  Future<List<BookingStateDto>> fetchBookingStates() async {
    if (fetchBookingStatesError != null) throw fetchBookingStatesError!;
    return List<BookingStateDto>.of(_states);
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String state,
    String? observation,
  }) async {
    statusUpdates.add((bookingId: bookingId, state: state));
    if (updateBookingStatusError != null) throw updateBookingStatusError!;
  }
}

class FakeClassBookingRepository implements ClassBookingRepository {
  Object? bookStandardError;
  Object? bookByClassTypeError;

  final List<AvailableSlotDto> standardBookings = [];
  final List<AvailableSlotByCapabilityDto> classTypeBookings = [];

  /// Completes only when the test decides to, so re-entrancy can be exercised.
  Completer<void>? gate;

  @override
  Future<void> bookStandard({
    required AvailableSlotDto slot,
    MemberAvailabilityFilters? listingContext,
  }) async {
    standardBookings.add(slot);
    if (gate != null) await gate!.future;
    if (bookStandardError != null) throw bookStandardError!;
  }

  @override
  Future<void> bookByClassType({
    required AvailableSlotByCapabilityDto slot,
  }) async {
    classTypeBookings.add(slot);
    if (gate != null) await gate!.future;
    if (bookByClassTypeError != null) throw bookByClassTypeError!;
  }
}

class FakeAgendaRefreshPort implements AgendaRefreshPort {
  int refreshCount = 0;
  Object? refreshError;

  @override
  Future<void> refreshAgenda() async {
    refreshCount++;
    if (refreshError != null) throw refreshError!;
  }
}
